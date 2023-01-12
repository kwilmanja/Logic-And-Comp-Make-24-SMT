; ****************** BEGIN INITIALIZATION FOR ACL2s MODE ****************** ;
; (Nothing to see here!  Your actual file is after this initialization code);
(make-event
 (er-progn
  (set-deferred-ttag-notes t state)
  (value '(value-triple :invisible))))

#+acl2s-startup (er-progn (assign fmt-error-msg "Problem loading the CCG book.~%Please choose \"Recertify ACL2s system books\" under the ACL2s menu and retry after successful recertification.") (value :invisible))
(include-book "acl2s/ccg/ccg" :uncertified-okp nil :dir :system :ttags ((:ccg)) :load-compiled-file nil);v4.0 change

;Common base theory for all modes.
#+acl2s-startup (er-progn (assign fmt-error-msg "Problem loading ACL2s base theory book.~%Please choose \"Recertify ACL2s system books\" under the ACL2s menu and retry after successful recertification.") (value :invisible))
(include-book "acl2s/base-theory" :dir :system :ttags :all)


#+acl2s-startup (er-progn (assign fmt-error-msg "Problem loading ACL2s customizations book.~%Please choose \"Recertify ACL2s system books\" under the ACL2s menu and retry after successful recertification.") (value :invisible))
(include-book "acl2s/custom" :dir :system :ttags :all)

;; guard-checking-on is in *protected-system-state-globals* so any
;; changes are reverted back to what they were if you try setting this
;; with make-event. So, in order to avoid the use of progn! and trust
;; tags (which would not have been a big deal) in custom.lisp, I
;; decided to add this here.
;; 
;; How to check (f-get-global 'guard-checking-on state)
;; (acl2::set-guard-checking :nowarn)
(acl2::set-guard-checking :all)

;Settings common to all ACL2s modes
(acl2s-common-settings)
;(acl2::xdoc acl2s::defunc) ;; 3 seconds is too much time to spare -- commenting out [2015-02-01 Sun]

#+acl2s-startup (er-progn (assign fmt-error-msg "Problem loading ACL2s customizations book.~%Please choose \"Recertify ACL2s system books\" under the ACL2s menu and retry after successful recertification.") (value :invisible))
(include-book "acl2s/acl2s-sigs" :dir :system :ttags :all)

#+acl2s-startup (er-progn (assign fmt-error-msg "Problem setting up ACL2s mode.") (value :invisible))

(acl2::xdoc acl2s::defunc) ; almost 3 seconds

; Non-events:
;(set-guard-checking :none)

(set-inhibit-warnings! "Invariant-risk" "theory")

(in-package "ACL2")
(redef+)
(defun print-ttag-note (val active-book-name include-bookp deferred-p state)
  (declare (xargs :stobjs state)
	   (ignore val active-book-name include-bookp deferred-p))
  state)

(defun print-deferred-ttag-notes-summary (state)
  (declare (xargs :stobjs state))
  state)

(defun notify-on-defttag (val active-book-name include-bookp state)
  (declare (xargs :stobjs state)
	   (ignore val active-book-name include-bookp))
  state)
(redef-)

(acl2::in-package "ACL2S")

; ******************* END INITIALIZATION FOR ACL2s MODE ******************* ;
;$ACL2s-SMode$;ACL2s
;(defdata func `(,func ,oper ,func ,oper ,func ,oper ,func))
;_________________________________________________________________
(defdata oper (enum '(+ - * /)))
(defdata subfunc `(,nat ,oper ,nat))
(defdata func `(,subfunc ,oper ,subfunc))
(defdata loNums (oneof '()
                       `(,nat ,nat ,nat ,nat)))

(definec onlyNums (subf :subfunc) :tl
  (cons (car subf) (cdr (cdr subf))))

(check= (onlyNums '(1 + 5)) '(1 5))
(check= (onlyNums '(3 - 1)) '(3 1))
(check= (onlyNums '(10 / 2)) '(10 2))
(check= (onlyNums '(0 * 3)) '(0 3))

; is the given number in the lists the same number of times?
(definec compare (num :nat f :func lon2 :loNums) :bool
  (equal (+ (count num (onlyNums (car f)))
            (count num (onlyNums (car (cdr (cdr f))))))
         (count num lon2)))

(check= (compare 1 '((16 + 0) * (0 + 1)) '(0 0 1 0)) t)
(check= (compare 1 '((16 + 0) * (0 + 1)) '(0 0 1 0)) t)
(check= (compare 16 '((16 + 0) * (0 + 1)) '(0 0 1 0)) nil)
(check= (compare 0 '((16 + 0) * (0 + 1)) '(0 0 1 0)) nil)
(check= (compare 16 '((16 + 0) * (0 + 1)) '(16 16 0 1)) nil)
(check= (compare 0 '((16 + 0) * (0 + 1)) '(16 16 0 1)) nil)
(check= (compare 1 '((16 + 0) * (0 + 1)) '(16 16 0 1)) t)

;does not include incorrect repeats (FINAL VERSION)
(definec contains-all2 (f :func lon :loNums) :bool
   (cond
   ((null lon) nil)
   ((equal nil (compare (car lon) f lon)) nil)
   ((equal nil (compare (car (cdr lon)) f lon)) nil)
   ((equal nil (compare (car (cddr lon)) f lon)) nil)
   ((equal nil (compare (car (cdddr lon)) f lon)) nil)
   (t t)))
(check= (contains-all2 '((16 + 0) * (0 + 1)) '(1 2 3 4)) nil)
(check= (contains-all2 '((16 + 0) * (0 + 1)) '(0 0 1 0)) nil)
(check= (contains-all2 '((16 + 0) * (0 + 1)) '(1 0 0 4)) nil)
(check= (contains-all2 '((16 + 0) * (0 + 1)) '(16 16 0 1)) nil) ;; fixed bug - only in once
(check= (contains-all2 '((16 + 0) * (0 + 1)) '(16 0 0 1)) t)
(check= (contains-all2 '((0 / 0) + (0 + 1)) '(0 0 0 1)) t)
(check= (contains-all2 '((0 / 0) + (0 + 0)) '(0 0 0 0)) t)#|ACL2s-ToDo-Line|#

