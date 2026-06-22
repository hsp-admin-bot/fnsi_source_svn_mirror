import * as KendoVueForm from "@progress/kendo-vue-form";
import { Error as KendoLabelsError } from "@progress/kendo-vue-labels";

export const KendoVueFormCompat = KendoVueForm;
export const KendoForm = KendoVueForm.Form;
export const KendoField = KendoVueForm.Field;
export const KendoFormElement = KendoVueForm.FormElement;
export const KendoFormError = KendoLabelsError;

export function installKendoValidatorWrapper(app) {
  const components = {
    "kendo-form": KendoForm,
    "kendo-field": KendoField,
    "kendo-form-element": KendoFormElement,
    "kendo-form-error": KendoFormError
  };
  Object.entries(components).forEach(([name, component]) => {
    if (component) {
      app?.component?.(name, component);
    }
  });
}

export default {
  install: installKendoValidatorWrapper,
  ...KendoVueFormCompat,
  Error: KendoFormError,
  KendoFormError
};
