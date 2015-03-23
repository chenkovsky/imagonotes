/*
 * util.c - commonly used utility functions.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "util.h"
void *checked_malloc(int len)
{void *p = malloc(len);
 if (!p) {
    fprintf(stderr,"\nRan out of memory!\n");
    exit(1);
 }
 memset(p,0,len);
 return p;
}

string String(char *s)
{string p = checked_malloc(strlen(s)+1);
 strcpy(p,s);
 return p;
}

string sappend(char *s,char * text)
{
      if(!s)
      	{
      	      string p = checked_malloc(strlen(text)+1);
	      
	      strcpy(p,text);
	      return p;
      	}
      string ns = checked_malloc(strlen(s) + strlen(text) + 1);
      strcpy(ns,s);
      strcat(ns,text);
   //   free(s);
      return ns;
}

string getstring1(char *s)
{
      if(!s)   return NULL;
      string p = checked_malloc(strlen(s) + 1);
      char * ps,*pp;
      ps = s;
      pp = p;
      while(*ps != '\0')
      	{
      	      if(*ps != '\\')
			 *pp++ = *ps++;
	      else  if(*(ps+1) != '\0' && *(ps+1) == 'n')
		  	{*pp++ = 10;ps++;ps++;}
	      else if(*(ps+1) != '\0' && *(ps+1) == 't')
		  	{*pp++ = 9;ps++;ps++;}
	      else if(*(ps+1) != '\0' && *(ps+1) == '"')
		  	{*pp++ = 34;ps++;ps++;}
	      else if(*(ps+1) != '\0' && *(ps+1) == '\\')
		  	{*pp++ = 92;ps++;ps++;}
	      else if(*(ps+1) == 9 ||*(ps+1) == 10 ||*(ps+1) == 32 )
	      	{
			char * temp = ps;
	              temp++;
		       while(*temp != '\\' && (*temp == 9 || *temp == 10 || *temp == 32) && *temp != '\0')
			   	temp++;
			 if(*temp == '\\')
			 	ps = temp + 1;
			 else
			 	{ps++;*pp++ = '\\';}
	      	}
		else if(*(ps+1) != '\0' && *(ps+2) != '\0' && *(ps+3) != '\0' 
			    && *(ps+1) >= 48 && *(ps+1) <= 57 
			    && *(ps+2) >= 48 && *(ps+2) <= 57
			    && *(ps+3) >= 48 && *(ps+3) <= 57)
			{
			       string temp = checked_malloc(4);
				 *ps++;
				*temp++ = *ps++;
				*temp++ = *ps++;
				*temp++ = *ps++;
				*temp = '\0';
		  		*pp++ = atoi(temp);
			}
		else if(*(ps+1) == '^' && *(ps+2) >= '@' && *(ps+2) <= '_')
			{
			       ps++;ps++;
				*pp++ = (*ps)-64;
				ps++;
			}
	       else    *pp++ = *ps++;
		  	
      	}
	*pp = '\0';
	return p;
}

U_boolList U_BoolList(bool head, U_boolList tail)
{ U_boolList list = checked_malloc(sizeof(*list));
  list->head = head;
  list->tail = tail;
  return list;
}

Table_  Table(string id, int value, Table_ tail)
{
     	 Table_  t = checked_malloc(sizeof(*t));
      	t->id = id;
    	 t->value = value;
   	 t->tail = tail;
	return t;
	
}

void update(Table_ t, string s, int value)
{
      Table_ Iter = t;
      while(Iter->tail)
      	{
      	      Iter = Iter->tail;
	      if(!strcmp(Iter->id,s))
		  	{
		  	   Iter->value = value;
			   return;
	        	}
      	}
	Table_ newnode = Table(s,value,NULL);
	Iter->tail = newnode;
}

int lookup(Table_  t, string s)
{
       Table_  Iter = t;
       while(Iter->tail)
       	{
       	        Iter = Iter->tail;
       	        if(!strcmp(Iter->id,s))
					      return Iter->value;
       	}
	 printf("Identifier %s does not exist!\n ", s);
	 exit(1);
}

void dumptable(Table_  t)
{
     Table_  Iter = t;
     while(Iter->tail)
     	{
     	        Iter = Iter->tail;
		 printf(" %s  : %d \n", Iter->id, Iter->value);
     	}
}


