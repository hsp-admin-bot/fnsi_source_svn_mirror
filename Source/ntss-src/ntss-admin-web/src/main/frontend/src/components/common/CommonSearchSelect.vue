<template>
  <div class="ons-select-like">
    <input ref="input" />
  </div>
</template>

<script>
import $ from "@/compat/jquery";

export default {
  name: "CommonSearchSelect",

  props: {
    modelValue: null,
    value: null,
    items: {
      type: Array,
      default: () => [],
    },

    textField: {
      type: String,
      default: "text",
    },

    valueField: {
      type: String,
      default: "value",
    },

    placeholder: {
      type: String,
      default: "",
    },

    disabled: {
      type: Boolean,
      default: false,
    },

    isEdited: {
      type: Boolean,
      default: false,
    },
  },

  data() {
    return {
      widget: null,
      syncingValue: false,
    };
  },

  computed: {
    currentValue() {
      return this.modelValue !== undefined ? this.modelValue : this.value;
    },
    popupSettings() {
      return {
        addClass: this.isEdited ? "green-popup-style" : "",
        origin: "bottom left",
      };
    },
  },

  watch: {
    currentValue(value) {
      this.syncWidgetValue(value);
    },
    items: {
      handler(value) {
        this.widget?.setDataSource?.(value);
      },
      deep: true,
    },
    disabled(value) {
      this.widget?.enable?.(!value);
    },
  },

  mounted() {
    this.createWidget();
  },

  beforeUnmount() {
    this.widget?._clear?.off?.("click.ntssClearFix touchend.ntssClearFix");
    if (this.widget) {
      try {
        this.widget.destroy();
      } catch (_error) {
        // noop
      }
      this.widget = null;
    }
  },

  methods: {
    createWidget() {
      const $element = $(this.$refs.input);
      $element.kendoComboBox({
        dataSource: this.items,
        dataTextField: this.textField,
        dataValueField: this.valueField,
        filter: "contains",
        suggest: false,
        clearButton: true,
        prefixOptions: { separator: false },
        suffixOptions: { separator: false },
        placeholder: this.placeholder,
        valuePrimitive: true,
        animation: false,
        popup: this.popupSettings,
        value: this.currentValue,
        change: () => {
          this.emitWidgetValue();
        },
        open: (e) => this.onPopupOpen(e),
      });
      this.widget = $element.data("kendoComboBox");
      this.widget?.wrapper?.addClass?.("select-input");
      this.widget?.enable?.(!this.disabled);
      this.$nextTick(() => {
        this.dedupeClearButton();
        this.dedupeDropdownButton();
        this.bindClearButton();
      });
    },
    normalizeEmittedValue(value) {
      return value === "" || value === undefined ? null : value;
    },
    emitWidgetValue() {
      if (this.syncingValue || !this.widget) {
        return;
      }
      const nextValue = this.normalizeEmittedValue(this.widget.value());
      this.$emit("update:modelValue", nextValue);
      this.$emit("input", nextValue);
    },
    dedupeClearButton() {
      const wrapper = this.widget?.wrapper;
      if (!wrapper) {
        return;
      }
      const clears = wrapper.find(".k-clear-value");
      if (clears.length > 1) {
        clears.slice(1).remove();
      }
    },
    dedupeDropdownButton() {
      const wrapper = this.widget?.wrapper;
      if (!wrapper) {
        return;
      }
      const buttons = wrapper.find(".k-input-button, .k-select").filter(
        (_, element) => !element.classList.contains("k-clear-value")
      );
      if (buttons.length > 1) {
        buttons.slice(0, -1).remove();
      }
    },
    bindClearButton() {
      const clear = this.widget?._clear;
      if (!clear?.on) {
        return;
      }
      clear.off("click.ntssClearFix touchend.ntssClearFix")
        .on("click.ntssClearFix touchend.ntssClearFix", () => {
          window.setTimeout(() => this.emitWidgetValue(), 0);
        });
    },
    syncWidgetValue(value) {
      if (!this.widget) {
        return;
      }
      const normalizedValue = value === undefined ? null : value;
      const current = this.widget.value();
      if (String(current ?? "") === String(normalizedValue ?? "")) {
        return;
      }
      this.syncingValue = true;
      try {
        this.widget.value(normalizedValue ?? "");
      } finally {
        this.syncingValue = false;
      }
    },
    onPopupOpen(e) {
      const widget = e.sender;

      if (this.isEdited) {
        widget.popup.element.addClass("green-popup-style");
      } else {
        widget.popup.element.removeClass("green-popup-style");
      }
    },
  },
};
</script>

<style>
/* 外框は ntss.css の .select-input（v-ons-select 同款）を使用 */
.ons-select-like > .k-combobox.k-input.select-input,
.ons-select-like .k-combobox.select-input .k-dropdown-wrap,
.ons-select-like .k-dropdown-wrap {
  align-items: center !important;
  width: 100%;
  display: inline-flex !important;
  vertical-align: middle;
  position: relative;
  padding: 0 !important;
  overflow: hidden;
  outline: none !important;
  box-shadow: none !important;
  border: unset !important;
  border-width: 2px !important;
  border-style: inset !important;
  border-image-repeat: stretch !important;
  border-color: unset !important;
  height: 2em !important;
  min-height: 2em !important;
  border-radius: 5px !important;
  box-sizing: border-box !important;
  background-color: #f7f7f7 !important;
  font-size: 1em !important;
  line-height: unset !important;
}

/* ons-select > .select-input と同じ左余白（背景矢印は Kendo ボタンで表示するため無効化） */
.ons-select-like > .k-combobox.k-input.select-input {
  padding-left: 4px !important;
  background-image: none !important;
}

.ons-select-like > .k-combobox.k-input.select-input.k-focus,
.ons-select-like > .k-combobox.k-input.select-input:focus-within {
  outline: none !important;
  box-shadow: none !important;
}

.ons-select-like > .k-combobox.k-input.select-input .k-input-inner,
.ons-select-like .k-dropdown-wrap input.k-input,
.ons-select-like .k-dropdown-wrap .k-input {
  font-size: 1em !important;
  line-height: unset !important;
  height: 100% !important;
  padding: 0 42px 0 0 !important;
  background: transparent !important;
  border: none !important;
  box-shadow: none !important;
  outline: none !important;
  box-sizing: border-box;
  flex: 1 1 auto;
  min-width: 0;
  max-width: 100%;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  -webkit-font-smoothing: antialiased !important;
  -moz-osx-font-smoothing: auto !important;
}

.ons-select-like > .k-combobox.k-input > .k-clear-value,
.ons-select-like .k-dropdown-wrap > .k-clear-value {
  position: absolute !important;
  top: 0 !important;
  bottom: 0 !important;
  right: 22px !important;
  transform: none !important;
  width: 20px !important;
  min-width: 20px !important;
  height: 20px !important;
  margin: auto 0 !important;
  padding: 0 !important;
  display: inline-flex !important;
  align-items: center !important;
  justify-content: center !important;
  background: transparent !important;
  border: none !important;
  box-shadow: none !important;
  z-index: 3;
  cursor: pointer;
  color: #666;
}

.ons-select-like > .k-combobox.k-input > .k-clear-value.k-hidden {
  display: none !important;
}

.ons-select-like > .k-combobox.k-input > .k-clear-value::before {
  display: none !important;
  content: none !important;
}

.ons-select-like > .k-combobox.k-input > .k-clear-value .k-svg-icon,
.ons-select-like > .k-combobox.k-input > .k-clear-value .k-icon {
  width: 16px !important;
  height: 16px !important;
}

.ons-select-like > .k-combobox.k-input > .k-clear-value .k-svg-icon svg {
  display: block !important;
}

.ons-select-like > .k-combobox.k-input > .k-input-button,
.ons-select-like .k-select {
  width: 28px !important;
  min-width: 28px !important;
  background: transparent !important;
  border: none !important;
  border-left: none !important;
  height: 100% !important;
  display: inline-flex !important;
  align-items: center !important;
  justify-content: center !important;
  position: absolute;
  right: 0;
  top: 0;
  bottom: 0;
  z-index: 2;
  box-shadow: none !important;
  color: #666;
}

.ons-select-like > .k-combobox.k-input > .k-input-button::before,
.ons-select-like > .k-combobox.k-input > .k-select::before {
  display: none !important;
  content: none !important;
}

.ons-select-like > .k-combobox.k-input > .k-input-button .k-svg-icon,
.ons-select-like > .k-combobox.k-input > .k-input-button .k-icon,
.ons-select-like .k-i-arrow-60-down {
  color: #666;
}

.ons-select-like > .k-combobox.k-input > input:not(.k-input-inner) {
  display: none !important;
}

.k-combobox-popup .k-list-container,
.k-list-container {
  border-radius: 5px !important;
  width: auto !important;
  min-width: 100%;
  max-width: 500px;
}

.k-combobox-popup .k-list,
.k-list {
  width: auto !important;
}

.k-combobox-popup .k-list-item,
.k-combobox-popup .k-item,
.k-list .k-list-item,
.k-list .k-item {
  font-size: 15px !important;
  padding: 4px 20px !important;
  border: none !important;
  white-space: nowrap !important;
  overflow: visible !important;
  text-overflow: clip !important;
  box-shadow: none !important;
}

.k-combobox-popup .k-list-item:hover,
.k-combobox-popup .k-item:hover,
.k-list .k-list-item:hover,
.k-list .k-item:hover {
  background: #2196f3 !important;
  border: none !important;
  box-shadow: none !important;
  color: #000 !important;
}

.k-combobox-popup .k-list-item.k-selected,
.k-combobox-popup .k-item.k-state-selected,
.k-list .k-list-item.k-selected,
.k-list .k-state-selected {
  border: none !important;
  box-shadow: none !important;
  outline: none !important;
  background: #2196f3 !important;
  color: #000 !important;
}

.k-combobox-popup .k-list-item.k-focus,
.k-combobox-popup .k-item.k-state-focused,
.k-list .k-list-item.k-focus,
.k-list .k-item.k-state-focused {
  outline: none !important;
  box-shadow: none !important;
  border: none !important;
}

body .k-combobox-popup .k-list-container .k-list .k-list-item,
body .k-list-container .k-list .k-item {
  padding: 3px 8px !important;
}

.ons-select-like > .k-combobox.k-input.select-input.k-disabled,
.ons-select-like > .k-combobox.k-disabled.select-input,
.ons-select-like .k-state-disabled.select-input,
.ons-select-like .k-state-disabled .k-dropdown-wrap {
  color: -internal-light-dark-color(rgb(84, 84, 84), rgb(170, 170, 170));
  cursor: default;
  background-color: #ebebe4 !important;
  border: unset !important;
  border-width: 2px !important;
  border-style: inset !important;
  border-image-repeat: stretch !important;
  border-color: unset !important;
  opacity: 1 !important;
  filter: none !important;
  pointer-events: none;
}

.ons-select-like > .k-combobox.k-input.select-input.k-disabled .k-input-inner,
.ons-select-like > .k-combobox.k-disabled.select-input .k-input-inner,
.ons-select-like .k-state-disabled .k-input {
  border: none !important;
  background-color: transparent !important;
}

.ons-select-like > .k-combobox.k-input.k-disabled > .k-input-button,
.ons-select-like > .k-combobox.k-disabled > .k-input-button,
.ons-select-like .k-state-disabled .k-select {
  display: inline-flex !important;
  opacity: 1 !important;
  filter: none !important;
  color: #b0bec5 !important;
}

.ons-select-like.custom-select-edited > .k-combobox.k-input.select-input,
.ons-select-like.custom-select-edited .k-dropdown-wrap {
  color: green;
  border: 2px green solid !important;
  outline: none !important;
  box-shadow: none !important;
}

.ons-select-like.custom-select-edited > .k-combobox.k-input.select-input .k-input-inner,
.ons-select-like.custom-select-edited .k-input {
  outline: none !important;
  box-shadow: none !important;
  color: green !important;
  font-weight: bold !important;
  -webkit-text-fill-color: green;
}

.ons-select-like.custom-select-edited.k-disabled > .k-combobox .k-input-inner,
.ons-select-like.k-state-disabled.custom-select-edited .k-input {
  color: #ccc !important;
  font-weight: normal !important;
  -webkit-text-fill-color: #ccc;
}

body .green-popup-style .k-list-item,
body .green-popup-style .k-list .k-item {
  color: green !important;
}
</style>
