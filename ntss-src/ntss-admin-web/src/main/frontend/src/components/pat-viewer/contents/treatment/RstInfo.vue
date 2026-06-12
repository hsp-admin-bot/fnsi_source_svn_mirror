/** * TODO: 患者経過総合ビューア 表示項目テンプレート ※ここにタイトルを記載 */
<template>
  <base-content
    :disp-data-list="rstInfoDataList"
    :is-able-lf="true"
    @onSubTitleClick="onSubTitleClick"
    @onCellClick="onCellClick"
  />
</template>

<script>
/**
 * Vue関連
 */
import { mapGetters, mapActions } from "@/compat/vue/vuex";

/**
 * ベースコンポーネント
 * @summary このコンポーネントへ、表示する情報を渡す
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
    },

    /**
     * 中項目カテゴリー情報
     */
    subCategory: {
      type: Object,
      default: () => {}
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
       */
      rstInfoDataList: []
    };
  },

  computed: {
    // mod #12462 患者情報共有->患者経過総合ビューア fang start
    // ...mapGetters("pat-info", {
    //   facilityCd: "selectedPatFacilityCd"
    // })
    ...mapGetters("user", {facilityCd: "getFacilityCd"}),
    // mod #12462 患者情報共有->患者経過総合ビューア fang end
  },

  async created() {
    // 表示用実績情報変換処理
    this.startLoadingScreen();
    await this.convertRstInfo({
      facilityCd: this.facilityCd,
      listIndex: this.rowIndex,
      selectLayoutCd: this.selectedLayoutCd,
      subCategory: this.subCategory
    }).then(rstInfoDataList => {
      this.rstInfoDataList = rstInfoDataList;
    }).finally(() => {
      this.finishLoadingScreen();
    });
  },

  beforeUnmount() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },

  methods: {
    ...mapActions("pat-viewer", ["convertRstInfo"]),
    ...mapActions("treatment-record/common", ["setOrdNo"]),
    ...mapActions("loading-screen", [
      "startLoadingScreen",
      "finishLoadingScreen",
    ]),

    /**
     * 実績情報サブタイトルクリック時処理
     */
    onSubTitleClick(event, rowInfo) {
      // すべて過去日の場合、操作不可メッセージを表示
      if (this.getIsPastDate) {
        this.showDisProcMessage();
        return;
      }

      // 一覧上に治療予定がない場合は処理終了
      if (!this.isTreatPlan) {
        return;
      }
      // 直近日を取得
      const recentDate = this.getRecentBaseDate();
      if (!recentDate) {
        return;
      }
      // 直近日の治療予定に実績が存在するかチェック
      const rstInfo = rowInfo.data.find(
        ({ ordNo }) => ordNo === this.ordMainData[recentDate].ordNo
      ).value1;

      if (rstInfo === null) {
        return;
      }
      // 遷移先情報リスト
      const routerInfoList = ["treatment-record"];
      routerInfoList.push(this.getTransitionInfo(rowInfo.itemNo));

      // 治療実績に画面遷移
      this.setRouter(this.getOrdNo(recentDate), routerInfoList);
    },

    /**
     * 実績情報データセルクリック時の処理
     */
    onCellClick(event, cellInfo) {
      // 治療予定か実績が存在しない場合処理終了
      if (null === cellInfo.ordNo || null === cellInfo.value1) {
        return;
      }

      if(cellInfo.isNotClickable) {
        return;
      }
      const routerInfoList = new Array();
      // 治療記録
      routerInfoList.push("treatment-record");
      // 治療記録内の遷移先情報を格納
      routerInfoList.push(this.getTransitionInfo(cellInfo.rstCd));
      // 治療記録画面へ画面遷移
      this.setRouter(cellInfo.ordNo, routerInfoList);
    },

    /**
     * 遷移先情報取得
     * @param cd 実績識別番号
     */
    getTransitionInfo(cd) {
      let name;
      switch (cd) {
        /**
         * 治療開始日、治療終了日、入外区分、透析回数、
         * 穿刺者名1、穿刺者名2、穿刺日時、返血者名1、
         * 返血者名2、返血日時、担当者名1、担当者名2、
         * 透析運転時間
         */
        case 1:
        case 2:
        case 3:
        case 4:
        case 6:
        case 7:
        case 8:
        case 9:
        case 10:
        case 11:
        case 12:
        case 13:
        case 14:
          // 実績へ遷移
          name = "treatment-record-result";
          break;

        case 5:
        case 15:
        case 18:
        case 19:
        case 20:
        case 21:
        case 22:
        case 23:
        case 24:
        case 25:
        case 26:
        case 27:
        case 28:
        case 29:
        case 30:
        case 31:
        case 32:
        case 33:
        case 34:
        case 35:
          // 体重へ遷移
          name = "treatment-record-weight";
          break;

        // 透析記録確認日時, 送信管理番号
        case 16:
        case 17:
          break;

        // 前血圧・後血圧・体温(1回目)・体温(最終)
        case 36:
        case 37:
        case 38:
        case 39:
          name = "treatment-record-vital";
          break;

        // 愁訴処置情報
        case 40:
          // 愁訴措置へ遷移
          name = "treatment-record-complaint";
          break;

        // 回診記録情報
        case 41:
          // 回診記録へ遷移
          name = "treatment-record-round";
          break;

        // 加算・管理料
        case 46:
          // 加算・管理料へ遷移
          name = "treatment-record-addition-info";
          break;

        default:
          break;
      }
      return name;
    }
  }
};
</script>

<style scoped lang="scss">
/* 患者経過総合ビューア共通スタイル定義 */
@use "../../css/style.scss" as *;
</style>
