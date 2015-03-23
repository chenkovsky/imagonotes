#ifndef _UTIL_H_
#define _UTIL_H_



#include <assert.h>

typedef char *string;
typedef char bool;

#define TRUE 1
#define FALSE 0

void *checked_malloc(int);
string String(char *);
string getstring1(char *);
string sappend(char *s,char * text);

typedef struct U_boolList_ *U_boolList;
struct U_boolList_ {bool head; U_boolList tail;};
U_boolList U_BoolList(bool head, U_boolList tail);


typedef struct table *Table_;
struct table{string id; int value;Table_ tail;};
Table_  Table(string id, int value, Table_ tail);
void update(Table_ t, string s, int value);
int lookup(Table_  t, string s);
void dumptable(Table_  t);


#endif /* _UTIL_H_ */
