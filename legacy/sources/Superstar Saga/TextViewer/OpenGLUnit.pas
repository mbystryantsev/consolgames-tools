unit OpenGLUnit;

interface

uses Windows, OpenGL;

var
  RC: HGLRC;
  DC: HDC;
                            
procedure glGenTextures(n: GLsizei; textures: PGLuint); stdcall;
{$EXTERNALSYM glGenTextures}
procedure glBindTexture(target: GLenum; texture: GLuint); stdcall;
{$EXTERNALSYM glBindTexture}
procedure glDeleteTextures(n: GLsizei; textures: PGLuint); stdcall;
{$EXTERNALSYM glDeleteTextures}
procedure glTexParameterf(target, pname: GLenum; param: GLfloat); stdcall;
{$EXTERNALSYM glTexParameterf}
procedure glTexParameteri(target, pname: GLenum; param: GLint); stdcall;
{$EXTERNALSYM glTexParameteri}
procedure glTexParameterfv(target, pname: GLenum; const param: PGLfloat); stdcall;
{$EXTERNALSYM glTexParameterfv}
procedure glTexParameteriv(target, pname: GLenum; const param: PGLint); stdcall;
{$EXTERNALSYM glTexParameteriv}
function gluBuild2DMipmaps(target: GLenum; components, width, height: GLint;
  format, _type: GLenum; data: Pointer): GLuint; stdcall;
{$EXTERNALSYM gluBuild2DMipmaps}

procedure glEnableClientState(_array: GLenum); stdcall;
{$EXTERNALSYM glEnableClientState}
procedure glDisableClientState(_array: GLenum); stdcall;
{$EXTERNALSYM glDisableClientState}
procedure glVertexPointer(size: GLint; _type: GLenum; stride: GLsizei; const _pointer: Pointer); stdcall;
{$EXTERNALSYM glVertexPointer}
procedure glTexCoordPointer(size: GLint; _type: GLenum; stride: GLsizei; const _pointer: Pointer); stdcall;
{$EXTERNALSYM glTexCoordPointer}
procedure glDrawArrays(mode: GLenum; first: GLint; count: GLsizei); stdcall;
{$EXTERNALSYM glDrawArrays}

const
// vertex_array
  GL_VERTEX_ARRAY                   = $8074;
  GL_NORMAL_ARRAY                   = $8075;
  GL_COLOR_ARRAY                    = $8076;
  GL_INDEX_ARRAY                    = $8077;
  GL_TEXTURE_COORD_ARRAY            = $8078;
  GL_EDGE_FLAG_ARRAY                = $8079;
  GL_VERTEX_ARRAY_SIZE              = $807A;
  GL_VERTEX_ARRAY_TYPE              = $807B;
  GL_VERTEX_ARRAY_STRIDE            = $807C;
  GL_NORMAL_ARRAY_TYPE              = $807E;
  GL_NORMAL_ARRAY_STRIDE            = $807F;
  GL_COLOR_ARRAY_SIZE               = $8081;
  GL_COLOR_ARRAY_TYPE               = $8082;
  GL_COLOR_ARRAY_STRIDE             = $8083;
  GL_INDEX_ARRAY_TYPE               = $8085;
  GL_INDEX_ARRAY_STRIDE             = $8086;
  GL_TEXTURE_COORD_ARRAY_SIZE       = $8088;
  GL_TEXTURE_COORD_ARRAY_TYPE       = $8089;
  GL_TEXTURE_COORD_ARRAY_STRIDE     = $808A;
  GL_EDGE_FLAG_ARRAY_STRIDE         = $808C;
  GL_VERTEX_ARRAY_POINTER           = $808E;
  GL_NORMAL_ARRAY_POINTER           = $808F;
  GL_COLOR_ARRAY_POINTER            = $8090;
  GL_INDEX_ARRAY_POINTER            = $8091;
  GL_TEXTURE_COORD_ARRAY_POINTER    = $8092;
  GL_EDGE_FLAG_ARRAY_POINTER        = $8093;
  GL_V2F                            = $2A20;
  GL_V3F                            = $2A21;
  GL_C4UB_V2F                       = $2A22;
  GL_C4UB_V3F                       = $2A23;
  GL_C3F_V3F                        = $2A24;
  GL_N3F_V3F                        = $2A25;
  GL_C4F_N3F_V3F                    = $2A26;
  GL_T2F_V3F                        = $2A27;
  GL_T4F_V4F                        = $2A28;
  GL_T2F_C4UB_V3F                   = $2A29;
  GL_T2F_C3F_V3F                    = $2A2A;
  GL_T2F_N3F_V3F                    = $2A2B;
  GL_T2F_C4F_N3F_V3F                = $2A2C;
  GL_T4F_C4F_N3F_V4F                = $2A2D;


Function GLInitialize(Handle: HWND): Boolean;
Procedure GLResize(Rect: TRect);
Function LoadTexture(Width, Height: Integer; data: Pointer; ColorType: Integer = GL_RGBA): Cardinal;
Procedure GLFinalize();


implementation

uses
  Dialogs;

procedure glGenTextures; external opengl32;
procedure glBindTexture; external opengl32;
procedure glDeleteTextures; external opengl32;
procedure glTexParameterf; external opengl32;
procedure glTexParameteri; external opengl32;
procedure glTexParameterfv; external opengl32;
procedure glTexParameteriv; external opengl32;
function gluBuild2DMipmaps; external glu32;

procedure glEnableClientState; external opengl32;
procedure glDisableClientState; external opengl32;
procedure glVertexPointer; external opengl32;
procedure glTexCoordPointer; external opengl32;
procedure glDrawArrays; external opengl32;

Procedure GLFinalize();
begin 
  If RC <> 0 Then                              // Существует ли Контекст Рендеринга?
  begin
    If not wglMakeCurrent(0, 0) Then // Возможно ли освободить RC и DC?
      MessageBox(0, 'Release Of DC And RC Failed.', 'SHUTDOWN ERROR', MB_OK or MB_ICONINFORMATION );
    if not wglDeleteContext(RC) Then      // Возможно ли удалить RC?
      MessageBox(0, 'Release Rendering Context Failed.', 'SHUTDOWN ERROR', MB_OK or MB_ICONINFORMATION );
    RC := 0;                         // Установить RC в NULL
  end;
end;

Function GLInitialize(Handle: HWND): Boolean;
var pfd: tagPIXELFORMATDESCRIPTOR; PixelFormat: Integer;
begin
  Result := False;

  GLFinalize();

  FillChar(pfd, SizeOf(pfd), 0);

 (*
  DC := GetDC(Handle);
  PixelFormat := GetPixelFormat(DC);

  DescribePixelFormat(DC, PixelFormat, sizeof(tagPIXELFORMATDESCRIPTOR), pfd);
  *)

  With pfd do
  begin
    nSize        := SizeOf(PIXELFORMATDESCRIPTOR);
    nVersion     := 1;
    dwFlags      := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
    iPixelType   := PFD_TYPE_RGBA;
    cColorBits   := 24;
    cDepthBits   := 32; //16
    cStencilBits := 0;
    iLayerType   := PFD_MAIN_PLANE;
  end;

    //If IsWindow(Handle) Then MessageDlg('Is Window', mtInformation, [mbOK], 0);

  DC := GetDC(Handle);
  PixelFormat := ChoosePixelFormat(DC, @pfd);

  DescribePixelFormat(DC, PixelFormat, sizeof(tagPIXELFORMATDESCRIPTOR), pfd);


  if(PixelFormat = 0) Then
  begin
    GLFinalize();
    MessageBox(0, 'Can''t Find A Suitable PixelFormat.', 'ERROR', MB_OK or MB_ICONEXCLAMATION );
  end;

  if(not SetPixelFormat(DC, PixelFormat, @pfd)) Then
  begin
    GLFinalize();
    MessageBox(0, 'Can''t Set The PixelFormat.', 'ERROR', MB_OK or MB_ICONEXCLAMATION );
  end;
                     
  DC := GetDC(Handle);
  RC := wglCreateContext(DC);
  If RC = 0 Then
  begin
    GLFinalize();
    MessageDlg('Can''t Create a GL Rendering Context.', mtError, [mbOK], 0);
  end;

  If not wglMakeCurrent(DC, RC) Then
  begin                             
    GLFinalize();
    MessageDlg('Can''t activate the GL Rendering Context.', mtError, [mbOK], 0);
  end;


  glShadeModel( GL_SMOOTH );              // Разрешить плавное цветовое сглаживание

  glClearColor(0.0, 0.0, 0.0, 0.0);   // Очистка экрана в черный цвет

  glClearDepth( 1.0 );                   // Разрешить очистку буфера глубины
  glEnable( GL_DEPTH_TEST );              // Разрешить тест глубины
  glEnable( GL_STENCIL_TEST );
  //glEnable(GL_TEXTURE_2D);
  //glEnable(GL_ALPHA_TEST);
  glDepthFunc( GL_LEQUAL );               // Тип теста глубины
  //glHint( GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST );
end;


Procedure GLResize(Rect: TRect);
var Width, Height: Integer;
begin
    Width  := Rect.Right - Rect.Left;
    Height := Rect.Bottom - Rect.Top;
    glViewport(Rect.Left, Rect.Top, Width, Height);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();

    //glOrtho(0, width, height, 0, -1, 1);
    gluOrtho2D(0, Width, Height, 0);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
end;

Function LoadTexture(Width, Height: Integer; data: Pointer; ColorType: Integer = GL_RGBA): Cardinal;
begin
  Result := 0;
  glGenTextures(1, @Result); 
  If Result = 0 Then Exit;
  glBindTexture(GL_TEXTURE_2D, Result);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, (* GL_LINEAR *) GL_NEAREST);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, (* GL_LINEAR *) GL_NEAREST);
  gluBuild2DMipmaps(GL_TEXTURE_2D, GL_RGBA, Width, Height, ColorType, GL_UNSIGNED_BYTE, data);
end;

Initialization
  RC := 0;
  DC := 0;
Finalization
  GLFinalize();
end.








