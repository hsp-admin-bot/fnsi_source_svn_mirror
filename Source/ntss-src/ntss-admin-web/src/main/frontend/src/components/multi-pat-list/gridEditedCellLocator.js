import {
  findAllKendoGridRowByUid,
  findKendoGridHeaderWrap,
  findKendoGridRowCells,
  getKendoGridWrapperElement
} from "@/compat/kendo/dom.js";

function resolveBodyGridRow(grid, dataItem) {
  const uid = dataItem?.uid ?? dataItem?._uid;
  if (uid == null || uid === "") {
    return null;
  }
  const rows = findAllKendoGridRowByUid(grid, uid);
  if (!Array.isArray(rows) || rows.length === 0) {
    return null;
  }
  if (rows.length === 1) {
    return rows[0];
  }
  return rows.find((row) => !row?.closest?.(".k-grid-content-locked")) || rows[rows.length - 1];
}

function findLeafHeaderFields(grid) {
  const gridRoot = getKendoGridWrapperElement(grid);
  const headerWrap = gridRoot ? findKendoGridHeaderWrap(gridRoot) : null;
  if (!headerWrap) {
    return [];
  }
  const thead = headerWrap.querySelector("thead") || headerWrap;
  const headerRows = thead.querySelectorAll("tr");
  if (!headerRows.length) {
    return [];
  }
  const leafRow = headerRows[headerRows.length - 1];
  return Array.from(leafRow.querySelectorAll('th[role="columnheader"], th.k-header, th.k-table-th, th'))
    .filter((cell) => cell?.style?.display !== "none" && cell?.getAttribute?.("aria-hidden") !== "true")
    .map((header) => header.getAttribute("data-field") || header.dataset?.field || "");
}

/**
 * scrollable body 行の編集済みセルを field 候補から特定する
 * @param {*} grid Kendo Grid インスタンス
 * @param {Object} dataItem 行データ
 * @param {string[]} fields 照合する field 候補
 * @returns {HTMLElement|null}
 */
export function findBodyGridCell(grid, dataItem, fields) {
  const fieldList = Array.isArray(fields) ? fields.filter(Boolean) : [];
  if (!grid || !dataItem || fieldList.length === 0) {
    return null;
  }
  const row = resolveBodyGridRow(grid, dataItem);
  if (!row) {
    return null;
  }
  for (const field of fieldList) {
    const escapedField = String(field).replace(/"/g, '\\"');
    const cell = row.querySelector(`td[data-field="${escapedField}"], th[data-field="${escapedField}"]`);
    if (cell) {
      return cell;
    }
  }
  const rowCells = findKendoGridRowCells(row);
  const headerFields = findLeafHeaderFields(grid);
  for (const field of fieldList) {
    const headerIndex = headerFields.indexOf(String(field));
    if (headerIndex >= 0 && rowCells[headerIndex]) {
      return rowCells[headerIndex];
    }
  }
  return null;
}
