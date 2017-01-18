#include "myl.h"

int prints(char *s){

	int i=0;
	while(s[i]!='\0') i++; //find length of string

	__asm__ __volatile__ ("syscall"::"a"(1), "D"(1), "S"(s), "d"(i));
	return i;
}

int printi(int n) { 
 	char s[30], zero='0'; 
 	int i=0, j, k;
 	if(n == 0) s[i++]=zero; 
 	else{ 
  		if(n < 0) { 
  			s[i++]='-'; 
   			n = -n; 
  		} 
  		while(n){ 
   			int dig = n%10; 
   			s[i++] = (char)(zero+dig); 
   			n /= 10; 
  		} 
    	if(s[0] == '-') j = 1; 
  		else j = 0; 
  		k=i-1; 
  		while(j<k){ 
   			char temp=s[j]; 
   			s[j++] = s[k]; 
   			s[k--] = temp; 
  		} 
 	} 
 	__asm__ __volatile__ ( 
  		"movl $1, %%eax \n\t" 
  		"movq $1, %%rdi \n\t" 
  		"syscall \n\t" 
  		: 
  		:"S"(s), "d"(i) 
 	) ;

 	return i;
} 


int readi(int *eP){

	char c;
	int i=-1;
	int neg=0;
	*eP=OK;

	//ignore leading whitespace
	do{
		__asm__ __volatile__ ("syscall"::"a"(0), "D"(0), "S"(&c), "d"(1));	

	}while(c=='\n' || c==' ' || c=='\t' || c=='\r');

	//first non whitespace character
	if(c >= '0' && c <= '9')
		i = c-'0';
	
	else if(c=='-')
		neg=1;
	
	else
		*eP=ERR;

	//rest of the characters
	do{
		__asm__ __volatile__ ("syscall"::"a"(0), "D"(0), "S"(&c), "d"(1));

		if(*eP == ERR)
			continue;
		
		if(c >= '0' && c <= '9'){
			if(i==-1) i=0;
			i = 10*i + c-'0';
		}

		else if(!(c=='\n' || c==' ' || c=='\t' || c=='\r'))
			*eP=ERR;
		
	}while(!(c=='\n' || c==' ' || c=='\t' || c=='\r'));

	if(neg){
		if(i==-1)
			*eP=ERR;
		else
			i=-i;
	}
	return i;
}

int readf(float *fp){

	int e=OK;
	float i = -1;
	int neg=0, dec=0; //negative sign or decimal point has been encountered or not
	float place=1;
	char c;

	//ignore leading whitespace
	do{
		__asm__ __volatile__ ("syscall"::"a"(0), "D"(0), "S"(&c), "d"(1));	

	}while(c=='\n' || c==' ' || c=='\t' || c=='\r');

	//first non whitespace character
	if(c >= '0' && c <= '9')
		i = c-'0';
	
	else if(c=='-')
		neg=1;

	else if(c=='.')
		dec=1;	
	else
		e=ERR;


	//rest of the characters
	do{
		__asm__ __volatile__ ("syscall"::"a"(0), "D"(0), "S"(&c), "d"(1));

		if(e == ERR)
			continue;
		
		if(c >= '0' && c <= '9'){
			if(i==-1) i=0;

			if(dec==0)
				i = 10*i + c-'0';
			else{
				place *= 10;
				i += (c-'0')/place;
			}
		}

		else if(c == '.'){
			if(dec==0)
				dec=1;
			else
				e=ERR;
		}
		

		else if(!(c=='\n' || c==' ' || c=='\t' || c=='\r'))
			e=ERR;
		
	}while(!(c=='\n' || c==' ' || c=='\t' || c=='\r'));

	if(neg){
		if(i==-1) //true when only minus sign is entered and no digit
			e=ERR;
		else
			i=-i;
	}

	if(e==OK)
		*fp = i;
	return e;
}

int printd(float f){

	int l=0;
	char c;

	//print negative sign if required
	if(f<0.0){
		c = '-';
		__asm__ __volatile__ ("syscall"::"a"(1), "D"(1), "S"(&c), "d"(1));
		l++;
		f=-f; //treat as positive number from now
	}

	//print integral part
	int i = f;
	l += printi(i);

	//print decimal point if required
	if(f- (float)((int)f) != 0.0){
		c = '.';
		__asm__ __volatile__ ("syscall"::"a"(1), "D"(1), "S"(&c), "d"(1));
		l++;
	}

	//print fractional part if required
	while(f- (float)((int)f) != 0.0){
		f *= 10;
		c = '0' + ((int)f)%10;
		__asm__ __volatile__ ("syscall"::"a"(1), "D"(1), "S"(&c), "d"(1));
		l++;
	}

	return l;
}
