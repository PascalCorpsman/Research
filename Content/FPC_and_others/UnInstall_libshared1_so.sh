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
# remove script libshared1.so
#
if [ -f /usr/lib/libshared1.so ]; then
    sudo rm /usr/lib/libshared1.so
fi


