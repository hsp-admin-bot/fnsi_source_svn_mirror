/**
 * 利用者マスタメンテナンスデータページ  MainContent
 */
<template>
  <div class='main-content-area master-maintenance-page'>
    <div class='ntss-list' :style="ntssListStyles" v-kendo-validator="kendoValidatorSetup">
      <kendo-grid-toolbar :class="['k-grid-toolbar', 'kendo-grid-toolbar-style', { 'no-scroll': isMobileDevice }]" :style="heightStyles">
        <div class="header-btn-area" style="display: flex; align-items: center; gap: 1em;">
          <v-ons-button class="btn3-normal toolbar-btn" @click="dispModalAddUser()">追加</v-ons-button>
          <div v-show="isMobileDevice" style="display: flex; align-items: center; min-width: 7em; height: 2em;">
            <label class="fab-font-color" style="margin-right: 0.5em;">編集</label>
            <v-ons-switch modifier="outline" class="custom-switch" v-model="allowEdit" />
          </div>
        </div>
        <kendo-grid ref="grid" :class="fontSizeSet" style="clear: both;"
            :data-source="masterRecords"
            :editable="true"
            :selectable="true"
            :reorderable="false"
            :height=kendoGridHeight
            :scrollable="true"
            :beforeEdit=onBeforeEdit
            :cellClose=editEnd
            @save="onSave"
            @databound="onDataBoundKendoGrid">
            <template v-for="(column, index) in columns" >
              <kendo-grid-column v-if="column.title === '管理者'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="column.hidden"
                :attributes="{ class: 'btn1-kendo-execute' }"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values"
                :command="{ text: '管理者', click: changeAdmin }">
              </kendo-grid-column>
              <kendo-grid-column v-else-if="column.title === '使用許可機能'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="column.hidden"
                :attributes="{ class: 'btn3-kendo-normal' }"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values"
                :command="{ text: '設定', click: dispModalUseFunction }">
              </kendo-grid-column>
              <kendo-grid-column v-else-if="column.title === '編集権限'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="column.hidden"
                :attributes="{ class: 'btn3-kendo-normal' }"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values"
                :command="{ text: '編集権限', click: dispModalEditAuthority }">
              </kendo-grid-column>
              <kendo-grid-column v-else-if="column.title === 'ID/PWリセット'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="column.hidden"
                :attributes="{ class: 'btn4-kendo-alert' }"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values"
                :command="{ text: 'リセット', click: dispModalIdReset }">
              </kendo-grid-column>
              <!-- add 追加患者共有 楊zc start -->
              <kendo-grid-column v-else-if="column.title === '患者共有'"
               :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="true"
                :attributes="{ class: 'btn3-kendo-normal' }"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values"
                :command="{ text: '表示', click: changePatientSharedReset }">
              </kendo-grid-column>
              <!-- add 追加患者共有 楊zc end -->
              <kendo-grid-column v-else-if="column.title === 'ロック解除'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="column.hidden"
                :attributes="{ class: 'btn3-kendo-normal' }"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values"
                :command="{ text: '解除', click: resetLoginFailCnt }">
              </kendo-grid-column>
              <kendo-grid-column v-else-if="column.title === '削除'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="column.hidden"
                :attributes="{ class: 'btn4-kendo-alert' }"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values"
                :command="{ text: '削除', click: delUser }">
              </kendo-grid-column>
              <kendo-grid-column v-else-if="column.title === '職種'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="column.hidden"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values">
              </kendo-grid-column>
              <kendo-grid-column v-else-if="column.title === 'カード作成'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :attributes="{ class: 'btn3-kendo-normal' }"
                :hidden="hiddenDispCreateCard ? true : !isCardDeviceConnected"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values"
                :command="{ text: 'カード作成', click: createCard }">
              </kendo-grid-column>
              <kendo-grid-column v-else-if="column.title === 'カード無効化'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="column.hidden"
                :attributes="{ class: 'btn4-kendo-alert' }"
                :editable="column.values"
                :width="column.width"
                :format="column.format"
                :values="column.values"
                :command="{ text: '無効化', click: disableCard }">
              </kendo-grid-column>
              <kendo-grid-column v-else-if="column.title === '利用者カナ名_姓'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="isRemsOnly"
                :editable="() => isOwnFacility"
                :width="column.width"
                :format="column.format"
                :values="column.values">
              </kendo-grid-column>
              <kendo-grid-column v-else-if="column.title === '利用者カナ名_名'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="isRemsOnly"
                :editable="() => isOwnFacility"
                :width="column.width"
                :format="column.format"
                :values="column.values">
              </kendo-grid-column>
              <kendo-grid-column v-else-if="column.title === '利用者英字名_姓'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="isRemsOnly"
                :editable="() => isOwnFacility"
                :width="column.width"
                :format="column.format"
                :values="column.values">
              </kendo-grid-column>
              <kendo-grid-column v-else-if="column.title === '利用者英字名_名'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="isRemsOnly"
                :editable="() => isOwnFacility"
                :width="column.width"
                :format="column.format"
                :values="column.values">
              </kendo-grid-column>
<!--                add #9584 2023-9-8 lmf start-->
              <kendo-grid-column v-else-if="column.title === 'メールアドレス1'"
                                 :key="index"
                                 :title="column.title"
                                 :field="column.field"
                                 :hidden="isRemsOnly"
                                 :editable="column.editable"
                                 :width="column.width"
                                 :format="column.format"
                                 :values="column.values">
              </kendo-grid-column>
              <kendo-grid-column v-else-if="column.title === 'メールアドレス2'"
                                 :key="index"
                                 :title="column.title"
                                 :field="column.field"
                                 :hidden="isRemsOnly"
                                 :editable="column.editable"
                                 :width="column.width"
                                 :format="column.format"
                                 :values="column.values">
              </kendo-grid-column>
<!--                add #9584 2023-9-8 lmf end-->
              <kendo-grid-column v-else-if="column.title === '内線番号'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="isRemsOnly"
                :editable="() => isOwnFacility"
                :width="column.width"
                :format="column.format"
                :values="column.values">
              </kendo-grid-column>
              <kendo-grid-column v-else-if="column.title === '自宅番号'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="isRemsOnly"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values">
              </kendo-grid-column>
              <kendo-grid-column v-else-if="column.title === '携帯番号'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="isRemsOnly"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values">
              </kendo-grid-column>
              <kendo-grid-column v-else-if="column.title === 'FAX番号'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="isRemsOnly"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values">
              </kendo-grid-column>
              <kendo-grid-column v-else-if="column.title === '郵便番号7'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="isRemsOnly"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values">
              </kendo-grid-column>
              <kendo-grid-column v-else-if="column.title === '自宅住所'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="isRemsOnly"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values">
              </kendo-grid-column>
              <kendo-grid-column v-else-if="column.title.indexOf('連携コード') > -1"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="isRemsOnly"
                :editable="() => isOwnFacility"
                :width="column.width"
                :format="column.format"
                :values="column.values">
              </kendo-grid-column>
              <kendo-grid-column v-else-if="column.title === '秘密鍵'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="column.hidden"
                :attributes="{ class: 'btn4-kendo-alert' }"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values"
                :command="{ text: '廃棄', click: deleteKey }">
              </kendo-grid-column>
              <kendo-grid-column v-else-if="column.title === 'サインイン日時'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="column.hidden"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values">
              </kendo-grid-column>
              <kendo-grid-column v-else
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="column.hidden"
                :locked="column.locked"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values">
              </kendo-grid-column>
            </template>
        </kendo-grid>
      </kendo-grid-toolbar>
      <!-- 高さ調整 -->
      <div id="grid-footer"></div>
      <div v-if="messageDialogInfo.isDialogVisible">
      <message-dialog
        :visible.sync="messageDialogInfo.isDialogVisible"
        :message-cd="messageDialogInfo.messageCd"
        :type="messageDialogInfo.type"
        :string-params="messageDialogInfo.stringParams"
        @confirm="confirm"
      />
      </div>
    </div>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "vuex";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import { Validator } from "@progress/kendo-validator-vue-wrapper";
import messageDialog from "@/components/common/message-dialog/MessageDialog";
import { EventBus } from "@/eventBus.js";
import $$ from "jquery";
import { sendRequestGetMstFacilityHashByFacilityCd } from "@/apis/mst-facility-hash";
// add 2020-09-25 FNSI-4200ポートを使用している 孫 start
import { ApiHelper } from "@/apis/AxiosHelper";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
// add 2020-09-25 FNSI-4200ポートを使用している 孫 end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
// add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen start
import { getMstJob } from "@/functions/mst/MstGetters.js";
import { MSG_SETTING_REFLECTION } from "@/constants/masterMaintenanceConstants";
import { sendRequestGetMstFacilitySettingValue } from "@/apis/facility-setting";
import { PERMISSION_CHANGE_SIGNOUT } from "@/constants/facilitySetting";
// add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen end

// add 2020-09-25 FNSI-4200ポートを使用している 孫 start
const uriGetCardAppPort = `/card_state/get_card_app_ports`;
// add 2020-09-25 FNSI-4200ポートを使用している 孫 end
export default {
  components: {
    "message-dialog": messageDialog
  },
  mixins: [NextTransitionMixin, MasterMaintenanceMixin],
  Validator,
  data() {
    return {
      // 初期状態で1列がないとその後の表示が行われないため初期列を定義
      columns: [
        {
          field: "code",
          title: "code",
          hidden: false,
          editable: () => true,
          values: null
        }
      ],
      condition: {
        recordName: ""
      },
      kendoGridToolbarHeight: 500,
      kendoGridHeight: 300,
      columnWidth: 14,
      kendoValidatorSetup: {
        rules: {},
        messages: {}
      },
      facilitylistValue: "",
      messageDialogInfo: {
        isDialogVisible: false,
        messageCd: "",
        type: "1",
        stringParams: [""]
      },
      delUserId: -1,
      //Android端末で編集中であることを示すフラグ
      editingFlg: false,
      androidFlg: false,
      iosFlg: false,
      //自画面の名称
      selfScreenName: "",
      isCardDeviceConnected: false,
      socketInterval: null,
      // 選択施設のシステム利用設定
      facilitySysUseSetting: "",
      // add #9764  by zhangruixue 2023-09-04 --start
      failureCnt: 5,
      accountLockSetting: 1,
      // add #9764  by zhangruixue 2023-09-04 --end
      // 追加フラグ
      addFlg: false,
      tmpAddFlg: false,
      // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen start
      allMstJob: [],
      mstJobBeforeChange: [],
      signoutFlg: false,
      // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen end
      // スクロール位置
      scrollPosition: {
        top: 0,
        left: 0
      },
      allowEdit: true, // NOTE: true = 編集モード、 false = 閲覧モード
    };
  },
  computed: {
    // #8745 【デグレ】マスタにて追加をし行が増えると縦横のスクロールが発生する。テキストボックスが切れる。 林峻峰 start
    // ...mapGetters("master-maintenance", ["getFacilitySwitch"]),
    ...mapGetters("master-maintenance", {
      getFacilitySwitch: "getFacilitySwitch",
      masterPhysicalName: "getMasterName",
    }),
    // #8745 【デグレ】マスタにて追加をし行が増えると縦横のスクロールが発生する。テキストボックスが切れる。 林峻峰 end
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth"
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo"
    }),
    ...mapGetters("user", {
      getSystemUseSetting: "getSystemUseSetting",
      facilityCd: "getFacilityCd",
      getAccountLockSetting: "getAccountLockSetting",
      getFailureCnt: "getFailureCnt"
    }),
    ...mapGetters("websocket-card", ["getSocketIsConnected", "getSocketMessages", "getCardDeviceStatus"]),
    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.kendoGridToolbarHeight}px` };
    },
    ntssListStyles() {
      return { display: this.columns.length === 1 ? "none" : "inherit" };
    },
    ...mapGetters("mst-user", {
      getFilteredMasterRecordList: "getFilteredMasterRecordList",
      getIsDispCreateCard: "getIsDispCreateCard"
    }),
    ...mapGetters("mst-facility-setting",{ getValueSignIn: "getValueSignIn" }),
    ...mapGetters("mst-user", { getUserOTP: "getUserOTP" }),
    masterRecords() {
      // storeからデータを取得
      return this.getFilteredMasterRecordList;
    },
    hiddenDispCreateCard() {
      return this.getIsDispCreateCard ? false : true;
    },
    isOwnFacility() {
      return this.facilitylistValue === this.getStateUserAccountInfo.facilityCd;
    },
    isRemsOnly() {
      return this.getSystemUseSetting === "1";
    },
    //バリューサインインを取得
    valueSignIn(){
      return this.getValueSignIn;
    },
    //ユーザーOTPの取得
    userOTP(){
      return this.getUserOTP;
    },
    isMobileDevice() {
      return this.iosFlg || this.androidFlg;
    },
  },
  watch: {
    windowHeight() {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
    },
    windowWidth() {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
    },
    isDispMenu() {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
    },
    getFontSize() {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
    },
    getSocketIsConnected(value) {
      this.isCardDeviceConnected = false;
      if (!value === true) {
        // 再接続
        this.reconnectSocket();
      } else {
        clearInterval(this.socketInterval);
      }
    },
    getSocketMessages(value) {
      if (value == null) return;
      const splitMsg = value.split("\t");
      if (splitMsg.length > 1) {
        if (splitMsg[0] == "CARD_CLIENT") {
          switch(splitMsg[1]) {
            case "CARD_READER_STATUS":
              this.isCardDeviceConnected = JSON.parse(splitMsg[2].toLowerCase());
              this.clearSocketMessage();
              break;
            case "CARD_WRITE_STATUS":
              this.setLoadingScreenVisible(false);
              if (JSON.parse(splitMsg[2].toLowerCase()) == true) {
                this.$ons.notification.alert({
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                  // title: "保存成功",
                  // message: "カード情報が</br>保存されました。"
                  title: DIALOG_MESSAGES[12000291].title,
                  message: messageFormat(DIALOG_MESSAGES[12000291].message)
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                });
                this.findList();
              } else {
                this.$ons.notification.alert({
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                  // title: "保存失敗",
                  // message: "カードの書き込みに失敗しました。"
                  title: DIALOG_MESSAGES["00200103"].title,
                  message: messageFormat(DIALOG_MESSAGES["00200103"])
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                });
              }
              this.clearSocketMessage();
              break;
          }
        }
      }
    },
    columns:function(val){
      this.$nextTick(function(){
        if (val.length > 1)
        this.setLoadingScreenVisible(false);
      });
    }
  },
  methods: {
    ...mapActions("multi-modal", [
      "showUserMasterIdReset",
      "showUserMasterAuthFunction",
      "showUserMasterEditAuthority"
    ]),
    ...mapActions("mst-user", [
      "getUserDataList",
      "facilityList",
      "setCondition",
      "sendRequestAddNewUser",
      "sendRequestUpdateAdministratorFlg",
      "sendRequestUpdatePatientSharedFlg",
      "sendRequestUpdatePassword",
      "sendRequestUpdateFailureCnt",
      "sendRequestDeleteUser",
      "setUserData",
      "mstJobList",
      "sendRequestUpdateJobCd",
      "getDispCreateCard",
      "sendRequestUpdateUserPersonalInfo",
      "sendRequestDisableAccessCard",
      "sendRequestDeleteSecretKey"
    ]),
    ...mapActions("account-edit", [
      "clearCard",
      "setCard",
      "getUserAccountInfo"
    ]),
    // mod FNSI-4200ポートを使用している 孫 start
    //...mapActions("websocket-card", ["connect", "sendSocketMessage", "close", "clearSocketMessage"]),
    ...mapActions("websocket-card", ["init", "connect", "sendSocketMessage", "close", "clearSocketMessage"]),
    // mod FNSI-4200ポートを使用している 孫 end
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),
    ...mapActions("mst-facility-setting", ["sendRequestGetValueSignInByFacilityCd"]),
    ...mapActions("mst-user",["sendRequestCreateMstUserOTP",
                              "sendRequestUpdateSecretKey",
                              "sendRequestUpdateIsSetQrCode"]),
    reconnectSocket() {
      const param = this;
      this.socketInterval = setInterval(function(){
        param.connect();
        clearInterval(this.socketInterval);
      }, 10000);
    },
    async systemUseSetting() {
      if (this.facilitylistValue) {
        // 施設のシステム利用設定を取得する
        const mstFacilityHash = await sendRequestGetMstFacilityHashByFacilityCd(this.facilitylistValue);
        this.facilitySysUseSetting = mstFacilityHash.data.systemUseSetting ? mstFacilityHash.data.systemUseSetting : "";
        /* add #9764  by zhangruixue 2023-09-04 --start */
        this.failureCnt = mstFacilityHash.data.failureCnt ? mstFacilityHash.data.failureCnt : 5;
        this.accountLockSetting = mstFacilityHash.data.accountLockSetting ? mstFacilityHash.data.accountLockSetting : 1;
        /* add #9764  by zhangruixue 2023-09-04 --end */
      } else {
        this.facilitySysUseSetting = ""
      }
    },
    // マスタ一覧のデータを取得
    findList() {
      // 選択施設のシステム利用設定を設定
      this.systemUseSetting();

      // apiをコールして利用者マスタの値を取得
      this.getUserDataList(this.facilitylistValue)
        // mod #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen end
        // .then(response => {
        .then(async response => {
        // mod #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen end
          // editableをKendoUI用にfunctionオブジェクトに変換
          const toFunction = response.data.columns;
          toFunction.forEach(column => {
            // 編集可否を関数化
            column.editable = column.editable ? () => true : () => false;
            // 列幅初期化
            column["width"] = column.width ? column.width : "0";
          });
          this.columns = toFunction;

          // 横スクロールバーを表示するために列幅を指定
          this.columns.forEach(column => {
            // 「削除」のプルダウンが改行しない幅に調整
            // add 削除の欄が広い 王 start
            column.width = this.columnWidth + "em";
            // mod #7289-マスタの削除ボタンが縦表示になる 徐博 start
            // if (column.field === "isDisp")column.width = "8em";
            if (column.field === "isDisp")column.width = "9em";
            // mod #7289-マスタの削除ボタンが縦表示になる 徐博 end
            // column.width = column.field === "isDisp" ? "8em" : (this.columnWidth + "em");
            // add 削除の欄が広い 王 end
            // #9185 最小フォント、mst画面編集文字、テキストボックス幅を超えます linjunfeng start
            // #8612 ウィンドウサイズの変更で、マスタレイアウトが崩れる。林峻峰 start
            // if (column.locked && column.field === "userName") {
            //   column.width = typeof column.width == 'string' ? Number(column.width.slice(0,-2)) * 15 : column.width * 15
            // }
            // #8612 ウィンドウサイズの変更で、マスタレイアウトが崩れる。林峻峰 end
            // #9185 最小フォント、mst画面編集文字、テキストボックス幅を超えます linjunfeng end
          });

          // 先頭列ダミー要素追加（並び順列の変更内容が"かぶって"表示されてしまう事象の対応のため）
          this.columns.unshift({
            title: " ",
            field: "dummy",
            hidden: false,
            locked: true,
            editable: () => false,
            width: "10px",
            format: "",
            values: null
          });

          // カラム幅等初期調整
          // 編集・並び順設定モードによって並び順項目の表示・非表示を切り替える
          // （先頭ダミー要素列と並び順列を交互に表示・非表示する）
          const sortRankIndex = this.columns.findIndex(
            col => col.field === "sortRank"
          );
          if (sortRankIndex >= 0) {
            this.columns[sortRankIndex].hidden = true;
            const dummyIndex = this.columns.findIndex(
              col => col.field === "dummy"
            );
            if (dummyIndex >= 0) {
              this.columns[dummyIndex].hidden = false;
            }
          }
          // 編集権限列のインデックス取得
          const editAuthorityIndex = this.columns.findIndex(
            col => col.field === "editAuthority"
          );
          // add 9522 by kangjie 20231012 start
          this.columns.forEach(item => {
            console.log("item.title :",item.title);
            if (item.title === '職種') {
              item.values.unshift({
                text: " ",
                value: 0
              })
            }
          })
          // add 9522 by kangjie 20231012 end
          // 職種列のインデックス取得
          const jobCdIndex = this.columns.findIndex(
            col => col.field === "jobCd"
          );
          // カード無効化列のインデックス取得
          const cardIdmIndex = this.columns.findIndex(
            col => col.field === "cardIdm"
          )
          // システム利用設定がReMSのみの施設の場合
          if(this.facilitySysUseSetting === "1") {
            // 編集権限列／職種列を非表示
            this.columns[editAuthorityIndex].hidden = true;
            this.columns[jobCdIndex].hidden = true;
            this.columns[cardIdmIndex].hidden = true;
          }

          this.$nextTick(() => {
            this.calculateGridHeight();
            this.calculateGridWidth();
            // 追加ボタン押下した場合
            if (this.addFlg) {
              // 仮追加フラグを設定
              this.tmpAddFlg = true;
              // 追加フラグの初期化
              this.addFlg = false;
            }
          });
          // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen start
          this.mstJobBeforeChange = [];
          response.data.localDataSource.data.map(async item => {
            let getUseAuthFuncs = undefined;
            let getJobCdBak = "";
            await ApiHelper.get("/user/get_by_id/" + item.userId).then(r =>{
              getUseAuthFuncs = r.data.userAccountInfo.userSettings.authorized_functions;
              getJobCdBak = r.data.userAccountInfo.jobCd;
            });
            const res = {userId: item.userId, authorities: item.authorities, useAuthFuncs: getUseAuthFuncs, jobCdBak: getJobCdBak};
            this.mstJobBeforeChange.push(res);
          });
          // 職種マスタを取得する
          this.allMstJob = await getMstJob(this.facilitylistValue);
          // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen end
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstUserMainComponent.vue', 'findList', '指定されたマスタが見つかりません。');
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              // message: "指定されたマスタが見つかりません。"
              title: DIALOG_MESSAGES[12000003].title,
              message: messageFormat(DIALOG_MESSAGES[12000003].message),
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
          }
        });
    },
    // 施設一覧のデータを取得
    findFacilityList() {
      // 日機装ユーザ以外の場合
      if (this.getStateUserAccountInfo.userType !== 1) {
        // ログイン者の担当施設を選択（初期値は自分の所属する施設）
        this.setFacilitylistValue();
        // 選択した施設を元に利用者一覧の取得
        this.findList();
        // 職種一覧を取得
        this.setJobList();
        return;
      }
      // apiをコールして施設一覧を取得
      this.facilityList()
        .then(() => {
          // ログイン者の担当施設を選択
          this.setFacilitylistValue();
          // 選択した施設を元に利用者一覧の取得
          this.findList();
          // 職種一覧を取得
          this.setJobList();
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstUserMainComponent.vue', 'findFacilityList', '指定されたマスタが見つかりません。');
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              // message: "指定されたマスタが見つかりません。"
              title: DIALOG_MESSAGES[12000003].title,
              message: messageFormat(DIALOG_MESSAGES[12000003].message),
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
          }
        });
    },
    setJobList() {
      this.mstJobList(this.facilitylistValue);
    },
    setFacilitylistValue() {
      this.facilitylistValue = this.getStateUserAccountInfo.facilityCd;
    },
    editBackgroundColor() {
      this.$nextTick(() => {
        // グリッドが表示されていない、またはダミーデータの場合は処理終了
        const gridHeader = this.$refs.grid.$el.firstChild;
        if (
          gridHeader.textContent === " " ||
          gridHeader.textContent === "code"
        ) {
          return;
        }
        gridHeader?.classList?.add("master-grid-header");

        // 列が存在しない場合は処理しない
        if (this.$refs.grid.$el.lastChild.lastChild.tBodies != null) {
          const tbodyc = this.$refs.grid.$el.lastChild.lastChild.tBodies[0]
            .children;
          const lockTbodyc = this.$refs.grid.$el.children[1].lastChild
            .tBodies[0].children;
          const gridData = this.$refs.grid.dataSource.data;
          gridData.forEach((dataRow, index) => {
            // 仮登録ユーザは黄色背景にする
            if (dataRow.isProvisional == 1) {
              tbodyc[index].style.backgroundColor = "yellow";
              lockTbodyc[index].style.backgroundColor = "yellow";
            }
            // ログインユーザの行を無効化
            if (dataRow.userId == this.getStateUserAccountInfo.userId) {
              // ログインユーザの管理者／ID/PWリセット/ロック解除/削除機能を無効化
              tbodyc[index].children[4].setAttribute("disabled", "disabled");
              tbodyc[index].children[7].setAttribute("disabled", "disabled");
              /* mod 追加患者共有 楊zc start */
              /* tbodyc[index].children[8].setAttribute("disabled", "disabled"); */
              /* tbodyc[index].children[32].setAttribute("disabled", "disabled"); */
              tbodyc[index].children[9].setAttribute("disabled", "disabled");
              // mod #9804 #9807対応、#9584追加メールアドレス1 メールアドレス2のエラーの再修正  lmf start
              // tbodyc[index].children[33].setAttribute("disabled", "disabled");
              tbodyc[index].children[35].setAttribute("disabled", "disabled");
              // mod #9804 #9807対応、#9584追加メールアドレス1 メールアドレス2のエラーの再修正  lmf end
              /* mod 追加患者共有 楊zc end */
            }
            // ロックユーザ以外のロック解除ボタンを非表示にする
            // アカウントロックする設定でない場合、または、サインイン失敗回数が上限を達してない場合
            /* mod #9764  by zhangruixue 2023-09-04 --start */
            if (tbodyc?.[index]?.children?.[9]?.children?.[0] && (this.accountLockSetting != "1" || dataRow.failure_cnt < this.failureCnt)) {
              /* mod #9764  by zhangruixue 2023-09-04 --end */
              /* mod 追加患者共有 楊zc start */
              /* tbodyc[index].children[8].children[0].style.display = "none"; */
              tbodyc[index].children[9].children[0].style.display = "none";
              /* mod 追加患者共有 楊zc end */
            }
            // 管理者変更ボタン名称切替
            if (dataRow.administrator == 0) {
              tbodyc[index].children[4].children[0].text = "ユーザー";
            }
            /* add 追加患者共有 楊zc start */
            // 患者共有変更ボタン名称切替
            if (dataRow.patientShared == 0) {
              tbodyc[index].children[8].children[0].text = "非表示";
            }
            /* add 追加患者共有 楊zc end */
            // 利用者が患者の場合、管理者／使用機能設定／編集権限／職種設定の機能を抑制
            if (dataRow.patFlg) {
              tbodyc[index].children[4].children[0].style.display = "none";
              tbodyc[index].children[5].children[0].style.display = "none";
              tbodyc[index].children[6].children[0].style.display = "none";
              /* mod 追加患者共有 楊zc start */
              /* tbodyc[index].children[9].textContent = ""; */
              /* tbodyc[index].children[9].style.pointerEvents = "none"; */
              tbodyc[index].children[10].textContent = "";
              tbodyc[index].children[10].style.pointerEvents = "none";
              /* mod 追加患者共有 楊zc end */
            }
            // アクセスカード番号を削除
            if (dataRow.cardIdm != 1) {
              /* mod 追加患者共有 楊zc start */
              /* tbodyc[index].children[30].children[0].style.display = "none"; */
              // mod #9804 #9807対応、#9584追加メールアドレス1 メールアドレス2のエラーの再修正  lmf start
              // tbodyc[index].children[31].children[0].style.display = "none";
              tbodyc[index].children[33].children[0].style.display = "none";
              // mod #9804 #9807対応、#9584追加メールアドレス1 メールアドレス2のエラーの再修正  lmf end
              /* mod 追加患者共有 楊zc end */
            }
            //ユーザーが秘密鍵を持っていない場合、ユーザーは秘密鍵を削除できません
            if(dataRow.secretKey == "未設定"){
              /* mod 追加患者共有 楊zc start */
              /* tbodyc[index].children[29].setAttribute("disabled", "disabled"); */
              // mod #9804 #9807対応、#9584追加メールアドレス1 メールアドレス2のエラーの再修正  lmf start
              // tbodyc[index].children[30].setAttribute("disabled", "disabled");
              tbodyc[index].children[32].setAttribute("disabled", "disabled");
              // mod #9804 #9807対応、#9584追加メールアドレス1 メールアドレス2のエラーの再修正  lmf end
              /* mod 追加患者共有 楊zc end */
            }
          });
          // スクロール位置設定
          if (this.tmpAddFlg) {
            // 新規ユーザー追加した時スクロール位置を一番下の左揃えにする
            this.$refs.grid.$el.children[1].scrollTop = this.$refs.grid.$el.children[1].scrollHeight;
            this.$refs.grid.$el.children[1].scrollLeft = 0;
            this.$refs.grid.$el.children[2].scrollTop = this.$refs.grid.$el.children[2].scrollHeight;
            this.$refs.grid.$el.children[2].scrollLeft = 0;
            // 仮追加フラグを初期化する
            this.tmpAddFlg = false;
          } else {
            // 上記以外は元のスクロール位置に移動
            this.$refs.grid.$el.children[1].scrollTop = this.scrollPosition.top;
            this.$refs.grid.$el.children[1].scrollLeft = 0;
            this.$refs.grid.$el.children[2].scrollTop = this.scrollPosition.top;
            this.$refs.grid.$el.children[2].scrollLeft = this.scrollPosition.left;
          }
        }
      });
    },
    // ユーザ追加/モーダル表示
    async dispModalAddUser() {
      this.addFlg = true;
      // モーダル画面表示用のユーザデータを設定
      const userData = {
        userId: "",
        facilityCd: this.facilitylistValue,
        facilityName: "",
        administrator: 0,
        patientShared: 0,
        userName: "新規　ユーザー",
        isProvisional: 1,
        failure_cnt: 0,
        dispUserId: "",
        userType: this.facilitylistValue === "nkknkk" ? 1 : 0,
        userLastName: "新規",
        userFirstName: "ユーザー",
        userPassword: "",
        loginUrl: "",
        systemUseSetting: ""
      };
      this.setUserData(userData);
      // 新規ユーザ登録
      const response = await this.sendRequestAddNewUser(userData);
      if (response === 0) {
        // ID/PWリセット頂部に置く
        document.getElementById("user-menu").style.zIndex = "100"
        document.getElementsByClassName("notification unread-count")[0].style.zIndex = "101"
        // モーダルを表示
        await this.showUserMasterIdReset();
        // 利用者の再取得
        this.findList();
      }
    },
    // ユーザID/PW変更・モーダル表示
    async dispModalIdReset(e) {
      // スクロールの位置を維持
      this.setScrollLocation();

      /**
       * 「リセット」ボタンを押下したレコードのデータを取得する。
       * see: https://www.telerik.com/forums/selected-row-at-wrappers-for-vue
       */
      e.preventDefault();
      const row = this.$refs.grid.kendoWidget();
      const selectedRowItem = row.dataItem(e.currentTarget.closest("tr"));
      const userId = selectedRowItem.userId;
      // モーダル画面表示用のユーザデータを設定
      const userData = {
        userId: userId,
        facilityName: "",
        facilityCd: this.facilitylistValue,
        userName: selectedRowItem.userName,
        dispUserId: selectedRowItem.dispUserId,
        userPassword: "",
        loginUrl: "",
        patFlg: selectedRowItem.patFlg
      };
      // パスワードリセット
      const response = await this.sendRequestUpdatePassword(userData);
      if(this.valueSignIn == 2){
          let dispUserId = this.getStateUserAccountInfo.dispUserId;
          let facilityValue = this.getStateUserAccountInfo.facilityCd
          const data1 = {
            dispUserId : dispUserId,
            facilityCd : facilityValue
          }
          await this.sendRequestCreateMstUserOTP(data1)
          const data2 = {
            userId : userId,
            secretKey : this.userOTP.secretKey
          }
          await this.sendRequestUpdateSecretKey(data2)
      }
      if (response === 0) {
        // ID/PWリセット頂部に置く
        document.getElementById("user-menu").style.zIndex = "100"
        document.getElementsByClassName("notification unread-count")[0].style.zIndex = "101"
        // モーダルを表示
        await this.showUserMasterIdReset();
        await this.findList();
      }
    },
    // 使用許可機能
    async dispModalUseFunction(e) {
      // スクロールの位置を維持
      this.setScrollLocation();

      /**
       * 「使用機能」ボタンを押下したレコードのデータを取得する。
       * see: https://www.telerik.com/forums/selected-row-at-wrappers-for-vue
       */
      e.preventDefault();
      const row = this.$refs.grid.kendoWidget();
      const selectedRowItem = row.dataItem(e.currentTarget.closest("tr"));

      // モーダル画面表示用のユーザデータを設定
      const userData = {
        userId: selectedRowItem.userId,
        facilityCd: this.facilitylistValue
      };
      this.setUserData(userData);
      // モーダル画面表示
      await this.showUserMasterAuthFunction();
    },
    // 権限設定
    async dispModalEditAuthority(e) {
      // スクロールの位置を維持
      this.setScrollLocation();

      /**
       * 「使用機能」ボタンを押下したレコードのデータを取得する。
       * see: https://www.telerik.com/forums/selected-row-at-wrappers-for-vue
       */
      e.preventDefault();
      const row = this.$refs.grid.kendoWidget();
      const selectedRowItem = row.dataItem(e.currentTarget.closest("tr"));

      // モーダル画面表示用のユーザデータを設定
      const userData = {
        userId: selectedRowItem.userId,
        authorities: selectedRowItem.authorities,
        facilityCd: this.facilitylistValue
      };
      this.setUserData(userData);
      // モーダル画面表示
      await this.showUserMasterEditAuthority();
    },
    // 管理者チェック
    async changeAdmin(e) {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);

      // スクロールの位置を維持
      this.setScrollLocation();

      e.preventDefault();
      const row = this.$refs.grid.kendoWidget();
      const selectedRowItem = row.dataItem(e.currentTarget.closest("tr"));

      const userData = {
        userId: selectedRowItem.userId,
        administrator: selectedRowItem.administrator === 1 ? 0 : 1
      };

      // 管理者フラグ更新
      const response = await this.sendRequestUpdateAdministratorFlg(userData);
      if (response === 0) {
        // 利用者の再取得
        this.findList();
      }
      // 共通ローダー:表示終了
      this.setLoadingScreenVisible(false);
    },
    /* add 追加患者共有 楊zc start */
    // 患者共有・モーダル表示
    async changePatientSharedReset(e) {

      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      e.preventDefault();

      const row = this.$refs.grid.kendoWidget();
      const selectedRowItem = row.dataItem(e.currentTarget.closest("tr"));

      const userData = {
        userId: selectedRowItem.userId,
        patientShared: selectedRowItem.patientShared === 1 ? 0 : 1
      };

      // 患者共有フラグ更新
      const response = await this.sendRequestUpdatePatientSharedFlg(userData);
      if (response === 0) {
        // 利用者の再取得
        this.findList();
      }

      // 共通ローダー:表示終了
      this.setLoadingScreenVisible(false);

    },
    /* add 追加患者共有 楊zc end */
    // ユーザのログイン失敗回数をリセット
    async resetLoginFailCnt(e) {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);

      // スクロールの位置を維持
      this.setScrollLocation();

      /**
       * 「リセット」ボタンを押下したレコードのデータを取得する。
       * see: https://www.telerik.com/forums/selected-row-at-wrappers-for-vue
       */
      e.preventDefault();
      const row = this.$refs.grid.kendoWidget();
      const selectedRowItem = row.dataItem(e.currentTarget.closest("tr"));

      const response = await this.sendRequestUpdateFailureCnt(
        selectedRowItem.userId
      );
      if (response === 0) {
        // 利用者の再取得
        this.findList();
      }
      // 共通ローダー:表示終了
      this.setLoadingScreenVisible(false);
    },
    // ユーザ削除
    async delUser(e) {
      // スクロールの位置を維持
      this.setScrollLocation();

      /**
       * 「削除」ボタンを押下したレコードのデータを取得する。
       * see: https://www.telerik.com/forums/selected-row-at-wrappers-for-vue
       */
      e.preventDefault();
      const row = this.$refs.grid.kendoWidget();
      const selectedRowItem = row.dataItem(e.currentTarget.closest("tr"));
      this.delUserId = selectedRowItem.userId;

      let mes = "";
      // 確認ダイアログ表示
      if (selectedRowItem.patFlg) {
        // 削除対象の利用者が患者の場合、再登録の注意を表示する
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
        // mes = "!!注意!!</br>在宅患者を削除しようとしています。再登録する場合は在宅透析指示書の登録ボタンを押してください。";
        mes = messageFormat(DIALOG_MESSAGES[13000100].message);
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
      } else {
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
        // mes = "!!注意!!</br>アカウントを削除すると二度と戻すことはできません。</br>削除すると対象アカウントをサインアウトします。";
        mes = messageFormat(DIALOG_MESSAGES[13000101].message);
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
      }
      // 確認ダイアログ表示
      const resOk = await this.$ons.notification.confirm({
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
        // title: "アカウント削除確認",
        title: DIALOG_MESSAGES[13000100].title,
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        message: mes
      });

      if (resOk === 1) {
        this.confirm();
      }
    },

    // 削除処理実行
    async confirm() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
        const response = await this.sendRequestDeleteUser(this.delUserId);
        if (response === 0) {
          // 利用者の再取得
          this.findList();
        }
      // 共通ローダー:表示終了
      this.setLoadingScreenVisible(false);
    },

    // カード作成
    async createCard(e) {
      // スクロールの位置を維持
      this.setScrollLocation();

      e.preventDefault();
      const row = this.$refs.grid.kendoWidget();
      const selectedRowItem = row.dataItem(e.currentTarget.closest("tr"));

      // TODO 保存する内容は未確定
      const card = {
        type: "1",
        id: selectedRowItem.userId,
        name: selectedRowItem.userName
      };
      this.setCard(card);
      if (this.getSocketIsConnected) {
        this.setLoadingScreenVisible(true);
        this.sendSocketMessage(`WRITE_STAFF_CARD-${this.facilityCd}-${card.id}`);
      } else {
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "保存失敗",
          // message: "カードの書き込みに失敗しました。"
          title: DIALOG_MESSAGES["00200103"].title,
          message: messageFormat(DIALOG_MESSAGES['00200103'].message)
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
        });
      }
    },
    async onSave(e){
      // スクロールの位置を維持
      this.setScrollLocation();

      /* mod 追加患者共有 楊zc start */
      // if (e.container[0].cellIndex === 9){
      if (e.container[0].cellIndex === 10){
      /* mod 追加患者共有 楊zc end */
        // 職種を更新
        // 共通ローダー:表示開始
        this.setLoadingScreenVisible(true);

        let strJobCd = "";
        // mod #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen start
        // if (e.values.jobCd.value === undefined){
        if (e.values.dirty == false || e.values.jobCd.value === undefined){
        // mod #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen end
          strJobCd = e.values.jobCd;
        } else {
          strJobCd = e.values.jobCd.value;
        }
        const userData = {
          userId: e.model.userId,
          jobCd: strJobCd
        }
        // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen start
        // this.allMstJob  this.mstJobBeforeChange
        let afterChangesMstJobInfo = this.allMstJob.filter(item => {return item.jobCd == strJobCd})[0];
        let beforeChangeInfo = this.mstJobBeforeChange.filter(item => {return item.userId == e.model.userId})[0];

        let changeFlg = false;
        if (!afterChangesMstJobInfo || !afterChangesMstJobInfo.defaultAuthorizedAuthorities) {
          changeFlg = false;
        } else {
          changeFlg = beforeChangeInfo.authorities.every(element => afterChangesMstJobInfo.defaultAuthorizedAuthorities.split(",").map(num => String(num)).includes(element)) &&
            beforeChangeInfo.useAuthFuncs.every(element => afterChangesMstJobInfo.defaultMenuSettings.default_menu_functions.includes(element));
        }

        let returnFlg = false;
        if (this.signoutFlg && !changeFlg) {
          await this.$ons.notification.confirm({
            // title: "変更確認",
            title: DIALOG_MESSAGES[13000157].title,
            message: MSG_SETTING_REFLECTION,
            callback: answer => {
              if (answer !== 1) {
                // キャンセル
                returnFlg = true;
                e.model.set("jobCd", beforeChangeInfo.jobCdBak);
                delete e.model.dirtyFields["jobCd"];
                if (Object.keys(e.model.dirtyFields).length === 0) {
                  e.model.set("dirty", false);
                }
                this.calculateColumnsWidth();
                this.calculateGridWidth();
                this.editBackgroundColor();
              }
            }
          });
        }

        if (returnFlg) {
          // 共通ローダー:表示終了
          this.setLoadingScreenVisible(false);
          return;
        }
        // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen end
        const response = await this.sendRequestUpdateJobCd(userData);
        if (response === 0) {
          // 利用者の再取得
          this.findList();
          await this.getUserAccountInfo();
        }
        // 共通ローダー:表示終了
        this.setLoadingScreenVisible(false);
      /* mod 追加患者共有 楊zc start */
      // } else if ([10, 11, 12, 13, 14, 22, 23].includes(e.container[0].cellIndex)) {
        // mod #9804 #9807対応、#9584追加メールアドレス1 メールアドレス2のエラーの再修正  lmf start
        // } else if ([11, 12, 13, 14, 15, 22, 23, 24].includes(e.container[0].cellIndex)) {
      } else if ([11, 12, 13, 14, 17, 24, 25, 26].includes(e.container[0].cellIndex)) {
        // mod #9804 #9807対応、#9584追加メールアドレス1 メールアドレス2のエラーの再修正  lmf end
      /* mod 追加患者共有 楊zc end */
        // 利用者個人情報を更新
        // 共通ローダー:表示開始
        this.setLoadingScreenVisible(true);

        // 更新用データを作成
        const userData = {
          userId: e.model.userId,
          userLastNameKana: e.model.userLastNameKana,
          userFirstNameKana: e.model.userFirstNameKana,
          userLastNameAlpha: e.model.userLastNameAlpha,
          userFirstNameAlpha: e.model.userFirstNameAlpha,
          extensionNo: e.model.extensionNo,
          inHospitalCd_1: e.model.inHospitalCd_1,
          inHospitalCd_2: e.model.inHospitalCd_2
        }

        $$.extend(userData, e.values);
        /* add  楊zc start */
        userData.userLastNameKana = this.transform(userData.userLastNameKana);
        userData.userFirstNameKana = this.transform(userData.userFirstNameKana);
        userData.userLastNameAlpha = this.transform(userData.userLastNameAlpha);
        userData.userFirstNameAlpha = this.transform(userData.userFirstNameAlpha);
        userData.extensionNo = this.transform(userData.extensionNo);
        /* add  楊zc end */
        const response = await this.sendRequestUpdateUserPersonalInfo(userData);
        if (response === 0) {
          // 利用者の再取得
          this.findList();
        }
        // 共通ローダー:表示終了
        this.setLoadingScreenVisible(false);
      }
    },
    // -----------------------------------------
    // 変換 \
    // -----------------------------------------
    transform(obj){
      let array = [];
      if(obj !== undefined && obj !== null){
          [...obj].forEach((str)=>{array.push(str.replace("\\","\\\\"));});
          return array.join("");
        }
    },
    // -----------------------------------------
    // 抽出UI表示イベント
    // -----------------------------------------
    showPopover(event) {
      this.popoverTarget = event;
      this.popoverVisible = true;
    },
    // パンくずリストをクリックされた場合に呼び出される関数
    refresh() {
      // 他の画面に遷移したときもrefresh()が発生する為、自分の画面のみ処理する
      if (this.selfScreenName === this.$router.currentRoute.name) {
        // スクロールの位置を初期化する
        this.scrollPosition.top = 0;
        this.scrollPosition.left = 0;
        this.findList();
      }
    },
    /**
     * @description スクロールバーの位置をクリアする
     */
    clearScrollPosition() {
      this.scrollPosition.top = 0;
      this.scrollPosition.left = 0;
    },
    //秘密鍵を削除する
    async deleteKey(e){
      // スクロールの位置を維持
      this.setScrollLocation();

      e.preventDefault();
      const row = this.$refs.grid.kendoWidget();
      const selectedRowItem = row.dataItem(e.currentTarget.closest("tr"));
      const userId = selectedRowItem.userId;
      this.$ons.notification.confirm({
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
        // title: "!!注意!!",
        title: DIALOG_MESSAGES[13000102].title,
        // message: "秘密鍵を削除すると二度と戻すことはできません。削除しますか？",
        message: messageFormat(DIALOG_MESSAGES[13000102].message),
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        callback: async answer => {
          if (answer === 1) {
            const user = {
                userId,
                isSetQrCode : 0
              }
              await this.sendRequestUpdateIsSetQrCode(user);
              const response = await this.sendRequestDeleteSecretKey(userId);
              if(this.valueSignIn == 2){
                  let dispUserId = this.getStateUserAccountInfo.dispUserId;
                  let facilityValue = this.getStateUserAccountInfo.facilityCd
                  const data1 = {
                    dispUserId : dispUserId,
                    facilityCd : facilityValue
                  }
                  await this.sendRequestCreateMstUserOTP(data1)
                  const data2 = {
                    userId : userId,
                    secretKey : this.userOTP.secretKey
                  }
                  await this.sendRequestUpdateSecretKey(data2)
              }
              if (response === 0) {
                this.findList();
            }
          }
        }
      });

    },

    //アクセスカードを無効にする
    async disableCard(e) {
      // スクロールの位置を維持
      this.setScrollLocation();

      e.preventDefault();
      const row = this.$refs.grid.kendoWidget();
      const selectedRowItem = row.dataItem(e.currentTarget.closest("tr"));
      const userId = selectedRowItem.userId;
      this.$ons.notification.confirm({
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
        // title: "!!注意!!",
        title: DIALOG_MESSAGES[13000103].title,
        // message: "アクセスカードを無効にすると、元に戻すことはできません。 無効にしますか？",
        message: messageFormat(DIALOG_MESSAGES[13000103].message),
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        callback: async answer => {
          if (answer === 1) {
            const response = await this.sendRequestDisableAccessCard(userId);
              if (response === 0) {
                this.findList();
            }
          }
        }
      });
    },

    // スクロールの位置の設定
    setScrollLocation() {
      if (this.$refs.grid != null) {
        // モーダル確定時にスクロール位置が戻ってしまう問題の対処
        const grid = $$("div.k-grid-content")[0];
        this.scrollPosition.top = grid.scrollTop;
        this.scrollPosition.left = grid.scrollLeft;
      }
    },
    onBeforeEdit(e) {
      if (this.isMobileDevice && !this.allowEdit) {
        /* NOTE:
         * モバイル系は、スワイプ・フリック操作で入力パッドが表示される。
         * そのため、スクロール操作が損なわれるので、閲覧モードのときは
         * 後続のイベントを発火させないように制御する。
         */
        e.preventDefault();
        return;
      }
      this.editStart(e);
    },
    onDataBoundKendoGrid(e) {
      if (this.scrollPosition.top > 0 || this.scrollPosition.left > 0) {
        //スクロールバーの位置をイベント発生前の位置に戻す
        this.$nextTick(() => {
          e.sender.content[0].scrollTop = this.scrollPosition.top;
          e.sender.content[0].scrollLeft = this.scrollPosition.left;
        });
      }
    },
  },
  // mod FNSI-4200ポートを使用している 孫 start
  //created() {
  //  if (!this.getSocketIsConnected) {
  //    this.connect();
  async created() {
    this.setLoadingScreenVisible(true);

    if (!this.getSocketIsConnected || null === this.getCardDeviceStatus) {
      // card appのwebsokcet以外場合、接続したサービスを閉じました
      if (this.getSocketIsConnected) {
        this.close();
        await SleepNSeconds(100);
      }

      // 遅延のミリ秒(millisecond)
      let delayMillisecond = 1000;

      // localStorageのportを利用する
      let defaultPort = localStorage.getItem("CARD_APP_PORT");
      // add 9511 FNSiカードアプリが一方のブラウザとしかつながらない。　吉 start
      if(!/^\d+$/.test(defaultPort)){
        localStorage.removeItem("CARD_APP_PORT");
        defaultPort = null;
      }
      // add 9511 FNSiカードアプリが一方のブラウザとしかつながらない。　吉 end
      if (null !== defaultPort) {
        // localStorageがあり場合、接続を実施する
        this.init({ port: defaultPort, facilityCd: "" });
        this.connect();

        // Nミリ秒を待つ
        await SleepNSeconds(delayMillisecond);
      }

      // 接続確認実施
      // APP接続しません、または、カードリーダーが無し
      if (!this.getSocketIsConnected || null === this.getCardDeviceStatus) {
        // 「カードアプリポート管理」からportを取得する
        let facilityCd = this.facilityCd;
        let cardPorts = await ApiHelper.get(`${uriGetCardAppPort}/${facilityCd}`).catch(() => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstUserMainComponent.vue', 'created', 'カードアプリポート管理から、ポートを取得しません。');
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          throw new Error("カードアプリポート管理から、ポートを取得しません。");
        });

        // portsをループする
        let portList = new Array();
        if (cardPorts.data.toString().indexOf(",") == -1) {
           portList[0] = cardPorts.data.toString();
        } else {
           portList = cardPorts.data.toString().split(",");
        }
        for(let i = 0; i < portList.length; i++) {
          // APP接続しません、または、カードリーダーが無し
          if (!this.getSocketIsConnected || null === this.getCardDeviceStatus) {
            // card appのwebsokcet以外場合、接続したサービスを閉じました
            if (this.getSocketIsConnected) {
              this.close();
              await SleepNSeconds(100);
            }

            // 接続を実施する
            this.init({ port: portList[i], facilityCd: "" });
            this.connect();

            // Nミリ秒を待つ
            await SleepNSeconds(delayMillisecond);
          }
        }
      }
    // mod FNSI-4200ポートを使用している 孫 end
    } else {
      this.isCardDeviceConnected = this.getCardDeviceStatus
    }
    // mod マスタ一覧 1･施設切替を可能とする 孔 start
    // this.findFacilityList();
    this.facilitylistValue = this.getFacilitySwitch;
    this.findList();
    this.setJobList();
    // mod マスタ一覧 1･施設切替を可能とする 孔 end
    this.setCondition(this.condition);
    this.getDispCreateCard(this.getStateUserAccountInfo.facilityCd);

    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");
    // 端末判別
    const ua = navigator.userAgent.toLowerCase();
    if (/android/.test(ua)) {
      this.androidFlg = true;
    } else if (/iphone|ipad|mac|os/.test(ua)) {
      this.iosFlg = true;
    }
    this.selfScreenName = this.$router.currentRoute.name
    EventBus.$on("refresh", this.refresh);

    // カード情報クリア
    this.clearCard();
    //値の取得ログイン
    this.sendRequestGetValueSignInByFacilityCd(this.getStateUserAccountInfo.facilityCd)
    // add FNSI-4200ポートを使用している 孫 start
    function SleepNSeconds(num) {
        return new Promise((resolve) => {
            setTimeout(() => {
              resolve(1*num);
            }, num);
        } );
    }
    // add FNSI-4200ポートを使用している 孫 end
    // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen start
    // 職種マスタを取得する
    this.allMstJob = await getMstJob(this.facilitylistValue);
    // 施設設定：権限変更時サインアウトさせるかの設定を取得
    sendRequestGetMstFacilitySettingValue(this.getFacilitySwitch, PERMISSION_CHANGE_SIGNOUT).then(response => {
      this.signoutFlg = (response.data == 1);
    });
    // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen end
  },
  updated() {
    // mod #9804 9807 コンソールエラーの修正  lmf start
    // // Storeの更新等で画面が再描画された場合に背景色を変更
    // this.editBackgroundColor();
    this.$nextTick(() => {
      // Storeの更新等で画面が再描画された場合に背景色を変更
      this.editBackgroundColor();
      // mod #9804 9807 コンソールエラーの修正  lmf end
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
    });
  },
  mounted() {
    this.$nextTick(() => {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
    });
    EventBus.$on("clearScrollPosition", this.clearScrollPosition);
  },
  // add 性能改善メモリ不足 shan start
  beforeDestroy() {
    EventBus.$off("refresh", this.refresh);
    clearInterval(this.socketInterval);
    EventBus.$off("clearScrollPosition", this.clearScrollPosition);
  },
  // add 性能改善メモリ不足 shan end
};
</script>

<!-- 個別スタイル定義 -->
<style scoped>
.right {
  text-align: right;
}
.header-btn-area {
  height: auto;
  padding: 0.1em 0.1em 0.1em 0.1em;
}
#grid-footer {
  margin: 0;
  padding: 5px 5px 5px 5px;
  bottom: 0;
  position: absolute;
  width: inherit;
}
.kendo-grid-toolbar-style {
  --height: 200px;
  height: var(--height);
  border-bottom: none;
}
.toolbar-btn {
  font-size: 1.0em;
  padding: 0.2em 1em 0em 1em;
  line-height: 2em;
  width: auto;
}
.k-grid-toolbar {
  padding: 0.1em 0.3em;
}
.kendo-grid-toolbar-style >>> .k-grid-header-locked > table {
  border-right-width: 0px;
}
.kendo-grid-toolbar-style >>> .k-grid-header-locked {
  border-right: 1px solid var(--ntss-list-border-color) !important;
}
.kendo-grid-toolbar-style >>> .k-grid-content-locked {
  z-index: 1;
  box-shadow: 1px 0px 0px 0px var(--ntss-border-color) !important;
}
.custom-switch {
  transform: scale(0.85);
  transform-origin: center;
  touch-action: manipulation;
}
.kendo-grid-toolbar-style >>> .k-grid-content-locked {
  overflow-y: scroll !important;
  -webkit-overflow-scrolling: touch;
  scrollbar-width: none;
  -ms-overflow-style: none;
}
.kendo-grid-toolbar-style >>> .k-grid-content-locked::-webkit-scrollbar {
  display: none;
}
.no-scroll {
  overflow-x: hidden;
}
</style>
