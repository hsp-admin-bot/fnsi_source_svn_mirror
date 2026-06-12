import { parse } from "csv-parse/browser/esm";

// Vue2 側の csv-parse 利用は callback 形式を前提にしている。
// browser ESM 入口に固定し、Vite browser build で Node stream へ外部化されないようにする。
export { parse };
export default parse;
