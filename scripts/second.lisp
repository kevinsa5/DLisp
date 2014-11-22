#!/usr/bin/lisp -f

run libs/libstd.lisp

; define a function and call it
(define func (lambda () (println "Hello!")))
(func)

; inside a group, redefine the function and call it
(group
	(define func (lambda () (println "World!")))
	(func)
	; inside a nested group, redefine the function and call it
	(group
		(define func (lambda () (println "Nested")))
		(func))
	(func))

; call the original
(func)
