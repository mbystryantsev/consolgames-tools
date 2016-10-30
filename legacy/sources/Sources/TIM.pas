unit TIM;

interface

Type
 DWord = LongWord;
 TTIMHeader = Packed Record
  thSignTag:    Byte; // 0x10
  thVersion:    Byte; // 0x00
  thReserved1:  Byte; // null
  thReserved2:  Byte; // null
  thFormatTag:  Byte; // BitCount and CLUT flag
  thReserved3:  Byte; // null
  thReserved4:  Byte; // null
  thReserved5:  Byte; // null
 end;

 TTIMCLUTHeader = Packed Record
  chSize:       DWord;
  chX:          Word;
  chY:          Word;
  chWidth:      Word;
  chHeight:     Word;
 end;

 TTIMImageHeader = Packed Record
   ihSize:      DWord;
   ihX:         Word;
   ihY:         Word;
   ihWidth:     Word;
   ihHeight:    Word;
 end;



implementation

end.
 