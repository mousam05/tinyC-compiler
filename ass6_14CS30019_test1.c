int printi(int num);
int prints(char * c);
int readi(int *eP);



int main()
{

	//useless comment

	prints("This is a program to find sum of 2 arrays.\n");

	int a[20];
	int b[20];
	int p, n, x, i;
	int y, z;	

	prints("Enter n: ");	
	n = readi(&p);

	prints("Enter the elements of first array:\n");
	for(i = 0; i < n; i++ )
	{
		x = readi(&p);
		a[i] = x;
	}

	prints("Enter the elements of second array:\n");
	for(i = 0; i < n; i++ )
	{
		x = readi(&p);
		b[i] = x;
	}
	prints("Elements of the product array are:\n");
	for( i = 0; i < n; i++ )
	{
		x = a[i];	
		y = b[i];
		z = x + y;
		printi(z);
		prints(" ");
	}
	prints("\n");
	return 0;
}
