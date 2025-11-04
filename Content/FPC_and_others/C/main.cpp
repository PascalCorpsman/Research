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
#include <cstdio>
#include "shared_o.h"

/*
 * Mock for shared.h
 */
void called_from_c(void)
{
    std::printf("Called from C\n");
}

int main(void)
{
    std::printf("This is the FPC and others demo application.\n");
    /*
     * "Test" calls to all in shared declared functions..
     */
    /*
     * low level C
     */
    print_HelloWorld();

    print_a_plus_b(20, 22);

    int c = calc_a_plus_b(21, 21);
    std::printf("C = %d\n", c);

    uint8_t arr[4] = {1, 2, 3, 4};
    plott_array(arr, 4);

    MyStruct_t s = {10, 5000, 20, 100000};

    print_struct_element(s, eA);
    print_struct_element(s, eB);
    print_struct_element(s, eC);
    print_struct_element(s, eD);

    call_c();

    /*
     * high level C++
     */
    DummyClass *dummy = create_Dummy_class();

    call_B_from_Dummy_class(dummy, 19);
    call_B_from_Dummy_class(dummy, 23);
    print_a_from_Dummy_class(dummy);
    destroy_Dummy_class(dummy);

    return 0;
}
