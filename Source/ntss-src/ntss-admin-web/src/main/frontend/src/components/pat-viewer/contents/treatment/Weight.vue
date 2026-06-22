/** * 患者経過総合ビュアー体重情報 */
<template>
  <div>
    <base-content :disp-data-list="weightDataList" :is-chart-rst="true" />
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
      weightDataList: []
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
    // 表示用に治療条件情報を加工
    this.startLoadingScreen();
    this.convertWeightInfo({
      listIndex: this.rowIndex,
      layout: this.layout,
      facilityCd: this.facilityCd,
      patId: this.patId,
      weekPattern: `[{ 'text': '全', 'done': true, 'value': 0 }]`
    }).then(weightDataList => {
      this.weightDataList = weightDataList;
    }).finally(() => {
      this.finishLoadingScreen();
    });
  },

  methods: {
    ...mapActions("pat-viewer", ["convertWeightInfo"]),
    ...mapActions("loading-screen", [
      "startLoadingScreen",
      "finishLoadingScreen",
    ]),
  },

  beforeUnmount() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
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
