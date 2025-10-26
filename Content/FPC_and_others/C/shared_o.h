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
#include <stdint.h>
#include <iostream>
#ifdef __cplusplus
extern "C"
{
#endif

    /*
     * Easy C-Like examples ;)
     */

    // Struktur Definition
    struct MyStruct_t
    {
        uint8_t a;
        uint16_t b;
        uint8_t c;
        int32_t d;
    };

    enum MyEnum_t
    {
        eA = 0u,
        eB,
        eC,
        eD
    };

    void print_HelloWorld(void);

    void print_a_plus_b(int a, int b);

    int calc_a_plus_b(int a, int b);

    void plott_array(const uint8_t *array, uint8_t length);

    void print_struct_element(const MyStruct_t &s, MyEnum_t e);

    /*
     * C-Code that calls a function named "called_from_c"
     */
    void call_c(void);

    void called_from_c(void); // Declaration of "called_from_c", this function needs to be defined by the FPC-Code

    /*
     * How to work with C++ Classes
     */

    struct DummyClass;

    DummyClass *create_Dummy_class(void);
    void destroy_Dummy_class(DummyClass *ptr);

    void call_B_from_Dummy_class(DummyClass *ptr, int value);

    void print_a_from_Dummy_class(DummyClass *ptr);

#ifdef __cplusplus
}
#endif
