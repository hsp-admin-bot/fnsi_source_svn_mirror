/** * 紹介状 */
<template>
  <base-content
    :func-name="funcName"
    :disp-data-list="letterInfoDataList"
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
 * 日付操作
 */

/**
 * 共通操作
 */

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
     * 一覧に表示する紹介状の行番号
     * @summary 何回目の治療予定かどうかの番号。表示に使用すデータの行番号となる
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

      sendTreatDate: {
        // 日付範囲
        startDate: "",
        endDate: "",
      },

      /**
       * 表示するデータのリスト
       * @summary 親コンポーネントに渡す情報
       */
      letterInfoDataList: []
    };
  },

  computed: {
    ...mapGetters("pat-info", ["selectedPatId"]),
  },

  async created() {
    this.startLoadingScreen();
    // 表示用に紹介状データを加工
    this.convertLetterData({
      listIndex: this.rowIndex,
      layout: this.layout,
      selectLayoutCd: this.selectedLayoutCd
    }).then(letterInfoDataList => {
      this.letterInfoDataList = letterInfoDataList;
    }).finally(() => {
      this.finishLoadingScreen();
    });
  },

  beforeUnmount() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },

  methods: {
    ...mapActions("pat-viewer", ["convertLetterData"]),
    ...mapActions("pat-viewer-modal", ["showIndModal"]),
    ...mapActions("pat-event/list", ["setConditionDate"]),
    ...mapActions("loading-screen", [
      "startLoadingScreen",
      "finishLoadingScreen",
    ]),

    /**
     * 「紹介状」タイトルクリック時処理
     * @summary モーダル表示は行わない
     */
    onTitleClick() {},

    /**
     * 「紹介状」サブタイトルクリック時処理
     * @summary モーダル表示は行わない
     */
    onSubTitleClick() {
      // すべて過去日の場合、操作不可メッセージを表示
      if (this.getIsPastDate) {
        this.showDisProcMessage();
        return;
      }

      // del bug 5948 修正 chen start
      // 一覧上に治療予定が無い場合は処理終了
      // if (!this.isTreatPlan) {
      //   return;
      // }
      // del bug 5948 修正 chen end

      // 基準日
      this.sendTreatDate.startDate = new Date(this.baseDate.substring(0, 4) + "-" + this.baseDate.substring(4, 6) + "-" + this.baseDate.substring(6, 8));
      // this.sendTreatDate.startDate.setMonth(this.sendTreatDate.startDate.getMonth() - 1);
      this.sendTreatDate.endDate = new Date(this.baseDate.substring(0, 4) + "-" + this.baseDate.substring(4, 6) + "-" + this.baseDate.substring(6, 8));
      this.sendTreatDate.endDate.setMonth(this.sendTreatDate.endDate.getMonth() + 1);

      // 遷移先の期間に設定（前後１カ月）
      this.setConditionDate(this.sendTreatDate);
      // mod 5948 紹介状画面に遷移する 張 start
      //紹介状画面に遷移する
      // this.$router.push({ name: "pat-event",params: { parentName:"letter" } });
      this.$router.push({ name: "pat-intro-letter",params: { parentName:"letter" } });
    },

    /**
     * 「紹介状」データセルクリック時処理
     */
    onCellClick(event, cellInfo, itemName, itemInfo, itemIndex, isIndClick) {
      //add 5317 患者経過総合ビューアの紹介状詳細をクリックした場合、紹介状画面へ遷移させて下さい。張 start
      // 基準日
      this.sendTreatDate.startDate = new Date(cellInfo.treatDate.substring(0, 4) + "-" +cellInfo.treatDate.substring(4, 6) + "-" + cellInfo.treatDate.substring(6, 8));
      this.sendTreatDate.endDate = new Date(cellInfo.treatDate.substring(0, 4) + "-" +cellInfo.treatDate.substring(4, 6) + "-" + cellInfo.treatDate.substring(6, 8));
      // 遷移先の期間に設定（前後１カ月）
      this.setConditionDate(this.sendTreatDate);

      // 紹介状画面に遷移する
      // this.$router.push({ name: "pat-event",params: { parentName:"letter" } });
      this.$router.push({ name: "pat-intro-letter",params: { parentName:"letter" } });
      // mod 5948 紹介状画面に遷移する 張 end
      //add 5317 患者経過総合ビューアの紹介状詳細をクリックした場合、紹介状画面へ遷移させて下さい。張 end
    }
  }
};
</script>

<style scoped lang="scss">

</style>
