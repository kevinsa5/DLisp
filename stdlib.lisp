(define fib (lambda (n)
	(cond ((= n 0) 0)
		  ((= n 1) 1)
		  ((= n 2) 1)
		  (#t (+ (fib (- n 1)) (fib (- n 2)))))))

(define fac (lambda (n) (if (= n 1) n (* n (fac (- n 1))))))
