<template>
  <span ref="root"></span>
</template>

<script>
import { destroyQrCode, getQrCode, mountQrCode, prepareQrCode } from "@/compat/kendo/qrcode.js";

export default {
  name: "KendoQrCode",
  inheritAttrs: false,
  props: {
    value: { type: String, default: "" },
    size: { type: [Number, String], default: 120 },
    encoding: { type: String, default: "UTF_8" },
    errorCorrection: { type: String, default: undefined },
    color: { type: String, default: undefined },
    background: { type: String, default: undefined },
    border: { type: [Object, Boolean], default: undefined },
    padding: { type: [Number, String], default: undefined },
    renderAs: { type: String, default: undefined }
  },
  async mounted() {
    await prepareQrCode();
    this.renderCode();
  },
  watch: {
    value() { this.renderCode(); },
    size() { this.renderCode(); },
    encoding() { this.renderCode(); }
  },
  methods: {
    buildOptions() {
      const options = {
        ...this.$attrs,
        value: this.value,
        size: Number(this.size),
        encoding: this.encoding
      };
      ["errorCorrection", "color", "background", "border", "padding", "renderAs"].forEach((key) => {
        if (this[key] !== undefined) {
          options[key] = key === "padding" ? Number(this[key]) : this[key];
        }
      });
      return options;
    },
    renderCode() {
      mountQrCode(this.$refs.root, this.buildOptions());
      this.syncWidgetCompatRefs();
    },
    syncWidgetCompatRefs() {
      const root = this.$refs.root;
      if (!root) {
        return;
      }
      root.classList?.add?.("k-widget", "k-qrcode", "ntss-kendo-qrcode-legacy");
      const widget = getQrCode(root);
      if (widget) {
        const element = widget.element || { 0: root, length: 1 };
        widget.element = element;
        widget.wrapper = widget.wrapper || element;
        widget.options = widget.options || this.buildOptions();
        widget.value = widget.value || (() => this.value);
        widget.setOptions = widget.setOptions || ((options = {}) => {
          mountQrCode(root, { ...this.buildOptions(), ...options });
          this.syncWidgetCompatRefs();
        });
        widget.redraw = widget.redraw || (() => this.renderCode());
      }
    },
    kendoWidget() {
      this.syncWidgetCompatRefs();
      return getQrCode(this.$refs.root);
    },
    redraw() {
      this.renderCode();
      return this.kendoWidget();
    },
    setOptions(options = {}) {
      mountQrCode(this.$refs.root, { ...this.buildOptions(), ...options });
      this.syncWidgetCompatRefs();
      return this.kendoWidget();
    }
  },
  beforeUnmount() {
    destroyQrCode(this.$refs.root);
  }
};
</script>
