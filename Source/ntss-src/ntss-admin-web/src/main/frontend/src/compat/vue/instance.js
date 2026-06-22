import {
  isElementNode,
  resolveElement,
  resolveHostElement,
} from "@/compat/dom/host";

function hasOwn(target, key) {
  return Object.prototype.hasOwnProperty.call(target || {}, key);
}

function setReactive(target, key, value) {
  if (target && typeof target === "object") {
    target[key] = value;
  }
  return value;
}

function deleteReactive(target, key) {
  if (target && typeof target === "object") {
    delete target[key];
  }
}

function hyphenateEventName(value = "") {
  return String(value)
    .replace(/^[A-Z]/, (char) => char.toLowerCase())
    .replace(/[A-Z]/g, (char) => `-${char.toLowerCase()}`);
}

function toLegacyListenerName(key = "") {
  if (!key.startsWith("on") || key.length <= 2) {
    return "";
  }
  return key
    .slice(2)
    .replace(/Once$/, "")
    .replace(/Capture$/, "")
    .replace(/Passive$/, "");
}

function getLegacyListeners(vm = null) {
  const attrs = vm?.$attrs || {};
  const vnodeProps = vm?.$?.vnode?.props || {};
  const listeners = {};
  Object.entries({ ...attrs, ...vnodeProps }).forEach(([key, value]) => {
    if (!key.startsWith("on") || (typeof value !== "function" && !Array.isArray(value))) {
      return;
    }
    const legacyName = toLegacyListenerName(key);
    if (!legacyName) {
      return;
    }
    const eventName = legacyName.replace(/^[A-Z]/, (char) => char.toLowerCase());
    const hyphenatedName = hyphenateEventName(legacyName);
    listeners[eventName] = value;
    listeners[hyphenatedName] = value;
  });
  return listeners;
}

function getLegacyScopedSlots(vm = null) {
  return vm?.$slots || {};
}

function legacyInstanceToPrimitive(hint) {
  return hint === "number" ? NaN : "[object Object]";
}

export function isVuePublicInstance(candidate) {
  return !!candidate && typeof candidate === "object" && (
    "$" in candidate ||
    "$el" in candidate ||
    "$refs" in candidate ||
    "$data" in candidate ||
    "$props" in candidate
  );
}

export function getInternalInstance(candidate = null) {
  if (!candidate || typeof candidate !== "object") {
    return null;
  }
  return candidate.$ || candidate._ || candidate.__v_skip?.$ || candidate.__vueParentComponent || null;
}

export function unwrapVueComponentProxy(candidate = null) {
  if (!candidate || typeof candidate !== "object") {
    return candidate || null;
  }
  if (candidate.proxy) {
    return candidate.proxy;
  }
  if (candidate.component?.proxy) {
    return candidate.component.proxy;
  }
  if (candidate.ctx?.proxy) {
    return candidate.ctx.proxy;
  }
  return candidate;
}

export function getComponentEl(candidate = null) {
  if (!candidate) {
    return null;
  }
  if (isElementNode(candidate)) {
    return candidate;
  }
  const proxy = unwrapVueComponentProxy(candidate);
  const internal = getInternalInstance(proxy) || getInternalInstance(candidate);
  const candidates = [
    proxy?.$el,
    internal?.vnode?.el,
    internal?.subTree?.el,
    internal?.subTree?.anchor,
    internal?.parent?.proxy?.$el,
    internal?.parent?.vnode?.el,
    candidate?.el,
    candidate?.element,
    candidate?.wrapper,
    candidate?.value,
  ];
  for (const item of candidates) {
    const element = resolveElement(item);
    if (element) {
      return element;
    }
  }
  return resolveElement(candidate);
}

export function resolveRef(refsOrInstance = null, refName = null) {
  if (!refsOrInstance) {
    return null;
  }
  if (refName == null) {
    return Array.isArray(refsOrInstance) ? refsOrInstance[0] || null : refsOrInstance;
  }
  const refs = refsOrInstance.$refs || refsOrInstance.refs || refsOrInstance;
  const value = refs?.[refName];
  return Array.isArray(value) ? value[0] || null : value || null;
}

export function resolveRefElement(refsOrInstance = null, refName = null) {
  return getComponentEl(resolveRef(refsOrInstance, refName));
}

export function getLegacyParent(candidate = null, depth = 1) {
  let proxy = unwrapVueComponentProxy(candidate);
  let internal = getInternalInstance(proxy) || getInternalInstance(candidate);
  let currentProxy = proxy?.$parent || internal?.parent?.proxy || null;
  let currentInternal = internal?.parent || getInternalInstance(currentProxy);
  let remaining = Math.max(Number(depth || 1), 1);

  while (remaining > 1 && (currentProxy || currentInternal)) {
    currentInternal = getInternalInstance(currentProxy) || currentInternal;
    currentProxy = currentProxy?.$parent || currentInternal?.parent?.proxy || null;
    currentInternal = currentInternal?.parent || getInternalInstance(currentProxy);
    remaining -= 1;
  }
  return currentProxy || currentInternal?.proxy || null;
}

function collectChildProxiesFromVNode(vnode, results, seen) {
  if (!vnode || seen.has(vnode)) {
    return;
  }
  seen.add(vnode);
  const proxy = vnode.component?.proxy || vnode.componentInstance || null;
  if (proxy && !results.includes(proxy)) {
    results.push(proxy);
  }
  const children = Array.isArray(vnode.children) ? vnode.children : [];
  children.forEach((child) => collectChildProxiesFromVNode(child, results, seen));
  const subTree = vnode.component?.subTree;
  if (subTree && subTree !== vnode) {
    collectChildProxiesFromVNode(subTree, results, seen);
  }
}

export function getLegacyChildren(candidate = null) {
  const proxy = unwrapVueComponentProxy(candidate);
  if (Array.isArray(proxy?.$children)) {
    return proxy.$children;
  }
  const internal = getInternalInstance(proxy) || getInternalInstance(candidate);
  const results = [];
  const seen = new Set();
  collectChildProxiesFromVNode(internal?.subTree, results, seen);
  return results.filter((child) => child && child !== proxy);
}

export function findLegacyAncestor(candidate = null, predicate = null, options = {}) {
  const { includeSelf = false, maxDepth = 16 } = options;
  const matcher = typeof predicate === "function"
    ? predicate
    : (vm) => !!predicate && (vm?.$options?.name === predicate || vm?.$?.type?.name === predicate);
  let current = includeSelf ? unwrapVueComponentProxy(candidate) : getLegacyParent(candidate);
  let depth = 0;
  while (current && depth <= maxDepth) {
    if (matcher(current)) {
      return current;
    }
    current = getLegacyParent(current);
    depth += 1;
  }
  return null;
}

export function findLegacyDescendant(candidate = null, predicate = null, options = {}) {
  const { maxDepth = 16 } = options;
  const matcher = typeof predicate === "function"
    ? predicate
    : (vm) => !!predicate && (vm?.$options?.name === predicate || vm?.$?.type?.name === predicate);
  const queue = getLegacyChildren(candidate).map((child) => ({ child, depth: 1 }));
  const seen = new Set();
  while (queue.length > 0) {
    const { child, depth } = queue.shift();
    if (!child || seen.has(child) || depth > maxDepth) {
      continue;
    }
    seen.add(child);
    if (matcher(child)) {
      return child;
    }
    getLegacyChildren(child).forEach((grandChild) => queue.push({ child: grandChild, depth: depth + 1 }));
  }
  return null;
}

export function safeCallComponentMethod(candidate = null, methodName = "", ...args) {
  const proxy = unwrapVueComponentProxy(candidate);
  const method = proxy?.[methodName];
  if (typeof method !== "function") {
    return undefined;
  }
  return method.apply(proxy, args);
}

export function exposeLegacyMethods(target = null, methods = {}) {
  if (!target || typeof target !== "object" || !methods || typeof methods !== "object") {
    return target;
  }
  Object.keys(methods).forEach((key) => {
    if (!key || hasOwn(target, key)) {
      return;
    }
    const method = methods[key];
    if (typeof method === "function") {
      target[key] = method.bind(target);
    }
  });
  return target;
}

export function getLegacyRoot(candidate = null) {
  let current = unwrapVueComponentProxy(candidate);
  let parent = getLegacyParent(current);
  while (parent) {
    current = parent;
    parent = getLegacyParent(current);
  }
  return current || null;
}

export function normalizeLegacyInstance(candidate = null) {
  const proxy = unwrapVueComponentProxy(candidate);
  const element = getComponentEl(proxy);
  const ownerDocument = element?.ownerDocument || resolveHostElement(proxy, { allowDocument: true, allowFragment: true })?.ownerDocument || null;
  return {
    proxy,
    instance: getInternalInstance(proxy) || getInternalInstance(candidate),
    element,
    ownerDocument,
    parent: getLegacyParent(proxy),
    children: getLegacyChildren(proxy),
  };
}

export function installLegacyInstanceCompat(app) {
  if (!app?.config?.globalProperties) {
    return app;
  }
  const helpers = {
    getComponentEl,
    resolveRef,
    resolveRefElement,
    getLegacyParent,
    getLegacyChildren,
    getLegacyRoot,
    findLegacyAncestor,
    findLegacyDescendant,
    safeCallComponentMethod,
    normalizeLegacyInstance,
    getLegacyListeners,
    getLegacyScopedSlots,
  };
  app.config.globalProperties.$compatInstance = helpers;
  app.config.globalProperties.$set = setReactive;
  app.config.globalProperties.$delete = deleteReactive;
  if (!hasOwn(app.config.globalProperties, Symbol.toPrimitive)) {
    app.config.globalProperties[Symbol.toPrimitive] = legacyInstanceToPrimitive;
  }
  app.mixin({
    beforeCreate() {
      if (!hasOwn(this, "$listeners")) {
        Object.defineProperty(this, "$listeners", {
          configurable: true,
          get() {
            return getLegacyListeners(this);
          }
        });
      }
      if (!hasOwn(this, "$scopedSlots")) {
        Object.defineProperty(this, "$scopedSlots", {
          configurable: true,
          get() {
            return getLegacyScopedSlots(this);
          }
        });
      }
    }
  });
  app.config.globalProperties.$resolveRefElement = function $resolveRefElement(refName) {
    return resolveRefElement(this, refName);
  };
  app.config.globalProperties.$getLegacyParent = function $getLegacyParent(depth = 1) {
    return getLegacyParent(this, depth);
  };
  app.config.globalProperties.$getLegacyChildren = function $getLegacyChildren() {
    return getLegacyChildren(this);
  };
  app.config.globalProperties.$safeCallComponentMethod = function $safeCallComponentMethod(target, methodName, ...args) {
    return safeCallComponentMethod(target, methodName, ...args);
  };
  return app;
}

export default {
  isVuePublicInstance,
  getInternalInstance,
  unwrapVueComponentProxy,
  getComponentEl,
  resolveRef,
  resolveRefElement,
  getLegacyParent,
  getLegacyChildren,
  getLegacyRoot,
  findLegacyAncestor,
  findLegacyDescendant,
  safeCallComponentMethod,
  exposeLegacyMethods,
  normalizeLegacyInstance,
  getLegacyListeners,
  getLegacyScopedSlots,
  installLegacyInstanceCompat,
};
