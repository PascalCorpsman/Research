# FPC and others

>
> !! Attention !!
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

ctypes

cdecl ( Bei der Definition aber auch bei Callbacks )

Pointer -> Var / Const
Pointer -> Array

Struct -> Record ( {$PACKRECORDS C} )
enum -> 1. Element mit 0, Problem wenn im Enum "gesprungen" wird wie bei FPC_Doom -> Auffüllen mit "dummy" Elementen

Unions -> Bit packet

Defines -> Const

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

