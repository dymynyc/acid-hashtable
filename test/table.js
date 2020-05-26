var hexpp = require('hexpp')
var path = require('path')
var memory = Buffer.alloc(65536)

function readString(memory, start) {
  var length = memory.readUInt32LE(start)
  return memory.slice(4+start, 4+start+length).toString()
}
var total = 0
var load = require('acidlisp/require')(__dirname, memory, {
  system: {
    log: function (start) {
      console.error(start, start.toString(16))
      return start
    },
    assert: function (test, string) {
      string = readString(memory, string)
      if(test) console.log('ok '+(++total) ,string)
      else throw new Error('failed:'+string)
    }
  }
})

var tests = load('./table.al')

var passed = 0
for(var k in tests)
  if(/^test_/.test(k)) {
    console.log('# ---', k)
    var s = tests.setup(16)
    try {
      tests[k](s, 16)
      ++passed
    } catch (err) {
      console.log(hexpp(tests.memory.slice(s, 1024)))
      throw err
    }
  }

console.log('# tests', passed, total)
