#!/bin/bash

#******************************************************************************
#*                                                                            *
#* Author      : Uwe Schächterle (Corpsman)                                   *
#*                                                                            *
#* This file is part of FPC_and_others                                        *
#*                                                                            *
#*  See the file license.md, located under:                                   *
#*  https://github.com/PascalCorpsman/Software_Licenses/blob/main/license.md  *
#*  for details about the license.                                            *
#*                                                                            *
#*               It is not allowed to change or remove this text from any     *
#*               source file of the project.                                  *
#*                                                                            *
#******************************************************************************

#
# C / C++ creation of a .o file which can be linked direktly into FPC
#
CXX=g++
CXXFLAGS="-g -Wall"

OBJFILE="obj/shared_o.o"

if [ ! -d "obj" ]; then
  mkdir -p obj
fi

# del old file if existing
if [ -f "$OBJFILE" ]; then
    rm "$OBJFILE"
fi

echo "compile C/shared_o.cpp to $OBJFILE ..."
$CXX $CXXFLAGS -c C/shared_o.cpp -o $OBJFILE

#
# C / C++ creation of a .a file
#

AFILE="obj/shared_a.a"

# del old file if existing
if [ -f "$AFILE" ]; then
    rm "$AFILE"
fi

$CXX $CXXFLAGS -c C/shared_a.cpp -o shared_a.o

ar rcs libshared_a.a shared_a.o

#
# C / C++ creation of libshared1.so
#

g++ -g -fPIC -shared C/shared_lib1.cpp -o libshared1.so

#
# C / C++ creation of libshared2.so
#

g++ -g -fPIC -shared C/shared_lib2.cpp -o libshared2.so