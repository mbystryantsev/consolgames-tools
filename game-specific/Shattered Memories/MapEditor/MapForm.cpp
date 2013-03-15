//---------------------------------------------------------------------------
                 
#include "gldraw.h"
#include <vcl.h>

#include "MapForm.h"
#include "map_editor.h"
#include "gl\gl.h"
#include "gl\glu.h"
#include "map.h"
#include "font.h"
#pragma hdrstop

//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"


SCharData* chars;
int char_count;
TFormMap *FormMap;
HDC hDC;
unsigned int font_tex = 0;
extern SCaption* cur_capt;
extern bool EditAllow;

float x = 0, y = 0, scale = 1.0;
float xx, yy, mx, my, cxx, cyy, cmx, cmy;


CGLDraw draw;
//---------------------------------------------------------------------------
__fastcall TFormMap::TFormMap(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------

void DrawCaptions(SCaption* rec, SColor* colors, std::string** names, int count){
  int i, j, c, len;
  char *s;
  glEnable(GL_TEXTURE_2D);
  glBindTexture(GL_TEXTURE_2D, font_tex);
  for(i = 0; i < count; i++){
    glLoadIdentity();
    //glScalef(1.0f / rec[i].scale, 1.0f / rec[i].scale, 0);
    glTranslatef(-x, -y, 0);
    glScalef(scale, scale, 0);
    glTranslatef(rec[i].x, rec[i].y, 0);
    glScalef(rec[i].scale / 15, rec[i].scale / 15, 0);
    glTranslatef(1, -12, 0);
    glTranslatef(0, 16, 0);
    glRotatef(360.0f - rec[i].angle, 0, 0, 1);
    glTranslatef(0, -16, 0);
    glColor4f(
      float(colors[rec[i].color].r) / 255.0f,
      float(colors[rec[i].color].g) / 255.0f,
      float(colors[rec[i].color].b) / 255.0f,
      float(colors[rec[i].color].a) / 255.0f
    );
    //len = MultiByteToWideChar(CP_ACP, 0, names + rec[i].str_offset, strlen(names + rec[i].str_offset), buf, 255);
    //len = WideCharToMultiByte(CP_UTF8, 0, names + j, strlen(names + j), 255, 0, 0);
    //buf[len] = 0;
    //for(j = 0; buf[j]; j++){
    s = (char*)names[i]->data();
    for(j = 0; s[j]; j++){
      for(c = 0; c < char_count; c++){
        if(char(chars[c].code) == s[j]) break;
      }
      if(c < char_count){
        glBegin(GL_QUADS);
          glTexCoord2f((c % 16) * 32 + 00, (c / 16) * 32 + 00 + 4);
          glVertex2f(0, 0);
          glTexCoord2f((c % 16) * 32 + 32, (c / 16) * 32 + 00 + 4);
          glVertex2f(32, 0);
          glTexCoord2f((c % 16) * 32 + 32, (c / 16) * 32 + 32 + 0);
          glVertex2f(32, 32 - 4);
          glTexCoord2f((c % 16) * 32 + 00, (c / 16) * 32 + 32 + 0);
          glVertex2f(0, 32 - 4);
        glEnd();
        glTranslatef(chars[c].width, 0, 0);
      }
    }
  }
  glDisable(GL_TEXTURE_2D);
}

void DrawPolygons(SPolygon* polygons, SColor* colors, SVertex* vertexes, int count){
  int i;
  glBegin(GL_TRIANGLES);
      for(i = 0; i < count; i++){
        glColor4f(
          float(colors[polygons[i].color].r) / 255.0f,
          float(colors[polygons[i].color].g) / 255.0f,
          float(colors[polygons[i].color].b) / 255.0f,
          float(colors[polygons[i].color].a) / 255.0f
        );
        //glColor3f(1, 0, 0);
        glVertex2fv((float*)&vertexes[polygons[i].v[0]]);
        glVertex2fv((float*)&vertexes[polygons[i].v[1]]);
        glVertex2fv((float*)&vertexes[polygons[i].v[2]]);
      }
  glEnd();
}

void DrawLines(SLine* lines, SColor* colors, SVertex* vertexes, int count){
  int i;
  glBegin(GL_LINES);
    for(i = 0; i < count; i++){
      glColor4f(
        float(colors[lines[i].color].r) / 255.0f,
        float(colors[lines[i].color].g) / 255.0f,
        float(colors[lines[i].color].b) / 255.0f,
        float(colors[lines[i].color].a) / 255.0f
      );
      glVertex2fv((float*)&vertexes[lines[i].v[0]]);
      glVertex2fv((float*)&vertexes[lines[i].v[1]]);
    }
  glEnd();
}


void __fastcall TFormMap::FormCreate(TObject *Sender)
{
  static  PIXELFORMATDESCRIPTOR pfd = // pfd сообщает Windows каким будет вывод на экран каждого пикселя
  {
    sizeof( PIXELFORMATDESCRIPTOR ), // Размер дескриптора данного формата пикселей
    1,                   // Номер версии
    PFD_DRAW_TO_WINDOW | // Формат для Окна
    PFD_SUPPORT_OPENGL | // Формат для OpenGL
    PFD_DOUBLEBUFFER,    // Формат для двойного буфера
    PFD_TYPE_RGBA,       // Требуется RGBA формат
    24,//BitCount,            // Выбирается бит глубины цвета
    0, 0, 0, 0, 0, 0,    // Игнорирование цветовых битов
    0,                   // Нет буфера прозрачности
    0,                   // Сдвиговый бит игнорируется
    0,                   // Нет буфера накопления
    0, 0, 0, 0,          // Биты накопления игнорируются
    0,//16,//32,                  // 32 битный Z-буфер (буфер глубины)
    0,//8,                   // Нет буфера трафарета
    0,                   // Нет вспомогательных буферов
    PFD_MAIN_PLANE,      // Главный слой рисования
    0,                   // Зарезервировано
    0, 0, 0              // Маски слоя игнорируются
  };


  if( !( hDC = GetDC( this->Handle ) ) ) // Можем ли мы получить Контекст Устройства?
  {
    MessageBox( NULL, "Can't Create A GL Device Context.", "ERROR", MB_OK | MB_ICONEXCLAMATION );
    return;
  }

  int PixelFormat;
  if( !( PixelFormat = ChoosePixelFormat( hDC, &pfd ) ) ) // Найден ли подходящий формат пикселя?
  {
    MessageBox( NULL, "Can't Find A Suitable PixelFormat.", "ERROR", MB_OK | MB_ICONEXCLAMATION );
    return;
  }

  if( !SetPixelFormat( hDC, PixelFormat, &pfd ) ) // Возможно ли установить Формат Пикселя?
  {
    MessageBox( NULL, "Can't Set The PixelFormat.", "ERROR", MB_OK | MB_ICONEXCLAMATION );
    return;
  }


  draw.Initialize(this->Handle, hDC);

  font_tex = MainForm->LoadFont("FontEUR.shf");


  glEnable(GL_ALPHA_TEST);
  glAlphaFunc(GL_GREATER, 0.0f);
  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  //glEnable(GL_DEPTH_TEST);
  glDisable(GL_DEPTH_TEST);

  glMatrixMode(GL_TEXTURE);
  glLoadIdentity();
  glScalef(1.0f / 512.0f, 1.0f / 512.0f, 1);
  glMatrixMode(GL_MODELVIEW);
}

void __fastcall TFormMap::DrawLayer(int layer){
    glLoadIdentity();
    glTranslatef(-x, -y, 0);
    glScalef(scale, scale, 1);
    DrawPolygons(map->layers[layer]->polygons, map->colors, map->vertexes, map->layers[layer]->getPolygonCount());
    DrawLines(map->layers[layer]->lines, map->colors, map->vertexes, map->layers[layer]->getLineCount());
    DrawCaptions(map->layers[layer]->captions, map->colors, map->layers[layer]->names, map->layers[layer]->getCaptionCount());
}

//---------------------------------------------------------------------------
void __fastcall TFormMap::FormPaint(TObject *Sender)
{
  int i, cur_layer = MainForm->eLayers->ItemIndex, cur_capt = MainForm->eCaptions->ItemIndex;
  glClearColor(0, 0, 0, 0);
  glClear( GL_COLOR_BUFFER_BIT /*| GL_DEPTH_BUFFER_BIT */);

  glLineWidth(1);
  if(MainForm->eCurOnly->Checked){
        DrawLayer(cur_layer);
  } else {
        for(i = 0; i < map->getLayerCount(); i++){
            DrawLayer(i);
        }
  }
  /*
  DrawLayer(0);
  DrawLayer(1);
  DrawLayer(2);
  DrawLayer(3);
  DrawLayer(4);
  DrawLayer(5);
  DrawLayer(6);
  */


  //glEnable(GL_TEXTURE_2D);

  /*
  glBegin(GL_QUADS);
    glTexCoord2f(0, 0);
    glVertex2f(0, 0);
    glTexCoord2f(512, 0);
    glVertex2f(512, 0);
    glTexCoord2f(512, 512);
    glVertex2f(512, 512);
    glTexCoord2f(0, 512);
    glVertex2f(0, 512);
  glEnd();
  */

  if(cur_capt >= 0){
    glLineWidth(4);
    glLoadIdentity();
    glTranslatef(-x, -y, 0);
    glScalef(scale, scale, 1);
    glColor4f(1, 0, 0, 0.5f);
    glBegin(GL_LINES);
      glVertex2f(0, 0);
      glVertex2f(map->layers[cur_layer]->captions[cur_capt].x, map->layers[cur_layer]->captions[cur_capt].y);
    glEnd();
  }

  SwapBuffers(hDC);
}
//---------------------------------------------------------------------------

void __fastcall TFormMap::UpdateData(){
}
void __fastcall TFormMap::FormDestroy(TObject *Sender)
{
        glDeleteTextures(1, &font_tex);
}
//---------------------------------------------------------------------------

void __fastcall TFormMap::FormResize(TObject *Sender)
{
   glViewport(0,0, this->Width , this->Height);
   glMatrixMode( GL_PROJECTION );
   glLoadIdentity();
   //gluOrtho2D(0, min(width, header->width), min(height, header->height), 0);
   //gluOrtho2D(0, header->width, header->height, 0);
   gluOrtho2D(0, this->Width, this->Height, 0);
   glMatrixMode( GL_MODELVIEW );
   glLoadIdentity();
}
//---------------------------------------------------------------------------

void __fastcall TFormMap::FormMouseMove(TObject *Sender, TShiftState Shift,
      int X, int Y)
{
  if(Shift.Contains(ssLeft)){
        x = xx + (mx - X);
        y = yy + (my - Y);
        FormPaint(NULL);
  } else if(Shift.Contains(ssRight) && cur_capt){
        cur_capt->x = cxx - (cmx - X) / scale;
        cur_capt->y = cyy - (cmy - Y) / scale;      
        EditAllow = false;
        MainForm->eX->Text = FloatToStr(cur_capt->x);
        MainForm->eY->Text = FloatToStr(cur_capt->y);
        EditAllow = true;   
        FormPaint(NULL);
  }
}
//---------------------------------------------------------------------------

void __fastcall TFormMap::FormMouseDown(TObject *Sender,
      TMouseButton Button, TShiftState Shift, int X, int Y)
{
  if(Button == mbLeft){
    xx = x;
    yy = y;
    mx = X;
    my = Y;
  } else if (Button == mbRight && cur_capt){
    cxx = cur_capt->x;
    cyy = cur_capt->y;
    cmx = X;
    cmy = Y;
  }
}
//---------------------------------------------------------------------------


void __fastcall TFormMap::FormMouseWheel(TObject *Sender,
      TShiftState Shift, int WheelDelta, TPoint &MousePos, bool &Handled)
{
    if(Shift.Contains(ssShift) && cur_capt){
        if(WheelDelta > 0)
          cur_capt->scale += 1;
        else
          cur_capt->scale -= 1;
        if(cur_capt->scale < 1) cur_capt->scale = 1;
        EditAllow = false;
        MainForm->eSize->Text = FloatToStr(cur_capt->scale);
        EditAllow = true;
    } else{
        scale += float(WheelDelta) / 1000.0f;
        if(scale < 0.5) scale = 0.5;
        if(scale > 20.0) scale = 20.0;
    }
    FormPaint(NULL);
}
//---------------------------------------------------------------------------

void __fastcall TFormMap::FormShow(TObject *Sender)
{
    MainForm->AViewMap->Checked = true;
}
//---------------------------------------------------------------------------

void __fastcall TFormMap::FormHide(TObject *Sender)
{
    MainForm->AViewMap->Checked = false;
}
//---------------------------------------------------------------------------

