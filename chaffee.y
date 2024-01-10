%{
#define YYSTYPE int
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdbool.h>


int vars[100];
int null = 0;
int is_block = 0;
bool is_if_inner = false;
bool is_func_block = false;


typedef struct node node;
struct node
{
   int token;
   int val;
   node* ptr1;
   node* ptr2;
};


typedef struct {
  bool *array;
  int size;
  int index;
} Array;

typedef struct {
  long *array;
  int size;
  int index;
} Long_array;

struct func {
   char name[25];
   Long_array body;
   struct func *next;
};

struct func *head = NULL;



Array if_cond;
Array while_cond;

Long_array while_body;
Long_array while_cond_exp;



void yyerror (char* s);
int yylex(void);
long makeNode(int token, int val, long p1, long p2);
int getVar(int ascii);
void storeVar(int ascii, int val);
void runStmt(long ptr);
void computeStmt(node* tree);
void cleanUp(node* tree);
void systemError(char* str);
int parseExpr(node* tree);
bool parseCond(node* tree);
int parseVal(node* tree);
long setBlock(int i);
void computeBlockStmt(node* tree);
void removeLastElement(Array *a);
bool getLastElement(Array *a);
bool getFirstElement(Array *a);
void insertElement(Array *a, bool element);
void initArray(Array *a);
void initLongArray(Long_array *a);
void insertLongElement(Long_array *a, long element);
long getLastLongElement(Long_array *a);
long getFirstLongElement(Long_array *a);
void removeLastLongElement(Long_array *a);
void freeLongArray(Long_array *a);
struct func* findFunc(char name[]);
void createFunction(char name[]);
void addFuncBody(long body);
void setFunction(node* tree);

%}


%start SQRL 

%token NUM
%token VAL
%token VAR
%token PRINT
%token STRING
%token PLUS
%token MINUS
%token MULT
%token DIV
%token INITIALIZE
%token INPUT
%token FUNC
%token CALL
%token IF
%token WHILE
%token EQL
%token GT
%token LT
%token IFELSE
%token ELSE
%token END_WHILE
%token END_IF
%token TITLE
%token END_FUNC




%left '-' '+' 
%left '*' '/'
%right '^'   



%%

SQRL:     code'.'
;

code:     line code         
        | line                           
;




line:     stmt                           { runStmt($1); }
;


stmt:     PRINT exp';'                   { $$ = makeNode(PRINT, 0, $2, null); }
        | VAR '=' exp';'                 { $$ = makeNode(INITIALIZE, $1, $3, null); }
        | INPUT VAR';'                   { $$ = makeNode(INPUT, $2, null, null); }
        | IF cond line                   { $$ = makeNode(IF, 0, $2, null); }
        | ELSE line                      { $$ = makeNode(ELSE, 0, null, null);}
        | WHILE cond line                { $$ = makeNode(WHILE, 0, $2, null); }
        | END_WHILE';'                   { $$ = makeNode(END_WHILE, 0, null, null); }
        | END_IF';'                      { $$ = makeNode(END_IF, 0, null, null); }
        | FUNC TITLE line                { $$ = makeNode(FUNC, $2, null, null); }
        | END_FUNC';'                    { $$ = makeNode(END_FUNC, 0, null, null); }
        | CALL TITLE';'                  { $$ = makeNode(CALL, $2, null, null); } 
        | '{'                            { $$ = setBlock(1); }     
        | '}'                            { $$ = setBlock(-1); }

;



exp:      val               { $$ = makeNode(VAL, 0, $1, null); }
        | val '+' val       { $$ = makeNode(PLUS, 0, $1, $3); }
        | val '*' val       { $$ = makeNode(MULT, 0, $1, $3); }
        | val '/' val       { $$ = makeNode(DIV, 0, $1, $3); }
        | val '-' val       { $$ = makeNode(MINUS, 0, $1, $3); }
        | STRING            { $$ = makeNode(STRING, $1, null, null); } 
;

cond:     val '=' '=' val      { $$ = makeNode(EQL, 0, $1, $4); }
        | val '>' val          { $$ = makeNode(GT, 0, $1, $3); }
        | val '<' val          { $$ = makeNode(LT, 0, $1, $3); }
;


val:      VAR               { $$ = makeNode(VAR, $1, null, null); }
        | NUM               { $$ = makeNode(NUM, $1, null, null); }
;


%%



int main ()
{
  initArray(&if_cond);
  initArray(&while_cond);
  initLongArray(&while_cond_exp);
  initLongArray(&while_body);
  yyparse ();
}


long makeNode(int token, int val, long p1, long p2)
{
   node* myNode;

   myNode = (node*)malloc( sizeof(node) );
   myNode->token = token;
   myNode->val = val;
   myNode->ptr1 = (node*)p1;
   myNode->ptr2 = (node*)p2;

   return (long)myNode;
}


void yyerror (char *s) 
{
  printf ("%s\n", s);
}



void runStmt(long ptr)
{
  if(ptr != 0)
  {
    if(is_block == 0)
    {
      computeStmt((node*)ptr);

    }
    else if(is_func_block)
    {
      setFunction((node*)ptr);
    }
    else
    {
      computeBlockStmt((node*)ptr);
    }
  }
}





long setBlock(int i)
{
  is_block = is_block + i;
  return 0;
}



void computeStmt(node* tree)
{
  int input_val;
  int i;
  struct func *found_func;
  char *func_name;
  switch(tree->token)
  {
    case PRINT:
      if(tree->ptr1->token == STRING){
        printf("%s\n", tree->ptr1->val);
      }
      else{
      printf("%d\n", parseExpr(tree->ptr1));
      }
      break;
    case INITIALIZE:
      storeVar(tree->val,parseExpr(tree->ptr1));
      break;
    case INPUT:
      printf("%c = ", tree->val);
      scanf("%d", &input_val);
      storeVar(tree->val,input_val);
      break;
    case CALL:
      func_name = (char*)tree->val;   
      found_func = findFunc(func_name);
      for (i = 0; i <= found_func->body.index; i++)
      {
        computeBlockStmt((node*)found_func->body.array[i]);
      }
      break;

    default:
     computeBlockStmt(tree);
  }
}


void setFunction(node* tree)
{
  switch(tree->token)
  {
    case END_FUNC:
      is_func_block = false;
      break;
    default:
      addFuncBody((long)tree);
  }
}

void computeBlockStmt(node* tree)
{
  bool buffer;
  int i;
  char *func_name;
  switch(tree->token)
  {
    case FUNC:
      is_func_block = true;
      func_name = (char*)tree->val;
      createFunction(func_name);
      break;

    case IF:
      if(while_cond.size != 0)
      {
        is_if_inner = true;
        insertLongElement(&while_body, (long)tree); 
      }
      insertElement(&if_cond, parseCond(tree->ptr1));
      break;

    case WHILE:
      insertElement(&while_cond, parseCond(tree->ptr1));
      insertLongElement(&while_cond_exp, (long)tree);
      break;

    case ELSE:
      if(is_if_inner)
      {
        insertLongElement(&while_body, (long)tree); 
      }
      buffer = getLastElement(&if_cond);
      removeLastElement(&if_cond);
      buffer = !buffer;
      insertElement(&if_cond, buffer);
      break;

    case END_IF:
      if(is_if_inner)
      {
        insertLongElement(&while_body, (long)tree); 
      }
      removeLastElement(&if_cond);
      break;

    case END_WHILE:
      removeLastElement(&while_cond);
      is_if_inner = false;
      while(while_body.size != 0 && parseCond(((node*)getLastLongElement(&while_cond_exp))->ptr1))
      {
        for(i = 0; i <= while_body.index; i = i + 1)
        {
          computeBlockStmt((node*)(while_body.array[i]));
        }
      }
      removeLastLongElement(&while_cond_exp);
      freeLongArray(&while_body);
      initLongArray(&while_body);
      break;


    default:
      if(while_cond.size != 0 && getLastElement(&while_cond))    /// if while block exists and its cond is true
      {
        if(if_cond.size == 0)
        {
          insertLongElement(&while_body, (long)tree); 
        }
        else if(getLastElement(&if_cond) && getFirstElement(&if_cond))
        {
          insertLongElement(&while_body, (long)tree);
        }
        else if(is_if_inner)
        {
          insertLongElement(&while_body, (long)tree);
        }
      }
      else if(while_cond.size == 0 && getLastElement(&if_cond) && getFirstElement(&if_cond))    /// if while block does NOT exist and if block is true
      { 
       computeStmt(tree);
      }
      else if(if_cond.size == 0)       /// if if block does NOT exist
      {
        computeStmt(tree);
      }
  }
}




int parseExpr(node* tree)
{
      switch(tree->token)
      {
        case VAL:
          return parseVal(tree->ptr1);
        case PLUS:
          return parseVal(tree->ptr1) + parseVal(tree->ptr2);
        case MINUS:
          return parseVal(tree->ptr1) - parseVal(tree->ptr2);
        case MULT:
          return parseVal(tree->ptr1) * parseVal(tree->ptr2);
        case DIV:
          return parseVal(tree->ptr1) / parseVal(tree->ptr2);
        default:
          systemError("parseExpr");
      }
      return 1;

}


bool parseCond(node* tree)
{
    switch(tree->token)
      {
        case EQL:
          return parseVal(tree->ptr1) == parseVal(tree->ptr2);
          break; 
        case GT:
          return parseVal(tree->ptr1) > parseVal(tree->ptr2);
          break;
        case LT:
          return parseVal(tree->ptr1) < parseVal(tree->ptr2);
          break;
        default:
          systemError("parseCond");
      }    
    return 0;
} 


int parseVal(node* tree)
{
   switch(tree->token)
   {
     case NUM:
        return tree->val;
     case VAR:
        return getVar(tree->val);
     default:
        systemError("parseVal"); 
   }

}


int getVar(int ascii)
{
  return vars[ascii-97];
}


void storeVar(int ascii, int val)
{
  vars[ascii-97] = val;
}


void cleanUp(node* tree)
{
   if ((long)tree->ptr1 != null)
      cleanUp(tree->ptr1);
   if ((long)tree->ptr2 != null)
      cleanUp(tree->ptr2);
   free(tree);
}


void systemError(char* str)
{
  printf ("ERROR: in '%s', something horrible went wrong.\n", str);
}

void initArray(Array *a) {
  a->size = 0;
  a->array = malloc(a->size * sizeof(bool));
  a->index = -1;
}

void initLongArray(Long_array *a) {
  a->size = 0;
  a->array = malloc(a->size * sizeof(long));
  a->index = -1;
}


void insertElement(Array *a, bool element) {
  a->size = a->size + 1;
  a->index = a->index + 1;
  a->array = realloc(a->array, a->size * sizeof(bool));
  a->array[a->index] = element;
}



void insertLongElement(Long_array *a, long element) {
  a->size = a->size + 1;
  a->index = a->index + 1;
  a->array = realloc(a->array, a->size * sizeof(long));
  a->array[a->index] = element;
}



bool getLastElement(Array *a) {
  if (a->size  >= 1)
  {
     return a->array[a->index];
  }
  return false;
}

long getLastLongElement(Long_array *a) {
  if (a->size  >= 1)
  {
     return a->array[a->index];
  }
  return 0;
}



bool getFirstElement(Array *a) {
  if (a->size  >= 1)
  {
     return a->array[0];
  }
  return false;
}

long getFirstLongElement(Long_array *a) {
  if (a->size  >= 1)
  {
     return a->array[0];
  }
  return 0;
}


 
void removeLastElement(Array *a) {
   if (a->size  >= 1)
   {
      a->size = a->size - 1;
      a->index = a->index - 1;
      a->array = realloc(a->array, a->size * sizeof(bool));
   }
}



void removeLastLongElement(Long_array *a) {
   if (a->size  >= 1)
   {
      a->size = a->size - 1;
      a->index = a->index - 1;
      a->array = realloc(a->array, a->size * sizeof(long));
   }
}



void freeLongArray(Long_array *a) {
  free(a->array);
}



void addFuncBody(long body)
{  
    insertLongElement(&head->body, body);
}


void createFunction(char name[]) 
{

   struct func *link = (struct func*) malloc(sizeof(struct func));
   initLongArray(&link->body);
	
   strcpy(link->name, name);
	
   link->next = head;
	
   head = link;
}


struct func* findFunc(char name[]) {

   struct func* current = head;

   if(head == NULL) {
      return NULL;
   }

   while(strcmp(current->name, name) != 0) {
      if(current->next == NULL) {
         return NULL;
      } else {
         current = current->next;
      }
   }      
	
   return current;
}


