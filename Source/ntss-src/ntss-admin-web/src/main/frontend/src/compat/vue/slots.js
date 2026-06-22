export function getSlotVNodes(vm, slotName = "default") {
  if (!vm?.$slots || !slotName) {
    return [];
  }

  const slot = vm.$slots[slotName];
  if (!slot) {
    return [];
  }

  const slotContent = typeof slot === "function" ? slot() : slot;
  if (!slotContent) {
    return [];
  }

  return Array.isArray(slotContent) ? slotContent : [slotContent];
}

function getVNodeChildren(vnode) {
  if (!vnode) {
    return [];
  }

  const children = [];
  if (Array.isArray(vnode.children)) {
    children.push(...vnode.children);
  }
  if (vnode.component?.subTree) {
    children.push(vnode.component.subTree);
  }
  if (Array.isArray(vnode.dynamicChildren)) {
    children.push(...vnode.dynamicChildren);
  }

  return children;
}

function resolveComponentFromVNodeQueue(queue, ownerVm = null, acceptedTypes = null) {
  while (queue.length > 0) {
    const vnode = queue.shift();
    if (!vnode) {
      continue;
    }

    const component = vnode.component;
    if (component && (!acceptedTypes || acceptedTypes.has(vnode.type))) {
      if (component.proxy && component.proxy !== ownerVm) {
        return component.proxy;
      }
      if (component.exposed) {
        return component.exposed;
      }
    }
    if (vnode.componentInstance && (!acceptedTypes || acceptedTypes.has(vnode.type))) {
      return vnode.componentInstance;
    }

    const children = getVNodeChildren(vnode);
    if (children.length > 0) {
      queue.unshift(...children);
    }
  }

  return null;
}

export function resolveSlotComponent(vm, slotName = "default") {
  const slotVNodes = getSlotVNodes(vm, slotName);
  const acceptedTypes = new Set(slotVNodes.map((vnode) => vnode?.type).filter(Boolean));
  if (acceptedTypes.size > 0) {
    const renderedComponent = resolveComponentFromVNodeQueue(
      vm?.$.subTree ? [vm.$.subTree] : [],
      vm,
      acceptedTypes
    );
    if (renderedComponent) {
      return renderedComponent;
    }
  }

  return resolveComponentFromVNodeQueue([...slotVNodes], vm);
}

export function resolveDefaultSlotComponent(vm) {
  return resolveSlotComponent(vm, "default");
}
