unit TableFont;

interface

uses
  TableText, H_Graphics, Graphics, Types, Direct3D9, D3DX9;

Type
  TCharRecord = Record
    Left:   Word;
    Width:  Word;
    Right:  Word;
  end;

  TTableFont = Class(TEngineFont)
    //constructor Create(DXDraw: TDXDraw; Table: TTable);
    FTable:     TTable;
    FCharsData: Array of TCharRecord;
    function DrawChar(X, Y: Integer; C: Char; EndSprite: Boolean = True): Integer;
  public

  end;

implementation
                              {
constructor TTableFont.Create(DXDraw: TDXDraw; Table: TTable);
begin
  inherited Create(DXDraw);
  FTable := Table;
end;                         }

Function TTableFont.DrawChar(X, Y: Integer; C: Char; EndSprite: Boolean = True): Integer;
var SrcRect: TRect; Vec: TD3DXVector3;
begin
{
  If not FInitialized Then Exit;
  If EndSprite Then FDXDraw.Sprite._Begin(D3DXSPRITE_ALPHABLEND);
  Vec := D3DXVector3(X, Y, 0);
  SrcRect := Bounds((Byte(C) and $F) * FGridX, (Byte(C) SHR $4) * FGridY, FCharsData[C].Width, FHeight);
  DXDraw.Sprite.Draw(FTexture, @SrcRect, nil, @Vec, $FFFFFFFF);
  If EndSprite Then FDXDraw.Sprite._End;
  Result := FCharsData[C].Width + FCharsData[C].Left + FCharsData[C].Right;            }
end;

end.
