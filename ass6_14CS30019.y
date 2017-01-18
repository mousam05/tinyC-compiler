%{    #include <string>
#include <iostream>
#include <fstream>
using namespace std;
extern "C" int yylex();
void yyerror(string s);
extern int yyparse();
#include "ass6_14CS30019_translator.h"
int literal_count = 0;
SymbolTable GT;
SymbolTable *curr_sym = &GT;
typeInf *global_type;
int global_width;
QuadArr arrQ;
SymbolTable *sym = &GT;
vector<string> string_lits;
%}

%union {    int intval;
  float floatval;
  ExpressionAtr *expr_attr;
  declaration *decclist;
  init_dec_list *init_dec_list_;
  typeInf *type_;
  char charval;
  string *str;
  func_def *func_def_;
  func_list *func_list_;}

%token RESTRICT_KEYWORD;
%token UNSIGNED_KEYWORD;
%token AUTO_KEYWORD;
%token ENUM_KEYWORD;
%token BREAK_KEYWORD;
%token SIGNED_KEYWORD;
%token WHILE_KEYWORD;
%token CONST_KEYWORD;
%token GOTO_KEYWORD;
%token SIZEOF_KEYWORD;
%token BOOL_KEYWORD;
%token CONTINUE_KEYWORD;
%token IF_KEYWORD;
%token STATIC_KEYWORD;
%token COMPLEX_KEYWORD;
%token DEFAULT_KEYWORD;
%token INLINE_KEYWORD;
%token STRUCT_KEYWORD;
%token IMAGINARY_KEYWORD;
%token DO_KEYWORD;
%token INT_KEYWORD;
%token SWITCH_KEYWORD;
%token DOUBLE_KEYWORD;
%token LONG_KEYWORD;
%token TYPEDEF_KEYWORD;
%token EXTERN_KEYWORD;
%token RETURN_KEYWORD;
%token VOID_KEYWORD;
%token CASE_KEYWORD;
%token FLOAT_KEYWORD;
%token SHORT_KEYWORD;
%token VOLATILE_KEYWORD;
%token CHAR_KEYWORD;
%token FOR_KEYWORD;
%token ELSE_KEYWORD;
%token REGISTER_KEYWORD;
%token UNION_KEYWORD;
%token <str> IDENTIFIER;
%token  <intval> INT_CONSTANT;
%token  <floatval> FLOAT_CONSTANT;
%token  <charval> CHAR_CONSTANT;
%token <str> STRING_LITERAL;
%token MUL_ASSIGNMENT;
%token DIV_ASSIGNMENT;
%token AND_ASSIGNMENT;
%token XOR_ASSIGNMENT;
%token OR_ASSIGNMENT;
%token POINTER_OP;
%token INCREMENT_OP;
%token DECREMENT_OP;
%token LEFT_SHIFT;
%token OR_OP;
%token ELLIPSIS;
%token SUB_ASSIGNMENT;
%token RIGHT_SHIFT;
%token LESS_EQ_OP;
%token GREATER_EQ_OP;
%token MOD_ASSIGNMENT;
%token ADD_ASSIGNMENT;
%token EQ_OP;
%token NOT_EQ_OP;
%token AND_OP;
%token LEFT_ASSIGNMENT;
%token RIGHT_ASSIGNMENT;
%type<expr_attr> statement
%type<func_def_> parameter_declaration
%type<func_list_> parameter_type_list_opt
%type<expr_attr> jump_statement
%type<expr_attr> compound_statement
%type<expr_attr> block_item
%type<expr_attr> block_item_list
%type<expr_attr> selection_statement
%type<expr_attr> iteration_statement
%type<expr_attr> M
%type<expr_attr> expression_statement
%type<func_list_> argument_expression_list
%type<expr_attr> expression_opt
%type<decclist> function_definition
%type<expr_attr> assignment_expression_opt
%type<expr_attr> assignment_operator
%type<expr_attr> expression
%type<expr_attr> logical_or_expression
%type<decclist> declarator
%type<expr_attr> initializer
%type<decclist> initializer_list
%type<type_> typeName
%type<expr_attr> primary_expression
%type<expr_attr> postfix_expression
%type<expr_attr> multiplicative_expression
%type<expr_attr> and_expression
%type<expr_attr> exclusive_or_expression
%type<expr_attr> inclusive_or_expression
%type<expr_attr> logical_and_expression
%type<expr_attr> assignment_expression
%type<type_>pointer
%type<func_list_> parameter_list
%type<init_dec_list_> init_declarator_list
%type<decclist> init_declarator
%type<decclist> direct_declarator
%type<type_> type_specifier
%type<type_> specifier_qualifier_list
%type<expr_attr> shift_expression
%type<expr_attr> relational_expression
%type<func_list_> parameter_type_list
%type<expr_attr> N
%type<expr_attr> additive_expression
%type<expr_attr> unary_expression
%type<charval> unary_operator
%type<expr_attr> cast_expression
%type<expr_attr> conditional_expression
%type<expr_attr> constant_expression
%type<expr_attr> declaration
%type<type_> declaration_specifiers
%type<expr_attr> equality_expression

%start translation_unit
%%
M :    {    $$ = new ExpressionAtr;
    $$->instr = arrQ.index;};
N :    {    $$ = new ExpressionAtr;
    $$->nextlist = makelist(arrQ.index);
    arrQ.emit(GOTO,"","","");};
primary_expression :  IDENTIFIER    {    $$ = new ExpressionAtr;
        string t = (*($1));     
        symTab *h = curr_sym->lookup(t);
        $$->loc = t;}| INT_CONSTANT             {    $$ = new ExpressionAtr;
        typeInf type;
        type.typeName = "int";
        opcode_t op = COPY;
        $$->loc = curr_sym->gentemp(type);
        arrQ.emit(op,$$->loc, $1);
        initValue *init = new initValue;
        init->intVal = $1;                     
        curr_sym->lookup($$->loc)->init_val = init;
        $$->is_pType = 0;}| CHAR_CONSTANT {    $$ = new ExpressionAtr;
        typeInf type;
        type.typeName = "char";
        opcode_t op = COPY;
        $$->loc = curr_sym->gentemp(type);
        arrQ.emit(op,$$->loc, $1);
        initValue *init = new initValue;
        init->charVal = $1;
        curr_sym->lookup($$->loc)->init_val = init;
        $$->is_pType = 0;}| FLOAT_CONSTANT   {    $$ = new ExpressionAtr;
        typeInf type;
        type.typeName = "double";
        opcode_t op = COPY;
        $$->loc = curr_sym->gentemp(type);
        arrQ.emit(op,$$->loc, $1);
        initValue *init = new initValue;
        init->doubleVal = $1;
        curr_sym->lookup($$->loc)->init_val = init;
        $$->is_pType = 0;}| STRING_LITERAL   {    $$ = new ExpressionAtr;
        string s = ".LC";
        string temp = to_string(literal_count);
        s = s + temp;
        $$->loc = s;
        literal_count++;
        string_lits.PB(*$1);}| '(' expression ')'   {    $$ = $2;};
postfix_expression :  primary_expression    {    $$ = $1;}| postfix_expression '[' expression ']'    {    typeInf t = curr_sym->lookup($1->loc)->type;
        string s;
        typeInf t1;
        t1.typeName = "int";
    int idx;
    string s1;
    idx = t.idx;
    s = curr_sym->gentemp(t1);
        arrQ.emit(COPY, s, 0);
        $1 -> inner = new string(s); 
    s = *($1->inner);
    s1 = to_string(idx);
        arrQ.emit(MULT, s, s, s1);
        arrQ.emit(PLUS, s, s, $3->loc);
        arrQ.emit(MULT, s, s, string("4"));
        $$ = $1;}| postfix_expression '(' ')' {}| postfix_expression '(' argument_expression_list ')'   {    string f = $1->loc;
        SymbolTable *fsym = GT.lookup(f)->nested_table;
        func_list *flist = ($3);
        list<func_def*>::iterator it;
        int c = 0;
        for(it = flist->func_def_list.begin(); it!=flist->func_def_list.end();it++){    func_def *f = *it;
            c++;
            arrQ.emit(PARAM, f->param_name,"","");}
        string s = to_string(c);
            arrQ.emit(CALL,f,s,"");}| postfix_expression '.' IDENTIFIER {}| postfix_expression POINTER_OP IDENTIFIER {}| postfix_expression INCREMENT_OP   {    $$ = new ExpressionAtr;
        string s = $1->loc;
        symTab * f = curr_sym->lookup($1->loc);
        $$->loc = curr_sym->gentemp(f->type);
        if(f->type.arrType.compare("array") == 0){    string temp = curr_sym->gentemp(f->type);
            arrQ.emit(ARRAY_ACCESS, temp, $1->loc, *($1->inner));
            arrQ.emit(COPY, $$->loc, temp, "");
            arrQ.emit(PLUS, temp, temp, "1");
            arrQ.emit(ARRAY_DEREFERENCE, $1->loc, temp, *($1->inner));}
        else{    arrQ.emit(COPY, $$->loc, $1->loc, "");
            arrQ.emit(PLUS, $1->loc, $1->loc, "1");} 
    }| postfix_expression DECREMENT_OP  {    $$ = new ExpressionAtr;
        symTab * f = curr_sym->lookup($1->loc);
        $$->loc = curr_sym->gentemp(f->type);
        if(f->type.arrType.compare("array") == 0){    string temp = curr_sym->gentemp(f->type);
            arrQ.emit(ARRAY_ACCESS, temp, $1->loc, *($1->inner));
            arrQ.emit(COPY, $$->loc, temp, "");
            arrQ.emit(MINUS, temp, temp, "1");
            arrQ.emit(ARRAY_DEREFERENCE, $1->loc, temp, *($1->inner));}
        else{    arrQ.emit(COPY, $$->loc, $1->loc, "");
            arrQ.emit(MINUS, $1->loc, $1->loc, "1");}
    }| '(' typeName ')' '{' initializer_list '}' {}| '(' typeName ')' '{' initializer_list ',' '}' {};
argument_expression_list :  assignment_expression	{    func_def *f = new func_def;
        f->param_name = $1->loc;
        $$ = new func_list;
        f->type = &(curr_sym->lookup(f->param_name)->type);
        $$->func_def_list.PB(f);}| argument_expression_list ',' assignment_expression	{    func_def *f = new func_def;
        f->param_name = $3->loc;
        $$ = new func_list;
        f->type = &(curr_sym->lookup(f->param_name)->type);
	$$ = $1;
        $$->func_def_list.PB(f);};
unary_expression :  postfix_expression {}| INCREMENT_OP unary_expression	{    opcode_t op;
        op = PLUS;
        $$ = new ExpressionAtr;
        typeInf type;
        type = curr_sym->lookup($2->loc)->type;
        if(type.arrType.compare("array") == 0){    string temp = curr_sym->gentemp(type);
            arrQ.emit(ARRAY_ACCESS, temp, $2->loc, *($2->inner));
            arrQ.emit(PLUS, temp, temp, "1");
            arrQ.emit(ARRAY_DEREFERENCE, $2->loc, temp, *($2->inner));}
        else
            arrQ.emit(op, $$->loc, $2->loc, "1");
        type = curr_sym->lookup($2->loc)->type;
        $$->loc = curr_sym->gentemp(type);
        op = COPY;
        arrQ.emit(op, $2->loc, $$->loc, "");}| DECREMENT_OP unary_expression	{    opcode_t op;
        op = MINUS;
        $$ = new ExpressionAtr;
        typeInf type;
        type = curr_sym->lookup($2->loc)->type;
        $$->loc = curr_sym->gentemp(type);
        if(type.arrType.compare("array") == 0){    string temp = curr_sym->gentemp(type);
            arrQ.emit(ARRAY_ACCESS, temp, $2->loc, *($2->inner));
            arrQ.emit(MINUS, temp, temp, "1");
            arrQ.emit(ARRAY_DEREFERENCE, $2->loc, temp, *($2->inner));}
        else
            arrQ.emit(op, $$->loc, $2->loc, "1");
        type = curr_sym->lookup($2->loc)->type;
        $$->loc = curr_sym->gentemp(type);
        op = COPY;
        arrQ.emit(op, $2->loc, $$->loc, "");}| unary_operator cast_expression	{    $$ = new ExpressionAtr;
        typeInf type;
        type.typeName = string("int");
        if($1 == '-'){    $$ = new ExpressionAtr; 
            $$->loc = curr_sym->gentemp(type);
            arrQ.emit(UNARY_MINUS,$$->loc,$2->loc,"");}
        else if($1 == '&'){    $$ = new ExpressionAtr;
	    type.pType = "ptr";
	    type.pCount = 1;
	    type.size = 8;
            $$->loc = curr_sym->gentemp(type);
            arrQ.emit(REFERENCE,$$->loc,$2->loc,"");}
        else if($1 == '*'){    $$ = new ExpressionAtr; 
            $$->loc = curr_sym->gentemp(type);
            arrQ.emit(DEREFERENCE,$$->loc,$2->loc,"");}
        else{    $$ = $2;}
    }| SIZEOF_KEYWORD unary_expression {}| SIZEOF_KEYWORD '(' typeName ')' {};
unary_operator :  '&'	{    $$ = '&';}| '*'	{    $$ = '*';}| '+'	{    $$ = '+';}| '-'	{    $$ = '-';}| '~'	{    $$ = '~';}| '!'	{    $$ = '!';};
cast_expression :  unary_expression {}| '(' typeName ')' cast_expression {};
multiplicative_expression :  cast_expression {}| multiplicative_expression '*' cast_expression	{    $$ = new ExpressionAtr;
        typeInf type1, type2, type;
        type1 = curr_sym->lookup($1->loc)->type;
        type2 = curr_sym->lookup($3->loc)->type;
        if(type2.arrType.compare("array") == 0){    string temp = curr_sym->gentemp(type2);
            arrQ.emit(ARRAY_ACCESS, temp, $3->loc, *($3->inner));
            $3->loc = temp;
            $3->type.arrType = "";}
        if(type1.arrType.compare("array") == 0){    string temp = curr_sym->gentemp(type1);
            arrQ.emit(ARRAY_ACCESS, temp, $1->loc, *($1->inner));
            $1->loc = temp;
            $1->type.arrType = "";}
        int flag = 0;
        if(type1.typeName == type2.typeName){    type.typeName = type1.typeName;
            flag = 1;}
        if(type1.typeName.compare("double")==0 && type2.typeName.compare("int")==0){    string t = curr_sym->gentemp(type1);
            symTab *s = curr_sym->lookup(t, type1.typeName);
            ExpressionAtr *e = new ExpressionAtr;
            e->loc = t;
            e->type = type1;
            arrQ.convI2D(e,$3);
            type.typeName = type1.typeName;}
        else if(type1.typeName.compare("int")==0 && type2.typeName.compare("double")==0){    string t = curr_sym->gentemp(type2);
            symTab *s = curr_sym->lookup(t, type2.typeName);
            ExpressionAtr *e = new ExpressionAtr;
            e->loc = t;
            e->type = type2;
            arrQ.convI2D(e,$1);
            type.typeName = type2.typeName;}
        if(type1.typeName.compare("double")==0 && type2.typeName.compare("char")==0){    string t = curr_sym->gentemp(type1);
            symTab *s = curr_sym->lookup(t, type1.typeName);
            ExpressionAtr *e = new ExpressionAtr;
            e->loc = t;
            e->type = type1;
            arrQ.convC2D(e,$3);
            type.typeName = type1.typeName;}
        if(type1.typeName.compare("char")==0 && type2.typeName.compare("double")==0){    string t = curr_sym->gentemp(type2);
            symTab *s = curr_sym->lookup(t, type2.typeName);
            ExpressionAtr *e = new ExpressionAtr;
            e->loc = t;
            e->type = type2;
            arrQ.convC2D(e,$1);
            type.typeName = type2.typeName;}
        if(type1.typeName.compare("char")==0 && type2.typeName.compare("int")==0){    string t = curr_sym->gentemp(type2);
            symTab *s = curr_sym->lookup(t, type2.typeName);
            ExpressionAtr *e = new ExpressionAtr;
            e->loc = t;
            e->type = type1;
            arrQ.convC2I(e,$1);
            type.typeName = type2.typeName;}
        if(type1.typeName.compare("int")==0 && type2.typeName.compare("char")==0){    string t = curr_sym->gentemp(type1);
            symTab *s = curr_sym->lookup(t, type1.typeName);
            ExpressionAtr *e = new ExpressionAtr;
            e->loc = t;
            e->type = type1;
            arrQ.convC2I(e,$3);
            type.typeName = type1.typeName;}
        $$->loc = curr_sym->gentemp(type);
        arrQ.emit(MULT, $$->loc, $1->loc, $3->loc);}| multiplicative_expression '/' cast_expression	{    $$ = new ExpressionAtr;
        typeInf type1, type2, type;
        type1 = curr_sym->lookup($1->loc)->type;
        type2 = curr_sym->lookup($3->loc)->type;
        if(type2.arrType.compare("array") == 0){    string temp = curr_sym->gentemp(type2);
            arrQ.emit(ARRAY_ACCESS, temp, $3->loc, *($3->inner));
            $3->loc = temp;
            $3->type.arrType = "";}
        if(type1.arrType.compare("array") == 0){    string temp = curr_sym->gentemp(type1);
            arrQ.emit(ARRAY_ACCESS, temp, $1->loc, *($1->inner));
            $1->loc = temp;
            $1->type.arrType = "";}
        int flag = 0;
        if(type1.typeName == type2.typeName){    type.typeName = type1.typeName;
            flag = 1;}
        if(type1.typeName.compare("double")==0 && type2.typeName.compare("int")==0){    string t = curr_sym->gentemp(type1);
            symTab *s = curr_sym->lookup(t, type1.typeName);
            ExpressionAtr *e = new ExpressionAtr;
            e->loc = t;
            e->type = type1;
            arrQ.convI2D(e,$3);
            type.typeName = type1.typeName;}
        else if(type1.typeName.compare("int")==0 && type2.typeName.compare("double")==0){    string t = curr_sym->gentemp(type2);
            symTab *s = curr_sym->lookup(t, type2.typeName);
            ExpressionAtr *e = new ExpressionAtr;
            e->loc = t;
            e->type = type2;
            arrQ.convI2D(e,$1);
            type.typeName = type2.typeName;}
        if(type1.typeName.compare("double")==0 && type2.typeName.compare("char")==0){    string t = curr_sym->gentemp(type1);
            symTab *s = curr_sym->lookup(t, type1.typeName);
            ExpressionAtr *e = new ExpressionAtr;
            e->loc = t;
            e->type = type1;
            arrQ.convC2D(e,$3);
            type.typeName = type1.typeName;}
        if(type1.typeName.compare("char")==0 && type2.typeName.compare("double")==0){    string t = curr_sym->gentemp(type2);
            symTab *s = curr_sym->lookup(t, type2.typeName);
            ExpressionAtr *e = new ExpressionAtr;
            e->loc = t;
            e->type = type2;
            arrQ.convC2D(e,$1);
            type.typeName = type2.typeName;}
        if(type1.typeName.compare("char")==0 && type2.typeName.compare("int")==0){    string t = curr_sym->gentemp(type2);
            symTab *s = curr_sym->lookup(t, type2.typeName);
            ExpressionAtr *e = new ExpressionAtr;
            e->loc = t;
            e->type = type1;
            arrQ.convC2I(e,$1);
            type.typeName = type2.typeName;}
        if(type1.typeName.compare("int")==0 && type2.typeName.compare("char")==0){    string t = curr_sym->gentemp(type1);
            symTab *s = curr_sym->lookup(t, type1.typeName);
            ExpressionAtr *e = new ExpressionAtr;
            e->loc = t;
            e->type = type1;
            arrQ.convC2I(e,$3);
            type.typeName = type1.typeName;}
        $$->loc = curr_sym->gentemp(type);
        arrQ.emit(DIVIDE, $$->loc, $1->loc, $3->loc);}| multiplicative_expression '%' cast_expression	{    $$ = new ExpressionAtr;
        typeInf type1, type2, type;
        type1 = curr_sym->lookup($1->loc)->type;
        type2 = curr_sym->lookup($3->loc)->type;
        if(type2.arrType.compare("array") == 0){    string temp = curr_sym->gentemp(type2);
            arrQ.emit(ARRAY_ACCESS, temp, $3->loc, *($3->inner));
            $3->loc = temp;
            $3->type.arrType = "";}
        if(type1.arrType.compare("array") == 0){    string temp = curr_sym->gentemp(type1);
            arrQ.emit(ARRAY_ACCESS, temp, $1->loc, *($1->inner));
            $1->loc = temp;
            $1->type.arrType = "";}
        int flag = 0;
        if(type1.typeName == type2.typeName){    type.typeName = type1.typeName;
            flag = 1;}
        if(type1.typeName.compare("double")==0 && type2.typeName.compare("int")==0){    string t = curr_sym->gentemp(type1);
            symTab *s = curr_sym->lookup(t, type1.typeName);
            ExpressionAtr *e = new ExpressionAtr;
            e->loc = t;
            e->type = type1;
            arrQ.convI2D(e,$3);
            type.typeName = type1.typeName;}
        else if(type1.typeName.compare("int")==0 && type2.typeName.compare("double")==0){    string t = curr_sym->gentemp(type2);
            symTab *s = curr_sym->lookup(t, type2.typeName);
            ExpressionAtr *e = new ExpressionAtr;
            e->loc = t;
            e->type = type2;
            arrQ.convI2D(e,$1);
            type.typeName = type2.typeName;}
        if(type1.typeName.compare("double")==0 && type2.typeName.compare("char")==0){    string t = curr_sym->gentemp(type1);
            symTab *s = curr_sym->lookup(t, type1.typeName);
            ExpressionAtr *e = new ExpressionAtr;
            e->loc = t;
            e->type = type1;
            arrQ.convC2D(e,$3);
            type.typeName = type1.typeName;}
        if(type1.typeName.compare("char")==0 && type2.typeName.compare("double")==0){    string t = curr_sym->gentemp(type2);
            symTab *s = curr_sym->lookup(t, type2.typeName);
            ExpressionAtr *e = new ExpressionAtr;
            e->loc = t;
            e->type = type2;
            arrQ.convC2D(e,$1);
            type.typeName = type2.typeName;}
        if(type1.typeName.compare("char")==0 && type2.typeName.compare("int")==0){    string t = curr_sym->gentemp(type2);
            symTab *s = curr_sym->lookup(t, type2.typeName);
            ExpressionAtr *e = new ExpressionAtr;
            e->loc = t;
            e->type = type1;
            arrQ.convC2I(e,$1);
            type.typeName = type2.typeName;}
        if(type1.typeName.compare("int")==0 && type2.typeName.compare("char")==0){    string t = curr_sym->gentemp(type1);
            symTab *s = curr_sym->lookup(t, type1.typeName);
            ExpressionAtr *e = new ExpressionAtr;
            e->loc = t;
            e->type = type1;
            arrQ.convC2I(e,$3);
            type.typeName = type1.typeName;}
        $$->loc = curr_sym->gentemp(type);
        arrQ.emit(MODULO, $$->loc, $1->loc, $3->loc);};
additive_expression :  multiplicative_expression	{$$ = $1;}| additive_expression '+' multiplicative_expression	{    $$ = new ExpressionAtr;
        typeInf type1, type2, type;
        type1 = curr_sym->lookup($1->loc)->type;
        type2 = curr_sym->lookup($3->loc)->type;
        if(type2.arrType.compare("array") == 0){    string temp = curr_sym->gentemp(type2);
            arrQ.emit(ARRAY_ACCESS, temp, $3->loc, *($3->inner));
            $3->loc = temp;
            $3->type.arrType = "";}
        if(type1.arrType.compare("array") == 0){    string temp = curr_sym->gentemp(type1);
            arrQ.emit(ARRAY_ACCESS, temp, $1->loc, *($1->inner));
            $1->loc = temp;
            $1->type.arrType = "";}
        int flag = 0;
        if(type1.typeName == type2.typeName){    type.typeName = type1.typeName;
            flag = 1;}
        if(type1.typeName.compare("double")==0 && type2.typeName.compare("int")==0){    string t = curr_sym->gentemp(type1);
            symTab *s = curr_sym->lookup(t, type1.typeName);
            ExpressionAtr *e = new ExpressionAtr;
            e->loc = t;
            e->type = type1;
            arrQ.convI2D(e,$3);
            type.typeName = type1.typeName;}
        else if(type1.typeName.compare("int")==0 && type2.typeName.compare("double")==0){    string t = curr_sym->gentemp(type2);
            symTab *s = curr_sym->lookup(t, type2.typeName);
            ExpressionAtr *e = new ExpressionAtr;
            e->loc = t;
            e->type = type2;
            arrQ.convI2D(e,$1);
            type.typeName = type2.typeName;}
        if(type1.typeName.compare("double")==0 && type2.typeName.compare("char")==0){    string t = curr_sym->gentemp(type1);
            symTab *s = curr_sym->lookup(t, type1.typeName);
            ExpressionAtr *e = new ExpressionAtr;
            e->loc = t;
            e->type = type1;
            arrQ.convC2D(e,$3);
            type.typeName = type1.typeName;}
        if(type1.typeName.compare("char")==0 && type2.typeName.compare("double")==0){    string t = curr_sym->gentemp(type2);
            symTab *s = curr_sym->lookup(t, type2.typeName);
            ExpressionAtr *e = new ExpressionAtr;
            e->loc = t;
            e->type = type2;
            arrQ.convC2D(e,$1);
            type.typeName = type2.typeName;}
        if(type1.typeName.compare("char")==0 && type2.typeName.compare("int")==0){    string t = curr_sym->gentemp(type2);
            symTab *s = curr_sym->lookup(t, type2.typeName);
            ExpressionAtr *e = new ExpressionAtr;
            e->loc = t;
            e->type = type1;
            arrQ.convC2I(e,$1);
            type.typeName = type2.typeName;}
        if(type1.typeName.compare("int")==0 && type2.typeName.compare("char")==0){    string t = curr_sym->gentemp(type1);
            symTab *s = curr_sym->lookup(t, type1.typeName);
            ExpressionAtr *e = new ExpressionAtr;
            e->loc = t;
            e->type = type1;
            arrQ.convC2I(e,$3);
            type.typeName = type1.typeName;}
        $$->loc = curr_sym->gentemp(type);
        arrQ.emit(PLUS, $$->loc, $1->loc, $3->loc);}| additive_expression '-' multiplicative_expression	{    $$ = new ExpressionAtr;
        typeInf type1, type2, type;
        type1 = curr_sym->lookup($1->loc)->type;
        type2 = curr_sym->lookup($3->loc)->type;
        if(type2.arrType.compare("array") == 0){    string temp = curr_sym->gentemp(type2);
            arrQ.emit(ARRAY_ACCESS, temp, $3->loc, *($3->inner));
            $3->loc = temp;
            $3->type.arrType = "";}
        if(type1.arrType.compare("array") == 0){    string temp = curr_sym->gentemp(type1);
            arrQ.emit(ARRAY_ACCESS, temp, $1->loc, *($1->inner));
            $1->loc = temp;
            $1->type.arrType = "";}
        int flag = 0;
        if(type1.typeName == type2.typeName){    type.typeName = type1.typeName;
            flag = 1;}
        if(type1.typeName.compare("double")==0 && type2.typeName.compare("int")==0){    string t = curr_sym->gentemp(type1);
            symTab *s = curr_sym->lookup(t, type1.typeName);
            ExpressionAtr *e = new ExpressionAtr;
            e->loc = t;
            e->type = type1;
            arrQ.convI2D(e,$3);
            type.typeName = type1.typeName;}
        else if(type1.typeName.compare("int")==0 && type2.typeName.compare("double")==0){    string t = curr_sym->gentemp(type2);
            symTab *s = curr_sym->lookup(t, type2.typeName);
            ExpressionAtr *e = new ExpressionAtr;
            e->loc = t;
            e->type = type2;
            arrQ.convI2D(e,$1);
            type.typeName = type2.typeName;}
        if(type1.typeName.compare("double")==0 && type2.typeName.compare("char")==0){    string t = curr_sym->gentemp(type1);
            symTab *s = curr_sym->lookup(t, type1.typeName);
            ExpressionAtr *e = new ExpressionAtr;
            e->loc = t;
            e->type = type1;
            arrQ.convC2D(e,$3);
            type.typeName = type1.typeName;}
        if(type1.typeName.compare("char")==0 && type2.typeName.compare("double")==0){    string t = curr_sym->gentemp(type2);
            symTab *s = curr_sym->lookup(t, type2.typeName);
            ExpressionAtr *e = new ExpressionAtr;
            e->loc = t;
            e->type = type2;
            arrQ.convC2D(e,$1);
            type.typeName = type2.typeName;}
        if(type1.typeName.compare("char")==0 && type2.typeName.compare("int")==0){    string t = curr_sym->gentemp(type2);
            symTab *s = curr_sym->lookup(t, type2.typeName);
            ExpressionAtr *e = new ExpressionAtr;
            e->loc = t;
            e->type = type1;
            arrQ.convC2I(e,$1);
            type.typeName = type2.typeName;}
        if(type1.typeName.compare("int")==0 && type2.typeName.compare("char")==0){    string t = curr_sym->gentemp(type1);
            symTab *s = curr_sym->lookup(t, type1.typeName);
            ExpressionAtr *e = new ExpressionAtr;
            e->loc = t;
            e->type = type1;
            arrQ.convC2I(e,$3);
            type.typeName = type1.typeName;}
        $$->loc = curr_sym->gentemp(type);
        arrQ.emit(MINUS, $$->loc, $1->loc, $3->loc);};
shift_expression :  additive_expression {}| shift_expression LEFT_SHIFT additive_expression	{    $$ = new ExpressionAtr;
        typeInf type1, type2, type;
        type1 = curr_sym->lookup($1->loc)->type;
        type2 = curr_sym->lookup($3->loc)->type;
        if(type2.arrType.compare("array") == 0){    string temp = curr_sym->gentemp(type2);
            arrQ.emit(ARRAY_ACCESS, temp, $3->loc, *($3->inner));
            $3->loc = temp;
            $3->type.arrType = "";}
        if(type1.arrType.compare("array") == 0){    string temp = curr_sym->gentemp(type1);
            arrQ.emit(ARRAY_ACCESS, temp, $1->loc, *($1->inner));
            $1->loc = temp;
            $1->type.arrType = "";}
        int flag = 0;
        if(type1.typeName.compare("int") == 0) {}
        else{    if(type1.typeName.compare("double") == 0){    type1.typeName = "int";
                string t = curr_sym->gentemp(type1);
                symTab *s = curr_sym->lookup(t, "int");
                ExpressionAtr *e = new ExpressionAtr;
                e->loc = t;
                e->type.typeName = "int";
                arrQ.convD2I(e,$3);}
            else if(type1.typeName.compare("char") == 0){    type1.typeName = "int";
                string t = curr_sym->gentemp(type1);
                symTab *s = curr_sym->lookup(t, "int");
                ExpressionAtr *e = new ExpressionAtr;
                e->loc = t;
                e->type.typeName = "int";
                arrQ.convC2I(e,$3);}
        }
        type1.typeName = "int";
        $$->loc = curr_sym->gentemp(type1);
        arrQ.emit(SHIFT_LEFT, $$->loc, $1->loc, $3->loc);}| shift_expression RIGHT_SHIFT additive_expression	{    $$ = new ExpressionAtr;
        typeInf type1, type2, type;
        type1 = curr_sym->lookup($1->loc)->type;
        type2 = curr_sym->lookup($3->loc)->type;
        if(type2.arrType.compare("array") == 0){    string temp = curr_sym->gentemp(type2);
            arrQ.emit(ARRAY_ACCESS, temp, $3->loc, *($3->inner));
            $3->loc = temp;
            $3->type.arrType = "";}
        if(type1.arrType.compare("array") == 0){    string temp = curr_sym->gentemp(type1);
            arrQ.emit(ARRAY_ACCESS, temp, $1->loc, *($1->inner));
            $1->loc = temp;
            $1->type.arrType = "";}
        int flag = 0;
        if(type1.typeName.compare("int") == 0) {}
        else{    if(type1.typeName.compare("double") == 0){    type1.typeName = "int";
                string t = curr_sym->gentemp(type1);
                symTab *s = curr_sym->lookup(t, "int");
                ExpressionAtr *e = new ExpressionAtr;
                e->loc = t;
                e->type.typeName = "int";
                arrQ.convD2I(e,$3);}
            else if(type1.typeName.compare("char") == 0){    type1.typeName = "int";
                string t = curr_sym->gentemp(type1);
                symTab *s = curr_sym->lookup(t, "int");
                ExpressionAtr *e = new ExpressionAtr;
                e->loc = t;
                e->type.typeName = "int";
                arrQ.convC2I(e,$3);}
        }
        type1.typeName = "int";
        $$->loc = curr_sym->gentemp(type1);
        arrQ.emit(SHIFT_RIGHT, $$->loc, $1->loc, $3->loc);};
relational_expression :  shift_expression {}| relational_expression '<' shift_expression	{    typeInf type1, type2, type;
        type1 = curr_sym->lookup($1->loc)->type;
        type2 = curr_sym->lookup($3->loc)->type;
        if(type2.arrType.compare("array") == 0){    string temp = curr_sym->gentemp(type2);
            arrQ.emit(ARRAY_ACCESS, temp, $3->loc, *($3->inner));
            $3->loc = temp;
            $3->type.arrType = "";}
        if(type1.arrType.compare("array") == 0){    string temp = curr_sym->gentemp(type1);
            arrQ.emit(ARRAY_ACCESS, temp, $1->loc, *($1->inner));
            $1->loc = temp;
            $1->type.arrType = "";}
        $$ = new ExpressionAtr;
        $$->type.typeName = "bool";
        $$->loc = curr_sym->gentemp($$->type);
        $$->truelist = makelist(arrQ.index);
        $$->falselist = makelist(arrQ.index + 1);
        arrQ.emit(IF_LESS, "", $1->loc, $3->loc);
        arrQ.emit(GOTO,"","","");}| relational_expression '>' shift_expression	{    typeInf type1, type2, type;
        type1 = curr_sym->lookup($1->loc)->type;
        type2 = curr_sym->lookup($3->loc)->type;
        if(type2.arrType.compare("array") == 0){    string temp = curr_sym->gentemp(type2);
            arrQ.emit(ARRAY_ACCESS, temp, $3->loc, *($3->inner));
            $3->loc = temp;
            $3->type.arrType = "";}
        if(type1.arrType.compare("array") == 0){    string temp = curr_sym->gentemp(type1);
            arrQ.emit(ARRAY_ACCESS, temp, $1->loc, *($1->inner));
            $1->loc = temp;
            $1->type.arrType = "";}
        $$ = new ExpressionAtr;
        $$->type.typeName = "bool";
        $$->loc = curr_sym->gentemp($$->type);
        $$->truelist = makelist(arrQ.index);
        $$->falselist = makelist(arrQ.index + 1);
        arrQ.emit(IF_GREATER, "", $1->loc, $3->loc);
        arrQ.emit(GOTO,"","","");}| relational_expression LESS_EQ_OP shift_expression	{    typeInf type1, type2, type;
        type1 = curr_sym->lookup($1->loc)->type;
        type2 = curr_sym->lookup($3->loc)->type;
        if(type2.arrType.compare("array") == 0){    string temp = curr_sym->gentemp(type2);
            arrQ.emit(ARRAY_ACCESS, temp, $3->loc, *($3->inner));
            $3->loc = temp;
            $3->type.arrType = "";}
        if(type1.arrType.compare("array") == 0){    string temp = curr_sym->gentemp(type1);
            arrQ.emit(ARRAY_ACCESS, temp, $1->loc, *($1->inner));
            $1->loc = temp;
            $1->type.arrType = "";}
        $$ = new ExpressionAtr;
        $$->type.typeName = "bool";
        $$->loc = curr_sym->gentemp($$->type);
        $$->truelist = makelist(arrQ.index);
        $$->falselist = makelist(arrQ.index + 1);
        arrQ.emit(IF_LESS_EQUAL, "", $1->loc, $3->loc);
        arrQ.emit(GOTO,"","","");}| relational_expression GREATER_EQ_OP shift_expression	{    typeInf type1, type2, type;
        type1 = curr_sym->lookup($1->loc)->type;
        type2 = curr_sym->lookup($3->loc)->type;
        if(type2.arrType.compare("array") == 0){    string temp = curr_sym->gentemp(type2);
            arrQ.emit(ARRAY_ACCESS, temp, $3->loc, *($3->inner));
            $3->loc = temp;
            $3->type.arrType = "";}
        if(type1.arrType.compare("array") == 0){    string temp = curr_sym->gentemp(type1);
            arrQ.emit(ARRAY_ACCESS, temp, $1->loc, *($1->inner));
            $1->loc = temp;
            $1->type.arrType = "";}
        $$ = new ExpressionAtr;
        $$->type.typeName = "bool";
        $$->loc = curr_sym->gentemp($$->type);
        $$->truelist = makelist(arrQ.index);
        $$->falselist = makelist(arrQ.index + 1);
        arrQ.emit(IF_GREATER_EQUAL, "", $1->loc, $3->loc);
        arrQ.emit(GOTO,"","","");};
equality_expression :  relational_expression {}| equality_expression EQ_OP relational_expression    {    typeInf type1, type2, type;
        type1 = curr_sym->lookup($1->loc)->type;
        type2 = curr_sym->lookup($3->loc)->type;
        if(type2.arrType.compare("array") == 0){    string temp = curr_sym->gentemp(type2);
            arrQ.emit(ARRAY_ACCESS, temp, $3->loc, *($3->inner));
            $3->loc = temp;
            $3->type.arrType = "";}
        if(type1.arrType.compare("array") == 0){    string temp = curr_sym->gentemp(type1);
            arrQ.emit(ARRAY_ACCESS, temp, $1->loc, *($1->inner));
            $1->loc = temp;
            $1->type.arrType = "";}
        $$ = new ExpressionAtr;
        $$->type.typeName = "bool";
        $$->loc = curr_sym->gentemp($$->type);
        $$->truelist = makelist(arrQ.index);
        $$->falselist = makelist(arrQ.index + 1);
        arrQ.emit(IF_IS_EQUAL,"",$1->loc, $3->loc);
        arrQ.emit(GOTO,"","","");}| equality_expression NOT_EQ_OP relational_expression  {    typeInf type1, type2, type;
        type1 = curr_sym->lookup($1->loc)->type;
        type2 = curr_sym->lookup($3->loc)->type;
        if(type2.arrType.compare("array") == 0){    string temp = curr_sym->gentemp(type2);
            arrQ.emit(ARRAY_ACCESS, temp, $3->loc, *($3->inner));
            $3->loc = temp;
            $3->type.arrType = "";}
        if(type1.arrType.compare("array") == 0){    string temp = curr_sym->gentemp(type1);
            arrQ.emit(ARRAY_ACCESS, temp, $1->loc, *($1->inner));
            $1->loc = temp;
            $1->type.arrType = "";}
        $$ = new ExpressionAtr;
        $$->type.typeName = "bool";
        $$->loc = curr_sym->gentemp($$->type);
        $$->truelist = makelist(arrQ.index);
        $$->falselist = makelist(arrQ.index + 1);
        arrQ.emit(IF_NOT_EQUAL,"",$1->loc, $3->loc);
        arrQ.emit(GOTO,"","","");};
and_expression :  equality_expression {}| and_expression '&' equality_expression	{    typeInf type1, type2, type;
        type1 = curr_sym->lookup($1->loc)->type;
        type2 = curr_sym->lookup($3->loc)->type;
        if(type2.arrType.compare("array") == 0){    string temp = curr_sym->gentemp(type2);
            arrQ.emit(ARRAY_ACCESS, temp, $3->loc, *($3->inner));
            $3->loc = temp;
            $3->type.arrType = "";}
        if(type1.arrType.compare("array") == 0){    string temp = curr_sym->gentemp(type1);
            arrQ.emit(ARRAY_ACCESS, temp, $1->loc, *($1->inner));
            $1->loc = temp;
            $1->type.arrType = "";}
        $$ = new ExpressionAtr;
        symTab *f = curr_sym->lookup($1->loc);
        typeInf t;
        t = f->type;
        $$->loc = curr_sym->gentemp(t);
        arrQ.emit(LOGICAL_AND, $$->loc, $1->loc, $3->loc);};
exclusive_or_expression :  and_expression {}| exclusive_or_expression '^' and_expression	{    typeInf type1, type2, type;
        type1 = curr_sym->lookup($1->loc)->type;
        type2 = curr_sym->lookup($3->loc)->type;
        if(type2.arrType.compare("array") == 0){    string temp = curr_sym->gentemp(type2);
            arrQ.emit(ARRAY_ACCESS, temp, $3->loc, *($3->inner));
            $3->loc = temp;
            $3->type.arrType = "";}
        if(type1.arrType.compare("array") == 0){    string temp = curr_sym->gentemp(type1);
            arrQ.emit(ARRAY_ACCESS, temp, $1->loc, *($1->inner));
            $1->loc = temp;
            $1->type.arrType = "";}
        $$ = new ExpressionAtr;
        symTab *f = curr_sym->lookup($1->loc);
        typeInf t;
        t = f->type;
        $$->loc = curr_sym->gentemp(t);
        arrQ.emit(XOR, $$->loc, $1->loc, $3->loc);};
inclusive_or_expression :  exclusive_or_expression {}| inclusive_or_expression '|' exclusive_or_expression	{    typeInf type1, type2, type;
        type1 = curr_sym->lookup($1->loc)->type;
        type2 = curr_sym->lookup($3->loc)->type;
        if(type2.arrType.compare("array") == 0){    string temp = curr_sym->gentemp(type2);
            arrQ.emit(ARRAY_ACCESS, temp, $3->loc, *($3->inner));
            $3->loc = temp;
            $3->type.arrType = "";}
        if(type1.arrType.compare("array") == 0){    string temp = curr_sym->gentemp(type1);
            arrQ.emit(ARRAY_ACCESS, temp, $1->loc, *($1->inner));
            $1->loc = temp;
            $1->type.arrType = "";}
        $$ = new ExpressionAtr;
        symTab *f = curr_sym->lookup($1->loc);
        typeInf t;
        t = f->type;
        $$->loc = curr_sym->gentemp(t);
        arrQ.emit(OR, $$->loc, $1->loc, $3->loc);};
logical_and_expression :  inclusive_or_expression {}| logical_and_expression N AND_OP M inclusive_or_expression	N{    typeInf type1, type2;
        type1 = curr_sym->lookup($1->loc)->type;
        type2 = curr_sym->lookup($5->loc)->type;
        if(type2.arrType.compare("array") == 0){    string temp = curr_sym->gentemp(type2);
            arrQ.emit(ARRAY_ACCESS, temp, $5->loc, *($5->inner));
            $5->loc = temp;
            $5->type.arrType = "";}
        if(type1.arrType.compare("array") == 0){    string temp = curr_sym->gentemp(type1);
            arrQ.emit(ARRAY_ACCESS, temp, $1->loc, *($1->inner));
            $1->loc = temp;
            $1->type.arrType = "";}
        typeInf type;
        type.typeName = "bool";
        $$ = new ExpressionAtr;
        $$->type = type;
        arrQ.backpatch($2->nextlist, arrQ.index);
        arrQ.convInt2Bool($1);
        arrQ.backpatch($6->nextlist, arrQ.index);
        arrQ.convInt2Bool($5);
        arrQ.backpatch($1->truelist, $4->instr);
        $$->truelist = $5->truelist;
        $$->falselist = merge($1->falselist, $5->falselist);};
logical_or_expression :  logical_and_expression {}| logical_or_expression N OR_OP M logical_and_expression N	{    typeInf type1, type2;
        type1 = curr_sym->lookup($1->loc)->type;
        type2 = curr_sym->lookup($5->loc)->type;
        if(type2.arrType.compare("array") == 0){    string temp = curr_sym->gentemp(type2);
            arrQ.emit(ARRAY_ACCESS, temp, $5->loc, *($5->inner));
            $5->loc = temp;
            $5->type.arrType = "";}
        if(type1.arrType.compare("array") == 0){    string temp = curr_sym->gentemp(type1);
            arrQ.emit(ARRAY_ACCESS, temp, $1->loc, *($1->inner));
            $1->loc = temp;
            $1->type.arrType = "";}
        typeInf type;
        type.typeName = "bool";
        $$ = new ExpressionAtr;
        $$->type = type;
        arrQ.backpatch($2->nextlist, arrQ.index);
        arrQ.convInt2Bool($1);
        arrQ.backpatch($6->nextlist, arrQ.index);
        arrQ.convInt2Bool($5);
        arrQ.backpatch($1->falselist, $4->instr);
        $$->truelist = merge($1->truelist, $5->truelist);
        $$->falselist = $5->falselist;};
conditional_expression :  logical_or_expression {}| logical_or_expression N '?' M expression N ':' M conditional_expression	{    typeInf type1, type2;
        type1 = curr_sym->lookup($5->loc)->type;
        type2 = curr_sym->lookup($9->loc)->type;
        if(type2.arrType.compare("array") == 0){    string temp = curr_sym->gentemp(type2);
            arrQ.emit(ARRAY_ACCESS, temp, $9->loc, *($9->inner));
            $9->loc = temp;
            $9->type.arrType = "";}
        if(type1.arrType.compare("array") == 0){    string temp = curr_sym->gentemp(type1);
            arrQ.emit(ARRAY_ACCESS, temp, $5->loc, *($5->inner));
            $9->loc = temp;
            $9->type.arrType = "";}
        $$ = new ExpressionAtr;
        list<int> I;
        typeInf type;
        type = curr_sym->lookup($5->loc)->type;
        $$->loc = curr_sym->gentemp(type);
        arrQ.emit(COPY, $$->loc, $9->loc,"");
        I = makelist(arrQ.index);
        arrQ.emit(GOTO,"","","");
        arrQ.backpatch($6->nextlist, arrQ.index);
        arrQ.emit(COPY, $$->loc, $5->loc, "");
        I = merge(I, makelist(arrQ.index));
        arrQ.emit(GOTO,"", "", "");
        arrQ.backpatch($2->nextlist, arrQ.index);
        arrQ.convInt2Bool($1);
        arrQ.backpatch($1->truelist, $4->instr);
        arrQ.backpatch($1->falselist, $8->instr);
        arrQ.backpatch(I, arrQ.index);};
assignment_expression :  conditional_expression {}| unary_expression assignment_operator assignment_expression  {    typeInf type1, type2, type;
        type1 = curr_sym->lookup($1->loc)->type;
        type2 = curr_sym->lookup($3->loc)->type;
        if(type2.arrType.compare("array") == 0){    string temp = curr_sym->gentemp(type2);
            arrQ.emit(ARRAY_ACCESS, temp, $3->loc, *($3->inner));
            $3->loc = temp;
            $3->type.arrType = "";}
        if(type1.arrType.compare("array") == 0){    arrQ.emit(ARRAY_DEREFERENCE, $1->loc, $3->loc, *($1->inner));}
        else
            arrQ.emit(COPY, $1->loc, $3->loc, "");
        $$ = $1;};
assignment_operator :  '=' {}| MUL_ASSIGNMENT {}| DIV_ASSIGNMENT {}| MOD_ASSIGNMENT {}| ADD_ASSIGNMENT {}| SUB_ASSIGNMENT {}| LEFT_ASSIGNMENT {}| RIGHT_ASSIGNMENT {}| AND_ASSIGNMENT {}| XOR_ASSIGNMENT {}| OR_ASSIGNMENT {};
expression :  assignment_expression {    $$ = $1;}| expression ',' assignment_expression {};
constant_expression :  conditional_expression {};
declaration :  declaration_specifiers ';' {}| declaration_specifiers init_declarator_list ';'	{    init_dec_list *new_dec = new init_dec_list;
        new_dec = $2;
        int size = 0;
        typeInf *type = $1;
        if(type->typeName.compare("int")==0) size = 4;
        if(type->typeName.compare("double")==0) size = 8;
        if(type->typeName.compare("char")==0) size = 1;
        list<declaration*>::iterator it;
        for(it = $2->dec_list.begin(); it != $2->dec_list.end(); it++){    declaration *new_dec = *it;
		    if(new_dec->type!=NULL){    if(new_dec->type->typeName.compare("function")==0){    string name = new_dec->dec_name;
                curr_sym = &GT;
                arrQ.emit(_FUNCTION_END,name,"","");}
            symTab *ret, *f;
            SymbolTable *nest;
            if(new_dec->type->typeName.compare("function")==0){    f = curr_sym->lookup(new_dec->dec_name, type->typeName);
                nest = f->nested_table;
                ret = nest->lookup("retVal", type->typeName, new_dec->pCount);
                f->offset = curr_sym->offset;
                f->size = size;
                f->init_val = NULL;
                continue;}
            }
            symTab *f1 = curr_sym->lookup(new_dec->dec_name, type->typeName);
            f1->nested_table = NULL;
            if(new_dec->alist == vector<int>() && new_dec->pCount == 0){    f1->offset = curr_sym->offset;
                f1->type = *type;
                f1 = curr_sym->lookup(new_dec->dec_name, type->typeName);
                if(new_dec->init != NULL){    string x = new_dec->init->loc;
                    arrQ.emit(COPY, new_dec->dec_name, x, "");
                    f1->init_val = curr_sym->lookup(x,f1->type.typeName)->init_val;}
                else
                    new_dec->init = NULL;}
            else if(new_dec -> pCount > 0){    symTab *sp;
                for(sp = curr_sym->sym_table; sp < &curr_sym->sym_table[curr_sym->entryCount]; sp++){    if(!sp->id.empty() && !sp->id.compare(new_dec->dec_name)){    sp->offset = curr_sym->offset-4;
                        sp->pCount = new_dec->pCount;
                        sp->type = *type;
                        sp->type.pType = "ptr";
                        sp->size = 4;}
                }
            }
            else if(new_dec->alist!=vector<int>()){    symTab *sp;
                for(sp = curr_sym->sym_table; sp < &curr_sym->sym_table[curr_sym->entryCount]; sp++){    if(!sp->id.empty() && !sp->id.compare(new_dec->dec_name)){    int temp_size = size;
                        sp->offset = curr_sym->offset-4;
                        sp->type = *type;
			            sp->type.typeName = type->typeName;
                        sp->type.arrType = "array";
                        sp->type.pType = "";
                        for(int i = 0; i < new_dec->alist.size(); i++){    sp->type.arrList.PB(new_dec->alist[i]);}
                        for (int i = 0; i < sp->type.arrList.size(); ++i){    temp_size = temp_size * sp->type.arrList[i];}
                        sp->size = temp_size;
                        curr_sym->offset = curr_sym->offset + temp_size;}
                }
            }
        }
    };
declaration_specifiers :  storage_class_specifier {}| storage_class_specifier declaration_specifiers {}| type_specifier	{    $$ = $1;}| type_specifier declaration_specifiers {}| type_qualifier {}| type_qualifier declaration_specifiers {}| function_specifier {}| function_specifier declaration_specifiers {};
init_declarator_list :  init_declarator	{    $$ = new init_dec_list;
        $$->dec_list.PB($1);}| init_declarator_list ',' init_declarator	{    $1->dec_list.PB($3);
        $$ = $1;};
init_declarator :  declarator	{    $$ = $1;
        $$->init = NULL;}| declarator '=' initializer	{    $$ = $1;
        $$->init = $3;};
storage_class_specifier :  EXTERN_KEYWORD	{printf("storage_class_specifier -> extern\n");}| STATIC_KEYWORD	{printf("storage_class_specifier -> static\n");}| AUTO_KEYWORD	{printf("storage_class_specifier -> auto\n");}| REGISTER_KEYWORD	{printf("storage_class_specifier -> register\n");};
type_specifier :  VOID_KEYWORD	{    $$ = new typeInf;
			$$->typeName = string("void");}| CHAR_KEYWORD	{    $$ = new typeInf;
			$$->typeName = string("char");
			$$->next = NULL;}| SHORT_KEYWORD {}| INT_KEYWORD	{    $$ = new typeInf;
			$$->typeName = string("int");
			$$->next = NULL;}| LONG_KEYWORD {}| FLOAT_KEYWORD {}| DOUBLE_KEYWORD	{    $$ = new typeInf;
		$$->typeName = string("double");
		$$->next = NULL;}| SIGNED_KEYWORD {}| UNSIGNED_KEYWORD {}| BOOL_KEYWORD {}| COMPLEX_KEYWORD {}| IMAGINARY_KEYWORD {}| enum_specifier
    ;
specifier_qualifier_list :  type_specifier 	{    $$ = $1;}| type_specifier specifier_qualifier_list {}| type_qualifier {}| type_qualifier specifier_qualifier_list {};
enum_specifier :  ENUM_KEYWORD '{' enumerator_list '}'	{printf("enum_specifier -> enum {enumerator_list}\n");}| ENUM_KEYWORD IDENTIFIER '{' enumerator_list '}'	{printf("enum_specifier -> enum IDENTIFIER {enumerator_list} \n");}| ENUM_KEYWORD '{' enumerator_list ',' '}'	{printf("enum_specifier -> enum {enumerator_list, }\n");}| ENUM_KEYWORD IDENTIFIER '{' enumerator_list ',' '}'	{printf("enum_specifier -> enum IDENTIFIER {enumerator_list ,}\n");}| ENUM_KEYWORD IDENTIFIER	{printf("enum_specifier->enum IDENTIFIER\n");};
enumerator_list :  enumerator	{printf("enumerator_list -> enumerator\n");}| enumerator_list ',' enumerator	{printf("enumerator_list -> enumerator_list , enumerator\n");};
enumerator :  enumeration_constant	{printf("enumerator -> enumeration_constant\n");}| enumeration_constant '=' constant_expression	{printf("enumerator -> enumeration_constant = constant_expression\n");};
enumeration_constant :  IDENTIFIER	{printf("enumeration_constant -> IDENTIFIER\n");};
type_qualifier :  CONST_KEYWORD	{printf("type_qualifier -> const\n");}| RESTRICT_KEYWORD	{printf("type_qualifier -> restrict\n");}| VOLATILE_KEYWORD	{printf("type_qualifier -> volatile\n");};
function_specifier :  INLINE_KEYWORD	{printf("function_specifier -> inline\n");}
declarator :  pointer direct_declarator	{    $$ = $2;
        $$->pCount = $1->pCount;}| direct_declarator	{    $$ = $1;
        $$->pCount = 0;};
direct_declarator :  IDENTIFIER	{    $$ = new declaration; 
        $$->dec_name = *($1);}| '(' declarator ')'	{    $$ = $2;}| direct_declarator '[' type_qualifier_list_opt assignment_expression_opt ']'	{    $$ = $1;
        int idx = curr_sym->lookup($4->loc)->init_val->intVal;
        $$->alist.PB(idx);}| direct_declarator '[' STATIC_KEYWORD type_qualifier_list_opt assignment_expression ']' {}| direct_declarator '[' type_qualifier_list STATIC_KEYWORD assignment_expression ']' {}| direct_declarator '[' type_qualifier_list_opt '*' ']' {}| direct_declarator '(' parameter_type_list_opt')'	{    list<func_def*> l = $3->func_def_list;
        SymbolTable *new_sym = new SymbolTable;
        $$ = $1;
        string name = $$->dec_name;
        $$->type = new typeInf;
        $$->type->typeName = string("function");
        $$->type->noOfParams = l.size();
        symTab *func_lookup = sym->lookup($$->dec_name, $$->type->typeName);
		for(int i=0; i < sym->entryCount; i++){    if(sym->sym_table[i].id.compare($$->dec_name)==0){    sym->sym_table[i].type.typeName = "function";
				sym->sym_table[i].type.noOfParams = l.size();}
        }
        func_lookup -> nested_table = new_sym;
        list<func_def*>::iterator it;
        for(it = l.begin(); it != l.end(); it++){    func_def *temp = *it;
            new_sym -> lookup(temp->param_name, temp->type->typeName);
	    for(int i = 0; i<new_sym->entryCount; i++){    if(new_sym->sym_table[i].id.compare(temp->param_name)==0){    if(temp->type->arrType.compare("array")==0){    new_sym->sym_table[i].type.arrType = "array";
				new_sym->sym_table[i].type.idx = temp->type->idx;}
		}
	    }
        }
        symTab *sp;
        for(sp = sym->sym_table; sp < &sym->sym_table[sym->entryCount]; sp++){    if(!sp->id.empty() && !sp->id.compare($$->dec_name)){    sp->nested_table = new_sym;}
        }
        curr_sym = new_sym;
        arrQ.emit(_FUNCTION_START, name,"","");}| direct_declarator '(' identifier_list')' {};
assignment_expression_opt :  assignment_expression {} | ;
type_qualifier_list_opt :  type_qualifier_list {} | ;
pointer :  '*'	{    $$ = new typeInf;
        $$->typeName = string("ptr");
        $$->next = NULL;
        $$->pType = string("ptr");
        $$->pCount = 1;}| '*' type_qualifier_list {}| '*' pointer	{    $$ = new typeInf;
        $$->typeName = string("ptr");
        $$->next = NULL;
        $$->pType = string("ptr");
        $$->pCount = $2->pCount + 1;}| '*' type_qualifier_list pointer {};
type_qualifier_list :  type_qualifier {}| type_qualifier_list type_qualifier {};
parameter_type_list_opt : parameter_type_list
    |   {    $$ = new func_list;};
parameter_type_list :  parameter_list	{    $$ = new func_list;
        $$ = $1;}| parameter_list ',' ELLIPSIS {};
parameter_list :  parameter_declaration	{    $$ = new func_list;
        $$->func_def_list.PB($1);}| parameter_list ',' parameter_declaration	{    $1->func_def_list.PB($3);
        $$ = $1;};
parameter_declaration :  declaration_specifiers declarator	{    $$ = new func_def;
        $$->type = $1;
	if($2->alist.size()>0){$$->type->arrType = "array";$$->type->idx = $2->alist[0];$$->type->typeName = $1->typeName;}
	for(int i=0; i<curr_sym->entryCount; i++){    if(curr_sym->sym_table[i].id.compare($2->dec_name)==0){    if($2->type->arrType.compare("array")==0 || curr_sym->sym_table[i].type.arrType.compare("array")==0){    curr_sym->sym_table[i].type.arrType = "array";
				$$->type->arrType = "array";}
		}
	}
	$$->param_name = $2->dec_name;}| declaration_specifiers {};
identifier_list :  IDENTIFIER {}| identifier_list ',' IDENTIFIER {};
typeName :  specifier_qualifier_list	{    $$ = $1;};
initializer :  assignment_expression	{    $$ = $1;}| '{' initializer_list '}' {}| '{' initializer_list ',' '}' {};
initializer_list :  initializer {}| designation initializer {}| initializer_list ',' initializer {}| initializer_list ',' designation initializer {};
designation :  designator_list '=' {};
designator_list :  designator {}| designator_list designator {};
designator :  '[' constant_expression ']' {}| '.' IDENTIFIER {};
statement :  labeled_statement {}| compound_statement {}| expression_statement {}| selection_statement {}| iteration_statement {}| jump_statement {};
labeled_statement :  IDENTIFIER ':' statement {}| CASE_KEYWORD constant_expression ':' statement {}| DEFAULT_KEYWORD ':' statement {};
compound_statement : '{' '}' {}|'{' block_item_list '}'	{    $$ = $2;};
block_item_list :  block_item	{    $$ = $1;
        arrQ.backpatch($1->nextlist, arrQ.index);}| block_item_list M block_item	{    arrQ.backpatch($1->nextlist, $2->instr);
        $$ = new ExpressionAtr;
        $$->nextlist = $3->nextlist;};
block_item :  declaration	{    $$ = new ExpressionAtr;}| statement {};
expression_statement :  ';'	{    $$ = new ExpressionAtr;}| expression ';' {};
selection_statement :  IF_KEYWORD '(' expression N')' M statement N	{    $$ = new ExpressionAtr;
        arrQ.backpatch($4->nextlist, arrQ.index);
        arrQ.convInt2Bool($3);
        arrQ.backpatch($3->truelist, $6->instr);
        $$->nextlist = merge($8->nextlist, $7->nextlist);
        $$->nextlist = merge($$->nextlist, $3->falselist);}| IF_KEYWORD '(' expression N')' M statement N ELSE_KEYWORD M statement	N{    $$ = new ExpressionAtr;
        arrQ.backpatch($4->nextlist , arrQ.index);
        arrQ.convInt2Bool($3);
        $$->nextlist = merge($7->nextlist, $8->nextlist);
        arrQ.backpatch($3->truelist, $6->instr);
        arrQ.backpatch($3->falselist, $10->instr);
        $$->nextlist = merge($$->nextlist, $12->nextlist);
        $$->nextlist = merge($$->nextlist, $11->nextlist);}| SWITCH_KEYWORD '(' expression ')' statement {};
iteration_statement :  WHILE_KEYWORD M '(' expression N ')' M statement	{    arrQ.emit(GOTO,"","","");
        arrQ.backpatch(makelist(arrQ.index-1),$2->instr);    
        arrQ.backpatch($5->nextlist,arrQ.index);
        arrQ.convInt2Bool($4);
        $$ = new ExpressionAtr;
        arrQ.backpatch($8->nextlist, $2->instr);
        arrQ.backpatch($4->truelist, $7->instr);
        $$->nextlist = $4->falselist;}| DO_KEYWORD M statement M WHILE_KEYWORD '(' expression ')' ';'	{    $$ = new ExpressionAtr;
        arrQ.convInt2Bool($7);
        arrQ.backpatch($3->nextlist, $4->instr);
        arrQ.backpatch($7->truelist, $2->instr);
        $$->nextlist = $7->falselist;}| FOR_KEYWORD '(' expression_opt ';' M expression_opt N ';' M expression_opt N ')' M statement	{    $$ = new ExpressionAtr;
        arrQ.emit(GOTO,"","","");
        arrQ.backpatch(makelist(arrQ.index-1),$9->instr);    
        arrQ.backpatch($7->nextlist, arrQ.index);
        arrQ.convInt2Bool($6);
        arrQ.backpatch($11->nextlist,$5->instr);
        arrQ.backpatch($6->truelist,$13->instr);
        arrQ.backpatch($14->nextlist,$9->instr);
        $$->nextlist = $6->falselist;}| FOR_KEYWORD '(' declaration expression_opt ';' expression_opt ')' statement {};
expression_opt : expression {};
jump_statement :  GOTO_KEYWORD IDENTIFIER ';' {}| CONTINUE_KEYWORD ';' {}| BREAK_KEYWORD ';' {}| RETURN_KEYWORD ';'	{    $$ = new ExpressionAtr;
        if(curr_sym->lookup("retVal")->type.typeName.compare("void")==0){    arrQ.emit(RETURN_VOID,"","","");}
    }| RETURN_KEYWORD expression ';'	{    $$ = new ExpressionAtr;
        typeInf type1, type2, type3;
        type1 = curr_sym->lookup("retVal")->type;
        type2 = curr_sym->lookup($2->loc)->type;
        for(int i=0; i<sym->entryCount;i++){    if(sym->sym_table[i].id.compare($2->loc)==0)
			type3 = sym->sym_table[i].type;}
	if(type3.typeName.compare("function")==0){    string t = curr_sym->gentemp(type1);
		arrQ.emit(COPY, t, $2->loc, "");
		arrQ.emit(RETURN,t,"","");}
	else if(type1.typeName == type2.typeName){    arrQ.emit(RETURN, $2->loc, "", "");}
    };
translation_unit :  external_declaration {}| translation_unit external_declaration {};
external_declaration :  function_definition {}| declaration {};
function_definition :  declaration_specifiers declarator declaration_list compound_statement {}| declaration_specifiers declarator compound_statement   {    declaration *new_dec = $2;
        int size = 0;
        typeInf *type = $1;
        if(type->typeName.compare("int")==0) size = 4;
        if(type->typeName.compare("double")==0) size = 8;
        if(type->typeName.compare("char")==0) size = 1;
        if(type->typeName.compare("void")==0) size = 0;
        SymbolTable *gt = &GT;
        arrQ.emit(_FUNCTION_END,new_dec->dec_name,"","");
        symTab *func = gt->lookup($2->dec_name);
        if(func->nested_table != NULL){    if($2->pCount>0)
                type->pType = "ptr";
            symTab *ret = func->nested_table->lookup("retVal", type->typeName, $2->pCount);
            if($2->pCount>0){    ret->pCount = $2->pCount;
                ret->type.pType = "ptr";}
            ret->offset = curr_sym->offset;
            ret->size = size;
            ret->init_val = NULL;}
        curr_sym = gt;
        $$ = $2;};
declaration_list : declaration {}|declaration_list declaration {};
%%
void yyerror(string s) {	cout << s << endl;}