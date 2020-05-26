
var djb2 = require('acidlisp/require')(__dirname)('./hash')
var tape = require('tape')
var random = require('crypto').randomBytes
var N = 1024*1024

tape('test', function (t) {
  t.equal(djb2.bytes(0, 0), 5381)
  var str = "hello world"
  djb2.memory.write(str, 1024)
  var h = djb2.bytes(1024, str.length)
  console.log(h.toString(16))
  t.ok(h)
  t.end()
})

tape('bytes vs ints', function (t) {
  random(4).copy(djb2.memory, 1024)
  var int = djb2.memory.readUInt32LE(1024)
  var h1 = djb2.bytes(1024, 4)
  var h2 = djb2.int(int)
  t.equal(h1, h2)
  t.end()
})

tape('incremental, null', function (t) {
  var start = Date.now()
  for(var i = 1; i < N; i++) {
    var h = djb2.null()
  }
  console.log('ops/s', N / ((Date.now()-start)/1000))

  t.end()
})


tape('incremental, bytes', function (t) {
  djb2.memory.writeUInt32LE(0, 1024)
  var _h = djb2.bytes(1024, 4)
  var h
  var start = Date.now()
  for(var i = 1; i < N; i++) {
    djb2.memory.writeUInt32LE(i, 1024)
    var h = djb2.bytes(1024, 4)
    if(h === _h) throw new Error('hash collision:'+h+', '+_h+', at:'+i)
    _h = h
  }
  console.log('ops/s', N / ((Date.now()-start)/1000))

  t.end()
})

tape('incremental, ints', function (t) {
  djb2.memory.writeUInt32LE(0, 1024)
  var _h = djb2.int(i)
  var h
  var start = Date.now()
  for(var i = 1; i < N; i++) {
    var h = djb2.int(i)
    if(h === _h) throw new Error('hash collision:'+h+', '+_h+', at:'+i)
    _h = h
  }
  console.log('ops/s', N / ((Date.now()-start)/1000))

  t.end()
})


tape('incremental, inside wasm', function (t) {
  var start = Date.now()
  var h1 = djb2.bench(N)
  console.log('wasmloop: ops/s', N / ((Date.now()-start)/1000))
  var h2 = 0
  var start = Date.now()
  for(var i = 0; i < N; i++)
    h2 = djb2.int(h2)
  console.log('jsloop  : ops/s', N / ((Date.now()-start)/1000))

  var h3 = djb2.bench_bytes(N, 1024, 4)
  console.log('byteloop: ops/s', N / ((Date.now()-start)/1000))

  t.equal(h2, h1)
  t.equal(h3, h1)
  t.end()
})
