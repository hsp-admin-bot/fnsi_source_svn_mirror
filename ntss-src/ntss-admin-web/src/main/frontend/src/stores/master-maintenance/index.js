/**
 * Vuex - Store 定義（マスタメンテナンス用Module分割取りまとめ）
 */
import MasterMaintenanceStore from "@/stores/master-maintenance/MasterMaintenanceStore";
import MstWeightScaleStore from "@/stores/master-maintenance/mst-weight/MstWeightScaleStore";
import MstWeightStore from "@/stores/master-maintenance/mst-weight/MstWeightStore";
import MstDestinationGroupStore from "@/stores/master-maintenance/MstDestinationGroupStore";
import MstAlarmNotificationStore from "@/stores/master-maintenance/MstAlarmNotificationStore";
import MstMachineStore from "@/stores/master-maintenance/MstMachineStore";
import MstChecklistStore from "@/stores/master-maintenance/MstChecklistStore";
import CheckGraphSettingStore from "@/stores/master-maintenance/mst-comsv-setting/MstCheckGraphSettingStore";
import MstComsvSettingStore from "@/stores/master-maintenance/MstComsvSettingStore";
import MstTreatmentStatusLayoutStore from "@/stores/master-maintenance/mst-treatment-status-layout/MstTreatmentStatusLayoutStore";
import MstUserStore from "@/stores/master-maintenance/MstUserStore";
import MstStatusMapBedLayoutStore from "@/stores/master-maintenance/MstStatusMapBedLayoutStore";
import MstWheelChairStore from "@/stores/master-maintenance/MstWheelChairStore";
import ComplaintStore from "@/stores/master-maintenance/MstComplaintStore";
import MstBedStore from "@/stores/master-maintenance/MstBedStore";
import MstFacilitySettingStore from "@/stores/master-maintenance/MstFacilitySettingStore";
import MstJobStore from "@/stores/master-maintenance/MstJobStore";
import MstPatEventTemplateStore from "@/stores/master-maintenance/mst-pat-event-template/MstPatEventTemplateStore";
import MstExamItemStore from "@/stores/master-maintenance/MstExamItemStore";
import MstFacilityStore from "@/stores/master-maintenance/MstFacilityStore";
import MstFavoriteFacilityStore from "@/stores/master-maintenance/MstFavoriteFacilityStore";
import MstMenteLayoutStore from "@/stores/master-maintenance/MstMenteLayoutStore";
import MstGraphSettingStore from "@/stores/master-maintenance/MstGraphSettingStore";
import MstSelfMeasureResultStore from "@/stores/master-maintenance/MstSelfMeasureResultStore";
import MstKurStore from "@/stores/master-maintenance/MstKurStore";
import MstHolidayStore from "@/stores/master-maintenance/MstHolidayStore";
import SysApplicationStore from "@/stores/master-maintenance/SysApplicationStore";
import MstMenuGroupStore from "@/stores/master-maintenance/MstMenuGroupStore";

export const MASTER_MAINTENANCE_STORES = {
  "master-maintenance": MasterMaintenanceStore,
  "mst-weight-scale": MstWeightScaleStore,
  "mst-weight": MstWeightStore,
  "mst-destination-group": MstDestinationGroupStore,
  "mst-machine": MstMachineStore,
  "mst-checklist": MstChecklistStore,
  "mst-com-sv-setting": MstComsvSettingStore,
  "mst-check-graph": CheckGraphSettingStore,
  "mst-alarm-notification": MstAlarmNotificationStore,
  "mst-treatment-status-layout": MstTreatmentStatusLayoutStore,
  "mst-user": MstUserStore,
  "mst-status-map-bed-layout": MstStatusMapBedLayoutStore,
  "mst-wheel-chair": MstWheelChairStore,
  "mst-complaint": ComplaintStore,
  "mst-bed": MstBedStore,
  "mst-facility-setting": MstFacilitySettingStore,
  "mst-job": MstJobStore,
  "mst-pat-event-template": MstPatEventTemplateStore,
  "mst-exam-item": MstExamItemStore,
  "mst-facility": MstFacilityStore,
  "mst-favorite-facility": MstFavoriteFacilityStore,
  "mst-layout" : MstMenteLayoutStore,
  "mst-graph-setting": MstGraphSettingStore,
  "mst-self-measure-result": MstSelfMeasureResultStore,
  "mst-kur":MstKurStore,
  "mst-holiday":MstHolidayStore,
  "sys-application": SysApplicationStore,
  "mst-menu-group":MstMenuGroupStore,
};
