import { createKendoValidator, destroyKendoValidator } from "@/functions/common/KendoFunctions";

const KENDO_VALIDATOR_INSTANCE_STATE_FLAG = "__ntssKendoValidatorInstanceStateInstalled";

export function installKendoValidatorInstanceState(app) {
  if (!app || app[KENDO_VALIDATOR_INSTANCE_STATE_FLAG]) {
    return;
  }
  Object.defineProperty(app, KENDO_VALIDATOR_INSTANCE_STATE_FLAG, {
    configurable: false,
    enumerable: false,
    value: true,
  });
  app.mixin({
    data() {
      return {
        // Vue2 の kendo-validator wrapper/directive はページ側で未宣言の
        // this.kendoValidator 参照を許容していたため、Vue3 でも初回 render 前に
        // 旧インスタンスプロパティだけを用意しておく。実体は v-kendo-validator が同期する。
        kendoValidator: undefined,
      };
    },
  });
}

/**
 * Kendo jQuery Validator 互換ディレクティブ。
 * 既存の v-kendo-validator 利用箇所を Vue3 側で継続利用できるようにする。
 */
function syncInstanceValidator(binding, validator) {
  const instance = binding?.instance;
  if (instance) {
    instance.kendoValidator = validator || undefined;
  }
}

function normalizeOptions(value) {
  const replacer = (_key, currentValue) => {
    if (typeof currentValue === "function") {
      return `[Function:${currentValue.name || "anonymous"}]`;
    }
    return currentValue;
  };
  try {
    return JSON.stringify(value || {}, replacer);
  } catch (_error) {
    return String(value || "");
  }
}

function ensureValidator(el, binding) {
  const options = binding.value || {};
  const nextSignature = normalizeOptions(options);
  const currentSignature = el.__kendoValidatorOptionsSignature__ || "";
  if (el.__kendoValidator__ && currentSignature === nextSignature) {
    syncInstanceValidator(binding, el.__kendoValidator__);
    return el.__kendoValidator__;
  }
  destroyKendoValidator(el.__kendoValidator__ || el);
  el.__kendoValidator__ = createKendoValidator(el, options);
  el.__kendoValidatorOptionsSignature__ = nextSignature;
  syncInstanceValidator(binding, el.__kendoValidator__);
  return el.__kendoValidator__;
}

export default {
  mounted(el, binding) {
    ensureValidator(el, binding);
  },
  updated(el, binding) {
    ensureValidator(el, binding);
  },
  unmounted(el, binding) {
    destroyKendoValidator(el.__kendoValidator__ || el);
    syncInstanceValidator(binding, null);
    delete el.__kendoValidator__;
    delete el.__kendoValidatorOptionsSignature__;
  }
};
