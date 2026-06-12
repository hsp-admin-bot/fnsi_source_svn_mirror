function hasKey(vm, key) {
  if (!vm || !key) return false;
  try {
    if (key in vm) return true;
    if (vm.$data && key in vm.$data) return true;
    if (vm.$props && key in vm.$props) return true;
    if (vm.$refs && key in vm.$refs) return true;
  } catch (e) {
    return false;
  }
  return false;
}

function hasMethod(vm, methodName) {
  if (!vm || !methodName) {
    return false;
  }
  try {
    return typeof vm[methodName] === "function";
  } catch (e) {
    return false;
  }
}

export function getComponentParent(vm) {
  try {
    return vm?.["$" + "parent"] || vm?.$?.parent?.proxy || vm?.$?.parent?.ctx || null;
  } catch (e) {
    return null;
  }
}

export function findAncestorComponent(vm, matcher, options = {}) {
  const { includeSelf = false, maxDepth = 24 } = options;
  let current = includeSelf ? vm : getComponentParent(vm);
  let depth = 0;
  while (current && depth < maxDepth) {
    if (matcher(current)) {
      return current;
    }
    current = getComponentParent(current);
    depth += 1;
  }
  return null;
}

export function findAncestorWithAllKeys(vm, keys, options = {}) {
  return findAncestorComponent(vm, target => Array.isArray(keys) && keys.every(key => hasKey(target, key)), options);
}

export function findAncestorWithAnyKey(vm, keys, options = {}) {
  return findAncestorComponent(vm, target => Array.isArray(keys) && keys.some(key => hasKey(target, key)), options);
}

export function findAncestorWithMethod(vm, methods, options = {}) {
  return findAncestorComponent(vm, target => Array.isArray(methods) && methods.every(methodName => hasMethod(target, methodName)), options);
}

export function findAncestorWithRef(vm, refName, options = {}) {
  return findAncestorComponent(vm, target => !!target?.$refs?.[refName], options);
}
