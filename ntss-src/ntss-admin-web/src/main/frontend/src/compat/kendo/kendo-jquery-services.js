import { ensureJQueryKendo } from "@/compat/kendo/kendo-jquery.js";

export async function prepareKendoJQueryServices() {
  return await ensureJQueryKendo();
}

export {
  createJQueryDataSource,
  isJQueryDataSource,
  createJQueryValidator,
  getJQueryValidator,
  destroyJQueryValidator,
  mountJQueryQrCode,
  getJQueryQrCode,
  destroyJQueryQrCode,
  setKendoProgress
} from "@/compat/kendo/kendo-jquery.js";

export {
  getNativeWidget,
  destroyNativeWidget
} from "@/compat/kendo/native-widgets.js";
