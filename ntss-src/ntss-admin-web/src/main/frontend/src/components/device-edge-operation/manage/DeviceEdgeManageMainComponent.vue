
/**
 * デバイスエッジアップデータ操作画面
 */
<template>
  <div class="main-content-area">
    <div class="main-content-block">
      <div class="updater-content-block vertical-div fill-width" :style="getBlockWidth">
        <table class="device-edge-manage-list">
          <thead>
            <tr>
              <th
                v-for="(column, idx) in appVerInfo"
                :key="column.key + idx"
                class="device-edge-manage-list-header"
              >{{ column.key }}</th>
            </tr>
          </thead>
          <tbody>
            <tr class="ntss-list-body-tr">
              <td
                v-for="column in appVerInfo"
                :key="column.key"
                class="ntss-list-body-td"
              >{{ column.value }}</td>
            </tr>
          </tbody>
        </table>
        <table class="device-edge-manage-list">
          <thead>
            <tr>
              <th
                v-for="(column, idx) in updaterVerInfo"
                :key="column.key + idx"
                class="device-edge-manage-list-header"
              >{{ column.key }}</th>
            </tr>
          </thead>
          <tbody>
            <tr class="ntss-list-body-tr">
              <td
                v-for="column in updaterVerInfo"
                :key="column.key"
                class="ntss-list-body-td"
              >{{ column.value }}</td>
            </tr>
          </tbody>
        </table>
        <label class="main-device-edge-manage-alert-label">{{ planInfoView }}</label>
      </div>
      <div class="updater-content-block vertical-div" :style="getBlockWidth">
        <label class="title main-device-edge-manage-label">更新用zipファイルパス／ファイル名</label>
        <div class="horizontal-div">
          <v-ons-input
            type="text"
            class="input-box-path"
            v-model="targetFilePath"
            placeholder="更新用zipファイルパス"
            :disabled="!isNkkAdminUser"
          ></v-ons-input>
          <div class="file-path-separator">/</div>
          <v-ons-input
            type="text"
            class="input-box-file"
            v-model="targetFileName"
            placeholder="更新用zipファイル名"
            :disabled="!isNkkAdminUser"
          ></v-ons-input>
        </div>
        <div class="horizontal-div">
          <v-ons-button
            class="manage-button-all btn1-execute"
            :disabled="isRunning || !isNkkAdminUser"
            @click="onAllUpdateClick()"
          >全部更新</v-ons-button>
        </div>
        <div class="horizontal-div">
          <v-ons-button
            class="manage-button-update-l btn1-execute"
            :disabled="isRunning || !isNkkAdminUser"
            @click="onAppUpdateClick()"
          >アプリ更新</v-ons-button>
          <v-ons-button
            class="manage-button-update-r btn1-execute"
            :disabled="isRunning || !isNkkAdminUser"
            @click="onUpdaterUpdateClick()"
          >アップデータ更新</v-ons-button>
        </div>
        <div class="horizontal-div">
          <v-ons-button
            class="manage-button-update-l btn1-execute"
            :disabled="isRunning || !isNkkAdminUser"
            @click="onAppRestoreClick()"
          >アプリ復元</v-ons-button>
          <v-ons-button
            class="manage-button-update-r btn1-execute"
            :disabled="isRunning || !isNkkAdminUser"
            @click="onUpdaterRestoreClick()"
          >アップデータ復元</v-ons-button>
        </div>
      </div>

      <div class="updater-content-block">
        <div class="control">
          <v-ons-button
            class="manage-button btn1-execute"
            :disabled="isRunning || !isNkkAdminUser"
            @click="onAppStopClick()"
          >アプリ停止</v-ons-button>
          <v-ons-button
            class="manage-button btn1-execute"
            :disabled="isRunning || !isNkkAdminUser"
            @click="onAppStartClick()"
          >アプリ起動</v-ons-button>
        </div>
        <div class="re_control">
          <v-ons-button
            class="manage-button btn1-execute"
            :disabled="isRunning || !isNkkAdminUser"
            @click="onAppRebootClick()"
          >アプリ再起動</v-ons-button>
          <v-ons-button
            class="manage-button btn1-execute"
            :disabled="isRunning || !isNkkAdminUser"
            @click="onDeviceRebootClick()"
          >DE再起動</v-ons-button>
        </div>
      </div>

      <div class="updater-content-block vertical-div">
        <label class="title main-device-edge-manage-label">DE内ログのアップロード</label>
        <div class="control">
          <div class="flex-align-center">
            <v-ons-button
              class="manage-button btn1-execute"
              :disabled="isRunning || !isNkkAdminUser"
              @click="onLogUpClick()"
            >実行</v-ons-button>
          </div>
          <label class="title main-device-edge-manage-label">DEログのダウンロード</label>
          <div class="flex-align-center">
            <date-input
              v-model="targetLogFileDate"
              :classes="'ntss-input-date ntss-control-size'"
              :disabled="isRunning || !isNkkAdminUser"
              @handleClearInput="targetLogFileDate = null"
            />
            <common-calendar v-model="targetLogFileDate" v-bind:disabled="isRunning" />
            <v-ons-button
              class="manage-button log-download-button btn1-execute"
              :disabled="isRunning || !isTargetLogFileDate || !isNkkAdminUser"
              @click="onLogDlClick()"
            >ダウンロード</v-ons-button>
          </div>
        </div>
      </div>

      <div class="updater-content-block vertical-div">
        <label class="title main-device-edge-manage-label">DE内ファイルのアップロード</label>
        <div class="control">
          <v-ons-button
            class="manage-button btn1-execute"
            :disabled="isRunning || !isNkkAdminUser"
            @click="onConfUpClick()"
          >実行</v-ons-button>
        </div>
        <label class="title main-device-edge-manage-label">DEファイルのダウンロード</label>
        <div class="control">
          <v-ons-button
            class="manage-button btn1-execute"
            :disabled="isRunning || !targetDlDeZipFile.exists || !isNkkAdminUser"
            @click="onConfDlClick()"
          >ダウンロード</v-ons-button>
          <label
            class="main-device-edge-manage-label"
          >{{targetDlDeZipFile.exists ? targetDlDeZipFile.fileName : targetDlDeZipFile.message}}</label>
        </div>
      </div>

      <div class="updater-content-block vertical-div">
        <label class="title main-device-edge-manage-label">設定ファイル適用</label>
        <label class="no-input-label">[ {{confFilePath}} ]</label>
        <label class="main-device-edge-manage-alert-label">適用後、アプリ再起動を行ってください。</label>
        <div class="control">
          <v-ons-button
            class="manage-button btn3-normal"
            :disabled="isRunning || !isNkkAdminUser"
            @click="onFilePicker()"
          >参照</v-ons-button>
          <v-ons-button
            class="manage-button btn1-execute"
            v-bind:disabled="isRunning || !isNkkAdminUser"
            @click="confFileUpdate()"
          >実行</v-ons-button>
        </div>
        <input type="file" id="hidden-file-picker" class="hidden-item" @change="onChangeFilePath()" />
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters, mapActions } from "vuex";
import { DEVICE_EDGE_MANAGE_CLASS } from "@/constants/deviceEdgeManageDefine";
import moment from "moment";
import { EventBus } from "@/eventBus.js";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar.vue";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
import { DATE_FORMAT, dateFormat } from "@/functions/common/DateTimeUtils.js";
import DateInput from "@/components/common/DateInput.vue";

const $$ = require("jquery");

export default {
  props: {},
  components: {
    "common-calendar": commonCalender,
    "date-input": DateInput,
  },
  data() {
    return {
      confFile: null,
      confFilePath: "",
      confFileData: null,
      updaterManageNo: 0,
      appUpdateManageNo: 0,
      updaterUpdateManageNo: 0,
      uploadBucket: "",
      targetLogFileDate: null,
      versionInfo: {},
      targetFilePath: "",
      targetFileName: "DE_UpdateX.zip",
      targetDlDeZipFile: {
        exists: false,
        fileDate: "",
        fileName: "",
        modifiedDate: "",
        bucket: "",
        message: ""
      },
      isRunning: false,
      blockWidth: 0,
      selfScreenName: "",
      planInfo: {
        manageNo: null,
        manageInfo: null,
        managePlanDate: null,
        responseStatus: null
      }
    };
  },
  computed: {
    ...mapGetters("account-edit", ["getStateUserAccountInfo"]),
    ...mapGetters("device-edge-manage", [
      "getSelectedDeviceEdge2digitNo",
      "getDlTarget",
      "getDownloadData"
    ]),
    ...mapGetters("window-size", {
      // 分割された画面の幅取得
      splittedWidth: "getSplittedWidth",
      windowHeight: "getWindowHeight"
    }),
    const() {
      return {
        mainAppPhrase: "main",
        updAppPhrase: "updater"
      };
    },
    isTargetLogFileDate() {
      return this.targetLogFileDate && this.targetLogFileDate.length > 0;
    },
    appVerInfo() {
      let ret = [];
      if (this.versionInfo) {
        let keys = Object.keys(this.versionInfo);
        for (const key of keys) {
          if (key.includes(this.const.mainAppPhrase)) {
            ret.unshift({
              "key": key,
              "value": this.versionInfo[key]
            });
          } else if (!key.includes(this.const.updAppPhrase)) {
            ret.push({
              "key": key,
              "value": this.versionInfo[key]
            });
          }
        }
      }
      return ret;
    },
    updaterVerInfo() {
      let ret = [];
      if (this.versionInfo) {
        let keys = Object.keys(this.versionInfo);
        for (const key of keys) {
          if (key.includes(this.const.updAppPhrase)) {
            ret.push({
              "key": key,
              "value": this.versionInfo[key]
            });
          }
        }
      }
      return ret;
    },
    planInfoView() {
      // 予約があれば「予約あり + 時刻」を表示
      if (this.planInfo.manageNo) {
        const planDate = moment(this.planInfo.managePlanDate).format("YYYY/MM/DD HH:mm:ss");
        if (this.planInfo.responseStatus === 3) {
          return `予約あり ${planDate}`;
        } if (this.planInfo.responseStatus === 2) {
          return null; // 予約処理完了済み
        } else if (this.planInfo.responseStatus >= 0) {
          return `予約依頼中 (応答待ち)`;
        } else {
          return `予約なし 処理失敗 ${this.planInfo.manageInfo.message ? `(${this.planInfo.manageInfo.message})` : ""}`;
        }
      } else {
        return null;
      }
    },
    getBlockWidth() {
      return { maxWidth: this.blockWidth + "px" };
    },
    // -----------------------------------------
    // 日機装ユーザーか否か
    // 日機装ユーザーの場合、trueを返します。
    // -----------------------------------------
    isNkkUser() {
      return 1 === this.getStateUserAccountInfo.userType;
    },
    // -----------------------------------------
    // 管理者ユーザーか否か
    // 管理者ユーザーの場合、trueを返します。
    // -----------------------------------------
    isAdminUser() {
      return 1 === this.getStateUserAccountInfo.administrator;
    },
    isNkkAdminUser() {
      return this.isNkkUser && this.isAdminUser;
    }
  },
  methods: {
    ...mapActions("device-edge-manage", [
      "fetchDeviceEdgeState",
      "fetchDeviceEdgeBaseBucket",
      "orderDeviceEdgeControl",
      "fetchLogFileInfo",
      "fetchConfFileInfo",
      "fetchConfUploadTarget",
      "setDownloadData",
      "setDownloadLogData",
      "uploadConfFile",
      "orderDeviceEdgeConfUpdate",
      "orderDeviceEdgeFileUpload",
      "orderDeviceEdgeRestoreApp",
      "orderDeviceEdgeRestoreUpdater",
      "orderDeviceEdgeUpdateApp",
      "orderDeviceEdgeUpdateUpdater",
      "orderDeviceEdgeUpdateAll"
    ]),
    async onAppUpdateClick() {
      const resOk = await this.$ons.notification.confirm({
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
        // title: "確認",
        title: DIALOG_MESSAGES[13000007].title,
        // message: "アプリケーションの更新指示を行います"
        message: messageFormat(DIALOG_MESSAGES[13000007].message),
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
      });
      if (resOk === 1) {
        const ordPayload = {
          uploadBucket: this.targetFilePath,
          fileName: this.targetFileName,
          orderClass: DEVICE_EDGE_MANAGE_CLASS.UPDATE
        };
        this.sendOrderDeviceEdge(this.orderDeviceEdgeUpdateApp, ordPayload);
      }
    },
    async onUpdaterUpdateClick() {
      const resOk = await this.$ons.notification.confirm({
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
        // title: "確認",
        title: DIALOG_MESSAGES[13000008].title,
        // message: "アップデータの更新指示を行います"
        message: messageFormat(DIALOG_MESSAGES[13000008].message),
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
      });
      if (resOk === 1) {
        const ordPayload = {
          uploadBucket: this.targetFilePath,
          fileName: this.targetFileName,
          orderClass: DEVICE_EDGE_MANAGE_CLASS.UPDATE
        };
        this.sendOrderDeviceEdge(this.orderDeviceEdgeUpdateUpdater, ordPayload);
      }
    },
    async onAllUpdateClick() {
      const resOk = await this.$ons.notification.confirm({
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
        // title: "確認",
        title: DIALOG_MESSAGES[13000009].title,
        // message: "全ファイルの更新指示を行います"
        message: messageFormat(DIALOG_MESSAGES[13000009].message),
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
      });
      if (resOk === 1) {
        const ordPayload = {
          uploadBucket: this.targetFilePath,
          fileName: this.targetFileName,
          orderClass: DEVICE_EDGE_MANAGE_CLASS.UPDATE
        };
        this.sendOrderDeviceEdge(this.orderDeviceEdgeUpdateAll, ordPayload);
      }
    },
    async onAppRestoreClick() {
      const resOk = await this.$ons.notification.confirm({
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
        // title: "確認",
        title: DIALOG_MESSAGES[13000010].title,
        // message: "アプリケーションの復元指示を行います"
        message: messageFormat(DIALOG_MESSAGES[13000010].message),
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
      });
      if (resOk === 1) {
        this.sendOrderDeviceEdge(
          this.orderDeviceEdgeRestoreApp,
          DEVICE_EDGE_MANAGE_CLASS.RESTORE
        );
      }
    },
    async onUpdaterRestoreClick() {
      const resOk = await this.$ons.notification.confirm({
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
        // title: "確認",
        title: DIALOG_MESSAGES[13000011].title,
        // message: "アップデータの復元指示を行います"
        message: messageFormat(DIALOG_MESSAGES[13000011].message),
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
      });
      if (resOk === 1) {
        this.sendOrderDeviceEdge(
          this.orderDeviceEdgeRestoreUpdater,
          DEVICE_EDGE_MANAGE_CLASS.RESTORE
        );
      }
    },
    onAppStopClick() {
      this.sendDeviceEdgeControlSignal(
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
        // "アプリケーションの停止指示を行います",
        messageFormat(DIALOG_MESSAGES[13000012].message),
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
        DEVICE_EDGE_MANAGE_CLASS.APP_STOP
      );
    },
    async onAppStartClick() {
      this.sendDeviceEdgeControlSignal(
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
        // "アプリケーションの起動指示を行います",
        messageFormat(DIALOG_MESSAGES[13000013].message),
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
        DEVICE_EDGE_MANAGE_CLASS.APP_START
      );
    },
    async onAppRebootClick() {
      this.sendDeviceEdgeControlSignal(
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
        // "アプリケーションの再起動指示を行います",
        messageFormat(DIALOG_MESSAGES[13000014].message),
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
        DEVICE_EDGE_MANAGE_CLASS.APP_REBOOT
      );
    },
    /**
     * デバイスエッジ再起動
     */
    async onDeviceRebootClick() {
      this.sendDeviceEdgeControlSignal(
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
        // "デバイスエッジの再起動指示を行います",
        messageFormat(DIALOG_MESSAGES[13000015].message),
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
        DEVICE_EDGE_MANAGE_CLASS.DEVICE_REBOOT
      );
    },
    async sendDeviceEdgeControlSignal(alertMessage, requestClass) {
      const resOk = await this.$ons.notification.confirm({
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
        // title: "確認",
        title: DIALOG_MESSAGES[13000012].title,
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
        message: alertMessage
      });
      if (resOk === 1) {
        this.sendOrderDeviceEdge(this.orderDeviceEdgeControl, requestClass);
      }
    },
    /**
     * ログファイルアップロード
     */
    async onLogUpClick() {
      const resOk = await this.$ons.notification.confirm(
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
        // `ログファイルのアップロード指示を行いますか？`,
        messageFormat(DIALOG_MESSAGES[13000016].message),
        // { title: "確認" }
        {title: DIALOG_MESSAGES[13000016].title}
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
      );
      if (resOk === 1) {
        // ログファイルアップロード指示
        this.sendOrderDeviceEdge(
          this.orderDeviceEdgeFileUpload,
          DEVICE_EDGE_MANAGE_CLASS.LOG_GATHER
        );
      }
    },
    /**
     * ログファイルダウンロード
     */
    async onLogDlClick() {
      if (this.targetLogFileDate === null) {
        // 取得日付未設定
        return;
      }
      const targetDate = moment(this.targetLogFileDate);
      // ログファイルダウンロード
      this.logFileDownload(targetDate.format("YYYYMMDD"));
    },
    async logFileDownload(dateStr) {
      const resOk = await this.$ons.notification.confirm(
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
        // "ログファイルをダウンロードします",
        messageFormat(DIALOG_MESSAGES[13000017].message),
        // { title: "確認" }
        {title: DIALOG_MESSAGES[13000017].title}
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
      );
      if (resOk === 1) {
        this.isRunning = true;
        try {
          const response = await this.fetchLogFileInfo(dateStr);
          if (response.data.exists) {
            // ダウンロード対象有り
            this.downloadLogApiCall(response.data.bucket, response.data.fileName);
          } else {
            // ログファイル無し
            this.isRunning = false;
            const resOk = await this.$ons.notification.confirm(
              // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
              // `${response.data.message}
              //   ログファイルのアップロード指示を行いますか？`,
              messageFormat(DIALOG_MESSAGES[13000160].message, response.data.message),
              // { title: "確認" }
              {title: DIALOG_MESSAGES[13000160].title}
               // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
            );
            if (resOk === 1) {
              // ログファイルアップロード指示
              this.sendOrderDeviceEdge(
                this.orderDeviceEdgeFileUpload,
                DEVICE_EDGE_MANAGE_CLASS.LOG_GATHER
              );
            }
          }
        } catch (error) {
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
          getErrorMessage('DeviceEdgeManageMainComponent.vue', 'logFileDownload', 'ログファイルアップロード指示に失敗しました');
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
          this.isRunning = false;
          this.$ons.notification.alert(
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // "ログファイルアップロード指示に失敗しました。",
            // { title: "確認" }
            messageFormat(DIALOG_MESSAGES['00200008'].message),
            { title: DIALOG_MESSAGES['00200008'].title }
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          );
        }
      }
    },
    /**
     * DE内ファイルアップロード
     */
    async onConfUpClick() {
      const resOk = await this.$ons.notification.confirm(
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
        // `DE内ファイルのアップロード指示を行いますか？`,
         messageFormat(DIALOG_MESSAGES[13000018].message),
        // { title: "確認" }
        {title: DIALOG_MESSAGES[13000018].title}
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
      );
      if (resOk === 1) {
        // ファイルアップロード指示
        this.sendOrderDeviceEdge(
          this.orderDeviceEdgeFileUpload,
          DEVICE_EDGE_MANAGE_CLASS.CONF_GATHER
        );
      }
    },
    /**
     * DEファイルダウンロード
     */
    async onConfDlClick() {
      this.isRunning = true;
      try {
        if (this.targetDlDeZipFile.exists) {
          // ダウンロード対象有り
          this.isRunning = false;
          const resOk = await this.$ons.notification.confirm(
            // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
            // `${this.targetDlDeZipFile.fileDate}時点にアップロードされたファイルをダウンロードしますか？`,
            messageFormat(DIALOG_MESSAGES[13000019].message,this.targetDlDeZipFile.fileDate),
            {
              // title: "確認",
              title: DIALOG_MESSAGES[13000019].title,
              // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
              buttonLabels: ["Cancel", "OK"]
            }
          );
          if (resOk === 1) {
            this.downloadApiCall(
              this.targetDlDeZipFile.bucket,
              this.targetDlDeZipFile.fileName
            );
          }
        }
      } catch (error) {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('DeviceEdgeManageMainComponent.vue', 'onConfDlClick', 'ファイルのダウンロードに失敗しました');
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        this.isRunning = false;
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
        // this.$ons.notification.alert("ファイルのダウンロードに失敗しました。", {
        //   title: "確認"
        // });
        this.$ons.notification.alert(messageFormat(DIALOG_MESSAGES['00200009'].message), {
          title: DIALOG_MESSAGES['00200009'].title
        });
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      }
    },
    downloadApiCall(fullBucket, file) {
      // NOTE:DLするファイル指定
      this.setDownloadData({
        bucket: fullBucket,
        filename: file
      })
        .then(() => {
          this.isRunning = false;
          this.downloadFile();
        })
        .catch((error) => {
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
          getErrorMessage('DeviceEdgeManageMainComponent.vue', 'downloadApiCall', 'ファイルのダウンロードに失敗しました');
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
          if (error.response.status === 400) {
            this.$ons.notification.alert(
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // "ファイルのダウンロードに失敗しました。",
              // { title: "確認" }
              messageFormat(DIALOG_MESSAGES['00200009'].message),
              { title: DIALOG_MESSAGES['00200009'].title }
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            );
          } else {
            throw error;
          }
        });
    },
    // DEログのダウンロード
    downloadLogApiCall(fullBucket, file) {
      // NOTE:DLするファイル指定
      this.setDownloadLogData({
        bucket: fullBucket,
        filename: file
      })
        .then(() => {
          this.isRunning = false;
          this.downloadFile();
        })
        .catch((error) => {
          if (error.response.status === 400) {
            this.$ons.notification.alert(
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // "ログファイルのダウンロードに失敗しました。",
              // { title: "確認" }
              messageFormat(DIALOG_MESSAGES['00200010'].message),
              { title: DIALOG_MESSAGES['00200010'].title }
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            );
          } else {
            throw error;
          }
        });
    },
    downloadFile() {
      const downloadData = this.getDownloadData;
      const fileName = this.getDlTarget.fileData.fileName;
      const blob = new Blob([this.hexStringToArrayBuffer(downloadData)], {
        type: "application/zip"
      });
      if (window.navigator.msSaveBlob) {
        window.navigator.msSaveBlob(blob, fileName);
      } else {
        const downloadUrl = (window.URL || window.webkitURL).createObjectURL(
          blob
        );
        const link = document.createElement("a");
        link.href = downloadUrl;
        link.download = fileName;
        link.click();
        (window.URL || window.webkitURL).revokeObjectURL(blob);
      }
    },
    // 16進文字列をバイト配列に変換
    hexStringToArrayBuffer(hexStr) {
      const bytes = [];
      // 受け取った16進数文字列を符号付バイト配列に変換
      for (let i = 0; i < hexStr.length; i += 2) {
        bytes.push(this.hexToDecimalNumber(hexStr.substr(i, 2)));
      }
      // バイト配列をArrayBuffer型に変換
      const arrayBuffer = new Uint8Array(bytes);
      return arrayBuffer;
    },
    // 16進文字列をバイト値に変換
    hexToDecimalNumber(hexStr) {
      let decimalNumber = "";
      // 受け取った16進数値を2進数値に変換
      const binaryNumber = parseInt(hexStr, 16).toString(2);
      // 変換した2進数値のサイズが8未満の場合、正数であるため10進数値に変換
      if (binaryNumber.length < 8) {
        decimalNumber = parseInt(hexStr, 16);
        // 変換した2進数値のサイズが8の場合、負数であるため符号付10進数値に独自変換
      } else {
        // 2進数値のサイズ分(8サイズ)回り、ビット値を入れ替える
        const binaryNumberStr = binaryNumber.toString();
        for (let i = 0; i < binaryNumberStr.length; i++) {
          if (parseInt(binaryNumberStr.substr(i, 1), 10) === 0) {
            decimalNumber += "1";
          } else if (parseInt(binaryNumberStr.substr(i, 1), 10) === 1) {
            decimalNumber += "0";
          }
        }
        // ビット値を入れ替えた2進数値を10進数値に変換し、1を足して負数に変換する
        decimalNumber = -(parseInt(decimalNumber, 2) + 1);
      }
      return decimalNumber;
    },
    onFilePicker() {
      $$("#hidden-file-picker")[0].click();
    },
    onChangeFilePath() {
      // confファイルを指定
      this.confFile = event.target.files[0];
      if (this.confFile !== undefined) {
        const reader = new FileReader();
        reader.onload = () => {
          this.confFilePath = this.confFile.name;
          this.confFileData = reader.result;
        };
        reader.readAsDataURL(this.confFile);
      } else {
        this.confFilePath = "";
      }
    },
    async confFileUpdate() {
      // confファイルの更新
      if (this.confFile === undefined || this.confFilePath === "") {
        return false;
      }
      const resOk = await this.$ons.notification.confirm(
      // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
        // "confファイルの更新指示を行います",
        messageFormat(DIALOG_MESSAGES[13000020].message),
        // { title: "確認" }
        {title: DIALOG_MESSAGES[13000020].title}
      // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
      );
      if (resOk === 1) {
        // OK
        this.isRunning = true;
        const result = await this.fetchConfUploadTarget();
        if (!result.data.exists) {
          // アップロード先取得失敗
          this.isRunning = false;
          this.$ons.notification.alert(
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // "confファイルのアップロード先取得に失敗しました。",
            // { title: "確認" }
            messageFormat(DIALOG_MESSAGES['00200011'].message),
            { title: DIALOG_MESSAGES['00200011'].title }
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          );
        }
        // ダウンロード対象有り
        this.uploadBucket = result.data.bucket;
        const upPayload = {
          confFile: this.confFile,
          filePath: this.uploadBucket
        };
        try {
          const uploadConfResponse = await this.uploadConfFile(upPayload);
          if (uploadConfResponse.data.isSuccess) {
            // アップロード成功
            const ordPayload = {
              uploadBucket: this.uploadBucket,
              fileName: this.confFile.name,
              orderClass: DEVICE_EDGE_MANAGE_CLASS.CONF_UPDATE
            };
            this.sendOrderDeviceEdge(
              this.orderDeviceEdgeConfUpdate,
              ordPayload
            );
          } else {
            // アップロード失敗
            this.$ons.notification.alert(
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // `confファイルアップロードに失敗しました\n:${uploadConfResponse.data.errorMessage}`,
              // { title: "失敗" }
              messageFormat(DIALOG_MESSAGES['00200012'].message, uploadConfResponse.data.errorMessage),
              { title: DIALOG_MESSAGES['00200012'].title }
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            );
            this.isRunning = false;
          }
        } catch (error) {
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
          getErrorMessage('DeviceEdgeManageMainComponent.vue', 'confFileUpdate', 'ファイルのダウンロードに失敗しました');
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
          if (error.response.status === 400) {
            this.$ons.notification.alert(
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // `confファイルアップロードに失敗しました\n:${error.response.data.errorMessage}`,
              // { title: "失敗" }
              messageFormat(DIALOG_MESSAGES['00200012'].message, error.response.data.errorMessage),
              { title: DIALOG_MESSAGES['00200012'].title }
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            );
          } else {
            this.$ons.notification.alert(
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // `confファイルアップロードに失敗しました\n:${error}`,
              // { title: "失敗" }
              messageFormat(DIALOG_MESSAGES['00200012'].message, error),
              { title: DIALOG_MESSAGES['00200012'].title }
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            );
          }
          this.isRunning = false;
        }
      }
      return true;
    },
    sendOrderDeviceEdge(func, arg) {
      this.isRunning = true;
      func(arg)
        .then(() => {
          this.$ons.notification.alert({
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // title: "通知成功",
            // message: "デバイスエッジ通知成功"
            title: DIALOG_MESSAGES['00100004'].title,
            message: messageFormat(DIALOG_MESSAGES['00100004'].message)
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          });
          this.isRunning = false;
        })
        .catch((error) => {
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
          getErrorMessage('DeviceEdgeManageMainComponent.vue', 'sendOrderDeviceEdge', error);
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
          if (error.response && error.response.data) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "通知失敗",
              // message: error.response.data.errorMessage
              title: DIALOG_MESSAGES["00300012"].title,
              message: error.response.data.errorMessage
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            });
          } else {
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "通知失敗",
              // message: error
              title: DIALOG_MESSAGES["00300012"].title,
              message: error
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            });
          }
          this.isRunning = false;
        });
    },
    loadData() {
      this.fetchDeviceEdgeState().then((res) => {
        if (res.data.versionInformation) {
          const vInfo = res.data.versionInformation;
          if (typeof vInfo === "string") {
            this.versionInfo = JSON.parse(vInfo);
          } else if (typeof vInfo === "object") {
            this.versionInfo = vInfo;
          } else {
            this.versionInfo = null;
          }
        } else {
          this.versionInfo = null;
        }
        if (res.data.manageNo !== null && res.data.responseStatus !== 2) {
          this.planInfo = {
            manageNo: res.data.manageNo,
            manageInfo: res.data.manageInfo,
            managePlanDate: res.data.managePlanDate,
            responseStatus: res.data.responseStatus
          };
        } else {
          this.planInfo = {
            manageNo: null,
            manageInfo: null,
            managePlanDate: null,
            responseStatus: null
          };
        }
      });
      this.fetchConfFileInfo().then((res) => {
        this.targetDlDeZipFile.exists = res.data.exists;
        this.targetDlDeZipFile.fileDate = res.data.modifiedDate;
        this.targetDlDeZipFile.fileName = res.data.fileName;
        this.targetDlDeZipFile.modifiedDate = res.data.modifiedDate;
        this.targetDlDeZipFile.bucket = res.data.bucket;
        this.targetDlDeZipFile.message = res.data.message;
        if (res.data.exists) {
          // ダウンロード対象有り
          const fileDate = moment(res.data.modifiedDate).format(
            "YYYY/MM/DD HH:mm:ss"
          );
          this.targetDlDeZipFile.fileDate = fileDate;
        }
      });
      this.$nextTick(() => {
        this.setClientWidth();
      });
    },
    // パンくずリストをクリックされた場合に呼び出される関数
    refresh() {
      // 他の画面に遷移したときもrefresh()が発生する為、自分の画面のみ処理する
      if (this.selfScreenName === this.$router.currentRoute.name) {
        this.loadData();
      }
    },
    setClientWidth() {
      if (this.splittedWidth) {
        this.blockWidth = this.splittedWidth - 40;
      }
    }
  },
  watch: {
    splittedWidth(value) {
      // 表示幅設定
      this.setClientWidth(value);
    }
  },
  created() {
    // 画面名称取得
    this.selfScreenName = this.$router.currentRoute.name;
    // add 性能改善メモリ不足 shan start
    EventBus.$off("refresh", this.refresh);
    // add 性能改善メモリ不足 shan end
    EventBus.$on("refresh", this.refresh);
    
    // DEログのダウンロードにデフォルト値のsysdate設定
    this.targetLogFileDate = dateFormat.format(new Date(), DATE_FORMAT);
  },
  mounted() {
    this.loadData();
    this.fetchDeviceEdgeBaseBucket().then(r => {
      this.targetFilePath = r.data.bucket;
    });
    EventBus.$emit("calcModalButtonAreaFrontHeader");
  },
  beforeDestroy() {
    EventBus.$off("refresh", this.refresh);
    EventBus.$emit("calcModalButtonAreaFrontHeader");
  }
};
</script>
<style scoped>
.main-content-area {
  display: flex;
  flex-direction: column;
}
.main-content-block {
  margin-left: auto;
  margin-right: auto;
}
.updater-content-block {
  margin-bottom: 20px;
}

.version_label {
  margin-left: 10px;
  font-size: 1.5em;
}

.manage-button-all {
  margin-top: 3px;
  margin-bottom: 3px;
  width: 100%;
}
.manage-button-update-l {
  margin-right: 2%;
  margin-top: 3px;
  margin-bottom: 3px;
  width: 48%;
}
.manage-button-update-r {
  margin-left: 2%;
  margin-top: 3px;
  margin-bottom: 3px;
  width: 48%;
}
.manage-button {
  margin-right: 10px;
  margin-top: 3px;
  margin-bottom: 3px;
  width: 7em;
}
.log-download-button {
  margin-left: 10px;
}

.control,
.re_control {
  display: inline-block;
}

.input-box {
  width: 25em;
}

.input-box-path {
  width: 62%;
}
.input-box-file {
  width: 32%;
}

.title {
  min-width: 15em;
}

.no-input-label {
  min-width: 15em;
  font-size: 1.5em;
}

.hidden-item {
  display: none;
}
.vertical-div {
  display: flex;
  flex-direction: column;
  align-content: flex-start;
}
.horizontal-div {
  display: flex;
  flex-direction: row;
}
.fill-width {
  overflow-x: auto;
  overflow-y: hidden;
}
.file-path-separator {
  font-size: 1.5em;
  margin-left: 2px;
  margin-right: 2px;
}
</style>
