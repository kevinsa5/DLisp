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
}



string[] tokenize(string fname){
	File file = File(fname, "r");
	string[] tokens;

	while(!file.eof()){
		string s = file.readln();
		tokens ~= chomp(s).replace("("," ( ").replace(")"," ) ").split();
	}
	file.close();
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
		e = e[1..$];
		for(int i = 0; i < e.length; i++){
			if(!e[i].atomic)
				e[i] = eval(e[i], env);
		}
		return env.findFunction(op)(e);
	}
}

void writeTree(expr tree, int level = 0){
	if(tree.atomic){
		writeln("\t".replicate(level), tree.val," (", tree.val.type,")");
	} else {
		foreach(e; tree.val.get!(expr[])){
			if(e.atomic){
				writeln("\t".replicate(level), e.val," (",e.val.type,")");
			} else{
				writeTree(e, level + 1);
			} 
		}
	}
}

void main(string[] args)
{
	string fname = "";
	bool pretty = true;
	
  	getopt(
    	args,
    	"f", &fname,
		"pretty", &pretty);	
	
	if(fname == ""){
		writeln("must pass a lisp file to parse (-f file.scm)");
		return;
	}
	
	Env env = new Env();
	string[] tokens = tokenize(fname);
	expr tree = new expr(bubble(tokens));
	
	if(pretty){
		writeln("Tree:");
		writeTree(tree);
		writeln();
		writeln("eval'd:");
	}
	expr e = eval(tree, env);
	writeTree(e);
}
