(import (scheme base)
        (scheme write)
        (srfi 1))

(write (apply circular-list '(3 1 4 1 5 9)))
(newline)
;; Output: #0=(3 1 4 1 5 9 . #0#)
(write (circular-list 3 1 4 1 5))
(newline)
;; Output: #0=(3 1 4 1 5 . #0#)