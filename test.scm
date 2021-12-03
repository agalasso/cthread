#!/bin/bash
# -*- mode: scheme -*-
exec guile -l ct.scm -e main -s $0 $@
!#

(use-modules (cthread))

(define (main args)
  (apply add-cthread (cons thread args))
  (format #t "main: starting thread...~%")
  (next-cthread)
  (let loop ()
    (next-cthread)
    (unless (= 1 (num-cthreads))
      (format #t "main: message from main~%")
      (usleep 10000)
      (loop))))

(define (loop)
  (format #t "cthread: now for a message from main:~%")
  (next-cthread)
  (format #t "cthread: That was a message from main. continue? y/n~%~%")
  (when (eqv? 'y (read))
    (format #t "continuing...~%")
    (loop)))

(define (thread . args)
  (format #t "cthread: Hi! The commandline arguments are: ~a~%" args)
  (add-cthread die-instantly)
  (unless (= (num-cthreads) 3)
    (error "should be three threads rn."))
  (next-cthread)
  (unless (= (num-cthreads) 2)
    (error "should be just 2 threads rn."))
  (loop)
  (format #t "I know you said to stop, but here's one more:~%")
  (next-cthread)
  (format #t "Ok, ok, I'll stop. Bye.~%"))

;; apply this procedure to die instantly!
(define (die-instantly)
  (remove-cthread)
  (error "This shouldn't happen. Remove-cthread never returns."))
