import runValidationRules from "@/compat/validation/rule-engine.js";
import {
  getObjectPathValue,
  normalizeValidationFieldName,
  normalizeValidationRules,
} from "@/compat/validation/host.js";

function normalizeFieldAlias(fieldName) {
  return normalizeValidationFieldName(fieldName);
}

function resolveAliases(meta) {
  const aliases = new Set();
  const fullName = normalizeFieldAlias(meta.fullName);
  const fieldName = normalizeFieldAlias(meta.fieldName);
  const scope = normalizeFieldAlias(meta.scope);
  const id = normalizeFieldAlias(meta.id);

  if (fullName) aliases.add(fullName);
  if (fieldName) aliases.add(fieldName);
  if (id) aliases.add(id);
  if (scope) aliases.add(scope);
  return Array.from(aliases);
}

function isMatchingError(item, target) {
  const normalized = normalizeFieldAlias(target);
  if (!normalized) {
    return false;
  }
  return [item.fullName, item.field, item.id, item.scope].some((value) => normalizeFieldAlias(value) === normalized)
    || (item.fullName && item.fullName.startsWith(`${normalized}.`));
}

function isSameFieldMeta(left, right) {
  if (!left || !right) {
    return false;
  }
  return left.id === right.id
    && left.fullName === right.fullName
    && left.fieldName === right.fieldName
    && left.scope === right.scope
    && left.label === right.label
    && JSON.stringify(left.rules || "") === JSON.stringify(right.rules || "")
    && left.getter === right.getter
    && left.target === right.target
    && left.customRules === right.customRules;
}

function isSameValidationError(left, right) {
  if (!left || !right) {
    return false;
  }
  return normalizeFieldAlias(left.id) === normalizeFieldAlias(right.id)
    && normalizeFieldAlias(left.field) === normalizeFieldAlias(right.field)
    && normalizeFieldAlias(left.fullName) === normalizeFieldAlias(right.fullName)
    && normalizeFieldAlias(left.scope) === normalizeFieldAlias(right.scope)
    && String(left.message || "") === String(right.message || "")
    && String(left.source || "") === String(right.source || "");
}

export default {
  data() {
    return {
      __validationFields: {},
      __validationErrors: [],
      __validationCustomRules: {}
    };
  },
  computed: {
    validationErrors() {
      return this.__validationErrors;
    },
    hasAnyValidationError() {
      return this.__validationErrors.length > 0;
    }
  },
  methods: {
    registerValidationField(meta = {}) {
      const fullName = normalizeFieldAlias(meta.fullName || meta.fieldName || meta.id);
      if (!fullName) {
        return;
      }
      const normalized = {
        id: meta.id || fullName,
        fullName,
        fieldName: meta.fieldName || fullName.split(".").pop(),
        scope: meta.scope || "",
        label: meta.label || meta.fieldName || fullName,
        rules: normalizeValidationRules(meta.rules),
        getter: meta.getter,
        target: meta.target || null,
        ownerDocument: meta.ownerDocument || meta.target?.ownerDocument || null,
        customRules: meta.customRules || null
      };
      const current = this.__validationFields[fullName];
      if (isSameFieldMeta(current, normalized)) {
        return;
      }
      this.__validationFields[fullName] = normalized;
    },
    unregisterValidationField(fullName) {
      const normalized = normalizeFieldAlias(typeof fullName === "object" ? fullName?.fullName || fullName?.fieldName || fullName?.id : fullName);
      if (!normalized || !this.__validationFields[normalized]) {
        return;
      }
      delete this.__validationFields[normalized];
      this.clearValidationError(normalized);
    },
    registerValidationRule(name, validator) {
      if (!name || typeof validator !== "function") {
        return;
      }
      if (this.__validationCustomRules[name] === validator) {
        return;
      }
      this.__validationCustomRules[name] = validator;
    },
    resolveValidationField(fieldName) {
      const normalized = normalizeFieldAlias(fieldName);
      if (!normalized) {
        return null;
      }
      if (this.__validationFields[normalized]) {
        return this.__validationFields[normalized];
      }
      const matched = Object.values(this.__validationFields).find((item) => resolveAliases(item).includes(normalized));
      return matched || null;
    },
    resolveValidationValue(fieldName, fallbackValue) {
      if (arguments.length > 1) {
        return fallbackValue;
      }
      const meta = this.resolveValidationField(fieldName);
      if (!meta) {
        return undefined;
      }
      if (typeof meta.getter === "function") {
        return meta.getter();
      }
      if (meta.target) {
        if (meta.target.type === "checkbox") {
          return !!meta.target.checked;
        }
        if (meta.target.value !== undefined) {
          return meta.target.value;
        }
      }
      return getObjectPathValue(this, meta.fullName) ?? getObjectPathValue(this, meta.fieldName);
    },
    clearValidationError(fieldName) {
      const normalized = normalizeFieldAlias(fieldName);
      if (!normalized) {
        if (this.__validationErrors.length > 0) {
          this.__validationErrors = [];
        }
        return;
      }
      const nextErrors = this.__validationErrors.filter((item) => !isMatchingError(item, normalized));
      if (nextErrors.length !== this.__validationErrors.length) {
        this.__validationErrors = nextErrors;
      }
    },
    pushValidationError(entryOrId, message = "") {
      const entry = typeof entryOrId === "string"
        ? { id: entryOrId, name: entryOrId, scope: entryOrId, message }
        : { ...(entryOrId || {}) };
      const id = normalizeFieldAlias(entry.id || entry.name || entry.field || entry.scope);
      if (!id) {
        return;
      }
      const nextError = {
        id,
        field: entry.field || entry.name || id,
        fullName: entry.fullName || entry.name || id,
        scope: entry.scope || "",
        message: entry.message || message || "",
        source: entry.source || "manual"
      };
      const currentIndex = this.__validationErrors.findIndex((item) => normalizeFieldAlias(item.id) === id);
      if (currentIndex >= 0) {
        if (isSameValidationError(this.__validationErrors[currentIndex], nextError)) {
          return;
        }
        const nextErrors = [...this.__validationErrors];
        nextErrors.splice(currentIndex, 1, nextError);
        this.__validationErrors = nextErrors;
        return;
      }
      this.__validationErrors = [...this.__validationErrors, nextError];
    },
    removeValidationErrorById(id) {
      const normalized = normalizeFieldAlias(id);
      if (!normalized) {
        return;
      }
      const nextErrors = this.__validationErrors.filter((item) => normalizeFieldAlias(item.id) !== normalized);
      if (nextErrors.length !== this.__validationErrors.length) {
        this.__validationErrors = nextErrors;
      }
    },
    getValidationError(fieldName) {
      const normalized = normalizeFieldAlias(fieldName);
      const errorItem = this.__validationErrors.find((item) => isMatchingError(item, normalized));
      return errorItem?.message || "";
    },
    hasValidationError(fieldName) {
      return this.getValidationError(fieldName) !== "" || this.__validationErrors.some((item) => isMatchingError(item, fieldName));
    },
    hasValidationErrorsIn(scopeOrField) {
      const normalized = normalizeFieldAlias(scopeOrField);
      if (!normalized) {
        return this.hasAnyValidationError;
      }
      return this.__validationErrors.some((item) => isMatchingError(item, normalized));
    },
    resetValidation(scopeOrField) {
      const normalized = normalizeFieldAlias(scopeOrField);
      if (!normalized) {
        if (this.__validationErrors.length > 0) {
          this.__validationErrors = [];
        }
        return;
      }
      const nextErrors = this.__validationErrors.filter((item) => {
        if (normalizeFieldAlias(item.scope) === normalized) {
          return false;
        }
        if (isMatchingError(item, normalized)) {
          return false;
        }
        return true;
      });
      if (nextErrors.length !== this.__validationErrors.length) {
        this.__validationErrors = nextErrors;
      }
    },
    async validateField(fieldName, value) {
      const meta = this.resolveValidationField(fieldName);
      if (!meta) {
        return true;
      }
      // validateField(name)
      const actualValue = arguments.length > 1
        ? value
        : this.resolveValidationValue(fieldName);
      const result = runValidationRules(meta.rules, actualValue, {
        fieldName: meta.fieldName,
        label: meta.label,
        scope: meta.scope,
        customRules: this.__validationCustomRules,
        resolveFieldValue: (otherFieldName) => this.resolveValidationValue(otherFieldName)
      });
      if (result.valid) {
        this.clearValidationError(meta.fullName);
      } else {
        this.pushValidationError({
          id: meta.id,
          field: meta.fieldName,
          fullName: meta.fullName,
          scope: meta.scope,
          message: result.message,
          source: "rule"
        });
      }
      return result.valid;
    },
    async validateAllFields(scopeOrField = "") {
      const normalized = normalizeFieldAlias(scopeOrField);
      const entries = Object.values(this.__validationFields).filter((meta) => {
        if (!normalized) {
          return true;
        }
        return resolveAliases(meta).some((alias) => alias === normalized || alias.startsWith(`${normalized}.`));
      });
      const results = await Promise.all(entries.map((meta) => this.validateField(meta.fullName)));
      return results.every(Boolean);
    }
  }
};
