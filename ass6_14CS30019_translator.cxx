#include "ass6_14CS30019_translator.h"

void QuadArr :: backpatch(list<int> bp_list, int i)
{
	string s = to_string(i);
	for(auto it = bp_list.begin(); it != bp_list.end(); ++it)
	{
		arr[*it].result = s; 
	}
}

void QuadArr :: emit(opcode_t op, string result, double double_num)
{
	Quad q;
	q.op = op;
	string s = to_string(double_num);
	q.arg_1 = s;
	q.result = result;
	arr.PB(q);
	index++;
}

void QuadArr :: emit(opcode_t op, string result, int num)
{
	Quad q;
	q.op = op;
	string s = to_string(num);
	q.arg_1 = s;
	q.result = result;
	arr.PB(q);
	index++;
}

void QuadArr :: emit(opcode_t op, string result, string arg_1, string arg_2)
{
	Quad q;
	q.op = op;
	q.arg_1 = arg_1;	
	q.arg_2 = arg_2;
	q.result = result;
	arr.PB(q);
	index++;
}

void QuadArr :: emit(opcode_t op, string result, char char_const)
{
	Quad q;
	q.op = op;
	string s = "";
	s = s + char_const;
	q.arg_1 = s;
	q.result = result;
	arr.PB(q);
	index++;
}

void QuadArr :: convD2C(ExpressionAtr * e1, ExpressionAtr *e2)
{
	if(! e2->type.typeName.compare("char"))
		return;
	
	
	e1 = e2;
	e1->type.typeName = "char";
	emit(D2C, e1->loc, e2->loc, "");
	
}


void QuadArr :: convD2I(ExpressionAtr * e1, ExpressionAtr *e2)
{
	if(e2->type.typeName.compare("int")==0)
		return;
	
	e1 = e2;
	e1->type.typeName = "int";
	emit(D2I, e1->loc, e2->loc, "");

}

void QuadArr :: convI2D(ExpressionAtr * e1, ExpressionAtr *e2)
{
	if(! e2->type.typeName.compare("double"))
		return;

	e1 = e2;
	e1->type.typeName = "double";
	emit(I2D, e1->loc, e2->loc, "");

}
void Quad :: print()
{
	if(op >= PLUS && op <=GREATER_EQUAL)
	{
		if(result.compare("")!=1)
			cout<<arg_1;
			
		else 
			cout<<result<<" = "<<arg_1;


		switch(op)
		{
			case DIVIDE: 
				cout<<"/"; 
				break;
			case AND: 
				cout<<"&"; 
				break;
            case MODULO: 
				cout<<"%"; 
				break;
            case GREATER: 
				cout<<">"; 
				break;
            case PLUS: 
				cout<<"+"; 
				break;
            case MINUS: 
				cout<<"-"; 
				break;
			case SHIFT_LEFT: 
				cout<<"<<"; 
				break;
            case SHIFT_RIGHT: 
				cout<<">>"; 
				break;
            case MULT: 
				cout<<"*"; 
				break;
            case IS_EQUAL: 
				cout<<"=="; 
				break;
            case NOT_EQUAL: 
				cout<<"!="; 
				break;
            case LESS_EQUAL: 
				cout<<"<="; 
				break;
            case GREATER_EQUAL: 
				cout<<">="; 
				break;
            case XOR: 
				cout<<"^"; 
				break;
            case OR: 
				cout<<"|"; 
				break;
            case LOGICAL_AND: 
				cout<<"&&"; 
				break;
            case LOGICAL_OR: 
				cout<<"||"; 
				break;
            case LESS: 
				cout<<"<"; 
				break;

		}
		cout<<arg_2<<"\n";
	}
	else if(op >= UNARY_PLUS && op <=NOT)
	{
		cout<<result<<" = ";
		switch(op)
		{
			case UNARY_PLUS:
				cout<<"+";
				break;
			case UNARY_MINUS:
				cout<<"-";
				break;
			case NOT:
				cout<<"!";
				break; 
			case COMPLEMENT:
				cout<<"~";
				break;

		}
		cout<<arg_1<<"\n";
	}
	else if(op >= IF_LESS && op <= IF_NOT_EXPRESSION)
	{
		cout<<"if "<<arg_1<<" ";
		switch(op)
		{
			case IF_NOT_EQUAL:
				cout<<"!=";
				break;
			case IF_EXPRESSION:
				cout<<"!= 0";
				break;
			case IF_NOT_EXPRESSION:
				cout<<"== 0";
				break;
			case IF_LESS_EQUAL:
				cout<<"<=";
				break;
			case IF_GREATER_EQUAL:
				cout<<">=";
				break;
			case IF_LESS:
				cout<<"<";
				break;
			case IF_GREATER:
				cout<<">";
				break;
			case IF_IS_EQUAL:
				cout<<"==";
				break;

		}
		cout<<arg_2<<" goto "<<result<<"\n";
	}

	else if (op == RETURN)
	{
		cout<<"return "<<result<<"\n";
	}
	else if (op == ARRAY_DEREFERENCE)
	{
		cout<<result<<"["<<arg_2<<"] = "<<arg_1<<"\n";
	}
	else if (op == REFERENCE)
	{
		cout<<result<<"= &"<<arg_1<<"\n";
	}
	else if(op == CALL)
	{
		cout<<"call "<<result<<" "<<arg_1<<"\n";
	}
	else if (op == DEREFERENCE)
	{
		cout<<result<<"= *"<<arg_1<<"\n";
	}
	else if(op == GOTO)
	{
		cout<<"goto "<<result<<"\n";
	}
	else if (op == COPY)
	{
		cout<<result<<" = "<<arg_1<<"\n";
	}
	else if (op == ARRAY_ACCESS)
	{
		cout<<result<<" = "<<arg_1<<"["<<arg_2<<"]\n";
	}
	else if (op == PARAM)
	{
		cout<<"param "<<result<<"\n";
	}
	else if (op == RETURN_VOID)
	{
		cout<<"return\n";
	}

	else if (op >= C2I && op <= D2I)
	{
		cout<<result<<" = ";
		switch(op)
		{
			case C2I : 
				cout<<" Char2Int(" <<arg_1<<")" <<endl; 
				break;
            case C2D : 
            	cout<<" Char2Double(" <<arg_1<<")" <<endl; 
            	break;
            case I2C : 
            	cout<<" Int2Char("<<arg_1<<")"<<endl; 
            	break;
            case I2D : 
            	cout<<" Int2Double("<<arg_1<<")"<<endl; 
            	break;
            case D2I : 
            	cout<<" Double2Int("<<arg_1<<")"<<endl; 
            	break;
            case D2C : 
            	cout<<" Double2Char("<<arg_1<<")"<<endl; 
            	break;
		}
	}
	else if (op == _FUNCTION_END)
	{
		cout<<"function "<<result<<" end\n";
	}
	else if (op == _FUNCTION_START)
	{
		cout<<"function "<<result<<" start\n";
	}

}
void QuadArr :: convC2D(ExpressionAtr * e1, ExpressionAtr *e2)
{
	if(! e2->type.typeName.compare("double"))
		return;

	e1 = e2;
	e1->type.typeName = "double";
	emit(C2D, e1->loc, e2->loc, "");
	
}

void QuadArr :: convI2C(ExpressionAtr * e1, ExpressionAtr *e2)
{
	if(e2->type.typeName.compare("char")==0)
		return;

	e1 = e2;
	e1->type.typeName = "char";
	emit(I2C, e1->loc, e2->loc, "");

}

void QuadArr :: convC2I(ExpressionAtr * e1, ExpressionAtr *e2)
{
	if(! e2->type.typeName.compare("int"))
		return;

	e1 = e2;
	e1->type.typeName = "int";
	emit(C2I, e1->loc, e2->loc, "");

}


void QuadArr :: convInt2Bool(ExpressionAtr *exp)
{
	typeInf bool_type;
	bool_type.typeName = "bool";
	if(exp->type.typeName.compare("bool")==0)
		return;

	backpatch(exp->truelist, index);
	backpatch(exp->falselist,index);
	exp->falselist = makelist(index);
	emit(IF_NOT_EXPRESSION,"",exp->loc,"");
	exp->truelist = makelist(index);
	emit(GOTO,"","","");
	exp->type.typeName = "bool";

}


symTab* SymbolTable :: lookup(string s, string type, int pc)
{
	symTab *sp;
	for(sp = sym_table; sp < &sym_table[MAX]; sp++)
	{
		if(!sp->id.empty() && !sp->id.compare(s))
			return sp;
		
		if(sp->id.empty())
		{
			sp = new symTab;
			sp->id = s;
			typeInf t;
			
			t.typeName = type;
			int t_size = 0;
			if(pc == 0)
			{
				if(type.compare("int") == 0)
					t_size = 4;
				else if(type.compare("double") == 0)
					t_size = 8;
				else if(type.compare("char") == 0)
					t_size = 1;
				else if(type.compare("function")==0 || type.compare("void")==0)
					t_size = 0;
				t.size = t_size;
				sp->type = t;
				sp->size = t_size;
				sp->offset = offset;
				sp->init_val = NULL;
				offset = offset + t_size;
				sym_table[entryCount] = *sp;
				entryCount++;

				break;
			}
			else if(pc>0)
			{
				sp->size = 8;
				sp->type.typeName = type;
				cout<<type<<"\n";
				sp->pCount = pc;
				sp->offset = offset;
				sp->init_val = NULL;
				
				offset = offset + 8;
				sym_table[entryCount] = *sp;
				entryCount++;
				break;
			}
			
		}
	}
	return sp;
}

void SymbolTable:: print()
{
	int i;
	cout<<"Name\tType\tSize\tOffset\tInitVal\n";
	cout<<"-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-\n";
	for(i=0;i<entryCount;i++)
	{
		int flag = 0;
		cout<<sym_table[i].id<<"\t";
		if(sym_table[i].pCount == 0 && sym_table[i].type.arrType.compare("array")!=0)
		{
			if(sym_table[i].type.typeName.compare("void")==0)
				cout<<"void\t";
			else if(sym_table[i].type.typeName.compare("int")==0)
				cout<<"int\t";
			else if(sym_table[i].type.typeName.compare("char")==0)
				cout<<"char\t";
			else if(sym_table[i].type.typeName.compare("function")==0)
			{
				cout<<"function\t";
				cout<<sym_table[i].type.noOfParams<<"\t";
			}
			else if(sym_table[i].type.typeName.compare("double")==0)
				cout<<"double\t";
		}
		else if(sym_table[i].type.pType.compare("ptr")==0)
		{
			sym_table[i].size = 8;
			for (int j = 0; j < sym_table[i].pCount; ++j)
				cout<<"*";

			cout<<"\t";
		}
		
		else if(sym_table[i].type.arrType.compare("array")==0)
		{
			cout<<sym_table[i].type.typeName;
			if(sym_table[i].type.idx!=0 && sym_table[i].type.typeName!="")
			{
				cout<<" ["<<sym_table[i].type.idx<<"]";
				flag = 1;
			}
			else
				for (int j = 0; j < sym_table[i].type.arrList.size(); ++j)
					cout<<"["<<sym_table[i].type.arrList[j]<<"]";
			cout<<"\t";
		}
		if(flag==1) 
		{
			cout<<"\t"<<sym_table[i].size*sym_table[i].type.idx<<"\t";
			sym_table[i].size = sym_table[i].size*sym_table[i].type.idx;
		}
		if(flag==0)
			cout<<"\t"<<sym_table[i].size<<"\t";
                if(i>=1)
		    sym_table[i].offset = sym_table[i-1].offset + sym_table[i-1].size;
		cout<<sym_table[i].offset<<"\t";

		if(sym_table[i].init_val == NULL)
			cout<<"NULL";
		else
		{
			if(! sym_table[i].type.typeName.compare("int"))
			{
				cout<<sym_table[i].init_val->intVal;
			}
			if(! sym_table[i].type.typeName.compare("char"))
			{
				cout<<sym_table[i].init_val->charVal;
			}
			if(! sym_table[i].type.typeName.compare("double"))
			{
				cout<<sym_table[i].init_val->doubleVal;
			}
		}
		cout<<"\n";
	}
}

list<int> merge(list<int> a, list<int> b)
{
    list<int> temp;
    temp.merge(a);
    temp.merge(b);
    return temp;
}

list<int> makelist(int index)
{
    list<int> temp;
    temp.PB(index);
    return temp;
}

string SymbolTable :: gentemp(typeInf type)
{
	static int temporary_count = 0;
	string s = "t";
	s = s + to_string(temporary_count);
	temporary_count++;
	sym_table[entryCount].id = s;
	sym_table[entryCount].type = type;
	int t_size = 0;
	if(!type.typeName.compare("int"))
		t_size = 4;
	else if(type.typeName.compare("function")==0 || type.typeName.compare("void")==0)
		t_size = 0;
	else if(! type.typeName.compare("char"))
		t_size = 1;
	else if(type.typeName.compare("double") == 0)
		t_size = 8;


	if(! type.pType.compare("ptr"))
		t_size = 8;
	
	sym_table[entryCount].size = t_size;
	sym_table[entryCount].init_val = NULL;
	sym_table[entryCount].offset = offset;
	sym_table[entryCount].nested_table = NULL;
	offset = offset + t_size;
	
	entryCount++;
	return s;
}