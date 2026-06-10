<template>
  <div class="ons-select-like">
    <kendo-combobox
      :data-source="items"
      :data-text-field="textField"
      :data-value-field="valueField"
      v-model="innerValue"
      :filter="'contains'"
      :suggest="false"
      :disabled="disabled"
      :placeholder="placeholder"
      :popup="popupSettings"
      @open="onPopupOpen"
    />
  </div>
</template>

<script>
import { ComboBox } from "@progress/kendo-dropdowns-vue-wrapper";

export default {
  name: "CommonSearchSelect",
  components: {
    "kendo-combobox": ComboBox,
  },

  props: {
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

  methods: {
    onPopupOpen(e) {
      const widget = e.sender;

      if (this.isEdited) {
        widget.popup.element.addClass("green-popup-style");
      } else {
        widget.popup.element.removeClass("green-popup-style");
      }
    },
  },

  computed: {
    innerValue: {
      get() {
        return this.value;
      },
      set(val) {
        this.$emit("input", val);
      },
    },
    popupSettings() {
      const currentStatus = this.isEdited;
      return {
        addClass: currentStatus ? "green-popup-style" : "",
        origin: "bottom left",
      };
    },
  },
};
</script>

<style>
.ons-select-like .k-combobox {
  width: 100%;
  font-size: 15px;
}
.ons-select-like .k-dropdown-wrap::before,
.ons-select-like .k-dropdown-wrap::after {
  border: 1.3px solid #90a4ae !important;
  content: "";
  position: absolute;
  inset: 0;
  border-radius: 5px;
  pointer-events: none;
}
.ons-select-like .k-dropdown-wrap:hover::before,
.ons-select-like .k-dropdown-wrap:hover::after {
  border-color: #b0bec5 !important;
}
.ons-select-like .k-dropdown-wrap.k-state-focused::before,
.ons-select-like .k-dropdown-wrap.k-state-focused::after {
  border-color: #2196f3 !important;
}
.ons-select-like .k-input {
  font-family: inherit !important;
  font-size: 15px !important;
  line-height: 30px !important;
  height: 30px !important;
  padding-left: 8px !important;
  background: transparent !important;
  box-sizing: border-box;
  max-width: calc(100% - 25px);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  -webkit-font-smoothing: antialiased !important;
  -moz-osx-font-smoothing: auto !important;
  display: flex !important;
  font-family: -apple-system, "Helvetica Neue", "Segoe UI", sans-serif !important;
  align-items: center !important;
}
.ons-select-like .k-select {
  width: 28px;
  background: transparent !important;
  border-left: none !important;
  height: 100% !important;
  display: flex !important;
  align-items: center !important;
  justify-content: center !important;
  position: absolute;
  right: 0;
}
.ons-select-like .k-i-arrow-60-down {
  color: #666;
}
.k-list-container {
  border-radius: 5px !important;
  width: auto !important;
  min-width: 100%;
  max-width: 500px;
}
.k-list .k-item {
  font-size: 15px !important;
  padding: 4px 20px !important;
  border: none !important;
  white-space: nowrap !important;
  overflow: visible !important;
  text-overflow: clip !important;
}
.k-list .k-item:hover {
  background: #2196f3 !important;
  border: none !important;
  box-shadow: none !important;
}
.k-list .k-state-selected {
  border: none !important;
  box-shadow: none !important;
  outline: none !important;
  background: #2196f3 !important;
  color: #000 !important;
}
.k-dropdown-wrap .k-clear-value {
  position: absolute !important;
  top: 50% !important;
  transform: translateY(-50%) !important;
  right: 28px !important;
  line-height: 2 !important;
  cursor: pointer;
}
.k-list .k-item.k-state-focused {
  outline: none !important;
  box-shadow: none !important;
  border: none !important;
}
.ons-select-like .k-dropdown-wrap.k-state-disabled:hover::before,
.ons-select-like .k-dropdown-wrap.k-state-disabled:hover::after {
  border-color: #d1d9dd !important;
}
.ons-select-like .k-state-disabled,
.ons-select-like .k-state-disabled .k-dropdown-wrap,
.ons-select-like .k-state-disabled.k-state-focused .k-dropdown-wrap {
  border: none !important;
  box-shadow: none !important;
}
.ons-select-like .k-state-disabled::before,
.ons-select-like .k-state-disabled::after {
  display: none !important;
}
.ons-select-like .k-state-disabled {
  filter: none !important;
  opacity: 1 !important;
  background-color: #f5f5f5 !important;
  cursor: default !important;
  border: none !important;
  pointer-events: none;
}
.ons-select-like .k-state-disabled .k-dropdown-wrap::before,
.ons-select-like .k-state-disabled .k-dropdown-wrap::after {
  display: block !important;
  border-color: rgba(144, 164, 174, 0.5) !important;
}
.ons-select-like .k-state-disabled:hover .k-dropdown-wrap::before,
.ons-select-like .k-state-disabled.k-state-focused .k-dropdown-wrap::before {
  border-color: rgba(144, 164, 174, 0.5) !important;
}
.ons-select-like .k-state-disabled .k-i-arrow-60-down {
  color: #666 !important;
}
.ons-select-like .k-state-disabled .k-dropdown-wrap {
  display: flex !important;
  align-items: center;
  height: 32px !important;
  border-color: transparent !important;
  box-shadow: none !important;
}
.k-list {
  width: auto !important;
}
.ons-select-like .k-state-disabled,
.ons-select-like .k-state-disabled .k-select,
.ons-select-like .k-state-disabled .k-i-arrow-60-down {
  opacity: 1 !important;
  filter: none !important;
}
.ons-select-like .k-state-disabled .k-select {
  display: flex !important;
  width: 28px !important;
  background: transparent !important;
  border-left: none !important;
}
.ons-select-like .k-dropdown-wrap {
  align-items: center !important;
  border-style: inset;
  border-width: 1.5px;
  border-image-repeat: stretch;
  border-color: unset;
  height: 2em;
  border-radius: 5px;
  -webkit-box-sizing: border-box;
  box-sizing: border-box;
  background: #f7f7f7 !important;
  -webkit-box-shadow: none !important;
  box-shadow: none !important;
  position: relative;
  height: 32px;
  padding-right: 0px !important;
}
.k-dropdown-wrap.k-state-disabled {
  border: 1px solid #dcdcdc !important;
  box-shadow: inset 1px 1px 3px rgba(0, 0, 0, 0.08) !important;
  background: #f7f7f7 !important;
  height: 2em;
  border-radius: 5px;
  box-sizing: border-box;
  border-style: solid !important;
}
.ons-select-like .k-dropdown-wrap.k-state-disabled .k-i-arrow-60-down {
  color: #b0bec5 !important;
}
div.ons-select-like .k-dropdown-wrap input.k-input {
  padding: 0 20px 0 6px !important;
}
body .k-list-container .k-list .k-item {
  padding: 3px 8px !important;
}
.ons-select-like .k-state-disabled,
.ons-select-like .k-state-disabled .k-dropdown-wrap,
.k-dropdown-wrap.k-state-disabled {
  background-color: #ebebe4 !important;
  opacity: 0.6 !important;
}
.ons-select-like .k-state-disabled .k-input {
  border: none !important;
  color: #ccc !important;
  -webkit-text-fill-color: #ccc !important;
  background-color: transparent !important;
}
.ons-select-like.custom-select-edited .k-dropdown-wrap,
.ons-select-like.custom-select-edited .k-dropdown-wrap.k-state-focused,
.ons-select-like.custom-select-edited .k-dropdown-wrap:hover {
  border-color: transparent !important;
  box-shadow: none !important;
  outline: none !important;
}
.ons-select-like.custom-select-edited .k-dropdown-wrap::before,
.ons-select-like.custom-select-edited .k-dropdown-wrap::after {
  border: 2px solid green !important;
  content: "";
  position: absolute;
  inset: 0;
  border-radius: 5px;
  pointer-events: none;
  opacity: 1 !important;
}
.ons-select-like.custom-select-edited .k-dropdown-wrap.k-state-focused::before,
.ons-select-like.custom-select-edited .k-dropdown-wrap.k-state-focused::after {
  border-color: green !important;
}
.ons-select-like.custom-select-edited .k-input {
  outline: none !important;
  box-shadow: none !important;
  color: green !important;
  font-weight: bold !important;
  -webkit-text-fill-color: green;
}
.ons-select-like.k-state-disabled.custom-select-edited .k-input {
  color: #ccc !important;
  font-weight: normal !important;
  -webkit-text-fill-color: #ccc;
}
body .green-popup-style .k-list .k-item {
  color: green !important;
}
</style>
