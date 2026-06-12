/**
 * 治療記録の子機能 愁訴処置ページ
 */
<template>
  <submenu-base>
    <template #header>
      <div>
      <div class="btn-area">
        <v-ons-button
          class="button registration-btn btn3-normal"
          :disabled="isEditDisabled()"
          @click="onClickComplaintCreate"
        >追加</v-ons-button>
        <v-ons-button
          class="button registration-btn btn3-normal"
          :disabled="isEditDisabled()"
          @click="showOxygenModal"
        >酸素吸入</v-ons-button>
        <v-ons-button
          class="button registration-btn btn3-normal"
          :disabled="isEditDisabled()"
          @click="showElectrocardiogramModal"
        >心電図</v-ons-button>
      </div>
      </div>
    </template>
    <template #main>
      <div id="complaint-component">
      <table class="treatment-record-list complaint-grid">
        <thead>
          <tr>
            <th
              class="ntss-list-header-th-sticky"
              style="width: 8.5em"
              @click="sort"
            >時刻{{ sortMarker }}</th>
            <th class="ntss-list-header-th-sticky ntss-checkbox-shaving"></th>
            <th
              class="ntss-list-header-th-sticky"
              style="min-width:9em; width:30%"
            >愁訴</th>
            <th
              class="ntss-list-header-th-sticky"
              style="min-width: 12em; z-index: 100;max-width:30%"
              colspan="2"
            >処置</th>
            <th
              class="ntss-list-header-th-sticky"
              style="min-width: 8em"
            >処置者</th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="(rowData, index) in displayList"
            :key="index"
            :class="[backgroundStyle(rowData)]"
            class="complaint-list-body-tr"
          >
            <td
              v-if="rowData.rowSpan > 0"
              class="complaint-list-body-td complaint-list-body-time-td"
              :rowspan="rowData.rowSpan"
            >
              <label>{{ rowData.occurTime }}</label>
              <v-ons-button
                v-if="rowData.isEditable && editStatus(rowData)"
                class="edit-button btn3-normal"
                :disabled="isEditDisabled() || isTreatmentEditDisabled(rowData.treatment.isEditable)"
                @click="onClickEdit(rowData)"
              >編集</v-ons-button>
            </td>
            <!-- 愁訴 -->
            <td
              :class="rowData.isLast || rowData.rowSpan === 1 ? 'checkbox-border' : ''"
              @click="selectConfirm(index)"
            >
              <v-ons-checkbox
                :disabled="isCheckboxDisabled(rowData)"
                v-model="rowData.checked"
                @click.stop="() => {}"
                :id="`checkbox-btn${index}`"
                @input="checkStatus(rowData)"
                :class="index === displayList.length - 1 ? 'last-box' : ''"
                class="complaint-checkbox"
              />
            </td>
            <td
              :class="borderBottomStyleCompliants(rowData)"
              class="complaint-list-body-td complaint-name">
              <label>{{ rowData.complaints.name }}</label>
            </td>
            <!-- 処置 -->
            <td
              :class="borderBottomStyleTreatment(rowData)"
              class="complaint-list-body-td treat-name"
              :colspan="rowData.treatment.hasMedicine ? 1 : 2">
              <label>{{ rowData.treatName }}</label>
            </td>
            <!-- 処置薬剤 -->
            <td
              v-if="rowData.treatment.hasMedicine"
              :class="borderBottomStyleTreatment(rowData)"
              class="complaint-list-body-td medicine-bottle"
            >
              <img
                :src="getMedicineBottleIconSrc(rowData)"
                style="cursor: pointer;"
                width="24"
                height="24"
                :disabled="isReadOnly"
                @click="showMedicine(rowData.treatment, $event)"
              />
            </td>
            <!-- 処置者 -->
            <td class="complaint-list-body-td"
              :class="rowData.isLast || rowData.rowSpan === 1 ? 'border-bottom-last' : 'border-bottom-hidden'">
              <label>{{ rowData.treatStaffName }}</label>
            </td>
          </tr>
        </tbody>
      </table>
      <treatment-medicine
        :popoverVisible="popoverVisible"
        :popoverTarget="popoverTarget"
        :popoverTreatment="popoverTreatment"
        @popover-close="closePopover"
      />
      </div>
    </template>
  </submenu-base>
</template>

<script>
import { getScopedElementById } from "@/functions/common/LayoutMeasureHelper";

import { mapActions, mapGetters, mapMutations } from "@/compat/vue/vuex";
import SubmenuBase from "@/components/treatment-record/SubmenuBaseComponent";
import DiscardConfirmationMixin from "@/components/treatment-record/DiscardConfirmationMixin";
import PopoverMixin from "@/components/PopoverMixin";
import { Complaint } from "@/models/treatment-record/complaint/Complaint";
import { Treatment } from "@/models/treatment-record/complaint/Treatment";
import { OxygenModal } from "@/models/treatment-record/complaint/OxygenModal";
import { ElectrocardiogramModal } from "@/models/treatment-record/complaint/ElectrocardiogramModal";
import { CODES } from "@/constants/TreatmentRecord";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from "@/functions/common/MessageFormat";
import { EventBus } from "@/compat/vue/event-bus.js";
import BigNumber from "@/compat/number/bignumber";
import ComplaintComponentMixin from "@/components/treatment-record/submenu/complaint/ComplaintComponentMixin";
import TreatmentMedicineComponent from "@/components/treatment-record/submenu/complaint/TreatmentMedicineComponent";
import dayjs from "@/compat/date/dayjs";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import { getAuthorized } from "@/functions/common/CommonFunctions";
import { sendRequestGetTreatmentRecordMediInfo } from "@/apis/treatment-record";
import { sendRequestGetMstFacilitySettingValue } from "@/apis/facility-setting";
import {
  COMPLAINT_MEDICINE_INFO,
  TOGGLE_VALUE_OFF,
  TOGGLE_VALUE_ON,
} from "@/constants/facilitySetting";

const getOccurDateTime = rowData => {
  const yyyymmddhhmmss = rowData.occurDate.replace(/-/g, "/").split(".")[0];
  return new Date(yyyymmddhhmmss).getTime();
};
const isDialysisEnd = rowData => (
  rowData.complaints.ctlNo === undefined
  && rowData.complaints.name === "治療終了"
);

export default {
  mixins: [
    DiscardConfirmationMixin,
    PopoverMixin,
    ComplaintComponentMixin,
  ],
  components: {
    "submenu-base": SubmenuBase,
    "treatment-medicine": TreatmentMedicineComponent,
  },
  data() {
    return {
      sortOrder: 1,
      rstStartDate: null,
      rstEndDate: null,
      comparisonModel: "",
      popoverVisible: false,
      popoverTarget: null,
      popoverTreatment: {},
      selfScreenName: "",
      alertFlag: true,
      monitorData: [],
      beforeTreatmentRecordComplaintInfo: {},
      currentEditCtlNoList: [],
      medicineInfoSettingValue: null,
      medicineInfoList: [],
    };
  },
  computed: {
    ...mapGetters("multi-modal", ["getModalName"]),
    ...mapGetters("window-size", { windowWidth: "getMainWindowWidth" }),
    ...mapGetters("treatment-record/common", [
      "getOrd",
      "getSharedFacilityCd",
    ]),
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("pat-info", ["selectedPatId"]),
    ...mapGetters("treatment-record/common", ["getDialysisState"]),
    ...mapGetters("treatment-record/complaint", {
      getDataListForIndex: "getComplaintData",
    }),

    /**
     * 一覧表示用のリストを作成する.
     */
    displayList() {
      const result = [];

      const sortOrder = this.sortOrder;
      const medicineInfoList = this.medicineInfoList;
      this.getComplaintData().forEach(element => {
        const treatmentList = element.treatmentList.length > 0
          ? element.treatmentList
          : [{ treatName: null, treatStaffName: null }];
        treatmentList.forEach(treatment => {
          result.push({
            checkFlag: element.checkFlag,
            // チェック状態は checkFlag == "1" の条件で設定する必要があるが
            // v-ons-checkbox のチェック状態をv-modelを通してしか設定できないため、
            // v-modelに設定できる項目として checked を用意する
            // v-ons-checkbox のクリック時には checkStatus 内で setComplaintData が行われ
            // それに連動して displayList の再計算が行われるため
            // checked の値は再び checkFlag == "1" の条件で設定されなおす
            checked: element.checkFlag == "1",
            occurDate: dayjs(element.occurDate).format("YYYY-MM-DD HH:mm:ss.SSS"),
            occurTime: element.occurTime,
            complaints: element.complaint,
            treatName: treatment.treatName,
            treatStaffName: treatment.treatStaffName,
            rowSpan: element.isSpecial ? 1 : 0,
            isDialysis: element.isDialysis,
            isMedicineInfo: false,
            treatment: treatment,
            isEditable: !element.isSpecial,
          });
        });
      });

      // セルの結合
      // 重複を排除したctlNoのリストを作成
      const ctlNoList = Array.from(new Set(
        result.map(e => e.treatment.ctlNo).concat(result.map(e => e.complaints.ctlNo))));

      // 行のソートを行う
      result.sort((a, b) => {
        const [aDate, bDate] = [a, b].map(getOccurDateTime);
        let compareResult = aDate - bDate;
        // 日時が同じだった場合 ctlNo でソートする
        if (compareResult === 0) {
          const [aCtlNo, bCtlNo] = [a, b].map(
            rowData => rowData.complaints.ctlNo || 0
          );
          if (aCtlNo > bCtlNo) {
            compareResult = 1;
          } else if (aCtlNo < bCtlNo) {
            compareResult = -1;
          }
          // 「治療開始」のレコードは同じ時刻の場合は先頭に、「治療終了」のレコードは同じ時刻の場合は最後尾にする
          // 「治療開始」「治療終了」はここまでに ctlNo が 0 として大小判定されているので
          // そのままで同日時内では先頭になる
          // そのため「治療終了」の場合のみ大小判定を逆転させる
          if (isDialysisEnd(a) || isDialysisEnd(b)) {
            compareResult = -compareResult;
          }
        }
        return compareResult * sortOrder;
      });

      // 結合する行数と罫線出力有無のフラグを設定
      ctlNoList.forEach(ctlNo => {
        const rows = result.filter(rowData => (
          (rowData.treatment.ctlNo === ctlNo || rowData.complaints.ctlNo === ctlNo)
          && rowData.isEditable));
        if (!rows.length) return;

        // 結合する行数と罫線出力有無のフラグを初期化
        rows.forEach(rowData => {
          rowData.rowSpan = 0;
          rowData.isLast = false;
        });
        // 結合する行数を設定
        rows[0].rowSpan = rows.length;
        // 最終行の場合に罫線出力有無を判断する為のフラグを立てる.
        rows[rows.length - 1].isLast = true;
      });

      // 投与薬剤の情報を追加
      this.addRowsFromMedicineInfo(result, medicineInfoList, sortOrder);

      return result.filter(rowData => !rowData.empty);
    },
    /**
     * ソートマーク.
     */
    sortMarker() {
      return this.sortOrder > 0 ? "▲" : "▼";
    },

    isReadOnly() {
      // URLダイレクト対応 setOrd実施前に子画面遷移すると表示不可になる不具合の対応
      if (this.getOrd == undefined || this.getOrd == null) {
        return false;
      }
      return this.getOrd.readOnly;
    },

    isShared() {
      return this.getFacilityCd === this.getSharedFacilityCd;
    },
  },
  methods: {
    ...mapActions("multi-modal", [
      "showOxygen",
      "showComplaintEdit",
      "showElectrocardiogram",
      "hideModal",
    ]),
    ...mapActions("multi-sub-modal", ["showComplaintCreate"]),
    ...mapActions("treatment-record/complaint", [
      "getTreatmentRecordComplaint",
      "updateTreatmentRecordComplaint",
      "setOxygenModal",
      "setComplaintData",
      "setEditingTime",
      "setElectrocardiogramModal",
      "setEditingCtlNo",
      "getMonitorMsgRecord",
      "updMonitorMsgRecord",
    ]),
    ...mapGetters("treatment-record/complaint", ["getComplaintData"]),
    ...mapMutations("treatment-record/complaint", ["setTempCtlNo"]),

    /**
     * ヘッダの時刻クリックでソートする.
     */
    sort() {
      this.sortOrder = this.sortOrder * -1;
    },
    /**
     * 薬瓶アイコンのクリックイベントハンドラ.
     *
     * @param {Treatment} treatment クリックされた行の処置データ
     * @param {MouseEvent} event クリックされたマウスイベント
     */
    showMedicine(treatment, event) {
      if (this.isReadOnly) return;

      // treatment.amountの小数部の桁数がマスタの小数部桁数より小さい場合には
      // 小数部の桁数を足すように整形する
      const decPoint = String(treatment.amount).split(".")[1]?.length || 0;
      const treatMedicineDecPoint = treatment.treatMedicine.decPoint || 0;
      const amountBigNumber = BigNumber(1 * treatment.amount);
      const setAmount = (decPoint > treatMedicineDecPoint)
        ? amountBigNumber.toFixed()
        : amountBigNumber.toFixed(treatMedicineDecPoint);
      this.popoverTreatment = {
        treatMedicine: treatment.treatMedicine.name,
        amount: setAmount,
        unit: treatment.unit,
        procedure: treatment.procedure.name,
      };
      this.popoverTarget = event.target;
      this.popoverVisible = true;
    },
    /**
     * ポップオーバクローズ処理
     */
    closePopover() {
      this.popoverVisible = false;
      this.popoverTarget = null;
      this.popoverTreatment = {};
    },
    /**
     * 酸素吸入ボタンクリックイベントハンドラ.
     */
    showOxygenModal() {
      if (this.isReadOnly) return;

      // モーダル用に新しい配列を作成
      const oxygenModals = this.getOxygenModals();
      this.setOxygenModal(oxygenModals);
      this.showOxygen();
    },
    /**
     * 心電図ボタンクリックイベントハンドラ.
     */
    showElectrocardiogramModal() {
      if (this.isReadOnly) return;

      // モーダル用に新しい配列を作成
      const electrocardiogramModals = this.getElectrocardiogramModals();
      this.setElectrocardiogramModal(electrocardiogramModals);
      this.showElectrocardiogram();
    },
    /**
     * 追加ボタンクリックイベントハンドラ
     */
    onClickComplaintCreate() {
      if (this.isReadOnly) return;

      this.showComplaintCreate({ isNew: true });
    },
    /**
     * 編集ボタンクリックイベントハンドラ.
     */
    onClickEdit(item) {
      if (this.isReadOnly) return;

      if (item.treatment.isOxygenStart || item.treatment.isOxygenEnd) {
        // 酸素吸入
        const oxygenModals = this.getOxygenModals();
        this.setOxygenModal(oxygenModals);
        this.showOxygen();
      } else if (
        item.treatment.isElectrocardiogramStart
        || item.treatment.isElectrocardiogramEnd
      ) {
        // 心電図
        const electrocardiogramModals = this.getElectrocardiogramModals();
        this.setElectrocardiogramModal(electrocardiogramModals);
        this.showElectrocardiogram();
      } else {
        // 愁訴
        const tempCtlNo = item.treatment.ctlNo != undefined
          ? item.treatment.ctlNo
          : item.complaints.ctlNo;
        this.setEditingTime(item.occurTime);
        this.setEditingCtlNo(tempCtlNo);
        this.showComplaintEdit();
      }
    },
    /**
     * 保存ボタンクリックイベントハンドラ.
     */
    async onSave(complaint, operateFlg, forcedChangeFlag = false) {
      this.currentEditCtlNoList = [];
      try {
        switch (operateFlg) {
          case 'edit':
            this.currentEditCtlNoList.push(complaint[0].complaint?.ctlNo || complaint[0].treatmentList?.[0]?.ctlNo || complaint[0].treatmentList?.[0]?.treatStaff?.ctlNo);
            break;
          case 'allDel':
          case 'allDelComplaint':
          case 'oxygenEdit':
          case 'oxygenDelete':
          case 'electrocardiogramEdit':
          case 'electrocardiogramDelete':
            complaint.forEach(item => {
              this.currentEditCtlNoList.push(item.complaint?.ctlNo || item.treatmentList?.[0]?.ctlNo || item.treatmentList?.[0]?.treatStaff?.ctlNo);
            })
            break;

        }
        // 有効な愁訴データを取得する
        const complaints = this.getValidComplaints(complaint);
        // 有効な廃棄データを取得する
        const { treatments, treatStaffs } = this.getValidTreatments(complaint);

        // 治療記録を更新する
        const saveFuc = operateFlg === 'create' ? 'createTreatmentRecord' : 'updateTreatmentRecord';
        const result = await this[saveFuc](complaints, treatments, treatStaffs, forcedChangeFlag, operateFlg);
        if ([12000343, 12000344, 12000345, 12000346].includes(result)) {
          const getButtonLabels = (code) => {
            switch(code) {
              case 12000343:
                return ["キャンセル", "再表示"];
              case 12000344:
                return ["キャンセル", "再表示", "強制保存"];
              case 12000345:
                return ["キャンセル", "閉じる", "強制保存"];
              case 12000346:
                return ["キャンセル", "再表示", "強制保存"];
              default:
                return ["キャンセル"];
            }
          };

          const buttonLabels = getButtonLabels(result);
          // 確認ダイアログボックスが表示されます
          this.$ons.notification.confirm({
            title: DIALOG_MESSAGES[result].title,
            message: messageFormat(DIALOG_MESSAGES[result].message),
            modifier: "rowfooter",
            buttonLabels,
            callback: async (index) => {
              switch (index) {
                case 0: // キャンセル
                  break;
                case 1: {// 更新
                  await this.init();
                  // 編集ポップアップ ウィンドウが開いている場合、ポップアップ データは更新されます
                  if (this.getModalName === 'ComplaintEdit') {
                    this.hideModal();
                    setTimeout(() => {
                      this.showComplaintEdit();
                    }, 0);
                  }
                  if (this.getModalName === 'Oxygen') {
                    this.hideModal();
                    setTimeout(() => {
                      const oxygenModals = this.getOxygenModals();
                      this.setOxygenModal(oxygenModals);
                      this.showOxygen();
                    }, 0);
                  }
                  if (this.getModalName === 'Electrocardiogram') {
                    this.hideModal();
                    setTimeout(() => {
                      const electrocardiogramModals = this.getElectrocardiogramModals();
                      this.setElectrocardiogramModal(electrocardiogramModals);
                      this.showElectrocardiogram();
                    }, 0);
                  }
                  break;
                }
                case 2: // 強制保存
                  try {
                    let operation = result === 12000345 ? 'create' : 'edit';
                    if (operation === 'create') {
                      complaint.forEach(complaint => {
                        complaint.complaint.ctlNo = null;
                        complaint.treatmentList[0].ctlNo = null;
                        complaint.treatmentList[0].treatStaff.ctlNo = null;
                      });
                    } else if (complaint[0].treatmentList[0].treatmentClass === '3') {
                      operation = complaint[0].treatmentList[0].isDel ? 'oxygenDelete' : 'oxygenEdit';
                    } else if (complaint[0].treatmentList[0].treatmentClass === '4') {
                      operation = complaint[0].treatmentList[0].isDel ? 'electrocardiogramDelete' : 'electrocardiogramEdit';
                    }
                    this.onSave(complaint, operation, true);
                  } catch (error) {
                    console.error(error);
                  }
                  break;
              }
            }
          });
          return;
        }
        if (this.getModalName && operateFlg !== "oxygenDelete" && operateFlg !== "electrocardiogramDelete") {
          this.hideModal();
        } else if (operateFlg === "oxygenDelete" || operateFlg === "electrocardiogramDelete") {
          EventBus.$emit("deleteOxygenOrElectrocardiogram");
        }

        // データの再初期化
        await this.init();

        // サブ機能ボタン領域を更新する
        this.$emit("update");
      } catch (error) {
        //FNSI-修正 VUEのエラー場合のログ対応
        getErrorMessage('ComplaintComponent.vue', 'onSave', error);

        // 409 競合エラーの処理
        if (error.response?.status === 409) {
          await this.init();
        }
      }
    },

    /**
     * 有効な愁訴データを取得する
     * @returns {Array} データ文字列の有効な配列
     */
    getValidComplaints(complaint = this.getComplaintData()) {
      return complaint
        .filter(c => !c.isDialysisRecord)
        .filter(c => !c.isSpecial)
        .filter(t => t.complaint.cd || t.complaint.name || !t.isDummy)
        .map(c => c.toString());
    },

    /**
     * 有効な廃棄データを取得する
     * @returns {Object} 廃棄データと廃棄者データを含むオブジェクト
     */
    getValidTreatments(complaint = this.getComplaintData()) {
      // すべての処理の一覧を取得する
      const treatmentList = complaint.flatMap(c => c.treatmentList);

      // ディスポーザーチェックフラグを設定する
      treatmentList.forEach(staffInfo => {
        if (staffInfo.treatStaff) {
          staffInfo.treatStaff.checkFlag = staffInfo.checkFlag;
        }
      });

      // 有効な廃棄データのフィルタリング
      const treatments = treatmentList
        .filter(t => !t.isDummy ||
          t.treat.cd || t.treat.name ||
          t.treatClass === 3 || t.treatClass === 4)
        .map(t => t.treatmentToString());
      // ディスポーザーデータを取得する
      const treatStaffs = treatmentList
        .map(t => t.treatStaffToString())
        .filter(staff => staff !== null);
      return { treatments, treatStaffs };
    },

    /**
     * 監視メッセージを処理する
     */
    async handleMonitorMessages() {
      try {
        const monitorMsgs = this.getComplaintData()
          .flatMap(c => c.treatmentList)
          .filter(t => parseInt(t.ctlNo) < 0 && !t.isDummy);
        if (!monitorMsgs.length) {
          return;
        }

        let updateData;
        monitorMsgs.forEach(element => {
          this.monitorData.data.forEach(el => {
            if (el.ctlNo === element.ctlNo) {
              if (el.reportDispFlg === "1" && element.checkFlag == 0) {
                updateData = { ...el, reportDispFlg: "0" };
              } else if (el.reportDispFlg === "0" && element.checkFlag == 1) {
                updateData = { ...el, reportDispFlg: "1" };
              }
            }
          });
        });
        if (updateData) {
          await this.updMonitorMsgRecord({
            motionRecordNo: updateData.motionRecordNo,
            reportDispFlg: updateData.reportDispFlg,
            upDate: updateData.upDate
          });
          this.init();
        }
      } catch (error) {
        this.init();
      }
    },

    /**
     * 治療記録を更新する
     * @param {Array} complaints データに関する愁訴
     * @param {Array} treatments ディスポジションデータ
     * @param {Array} treatStaffs ディスポーザーデータ
     */
    async updateTreatmentRecord(complaints, treatments, treatStaffs, forcedChangeFlag = false, operateFlg) {
      if (operateFlg === 'allDelComplaint') {
        complaints = [];
        treatments = [];
        treatStaffs = [];
      }
      const {
        rstComplaintInfo,
        rstTreatmentInfo,
        rstTreatStaffInfo
      } = this.beforeTreatmentRecordComplaintInfo;
      const beforeRstComplaintInfo = rstComplaintInfo.filter(c => this.currentEditCtlNoList.includes(c.ctl_no));
      const beforeRstTreatmentInfo = rstTreatmentInfo.filter(t => this.currentEditCtlNoList.includes(t.ctl_no));
      const beforeRstTreatStaffInfo = rstTreatStaffInfo.filter(s => this.currentEditCtlNoList.includes(s.ctl_no));
      const res = await this.updateTreatmentRecordComplaint({
        ordNo: this.getOrdNo,
        forcedChangeFlag,
        payload: {
          before_rst_complaint_info: JSON.stringify(beforeRstComplaintInfo),
          before_rst_treatment_info: JSON.stringify(beforeRstTreatmentInfo),
          before_rst_treat_staff_info: JSON.stringify(beforeRstTreatStaffInfo),
          rst_complaint_info: `[${complaints.join(",")}]`,
          rst_treatment_info: `[${treatments.join(",")}]`,
          rst_treat_staff_info: `[${treatStaffs.join(",")}]`
        }
      });
      return res.data;
    },

    /**
     * 治療レコードの作成
     * @param {Array} complaints データに関する愁訴
     * @param {Array} treatments ディスポジションデータ
     * @param {Array} treatStaffs ディスポーザーデータ
     */
    async createTreatmentRecord(complaints, treatments, treatStaffs) {
      await this.updateTreatmentRecordComplaint({
        ordNo: this.getOrdNo,
        forcedChangeFlag: false,
        payload: {
          rst_complaint_info: `[${complaints.join(",")}]`,
          rst_treatment_info: `[${treatments.join(",")}]`,
          rst_treat_staff_info: `[${treatStaffs.join(",")}]`
        }
      });
    },

    // 投与薬剤の情報から愁訴処置互換のオブジェクトのリストを作る
    makeComplaintsFromMedicineInfo(rstMediInfo, medicine) {
      const result = JSON.parse(rstMediInfo).filter(
        // 投与済み薬剤のみを対象にする
        info => info.effect_flg === 1).map(info => {
        const occurDateMoment = dayjs(info.effect_date);
        const medicineCd = info.cd;
        const treatName = info.name;
        const treatStaffName = `${info.effect_user_last_name} ${info.effect_user_first_name}`;
        const treatment = {
          hasMedicine: true,
          treatClass: null,
          medicineType: info.medicine_type != null
            ? Number(info.medicine_type)
            : null,
          treatMedicine: {
            cd: medicineCd,
            name: info.name,
            decPoint: "",
          },
          amount: info.amount,
          unit: info.unit,
          procedure: {
            cd: info.procedure_cd,
            name: info.procedure_name,
          },
          treatName,
          treatStaffName,
          isOxygenStart: false,
          isOxygenEnd: false,
          isElectrocardiogramStart: false,
          isElectrocardiogramEnd: false,
        };
        if (medicineCd && isNaN(medicineCd)) {
          treatment.treatMedicine.cd = Number(String(medicineCd).split("$")[0]);
          treatment.medicineType = String(medicineCd).indexOf("$") === -1
            ? CODES.MEDICINE_TYPE.NORMAL.cd
            : CODES.MEDICINE_TYPE.MIX.cd;
        }
        if (treatment.treatMedicine.cd === undefined) {
          treatment.treatMedicine.cd = null;
          treatment.medicineType = null;
        }
        return {
          checkFlag: 0,
          checked: false,
          occurDate: occurDateMoment.format("YYYY-MM-DD HH:mm:ss.SSS"),
          occurTime: occurDateMoment.format("HH:mm"),
          treatmentList: [treatment],
          complaints: {
            name: "",
          },
          treatName,
          treatStaffName,
          rowSpan: 1,
          isDialysis: false,
          isMedicineInfo: true,
          treatment,
          isEditable: false,
        };
      });

      // 日時と薬剤マスタの表示順にしたがってソートする
      result.sort((itemA, itemB) => {
        const [aDate, bDate] = [itemA, itemB].map(getOccurDateTime);
        let compareResult = aDate - bDate;
        // 日時が同じだった場合薬剤マスタの表示順でソートする
        if (compareResult === 0) {
          const [
            [aIndex, aTypeSeq, aCd],
            [bIndex, bTypeSeq, bCd],
          ] = [itemA, itemB].map(rowData => [
            (({ medicineType, treatMedicine }) => {
              // 薬剤マスタ（調整薬剤を含む）の表示順に従った並び順を求める
              // 削除済みなどでマスタの表示順がないものは末尾に並ぶようにする
              const index = medicine.findIndex(medicineMst => (
                medicineMst.medicineType === medicineType
                && medicineMst.medicineCd === treatMedicine.cd));
              return index > -1 ? index : medicine.length;
            })(rowData.treatment),
            (medicineType => {
              // 薬剤、調整薬剤、それ以外の順での並び順を求める
              const medicineTypeList = [
                CODES.MEDICINE_TYPE.NORMAL.cd,
                CODES.MEDICINE_TYPE.MIX.cd,
              ];
              const seq = medicineTypeList.indexOf(medicineType);
              return seq > -1 ? seq : medicineTypeList.length;
            })(rowData.treatment.medicineType),
            Number(rowData.treatment.treatMedicine.cd),
          ]);
          if (aIndex !== bIndex) {
            compareResult = aIndex - bIndex;
          } else if (aTypeSeq !== bTypeSeq) {
            compareResult = aTypeSeq - bTypeSeq;
          } else if (!isNaN(aCd) && !isNaN(bCd)) {
            compareResult = aCd - bCd;
          } else if (!isNaN(aCd)) {
            compareResult = 1;
          } else if (!isNaN(bCd)) {
            compareResult = -1;
          }
        }
        return compareResult;
      });

      return result;
    },
    addRowsFromMedicineInfo(displayList, medicineInfoList, sortOrder) {
      const isAsc = sortOrder > 0;
      let srcIndex = 0;
      let destIndex = isAsc ? 0 : displayList.length - 1;
      while (srcIndex < medicineInfoList.length) {
        // 挿入する投与薬剤の日時以降になる行まで挿入先のインデックスを進める
        const srcDate = getOccurDateTime(medicineInfoList[srcIndex]);
        while (
          destIndex >= 0
          && destIndex < displayList.length
          && srcDate > getOccurDateTime(displayList[destIndex])
        ) {
          destIndex += sortOrder;
        }

        // 挿入する投与薬剤と同じ日時の行がある場合は同じ日時内での挿入位置まで挿入先のインデックスを進める
        // 同日時内の並び順（降順指定の場合はこの逆）：治療開始、愁訴処置、投与薬剤、治療終了
        // ちなみに愁訴処置内では管理番号、投与薬剤内では薬剤マスタの並び順でソートするが
        // それらも同じもの同士の並び順はAPIのレスポンスの時点の並び順に依存する
        while (
          destIndex >= 0
          && destIndex < displayList.length
          && srcDate === getOccurDateTime(displayList[destIndex])
          && !isDialysisEnd(displayList[destIndex])
        ) {
          destIndex += sortOrder;
        }

        // 同じ日時の投与薬剤データを挿入
        let srcCount = 0;
        while (
          srcIndex < medicineInfoList.length
          && srcDate === getOccurDateTime(medicineInfoList[srcIndex])
        ) {
          srcCount++;
          srcIndex++;
        }
        const destStart = isAsc ? destIndex : destIndex + 1;
        const srcPart = medicineInfoList.slice(srcIndex - srcCount, srcIndex);
        displayList.splice(destStart, 0, ...srcPart);
        if (isAsc) {
          destIndex += srcCount;
        }
      }
    },

    // 一覧を描画するデータに、薬剤の情報を付与
    extractMedicine(complaintList, medicine) {
      const [mstMedicine, mstMedicineMix] = [
        CODES.MEDICINE_TYPE.NORMAL.cd,
        CODES.MEDICINE_TYPE.MIX.cd,
      ].map(type => medicine.filter(item => item.medicineType == type));

      complaintList.forEach(cat => {
        const catTreatment = cat.treatmentList?.[0];
        const catTreatMedicine = catTreatment?.treatMedicine;
        // 薬剤コードを持っていないものは処理しない
        if (catTreatMedicine?.cd == null) return;

        // 薬剤マスタ or 調整薬剤マスタ
        // 処置区分と薬剤区分を取得
        // ※処置区分のみの薬剤、薬剤区分のみの薬剤、両方ある薬剤の3種があるため両方取得
        // 　原則薬剤区分に従い、薬剤区分が無い場合は処置区分に従う
        const { medicineType, treatClass } = catTreatment;
        // medicineType の値があればその値を参照し、
        // なければ treatClass の値を参照して処理対象のマスタを判断する
        const [typeCd, mixCd, normalCd] = medicineType
          ? [
            Number(medicineType),
            CODES.MEDICINE_TYPE.MIX.cd,
            CODES.MEDICINE_TYPE.NORMAL.cd,
          ] : [
            treatClass,
            CODES.TREATMENT_CLASS.MIX.cd,
            CODES.TREATMENT_CLASS.NORMAL.cd,
          ];
        let mst = null;
        if (typeCd === mixCd) {
          // 調整薬剤マスタから取得
          mst = mstMedicineMix;
        } else if (typeCd === normalCd) {
          // 薬剤マスタから取得
          mst = mstMedicine;
        }

        const treatMedicine = mst
          ? mst.find(item => item.medicineCd === catTreatMedicine.cd)
          : null;
        if (treatMedicine?.unitDecimalPoint != null) {
          // 薬剤コードに該当するマスタから小数部桁数が取得できた場合
          catTreatMedicine.decPoint = treatMedicine.unitDecimalPoint;
        }
      });
    },

    /**
     * 初期化処理
     */
    async init() {
      if (!this.getOrdNo) return;

      // データをクリアする
      this.setComplaintData([]);
      this.medicineInfoList = [];

      // API呼び出し
      const [
        response,
        monitorData,
        medicineAllResponse,
        medicineResponse,
      ] = await Promise.all([
        this.getTreatmentRecordComplaint({
          ordNo: this.getOrdNo,
          selectedPatId: this.selectedPatId
        }),
        this.getMonitorMsgRecord({
          ordNo: this.getOrdNo,
          facilityCd: this.getSharedFacilityCd,
          selectedPatId: this.selectedPatId
        }),
        this.fetchMedicineAllTabooAllergy(),
        this.fetchMedicineInfoList(),
      ]);

      // 治療記録データの取得
      const {
        rst_complaint_info,
        rst_treatment_info,
        rst_treat_staff_info,
        rst_start_date,
        rst_end_date
      } = response.data;

      // データを解析する
      const rstComplaintInfo = JSON.parse(rst_complaint_info) || [];
      const rstTreatmentInfo = JSON.parse(rst_treatment_info) || [];
      const rstTreatStaffInfo = JSON.parse(rst_treat_staff_info) || [];
      this.beforeTreatmentRecordComplaintInfo = {
        rstComplaintInfo,
        rstTreatmentInfo,
        rstTreatStaffInfo,
      };

      // モニター・メッセージの取得と処理
      const processedTreatmentInfo = this.processMonitorData(monitorData, rstTreatmentInfo, rstTreatStaffInfo);

      // 保存日情報
      this.rstStartDate = rst_start_date;
      this.rstEndDate = rst_end_date;

      // データ集約型処理
      const complaintList = this.aggregateData(
        rstComplaintInfo,
        processedTreatmentInfo.treatmentInfo,
        processedTreatmentInfo.staffInfo
      );

      // 最新の薬剤を取得
      const medicine = medicineAllResponse.data;

      // 投与済みの投与薬剤データの取得
      const rstMediInfo = medicineResponse?.data?.rst_medi_info;
      const medicineInfoList = rstMediInfo ? this.makeComplaintsFromMedicineInfo(rstMediInfo, medicine) : [];

      // 薬剤情報の抽出
      this.extractMedicine(complaintList.concat(medicineInfoList), medicine);

      // 透析開始レコードと透析終了レコードの追加
      const finalComplaintList = this.addDialysisRecords(complaintList);

      // データを更新する
      this.setComplaintData(finalComplaintList.sort(this.compareComplaintList));
      this.comparisonModel = JSON.stringify(this.getComplaintData());
      this.medicineInfoList = medicineInfoList;
    },
    // 投与薬剤情報を取得
    async fetchMedicineInfoList() {
      // 施設設定で投与薬剤情報表示がOFFの場合はnullを返して終わる
      if (await this.isMedicineInfoDisabled()) return null;

      return await sendRequestGetTreatmentRecordMediInfo(
        this.getOrdNo,
        this.selectedPatId
      );
    },
    // 施設設定で投与薬剤情報表示がONの場合はtrueを返す
    async isMedicineInfoDisabled() {
      if (this.medicineInfoSettingValue == null) {
        // まだ施設設定を取得していない場合
        const response = await sendRequestGetMstFacilitySettingValue(
          this.getFacilityCd,
          COMPLAINT_MEDICINE_INFO,
          this.selectedPatId
        );
        this.medicineInfoSettingValue = (response?.data === TOGGLE_VALUE_ON)
          ? TOGGLE_VALUE_ON
          : TOGGLE_VALUE_OFF;
      }
      return this.medicineInfoSettingValue === TOGGLE_VALUE_OFF;
    },

    /**
     * プロセス監視メッセージデータ
     * @param {Object} monitorData データの監視
     * @param {Array} treatmentInfo 処置情報
     * @param {Array} staffInfo ディスポーザー情報
     * @returns {Object} 処理されたデータ
     */
    processMonitorData(monitorData, treatmentInfo, staffInfo) {
      if (!monitorData?.data?.length) {
        return { treatmentInfo, staffInfo };
      }

      let tempCtlNo = -1;
      monitorData.data.forEach(element => {
        if (this.shouldProcessMonitorElement(element)) {
          const checkFlag = element.reportDispFlg === "1" ? 1 : 0;

          treatmentInfo.push(this.createMonitorTreatmentInfo(element, tempCtlNo, checkFlag));
          staffInfo.push(this.createMonitorStaffInfo(element, tempCtlNo, checkFlag));

          element.ctlNo = tempCtlNo;
          tempCtlNo--;
        }
      });
      this.monitorData = monitorData;

      return { treatmentInfo, staffInfo };
    },

    /**
     * 監視要素を処理する必要があるかどうかの判断
     * @param {Object} element モニター要素
     * @returns {boolean} 処理が必要かどうか
     */
    shouldProcessMonitorElement(element) {
      return element.reportDispFlg === "1" ||
             (element.reportDispFlg === "0" && (element.dispFlg === "1" || element.dispFlg === "2"));
    },

    /**
     * 監視処置情報の作成
     * @param {Object} element モニター要素
     * @param {number} ctlNo 管理番号
     * @param {number} checkFlag サインを確認してください
     * @returns {Object} ディスポジション情報の監視
     */
    createMonitorTreatmentInfo(element, ctlNo, checkFlag) {
      return {
        row_no: 1,
        checkFlag,
        ctl_no: ctlNo,
        occur_date: element.eventRegDate,
        treat_name: element.machineRecordMessage,
        upDate: element.upDate,
        is_editable: "1"
      };
    },

    /**
     * 監視ディスポーザー情報の作成
     * @param {Object} element モニター要素
     * @param {number} ctlNo 管理番号
     * @param {number} checkFlag サインを確認してください
     * @returns {Object} ディスポーザー情報の監視
     */
    createMonitorStaffInfo(element, ctlNo, checkFlag) {
      return {
        row_no: 1,
        checkFlag,
        ctl_no: ctlNo,
        occur_date: element.eventRegDate,
        upDate: element.upDate,
        is_editable: "1",
        treat_staff_cd: element.userId
      };
    },

    /**
     * データ集約型処理
     * @param {Array} complaintInfo 愁訴情報
     * @param {Array} treatmentInfo 処置情報
     * @param {Array} staffInfo ディスポーザー情報
     * @returns {Array} 処理されたデータのリスト
     */
    aggregateData(complaintInfo, treatmentInfo, staffInfo) {
      if (!complaintInfo && !treatmentInfo && !staffInfo) {
        return [];
      }

      // 制御番号と発生日の一意の組み合わせを取得
      const uniqueKeys = new Set([
        ...complaintInfo.map(e => `${e.ctl_no}_${e.occur_date}`),
        ...treatmentInfo.map(e => `${e.ctl_no}_${e.occur_date}`),
        ...staffInfo.map(e => `${e.ctl_no}_${e.occur_date}`)
      ]);
      return Array.from(uniqueKeys).flatMap(key => {
        const [ctlNo, occurDate] = key.split("_");
        const numCtlNo = parseInt(ctlNo);

        // 愁訴に関する関連情報を取得する
        const complaints = this.getComplaints(complaintInfo, numCtlNo, occurDate);

        // 関連する処分情報と処分者情報を取得する
        const { newTreatmentList } = this.getTreatments(
          treatmentInfo,
          staffInfo,
          numCtlNo,
          occurDate
        );

        // データの長さを揃える
        return this.alignDataLength(complaints, newTreatmentList, numCtlNo, occurDate);
      });
    },

    alignDataLength(complaints, treatmentList, ctlNo, occurDate) {
      // マップを作成して、さまざまなrowNosのデータを格納する
      const rowNoMap = new Map();

      // 行別グループ化の苦痛データなし
      complaints.forEach(complaint => {
        const rowNo = complaint.complaint.rowNo;
        if (!rowNoMap.has(rowNo) && rowNo) {
          rowNoMap.set(rowNo, { complaints: [], treatments: [] });
        }
        rowNoMap.get(rowNo)?.complaints?.push(complaint);
      });

      // 行ごとのディスポジション データグループなし
      treatmentList.forEach(treatment => {
        const rowNo = treatment.rowNo;
        if (!rowNoMap.has(rowNo) && rowNo) {
          rowNoMap.set(rowNo, { complaints: [], treatments: [] });
        }
        rowNoMap.get(rowNo)?.treatments?.push(treatment);
      });
      // 各行のデータを処理しますNo グループと結果をマージします
      const result = [];
      rowNoMap.forEach((group, rowNo) => {
        const maxSize = Math.max(group.complaints.length, group.treatments.length);

        // 補足的な愁訴データ
        while (group.complaints.length < maxSize) {
          group.complaints.push(new Complaint({
            ctl_no: ctlNo,
            checkFlag: rowNoMap.get(rowNo).treatments.checkFlag,
            occur_date: occurDate,
            row_no: rowNo
          }, false, false, true));
        }

        // 補足処分データ
        while (group.treatments.length < maxSize) {
          group.treatments.push(new Treatment({
            ctl_no: ctlNo,
            occur_date: occurDate,
            row_no: rowNo
          }, null, true));
        }

        // 廃棄関係の設定
        group.treatments.forEach((t, idx) => {
          group.complaints[idx].treatmentList = [t];
          group.complaints[idx].isDummy = group.complaints[idx].isDummy && t.isDummy;
        });

        // チェックフラグを設定する
        group.complaints.forEach(e => {
          if (e.treatmentList.some(el => el.checkFlag == "0")) {
            e.checkFlag = 0;
          }
        });

        result.push(...group.complaints);
      });
      return result;
    },

    /**
     * 愁訴に関する情報を取得する
     * @param {Array} complaintInfo 愁訴情報のリスト
     * @param {number} ctlNo 管理番号
     * @param {string} occurDate 発生年月日
     * @returns {Array} 愁訴情報
     */
    getComplaints(complaintInfo, ctlNo, occurDate) {
      const filteredComplaints = complaintInfo.filter(c => c.ctl_no === ctlNo);
      return filteredComplaints.length > 0
        ? filteredComplaints.map(c => new Complaint(c))
        : [new Complaint({ ctl_no: ctlNo, occur_date: occurDate }, false, false, true)];
    },

    /**
     * 廃棄情報を取得する
     * @param {Array} treatmentInfo 廃棄情報のリスト
     * @param {Array} staffInfo ディスポーザー情報のリスト
     * @param {number} ctlNo 管理番号
     * @param {string} occurDate 発生年月日
     * @returns {Object} 廃棄情報と廃棄リスト
     */
    getTreatments(treatmentInfo, staffInfo, ctlNo, occurDate) {
      const treatments = treatmentInfo.filter(c => c.ctl_no === ctlNo);
      const treatStaffList = staffInfo.filter(staff => staff.ctl_no === ctlNo);
      const orgTreatmentListCount = treatments.length;

      // ディスポジションデータとディスポーザーデータの長さを揃える
      while (treatments.length < treatStaffList.length) {
        treatments.push({ checkFlag: treatStaffList[treatments.length].checkFlag, ctl_no: ctlNo, row_no: treatments.length + 1, occur_date: occurDate });
      }

      // 新しい廃棄リストを作成する
      const newTreatmentList = treatments.map((treatment, idx) =>
        new Treatment(
          treatment,
          treatStaffList.length > idx ? treatStaffList[idx] : null,
          orgTreatmentListCount > idx ? false : true)).sort((a, b) => a.rowNo - b.rowNo);
      return { treatments, newTreatmentList };
    },

    /**
     * 透析レコードを追加する
     * @param {Array} complaintList 愁訴のリスト
     * @returns {Array} 透析レコードのリストを追加する
     */
    addDialysisRecords(complaintList) {
      const result = [...complaintList];

      // 透析開始記録を追加
      if (this.rstStartDate) {
        result.unshift(
          new Complaint(
            { occur_date: this.rstStartDate, complaint: "治療開始" },
            true));
      }

      // 透析終了レコードを追加する
      if (this.rstEndDate) {
        result.push(
          new Complaint(
            { occur_date: this.rstEndDate, complaint: "治療終了" },
            true));
      }

      return result;
    },

    /**
     * 透析開始または透析終了の場合に背景色を設定する.
     */
    backgroundStyle(e) {
      return e.isDialysis ? "dialysis-tr" : this.editStatus(e) ? "even-row" : "odd-row";
    },
    /**
     * 愁訴処置の愁訴セルのボーダースタイルを取得する.
     * @param {*} rowData 愁訴処置の一行分のデータ
     * @returns {String} クラス名
     */
    borderBottomStyleCompliants(rowData) {
      // 最終行又はセルの縦結合がない場合
      if (rowData.isLast || rowData.rowSpan === 1) {
        return "border-bottom-last";
      }
      const { cd, ctlNo, inputClass, name } = rowData.complaints;
      if (!cd && !ctlNo && !inputClass && !name) {
        return "border-bottom-hidden";
      }
      return null;
    },
    /**
     * 愁訴処置の処置セルのボーダースタイルを取得する.
     * @param {*} rowData 愁訴処置の一行分のデータ
     * @returns {String} クラス名
     */
    borderBottomStyleTreatment(rowData) {
      // 最終行又はセルの縦結合がない場合
      if (rowData.isLast || rowData.rowSpan === 1) {
        return "border-bottom-last";
      }
      return null;
    },
    /**
     * 再描画処理
     */
    refresh() {
      // 子機能ボタンエリアの更新
      this.$emit("update");
      if (this.selfScreenName !== this.$route.name) return;

      this.init();
      this.alertFlag = true;
    },

    // 禁忌・アレルギーによる薬剤ボトルアイコンの選択
    getMedicineBottleIconSrc(rowData) {
      const medicineName = rowData.treatment.treatMedicine.name;
      const fileName = (["【禁忌】", "【禁忌・ｱﾚﾙｷﾞｰ】", "【ｱﾚﾙｷﾞｰ】"].some(
        prefix => medicineName.includes(prefix))) ? "medicine-bottle-red" : "medicine-bottle";
      return `img/treatment-record/${fileName}.png`;
    },
    checkStatus(data) {
      let updFlag = data.checkFlag;
      let operateFlg = 'edit';
      if (data.checkFlag == "0") {
        updFlag = 1;
      } else {
        updFlag = 0
      }
      let complaintData = this.getComplaintData();
      let ctlNo = data.treatment?.ctlNo || data.complaints?.ctlNo || data.treatment.treatStaff?.ctlNo;
      let rowNo = data.treatment?.rowNo || data.complaints?.rowNo || data.treatment.treatStaff?.rowNo;
      complaintData.forEach(
        e => {
          if (e.complaint.ctlNo === ctlNo && e.complaint.rowNo === rowNo) {
            e.checkFlag = updFlag;
            e.treatmentList[0].checkFlag = updFlag;
          } else {
            if (e.treatmentList[0] != undefined && e.treatmentList[0].ctlNo === ctlNo && e.treatmentList[0].rowNo === rowNo) {
              e.checkFlag = updFlag;
              e.treatmentList.forEach(el => {
                el.checkFlag = updFlag;
              })
            }
          }
        }
      );
      this.setComplaintData(complaintData);
      if (data?.complaints?.ctlNo < 0) {
        // 監視メッセージを処理する
        this.handleMonitorMessages();
        return;
      }
      // 親の保存イベントを呼びだす
      const complaint = complaintData.filter(item => {
        if ([3, 4].includes(data.treatment.treatClass)) {
          if (item.treatmentList[0]?.treatClass === data.treatment.treatClass) {
            operateFlg = data.treatClass === 3 ? "oxygenEdit" : "electrocardiogramEdit";
          }
          return item.treatmentList[0]?.treatClass === data.treatment.treatClass;
        }
        return ctlNo === (item.complaint?.ctlNo || item.treatmentList[0]?.ctlNo || item.treatmentList[0]?.treatStaff?.ctlNo)
      });
      this.onSave(complaint, operateFlg);
    },
    getChangeStatus() {
      return this.comparisonModel !== JSON.stringify(this.getComplaintData());
    },
    updateChangeStatus() {
      this.alertFlag = false;
    },
    editStatus(data) {
      const ctlNo = (data.treatment != undefined)
        ? data.treatment.ctlNo
        : data.complaints.ctlNo;
      return parseInt(ctlNo) > 0;
    },
    selectConfirm(index) {
      const element = getScopedElementById(`checkbox-btn${index}`, this.$el || this);
      const clickElement = element.children[0];
      clickElement.click();
    },
    isEditDisabled() {
      return !this.getItemAuthorized() || this.isReadOnly || !this.isShared;
    },
    getItemAuthorized() {
      return getAuthorized("TreatmentRecord", "default_authority");
    },
    isTreatmentEditDisabled(isEditable) {
      return isEditable !== undefined && isEditable !== '1' && isEditable !== 1;
    },
    isCheckboxDisabled(rowData) {
      return (
        !this.getItemAuthorized()
        || rowData.isDialysis
        || rowData.isMedicineInfo
        || this.isTreatmentEditDisabled(rowData.treatment.isEditable)
        || !this.isShared
      );
    },
    /**
     * 画面に表示中のリストから酸素吸入レコードを抽出
     */
    getOxygenModals() {
      const oxygenTreatments = this.displayList.filter(e =>
        e.treatment.isOxygenStart || e.treatment.isOxygenEnd
      );
      // 時刻が降順でソートされている場合は昇順に並び替えする
      if (this.sortOrder < 0) {
        oxygenTreatments.reverse();
      }
      // モーダル用に新しい配列を作成
      return oxygenTreatments.map(e => new OxygenModal(e.treatment));
    },
    /**
     * 画面に表示中のリストから心電図レコードを抽出
     */
    getElectrocardiogramModals() {
      const electrocardiogramTreatments = this.displayList.filter(e =>
        e.treatment.isElectrocardiogramStart || e.treatment.isElectrocardiogramEnd
      );
      // 時刻が降順でソートされている場合は昇順に並び替えする
      if (this.sortOrder < 0) {
        electrocardiogramTreatments.reverse();
      }
      // モーダル用に新しい配列を作成
      return electrocardiogramTreatments.map(e => new ElectrocardiogramModal(e.treatment));
    },
  },
  watch: {
    getDataListForIndex() {
      if (this.getDataListForIndex.length === 0) {
        this.setTempCtlNo(0);
      } else {
        let ctlNo = 0;
        this.getDataListForIndex.forEach(e=>{
          e.treatmentList.forEach(el=>{
            if (el.ctlNo > ctlNo) {
              ctlNo = el.ctlNo
            }
          })
        });
        this.setTempCtlNo(ctlNo);
      }
    }
  },
  created() {
    this.init();
    // 画面名称取得
    this.selfScreenName = this.$route.name;
    // イベント登録
    // 保存イベントを登録
    EventBus.$on("saveCompTreatEdit", this.onSave);
    EventBus.$on("saveCompTreatCreate", this.onSave);
  },
  mounted() {
    EventBus.$on("refresh", this.refresh);
  },
  /**
   * コンポーネント破棄
   */
  beforeUnmount() {
    EventBus.$off("refresh", this.refresh);
    EventBus.$off("saveCompTreatEdit", this.onSave);
    EventBus.$off("saveCompTreatCreate", this.onSave);

    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  }
};
</script>

<style scoped>
.ntss-list-header-th-sticky {
  z-index: 1;
}
.btn-area :deep(ons-button) {
  margin: 8px;
}
.scroll-table {
  width: 1px;
}
.ntss-list-body-td {
  vertical-align: top;
}
.dialysis-tr {
  background-color: var(--treatment-record-dialysis-tr);
}
td.treat-name {
  border-right: none;
}
/**
 * 愁訴と処置のセル内のスタイル
 */
td.treat-name,
td.complaint-name {
  white-space: pre;
  vertical-align: top;
  white-space: pre-line;
  word-break: break-word;
}
td.medicine-bottle {
  width: 24px;
  border-left: none;
  -webkit-filter: invert(var(--treatment-record-medicine-bottle-invert));
  filter: invert(var(--treatment-record-medicine-bottle-invert));
  vertical-align: middle;
}
.edit-button {
  font-size: 1em;
  width: 3.5em;
  margin-left: 8px;
}
.complaint-list-body-tr {
  /* 一覧のボーダーライン */
  border: dotted 1px var(--ntss-list-border-color);
  /* 一覧の文字色 */
  color: var(--ntss-list-body-color);
}
.complaint-list-body-td {
  border: dotted 1px var(--ntss-list-border-color);
  padding: 8px;
  border-left-style: solid;
  border-right-style: solid;
}
.border-bottom-last,
.complaint-list-body-time-td,
.complaint-list-body-tr:last-child {
  border-bottom-style: solid;
  vertical-align: top;
}
/**
 * テーブルのボーダーの非表示
 */
.border-bottom-hidden {
  border-bottom-style: hidden;
}
.complaint-list-body-tr {
  /* 一覧のボーダーライン */
  border: dotted 1px var(--ntss-list-border-color);
  /* 一覧の文字色 */
  color: var(--ntss-list-body-color);
}
.complaint-list-body-td {
  border: dotted 1px var(--ntss-list-border-color);
  padding: 8px;
  border-left-style: solid;
  border-right-style: solid;
}
.border-bottom-last,
.complaint-list-body-time-td,
.complaint-list-body-tr:last-child {
  border-bottom-style: solid;
  vertical-align: top;
}
/**
 * テーブルのボーダーの非表示
 */
.border-bottom-hidden {
  border-bottom-style: hidden;
}
.align-center {
  text-align: center;
}
.ntss-checkbox-shaving {
  width: 1em;
}
.even-row {
  background-color: var(---ntss-list-item-background-color);
}
.odd-row {
  background-color: var(--ntss-list-content-2nd-background-color);
}
.checkbox-border {
  border: dotted 1px var(--ntss-list-border-color);
  border-bottom-style: solid;
}
.complaint-checkbox{
  margin: 10px 5px;
}
</style>
