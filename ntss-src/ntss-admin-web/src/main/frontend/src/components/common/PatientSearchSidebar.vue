<template>
  <div class="side-bar" @click='closeMenu'>
    <kendo-tabstrip style="overflow-y: hidden" @select="changeTab">
      <ul>
        <li class="k-state-active">
          患者検索
        </li>
        <li>
          予実リスト
        </li>
      </ul>
      <div>
        <!-- 簡易検索 -->
        <simple-search @handleClickChange="searchChange" :user-query="userSearchQuery" v-show="!isIndicationScreen" />
        <!--mod FNSI-改修内容画面デザイン 任 start-->
        <!--<v-ons-button
          class="detailed-search-button color-btn-ok"
          @click="showDetailedSearchModal"
          v-show="!isIndicationScreen"
        >-->
        <v-ons-button
          class="detailed-search-button color-btn-ok btn3-normal"
          @click="showDetailedSearchModal"
          v-show="!isIndicationScreen"
          :style="patSearchTypeColor"
        >
          <!--mod FNSI-改修内容画面デザイン 任 start-->
          もっと詳しく検索
        </v-ons-button>
        <!-- 各機能からの患者リストを表示している場合に表示する -->
        <label class="src-func-name" style="color: orange; font-weight: bold;" v-if="srcFuncName !== ''">{{ funcName }}の患者一覧を表示</label>
        <!-- 患者リスト -->
        <!-- mod 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 関 start -->
        <!--mod FNSI-No.341 患者リストのソート項目不足 吉 start-->
        <!--<pat-list/>-->
        <!-- <pat-list ref="patList" v-if="flag"/>
        <pat-list-date  ref="patListDate" v-if="!flag"/> -->
        <!--mod FNSI-No.341 患者リストのソート項目不足 吉 end-->
        <pat-list ref="patList"/>
        <!-- mod 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 関 end -->
      </div>
      <div>
        <div id="indication-result-wrapper">
          <indication-result />
        </div>
      </div>
    </kendo-tabstrip>
  </div>
</template>

<script>
  // コンポーネント
  import $ from "@/compat/jquery";
  import simpleSearch from "@/components/side-contents/SimpleSearch.vue";
  import patList from "@/components/side-contents/PatList.vue";
  // del 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 関 start
  // add FNSI-No.341 患者リストのソート項目不足 吉 start
  // import patListDate from "@/components/side-contents/PatListByTreatDate.vue";
  // add FNSI-No.341 患者リストのソート項目不足 吉 end
  // del 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 関 end
  // del FNSI-改修内容 ｶｽﾀﾑ検索ドロップダウンボックスの初期化エラー dou start
  // import { SearchQuery } from "@/components/side-contents/SearchDefinitions.js";
  // del FNSI-改修内容 ｶｽﾀﾑ検索ドロップダウンボックスの初期化エラー dou start
  import IndicationResultComponent from "@/components/indication-result/IndicationResultComponent";

  import {mapActions, mapGetters, mapMutations} from "@/compat/vue/vuex";
  import {EventBus} from "@/compat/vue/event-bus.js";
  // add FNSI-改修内容 ｶｽﾀﾑ検索ドロップダウンボックスの初期化エラー dou start
  import {ApiHelper} from "@/apis/AxiosHelper.js";
  // add FNSI-改修内容 ｶｽﾀﾑ検索ドロップダウンボックスの初期化エラー dou end

/**
 * @description 共通患者検索サイドバー
 */
export default {
  inject: {
    getNtssLayoutRootElement: {
      default: null
    },
    getNtssFooterMenuElement: {
      default: null
    }
  },
  components: {
    "simple-search": simpleSearch,
    "pat-list": patList,
    "indication-result": IndicationResultComponent,
    // del 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 関 start
    // add FNSI-No.341 患者リストのソート項目不足 吉 start
    // "pat-list-date":patListDate
    // add FNSI-No.341 患者リストのソート項目不足 吉 end
    // del 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 関 end
  },
  data() {
    return {
      // クエリオブジェクト配列
      userSearchQuery: [],
      selectTabId: 0,
      funcName: "",
      // del 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 関 start
      // flag:true,
      // del 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 関 end
      // FNSI-修正、#6129、「beforeSelectPatId」を子対象から親対象に遷移、xugj add start
      beforeSelectPatId: "",
      onDetailedSearchUserSearchQuery: null,
      onCalculateTableHeight: null,
      onBeforeSelectPatIdChange: null,
      onPatListSort: null
      // FNSI-修正、#6129、「beforeSelectPatId」を子対象から親対象に遷移、xugj add end
    };
  },
  computed: {
    // add FNSI-改修内容 ｶｽﾀﾑ検索ドロップダウンボックスの初期化エラー dou start
    ...mapGetters("pat-info", ["patSearchDetails"]),
    // add FNSI-改修内容 ｶｽﾀﾑ検索ドロップダウンボックスの初期化エラー dou end
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight"
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize"
    }),
    ...mapGetters("pat-info", {
      srcFuncName: "srcFuncName",
      patSearchType: "patSearchType"
    }),
    ...mapGetters("bread-crumb", {
      keepHistories: "getKeepHistory"
    }),
    isIndicationScreen() {
      return /^indication/i.test(this.$route.name)
    },
    // もっと詳しく検索ボタンから検索が実施された場合にボタンの色を変更
    patSearchTypeColor() {
      let rtn = {};
      // patSearchType が詳細検索(2)の場合、且つ画面遷移後でない場合
      if (this.patSearchType === 2 && this.srcFuncName === "") {
        rtn = {"background-image": "linear-gradient(#2ca06f, #2ca06f) !important"};
      }
      return rtn;
    }
  },
  watch: {
    windowHeight() {
      this.calculateTableHeight();
    },
    isDispMenu() {
      this.calculateTableHeight();
    },
    getFontSize() {
      this.calculateTableHeight();
    },
    // 遷移先が親画面(keepHistoriesが1件)だった場合、検索一覧表示に戻す
    keepHistories() {
      if (this.keepHistories.length <= 1 && this.srcFuncName !== 'indication') {
        this.setSrcFuncName("");
        this.setOrdNoForSideBarRecord(null);
      }
    },
    srcFuncName() {
      // url から機能名称を取得
      if (this.srcFuncName !== "") {
        this.keepHistories.forEach(function(hist) {
          if (hist.routerName == this.srcFuncName) {
            this.funcName = hist.title;
          }
        }, this);
      } else {
        this.funcName = "";
        this.setIsNullPat(false);
      }
    }
  },
  methods: {
    ...mapActions("multi-modal", ["showDetailedSearchModal"]),
    ...mapActions("treatment-record/common", ["setOrdNoForSideBarRecord"]),
    ...mapMutations("pat-info", ["setSrcFuncName", "setIsNullPat"]),
    // add FNSI-改修内容 ｶｽﾀﾑ検索ドロップダウンボックスの初期化エラー dou start
    ...mapMutations("pat-info", ["addPatSearchDetail",]),
    // add FNSI-改修内容 ｶｽﾀﾑ検索ドロップダウンボックスの初期化エラー dou end
    // add FNSi6299-抽出条件を設定している状態で指示受け（指示承認）画面を開き、その後元の画面に戻ると表示順が勝手に入れ替わる 周 start
    ...mapActions("loading-screen", ["setLoadingScreenVisible", "setLoadingScreenMessage"]),
    // add FNSi6299-抽出条件を設定している状態で指示受け（指示承認）画面を開き、その後元の画面に戻ると表示順が勝手に入れ替わる 周 end
    getSidebarRoot() {
      return this.$el || null;
    },
    getLayoutRoot() {
      return typeof this.getNtssLayoutRootElement === "function"
        ? this.getNtssLayoutRootElement()
        : null;
    },
    getScopedSearchRoots() {
      const roots = [];
      const pushRoot = (candidate) => {
        if (candidate && !roots.includes(candidate)) {
          roots.push(candidate);
        }
      };
      pushRoot(this.getSidebarRoot());
      pushRoot(this.getLayoutRoot());
      return roots;
    },
    queryScoped(selector) {
      for (const root of this.getScopedSearchRoots()) {
        const found = root?.querySelector?.(selector);
        if (found) {
          return found;
        }
      }
      return null;
    },
    queryScopedAll(selector) {
      const results = [];
      this.getScopedSearchRoots().forEach((root) => {
        root?.querySelectorAll?.(selector)?.forEach?.((element) => {
          if (!results.includes(element)) {
            results.push(element);
          }
        });
      });
      return results;
    },
    getFooterMenuHeight() {
      const footerMenu = typeof this.getNtssFooterMenuElement === "function"
        ? this.getNtssFooterMenuElement()
        : null;
      return footerMenu?.clientHeight || 0;
    },
    changeTab(e) {
      this.selectTabId = (typeof e?.itemIndex === "number" ? e.itemIndex : $(e.item).index());
      this.$nextTick(() => {
        // 患者検索の画面の高さを再計算
        this.calculateTableHeight();
      });
    },
    // 一覧領域の高さを調整
    calculateTableHeight() {
      // 画面の高さを取得
      const wh = this.windowHeight;
      // フッターの高さを取得
      const fmh = this.isDispMenu === 1
        ? this.getFooterMenuHeight()
        : 0;

      if (this.selectTabId === 0) {
        // simpleSearchAreaHight: 検索条件枠の高さ
        // btnnnHight: 「もっと詳しく検索」ボタンの高さ
        // srcFuncNameHeight: "指示受け・指示承認の患者一覧を表示" ラベルの高さ
        let objHeight = 0;
        // 画面の高さ変動が落ち着くまで取得処理を実施
        const loopId = setInterval(() => {
          const header = this.queryScoped("#showPatientSearchSidebarBtn");
          const headerHight = header && header.offsetHeight ? header.offsetHeight : 0;
          const simpleSearchArea = this.queryScoped(".simple-search-area");
          const simpleSearchAreaHight = simpleSearchArea && simpleSearchArea.offsetHeight ? simpleSearchArea.offsetHeight : 0;
          const btnnn = this.queryScoped(".detailed-search-button.color-btn-ok");
          const btnnnHight = btnnn && btnnn.offsetHeight ? btnnn.offsetHeight : 0;
          const srcFuncNameArea = this.queryScoped(".src-func-name");
          const srcFuncNameHeight = srcFuncNameArea && srcFuncNameArea.offsetHeight ? srcFuncNameArea.offsetHeight + 5 : 0; // 5は上下位置状を考慮
          if (objHeight === simpleSearchAreaHight + btnnnHight + srcFuncNameHeight) {
            const tableTop = headerHight + simpleSearchAreaHight + btnnnHight + srcFuncNameHeight;
            const patListArea = this.queryScoped(".pat-list-area");
            if (patListArea) {
              const resolvedHeight = wh - tableTop - fmh - 20;
              patListArea.style.height = `${resolvedHeight}px`;
              // 高さの調整を実施後処理を抜ける
              clearInterval(loopId);
            }
          } else {
            // 前回の高さを更新
            objHeight = simpleSearchAreaHight + btnnnHight + srcFuncNameHeight;
          }
        }, 300);
      } else if (this.selectTabId === 1) {
        // Tabindex = 1 （予実リスト）
        // 検索条件枠の高さ
        let filterAreaHight = 0;
        let objHeight = filterAreaHight;
        // 画面の高さ変動が落ち着くまで取得処理を実施
        const loopId = setInterval(() => {
          const headerHight = this.queryScoped("#showPatientSearchSidebarBtn")?.offsetHeight || 0;
          const filterArea = this.queryScoped(".filter-area");
          filterAreaHight = filterArea ? filterArea.offsetHeight : 0;
          if (objHeight === filterAreaHight) {
            const tableTop = headerHight + filterAreaHight;
            const treeHeaderObj = this.queryScopedAll(".tree-view-header-area");
            const treeHeaderHeight = treeHeaderObj.length > 0 ? treeHeaderObj[0].offsetHeight : 0;
            const treeViewContentArea = this.queryScoped(".tree-view-content-area");
            if (treeViewContentArea) {
              const resolvedHeight = wh - tableTop - treeHeaderHeight - fmh - 35;
              treeViewContentArea.style.height = `${resolvedHeight}px`;
            }
            // 高さの調整を実施後処理を抜ける
            clearInterval(loopId);
          } else {
            // 前回の高さを更新
            objHeight = filterAreaHight;
          }
        }, 300);
      }
    },
    // del 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 関 start
    // add FNSI-No.341 患者リストのソート項目不足 吉 start
    // setDreatDate(val){
    //   if(null != val && ""!= val){
    //     this.flag=true;
    //   }else{
    //     this.flag=false;
    //   }
    //   // add FutreNetWeb+SI課題管理No4072対応 趙 start
    //   this.calculateTableHeight();
    //   // add FutreNetWeb+SI課題管理No4072対応 趙 end
    // },
    // add FNSI-No.341 患者リストのソート項目不足  吉 end
    // del 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 関 end
    // mod 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 関 start
    // async searchChange() {
    //   if(this.flag){
    //     //header组件和home组件相互通信
    //     await this.$refs.patList.sort();
    //   }else{
    //     this.$refs.patListDate.sort();
    //   }

    // }
    async searchChange() {
      const patList = this.$refs.patList;
      if (!patList || typeof patList.sort !== "function") {
        return;
      }
      try {
        await patList.sort();
      } catch (error) {
        void error;
      }
    },
    // mod 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 関 end
    closeMenu() {
      // フッターを閉じる
      EventBus.$emit("closeFooterList");
    },
    setBeforeSelectPatId(patId) {
      this.beforeSelectPatId = patId;
    },
  },
    // mod FNSI-改修内容 ｶｽﾀﾑ検索ドロップダウンボックスの初期化エラー dou start
  // created() {
  async created() {
    // add FNSi6299-抽出条件を設定している状態で指示受け（指示承認）画面を開き、その後元の画面に戻ると表示順が勝手に入れ替わる 周 start
    this.setLoadingScreenMessage("処理中...");
    this.setLoadingScreenVisible(true);
    // add FNSi6299-抽出条件を設定している状態で指示受け（指示承認）画面を開き、その後元の画面に戻ると表示順が勝手に入れ替わる 周 end
    // mod FNSI-改修内容 ｶｽﾀﾑ検索ドロップダウンボックスの初期化エラー dou end
    // TODO: ユーザ設定のクエリ取得API実装待ち

// mod FNSI-改修内容 ｶｽﾀﾑ検索ドロップダウンボックスの初期化エラー dou start
    // クエリはプレーンオブジェクトで取得されるのでSearchQueryオブジェクトとしてインスタンス化
    // this.userSearchQuery = this.userSearchQuery.map(el => {
    //   return {
    //     queryName: el.queryName,
    //     query: new SearchQuery(el.query)
    //   };
    // });
    let resPatSearchDetails = await ApiHelper.get("/pat_search_detail");
    const patSearchDetails = Array.isArray(resPatSearchDetails?.data) ? resPatSearchDetails.data : [];
    patSearchDetails.forEach(detail => {
      this.addPatSearchDetail({
        queryId: detail.searchCd,
        queryName: detail.searchName,
        query: JSON.parse(detail.searchCondition)
      });
    });
    this.userSearchQuery = this.patSearchDetails;
    var obj = {}
    var newArr = this.patSearchDetails.reduce((cur,next) => {
      if (!obj[next.queryId]) {
        obj[next.queryId] = true;
        cur.push(next);
      }
      return cur;
    },[])
    this.userSearchQuery = newArr;
    this.onDetailedSearchUserSearchQuery = (userQuery) => {
      this.userSearchQuery = userQuery;
    };
    this.onCalculateTableHeight = () => this.calculateTableHeight();
    this.onBeforeSelectPatIdChange = (patId) => this.setBeforeSelectPatId(patId);
    this.onPatListSort = () => this.searchChange();
    // add 性能改善メモリ不足 shan start
     EventBus.$off("detailedSearchUserSearchQuery", this.onDetailedSearchUserSearchQuery);
    // del 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 関 start
    // EventBus.$off("setDreatDate", this.setDreatDate);
    // del 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 関 end
    EventBus.$off("calculateTableHeight", this.onCalculateTableHeight);
    EventBus.$off("setPatientSearchSidebarBeforeSelectPatId", this.onBeforeSelectPatIdChange);
    // add 性能改善メモリ不足 shan end
// mod FNSI-改修内容 ｶｽﾀﾑ検索ドロップダウンボックスの初期化エラー dou end
    EventBus.$on("detailedSearchUserSearchQuery", this.onDetailedSearchUserSearchQuery);
    // del 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 関 start
    // add FNSI-No.341 患者リストのソート項目不足 吉 start
    // EventBus.$on("setDreatDate", this.setDreatDate);
    // add FNSI-No.341 患者リストのソート項目不足  吉 end
    // del 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 関 end
    // add FutreNetWeb+SI課題管理 No4072 趙 start
    EventBus.$on("calculateTableHeight", this.onCalculateTableHeight);
    EventBus.$on("setPatientSearchSidebarBeforeSelectPatId", this.onBeforeSelectPatIdChange);
    // add FutreNetWeb+SI課題管理 No4072 趙 end
    EventBus.$on("patlistsort", this.onPatListSort);
  },
  // add FutreNetWeb+SI課題管理 No4072 趙 start
  beforeUnmount() {
    // add FNSI-性能を最適化する 李 start
    EventBus.$off("detailedSearchUserSearchQuery", this.onDetailedSearchUserSearchQuery);
    // add FNSI-性能を最適化する 李 end
    //add FNSI-性能を最適化する 吉 end
    EventBus.$off("setDreatDate", this.setDreatDate);
    //add FNSI-性能を最適化する 吉 end
    EventBus.$off("calculateTableHeight", this.onCalculateTableHeight);
    EventBus.$off("setPatientSearchSidebarBeforeSelectPatId", this.onBeforeSelectPatIdChange);
    EventBus.$off("patlistsort", this.onPatListSort);
  },
  // add FutreNetWeb+SI課題管理 No4072 趙 end
  async mounted() {
    try {
      this.calculateTableHeight();
      await this.$nextTick();
      // サインイン時の並び順適用処理
      // mod FNSi6299-抽出条件を設定している状態で指示受け（指示承認）画面を開き、その後元の画面に戻ると表示順が勝手に入れ替わる 周 start
      //this.searchChange();
      await this.searchChange();
      // mod FNSi6299-抽出条件を設定している状態で指示受け（指示承認）画面を開き、その後元の画面に戻ると表示順が勝手に入れ替わる 周 end
    } catch (error) {
      void error;
    } finally {
      this.setLoadingScreenVisible(false);
    }
  }
};
</script>

<style scoped>
ul {
  /* border 1px を補正 */
  height: calc(4.2em - 1px);

}

.side-bar {
  background-color: var(--ntss-base-background-color);
  z-index: 4;
  font-size: 150%;
}

.detailed-search-button {
  width: 100%;
  font-size: 1em;
  border: 1px solid #dddddd;
  margin: 1px 0px 1px 0px;
}

/** 文字サイズ変更のためにkendo-uiのCSSの一部を強制書き換え*/
.k-widget {
  font-size: inherit !important;
}

/** padding を上書き補正*/
.side-bar :deep(.k-tabstrip > .k-content) {
  padding: 0.5rem;
  /** 一瞬余分なスクロールバーが発生する為 */
  overflow-y: hidden;
  background-color: var(--ntss-base-background-color);
  color: var(--ntss-base-color);
}

.side-bar :deep(.k-tabstrip-content.k-content) {
  padding: 0.5rem;
  /** 一瞬余分なスクロールバーが発生する為 */
  overflow-y: hidden;
  background-color: var(--ntss-base-background-color);
  color: var(--ntss-base-color);
}
.side-bar :deep(.k-state-active) {
  background-color: var(--ntss-base-background-color) !important;
  color: var(--ntss-base-color) !important;
  border-color:  var(--ntss-border-color) !important;
  border-bottom-color: transparent !important;
}

.side-bar :deep(.k-active) {
  background-color: var(--ntss-base-background-color) !important;
  color: var(--ntss-base-color) !important;
  border-color:  var(--ntss-border-color) !important;
  border-bottom-color: transparent !important;
}
.side-bar :deep(.k-tabstrip-items) {
  border-color:  var(--ntss-border-color) !important;
}
</style>