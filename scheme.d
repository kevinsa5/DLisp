// Written in the D programming language
import std.stdio;
import std.string;
import std.array;
import std.variant;
import std.conv;
import std.getopt;

import env;

class symbol
{
	string name; 
	this(string s){ name = s;}
	
	override string toString(){
		return name;
	}
}

string str(bool b){
	return b ? "#t" : "#f";
}
string str(long l){
	return to!string(l);
}
string str(float f){
	string s = to!string(f);
	return (s.indexOf(".") != -1) ? s : s ~ ".0";
}
string str(symbol s){
	return s.name;
}

string strForm(Variant v){
	if(v.type == typeid(bool)) return str(v.get!(bool));
	if(v.type == typeid(long)) return str(v.get!(long));
	if(v.type == typeid(float)) return str(v.get!(float));
	if(v.type == typeid(symbol)) return str(v.get!(symbol));
	return "bug in strForm()";
}
class expr
{
	Variant val;
	this(Variant v){
		val = v;
	}
	this(bool b){ val = b; }
	this(string s){ val = s; }
	this(long l){ val = l; }
	this(float f){ val = f; }
	this(expr[] e){ val = e; }
	this(symbol s){ val = s; }
	
	bool atomic(){
		return val.type == typeid(bool) || 
			   val.type == typeid(long) || 
			   val.type == typeid(float) ||
			   val.type == typeid(symbol);
	}

	
	override string toString()
	{
		if(atomic){	
			if(types) return strForm(val) ~ " (" ~ to!string(val.type)~")";
			else return strForm(val);
		}
		string s = "";
		foreach(expr e; val.get!(expr[])){
			s ~= e.toString() ~ " ";
		}
		if(s.length != 0)
			return "(" ~ s[0..$-1] ~ ")";
		return "()";
	}
}

Variant parseValue(string token){
	try{
		Variant e = to!long(token);
		return e;
	}catch(ConvException e){}
	
	try{
		Variant e = to!float(token);
		return e;
	}catch(ConvException e){}
	
	try{
		Variant e = to!bool(token);
		return e;
	}catch(ConvException e){}
	
	Variant e = new symbol(token);
	return e;
}

string[] tokenize(File file){
	string[] tokens;
	int left = 0, right = 0;
	while(!(file.eof()  || (file == stdin && left == right && right != 0))){
		string s = file.readln();
		left += s.split("(").length;
		right += s.split(")").length;
		tokens ~= chomp(s).replace("("," ( ").replace(")"," ) ").replace("#t","true").replace("#f", "false").split();
	}
	return tokens;
}

expr[] bubble(ref string[] tokens){
	if(tokens.length == 0) return cast(expr[]) [];
	//eat the open paren
	string token = tokens[0];
	tokens.popFront();
	expr[] tree;
	while(tokens[0] != ")"){
		expr e;
		if(tokens[0] == "("){
			expr[] l = bubble(tokens);
			tree ~= new expr(l);
		} else {
			string t = tokens[0];
			tokens.popFront();
			tree ~= new expr(parseValue(t));
		}
	}
	// eat the close paren
	tokens.popFront();
	return tree;
}

expr eval(expr tree, Env env){
	//writeTree(tree);
	if(tree.atomic){
		if(tree.val.type == typeid(symbol) && env.findFunction(tree.val.get!symbol) == null)
			return eval(env.find(tree.val.get!symbol), env);
		return tree;
	} else {
		expr[] e = tree.val.get!(expr[]);
		if(e.length == 0) return new expr(cast(expr[]) []);
		if(to!string(e[0]) == "if"){
			expr exp = e[1];
			expr res = e[2];
			expr alt = e[3];
			if(eval(exp, env).val != false)
				return eval(res, env);
			return eval(alt, env);
		} else if(to!string(e[0]) == "cond"){
			for(int i = 1; i < e.length; i++){
				expr[] clause = e[i].val.get!(expr[]);
				if(eval(clause[0], env).val != false){
					return eval(clause[1], env);
				}
			}
			throw new Exception("cond had no true clauses");
			return null;
		} else if(to!string(e[0]) == "define"){
			env.addSymbol(e[1].val.get!symbol, eval(e[2],env));
			//return env.find(e[1].val.get!symbol);
			return null;
		} else if(to!string(e[0]) == "define-ref"){
			env.addSymbol(e[1].val.get!symbol, e[2]);
			return null;
		} else if(to!string(e[0]) == "set!"){
			return null;
		} else if(to!string(e[0]) == "defun"){
			return null;
		} else if(to!string(e[0]) == "lambda"){
			expr[] largnames = e[1].val.get!(expr[]);
			expr lbody = e[2];
			string lambdaname = "__lambda"~to!string(lambdaSerial++);
			env.addDelegate(lambdaname, delegate expr(expr[] args, Env env){
				Env newenv = new Env(env);
				if(largnames.length != args.length) 
					throw new Exception("Arity mismatch: lambda function accepts " ~ to!string(largnames.length) ~ " arguments, but was given " ~ to!string(args.length));
				foreach(int i, expr e; largnames){
					newenv.addSymbol(e.val.get!symbol, args[i]);
				}
				return eval(lbody, newenv);
			});
			return new expr(new symbol(lambdaname));
		} else if(to!string(e[0])  == "begin"){
			return null;
		} else {
			expr op = eval(e[0], env);
			expr delegate(expr[], Env) f =env.findFunction(op.val.get!symbol);
			if(f == null){
				throw new Exception("No such function: " ~ to!string(op.val));
			}
			expr[] args = e[1..$].dup;
			for(int i = 0; i < args.length; i++){
				if(!args[i].atomic || args[i].val.type == typeid(symbol)){
					args[i] = eval(args[i], env);
				}
			}
			return f(args, env);
		}
	}
}

void writeTree(expr tree, int level = 0){
	if(tree.atomic){
		writeln("\t".replicate(level), tree.toString());
	} else {
		foreach(e; tree.val.get!(expr[])){
			if(e.atomic){
				writeln("\t".replicate(level), e.toString);
			} else {
				writeTree(e, level + 1);
			} 
		}
	}
}

bool types;
bool pretty;
bool trace;
long lambdaSerial;

void main(string[] args)
{
	string fname = "";
	types = false;
	pretty = false;
	trace = false;
	
  	getopt(
    	args,
    	"f", &fname,
		"types", &types,
		"pretty", &pretty,
		"trace", &trace);	
		
	Env env = new Env();
	env.addBuiltins();
	lambdaSerial = 0;
	
	do {
		string[] tokens;
		if(fname != ""){
			try { 
				File file = File(fname, "r");
				tokens = tokenize(file);
				file.close(); 
			}
			catch(Exception ex){
				writeln("No such file: ", fname);
				return;
			}
		} else {
			write(": ");
			tokens = tokenize(stdin);
		}
		if(tokens.length == 0) continue;
		if(tokens[0] == "set"){
			if(tokens[1] == "types"){
				if(tokens[2] == "on") types = true;
				if(tokens[2] == "off") types = false;
			} else if(tokens[1] == "pretty"){
				if(tokens[2] == "on") pretty = true;
				if(tokens[2] == "off") pretty = false;
			} else if(tokens[1] == "trace"){
				if(tokens[2] == "on") trace = true;
				if(tokens[2] == "off") trace = false;
			} else {
				writeln("REPL option not found: ", tokens[1]);
			}
			continue;
		}
		if(tokens[0] == "run"){
			try {
				File file = File(tokens[1], "r");
				tokens = tokenize(file);
				file.close();
				while(tokens.length != 0){
					expr tree = new expr(bubble(tokens));
					try {
						expr e = eval(tree, env);
						if(e !is null) writeln(e);
					} catch(Exception ex){
						if(trace){
							writeln(ex);
						} else {
							writeln(ex.msg);
						}
					}
				}
			} catch(Exception e){
				writeln("No such file: ", tokens[1]);
			}
			continue;
		}
		while(tokens.length != 0){
			expr tree = new expr(bubble(tokens));
			if(pretty){
				writeTree(tree);
				writeln("~".replicate(40));
			}
			try{
				expr e = eval(tree, env);
				if(e !is null) writeln(e);
			} catch(Exception ex){
				if(trace){
					writeln(ex);
				} else {
					writeln(ex.msg);
				}
			}
			}

	} while (fname == "");
}
