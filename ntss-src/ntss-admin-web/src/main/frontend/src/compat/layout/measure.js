import {
  resolveElement,
  resolveHostElement,
  resolveOwnerDocument,
  resolveOwnerWindow,
} from "@/compat/dom/host";

export function getElementWindow(target = null) {
  return resolveOwnerWindow(target);
}

export function getComputedStyleSafe(target = null, pseudoElt = null) {
  const element = resolveElement(target);
  const scopedWindow = getElementWindow(element || target);
  if (!element || !scopedWindow?.getComputedStyle) {
    return null;
  }
  try {
    return scopedWindow.getComputedStyle(element, pseudoElt);
  } catch (_error) {
    return null;
  }
}

export function isElementVisible(target = null) {
  const element = resolveElement(target);
  if (!element) {
    return false;
  }
  const style = getComputedStyleSafe(element);
  if (!style) {
    return true;
  }
  if (style.display === "none" || style.visibility === "hidden") {
    return false;
  }
  return true;
}

export function getElementRect(target = null) {
  const element = resolveElement(target);
  if (!element?.getBoundingClientRect) {
    return {
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      width: 0,
      height: 0,
    };
  }
  try {
    const rect = element.getBoundingClientRect();
    return {
      top: Number(rect.top || 0),
      left: Number(rect.left || 0),
      right: Number(rect.right || 0),
      bottom: Number(rect.bottom || 0),
      width: Number(rect.width || 0),
      height: Number(rect.height || 0),
    };
  } catch (_error) {
    return {
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      width: 0,
      height: 0,
    };
  }
}

export function getRenderedElementHeight(target = null) {
  const element = resolveElement(target);
  if (!element || !isElementVisible(element)) {
    return 0;
  }
  const rect = getElementRect(element);
  return Math.max(
    Number(rect.height || 0),
    Number(element.clientHeight || 0),
    Number(element.offsetHeight || 0),
    Number(element.scrollHeight || 0),
    0,
  );
}

export function getRenderedElementWidth(target = null) {
  const element = resolveElement(target);
  if (!element || !isElementVisible(element)) {
    return 0;
  }
  const rect = getElementRect(element);
  return Math.max(
    Number(rect.width || 0),
    Number(element.clientWidth || 0),
    Number(element.offsetWidth || 0),
    Number(element.scrollWidth || 0),
    0,
  );
}

export function getClientSize(target = null) {
  const element = resolveElement(target);
  if (!element) {
    const scopedDocument = resolveOwnerDocument(target);
    const scopedWindow = resolveOwnerWindow(target);
    return {
      width: Number(scopedDocument?.documentElement?.clientWidth || scopedWindow?.innerWidth || 0),
      height: Number(scopedDocument?.documentElement?.clientHeight || scopedWindow?.innerHeight || 0),
    };
  }
  return {
    width: Number(element.clientWidth || 0),
    height: Number(element.clientHeight || 0),
  };
}

export function getScrollSize(target = null) {
  const element = resolveElement(target);
  return {
    width: Number(element?.scrollWidth || 0),
    height: Number(element?.scrollHeight || 0),
  };
}

export function isElementMeasurable(target = null) {
  const element = resolveElement(target);
  if (!element || !isElementVisible(element)) {
    return false;
  }
  return getRenderedElementHeight(element) > 0 || getRenderedElementWidth(element) > 0;
}

export function requestScopedAnimationFrame(root = null, callback = () => {}) {
  const scopedWindow = resolveOwnerWindow(root);
  if (typeof scopedWindow?.requestAnimationFrame === "function") {
    return scopedWindow.requestAnimationFrame(callback);
  }
  return setTimeout(() => callback(Date.now()), 16);
}

export function cancelScopedAnimationFrame(root = null, handle = null) {
  if (handle == null) {
    return;
  }
  const scopedWindow = resolveOwnerWindow(root);
  if (typeof scopedWindow?.cancelAnimationFrame === "function") {
    scopedWindow.cancelAnimationFrame(handle);
    return;
  }
  clearTimeout(handle);
}

export function nextLayoutFrame(root = null) {
  return new Promise((resolve) => {
    requestScopedAnimationFrame(root, () => {
      requestScopedAnimationFrame(root, resolve);
    });
  });
}

export function createScopedResizeObserver(root = null, callback = () => {}) {
  const scopedWindow = resolveOwnerWindow(root);
  const ResizeObserverCtor = scopedWindow?.ResizeObserver || globalThis?.ResizeObserver;
  if (typeof ResizeObserverCtor !== "function") {
    return null;
  }
  try {
    return new ResizeObserverCtor(callback);
  } catch (_error) {
    return null;
  }
}

export function observeElementResize(target = null, callback = () => {}, options = {}) {
  const element = resolveElement(target);
  if (!element) {
    return () => {};
  }
  const observer = createScopedResizeObserver(element, callback);
  if (observer) {
    observer.observe(element, options);
    return () => observer.disconnect?.();
  }
  const scopedWindow = resolveOwnerWindow(element);
  if (typeof scopedWindow?.addEventListener === "function") {
    const handler = () => callback([{ target: element }]);
    scopedWindow.addEventListener("resize", handler);
    return () => scopedWindow.removeEventListener?.("resize", handler);
  }
  return () => {};
}

export function resolveScrollableElement(target = null) {
  const element = resolveElement(target);
  if (!element) {
    return resolveOwnerDocument(target)?.scrollingElement || resolveOwnerDocument(target)?.documentElement || null;
  }
  let current = element;
  while (current) {
    const style = getComputedStyleSafe(current);
    const overflowY = `${style?.overflowY || ""} ${style?.overflow || ""}`;
    if (/(auto|scroll|overlay)/.test(overflowY) && current.scrollHeight > current.clientHeight) {
      return current;
    }
    current = current.parentElement;
  }
  const ownerDocument = element.ownerDocument || resolveOwnerDocument(element);
  return ownerDocument?.scrollingElement || ownerDocument?.documentElement || null;
}

export function getAvailableHeight({ root = null, topElement = null, bottomElement = null, extraOffset = 0 } = {}) {
  const scopedDocument = resolveOwnerDocument(root || topElement || bottomElement);
  const scopedWindow = resolveOwnerWindow(root || topElement || bottomElement);
  const viewportHeight = Number(scopedDocument?.documentElement?.clientHeight || scopedWindow?.innerHeight || 0);
  const topRect = topElement ? getElementRect(topElement) : getElementRect(root);
  const top = Number(topRect?.bottom || topRect?.top || 0);
  const bottomHeight = getRenderedElementHeight(bottomElement);
  return Math.max(viewportHeight - top - bottomHeight - Number(extraOffset || 0), 0);
}

export function setElementStyleSafe(target = null, styles = {}) {
  const element = resolveElement(target);
  if (!element?.style || !styles || typeof styles !== "object") {
    return false;
  }
  Object.keys(styles).forEach((key) => {
    try {
      element.style[key] = styles[key];
    } catch (_error) {
      // noop
    }
  });
  return true;
}

export function getLayoutHost(target = null) {
  return resolveHostElement(target, { allowDocument: true, allowFragment: true });
}

export default {
  getElementWindow,
  getComputedStyleSafe,
  isElementVisible,
  getElementRect,
  getRenderedElementHeight,
  getRenderedElementWidth,
  getClientSize,
  getScrollSize,
  isElementMeasurable,
  requestScopedAnimationFrame,
  cancelScopedAnimationFrame,
  nextLayoutFrame,
  createScopedResizeObserver,
  observeElementResize,
  resolveScrollableElement,
  getAvailableHeight,
  setElementStyleSafe,
  getLayoutHost,
};
