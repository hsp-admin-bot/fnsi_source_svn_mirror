const DEFAULT_MENU_WIDTH = 240;
const DEFAULT_MENU_Z_INDEX = "2147483647";
const MENU_OWNER_ATTR = "data-ntss-calendar-owner";
const MENU_FLOATING_CLASS = "ntss-custom-calendar-menu";
const MENU_PANEL_READY_CLASS = "ntss-custom-calendar-panel-ready";
const MENU_PANEL_POSITIONING_CLASS = "ntss-custom-calendar-panel-positioning";
const MENU_POSITIONED_CLASS = "ntss-custom-calendar-panel-positioned";
const NTSS_CALENDAR_PANEL_SELECTOR = ".dp__menu.ntss-custom-calendar-panel";
const flashGuardDocuments = new WeakSet();

const toElement = value => {
  if (!value) {
    return null;
  }
  if (typeof Element !== "undefined" && value instanceof Element) {
    return value;
  }
  return typeof Element !== "undefined" && value?.$el instanceof Element ? value.$el : null;
};

const getOwnerDocument = root => {
  const element = toElement(root);
  return element?.ownerDocument || globalThis.document || null;
};

const cssEscape = value => {
  const text = `${value || ""}`;
  if (!text) {
    return "";
  }
  if (globalThis.CSS?.escape) {
    return globalThis.CSS.escape(text);
  }
  return text.replace(/["\\]/g, "\\$&");
};

const setStyleValue = (element, name, value) => {
  if (!element) {
    return;
  }
  const resolved = `${value}`;
  if (element.style[name] !== resolved) {
    element.style[name] = resolved;
  }
};

const removeStyleValue = (element, name) => {
  if (!element) {
    return;
  }
  if (element.style[name]) {
    element.style[name] = "";
  }
};

const clearDatePickerMenuPosition = wrapper => {
  if (!wrapper) {
    return;
  }
  removeStyleValue(wrapper, "position");
  removeStyleValue(wrapper, "left");
  removeStyleValue(wrapper, "right");
  removeStyleValue(wrapper, "top");
  removeStyleValue(wrapper, "bottom");
  removeStyleValue(wrapper, "transform");
  removeStyleValue(wrapper, "margin");
  removeStyleValue(wrapper, "zIndex");
  removeStyleValue(wrapper, "inset");
  removeStyleValue(wrapper, "visibility");
  removeStyleValue(wrapper, "opacity");
  removeStyleValue(wrapper, "pointerEvents");
};

const ensureMenuWrapperDetached = (wrapper, ownerId) => {
  if (!wrapper) {
    return null;
  }
  const ownerDocument = wrapper.ownerDocument || globalThis.document || null;
  const body = ownerDocument?.body || null;

  // Vue2 の Pikaday は calendar DOM を親 popover のレイアウトツリーに入れない。
  // Vue3 DatePicker の menu wrapper が v-ons-popover 内に残ると、月送り redraw 時に
  // 親 popover のスクロール領域へ流入して位置ずれ/親 header 圧縮を起こすため、
  // 共有 calendar 控件层で body 直下の浮動 DOM として扱う。
  if (ownerId) {
    wrapper.setAttribute(MENU_OWNER_ATTR, ownerId);
  }
  wrapper.classList?.add?.(MENU_FLOATING_CLASS);
  if (body && wrapper.parentElement !== body) {
    body.appendChild(wrapper);
  }
  return wrapper;
};

const stripVueDatePickerFloatingStyles = wrapper => {
  if (!wrapper) {
    return;
  }
  removeStyleValue(wrapper, "transform");
  removeStyleValue(wrapper, "top");
  removeStyleValue(wrapper, "left");
  removeStyleValue(wrapper, "right");
  removeStyleValue(wrapper, "bottom");
  removeStyleValue(wrapper, "width");
};

const markMenuWrapperPositioning = wrapper => {
  if (!wrapper || wrapper.classList?.contains?.(MENU_POSITIONED_CLASS)) {
    return;
  }
  stripVueDatePickerFloatingStyles(wrapper);
  wrapper.classList?.add?.(MENU_PANEL_POSITIONING_CLASS);
  wrapper.classList?.remove?.(MENU_POSITIONED_CLASS);
  setStyleValue(wrapper, "position", "fixed");
  setStyleValue(wrapper, "visibility", "hidden");
  setStyleValue(wrapper, "opacity", "0");
  setStyleValue(wrapper, "pointerEvents", "none");
  setStyleValue(wrapper, "zIndex", "-1");
};

const isNtssCalendarMenuWrapper = wrapper => !!wrapper?.querySelector?.(NTSS_CALENDAR_PANEL_SELECTOR);

const hideNtssMenuWrapperIfNeeded = wrapper => {
  if (!isNtssCalendarMenuWrapper(wrapper)) {
    return;
  }
  markMenuWrapperPositioning(wrapper);
};

const scanNodeForNtssMenuWrappers = node => {
  if (!(node instanceof Element)) {
    return;
  }
  if (node.classList?.contains?.("dp--menu-wrapper")) {
    hideNtssMenuWrapperIfNeeded(node);
  }
  node.querySelectorAll?.(".dp--menu-wrapper")?.forEach(hideNtssMenuWrapperIfNeeded);
};

export const installDatePickerMenuFlashGuard = root => {
  const document = getOwnerDocument(root);
  if (!document?.body || flashGuardDocuments.has(document)) {
    return;
  }
  flashGuardDocuments.add(document);

  const observer = new MutationObserver(mutations => {
    for (const mutation of mutations) {
      mutation.addedNodes.forEach(scanNodeForNtssMenuWrappers);
      if (mutation.type === "attributes" && mutation.target instanceof Element) {
        const target = mutation.target;
        if (target.classList?.contains?.("dp--menu-wrapper")) {
          hideNtssMenuWrapperIfNeeded(target);
        }
      }
    }
  });

  observer.observe(document.body, {
    childList: true,
    subtree: true,
    attributes: true,
    attributeFilter: ["style", "class"]
  });
};

const toFiniteNumber = (value, fallback = 0) => {
  const number = Number(value);
  return Number.isFinite(number) ? number : fallback;
};

const clampToViewport = (value, size, maxSize) => {
  const resolvedValue = toFiniteNumber(value, 0);
  const resolvedSize = Math.max(0, toFiniteNumber(size, 0));
  const resolvedMaxSize = Math.max(0, toFiniteNumber(maxSize, 0));

  if (!resolvedMaxSize) {
    return Math.max(0, resolvedValue);
  }

  return Math.min(Math.max(0, resolvedValue), Math.max(0, resolvedMaxSize - resolvedSize));
};

const isVisibleRect = rect => rect && rect.width > 0 && rect.height > 0;

const getEffectiveViewportRect = (trigger, wrapper) => {
  const ownerDocument = trigger?.ownerDocument || wrapper?.ownerDocument || globalThis.document || null;
  const ownerWindow = ownerDocument?.defaultView || globalThis.window || null;
  const viewport = {
    left: 0,
    top: 0,
    right: ownerWindow?.innerWidth || 0,
    bottom: ownerWindow?.innerHeight || 0
  };

  const triggerRect = trigger?.getBoundingClientRect?.() || null;
  if (!triggerRect || !ownerDocument?.body) {
    return viewport;
  }

  // Vue2 Pikaday は fixed footer や modal の可視領域に隠れない位置へ実質的に収まる。
  // Vue3 DatePicker は body 直下へ teleport するため、window.innerHeight だけを見ると
  // 下部 toolbar/footer の裏へ潜る。画面下にある fixed/sticky の大きな要素を下端として扱う。
  const candidates = [...ownerDocument.body.querySelectorAll("body > *, .ons-page, .page, .modal, .multi-modal")];
  for (const element of candidates) {
    if (!element || element === wrapper || element.contains?.(trigger) || element.contains?.(wrapper)) {
      continue;
    }
    const style = ownerWindow?.getComputedStyle?.(element);
    if (!style || (style.display === "none" || style.visibility === "hidden")) {
      continue;
    }
    const rect = element.getBoundingClientRect?.();
    if (!isVisibleRect(rect)) {
      continue;
    }
    const position = style.position;
    const coversBottom = (position === "fixed" || position === "sticky")
      && rect.top > triggerRect.bottom
      && rect.bottom >= viewport.bottom - 4
      && rect.width >= viewport.right * 0.4;
    if (coversBottom) {
      viewport.bottom = Math.min(viewport.bottom, rect.top);
    }
  }

  // 治療記録：左のサブメニュー（.scroll-area）は body teleport のカレンダーから独立しているため、
  // 左端をサブメニュー右端まで狭めてモニタ等でサイドバーを隠さない。
  const treatmentRecordRoot = trigger?.closest?.(".treatment-record-content-area");
  const submenuScrollArea = treatmentRecordRoot?.querySelector?.(".main-area > .scroll-area");
  const submenuRect = submenuScrollArea?.getBoundingClientRect?.();
  if (isVisibleRect(submenuRect) && submenuRect.right <= triggerRect.right + 1) {
    viewport.left = Math.max(viewport.left, submenuRect.right);
  }

  return viewport;
};

const PLACEMENT_GAP = 2;

const fitsViewportRect = (left, top, menuWidth, menuHeight, viewport) => left >= viewport.left
  && top >= viewport.top
  && left + menuWidth <= viewport.right
  && top + menuHeight <= viewport.bottom;

const clampMenuPositionToViewport = ({ left, top, menuWidth, menuHeight, viewport }) => ({
  left: viewport.left + clampToViewport(left - viewport.left, menuWidth, viewport.right - viewport.left),
  top: viewport.top + clampToViewport(top - viewport.top, menuHeight, viewport.bottom - viewport.top)
});

const buildRect = (left, top, width, height) => ({
  left,
  top,
  right: left + width,
  bottom: top + height
});

const overlapsRect = (a, b) => a.left < b.right
  && a.right > b.left
  && a.top < b.bottom
  && a.bottom > b.top;

/** 優先：アイコン右側に展開。右側に幅がなければ下側・右端揃え */
const resolveMenuPosition = ({ triggerRect, menuWidth, menuHeight, viewport, gap = PLACEMENT_GAP }) => {
  const triggerArea = buildRect(triggerRect.left, triggerRect.top, triggerRect.width, triggerRect.height);
  const hasRightSpace = triggerRect.right + gap + menuWidth <= viewport.right;

  const candidates = hasRightSpace
    ? [
        { left: triggerRect.right + gap, top: triggerRect.top },
        { left: triggerRect.right + gap, top: triggerRect.bottom - menuHeight }
      ]
    : [];

  candidates.push({
    left: triggerRect.right - menuWidth,
    top: triggerRect.bottom + gap
  });

  for (const candidate of candidates) {
    const menuArea = buildRect(candidate.left, candidate.top, menuWidth, menuHeight);
    if (fitsViewportRect(candidate.left, candidate.top, menuWidth, menuHeight, viewport)
      && !overlapsRect(menuArea, triggerArea)) {
      return candidate;
    }
  }

  const belowRight = {
    left: triggerRect.right - menuWidth,
    top: triggerRect.bottom + gap
  };
  const isRightEdge = !hasRightSpace;
  const isBottomOverflow = belowRight.top + menuHeight > viewport.bottom;

  // 画面右端・下端のみ：下方に展開できない場合は icon 上方へ右端揃え
  if (isRightEdge || isBottomOverflow) {
    const aboveRight = {
      left: triggerRect.right - menuWidth,
      top: triggerRect.top - menuHeight - gap
    };
    const aboveMenuArea = buildRect(aboveRight.left, aboveRight.top, menuWidth, menuHeight);
    if (fitsViewportRect(aboveRight.left, aboveRight.top, menuWidth, menuHeight, viewport)
      && !overlapsRect(aboveMenuArea, triggerArea)) {
      return aboveRight;
    }
  }

  const clamped = clampMenuPositionToViewport({
    left: belowRight.left,
    top: belowRight.top,
    menuWidth,
    menuHeight,
    viewport
  });
  const menuArea = buildRect(clamped.left, clamped.top, menuWidth, menuHeight);
  if (!overlapsRect(menuArea, triggerArea)) {
    return clamped;
  }

  // 右端・下端のみ clamp 済み位置を返し、画面外にはみ出さないようにする
  if (isRightEdge || isBottomOverflow) {
    return clamped;
  }

  return belowRight;
};

const applyDatePickerMenuFloatingPosition = (wrapper, { left, top, zIndex }) => {
  if (!wrapper) {
    return;
  }
  setStyleValue(wrapper, "position", "fixed");
  setStyleValue(wrapper, "left", `${Math.max(0, left)}px`);
  setStyleValue(wrapper, "top", `${Math.max(0, top)}px`);
  setStyleValue(wrapper, "right", "auto");
  setStyleValue(wrapper, "bottom", "auto");
  setStyleValue(wrapper, "transform", "none");
  setStyleValue(wrapper, "margin", "0px");
  setStyleValue(wrapper, "zIndex", `${zIndex}`);
  setStyleValue(wrapper, "opacity", "1");
  setStyleValue(wrapper, "pointerEvents", "auto");
  wrapper.classList?.remove?.(MENU_PANEL_POSITIONING_CLASS);
  wrapper.classList?.add?.(MENU_POSITIONED_CLASS);
  setStyleValue(wrapper, "visibility", "visible");
};

const findOwnedWrapper = (scopedDocument, ownerId) => {
  if (!scopedDocument || !ownerId) {
    return null;
  }
  const menu = scopedDocument.getElementById?.(ownerId) || null;
  return menu?.closest?.(".dp--menu-wrapper")
    || scopedDocument.querySelector(`.dp--menu-wrapper[${MENU_OWNER_ATTR}="${cssEscape(ownerId)}"]`);
};

const findVisibleDocumentWrappers = scopedDocument => {
  if (!scopedDocument) {
    return [];
  }
  return [...scopedDocument.querySelectorAll(".dp--menu-wrapper")].filter(wrapper => {
    const rect = wrapper.getBoundingClientRect?.();
    return rect && rect.width >= 0 && rect.height >= 0;
  });
};

export const getVueDatePickerMenuElements = (root, ownerId = "") => {
  const queryRoot = root?.querySelector ? root : toElement(root);
  const scopedDocument = getOwnerDocument(root);

  const ownedWrapper = findOwnedWrapper(scopedDocument, ownerId);
  const rootWrapper = queryRoot?.querySelector?.(".dp--menu-wrapper") || null;
  const documentWrappers = findVisibleDocumentWrappers(scopedDocument);
  const wrapper = ownedWrapper || rootWrapper || documentWrappers[documentWrappers.length - 1] || null;
  const menu = wrapper?.querySelector?.(".dp__menu") || null;
  const widthHost = wrapper?.querySelector?.('[style*="--dp-menu-width"]') || null;

  return {
    wrapper,
    menu,
    widthHost
  };
};

export const resetVueDatePickerMenuLayout = (root, ownerId = "") => {
  const { wrapper, menu, widthHost } = getVueDatePickerMenuElements(root, ownerId);

  clearDatePickerMenuPosition(wrapper);

  if (widthHost) {
    widthHost.style.removeProperty("--dp-menu-width");
  }

  if (menu) {
    menu.style.width = "";
    menu.style.minWidth = "";
    menu.style.maxWidth = "";
    menu.classList?.remove?.(MENU_PANEL_READY_CLASS);
  }

  if (wrapper && ownerId && wrapper.getAttribute(MENU_OWNER_ATTR) === ownerId) {
    wrapper.removeAttribute(MENU_OWNER_ATTR);
  }
  wrapper?.classList?.remove?.(MENU_FLOATING_CLASS);
  wrapper?.classList?.remove?.(MENU_PANEL_POSITIONING_CLASS);
  wrapper?.classList?.remove?.(MENU_POSITIONED_CLASS);
};

export const alignVueDatePickerMenuToTrigger = ({
  root,
  trigger,
  numberOfMonths = 1,
  menuWidth = DEFAULT_MENU_WIDTH,
  zIndex = DEFAULT_MENU_Z_INDEX,
  positionSnapshot = null,
  onPositionResolved = null,
  ownerId = ""
} = {}) => {
  let { wrapper, menu, widthHost } = getVueDatePickerMenuElements(root, ownerId);
  if (!trigger || !wrapper || !menu) {
    return false;
  }

  installDatePickerMenuFlashGuard(root);
  wrapper = ensureMenuWrapperDetached(wrapper, ownerId);
  ({ wrapper, menu, widthHost } = getVueDatePickerMenuElements(root, ownerId));
  if (!wrapper || !menu) {
    return false;
  }

  const monthCount = Number(numberOfMonths) > 1 ? Number(numberOfMonths) : 1;
  const resolvedMenuWidth = monthCount > 1 ? menuWidth * monthCount : menuWidth;

  if (widthHost) {
    widthHost.style.setProperty("--dp-menu-width", `${resolvedMenuWidth}px`);
  }
  setStyleValue(menu, "width", `${resolvedMenuWidth}px`);
  setStyleValue(menu, "minWidth", `${resolvedMenuWidth}px`);
  setStyleValue(menu, "maxWidth", `${resolvedMenuWidth}px`);

  // Vue2 Pikaday は「開いた瞬間」に top/left を決め、その後の前月/次月 redraw では
  // 親 popover 内に流れ込まず同じ浮動位置を維持する。Vue3 DatePicker は月送り時に
  // menu wrapper の style を再生成するため、既に確定済みの位置がある場合は再計算せず
  // その位置を再適用する。
  if (Number.isFinite(positionSnapshot?.left) && Number.isFinite(positionSnapshot?.top)) {
    applyDatePickerMenuFloatingPosition(wrapper, {
      left: positionSnapshot.left,
      top: positionSnapshot.top,
      zIndex: positionSnapshot.zIndex || zIndex
    });
    menu.classList?.add?.(MENU_PANEL_READY_CLASS);
    return true;
  }

  markMenuWrapperPositioning(wrapper);

  const parentPos = trigger.getBoundingClientRect();
  const datePickPos = menu.getBoundingClientRect();
  const viewport = getEffectiveViewportRect(trigger, wrapper);
  const menuHeight = datePickPos.height || menu.offsetHeight || 0;
  const measuredMenuWidth = datePickPos.width || menu.offsetWidth || resolvedMenuWidth;
  const { left, top } = resolveMenuPosition({
    triggerRect: parentPos,
    menuWidth: measuredMenuWidth,
    menuHeight,
    viewport,
    gap: PLACEMENT_GAP
  });

  const resolvedPosition = { left, top, zIndex };
  applyDatePickerMenuFloatingPosition(wrapper, resolvedPosition);
  menu.classList?.add?.(MENU_PANEL_READY_CLASS);
  if (typeof onPositionResolved === "function") {
    onPositionResolved(resolvedPosition);
  }
  return true;
};

export const attachVueDatePickerMenuLayoutGuard = ({
  root,
  trigger,
  realign,
  close,
  shouldSuspend,
  ownerId = ""
} = {}) => {
  const { wrapper } = getVueDatePickerMenuElements(root, ownerId);
  if (!wrapper || typeof realign !== "function") {
    return null;
  }

  let disposed = false;
  let timer = null;
  let rafId = null;
  let ownerCheckTimer = null;
  let inRealign = false;

  const isVisibleElement = element => {
    if (!element?.isConnected) {
      return false;
    }
    const ownerWindow = element.ownerDocument?.defaultView || globalThis.window || null;
    const style = ownerWindow?.getComputedStyle?.(element);
    if (style && (style.display === "none" || style.visibility === "hidden")) {
      return false;
    }
    return !!element.getClientRects?.().length;
  };

  const closeIfOwnerHidden = () => {
    const ownerRoot = toElement(root);
    const ownerTrigger = toElement(trigger);
    if ((ownerRoot && !isVisibleElement(ownerRoot)) || (ownerTrigger && !isVisibleElement(ownerTrigger))) {
      disposed = true;
      if (typeof close === "function") {
        close();
      }
      return true;
    }
    return false;
  };

  const isSuspended = () => typeof shouldSuspend === "function" && shouldSuspend();

  const run = () => {
    if (disposed || inRealign || isSuspended()) {
      return;
    }
    inRealign = true;
    try {
      realign();
    } finally {
      inRealign = false;
    }
  };

  const schedule = () => {
    if (disposed || isSuspended()) {
      return;
    }
    if (closeIfOwnerHidden()) {
      return;
    }
    if (timer !== null) {
      clearTimeout(timer);
    }
    timer = setTimeout(() => {
      timer = null;
      run();
    }, 0);

    const ownerWindow = wrapper.ownerDocument?.defaultView || globalThis.window || null;
    if (ownerWindow?.requestAnimationFrame) {
      if (rafId !== null) {
        ownerWindow.cancelAnimationFrame?.(rafId);
      }
      rafId = ownerWindow.requestAnimationFrame(() => {
        rafId = null;
        run();
      });
    }
  };

  const onCalendarInteraction = event => {
    const target = event?.target;
    if (isSuspended()) {
      return;
    }
    if (target?.closest?.(".dp--arrow-btn-nav, .dp__month_year_select, .ntss-calendar-month-year-select, .dp__calendar_item, .dp__calendar_header_item")) {
      // pointerdown/click の時点で即座に固定位置を戻して、Vue3 DatePicker の redraw が
      // 親 popover のレイアウト計算へ入る前に Vue2 Pikaday の浮動 DOM 状態を維持する。
      run();
      schedule();
      setTimeout(schedule, 32);
    }
  };

  wrapper.addEventListener("pointerdown", onCalendarInteraction, true);
  wrapper.addEventListener("click", onCalendarInteraction, true);
  wrapper.addEventListener("wheel", schedule, { passive: true });
  ownerCheckTimer = setInterval(closeIfOwnerHidden, 100);

  const observer = typeof MutationObserver !== "undefined"
    ? new MutationObserver(schedule)
    : null;
  observer?.observe?.(wrapper, {
    childList: true,
    subtree: true,
    characterData: true,
    attributes: true,
    attributeFilter: ["style", "class"]
  });

  return () => {
    disposed = true;
    if (timer !== null) {
      clearTimeout(timer);
      timer = null;
    }
    const ownerWindow = wrapper.ownerDocument?.defaultView || globalThis.window || null;
    if (rafId !== null) {
      ownerWindow?.cancelAnimationFrame?.(rafId);
      rafId = null;
    }
    if (ownerCheckTimer !== null) {
      clearInterval(ownerCheckTimer);
      ownerCheckTimer = null;
    }
    wrapper.removeEventListener("pointerdown", onCalendarInteraction, true);
    wrapper.removeEventListener("click", onCalendarInteraction, true);
    wrapper.removeEventListener("wheel", schedule);
    observer?.disconnect?.();
  };
};
