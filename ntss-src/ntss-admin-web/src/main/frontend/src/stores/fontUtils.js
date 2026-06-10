// add #10633 【たくしん会】【因島】帳票のフォント問題 高　start
// src/utils/fontUtils.js
export function extractFontsFromSVG(svgText) {
  const fontFamilies = new Set()
  const regex = /font-family\s*:\s*["']?([^;"']+)/gi
  let match
  while ((match = regex.exec(svgText)) !== null) {
    match[1].split(',').forEach(font => {
      fontFamilies.add(font.trim().replace(/['"]/g, ''))
    })
  }
  return Array.from(fontFamilies)
}

export function isFontAvailable(fonts) {
  const testText = "mmmmmmmmmlli│─日本語ｱｲｳｴｵ";
  const testSize = "72px";

  const baseCanvas = document.createElement("canvas");
  const baseCtx = baseCanvas.getContext("2d");
  baseCtx.font = `${testSize} 'Courier New', monospace`;
  const baseWidth = baseCtx.measureText(testText).width;

  const canvas = document.createElement("canvas");
  const ctx = canvas.getContext("2d");

  ctx.font = `${testSize} '${fonts}', '__invalid__'`;
  const width1 = ctx.measureText(testText).width;

  ctx.font = `${testSize} 'Arial'`;
  const arialWidth = ctx.measureText(testText).width;

  ctx.font = `${testSize} '${fonts}', 'Arial'`;
  const width2 = ctx.measureText(testText).width;

  ctx.font = `${testSize} 'Monaco'`;
  const monacoWidth = ctx.measureText(testText).width;
  ctx.font = `${testSize} '${fonts}', 'Monaco'`;
  const width3 = ctx.measureText(testText).width;

  if (navigator.platform.toLowerCase().includes("win")) {
    return (
      (Math.abs(width1 - baseWidth) > 1 &&
        Math.abs(width1 - arialWidth) > 1 &&
        Math.abs(width2 - arialWidth) > 0) ||
      fonts === "Arial" || fonts === "Courier New"
    );
  }

  if (navigator.platform.toLowerCase().includes("mac")) {
    return (
      (Math.abs(width1 - width3) > 1 &&
        Math.abs(width1 - arialWidth) > 1 &&
        Math.abs(width2 - arialWidth) > 0) ||
      fonts === "Arial" || fonts === "Monaco"
    );
  }

  return false;
}

export function replaceUnavailableFonts(svgText, fallbackMap) {
  for (const [font, fallback] of Object.entries(fallbackMap)) {
    const regex = new RegExp(`(font-family\\s*:\\s*['"]?)${font}(['"]?)`, 'gi')
    svgText = svgText.replace(regex, `$1${fallback}$2`)
  }
  return svgText
}

export function findFirstAvailableFont(fontList) {
  for (const font of fontList) {
    if (isFontAvailable(font)) {
      return font
    }
  }
  return null
}
// add #10633 【たくしん会】【因島】帳票のフォント問題 高　start
