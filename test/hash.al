(module
  (def djb2 (import "../djb2"))
  (def reducers (import "acid-reducers"))
  ;;the following are just for benchmarking.
  ;;don't actually use them obviously

  (export int djb2.int)

  (export bytes djb2.bytes)

  (export null (fun () 5381))

  (export bench (fun (n)
    (reducers.range 0 n 0 (fun (acc i) (djb2.int acc)))
  ))

  (export bench_bytes (fun (n p) (block
    (i32_store p 0)
    (reducers.range 0 (sub n 1) 0 (fun (acc i) (i32_store p (djb2.bytes p 4))))
  )))
)
