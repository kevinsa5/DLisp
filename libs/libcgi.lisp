run stdlib.lisp

(define parameter-string (get-env "QUERY_STRING"))
(define parameter-list (split parameter-string "&"))

(define print-cgi-headers (lambda ()
	(group
	(println "Content-type: text/plain")
	(println ""))))

(define get-keys (lambda ()
	(group
	(define helper (lambda (lis)
		(if (= (length lis) 0) () 
			(join (list (car (split (car lis) "=")))
				  (helper (cdr lis))))))
	(helper parameter-list))))

(define get-values (lambda ()
	(group
	(define helper (lambda (lis)
		(if (= (length lis) 0) ()
			(join (list (car (cdr (split (car lis) "="))))
				  (helper (cdr lis))))))
	(helper parameter-list))))

(define cgi-keys (get-keys))
(define cgi-values (get-values))

(define get-value (lambda (key)
	(group
	(define helper (lambda (keys values)
		(cond ((= (length keys) 0) null)
			  ((= (car keys) key) (car values))
			  (#t (helper (cdr keys) (cdr values))))))
	(helper cgi-keys cgi-values))))
