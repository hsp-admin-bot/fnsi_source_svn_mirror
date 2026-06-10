/**
 * Vuex - Store 定義（患者経過総合ビューア用Module分割取りまとめ）
 */
import PatViewerStore from "@/stores/pat-viewer/PatViewerStore";
import PatViewerModalStore from "@/stores/pat-viewer/PatViewerModalStore";
import PatViewerPopoverStore from "@/stores/pat-viewer/PatViewerPopoverStore";
import PatViewerTreatCondStore from "@/stores/pat-viewer/PatViewerTreatCondStore";

export const PAT_VIEWER_STORES = {
  "pat-viewer": PatViewerStore,
  "pat-viewer-modal": PatViewerModalStore,
  "pat-viewer-popover": PatViewerPopoverStore,
  "pat-viewer-treat-cond": PatViewerTreatCondStore
};
