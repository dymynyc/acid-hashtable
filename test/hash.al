(module
  (def djb2 (import "../djb2"))
  ;;the following are just for benchmarking.
  ;;don't actually use them obviously

  (export int djb2.int)

  (export bytes djb2.bytes)

  (export null (fun () 5381))

  (export bench (fun (n) (block
    (def i 0)
    (def h 0)
    (loop (lt i n) (block
      (set h (djb2.int h))
      (set i (add i 1))
    ))
    h
  )))
  (export bench_bytes (fun (n) (block
    (def i 0)
    (i32_store 1024 0)
    (loop (lt i n) (block
      (i32_store 1024 (djb2.bytes 1024 4))
      (set i (add i 1))
    ))
    (i32_load 1024)
  )))
)
