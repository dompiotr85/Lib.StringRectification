{===============================================================================

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

===============================================================================}

{$IFNDEF SR_CONFIG_INC}
{$DEFINE SR_CONFIG_INC}

{ Include jedi.inc file. }
{$INCLUDE jedi\jedi.inc}

{$IFDEF SUPPORTS_LEGACYIFEND}{$LEGACYIFEND ON}{$ENDIF}

{$UNDEF SR_BareFPC}

{-- Remove dot ('.') to enable specific feature in Lib.StringRectification ----}

{ Activate symbol SR_BareFPC if you want to compile this unit outside of
  Lazarus. Non-unicode default strings are assumed to be encoded using current
  CP when defined, otherwise they are assumed to be UTF8-encoded.
  It has effect only in FPC older than 2.7.1, in newer versions there are ways
  of how to discern the encoding automatically.
  It is automatically undefined if you compile the program in Lazarus with LCL
  (Lazarus defines symbol LCL, this symbol is observed).
  Not defined by default. }
{.$DEFINE SR_BareFPC}

{ Activate symbol SR_UseInline if you want to compile some of the method of this
  unit with inline switch. }
{$DEFINE SR_UseInline}

{------------------------------------------------------------------------------}


{$ENDIF !SR_CONFIG_INC}