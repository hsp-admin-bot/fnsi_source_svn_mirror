/**
 * 心電図モーダル
 */
<template>
  <modal-base @onClose="cancel">
    <div slot="body">
      <table class="electro-table treatment-record-accordion treatment-record-modal">
        <tr v-for="(item, index) in actualModel" :key="index">
          <td class="electrocardiogram-tb-content" :class="{ 'edited-row': item.isNew }">
            <button
              v-show="actualModel.length - 1 === index && item.isEditable"
              class="button-delete ntss-btn-outset"
              @click="deleteItem(item.isNew)"
            ><v-ons-icon icon="fa-trash"/></button>
            <template  v-if="item.isStart">
              <com-date-time-input
                :is-show-clear="true"
                labelName="開始日時"
                dateID="'startDate' + index"
                :required="true"
                v-model="item.startDate"
                :initValue="initModel[index].startDate"
                :disabled="!item.isEditable"
                :isValid="item.isValid"
                @input="setOverTime(index, 'startDate')"
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
                dateID="'endDate' + index"
                v-model="item.endDate"
                :initValue="initModel[index].endDate"
                :disabled="!item.isEditable"
                :isValid="item.isValid"
                :appendix="formatMinutes(item.overTime)"
                @input="setOverTime(index, 'endDate')"
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
      </div>
      <br>
    </div>
    <div slot="footer" class="flex-container" style="overflow-x: auto;">
      <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 start -->
      <div class="denial-btn-area" style="background:none">
        <v-ons-button class="button denial-btn btn2-cancel" @click="cancel">キャンセル</v-ons-button>
      </div>
      <!-- add 確定有効の修正 周雨晴 start 2020/10/20 -->
      <div class="registration-btn-area" style="background:none">
        <v-ons-button class="button registration-btn btn1-execute" :disabled="!isChanged" @click="saveItem">保存</v-ons-button>
      </div>
      <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 end -->
      <!-- add 確定有効の修正 周雨晴 end 2020/10/20 -->
    </div>
  </modal-base>
</template>

<script>
import moment from "moment";
import { mapGetters, mapActions } from "vuex";
import ModalBase from "@/components/modals/ModalBase";
import MultiModalMixin from "@/components/modals/MultiModalMixin";
import DiscardConfirmationMixin from "@/components/treatment-record/DiscardConfirmationMixin";
import CommonDateTimeComponent from "@/components/treatment-record/submenu/common/CommonDateTimeComponent";
import CommonMasterSelectorComponent from "@/components/common/master-selector/TreatmentRecordSelectorComponent";
import { personalUser } from "@/components/common/master-selector/MasterSelectorDefinitions";
import ComplaintComponentMixin from "@/components/treatment-record/submenu/complaint/ComplaintComponentMixin";
import { Complaint } from "@/models/treatment-record/complaint/Complaint";
import { ElectrocardiogramModal } from "@/models/treatment-record/complaint/ElectrocardiogramModal";
import { Treatment } from "@/models/treatment-record/complaint/Treatment";
import { Master } from "@/models/common/master-selector-condition/Master";
import { CODES } from "@/constants/TreatmentRecord";
import { dateFormat } from "@/functions/common/DateTimeUtils";
import { EventBus } from "@/eventBus.js";
import { sendRequestGetMstPersonalUser, sendRequestMstGetJobs } from "@/apis/user-selector-popover";
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
    "com-date-time-input": CommonDateTimeComponent,
    "com-master-selector": CommonMasterSelectorComponent,
    // FNSI-add redmine4848 徐 start
    "custom-input": customInput,
    // FNSI-add redmine4848 徐 end
  },
  data() {
    return {
      personalUser: personalUser,
      actualModel: [],
      overTime: null,
      treatmentArgBase: {
        treatCd: null,
        treatName: null,
        procedureCd: null,
        procedureName: null,
        treatMedicineCd: null,
        treatMedicineName: null
      },
      userNameValue: [],
      initModel: [],
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
          !areDatesEqual(actualItem.endDate, initItem.endDate) ||
          !areStaffEqual(actualItem.staff, initItem.staff)
        ) {
          return true;
        }
      }
      return false;
    }
  },
  methods: {
    ...mapGetters("account-edit", ["getUserId", "getUserName"]),
    ...mapGetters("treatment-record/complaint", ["getElectrocardiogramModal", "getComplaintData"]),
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
       * 経過時間チェック
       * - 経過時間が99:59を超過していないかチェック
       */
      // 最初のブロックの開始日時と終了日時の相関チェック
      if (this.actualModel[0].startDate > this.actualModel[1]?.endDate) {
        errorMessages.push(messageFormat(DIALOG_MESSAGES["00200117"].message));
        this.actualModel[1].isValid = false; // 終了日時にエラースタイル適用
      }
      // 最初のブロックの経過時間チェック
      if (this.actualModel[1]?.overTime && this.actualModel[1]?.overTime >= 100 * 60) {
        errorMessages.push(messageFormat(DIALOG_MESSAGES["00200161"].message));
        this.actualModel[1].isValid = false; // 終了日時にエラースタイル適用
      }
      // 2番目以降の要素のチェック
      for (let i = 2; i < this.actualModel.length; i += 2) {
        const currentStartDate = this.actualModel[i]?.startDate;
        const currentEndDate = this.actualModel[i + 1]?.endDate;  // 終了日時を取得
        const currentOverTime = this.actualModel[i + 1]?.overTime;// 経過時間を取得
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
        // 経過時間チェック
        if (currentOverTime && currentOverTime >= 100 * 60) {
          errorMessages.push(messageFormat(DIALOG_MESSAGES["00200161"].message));
          this.actualModel[i + 1].isValid = false; // 終了日時にエラースタイル適用
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
      let electrocardiogramDataList = [];
      let operateFlg = 'electrocardiogramEdit';
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
          // 追加行の場合は新たにctl_noを採番し、既存行の場合は元のctl_noを採用
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
                  treatClass: CODES.COMPLAINT_TREAT_CLASS.ELECTRO.cd,
                  electrocardiogramStart: dateFormat.format(model.startDate, "yyyyMMdd"),
                  overTime: startDate.diff(startDate.clone().startOf("date"), "minutes"),
                  isEditable: model.isEditable ? "1" : "0",
                  electrocardiogramType: 0
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
            electrocardiogramDataList.push(startComplaint);
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
                  treatClass: CODES.COMPLAINT_TREAT_CLASS.ELECTRO.cd,
                  overTime: model.overTime,
                  linkStartDate: previousCtlNo?.toString() || null, // 対応する酸素吸入開始のctl_noをStringに変換してセット
                  isEditable: model.isEditable ? "1" : "0",
                  electrocardiogramType: 1
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
            electrocardiogramDataList.push(endComplaint);
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
          if (item.treatmentList?.[0]?.treatClass === 4) {
            electrocardiogramDataList.push(item);
          }
        })
        // 削除行を愁訴処置データから除外する
        complaintData = complaintData.filter(
          (e) =>
            e.complaint.ctlNo !== deleteCtlNo &&
            !e.treatmentList.some((element) => element.ctlNo === deleteCtlNo)
        );

        operateFlg = "electrocardiogramDelete";
        // 編集前、編集中modelから最後の要素削除
        // this.removeLastElement();
        EventBus.$on('deleteOxygenOrElectrocardiogram', this.removeLastElement)
      }

      // ソートしてストアに設定
      this.setComplaintData(complaintData.sort((a, b) => a.compareTo(b)));
      // 親の保存イベントを呼びだす
      EventBus.$emit("saveCompTreatCreate", electrocardiogramDataList, operateFlg);

      // 保存時はモーダルを非表示にする
      // if (flag === 0) {
      //   setTimeout(() => { // 親画面のリスト更新の画面ちらつき回避
      //     this.hideModal();
      //   }, 1000);
      // }
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
      return Promise.all([sendRequestGetMstPersonalUser(this.facilityCd), sendRequestMstGetJobs(this.facilityCd)]);
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
     * 経過時間 設定
     * @param {Number} index 表示中のModelのindex
     * @param {String} field 変更したフィールド名
     */
    setOverTime(index, field) {
      let startElectrocardiogramModal = null;
      let endElectrocardiogramModal = null;
      let endDate = null;
      if ("startDate" === field) {
        // 開始ブロック取得
        startElectrocardiogramModal = { ...this.actualModel[index] };
        // 終了日時取得
        if ((index + 1) < this.actualModel.length) {
          endElectrocardiogramModal = this.actualModel[index + 1];
          endDate = endElectrocardiogramModal.endDate;
        }
      } else {
        // 開始ブロック取得
        startElectrocardiogramModal = { ...this.actualModel[index - 1] };
        // 終了日時取得
        endElectrocardiogramModal = this.actualModel[index];
        endDate = endElectrocardiogramModal.endDate;
      }

      if (endElectrocardiogramModal) {
        // 経過時間の算出
        const overTime = this.calcOverTime(endDate, startElectrocardiogramModal);
        endElectrocardiogramModal.overTime = overTime;
      }
    },
    /**
     * 経過時間の算出
     * @param {*} endDate
     * @param {*} preElectrocardiogramModal
     */
    calcOverTime(endDate, preElectrocardiogramModal) {
      // パラメータが不足している場合は計算しない
      if (endDate === null || preElectrocardiogramModal.startDate === null) {
        return null;
      }
      const _startDate = moment(preElectrocardiogramModal.startDate);
      const _endDate = moment(endDate);
      // 開始日時と終了日時の差分を求める
      const diff = _endDate.diff(_startDate, "minutes");
      if (diff <= 0) {
        return null;
      }
      return diff;
    },
    /**
     * 開始 or 終了ブロック追加
     */
    addRow() {
      const createElectrocardiogramModal = (isStart, date, preElectrocardiogramModal) => {
        const electrocardiogramModal = new ElectrocardiogramModal(null, isStart, date);
        if (!isStart) {
          // 経過時間を算出
          electrocardiogramModal.overTime = this.calcOverTime(date, preElectrocardiogramModal);
        }
        return electrocardiogramModal;
      };

      const preElectrocardiogramModal = this.actualModel.at(-1);
      // 1つ前が開始の場合、終了ブロック追加、デフォルト日時に1つ前の開始日時以上を設定
      // 1つ前が終了の場合、開始ブロック追加、デフォルト日時に1つ前の終了日時以上を設定
      // 1つ前のブロックが開始かどうかを確認
      const preIsStart = preElectrocardiogramModal?.isStart || false;
      // デフォルト日時を設定
      const defaultDate = this.getDefaultDate(
        preIsStart
          ? preElectrocardiogramModal.startDate
          : preElectrocardiogramModal?.endDate || null
      );
      const electrocardiogramModal = createElectrocardiogramModal(!preIsStart, defaultDate, preElectrocardiogramModal);

      // 編集前データ
      this.initModel.push(JSON.parse(JSON.stringify(electrocardiogramModal)));

      // デフォルト値を設定
      // デフォルト開始/終了日時
      if (preIsStart) {
        electrocardiogramModal.endDate = defaultDate;
      } else {
        electrocardiogramModal.startDate = defaultDate;
      }
      // 処置者：サインインユーザー
      electrocardiogramModal.staff = new Master(this.getUserId(), this.getUserName());
      this.userNameValue.push({ initValue: "", editValue: electrocardiogramModal.staff.name });

      // 編集後データ
      this.actualModel.push(electrocardiogramModal);

      // 一番下にスクロールする
      this.$nextTick(() => {
        const scrollBody = document.getElementById("scrollbody");
        scrollBody.scrollTop = scrollBody.scrollHeight;
      });
    },
    /**
     * 経過時間のフォーマット
     */
    formatMinutes(minutes) {
      if (minutes === null) {
          return "";
      }
      const hours = Math.floor(minutes / 60);
      const remainingMinutes = minutes % 60;
      let result = ""
      if (hours > 0) {
          result += hours + "時間";
      }
      if (remainingMinutes > 0 || hours === 0) {
          result += remainingMinutes + "分";
      }
      return result;
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
      this.actualModel = this.getElectrocardiogramModal();

      // デフォルトブロック追加
      if (this.actualModel.length === 0) {
        // electrocardiogramModalsが空の場合は開始ブロックを追加
        const defaultDate = this.getDefaultDate(null);
        const electrocardiogramModal = new ElectrocardiogramModal(null, true, defaultDate);
        this.actualModel.push(electrocardiogramModal);
      } else {
        // electrocardiogramModalsの最後尾が開始日時の場合は終了ブロックを追加
        const preElectrocardiogramModal = this.actualModel.at(-1);
        if (preElectrocardiogramModal.isStart) {
          // 1つ前が開始の場合、終了ブロック追加
          // デフォルト日時に1つ前の開始日時以上を設定
          const defaultDate = this.getDefaultDate(preElectrocardiogramModal.startDate);
          const electrocardiogramModal = new ElectrocardiogramModal(null, false, defaultDate);
          // 経過時間を算出
          electrocardiogramModal.overTime = this.calcOverTime(defaultDate, preElectrocardiogramModal);

          this.actualModel.push(electrocardiogramModal);
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
.electro-table {
  width: 98%;
  padding-left: 10px;
}
.electro-table tr {
  position: relative;
}
.electrocardiogram-tb-content {
  border-bottom: 1px solid #cccccc;
  padding: 10px;
}
.electrocardiogram-tb-content >>> ons-row {
  flex-wrap: nowrap;
}
.electrocardiogram-tb-content >>> ons-col.title {
  /* treatment-record-accordion 関連設定の幅だけ上書きする */
  flex: 0 0 20%;
  min-width: 5em;
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
