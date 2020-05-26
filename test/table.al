(module

  (def ht      (import "acid-hashtable"))
  (def djb2    (import "acid-hashtable/djb2"))
  (def strings (import "acid-strings"))
  (def reducers (import "acid-reducers"))

  (def assert (system "system" "assert" (test string)))
  (def log (system "system" "log" (data)))

  (export setup (fun (size) (ht.create size 0)))

  (def test_ht (fun (t) (block
    (def k (djb2.int 0))
    (def hello "hello world")
    (def goodbye "see you later")

    (assert (eq 0 (ht.get_entries t)) "should be empty")

    (assert (eq (ht.set t k hello) hello) "set returns value")
    (def v (ht.get t k))

    ;; not sure why: if assert is a macro it always crashes
    (assert (eq 0 (strings.compare v "hello world")) "equal values")
    (assert (eq v hello) "equal memory")

    (assert (eq 1 (ht.get_entries t)) "should have 1 entry")
    (def k2 (djb2.int 1))
    (assert (eq 0 (ht.get t k2)) "should be nothing at k2 yet")
    (assert (neq k k2) "keys should not be equal")
    (ht.set t k2 hello)
    (assert (eq 2 (ht.get_entries t)) "should have 2 entries")

    (assert (eq (ht.get t k) (ht.get t k2)) "equal memory")
    (ht.set t k2 goodbye)
    (assert (eq 2 (ht.get_entries t)) "should still have 2 entries")

    (assert (neq (ht.get t k) (ht.get t k2)) "not equal memory")
  )))

  (export test_collision (fun (t size) {block
;;    (def size 16)
;;    (def t (ht.create size 0))
    (def k1 (djb2.int 0))
    (def a "A")
    (def b "B")
;;    (def i 99999)
    ;;find a second key that collides with the first (within table)

  ;;    (reducers.until 100 1 (fun (acc i)
  ;;        (neq (mod k1 size) (mod (djb2.int i) size))
  ;;    ))

    (def _k2 
      ((fun R (j)
        (if (neq (mod k1 size) (mod (djb2.int j) size))
          (R (add 1 j)) j)
      ) 1)
    )
;;    (log _k2)
;;    (log (djb2.int 16))
;;    (log (djb2.int 0))
    (def k2 (djb2.int _k2))

;;    (log 6666)
;;    (log k1)
;;    (log k2)
;;    (log 9999)
;;    (log (mod k1 size))
;;    (log (mod k2 size))
;;    (log 3333)
;;    (log a)
;;    (log b)
;;    (log 1111)

    (assert (neq k1 k2) "keys should not actually collide")
    (assert (eq (mod k1 size) (mod k2 size)) "(mod key size) should collide")

    (ht.set t k1 a)
    (assert (ht.has t k1) "hash table has k1")
    (assert (eq a (ht.get t k1)) "get colliding key k1")
    (assert (eq 0 (ht.has t k2)) "hash table doesn't have k2")
;;    (ht.set t k1 b)
    ;;(assert (eq b (ht.get t k1)) "overwrite k1:a")
  ;;  (ht.set t k1 a)
    (ht.set t k2 b)
;;    (assert 0 "fail")

    (assert (eq b (ht.set t k2 b)) "set colliding key")
    (assert (eq a (ht.get t k1)) "get colliding key k1")
    (assert (eq b (ht.get t k2)) "get colliding key k2")
    (assert (ht.has t k2) "hash table has k1, after set")
    (assert (ht.has t k2) "hash table has k2, after set")
  }))

  (def set_if (fun (table key value)
    (if (ht.has table key)
      (ht.get table key)
      (ht.set table key value) ) ;;note $value only runs if has fails
  ))

  (def test_set_if (fun (t) {block
    (def k (djb2.int 100))
    (def a "A")
    (def b "B")
    ;;find a second key that collides with the first (within table)
    (assert (eq 0 (ht.has t k)) "initially unset")
    (assert (eq a (set_if t k a)) "set_if sets if unset")
    (assert (eq a (ht.get t k)) "get after set_if set")
    (assert (eq 1 (ht.has t k)) "has after set_if set")
    (assert (eq a (set_if t k b)) "reset doesn\'t set")
    (assert (eq a (ht.get t k)) "still the same")
  }))

  (def test_has (fun (t k)
    (ht.has t 1)
  ))
)
