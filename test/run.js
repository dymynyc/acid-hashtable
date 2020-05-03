var path = require('path')
var memory = Buffer.alloc(65536)

function readString(memory, start) {
  var length = memory.readUInt32LE(start)
  return memory.slice(4+start, 4+start+length).toString()
}
var load = require('acidlisp/require')(__dirname, memory, {
  system: {
    log: function (start) {
      process.stdout.write()
      return start
    },
    assert: function (test, string) {
      string = readString(memory, string)
      if(test) console.log('ok:'+string)
      else throw new Error('failed:'+string)
    }

  }
})

var passed = 0

for(var i = 2; i < process.argv.length; i++) {
  console.log('#', process.argv[i])
  var tests = load(process.argv[i])
  for(var k in tests)
    if(/^test/.test(k)) {
      console.log('# --- ', k)
      tests[k]()
      ++passed
  }
}
console.log("passed:", passed)
