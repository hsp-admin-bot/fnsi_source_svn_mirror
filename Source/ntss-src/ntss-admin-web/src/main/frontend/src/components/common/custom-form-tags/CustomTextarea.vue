<template>
  <!--mod FNSI-画面部品デザイン じょはく start-->
  <textarea
    ref="textarea"
    :value="editValue"
    :class="classObject"
    @input="inputValue($event)"
    @focus="onFocus"
    @blur="onBlur"
    v-bind="forwardedAttrs"
  ></textarea>
  <!--mod FNSI-画面部品デザイン じょはく end-->
</template>

<script>
import { EventBus } from "@/compat/vue/event-bus.js";
// 共通タグ用ベースコンポーネント
import baseCustomForm from "@/components/common/custom-form-tags/BaseCustomForm";

const MIN_TEXTAREA_HEIGHT = 40;
const TEXTAREA_HEIGHT_MARGIN = 5;
const MAX_RESIZE_ITEMS_PER_FRAME = 50;
const RESIZE_STATE_KEY = "__customTextareaResizeState";

// Grid等で大量のCustomTextareaが同時表示される場合、各コンポーネントごとの
// layout計測をまとめ、1フレームあたりの処理量を抑えて初期描画の詰まりを避ける。
const textareaResizeQueue = new Map();
let textareaResizeFrameId = null;
let textareaResizeOwnerWindow = null;

function getFallbackWindow() {
  return typeof window !== "undefined" ? window : null;
}

function isTextareaElement(element) {
  return typeof HTMLTextAreaElement !== "undefined" && element instanceof HTMLTextAreaElement;
}

function resolveTextareaHeightMargin(component) {
  const margin = component?.resizeHeightMargin;
  return typeof margin === "number" ? margin : TEXTAREA_HEIGHT_MARGIN;
}

function requestTextareaResize(component, force = false) {
  if (!component || !component.isRisize) {
    return;
  }
  textareaResizeQueue.set(component, Boolean(textareaResizeQueue.get(component) || force));
  if (textareaResizeFrameId !== null) {
    return;
  }

  const ownerWindow = component.getOwnerWindow?.() || getFallbackWindow();
  const requestFrame = ownerWindow?.requestAnimationFrame?.bind(ownerWindow) || ((callback) => setTimeout(callback, 0));
  textareaResizeOwnerWindow = ownerWindow;
  textareaResizeFrameId = requestFrame(flushTextareaResizeQueue);
}

function cancelTextareaResize(component) {
  textareaResizeQueue.delete(component);
  if (textareaResizeQueue.size > 0 || textareaResizeFrameId === null) {
    return;
  }

  const ownerWindow = textareaResizeOwnerWindow || component?.getOwnerWindow?.() || getFallbackWindow();
  if (ownerWindow?.cancelAnimationFrame) {
    ownerWindow.cancelAnimationFrame(textareaResizeFrameId);
  } else {
    clearTimeout(textareaResizeFrameId);
  }
  textareaResizeFrameId = null;
  textareaResizeOwnerWindow = null;
}

function flushTextareaResizeQueue() {
  const batch = [];
  for (const entry of textareaResizeQueue.entries()) {
    batch.push(entry);
    textareaResizeQueue.delete(entry[0]);
    if (batch.length >= MAX_RESIZE_ITEMS_PER_FRAME) {
      break;
    }
  }

  textareaResizeFrameId = null;
  textareaResizeOwnerWindow = null;
  applyTextareaResizeBatch(batch);

  if (textareaResizeQueue.size > 0) {
    const nextComponent = textareaResizeQueue.keys().next().value;
    requestTextareaResize(nextComponent);
  }
}

function applyTextareaResizeBatch(batch) {
  const resizeTargets = [];

  batch.forEach(([component, force]) => {
    if (!component?.isRisize) {
      return;
    }

    const element = component.getTextareaElement?.();
    if (!element) {
      return;
    }

    const state = createResizeState(component, element);
    if ((element.clientWidth || 0) === 0) {
      component.scheduleTextareaResizeAfterLayout?.();
    }

    const previousState = element[RESIZE_STATE_KEY];
    if (!force && isSameResizeState(state, previousState)) {
      return;
    }

    resizeTargets.push({
      component,
      element,
      state,
      force
    });
  });

  if (resizeTargets.length === 0) {
    return;
  }

  resizeTargets.forEach(target => {
    target.component?.markTextareaResizeApplying?.(true);
  });

  resizeTargets.forEach(target => {
    applyTextareaHeight(target.element, target.component, undefined, target.force);
    target.component?.markTextareaResizeApplying?.(false);
  });
}

function createResizeState(component, element, valueOverride) {
  const value = valueOverride !== undefined ? valueOverride : component.editValue;
  const valueKey = value === null || value === undefined ? "" : String(value);
  const useDefaultHeight = value === null || value === undefined || value === "";
  return {
    valueKey,
    // 空欄は固定高さで足りるため、clientWidth取得を避けてlayout計測を減らす。
    width: useDefaultHeight ? 0 : (element.clientWidth || 0),
    rows: element.getAttribute("rows") || "",
    cols: element.getAttribute("cols") || "",
    defaultHeight: component.defaultHeight || `${MIN_TEXTAREA_HEIGHT}px`,
    useDefaultHeight,
    styleHeight: element.style.height
  };
}

function parseHeightPx(heightValue, fallback = MIN_TEXTAREA_HEIGHT) {
  if (!heightValue) {
    return fallback;
  }
  const parsed = parseFloat(heightValue);
  return Number.isFinite(parsed) ? parsed : fallback;
}

function measureScrollHeight(element) {
  const previousOverflow = element.style.overflow;
  const previousHeight = element.style.height;
  element.style.overflow = "hidden";
  element.style.height = "0px";
  const scrollHeight = element.scrollHeight;
  element.style.overflow = previousOverflow;
  element.style.height = previousHeight;
  return scrollHeight;
}

function resolveTextareaHeight(element, component, valueOverride) {
  const state = createResizeState(component, element, valueOverride);
  const minHeight = Math.max(
    MIN_TEXTAREA_HEIGHT,
    parseHeightPx(state.defaultHeight, MIN_TEXTAREA_HEIGHT)
  );

  if (state.useDefaultHeight) {
    return {
      state,
      nextHeight: `${minHeight}px`,
      scrollHeight: null,
      deferred: false
    };
  }

  if ((element.clientWidth || 0) === 0) {
    return {
      state,
      nextHeight: `${minHeight}px`,
      scrollHeight: null,
      deferred: true
    };
  }

  const scrollHeight = measureScrollHeight(element);
  const heightMargin = resolveTextareaHeightMargin(component);
  let calculatedHeight = Math.max(
    minHeight,
    scrollHeight < MIN_TEXTAREA_HEIGHT ? MIN_TEXTAREA_HEIGHT : scrollHeight + heightMargin
  );

  const currentHeight = element.offsetHeight;
  if (calculatedHeight < currentHeight) {
    const contentNeedsLess = scrollHeight + heightMargin < currentHeight - 1;
    if (!contentNeedsLess) {
      calculatedHeight = currentHeight;
    }
  }

  return {
    state,
    nextHeight: `${calculatedHeight}px`,
    scrollHeight,
    deferred: false
  };
}

function applyTextareaHeight(element, component, valueOverride, force = false) {
  const { state, nextHeight, scrollHeight, deferred } = resolveTextareaHeight(
    element,
    component,
    valueOverride
  );

  if (deferred) {
    component?.scheduleTextareaResizeAfterLayout?.();
    if (element.style.height !== nextHeight) {
      element.style.height = nextHeight;
    }
    element[RESIZE_STATE_KEY] = {
      ...state,
      scrollHeight,
      appliedHeight: nextHeight
    };
    return false;
  }

  const previousState = element[RESIZE_STATE_KEY];
  if (
    !force &&
    isSameResizeState(state, previousState) &&
    previousState?.appliedHeight === nextHeight
  ) {
    return false;
  }

  if (element.style.height !== nextHeight) {
    element.style.height = nextHeight;
  }

  element[RESIZE_STATE_KEY] = {
    ...state,
    scrollHeight,
    appliedHeight: nextHeight
  };
  return true;
}

function isSameResizeState(currentState, previousState) {
  return Boolean(
    previousState &&
    currentState.valueKey === previousState.valueKey &&
    currentState.width === previousState.width &&
    currentState.rows === previousState.rows &&
    currentState.cols === previousState.cols &&
    currentState.defaultHeight === previousState.defaultHeight &&
    currentState.useDefaultHeight === previousState.useDefaultHeight &&
    currentState.styleHeight === previousState.appliedHeight &&
    previousState.appliedHeight
  );
}

/**
 * @description 共通テキストエリアタグ
 */
// TODO: 初期表示時に文字列の長さでrows属性が固定されるので、例えば2行から1行になっても高さが2行分になってしまう
export default {
  inheritAttrs: false,
  mixins: [baseCustomForm],
  emits: ["blur"],
  props: {
    isRisize: {
      type: Boolean,
      default: true
    },
    resizeHeightMargin: {
      type: Number,
      default: 5
    }
  },

  computed: {
    classObject() {
      return {
        // 常に適用されるclass
        "custom-textarea": true,
        // 編集時に適用されるclass
        "custom-textarea-edited": this.isEdited,
        // 拡張無効class
        "custom-textarea-disabled-resize": true
      };
    },
    forwardedAttrs() {
      const attrs = { ...this.$attrs };
      Object.keys(attrs).forEach((key) => {
        if (this.isControlledAttrListenerKey(key)) {
          delete attrs[key];
        }
      });
      return attrs;
    }
  },
  data() {
    return {
      // 高低差
      differenceHeight: 0,
      pendingLayoutResize: false,
      lastObservedWidth: 0,
      textareaResizeObserver: null,
      isApplyingTextareaResize: false,
      skipNextEditValueResize: false
    };
  },
  watch: {
    editValue() {
      this.isValid = true;
      if (this.skipNextEditValueResize) {
        this.skipNextEditValueResize = false;
        return;
      }
      this.resizeTextarea();
    }
  },
  methods: {
    isControlledAttrListenerKey(key) {
      return ["onBlur"].includes(key);
    },
    getAttrListener(key) {
      const vnodeProps = this.$?.vnode?.props || {};
      return this.$attrs[key] ?? vnodeProps[key];
    },
    callAttrListener(key, event) {
      const listener = this.getAttrListener(key);
      if (Array.isArray(listener)) {
        listener.forEach((handler) => {
          if (typeof handler === "function") {
            handler(event);
          }
        });
      } else if (typeof listener === "function") {
        listener(event);
      }
    },
    onFocus() {
      this.resizeTextarea(true);
    },
    scheduleTextareaResizeAfterLayout() {
      if (!this.isRisize) {
        return;
      }
      if (this.pendingLayoutResize) {
        return;
      }
      this.pendingLayoutResize = true;
      this.$nextTick(() => {
        const ownerWindow = this.getOwnerWindow();
        const raf = ownerWindow?.requestAnimationFrame?.bind(ownerWindow)
          || ((callback) => setTimeout(callback, 0));
        raf(() => {
          this.pendingLayoutResize = false;
          this.resizeTextarea(true);
        });
      });
    },
    scheduleInitialResize() {
      if (!this.isRisize) {
        return;
      }
      this.scheduleTextareaResizeAfterLayout();
    },
    observeTextareaResize() {
      if (!this.isRisize || typeof ResizeObserver === "undefined") {
        return;
      }
      const element = this.getTextareaElement();
      if (!element) {
        return;
      }
      this.textareaResizeObserver = new ResizeObserver((entries) => {
        if (this.isApplyingTextareaResize) {
          return;
        }
        const width = entries[0]?.contentRect?.width || 0;
        if (width > 0 && width !== this.lastObservedWidth) {
          this.lastObservedWidth = width;
          this.resizeTextarea(true);
        }
      });
      this.textareaResizeObserver.observe(element);
    },
    unobserveTextareaResize() {
      this.textareaResizeObserver?.disconnect?.();
      this.textareaResizeObserver = null;
      this.lastObservedWidth = 0;
    },
    onBlur(event) {
      this.validate();
      this.callAttrListener("onBlur", event);
      this.$emit("blur", event);
    },
    getOwnerWindow() {
      return this.$el?.ownerDocument?.defaultView || getFallbackWindow();
    },

    getTextareaElement() {
      const textareaRef = this.$refs?.textarea;
      if (isTextareaElement(textareaRef)) {
        return textareaRef;
      }
      if (isTextareaElement(this.$el)) {
        return this.$el;
      }
      return this.$el?.querySelector?.("textarea") || null;
    },

    inputValue(event) {
      const value = event.target.value;

      // 入力直後はDOM上の値で同期計測し、非同期バッチ待ちによる高さ塌陷を防ぐ。
      if (this.isRisize) {
        this.syncTextareaHeight(event.target, value);
      }

      this.skipNextEditValueResize = true;
      this.editValue = value;
    },

    syncTextareaHeight(element, valueOverride) {
      if (!element) {
        return;
      }
      this.markTextareaResizeApplying(true);
      applyTextareaHeight(element, this, valueOverride);
      this.markTextareaResizeApplying(false);
    },

    resizeTextarea(elOrForce = false) {
      if (!this.isRisize) {
        return;
      }
      // 旧呼び出しの resizeTextarea(element) と、強制再計算の resizeTextarea(true) の両方を許容する。
      const force = elOrForce === true || isTextareaElement(elOrForce);
      requestTextareaResize(this, force);
    },
    markTextareaResizeApplying(isApplying) {
      this.isApplyingTextareaResize = isApplying;
    },
    cancelTextareaResizeFrame() {
      cancelTextareaResize(this);
    },
    onUpdateDifferenceHeight() {
      this.differenceHeight = 0;
    }
  },

  mounted() {
    this.scheduleInitialResize();
    this.$nextTick(() => {
      this.observeTextareaResize();
    });
    EventBus.$off("updateDifferenceHeight", this.onUpdateDifferenceHeight);
    EventBus.$on("updateDifferenceHeight", this.onUpdateDifferenceHeight);
  },
  // add 6119 ブラウザがOut of Memoryのエラーが発生する 史
  beforeUnmount() {
    this.unobserveTextareaResize();
    this.cancelTextareaResizeFrame();
    EventBus.$off("updateDifferenceHeight", this.onUpdateDifferenceHeight);
  }
};
</script>

<style scoped>
textarea {
  font-family: helvetica, arial, "hiragino kaku gothic pro", meiryo,
    "ms pgothic", sans-serif;
  /*mod FNSI-画面部品デザイン じょはく start*/
  /*overflow-y: auto;*/
  min-height: 40px;
  max-height: 80vh;
  /*mod FNSI-画面部品デザイン じょはく end*/
  background-color: #F7F7F7;
  padding: 5px !important;
}

.custom-textarea-edited {
  border: 2px green solid;
  outline: 0;
}

/* テキストエリア拡張禁止 */
.custom-textarea-disabled-resize {
  resize: none;
}
</style>
