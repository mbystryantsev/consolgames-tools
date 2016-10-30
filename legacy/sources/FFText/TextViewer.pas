unit TextViewer;

interface

uses DIB, Graphics, Classes;

Type

  TBGType =  (bgNone, bgColor, bgImage, bgImageFill, bgImageResize);
  TBorders = (bdLeft, bdTop, bdRight, bdBottom, bdLeftTop, bdRightTop, bdRightBottom, bdLeftBottom);
  TShowBorder = Set of TBorders;
const
  bdAll: TShowBorder  = [bdLeft, bdTop, bdRight, bdBottom, bdLeftTop, bdRightTop, bdRightBottom, bdLeftBottom];

Type

  TBorderImages = Array[TBorders] of TRect;
  TBackground = Record
    BGType:        TBGType;
    BGLeft:        Integer;
    BGTop:         Integer;
    BGRight:       Integer;
    BGDown:        Integer;
    BGColor:       TColor;
    BGBrushStyle:  TBrushStyle;
    BGBrushColor:  TColor;
  end;
  TViewerWindow = Class
    constructor Create;
    destructor  Destroy;
  private
    FResizible:         Boolean;  
    FWidth:             Integer;
    FHeight:            Integer;
    FMaxWidth:          Integer;
    FMaxHeight:         Integer;
    FMinWidth:          Integer;
    FMinHeight:         Integer;
    FTransparent:       Boolean;
    FTransparentColor:  TColor;      
    FAutoRelease:       Boolean;
    FBorder:            TShowBorder;
    
    FDrawed:            Boolean;  
    FBorderImages:      TBorderImages;
    FBGImage:           TDIB;       
    FDWnd:              TDIB;
    procedure Draw; overload;
  public                                                      
    BG:            TBackground;
    Procedure Draw(DXD: TDXDraw; X, Y: Integer); overload;
    Procedure Draw(DXD: TDXDraw; X, Y: Integer; W, H: Integer); overload;
    property  Width:  Integer read FWidth  write FWidth;
    property  Height: Integer read FHeight write FHeight;
    property  Resizible: Boolean read FResizible write FResizible;
    property  BorderImages: TBorderImages read FBorderImages;
    property  Borders: TShowBorder read FBorder write FBorder;
    procedure SaveToStream(Stream: TStream);
    procedure LoadFromStream(Stream: TStream);
    property TransparentColor: TColor Read FTransparentColor write FTransparentColor;
    property Transparent: Boolean read FTransparent write FTransparent;
    property Background: TDIB read FBGImage;
    property AutoRelease: Boolean read FAutoRelease write FAutoRelease;
    //property  Background: TBackground read FBG write FBG;
  end;


  TTextViewer = Class
  private
    FDXD: TDXDraw;
    FWindow: TViewerWindow;
  public
  end;

implementation

{ TViewerWindow }

procedure TViewerWindow.Draw;

  Function Max(WW, W: Integer): Integer;
  begin
    Result := - 1;
    If W = 0 Then Exit;
    Result := (WW div W) - 1;
    If Result * W < WW Then Inc(Result);
  end;

var n, m, X, Y, W, H, WW, HH: Integer;
begin
  FDWnd.Width  := FWidth;
  FDWnd.Height := FHeight;

  FDWnd.Canvas.Brush.Color := BG.BGColor;
  FDWnd.Canvas.FillRect(FDWnd.Canvas.ClipRect);

  FDWnd.Canvas.Brush.Style := BG.BGBrushStyle;
  FDWnd.Canvas.Brush.Color := BG.BGBrushColor;
  X := BG.BGLeft;
  Y := BG.BGTop;
  W := FDWnd.Width -  BG.BGRight - BG.BGLeft;
  H := FDWnd.Height - BG.BGTop  -  BG.BGDown;
  WW := FDWnd.Width;
  HH := FDWnd.Height;
  Case BG.BGType of

    bgColor: FDWnd.Canvas.FillRect(Bounds(X, Y, W, H));
    bgImage: FDWnd.Canvas.Draw(X, Y, FBGImage);
    bgImageFill:
    begin
      For n := 0 To Max(W, FBGImage.Width) do
        For m := 0 To Max(H, FBGImage.Height) do
          FDWnd.Canvas.Draw(X + n * FBGImage.Width, Y + m * FBGImage.Height, FBGImage);
    end;
    bgImageResize:
      FDWnd.Canvas.CopyRect(Bounds(X, Y, W, H), FBGImage.Canvas,
                Bounds(0,0, FBGImage.Width, FBGImage.Height));
  end;

  For n := 0 To Integer(High(TBorders)) do
  begin
    W := FBorderImages[TBorders(n)].Width;
    H := FBorderImages[TBorders(n)].Height;
    If (TBorders(n) in FBorder) and (FBorderImages[TBorders(n)] <> nil) Then
    begin
      With FDWnd, Canvas do Case TBorders(n) of
        bdLeftTop:     Draw(0,0,FBorderImages[TBorders(n)]);
        bdRightTop:    Draw(Width - W, 0, FBorderImages[TBorders(n)]);
        bdRightBottom: Draw(Width - W, Height - H, FBorderImages[TBorders(n)]);
        bdLeftBottom:  Draw(0, Height - H, FBorderImages[TBorders(n)]);
        bdTop:         For m := 0 To Max(WW, W) do
                         Draw(m * W, 0, FBorderImages[TBorders(n)]);
        bdBottom:      For m := 0 To Max(WW, W) do
                          Draw(m * W, HH - H, FBorderImages[TBorders(n)]);
        bdLeft:        For m := 0 To Max(HH, H) do
                          Draw(0, m * H, FBorderImages[TBorders(n)]);
        bdRight:       For m := 0 To Max(HH, H) do
                          Draw(WW - W, m * H, FBorderImages[TBorders(n)]);
      end;
    end;
  end;
  FDWnd.Transparent      := FTransparent;
  FDWnd.TransparentColor := FTransparentColor;
end;

procedure TViewerWindow.Draw(DXD: TDXDraw; X, Y: Integer);
begin
  Draw(DXD, X, Y, FWidth, FHeight);
end;

constructor TViewerWindow.Create;
var n: Integer;
begin
  FDWnd := TDIB.Create;
  FDWnd.BitCount := 24;
  For n := 0 To Integer(High(TBorders)) do
    FBorderImages[TBorders(n)] := TDIB.Create;
  FBGImage := TDIB.Create;
end;

destructor TViewerWindow.Destroy;
var n: Integer;
begin
  FDWnd.Free;
  For n := 0 To Integer(High(TBorders)) do
    FBorderImages[TBorders(n)].Free; 
  FBGImage.Free;
end;

procedure TViewerWindow.Draw(DXD: TDXDraw; X, Y, W, H: Integer);
var WW, HH: Integer;
begin
  WW := FWidth;
  HH := FHeight;
  FWidth  := W;
  FHeight := H;
  With FDWnd do
  begin
    If (FResizible and ((Width <> W) or (Height <> H))) or not FDrawed Then Draw;
    If DXD = nil Then Exit;
    DXD.Surface.Canvas.Draw(X, Y, FDWnd);
    If FAutoRelease Then
    begin
      DXD.Surface.Canvas.Release;
      DXD.Flip;
    end;
  end;          
  FWidth  := WW;
  FHeight := HH;
end;

procedure TViewerWindow.LoadFromStream(Stream: TStream);
begin

end;

procedure TViewerWindow.SaveToStream(Stream: TStream);
begin

end;

end.
