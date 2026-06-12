<script>
import { mapGetters } from "@/compat/vue/vuex";

import {
  sendRequestGetMstMedicine,
  sendRequestGetMstMedicineClass,
  sendRequestGetMstPersonalUser,
  sendRequestGetMstProcedure,
  sendRequestGetMstMedicineMix,
  getMedicineAllTabooAllergy
} from "@/apis/treatment-record";
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
import { DATE_FORMAT, SHORT_TIME_FORMAT, dateFormat, parseDate } from "@/functions/common/DateTimeUtils";
import { CODES } from "@/constants/TreatmentRecord";
// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
import { getMstListCompose } from "@/apis/pat-prescription";
import { getMasterConfig } from "@/components/common/master-selector/builder/masterPopoverConfig";
import * as MasterType from "@/components/common/master-selector/MasterType";
// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end

export default {
  data() {
    return {
      perPage: 8 // 1ページ中に表示される愁訴処置の数
    }
  },
  computed: {
    ...mapGetters("pat-info", ["selectedPatId"]),
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
    ...mapGetters("master-maintenance", { facilityCd: "getFacilitySwitch" }),
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
  },
  methods: {
    /**
     * 薬剤マスタ及び調整薬剤マスタ、薬剤分類を取得する.
     */
    fetchMedicineAllWithMix() {
      return Promise.all([
        sendRequestGetMstMedicine(),
        sendRequestGetMstMedicineMix(),
        sendRequestGetMstMedicineClass(this.selectedPatId)
      ]);
    },
    /**
     * 薬剤（薬剤マスタと調整薬剤マスタ）を取得する.
     */
    fetchMedicineAllTabooAllergy() {
      const patId = this.selectedPatId;
      return getMedicineAllTabooAllergy(patId);
    },
    /**
     * 薬剤（薬剤マスタと調整薬剤マスタ）、薬剤分類マスタを取得する.
     */
    fetchMedicineAll() {
      // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
      const patId = this.selectedPatId;
      const facCd = this.facilityCd;
      const context = {
        facilityCd: facCd,
        patientId: patId ? String(patId) : null,
        extraParams: {
          treatDate: "",
          rstInfo: { rstName: "", rstUnit: "" }
        },
        dialysisState: 0,
        allowedFields: {}
      };
      const item = getMasterConfig(MasterType.MEDICATION_TREATMENT_RECORD, context);
      return Promise.all([
        this.fetchMedicineAllTabooAllergy(),
        sendRequestGetMstMedicineClass(this.selectedPatId),
        getMstListCompose(item)
      ]);
      // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
    },
    fetchPersonalUserAll() {
      return sendRequestGetMstPersonalUser(this.selectedPatId);
    },
    fetchProcedureAll() {
      return sendRequestGetMstProcedure();
    },
    /**
     * 指定した行がそのページの最後の行か.
     * @param {array} items 要素のリスト
     * @param {number} index 要素のインデックス
     * @param {function} conditionOfItemVisible items[index]の要素が表示されるかどうかを返す関数
     *                                          引数: items[index]
     *                                          戻り値: boolean
     */
    isLastRowPerPage(items, index, conditionOfItemVisible) {
      if(index < 0 || !this.isVisibleItem(items, index, conditionOfItemVisible)) return false;

      const remain = this.perPage - (index % this.perPage);
      return !items
        .slice(index + 1, index + remain)
        .some((_, i) => this.isVisibleItem(items, index + i + 1, conditionOfItemVisible));
    },
    /**
     * 指定した行が属しているページが表示されているか.
     * @param {array} items 要素のリスト
     * @param {number} index 要素のインデックス
     * @param {function} conditionOfItemVisible items[index]の要素が表示されるかどうかを返す関数
     *                                          引数: items[index]
     *                                          戻り値: boolean
     */
    isVisiblePage(items, index, conditionOfItemVisible) {
      return items
        .slice(index, index + this.perPage)
        .some((v, i) => this.isVisibleItem(items, index + i, conditionOfItemVisible));
    },
    /**
     * 指定した行が表示されているか.
     * @param {array} items 要素のリスト
     * @param {number} index 要素のインデックス
     * @param {function} conditionOfItemVisible items[index]の要素が表示されるかどうかを返す関数
     *                                          引数: items[index]
     *                                          戻り値: boolean
     */
    isVisibleItem(items, index, conditionOfItemVisible) {
      if(index >= items.length) return false;
      return (
        index < 0 ||
        conditionOfItemVisible(items[index])
      );
    },
    /**
     * 愁訴処置記録日時が未入力か否かのバリデーションを行う.
     * 
     * @param {Date} value 愁訴処置記録日時
     * @returns {Boolean} true:正常 false:エラー
     */
    validateOccurDate(value) {
      if (!value) {
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          // message: "日時が入力されていません。"
          title: DIALOG_MESSAGES[12000256].title,
          message: messageFormat(DIALOG_MESSAGES[12000256].message)  
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
        });
        return false;
      }
      return true;
    },
    /**
     * リストの並び替え
     * @param {Complaint} a
     * @param {Complaint} b
     * @returns 比較結果
     */
    compareComplaintList(a, b) {
      // 
      const aDate = a.occurDate.getTime();
      const bDate = b.occurDate.getTime();
      const compareResult = aDate === bDate ? 0 : aDate < bDate ? -1 : 1;
      if (compareResult === 0 && a.isDialysis) {
        return -1;
      } else if (compareResult === 0 && b.isDialysis) {
        return 1;
      }
      return compareResult;
    },
    /** デフォルト日時取得
     *  rst_dialysis_state＝1～5 の場合
     *  - 開始日時：現在日時or1つ前の終了日時
     *  - 終了日時：現在日時or1つ前の開始日時
     *  rst_dialysis_state＝6 の場合
     *  - 開始日時：治療終了日時(なければ現在日時)or1つ前の終了日時
     *  - 終了日時：治療終了日時(なければ現在日時)or1つ前の開始日時
     *  @param {Date} previousDate  1つ前の開始 or 終了日時
     *  @return {Date} デフォルト日時
     */
    getDefaultDate(previousDate) {
      let defaultDate = new Date();
      if (+this.getDialysisState === +CODES.DIALYSIS_STATE.CONFIRMED_WEIGHT_MEASURING.cd) {
        defaultDate = this.getRstEndDate ? new Date(this.getRstEndDate) : defaultDate;
      }
      if (previousDate) {
        defaultDate = (defaultDate >= previousDate) ? defaultDate : previousDate;
      }
      // "YYYY-MM-DD HH:mm" 部分だけの Date オブジェクトを返す
      const dateString = dateFormat.format(defaultDate, DATE_FORMAT);
      const timeString = dateFormat.format(defaultDate, SHORT_TIME_FORMAT);
      return parseDate(dateString, timeString);
    },
  },
}
</script>

