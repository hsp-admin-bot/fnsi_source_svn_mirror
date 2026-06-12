import {
  findKendoGridContent,
  findKendoGridHeaderScrollHost,
  findKendoGridHeaderWrap,
  findKendoGridLockedContent,
  findKendoGridLockedHeader,
  findKendoGridLogicalTable,
  findKendoGridLockedRows,
  findKendoGridLockedTable,
  findKendoGridLockedTbody,
  findKendoGridRoot,
  findKendoGridScrollHost,
  findKendoGridTable,
  findKendoGridTbody,
  findKendoGridVerticalScrollbar,
  resolveDomElement
} from "@/compat/kendo/dom.js";

function firstElement(value) {
  if (!value) {
    return null;
  }
  if (value.jquery) {
    return value[0] || null;
  }
  if (Array.isArray(value)) {
    return value[0] || null;
  }
  if (typeof value.get === "function" && typeof value.length === "number") {
    return value.get(0) || null;
  }
  return resolveDomElement(value) || null;
}

function resolveGridRoot(senderOrRoot) {
  const sender = senderOrRoot?.sender || senderOrRoot;
  return firstElement(sender?.wrapper)
    || firstElement(sender?.element)
    || findKendoGridRoot(firstElement(senderOrRoot))
    || firstElement(senderOrRoot)
    || null;
}

function resolveGridSender(senderOrRoot) {
  const sender = senderOrRoot?.sender || senderOrRoot;
  if (!sender || typeof sender !== 'object') {
    return null;
  }
  if (Array.isArray(sender.columns) || Array.isArray(sender.options?.columns)) {
    return sender;
  }
  return null;
}

function resolveGridContent(senderOrRoot) {
  const sender = senderOrRoot?.sender || senderOrRoot;
  const root = resolveGridRoot(senderOrRoot);
  // Prefer the scroll host (which may be the virtual scroll wrapper)
  // over sender.content, because sender.content can refer to an inner
  // element that does not actually receive scroll events when virtual
  // scrolling is enabled.
  return findKendoGridScrollHost(root)
    || firstElement(sender?.content)
    || findKendoGridContent(root)
    || null;
}


function resolveGridHeaderScrollHost(senderOrRoot) {
  const sender = senderOrRoot?.sender || senderOrRoot;
  const root = resolveGridRoot(senderOrRoot);
  return firstElement(sender?.headerWrap)
    || findKendoGridHeaderScrollHost(root)
    || findKendoGridHeaderWrap(root)
    || null;
}


function readTableWidth(tableEl) {
  if (!tableEl) {
    return 0;
  }
  const cols = Array.from(tableEl.querySelectorAll?.('colgroup > col') || []);
  const colWidth = cols.reduce((sum, col) => {
    const styleWidth = parseFloat(col.style?.width || '0');
    const rectWidth = col.getBoundingClientRect?.().width || 0;
    return sum + (Number.isFinite(styleWidth) && styleWidth > 0 ? styleWidth : (rectWidth || 0));
  }, 0);
  if (colWidth > 0) {
    return Math.round(colWidth);
  }
  const styleWidth = parseFloat(tableEl.style?.width || '0');
  const rectWidth = tableEl.getBoundingClientRect?.().width || 0;
  return Math.round((Number.isFinite(styleWidth) && styleWidth > 0 ? styleWidth : rectWidth) || 0);
}

function resolveFontSize(root, rem = false) {
  const fallbackDocument = typeof document !== 'undefined' ? document : null;
  const ownerDocument = root?.ownerDocument || fallbackDocument;
  if (!ownerDocument) {
    return 16;
  }
  const target = rem ? ownerDocument?.documentElement : root;
  const ownerWindow = ownerDocument?.defaultView || (typeof window !== 'undefined' ? window : null);
  const fontSize = parseFloat(ownerWindow?.getComputedStyle?.(target || ownerDocument?.documentElement)?.fontSize || '16');
  return Number.isFinite(fontSize) && fontSize > 0 ? fontSize : 16;
}

function parseCssLength(value, root) {
  if (typeof value === 'number') {
    return Number.isFinite(value) ? value : 0;
  }
  if (typeof value !== 'string') {
    return 0;
  }
  const normalized = value.trim();
  if (!normalized || normalized === 'auto') {
    return 0;
  }
  const single = normalized.match(/^([-+]?\d+(?:\.\d+)?)(px|em|rem)?$/i);
  if (single) {
    const amount = Number(single[1]);
    const unit = (single[2] || 'px').toLowerCase();
    if (!Number.isFinite(amount)) {
      return 0;
    }
    if (unit === 'em') {
      return amount * resolveFontSize(root, false);
    }
    if (unit === 'rem') {
      return amount * resolveFontSize(root, true);
    }
    return amount;
  }
  if (/^calc\(/i.test(normalized)) {
    let total = 0;
    let matched = false;
    const expression = normalized.replace(/^calc\(/i, '').replace(/\)$/, '');
    expression.replace(/([+-]?)\s*(\d+(?:\.\d+)?)(px|em|rem)/gi, (_match, sign, amountText, unitText) => {
      const signValue = sign === '-' ? -1 : 1;
      const amount = Number(amountText);
      const unit = unitText.toLowerCase();
      if (!Number.isFinite(amount)) {
        return '';
      }
      matched = true;
      if (unit === 'em') {
        total += signValue * amount * resolveFontSize(root, false);
      } else if (unit === 'rem') {
        total += signValue * amount * resolveFontSize(root, true);
      } else {
        total += signValue * amount;
      }
      return '';
    });
    return matched && Number.isFinite(total) && total > 0 ? total : 0;
  }
  const parsed = parseFloat(normalized);
  return Number.isFinite(parsed) && parsed > 0 ? parsed : 0;
}

function readElementInlineWidth(element, root) {
  if (!element) {
    return 0;
  }
  const style = element.style || {};
  const appliedWidth = element.dataset?.ntssKendoLockedWidth || '';
  if (style.width && style.width === appliedWidth) {
    return 0;
  }
  const styleWidth = parseCssLength(style.width, root)
    || parseCssLength(style.minWidth, root)
    || parseCssLength(style.flexBasis, root);
  return Math.round(styleWidth || 0);
}

function readElementRenderedWidth(element) {
  if (!element) {
    return 0;
  }
  const rectWidth = element.getBoundingClientRect?.().width || 0;
  return Math.round(Number.isFinite(rectWidth) && rectWidth > 0 ? rectWidth : 0);
}

function flattenColumns(columns, result = []) {
  if (!Array.isArray(columns)) {
    return result;
  }
  columns.forEach((column) => {
    if (!column) {
      return;
    }
    if (Array.isArray(column.columns) && column.columns.length > 0) {
      flattenColumns(column.columns, result);
    } else {
      result.push(column);
    }
  });
  return result;
}

function readLockedColumnsWidth(senderOrRoot, root) {
  const sender = resolveGridSender(senderOrRoot);
  const columns = flattenColumns(sender?.columns || sender?.options?.columns || []);
  if (columns.length === 0) {
    return 0;
  }
  let hasWidth = false;
  const width = columns.reduce((sum, column) => {
    if (column.locked !== true || column.hidden === true) {
      return sum;
    }
    const columnWidth = parseCssLength(column.width, root);
    if (columnWidth > 0) {
      hasWidth = true;
      return sum + columnWidth;
    }
    return sum;
  }, 0);
  return hasWidth ? Math.round(width) : 0;
}

function setPixelWidth(element, width) {
  if (!element || !Number.isFinite(width) || width <= 0) {
    return false;
  }
  const next = `${Math.round(width)}px`;
  let changed = false;
  if (element.dataset && element.dataset.ntssKendoLockedWidth !== next) {
    element.dataset.ntssKendoLockedWidth = next;
    changed = true;
  }
  ['width', 'minWidth', 'flexBasis'].forEach((name) => {
    if (element.style?.[name] !== next) {
      element.style[name] = next;
      changed = true;
    }
  });
  if (element.style?.maxWidth) {
    element.style.maxWidth = '';
    changed = true;
  }
  return changed;
}

function setPixelHeight(element, height) {
  if (!element || !Number.isFinite(height) || height <= 0) {
    return false;
  }
  const next = `${Math.round(height)}px`;
  let changed = false;
  if (element.dataset && element.dataset.ntssKendoLockedHeight !== next) {
    element.dataset.ntssKendoLockedHeight = next;
    changed = true;
  }
  ['height', 'minHeight'].forEach((name) => {
    if (element.style?.[name] !== next) {
      element.style[name] = next;
      changed = true;
    }
  });
  if (element.style?.maxHeight) {
    element.style.maxHeight = '';
    changed = true;
  }
  return changed;
}

function rowHeightElements(row) {
  if (!row) {
    return [];
  }
  return [
    row,
    ...Array.from(row.children || []).filter((child) => child?.nodeType === 1)
  ];
}

function clearCompatPixelHeight(element) {
  const appliedHeight = element?.dataset?.ntssKendoLockedHeight;
  if (!element || !appliedHeight) {
    return false;
  }
  let changed = false;
  ['height', 'minHeight'].forEach((name) => {
    if (element.style?.[name] === appliedHeight) {
      element.style[name] = '';
      changed = true;
    }
  });
  delete element.dataset.ntssKendoLockedHeight;
  return changed;
}

function clearLogicalRowPixelHeight(row) {
  return rowHeightElements(row).reduce(
    (changed, element) => clearCompatPixelHeight(element) || changed,
    false
  );
}

function setLogicalRowPixelHeight(row, height) {
  return rowHeightElements(row).reduce(
    (changed, element) => setPixelHeight(element, height) || changed,
    false
  );
}

function sumElementHeights(elements) {
  return (elements || []).reduce((total, element) => {
    const height = element?.offsetHeight || element?.getBoundingClientRect?.().height || 0;
    return total + (Number.isFinite(height) ? height : 0);
  }, 0);
}

function readRenderedRowHeight(row) {
  if (!row) {
    return 0;
  }
  const rectHeight = row.getBoundingClientRect?.().height || 0;
  const offsetHeight = row.offsetHeight || 0;
  const clientHeight = row.clientHeight || 0;
  return Math.max(rectHeight, offsetHeight, clientHeight, 0);
}

function isMasterMaintenanceGrid(root) {
  return !!root?.closest?.('.master-maintenance-page');
}

function isLogicalRowEditing(bodyRow, lockedRow) {
  return [bodyRow, lockedRow].some((row) => (
    row?.classList?.contains?.('k-grid-edit-row')
    || row?.classList?.contains?.('k-edit-row')
    || row?.querySelector?.('.k-edit-cell, .k-grid-edit-cell, td.k-edit-cell')
  ));
}

function resolveLogicalRowHeight(root, bodyRow, lockedRow) {
  const bodyHeight = readRenderedRowHeight(bodyRow);
  const lockedHeight = readRenderedRowHeight(lockedRow);
  if (isMasterMaintenanceGrid(root) && !isLogicalRowEditing(bodyRow, lockedRow)) {
    return lockedHeight > 0 ? lockedHeight : bodyHeight;
  }
  return Math.max(bodyHeight, lockedHeight);
}

function syncKendoGridLogicalRowHeights(root) {
  const logicalTable = findKendoGridLogicalTable(root);
  if (!logicalTable.hasLockedRows || logicalTable.bodyRows.length === 0) {
    return false;
  }
  let changed = false;
  logicalTable.rows.forEach(({ bodyRow, lockedRow }) => {
    if (!bodyRow || !lockedRow) {
      return;
    }
    changed = clearLogicalRowPixelHeight(bodyRow) || changed;
    changed = clearLogicalRowPixelHeight(lockedRow) || changed;
    const rowHeight = resolveLogicalRowHeight(root, bodyRow, lockedRow);
    if (rowHeight <= 0) {
      return;
    }
    changed = setLogicalRowPixelHeight(bodyRow, rowHeight) || changed;
    changed = setLogicalRowPixelHeight(lockedRow, rowHeight) || changed;
  });
  return changed;
}

function uniqueElements(elements) {
  const seen = new Set();
  return (elements || []).filter((element) => {
    if (!element || seen.has(element)) {
      return false;
    }
    seen.add(element);
    return true;
  });
}

function resolveLockedContentHeight(root, lockedContent, scrollableContent) {
  if (scrollableContent && scrollableContent !== lockedContent) {
    const hasHorizontalScrollbar = (scrollableContent.scrollWidth || 0) > ((scrollableContent.clientWidth || 0) + 1);
    const scrollableHeight = (hasHorizontalScrollbar
      ? scrollableContent.clientHeight
      : scrollableContent.offsetHeight)
      || scrollableContent.clientHeight
      || scrollableContent.offsetHeight
      || scrollableContent.scrollHeight;
    if (scrollableHeight > 0) {
      return scrollableHeight;
    }
    const ownerWindow = scrollableContent.ownerDocument?.defaultView
      || (typeof window !== 'undefined' ? window : null);
    const computedHeight = parseFloat(
      ownerWindow?.getComputedStyle?.(scrollableContent)?.height || '0'
    );
    if (Number.isFinite(computedHeight) && computedHeight > 0) {
      return computedHeight;
    }
  }

  const lockedTable = findKendoGridLockedTable(root) || lockedContent?.querySelector?.('table');
  if (lockedTable?.offsetHeight > 0) {
    return lockedTable.offsetHeight;
  }

  const lockedRows = findKendoGridLockedRows(root);
  const lockedRowsHeight = sumElementHeights(lockedRows);
  if (lockedRowsHeight > 0) {
    return lockedRowsHeight;
  }

  return 0;
}

function resolveLockedWidth(senderOrRoot, root, lockedHeader, lockedContent, lockedHeaderTable, lockedTable) {
  const expectedColumnWidth = readLockedColumnsWidth(senderOrRoot, root);
  const expectedInlineWidth = readElementInlineWidth(lockedHeader, root)
    || readElementInlineWidth(lockedContent, root);
  if (expectedColumnWidth > 0) {
    if (expectedInlineWidth > 0 && expectedInlineWidth <= Math.ceil(expectedColumnWidth * 1.15)) {
      return expectedInlineWidth;
    }
    return expectedColumnWidth;
  }
  if (expectedInlineWidth > 0) {
    return expectedInlineWidth;
  }
  const tableWidth = readTableWidth(lockedHeaderTable) || readTableWidth(lockedTable);
  if (tableWidth > 0) {
    return tableWidth;
  }
  return readElementRenderedWidth(lockedHeader) || readElementRenderedWidth(lockedContent);
}

function readColumnResizeInteractionDepth(root) {
  const depth = Number(root?.dataset?.ntssColumnResizeDepth || 0);
  return Number.isFinite(depth) && depth > 0 ? depth : 0;
}

export function isKendoGridColumnResizeActive(senderOrRoot) {
  const root = resolveGridRoot(senderOrRoot);
  return readColumnResizeInteractionDepth(root) > 0;
}

function setColumnResizeInteractionDepth(root, depth) {
  if (!root?.dataset) {
    return;
  }
  const nextDepth = Math.max(0, Number(depth) || 0);
  if (nextDepth > 0) {
    root.dataset.ntssColumnResizeDepth = String(nextDepth);
  } else {
    delete root.dataset.ntssColumnResizeDepth;
  }
}

export function attachKendoGridColumnResizeGuard(senderOrRoot, options = {}) {
  const root = resolveGridRoot(senderOrRoot);
  if (!root || typeof root.addEventListener !== 'function') {
    return () => {};
  }
  const cleanupList = Array.isArray(options?.cleanupList) ? options.cleanupList : null;
  const attachedKey = '__ntssKendoColumnResizeGuardAttached';
  if (!cleanupList && root[attachedKey]) {
    return () => {};
  }
  if (!cleanupList) {
    root[attachedKey] = true;
  }

  const ownerDocument = root.ownerDocument || (typeof document !== 'undefined' ? document : null);
  const ownerWindow = ownerDocument?.defaultView || (typeof window !== 'undefined' ? window : null);
  let pendingRepair = false;

  const scheduleDeferredRepair = () => {
    if (typeof options.onResizeEnd !== 'function') {
      return;
    }
    if (pendingRepair) {
      return;
    }
    pendingRepair = true;
    const run = () => {
      pendingRepair = false;
      options.onResizeEnd();
    };
    if (typeof ownerWindow?.requestAnimationFrame === 'function') {
      ownerWindow.requestAnimationFrame(run);
    } else {
      ownerWindow?.setTimeout?.(run, 0);
    }
  };

  let endTimer = 0;
  const beginResize = () => {
    if (endTimer) {
      ownerWindow?.clearTimeout?.(endTimer);
      endTimer = 0;
    }
    setColumnResizeInteractionDepth(root, readColumnResizeInteractionDepth(root) + 1);
  };

  const endResize = () => {
    if (endTimer) {
      ownerWindow?.clearTimeout?.(endTimer);
    }
    endTimer = ownerWindow?.setTimeout?.(() => {
      endTimer = 0;
      const nextDepth = readColumnResizeInteractionDepth(root) - 1;
      setColumnResizeInteractionDepth(root, nextDepth);
      if (nextDepth === 0) {
        scheduleDeferredRepair();
      }
    }, 120) || 0;
    if (!endTimer) {
      const nextDepth = readColumnResizeInteractionDepth(root) - 1;
      setColumnResizeInteractionDepth(root, nextDepth);
      if (nextDepth === 0) {
        scheduleDeferredRepair();
      }
    }
  };

  const onPointerDown = (event) => {
    if (event.button != null && event.button !== 0) {
      return;
    }
    if (!event.target?.closest?.('.k-resize-handle')) {
      return;
    }
    beginResize();
    const onPointerEnd = () => {
      ownerDocument?.removeEventListener?.('mouseup', onPointerEnd, true);
      ownerDocument?.removeEventListener?.('touchend', onPointerEnd, true);
      endResize();
    };
    ownerDocument?.addEventListener?.('mouseup', onPointerEnd, true);
    ownerDocument?.addEventListener?.('touchend', onPointerEnd, true);
  };

  root.addEventListener('mousedown', onPointerDown, true);
  root.addEventListener('touchstart', onPointerDown, true);

  const cleanup = () => {
    root.removeEventListener('mousedown', onPointerDown, true);
    root.removeEventListener('touchstart', onPointerDown, true);
    if (endTimer) {
      ownerWindow?.clearTimeout?.(endTimer);
      endTimer = 0;
    }
    setColumnResizeInteractionDepth(root, 0);
    pendingRepair = false;
    if (!cleanupList) {
      delete root[attachedKey];
    }
  };
  cleanupList?.push(cleanup);
  return cleanup;
}

export function measureKendoGridLockedContentHeight(root, lockedContent, scrollableContent) {
  return resolveLockedContentHeight(root, lockedContent, scrollableContent);
}

export function repairKendoGridLockedColumnLayout(senderOrRoot) {
  const root = resolveGridRoot(senderOrRoot);
  if (!root || typeof root.querySelector !== 'function') {
    return false;
  }
  if (isKendoGridColumnResizeActive(root)) {
    return false;
  }
  const lockedHeader = findKendoGridLockedHeader(root);
  const lockedContent = findKendoGridLockedContent(root);
  if (!lockedHeader && !lockedContent) {
    return false;
  }
  const lockedHeaderTable =
    lockedHeader?.querySelector?.('table') || null;

  const lockedTable =
    findKendoGridLockedTable(root) ||
    lockedContent?.querySelector?.('table') ||
    null;

  const lockedWidth = resolveLockedWidth(
    senderOrRoot,
    root,
    lockedHeader,
    lockedContent,
    lockedHeaderTable,
    lockedTable
  );

  const scrollableContent = resolveGridContent(senderOrRoot) || findKendoGridContent(root);
  const lockedHeight = resolveLockedContentHeight(root, lockedContent, scrollableContent);

  let changed = false;
  changed = syncKendoGridLogicalRowHeights(root) || changed;

  if (Number.isFinite(lockedWidth) && lockedWidth > 0) {
    changed = setPixelWidth(lockedHeader, lockedWidth) || changed;
    changed = setPixelWidth(lockedContent, lockedWidth) || changed;
  }

  if (Number.isFinite(lockedHeight) && lockedHeight > 0) {
    changed = setPixelHeight(lockedContent, lockedHeight) || changed;
    if (
      scrollableContent
      && scrollableContent !== lockedContent
      && lockedContent.scrollHeight > lockedContent.clientHeight
    ) {
      lockedContent.scrollTop = readActualScrollTop(
        senderOrRoot,
        scrollableContent,
        resolveVerticalScrollbar(senderOrRoot)
      );
    }
  }

  if (!changed) {
    return false;
  }
  if (Number.isFinite(lockedWidth) && lockedWidth > 0) {
    const resizeHandle =
      lockedHeader?.querySelector?.('.k-resize-handle') || null;

    if (resizeHandle) {
      const handleWidth =
        resizeHandle.getBoundingClientRect?.().width ||
        parseFloat(resizeHandle.style?.width || '0') ||
        0;

      const nextLeft =
        `${Math.max(
          0,
          Math.round(
            (lockedWidth - handleWidth / 2) * 10
          ) / 10
        )}px`;

      if (resizeHandle.style.left !== nextLeft) {
        resizeHandle.style.left = nextLeft;
        changed = true;
      }
    }
  }

  return changed;
}

export function attachKendoGridLockedLayoutRepair(senderOrRoot, options = {}) {
  const root = resolveGridRoot(senderOrRoot);
  if (!root || typeof root.querySelector !== 'function') {
    return () => {};
  }
  const cleanupList = Array.isArray(options?.cleanupList) ? options.cleanupList : null;
  const attachedKey = '__ntssKendoLockedLayoutRepairAttached';
  if (root[attachedKey]) {
    return () => {};
  }
  root[attachedKey] = true;

  let frameId = 0;
  const scheduleRepair = () => {
    if (isKendoGridColumnResizeActive(root)) {
      return;
    }
    if (frameId) {
      return;
    }
    const ownerWindow = root.ownerDocument?.defaultView || window;
    frameId = ownerWindow.requestAnimationFrame?.(() => {
      frameId = 0;
      repairKendoGridLockedColumnLayout(senderOrRoot);
    }) || setTimeout(() => {
      frameId = 0;
      repairKendoGridLockedColumnLayout(senderOrRoot);
    }, 0);
  };

  const attributeObserverTargets = uniqueElements([
    findKendoGridLockedHeader(root),
    findKendoGridLockedContent(root),
    findKendoGridLockedHeader(root)?.querySelector?.('table') || null,
    findKendoGridLockedTable(root),
    findKendoGridContent(root),
    findKendoGridTable(root)
  ].filter(Boolean));
  const logicalTableObserverTargets = uniqueElements([
    findKendoGridTbody(root),
    findKendoGridLockedTbody(root)
  ].filter(Boolean));
  const MutationObserverCtor = root.ownerDocument?.defaultView?.MutationObserver || (typeof MutationObserver !== 'undefined' ? MutationObserver : null);
  const observers = [];
  if (MutationObserverCtor) {
    attributeObserverTargets.forEach((target) => {
      const observer = new MutationObserverCtor(scheduleRepair);
      observer.observe(target, { attributes: true, attributeFilter: ['style', 'class'] });
      observers.push(observer);
    });
    logicalTableObserverTargets.forEach((target) => {
      const observer = new MutationObserverCtor(scheduleRepair);
      observer.observe(target, { childList: true });
      observers.push(observer);
    });
  }

  repairKendoGridLockedColumnLayout(senderOrRoot);
  scheduleRepair();

  const cleanup = () => {
    observers.forEach((observer) => observer.disconnect());
    observers.length = 0;
    if (frameId) {
      const ownerWindow = root.ownerDocument?.defaultView || window;
      ownerWindow.cancelAnimationFrame?.(frameId) || clearTimeout(frameId);
      frameId = 0;
    }
    delete root[attachedKey];
  };
  cleanupList?.push(cleanup);
  return cleanup;
}

function resolveVerticalScrollbar(senderOrRoot) {
  const sender = senderOrRoot?.sender || senderOrRoot;
  const root = resolveGridRoot(senderOrRoot);
  return firstElement(sender?.virtualScrollable?.verticalScrollbar)
    || firstElement(sender?.lockedScrollbar)
    || findKendoGridVerticalScrollbar(root)
    || null;
}

function readScrollTop(content, verticalScrollbar, virtual = false) {
  const contentTop = Number(content?.scrollTop);
  const scrollbarTop = Number(verticalScrollbar?.scrollTop);
  const childTop = Number(content?.lastChild?.scrollTop);
  if (virtual) {
    if (Number.isFinite(childTop) && childTop !== 0) return childTop;
    if (Number.isFinite(scrollbarTop) && scrollbarTop !== 0) return scrollbarTop;
    if (Number.isFinite(contentTop)) return contentTop;
    if (Number.isFinite(scrollbarTop)) return scrollbarTop;
    return Number.isFinite(childTop) ? childTop : 0;
  }
  if (Number.isFinite(contentTop) && contentTop !== 0) return contentTop;
  if (Number.isFinite(scrollbarTop) && scrollbarTop !== 0) return scrollbarTop;
  if (Number.isFinite(childTop) && childTop !== 0) return childTop;
  if (Number.isFinite(contentTop)) return contentTop;
  if (Number.isFinite(scrollbarTop)) return scrollbarTop;
  return Number.isFinite(childTop) ? childTop : 0;
}

function readScrollLeft(content, virtual = false) {
  const contentLeft = Number(content?.scrollLeft);
  const childLeft = Number(content?.firstChild?.scrollLeft);
  if (virtual) {
    if (Number.isFinite(childLeft) && childLeft !== 0) return childLeft;
    if (Number.isFinite(contentLeft)) return contentLeft;
    return Number.isFinite(childLeft) ? childLeft : 0;
  }
  if (Number.isFinite(contentLeft) && contentLeft !== 0) return contentLeft;
  if (Number.isFinite(childLeft)) return childLeft;
  return Number.isFinite(contentLeft) ? contentLeft : 0;
}

function writeScrollLeft(content, left) {
  if (!content || !Number.isFinite(left)) return;
  if (content.firstChild && content.firstChild !== content) {
    content.firstChild.scrollLeft = left;
  }
  content.scrollLeft = left;
}

function writeScrollTop(content, verticalScrollbar, top, virtual = false) {
  if (!Number.isFinite(top)) return;
  if (virtual && content?.lastChild && content.lastChild !== content) {
    content.lastChild.scrollTop = top;
  }
  if (content) {
    content.scrollTop = top;
  }
  if (verticalScrollbar) {
    verticalScrollbar.scrollTop = top;
  }
}

function resolveLockedContents(senderOrRoot, root = null) {
  const gridRoot = root
    || resolveGridRoot(senderOrRoot)
    || findKendoGridRoot(firstElement(senderOrRoot))
    || firstElement(senderOrRoot);
  const lockedContents = Array.from(gridRoot?.querySelectorAll?.('.k-grid-content-locked') || []);
  const directLockedContent = findKendoGridLockedContent(gridRoot || senderOrRoot);
  if (directLockedContent && !lockedContents.includes(directLockedContent)) {
    lockedContents.unshift(directLockedContent);
  }
  return lockedContents;
}

function writeLockedScrollTop(lockedContents, top, exclude = null) {
  if (!Number.isFinite(top)) {
    return false;
  }
  let changed = false;
  (lockedContents || []).forEach((lockedContent) => {
    if (!lockedContent || lockedContent === exclude) {
      return;
    }
    if (lockedContent.scrollTop !== top) {
      lockedContent.scrollTop = top;
      changed = true;
    }
  });
  return changed;
}

function dispatchScrollEvent(target) {
  if (!target || typeof target.dispatchEvent !== 'function') {
    return false;
  }
  const ownerWindow = target.ownerDocument?.defaultView || (typeof window !== 'undefined' ? window : null);
  const EventCtor = ownerWindow?.Event || (typeof Event !== 'undefined' ? Event : null);
  if (!EventCtor) {
    return false;
  }
  try {
    target.dispatchEvent(new EventCtor('scroll', { bubbles: false, cancelable: false }));
    return true;
  } catch (_error) {
    return false;
  }
}

function readActualScrollTop(senderOrRoot, content = null, verticalScrollbar = null, virtual = false) {
  const resolvedContent = content || resolveGridContent(senderOrRoot);
  const resolvedVerticalScrollbar = verticalScrollbar || resolveVerticalScrollbar(senderOrRoot);
  return readScrollTop(resolvedContent, resolvedVerticalScrollbar, virtual);
}

export function syncKendoGridLockedScrollTop(senderOrRoot, top, options = {}) {
  if (!Number.isFinite(top)) {
    return false;
  }
  const root = resolveGridRoot(senderOrRoot);
  const lockedContents = resolveLockedContents(senderOrRoot, root);
  if (lockedContents.length === 0) {
    return false;
  }
  const exclude = options?.exclude || null;
  const changed = writeLockedScrollTop(lockedContents, top, exclude);
  if (options?.defer === false) {
    return changed;
  }
  const ownerDocument = root?.ownerDocument
    || lockedContents[0]?.ownerDocument
    || (typeof document !== 'undefined' ? document : null);
  const ownerWindow = ownerDocument?.defaultView || (typeof window !== 'undefined' ? window : null);
  const run = () => writeLockedScrollTop(resolveLockedContents(senderOrRoot, root), top, exclude);
  if (typeof ownerWindow?.requestAnimationFrame === 'function') {
    ownerWindow.requestAnimationFrame(run);
  } else if (typeof ownerWindow?.setTimeout === 'function') {
    ownerWindow.setTimeout(run, 16);
  } else if (typeof setTimeout === 'function') {
    setTimeout(run, 16);
  }
  return true;
}

function syncLockedScrollTopFromCurrentScrollable(senderOrRoot, options = {}) {
  const virtual = options?.virtual === true;
  if (virtual) {
    return false;
  }
  const content = resolveGridContent(senderOrRoot);
  const verticalScrollbar = resolveVerticalScrollbar(senderOrRoot);
  const currentTop = readActualScrollTop(senderOrRoot, content, verticalScrollbar, virtual);
  if (!Number.isFinite(currentTop)) {
    return false;
  }
  return syncKendoGridLockedScrollTop(senderOrRoot, currentTop, {
    exclude: options?.exclude || null,
    defer: false
  });
}

function scheduleLockedScrollTopSyncFromCurrent(senderOrRoot, options = {}) {
  const root = resolveGridRoot(senderOrRoot);
  const ownerDocument = root?.ownerDocument || (typeof document !== 'undefined' ? document : null);
  const ownerWindow = ownerDocument?.defaultView || (typeof window !== 'undefined' ? window : null);
  const run = () => syncLockedScrollTopFromCurrentScrollable(senderOrRoot, options);
  if (typeof ownerWindow?.requestAnimationFrame === 'function') {
    ownerWindow.requestAnimationFrame(run);
  } else if (typeof ownerWindow?.setTimeout === 'function') {
    ownerWindow.setTimeout(run, 16);
  } else if (typeof setTimeout === 'function') {
    setTimeout(run, 16);
  }
  ownerWindow?.setTimeout?.(run, options?.delay ?? 80);
  return true;
}

function notifyKendoGridScrollTargets(content, verticalScrollbar, virtual = false) {
  const targets = [
    verticalScrollbar,
    content,
    virtual ? content?.lastChild : content?.firstElementChild
  ].filter(Boolean);
  targets.forEach(dispatchScrollEvent);
}

export function captureKendoGridScrollPosition(senderOrRoot, options = {}) {
  const virtual = options?.virtual === true;
  const content = resolveGridContent(senderOrRoot);
  const verticalScrollbar = resolveVerticalScrollbar(senderOrRoot);
  return {
    top: readScrollTop(content, verticalScrollbar, virtual),
    left: readScrollLeft(content, virtual)
  };
}

export function restoreKendoGridScrollPosition(senderOrRoot, position = {}, options = {}) {
  const virtual = options?.virtual === true;
  const content = resolveGridContent(senderOrRoot);
  const verticalScrollbar = resolveVerticalScrollbar(senderOrRoot);
  const lockedContents = resolveLockedContents(senderOrRoot);
  const top = Number.isFinite(position?.top) ? position.top : null;
  const left = Number.isFinite(position?.left) ? position.left : null;
  if (!content && !verticalScrollbar && lockedContents.length === 0) {
    return false;
  }
  if (left !== null && content) {
    writeScrollLeft(content, left);
  }
  if (top !== null) {
    writeScrollTop(content, verticalScrollbar, top, virtual);
    if (!virtual && lockedContents.length > 0) {
      syncLockedScrollTopFromCurrentScrollable(senderOrRoot, { exclude: content });
      scheduleLockedScrollTopSyncFromCurrent(senderOrRoot, { exclude: content });
      notifyKendoGridScrollTargets(content, verticalScrollbar, virtual);
    }
  }
  return true;
}

export function attachKendoGridLockedContentScrollSync(senderOrRoot, options = {}) {
  const gridRoot = resolveGridRoot(senderOrRoot);
  const sender = resolveGridSender(senderOrRoot);
  const lockedContent = findKendoGridLockedContent(gridRoot || senderOrRoot);
  const scrollableContent = resolveGridContent(senderOrRoot);
  const headerScrollHost = resolveGridHeaderScrollHost(senderOrRoot);
  const verticalScrollbar = resolveVerticalScrollbar(senderOrRoot);
  const virtual = options?.virtual === true
    || !!sender?.virtualScrollable
    || !!gridRoot?.querySelector?.('.k-virtual-scrollable-wrap');
  const hasLockedContent = !!lockedContent && !!scrollableContent && lockedContent !== scrollableContent;
  if (!scrollableContent || (!hasLockedContent && !headerScrollHost)) {
    return () => {};
  }

  const cleanups = [];
  const cleanupList = Array.isArray(options?.cleanupList) ? options.cleanupList : null;
  const attachedKey = '__ntssKendoLockedContentScrollAttached';
  if (!cleanupList && scrollableContent[attachedKey] && (!hasLockedContent || lockedContent[attachedKey])) {
    return () => {};
  }
  if (!cleanupList) {
    if (hasLockedContent) {
      lockedContent[attachedKey] = true;
    }
    scrollableContent[attachedKey] = true;
  }

  const addListener = (target, eventName, handler, listenerOptions = undefined) => {
    if (!target) return;
    target.addEventListener(eventName, handler, listenerOptions);
    cleanups.push(() => target.removeEventListener(eventName, handler, listenerOptions));
  };

  const syncScrollableHeaderLeft = () => {
    if (!headerScrollHost || !scrollableContent) {
      return;
    }
    const left = readScrollLeft(scrollableContent, virtual);
    if (Number.isFinite(left)) {
      writeScrollLeft(headerScrollHost, left);
    }
  };
  const syncVerticalTop = (top, source) => {
    if (!Number.isFinite(top)) {
      return;
    }
    if (virtual) {
      return;
    }
    if (hasLockedContent && source !== lockedContent) {
      lockedContent.scrollTop = top;
    }
    if (source !== scrollableContent) {
      writeScrollTop(scrollableContent, null, top);
    }
    if (verticalScrollbar && source !== verticalScrollbar) {
      verticalScrollbar.scrollTop = top;
    }
  };
  const readCanonicalVerticalTop = () => readScrollTop(scrollableContent, verticalScrollbar, virtual);

  if (hasLockedContent && options?.layoutRepair !== false) {
    const lockedLayoutCleanup = attachKendoGridLockedLayoutRepair(senderOrRoot, { cleanupList });
    if (!cleanupList && typeof lockedLayoutCleanup === 'function') {
      cleanups.push(lockedLayoutCleanup);
    }
  }

  if (hasLockedContent && !virtual && options?.wheel !== false) {
    addListener(lockedContent, 'wheel', (event) => {
      event.preventDefault();
      syncVerticalTop(readCanonicalVerticalTop() + (event.deltaY || 0), null);
    }, { passive: false });
  }

  if (hasLockedContent && !virtual && options?.touch !== false) {
    let startY = 0;
    addListener(lockedContent, 'touchstart', (event) => {
      startY = event.touches?.[0]?.clientY || 0;
    }, { passive: false });
    addListener(lockedContent, 'touchmove', (event) => {
      const currentY = event.touches?.[0]?.clientY || startY;
      const deltaY = startY - currentY;
      syncVerticalTop(readCanonicalVerticalTop() + deltaY, null);
      startY = currentY;
      event.preventDefault();
    }, { passive: false });
  }

  let syncing = false;
  if (hasLockedContent && !virtual) {
    addListener(lockedContent, 'scroll', () => {
      if (syncing) return;
      syncing = true;
      syncVerticalTop(readCanonicalVerticalTop(), scrollableContent);
      options?.onLockedScroll?.({ lockedContent, scrollableContent, verticalScrollbar });
      syncing = false;
    });
  }
  addListener(scrollableContent, 'scroll', () => {
    if (syncing) return;
    syncing = true;
    if (hasLockedContent && !virtual) {
      syncVerticalTop(readScrollTop(scrollableContent, verticalScrollbar), scrollableContent);
    }
    syncScrollableHeaderLeft();
    options?.onScrollableScroll?.({ lockedContent, scrollableContent, headerScrollHost, verticalScrollbar });
    syncing = false;
  });
  if (scrollableContent.firstElementChild && scrollableContent.firstElementChild !== scrollableContent) {
    addListener(scrollableContent.firstElementChild, 'scroll', () => {
      if (syncing) return;
      syncing = true;
      if (!virtual) {
        syncVerticalTop(readScrollTop(scrollableContent, verticalScrollbar), scrollableContent.firstElementChild);
      }
      syncScrollableHeaderLeft();
      syncing = false;
    });
  }
  if (verticalScrollbar && verticalScrollbar !== scrollableContent && verticalScrollbar !== lockedContent) {
    addListener(verticalScrollbar, 'scroll', () => {
      if (syncing) return;
      syncing = true;
      if (!virtual) {
        syncVerticalTop(verticalScrollbar.scrollTop || 0, verticalScrollbar);
      }
      syncScrollableHeaderLeft();
      options?.onScrollableScroll?.({ lockedContent, scrollableContent, headerScrollHost, verticalScrollbar });
      syncing = false;
    });
  }
  if (hasLockedContent) {
    repairKendoGridLockedColumnLayout(senderOrRoot);
    if (!virtual) {
      syncVerticalTop(readScrollTop(scrollableContent, verticalScrollbar), scrollableContent);
      scheduleLockedScrollTopSyncFromCurrent(senderOrRoot, { exclude: scrollableContent });
    }
  }
  syncScrollableHeaderLeft();

  const cleanup = () => {
    while (cleanups.length) {
      try {
        cleanups.pop()?.();
      } catch (_error) {
        // noop
      }
    }
    if (!cleanupList) {
      if (hasLockedContent) {
        delete lockedContent[attachedKey];
      }
      delete scrollableContent[attachedKey];
    }
  };
  cleanupList?.push(cleanup);
  return cleanup;
}

export function detachKendoGridLockedContentScroll(senderOrRoot) {
  const gridRoot = resolveGridRoot(senderOrRoot);
  const cleanupInfo = gridRoot?.__ntssKendoLockedContentScrollCleanupInfo || null;
  const cleanup = cleanupInfo?.cleanup || gridRoot?.__ntssKendoLockedContentScrollCleanup || null;
  if (!cleanup) {
    return false;
  }
  try {
    cleanup();
  } catch (_error) {
    // noop
  }
  delete gridRoot.__ntssKendoLockedContentScrollCleanup;
  delete gridRoot.__ntssKendoLockedContentScrollCleanupInfo;
  return true;
}

export function syncKendoGridLockedContentScroll(senderOrRoot, options = {}) {
  const gridRoot = resolveGridRoot(senderOrRoot);
  const lockedContent = findKendoGridLockedContent(gridRoot || senderOrRoot);
  const scrollableContent = resolveGridContent(senderOrRoot);
  if (!gridRoot || !lockedContent || !scrollableContent || lockedContent === scrollableContent) {
    return false;
  }

  const current = gridRoot.__ntssKendoLockedContentScrollCleanupInfo || null;
  if (typeof current?.cleanup === 'function') {
    if (current.lockedContent === lockedContent && current.scrollableContent === scrollableContent) {
      return true;
    }
    detachKendoGridLockedContentScroll(gridRoot);
  }

  const cleanup = attachKendoGridLockedContentScrollSync(gridRoot, options);
  const wrappedCleanup = () => {
    try {
      cleanup?.();
    } finally {
      delete gridRoot.__ntssKendoLockedContentScrollCleanup;
      delete gridRoot.__ntssKendoLockedContentScrollCleanupInfo;
    }
  };
  gridRoot.__ntssKendoLockedContentScrollCleanup = wrappedCleanup;
  gridRoot.__ntssKendoLockedContentScrollCleanupInfo = {
    cleanup: wrappedCleanup,
    lockedContent,
    scrollableContent
  };
  return true;
}
