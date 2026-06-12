/**
 * 処方箋-一括交付済み変更モーダル
 */
<template>
  <div class="modal-mask">
    <div class="modal-wrapper">
      <div class="modal-container">
        <div class="modal-header">
          <ons-toolbar>
            <div class="left toolbar__title">
              <span class="modal-title">一括交付済み変更</span>
            </div>
            <div class="right">
              <ons-toolbar-button class="close-btn print-none" @click="cancel">
                <ons-icon icon="fa-times"></ons-icon>
              </ons-toolbar-button>
            </div>
          </ons-toolbar>
        </div>
        <div class="modal-search">
        </div>
        <div class="modal-body" >
          <div class="conf-modal">
          <table>
            <tbody>
              <tr >
                <td >
                  <label>指定日の未交付処方を交付済みにします。</label>
                </td>
              </tr>
              <tr >
                <td class="input-warning-col" align="top">
                  <span class="icon-exclamation"><v-ons-icon icon="fa-exclamation-triangle"/></span>
                  <label>交付済にする処方内容を確認してから保存してください。</label>
                </td>
              </tr>
            </tbody>
          </table>
          <br>
          <table>
            <tbody>
              <tr >
                <td colspan=2>
                  <label>交付済にする処方日と保険医を指定してください。</label>
                </td>
              </tr>
              <tr >
                <td style="white-space: nowrap; width:4.0em">
                  <span>・処方日</span>
                </td>
                <td>
                  <date-input
                    v-model='issueDate'
                    :classes="'input-area ntss-input-date ntss-custom-input start-date'"
                    style="width:75%"
                    isRequired
                    />
                  <common-calendar
                    v-model="issueDate"
                    class="calender start-date-comment"
                    />
                </td>
              </tr>
              <tr >
                <td ></td>
                <td>
                  <label>対象処方件数：{{count}}件</label>
                </td>
              </tr>
            </tbody>
          </table>
          <br>
          <table>
            <tbody>
              <tr >
                <td >
                  <label>・保険医</label>
                </td>
              </tr>
            </tbody>
          </table>
          <table>
            <tbody>
              <tr >
                <td class="modal-radio">
                    <v-ons-radio
                      name="radiogroupDispTerm"
                      value="1"
                      modifier="round"
                      v-model="selectedPreDoctor"
                    />
                  </td>
                  <td >
                    指定済みの保険医はそのままに、未指定の場合は次の保険医で登録する
                  </td>
              </tr>
              <tr >
                <td class="modal-radio">
                    <v-ons-radio
                      name="radiogroupDispTerm"
                      value="2"
                      modifier="round"
                      v-model="selectedPreDoctor"
                    />
                </td>
                <td >
                    新たに保険医を指定する
                </td>
              </tr>
              <tr >
                <td class="modal-dropdownlist" colspan="2">
                  <kendo-dropdownlist
                    v-model="selectedItem"
                    :data-source="items"
                    :data-text-field="'fullName'"
                    :data-value-field="'user_id'"
                    style="min-width:150px;width:auto; height: 2em; margin-right: 5px; font-size:1.0em">
                  </kendo-dropdownlist>
                </td>
              </tr>
            </tbody>
          </table>

          </div>
        </div>
        <div class="modal-footer">
          <v-ons-bottom-toolbar>
          <div class="flex-container">
            <div class="">
              <v-ons-button class="btn2-cancel common-style-cancel-button" @click="cancel">
                キャンセル
              </v-ons-button>
            </div>
            <div class="">
              <v-ons-button class="btn3-normal common-style-ok-button" @click="confirm" v-bind:disabled="isCountZero">
                保存
              </v-ons-button>
            </div>
          </div>
          </v-ons-bottom-toolbar>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters, mapActions, mapMutations } from "@/compat/vue/vuex";

import MultiModalMixin from "@/components/modals/MultiModalMixin";
import UserAuthorityMixin from "@/components/common/UserAuthorityMixin";
import IndUserSelectMixin from "@/components/common/IndUserSelectMixin";
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from '@/functions/common/MessageFormat';
import { sendRequestGetPatPrescriptionCount, sendRequestGetOrdPrescriptionNoList, updateIssueState } from "@/apis/pat-prescription";
import { formatDatetime } from "@/functions/common/CommonFunctions.js";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
import DateInput from "@/components/common/DateInput.vue";
import { deepCopy } from "@/functions/common/CommonFunctions";

export default {
  mixins: [UserAuthorityMixin,MultiModalMixin,IndUserSelectMixin],
  components: {
      "common-calendar": commonCalender,
      "date-input":DateInput,
    },
  data() {
    const defaultCondition = {
      viewPatId: true,
      viewDateInfo: true,
      searchDate: "",
      viewPreIn: true,
      viewPreOut: true,
      issueDate: "",
      reSearchCount: 0
    };
    return {
      // 権限設定
      authorityCds: [ AUTHORITY_CODES.PRESCRIPTION_PEDIT, AUTHORITY_CODES.PRESCRIPTION_EDIT ],
      items: [
      ],
      selectedItem: '',
      selectedPreDoctor: '1',
      issueDate: '',
      count: '0',
      condition: {
        ...defaultCondition
      }
    };
  },
  computed: {
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("pat-info", ["searchedPatList", "selectedPatId"]),
    ...mapGetters("prescription/list", [
      "getCondition"
    ]),
    // 変更フラグ
    isCountZero() {
      return this.count === 0;
    }
  },
  watch : {
    'issueDate'() {
      this.calCount();
    },
  },
  methods: {
    ...mapMutations("prescription/list", [
      "incrementReSearchCount"
    ]),
    ...mapActions("prescription/list", [
      "setCondition"
    ]),
    cancel() {
      /**
      * キャンセルボタン押下時イベント処理
      */
      this.hideModal();
    },
    async calCount() {
      // 対象処方件数取得(交付日変更時)
      const changeIssueDate = this.issueDate;
      let patIdList = this.searchedPatList.map(x => x.pat_id).filter(y => y);
      let newIssueDate = formatDatetime(changeIssueDate, "YYYYMMDD");
      let prescriptionCount = await sendRequestGetPatPrescriptionCount(patIdList, newIssueDate, this.getFacilityCd).then(result => result.data);
      this.count = prescriptionCount;
    },
    async confirm(){
      try {
        // 交付状態更新
        let patIdList = this.searchedPatList.map(x => x.pat_id).filter(y => y);
        let newIssueDate = formatDatetime(this.issueDate, "YYYYMMDD");
        let ordPrescriptionNoList = await sendRequestGetOrdPrescriptionNoList(patIdList, newIssueDate, this.getFacilityCd).then(result => result.data);
        let newOrdPrescriptionNoList = ordPrescriptionNoList.map(function (item) {
          return item['ordPrescriptionNo'];
        });
        let insuDrId = this.selectedItem;
        let prescriptionCount = await sendRequestGetPatPrescriptionCount(patIdList, newIssueDate, this.getFacilityCd).then(result => result.data);
        if(prescriptionCount === 0){
          getErrorMessage('PrescriptionConfModalComponent.vue', 'updateIssueState', '該当データが存在していません。');
          this.$ons.notification.alert({
            title: DIALOG_MESSAGES['00200123'].title,
            message: messageFormat(DIALOG_MESSAGES['00200123'].message)
          });
        }else{
          await updateIssueState(newOrdPrescriptionNoList, insuDrId, this.selectedPreDoctor, this.getFacilityCd).then(result => result.data);
          this.hideModal();
          this.incrementReSearchCount();
          this.setCondition(deepCopy(this.getCondition));
        }
      } catch (error) {
        getErrorMessage('PrescriptionConfModalComponent.vue', 'updateIssueState', 'システムエラーが発生しました。');
        this.$ons.notification.alert({
          title: DIALOG_MESSAGES['00200153'].title,
          message: messageFormat(DIALOG_MESSAGES['00200153'].message)
        });
      }
    }
  },
  async created() {
      // 対象処方件数取得(ダイアログ表示時)
      let patIdList = this.searchedPatList.map(x => x.pat_id).filter(y => y);
      let newIssueDate = formatDatetime(this.getCondition.searchDate, "YYYYMMDD");
      let prescriptionCount = await sendRequestGetPatPrescriptionCount(patIdList, newIssueDate, this.getFacilityCd).then(result => result.data);
      this.count = prescriptionCount;
  },
  mounted() {
    // 指示者ドロップダウンの設定
    this.getIndUserList(AUTHORITY_CODES.PRESCRIPTION_EDIT, AUTHORITY_CODES.PRESCRIPTION_PEDIT)
    .then(response => {
      this.items = response.doctorList;
      this.$nextTick(() => {
        this.selectedItem = response.iniSelectId;
      });
    });
    // 処方日:一覧画面指定日をセット
    this.issueDate = this.getCondition.searchDate;
  }
}
</script>

<style scoped>
@import "../../assets/styles/modal.css";

/* 印刷時スタイル */
@media print {
  .print-none {
    display: none;
  }
}
/*
 * TODO 以下のように、cssのパスをエイリアスで設定できるようにしたい。
 * @import "@/assets/styles/modal.css";
 *
 * webpackでエイリアスを設定すればできそう。
 * https://vue-loader-v14.vuejs.org/ja/configurations/asset-url.html
 */

.modal-container {
  width: 68%;
  height: 68%;
}

.modal-body {
  position: absolute;
  top: 50px;
  width: 100%;
  height: calc(100% - 10em);
  overflow-y: auto;
}

.conf-modal{
  margin-left:1.0em;
  font-size:1em;
}

.modal-footer {
  position: absolute;
  width: 100%;
  bottom: 0px;
}

.input-warning-col{
  color:red;
}

.icon-exclamation{
  font-size:2.0em;
  vertical-align:middle;
}

.modal-radio{
  padding-left:2.0em;
  width:2.0em;
}

.modal-dropdownlist{
  padding-left:2.0em;
}

.modal-title{
  font-size:1.2em;
}

.denial-btn-area .registration-btn-area{
  background:none;
}

/* 横幅550px以上1024px以下 ならスタイル変更 */
@media screen and (min-width:551px) and (max-width: 1024px){
  .modal-container {
    width: 75%;
    height: 75%;
  }
}

/* 横幅550px以下 ならスタイル変更 */
@media screen and (max-width: 550px){
  .modal-container {
    width: 88%;
    height: 88%;
  }
}
:deep(.k-legacy-dropdownlist.k-dropdownlist.k-picker > .k-input-button.k-select, .k-dropdownlist.k-picker.k-legacy-dropdownlist > .k-input-button.k-select){
  position: relative !important;
}
</style>
