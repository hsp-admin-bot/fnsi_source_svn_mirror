/** * 処方 */
/** add FNSI-処方を追加 姜 */
<template>
  <base-content
    :func-name="funcName"
    :disp-data-list="obserInfoDataList"
    @onTitleClick="onTitleClick"
    @onSubTitleClick="onSubTitleClick"
    @onCellClick="onCellClick"
  />
</template>

<script>
/**
 * Vue関連
 */
import { mapActions, mapGetters } from "vuex";

/**
 * ベースコンポーネント
 * @summary このコンポーネントへ表示する情報を渡す
 */
import baseContent from "@/components/pat-viewer/contents/base/BaseContent";

/**
 * コンポーネント共通操作
 */
import BaseComponent from "@/components/pat-viewer/contents/base/BaseComponent";

export default {
  components: {
    "base-content": baseContent
  },

  mixins: [BaseComponent],

  props: {
    /**
     * 一覧に表示する処方の行番号
     * @summary 何回目の処方かどうかの番号。表示に使用すデータの行番号となる
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
    };
  },

  computed: {
    ...mapGetters("pat-info", ["selectedPatId"]),
  },


  async created() {
    this.startLoadingScreen();
    // 表示用に患者イベント（仮）データを加工
    this.convertPrescriptionDataList({
      layout: this.layout,
      selectLayoutCd: this.selectedLayoutCd
    }).then(obserInfoDataList => {
      this.obserInfoDataList = obserInfoDataList;
    }).finally(() => {
      this.finishLoadingScreen();
    });
  },

  beforeDestroy() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },

  methods: {
    ...mapActions("pat-viewer", ["convertPrescriptionDataList"]),
    ...mapActions("pat-viewer-modal", ["showIndModal"]),
    ...mapActions("pat-event/list", ["setSelectedPatId", "setConditionDate"]),
    ...mapActions("pat-prescription", {preSetTreatBaseDate: "setTreatBaseDate"}),
    ...mapActions("loading-screen", [
      "startLoadingScreen",
      "finishLoadingScreen",
    ]),

    onCellClick(event, cellInfo){

    // 処方へ遷移
        const treatDateList = [cellInfo.treatDate, new Date()];
        this.preSetTreatBaseDate(treatDateList).then(() => {
          this.$router.push({ name: "prescription"});
          this.$router.push({ name: "pat-prescription", params: { condition: cellInfo}});
        })
    },
    onSubTitleClick(event, rowInfo) {
      const treatDateList = [rowInfo.treatDate, new Date()];
        this.preSetTreatBaseDate(treatDateList).then(() => {
          this.$router.push({ name: "prescription"});
          this.$router.push({ name: "pat-prescription", params: { condition: rowInfo}});
        })
    },

    onTitleClick(event) {
      const treatDateList = [cellInfo.treatDate, new Date()];
        this.preSetTreatBaseDate(treatDateList).then(() => {
          this.$router.push({ name: "prescription"});
          this.$router.push({ name: "pat-prescription", params: { condition: event}});
        })
    }
  }
};
</script>
