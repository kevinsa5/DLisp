run ../libs/libstd.lisp
(println "Hello!")
(define name "Lisp")

(define greet (lambda () 
				(println (strcat "Hello, " 
								 (input "What's your name?") 
								 ". My name is " 
								 name 
								 "."))))

(greet)

(println "i : fib-r(i)")
(println "~~~~~~~~~~")

(define row (lambda (n) 
	(println (strcat (str n) " : " (str (fib-r n))))))

;(map row (sequence 1 10 1))
(suppress (map row (list 1 2 3)))

(define print'n'calc (lambda (n)
	(group
	(println "Here's a group of commands!")
	(println "This is the second one.")
	(define a 2)
	(println "The last one is returned:")
	(* a n))))

(print'n'calc 5)
