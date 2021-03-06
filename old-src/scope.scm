(load "mk.scm")
(load "matche.scm")
(load "pmatch.scm")
(load "test-check.scm")

(define occurs-free?-tests
  (lambda (occurs-free?)

    (test "occurs-free?-0a"
      (occurs-free? 'z 'z)
      #t)

    (test "occurs-free?-0b"
      (occurs-free? 'z 'w)
      #f)
    
    (test "occurs-free?-1"
      (occurs-free? 'z '(lambda (z) (lambda (z) z)))
      #f)

    (test "occurs-free?-2"
      (occurs-free? 'z '(lambda (z) (lambda (y) z)))
      #f)

    (test "occurs-free?-3"
      (occurs-free? 'y '(lambda (z) (lambda (x) y)))
      #t)

    (test "occurs-free?-4"
      (occurs-free? 'y '(lambda (y) y))
      #f)

    (test "occurs-free?-5"
      (occurs-free? 'y '(lambda (y) z))
      #f)

    (test "occurs-free?-6"
      (occurs-free? 'y '(y y))
      #t)

    (test "occurs-free?-7"
      (occurs-free? 'y '(w z))
      #f)

    (test "occurs-free?-8"
      (occurs-free? 'y '(y z))
      #t)
    
    (test "occurs-free?-9"
      (occurs-free? 'y '(z y))
      #t)

    (test "occurs-free?-10"
      (occurs-free? 'y '((lambda (x) y) z))
      #t)

    (test "occurs-free?-11"
      (occurs-free? 'y '(z (lambda (x) y)))
      #t)

    (test "occurs-free?-12"
      (occurs-free? 'y '(z (lambda (x) w)))
      #f)
    
    ))


(define occurs-free?
  (lambda (x e)
    (pmatch e
      (,y (guard (symbol? y))
       (eq? x y))
      ((lambda (,y) ,body)
       (cond
         ((eq? x y) #f)
         (else (occurs-free? x body))))
      ((,e1 ,e2)
       (or (occurs-free? x e1)
           (occurs-free? x e2))))))

(occurs-free?-tests occurs-free?)

(define occurs-free?
  (lambda (x e)
    (unless (symbol? x)
      (error 'occurs-free? "first argument must be a symbol"))
    (pmatch e
      (,y (guard (symbol? y))
       (eq? x y))
      ((lambda (,y) ,body) (guard (symbol? y))
       (cond
         ((eq? x y) #f)
         ((not (eq? x y)) (occurs-free? x body))))
      ((,e1 ,e2)
       (cond
         ((occurs-free? x e1) #t)
         ((not (occurs-free? x e1))
          (occurs-free? x e2)))))))

(occurs-free?-tests occurs-free?)

(define occurs-free?
  (lambda (x e)
    (unless (symbol? x)
      (error 'occurs-free? "first argument must be a symbol"))
    (pmatch e
      ((,e1 ,e2)
       (cond
         ((not (occurs-free? x e1))
          (occurs-free? x e2))
         ((occurs-free? x e1) #t)))
      ((lambda (,y) ,body) (guard (symbol? y))
       (cond
         ((not (eq? x y)) (occurs-free? x body))
         ((eq? x y) #f)))
      (,y (guard (symbol? y))
       (eq? x y)))))

(occurs-free?-tests occurs-free?)

(define occurs-free?
  (lambda (x e)
    (unless (symbol? x)
      (error 'occurs-free? "first argument must be a symbol"))
    (pmatch e
      ((,e1 ,e2)
       (cond
         ((not-occurs-free? x e1)
          (occurs-free? x e2))
         ((occurs-free? x e1) #t)))
      ((lambda (,y) ,body) (guard (symbol? y))
       (cond
         ((not (eq? x y)) (occurs-free? x body))
         ((eq? x y) #f)))
      (,y (guard (symbol? y))
       (eq? x y)))))

;; not-occurs-free? is *not* the same as occurs-bound?
(define not-occurs-free?
  (lambda (x e)
    (unless (symbol? x)
      (error 'not-occurs-free? "first argument must be a symbol"))
    (pmatch e
      (,y (guard (symbol? y))
       (not (eq? x y)))
      ((lambda (,y) ,body) (guard (symbol? y))
       (cond
         ((not (eq? x y)) (not-occurs-free? x body))
         ((eq? x y) #t)))
      ((,e1 ,e2)
       (and
         (not-occurs-free? x e1)
         (not-occurs-free? x e2))))))

(occurs-free?-tests occurs-free?)

(define occurs-free?
  (lambda (x e)
    (unless (symbol? x)
      (error 'occurs-free? "first argument must be a symbol"))
    (pmatch e
      (,y (guard (symbol? y))
       (eq? x y))
      ((lambda (,y) ,body) (guard (symbol? y))
       (cond
         ((eq? x y) #f)
         ((not (eq? x y)) (occurs-free? x body))))
      ((,e1 ,e2)
       (cond
         ((occurs-free? x e1) #t)
         ((not-occurs-free? x e1)
          (occurs-free? x e2)))))))

(define not-occurs-free?
  (lambda (x e)
    (unless (symbol? x)
      (error 'not-occurs-free? "first argument must be a symbol"))
    (pmatch e
      (,y (guard (symbol? y))
       (not (eq? x y)))
      ((lambda (,y) ,body) (guard (symbol? y))
       (cond
         ((not (eq? x y)) (not-occurs-free? x body))
         ((eq? x y) #t)))
      ((,e1 ,e2)
       (and
         (not-occurs-free? x e1)
         (not-occurs-free? x e2))))))

(occurs-free?-tests occurs-free?)





(define occurs-bound?-tests
  (lambda (occurs-bound?)

    (test "occurs-bound?-0"
      (occurs-bound? 'z 'z)
      #f)

    (test "occurs-bound?-1"
      (occurs-bound? 'z '(lambda (z) (lambda (z) z)))
      #t)

    (test "occurs-bound?-2"
      (occurs-bound? 'z '(lambda (z) (lambda (w) z)))
      #t)

    (test "occurs-bound?-3"
      (occurs-bound? 'z '(lambda (w) (lambda (x) z)))
      #f)
    
    ))

(define not-occurs-bound?-tests
  (lambda (not-occurs-bound?)

    (test "not-occurs-bound?-0"
      (not-occurs-bound? 'z 'z)
      #t)

    (test "not-occurs-bound?-1"
      (not-occurs-bound? 'z '(lambda (z) (lambda (z) z)))
      #f)  

    (test "not-occurs-bound?-2"
      (not-occurs-bound? 'z '(lambda (z) (lambda (w) z)))
      #f)

    (test "not-occurs-bound?-3"
      (not-occurs-bound? 'z '(lambda (w) (lambda (x) z)))
      #t)
    
    ))


(define occurs-bound?
  (lambda (x e)
    (pmatch e
      (,y (guard (symbol? y))
       #f)
      ((lambda (,y) ,body)
       (cond
         ((eq? x y)
          (or (occurs-free? x body)
              (occurs-bound? x body)))
         (else (occurs-bound? x body))))
      ((,e1 ,e2)
       (or (occurs-bound? x e1)
           (occurs-bound? x e2))))))

(occurs-bound?-tests occurs-bound?)

(define occurs-bound?
  (lambda (x e)
    (unless (symbol? x)
      (error 'occurs-bound? "first argument must be a symbol"))
    (pmatch e
      (,y (guard (symbol? y))
       #f)
      ((lambda (,y) ,body) (guard (symbol? y))
       (cond
         ((eq? x y)
          (cond
            ((occurs-free? x body) #t)
            ((not-occurs-free? x body)
             (occurs-bound? x body))))
         ((not (eq? x y))
          (occurs-bound? x body))))
      ((,e1 ,e2)
       (cond
         ((occurs-bound? x e1) #t)
         ((not (occurs-bound? x e1))
          (occurs-bound? x e2)))))))

(occurs-bound?-tests occurs-bound?)

(define occurs-bound?
  (lambda (x e)
    (unless (symbol? x)
      (error 'occurs-bound? "first argument must be a symbol"))
    (pmatch e
      ((,e1 ,e2)
       (cond
         ((not (occurs-bound? x e1))
          (occurs-bound? x e2))
         ((occurs-bound? x e1) #t)))
      ((lambda (,y) ,body) (guard (symbol? y))
       (cond
         ((eq? x y)
          (cond
            ((not-occurs-free? x body)
             (occurs-bound? x body))
            ((occurs-free? x body) #t)))
         ((not (eq? x y))
          (occurs-bound? x body))))
      (,y (guard (symbol? y))
       #f))))

(occurs-bound?-tests occurs-bound?)

(define occurs-bound?
  (lambda (x e)
    (unless (symbol? x)
      (error 'occurs-bound? "first argument must be a symbol"))
    (pmatch e
      (,y (guard (symbol? y))
       #f)
      ((lambda (,y) ,body) (guard (symbol? y))
       (cond
         ((eq? x y)
          (cond
            ((occurs-free? x body) #t)
            ((not-occurs-free? x body)
             (occurs-bound? x body))))
         ((not (eq? x y))
          (occurs-bound? x body))))
      ((,e1 ,e2)
       (cond
         ((occurs-bound? x e1) #t)
         ((not-occurs-bound? x e1)
          (occurs-bound? x e2)))))))

(define not-occurs-bound?
  (lambda (x e)
    (unless (symbol? x)
      (error 'not-occurs-bound? "first argument must be a symbol"))
    (pmatch e
      (,y (guard (symbol? y))
       #t)
      ((lambda (,y) ,body) (guard (symbol? y))
       (cond
         ((eq? x y)
          (and
            (not-occurs-free? x body)
            (not-occurs-bound? x body)))
         ((not (eq? x y))
          (not-occurs-bound? x body))))
      ((,e1 ,e2)
       (and
         (not-occurs-bound? x e1)
         (not-occurs-bound? x e2))))))

(occurs-bound?-tests occurs-bound?)
(not-occurs-bound?-tests not-occurs-bound?)

(define occurs-bound?
  (lambda (x e)
    (unless (symbol? x)
      (error 'occurs-bound? "first argument must be a symbol"))
    (pmatch e
      ((,e1 ,e2)
       (cond
         ((occurs-bound? x e1) #t)
         ((not-occurs-bound? x e1)
          (occurs-bound? x e2))))
      ((lambda (,y) ,body) (guard (symbol? y))
       (cond
         ((not (eq? x y))
          (occurs-bound? x body))
         ((eq? x y)
          (cond
            ((not-occurs-free? x body)
             (occurs-bound? x body))
            ((occurs-free? x body) #t)))))
      (,y (guard (symbol? y))
       #f))))

(define not-occurs-bound?
  (lambda (x e)
    (unless (symbol? x)
      (error 'not-occurs-bound? "first argument must be a symbol"))
    (pmatch e
      ((,e1 ,e2)
       (and
         (not-occurs-bound? x e2)
         (not-occurs-bound? x e1)))
      ((lambda (,y) ,body) (guard (symbol? y))
       (cond
         ((not (eq? x y))
          (not-occurs-bound? x body))
         ((eq? x y)
          (and
            (not-occurs-bound? x body)
            (not-occurs-free? x body)))))
      (,y (guard (symbol? y))
       #t))))

(occurs-bound?-tests occurs-bound?)
(not-occurs-bound?-tests not-occurs-bound?)


;;; careful here--my code doesn't know about 'let' or '+'
(test "shadowing-1"
  (let ((x 3))
    (let ((y 4))
      (+ x y)))
  7)

(test "shadowing-2"
  (let ((x 3))
    (let ((y 4))
      (let ((x 5))
        (+ x y))))
  9)

(test "lexical-scope-1"
  (let ((x 5))
    (let ((f (lambda (y) (+ x y))))
      (let ((x 6))
        (f x))))
  11)

;; avoiding overlapping answers in the application case is the tricky
;; part, and requires the 'not-occurs-freeo' helper relation.
(define occurs-freeo
  (lambda (x e)
    (fresh ()
      (symbolo x)
      (matche e
        (,y (symbolo y)
         (== x y))
        ((lambda (,y) ,body) (symbolo y)
         (=/= x y)
         (occurs-freeo x body))
        ((,e1 ,e2)
         (conde
           ((occurs-freeo x e1))
           ((not-occurs-freeo x e1)
            (occurs-freeo x e2))))))))

;; not-occurs-freeo is *not* the same as occurs-boundo
(define not-occurs-freeo
  (lambda (x e)
    (fresh ()
      (symbolo x)
      (matche e
        (,y (symbolo y)
         (=/= x y))
        ((lambda (,y) ,body) (symbolo y)
         (conde
           ((== x y))
           ((=/= x y)
            (not-occurs-freeo x body))))
        ((,e1 ,e2)
         (not-occurs-freeo x e1)
         (not-occurs-freeo x e2))))))



(define occurs-boundo
  (lambda (x e)
    (fresh ()
      (symbolo x)
      (matche e
        ((lambda (,y) ,body) (symbolo y)
         (conde
           ((=/= x y)
            (occurs-boundo x body))
           ((== x y)
            (conde
              ((occurs-freeo x body))
              ((not-occurs-freeo x body)
               (occurs-boundo x body))))))
        ((,e1 ,e2)
         (conde
           ((occurs-boundo x e1))
           ((not-occurs-boundo x e1)
            (occurs-boundo x e2))))))))

(define not-occurs-boundo
  (lambda (x e)
    (fresh ()
      (symbolo x)
      (matche e
        (,y (symbolo y))
        ((lambda (,y) ,body) (symbolo y)
         (conde
           ((== x y)
            (not-occurs-freeo x body)
            (not-occurs-boundo x body))
           ((=/= x y)
            (not-occurs-boundo x body))))
        ((,e1 ,e2)
         (not-occurs-boundo x e1)
         (not-occurs-boundo x e2))))))



(test "occurs-freeo-0"
  (run* (q) (occurs-freeo 'z 'z))
  '(_.0))

(test "occurs-freeo-1"
  (run* (q) (occurs-freeo 'z '(lambda (z) (lambda (z) z))))
  '())

(test "occurs-freeo-2"
  (run 10 (q) (occurs-freeo 'z q))
  '(z
    ((lambda (_.0) z) (=/= ((_.0 z))) (sym _.0))
    (z _.0)
    ((lambda (_.0) (lambda (_.1) z)) (=/= ((_.0 z)) ((_.1 z))) (sym _.0 _.1))
    ((lambda (_.0) (z _.1)) (=/= ((_.0 z))) (sym _.0))
    ((_.0 z) (=/= ((_.0 z))) (sym _.0))
    (((lambda (_.0) z) _.1) (=/= ((_.0 z))) (sym _.0))
    ((lambda (_.0) (lambda (_.1) (lambda (_.2) z))) (=/= ((_.0 z)) ((_.1 z)) ((_.2 z))) (sym _.0 _.1 _.2))
    ((z _.0) _.1)
    ((lambda (_.0) (lambda (_.1) (z _.2))) (=/= ((_.0 z)) ((_.1 z))) (sym _.0 _.1))))



(define answer-contains-constraints?
  (letrec ((memq*
            (lambda (x y)
              (cond
                ((null? y) #f)
                ((pair? y) (or (memq* x (car y)) (memq* x (cdr y))))
                ((eq? x y) #t)
                (else #f)))))
    (lambda (ans)
      (and (list? ans)
           (or (memq* '=/= ans)
               (memq* 'sym ans)
               (memq* 'num ans)
               (memq* 'absento ans))))))


(test "occurs-freeo-3"
  (for-all
   (lambda (e)
     (let ((e (if (answer-contains-constraints? e) (car e) e)))
       (occurs-free? 'z e)))
   (run 100 (q) (occurs-freeo 'z q)))
  #t)

(test "occurs-freeo-10"
  (run* (q) (occurs-freeo 'a '(a b)))
  '(_.0))

(test "occurs-freeo-9"
  (run* (q) (occurs-freeo 'a '(b a)))
  '(_.0))

(test "occurs-freeo-8"
  (run* (q) (occurs-freeo 'a '(((lambda (z) (v (w z))) w) a)))
  '(_.0))

(test "occurs-freeo-7"
  (run* (q) (occurs-freeo 'a '(a ((lambda (z) (v (w z))) w))))
  '(_.0))

(test "occurs-freeo-6"
  (run* (q) (occurs-freeo 'a '(lambda (w) (a ((lambda (z) (v (w z))) w)))))
  '(_.0))

(test "occurs-freeo-5"
  (run* (q) (occurs-freeo 'a '(lambda (w) (((lambda (z) (v (w z))) w) a))))
  '(_.0))

(test "occurs-freeo-4"
  (run* (q) (occurs-freeo q '(lambda (w) (((lambda (z) (v (w z))) w) a))))
  '(v a))

(test "occurs-freeo-11"
  (run 5 (q) (fresh (x e) (occurs-freeo x e) (== `(,x ,e) q)))
  '(((_.0 _.0) (sym _.0))
    ((_.0 (lambda (_.1) _.0)) (=/= ((_.0 _.1))) (sym _.0 _.1))
    ((_.0 (_.0 _.1)) (sym _.0))
    ((_.0 (lambda (_.1) (lambda (_.2) _.0))) (=/= ((_.0 _.1)) ((_.0 _.2))) (sym _.0 _.1 _.2))
    ((_.0 (lambda (_.1) (_.0 _.2))) (=/= ((_.0 _.1))) (sym _.0 _.1))))


(test "occurs-boundo-0"
  (run* (q) (occurs-boundo 'z 'z))
  '())

(test "occurs-boundo-1"
  (run* (q) (occurs-boundo 'z '(lambda (z) (lambda (z) z))))
  '(_.0))

(test "occurs-boundo-2"
  (run* (q) (occurs-boundo q '(lambda (w) (((lambda (z) (v (w z))) w) a))))
  '(w z))

(test "occurs-boundo-3"
  (run 10 (q) (occurs-boundo 'z q))
  '((lambda (z) z)
    ((lambda (z) (lambda (_.0) z)) (=/= ((_.0 z))) (sym _.0))
    ((lambda (_.0) (lambda (z) z)) (=/= ((_.0 z))) (sym _.0))
    ((lambda (z) z) _.0)
    (lambda (z) (z _.0))
    ((lambda (z) (lambda (_.0) (lambda (_.1) z)))
     (=/= ((_.0 z)) ((_.1 z))) (sym _.0 _.1))
    (lambda (z) (lambda (z) z))
    ((_.0 (lambda (z) z)) (sym _.0))
    ((lambda (z) (lambda (_.0) (z _.1))) (=/= ((_.0 z))) (sym _.0))
    ((lambda (z) (_.0 z)) (=/= ((_.0 z))) (sym _.0))))

(test "occurs-boundo-4"
  (for-all
   (lambda (e)
     (let ((e (if (answer-contains-constraints? e) (car e) e)))
       (occurs-bound? 'z e)))
   (run 100 (q) (occurs-boundo 'z q)))
  #t)

(test "occurs-boundo-5"
  (run 10 (q) (fresh (x e) (occurs-boundo x e) (== `(,x ,e) q)))
  '(((_.0 (lambda (_.0) _.0))
     (sym _.0))
    ((_.0 (lambda (_.0) (lambda (_.1) _.0)))
     (=/= ((_.0 _.1)))
     (sym _.0 _.1))
    ((_.0 (lambda (_.1) (lambda (_.0) _.0)))
     (=/= ((_.0 _.1)))
     (sym _.0 _.1))
    ((_.0 ((lambda (_.0) _.0) _.1))
     (sym _.0))
    ((_.0 (lambda (_.0) (_.0 _.1)))
     (sym _.0))
    ((_.0 (lambda (_.0) (lambda (_.1) (lambda (_.2) _.0))))
     (=/= ((_.0 _.1)) ((_.0 _.2)))
     (sym _.0 _.1 _.2))
    ((_.0 (lambda (_.0) (lambda (_.0) _.0)))
     (sym _.0))
    ((_.0 (_.1 (lambda (_.0) _.0)))
     (sym _.0 _.1))
    ((_.0 (lambda (_.0) (lambda (_.1) (_.0 _.2))))
     (=/= ((_.0 _.1)))
     (sym _.0 _.1))
    ((_.0 (lambda (_.0) (_.1 _.0)))
     (=/= ((_.0 _.1)))
     (sym _.0 _.1))))

(define union
  (lambda (s1 s2)
    (cond
      ((null? s1)
       s2)
      ((memv (car s1) s2)
       (union (cdr s1) s2))
      (else
       (cons (car s1) (union (cdr s1) s2))))))

(test "union-1"
  (union '() '())
  '())

(test "union-2"
  (union '(a b c) '())
  '(a b c))

(test "union-3"
  (union '() '(a b c))
  '(a b c))

(test "union-4"
  (union '(a b c) '(d e f))
  '(a b c d e f))

(test "union-5"
  (union '(a) '(a))
  '(a))

(test "union-6"
  (union '(a b c d) '(c a d e))
  '(b c a d e))


(define free
  (lambda (e)
    (letrec ((free
              (lambda (e bound-vars)
                (pmatch e
                  (,x (guard (symbol? x))
                      (if (memv x bound-vars)
                          '()
                          `(,x)))
                  ((lambda (,x) ,body) (guard (symbol? x))
                   (free body `(,x . ,bound-vars)))
                  ((,e1 ,e2)
                   (union (free e1 bound-vars)
                          (free e2 bound-vars)))))))
      (free e '()))))

(test "free-1"
  (free '(lambda (w) (((lambda (z) (v (w z))) w) a)))
  '(v a))

(define bound
  (lambda (e)
    (letrec ((bound
              (lambda (e bound-vars)
                (pmatch e
                  (,x (guard (symbol? x))
                      (if (memv x bound-vars)
                          `(,x)
                          '()))
                  ((lambda (,x) ,body) (guard (symbol? x))
                   (bound body `(,x . ,bound-vars)))
                  ((,e1 ,e2)
                   (union (bound e1 bound-vars)
                          (bound e2 bound-vars)))))))
      (bound e '()))))

(test "bound-1"
  (bound '(lambda (w) (((lambda (z) (v (w z))) w) a)))
  '(z w))


(define membero
  (lambda (x ls)
    (matche ls
      ((,y . ,rest)
       (conde
         ((== x y))
         ((=/= x y)
          (membero x rest)))))))

(test "membero-1"
  (run* (q) (membero 'x '()))
  '())

(test "membero-2"
  (run* (q) (membero 'x '(x)))
  '(_.0))

(test "membero-3"
  (run* (q) (membero 'x '(x x)))
  '(_.0))

(test "membero-4"
  (run* (q) (membero 'x '(y z)))
  '())

(test "membero-5"
  (run* (q) (membero q '(y z)))
  '(y z))


(define not-membero
  (lambda (x ls)
    (matche ls
      (())
      ((,y . ,rest)
       (=/= x y)
       (not-membero x rest)))))

(test "not-membero-1"
  (run* (q) (not-membero 'x '()))
  '(_.0))

(test "not-membero-2"
  (run* (q) (not-membero 'x '(x)))
  '())

(test "not-membero-3"
  (run* (q) (not-membero 'x '(x x)))
  '())

(test "not-membero-4"
  (run* (q) (not-membero 'x '(y z)))
  '(_.0))

(test "not-membero-5"
  (run* (q) (not-membero q '(y z)))
  '((_.0 (=/= ((_.0 y)) ((_.0 z))))))



;; really should be replaced with set constraints
(define uniono
  (lambda (s1 s2 out)
    (matche s1
      (()
       (== s2 out))
      ((,a . ,rest)
       (conde
         ((membero a s2)
          (uniono rest s2 out))
         ((fresh (res)
            (== `(,a . ,res) out)
            (not-membero a s2)
            (uniono rest s2 res))))))))

(test "uniono-1"
  (run* (q) (uniono '() '() q))
  '(()))

(test "uniono-2"
  (run* (q) (uniono '(a b c) '() q))
  '((a b c)))

(test "uniono-3"
  (run* (q) (uniono '() '(a b c) q))
  '((a b c)))

(test "uniono-4"
  (run* (q) (uniono '(a b c) '(d e f) q))
  '((a b c d e f)))

(test "uniono-5"
  (run* (q) (uniono '(a) '(a) q))
  '((a)))

(test "uniono-6"
  (run* (q) (uniono '(a b c d) '(c a d e) q))
  '((b c a d e)))



;; Really need set constraints to do this right. Uniono doesn't work
;; very well, membero should be set membership...
(define freeo
  (lambda (e out)
    (letrec ((freeo
              (lambda (e bound-vars out)
                (matche e
                  (,x (symbolo x)
                      (conde
                        ((== `(,x) out)
                         (not-membero x bound-vars))
                        ((== '() out)
                         (membero x bound-vars))))
                  ((lambda (,x) ,body) (symbolo x)
                   (freeo body `(,x . ,bound-vars) out))
                  ((,e1 ,e2)
                   (fresh (res1 res2)
                     (freeo e1 bound-vars res1)
                     (freeo e2 bound-vars res2)
                     (uniono res1 res2 out)))))))
      (freeo e '() out))))

(test "freeo-1"
  (run* (q) (freeo '(lambda (w) (((lambda (z) (v (w z))) w) a)) q))
  '((v a)))

(define boundo
  (lambda (e out)
    (letrec ((boundo
              (lambda (e bound-vars out)
                (matche e
                  (,x (symbolo x)
                      (conde
                        ((== '() out)
                         (not-membero x bound-vars))
                        ((== `(,x) out)
                         (membero x bound-vars))))
                  ((lambda (,x) ,body) (symbolo x)
                   (boundo body `(,x . ,bound-vars) out))
                  ((,e1 ,e2)
                   (fresh (res1 res2)
                     (boundo e1 bound-vars res1)
                     (boundo e2 bound-vars res2)
                     (uniono res1 res2 out)))))))
      (boundo e '() out))))

(test "boundo-1"
  (run* (q) (boundo '(lambda (w) (((lambda (z) (v (w z))) w) a)) q))
  '((z w)))


;; Smarter way to write freeo, without uniono or sets.
;;
;; Avoid uniono by having separate "input" and "output" lists of free
;; vars.
;;
;; Avoid sets by carefully using membero when creating non-empty
;; lists of free variables when running backwards.
(define freeo
  (lambda (e out)
    (letrec ((freeo
              (lambda (e bound-vars free-vars-in free-vars-out)
                (matche e
                  (,x (symbolo x)
                      (conde
                        ((== `(,x . ,free-vars-in) free-vars-out)
                         (not-membero x bound-vars))
                        ((== free-vars-in free-vars-out)
                         (membero x bound-vars))))
                  ((lambda (,x) ,body) (symbolo x)
                   (freeo body `(,x . ,bound-vars) free-vars-in free-vars-out))
                  ((,e1 ,e2)
                   (fresh (free-vars-out^)
                     (freeo e1 bound-vars free-vars-in free-vars-out^)
                     (freeo e2 bound-vars free-vars-out^ free-vars-out)))))))
      (freeo e '() '() out))))

(test "freeo-1"
  (run* (q) (freeo '(lambda (w) (((lambda (z) (v (w z))) w) a)) q))
  '((a v)))

(test "freeo-2"
  (run* (q) (freeo '(v a) '(a v)))
  '(_.0))

(test "freeo-3"
;; This example illustrates the problem with using lists to represent sets.
;; The first argument to freeo is a list representing an application in the lambda-calculus.
;; The second argument is a list representing a *set*, in which order matters
  (list
    (run* (q) (freeo '(a v) '(a v)))
    (run* (q) (freeo '(a v) '(v a))))
  '(() (_.0)))

(test "freeo-4"
;; Avoiding the ordering problem in the 'free' "set" using membero and
;; a length-instantiated free list.
  (list
    (run* (q)
      (fresh (free x y)
        (== `(,x ,y) free)
        (membero 'a free)
        (membero 'v free)
        (freeo '(a v) free)))
    (run* (q)
      (fresh (free x y)
        (== `(,x ,y) free)
        (membero 'v free)
        (membero 'a free)
        (freeo '(a v) free))))
  '((_.0) (_.0)))


;; faking sets when running backwards

 (test "freeo-5a"
   ;; "naive"
   (run 10 (q) (freeo q '(a v)))
   '((v a)
     ((v (lambda (_.0) a)) (=/= ((_.0 a))) (sym _.0))
     ((lambda (_.0) (v a)) (=/= ((_.0 a)) ((_.0 v))) (sym _.0))
     (((lambda (_.0) v) a) (=/= ((_.0 v))) (sym _.0))
     ((v (lambda (_.0) (lambda (_.1) a))) (=/= ((_.0 a)) ((_.1 a))) (sym _.0 _.1))
     ((v (a (lambda (_.0) _.0))) (sym _.0))
     (((lambda (_.0) _.0) (v a)) (sym _.0))
     (((lambda (_.0) v) (lambda (_.1) a)) (=/= ((_.0 v)) ((_.1 a))) (sym _.0 _.1))
     ((v (lambda (_.0) (_.0 a))) (=/= ((_.0 a))) (sym _.0))
     ((v ((lambda (_.0) _.0) a)) (sym _.0))))

 (test "freeo-5b"
   ;; "naive", reordered   
   (run 10 (q) (freeo q '(v a)))
   '((a v)
     ((a (lambda (_.0) v)) (=/= ((_.0 v))) (sym _.0))
     ((lambda (_.0) (a v)) (=/= ((_.0 a)) ((_.0 v))) (sym _.0))
     (((lambda (_.0) a) v) (=/= ((_.0 a))) (sym _.0))
     ((a (lambda (_.0) (lambda (_.1) v))) (=/= ((_.0 v)) ((_.1 v))) (sym _.0 _.1))
     ((a (v (lambda (_.0) _.0))) (sym _.0))
     (((lambda (_.0) _.0) (a v)) (sym _.0))
     (((lambda (_.0) a) (lambda (_.1) v)) (=/= ((_.0 a)) ((_.1 v))) (sym _.0 _.1))
     ((a (lambda (_.0) (_.0 v))) (=/= ((_.0 v))) (sym _.0))
     ((a ((lambda (_.0) _.0) v)) (sym _.0))))

 (test "freeo-5c"
   ;; faking sets
   (run 10 (q)
     (fresh (free x y)
       (== `(,x ,y) free)
       (membero 'a free)
       (membero 'v free)
       (freeo q free)))
   '((v a)
     (a v)
     ((v (lambda (_.0) a)) (=/= ((_.0 a))) (sym _.0))
     ((a (lambda (_.0) v)) (=/= ((_.0 v))) (sym _.0))
     ((lambda (_.0) (v a)) (=/= ((_.0 a)) ((_.0 v))) (sym _.0))
     ((lambda (_.0) (a v)) (=/= ((_.0 a)) ((_.0 v))) (sym _.0))
     (((lambda (_.0) v) a) (=/= ((_.0 v))) (sym _.0))
     (((lambda (_.0) a) v) (=/= ((_.0 a))) (sym _.0))
     ((v (lambda (_.0) (lambda (_.1) a))) (=/= ((_.0 a)) ((_.1 a))) (sym _.0 _.1))
     ((a (lambda (_.0) (lambda (_.1) v))) (=/= ((_.0 v)) ((_.1 v))) (sym _.0 _.1))))

 (test "freeo-5d"
   ;; faking sets, reordered
   (run 10 (q)
     (fresh (free x y)
       (== `(,x ,y) free)
       (membero 'v free)
       (membero 'a free)
       (freeo q free)))
   '((a v)
     (v a)
     ((a (lambda (_.0) v)) (=/= ((_.0 v))) (sym _.0))
     ((v (lambda (_.0) a)) (=/= ((_.0 a))) (sym _.0))
     ((lambda (_.0) (a v)) (=/= ((_.0 a)) ((_.0 v))) (sym _.0))
     ((lambda (_.0) (v a)) (=/= ((_.0 a)) ((_.0 v))) (sym _.0))
     (((lambda (_.0) a) v) (=/= ((_.0 a))) (sym _.0))
     (((lambda (_.0) v) a) (=/= ((_.0 v))) (sym _.0))
     ((a (lambda (_.0) (lambda (_.1) v))) (=/= ((_.0 v)) ((_.1 v))) (sym _.0 _.1))
     ((v (lambda (_.0) (lambda (_.1) a))) (=/= ((_.0 a)) ((_.1 a))) (sym _.0 _.1))))

;; shows a problem with freeo--it generates duplicate answers
 (test "freeo-6"
   (run* (q) (freeo '(w (v w)) q))
   '((w v w)))

(define boundo
  (lambda (e out)
    (letrec ((boundo
              (lambda (e bound-vars occurs-bound-vars-in occurs-bound-vars-out)
                (matche e
                  (,x (symbolo x)
                      (conde
                        ((== `(,x . ,occurs-bound-vars-in) occurs-bound-vars-out)
                         (membero x bound-vars))
                        ((== occurs-bound-vars-in occurs-bound-vars-out)
                         (not-membero x bound-vars))))
                  ((lambda (,x) ,body) (symbolo x)
                   (boundo body `(,x . ,bound-vars) occurs-bound-vars-in occurs-bound-vars-out))
                  ((,e1 ,e2)
                   (fresh (occurs-bound-vars-out^)
                     (boundo e1 bound-vars occurs-bound-vars-in occurs-bound-vars-out^)
                     (boundo e2 bound-vars occurs-bound-vars-out^ occurs-bound-vars-out)))))))
      (boundo e '() '() out))))


(test "boundo-1"
  (run* (q) (boundo '(lambda (w) (((lambda (z) (v (w z))) w) a)) q))
  '((w z w)))

(test "boundo-2"
  (run* (q) (boundo '(lambda (w) (((lambda (z) (v (w z))) w) a)) '(w z w)))
  '(_.0))

(test "boundo-3"
;; This example illustrates the problem with using lists to represent
;; sets.  The first argument to boundo is a list representing an
;; application in the lambda-calculus.  The second argument is a list
;; representing a *set*, yet order matters.
;;
;; There is another issue: the list representing the answers contains
;; duplicates.  This means that our trick of using a
;; length-instantiated list of logic variables + membero to represent
;; the set {z w} is problematic.  We can either use real set
;; constraints, re-write freeo and boundo to avoid adding duplicate
;; values to the "set" lists, or avoid length-instantiating the sets.
  (list
    (run* (q) (boundo '(lambda (w) (((lambda (z) (v (w z))) w) a)) '(z w w)))
    (run* (q) (boundo '(lambda (w) (((lambda (z) (v (w z))) w) a)) '(w z w))))
  '(() (_.0)))

(test "boundo-4"
;; run 2 diverges
  (run 1 (q)
    (fresh (bound)
      (membero 'w bound)
      (membero 'z bound)      
      (boundo '(lambda (w) (((lambda (z) (v (w z))) w) a)) bound)))
  '(_.0))


;; Try to improve boundo by avoiding adding duplicate variables.  I
;; wonder if absento (or a lazy not-membero constraint) would work
;; better than the recursively defined not-membero.
(define boundo
  (lambda (e out)
    (letrec ((boundo
              (lambda (e bound-vars occurs-bound-vars-in occurs-bound-vars-out)
                (matche e
                  (,x (symbolo x)
                      (conde
                        ((== occurs-bound-vars-in occurs-bound-vars-out)
                         (not-membero x bound-vars))
                        ((conde
                           ((== `(,x . ,occurs-bound-vars-in) occurs-bound-vars-out)
                            (not-membero x occurs-bound-vars-in))
                           ((== occurs-bound-vars-in occurs-bound-vars-out)
                            (membero x occurs-bound-vars-in)))
                         (membero x bound-vars))))
                  ((lambda (,x) ,body) (symbolo x)
                   (boundo body `(,x . ,bound-vars) occurs-bound-vars-in occurs-bound-vars-out))
                  ((,e1 ,e2)
                   (fresh (occurs-bound-vars-out^)
                     (boundo e1 bound-vars occurs-bound-vars-in occurs-bound-vars-out^)
                     (boundo e2 bound-vars occurs-bound-vars-out^ occurs-bound-vars-out)))))))
      (boundo e '() '() out))))

(test "smart-boundo-1"
  (run* (q) (boundo '(lambda (w) (((lambda (z) (v (w z))) w) a)) q))
  '((z w)))

(test "smart-boundo-2"
  (run* (q) (boundo '(lambda (w) (((lambda (z) (v (w z))) w) a)) '(w z w)))
  '())

(test "smart-boundo-2b"
  (run* (q) (boundo '(lambda (w) (((lambda (z) (v (w z))) w) a)) '(w z)))
  '())

(test "smart-boundo-3a"
;; This example illustrates the problem with using lists to represent
;; sets.  The first argument to boundo is a list representing an
;; application in the lambda-calculus.  The second argument is a list
;; representing a *set*, yet order matters.
;;
;; However, since there are no duplicates in the sets, we can use the
;; trick of using a length-instantiated list of logic variables +
;; membero to represent the set {z w}.
  (list
    (run* (q) (boundo '(lambda (w) (((lambda (z) (v (w z))) w) a)) '(z w)))
    (run* (q) (boundo '(lambda (w) (((lambda (z) (v (w z))) w) a)) '(w z))))
  '((_.0) ()))

(test "smart-boundo-3b"
;; This example illustrates the problem with using lists to represent
;; sets.  The first argument to boundo is a list representing an
;; application in the lambda-calculus.  The second argument is a list
;; representing a *set*, yet order matters.
;;
;; However, since there are no duplicates in the sets, we can use the
;; trick of using a length-instantiated list of logic variables +
;; membero to represent the set {z w}.
  (list
   (run* (q)
     (fresh (bound a b)
       (== `(,a ,b) bound)
       (membero 'w bound)
       (membero 'z bound)
       (boundo '(lambda (w) (((lambda (z) (v (w z))) w) a)) bound)))
   (run* (q)
     (fresh (bound a b)
       (== `(,a ,b) bound)
       (membero 'z bound)
       (membero 'w bound)
       (boundo '(lambda (w) (((lambda (z) (v (w z))) w) a)) bound))))
  '((_.0) (_.0)))

(test "smart-boundo-4"
;; run 2 diverges
  (run 1 (q)
    (fresh (bound)
      (membero 'w bound)
      (membero 'z bound)
      (boundo '(lambda (w) (((lambda (z) (v (w z))) w) a)) bound)))
  '(_.0))

(test "smart-boundo-5"
  (run 20 (q)
    (fresh (bound a b)
      (== `(,a ,b) bound)
      (membero 'w bound)
      (membero 'z bound)
      (boundo q bound)))
  '((lambda (z) (z (lambda (w) w)))
    (lambda (w) (w (lambda (z) z)))
    (lambda (w) (lambda (z) (z w)))
    (lambda (z) (lambda (w) (w z)))
    ((lambda (z) z) (lambda (w) w))
    ((lambda (w) w) (lambda (z) z))
    ((lambda (_.0) (lambda (w) (lambda (z) (z w)))) (sym _.0))
    ((lambda (_.0) (lambda (z) (lambda (w) (w z)))) (sym _.0))
    ((lambda (w) (lambda (_.0) (lambda (z) (z w))))
     (=/= ((_.0 w))) (sym _.0))
    ((lambda (z) (lambda (_.0) (lambda (w) (w z))))
     (=/= ((_.0 z))) (sym _.0))
    (lambda (z) (lambda (w) (z w)))
    (lambda (w) (lambda (z) (w z)))
    ((lambda (_.0) (lambda (z) (z (lambda (w) w)))) (sym _.0))
    ((lambda (_.0) (lambda (w) (w (lambda (z) z)))) (sym _.0))
    ((lambda (z) (z (lambda (_.0) (lambda (w) w)))) (sym _.0))
    ((lambda (w) (w (lambda (_.0) (lambda (z) z)))) (sym _.0))
    (((lambda (z) z) (lambda (_.0) (lambda (w) w))) (sym _.0))
    (((lambda (w) w) (lambda (_.0) (lambda (z) z))) (sym _.0))
    (lambda (w) ((lambda (z) z) w))
    (lambda (z) ((lambda (w) w) z))))




(define freeo
  (lambda (e out)
    (letrec ((freeo
              (lambda (e bound-vars free-vars-in free-vars-out)
                (matche e
                  (,x (symbolo x)
                      (conde
                        ((== free-vars-in free-vars-out)
                         (membero x bound-vars))
                        ((conde
                           ((== `(,x . ,free-vars-in) free-vars-out)
                            (not-membero x free-vars-in))
                           ((== free-vars-in free-vars-out)
                            (membero x free-vars-in)))
                         (not-membero x bound-vars))))
                  ((lambda (,x) ,body) (symbolo x)
                   (freeo body `(,x . ,bound-vars) free-vars-in free-vars-out))
                  ((,e1 ,e2)
                   (fresh (free-vars-out^)
                     (freeo e1 bound-vars free-vars-in free-vars-out^)
                     (freeo e2 bound-vars free-vars-out^ free-vars-out)))))))
      (freeo e '() '() out))))

(test "smart-freeo-1"
  (run* (q) (freeo '(lambda (w) (((lambda (z) (v (w z))) w) a)) q))
  '((a v)))

(test "smart-freeo-2"
  (run* (q) (freeo '(v a) '(a v)))
  '(_.0))

(test "smart-freeo-3"
;; This example illustrates the problem with using lists to represent sets.
;; The first argument to freeo is a list representing an application in the lambda-calculus.
;; The second argument is a list representing a *set*, in which order matters
  (list
    (run* (q) (freeo '(a v) '(a v)))
    (run* (q) (freeo '(a v) '(v a))))
  '(() (_.0)))

(test "smart-freeo-4"
;; Avoiding the ordering problem in the 'free' "set" using membero and
;; a length-instantiated free list.
  (list
    (run* (q)
      (fresh (free x y)
        (== `(,x ,y) free)
        (membero 'a free)
        (membero 'v free)
        (freeo '(a v) free)))
    (run* (q)
      (fresh (free x y)
        (== `(,x ,y) free)
        (membero 'v free)
        (membero 'a free)
        (freeo '(a v) free))))
  '((_.0) (_.0)))


;; faking sets when running backwards

 (test "smart-freeo-5a"
   ;; "naive"
   (run 10 (q) (freeo q '(a v)))
   '((v a)
     ((v (lambda (_.0) a)) (=/= ((_.0 a))) (sym _.0))
     ((lambda (_.0) (v a)) (=/= ((_.0 a)) ((_.0 v))) (sym _.0))
     (v (v a))
     ((v (lambda (_.0) (lambda (_.1) a)))
      (=/= ((_.0 a)) ((_.1 a))) (sym _.0 _.1))
     (((lambda (_.0) v) a) (=/= ((_.0 v))) (sym _.0))
     (((lambda (_.0) _.0) (v a)) (sym _.0)) (v (a a))
     ((v (lambda (_.0) (_.0 a))) (=/= ((_.0 a))) (sym _.0))
     ((v (v (lambda (_.0) a))) (=/= ((_.0 a))) (sym _.0))))

 (test "smart-freeo-5b"
   ;; "naive", reordered   
   (run 10 (q) (freeo q '(v a)))
   '((a v)
     ((a (lambda (_.0) v)) (=/= ((_.0 v))) (sym _.0))
     ((lambda (_.0) (a v)) (=/= ((_.0 a)) ((_.0 v))) (sym _.0))
     (a (a v))
     ((a (lambda (_.0) (lambda (_.1) v)))
      (=/= ((_.0 v)) ((_.1 v))) (sym _.0 _.1))
     (((lambda (_.0) a) v) (=/= ((_.0 a))) (sym _.0))
     (((lambda (_.0) _.0) (a v)) (sym _.0)) (a (v v))
     ((a (lambda (_.0) (_.0 v))) (=/= ((_.0 v))) (sym _.0))
     ((a (a (lambda (_.0) v))) (=/= ((_.0 v))) (sym _.0))))

 (test "smart-freeo-5c"
   ;; faking sets
   (run 10 (q)
     (fresh (free x y)
       (== `(,x ,y) free)
       (membero 'a free)
       (membero 'v free)
       (freeo q free)))
   '((v a)
     (a v)
     ((v (lambda (_.0) a)) (=/= ((_.0 a))) (sym _.0))
     ((a (lambda (_.0) v)) (=/= ((_.0 v))) (sym _.0))
     ((lambda (_.0) (v a)) (=/= ((_.0 a)) ((_.0 v))) (sym _.0))
     ((lambda (_.0) (a v)) (=/= ((_.0 a)) ((_.0 v))) (sym _.0))
     (v (v a))
     (a (a v))
     ((v (lambda (_.0) (lambda (_.1) a)))
      (=/= ((_.0 a)) ((_.1 a))) (sym _.0 _.1))
     ((a (lambda (_.0) (lambda (_.1) v)))
      (=/= ((_.0 v)) ((_.1 v))) (sym _.0 _.1))))

 (test "smart-freeo-5d"
   ;; faking sets, reordered
   (run 10 (q)
     (fresh (free x y)
       (== `(,x ,y) free)
       (membero 'v free)
       (membero 'a free)
       (freeo q free)))
   '((a v)
     (v a)
     ((a (lambda (_.0) v)) (=/= ((_.0 v))) (sym _.0))
     ((v (lambda (_.0) a)) (=/= ((_.0 a))) (sym _.0))
     ((lambda (_.0) (a v)) (=/= ((_.0 a)) ((_.0 v))) (sym _.0))
     ((lambda (_.0) (v a)) (=/= ((_.0 a)) ((_.0 v))) (sym _.0))
     (a (a v))
     (v (v a))
     ((a (lambda (_.0) (lambda (_.1) v)))
      (=/= ((_.0 v)) ((_.1 v))) (sym _.0 _.1))
     ((v (lambda (_.0) (lambda (_.1) a)))
      (=/= ((_.0 a)) ((_.1 a))) (sym _.0 _.1))))

;; this smarter definition of freeo doesn't generate duplicate answers
 (test "smart-freeo-6"
   (run* (q) (freeo '(w (v w)) q))
   '((v w)))


;; combine freeo and boundo into one relation
(define free/boundo
  (lambda (e free bound)
    (letrec ((free/boundo
              (lambda (e bound-vars free-vars-in bound-vars-in free-vars-out bound-vars-out)
                (matche e
                  (,x (symbolo x)
                      (conde
                        ((== free-vars-in free-vars-out)
                         (conde
                           ((== `(,x . ,bound-vars-in) bound-vars-out)
                            (not-membero x bound-vars-in))
                           ((== bound-vars-in bound-vars-out)
                            (membero x bound-vars-in)))
                         (membero x bound-vars))
                        ((== bound-vars-in bound-vars-out)
                         (conde
                           ((== `(,x . ,free-vars-in) free-vars-out)
                            (not-membero x free-vars-in))
                           ((== free-vars-in free-vars-out)
                            (membero x free-vars-in)))
                         (not-membero x bound-vars))))
                  ((lambda (,x) ,body) (symbolo x)
                   (free/boundo body `(,x . ,bound-vars) free-vars-in bound-vars-in free-vars-out bound-vars-out))
                  ((,e1 ,e2)
                   (fresh (free-vars-out^ bound-vars-out^)
                     (free/boundo e1 bound-vars free-vars-in bound-vars-in free-vars-out^ bound-vars-out^)
                     (free/boundo e2 bound-vars free-vars-out^ bound-vars-out^ free-vars-out bound-vars-out)))))))
      (free/boundo e '() '() '() free bound))))

(test "free/boundo-1"
  (run* (q)
    (fresh (free bound)
      (free/boundo '(w (v w)) free bound)
      (== `(,free ,bound) q)))
  '(((v w) ())))

(test "free/boundo-2"
  (run* (q)
    (fresh (free bound)
      (free/boundo '(lambda (w) (w (v w))) free bound)
      (== `(,free ,bound) q)))
  '(((v) (w))))

(test "free/boundo-3"
  (run* (q)
    (fresh (free bound)
      (free/boundo '(w (lambda (w) (w (v w)))) free bound)
      (== `(,free ,bound) q)))
  '(((v w) (w))))

(test "free/boundo-4"
  (run 10 (q)
    (fresh (bound a b)
      (== `(,a ,b) bound)
      (membero 'v bound)
      (membero 'w bound)
      (free/boundo q '() bound)))
  '((lambda (w) (w (lambda (v) v)))
    (lambda (v) (v (lambda (w) w)))
    ((lambda (w) w) (lambda (v) v))
    ((lambda (v) v) (lambda (w) w))
    (lambda (v) (lambda (w) (w v)))
    (lambda (w) (lambda (v) (v w)))
    (lambda (w) (lambda (v) (w v)))
    (lambda (v) (lambda (w) (v w)))
    ((lambda (w) (w (lambda (_.0) (lambda (v) v)))) (sym _.0))
    ((lambda (v) (v (lambda (_.0) (lambda (w) w)))) (sym _.0))))

;; Generate lambda-calculus expressions in which the only variables
;; that occur bound are v and w, and the only variable that occurs
;; free is w.
(test "free/boundo-5"
  (run 20 (q)
    (fresh (bound free a b c)
      (== `(,a ,b) bound)
      (== `(,c) free)
      (membero 'v bound)
      (membero 'w bound)
      (membero 'w free)
      (free/boundo q free bound)))
  '((w (lambda (w) (w (lambda (v) v))))
    (w (lambda (v) (v (lambda (w) w))))
    ((lambda (w) w) (w (lambda (v) v)))
    ((lambda (v) v) (w (lambda (w) w)))
    (lambda (v) (v (w (lambda (w) w))))
    (w (lambda (v) (lambda (w) (w v))))
    (w (lambda (w) (lambda (v) (v w))))
    ((lambda (w) w) (lambda (v) (w v)))
    (w (lambda (w) (lambda (v) (w v))))
    (w (lambda (v) (lambda (w) (v w))))
    (((lambda (w) w) (w (lambda (_.0) (lambda (v) v))))
     (sym _.0))
    (((lambda (v) v) (w (lambda (_.0) (lambda (w) w))))
     (sym _.0))
    ((w (lambda (w) (w (lambda (_.0) (lambda (v) v)))))
     (sym _.0))
    ((w (lambda (v) (v (lambda (_.0) (lambda (w) w)))))
     (sym _.0))
    (lambda (v) (w (v (lambda (w) w))))
    ((w (lambda (_.0) (lambda (w) (w (lambda (v) v)))))
     (sym _.0))
    ((w (lambda (_.0) (lambda (v) (v (lambda (w) w)))))
     (sym _.0))
    ((lambda (v) (v (w (lambda (_.0) (lambda (w) w)))))
     (sym _.0))
    (w ((lambda (w) w) (lambda (v) v)))
    (w ((lambda (v) v) (lambda (w) w)))))

(test "free/boundo-6"
  (run 20 (q)
    (fresh (bound free a b c* d e*)
      (== `(,a ,b . ,c*) bound)
      (== `(,d . ,e*) free)
      (membero 'v bound)
      (membero 'w bound)
      (membero 'w free)
      (free/boundo q free bound)))
  '((w (lambda (w) (w (lambda (v) v))))
    ((lambda (w) w) (w (lambda (v) v)))
    (w (lambda (v) (lambda (w) (w v))))
    ((lambda (w) w) (lambda (v) (w v)))
    (w (lambda (w) (lambda (v) (w v))))
    (((lambda (w) w) (w (lambda (_.0) (lambda (v) v))))
     (sym _.0))
    ((w (lambda (w) (w (lambda (_.0) (lambda (v) v)))))
     (sym _.0))
    ((w (lambda (_.0) (lambda (w) (w (lambda (v) v)))))
     (sym _.0))
    (w ((lambda (w) w) (lambda (v) v)))
    (((lambda (w) w) (lambda (_.0) (w (lambda (v) v))))
     (=/= ((_.0 w))) (sym _.0))
    (((lambda (w) w) (w (lambda (v) (lambda (_.0) v))))
     (=/= ((_.0 v))) (sym _.0))
    ((w (lambda (w) (w (lambda (v) (lambda (_.0) v)))))
     (=/= ((_.0 v))) (sym _.0))
    ((w (lambda (_.0) (lambda (v) (lambda (w) (w v)))))
     (sym _.0))
    (lambda (v) (w (lambda (w) (w v))))
    (((lambda (w) w) (lambda (v) (w (lambda (_.0) v))))
     (=/= ((_.0 v))) (sym _.0))
    ((w (lambda (v) (lambda (w) (w (lambda (_.0) v)))))
     (=/= ((_.0 v))) (sym _.0))
    ((w (lambda (v) (lambda (_.0) (lambda (w) (w v)))))
     (=/= ((_.0 v))) (sym _.0))
    (lambda (v) ((lambda (w) w) (w v)))
    (((lambda (w) w) ((lambda (_.0) w) (lambda (v) v)))
     (=/= ((_.0 w))) (sym _.0))
    ((lambda (w) w) (lambda (v) (v w)))))

;; There are countably infinite lambda-calculus expressions in which
;; no variables appear free, and only 'v' appears bound.
(test "free/boundo-7"
  (run 10 (q)
    (fresh (bound a)
      (== `(,a) bound)
      (membero 'v bound)
      (free/boundo q '() bound)))
  '((lambda (v) v)
    ((lambda (_.0) (lambda (v) v)) (sym _.0))
    ((lambda (v) (lambda (_.0) v)) (=/= ((_.0 v))) (sym _.0))
    ((lambda (_.0) (lambda (_.1) (lambda (v) v))) (sym _.0 _.1))
    ((lambda (_.0) (lambda (v) (lambda (_.1) v))) (=/= ((_.1 v))) (sym _.0 _.1))
    ((lambda (v) (lambda (_.0) (lambda (_.1) v))) (=/= ((_.0 v)) ((_.1 v))) (sym _.0 _.1))
    (lambda (v) (v v))
    ((lambda (_.0) (lambda (_.1) (lambda (_.2) (lambda (v) v)))) (sym _.0 _.1 _.2))
    ((lambda (_.0) (lambda (_.1) (lambda (v) (lambda (_.2) v)))) (=/= ((_.2 v))) (sym _.0 _.1 _.2))
    (lambda (v) (v (lambda (v) v)))))

;; Generate expressions with no bound variables, and in which 'w' must
;; occur free (and other variables might also occur free.)
(test "free/boundo-8"
  (run 10 (q)
    (fresh (free a b*)
      (== `(,a . ,b*) free)
      (membero 'w free)
      (free/boundo q free '())))
  '(w
    ((lambda (_.0) w) (=/= ((_.0 w))) (sym _.0))
    ((lambda (_.0) (lambda (_.1) w)) (=/= ((_.0 w)) ((_.1 w)))
     (sym _.0 _.1))
    (w w)
    ((_.0 w) (=/= ((_.0 w))) (sym _.0))
    ((w _.0) (=/= ((_.0 w))) (sym _.0))
    ((lambda (_.0) (lambda (_.1) (lambda (_.2) w)))
     (=/= ((_.0 w)) ((_.1 w)) ((_.2 w))) (sym _.0 _.1 _.2))
    ((w (lambda (_.0) w)) (=/= ((_.0 w))) (sym _.0))
    ((_.0 (lambda (_.1) w)) (=/= ((_.0 w)) ((_.1 w)))
     (sym _.0 _.1))
    ((w (lambda (_.0) _.1)) (=/= ((_.0 _.1)) ((_.1 w)))
     (sym _.0 _.1))))

;; Generate expressions in which exactly one variable occurs free, and
;; exactly two variables occur bound.  The variable occurring free
;; could overlap with one of the variables occuring bound.
(test "free/boundo-9"
  (run 10 (q)
    (fresh (e free a bound b c)
      (== `(,a) free)
      (== `(,b ,c) bound)
      (free/boundo e free bound)
      (== `(e: ,e f: ,free b: ,bound) q)))
  '(((e: (_.0 (lambda (_.1) (_.1 (lambda (_.2) _.2))))
      f: (_.0)
      b: (_.2 _.1))
     (=/= ((_.1 _.2))) (sym _.0 _.1 _.2))
    ((e: ((lambda (_.0) _.0) (_.1 (lambda (_.2) _.2)))
      f: (_.1)
      b: (_.2 _.0))
     (=/= ((_.0 _.2))) (sym _.0 _.1 _.2))
    ((e: (lambda (_.0) (_.0 (_.1 (lambda (_.2) _.2))))
      f: (_.1)
      b: (_.2 _.0))
     (=/= ((_.0 _.1)) ((_.0 _.2))) (sym _.0 _.1 _.2))
    ((e: (_.0 (lambda (_.1) (lambda (_.2) (_.2 _.1))))
      f: (_.0)
      b: (_.1 _.2))
     (=/= ((_.1 _.2))) (sym _.0 _.1 _.2))
    ((e: ((lambda (_.0) _.0) (lambda (_.1) (_.2 _.1)))
      f: (_.2)
      b: (_.1 _.0))
     (=/= ((_.0 _.1)) ((_.1 _.2))) (sym _.0 _.1 _.2))
    ((e: (_.0 (lambda (_.1) (lambda (_.2) (_.1 _.2))))
      f: (_.0)
      b: (_.2 _.1))
     (=/= ((_.1 _.2))) (sym _.0 _.1 _.2))
    ((e: (lambda (_.0) (_.0 (lambda (_.1) (_.2 _.1))))
      f: (_.2)
      b: (_.1 _.0))
     (=/= ((_.0 _.1)) ((_.0 _.2)) ((_.1 _.2)))
     (sym _.0 _.1 _.2))
    ((e: ((lambda (_.0) _.0) (_.1 (lambda (_.2) (lambda (_.3) _.3))))
      f: (_.1)
      b: (_.3 _.0))
     (=/= ((_.0 _.3))) (sym _.0 _.1 _.2 _.3))
    ((e: (_.0 (lambda (_.1) (_.1 (lambda (_.2) (lambda (_.3) _.3)))))
      f: (_.0)
      b: (_.3 _.1))
     (=/= ((_.1 _.3))) (sym _.0 _.1 _.2 _.3))
    ((e: (lambda (_.0) (_.1 (_.0 (lambda (_.2) _.2))))
      f: (_.1)
      b: (_.2 _.0))
     (=/= ((_.0 _.1)) ((_.0 _.2))) (sym _.0 _.1 _.2))))

;; Verify that free and bound variables can overlap.
(test "free/boundo-10"
  (run* (q)
    (fresh (free a bound b c)
      (== `(,a) free)
      (== `(,b ,c) bound)
      (free/boundo '(w (lambda (x) (lambda (w) (x w)))) free bound)
      (== `(f: ,free b: ,bound) q)))
  '((f: (w) b: (w x))))

;; Generate expressions in which free and bound variables overlap.
(test "free/boundo-11"
  (run 10 (q)
    (fresh (e free a bound b c)
      (== `(,a) free)
      (== `(,b ,c) bound)
      (free/boundo e free bound)
      (membero a bound)
      (== `(e: ,e f: ,free b: ,bound) q)))
  '(((e: (_.0 (lambda (_.1) (_.1 (lambda (_.0) _.0))))
      f: (_.0)
      b: (_.0 _.1))
     (=/= ((_.0 _.1))) (sym _.0 _.1))
    ((e: (_.0 (lambda (_.0) (_.0 (lambda (_.1) _.1))))
      f: (_.0)
      b: (_.1 _.0))
     (=/= ((_.0 _.1))) (sym _.0 _.1))
    ((e: ((lambda (_.0) _.0) (_.1 (lambda (_.1) _.1)))
      f: (_.1)
      b: (_.1 _.0))
     (=/= ((_.0 _.1))) (sym _.0 _.1))
    ((e: ((lambda (_.0) _.0) (_.0 (lambda (_.1) _.1)))
      f: (_.0)
      b: (_.1 _.0))
     (=/= ((_.0 _.1))) (sym _.0 _.1))
    ((e: (lambda (_.0) (_.0 (_.1 (lambda (_.1) _.1))))
      f: (_.1)
      b: (_.1 _.0))
     (=/= ((_.0 _.1))) (sym _.0 _.1))
    ((e: (_.0 (lambda (_.0) (lambda (_.1) (_.1 _.0))))
      f: (_.0)
      b: (_.0 _.1))
     (=/= ((_.0 _.1))) (sym _.0 _.1))
    ((e: (_.0 (lambda (_.1) (lambda (_.0) (_.0 _.1))))
      f: (_.0)
      b: (_.1 _.0))
     (=/= ((_.0 _.1))) (sym _.0 _.1))
    ((e: ((lambda (_.0) _.0) (lambda (_.1) (_.0 _.1)))
      f: (_.0)
      b: (_.1 _.0))
     (=/= ((_.0 _.1))) (sym _.0 _.1))
    ((e: (_.0 (lambda (_.1) (lambda (_.0) (_.1 _.0))))
      f: (_.0)
      b: (_.0 _.1))
     (=/= ((_.0 _.1))) (sym _.0 _.1))
    ((e: (_.0 (lambda (_.0) (lambda (_.1) (_.0 _.1))))
      f: (_.0)
      b: (_.1 _.0))
     (=/= ((_.0 _.1))) (sym _.0 _.1))))

;; Generate expressions in which free and bound variables *cannot* overlap.
(test "free/boundo-12"
  (run 10 (q)
    (fresh (e free a bound b c)
      (== `(,a) free)
      (== `(,b ,c) bound)
      (=/= a b)
      (=/= a c)
      (free/boundo e free bound)
      (== `(e: ,e f: ,free b: ,bound) q)))
  '(((e: (_.0 (lambda (_.1) (_.1 (lambda (_.2) _.2))))
      f: (_.0)
      b: (_.2 _.1))
     (=/= ((_.0 _.1)) ((_.0 _.2)) ((_.1 _.2)))
     (sym _.0 _.1 _.2))
    ((e: ((lambda (_.0) _.0) (_.1 (lambda (_.2) _.2)))
      f: (_.1) 
      b: (_.2 _.0))
     (=/= ((_.0 _.1)) ((_.0 _.2)) ((_.1 _.2)))
     (sym _.0 _.1 _.2))
    ((e: (lambda (_.0) (_.0 (_.1 (lambda (_.2) _.2)))) 
      f: (_.1)
      b: (_.2 _.0))
     (=/= ((_.0 _.1)) ((_.0 _.2)) ((_.1 _.2)))
     (sym _.0 _.1 _.2))
    ((e: (_.0 (lambda (_.1) (lambda (_.2) (_.2 _.1))))
      f: (_.0)
      b: (_.1 _.2))
     (=/= ((_.0 _.1)) ((_.0 _.2)) ((_.1 _.2)))
     (sym _.0 _.1 _.2))
    ((e: ((lambda (_.0) _.0) (lambda (_.1) (_.2 _.1)))
      f: (_.2)
      b: (_.1 _.0))
     (=/= ((_.0 _.1)) ((_.0 _.2)) ((_.1 _.2)))
     (sym _.0 _.1 _.2))
    ((e: (_.0 (lambda (_.1) (lambda (_.2) (_.1 _.2))))
      f: (_.0)
      b: (_.2 _.1))
     (=/= ((_.0 _.1)) ((_.0 _.2)) ((_.1 _.2)))
     (sym _.0 _.1 _.2))
    ((e: (lambda (_.0) (_.0 (lambda (_.1) (_.2 _.1))))
      f: (_.2)
      b: (_.1 _.0))
     (=/= ((_.0 _.1)) ((_.0 _.2)) ((_.1 _.2)))
     (sym _.0 _.1 _.2))
    ((e:
      ((lambda (_.0) _.0)
       (_.1 (lambda (_.2) (lambda (_.3) _.3))))
      f: (_.1)
      b: (_.3 _.0))
     (=/= ((_.0 _.1)) ((_.0 _.3)) ((_.1 _.3)))
     (sym _.0 _.1 _.2 _.3))
    ((e:
      (_.0
       (lambda (_.1) (_.1 (lambda (_.2) (lambda (_.3) _.3)))))
      f: (_.0)
      b: (_.3 _.1))
     (=/= ((_.0 _.1)) ((_.0 _.3)) ((_.1 _.3)))
     (sym _.0 _.1 _.2 _.3))
    ((e: (lambda (_.0) (_.1 (_.0 (lambda (_.2) _.2))))
      f: (_.1)
      b: (_.2 _.0))
     (=/= ((_.0 _.1)) ((_.0 _.2)) ((_.1 _.2)))
     (sym _.0 _.1 _.2))))

;; verify that shadowing is allowed
(test "free/boundo-13"
  (run* (q)
    (fresh (free bound)
      (free/boundo '(lambda (z) (lambda (z) (z w))) free bound)
      (== `(,free ,bound) q)))
  '(((w) (z))))

;; Generate expressions in which 2 variables occur free, 2 occur
;; bound, and the intersection of bound and free variables is at most
;; size 1.
(test "free/boundo-14"
  (run 10 (q)
    (fresh (expr free bound a b c d e)
      (== `(,a ,b) free)
      (== `(,c ,d) bound)
      (=/= a e)
      (membero e bound)
      (free/boundo expr free bound)
      (== `(e: ,expr f: ,free b: ,bound) q)))
  '(((e: ((lambda (_.0) _.0) (_.1 (_.2 (lambda (_.3) _.3))))
      f: (_.2 _.1)
      b: (_.3 _.0))
     (=/= ((_.0 _.3)) ((_.1 _.2)) ((_.2 _.3)))
     (sym _.0 _.1 _.2 _.3))
    ((e: ((lambda (_.0) _.0) (_.1 (_.2 (lambda (_.3) _.3))))
      f: (_.2 _.1)
      b: (_.3 _.0))
     (=/= ((_.0 _.2)) ((_.0 _.3)) ((_.1 _.2)))
     (sym _.0 _.1 _.2 _.3))
    ((e: (_.0 (_.1 (lambda (_.2) (_.2 (lambda (_.3) _.3)))))
      f: (_.1 _.0)
      b: (_.3 _.2))
     (=/= ((_.0 _.1)) ((_.1 _.3)) ((_.2 _.3)))
     (sym _.0 _.1 _.2 _.3))
    ((e: (_.0 (_.1 (lambda (_.2) (_.2 (lambda (_.3) _.3)))))
      f: (_.1 _.0)
      b: (_.3 _.2))
     (=/= ((_.0 _.1)) ((_.1 _.2)) ((_.2 _.3)))
     (sym _.0 _.1 _.2 _.3))
    ((e: (_.0 (_.1 (lambda (_.2) (lambda (_.3) (_.3 _.2)))))
      f: (_.1 _.0)
      b: (_.2 _.3))
     (=/= ((_.0 _.1)) ((_.1 _.2)) ((_.2 _.3)))
     (sym _.0 _.1 _.2 _.3))
    ((e: (_.0 (_.1 (lambda (_.2) (lambda (_.3) (_.3 _.2)))))
      f: (_.1 _.0)
      b: (_.2 _.3))
     (=/= ((_.0 _.1)) ((_.1 _.3)) ((_.2 _.3)))
     (sym _.0 _.1 _.2 _.3))
    ((e: (_.0 (lambda (_.1) (lambda (_.2) (_.2 (_.1 _.3)))))
      f: (_.3 _.0)
      b: (_.1 _.2))
     (=/= ((_.0 _.3)) ((_.1 _.2)) ((_.1 _.3)) ((_.2 _.3)))
     (sym _.0 _.1 _.2 _.3))
    ((e: (_.0 (lambda (_.1) (lambda (_.2) (_.2 (_.1 _.3)))))
      f: (_.3 _.0)
      b: (_.1 _.2))
     (=/= ((_.0 _.3)) ((_.1 _.2)) ((_.1 _.3)) ((_.2 _.3)))
     (sym _.0 _.1 _.2 _.3))
    ((e: (_.0 (lambda (_.1) (_.1 (_.2 (lambda (_.3) _.3)))))
      f: (_.2 _.0)
      b: (_.3 _.1))
     (=/= ((_.0 _.2)) ((_.1 _.2)) ((_.1 _.3)) ((_.2 _.3)))
     (sym _.0 _.1 _.2 _.3))
    ((e: (_.0 (lambda (_.1) (_.1 (_.2 (lambda (_.3) _.3)))))
      f: (_.2 _.0)
      b: (_.3 _.1))
     (=/= ((_.0 _.2)) ((_.1 _.2)) ((_.1 _.3)))
     (sym _.0 _.1 _.2 _.3))))



;; ????  questions
;;
;; Would using sets give up some of the control, or would I keep the same expressive power?
;;
;; not-membero seems like a fine constraint, which should be easy to
;; implement.  What about making membero a constraint?
;;
;; Can these techinques be applied to full environments represented as a-lists?
