/**
 * 検査結果一覧
 */
<template>
  <ntss-layout>
    <template #header-content>
      <header-component />
    </template>
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start -->
    <!-- <bread-crumbs-component slot='bread-crumbs-content' :history-key="historyKey" :no-split=true @refresh='refresh' /> -->
    <template #bread-crumbs-content>
      <bread-crumbs-component :history-key="historyKey" :no-split="true" />
    </template>
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end -->
    <template #main-content>
      <main-component ref="mainComponent" :history-key="historyKey" />
    </template>
  </ntss-layout>
</template>

<script>
//import HeaderComponent from "@/components/header-contents/PatHeader";
import HeaderComponent from "@/components/exam-record/ExamRecordHeader";
import MainComponent from "@/components/exam-record/ExamRecordMainFrameComponent";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import ViewHelper from "@/views/ViewHelperMixin";
// mod FutreNetWeb+SI課題管理No4114対応 趙 start
// import { HISTORY_KEY_EXAM_RECORD_LIST } from "@/router/exam-record/HistoryKeyConstants";
import { HISTORY_KEY_EXAM_RECORD_LIST, HISTORY_KEY_EXAM_RECORD_DETAIL } from "@/router/exam-record/HistoryKeyConstants";
// del #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。 linjunfeng start
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
// import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
// import {messageFormat} from "@/functions/common/MessageFormat";
// import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
// import {mapGetters, mapMutations} from "@/compat/vue/vuex";
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end
// del #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。 linjunfeng end
// mod FutreNetWeb+SI課題管理No4114対応 趙 end

export default {
  name: "ExamRecordListView",
  components: {
    "header-component": HeaderComponent,
    "main-component": MainComponent,
    "bread-crumbs-component": BreadCrumbsComponent
  },
  mixins: [ViewHelper],
  // del #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。 linjunfeng start
  // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
  // async beforeRouteLeave(to, from, next) {
  //   try {
  //     if (to.name != "signin" && !!this.isPatInfoChaned) {
  //       await this.$ons.notification.confirm({
  //         title: DIALOG_MESSAGES[13000004].title,
  //         message: messageFormat(DIALOG_MESSAGES[13000004].message),
  //         callback: answer => {
  //           if (answer === 1) {
  //             this.setIsPatInfoChaned(false);
  //             next();
  //           }
  //         }
  //       });
  //     } else {
  //       next();
  //     }
  //   } catch (error) {
  //     getErrorMessage('ExamRecordView.vue', 'beforeRouteLeave', error);
  //     next();
  //   }
  // },
  // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end
  // del #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。 linjunfeng start
  data() {
    return {
      historyKey: HISTORY_KEY_EXAM_RECORD_LIST
    };
  },
  // add FutreNetWeb+SI課題管理No4114対応 趙 start
  created() {
    if (this.$route.name === "exam-record") {
      this.historyKey = HISTORY_KEY_EXAM_RECORD_LIST;
    } else {
      this.historyKey = HISTORY_KEY_EXAM_RECORD_DETAIL;
    }
  },
  // add FutreNetWeb+SI課題管理No4114対応 趙 end
  // del #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。 linjunfeng start
  // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
  // computed: {
  //   ...mapGetters("pat-info", ["isPatInfoChaned"]),
  // },
  // methods: {
  //   ...mapMutations("pat-info", ["setIsPatInfoChaned"]),
  // }
  // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end
  // del #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。 linjunfeng end
};
</script>
