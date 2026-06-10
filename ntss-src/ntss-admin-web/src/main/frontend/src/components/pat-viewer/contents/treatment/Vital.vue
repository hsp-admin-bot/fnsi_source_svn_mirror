/** * 患者経過総合ビュアーバイタル */
<template>
  <div>
    <base-content :disp-data-list="vitalDataList" :is-chart-rst="true" />
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
     * 中項目カテゴリー情報
     * (中項目として呼び出される場合ー1日単位)
     */
    subCategory: {
      type: Object
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
      vitalDataList: []
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
    // add FNSI-性能を最適化する 李 end
    if(this.subCategory!=null&&(58<=this.subCategory.categoryNo<=61||65<=this.subCategory.categoryNo<=72)){
        this.convertVitalInfoDuringTreatment({
          listIndex: this.rowIndex,
        // 入室～退室対応
        layout: this.subCategory && this.subCategory.subClassify ? {
          categoryItem: [...this.subCategory.categoryItem],
          categoryName: this.subCategory.categoryName,
          categoryNo: this.subCategory.categoryNo
        } : this.subCategory ? {
          categoryItem: [this.subCategory],
          categoryName: this.subCategory.subCategoryName,
          categoryNo: this.subCategory.subCategoryNo
        } : this.layout,
        // mod FNSI-グラフ３軸表示対応「230」バイタル・モニタグラフ分（入室～退室） 周 end
        facilityCd: this.facilityCd,
        patId: this.patId,
        weekPattern: `[{ 'text': '全', 'done': true, 'value': 0 }]`
      }).then(vitalDataList => {
        this.vitalDataList = vitalDataList;
      }).finally(() => {
        this.finishLoadingScreen();
      });
      // add FNSI-性能を最適化する 李 end

    }else{
      this.convertVitalInfo({
        listIndex: this.rowIndex,
        // mod FNSI-グラフ３軸表示対応「230」バイタル・モニタグラフ分（入室～退室） 周 start
        // layout: this.subCategory ? {
          //   categoryItem: [this.subCategory],
        //   categoryName: this.subCategory.subCategoryName,
        //   categoryNo: this.subCategory.subCategoryNo
        // } : this.layout,

        // 入室～退室対応
        layout: this.subCategory && this.subCategory.subClassify ? {
          categoryItem: [...this.subCategory.categoryItem],
          categoryName: this.subCategory.categoryName,
          categoryNo: this.subCategory.categoryNo
        } : this.subCategory ? {
          categoryItem: [this.subCategory],
          categoryName: this.subCategory.subCategoryName,
          categoryNo: this.subCategory.subCategoryNo
        } : this.layout,
        // mod FNSI-グラフ３軸表示対応「230」バイタル・モニタグラフ分（入室～退室） 周 end
        facilityCd: this.facilityCd,
        patId: this.patId,
        weekPattern: `[{ 'text': '全', 'done': true, 'value': 0 }]`
      }).then(vitalDataList => {
        this.vitalDataList = vitalDataList;
      }).finally(() => {
        this.finishLoadingScreen();
      });
      // add FNSI-性能を最適化する 李 end
    }
      // mod 5930 バイタル・モニタグラフ入室～退室のマスタおよび画面表示不正 張 end
  },

  beforeDestroy() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },

  methods: {
    // mod 5930 バイタル・モニタグラフ入室～退室のマスタおよび画面表示不正 張 start
    // ...mapActions("pat-viewer", ["convertVitalInfo"])
    ...mapActions("pat-viewer", ["convertVitalInfo","convertVitalInfoDuringTreatment"]),
    // mod 5930 バイタル・モニタグラフ入室～退室のマスタおよび画面表示不正 張 start
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
