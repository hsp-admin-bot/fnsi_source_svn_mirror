<template>
  <div v-show="isRenderable" class="vue-touch-keyboard">
    <div ref="keyboardRoot" class="keyboard"></div>
  </div>
</template>

<script>
import SimpleKeyboardModule from "simple-keyboard";
import "simple-keyboard/build/css/index.css";
import { resolveElement, resolveOwnerDocument } from "@/compat/dom/host";

function resolveKeyboardConstructor(candidate) {
  let current = candidate;
  for (let index = 0; index < 4; index++) {
    if (typeof current === "function") {
      return current;
    }
    current = current?.default || current?.Keyboard;
  }
  return null;
}

const DEFAULT_LAYOUT = {
  default: ["7 8 9", "4 5 6", "1 2 3", "0 ."]
};

function normalizeButtonName(name) {
  if (!name) {
    return "";
  }
  return name.startsWith("{") ? name : `{${name}}`;
}

function normalizeClassTokens(rawClasses) {
  if (!rawClasses) {
    return [];
  }
  if (Array.isArray(rawClasses)) {
    return rawClasses.filter(Boolean).map(value => String(value).trim()).filter(Boolean);
  }
  return String(rawClasses)
    .split(/\s+/)
    .map(value => value.trim())
    .filter(Boolean);
}

function getButtonLabel(buttonName, metaEntry) {
  if (metaEntry?.text !== undefined && metaEntry?.text !== null) {
    return String(metaEntry.text);
  }
  // Vue2 vue-touch-keyboard used meta.key as the display label too, e.g.
  // meta = { zero: { key: "0" } } renders as "0" instead of falling back to
  // "zero" stripped from "{zero}".
  if (metaEntry?.key !== undefined && metaEntry?.key !== null) {
    return String(metaEntry.key);
  }
  if (buttonName === "{backspace}" || buttonName === "{bksp}") {
    return "";
  }
  if (buttonName === "{placeholder}") {
    return "";
  }
  return buttonName.replace(/^\{/, "").replace(/\}$/, "");
}

function createButtonModel(rawToken, metaSource) {
  const token = String(rawToken || "").trim();
  if (!token) {
    return null;
  }

  const isNamedButton = token.startsWith("{") && token.endsWith("}");
  const rawName = isNamedButton ? token.slice(1, -1) : token;
  // Keep plain keys as plain text (e.g. "7"), only keep braces for named keys.
  // Wrapping plain keys as "{7}" makes simple-keyboard treat them as function keys.
  const normalizedName = isNamedButton ? token : token;
  const metaEntry = metaSource?.[rawName] || metaSource?.[normalizeButtonName(rawName)] || null;
  const classTokens = ["key", ...normalizeClassTokens(metaEntry?.classes)];

  return {
    key: normalizedName,
    label: getButtonLabel(normalizedName, metaEntry),
    meta: metaEntry,
    classes: classTokens.join(" ")
  };
}

function normalizeRows(layout) {
  const rows = Array.isArray(layout?.default) && layout.default.length > 0
    ? layout.default
    : DEFAULT_LAYOUT.default;
  const metaSource = layout?._meta || {};

  return rows.map(row => {
    const tokens = String(row || "").split(/\s+/).filter(Boolean);
    return tokens
      .map(token => createButtonModel(token, metaSource))
      .filter(Boolean);
  });
}

function toSimpleKeyboardLayout(rows) {
  return {
    default: rows.map(row => row.map(button => button.key).join(" "))
  };
}

function toSimpleKeyboardDisplay(rows) {
  return rows.flat().reduce((display, button) => {
    display[button.key] = button.label;
    return display;
  }, {});
}

function toSimpleKeyboardButtonTheme(rows) {
  return rows.flat()
    .filter(button => button.classes)
    .map(button => ({
      class: button.classes,
      buttons: button.key
    }));
}

export default {
  name: "TouchKeyboard",
  props: {
    options: {
      type: Object,
      default: () => ({})
    },
    layout: {
      type: Object,
      default: () => null
    },
    cancel: {
      type: Function,
      default: null
    },
    accept: {
      type: Function,
      default: null
    },
    input: {
      type: Object,
      default: null
    },
    visible: {
      type: Boolean,
      default: true
    },
    next: {
      type: Function,
      default: null
    },
    change: {
      type: Function,
      default: null
    }
  },
  data() {
    return {
      keyboard: null
    };
  },
  computed: {
    normalizedRows() {
      return normalizeRows(this.layout);
    },
    isRenderable() {
      return this.visible !== false;
    }
  },
  watch: {
    layout: {
      deep: true,
      handler() {
        this.refreshKeyboardOptions();
      }
    },
    options: {
      deep: true,
      handler() {
        this.refreshKeyboardOptions();
      }
    },
    input() {
      this.syncKeyboardInput();
    },
    visible() {
      this.$nextTick(() => this.refreshKeyboardOptions());
    }
  },
  mounted() {
    this.mountKeyboard();
  },
  beforeUnmount() {
    this.destroyKeyboard();
  },
  methods: {
    getTargetInput() {
      const input = resolveElement(this.input);
      const ownerWindow = resolveOwnerDocument(input)?.defaultView || globalThis.window || null;
      if (!input || !ownerWindow) {
        return null;
      }
      return input instanceof ownerWindow.HTMLInputElement || input instanceof ownerWindow.HTMLTextAreaElement
        ? input
        : null;
    },
    emitInputEvent(targetInput) {
      const ownerWindow = resolveOwnerDocument(targetInput)?.defaultView || globalThis.window || null;
      const InputEventCtor = ownerWindow?.InputEvent || ownerWindow?.Event || globalThis.Event;
      if (InputEventCtor) {
        try {
          targetInput.dispatchEvent(new InputEventCtor("input", { bubbles: true, inputType: "insertText" }));
        } catch (_error) {
          targetInput.dispatchEvent(new InputEventCtor("input", { bubbles: true }));
        }
      }
      if (typeof this.change === "function") {
        this.change();
      }
    },
    syncKeyboardInput() {
      const targetInput = this.getTargetInput();
      this.keyboard?.setInput?.(String(targetInput?.value ?? ""));
    },
    focusTargetInput(targetInput) {
      try {
        targetInput?.focus?.();
      } catch (_error) {
        // The legacy keyboard ignored focus failures caused by hidden or detached inputs.
      }
    },
    setTargetSelectionRange(targetInput, start, end = start) {
      try {
        targetInput?.setSelectionRange?.(start, end);
      } catch (_error) {
        // Non-text inputs can reject selection APIs; keep Vue2-era keyboard flow alive.
      }
    },
    findButton(buttonName) {
      return this.normalizedRows.flat().find(button => button.key === buttonName)
        || createButtonModel(buttonName, this.layout?._meta || {});
    },
    createKeyboardOptions() {
      const rows = this.normalizedRows;
      const userOptions = { ...(this.options || {}) };
      const userOnKeyPress = userOptions.onKeyPress;
      const userOnRender = userOptions.onRender;
      return {
        ...userOptions,
        layout: toSimpleKeyboardLayout(rows),
        display: toSimpleKeyboardDisplay(rows),
        buttonTheme: toSimpleKeyboardButtonTheme(rows),
        onKeyPress: (buttonName) => {
          this.handleKeyPress(buttonName);
          if (typeof userOnKeyPress === "function") {
            userOnKeyPress(buttonName);
          }
        },
        onRender: () => {
          this.applyLegacyKeyboardClasses();
          if (typeof userOnRender === "function") {
            userOnRender();
          }
        },
        preventMouseDownDefault: userOptions.preventMouseDownDefault ?? true,
        physicalKeyboardHighlight: userOptions.physicalKeyboardHighlight ?? false
      };
    },
    applyLegacyKeyboardClasses() {
      const root = resolveElement(this.$refs.keyboardRoot);
      if (!root) {
        return;
      }
      root.querySelectorAll?.(".hg-row").forEach(row => row.classList.add("line"));
      root.querySelectorAll?.(".hg-button").forEach(button => button.classList.add("key"));
      root.querySelectorAll?.(".hg-button-bksp, .hg-button-backspace").forEach(button => {
        button.classList.add("key", "backspace", "control");
        const label = button.querySelector(":scope > span");
        if (label) {
          label.classList.add("backspace");
          label.textContent = "";
        }
      });
      root.querySelectorAll?.(".hg-button-placeholder").forEach(button => {
        button.classList.add("placeholder");
        button.setAttribute("aria-hidden", "true");
      });
    },
    destroyKeyboard() {
      this.keyboard?.destroy?.();
      this.keyboard = null;
    },
    mountKeyboard() {
      const root = resolveElement(this.$refs.keyboardRoot);
      if (!root) {
        return;
      }
      const KeyboardConstructor = resolveKeyboardConstructor(SimpleKeyboardModule);
      if (!KeyboardConstructor) {
        return;
      }
      this.destroyKeyboard();
      this.keyboard = new KeyboardConstructor(root, this.createKeyboardOptions());
      this.syncKeyboardInput();
      this.$nextTick(() => this.applyLegacyKeyboardClasses());
    },
    refreshKeyboardOptions() {
      if (!this.keyboard) {
        this.mountKeyboard();
        return;
      }
      this.keyboard.setOptions(this.createKeyboardOptions());
      this.syncKeyboardInput();
      this.$nextTick(() => this.applyLegacyKeyboardClasses());
    },
    replaceSelection(insertText) {
      const targetInput = this.getTargetInput();
      if (!targetInput) {
        return;
      }

      const currentValue = String(targetInput.value ?? "");
      const selectionStart = targetInput.selectionStart ?? currentValue.length;
      const selectionEnd = targetInput.selectionEnd ?? selectionStart;
      const nextValue = `${currentValue.slice(0, selectionStart)}${insertText}${currentValue.slice(selectionEnd)}`;
      const nextCaret = selectionStart + insertText.length;

      targetInput.value = nextValue;
      this.focusTargetInput(targetInput);
      this.setTargetSelectionRange(targetInput, nextCaret, nextCaret);
      this.keyboard?.setInput?.(nextValue);
      this.emitInputEvent(targetInput);
    },
    deleteSelection() {
      const targetInput = this.getTargetInput();
      if (!targetInput) {
        return;
      }

      const currentValue = String(targetInput.value ?? "");
      const selectionStart = targetInput.selectionStart ?? currentValue.length;
      const selectionEnd = targetInput.selectionEnd ?? selectionStart;

      if (selectionStart === 0 && selectionEnd === 0) {
        return;
      }

      let nextValue;
      let nextCaret = selectionStart;

      if (selectionStart !== selectionEnd) {
        nextValue = `${currentValue.slice(0, selectionStart)}${currentValue.slice(selectionEnd)}`;
      } else {
        nextValue = `${currentValue.slice(0, selectionStart - 1)}${currentValue.slice(selectionStart)}`;
        nextCaret = selectionStart - 1;
      }

      targetInput.value = nextValue;
      this.focusTargetInput(targetInput);
      this.setTargetSelectionRange(targetInput, nextCaret, nextCaret);
      this.keyboard?.setInput?.(nextValue);
      this.emitInputEvent(targetInput);
    },
    runFunction(funcName) {
      const functionMap = {
        accept: this.accept,
        cancel: this.cancel,
        next: this.next
      };
      const callback = functionMap[funcName];
      if (typeof callback === "function") {
        callback();
      }
    },
    handleKeyPress(buttonName) {
      if (!this.isRenderable) {
        return;
      }

      const targetInput = this.getTargetInput();
      if (!targetInput) {
        return;
      }

      const button = this.findButton(buttonName);
      const metaEntry = button?.meta || null;

      if (metaEntry?.func) {
        if (metaEntry.func === "backspace") {
          this.deleteSelection();
          return;
        }
        this.runFunction(metaEntry.func);
        return;
      }

      if (buttonName === "{backspace}" || buttonName === "{bksp}") {
        this.deleteSelection();
        return;
      }

      if (buttonName === "{placeholder}") {
        return;
      }

      if (metaEntry?.key !== undefined) {
        this.replaceSelection(String(metaEntry.key));
        return;
      }

      if (buttonName.startsWith("{") && buttonName.endsWith("}")) {
        return;
      }

      this.replaceSelection(buttonName);
    }
  }
};
</script>

<style>
.vue-touch-keyboard .keyboard,
.vue-touch-keyboard .simple-keyboard {
  width: 12em;
  margin: 0px;
  background-color: #666666;
  padding: 0.5em;
  position: relative;
}

.vue-touch-keyboard .keyboard .hg-row {
  display: flex;
  justify-content: space-around;
}

.vue-touch-keyboard .keyboard .line {
  display: flex;
  justify-content: space-around;
}

.vue-touch-keyboard .keyboard .hg-row:not(:last-child),
.vue-touch-keyboard .keyboard .line:not(:last-child) {
  margin-bottom: .5em;
}

/* simple-keyboard: .hg-standardBtn{width:20px} etc.; align flex basis so row distribution is stable. */
.vue-touch-keyboard .keyboard.hg-theme-default .hg-button.key,
.vue-touch-keyboard .keyboard.hg-theme-default .key {
  flex: 40 1 0%;
  min-width: 0;
  width: auto !important;
  max-width: none !important;
  height: 2.2em;
  line-height: 2.2em;
  overflow: hidden;
  vertical-align: middle;
  border: 1px solid #ccc;
  color: #333;
  background-color: #fff;
  box-shadow: 0 2px 2px rgba(0, 0, 0, .6);
  border-radius: .35em;
  font-size: 1.3em;
  text-align: center;
  white-space: nowrap;
  user-select: none;
  cursor: pointer;
}

.vue-touch-keyboard .keyboard .hg-button.key:not(:last-child),
.vue-touch-keyboard .keyboard .key:not(:last-child) {
  margin-right: .5em;
}

.vue-touch-keyboard .keyboard .hg-button.key.backspace,
.vue-touch-keyboard .keyboard .key.backspace {
  background-image: url(data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIGhlaWdodD0iNDgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgd2lkdGg9IjQ4Ij48cGF0aCBkPSJNMCAwaDQ4djQ4aC00OHoiIGZpbGw9Im5vbmUiLz48cGF0aCBkPSJNNDQgNmgtMzBjLTEuMzggMC0yLjQ3LjctMy4xOSAxLjc2bC0xMC44MSAxNi4yMyAxMC44MSAxNi4yM2MuNzIgMS4wNiAxLjgxIDEuNzggMy4xOSAxLjc4aDMwYzIuMjEgMCA0LTEuNzkgNC00di0yOGMwLTIuMjEtMS43OS00LTQtNHptLTYgMjUuMTdsLTIuODMgMi44My03LjE3LTcuMTctNy4xNyA3LjE3LTIuODMtMi44MyA3LjE3LTcuMTctNy4xNy03LjE3IDIuODMtMi44MyA3LjE3IDcuMTcgNy4xNy03LjE3IDIuODMgMi44My03LjE3IDcuMTcgNy4xNyA3LjE3eiIgZmlsbD0id2hpdGUiLz48L3N2Zz4=);
  background-position: 50%;
  background-repeat: no-repeat;
  background-size: 35%;
}

.vue-touch-keyboard .keyboard .hg-button.key span.backspace,
.vue-touch-keyboard .keyboard .key span.backspace {
  /* simple-keyboard uses display:flex + align-items:center on .hg-button; an empty
     span otherwise stays minimal and the background paints in a near-zero box. */
  display: block;
  flex: 1 1 auto;
  align-self: stretch;
  width: 100%;
  min-width: 0;
  min-height: 0;
  margin: 0;
  padding: 0;
  line-height: inherit;
  /* SVG must use xmlns="http://www.w3.org/2000/svg"; old asset used http://www.w3.org and did not paint in data URLs. */
  background-image: url(data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIGhlaWdodD0iNDgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgd2lkdGg9IjQ4Ij48cGF0aCBkPSJNMCAwaDQ4djQ4aC00OHoiIGZpbGw9Im5vbmUiLz48cGF0aCBkPSJNNDQgNmgtMzBjLTEuMzggMC0yLjQ3LjctMy4xOSAxLjc2bC0xMC44MSAxNi4yMyAxMC44MSAxNi4yM2MuNzIgMS4wNiAxLjgxIDEuNzggMy4xOSAxLjc4aDMwYzIuMjEgMCA0LTEuNzkgNC00di0yOGMwLTIuMjEtMS43OS00LTQtNHptLTYgMjUuMTdsLTIuODMgMi44My03LjE3LTcuMTctNy4xNyA3LjE3LTIuODMtMi44MyA3LjE3LTcuMTctNy4xNy03LjE3IDIuODMtMi44MyA3LjE3IDcuMTcgNy4xNy03LjE3IDIuODMgMi44My03LjE3IDcuMTcgNy4xNyA3LjE3eiIgZmlsbD0id2hpdGUiLz48L3N2Zz4=);
  background-position: 50%;
  background-repeat: no-repeat;
  background-size: 35%;
}

.vue-touch-keyboard .keyboard.hg-theme-default .hg-button.key.half,
.vue-touch-keyboard .keyboard.hg-theme-default .key.half {
  flex: 20 1 0%;
}

.vue-touch-keyboard .keyboard .hg-button.key.control,
.vue-touch-keyboard .keyboard .key.control {
  color: #fff;
  background-color: #7d7d7d;
  border-color: #656565;
}

.vue-touch-keyboard .keyboard.hg-theme-default .hg-button.key.featured,
.vue-touch-keyboard .keyboard.hg-theme-default .key.featured {
  /* flex: 100 1 0%; */
  color: #fff;
  background-color: #337ab7;
  border-color: #2e6da4;
}

.vue-touch-keyboard .keyboard .hg-button.key:hover,
.vue-touch-keyboard .keyboard .key:hover {
  color: #333;
  background-color: #d6d6d6;
  border-color: #adadad;
}

.vue-touch-keyboard .keyboard .hg-button.key:active,
.vue-touch-keyboard .keyboard .hg-button.key.activated,
.vue-touch-keyboard .keyboard .key:active,
.vue-touch-keyboard .keyboard .key.activated {
  transform: scale(.98);
}

.vue-touch-keyboard .keyboard .hg-button.key:active,
.vue-touch-keyboard .keyboard .key:active {
  color: #333;
  background-color: #d4d4d4;
  border-color: #8c8c8c;
}

.vue-touch-keyboard .keyboard .hg-button.key.activated,
.vue-touch-keyboard .keyboard .key.activated {
  color: #fff;
  background-color: #5bc0de;
  border-color: #46b8da;
}

.vue-touch-keyboard .keyboard.hg-theme-default .hg-button.placeholder,
.vue-touch-keyboard .keyboard.hg-theme-default .placeholder {
  flex: 20 1 0%;
  min-width: 0;
  width: auto !important;
  max-width: none !important;
  height: 2.2em;
  line-height: 2.2em;
  background: transparent;
  border-color: transparent;
  box-shadow: none;
  pointer-events: none;
}

.vue-touch-keyboard .keyboard .hg-button.placeholder:not(:last-child),
.vue-touch-keyboard .keyboard .placeholder:not(:last-child) {
  margin-right: .5em;
}

.vue-touch-keyboard .keyboard:after,
.vue-touch-keyboard .keyboard:before {
  content: "";
  display: table;
}

.vue-touch-keyboard .keyboard:after {
  clear: both;
}
</style>
