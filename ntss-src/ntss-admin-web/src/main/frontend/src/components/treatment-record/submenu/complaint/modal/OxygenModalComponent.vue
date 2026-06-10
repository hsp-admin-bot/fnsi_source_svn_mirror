/**
 * 酸素吸入モーダル
 */
<template>
  <modal-base @onClose="cancel">
    <div slot="body">
      <table class="oxygen-table treatment-record-accordion treatment-record-modal">
        <tr v-for="(item, index) in actualModel" :key="index">
          <td class="oxygen-tb-content" :class="{ 'edited-row': item.isNew }">
            <button
              v-show="actualModel.length - 1 === index && item.isEditable"
              class="button-delete ntss-btn-outset"
              @click="deleteItem(item.isNew)"
            ><v-ons-icon icon="fa-trash"/></button>
            <template  v-if="item.isStart">
              <com-date-time-input
                labelName="開始日時"
                :dateID="'startDate' + index"
                :required="true"
                v-model="item.startDate"
                :initValue="initModel[index].startDate"
                :disabled="!item.isEditable"
                :isValid="item.isValid"
                @input="setOxygenAmount($event, index, 'startDate')"
              />
              <com-number-input
                labelName="速度"
                unitName="L/min"
                :step="0.01"
                :inputType='"number"'
                :inputMin=0.0
                :inputMax=9999.99
                v-model="item.oxygenSpeed"
                :initValue="initModel[index].oxygenSpeed"
                :disabled="!item.isEditable"
                @getChildData="setOxygenAmount($event, index, 'oxygenSpeed')"
              />
              <v-ons-row class="user-name-1">
                <v-ons-col class="title">
                  <label>処置者</label>
                </v-ons-col>
                <v-ons-col width="13em" class="value d-flex align-items-center">
                  <custom-input :value="userNameValue[index]" :disabled="true" />
                </v-ons-col>
                <v-ons-col width="5em" class="select d-flex align-items-center">
                  <!-- mod 11778 【因島】実績の穿刺者や返血者の選択ダイアログでログイン者が選択されていない zkm start-->
<!--                  <com-master-selector-->
<!--                    name="personal-user-all"-->
<!--                    :v-model="createStaffValue(index)"-->
<!--                    :showLabelName="false"-->
<!--                    :showClassFilter="true"-->
<!--                    :readMasterData="fetchPersonalUserAll"-->
<!--                    :masterDefine="personalUser"-->
<!--                    :index="index"-->
<!--                    @changePersonalUser="setUser"-->
<!--                    :class="['isClass']"-->
<!--                    :isDisabled="!item.isEditable"-->
<!--                  />-->
                  <com-master-selector
                    name="personal-user-all"
                    :value="createStaffValue(index)"
                    :showLabelName="false"
                    :showClassFilter="true"
                    :readMasterData="fetchPersonalUserAll"
                    :masterDefine="personalUser"
                    :index="index"
                    @changePersonalUser="setUser"
                    :class="['isClass']"
                    :isDisabled="!item.isEditable"
                  />
                  <!-- mod 11778 【因島】実績の穿刺者や返血者の選択ダイアログでログイン者が選択されていない zkm end-->
                </v-ons-col>
              </v-ons-row>
            </template>
            <template v-else>
              <com-date-time-input
                labelName="終了日時"
                :required="true"
                :dateID="'endDate' + index"
                v-model="item.endDate"
                :initValue="initModel[index].endDate"
                :disabled="!item.isEditable"
                :isValid="item.isValid"
                @input="setOxygenAmount($event, index, 'endDate')"
              />
              <com-number-input
                labelName="吸入量"
                unitName="L"
                :step="0.01"
                :inputMin="0.0"
                :inputMax="9999.99"
                :inputType='"number"'
                v-model="item.oxygenAmount"
                :initValue="initModel[index].oxygenAmount"
                :disabled="!item.isEditable"
              />
              <v-ons-row class="user-name-2">
                <v-ons-col class="title">
                  <label>処置者</label>
                </v-ons-col>
                <v-ons-col width="13em" class="value d-flex align-items-center">
                  <custom-input :value="userNameValue[index]" :disabled="true" />
                </v-ons-col>
                <v-ons-col width="5em" class="select d-flex align-items-center">
                  <!-- mod 11778 【因島】実績の穿刺者や返血者の選択ダイアログでログイン者が選択されていない zkm start-->
<!--                  <com-master-selector-->
<!--                    name="personal-user-all"-->
<!--                    :v-model="createStaffValue(index)"-->
<!--                    :showLabelName="false"-->
<!--                    :showClassFilter="true"-->
<!--                    :readMasterData="fetchPersonalUserAll"-->
<!--                    :masterDefine="personalUser"-->
<!--                    :index="index"-->
<!--                    @changePersonalUser="setUser"-->
<!--                    :class="['isClass']"-->
<!--                    :isDisabled="!item.isEditable"-->
<!--                  />-->
                  <com-master-selector
                    name="personal-user-all"
                    :value="createStaffValue(index)"
                    :showLabelName="false"
                    :showClassFilter="true"
                    :readMasterData="fetchPersonalUserAll"
                    :masterDefine="personalUser"
                    :index="index"
                    @changePersonalUser="setUser"
                    :class="['isClass']"
                    :isDisabled="!item.isEditable"
                  />

                  <!-- mod 11778 【因島】実績の穿刺者や返血者の選択ダイアログでログイン者が選択されていない zkm end-->
                </v-ons-col>
              </v-ons-row>
            </template>
          </td>
        </tr>
      </table>
      <div class="total-container">
        <label class="add-btn" @click="addRow()">
          <img class="pat-create-btn" src="img/pat-info/add.png"/>
        </label>
        <com-number-display
          labelName="合計吸入量"
          unitName="L"
          :digits="2"
          v-model="totalAmount"
        />
      </div>
      <br>
    </div>
    <div slot="footer" class="flex-container" style="overflow-x: auto;">
      <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 start -->
      <div class="denial-btn-area" style="background: none">
        <v-ons-button class="button denial-btn btn2-cancel" @click="cancel"
          >キャンセル</v-ons-button
        >
      </div>
      <div class="registration-btn-area" style="background: none">
        <v-ons-button
          class="button registration-btn btn1-execute"
          :disabled="!isChanged"
          @click="saveItem"
          >保存</v-ons-button
        >
      </div>
      <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 end -->
    </div>
  </modal-base>
</template>

<script>
import moment from "moment";
import { mapGetters, mapActions } from "vuex";
import ModalBase from "@/components/modals/ModalBase";
import MultiModalMixin from "@/components/modals/MultiModalMixin";
import DiscardConfirmationMixin from "@/components/treatment-record/DiscardConfirmationMixin";
import CommonNumberInputComponent from "@/components/treatment-record/submenu/common/CommonNumberInputComponent";
import CommonDateTimeComponent from "@/components/treatment-record/submenu/common/CommonDateTimeComponent";
import CommonNumberDisplayComponent from "@/components/treatment-record/submenu/common/CommonNumberDisplayComponent";
import CommonMasterSelectorComponent from "@/components/common/master-selector/TreatmentRecordSelectorComponent";
import { personalUser } from "@/components/common/master-selector/MasterSelectorDefinitions";
import ComplaintComponentMixin from "@/components/treatment-record/submenu/complaint/ComplaintComponentMixin";
import { Complaint } from "@/models/treatment-record/complaint/Complaint";
import { OxygenModal } from "@/models/treatment-record/complaint/OxygenModal";
import { Treatment } from "@/models/treatment-record/complaint/Treatment";
import { Master } from "@/models/common/master-selector-condition/Master";
import { CODES } from "@/constants/TreatmentRecord";
import { dateFormat } from "@/functions/common/DateTimeUtils";
import { EventBus } from "@/eventBus.js";
import {
  sendRequestGetMstPersonalUser,
  sendRequestMstGetJobs,
} from "@/apis/user-selector-popover";
// FNSI-add redmine4848 徐 start
import customInput from "@/components/common/custom-form-tags/CustomInput";
// FNSI-add redmine4848 徐 end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end

export default {
  mixins: [MultiModalMixin, DiscardConfirmationMixin, ComplaintComponentMixin],
  components: {
    "modal-base": ModalBase,
    "com-number-input": CommonNumberInputComponent,
    "com-date-time-input": CommonDateTimeComponent,
    "com-number-display": CommonNumberDisplayComponent,
    "com-master-selector": CommonMasterSelectorComponent,
    // FNSI-add redmine4848 徐 start
    "custom-input": customInput,
    // FNSI-add redmine4848 徐 end
  },
  data() {
    return {
      personalUser: personalUser,
      actualModel: [],
      // del FNSI-8014 劉全航 start
      // totalAmount: null,
      // del FNSI-8014 劉全航 end
      treatmentArgBase: {
        treatCd: null,
        treatName: null,
        amount: null,
        unit: null,
        procedureCd: null,
        procedureName: null,
        treatMedicineCd: null,
        treatMedicineName: null,
      },
      userNameValue: [],
      // #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng start
      initModel: [],
      // #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng end
    };
  },
  computed: {
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("treatment-record/common", ["getDialysisState", "getRstEndDate"]),
    //add FNSI修正内容 愁訴処置の登録および表示修正 房 start
    ...mapGetters("treatment-record/complaint", ["getTempCtlNo"]),
    //add FNSI修正内容 愁訴処置の登録および表示修正 房 end
    // add 11778 【因島】実績の穿刺者や返血者の選択ダイアログでログイン者が選択されていない zkm start
    ...mapGetters("account-edit", {userInfo: "getStateUserAccountInfo"}),
    // add 11778 【因島】実績の穿刺者や返血者の選択ダイアログでログイン者が選択されていない zkm end

    /**
     * 編集したかどうかのフラグ.
     */
    isChanged() {
      if (this.actualModel.length === 0) {
        return false;
      }

      const areDatesEqual = (date1, date2) => {
      if (date1 === null || date2 === null) return date1 === date2;
        return date1.getTime() === date2.getTime();
      };

      const areStaffEqual = (staff1, staff2) => {
      if (!staff1 || !staff2) return staff1 === staff2;
        return staff1.cd === staff2.cd && staff1.name === staff2.name;
      };

      // 編集前後の各プロパティを比較
      for (let i = 0; i < this.actualModel.length; i++) {
        const actualItem = this.actualModel[i];
        const initItem = this.initModel[i];
        // 変更チェック
        if (
          !areDatesEqual(actualItem.startDate, initItem.startDate) ||
          actualItem.oxygenSpeed != initItem.oxygenSpeed ||
          !areDatesEqual(actualItem.endDate, initItem.endDate) ||
          actualItem.oxygenAmount != initItem.oxygenAmount ||
          !areStaffEqual(actualItem.staff, initItem.staff)
        ) {
          return true;
        }
      }
      return false;
    },
    // 合計吸入量
    totalAmount() {
      const totalOxygenAmount = this.actualModel.reduce((sum, item) => {
        return sum + (item.oxygenAmount !== null ? parseFloat(item.oxygenAmount) : 0);
      }, 0);
      // oxygenAmountが全てnullの場合は0を返す
      if (totalOxygenAmount === 0 && this.actualModel.every(item => item.oxygenAmount === null)) {
        return 0;
      }
      // 小数第二位で切り上げ
      return Math.ceil(totalOxygenAmount * 100) / 100;
    },
  },
  methods: {
    ...mapGetters("account-edit", ["getUserId", "getUserName"]),
    ...mapGetters("treatment-record/complaint", [
      "getOxygenModal",
      "getComplaintData",
    ]),
    ...mapActions("treatment-record/complaint", ["setComplaintData"]),

    /**
     * 削除（×）ボタンクリック時ハンドラ.
     * @param isNew 追加行かどうかのフラグ
     */
    deleteItem(isNew) {
      // 既存データの場合は確認ダイアログを表示する
      if (!isNew) {
        this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "削除確認",
          title: DIALOG_MESSAGES[13000141].title,
          // message: "削除します。<br>よろしいですか？",
          message: messageFormat(DIALOG_MESSAGES[13000141].message),
          callback: (answer) => {
            if (answer === 1) {
              // 削除データ反映
              this.doReflect(1);
            }
          },
        });
      } else {
        // 追加行の場合はアラートなし。編集前、編集中modelから最後の要素削除
        this.removeLastElement();
      }
    },
    /**
     * 保存ボタンクリック時ハンドラ.
     */
    saveItem() {
      // エラースタイル クリア
      this.actualModel.forEach(element => {
        element.isValid = true;
      });

      let errorMessages = [];

      /**
       * 日付の相関チェック
       * - 開始日時：1つ前の終了日時以上でなくてはいけない
       * - 終了日時：1つ前の開始日以上でなくてはいけない
       */
      // 最初のブロックの開始日時と終了日時の相関チェック
      if (this.actualModel[0].isStart) {
        if (this.actualModel[0].startDate > this.actualModel[1]?.endDate) {
          errorMessages.push(messageFormat(DIALOG_MESSAGES["00200117"].message));
          this.actualModel[1].isValid = false; // 終了日時にエラースタイル適用
        }
      }
      const startIndex = this.actualModel[0].isStart ? 2 : 1;
      // 2番目以降の要素のチェック
      for (let i = startIndex; i < this.actualModel.length; i += 2) {
        const currentStartDate = this.actualModel[i]?.startDate;
        const currentEndDate = this.actualModel[i + 1]?.endDate;  // 終了日時を取得
        const previousEndDate = this.actualModel[i - 1]?.endDate; // 1つ前の終了日時を取得
        // 終了日時：1つ前の開始日以上かのチェック
        if (currentStartDate > currentEndDate) {
          errorMessages.push(messageFormat(DIALOG_MESSAGES["00200117"].message));
          this.actualModel[i + 1].isValid = false; // 終了日時にエラースタイル適用
        }
        // 開始日時：1つ前の終了日時以上かのチェック
        if (currentStartDate < previousEndDate) {
          errorMessages.push(messageFormat(DIALOG_MESSAGES["00200160"].message));
          this.actualModel[i].isValid = false; // 開始日時にエラースタイル適用
        }
      }

      if (errorMessages.length > 0) {
        // エラーメッセージの重複削除
        const uniqueErrorMessages = [...new Set(errorMessages)];
        this.$ons.notification.alert({
          title: "チェックエラー",
          message: messageFormat(uniqueErrorMessages.join("\n"))
        });
        return;
      }

      // 保存データ反映
      this.doReflect(0);
    },
    /**
     * 保存、削除 反映処理.
     * - 保存：storeの愁訴処置データへ編集後データを反映する
     * - 削除：storeの愁訴処置データから対象行を削除する
     * 最終的に親コンポーネント側でstoreに保存した愁訴処置データに対してrowNoを振りなおしてDB更新する
     * @param flag 0:保存、1:削除
     */
    doReflect(flag) {
      // 愁訴処置画面の表示データ取得
      let complaintData = this.getComplaintData();
      let oxygenDataList = [];
      let operateFlg = 'oxygenEdit';
      // 保存処理
      if (flag === 0) {
        // this.actualModelの全要素のctlNoを取得 ※追加行は除く
        const deleteCtlNos = this.actualModel
          .filter(model => model.treatment)
          .map(model => model.treatment.ctlNo);
        // deleteCtlNosに一致する要素を愁訴処置データから除外する
        complaintData = complaintData.filter(({ complaint, treatmentList }) =>
          !deleteCtlNos.includes(complaint.ctlNo) &&
          !treatmentList.some(({ ctlNo }) => deleteCtlNos.includes(ctlNo))
        );

        // 前行のctlNo
        let previousCtlNo = null;
        this.actualModel.forEach((model, i) => {
          const ctlNo = model.isNew ? null : model.treatment.ctlNo;
          const rowNo = 1;
          const index = i + 1;
          if (model.isStart) {
            // 開始ブロックの処理
            const startDate = moment(model.startDate);
            const startComplaint = Complaint.of({
              ctlNo: ctlNo,
              rowNo,
              occurDate: model.startDate,
            });

            startComplaint.treatmentList = [
              Treatment.of(
                {
                  ...this.treatmentArgBase,
                  ctlNo: ctlNo,
                  rowNo,
                  index,
                  occurDate: model.startDate,
                  treatClass: CODES.COMPLAINT_TREAT_CLASS.OXYGEN.cd,
                  oxygenStart: dateFormat.format(model.startDate, "yyyyMMdd"),
                  oxygenTime: startDate.diff(startDate.clone().startOf("date"), "minutes"),
                  oxygenSpeed: model.oxygenSpeed,
                  isEditable: model.isEditable ? "1" : "0"
                },
                {
                  ctlNo: ctlNo,
                  rowNo,
                  index,
                  occurDate: model.startDate,
                  treatStaffCd: model.staff ? model.staff.cd : null,
                  treatStaffName: model.staff ? model.staff.name : null,
                  isEditable: model.isEditable ? "1" : "0"
                }
              ),
            ];
            // 生成した開始ブロックを愁訴処置データに追加
            complaintData.push(startComplaint);
            oxygenDataList.push(startComplaint);
          } else {
            // 終了ブロックの処理
            const endComplaint = Complaint.of({
              ctlNo: ctlNo,
              rowNo,
              occurDate: model.endDate,
            });

            endComplaint.treatmentList = [
              Treatment.of(
                {
                  ...this.treatmentArgBase,
                  ctlNo: ctlNo,
                  rowNo,
                  index,
                  occurDate: model.endDate,
                  treatClass: CODES.COMPLAINT_TREAT_CLASS.OXYGEN.cd,
                  oxygenAmount: model.oxygenAmount,
                  linkStartDate: previousCtlNo?.toString() || null, // 対応する酸素吸入開始のctl_noをStringに変換してセット
                  isEditable: model.isEditable ? "1" : "0"
                },
                {
                  ctlNo: ctlNo,
                  rowNo,
                  index,
                  occurDate: model.endDate,
                  treatStaffCd: model.staff ? model.staff.cd : null,
                  treatStaffName: model.staff ? model.staff.name : null,
                  isEditable: model.isEditable ? "1" : "0"
                }
              ),
            ];
            // 生成した終了ブロックを愁訴処置データに追加
            complaintData.push(endComplaint);
            oxygenDataList.push(endComplaint);
          }
          // ctlNo退避
          previousCtlNo = ctlNo;
        });
      }

      // 削除処理
      if (flag === 1) {
        const deleteCtlNo = this.actualModel.at(-1).treatment.ctlNo; // 最終行の削除
        complaintData.forEach(item => {
          if (item.complaint.ctlNo === deleteCtlNo) {
            item.complaint.isDel = true;
            item.treatmentList[0].isDel = true;
            if (item.treatmentList[0].treatStaff) {
              item.treatmentList[0].treatStaff.isDel = true;
            }
          }
          if (item.treatmentList?.[0]?.treatClass === 3) {
            oxygenDataList.push(item);
          }
        })
        // 削除行を愁訴処置データから除外する
        complaintData = complaintData.filter(
          (e) =>
            e.complaint.ctlNo !== deleteCtlNo &&
            !e.treatmentList.some((element) => element.ctlNo === deleteCtlNo)
        );
        operateFlg = "oxygenDelete";
        // 編集前、編集中modelから最後の要素削除
        EventBus.$on('deleteOxygenOrElectrocardiogram', this.removeLastElement)
      }

      // ソートしてストアに設定
      this.setComplaintData(complaintData.sort((a, b) => a.compareTo(b)));
      // 親の保存イベントを呼びだす
      EventBus.$emit("saveCompTreatCreate", oxygenDataList, operateFlg);
    },
    /**
     * キャンセルボタンクリック時ハンドラ.
     */
    cancel() {
      if (this.isChanged) {
        this.discardConfirm(this.hideModal);
      } else {
        this.hideModal();
      }
    },

    fetchPersonalUserAll() {
      return Promise.all([
        sendRequestGetMstPersonalUser(this.facilityCd),
        sendRequestMstGetJobs(this.facilityCd),
      ]);
    },

    // FNSI-add redmine4848 徐 start
    setUser(userInfo, index) {
      let userName = "";
      if (userInfo && userInfo.lastName) {
        userName = userInfo.lastName + " ";
      }
      if (userInfo && userInfo.firstName) {
        userName = userName + userInfo.firstName;
      }
      this.actualModel[index].staff.name = userName;
      this.actualModel[index].staff.cd = userInfo ? userInfo.id : null;

      // リアクティブに通知してUIが更新されるようにspliceで配列を更新する
      const newValue = {
        ...this.userNameValue[index],
        editValue: this.actualModel[index].staff.name
      };
      this.userNameValue.splice(index, 1, newValue);
    },
    // FNSI-add redmine4848 徐 end
    createStaffValue(index) {
      // mod 11778 【因島】実績の穿刺者や返血者の選択ダイアログでログイン者が選択されていない zkm start
      // return new Master(this.actualModel[index].staff.cd, this.actualModel[index].staff.name);
      return new Master(null == this.actualModel[index].staff.cd || "" === this.actualModel[index].staff.cd
        ? this.userInfo.userId : this.actualModel[index].staff.cd, this.actualModel[index].staff.name);
      // mod 11778 【因島】実績の穿刺者や返血者の選択ダイアログでログイン者が選択されていない zkm end
    },
    /**
     * 吸入量 設定
     * @param {*} newValue 変更後の値
     * @param {Number} index 表示中のModelのindex
     * @param {String} field 変更したフィールド名
     */
    setOxygenAmount(newValue, index, field) {
      let startOxygenModal = null;
      let endOxygenModal = null;
      let endDate = null;
      if (["startDate", "oxygenSpeed"].includes(field)) {
        // 開始ブロック取得
        startOxygenModal = { ...this.actualModel[index] };
        // 速度変更時だけmodelに変更後の値が反映されていないためnewValueを上書き
        startOxygenModal.oxygenSpeed = "oxygenSpeed" === field ? newValue : startOxygenModal.oxygenSpeed;
        // 終了日時取得
        if ((index + 1) < this.actualModel.length) {
          endOxygenModal = this.actualModel[index + 1];
          endDate = endOxygenModal.endDate;

          // 終了が編集不可の場合は算出処理を行わない
          if (!endOxygenModal.isEditable) {
            return;
          }
        }
      } else {
        // 開始ブロック取得
        startOxygenModal = { ...this.actualModel[index - 1] };
        // 終了日時取得
        endOxygenModal = this.actualModel[index];
        endDate = endOxygenModal.endDate;
      }

      if (endOxygenModal) {
        // 吸入量の算出
        const oxygenAmount = this.calcOxygenAmount(endDate, startOxygenModal);
        // 結果がnullの場合はパラメータ不足のため未計算。元の値を更新しない
        endOxygenModal.oxygenAmount = oxygenAmount !== null ? oxygenAmount : endOxygenModal.oxygenAmount;
      }
    },
    /**
     * 吸入量の算出
     * @param {*} endDate
     * @param {*} preOxygenModal
     */
    calcOxygenAmount(endDate, preOxygenModal) {
      // パラメータが不足している場合は計算しない
      if (endDate === null || preOxygenModal.startDate === null || preOxygenModal.oxygenSpeed === null || preOxygenModal.oxygenSpeed === "") {
        return null;
      }
      // 吸入量に1つ前の開始速度*(終了日時－1つ前の開始日時)を計算
      const diff = moment(endDate).diff(moment(preOxygenModal.startDate), "minutes");
      if (diff >= 0) {
        let total = isNaN(diff) ? null : diff * preOxygenModal.oxygenSpeed;
        return Math.round(total * 100) / 100; // 計算結果を返す
      }
      return null; // 差が0未満の場合はnullを返す
    },
    /**
     * 開始 or 終了ブロック追加
     */
    addRow() {
      const createOxygenModal = (isStart, date, preOxygenModal) => {
        const oxygenModal = new OxygenModal(null, isStart, date);
        if (!isStart) {
          // 吸入量を算出
          oxygenModal.oxygenAmount = this.calcOxygenAmount(date, preOxygenModal);
        }
        return oxygenModal;
      };

      const preOxygenModal = this.actualModel.at(-1);
      // 1つ前が開始の場合、終了ブロック追加、デフォルト日時に1つ前の開始日時以上を設定
      // 1つ前が終了の場合、開始ブロック追加、デフォルト日時に1つ前の終了日時以上を設定
      // 1つ前のブロックが開始かどうかを確認
      const preIsStart = preOxygenModal?.isStart || false;
      // デフォルト日時を設定
      const defaultDate = this.getDefaultDate(
        preIsStart
          ? preOxygenModal.startDate
          : preOxygenModal?.endDate || null
      );
      const oxygenModal = createOxygenModal(!preIsStart, defaultDate, preOxygenModal);

      // 編集前データ
      this.initModel.push(JSON.parse(JSON.stringify(oxygenModal)));

      // デフォルト値を設定
      // デフォルト開始/終了日時
      if (preIsStart) {
        oxygenModal.endDate = defaultDate;
      } else {
        oxygenModal.startDate = defaultDate;
      }
      // 処置者：サインインユーザー
      oxygenModal.staff = new Master(this.getUserId(), this.getUserName());
      this.userNameValue.push({ initValue: "", editValue: oxygenModal.staff.name });

      // 編集後データ
      this.actualModel.push(oxygenModal);

      // 一番下にスクロールする
      this.$nextTick(() => {
        const scrollBody = document.getElementById("scrollbody");
        scrollBody.scrollTop = scrollBody.scrollHeight;
      });
    },
    /**
     * 編集前、編集中modelから最後の要素削除
     */
    removeLastElement() {
      EventBus.$off('deleteOxygenOrElectrocardiogram', this.removeLastElement);
      this.actualModel.pop();
      this.initModel.pop();
      this.userNameValue.pop();
    }
  },
  beforeDestroy() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
    EventBus.$off('deleteOxygenOrElectrocardiogram', this.removeLastElement);
  },
  created() {
    this.$nextTick(() => {
      this.actualModel = this.getOxygenModal();
      // デフォルトブロック追加
      if (this.actualModel.length === 0) {
        // oxygenModalsが空の場合は開始ブロックを追加
        const defaultDate = this.getDefaultDate(null);
        const oxygenModal = new OxygenModal(null, true, defaultDate);
        this.actualModel.push(oxygenModal);
      } else {
        // oxygenModalsの最後尾が開始日時の場合は終了ブロックを追加
        const preOxygenModal = this.actualModel.at(-1);
        if (preOxygenModal.isStart) {
          // 1つ前が開始の場合、終了ブロック追加
          // デフォルト日時に1つ前の開始日時以上を設定
          const defaultDate = this.getDefaultDate(preOxygenModal.startDate);
          const oxygenModal = new OxygenModal(null, false, defaultDate);
          // 吸入量を算出
          oxygenModal.oxygenAmount = this.calcOxygenAmount(defaultDate, preOxygenModal);

          this.actualModel.push(oxygenModal);
        }
      }
      // #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng start
      this.initModel = JSON.parse(JSON.stringify(this.actualModel));
      // #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng end
      // 各要素のstartDate, endDateをDateオブジェクトに変換
      this.initModel.forEach(item => {
        if (item.startDate !== null) {
          item.startDate = new Date(item.startDate);
        }
        if (item.endDate !== null) {
          item.endDate = new Date(item.endDate);
        }
      });

      // デフォルト値 設定
      this.actualModel.forEach((item, index) => {
        // 開始日時
        if (item.isStart && item.startDate === null) {
          item.startDate = item.defaultDate;
        }
        // 終了日時
        if (!item.isStart && item.endDate === null) {
          item.endDate = item.defaultDate;
        }
        // 処置者：サインインユーザー
        this.userNameValue[index] = { initValue: null, editValue: null }; // 初期化
        this.userNameValue[index].initValue = item.staff != null ? item.staff.name : "";
        if (item.staff === null) {
          item.staff = new Master(this.getUserId(), this.getUserName());
        }
        this.userNameValue[index].editValue = item.staff.name;
      });
    });
  }
};
</script>

<style scoped>
.oxygen-table {
  width: 98%;
  padding-left: 10px;
}
.oxygen-table tr {
  position: relative;
}
.oxygen-tb-content {
  border-bottom: 1px solid #cccccc;
  padding: 10px;
}
.oxygen-tb-content >>> ons-row {
  flex-wrap: nowrap;
}
.oxygen-tb-content >>> ons-col.title {
  /* treatment-record-accordion 関連設定の幅だけ上書きする */
  flex: 0 0 30%;
  min-width: 7em;
}
.total-container {
  min-width: 7em;
  max-width: 35.4em;
}
.total-container >>> ons-row {
  flex-wrap: nowrap;
  width: 90%;
  margin-top: 10px;
}
.total-container >>> ons-col.title {
  min-width: 7.5em;
  max-width: 25em;
  text-align: right;
  padding-left: 40px;
}
.total-container >>> ons-col.num-value {
  flex: 0 0 5em;
  max-width: 5em;
  text-align: right;
}
div >>> .modal-container,
div >>> .modal-search,
div >>> .modal-body,
div >>> .modal-footer,
div >>> .modal-footer .bottom-bar {
  background-color: var(--ntss-base-background-color);
  color: var(--ntss-base-color);
}
div >>> .modal-body {
  overflow-x: hidden;
}
/* add FNSI-redmine3855 徐 start */
.isClass {
  padding: unset;
}
.isClass >>> ons-button {
  margin-right:35em;
}
/* add FNSI-redmine3855 徐 end */
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
.edited-row {
  color: #003300 !important;
  background-color: #ccffcc !important;
}
.add-btn {
  padding: 0px 0px 0px 10px;
  position: absolute;
}
/* 削除ボタン */
.button-delete {
  position: absolute;
  top: 0;
  right: 0;
  z-index: 1;
  height: 100%;
}
</style>
