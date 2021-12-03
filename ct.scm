(define-module (cthread)
  #:use-module (srfi srfi-1)
  #:export (add-cthread remove-cthread num-cthreads next-cthread))

;; Circular list of continuations for every cthread.
;; Some invariants:
;;   (car cthreads) is the continuation for the currently executing code.
;;   (car cthreads) is always out of date and safe to overwrite.
;;   every other continuation in cthreads in valid, and safe to call.
(define cthreads (circular-list #f))

(define* (set-circular-last! clist what #:optional (first clist))
  (if (eq? (cdr clist) first)
    (set-cdr! clist what)
    (set-circular-last! (cdr clist) what first)))

;; Register another cthread for this program, with a starting point of proc.
;; When the new cthread starts, proc is called with arguments args.
;; If in the new cthread proc returns, that cthread is unregistered, and
;; it ceases execution.
;; This function returns immediately. To switch to the new cthread, call
;; (next-cthread).
(define (add-cthread proc . args)
  (call/cc (lambda (done)
    (call/cc (lambda (new-cont)
      (set-cdr! cthreads (cons new-cont (cdr cthreads)))
      (set-circular-last! cthreads cthreads)
      (done)))
    (apply proc args)
    (remove-cthread))))

;; Unregisters the current cthread, and switches control to another. Kind of
;; like exit(). If there are no other cthreads, cease execution.
(define (remove-cthread)
  (if (eqv? cthreads (cdr cthreads))  ;; size is one
    (exit)
    (begin
      (set-circular-last! cthreads (cdr cthreads))
      (set! cthreads (cdr cthreads))
      ((car cthreads)))))

(define (num-cthreads)
  (let loop ((cur cthreads) (n 1))
    (if (eq? (cdr cur) cthreads)
      n
      (loop (cdr cur) (+ n 1)))))

;; Save state and transfer control to another cthread. When another cthread
;; calls next-cthread, this function returns.
(define (next-cthread)
  (call/cc (lambda (cont)
    (set-car! cthreads cont)
    (set! cthreads (cdr cthreads))
    ((car cthreads)))))  ;; <= never returns, eventually someone calls cont
