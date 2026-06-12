/**
 * Vuex - Store 定義（患者イベント用Module分割取りまとめ）
 */
import PatEventListStore from "@/stores/pat-event/PatEventStore";
import PatEventDetailStore from "@/stores/pat-event/PatEventDetailStore";
import PatEventImageViewerStore from "@/stores/pat-event/PatEventImageViewerStore";
import PatEventImageEditorStore from "@/stores/pat-event/PatEventImageEditorStore";

export const PAT_EVENT_STORES = {
  "pat-event": {
    namespaced: true,
    modules: {
      list: PatEventListStore,
      detail: PatEventDetailStore,
      viewer: PatEventImageViewerStore,
      "image-editor": PatEventImageEditorStore
    }
  }
};
