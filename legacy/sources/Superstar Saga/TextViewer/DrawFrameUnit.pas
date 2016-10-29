unit DrawFrameUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, OpenGL, OpenGLUnit, FontUnit, StdCtrls;

type
  TDrawFrame = class(TFrame)
    procedure FrameResize(Sender: TObject);
  private
    { Private declarations }
  public
    Procedure InitializeGL();
  end;

var
  WinTex:   Integer;
  MarioFont: TMarioFont;


implementation

{$R *.dfm}


//{$INCLUDE Window.inc}

procedure TDrawFrame.InitializeGL;
var pfd: tagPIXELFORMATDESCRIPTOR; nPixelFormat: Integer;
begin
//  InitializeGL();
  DC := GetDC(Handle);
  FillChar(pfd, SizeOf(pfd), 0);
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
  nPixelFormat:=ChoosePixelFormat(DC,@pfd);
  SetPixelFormat(DC,nPixelFormat,@pfd);

  RC := wglCreateContext(DC);
  wglMakeCurrent(DC, RC);

  glMatrixMode (GL_PROJECTION);
  glLoadIdentity;
  glClearColor(0.3, 0.4, 0.5, 0.0);
  glShadeModel( GL_SMOOTH );
  //glClearDepth( 1.0 );
  GLResize(Self.ClientRect);
end;

procedure TDrawFrame.FrameResize(Sender: TObject);
begin
  GLResize(Self.ClientRect);
end;

end.
