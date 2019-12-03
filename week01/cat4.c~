// COMP1521 19T2 ... lab 1
// cat4: Copy input to output

#include <stdio.h>
#include <stdlib.h>

static void copy (FILE *, FILE *);

int main (int argc, char *argv[])
{
    if (argc == 1){
	    copy (stdin, stdout);
    } else {
        FILE *fp;
        for (int i = 1; i <= argc; i++){ 
            fp = fopen(argv[i], "r");
            if (fp == NULL){
                printf("Can't read %s", argv[i]);
            } else {
                copy (fp, stdout);
                fclose(fp);
            }
        }
    }
	return EXIT_SUCCESS;
}

// Copy contents of input to output, char-by-char
// Assumes both files open in appropriate mode
static void copy (FILE *input, FILE *output)
{
    char ch[BUFSIZ];
    while ((fgets(ch, BUFSIZ, input)) != NULL){
        fputs(ch, output);
    }
}
