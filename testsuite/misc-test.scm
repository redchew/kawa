(test-init "Miscellaneous" 66)

;;; DSSSL spec example 11
(test '(3 4 5 6) (lambda x x) 3 4 5 6)
(test '(5 6) (lambda (x y #!rest z) z) 3 4 5 6)
(test '(3 4 5 i: 6 j: 1)
      (lambda ( x y #!optional z #!rest r #!key i (j 1))
	(list x y z i: i j: j))
      3 4 5 i: 6 i: 7)

(test #t keyword? foo:)
(test #t keyword? 'foo:)
(test #f keyword? 'foo\:)

;;; DSSSL spec example 44
(test "Argentina" keyword->string \Argentina:)

;;; DSSSL spec example 45
(test foobar: string->keyword "foobar")

(define-unit ft 12in)
(test 18in + 6in 1ft)

;;; This caused a spurious warning in earlier releases.
(test '(1 2 3) 'let (let ((x (lambda l l))) (x 1 2 3)))

;;; test old reader bugs 
(test '(b) cdr '(a .(b))) 
(test "foo" cdr '(a ."foo")) 
(test 'a car '(a #||#)) 

(define (try-vector-ref vec index)
  (try-catch (vector-ref vec index)
	     (ex <java.lang.IndexOutOfBoundsException>
		 "Bad array index")))

(test 3 try-vector-ref #(1 2 3) 2)
(test "Bad array index" try-vector-ref #(1 2 3) 10)

(define (test-catch)
  (let* ((x 0)
	 (y (catch 'key
		   (lambda ()
		     (set! x 2)
		     (throw 'key 10)
		     (set! x 1000))
		   (lambda (key arg)
		     (set! x (* x arg))
		     (+ x 10)))))
    (list x y)))

(test '(20 30) test-catch)

(section "new-line handling")
;;; Test that #\return and #\newline are read robustly.

(define cr-test-string "a \"bRLc\" dRklLXY")
(do ((i 0 (+ i 1)))
    ((= i (string-length cr-test-string)) #t)
  (if (char=? #\R (string-ref cr-test-string i))
      (string-set! cr-test-string i #\Return))
  (if (char=? #\L (string-ref cr-test-string i))
      (string-set! cr-test-string i #\Linefeed)))
(call-with-input-string
 cr-test-string
 (lambda (iport)
   (test 1 input-port-column-number iport)
   (test 1 input-port-line-number iport)
   (test 'a read iport)
   (test "b\nc" read iport)
   (test 'd read iport)
   (test 'kl read iport)
   (test 'XY read iport)
   (test #!eof read iport)))

(call-with-input-string
 cr-test-string
 (lambda (iport)
   (test #\a read-char iport)
   (test #\Space read-char iport)
   (test #\" read-char iport)
   (test #\b read-char iport)
   (test #\Return peek-char iport)
   (test 5 input-port-column-number iport)
   (test 1 input-port-line-number iport)
   (test #\Return read-char iport)
   (test #\Linefeed read-char iport)
   (test #\c read-char iport)
   (test #\" read-char iport)
   (test #\Space read-char iport)
   (test #\d read-char iport)
   (test #\Return read-char iport)
   (test 3 input-port-line-number iport)
   (test 1 input-port-column-number iport)
   (test #\k read-char iport)
   (test #\l read-char iport)
   (test #\Linefeed read-char iport)
   (test #\X read-char iport)
   (test #\Y read-char iport)
   (test #!eof read-char iport)))

;;; From: Hallvard Traetteberg <Hallvard.Traetteberg@idi.ntnu.no>
;;; Triggered bug with try-finally nested in an expression.

(define (quote-keyword-values list)
  (if (null? list)
  list
  `(,(car list) ',(car (cdr list))
  . ,(quote-keyword-values (cdr (cdr list)))))
  )

(defmacro with-content (object-form . content)
  (let ((var-symbol (string->symbol (string-append "context-"
(symbol->string (car object-form)))))
    (object-form `(,(car object-form)
         . ,(quote-keyword-values (cdr object-form)))))
  `(fluid-let ((,var-symbol ,object-form))
   (let ((content (list . ,content)))
         (cons ,var-symbol content)))
  ))

(define (document) (list 'document))
(define (view #!key type)
  (list 'view type: type))

(test '((view type: text)) 'with-content
      (with-content (view type: text)))
(test '((document) ((view type: diagram)) ((view type: text))) 'with-content
      (with-content (document) (with-content (view type: diagram))
		    (with-content (view type: text))))

(test '("X" . "X:abc") 'synchronized
      (let* ((x "X")
	     (y "abc")
	     (z	(synchronized y
			      (set! y (string-append x ":" y))
			      (cons x y))))
	z))

(define *xx* 3)
(define (fluid-test *xx*)
  (fluid-let ((*xx* *xx*))
    (set! *xx* (+ 100 (twice-*xx*)))
    (set! *xx* (let ((*xx* *xx*))
		 (+ 100 *xx*)))
    *xx*))
(define (twice-*xx*) (* 2 *xx*))
(test '(220 . 3) 'fluid-test (let ((res (fluid-test 10))) (cons res *xx*)))

(section "closures")

(define (f1 a)
  (define (f2 b)
    (cons a b))
  (cons a f2))
(define f1-100 (f1 100))
(define f2-20 ((cdr f1-100) 20))
(test 100 'closure-f2-car (car f2-20))
(test 20 'closure-f2-cdr (cdr f2-20))

;; Here f4 should be optimized away.
(define (f3 a)
  (define (f4 b)
    (cons a b))
  (define (f5 c)
    (cons a c))
  (cons a f5))
(define f3-10 (f3 10))
(define f4-20 ((cdr f3-10) 20))
(test '(10 . 20) 'closure-f4-20 f4-20)

(define (f30 a)
  (define (f31 b)
    (cons a b))
  (define (f32 c)
    (cons a c))
  (list a f31 f32))
(define f30-10 (f30 10))
(define f31-20 ((cadr f30-10) 20))
(define f32-33 ((caddr f30-10) 33))
(test '(10 . 20) 'closure-f31-20 f31-20)
(test '(10 . 33) 'closure-f32-33 f32-33)

(define (f6 a)
  (define (f7 b)
    (define (f8 c)
      (define (f9 d)
        (list a b c d))
      (list a b c f9))
    (list a b f8))
  (list a f7))
(define f6-100 (f6 100))
(define f7-20 ((cadr f6-100) 20))
(define f8-10 ((caddr f7-20) 10))
(test '(100 20 10 2) 'closure-test3 ((cadddr f8-10) 2))

(define (f6 a)
  (define (x6 b) a)
  (define (f7 b)
    (define (x7 c) b)
    (define (f8 c)
      (define (x8 d) c)
      (define (f9 d)
        (list a b c d))
      (list a b c f9))
    (list a b f8))
  (list a f7))
(define f6-100 (f6 100)) 
(define f7-20 ((cadr f6-100) 20)) 
(define f8-10 ((caddr f7-20) 10)) 
(test '(100 20 10 2) 'closure-test4 ((cadddr f8-10) 2)) 

;; A bug reported by Edward Mandac <ed@texar.com>.
(test "Done" 'do-future (do   ((test 'empty))
			  (#t "Done")
			(future (begin(set! test 'goodbye)))))

(define p1 (cons 9 45))
(define-alias p2 p1)
(define-alias p2car (car p2))
(set! p2car 40)
(test '(40 . 45) 'test-alias-1 p1)
(define p1-cdr-loc (location (cdr p1)))
(set! (p1-cdr-loc) 50)
(set! (car p2) 49)
(test '(49 . 50) 'test-alias-2 p2)
(test '(49 . 50) 'test-alias-3 ((location p1)))

(define (test-alias-4 x y)
  (define-alias xcar (car x))
  (define-alias yy y)
  (set! yy (+ yy xcar))
  (set! xcar yy)
  (list yy xcar x y))
(test '(59 59 (59 . 50) 59) test-alias-4 p1 10)

(define test-nesting-1
  (lambda ()
    ((lambda (bar)
       (letrec
	   ((foo 
	     (lambda (bar1) (foo bar))))
	 33))
   100)))
(test 33 test-nesting-1)

(define (test-nesting-2)
  ((lambda (bar1)
     (lambda ()
       (lambda ()
         bar1)))
   #t)
  (let ((bar2 34))
    (lambda () (lambda () bar2))))
(test 34 ((test-nesting-2)))

(define (test-duplicate-names)
  (let ((bar #t)) (lambda () (lambda () bar)))
  (let ((bar #t)) (lambda () (lambda () bar)))
  (let ((bar #t)) (lambda () (lambda () bar)))
  97)
(test 97 test-duplicate-names)

(define (test-location-local x)
  (let* ((xl (location x))  ;; test location of formal parameter x
	 (z (xl))
	 (zl (location z))) ;; test location of local variable z
    (set! (xl) (+ (zl) 100))
    x))
(test 110 test-location-local 10)
