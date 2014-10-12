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
	
	bool atomic(){
		return val.type == typeid(bool) || 
			   val.type == typeid(long) || 
			   val.type == typeid(float) ||
			   val.type == typeid(symbol);
	}

	
	override string toString()
	{
		if(atomic){	
			if(types) return to!string(val) ~ " (" ~ to!string(val.type)~")";
			else return to!string(val);
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
	while(!(file.eof() || (left == right && right != 0))){
		string s = file.readln();
		left += s.split("(").length;
		right += s.split(")").length;
		tokens ~= chomp(s).replace("("," ( ").replace(")"," ) ").split();
	}
	return tokens;
}

expr[] bubble(ref string[] tokens){
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
	if(tree.atomic)
		return tree;
	else {
		expr[] e = tree.val.get!(expr[]);
		expr op = e[0];
		expr function(expr[], Env) f = env.findFunction(op);
		if(f == null){
			throw new Exception("No such function: " ~ to!string(op.val));
		}
		expr[] args = e[1..$].dup;
		for(int i = 0; i < args.length; i++){
			if(!args[i].atomic){
				args[i] = eval(args[i], env);
			}
		}
		return f(args, env);
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

void main(string[] args)
{
	string fname = "";
	types = false;
	pretty = false;
	
  	getopt(
    	args,
    	"f", &fname,
		"types", &types,
		"pretty", &pretty);	
		
	Env env = new Env();
	do {
		string[] tokens;
		if(fname != ""){
			File file = File(fname, "r");
			tokens = tokenize(file);
			file.close();
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
			}
			continue;
		}
		expr tree = new expr(bubble(tokens));
		if(pretty){
			writeTree(tree);
			writeln("~~~~~~~~~~~~~");
		}
		try{
			expr e = eval(tree, env);
			writeln(e);
		} catch(Exception ex){
			writeln(ex);
		}

	} while (fname == "");
}
