var path = require('path')
var memory = Buffer.alloc(65536)

function readString(memory, start) {
  var length = memory.readUInt32LE(start)
  return memory.slice(4+start, 4+start+length).toString()
}
var total = 0
var load = require('acidlisp/require')(process.cwd(), memory, {
  system: {
    log: function (start) {
      process.stdout.write()
      return start
    },
    assert: function (test, string) {
      string = readString(memory, string)
      if(test) console.log('ok '+(++total) ,string)
      else throw new Error('failed:'+string)
    }

  }
})

var passed = 0

var name
try {
  name = require('./package.json').name
} catch (_) {}

for(var i = 2; i < process.argv.length; i++) {
  console.log('#', name, process.argv[i])
  var tests = load(process.argv[i])
  var found = false
  for(var k in tests) {
    if(/^test/.test(k)) {
      found ++
      console.log('# --- ', k)
      tests[k]()
      ++passed
    }
  }
  if(!found)
    console.log("# ... no test functions")
}
console.log("# tests "+total)
console.log("# files "+ passed)
