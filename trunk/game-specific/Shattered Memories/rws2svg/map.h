#ifndef __MAP_H
#define __MAP_H

#include <string>
#include <malloc.h>
//#include <iostream>
//#include <windows.h>


using namespace std;
//string s;

struct SVertex
{
    float x, y;
};

struct SPolygon
{
    unsigned short color, v[3];
};

struct SLine
{
    unsigned short color, v[2];
};

struct SColor
{
    unsigned char r, g, b, a;
};

struct SMapHeader
{
    int signature;
    int width;
    int height;
    int vertex_count;
};

struct SCaption
{
    short str_offset;
    short color;
    float x, y;
    float angle;
    float scale; //?
};

class CLayer
{
    int polygon_count, line_count, caption_count;
    void free_layer()
    {
        int i;
        for(i = 0; i < caption_count; i++) delete names[i];
        if(caption_count)
        {
            free(names);
            free(captions);
            caption_count = 0;
        }
        if(polygon_count)
        {
            free(polygons);
            polygon_count = 0;
        }
        if(line_count)
        {
            free(lines);
            line_count = 0;
        }
        names = NULL;
        polygons = NULL;
        lines = NULL;
        captions = NULL;
    }
public:
    CLayer()
    {
        polygon_count = line_count = caption_count = 0;
    }
    ~CLayer()
    {
        free_layer();
    }
    int getCaptionCount()
    {
        return caption_count;
    }
    int getPolygonCount()
    {
        return polygon_count;
    }
    int getLineCount()
    {
        return line_count;
    }
    int getLayerSize()
    {
        return caption_count * sizeof(SCaption) +
               line_count * sizeof(SLine) +
               polygon_count * sizeof(SPolygon)
               + 16;
    }
    int getStringsSize()
    {
        int i, size = 0;
        for(i = 0; i < caption_count; i++)
        {
            size += names[i]->length() + 1;
        }
        return size;
    }
    void DeleteCaption(int index);
    void InsertCaption(int index);
    int name_pos;
    SPolygon* polygons;
    SLine* lines;
    SCaption* captions;
    string** names;
    unsigned char* LoadLayer(void* map_data, char* str_data, bool first = false);
    string name;
};

class CMap
{
    int layer_count;
    int vertex_count;
    int color_count;
    void free_map()
    {
        int i;
        for(i = 0; i < layer_count; i++) delete layers[i];
        if(layer_count) free(layers);
        if(vertex_count) free(vertexes);
        layers = NULL;
        vertexes = NULL;
    }
public:
    CMap()
    {
        layer_count = vertex_count =  color_count = 0;
    }
    ~CMap()
    {
        free_map();
    }
    int getLayerCount()
    {
        return layer_count;
    }
    int getColorCount()
    {
        return color_count;
    }
    int getMapSize();


    SMapHeader header;
    SVertex* vertexes;
    SColor* colors;
    CLayer **layers;

    void LoadMap(const void *data);
    void LoadFromFile(const char* name);
    int SaveMap(void *data);
    int SaveToFile(const char* name);
};

#endif /* __MAP_H */
