unit ICO_GZip;

interface

uses Classes, SysUtils, sggzip, gzIO, ZUtil, gZlib, Crc, zDeflate, zInflate;

Type
  TICOGZip = Class(TGZip)
  protected
    procedure Decompress(infile: gzFile; outfile: TStream; MaxSize: Integer = 0); overload;
  public
    procedure Decompress(infile: TStream; outfile: TStream; MaxSize: Integer = 0); overload;
  end;

implementation

Type
gz_stream = record
  stream      : z_stream;
  z_err       : int;      { error code for last stream operation }
  z_eof       : boolean;  { set if end of input file }
  gzfile      : TStream; //file;     { .gz file }
  inbuf       : pBytef;   { input buffer }
  outbuf      : pBytef;   { output buffer }
  crc         : uLong;    { crc32 of uncompressed data }
  msg         : string[79];   { error message }
//  path        : string[79];   { path name for debugging only - limit 79 chars }
  transparent : boolean;  { true if input file is not a .gz file }
  mode        : char;     { 'w' or 'r' }
  startpos    : long;     { start of compressed data in file (header skipped) }

  destroystream: boolean;
end;

  gz_streamp = ^gz_stream;

const
  Z_EOF = -1;         { same value as in STDIO.H }
  Z_BUFSIZE = 16384;
  { Z_PRINTF_BUFSIZE = 4096; }


  gz_magic : array[0..1] of byte = ($1F, $8B); { gzip magic header }

  { gzip flag byte }

  ASCII_FLAG  = $01; { bit 0 set: file probably ascii text }
  HEAD_CRC    = $02; { bit 1 set: header CRC present }
  EXTRA_FIELD = $04; { bit 2 set: extra field present }
  ORIG_NAME   = $08; { bit 3 set: original file name present }
  COMMENT     = $10; { bit 4 set: file comment present }
  RESERVED    = $E0; { bits 5..7: reserved }

function get_byte (s:gz_streamp) : int;
begin
  if (s^.z_eof = true) then begin
    get_byte := Z_EOF;
    exit;
  end;
  if (s^.stream.avail_in = 0) then begin
    {$I-}
    //blockread (s^.gzfile, s^.inbuf^, Z_BUFSIZE, s^.stream.avail_in);
    s^.stream.avail_in:=s^.gzfile.Read(s^.inbuf^, Z_BUFSIZE);
    {$I+}
    if (s^.stream.avail_in = 0) then begin
      s^.z_eof := true;
      if (IOResult <> 0) then s^.z_err := Z_ERRNO;
      get_byte := Z_EOF;
      exit;
    end;
    s^.stream.next_in := s^.inbuf;
  end;
  Dec(s^.stream.avail_in);
  get_byte := s^.stream.next_in^;
  Inc(s^.stream.next_in);
end;

function getLong(s : gz_streamp) : uLong;
var
  x : packed array [0..3] of byte;
  c : int;
begin
  { x := uLong(get_byte(s));  - you can't do this with TP, no unsigned long }
  { the following assumes a little endian machine and TP }
  x[0] := Byte(get_byte(s));
  x[1] := Byte(get_byte(s));
  x[2] := Byte(get_byte(s));
  c := get_byte(s);
  x[3] := Byte(c);
  if (c = Z_EOF) then
    s^.z_err := Z_DATA_ERROR;
  GetLong := uLong(longint(x));
end;

procedure check_header (s:gz_streamp);

var

  method : int;  { method byte }
  flags  : int;  { flags byte }
  len    : uInt;
  c      : int;

begin

  { Check the gzip magic header }
  for len := 0 to 1 do begin
    c := get_byte(s);
    if (c <> gz_magic[len]) then begin
      if (len <> 0) then begin
        Inc(s^.stream.avail_in);
        Dec(s^.stream.next_in);
      end;
      if (c <> Z_EOF) then begin
        Inc(s^.stream.avail_in);
        Dec(s^.stream.next_in);
  s^.transparent := TRUE;
      end;
      if (s^.stream.avail_in <> 0) then s^.z_err := Z_OK
      else s^.z_err := Z_STREAM_END;
      exit;
    end;
  end;

  method := get_byte(s);
  flags := get_byte(s);
  if (method <> Z_DEFLATED) or ((flags and RESERVED) <> 0) then begin
    s^.z_err := Z_DATA_ERROR;
    exit;
  end;

  for len := 0 to 5 do get_byte(s); { Discard time, xflags and OS code }

  if ((flags and EXTRA_FIELD) <> 0) then begin { skip the extra field }
    len := uInt(get_byte(s));
    len := len + (uInt(get_byte(s)) shr 8);
    { len is garbage if EOF but the loop below will quit anyway }
    while (len <> 0) and (get_byte(s) <> Z_EOF) do Dec(len);
  end;

  if ((flags and ORIG_NAME) <> 0) then begin { skip the original file name }
    repeat
      c := get_byte(s);
    until (c = 0) or (c = Z_EOF);
  end;

  if ((flags and COMMENT) <> 0) then begin { skip the .gz file comment }
    repeat
      c := get_byte(s);
    until (c = 0) or (c = Z_EOF);
  end;

  if ((flags and HEAD_CRC) <> 0) then begin { skip the header crc }
    get_byte(s);
    get_byte(s);
  end;

  if (s^.z_eof = true) then
    s^.z_err := Z_DATA_ERROR
  else
    s^.z_err := Z_OK;

end;

function gzread2 (f:gzFile; buf:voidp; len:uInt; var Size: Integer) : int;
var
  s         : gz_streamp;
  start     : pBytef;
  next_out  : pBytef;
  n         : uInt;
  crclen    : uInt;
  filecrc   : uLong;
  filelen   : uLong;
  bytes     : integer;
  total_in  : uLong;
  total_out : uLong;
  e         : Boolean;
begin
  s := gz_streamp(f);
  start := pBytef(buf);

  if (s = NIL) or (s^.mode <> 'r') then begin
    result := Z_STREAM_ERROR;
    exit;
  end;

  if (s^.z_err = Z_DATA_ERROR) or (s^.z_err = Z_ERRNO) then begin
    result := -1;
    exit;
  end;

  if (s^.z_err = Z_STREAM_END) then begin
    result := 0;
    exit;
  end;

  s^.stream.next_out := pBytef(buf);
  s^.stream.avail_out := len;

  while (s^.stream.avail_out <> 0) do begin

    if (s^.transparent = true) then begin
      n := s^.stream.avail_in;
      if (n > s^.stream.avail_out) then n := s^.stream.avail_out;
      if (n > 0) then begin
        zmemcpy(s^.stream.next_out, s^.stream.next_in, n);
        inc (s^.stream.next_out, n);
        inc (s^.stream.next_in, n);
        dec (s^.stream.avail_out, n);
        dec (s^.stream.avail_in, n);
      end;
      if (s^.stream.avail_out > 0) then begin
        bytes:=s^.gzfile.Read(s^.stream.next_out^, s^.stream.avail_out);
        dec (s^.stream.avail_out, uInt(bytes));
      end;
      dec (len, s^.stream.avail_out);
      inc (s^.stream.total_in, uLong(len));
      inc (s^.stream.total_out, uLong(len));
      result := int(len);
      exit;
    end;

    if (s^.stream.avail_in = 0) and (s^.z_eof = false) then begin
      {$I-}
      s^.stream.avail_in:=s^.gzfile.Read(s^.inbuf^, Z_BUFSIZE);
      {$I+}
      if (s^.stream.avail_in = 0) then begin
        s^.z_eof := true;
  if (IOResult <> 0) then begin
    s^.z_err := Z_ERRNO;
    break;
        end;
      end;
      s^.stream.next_in := s^.inbuf;
    end;

    s^.z_err := inflate(s^.stream, Z_NO_FLUSH);

    if (s^.z_err = Z_STREAM_END) then begin
      e := True;
      crclen := 0;
      next_out := s^.stream.next_out;
      while (next_out <> start ) do begin
        dec (next_out);
        inc (crclen);
      end;

      s^.crc := crc32(s^.crc, start, crclen);
      start := s^.stream.next_out;

      filecrc := getLong (s);
      filelen := getLong (s);

      if (s^.crc <> filecrc) or (s^.stream.total_out <> filelen)
        then s^.z_err := Z_DATA_ERROR
  else begin

    check_header(s);
    if (s^.z_err = Z_OK) then begin
            total_in := s^.stream.total_in;
            total_out := s^.stream.total_out;

      inflateReset (s^.stream);
      s^.stream.total_in := total_in;
      s^.stream.total_out := total_out;
      s^.crc := crc32 (0, Z_NULL, 0);
    end;
      end;
    end;

    if (s^.z_err <> Z_OK) or (s^.z_eof = true) then break;

  end;

  crclen := 0;
  next_out := s^.stream.next_out;
  {while (next_out <> start ) do begin
    dec (next_out);
    inc (crclen);
  end;}
  crclen:=LongWord(next_out)-LongWord(start);
  Dec(next_out,crclen);
  s^.crc := crc32 (s^.crc, start, crclen);

  result := int(len - s^.stream.avail_out);
  Size:=S^.stream.total_in;
  If e Then Inc(Size);
end;




{ TICOGZip }

{$O-}
procedure TICOGZip.Decompress(infile: gzFile; outfile: TStream;
  MaxSize: Integer);
var len, total, written, err,Size,OldSize: integer;
begin
  Size:=0;
  total:=0;
  try
    while true do begin
      //OldSize:=Size;
      len:=gzread2(infile, buf, BUFLEN,Size);
      if len<0 then raise Exception.Create(gzerror(infile, err));  //HoRRoR
      total:=total+len;
      if Assigned(vOnProgress) then vOnProgress(Self, total);
      if len=0 then break;
      //blockwrite (outfile, buf, len, written);
      written:=outfile.Write(buf^, len);
      if written<>len then
        raise Exception.Create('write error');
     // s:=gz_streamp(infile);
     if (MaxSize<>0) and ((Size>=MaxSize) {or (Size=OldSize)}) Then Break;
    end; {WHILE}
  except
    on E: Exception do raise Exception.Create('Uncompress(gzFile->Stream): '+E.Message);
  end;
end;
{$O+}

procedure TICOGZip.Decompress(infile, outfile: TStream; MaxSize: Integer);
var ingzfile: gzFile;
begin
  try
    ingzfile:=gzopen(infile, 'r', false);
    if ingzfile=nil then raise Exception.Create('can''t gzopen');
    try
      Decompress (ingzfile, outfile, MaxSize); // calling lower-level function
    finally
      If MaxSize=0 Then
      begin
        if (gzclose (ingzfile) <> 0{Z_OK}) then;// raise Exception.Create('gzclose error');
      end else gzclose (ingzfile);
    end;
  except
    on E: Exception do raise Exception.Create('UnCompress(Stream->Stream): '+E.Message);
  end;
end;

end.
 