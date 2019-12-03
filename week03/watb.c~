// COMP1521 19t2 ... lab 03: where are the bits?
// watb.c: determine bit-field order

#include <stdio.h>
#include <stdlib.h>

struct _bit_fields {
	unsigned int a : 4;
	unsigned int b : 8;
	unsigned int c : 20;
};

int main (void)
{
	struct _bit_fields x;
    x.a = 1;
    x.b = 1;
    x.c = 1;
    unsigned int *p = (unsigned int *) &x;
    unsigned int mask = 1;
	printf ("%zu\n", sizeof (x));
    for (int i = 0; i < 32; i++){
        if ((*p & mask) > 0){
            printf("1");
        } else {
            printf ("0");
        }
        if (i == 3 || i == 11){
            printf(" ");
        }
        mask = mask << 1;
    }
    printf("\n");
	return EXIT_SUCCESS;
}
