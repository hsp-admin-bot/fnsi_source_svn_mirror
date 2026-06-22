import { cloneVNode, Fragment, h, nextTick, onBeforeUnmount, onMounted, onUpdated, ref } from "vue";
import Sortable from "sortablejs";

const legacyDraggableItemKeys = new WeakMap();
const legacyDraggableDomItems = new WeakMap();
const legacyDraggableRootItems = new WeakMap();
let legacyDraggableItemKeySeed = 0;

const SORTABLE_OPTION_KEYS = new Set([
  "group",
  "sort",
  "disabled",
  "animation",
  "easing",
  "handle",
  "filter",
  "preventOnFilter",
  "draggable",
  "ghostClass",
  "chosenClass",
  "dragClass",
  "dataIdAttr",
  "delay",
  "delayOnTouchOnly",
  "touchStartThreshold",
  "forceFallback",
  "fallbackClass",
  "fallbackOnBody",
  "fallbackTolerance",
  "fallbackOffset",
  "swapThreshold",
  "invertSwap",
  "invertedSwapThreshold",
  "direction",
  "scroll",
  "scrollSensitivity",
  "scrollSpeed",
  "bubbleScroll",
  "removeCloneOnHide",
  "emptyInsertThreshold"
]);

const RESERVED_ATTR_KEYS = new Set([
  "modelValue",
  "list",
  "value",
  "options",
  "itemKey",
  "item-key",
  "tag",
  "element",
  "move",
  "clone",
  "v-model",
  "onUpdate:modelValue"
]);

function toCamelCase(key) {
  return String(key).replace(/-([a-z])/g, (_match, char) => char.toUpperCase());
}

function getLegacyDraggableItemKey(item) {
  if (item && (typeof item === "object" || typeof item === "function")) {
    if (!legacyDraggableItemKeys.has(item)) {
      legacyDraggableItemKeySeed += 1;
      legacyDraggableItemKeys.set(item, `ntss-draggable-${legacyDraggableItemKeySeed}`);
    }
    return legacyDraggableItemKeys.get(item);
  }
  return `${typeof item}:${String(item)}`;
}

function isListenerAttr(key, value) {
  return /^on[A-Z]/.test(String(key)) && typeof value === "function";
}

function getDomAttrs(attrs) {
  return Object.entries(attrs || {}).reduce((result, [key, value]) => {
    const optionKey = toCamelCase(key);
    if (
      RESERVED_ATTR_KEYS.has(key)
      || SORTABLE_OPTION_KEYS.has(optionKey)
      || isListenerAttr(key, value)
    ) {
      return result;
    }
    result[key] = value;
    return result;
  }, {});
}

function getSortableOptions(props, attrs) {
  const options = {
    ...(props.options || {})
  };

  Object.entries(attrs || {}).forEach(([key, value]) => {
    const optionKey = toCamelCase(key);
    if (SORTABLE_OPTION_KEYS.has(optionKey)) {
      options[optionKey] = value;
    }
  });

  if (props.disabled !== undefined) {
    options.disabled = props.disabled;
  }

  return options;
}

function hasOwnValue(value) {
  return value !== undefined && value !== null;
}

function hasSameOrder(left, right) {
  return Array.isArray(left)
    && Array.isArray(right)
    && left.length === right.length
    && left.every((item, index) => item === right[index]);
}

function getSortableIndex(event, keyPrefix) {
  const draggableIndex = event?.[`${keyPrefix}DraggableIndex`];
  if (Number.isInteger(draggableIndex)) {
    return draggableIndex;
  }
  const index = event?.[`${keyPrefix}Index`];
  return Number.isInteger(index) ? index : -1;
}

function getLegacyDomClasses(attrs) {
  const result = [];
  const classAttr = attrs?.class;
  if (Array.isArray(classAttr)) {
    result.push(...classAttr);
  } else if (classAttr) {
    result.push(classAttr);
  }
  result.push("ntss-vuedraggable-legacy");
  return result;
}

const VueDraggable = {
  name: "draggable",
  inheritAttrs: false,
  props: {
    modelValue: {
      type: Array,
      default: undefined
    },
    list: {
      type: Array,
      default: undefined
    },
    value: {
      type: Array,
      default: undefined
    },
    options: {
      type: Object,
      default: undefined
    },
    itemKey: {
      type: [String, Function],
      default: getLegacyDraggableItemKey
    },
    tag: {
      type: String,
      default: undefined
    },
    element: {
      type: String,
      default: undefined
    },
    disabled: {
      type: Boolean,
      default: undefined
    },
    move: {
      type: Function,
      default: undefined
    },
    clone: {
      type: Function,
      default: undefined
    }
  },
  emits: [
    "update:modelValue",
    "input",
    "change",
    "update",
    "start",
    "end",
    "choose",
    "unchoose",
    "add",
    "remove",
    "sort",
    "filter",
    "clone"
  ],
  setup(props, { attrs, emit, slots }) {
    const root = ref(null);
    let sortable = null;
    let didUpdateModelDuringDrag = false;

    const getList = () => {
      if (Array.isArray(props.list)) {
        return props.list;
      }
      if (Array.isArray(props.modelValue)) {
        return props.modelValue;
      }
      if (Array.isArray(props.value)) {
        return props.value;
      }
      if (Array.isArray(attrs["v-model"])) {
        return attrs["v-model"];
      }
      return [];
    };

    const emitSortableEvent = (name, event) => {
      emit(name, event);
    };

    const replaceList = (nextList) => {
      if (Array.isArray(props.list)) {
        props.list.splice(0, props.list.length, ...nextList);
        return;
      }
      if (Array.isArray(props.modelValue)) {
        emit("update:modelValue", nextList);
        emit("input", nextList);
        return;
      }
      if (Array.isArray(props.value)) {
        emit("input", nextList);
      }
    };

    const replaceListIfChanged = (nextList) => {
      const list = getList();
      if (!Array.isArray(list) || !Array.isArray(nextList) || hasSameOrder(list, nextList)) {
        return false;
      }
      replaceList(nextList);
      return true;
    };

    const spliceList = (start, deleteCount, ...items) => {
      const list = getList();
      if (!Array.isArray(list)) {
        return [];
      }
      const nextList = list.slice();
      const removed = nextList.splice(start, deleteCount, ...items);
      replaceList(nextList);
      return removed;
    };

    const getRootChild = (element) => {
      let current = element;
      while (current && root.value && current.parentElement !== root.value) {
        current = current.parentElement;
      }
      return current && current.parentElement === root.value ? current : null;
    };

    const getChildIndex = (element) => {
      const rootChild = getRootChild(element);
      if (!rootChild || !root.value) {
        return -1;
      }
      return Array.from(root.value.children).indexOf(rootChild);
    };

    const createLegacyContext = (index) => {
      const list = getList();
      const normalizedIndex = Number.isInteger(index) && index >= 0 ? index : null;
      return {
        index: normalizedIndex,
        element: normalizedIndex !== null ? list?.[normalizedIndex] : null,
        list,
        component: null
      };
    };

    const createLegacyMoveEvent = (event, originalEvent) => {
      const draggedIndex = getSortableIndex(event, "old") >= 0
        ? getSortableIndex(event, "old")
        : getChildIndex(event?.dragged);
      const relatedIndex = getChildIndex(event?.related);

      return {
        ...event,
        originalEvent,
        draggedContext: createLegacyContext(draggedIndex),
        relatedContext: createLegacyContext(relatedIndex)
      };
    };

    const enrichSortableEvent = (event) => ({
      ...event,
      draggedContext: event?.item ? createLegacyContext(getSortableIndex(event, "old")) : undefined,
      relatedContext: event?.related ? createLegacyContext(getChildIndex(event.related)) : undefined
    });

    const rememberDraggedElement = (event) => {
      const list = getList();
      const oldIndex = getSortableIndex(event, "old");
      const element = oldIndex >= 0 ? list[oldIndex] : undefined;
      if (event?.item && hasOwnValue(element)) {
        legacyDraggableDomItems.set(event.item, {
          element,
          clonedElement: typeof props.clone === "function" ? props.clone(element) : element,
          oldIndex,
          list
        });
      }
      if (event?.clone && event?.item && legacyDraggableDomItems.has(event.item)) {
        legacyDraggableDomItems.set(event.clone, legacyDraggableDomItems.get(event.item));
      }
      return element;
    };

    const rememberRootDomItems = () => {
      const list = getList();
      if (!root.value || !Array.isArray(list)) {
        return;
      }
      Array.from(root.value.children).forEach((child, index) => {
        if (index < list.length) {
          legacyDraggableRootItems.set(child, list[index]);
        }
      });
    };

    const createListFromDomOrder = () => {
      const list = getList();
      if (!root.value || !Array.isArray(list) || list.length === 0) {
        return null;
      }
      const nextList = Array.from(root.value.children).map((child) => (
        legacyDraggableRootItems.get(child)
      ));
      if (nextList.length !== list.length || nextList.some((item) => !hasOwnValue(item))) {
        return null;
      }
      return nextList;
    };

    const getAddedElement = (event) => {
      const remembered = event?.item ? legacyDraggableDomItems.get(event.item) : null;
      if (!remembered) {
        return undefined;
      }
      return event?.pullMode === "clone" ? remembered.clonedElement : remembered.element;
    };

    const updateModel = (event) => {
      const list = getList();
      if (!Array.isArray(list)) {
        return false;
      }

      const oldIndex = getSortableIndex(event, "old");
      const newIndex = getSortableIndex(event, "new");
      if (
        oldIndex === undefined
        || newIndex === undefined
        || oldIndex === newIndex
        || oldIndex < 0
        || newIndex < 0
        || oldIndex >= list.length
      ) {
        return false;
      }

      const nextList = list.slice();
      const [element] = nextList.splice(oldIndex, 1);
      nextList.splice(newIndex, 0, element);
      if (!replaceListIfChanged(nextList)) {
        return false;
      }

      emit("change", {
        moved: {
          element,
          oldIndex,
          newIndex
        }
      });
      return true;
    };

    const syncModelByDomOrder = (event) => {
      const nextList = createListFromDomOrder();
      if (!replaceListIfChanged(nextList)) {
        return false;
      }

      const oldIndex = getSortableIndex(event, "old");
      const newIndex = getSortableIndex(event, "new");
      const element = event?.item
        ? legacyDraggableRootItems.get(event.item)
        : nextList?.[newIndex];
      if (hasOwnValue(element)) {
        emit("change", {
          moved: {
            element,
            oldIndex,
            newIndex
          }
        });
      }
      return true;
    };

    const addModel = (event) => {
      const newIndex = getSortableIndex(event, "new");
      const element = getAddedElement(event);
      if (newIndex < 0 || !hasOwnValue(element)) {
        return false;
      }
      spliceList(newIndex, 0, element);
      emit("change", {
        added: {
          element,
          newIndex
        }
      });
      return true;
    };

    const removeModel = (event) => {
      if (event?.pullMode === "clone") {
        return false;
      }
      const oldIndex = getSortableIndex(event, "old");
      if (oldIndex < 0) {
        return false;
      }
      const [element] = spliceList(oldIndex, 1);
      if (!hasOwnValue(element)) {
        return false;
      }
      emit("change", {
        removed: {
          element,
          oldIndex
        }
      });
      return true;
    };

    const getChildVNodeKey = (item) => {
      if (typeof props.itemKey === "function") {
        return props.itemKey(item);
      }
      if (item && typeof item === "object" && hasOwnValue(item[props.itemKey])) {
        return item[props.itemKey];
      }
      return getLegacyDraggableItemKey(item);
    };

    const flattenSlotChildren = (children) => children.flatMap((child) => (
      child?.type === Fragment && Array.isArray(child.children)
        ? flattenSlotChildren(child.children)
        : [child]
    ));

    const renderSlotChildren = () => {
      const children = flattenSlotChildren(slots.default ? slots.default() : []);
      const list = getList();
      if (!Array.isArray(list) || list.length === 0) {
        return children;
      }

      let itemIndex = 0;
      return children.map((child) => {
        if (!child || typeof child !== "object" || itemIndex >= list.length) {
          return child;
        }
        const item = list[itemIndex];
        itemIndex += 1;
        return cloneVNode(child, { key: getChildVNodeKey(item) });
      });
    };

    const createSortableOptions = () => {
      const sortableOptions = getSortableOptions(props, attrs);
      return {
        ...sortableOptions,
        onMove: props.move
          ? (event, originalEvent) => props.move(createLegacyMoveEvent(event, originalEvent), originalEvent)
          : sortableOptions.onMove,
        onChoose: (event) => {
          sortableOptions.onChoose?.(event);
          emitSortableEvent("choose", enrichSortableEvent(event));
        },
        onStart: (event) => {
          didUpdateModelDuringDrag = false;
          rememberRootDomItems();
          rememberDraggedElement(event);
          sortableOptions.onStart?.(event);
          emitSortableEvent("start", enrichSortableEvent(event));
        },
        onUpdate: (event) => {
          sortableOptions.onUpdate?.(event);
          didUpdateModelDuringDrag = updateModel(event) || didUpdateModelDuringDrag;
          emitSortableEvent("update", enrichSortableEvent(event));
        },
        onAdd: (event) => {
          sortableOptions.onAdd?.(event);
          didUpdateModelDuringDrag = addModel(event) || didUpdateModelDuringDrag;
          emitSortableEvent("add", enrichSortableEvent(event));
        },
        onRemove: (event) => {
          sortableOptions.onRemove?.(event);
          didUpdateModelDuringDrag = removeModel(event) || didUpdateModelDuringDrag;
          emitSortableEvent("remove", enrichSortableEvent(event));
        },
        onSort: (event) => {
          sortableOptions.onSort?.(event);
          emitSortableEvent("sort", enrichSortableEvent(event));
        },
        onEnd: (event) => {
          sortableOptions.onEnd?.(event);
          if (!didUpdateModelDuringDrag) {
            didUpdateModelDuringDrag = syncModelByDomOrder(event) || updateModel(event);
          }
          emitSortableEvent("end", enrichSortableEvent(event));
        },
        onUnchoose: (event) => {
          sortableOptions.onUnchoose?.(event);
          emitSortableEvent("unchoose", enrichSortableEvent(event));
        },
        onFilter: (event) => {
          sortableOptions.onFilter?.(event);
          emitSortableEvent("filter", enrichSortableEvent(event));
        },
        onClone: (event) => {
          if (event?.clone && event?.item && legacyDraggableDomItems.has(event.item)) {
            legacyDraggableDomItems.set(event.clone, legacyDraggableDomItems.get(event.item));
          }
          sortableOptions.onClone?.(event);
          emitSortableEvent("clone", enrichSortableEvent(event));
        }
      };
    };

    const syncSortableOptions = () => {
      if (!sortable) {
        return;
      }
      const options = getSortableOptions(props, attrs);
      Object.keys(options).forEach((key) => sortable.option(key, options[key]));
    };

    onMounted(() => {
      nextTick(() => {
        if (!root.value || sortable) {
          return;
        }
        sortable = Sortable.create(root.value, createSortableOptions());
      });
    });

    onBeforeUnmount(() => {
      sortable?.destroy?.();
      sortable = null;
    });

    onUpdated(() => {
      nextTick(syncSortableOptions);
    });

    return () => h(
      props.tag || props.element || "div",
      {
        ...getDomAttrs(attrs),
        class: getLegacyDomClasses(attrs),
        ref: root
      },
      renderSlotChildren()
    );
  }
};

// vuedraggable 2 系から 4 系への差異はこの入口で吸収します。
// 画面側は Vue2 相当の入口を使い続けます。
export { VueDraggable };
export default VueDraggable;
