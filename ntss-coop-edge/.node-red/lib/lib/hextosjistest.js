
var commonLib = require('./CommonLib.js');
//var utf8 = 'あいうえお';

//var buf = commonLib.encodeString(utf8, 'shift-jis');

var hex = '';
//var binary = parseInt(hex, 16).toString(2);

var buf = Buffer.from(hex, 'hex');
console.log(commonLib.decodeBuffer(buf, 'shift-jis'));

//console.log(commonLib.decodeBuffer(binary, 'shift-jis'));
