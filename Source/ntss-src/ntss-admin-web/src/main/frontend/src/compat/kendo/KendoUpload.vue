<template>
  <input ref="root" :name="name" type="file" />
</template>

<script>
import $ from "@/compat/jquery";
import { ensureJQueryKendo } from "@/compat/kendo/kendo-jquery.js";
import { createLegacyKendoEvent, updateLegacySenderState } from "@/compat/kendo/legacy-sender.js";

export default {
  name: "KendoUpload",
  inheritAttrs: false,
  props: {
    name: { type: String, default: "files" },
    disabled: { type: Boolean, default: false },
    async: { type: Object, default: () => ({}) },
    showFileList: { type: Boolean, default: true },
    dropZone: { type: [String, Object], default: null },
    localization: { type: Object, default: () => ({}) },
    validation: { type: Object, default: () => ({}) },
    multiple: { type: Boolean, default: true }
  },
  emits: ["select", "remove", "upload", "success", "error", "cancel", "complete"],
  data() {
    return {
      widget: null
    };
  },
  mounted() {
    this.createWidget();
  },
  watch: {
    disabled(value) {
      if (this.widget?.enable) {
        this.widget.enable(!value);
      }
    },
    async: {
      deep: true,
      handler() {
        this.recreateWidget();
      }
    },
    showFileList() { this.recreateWidget(); },
    dropZone() { this.recreateWidget(); },
    localization: {
      deep: true,
      handler() {
        this.recreateWidget();
      }
    },
    validation: {
      deep: true,
      handler() {
        this.recreateWidget();
      }
    },
    multiple() { this.recreateWidget(); }
  },
  beforeUnmount() {
    this.destroyWidget();
  },
  methods: {
    normalizeUploadFiles(files = []) {
      return Array.from(files || []).map((file, index) => {
        if (!file || typeof file !== "object") {
          return file;
        }
        if (!file.uid) {
          const name = file.name || file.fileName || `file-${index}`;
          file.uid = `ntss-upload-${Date.now()}-${index}-${String(name).replace(/\W+/g, "-")}`;
        }
        if (!file.extension && file.name && file.name.includes(".")) {
          file.extension = file.name.slice(file.name.lastIndexOf("."));
        }
        return file;
      });
    },
    decorateUploadDom() {
      const widget = this.widget;
      const root = this.$refs.root;
      const element = widget?.element || $(root || []);
      const wrapper = widget?.wrapper || element.closest?.(".k-upload") || element;
      const wrapperEl = wrapper?.[0] || root?.closest?.(".k-upload") || root;
      wrapperEl?.classList?.add?.("k-widget", "k-upload", "k-header", "ntss-kendo-upload-legacy");
      Array.from(wrapperEl?.querySelectorAll?.(".k-dropzone, .k-upload-button, .k-button, .k-upload-files, .k-file, .k-file-name, .k-actions, .k-upload-status") || []).forEach((el) => {
        el.classList?.add?.("ntss-kendo-upload-legacy-child");
      });
      Array.from(wrapperEl?.querySelectorAll?.("button, .k-button, [role='button']") || []).forEach((button) => {
        button.classList?.add?.("k-button", "k-button-icontext", "ntss-kendo-upload-button-legacy");
        Array.from(button.querySelectorAll?.(".k-icon, .k-svg-icon, svg") || []).forEach((icon) => {
          icon.classList?.add?.("ntss-kendo-upload-icon-legacy");
        });
      });
      Array.from(wrapperEl?.querySelectorAll?.("ul.k-upload-files, .k-upload-files") || []).forEach((list) => {
        list.classList?.add?.("k-reset");
      });
      Array.from(wrapperEl?.querySelectorAll?.("li.k-file, .k-file") || []).forEach((file) => {
        file.classList?.add?.("k-file", "k-state-default");
      });
      return { element, wrapper, wrapperEl };
    },
    destroyWidget() {
      if (this.widget?.destroy) {
        this.widget.destroy();
      }
      this.widget = null;
    },
    async recreateWidget() {
      this.destroyWidget();
      await this.createWidget();
    },
    buildOptions() {
      return {
        ...this.$attrs,
        async: this.async,
        showFileList: this.showFileList,
        dropZone: this.dropZone,
        localization: this.localization,
        validation: this.validation,
        multiple: this.multiple,
        enabled: !this.disabled,
        select: (e) => this.emitUploadEvent("select", e),
        remove: (e) => this.emitUploadEvent("remove", e),
        upload: (e) => this.emitUploadEvent("upload", e),
        success: (e) => this.emitUploadEvent("success", e),
        error: (e) => this.emitUploadEvent("error", e),
        cancel: (e) => this.emitUploadEvent("cancel", e),
        complete: (e) => this.emitUploadEvent("complete", e)
      };
    },
    emitUploadEvent(name, rawEvent = null) {
      const sender = rawEvent?.sender || this.widget;
      const { element, wrapper } = this.decorateUploadDom();
      const files = this.normalizeUploadFiles(rawEvent?.files || []);
      updateLegacySenderState(sender, {
        value: this.$refs.root?.value || "",
        text: this.$refs.root?.value || "",
        element: sender?.element || element,
        wrapper: sender?.wrapper || wrapper
      });
      this.$emit(name, createLegacyKendoEvent(rawEvent, sender, {
        files,
        operation: rawEvent?.operation,
        response: rawEvent?.response,
        XMLHttpRequest: rawEvent?.XMLHttpRequest,
        originalEvent: rawEvent?.originalEvent || rawEvent?.event || null
      }));
      this.$nextTick(() => this.decorateUploadDom());
    },
    syncWidgetCompatRefs() {
      if (!this.widget) {
        return;
      }
      const { element, wrapper } = this.decorateUploadDom();
      this.widget.element = element;
      this.widget.wrapper = wrapper;
      this.widget.input = element;
      this.widget.files = this.widget.files || (() => this.getFiles());
      updateLegacySenderState(this.widget, {
        value: this.$refs.root?.value || "",
        text: this.$refs.root?.value || "",
        element,
        wrapper
      });
    },
    async createWidget() {
      await ensureJQueryKendo();
      const root = this.$refs.root;
      if (!root) {
        return;
      }
      const $root = $(root);
      const current = $root.data("kendoUpload");
      if (current?.destroy) {
        current.destroy();
      }
      $root.kendoUpload(this.buildOptions());
      this.widget = $root.data("kendoUpload") || null;
      if (this.widget?.enable) {
        this.widget.enable(!this.disabled);
      }
      this.syncWidgetCompatRefs();
      this.$nextTick(() => this.decorateUploadDom());
    },
    kendoWidget() {
      this.syncWidgetCompatRefs();
      return this.widget;
    },
    getFiles() {
      const wrapperEl = this.widget?.wrapper?.[0] || this.$refs.root?.closest?.(".k-upload");
      return Array.from(wrapperEl?.querySelectorAll?.(".k-file") || []).map((fileEl) => ({
        uid: fileEl.getAttribute("data-uid") || "",
        name: fileEl.querySelector?.(".k-file-name")?.textContent?.trim?.() || "",
        element: fileEl
      }));
    },
    clearAllFiles() {
      this.widget?.clearAllFiles?.();
      const wrapperEl = this.widget?.wrapper?.[0] || this.$refs.root?.closest?.(".k-upload");
      Array.from(wrapperEl?.querySelectorAll?.(".k-file") || []).forEach((fileEl) => fileEl.remove());
      return this.widget;
    },
    clearFiles() {
      return this.clearAllFiles();
    },
    enable(value = true) {
      this.widget?.enable?.(value !== false);
      return this.widget;
    },
    disable() {
      this.widget?.enable?.(false);
      return this.widget;
    },
    upload() {
      return this.widget?.upload?.();
    },
    browse() {
      const input = this.widget?.element?.[0] || this.$refs.root;
      input?.click?.();
      return input;
    },
    setSaveUrl(saveUrl) {
      if (!this.widget) {
        return;
      }
      if (!this.widget.options.async) {
        this.widget.options.async = {};
      }
      this.widget.options.async.saveUrl = saveUrl;
    },
    setRemoveUrl(removeUrl) {
      if (!this.widget) {
        return;
      }
      if (!this.widget.options.async) {
        this.widget.options.async = {};
      }
      this.widget.options.async.removeUrl = removeUrl;
    }
  }
};
</script>
