/**
 * Vuex - Store 定義
 */
import ExamRecordStore from "@/stores/exam-record/ExamRecordStore";
import ExamRecordModalStore from "@/stores/exam-record/ExamRecordModalStore";

export const EXAM_RECORD_STORES = {
  "exam-record": {
    namespaced: true,
    modules: {
      list: ExamRecordStore,
      modal: ExamRecordModalStore,
    }
  }
};
