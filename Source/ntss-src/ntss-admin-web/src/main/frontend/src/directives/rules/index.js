import {
  buildValidationFieldMeta,
  extractValidationValue,
  queueValidationTask,
  resolveValidationOwner,
} from "@/compat/validation/host.js";

function getDirectiveSignature(instance, meta, binding) {
  const ruleValue = binding.value || "";
  let rules = "";
  try {
    rules = JSON.stringify(ruleValue);
  } catch (_error) {
    rules = String(ruleValue);
  }
  return JSON.stringify({
    ownerUid: instance?.$?.uid || instance?._uid || 0,
    id: meta.id,
    scope: meta.scope,
    label: meta.label,
    fieldName: meta.fieldName,
    fullName: meta.fullName,
    rules,
    immediate: !!binding.modifiers.immediate
  });
}

function setupRulesDirective(el, binding) {
  const instance = resolveValidationOwner(binding.instance);
  if (!instance || typeof instance.registerValidationField !== "function") {
    el.__rulesCleanup?.();
    return;
  }

  const meta = buildValidationFieldMeta(el, binding);
  if (!meta.fieldName || !meta.target) {
    el.__rulesCleanup?.();
    return;
  }

  const nextSignature = getDirectiveSignature(instance, meta, binding);
  if (
    el.__rulesCleanup
    && el.__rulesOwner__ === instance
    && el.__rulesTarget__ === meta.target
    && el.__rulesSignature__ === nextSignature
  ) {
    return;
  }

  el.__rulesCleanup?.();

  const applyValidation = () => {
    instance.registerValidationField({
      id: meta.id,
      scope: meta.scope,
      fieldName: meta.fieldName,
      fullName: meta.fullName,
      label: meta.label,
      rules: meta.rules,
      target: meta.target,
      ownerDocument: meta.ownerDocument,
      getter: () => extractValidationValue(meta.target)
    });
  };

  const handleValidate = () => {
    applyValidation();
    instance.validateField(meta.fullName);
  };

  const handleInput = () => {
    applyValidation();
    if (instance.hasValidationError?.(meta.fullName)) {
      instance.validateField(meta.fullName);
    }
  };

  applyValidation();
  meta.target?.addEventListener?.("blur", handleValidate);
  meta.target?.addEventListener?.("change", handleValidate);
  meta.target?.addEventListener?.("input", handleInput);

  if (meta.immediate) {
    queueValidationTask(handleValidate);
  }

  el.__rulesOwner__ = instance;
  el.__rulesTarget__ = meta.target;
  el.__rulesSignature__ = nextSignature;
  el.__rulesCleanup = () => {
    meta.target?.removeEventListener?.("blur", handleValidate);
    meta.target?.removeEventListener?.("change", handleValidate);
    meta.target?.removeEventListener?.("input", handleInput);
    instance.unregisterValidationField?.(meta);
    delete el.__rulesOwner__;
    delete el.__rulesTarget__;
    delete el.__rulesSignature__;
    delete el.__rulesCleanup;
  };
}

export default {
  mounted(el, binding) {
    setupRulesDirective(el, binding);
  },
  updated(el, binding) {
    setupRulesDirective(el, binding);
  },
  unmounted(el) {
    el.__rulesCleanup?.();
  }
};
