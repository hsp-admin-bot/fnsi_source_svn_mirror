import {
  findKendoGridBodyTable,
  findKendoGridContent,
  findKendoGridHeader,
  findKendoGridHeaderTable,
  findKendoGridHeaderWrap,
  findKendoGridRoot,
  getKendoMultiSelectDomParts
} from "@/compat/kendo/dom.js";

function queryAll(root, selector) {
  if (!root || !selector || typeof root.querySelectorAll !== "function") {
    return [];
  }
  try {
    return Array.from(root.querySelectorAll(selector));
  } catch (_error) {
    return [];
  }
}

export function syncKendoMultiSelectLegacyWrapLayout(root, options = {}) {
  const parts = getKendoMultiSelectDomParts(root);
  const { wrapper, valueArea, chipList } = parts;
  if (!wrapper) {
    return parts;
  }
  ["k-widget", "k-header", "k-legacy-multiselect"].forEach((className) => wrapper.classList?.add?.(className));
  if (options.wrapperClassName) {
    wrapper.classList?.add?.(options.wrapperClassName);
  }
  wrapper.style.height = options.height || "auto";
  wrapper.style.minHeight = options.minHeight || "2em";
  wrapper.style.overflow = options.overflow || "hidden";
  if (valueArea) {
    ["k-multiselect-wrap", "k-floatwrap"].forEach((className) => valueArea.classList?.add?.(className));
    valueArea.style.display = options.display || "flex";
    valueArea.style.flexWrap = options.flexWrap || "wrap";
    valueArea.style.alignItems = options.alignItems || "flex-start";
    valueArea.style.overflow = options.overflow || "hidden";
    valueArea.style.minHeight = options.minHeight || "2em";
  }
  if (chipList) {
    chipList.style.display = options.display || "flex";
    chipList.style.flexWrap = options.flexWrap || "wrap";
    chipList.style.alignItems = options.chipAlignItems || "center";
    chipList.style.gap = options.gap || "2px";
    chipList.style.flex = options.flex || "1 1 auto";
    chipList.style.minWidth = options.minWidth || "0";
  }
  return parts;
}

export function syncKendoGridHeaderBodyTableWidth(root, totalWidth, options = {}) {
  const gridRoot = findKendoGridRoot(root) || root;
  if (!gridRoot) {
    return false;
  }
  const width = Math.max(0, Math.round(Number(totalWidth) || 0));
  const widthText = `${width}px`;
  [findKendoGridHeaderTable(gridRoot), findKendoGridBodyTable(gridRoot)]
    .filter(Boolean)
    .forEach((table) => {
      table.style.width = widthText;
      // min-width を総幅に合わせると table-layout:fixed で他列が再分配され左端がずれる
      table.style.removeProperty("min-width");
      table.style.tableLayout = "fixed";
    });
  if (options?.includeContentExpander !== false) {
    queryAll(gridRoot, ".k-grid-content-expander").forEach((expander) => {
      expander.style.width = widthText;
    });
  }
  if (options?.hideHorizontalOverflow !== false) {
    [findKendoGridHeaderWrap(gridRoot), findKendoGridContent(gridRoot)]
      .filter(Boolean)
      .forEach((wrap) => {
        wrap.style.overflowX = "hidden";
      });
  }
  if (options?.removeHeaderRightPadding !== false) {
    const header = findKendoGridHeader(gridRoot);
    if (header) {
      header.style.paddingRight = "0px";
    }
  }
  return true;
}
