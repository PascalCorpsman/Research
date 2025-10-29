@echo off
REM ******************************************************************************
REM *                                                                            *
REM * Author      : Uwe Schächterle (Corpsman)                                   *
REM *                                                                            *
REM * This file is part of FPC_and_others                                        *
REM *                                                                            *
REM *  See the file license.md, located under:                                   *
REM *  https://github.com/PascalCorpsman/Software_Licenses/blob/main/license.md  *
REM *  for details about the license.                                            *
REM *                                                                            *
REM *               It is not allowed to change or remove this text from any     *
REM *               source file of the project.                                  *
REM *                                                                            *
REM ******************************************************************************

REM -------------------------------------------------------------------------------
REM C / C++ creation of a .o file which can be linked directly into FPC
REM -------------------------------------------------------------------------------

set CXX=g++
set CXXFLAGS=-g -Wall

set OBJDIR=obj
set OBJFILE=%OBJDIR%\shared_o.o

REM create obj folder if not existing
if not exist "%OBJDIR%" mkdir "%OBJDIR%"

REM delete old file if exists
if exist "%OBJFILE%" del "%OBJFILE%"

echo Compiling C\shared_o.cpp to %OBJFILE% ...
%CXX% %CXXFLAGS% -c C\shared_o.cpp -o %OBJFILE%

REM -------------------------------------------------------------------------------
REM C / C++ creation of .a file
REM -------------------------------------------------------------------------------

set AFILE=libshared_a.a

REM delete old file if exists
if exist "%AFILE%" del "%AFILE%"

echo Compiling C\shared_a.cpp to shared_a.o ...
%CXX% %CXXFLAGS% -c C\shared_a.cpp -o shared_a.o

echo Creating static library %AFILE% ...
ar rcs %AFILE% shared_a.o

REM -------------------------------------------------------------------------------
REM C / C++ creation of libshared1.dll
REM -------------------------------------------------------------------------------

echo Creating shared1.dll ...
%CXX% -g -shared -o shared1.dll C\shared_lib1.cpp

REM -------------------------------------------------------------------------------
REM C / C++ creation of libshared2.dll
REM -------------------------------------------------------------------------------

echo Creating shared2.dll ...
%CXX% -g -shared -o shared2.dll C\shared_lib2.cpp


