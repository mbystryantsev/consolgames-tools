#ifndef __DRAW_H
#define __DRAW_H

#include <windows.h>

#define DRAW_COLOR_RGB  1
#define DRAW_COLOR_RGBA 2

class CTexture;

typedef struct {
  float left, right, top, bottom;
} TRect;


class CCommonDraw{
  HGLRC hRC;
  HWND hWnd;
public:
  CCommonDraw():hRC(0),hWnd(0){}
  ~CCommonDraw(){
    Finalize();
  }
  int Initialize(HWND hWnd, HDC _hDC = 0);
  void Finalize();
  void ResizeScene(int width, int height, int x = 0, int y = 0);

  int AddTexture(int Width, int Height, void *pixels, int PixelFormat);
  int AddMaskTexture(int Width, int Height, void *pixels, int PixelFormat);


  static void DrawLine(float x1, float y1, float x2, float y2);
  static void DrawRectanglePos(float x, float y, float w, float h);
  static void DrawRectangle(float x1, float y1, float x2, float y2);
  static void DrawTexture(CTexture* tex, float x1, float y1, float x2, float y2,
        float tx1, float ty1, float tx2, float ty2);
  static void setTextureMatrix(CTexture *tex);
  void DeleteTexture(CTexture *tex);
  
  static void DrawTextureRect(CTexture* tex, TRect *rect, TRect *coords);

};


typedef struct{
  char* ptr;
  unsigned int size, pos;
} t_mem_rec;

class CTexture{
  //CDraw *draw;
  CCommonDraw* draw;
  int tex;
  int width, height;
public:
  //CTexture(CDraw* _draw){
  CTexture(CCommonDraw* _draw){
    draw = _draw;
    tex = width = height = 0;
  }
  ~CTexture(){
    if(tex) draw->DeleteTexture(this);
  }

  int getName(){
    return tex;
  }
  int getMaskTexture(){
    return tex;
  }
  void setMatrix(){
    draw->setTextureMatrix(this);
  }
  void Draw(float x1, float y1, float x2, float y2, float tx1, float ty1, float tx2, float ty2){
    draw->DrawTexture(this, x1, y1, x2, y2, tx1, ty1, tx2, ty2);
  }
  void DrawPos(float x, float y, float w, float h, float tx1, float ty1, float tx2, float ty2){
    draw->DrawTexture(this, x, y, x + w, y + h, tx1, ty1, tx2, ty2);
  }

  int getWidth(){
    return width;
  }
  int getHeight(){
    return height;
  }
  //CDraw* getDraw(){
  CCommonDraw* getDraw(){
    return draw;
  }

};








#endif /* __DRAW_H */


