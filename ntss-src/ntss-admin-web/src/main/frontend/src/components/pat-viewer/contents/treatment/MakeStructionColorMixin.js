/**
 * add FNSI-障害票一覧_患者経過総合ビューアNo.16-19(指示の切り替わりポイントを赤くする) 李 start
 * 指示の切り替わりポイントを赤くする用のMixin
 */

/**
 * Vue関連
 */
import { mapActions } from "vuex";
/**
 * 日付操作
 */
import moment from "moment";

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
     * 指示の切り替わりポイント
     * @param treatDataList 画面上の治療予定情報
     * @param originKbn 発生元区分(1:治療方法、2:スケジュール、3:治療条件、4:投与薬剤、5:医療材料、6:指示コメント)
     */
    async makeStructionColor(treatDataList, originKbn) {
      try {
        // 画面上の治療予定情報がないの場合、処理中止
        if (!treatDataList) return;

        // すべての治療情報を取得
        const allTreatmentDataTmp = this.getTreatmentDataTmp;
        // すべての治療情報がないの場合、処理中止
        if (!allTreatmentDataTmp) return;

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
                isMakeStructionColorData: true
              });
              break;

            // 医療材料の場合
            case 5:
              dataListTmp = await this.convertEquipmentData({
                listIndex: rowIndex,
                isMakeStructionColorData: true
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
          if (!treatDataList[i]) return;

          let zairyuNo = null;
          if (originKbn == 4) zairyuNo = treatDataList[i].itemNo;
          if (originKbn == 5) zairyuNo = treatDataList[i].itemNo;

          // 画面上の治療予定具体的な項目取得する
          const screenTreatDataList = treatDataList[i].data;

          // 画面上の治療予定具体的な項目を循環されています
          screenTreatDataList.forEach(screenTreatDataItem => {
            // 画面上の治療予定がないの場合、処理中止
            if (!screenTreatDataItem.ordNo || !screenTreatDataItem.treatDate) return;

            // ●●●●●●●比較のデータ取得●●●●●●●start●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●
            // 比較の範囲取得(前1週間+後1週間、当日含まず)
            const oneWeekBeforeDate = moment(screenTreatDataItem.treatDate).add(-8, "days").format("YYYYMMDD");
            const oneWeekAfterDate = moment(screenTreatDataItem.treatDate).add(8, "days").format("YYYYMMDD");

            let someTreatMentDataTmpData = [];
            // 当日予定のすべての治療情報を取得します、比較範囲有効のデータ取得
            for (let index = 0; index < treatMentDataTmp.length; index++) {

              // フォマードのすべての治療情報がない場合
              if (!treatMentDataTmp[index]) return;

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
                if (!treatMentDataTmp[index][i]) return;
                if (!treatMentDataTmp[index][i].data) return;
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
                //   return moment(allOneLineScreenTreatDataItem.treatDate).isBetween(oneWeekBeforeDate, oneWeekAfterDate, "day");
                // }

                return moment(allOneLineScreenTreatDataItem.treatDate).isBetween(oneWeekBeforeDate, oneWeekAfterDate, "day");
              })
              Array.prototype.push.apply(someTreatMentDataTmpData, oneLineScreenTreatDataItem);
            }

            // mod FNSI-FutreNetWeb+SI課題管理No.4869 李 start
            // 同一の装置モードを取得する
            if (!someTreatMentDataTmpData) return;

            // 治療情報(画面表示治療日±7日)の格納
            let deviceModeScreenTreatDataList = someTreatMentDataTmpData;

            // 比較のデータ取得
            if (!deviceModeScreenTreatDataList) return;
            let compareTreatMentDataTmpData = [];
            for (let index = 0; index < deviceModeScreenTreatDataList.length; index++) {
              if (deviceModeScreenTreatDataList[index].ordNo == screenTreatDataItem.ordNo) {
                if (deviceModeScreenTreatDataList[index - 1]) compareTreatMentDataTmpData.push(deviceModeScreenTreatDataList[index - 1]);
                if (deviceModeScreenTreatDataList[index + 1]) compareTreatMentDataTmpData.push(deviceModeScreenTreatDataList[index + 1]);
              }
            }
            // ●●●●●●●比較のデータ取得●●●●●●●end●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●

            // ●●●●●●●比較処理●●●●●●●start●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●
            // let colorChangeFlg = true;
            // someTreatMentDataTmpData.forEach(someDataItem => {
            if (!compareTreatMentDataTmpData) return;
            let colorChangeFlg = false;
            compareTreatMentDataTmpData.forEach(someDataItem => {
              // 値が異なる場合
              if (screenTreatDataItem.value1 != someDataItem.value1) {
                // 色変更する
                colorChangeFlg = true;
                return;
              }
            })
            // ●●●●●●●比較処理●●●●●●●end●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●

            // 色変更フラグがtrueの場合、色変更する
            if (colorChangeFlg) screenTreatDataItem.colorFlg = 1;
            // 色変更フラグ初期化
            colorChangeFlg = true;
          })
        }
      } catch (error) {
        console.error(error);
      }
    }
  }
}
/* add FNSI-障害票一覧_患者経過総合ビューアNo.16-19(指示の切り替わりポイントを赤くする) 李 end */
