#ifndef __GLDRAW_H
#define __GLDRAW_H

#include <windows.h>
#include <gl\gl.h>    // OpenGL32
//#include <gl\glu.h>   // GLu32
//#include "texture.h"
#include "draw.h"

typedef struct{
  float r, g, b, a;
} TColor;

// CGLDraw
class CGLDraw: public CCommonDraw{
  //TColor ClearColor;
public:
  CGLDraw(): CCommonDraw(){}
  void ClearColor(float r, float g, float b, float  a){
    glClearColor(r, g, b, a);
  }
  void Clear(){
    glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  }
  void BeginStencil(){
    glClear(GL_STENCIL_BUFFER_BIT);
    glStencilFunc(GL_ALWAYS, 1, 0); // значение mask не используется
    glStencilOp(GL_REPLACE, GL_KEEP, GL_KEEP);
  }
  void EndStencil(){
    glStencilFunc(GL_EQUAL, 1, 255);
  }
  void setColor(float r, float g, float b, float a){
    glColor4f(r, g, b, a);
  }
  void _beginQuads(){
    glBegin(GL_QUADS);
  }
  void _end(){
    glEnd();
  }
  void _vertex(float x, float y){
    glVertex2f(x, y);
  }
};

typedef CGLDraw CDraw;


#endif /* __GLDRAW_H */
