int printi(int n);
int readi(int *eP);
int prints(char *str);

int bsearch(int arr[10], int left, int right, int key)
{
	int mid, temp;
	if(left < right || left == right)
	{
		mid = (left + right)/2;
		if(arr[mid] == key)
			return mid;
		else if (key < arr[mid])
		{
			temp = bsearch(arr, left, mid - 1, key);
			return temp;
		}
		else
		{
			temp = bsearch(arr,mid + 1, right, key);
			return temp;			
		}
	}
	else
		return -1;		
}
int main()
{
	int n, p, i, x, value;
	int a[10];
	prints("This function implements binary search recursively.\n");
	prints("Enter n<10: ");
	n = readi(&p);
	prints("Enter the sorted array.\n");
	for(i=0; i<n ;i++)
	{
		x = readi(&p);
		a[i] = x;
	}	
	prints("Enter the value to search for: ");
	value = readi(&p);
	int retval;
	retval = bsearch(a, 0, n-1, value);

	if(retval == -1)
		prints("Value not found.\n");
	else
	{
		prints("Value found at index ");
		printi(retval);
		prints("\n");
	}
	return 0;
}
