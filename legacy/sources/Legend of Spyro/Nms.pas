unit Nms;

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
Cnt:=37;
TilePos:=$A74034;
TileCount:=1317;
n:=0;


SetLength(Tiles, TileCount);
SetLength(Fpos, cnt);
SetLength(Siz, cnt);
Fpos[0]:=$A75C4C;
Fpos[1]:=$A75C9C;
Fpos[2]:=$A75CD8;
Fpos[3]:=$A75D28;
Fpos[4]:=$A75D5C;
Fpos[5]:=$A75DAC;
Fpos[6]:=$A75DE8;
Fpos[7]:=$A75E38;
Fpos[8]:=$A75E74;
Fpos[9]:=$A75EC4;
Fpos[10]:=$A75EF8;
Fpos[11]:=$A75F48;

Fpos[12]:=$A75F84;
Fpos[13]:=$A75FD4;
Fpos[14]:=$A76010;
Fpos[15]:=$A76060;
Fpos[16]:=$A7609C;
Fpos[17]:=$A760EC;

Fpos[18]:=$A76120;
Fpos[19]:=$A76170;
Fpos[20]:=$A761A4;
Fpos[21]:=$A761F4;
Fpos[22]:=$A76228;
Fpos[23]:=$A76278;

Fpos[24]:=$A762AC;
Fpos[25]:=$A762FC;
Fpos[26]:=$A76338;
Fpos[27]:=$A764C8; //!
Fpos[28]:=$A763B8;
Fpos[29]:=$A76408;

Fpos[30]:=$A76444;
Fpos[31]:=$A76494;
Fpos[32]:=$A76548;
Fpos[33]:=$A76598;
Fpos[34]:=$A765D4;
Fpos[35]:=$A76654;

Fpos[36]:=$A766D4;
//Fpos[37]:=$A76494;
//Fpos[38]:=$A76548;
//Fpos[39]:=$A76598;
//Fpos[40]:=$A765D4;
//Fpos[41]:=$A76654;


Siz[0]:=8*4*2;//64x32;
Siz[1]:=2*4*2;//16x32;
Siz[2]:=8*4*2;//64x32;
Siz[3]:=1*4*2;//8x32;
Siz[4]:=8*4*2;//64x32;
Siz[5]:=2*4*2;//16x32;
Siz[6]:=8*4*2;//64x32;
Siz[7]:=2*4*2;//16x32;
Siz[8]:=8*4*2;//64x32;
Siz[9]:=1*4*2;//8x32;
Siz[10]:=8*4*2;//64x32;
Siz[11]:=2*4*2;//16x32;

Siz[12]:=8*4*2;//64x32;
Siz[13]:=2*4*2;//16x32;
Siz[14]:=8*4*2;//64x32;
Siz[15]:=2*4*2;//16x32;
Siz[16]:=4*4*2;//64x32;
Siz[17]:=4*1*2;//64x32;

Siz[18]:=32;//2*4*2;//64x32;
Siz[19]:=8;//2*4*2;//16x32;
Siz[20]:=8*4*2;//64x32;
Siz[21]:=1*4*2;//8x32;
Siz[22]:=8*4*2;//64x32;
Siz[23]:=1*4*2;//8x32;

Siz[24]:=8*4*2;//64x32;
Siz[25]:=2*4*2;//16x32;
Siz[26]:=8*4*2;//64x32;
Siz[27]:=8*4*2;//64x32;
Siz[28]:=8*4*2;//64x32;
Siz[29]:=2*4*2;//16x32;

Siz[30]:=8*4*2;//64x32;
Siz[31]:=1*4*2;//8x32;
Siz[32]:=8*4*2;//64x32;
Siz[33]:=2*4*2;//16x32;
Siz[34]:=8*4*2;//64x32;
Siz[35]:=8*4*2;//64x32;

Siz[36]:=8;//8*4*2;//64x32;
{Siz[37]:=1*4*2;//8x32;
Siz[38]:=8*4*2;//64x32;
Siz[39]:=2*4*2;//16x32;
Siz[40]:=8*4*2;//64x32;
Siz[41]:=8*4*2;//64x32;}

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
Cnt:=37;
TilePos:=$A74034;
TileCount:=1317;
n:=0;


//SetLength(Tiles, TileCount);
SetLength(Fpos, cnt);
SetLength(Siz, cnt);
Fpos[0]:=$A75C4C;
Fpos[1]:=$A75C9C;
Fpos[2]:=$A75CD8;
Fpos[3]:=$A75D28;
Fpos[4]:=$A75D5C;
Fpos[5]:=$A75DAC;
Fpos[6]:=$A75DE8;
Fpos[7]:=$A75E38;
Fpos[8]:=$A75E74;
Fpos[9]:=$A75EC4;
Fpos[10]:=$A75EF8;
Fpos[11]:=$A75F48;

Fpos[12]:=$A75F84;
Fpos[13]:=$A75FD4;
Fpos[14]:=$A76010;
Fpos[15]:=$A76060;
Fpos[16]:=$A7609C;
Fpos[17]:=$A760EC;

Fpos[18]:=$A76120;
Fpos[19]:=$A76170;
Fpos[20]:=$A761A4;
Fpos[21]:=$A761F4;
Fpos[22]:=$A76228;
Fpos[23]:=$A76278;

Fpos[24]:=$A762AC;
Fpos[25]:=$A762FC;
Fpos[26]:=$A76338;
Fpos[27]:=$A764C8; //!
Fpos[28]:=$A763B8;
Fpos[29]:=$A76408;

Fpos[30]:=$A76444;
Fpos[31]:=$A76494;
Fpos[32]:=$A76548;
Fpos[33]:=$A76598;
Fpos[34]:=$A765D4;
Fpos[35]:=$A76654;

Fpos[36]:=$A766D4;
//Fpos[37]:=$A76494;
//Fpos[38]:=$A76548;
//Fpos[39]:=$A76598;
//Fpos[40]:=$A765D4;
//Fpos[41]:=$A76654;


Siz[0]:=8*4*2;//64x32;
Siz[1]:=2*4*2;//16x32;
Siz[2]:=8*4*2;//64x32;
Siz[3]:=1*4*2;//8x32;
Siz[4]:=8*4*2;//64x32;
Siz[5]:=2*4*2;//16x32;
Siz[6]:=8*4*2;//64x32;
Siz[7]:=2*4*2;//16x32;
Siz[8]:=8*4*2;//64x32;
Siz[9]:=1*4*2;//8x32;
Siz[10]:=8*4*2;//64x32;
Siz[11]:=2*4*2;//16x32;

Siz[12]:=8*4*2;//64x32;
Siz[13]:=2*4*2;//16x32;
Siz[14]:=8*4*2;//64x32;
Siz[15]:=2*4*2;//16x32;
Siz[16]:=4*4*2;//64x32;
Siz[17]:=4*1*2;//64x32;

Siz[18]:=32;//2*4*2;//64x32;
Siz[19]:=8;//2*4*2;//16x32;
Siz[20]:=8*4*2;//64x32;
Siz[21]:=1*4*2;//8x32;
Siz[22]:=8*4*2;//64x32;
Siz[23]:=1*4*2;//8x32;

Siz[24]:=8*4*2;//64x32;
Siz[25]:=2*4*2;//16x32;
Siz[26]:=8*4*2;//64x32;
Siz[27]:=8*4*2;//64x32;
Siz[28]:=8*4*2;//64x32;
Siz[29]:=2*4*2;//16x32;

Siz[30]:=8*4*2;//64x32;
Siz[31]:=1*4*2;//8x32;
Siz[32]:=8*4*2;//64x32;
Siz[33]:=2*4*2;//16x32;
Siz[34]:=8*4*2;//64x32;
Siz[35]:=8*4*2;//64x32;

Siz[36]:=8;//8*4*2;//64x32;
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
BlockWrite(F,Buffer^,16777216);
FreeMem(Buffer);
CloseFile(F);
end;//!!!

end.
