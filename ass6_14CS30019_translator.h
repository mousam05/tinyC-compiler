#ifndef __ASS6_14CS30019_TRANSLATOR_H
#define __ASS6_14CS30019_TRANSLATOR_H
#include <string>
#include <stdio.h>
#include <map>
#include <stack>
#include <fstream>
#include <iostream>
#include <vector>
#include <list>
#include <cstring>

using namespace std;

#define PB push_back
#define ACTI 2500
#define MAX 100000

typedef struct typeInf
{
	string typeName;
	int size;
	int pCount;
	string pType;
	string arrType;
	int noOfParams;
	int idx;
	vector<int> arrList;
	struct typeInf *next;
}typeInf;

class ExpressionAtr
{
public:
	string loc;
	list<int> truelist, falselist, nextlist;
	int instr;
	typeInf type;
	bool is_pType;
	int dim ;
	string *inner;
	ExpressionAtr()
	{
		dim = 0;
		inner = NULL;
		nextlist = list<int>();
	}
	int is_array_id;
};

class Quad;
class QuadArr;

enum opcode_t{
	//binary
	PLUS = 1,
	MINUS,
	MULT,
	DIVIDE,
	AND,
	MODULO,
	SHIFT_LEFT,
	SHIFT_RIGHT,
	XOR,
	OR,
	LOGICAL_AND,
	LOGICAL_OR,
	LESS,
	GREATER,
	IS_EQUAL,
	NOT_EQUAL,
	LESS_EQUAL,
	GREATER_EQUAL,

	//unary
	UNARY_PLUS,
	UNARY_MINUS,
	COMPLEMENT,
	NOT,

	//branch
	IF_LESS,
	IF_GREATER,
	IF_LESS_EQUAL,
	IF_GREATER_EQUAL,
	IF_IS_EQUAL,
	IF_NOT_EQUAL,
	IF_EXPRESSION,
	IF_NOT_EXPRESSION,
	GOTO,

	//assignment
	COPY,

	//array
	ARRAY_ACCESS,
	ARRAY_DEREFERENCE,

	//function call
	CALL,
	PARAM,
	RETURN_VOID,
	RETURN,

	//pointer
	REFERENCE,
	DEREFERENCE,
	POINTER_ASSIGNMENT,

	_FUNCTION_START,
	_FUNCTION_END,
	_INCREMENT,
	_DECREMENT,

	C2I,
	C2D,
	I2C,
	D2C,
	I2D,
	D2I

};

class Quad
{
public:
	opcode_t op;
	string arg_1, arg_2, result;
	void print();
};

typedef union init{
	int intVal;
	double doubleVal;
	char charVal;
}initValue;

class SymbolTable;

class QuadArr
{
public:

	vector<Quad> arr;
	int index;
	QuadArr(){ index = 0; }


	void emit(opcode_t op, string result, int num);
	void emit(opcode_t op, string result, char char_const);
	void emit(opcode_t op, string result, double double_num);
	void emit(opcode_t op, string result, string arg_1, string arg_2 = 0);


	void convI2C(ExpressionAtr *e1, ExpressionAtr *e2);
	void convD2C(ExpressionAtr *e1, ExpressionAtr *e2);
	void convI2D(ExpressionAtr *e1, ExpressionAtr *e2);
	void convC2I(ExpressionAtr *e1, ExpressionAtr *e2);
	void convC2D(ExpressionAtr *e1, ExpressionAtr *e2);
	void convD2I(ExpressionAtr *e1, ExpressionAtr *e2);

	void backpatch(list<int> bp_list, int i);
	void convInt2Bool(ExpressionAtr *e);
};

typedef struct symTab
{
	string id;
	typeInf type;
	initValue *init_val;
	int size;
	int offset;
	int pCount;
	SymbolTable *nested_table;
}symTab;

class SymbolTable
{
public:
	symTab sym_table[MAX];
	int entryCount;
	int offset;

	SymbolTable() 
	{
		int i=0;
		while(i<MAX){
			sym_table[i].nested_table = NULL;
			i++;
		}
		entryCount = 0;
		offset = 0;
	}

	symTab* lookup(string s, string type_nm = "int" , int pc = 0);
	void print();
	string gentemp(typeInf type);

};

typedef struct func_param_def
{
	string param_name;
	typeInf *type;
}func_def;


typedef struct func_param_list
{
	list<func_def*> func_def_list;
}func_list;


class AssemblyGenerator
{
public:
	
	string function_name;
	int memory;
	int stack_req;
	int ptr_type;
	map<int, string> generateGoto;
	Quad currQuad;
	Quad next_quad;
	stack<vector<string> > paramStack;
	int noOfParams;
	int array_param ;
	int goto_label_count;
	string empty_string;
	string global_string_start;
	int funcType_r;
	symTab *row;
	SymbolTable *new_sym;
	int stack_size;
	int flagParam;
	int memory_bind_ebp;
	int funcType;


	AssemblyGenerator()
	{
		funcType_r = 0;
		ptr_type = 0;
		array_param = 0;
		function_name = "";
		stack_size = 0;
		global_string_start = ".LC";
		goto_label_count = 0;
		memory_bind_ebp = 0;
		memory = 16;
		noOfParams = 0;
		row = NULL;
		new_sym = NULL;
		empty_string = "";
		funcType = 0;

	}
	void convertTACtoAsm();
	void handle_strings();
	void setGOTOLabelsTarget();
	void createFuncPrologue();
	void createFuncEpilogue();
	string generateGOTOLabels();
	void bindMemRecord();
	void handleGlobals();


};

class declaration
{
public:
	ExpressionAtr *init;
	string dec_name;
	typeInf *type;
	func_list *param_list;
	vector<int> alist;
	int pCount;
};


typedef struct init_decl_list
{
	list<declaration*> dec_list;
}init_dec_list;

list<int> makelist(int index);
list<int> merge(list<int> a, list<int> b);

#endif /* ASS6_14CS30019_TRANSLATOR_H */
