// BigNum.c ... LARGE positive integer values

#include <assert.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "BigNum.h"

// Initialise a BigNum to N bytes, all zero
void initBigNum (BigNum *bn, int Nbytes)
{
    bn->bytes = malloc(sizeof(int) * Nbytes);
    assert(bn->bytes != NULL);
    for (bn->nbytes = 0; bn->nbytes < Nbytes; bn->nbytes++)
        bn->bytes[bn->nbytes] = '0';
}

// Add two BigNums and store result in a third BigNum
void addBigNums (BigNum bnA, BigNum bnB, BigNum *res)
{
    int length = (bnA.nbytes > bnB.nbytes) ? bnA.nbytes : bnB.nbytes;
    res->nbytes = (res->nbytes < length) ? (length + 1): res->nbytes;
    res->bytes = realloc(res->bytes, sizeof(int) * res->nbytes);
    assert(res->bytes != NULL);
	for (int i = 0; i < res->nbytes; i++) {
        res->bytes[i] = (isdigit(res->bytes[i])) ? res->bytes[i] : '0';
        char num = (bnA.bytes[i]) * (bnA.nbytes >= i) + (bnB.bytes[i]) * 
                    (bnB.nbytes >= i) + res->bytes[i] - ('0') * (i < length) - 
                    ('0') * (isdigit(bnA.bytes[i]) && isdigit(bnB.bytes[i]));
        res->bytes[i + 1] = (num > '9') ? '1' : res->bytes[i + 1];
	    res->bytes[i] = (num > '9') ? (num - 10): (num);
    }
}

// Set the value of a BigNum from a string of digits
// Returns 1 if it *was* a string of digits, 0 otherwise
int scanBigNum (char *s, BigNum *bn)
{
    int length = strlen(s);
    int check = 0;
    bn->nbytes = (bn->nbytes < length) ? length : bn->nbytes;
    bn->bytes = realloc(bn->bytes, sizeof(int) * bn->nbytes);
    assert(bn->bytes != NULL);
	for (int i = 0; length > 0; i++){
        for (length = length; !isdigit(s[length - 1]) && length > 0; length--){
            check += 1; 
        }
	    bn->bytes[i] = (isdigit(s[length - 1])) ? s[length - 1] : '0';
	    length--;
	}
    return (check == strlen(s)) ? 0 : 1;
}

// Display a BigNum in decimal format
void showBigNum (BigNum bn)
{
	for (int i = bn.nbytes - 1, flag = 0; i >= 0; i--) {
        flag = (bn.bytes[i] == '0' && flag == 0) ? 0 : 1;
        if (flag == 1){
            printf("%c", bn.bytes[i]);
        }
	}
}
