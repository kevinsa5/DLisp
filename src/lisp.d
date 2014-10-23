// Written in the D programming language
import std.stdio;
import std.string;
import std.array;
import std.variant;
import std.conv;
import std.getopt;
import std.ascii;

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
string str(string s){
	return '"' ~ s ~ '"';
	//return s;
}
string str(symbol s){
	return s.name;
}

string strForm(Variant v){
	if(v.type == typeid(bool)) return str(v.get!(bool));
	if(v.type == typeid(long)) return str(v.get!(long));
	if(v.type == typeid(float)) return str(v.get!(float));
	if(v.type == typeid(string)) return str(v.get!(string));
	if(v.type == typeid(symbol)) return str(v.get!(symbol));
	if(v.type == typeid(expr[])) return (new expr(v)).toString();
	return "bug in strForm()";
}

class listexpr : expr
{
	this(expr[] e){
		super(e);
	}
	override bool atomic(){
		return true;
	}
}

class nullexpr : expr
{
	this(expr[] e){super(e);}
	override bool atomic(){
		return true;
	}
	override string toString(){
		return "nil";
	}
	override string toStringNoTypes(){
		return "nil";
	}
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
			   val.type == typeid(string) ||
			   val.type == typeid(symbol);
	}
	
	override string toString()
	{
		if(atomic && val.type != typeid(expr[])){	
			if(types)
				return strForm(val) ~ " (" ~ to!string(val.type)~")";
			else 
				return strForm(val);
		}
		string s = "";
		foreach(expr e; val.get!(expr[])){
			if(e !is null)
				s ~= e.toString() ~ " ";
			else
				s ~= "null ";
		}
		if(s.length != 0)
			return "(" ~ s[0..$-1] ~ ")";
		return "()";
	}
	
	string toStringNoTypes(){
		if(atomic){
			return strForm(val);
		}
		string s = "";
		foreach(expr e; val.get!(expr[])){
			s ~= e.toStringNoTypes() ~ " ";
		}
		if(s.length != 0)
			return "(" ~ s[0..$-1] ~ ")";
		return "()";
	}
}

expr parseValue(string token){
	if(token[0] == '"' && token[$-1] == '"'){
		Variant e = token[1..$-1];
		return new expr(e);
	}
	try{
		Variant e = to!long(token);
		return new expr(e);
	}catch(ConvException e){}
	
	try{
		Variant e = to!float(token);
		return new expr(e);
	}catch(ConvException e){}
	
	try{
		Variant e = to!bool(token);
		return new expr(e);
	}catch(ConvException e){}
	if(token == "nil") return new nullexpr(null);
	Variant e = new symbol(token);
	return new expr(e);
}

bool inStringLeft = false;
int countLeftParens(string s){
	return countParens(s, '(', inStringLeft);
}
bool inStringRight = false;
int countRightParens(string s){
	return countParens(s, ')', inStringRight);
}

int countParens(string s, char key, ref bool inString){
	int n = 0;
	foreach (char c; s){
		if(c == '"'){
			inString = !inString;
		}
		if(!inString && c == key) n++;
		if(c == ';' && !inString) return n;
	}
	return n;
}

string tokenFormat(string s){
	string ret = "";
	bool inString = false;
	for (int i = 0; i < s.length; i++){
		if(s[i] == '"'){
			inString = !inString;
			ret ~= '"';
		}
		else if(!inString && s[i] == '(') ret ~= " ( ";
		else if(!inString && s[i] == ')') ret ~= " ) ";
		else if(!inString && i<s.length-1 && s[i]=='#' && s[i+1]=='t'){
			ret~="true";
			i++;
		}
		else if(!inString && i<s.length-1 && s[i]=='#' && s[i+1]=='f'){
			ret~="false";
			i++;
		} else {
			ret ~= s[i];
		}
	}
	return ret;
}

string[] tokenSplit(string s){
	s = tokenFormat(chomp(s));
	if(s.length > 0 && s[0].isWhite()) s = s[1..$];
	string[] list;
	for(int i = 0; i < s.length; i++){
		if(s[i] == '"'){
			int start = i;
			i += 1;
			while(i < s.length && s[i] != '"'){ i++; }
			if(i == s.length){
				throw new Exception("Unterminated string");
			}
			list ~= s[start..i+1];
			s = s[i+2..$];
			i = -1;
			continue;
		}
		if(s[i] == ';' || s[i] == '#'){
			while(i < s.length && s[i] != '\n'){
				i++;
			}
			if(i == s.length) s = [];
			else s = s[i+1..$];
			i = -1;
			continue;
		}
		if(s[i].isWhite()){
			while(s[i].isWhite() && i < s.length-1 && s[i+1].isWhite())
				s = s[0..i] ~ s[i+1..$];
			if(s[0..i] != "")
				list ~= s[0..i];
			s = s[i+1..$];
			i = -1;
		}
	}
	if(s != "") list ~= s;
	return list;
}

string[] tokenize(File file){
	string total;
	int left = 0, right = 0;
	string[] tokens;
	while(!(file.eof()  || (file == stdin && left == right && right != 0))){
		string s = file.readln();
		if(s.length>3 && (s[0..3]=="set" || s[0..3]=="run") && left==right){
			tokens ~= s.split();
			if(file == stdin) return tokens;
			continue;
		}
		if(s == "\n" && file == stdin) return tokens;
		left += countLeftParens(s);
		right += countRightParens(s);
		total ~= s;
	}
	tokens ~= tokenSplit(total);
	foreach (int i, string s; tokens){
		tokens[i] = s.replace("\\n", "\n").replace("\\t", "\t");
	}
	//writeln(tokens);
	return tokens;
}

expr[] bubble(ref string[] tokens){
	if(tokens.length == 0) throw new Exception("bubble() received an empty token array");
	// eat the open paren
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
			tree ~= parseValue(t);
		}
	}
	// eat the close paren
	tokens.popFront();
	return tree;
}

expr eval(expr tree, Env env){
	if(tree is null) return new nullexpr(null);
	if(tree.atomic){
		if(tree.val.type == typeid(expr[]) && ((tree.val.get!(expr[])).length > 0) && tree.val.get!(expr[])[0].val.type != typeid(symbol))
			return tree;
		if(tree.val.type == typeid(symbol) && env.findFunction(tree.val.get!symbol) == null){
			return eval(env.find(tree.val.get!symbol), env);
		}
		return tree;
	} else {
		expr[] e = tree.val.get!(expr[]);
		if(e.length == 0) return new expr(cast(expr[]) []);
		if(e[0].toStringNoTypes() == "if"){
			expr exp = e[1];
			expr res = e[2];
			expr alt = e[3];
			if(eval(exp, env).val != false)
				return eval(res, env);
			return eval(alt, env);
		} else if(e[0].toStringNoTypes() == "cond"){
			for(int i = 1; i < e.length; i++){
				expr[] clause = e[i].val.get!(expr[]);
				if(eval(clause[0], env).val != false){
					return eval(clause[1], env);
				}
			}
			throw new Exception("cond had no true clauses");
			return null;
		} else if(e[0].toStringNoTypes() == "define"){
			env.addSymbol(e[1].val.get!symbol, eval(e[2],env));
			//return env.find(e[1].val.get!symbol);
			return null;
		} else if(e[0].toStringNoTypes() == "suppress"){
			eval(e[1], env);
			return null;
		} else if(e[0].toStringNoTypes() == "define-ref"){
			env.addSymbol(e[1].val.get!symbol, e[2]);
			return null;
		} else if(e[0].toStringNoTypes() == "set!"){
			return null;
		} else if(e[0].toStringNoTypes() == "defun"){
			return null;
		} else if(e[0].toStringNoTypes() == "lambda"){
			expr[] largnames = e[1].val.get!(expr[]);
			expr lbody = e[2];
			string lambdaname = "__lambda"~to!string(lambdaSerial++);
			env.addDelegate(lambdaname, delegate expr(expr[] args, Env env){
				Env newenv = new Env(env);
				if(largnames.length != args.length) 
					throw new Exception("Arity mismatch: lambda function accepts " ~ to!string(largnames.length) ~ " arguments, but was given " ~ to!string(args.length) ~ "\nParameter list:" ~ to!string(largnames) ~ "\nGiven parameters:" ~ to!string(args));
				foreach(int i, expr e; largnames){
					newenv.addSymbol(e.val.get!symbol, args[i]);
				}
				return eval(lbody, newenv);
			});
			return new expr(new symbol(lambdaname));
		} else if(e[0].toStringNoTypes()  == "group"){
			Env newenv = new Env(env);
			for(int i = 1; i < e.length-1; i++){
				eval(e[i], newenv);
			}
			return eval(e[$-1], newenv);
		} else if(e.length == 3 && e[0].toStringNoTypes() == "set"){
			if(e[1].toStringNoTypes()  == "types"){
				if(e[2].toStringNoTypes()  == "on") types = true;
				if(e[2].toStringNoTypes()  == "off") types = false;
			} else if(e[1].toStringNoTypes()  == "pretty"){
				if(e[2].toStringNoTypes()  == "on") pretty = true;
				if(e[2].toStringNoTypes()  == "off") pretty = false;
			} else if(e[1].toStringNoTypes()  == "trace"){
				if(e[2].toStringNoTypes()  == "on") trace = true;
				if(e[2].toStringNoTypes()  == "off") trace = false;
			} else {
				writeln("REPL option not found: ", e[1].toStringNoTypes());
			}
			return null;
		} else {
			expr op = eval(e[0], env);
			expr delegate(expr[], Env) f;
			try {
				f = env.findFunction(op.val.get!symbol);
			} catch(Exception e){
				throw new Exception(op.toString() ~ " is not a valid function");
			}
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
		writeln("    ".replicate(level), tree.toString());
	} else {
		foreach(e; tree.val.get!(expr[])){
			if(e.atomic){
				writeln("    ".replicate(level), e.toString);
			} else {
				writeTree(e, level + 1);
			} 
		}
	}
}

void handleException(Exception e){
	if(trace){
		writeln(e);
	} else {
		writeln(e.msg);
	}
}

string[] preprocess(File f){
	string[] tokens = tokenize(f);
	for (int i = 0; i < tokens.length; i++){
		if(tokens[i] == "run"){
			try {
				tokens =tokens[0..i] ~ preprocess(File(tokens[i+1])) ~ tokens[i+2..$];
				} catch(Exception e){
					handleException(e);
					return null;
				}
		}
	}
	return tokens;
}

bool types;
bool pretty;
bool trace;
long lambdaSerial;
long buildID = 93;

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
	
	if(fname == ""){
		writeln("DLisp beta, build ", buildID);
	}
		
	Env env = new Env();
	env.addBuiltins();
	lambdaSerial = 0;
	
	do {
		string[] tokens;
		if(fname != ""){
			try { 
				File file = File(fname, "r");
				tokens = preprocess(file);
				file.close(); 
			}
			catch(Exception ex){
				writeln("No such file: ", fname);
				return;
			}
		} else {
			write(": ");
			tokens = preprocess(stdin);
		}

		if(tokens.length == 0) continue;
		while(tokens.length != 0){
			expr tree = new expr(bubble(tokens));
			if(pretty){
				writeTree(tree);
				writeln("~".replicate(40));
			}
			try{
				expr e = eval(tree, env);
				//incredibly messy to avoid printing the results of 
				//functions that return null (eg print)
				if(e !is null && (typeid(e) != typeid(listexpr) || ((e.val.get!(expr[]).length == 0) || (e.val.get!(expr[]).length > 0 && e.val.get!(expr[])[0] !is null)))){
					writeln(e);
				}
			} catch(Exception ex){
				handleException(ex);
			}
		}

	} while (fname == "");
}
