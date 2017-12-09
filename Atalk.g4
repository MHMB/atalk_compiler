grammar Atalk;

@members{
	void print(String str){
		System.out.println(str);
	}
	
	void createActor(String name , int mailBoxLenght) throws ItemAlreadyExistsException{
		int offset = SymbolTable.top.getOffset(Register.GP);
		SymbolTable.top.put(new SymbolTableActorItem(new Actor(name , mailBoxLenght),offset));
    	if(SymbolTable.top != null)
        	offset = SymbolTable.top.getOffset(Register.GP);
        SymbolTable.push(new SymbolTable());
        SymbolTable.top.setOffset(Register.GP, offset);
	}

	// void createReceiver(){
	// 	int offset = SymbolTable.top.getOffset(Register.TEMP9);
	// 	SymbolTable.top.put(new ReceiverDefItem());
	// 	if(SymbolTable.top != null)
	// 		offset = SymbolTable.top.getOffset(Register.TEMP9);
	// 	SymbolTable.push(new SymbolTable());
	// 	SymbolTable.top.setOffset(Register.TEMP9 , offset);
	// }

	void putGlobalVar(String name, Type type) throws ItemAlreadyExistsException {
        SymbolTable.top.put(
            new SymbolTableGlobalVariableItem(
                new Variable(name, type),
                SymbolTable.top.getOffset(Register.GP)
            )
        );
    }

	void beginScope() {
    	int offset = 0;
    	if(SymbolTable.top != null)
        	offset = SymbolTable.top.getOffset(Register.SP);
        SymbolTable.push(new SymbolTable());
        SymbolTable.top.setOffset(Register.SP, offset);
    }

	void endScope() {
        print(String.format("End scope:\n\tStack offset: %d\tData Segment offset: %d\tHeap offset: %d\n",
			SymbolTable.top.getOffset(Register.SP) , 
			SymbolTable.top.getOffset(Register.GP) , 
			SymbolTable.top.getOffset(Register.TEMP9)));
        SymbolTable.pop();
    }

	String createTemporaryName(String name , int num){
		return name+"_Tempprary_" + num;
	}

	void endActor(){
		print(String.format("Actor ends:\n\tStack offset: %d\tData Segment offset: %d\tHeap offset: %d\n",
			SymbolTable.top.getOffset(Register.SP) , 
			SymbolTable.top.getOffset(Register.GP) , 
			SymbolTable.top.getOffset(Register.TEMP9)));
        SymbolTable.pop();
	}

}

program:
		{beginScope();}
		(actor | NL)*
		{endScope();}
	;

actor:
		'actor' actor_id  = ID '<' box_len = CONST_NUM '>' NL
		{
			try	{
				if($box_len.int > 0)
					createActor($actor_id.text , $box_len.int);
				else{
						print(String.format("[Line #%s] Actor \"%s\" mailbox is %d. It's an illegal value.", $actor_id.getLine(), $actor_id.text , $box_len.int));
						createActor($actor_id.text , 0);
					}
			}
			catch(ItemAlreadyExistsException e){
				int n = 1;
				print(String.format("[Line #%s] Actor \"%s\" already exists.", $actor_id.getLine(), $actor_id.text));
				while(true){
					try{
						createActor(createTemporaryName($actor_id.text , n) , $box_len.int);
						break;
					}
					catch(ItemAlreadyExistsException ee){
						n++;
						continue;
					}
				}
			}
		}
			(state | receiver | NL)*
		'end' (NL | EOF)
		{endActor();}
	;

state:
		var_type = type  var_id = ID (',' ID)* NL
		{
			try{
				putGlobalVar($var_id.text , $var_type.return_type);
			}
			catch(ItemAlreadyExistsException e) {
            	print(String.format("[Line #%s] Variable \"%s\" already exists.", $var_id.getLine(), $var_id.text));
            }
		}
	;

receiver:
		'receiver' ID '(' (type ID (',' type ID)*)? ')' NL
			statements
		'end' NL
	;

type returns [Type return_type]:
		'char' ('[' CONST_NUM ']')*{ $return_type = CharType.getInstance(); }
	|	'int' ('[' CONST_NUM ']')*{$return_type = IntType.getInstance();}
	;

block:
		'begin' NL
			statements
		'end' NL
	;

statements:
		(statement | NL)*
	;

statement:
		stm_vardef
	|	stm_assignment
	|	stm_foreach
	|	stm_if_elseif_else
	|	stm_quit
	|	stm_break
	|	stm_tell
	|	stm_write
	|	block
	;

stm_vardef:
		type ID ('=' expr)? (',' ID ('=' expr)?)* NL
	;

stm_tell:
		(ID | 'sender' | 'self') '<<' ID '(' (expr (',' expr)*)? ')' NL
	;

stm_write:
		'write' '(' expr ')' NL
	;

stm_if_elseif_else:
		'if' expr NL statements
		('elseif' expr NL statements)*
		('else' NL statements)?
		'end' NL
	;

stm_foreach:
		'foreach' ID 'in' expr NL
			statements
		'end' NL
	;

stm_quit:
		'quit' NL
	;

stm_break:
		'break' NL
	;

stm_assignment:
		expr NL
	;

expr:
		expr_assign
	;

expr_assign:
		expr_or '=' expr_assign
	|	expr_or
	;

expr_or:
		expr_and expr_or_tmp
	;

expr_or_tmp:
		'or' expr_and expr_or_tmp
	|
	;

expr_and:
		expr_eq expr_and_tmp
	;

expr_and_tmp:
		'and' expr_eq expr_and_tmp
	|
	;

expr_eq:
		expr_cmp expr_eq_tmp
	;

expr_eq_tmp:
		('==' | '<>') expr_cmp expr_eq_tmp
	|
	;

expr_cmp:
		expr_add expr_cmp_tmp
	;

expr_cmp_tmp:
		('<' | '>') expr_add expr_cmp_tmp
	|
	;

expr_add:
		expr_mult expr_add_tmp
	;

expr_add_tmp:
		('+' | '-') expr_mult expr_add_tmp
	|
	;

expr_mult:
		expr_un expr_mult_tmp
	;

expr_mult_tmp:
		('*' | '/') expr_un expr_mult_tmp
	|
	;

expr_un:
		('not' | '-') expr_un
	|	expr_mem
	;

expr_mem:
		expr_other expr_mem_tmp
	;

expr_mem_tmp:
		'[' expr ']' expr_mem_tmp
	|
	;

expr_other:
		CONST_NUM
	|	CONST_CHAR
	|	CONST_STR
	|	ID
	|	'{' expr (',' expr)* '}'
	|	'read' '(' CONST_NUM ')'
	|	'(' expr ')'
	;

CONST_NUM:
		[0-9]+
	;

CONST_CHAR:
		'\'' . '\''
	;

CONST_STR:
		'"' ~('\r' | '\n' | '"')* '"'
	;

NL:
		'\r'? '\n' { setText("new_line"); }
	;

ID:
		[a-zA-Z_][a-zA-Z0-9_]*
	;

COMMENT:
		'#'(~[\r\n])* -> skip
	;

WS:
    	[ \t] -> skip
    ;