module env;
// Written in the D programming language
import scheme;
import std.variant;
import std.stdio;

class Env
{
	private:
		Env outer;
		expr[string] dict;
		expr function(expr[])[string] funcDict;
	public:
		this(Env o = null){
			outer = o;
			addBuiltins();
		}
		void addSymbol(string name, expr val){
			dict[name] = val;
		}
		void addFunction(string name, expr function(expr[]) f){
			funcDict[name] = f;
		}
		expr function(expr[]) findFunction(expr op){
			if(op.val.get!(string) in funcDict){
				return funcDict[op.val.get!(string)];
			}
			return outer.findFunction(op);
		}
	private:
		void addBuiltins(){
			addFunction("+", &add);
			addFunction("*", &mul);
		}
}

expr add(expr[] list){
	if(list.length == 0) return new expr(0);
	expr e = add(list[1..$]);
	try {
		e.val += list[0].val.get!(long);
	} catch(VariantException ex){
		e.val += list[0].val.get!(float);
	}
	return e;
}
expr mul(expr[] list){
	if(list.length == 0) return new expr(1);
	expr e = mul(list[1..$]);
	try {
		e.val *= list[0].val.get!(long);
	} catch(VariantException ex){
		e.val *= list[0].val.get!(float);
	}
	return e;
}
