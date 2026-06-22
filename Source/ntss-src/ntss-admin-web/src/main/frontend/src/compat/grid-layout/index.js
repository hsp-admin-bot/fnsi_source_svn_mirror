import { cloneVNode, defineComponent, h } from "vue";
import VueGridLayout from "@marsio/vue-grid-layout";
import "./legacy.css";

// @marsio/vue-grid-layout は GridLayout の default export のみ公開する。
// Vue2 の <grid-item> は子 vnode を展開してから GridLayout に渡す。
const RawGridLayout = VueGridLayout.default || VueGridLayout;

function mergeClassNames(...values) {
  return values
    .flatMap(value => {
      if (!value) {
        return [];
      }
      if (Array.isArray(value)) {
        return value.flatMap(item => mergeClassNames(item));
      }
      if (typeof value === "object") {
        return Object.keys(value).filter(key => value[key]);
      }
      return String(value).split(/\s+/).filter(Boolean);
    })
    .filter(Boolean);
}

function withLegacyClass(attrs, className) {
  const nextAttrs = { ...(attrs || {}) };
  nextAttrs.class = mergeClassNames(className, attrs?.class);
  return nextAttrs;
}

function isCompatGridItem(vnode) {
  const type = vnode?.type;
  return type?.name === "CompatGridItem" || type?.__name === "CompatGridItem";
}

function unwrapGridItemChildren(vnodes) {
  const result = [];

  for (const vnode of vnodes) {
    if (!vnode) {
      continue;
    }

    if (!isCompatGridItem(vnode)) {
      result.push(vnode);
      continue;
    }

    const innerSlot = vnode.children?.default;
    if (typeof innerSlot !== "function") {
      continue;
    }

    const key = vnode.key ?? vnode.props?.i;
    for (const innerVnode of innerSlot()) {
      if (!innerVnode) {
        continue;
      }
      result.push(key != null ? cloneVNode(innerVnode, { key }) : innerVnode);
    }
  }

  return result;
}

function normalizeSlots(slots) {
  const normalized = {};

  for (const name of Object.keys(slots)) {
    const slot = slots[name];
    if (!slot) {
      continue;
    }

    if (name === "default") {
      normalized.default = () => unwrapGridItemChildren(slot());
      continue;
    }

    normalized[name] = (...args) => slot(...args);
  }

  return normalized;
}

function toGridNumber(value, fallback = 0) {
  const num = Number(value);
  return Number.isFinite(num) ? num : fallback;
}

function normalizeLayoutItems(layout) {
  if (!Array.isArray(layout)) {
    return layout;
  }

  return layout.map(item => {
    if (!item) {
      return item;
    }

    return {
      ...item,
      i: item.i == null ? item.i : String(item.i),
      x: toGridNumber(item.x),
      y: toGridNumber(item.y),
      w: toGridNumber(item.w, 1),
      h: toGridNumber(item.h, 1)
    };
  });
}

function resolveGridWidth(attrs) {
  if (attrs.width != null) {
    return toGridNumber(attrs.width, undefined);
  }

  const styleWidth = attrs.style?.width;
  if (styleWidth == null) {
    return undefined;
  }

  const parsed = parseFloat(String(styleWidth));
  return Number.isFinite(parsed) ? parsed : undefined;
}

function mapGridLayoutProps(props, attrs) {
  const next = { ...(attrs || {}) };
  const layout = props.layout ?? next.layout ?? next.modelValue;

  if (layout !== undefined) {
    next.modelValue = normalizeLayoutItems(layout);
    delete next.layout;
  }

  const colNum = props.colNum ?? next.colNum ?? next["col-num"];
  if (colNum != null) {
    next.cols = colNum;
    delete next.colNum;
    delete next["col-num"];
  }

  const width = props.width ?? resolveGridWidth(next);
  if (width != null) {
    next.width = width;
  }

  const draggableCancel =
    props.draggableCancel ?? next.draggableCancel ?? next["draggable-cancel"];
  if (draggableCancel != null) {
    next.draggableCancel = draggableCancel;
    delete next["draggable-cancel"];
  }

  const rowHeight = props.rowHeight ?? next.rowHeight ?? next["row-height"];
  if (rowHeight != null) {
    next.rowHeight = rowHeight;
    delete next["row-height"];
  }

  const isDraggable = props.isDraggable ?? next.isDraggable ?? next["is-draggable"];
  if (isDraggable != null) {
    next.isDraggable = isDraggable;
    delete next["is-draggable"];
  }

  const isResizable = props.isResizable ?? next.isResizable ?? next["is-resizable"];
  if (isResizable != null) {
    next.isResizable = isResizable;
    delete next["is-resizable"];
  }

  const verticalCompact =
    props.verticalCompact ?? next.verticalCompact ?? next["vertical-compact"];
  if (verticalCompact != null) {
    next.verticalCompact = verticalCompact;
    delete next["vertical-compact"];
  }

  const useCSSTransforms =
    props.useCSSTransforms ??
    next.useCSSTransforms ??
    next.useCssTransforms ??
    next["use-css-transforms"];
  if (useCSSTransforms != null) {
    next.useCSSTransforms = useCSSTransforms;
    delete next.useCssTransforms;
    delete next["use-css-transforms"];
  }

  delete next.isMirrored;

  return withLegacyClass(next, "vue-grid-layout");
}

export const GridLayout = defineComponent({
  name: "CompatGridLayout",
  inheritAttrs: false,
  props: {
    layout: {
      type: Array,
      default: undefined
    },
    colNum: {
      type: Number,
      default: undefined
    },
    width: {
      type: Number,
      default: undefined
    }
  },
  emits: ["update:layout"],
  setup(props, { attrs, slots, emit }) {
    return () =>
      h(
        RawGridLayout,
        {
          ...mapGridLayoutProps(props, attrs),
          "onUpdate:modelValue": value => emit("update:layout", value)
        },
        normalizeSlots(slots)
      );
  }
});

// テンプレート互換用。実際の描画は GridLayout 側で子 vnode を展開する。
export const GridItem = defineComponent({
  name: "CompatGridItem",
  inheritAttrs: false,
  props: {
    i: {},
    x: {},
    y: {},
    w: {},
    h: {},
    minW: {},
    minH: {},
    maxW: {},
    maxH: {}
  },
  setup(_props, { slots }) {
    return () => slots.default?.() ?? null;
  }
});

export default GridLayout;
