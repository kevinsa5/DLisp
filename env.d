// Written in the D programming language

module env;

import std.variant;
import std.stdio;
import std.conv;

import lisp;

class Env
{
	private:
		Env outer;
		expr[string] dict;
		expr delegate(expr[], Env)[string] funcDict;
	public:
		this(Env o = null){
			outer = o;
		}
		void addSymbol(symbol s, expr val){
			dict[s.name] = val;
		}
		void addFunction(string name, expr function(expr[], Env) f){
			funcDict[name] = std.functional.toDelegate(f);
		}
		void addDelegate(string name, expr delegate(expr[], Env) d){
			funcDict[name] = d;
		}
		expr find(symbol s){
			if(s.name in dict)
				return dict[s.name];
			if(outer !is null)
				return outer.find(s);
			throw new Exception("No such symbol: "~s.name);
		}
		expr delegate(expr[], Env) findFunction(symbol s){
			if(s.name in funcDict){
				return funcDict[s.name];
			}
			if(outer !is null)
				return outer.findFunction(s);
			return null;
		}
		void addBuiltins(){
			addFunction("+", &add);
			addFunction("*", &mul);
			addFunction("-", &sub);
			addFunction("/", &div);
			addFunction("list", &list);
			addFunction("length", &length);
			addFunction("append", &append);
			addFunction("list-ref", &list_ref);
			addFunction(">", &gt);
			addFunction("<", &lt);
			addFunction(">=", &ge);
			addFunction("<=", &le);
			addFunction("=", &equals);
			addFunction("zero?", &zero);
			addFunction("positive?", &positive);
			addFunction("negative?", &negative);
			addFunction("max", &max);
			addFunction("min", &min);
			addFunction("abs", &abs);
			addFunction("modulo", &modulo);
			addFunction("remainder", &remainder);
			addFunction("quotient", &quotient);
			addFunction("and", &and);
			addFunction("or", &or);
			addFunction("print", &print);
			addFunction("error", &error);
			addFunction("str", &str);
		}
}

expr str(expr[] list, Env env){
	return new expr(list[0].toStringNoTypes());
}

expr error(expr[] list, Env env){
	throw new Exception("Lisp Error: " ~ list[0].val.get!string);
}

expr print(expr[] list, Env env){
	foreach (int i, expr e; list){
		string s = e.toStringNoTypes();
		if(e.val.type == typeid(string))
			s = s[1..$-1];
		write(s);
		if(i != list.length-1) write(" ");
	}
	return null;
}

expr and(expr[] list, Env env){
	if(list.length == 1) return new expr(list[0].val.type == typeid(bool) && list[0].val != false);
	return new expr(list[0].val.get!(bool) && and(list[1..$], env).val.get!(bool));
}
expr or(expr[] list, Env env){
	if(list.length == 1) return new expr(list[0].val.type == typeid(bool) && list[0].val != false);
	return new expr(list[0].val.get!(bool) || or(list[1..$], env).val.get!(bool));
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

expr genericComparison(bool delegate(Variant a, Variant b) f, expr[] list, Env env){
	if(list.length == 2) 
		return new expr(f(list[0].val, list[1].val));
	return new expr(f(list[0].val, list[1].val) && genericComparison(f, list[1..$], env).val.get!(bool));
}

expr gt(expr[] list, Env env){
	return genericComparison(delegate bool(a,b){return (a>b);}, list, env);
}

expr lt(expr[] list, Env env){
	return genericComparison(delegate bool(a,b){return (a<b);}, list, env);
}

expr ge(expr[] list, Env env){
	return genericComparison(delegate bool(a,b){return (a>=b);}, list, env);
}

expr le(expr[] list, Env env){
	return genericComparison(delegate bool(a,b){return (a<=b);}, list, env);
}

expr equals(expr[] list, Env env){
	return genericComparison(delegate bool(a,b){return (a==b);}, list, env);
}

expr zero(expr[] list, Env env){
	if(list.length == 0) return new expr(true);
	return new expr(list[0].val == 0 && zero(list[1..$], env));
}
expr positive(expr[] list, Env env){
	if(list.length == 0) return new expr(true);
	return new expr(list[0].val > 0 && positive(list[1..$], env));
}
expr negative(expr[] list, Env env){
	if(list.length == 0) return new expr(true);
	return new expr(list[0].val < 0 && negative(list[1..$], env));
}

expr max(expr[] list, Env env){
	if(list.length == 1) return list[0];
	expr max = max(list[1..$], env);
	return (list[0].val > max.val)? list[0] : max;
}

expr min(expr[] list, Env env){
	if(list.length == 1) return list[0];
	expr min = min(list[1..$], env);
	return (list[0].val < min.val)? list[0] : min;
}

expr abs(expr[] list, Env env){
	return (list[0].val > 0)? list[0] : mul([list[0], new expr(-1)], env);
}

expr quotient(expr[] list, Env env){
	return new expr(list[0].val / list[1].val);
}
expr remainder(expr[] list, Env env){
	return modulo(list, env);
}
expr modulo(expr[] list, Env env){
	return new expr(list[0].val % list[1].val);
}

