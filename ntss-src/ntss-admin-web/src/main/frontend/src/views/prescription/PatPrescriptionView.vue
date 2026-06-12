<!-- 処方箋 -->
<template>
  <ntss-layout>
    <template #header-content>
      <header-component />
    </template>
    <template #bread-crumbs-content>
      <bread-crumbs-component :history-key="historyKey" :no-split="true" @refresh='refresh' />
    </template>
    <template #main-content>
      <main-component ref='mainComponent' :history-key="historyKey" />
    </template>
  </ntss-layout>
</template>

<script>
import HeaderComponent from "@/components/header-contents/PatHeader";
import MainComponent from "@/components/pat-prescription/PatPrescriptionMainComponent";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import ViewHelper from "@/views/ViewHelperMixin";
import { HISTORY_KEY_PRESCRIPTION_DETAIL } from "@/router/prescription/HistoryKeyConstants";
// //FNSI-横展開管理台帳_日機装FNSI NO.15 劉全航 start
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
import {mapActions, mapGetters, mapMutations} from "@/compat/vue/vuex";
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end
// //FNSI-横展開管理台帳_日機装FNSI NO.15 劉全航 end
// // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from '@/functions/common/MessageFormat';
// // mod #6107 2023/03/23 メッセージボックス全調整 張博 end

export default {
  name: "PrescriptionListView",
  components: {
    "header-component": HeaderComponent,
    "main-component": MainComponent,
    "bread-crumbs-component": BreadCrumbsComponent
  },
  mixins: [ViewHelper],
  // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_処方 20231124 ztc start
  beforeRouteLeave(to, from, next) {
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
    // if (this.$refs.mainComponent && this.$refs.mainComponent.selectedPatId) {
    if (this.$refs.mainComponent && (this.$refs.mainComponent.selectedPatId || !!this.isPatInfoChaned)) {
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end
      if(this.$refs.mainComponent.isChanged){
        this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "内容破棄",
          title: DIALOG_MESSAGES[13000004].title,
          // message: "編集内容が破棄されます。</br>よろしいですか？",
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
          buttonLabels: ["Cancel", "OK"],
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
          callback: answer => {
            //FNSI-横展開管理台帳_日機装FNSI NO.15 劉全航 start
            //next(answer === 1);
            if(answer === 1){
              this.setOriginalEditRecord([]);
              this.setEditRecord([]);
              this.setIsInputModalChanged(false);
              this.setIsDoctorChanged(false);
              // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
              this.setIsPatInfoChaned(false);
              // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end
              next()
            } else {
              next(false);
            }
            //FNSI-横展開管理台帳_日機装FNSI NO.15 劉全航 end
          }
        });
      } else {
        next();
      }
    } else {
      next();
    }
  },
  // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_処方 20231124 ztc end
  data() {
    return {
      historyKey: HISTORY_KEY_PRESCRIPTION_DETAIL
    };
  },
  // //FNSI-横展開管理台帳_日機装FNSI NO.15 劉全航 start
  // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
  computed: {
    ...mapGetters("pat-info", ["isPatInfoChaned"]),
  },
  // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end
  // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_処方 20231124 ztc start
  methods: {
    ...mapActions("pat-prescription",[
      "setOriginalEditRecord",
      "setEditRecord",
      "setIsInputModalChanged",
      "setIsDoctorChanged"
      ]),
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
    ...mapMutations("pat-info", ["setIsPatInfoChaned"]),
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end
  }
  // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_処方 20231124 ztc end
  //FNSI-横展開管理台帳_日機装FNSI NO.15 劉全航 end
};
</script>
