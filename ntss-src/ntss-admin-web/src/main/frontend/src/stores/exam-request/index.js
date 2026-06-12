/**
 * Vuex - Store 定義（検査依頼用Module分割取りまとめ）
 */
import ExamRequestStore from "@/stores/exam-request/ExamRequestStore";
import ExamRequestDailyStore from "@/stores/exam-request/ExamRequestDailyStore";

export const EXAM_REQUEST_STORES = {
  "exam-request": {
    namespaced: true,
    modules: {
      list: ExamRequestStore,
      daily: ExamRequestDailyStore
    }
  }
};
