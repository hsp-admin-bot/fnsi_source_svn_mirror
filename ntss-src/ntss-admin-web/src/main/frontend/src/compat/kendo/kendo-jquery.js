import $ from "@/compat/jquery";

let jqueryKendoPromise = null;

export function getJQueryKendo() {
  if (typeof window !== "undefined" && window.kendo) {
    return window.kendo;
  }
  return globalThis.kendo;
}

export async function ensureJQueryKendo() {
  const current = getJQueryKendo();
  if (current) {
    return current;
  }
  if (!jqueryKendoPromise) {
    jqueryKendoPromise = import("@progress/kendo-ui").then(() => {
      const loaded = getJQueryKendo();
      if (!loaded) {
        throw new Error("Kendo jQuery is not available.");
      }
      return loaded;
    });
  }
  return jqueryKendoPromise;
}

function requireJQueryKendo() {
  const jqueryKendo = getJQueryKendo();
  if (!jqueryKendo?.data?.DataSource) {
    throw new Error("Kendo jQuery is not available. Call ensureJQueryKendo() before using jQuery widgets.");
  }
  return jqueryKendo;
}

export function isJQueryDataSource(source) {
  const jqueryKendo = getJQueryKendo();
  return !!(jqueryKendo?.data?.DataSource && source instanceof jqueryKendo.data.DataSource);
}

export function createJQueryDataSource(options) {
  const jqueryKendo = requireJQueryKendo();
  return new jqueryKendo.data.DataSource(options);
}

function toJQuery(target) {
  if (target?.jquery) {
    return target;
  }
  return $(target || []);
}

/** Grid Editable と同じ Kendo UI 2026 向け SVG（k-i-warning は保存時 validate で□になる） */
function renderKendoValidatorErrorTemplate({ message } = {}) {
  const kendo = getJQueryKendo();
  const text = message ?? "";
  const iconMarkup = kendo?.ui?.icon
    ? kendo.ui.icon({
      icon: "exclamation-circle",
      iconClass: "k-tooltip-icon",
    })
    : "";
  return (
    '<div class="k-widget k-tooltip k-tooltip-validation k-invalid-msg k-tooltip-error k-validator-tooltip">'
    + iconMarkup
    + `<span class="k-tooltip-content">${text}</span>`
    + '<span class="k-callout k-callout-n"></span>'
    + "</div>"
  );
}

function mergeLegacyKendoValidatorOptions(options = {}) {
  return {
    ...options,
    errorTemplate: options.errorTemplate ?? renderKendoValidatorErrorTemplate,
  };
}

export function createJQueryValidator(target, options = {}) {
  const $target = toJQuery(target);
  return $target.kendoValidator(mergeLegacyKendoValidatorOptions(options)).data("kendoValidator");
}

export function getJQueryValidator(target) {
  const $target = toJQuery(target);
  return $target.data("kendoValidator") || null;
}

export function destroyJQueryValidator(target) {
  const widget = target?.validate ? target : getJQueryValidator(target);
  if (widget && typeof widget.destroy === "function") {
    widget.destroy();
  }
}

export function mountJQueryQrCode(target, options = {}) {
  const $target = toJQuery(target);
  destroyJQueryQrCode($target);
  $target.empty();
  $target.kendoQRCode(options);
  return $target.data("kendoQRCode") || null;
}

export function getJQueryQrCode(target) {
  const $target = toJQuery(target);
  return $target.data("kendoQRCode") || null;
}

export function destroyJQueryQrCode(target) {
  const $target = toJQuery(target);
  const widget = $target.data("kendoQRCode");
  if (widget && typeof widget.destroy === "function") {
    widget.destroy();
  }
  $target.empty();
}

export function setKendoProgress(target, visible) {
  const element = target?.jquery ? target : toJQuery(target?.element?.[0] || target?.element || target);
  const kendo = getJQueryKendo();
  if (kendo?.ui?.progress && element?.length) {
    kendo.ui.progress(element, !!visible);
  }
}
