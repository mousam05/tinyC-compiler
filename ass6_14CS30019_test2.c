int printi(int num);
int prints(char * c);
int readi(int *eP);

int f(int *a)
{
    int b;
    b = *a;
    b = b + 17;
    return b;
}

int main()
{
    int a,b;
    int *e;

    b = 54;
    e = &b;

    prints("This function adds 17 to its argument, passed by pointer.\n");
    prints("Value passed to function: ");
    printi(b);
    prints("\n");

    /*this is a useless
    multi-line
    comment*/
    
    a = f(e);
    prints("Value returned from function: ");
    printi(a);
    prints("\n");
    
    prints("Enter an integer: ");
    prints("\n");
    b = readi(e);
    prints("Entered integer is: ");
    printi(b);
    prints("\n");
    
    return 0;
}
