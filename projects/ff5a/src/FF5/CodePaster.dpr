program CodePaster;

{$APPTYPE CONSOLE}

uses
  SysUtils, Windows, Classes;

{$INCLUDE CodePasterUnit.pas}

begin
  SetAlign(4);
  SetPtrSize(4);
  SetPtrDef($F8000000);
  AddSpace($36DD54, $3B6073);
  AddSpace($70AE60, $7FFFFF);

  OpenFile('Final Fantasy V.gba');
  WriteWordPos($14488C, [$D3D8, $D3D8, $D3D8]);   // 14488C - font lengths
  WriteWordPos($D24D8,  [$F31B, $FA6A]);          // bl 083ED9B0h
  WriteFilePos($3ED9B0, 'data\asm\text_out.gba');

  WriteFile('russian.msg');
  ReplacePtrs([$6342C, $72258, $D231C]);

  WriteFile('data\fonts\font1_RUS.fnt');
  ReplacePtrs([$63430, $D38EC, $D4648]);

  WriteFile('data\fonts\font2_RUS.fnt');
  ReplacePtrs([$90844, $D38F4, $D4650]);

  WriteFile('data\fonts\font3_RUS.fnt');
  ReplacePtrs([$D38E0, $D463C]);
end.
 