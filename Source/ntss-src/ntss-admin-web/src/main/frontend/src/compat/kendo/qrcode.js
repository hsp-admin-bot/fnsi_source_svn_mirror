import {
  destroyJQueryQrCode,
  getJQueryQrCode,
  mountJQueryQrCode,
  prepareKendoJQueryServices,
} from "@/compat/kendo/kendo-jquery-services.js";

export async function prepareQrCode() {
  return await prepareKendoJQueryServices();
}

export function mountQrCode(target, options = {}) {
  return mountJQueryQrCode(target, options);
}

export function getQrCode(target) {
  return getJQueryQrCode(target);
}

export function destroyQrCode(target) {
  destroyJQueryQrCode(target);
}
