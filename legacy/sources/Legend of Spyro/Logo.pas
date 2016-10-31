unit Logo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    file1: TEdit;
    Button1: TButton;
    File2: TEdit;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
Type
  TTile = Record
  Tile: Array[0..31] of byte;
  end;   
Type
  TTiles = Record
  Tiles: Array of TTile;
  end;
  Type
  TMap = Record
  Map: Array of Word;
  end;

procedure TForm1.Button1Click(Sender: TObject);
var F, F2: File; Siz, Fpos: Array of integer; Count, n, m: Integer;
Tiles: Array of TTile; Map: Array of Word;
TilePos, TileCount, cnt: Integer; PTile: ^TTile;
Buffer: Pointer;
begin
Cnt:=12;
TilePos:=$CA1878-32;
TileCount:=1317;
n:=0;


SetLength(Tiles, TileCount);
SetLength(Fpos, cnt);
SetLength(Siz, cnt);
Fpos[0]:=$CABEC0;
Fpos[1]:=$CABF50;
Fpos[2]:=$CABFE0;
Fpos[3]:=$CAC070;
Fpos[4]:=$CAC100;
Fpos[5]:=$CAC190;
Fpos[6]:=$CAC220;
Fpos[7]:=$CAC2B0;
Fpos[8]:=$CAC340;
Fpos[9]:=$CAC390;
Fpos[10]:=$CAC3E0;
Fpos[11]:=$CAC430;
Siz[0]:=8*8*2;//64x64;
Siz[1]:=8*8*2;//64x64;
Siz[2]:=8*8*2;//64x64;
Siz[3]:=8*8*2;//64x64;
Siz[4]:=8*8*2;//64x64;
Siz[5]:=8*8*2;//64x64;
Siz[6]:=8*8*2;//64x64;
Siz[7]:=8*8*2;//64x64;
Siz[8]:=8*4*2;//64x32;
Siz[9]:=8*4*2;//64x32;
Siz[10]:=8*4*2;//64x32;
Siz[11]:=8*4*2;//64x32;

AssignFile(F, File1.Text);
Reset(F,1);
For n:=0 to cnt-1 do
begin
For m:=0 to length(Tiles)-1 do
begin
  Seek(F, TilePos+m*32);
  BlockRead(F, Tiles[m], 32 {TileCount*32});
end;
SetLength(map, siz[n] div 2);
For m:=0 to length(map)-1 do
begin
  Seek(F, Fpos[n]+m*2);
  BlockRead(F, map[m], 2 {siz[n]} );
end;
GetMem(Buffer, siz[n]*16);
PTile:=Addr(Buffer^);
For m:=0 to length(map)-1 do
begin
  PTile^:=Tiles[map[m]];
  Inc(PTile);
end;
AssignFile(F2, File2.Text+'.'+IntToStr(n)+'.chr');
Rewrite(F2,1);
BlockWrite(F2,Buffer^,siz[n]*16);
CloseFile(F2);
end;

CloseFile(F);
FreeMem(Buffer);

end;//!!!

procedure TForm1.Button2Click(Sender: TObject);

var F, F2: File; Siz, Fpos: Array of integer; Count, n, m, l,p: Integer;
Tiles: TTiles; Map: Array of TMap;
TilePos, TileCount, cnt: Integer; PTile: ^TTile;
Buffer: Pointer;  Tile: Array of TTiles;
Flag,rFlag: Boolean;
W: ^Word; B: ^Byte;
begin
Cnt:=12;
TilePos:=$CA1878-32;
TileCount:=1317;
n:=0;


//SetLength(Tiles, TileCount);
SetLength(Fpos, cnt);
SetLength(Siz, cnt);
Fpos[0]:=$CABEC0;
Fpos[1]:=$CABF50;
Fpos[2]:=$CABFE0;
Fpos[3]:=$CAC070;
Fpos[4]:=$CAC100;
Fpos[5]:=$CAC190;
Fpos[6]:=$CAC220;
Fpos[7]:=$CAC2B0;
Fpos[8]:=$CAC340;
Fpos[9]:=$CAC390;
Fpos[10]:=$CAC3E0;
Fpos[11]:=$CAC430;
Siz[0]:=8*8*2;//64x64;
Siz[1]:=8*8*2;//64x64;
Siz[2]:=8*8*2;//64x64;
Siz[3]:=8*8*2;//64x64;
Siz[4]:=8*8*2;//64x64;
Siz[5]:=8*8*2;//64x64;
Siz[6]:=8*8*2;//64x64;
Siz[7]:=8*8*2;//64x64;
Siz[8]:=8*4*2;//64x32;
Siz[9]:=8*4*2;//64x32;
Siz[10]:=8*4*2;//64x32;
Siz[11]:=8*4*2;//64x32;
SetLength(Tile, cnt);
For n:=0 to cnt-1 do
begin
  SetLength(Tile[n].Tiles, Siz[n] div 2); 
  AssignFile(F, File2.Text+'.'+IntToStr(n)+'.chr');
  Reset(F,1);
  For m:=0 to (siz[n] div 2)-1 do
  begin
    Seek(F, m*32);
    BlockRead(F, Tile[n].Tiles[m], 32);  
  end;
  CloseFile(F);
end;
SetLength(Map, cnt);
For n:=0 to cnt-1 do
begin
  SetLength(Map[n].Map, Siz[n] div 2);
  For m:=0 to length(Map[n].Map)-1 do
  begin
    Flag:=False;
    For l:=0 to length(Tiles.Tiles)-1 do
    begin
      rFlag:=True;
      For p:=0 to 31 do
      begin
        If Tile[n].Tiles[m].Tile[p] <> Tiles.Tiles[l].Tile[p] then
        begin
          rFlag:=False;
          Break;
        end;
      end;
      If rFlag then
      begin
        Flag:=True;
        Map[n].Map[m]:=l;
        Break;
      end;
    end;
    If not flag then
    begin
      Map[n].Map[m]:=Length(Tiles.Tiles);
      SetLength(Tiles.Tiles, Length(Tiles.Tiles)+1);
      Tiles.Tiles[Length(Tiles.Tiles)-1]:=Tile[n].Tiles[m];
    end;
  end;
end;
//CloseFile(F);
AssignFile(F, File2.Text+'.tiles.chr');
Rewrite(F,1);
For n:=0 to Length(Tiles.Tiles)-1 do
begin
  Seek(F, n*32);
  BlockWrite(F,Tiles.Tiles[n],32);
end;
CloseFile(F);
AssignFile(F, File1.Text);
Reset(F,1);
GetMem(Buffer, FileSize(F));
Seek(F,0);
BlockRead(F, Buffer^, FileSize(F));
For n:=0 to cnt-1 do
begin
  B:=Addr(Buffer^);
  Inc(B, Fpos[n]);
  W:=Addr(B^);
  For m:=0 to Length(Map[n].Map)-1 do
  begin
    W^:=Map[n].Map[m];
    Inc(W);
  end;
end;
Rewrite(F,1);
Seek(F,0);
BlockWrite(F,Buffer^,16777220);
FreeMem(Buffer);
CloseFile(F);
end;//!!!

end.
