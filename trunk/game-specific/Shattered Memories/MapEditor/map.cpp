#include "map.h"

#include <stdio.h>


char* CLayer::LoadLayer(void* data, char* str_data, bool first){
    int i, size;
    free_layer();
    //key = *(int*)data;
    if(first) name.assign("(main)");
    else name.assign(&str_data[*(int*)data]);
    polygon_count = *(((int*)data) + 1);
    (int*)data += 2;
    size = sizeof(SPolygon) * polygon_count;
    polygons = (SPolygon*)malloc(size);
    memcpy(polygons, data, size);
    ((char*)data) += size;

    line_count = *(int*)data;
    ((int*)data)++;
    size = sizeof(SLine) * line_count;
    lines = (SLine*)malloc(size);
    memcpy(lines, data, size);
    ((char*)data) += size;

    caption_count = *(int*)data;
    names = (string**)malloc(sizeof(string**) * caption_count);
    captions = (SCaption*)malloc(sizeof(SCaption) * caption_count);
    memcpy(captions, (int*)data + 1, sizeof(SCaption) * caption_count);
    for(i = 0; i < caption_count; i++){
      names[i] = new string();
      names[i]->assign(str_data + captions[i].str_offset);
    }
    return ((char*)data) + 4 + sizeof(SCaption) * caption_count;
}


void CLayer::DeleteCaption(int index){
  int i;
  if(index < 0 || index >= caption_count) return;
  delete names[index];
  for(i = index; i < caption_count - 1; i++){
    names[i] = names[i + 1];
    captions[i] = captions[i + 1];
  }
  caption_count--;
}


void CLayer::InsertCaption(int index){
  int i;
  if((index < 0 || index >= caption_count) && index != -1) return;
  if(index == -1) index = 0;

  caption_count++;
  captions = (SCaption*)realloc(captions, caption_count * sizeof(SCaption));
  names = (string**)realloc(names, caption_count * sizeof(string**));
  for(i = caption_count - 1; i > index; i--){
    captions[i] = captions[i - 1];
    names[i] = names[i - 1];
  }
  names[index] = new string();
  if(index > 0) names[index]->assign(*names[index - 1]); 
  if(index == 0){
    memset(&captions[0], 0, sizeof(SCaption));
    captions[0].scale = 12;
    names[index]->assign("New Caption");  
  }
}

#define LAYER_COUNT 7
void CMap::LoadMap(void *data){

    int i, count;
    char *str_data;
    free_map();
    //memcpy(&header, data, sizeof(SMapHeader));
    header = *(SMapHeader*)data;
    vertex_count = header.vertex_count;
    vertexes = (SVertex*)malloc(vertex_count * sizeof(SVertex));
    memcpy(vertexes, ((char*)data) + sizeof(SMapHeader), vertex_count * sizeof(SVertex));
    char *d = ((char*)data) + sizeof(SMapHeader) + vertex_count * sizeof(SVertex);
    color_count = *(int*)d;
    d += 4;
    colors = (SColor*)malloc(color_count * sizeof(SColor));
    memcpy(colors, d, color_count * sizeof(SColor));
    d += color_count * sizeof(SColor);
    str_data = d + 4;
    d += 4 + *(int*)d;

    layer_count = *(int*)d;
    layers = (CLayer**)malloc(LAYER_COUNT * sizeof(CLayer**));
    for(i = 0; i < layer_count; i++){
      layers[i] = new CLayer();
      d = layers[i]->LoadLayer(d, str_data, i == 0);
    }
}

void CMap::LoadFromFile(char* name){
    FILE *f = fopen(name, "rb");
    fseek(f, 0, SEEK_END);
    int size = ftell(f);
    fseek(f, 0, SEEK_SET);
    char *buf = (char*)malloc(size);
    fread(buf, size, 1, f);
    fclose(f);
    LoadMap(buf);
    free(buf);
}

int CMap::getMapSize(){
    int i, size = 4;
    for(i = 0; i < layer_count; i++){
      size += layers[i]->getStringsSize();
      size += layers[i]->name.length() + 1;
    }
    size = (size + 3) & 0xFFFFFFFC;
    size += sizeof(SMapHeader) + vertex_count * sizeof(SVertex) +
           color_count * sizeof(SColor) + 4;
    for(i = 0; i < layer_count; i++){
      size += layers[i]->getLayerSize();
    }
    return size;
}


#define write_p(d, size) memcpy(p, d, size); p += size;
#define write_i(d) *(int*)p = d; p += 4;
int CMap::SaveMap(void *data){
  char* p = (char*)data;
  int *str_size, i, j;
  write_p(&header, sizeof(SMapHeader));
  write_p(vertexes, vertex_count * sizeof(SVertex));
  write_p(&color_count, 4);
  write_p(colors, color_count * sizeof(SColor));
  str_size = (int*)p;
  p += 4;
  *p++ = 0;
  for(i = 0; i < layer_count; i++){
      if(i > 0){
         layers[i]->name_pos = int(p - (char*)str_size - 4);
         write_p(layers[i]->name.data(), layers[i]->name.length() + 1);
      } else layers[i]->name_pos = layer_count;
      for(j = 0; j < layers[i]->getCaptionCount(); j++){
         layers[i]->captions[j].str_offset = int(p - (char*)str_size - 4);
         write_p(layers[i]->names[j]->data(), layers[i]->names[j]->length() + 1);
      }
  }
  if((int)p % 4) p += (4 - (int)p % 4);
  *str_size = int(p - (char*)str_size - 4);
  for(i = 0; i < layer_count; i++){
      write_i(layers[i]->name_pos);
      write_i(layers[i]->getPolygonCount());
      write_p(layers[i]->polygons, layers[i]->getPolygonCount() * sizeof(SPolygon));
      write_i(layers[i]->getLineCount());
      write_p(layers[i]->lines, layers[i]->getLineCount() * sizeof(SLine));
      write_i(layers[i]->getCaptionCount());
      write_p(layers[i]->captions, layers[i]->getCaptionCount() * sizeof(SCaption));
  }
  return p - (char*)data;
}
#undef write_p
#undef write_i

int CMap::SaveToFile(char* name){
  int size;
  char *buf;
  size = getMapSize();
  buf = (char*)malloc(size);
  size = SaveMap(buf);
  FILE *f = fopen(name, "wb");
  fwrite(buf, size, 1, f);
  fclose(f);
  free(buf);   
}


