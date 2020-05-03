(module

  (def ht      (import "acid-hashtable"))
  (def djb2    (import "acid-hashtable/djb2"))
  (def strings (import "acid-strings"))

  (def assert (system "system" "assert" (test string)))

  (export test_ht (fun () (block
    (def t (ht.create 64 0))
    (def k (djb2.int 0))
    (def hello "hello world")
    (def goodbye "see you later")

    (assert (eq 0 (ht.get_entries t)) "should be empty")

    (ht.set t k hello)
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

  (export test_collision (fun () {block
    (def size 64)
    (def t (ht.create 64 0))
    (def k1 (djb2.int 0))
    (def a "A")
    (def b "B")
    (def i 0)
    ;;find a second key that collides with the first (within table)
    (loop (neq
      (mod k1 64)
      (mod [def k2 (djb2.int (set i (add i 1)))] 64)
    ) 0)
    (assert (neq k1 k2) "keys should not actually collide")
    (assert (eq (mod k1 size) (mod k2 size)) "(mod key size) should collide")

    (ht.set t k1 a)
    (assert (ht.has t k1) "hash table has k1")
    (assert (eq 0 (ht.has t k2)) "hash table doesn't have k2")
  }))

)
