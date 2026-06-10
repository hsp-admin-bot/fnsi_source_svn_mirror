/**
 * 治療記録用ルーティング設定
 */
// 機能名
import {
  FUNC_TREATMENT_RECORD_JPN_NAME,
  FUNC_TREATMENT_RECORD_RESULT_JPN_NAME,
  FUNC_TREATMENT_RECORD_VITAL_JPN_NAME,
  FUNC_TREATMENT_RECORD_MONITOR_JPN_NAME,
  FUNC_TREATMENT_RECORD_COMPLAINT_JPN_NAME,
  FUNC_TREATMENT_RECORD_WEIGHT_JPN_NAME,
  FUNC_TREATMENT_RECORD_CONDITION_JPN_NAME,
  FUNC_TREATMENT_RECORD_MEDICINE_JPN_NAME,
  FUNC_TREATMENT_RECORD_EQUIPMENT_JPN_NAME,
  FUNC_TREATMENT_RECORD_ADDITION_JPN_NAME,
  FUNC_TREATMENT_RECORD_SETTING_JPN_NAME,
  FUNC_TREATMENT_RECORD_ROUND_JPN_NAME,
  FUNC_TREATMENT_RECORD_OBSERVATION_JPN_NAME,
  FUNC_TREATMENT_RECORD_BVMS_JPN_NAME,
  FUNC_TREATMENT_RECORD_ADDITION_INFO_JPN_NAME
} from "@/constants/function-code";
// パンくず特定キー
import {
  HISTORY_KEY_TREATMENT_RECORD_TREATMENT,
  HISTORY_KEY_TREATMENT_RECORD_RESULT,
  HISTORY_KEY_TREATMENT_RECORD_VITAL,
  HISTORY_KEY_TREATMENT_RECORD_MONITOR,
  HISTORY_KEY_TREATMENT_RECORD_COMPLAINT,
  HISTORY_KEY_TREATMENT_RECORD_WEIGHT,
  HISTORY_KEY_TREATMENT_RECORD_CONDITION,
  HISTORY_KEY_TREATMENT_RECORD_MEDICINE,
  HISTORY_KEY_TREATMENT_RECORD_EQUIPMENT,
  HISTORY_KEY_TREATMENT_RECORD_ADDITION,
  HISTORY_KEY_TREATMENT_RECORD_SETTING,
  HISTORY_KEY_TREATMENT_RECORD_ROUND,
  HISTORY_KEY_TREATMENT_RECORD_OBSERVATION,
  HISTORY_KEY_TREATMENT_RECORD_BVMS,
  HISTORY_KEY_TREATMENT_RECORD_ADDITION_INFO
} from "@/router/treatment-record/HistoryKeyConstants";

// 治療記録（親画面）
import TreatmentRecordView from "@/views/treatment-record/TreatmentRecordView";
import ResultComponent from "@/components/treatment-record/submenu/result/ResultComponent";
import VitalComponent from "@/components/treatment-record/submenu/vital/VitalComponent";
import MonitorComponent from "@/components/treatment-record/submenu/monitor/MonitorComponent";
import BvmsComponent from "@/components/treatment-record/submenu/bvms/BvmsComponent";
import ComplaintComponent from "@/components/treatment-record/submenu/complaint/ComplaintComponent";
import WeightComponent from "@/components/treatment-record/submenu/weight/WeightComponent";
import ConditionComponent from "@/components/treatment-record/submenu/condition/ConditionComponent";
import MedicineComponent from "@/components/treatment-record/submenu/medicine/MedicineComponent";
import EquipmentComponent from "@/components/treatment-record/submenu/equipment/EquipmentComponent";
import AdditionComponent from "@/components/treatment-record/submenu/addition/AdditionComponent";
import SettingComponent from "@/components/treatment-record/submenu/setting/SettingComponent";
import RoundComponent from "@/components/treatment-record/submenu/round/RoundComponent";
import ObservationComponent from "@/components/treatment-record/submenu/observation/ObservationComponent";
import AdditionInfoComponent from "@/components/treatment-record/submenu/addition-info/AdditionInfoComponent";

const RESULT = {
  path: "result",
  name: "treatment-record-result",
  component: ResultComponent,
  meta: {
    title: FUNC_TREATMENT_RECORD_RESULT_JPN_NAME,
    depth: 2,
    historyKey: HISTORY_KEY_TREATMENT_RECORD_RESULT
  }
};
const VITAL = {
  path: "vital",
  name: "treatment-record-vital",
  component: VitalComponent,
  meta: {
    title: FUNC_TREATMENT_RECORD_VITAL_JPN_NAME,
    depth: 2,
    historyKey: HISTORY_KEY_TREATMENT_RECORD_VITAL
  }
};
const MONITOR = {
  path: "monitor",
  name: "treatment-record-monitor",
  component: MonitorComponent,
  meta: {
    title: FUNC_TREATMENT_RECORD_MONITOR_JPN_NAME,
    depth: 2,
    historyKey: HISTORY_KEY_TREATMENT_RECORD_MONITOR
  }
};
const BVMS = {
  path: "bvms",
  name: "Bvms",
  component: BvmsComponent,
  meta: {
    title: FUNC_TREATMENT_RECORD_BVMS_JPN_NAME,
    depth: 2,
    historyKey: HISTORY_KEY_TREATMENT_RECORD_BVMS
  }
};
const COMPLAINT = {
  path: "complaint",
  name: "treatment-record-complaint",
  component: ComplaintComponent,
  meta: {
    title: FUNC_TREATMENT_RECORD_COMPLAINT_JPN_NAME,
    depth: 2,
    historyKey: HISTORY_KEY_TREATMENT_RECORD_COMPLAINT
  }
};
const WEIGHT = {
  path: "weight",
  name: "treatment-record-weight",
  component: WeightComponent,
  props: true,
  meta: {
    title: FUNC_TREATMENT_RECORD_WEIGHT_JPN_NAME,
    depth: 2,
    historyKey: HISTORY_KEY_TREATMENT_RECORD_WEIGHT
  }
};
const CONDITION = {
  path: "condition",
  name: "treatment-record-condition",
  component: ConditionComponent,
  meta: {
    title: FUNC_TREATMENT_RECORD_CONDITION_JPN_NAME,
    depth: 2,
    historyKey: HISTORY_KEY_TREATMENT_RECORD_CONDITION
  }
};
const MEDICINE = {
  path: "medicine",
  name: "treatment-record-medicine",
  component: MedicineComponent,
  meta: {
    title: FUNC_TREATMENT_RECORD_MEDICINE_JPN_NAME,
    depth: 2,
    historyKey: HISTORY_KEY_TREATMENT_RECORD_MEDICINE
  }
};
const EQUIPMENT = {
  path: "equipment",
  name: "treatment-record-equipment",
  component: EquipmentComponent,
  meta: {
    title: FUNC_TREATMENT_RECORD_EQUIPMENT_JPN_NAME,
    depth: 2,
    historyKey: HISTORY_KEY_TREATMENT_RECORD_EQUIPMENT
  }
};
const ADDITION = {
  path: "addition",
  name: "treatment-record-addition",
  component: AdditionComponent,
  meta: {
    title: FUNC_TREATMENT_RECORD_ADDITION_JPN_NAME,
    depth: 2,
    historyKey: HISTORY_KEY_TREATMENT_RECORD_ADDITION
  }
};
const SETTING = {
  path: "setting",
  name: "treatment-record-setting",
  component: SettingComponent,
  meta: {
    title: FUNC_TREATMENT_RECORD_SETTING_JPN_NAME,
    depth: 2,
    historyKey: HISTORY_KEY_TREATMENT_RECORD_SETTING
  }
};
const ROUND = {
  path: "round",
  name: "treatment-record-round",
  component: RoundComponent,
  meta: {
    title: FUNC_TREATMENT_RECORD_ROUND_JPN_NAME,
    depth: 2,
    historyKey: HISTORY_KEY_TREATMENT_RECORD_ROUND
  }
};
const OBSERVATION = {
  path: "observation",
  name: "treatment-record-observation",
  component: ObservationComponent,
  meta: {
    title: FUNC_TREATMENT_RECORD_OBSERVATION_JPN_NAME,
    depth: 2,
    historyKey: HISTORY_KEY_TREATMENT_RECORD_OBSERVATION
  }
};
const ADDITION_INFO = {
  path: "addition-info",
  name: "treatment-record-addition-info",
  component: AdditionInfoComponent,
  meta: {
    title: FUNC_TREATMENT_RECORD_ADDITION_INFO_JPN_NAME,
    depth: 2,
    historyKey: HISTORY_KEY_TREATMENT_RECORD_ADDITION_INFO
  }
};
/*add FNSI-bug6119 観察記録画面Out of memoryの問題 史 start*/
// 詳細
import ObserveRecordDetailView from "@/views/observe-record/ObserveRecordDetailView";
const OBSERVE_DETAIL = {
  path: "treatment-observe-detail",
  name: "treatment-observe-detail",
  component: ObserveRecordDetailView,
  meta: {
    title: '観察記録詳細',
    depth: 3,
    historyKey: "DETAIL"
  }
};
/*add FNSI-bug6119 観察記録画面Out of memoryの問題 史 end*/
const TREATMENT_RECORD = {
  path: "list",
  name: "treatment-record",
  component: TreatmentRecordView,
  meta: {
    title: FUNC_TREATMENT_RECORD_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_TREATMENT_RECORD_TREATMENT
  },
  children: [
    ROUND,      // 回診記録
    BVMS,     // BVMS
    RESULT,     // 実績情報
    VITAL,      // バイタル
    MONITOR,    // モニタ
    COMPLAINT,  // 愁訴処置
    OBSERVATION,// 観察記録
    WEIGHT,     // 体重
    CONDITION,  // 治療条件
    MEDICINE,   // 投与薬剤
    EQUIPMENT,  // 医療材料
    ADDITION,   // 指示コメント
    SETTING,    // 装置設定
    ADDITION_INFO,
    /*add FNSI-bug6119 観察記録画面Out of memoryの問題 史 start*/
    OBSERVE_DETAIL
    /*add FNSI-bug6119 観察記録画面Out of memoryの問題 史 end*/
  ]
};

export { ROUND }
/* ----- マスタメンテナンス ルーティング設定 ------- */
export default [TREATMENT_RECORD];
