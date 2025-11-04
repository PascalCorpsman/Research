/******************************************************************************/
/*                                                                            */
/* Author      : Uwe Schächterle (Corpsman)                                   */
/*                                                                            */
/* This file is part of FPC_and_others                                        */
/*                                                                            */
/*  See the file license.md, located under:                                   */
/*  https://github.com/PascalCorpsman/Software_Licenses/blob/main/license.md  */
/*  for details about the license.                                            */
/*                                                                            */
/*               It is not allowed to change or remove this text from any     */
/*               source file of the project.                                  */
/*                                                                            */
/******************************************************************************/
#include "shared_o.h"
#include <cstdio>

void print_HelloWorld(void)
{
    std::printf("Hello World.\n");
}

void print_a_plus_b(int a, int b)
{
    std::printf("A + B = %d\n", a + b);
}

int calc_a_plus_b(int a, int b)
{
    return a + b;
}

void plott_array(const uint8_t *array, uint8_t length)
{
    if (!array)
        return;

    std::printf("Array: ");
    for (uint8_t i = 0; i < length; ++i)
    {
        printf("%u ", array[i]);
    }
    std::printf("\n");
}

void print_struct_element(const MyStruct_t &s, MyEnum_t e)
{
    switch (e)
    {
    case eA:
        std::printf("MyStruct_t.a = %u\n", s.a);
        break;
    case eB:
        std::printf("MyStruct_t.b = %u\n", s.b);
        break;
    case eC:
        std::printf("MyStruct_t.c = %u\n", s.c);
        break;
    case eD:
        std::printf("MyStruct_t.d = %u\n", s.d);
        break;
    default:
        std::printf("unknown enum\n");
    }
}

void call_c(void)
{
    called_from_c();
}

class DummyClass
{
public:
    int a;

    DummyClass(void) : a(0) {}

    void B(int c)
    {
        std::printf("DummyClass.B(%d)\n", c);
        a += c;
    }
};

DummyClass *create_Dummy_class(void)
{
    return new DummyClass();
}

void destroy_Dummy_class(DummyClass *ptr)
{
    if (ptr)
    {
        delete ptr;
    }
}

void call_B_from_Dummy_class(DummyClass *ptr, int value)
{
    if (ptr)
    {
        ptr->B(value);
    }
}

void print_a_from_Dummy_class(DummyClass *ptr)
{
    if (ptr)
    {
        std::printf("Dummy_class.A = %d\n", ptr->a);
    }
}
