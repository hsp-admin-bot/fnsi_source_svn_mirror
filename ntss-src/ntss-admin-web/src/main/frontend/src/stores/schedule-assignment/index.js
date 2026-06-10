/**
 * Vuex - Store 定義
 */
import ScheduleAssignmentModalStore from "@/stores/schedule-assignment/ScheduleAssignmentModalStore";

export const SCHEDULE_ASSIGNMENT_STORES = {
  "schedule-assignment": {
    namespaced: true,
    modules: {
      modal: ScheduleAssignmentModalStore
    }
  }
};
