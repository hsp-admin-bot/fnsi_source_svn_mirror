/**
 * マルチ患者リスト系 Kendo Grid: 固定列ヘッダをスクロール側の多段ヘッダ高さに合わせる。
 * データ行が無いとき Kendo は locked 側に第2行ヘッダを残し、空白が出るため DOM で rowspan を同期する。
 */

const SYNC_INLINE_HEIGHT_PROPS = ['height', 'minHeight', 'maxHeight'];

function toKebabCase(prop) {
  return prop.replace(/[A-Z]/g, (m) => `-${m.toLowerCase()}`);
}

function clearSyncInlineHeights(element) {
  if (!element?.style) {
    return;
  }
  SYNC_INLINE_HEIGHT_PROPS.forEach((prop) => {
    element.style.removeProperty(toKebabCase(prop));
  });
}

/**
 * 前回のヘッダ同期で付与した inline 高さを除去し、自然レイアウトで再計測できるようにする。
 */
export function resetMultiPatGridHeaderLayoutStyles(headerWrap, lockedHeader) {
  if (headerWrap) {
    headerWrap.style.removeProperty('overflow');
    [
      headerWrap,
      headerWrap.querySelector('table'),
      headerWrap.querySelector('thead'),
    ].forEach(clearSyncInlineHeights);
    headerWrap.querySelectorAll('tr, th, .k-cell-inner, .k-link').forEach(clearSyncInlineHeights);
  }
  if (lockedHeader) {
    [
      lockedHeader,
      lockedHeader.querySelector('table'),
      lockedHeader.querySelector('thead'),
    ].forEach(clearSyncInlineHeights);
    lockedHeader.querySelectorAll('tr, th, .k-cell-inner, .k-link').forEach(clearSyncInlineHeights);
  }
}

function measureScrollTheadHeight(scrollThead) {
  if (!scrollThead) {
    return 0;
  }
  return Math.round(scrollThead.getBoundingClientRect().height);
}

/** MultiPatList: 患者ID・患者名のみ rowspan 対象 */
export const PAT_LOCKED_HEADER_FIELDS = [
  'pat_personal_main$hosp_pat_id',
  'pat_personal_main$pat_name',
];

export function isPatLockedHeaderCell(cell) {
  const field = cell.getAttribute('data-field') || '';
  if (PAT_LOCKED_HEADER_FIELDS.includes(field)) {
    return true;
  }
  const title = (cell.getAttribute('data-title') || '').trim();
  return title === '患者ID' || title === '患者名';
}

/** ExamRecord 一覧: 患者ID・患者名・最終検査日のみ rowspan 対象 */
export const EXAM_RECORD_LOCKED_HEADER_FIELDS = [
  'hosp_pat_id',
  'pat_name',
  'viewTreatDate',
];

export function isExamRecordLockedHeaderCell(cell) {
  const field = cell.getAttribute('data-field') || '';
  if (EXAM_RECORD_LOCKED_HEADER_FIELDS.includes(field)) {
    return true;
  }
  const title = (cell.getAttribute('data-title') || '').trim();
  return title === '患者ID' || title === '患者名' || title === '最終検査日';
}

export function syncLockedHeaderRowSpan(headerWrap, lockedHeader, options = {}) {
  if (!headerWrap || !lockedHeader) {
    return;
  }

  const lockedHeaderCellFilter = options.lockedHeaderCellFilter || (() => true);

  const scrollThead = headerWrap.querySelector('thead');
  const lockedThead = lockedHeader.querySelector('thead');
  if (!scrollThead || !lockedThead) {
    return;
  }

  const scrollRows = Array.from(scrollThead.querySelectorAll(':scope > tr'));
  const rowSpan = scrollRows.length;
  if (rowSpan <= 1) {
    return;
  }

  const scrollHeaderHeight = measureScrollTheadHeight(scrollThead);
  const lockedRows = Array.from(lockedThead.querySelectorAll(':scope > tr'));
  if (lockedRows.length === 0) {
    return;
  }

  const firstRow = lockedRows[0];
  const cellsToSpan = Array.from(firstRow.querySelectorAll('th')).filter(lockedHeaderCellFilter);
  if (cellsToSpan.length === 0) {
    return;
  }

  cellsToSpan.forEach((cell) => {
    if (Number(cell.rowSpan) !== rowSpan) {
      cell.rowSpan = rowSpan;
    }
    cell.style.verticalAlign = 'middle';
    cell.style.boxSizing = 'border-box';
    if (scrollHeaderHeight > 0) {
      cell.style.height = `${scrollHeaderHeight}px`;
    }
    cell.querySelectorAll('.k-cell-inner, .k-link').forEach((inner) => {
      inner.style.boxSizing = 'border-box';
      clearSyncInlineHeights(inner);
    });
  });

  for (let rowIndex = 1; rowIndex < lockedRows.length; rowIndex += 1) {
    const row = lockedRows[rowIndex];
    Array.from(row.querySelectorAll('th')).forEach((cell) => {
      if (lockedHeaderCellFilter(cell) || Number(cell.rowSpan) > 1) {
        cell.remove();
      }
    });
    if (row.cells.length === 0) {
      row.remove();
    }
  }
}

/**
 * locked 側ヘッダ外枠をスクロール thead の自然高に合わせる（底部ズレ対策）。
 * スクロール側 thead には高さを書き戻さない（書き戻すと再計測のたびに高さが累積する）。
 */
export function syncLockedAndScrollHeaderHeights(headerWrap, lockedHeader) {
  if (!headerWrap || !lockedHeader) {
    return;
  }

  const scrollThead = headerWrap.querySelector('thead');
  if (!scrollThead) {
    return;
  }

  const scrollTheadHeight = measureScrollTheadHeight(scrollThead);
  if (scrollTheadHeight <= 0) {
    return;
  }

  const applyLockedBlockHeight = (element) => {
    if (!element) {
      return;
    }
    element.style.height = `${scrollTheadHeight}px`;
    element.style.minHeight = `${scrollTheadHeight}px`;
    element.style.boxSizing = 'border-box';
  };

  applyLockedBlockHeight(lockedHeader);
  applyLockedBlockHeight(lockedHeader.querySelector('table'));

  const lockedThead = lockedHeader.querySelector('thead');
  if (!lockedThead) {
    return;
  }

  applyLockedBlockHeight(lockedThead);
  lockedThead.querySelectorAll('th').forEach((cell) => {
    cell.style.boxSizing = 'border-box';
    if (Number(cell.rowSpan) > 1) {
      cell.style.height = `${scrollTheadHeight}px`;
    }
  });
}

export function syncScrollableLeafHeaderRowSpan(headerWrap) {
  if (!headerWrap) {
    return;
  }

  const scrollThead = headerWrap.querySelector('thead');
  if (!scrollThead) {
    return;
  }

  const scrollRows = Array.from(scrollThead.querySelectorAll(':scope > tr'));
  const rowSpan = scrollRows.length;
  if (rowSpan <= 1) {
    return;
  }

  const scrollHeaderHeight = measureScrollTheadHeight(scrollThead);
  const isCardCreationHeaderCell = (cell) => {
    const title = (cell.getAttribute('data-title') || '').trim();
    return title === 'カード作成'
      || cell.classList.contains('multi-pat-card-creation-header');
  };

  const applyLeafHeaderCellLayout = (cell) => {
    cell.classList.remove('btn3-kendo-normal', 'multi-pat-card-creation-body');
    cell.classList.add('k-header', 'multi-pat-card-creation-header');
    if (Number(cell.rowSpan) !== rowSpan) {
      cell.rowSpan = rowSpan;
    }
    cell.style.verticalAlign = 'middle';
    cell.style.boxSizing = 'border-box';
    if (scrollHeaderHeight > 0 && Number(cell.rowSpan) > 1) {
      cell.style.height = `${scrollHeaderHeight}px`;
    } else {
      clearSyncInlineHeights(cell);
    }
    cell.querySelectorAll('.k-cell-inner, .k-link').forEach((inner) => {
      inner.style.boxSizing = 'border-box';
      clearSyncInlineHeights(inner);
    });
  };

  scrollRows.forEach((row, rowIndex) => {
    Array.from(row.querySelectorAll('th')).forEach((cell) => {
      if (rowIndex === 0 && isCardCreationHeaderCell(cell)) {
        applyLeafHeaderCellLayout(cell);
      }
    });
  });
}

export function syncMultiPatGridLockedHeaderLayout(headerWrap, lockedHeader, options = {}) {
  resetMultiPatGridHeaderLayoutStyles(headerWrap, lockedHeader);
  syncLockedHeaderRowSpan(headerWrap, lockedHeader, options);
  syncScrollableLeafHeaderRowSpan(headerWrap);
  syncLockedAndScrollHeaderHeights(headerWrap, lockedHeader);
}
