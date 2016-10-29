unit FF8_compression;

// bcc32 -c -6 -O2 -Ve -X -pr -a8 -b -d -k- -vi -tWM -r -RT- -ff compression.c

interface

{$L compression.obj}

function lzs_compress(p_src_first: Pointer; src_len: Integer; p_dst_first: Pointer; out p_dst_len: Integer): LongBool; external;
procedure lzs_decompress(p_src_first: Pointer; src_len: Integer; p_dst_first: Pointer; out p_dst_len: Integer); external;

implementation


end.