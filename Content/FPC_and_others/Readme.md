# FPC and others

>
> !! Attention !!
> 
> This is a work in progress
>

As a developer and user of a lot of other libraries like OpenGL or SDL there is often the need to include source code from other languages (like Phyton, C, C++, ..).

In this "research" i try to evaluate the different ways on how to include code written in other languages into a FreePascal application.

### Short Summary
* use C compatibility when writing libs or adding plugin support to applications

### Detailes Discussion

When developing applications with FreePascal, developers occasionally need to rely on external functionalities. These can range from simple code snippets to more complex integrations, such as connecting to a rendering engine or a sound library. Often, however, such functionalities are not natively available in FreePascal. The same applies when a developer wants to make their application extensible for others, for example through plugins - such as the AI plugin provided by [FPC_Atomic](https://github.com/PascalCorpsman/fpc_atomic).

A common denominator that has emerged is the C programming language. Its structure is relatively simple, yet it provides everything necessary to extend applications. Instead of supporting *all* programming languages directly, FreePascal focuses on supporting C. This same decision has been made by the developers of many other languages as well. So, if you want to connect a Kotlin or Java application with FreePascal, C once again serves as the shared foundation.

Depending on the scope of the code to be integrated, it can be beneficial to choose different approaches for incorporating it. The following sections will examine and compare various integration methods. Special attention will also be given to potential challenges and edge cases that may arise during implementation.

The following three use cases will be examined in detail:

* **Transpiling from the source language to FreePascal**
  Converting code written in another language into FreePascal-compatible code.

* **Integrating libraries (.dll, .so, .dylib)**
  Linking external dynamic libraries to extend functionality.

* **Special case: Integrating intermediate compilation artifacts (.a, .o)**
  Using compiled object files or static archives directly within FreePascal projects.

Before diving into the analysis of the individual use cases, it is important to first consider the specific characteristics involved in integrating C code. These characteristics primarily concern the interface layer - namely, function calls and the handling of associated parameters. Since these aspects are relevant across all three use cases, they will be discussed collectively in this section.

### Common Interface Challenges when integrating C Code

The foundation of all data types typically lies in the basic types - such as `integer`, `boolean`, and `float`. In FreePascal, C-compatible equivalents of these types are provided in the `ctypes` unit. However, the naming conventions used in `ctypes` differ from those found in the widely adopted C standard header `stdint.h`. See the following table for the mappings:

| C Type (`stdint.h`) | FreePascal Type (`ctypes`) | Description
|---------------------|----------------------------|---------------------------------
| `int8_t`            | `cint8`                    | 8-bit signed integer
| `uint8_t`           | `cuint8`                   | 8-bit unsigned integer
| `int16_t`           | `cint16`                   | 16-bit signed integer
| `uint16_t`          | `cuint16`                  | 16-bit unsigned integer
| `int32_t`           | `cint32`                   | 32-bit signed integer
| `uint32_t`          | `cuint32`                  | 32-bit unsigned integer
| `int64_t`           | `cint64`                   | 64-bit signed integer
| `uint64_t`          | `cuint64`                  | 64-bit unsigned integer
| `float`             | `cfloat`                   | 32-bit floating point number
| `double`            | `cdouble`                  | 64-bit floating point number
| `long double`       | `clongdouble`              | Extended precision float
| `bool` / `_Bool`    | `cbool`                    | Boolean type (typically 1 byte)
| `size_t`            | `csize_t`                  | Unsigned type used for sizes and indexing
| `char`              | `cchar`                    | Single character (typically 1 byte)

> 💡 Note: While the functionality is equivalent, the naming conventions differ. This can lead to confusion when porting C code or writing bindings, especially when using automated tools or macros that expect `stdint.h` names.

Handling strings presents a particularly tricky challenge. In C, strings are represented as null-terminated arrays of characters and lack built-in memory management. In contrast, FreePascal strings are managed by the language itself and do not rely on null-termination. For interoperability, the appropriate type in FreePascal is `PChar`, which corresponds to a C-style `char*`.

To ensure that structures are compatible with C, the compiler directive `{$PACKRECORDS C}` must be enabled in the respective unit. This instructs the FreePascal compiler to align the fields within a record according to C conventions. 

>⚠️ Note that the `packed` keyword overrides this behavior in both languages and must be set consistently when porting code.

This structure will be aligned just like the following C struct:
```C
struct Example {
    uint8_t a;
    uint32_t b;
};
```
Converts to 
```pascal
{$mode objfpc}
{$PACKRECORDS C}

type
  TExample = record
    a: cuint8;
    b: cuint32;
  end;
```
> 💡 Without {$PACKRECORDS C}, FreePascal might insert padding differently, leading to mismatches in memory layout when exchanging data with C code.

Enumeration types are generally straightforward to convert between C and FreePascal, as both compilers typically represent them internally as integers starting from index 0. However, in C it is quite common to use enums for array indexing. This becomes problematic when developers break the typical sequential numbering and assign custom constants to specific enum values - such as seen in projects like [FPC_Doom](https://github.com/PascalCorpsman/FPC_DOOM)

Here is a example how to convert this:
```c
enum WeaponType {
    WEAPON_PISTOL = 0,
    WEAPON_SHOTGUN = 1,
    WEAPON_ROCKET = 10
};

int weaponDamage[11]; // Indexed by WeaponType
```
converts to
```pascal
type
  TWeaponType = (WEAPON_PISTOL = 0, WEAPON_SHOTGUN = 1, WEAPON_ROCKET = 10);
var
  weaponDamage: array[0..10] of Integer;
begin
  weaponDamage[Ord(WEAPON_ROCKET)] := 100;
end;
```

Unions -> Bit packet
Defines -> Const

Pointer -> Var / Const
Pointer -> Array

cdecl ( Bei der Definition aber auch bei Callbacks )

! Achtung !, da hier definitionen sind, Kann der Compiler die Korrektheit zum C-Code nicht prüfen, wenn Möglich Tools wie H2pas einsetzen.

Sonderfall: dem C-Code FPC Funktionen bereit stellen (wird nicht von H2pas abgedeckt):
Function memset(str: Pointer; c: integer; n: size_t): Pointer; cdecl public name{$IFDEF CPU64} 'memset'{$ELSE} '_memset'{$ENDIF};


### Transpiling from the source language to FreePascal

   \-> 1. Portierung von Hand (Biosim, FPC_DOOM, Cyclone)
          * Hoher Aufwand, aber volle Kontrolle
          * Vorteil eigene Libs, portierbar, native FreePascal, keine Abhängigkeiten zu externen Libs, Tiefes Verständnis des Portierten Codes, ggf sogar Bugfixes möglich
          * Nachteil z.B. tanh, sehr aufwendig, Änderungen im Original müssen von hand nachgepflegt werden, Fehler die durch die Portierung rein kommen, Man muss die Quellsprache "verstehen"
          * Fallstricke siehe Lessons learned von FPC_Doom
   \-> 1.1. Portierung via KI
          * Nachtel: Riskant ( Code wird nicht verstanden ), compiliert häufig nicht da die KI's FPC nicht so gut können oder funktionen fehlen
          * Vorteil: schnell ( nur für kleine Sachen auch OK )

### Integrating libraries (.dll, .so, .dylib)

   \-> 2. Portierung von Headern via H2Pas (siehe oben) / Ki + DLL

	    2.1 Runtime Linking vs Statisch gelinkt mit beispielen
          Vorteil: Runtime, zur Laufzeit austauschbar, nur laden wenn tatsächlich benötigt (siehe SDL2 in FPC_Atomic)
          Nachteil: Statisch, kein Start ohne gültige Lib
                    Runtime, Extra Code zum Laden Notwendig (für Anfänger ggf. Nicht intuitiv) 
       2.2 Allgemein
          * Nachteil: meist nicht debuggbar, da kein Quellcode zur Verfügung steht
          * Vorteil: flexibel für den Entwickler, da dll's leicht getauscht werden können

### Special case: Integrating intermediate compilation artifacts (.a, .o)
  3.1 Portierung Header wie 2.
  3.2 .a Files "auspacken" zu .o files
  
3.3 Linken benötigt manchmal zusätzlich
{$IFDEF Linux}
{$LINKLIB c}
{$ELSE}
(*
 *
 * Einbinden des Standart C-Headers für 32-Bit, damit kann dann im C-Source
 * <stdio.h> und entsprechend printf verwendet werden :)
 *
 * !! ACHTUNG !!
 * Wenn dieses Feature Aktiv ist, muss der Hacken bei Win32-Gui Anwendung weg,
 * sonst sehen wir nichts.
 *)
{$LINKLIB libmsvcrt}
{$ENDIF}

3.4 Einbinden der Files via: {$Link obj\Filename.o}

Vorteil: kann automatisiert im Prebuild angepasst werden, Debuggbar wenn gdb verwendet wird
Nachteil: benötigt gcc compiler, ggf. Make und weitere (unter Windows eher ein Thema (ggf. Cygwin, MSys2), Linux (y))

### Compile / run the demo application
Windows:
 - Umstellen build.sh -> build.bat
 - ggf einrichten von MinGW ( oder vergleichbarem )
 - F9
Linux:
 - STRG + F9
 - Install_libshared1_so.sh ( Wenn das nicht gemacht wird crasht der Debugger, weil die Statisch gelinkte lib net da ist)
 - F9, run and have fun ;)

