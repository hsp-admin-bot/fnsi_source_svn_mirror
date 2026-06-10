/** * マスタメンテナンス 個別ページ */
<template>
  <ntss-layout>
    <header-component :is="current_header" slot="header-content" />
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start -->
    <!-- <bread-crumbs-component
      slot="bread-crumbs-content"
      :history-key="historyKey"
      :no-split=true
      @refresh="refresh"
    /> -->
    <bread-crumbs-component
      slot="bread-crumbs-content"
      :history-key="historyKey"
      :no-split=true
    />
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end -->
    <main-component
      :is="current_main"
      slot="main-content"
      ref="mainComponent"
      :history-key="historyKey"
    />
  </ntss-layout>
</template>

<script>
import { mapGetters } from "vuex";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import ViewHelper from "@/views/ViewHelperMixin";
import { HISTORY_KEY_MASTER_MAINTENANCE_RECORD } from "@/router/master-maintenance/HistoryKeyConstants";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
// mod #6107 2023/03/23 メッセージボックス全調整 張博 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from '@/functions/common/MessageFormat';
// mod #6107 2023/03/23 メッセージボックス全調整 張博 end

export default {
  name: "IndividualMasterView",
  components: {
    // --------------------------------------
    // 個々のページのImportをここで行なってください
    // 要素名は下記にしてください（要素名はケバブケースで記載してください。（mst_hoge → mst-hoge））
    //   Mainページ：テーブル論理名（例：mst_hoge）
    //     "mst-hoge": () => import("@/components/master-maintenance/MasterComponentMstHoge")
    //   Headerページ：テーブル論理名＋_header（例：mst_hoge_header）
    //     "mst-hoge-header": () => import("@/components/master-maintenance/MasterComponentMstHogeHeader")
    // --------------------------------------
    "bread-crumbs-component": BreadCrumbsComponent,
    "default-header": () =>
      import("@/components/master-maintenance/IndividualMasterHeaderComponent"),
    // (例)mst_test_mode2の独自マスタ編集用コンポーネントは以下のようにインポートします。
    // ヘッダーをインポートしない場合は、default-headerがヘッダーコンポーネントとして利用されます。
    "mst-test-mode2-header": () =>
      import("@/components/master-maintenance/mst-test-mode2/IndividualMasterComponentMstTestMode2Header"),
    "mst-test-mode2": () =>
      import("@/components/master-maintenance/mst-test-mode2/IndividualMasterComponentMstTestMode2"),
    "mst-weight": () =>
      import("@/components/master-maintenance/mst-weight/MstWeightRecordComponent"),
    "mst-weight-header": () =>
      import("@/components/master-maintenance/mst-weight/MstWeightRecordHeaderComponent"),
    "mst-machine": () =>
      import("@/components/master-maintenance/mst-machine/MstMachineMainComponent"),
    "mst-machine-header": () =>
      import("@/components/master-maintenance/mst-machine/MstMachineHeaderComponent"),
    "mst-checklist": () =>
      import("@/components/master-maintenance/mst-checklist/MstChecklistMainComponent"),
    "mst-device-set-info-default": () =>
      import("@/components/deviceset-info/DeviceSetInfoListMst.vue"),
    "mst-kur": () =>
      import("@/components/master-maintenance/mst-kur/MstKurMainComponent"),
    "mst-kur-header": () =>
      import("@/components/master-maintenance/mst-kur/MstKurHeaderComponent"),
    "mst-facility": () =>
      import("@/components/master-maintenance/mst-facility/MstFacilityMainComponent"),
    "mst-facility-header": () =>
      import("@/components/master-maintenance/mst-facility/MstFacilityHeader"),
    "mst-device-edge": () =>
      import("@/components/master-maintenance/mst-device-edge/MstDeviceEdgeMainComponent"),
    "mst-device-edge-header": () =>
      import("@/components/master-maintenance/mst-device-edge/MstDeviceEdgeHeader"),
    "mst-wheel-chair": () =>
      import("@/components/master-maintenance/mst-wheel-chair/MstWheelChairMainComponent"),
    "mst-wheel-chair-header": () =>
      import("@/components/master-maintenance/mst-wheel-chair/MstWheelChairHeaderComponent"),
    "mst-status-map-bed-layout": () =>
      import("@/components/master-maintenance/mst-status-map-bed-layout/MstStatusMapBedLayoutMainComponent"),
    "mst-status-map-bed-layout-header": () =>
      import("@/components/master-maintenance/mst-status-map-bed-layout/MstStatusMapBedLayoutHeaderComponent"),
    "mst-user-header": () =>
      import("@/components/master-maintenance/mst-user/MstUserHeaderComponent"),
    "mst-user": () =>
      import("@/components/master-maintenance/mst-user/MstUserMainComponent"),
    "mst-user-disporder-header": () =>
      import("@/components/master-maintenance/mst-user-disporder/MstUserDisporderHeaderComponent"),
    "mst-user-disporder": () =>
      import("@/components/master-maintenance/mst-user-disporder/MstUserDisporderMainComponent"),
    "mst-comsv-setting": () =>
      import("@/components/master-maintenance/mst-comsv-setting/MstComSvSettingMainComponent"),
    "mst-comsv-setting-header": () =>
      import("@/components/master-maintenance/mst-comsv-setting/MstComSvSettingHeaderComponent"),
    "mst-complaint": () =>
      import("@/components/master-maintenance/mst-complaint/MstComplaintMainComponent"),
    "mst-complaint-header": () =>
      import("@/components/master-maintenance/mst-complaint/MstComplaintHeaderComponent"),
    "mst-bed": () =>
      import("@/components/master-maintenance/mst-bed/MstBedMainComponent"),
    "mst-bed-header": () =>
      import("@/components/master-maintenance/mst-bed/MstBedHeader"),
    "mst-facility-setting": () =>
      import("@/components/master-maintenance/mst-facility-setting/MstFacilitySettingMainComponent"),
    "mst-facility-setting-header": () =>
      import("@/components/master-maintenance/mst-facility-setting/MstFacilitySettingHeaderComponent"),
    // modify #10053 start
    "mst-job": () =>
      // import("@/components/master-maintenance/mst-job/MstJobMainComponent"),
      import("@/components/master-maintenance/mst-virtual-scrollable/MasterRecordVirtualScrollableComponent"),
    "mst-job-header": () =>
      // import("@/components/master-maintenance/mst-job/MstJobHeader"),
      import("@/components/master-maintenance/mst-virtual-scrollable/MasterRecordHeaderComponentVirtualScrollable"),
    "mst-favorite-facility": () =>
      // import("@/components/master-maintenance/mst-favorite-facility/MstFavoriteFacilityMainComponent"),
      import("@/components/master-maintenance/mst-virtual-scrollable/MasterRecordVirtualScrollableComponent"),
    "mst-favorite-facility-header": () =>
      // import("@/components/master-maintenance/mst-favorite-facility/MstFavoriteFacilityHeaderComponent"),
      import("@/components/master-maintenance/mst-virtual-scrollable/MasterRecordHeaderComponentVirtualScrollable"),
    // modify #10053 end
    "sys-facility": () =>
      import("@/components/master-maintenance/sys-facility/SysFacilityMainComponent"),
    "sys-facility-header": () =>
      import("@/components/master-maintenance/sys-facility/SysFacilityHeader"),
    "mst-pat-memo": () =>
      import("@/components/master-maintenance/mst-pat-memo/MstPatMemoMainComponent"),
    "mst-pat-memo-header": () =>
      import("@/components/master-maintenance/mst-pat-memo/MstPatMemoHeader"),
    "mst-take-medicine": () =>
      import("@/components/master-maintenance/mst-take-medicine/MstTakeMedicineComponent"),
    "mst-take-medicine-header": () =>
      import("@/components/master-maintenance/mst-take-medicine/MstTakeMedicineComponentHeader"),
    "mst-graph-setting": () =>
      import("@/components/master-maintenance/mst-graph-setting/MstGraphSettingMainComponent"),
    "mst-graph-setting-header": () =>
      import("@/components/master-maintenance/mst-graph-setting/MstGraphSettingHeaderComponent"),
    //ADD 患者イベントサブカテゴリマスタ 孔s START
    "mst-pat-event-sub-category": () =>
      import("@/components/master-maintenance/mst_pat_event_sub_category/MstPatEventSubCategoryMainComponent"),
    "mst-pat-event-sub-category-header": () =>
      import("@/components/master-maintenance/mst_pat_event_sub_category/MstPatEventSubCategoryHeaderComponent"),
    //ADD 患者イベントサブカテゴリマスタ 孔s END
    //ADD 定期点検項目グループマスタ Du START
    "mst-mainte-category-header": () =>
      import("@/components/master-maintenance/mst-mainte-category/MstMainteCategoryMainHeader.vue"),
    "mst-mainte-category": () =>
      import("@/components/master-maintenance/mst-mainte-category/MstMainteCategoryMainComponent.vue"),
    //ADD 定期点検項目グループマスタ Du END
    "mst-machine-record-control": () =>
      import("@/components/master-maintenance/mst_machine_record_control/MstMachineRecordControlMainComponent"),
    "mst-machine-record-control-header": () =>
      import("@/components/master-maintenance/mst_machine_record_control/MstMachineRecordControlHeaderComponent"),
    "mst-self-measure-result": () =>
      import("@/components/master-maintenance/mst-self-measure-result/MstSelfMeasureResultMainComponent"),
    "mst-self-measure-result-header": () =>
      import("@/components/master-maintenance/mst-self-measure-result/MstSelfMeasureResultHeader"),
    "mst-function-report": () =>
      import("@/components/master-maintenance/mst_function_report/MstFunctionReportMainComponent"),
    "mst-function-report-header": () =>
      import("@/components/master-maintenance/mst_function_report/MstFunctionReportHeaderComponent"),
    // add マスタ性能の改善 孔 start
    // modify #9595 #9542、#9304、#10151仮想スクロールテーブルの再構築 start
    "mst-disease": () =>
      // import("@/components/master-maintenance/mst-virtual-scrollable/MasterRecordComponentVirtualScrollable"),
      import("@/components/master-maintenance/mst-virtual-scrollable/MasterRecordVirtualScrollableComponent"),
    "mst-disease-header": () =>
      import("@/components/master-maintenance/mst-virtual-scrollable/MasterRecordHeaderComponentVirtualScrollable"),
    "mst-medicine": () =>
      // import("@/components/master-maintenance/mst-virtual-scrollable/MasterRecordComponentVirtualScrollable"),
      import("@/components/master-maintenance/mst-virtual-scrollable/MasterRecordVirtualScrollableComponent"),
    // add redmine 6238 標準医薬品マスタでデータが表示されない 宋qy start
    // modify #9595 #9542、#9304、#10151仮想スクロールテーブルの再構築 end
    "sys-medicine": () =>
      import("@/components/master-maintenance/sys-medicine/SysMedicineMainComponent"),
    "sys-medicine-header": () =>
      import("@/components/master-maintenance/sys-medicine/SysMedicineHeader"),
    // add redmine 6238 標準医薬品マスタでデータが表示されない 宋qy end
    "mst-medicine-header": () =>
      import("@/components/master-maintenance/mst-virtual-scrollable/MasterRecordHeaderComponentVirtualScrollable"),
    // add マスタ性能の改善 孔 end
    // add #9595 #9542、#9304、#10151仮想スクロールテーブルの再構築 start
    "mst-mainte-detail": () =>
      import("@/components/master-maintenance/mst-virtual-scrollable/MasterRecordVirtualScrollableComponent"),
    "mst-mainte-detail-header": () =>
      import("@/components/master-maintenance/mst-virtual-scrollable/MasterRecordHeaderComponentVirtualScrollable"),
    // add #9595 #9542、#9304、#10151仮想スクロールテーブルの再構築 end
    // add start #10053
    "mst-exam-item": () =>
      import("@/components/master-maintenance/mst-virtual-scrollable/MasterRecordVirtualScrollableComponent"),
    "mst-exam-item-header": () =>
      import("@/components/master-maintenance/mst-virtual-scrollable/MasterRecordHeaderComponentVirtualScrollable"),
    "mst-taboo-allergy": () =>
      import("@/components/master-maintenance/mst-virtual-scrollable/MasterRecordVirtualScrollableComponent"),
    "mst-taboo-allergy-header": () =>
      import("@/components/master-maintenance/mst-virtual-scrollable/MasterRecordHeaderComponentVirtualScrollable"),
    // add end #10053
    "sys-application-header": () =>
      import("@/components/master-maintenance/sys-application/SysApplicationHeaderComponent"),
    "sys-application": () =>
      import("@/components/master-maintenance/sys-application/SysApplicationMainComponent"),
  },
  mixins: [ViewHelper],
  beforeRouteLeave(to, from, next) {
    try {
      // #10053 dou start
      // if (this.$refs.mainComponent && this.$refs.mainComponent.isChanged) {
      if (to.name != "signin" && this.$refs.mainComponent && this.$refs.mainComponent.isChanged) {
        // #10053 dou end
        this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "内容破棄",
          title: DIALOG_MESSAGES[13000004].title,
          // message: "編集内容が破棄されます。</br>よろしいですか？",
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
          callback: answer => {
            next(answer === 1);
          }
        });
      } else {
        next();
      }
    } catch (error){
      //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
      getErrorMessage('IndividualMasterView.vue','beforeRouteLeave',error);
      //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
      next();
    }
  },
  data() {
    return {
      historyKey: HISTORY_KEY_MASTER_MAINTENANCE_RECORD,
      current_header: "",
      current_main: ""
    };
  },
  computed: {
    ...mapGetters("master-maintenance", ["getMasterName"])
  },
  created() {
    const mainComponentName = this.getMasterName.replace(/_/g, "-");
    const headerComponentName = `${mainComponentName}-header`;
    // Mainの設定
    this.current_main = mainComponentName;
    // Headerの設定
    if (this.$options.components[headerComponentName]) {
      // 該当のヘッダComponentがある場合は該当ヘッダを使用
      this.current_header = headerComponentName;
    } else {
      // 該当のヘッダComponentがない場合はデフォルトヘッダを使用
      this.current_header = "default-header";
    }
  }
};
</script>
