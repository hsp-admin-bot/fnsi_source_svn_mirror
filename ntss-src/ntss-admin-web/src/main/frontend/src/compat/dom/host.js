const ELEMENT_NODE = 1;
const DOCUMENT_NODE = 9;
const DOCUMENT_FRAGMENT_NODE = 11;

function getGlobalValue(name) {
  try {
    return typeof globalThis !== 'undefined' ? globalThis[name] || null : null;
  } catch (_error) {
    return null;
  }
}

export function getDefaultDocument() {
  return getGlobalValue('document');
}

export function getDefaultWindow() {
  return getGlobalValue('window');
}

export function isWindowObject(candidate) {
  return !!candidate && typeof candidate === 'object' && candidate.window === candidate;
}

export function isDomNode(candidate) {
  return !!candidate && typeof candidate === 'object' && typeof candidate.nodeType === 'number';
}

export function isElementNode(candidate) {
  return isDomNode(candidate) && candidate.nodeType === ELEMENT_NODE;
}

export function isDocumentNode(candidate) {
  return isDomNode(candidate) && candidate.nodeType === DOCUMENT_NODE;
}

export function isDocumentFragmentNode(candidate) {
  return isDomNode(candidate) && candidate.nodeType === DOCUMENT_FRAGMENT_NODE;
}

function isQueryableNode(candidate) {
  return isElementNode(candidate) || isDocumentNode(candidate) || isDocumentFragmentNode(candidate);
}

function isVuePublicInstance(candidate) {
  return !!candidate && typeof candidate === 'object' && (
    '$' in candidate ||
    '$el' in candidate ||
    '$refs' in candidate ||
    '$data' in candidate ||
    '$props' in candidate
  );
}

function asJQueryElement(candidate) {
  if (!candidate || typeof candidate !== 'object') {
    return null;
  }
  if (candidate.jquery && typeof candidate.length === 'number') {
    return candidate[0] || null;
  }
  if (typeof candidate.get === 'function' && typeof candidate.length === 'number') {
    try {
      return candidate.get(0) || null;
    } catch (_error) {
      return null;
    }
  }
  return null;
}

/**
 * DOM イベントかどうか（ポップオーバー anchor 用）
 * @summary クリック実体は target を優先する（Vue2 / Onsen UI の挙動に合わせる）
 */
function isDomEvent(candidate) {
  return !!candidate
    && typeof candidate === 'object'
    && !isVuePublicInstance(candidate)
    && !isElementNode(candidate)
    && !isDocumentNode(candidate)
    && !isDocumentFragmentNode(candidate)
    && !isWindowObject(candidate)
    && !Array.isArray(candidate)
    && (candidate.target != null || candidate.currentTarget != null);
}

function getCandidateList(target) {
  if (!target || typeof target !== 'object') {
    return [];
  }

  // Vue3 public instance proxy warns when arbitrary fields such as
  // currentTarget/target are read during render.  For component proxies only
  // read the DOM-bearing fields Vue exposes intentionally.
  if (isVuePublicInstance(target)) {
    return [
      target.$el,
      target.$?.vnode?.el,
      target.$?.subTree?.el,
      target.$?.parent?.proxy?.$el,
      target.$?.parent?.vnode?.el,
      target.$?.parent?.subTree?.el
    ];
  }

  // イベントは実際にクリックされた要素（target）を優先する。
  // currentTarget を先にすると、子要素クリック時も親の @click 要素に popover が付く。
  if (isDomEvent(target)) {
    return [
      asJQueryElement(target),
      target.target,
      target.currentTarget,
      target.srcElement
    ];
  }

  return [
    asJQueryElement(target),
    target.currentTarget,
    target.target,
    target.srcElement,
    target.$el,
    target.el,
    target.element,
    target.wrapper,
    target.nativeElement,
    target.root,
    target.mountNode,
    target.mountNode?.firstElementChild,
    target.popup?.wrapper,
    target.popup?.element,
    target.vnode?.el,
    target.subTree?.el,
    target.proxy?.$el,
    target.ctx?.$el,
    target.value
  ];
}

export function resolveHostElement(target = null, options = {}) {
  const { allowDocument = true, allowFragment = true, maxDepth = 8 } = options;

  function visit(candidate, depth) {
    if (!candidate || depth > maxDepth) {
      return null;
    }

    // Vue3 public instance proxies warn when arbitrary properties such as
    // window/nodeType/jquery/get are read during render.  Vue2 page code can
    // still pass component instances as scope roots, so unwrap them before
    // probing DOM/jQuery specific fields.
    if (isVuePublicInstance(candidate)) {
      for (const nextCandidate of getCandidateList(candidate)) {
        const resolved = visit(nextCandidate, depth + 1);
        if (resolved) return resolved;
      }
      return null;
    }

    if (isWindowObject(candidate)) {
      return allowDocument ? candidate.document || null : null;
    }
    if (isElementNode(candidate)) {
      return candidate;
    }
    if (allowDocument && isDocumentNode(candidate)) {
      return candidate;
    }
    if (allowFragment && isDocumentFragmentNode(candidate)) {
      return candidate;
    }
    if (Array.isArray(candidate)) {
      for (const item of candidate) {
        const resolved = visit(item, depth + 1);
        if (resolved) return resolved;
      }
      return null;
    }
    const jqElement = asJQueryElement(candidate);
    if (jqElement) {
      return visit(jqElement, depth + 1);
    }
    for (const nextCandidate of getCandidateList(candidate)) {
      const resolved = visit(nextCandidate, depth + 1);
      if (resolved) return resolved;
    }
    return null;
  }

  return visit(target, 0);
}

export function resolveElement(target = null) {
  const resolved = resolveHostElement(target, { allowDocument: false, allowFragment: false });
  return isElementNode(resolved) ? resolved : null;
}

export function resolveOwnerDocument(target = null) {
  const resolved = resolveHostElement(target, { allowDocument: true, allowFragment: true });
  if (isDocumentNode(resolved)) {
    return resolved;
  }
  if (isDocumentFragmentNode(resolved)) {
    return resolved.ownerDocument || getDefaultDocument();
  }
  return resolved?.ownerDocument || getDefaultDocument();
}

export function resolveOwnerWindow(target = null) {
  return resolveOwnerDocument(target)?.defaultView || getDefaultWindow();
}

export function getScopedBody(target = null) {
  const scopedDocument = resolveOwnerDocument(target);
  return scopedDocument?.body || scopedDocument?.documentElement || null;
}

function normalizeSelectorList(selectors = []) {
  if (Array.isArray(selectors)) {
    return selectors.map((selector) => String(selector || '').trim()).filter(Boolean);
  }
  const selector = String(selectors || '').trim();
  return selector ? [selector] : [];
}

function matchesSelector(element, selector) {
  if (!isElementNode(element) || typeof element.matches !== 'function' || !selector) {
    return false;
  }
  try {
    return element.matches(selector);
  } catch (_error) {
    return false;
  }
}

function safeQuerySelector(root, selector) {
  if (!root || !selector || typeof root.querySelector !== 'function') {
    return null;
  }
  try {
    return root.querySelector(selector) || null;
  } catch (_error) {
    return null;
  }
}

function safeQuerySelectorAll(root, selector) {
  if (!root || !selector || typeof root.querySelectorAll !== 'function') {
    return [];
  }
  try {
    return Array.from(root.querySelectorAll(selector));
  } catch (_error) {
    return [];
  }
}

export function normalizeHostRoots(root = null, options = {}) {
  const {
    includeSelf = true,
    includeClosestHost = true,
    includeOwnerDocument = true,
    includeBody = true,
    includeDefaultDocument = true
  } = options;
  const roots = [];
  const push = (candidate) => {
    const resolved = resolveHostElement(candidate, { allowDocument: true, allowFragment: true });
    if (resolved && isQueryableNode(resolved) && !roots.includes(resolved)) {
      roots.push(resolved);
    }
  };

  const host = resolveHostElement(root, { allowDocument: true, allowFragment: true });
  if (includeSelf) {
    push(host);
  }

  if (includeClosestHost && isElementNode(host)) {
    const selector = [
      '[data-ntss-scope-root]',
      '[data-ntss-owner-root]',
      '[data-ntss-layout-root]',
      '[data-ntss-role="modal-root"]',
      '[data-ntss-role="popover-root"]',
      '[role="dialog"]',
      '.modal-container',
      '.modal-content',
      '.modal-body',
      '.dialog',
      '.popover',
      '.popover__content',
      '.k-grid',
      '.k-widget',
      '#app'
    ].join(', ');
    try {
      push(host.closest?.(selector) || null);
    } catch (_error) {
      // noop
    }
  }

  const ownerDocument = resolveOwnerDocument(host || root);
  if (includeBody) {
    push(ownerDocument?.body || null);
  }
  if (includeOwnerDocument) {
    push(ownerDocument || null);
  }
  if (includeDefaultDocument) {
    push(getDefaultDocument());
  }
  return roots;
}

export function queryElementBySelectors(selectors = [], root = null, options = {}) {
  const safeSelectors = normalizeSelectorList(selectors);
  const roots = Array.isArray(root) ? root : normalizeHostRoots(root, options);
  for (const rawRoot of roots) {
    const scope = resolveHostElement(rawRoot, { allowDocument: true, allowFragment: true });
    if (!scope) continue;
    for (const selector of safeSelectors) {
      if (options.includeSelf !== false && matchesSelector(scope, selector)) {
        return scope;
      }
      const found = safeQuerySelector(scope, selector);
      if (found) {
        return found;
      }
    }
  }
  return null;
}

export function queryElementsBySelectors(selectors = [], root = null, options = {}) {
  const safeSelectors = normalizeSelectorList(selectors);
  const roots = Array.isArray(root) ? root : normalizeHostRoots(root, options);
  const results = [];
  const push = (candidate) => {
    if (candidate && !results.includes(candidate)) {
      results.push(candidate);
    }
  };
  roots.forEach((rawRoot) => {
    const scope = resolveHostElement(rawRoot, { allowDocument: true, allowFragment: true });
    if (!scope) return;
    safeSelectors.forEach((selector) => {
      if (options.includeSelf !== false && matchesSelector(scope, selector)) {
        push(scope);
      }
      safeQuerySelectorAll(scope, selector).forEach(push);
    });
  });
  return results;
}

export function closestWithinHost(element, selector, host = null) {
  const target = resolveElement(element);
  if (!target || !selector) {
    return null;
  }
  let closest = null;
  try {
    closest = target.matches?.(selector) ? target : target.closest?.(selector) || null;
  } catch (_error) {
    closest = null;
  }
  if (!closest) {
    return null;
  }
  const safeHost = resolveHostElement(host, { allowDocument: true, allowFragment: true });
  if (!safeHost || isDocumentNode(safeHost)) {
    return closest;
  }
  return closest === safeHost || safeHost.contains?.(closest) ? closest : null;
}

function escapeCssToken(value = '') {
  const normalized = String(value || '');
  try {
    const ownerWindow = getDefaultWindow();
    const css = ownerWindow?.CSS || getGlobalValue('CSS');
    if (typeof css?.escape === 'function') {
      return css.escape(normalized);
    }
  } catch (_error) {
    // noop
  }
  return normalized.replace(/([^a-zA-Z0-9_-])/g, '\\$1');
}

function escapeAttributeValue(value = '') {
  return String(value || '').replace(/\\/g, '\\\\').replace(/"/g, '\\"');
}

export function getScopedElementById(id = '', root = null) {
  if (!id) {
    return null;
  }
  const normalizedId = String(id).replace(/^#/, '');
  const attrSelector = `[id="${escapeAttributeValue(normalizedId)}"]`;
  const selectors = [`#${escapeCssToken(normalizedId)}`, attrSelector];
  const roots = normalizeHostRoots(root, { includeSelf: true, includeClosestHost: true, includeBody: true, includeOwnerDocument: true });

  for (const scope of roots) {
    if (isElementNode(scope) && scope.id === normalizedId) {
      return scope;
    }
    if (isDocumentNode(scope)) {
      const byId = scope.getElementById?.(normalizedId) || null;
      if (byId) {
        return byId;
      }
    }
    const found = queryElementBySelectors(selectors, [scope], { includeSelf: true });
    if (found) {
      return found;
    }
  }
  return null;
}

export function getScopedElementByClassName(className = '', root = null) {
  const normalizedClassName = String(className || '').trim().replace(/^\./, '');
  if (!normalizedClassName) {
    return null;
  }
  const selector = normalizedClassName
    .split(/\s+/)
    .map((token) => `.${escapeCssToken(token)}`)
    .join('');
  return queryElementBySelectors([selector], root, { includeSelf: true });
}

export function isElementWithinHost(element, host = null) {
  const target = resolveElement(element);
  const safeHost = resolveHostElement(host, { allowDocument: true, allowFragment: true });
  if (!target || !safeHost) {
    return false;
  }
  if (isDocumentNode(safeHost)) {
    return safeHost.documentElement?.contains?.(target) === true;
  }
  return target === safeHost || safeHost.contains?.(target) === true;
}
