int printi(int num);
int prints(char * c);
int readi(int *eP);

int gcd(int m, int n)
{
    if (n!=0)
    {
		int a, b;
		a = m % n;
		b = gcd(n, a);
	        return b;
    }
    else 
       return m;
}

int main()
{
	int a, b, c, p;
	prints("This program computes the GCD of 2 numbers.\n");
	prints("Enter a>0: ");
	a = readi(&p);
	prints("Enter b>0: ");
	b = readi(&p);	
	prints("The greatest common divisor of ");
	printi(a);
	prints(" & ");
	printi(b);
	prints(" is : ");
	c = gcd(a, b);
	printi(c);
	prints("\n");	
	return 0;
}
