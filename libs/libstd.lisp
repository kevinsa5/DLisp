(define fib-r (lambda (n)
	(cond ((= n 0) 0)
		  ((= n 1) 1)
		  ((= n 2) 1)
		  (#t (+ (fib-r (- n 1)) (fib-r (- n 2)))))))

(define fac (lambda (n) (if (= n 0) 1 (* n (fac (- n 1))))))

(define println (lambda (n) (print (strcat (str n) "\n"))))

(define all (lambda (lis) 
	(cond ((= (length lis) 0)  #t)
		  ((car lis) (all (cdr lis)))
		  (#t #f))))

(define any (lambda (lis) 
	(cond ((= (length lis) 0)  #f)
		  ((car lis) #t)
		  (#t (any (cdr lis))))))

(define map (lambda (f lis)
	(if (= (length lis) 1) (list (f (car lis))) 
						   (join (list (f (car lis))) (map f (cdr lis))))))

(define sequence (lambda (start end delta)
	(cond ((and (positive? delta) (> start end)) ())
		  ((and (negative? delta) (< start end)) ())
		  (#t (join (list start) (sequence (+ start delta) end delta))))))

(define strindex (lambda (s key)
	(group
	(define len (strlen key))
	(define helper (lambda (s key start)
		(cond ((= (strlen s) 0) -1)
			  ((= (strlen s) (+ start len -1)) -1)
			  ((= (str-ref s start (+ start len)) key) start)
			  (#t (helper s key (+ start 1))))))
	(helper s key 0))))

(define split (lambda (s delim)
	(group
	(define i (strindex s delim))
	(cond ((= (strlen s) 0) ())
		  ((= i -1) (list s))
		  (#t (join (list (str-ref s 0 i))
		  			  (split (str-ref s (+ i (strlen delim)) (strlen s))
		  			  		 delim)))))))
