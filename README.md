DLisp
=====

A simple Lisp interpreter written in the D programming language.
Last compiled on Debian x64 with DMD64 D Compiler v2.072.2 
See http://dlang.org and http://dlang.org/download.html


Example
-------

    kevin@onion-run:~$ git clone https://www.github.com/kevinsa5/DLisp
    Cloning into 'DLisp'...
    remote: Counting objects: 108, done.
    remote: Total 108 (delta 0), reused 0 (delta 0), pack-reused 108
    Receiving objects: 100% (108/108), 22.57 KiB | 0 bytes/s, done.
    Resolving deltas: 100% (49/49), done.
    Checking connectivity... done.
    kevin@onion-run:~$ DLisp/src/compile.sh
    [sudo] password for kevin: 
    0+1 records in
    0+1 records out
    49 bytes copied, 7.1709e-05 s, 683 kB/s
    created /usr/bin/lisp
    0+1 records in
    0+1 records out
    62 bytes copied, 7.2632e-05 s, 854 kB/s
    created /usr/bin/lisp-term
    kevin@onion-run:~$ DLisp/bin/unit 
    10 tests completed
    20 tests completed
    30 tests completed
    40 tests completed
    50 tests completed
    60 tests completed
    70 tests completed
    80 tests completed
    90 tests completed
    100 tests completed
    110 tests completed
    Passed 117 out of 117 unit tests.
    kevin@onion-run:~$ lisp-term 
    DLisp beta, build 183
    DMD version 2.70
    Root directory: /home/kevin/DLisp/src/../
    : (println "Hello, world!")
    Hello, world!
    : (map fib-r (sequence 1 10 1))
    (1 1 2 3 5 8 13 21 34 55)
    : (set types on)
    : (set pretty on)
    : (set trace on)
    set (lisp.symbol)
    trace (lisp.symbol)
    on (lisp.symbol)
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    : (list (* 2 4) (+ (/ 10 5) 2 3 4))
    list (lisp.symbol)
        * (lisp.symbol)
        2 (long)
        4 (long)
        + (lisp.symbol)
            / (lisp.symbol)
            10 (long)
            5 (long)
        2 (long)
        3 (long)
        4 (long)
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (8 (long) 11 (long))
    : 
