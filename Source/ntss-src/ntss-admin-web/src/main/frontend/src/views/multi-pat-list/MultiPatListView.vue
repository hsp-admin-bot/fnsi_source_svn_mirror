<template>
  <ntss-layout>
    <!--mod #6256 背景色が変わらない 徐博 start-->
    <!--<header-component #header-content />-->
    <template #header-content>
      <header-component :getInfo="getInfo" @changeLayout="onLayoutChange" @onSearch="onSearch" />
    </template>
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start -->
    <!--mod #6256 背景色が変わらない 徐博 end-->
    <!-- <bread-crumbs-component
      #bread-crumbs-content
      :history-key="historyKey"
      @refresh="refresh"
    /> -->
    <template #bread-crumbs-content>
      <bread-crumbs-component
        :history-key="historyKey"
      />
    </template>
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end -->
    <template #main-content>
      <dynamic-multi-pat-list ref="mainComponent"
        v-if="handleShowNewLayout"
        :history-key="historyKey"
      />
    <!-- mod FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou start -->
    <!-- <main-component
      v-else
      #main-content
      :history-key="historyKey"
    /> -->
    <!--add #6256 背景色が変わらない 徐博 start-->
    <!--mod #11708 データリスト患者情報1の身体情報系データを含むレイアウトが画面表示しない。 fang start -->
    <!-- NOTE: 患者情報１ -->
      <main-component ref="mainComponent"
        v-else-if="handleShowNewLayout2 && loadFlag"
        :patIdListToDisplay="patIdListToDisplay"
        :patRecords="patRecords"
        :history-key="historyKey"
        :ord-arr="ordArr"
        @refresh="getData"
      />
    <!--mod #11708 データリスト患者情報1の身体情報系データを含むレイアウトが画面表示しない。 fang end -->
    <!-- NOTE: 患者情報２、装置設定、治療予定・治療記録、バイタル・モニタ・愁訴処置、検査結果 -->
      <template-component ref="mainComponent"
        v-else-if="handleShowNewLayout3"
        :history-key="historyKey"
        :ord-arr="ordArr"
      />
    <!--add #6256 背景色が変わらない 徐博 end-->
    <!-- NOTE: 装置情報（水質検査） -->
      <template-component2 ref="mainComponent"
        v-else-if="handleShowNewLayout4"
        :history-key="historyKey"
      />
    <!-- NOTE: 装置情報（自己診断） -->
      <template-component3 ref="mainComponent"
        v-else-if="handleShowNewLayout5"
        :history-key="historyKey"
      />
    <!-- NOTE: 装置情報（日常点検・定期点検） -->
      <template-component4 ref="mainComponent"
        v-else-if="handleShowNewLayout6"
        :history-key="historyKey"
      />
    <!-- NOTE: 集計（日常点検・定期点検） -->
      <template-component5 ref="mainComponent"
        v-else-if="handleShowNewLayout7"
        :history-key="historyKey"
      />
    <!-- mod FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou end -->
    </template>
  </ntss-layout>
</template>

<script>
import HeaderComponent from "@/components/header-contents/MultiPatHeader";
import MainComponent from "@/components/multi-pat-list/MultiPatList.vue";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import ViewHelper from "@/views/ViewHelperMixin";
import { HISTORY_KEY_MULTI_PAT_LIST } from "@/router/multi-pat-list/HistoryKeyConstants";
import { mapActions, mapGetters} from "@/compat/vue/vuex";
import DynamicTemplateComponent from "@/components/multi-pat-list/DynamicTemplateComponent";
// mod FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou start
// import { PAT_INFO_TEMPLATE_CD } from "@/constants/dataListConstant";
import TemplateComponent from "@/components/multi-pat-list/TemplateComponent";
import TemplateComponent2 from "@/components/multi-pat-list/TemplateComponent2";
import TemplateComponent3 from "@/components/multi-pat-list/TemplateComponent3";
import TemplateComponent4 from "@/components/multi-pat-list/TemplateComponent4";
import TemplateComponent5 from "@/components/multi-pat-list/TemplateComponent5";
import { DATE_TEMPLATE_CD, MONTH_TEMPLATE_CD, PAT_INFO_TEMPLATE_CD, PAT_INFO_TWO_TEMPLATE_CD, TREATMENT_PLAN_TREATMENT_RECORD,
  VITAL_MONITORS_COMPLAINTS_CD, INSPECTION_RADIATION, DEVICE_SET, EQUIPMENT_INFORMATION_INSPECTION_DAILY_REGULAR,
  EQUIPMENT_INFORMATION_WATER_QUALITY_SURVEY, EQUIPMENT_INFORMATION_SELF_DIAGNOSIS, COLLECTIVE_DAILY_REGULAR } from "@/constants/dataListConstant";
// add #6256 背景色が変わらない 徐博 start
import { getPatRecords, confirmAllowDiscardChangesInMultiPatList } from "@/components/multi-pat-list/Functions";
import { EventBus } from "@/compat/vue/event-bus.js";
// add #6256 背景色が変わらない 徐博 end
// mod FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou end

export default {
  name: "MultiPatListView",
  components: {
    "header-component": HeaderComponent,
    "main-component": MainComponent,
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou start
    "template-component": TemplateComponent,
    "template-component2": TemplateComponent2,
    "template-component3": TemplateComponent3,
    "template-component4": TemplateComponent4,
    "template-component5": TemplateComponent5,
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou end
    "bread-crumbs-component": BreadCrumbsComponent,
    "dynamic-multi-pat-list": DynamicTemplateComponent
  },
  mixins: [ViewHelper],
  async beforeRouteLeave(to, from, next) {
    if (to.name != "signin") {
      const answer = await confirmAllowDiscardChangesInMultiPatList();
      next(answer === 1);
    } else {
      next();
    }
  },
  data() {
    return {
      historyKey: HISTORY_KEY_MULTI_PAT_LIST,
      selfScreenName: "",
      patRecords: [],
      // add #11708 データリスト患者情報1の身体情報系データを含むレイアウトが画面表示しない。 fang start
      loadFlag: false,
      // add #11708 データリスト患者情報1の身体情報系データを含むレイアウトが画面表示しない。 fang end
      ordArr: {
        // 前体重測定済のオーダー番号
        afterSendConditionArr: [],
        // 治療中のオーダー番号
        dialysisArr: [],
        // 治療終了のオーダー番号
        afterDialysisArr: []
      },
      // 吹き出し表示＞レイアウト変更時に一時保持
      tempSelectedLayout: {},
      // 吹き出し内＞実行押下時のフラグ
      isSearch: true
    };
  },
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou start
  watch: {
    searchedPatList: {
      handler() {
        this.getInfo()
      },
    },
    // add #11708 データリスト患者情報1の身体情報系データを含むレイアウトが画面表示しない。 fang start
    getLoadFlag: {
      handler() {
        this.loadFlag = this.getLoadFlag;
      }
    }
    // add #11708 データリスト患者情報1の身体情報系データを含むレイアウトが画面表示しない。 fang end
  },
  computed: {
    ...mapGetters("pat-info", ["searchedPatList"]),
    patIdListToDisplay() {
      return this.searchedPatList.map(el => el.pat_id);
    },
    // mod #11708 データリスト患者情報1の身体情報系データを含むレイアウトが画面表示しない。 fang start
    ...mapGetters("data-list", ["getSelectedDynamicLayout", "getLoadFlag"]),
    // mod #11708 データリスト患者情報1の身体情報系データを含むレイアウトが画面表示しない。 fang end
    handleShowNewLayout() {
      return this.isSearch && this.getSelectedDynamicLayout && (this.getSelectedDynamicLayout.templateCd == DATE_TEMPLATE_CD || this.getSelectedDynamicLayout.templateCd == MONTH_TEMPLATE_CD);
    },
    handleShowNewLayout2() {
      return this.isSearch && this.getSelectedDynamicLayout && this.getSelectedDynamicLayout.templateCd == PAT_INFO_TEMPLATE_CD && this.patRecords
    },
    handleShowNewLayout3() {
      return this.isSearch && this.getSelectedDynamicLayout && (this.getSelectedDynamicLayout.templateCd == PAT_INFO_TWO_TEMPLATE_CD
        || this.getSelectedDynamicLayout.templateCd == TREATMENT_PLAN_TREATMENT_RECORD
        || this.getSelectedDynamicLayout.templateCd == VITAL_MONITORS_COMPLAINTS_CD
        || this.getSelectedDynamicLayout.templateCd == INSPECTION_RADIATION
        || this.getSelectedDynamicLayout.templateCd == DEVICE_SET)
    },
    handleShowNewLayout4() {
      return this.isSearch && this.getSelectedDynamicLayout && this.getSelectedDynamicLayout.templateCd == EQUIPMENT_INFORMATION_WATER_QUALITY_SURVEY
    },
    handleShowNewLayout5() {
      return this.isSearch && this.getSelectedDynamicLayout && this.getSelectedDynamicLayout.templateCd == EQUIPMENT_INFORMATION_SELF_DIAGNOSIS
    },
    handleShowNewLayout6() {
      return this.isSearch && this.getSelectedDynamicLayout && this.getSelectedDynamicLayout.templateCd == EQUIPMENT_INFORMATION_INSPECTION_DAILY_REGULAR
    },
    handleShowNewLayout7() {
      return this.isSearch && this.getSelectedDynamicLayout && this.getSelectedDynamicLayout.templateCd == COLLECTIVE_DAILY_REGULAR
    }
  },
  created() {
    // メニュー遷移時はフラグOFF、パンくずリスト押下、ブラウザバックの時はON
    const functionCd = this.$route.query.function_cd ?? this.$route.params.function_cd;
    this.isSearch = !functionCd;
    this.setLoadFlag(!functionCd);
    // ファイル出力ボタン活性or非活性
    this.$nextTick(() => {
      EventBus.$emit("allowEditTrue", !this.isSearch);
    });
    
    // 画面名称取得
    this.selfScreenName = this.$route.name;
    EventBus.$on("refresh", this.getInfo);
    this.getInfo();
  },
  beforeUnmount() {
    // add #11708 データリスト患者情報1の身体情報系データを含むレイアウトが画面表示しない。 fang start
    this.setLoadFlag(false);
    // add #11708 データリスト患者情報1の身体情報系データを含むレイアウトが画面表示しない。 fang end
    this.setIsDataChanged(false);
    EventBus.$off("refresh", this.getInfo);
  },
  methods: {
    ...mapActions("loading-screen", ["startLoadingScreen", "finishLoadingScreen"]),
    // add #11708 データリスト患者情報1の身体情報系データを含むレイアウトが画面表示しない。 fang start
    ...mapActions("data-list", ["setLoadFlag", "setSelectedDynamicLayout", "setSelectedLayout", "setIsDataChanged"]),
    // add #11708 データリスト患者情報1の身体情報系データを含むレイアウトが画面表示しない。 fang end
    newArrFn(arr) {
      return ([...new Set(arr)])
    },
    async getInfo() {
      if (this.selfScreenName !== this.$route.name) {
        return;
      }

      // 患者情報1で変更がある場合、破棄確認メッセージを表示
      const answer = await confirmAllowDiscardChangesInMultiPatList();
      if (answer === 1) {
        // 破棄確認OK or 変更なし
        this.getData();
      }
    },
    getData(){
      /* 治療状況の配色リスト生成 */
      let ordArr = {
        afterSendConditionArr: [],
        dialysisArr: [],
        afterDialysisArr: []
      };
      this.startLoadingScreen();
      getPatRecords(this.patIdListToDisplay).then((res) => {
        this.patRecords = res;
        if (res.length > 0) {
          for (const gridPat of res) {
            this.processGridPat(gridPat, ordArr);
          }
          this.ordArr.afterSendConditionArr = this.newArrFn(ordArr.afterSendConditionArr) || [];
          this.ordArr.dialysisArr = this.newArrFn(ordArr.dialysisArr) || [];
          this.ordArr.afterDialysisArr = this.newArrFn(ordArr.afterDialysisArr) || [];
        } else {
          // 患者検索で患者リストが0件の場合、表示中のコンテンツをクリアする
          const toggleSearch = () => {
            this.isSearch = false;
            this.$nextTick(() => (this.isSearch = true));
          };
          if (this.handleShowNewLayout2 || this.handleShowNewLayout3) toggleSearch();
        }
      }).catch(() => {
        this.patRecords = [];
      }).finally(() => {
        this.finishLoadingScreen();
      });
    },
    /** 患者基本情報の治療進捗状態内の治療状況判定処理呼び出し */ 
    processGridPat(gridPat, ordArr) {
      const statusInfo = gridPat.pat_main.acceptance_status_info;
      if (statusInfo.length > 0) {
        for (const info of statusInfo) {
          this.processPatient(info, ordArr);
        }
      }
    },
    /** 患者基本情報の治療進捗状態から治療中情報を抽出します */ 
    processPatient(info, ordArr) {
      const classMap = {
        "1": "afterSendConditionArr",
        "2": "afterSendConditionArr",
        "3": "dialysisArr",
        "4": "afterDialysisArr",
        "5": "afterDialysisArr"
      };
      const targetArray = classMap[info.class];
      if (targetArray) {
        ordArr[targetArray].push(info.ord_no);
      }
    },
    /** 吹き出し表示＞レイアウト変更時に一時保持 */ 
    onLayoutChange(layout) {
      this.tempSelectedLayout = layout;
    },
    /** 吹き出し内＞実行押下時にisSearchフラグをON & ストアを書き換える */ 
    onSearch() {
      this.isSearch = true;
      // store書き換え
      this.setSelectedDynamicLayout(this.tempSelectedLayout);
      this.setSelectedLayout(this.tempSelectedLayout.dispItemInfo);
    }
  }
};
</script>
