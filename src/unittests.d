// Written in the D programming language
import std.stdio;
import std.file;
import std.process;
import std.string;

//pragma(msg, __VERSION__);

string fname = "/tmp/d-unittest";
string libstd = "run /home/kevin/DLisp/libs/libstd.lisp\n";
int pass = 0;
int fail = 0;

bool types;

string exec(string s){
	std.file.write(fname, s);
	if(types)
		return std.process.executeShell("lisp --types=true --std -f "~fname).output;
	else
		return std.process.executeShell("lisp --types=false --std -f "~fname).output;
}

void test(string a, string b){
	string res = chomp(exec(a));
	if(res == b){
		pass++;
	} else {
		fail++;
		writeln("Failure: ", a, ". Expected: ", b, "; Got: ", res);
	}
}

void main(){
	types = true;
	
	test("(+ 3 5)", "8 (long)");
	test("(+ 3.0 5)", "8.0 (float)");
	test("(+ 3 5.0)", "8.0 (float)");
	test("(+ 3.0 5.0)", "8.0 (float)");
	test("(* 3 5)", "15 (long)");
	test("(* 3 0)", "0 (long)");
	test("(+ (* 2 3) (+ 5 4) (* (+ 1 2) 3))", "24 (long)");
	test("(+ (* 2 3) (+ 5 4.0) (* (+ 1 2) 3))", "24.0 (float)");
	test("(- 5 3)","2 (long)");
	test("(- 5 (+ 5 5) 5)", "-10 (long)");
	test("(- 10 5.0)", "5.0 (float)");
	test("(- 3)", "-3 (long)");
	test("(- 3 4 5)", "-6 (long)");
	test("(/ 10 5)", "2 (long)");
	test("(/ 10.0 3)", "3.33333 (float)");
	test("(/ 10)", "0 (long)");
	test("(/ 10.0)", "0.1 (float)");
	test("(/ 3.0 4 5)", "0.15 (float)");
	test("(list 1 2 3)", "(1 (long) 2 (long) 3 (long))");
	test("(list (+ 1 2) 5 (* 3 4))", "(3 (long) 5 (long) 12 (long))");
	test("(list 1.0 2 (list 3 4.0 (list 5.0 6) 7) 8)", "(1.0 (float) 2 (long) (3 (long) 4.0 (float) (5.0 (float) 6 (long)) 7 (long)) 8 (long))");
	
	types = false;
	
	test("(append (list 1 2 3) (list 4 5 6))", "(1 2 3 (4 5 6))");
	test("(append (list 1 2) (list 3 4 (list 5 6)))", "(1 2 (3 4 (5 6)))");
	test("(append () (list 4 5 6))", "((4 5 6))");
	test("(length (list 1 2 3))", "3");
	test("(length (list ))", "0");
	test("(list-ref (list 9 8 7) 0)", "9");
	test("(list-ref (list 9 8 7) 1)", "8");
	test("(list-ref (list 9 8 7) 2)", "7");
	test("(> 1 0)", "#t");
	test("(> 1 1)", "#f");
	test("(> 1 2)", "#f");
	test("(> 1 1.1)", "#f");
	test("(> 1 0.9)", "#t");
	test("(< 1 0)", "#f");
	test("(< 0 1)", "#t");
	test("(< 5 5)", "#f");
	test("(>= 10 5)", "#t");
	test("(>= 5 5)", "#t");
	test("(>= 1 5)", "#f");
	test("(<= 1 5)", "#t");
	test("(<= 5 5)", "#t");
	test("(<= 10 5)", "#f");
	test("(= 1 1)", "#t");
	test("(= 1 1.0)", "#t");
	test("(= 1 2)", "#f");
	test("(zero? 0)", "#t");
	test("(zero? 0.1)", "#f");
	test("(zero? -1)", "#f");
	test("(positive? 1)", "#t");
	test("(positive? 0)", "#f");
	test("(positive? -1)", "#f");
	test("(negative? 1)", "#f");
	test("(negative? 0)", "#f");
	test("(negative? -1)", "#t");
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
	test("(if #t 2 3)", "2");
	test("(if #f 2 3)", "3");
	test("(if (> 2 1) 5 6)", "5");
	test("(if (zero? 0) -1 -4)", "-1");
	test("(if (< (max 1 2 3) (min 1 2 3)) -1.1 1.1)", "1.1");
	test("(if (or (positive? 1) (negative? 1)) #t #f)", "#t");
	test("(if (or (positive? 0) (negative? 0)) #t #f)", "#f");
	test("(if (and #t #f) 0 1)", "1");
	test("((if #t + *) 3 5)", "8");
	test("((if (> 1 0) and or) #t #f)", "#f");
	test("((if (< 1 0) and or) #t #f)", "#t");
	test("()", "()");
	test("(print 5)", "5");
	test("(print (list 1 2 3))", "(1 2 3)");
	test("(print (list 1 2) (list 3 4) (if #t 1 0))", "(1 2) (3 4) 1");
	test("(str 5)", "\"5\"");
	test("(str 5.0)", "\"5.0\"");
	test("(str \"asd\")", "\"asd\"");
	test("(str (list 1 2 3))", "\"(1 2 3)\"");
	test("(strcat \"123\" \"456\")", "\"123456\"");
	test("(strcat (str 123) (str 456))", "\"123456\"");
	test("(join (list 1 2 3) (list 4 5 6))", "(1 2 3 4 5 6)");
	test("(join () (list 4 5 6))", "(4 5 6)");
	test("(join () ())", "()");
	
	
	test("(strindex \"12345\" \"3\")", "2");
	test("(strindex \"12345\" \"6\")", "-1");
	test("(split \"A=B&C=D&E=F&G=H\" \"&\")", "(\"A=B\" \"C=D\" \"E=F\" \"G=H\")");
	test("(sequence 1 10 1)", "(1 2 3 4 5 6 7 8 9 10)");
	test("(sequence 5 0 -1)", "(5 4 3 2 1 0)");
	test("(sequence 1 10 2)", "(1 3 5 7 9)");
	test("(sequence 5 10 1.5)", "(5 6.5 8.0 9.5)");
	test("(any (list #f #f #f))", "#f");
	test("(any (list ))", "#f");
	test("(any (list #t #f #f))", "#t");
	test("(any (list #f #t #f))", "#t");
	test("(any (list #f #f #t))", "#t");
	test("(all (list #t #t #t))", "#t");
	test("(all (list #f #t #t))", "#f");
	test("(all (list #t #f #t))", "#f");
	test("(all (list #t #t #f))", "#f");
	test("(all (list ))", "#t");
	
	test("(cond ( (> 3 2) 5)
	            ( (< 3 2) 6)
	            ( #t 7))", "5");
	test("(cond ( (< 3 2) 5)
           		( (> 3 2) 6)
            	( #t 7))", "6");
	test("(cond ( (> 0 2) 5)
           		( (> 0 5) 6)
            	( #t 7))", "7");
	            
	test(
"(define i 0)
(println i)
(define i (+ i 1))
(println i)
(define i (+ i 3))
(define i (* i i))
(println i)
(println (fib-r i))",
"0
1
16
987");

test(
"(define a 1)
(println a)
;(define a 2)
(println a)
(define a 3);(define a 4)
(println a)",
"1
1
3");

test(
"(cond ((= 1 0) 1)
; here's a comment
       ((= 1 1) 2))","2");

test(
"(cond ((< 1 0) 1)
; (#t 2)
(#t 3))", "3");

test(
"(map zero? (list -2 -1 0 1 2))","(#f #f #t #f #f)");

	writeln("Passed ",pass," out of ",pass+fail," unit tests.");
}
