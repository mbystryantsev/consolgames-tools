//#include "draw.h"
#include "GLDraw.h"
#include "draw.h"
#include <gl\gl.h>
#include <gl\glu.h>

void CCommonDraw::Finalize(){
  if( hRC )                               // Существует ли Контекст Рендеринга?
  {
    if( !wglMakeCurrent( NULL, NULL ) ) // Возможно ли освободить RC и DC?
    {
      MessageBox( NULL, "Release Of DC And RC Failed.", "SHUTDOWN ERROR", MB_OK | MB_ICONINFORMATION );
    }
    if( !wglDeleteContext( hRC ) )      // Возможно ли удалить RC?
    {
      MessageBox( NULL, "Release Rendering Context Failed.", "SHUTDOWN ERROR", MB_OK | MB_ICONINFORMATION );
    }
    hRC = NULL;                         // Установить RC в NULL
  }
}

int CCommonDraw::Initialize(HWND hWnd, HDC _hDC){

  Finalize();

  HDC hDC;
  if(!_hDC) hDC = GetDC(hWnd);
  else hDC = _hDC;
  //HDC hDC = Application->getDC();

  if( !( hRC = wglCreateContext( hDC ) ) ) // Возможно ли установить Контекст Рендеринга?
  {
    Finalize(); // Восстановить экран
    MessageBox( NULL, "Can't Create A GL Rendering Context.", "ERROR", MB_OK | MB_ICONEXCLAMATION);
    return false;   // Вернуть false
  }

  if( !wglMakeCurrent( hDC, hRC ) ) // Попробовать активировать Контекст Рендеринга
  {
    Finalize(); // Восстановить экран
    MessageBox( NULL, "Can't Activate The GL Rendering Context.", "ERROR", MB_OK | MB_ICONEXCLAMATION );
    return false;   // Вернуть false
  }
  
  glShadeModel( GL_SMOOTH );              // Разрешить плавное цветовое сглаживание

  glClearColor(0.0f, 0.0f, 0.0f, 0.0f);   // Очистка экрана в черный цвет

  //glClearDepth( 1.0f );                   // Разрешить очистку буфера глубины
  //glEnable( GL_DEPTH_TEST );              // Разрешить тест глубины
  //glEnable( GL_STENCIL_TEST );
  //glEnable(GL_TEXTURE_2D);
  //glEnable(GL_ALPHA_TEST);
  //glDepthFunc( GL_LEQUAL );               // Тип теста глубины

  //glHint( GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST ); // Улучшение в вычислении перспективы

  return true; // Инициализация прошла успешно
}

void CCommonDraw::ResizeScene( int width, int height, int x, int y ) // Изменить размер и инициализировать окно GL
{
    glViewport( x, y, width, height );  // Сброс текущей области вывода

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    
    //glOrtho(0, width, height, 0, -1, 1);
    gluOrtho2D(0, width, height, 0);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    //glMatrixMode( GL_PROJECTION );      // Выбор матрицы проекций
    //glLoadIdentity();                   // Сброс матрицы проекции
    
    // Вычисление соотношения геометрических размеров для окна
    //gluPerspective( 45.0f, (GLfloat) width / (GLfloat) height, 0.1f, 100.0f );

    //glMatrixMode( GL_MODELVIEW );       // Выбор матрицы вида модели
    //glLoadIdentity();                   // Сброс матрицы вида модели
}


void CCommonDraw::DrawLine(float x1, float y1, float x2, float y2){
    glBegin(GL_LINES);
      glVertex2f(x1, y1);
      glVertex2f(x2, y2);
    glEnd();
}

void CCommonDraw::DrawRectanglePos(float x, float y, float w, float h){
    glRectf(x, y, x + w, y + h);
}

void CCommonDraw::DrawRectangle(float x1, float y1, float x2, float y2){
    glRectf(x1, y1, x2, y2);
}


void CCommonDraw::DrawTexture(CTexture *tex, float x1, float y1, float x2, float y2,
        float tx1, float ty1, float tx2, float ty2)
{
    int id = tex->getName();
    setTextureMatrix(tex);
    glBindTexture(GL_TEXTURE_2D, id);
    glBegin(GL_QUADS);
      glTexCoord2f(tx1, ty1);   // Первая точка на текстуре
      glVertex2f(x1, y1);       // Первая вершина
      glTexCoord2f(tx1, ty2);   // Вторая точка на текстуре
      glVertex2f(x1, y2);      // Вторая вершина
      glTexCoord2f(tx2, ty2);   // Третья точка на текстуре
      glVertex2f(x2, y2);      // Третья вершина
      glTexCoord2f(tx2, ty1);   // Четвертая точка на текстуре
      glVertex2f(x2, y1);       // Четвертая вершина
    glEnd();
}

int CCommonDraw::AddTexture(int Width, int Height, void *pixels, int PixelFormat = DRAW_COLOR_RGBA){
    unsigned int tex;
    int pixel_format = GL_RGBA;
    if (PixelFormat == DRAW_COLOR_RGB) pixel_format = GL_RGB;

    glGenTextures(1, &tex);
    glBindTexture(GL_TEXTURE_2D, tex);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,  GL_LINEAR /* GL_NEAREST */);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,  GL_LINEAR /* GL_NEAREST */);
    gluBuild2DMipmaps(GL_TEXTURE_2D, GL_RGBA, Width, Height, pixel_format, GL_UNSIGNED_BYTE, pixels);
    
    return tex;
}

int CCommonDraw::AddMaskTexture(int Width, int Height, void *pixels, int PixelFormat = DRAW_COLOR_RGBA){
   int* buf = (int*)malloc(Width * Height * 4);
   int i;
   for(i = 0; i < Width * Height; i++){
     *(buf + i) |= 0x00FFFFFF;
   }

   i = AddTexture(Width, Height, pixels, PixelFormat);
   
   free(buf);
   return i;
}


void CCommonDraw::setTextureMatrix(CTexture *tex){
    static int w, h;
    glMatrixMode(GL_TEXTURE);
    glLoadIdentity();
    w = tex->getWidth();
    h = tex->getHeight();
    if(w > 0 && h > 0){
        glScaled(1.0 / w, 1.0 / h, 1.0);
    }
    glMatrixMode(GL_MODELVIEW);
}

void CCommonDraw::DeleteTexture(CTexture* tex){
  unsigned int id = tex->getName();
  glDeleteTextures(1, &id);
  id = tex->getMaskTexture();
  if(id) glDeleteTextures(1, &id);
}


void CCommonDraw::DrawTextureRect(CTexture* tex, TRect *rect, TRect *coords){
    int id = tex->getName();
    if(!id) return;
    setTextureMatrix(tex);
    glBindTexture(GL_TEXTURE_2D, id);
    glBegin(GL_QUADS);
        glTexCoord2f(coords->left, coords->top);
        glVertex2f(rect->left, rect->top);

        glTexCoord2f(coords->right, coords->top);
        glVertex2f(rect->right, rect->top);

        glTexCoord2f(coords->right, coords->bottom);
        glVertex2f(rect->right, rect->bottom);

        glTexCoord2f(coords->left, coords->bottom);
        glVertex2f(rect->left, rect->bottom);
        //glRectfv((float*)rect, (float*)&(rect->top));
    glEnd();
}
