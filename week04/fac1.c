// Simple factorial calculator
//
// Doesn't do error checking
// n < 1 or not a number produce n! = 1

#include <stdio.h>

int main (void)
{
	int n = 0;
	printf ("n  = ");
	scanf ("%d", &n);
	int fac = 1;
	for (int i = 1; i <= n; i++)
		fac *= i;
	printf ("n! = %d\n", fac);
	return 0;
}
