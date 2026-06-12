import { withModelModifierHandler } from "@/compat/vue/model.js";

export function normalizeOnsInputAttrs(attrs = {}) {
  const forwardedAttrs = withModelModifierHandler(attrs);
  const inputId = forwardedAttrs.inputId
    ?? forwardedAttrs.inputid
    ?? forwardedAttrs["input-id"]
    ?? forwardedAttrs.selectId
    ?? forwardedAttrs.selectid
    ?? forwardedAttrs["select-id"];
  if (inputId !== undefined) {
    forwardedAttrs["input-id"] = inputId;
  }
  delete forwardedAttrs.inputId;
  delete forwardedAttrs.inputid;
  delete forwardedAttrs.selectId;
  delete forwardedAttrs.selectid;
  delete forwardedAttrs["select-id"];
  return forwardedAttrs;
}
