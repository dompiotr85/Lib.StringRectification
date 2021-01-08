{===============================================================================

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

===============================================================================}

{-------------------------------------------------------------------------------
 String rectification utilities.

 Main aim of this library is to simplify conversions in Lazarus when passing
 strings to RTL or WinAPI - mainly to ensure the same code can be used in all
 compilers (Delphi, FPC 2.x.x, FPC 3.x.x) without a need for symbol checks.

 It also provides set of functions for string comparison that encapsulates
 some of the intricacies given by different approach in different compilers.

 For details about encodings refer to file EncodingNotes.txt that should
 be distributed with this library.

 Lib.StringRectification was tested in following IDE/compilers:

   Delphi 10.4.1 Sidney Architect (unicode, Windows)
   Lazarus 2.0.10 - FPC 3.2.0 (non-unicode, Windows)
   Lazarus 2.0.10 - FPC 3.2.0 (non-unicode, Linux)
   Lazarus 2.0.10 - FPC 3.2.0 (unicode, Windows)
   Lazarus 2.0.10 - FPC 3.2.0 (unicode, Linux)

 Tested compatible FPC modes:

   Delphi, DelphiUnicode, FPC (default), ObjFPC, TurboPascal

 WARNING - a LOT of assumptions were made when creating this library (most of it
 was written "blind", with no access to internet and documentation), so if you
 find any error or mistake, please contact the author.
 Also, if you are certain that some part, in here marked as dubious, is actually
 correct, let the author know.

 Version 0.1.2

 Copyright (c) 2018-2021, Piotr Domañski

 Last change:
   01-01-2021

 Changelog:
   For detailed changelog and history please refer to this git repository:
     https://github.com/dompiotr85/Lib.StringRectification

 Contacts:
   Piotr Domañski (dom.piotr.85@gmail.com)

 Dependencies:
   JEDI common files (https://github.com/project-jedi/jedi)
-------------------------------------------------------------------------------}

{$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
/// <summary>
///   <para>
///     Main aim of this library is to simplify conversions in Lazarus when
///     passing strings to RTL or WinAPI - mainly to ensure the same code can
///     be used in all compilers (Delphi, FPC 2.x.x, FPC 3.x.x) without a
///     need for symbol checks.
///   </para>
///   <para>
///     It also provides set of functions for string comparison that
///     encapsulates some of the intricacies given by different approach in
///     different compilers.
///   </para>
///   <para>
///     For details about encodings refer to file EncodingNotes.txt that
///     should be distributed with this library.
///   </para>
/// </summary>
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
{ I do not have any good information on non-windows Delphi, therefore this
  entire unit is marked as platform in those systems as a warning. }
unit StringRectification{$IF NOT DEFINED(FPC) AND NOT (DEFINED(WINDOWS) OR DEFINED(MSWINDOWS))} platform{$IFEND};

{$INCLUDE StringRectification.Config.inc}

{$IF DEFINED(WINDOWS) OR DEFINED(MSWINDOWS)}
 {$DEFINE Windows}
{$IFEND}

{$IFDEF FPC}
 { Don't set $MODE, leave the unit mode-agnostic. }
 {$MODESWITCH RESULT+}
 {$MODESWITCH DEFAULTPARAMETERS+}
 {$IFDEF SR_UseInline}
  {$INLINE ON}
  {$DEFINE CanInline}
 {$ENDIF !SR_UseInline}

 {$IFDEF SR_BareFPC}
  {$DEFINE BARE_FPC}
 {$ENDIF !SR_BareFPC}

 {$IFDEF LCL}  // Clearly not bare FPC...
  {$MESSAGE INFO 'Lazarus LCL detected, can not compile bare FPC!'}
  {$UNDEF BARE_FPC}
 {$ENDIF !LCL}
{$ELSE}
 {$IF CompilerVersion >= 17}  // Delphi 2005+
  {$IFDEF SR_UseInline}
   {$DEFINE CanInline}
  {$ENDIF !SR_UseInline}
 {$ELSE}
  {$UNDEF CanInline}
 {$IFEND}
{$ENDIF}

{$H+} // Explicitly activate long strings.

interface

type
{$IF NOT DECLARED(UnicodeString)}
  UnicodeString = WideString;
{$ELSE}
  // don't ask, it must be here.
  UnicodeString = System.UnicodeString;
{$IFEND}

{$IFNDEF FPC}
const
  FPC_FULLVERSION = Integer(0);
{$ENDIF !FPC}

{- Auxiliary public functions declaration  - - - - - - - - - - - - - - - - - - }
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

{$IFDEF SUPPORTS_REGION}{$REGION 'Auxiliary public functions declaration'}{$ENDIF}
{ Following two functions are present in newer Delphi where they replace
  deprecated UTF8Decode/UTF8Encode. They are here for use in older compilers. }

{$IF NOT DECLARED(UTF8ToString)}
{$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
/// <summary>
///   <para>
///     Converts a UTF-8 encoded string to a UnicodeString.
///   </para>
///   <para>
///     Call <b>UTF8ToString</b> to convert a UTF-8 encoded string to a
///     UnicodeString. <c>Str</c> is a string or an array of UTF-8 encoded
///     characters.
///   </para>
///   <para>
///     The result of the function is the corresponding decoded string value.
///   </para>
/// </summary>
/// <param name="Str">
///   String or an array of UTF-8 encoded characters.
/// </param>
/// <returns>
///   Returns converted UnicodeString.
/// </returns>
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
function UTF8ToString(const Str: UTF8String): UnicodeString; {$IFDEF CanInline}inline;{$ENDIF}
 {$DEFINE Implement_UTF8ToString}
{$IFEND}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

{$IF NOT DECLARED(StringToUTF8)}
{$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
/// <summary>
///   <para>
///     Converts a string to UTF-8 encoded string.
///   </para>
///   <para>
///     Call <b>StringToUTF8</b> to convert a string to a UTF-8 encoded string.
///     string.
///   </para>
/// </summary>
/// <param name="Str">
///   Unicode string or an array of Unicode characters.
/// </param>
/// <returns>
///   Returns converted UTF-8 encoded string.
/// </returns>
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
function StringToUTF8(const Str: UnicodeString): UTF8String; {$IFDEF CanInline}inline;{$ENDIF}
 {$DEFINE Implement_StringToUTF8}
{$IFEND}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

{$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
/// <summary>
///   Returns True when single-byte strings (AnsiString, ShortString, String in
///   some cases) are encoded using UTF-8 encoding, False otherwise.
/// </summary>
/// <returns>
///   Returns True when single-byte string are encoded using UTF-8 encoding,
///   False otherwise.
/// </returns>
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
function UTF8AnsiStrings: Boolean; {$IFDEF CanInline}inline;{$ENDIF}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

{$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
/// <summary>
///   Returns True when default strings (type String) are UTF-8 encoded ansi
///   strings, False in all other cases (eg. when in Unicode).
/// </summary>
/// <returns>
///   Returns True when default strings (type String) are UTF-8 encoded ansi
///   strings, False in all other cases (eg. when in Unicode).
/// </returns>
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
function UTF8AnsiDefaultStrings: Boolean; {$IFDEF CanInline}inline;{$ENDIF}
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}

{- Default string <-> explicit string conversion functions - - - - - - - - - - }
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

{$IFDEF SUPPORTS_REGION}{$REGION 'Default string <-> explicit string conversion functions'}{$ENDIF}
{ Depending on some use cases, the actually used string type might change,
  therefore following type aliases are introduced for such cases. }
type
{$IF DEFINED(FPC) AND DEFINED(Unicode)}
  TRTLString = AnsiString;
  TRTLChar = AnsiChar;
  PRTLChar = PAnsiChar;
{$ELSE}
  TRTLString = String;
  TRTLChar = Char;
  PRTLChar = PChar;
{$IFEND}

  {- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

{$IF NOT DEFINED(FPC) AND DEFINED(Windows) AND Defined(Unicode)}
  TWinString = WideString;
  TWinChar = WideChar;
  PWinChar = PWideChar;

  TSysString = WideString;
  TSysChar = WideChar;
  PSysChar = PWideChar;
{$ELSE}
  TWinString = AnsiString;
  TWinChar = AnsiChar;
  PWinChar = PAnsiChar;

  TSysString = AnsiString;
  TSysChar = AnsiChar;
  PSysChar = PAnsiChar;
{$IFEND}

  {- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

{$IFDEF FPC}
 {$IF FPC_FULLVERSION >= 207021}
  TGUIString = type AnsiString(CP_UTF8);
  TGUIChar = AnsiChar;
  PGUIChar = PAnsiChar;
 {$ELSE}
  TGUIString = AnsiString;
  TGUIChar = AnsiChar;
  PGUIChar = PAnsiChar;
 {$IFEND}
{$ELSE !FPC}
  TGUIString = String;
  TGUIChar = Char;
  PGUIChar = PChar;
{$ENDIF !FPC}

  {- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

{$IF DEFINED(FPC) AND NOT DEFINED(Windows) AND DEFINED(Unicode)}
  TCSLString = AnsiString;
  TCSLChar = AnsiChar;
  PCSLChar = PAnsiChar;
{$ELSE}
  TCSLString = String;
  TCSLChar = Char;
  PCSLChar = PChar;
{$IFEND}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

{$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
/// <summary>
///   Convers a string to a short string.
/// </summary>
/// <param name="Str">
///   A string that will be converted to short string.
/// </param>
/// <returns>
///   Returns converted ShortString.
/// </returns>
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
function StrToShort(const Str: String): ShortString; {$IF DEFINED(CanInline) AND DEFINED(FPC)}inline;{$IFEND}

{$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
/// <summary>
///   Convers a short string to a string.
/// </summary>
/// <param name="Str">
///   A short string that will be converted to string.
/// </param>
/// <returns>
///   Returns converted string.
/// </returns>
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
function ShortToStr(const Str: ShortString): String; {$IF DEFINED(CanInline) AND DEFINED(FPC)}inline;{$IFEND}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

{$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
/// <summary>
///   Converts a string to an AnsiString.
/// </summary>
/// <param name="Str">
///   A string that will be converted to AnsiString.
/// </param>
/// <returns>
///   Returns converted AnsiString.
/// </returns>
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
function StrToAnsi(const Str: String): AnsiString; {$IF DEFINED(CanInline) AND DEFINED(FPC)}inline;{$IFEND}

{$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
/// <summary>
///   Converts an AnsiString to a string.
/// </summary>
/// <param name="Str">
///   An AnsiString that will be converted to a string.
/// </param>
/// <returns>
///   Returns converted string.
/// </returns>
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
function AnsiToStr(const Str: AnsiString): String; {$IF DEFINED(CanInline) AND DEFINED(FPC)}inline;{$IFEND}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

{$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
/// <summary>
///   Converts a string to UTF-8 encoded string.
/// </summary>
/// <param name="Str">
///   A string that will be converted to UTF-8 encoded string.
/// </param>
/// <returns>
///   Returns converted UTF-8 encoded string.
/// </returns>
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
function StrToUTF8(const Str: String): UTF8String; {$IFDEF CanInline}inline;{$ENDIF}

{$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
/// <summary>
///   Converts UTF-8 encoded string to a string.
/// </summary>
/// <param name="Str">
///   UTF-8 encoded string that will be converted to a string.
/// </param>
/// <returns>
///   Returns converted string.
/// </returns>
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
function UTF8ToStr(const Str: UTF8String): String; {$IFDEF CanInline}inline;{$ENDIF}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

{$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
/// <summary>
///   Converts a string to a WideString.
/// </summary>
/// <param name="Str">
///   A string that will be converted to a WideString.
/// </param>
/// <returns>
///   Returns converted WideString.
/// </returns>
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
function StrToWide(const Str: String): WideString; {$IFDEF CanInline}inline;{$ENDIF}

{$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
/// <summary>
///   Converts a WideString to a string.
/// </summary>
/// <param name="Str">
///   A WideString that will be converted to a string.
/// </param>
/// <returns>
///   Returns converted string.
/// </returns>
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
function WideToStr(const Str: WideString): String; {$IFDEF CanInline}inline;{$ENDIF}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

{$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
/// <summary>
///   Converts a string to a UnicodeString.
/// </summary>
/// <param name="Str">
///   A string that will be converted to a UnicodeString.
/// </param>
/// <returns>
///   Returns converted UnicodeString.
/// </returns>
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
function StrToUnicode(const Str: String): UnicodeString; {$IFDEF CanInline}inline;{$ENDIF}

{$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
/// <summary>
///   Converts a UnicodeString to a string.
/// </summary>
/// <param name="Str">
///   A UnicodeString that will be converted to a string.
/// </param>
/// <returns>
///   Returns converted string.
/// </returns>
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
function UnicodeToStr(const Str: UnicodeString): String; {$IFDEF CanInline}inline;{$ENDIF}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

{$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
/// <summary>
///   Converts a string to a RTL string.
/// </summary>
/// <param name="Str">
///   A string that will be converted to a RTL string.
/// </param>
/// <returns>
///   Returns converted TRTLString.
/// </returns>
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
function StrToRTL(const Str: String): TRTLString; {$IFDEF CanInline}inline;{$ENDIF}

{$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
/// <summary>
///   Converts a RTL string to a string.
/// </summary>
/// <param name="Str">
///   A RTL string that will be converted to a string.
/// </param>
/// <returns>
///   Returns converted string.
/// </returns>
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
function RTLToStr(const Str: TRTLString): String; {$IFDEF CanInline}inline;{$ENDIF}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

{$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
/// <summary>
///   Converts a string to a GUI string.
/// </summary>
/// <param name="Str">
///   A string that will be converted to a GUI string.
/// </param>
/// <returns>
///   Returns converted TGUIString.
/// </returns>
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
function StrToGUI(const Str: String): TGUIString; {$IFDEF CanInline}inline;{$ENDIF}

{$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
/// <summary>
///   Converts a GUI string to a string.
/// </summary>
/// <param name="Str">
///   A GUI string that will be converted to a string.
/// </param>
/// <returns>
///   Returns converted string.
/// </returns>
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
function GUIToStr(const Str: TGUIString): String; {$IFDEF CanInline}inline;{$ENDIF}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

{$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
/// <summary>
///   Converts a string to an AnsiString.
/// </summary>
/// <param name="Str">
///   A string that will be converted to an AnsiString.
/// </param>
/// <returns>
///   Returns converted AnsiString.
/// </returns>
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
function StrToWinA(const Str: String): AnsiString; {$IF DEFINED(CanInline) AND DEFINED(FPC)}inline;{$IFEND}

{$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
/// <summary>
///   Converts an AnsiString to a string.
/// </summary>
/// <param name="Str">
///   An AnsiString that will be converted to a string.
/// </param>
/// <returns>
///   Returns converted string.
/// </returns>
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
function WinAToStr(const Str: AnsiString): String; {$IF DEFINED(CanInline) AND DEFINED(FPC)}inline;{$IFEND}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

{$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
/// <summary>
///   Converts a string to a WideString.
/// </summary>
/// <param name="Str">
///   A string that will be converted to a WideString.
/// </param>
/// <returns>
///   Returns converted WideString.
/// </returns>
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
function StrToWinW(const Str: String): WideString; {$IFDEF CanInline}inline;{$ENDIF}

{$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
/// <summary>
///   Converts a WideString to a string.
/// </summary>
/// <param name="Str">
///   A WideString that will be converted to a string.
/// </param>
/// <returns>
///   Returns converted string.
/// </returns>
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
function WinWToStr(const Str: WideString): String; {$IFDEF CanInline}inline;{$ENDIF}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

{$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
/// <summary>
///   Converts a string to a TWinString.
/// </summary>
/// <param name="Str">
///   A string that will be converted to a TWinString.
/// </param>
/// <returns>
///   Returns converted TWinString.
/// </returns>
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
function StrToWin(const Str: String): TWinString; {$IFDEF CanInline}inline;{$ENDIF}

{$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
/// <summary>
///   Converts a TWinString to a string.
/// </summary>
/// <param name="Str">
///   A TWinString that will be converted to a string.
/// </param>
/// <returns>
///   Returns converted string.
/// </returns>
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
function WinToStr(const Str: TWinString): String; {$IFDEF CanInline}inline;{$ENDIF}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

{$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
/// <summary>
///   Converts a string to a TCSLString.
/// </summary>
/// <param name="Str">
///   A string that will be converted to TCSLString.
/// </param>
/// <returns>
///   Returns converted TCSLString.
/// </returns>
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
function StrToCsl(const Str: String): TCSLString; {$IFDEF CanInline}inline;{$ENDIF}

{$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
/// <summary>
///   Converts a TCSLString to a string.
/// </summary>
/// <param name="Str">
///   A TCSLString that will be converted to a string.
/// </param>
/// <returns>
///   Returns converted string.
/// </returns>
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
function CslToStr(const Str: TCSLString): String; {$IFDEF CanInline}inline;{$ENDIF}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

{$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
/// <summary>
///   Converts a string to a TSysString.
/// </summary>
/// <param name="Str">
///   A string that will be converted to a TSysString.
/// </param>
/// <returns>
///   Returns converted TSysString.
/// </returns>
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
function StrToSys(const Str: String): TSysString; {$IFDEF CanInline}inline;{$ENDIF}

{$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
/// <summary>
///   Converts a TSysString to a string.
/// </summary>
/// <param name="Str">
///   A TSysString that will be converted to a string.
/// </param>
/// <returns>
///   Returns converted string.
/// </returns>
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
function SysToStr(const Str: TSysString): String; {$IFDEF CanInline}inline;{$ENDIF}
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}

{- Explicit string comparison functions declaration  - - - - - - - - - - - - - }
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

{$IFDEF SUPPORTS_REGION}{$REGION 'Explicit string comparison functions declaration'}{$ENDIF}
{$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
/// <summary>
///   Compares two strings which are of ShortString type. If CaseSensitive flag
///   is set to True, comparing will be character's case sensitive.
/// </summary>
/// <param name="A">
///   First string of ShortString type.
/// </param>
/// <param name="B">
///   Second string of ShortString type.
/// </param>
/// <param name="CaseSensitive">
///   CaseSensitive flag.
/// </param>
/// <returns>
///   Returns a value less than 0 if A < B, a value greater than 0 if A > B, and
///   0 if A = B.
/// </returns>
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
function ShortStringCompare(const A, B: ShortString; CaseSensitive: Boolean): Integer;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

{$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
/// <summary>
///   Compares two strings which are of AnsiString type. If CaseSensitive flag
///   is set to True, comparing will be character's case sensitive.
/// </summary>
/// <param name="A">
///   First string of AnsiString type.
/// </param>
/// <param name="B">
///   Second string of AnsiString type.
/// </param>
/// <param name="CaseSensitive">
///   CaseSensitive flag.
/// </param>
/// <returns>
///   Returns a value less than 0 if A < B, a value greater than 0 if A > B, and
///   0 if A = B.
/// </returns>
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
function AnsiStringCompare(const A, B: AnsiString; CaseSensitive: Boolean): Integer;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

{$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
/// <summary>
///   Compares two strings which are UTF-8 encoded string type. If CaseSensitive
///   flag is set to True, comparing will be character's case sensitive.
/// </summary>
/// <param name="A">
///   First string of UTF-8 encoding string type.
/// </param>
/// <param name="B">
///   Second string of UTF-8 encoding string type.
/// </param>
/// <param name="CaseSensitive">
///   CaseSensitive flag.
/// </param>
/// <returns>
///   Returns a value less than 0 if A < B, a value greater than 0 if A > B, and
///   0 if A = B.
/// </returns>
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
function UTF8StringCompare(const A, B: UTF8String; CaseSensitive: Boolean): Integer;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

{$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
/// <summary>
///   Compares two strings which are WideString type. If CaseSensitive flag is
///   set to True, comparing will be character's case sensitive.
/// </summary>
/// <param name="A">
///   First string of WideString type.
/// </param>
/// <param name="B">
///   Second string of WideString type.
/// </param>
/// <param name="CaseSensitive">
///   CaseSensitive flag.
/// </param>
/// <returns>
///   Returns a value less than 0 if A < B, a value greater than 0 if A > B, and
///   0 if A = B.
/// </returns>
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
function WideStringCompare(const A, B: WideString; CaseSensitive: Boolean): Integer;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

{$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
/// <summary>
///   Compares two strings which are UnicodeString type. If CaseSensitive flag
///   is set to True, comparing will be character's case sensitive.
/// </summary>
/// <param name="A">
///   First string of UnicodeString type.
/// </param>
/// <param name="B">
///   Second string of UnicodeString type.
/// </param>
/// <param name="CaseSensitive">
///   CaseSensitive flag.
/// </param>
/// <returns>
///   Returns a value less than 0 if A < B, a value greater than 0 if A > B, and
///   0 if A = B.
/// </returns>
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
function UnicodeStringCompare(const A, B: UnicodeString; CaseSensitive: Boolean): Integer;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

{$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
/// <summary>
///   Compares two strings. Uf CaseSensitive flag is set to True, comparing will
///   be character's case sensitive.
/// </summary>
/// <param name="A">
///   First string.
/// </param>
/// <param name="B">
///   Second string.
/// </param>
/// <param name="CaseSensitive">
///   CaseSensitive flag.
/// </param>
/// <returns>
///   Returns a value less than 0 if A < B, a value greater than 0 if A > B, and
///   0 if A = B.
/// </returns>
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
function StringCompare(const A, B: String; CaseSensitive: Boolean): Integer;
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}

implementation

uses
  {$IFDEF HAS_UNITSCOPE}System.SysUtils{$ELSE}SysUtils{$ENDIF},
{$IF NOT DEFINED(FPC) AND (CompilerVersion >= 20)} { Delphi 2009+ }
  {$IFDEF HAS_UNITSCOPE}System.AnsiStrings{$ELSE}AnsiStrings{$ENDIF},
{$IFEND}
{$IFDEF Windows}
  {$IFDEF HAS_UNITSCOPE}Winapi.Windows{$ELSE}Windows{$ENDIF}
{$ENDIF !Windows};

{- Auxiliary public functions implementation - - - - - - - - - - - - - - - - - }
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

{$IFDEF SUPPORTS_REGION}{$REGION 'Auxiliary public functions implementation'}{$ENDIF}
{$IFDEF Implement_UTF8ToString}
function UTF8ToString(const Str: UTF8String): UnicodeString;
begin
  Result := UTF8Decode(Str);
end;
{$ENDIF}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

{$IFDEF Implement_StringToUTF8}
function StringToUTF8(const Str: UnicodeString): UTF8String;
begin
  Result := UTF8Encode(Str);
end;
{$ENDIF}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function UTF8AnsiStrings: Boolean;
begin
{$IFDEF FPC}
  { FPC. }
 {$IFDEF Windows}
  { Check for FPC version. }
  {$IF FPC_FULLVERSION >= 20701}
  { New FPC, version 2.7.1 and newer. }
  Result := (StringCodePage(AnsiString('')) = CP_UTF8);
  {$ELSE}
  { Old FPC (prior to 2.7.1), everything is assumed to be ansi CP. }
  Result := False;
  {$IFEND}
 {$ELSE !Windows}
  { In linux, everything is assumed to be UTF-8. }
  Result := True;
 {$ENDIF !Windows}
{$ELSE !FPC}
  { Delphi. }
  Result := {$IFDEF Windows}False{$ELSE}True{$ENDIF};
{$ENDIF !FPC}
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function UTF8AnsiDefaultStrings: Boolean;
begin
{$IFDEF Unicode}
  { Strings are encoded using UTF-16. }
  Result := False;
{$ELSE !Unicode}
 {$IFDEF FPC}
  { FPC. }
  {$IFDEF Windows}
  { Windows. }
   {$IF FPC_FULLVERSION >= 20701}
  Result := (StringCodePage(AnsiString('')) = CP_UTF8);
   {$ELSE}
    {$IFDEF BARE_FPC}
  Result := (GetACP = CP_UTF8);
    {$ELSE !BARE_FPC}
  Result := True;
    {$ENDIF !BARE_FPC}
   {$IFEND}
  {$ELSE !Windows}
  { Linux. }
  Result := True;
  {$ENDIF !Windows}
 {$ELSE !FPC}
  { Delphi. }
  Result := {$IFDEF Windows}False{$ELSE}True{$ENDIF};
 {$ENDIF !FPC}
{$ENDIF !Unicode}
end;
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}

{- Internal functions implementation - - - - - - - - - - - - - - - - - - - - - }
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

{$IFDEF SUPPORTS_REGION}{$REGION 'Internal functions implementation'}{$ENDIF}
{$IFDEF Windows}
type
  PUnicodeChar = PWideChar;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function UnicodeToAnsiCP(const Str: UnicodeString; CodePage: UINT = CP_ACP): AnsiString;
begin
  if (Length(Str) > 0) then
  begin
    SetLength(Result, WideCharToMultiByte(CodePage, 0, PUnicodeChar(Str), Length(Str), nil, 0, nil, nil));
    WideCharToMultiByte(CodePage, 0, PUnicodeChar(Str), Length(Str), PAnsiChar(Result), Length(Result) * SizeOf(AnsiChar), nil, nil);
 {$IF DEFINED(FPC) AND (FPC_FULLVERSION >= 20701)}
    SetCodePage(RawByteString(Result), CodePage, False);
 {$IFEND}
  end else
    Result := '';
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function AnsiCPToUnicode(const Str: AnsiString; CodePage: UINT = CP_ACP): UnicodeString;
const
  ExclCodePages: array[0..19] of Word = (
    50220, 50221, 50222, 50225, 50227, 50229, 52936, 54936, 57002, 57003, 57004,
    57005, 57006, 57007, 57008, 57009, 57010, 57011, 65000, 42);
var
  I: Integer;
  Flags: DWORD;
begin
  if (Length(Str) > 0) then
  begin
    Flags := MB_PRECOMPOSED;
    for I := Low(ExclCodePages) to High(ExclCodePages) do
      if (CodePage = ExclCodePages[I]) then
      begin
        Flags := 0;

        Break{for I};
      end;

    SetLength(Result, MultiByteToWideChar(CodePage, Flags, PAnsiChar(Str), Length(Str) * SizeOf(AnsiChar), nil, 0));
    MultiByteToWideChar(CodePage, Flags, PAnsiChar(Str), Length(Str) * SizeOf(AnsiChar), PUnicodeChar(Result), Length(Result));
  end else
    Result := '';
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function UTF8ToAnsiCP(const Str: UTF8String; CodePage: UINT = CP_ACP): AnsiString; {$IFDEF CanInline}inline;{$ENDIF}
begin
  Result := UnicodeToAnsiCP(UTF8ToString(Str), CodePage);
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function AnsiCPToUTF8(const Str: AnsiString; CodePage: UINT = CP_ACP): UTF8String; {$IFDEF CanInline}inline;{$ENDIF}
begin
  Result := StringToUTF8(AnsiCPToUnicode(Str, CodePage));
end;
{$ENDIF !Windows}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

{$IF DEFINED(Windows) AND NOT DEFINED(Unicode)}
function AnsiToConsole(const Str: AnsiString): AnsiString;
begin
  if (Length(Str) > 0) then
  begin
    Result := StrToWinA(Str);
    UniqueString(Result);

    If (not CharToOEMBuff(PAnsiChar(Result), PAnsiChar(Result), Length(Result))) then
      Result := '';

 {$IF DEFINED(FPC) AND (FPC_FULLVERSION >= 20701)}
    SetCodePage(RawByteString(Result), CP_OEMCP, False);
 {$IFEND}
  end else
    Result := '';
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function ConsoleToAnsi(const Str: AnsiString): AnsiString;
begin
  if (Length(Str) > 0) then
  begin
    Result := Str;
    UniqueString(Result);

    If OEMToCharBuff(PAnsiChar(Result), PAnsiChar(Result), Length(Result)) then
      Result := WinAToStr(Result)
    else
      Result := '';

 {$IF DEFINED(FPC) AND (FPC_FULLVERSION >= 20701)}
    SetCodePage(RawByteString(Result), CP_ACP, False);
 {$IFEND}
  end else
    Result := '';
end;
{$IFEND}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function UTF8ToUTF16(const Str: UTF8String): UnicodeString; {$IFDEF CanInline}inline;{$ENDIF}
begin
  Result := UTF8ToString(Str);
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function UTF16ToUTF8(const Str: UnicodeString): UTF8String; {$IFDEF CanInline}inline;{$ENDIF}
begin
  Result := StringToUTF8(Str);
end;
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}

{- Default string <-> explicit string conversion functions implementation  - - }
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

{$IFDEF SUPPORTS_REGION}{$REGION 'Default string <-> explicit string conversion functions implementation'}{$ENDIF}
function StrToShort(const Str: String): ShortString;
begin
{$IFDEF FPC}
 {$IFDEF Windows}
  {$IFDEF Unicode}
  { Unicode FPC on Windows. }
  if (UTF8AnsiStrings) then
    Result := ShortString(UTF16ToUTF8(Str))
  else
    Result := ShortString(UnicodeToAnsiCP(Str));
  {$ELSE !Unicode}
  { Non-Unicode FPC on Windows. }
  if ((UTF8AnsiDefaultStrings) and (not UTF8AnsiStrings)) then
    Result := ShortString(UTF8ToAnsiCP(Str))
  else
    Result := ShortString(Str);
  {$ENDIF !Unicode}
 {$ELSE !Windows}
  {$IFDEF Unicode}
  { Unicode FPC on Linux. }
  Result := ShortString(UTF16ToUTF8(Str));
  {$ELSE !Unicode}
  { Non-Unicode FPC on Linux. }
  Result := ShortString(Str);
  {$ENDIF !Unicode}
 {$ENDIF !Windows}
{$ELSE !FPC}
 {$IFDEF Windows}
  {$IFDEF Unicode}
  { Unicode Delphi on Windows. }
  Result := ShortString(UnicodeToAnsiCP(Str));
  {$ELSE !Unicode}
  { Non-Unicode Delphi on Windows. }
  Result := ShortString(Str);
  {$ENDIF !Unicode}
 {$ELSE !Windows}
  {$IFDEF Unicode}
  { Unicode Delphi on Linux. }
  Result := ShortString(UTF16ToUTF8(Str));
  {$ELSE !Unicode}
  { Non-Unicode Delphi on Linux. }
  Result := ShortString(Str);
  {$ENDIF !Unicode}
 {$ENDIF !Windows}
{$ENDIF !FPC}
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function ShortToStr(const Str: ShortString): String;
begin
{$IFDEF FPC}
 {$IFDEF Windows}
  {$IFDEF Unicode}
  { Unicode FPC on Windows. }
  if (UTF8AnsiStrings) then
    Result := String(UTF8ToUTF16(Str))
  else
    Result := String(AnsiCPToUnicode(Str));
  {$ELSE !Unicode}
  { Non-Unicode FPC on Windows. }
  if ((UTF8AnsiDefaultStrings) and (not UTF8AnsiStrings)) then
    Result := String(AnsiCPToUTF8(Str))
  else
    Result := String(Str);
  {$ENDIF !Unicode}
 {$ELSE !Windows}
  {$IFDEF Unicode}
  { Inicode FPC on Linux. }
  Result := String(UTF8ToUTF16(Str));
  {$ELSE !Unicode}
  { Non-Unicode FPC on Linux. }
  Result := String(Str);
  {$ENDIF !Unicode}
 {$ENDIF !Windows}
{$ELSE !FPC}
 {$IFDEF Windows}
  {$IFDEF Unicode}
  { Unicode Delphi on Windows. }
  Result := String(AnsiCPToUnicode(Str));
  {$ELSE !Unicode}
  { Non-Unicode Delphi on Windows. }
  Result := String(Str);
  {$ENDIF !Unicode}
 {$ELSE !Windows}
  {$IFDEF Unicode}
  { Unicode Delphi on Linux. }
  Result := String(UTF8ToUTF16(Str));
  {$ELSE !Unicode}
  { Non-Unicode Delphi on Linux. }
  Result := String(Str);
  {$ENDIF !Unicode}
 {$ENDIF !Windows}
{$ENDIF !FPC}
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function StrToAnsi(const Str: String): AnsiString;
begin
{$IFDEF FPC}
 {$IFDEF Windows}
  {$IFDEF Unicode}
  { Unicode FPC on Windows. }
  if (UTF8AnsiStrings) then
    Result := UTF16ToUTF8(Str)
  else
    Result := UnicodeToAnsiCP(Str);
  {$ELSE !Unicode}
  { Non-Unicode FPC on Windows. }
  if ((UTF8AnsiDefaultStrings) and (not UTF8AnsiStrings)) then
    Result := UTF8ToAnsiCP(Str)
  else
    Result := Str;
  {$ENDIF !Unicode}
 {$ELSE !Windows}
  {$IFDEF Unicode}
  { Unicode FPC on Linux. }
  Result := UTF16ToUTF8(Str);
  {$ELSE !Unicode}
  { Non-Unicode FPC on Linux. }
  Result := Str;
  {$ENDIF !Unicode}
 {$ENDIF !Windows}
{$ELSE !FPC}
 {$IFDEF Windows}
  {$IFDEF Unicode}
  { Unicode Delphi on Windows. }
  Result := UnicodeToAnsiCP(Str);
  {$ELSE !Unicode}
  { Non-Unicode Delphi on Windows. }
  Result := Str;
  {$ENDIF !Unicode}
 {$ELSE !Windows}
  {$IFDEF Unicode}
  { Unicode Delphi on Linux. }
  Result := UTF16ToUTF8(Str);
  {$ELSE !Unicode}
  { Non-Unicode Delphi on Linux. }
  Result := Str;
  {$ENDIF !Unicode}
 {$ENDIF !Windows}
{$ENDIF !FPC}
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function AnsiToStr(const Str: AnsiString): String;
begin
{$IFDEF FPC}
 {$IFDEF Windows}
  {$IFDEF Unicode}
  { Unicode FPC on Windows. }
  if (UTF8AnsiStrings) then
    Result := UTF8ToUTF16(Str)
  else
    Result := AnsiCPToUnicode(Str);
  {$ELSE !Unicode}
  { Non-Unicode FPC on Windows. }
  if ((UTF8AnsiDefaultStrings) and (not UTF8AnsiStrings)) then
    Result := AnsiCPToUTF8(Str)
  else
    Result := Str;
  {$ENDIF !Unicode}
 {$ELSE !Windows}
  {$IFDEF Unicode}
  { Unicode FPC on Linux. }
  Result := UTF8ToUTF16(Str);
  {$ELSE !Unicode}
  { Non-Unicode FPC on Linux. }
  Result := Str;
  {$ENDIF !Unicode}
 {$ENDIF !Windows}
{$ELSE !FPC}
 {$IFDEF Windows}
  {$IFDEF Unicode}
  { Unicode Delphi on Windows. }
  Result := AnsiCPToUnicode(Str);
  {$ELSE !Unicode}
  { Non-Unicode Delphi on Windows. }
  Result := Str;
  {$ENDIF !Unicode}
 {$ELSE !Windows}
  {$IFDEF Unicode}
  { Unicode Delphi on Linux. }
  Result := UTF8ToUTF16(Str);
  {$ELSE !Unicode}
  { Non-Unicode Delphi on Linux. }
  Result := Str;
  {$ENDIF !Unicode}
 {$ENDIF !Windows}
{$ENDIF !FPC}
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function StrToUTF8(const Str: String): UTF8String;
begin
{$IFDEF FPC}
 {$IFDEF Windows}
  {$IFDEF Unicode}
  { Unicode FPC on Windows. }
  Result := UTF16ToUTF8(Str);
  {$ELSE !Unicode}
  { Non-Unicode FPC on Windows. }
  if (UTF8AnsiDefaultStrings) then
    Result := Str
  else
    Result := AnsiCPToUTF8(Str);
  {$ENDIF !Unicode}
 {$ELSE !Windows}
  {$IFDEF Unicode}
  { Unicode FPC on Linux. }
  Result := UTF16ToUTF8(Str);
  {$ELSE !Unicode}
  { Non-Unicode FPC on Linux. }
  Result := Str;
  {$ENDIF !Unicode}
 {$ENDIF !Windows}
{$ELSE !FPC}
 {$IFDEF Windows}
  {$IFDEF Unicode}
  { Unicode Delphi on Windows. }
  Result := UTF16ToUTF8(Str);
  {$ELSE !Unicode}
  { Non-Unicode Delphi on Windows. }
  Result := AnsiCPToUTF8(Str);
  {$ENDIF !Unicode}
 {$ELSE !Windows}
  {$IFDEF Unicode}
  { Unicode Delphi on Linux. }
  Result := UTF16ToUTF8(Str);
  {$ELSE !Unicode}
  { Non-Unicode Delphi on Linux. }
  Result := Str;
  {$ENDIF !Unicode}
 {$ENDIF !Windows}
{$ENDIF !FPC}
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function UTF8ToStr(const Str: UTF8String): String;
begin
{$IFDEF FPC}
 {$IFDEF Windows}
  {$IFDEF Unicode}
  { Unicode FPC on Windows. }
  Result := UTF8ToUTF16(Str);
  {$ELSE !Unicode}
  { Non-Unicode FPC on Windows. }
  If (UTF8AnsiDefaultStrings) then
    Result := Str
  else
    Result := UTF8ToAnsiCP(Str);
  {$ENDIF !Unicode}
 {$ELSE !Windows}
  {$IFDEF Unicode}
  { Unicode FPC on Linux. }
  Result := UTF8ToUTF16(Str);
  {$ELSE !Unicode}
  { Non-Unicode FPC on Linux. }
  Result := Str;
  {$ENDIF !Unicode}
 {$ENDIF !Windows}
{$ELSE !FPC}
 {$IFDEF Windows}
  {$IFDEF Unicode}
  { Unicode Delphi on Windows. }
  Result := UTF8ToUTF16(Str);
  {$ELSE !Unicode}
  { Non-Unicode Delphi on Windows. }
  Result := UTF8ToAnsiCP(Str);
  {$ENDIF !Unicode}
 {$ELSE !Windows}
  {$IFDEF Unicode}
  { Unicode Delphi on Linux. }
  Result := UTF8ToUTF16(Str);
  {$ELSE !Unicode}
  { Non-Unicode Delphi on Linux. }
  Result := Str;
  {$ENDIF !Unicode}
 {$ENDIF !Windows}
{$ENDIF !FPC}
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function StrToWide(const Str: String): WideString;
begin
{$IFDEF FPC}
 {$IFDEF Windows}
  {$IFDEF Unicode}
  { Unicode FPC on Windows. }
  Result := Str;
  {$ELSE !Unicode}
  { Non-Unicode FPC on Windows. }
  if (UTF8AnsiDefaultStrings) then
    Result := UTF8ToUTF16(Str)
  else
    Result := AnsiCPToUnicode(Str);
  {$ENDIF !Unicode}
 {$ELSE !Windows}
  {$IFDEF Unicode}
  { Unicode FPC on Linux. }
  Result := Str;
  {$ELSE !Unicode}
  { Non-Unicode FPC on Linux. }
  Result := UTF8ToUTF16(Str);
  {$ENDIF !Unicode}
 {$ENDIF !Windows}
{$ELSE !FPC}
 {$IFDEF Windows}
  {$IFDEF Unicode}
  { Unicode Delphi on Windows. }
  Result := Str;
  {$ELSE !Unicode}
  { Non-Unicode Delphi on Windows. }
  Result := AnsiCPToUnicode(Str);
  {$ENDIF !Unicode}
 {$ELSE !Windows}
  {$IFDEF Unicode}
  { Unicode Delphi on Linux. }
  Result := Str;
  {$ELSE !Unicode}
  { Non-Unicode Delphi on Linux. }
  Result := UTF8ToUTF16(Str);
  {$ENDIF !Unicode}
 {$ENDIF !Windows}
{$ENDIF !FPC}
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function WideToStr(const Str: WideString): String;
begin
{$IFDEF FPC}
 {$IFDEF Windows}
  {$IFDEF Unicode}
  { Unicode FPC on Windows. }
  Result := Str;
  {$ELSE}
  { Non-Unicode FPC on Windows. }
  if (UTF8AnsiDefaultStrings) then
    Result := UTF16ToUTF8(Str)
  else
    Result := UnicodeToAnsiCP(Str);
  {$ENDIF !Unicode}
 {$ELSE !Windows}
  {$IFDEF Unicode}
  { Unicode FPC on Linux. }
  Result := Str;
  {$ELSE !Unicode}
  { Non-Unicode FPC on Linux. }
  Result := UTF16ToUTF8(Str);
  {$ENDIF !Unicode}
 {$ENDIF !Windows}
{$ELSE !FPC}
 {$IFDEF Windows}
  {$IFDEF Unicode}
  { Unicode Delphi on Windows. }
  Result := Str;
  {$ELSE !Unicode}
  { Non-Unicode Delphi on Windows. }
  Result := UnicodeToAnsiCP(Str);
  {$ENDIF !Unicode}
 {$ELSE !Windows}
  {$IFDEF Unicode}
  { Unicode Delphi on Linux. }
  Result := Str;
  {$ELSE !Unicode}
  { Non-Unicode Delphi on Linux. }
  Result := UTF16ToUTF8(Str);
  {$ENDIF !Unicode}
 {$ENDIF !Windows}
{$ENDIF !FPC}
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function StrToUnicode(const Str: String): UnicodeString;
begin
{$IFDEF FPC}
 {$IFDEF Windows}
  {$IFDEF Unicode}
  { Unicode FPC on Windows. }
  Result := Str;
  {$ELSE !Unicode}
  { Non-Unicode FPC on Windows. }
  if (UTF8AnsiDefaultStrings) then
    Result := UTF8ToUTF16(Str)
  else
    Result := AnsiCPToUnicode(Str);
  {$ENDIF !Unicode}
 {$ELSE !Windows}
  {$IFDEF Unicode}
  { Unicode FPC on Linux. }
  Result := Str;
  {$ELSE !Unicode}
  { Non-Unicode FPC on Linux. }
  Result := UTF8ToUTF16(Str);
  {$ENDIF !Unicode}
 {$ENDIF !Windows}
{$ELSE !FPC}
 {$IFDEF Windows}
  {$IFDEF Unicode}
  { Unicode Delphi on Windows. }
  Result := Str;
  {$ELSE !Unicode}
  { Non-Unicode Delphi on Windows. }
  Result := AnsiCPToUnicode(Str);
  {$ENDIF !Unicode}
 {$ELSE !Windows}
  {$IFDEF Unicode}
  { Unicode Delphi on Linux. }
  Result := Str;
  {$ELSE !Unicode}
  { Non-Unicode Delphi on Linux. }
  Result := UTF8ToUTF16(Str);
  {$ENDIF !Unicode}
 {$ENDIF !Windows}
{$ENDIF !FPC}
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function UnicodeToStr(const Str: UnicodeString): String;
begin
{$IFDEF FPC}
 {$IFDEF Windows}
  {$IFDEF Unicode}
  { Unicode FPC on Windows. }
  Result := Str;
  {$ELSE !Unicode}
  { Non-Unicode FPC on Windows. }
  if (UTF8AnsiDefaultStrings) then
    Result := UTF16ToUTF8(Str)
  else
    Result := UnicodeToAnsiCP(Str);
  {$ENDIF !Unicode}
 {$ELSE !Windows}
  {$IFDEF Unicode}
  { Unicode FPC on Linux. }
  Result := Str;
  {$ELSE !Unicode}
  { Non-Unicode FPC on Linux. }
  Result := UTF16ToUTF8(Str);
  {$ENDIF !Unicode}
 {$ENDIF !Windows}
{$ELSE !FPC}
 {$IFDEF Windows}
  {$IFDEF Unicode}
  { Unicode Delphi on Windows. }
  Result := Str;
  {$ELSE !Unicode}
  { Non-Unicode Delphi on Windows. }
  Result := UnicodeToAnsiCP(Str);
  {$ENDIF !Unicode}
 {$ELSE !Windows}
  {$IFDEF Unicode}
  { Unicode Delphi on Linux. }
  Result := Str;
  {$ELSE !Unicode}
  { Non-Unicode Delphi on Linux. }
  Result := UTF16ToUTF8(Str);
  {$ENDIF !Unicode}
 {$ENDIF !Windows}
{$ENDIF !FPC}
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function StrToRTL(const Str: String): TRTLString;
begin
{$IFDEF FPC}
 {$IFDEF Windows}
  {$IFDEF Unicode}
  { Unicode FPC on Windows. }
  if (UTF8AnsiStrings) then
    Result := UTF16ToUTF8(Str)
  else
    Result := UnicodeToAnsiCP(Str);
  {$ELSE !Unicode}
  { Non-Unicode FPC on Windows. }
  if ((UTF8AnsiDefaultStrings) and (not UTF8AnsiStrings)) then
    Result := UTF8ToAnsiCP(Str)
  else
    Result := Str;
  {$ENDIF !Unicode}
 {$ELSE !Windows}
  {$IFDEF Unicode}
  { Unicode FPC on Linux. }
  Result := UTF16ToUTF8(Str);
  {$ELSE !Unicode}
  { Non-Unicode FPC on Linux. }
  Result := Str;
  {$ENDIF !Unicode}
 {$ENDIF !Windows}
{$ELSE !FPC}
 {$IFDEF Windows}
  {$IFDEF Unicode}
  { Unicode Delphi on Windows. }
  Result := Str;
  {$ELSE !Unicode}
  { Non-Unicode Delphi on Windows. }
  Result := Str;
  {$ENDIF !Unicode}
 {$ELSE !Windows}
  {$IFDEF Unicode}
  { Unicode Delphi on Linux. }
  Result := Str;
  {$ELSE !Unicode}
  { Non-Unicode Delphi on Linux. }
  Result := Str;
  {$ENDIF !Unicode}
 {$ENDIF !Windows}
{$ENDIF !FPC}
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function RTLToStr(const Str: TRTLString): String;
begin
{$IFDEF FPC}
 {$IFDEF Windows}
  {$IFDEF Unicode}
  { Unicode FPC on Windows. }
  if (UTF8AnsiStrings) then
    Result := UTF8ToUTF16(Str)
  else
    Result := AnsiCPToUnicode(Str);
  {$ELSE !Unicode}
  { Non-Unicode FPC on Windows. }
  if ((UTF8AnsiDefaultStrings) and (not UTF8AnsiStrings)) then
    Result := AnsiCPToUTF8(Str)
  else
    Result := Str;
  {$ENDIF !Unicode}
 {$ELSE !Windows}
  {$IFDEF Unicode}
  { Unicode FPC on Linux. }
  Result := UTF8ToUTF16(Str);
  {$ELSE !Unicode}
  { Non-Unicode FPC on Linux. }
  Result := Str;
  {$ENDIF !Unicode}
 {$ENDIF !Windows}
{$ELSE !FPC}
 {$IFDEF Windows}
  {$IFDEF Unicode}
  { Unicode Delphi on Windows. }
  Result := Str;
  {$ELSE !Unicode}
  { Non-Unicode Delphi on Windows. }
  Result := Str;
  {$ENDIF !Unicode}
 {$ELSE !Windows}
  {$IFDEF Unicode}
  { Unicode Delphi on Linux. }
  Result := Str;
  {$ELSE !Unicode}
  { Non-Unicode Delphi on Linux. }
  Result := Str;
  {$ENDIF !Unicode}
 {$ENDIF !Windows}
{$ENDIF !FPC}
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function StrToGUI(const Str: String): TGUIString;
begin
{$IFDEF FPC}
 {$IFDEF Windows}
  {$IFDEF Unicode}
  { Unicode FPC on Windows. }
  Result := UTF16ToUTF8(Str);
  {$ELSE !Unicode}
  { Non-Unicode FPC on Windows. }
  if (UTF8AnsiDefaultStrings) then
    Result := Str
  else
    Result := AnsiCPToUTF8(Str);
  {$ENDIF !Unicode}
 {$ELSE !Windows}
  {$IFDEF Unicode}
  { Unicode FPC on Linux. }
  Result := UTF16ToUTF8(Str);
  {$ELSE !Unicode}
  { Non-Unicode FPC on Linux. }
  Result := Str;
  {$ENDIF !Unicode}
 {$ENDIF !Windows}
{$ELSE !FPC}
 {$IFDEF Windows}
  {$IFDEF Unicode}
  { Unicode Delphi on Windows. }
  Result := Str;
  {$ELSE !Unicode}
  { Non-Unicode Delphi on Windows. }
  Result := Str;
  {$ENDIF !Unicode}
 {$ELSE !Windows}
  {$IFDEF Unicode}
  { Unicode Delphi on Linux. }
  Result := Str;
  {$ELSE !Unicode}
  { Non-Unicode Delphi on Linux. }
  Result := Str;
  {$ENDIF !Unicode}
 {$ENDIF !Windows}
{$ENDIF !FPC}
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

Function GUIToStr(const Str: TGUIString): String;
begin
{$IFDEF FPC}
 {$IFDEF Windows}
  {$IFDEF Unicode}
  { Unicode FPC on Windows. }
  Result := UTF8ToUTF16(Str);
  {$ELSE !Unicode}
  { Non-Unicode FPC on Windows. }
  if (UTF8AnsiDefaultStrings) then
    Result := Str
  else
    Result := UTF8ToAnsiCP(Str);
  {$ENDIF !Unicode}
 {$ELSE !Windows}
  {$IFDEF Unicode}
  { Unicode FPC on Linux. }
  Result := UTF8ToUTF16(Str);
  {$ELSE !Unicode}
  { Non-Unicode FPC on Linux. }
  Result := Str;
  {$ENDIF !Unicode}
 {$ENDIF !Windows}
{$ELSE !FPC}
 {$IFDEF Windows}
  {$IFDEF Unicode}
  { Unicode Delphi on Windows. }
  Result := Str;
  {$ELSE !Unicode}
  { Non-Unicode Delphi on Windows. }
  Result := Str;
  {$ENDIF !Unicode}
 {$ELSE !Windows}
  {$IFDEF Unicode}
  { Unicode Delphi on Linux. }
  Result := Str;
  {$ELSE !Unicode}
  { Non-Unicode Delphi on Linux. }
  Result := Str;
  {$ENDIF !Unicode}
 {$ENDIF !Windows}
{$ENDIF !FPC}
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function StrToWinA(const Str: String): AnsiString;
begin
{$IFDEF FPC}
 {$IFDEF Windows}
  {$IFDEF Unicode}
  { Unicode FPC on Windows. }
  Result := UnicodeToAnsiCP(Str);
  {$ELSE !Unicode}
  { Non-Unicode FPC on Windows. }
  if (UTF8AnsiDefaultStrings) then
    Result := UTF8ToAnsiCP(Str)
  else
    Result := Str;
  {$ENDIF !Unicode}
 {$ELSE !Windows}
  {$IFDEF Unicode}
  { Unicode FPC on Linux. }
  Result := UTF16ToUTF8(Str);
  {$ELSE !Unicode}
  { Non-Unicode FPC on Linux. }
  Result := Str;
  {$ENDIF !Unicode}
 {$ENDIF !Windows}
{$ELSE !FPC}
 {$IFDEF Windows}
  {$IFDEF Unicode}
  { Unicode Delphi on Windows. }
  Result := UnicodeToAnsiCP(Str);
  {$ELSE !Unicode}
  { Non-Unicode Delphi on Windows. }
  Result := Str;
  {$ENDIF}
 {$ELSE !Windows}
  {$IFDEF Unicode}
  { Unicode Delphi on Linux. }
  Result := UTF16ToUTF8(Str);
  {$ELSE !Unicode}
  { Non-unicode Delphi on Linux. }
  Result := Str;
  {$ENDIF !Unicode}
 {$ENDIF !Windows}
{$ENDIF !FPC}
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function WinAToStr(const Str: AnsiString): String;
begin
{$IFDEF FPC}
 {$IFDEF Windows}
  {$IFDEF Unicode}
  { Unicode FPC on Windows. }
  Result := AnsiCPToUnicode(Str);
  {$ELSE !Unicode}
  { Non-Unicode FPC on Windows. }
  if (UTF8AnsiDefaultStrings) then
    Result := AnsiCPToUTF8(Str)
  else
    Result := Str;
  {$ENDIF !Unicode}
 {$ELSE !Windows}
  {$IFDEF Unicode}
  { Unicode FPC on Linux. }
  Result := UTF8ToUTF16(Str);
  {$ELSE !Unicode}
  { Non-Unicode FPC on Linux. }
  Result := Str;
  {$ENDIF !Unicode}
 {$ENDIF !Windows}
{$ELSE !FPC}
 {$IFDEF Windows}
  {$IFDEF Unicode}
  { Unicode Delphi on Windows. }
  Result := AnsiCPToUnicode(Str);
  {$ELSE !Unicode}
  { Non-Unicode Delphi on Windows. }
  Result := Str;
  {$ENDIF !Unicode}
 {$ELSE !Windows}
  {$IFDEF Unicode}
  { Unicode Delphi on Linux. }
  Result := UTF8ToUTF16(Str);
  {$ELSE !Unicode}
  { Non-Unicode Delphi on Linux. }
  Result := Str;
  {$ENDIF !Unicode}
 {$ENDIF !Windows}
{$ENDIF !FPC}
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function StrToWinW(const Str: String): WideString;
begin
  Result := StrToWide(Str);
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function WinWToStr(const Str: WideString): String;
begin
  Result := WideToStr(Str);
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function StrToWin(const Str: String): TWinString;
begin
  Result := StrToSys(Str);
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function WinToStr(const Str: TWinString): String;
begin
  Result := SysToStr(Str);
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

Function StrToCsl(const Str: String): TCSLString;
begin
{$IFDEF FPC}
 {$IFDEF Windows}
  {$IFDEF Unicode}
  { Unicode FPC on Windows. }
  Result := Str;
  {$ELSE !Unicode}
  { Non-Unicode FPC on Windows. }
  if (UTF8AnsiDefaultStrings) then
    Result := UTF8ToAnsiCP(Str,CP_OEMCP)
  else
    Result := AnsiToConsole(Str);
  {$ENDIF !Unicode}
 {$ELSE !Windows}
  {$IFDEF Unicode}
  { Unicode FPC on Linux. }
  Result := UTF16ToUTF8(Str);
  {$ELSE !Unicode}
  { Non-Unicode FPC on Linux. }
  Result := Str;
  {$ENDIF !Unicode}
 {$ENDIF !Windows}
{$ELSE !FPC}
 {$IFDEF Windows}
  {$IFDEF Unicode}
  { Unicode Delphi on Windows. }
  Result := Str;
  {$ELSE !Unicode}
  { Non-Unicode Delphi on Windows. }
  Result := AnsiToConsole(Str);
  {$ENDIF !Unicode}
 {$ELSE !Windows}
  {$IFDEF Unicode}
  { Unicode Delphi on Linux. }
  Result := Str;
  {$ELSE !Unicode}
  { Non-Unicode Delphi on Linux. }
  Result := Str;
  {$ENDIF !Unicode}
 {$ENDIF !Windows}
{$ENDIF !FPC}
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function CslToStr(const Str: TCSLString): String;
begin
{$IFDEF FPC}
 {$IFDEF Windows}
  {$IFDEF Unicode}
  { Unicode FPC on Windows. }
  Result := Str;
  {$ELSE !Unicode}
  { Non-Unicode FPC on Windows. }
  if (UTF8AnsiDefaultStrings) then
    Result := AnsiCPToUTF8(Str,CP_OEMCP)
  else
    Result := ConsoleToAnsi(Str);
  {$ENDIF !Unicode}
 {$ELSE !Windows}
  {$IFDEF Unicode}
  { Unicode FPC on Linux. }
  Result := UTF8ToUTF16(Str);
  {$ELSE !Unicode}
  { Non-Unicode FPC on Linux. }
  Result := Str;
  {$ENDIF !Unicode}
 {$ENDIF !Windows}
{$ELSE !FPC}
 {$IFDEF Windows}
  {$IFDEF Unicode}
  { Unicode Delphi on Windows. }
  Result := Str;
  {$ELSE !Unicode}
  { Non-Unicode Delphi on Windows. }
  Result := ConsoleToAnsi(Str);
  {$ENDIF !Unicode}
 {$ELSE !Windows}
  {$IFDEF Unicode}
  { Unicode Delphi on Linux. }
  Result := Str;
  {$ELSE !Unicode}
  { Non-Unicode Delphi on Linux. }
  Result := Str;
  {$ENDIF !Unicode}
 {$ENDIF !Windows}
{$ENDIF !FPC}
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

Function StrToSys(const Str: String): TSysString;
begin
{$IFDEF FPC}
 {$IFDEF Windows}
  {$IFDEF Unicode}
  { Unicode FPC on Windows. }
  Result := UnicodeToAnsiCP(Str);
  {$ELSE !Unicode}
  { Non-Unicode FPC on Windows. }
  if (UTF8AnsiDefaultStrings) then
    Result := UTF8ToAnsiCP(Str)
  else
    Result := Str;
  {$ENDIF !Unicode}
 {$ELSE !Windows}
  {$IFDEF Unicode}
  { Unicode FPC on Linux. }
  Result := UTF16ToUTF8(Str);
  {$ELSE !Unicode}
  { Non-Unicode FPC on Linux. }
  Result := Str;
  {$ENDIF !Unicode}
 {$ENDIF !Windows}
{$ELSE !FPC}
 {$IFDEF Windows}
  {$IFDEF Unicode}
  { Unicode Delphi on Windows. }
  Result := Str;
  {$ELSE !Unicode}
  { Non-Unicode Delphi on Windows. }
  Result := Str;
  {$ENDIF !Unicode}
 {$ELSE !Windows}
  {$IFDEF Unicode}
  { Unicode Delphi on Linux. }
  Result := UTF16ToUTF8(Str);
  {$ELSE !Unicode}
  { Non-Unicode Delphi on Linux. }
  Result := Str;
  {$ENDIF !Unicode}
 {$ENDIF !Windows}
{$ENDIF !FPC}
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function SysToStr(const Str: TSysString): String;
begin
{$IFDEF FPC}
 {$IFDEF Windows}
  {$IFDEF Unicode}
  { Unicode FPC on Windows. }
  Result := AnsiCPToUnicode(Str);
  {$ELSE !Unicode}
  { Non-Unicode FPC on Windows. }
  if (UTF8AnsiDefaultStrings) then
    Result := AnsiCPToUTF8(Str)
  else
    Result := Str;
  {$ENDIF !Unicode}
 {$ELSE !Windows}
  {$IFDEF Unicode}
  { Unicode FPC on Linux. }
  Result := UTF8ToUTF16(Str);
  {$ELSE !Unicode}
  { Non-Unicode FPC on Linux. }
  Result := Str;
  {$ENDIF !Unicode}
 {$ENDIF !Windows}
{$ELSE !FPC}
 {$IFDEF Windows}
  {$IFDEF Unicode}
  { Unicode Delphi on Windows. }
  Result := Str;
  {$ELSE !Unicode}
  { Non-Unicode Delphi on Windows. }
  Result := Str;
  {$ENDIF !Unicode}
 {$ELSE !Windows}
  {$IFDEF Unicode}
  { Unicode Delphi on Linux. }
  Result := UTF8ToUTF16(Str);
  {$ELSE !Unicode}
  { Non-Unicode Delphi on Linux. }
  Result := Str;
  {$ENDIF !Unicode}
 {$ENDIF !Windows}
{$ENDIF !FPC}
end;
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}

{- Explicit string comparison functions implementation - - - - - - - - - - - - }
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

{$IFDEF SUPPORTS_REGION}{$REGION 'Explicit string comparison functions implementation'}{$ENDIF}
function ShortStringCompare(const A, B: ShortString; CaseSensitive: Boolean): Integer;
begin
{$IF DEFINED(FPC) AND DEFINED(Unicode)}
  if (CaseSensitive) then
    Result := SysUtils.UnicodeCompareStr(ShortToStr(A), ShortToStr(B))
  else
    Result := SysUtils.UnicodeCompareText(ShortToStr(A), ShortToStr(B));
{$ELSE}
  if (CaseSensitive) then
    Result := {$IFDEF HAS_UNITSCOPE}System.{$ENDIF}SysUtils.AnsiCompareStr(ShortToStr(A), ShortToStr(B))
  else
    Result := {$IFDEF HAS_UNITSCOPE}System.{$ENDIF}SysUtils.AnsiCompareText(ShortToStr(A), ShortToStr(B));
{$IFEND}
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function AnsiStringCompare(const A, B: AnsiString; CaseSensitive: Boolean): Integer;
begin
{$IFDEF FPC}
  if (CaseSensitive) then
    Result := SysUtils.AnsiCompareStr(A, B)
  else
    Result := SysUtils.AnsiCompareText(A, B);
{$ELSE !FPC}
 {$IF DECLARED(AnsiStrings)}
  if (CaseSensitive) then
    Result := {$IFDEF HAS_UNITSCOPE}System.{$ENDIF}AnsiStrings.AnsiCompareStr(A, B)
  else
    Result := {$IFDEF HAS_UNITSCOPE}System.{$ENDIF}AnsiStrings.AnsiCompareText(A, B);
 {$ELSE}
  if (CaseSensitive) then
    Result := {$IFDEF HAS_UNITSCOPE}System.{$ENDIF}SysUtils.AnsiCompareStr(A, B)
  else
    Result := {$IFDEF HAS_UNITSCOPE}System.{$ENDIF}SysUtils.AnsiCompareText(A, B);
 {$IFEND}
{$ENDIF !FPC}
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function UTF8StringCompare(const A, B: UTF8String; CaseSensitive: Boolean): Integer;
begin
{$IFDEF FPC}
  if (CaseSensitive) then
    Result := SysUtils.UnicodeCompareStr(UTF8ToUTF16(A), UTF8ToUTF16(B))
  else
    Result := SysUtils.UnicodeCompareText(UTF8ToUTF16(A), UTF8ToUTF16(B));
{$ELSE !FPC}
 {$IFDEF Unicode}
  if (CaseSensitive) then
    Result := {$IFDEF HAS_UNITSCOPE}System.{$ENDIF}SysUtils.AnsiCompareStr(UTF8ToUTF16(A), UTF8ToUTF16(B))
  else
    Result := {$IFDEF HAS_UNITSCOPE}System.{$ENDIF}SysUtils.AnsiCompareText(UTF8ToUTF16(A), UTF8ToUTF16(B));
 {$ELSE}
  if (CaseSensitive) then
    Result := {$IFDEF HAS_UNITSCOPE}System.{$ENDIF}SysUtils.WideCompareStr(UTF8ToUTF16(A), UTF8ToUTF16(B))
  else
    Result := {$IFDEF HAS_UNITSCOPE}System.{$ENDIF}SysUtils.WideCompareText(UTF8ToUTF16(A), UTF8ToUTF16(B));
 {$ENDIF}
{$ENDIF !FPC}
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function WideStringCompare(const A, B: WideString; CaseSensitive: Boolean): Integer;
begin
  if (CaseSensitive) then
    Result := {$IFDEF HAS_UNITSCOPE}System.{$ENDIF}SysUtils.WideCompareStr(A, B)
  else
    Result := {$IFDEF HAS_UNITSCOPE}System.{$ENDIF}SysUtils.WideCompareText(A, B);
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function UnicodeStringCompare(const A, B: UnicodeString; CaseSensitive: Boolean): Integer;
begin
{$IFDEF FPC}
  if (CaseSensitive) then
    Result := SysUtils.UnicodeCompareStr(A, B)
  else
    Result := SysUtils.UnicodeCompareText(A, B);
{$ELSE !FPC}
 {$IFDEF Unicode}
  if (CaseSensitive) then
    Result := {$IFDEF HAS_UNITSCOPE}System.{$ENDIF}SysUtils.AnsiCompareStr(A, B)
  else
    Result := {$IFDEF HAS_UNITSCOPE}System.{$ENDIF}SysUtils.AnsiCompareText(A, B);
 {$ELSE}
  if (CaseSensitive) then
    Result := {$IFDEF HAS_UNITSCOPE}System.{$ENDIF}SysUtils.WideCompareStr(A, B)
  else
    Result := {$IFDEF HAS_UNITSCOPE}System.{$ENDIF}SysUtils.WideCompareText(A, B);
 {$ENDIF}
{$ENDIF !FPC}
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function StringCompare(const A, B: String; CaseSensitive: Boolean): Integer;
begin
{$IF DEFINED(FPC) AND DEFINED(Unicode)}
  if (CaseSensitive) then
    Result := SysUtils.UnicodeCompareStr(A, B)
  else
    Result := SysUtils.UnicodeCompareText(A, B);
{$ELSE}
  if (CaseSensitive) then
    Result := {$IFDEF HAS_UNITSCOPE}System.{$ENDIF}SysUtils.AnsiCompareStr(A, B)
  else
    Result := {$IFDEF HAS_UNITSCOPE}System.{$ENDIF}SysUtils.AnsiCompareText(A, B);
{$IFEND}
end;
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}

end.
