<template>
  <modal-base @onClose="onClickClose">
    <div slot="body" class="main-content">
      <div class="treatment-record-accordion treatment-record-modal height-def">
        <div id="comp-and-treat-tbl-wrapper">
          <div
            style="height: 100%;"
            :style="isNew ? 'width: 85%;' : 'width: 100%;'">
            <!-- 日時 -->
            <div>
              <com-date-time-input
               :is-show-clear="true"
                class="ntss-style-date-time"
                labelName="日時"
                :required="true"
                v-model="occurDateTime"
                :disabled="isDisabled"
                @handleCurrentDateChange="handleCurrentDateChange"
                @handleCurrentTimeChange="handleCurrentTimeChange"
                :row-height="'2.25em'"/>
            </div>
            <!-- 検索エリア -->
            <div style="display: flex; height: 2.25em; align-items: center;">
              <div id="str-to-search" style="flex: 1; margin-right: 0.5em;">
                <v-ons-input v-model="strToSearch.inProgress" type="text" @keydown.enter="doSearch"></v-ons-input>
              </div>
              <div id="select-exec">
                <v-ons-button class="button registration-btn btn3-normal" @click="doSearch">検索</v-ons-button>
              </div>
            </div>
            <!-- テーブルエリア -->
            <div class="scroll-table">
              <table class="ntss-list">
                <thead>
                  <tr>
                    <th class="ntss-list-header-th-sticky page-index-col"></th>
                    <th class="ntss-list-header-th-sticky" style="width: 50%; min-width: 13em;">愁訴</th>
                    <th class="ntss-list-header-th-sticky" style="width: 50%; min-width: 16em;" colspan="2">処置</th>
                  </tr>
                </thead>
                <tbody :class="themeBlack">
                  <template v-for="(data, index) in compAndTreat">
                    <tr class="ntss-list-body-tr" :key="index + '-1'">
                      <td
                        style="width: 1em"
                        class="ntss-list-body-td border-per-page-bottom"
                        :rowspan="perPage"
                        v-if="index % perPage === 0"
                        v-show="isVisiblePage(compAndTreat, index, hasMatchedName)"
                      >{{ getOnPage(index) }}</td>

                      <!-- 愁訴 -->
                      <td
                        v-show="isVisibleItem(compAndTreat, index, hasMatchedName)"
                        style="width: 18em"
                        class="ntss-list-body-td border-per-page-right"
                        :class="isLastRowPerPage(compAndTreat, index, hasMatchedName) ? 'border-per-page-bottom' : ''"
                      >
                        <div v-if="data.complaint !== null" style="display: flex; align-items: center;">
                          <div>
                            <v-ons-checkbox
                              :input-id="'complaint-' + index"
                              v-model="data.complaintSelected"
                            ></v-ons-checkbox>
                          </div>
                          <div>
                            <label
                              :for="'complaint-' + index"
                              class="label-text">{{ data.complaint.name }}</label>
                          </div>
                        </div>
                      </td>

                      <!-- 処置 -->
                      <td
                        v-show="isVisibleItem(compAndTreat, index, hasMatchedName)"
                        style="width: 18em"
                        class="ntss-list-body-td treat-name"
                        :class="isLastRowPerPage(compAndTreat, index, hasMatchedName) ? 'border-per-page-bottom' : ''"
                        :colspan="1"
                      >
                        <div v-if="data.compTreatment !== null" style="display: flex; align-items: center;">
                          <div>
                            <v-ons-checkbox
                              :input-id="'treatment-' + index"
                              v-model="data.compTreatmentSelected"
                            ></v-ons-checkbox>
                          </div>
                          <div>
                            <label
                              :for="'treatment-' + index"
                              class="label-text">{{ data.compTreatment.name }}</label>
                          </div>
                        </div>
                      </td>
                      <td
                        v-show="isVisibleItem(compAndTreat, index, hasMatchedName)"
                        class="complaint-list-body-td medicine-bottle"
                        :class="isLastRowPerPage(compAndTreat, index, hasMatchedName) ? 'border-per-page-bottom' : ''">
                        <img
                          v-if="data.compTreatment !== null && data.compTreatment.treatMedicine.cd !== null && !checkExistContraindications(data.compTreatment.treatMedicine.name)"
                          src="img/treatment-record/medicine-bottle.png"
                          style="cursor: pointer"
                          width="24"
                          height="24"
                          @click="showMedicine(data.compTreatment, arguments[0])"
                        />
                        <img
                          v-if="data.compTreatment !== null && data.compTreatment.treatMedicine.cd !== null && checkExistContraindications(data.compTreatment.treatMedicine.name)"
                          src="img/treatment-record/medicine-bottle-red.png"
                          style="cursor: pointer"
                          width="24"
                          height="24"
                          @click="showMedicine(data.compTreatment, arguments[0])"
                        />
                      </td>
                    </tr>
                  </template>
                </tbody>
              </table>
            </div>
          </div>
          <div
            v-if="isNew"
            style="width: 15%; min-width: 13em; margin-left:10px;"
            id="new-comp-treat-staff-area">
            <!-- 処置者検索欄 -->
            <div style="height: 4.5em; display: flex; flex-direction: column; justify-content: space-around;">
              <div>
                <v-ons-select v-model="selectedJobCd.inProgress" @change="doStaffSearch" style="width: 100%;">
                  <option v-for="job in getMstJobList" :key="job.length" :value="job.jobCd">
                    {{ job.jobName }}
                  </option>
                </v-ons-select>
              </div>
              <div style="display: flex;">
                <div>
                  <v-ons-input type="text" v-model="strToStaffSearch.inProgress" @keydown.enter="doStaffSearch"></v-ons-input>
                </div>
                <div style="margin-left: 0.5em; margin-right: 1px;">
                  <v-ons-button class="btn3-normal" @click="doStaffSearch">抽出</v-ons-button>
                </div>
              </div>
            </div>
            <!-- 処置者リスト -->
            <div class="scroll-table" id="new-comp-treat-staff-area-list">
              <table class="ntss-list">
                <thead>
                  <tr id="new-comp-treat-staff-header">
                    <th class="ntss-list-header-th-sticky">処置者</th>
                  </tr>
                </thead>
                <tbody :class="themeBlack">
                  <template v-for="(item, index) in mstUsers">
                    <tr :key="index + '-1'" class="ntss-list-body-tr" :id="'comp-treat-staff-' + item.userId" v-if="hasMatchedStaffName(item)">
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
                              class="label-text"
                              style="word-break: break-all;" >{{ `${item.userLastName} ${item.userFirstName}` }}</label>
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
        <div id="comp-and-treat-selector-wrapper">
          <table class="ntss-list">
            <thead>
              <tr>
                <th class="ntss-list-header-th-sticky" style="width: 25%; min-width: 12em;">
                  <div style="display: flex; justify-content: space-between; align-items: center;">
                    <label>愁訴</label>
                    <v-ons-button class="edit-button btn3-normal" @click="onSelectComplaintClick">選択</v-ons-button>
                  </div>
                </th>
                <th class="ntss-list-header-th-sticky" style="width: 25%; min-width: 12em;">
                  <div style="display: flex; justify-content: space-between; align-items: center;">
                    <label>処置</label>
                    <v-ons-button class="edit-button btn3-normal" @click="onSelectCompTreatmentClick">選択</v-ons-button>
                  </div>
                </th>
                <th class="ntss-list-header-th-sticky" style="min-width: 15em;">処置薬剤／手技</th>
              </tr>
            </thead>
            <tbody :class="themeBlack">
              <tr class="ntss-list-body-tr">
                <td class="ntss-list-body-td complaint-td" rowspan="2">
                  <com-textarea
                    :content="complaintSelector.model.name"
                    idTextarea="com-textarea-cps"
                    cssClass="com-textarea textarea-resize-vertical"
                    rows="4"
                    @set-content-data="setContentDataCps"
                  ></com-textarea>
                </td>
                <!-- mod 5519 愁訴処置で処置がないのに処置薬剤の保存操作が出来てしまう 房 start -->
                <td class="ntss-list-body-td complaint-td" rowspan="2">
                  <com-textarea
                    :content="compTreatmentSelector.model.name"
                    idTextarea="com-textarea-tms"
                    cssClass="com-textarea textarea-resize-vertical"
                    rows="4"
                    @set-content-data="setContentDataTms"
                    @change="medicineClear()"
                  ></com-textarea>
                </td>
                <!-- mod 7359 処置薬剤の上限が、追加画面と編集画面で異なる。 房 start -->
                <td class="ntss-list-body-td selector-td">
                  <!-- mod #11380 愁訴処置にて登録される薬剤の判別子が間違って登録される 房 start -->
                  <com-master-number-input
                    class="treat-medicine-selector"
                    :unitName="selectedTreatMedicine.unit"
                    :step="selectedTreatMedicine.step"
                    :inputMin="0"
                    :inputMax="99999"
                    :readMasterData="fetchMedicineAll"
                    :masterDefine="treatMedicineMasterDef"
                    :type-no="1"
                    v-model="selectedTreatMedicine.model"
                    @changeUnit="(unit) => selectedTreatMedicine.unit = unit"
                    @changeStep="(step) => selectedTreatMedicine.step = step"
                    @change="(value) => selectedTreatMedicine.model.value = value"
                    @changeMedicineType="medicineObj => {selectedTreatMedicine.medicineType = medicineObj.medicineType;
                    selectedTreatMedicine.treatClass = medicineObj.treatClass;}"
                    @input="handleInputTreatMedicine"
                    :disabled="(compTreatmentSelector.model.cd || compTreatmentSelector.model.name) ? false : true"
                    :required="true"
                  />
                  <!-- mod #11380 愁訴処置にて登録される薬剤の判別子が間違って登録される 房 end -->
                </td>
                <!-- mod 7359 処置薬剤の上限が、追加画面と編集画面で異なる。 房 end -->
              </tr>
              <tr class="ntss-list-body-tr">
                <td class="ntss-list-body-td selector-td">
                  <com-master-selector
                    class="procedure-selector"
                    :showClassFilter="false"
                    :readMasterData="fetchProcedureAll"
                    :masterDefine="procedureMasterDef"
                    v-model="selectedTreatProcedureModel"
                    :isDisabled="(compTreatmentSelector.model.cd || compTreatmentSelector.model.name) ? false : true"
                  />
                </td>
              </tr>
              <!-- mod 5519 愁訴処置で処置がないのに処置薬剤の保存操作が出来てしまう 房 end -->
            </tbody>
          </table>
        </div>
      </div>
      <complaint-selector
        :popoverVisible="complaintSelector.visible"
        :popoverTarget="complaintSelector.target"
        @popover-close="onCloseSelectComplaint"
      />
      <treatment-selector
        :popoverVisible="compTreatmentSelector.visible"
        :popoverTarget="compTreatmentSelector.target"
        @popover-close="onCloseSelectCompTreatment"
      />
      <!-- 薬剤瓶アイコンクリック時のポップオーバー -->
      <treatment-medicine
        :popoverVisible="compTreatmentMedicine.visible"
        :popoverTarget="compTreatmentMedicine.target"
        :popoverTreatment="compTreatmentMedicine.treatMedicine"
        @popover-close="onCloseMedicinePopover"
      />
    </div>
    <div slot="footer" class="flex-container">
      <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 start -->
      <div class="denial-btn-area" style="background:none">
        <v-ons-button class="button denial-btn btn2-cancel" @click="onClickClose">キャンセル</v-ons-button>
      </div>
      <div class="registration-btn-area" style="background:none">
        <v-ons-button class="button registration-btn btn1-execute" :disabled="isEmptyInput" @click="onClickReflect">
          {{ getSaveButtonLabel() }}
        </v-ons-button>
      </div>
      <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 end -->
    </div>
  </modal-base>
</template>

<script>
import { mapActions, mapGetters } from "vuex";
import SubModalBase from "@/components/modals/SubModalBase";
import MultiSubModalMixin from "@/components/modals/MultiSubModalMixin";
import CommonDateTimeComponent from "@/components/treatment-record/submenu/common/CommonDateTimeComponent";
import CommonMasterSelectorComponent from "@/components/common/master-selector/CommonMasterSelectorComponent";
import CommonMasterAndNumberInputComponent from "@/components/treatment-record/submenu/common/CommonMasterAndNumberInputComponent";
import {
  treatMedicine,
  treatUser,
  procedure
} from "@/components/common/master-selector/MasterSelectorDefinitions";
import { Master } from "@/models/common/master-selector-condition/Master";
import { MasterAndNumber } from "@/models/common/MasterAndNumber";
import { MstComplaint } from "@/models/treatment-record/complaint/MstComplaint";
import { MstCompTreatment } from "@/models/treatment-record/complaint/MstCompTreatment";
import { Complaint } from "@/models/treatment-record/complaint/Complaint";
import { Treatment } from "@/models/treatment-record/complaint/Treatment";
import { TreatmentStaff } from "@/models/treatment-record/complaint/TreatmentStaff";
import ComplaintComponentMixin from "@/components/treatment-record/submenu/complaint/ComplaintComponentMixin";
import ComplaintSelectorComponent from "@/components/treatment-record/submenu/complaint/ComplaintSelectorComponent";
import TreatmentSelectorComponent from "@/components/treatment-record/submenu/complaint/TreatmentSelectorComponent";
import DiscardConfirmationMixin from "@/components/treatment-record/DiscardConfirmationMixin";
import moment from "moment";
import BigNumber from "bignumber.js";
import { CODES } from "@/constants/TreatmentRecord";
import TreatmentMedicineComponent from "@/components/treatment-record/submenu/complaint/TreatmentMedicineComponent";
import { EventBus } from "@/eventBus.js";
import CommonTextArea from "@/components/common/CommonTextArea";
// add FNSI-日付書式の修正 徐 start
import { dateFormat, DATE_TIME_FORMAT } from "@/functions/common/DateTimeUtils";
// add FNSI-日付書式の修正 徐 end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
export default {
  mixins: [DiscardConfirmationMixin, MultiSubModalMixin, ComplaintComponentMixin],
  components: {
    "modal-base": SubModalBase,
    "com-date-time-input": CommonDateTimeComponent,
    "com-master-selector": CommonMasterSelectorComponent,
    "com-master-number-input": CommonMasterAndNumberInputComponent,
    "complaint-selector": ComplaintSelectorComponent,
    "treatment-selector": TreatmentSelectorComponent,
    "treatment-medicine": TreatmentMedicineComponent,
    "com-textarea": CommonTextArea
  },
  data() {
    return {
      occurDateTime: undefined,
      occurDateTimeInit: undefined,
      compAndTreat: [],
      // 検索入力にバインドする文字列。愁訴・処置・薬剤の名称を対象に検索する
      strToSearch: {
        inProgress: "", // 入力中の文字列にバインドする。「検索」ボタン押下時にinUsedへコピーされる。
        inUsed: "" // 実際に検索に使われる文字列
      },
      treatUserMasterDef: treatUser,
      treatMedicineMasterDef: treatMedicine,
      procedureMasterDef: procedure,
      defaultUserModel: new Master(this.getUserId(), this.getUserName()),
      selectedTreatMedicine: {
        unit: "",
        model: new MasterAndNumber(),
        // add #11380 愁訴処置にて登録される薬剤の判別子が間違って登録される 房 start
        medicineType: undefined
        // add #11380 愁訴処置にて登録される薬剤の判別子が間違って登録される 房 end
      },
      selectedTreatProcedureModel: new Master(),
      selectedTreatUser: {
        title: "処置者",
        model: new Master()
      },
      complaintSelector: {
        model: new MstComplaint(),
        visible: false,
        target: null
      },
      compTreatmentSelector: {
        model: new MstCompTreatment(),
        visible: false,
        target: null,
        // add #11380 愁訴処置にて登録される薬剤の判別子が間違って登録される 房 start
        medicineType: undefined
        // add #11380 愁訴処置にて登録される薬剤の判別子が間違って登録される 房 end
      },
      /**
       * 薬剤瓶アイコンをクリックした時のポップアップに渡すための情報
       * visible : 表示／非表示
       * target : イベント
       * treatMedicine : 薬剤情報
       *    treatMedicine : 薬剤名称
       *    amount : 数量
       *    unit : 単位名称
       *    procedure : 手技名称
       */
      compTreatmentMedicine: {
        visible: false,
        target: null,
        treatMedicine: {},
      },
      /**
       * 利用者マスタ
       */
      mstUsers: [],
      /**
       * 新規登録フラグ
       * true:新規登録
       * false:編集(編集モーダルからの起動)
       */
      isNew: true,
      /**
       * 編集モーダルから呼びだされた時点の愁訴処置情報
       */
      comparisonModel: {
        // 愁訴処置薬剤
        treatmentMedicine: null,
        // 愁訴
        complaint: null,
        // 処置
        compTreatment: null,
        // 手技
        procedure: null,
      },
      //add FNSI修正内容 愁訴処置の登録および表示修正 房 start
      tempCtlNo: 0,
      //add FNSI修正内容 愁訴処置の登録および表示修正 房 end
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
      currentDateChange: 'date'
      // 内部 日付没入,データ登録できました end
    };
  },
  computed: {
    // 呼出元からのパラメータ取得
    ...mapGetters("multi-sub-modal", ["getInitValues"]),
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("mst-user", ["getMstJobList"]),
    ...mapGetters("account-edit", ["getTheme"]),
    //add FNSI修正内容 愁訴処置の登録および表示修正 房 start
    ...mapGetters("treatment-record/complaint", ["getTempCtlNo"]),
    //add FNSI修正内容 愁訴処置の登録および表示修正 房 end
    //add FNSI-6492 ljx start
    ...mapGetters("treatment-record/common", ["getDialysisState"]),
    //add FNSI-6492 ljx end
    isChanged() {
      // 編集から起動された場合
      if (!this.isNew) {
        return (
          this.comparisonModel.treatmentMedicine !== JSON.stringify(this.selectedTreatMedicine) ||
          this.comparisonModel.complaint !== JSON.stringify(this.complaintSelector.model) ||
          this.comparisonModel.compTreatment !== JSON.stringify(this.compTreatmentSelector.model) ||
          this.comparisonModel.procedure !== JSON.stringify(this.selectedTreatProcedureModel) ||
          this.compAndTreat.some(
            cat => cat.complaintSelected || cat.compTreatmentSelected
          )
        );
      }
      return (
        // add FNSI-日付書式の修正 徐 start
        // this.occurDateTime !== this.occurDateTimeInit ||
        dateFormat.format(new Date(this.occurDateTime), DATE_TIME_FORMAT) !== dateFormat.format(new Date(this.occurDateTimeInit), DATE_TIME_FORMAT) ||
        // add FNSI-日付書式の修正 徐 end
        this.selectedTreatUser.model !== this.defaultUserModel ||
        !this.selectedTreatProcedureModel.isEmpty() ||
        !this.selectedTreatMedicine.model.isEmpty() ||
        this.compAndTreat.some(
          cat => cat.complaintSelected || cat.compTreatmentSelected
        ) ||
        !this.complaintSelector.model.isEmpty() ||
        !this.compTreatmentSelector.model.isEmpty()
      );
    },
    isEmptyInput() {
      if (!this.isNew) {
        return !(
          (
            // 処置
            this.comparisonModel.complaint !== JSON.stringify(this.complaintSelector.model) ||
            // 処置
            this.comparisonModel.compTreatment !== JSON.stringify(this.compTreatmentSelector.model) ||
            // 処置薬剤、手技
            // 処置欄が入力されている場合でかつ、処置薬剤、手技が表示した時の内容と異なる場合のみtrueとする.
            (!this.compTreatmentSelector.model.isEmpty() &&
              (this.comparisonModel.procedure !== JSON.stringify(this.selectedTreatProcedureModel) ||
              this.comparisonModel.treatmentMedicine !== JSON.stringify(this.selectedTreatMedicine))
            ) ||
            // 愁訴、処置の選択
            this.compAndTreat.some(
              cat => cat.complaintSelected || cat.compTreatmentSelected
            )
          )
        );
      }
      // add FNSI-日付書式の修正 徐 start
      // return (
      //   !this.compAndTreat.some(
      //     cat => cat.complaintSelected || cat.compTreatmentSelected
      //   ) &&
      //   this.complaintSelector.model.isEmpty() &&
      //   this.compTreatmentSelector.model.isEmpty()
      // );
      return !(
        dateFormat.format(new Date(this.occurDateTime), DATE_TIME_FORMAT) !== dateFormat.format(new Date(this.occurDateTimeInit), DATE_TIME_FORMAT) ||
        this.selectedTreatUser.model !== this.defaultUserModel ||
        !this.selectedTreatProcedureModel.isEmpty() ||
        !this.selectedTreatMedicine.model.isEmpty() ||
        this.compAndTreat.some(
          cat => cat.complaintSelected || cat.compTreatmentSelected
        ) ||
        !this.complaintSelector.model.isEmpty() ||
        !this.compTreatmentSelector.model.isEmpty()
      );
      // add FNSI-日付書式の修正 徐 end
    },
    /**
     * 非活性有無
     */
    isDisabled() {
      return !this.isNew;
    },
    themeBlack() {
      return this.getTheme === 1 ? "ntss-list-body-tr-black" : "";
    }
  },
  methods: {
    handleInputTreatMedicine (master) {
      if (!master.cd) {
        this.selectedTreatMedicine.model = new MasterAndNumber();
        this.selectedTreatMedicine.unit = "";
        // add #11380 愁訴処置にて登録される薬剤の判別子が間違って登録される 房 start
        this.selectedTreatMedicine.medicineType = undefined;
        this.selectedTreatMedicine.treatClass = undefined;
        // add #11380 愁訴処置にて登録される薬剤の判別子が間違って登録される 房 end
        this.selectedTreatProcedureModel = new Master();
      }
    },
    handleCurrentDateChange (val) {
      this.currentDateChange = val
    },
    handleCurrentTimeChange (val) {
      this.currentTimeChange = val
    },
    ...mapActions("mst-user", ["mstJobList"]),
    ...mapGetters("account-edit", ["getUserId", "getUserName"]),
    ...mapGetters("treatment-record/complaint", ["getComplaintData", "getEditCompAndTreat", "getEditOccurDate"]),
    ...mapActions("treatment-record/complaint", [
      "getMstComplaint",
      "getMstCompTreatment",
      "setComplaintData"
    ]),
    onClickClose() {
      this.isChanged ? this.discardConfirm(this.hideModal) : this.hideModal();
    },
    async onClickReflect() {
      // データ検証
      if (!this.validateInputData()) {
        return;
      }

      try {
        // 基になるデータ オブジェクトを構築する
        const baseData = {
          occurDate: this.occurDateTime,
          checkFlag: "1",
          isEditable: true,
          isSpecial: false,
          isDummy: false,
          ctlNo: null
        };

        // 選択したディスポーザーのリストを取得します
        const selectedStaffList = this.getSelectedStaffList(baseData);
        // 選択した対話結果の一覧を取得します
        let selectedTreatments = this.getSelectedTreatments(baseData, selectedStaffList);
        // 選択した愁訴のリストを取得する
        let selectedComplaints = this.getSelectedComplaints(baseData);
        // データアライメントの処理
        const { complaints } = this.alignData(selectedComplaints, selectedTreatments, selectedStaffList, baseData);
        // ハンドル編集モード
        if (!this.isNew) {
          EventBus.$emit("applayCompTreatCreateModal", complaints);
          this.hideModal();
          return;
        }

        // データを更新して保存する
        await this.updateAndSave(complaints);

      } catch (error) {
        throw error;
      }
    },
    addCompTreatmentSelector(baseData) {
      let customTreatment = null;
      let customComplaint = null;
      customTreatment = this.createCustomTreatment(baseData);
      customTreatment.setTreatmentStaff(TreatmentStaff.of({
        ctlNo: null,
        occurDate: baseData.occurDate,
        treatStaffCd: null,
      }));
      customComplaint = this.createComplaint(this.complaintSelector.model, baseData);
      customComplaint.treatmentList = [customTreatment];
      return customComplaint;
    },

    /**
     * 入力データの検証
     * @returns {boolean} 結果を確認する
     */
    validateInputData() {
      // 医薬品データの検証
      if (!this.selectedTreatMedicine.model.value && this.selectedTreatMedicine.model.name) {
        this.$ons.notification.alert({
          title: DIALOG_MESSAGES[13000170].title,
          message: messageFormat(DIALOG_MESSAGES[13000170].message)
        });
        return false;
      }

      // 日付と時刻を確認する
      const timeOrDate = (this.currentTimeChange == null || this.currentDateChange == null)
        ? null
        : 'timeOrDate';
      if (!this.validateOccurDate(timeOrDate)) {
        return false;
      }

      return true;
    },

    /**
     * 選択したディスポーザーのリストを取得します
     * @param {Object} baseData 基になるデータ オブジェクト
     * @returns {Array} ディスポーザーのリスト
     */
    getSelectedStaffList(baseData) {
      return this.mstUsers
        .filter(user => user.selected)
        .map(user => TreatmentStaff.of({
          ctlNo: null,
          inputClass: CODES.COMP_TREAT_INPUT_CLASS.CLIENT.cd,
          occurDate: baseData.occurDate,
          treatStaffCd: user.userId,
          treatStaffName: `${user.userLastName} ${user.userFirstName}`,
          copOrderNo: 0,
          isEditable: CODES.IS_EDITABLE.POSSIBLE.cd
        }));
    },

    /**
     * 選択した対話結果の一覧を取得します
     * @param {Object} baseData 基になるデータ オブジェクト
     * @param {Array} staffList ディスポーザーのリスト
     * @returns {Array} 処分リスト
     */
    getSelectedTreatments(baseData, staffList) {
      const treatments = [];

      // 選択した廃棄処理を処理します
      const selectedTreatments = this.compAndTreat
        .filter(cat => cat.compTreatmentSelected)
        .map(cat => this.createTreatment(cat.compTreatment, baseData, null));
      treatments.push(...selectedTreatments);

      // フリーエントリーの処分を処理
      if (this.shouldAddCustomTreatment() && this.isNew) {
        const customTreatment = this.createCustomTreatment(baseData);
        if (customTreatment) {
          treatments.push(customTreatment);
        }
      }

      return treatments;
    },

    /**
     * 選択した愁訴のリストを取得する
     * @param {Object} baseData 基になるデータ オブジェクト
     * @returns {Array} 愁訴のリスト
     */
    getSelectedComplaints(baseData) {
      const complaints = [];

      // 選択した愁訴に対処する
      const selectedComplaints = this.compAndTreat
        .filter(cat => cat.complaintSelected)
        .map(cat => this.createComplaint(cat.complaint, baseData));
      complaints.push(...selectedComplaints);

      // 無料エントリーの愁訴への対処
      if (!this.complaintSelector.model.isEmpty() && this.isNew) {
        const customComplaint = this.createComplaint(this.complaintSelector.model, baseData);
        complaints.push(customComplaint);
      }

      return complaints;
    },

    /**
     * 廃棄オブジェクトの作成
     * @param {Object} treatment ディスポジションデータ
     * @param {Object} baseData 基になるデータ オブジェクト
     * @param {Object} staff ディスポーザーデータ
     * @returns {Object} 廃棄オブジェクト
     */
    createTreatment(treatment, baseData, staff) {
      return Treatment.of({
        ctlNo: null,
        occurDate: baseData.occurDate,
        treatClass: treatment.treatClass,
        treatCd: treatment.cd,
        treatName: treatment.name,
        amount: treatment.amount,
        unit: treatment.treatMedicine?.unit || null,
        procedureCd: treatment.procedure?.cd || null,
        procedureName: treatment.procedure?.name || null,
        treatMedicineCd: treatment.treatMedicine?.cd || null,
        treatMedicineName: treatment.treatMedicine?.name || null,
        medicineType: this.getMedicineType(treatment)
      }, staff);
    },

    /**
     * カスタム廃棄オブジェクトの作成
     * @param {Object} baseData 基になるデータ オブジェクト
     * @returns {Object} 廃棄オブジェクト
     */
    createCustomTreatment(baseData) {
      const model = this.compTreatmentSelector.model;
      const medicine = this.selectedTreatMedicine;
      return Treatment.of({
        ctlNo: null,
        occurDate: baseData.occurDate,
        treatClass: medicine.treatClass === 0 ? 0 : (medicine.treatClass || CODES.TREATMENT_CLASS.TREAT.cd),
        treatCd: model.cd,
        treatName: model.name,
        amount: medicine.model.value,
        decPoint: new BigNumber(medicine.step).dp(),
        unit: medicine.unit,
        procedureCd: this.selectedTreatProcedureModel.cd,
        procedureName: this.selectedTreatProcedureModel.name,
        treatMedicineCd: medicine.model.cd,
        treatMedicineName: medicine.model.name,
        medicineType: medicine.medicineType
      }, null);
    },

    /**
     * 愁訴処理オブジェクトの作成
     * @param {Object} complaint データに関する愁訴
     * @param {Object} baseData 基になるデータ オブジェクト
     * @returns {Object} 愁訴の対象
     */
    createComplaint(complaint, baseData) {
      return Complaint.of({
        ctlNo: null,
        occurDate: baseData.occurDate,
        compCd: complaint.cd,
        complaint: complaint.name,
        ...baseData
      });
    },

    /**
     * データの長さを揃える
     * @param {Array} complaints 愁訴のリスト
     * @param {Array} treatments 処分リスト
     * @param {Array} staffList ディスポーザーのリスト
     * @returns {Object} 整合されたデータ
     */
    alignData(complaints, treatments, staffList, baseData) {
      const maxSize = Math.max(complaints.length, treatments.length, this.isNew ? staffList.length : 0);
      const fillList = (list, factoryMethod, additionalArgs = []) => {
        while (list.length < maxSize) {
          list.push(factoryMethod(...additionalArgs));
        }
      };

      fillList(treatments, Treatment.of, [{ ctlNo: null, occurDate: this.occurDateTime }, null, true]);
      fillList(complaints, Complaint.of, [{ ctlNo: null, occurDate: this.occurDateTime, compCd: null }, false, true]);
      fillList(staffList, TreatmentStaff.of, [{ ctlNo: null, occurDate: this.occurDateTime, treatStaffCd: null }]);
      treatments.forEach((treatment, index) => {
        if (treatment.treat.cd || treatment.treat.name || complaints[index].complaint.cd || complaints[index].complaint.name) {
          treatment.isDummy = false;
          complaints[index].isDummy = false;
        }
        treatment.setTreatmentStaff(staffList[index]);
        complaints[index].treatmentList = [treatment];
      });
      if (!this.isNew && (!this.getEditCompAndTreat().isNewEditFlag || this.shouldAddCustomTreatment())) {
        let currentComplaints = this.addCompTreatmentSelector(baseData);
        complaints.push(currentComplaints);
      }
      return { complaints };
    },

    /**
     * データを更新して保存する
     * @param {Array} complaints 愁訴のリスト
     */
    async updateAndSave(complaints) {
      const complaintData = this.getComplaintData();
      complaints.forEach((complaint, index) => {
        complaint.complaint.rowNo = index + 1;
        complaint.treatmentList[0].rowNo = index + 1;
        complaint.treatmentList[0].treatStaff.rowNo = index + 1;
      });
      this.setComplaintData(
        complaintData.concat(complaints).sort(this.compareComplaintList)
      );
      EventBus.$emit("saveCompTreatCreate", complaints, 'create');
      this.hideModal();
    },

    /**
     * カスタム処理を追加する必要があるかどうかを判断します
     * @returns {boolean} 追加が必要かどうか
     */
    shouldAddCustomTreatment() {
      return (!this.compTreatmentSelector.model.isEmpty() || !this.selectedTreatMedicine.model.isEmpty() || !this.complaintSelector.model.isEmpty());
    },

    /**
     * フラスコの種類を取得します
     * @param {Object} treatment ディスポジションデータ
     * @returns {string} エージェントの種類
     */
    getMedicineType(treatment) {
      if (treatment.treatClass == 0) {
        return CODES.MEDICINE_TYPE.MIX.cd;
      } else if (treatment.treatClass == 1) {
        return CODES.MEDICINE_TYPE.NORMAL.cd;
      }
      return null;
    },
    // 愁訴選択ボタン押下時の処理
    onSelectComplaintClick(ev) {
      this.complaintSelector.target = ev.target;
      this.complaintSelector.visible = true;
    },
    // 愁訴選択ポップオーバーで「OK」押下時の処理
    onCloseSelectComplaint(item) {
      if (item) {
        this.complaintSelector.model = new MstComplaint(item.cd, item.name);
      }
      this.complaintSelector.visible = false;
    },
    // 処置選択ボタン押下時の処理
    onSelectCompTreatmentClick(ev) {
      this.compTreatmentSelector.target = ev.target;
      this.compTreatmentSelector.visible = true;
    },
    // 処置選択ポップオーバーで「OK」押下時の処理
    onCloseSelectCompTreatment(item) {
      // mod #11380 愁訴処置にて登録される薬剤の判別子が間違って登録される 房 start
      if (item && !item.isEmpty()) {
        this.compTreatmentSelector.model = new MstCompTreatment(
          item.cd,
          item.name,
          item.treatClass,
          // FNSI-修正 #5343 xugj add start
          item.treatMedicine.cd,
          item.amount,
          item.procedure.cd
          // FNSI-修正 #5343 xugj add end
        );
        if(item.treatMedicine) {
          this.selectedTreatMedicine.medicineType = item.treatMedicine.medicineType;
          this.selectedTreatMedicine.treatClass = item.treatClass;
          this.selectedTreatMedicine.unit = item.treatMedicine.unit;
          this.selectedTreatMedicine.model.cd = item.treatMedicine.cd;
          this.selectedTreatMedicine.model.name = item.treatMedicine.name;
          this.selectedTreatMedicine.model.value = item.amount;
          this.selectedTreatMedicine.step = Math.pow(10, -item.treatMedicine.decPoint);
        }
        if(item.procedure) {
          this.selectedTreatProcedureModel.cd = item.procedure.cd;
          this.selectedTreatProcedureModel.name = item.procedure.name;
        }
      } else if(item) {
        this.compTreatmentSelector.model = new MstCompTreatment();
        this.compTreatmentSelector.target = null;
        this.compTreatmentSelector.medicineType = undefined;
        this.selectedTreatMedicine.model = new MasterAndNumber();
        this.selectedTreatMedicine.unit = "";
        this.selectedTreatMedicine.medicineType = undefined;
        this.selectedTreatMedicine.treatClass = undefined;
        this.selectedTreatProcedureModel = new Master();
      }
      // mod #11380 愁訴処置にて登録される薬剤の判別子が間違って登録される 房 end
      this.compTreatmentSelector.visible = false;
    },
    // 指定したインデックスが「何ページにあるか」を返す
    getOnPage(index) {
      return Math.floor(index / this.perPage) + 1;
    },
    doSearch() {
      this.strToSearch.inUsed = this.strToSearch.inProgress;
    },
    // 処置者抽出のトリガ処理
    doStaffSearch() {
      this.strToStaffSearch.inUsed = this.strToStaffSearch.inProgress;
      this.selectedJobCd.inUsed = this.selectedJobCd.inProgress;
    },
    /**
     * 絞込条件に入力されている文字列が含まれているか否かを判断する.
     * 対象は愁訴名、処置名、薬剤名とする.
     *
     * @param {*} compAndTreat 愁訴処置の1行データ
     * @returns {Boolean} 愁訴名、処置名、薬剤名のいづれかに検索対象文字列が含まれる場合、trueを返す.
     */
    hasMatchedName(compAndTreat) {
      if (!this.strToSearch.inUsed) return true;
      // 愁訴、処置、処置薬剤のデータを取得.
      const compData = compAndTreat.complaint;
      const treatData = compAndTreat.compTreatment;
      const treatMediData = compAndTreat.compTreatment
        ? compAndTreat.compTreatment.treatMedicine
        : null;
      // 愁訴
      const hasMatchComp = (compData && compData.name)
        ? compData.name.includes(this.strToSearch.inUsed)
        : false;
      // 処置
      const hasMatchTreat = (treatData && treatData.name)
        ? treatData.name.includes(this.strToSearch.inUsed)
        : false;
      // 処置薬剤
      const hasMatchTreatMedi = (treatData && treatMediData && treatMediData.name)
        ? treatMediData.name.includes(this.strToSearch.inUsed)
        : false;
      return hasMatchComp || hasMatchTreat || hasMatchTreatMedi;
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
        if (isNaN(staffJobCd) || staffJobCd !== selectJobCd) {
          return false;
        }
      }
      if (!this.strToStaffSearch.inUsed) return true;
      // 処置者名でフィルタリング
      const userNameComp = staff.userName ? staff.userName.includes(this.strToStaffSearch.inUsed) : false;
      return userNameComp;
    },
    // 一覧を描画するデータに、薬剤の情報を付与
    async extractMedicine() {
      // 最新の薬剤を取得
      // TODO 薬剤セットマスタを考慮してない。必要があれば実装する
      const medicineAndClassResponse = await this.fetchMedicineAll();
      const medicine = medicineAndClassResponse[0].data;

      const mstMedicine = medicine.filter(m => {
        // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
        //return m.medicineType === CODES.MEDICINE_TYPE.NORMAL.cd;
        return m.medicineType == CODES.MEDICINE_TYPE.NORMAL.cd;
        // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
      });
      const mstMedicineMix = medicine.filter(m => {
        // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
        //return m.medicineType === CODES.MEDICINE_TYPE.MIX.cd;
        return m.medicineType == CODES.MEDICINE_TYPE.MIX.cd;
        // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      });

      this.compAndTreat.forEach(cat => {
        if (!cat.compTreatment) return;
        // 薬剤マスタ or 調整薬剤マスタ
        let treatMedicine = null;
        // 処置区分を取得.
        const treatClass = cat.compTreatment.treatClass;
        // console.log("処置区分", treatClass);
        if (treatClass === CODES.TREATMENT_CLASS.MIX.cd) {
          // console.log("調整薬剤マスタから検索します。");
          // 調整薬剤マスタから名称及び単位を取得
          treatMedicine = mstMedicineMix.find(
            medi => medi.medicineCd === cat.compTreatment.treatMedicine.cd
          );
        } else if (treatClass === CODES.TREATMENT_CLASS.NORMAL.cd) {
          // console.log("薬剤マスタから検索します。");
          // 薬剤マスタから名称及び単位を取得
          treatMedicine = mstMedicine.find(
            medi => medi.medicineCd === cat.compTreatment.treatMedicine.cd
          );
        }
        // 薬剤コードに該当する薬剤マスタがある場合
        if (treatMedicine) {
          cat.compTreatment.treatMedicine.name = treatMedicine ? treatMedicine.medicineName : "";
          cat.compTreatment.treatMedicine.unit = treatMedicine ? treatMedicine.unit : "";
          cat.compTreatment.treatMedicine.decPoint = treatMedicine ? treatMedicine.unitDecimalPoint : "";
        }
      });
    },
    // 一覧を描画するデータに、手技の情報を付与
    async extractProcedure() {
      // 最新の手技を取得
      const procedureResponse = await this.fetchProcedureAll();
      const procedure = procedureResponse.data;

      this.compAndTreat.forEach(cat => {
        if (!cat.compTreatment) return;
        const p = procedure.find(
          proc => proc.procedureCd === cat.compTreatment.procedure.cd
        );
        cat.compTreatment.procedure.name = p ? p.pricedureName : "";
      });
    },
    /**
     * 初期処理
     */
    async init() {
      // 新規登録フラグを取得.
      const isNewFlg = this.getInitValues.isNew;
      // 愁訴と処置を取得
      const getComplaintResponse = await this.getMstComplaint();
      const getCompTreatmentResponse = await this.getMstCompTreatment();

      this.tempCtlNo = this.getTempCtlNo;

      // 「表示」のもののみ扱うようにする
      const complaints = getComplaintResponse.data
        .filter(d => d.is_disp === CODES.IS_DISP.DISPLAY.cd)
        .map(d => new MstComplaint(d.complaint_cd, d.complaint_name));
      const compTreatments = getCompTreatmentResponse.data
        .filter(d => d.is_disp === CODES.IS_DISP.DISPLAY.cd)
        .map(
          d =>
            new MstCompTreatment(
              d.comp_treatment_cd,
              d.treatment,
              d.treat_class,
              d.treat_medicine_cd,
              d.amount,
              d.procedure_cd
            )
        );

      // 愁訴と処置のリストを生成
      this.compAndTreat = [
        ...Array(Math.max(complaints.length, compTreatments.length))
      ].map((n, index) => {
        return {
          complaint: index < complaints.length ? complaints[index] : null,
          compTreatment:
            index < compTreatments.length ? compTreatments[index] : null,
          complaintSelected: false,
          compTreatmentSelected: false
        };
      });

      await this.extractMedicine();
      await this.extractProcedure();

      // 透析開始/終了日時を取得
      const occurDates = this.getComplaintData()
        .filter(e => e.isDialysis)
        .map(e => e.occurDate);
      // 透析開始日時が存在したら、透析日＋現在時刻を画面の日時の初期値とする
      if (isNewFlg && occurDates.length >= 1) {
        const now = moment();
        const startDateTime = moment(occurDates[0]);
        // mod FNSI-6492 ljx start
        //透析終了日時(存在しない場合、undefinedとする)
        const endDateTime = occurDates[1]?moment(occurDates[1]):undefined;
        //初期化表示日時
        //rst_dialysis_stateの値が1～5の場合、システム日時
        let occurDateTime= now;
        //DialysisStateが「６」の場合、初期化表示日時は下記の通り
        //透析終了日時→（空白だった場合）→透析開始日時→（空白だった場合）→システム日時
        if(this.getDialysisState && this.getDialysisState == "6"){
          occurDateTime = endDateTime?endDateTime:(startDateTime?startDateTime:now);
        }
        //画面にて表示される日時
        this.occurDateTime = new Date(
          occurDateTime.year(),
          occurDateTime.month(),
          occurDateTime.date(),
          occurDateTime.hour(),
          occurDateTime.minute()
        );
/*        this.occurDateTime = new Date(
          startDateTime.year(),
          startDateTime.month(),
          startDateTime.date(),
          now.hour(),
          now.minute()
        );*/
        // mod FNSI-6492 ljx end
        // add FNSI-日付書式の修正 徐 start
        // this.occurDateTimeInit = this.occurDateTime;
        // add FNSI-日付書式の修正 徐 end
      } else if (isNewFlg && occurDates.length === 0) {
        this.occurDateTime = new Date();
      } else if (!isNewFlg) {
        this.setEditCompTreatment();
      }
      // add FNSI-日付書式の修正 徐 start
      this.occurDateTimeInit = this.occurDateTime;
      // add FNSI-日付書式の修正 徐 end

      // 処置者の初期値にサインイン中ユーザーを設定
      this.selectedTreatUser.model = this.defaultUserModel;
      // 利用者マスタ
      this.getPersonalUserAll();
      // 職種マスタ(mstJobListでデータを取得後、getMstJobListから参照)
      await this.mstJobList(this.getFacilityCd);
    },
    /**
     * 編集時の設定
     */
    async setEditCompTreatment() {
      // 愁訴処置日時
      if (this.getEditOccurDate()) {
        this.occurDateTime = moment(this.getEditOccurDate()).toDate();
      }
      // 編集対象の愁訴処置
      if (this.getEditCompAndTreat()) {
        const complaintEdit = this.getEditCompAndTreat();
        // 登録済の愁訴
        this.complaintSelector.model = complaintEdit.complaint
          ? new MstComplaint(
            complaintEdit.complaint.cd,
            complaintEdit.complaint.name ? complaintEdit.complaint.name : ""
          )
          : null;
        // 登録済の処置
         const mstCompTreatment = complaintEdit.treatment
          ? new MstCompTreatment(
              complaintEdit.treatment.cd,
              complaintEdit.treatment.name,
              complaintEdit.treatment.treatClass ? complaintEdit.treatment.treatClass : CODES.TREATMENT_CLASS.NORMAL.cd,
              complaintEdit.treatment.treatMedicine.cd,
              complaintEdit.treatment.amount,
              complaintEdit.treatment.procedure.cd
            )
          : new MstCompTreatment();
        this.compTreatmentSelector.model = mstCompTreatment;

        // 薬剤設定
        this.selectedTreatMedicine.model = complaintEdit.treatMedicine;
        this.selectedTreatMedicine.unit = complaintEdit.treatMedicineUnit;
        this.selectedTreatMedicine.step = complaintEdit.treatMedicineStep;
        // add #11380 愁訴処置にて登録される薬剤の判別子が間違って登録される 房 start
        this.selectedTreatMedicine.treatClass = complaintEdit.treatClass;
        this.selectedTreatMedicine.medicineType = complaintEdit.medicineType;
        // add #11380 愁訴処置にて登録される薬剤の判別子が間違って登録される 房 end

        // 手技
        this.selectedTreatProcedureModel = complaintEdit.procedure;

        // 変更比較時モデルに設定
        this.comparisonModel.treatmentMedicine = JSON.stringify(this.selectedTreatMedicine);
        this.comparisonModel.complaint = JSON.stringify(this.complaintSelector.model);
        this.comparisonModel.compTreatment = JSON.stringify(this.compTreatmentSelector.model);
        this.comparisonModel.procedure = JSON.stringify(this.selectedTreatProcedureModel);
      }
    },
    /**
     * 利用者マスタ取得
     * TODO:mst_selectorへの切替が必要
     */
    async getPersonalUserAll() {
      const latestPersonalUserResponse = await this.fetchPersonalUserAll();
      this.mstUsers = latestPersonalUserResponse.data;
      // 初期選択ユーザIDを選択状態にする.
      const defaultUserId = this.defaultUserModel ? this.defaultUserModel.cd : null;
      this.mstUsers.forEach(user => {
        user.selected = false;
        if (user.userId === defaultUserId) {
          user.selected = true;
        }
      });
    },
    /**
     * 薬瓶アイコンのクリックイントハンドラ.
     */
    showMedicine(compTreatment, event) {
      // console.log("薬剤瓶アイコンがクリックされた", compTreatment);
      let setAmount = null;
      let numbers = String(compTreatment.amount).split('.');
      let decPoint = (numbers[1]) ? numbers[1].length : 0;
      if(decPoint > compTreatment.treatMedicine.decPoint){
        setAmount = BigNumber(1 * compTreatment.amount).toFixed();
      }else{
        setAmount = BigNumber(1 * compTreatment.amount).toFixed(compTreatment.treatMedicine.decPoint);
      }

      const treatMedicine = {
        treatMedicine: compTreatment.treatMedicine.name,
        amount: setAmount,
        unit: compTreatment.treatMedicine.unit,
        procedure: compTreatment.procedure.name
      };
      this.compTreatmentMedicine.visible = true;
      this.compTreatmentMedicine.target = event.target;
      this.compTreatmentMedicine.treatMedicine = treatMedicine;
    },
    /**
     * ポップオーバクローズ処理
     */
    onCloseMedicinePopover() {
      this.compTreatmentMedicine.visible = false;
      this.compTreatmentMedicine.target = null;
      this.compTreatmentMedicine.treatMedicine = {};
    },
    /**
     * 画面に表示するボタン名を取得する.
     * isNewプロパティ値に下記の文字列を返却する.
     *  true の場合："保存"
     *  false の場合："確定"
     *
     * @returns {String} ボタン名
     */
    getSaveButtonLabel() {
      return this.isNew ? "保存" : "確定";
    },

    // check condition change image icon bottle
    checkExistContraindications(treatMedicineName) {
      return (
        treatMedicineName &&
        (treatMedicineName.includes("【禁忌】") ||
          treatMedicineName.includes("【禁忌・ｱﾚﾙｷﾞｰ】") ||
          treatMedicineName.includes("【ｱﾚﾙｷﾞｰ】"))
      );
    },
    setContentDataCps(newValue) {
      this.complaintSelector.model.name = newValue;

      // 入力文字が全て消された場合
      // 内部で保持しているコードをクリア
      if (!newValue || !newValue.trim()) {
        this.complaintSelector.model = new MstComplaint();
        return;
      }

      // 愁訴を手入力された場合、コードをnullにする事で、入力した内容を
      // 元の内容に戻した場合でも変更扱いになってしまう為、手入力された場合には、
      // 入力された文字列のみ更新する.
      this.complaintSelector.model = new MstComplaint(this.complaintSelector.model.cd, newValue);
    },

    setContentDataTms(newValue) {
      this.compTreatmentSelector.model.name = newValue;

      // 入力文字が全て消された場合
      // 内部で保持しているコードをクリア
      if (!newValue || !newValue.trim()) {
        this.compTreatmentSelector.model = new MstCompTreatment();
        return;
      }
      this.compTreatmentSelector.model = new MstCompTreatment(
        this.compTreatmentSelector.model.cd,
        newValue,
        CODES.TREATMENT_CLASS.NORMAL.cd
      );
    },
    // add 5519 愁訴処置で処置がないのに処置薬剤の保存操作が出来てしまう 房 start
    medicineClear(){
      if (!this.compTreatmentSelector.model.name) {
        this.selectedTreatMedicine.model = new MasterAndNumber();
        this.selectedTreatMedicine.unit = "";
        this.selectedTreatProcedureModel = new Master();
      }
    }
    // add 5519 愁訴処置で処置がないのに処置薬剤の保存操作が出来てしまう 房 end
  },
  beforeDestroy() {
    // dataの初期化
    // #9401 治療記録で愁訴処置を追加するとTYPEエラー発生 linjunfeng start
    // Object.assign(this.$data, this.$options.data());
    Object.assign(this.$data, this.$options.data.call(this));
    // #9401 治療記録で愁訴処置を追加するとTYPEエラー発生 linjunfeng end
  },
  async created() {
    await this.init();

    setTimeout(() => {
      // 処置者のスクロール位置を変更
      const target = document.querySelector('#new-comp-treat-staff-area-list input[type="checkbox"]:checked');
      // 指定した要素が取得出来ない場合
      if (!target) {
        return;
      }
      // 処置者テーブルの要素を取得
      let scrollArea = document.getElementById("new-comp-treat-staff-area-list");
      if (!scrollArea) {
        return;
      }
      // 処置者テーブルのヘッダ要素を取得
      const headerElement = document.getElementById("new-comp-treat-staff-header");
      if (!headerElement) {
        // スクロール位置を変更
        scrollArea.scrollTop = target.offsetTop;
      }
      //位置調節
      const rect = target.getBoundingClientRect();
      const headerheight = headerElement.offsetHeight;
      const adjustedTop = rect.top - headerheight;
      const scrollTo = adjustedTop + scrollArea.scrollTop - scrollArea.getBoundingClientRect().top;

      const maxScrollTop = scrollArea.scrollHeight - scrollArea.clientHeight;
      scrollArea.scrollTop = (Math.min(scrollTo, maxScrollTop));
    }, 500);
  },
  mounted() {
    // 呼出元からのパラメータ取得
    this.isNew = this.getInitValues.isNew;
    // 自要素が無い場合
    if (!this.$el) {
      return;
    }
    // モーダル画面サイズを変更
    // ※愁訴処置登録のモーダルはサブモーダルに変更した為、[治療記録]-[愁訴処置]-[新規登録]から
    //   表示した場合に画面が小さくなってしまう為、通常のモーダル画面と同じサイズに変更する.
    const elmSubModalContainer = this.$el.getElementsByClassName("sub-modal-container");
    if (elmSubModalContainer && elmSubModalContainer.length === 1) {
      elmSubModalContainer[0].style.width = "88%";
      elmSubModalContainer[0].style.height = "88%";
    }
  }
};
</script>

<style scoped>
.treatment-record-modal {
  margin: 0 4px;
  min-width: 46em;
  display: flex;
  flex-flow: column;
}
.treatment-record-modal >>> ons-col.title {
  flex: 0 0 6em;
}
.treatment-record-modal >>> ons-col.unit {
  flex: 0 0 3em;
}
label {
  font-size: 1em !important;
}
th {
  z-index: 1;
}
div >>> textarea {
  width: 96%;
  height: 4em;
  font-size: 1em;
  font-family: inherit;
}
.ntss-list .medicine-td,
.ntss-list .procedure-td {
  height: 1.5em;
}
.main-content {
  height: 100%;
}
.height-def {
  height: inherit;
}
.height-def #comp-and-treat-tbl-wrapper {
  height: calc(100% - 8.5em);
  min-height: calc(16em + 200px);
  flex: 1;
  width: 100%;
  display: flex;
}
.ntss-style-date-time >>> .title {
  min-width: unset;
}
.scroll-table {
  overflow-y: auto;
  height: calc(100% - 4.5em);
}
.height-def #comp-and-treat-selector-wrapper {
  margin-top: 0.5em;
}
.ntss-list {
  position: inherit;
}
.edit-button {
  width: 3.5em;
}
.complaint-td {
  padding: 4px;
  vertical-align: top;
}
.selector-td {
  padding: 2px 4px;
  vertical-align: middle;
}
.selector-td >>> ons-row {
  height: inherit;
  /* width: 90%; */
}
.selector-td >>> .text-input,
.selector-td >>> label {
  font-size: 1em;
}
.selector-td >>> ons-input {
  width: 100%;
}
.selector-td >>> ons-col.num-value {
  flex: 0 0 3em;
}
.selector-td >>> ons-col.unit {
  padding-left: 4px;
}
#personal-user-selector-wrapper >>> ons-col.select-button,
.selector-td >>> ons-col.select-button {
  flex: 0 0 3em;
  align-items: center;
}
.selector-td >>> .select-btn {
  font-size: 1em;
}
.treat-medicine-selector >>> ons-col.title {
  flex: 1;
}
.procedure-selector >>> ons-col.title {
  display: none;
}
.treat-staff-selector {
  width: 28em;
}
.treat-staff-selector >>> ons-col.select-button {
  font-size: 1.5em;
}
.border-per-page-bottom {
  border-bottom: solid 1px var(--treatment-record-complaint-per-page-border) !important;
}
.border-per-page-right {
  border-right: solid 1px var(--treatment-record-complaint-per-page-border) !important;
}
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
}

.ntss-list-body-tr-black {
  background-color: var(--ntss-base-background-color);
  color: #fafafa;
}
.ntss-list-body-td {
  border: solid 1px #cccccc;
}
/**
 * 薬剤瓶部分のスタイル
 */
td.medicine-bottle {
  width: 24px;
  border-left: none;
  padding-top: 6px;
  padding-bottom: 4px;
  -webkit-filter: invert(var(--treatment-record-medicine-bottle-invert));
  filter: invert(var(--treatment-record-medicine-bottle-invert));
  vertical-align: middle;
}
/**
 * 処置列のスタイル
 */
td.treat-name {
  border-right: none;
}
div >>> .sub-modal-container,
div >>> .sub-modal-search,
div >>> .sub-modal-body,
div >>> .sub-modal-footer,
div >>> .sub-modal-footer .bottom-bar {
  background-color: var(--ntss-base-background-color);
  color: var(--ntss-base-color);
}

.procedure-selector >>> ons-col.text-value {
  color: var(--ntss-base-color);
}

div >>> .com-textarea{
  width: 98%;
  box-sizing: border-box;
}
@media print {
  .main-content >>> div {
    height: auto !important;
  }
}
</style>
