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
# export the local path as library path so that project1 can find libshared1.so
#
export LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH

./project1



