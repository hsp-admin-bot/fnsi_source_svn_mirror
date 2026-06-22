/**
 * Vuex - Store 定義（治療記録用Module分割取りまとめ）
 */
import TreatmentRecordStore from "@/stores/treatment-record/TreatmentRecordStore";
import GridSizeStore from "@/stores/treatment-record/GridSizeStore";
import ResultStore from "@/stores/treatment-record/ResultStore";
import MediInfoStore from "@/stores/treatment-record/MediInfoStore";
import ConditionStore from "@/stores/treatment-record/ConditionStore";
import WeightStore from "@/stores/treatment-record/WeightStore";
import BvmsStore from "@/stores/treatment-record/BvmsStore";
import EquipInfoStore from "@/stores/treatment-record/EquipInfoStore";
import AdditionStore from "@/stores/treatment-record/AdditionStore";
import VitalStore from "@/stores/treatment-record/VitalStore";
import MonitorStore from "@/stores/treatment-record/MonitorStore";
import ComplaintStore from "@/stores/treatment-record/ComplaintStore";
import SettingStore from "@/stores/treatment-record/SettingStore";
import RoundsInfoStore from "@/stores/treatment-record/RoundsInfoStore";
import ResultMergeStore from "@/stores/treatment-record/ResultMergeStore";
import OfflineResultMergeStore from "@/stores/treatment-record/OfflineResultMergeStore";

export const TREATMENT_RECORD_STORES = {
  "treatment-record": {
    namespaced: true,
    modules: {
      common: TreatmentRecordStore,
      "grid-size": GridSizeStore,
      result: ResultStore,
      mediInfo: MediInfoStore,
      condition: ConditionStore,
      weight: WeightStore,
      bvms: BvmsStore,
      equipInfo: EquipInfoStore,
      addition: AdditionStore,
      vital: VitalStore,
      monitor: MonitorStore,
      complaint: ComplaintStore,
      setting: SettingStore,
      roundsInfo: RoundsInfoStore,
      "result-merge": ResultMergeStore,
      offlineResultMerge: OfflineResultMergeStore
    }
  }
};
