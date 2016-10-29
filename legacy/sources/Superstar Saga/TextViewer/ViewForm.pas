unit ViewForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OpenGL, OpenGLUnit, FontUnit, ViewUnit;

type
  TFormView = class(TForm)
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormPaint(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }    
    procedure InitializeGL();

    procedure CreateParams(var Params: TCreateParams); override;
  end;

var
  FormView: TFormView;
  MarioFont: TMarioFont;
  AllowResize: Boolean = False;   
  Viewer:    TTextViewer = nil; 
  ViewFocus: Boolean = False;

implementation

{$R *.dfm}

uses TextView;


procedure TFormView.InitializeGL;
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

  ViewerInit();

  glMatrixMode (GL_PROJECTION);
  glLoadIdentity;
  glClearColor(0.3, 0.4, 0.5, 0.0);
  glShadeModel( GL_SMOOTH );
  //glClearDepth( 1.0 );
  GLResize(Self.ClientRect);
end;


procedure TFormView.FormResize(Sender: TObject);
begin
  GLResize(Self.ClientRect);
  MainForm.DrawMessage();
end;



procedure TFormView.FormDestroy(Sender: TObject);
begin
  AllowResize := False;
  MarioFont.Free;
  If WinTex <> 0 Then
    glDeleteTextures(1, @WinTex);
  GLFinalize();
end;


procedure TFormView.FormCreate(Sender: TObject);
var Stream: TFileStream;
begin
  InitializeGL();
  glEnable(GL_TEXTURE_2D);

  Stream := TFileStream.Create('fonts.mft', fmOpenRead);

  MarioFont := TMarioFont.Create;
  MarioFont.LoadFromStream(Stream);
  Stream.Free;
                                                            
  AllowResize := True;
end;

procedure TFormView.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.style := Params.style and not WS_CAPTION;
end;

var MX, MY: Integer;
  SX, SY: Real;
procedure TFormView.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  MX := X;
  MY := Y;
  SX := Viewer.SceneX;
  SY := Viewer.SceneY; 
  //Cursor := crSizeAll;
end;

procedure TFormView.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin

  ViewFocus := True;
  //MainForm.SetFocusedControl(Self);
  If not (ssLeft in Shift) Then Exit;
  Viewer.SceneX := SX + (MX - X) / Viewer.Scale;
  Viewer.SceneY := SY + (MY - Y) / Viewer.Scale;
  MainForm.DrawMessage();
end;

procedure TFormView.FormPaint(Sender: TObject);
begin
  MainForm.DrawMessage();
end;

Initialization
Finalization
end.
