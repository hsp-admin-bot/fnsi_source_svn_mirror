/** * 患者経過総合ビュアー複合情報 */
<template>
  <div>
    <base-content :disp-data-list="comprehensiveDataList" :is-comprehensive-graph="true" />
  </div>
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

export default {
  components: {
    "base-content": baseContent
  },

  props: {
    /**
     * 一覧に表示する治療情報の行番号
     * @summary 何回目の治療予定かどうかの番号(表示に使用すデータの行番号となる)
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
    },

    /**
     * 患者経過総合ビューアレイアウトマスタ選択情報
     */
    layout: {
      type: Object,
      default: () => {}
    }
  },

  data() {
    return {
      /**
       * 表示するデータのリスト
       * @summary 親コンポーネントに渡す情報
       * fields -> デフォルト値
       * groupCd -> クリックした際に一緒に表示するグループコード
       */
      comprehensiveDataList: []
    };
  },

  computed: {
    // mod #12462 患者情報共有->患者経過総合ビューア fang start
    ...mapGetters("pat-info", {
      patId: "selectedPatId",
      // facilityCd: "selectedPatFacilityCd"
    }),
    ...mapGetters("user", {facilityCd: "getFacilityCd"}),
    // mod #12462 患者情報共有->患者経過総合ビューア fang end
  },

  async created() {
    // 複合グラフ情報「計算材料保持テーブル、治療情報」を表示用に加工
    this.startLoadingScreen();
    this.convertComprehensiveInfo({
      listIndex: this.rowIndex,
      layout: this.layout,
      facilityCd: this.facilityCd,
      patId: this.patId,
      weekPattern: `[{ 'text': '全', 'done': true, 'value': 0 }]`
    }).then(comprehensiveDataList => {
      this.comprehensiveDataList = comprehensiveDataList;
    }).finally(() => {
      this.finishLoadingScreen();
    });
  },

  beforeDestroy() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },

  methods: {
    ...mapActions("pat-viewer", ["convertComprehensiveInfo"]),
    ...mapActions("loading-screen", [
      "startLoadingScreen",
      "finishLoadingScreen",
    ]),
  }
};
</script>

<style scoped lang="scss">
/* 患者経過総合ビューア共通スタイル定義 */
@import "../../css/style.scss";

div /deep/ .list-content-col {
  width: 0px;
}
</style>
