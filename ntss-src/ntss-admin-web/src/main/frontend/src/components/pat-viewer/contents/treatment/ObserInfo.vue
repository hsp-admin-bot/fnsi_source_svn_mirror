/** * 観察記録 */
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
 * 日付操作
 */
import moment from "moment";

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
     * 一覧に表示する観察記録の行番号
     * @summary 何回目の観察記録かどうかの番号。表示に使用すデータの行番号となる
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

      // パラメータ
      sendTreatDate: {
        // 日付範囲
        startDate: "",
        endDate: ""
      },

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
    // 表示用に観察記録データを加工
    this.convertObserData({
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
    ...mapActions("pat-viewer", ["convertObserData"]),
    ...mapActions("pat-viewer-modal", ["showIndModal"]),
    ...mapActions("observe-record/list", ["updateStartToEndDate"]),
    ...mapActions("loading-screen", [
      "startLoadingScreen",
      "finishLoadingScreen",
    ]),
    /**
     * 「観察記録」タイトルクリック時処理
     * @summary モーダル表示は行わない
     */
    onTitleClick() {},

    /**
     * 「観察記録」サブタイトルクリック時処理
     * @summary モーダル表示は行わない
     */
    onSubTitleClick() {
      // すべて過去日の場合、操作不可メッセージを表示
      if (this.getIsPastDate) {
        this.showDisProcMessage();
        return;
      }

      // 一覧上に治療予定が無い場合は処理終了
      if (!this.isTreatPlan) {
        return;
      }

      // 基準日
      this.sendTreatDate.startDate = new Date(this.baseDate.substring(0, 4) + "-" + this.baseDate.substring(4, 6) + "-" + this.baseDate.substring(6, 8));
      this.sendTreatDate.startDate.setDate(this.sendTreatDate.startDate.getDate() - 7);
      this.sendTreatDate.endDate = new Date(this.baseDate.substring(0, 4) + "-" + this.baseDate.substring(4, 6) + "-" + this.baseDate.substring(6, 8));
      this.sendTreatDate.endDate.setDate(this.sendTreatDate.endDate.getDate() + 7);

      // 遷移先の期間に設定（基準日から前後一週間）
      this.updateStartToEndDate(this.sendTreatDate);

      // 観察記録画面に遷移する
      this.setRouter(null, [
        "observe-record"
      ]);
    },

    /**
     * 「観察記録」データセルクリック時処理
     * @summary 患者イベント画面に遷移
     */
    onCellClick(event, cellInfo, itemName, itemInfo, itemIndex, isIndClick) {

      // クリックしたセルに観察記録がない場合は、処理終了
      if (null === cellInfo.value1 && null === cellInfo.value2) {
        return;
      }

      if(cellInfo.isNotClickable) {
        return;
      }
      // 指示項目クリック時以下の処理を実行する
      // 患者イベント画面に遷移する
      this.setRouter(cellInfo.ordNo, [
        "pat-event"
      ]);
    }
  }
};
</script>

<style scoped>

</style>

