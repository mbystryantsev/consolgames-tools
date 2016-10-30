{-------------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: SynHighlighterBat.pas, released 2000-04-18.
The Original Code is based on the dmBatSyn.pas file from the
mwEdit component suite by Martin Waldenburg and other developers, the Initial
Author of this file is David H. Muir.
Unicode translation by Maël Hörz.
All Rights Reserved.

Contributors to the SynEdit and mwEdit projects are listed in the
Contributors.txt file.

Alternatively, the contents of this file may be used under the terms of the
GNU General Public License Version 2 or later (the "GPL"), in which case
the provisions of the GPL are applicable instead of those above.
If you wish to allow use of your version of this file only under the terms
of the GPL and not to allow others to use your version of this file
under the MPL, indicate your decision by deleting the provisions above and
replace them with the notice and other provisions required by the GPL.
If you do not delete the provisions above, a recipient may use your version
of this file under either the MPL or the GPL.

$Id: SynHighlighterBat.pas,v 1.14.2.6 2008/09/14 16:24:59 maelh Exp $

You may retrieve the latest version of this file at the SynEdit home page,
located at http://SynEdit.SourceForge.net

Known Issues:
-------------------------------------------------------------------------------}
{
@abstract(Provides a MS-DOS Batch file highlighter for SynEdit)
@author(David Muir <dhm@dmsoftware.co.uk>)
@created(Late 1999)
@lastmod(May 19, 2000)
The SynHighlighterBat unit provides SynEdit with a MS-DOS Batch file (.bat) highlighter.
The highlighter supports the formatting of keywords and parameters (batch file arguments).
}

{$IFNDEF QSYNHIGHLIGHTERBAT}
unit FFHighlighter;
{$ENDIF}

{$I SynEdit.inc}

interface

uses
{$IFDEF SYN_CLX}
  QGraphics,
  QSynEditTypes,
  QSynEditHighlighter,
  QSynUnicode,
{$ELSE}
  Graphics,
  SynEditTypes,
  SynEditHighlighter,
  SynUnicode,
{$ENDIF}
  SysUtils,
  Classes;

type
  TtkTokenKind = (tkComment, tkIdentifier, tkKey, tkNull, tkWord, tkSpace,
    tkUnknown, tkVariable);

  PIdentFuncTableFunc = ^TIdentFuncTableFunc;
  TIdentFuncTableFunc = function (Index: Integer): TtkTokenKind of object;

type
  TSynFFSyn = class(TSynCustomHighlighter)
  private
    //fIdentFuncTable: array[0..24] of TIdentFuncTableFunc;
    FTokenID:         TtkTokenKind;
    fCommentAttri:    TSynHighlighterAttributes;
    fIdentifierAttri: TSynHighlighterAttributes;
    fKeyAttri:        TSynHighlighterAttributes;
    fWordsAttri:      TSynHighlighterAttributes;
    fSpaceAttri:      TSynHighlighterAttributes;
    fVariableAttri:   TSynHighlighterAttributes;

    FWords:   Array of WideString;

    function AltFunc(Index: Integer): TtkTokenKind;
    function HashKey(Str: PWideChar): Cardinal;
    function IdentKind(MayBe: PWideChar): TtkTokenKind;
    procedure InitIdent;
    procedure CRProc;
    procedure CommentProc;
    procedure IdentProc;
    procedure LFProc;
    procedure NullProc;
    procedure WordsProc(ID: Integer);
    procedure SpaceProc;
    procedure UnknownProc;

    Function  IsCurrentWord(S: WideString): Boolean;

  protected
    function GetSampleSource: UnicodeString; override;
    function IsFilterStored: Boolean; override;
  public
    class function GetLanguageName: string; override;
    class function GetFriendlyLanguageName: UnicodeString; override;
  public
    constructor Create(AOwner: TComponent); override;        
    function GetDefaultAttribute(Index: integer): TSynHighlighterAttributes;
      override;
    function GetEol: Boolean; override;
    function GetTokenID: TtkTokenKind;
    function GetTokenAttribute: TSynHighlighterAttributes; override;
    function GetTokenKind: integer; override;
    procedure Next; override;
  published
    property CommentAttri: TSynHighlighterAttributes read fCommentAttri write fCommentAttri;
    property IdentifierAttri: TSynHighlighterAttributes read fIdentifierAttri write fIdentifierAttri;
    property KeyAttri: TSynHighlighterAttributes read fKeyAttri write fKeyAttri;
    property WordsAttri: TSynHighlighterAttributes read fWordsAttri write fWordsAttri;
    property SpaceAttri: TSynHighlighterAttributes read fSpaceAttri write fSpaceAttri;
    property VariableAttri: TSynHighlighterAttributes read fVariableAttri write fVariableAttri;

    procedure AddWord(S: WideString);
  end;

implementation

uses
{$IFDEF SYN_CLX}
  QSynEditStrConst;
{$ELSE}
  SynEditStrConst;
{$ENDIF}

{$Q-}
function TSynFFSyn.HashKey(Str: PWideChar): Cardinal;
begin
  Result := 0;
  while IsIdentChar(Str^) do
  begin
    Result := Result * 869 + Ord(Str^) * 61;
    inc(Str);
  end;
  Result := Result mod 25;
  fStringLen := Str - fToIdent;
end;
{$Q+}

function TSynFFSyn.IdentKind(MayBe: PWideChar): TtkTokenKind;
var
  Key: Cardinal;
begin
  {fToIdent := MayBe;
  Key := HashKey(MayBe);
  if Key <= High(fIdentFuncTable) then
    Result := fIdentFuncTable[Key](KeyIndices[Key])
  else
    Result := tkIdentifier;}
end;

procedure TSynFFSyn.InitIdent;
var
  i: Integer;
begin
  {for i := Low(fIdentFuncTable) to High(fIdentFuncTable) do
    if KeyIndices[i] = -1 then
      fIdentFuncTable[i] := AltFunc;}
end;

function TSynFFSyn.AltFunc(Index: Integer): TtkTokenKind;
begin
  Result := tkIdentifier
end;

constructor TSynFFSyn.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  fCaseSensitive := False;

  fCommentAttri := TSynHighlighterAttributes.Create(SYNS_AttrComment, SYNS_FriendlyAttrComment);
  fCommentAttri.Style := [fsItalic];
  fCommentAttri.Foreground := clNavy;
  AddAttribute(fCommentAttri);

  fIdentifierAttri := TSynHighlighterAttributes.Create(SYNS_AttrIdentifier, SYNS_FriendlyAttrIdentifier);
  AddAttribute(fIdentifierAttri);
  fKeyAttri := TSynHighlighterAttributes.Create(SYNS_AttrKey, SYNS_FriendlyAttrKey);
  fKeyAttri.Style := [fsBold];
  AddAttribute(fKeyAttri);

  fWordsAttri := TSynHighlighterAttributes.Create(SYNS_AttrNumber, SYNS_FriendlyAttrNumber);
  fWordsAttri.Style := [fsBold];
  //fWordsAttri.Foreground := clBlue;
  AddAttribute(fWordsAttri);

  fSpaceAttri := TSynHighlighterAttributes.Create(SYNS_AttrSpace, SYNS_FriendlyAttrSpace);
  AddAttribute(fSpaceAttri);
  fVariableAttri := TSynHighlighterAttributes.Create(SYNS_AttrVariable, SYNS_FriendlyAttrVariable);
  fVariableAttri.Foreground := clGreen;
  AddAttribute(fVariableAttri);
  SetAttributesOnChange(DefHighlightChange);
  InitIdent;
  fDefaultFilter := SYNS_FilterBatch;
end;

procedure TSynFFSyn.CRProc;
begin
  fTokenID := tkSpace;
  Inc(Run);
  if (fLine[Run] = #10) then Inc(Run);
end;

procedure TSynFFSyn.CommentProc;
begin
  {fTokenID := tkIdentifier;
  Inc(Run);
  if fLine[Run] = ':' then begin
    fTokenID := tkComment;
    repeat
      Inc(Run);
    until IsLineEnd(Run);
  end;}
end;

procedure TSynFFSyn.IdentProc;
begin
  fTokenID := IdentKind((fLine + Run));
  Inc(Run, fStringLen);
  while IsIdentChar(fLine[Run]) do inc(Run);
end;

procedure TSynFFSyn.LFProc;
begin
  fTokenID := tkSpace;
  inc(Run);
end;

procedure TSynFFSyn.NullProc;
begin
  fTokenID := tkNull;
  inc(Run);
end;

procedure TSynFFSyn.WordsProc(ID: Integer);
begin
  fTokenID := tkWord;
  Inc(Run, Length(FWords[ID]));
end;


procedure TSynFFSyn.SpaceProc;
begin
  fTokenID := tkSpace;
  repeat
    Inc(Run);
  until (fLine[Run] > #32) or IsLineEnd(Run);
end;

procedure TSynFFSyn.UnknownProc;
begin
  inc(Run);
  fTokenID := tkUnknown;
end;

procedure TSynFFSyn.Next;
var n: Integer;
begin
  fTokenPos := Run;

  For n := 0 To High(FWords) do
    if IsCurrentWord(FWords[n]) then
      break;

  If n < Length(FWords) Then
    WordsProc(n)
  else
  case fLine[Run] of
    #13: CRProc;
    //':': CommentProc;
    'A'..'Q', 'S'..'Z', 'a'..'q', 's'..'z', '_': IdentProc;
    #10: LFProc;
    #0: NullProc;
    //'0'..'9': WordsProc;
    //'R', 'r': REMCommentProc;
    #1..#9, #11, #12, #14..#32: SpaceProc;
    else
      UnknownProc;
  end;
  inherited;
end;

function TSynFFSyn.GetDefaultAttribute(Index: integer): TSynHighlighterAttributes;
begin
  case Index of
    SYN_ATTR_COMMENT:    Result := fCommentAttri;
    SYN_ATTR_IDENTIFIER: Result := fIdentifierAttri;
    SYN_ATTR_KEYWORD:    Result := fKeyAttri;
    SYN_ATTR_WHITESPACE: Result := fSpaceAttri;
  else
    Result := nil;
  end;
end;

function TSynFFSyn.GetEol: Boolean;
begin
  Result := Run = fLineLen + 1;
end;

function TSynFFSyn.GetTokenAttribute: TSynHighlighterAttributes;
begin
  case fTokenID of
    tkComment:        Result := fCommentAttri;
    tkIdentifier:     Result := fIdentifierAttri;
    tkKey:            Result := fKeyAttri;
    tkWord:           Result := fWordsAttri;
    tkSpace:          Result := fSpaceAttri;
    tkUnknown:        Result := fIdentifierAttri;
    tkVariable:       Result := fVariableAttri;
    else              Result := nil;
  end;
end;

function TSynFFSyn.GetTokenID: TtkTokenKind;
begin
  Result := fTokenId;
end;

function TSynFFSyn.GetTokenKind: integer;
begin
  Result := Ord(fTokenId);
end;

function TSynFFSyn.IsFilterStored: Boolean;
begin
  Result := fDefaultFilter <> SYNS_FilterBatch;
end;

class function TSynFFSyn.GetLanguageName: string;
begin
  Result := SYNS_LangBatch;
end;

function TSynFFSyn.GetSampleSource: UnicodeString;
begin
  Result := 'Crono: {83}{62}!'#13#10 +
            '-'#13#10 +
            'Marle: {AHTUNG}!'#13#10 +
            '--'#13#10 +
            '{???}'#13#10 +
            '// Îôèãåòü!';
end;

class function TSynFFSyn.GetFriendlyLanguageName: UnicodeString;
begin
  Result := SYNS_FriendlyLangBatch;
end;

procedure TSynFFSyn.AddWord(S: WideString);
begin
  SetLength(FWords, Length(FWords) + 1);
  FWords[High(FWords)] := SynWideLowerCase(S);
end;

function TSynFFSyn.IsCurrentWord(S: WideString): Boolean;
var n: Integer;
begin
  Result := False;
  For n := 1 To Length(S) do
    If (fLine[Run + n - 1] <> S[n]) Then
      Exit;
  If not IsWordBreakChar(fLine[Run + Length(S)]) Then Exit;
  Result := True;
end;

initialization
{$IFNDEF SYN_CPPB_1}
  RegisterPlaceableHighlighter(TSynFFSyn);
{$ENDIF}
end.
