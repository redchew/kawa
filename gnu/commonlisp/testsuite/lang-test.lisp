(test-init "Common Lisp tests" 59)

(setq y 100)
(defun foo1 (x)
  (lambda (y)
    (/ x y)))
(defvar foo12 (foo1 12))
(test 4 'lexical-test-1 (apply foo12 '(3)))

(defvar xx 20)
(defun xx (a) (+ xx a))
(test 24 'separate-names-1 (xx 4))

;(test t 'eq-test-1 (eq t 't))

(test t 'equal-test-1 (equal "tt" "tt"))
(test nil 'equal-test-2 (equal "tt" "tt "))

(test "The octal value of 18 is 22,
   and the hex value is 12."
      'format-test-1
      (format "The octal value of ~d is ~o,
   and the hex value is ~x." 18 18 18))

(defmacro list-1 (bar) `(list ,bar))
(test '(12) 'defmacro (list-1 12))

(test '(3 4) 'list-1 (list 3 4))
(test nil 'functionp-1 (functionp 'list))
(test t 'functionp-2 (functionp #'list))
(test t 'functionp-3 (functionp (function list)))
(test '(3 4) 'function-1 ((function list) 3 4))

(test 6 'flet-1 (flet ((flet1 (n) (+ n n)))
                  (flet ((flet1 (n) (+ 2 (flet1 n))))
                    (flet1 2))))

(defun dummy-function () 'top-level)

(test 'shadow 'flet-2 (flet ((dummy-function () 'shadow))
                        (funcall #'dummy-function)))

(test 'top-level 'funcall-3 (funcall #'dummy-function))

(test 'shadow 'flet-2 (flet ((dummy-function () 'shadow))
                        (funcall #'dummy-function)))

(test t 'flet-3 (eq (funcall #'dummy-function) (funcall 'dummy-function)))
(test '() 'flet-4 (flet ((dummy-function () 'shadow))
		    (eq (funcall #'dummy-function)
			(funcall 'dummy-function))))

;; # is a non-terminating macro character in Common Lisp.
(test '(|a#com#b|) 'sharp-in-token '(a#|com|#b))

(test nil 'car-1 (car nil))
(test 1 'car-2 (car '(1 . 2)))
(test nil 'cdr-1 (cdr nil))
(test 2 'cdr-2 (cdr '(1 . 2)))
(test nil 'first-1 (first nil))
(test 1 'first-2 (first '(1 . 2)))
(test nil 'rest-1 (rest nil))
(test 2 'rest-2 (rest '(1 . 2)))
(test 'foo 'nth-1 (nth 0 '(foo bar baz)))
(test 'bar 'nth-2 (nth 1 '(foo bar baz)))
(test nil 'nth-3 (nth 3 '(foo bar baz)))
(test nil 'nthcdr-1 (nthcdr 0 '()))
(test nil 'nthcdr-2 (nthcdr 3 '()))
(test '(a b c) 'nthcdr-3 (nthcdr 0 '(a b c)))
(test '(c) 'nthcdr-4 (nthcdr 2 '(a b c)))
(test '() 'nthcdr-5 (nthcdr 4 '(a b c)))
(test 1 'nthcdr-6 (nthcdr 1 '(0 . 1)))

(setq alist '())
(test '((1 . "one")) 'acons-1 (acons 1 "one" alist))
(test nil 'acons-2 alist)
(test '((1 . "one") (2 . "two"))
      'acons-3
      (setq alist (acons 1 "one" (acons 2 "two" alist))))
(test '(1 . "one")
      'acons-4
      (assoc 1 alist))
(test '((1 . "uno") (1 . "one") (2 . "two"))
      'acons-5
      (setq alist (acons 1 "uno" alist)))
(test '(1 . "uno")
      'assoc-6
      (assoc 1 alist))

(test t 'listp-1 (listp nil))
(test t 'listp-2 (listp (cons 1 2)))
(test nil 'listp-3 (listp t))

(test t 'numberp-1 (numberp 12))
(test t 'numberp-2 (numberp (expt 2 130)))
(test nil 'numberp-3 (numberp nil))
(test nil 'numberp-4 (numberp (cons 1 2)))

(test t 'zerop-1 (zerop 0))
(test nil 'zerop-2 (zerop 1))
(test t 'zerop-3 (zerop -0.0))
(test t 'zerop-4 (zerop 0/100))

(test nil 'consp-1 (consp nil))
(test t 'consp-2 (consp (cons 1 2)))

(test t 'atomp-1 (atom 'sss))
(test nil 'atomp-2 (atom (cons 1 2)))
(test t 'atomp-3 (atom nil))
(test t 'atomp-4 (atom '()))
(test t 'atomp-5 (atom 3))
