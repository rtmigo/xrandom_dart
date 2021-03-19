function mulberry32(a) {
    // https://stackoverflow.com/a/47593316
    return function() {
      var t = a += 0x6D2B79F5;
      t = Math.imul(t ^ t >>> 15, t | 1);
      t ^= t + Math.imul(t ^ t >>> 7, t | 61);
      //return ((t ^ t >>> 14) >>> 0) / 4294967296;
      return ((t ^ t >>> 14) >>> 0);
    }
}

var f = mulberry32(99)
var results = [];
for (var i=0; i<10; ++i)
    results.push(f());

console.log(results);
//console.log(f());
//console.log(f());
//console.log(f());
//console.log(f());