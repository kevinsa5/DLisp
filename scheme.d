// Written in the D programming language
import std.stdio;
import std.string;
import std.array;
import std.variant;
import std.conv;
import std.getopt;

import env;


class expr
{
	Variant val;
	this(Variant v){
		val = v;
	}
	this(bool b){
		val = b;
	}
	this(string s){
		val = s;
	}
	this(long l){
		val = l;
	}
	this(float f){
		val = f;
	}
	this(expr[] e){
		val = e;
	}
	bool atomic(){
		return val.type != typeid(expr[]);
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
        return "(" ~ s[0..$-1] ~ ")";
    }
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
	string token = tokens[0];
	tokens = tokens[1..$];
	if(token == "("){
		expr[] tree;
		while(tokens[0] != ")"){
			expr e;
			expr[] l = bubble(tokens);
			if(l.length == 1 && l[0].atomic){
				e = l[0];
			} else {
				e = new expr(l);
			}
			tree ~= e;
		}
		tokens = tokens[1..$];
		return tree;
	} else {
		try{
			int e = to!int(token);
			return [new expr(e)];
		}catch(ConvException e){}
		try{
			float e = to!float(token);
			return [new expr(e)];
		}catch(ConvException e){}
		try{
			bool e = to!bool(token);
			return [new expr(e)];
		}catch(ConvException e){}
		return [new expr(token)];
	}
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

void main(string[] args)
{
	string fname = "";
	types = false;
	
  	getopt(
    	args,
    	"f", &fname,
		"types", &types);	
		
	Env env = new Env();
	do {
		string[] tokens;
		if(fname != ""){
			File file = File(fname, "r");
			tokens = tokenize(file);
			file.close();
		} else {
			write("> ");
			tokens = tokenize(stdin);
		}
		expr tree = new expr(bubble(tokens));
		/+
		if(pretty){
			writeln("Tree:");
			writeTree(tree);
			writeln();
		}
		+/
		try{
			expr e = eval(tree, env);
			writeln(e);
		} catch(VariantException ex){
			writeln("error");
		}

	} while (fname == "");
}
