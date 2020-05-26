(module
  (def mem (import "acid-memory"))
  (def reducers (import "acid-reducers"))
  (def log (system "system" "log" (data)))

  (def get_size    (fun (ht)     (i32_load  (add 0 ht)) ))
  (def get_parent  (fun (ht)     (i32_load  (add 4 ht)) ))
  (def get_entries (fun (ht)     (i32_load  (add 8 ht)) ))

  (def set_size    (fun (ht val) (i32_store (add 0 ht) val) ))
  (def set_parent  (fun (ht val) (i32_store (add 4 ht) val) ))
  (def set_entries (fun (ht val) (i32_store (add 8 ht) val) ))

  (def create (fun (size parent) (block
    (def table (mem.alloc (add 12 (mul 8 size))))
    (set_size    table size)
    (set_parent  table parent)
    (set_entries table 0)
    table
  )))

  ;; pass in size so we don't reload it every time
  (def kslot (fun (table key size)
    (add table 12 (mul 8 (mod key size)))
  ))
  (def vslot (fun (table key size)
    (add 4 (kslot table key size))
  ))

  ;; Okay, first take on this used macros.
  ;; rewriting with functions, I think the best
  ;; is approach is to pass a function to find,
  ;; that gets called at the end with the slot, key, and values.
  ;; then it can set or return the value.
  ;; of course it gets inlined so it's as fast as the macro.
  ;; but doesn't rely on weird macro stuff.

  (def find (fun (table key found)
    (block
      (def size (get_size table))
      (found
        (reducers.while key (fun (_key)
          (block
            (def k (i32_load (kslot table _key size) ))
            (and (neq key k) (neq 0 k))
          )))
        size)
    )
  ))

  ;; note, this does an extra read the key slot.
  (def has_key (fun (table key) {block
    (find table key (fun (i size)
      (eq key (i32_load (kslot table i size)))
    ))
  }))

  (def get_key (fun (table key)
    (find table key (fun (i size)
      (i32_load (vslot table i size))
    )) ))

  (def set_key (fun (table key value)
    (find table key (fun (i size)
      (block
        (def slot (kslot table i size))
        ;;if it's a new record, increase entries and store key.
        (if
          (eqz (i32_load (add 4 slot)))
          (block
            (set_entries table (add 1 (get_entries table)))
          )
        )
        (log 999999)
        (log slot)
        (log (i32_load slot))
;;        (log (kslot table i size))
        (i32_store slot key)
        (i32_store (add 4 slot) value)
      ) )) ))

  (export create create)
  (export get get_key)
  (export set set_key)
  (export has has_key)

  ;;there is something wrong with macros.
  ;;this macro doesn't work right (can't resolve get_key etc)
  ;;if imported into another module.
  ;;hmm, also, it's annoying that function names are replaced
  ;;in the wasm. I'm sure that these are related.

;;  (export set_if   ;;macro that sets returns current value or sets
;;    (mac (table key value) &(block
;;      (def k $key) ;;define k so we don't re-eval $key
;;      (if (has_key $table k)
;;        (get_key $table k)
;;        (set_key $table k $value) ) ;;not $value only runs if has fails
;;    )))

  (export get_entries (fun (table) (get_entries table)))
)
