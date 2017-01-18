#include "ass6_14CS30019_translator.h"

extern int global_width;
extern vector<string> string_lits;
extern SymbolTable *sym;
extern SymbolTable *curr_sym;
extern typeInf *global_type;
extern QuadArr arrQ;
extern SymbolTable GT;
extern int yyparse();

void AssemblyGenerator:: createFuncPrologue(){
    stack_req = ((stack_size>>4)+1)<<4;
    cout<<"\t.globl\t"<<function_name<<"\n";
    cout<<"\t.type\t"<<function_name<<", @function\n";
    cout<<function_name<<":\n";
    cout<<"\tpushq\t%rbp\n";
    cout<<"\tmovq\t%rsp, %rbp\n";
    cout<<"\tsubq\t$"<<stack_req<<",\t%rsp\n";
}
void AssemblyGenerator:: handle_strings(){
    int global_string_count = 0;
    cout<<"\t.section\t.rodata\n";
    for(auto it = string_lits.begin(); it != string_lits.end(); it++){
        cout<<global_string_start<<global_string_count++<<":\n";
        cout<<"\t.string "<<*it<<"\n";
    }
    
}
void AssemblyGenerator:: createFuncEpilogue(){
    cout << "\t" << "ret"<<endl;
}
string AssemblyGenerator:: generateGOTOLabels(){
    string t = ".L";
    t = t + to_string(goto_label_count);
    goto_label_count++;
    return t;
}
void associate(int arr[], int l, int m, int r){
    int i, j, k;
    int n1 = m - l + 1;
    int n2 =  r - m;
    int L[n1], R[n2];
 
    for(i = 0; i < n1; i++)
        L[i] = arr[l + i];
    for(j = 0; j < n2; j++)
        R[j] = arr[m + 1+ j];
 
    i = 0;
    j = 0;
    k = l;
    while (i < n1 && j < n2){
        if (L[i] <= R[j]){
            arr[k] = L[i];
            i++;
        }
        else{
            arr[k] = R[j];
            j++;
        }
        k++;
    }
 
    while (i < n1){
        arr[k] = L[i];
        i++;
        k++;
    }
 
    while (j < n2){
        arr[k] = R[j];
        j++;
        k++;
    }
}
void AssemblyGenerator:: convertTACtoAsm(){
    int arg1_binding, arg2_binding, result_binding;
    arg1_binding = arg2_binding = result_binding = 0;
    symTab *global_arg1, *global_arg2, *global_result;    
    symTab* curr_arg1 ;
    curr_arg1 = curr_sym->lookup(currQuad.arg_1);
    symTab* curr_arg2 ;
    curr_arg2= curr_sym->lookup(currQuad.arg_2);
    symTab* curr_result;
    curr_result = curr_sym->lookup(currQuad.result);
    
    global_arg1 = NULL;
    global_arg2 = NULL;
    global_result = NULL;
   
    for(int j = 0; j < (&GT)->entryCount; j++){
        if((&GT)->sym_table[j].id.compare(currQuad.arg_1)==0)
            global_arg1 = &((&GT)->sym_table[j]);
        
    }
    
    for(int j = 0; j < (&GT)->entryCount; j++){
        if((&GT)->sym_table[j].id.compare(currQuad.arg_2)==0)
            global_arg2 = &((&GT)->sym_table[j]);
    }
    
    for(int j = 0; j < (&GT)->entryCount; j++){
        if((&GT)->sym_table[j].id.compare(currQuad.result)==0)
            global_result = &((&GT)->sym_table[j]);
        else 
        global_result = NULL;
    }
    
    
     
    string generator_arg1 = empty_string;
    string generator_arg2 = empty_string;
    string generator_result = empty_string;
    if(currQuad.result[0] <= '0' || currQuad.result[0] >= '9'){
        if(global_result == NULL){
            result_binding = curr_result->offset;
	    string bind = to_string(result_binding);
            generator_result = bind + "(%rbp)";
        }
        else
            generator_result = currQuad.result;
    }
    
    if(currQuad.arg_1[0] <= '0' || currQuad.arg_1[0] >= '9'){
        if(global_arg1 == NULL){
            arg1_binding = curr_arg1->offset;
	    string bind = to_string(arg1_binding);
            generator_arg1 = bind + "(%rbp)";
        }
        else{
	    if(global_arg1->type.typeName.compare("function")==0){
		funcType = 1;
	    }
	    else{generator_arg1 = currQuad.arg_1;}
	}
    }            
        if(currQuad.arg_2[0] <= '0' || currQuad.arg_2[0] >= '9'){
        if(global_arg2 == NULL){
            arg2_binding = curr_arg2->offset;
	    string bind = to_string(arg2_binding);
            generator_arg2 = bind + "(%rbp)";
        }
        else{
	    generator_arg2 = currQuad.arg_2;
	    
	}
            
    }            
    
    if(currQuad.op == UNARY_MINUS){
        cout << "\t" << "movq" << "\t" <<generator_arg1<< ",\t%rax" << endl; 
        cout << "\t" << "negq\t %rax"<< endl;
        cout << "\t" << "movq" << "\t" << "%rax,\t" << generator_result << "\t"  << endl; 
    }
    else if(currQuad.op == COPY){
	if(funcType==1){
	   
	    cout<<"\tmovl\t%eax,\t"<<generator_result<<endl;
	    funcType = 0;
	    
	}
	else{
		if(currQuad.arg_1[0]>='0' && currQuad.arg_1[0]<='9'){
		    cout<<"\tmovl\t$"<<currQuad.arg_1<<",\t"<<generator_result<<"\n";
		}
		else{
		    cout<<"\tmovl\t"<<generator_arg1<<",\t%eax\n"; 
		    cout<<"\tmovl\t"<<"%eax,\t"<<generator_result<<"\n"; 
		}
	}
    }
    else if(currQuad.op == PLUS){
        if((currQuad.arg_2.compare("1"))==0){
            cout<< "\tmovl\t" <<generator_arg1<<",\t%edx\n";
            cout<< "\taddl\t$1,\t%edx\n";
            cout<< "\tmovl\t%edx,\t%eax\n";
            cout<< "\tmovl\t%eax,\t"<< generator_result<<"\n";
        }
        else{
            
            cout<<"\tmovl\t" <<generator_arg1<<",\t%edx\n";
            if(currQuad.arg_2[0]>='0' && currQuad.arg_2[0]<='9')
                cout<<"\tmovl\t$" <<currQuad.arg_2<<",\t%eax\n";
            else
                cout << "\tmovl\t" <<generator_arg2 << ",\t%eax\n";
            cout<<"\taddl\t %edx,\t%eax\n";
            cout<<"\tmovl\t %eax,\t"<<generator_result<<"\n";     
        }
    }
    else if(currQuad.op == MINUS){
        if((currQuad.arg_2).compare("1")==0){
	    
            cout << "\tmovl\t" <<generator_arg1<< ",\t%edx\n";
            cout << "\tsubl\t$1,\t %edx\n";
            cout << "\tmovl\t %edx,\t %eax\n";
            cout << "\tmovl \t %eax,\t"  << generator_result<< "\n";
        }
        else{
            
            cout<< "\tmovl\t" <<generator_arg1<< ",\t%edx\n";
            cout<< "\tmovl\t" <<generator_arg2 << ",\t%eax\n";
            cout<< "\tsubl\t%eax,\t%edx\n";
            cout<< "\tmovl\t%edx,\t%eax\n";
            cout<< "\tmovl \t%eax,\t" << generator_result<<"\n";       
        }
    }
    else if(currQuad.op==MULT){
        
        cout<< "\tmovl\t" <<generator_arg1 << ",\t%eax\n";
        if(currQuad.arg_2[0]>='0' && currQuad.arg_2[0]<='9')
            cout<< "\timull\t$" << currQuad.arg_2 << ",%eax\n";
        else{
            cout<< "\timull\t" <<generator_arg2 << ",%eax\n";
        }
        cout<< "\tmovl\t%eax,\t"<< generator_result<< "\n";           
        
    }
    else if(currQuad.op==DIVIDE){
        cout << "\tmovl\t" <<generator_arg1 << ",\t%eax\n";
        cout << "\tcltd\n";
        cout << "\tidivl\t"<< generator_arg2 << "\n";
        cout << "\tmovl\t%eax,\t" << generator_result<< "\n";       
        
    }
    else if(currQuad.op==MODULO){
        cout << "\tmovl\t" <<generator_arg1 << ",\t%eax\n";
        cout << "\tcltd\n";
        cout << "\tidivl\t"<< generator_arg2 << "\n";
        cout << "\tmovl\t%edx,\t"  << generator_result << "\n";          
        
    }
    
    else if(currQuad.op==IF_LESS){
        
        cout << "\tmovl\t" <<generator_arg1 << ",\t%eax\n";
        cout << "\tcmpl\t" <<generator_arg2 << ",\t%eax\n";
        cout << "\tjge\t.L" << goto_label_count <<"\n";
        cout << "\tjmp\t" <<currQuad.result <<"\n";
        cout << ".L" << goto_label_count  << ":\n";
        goto_label_count = goto_label_count + 1;
    }
    else if(currQuad.op==IF_GREATER){
        
        cout<< "\tmovl\t" <<generator_arg1 << ",\t%eax\n";
        cout<< "\tcmpl\t" <<generator_arg2 << ",\t%eax\n";
        cout<< "\tjle\t.L" << goto_label_count << "\n";
        cout<< "\tjmp\t" <<currQuad.result << "\n";
        cout<< ".L"<< goto_label_count  << ":\n";
        goto_label_count = goto_label_count + 1;
    }
    else if(currQuad.op==IF_IS_EQUAL){
        
        
        cout << "\tmovl\t" <<generator_arg1 << ",\t%eax\n";
        cout << "\tcmpl\t" <<generator_arg2 << ",\t%eax\n";
        cout << "\tjne\t.L" << goto_label_count << "\n";
        cout << "\tjmp\t" <<currQuad.result << "\n";
        cout << ".L" << goto_label_count  << ":\n";
        goto_label_count = goto_label_count + 1;
    }
    else if(currQuad.op==IF_NOT_EQUAL){
        
        
        cout << "\tmovl\t" <<generator_arg1 << ",\t%eax\n";
        cout << "\tcmpl\t" <<generator_arg2 << ",\t%eax\n";
        cout << "\tje\t.L" << goto_label_count << "\n";
        cout << "\tjmp\t" <<currQuad.result << "\n";
        cout << ".L" << goto_label_count  << ":\n";
        goto_label_count = goto_label_count + 1;
    }
    
    else if(currQuad.op==IF_NOT_EXPRESSION){
	
        cout<< "\tcmpl\t$0,\t"<<generator_arg1<< "\n"; 
        cout<< "\tjne\t.L"<< goto_label_count<<"\n"; 
        cout<< "\tjmp\t"<<currQuad.result<<endl;
        cout<< ".L"<<goto_label_count<<" : \n";  
        goto_label_count = goto_label_count + 1;     
    }
    else if(currQuad.op==IF_EXPRESSION){  
	
        cout<< "\tcmpl\t$0,\t"<<generator_arg1<< endl; 
        cout<< "\tje\t.L"<< goto_label_count<<endl; 
        cout<< "\tjmp\t"<<currQuad.result<<endl;
        cout<< ".L" <<goto_label_count<<" : \n" ;  
        goto_label_count++;
    }
  
    else if(currQuad.op==GOTO){
        
        cout<<"\tjmp\t" <<currQuad.result<<"\n";
    }
    else if(currQuad.op == PARAM){
        if(next_quad.result.compare("printi")==0 || next_quad.result.compare("prints")==0 || next_quad.result.compare("readi")==0){
	    if(currQuad.result[0]=='.'){
		cout<<"\tmovq\t$"<<currQuad.result<<",\t%rdi\n";
	    }
	    else if(currQuad.result[0]>='0' && currQuad.result[0]<='9')
                cout<<"\tmovq\t$"<<currQuad.result<<",\t%rdi\n";
            else
                cout<<"\tmovq\t"<<generator_result<<",\t%rdi\n";
            noOfParams++;
	}
	else{
	     string s;
             std::vector<string> str1;
	     int flag = 0;
             if(currQuad.result[0]>='0' && currQuad.result[0]<='9'){
                s = s + "\tmovq\t$" + currQuad.result + ",\t%rax\n";
             }
             else{
		 flag = 0;
		 for(int i=0;i<new_sym->entryCount;i++){
		     if(currQuad.result.compare(new_sym->sym_table[i].id)==0 && new_sym->sym_table[i].type.arrType.compare("array")==0){
		     	if(result_binding>0){s = s + "\tmovq\t" + generator_result + ",\t%rax\n";flag = 1;}
			else{s = s + "\tleaq\t" + generator_result + ",\t%rax\n";flag = 1;}
		     }
		 }
		 if(flag == 0)
                 	s = s + "\tmovq\t" + generator_result + ",\t%rax\n";
        	 str1.PB(s);
        	 str1.PB("\tpushq\t%rax\n");
        	 paramStack.push(str1);
	  
	    }
	}
    }
    else if(currQuad.op==CALL){
	if(currQuad.result.compare("printi")==0 || currQuad.result.compare("prints")==0 || currQuad.result.compare("readi")==0){
	   int num;
           num = atoi((currQuad.arg_1).c_str());
           num=num*4;
           cout << "\t" << "call\t"<<currQuad.result << endl;
           if(currQuad.arg_2 != "")
               cout << "\t" << "movq\t%rax,\t"<<generator_arg2<< endl;
	}
	else{
	int num;
        num = atoi((currQuad.arg_1).c_str());
        num=num*8;
        while(paramStack.size() > 0){
            vector<string> str; 
            str = paramStack.top();
            for(int i = 0; i<str.size(); i++){
                cout<<str[i];
            }
	    paramStack.pop();
        }
        
        cout << "\tcall\t"<<currQuad.result << "\n";
        cout << "\taddq\t$"<<num<<",\t%rsp"<< "\n";
	cout<<"#--"<<currQuad.arg_2<<"\n";
	}
    }
    else if(currQuad.op==RETURN){
        if(currQuad.result.compare(empty_string)!=0)
        	cout<<"\tmovq\t"<<generator_result<< ",\t%rax"<< endl;
	cout <<"\tleave\n\tret\n";
	noOfParams = 0;
            
    }
    else if(currQuad.op==DEREFERENCE){
        
        cout<<"\tmovq\t"<<generator_arg1<<",\t%rax\n";
        cout<<"\tmovl\t(%rax),\t %ecx\n";
        cout<<"\tmovl\t%ecx,\t"<<generator_result<<"\n";
    }
    else if(currQuad.op==REFERENCE){
        
        cout<<"\tleaq\t"<<generator_arg1<<",\t%rax\n";
        cout<<"\tmovq\t%rax,\t"<<generator_result<<"\n";
    }
    
    else if(currQuad.op==ARRAY_ACCESS){
        
	if(arg1_binding>0){
		cout<<"\tmovslq\t"<<generator_arg2<<",\t%rdx\n";
		cout<<"\tmovq\t"<<arg1_binding<<"(%rbp),\t%rdi\n";
		cout<<"\taddq\t%rdi,\t%rdx\n";
		cout<<"\tmovl\t(%rdx),\t%eax\n";
		cout<<"\tmovl\t%eax,\t"<<generator_result<<"\n";
	}
	else{
		cout<<"\tmovslq\t"<<generator_arg2<<",\t%rdx"<< endl;
		cout<<"\tmovl\t"<<arg1_binding<<"(%rbp,%rdx,1),\t%eax\n";
		cout<<"\tmovl\t%eax,\t"<<generator_result<<"\n";
	} 
    }
    else if(currQuad.op==ARRAY_DEREFERENCE){
        
	if(result_binding>0)		{
		cout<<"\tmovslq\t"<<generator_arg2<<",\t%rdx\n";
		cout<<"\tmovl\t"<<generator_arg1<<",\t%eax\n";
		cout<<"\tmovq\t"<<result_binding<<"(%rbp),\t%rdi\n";
		cout<<"\taddq\t%rdi,\t%rdx\n";
		
		cout<<"\tmovl\t%eax,\t(%rdx)\n";
	}
	else{
        cout<<"\tmovslq\t"<<generator_arg2<<",\t%rdx\n";
        cout<<"\tmovslq\t"<<generator_arg1<<",\t%rax\n";
        cout<<"\tmovq\t%rax,\t"<<result_binding<<"(%rbp,%rdx,1)\n";}
    }
    if(false){
        associate(NULL, 0, 5, 2);
    }
}
 
void AssemblyGenerator:: setGOTOLabelsTarget(){
    for(vector<Quad>::iterator it = arrQ.arr.begin(); it != arrQ.arr.end(); it++){
        if(it->op >= IF_LESS && it->op <= GOTO){
            int backpatch_result = atoi(((*it).result).c_str());
            if(generateGoto.count(backpatch_result)==0){
                string label = generateGOTOLabels();
                generateGoto[backpatch_result] = label;
            }
            (*it).result = generateGoto[backpatch_result];
        }
    }
}
void AssemblyGenerator:: bindMemRecord(){
    
    handle_strings();
    handleGlobals();
    setGOTOLabelsTarget();
    int quad_size = arrQ.arr.size();
    for(int i = 0; i < quad_size; i++){
	cout<<"  # "; arrQ.arr[i].print();
        
        if(generateGoto.count(i)>0){
            cout<<generateGoto[i]<<":\n";
        }
        currQuad = arrQ.arr[i];	
	if(i<quad_size-1)
		next_quad = arrQ.arr[i+1];	
        if(arrQ.arr[i].op == _FUNCTION_START){
            if(arrQ.arr[i+1].op != _FUNCTION_END){
		ptr_type=0;
                symTab *p=NULL;
                for(int j = 0; j < (&GT)->entryCount; j++){
                    if(((&GT)->sym_table[j].id).compare(arrQ.arr[i].result)==0)
                        p = &((&GT)->sym_table[j]);
                }
                
                function_name = arrQ.arr[i].result;
                row = p;
                new_sym = p->nested_table;
                curr_sym = new_sym;
                flagParam = 1;
                int total_count; 
                total_count =  row->type.noOfParams;
		for(int j = 0; j < total_count; j++){
		    new_sym->sym_table[j].offset = memory;
		    memory = memory + 8;
		    cout<<"#--param_offset:"<<memory<<"\n";
		}
		memory_bind_ebp = 0;
                for(int j = total_count; j < new_sym->entryCount; j++){
		    if(new_sym->sym_table[j].id.compare("retVal")==0){
		    }
                    if(new_sym->sym_table[j].id.compare("retVal")){
                        memory_bind_ebp = memory_bind_ebp - new_sym->sym_table[j].size;
                        new_sym->sym_table[j].offset = memory_bind_ebp;
			cout<<"#--local var offset: "<<new_sym->sym_table[j].size<<" "<<new_sym->sym_table[j].offset<<"\n";
                    }
                }
                cout<<"#"<<memory_bind_ebp<<endl;
                stack_size = memory_bind_ebp*(-1) + memory;
		for(int j = 0; j< new_sym->entryCount; j++){
			if(new_sym->sym_table[j].id.compare(currQuad.result)==0||!new_sym->sym_table[j].id.compare(currQuad.arg_1)==0
                       ||!new_sym->sym_table[j].id.compare(currQuad.arg_2)==0){
				if(new_sym->sym_table[j].type.pType.compare("ptr")==0)
					ptr_type = 1;
				cout<<"##ptr"<<new_sym->sym_table[j].id<<endl;
			}
		}
                createFuncPrologue();
            }
            else{
                i++;
		noOfParams = 0;
		memory = 16;
		memory_bind_ebp = 0;
                continue;
            }
        }
        else if(arrQ.arr[i].op == _FUNCTION_END){
            sym = &GT;
            curr_sym = &GT;
	    cout<<"\tleave\n\tret\n";
            cout << "\t.size\t"<<function_name<<",\t.-"<<function_name<<endl;
	    function_name = "";
            noOfParams = 0;
	    memory = 16;
	    memory_bind_ebp = 0;
	    continue;
        }
        if(function_name.compare(empty_string)){
            convertTACtoAsm();
        }
    }
}
void AssemblyGenerator:: handleGlobals(){
    symTab *p;
    int i=0;
    while(i < (&GT)->entryCount){
        if((&GT)->sym_table[i].id[0] != 't'){
            if((&GT)->sym_table[i].type.typeName.compare("char")==0){
                if(! (&GT)->sym_table[i].init_val)
                    cout<<"\tcomm\t"<<(&GT)->sym_table[i].id<<",1,1\n";
                else{
                    cout << "\t.globl\t"<<(&GT)->sym_table[i].id<<"\n";
                    cout << "\t.data"<<endl;
                    cout << "\t.type\t"<<(&GT)->sym_table[i].id<<", @object"<<"\n";
                    cout << "\t.size\t"<<(&GT)->sym_table[i].id<<", 1"<<"\n";
                    cout << (&GT)->sym_table[i].id<< ":" << "\n";
                    cout << "\t.byte\t"<<(&GT)->sym_table[i].init_val->intVal<<"\n";
                }
            }
        if( ! (&GT)->sym_table[i].type.typeName.compare("int")){
                if((&GT)->sym_table[i].init_val){
                    cout << "\t.globl\t"<<(&GT)->sym_table[i].id<<"\n";
                    cout << "\t.data"<<endl;
                    cout << "\t.align 4"<<endl;
                    cout << "\t.type\t"<<(&GT)->sym_table[i].id<<", @object"<<"\n";
                    cout << "\t.size\t"<<(&GT)->sym_table[i].id<<", 4"<<"\n";
                    cout << (&GT)->sym_table[i].id<< ":" << "\n";
                    cout << "\t.long\t"<<(&GT)->sym_table[i].init_val->intVal<<"\n";
                }
                    
                else{
                    cout<<"\tcomm\t"<<(&GT)->sym_table[i].id<<",4,4\n";
                    
                }
            }
        }
        i++;
    }
}
int main(int argc, char *argv[]){   
    int arr_size = arrQ.arr.size();
    bool statusFail = yyparse();
    
    string output_file = "a.out";
    if(argc==2) output_file = string(argv[1]);
    string quad_file = "ass6_14CS30019_quads" + output_file + ".out";
    ofstream outf1(quad_file.c_str());
    streambuf *coutbuf1 = cout.rdbuf();
    cout.rdbuf(outf1.rdbuf());
    cout<<"====================List of quads======================\n";
    int i=0;
    while(i<arr_size){
        cout<<i<<" : "; 
        arrQ.arr[i].print();
        i++;
    }
    cout<<"\n----------------Global symbol table-----------------------\n";
    SymbolTable *g = &GT;
    g->print();
    i=0;
    while(i< g->entryCount){
        if(g->sym_table[i].nested_table != NULL){
            cout<<"----------------Symbol table of "<<g->sym_table[i].id<<"----------------"<<endl;
            g->sym_table[i].nested_table->print();
        }
        i++;
    }
    if(statusFail==0)
        printf("Compilation success\n");
    else
        printf("Compilation failure\n");
    cout<<"=========================================================\n";
    
    cout.rdbuf(coutbuf1);
    string tmp = "ass6_14CS30019_" + output_file + ".s";
    ofstream outfile(tmp.c_str());
    streambuf *coutbuf = cout.rdbuf();
    cout.rdbuf(outfile.rdbuf());
 
    curr_sym = sym;
    AssemblyGenerator c;
    c.bindMemRecord();
    
    cout.rdbuf(coutbuf);
    return 0;
}