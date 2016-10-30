unit PlugInterface;

interface

type
 //LunaGFX types
 TChannelType = (ctRed, ctGreen, ctBlue, ctAlpha, ctDummy);

 TPixelReadFormat = (prRightToLeft, prLeftToRight);

 PChannel = ^TChannel;
 TChannel = packed record
  chType: TChannelType;
  chBitsCount: Byte;
 end;

 TGfxHead = Array[0..7] of Char;

const
 //Stream constants
 SO_Beginning = 0;
 SO_Current = 1;
 so_End = 2;
 //LunaGFX constants
 RGBQuadChannels: array[0..3] of TChannel =
 ((chType: ctBlue; chBitsCount: 8),
  (chType: ctGreen; chBitsCount: 8),
  (chType: ctRed; chBitsCount: 8),
  (chType: ctAlpha; chBitsCount: 8));

 //PropContainer constants
 //File open options
 FO_ReadOnly = 1;
 FO_OverwritePrompt = 1 shl 1;
 FO_HideReadOnly = 1 shl 2;
 FO_NoChangeDir = 1 shl 3;
 FO_ShowHelp = 1 shl 4;
 FO_NoValidate = 1 shl 5;
 FO_AllowMultiSelect = 1 shl 6;
 FO_ExtensionDifferent = 1 shl 7;
 FO_PathMustExist = 1 shl 8;
 FO_FileMustExist = 1 shl 9;
 FO_CreatePrompt = 1 shl 10;
 FO_ShareAware = 1 shl 11;
 FO_NoReadOnlyReturn = 1 shl 12;
 FO_NoTestFileCreate = 1 shl 13;
 FO_NoNetworkButton = 1 shl 14;
 FO_NoLongNames = 1 shl 15;
 FO_OldStyleDialog = 1 shl 16;
 FO_NoDereferenceLinks = 1 shl 17;
 FO_EnableIncludeNotify = 1 shl 18;
 FO_EnableSizing = 1 shl 19;
 FO_DontAddToRecent = 1 shl 20;
 FO_ForceShowHidden = 1 shl 21;

 //Error result constants
 PI_E_OK = 0;
 PI_E_STRTOINT = 1;
 PI_E_OUTOFBOUNDS = 2;
 //Property list constants
 PL_FIXEDPICK = 1;
 PL_BUFFER = 1;

type
 //Pre-definitions
 IColorFormat = interface;
 ILunaGFX = interface;
 ILunaGFXSet = interface;
 ILunaGFXList = interface;
 IPropertyListItem = interface;
 IPropertyList = interface;

 //Utils interfaces
 IRoot = interface
 ['{3BD3A27E-1973-41D0-9620-01D58310C915}']
    function GetPtr: Pointer; stdcall;
    procedure FreeObject; stdcall;
 end;

 IReadWrite = interface(IRoot)
 ['{A1FE8B5E-6B1C-41B7-9043-13EDE4AAE21C}']
 //public
    function Read(var Buffer; Count: Integer): Integer; stdcall;
    function Write(const Buffer; Count: Integer): Integer; stdcall;
 end;

 INodeList = interface(IRoot)
 ['{E768FD87-30EE-4D8F-B8FA-DF44F3351889}']
 //private
    function GetCount: Integer; stdcall;
 //public
    procedure Clear; stdcall;
 //properties
    property Count: Integer read GetCount;
 end;

 INodeListEx = interface(INodeList)
 ['{80410948-F504-4DC2-9AA0-7FA431F7D0F6}']
    procedure LoadFromStream(const Stream: IReadWrite); stdcall;
    procedure SaveToStream(const Stream: IReadWrite); stdcall;
 end;

 IStream32 = interface(IReadWrite)
 ['{9B7F6EAF-0306-4943-B687-A9FBBDA38FB5}']
 //private
    function GetPos: Integer; stdcall;
    function GetSize: Integer; stdcall;
    procedure SetPos(Value: Integer); stdcall;
    procedure SetSize(Value: Integer); stdcall;
 //public
    procedure Seek(Offset, SeekOrigin: Integer); stdcall;
    function CopyFrom(const Stream: IReadWrite;
                      Count: Integer): Integer; stdcall;
 //properties
    property Position: Integer read GetPos write SetPos;
    property Size: Integer read GetSize write SetSize;
 end;

 IStream64 = interface(IReadWrite)
 ['{737B631C-7CF5-4F7F-B902-8940E5A16B78}']
 //private
    function GetPos: Int64; stdcall;
    function GetSize: Int64; stdcall;
    procedure SetPos(const Value: Int64); stdcall;
    procedure SetSize(const Value: Int64); stdcall;
 //public
    procedure Seek(const Offset: Int64; SeekOrigin: Integer); stdcall;
    function CopyFrom(const Stream: IReadWrite;
                      const Count: Int64): Int64; stdcall;
 //properties
    property Position: Int64 read GetPos write SetPos;
    property Size: Int64 read GetSize write SetSize;
 end;

 IStrings = interface(INodeListEx)
 ['{295E6898-C6AA-4367-99D2-ED49393D2780}']
    procedure Delete(Index: Integer); stdcall;
    procedure Exchange(Index1, Index2: Integer); stdcall;
    procedure Move(CurIndex, NewIndex: Integer); stdcall;
    procedure Sort; stdcall;
    procedure AddStrings(const Strings: IStrings); stdcall;
    procedure Assign(const Source: IStrings); stdcall;
    function Equals(const Strings: IStrings): LongBool; stdcall;
 end;

 IStringList = interface(IStrings)
 ['{7D8F9D3A-7284-411F-8B2B-119364FB716A}']
 //private
    function GetString(Index: Integer): PAnsiChar; stdcall;
    procedure SetString(Index: Integer; Value: PAnsiChar); stdcall;
    function GetText: PAnsiChar; stdcall;
    procedure SetText(Value: PAnsiChar); stdcall;
 //public
    function Add(S: PAnsiChar): Integer; stdcall;
    procedure Append(S: PAnsiChar); stdcall;
    function Find(S: PAnsiChar; var Index: Integer): LongBool; stdcall;
    function IndexOf(S: PAnsiChar): Integer; stdcall;
    procedure Insert(Index: Integer; S: PAnsiChar); stdcall;
 //properties
    property Strings[Index: Integer]: PAnsiChar read GetString write SetString;
    property Text: PAnsiChar read GetText write SetText;
 end;

 IWideStringList = interface(IStrings)
 ['{63135F46-74A5-4106-99B0-B7690C911030}']
 //private
    function GetString(Index: Integer): PWideChar; stdcall;
    procedure SetString(Index: Integer; Value: PWideChar); stdcall;
    function GetText: PWideChar; stdcall;
    procedure SetText(Value: PWideChar); stdcall;
 //public
    function Add(S: PWideChar): Integer; stdcall;
    procedure Append(S: PWideChar); stdcall;
    function Find(S: PWideChar; var Index: Integer): LongBool; stdcall;
    function IndexOf(S: PWideChar): Integer; stdcall;
    procedure Insert(Index: Integer; S: PWideChar); stdcall;
 //properties
    property Strings[Index: Integer]: PWideChar read GetString write SetString;
    property Text: PWideChar read GetText write SetText;
 end;

 TCompressionLevel = (clNone, clFastest, clDefault, clMax);

 IUtilsInterface = interface
 ['{A19E5704-EBC3-4851-A76D-3BAC4F1F529E}']
 //Stream utils
   function CreateMemoryStream: IStream32; stdcall;
   function CreateFileStream(FileName: PAnsiChar;
                             Mode: Integer): IStream64; stdcall;
   function CreateFileStreamW(FileName: PWideChar;
                             Mode: Integer): IStream64; stdcall;
   function CreateZLibCompressor(Level: TCompressionLevel; const Dest: IReadWrite): IStream32; stdcall;
   function CreateZLibDecompressor(const Source:
                                   IReadWrite): IStream32; stdcall;
 //Strings utils
   function CreateStringList: IStringList; stdcall;
   function CreateWideStringList: IWideStringList; stdcall;
 //Color utils
   function CreateColorFormat(Data: PChannel; Count: Integer): IColorFormat; stdcall;
 //LunaGFX utils
   function CreateLunaGFX: ILunaGFX; stdcall;
   function CreateLunaGFXSet: ILunaGFXSet; stdcall;
   function CreateLunaGFXList: ILunaGFXList; stdcall;
 //PropertyList utils
   function CreateProperty: IPropertyListItem; stdcall;
   function CreatePropertyList: IPropertyList; stdcall;
 end;

 //LunaGFX unterfaces
 ILunaGFX = interface(IRoot)
 ['{029A83CB-20E1-461F-804A-FDBADF5966F0}']
 //private
    function GetLeft: Integer; stdcall;
    procedure SetLeft(Value: Integer); stdcall;
    function GetTop: Integer; stdcall;
    procedure SetTop(Value: Integer); stdcall;
    function GetWidth: Integer; stdcall;
    function GetHeight: Integer; stdcall;
    function GetBitCount: Integer; stdcall;
    function GetPixelReadFormat: TPixelReadFormat; stdcall;
    function GetLineSize: Integer; stdcall;
    function GetColorSize: Integer; stdcall;
    function GetImgBuf: Pointer; stdcall;
    function GetImageSize: Integer; stdcall;
    function GetInfo: Pointer; stdcall;
    function GetInfoSize: Integer; stdcall;
    function GetColorTable: Pointer; stdcall;
    function GetPaletteSize: Integer; stdcall;
    function GetColorFormat: IColorFormat; stdcall;
    function GetInfoStream: IStream32; stdcall;
    function GetColorsUsed: Integer; stdcall;
    procedure SetColorsUsed(Value: Integer); stdcall;
    procedure SetPixelReadFormat(Value: TPixelReadFormat); stdcall;
    procedure SetInfoSize(Value: Integer); stdcall;
 //public
    procedure SetColorFormat(Data: PChannel; Count: Integer); stdcall;
    procedure SetSize(Width, Height, BitCount: Integer); stdcall;
    procedure GetDIBColorTable(Dest: Pointer; Count: Integer = -1); stdcall;
 //properties
    property Left: Integer read GetLeft write SetLeft;
    property Top: Integer read GetTop write SetTop;
    property Width: Integer read GetWidth;
    property Height: Integer read GetHeight;
    property BitCount: Integer read GetBitCount;
    property ColorsUsed: Integer read GetColorsUsed write SetColorsUsed;
    property PixelReadFormat: TPixelReadFormat read GetPixelReadFormat
                                              write SetPixelReadFormat;
    property LineSize: Integer read GetLineSize;
    property ColorSize: Integer read GetColorSize;
    property ImgBuf: Pointer read GetImgBuf;
    property ImageSize: Integer read GetImageSize;
    property InfoStream: IStream32 read GetInfoStream;
    property Info: Pointer read GetInfo;
    property InfoSize: Integer read GetInfoSize write SetInfoSize;
    property ColorTable: Pointer read GetColorTable;
    property PaletteSize: Integer read GetPaletteSize;
    property ColorFormat: IColorFormat read GetColorFormat;
 end;

 IInfoList = interface(INodeListEx)
 ['{98C651BD-99DB-47F1-AEE6-78E5162CBAE2}']
 //private
    function GetInfoStream: IStream32; stdcall;
 //private
    property InfoStream: IStream32 read GetInfoStream;
 end;

 ILunaGFXSet = interface(IInfoList)
 ['{39D0AA7A-7660-410C-B26E-143A341A015B}']
 //private
    function GetName: PWideChar; stdcall;
    procedure SetName(Value: PWideChar); stdcall;    
    function GetImage(Index: Integer): ILunaGFX; stdcall;
 //public
    function AddImage: ILunaGFX; stdcall;
    procedure RemoveImage(const Image: ILunaGFX); stdcall;
 //properties
    property Name: PWideChar read GetName write SetName;
    property Images[Index: Integer]: ILunaGFX read GetImage;
 end;

 ILunaGFXList = interface(IInfoList)
 ['{369E411D-F96E-4021-94C2-367DC3885FCB}']
 //private
    function GetSet(Index: Integer): ILunaGFXSet; stdcall;
 //public
    function AddSet: ILunaGFXSet; stdcall;
    procedure RemoveSet(const ASet: ILunaGFXSet); stdcall;
 //properties
    property Sets[Index: Integer]: ILunaGFXSet read GetSet;
 end;

 //PropContainer types
 TValueType =  (vtDecimal, vtHexadecimal, vtString, vtPickString);

 IPropertyListItem = interface(IRoot)
 ['{3B54CE55-24D6-4CE2-B809-DED5519974E8}']
 //private
    function NameGet: PWideChar; stdcall;
    procedure NameSet(Value: PWideChar); stdcall;
    function ValueTypeGet: TValueType; stdcall;
    procedure ValueTypeSet(Value: TValueType); stdcall;
    function ValueStrGet: PWideChar; stdcall;
    procedure ValueStrSet(Value: PWideChar); stdcall;
    function DefValStrGet: PWideChar; stdcall;
    procedure DefValStrSet(Value: PWideChar); stdcall;
    function ValueGet: Int64; stdcall;
    procedure ValueSet(const Value: Int64); stdcall;
    function MinGet: Int64; stdcall;
    procedure MinSet(const Value: Int64); stdcall;
    function MaxGet: Int64; stdcall;
    procedure MaxSet(const Value: Int64); stdcall;
    function HexDigitsGet: Integer; stdcall;
    procedure HexDigitsSet(Value: Integer); stdcall;
    function ReadOnlyGet: LongBool; stdcall;
    procedure ReadOnlySet(Value: LongBool); stdcall;
    function ParamsGet: Integer; stdcall;
    procedure ParamsSet(Value: Integer); stdcall;
    function TagGet: Integer stdcall;
    procedure TagSet(Value: Integer); stdcall;
    function DataGet: Pointer; stdcall;
    function DataSizeGet: Integer; stdcall;
    procedure DataSizeSet(Value: Integer); stdcall;
    function GetPickListIndex: Integer; stdcall;
    procedure SetPickListIndex(Value: Integer); stdcall;
    function GetPickList: IWideStringList; stdcall;
    function SubPropsGet: IPropertyList; stdcall;
    function GetDataStream: IStream32; stdcall;    
 //public
    property Name: PWideChar read NameGet write NameSet;
    property ValueType: TValueType read ValueTypeGet write ValueTypeSet;
    property ValueStr: PWideChar read ValueStrGet write ValueStrSet;
    property DefaultStr: PWideChar read DefValStrGet write DefValStrSet;
    property Value: Int64 read ValueGet write ValueSet;
    property ValueMin: Int64 read MinGet write MinSet;
    property ValueMax: Int64 read MaxGet write MaxSet;
    property HexDigits: Integer read HexDigitsGet write HexDigitsSet;
    property ReadOnly: LongBool read ReadOnlyGet write ReadOnlySet;
    property Parameters: Integer read ParamsGet write ParamsSet;
    property Tag: Integer read TagGet write TagSet;
    property DataStream: IStream32 read GetDataStream;
    property Data: Pointer read DataGet;
    property DataSize: Integer read DataSizeGet write DataSizeSet;
    property PickListIndex: Integer read GetPickListIndex
                                   write SetPickListIndex;
    property PickList: IWideStringList read GetPickList;
    property SubProperties: IPropertyList read SubPropsGet;
 end;

 IPropertyList = interface(INodeListEx)
 ['{CF720291-343E-477E-8C6C-08556F8C0E21}']
 //private
    function PropertyGet(Index: Integer): IPropertyListItem; stdcall;
 //public
    function AddProperty: IPropertyListItem; stdcall;
    procedure RemoveProperty(const Prop: IPropertyListItem); stdcall;
    function BooleanAdd(Name: PWideChar;
                       Value: LongBool): IPropertyListItem; stdcall;
    function DecimalAdd(Name: PWideChar;
                      const Value, Min, Max: Int64): IPropertyListItem; stdcall;
    function HexadecimalAdd(Name: PWideChar;
                            const Value, Min, Max: Int64;
                            Digits: Integer): IPropertyListItem; stdcall;
    function StringAdd(Name, Value: PWideChar;
                      ReadOnly: LongBool): IPropertyListItem; stdcall;
    function PickListAdd(Name, Value, List: PWideChar;
                        Fixed: LongBool = True): IPropertyListItem; stdcall;
    function FilePickAdd(Name, FileName, Filter, DefaultExt,
     InitialDir: PWideChar; Save: LongBool = False; Options: Integer =
     FO_HideReadOnly or FO_EnableSizing): IPropertyListItem; stdcall;
    function DataAdd(Name: PWideChar): IPropertyListItem; stdcall;
 //properties
    property Properties[Index: Integer]: IPropertyListItem read PropertyGet;
 end;

 IColorFormat = interface(IRoot)
 ['{BB4319D9-632E-4D61-9C1F-E23809512AFF}']
 //private
    function GetColorSize: Integer; stdcall;
    function GetColorBits: Integer; stdcall;
    function GetUsedBits: Integer; stdcall;
    function GetIsRGBQuad: LongBool; stdcall;
 //public
    procedure ConvertTo(const DestFormat: IColorFormat; Source, Dest: Pointer; Count: Integer); stdcall;
    procedure ConvertToRGBQuad(Source, Dest: Pointer; Count: Integer); stdcall;
    procedure ConvertFromRQBQuad(Source, Dest: Pointer; Count: Integer); stdcall;
 //properties
    property ColorSize: Integer read GetColorSize;
    property ColorBits: Integer read GetColorBits;
    property UsedBits: Integer read GetUsedBits;
    property IsRGBQuad: LongBool read GetIsRGBQuad;
 end;

 TErrorMessageType = (emWarning, emError);
 TErrorMessageProc = procedure(Str: PWideChar; EMT: TErrorMessageType); stdcall;

 PExternalData = ^TExternalData;
 TExternalData = packed record
  Utils: IUtilsInterface;
  PropertyList: IPropertyList;
  GFXList: ILunaGFXList;
  ShowMessage: TErrorMessageProc;
 end;

implementation

end.
