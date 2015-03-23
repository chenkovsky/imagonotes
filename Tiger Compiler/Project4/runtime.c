#define getchar get_char
#include <stdio.h>
#include <stdlib.h>

int *initArray(int size, int init)
{	printf("array_init:%x\n",init);
	printf("array size:%d\n",size);
	int i;
 	int *a = (int *)malloc(size*sizeof(int));
 	for(i=0;i<size;i++) a[i]=init;
 	return a;
}

int *allocRecord(int size)
{
	int i;
 	int *a;
	printf("record size:%d\n",size);
 	a = (int *)malloc(size*sizeof(int));
 	for(i=0;i<size;i++) a[i] = 0;
 	return a;
}

typedef char * string;

int stringEqual(int link, string s, string t)
{
	return !strcmp(s, t);
}

void print(int link, string s)
{
 	printf("%s", s);
}

void printi(int link, int i)
{
	printf("%d", i);
}

void flush(int link)
{
	fflush(stdout);
}

int main()
{
 	return tigermain(0 /* static link */);
}

int ord(int link, string s)
{
 	if (s && !s[0]) return -1;
 	else return s[0];
}

string chr(int link, int i)
{
	if (i<0 || i>=256) 
   	{
   		printf("chr(%d) out of range\n",i); 
		exit(1);
	}
	string t=(string)malloc(2);
	t[0]=i;
	t[1]='\0';
	return t;
 }

int size(int link, string s)
{ 
	int i;
 	for(i = 0; s[i]; i++);
	return i;
}

string substring(int link, string s, int first, int n)
{
	 int len = size(link, s);
	 if (first<0 || first+n>len)
	 {
	 	printf("substring([%d],%d,%d) out of range\n",len,first,n);
	    	exit(1);
	 }
	 string t=(string)malloc(n+1);
	 int i;
	 for(i=0; i< n; i++)
	 	t[i]=s[first+i];
	 t[i]='\0';
	 return t;
}

string concat(int link, string a, string b)
{
	int lena = size(link, a);
	int lenb = size(link, b);
	if(lena==0) return b;
	else if(lenb==0) return a;
	else
	{
		string t=(string)malloc(lena+lenb+1);
		int i;
		for(i=0;i<lena;i++)
			t[i] = a[i];
		for(i=0;i<lenb;i++)
			t[i+lena] = b[i];
		t[i]='\0';
		return t;
	}
}

int not(int link, int i)
{ 
	return !i;
}


#undef getchar

string getchar(int link)
{
	int i=getc(stdin);
 	if (i==EOF) return "";
 	else
 	{
 		string t = malloc(2);
		t[0] = i;
		t[1] = '\0';
		return t;
 	}
}
int *get_staticlink(int aim){
	int *v = &aim;
	int *ebp = (int*)*((int*)(((int)v)-8));
	int* level= NULL;
	do{
		level = (int*)((int)ebp+8);
		ebp = (int*)(*ebp);
	}while((*level) != aim);
	return ebp;
}
