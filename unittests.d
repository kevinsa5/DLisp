// Written in the D programming language
import std.stdio;
import std.file;
import std.process;
import std.string;

pragma(msg, __VERSION__);

string fname = "/tmp/d-unittest";
int passed = 0;
int failed = 0;

string exec(string s){
	std.file.write(fname, s);
	return std.process.executeShell("./scheme --pretty=false -f "~fname).output;
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
	test("(+ 3 5)", "8 (long)");
	test("(+ 3.0 5)", "8 (float)");
	test("(+ 3 5.0)", "8 (float)");
	test("(+ 3.0 5.0)", "8 (float)");
	test("(* 3 5)", "15 (long)");
	test("(* 3 0)", "0 (long)");
	test("(+ (* 2 3) (+ 5 4) (* (+ 1 2) 3))", "24 (long)");
	test("(+ (* 2 3) (+ 5 4.0) (* (+ 1 2) 3))", "24 (float)");
	test("(- 5 3)","2 (long)");
	writeln("Passed ", passed, " of ", (passed+failed), " tests.");
}
