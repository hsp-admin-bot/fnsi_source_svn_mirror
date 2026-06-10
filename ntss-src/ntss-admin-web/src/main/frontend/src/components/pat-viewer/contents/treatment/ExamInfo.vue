/** * 検体検査 */
<template>
  <base-content
    class="exam-info-font"
    :func-name="funcName"
    :disp-data-list="examInfoDataList"
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
 // mod #10036 患者経過総合ビューアの検査予定の表示不正 zhangbo start
import {EXAM_RECORD,EXAM_REQUEST} from "@/constants/defaultSettingConstants";
 // mod #10036 患者経過総合ビューアの検査予定の表示不正 zhangbo end

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
      // mod FNSI-検体検査の表示の修正 楊 start
      // default: null,
      default: 0,
      // mod FNSI-検体検査の表示の修正 楊 end
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
      examInfoDataList: []
    };
  },

  computed: {
    ...mapGetters("pat-info", ["selectedPatId"]),
     // add #10036 患者経過総合ビューアの検査予定の表示不正 zhangbo start
    ...mapGetters("account-edit", {
      getDefaultSetting:"getDefaultSetting"
    }),
     // add #10036 患者経過総合ビューアの検査予定の表示不正 zhangbo end
  },

  async created() {
    // 表示用に検体検査データを加工
    this.startLoadingScreen();
    this.convertExamData({
      listIndex: this.rowIndex,
      layout: this.layout,
      selectLayoutCd: this.selectedLayoutCd
    }).then(examInfoDataList => {
      this.examInfoDataList = examInfoDataList;
    }).finally(() => {
      this.finishLoadingScreen();
    });
  },

  beforeDestroy() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },

  methods: {
    ...mapActions("pat-viewer", ["convertExamData"]),
    ...mapActions("pat-viewer-modal", ["showIndModal"]),
    // add FNSI-検体検査の表示の修正 楊 start
    //...mapActions("exam-request/list", ["setSelectedPatId"]),
    ...mapActions("exam-request/list", ["setSelectedPatId", "updateStartToEndDate"]),
     // mod #10036 患者経過総合ビューアの検査予定の表示不正 zhangbo start
    ...mapActions("exam-record/list", ["setDetailCondition"]),
     // mod #10036 患者経過総合ビューアの検査予定の表示不正 zhangbo end
    // add FNSI-検体検査の表示の修正 楊 end
    ...mapActions("loading-screen", [
      "startLoadingScreen",
      "finishLoadingScreen",
    ]),
    /**
     * 「検体検査」タイトルクリック時処理
     * @summary モーダル表示は行わない
     */
    onTitleClick() {},

    // mod FNSI-検体検査の表示の修正 楊 start
    /**
     * 「検体検査」サブタイトルクリック時処理
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
        "exam-request",
        "exam-request-detail"
      ]);
    },
    // mod FNSI-検体検査の表示の修正 楊 end

    /**
     * 「検体検査」データセルクリック時処理
     * @summary 検査依頼or検査結果の個別画面に遷移
     */
    onCellClick(event, cellInfo, itemName, itemInfo, itemIndex, isIndClick) {

      // クリックしたセルに検査依頼がない場合は、処理終了
      if (null === cellInfo.value1 && null === cellInfo.value2) {
        return;
      }

      if(cellInfo.isNotClickable) {
        return;
      }
      // 指示項目クリック時以下の処理を実行する
      if (isIndClick) {
        // mod #10036 患者経過総合ビューアの検査予定の表示不正 zhangbo start
        if ("" === cellInfo.value1) {
          return;
        }
        // mod #10036 患者経過総合ビューアの検査予定の表示不正 zhangbo end
        // 個別依頼画面に遷移する
        // add FNSI-検体検査の表示の修正 楊 start
        // クリックした日
        // mod #10036 患者経過総合ビューアの検査予定の表示不正 zhangbo start
          let setDate = moment(cellInfo.treatDate);
          if (!this.getDefaultSetting[EXAM_REQUEST.KEY_NAME]) {
            this.sendTreatDate.showStartDate = setDate.format("YYYY-MM-DD");
            this.sendTreatDate.showEndDate = setDate.add(3, 'months').format("YYYY-MM-DD");
            this.updateStartToEndDate(this.sendTreatDate);
          }else {
            this.sendTreatDate.showStartDate = setDate.format("YYYY-MM-DD");
            // this.sendTreatDate.showEndDate = setDate.add(3, 'months').format("YYYY-MM-DD");
            const end = this.getDefaultSetting[EXAM_REQUEST.KEY_NAME].endDate;
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
            this.updateStartToEndDate(this.sendTreatDate);
        }
        // add FNSI-検体検査の表示の修正 楊 end
        // mod #10036 患者経過総合ビューアの検査予定の表示不正 zhangbo end
        this.setSelectedPatId(this.selectedPatId);
        this.setRouter(cellInfo.ordNo, [
          "exam-request",
          "exam-request-detail"
        ]);
      } else {
        // mod FNSI-検体検査の表示の修正 楊 start
        // クリックしたセルに検査結果がない場合は、処理終了
        // if (" " === cellInfo.value2) {
        //   return;
        // }
        // 個別結果画面に遷移する
        // 検査日を指定する("YYYY-MM-DD")
        // let sendTreatDate = moment(cellInfo.treatDate);

        // 2段階移動
        // this.$router.push({ name: "exam-record" });
        // this.$router.push({
        //   name: "exam-record-detail",
        //   params: { treatDate: sendTreatDate.format("YYYY-MM-DD") }
        //  });

        // クリックしたセルに検査結果がない場合は、処理終了
        if ("" === cellInfo.value2) {
          return;
        }
        // クリックした日
        // mod #10036 患者経過総合ビューアの検査予定の表示不正 zhangbo start
          const setDateStart = moment(cellInfo.treatDate);
          // this.sendTreatDate.showStartDate = setDate.format("YYYY-MM-DD");
          // this.sendTreatDate.showEndDate = setDate.add(3, 'months').format("YYYY-MM-DD");
          if (!this.getDefaultSetting[EXAM_RECORD.KEY_NAME] && !this.getDefaultSetting[EXAM_RECORD.KEY_NAME]) {
           let examDateStart = setDateStart.format("YYYY-MM-DD");
           const today = new Date();
           const year = today.getFullYear();
           const month = today.getMonth() + 1;
           const date = today.getDate();
           let examDateEnd = year + '-' + (month < 10 ? '0' + month : month) + '-' + (date < 10 ? '0' + date : date);
           const setCondition = {examDateSt : examDateStart,examDateEd : examDateEnd};
           this.setDetailCondition(setCondition);
          }else{
          const end = this.getDefaultSetting[EXAM_RECORD.KEY_NAME].examDateEd;
          const today = new Date();
          const year = today.getFullYear();
          const month = today.getMonth() + 1;
          const date = today.getDate();
          let setDateEnd = moment(cellInfo.treatDate);
          let examDateStart = setDateStart.format("YYYY-MM-DD");
          let examDateEnd = "";
          switch (end) {
            case "20":
              examDateEnd = year + '-' + (month < 10 ? '0' + month : month) + '-' + (date < 10 ? '0' + date : date);
              break;
            case "24":
              examDateEnd = setDateEnd.add(1, 'months').format("YYYY-MM-DD");
              break;
            case "25":
              examDateEnd = setDateEnd.add(3, 'months').format("YYYY-MM-DD");
              break;
            case "26":
              examDateEnd = setDateEnd.add(6, 'months').format("YYYY-MM-DD");
              break;
            case "27":
              examDateEnd = setDateEnd.add(1, 'years').format("YYYY-MM-DD");
              break;
            case "29":
              examDateEnd = setDateEnd.add(3, 'years').format("YYYY-MM-DD");
              break;
            default:
              break;
          }
          const localCondition = {examDateSt : examDateStart,examDateEd : examDateEnd};

          // 遷移先の期間に設定（クリックした日～3か月）
          // this.updateStartToEndDate(this.sendTreatDate);
          this.setDetailCondition(localCondition);
          }
        // 患者ID
        // this.setSelectedPatId(this.selectedPatId);

        this.setRouter(cellInfo.ordNo, [
          "exam-record",
          "exam-record-detail"
        ]);
        // mod #10036 患者経過総合ビューアの検査予定の表示不正 zhangbo end
        // mod FNSI-検体検査の表示の修正 楊 end
      }
    }
  }
};
</script>

<style scoped lang="scss">
/* 患者経過総合ビューア共通スタイル定義 */
@import "../../css/style.scss";

/* ○と●が英文フォントだと小さく表示されるため、日本語フォント限定にする */
.exam-info-font {
  font-family: Osaka,Meiryo;
}
</style>
