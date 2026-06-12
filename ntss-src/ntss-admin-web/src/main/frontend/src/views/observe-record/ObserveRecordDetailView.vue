/**
 * 観察記録詳細ページ
 */
<!--
/**
 * *************************************************************
 * NOTE: 分割表示に戻す際は、<ntss-layout>タグを<ntss-layout-split>に変更する
 *       また、router.indexのOBSERVE_RECORDの内容をコメントアウトのJSONに変更し、
 *       参照されなくなったOBSERVE_RECORD_LIST関係の要素を削除する
 * **************************************************************
 */
 -->
<template>
  <ntss-layout-content>
    <!-- del FNSI-顯示調整 房 start
    <template #header-content>
      <header-component :isCannotSwipe="true" />
    </template>
    <template #bread-crumbs-content>
      <bread-crumbs-component :no-split="true" :history-key="historyKey" />
    </template>
    del FNSI-顯示調整 房 end-->
    <template #main-content>
      <main-component ref="mainComponent" :history-key="historyKey" />
    </template>
  </ntss-layout-content>
</template>
<script>
import MainComponent from "@/components/pat-event/PatEventDetailComponent";
import ViewHelper from "@/views/ViewHelperMixin";
import { HISTORY_KEY_OBSERVE_RECORD_DETAIL } from "@/router/observe-record/HistoryKeyConstants";
// add #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 start
import {mapActions, mapGetters} from "@/compat/vue/vuex";
// add #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 end

export default {
  name: "ObserveRecordDetailView",
  components: {
    // mod FNSI-顯示調整 房 start
    // "header-component": HeaderComponent,
    "main-component": MainComponent,
    // "bread-crumbs-component": BreadCrumbsComponent
    // mod FNSI-顯示調整 房 end
  },
  mixins: [ViewHelper],
  async beforeRouteLeave(to, from, next) {
    //add #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc start
    // mod #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 start
    if(this.$refs.mainComponent &&
        // (this.$refs.mainComponent.skipRoute || this.$refs.mainComponent.isChangePatId)){
        (this.getSkipRoute || this.$refs.mainComponent.isChangePatId)){
      this.setSkipRoute(false)
      // mod #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 end
      next();
      return;
    }
    //add #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc end
    if (this.$refs.mainComponent
      && this.$refs.mainComponent.selectedPatId
      && !(await this.$refs.mainComponent.confirmAllowDiscardChanges())
    ) {
      // 内容破棄確認でキャンセルした場合はページ遷移をキャンセルする
      next(false);
    } else {
      next();
    }
  },
  data() {
    return {
      historyKey: HISTORY_KEY_OBSERVE_RECORD_DETAIL
    };
  },
  // add #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 start
  computed: {
    ...mapGetters("pat-event/detail", ["getSkipRoute"])
  },
  methods: {
    ...mapActions("pat-event/detail", ["setSkipRoute" ])
  },
  // add #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 end
};
</script>
