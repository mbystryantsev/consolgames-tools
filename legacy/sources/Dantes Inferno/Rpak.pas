unit Rpak;

interface

{$L rpak_lib.obj}

Type
  fProgress = Procedure(A, B: Integer); stdcall;
  pProgress = ^fProgress;

Function RDecompress(InBuf, OutBuf: Pointer): Integer; external;
Function RCompress(InBuf: Pointer; InSize: Integer; OutBuf: Pointer; progress: pProgress = nil): Integer; external;

implementation

end.
