unit TabConv;

interface

uses
  Windows, TableText, Classes;
  
Type

	TTabHeader = Packed Record
		Sign: 		Array[0..3] of Char;
		Version: 	Word;  // 0001 0001
    Unicode:  WordBool;
		Date: 		TFileTime;
		Count: 		Integer;
	end;
	
	TTabRecordHeader = Packed Record
		tag010100: Array[0..2] of Byte;
		NameLen:   Word;
	end;

Procedure ExtractText(Stream: TStream; Text: TGameTextSet); 
Procedure BuildText(Stream: TStream; Text: TGameTextSet; Unicode: Boolean = True);
Implementation

Procedure ExtractText(Stream: TStream; Text: TGameTextSet);
var
  Header: TTabHeader; RecHeader: TTabRecordHeader;
  n, m, Count: Integer; Len: Word;
  S: WideString;
  PS: PWideString;
  SS: String;
begin
  Stream.Read(Header, SizeOf(Header));
  For n := 0 To Header.Count - 1 do
  begin
    Stream.Read(RecHeader, SizeOf(RecHeader));
    If Header.Unicode Then
    begin
      SetLength(S, RecHeader.NameLen);
      Stream.Read(S[1], Length(S) * 2);
    end else
    begin
      SetLength(SS, RecHeader.NameLen);
      Stream.Read(SS[1], Length(SS));
      S := SS;
    end;

    Text.AddItem(S);
    Stream.Read(Count, 4);
    Text.Items[n].SetCount(Count);
    For m := 0 To Count - 1 do With Text.Items[n].Items[m] do
    begin
      Stream.Read(Len, 2);
      If Header.Unicode Then
      begin
        SetLength(Strr, Len);
        Stream.Read(Strr[1], Len * 2);
      end else
      begin   
        SetLength(SS, Len);
        Stream.Read(SS[1], Len);
        Strr := SS;
      end;
      //Text.AddString(S);
    end;
  end;
end;

Procedure BuildText(Stream: TStream; Text: TGameTextSet; Unicode: Boolean = True);
var
  Header: TTabHeader; RecHeader: TTabRecordHeader;
  n, m, Count: Integer; Len: Word;
  S: WideString; SS: String;
const
  tag010100: Array[0..2] of Byte = (1, 1, 0);
begin
  Header.Sign := 'TAB0';
  Header.Version := $0001;
  GetSystemTimeAsFileTime(Header.Date);
  Header.Count := Text.Count;
  Stream.Write(Header, SizeOf(Header));   
  For n := 0 To Header.Count - 1 do
  begin
    Stream.Write(tag010100, 3);
    S := Text.Items[n].Name;
    Len := Length(S);
    Stream.Write(Len, 2);
    If Unicode Then
      Stream.Write(S[1], Len * 2)
    else
    begin
      SS := S;
      Stream.Write(SS[1], Len);
    end;
    m := Text.Items[n].Count;
    Stream.Write(m, 4);
    For m := 0 To Text.Items[n].Count - 1 do With Text.Items[n].Items[m] do
    begin
      //Strr := ReturnCarrets(Strr);   
      Len := Length(Strr);        
      Stream.Write(Len, 2);
      If Unicode Then
        Stream.Write(Strr[1], Len * 2)
      else
      begin
        SS := Strr;
        Stream.Write(SS[1], Len);
      end;
    end;
  end;
end;
	
	
	
	
	
end.