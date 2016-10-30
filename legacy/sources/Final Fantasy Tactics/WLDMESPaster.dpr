program WLDMESPaster;

{$APPTYPE CONSOLE}

uses
  SysUtils, Classes,
  FFT;


var List: TStringList; Text: String; F: File; Buf, WBuf: Pointer; B: ^Byte;
n,m,Size,ErrorCount: Integer; Msg: TMessageArray; Table: TTableArray;
begin
  If ParamCount<4 Then Exit;
  LoadOptText(ParamStr(1),ParamStr(2), Msg, True);
  LoadTable(ParamStr(3), Table);
  AssignFile(F,ParamStr(4));
  Reset(F,1);
  GetMem(Buf,FileSize(F));
  BlockRead(F, Buf^, FileSize(F));
  GetMem(WBuf, $80000);
  For n:=0 To Length(Msg)-1 do
  begin
    Text:=''; Size:=0;
    For m:=0 To Length(Msg[n].R)-1 do Text:=Text+Msg[n].R[m].Text;
    Inc(Size,PasteText(Text, Table, WBuf));
    B:=Addr(Buf^);
    Inc(B, Msg[n].Adr1);
    CopyMem(WBuf, Pointer(B), Size);
    If Size<=Msg[n].Adr2-Msg[n].Adr1+1 Then WriteLn(Format('[%d/%d] Successfully!',[n+1, Length(Msg)]))
    else
    begin
      WriteLn(Format('[%d/%d] Not enought space!',[n+1, Length(Msg)]));
      Inc(ErrorCount);
    end;
  end;
  Seek(F,0);
  BlockWrite(F, Buf^, FileSize(F));
  CloseFile(F);
  WriteLn(Format('Complete! %d errors in %d blocks.',[ErrorCount,Length(Msg)]));
  FreeMem(Buf);
  FreeMem(WBuf);
  //WriteLn('Press ENTER...');
  //ReadLn;
  { TODO -oUser -cConsole Main : Insert code here }
end.
