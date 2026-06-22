/**
 * パンくずリスト部品（Vue3 / Vuex 4）
 */
<template>
  <div id="BreadCrumbsComponent_breadcrumb_content_area" class="breadcrumb-area">
    <ol :id="`breadcrumb-content-${depth}`" class="breadcrumb-content">
      <!-- mod #7190 2022/8/19 【デグレ】治療状況リストを開くまでが遅くなった。 dou start -->
      <!-- <li v-for="item in historyList" :key="item.depth"> -->
      <li v-for="item in historyList" :key="item.routerName" :ref="'mbx'">
        <!-- mod #7190 2022/8/19 【デグレ】治療状況リストを開くまでが遅くなった。 dou end -->
        <a @click="goBack(item.routerName)">{{ item.title }}</a>
      </li>
    </ol>
  </div>
</template>

<script>
// mod FNSI-改修内容 処方個別画面に処方一覧画面のリンクを追加する dou start
// import { mapGetters, mapActions } from "@/compat/vue/vuex";
import { mapGetters, mapActions, mapMutations } from "@/compat/vue/vuex";
// mod FNSI-改修内容 処方個別画面に処方一覧画面のリンクを追加する dou end
import { EventBus } from "@/compat/vue/event-bus.js";

export default {
  name: "BreadCrumbsComponent",
  inject: {
    getNtssMainComponent: {
      default: null
    }
  },
  props: {
    historyKey: {
      type: String,
      required: true
    },
    noSplit: Boolean
  },
  data() {
    return {
      depth: 0,
      historyList: [],
      routerName: null,
      lastHistoryText: null
    };
  },
  computed: {
    ...mapGetters("window-size", {
      splittableFrames: "getSplittableFrames"
    }),
    ...mapGetters("bread-crumb", {
      histories: "getHistory",
      keepHistories: "getKeepHistory",
      // add #8043 2022/10/26 【デグレ】ブラウザバックするとパンくずリストに追加される dou start
      popstate: "getPopstate",
      // add #8043 2022/10/26 【デグレ】ブラウザバックするとパンくずリストに追加される dou end
      fromName: "getFromName"
    })
  },
  watch: {
    // 画面分割数の監視
    splittableFrames() {
      this.createHistoryList();
    },
    //upd #9923 20231030 日機装施設の場合に顧客施設マスタ編集時にでていた施設名が表示しなくなった ztc start
    // アクセス履歴の監視
    // histories() {
    //   this.createHistoryList();
    // }
    histories: {
      handler() {
        this.createHistoryList();
      },
      deep: true
    },
    historyList: {
      handler(newVal, oldVal) {
        this.$nextTick(() => {
          const breadcrumbItems = this.$refs.mbx;
          const breadcrumbElements = Array.isArray(breadcrumbItems)
            ? breadcrumbItems
            : (breadcrumbItems ? [breadcrumbItems] : []);
          const historyText = breadcrumbElements
            .map((element) => element?.innerText || element?.textContent || "")
            .filter((text) => text !== "")
            .join(">");
          if (oldVal && historyText && historyText !== this.lastHistoryText) {
            this.lastHistoryText = historyText;
            this.sethisData(historyText);
          }
        });
      }
    }
    //upd #9923 20231030 日機装施設の場合に顧客施設マスタ編集時にでていた施設名が表示しなくなった ztc end
  },
  created() {
    const currentHistory = this.histories.find((e) => e.historyKey === this.historyKey);
    this.depth = currentHistory ? currentHistory.depth : 0;
    // mod #8043 2022/10/26 【デグレ】ブラウザバックするとパンくずリストに追加される dou start
    // this.createHistoryList();
    setTimeout(() => {
      this.createHistoryList();
    }, 0);
    // mod #8043 2022/10/26 【デグレ】ブラウザバックするとパンくずリストに追加される dou end
  },
  methods: {
    ...mapActions("bread-crumb", ["setKeepHistory", "clearPopstate", "sethisData"]),
    // add FNSI-改修内容 処方個別画面に処方一覧画面のリンクを追加する dou start
    ...mapMutations("pat-prescription", ["setRouteFlag"]),
    // add FNSI-改修内容 処方個別画面に処方一覧画面のリンクを追加する dou end
    // add #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。linjunfeng start
    ...mapMutations("exam-record/list", ["setExamRouteFlg"]),
    // add #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。linjunfeng end
    getMainComponent() {
      return typeof this.getNtssMainComponent === "function"
        ? this.getNtssMainComponent()
        : null;
    },
    async pushBreadcrumbRoute(routerName) {
      try {
        await this.$router.push({ name: routerName });
      } catch (error) {
        const failureType = error?.type;
        const failureName = error?.name || "";
        if (failureType !== 16 && !String(failureName).includes("NavigationDuplicated")) {
          throw error;
        }
      }
      await this.$nextTick();
    },
    // 表示対象となるアクセス履歴配列を生成する
    createHistoryList() {
      // mod #8043 2022/10/26 【デグレ】ブラウザバックするとパンくずリストに追加される dou start
      // this.createHistoryList();
      // 現在画面に表示されている履歴を取得する
      // ※`this.histories`を直接操作すると、`watch`の無限ループが始まるため、ディープコピーしてから操作する
      const baseHistories = Array.isArray(this.histories)
        ? JSON.parse(JSON.stringify(this.histories))
        : [];
      if (baseHistories.length === 0) {
        this.historyList = [];
        return;
      }
      const shownHistories = JSON.parse(JSON.stringify(baseHistories))
        .reverse()
        .filter((value, index) => {
          return index < this.splittableFrames;
        })
        .reverse();
      /* mod #8620 by zhangruixue 2023-05-06 --start */
      let histories = JSON.parse(JSON.stringify(baseHistories));
      let routerName = this.keepHistories[0]?.routerName || "";
      // パンくずリストに表示する対象要素を決定する
      histories.forEach((item) => {
        if (
          ["INFO", "PAT_EVENT", "EXAM_RECORD_DETAIL"].includes(item.historyKey) &&
          (item.historyKey === "PAT_EVENT" || item.historyKey === "INFO") &&
          routerName === "exam-record-detail"
        ) {
          item.depth = 1;
          item.historyKey = "EXAM_RECORD_LIST";
          item.routerName = "exam-record";
          item.title = "検査結果一覧";
        }
      });
      if (this.noSplit) {
        // 画面分割なしの場合、全て
        this.historyList = histories;
        // this.historyList = this.histories;
      } else if (shownHistories[0] && shownHistories[0].depth === this.depth) {
        // 一番左に表示されるページの場合は、履歴の先頭から自ページまで
        // this.historyList = this.histories.filter(item => {
        //   return item.depth <= this.depth;
        // });
        this.historyList = histories.filter((item) => {
          return item.depth <= this.depth;
        });
      } else {
        // 上記以外は、自ページのみ
        // this.historyList = this.histories.filter(item => {
        //   return item.depth === this.depth;
        // });
        this.historyList = histories.filter((item) => {
          return item.depth === this.depth;
        });
        /* mod #8620 by zhangruixue 2023-05-06 --end */
      }

      // フッター以外から遷移する場合、パンくずリストに遷移履歴(パンくず保存履歴)を追加
      const targetRouters = [
        "pat-viewer",
        "pat-calendar",
        "bbs-info",
        "split-graph",
        "multi-pat-list",
        "facility-calendar"
      ];
      if (this.depth === 1 || targetRouters.includes(routerName)) {
        const routerNameList = this.histories.map((item) => item.routerName);
        const keepHistories = [];

        // パンくずリストのアクセス履歴以前を取得
        for (const item of this.keepHistories) {
          if (routerNameList.includes(item.routerName)) {
            break;
          } else {
            keepHistories.push(item);
          }
        }

        // アクセス保持履歴 ＋ アクセス履歴
        if (this.popstate) {
          // ブラウザバックが発生した場合keepHistoriesからFromとなった要素を除外
          keepHistories.forEach((item, index) => {
            if (item.routerName === this.fromName) {
              keepHistories.splice(index, 1);
            }
          });
          this.clearPopstate();
        }
        this.historyList = [...keepHistories, ...this.historyList];
        // パンくず保存履歴に表示しているパンくずリストを設定
        this.setKeepHistory(this.historyList);
      }

      // リストを右に寄せる
      this.$nextTick(() => {
        // mod #10225 処方薬剤選択に一般名処方が表示しない。yqz start
        const listElement = this.$el?.querySelector?.(`#breadcrumb-content-${this.depth}`)
          || this.$el?.ownerDocument?.getElementById?.(`breadcrumb-content-${this.depth}`)
          || null;
        if (listElement && typeof listElement.scrollLeft === "number") {
          listElement.scrollLeft = 1000;
        }
        // mod #10225 処方薬剤選択に一般名処方が表示しない。yqz end
      });
      this.historyList.forEach((item, index) => {
        if (
          ["EXAM_RECORD_LIST", "EXAM_RECORD_DETAIL"].includes(item.historyKey) &&
          item.historyKey === "EXAM_RECORD_DETAIL" &&
          this.routerName === "exam-record" &&
          routerName === "exam-record-detail"
        ) {
          this.historyList.splice(index, 1);
        }
      });
    },
    // クリックされた場所（画面）に戻る
    async goBack(routerName) {
      if (!routerName) {
        return;
      }
      if (!Array.isArray(this.historyList) || this.historyList.length === 0) {
        await this.pushBreadcrumbRoute(routerName);
        return;
      }
      this.routerName = routerName;
      if (routerName === "exam-record") {
        this.depth = 1;
      }
      if (routerName === "indication-receive-detail") {
        EventBus.$emit("goBack");
      }
      if (routerName === "pat-calendar") {
        EventBus.$emit("goBack");
      }
      if (routerName === "indication-receive-details") {
        EventBus.$emit("goBack");
      }
      if (routerName === "rad-request-detail" || routerName === "rad-request") {
        EventBus.$emit("goBack");
      }
      if (routerName === "view-log") {
        const mainComponent = this.getMainComponent();
        if (mainComponent) {
          mainComponent.createTab(mainComponent.getCondition);
          mainComponent.onGetTabData();
          await mainComponent.getUser();
        }
      }
      if (routerName === "facility-calendar" && this.historyList.length === 1) {
        this.getMainComponent()?.createCalendarContentsForMasterLayoutSearch();
      }
      if (routerName === "split-graph" && this.historyList.length === 1) {
        this.getMainComponent()?.init();
      }
      if (routerName === "pat-info" && this.historyList.length === 1) {
        this.getMainComponent()?.$refs.cardList?.refreshData();
      }
      if (routerName === "pat-info-create" && this.historyList.length === 1) {
        this.getMainComponent()?.$refs.cardListCreate?.refreshData();
      }
      if (routerName === "bbs-info") {
        // 施設カレンダー＞掲示板、掲示板 の掲示板パンくずリスト押下時はsearch()を実行する。掲示板＞各機能の場合はsearch()が存在しないのでtypeerror発生
        const mainComponent = this.getMainComponent();
        if (typeof mainComponent?.search === "function") {
          mainComponent.search();
        }
      }
      // 患者情報共有画面の場合、リフレッシュを実行する
      if (routerName.includes("pat-info-sharing")) {
        EventBus.$emit("refresh", this.historyKey);
        return;
      }
      // 画面幅に応じてサイドバーを閉じる
      EventBus.$emit("sidebarCloseByWidth");
      this.setRouteFlag(false);
      if (routerName === "exam-record") {
        this.setExamRouteFlg(false);
      }
      if (routerName === "pat-prescription") {
        this.getMainComponent()?.$refs.detail?.refresh();
      }
      // 画面分割される画面で元の画面となるルート名
      const splitPageRouterName = [
        "status-list",
        "operation-viewer-general-machines",
        "device-edge-operation",
        "operation-viewer-admin-facilities",
        "operation-viewer-admin-machines",
        "operation-viewer-admin-motion-record",
        "operation-viewer-general-motion-record",
        "pat-group"
      ];
      const lastHistory = this.historyList[this.historyList.length - 1] || null;
      if (routerName === lastHistory?.routerName) {
        // 画面分割の画面幅が広い場合に以下のパンくず選択時に分割元の画面に遷移して分割状態を解除する
        // ・治療状況リストと警報報告一覧の分割時に治療状況リストの選択時
        // ・遠隔監視と装置記録の分割時に遠隔監視の選択時
        // ・遠隔監視と装置記録と装置記録詳細の分割時に装置記録の選択時
        // ・患者グループと患者グループ編集の分割時に患者グループの選択時
        // nkknkk施設
        // ・デバイスエッジ遠隔監視とデバイスエッジ遠隔保守の分割時にデバイスエッジ遠隔監視の選択時
        // ・遠隔操作施設一覧と遠隔監視(施設名)の分割時に遠隔操作施設一覧の選択時
        // ・遠隔操作施設一覧と遠隔監視(施設名)と装置記録の分割時に遠隔監視(施設名)の選択時
        // ・遠隔操作施設一覧と遠隔監視(施設名)と装置記録と装置記録詳細の分割時に装置記録の選択時
        if (splitPageRouterName.includes(routerName)) {
          this.$router.push({ name: routerName });
        }
        if (routerName.includes("treatment-record-")) {
          EventBus.$emit("refresh", false);
          return;
        }
        if (routerName.includes("pat-group-")) {
          EventBus.$emit("refresh", true);
          return;
        }
        EventBus.$emit("refresh");
      } else {
        const currentRoute = this.$route?.name || "";
        await this.pushBreadcrumbRoute(routerName);
        // 画面分割の画面幅が狭い場合（モバイル端末の表示も含む）以下のパンくず選択時に分割元の画面に refresh イベントを通知する
        // ・[治療状況リスト＞警報報告一覧]で治療状況リストの選択時
        // ・[遠隔監視＞装置記録]で遠隔監視の選択時
        // ・[遠隔監視＞装置記録＞装置記録詳細]で装置記録の選択時
        // ・[患者グループ＞患者グループ編集]で患者グループの選択時
        // nkknkk施設
        // ・[デバイスエッジ遠隔監視＞デバイスエッジ遠隔保守]でデバイスエッジ遠隔監視の選択時
        // ・[遠隔操作施設一覧＞遠隔監視(施設名)]で遠隔操作施設一覧の選択時
        // ・[遠隔操作施設一覧＞遠隔監視(施設名)＞装置記録]で遠隔監視(施設名)の選択時
        // ・[遠隔操作施設一覧＞遠隔監視(施設名)＞装置記録＞装置記録詳細]で装置記録の選択時
        if (splitPageRouterName.includes(routerName)) {
          // 治療状況リストの子画面として治療記録画面に遷移した場合を除く（パンくず[治療状況リスト＞治療記録]の治療状況リストの選択を判定する）
          // mod 12409 治療状況リストから治療記録に遷移しサイドメニューから画面を開きパンくずリストの治療状況リストを押下すると画面遷移せずパンくずリストが消える zkm start
          // if (currentRoute !== 'treatment-record') {
          if (currentRoute !== "treatment-record" && !currentRoute.includes("treatment-record-")) {
            // mod 12409 治療状況リストから治療記録に遷移しサイドメニューから画面を開きパンくずリストの治療状況リストを押下すると画面遷移せずパンくずリストが消える zkm end
            EventBus.$emit("refresh");
          }
        }
      }
    }
  }
};
</script>
