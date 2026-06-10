/**
 * Vuex - Store 定義（モーダル画面用Module分割取りまとめ）
 */

import MultiModalStore from "@/stores/modals/MultiModalStore";
import AccountEditStore from "@/stores/modals/AccountEditStore";
import StaffFacilityStore from "@/stores/modals/StaffFacilityStore";
import MstSynchroStore from "@/stores/modals/MstSynchroStore";
import MstFacilityStore from "@/stores/modals/menu-bar/MstFacilityStore";
import PersonalSettingStore from "@/stores/modals/PersonalSettingStore";
import NotificationMessageStore from "@/stores/modals/NotificationMessageStore";
import DeviceSetInfoModalStore from "@/stores/modals/DeviceSetInfoModalStore";
import MultiSubModalStore from "@/stores/modals/MultiSubModalStore";
// 標準医薬品マスタ検索用モーダルのStore
import SysMedicineSubModalStore from "@/stores/modals/SysMedicineSubModalStore";
import ReleaseInfoStore from "@/stores/modals/ReleaseInfoStore";
import MstExamMatomeStore from "@/stores/modals/MstExamMatomeStore";

export const MODALS_STORES = {
  "account-edit": AccountEditStore,
  "staff-facility": StaffFacilityStore,
  "multi-modal": MultiModalStore,
  "mst-synchro": MstSynchroStore,
  "modal/mst-facility": MstFacilityStore,
  "personal-setting": PersonalSettingStore,
  "notification-message": NotificationMessageStore,
  "device-set-info-modal": DeviceSetInfoModalStore,
  "multi-sub-modal": MultiSubModalStore,
  "sys-medicine-sub-modal": SysMedicineSubModalStore,
  "release-info": ReleaseInfoStore,
  "mst-exam-matome": MstExamMatomeStore,
};
