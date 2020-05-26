
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

var ht = load('../')

var t = ht.create(16, 0)
console.log(t)

ht.set(t, 1, 0xff)
console.log("set 17")
ht.set(t, 17, 0xee)
console.log("SET DONE")

console.log(hexpp(ht.memory.slice(t, t+12+16*8)))
