import { getViewportHeight, getViewportWidth } from "@/functions/common/LayoutMeasureHelper";
import { getOnsPopoverParts, getOnsPopoverPartsFromEvent } from "@/functions/common/OnsenFunctions";

let activePopoverState = null;
const COMMON_POPOVER_EVENT_HANDLED = "__ntssCommonPopoverEventHandled";
const COMMON_POPOVER_BRIDGE_INSTALLED = "__ntssCommonPopoverBridgeInstalled";

function isCommonPopoverEventHandled(event, eventName) {
  return !!event?.[COMMON_POPOVER_EVENT_HANDLED]?.[eventName];
}

function markCommonPopoverEventHandled(event, eventName) {
  if (!event || typeof event !== "object") {
    return;
  }
  const handled = event[COMMON_POPOVER_EVENT_HANDLED] || {};
  handled[eventName] = true;
  try {
    Object.defineProperty(event, COMMON_POPOVER_EVENT_HANDLED, {
      configurable: true,
      value: handled
    });
  } catch (_error) {
    event[COMMON_POPOVER_EVENT_HANDLED] = handled;
  }
}

function beginCommonPopoverEvent(event, eventName) {
  if (isCommonPopoverEventHandled(event, eventName)) {
    return false;
  }
  markCommonPopoverEventHandled(event, eventName);
  return true;
}

function hasPopoverParts(state) {
  return !!(state?.arrow && state?.popover && state?.content);
}

function getPopoverDocument(event, state = null) {
  return state?.root?.ownerDocument
    || state?.popover?.ownerDocument
    || event?.popover?.ownerDocument
    || event?.target?.ownerDocument
    || event?.currentTarget?.ownerDocument
    || (typeof document !== "undefined" ? document : null);
}

function isVisiblePopoverRoot(root) {
  const popover = root?.querySelector?.(".popover");
  if (!popover) {
    return false;
  }

  const ownerWindow = root.ownerDocument?.defaultView;
  const style = ownerWindow?.getComputedStyle?.(root);
  const popoverStyle = ownerWindow?.getComputedStyle?.(popover);
  const rect = popover.getBoundingClientRect?.();
  return style?.display !== "none"
    && popoverStyle?.display !== "none"
    && ((rect?.width || 0) > 0 || (rect?.height || 0) > 0);
}

function findVisiblePopoverParts(event, state = null) {
  const ownerDocument = getPopoverDocument(event, state);
  if (!ownerDocument?.querySelectorAll) {
    return state || {};
  }

  const roots = Array.from(ownerDocument.querySelectorAll("ons-popover"))
    .filter(isVisiblePopoverRoot);
  if (roots.length === 0) {
    return state || {};
  }

  return getOnsPopoverParts(roots[roots.length - 1]);
}

function resolvePopoverParts(event) {
  const state = getOnsPopoverPartsFromEvent(event);
  return hasPopoverParts(state) ? state : findVisiblePopoverParts(event, state);
}

function isPopoverOutsideViewport(state) {
  if (!hasPopoverParts(state)) {
    return false;
  }

  const rect = state.popover.getBoundingClientRect?.();
  if (!rect) {
    return false;
  }

  const viewportWidth = getViewportWidth(state.popover);
  const viewportHeight = getViewportHeight(state.popover);
  const outside = rect.left < 0
    || rect.top < 0
    || rect.right > viewportWidth
    || rect.bottom > viewportHeight;
  return outside;
}

function clearPopoverStyles(state) {
  if (!state?.arrow || !state?.popover || !state?.content) {
    return;
  }
  state.popover.style.right = "";
  state.popover.style.left = "";
  state.popover.style.bottom = "";
  state.popover.style.top = "";
  state.content.style.width = "";
  state.content.style.height = "";
  state.content.style.maxHeight = "";
  state.content.style.marginLeft = "";
  state.content.style.marginRight = "";
  state.arrow.style.display = "unset";
  state.arrow.classList.remove("disp_target_popover__arrow");
  state.popover.classList.remove("disp_target_popover");
  state.content.classList.remove("disp_target_popover__content");
}

function parsePopoverPx(value) {
  const number = parseFloat(value);
  return Number.isFinite(number) ? number : null;
}

function clampPopoverPx(value, min, max) {
  if (!Number.isFinite(value)) {
    return min;
  }
  return Math.min(Math.max(value, min), max);
}

function getVerticalPopoverArrowCenterOffsetX(state) {
  const popoverWidth = state?.popover?.offsetWidth || 0;
  const arrowLeft = parsePopoverPx(state?.arrow?.style?.left);
  if (arrowLeft !== null) {
    return arrowLeft;
  }

  const arrowRight = parsePopoverPx(state?.arrow?.style?.right);
  if (arrowRight !== null && popoverWidth > 0) {
    return popoverWidth - arrowRight;
  }

  const popoverRect = state?.popover?.getBoundingClientRect?.();
  const arrowRect = state?.arrow?.getBoundingClientRect?.();
  if (popoverRect && arrowRect && arrowRect.width > 0) {
    return arrowRect.left + (arrowRect.width / 2) - popoverRect.left;
  }

  return null;
}

function alignVerticalPopoverContentToArrow(state) {
  if (!state?.arrow || !state?.popover || !state?.content) {
    return;
  }

  const upFlg = state.arrow.classList.contains("popover--bottom__arrow");
  const downFlg = state.arrow.classList.contains("popover--top__arrow");
  if (!upFlg && !downFlg) {
    state.content.style.marginLeft = "";
    state.content.style.marginRight = "";
    return;
  }

  const popoverWidth = state.popover.offsetWidth || 0;
  const contentWidth = state.content.offsetWidth || 0;
  if (popoverWidth <= 0 || contentWidth <= 0 || contentWidth >= popoverWidth) {
    state.content.style.marginLeft = "";
    state.content.style.marginRight = "";
    return;
  }

  const arrowCenterOffset = getVerticalPopoverArrowCenterOffsetX(state);
  if (arrowCenterOffset === null) {
    state.content.style.marginLeft = "";
    state.content.style.marginRight = "";
    return;
  }

  const maxMarginLeft = popoverWidth - contentWidth;
  const marginLeft = clampPopoverPx(arrowCenterOffset - (contentWidth / 2), 0, maxMarginLeft);
  state.content.style.marginLeft = marginLeft > 0.5 ? `${Math.round(marginLeft * 1000) / 1000}px` : "";
  state.content.style.marginRight = "";
}

function resizeActivePopover() {
  const state = activePopoverState;
  if (!state?.arrow || !state?.popover || !state?.content) {
    return;
  }

  const upFlg = state.arrow.classList.contains("popover--bottom__arrow");
  const downFlg = state.arrow.classList.contains("popover--top__arrow");
  const leftFlg = state.arrow.classList.contains("popover--right__arrow");
  const rightFlg = state.arrow.classList.contains("popover--left__arrow");
  const viewportWidth = getViewportWidth(state.popover);
  const viewportHeight = getViewportHeight(state.popover);

  if (leftFlg || rightFlg) {
    let widthPx = parseInt(leftFlg ? state.popover.style.right : state.popover.style.left, 10);
    if (isNaN(widthPx)) {
      widthPx = 0;
    }
    const freeSize = viewportWidth - (widthPx + state.popover.offsetWidth + 12);
    if (freeSize < 0 && widthPx > (freeSize * -1)) {
      const tmpPx = widthPx - (freeSize * -1) + 6;
      if (leftFlg) {
        state.popover.style.right = tmpPx + "px";
      } else {
        state.popover.style.left = tmpPx + "px";
      }
      // 位置調整後も矢印を表示（100%表示時に矢印が消える不具合対応）
      state.arrow.style.display = "";
    } else if (freeSize < 0 && widthPx < (freeSize * -1)) {
      if (leftFlg) {
        state.popover.style.right = "6px";
      } else {
        state.popover.style.left = "6px";
      }
      state.content.style.width = (viewportWidth - 12) + "px";
      restorePopoverArrowDisplay(state.arrow);
    } else {
      state.arrow.style.display = "";
    }
    if ((viewportHeight - 12) <= state.popover.offsetHeight) {
      state.content.style.height = (viewportHeight - 12) + "px";
    }
    state.content.style.marginLeft = "";
    state.content.style.marginRight = "";
    state.popover.style.visibility = "visible";
    restorePopoverArrowDisplay(state.arrow);
    return;
  }

  if (upFlg || downFlg) {
    let heightPx = parseInt(upFlg ? state.popover.style.bottom : state.popover.style.top, 10);
    if (isNaN(heightPx)) {
      heightPx = 0;
    }
    const freeSize = viewportHeight - (heightPx + state.popover.offsetHeight + 12);
    if (freeSize < 0 && heightPx > (freeSize * -1)) {
      const tmpPx = heightPx - (freeSize * -1) + 6;
      if (upFlg) {
        state.popover.style.bottom = tmpPx + "px";
      } else {
        state.popover.style.top = tmpPx + "px";
      }
      state.content.style.maxHeight = state.popover.offsetHeight + "px";
      // 位置調整後も矢印を表示（100%表示時に矢印が消える不具合対応）
      state.arrow.style.display = "";
    } else if (freeSize < 0 && heightPx < (freeSize * -1)) {
      if (upFlg) {
        state.popover.style.bottom = "6px";
      } else {
        state.popover.style.top = "6px";
      }
      state.content.style.height = (viewportHeight - 12) + "px";
      restorePopoverArrowDisplay(state.arrow);
    } else {
      state.arrow.style.display = "";
      state.content.style.maxHeight = (viewportHeight - 12 - heightPx) + "px";
    }
    if ((viewportWidth - 12) <= state.popover.offsetWidth) {
      state.content.style.width = (viewportWidth - 12) + "px";
    }
    alignVerticalPopoverContentToArrow(state);
    state.popover.style.visibility = "visible";
    restorePopoverArrowDisplay(state.arrow);
  }
}

/**
 * 吹き出し矢印の表示復帰（preshow で非表示にした後、リサイズ完了時に必ず表示する）
 */
function restorePopoverArrowDisplay(arrowEl) {
  if (arrowEl) {
    arrowEl.style.display = "";
  }
}

function getPopoverOwnerWindow(state = activePopoverState) {
  return state?.popover?.ownerDocument?.defaultView || (typeof window !== 'undefined' ? window : null);
}

function popoverEventResize() {
  const ownerWindow = getPopoverOwnerWindow();
  ownerWindow?.setTimeout?.(() => {
    const state = activePopoverState;
    if (state?.arrow && state?.content) {
      state.content.style.width = "";
      state.content.style.height = "";
      state.arrow.style.display = "none";
    }
    resizeActivePopover();
  }, 200);
}

export const popoverPreShow = function(event) {
  if (!beginCommonPopoverEvent(event, "preshow")) {
    return;
  }
  const state = resolvePopoverParts(event);
  if (state.arrow) {
    state.arrow.style.display = "none";
  }
  if (state.popover) {
    state.popover.style.visibility = "hidden";
  }
};

export const popoverPostShow = function(event) {
  if (!beginCommonPopoverEvent(event, "postshow")) {
    return;
  }
  const state = resolvePopoverParts(event);
  if (!state.arrow || !state.popover || !state.content) {
    return;
  }

  const needsResize = state.popover.style.visibility === "hidden" || isPopoverOutsideViewport(state);
  if (!needsResize) {
    clearPopoverStyles(state);
    if (activePopoverState?.popover === state.popover) {
      getPopoverOwnerWindow(activePopoverState || state)?.removeEventListener?.("resize", popoverEventResize);
      activePopoverState = null;
    }
    return;
  }

  state.arrow.style.display = "none";
  state.arrow.classList.add("disp_target_popover__arrow");
  state.popover.classList.add("disp_target_popover");
  state.content.classList.add("disp_target_popover__content");
  activePopoverState = state;
  resizeActivePopover();
  getPopoverOwnerWindow(activePopoverState || state)?.removeEventListener?.("resize", popoverEventResize);
  getPopoverOwnerWindow(activePopoverState)?.addEventListener?.("resize", popoverEventResize);
};

export const popoverPosthide = function(event) {
  if (!beginCommonPopoverEvent(event, "posthide")) {
    return;
  }
  const state = resolvePopoverParts(event);
  getPopoverOwnerWindow(activePopoverState || state)?.removeEventListener?.("resize", popoverEventResize);
  clearPopoverStyles(state);
  activePopoverState = null;
};

function isCommonPopoverRoot(state) {
  return state?.root?.classList?.contains("popover-style")
    || state?.popover?.classList?.contains("disp_target_popover")
    || state?.content?.classList?.contains("disp_target_popover__content");
}

function onNativeCommonPopoverEvent(eventName, handler, event) {
  const state = resolvePopoverParts(event);
  if (!hasPopoverParts(state) || !isCommonPopoverRoot(state)) {
    return;
  }
  handler(event);
}

function installNativeCommonPopoverBridge() {
  if (typeof document === "undefined") {
    return;
  }
  const ownerDocument = document;
  if (ownerDocument[COMMON_POPOVER_BRIDGE_INSTALLED]) {
    return;
  }
  ownerDocument[COMMON_POPOVER_BRIDGE_INSTALLED] = true;
  ownerDocument.addEventListener("preshow", (event) => {
    onNativeCommonPopoverEvent("preshow", popoverPreShow, event);
  }, true);
  ownerDocument.addEventListener("postshow", (event) => {
    onNativeCommonPopoverEvent("postshow", popoverPostShow, event);
  }, true);
  ownerDocument.addEventListener("posthide", (event) => {
    onNativeCommonPopoverEvent("posthide", popoverPosthide, event);
  }, true);
}

installNativeCommonPopoverBridge();
