/**
 * 処方箋-一括処方モーダル
 */
<template>
  <div class="modal-mask">
    <div class="modal-wrapper">
      <div class="modal-container">
        <div class="modal-header">
          <ons-toolbar>
            <div class="left toolbar__title">
              <!-- mod #10184 処方画面文言修正 宮崎 start -->
              <span class="modal-title">一括処方コピー</span>
              <!-- mod #10184 処方画面文言修正 宮崎 end -->
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
          <table >
            <tbody>
              <tr >
                <td >
                  <label>患者ごとにチェックした過去処方を複製します。</label>
                </td>
              </tr>
              <tr >
                <td class="input-warning-col" align="top">
                  <span class="icon-exclamation"><v-ons-icon icon="fa-exclamation-triangle"/></span>
                  <label>複製する過去処方内容を確認してから保存してください。</label>
                </td>
              </tr>
            </tbody>
          </table>
          <table>
            <tbody>
              <tr >
                <td  >
                  <label>対象患者数：{{count}}件</label>
                </td>
              </tr>
            </tbody>
          </table>
          <br>
          <table >
            <tbody>
              <tr >
                <td colspan=2>
                  <label>新たに作成する処方条件を指定してください。</label>
                </td>
              </tr>
              <tr >
                <td style="white-space: nowrap; width:4.0em">
                  <span >・処方日</span>
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
            </tbody>
          </table>
          <table >
            <tbody>
              <tr >
                <td  >
                  <!-- mod #10184 処方画面文言修正 宮崎 start -->
                  <label>・保険医</label>
                  <!-- mod #10184 処方画面文言修正 宮崎 end -->
                </td>
              </tr>
            </tbody>
          </table>
          <table>
            <tbody>
              <tr>
                <td class="modal-radio">
                    <v-ons-radio
                      name="radiogroupDispTerm"
                      value="1"
                      modifier="round"
                      v-model="selectedPreDoctor"
                    />
                  </td>
                  <!-- mod #10184 処方画面文言修正 宮崎 start -->
                  <td colspan="2">
                  複製する処方の保険医を継承する
                  </td>
                  <!-- mod #10184 処方画面文言修正 宮崎 end -->
              </tr>
              <tr>
                <td class="modal-radio">
                    <v-ons-radio
                      name="radiogroupDispTerm"
                      value="2"
                      modifier="round"
                      v-model="selectedPreDoctor"
                    />
                </td>
                <!-- mod #10184 処方画面文言修正 宮崎 start -->
                <td>
                    新たに保険医を指定する
                </td>
                <!-- mod #10184 処方画面文言修正 宮崎 end -->
              </tr>
              <tr >
                <td class="modal-dropdownlist" colspan="2">
                  <kendo-dropdownlist
                    v-model="selectedItem"
                    :disabled="isOrderSelectDoctor"
                    :data-source="items"
                    :data-text-field="'fullName'"
                    :data-value-field="'user_id'"
                    style="min-width:150px;width:auto; height: 2em; margin-right: 5px; font-size:1.0em">
                  </kendo-dropdownlist>
                </td>
              </tr>
            </tbody>
          </table>
          <table>
            <tbody>
              <tr>
                <td>
                  <label>・保存形式選択</label>
                </td>
              </tr>
            </tbody>
          </table>
          <table>
            <tbody>
              <tr>
                <td class="modal-radio">
                    <v-ons-radio
                      name="radiogroupSaveMode"
                      value="0"
                      modifier="round"
                      v-model="selectedSeveMode"
                    />
                  </td>
                  <td>
                  未交付保存
                  </td>
              </tr>
              <tr>
                <td class="modal-radio">
                    <v-ons-radio
                      name="radiogroupSaveMode"
                      value="1"
                      modifier="round"
                      v-model="selectedSeveMode"
                    />
                </td>
                <td>
                交付済み保存
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
              <v-ons-button class="btn3-normal common-style-ok-button" @click="insertData" v-bind:disabled="isCountZero">
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
import { mapGetters, mapMutations, mapActions } from "@/compat/vue/vuex";
import UserAuthorityMixin from "@/components/common/UserAuthorityMixin";
import IndUserSelectMixin from "@/components/common/IndUserSelectMixin";
import MultiModalMixin from "@/components/modals/MultiModalMixin";
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from '@/functions/common/MessageFormat';
import { sendRequestSaveCopyPrescription } from "@/apis/pat-prescription";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import { deepCopy } from "@/functions/common/CommonFunctions";

import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
import DateInput from "@/components/common/DateInput.vue";
import { getContentContainerElement, getScopedWindow } from "@/functions/common/LayoutMeasureHelper";

export default {
  mixins: [UserAuthorityMixin,MultiModalMixin,IndUserSelectMixin],
  components: {
      "common-calendar": commonCalender,
      "date-input":DateInput,
    },
  data() {
    return {
      // 権限設定
      authorityCds: [ AUTHORITY_CODES.PRESCRIPTION_PEDIT, AUTHORITY_CODES.PRESCRIPTION_EDIT ],
      items: [
      ],
      selectedItem: "",
      issueDate: "",
      selectedPreDoctor: "1",
      selectedSeveMode: "0" // 未交付保存
    };
  },
  computed: {
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("prescription/list", [
    "getCondition",
    "getOrdPreNo"
    ]),
    count() {
      return Array.isArray(this.getOrdPreNo) ? this.getOrdPreNo.length : 0;
    },
    isOrderSelectDoctor() {
      // 画面からデータを取得
      if(this.selectedPreDoctor == '2'){
        return false;
      }else{
        return true;
      }
    },
    // 変更フラグ
    isCountZero() {
      return this.count === 0;
    }
  },

  methods: {
    ...mapMutations("prescription/list", [
      "incrementReSearchCount"
    ]),
    ...mapActions("prescription/list", [
      "setOrdPreNo",
      "setCondition"
    ]),
    /**
     * キャンセルボタン押下時イベント処理
     */
    cancel() {
      this.hideModal();
    },
    getPrintContentContainer() {
      return getContentContainerElement(this.$el || null);
    },
    /**
     * 登録ボタン押下時イベント処理
     */
    async insertData() {
      const ordPrescriptionNoList = this.getOrdPreNo;
      if(!this.Validate(ordPrescriptionNoList)){
        return
      }
      const insuDrId = this.selectedPreDoctor === "2" ? this.selectedItem: null;
      const issueState = this.selectedSeveMode;
      const issueDate = this.issueDate.replace(/-/g, '');
      try {
        await sendRequestSaveCopyPrescription(ordPrescriptionNoList, insuDrId, issueState, issueDate, this.selectedPreDoctor);
      } catch (error) {
        getErrorMessage('PrescriptionConfModalComponent.vue', 'sendRequestSaveCopyPrescription', 'システムエラーが発生しました。');
        this.$ons.notification.alert({
          title: DIALOG_MESSAGES['00200153'].title,
          message: messageFormat(DIALOG_MESSAGES['00200153'].message)
        });
        return;
      }
      this.hideModal();
      this.setOrdPreNo([]);
      this.incrementReSearchCount();
      this.setCondition(deepCopy(this.getCondition));
    },
    /**
     * 入力チェック
     */
    Validate(ordPrescriptionNoList) {
      let msg;
      if (ordPrescriptionNoList.length === 0){
        msg = "処方が選択されていません。";
      } else if(!this.issueDate){
        msg = "処方日を選択してください。";
      }
      if(msg){
        this.$ons.notification.alert({
            title: "",
            message: DIALOG_MESSAGES[30000004].message.replace(/{\$\d*}/, msg)
          });
        return false;
      }
      return true;
      }
  },

  async created() {
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
    
    const ownerWindow = getScopedWindow(this.$el || null);
    this._printOwnerWindow = ownerWindow;
    this._previousOnBeforePrint = ownerWindow?.onbeforeprint || null;
    this._previousOnAfterPrint = ownerWindow?.onafterprint || null;
    if (!ownerWindow) {
      return;
    }
    ownerWindow.onbeforeprint = () => {
        this._previousOnBeforePrint?.();
        //印刷不要な要素を非表示にする
        const contentContainer = this.getPrintContentContainer();
        if (contentContainer) {
          contentContainer.style.display = 'none';
        }
      };
      ownerWindow.onafterprint = () => {
        //隠し要素を放す
        const contentContainer = this.getPrintContentContainer();
        if (contentContainer) {
          contentContainer.style.display = 'block';
        }
        this._previousOnAfterPrint?.();
      };
  },
  beforeUnmount () {
    const ownerWindow = this._printOwnerWindow || getScopedWindow(this.$el || null);
    if (ownerWindow) {
      ownerWindow.onbeforeprint = this._previousOnBeforePrint || null;
      ownerWindow.onafterprint = this._previousOnAfterPrint || null;
    }
    this._printOwnerWindow = null;
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
