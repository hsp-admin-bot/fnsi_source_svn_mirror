import * as pdfjsLib from "pdfjs-dist";
import workerSrc from "pdfjs-dist/build/pdf.worker.mjs?url";

// pdfjs-dist 2.x の webpack 入口との差異を Vue3/Vite 側で吸収します。
if (pdfjsLib?.GlobalWorkerOptions && !pdfjsLib.GlobalWorkerOptions.workerSrc) {
  pdfjsLib.GlobalWorkerOptions.workerSrc = workerSrc;
}

export * from "pdfjs-dist";

export function getDocument(source) {
  return pdfjsLib.getDocument(source);
}

export { pdfjsLib };
export default pdfjsLib;
