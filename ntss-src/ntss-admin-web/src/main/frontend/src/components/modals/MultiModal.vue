<template>
  <component :is="getModalName" v-if="isModalOpened" />
</template>

<script>
import { mapGetters } from "vuex";
import AccountEdit from "@/views/modals/AccountEditView";
import MenuBarEdit from "@/views/modals/MenuBarEditView";
import StaffFacility from "@/views/modals/StaffFacilityView";
import MstSynchro from "@/views/modals/MstSynchroView";
import MasterEdit from "@/views/master-maintenance/MasterEditModal";
import PatSearch from "@/components/send-condition/PatSearchModal";
import ShrPatEdit from "@/components/pat-info-sharing/detail/SharingDetailPatEditModal";
import MstComplaintEdit from "@/components/master-maintenance/mst-complaint/modal/MstComplaintModalComponent";
import MstCompTreatmentEdit from "@/components/master-maintenance/mst-complaint/modal/MstCompTreatmentModalComponent";
import Oxygen from "@/components/treatment-record/submenu/complaint/modal/OxygenModalComponent";
import ComplaintEdit from "@/components/treatment-record/submenu/complaint/modal/ComplaintEditModalComponent";
import ComplaintCreate from "@/components/treatment-record/submenu/complaint/modal/ComplaintCreateModalComponent";
import BvmsGraphCommentCreate from "@/components/treatment-record/submenu/bvms/modal/BvmsGraphCommentCreateModalComponent";
import TareWaterEdit from "@/components/send-condition/TareWaterEditModal";
import ChecklistEdit from "@/views/master-maintenance/mst-checklist/ChecklistEditModal";
import Checklist from "@/components/check-list/CheckListModal";
import Medicine from "@/components/check-list/MedicineModal";
import MeasureHistory from "@/components/send-condition/MeasurementHistoryModal";
import MstWeightCheckEdit from "@/components/master-maintenance/mst-weight/sub-item/MstWeightCheckItemModal";
import TreatmentRecordWeightInput from "@/components/treatment-record/submenu/weight/modal/WeightModalComponent";
import NotAssignedSchedule from "@/components/status-map/schedule/NotAssignedScheduleModalComponent";
import ScheduleAssignment from "@/components/schedule-assignment/ScheduleAssignmentModal";
import TreatmentRecordAdditionInput from "@/components/treatment-record/submenu/addition/modal/AdditionModalComponent";
import UserMasterIdReset from "@/views/master-maintenance/mst-user/MstUserIdResetModal";
import PersonalSettings from "@/views/modals/PersonalSettingsView";
import ResultMerge from "@/components/treatment-record/submenu/result-merge/modal/ResultMergeModalComponent";
import ChangeLog from "@/components/treatment-record/submenu/change-log/modal/ChangeLogModalComponent";
import NotificationMessage from "@/views/modals/NotificationMessageView";
import ReleaseInfo from "@/views/modals/ReleaseInfoView";
import MakerNotice from "@/views/modals/MakerNoticeView";
import PrintPreview from "@/views/modals/PrintPreviewView";
import BVMSPrintPreview from "@/views/modals/BVMSPrintPreviewView";

import ExamRecordEdit from "@/components/exam-record/ExamRecordModal";
import UserMasterAuthFunction from "@/views/master-maintenance/mst-user/MstUserFunctionModal";
import FacilityMasterAuthFunction from "@/components/master-maintenance/mst-facility/MstFacilityAuthFunctionModal";
import FacilityMasterAdvancedSettings from "@/components/master-maintenance/mst-facility/MstFacilityAdvancedSettingsModal";
import UserMasterEditAuthority from "@/views/master-maintenance/mst-user/MstUserEditAuthorityModal";
import JobMasterEditAuthority from "@/components/master-maintenance/mst-job/MstJobEditAuthorityModal";
import AddressSearch from "@/components/pat-info/address-search/AddressSearch.vue";
import PhysicalInfoAddEdit from "@/components/pat-info/physical-info-card/PhysicalInfoAddEditForPatInfo";
import PhysicalInfoAddEditForPatInfo from "@/components/pat-info/physical-info-card/PhysicalInfoAddEditForPatInfo";
import InsuranceInfoAddEditModal from "@/components/pat-info/insurance-info-card/InsuranceInfoAddEditModal";
import IndHistory from "@/components/indication/IndHistoryView";
import IndSupport from "@/components/indication/IndSupportView";
import IndMedicine from "@/components/indication/IndMedicineView";
import DetailedSearch from "@/components/side-contents/DetailedSearch";
import DetailedSearch2 from "@/components/side-contents/DetailedSearch2";
import DeviceSetInfoModal from "@/components/deviceset-info/base-modules/DeviceSetInfoModal";
import IndEditModal from "@/components/pat-viewer/modal/ModalContents";

import ExamRecordGraph from "@/components/exam-record/ExamRecordGraphModal";
import MultiCalendar from "@/components/multi-calendar/MultiCalendarModal";
import HomeDialysisInstrConfirmModal from "@/components/home-dialysis-instr-confirm/HomeDialysisInstrConfirmModal";
import showDailyModal from "@/components/daily-check/DailyCheckModal";
import showMachineModal from "@/components/periodic-inspection/MachinePartsRunningComponent";
import showHistoryModal from "@/components/periodic-inspection/PeriodicHistoryModel";
import showPeriodicModal from "@/components/periodic-inspection/PeriodicInspectionModal";
import PeriodicCalendarModal from "@/components/periodic-inspection/PeriodicCalendarModal";
import ExternalCoopModal from "@/components/external-coop/ExternalCoopModal";
import ExternalCoopDumpPathModal from "@/components/external-coop/ExternalCoopDumpPathModal";
import ExternalCoopMessageModal from "@/components/external-coop/ExternalCoopMessageModal";
import MstFavoriteFacilityModal from "@/components/master-maintenance/mst-favorite-facility/MstFavoriteFacilityEditModal";
import PrescriptionConfModal from "@/components/prescription/PrescriptionConfModalComponent";
import PrescriptionOrderModal from "@/components/prescription/PrescriptionOrderModalComponent";
import PatPrescriptionSelectDrugModal from "@/components/pat-prescription/modal/PatPrescriptionSelectDrugModal";

import ItemSettingModal from "@/components/view-log/ItemSettingModal.vue";
import WaterResultModal from "@/components/water-quality-survey/modal/WaterResultModal";
import WaterChartModal from "@/components/water-quality-survey/modal/WaterChartModal";
import ReportListModal from "@/components/pat-event/intro-letter/ReportModal";

import indicationDiffForStatusMap from "@/components/status-map/modal/IndicationDetailModalComponent";
import IndicationsHistoryModal from "@/components/indications/IndicationsHistoryModal";
import Electrocardiogram from "@/components/treatment-record/submenu/complaint/modal/ElectrocardiogramModalComponent";
import MultiDeviceEdgeManageModal from "@/components/device-edge-operation/manage/MultiDeviceEdgeManageModalComponent";
import MntFindMachineModal from "@/components/master-maintenance/mst-machine/MntFindMachineMainModalComponent";
import MstSelfMeasureResultMainModal from "@/components/master-maintenance/mst-self-measure-result/MstSelfMeasureResultMainModalComponent";
import StatusMapAlarmDetailModal from "@/components/status-map/modal/StatusMapAlarmDetailModalComponent";
import KurDoctorComponent from "@/components/master-maintenance/mst-kur/MstKurDoctorComponent";
import MstExamItemRecManagementModal from "@/components/master-maintenance/mst-exam-item/MstExamItemRecManagementModal.vue";
import MstExamItemRecBookingModal from "@/components/master-maintenance/mst-exam-item/MstExamItemRecBookingModal.vue";
import MstJobEditDefaultDispSettingModal from "@/components/master-maintenance/mst-job/MstJobEditDefaultDispSettingModal.vue";
import MstJobEditNotificationSettingModal from "@/components/master-maintenance/mst-job/MstJobEditNotificationSettingModal.vue";

export default {
  name: "MultiModal",
  components: {
    AccountEdit,
    MenuBarEdit,
    StaffFacility,
    MstSynchro,
    MasterEdit,
    PatSearch,
    MstComplaintEdit,
    MstCompTreatmentEdit,
    Oxygen,
    ComplaintEdit,
    ComplaintCreate,
    BvmsGraphCommentCreate,
    TareWaterEdit,
    Checklist,
    Medicine,
    ChecklistEdit,
    MeasureHistory,
    MstWeightCheckEdit,
    TreatmentRecordWeightInput,
    NotAssignedSchedule,
    ScheduleAssignment,
    TreatmentRecordAdditionInput,
    UserMasterIdReset,
    PersonalSettings,
    ResultMerge,
    ChangeLog,
    ExamRecordEdit,
    UserMasterAuthFunction,
    FacilityMasterAuthFunction,
    FacilityMasterAdvancedSettings,
    NotificationMessage,
    ReleaseInfo,
    MakerNotice,
    PrintPreview,
    BVMSPrintPreview,
    UserMasterEditAuthority,
    JobMasterEditAuthority,
    MstJobEditDefaultDispSettingModal,
    MstJobEditNotificationSettingModal,
    AddressSearch,
    PhysicalInfoAddEdit,
    PhysicalInfoAddEditForPatInfo,
    InsuranceInfoAddEditModal,
    IndHistory,
    IndSupport,
    IndMedicine,
    DetailedSearch,
    DetailedSearch2,
    DeviceSetInfoModal,
    IndEditModal,
    ExamRecordGraph,
    MultiCalendar,
    HomeDialysisInstrConfirmModal,
    ExternalCoopModal,
    ExternalCoopDumpPathModal,
    ExternalCoopMessageModal,
    MstFavoriteFacilityModal,
    PrescriptionConfModal,
    PrescriptionOrderModal,
    ItemSettingModal,
    showDailyModal,
    showMachineModal,
    showHistoryModal,
    showPeriodicModal,
    PeriodicCalendarModal,
    WaterResultModal,
    WaterChartModal,
    ReportListModal,
    indicationDiffForStatusMap,
    PatPrescriptionSelectDrugModal,
    IndicationsHistoryModal,
    MultiDeviceEdgeManageModal,
    MntFindMachineModal,
    MstSelfMeasureResultMainModal,
    Electrocardiogram,
    StatusMapAlarmDetailModal,
    KurDoctorComponent,
    MstExamItemRecManagementModal,
    MstExamItemRecBookingModal,
    ShrPatEdit
  },
  computed: {
    ...mapGetters("multi-modal", ["isModalOpened", "getModalName"])
  }
};
</script>
