(define fib (lambda (n)
	(cond ((= n 0) 0)
		  ((= n 1) 1)
		  ((= n 2) 1)
		  (#t (+ (fib (- n 1)) (fib (- n 2)))))))

(define fac (lambda (n) (if (= n 0) 1 (* n (fac (- n 1))))))

(define println (lambda (n) (print (append (str n) "\n"))))
