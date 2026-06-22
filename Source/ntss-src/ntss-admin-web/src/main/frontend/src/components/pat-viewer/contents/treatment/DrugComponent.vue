/** * 患者経過総合ビュアー薬剤情報 */
<template>
  <div>
    <!-- mod FNSI-長期の薬剤グラフの表示を改善「235」 周 start -->
    <!-- <base-content :disp-data-list="weightDataList" :is-drug-graph="true" /> -->
    <base-content :disp-data-list="drugDataList" :is-drug-graph="true" />
    <!-- mod FNSI-長期の薬剤グラフの表示を改善「235」 周 end -->
  </div>
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

    // mod FNSI-長期の薬剤グラフの表示を改善「235」 周 start
    /**
     * 患者経過総合ビューアレイアウトマスタの表示中項目リスト
     */
    // categoryItem: {
    //   type: Array,
    //   default: () => []
    // }

    /**
     * 患者経過総合ビューアレイアウトマスタ選択情報
     */
    layout: {
      type: Object,
      default: () => {}
    }
    // mod FNSI-長期の薬剤グラフの表示を改善「235」 周 end
  },

  data() {
    return {
      /**
       * 表示するデータのリスト
       * @summary 親コンポーネントに渡す情報
       * fields -> デフォルト値
       * groupCd -> クリックした際に一緒に表示するグループコード
       */
      // mod FNSI-長期の薬剤グラフの表示を改善「235」 周 start
      // weightDataList: []
      drugDataList: []
      // mod FNSI-長期の薬剤グラフの表示を改善「235」 周 end
    };
  },

  computed: {
    // mod #12462 患者情報共有->患者経過総合ビューア fang start
    ...mapGetters("pat-info", {
      patId: "selectedPatId",
      // facilityCd: "selectedPatFacilityCd"
    }),
    ...mapGetters("pat-info", ["selectedPatId"]),
    ...mapGetters("user", {facilityCd: "getFacilityCd"}),
    // mod #12462 患者情報共有->患者経過総合ビューア fang end
  },

  async created() {
    // 薬剤情報「計算材料保持テーブル」を表示用に加工
    this.startLoadingScreen();
    this.convertDrugInfo({
      listIndex: this.rowIndex,
      layout: this.layout,
      facilityCd: this.facilityCd,
      patId: this.patId,
      weekPattern: `[{ 'text': '全', 'done': true, 'value': 0 }]`,
      selectedPatId: this.selectedPatId
    }).then(drugDataList => {
      this.drugDataList = drugDataList;
    }).finally(() => {
      this.finishLoadingScreen();
    });
  },

  beforeUnmount() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },

  methods: {
    ...mapActions("pat-viewer", ["convertDrugInfo"]),
    ...mapActions("loading-screen", [
      "startLoadingScreen",
      "finishLoadingScreen",
    ]),
  }
};
</script>

<style scoped lang="scss">
@use "../../css/style.scss" as *;

/* 患者経過総合ビューア共通スタイル定義 */
div :deep(.list-content-col) {
  width: 0px;
}
</style>
