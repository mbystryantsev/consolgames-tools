unit ViewUnit;

interface

uses TableText, FontUnit, OpenGL, OpenGLUnit, Types;

const
  cBufferSize = 1024 * 64;
  
var
  WinTex:   Integer = 0;

Type
  TTextViewer = class
    FTable: TTable;
    FMarioFont:  TMarioFont;
    FBuffer:  Array[0..cBufferSize-1] of Byte;
    FWinWidth:  Integer;
    FWinHeight: Integer;
    FWidth:     Integer;
    FHeight:    Integer;
    FSceneX:    Real;
    FSceneY:    Real;
    FScale:     Real;
    Procedure ProcessData(Data: Pointer; Len: Integer);
    Procedure DrawRect(const TexCoord: TTexCoord; const Rect: TRect);
    constructor Create;
  public
    Property Table: TTable read FTable write FTable;
    Property MarioFont: TMarioFont read FMarioFont write FMarioFont;
    Property Width:  Integer read FWidth  write FWidth;
    Property Height: Integer read FHeight write FHeight;
    Property SceneX: Real read FSceneX write FSceneX;
    Property SceneY: Real read FSceneY write FSceneY;
    Property Scale:  Real read FScale  write FScale;

    Procedure DrawText(S: PWideChar; Len: Integer); overload;
    Procedure DrawText(var S: WideString); overload;
    procedure DrawWindow(W, H: Integer);
    Procedure DrawString(var S: WideString);
  end;

  Procedure ViewerInit();

implementation
          
{$INCLUDE Window.inc}

Procedure ViewerInit();
begin
  WinTex := LoadTexture(64, 64, @WinData);
end;

{ TTextViewer }

Procedure TTextViewer.DrawRect(const TexCoord: TTexCoord; const Rect: TRect);
begin
  glBegin(GL_QUADS);
    glTexCoord2f(TexCoord[0].X, TexCoord[0].Y);
    glVertex2i(Rect.Left, Rect.Top);
    glTexCoord2f(TexCoord[1].X, TexCoord[1].Y);
    glVertex2i(Rect.Right, Rect.Top);
    glTexCoord2f(TexCoord[2].X, TexCoord[2].Y);
    glVertex2i(Rect.Right, Rect.Bottom);
    glTexCoord2f(TexCoord[3].X, TexCoord[3].Y);
    glVertex2i(Rect.Left, Rect.Bottom);
  glEnd();
end;

procedure TTextViewer.DrawWindow(W, H: Integer);
var Rect, TileRect: TRect; i: Integer;
begin

  Rect := Bounds(0, 0, 16, 16);
  TileRect := Bounds(0, 0, 8, 8);
  glMatrixMode(GL_TEXTURE);      
  glPushMatrix();
  glLoadIdentity();
  glScalef(1 / 64, 1 / 64, 1);
  glMatrixMode(GL_MODELVIEW);
  glPushMatrix();

  glDisable(GL_TEXTURE_2D);
  glRectf(8, 8, 8 + W * 8 + 16, 8 + H * 8 + 16);
  glEnable(GL_TEXTURE_2D);

  glBindTexture(GL_TEXTURE_2D, WinTex);
  DrawRect(WinCoords[0], Rect);
  glTranslatef(16, 0, 0);
  For i := 0 To W - 1 do
  begin
    DrawRect(WinCoords[4], TileRect);   
    glTranslatef(8, 0, 0);
  end;
  DrawRect(WinCoords[1], Rect);
  glTranslatef(8, 16, 0);
  For i := 0 To H - 1 do
  begin
    DrawRect(WinCoords[5], TileRect);
    glTranslatef(0, 8, 0);
  end;
  glTranslatef(-8, 0, 0);
  DrawRect(WinCoords[2], Rect);
  glTranslatef(0, 8, 0);
  For i := 0 To W - 1 do
  begin
    glTranslatef(-8, 0, 0);
    DrawRect(WinCoords[6], TileRect);
  end;
  glTranslatef(-16, -8, 0);
  DrawRect(WinCoords[3], Rect);
  For i := 0 To H - 1 do
  begin
    glTranslatef(0, -8, 0);
    DrawRect(WinCoords[7], TileRect);
  end;
  glPopMatrix();
  glMatrixMode(GL_TEXTURE);
  glPopMatrix();
  glMatrixMode(GL_MODELVIEW);
end;

procedure TTextViewer.DrawText(S: PWideChar; Len: Integer);
var P: PByte; DataLen: Integer;
begin
  If FTable = nil Then Exit;
  P := @FBuffer;
  DataLen := FTable.ExportString(P, S, Len, False, True);
  ProcessData(@FBuffer, DataLen);
end;

procedure TTextViewer.DrawText(var S: WideString);
var Str: WideString;
begin
  //Str := 'Test';
  DrawText(PWideChar(S), Length(S));
  //DrawText(PWideChar(Str), Length(Str));
end;


Type
  TTableRecordArray = Array[0..1] of PTableRecord;
  PTableRecordArray = ^TTableRecordArray;
procedure TTextViewer.ProcessData(Data: Pointer; Len: Integer);
var i, j, WX, WY: Integer; Rec: PTableRecordArray absolute Data;
begin
  glMatrixMode(GL_TEXTURE);
  glLoadIdentity();
  glScalef(1 / 256, 1 / 256, 1);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();
  glScalef(FScale, FScale, 1);  
  glTranslatef(-FSceneX, -FSceneY, 0);
  WX := 0;
  WY := 0;
  DrawWindow(FWinWidth, FWinHeight);
  //WY := FWinHeight * 8;
  glPushMatrix();



  glTranslatef(16, 8, 0);
  glEnable(GL_TEXTURE_2D);
  glBindTexture(GL_TEXTURE_2D, MarioFont.Texture);
  glPushMatrix();


  For i := 0 To (Len div 4) - 1 do
  begin
    With Rec^[i]^ do
    begin
      Case Mode of
        rtNewLine:
        begin
          glPopMatrix();
          glTranslatef(0, 16, 0);
          glPushMatrix();
        end;
        rtNewScreen:
        begin
          glPopMatrix();
            glPopMatrix();
              if (WY + 2) * (FWinHeight * 8 + 24) > FHeight Then
              begin
                Inc(WX);
                glTranslatef(FWinWidth * 8 + 32, -1 * WY * (FWinHeight * 8 + 24), 0); 
                WY := -1;
              end else
                glTranslatef(0, FWinHeight * 8 + 24, 0);
              Inc(WY);
              DrawWindow(FWinWidth, FWinHeight);
              glEnable(GL_TEXTURE_2D);
              glBindTexture(GL_TEXTURE_2D, MarioFont.Texture);
            glPushMatrix();
            glTranslatef(16, 8, 0);
          glPushMatrix();
        end;
      else
        begin
          For j := 0 To High(Indexes) do
            FMarioFont.DrawChar(Indexes[j] and $FF);
        end;
      end;
    end;
  end;
  glPopMatrix();
  glPopMatrix();
end;

procedure TTextViewer.DrawString(var S: WideString);
var SS: WideString; W, H, Code: Integer;
begin

  glEnable(GL_ALPHA_TEST);
  glAlphaFunc(GL_GREATER, 0);

  If (Length(S) >= 9) and (S[1] = '[') and (S[9] = ']') Then
  begin
    SetLength(SS, 3);
    Move(S[2], SS[1], 3 * 2);
    Val(SS, W, Code);
    Move(S[6], SS[1], 3 * 2);
    Val(SS, H, Code);
    FWinWidth  := W;
    FWinHeight := H;
    If S[10] = #10 Then
      DrawText(@S[11], Length(S) - 10)
    else
      DrawText(@S[12], Length(S) - 11);
  end else
    DrawText(@S[1], Length(S));
end;

constructor TTextViewer.Create;
begin
  FScale := 2.0;
end;

end.
 