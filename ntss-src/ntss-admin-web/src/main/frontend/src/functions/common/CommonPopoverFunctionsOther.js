import { getViewportHeight, getViewportWidth } from "@/functions/common/LayoutMeasureHelper";
import { getOnsPopoverPartsFromEvent } from "@/functions/common/OnsenFunctions";

const targetClassList = {
  splitGraph: "sg",
  viewLog: "vl"
};

const activePopoverStates = {};

function resolvePopoverParts(event) {
  return getOnsPopoverPartsFromEvent(event);
}

function stateClasses(target) {
  const suffix = targetClassList[target];
  return {
    arrow: `disp_target_${suffix}_parrow`,
    popover: `disp_target_${suffix}_p`,
    content: `disp_target_${suffix}_p_content`
  };
}

function clearPopoverStyles(state, target) {
  if (!state?.arrow || !state?.popover || !state?.content) {
    return;
  }
  const classes = stateClasses(target);
  state.popover.style.right = "";
  state.popover.style.left = "";
  state.popover.style.bottom = "";
  state.popover.style.top = "";
  state.content.style.width = "";
  state.content.style.height = "";
  state.content.style.maxHeight = "";
  state.arrow.style.display = "unset";
  state.arrow.classList.remove(classes.arrow);
  state.popover.classList.remove(classes.popover);
  state.content.classList.remove(classes.content);
}

function resizePopover(target) {
  const state = activePopoverStates[target];
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
    if (isNaN(widthPx)) { widthPx = 0; }
    const freeSize = viewportWidth - (widthPx + state.popover.offsetWidth + 12);
    if (freeSize < 0 && widthPx > (freeSize * -1)) {
      const tmpPx = widthPx - (freeSize * -1) + 6;
      if (leftFlg) {
        state.popover.style.right = tmpPx + "px";
      } else {
        state.popover.style.left = tmpPx + "px";
      }
      if ((freeSize * -1) <= 10) { state.arrow.style.display = ""; }
    } else if (freeSize < 0 && widthPx < (freeSize * -1)) {
      if (leftFlg) {
        state.popover.style.right = "6px";
      } else {
        state.popover.style.left = "6px";
      }
      state.content.style.width = (viewportWidth - 12) + "px";
    } else {
      state.arrow.style.display = "";
    }
    if ((viewportHeight - 12) <= state.popover.offsetHeight) {
      state.content.style.height = (viewportHeight - 12) + "px";
    }
    state.popover.style.visibility = "visible";
    return;
  }

  if (upFlg || downFlg) {
    let heightPx = parseInt(upFlg ? state.popover.style.bottom : state.popover.style.top, 10);
    if (isNaN(heightPx)) { heightPx = 0; }
    const freeSize = viewportHeight - (heightPx + state.popover.offsetHeight + 12);
    if (freeSize < 0 && heightPx > (freeSize * -1)) {
      const tmpPx = heightPx - (freeSize * -1) + 6;
      if (upFlg) {
        state.popover.style.bottom = tmpPx + "px";
      } else {
        state.popover.style.top = tmpPx + "px";
      }
      state.content.style.maxHeight = state.popover.offsetHeight + "px";
      if ((freeSize * -1) <= 10) { state.arrow.style.display = ""; }
    } else if (freeSize < 0 && heightPx < (freeSize * -1)) {
      if (upFlg) {
        state.popover.style.bottom = "6px";
      } else {
        state.popover.style.top = "6px";
      }
      state.content.style.height = (viewportHeight - 12) + "px";
    } else {
      state.arrow.style.display = "";
      state.content.style.maxHeight = (viewportHeight - 12 - heightPx) + "px";
    }
    if ((viewportWidth - 12) <= state.popover.offsetWidth) {
      state.content.style.width = (viewportWidth - 12) + "px";
    }
    state.popover.style.visibility = "visible";
  }
}

function getPopoverOwnerWindow(state = null) {
  return state?.popover?.ownerDocument?.defaultView || (typeof window !== 'undefined' ? window : null);
}

function createPopoverResizeHandler(target) {
  return function popoverEventResize() {
    const ownerWindow = getPopoverOwnerWindow(activePopoverStates[target]);
    ownerWindow?.setTimeout?.(() => {
      const state = activePopoverStates[target];
      if (state?.arrow && state?.content) {
        state.content.style.width = "";
        state.content.style.height = "";
        state.arrow.style.display = "none";
      }
      resizePopover(target);
    }, 200);
  };
}

export const popoverPreShowOther = function(event) {
  const state = resolvePopoverParts(event);
  if (state.arrow) { state.arrow.style.display = "none"; }
  if (state.popover) { state.popover.style.visibility = "hidden"; }
};

export const popoverPostShowOther = function(event, target) {
  const state = resolvePopoverParts(event);
  if (!state.arrow || !state.popover || !state.content || !targetClassList[target]) {
    return;
  }

  if (state.popover.style.visibility !== "hidden") {
    clearPopoverStyles(state, target);
    const previous = activePopoverStates[target];
    if (previous?.resizeHandler) {
      getPopoverOwnerWindow(previous)?.removeEventListener?.("resize", previous.resizeHandler);
    }
    delete activePopoverStates[target];
    return;
  }

  const classes = stateClasses(target);
  state.arrow.classList.add(classes.arrow);
  state.popover.classList.add(classes.popover);
  state.content.classList.add(classes.content);
  const resizeHandler = createPopoverResizeHandler(target);
  const previous = activePopoverStates[target];
  if (previous?.resizeHandler) {
    getPopoverOwnerWindow(previous)?.removeEventListener?.("resize", previous.resizeHandler);
  }
  activePopoverStates[target] = { ...state, resizeHandler };
  resizePopover(target);
  getPopoverOwnerWindow(activePopoverStates[target])?.addEventListener?.("resize", resizeHandler);
};

export const popoverPosthideOther = function(event, target) {
  const current = activePopoverStates[target];
  if (current?.resizeHandler) {
    getPopoverOwnerWindow(current)?.removeEventListener?.("resize", current.resizeHandler);
  }
  const state = resolvePopoverParts(event);
  clearPopoverStyles(state, target);
  delete activePopoverStates[target];
};
