unit G3PakDef;

{$MINENUMSIZE 4}

interface

uses
  Windows;

const
  G3PakFileHeaderVersion: LongWord  = $00000000;
  G3PakFileHeaderProduct: LongWord  = $30563347;  // 'G3V0'
  G3PakFileHeaderRevision: LongWord = $00000000;

type
  PG3PakEncryption = ^TG3PakEncryption;
  TG3PakEncryption = (
    G3PakEncryptionNone     = $00000000,
    G3PakEncryptionInternal = $00000001,
    G3PakEncryptionUser     = $10000000,
    G3PakEncryptionInvalid  = $7FFFFFFF
  );

type
  PG3PakCompression = ^TG3PakCompression;
  TG3PakCompression = (
    G3PakCompressionNone    = $00000000,
    G3PakCompressionAuto    = $00000001,
    G3PakCompressionZip     = $00000002,
    G3PakCompressionUser    = $10000000,
    G3PakCompressionInvalid = $7FFFFFFF
  );

type
  PG3PakReserved = ^TG3PakReserved;
  TG3PakReserved = (
    G3PakReservedNone     = $00000000,
    G3PakReserved1        = $100067F8,  // PB, CPT <= 1.5, G3PakDir <= 0.0.0.8
    G3PakReserved2        = $003263F8,  // CPT 1.6
    G3PakReservedG3PakDir = $44503347   // G3PakDir >= 0.0.0.9 ('G3PD')
  );

type
  PG3PakFileHeader = ^TG3PakFileHeader;
  TG3PakFileHeader = packed record
    Version        : LongWord;
    Product        : Array[0..3] of Char;
    Revision       : LongWord;
    Encryption     : TG3PakEncryption;
    Compression    : TG3PakCompression;
    Reserved       : TG3PakReserved;  // Alignment, usually not initialized
    OffsetToFiles  : TULargeInteger;
    OffsetToFolders: TULargeInteger;
    DataSize       : TULargeInteger;
  end;

type
  PG3PakFileAttribute = ^TG3PakFileAttribute;
  TG3PakFileAttribute = (
    G3PakFileAttributeReadOnly,    // $00000001 FILE_ATTRIBUTE_READONLY
    G3PakFileAttributeHidden,      // $00000002 FILE_ATTRIBUTE_HIDDEN
    G3PakFileAttributeSystem,      // $00000004 FILE_ATTRIBUTE_SYSTEM
    G3PakFileAttribute03,          // $00000008 FILE_ATTRIBUTE_VOLUME_LABEL
    G3PakFileAttributeDirectory,   // $00000010 FILE_ATTRIBUTE_DIRECTORY
    G3PakFileAttributeArchive,     // $00000020 FILE_ATTRIBUTE_ARCHIVE
    G3PakFileAttribute06,          // $00000040 FILE_ATTRIBUTE_DEVICE
    G3PakFileAttributeNormal,      // $00000080 FILE_ATTRIBUTE_NORMAL
    G3PakFileAttributeTemporary,   // $00000100 FILE_ATTRIBUTE_TEMPORARY
    G3PakFileAttribute09,          // $00000200 FILE_ATTRIBUTE_SPARSE_FILE
    G3PakFileAttribute10,          // $00000400 FILE_ATTRIBUTE_REPARSE_POINT
    G3PakFileAttributeCompressed,  // $00000800 FILE_ATTRIBUTE_COMPRESSED
    G3PakFileAttribute12,          // $00001000 FILE_ATTRIBUTE_OFFLINE
    G3PakFileAttribute13,          // $00002000 FILE_ATTRIBUTE_NOT_CONTENT_INDEXED
    G3PakFileAttributeEncrypted,   // $00004000 FILE_ATTRIBUTE_ENCRYPTED
    G3PakFileAttributeDeleted,     // $00008000
    G3PakFileAttributeVirtual,     // $00010000 FILE_ATTRIBUTE_VIRTUAL
    G3PakFileAttributePacked,      // $00020000
    G3PakFileAttributeStream,      // $00040000
    G3PakFileAttribute19,          // $00080000
    G3PakFileAttribute20,          // $00100000
    G3PakFileAttribute21,          // $00200000
    G3PakFileAttribute22,          // $00400000
    G3PakFileAttribute23,          // $00800000
    G3PakFileAttribute24,          // $01000000
    G3PakFileAttribute25,          // $02000000
    G3PakFileAttribute26,          // $04000000
    G3PakFileAttribute27,          // $08000000
    G3PakFileAttribute28,          // $10000000
    G3PakFileAttribute29,          // $20000000
    G3PakFileAttribute30,          // $40000000
    G3PakFileAttribute31           // $80000000
  );
const
  G3PakFileAttributeInvalid: TG3PakFileAttribute = TG3PakFileAttribute($FFFFFFFF);
type
  PG3PakFileAttributes = ^TG3PakFileAttributes;
  TG3PakFileAttributes = set of TG3PakFileAttribute;
const
  G3PakFileEmptyAttributes: TG3PakFileAttributes = [];
  G3PakFileValidAttributes: TG3PakFileAttributes = [
    G3PakFileAttributeReadOnly,
    G3PakFileAttributeHidden,
    G3PakFileAttributeSystem,
    G3PakFileAttributeDirectory,
    G3PakFileAttributeArchive,
    G3PakFileAttributeCompressed,
    G3PakFileAttributeEncrypted,
    G3PakFileAttributeDeleted,
    G3PakFileAttributePacked,
    G3PakFileAttributeStream
  ];
  G3PakFileValidSetAttributes: TG3PakFileAttributes = [
    G3PakFileAttributeReadOnly,
    G3PakFileAttributeHidden,
    G3PakFileAttributeSystem,
    G3PakFileAttributeArchive
  ];

type
//  PG3PakFileEntry = ^TG3PakFileEntry;
 // TG3PakFileEntry = record
 // end;
    // all
    TG3PakFileRecordData = packed record
      Compression    : TG3PakCompression;
      FileSizePacked : LongWord;
      FileSizeFull   : LongWord;
    end;
    TG3PakFileRecordHeader = packed record
      Created     : TFileTime;
      Accessed    : TFileTime;
      Written     : TFileTime;
      Attribs     : TG3PakFileAttributes;
      Count       : Integer;
    end;
    // files
    {
    // all
    NameLen    : LongWord;
    Name      : AnsiString;
    // files
    Comment   : AnsiString;
    // directories
    DirCount  : LongWord;
    FileCount : LongWord;
  end;                      }

implementation

end.
