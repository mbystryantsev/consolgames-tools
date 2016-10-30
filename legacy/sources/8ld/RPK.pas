unit RPK;

interface

uses Windows;

  THeader = Packed Record
    Sign: Array[0..3] of Char;
    hz1:  Word;
    hz2:  Word;
    hz3:  DWord;
    Size: DWord;
    Name: Array[0..$9F] of Char;
  end;

  TInfoHeader = Packed Record
    hz1: Byte;
    Count: DWord;
    hz2: Word;
  end;
  
  TFileHeader = Packed Record   
    hz1:    DWord;
    Offset: DWord;
  end;
  
  TDataHeader = Packed Record
  end;

implementation



end.
 