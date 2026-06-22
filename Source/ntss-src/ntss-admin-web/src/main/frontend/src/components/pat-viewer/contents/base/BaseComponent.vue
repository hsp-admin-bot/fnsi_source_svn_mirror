/** * コンポーネント共通操作 */
<template>
  <div></div>
</template>

<script>
/**
 * Vue関連
 */
import { mapActions, mapGetters } from "@/compat/vue/vuex";

/**
 * 外部ライブラリ関連
 */

/**
 * 日時操作
 */
import dayjs from "@/compat/date/dayjs";

export default {


  computed: {
    ...mapGetters("pat-info", ["selectedPatId"]),
    ...mapGetters("user", ["getFacilityCd"]),
    // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
    // ...mapGetters("pat-viewer", ["getIsTreatPlan", "getTreatmentData"]),
    ...mapGetters("pat-viewer", ["getIsTreatPlan", "getTreatmentData", "getRecentTreatmentDate"]),
    // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
    ...mapGetters("pat-viewer-modal", ["getBaseDate"]),

    /**
     * 患者ID
     */
    patId() {
      return this.selectedPatId;
    },

    /**
     * 施設コード
     */
    facilityCd() {
      return this.getFacilityCd;
    },

    /**
     * 基準日
     */
    baseDate() {
      return dayjs(this.getBaseDate, "YYYY-MM-DD").format("YYYYMMDD");
    },

    /**
     * 一覧上の治療予定の有無
     */
    isTreatPlan() {
      return this.getIsTreatPlan;
    },

    /**
     * ordMain情報
     */
    ordMainData() {
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
      // return this.getTreatmentData[this.rowIndex];
      return this.getRecentTreatmentDate[this.rowIndex];
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
    },

    /**
     * 一覧上の予定が過去日かどうか取得
     */
    getIsPastDate() {
      // 治療日リストを取得
      const ordMainDataNotIncludeShr = Object.fromEntries(
        Object.entries(this.ordMainData).filter(([, value]) => value && !value.readOnly)
      );
      const treatDateList = Object.keys(ordMainDataNotIncludeShr);
      // 表示されている最終治療日を取得
      const lastTreatDate = treatDateList[treatDateList.length - 1];
      // 本日の日付を取得
      const day = dayjs().format("YYYYMMDD");
      // 最終日が過去日かどうかを返す
      return day > lastTreatDate;
    }
  },

  methods: {
    ...mapActions("treatment-record/common", ["setOrdNo"]),
    ...mapActions("pat-viewer-modal", ["showMessageDialog"]),

    /**
     * 画面遷移
     * @param ordNo オーダー番号
     * @param transitionList 遷移情報リスト
     */
    setRouter(ordNo, transitionList) {
      // オーダー番号を格納する
      this.setOrdNo(ordNo);
      // 遷移情報リスト分画面遷移する
      transitionList.forEach(name => {
        this.$router.push({ name });
      });
    },

    /**
     * 曜日を英語表記に変換
     */
    changeWeekStr(num) {
      switch (num) {
        case 0:
          return "sunday";
        case 1:
          return "monday";
        case 2:
          return "tuesday";
        case 3:
          return "wednesday";
        case 4:
          return "thursday";
        case 5:
          return "friday";
        case 6:
          return "saturday";
        default:
          return null;
      }
    },

    /**
     * 直近日から治療予定のある日付を返す
     */
    getRecentBaseDate() {
      // mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy start
      // let arr = []
      // 基準日との差(最小値)
      let minDifferenceDate = null;
      // 直近日
      let recentDate = null;
      // for (let i = 0; i < this.getTreatmentData.length; i++) {
      //   for (const ita in this.getTreatmentData[i]) {
      //     if (/* this.baseDate === ita &&  */this.getTreatmentData[i][ita] && this.getTreatmentData[i][ita].rstInputClass !== null) {
      //       for (const treatDate in this.getTreatmentData[0]) {
      //         // 対象日に治療予定が入っている場合
      //         // mod FNSI-【1006】最新の改修対象一覧の679対応 韓 start
      //         // if (this.ordMainData[treatDate]) {
      //         if (this.ordMainData[treatDate] && this.ordMainData[treatDate].rstDialysisState !== undefined && (this.ordMainData[treatDate].rstDialysisState === '0'
      //           || this.ordMainData[treatDate].rstDialysisState === '1'
      //           || this.ordMainData[treatDate].rstDialysisState === '2'
      //           || this.ordMainData[treatDate].rstDialysisState === '3')) {
      //         // rst_dialysis_stateが1以上は編集対象外
      //         // mod FNSI-【1006】最新の改修対象一覧の679対応 韓 end
      //           // 基準日との差を取得
      //           const eleDifferenceDate = Math.abs(
      //             Number(treatDate) - Number(this.baseDate)
      //           );
      //           // 最小値がnullもしくは基準日との差分が最小値以下の時、最小値と直近日を格納
      //           if (
      //             null === minDifferenceDate ||
      //             minDifferenceDate >= eleDifferenceDate
      //           ) {
      //             // 最小値の格納
      //             minDifferenceDate = eleDifferenceDate;
      //             // 直近日の格納
      //             recentDate = treatDate;
      //           }
      //         }
      //       }
      //     } else if (this.getTreatmentData[i][ita] && this.getTreatmentData[i][ita].rstInputClass == null) {
      //       arr.push(ita)
      //       //患者経過総合ビューア（計画）_除水補正編集： 「期間/レイアウト」が選択され、14日分にはページデータ表示に問題があります，修正。20230529 ztc start
      //       recentDate = String(Math.min.apply(null, arr.filter(arrDate => arrDate >= this.baseDate)))
      //       //患者経過総合ビューア（計画）_除水補正編集： 「期間/レイアウト」が選択され、14日分にはページデータ表示に問題があります，修正。20230529 ztc end
      //     }
      //   }
      // }
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
      // for (const ita in this.getRecentTreatmentDate[0]) {
      //   // 対象日に治療予定が入っている場合
      //   // if (this.ordMainData[ita] && this.ordMainData[ita].rstDialysisState !== undefined && this.ordMainData[ita].rstDialysisState === '0') {
      //   if (this.ordMainData[ita] && this.ordMainData[ita].rstDialysisState !== undefined && rstDialysisStateObj[ita] === '0') {
      //     // 基準日との差を取得
      //     const eleDifferenceDate = Math.abs(
      //       Number(ita) - Number(this.baseDate)
      //     );
      //     // 最小値がnullもしくは基準日との差分が最小値以下の時、最小値と直近日を格納
      //     if (
      //       null === minDifferenceDate ||
      //       minDifferenceDate >= eleDifferenceDate
      //     ) {
      //       // 最小値の格納
      //       minDifferenceDate = eleDifferenceDate;
      //       // 直近日の格納
      //       recentDate = ita;
      //       // mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy start
      //     }
      //   }
      // }
      const ordMainDataNotIncludeShr = Object.fromEntries(
        Object.entries(this.ordMainData).filter(([, value]) => value && !value.readOnly)
      );
      const dateArr = Object.keys(ordMainDataNotIncludeShr);
      for (let date of dateArr) {
        let status = false;
        for (let item of this.getRecentTreatmentDate) {
          if (date >= this.baseDate && item[date] && item[date].rstDialysisState == "0") {
            status = true;
          }
        }
        if (status) {
          recentDate = date;
          break;
        }
      }
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
      return recentDate;
    },

    /**
     * 日付情報からオーダー番号を取得
     * @param date 治療日
     */
    getOrdNo(date) {
      const ordNo = this.ordMainData[date].ordNo;
      return ordNo;
    },

    /**
     * 治療状況の取得
     * @param ordNoオーダー番号
     * @return オーダー番号と一致した治療状況
     */
    getRstDialysisState(ordNo) {
      // オーダー番号が渡されていない場合、nullを返す
      if (!ordNo) {
        return null;
      }
      // 治療日ごとの治療情報を取得
      for (const date in this.ordMainData) {
        const ordInfo = this.ordMainData[date];
        if (null !== ordInfo) {
          if (ordNo === ordInfo.ordNo) {
            return ordInfo.rstDialysisState;
          }
        }
      }
    },

    // 操作不可メッセージの表示
    showDisProcMessage() {
      this.showMessageDialog({ isShowMessageDialog: true });
    }
  }
};
</script>

<style scoped></style>
