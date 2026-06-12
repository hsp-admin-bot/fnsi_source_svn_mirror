import $ from "@/compat/jquery";

const BOUND_ATTR = "data-ntss-grid-enter-close-bound";
const WHEEL_BOUND_ATTR = "data-ntss-grid-wheel-bound";
const NUMERIC_WHEEL_SPIN_BOUND = "data-ntss-grid-numeric-wheel-spin-bound";
const DROPDOWN_CLOSE_BOUND_ATTR = "data-ntss-grid-dropdown-close-bound";

export function resolveGridEditorContainerElement(container) {
  if (!container) {
    return null;
  }
  if (container.jquery) {
    return container[0] || null;
  }
  if (container.nodeType === 1) {
    return container;
  }
  return null;
}

function collectGridEditorInputs(container) {
  const root = resolveGridEditorContainerElement(container);
  if (!root) {
    return [];
  }
  if (root.matches?.("input, select")) {
    return [root];
  }
  return Array.from(root.querySelectorAll?.("input, select") || []);
}

function collectGridEditorNumericWraps(container) {
  const root = resolveGridEditorContainerElement(container);
  if (!root) {
    return [];
  }
  if (root.matches?.(".k-numerictextbox")) {
    return [root];
  }
  return Array.from(root.querySelectorAll?.(".k-numerictextbox") || []);
}

/**
 * NumericTextBox 上のホイールを Grid 固定列の _wheelScroll へ渡さない。
 * input の wheel 処理の後、bubble 段階で止める（preventDefault はしない）。
 */
function bindGridEditorNumericWheelIsolation(container) {
  const stopBubble = (event) => {
    event.stopPropagation();
  };
  collectGridEditorNumericWraps(container).forEach((wrap) => {
    if (!(wrap instanceof HTMLElement) || wrap.hasAttribute(WHEEL_BOUND_ATTR)) {
      return;
    }
    wrap.setAttribute(WHEEL_BOUND_ATTR, "1");
    wrap.addEventListener("wheel", stopBubble);
    wrap.addEventListener("mousewheel", stopBubble);
  });
}

function getElementOwnerWindow(element) {
  return element?.ownerDocument?.defaultView || (typeof window !== "undefined" ? window : globalThis);
}

function resolveJQueryElement(value) {
  return value?.jquery ? value[0] : value?.[0] || value || null;
}

function createGridEditorMultiSelectSearchSvg(ownerDocument) {
  const svg = ownerDocument.createElementNS("http://www.w3.org/2000/svg", "svg");
  svg.setAttribute("aria-hidden", "true");
  svg.setAttribute("focusable", "false");
  svg.setAttribute("viewBox", "0 0 24 24");
  svg.classList.add("ntss-grid-editor-multiselect-header-search-svg");
  const path = ownerDocument.createElementNS("http://www.w3.org/2000/svg", "path");
  // Vue2/Kendo 2019 は k-icon k-i-zoom の 16px アイコンを flex 末尾に置いていた。
  // Kendo 2026 側では旧 font icon が表示されないことがあるため、同じ位置・サイズで
  // 独自 SVG を内包する。k-svg-icon は付けず、Kendo 2026 theme の sizing 介入を避ける。
  path.setAttribute("d", "M9.5 4C6.46 4 4 6.46 4 9.5S6.46 15 9.5 15c1.32 0 2.54-.46 3.49-1.24l4.37 4.37 1.27-1.27-4.37-4.37A5.47 5.47 0 0 0 15 9.5C15 6.46 12.54 4 9.5 4zm0 1.8c2.04 0 3.7 1.66 3.7 3.7s-1.66 3.7-3.7 3.7-3.7-1.66-3.7-3.7 1.66-3.7 3.7-3.7z");
  svg.appendChild(path);
  return svg;
}

function getGridEditorMultiSelectPopupElement(widgetOrPopup) {
  const popup = widgetOrPopup?.popup || widgetOrPopup;
  return resolveJQueryElement(popup?.element)
    || resolveJQueryElement(popup?.wrapper)
    || resolveJQueryElement(widgetOrPopup)
    || null;
}

/**
 * Grid editor 内の jQuery Kendo MultiSelect headerTemplate 検索欄に、
 * Vue2/Kendo 2019 の虫眼鏡アイコン契約を復元する。
 * 普通の <kendo-multiselect> は一体型検索欄なので対象外。
 */
export function ensureGridEditorMultiSelectHeaderSearchIcon(widgetOrPopup) {
  const popupElement = getGridEditorMultiSelectPopupElement(widgetOrPopup);
  if (!popupElement) {
    return null;
  }
  const ownerDocument = popupElement.ownerDocument || (typeof document !== "undefined" ? document : null);
  if (!ownerDocument) {
    return null;
  }
  const searchInput = popupElement.querySelector?.(".custom-header-search") || null;
  const searchBox = popupElement.querySelector?.(".custom-search-container, #custom-search-container")
    || searchInput?.parentElement
    || null;
  if (!searchBox) {
    return null;
  }

  searchBox.classList.add("ntss-grid-editor-multiselect-header-search-box");
  searchInput?.classList?.add("ntss-grid-editor-multiselect-header-search-input");

  // Kendo 2026 では旧 k-icon/k-i-zoom の icon font が欠落すると「□」だけが
  // 表示される。Vue2 と同じ右端 16px 位置は維持しつつ、表示元は SVG 1 個に
  // 統一するため、headerTemplate 由来の旧 icon font ノードは再利用しない。
  Array.from(searchBox.children || []).forEach((child) => {
    if (!(child instanceof HTMLElement)) {
      return;
    }
    if (child.classList.contains("ntss-grid-editor-multiselect-header-search-icon")) {
      return;
    }
    if (child.classList.contains("k-icon") && (child.classList.contains("k-i-zoom") || child.classList.contains("k-i-search"))) {
      child.remove();
      return;
    }
    if (child.classList.contains("k-input-icon")) {
      child.remove();
    }
  });

  let icon = searchBox.querySelector?.(":scope > .ntss-grid-editor-multiselect-header-search-icon") || null;
  if (!icon) {
    icon = ownerDocument.createElement("span");
    searchBox.appendChild(icon);
  }
  icon.className = "ntss-grid-editor-multiselect-header-search-icon";
  icon.setAttribute("aria-hidden", "true");
  icon.querySelectorAll?.("svg, .k-svg-icon, .k-svg-i-search, .ntss-grid-editor-multiselect-header-search-svg")?.forEach((oldSvg) => {
    oldSvg.remove();
  });
  icon.appendChild(createGridEditorMultiSelectSearchSvg(ownerDocument));
  return { searchBox, searchInput, icon };
}

function collectGridEditorDropDownListWidgets(container) {
  const root = resolveGridEditorContainerElement(container);
  if (!root) {
    return [];
  }
  const candidates = new Set();
  if (root.matches?.("input, select, .k-dropdownlist, .k-dropdown, .k-picker")) {
    candidates.add(root);
  }
  root.querySelectorAll?.("input, select, .k-dropdownlist, .k-dropdown, .k-picker")?.forEach((element) => {
    candidates.add(element);
  });

  const widgets = [];
  const seen = new Set();
  candidates.forEach((element) => {
    const widget = $(element).data("kendoDropDownList")
      || $(element).closest(".k-dropdownlist, .k-dropdown, .k-picker").data("kendoDropDownList")
      || $(element).find("input, select").first().data("kendoDropDownList");
    if (!widget || seen.has(widget)) {
      return;
    }
    seen.add(widget);
    widgets.push(widget);
  });
  return widgets;
}

/**
 * Grid 編集セル内の Kendo DropDownList widget を取得する（複数ある場合は先頭）。
 * bindGridEditorDropDownListToCloseCell と同じ探索ロジックを利用する。
 */
export function getGridEditorDropDownListWidget(container) {
  const widgets = collectGridEditorDropDownListWidgets(container);
  return widgets[0] || null;
}

/**
 * Grid save / edit イベントから編集中フィールド名を解決する。
 * Kendo 2026 の editable.options.field / fields.field と aria-colindex フォールバックに対応。
 */
export function getGridEditFieldFromEvent(ev, columns = []) {
  const fromEditableField = ev?.sender?.editable?.options?.field;
  if (fromEditableField) {
    return fromEditableField;
  }
  const fromEditableFields = ev?.sender?.editable?.options?.fields?.field;
  if (fromEditableFields) {
    return fromEditableFields;
  }
  const cell = resolveGridEditorContainerElement(ev?.container);
  const colIndex = Number(cell?.getAttribute?.("aria-colindex")) - 1;
  if (!Number.isFinite(colIndex) || colIndex < 0) {
    return null;
  }
  return columns[colIndex]?.field || null;
}

/**
 * Grid save 時に DropDownList 列の code 値を解決する。
 * Kendo save が表示テキストを values に入れる場合があるため、
 * __ntssComboSave → widget.value → model の順で code を優先する。
 */
export function resolveGridEditorDropDownListSaveValue(field, ev, schemaFields = {}) {
  if (!field) {
    return undefined;
  }
  const widget = getGridEditorDropDownListWidget(ev?.container);
  const pending = ev?.model?.__ntssComboSave;
  let resolved = pending?.field === field ? pending.value : undefined;
  if (resolved === undefined || resolved === null || resolved === "") {
    resolved = typeof widget?.value === "function" ? widget.value() : undefined;
  }
  if (resolved === undefined || resolved === null || resolved === "") {
    resolved = typeof ev.model?.get === "function" ? ev.model.get(field) : ev.model?.[field];
  }
  if (resolved === undefined || resolved === null || resolved === "") {
    return undefined;
  }
  const schemaType = schemaFields?.[field]?.type;
  if (schemaType === "number") {
    const numeric = Number(resolved);
    return Number.isNaN(numeric) ? resolved : numeric;
  }
  return resolved;
}

function resolveGridCellEditContext(grid, container) {
  const root = resolveGridEditorContainerElement(container);
  const cell = root?.closest?.("td.k-edit-cell, td.k-grid-edit-cell, td[data-role='editable'], td[data-container-for]") || null;
  const gridRoot = cell?.closest?.(".k-grid") || null;
  const resolvedGrid = grid || (gridRoot ? $(gridRoot).data("kendoGrid") : null);
  return { grid: resolvedGrid, cell };
}

function isGridCellStillEditing(cell) {
  return !!cell && (
    cell.classList?.contains("k-edit-cell")
    || cell.classList?.contains("k-grid-edit-cell")
    || cell.getAttribute?.("data-role") === "editable"
  );
}

function scheduleGridCellCloseAfterDropDownSelection(grid, container, widget) {
  const { cell } = resolveGridCellEditContext(grid, container);
  if (!widget || !cell || widget.__ntssGridDropDownCellClosePending) {
    return;
  }
  widget.__ntssGridDropDownCellClosePending = true;
  const ownerWindow = getElementOwnerWindow(cell);
  ownerWindow.setTimeout(() => {
    widget.__ntssGridDropDownCellClosePending = false;
    const { grid: currentGrid, cell: currentCell } = resolveGridCellEditContext(grid, container);
    if (!currentGrid || typeof currentGrid.closeCell !== "function" || !isGridCellStillEditing(currentCell)) {
      return;
    }

    const value = typeof widget.value === "function" ? widget.value() : widget.element?.val?.();
    try {
      widget.element?.val?.(value);
    } catch (_error) {
      // noop
    }
    try {
      widget.wrapper?.trigger?.("blur");
      widget.element?.trigger?.("blur");
      widget.element?.[0]?.blur?.();
    } catch (_error) {
      // noop
    }
    try {
      currentGrid.current?.($(currentCell));
    } catch (_error) {
      // noop
    }
    try {
      currentGrid.closeCell();
    } catch (_error) {
      // Kendo 2019/Vue2 wrapper は dropdown 選択後に cell 編集を終了する。
      // closeCell が例外を出しても dropdown 自体の選択処理は維持する。
    }
  }, 0);
}

/**
 * Vue2 の Kendo Grid foreign-key column は DropDownList 選択後にセル編集を終了する。
 * Vue3 direct jQuery Grid + Kendo 2026 では dropdown が閉じても td が k-edit-cell のまま残るため、
 * Grid edit 時点で生成済みの DropDownList widget にだけ select/change フックを追加する。
 */
export function bindGridEditorDropDownListToCloseCell(grid, container) {
  const bind = () => {
    collectGridEditorDropDownListWidgets(container).forEach((widget) => {
      const element = widget.element?.[0] || widget.wrapper?.[0];
      if (!(element instanceof HTMLElement) || element.hasAttribute(DROPDOWN_CLOSE_BOUND_ATTR)) {
        return;
      }
      element.setAttribute(DROPDOWN_CLOSE_BOUND_ATTR, "1");
      const closeAfterSelection = () => scheduleGridCellCloseAfterDropDownSelection(grid, container, widget);
      try {
        widget.bind?.("select", closeAfterSelection);
        widget.bind?.("change", closeAfterSelection);
      } catch (_error) {
        // noop
      }
      try {
        widget.element?.on?.("change", closeAfterSelection);
      } catch (_error) {
        // noop
      }
    });
  };
  bind();
  const root = resolveGridEditorContainerElement(container);
  getElementOwnerWindow(root).setTimeout(bind, 0);
}

export function readGridEditorNumericValue(container) {
  const root = resolveGridEditorContainerElement(container);
  const input = root?.querySelector?.("input");
  if (!input) {
    return undefined;
  }
  const value = input.value;
  const numeric = Number(value);
  return value !== "" && !Number.isNaN(numeric) ? numeric : value;
}

/**
 * Grid 編集セル内 NumericTextBox のホイールで増減する（下スクロールで減算）。
 * MstFunctionReportMainComponent 等と同じ挙動。
 */
export function applyGridEditorNumericWheelSpin(wheelEvent, cell, onEditorValueChange) {
  const root = resolveGridEditorContainerElement(cell);
  if (!wheelEvent || !root) {
    return;
  }
  wheelEvent.preventDefault();
  wheelEvent.stopPropagation();
  const numericWidget = $(root).find(".k-numerictextbox").data("kendoNumericTextBox");
  const step = Number(numericWidget?.options?.step ?? 1) || 1;
  const min = numericWidget?.options?.min;
  const max = numericWidget?.options?.max;
  let direction = 0;
  if (typeof wheelEvent.deltaY === "number" && wheelEvent.deltaY !== 0) {
    let delta = wheelEvent.deltaY;
    if (wheelEvent.deltaMode === 1) {
      delta *= 16;
    } else if (wheelEvent.deltaMode === 2) {
      delta *= wheelEvent.target?.ownerDocument?.defaultView?.innerHeight ?? 640;
    }
    direction = delta > 0 ? -1 : 1;
  } else {
    const legacyDelta = wheelEvent.wheelDelta ?? (wheelEvent.detail ? wheelEvent.detail * -40 : 0);
    if (legacyDelta > 0) {
      direction = 1;
    } else if (legacyDelta < 0) {
      direction = -1;
    }
  }
  if (direction === 0) {
    return;
  }
  let value = numericWidget?.value?.();
  if (value == null || value === "") {
    const parsed = Number(readGridEditorNumericValue(root));
    value = Number.isFinite(parsed) ? parsed : 0;
  } else {
    value = Number(value);
  }
  if (!Number.isFinite(value)) {
    value = 0;
  }
  value += direction * step;
  if (min != null && value < min) {
    value = min;
  }
  if (max != null && value > max) {
    value = max;
  }
  if (numericWidget?.value) {
    numericWidget.value(value);
  } else {
    const input = root.querySelector?.("input");
    if (input) {
      input.value = String(value);
    }
  }
  onEditorValueChange?.();
}

/**
 * sortRank 等の Grid 数値編集でホイール増減を有効化し、Grid 本体へのスクロール伝播を抑止する。
 */
export function bindGridEditorNumericWheelSpinAssist({
  cell,
  gridRoot = null,
  onEditorValueChange = null,
} = {}) {
  const root = resolveGridEditorContainerElement(cell);
  if (!root) {
    return;
  }
  const input = root.querySelector?.("input");
  const numericWrapEl = root.matches?.(".k-numerictextbox")
    ? root
    : root.querySelector?.(".k-numerictextbox, .k-input-spinner")
    || input?.closest?.(".k-numerictextbox, .k-input-spinner")
    || root;
  if (gridRoot) {
    gridRoot.__ntssGridMouseWheelSuppressed = false;
    gridRoot.onmousewheel = () => false;
  }
  const applyWheelSpin = (wheelEvent) => {
    applyGridEditorNumericWheelSpin(wheelEvent, root, onEditorValueChange);
  };
  const restoreGridMouseWheel = () => {
    if (gridRoot && !gridRoot.__ntssGridMouseWheelSuppressed) {
      gridRoot.onmousewheel = null;
      gridRoot.__ntssGridMouseWheelSuppressed = true;
    }
  };
  [input, numericWrapEl].forEach((element) => {
    if (!(element instanceof HTMLElement) || element.hasAttribute(NUMERIC_WHEEL_SPIN_BOUND)) {
      return;
    }
    element.setAttribute(NUMERIC_WHEEL_SPIN_BOUND, "1");
    element.addEventListener("wheel", applyWheelSpin, { passive: false });
    element.addEventListener("mousewheel", applyWheelSpin, { passive: false });
  });
  input?.addEventListener?.("blur", restoreGridMouseWheel, { once: true });
  const numericWidget = $(root).find(".k-numerictextbox").data("kendoNumericTextBox");
  numericWidget?.bind?.("spin change", onEditorValueChange);
  if (onEditorValueChange) {
    setTimeout(onEditorValueChange, 0);
  }
}


const GRID_MULTISELECT_ROWHEIGHT_BOUND_ATTR = "data-ntss-grid-multiselect-rowheight-bound";
const GRID_MULTISELECT_LEGACY_CLASS = "ntss-grid-editor-multiselect-legacy";

export function getKendoMultiSelectDomParts(widget) {
  const wrapper = widget?.wrapper?.get?.(0) || widget?.wrapper?.[0] || null;
  const valueArea = wrapper?.querySelector?.(".k-multiselect-wrap, .k-input-values, .k-chip-list") || null;
  const chips = wrapper ? Array.from(wrapper.querySelectorAll(".k-button, .k-chip")) : [];
  const chipLabels = wrapper ? Array.from(wrapper.querySelectorAll(".k-chip-label, .k-chip-content, .k-button-text")) : [];
  const chipActions = wrapper ? Array.from(wrapper.querySelectorAll(".k-chip-actions, .k-chip-remove-action, .k-select")) : [];
  const chipRemoveActions = wrapper ? Array.from(wrapper.querySelectorAll(".k-chip-remove-action")) : [];
  const chipRemoveIcons = wrapper ? Array.from(wrapper.querySelectorAll(".k-chip-remove-action .k-icon, .k-chip-remove-action .k-svg-icon, .k-select .k-icon, .k-select .k-svg-icon")) : [];
  const input = wrapper?.querySelector?.("input.k-input, .k-input-inner") || null;
  return { wrapper, valueArea, chips, chipLabels, chipActions, chipRemoveActions, chipRemoveIcons, input };
}

function clearElementInlineBoxHeight(element) {
  if (!(element instanceof HTMLElement)) {
    return;
  }
  element.style.height = "";
  element.style.minHeight = "";
  element.style.maxHeight = "";
}

function findGridRowsForEditRow(editRow, gridRoot = null) {
  if (!editRow) {
    return [];
  }
  const root = gridRoot || editRow.closest?.(".k-grid");
  if (!root) {
    return [editRow];
  }
  const uid = editRow.getAttribute?.("data-uid");
  if (uid) {
    const rowsByUid = Array.from(root.querySelectorAll(`tbody tr[data-uid="${uid}"]`));
    if (rowsByUid.length) {
      return rowsByUid;
    }
  }
  const tbody = editRow.parentElement;
  const rowIndex = tbody ? Array.prototype.indexOf.call(tbody.children, editRow) : -1;
  if (rowIndex >= 0) {
    const rowsByIndex = Array.from(root.querySelectorAll(".k-grid-content tbody, .k-grid-content-locked tbody"))
      .map((body) => body.children?.[rowIndex])
      .filter(Boolean);
    if (rowsByIndex.length) {
      return rowsByIndex;
    }
  }
  return [editRow];
}

function resolveGridEditorElement(target) {
  if (!target) {
    return null;
  }
  return target?.jquery ? target.get?.(0) : target?.get?.(0) || target?.[0] || target;
}

function findGridRowsByUid(gridRoot, uid) {
  if (!gridRoot || uid === undefined || uid === null) {
    return [];
  }
  const uidText = String(uid);
  return Array.from(gridRoot.querySelectorAll("tbody tr[data-uid]"))
    .filter((row) => row.getAttribute("data-uid") === uidText);
}

function clearGridEditorRowHeight(rows = []) {
  rows.forEach((row) => {
    clearElementInlineBoxHeight(row);
    Array.from(row?.children || []).forEach((cell) => {
      clearElementInlineBoxHeight(cell);
      if (cell instanceof HTMLElement) {
        cell.style.verticalAlign = "top";
        cell.style.overflow = "visible";
        cell.style.whiteSpace = "normal";
      }
    });
  });
}

export function clearGridEditorMultiSelectRowHeight(target = null, options = {}) {
  const targetElement = resolveGridEditorElement(target);
  const gridRoot = options.gridRoot || targetElement?.closest?.(".k-grid") || null;
  let rows = findGridRowsByUid(gridRoot, options.uid);

  if (!rows.length) {
    const editRow = targetElement?.closest?.("tr");
    rows = editRow ? findGridRowsForEditRow(editRow, gridRoot) : [];
  }
  clearGridEditorRowHeight(rows);
  return rows.length;
}

export function scheduleClearGridEditorMultiSelectRowHeight(target = null, options = {}) {
  const targetElement = resolveGridEditorElement(target);
  const gridRoot = options.gridRoot || targetElement?.closest?.(".k-grid") || null;
  const ownerWindow = getElementOwnerWindow(gridRoot || targetElement);
  const clear = () => {
    clearGridEditorMultiSelectRowHeight(targetElement || gridRoot, options);
    options.afterClear?.();
  };
  clear();
  if (!ownerWindow) {
    return;
  }
  const schedule = typeof ownerWindow.requestAnimationFrame === "function"
    ? ownerWindow.requestAnimationFrame.bind(ownerWindow)
    : (callback) => ownerWindow.setTimeout(callback, 0);
  schedule(() => {
    clear();
    schedule(clear);
  });
}

export function syncKendoMultiSelectLegacyWrapLayout(widget, options = {}) {
  const { wrapper, valueArea, chips, chipLabels, chipActions, chipRemoveActions, chipRemoveIcons, input } = getKendoMultiSelectDomParts(widget);
  if (!wrapper) {
    return;
  }
  wrapper.classList.add(GRID_MULTISELECT_LEGACY_CLASS);
  wrapper.classList.add("k-legacy-multiselect");
  if (options.wrapperClassName) {
    wrapper.classList.add(options.wrapperClassName);
  }

  // Vue2 + Kendo 2019 wrapper は MultiSelect の tag 領域を table cell の通常フローに載せる。
  // Vue3 direct jq Grid + Kendo 2026 で残る固定高/flex だけを共通で外す。
  clearElementInlineBoxHeight(wrapper);
  wrapper.style.position = "static";
  wrapper.style.left = "auto";
  wrapper.style.top = "auto";
  wrapper.style.transform = "none";
  wrapper.style.display = "flex";
  wrapper.style.width = "100%";
  wrapper.style.height = "auto";
  wrapper.style.maxHeight = "none";
  wrapper.style.minHeight = options.minHeight || "2em";
  wrapper.style.whiteSpace = "normal";
  wrapper.style.overflow = "visible";
  wrapper.style.maxWidth = "100%";
  wrapper.style.backgroundColor = options.backgroundColor || "#fff";
  wrapper.style.color = options.color || "#050505";
  wrapper.style.borderColor = options.borderColor || "#a8a8a8";

  if (valueArea instanceof HTMLElement) {
    clearElementInlineBoxHeight(valueArea);
    valueArea.style.height = "auto";
    valueArea.style.maxHeight = "none";
    valueArea.style.whiteSpace = "normal";
    valueArea.style.overflow = "visible";
    valueArea.style.maxWidth = "100%";
    valueArea.style.flexWrap = "wrap";
    valueArea.style.alignItems = "flex-start";
    valueArea.style.alignContent = "flex-start";
    valueArea.style.backgroundColor = options.backgroundColor || "#fff";
    valueArea.style.color = options.color || "#050505";
  }

  chips.forEach((chip) => {
    chip.classList?.add?.("k-button");
    chip.style.display = "inline-flex";
    chip.style.alignItems = "center";
    chip.style.boxSizing = "border-box";
    chip.style.flex = "0 1 auto";
    chip.style.minWidth = "0";
    chip.style.maxWidth = "100%";
    chip.style.whiteSpace = "nowrap";
    chip.style.overflow = "hidden";
    chip.style.textOverflow = "clip";
  });
  chipLabels.forEach((label) => {
    label.style.display = "inline-flex";
    label.style.alignItems = "center";
    label.style.flex = "1 1 auto";
    label.style.minWidth = "0";
    label.style.maxWidth = "100%";
    label.style.whiteSpace = "nowrap";
    label.style.wordBreak = "normal";
    label.style.overflowWrap = "normal";
    label.style.overflow = "hidden";
    label.style.textOverflow = "ellipsis";
  });
  chipActions.forEach((action) => {
    action.style.flex = "0 0 auto";
    action.style.whiteSpace = "nowrap";
    action.style.overflow = "visible";
  });
  chipRemoveActions.forEach((action) => {
    action.classList?.add?.("k-select");
    action.setAttribute?.("unselectable", "on");
  });
  chipRemoveIcons.forEach((icon) => {
    icon.classList?.add?.("k-icon", "k-i-close");
  });
  if (input instanceof HTMLElement) {
    input.style.flex = "1 0 4em";
    input.style.minWidth = "4em";
    input.style.alignSelf = "flex-start";
    input.style.color = options.color || "#050505";
    input.style.caretColor = options.color || "#050505";
  }
}

export function syncGridEditorMultiSelectRowHeight(widget, options = {}) {
  const { wrapper, valueArea } = getKendoMultiSelectDomParts(widget);
  if (!wrapper) {
    return;
  }
  const editCell = wrapper.closest(".k-edit-cell, td");
  const editRow = wrapper.closest(".k-grid-edit-row, tr");
  if (!editCell || !editRow) {
    return;
  }

  const rows = findGridRowsForEditRow(editRow, options.gridRoot || null);
  // 旧値を残したまま測ると削除時に縮まず、クリックのたびに行高が累積する。
  // Vue2 wrapper/Kendo 2019 の「現在の editor 内容で行高を再同期する」挙動を共通で復元する。
  clearGridEditorRowHeight(rows);
  clearElementInlineBoxHeight(wrapper);
  if (valueArea) {
    clearElementInlineBoxHeight(valueArea);
  }
  syncKendoMultiSelectLegacyWrapLayout(widget, options);

  // layout flush: Kendo 2026 は tag DOM 更新直後に高さが確定していないことがある。
  wrapper.offsetHeight;

  const ownerWindow = getElementOwnerWindow(wrapper);
  const cellStyle = ownerWindow.getComputedStyle?.(editCell);
  const paddingTop = parseFloat(cellStyle?.paddingTop || "0") || 0;
  const paddingBottom = parseFloat(cellStyle?.paddingBottom || "0") || 0;
  const borderTop = parseFloat(cellStyle?.borderTopWidth || "0") || 0;
  const borderBottom = parseFloat(cellStyle?.borderBottomWidth || "0") || 0;
  const minPixelHeight = Number(options.minPixelHeight ?? 32) || 32;
  const wrapperHeight = Math.ceil(Math.max(
    wrapper.getBoundingClientRect?.().height || 0,
    wrapper.scrollHeight || 0,
    valueArea?.getBoundingClientRect?.().height || 0,
    valueArea?.scrollHeight || 0,
    minPixelHeight
  ));
  const targetHeight = Math.ceil(Math.max(
    minPixelHeight,
    wrapperHeight + paddingTop + paddingBottom + borderTop + borderBottom + 2
  ));

  rows.forEach((row) => {
    if (!(row instanceof HTMLElement)) {
      return;
    }
    row.style.height = `${targetHeight}px`;
    row.style.minHeight = `${targetHeight}px`;
    Array.from(row.children || []).forEach((cell) => {
      if (!(cell instanceof HTMLElement)) {
        return;
      }
      cell.style.height = `${targetHeight}px`;
      cell.style.minHeight = `${targetHeight}px`;
      cell.style.verticalAlign = "top";
      cell.style.overflow = "visible";
      cell.style.whiteSpace = "normal";
    });
  });

  widget.popup?.position?.();
  options.afterSync?.({ widget, rows, targetHeight });
}

export function scheduleGridEditorMultiSelectRowHeight(widget, options = {}) {
  const { wrapper } = getKendoMultiSelectDomParts(widget);
  syncGridEditorMultiSelectRowHeight(widget, options);
  const ownerWindow = getElementOwnerWindow(wrapper);
  const schedule = typeof ownerWindow.requestAnimationFrame === "function"
    ? ownerWindow.requestAnimationFrame.bind(ownerWindow)
    : (callback) => ownerWindow.setTimeout(callback, 0);
  schedule(() => {
    const { wrapper: currentWrapper } = getKendoMultiSelectDomParts(widget);
    if (currentWrapper?.isConnected !== false) {
      syncGridEditorMultiSelectRowHeight(widget, options);
    }
  });
}

export function bindGridEditorMultiSelectRowHeight(grid, container, options = {}) {
  const root = resolveGridEditorContainerElement(container);
  if (!root || root.hasAttribute?.(GRID_MULTISELECT_ROWHEIGHT_BOUND_ATTR)) {
    return;
  }
  root.setAttribute(GRID_MULTISELECT_ROWHEIGHT_BOUND_ATTR, "1");
  const widget = $(root).find("select, input").addBack?.().data?.("kendoMultiSelect")
    || $(root).find("select, input").first().data("kendoMultiSelect")
    || $(root).find(".k-multiselect").data("kendoMultiSelect");
  if (!widget) {
    return;
  }
  const gridRoot = options.gridRoot || root.closest?.(".k-grid") || grid?.wrapper?.[0] || null;
  const rowHeightOptions = { ...options, gridRoot };
  widget.bind?.("open", () => scheduleGridEditorMultiSelectRowHeight(widget, rowHeightOptions));
  widget.bind?.("change", () => scheduleGridEditorMultiSelectRowHeight(widget, rowHeightOptions));
  scheduleGridEditorMultiSelectRowHeight(widget, rowHeightOptions);
}

/**
 * Grid セル編集中の Enter で blur + closeCell し、編集を確定させる。
 * Vue3 NumericTextBox compat では Kendo Grid 標準の Enter 終了が効かないため共通利用する。
 */
export function bindGridEditorEnterToCloseCell(grid, container) {
  bindGridEditorNumericWheelIsolation(container);
  collectGridEditorInputs(container).forEach((input) => {
    if (!(input instanceof HTMLElement)) {
      return;
    }
    if (input.tagName === "TEXTAREA") {
      return;
    }
    if (input.hasAttribute(BOUND_ATTR)) {
      return;
    }
    input.setAttribute(BOUND_ATTR, "1");
    input.addEventListener("keydown", (event) => {
      if (event.key !== "Enter") {
        return;
      }
      event.preventDefault();
      event.stopPropagation();
      input.blur();
      requestAnimationFrame(() => {
        try {
          grid?.closeCell?.();
        } catch (_error) {
          // noop
        }
      });
    });
  });
}

/**
 * locked / unlocked 分割 Grid 上で field 名から td を取得する。
 */
export function getDirectGridFieldCell(grid, tr, field) {
  if (!grid || !tr || !field) {
    return null;
  }
  const isLocked = !!tr.closest?.(".k-grid-content-locked");
  let index = 0;
  for (const column of grid.columns || []) {
    if (!column.field) {
      continue;
    }
    if (!!column.locked !== isLocked) {
      continue;
    }
    if (column.field === field) {
      return tr.querySelectorAll(":scope > td")[index] || null;
    }
    index += 1;
  }
  return null;
}

function getDirectGridRowsByRecord(grid, gridRoot, record) {
  const rows = [];
  if (!grid || !gridRoot || !record) {
    return rows;
  }
  if (record.uid) {
    gridRoot.querySelectorAll(`tr[data-uid="${record.uid}"]`).forEach(tr => rows.push(tr));
  }
  if (!rows.length) {
    gridRoot.querySelectorAll("tbody tr[data-uid]").forEach(tr => {
      const item = grid.dataItem?.(tr);
      if (item && record.code != null && String(item.code) === String(record.code)) {
        rows.push(tr);
      }
    });
  }
  return rows;
}

/**
 * direct jq Grid の指定 field を DOM 表示に同期する（locked / unlocked 両方）。
 */
export function syncDirectGridRecordFieldCells(grid, gridRoot, record, fields) {
  if (!grid || !gridRoot || !record || !fields?.length) {
    return;
  }
  getDirectGridRowsByRecord(grid, gridRoot, record).forEach(tr => {
    fields.forEach(field => {
      const cell = getDirectGridFieldCell(grid, tr, field);
      if (!cell) {
        return;
      }
      const dropDownWidget = getGridEditorDropDownListWidget(cell);
      if (dropDownWidget) {
        try {
          const value = record[field];
          dropDownWidget.value(value == null || value === "" ? null : value);
        } catch (_error) {
          // noop
        }
        return;
      }
      if (cell.classList.contains("k-edit-cell") && cell.querySelector("input, select, .k-dropdownlist, .k-picker")) {
        return;
      }
      const value = record[field];
      cell.textContent = value == null || value === "" ? "" : String(value);
    });
  });
}

/**
 * Kendo 2026 direct Grid: 追加行(operation=1)の DropDownList は closeCell だけでは
 * 選択値がセルに残らないため、widget を破棄してテキスト表示に切り替える。
 */
export function commitDirectGridAddedRowDropDownCell(grid, container, field, displayText) {
  const { cell } = resolveGridCellEditContext(grid, container);
  if (!cell) {
    return;
  }
  const dropDownWidget = getGridEditorDropDownListWidget(container);
  if (dropDownWidget) {
    try {
      dropDownWidget.unbind?.("change");
      dropDownWidget.unbind?.("select");
      dropDownWidget.destroy();
    } catch (_error) {
      // noop
    }
  }
  cell.classList.remove("k-edit-cell", "k-grid-edit-cell", "k-invalid");
  if (field) {
    cell.setAttribute("data-field", field);
  }
  cell.innerHTML = "";
  if (displayText != null && displayText !== "") {
    cell.appendChild(cell.ownerDocument.createTextNode(String(displayText)));
  }
  cell.closest("tr")?.classList.remove("k-grid-edit-row");
  if (grid?.editable) {
    grid.editable = null;
  }
}
