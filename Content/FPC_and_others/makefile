# ******************************************************************************
# *                                                                            *
# * Author      : Uwe Schächterle (Corpsman)                                   *
# *                                                                            *
# * This file is part of FPC_and_others                                        *
# *                                                                            *
# *  See the file license.md, located under:                                   *
# *  https://github.com/PascalCorpsman/Software_Licenses/blob/main/license.md  *
# *  for details about the license.                                            *
# *                                                                            *
# *               It is not allowed to change or remove this text from any     *
# *               source file of the project.                                  *
# *                                                                            *
# ******************************************************************************

CXX := g++
CXXFLAGS := -g -Wall

OBJDIR := obj
OBJFILE := $(OBJDIR)/shared_o.o
AFILE := libshared_a.a

UNAME_S := $(shell uname -s)

ifeq ($(UNAME_S),Linux)
	SHARED1 := libshared1.so
	SHARED2 := libshared2.so
	SHARED_FLAGS := -shared -fPIC
else ifeq ($(UNAME_S),Darwin)
	SHARED1 := libshared1.dylib
	SHARED2 := libshared2.dylib
	SHARED_FLAGS := -shared -fPIC
else
	SHARED1 := shared1.dll
	SHARED2 := shared2.dll
	SHARED_FLAGS := -shared
endif

.PHONY: all clean

all: $(OBJFILE) $(AFILE) $(SHARED1) $(SHARED2)

$(OBJDIR):
	mkdir -p $(OBJDIR)

$(OBJFILE): C/shared_o.cpp | $(OBJDIR)
	echo "Compiling C/shared_o.cpp to $(OBJFILE) ..."
	$(CXX) $(CXXFLAGS) -c $< -o $@

shared_a.o: C/shared_a.cpp
	echo "Compiling C/shared_a.cpp to shared_a.o ..."
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(AFILE): shared_a.o
	echo "Creating static library $(AFILE) ..."
	ar rcs $@ $<

$(SHARED1): C/shared_lib1.cpp
	echo "Creating $(SHARED1) ..."
	$(CXX) $(CXXFLAGS) $(SHARED_FLAGS) -o $@ $<

$(SHARED2): C/shared_lib2.cpp
	echo "Creating $(SHARED2) ..."
	$(CXX) $(CXXFLAGS) $(SHARED_FLAGS) -o $@ $<

clean:
	echo "Cleaning up..."
	rm -f $(OBJFILE) shared_a.o $(AFILE) $(SHARED1) $(SHARED2)
	rm -rf $(OBJDIR)
