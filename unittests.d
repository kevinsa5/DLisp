// Written in the D programming language
import std.stdio;
import std.file;
import std.process;
import std.string;

pragma(msg, __VERSION__);

string fname = "/tmp/d-unittest";
int passed = 0;
int failed = 0;

bool types;

string exec(string s){
	std.file.write(fname, s);
	if(types)
	return std.process.executeShell("./scheme --types=true -f "~fname).output;
	else
	return std.process.executeShell("./scheme --types=false -f "~fname).output;
}

void test(string a, string b){
	string res = chomp(exec(a));
	if(res == b){
		passed++;
	} else {
		failed++;
		writeln("Failure: ", a, ". Expected: ", b, "; Got: ", res);
	}
}

void main(){
	types = true;
	test("(+ 3 5)", "8 (long)");
	test("(+ 3.0 5)", "8 (float)");
	test("(+ 3 5.0)", "8 (float)");
	test("(+ 3.0 5.0)", "8 (float)");
	test("(* 3 5)", "15 (long)");
	test("(* 3 0)", "0 (long)");
	test("(+ (* 2 3) (+ 5 4) (* (+ 1 2) 3))", "24 (long)");
	test("(+ (* 2 3) (+ 5 4.0) (* (+ 1 2) 3))", "24 (float)");
	test("(- 5 3)","2 (long)");
	test("(- 5 (+ 5 5) 5)", "-10 (long)");
	test("(- 10 5.0)", "5 (float)");
	test("(- 3)", "-3 (long)");
	test("(- 3 4 5)", "-6 (long)");
	test("(/ 10 5)", "2 (long)");
	test("(/ 10.0 3)", "3.33333 (float)");
	test("(/ 10)", "0 (long)");
	test("(/ 10.0)", "0.1 (float)");
	test("(/ 3.0 4 5)", "0.15 (float)");
	test("(list 1 2 3)", "(1 (long) 2 (long) 3 (long))");
	test("(list (+ 1 2) 5 (* 3 4))", "(3 (long) 5 (long) 12 (long))");
	test("(list 1.0 2 (list 3 4.0 (list 5.0 6) 7) 8)", "(1 (float) 2 (long) (3 (long) 4 (float) (5 (float) 6 (long)) 7 (long)) 8 (long))");
	
	types = false;
	
	test("(append (list 1 2 3) (list 4 5 6))", "(1 2 3 4 5 6)");
	test("(append (list 1 2) (list 3 4 (list 5 6)))", "(1 2 3 4 (5 6))");
	test("(length (list 1 2 3))", "3");
	test("(length (list ))", "0");
	test("(list-ref (list 9 8 7) 0)", "9");
	test("(list-ref (list 9 8 7) 1)", "8");
	test("(list-ref (list 9 8 7) 2)", "7");
	test("(> 1 0)", "true");
	test("(> 1 1)", "false");
	test("(> 1 2)", "false");
	test("(> 1 1.1)", "false");
	test("(> 1 0.9)", "true");
	test("(< 1 0)", "false");
	test("(< 0 1)", "true");
	test("(< 5 5)", "false");
	test("(>= 10 5)", "true");
	test("(>= 5 5)", "true");
	test("(>= 1 5)", "false");
	test("(<= 1 5)", "true");
	test("(<= 5 5)", "true");
	test("(<= 10 5)", "false");
	test("(zero? 0)", "true");
	test("(zero? 0.1)", "false");
	test("(zero? -1)", "false");
	test("(positive? 1)", "true");
	test("(positive? 0)", "false");
	test("(positive? -1)", "false");
	test("(negative? 1)", "false");
	test("(negative? 0)", "false");
	test("(negative? -1)", "true");
	test("(max -1 2 5 2 -6)", "5");
	test("(max -4 -3 -1)", "-1");
	test("(max 5 1 2)", "5");
	test("(max 2 1 5)", "5");
	test("(min 1 2 3)", "1");
	test("(min 3 2 1)", "1");
	test("(min -1 0 1)", "-1");
	test("(modulo 10 3)", "1");
	test("(modulo 2 5)", "2");
	test("(remainder 10 3)", "1");
	test("(remainder 2 5)", "2");
	test("(quotient 10 3)", "3");
	test("(quotient 5 10)", "0");
	
	writeln("Passed ", passed, " of ", (passed+failed), " tests.");
}
