/** * 患者イベント（仮） */
<template>
  <base-content
    :func-name="funcName"
    :disp-data-list="obserInfoDataList"
    @onCellClick="onCellClick"
  />
</template>

<script>
  /**
   * Vue関連
   */
  import {mapActions, mapGetters} from "@/compat/vue/vuex";
  /**
   * 日付操作
   */
  import dayjs from "@/compat/date/dayjs";
  /**
   * ベースコンポーネント
   * @summary このコンポーネントへ表示する情報を渡す
   */
  import baseContent from "@/components/pat-viewer/contents/base/BaseContent";
  /**
   * コンポーネント共通操作
   */
  import BaseComponent from "@/components/pat-viewer/contents/base/BaseComponent";
// add 患者経過総合ビューア画面から画面遷移した際の動作不正 張 start
  import {
    sendRequestGetPatEventCateMst,
    sendRequestGetPatSubEventCateMst
  } from "@/apis/facility-calendar";
// add 患者経過総合ビューア画面から画面遷移した際の動作不正 張 end
  export default {
  components: {
    "base-content": baseContent
  },

  mixins: [BaseComponent],

  props: {
    /**
     * 一覧に表示する患者イベント（仮）の行番号
     * @summary 何回目の患者イベント（仮）かどうかの番号。表示に使用すデータの行番号となる
     */
    rowIndex: {
      type: Number,
      default: 0,
      required: false
    },

    /**
     * 患者経過総合ビューアレイアウトマスタ選択情報
     */
    layout: {
      type: Object,
      default: () => {}
    },

    /**
     * 患者経過総合ビューアレイアウトマスタ選択コード
     */
    selectedLayoutCd: {
      type: Number,
      default: -1,
      required: false
    }
  },

  data() {
    return {
      /**
       * 項目列の縦文字タイトル
       * @summary 親コンポーネントに渡す情報
       */
      funcName: null,

      /**
       * 表示するデータのリスト
       * @summary 親コンポーネントに渡す情報
       */
      obserInfoDataList: []
// add 患者経過総合ビューア画面から画面遷移した際の動作不正 張 start
      ,mstPatEventCategory:[],
      mstPatEventSubCategory:[],
// add 患者経過総合ビューア画面から画面遷移した際の動作不正 張 end
    };
  },

  computed: {
    ...mapGetters("pat-info", ["selectedPatId"]),
  },

  async created() {
    this.startLoadingScreen();
    // 表示用に患者イベント（仮）データを加工
    this.convertPatientData({
      layout: this.layout,
      selectLayoutCd: this.selectedLayoutCd
    }).then(obserInfoDataList => {
      this.obserInfoDataList = obserInfoDataList;
    }).finally(() => {
      this.finishLoadingScreen();
    });
    // add FNSI-性能を最適化する 李 end
    sendRequestGetPatEventCateMst(this.selectedPatId).then(res => {
        this.mstPatEventCategory=res.data.localDataSource.data.filter(item => item.isDisp)
    });
    sendRequestGetPatSubEventCateMst(this.selectedPatId).then(res => {
        this.mstPatEventSubCategory=res.data.localDataSource.data.filter(item => item.isDisp)
    });
  },

  beforeUnmount() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },

  methods: {
    ...mapActions("pat-viewer", ["convertPatientData"]),
    ...mapActions("pat-viewer-modal", ["showIndModal"]),
    // mod FNSI-FutreNetWeb+SI課題管理No.5318 李 start
    ...mapActions("pat-event/list", ["setSelectedPatId", "setConditionDate", "setTreatBaseDate"]),
    // mod FNSI-FutreNetWeb+SI課題管理No.5318 李 end
    ...mapActions("loading-screen", [
      "startLoadingScreen",
      "finishLoadingScreen",
    ]),
    /**
     * 「患者イベント」データセルクリック時処理
     * @summary 患者イベント表示
     * @param cellInfo セル情報
     */
    onCellClick(event, cellInfo, itemName, itemInfo, itemIndex, isIndClick) {
      // add FNSI-FutreNetWeb+SI課題管理No.5318 李 start
      // 患者イベント画面に遷移
      let subPatEvent = [];
      let patEvent = [];
      if (itemInfo[itemIndex].isPatEventSub === 1) {
        // サブカテゴリがクリックされた場合はサブカテゴリ, カテゴリを取得
        subPatEvent = this.mstPatEventSubCategory.find(item=>item.code===itemInfo[itemIndex].itemNo);
        patEvent= this.mstPatEventCategory.find(item=>item.code===subPatEvent?.categoryCd)
      } else {
        // カテゴリがクリックされた場合はカテゴリを取得
        patEvent= this.mstPatEventCategory.find(item=>item.code===itemInfo[itemIndex].itemNo)
      }
      const model = {
        type: "pat_event",
        treatDate: dayjs(cellInfo.treatDate).format('YYYY/MM/DD'),
        eventStartDate: cellInfo.treatDate,
        eventEndDate: cellInfo.treatDate,
        categoryCd:patEvent?patEvent.code:"",
        subCategoryCd:subPatEvent?subPatEvent.code:"",
        subCategoryName:subPatEvent?subPatEvent.name:"",
        categoryName:patEvent?patEvent.name:"",
      }
      const treatDateList = [model, new Date()];
      this.setTreatBaseDate(treatDateList).then(() => {
        this.$router.push({ name: "pat-event", params: { condition: model }});
      });
      // add FNSI-FutreNetWeb+SI課題管理No.5318 李 end
    }
  }
};
</script>
