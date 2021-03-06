;; -*- coding: utf-8 -*-
(test-begin "arrays" 244)

;;; array test
;;; 2001 Jussi Piitulainen
;;; 2002 Per Bothner modified to fit Kawa testing framework.
;;; 2006 Per Bothner modified to fit SRFI-64 testing framework.

;;; Simple tests

(test-equal "shape" #t
      (and (array? (shape))
	   (array? (shape -1 -1))
	   (array? (shape -1 0))
	   (array? (shape -1 1))
	   (array? (shape 1 2 3 4 5 6 7 8 1 2 3 4 5 6 7 8 1 2 3 4 5 6 7 8))))

(test-equal "make-array" #t
      (and (array? (make-array (shape)))
	   (array? (make-array (shape) *))
	   (array? (make-array (shape -1 -1)))
	   (array? (make-array (shape -1 -1) *))
	   (array? (make-array (shape -1 1)))
	   (array? (make-array (shape 1 2 3 4 5 6 7 8 1 2 3 4 5 6 7 8 1 2 3 4) *))))

(test-equal "array" #t
      (and (array? (array (shape) *))
	   (array? (array (shape -1 -1)))
	   (array? (array (shape -1 1) * *))
	   (array? (array (shape 1 2 3 4 5 6 7 8 1 2 3 4 5 6 7 8) *))))

(test-equal 2 (array-rank (shape)))
(test-equal 2 (array-rank (shape -1 -1)))
(test-equal 2 (array-rank (shape -1 1)))
(test-equal 2 (array-rank (shape 1 2 3 4 5 6 7 8)))

(test-equal 0 (array-rank (make-array (shape))))
(test-equal 1 (array-rank (make-array (shape -1 -1))))
(test-equal 1 (array-rank (make-array (shape -1 1))))
(test-equal 4 (array-rank (make-array (shape 1 2 3 4 5 6 7 8))))

(test-equal 0 (array-rank (array (shape) *)))
(test-equal 1 (array-rank (array (shape -1 -1))))
(test-equal 1 (array-rank (array (shape -1 1) * *)))
(test-equal 4 (array-rank (array (shape 1 2 3 4 5 6 7 8) *)))

(test-equal 0 (array-start (shape -1 -1) 0))
(test-equal 0 (array-start (shape -1 -1) 1))
(test-equal 0 (array-start (shape -1 1) 0))
(test-equal 0 (array-start (shape -1 1) 1))
(test-equal 0 (array-start (shape 1 2 3 4 5 6 7 8) 0))
(test-equal 0 (array-start (shape 1 2 3 4 5 6 7 8) 1))

(test-equal 1 (array-end (shape -1 -1) 0))
(test-equal 2 (array-end (shape -1 -1) 1))
(test-equal 1 (array-end (shape -1 1) 0))
(test-equal 2 (array-end (shape -1 1) 1))
(test-equal 4 (array-end (shape 1 2 3 4 5 6 7 8) 0))
(test-equal 2 (array-end (shape 1 2 3 4 5 6 7 8) 1))

(test-equal -1 (array-start (make-array (shape -1 -1)) 0))
(test-equal -1 (array-start (make-array (shape -1 1)) 0))
(test-equal 1 (array-start (make-array (shape 1 2 3 4 5 6 7 8)) 0))
(test-equal 3 (array-start (make-array (shape 1 2 3 4 5 6 7 8)) 1))
(test-equal 5 (array-start (make-array (shape 1 2 3 4 5 6 7 8)) 2))
(test-equal 7 (array-start (make-array (shape 1 2 3 4 5 6 7 8)) 3))

(test-equal -1 (array-end (make-array (shape -1 -1)) 0))
(test-equal 1 (array-end (make-array (shape -1 1)) 0))
(test-equal 2 (array-end (make-array (shape 1 2 3 4 5 6 7 8)) 0))
(test-equal 4 (array-end (make-array (shape 1 2 3 4 5 6 7 8)) 1))
(test-equal 6 (array-end (make-array (shape 1 2 3 4 5 6 7 8)) 2))
(test-equal 8 (array-end (make-array (shape 1 2 3 4 5 6 7 8)) 3))

;; array-start of array
(test-equal -1 (array-start (array (shape -1 -1)) 0))
(test-equal -1 (array-start (array (shape -1 1) * *) 0))
(test-equal 1 (array-start (array (shape 1 2 3 4 5 6 7 8) *) 0))
(test-equal 3 (array-start (array (shape 1 2 3 4 5 6 7 8) *) 1))
(test-equal 5 (array-start (array (shape 1 2 3 4 5 6 7 8) *) 2))
(test-equal 7 (array-start (array (shape 1 2 3 4 5 6 7 8) *) 3))

;; array-end of array
(test-equal -1 (array-end (array (shape -1 -1)) 0))
(test-equal 1 (array-end (array (shape -1 1) * *) 0))
(test-equal 2 (array-end (array (shape 1 2 3 4 5 6 7 8) *) 0))
(test-equal 4 (array-end (array (shape 1 2 3 4 5 6 7 8) *) 1))
(test-equal 6 (array-end (array (shape 1 2 3 4 5 6 7 8) *) 2))
(test-equal 8 (array-end (array (shape 1 2 3 4 5 6 7 8) *) 3))

;; array-ref of make-array with arguments
(test-equal 'a (array-ref (make-array (shape) 'a)))
(test-equal 'b (array-ref (make-array (shape -1 1) 'b) -1))
(test-equal 'c (array-ref (make-array (shape -1 1) 'c) 0))
(test-equal 'd (array-ref (make-array (shape 1 2 3 4 5 6 7 8) 'd) 1 3 5 7))

;; array-ref of make-array with vector
(test-equal 'a (array-ref (make-array (shape) 'a) '#()))
(test-equal 'b (array-ref (make-array (shape -1 1) 'b) '#(-1)))
(test-equal 'c (array-ref (make-array (shape -1 1) 'c) '#(0)))
(test-equal 'd (array-ref (make-array (shape 1 2 3 4 5 6 7 8) 'd) '#(1 3 5 7)))

;; array-ref of make-array with array
(test-equal 'a (array-ref (make-array (shape) 'a) (array (shape 0 0))))
(test-equal 'b (array-ref (make-array (shape -1 1) 'b) (array (shape 0 1) -1)))
(test-equal 'c (array-ref (make-array (shape -1 1) 'c) (array (shape 0 1) 0)))
(test-equal 'd (array-ref (make-array (shape 1 2 3 4 5 6 7 8) 'd)
      (array (shape 0 4) 1 3 5 7)))

;; array-set! of make-array with arguments
(test-equal "set" 'a
      (let ((arr (make-array (shape) 'o)))
	(array-set! arr 'a)
	(array-ref arr)))
(let ((arr (make-array (shape -1 1) 'o)))
  (array-set! arr -1 'b)
  (array-set! arr 0 'c)
  (test-equal 'b (array-ref arr -1))
  (test-equal 'c (array-ref arr 0)))
(let ((arr (make-array (shape 1 2 3 4 5 6 7 8) 'o)))
  (array-set! arr 1 3 5 7 'd)
  (test-equal 'd (array-ref arr 1 3 5 7)))

;; array-set! of make-array with vector
(let ((arr (make-array (shape) 'o)))
  (array-set! arr '#() 'a)
  (test-equal 'a (array-ref arr)))
(let ((arr (make-array (shape -1 1) 'o)))
  (array-set! arr '#(-1) 'b)
  (array-set! arr '#(0) 'c)
  (test-equal 'b (array-ref arr -1))
  (test-equal 'c (array-ref arr 0)))
(let ((arr (make-array (shape 1 2 3 4 5 6 7 8) 'o)))
  (array-set! arr '#(1 3 5 7) 'd)
  (test-equal 'd (array-ref arr 1 3 5 7)))

;; array-set! of make-array with array
(let ((arr (make-array (shape) 'o)))
  (array-set! arr 'a)
  (test-equal 'a (array-ref arr)))
(let ((arr (make-array (shape -1 1) 'o)))
  (array-set! arr (array (shape 0 1) -1) 'b)
  (array-set! arr (array (shape 0 1) 0) 'c)
  (test-equal 'b (array-ref arr -1))
  (test-equal 'c (array-ref arr 0)))
(let ((arr (make-array (shape 1 2 3 4 5 6 7 8) 'o)))
  (array-set! arr (array (shape 0 4) 1 3 5 7) 'd)
  (test-equal 'd (array-ref arr 1 3 5 7)))

;;; Share and change:
;;;
;;;  org     brk     swp            box
;;;
;;;   0 1     1 2     5 6
;;; 6 a b   2 a b   3 d c   0 2 4 6 8: e
;;; 7 c d   3 e f   4 f e
;;; 8 e f

;; shared change
(let* ((org (array (shape 6 9 0 2) 'a 'b 'c 'd 'e 'f))
       (brk (share-array
	     org
	     (shape 2 4 1 3)
	     (lambda (r k)
	       (values
		(+ 6 (* 2 (- r 2)))
		(- k 1)))))
       (swp (share-array
	     org
	     (shape 3 5 5 7)
	     (lambda (r k)
	       (values
		(+ 7 (- r 3))
		(- 1 (- k 5))))))
       (box (share-array
	     swp
	     (shape 0 1 2 3 4 5 6 7 8 9)
	     (lambda _ (values 4 6))))
       (org-contents (lambda ()
		       (list (array-ref org 6 0) (array-ref org 6 1)
			     (array-ref org 7 0) (array-ref org 7 1)
			     (array-ref org 8 0) (array-ref org 8 1))))
       (brk-contents (lambda ()
		       (list (array-ref brk 2 1) (array-ref brk 2 2)
			     (array-ref brk 3 1) (array-ref brk 3 2))))
       (swp-contents (lambda ()
		       (list (array-ref swp 3 5) (array-ref swp 3 6)
			     (array-ref swp 4 5) (array-ref swp 4 6))))
       (box-contents (lambda ()
		       (list (array-ref box 0 2 4 6 8)))))
  (test-equal '(a b c d e f) (org-contents))
  (test-equal '(a b e f) (brk-contents))
  (test-equal '(d c f e) (swp-contents))
  (test-equal '(e) (box-contents))
  (array-set! org 6 0 'x)
  (test-equal '(x b c d e f) (org-contents))
  (test-equal '(x b e f) (brk-contents))
  (test-equal '(d c f e) (swp-contents))
  (test-equal '(e) (box-contents))
  (array-set! brk 3 1 'y)
  (test-equal '(x b c d y f) (org-contents))
  (test-equal '(x b y f) (brk-contents))
  (test-equal  '(d c f y) (swp-contents))
  (test-equal '(y) (box-contents))
  (array-set! swp 4 5 'z)
  (test-equal '(x b c d y z) (org-contents))
  (test-equal '(x b y z) (brk-contents))
  (test-equal '(d c z y) (swp-contents))
  (test-equal '(y) (box-contents))
  (array-set! box 0 2 4 6 8 'e)
  (test-equal '(x b c d e z) (org-contents))
  (test-equal '(x b e z) (brk-contents))
  (test-equal '(d c z e) (swp-contents))
  (test-equal '(e) (box-contents)))

;;; Check that arrays copy the shape specification

;; array-set! of shape
(let ((shp (shape 10 12)))
  (let ((arr (make-array shp))
	(ars (array shp * *))
	(art (share-array (make-array shp) shp (lambda (k) k))))
    (array-set! shp 0 0 '?)
    (array-set! shp 0 1 '!)
    (test-equal #2s32((10 12)) (array-shape arr))
    (test-equal 2 (array-rank shp))
    (test-equal 0 (array-start shp 0))
    (test-equal 1 (array-end shp 0))
    (test-equal 0 (array-start shp 1))
    (test-equal 2 (array-end shp 1))
    (test-equal '? (array-ref shp 0 0))
    (test-equal '! (array-ref shp 0 1))
    (test-equal 1 (array-rank arr))
    (test-equal 10 (array-start arr 0))
    (test-equal 12 (array-end arr 0))
    (test-equal 1 (array-rank ars))
    (test-equal 10 (array-start ars 0))
    (test-equal 12 (array-end ars 0))
    (test-equal 1 (array-rank art))
    (test-equal 10 (array-start art 0))
    (test-equal 12 (array-end art 0))))

;;; Check that index arrays work even when they share
;;;
;;; arr       ixn
;;;   5  6      0 1
;;; 4 nw ne   0 4 6
;;; 5 sw se   1 5 4

;; array access with sharing index array
(let ((arr (array (shape 4 6 5 7) 'nw 'ne 'sw 'se))
      (ixn (array (shape 0 2 0 2) 4 6 5 4)))
  (let ((col0 (share-array
	       ixn
	       (shape 0 2)
	       (lambda (k) (values k 0))))
	(row0 (share-array
	       ixn
	       (shape 0 2)
	       (lambda (k) (values 0 k))))
	(wor1 (share-array
	       ixn
	       (shape 0 2)
	       (lambda (k) (values 1 (- 1 k)))))
	(cod (share-array
	      ixn
	      (shape 0 2)
	      (lambda (k)
		(case k
		  ((0) (values 1 0))
		  ((1) (values 0 1))))))
	(box (share-array
	      ixn
	      (shape 0 2)
	      (lambda (k) (values 1 0)))))
    (test-equal 'nw (array-ref arr col0))
    (test-equal 'ne (array-ref arr row0))
    (test-equal 'nw (array-ref arr wor1))
    (test-equal 'se (array-ref arr cod))
    (test-equal 'sw (array-ref arr box))
    (array-set! arr col0 'ul)
    (array-set! arr row0 'ur)
    (array-set! arr cod 'lr)
    (array-set! arr box 'll)
    (test-equal 'ul (array-ref arr 4 5))
    (test-equal 'ur (array-ref arr 4 6))
    (test-equal 'll (array-ref arr 5 5))
    (test-equal 'lr (array-ref arr 5 6))
    (array-set! arr wor1 'xx)
    (test-equal 'xx (array-ref arr 4 5))))

;;; Check that shape arrays work even when they share
;;;
;;; arr             shp       shq       shr       shs
;;;    1  2  3  4      0  1      0  1      0  1      0  1 
;;; 1 10 12 16 20   0 10 12   0 12 20   0 10 10   0 12 12
;;; 2 10 11 12 13   1 10 11   1 11 13   1 11 12   1 12 12
;;;                                     2 12 16
;;;                                     3 13 20

;; sharing shape array
(let ((arr (array (shape 1 3 1 5) 10 12 16 20 10 11 12 13)))
  (let ((shp (share-array
	      arr
	      (shape 0 2 0 2)
	      (lambda (r k) (values (+ r 1) (+ k 1)))))
	(shq (share-array
	      arr
	      (shape 0 2 0 2)
	      (lambda (r k) (values (+ r 1) (* 2 (+ 1 k))))))
	(shr (share-array
	      arr
	      (shape 0 4 0 2)
	      (lambda (r k) (values (- 2 k) (+ r 1)))))
	(shs (share-array
	      arr
	      (shape 0 2 0 2)
	      (lambda (r k) (values 2 3)))))
    (let ((arr-p (make-array shp)))
      (test-equal  2 (array-rank arr-p))
      (test-equal 10 (array-start arr-p 0))
      (test-equal 12 (array-end arr-p 0))
      (test-equal 10 (array-start arr-p 1))
      (test-equal 11 (array-end arr-p 1)))
    (let ((arr-q (array shq * * * *  * * * *  * * * *  * * * *)))
      (test-equal 2 (array-rank arr-q))
      (test-equal 12 (array-start arr-q 0))
      (test-equal 20 (array-end arr-q 0))
      (test-equal 11 (array-start arr-q 1))
      (test-equal 13 (array-end arr-q 1)))
    (let ((arr-r (share-array
		  (array (shape) *)
		  shr
		  (lambda _ (values)))))
      (test-equal 4 (array-rank arr-r))
      (test-equal 10 (array-start arr-r 0))
      (test-equal 10 (array-end arr-r 0))
      (test-equal 11 (array-start arr-r 1))
      (test-equal 12 (array-end arr-r 1))
      (test-equal 12 (array-start arr-r 2))
      (test-equal 16 (array-end arr-r 2))
      (test-equal 13 (array-start arr-r 3))
      (test-equal 20 (array-end arr-r 3)))
    (let ((arr-s (make-array shs)))
      (test-equal 2 (array-rank arr-s))
      (test-equal 12 (array-start arr-s 0))
      (test-equal 12 (array-end arr-s 0))
      (test-equal 12 (array-start arr-s 1))
      (test-equal 12 (array-end arr-s 1)))
    (let ((arr-s (make-array shs)))
      (test-equal 2 (array-rank arr-s))
      (test-equal 12 (array-start arr-s 0))
      (test-equal 12 (array-end arr-s 0))
      (test-equal 12 (array-start arr-s 1))
      (test-equal 12 (array-end arr-s 1)))))

;; sharing with sharing subshape
(let ((super (array (shape 4 7 4 7)
                    1 * *
                    * 2 *
                    * * 3))
      (subshape (share-array
                 (array (shape 0 2 0 3)
                        * 4 *
                        * 7 *)
                 (shape 0 1 0 2)
                 (lambda (r k)
                   (values k 1)))))
  (let ((sub (share-array super subshape (lambda (k) (values k k)))))
    ;(array-equal? subshape (shape 4 7))
    (test-equal 2 (array-rank subshape))
    (test-equal 0 (array-start subshape 0))
    (test-equal 1 (array-end subshape 0))
    (test-equal 0 (array-start subshape 1))
    (test-equal 2 (array-end subshape 1))
    (test-equal 4 (array-ref subshape 0 0))
    (test-equal 7 (array-ref subshape 0 1))
    ;(array-equal? sub (array (shape 4 7) 1 2 3))
    (test-equal 1 (array-rank sub))
    (test-equal 4 (array-start sub 0))
    (test-equal 7 (array-end sub 0))
    (test-equal 1 (array-ref sub 4))
    (test-equal 2 (array-ref sub 5))
    (test-equal 3 (array-ref sub 6))))

;; Bug reported by Chris Dean <ctdean@mercedsystems.com>

(define a-2-9 (make-array (shape 0 2 0 9)))
(array-set! a-2-9 1 3 'e)
(test-equal 'e (array-ref a-2-9 1 3))

;; Savannah [bug #4310] share-array edge case.  All these tests should
;; return ok without an error or IndexOutOfBoundsException
(define (make-simple-affine ndims hibound)
  (lambda (i)
    (if (> i hibound) 
        (error "index out of bounds" i hibound))
    (apply values (vector->list (make-vector ndims i)))))

(define four-dee-array (array (shape 0 2 0 2 0 2 0 2)
			      'a 'b 'c 'd 'e 'f 'g 'h
			      'i 'j 'k 'l 'm 'n 'o 'p))
(define four-dee-lil-array (make-array (shape 0 1 0 1 0 1 0 1) 'ok))

(test-equal 'ok
	    (array-ref
	     (share-array four-dee-lil-array (shape 0 1) (make-simple-affine 4 0))
	     0))
(test-equal 'a
	    (array-ref
	     (share-array four-dee-array (shape 0 1) (make-simple-affine 4 0))
	     0))
(test-equal 'a
	    (array-ref
	     (share-array four-dee-array (shape 0 2) (make-simple-affine 4 1))
	     0))
(test-equal
 '(a p)
 (map
  (lambda (i)
    (array-ref
     (share-array four-dee-array (shape 0 2) (make-simple-affine 4 1))
     i))
  '(0 1)))
(test-equal 'p
	    (array-ref
	     (share-array four-dee-array (shape 1 2) (make-simple-affine 4 1))
	     1))

;;; Kawa-specific tests

(let* ((arr (make-array (shape 0 2 1 5) @[100 <: 108]))
       (a1 (array-index-ref arr 1 [2 <: 5]))
       (a2 (array-index-share arr 1 [2 <=: 4]))
       (v1 (array->vector arr))
       (v2 (array-flatten arr)))
  (test-equal 8 (array-size arr))
  (test-equal #(105 106 107) (vector @a1))
  (test-equal #(105 106 107) a2)
  (test-equal #(100 101 102 103 104 105 106 107) v1)
  (test-equal #(100 101 102 103 104 105 106 107) v2)
  (set! (arr 1 3) 206)
  (test-equal #(105 106 107) a1)
  (test-equal #(105 206 107) a2)
  (test-error (set! (a1 0) 99))
  (test-equal 107 (arr 1 4))
  (set! (a2 2) 207)
  (test-equal #(100 101 102 103 104 105 206 207) v1)
  (test-equal #(100 101 102 103 104 105 106 107) v2)
  (test-equal #(105 106 107) a1)
  (test-equal #(105 206 207) a2)
  (test-equal 207 (arr 1 4))
)
;; Similar but use plain array (rather than range) for selection
(let* ((arr (make-array (shape 0 2 1 5) @[100 <: 108]))
       (a1 (array-index-ref arr 1 [2 3 4]))
       (a2 (array-index-share arr 1 [2 3 4])))
  (test-equal #(105 106 107) a1)
  (test-equal #(105 106 107) a2)
  (set! (arr 1 3) 206)
  (test-equal #(105 106 107) a1)
  (test-equal #(105 206 107) a2)
  (test-error (set! (a1 0) 99))
  (test-equal 107 (arr 1 4))
  (set! (a2 2) 207)
  (test-equal #(105 106 107) a1)
  (test-equal #(105 206 207) a2)
  (test-equal 207 (arr 1 4))
  (array-fill! a2 42)
  (test-equal #(100 101 102 103 104 42 42 42)
   (array-flatten arr)))

(test-equal #2a:2@1:3((9 8 7) (10 9 8))
            (build-array [2 [1 <: 4]]
                         (lambda (ind)
                           (let ((x (ind 0)) (y (ind 1)))
                             (+ 10 x (- y))))))

(define (make-sparse-array shape default-value)
  (let ((vals '()))
    (build-array shape
                 (lambda (I)
                   (let ((v (assoc I vals)))
                     (if v (cdr v)
                         default-value)))
                 (lambda (I newval)
                   (let ((v (assoc I vals)))
                     (if v
                         (set-cdr! v newval)
                         (set! vals (cons (cons I newval) vals))))))))

(define sarr (make-sparse-array [3 4] -1))
(array-set! sarr 1 1 10)
(array-set! sarr 2 3 23)
(array-set! sarr 1 1 11)
(test-equal #2a((-1 -1 -1 -1) (-1 11 -1 -1) (-1 -1 -1 23)) sarr)

(test-equal &{&-
#2a@10:2:3
║10│ 9│8║
╟──┼──┼─╢
║11│10│9║
╚══╧══╧═╝}
  (format-array
   (build-array [[10 <: 12] 3]
                (lambda (ind)
                  (let ((x (ind 0)) (y (ind 1)))
                    (- x y))))))

(test-equal &{&-
#2a:2:3═╗
║12│3│ 4║
╟──┼─┼──╢
║ 5│9│11║
╚══╧═╧══╝}
  (format-array #2a((12 3 4) (5 9 11)) #f))

(test-equal &{&-
#2a:2:4═╤═══╗
║ab│c│d │e  ║
╟──┼─┼──┼───╢
║f │g│hi│jkl║
╚══╧═╧══╧═══╝}
  (format-array #2a((ab c d e) (f g hi jkl))))

(test-equal &{&-
#2s8:2:3╤═══╗
║012│003│004║
╟───┼───┼───╢
║005│-09│011║
╚═══╧═══╧═══╝}
  (format-array #2S8((12 3 4) (5 -9 11)) "~3,'0d"))

(test-equal &{&-
#3a:2:2:3═╗
║ab│c  │d ║
╟──┼───┼──╢
║e │f  │gh║
╠══╪═══╪══╣
║i │j  │k ║
╟──┼───┼──╢
║lm│nop│q ║
╚══╧═══╧══╝}
  (format-array #3a(((ab c d) (e f gh)) ((i j k) (lm nop q)))))

(test-equal &{&-
#2a:2:3════╤═════════╗
║  334│4545│#2f32:1:2║
║     │    │║5.0│6.0║║
║     │    │╚═══╧═══╝║
╟─────┼────┼─────────╢
║78987│abc │#2a══╗   ║
║     │defg│║1│ 2║   ║
║     │hi  │╟─┼──╢   ║
║     │    │║3│14║   ║
║     │    │╚═╧══╝   ║
╚═════╧════╧═════════╝}
  (format-array
   #2a((334 4545 #2f32((5 6))) (78987 "abc\ndefg\nhi" #2A((1 2) (3 14))))))

(test-equal "#0a -02" (format-array #0a -2 #f "~3,'0d"))

(test-equal "#2a@1:3:0 ()"
            (format-array #2a@1:3:0()))

(let ((arr #2a@1:2:3((a -9 "c") (d 153 "ef"))))
  (test-equal "#2a@1:2:3((a -9 c) (d 153 ef))"
              (format "~a" arr))
  (test-equal #2s32((1 3) (0 3)) (array-shape arr)))

(test-equal #2s32((0 3) (2 5) (0 9) (-1 3))
            (->shape `#(3 (2 5) 9 ,[-1 size: 4])))

(test-equal &{#2a@1:2:3((a -9 "c") (d 153 "ef"))}
            (format "~w" #2a@1:2:3((a -9 "c") (d 153 "ef"))))

(test-equal [2 5] [2 by: 3 <: 8])
(test-equal [2 5 8] [2 by: 3 <=: 8])
(test-equal [1 4 7 10] [1 by: 3 size: 4])
(test-equal [3 4 5 6] [3 size: 4])
(test-equal [2 5 8] [2 by: 3 <: 9])
(test-equal [2 5 8 11] [2 by: 3 <=: 11])
(test-equal [2 5 8 11] [2 by: 3 <=: 13])
(test-equal ([1 by: 2 ] [1 <: 10]) [3 5 7 9 11 13 15 17 19])
(test-equal [20 20 20 20 20] ([20 by: 0] [0 <: 5]))
(test-equal [3.0 3.5 4.0 4.5 5.0 5.5 6.0] [3.0 by: 0.5 <=: 6])
(test-equal [4.0 3.5 3.0] [4.0 by: -0.5 >=: 3.0])
(test-error [20 by: 2 >: 30])
(test-error [20 by: -2 <=: 10])

(define arr1 (array #2a((1 4) (0 4))
                    10 11 12 13 20 21 22 23 30 31 32 33))
(test-equal #2a@1:3:4((10 11 12 13) (20 21 22 23) (30 31 32 33))
            arr1)
(test-equal 23 (arr1 2 3))
(test-equal #(23 21) (arr1 2 [3 1]))
(test-equal #2a((23 21 23) (13 11 13))
            (arr1 [2 1] [3 1 3]))
(test-equal #2a((11 12 13) (21 22 23))
            (arr1 [1 <: 3] [1 <: 4]))
(test-equal #(23 22 21 20)
            (arr1 2 [>:]))
(test-equal #(12 22 32)
            (arr1 [<:] 2))
(test-equal #2a((10 11 12 13) (20 21 22 23) (30 31 32 33))
            (arr1 [<:] [<:]))
(test-equal #3a(((23 21) (23 22)) ((13 11) (13 12)))
            (arr1 [2 1] #2a((3 1) (3 2))))
(test-equal #2a((13) (23) (33))
            (arr1 [<:] [3]))
(test-equal #2a((13 13 13 13 13) (23 23 23 23 23) (33 33 33 33 33))
            (arr1 [<:] [3 by: 0 size: 5]))
(test-equal #3a:3@1:2:2(((10 11) (12 13)) ((20 21) (22 23)) ((30 31) (32 33)))
            (array-transform arr1 #2a((0 3) (1 3) (0 2))
                             (lambda (ix) (let ((i (ix 0)) (j (ix 1)) (k (ix 2)))
                                            [(+ i 1)
                                             (+ (* 2 (- j 1)) k)]))))
(test-equal &{&-
#2u32@2:2@3:2
║001│002║
╟───┼───╢
║002│003║
╚═══╧═══╝}
  (format-array  #2u32@2@3((1 2) (2 3)) "~3,'0d"))      

;; Some tests relating to GitLab issues #66 and #67
(let* ((v1 (vector 100 101 102 103))
       (a1a (make-array (shape 0 4) @v1))
       (a1b (array-reshape v1 (shape 0 4)))
       (a2a (make-array (shape 0 2 0 2) @v1))
       (s2b (shape 0 2 1 3))
       (a2b (array-reshape v1 s2b))
       (a3 (share-array a1b (shape 0 2) values)))
  (test-equal a1a a1b)
  (test-assert (not (equal? a2a a2b)))
  (test-assert (equal? (array-reshape a2a s2b) a2b))
  (test-equal v1 (array->vector a1a))
  (test-eq v1 (array->vector a1b))
  (test-equal v1 (array->vector a2a))
  (test-eq v1 (array->vector a2b))
  (test-equal #(100 101) a3)
  (test-equal #(100 101) (array->vector a3))
  (test-equal #(100 101) (array-flatten a3))
  )

(test-end)
