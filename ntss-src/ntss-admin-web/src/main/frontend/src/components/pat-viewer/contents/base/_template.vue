/**
 * TODO: 患者経過総合ビューア 表示項目テンプレート ※ここにタイトルを記載
 */
<template>
  <base-content :funcName="funcName" :dispDataList="xxxxxDataList" />
</template>

<script>
/**
 * Vue関連
 */
// TODO: 必要な場合、コメント解除
//import { mapActions } from "@/compat/vue/vuex";

/**
 * ベースコンポーネント
 * @summary このコンポーネントへ、表示する情報を渡す
 */
import baseContent from "@/components/pat-viewer/contents/base/BaseContent";

export default {
  components: {
    "base-content": baseContent
  },

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
       * @summary
       *   親コンポーネントに渡す情報
       *   null (空文字)に設定することで縦列エリアを非表示とすることが可能
       */
      funcName: null,

      /**
       * 表示するデータのリスト
       * @summary 親コンポーネントに渡す情報
       * TODO:以下変数名xxxxをリネームし、<template>内で使用している箇所にも適用 ※実装時はこのコメントは消すこと
       */
      xxxxxDataList: []
    };
  },

  async created() {
    // TODO: 治療情報データを表示用に加工(以下、実装例) ※実装時はこのコメントは消すこと
    // 表示用にXXXX情報を加工
    // this.treatDataList = await this.convertTreatCondData({
    //   listIndex: this.rowIndex,
    //   selectLayoutCd: this.selectedLayoutCd
    // });
  },

  methods: {
    // TODO: 治療情報データを表示用に加工するmethod(以下、実装例) ※実装時はこのコメントは消すこと
    //...mapActions("pat-viewer", ["convertTreatCondData"])
  }
};
</script>

<style scoped lang="scss">
/* 患者経過総合ビューア共通スタイル定義 */
@use "../../css/style.scss" as *;
</style>
