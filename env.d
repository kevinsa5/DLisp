module env;
// Written in the D programming language
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
			if(op.val.get!(string) in funcDict){
				return funcDict[op.val.get!(string)];
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
	expr[] ret = list.dup;/+
	foreach (int i, expr e; ret){
		write("list is calling eval on ");
		writeExpr(e);
		if(!e.atomic) ret[i] = eval(e, env);
	}+/
	return new expr(ret);
}
