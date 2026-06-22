/**
 * add FNSI-障害票一覧_患者経過総合ビューアNo.16-19(指示の切り替わりポイントを赤くする) 李 start
 * 指示の切り替わりポイントを赤くする用のMixin
 */

/**
 * Vue関連
 */
import { mapActions } from "@/compat/vue/vuex";
/**
 * 日付操作
 */
import dayjs from "@/compat/date/dayjs";

const isComparableValue = value => value !== null && value !== undefined && value !== "";

export default {
  methods: {
    ...mapActions("pat-viewer", [
      "convertTreatMethodData",
      "convertScheduleData",
      "convertTreatCondData",
      "convertEquipmentData",
      "convertMedicinetData",
      "convertIndCommentData"
    ]),

    /**
     * 比較対象を治療日順に整列し、前後1件を取得する
     */
    getChronologicalCompareTargets(screenTreatDataItem, candidateList) {
      const uniqueByDate = new Map();
      candidateList
        .filter(item => item?.ordNo && item?.treatDate)
        .sort((a, b) => a.treatDate.localeCompare(b.treatDate))
        .forEach(item => {
          uniqueByDate.set(`${item.treatDate}_${item.ordNo}`, item);
        });

      const sortedList = [...uniqueByDate.values()];
      const currentIndex = sortedList.findIndex(
        item =>
          item.treatDate === screenTreatDataItem.treatDate &&
          item.ordNo == screenTreatDataItem.ordNo
      );
      if (currentIndex < 0) {
        return [];
      }

      const compareTargets = [];
      if (sortedList[currentIndex - 1]) {
        compareTargets.push(sortedList[currentIndex - 1]);
      }
      if (sortedList[currentIndex + 1]) {
        compareTargets.push(sortedList[currentIndex + 1]);
      }
      return compareTargets;
    },

    /**
     * 比較対象を治療日順に整列し、直前1件を取得する
     */
    getChronologicalPreviousTarget(screenTreatDataItem, candidateList) {
      const uniqueByDate = new Map();
      candidateList
        .filter(item => item?.ordNo && item?.treatDate)
        .sort((a, b) => a.treatDate.localeCompare(b.treatDate))
        .forEach(item => {
          uniqueByDate.set(`${item.treatDate}_${item.ordNo}`, item);
        });

      const sortedList = [...uniqueByDate.values()];
      const currentIndex = sortedList.findIndex(
        item =>
          item.treatDate === screenTreatDataItem.treatDate &&
          item.ordNo == screenTreatDataItem.ordNo
      );
      if (currentIndex < 0) {
        return null;
      }

      return sortedList[currentIndex - 1] || null;
    },

    /**
     * 指示の切り替わりポイント
     * @param treatDataList 画面上の治療予定情報
     * @param originKbn 発生元区分(1:治療方法、2:スケジュール、3:治療条件、4:投与薬剤、5:医療材料、6:指示コメント)
     */
    async makeStructionColor(treatDataList, originKbn) {
      // 画面上の治療予定情報がないの場合、処理中止
      if (!treatDataList) return;

      // すべての治療情報を取得
      const allTreatmentDataTmp = this.getTreatmentDataTmp;
      // すべての治療情報がないの場合、処理中止
      if (!allTreatmentDataTmp || allTreatmentDataTmp.length === 0) return;

      // すべての治療情報フォマード
      let treatMentDataTmp = [];
      for (let rowIndex = 0; rowIndex < allTreatmentDataTmp.length; rowIndex++) {
        let dataListTmp = null;
        switch (originKbn) {
          // 治療方法の場合
          case 1:
            dataListTmp = await this.convertTreatMethodData({
              listIndex: rowIndex,
              selectLayoutCd: this.selectedLayoutCd,
              isMakeStructionColorData: true
            });
            break;

          // スケジュールの場合
          case 2:
            dataListTmp = await this.convertScheduleData({
              listIndex: rowIndex,
              selectLayoutCd: this.selectedLayoutCd,
              isMakeStructionColorData: true
            });
            break;

          // 治療条件の場合
          case 3:
            dataListTmp = await this.convertTreatCondData({
              listIndex: rowIndex,
              selectLayoutCd: this.selectedLayoutCd,
              isMakeStructionColorData: true
            });
            break;

          // 投与薬剤の場合
          case 4:
            dataListTmp = await this.convertMedicinetData({
              listIndex: rowIndex,
              selectLayoutCd: this.selectedLayoutCd,
              isMakeStructionColorData: true,
              selectedPatId: this.selectedPatId
            });
            break;

          // 医療材料の場合
          case 5:
            dataListTmp = await this.convertEquipmentData({
              listIndex: rowIndex,
              isMakeStructionColorData: true,
              selectedPatId: this.selectedPatId
            });
            break;

          // 指示コメントの場合
          case 6:
            dataListTmp = await this.convertIndCommentData({
              listIndex: rowIndex,
              isMakeStructionColorData: true
            });
            break;
        }
        treatMentDataTmp.push(dataListTmp);
      }

      // 画面上の治療予定情報を循環する
      for (let i = 0; i < treatDataList.length; i++) {
        // 画面上の治療予定情報の具体的な項目がない場合
        if (!treatDataList[i]) continue;

        let zairyuNo = null;
        if (originKbn == 4) zairyuNo = treatDataList[i].itemNo;
        if (originKbn == 5) zairyuNo = treatDataList[i].itemNo;

        // 画面上の治療予定具体的な項目取得する
        const screenTreatDataList = treatDataList[i].data;

        // 画面上の治療予定具体的な項目を循環されています
        screenTreatDataList.forEach(screenTreatDataItem => {
          // 画面上の治療予定がないの場合、処理中止
          if (!screenTreatDataItem.ordNo || !screenTreatDataItem.treatDate) return;

          // マスタ名称の非同期取得前は比較しない（初回表示で誤って青くならないようにする）
          if (!isComparableValue(screenTreatDataItem.value1)) return;

          // ●●●●●●●比較のデータ取得●●●●●●●start●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●
          // 比較の範囲取得(前1週間+後1週間、当日含まず)
          const oneWeekBeforeDate = dayjs(screenTreatDataItem.treatDate).add(-8, "days").format("YYYYMMDD");
          const oneWeekAfterDate = dayjs(screenTreatDataItem.treatDate).add(8, "days").format("YYYYMMDD");

          let someTreatMentDataTmpData = [];
          // 当日予定のすべての治療情報を取得します、比較範囲有効のデータ取得
          for (let index = 0; index < treatMentDataTmp.length; index++) {

            // フォマードのすべての治療情報がない場合
            if (!treatMentDataTmp[index]) continue;

            let treatmentData = null;
            // 指示コメントの場合
            if (originKbn == 6) {
              const treatmentDataList = treatMentDataTmp[index].find(item => screenTreatDataItem.itemNo == item.itemNo);
              if (treatmentDataList) treatmentData = treatmentDataList.data;

            // 投与薬剤の場合
            } else if (originKbn == 4 && zairyuNo) {
              const treatmentDataList = treatMentDataTmp[index].find(item => zairyuNo == item.itemNo);
              if (treatmentDataList) treatmentData = treatmentDataList.data;

            // 医療材料の場合
            } else if (originKbn == 5 && zairyuNo) {
              const treatmentDataList = treatMentDataTmp[index].find(item => zairyuNo == item.itemNo);
              if (treatmentDataList) treatmentData = treatmentDataList.data;

            // 指示コメント以外の場合
            } else {
              if (!treatMentDataTmp[index][i]) continue;
              if (!treatMentDataTmp[index][i].data) continue;
              // すべての治療情報フォマード
              treatmentData = treatMentDataTmp[index][i].data;
            }

            if (!treatmentData) continue;
            // 比較範囲有効のデータ取得
            const oneLineScreenTreatDataItem = treatmentData.filter(allOneLineScreenTreatDataItem => {
              // 比較範囲のデータ存在なしの場合、処理中止
              if (!allOneLineScreenTreatDataItem.ordNo) return;
              // 当日の予定は除く
              // if (screenTreatDataItem.treatDate != allOneLineScreenTreatDataItem.treatDate) {
              //   return dayjs(allOneLineScreenTreatDataItem.treatDate).isBetween(oneWeekBeforeDate, oneWeekAfterDate, "day");
              // }

              return dayjs(allOneLineScreenTreatDataItem.treatDate).isBetween(oneWeekBeforeDate, oneWeekAfterDate, "day");
            })
            Array.prototype.push.apply(someTreatMentDataTmpData, oneLineScreenTreatDataItem);
          }

          // mod FNSI-FutreNetWeb+SI課題管理No.4869 李 start
          // 同一の装置モードを取得する
          if (!someTreatMentDataTmpData) return;

          // 治療情報(画面表示治療日±7日)の格納
          let deviceModeScreenTreatDataList = someTreatMentDataTmpData;

          // 比較のデータ取得（治療日順の前後1件）
          if (!deviceModeScreenTreatDataList) return;
          const compareTreatMentDataTmpData = this.getChronologicalCompareTargets(
            screenTreatDataItem,
            deviceModeScreenTreatDataList
          );
          const previousTreatDataItem = this.getChronologicalPreviousTarget(
            screenTreatDataItem,
            deviceModeScreenTreatDataList
          );
          // ●●●●●●●比較のデータ取得●●●●●●●end●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●

          // ●●●●●●●比較処理●●●●●●●start●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●
          if (!compareTreatMentDataTmpData) return;
          let colorChangeFlg = false;
          compareTreatMentDataTmpData.forEach(someDataItem => {
            const isPrevious =
              previousTreatDataItem && someDataItem === previousTreatDataItem;
            if (!isComparableValue(someDataItem.value1)) {
              // 治療日順の直前1件が空の場合は値が異なるとみなす（後1件が空の場合はスキップ）
              if (isPrevious) {
                colorChangeFlg = true;
              }
              return;
            }
            // 値が異なる場合
            if (screenTreatDataItem.value1 != someDataItem.value1) {
              colorChangeFlg = true;
            }
          })
          // ●●●●●●●比較処理●●●●●●●end●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●

          // 色変更フラグがtrueの場合、色変更する
          if (colorChangeFlg) {
            screenTreatDataItem.colorFlg = 1;
          }
        })
      }
    }
  }
}
/* add FNSI-障害票一覧_患者経過総合ビューアNo.16-19(指示の切り替わりポイントを赤くする) 李 end */
