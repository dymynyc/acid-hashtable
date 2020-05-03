(module
  (def mem (import "acid-memory"))

  (def get_size    (mac (ht)     &(i32_load  (add 0 $ht)) ))
  (def get_parent  (mac (ht)     &(i32_load  (add 4 $ht)) ))
  (def get_entries (mac (ht)     &(i32_load  (add 8 $ht)) ))

  (def set_size    (mac (ht val) &(i32_store (add 0 $ht) $val) ))
  (def set_parent  (mac (ht val) &(i32_store (add 4 $ht) $val) ))
  (def set_entries (mac (ht val) &(i32_store (add 8 $ht) $val) ))

  (def create (fun (size parent) (block
    (def table (mem.alloc (add 12 (mul 2 size))))
    (set_size    table size)
    (set_parent  table parent)
    (set_entries table 0)
    table
  )))

  ;; pass in size so we don't reload it every time
  (def kslot (mac (table key size)
    &(add $table 12 (mul 8 (mod $key $size)))
  ))
  ;; pass in size so we don't reload it every time
  (def vslot (mac (table key size)
    &(add 4 (kslot $table $key $size))
  ))

  (def find (mac (table key k) &{block
    (def _key $key)
    (def size (get_size table))
    (loop
      (block
        (def $k (i32_load (kslot table _key size)) )
        (and
          (neq $key $k) ;; if we find something matching the key, stop we are there
          (neq 0 $k))  ;; if we find something matching zero, stop we don't have it
      )
      (set _key (add _key 2))
    )
    _key
;;    (if (eq k $key) _key 0)
  }))

  (def has_key (fun (table key) {block
    (def k 0)
    (find table key k)
    (neq 0 k)
  }))

  (def get_key (fun (table key) (block
    (def k 0)
    (def _key (find table key k))
    (if (neq 0 k)
      (i32_load (vslot table _key (get_size table)))
      ;;(if (get_parent table) (get_key (get_parent key)))
    )
  )))

  (def set_key (fun (table key value) (block
    (def k 0)
    (def _key (find table key k))
    ;;store key, value next to each other
    (def size (get_size table))

    ;;this reads the key slot again.
    ;; to make this faster i'd need to inline find.
    (if (eq 0 (i32_load (kslot table _key size)))
      (set_entries table (add 1 (get_entries table)))
    )
    (i32_store (kslot table _key size) key)
    (i32_store (vslot table _key size) value)

    ;;idiom: sets return the value set
    ;;(or is it better to return the object?
    ;;maybe useful in the case where we need to embiggen
    ;;the object)
    _key
    ;;value
  )))

  (export create create)
  (export get get_key)
  (export set set_key)
  (export has has_key)

  (export get_entries (fun (table) (get_entries table)))
)
