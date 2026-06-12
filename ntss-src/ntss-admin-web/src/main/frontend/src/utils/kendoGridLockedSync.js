/**
 * Kendo Grid locked 列 行高同期 polyfill
 *
 * Kendo UI 2019.3 では kendo.grid.js 内に _adjustRowsHeight /
 * _syncLockedContentHeight / _syncLockedHeaderHeight / syncTableHeight が
 * 組み込まれており、dataBound / resize / _render 等の lifecycle 内で
 * locked 列側 <tr> と body 側 <tr> の高さが自動的に揃えられていた。
 *
 * Kendo UI 2026.x ではこの一連のメソッドが削除されたため、locked 列を持つ
 * Grid で行高が左右で不一致になり、行 N が垂直方向にずれて見える不具合が
 * 発生する。本ユーティリティは Kendo 2019 の _adjustRowsHeight と同等の
 * 処理を外部から適用する。
 *
 * 使い方:
 *   import { syncKendoGridLockedRowHeights } from "@/utils/kendoGridLockedSync";
 *
 *   // dataBound や layout 再構成のタイミングで 1 度だけ呼ぶ
 *   syncKendoGridLockedRowHeights(gridWidgetOrRootEl);
 *
 * 設計メモ:
 *  - MutationObserver で継続監視はしない。Kendo 内部の _adjustRowsHeight が
 *    自分で tr.style.height を書き換えるため、style 属性監視はループ要因に
 *    なる。childList のみ監視でも、ホイールでページ遷移を伴うと sync が
 *    レンダリングと取り合って scrollbar が震える事象が観測された。
 *  - 滚轮スクロールが「ページ遷移を伴わない」場合、Kendo は wrapper.scrollTop
 *    を更新するだけで行高さを変更しないため、ここで再 sync する必要も無い。
 *    ページ遷移が起きるときは dataBound が走るので、その経路で 1 度だけ呼べば足りる。
 */

import {
  findKendoGridRoot,
  findKendoGridBodyRows,
  findKendoGridLockedRows,
} from "@/compat/kendo/dom.js";

function resolveRootElement(input) {
  if (!input) {
    return null;
  }
  if (input.wrapper && input.wrapper[0]) {
    return input.wrapper[0];
  }
  if (input.element && input.element[0]) {
    return input.element[0];
  }
  if (input.jquery) {
    return input[0] || null;
  }
  if (input.nodeType === 1) {
    return input;
  }
  return null;
}

function collectRowChildren(parent) {
  if (!parent) {
    return [];
  }
  return Array.from(parent.children).filter((el) => el?.tagName === "TR");
}

function findBodyRowPair(root) {
  const gridRoot = findKendoGridRoot(root) || root;
  const lockedRows = findKendoGridLockedRows(gridRoot);
  const bodyRows = findKendoGridBodyRows(gridRoot);
  if (lockedRows.length === 0 || bodyRows.length === 0) {
    return null;
  }
  return { lockedRows, bodyRows };
}

function findHeaderRowPair(root) {
  const lockedThead = root.querySelector?.(".k-grid-header-locked thead");
  const bodyThead = root.querySelector?.(".k-grid-header-wrap thead")
    || root.querySelector?.(".k-grid-header:not(.k-grid-header-locked) thead");
  if (!lockedThead || !bodyThead) {
    return null;
  }
  const lockedRows = collectRowChildren(lockedThead);
  const bodyRows = collectRowChildren(bodyThead);
  if (lockedRows.length === 0 || bodyRows.length === 0) {
    return null;
  }
  return { lockedRows, bodyRows };
}

function measureRowHeight(row) {
  if (!row) {
    return 0;
  }
  const rect = row.getBoundingClientRect?.();
  const h = (rect && rect.height) || row.offsetHeight || 0;
  return Number.isFinite(h) ? h : 0;
}

/**
 * Kendo 2019/2026 _adjustRowsHeight 相当の処理。
 *
 * パフォーマンスのために 2 段階構成:
 *
 *  [Phase 1: 読み取り専用チェック]
 *   現在の行高さ (inline height 込み) を測定して、全ペアが既に揃っているなら
 *   即 return。clear / write back を一切やらないので reflow を誘発しない。
 *   Kendo 内部の _adjustRowsHeight が既に対齐済みの場合や、ホイール / ドラッグ
 *   スクロールで dataBound が連発する状況でも、ここで早期 return する。
 *
 *  [Phase 2: 差異がある場合のみ Kendo 原版アルゴリズム]
 *   既存 inline height をクリア → 自然高さを再測定 → 大きい方を書き戻す。
 *   一致しているペア (heights[i]===0) には書かないことで、Kendo virtual
 *   scrollable の itemHeight 計算と齟齬を起こさない。
 */
function adjustRowPairHeights(leftRows, rightRows, options = {}) {
  const n = Math.min(leftRows.length, rightRows.length);
  if (n === 0) {
    return false;
  }

  const force = options.force === true;

  // Phase 1: 早期 return できるかどうか先に確認 (read-only)
  const TOLERANCE_PX = 0.5;
  let needAdjust = force;
  if (!needAdjust) {
    for (let i = 0; i < n; i++) {
      const lh = measureRowHeight(leftRows[i]);
      const rh = measureRowHeight(rightRows[i]);
      if (Math.abs(lh - rh) > TOLERANCE_PX) {
        needAdjust = true;
        break;
      }
      // textarea 縮小時: 左右は同じ inline height のままだが実内容は低くなっている
      const hasResizingTextarea = !!rightRows[i].querySelector?.(".resize-obs-target")
        || !!leftRows[i].querySelector?.(".resize-obs-target");
      if (hasResizingTextarea && (leftRows[i].style.height || rightRows[i].style.height)) {
        needAdjust = true;
        break;
      }
    }
  }
  if (!needAdjust) {
    return false;
  }

  // Phase 2: 差異があるペアを揃える
  for (let i = 0; i < n; i++) {
    if (leftRows[i].style.height) {
      leftRows[i].style.height = "";
    }
    if (rightRows[i].style.height) {
      rightRows[i].style.height = "";
    }
  }
  const heights = new Array(n);
  for (let i = 0; i < n; i++) {
    const lh = measureRowHeight(leftRows[i]);
    const rh = measureRowHeight(rightRows[i]);
    if (lh > rh) {
      heights[i] = lh;
    } else if (lh < rh) {
      heights[i] = rh;
    } else {
      heights[i] = 0;
    }
  }
  let changed = false;
  for (let i = 0; i < n; i++) {
    const h = heights[i];
    if (h <= 0) {
      continue;
    }
    const px = `${Math.round(h)}px`;
    if (leftRows[i].style.height !== px) {
      leftRows[i].style.height = px;
      changed = true;
    }
    if (rightRows[i].style.height !== px) {
      rightRows[i].style.height = px;
      changed = true;
    }
  }
  return changed;
}


function firstNonEmptyWidth(...values) {
  for (const value of values) {
    if (typeof value === "string" && value.trim()) {
      return value.trim();
    }
  }
  return "";
}

function sumColgroupWidthsPx(table) {
  if (!table) {
    return 0;
  }
  let sum = 0;
  const cols = Array.from(table.querySelectorAll?.("colgroup col") || []);
  cols.forEach((col) => {
    const styleWidth = col.style?.width || col.getAttribute?.("width") || "";
    const rectWidth = col.getBoundingClientRect?.().width || 0;
    if (styleWidth.endsWith("px")) {
      const px = parseFloat(styleWidth);
      if (Number.isFinite(px)) {
        sum += px;
        return;
      }
    }
    if (rectWidth > 0) {
      sum += rectWidth;
    }
  });
  return Number.isFinite(sum) ? sum : 0;
}

function detectLockedWidth(headerLocked, contentLocked, explicitWidth) {
  if (typeof explicitWidth === "string" && explicitWidth.trim()) {
    return explicitWidth.trim();
  }
  if (typeof explicitWidth === "number" && Number.isFinite(explicitWidth) && explicitWidth > 0) {
    return `${Math.ceil(explicitWidth)}px`;
  }
  const headerTable = headerLocked?.querySelector?.("table");
  const contentTable = contentLocked?.querySelector?.("table");
  const styleWidth = firstNonEmptyWidth(
    headerLocked?.style?.width,
    contentLocked?.style?.width,
    headerTable?.style?.width,
    contentTable?.style?.width,
  );
  if (styleWidth && styleWidth !== "auto") {
    return styleWidth;
  }
  const colWidth = sumColgroupWidthsPx(headerTable) || sumColgroupWidthsPx(contentTable);
  if (colWidth > 0) {
    return `${Math.ceil(colWidth)}px`;
  }
  const rectWidth = headerLocked?.getBoundingClientRect?.().width
    || contentLocked?.getBoundingClientRect?.().width
    || headerTable?.getBoundingClientRect?.().width
    || contentTable?.getBoundingClientRect?.().width
    || 0;
  if (rectWidth > 0) {
    return `${Math.ceil(rectWidth)}px`;
  }
  return "";
}

function applyFixedLockedContainerWidth(element, width) {
  if (!element || !width) {
    return;
  }
  element.style.width = width;
  element.style.minWidth = width;
  element.style.maxWidth = width;
  element.style.flexBasis = width;
  element.style.flexShrink = "0";
  element.style.flexGrow = "0";
  element.style.flex = `0 0 ${width}`;
}

function applyLockedTableWidth(element, width) {
  if (!element || !width) {
    return;
  }
  element.style.width = width;
  element.style.minWidth = width;
}

/**
 * Kendo UI 2019 の locked 列は、算出済み width がそのまま固定領域として維持されていた。
 * Kendo UI 2026 の locked Grid は .k-grid-container 配下の flex item になるため、
 * window resize 時に width が残っていても flex shrink で固定領域が縮む場合がある。
 *
 * HTML を 2019 へ戻すのではなく、Vue2 と同じ「locked 領域は算出済み幅で固定」
 * という layout contract だけを適用する。
 *
 * @param {*} input Kendo Grid widget / jQuery object / root DOM element
 * @param {{ width?: string|number }} [options]
 * @returns {string} 適用した width。適用できない場合は空文字。
 */
export function applyKendoGridLockedWidthContract(input, options = {}) {
  const root = resolveRootElement(input);
  if (!root || typeof root.querySelector !== "function") {
    return "";
  }
  const headerLocked = root.querySelector(".k-grid-header-locked");
  const contentLocked = root.querySelector(".k-grid-content-locked");
  if (!headerLocked && !contentLocked) {
    return "";
  }
  const width = detectLockedWidth(headerLocked, contentLocked, options.width);
  if (!width) {
    return "";
  }
  [headerLocked, contentLocked].forEach((container) => {
    applyFixedLockedContainerWidth(container, width);
    applyLockedTableWidth(container?.querySelector?.("table"), width);
  });
  return width;
}

/**
 * 一度だけ locked 列 行高を同期する
 * @param {*} input Kendo Grid widget / jQuery object / root DOM element
 * @param {{ force?: boolean, skipHeader?: boolean }} [options] force=true のときは常に再測定（textarea 縮小時など）
 * @returns {boolean} 何らかの行 height を書き換えた場合 true
 */
export function syncKendoGridLockedRowHeights(input, options = {}) {
  const root = resolveRootElement(input);
  if (!root || typeof root.querySelector !== "function") {
    return false;
  }
  applyKendoGridLockedWidthContract(root, options);
  let changed = false;
  const bodyPair = findBodyRowPair(root);
  if (bodyPair) {
    changed = adjustRowPairHeights(bodyPair.lockedRows, bodyPair.bodyRows, options) || changed;
  }
  if (options.skipHeader !== true) {
    const headerPair = findHeaderRowPair(root);
    if (headerPair) {
      changed = adjustRowPairHeights(headerPair.lockedRows, headerPair.bodyRows, options) || changed;
    }
  }
  return changed;
}
