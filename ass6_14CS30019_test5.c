int printi(int num);
int prints(char * c);
int readi(int *eP);

//returns nth fibonacci number
int fibonacci(int n) 
{

   if(n == 0)
   {
      return 0;
   }
	
   if(n == 1) 
   {
      return 1;
   }
   int a,b,c;
   a = fibonacci(n-1);
   b = fibonacci(n-2);
   c = a + b;
   return c;
}

//returns factorial of n
int factorial(int n)
{

  if (n == 0)
    return 1;
  else
  {
	int a;
	a = factorial(n-1);
  }
    return(n * a);
}

int main()
{
	int num, fact, fib;
	prints("This program tests recursive functions.\n");

	prints("Enter a number(<=10) for finding factorial: ");
	int p;
	num = readi(&p);
	if(num>10)
	{
		prints("Sorry. Enter number is too large.\n");
	}
	else
	{
		fact = factorial(num);
		prints("The factorial of ");
		printi(num);
		prints(" is : ");
		printi(fact);
		prints("\n");
	}

	prints("Enter a number(<=10) for finding nth Fibonacci number: ");
	int p;
	num = readi(&p);
	if(num>10)
	{
		prints("Sorry. Enter number is too large.\n");
	}
	else
	{
		fib = fibonacci(num);
		prints("The ");
		printi(num);
		prints("th fibonacci no. is ");
		printi(fib);
		prints("\n");
	}
	
	return 0;
}
