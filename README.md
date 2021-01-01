[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-v2.0%20adopted-ff69b4.svg)](code_of_conduct.md)

# Welcome to Lib.StringRectification

## What's Lib.StringRectification

Main aim of this library is to simplify conversions in Lazarus when passing strings to RTL
or WinAPI - mainly to ensure the same code can be used in all compilers (Delphi, FPC 2.x.x,
FPC 3.x.x) without a need for symbol checks.

It also provides set of functions for string comparison that encapsulates some of the
intricacies given by different approach in different compilers.

For details about encodings refer to file EncodingNotes.txt that should be distributed with
this library.

Lib.StringRectification was tested in following IDE/compilers:

- Delphi 10.4.1 Sidney Architect (unicode, Windows)
- Lazarus 2.0.10 - FPC 3.2.0 (non-unicode, Windows)
- Lazarus 2.0.10 - FPC 3.2.0 (non-unicode, Linux)
- Lazarus 2.0.10 - FPC 3.2.0 (unicode, Windows)
- Lazarus 2.0.10 - FPC 3.2.0 (unicode, Linux)

Tested compatible FPC modes:

Delphi, DelphiUnicode, FPC (default), ObjFPC, TurboPascal

WARNING - a LOT of assumptions were made when creating this library (most of it was written
"blind", with no access to internet and documentation), so if you find any error or mistake,
please contact the author.
Also, if you are certain that some part, in here marked as dubious, is actually correct,
let the author know.

## Clone with GIT

```
git clone https://github.com/dompiotr85/Lib.StringRectification.git Lib.StringRectification
```

This will get you the Lib.StringRectification repository.

## Contributing

We encourage you to contribute to Lib.StringRectification! Please check out the
[Contributing to Lib.StringRectification guide](./CONTRIBUTING.md) for guidelines
about how to proceed.

Everyone interacting with Lib.StringRectification and its sub-projects' issue
trackers is expected to follow the Lib.StringRectification
[code of conduct](./CODE_OF_CONDUCT.md).

## License

Lib.StringRectification is licensed under the [MPL-2.0](./LICENSE).
