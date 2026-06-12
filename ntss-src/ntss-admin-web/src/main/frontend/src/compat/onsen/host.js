import {
  closestWithinHost,
  getScopedBody,
  isElementNode,
  queryElementBySelectors,
  queryElementsBySelectors,
  resolveElement,
  resolveHostElement,
  resolveOwnerDocument
} from "@/compat/dom/host";

function normalizeTagName(tagName = "") {
  return String(tagName || "").trim().toLowerCase();
}

function normalizeSelector(selector = "") {
  return String(selector || "").trim();
}

function normalizeClassName(className = "") {
  return String(className || "").trim().replace(/^\./, "");
}

function pushUnique(result, element) {
  if (element && !result.includes(element)) {
    result.push(element);
  }
}

function getRoleSelector(tagName, legacySelector = "") {
  const tag = normalizeTagName(tagName);
  const legacy = normalizeSelector(legacySelector);
  return [tag, legacy].filter(Boolean).join(", ");
}

function resolveOnsHost(target = null, fallbackRoot = null) {
  return resolveElement(target)
    || resolveElement(fallbackRoot)
    || getScopedBody(fallbackRoot || target)
    || getScopedBody();
}

export function resolveOnsElement(target = null) {
  return resolveElement(target);
}

export function getOnsOwnerDocument(target = null, fallbackRoot = null) {
  return resolveOwnerDocument(target || fallbackRoot);
}

export function isOnsElement(candidate, tagName, legacySelector = "") {
  const element = resolveElement(candidate);
  const selector = getRoleSelector(tagName, legacySelector);
  if (!element || !selector) {
    return false;
  }
  try {
    return element.matches?.(selector) === true
      || normalizeTagName(element.localName || element.nodeName) === normalizeTagName(tagName);
  } catch (_error) {
    return normalizeTagName(element.localName || element.nodeName) === normalizeTagName(tagName);
  }
}

export function getOnsElement(target = null, tagName, legacySelector = "", fallbackRoot = null) {
  const element = resolveElement(target);
  const selector = getRoleSelector(tagName, legacySelector);
  if (element && selector) {
    if (isOnsElement(element, tagName, legacySelector)) {
      return element;
    }
    const closest = closestWithinHost(element, selector, fallbackRoot || element)
      || element.closest?.(selector)
      || null;
    if (closest) {
      return closest;
    }
    const nested = queryElementsBySelectors([selector], element, {
      includeSelf: false,
      includeBody: false,
      includeOwnerDocument: false,
      includeDefaultDocument: false
    });
    if (nested.length > 0) {
      return nested[nested.length - 1];
    }
  }

  const root = resolveOnsHost(fallbackRoot, target);
  if (!root || !selector) {
    return null;
  }
  return queryElementBySelectors([selector], root, {
    includeSelf: true,
    includeClosestHost: true,
    includeBody: false,
    includeOwnerDocument: false,
    includeDefaultDocument: false
  });
}

export function getOnsElementFromEvent(event = null, tagName, legacySelector = "", fallbackRoot = null, eventField = null) {
  const direct = eventField ? event?.[eventField] : null;
  return getOnsElement(
    direct || event?.popover || event?.dialog || event?.alertDialog || event?.modal || event?.target || event?.currentTarget || null,
    tagName,
    legacySelector,
    fallbackRoot
  );
}

export function queryOnsPart(root = null, selectors = [], fallbackRoot = null) {
  const element = resolveElement(root);
  const searchRoot = element || resolveOnsHost(fallbackRoot, root);
  return queryElementBySelectors(selectors, searchRoot ? [searchRoot] : null, {
    includeSelf: false,
    includeClosestHost: false,
    includeBody: false,
    includeOwnerDocument: false,
    includeDefaultDocument: false
  });
}

export function queryOnsParts(root = null, selectors = [], fallbackRoot = null) {
  const element = resolveElement(root);
  const searchRoot = element || resolveOnsHost(fallbackRoot, root);
  return queryElementsBySelectors(selectors, searchRoot ? [searchRoot] : null, {
    includeSelf: false,
    includeClosestHost: false,
    includeBody: false,
    includeOwnerDocument: false,
    includeDefaultDocument: false
  });
}

export function getOnsScopedElementsByClassName(rootOrComponent, tagName, className, fallbackRoot = null, hostClass = null, legacySelector = "") {
  const normalizedClassName = normalizeClassName(className);
  if (!normalizedClassName) {
    return [];
  }

  const selector = `.${normalizedClassName}`;
  const result = [];
  const hostElement = getOnsElement(rootOrComponent, tagName, legacySelector, fallbackRoot)
    || resolveElement(rootOrComponent);

  if (hostElement) {
    if (hostElement.matches?.(selector)) {
      pushUnique(result, hostElement);
    }
    queryOnsParts(hostElement, [selector]).forEach((element) => pushUnique(result, element));
  }

  if (result.length > 0) {
    return result;
  }

  const normalizedHostClass = normalizeClassName(hostClass);
  const fallbackSelector = normalizedHostClass
    ? `.${normalizedHostClass}${selector}, .${normalizedHostClass} ${selector}`
    : selector;
  queryElementsBySelectors([fallbackSelector], fallbackRoot || rootOrComponent || getScopedBody(rootOrComponent), {
    includeSelf: true,
    includeClosestHost: true,
    includeBody: true,
    includeOwnerDocument: false,
    includeDefaultDocument: true
  }).forEach((element) => pushUnique(result, element));
  return result;
}

export function ensureOnsCompatEvent(event, roleName, element = null) {
  if (!event || typeof event !== "object") {
    return event;
  }
  const resolved = resolveElement(element) || resolveElement(event?.target) || resolveElement(event?.currentTarget);
  if (!resolved) {
    return event;
  }
  const define = (name, value) => {
    if (value == null || event[name] != null) {
      return;
    }
    try {
      Object.defineProperty(event, name, {
        configurable: true,
        enumerable: false,
        value
      });
    } catch (_error) {
      try {
        event[name] = value;
      } catch (__error) {
        // noop
      }
    }
  };
  define("target", resolved);
  define("currentTarget", resolved);
  define("element", resolved);
  if (roleName) {
    define(roleName, resolved);
  }
  return event;
}

export function wrapOnsEventHandler(handler, roleName, resolveElementForEvent) {
  if (typeof handler !== "function") {
    return handler;
  }
  return (...args) => {
    const firstArg = args[0];
    const compatElement = typeof resolveElementForEvent === "function"
      ? resolveElementForEvent(firstArg)
      : null;
    if (firstArg && typeof firstArg === "object") {
      args[0] = ensureOnsCompatEvent(firstArg, roleName, compatElement);
    }
    return handler(...args);
  };
}

export { isElementNode, resolveHostElement };
