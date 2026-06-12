import qs from "qs";

export function stringify(value, options) {
  return qs.stringify(value, options);
}

export function parse(value, options) {
  return qs.parse(value, options);
}

export { qs };
export default qs;
