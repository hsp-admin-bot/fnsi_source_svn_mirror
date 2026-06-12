/** * マスタメンテナンス 個別ページ */
<template>
  <ntss-layout>
    <template #header-content>
      <component :is="current_header" />
    </template>
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start -->
    <!-- <bread-crumbs-component
      #bread-crumbs-content
      :history-key="historyKey"
      :no-split=true
      @refresh="refresh"
    /> -->
    <template #bread-crumbs-content>
      <bread-crumbs-component
        :history-key="historyKey"
        :no-split=true
      />
    </template>
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end -->
    <template #main-content>
      <component
        :is="current_main"
        ref="mainComponent"
        :history-key="historyKey"
      />
    </template>
  </ntss-layout>
</template>

<script>
import { mapGetters } from "@/compat/vue/vuex";
import { defineAsyncComponent } from "@/compat/vue/runtime";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import ViewHelper from "@/views/ViewHelperMixin";
import { HISTORY_KEY_MASTER_MAINTENANCE_RECORD } from "@/router/master-maintenance/HistoryKeyConstants";
import IndividualMasterHeaderComponent from "@/components/master-maintenance/IndividualMasterHeaderComponent";
import MstWheelChairMainComponent from "@/components/master-maintenance/mst-wheel-chair/MstWheelChairMainComponent";
import MstWheelChairHeaderComponent from "@/components/master-maintenance/mst-wheel-chair/MstWheelChairHeaderComponent";
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
    "default-header": IndividualMasterHeaderComponent,
    // (例)mst_test_mode2の独自マスタ編集用コンポーネントは以下のようにインポートします。
    // ヘッダーをインポートしない場合は、default-headerがヘッダーコンポーネントとして利用されます。
    "mst-test-mode2-header": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-test-mode2/IndividualMasterComponentMstTestMode2Header")),
    "mst-test-mode2": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-test-mode2/IndividualMasterComponentMstTestMode2")),
    "mst-weight": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-weight/MstWeightRecordComponent")),
    "mst-weight-header": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-weight/MstWeightRecordHeaderComponent")),
    "mst-machine": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-machine/MstMachineMainComponent")),
    "mst-machine-header": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-machine/MstMachineHeaderComponent")),
    "mst-checklist": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-checklist/MstChecklistMainComponent")),
    "mst-device-set-info-default": defineAsyncComponent(() =>
      import("@/components/deviceset-info/DeviceSetInfoListMst.vue")),
    "mst-kur": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-kur/MstKurMainComponent")),
    "mst-kur-header": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-kur/MstKurHeaderComponent")),
    "mst-facility": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-facility/MstFacilityMainComponent")),
    "mst-facility-header": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-facility/MstFacilityHeader")),
    "mst-device-edge": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-device-edge/MstDeviceEdgeMainComponent")),
    "mst-device-edge-header": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-device-edge/MstDeviceEdgeHeader")),
    "mst-wheel-chair": MstWheelChairMainComponent,
    "mst-wheel-chair-header": MstWheelChairHeaderComponent,
    "mst-status-map-bed-layout": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-status-map-bed-layout/MstStatusMapBedLayoutMainComponent")),
    "mst-status-map-bed-layout-header": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-status-map-bed-layout/MstStatusMapBedLayoutHeaderComponent")),
    "mst-user-header": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-user/MstUserHeaderComponent")),
    "mst-user": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-user/MstUserMainComponent")),
    "mst-user-disporder-header": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-user-disporder/MstUserDisporderHeaderComponent")),
    "mst-user-disporder": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-user-disporder/MstUserDisporderMainComponent")),
    "mst-comsv-setting": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-comsv-setting/MstComSvSettingMainComponent")),
    "mst-comsv-setting-header": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-comsv-setting/MstComSvSettingHeaderComponent")),
    "mst-complaint": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-complaint/MstComplaintMainComponent")),
    "mst-complaint-header": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-complaint/MstComplaintHeaderComponent")),
    "mst-bed": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-bed/MstBedMainComponent")),
    "mst-bed-header": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-bed/MstBedHeader")),
    "mst-facility-setting": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-facility-setting/MstFacilitySettingMainComponent")),
    "mst-facility-setting-header": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-facility-setting/MstFacilitySettingHeaderComponent")),
    // modify #10053 start
    "mst-job": defineAsyncComponent(() => {
      return import("@/components/master-maintenance/mst-virtual-scrollable/MasterRecordVirtualScrollableComponent");
    }),
    "mst-job-header": defineAsyncComponent(() => {
      return import("@/components/master-maintenance/mst-virtual-scrollable/MasterRecordHeaderComponentVirtualScrollable");
    }),
    "mst-favorite-facility": defineAsyncComponent(() => {
      // import("@/components/master-maintenance/mst-favorite-facility/MstFavoriteFacilityMainComponent")
      return import("@/components/master-maintenance/mst-virtual-scrollable/MasterRecordVirtualScrollableComponent");
    }),
    "mst-favorite-facility-header": defineAsyncComponent(() => {
      // import("@/components/master-maintenance/mst-favorite-facility/MstFavoriteFacilityHeaderComponent")
      return import("@/components/master-maintenance/mst-virtual-scrollable/MasterRecordHeaderComponentVirtualScrollable");
    }),
    // modify #10053 end
    "sys-facility": defineAsyncComponent(() =>
      import("@/components/master-maintenance/sys-facility/SysFacilityMainComponent")),
    "sys-facility-header": defineAsyncComponent(() =>
      import("@/components/master-maintenance/sys-facility/SysFacilityHeader")),
    "mst-pat-memo": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-pat-memo/MstPatMemoMainComponent")),
    "mst-pat-memo-header": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-pat-memo/MstPatMemoHeader")),
    "mst-take-medicine": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-take-medicine/MstTakeMedicineComponent")),
    "mst-take-medicine-header": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-take-medicine/MstTakeMedicineComponentHeader")),
    "mst-graph-setting": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-graph-setting/MstGraphSettingMainComponent")),
    "mst-graph-setting-header": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-graph-setting/MstGraphSettingHeaderComponent")),
    //ADD 患者イベントサブカテゴリマスタ 孔s START
    "mst-pat-event-sub-category": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst_pat_event_sub_category/MstPatEventSubCategoryMainComponent")),
    "mst-pat-event-sub-category-header": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst_pat_event_sub_category/MstPatEventSubCategoryHeaderComponent")),
    //ADD 患者イベントサブカテゴリマスタ 孔s END
    //ADD 定期点検項目グループマスタ Du START
    "mst-mainte-category-header": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-mainte-category/MstMainteCategoryMainHeader.vue")),
    "mst-mainte-category": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-mainte-category/MstMainteCategoryMainComponent.vue")),
    //ADD 定期点検項目グループマスタ Du END
    "mst-machine-record-control": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst_machine_record_control/MstMachineRecordControlMainComponent")),
    "mst-machine-record-control-header": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst_machine_record_control/MstMachineRecordControlHeaderComponent")),
    "mst-self-measure-result": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-self-measure-result/MstSelfMeasureResultMainComponent")),
    "mst-self-measure-result-header": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-self-measure-result/MstSelfMeasureResultHeader")),
    "mst-function-report": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst_function_report/MstFunctionReportMainComponent")),
    "mst-function-report-header": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst_function_report/MstFunctionReportHeaderComponent")),
    // add マスタ性能の改善 孔 start
    // modify #9595 #9542、#9304、#10151仮想スクロールテーブルの再構築 start
    "mst-disease": defineAsyncComponent(() => {
      return import("@/components/master-maintenance/mst-virtual-scrollable/MasterRecordVirtualScrollableComponent");
    }),
    "mst-disease-header": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-virtual-scrollable/MasterRecordHeaderComponentVirtualScrollable")),
    "mst-medicine": defineAsyncComponent(() => {
      return import("@/components/master-maintenance/mst-virtual-scrollable/MasterRecordVirtualScrollableComponent");
    }),
    // add redmine 6238 標準医薬品マスタでデータが表示されない 宋qy start
    // modify #9595 #9542、#9304、#10151仮想スクロールテーブルの再構築 end
    "sys-medicine": defineAsyncComponent(() =>
      import("@/components/master-maintenance/sys-medicine/SysMedicineMainComponent")),
    "sys-medicine-header": defineAsyncComponent(() =>
      import("@/components/master-maintenance/sys-medicine/SysMedicineHeader")),
    // add redmine 6238 標準医薬品マスタでデータが表示されない 宋qy end
    "mst-medicine-header": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-virtual-scrollable/MasterRecordHeaderComponentVirtualScrollable")),
    // add マスタ性能の改善 孔 end
    // add #9595 #9542、#9304、#10151仮想スクロールテーブルの再構築 start
    "mst-mainte-detail": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-virtual-scrollable/MasterRecordVirtualScrollableComponent")),
    "mst-mainte-detail-header": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-virtual-scrollable/MasterRecordHeaderComponentVirtualScrollable")),
    // add #9595 #9542、#9304、#10151仮想スクロールテーブルの再構築 end
    // add start #10053
    "mst-exam-item": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-virtual-scrollable/MasterRecordVirtualScrollableComponent")),
    "mst-exam-item-header": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-virtual-scrollable/MasterRecordHeaderComponentVirtualScrollable")),
    "mst-taboo-allergy": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-virtual-scrollable/MasterRecordVirtualScrollableComponent")),
    "mst-taboo-allergy-header": defineAsyncComponent(() =>
      import("@/components/master-maintenance/mst-virtual-scrollable/MasterRecordHeaderComponentVirtualScrollable")),
    // add end #10053
    "sys-application-header": defineAsyncComponent(() =>
      import("@/components/master-maintenance/sys-application/SysApplicationHeaderComponent")),
    "sys-application": defineAsyncComponent(() =>
      import("@/components/master-maintenance/sys-application/SysApplicationMainComponent")),
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
