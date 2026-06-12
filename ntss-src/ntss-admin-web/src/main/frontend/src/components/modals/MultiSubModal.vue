<template>
  <component :is="getModalName" v-if="isModalOpened" />
</template>

<script>
import { mapGetters } from "@/compat/vue/vuex";
import DeviceSetInfoSubModal from "@/components/deviceset-info/base-modules/DeviceSetInfoSubModal";
import ComplaintCreate from "@/components/treatment-record/submenu/complaint/modal/ComplaintCreateModalComponent";
import AddressSearch from "@/components/pat-info/address-search/AddressSearch.vue";
import ShrPatSearch from "@/components/pat-info-sharing/detail/SharingDetailPatSearchModal";
// add FNSI-水質検査結果登録で備考欄を追加する 周 start
// 水質検査結果備考登録
import WaterResultMemoEditSubModal from "@/components/water-quality-survey/modal/WaterResultMemoEditSubModalComponent";
// add FNSI-水質検査結果登録で備考欄を追加する 周 end
// 標準医薬品マスタ検索
import SysMedicineSearchSubModal from "@/components/master-maintenance/mst-medicine/modal/SysMedicineSearchSubModalComponent";
// add IES 臨床検査マスタ検索追加する Du start
// 臨床検査マスタ検索
import MstExamMatomeSearchSubModal from "@/components/master-maintenance/mst-exam-item/modal/MstExamMatomeSearchSubModalComponent";
// add IES 臨床検査マスタ検索追加する Du end
// 帳票グラフ設定
import ReportGraphSettingSubModal from "@/components/master-maintenance/mst-treatment/modal/ReportGraphSettingSubModalComponent"
//add FNSI修正486改修 房 start
import ResultMergePatSearchModal from "@/components/treatment-record/submenu/result-merge/modal/ResultMergePatSearchComponent";
//add FNSI修正486改修 房 end
// FNSI-add 除外期間の追加 徐 start
import PatExcludedPeriod from "@/components/pat-viewer/modal/PatExcludedPeriodComponent";
// FNSI-add 除外期間の追加 徐 end
import PatPrescriptionSelectDrugModal from "@/components/pat-prescription/modal/PatPrescriptionSelectDrugModal";

export default {
  name: "MultiSubModal",
  components: {
    DeviceSetInfoSubModal,
    ComplaintCreate,
    AddressSearch,
    ShrPatSearch,
    // add FNSI-水質検査結果登録で備考欄を追加する 周 start
    // 水質検査結果備考登録
    WaterResultMemoEditSubModal,
    // add FNSI-水質検査結果登録で備考欄を追加する 周 end
    // 標準医薬品マスタ検索
    SysMedicineSearchSubModal,
    // add IES 臨床検査マスタ検索追加する Du start
    // 臨床検査マスタ検索
    MstExamMatomeSearchSubModal,
    // add IES 臨床検査マスタ検索追加する Du end
    // 帳票グラフ設定
    ReportGraphSettingSubModal,
    //add FNSI修正486改修 房 start
    ResultMergePatSearchModal,
    //add FNSI修正486改修 房 end
    // FNSI-add 除外期間の追加 徐 start
    PatExcludedPeriod,
    // FNSI-add 除外期間の追加 徐 end
    PatPrescriptionSelectDrugModal
  },
  computed: {
    ...mapGetters("multi-sub-modal", ["isModalOpened", "getModalName"])
  }
};
</script>
