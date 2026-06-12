/**
 * 治療記録の子機能 愁訴処置編集
 */
<template>
  <modal-base @onClose="onClickCancel">
    <template #body>
      <div class="treatment-record-modal">
      <div class="compliant-edit-list">
        <div class="scroll-table" style="width: 80%;">
          <div style="height: 4.5em; display: flex; flex-direction: column; justify-content: space-around;">
            <div class="compliant-edit-dummy-space"></div>
            <div class="treatment-record-accordion">
              <com-date-time-input :is-show-clear="true" class="ntss-style-date-time" labelName="日時" :required="true" v-model="actualModel.occurDate" @handleCurrentDateChange="handleCurrentDateChange" @handleCurrentTimeChange="handleCurrentTimeChange" :row-height="'2em'"/>
            </div>
          </div>
          <div style="overflow-y: auto; height: calc(100% - 4.5em); min-height: calc(475px - 4.5em);">
            <table class="ntss-list">
              <thead>
                <tr>
                  <th class="ntss-list-header-th-sticky delete-checkbox-col" style="width: 2em"></th>
                  <th class="ntss-list-header-th-sticky" style="width: 25%; min-width: 12em;">愁訴</th>
                  <th class="ntss-list-header-th-sticky" style="width: 25%; min-width: 12em;">処置</th>
                  <th class="ntss-list-header-th-sticky" style="min-width: 15em;">処置薬剤／手技</th>
                </tr>
              </thead>
              <tbody :class="themeBlack">
                <template v-for="(item, index) in actualModel.items" :key="index + '-1'">
                  <tr class="ntss-list-body-tr" :class="{'new-row': index === actualModel.items.length - 1}">
                    <td class="ntss-list-body-td delete-checkbox-col" rowspan="2">
                      <div style="display:block;">
                        <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 start -->
                        <v-ons-button
                          class="comp-treat-button btn3-normal"
                          @click="onEdit(item, index)">編集</v-ons-button>
                        <v-ons-button
                          class="comp-treat-button btn3-normal"
                          v-if="!item.isNew"
                          v-model="item.isDel"
                          @click="onDelete(index)">削除</v-ons-button>
                        <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 end -->
                      </div>
                    </td>
                    <td class="ntss-list-body-td complaint-td" rowspan="2">
                      <com-textarea
                        v-if="item.complaint"
                        :content="item.complaint.name"
                        modelEvent="change"
                        rows="4"
                        :idTextarea="'com-textarea-cps' + index"
                        cssClass="com-textarea textarea-resize-vertical"
                        @set-content-data="setContentDataCps($event, index)"
                      ></com-textarea>
                      <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 start -->
                      <v-ons-button
                        v-if="item.complaint"
                        class="edit-button btn3-normal"
                        @click="onSelectComplaint($event, index)"
                      >選択</v-ons-button>
                      <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 end -->
                    </td>
                    <td class="ntss-list-body-td treatment-td" rowspan="2">
                      <com-textarea
                        v-if="item.treatment"
                        :content="item.treatment.name"
                        modelEvent="change"
                        rows="4"
                        :idTextarea="'com-textarea-tms' + index"
                        cssClass="com-textarea textarea-resize-vertical"
                        @set-content-data="setContentDataTms($event, index)"
                        @change="medicineClear(index)"
                      ></com-textarea>
                      <v-ons-button
                        v-if="item.treatment"
                        class="edit-button btn3-normal"
                        @click="onSelectTreatment($event, index)"
                      >選択</v-ons-button>
                    </td>
                    <td class="ntss-list-body-td selector-td">
                      <com-master-number-input
                        class="treat-medicine-selector"
                        :unitName="item.treatMedicineUnit"
                        :step="item.treatMedicineStep"
                        :inputMin="0"
                        :inputMax="99999"
                        :medicine-type="item.medicineType"
                        :readMasterData="fetchMedicineAll"
                        :masterDefine="treatMedicine"
                        :modelValue="item.treatMedicine"
                        @update:modelValue="(val) => onTreatMedicineUpdate(val, index)"
                        @changeUnit="(unit) => item.treatMedicineUnit = unit"
                        @changeStep="(step) => item.treatMedicineStep = step"
                        @change="(value) => item.treatMedicine.value = parseFloat(value)"
                        @changeMedicineType="medicineObj => {item.medicineType = medicineObj.medicineType;
                        item.treatClass = medicineObj.treatClass;}"
                        :disabled="(item.treatment.name || item.treatment.cd) ? false : true"
                        :index="index"
                        :type-no="1"
                        :required="true"
                      />
                    </td>
                  </tr>
                  <tr v-if="!item.isDel" :key="index + '-2'" class="ntss-list-body-tr" :class="{'new-row': index === actualModel.items.length - 1}">
                    <td class="ntss-list-body-td selector-td">
                      <common-master-selector
                        class="procedure-selector"
                        :masterType="MasterType.PROCEDURE_TREATMENT_RECORD"
                        :facilityCd="facilityCd"
                        :initItem="procedurePickerItem(item)"
                        :editItem="procedurePickerItem(item)"
                        :selectedItemClass="'selector-input'"
                        :btnClass="'btn3-normal'"
                        :btnDisabled="(item.treatment.name || item.treatment.cd) ? false : true"
                        @popover-return="d => onProcedureReturn(d, item)"
                      />
                    </td>
                  </tr>
                </template>
              </tbody>
            </table>
          </div>
        </div>
        <div class="scroll-table" style="width: 20%; min-width:11em; margin-right: 5px;" id="new-comp-treat-staff-area">
          <!-- 処置者検索欄 -->
          <div style="height: 4.5em; display: flex; flex-direction: column; justify-content: space-around;">
            <div style="margin-left: 10px;">
              <v-ons-select v-model="selectedJobCd.inProgress" @change="doStaffSearch" style="width: 100%;">
                <option v-for="job in getMstJobList" :key="job.length" :value="job.jobCd">
                  {{ job.jobName }}
                </option>
              </v-ons-select>
            </div>
            <div style="display: flex; margin-left: 10px;">
              <div>
                <v-ons-input type="text" v-model="strToStaffSearch.inProgress" @keydown.enter="doStaffSearch"></v-ons-input>
              </div>
              <div style="margin-left: 0.5em; margin-right: 1px;">
                <v-ons-button class="btn3-normal" @click="doStaffSearch">抽出</v-ons-button>
              </div>
            </div>
          </div>
          <!-- 処置者リスト -->
          <div style="overflow-y: auto; height: calc(100% - 4.5em); min-height: calc(475px - 4.5em);">
            <table class="ntss-list" style="margin-left: 10px;">
              <thead>
                <tr id="new-comp-treat-staff-header">
                  <th class="ntss-list-header-th-sticky">処置者</th>
                </tr>
              </thead>
              <tbody :class="themeBlack">
                <template v-for="(item, index) in actualModel.treatStaff" :key="index + '-1'">
                  <tr class="ntss-list-body-tr" :id="'comp-treat-staff-' + item.userId" v-if="hasMatchedStaffName(item)">
                    <td td class="ntss-list-body-td">
                      <div style="display: flex; align-items: center;">
                        <div>
                          <v-ons-checkbox
                            :input-id="'comp-treat-staff-' + index"
                            v-model="item.selected"
                          ></v-ons-checkbox>
                        </div>
                        <div>
                          <label
                            :for="'comp-treat-staff-' + index"
                            class="label-text">{{ `${item.userLastName} ${item.userFirstName}` }}</label>
                        </div>
                      </div>
                    </td>
                  </tr>
                </template>
              </tbody>
            </table>
          </div>
        </div>
      </div>
      <complaint-selector
        :popoverVisible="complaintSelector.visible"
        :popoverTarget="complaintSelector.target"
        @popover-close="onCloseSelectComplaint"
      />
      <treatment-selector
        :popoverVisible="treatmentSelector.visible"
        :popoverTarget="treatmentSelector.target"
        @popover-close="onCloseSelectTreatment"
      />
      </div>
    </template>
    <template #footer>
      <div class="flex-container" style="overflow-x: auto;">
      <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 start -->
      <div class="denial-btn-area" style="background:none">
        <v-ons-button class="button denial-btn btn2-cancel" @click="onClickCancel">キャンセル</v-ons-button>
        <v-ons-button class="button denial-btn btn4-alert" style="margin-left: 10px; margin-right: 10px;" @click="onAllDelete">削除</v-ons-button>
      </div>
      <div class="registration-btn-area" style="background:none">
        <v-ons-button class="button registration-btn btn1-execute" :disabled="!isChanged" @click="onClickApply">保存</v-ons-button>
      </div>
      <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 end -->
      </div>
    </template>
  </modal-base>
</template>

<script>
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import ModalBase from "@/components/modals/ModalBase";
import MultiModalMixin from "@/components/modals/MultiModalMixin";
import DiscardConfirmationMixin from "@/components/treatment-record/DiscardConfirmationMixin";
import CommonDateTimeComponent from "@/components/treatment-record/submenu/common/CommonDateTimeComponent";
import CommonMasterSelector from "@/components/common/master-selector/CommonMasterSelector.vue";
import * as MasterType from "@/components/common/master-selector/MasterType";
import CommonMasterAndNumberInputComponent from "@/components/treatment-record/submenu/common/CommonMasterAndNumberInputComponent";
import ComplaintSelectorComponent from "@/components/treatment-record/submenu/complaint/ComplaintSelectorComponent";
import TreatmentSelectorComponent from "@/components/treatment-record/submenu/complaint/TreatmentSelectorComponent";
import { Complaint } from "@/models/treatment-record/complaint/Complaint";
import { Treatment } from "@/models/treatment-record/complaint/Treatment";
import { ComplaintEdit } from "@/models/treatment-record/complaint/ComplaintEdit";
import { TreatmentStaff } from "@/models/treatment-record/complaint/TreatmentStaff";
import { MasterAndNumber } from "@/models/common/MasterAndNumber";
import { Master } from "@/models/common/master-selector-condition/Master";
import {
  treatMedicine,
  treatUser,
  procedure
} from "@/components/common/master-selector/MasterSelectorDefinitions";
import ComplaintComponentMixin from "@/components/treatment-record/submenu/complaint/ComplaintComponentMixin";
import { CODES } from "@/constants/TreatmentRecord";
import { EventBus } from "@/compat/vue/event-bus.js";
import BigNumber from "@/compat/number/bignumber";
import CommonTextArea from "@/components/common/CommonTextArea";
// mod #6107 2023/03/23 メッセージボックス全調整 張博 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";

// add #11380 愁訴処置にて登録される薬剤の判別子が間違って登録される 房 end
import cloneDeep from '@/compat/collections/lodash/cloneDeep';
import { messageFormat } from "@/functions/common/MessageFormat";
import { isNaN } from "@/compat/collections/lodash";
import { MstCompTreatment } from "@/models/treatment-record/complaint/MstCompTreatment";
export default {
  mixins: [MultiModalMixin, DiscardConfirmationMixin, ComplaintComponentMixin],
  components: {
    "modal-base": ModalBase,
    "com-date-time-input": CommonDateTimeComponent,
    "common-master-selector": CommonMasterSelector,
    "com-master-number-input": CommonMasterAndNumberInputComponent,
    "complaint-selector": ComplaintSelectorComponent,
    "treatment-selector": TreatmentSelectorComponent,
    "com-textarea": CommonTextArea
  },
  data() {
    return {
      MasterType,
      treatUser: treatUser,
      treatMedicine: treatMedicine,
      procedure: procedure,
      complaintSelector: {
        visible: false,
        target: null,
        index: null
      },
      treatmentSelector: {
        visible: false,
        target: null,
        index: null
      },
      actualModel: {
        occurDate: null,
        items: [],
        treatStaff: []
      },
      comparisonModel: "",
      /**
       * 利用者マスタ
       */
      mstUsers: [],
      /**
       * 編集中のインデックス
       */
      editIndex: null,
      // 抽出入力にバインドする文字列。処置者の名称を対象に抽出する
      strToStaffSearch: {
        inProgress: "", // 入力中の文字列にバインドする。「抽出」ボタン押下時にinUsedへコピーされる。
        inUsed: "" // 実際に検索に使われる文字列
      },
      // 職種選択にバインドする
      selectedJobCd: {
        inProgress: "",
        inUsed: ""
      },
      // 内部 日付没入,データ登録できました start
      currentTimeChange: 'time',
      currentDateChange: 'date',
      // 内部 日付没入,データ登録できました end
      originalComplaints: []
    };
  },
  methods: {
    // 内部 日付没入,データ登録できました start
    handleCurrentDateChange (val) {
      this.currentDateChange = val
    },
    handleCurrentTimeChange (val) {
      this.currentTimeChange = val
    },
    // 内部 日付没入,データ登録できました end
    ...mapGetters("treatment-record/complaint", [
      "getComplaintData",
      "getEditingTime",
      "getEditingCtlNo"
    ]),
    ...mapActions("treatment-record/complaint", ["setComplaintData", "setEditCompAndTreat", "setEditOccurDate"]),
    ...mapActions("multi-sub-modal", [
      "showComplaintCreate"
    ]),
    ...mapActions("mst-user", ["mstJobList"]),
    procedurePickerItem(item) {
      return {
        value: item?.procedure?.cd ?? null,
        text: item?.procedure?.name ?? ""
      };
    },
    onProcedureReturn(data, item) {
      item.procedure.cd = data?.value ?? null;
      item.procedure.name = data?.text ?? "";
    },
    /**
     * キャンセルボタンクリック時ハンドラ.
     */
    onClickCancel() {
      if (this.isChanged) {
        this.discardConfirm(this.hideModal);
      } else {
        this.hideModal();
      }
    },
    /**
     * 反映ボタンクリック時ハンドラ.
     */
    onClickApply() {
      // バリデーション
      // 内部 日付没入,データ登録できました start
      const timeOrDate = (this.currentTimeChange == null || this.currentDateChange == null) ? null : 'timeOrDate'
      if (
        !this.hasComplaintData() &&
        !this.validateOccurDate(timeOrDate)
      ) {
        // 内部 日付没入,データ登録できました end
        // エラーなので処理中断
        return;
      }
      const amountIsNullFlag = this.actualModel.items.some((item) => {
        return !item.isDel && item.treatMedicine?.name && !(item.treatMedicine?.value);
      });
      if (amountIsNullFlag) {
        this.$ons.notification.alert({
          title: DIALOG_MESSAGES[13000170].title,
          message: messageFormat(DIALOG_MESSAGES[13000170].message),
        });
        return;
      }

      this.doApply();
    },
    /**
     * 更新対象のデータを抽出する.
     */
    hasComplaintData() {
      return this.actualModel.items.filter(e => !(e.isNew && e.isEmpty())).length > 0 ||
      this.getSelectedTreatmentStaff().length > 0;
    },
    /**
     * 反映処理.
     */
    async doApply(operateFlg= 'edit') {
      try {
        // 現在編集されているデータが含まれていない苦痛データを取得する
        const complaintData = this.getFilteredComplaintData();

        // 選択したディスポーザーデータを取得する
        const selectedTreatmentStaff = this.getSelectedTreatmentStaff();

        // 取得更新的愁訴処置数据
        const updateItems = this.actualModel.items.filter(e => !(e.isNew && e.isEmpty()));

        // 更新されたデータがない場合は、すぐに戻ってください
        if(!this.hasComplaintData()) {
          EventBus.$emit("saveCompTreatEdit", this.originalComplaints, 'allDelComplaint');
          return;
        }

        // 新しい愁訴データの構築
        const newComplaints = this.buildNewComplaints(updateItems, selectedTreatmentStaff, operateFlg);
        EventBus.$emit("saveCompTreatEdit", newComplaints, operateFlg);

        // 特別なエラー・コードがない場合は、通常の保管プロセスを続行します
        this.setComplaintData(complaintData.concat(newComplaints).sort(this.compareComplaintList));
        // this.hideModal();

      } catch (error) {
        this.$ons.notification.alert({
          title: DIALOG_MESSAGES[13000141].title,
          message: messageFormat(DIALOG_MESSAGES[13000141].message),
        });
      }
    },
    /**
     * フィルタリングされた遭難後のデータを取得する(現在編集されているデータは含まれません)
     */
    getFilteredComplaintData() {
      return this.getComplaintData().filter(e => {
        if ((e.complaint.ctlNo !== this.getEditingCtlNo() &&
             e.treatmentList.filter(element => element.ctlNo === this.getEditingCtlNo()).length == 0)
          || e.isSpecial){
          return true;
        }
        return false;
      });
    },

    /**
     * 選択したディスポーザーデータを取得する
     */
    getSelectedTreatmentStaff() {
      this.mstUsers = JSON.parse(JSON.stringify(this.actualModel.treatStaff));
      return this.mstUsers
        .filter(user => user.selected)
        .map(user => TreatmentStaff.of({
          ctlNo: this.getEditingCtlNo(),
          rowNo: 0,
          inputClass: CODES.COMP_TREAT_INPUT_CLASS.CLIENT.cd,
          occurDate: this.actualModel.occurDate,
          treatStaffCd: user.userId,
          treatStaffName: user.userLastName + " " + user.userFirstName,
          copOrderNo: 0,
          isEditable: CODES.IS_EDITABLE.POSSIBLE.cd
        })) || [];
    },

    /**
     * 新しい愁訴データの構築
     */
    buildNewComplaints(updateItems, selectedTreatmentStaff, operateFlg) {
      // 愁訴処理データの構築
      const complaints = this.buildComplaints(updateItems);
      // 廃棄データの構造化
      const treatments = this.buildTreatments(updateItems);
      // 最大データレコード数の取得
      const maxSize = Math.max(
        complaints.length,
        treatments.length,
        selectedTreatmentStaff.length
      );

      // 愁訴データを最大数まで補足します
      this.fillComplaints(complaints, maxSize);

      // 廃棄データを最大数まで補充します
      this.fillTreatments(treatments, maxSize);

      this.fillTreatmentStaff(selectedTreatmentStaff, maxSize);

      // ディスポーザーデータの関連付け
      treatments.forEach((t, index) => {
        if(t) {
          selectedTreatmentStaff[index].rowNo = t.rowNo;
          t.setTreatmentStaff(selectedTreatmentStaff[index]);
          complaints[index].treatmentList = [t];
        }
      });
      complaints.forEach((complaint, index) => {
        const rowNo = index + 1;
        complaint.complaint.rowNo = rowNo;
        const treatment = complaint.treatmentList[0];
        if (treatment) {
          treatment.rowNo = rowNo;
          treatment.treatStaff.rowNo = rowNo;
        }
        if (operateFlg === 'allDel') {
          complaint.complaint.isDel = true;
          treatment.isDel = true;
          treatment.treatStaff.isDel = true;
        }
      });
      return complaints;
    },

    /**
     * 愁訴処理データの構築
     */
    buildComplaints(updateItems) {

      const complaints = updateItems
        // .filter(e => e.complaint?.name || e.complaint?.cd)
        .map(e => Complaint.of({
          ctlNo: this.getEditingCtlNo(),
          occurDate: this.actualModel.occurDate,
          compCd: e.complaint.cd,
          complaint: e.complaint.name,
          isDel: e.isDel
        }));
      // 愁訴データがない場合は、空のデータを追加します
      if(complaints.length === 0) {
        complaints.push(Complaint.of({
          ctlNo: this.getEditingCtlNo(),
          occurDate: this.actualModel.occurDate,
          compCd: null,
          complaint: null
        }, false, true));
      }

      return complaints;
    },

    /**
     * 廃棄データの構造化
     */
    buildTreatments(updateItems) {
      const treatments = updateItems.map(e => {
        return Treatment.of({
          ctlNo: this.getEditingCtlNo(),
          rowNo: e.rowNo,
          occurDate: this.actualModel.occurDate,
          treatClass: e.treatClass,
          treatCd: e.treatment.cd,
          treatName: e.treatment.name ? e.treatment.name : null,
          treatMedicineName: e.treatMedicine.name ? e.treatMedicine.name : null,
          amount: e.treatMedicine.value || null,
          unit: e.treatMedicineUnit,
          procedureCd: e.procedure.cd,
          procedureName: e.procedure.name ? e.procedure.name : null,
          treatMedicineCd: e.treatMedicine.cd,
          medicineType: e.medicineType,
          isDel: e.isDel
        }, null);
      });
      if (treatments.length === 0) {
        treatments.push(Treatment.of({
          ctlNo: this.getEditingCtlNo(),
          occurDate: this.actualModel.occurDate,
        }, null, true));
      }
      return treatments;
    },

    /**
     * 愁訴データを指定された数に補足します
     */
    fillComplaints(complaints, maxSize) {
      if(complaints.length < maxSize) {
        const addCount = maxSize - complaints.length;
        for(let i = 0; i < addCount; i++) {
          complaints.push(Complaint.of({
            ctlNo: this.getEditingCtlNo(),
            occurDate: this.actualModel.occurDate,
            compCd: null,
            complaint: null
          }, false, true));
        }
      }
    },

    /**
     * 破棄されたデータの数を指定した数に増やします
     */
    fillTreatments(treatments, maxSize) {
      if(treatments.length < maxSize) {
        const addCount = maxSize - treatments.length;
        for(let i = 0; i < addCount; i++) {
          treatments.push(Treatment.of({
            ctlNo: this.getEditingCtlNo(),
            occurDate: this.actualModel.occurDate
          }, null, true));
        }
      }
    },

    /**
     * ディスポーザーデータを指定した数まで補充します
     */
    fillTreatmentStaff(selectedTreatmentStaff, maxSize) {
      if(selectedTreatmentStaff.length < maxSize) {
        const addCount = maxSize - selectedTreatmentStaff.length;
        for(let i = 0; i < addCount; i++) {
          selectedTreatmentStaff.push(TreatmentStaff.of({
            ctlNo: this.getEditingCtlNo(),
            occurDate: this.actualModel.occurDate,
            treatStaffCd: null,
            treatStaffName: null,
            copOrderNo: null,
            isEditable: CODES.IS_EDITABLE.POSSIBLE.cd
          }));
        }
      }
    },
    /**
     * 編集ボタンクリック時ハンドラ.
     *
     * @param {TreatmentEdit} item クリックされた行アイテム
     * @param {Integer} index 選択された行
     */
    onEdit(item, index) {
      const currentRow = cloneDeep(item);
      if (item.isEmpty() && index === this.actualModel.items.length - 1) {
        currentRow.isNewEditFlag = true;
      }
      // 選択されたインデックスの退避
      this.editIndex = index;
      // 選択された情報をStoreに設定
      this.setEditOccurDate(this.actualModel.occurDate);
      this.setEditCompAndTreat(currentRow);
      // 新規登録画面の表示
      this.showComplaintCreate({isNew: false});
    },
    /**
     * 各行の削除ボタンクリック時ハンドラ.
     *
     * @param {Integer} index クリックされた行インデックス(0 ～)
     */
    onDelete(index) {
      this.actualModel.items.splice(index, 1);
    },
    /**
     * フッターの削除ボタンクリック時ハンドラ.
     */
    onAllDelete() {
      this.$ons.notification.confirm({
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
        // title: "愁訴処置削除確認",
        title: DIALOG_MESSAGES[13000142].title,
        // message: "表示している愁訴処置を全て削除します。<br>削除すると二度と元に戻せません。削除してもよろしいですか？",
        message: messageFormat(DIALOG_MESSAGES[13000142].message),
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        callback: answer => {
          if (answer === 1) {
            // this.actualModel.items.forEach(item => item.isDel = true);
            this.doApply('allDel');
          }
        }
      });
    },
    /**
     * 愁訴選択ボタンクリック時ハンドラ.
     */
    onSelectComplaint(ev, index) {
      this.complaintSelector.target = ev.target;
      this.complaintSelector.visible = true;
      this.complaintSelector.index = index;
    },
    /**
     * 愁訴選択完了時ハンドラ.
     */
    onCloseSelectComplaint(item) {
      if (item) {
        this.actualModel.items[this.complaintSelector.index].complaint = item;
      }
      this.complaintSelector.visible = false;
    },
    /**
     * 処置選択ボタンクリック時ハンドラ.
     */
    onSelectTreatment(ev, index) {
      this.treatmentSelector.target = ev.target;
      this.treatmentSelector.visible = true;
      this.treatmentSelector.index = index;
    },
    /**
     * 処置選択完了時ハンドラ.
     */
    onCloseSelectTreatment(item) {
      if (item && !item.isEmpty()) {
        const row = this.actualModel.items[this.treatmentSelector.index];
        row.treatment = item;
        row.treatMedicine = new MasterAndNumber(
          item.treatMedicine.cd,
          item.treatMedicine.name,
          item.amount
        );
        row.medicineType = item.treatMedicine.medicineType;
        row.treatClass = item.treatClass;
        // 薬剤がない場合、処置区分は「2」になる。
        if(!item.treatMedicine || (!item.treatMedicine.cd && !item.treatMedicine.name)) {
          row.treatClass = 2;
        }
        row.treatMedicineUnit = item.treatMedicine.unit;
        // 小数点ステップ数
        // 指示単位小数部:step制御用パラメータ
        var num = parseInt(item.treatMedicine.decPoint ? item.treatMedicine.decPoint : null);
        if (Number.isNaN(num)) {
          num = 0;
        }
        row.treatMedicineStep = Number(BigNumber(10).exponentiatedBy(BigNumber(num).negated()).valueOf());
        row.procedure = new Master(item.procedure.cd, item.procedure.name);

        // 処置で「未登録」が選択された場合、処置者をクリアする
        if (item.cd === null) {
          row.treatStaff = new Master();
        }
      } else if(item) {
        const row = this.actualModel.items[this.treatmentSelector.index];
        row.treatMedicine= new MasterAndNumber();
        row.treatMedicineUnit = "";
        row.procedure = new Master();
        row.medicineType = undefined;
        row.treatClass = 2;
        row.treatment = new MstCompTreatment();
      }
      // mod #11380 愁訴処置にて登録される薬剤の判別子が間違って登録される 房 end
      this.treatmentSelector.visible = false;
    },

    onTreatMedicineUpdate(val, index) {
      const item = this.actualModel.items[index];
      const prevCd = item.treatMedicine?.cd;
      item.treatMedicine = val;
      if (prevCd !== val?.cd) {
        this.handleInputTreatMedicine(val, index);
      }
    },
    handleInputTreatMedicine (master, index) {
      if (!master.cd) {
        this.actualModel.items[index].treatMedicine= new MasterAndNumber();
        this.actualModel.items[index].treatMedicineUnit = "";
        this.actualModel.items[index].procedure = new Master();
        this.actualModel.items[index].medicineType = undefined;
        this.actualModel.items[index].treatClass = 2;
      } else {
        this.actualModel.items[index].treatMedicine= master;
      }
    },
    /**
     * 初期化処理.
     */
    async init() {
      let complaints = this.getComplaintData().filter(
        e => {
          if ((e.complaint.ctlNo === this.getEditingCtlNo() || e.treatmentList.filter(element => element.ctlNo === this.getEditingCtlNo()).length > 0)
          && !e.isSpecial){
            return true;
          } else {
            return false;
          }
        });
      this.originalComplaints = cloneDeep(complaints);
      //mod FNSI改修内容 愁訴処置編集修正 房 end
      let treatments = complaints.flatMap(e => e.treatmentList);

      // 登録済の処置者を取得.
      const selectedUsers = treatments.filter(treatment => {
        return treatment.treatStaff && treatment.treatStaff.cd;
      }).map(treatment => {
        return treatment.treatStaff.cd;
      });
      // 利用者マスタ
      await this.getPersonalUserAll(selectedUsers);
      // 職種マスタ(mstJobListでデータを取得後、getMstJobListから参照)
      await this.mstJobList(this.getFacilityCd);

      // 処置者を取得したらダミーの愁訴処置データ行を間引く
      this.actualModel.occurDate = complaints[0]?.occurDate || treatments[0]?.occurDate || treatments[0]?.treatStaff.occurDate;
      complaints = complaints.filter(
        e => !e.isDummy
      );
      // 間引いた愁訴データから処置データを取得
      treatments = complaints.flatMap(e => e.treatmentList);
      this.actualModel.items = [
        ...Array(Math.max(complaints.length, treatments.length))
      ]
        .map((_, i) => {
          return new ComplaintEdit(
            i < complaints.length ? complaints[i] : null,
            i < treatments.length ? treatments[i] : null,
            false,
            false
            // i < complaints.length ? complaints[i].isDummy : false,
          );
        })
        .concat(new ComplaintEdit(null, null, true));
      this.comparisonModel = JSON.parse(JSON.stringify(this.actualModel));
    },
    /**
     * 利用者情報取得
     *
     * @param {Array} selectedUsers 選択済の利用者IDの配列
     */
    async getPersonalUserAll(selectedUsers) {
      const latestPersonalUserResponse = await this.fetchPersonalUserAll();
      this.mstUsers = latestPersonalUserResponse.data;
      this.mstUsers.forEach(user => {
        user.selected = selectedUsers.includes(user.userId);
      });
      this.actualModel.treatStaff = JSON.parse(JSON.stringify(this.mstUsers));
    },
    setContentDataCps(newValue, index) {
      this.actualModel.items[index].complaint.name = newValue;
      // 入力文字が全て消された場合
      // 内部で保持しているコードをクリア
      //del #9321 患者経過総合ビューアの長期間表示で、治療記録集計と愁訴処置がデータ表示しない。 zy start
      // if (!newValue || !newValue.trim()) {
      //   this.actualModel.items[index].complaint.cd = null;
      //   return;
      // }
      //del #9321 患者経過総合ビューアの長期間表示で、治療記録集計と愁訴処置がデータ表示しない。 zy end
    },
    setContentDataTms(newValue, index) {
      this.actualModel.items[index].treatment.name = newValue;
      // 入力文字が全て消された場合
      // 内部で保持しているコードをクリア
      //del #9321 患者経過総合ビューアの長期間表示で、治療記録集計と愁訴処置がデータ表示しない。 zy start
      // if (!newValue || !newValue.trim()) {
      //   this.actualModel.items[index].treatment.cd = null;
      //   return;
      // }
      //del #9321 患者経過総合ビューアの長期間表示で、治療記録集計と愁訴処置がデータ表示しない。 zy end
    },
    // 処置者抽出のトリガ処理
    doStaffSearch() {
      this.strToStaffSearch.inUsed = this.strToStaffSearch.inProgress;
      this.selectedJobCd.inUsed = this.selectedJobCd.inProgress;
    },
    /**
     * 抽出条件に入力されている文字列が含まれているか否か、選択された職種に該当するかを複合判断する.
     * 対象は処置者名とする.
     *
     * @param {*} staff 処置者の1行データ
     * @returns {Boolean} 処置者名に検索対象文字列が含まれ、且つ選択職種に該当する場合、trueを返す.
     */
    hasMatchedStaffName(staff) {
      // 職種でフィルタリング
      if (this.selectedJobCd.inUsed !== "") {
        const staffJobCd = parseInt(staff.jobCd);
        const selectJobCd = parseInt(this.selectedJobCd.inUsed);
        if (Number.isNaN(staffJobCd) || staffJobCd !== selectJobCd) {
          return false;
        }
      }
      if (!this.strToStaffSearch.inUsed) return true;
      // 処置者名でフィルタリング
      const userNameComp = staff.userName ? staff.userName.includes(this.strToStaffSearch.inUsed) : false;
      return userNameComp;
    },
    // add 5519 愁訴処置で処置がないのに処置薬剤の保存操作が出来てしまう 房 start
    medicineClear(index){
      if (!this.actualModel.items[index].treatment.name) {
        this.actualModel.items[index].treatMedicine= new MasterAndNumber();
        this.actualModel.items[index].treatMedicineUnit = "";
        this.actualModel.items[index].procedure = new Master();
      }
    },
    // add 5519 愁訴処置で処置がないのに処置薬剤の保存操作が出来てしまう 房 end
    /**
     * 愁訴処置登録画面で確定した愁訴処置を編集画面に反映する.
     *
     * @param {Array} complaints 愁訴処置データの配列
     */
    onApplayCompTreatCreateModal(complaints) {
      if (!Array.isArray(complaints)) {
        return;
      }
      const treatments = complaints.flatMap(e => e.treatmentList);
      const addItems = [
          ...Array(Math.max(complaints.length, treatments.length))
        ]
        .map((_, i) => {
          return new ComplaintEdit(
            i < complaints.length ? complaints[i] : null,
            i < treatments.length ? treatments[i] : null
          );
        });
      // 新規行を追加するか否か
      const addNewRow =
        this.editIndex === (this.actualModel.items.length - 1) ? true : false;
      // 登録画面で入力された愁訴処置を追加
      if (addItems.length > 0) {
        this.actualModel.items.splice(this.editIndex, 1, ...addItems);
        // 最終行(新規行)で追加された場合、新規行を追加
        // ※登録画面で入力された愁訴処置情報で上書する為、ここで新規行を追加する必要がある.
        if (addNewRow) {
          this.actualModel.items.push(new ComplaintEdit(null, null, true));
        }
      }
    }
  },
  computed: {
    ...mapGetters("account-edit", ["getTheme"]),
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("mst-user", ["getMstJobList"]),
    /**
     * 編集中フラグ.
     */
    isChanged() {
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231214 ztc start
      const compareInitData = JSON.parse(JSON.stringify(this.comparisonModel));
      const compareCurData = JSON.parse(JSON.stringify(this.actualModel));
      compareInitData.items && compareInitData.items.forEach(item => {
        delete item.treatStaff;
      });
      compareCurData.items && compareCurData.items.forEach(item => {
        delete item.treatStaff;
      });
      return JSON.stringify(compareInitData) !== JSON.stringify(compareCurData);
      // return this.comparisonModel !== JSON.stringify(this.actualModel);
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231214 ztc end
    },

    themeBlack() {
      return this.getTheme === 1 ? "ntss-list-body-tr-black" : "";
    }
  },
  created() {
    this.$nextTick(() => {
      this.init();
    });
    // 登録画面で確定ボタン押下された時にイベント
    EventBus.$off("applayCompTreatCreateModal", this.onApplayCompTreatCreateModal);
    EventBus.$on("applayCompTreatCreateModal", this.onApplayCompTreatCreateModal);
  },
  /**
   * 愁訴処置モーダル画面破棄時
   */
  beforeUnmount() {
    EventBus.$off("applayCompTreatCreateModal", this.onApplayCompTreatCreateModal);
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  }
};
</script>

<style lang="scss" scoped>
ons-checkbox.checkbox {
  margin-top: 0;
}
@import "../../../../../assets/styles/modal.css";
.ntss-list-header-th-sticky {
  z-index: 1;
}
.compliant-edit-list {
  height: inherit;
  display: flex;
}
.compliant-edit-list :deep(ons-col) {
  display: flex;
  align-items: center;
}
.compliant-edit-dummy-space {
  height: 3em;
}
/* ntss.css に記載されている動作により、不要な padding が日時部品に発生する為の調整 */
@media only screen and (max-width: 576px) {
  .compliant-edit-dummy-space {
    height: 1em;
  }
}
.ntss-style-date-time :deep(.date-time) {
  padding: unset;
}
.ntss-style-date-time :deep(.title) {
  min-width: unset;
}
.scroll-table {
  height: 100%;
}
.ntss-list {
  position: inherit;
}
.treatment-record-modal {
  margin: 0 4px;
  min-width: 57em;
  height: 100%;
}
.treatment-record-modal :deep(ons-col.title) {
  flex: 0 0 6em;
}
.treatment-record-modal :deep(ons-col.unit) {
  flex: 0 0 3em;
}
.delete-checkbox-col {
  text-align: center;
}
td.delete-checkbox-col {
  vertical-align: middle;
}
.ntss-list-body-td {
  vertical-align: top;
}
div :deep(.com-textarea) {
  width: 98%;
  height: 4.5em;
  box-sizing: border-box;
}
div :deep(textarea) {
  resize: both;
  width: 96%;
  height: 100%;
  font-size: 1em;
  font-family: inherit;
}
.selector-td {
  padding: 2px 4px;
  vertical-align: middle;
}
.selector-td :deep(ons-row) {
  height: inherit;
}
.selector-td :deep(label),
.selector-td :deep(.select-btn) {
  font-size: 1em;
}

.selector-td :deep(.text-input) {
  font-size: 1em;
}
.complaint-td,
.treatment-td {
  padding: 4px;
}
.selector-td :deep(ons-input) {
  width: 100%;
}
.selector-td :deep(ons-col.num-value) {
  flex: 0 0 3em;
}
.selector-td :deep(ons-col.unit) {
  padding-left: 4px;
}
.selector-td :deep(ons-col.select-button) {
  flex: 0 0 3em;
  align-items: center;
}
.treat-medicine-selector :deep(ons-col.title) {
  flex: 1;
}
.procedure-selector :deep(ons-col.title),
.treat-staff-selector :deep(ons-col.title) {
  display: none;
}
.edit-button {
  width: 3.5em;
}
/* TODO モーダルのブラックテーマ適用時に以下のスタイルを全て削除する */
.ntss-list {
  background-color: #fafafa;
}
.ntss-list-header-th-sticky {
  background-color: #333333;
  border: solid 1px #cccccc;
  border-top: none;
}
.ntss-list-body-tr {
  border: solid 1px #cccccc;
  color: var(--ntss-base-color);
  background-color:var(--ntss-list-item-background-color);
  &.new-row{
    background-color: #ccffcc !important;
  }
}
.ntss-list-body-td {
  border: solid 1px #cccccc;
}
.treatment-record-modal :deep(.comp-treat-button) {
  width: 3.0em;
  height: 2.0em;
  margin: 5px 0px;
}

.ntss-list-body-tr-black {
  background-color: var(--ntss-base-background-color);
  color: #fafafa;
}

div :deep(.modal-container),
div :deep(.modal-search),
div :deep(.modal-body),
div :deep(.modal-footer),
div :deep(.modal-footer .bottom-bar) {
  background-color: var(--ntss-base-background-color);
  color: var(--ntss-base-color);
}
.procedure-selector :deep(ons-col.text-value) {
  color: var(--ntss-base-color);
}

.procedure-selector :deep(.custom-div-show-selected-item) {
  border: none !important;
  border-radius: 0 !important;
  border-style: none !important;
  background-color: transparent !important;
  padding: 0 !important;
  min-height: auto !important;
  color: inherit;
  flex: 1 1 auto;
}

.procedure-selector :deep(.custom-div-show-selected-item-edited) {
  border: none !important;
  outline: 0 !important;
}

.procedure-selector :deep(ons-col) {
  align-items: center;
}

.procedure-selector :deep(.common-style-select-button) {
  margin-left: auto;
  width: 5em;
  min-width: 5em;
  padding-left: 0;
  padding-right: 0;
}

.treat-medicine-selector :deep(.common-style-select-button.com-basic-sub-btn) {
  width: 5em;
  min-width: 5em;
  padding-left: 0;
  padding-right: 0;
}
/* モバイル縦画面にてフッター部のボタンが収まりきらないので幅を調整 */
@media only screen and (max-width: 480px) {
  .flex-container .denial-btn-area {
    margin-left: unset;
  }
  .flex-container .registration-btn-area {
    margin-right: unset;
  }
  .flex-container .denial-btn-area .btn2-cancel {
    padding-left: 0.5em;
    padding-right: 0.5em;
  }
  .flex-container .denial-btn-area .btn4-alert,
  .flex-container .registration-btn-area .btn1-execute {
    min-width: 4.3em;
  }
}
@media print {
  .modal-mask {
    text-align: center;
    
  }
  .modal-mask :deep(.modal-wrapper) {
    display: inline-block !important;
    text-align: left;
  }
  .modal-mask :deep(.modal-container) {
    width: 98% !important;
  }
  #new-comp-treat-staff-area {
    width: 18% !important;
    min-width: 10em !important;
  }
}
</style>
