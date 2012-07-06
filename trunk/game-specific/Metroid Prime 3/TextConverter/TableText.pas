unit TableText;

interface
Uses
  Windows, Classes, StrUtils, SysUtils, TntClasses, TntSysUtils;

Type
  TCharSet = Set of Char;

Function WidePosEx(const SubStr, S: WideString; Offset: Cardinal; Out StrLen: Integer): Integer;
function WidePosExRev(const SubStr, S: WideString; Offset: Cardinal = 0): Integer;
Function DeleteCarrets(const S: WideString): WideString;
Function ReturnCarrets(const S: WideString): WideString;
Function CppToString(const S: WideString): WideString;
Function StringToCpp(const S: WideString): WideString;
Function GetPart(S: String; C: TCharSet; Num: Integer; SPos: Integer = 1; EPos: Integer = 0): String; overload;
Function GetPart(S: String; C: Char; Num: Integer; SPos: Integer = 1; EPos: Integer = 0): String; overload;
Function GetPart(S, Sub: WideString; Num: Integer; SPos: Integer = 1; EPos: Integer = 0): WideString; overload;
Function ChangeEndian(V: LongWord; Size: Integer): LongWord;


const
  FONT_FLAG_INDEX = 1 SHL 24;
  FONT_FLAG_RGB   = 1;
  FONT_FLAG_RBG   = 2;
  FONT_FLAG_GRB   = 3;
  FONT_FLAG_GBR   = 4;
  FONT_FLAG_BRG   = 5;
  FONT_FLAG_BGR   = 6;
  FONT_FLAG_555   = 1 SHL 8;
  FONT_FLAG_565   = 2 SHL 8;
  FONT_FLAG_888   = 3 SHL 8;
  FONT_FLAG_8888  = 4 SHL 8;

Type

  TProgressFunc = Function(Cur, Max: Integer; S: String): Boolean;
  TErrorType = (etLog, etHint, etWarning, etError);
  TByteSet = Set of Byte;


  TByteArray = Array of Byte;
  TByteArraySet = Array of TByteArray;
  TWordArray = Array of Word;
  TTabRecType = (rtNone, rtStop, rtNewLine, rtNewScreen);
  // Тип записи таблицы кодировки:
  // Обычный, стоп-цепочка, перенос строки, новый экран -
  // последние два типа не отличаются от обычного, могут быть использованы разве что во вьювере)

      
  PTableRecord = ^TTableRecord;
  TTableRecord = Packed Record
    Strr:    WideString;	// Текстовые данные
    Data:    TByteArray;	// Цепочка байт
    Mode:    TTabRecType;	// Тип записи
    IsOp:    Boolean;		  // Является ли запись "инструкцией"
    OpID:    Integer;		  // Если да, то индекс данных инструкции (идут в отдельном массиве)
    Indexes: TWordArray;   // Индекс символа для шрифта

    NextForData:   PTableRecord;
    NextForString: PTableRecord;
    RStrLen:       Integer;
    RDataLen:      Integer;
  end;

  TCodeTable = Array of TTableRecord;
  TIntArray = Array of Integer;

  TTextMessage = Packed Record
    Strr:  WideString;			// Сам текст
    Retry: Boolean;				// Является ли стринг "ссылкой" (работа будет вестись с оригиналом, на который эта ссылка)
    RName: String;				// Если да - имя Item'а, в котором находится "оригинал"
    RID:   Integer;				// И его индекс
  end;
  TTextMessages = Array of TTextMessage;

  TTextMessageSet = Packed Record
    Name: String;
    Mess: TTextMessages;
  end;
  TCreateError = Procedure(const S: string; Level: TErrorType = etError);
  ECreateError = Class(EAbort)
  constructor Create(S: String; ErrorProc: TCreateError = nil); overload;
  constructor Create(S: String; const Args: Array of const; ErrorProc: TCreateError = nil); overload;
  end;

  TTextSet = Array of TTextMessageSet;
  TDataMode = (dmDec, dmHex, dmChar, dmEnum);

  TFontPropertyMode = (fvNone, fvColor, fvScale, fvTransparency);
  TFontProperty = Record
    Name:  Array[0..15] of Char;
    Mode:  TFontPropertyMode;
    Flags: Integer;
    Value: Integer;
  end;


  TOpcodeList = Class;

  TTable = Class
    constructor Create; overload;
    constructor Create(ErrorProc: TCreateError); overload;
    destructor  Destroy; override;
  private
    FTableFile: String;
    FByteLeft:  WideString;
    FByteRight: WideString;
    FByteLen:   Integer;
    FByteMode:  TDataMode;
    FNEData:    TByteArray;
    FPropertyList: Array of TFontProperty;

    FStringIndex: Array[Byte] of PTableRecord;
    FDataIndex:   Array[Byte] of PTableRecord;

    procedure SetCreateError(const Value: TCreateError);// virtual;
    procedure SetByteMask(const Mask: WideString);
    function  DrawByteMask(S: WideString): Boolean;
    function  GetTableElement(Index: WideString): TByteArray;
    procedure SetTableElement(Index: WideString; const Value: TByteArray);
    procedure ProcessProperty(S: String);
    procedure ProcessSearchIndexes();
  protected
    FError:     Boolean;
    FTable:     TCodeTable;
    FCreateError: TCreateError;
    FByteMask: WideString;
    FByteEMask: WideString;
    Procedure CreateError(const S: string; const Args: array of const; Level: TErrorType = etError); overload;
    Procedure CreateError(const S: string; Level: TErrorType = etError); overload;
    Procedure TrimStr(var S: WideString);
    Function  IsComment(const S: WideString): Boolean;
  public
    FOpcodeList:TOpcodeList;
    Property  ErrorProcedure: TCreateError read FCreateError write SetCreateError;
    Function  StopData(ID: Integer = 0): Integer;
    Function  LoadTable(List: TTntStringList; Append: Boolean = False):  Integer; overload;
    Function  LoadTable(FileName: String;  Append: Boolean = False): Integer; overload;
    Procedure SaveTable(List: TTntStringList; Append: Boolean = False); overload;
    Procedure SaveTable(FileName: String); overload;
    Function  GetElementString(var P: PByte; var S: WideString; var EOS: Boolean; Len: Integer = 0; const Double: TByteSet = []; Dbl: PBoolean = nil): Integer;
    Function  GetElementData(var C: PWideChar; var P: PByte; const Len: Integer; var DataLen: Integer; GetIndexes: Boolean = False): Integer;
    Function  GetElementDataFast(var C: PWideChar; var P: PByte; const Len: Integer; var DataLen: Integer; GetIndexes: Boolean = False): Integer;
    Function  ExtractString(const Buf: Pointer; var Text: WideString; Len: Integer = 0; const Double: TByteSet = []): Integer;
    Function  ExportString(var P: PByte; Text: WideString; AutoStop: Boolean = False; GetIndexes: Boolean = False): Integer; overload;
    Function  ExportString(var P: PByte; C: PWideChar; Len: Integer; AutoStop: Boolean = False; GetIndexes: Boolean = False): Integer; overload;
    Function  IsByte(C: PWideChar; var B: Byte; var Len: Integer): Boolean;
    Property  ByteMask: WideString read FByteMask write SetByteMask;
    Property  TableElement[Index: WideString]: TByteArray read GetTableElement write SetTableElement;
    Property  NEData: TByteArray read FNEData write FNEData;
    Procedure ClearTable;
    Function TableCount: Integer;
    Property TableData: TCodeTable read FTable;
    
    Procedure AddProperty(Name: String; Mode: TFontPropertyMode; Value: Integer; Flags: Integer = 0);
  end;

  TGameTextSet = Class;
  TGameText = Class
  private
    FHidden:      Boolean;			// Для GUI, флаг невидимости элемента (пользовательский)
    FChecked:     Boolean;			// Для GUI, флаг того, что элемент обработан (пользовательский)
    FParent:      TGameTextSet;		// Родительский класс (если есть)
    FIndex:       Integer;			// Индекс как Item'а в родительском классе
    FName:        String; 			// Имя элемента
    FCaption:     WideString;		// Заголовок
    FUserInfo:    WideString;		// Пользовательские данные (не могут содержать строку конца заголовка)
    FStrings:     TTextMessages;	// Массив стрингов
    FCreateError: TCreateError;
    Function  GetString(ID: Integer): WideString;
    procedure SetString(Index: Integer; const Value: WideString);
    procedure SetName(const Value: String);
    Function  GetCount: Integer;
    Function  GetRetry(Index: Integer): Boolean;

  public
    Procedure Cut(ID: Integer);										// Удалить все строки, начиная с ID
    Property  Count: Integer read GetCount;
    Procedure SetCount(ACount: Integer);
    Property  Retry[Index: Integer]: Boolean read GetRetry;			// Является ли строка лишь ссылкой
    Procedure LoadText(FileName: String;  Appned: Boolean = False);
    Function  AddString(Table: TTable; const Buf: Pointer; Len: Integer = 0; const Double: TByteSet = []): Integer; overload;	
	Procedure AddString(S: WideString); overload;
    Property  Strings[Index: Integer]: WideString read GetString write SetString;
    Property  DirectLinkToItems: TTextMessages read FStrings;
    Property  Items: TTextMessages read FStrings write FStrings;
    Property  Name: String read FName write SetName;
    Function  TextSize: Integer;
    Property  Parent: TGameTextSet read FParent write FParent;
    Function StrLength(Index: Integer): Integer;
    Property Hidden: Boolean read FHidden write FHidden;
    Property Checked: Boolean read FChecked write FChecked;
    Property UserData: WideString read FUserInfo write FUserInfo;
    Procedure Unlink(Index: Integer);
    Property  Caption: WideString read FCaption write FCaption;
    //function  Next
  end;
  TGameTextArray = Array of TGameText;

  TGameTextSet = Class(TTable)
  Constructor Create; overload;
  constructor Create(ErrorProc: TCreateError); overload;
  protected
    FName:    String;
    FItems: TGameTextArray;

	// Структурные элементы текстового файла
    FItemPre: WideString;	// Префикс заголовка Item'а (по умолчанию "[@")
    FItemPos: WideString;	// Постфикс заголовка Item'а (по умолчанию "]")
    FInfoDel: WideString;	// Разделитель данных в заголовке Item'а (по умолчанию ",")
   // FItemDel: WideString;
    FStrEnd:  WideString;	// Конец строки (по умолчанию "\n{E}")
    FStrDel:  WideString;	// Разделитель строк (по умолчанию "\n\n", идёт после заголовка Item'а и между строками)

    FDelCarrets:  Boolean;	// НАСТОЯТЕЛЬНО не рекомендуется менять эту опцию на False, отвечает за приведение символов переноса к единому виду
    Procedure LoadItem(const S: WideString; var P: Integer; const Num: Integer; Optimized: Boolean = False);
  public
    Procedure Clear;
    Property  Name: String read FName write FName;
    function  LastParent(ID: Integer): Integer;
    function  NextParent(ID: Integer; Cur: Integer = -1): Integer;
    Procedure SetCreateError(ErrorProc: TCreateError);
    function  AddString(ID: Integer; P: PByte; Len: Integer = 0; const Double: TByteSet = []): Integer; overload;
    // Добавляет стринг в Item с индексом ID, вынимая текст по указателю P,
	// Len - максимальная длина буфера (если не встретится стоп-байт, то дальше не пойдёт), если 0 - неограниченно.
	// Double - множество байт, которые должны выниматься в месте со следующим байтом, если не найдены в таблице
	// Пример: Цепочка байт AABBCC, AA=a, CC=c, BB нет в таблице и он означает инструкцию, где CC = параметр,
	// тогда вынется так: "a{BB}{CC}", вместо a{BB}c, если BB есть в множестве
	
	Procedure AddString(ID: Integer; S: WideString); overload; // Добавить строку в Item с индексом ID
    function  AddString(P: PByte; Len: Integer = 0; const Double: TByteSet = []): Integer; overload;
	// Вынуть строку из буфера в последний Item
    Procedure AddString(S: WideString); overload; // Добавить строку в последний Item
    Function AddItem(const Name: String = ''; const UserData: String = '';
              const Hidden: Boolean = False; const Caption: WideString = ''): TGameText; // Добавить Item
    procedure UnLink(ItemIndex, Index: Integer);	// Сделать ссылку самостоятельным "стрингом"
    procedure SetLink(ItemIndex, Index: Integer; LName: String; LIndex: Integer);	// Сделать стринг ссылкой
    Function  FindItem(LName: String): Integer;		// Узнать индекс Item'а по имени
    Function  GetLinkedText(LName: String; LIndex: Integer): WideString;  // Получить текст по информации ссылки
    Function  TextSize: Integer;
    Function  NamesSize: Integer;
    Function  Count: Integer;
    Function  VisibleCount: Integer;
    Function  StringsCount: Integer;
    Property  Items: TGameTextArray read FItems;
    Procedure OptimizeText(Progress: TProgressFunc = NIL);
    procedure LoadTextFromFile(FileName: String; Optimized: Boolean = False);
    procedure LoadTextFromList(List: TTntStringList; Optimized: Boolean = False);
    procedure LoadTextFromString(S: WideString; Optimized: Boolean = False);
    Procedure SaveTextToFile(Name: String);
    Procedure SaveTextToList(List: TTntStringList);
    Function  SaveTextToString: WideString;
    Procedure CalculateIndexes;
	
	// В данных об оптимизации хранится информация, какие строки являются ссылками.
	// Такие строки не занесены в сам текстовый файл, а данные об оптимизации хранятся в отдельном файле.
	// Если текст был оптимизирован, то сперва надо загрузить данные об оптимизации, а затем сам текст.
    // НЕ СТОИТ ИСПОЛЬЗОВАТЬ ОПТИМИЗАЦИЮ, ЕСЛИ НА ТО НЕТ ЯВНОЙ НУЖДЫ, т.к. если есть одинаковые строки,
	// они могут быть использованы в разных местах, и, как следствие, могут нести разный смысл, в
	// зависимости от контекста.
	procedure LoadOptimDataFromFile(FileName: String);
    procedure LoadOptimDataFromList(List: TStringList);
    procedure LoadOptimDataFromString(const S: WideString);
    Procedure SaveOptimDataToList(List: TStringList; Append: Boolean = False);
    function  SaveOptimDataToString: String;
    procedure SaveOptimDataToFile(FileName: String);
    function  CkeckDelimeters: Boolean;
    Function  Strings(ItemIndex, Index: Integer): WideString;
	// Возвращает строку по индексу Item'а и строки.
	// Работает медленнее, чем взятие напрямую через Item.
	
    Procedure DelinkChildrens(Name: String; ID: Integer);
    Procedure DelinkChildrensOfBlock(ItemIndex, ID1, ID2: Integer);
    Procedure SetString(ItemIndex, Index: Integer; S: WideString);
    Function  Optimized: Boolean;	// Оптимизирован ли текст
    Procedure SetLinkedText(LName: String; LIndex: Integer; S: WideString);
    property  DelCarrets: Boolean read FDelCarrets write FDelCarrets;
    Property SepStrEnd: WideString Read FStrEnd Write FStrEnd;
    procedure RemoveItem(Index: Integer);  overload;
    procedure RemoveItem(Item: TGameText); overload;
  end;



  TEnumRecord = Record
    Str:   WideString;
    Index: Integer;
  end;
  TEnum = Array of TEnumRecord;
  TOpcodeValue = Record		
    Mask:    TByteArray;	// Битовая маска значения, по которой оно будет выниматься.
							// Биты, по позициям которых единицы, сольются вместе и образуют значение.
							// Например, значение FF по маске 81 будет 3, т.к. первый и последний бит сольются в 11b.
    Pre:     WideString;	// Начало стринга до первой 
    ValType: TDataMode;		// Тип переменной Dec, Hex, Char или Enum
    Len:     Integer;		// Длина в байтах
    Enum:    TEnum;			// Если перечисление, то есть и массив-перечисление
    ValueIndex: Integer; // Индекс значения (для отображения текста)
  end;
  TEnumArray = Array of TEnum;
  TOpcodeRecord = Record	// Структура "инструкции"
    Mask:   TByteArray;		// Маска сравнения. Цепочка байт AND маска = Value.
    Data:   TByteArray;		// Данные. Если Value = Data, тогда это наша инструкция.
    Big:    Boolean;			// BigEndian
    Fmt:    WideString;		// Форматная строка
    Values: Array of TOpcodeValue;	// Набор переменных в "инструкции"
    Footer: WideString;		// Постфикс строки инструкции
    Spaces: WideString;		// "Пробельные" символы, которые не влияют на идентификацию инструкции при парсинге
							// Например, если равно "/ ", то <val=2> и <val = 2/> будет эквивалентно.
  end;
  
  // "Инструкцию" можно объявить двумя способами - быстрой маской и полным.
  // Пример быстрой маски: AB??=%d. Он эквивалентен FF00?AB00:00FF=%d и расшифровывается как:
  // Если два_байта AND FF00 равны AB00, то мы берём значение = два_байта AND 00FF и записываем как Dec.
  
  TOpcodeList = Class
  private
//    FCreateError: TCreateError;
    FParent: TTable;
  public
    FOpcodes: Array of TOpcodeRecord;
    Function  GetByteAsMask(var V: Integer; B, M: Byte; Num: Integer): Integer;
    Function  SetByteAsMask(V: Integer; var B: Byte; M: Byte; Num: Integer): Integer;
    Procedure ExtractValue(var V: Integer; P: PByte; M: TByteArray; BigEndian: Boolean = False);
    Function  DrawFormat(S: WideString; var Opcode: TOpcodeRecord): Boolean;
    Procedure Add(Mask: TByteArray; ValMasks: TByteArraySet; Fmt: WideString);
    Function  OpcodeLen(Index: Integer): Integer;
    Function  CheckMask(Index: Integer; P: PByte; Len: Integer = 0): Boolean;
    Function  GetString(Index: Integer; P: PByte{; BigEndian: Boolean = False}): WideString;
    Function  GetEnumElement(Enum: TEnum; Index: Integer): WideString;
    Function  GetEnumIndex(Enum: TEnum; S: PWideChar; var Len: Integer): Integer;
    Procedure Clear;
    Function  Count: Integer;
    Function  GetData(Index: Integer; var D: TByteArray; S: PWideChar; Len: Integer): Integer;
    Function  GetValues(Index: Integer; var I: TIntArray; S: PWideChar; var L: Integer): Integer;
  end;


  TLexemType = (
    ltUnknown, ltVoid, ltStringEnd, ltIdentifier, ltIdentifierOrHex, ltHex, ltValue,
    ltCode, ltCodeWithMask, ltMaskCheck, ltMaskCheckEnd, ltMask, ltSeparator, ltEq, ltTextData, ltComment,
    ltPropOpen, ltPropClose, ltPropName, ltScopeOpen, ltScopeClose, ltPropValue,
    ltDirective, ltDirectiveName, ltDirectiveParam
  );
  // ltCode[WithMask] [ltPropOpen ltPropClose] ltEq ltTextData
  //
  TLexem = Record
    Data: PWideChar;
    Len:  Integer;
    Lex:  TLexemType;
  end;
  TLexer = class
    FLexems: Array[Byte] of TLexem;
    FCount:  Integer;
    Function DetectType(S: PWideChar; var Len: Integer): TLexemType;
  public
    Function ParseString(const S: WideString): Integer;
  end;

var
  Lexer: TLexer;

implementation

const
  cChar: Array[TDataMode] of Char = ('d', 'x', 's', 's');

{ ETableError }

constructor ECreateError.Create(S: String; ErrorProc: TCreateError = nil);
begin
  If @ErrorProc<>nil Then ErrorProc(S);
end;

constructor ECreateError.Create(S: String; const Args: array of const;
  ErrorProc: TCreateError);
begin
  If @ErrorProc<>nil Then ErrorProc(Format(S,Args));
end;

Function RoundBy(Value, R: Integer): Integer;
begin
 Result := Value;
 If Result mod R > 0 then Result := (Result div R) * R + R;
end;

procedure TTable.CreateError(const S: string; const Args: array of const; Level: TErrorType = etError);
begin
  If @FCreateError <> nil Then FCreateError(Format(S,Args), Level);
end;

procedure TTable.CreateError(const S: string; Level: TErrorType = etError);
begin
  If @FCreateError <> nil Then FCreateError(S);
  FError := True;
end;

Function TTable.ExtractString(const Buf: Pointer; var Text: WideString; Len: Integer = 0; const Double: TByteSet = []): Integer;
var P: PByte; Stop: Boolean; Dbl: Boolean;
begin
  If Length(FTable)<=0 Then
    raise ECreateError.Create('TGameText.ImportText: Table does not loaded!', FCreateError);
  P:=Buf;
  Result:=0;
  Stop := False;
  Dbl  := False;
  While not Stop and ((Len=0) or (Result<Len)) do
    Inc(Result, GetElementString(P, Text, Stop, Len - Result, Double, @Dbl));
end;

function TTable.GetElementString(var P: PByte; var S: WideString; var EOS: Boolean; Len: Integer = 0; const Double: TByteSet = []; Dbl: PBoolean = nil): Integer;
var m,L: Integer;
begin
  If Len < 0 Then Len := 0;
  For m:=0 To High(FTable) do With FTable[m] do
  begin
    //If ((Dbl=nil) or not Dbl^) and (P^ = Data[0]) Then
    //begin
      If IsOp Then
      begin
        If FOpcodeList.CheckMask(OpID, P) and ((Dbl=nil) or not Dbl^) and ((Len = 0) or (FOpcodeList.OpcodeLen(OpID) <= Len)) Then
        begin
          Result := FOpcodeList.OpcodeLen(OpID);
          S := S + FOpcodeList.GetString(OpID, P);
          Inc(P, Result);
          EOS := False;
          Exit;
        end;
      end
      else
      begin
        L := Length(Data);
        If (L > 0) and ((Dbl=nil) or not Dbl^) and (P^ = Data[0])
        and CompareMem(P, @Data[0], L) and ((Len = 0) or (Len >= L)) Then
        begin
          {If Strr<>#0 Then} S := S + Strr;
          Result := L;
          Inc(P, Result);
          EOS := Mode = rtStop;
          Exit;
        end;
      end;
    //end;
  end;
  S := S + WideFormat(FByteEMask, [P^]);
  If Dbl<>nil Then
  begin
    Case Dbl^ of
      False: If P^ in Double Then Dbl^ := True;
      True:  Dbl^ := False;
    end;
  end;
  Inc(P);
  Result := 1;
end;

Function TTable.LoadTable(FileName: String; Append: Boolean = False): Integer;
var List: TTntStringList; FName: String;
begin
  If not FileExists(FileName) Then
    raise ECreateError.Create('File does not exist: %s',[FileName], @FCreateError);
  FName := FTableFile;
  FTableFile := ExpandFileName(FileName);
  List:=TTntStringList.Create;
  List.LoadFromFile(FileName);


  LoadTable(List, Append);
  If Append Then FTableFile := FName;
  List.Free;
  Result := 0;
end;

Function TTable.LoadTable(List: TTntStringList; Append: Boolean = False): Integer;
var
  n, P, Cur: Integer; S, SS, Str: WideString; Fmt: Boolean; _endian, BigEndian: Boolean;
  //CharsIndexes: TWordArray;
  bCharIndex, bSetIndex: Boolean; CISize, CIStride: Integer;
  CILeft, CIBigEndian: Boolean; CIAnd: LongWord; CIAdd, CIShr: Integer;
Type TDirectiveType = (dtNone, dtInclude, dtFormat, dtNormal, dtEndian, dtProperty, dtCharIndex, dtSetIndex);
     TLineMode = (lnNormal, lnMiniOpcode, lnOpcode);
var  Mode: TLineMode; DT: TDirectiveType;
const
  cStr: Array[TDirectiveType] of WideString = ('', 'include', 'format', 'normal', 'endian', 'propery', 'charindex', 'setindex');
  Function CheckStr: Boolean;
  var Q, n: Integer; Col: Boolean;
  begin
    Result := False;
    Q := 0;
    Col := False;
    For n := 1 To P - 1 do If not (Char(S[n]) in ['0'..'9', 'a'..'f', 'A'..'F']) Then
    begin
      If (Char(S[n]) in ['!','^','~']) and (n = P - 1) Then Break;
      If (Mode in [lnOpcode, lnMiniOpcode]) and (n = P - 1) and (Char(S[n]) in ['<','>']) Then
        break;
      If Char(S[n]) in ['?',':',','] Then
      begin
        If (S[n] = '?') and not Col Then
        begin
          Mode := lnMiniOpcode;
          Inc(Q);
        end
        else If (S[n] = ':') and (Mode = lnMiniOpcode) and (Q = 1) and not Col Then
        begin
          Mode := lnOpcode;
          Col := True;
        end
        else If (S[n] = ',') and (Q = 1) and Col Then
          Continue  
        else Exit;
      end else
      Exit;
    end;
    Result := True;
  end;
  Function GetVal(WC: WideChar): Byte;
  var S: String; C: Char;
  begin
    S := WC;
    C := S[1];
    Case C of
      '0'..'9': Result := Ord(C) - Ord('0');
      'a'..'f': Result := Ord(C) - Ord('a') + 10;
      'A'..'F': Result := Ord(C) - Ord('A') + 10;
      else
        Result := 0;
    end;
  end;     
  Procedure GetDataArray(var Data: TByteArray; S: PWideChar; Len: Integer);
  var n: Integer;
  begin
    SetLength(Data, Len);
    For n := 0 To Len - 1 do
      Data[n] := (GetVal(S[n*2]) SHL 4) + GetVal(S[n*2+1]);
  end;
  Procedure GetData;
  var n, Q, C, Index: Integer;
  begin
    Case Mode of
      lnNormal:
      begin
        GetDataArray(FTable[Cur].Data, PWideChar(S), (P - 1) div 2);
        FTable[Cur].RDataLen := Length(FTable[Cur].Data);
        FTable[Cur].RStrLen  := Length(FTable[Cur].Strr);
      end;
      {begin
        SetLength(FTable[Cur].Data, (P - 1) div 2);
        For n := 0 To (P-2) div 2 do With FTable[Cur] do
          Data[n] := (GetVal(S[n*2+1]) SHL 4) + GetVal(S[n*2+2]);
      end;}
      lnMiniOpcode:
      begin
        Index := FOpcodeList.Count;
        SetLength(FOpcodeList.FOpcodes, Index + 1);
        With FOpcodeList.FOpcodes[Index] do
        begin
          SetLength(Mask, P div 2);
          SetLength(Data, P div 2);
          SetLength(Values, 1);
          SetLength(Values[0].Mask, P div 2);
          For n := 0 To (P div 2) - 1 do
          begin
            Mask[n] := 0;              
            Data[n] := 0;
            Values[0].Mask[n] := 0;
            If S[n*2+1] = '?' Then
              Values[0].Mask[n] := $F0
            else
            begin
              Mask[n] := $F0;
              Data[n] := GetVal(S[n*2+1]) SHL 4;
            end;           
            If S[n*2+2] = '?' Then
              Values[0].Mask[n] := Values[0].Mask[n] or $0F
            else
            begin
              Mask[n] := Mask[n] or $0F;
              Data[n] := Data[n] or GetVal(S[n*2+2]);
            end;
          end;
          FTable[Cur].IsOp := True;
          FTable[Cur].OpID := Index;
        end;
      end;
      lnOpcode:
      begin
        Q := Pos('?', S);
        C := Pos(':', S); 
        Index := FOpcodeList.Count;
        SetLength(FOpcodeList.FOpcodes, Index + 1);
        With FOpcodeList.FOpcodes[Index] do
        begin
          GetDataArray(Mask, PWideChar(S), (Q - 1) div 2);
          GetDataArray(Data, @S[Q+1], (C - Q - 1) div 2);
          n := 0;
          Inc(C);
          While True do
          begin
            Q := PosEx(',', S, C);
            If (Q > P) or (Q = 0) Then Q := P;
            If C >= Q Then break;
            SetLength(Values, n + 1);
            GetDataArray(Values[n].Mask, @S[C], (Q - C) div 2);
            C := Q + 1;
            Inc(n);
          end;
        end;
        FTable[Cur].IsOp := True;
        FTable[Cur].OpID := Index;
      end;
    end;
  end;
  Function DirectiveType(S: WideString): TDirectiveType;
  var n: Integer;
  begin
    For n:=1 To Length(S) do If S[n]<=#32 Then break;
    If n <= Length(S) Then SetLength(S, n - 1);
    TrimStr(S);
    For Result := Low(TDirectiveType) To High(TDirectiveType) do
      If '.' + cStr[Result] = S Then Exit; // Дебильно, но по-другому лень(
    Result := dtNone;
  end;
  Procedure GetIndexes();
  var n, Index, Size, Step, Value: Integer;
  begin
    Size := Length(FTable[Cur].Data);
    If Size < CISize + CIStride Then Exit;
    Step := CISize + CIStride;
    If CILeft Then
    begin
      Index := Size - CISize;
      Step := -Step;
    end else
      Index := 0;
    SetLength(FTable[Cur].Indexes, Size div (CISize + CIStride));
    For n := 0 To (Size div (CISize + CIStride)) - 1 do
    begin
      Case CISize of
        1: Value := FTable[Cur].Data[Index];
        2: Value := Word((@FTable[Cur].Data[Index])^);
        3: Value := LongWord((@FTable[Cur].Data[Index])^) and $FFFFFF;
        4: Value := LongWord((@FTable[Cur].Data[Index])^);
        else // Error
          Value := 0;
      end;
      If CIBigEndian Then
        Value := ChangeEndian(Value, CISize);
      If CIShr < 0 Then
        FTable[Cur].Indexes[n] := ((Value and CIAnd) shl -CIShr) + CIAdd
      else
        FTable[Cur].Indexes[n] := ((Value and CIAnd) shr  CIShr) + CIAdd;
      Inc(Index, Step);
    end;
  end;

  Procedure ProcessCharIndexDirective(S: String);
  var Param: String; Code, V: Integer;
  begin
    Param := GetPart(S, ' ', 2);
    If Param = 'on' Then
      bCharIndex := True
    else If Param = 'off' Then
      bCharIndex := False
    else If Param = 'left' Then
      CILeft := True
    else If Param = 'right' Then
      CILeft := False
    else if Param = 'bigendian' Then
      CIBigEndian := True
    else if Param = 'littleendian' Then
      CIBigEndian := False
    else If Param = 'and' Then
    begin
      Param := GetPart(S, ' ', 3);
      Val(Param, V, Code);
      If Code <> 0 Then
        raise ECreateError.Create('.charindex and: Invalid value: %s', [Param]);
      CIAnd := V;
    end else If Param = 'add' Then
    begin        
      Param := GetPart(S, ' ', 3);
      Val(Param, V, Code);
      If Code <> 0 Then
        raise ECreateError.Create('.charindex add: Invalid value: %s', [Param]);
      CIAdd := V;
    end else If Param = 'shr' Then
    begin
      Param := GetPart(S, ' ', 3);
      Val(Param, V, Code);
      If Code <> 0 Then
        raise ECreateError.Create('.charindex add: Invalid value: %s', [Param]); 
      If V > 32 Then V := 32;
      If V < -32 Then V := -32;
      CIShr := V;
    end else If Param = 'size' Then
    begin        
      Param := GetPart(S, ' ', 3);
      Val(Param, V, Code);
      If Code <> 0 Then
        raise ECreateError.Create('.charindex size: Invalid value: %s', [Param]);
      If V > 4 Then V := 4;
      If V < 1 Then V := 1;
      CISize := V;
    end else If Param = 'stride' Then
    begin        
      Param := GetPart(S, ' ', 3);
      Val(Param, V, Code);
      If Code <> 0 Then
        raise ECreateError.Create('.charindex stride: Invalid value: %s', [Param]);
      CIStride := V;
    end else
      CreateError('Error! Invalid .charindex property: %s!', [Param]);
  end;
begin
  If List = nil Then
    ECreateError.Create('TGameText.LoadTable: List does not assigned!', FCreateError);

  bCharIndex := False;
  //bSetIndex  := False;
  CISize := 1;
  CIStride := 0;
  CILeft := False;
  CIBigEndian := False;
  CIAnd := $FFFFFFFF;
  CIAdd := 0;
  CIShr := 0;

  If not Append Then ClearTable;//Finalize(FTable);
  Fmt := False;
  _endian := False;
  For n:=0 To List.Count-1 do
  begin
    Cur := Length(FTable);
    //S := CppToString(List.Strings[n]);
    S := List.Strings[n];
    If (S = '') or IsComment(S) Then Continue;
    If S[1] = '.' Then
    begin
      DT := DirectiveType(S);
      SetLength(SS, Length(S) - Length(cStr[DT]) - 2);
      Move(S[Length(cStr[DT]) + 3], SS[1], Length(SS)*2);
      TrimStr(SS);
      Case DT of
        dtInclude:
          If FTableFile = '' Then
            LoadTable(SS, True)
          else
            LoadTable(ExtractFilePath(FTableFile)
              + ExtractRelativePath(ExtractFilePath(FTableFile),  SS), True);
        dtFormat: Fmt := True;
        dtNormal: Fmt := False;
        dtEndian: If SS = 'big' Then _endian := True
                  else If SS = 'little' Then _endian := False
                  else CreateError('Invalid endian type: %d', [SS]);
        dtCharIndex: ProcessCharIndexDirective(S);
        else
          Continue;
      end;
    end else
    begin
      Mode := lnNormal;
      BigEndian := _endian;
      P := Pos('=', S);
      If (P<=2) {or ((P and 1 = P) and )} {or (P=Length(S))} or not CheckStr Then
      begin
        CreateError('TGameText.LoadTable: Invalid table line: %s', [S], etWarning);
        Continue;
      end;
      SetLength(FTable, Cur + 1);
      With FTable[Cur] do Case S[P-1] of
        '!': Mode := rtStop;
        '^': Mode := rtNewLine;
        '~': Mode := rtNewScreen;
        '+': BigEndian := True;
        '-': BigEndian := False;
      end;
      GetData;
      SetLength(Str, Length(S) - P);
      Move(S[P+1], Str[1], Length(Str) * 2);
      If Fmt Then Str := CppToString(Str);
      Case Mode of
        lnNormal: FTable[Cur].Strr := Str;
        else
        begin
          FOpcodeList.DrawFormat(Str, FOpcodeList.FOpcodes[FTable[Cur].OpID]);
          FOpcodeList.FOpcodes[FTable[Cur].OpID].Big := BigEndian;
        end;
      end;

      If bCharIndex Then GetIndexes;
      //Inc(Cur);
    end;
  end;
  Result := Cur;

  //ProcessSearchIndexes();

end;

Procedure TGameTextSet.SaveOptimDataToList(List: TStringList; Append: Boolean = False);
var n,m: Integer;
begin
  If List = nil Then
    ECreateError.Create('TGameText.SaveOptimDataToList: List does not assigned!', FCreateError);

  If not Append Then List.Clear;
  For n:=0 To High(FItems) do
  begin
    List.Add(Format('[@%s,%d]',[FItems[n].Name,FItems[n].Count]));
    For m:=0 To FItems[n].Count - 1 do With FItems[n].FStrings[m] do
      If Retry Then
        List.Add(Format('%d,%s,%d',[m,RName,RID]));
    List.Add('');
  end;
end;

Procedure TGameTextSet.OptimizeText(Progress: TProgressFunc = NIL);
var n,m,l,r: Integer;// Cancel: Boolean;
Label BRK;
begin
//  Cancel:=False;
  For n:=0 To Count-1 do
  begin
    If @Progress<>NIL Then
    begin
      If Progress(n, Count, FItems[n].FName) Then Break;
    end;
    For m:=0 To FItems[n].Count - 1 do
    begin
      For l:=0 To n do
      For r:=0 To FItems[l].Count - 1 do
      begin
        If (n=l) and (r>=m) Then GoTo BRK;
        If (Length(FItems[n].FStrings[m].Strr) = Length(FItems[l].FStrings[r].Strr))
          and (FItems[n].FStrings[m].Strr = '')
          or (//((FItems[n].FStrings[m].Strr <> '')
             //and (FItems[n].FStrings[m].Strr[1] = FItems[l].FStrings[r].Strr[1])
             {and (}FItems[n].FStrings[m].Strr = FItems[l].FStrings[r].Strr)//)
        Then
        begin
          SetLink(n,m,FItems[l].FName,r);
          {Text[n].S[m].Retry:=True;
          Text[n].S[m].RName:=Text[l].Name;
          Text[n].S[m].RID:=r;}
          GoTo BRK;
        end;
      end;
    BRK:
    end;
  end;
end;

function PosExRev(const SubStr, S: string; Offset: Cardinal = 0): Integer;
var
  I,X: Integer;
  LenSubStr: Integer;
begin
  I := Offset;
  LenSubStr := Length(SubStr);
  //Len := Length(S) - LenSubStr + 1;
  If I = 0 Then I := Length(S);
  while I > 0 do
  begin
    if S[I] = SubStr[LenSubStr] then
    begin
      X := 0;
      while (X < LenSubStr) and (S[I - X] = SubStr[LenSubStr - X]) do
        Inc(X);
      if (X = LenSubStr) then
      begin
        Result := I - LenSubStr + 1;
        exit;
      end;
    end;
    Dec(I);
  end;
  Result := 0;
end;

Function GetUpCase(S: String): String;
var n: Integer; C: ^Char;
begin
  C:=Addr(S[1]);
  Result:=S;
  For n:=1 To Length(S) do
  begin
    Case Result[n] of
      'a'..'z':  Dec(C^, Ord('a') - Ord('A'));
      'а'..'я':  Dec(C^, Ord('а') - Ord('А'));
      'ё':       Dec(C^, Ord('ё') - Ord('Ё'));
    end;
    Inc(C);
  end;
end;

constructor TTable.Create;
begin
   ByteMask := '{%2x}';
   FOpcodeList := TOpcodeList.Create;
end;

constructor TTable.Create(ErrorProc: TCreateError);
begin
  @FCreateError := @ErrorProc;
  Create;
end;

procedure TTable.SaveTable(List: TTntStringList; Append: Boolean);
var n,m: Integer; S: String;
const cStopChar: Array[Boolean] of String = ('', '!');
begin
  If not Append Then List.Free;
  For m := 0 To High(FTable) do With FTable[m] do
  begin
    S := '';
    For n := 0 To High(Data) do S := S + IntToHex(Data[m], 2);
    List.Add(WideFormat('%s%s=%s',[S,cStopChar[Mode=rtStop],Strr]));
  end;
end;

procedure TTable.SaveTable(FileName: String);
var List: TTntStringList;
begin
  List := TTntStringList.Create;
  SaveTable(List);
  List.SaveToFile(FileName);
  List.Free;
end;

Function CppToString(const S: WideString): WideString;
var n: Integer;
begin
  Result := '';
  n := 1;
  While n <= Length(S) do
  begin
    If S[n] = '\' Then
    begin
      Inc(n);
      If n>Length(S) Then
      begin
        Result := Result + '\';
        //@ERROR
        //CreateError('TTable.CppToString: Missing terminating character: %s', [S]);
        Exit;
      end;
      Case S[n] of
        '\': Result := Result + '\';
        'n': Result := Result + #$0A;
        'r': Result := Result + #$0D;
        't': Result := Result + #$09;
        'f': Result := Result + #$0C;
        'a': Result := Result + #$07;
        'e': Result := Result + #$1B;
        '0': Result := Result + #0;
        else
          Result := Result + S[n];
      end;
    end else
      Result := Result + S[n];
    Inc(n);
  end;
end;

Function StringToCpp(const S: WideString): WideString;
var n: Integer;
begin
  Result := '';
  For n := 1 To Length(S) do
  begin
    Case S[n] of
      '\' : Result := Result + '\\';
      #$0A: Result := Result + '\n';
      #$0D: Result := Result + '\r';
      #$09: Result := Result + '\t';
      #$0C: Result := Result + '\f';
      #$07: Result := Result + '\a';
      #$1B: Result := Result + '\e';
      #$00: Result := Result + '\0';
      else
        Result := Result + S[n];
      end;
  end;
end;


{ TGameText }


Function TGameText.AddString(Table: TTable; const Buf: Pointer; Len: Integer = 0; const Double: TByteSet = []): Integer;
begin
  SetLength(FStrings, Length(FStrings) + 1);
  Result := Table.ExtractString(Buf, FStrings[High(FStrings)].Strr, Len, Double);
end;

procedure TGameText.AddString(S: WideString);
begin
  SetLength(FStrings, Length(FStrings) + 1);
  FStrings[High(FStrings)].Strr := S;
end;

function TGameText.GetString(ID: Integer): WideString;
begin
  If FParent = nil Then
    Result := FStrings[ID].Strr
  else
    Result := FParent.Strings(FIndex, ID); 
end;
        
procedure TGameText.SetString(Index: Integer; const Value: WideString);
begin
  If FParent = nil Then
    FStrings[Index].Strr := Value
  else
    FParent.SetString(FIndex, Index, Value); 
end;

procedure TGameText.LoadText(FileName: String; Appned: Boolean);
begin
end;

procedure TGameText.SetName(const Value: String);
begin
  If (Length(Value)>0) and (Value[1] = '#') Then
    raise ECreateError.Create('The name can not begin with the character ''#''', @FCreateError);
  FName := Value;
end;

function TGameText.GetCount: Integer;
begin
  Result := Length(FStrings);
end;

function TGameText.GetRetry(Index: Integer): Boolean;
begin
  Result := FStrings[Index].Retry;
end;

procedure TGameTextSet.UnLink(ItemIndex, Index: Integer);
begin
 If (ItemIndex<0) or (ItemIndex>High(FItems)) Then raise ECreateError.Create
    ('TGameText.UnLink: Items out of bounds! (%d/%d)', [ItemIndex,High(FItems)], @FCreateError);
  If (Index<0) or (Index>High(FItems[ItemIndex].FStrings)) Then raise ECreateError.Create
    ('TGameText.UnLink: Strings out of bounds! (%d/%d)',
    [Index,High(FItems[ItemIndex].FStrings)], @FCreateError);
  With FItems[ItemIndex].FStrings[Index] do
  begin
    If not Retry Then Exit;
    Retry := False;
    Strr  := GetLinkedText(RName, RID);
    //@@FIXED
    //RName := '';
    //RID   := -1;
  end;
end;


function TGameText.TextSize: Integer;
var n: Integer;
begin
  Result := 0;
  For n:=0 To High(FStrings) do Inc(Result, Length(FStrings[n].Strr));
end;

procedure TGameText.Cut(ID: Integer);
begin
  If (ID<0) or (ID>High(FStrings)) Then raise ECreateError.Create
    ('Cut: Array out of bounds! (%d/%d)', [ID, High(FStrings)], @FCreateError);

  If FParent <> nil Then
    FParent.DelinkChildrensOfBlock(FIndex, ID, High(FStrings));
  SetLength(FStrings, ID);
end;

function TGameText.StrLength(Index: Integer): Integer;
begin
  If FParent = nil Then
    Result := Length(FStrings[Index].Strr)
  else
    Result := Length(Strings[Index]);
end;

procedure TGameText.Unlink(Index: Integer);
begin
  If FParent <> nil Then
    FParent.UnLink(FIndex, Index)
  else
    raise ECreateError.Create('Parent does not assigned!', FCreateError);
end;

procedure TGameText.SetCount(ACount: Integer);
begin
  If ACount < 0 Then
    raise ECreateError.Create('Invalid count!', FCreateError);
  SetLength(FStrings, ACount);
end;

{ TGameTextSet }

procedure TGameTextSet.AddString(ID: Integer; S: WideString);
begin
  If (ID<0) or (ID>High(FItems)) Then raise ECreateError.Create
    ('TGameTextSet.AddString: Array out of bounds! (%d/%d)', [ID, High(FItems)], @FCreateError);
  FItems[ID].AddString(S);
end;


function TGameTextSet.AddString(ID: Integer; P: PByte; Len: Integer = 0; const Double: TByteSet = []): Integer;
begin
  If (ID<0) or (ID>High(FItems)) Then raise ECreateError.Create
    ('TGameTextSet.AddString: Array out of bounds! (%d/%d)', [ID, High(FItems)], @FCreateError);
  Result := FItems[ID].AddString(Self as TTable, P, Len, Double);
end;

Function TGameTextSet.AddItem(const Name: String; const UserData: String;
          const Hidden: Boolean; const Caption: WideString ): TGameText;
var Num: Integer;
begin
  Num := Length(FItems);
  SetLength(FItems, Num + 1);
  FItems[Num] := TGameText.Create;
  Result := FItems[Num];
  Result.FName    := Name;
  Result.FParent  := Self;
  Result.FIndex   := Num;
  Result.UserData := UserData;
  Result.FHidden  := Hidden;
  Result.FCaption := Caption;
end;

procedure TGameTextSet.AddString(S: WideString);
begin
  If Length(FItems) = 0 Then raise ECreateError.Create
    ('TGameTextSet.AddString: Nowhere to add!', @FCreateError);
  FItems[High(FItems)].AddString(S);
end;

Function TGameTextSet.AddString(P: PByte; Len: Integer = 0; const Double: TByteSet = []): Integer;
begin
  If Length(FItems) = 0 Then raise ECreateError.Create
    ('TGameTextSet.AddString: Nowhere to add!', @FCreateError);
  Result := FItems[High(FItems)].AddString(Self as TTable, P, Len, Double);
end;

Procedure TGameTextSet.SaveTextToList(List: TTntStringList);
begin
  If List = nil Then
    ECreateError.Create('SaveTextToList: List does not assigned!', FCreateError);

  List.Text := SaveTextToString;
end;

Procedure TGameTextSet.SaveTextToFile(Name: String);
var {List: TTntStringList; }S: WideString; F: File;
const Code: Word = $FEFF;
begin
  S := SaveTextToString;
  Assign(F, Name);
  Rewrite(F, 1);

  //List := TTntStringList.Create;
  //SaveTextToList(List);
  //List.SaveToFile(Name);
  //List.Free;
  BlockWrite(F, Code, 2);
  BlockWrite(F, S[1], Length(S) * 2);
  CloseFile(F);
end;

procedure TTable.SetCreateError(const Value: TCreateError);
begin
  @FCreateError := @Value;
end;

function TGameTextSet.FindItem(LName: String): Integer;
var n, Code: Integer;
begin
  Result := -1;
  // @ERROR
  //If Length(FItems) = 0 Then raise ECreateError.Create('FindItem: Nowhere to find!', @FCreateError);
  //If Length(LName)  = 0 Then raise ECreateError.Create('FindItem: Nothing to find!', @FCreateError);
  If (Length(FItems) = 0) or (Length(LName)  = 0) Then
    Exit;

  If LName[1] = '#' Then
  begin
    LName[1] := '+';
    Val(LName, n, Code);
    If Code<>0 Then raise ECreateError.Create
      ('FindItem: Can not convert String to Integer! (String: %s, Code: %d)',
      [LName, Code],@FCreateError);
    If (n<0) or (n>High(FItems)) Then raise ECreateError.Create
      ('FindItem: Invalid index: %d',[n],@FCreateError);
  end else
  begin
    For n := 0 To High(FItems) do
      If FItems[n].Name = LName Then break;
    If n = Length(FItems) Then Exit;
    // @ERROR
    //If n = Length(FItems) Then raise ECreateError.Create('FindItem: Not found!', @FCreateError)
  end;
  Result := n;
end;

function TGameTextSet.GetLinkedText(LName: String; LIndex: Integer): WideString;
var Index: Integer;
begin
  Result := '#text';
  Index := FindItem(LName);
  If Index<0 Then raise ECreateError.Create('GetLinkedText: Can''t find parent!', @FCreateError);
  If LIndex >= FItems[Index].Count Then raise ECreateError.Create
    ('GetLinkedText: Array out of bounds! (%d/%d)', [LIndex, FItems[Index].Count-1], @FCreateError);
  Result := FItems[Index].FStrings[LIndex].Strr;
end;

procedure TGameTextSet.SetLinkedText(LName: String; LIndex: Integer; S: WideString);
var Index: Integer;
begin
  Index := FindItem(LName);
  If Index<0 Then raise ECreateError.Create('SetLinkedText: Can''t find parent!', @FCreateError);
  If LIndex >= FItems[Index].Count Then raise ECreateError.Create
    ('GetLinkedText: Array out of bounds! (%d/%d)', [LIndex, FItems[Index].Count-1], @FCreateError);
  FItems[Index].FStrings[LIndex].Strr := S;
end;

procedure TGameTextSet.SetLink(ItemIndex, Index: Integer; LName: String;
  LIndex: Integer);
begin
  FItems[ItemIndex].FStrings[Index].Retry := True;
  FItems[ItemIndex].FStrings[Index].RName := LName;
  FItems[ItemIndex].FStrings[Index].RID   := LIndex;
end;

procedure TGameTextSet.SetCreateError(ErrorProc: TCreateError);
var n: Integer;
begin
  //@FCreateError := @ErrorProc;
  inherited SetCreateError(ErrorProc);
  For n := 0 To High(FItems) do
    @FItems[n].FCreateError := @ErrorProc;
end;

function TGameTextSet.SaveTextToString: WideString;
var n,m, Pos, Size: Integer;

  Procedure Add(S: WideString; var VS: WideString);
  begin
    Move(S[1], VS[Pos + 1], Length(S)*2);
    Inc(Pos, Length(S));
  end;

const
  cHide:    Array[Boolean] of String = ('', 'H');
  cChecked: Array[Boolean] of String = ('', 'C');
  cCaption: Array[Boolean] of String = ('', ':');
begin
  Pos := 0;
  Size := TextSize*2 + NamesSize + Length(FInfoDel)*2*Count +
          Length(FItemPre)*Count + Length(FItemPos)*Count +
          Count*8 + (Count-1)*Length(FStrEnd) +
          (StringsCount)*Length(FStrEnd) + Length(FStrDel);// +
          //Count*Length(FItemDel);
  Size := Size * 2;
  SetLength(Result, Size);

  For n:=0 To High(FItems) do
  begin
    Add(WideFormat('%s%s%s%d',[FItemPre,FItems[n].Name,FInfoDel,FItems[n].Count]), Result);
    //
    If FItems[n].FHidden or FItems[n].FChecked or (FItems[n].FCaption <> '') Then
      Add(WideFormat('%s#%s%s%s%s%s', [FInfoDel, cHide[FItems[n].FHidden],
        cChecked[FItems[n].FChecked], cCaption[FItems[n].FCaption<>''],
        FItems[n].FCaption, cCaption[(FItems[n].FUserInfo<>'') and (FItems[n].FCaption<>'')]]), Result);
    If FItems[n].FUserInfo <> '' Then
      Add(WideFormat('%s%s',[FInfoDel, FItems[n].FUserInfo]), Result);
    Add(FItemPos, Result);


    //Top := LastParent(n);
    For m:=0 To High(FItems[n].FStrings) do
      If not FItems[n].Retry[m] Then
      begin
        Add(FItems[n].FStrings[m].Strr + FStrEnd, Result);
        (* If m<{High(FItems[n].FStrings)}Top Then *) Add(FStrDel, Result);
      end;
    //If n < High(FItems) Then Add(FItemDel, Result);
  end;

  SetLength(Result, Pos);
end;

constructor TGameTextSet.Create;
begin
  FDelCarrets := True;
  If @FCreateError <> nil Then
    inherited Create(FCreateError)
  else
    inherited Create;
  FStrEnd := CppToString('\n{E}');
  FStrDel := CppToString('\n\n');
  //FItemDel := CppToString('\n\n');
  FItemPre := '[@';
  FItemPos := CppToString(']\n\n');
  FInfoDel := ',';
end;

constructor TGameTextSet.Create(ErrorProc: TCreateError);
begin
  @FCreateError := @ErrorProc;
  Create;
end;

function TGameTextSet.TextSize: Integer;
var n: Integer;
begin
  Result := 0;
  For n := 0 To High(FItems) do Inc(Result, FItems[n].TextSize);
end;

function TGameTextSet.NamesSize: Integer;
var n: Integer;
begin
  Result := 0;
  For n := 0 To High(FItems) do Inc(Result, Length(FItems[n].Name));
end;

function TGameTextSet.Count: Integer;
begin
  Result := Length(FItems);
end;

function TGameTextSet.StringsCount: Integer;
var n: Integer;
begin 
  Result := 0;
  For n := 0 To High(FItems) do Inc(Result, FItems[n].Count);
end;

Procedure TGameTextSet.LoadOptimDataFromString(const S: WideString);
var List: TStringList;
begin
  List := TStringList.Create;
  List.Text := S;
  LoadOptimDataFromList(List);
  List.Free;
end;

function TGameTextSet.CkeckDelimeters: Boolean;
begin
  Result := False;
  FError := False;

  If FItemPre = '' Then
    CreateError('Item prefix does not exist!');
  If FItemPos = '' Then
    CreateError('Item postfix does not exist!');
  If FInfoDel = '' Then
    CreateError('Item info delimeter does not exists!');
  If FStrEnd = '' Then
    CreateError('Strings end delimeter does not exists!');
  If not FError Then
    Result := True;
end;

procedure TTable.TrimStr(var S: WideString);
var b,e: Integer; SS: WideString;
begin
  For b := 1 To Length(S) do
    If S[b] > #32 Then break;
  For e := Length(S) DownTo 1 do
    If S[e] > #32 Then break;
  If e >= b Then
  begin
    SetLength(SS, e - b + 1);
    Move(S[b], SS[1], Length(SS)*2);
    S := SS;
  end;      
end;

procedure TTable.SetByteMask(const Mask: WideString);
begin
  If not DrawByteMask(Mask) Then
    raise ECreateError.Create('Byte mask string is invalid! (%s)', [Mask], FCreateError);
  FByteMask := Mask;
end;


procedure TGameTextSet.SaveOptimDataToFile(FileName: String);
var List: TStringList;
begin
  List := TStringList.Create;
  SaveOptimDataToList(List);
  Try
    List.SaveToFile(FileName);
  except                                                          
    List.Free;
    raise ECreateError.Create('Error saving file!', FCreateError);
  end;
end;

function TGameTextSet.SaveOptimDataToString: String;
var List: TStringList;
begin
  List := TStringList.Create;
  SaveOptimDataToList(List);
  Result := List.Text;
  List.Free;
end;

procedure TGameTextSet.LoadOptimDataFromFile(FileName: String);
var List: TStringList;
begin
  List := TStringList.Create;
  List.LoadFromFile(FileName);
  LoadOptimDataFromList(List);
  List.Free;
end;

Function GetPart(S: String; C: TCharSet; Num: Integer; SPos: Integer = 1; EPos: Integer = 0): String;
var n,m: Integer;
begin
  m:=1;
  Result:='';
  If SPos < 1 Then SPos := 1;
  If (EPos < 1) or (EPos > Length(S)) Then EPos := Length(S);

  For n := SPos to EPos do
  begin
    If (Num = m) and (S[n] in C) Then Inc(m);
    If Num = m then
    Result := Result+S[n];
    If (Num <> m) and (S[n] in C) Then Inc(m);
  end;
end;

Function GetPart(S: String; C: Char; Num: Integer; SPos: Integer = 1; EPos: Integer = 0): String;
begin
  Result := GetPart(S, [C], Num, SPos, EPos);
end;

Function GetPart(S: WideString; Sub: WideString; Num: Integer; SPos: Integer = 1; EPos: Integer = 0): WideString;
var n,m: Integer;
begin
  Result := '';
  If S = '' Then
    Exit;
    //raise ECreateError.Create('GetPart: Empty string!',FCreateError);

  m:=1;
  Result:='';
  If SPos < 1 Then SPos := 1;
  If (EPos < 1) or (EPos > Length(S) - Length(Sub) + 1) Then EPos := Length(S) - Length(Sub) + 1;

  //For n:=SPos to EPos + Length(Sub) - 1 do
  n := SPos;
  While n <= EPos + Length(Sub) - 1 do
  begin
    If (n <= EPos) and CompareMem(@S[n], @Sub[1], Length(Sub) * 2) Then
    begin
      Inc(m);
      Inc(n, Length(Sub));
      Continue;
    end else
    If m = Num Then
      Result := Result + S[n];
    Inc(n);
  end;
end;

procedure TGameTextSet.LoadOptimDataFromList(List: TStringList);
var n,m,i: Integer; S: String;
begin
  n:=-1;
  Clear;
  For m:=0 To List.Count-1 do
  begin
    S:=List.Strings[m];
    If (Length(S)>0) and (S[1]='[') Then
    begin
      Inc(n);
      AddItem(GetPart(S,[','],1,3,Length(S)-1));
      SetLength(FItems[n].FStrings,StrToInt(GetPart(S,[',',']'],2)));
    end else
    If S<>'' Then With FItems[n] do
    begin
      i:=StrToInt(GetPart(S,',',1));
      If (i>=0) and (i<=High(FStrings)) Then
      begin
        FStrings[i].Retry:=True;
        FStrings[i].RName:=GetPart(S,',',2);
        FStrings[i].RID:=StrToInt(GetPart(S,',',3));
      end else
        CreateError('Invalid string number in line %s!', [S]);
    end;
  end;
end;

procedure TGameTextSet.Clear;
var n: Integer;
begin
  For n := 0 To High(FItems) do
    FItems[n].Free;
  Finalize(FItems);
end;

procedure TGameTextSet.LoadTextFromFile(FileName: String; Optimized: Boolean = False);
var F: File; W: Word; S: WideString; SS: String; n: Integer;
begin
  If not FileExists(FileName) Then
    raise ECreateError.Create('File does not exist: %s',[FileName], @FCreateError);
  //List := TTntStringList.Create;
  //List.LoadFromFile(FileName);
  //LoadTextFromList(List, Optimized);
  AssignFile(F, FileName);
  Reset(F, 1);
  BlockRead(F, W, 2);
  If (W = $FEFF) or (W = $FFFE) Then
  begin
    SetLength(S, (FileSize(F) - 2) div 2);
    BlockRead(F, S[1], FileSize(F) - 2);
    If W = $FFFE Then
      For n := 1 To Length(S) do
        Word(S[n]) := (Word(S[n]) SHR 8) or (Word(S[n]) SHL 8);
  end else
  begin
    Seek(F, 0);
    SetLength(SS, FileSize(F));
    BlockRead(F, SS[1], FileSize(F));
    S := SS;
  end;

  CloseFile(F);
  LoadTextFromString(S, Optimized);
  //List.Free;
end;

procedure TGameTextSet.LoadTextFromList(List: TTntStringList; Optimized: Boolean = False);
begin
  If List = nil Then
    ECreateError.Create('LoadTextFromList: List does not assigned!', FCreateError);
  LoadTextFromString(List.Text, Optimized);
end;


function WidePosEx(const SubStr, S: WideString; Offset: Cardinal; Out StrLen: Integer): Integer;
var
  I,X{,C}: Integer;
  Len, LenSubStr, LenCarret: Integer;
begin
//  LenCarret := 0;
  StrLen := 0;
  //if Offset = 1 then
  //  Result := Pos(SubStr, S)
  //else
  begin
    I := Offset;
    LenSubStr := Length(SubStr);
    Len := Length(S) - LenSubStr + 1;
    while I <= Len do
    begin
      if (S[I] = SubStr[1]) or (S[I] = #$0D) then
      begin
        If S[I] = #$0D Then
          LenCarret := 1
        else
          LenCarret := 0;
        X := 1;
        while (X < LenSubStr + LenCarret) and ((S[I + X] = SubStr[X + 1 - LenCarret]) or (S[I + X] = #$0D)) do
        begin              
          If S[I + X] = #$0D Then Inc(LenCarret);
          Inc(X);
        end;
        if (X = LenSubStr + LenCarret) then
        begin
          Result := I;  
          StrLen := LenSubStr + LenCarret;
          {If (Offset > 1) and (S[I] = #$0A) and (S[I - 1] = #$0D) Then
          begin
            Dec(Result);
            Inc(StrLen);
          end;}
          exit;
        end;
      end;
      Inc(I);
    end;
    Result := 0;
  end;
end;

function WidePosExRev(const SubStr, S: WideString; Offset: Cardinal = 0): Integer;
var
  I,X: Integer;
  LenSubStr: Integer;
begin
  I := Offset;
  LenSubStr := Length(SubStr);
  If I = 0 Then I := Length(S);
  while I > 0 do
  begin
    if S[I] = SubStr[LenSubStr] then
    begin
      X := 0;
      while (X < LenSubStr) and (S[I - X] = SubStr[LenSubStr - X]) do
        Inc(X);
      if (X = LenSubStr) then
      begin
        Result := I - LenSubStr + 1;
        exit;
      end;
    end;
    Dec(I);
  end;
  Result := 0;
end;

function DeleteCarrets(const S: WideString): WideString;
var n,C: Integer;
begin
  C := 0;
  SetLength(Result, Length(S));
  For n := 1 To Length(S) do
    If S[n]<>#13 Then
    begin
      Inc(C);
      Result[C] := S[n];
    end;
  SetLength(Result, C);
end;


Function ReturnCarrets(const S: WideString): WideString;
var n, C, Len: Integer; //SS: WideString;
begin
  C := 1;
  Len := Length(S);
  SetLength(Result, Len * 2);
  n := 1;
  While n <= Length(S) do
  begin
    If (S[n] = #10) and ((n = 1) or (S[n + 1] <> #13)) Then
    begin
      Result[C] := #13;
      Result[C + 1] := #10;
      Inc(C, 2);
      //SS := Result;
      //SetLength(SS, C);
    end else
    begin
      Result[C] := S[n];
      Inc(C);
    end;        
    Inc(n);
  end;
  SetLength(Result, C - 1);
end;

Function WCompareMem(C, S: PWideChar; Count: Integer; out Len: Integer): Boolean;
begin
  Len := Count;
  Result := False;
  While Count > 0 do
  begin
    If (C^ <> S^) Then
    begin  
      If (S^ = #$0D) Then
      begin
        Inc(Len);
        Inc(S);
        Continue;
      end;
      Exit;
    end;
    Inc(C);
    Inc(S);
    Dec(Count);
  end;
  Result := True;
end;

procedure TGameTextSet.LoadTextFromString(S: WideString; Optimized: Boolean = False);
var P,E, n: Integer; Cur, Len, StrCount, Code, PreLen, PosLen: Integer; Info,Name,UserInfo: WideString; SCount: String;
begin
  If not CkeckDelimeters Then
    raise ECreateError.Create('LoadTextFromString: Invalid structure string(s)!', FCreateError);

  If not Optimized Then Clear;
  Cur := -1;
  If FDelCarrets Then
    S := DeleteCarrets(S);
  Len := Length(S); 
  P := 1;
  While P < Len do
  begin
    P := WidePosEx(FItemPre, S, P, PreLen);
    If P = 0 Then Break;
    Inc(P, {Length(FItemPre)} PreLen);
    E := WidePosEx(FItemPos, S, P, PosLen);
    If E = 0 Then
      raise ECreateError.Create ('Unterminated block header! (Pos: %d)',
        [P - {Length(FItemPre)}PreLen], FCreateError);
    SetLength(Info, E - P);
    Move(S[P], Info[1], Length(Info) * 2);
    P := E + PosLen{Length(FItemPos)};

    Name     := GetPart(Info, FInfoDel, 1);
    SCount   := GetPart(Info, FInfoDel, 2);
    UserInfo := GetPart(Info, FItemPos, 1, Length(SCount) + Length(Name) + Length(FInfoDel)*2 + 1);
    Val(SCount, StrCount, Code);
    If Code <> 0 Then
      CreateError('Invalid integer string: "%s", Code: %d', [SCount, Code]);

    If not Optimized Then
    begin
      AddItem(Name);
      Inc(Cur);
    end else
      Cur := FindItem(Name);

    
    //WriteLn(Cur,'/',Count - 1);
      
    If (Cur < 0) or (Cur >= Count) Then
      raise ECreateError.Create('Item "%s" not found! (%d/%d)', [Name, Cur, Count - 1], FCreateError);

    With FItems[Cur] do
    begin
      FHidden   := False;
      FChecked := False;
      FName    := Name;
      If (UserInfo <> '') and (UserInfo[1] = '#') Then
      begin
        Info      := GetPart(UserInfo, FInfoDel, 1);
        FUserInfo := GetPart(UserInfo, FInfoDel, 2);
        For n := 2 To Length(Info) do
          Case Char(Info[n]) of
            'c', 'C': FChecked := True;
            'h', 'H': FHidden    := True;
            ':':
            begin
              Info      := GetPart(UserInfo, ':' + FInfoDel, 1);
              FUserInfo := GetPart(UserInfo, ':' + FInfoDel, 2);
              SetLength(FCaption, Length(Info) - n);
              Move(Info[n + 1], FCaption[1], Length(FCaption)*2);
              break;
            end;
          else
            CreateError('LoadTextFromString: Unknown flag character: %s', [Char(Info[n])] , etWarning);
          end;
      end
      else
        FUserInfo := UserInfo;
    end;
    {If CompareMem(@S[P], @FItemDel[1], Length(FItemDel) * 2) Then
      Inc(P, Length(FItemDel))
    else
      CreateError('Structure is damaged!', etWarning);}

    Try      
      //WriteLn('[',Count, '] ',Name);
      LoadItem(S, P, Cur, Optimized);
      //readln;
    except
      raise ECreateError.Create('Invalid Structure!', FCreateError);
    end;
    If StrCount <> Length(FItems[Cur].FStrings) Then
      CreateError('Different strings count in %s: %d != %d', [Name, StrCount, Length(FItems[Cur].FStrings)], etWarning);
  end;
end;

procedure TGameTextSet.LoadItem(const S: WideString; var P: Integer;
          const Num: Integer; Optimized: Boolean = False);
var SI: WideString; Cur, PP, Len, EndLen, DelLen: Integer;
begin
  If (Num < 0) or (Num >= Count) Then
    raise ECreateError.Create('LoadItem: Items out of bounds!', FCreateError);

  Len := Length(S);
  If (P<0) or (P>Len) Then
    Exit;
    //raise ECreateError.Create('LoadItem: String out of bounds!', FCreateError);

  Cur := -1;
  While P < Len do
  begin
    If (Len - P) < Length(FStrEnd) Then Exit;
    If CompareMem(@S[P], @FItemPre[1], Length(FItemPre) * 2) Then Exit;
    If CompareMem(@S[P], @FStrDel[1], Length(FStrDel) * 2) and
       CompareMem(@S[P+Length(FStrDel)], @FItemPre[1], Length(FItemPre) * 2) Then
        Exit;
    PP := WidePosEx(FStrEnd, S, P, EndLen);
    If PP <= 0 Then
      raise ECreateError.Create('LoadItem: Unterminated string block! (pos=%d)', [P], FCreateError);
    SetLength(SI, PP - P);
    Move(S[P], SI[1], Length(SI) * 2);
    If Optimized Then
    begin
      Cur := NextParent(Num, Cur);
      If Cur < 0 Then
        raise ECreateError.Create('LoadItem: Too many strings in %s!',
          [FItems[Num].FName], FCreateError);
      FItems[Num].FStrings[Cur].Strr := SI;
    end else
      AddString(Num, SI);
    P := PP + EndLen{Length(FStrEnd)};
    //If CompareMem(@S[P], @FStrDel[1], Length(FStrDel) * 2) Then
    //  Inc(P, Length(FStrDel))
    If WCompareMem(@FStrDel[1], @S[P], Length(FStrDel), DelLen) Then
      Inc(P, DelLen)
    else
      CreateError('LoadItem: Structure is damaged!', etWarning);
  end;

end;

function TGameTextSet.LastParent(ID: Integer): Integer;
begin
  If (ID<0) or (ID>High(FItems)) Then
    raise ECreateError.Create('NextParent: Items out of bounds (%d/%d)', [ID, High(FItems)], FCreateError);
  With FItems[ID] do For Result := High(FStrings) DownTo 0 do
    If not FStrings[Result].Retry Then break;
end;

function TGameTextSet.NextParent(ID: Integer; Cur: Integer = -1): Integer;
begin
  Result := -1;
  Inc(Cur);
  If (ID<0) or (ID>High(FItems)) Then
    raise ECreateError.Create('NextParent: Items out of bounds (%d/%d)', [ID, High(FItems)], FCreateError);

  If Cur > High(FItems[ID].FStrings) Then Exit
  else if Cur < 0 Then Cur := 0;
  With FItems[ID] do For Result := Cur To High(FStrings) do
    If not FStrings[Result].Retry Then break;
  If Result > High(FItems[ID].FStrings) Then Result := -1;
end;

function TTable.GetElementDataFast(var C: PWideChar; var P: PByte;
  const Len: Integer; var DataLen: Integer; GetIndexes: Boolean = False): Integer;
var L: Integer; B: Byte; D: TByteArray; S: PWideChar; SLen: Integer;
  Rec: PTableRecord;
begin
  Result := 0;
  L := Len;
  If IsByte(C, B, L) Then
  begin
    P^ := B;
    Inc(P);
    Inc(C, L);
    Result := L;
    DataLen := 1;
    Exit;
  end;
  Rec := FStringIndex[Byte(C^)];
  While Rec <> nil do With Rec^ do
  begin
    If IsOp Then
    begin
      If Length(FOpcodeList.FOpcodes[OpID].Values) > 0 Then
      begin
        S := PWideChar(FOpcodeList.FOpcodes[OpID].Values[0].Pre);
        SLen := Length(FOpcodeList.FOpcodes[OpID].Values[0].Pre);
      end else
      begin
        S    := PWideChar(FOpcodeList.FOpcodes[OpID].Footer);
        SLen := Length(FOpcodeList.FOpcodes[OpID].Footer);
      end;
      If ((Len=0) or (SLen <= Len)) and ((SLen = 0) or CompareMem(S, C, SLen * 2)) Then
      begin
        L :=  FOpcodeList.GetData(OpID, D, C, Len);
        If L >= 0 Then
        begin  
          Result := L;
          If GetIndexes Then
          begin
            DataLen := 4;
            PTableRecord(Pointer(P)^) := Rec;
            Inc(P, 4);
            Inc(C, Result);
            Exit;
          end else
          begin
            DataLen := Length(D);
            Move(D[0], P^, DataLen);
            Inc(P, DataLen);
            Inc(C, Result);
            Exit;
          end;
        end;
      end;
    end else
    begin
      L := Length(Strr);
      If (L <= Len) and (L > 0) and (Strr[1] = C^) and CompareMem(@Strr[1], C, L*2) Then
      begin           
        Result :=  L;
        If GetIndexes Then
        begin
          DataLen := 4;//Length(FTable[n].Indexes) * SizeOf(FTable[n].Indexes[0]);
          PTableRecord(Pointer(P)^) := Rec;
          Inc(P, 4 (*DataLen*));
          Inc(C, Result);
          Exit;
        end else
        begin
          //Result := Length(Data);
          DataLen := Length(Data);
          Move(Data[0], P^, DataLen);
          Inc(P, DataLen);
          Inc(C, Result);
          Exit;
        end;
      end;
    end;
    Rec := Rec^.NextForString;
  end;
end;

function TTable.GetElementData(var C: PWideChar; var P: PByte;
  const Len: Integer; var DataLen: Integer; GetIndexes: Boolean = False): Integer;
var n, L: Integer; B: Byte; D: TByteArray; S: PWideChar; SLen: Integer;
begin
  Result := 0;
  L := Len;
  If IsByte(C, B, L) Then
  begin
    Result := L;
    Inc(C, L);
    If GetIndexes Then
      DataLen := 0
    else
    begin
      P^ := B;
      Inc(P);
      DataLen := 1;
    end;
    Exit;
  end;
  For n := 0 To High(FTable) do With FTable[n] do
  begin
    If IsOp Then
    begin
      If Length(FOpcodeList.FOpcodes[OpID].Values) > 0 Then
      begin
        S := PWideChar(FOpcodeList.FOpcodes[OpID].Values[0].Pre);
        SLen := Length(FOpcodeList.FOpcodes[OpID].Values[0].Pre);
      end else
      begin
        S    := PWideChar(FOpcodeList.FOpcodes[OpID].Footer);
        SLen := Length(FOpcodeList.FOpcodes[OpID].Footer);
      end;
      If ((Len=0) or (SLen <= Len)) and ((SLen = 0) or CompareMem(S, C, SLen * 2)) Then
      begin
        L :=  FOpcodeList.GetData(OpID, D, C, Len);
        If L >= 0 Then
        begin  
          Result := L;
          If GetIndexes Then
          begin
            DataLen := 4;
            PTableRecord(Pointer(P)^) := @FTable[n];
            Inc(P, 4);
            Inc(C, Result);
            Exit;
          end else
          begin
            DataLen := Length(D);
            Move(D[0], P^, DataLen);
            Inc(P, DataLen);
            Inc(C, Result);
            Exit;
          end;
        end;
      end;
    end else
    begin
      L := Length(Strr);
      If (L <= Len) and (L > 0) and (Strr[1] = C^) and CompareMem(@Strr[1], C, L*2) Then
      begin           
        Result :=  L;
        If GetIndexes Then
        begin
          DataLen := 4;//Length(FTable[n].Indexes) * SizeOf(FTable[n].Indexes[0]);
          PTableRecord(Pointer(P)^) := @(FTable[n]);
          Inc(P, 4 (*DataLen*));
          Inc(C, Result);
          Exit;
        end else
        begin
          //Result := Length(Data);
          DataLen := Length(Data);
          Move(Data[0], P^, DataLen);
          Inc(P, DataLen);
          Inc(C, Result);
          Exit;
        end;
      end;
    end;
  end;
end;

function TTable.IsByte(C: PWideChar; var B: Byte; var Len: Integer): Boolean;
var n, Cur, Cnt, Cr: Integer; Ch: String; SLen: String;
const
  Max: Array[TDataMode] of Integer = (3,2,1,0);
  CharSet: Array[TDataMode] of TCharSet = (['0'..'9'], ['0'..'9','a'..'f','A'..'F'],[#0..#255],[#0..#255]);
begin
  Result := False;
  Cnt := 0;
  If Length(FByteLeft) + Length(FByteRight) + FByteLen > Len Then Exit;
  For Cur := 0 To Length(FByteLeft) - 1 do
    If C[Cur] <> FByteLeft[Cur + 1] Then Exit;
  Case FByteMode of
    dmDec, dmHex:
    begin
      If FByteLen <= 0 Then Cnt := Max[FByteMode]
      else Cnt := FByteLen;
      Cr := Cur;
      For Cur := Cr To Cr + Cnt - 1 do
        If Char(C[Cur]) in CharSet[FByteMode] Then
          SLen := SLen + C[Cur]
        else If FByteLen > 0 Then Exit else break;
    end;
    dmChar:
    begin
      Ch := C[Cur];
      B := Byte(Ch[1]);
      Inc(Cur);
    end;
  end;
  n := 1;
  For Cur := Cur To Cur + Length(FByteRight) - 1 do
  begin
    If C[Cur] <> FByteRight[n] Then Exit;
    Inc(n);
  end;
  Len := Cur;
  Case FByteMode of
    dmDec: Val(SLen, B, n);
    dmHex: Val('$'+SLen, B, n);
  end;
  Result := True;

end;


function TTable.DrawByteMask(S: WideString): Boolean;
Type
  TReadMode = (rmChar, rmData, rmLenOnly, rmReadData, rmPostChar);
var n: Integer; Mode: TReadMode; SLen: String; DMode: TDataMode;
L,R: WideString;
//const cChar: Array[TDataMode] of Char = ('d', 'x', 'c', '{');
begin          
  Result := False;
  FByteLen := 0;
  Mode := rmChar;
  For n := 1 To Length(S) do
  begin
    Case Mode of
      rmChar:     If S[n] = '%' Then Mode := rmData Else L := L + S[n];
      rmPostChar: R := S[n] + R;
      rmData:
      begin
        Case S[n] of
          '%':
          begin
            L := L + S[n];
            Mode := rmChar;
          end;
          '0'..'9':
          begin
            SLen := S[n];
            Mode := rmLenOnly;
          end;
          'c','d','x':
          begin
            Case S[n] of
              'c': DMode := dmChar;
              'd': DMode := dmDec;
              'x': DMode := dmHex;
            end;
            Mode := rmPostChar;//rmReadData;
          end;
        else
          Exit;
        end;
      end;
      rmLenOnly:
      begin
        If (S[n]>'0') and (S[n]<'9') Then SLen := SLen + S[n] Else
        Case S[n] of
          'c': DMode := dmChar;
          'd': DMode := dmDec;
          'x': DMode := dmHex;
        else
          Exit;
        end;
        Mode := rmPostChar;
      end;
    end;
  end;
  FByteLeft  := L;
  FByteRight := R;
  If SLen <> '' Then
    FByteLen := StrToInt(SLen)
  else
    FByteLen := 0;
  FByteMode  := DMode;
  If FByteLen > 0 Then
    FByteEMask := WideFormat('%s%%%d.%d%s%s',[L, FByteLen, FByteLen, cChar[FByteMode], R])
  else
    FByteEMask := WideFormat('%s%%%s%s', [L, cChar[FByteMode], R]);
  Result := True;
end;

function TTable.ExportString(var P: PByte; Text: WideString;
  AutoStop: Boolean = False; GetIndexes: Boolean = False): Integer;
begin
  Result := ExportString(P, PWideChar(Text), Length(Text), AutoStop, GetIndexes);
end;

function TTable.ExportString(var P: PByte; C: PWideChar; Len: Integer;
  AutoStop: Boolean = False; GetIndexes: Boolean = False): Integer;
var DL, SL: Integer;
begin
  If P = nil Then
    raise ECreateError.Create('ExportString: Pointer does not assigned!',FCreateError);

  Result := 0;

  While Len > 0 do
  begin
    SL := GetElementData(C, P, Len, DL, GetIndexes);
    Dec(Len, SL);
    If SL = 0 Then
    begin
      DL := Length(FNEData);
      If DL > 0 Then
        Move(FNEData[0], P^, DL);
      Inc(P, DL);
      If @FCreateError <> nil Then
        FCreateError(Format('Unknown char: ''%s'' (wchar code: 0x%4.4x)',
         [WideCharLenToString(C, 1), Word(C^)]), etWarning);
      Inc(C);
      Dec(Len);
    end;
    Inc(Result, DL);
  end;
  If AutoStop Then
  begin
    DL := StopData;
    If DL < 0 Then
      raise ECreateError.Create('ExportString: Stop data not found!', FCreateError);
    Len := Length(FTable[DL].Data);
    If Len > 0 Then Move(FTable[DL].Data[0], P^, Len);
    Inc(P, Len);
    Inc(Result, Len);
  end;
end;

function TTable.StopData(ID: Integer): Integer;
begin
  If (ID < 0) Then
    raise ECreateError.Create('StopData: Table out of bounds!', FCreateError);

  For Result := ID To High(FTable) do
    If FTable[Result].Mode = rtStop Then Exit;
  Result := -1;
end;

function TGameTextSet.Strings(ItemIndex, Index: Integer): WideString;
begin
  If (ItemIndex<0) or (ItemIndex>High(FItems)) Then raise ECreateError.Create
    ('Items out of bounds! (%d/%d)', [ItemIndex,High(FItems)], @FCreateError);
  If (Index<0) or (Index>High(FItems[ItemIndex].FStrings)) Then raise ECreateError.Create
    ('Strings out of bounds! (%d/%d)', [Index,High(FItems[ItemIndex].FStrings)], @FCreateError);

  With FItems[ItemIndex].FStrings[Index] do
  If Retry Then
    Result := GetLinkedText(RName, RID)
  else
    Result := Strr;
end;

function TTable.GetTableElement(Index: WideString): TByteArray;
var n: Integer;
begin
  For n := 0 To High(FTable) do
    If Index = FTable[n].Strr Then
      Break;
  If n = Length(FTable) Then
    Result := FNEData
  else
    Result := FTable[n].Data;
end;

procedure TTable.SetTableElement(Index: WideString; const Value: TByteArray);
var n: Integer;
begin
  For n := 0 To High(FTable) do
    If Index = FTable[n].Strr Then
      Break;
    
  If n = Length(FTable) Then
    raise ECreateError.Create('Element %s not found!', [Index], FCreateError)
  else
    FTable[n].Data := Value;

end;

procedure TGameTextSet.DelinkChildrensOfBlock(ItemIndex, ID1, ID2: Integer);
var n: Integer;
begin
  For n := ID1 To ID2 do DelinkChildrens(FItems[ItemIndex].FName, n);
end;

procedure TGameTextSet.DelinkChildrens(Name: String; ID: Integer);
var n, m: Integer;
begin
  For n := 0 To High(FItems) do
    For m := 0 To High(FItems[n].FStrings) do With FItems[n].FStrings[m] do
      If Retry and (RID = ID) and (RName = Name) Then UnLink(n, m);
end;

function TGameTextSet.Optimized: Boolean;
var n,m: Integer;
begin
  Result := True;
  For n := 0 To High(FItems) do
    For m := 0 To High(FItems[n].FStrings) do
      If FItems[n].FStrings[m].Retry Then
        Exit;
  Result := False;
end;

procedure TGameTextSet.SetString(ItemIndex, Index: Integer; S: WideString);
begin
  If FItems[ItemIndex].FStrings[Index].Retry Then
    SetLinkedText(FItems[ItemIndex].FStrings[Index].RName,
                  FItems[ItemIndex].FStrings[Index].RID, S)
  else
    FItems[ItemIndex].FStrings[Index].Strr := S;
end;

function TGameTextSet.VisibleCount: Integer;
var n: Integer;
begin
  Result := 0;
  For n := 0 To High(FItems) do
    If not FItems[n].FHidden Then
      Inc(Result);
end;

{ TOpcode }

procedure TOpcodeList.Add(Mask: TByteArray; ValMasks: TByteArraySet; Fmt: WideString);
begin

end;

function TOpcodeList.CheckMask(Index: Integer; P: PByte; Len: Integer = 0): Boolean;
var n: Integer;
begin
  Result := False;
  With FOpcodes[Index] do
  begin
    If (Len <> 0) and (Len < Length(Mask)) Then Exit;
    For n := 0 To High(Mask) do
    begin
      If (P^ and Mask[n]) <> Data[n] Then Exit;
      Inc(P);
    end;
  end;
  Result := True;
end;

procedure TOpcodeList.Clear;
var n,m: Integer;
begin
  For n := 0 To High(FOpcodes) do
  begin
    For m := 0 To High(FOpcodes[n].Values) do With FOpcodes[n].Values[m] do
    begin
      Finalize(Mask);
      Finalize(Pre);
      Finalize(Enum);
    end;
    With FOpcodes[n] do
    begin
      Finalize(Mask);
      Finalize(Data);
      Finalize(Fmt);
      Finalize(Footer);
      Finalize(Spaces);
    end;
  end;
  Finalize(FOpcodes);
end;

function TOpcodeList.DrawFormat(S: WideString; var Opcode: TOpcodeRecord): Boolean;
Type
  TReadMode = (rmChar, rmData, rmLenOnly, rmReadData, rmEnum, rmEnumNum, rmSpaces);
var n, m, Count, EnumNum, Code: Integer; Mode: TReadMode; SLen: String;
DMode: TDataMode; L, SEnumNum, SEnum: WideString;

Procedure Complete;
begin
  If High(Opcode.Values)<Count Then SetLength(Opcode.Values, Count + 1);
  With Opcode, Values[Count] do
  begin
    Pre := L;
    ValType := DMode;
    If SLen <> '' Then
    begin
      Len := StrToInt(SLen);
      Fmt := WideFormat('%s%s%%%d.%d%s', [Fmt, Pre, Len, Len, cChar[DMode]]);
    end else
    begin
      Len := 0;
      Fmt := WideFormat('%s%s%%%s', [Fmt, Pre, cChar[DMode]]);
    end;
  end;
  Inc(Count);
  L := '';
  SLen := '';
  EnumNum := 0;
  Mode := rmChar;//rmPostChar;
end;

Procedure CompleteEnumElement;
var n: Integer;
begin
  If High(Opcode.Values)<Count Then SetLength(Opcode.Values, Count + 1);
  With Opcode.Values[Count] do
  begin
    For n := 0 To High(Enum) do
      If Enum[n].Str = SEnum Then
      begin
         If FParent <> nil Then FParent.CreateError(Format('Redefinition of "%s"!', [SEnum]), etWarning);
      end;
      SetLength(Enum, Length(Enum) + 1);
      Enum[High(Enum)].Str   := SEnum;
      Enum[High(Enum)].Index := EnumNum;
  end;
  SEnum := '';
  Inc(EnumNum);
  Mode := rmEnum;
end;

begin
  Result := False;
  Opcode.Fmt := '';
  Count := 0;
  Mode := rmChar;
  EnumNum := 0;
  For n := 1 To Length(S) do
  begin
    Case Mode of
      rmChar:  If S[n] = '%' Then Mode := rmData Else L := L + S[n];
      rmData:
      begin
        Case S[n] of
          '%':
          begin
            L := L + S[n];
            Mode := rmChar;
          end;
          '0'..'9':
          begin
            SLen := S[n];
            Mode := rmLenOnly;
          end;
          'c','d','x':
          begin
            Case S[n] of
              'c': DMode := dmChar;
              'd': DMode := dmDec;
              'x': DMode := dmHex;
            end;
            Complete;
          end;
          '{':
          begin
            Mode := rmEnum;
            DMode := dmEnum;
          end;
        '[': Mode := rmSpaces;
        else
          Exit;
        end;
      end;
      rmLenOnly:
      begin
        If (S[n]>'0') and (S[n]<'9') Then SLen := SLen + S[n] Else
        Case S[n] of
          'c': DMode := dmChar;
          'd': DMode := dmDec;
          'x': DMode := dmHex;
        else
          Exit;
        end;
        Complete;
      end;
      rmEnum:
      begin
        Case S[n] of
          '}':
          begin
            CompleteEnumElement;
            Complete;
          end;
          ',':  CompleteEnumElement;
          '=':
          begin
            SEnumNum := '';
            Mode     := rmEnumNum;
          end;
        else
          SEnum := SEnum + S[n];
        end;
      end;
      rmEnumNum:
      begin
        Case S[n] of
          '0'..'9','x','X','$': SEnumNum := SEnumNum + S[n];
          ',', '}':
          begin
            Val(SEnumNum, EnumNum, Code);
            If Code <> 0 Then Exit;
            CompleteEnumElement;
            If S[n] = '}' Then Complete;
          end;
        else
          Exit;
        end;
      end;
      rmSpaces:
      begin
        If S[n] = ']' Then
          Mode := rmChar
        else
        begin
          For m := 1 To Length(Opcode.Spaces) do
            If S[n] = Opcode.Spaces[m] Then
              break;
          If (Length(Opcode.Spaces) = 0) or (m = Length(Opcode.Spaces) + 1) Then
          begin
            SetLength(Opcode.Spaces, Length(Opcode.Spaces) + 1);
            Opcode.Spaces[Length(Opcode.Spaces)] := S[n];
          end;
        end;
      end;
    end;
  end;
  Opcode.Footer := L;
  Opcode.Fmt := Opcode.Fmt + L;
  Result := True;
end;


procedure TOpcodeList.ExtractValue(var V: Integer; P: PByte; M: TByteArray; BigEndian: Boolean = False);
var n, Incr, Num: Integer;
begin
  //If Length(B) <> Length(M) Then
  //  raise ECreateError.Create('The size of the mask and the data do not match (%d/%d)',
  //    [Length(B), Length(M)], FCreateError);
  Num := 0;
  V   := 0;
  If BigEndian Then
  begin
    n := High(M);
    Incr := -1;
    Inc(P, High(M));
  end else
  begin
    n := Low(M);
    Incr := 1;
  end;
  While (n <= High(M)) and (n >= Low(M)) do
  begin
    If M[n] <> 0 Then
      Inc(Num, GetByteAsMask(V, P^, M[n], Num));
    Inc(n, Incr);
    Inc(P, Incr);
  end;
end;

function TOpcodeList.GetEnumElement(Enum: TEnum; Index: Integer): WideString;
var n: Integer;
begin
  For n := 0 To High(Enum) do
  begin
    If Enum[n].Index = Index Then
    begin
      Result := Enum[n].Str;
      Exit;
    end;
  end;
  Result := IntToStr(Index);
end;

function TOpcodeList.GetString(Index: Integer; P: PByte{; BigEndian: Boolean = False}): WideString;
var n,V: Integer; Fmt: WideString;
begin
  Result := '';
  For n := 0 To High(FOpcodes[Index].Values) do
  With FOpcodes[Index].Values[n] do
  begin
    ExtractValue(V, P, Mask, FOpcodes[Index].Big{, BigEndian});
    If Len > 0 Then
      Fmt := WideFormat('%s%%%d.%d%s', [Pre, Len, Len, cChar[ValType]])
    else
      Fmt := WideFormat('%s%%%s', [Pre, cChar[ValType]]);
    Case ValType of
      dmDec, dmHex:  Result := WideFormat('%s%s',[Result, WideFormat(Fmt, [V])]);
      dmChar:        Result := WideFormat('%s%s',[Result, WideFormat(Fmt, [Char(V)])]);
      dmEnum:        Result := WideFormat('%s%s',[Result, WideFormat(Fmt, [GetEnumElement(Enum, V)])]);
    end;
  end; 
  Result := Result + FOpcodes[Index].Footer;
end;

Function TOpcodeList.GetByteAsMask(var V: Integer; B, M: Byte; Num: Integer): Integer;
var n, I: Integer;
begin
  Result := 0;
  For n := 0 To 7 do If Boolean((M SHR n) and 1) Then
  begin
    I := (B SHR n) and 1;
    I := I SHL Num;
    V := V or I;
    Inc(Result);
    Inc(Num);
  end;
end;

Function TOpcodeList.SetByteAsMask(V: Integer; var B: Byte; M: Byte; Num: Integer): Integer;
var n, I: Integer;
begin
  Result := 0;
  For n := 0 To 7 do If Boolean((M SHR n) and 1) Then
  begin
    I := (V SHR Num) and 1;
    I := I SHL n;
    B := B or I;
    Inc(Result);
    Inc(Num);
  end;
end;

function TOpcodeList.OpcodeLen(Index: Integer): Integer;
begin
  Result := Length(FOpcodes[Index].Mask);
end;

procedure TTable.ClearTable;
var n: Integer;
begin
  For n := 0 To High(FTable) do With FTable[n] do
  begin
    Finalize(Strr);
    Finalize(Data);
    Finalize(Indexes);
  end;
  Finalize(FTable);
  Finalize(FPropertyList);
  FOpcodeList.Clear;
end;

destructor TTable.Destroy;
begin
  ClearTable;
  Inherited;
end;

function TOpcodeList.Count: Integer;
begin
  Result := Length(FOpcodes);
end;

function TOpcodeList.GetData(Index: Integer; var D: TByteArray; S: PWideChar; Len: Integer): Integer;
var I: TIntArray; n, m, Num: Integer;
begin
  Result := -1;
  If GetValues(Index, I, S, Len) >= 0 Then With FOpcodes[Index] do
  begin
    Num := 0;
    SetLength(D, Length(Data));
    For n := 0 To High(Data) do
      D[n] := Data[n];
    For m := 0 To High(Values) do With Values[m] do
    begin
      Num := 0;
      For n := 0 To High(D) do
        If Mask[n] > 0 Then
          Inc(Num, SetByteAsMask(I[m], D[n], Mask[n], Num));
    end;
    Result := Len;
  end;
end;

function TOpcodeList.GetValues(Index: Integer; var I: TIntArray; S: PWideChar; var L: Integer): Integer;
var V, n, m, P, Cur, Cnt, ELen: Integer; Str: WideString; Mode: TDataMode;

 Function InSpaces(C: WideChar): Boolean;
 var n: Integer;
 begin
  Result := True;
  For n := 1 To Length(FOpcodes[Index].Spaces) do
    If FOpcodes[Index].Spaces[n] = C Then
      Exit;
  Result := False;
 end;
 Function CompareStr(var CS: WideString): Boolean;
 //var n: Integer;
 begin
    Result := False;
    n := 1;
    While (n <= Length(CS)) and (P < L) do
    begin
      If S[P] = CS[n] Then
      begin
        Inc(P);
        Inc(n);
      end else
      If InSpaces(S[P]) Then
        Inc(P)
      else
        Exit;
    end;
    While InSpaces(S[P]) and (P < L) do Inc(P);
    Result := True;
 end;

const
  cMax: Array[TDataMode] of Integer = (11, 8, -1, -1);
  cCharSet: Array[TDataMode] of TCharSet =
  (['0'..'9'], ['0'..'9','a'..'f','A'..'F'],[],[]);
begin
  Result := -1;
  P := 0;
  SetLength(I, Length(FOpcodes[Index].Values));
  With FOpcodes[Index] do
  For V := 0 To High(Values) do With Values[V] do
  begin
    Mode := ValType;
    If (not CompareStr(Pre)) or (n <= Length(Pre)) Then Exit;
    Case Mode of
      dmEnum:
      begin
        n := L - P;
        I[V] := GetEnumIndex(Enum, @S[P], n);
        If I[V] = -1 Then Exit;
        Inc(P, n);
      end;
      dmDec, dmHex:
      begin
        If Len <= 0 Then Cnt := cMax[ValType]
        else Cnt := Len;
        Str := '';
        For Cur := P To P + Cnt - 1 do
          If (Char(S[Cur]) in cCharSet[ValType])
          or ((ValType = dmDec) and (Cur = P) and (S[Cur] = '-')) Then
            Str := Str + S[Cur]
          else If Len > 0 Then
            Exit
          else
            break;
        P := Cur;
      end;
      dmChar:
      begin
        For n := 0 To Len - 2 do
          If S[P + n] <> ' ' Then
            Exit
          else
            Inc(P);
        I[V] := Integer(S[P]);
        Inc(P);
      end;
    end;
    //n := 1;
    //L := Cur;
    Case ValType of
      dmDec:  Val(Str, I[V], n);
      dmHex:  Val('$'+Str, I[V], n);
    end;
  end;
  If not CompareStr(FOpcodes[Index].Footer) Then Exit;
  Result := Length(FOpcodes[Index].Values);
  L := P;
  
end;

function TOpcodeList.GetEnumIndex(Enum: TEnum; S: PWideChar; var Len: Integer): Integer;
var n: Integer; Str: String;
begin
  Result := -1;
  For n := 0 To High(Enum) do With Enum[n] do
    If (Length(Str) <= Len) and CompareMem(@Str[1], S, Length(Str) * 2) Then
      break;
  If n < Length(Enum) Then
  begin
    Result := Enum[n].Index;
    Len := Length(Enum[n].Str);
  end else
  begin    
    If Len > 12 Then Len := 12;
    SetLength(Str, Len);
    For n := 0 To Len - 1 do
    If Char(S[n]) in ['0'..'9','a'..'f','A'..'F','$','X','x','-','+'] Then
      Str[n + 1] := Char(S[n])
    else
      break;
    SetLength(Str, n);
    Val(Str, Result, n);
    If n <> 0 Then
      Result := -1;
    Len := Length(Str);
  end;

end;

function TTable.IsComment(const S: WideString): Boolean;
var n: Integer;
begin
  Result := False;
  For n := 1 To Length(S) do
    If S[n] > ' ' Then
      break;
  If n > Length(S) Then Exit;
  If (S[n] = ';') or ((Length(S) - n >= 1) and (S[n]='/') and (S[n+1]='/')) Then
    Result := True;
end;

procedure TGameTextSet.RemoveItem(Index: Integer);
var n: Integer;
begin
  If (Index >= 0) and (Index < Length(FItems)) Then
  begin
    DelinkChildrensOfBlock(Index, 0, FItems[Index].Count - 1);
    FItems[Index].Free;
    For n := Index to High(FItems) - 1 do
      FItems[n] := FItems[n + 1];
    SetLength(FItems, High(FItems));
    CalculateIndexes;
  end;
end;

procedure TGameTextSet.RemoveItem(Item: TGameText);
var Index: Integer;
begin
  For Index := 0 To High(FItems) do
    If FItems[Index] = Item Then
      break;
  If Index < Length(FItems) Then
    RemoveItem(Index);
end;

procedure TGameTextSet.CalculateIndexes;
var n: Integer;
begin
  For n := 0 To High(FItems) do
    FItems[n].FIndex := n;
end;

procedure TTable.AddProperty(Name: String; Mode: TFontPropertyMode; Value, Flags: Integer);
var n: Integer;
begin
  n := Length(FPropertyList);
  SetLength(FPropertyList, n + 1);
  FPropertyList[n].Mode  := Mode;
  If Length(Name) > 15 Then
    SetLength(Name, 15);
  Move(Name[1], FPropertyList[n].Name, Length(Name) + 1);
  FPropertyList[n].Flags := Flags;
  FPropertyList[n].Value := Value;
end;

procedure TTable.ProcessProperty(S: String);
var Mode: TFontPropertyMode; Value, Flags: Integer; Name, SS, SV: String;
begin
  AddProperty(Name, Mode, Value, Flags);
  Name := GetPart(S, [#0..#31], 2);
  SS := GetPart(S, [#0..#31], 3);
  If SS = 'color' Then
  begin
    SV := GetPart(S, [#0..#31], 3);
    If SV = 'index' Then
      AddProperty(Name, fvColor, FONT_FLAG_INDEX);
  end else ;
  //end;

end;

Function ChangeEndian(V: LongWord; Size: Integer): LongWord;
var n: Integer; B, WB: ^Byte;
begin
  If Size < 2 Then Exit;
  If Size > 4 Then Size := 4;
  Result := 0;
  B := @V;
  WB := Pointer(LongWord(@Result) + Size - 1);

  For n := 1 To Size do
  begin
    WB^ := B^;
    Inc(B);
    Dec(WB);
  end;
  
end;

{ TLexer }

// Line - Code [Properties] [Mode] Eq [String]
// Property -
// Properties

function TLexer.DetectType(S: PWideChar;
  var Len: Integer): TLexemType;
var
  flagIdentifier,
  flagHexValue,
  flagDecValue,
  flagValue, valhex:     Boolean;
const
  sIdentifier = ['_', 'A'..'Z', 'a'..'z'];
  sHexValue   = ['A'..'F', 'a'..'f', '0'..'9'];
  sDecValue   = ['0'..'9'];
begin
  Len := 0;
  Result := ltUnknown;
  If S^ = #0 Then
  begin
    Result := ltStringEnd;
    Exit;
  end;
  While Word(S^) <= $20 do
  begin
    Inc(S);
    Inc(Len);
    If S^ = #0 Then break;
  end;
  If Len > 0 Then
  begin
    Result := ltVoid;
    Exit;
  end;
  If Char(S^) in ['.', '=', ':', '(', ')', '<', '>', ','] Then
  begin
    Case S^ of
      '=': Result := ltEq;
      '.': Result := ltDirective;
      ':': Result := ltMaskCheckEnd;
      '(': Result := ltScopeOpen;
      ')': Result := ltScopeClose;
      '<': Result := ltPropOpen;
      '>': Result := ltPropClose;
      ',': Result := ltSeparator;
    end;
    Len := 1;
    Exit;
  end;
  flagIdentifier := Char(S^) in sIdentifier;
  flagHexValue   := Char(S^) in sHexValue;
  flagDecValue   := Char(S^) in sDecValue;
  flagValue      := flagDecValue or (S^ = '$');
  valhex := True;
  If (S^ = '$') Then
  begin
  end else
  If (S^ = '0') and ((S[1] = 'x') or (S[1] = 'X')) Then
  begin
    flagHexValue := False;
    flagDecValue := False;
    Inc(S);
    Len := 1;
  end else
    valhex := False;
  if flagIdentifier or flagHexValue or flagDecValue or flagValue then
  begin
    Inc(Len);
    Inc(S);
    While True do
    begin
      if not (Char(S^) in sIdentifier + sDecValue) Then break;
      If flagHexValue Then flagHexValue := Char(S^) in sHexValue;
      If flagDecValue Then flagDecValue := Char(S^) in sDecValue;
      If flagValue Then
      begin
        If valhex Then
          flagValue := Char(S^) in sHexValue
        else
          flagValue := Char(S^) in sDecValue;
      end;
      Inc(S);
      Inc(Len);
    end;
    If flagIdentifier Then
      Result := ltIdentifier
    else if flagValue Then
      Result := ltValue;
    //else If flagHexValue Then
    //else If flagDecValue Then
    //else
    //  Result := ltIdentifier;
    If Result <> ltUnknown Then Exit;
  end;



  Len := 1;
end;

function TLexer.ParseString(const S: WideString): Integer;
var i, Pos, OldPos, Len: Integer; LexType: TLexemType;
begin
  FCount := 0;
  i := 0;
  Pos := 1;
  While (Pos <= Length(S)) And (i < Length(FLexems)) do
  begin
    LexType := DetectType(@S[Pos], Len);
    OldPos := Pos;
    Inc(Pos, Len);
    If LexType = ltVoid Then Continue;
    FLexems[i].Data := @S[OldPos];
    FLexems[i].Len := Len;
    FLexems[i].Lex := LexType;
    Inc(i);
  end;

  FCount := i;
  Result := FCount;
end;

procedure TTable.ProcessSearchIndexes;
var Dat, Str: Array of PTableRecord; i, j: Integer; CurIndex, Index: Integer; Rec: PTableRecord;
  S: PWideChar; SLen: Integer;
Procedure Swap(var R1, R2: PTableRecord);
var RT: PTableRecord;
begin
  RT := R1;
  R1 := R2;
  R2 := RT;
end;
begin
  SetLength(Dat, Length(FTable));
  SetLength(Str, Length(FTable));
  For i := 0 to High(FTable) do
  begin
    Dat[i] := @FTable[i];
    Str[i] := @FTable[i];
    FTable[i].NextForData   := nil;
    FTable[i].NextForString := nil;
  end;
  For i := 0 To High(FTable) do
  begin
    For j := i + 1 To High(FTable) do
    begin
      If Dat[i]^.RDataLen < Dat[j]^.RDataLen Then Swap(Dat[i], Dat[j]);
      If Str[i]^.RStrLen  < Str[j]^.RStrLen  Then Swap(Str[i], Str[j]);
    end;
  end;
  For i := 0 To High(FStringIndex) do
    FStringIndex[i] := nil;
  For i := 0 To High(Str) do With Str[i]^ do
  begin

    If IsOp Then
    begin
      If Length(FOpcodeList.FOpcodes[OpID].Values) > 0 Then
      begin
        S := PWideChar(FOpcodeList.FOpcodes[OpID].Values[0].Pre);
        SLen := Length(FOpcodeList.FOpcodes[OpID].Values[0].Pre);
      end else
      begin
        S := PWideChar(FOpcodeList.FOpcodes[OpID].Footer);
        SLen := Length(FOpcodeList.FOpcodes[OpID].Footer);
      end;
    end else
    begin
      S := PWideChar(Strr);
      SLen := Length(Strr);
    end;

    If SLen > 0 Then
      Index := Byte(S^)
    else
      Index := -1;

    If Index > 0 Then
    begin
      Rec := FStringIndex[Index];
      If Rec = nil Then
        FStringIndex[Index] := Str[i]
      else
      begin
        While Rec^.NextForString <> nil do Rec := Rec^.NextForString;
        Rec^.NextForString := Str[i];
      end;
    end else
    begin
      Rec^.NextForString := Str[i];
    end;
    Rec := Str[i];
  end;

end;

function TTable.TableCount: Integer;
begin
  Result := Length(FTable);
end;

Initialization
  Lexer := TLexer.Create;
Finalization
  Lexer.Free;
end.

