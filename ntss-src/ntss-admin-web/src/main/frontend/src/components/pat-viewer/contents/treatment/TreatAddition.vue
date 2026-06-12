/** * 治療方法 */
<template>
  <base-content
    :func-name="funcName"
    :disp-data-list="treatMethodDataList"
    @onTitleClick="onTitleClick"
    @onSubTitleClick="onSubTitleClick"
    @onCellClick="onCellClick"
  />
</template>

<script>
/**
 * Vue関連
 */
import { mapActions, mapGetters } from "@/compat/vue/vuex";

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
     * 一覧に表示する治療情報の行番号
     * @summary 何回目の治療予定かどうかの番号。表示に使用すデータの行番号となる
     */
    rowIndex: {
      type: Number,
      default: null,
      required: false
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
      treatMethodDataList: []
    };
  },

  computed: {
    ...mapGetters("pat-viewer", ["getMstKurData", "getMstBedData"]),
    ...mapGetters("pat-viewer-modal", ["getDefaultSettingIndTreatMethodData"]),
    ...mapGetters("pat-viewer", ["getTreatmentData"]),
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("pat-info", ["selectedPatId"]),

    /**
     * スケジュール(IndEditBase)に渡すデータ(雛形)
     */
    faultSettingScheduleData() {
      return this.getDefaultSettingIndTreatMethodData;
    },

    /**
     * クールマスタデータ
     */
    mstKurData() {
      return this.getMstKurData;
    },

    /**
     * ベッドマスタデータ
     */
    mstBedData() {
      return this.getMstBedData;
    }
  },

  beforeUnmount() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },

  async created() {
    // 表示用に治療方法データを加工
    this.startLoadingScreen();
    this.convertTreatAdditionData({
      listIndex: this.rowIndex,
      selectLayoutCd: this.selectedLayoutCd,
      patId: this.selectedPatId,
      facilityCd: this.getFacilityCd
    }).then(treatMethodDataList => {
      this.treatMethodDataList = treatMethodDataList;
    }).finally(() => {
      this.finishLoadingScreen();
    });
  },

  methods: {
    ...mapActions("pat-viewer", ["convertTreatAdditionData"]),
    ...mapActions("pat-viewer-modal", ["showIndModal"]),
    ...mapActions("loading-screen", [
      "startLoadingScreen",
      "finishLoadingScreen",
    ]),

    /**
     * 「治療方法」タイトルクリック時処理
     * @summary 治療方法編集モーダル表示
     */
    onTitleClick() {
    },

    /**
     * 「治療方法」サブタイトルクリック時処理
     * @summary 治療方法編集モーダル表示
     */
    onSubTitleClick() {
      // すべて過去日の場合、操作不可メッセージを表示
      if (this.getIsPastDate) {
        this.showDisProcMessage();
        return;
      }

      // 一覧上に治療予定がない場合は処理終了
      if (!this.isTreatPlan) {
        return;
      }
    },

    /**
     * 「医療材料」データセルクリック時処理
     * @summary 医療材料編集モーダル表示
     */
    onCellClick(event, cellInfo) {

      if(cellInfo.ordNo){
        // 治療記録に画面遷移する
        this.setRouter(cellInfo.ordNo, ["treatment-record-addition-info"]);
      }

    }
  }
};
</script>

<style scoped lang="scss">
/* 患者経過総合ビューア共通スタイル定義 */
@use "../../css/style.scss" as *;
</style>
