import {
  closestWithinHost as compatClosestWithinHost,
  getScopedBody as getCompatScopedBody,
  getScopedElementByClassName as getCompatScopedElementByClassName,
  getScopedElementById as getCompatScopedElementById,
  queryElementBySelectors as queryElementBySelectorsCompat,
  queryElementsBySelectors as queryElementsBySelectorsCompat,
  resolveHostElement as resolveCompatHostElement,
  resolveOwnerDocument as resolveCompatOwnerDocument,
  resolveOwnerWindow as resolveCompatOwnerWindow,
} from "@/compat/dom/host";

import {
  getClientSize as compatGetClientSize,
  getComputedStyleSafe as compatGetComputedStyleSafe,
  getElementRect as compatGetElementRect,
  getRenderedElementHeight as compatGetRenderedElementHeight,
  getRenderedElementWidth as compatGetRenderedElementWidth,
  isElementVisible as compatIsElementVisible,
  nextLayoutFrame as compatNextLayoutFrame,
  observeElementResize as compatObserveElementResize,
  requestScopedAnimationFrame as compatRequestScopedAnimationFrame,
  cancelScopedAnimationFrame as compatCancelScopedAnimationFrame,
  resolveScrollableElement as compatResolveScrollableElement,
  setElementStyleSafe as compatSetElementStyleSafe,
} from "@/compat/layout/measure";
import {
  getComponentEl as compatGetComponentEl,
  getLegacyChildren as compatGetLegacyChildren,
  getLegacyParent as compatGetLegacyParent,
  resolveRefElement as compatResolveRefElement,
  safeCallComponentMethod as compatSafeCallComponentMethod,
} from "@/compat/vue/instance";

export function getViewportHeight(root = null) {
  const scopedDocument = getScopedDocument(root);
  const scopedWindow = scopedDocument?.defaultView || window;
  return scopedDocument?.documentElement?.clientHeight || scopedWindow.innerHeight || 0;
}

export function getViewportWidth(root = null) {
  const scopedDocument = getScopedDocument(root);
  const scopedWindow = scopedDocument?.defaultView || window;
  return scopedDocument?.documentElement?.clientWidth || scopedWindow.innerWidth || 0;
}


export function getScopedDocument(root = null) {
  return resolveCompatOwnerDocument(root);
}

export function getScopedWindow(root = null) {
  return resolveCompatOwnerWindow(root);
}

export function getScopedNavigator(root = null) {
  return getScopedWindow(root)?.navigator || (typeof navigator !== 'undefined' ? navigator : null);
}

export function getScopedUserAgent(root = null) {
  return getScopedNavigator(root)?.userAgent || '';
}

export function getScopedDocumentElement(root = null) {
  return getScopedDocument(root)?.documentElement || null;
}

export function appendScopedStylesheet(href = '', root = null) {
  const scopedDocument = getScopedDocument(root);
  if (!href || !scopedDocument?.createElement || !scopedDocument?.head) {
    return null;
  }
  const exists = Array.from(scopedDocument.head.querySelectorAll?.('link[href]') || [])
    .some((link) => link.getAttribute('href') === href);
  if (exists) {
    return null;
  }
  const link = scopedDocument.createElement('link');
  link.rel = 'stylesheet';
  link.href = href;
  scopedDocument.head.appendChild(link);
  return link;
}

export function removeScopedStylesheets(href = '', root = null) {
  const scopedDocument = getScopedDocument(root);
  if (!href || !scopedDocument?.head?.querySelectorAll) {
    return;
  }
  const links = Array.from(scopedDocument.head.querySelectorAll(`link[href="${escapeAttributeValue(href)}"]`));
  links.forEach((link) => link.parentNode?.removeChild?.(link));
}

function getSafeStorage(scopedWindow, storageName) {
  try {
    const scopedStorage = scopedWindow?.[storageName];
    if (scopedStorage) {
      return scopedStorage;
    }
  } catch (_error) {
    // noop
  }
  try {
    if (typeof globalThis !== 'undefined' && globalThis?.[storageName]) {
      return globalThis[storageName];
    }
  } catch (_error) {
    // noop
  }
  return {
    getItem: () => null,
    setItem: () => {},
    removeItem: () => {},
  };
}

export function getScopedSessionStorage(root = null) {
  return getSafeStorage(getScopedWindow(root), 'sessionStorage');
}

export function getScopedLocalStorage(root = null) {
  return getSafeStorage(getScopedWindow(root), 'localStorage');
}

export function getScopedLocation(root = null) {
  const scopedWindow = getScopedWindow(root);
  return scopedWindow?.location || (typeof location !== 'undefined' ? location : null);
}

export function setScopedCookie(value = '', root = null) {
  const scopedDocument = getScopedDocument(root);
  if (!scopedDocument) {
    return false;
  }
  scopedDocument.cookie = value;
  return true;
}

export function getScopedURL(root = null) {
  const scopedWindow = getScopedWindow(root);
  return scopedWindow?.URL || scopedWindow?.webkitURL || (typeof URL !== 'undefined' ? URL : null);
}

export function createScopedElement(tagName = 'div', root = null) {
  const scopedDocument = getScopedDocument(root);
  const normalizedTagName = String(tagName || 'div').trim() || 'div';
  return scopedDocument?.createElement?.(normalizedTagName) || null;
}

export function createScopedImageElement(root = null) {
  return createScopedElement('img', root);
}

export function appendScopedChild(parent = null, child = null) {
  if (!parent?.appendChild || !child) {
    return null;
  }
  return parent.appendChild(child);
}

export function removeScopedChild(child = null, expectedParent = null) {
  const parent = expectedParent || child?.parentNode || null;
  if (!child || !parent?.removeChild || child.parentNode !== parent) {
    return false;
  }
  parent.removeChild(child);
  return true;
}

export function createScopedObjectURL(blob, root = null) {
  const scopedURL = getScopedURL(root);
  if (!scopedURL || typeof scopedURL.createObjectURL !== 'function') {
    return null;
  }
  return scopedURL.createObjectURL(blob);
}

export function revokeScopedObjectURL(objectUrl, root = null) {
  const scopedURL = getScopedURL(root);
  if (objectUrl && scopedURL && typeof scopedURL.revokeObjectURL === 'function') {
    scopedURL.revokeObjectURL(objectUrl);
  }
}

export function triggerScopedDownload({ blob = null, href = '', filename = '', root = null } = {}) {
  const scopedDocument = getScopedDocument(root);
  const scopedWindow = scopedDocument?.defaultView || getScopedWindow(root);
  if (!scopedDocument || !scopedWindow) {
    return false;
  }

  if (blob && scopedWindow.navigator?.msSaveBlob) {
    scopedWindow.navigator.msSaveBlob(blob, filename);
    return true;
  }

  const objectUrl = href || (blob ? createScopedObjectURL(blob, root) : '');
  if (!objectUrl) {
    return false;
  }

  const link = scopedDocument.createElement('a');
  link.href = objectUrl;
  link.download = filename || '';
  link.style.display = 'none';
  const parent = scopedDocument.body || scopedDocument.documentElement;
  parent?.appendChild?.(link);
  link.click();
  link.parentNode?.removeChild?.(link);

  if (!href && blob) {
    revokeScopedObjectURL(objectUrl, root);
  }
  return true;
}

export function getScopedBodyClientWidth(root = null) {
  const scopedDocument = getScopedDocument(root);
  const scopedWindow = scopedDocument?.defaultView || window;
  return Number(scopedDocument?.body?.clientWidth || scopedDocument?.documentElement?.clientWidth || scopedWindow.innerWidth || 0);
}

export function getModalContainerElement(root = null) {
  const elementRoot = resolveElementRoot(root);
  if (elementRoot && elementRoot !== document) {
    if (elementRoot.matches?.('.modal-container, [data-ntss-role="modal-root"]')) {
      return elementRoot;
    }
    const closestModalContainer = elementRoot.closest?.('.modal-container, [data-ntss-role="modal-root"]');
    if (closestModalContainer) {
      return closestModalContainer;
    }
  }
  return queryElementBySelectors(['.modal-container', '[data-ntss-role="modal-root"]'], elementRoot || document);
}

export function getModalBodyElement(root = null) {
  const elementRoot = resolveElementRoot(root);
  const bodySelectors = ['.modal-body', '.modal-body-search', '.modal-body-no-footer'];
  if (elementRoot && elementRoot !== document) {
    if (elementRoot.matches?.(bodySelectors.join(', '))) {
      return elementRoot;
    }
    const closestModalBody = elementRoot.closest?.(bodySelectors.join(', '));
    if (closestModalBody) {
      return closestModalBody;
    }
  }
  const modalContainer = getModalContainerElement(elementRoot);
  if (modalContainer?.querySelector) {
    const modalBody = modalContainer.querySelector(bodySelectors.join(', '));
    if (modalBody) {
      return modalBody;
    }
  }
  return queryElementBySelectors(bodySelectors, elementRoot || document);
}

export function getModalFooterElement(root = null) {
  const elementRoot = resolveElementRoot(root);
  if (elementRoot && elementRoot !== document) {
    if (elementRoot.matches?.('.modal-footer')) {
      return elementRoot;
    }
    const closestModalFooter = elementRoot.closest?.('.modal-footer');
    if (closestModalFooter) {
      return closestModalFooter;
    }
  }
  const modalContainer = getModalContainerElement(elementRoot);
  if (modalContainer?.querySelector) {
    const modalFooter = modalContainer.querySelector('.modal-footer');
    if (modalFooter) {
      return modalFooter;
    }
  }
  return queryElementBySelectors(['.modal-footer'], elementRoot || document);
}

export function getModalToolbarElement(root = null) {
  const elementRoot = resolveElementRoot(root);
  if (elementRoot && elementRoot !== document) {
    if (elementRoot.matches?.('.toolbar')) {
      return elementRoot;
    }
    const closestToolbar = elementRoot.closest?.('.toolbar');
    if (closestToolbar) {
      return closestToolbar;
    }
  }
  const modalContainer = getModalContainerElement(elementRoot);
  if (modalContainer?.querySelector) {
    const toolbar = modalContainer.querySelector('.toolbar');
    if (toolbar) {
      return toolbar;
    }
  }
  return queryElementBySelectors(['.modal-header .toolbar', '.toolbar'], elementRoot || document);
}
function isDomNode(candidate) {
  return !!candidate && typeof candidate === 'object' && typeof candidate.nodeType === 'number';
}

function resolveElementRoot(root = null) {
  return resolveCompatHostElement(root);
}


export function getAppElement(root = null) {
  const elementRoot = resolveElementRoot(root);
  const scopedDocument = elementRoot?.nodeType === 9
    ? elementRoot
    : (elementRoot?.ownerDocument || document);

  if (elementRoot && elementRoot !== document) {
    const closestApp = elementRoot.closest?.('#app');
    if (closestApp) {
      return closestApp;
    }
  }

  const mountRoot = scopedDocument.querySelector?.('#app[data-v-app]') || scopedDocument.getElementById?.('app') || null;
  if (mountRoot?.firstElementChild?.id === 'app') {
    return mountRoot.firstElementChild;
  }
  return mountRoot;
}

export function getAppComputedStyle(root = null) {
  const appElement = getAppElement(root);
  const scopedWindow = appElement?.ownerDocument?.defaultView || window;
  return appElement ? scopedWindow.getComputedStyle(appElement, null) : null;
}

export function getAppClientWidth(root = null) {
  const appElement = getAppElement(root);
  const styleWidth = parseFloat(getAppComputedStyle(root)?.getPropertyValue('width') || '');
  if (!Number.isNaN(styleWidth) && styleWidth > 0) {
    return styleWidth;
  }
  const scopedDocument = appElement?.ownerDocument || document;
  const scopedWindow = scopedDocument?.defaultView || window;
  return Number(appElement?.clientWidth || scopedDocument?.documentElement?.clientWidth || scopedWindow.innerWidth || 0);
}


export function getAppMountElement(root = null) {
  const elementRoot = resolveElementRoot(root);
  const scopedDocument = elementRoot?.nodeType === 9
    ? elementRoot
    : (elementRoot?.ownerDocument || document);
  return scopedDocument.querySelector?.('#app[data-v-app]') || scopedDocument.getElementById?.('app') || null;
}

export function getConsoleFrameElement(root = null) {
  return queryElementBySelectors(['#consoleFrame'], getAppElement(root) || getAppMountElement(root) || root || document);
}

export function getBreadcrumbContentElements(root = null) {
  return queryElementsBySelectors(['.breadcrumb-content'], getAppElement(root) || getAppMountElement(root) || root || document);
}

export function getShellOverlayElements(root = null) {
  return queryElementsBySelectors([
    '.modal-container',
    '.modal-container-custom',
    'ons-dialog',
    'ons-alert-dialog',
    'ons-popover',
    '.dialog-container',
    '.dialog',
    '.alert-dialog',
    '.popover',
    '.modal-mask',
    '.popover-mask'
  ], root || document);
}

export function getAlertDialogFooterButtonElements(root = null) {
  return queryElementsBySelectors([
    '.alert-dialog-footer a',
    '.alert-dialog-footer button',
    '.alert-dialog-footer ons-alert-dialog-button'
  ], root || document);
}

export function getLayoutRootElement(root = null) {
  const elementRoot = resolveElementRoot(root);
  if (elementRoot && elementRoot !== document) {
    if (typeof elementRoot.closest === 'function') {
      const scopedRoot = elementRoot.closest('[data-ntss-layout-root]');
      if (scopedRoot) {
        return scopedRoot;
      }
    }
    if (elementRoot.matches?.('[data-ntss-layout-root]')) {
      return elementRoot;
    }
  }
  const fallbackDocument = elementRoot?.ownerDocument || document;
  return fallbackDocument.querySelector?.('[data-ntss-layout-root]') || null;
}

function normalizeRoots(root = null) {
  const roots = [];
  const elementRoot = resolveElementRoot(root);
  const pushRoot = (candidate) => {
    if (!candidate) {
      return;
    }
    const normalized = candidate === window ? document : candidate;
    if (!roots.includes(normalized)) {
      roots.push(normalized);
    }
  };

  pushRoot(elementRoot);
  if (elementRoot && elementRoot !== document) {
    pushRoot(
      elementRoot.closest?.(
        [
          '[data-ntss-scope-root]',
          '[data-ntss-owner-root]',
          '[data-ntss-role="modal-root"]',
          '.modal-container',
          '.modal-body',
          '.modal-content',
          '[role="dialog"]',
          '[data-ntss-role="popover-root"]',
          '.popover',
          '.popover__content',
          '[data-ntss-role="grid-root"]',
          '.k-grid',
          '.k-grid-content',
          '.k-grid-content-locked',
          '[data-ntss-role="virtual-scroll-root"]',
          '.k-virtual-scrollable-wrap',
          '#main-content-area',
          '.main-content-area',
          '[data-ntss-layout="main-content"]'
        ].join(', ')
      ) || null
    );
  }
  pushRoot(getLayoutRootElement(elementRoot));
  pushRoot(elementRoot?.ownerDocument || document);
  return roots.filter(Boolean);
}


export function getPrimaryScopeRoot(root = null) {
  const roots = normalizeRoots(root);
  return roots.length > 0 ? roots[0] : (document || null);
}

export function queryElementBySelectors(selectors = [], root = null) {
  const safeSelectors = Array.isArray(selectors) ? selectors.filter(Boolean) : [selectors].filter(Boolean);
  for (const scope of normalizeRoots(root)) {
    const found = queryElementBySelectorsCompat(safeSelectors, [scope], { includeSelf: true });
    if (found) {
      return found;
    }
  }
  return null;
}

export function queryElementsBySelectors(selectors = [], root = null) {
  const safeSelectors = Array.isArray(selectors) ? selectors.filter(Boolean) : [selectors].filter(Boolean);
  const results = [];
  normalizeRoots(root).forEach((scope) => {
    queryElementsBySelectorsCompat(safeSelectors, [scope], { includeSelf: true }).forEach((element) => {
      if (!results.includes(element)) {
        results.push(element);
      }
    });
  });
  return results;
}

export function getHeaderElements(root = document) {
  return queryElementsBySelectors(['.header'], root);
}

export function getLatestHeaderElement(root = document) {
  const headers = getHeaderElements(root);
  return headers.length > 0 ? headers[headers.length - 1] : null;
}

export function getFooterMenuElement(root = null) {
  return queryElementBySelectors(['[data-ntss-layout-role="footer-menu"]', '#footer-menu', '.bottom-bar', '.ntss-footer.bottom-bar'], root);
}

export function getUserMenuElement(root = null) {
  return queryElementBySelectors(['#user-menu', '[data-ntss-layout-role="user-menu"]'], root);
}

export function getNotificationUnreadCountElement(root = null) {
  return queryElementBySelectors(['.notification.unread-count'], root);
}


export function getPatientSearchSidebarElement(root = null) {
  return queryElementBySelectors(['[data-ntss-layout-role="patient-search-sidebar"]', '#patientSearchSidebarArea'], getLayoutRootElement(root) || getAppElement(root) || resolveElementRoot(root) || document);
}

export function getSidebarToggleButtonElement(root = null) {
  return queryElementBySelectors(['[data-ntss-layout-role="sidebar-toggle"]', '#showPatientSearchSidebarBtn'], getLayoutRootElement(root) || getAppElement(root) || resolveElementRoot(root) || document);
}

export function getFooterMenuBaseElement(root = null) {
  const footerMenu = getFooterMenuElement(root);
  if (footerMenu?.querySelector) {
    const localBase = footerMenu.querySelector('.footer-base-area');
    if (localBase) {
      return localBase;
    }
  }
  return queryElementBySelectors(['.footer-base-area'], footerMenu || root);
}

function isElementVisible(element) {
  return compatIsElementVisible(element);
}

function getRenderedElementHeight(element) {
  return compatGetRenderedElementHeight(element);
}

export function getVisibleFooterMenuHeight(root = null) {
  const footerMenu = getFooterMenuElement(root);
  const footerBase = getFooterMenuBaseElement(footerMenu || root);
  const listOpenButtonArea = queryElementBySelectors(['#listOpenBtnArea'], footerMenu || root);
  return Math.max(
    getRenderedElementHeight(footerMenu),
    //getRenderedElementHeight(footerBase),
    getRenderedElementHeight(listOpenButtonArea),
    0
  );
}

export function hasRenderedHeaderContent(headerRoot) {
  if (!headerRoot) {
    return false;
  }
  return !!(
    (headerRoot.firstElementChild && headerRoot.firstElementChild.childElementCount > 0)
    || (headerRoot.querySelector?.('.bread-crumbs')?.childElementCount > 0)
    || (headerRoot.textContent || '').trim()
  );
}

export function getHeaderHeight(headerRoot, fallback = 0) {
  if (!hasRenderedHeaderContent(headerRoot)) {
    return 0;
  }
  const height = Number(headerRoot?.clientHeight || 0);
  return height > 0 ? height : Number(fallback || 0);
}


export function getFooterMenuClientHeight(root = null) {
  return getVisibleFooterMenuHeight(root);
}

export function getGridHeaderElement(root = null) {
  return queryElementBySelectors(['#grid-header', '[data-ntss-role="grid-header"]', '.k-grid-header'], root);
}

export function getGridFooterElement(root = null) {
  return queryElementBySelectors(['#grid-footer', '[data-ntss-role="grid-footer"]'], root);
}

export function getGridFooterClientHeight(root = null) {
  return Number(getGridFooterElement(root)?.clientHeight || 0);
}

export function getMainContentAreaElement(root = null) {
  return queryElementBySelectors(['[data-ntss-layout-role="main-content"]', '#main-content-area', '.main-content-area', '[data-ntss-layout="main-content"]'], root);
}

export function getClosestMainContentAreaElement(target = null) {
  const element = resolveElementRoot(target);
  if (!element || typeof element.closest !== 'function') {
    return getMainContentAreaElement(target);
  }
  return element.closest('#main-content-area, .main-content-area, [data-ntss-layout="main-content"]') || getMainContentAreaElement(element);
}

export function getFooterMenuHeight({ root = null, isDispMenu = 0 } = {}) {
  if (Number(isDispMenu) !== 1) {
    return 0;
  }
  return getVisibleFooterMenuHeight(root);
}


export function shouldCloseTransientMenusOnLayoutClick(event) {
  const currentTarget = event?.currentTarget || null;
  const target = event?.target || null;
  if (!currentTarget || !target || target === currentTarget) {
    return true;
  }
  const ignoredRoot = typeof target.closest === 'function'
    ? target.closest('[data-ntss-layout-ignore-close]')
    : null;
  return !(ignoredRoot && currentTarget.contains?.(ignoredRoot));
}


function escapeCssToken(value = '') {
  const normalized = String(value || '').trim();
  if (!normalized) {
    return '';
  }
  try {
    if (typeof CSS !== 'undefined' && typeof CSS.escape === 'function') {
      return CSS.escape(normalized);
    }
  } catch (_error) {
    // noop
  }
  return normalized.replace(/([^a-zA-Z0-9_-])/g, '\\$1');
}

function escapeAttributeValue(value = '') {
  return String(value || '').replace(/\\/g, '\\\\').replace(/"/g, '\\"');
}

function escapeClassToken(className = '') {
  return escapeCssToken(String(className || '').trim().replace(/^\./, ''));
}

function createClassSelector(className = '') {
  const classTokens = String(className || '')
    .trim()
    .split(/\s+/)
    .map((token) => escapeClassToken(token))
    .filter(Boolean);
  if (!classTokens.length) {
    return '';
  }
  return classTokens.map((token) => `.${token}`).join('');
}

export function getFirstElementByClassName(className, root = null) {
  const selector = createClassSelector(className);
  if (!selector) {
    return null;
  }
  return queryElementBySelectors([selector], root);
}

export function getScopedElement(root = null, ...selectors) {
  return queryElementBySelectors(selectors, root);
}

export function getScopedElementById(id = '', root = null) {
  if (!id) {
    return null;
  }
  const normalizedId = String(id).replace(/^#/, '');
  const escapedId = escapeCssToken(normalizedId);
  const attrSelector = `[id="${escapeAttributeValue(normalizedId)}"]`;
  const roots = normalizeRoots(root);

  for (const scope of roots) {
    if (!scope) {
      continue;
    }
    if (scope.nodeType === 1) {
      if (scope.id === normalizedId) {
        return scope;
      }
      const scopedHit = queryElementBySelectors([`#${escapedId}`, attrSelector], scope);
      if (scopedHit) {
        return scopedHit;
      }
    }
    if (scope.nodeType === 9) {
      const byId = scope.getElementById?.(normalizedId) || null;
      if (byId) {
        return byId;
      }
    }
  }

  for (const scope of roots) {
    const scopedDocument = scope?.nodeType === 9 ? scope : (scope?.ownerDocument || document);
    const byId = scopedDocument?.getElementById?.(normalizedId) || null;
    if (byId && (scope === scopedDocument || byId === scope || scope?.contains?.(byId))) {
      return byId;
    }
  }
  return getCompatScopedElementById(normalizedId, root);
}

export function getScopedElementsByClassName(className = '', root = null) {
  const selector = createClassSelector(className);
  if (!selector) {
    return [];
  }
  return queryElementsBySelectors([selector], root);
}

export function queryScopedSelector(selector = '', root = null) {
  if (!selector) {
    return null;
  }
  return queryElementBySelectors([selector], root);
}

export function queryScopedSelectorAll(selector = '', root = null) {
  if (!selector) {
    return [];
  }
  return queryElementsBySelectors([selector], root);
}


export function getScopedBody(root = null) {
  return getCompatScopedBody(root);
}

export function resolveHostElement(root = null) {
  return resolveCompatHostElement(root);
}

export function closestWithinHost(element, selector, host = null) {
  return compatClosestWithinHost(element, selector, host);
}

export function getScopedElementByClassName(className = '', root = null) {
  return getCompatScopedElementByClassName(className, root);
}

export function getScopedJQuery(root = null, jqueryInstance = null) {
  const jq = jqueryInstance || globalThis?.jQuery || globalThis?.$ || null;
  if (typeof jq !== 'function') {
    return null;
  }

  return function scopedJQuery(selector, context) {
    if (context) {
      return jq(selector, context);
    }
    if (typeof selector === 'string') {
      const trimmedSelector = selector.trim();
      if (!trimmedSelector || trimmedSelector.startsWith('<')) {
        return jq(selector);
      }
      return jq(queryScopedSelectorAll(trimmedSelector, root));
    }
    return jq(selector);
  };
}

export function getScopedElementsByTagName(tagName = '', root = null) {
  const normalizedTagName = String(tagName || '').trim();
  if (!normalizedTagName) {
    return [];
  }
  return queryElementsBySelectors([normalizedTagName], root);
}

export function getInputElementFromComponentRef(target = null) {
  if (!target) {
    return null;
  }
  const componentElement = compatGetComponentEl(target) || resolveElementRoot(target);
  const candidates = [
    compatResolveRefElement(target),
    target?._input?.value,
    target?._input,
    target?.inputEl?.value,
    target?.inputEl,
    target?.$el?._input,
    target?.$el?.querySelector?.("input, textarea, select, [contenteditable='true']"),
    target?.querySelector?.("input, textarea, select, [contenteditable='true']"),
    target?.$?.subTree?.el?.querySelector?.("input, textarea, select, [contenteditable='true']"),
    componentElement?.matches?.("input, textarea, select, [contenteditable='true']") ? componentElement : null,
    componentElement?.querySelector?.("input, textarea, select, [contenteditable='true']")
  ];
  return candidates.find((candidate) => candidate && typeof candidate.focus === 'function') || null;
}

export function focusComponentInput(target = null) {
  const inputElement = getInputElementFromComponentRef(target);
  inputElement?.focus?.();
  return inputElement;
}

export function getModalContentRoot(root = null) {
  return getModalBodyElement(root) || getModalContainerElement(root) || resolveElementRoot(root) || getScopedDocument(root);
}

export function getScopedNumericTextBox(root = null) {
  return queryScopedSelector('.k-numerictextbox', root);
}

export function getScopedAlertDialogs(root = null) {
  return getScopedElementsByTagName("ons-alert-dialog", root);
}

export function getScopedAlertDialog(root = null) {
  return getScopedAlertDialogs(root)[0] || null;
}

export function getScopedCalendarRoot(root = null) {
  return queryElementBySelectors(['.vc-pane-container', '.vc-container', '.vc-weeks', '.vc-reset'], root);
}

export function getAvailableMainContentHeight({ root = null, isDispMenu = 0, extraOffset = 0 } = {}) {
  const mainContent = getMainContentAreaElement(root);
  const viewportHeight = getViewportHeight(root);
  const mainRect = mainContent?.getBoundingClientRect?.() || null;
  const topOffset = Number(mainRect?.top || 0);
  const footerHeight = getFooterMenuHeight({ root, isDispMenu });
  return Math.max(viewportHeight - topOffset - footerHeight - Number(extraOffset || 0), 0);
}

export function getContentContainerElement(root = null) {
  return getFirstElementByClassName('content-container', root);
}

export function getPatInfoHeaderAreaElement(root = null) {
  return getFirstElementByClassName('pat-info-header-area', root);
}

export function getPatHeaderElement(root = null) {
  return getFirstElementByClassName('pat-header', root);
}

export function getRightExeButtonElement(root = null) {
  return getFirstElementByClassName('right-exe-btn', root);
}

export function getElementRect(target = null) {
  return compatGetElementRect(target);
}

export function getElementRenderedHeight(target = null) {
  return compatGetRenderedElementHeight(target);
}

export function getElementRenderedWidth(target = null) {
  return compatGetRenderedElementWidth(target);
}

export function getElementClientSize(target = null) {
  return compatGetClientSize(target);
}


export function getScopedElementDisplayValue(target = null, root = null) {
  const element = typeof target === 'string'
    ? (getScopedElementById(target, root) || queryElementBySelectors([target], root))
    : resolveElementRoot(target);
  if (!element) {
    return '';
  }
  return getComputedStyleSafe(element)?.display || element.style?.display || '';
}

export function isScopedElementDisplayInline(target = null, root = null) {
  return getScopedElementDisplayValue(target, root) === 'inline';
}

export function getComputedStyleSafe(target = null, pseudoElt = null) {
  return compatGetComputedStyleSafe(target, pseudoElt);
}

export function isVisibleElement(target = null) {
  return compatIsElementVisible(target);
}

export function requestScopedAnimationFrame(root = null, callback = () => {}) {
  return compatRequestScopedAnimationFrame(root, callback);
}

export function cancelScopedAnimationFrame(root = null, handle = null) {
  return compatCancelScopedAnimationFrame(root, handle);
}

export function nextLayoutFrame(root = null) {
  return compatNextLayoutFrame(root);
}

export function observeElementResize(target = null, callback = () => {}, options = {}) {
  return compatObserveElementResize(target, callback, options);
}

export function resolveScrollableElement(target = null) {
  return compatResolveScrollableElement(target);
}

export function setElementStyleSafe(target = null, styles = {}) {
  return compatSetElementStyleSafe(target, styles);
}

export function getComponentElement(target = null) {
  return compatGetComponentEl(target);
}

export function resolveRefElement(target = null, refName = null) {
  return compatResolveRefElement(target, refName);
}

export function getLegacyParent(target = null, depth = 1) {
  return compatGetLegacyParent(target, depth);
}

export function getLegacyChildren(target = null) {
  return compatGetLegacyChildren(target);
}

export function safeCallComponentMethod(target = null, methodName = '', ...args) {
  return compatSafeCallComponentMethod(target, methodName, ...args);
}

