unit NodeLstEx;

interface

uses SysUtils, NodeLst, Classes, TntClasses;

type
 TNodeListEx = class(TNodeList)
  public
    procedure LoadFromFile(const FileName: WideString);
    procedure SaveToFile(const FileName: WideString);
    procedure LoadFromStream(const Stream: TStream); virtual; abstract;
    procedure SaveToStream(const Stream: TStream); virtual; abstract;
 end;

implementation

procedure TNodeListEx.LoadFromFile(const FileName: WideString);
var Stream: TTntFileStream;
begin
 Stream := TTntFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
 try
  LoadFromStream(Stream);
 finally
  Stream.Free;
 end;
end;

procedure TNodeListEx.SaveToFile(const FileName: WideString);
var Stream: TTntFileStream;
begin
 Stream := TTntFileStream.Create(FileName, fmCreate);
 try
  SaveToStream(Stream);
 finally
  Stream.Free;
 end;
end;

end.
