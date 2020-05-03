(module
  ;;this would be a good candidate for unrolling.
  ;;in the cases where you know the length
  (export bytes (fun (start len)
    (block
      ;; if the length is 4, load as an int
      (def hash 5381)
      (def i 0)
      (loop (lt i len)
        (block
          ;; usually implemented as hash << 5 + hash
          ;; but this is the same perf (I measured it) in wasm
          (set hash (add (mul hash 33) (i32_load8 (add start i)) ))
          (set i (add i 1))
      ))
      hash
    )
  ))

  ;;this is quite a bit faster, if you are hashing an int.
  (export int (fun (i) {block
    ;;(def hash 5381)

    ;; this way resets the same local value. it's 1.3 times faster
    ;; (precomputing the first multiply makes it 1.03 times faster
    ;; since we know we are hashing 4 bytes we can do that)
    (def hash (add       177573  (and      i     255)))
    (set hash (add (mul hash 33) (and (shr i  8) 255)))
    (set hash (add (mul hash 33) (and (shr i 16) 255)))
              (add (mul hash 33) (and (shr i 24) 255))

    ;; this method, is the same, but it's slower!!!
    ;; the difference is that it's it's all stack.
    ;; seems very interesting that a local var would be faster
    ;; than the stack! I wonder if rewriting it in single assignmet
    ;; form would be even faster?

    ;; (mul 33 [add (and (shr i 24) 255)
    ;; (mul 33 [add (and (shr i 16) 255)
    ;; (mul 33 [add (and (shr i  8) 255)
    ;; (mul 33 [add (and      i     255)
    ;; (mul 33 hash) ]) ]) ]) ])

    ;;I tried writing it with (mul hash 33) separate
    ;;and it was 1.011 times faster.  not worth it.
    ;;it doesn't actually need to be _that_ fast.
  }))

)
