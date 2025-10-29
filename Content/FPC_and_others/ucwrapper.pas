(******************************************************************************)
(*                                                                            *)
(* Author      : Uwe Schächterle (Corpsman)                                   *)
(*                                                                            *)
(* This file is part of FPC_and_others                                        *)
(*                                                                            *)
(*  See the file license.md, located under:                                   *)
(*  https://github.com/PascalCorpsman/Software_Licenses/blob/main/license.md  *)
(*  for details about the license.                                            *)
(*                                                                            *)
(*               It is not allowed to change or remove this text from any     *)
(*               source file of the project.                                  *)
(*                                                                            *)
(******************************************************************************)
Unit uCWrapper;

{$MODE ObjFPC}{$H+}
(*
 * Generally needed for all records to be same in memory as C/C++ structs
 *)
{$PACKRECORDS C}

Interface

Uses
  Classes, SysUtils, ctypes;

(*
 * Only needed if "defaults" like allocation (C++) or console (C) is used
 * If you do your own applications try to "not" use this includes at the first
 * steps
 *)
{$IFDEF Linux}
{$LINKLIB c} // support for printf
{$LINKLIB stdc++} // support for new / delete
{$ENDIF}

{$IFDEF Windows}
{$LINKLIB msvcrt}
{$LINKLIB libstdc++.dll.a}
{$ENDIF}

{$IFDEF Darwin} // Untested
{$LINKLIB c}
{$LINKLIB stdc++}
{$ENDIF}

(*
 * Statically linked code created via g++ as .o
 *)
{$LINK obj/shared_o.o}

(*
 *Statically linkded code created via g++ as .a (including usually more than one .o file)
 *)
{$LINKLIB libshared_a.a}

(*
 * Shared_o.h
 *)

  (*
   * Easy C-Like examples ;)
   *)
Type

  MyStruct_t = Record
    a: cuint8; // uint8_t
    b: cuint16; // uint16_t
    c: cuint8; // uint8_t
    d: cint32; // uint32_t
  End;

  MyEnum_t = (eA = 0, eB, eC, eD);

Procedure print_HelloWorld; cdecl; external;
Procedure print_a_plus_b(a, b: Integer); cdecl; external;
Function calc_a_plus_b(a, b: Integer): Integer; cdecl; external;
Procedure plott_array(Var arrayPtr: Array Of cuint8; length: Byte); cdecl; external;
Procedure print_struct_element(Var S: MyStruct_t; E: MyEnum_t); cdecl; external;
Procedure call_c(); cdecl; external;

(*
 * How to work with C++ Classes
 *)

Type
  DummyClass = Pointer;

Function create_Dummy_class(): DummyClass; cdecl; external;

Procedure destroy_Dummy_class(Const ptr: DummyClass); cdecl; external;

Procedure call_B_from_Dummy_class(Const ptr: DummyClass; value: cint); cdecl; external;

Procedure print_a_from_Dummy_class(Const ptr: DummyClass); cdecl; external;

(*
 * shared_a.h
 *)

Procedure print_HelloWorld_from_a(); cdecl; external;

(*
 * shared_lib1.h, statically linked
 *)

Procedure print_HelloWorld_from_lib1(); cdecl; external{$IFDEF Windows} 'shared1.dll'{$ELSE}{$IFDEF Darwin} 'libshared1.dylib'{$ELSE}{$ENDIF} 'libshared1.so'{$ENDIF};

(*
 * shared_lib2.h runtime linked
 *)

Type
  Tprint_HelloWorld_from_lib2 = Procedure(); cdecl;

Var
  print_HelloWorld_from_lib2: Tprint_HelloWorld_from_lib2 = Nil;

Procedure LoadLib();
Procedure UnLoadLib();

Implementation

Uses dynlibs; // Needed for runtime loading of shared2 lib

Var
  LibHandle: TLibHandle = 0; // Needed for runtime loading of shared2 lib

  (*
   * Shared_o.h
   *)

Procedure called_from_c(); cdecl public name{$IFDEF CPU64} 'called_from_c'{$ELSE} '_called_from_c'{$ENDIF};
Begin
  writeln('called from c');
End;

(*
 * shared_lib2.h runtime linking
 *)

Procedure LoadLib();
Var
  path: String;
Begin
  UnLoadLib();
  // At least under Linux it has to be a absolute path not relative !
  path := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
  LibHandle := LoadLibrary(path + {$IFDEF Windows} 'shared2.dll'{$ELSE}{$IFDEF Darwin} 'libshared2.dylib'{$ELSE}{$ENDIF} 'libshared2.so'{$ENDIF});
  If LibHandle = 0 Then Begin
    Raise exception.create('Error, could not load shared2 lib.');
  End;
  print_HelloWorld_from_lib2 := Tprint_HelloWorld_from_lib2(GetProcedureAddress(LibHandle, 'print_HelloWorld_from_lib2'));
  If Not assigned(print_HelloWorld_from_lib2) Then Begin
    UnLoadLib();
    Raise exception.create('Error, could not load print_HelloWorld_from_lib2.');
  End;
End;

Procedure UnLoadLib();
Begin
  If LibHandle <> 0 Then Begin
    UnloadLibrary(LibHandle);
  End;
  LibHandle := 0;
  print_HelloWorld_from_lib2 := Nil;
End;

{$IFDEF Windows}
(*
 * In oder to be able to use the C++ Bindings from Windows, there was the need
 * to give the Linker some "extra" function pointers to call ;)
 *)

Function atexit(func: pointer): cint; cdecl public name{$IFDEF CPU64} 'atexit'{$ELSE} '_atexit'{$ENDIF};
Begin
  // Don't know what to do here ?
  result := 0;
End;

Function __mingw_vfprintf(stdout: Pointer; __format: PChar; __local_argv: Array Of pointer): cint; cdecl public name{$IFDEF CPU64} '__mingw_vfprintf'{$ELSE} '___mingw_vfprintf'{$ENDIF};
Begin
  (*
   * This is a bad eval hack, but at least on my Windows Test machine it worked ...
   *)
  // !! Do not use this code in your own applications, this does only work because all
  //    examples of the demo use a integer as param !!
  writeln(format(__format, [integer(__local_argv[0])]));
  result := 0;
End;

{$ENDIF}

End.

