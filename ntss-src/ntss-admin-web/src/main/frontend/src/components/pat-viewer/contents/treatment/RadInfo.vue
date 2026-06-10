/** * 放射線検査 */
<template>
  <base-content
    class="rad-info-font"
    :func-name="funcName"
    :disp-data-list="radInfoDataList"
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
 * 共通操作
 */
import { deepCopy } from "@/functions/common/CommonFunctions";

/**
 * ベースコンポーネント
 * @summary このコンポーネントへ表示する情報を渡す
 */
import baseContent from "@/components/pat-viewer/contents/base/BaseContent";

/**
 * コンポーネント共通操作
 */
import BaseComponent from "@/components/pat-viewer/contents/base/BaseComponent";
// add #10036 患者経過総合ビューアの一般撮影検査依頼の表示不正 zhangbo start
import {RAD_REQUEST} from "@/constants/defaultSettingConstants";
// add #10036 患者経過総合ビューアの一般撮影検査依頼の表示不正 zhangbo end

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
      // mod FNSI-放射線検査の表示の修正 楊 start
      // default: null,
      default: 0,
      // mod FNSI-放射線検査の表示の修正 楊 end
      required: false
    },
    // add FNSI-放射線検査の表示の修正 楊 start
    /**
     * 患者経過総合ビューアレイアウトマスタ選択情報
     */
    layout: {
      type: Object,
      default: () => {}
    },
    // add FNSI-放射線検査の表示の修正 楊 end
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

      // add FNSI-検体検査の表示の修正 楊 start
      sendTreatDate: {
        // 日付範囲
        showStartDate: "",
        showEndDate: "",
      },
      // add FNSI-検体検査の表示の修正 楊 end

      /**
       * 表示するデータのリスト
       * @summary 親コンポーネントに渡す情報
       */
      radInfoDataList: []
    };
  },

  computed: {
    ...mapGetters("pat-info", ["selectedPatId"]),
    // add #10036 患者経過総合ビューアの一般撮影検査依頼の表示不正 zhangbo start
    ...mapGetters("account-edit", {
      getDefaultSetting:"getDefaultSetting"
    }),
    // add #10036 患者経過総合ビューアの一般撮影検査依頼の表示不正 zhangbo end
  },

  async created() {
    // 表示用に放射線検査データを加工
    this.startLoadingScreen();
    this.convertRadData({
      listIndex: this.rowIndex,
      // add FNSI-放射線検査の表示の修正 楊 start
      layout: this.layout,
      // add FNSI-放射線検査の表示の修正 楊 end
      selectLayoutCd: this.selectedLayoutCd
    }).then(radInfoDataList => {
      this.radInfoDataList = radInfoDataList;
    }).finally(() => {
      this.finishLoadingScreen();
    });
    // add FNSI-性能を最適化する 李 end
  },

  beforeDestroy() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },

  methods: {
    ...mapActions("pat-viewer", ["convertRadData"]),
    ...mapActions("pat-viewer-modal", ["showIndModal"]),
    // mod FNSI-放射線検査の表示の修正 楊 start
    // ...mapActions("rad-request/list", ["setSelectedPatId"]),
    ...mapActions("rad-request/list", ["setSelectedPatId", "updateStartToEndDate"]),
    // mod FNSI-放射線検査の表示の修正 楊 end
    ...mapActions("loading-screen", [
      "startLoadingScreen",
      "finishLoadingScreen",
    ]),
    /**
     * 「放射線検査」タイトルクリック時処理
     * @summary モーダル表示は行わない
     */
    onTitleClick() {},

    // mod FNSI-放射線検査の表示の修正 楊 start
    /**
     * 「放射線検査」サブタイトルクリック時処理
     * @summary モーダル表示は行わない
     */
    // onSubTitleClick() {},
    onSubTitleClick() {
      // 個別結果画面に遷移する
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
      let setDate = moment(this.baseDate);
      this.sendTreatDate.showStartDate = setDate.format("YYYY-MM-DD");
      this.sendTreatDate.showEndDate = setDate.add(3, 'months').format("YYYY-MM-DD");

      // 遷移先の期間に設定（基準日～3か月）
      this.updateStartToEndDate(this.sendTreatDate);
      // 患者ID
      this.setSelectedPatId(this.selectedPatId);

      // 個別結果画面に遷移する
      this.setRouter(null, [
        "rad-request",
        "rad-request-detail"
      ]);
    },
    // mod FNSI-放射線検査の表示の修正 楊 end

    /**
     * 「放射線検査」データセルクリック時処理
     * @summary 検査依頼or検査結果の個別画面に遷移
     */
    onCellClick(event, cellInfo, itemName, itemInfo, itemIndex, isIndClick) {

      // クリックしたセルに放射線検査がない場合は、処理終了
      if (null === cellInfo.value1 && null === cellInfo.value2) {
        return;
      }

      if(cellInfo.isNotClickable) {
        return;
      }
      // 指示項目クリック時以下の処理を実行する
      if (isIndClick) {

        // add FNSI-放射線検査の表示の修正 楊 start
        // クリックした日
        // mod #10036 患者経過総合ビューアの一般撮影検査依頼の表示不正 zhangbo start
          let setDate = moment(cellInfo.treatDate);
          if (!this.getDefaultSetting[RAD_REQUEST.KEY_NAME]) {
            this.sendTreatDate.showStartDate = setDate.format("YYYY-MM-DD");
            this.sendTreatDate.showEndDate = setDate.add(3, 'months').format("YYYY-MM-DD");
            this.updateStartToEndDate(this.sendTreatDate);
          }else{
            this.sendTreatDate.showStartDate = setDate.format("YYYY-MM-DD");
            // this.sendTreatDate.showEndDate = setDate.add(3, 'months').format("YYYY-MM-DD");
            const end= this.getDefaultSetting[RAD_REQUEST.KEY_NAME].endDate;
            switch (end) {
              case "25":
                this.sendTreatDate.showEndDate = setDate.add(3, 'months').format("YYYY-MM-DD");
                break;
              case "26":
                this.sendTreatDate.showEndDate = setDate.add(6, 'months').format("YYYY-MM-DD")
                break;
              case "27":
                this.sendTreatDate.showEndDate = setDate.add(1, 'years').format("YYYY-MM-DD");
                break;
              default:
                break;
            }
            // 遷移先の期間に設定（クリックした日～3か月）
            this.updateStartToEndDate(this.sendTreatDate);
            // add FNSI-放射線検査の表示の修正 楊 end
          }
        // add #10036 患者経過総合ビューアの一般撮影検査依頼の表示不正 zhangbo end
        this.setSelectedPatId(this.selectedPatId);
        this.setRouter(cellInfo.ordNo, [
          "rad-request",
          "rad-request-detail"
        ]);
      }
    }
  }
};
</script>

<style scoped lang="scss">
/* 患者経過総合ビューア共通スタイル定義 */
@import "../../css/style.scss";

/* ○と●が英文フォントだと小さく表示されるため、日本語フォント限定にする */
.rad-info-font {
  font-family: Osaka,Meiryo;
}
</style>
