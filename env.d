// Written in the D programming language

module env;

import std.variant;
import std.stdio;
import std.conv;

import scheme;

class Env
{
	private:
		Env outer;
		expr[string] dict;
		expr function(expr[], Env)[string] funcDict;
	public:
		this(Env o = null){
			outer = o;
			addBuiltins();
		}
		void addSymbol(string name, expr val){
			dict[name] = val;
		}
		void addFunction(string name, expr function(expr[], Env) f){
			funcDict[name] = f;
		}
		expr function(expr[], Env) findFunction(expr op){
			if(op.val.get!(symbol).name in funcDict){
				return funcDict[op.val.get!(symbol).name];
			}
			if(outer !is null)
				return outer.findFunction(op);
			return null;
		}
	private:
		void addBuiltins(){
			addFunction("+", &add);
			addFunction("*", &mul);
			addFunction("-", &sub);
			addFunction("/", &div);
			addFunction("list", &list);
			addFunction("length", &length);
			addFunction("append", &append);
			addFunction("list-ref", &list_ref);
		}
}

expr add(expr[] list, Env env){
	if(list.length == 0) return new expr(0);
	return new expr(add(list[1..$], env).val + list[0].val);
}

expr sub(expr[] list, Env env){
	if(list.length == 1) return sub([new expr(0), list[0]], env);
	return new expr(list[0].val - add(list[1..$], env).val);
}

expr mul(expr[] list, Env env){
	if(list.length == 0) return new expr(1);
	return new expr(mul(list[1..$], env).val * list[0].val);
}

expr div(expr[] list, Env env){
	if(list.length == 1) return div([new expr(1), list[0]], env);
	return new expr(list[0].val / mul(list[1..$], env).val);	
}

expr list(expr[] list, Env env){
	return new expr(list);
}

expr length(expr[] list, Env env){
	return new expr(list[0].val.get!(expr[]).length);
}

expr append(expr[] list, Env env){
	if(list.length == 1) return list[0];
	return new expr(list[0].val ~ (append(list[1..$], env)).val);
}

expr list_ref(expr[] list, Env env){
	return list[0].val.get!(expr[])[list[1].val.get!(long)];
}

