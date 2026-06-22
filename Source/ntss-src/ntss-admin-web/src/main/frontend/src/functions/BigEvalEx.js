/**
 * eval()の代替として計算式を実行するライブラリBigEvalで
 * 小数を計算するためにbignumber.jsを使用するためのラッパークラス
 * 使い方はBigEvalに準拠
 */

import BigNumber from "@/compat/number/bignumber";
import BigEval from "@/compat/number/bigeval";

let _bigNum = BigNumber;
let _bigEval = BigEval;

function p(s) {
  return s[0] == "+" ? s.substr(1) : s;
}

// override methods

_bigEval.prototype.number = function(str) {
  return str instanceof BigNumber ? str : new BigNumber(str);
};

_bigEval.prototype.add = function(a, b) {
  return new _bigNum(p(a)).plus(p(b));
};

_bigEval.prototype.sub = function(a, b) {
  return new _bigNum(p(a)).minus(p(b));
};

_bigEval.prototype.mul = function(a, b) {
  return new _bigNum(p(a)).times(p(b));
};

_bigEval.prototype.div = function(a, b) {
  return new _bigNum(p(a)).dividedBy(p(b));
};

_bigEval.prototype.pow = function(a, b) {
  return new _bigNum(p(a)).pow(p(b));
};

_bigEval.prototype.lessThan = function(a, b) {
  return a.lessThan(b);
};

_bigEval.prototype.lessThanOrEqualsTo = function(a, b) {
  return a.lessThanOrEqualTo(b);
};

_bigEval.prototype.greaterThan = function(a, b) {
  return a.greaterThan(b);
};

_bigEval.prototype.greaterThanOrEqualsTo = function(a, b) {
  return a.greaterThanOrEqualTo(b);
};

_bigEval.prototype.equalsTo = function(a, b) {
  return a.equals(b);
};

_bigEval.prototype.notEqualsTo = function(a, b) {
  return !a.equals(b);
};

_bigEval.prototype.isTruthy = function(a) {
  return !a.equals(0);
};

_bigEval.prototype.logicalAnd = function(a, b) {
  if (!a || (a instanceof BigNumber && a.equals(0))) return a;

  return b;
};

_bigEval.prototype.logicalOr = function(a, b) {
  if (!a || (a instanceof BigNumber && a.equals(0))) return b;

  return a;
};

_bigEval.prototype.mod = function(a, b) {
  return new _bigNum(p(a)).modulo(p(b));
};

_bigEval.prototype.shiftLeft = function(a, b) {
  return a << b;
};

_bigEval.prototype.shiftRight = function(a, b) {
  return a >> b;
};

_bigEval.prototype.and = function(a, b) {
  return a & b;
};

_bigEval.prototype.xor = function(a, b) {
  return a ^ b;
};

_bigEval.prototype.or = function(a, b) {
  return a | b;
};

// Extra methods

_bigEval.prototype.sqrt = function(a) {
  return new _bigNum(p(a)).sqrt();
};

_bigEval.prototype.log = function(a) {
  return new _bigNum(p(a)).log();
};

_bigEval.prototype.ln = function(a) {
  return new _bigNum(p(a)).ln();
};

_bigEval.prototype.exp = function(a) {
  return new _bigNum(p(a)).exp();
};

/*
 * Export module
 */

export default _bigEval;
