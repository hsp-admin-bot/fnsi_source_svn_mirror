/** * マスタメンテナンス 装置自動登録（モーダルコンポーネント） */
<template>
  <modal-base @onClose="closeModal(false)">
    <div slot="header">
      <component :is="header" />
    </div>
    <div slot="body">
      <div modal-body>
        <div
          class="machine-record-list-wrapper"
          :style="{ height: gridHeight + 'px' }"
        >
          <table class="machine-list">
            <thead>
              <tr class="machine-list-header">
                <th width="20%">通信種別</th>
                <th width="35%">通信フォーマット</th>
                <th width="45%">型式</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(machineRecord, index) in machineList" :key="index">
                <td>{{ machineRecord.comTypeName }}</td>
                <td>{{ machineRecord.comFormatName }}</td>
                <td>
                  <v-ons-select
                    select-id="com-format-cd"
                    v-model="machineRecord.machineType"
                    name="com-format-cd"
                    :disabled="!searchEnabled"
                  >
                    <option
                      v-for="(item, index) in filterMachineType(machineRecord)"
                      :key="index"
                      :value="item.value"
                    >
                      {{ item.text }}
                    </option>
                  </v-ons-select>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <div class="infomationbox" id="infomation-box">
          <p>検索を開始する場合は登録したいすべての装置の</p>
          <p>電源を入れて通信可能な状態としてください。</p>
          <p>【現在の検出台数：{{ countDetection }} 台】</p>
        </div>
      </div>
    </div>
    <div slot="footer" class="flex-container" id="footer">
      <div class="denial-btn-area" style="background: none">
        <v-ons-button class="btn2-cancel denial-btn" @click="closeModal(false)"
          >キャンセル</v-ons-button
        >
      </div>
      <div
        v-show="searchEnabled"
        class="registration-btn-area"
        style="background: none"
      >
        <v-ons-button class="btn1-execute registration-btn" @click="startSearch"
          >検索開始</v-ons-button
        >
      </div>
      <div
        v-show="!searchEnabled"
        class="registration-btn-area"
        style="background: none"
      >
        <v-ons-button
          class="btn1-execute registration-btn"
          @click="closeModal(true)"
          >検索終了</v-ons-button
        >
      </div>
    </div>
  </modal-base>
</template>

<script>
import ModalBase from "@/components/modals/ModalBase";
import { mapActions, mapGetters } from "vuex";
import { deepCopy } from "@/functions/common/CommonFunctions";
import { EventBus } from "@/eventBus.js";
import { dateFormat, DATE_FORMAT } from "@/functions/common/DateTimeUtils.js";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from "@/functions/common/MessageFormat";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
export default {
  name: "MntFindMachine",
  components: {
    "modal-base": ModalBase,
  },
  data() {
    return {
      header: "",
      machineList: [
        {
          comTypeCd: 1,
          comTypeName: "新通信",
          comFormatCd: "I",
          comFormatName: "DCS(I)",
          machineType: "075",
        },
        {
          comTypeCd: 1,
          comTypeName: "新通信",
          comFormatCd: "J",
          comFormatName: "DBB(J)",
          machineType: "076",
        },
        {
          comTypeCd: 1,
          comTypeName: "新通信",
          comFormatCd: "M",
          comFormatName: "DCS・DCG(M)",
          machineType: "071",
        },
        {
          comTypeCd: 1,
          comTypeName: "新通信",
          comFormatCd: "N",
          comFormatName: "DBB・DBG(N)",
          machineType: "072",
        },
        // add #7663 C重複情報のメッセージ画面を表示する。 zhou start
        {
          comTypeCd: 1,
          comTypeName: "新通信",
          comFormatCd: "P",
          comFormatName: "DCS(P)",
          machineType: "069",
        },
        // add #7663 C重複情報のメッセージ画面を表示する。 zhou end
        // #10079 2023.11.27 del 装置検索登録画面にてDCS(P)が2つ表示される TDC米沢 start
        // {
        //   comTypeCd: 1,
        //   comTypeName: "新通信",
        //   comFormatCd: "P",
        //   comFormatName: "DCS(P)",
        //   machineType: "071"
        // },
        // #10079 2023.11.27 del 装置検索登録画面にてDCS(P)が2つ表示される TDC米沢 end
        {
          comTypeCd: 1,
          comTypeName: "新通信",
          comFormatCd: "Q",
          comFormatName: "DBB(Q)",
          // #10080 2023.11.27 mod 装置検索登録の初期値について TDC米沢 start
          //machineType: "072",
          machineType: "070",
          // #10080 2023.11.27 mod 装置検索登録の初期値について TDC米沢 end
        },
        {
          comTypeCd: 2,
          comTypeName: "NX通信",
          comFormatCd: "A",
          comFormatName: "DAB(A)",
          // #10080 2023.11.27 mod 装置検索登録の初期値について TDC米沢 start
          //machineType: "181",
          machineType: "180",
          // #10080 2023.11.27 mod 装置検索登録の初期値について TDC米沢 end
        },
        {
          comTypeCd: 2,
          comFormatCd: "D",
          comTypeName: "NX通信",
          comFormatName: "DAD(D)",
          // #10080 2023.11.27 mod 装置検索登録の初期値について TDC米沢 start
          //machineType: "261",
          machineType: "260",
          // #10080 2023.11.27 mod 装置検索登録の初期値について TDC米沢 end
        },
        {
          comTypeCd: 2,
          comTypeName: "NX通信",
          comFormatCd: "R",
          comFormatName: "DRO(R)",
          // #10080 2023.11.27 mod 装置検索登録の初期値について TDC米沢 start
          //machineType: "291",
          machineType: "290",
          // #10080 2023.11.27 mod 装置検索登録の初期値について TDC米沢 end
        },
        {
          comTypeCd: 2,
          comTypeName: "NX通信",
          comFormatCd: "I",
          comFormatName: "DRY-50A(I)",
          machineType: "262",
        },
        {
          comTypeCd: 2,
          comTypeName: "NX通信",
          comFormatCd: "J",
          comFormatName: "DRY-50B(J)",
          machineType: "263",
        },
      ],
      countDetection: 0,
      searchEnabled: true,
      messageList: [],
      timerId: 0,
      gridHeight: 150,
    };
  },
  computed: {
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
    }),
    ...mapGetters("account-edit", {
      getFontSize: "getFontSize",
      accountInfo: "getStateUserAccountInfo",
    }),
    ...mapGetters("mst-machine", {
      getMachineTypeList: "getMachineTypeList",
      getMntFindMachineList: "getMntFindMachineList",
      getSelectedFacilityCd: "getSelectedFacilityCd",
    }),
    ...mapGetters("master-maintenance", {
      getMasterRecordList: "getMasterRecordList",
      getFilteredMasterRecordList: "getFilteredMasterRecordList",
      getUpdateRecordList: "getUpdateRecordList",
      editRecord: "getEditRecord",
    }),
    masterRecords() {
      // storeからデータを取得
      return this.getMasterRecordList;
    },
  },
  methods: {
    ...mapActions("multi-modal", ["hideModal"]),
    ...mapActions("mst-machine", [
      "getMntFindMachineListByFacility",
      "notificationMachine",
      "setMessageList",
    ]),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount: "resetLoadingScreenVisibleCount",
    }),
    ...mapActions("master-maintenance", ["setMasterRecordList"]),
    // Windowの高さからGirdコンポーネント領域の高さを算出
    calculateGridHeight() {
      // モーダルのbodyの高さ
      const mb = document.getElementsByClassName("modal-body")[0];
      const mh = mb ? mb.clientHeight : 0;
      // モーダルのヘッダの高さ
      const hElm = document.getElementById("infomation-box");
      const hh = hElm ? hElm.clientHeight : 0;
      this.gridHeight = mh - hh;
      -35;
    },
    filterMachineType(machineRecord) {
      let filterMachineType = [];
      for (const machineType of this.getMachineTypeList) {
        const comType = JSON.parse(machineType.com_type);
        if (comType) {
          const findComType = comType.find(
            (x) => Number(x.value) === machineRecord.comTypeCd
          );
          if (findComType) {
            const findComFormat = findComType.com_format_cd.find(
              (y) => y.value === machineRecord.comFormatCd
            );
            if (findComFormat) {
              filterMachineType.push(machineType);
            }
          }
        }
      }
      return filterMachineType;
    },
    closeModal(isSuccess) {
      if (!this.searchEnabled) {
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
        // const title = "装置検索終了";
        const title = DIALOG_MESSAGES["00100012"].title;
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        // 装置検索終了指示
        this.notificationMachine({
          procMode: 0,
          facilityCd: this.getSelectedFacilityCd,
        })
          .then(() => {
            //共通ローダー：表示終了
            this.setLoadingScreenVisible(false);
            this.$ons.notification.alert({
              title: title,
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // message: isSuccess ? "装置検索を終了しました。" : "装置検索を中止しました。"
              message: isSuccess
                ? messageFormat(DIALOG_MESSAGES["00100012"].message)
                : messageFormat(DIALOG_MESSAGES["00100013"].message),
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            });
            if (isSuccess) {
              // 装置マスタ一覧に反映
              this.updateMachineList();
            } else {
              // モーダルを非表示に
              this.hideModal();
            }
          })
          .catch((error) => {
            //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
            getErrorMessage(
              "MntFindMachineMainModalComponent.vue",
              "closeModal",
              "装置検索終了指示の通知に失敗しました。"
            );
            //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
            //共通ローダー：表示終了
            this.setLoadingScreenVisible(false);
            if (error.response.status === 400) {
              this.$ons.notification.alert({
                title: title,
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                // message: "装置検索終了指示の通知に失敗しました。"
                message: messageFormat(DIALOG_MESSAGES["00200068"].message),
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              });
            }
          });
      } else {
        // モーダルを非表示に
        this.hideModal();
      }
    },
    // 全レコードの並び順の最大値を取得
    getMaxSortRank() {
      if (this.masterRecords.data.length > 0) {
        return this.masterRecords.data.reduce(
          (a, b) => Math.max(a, +b.sortRank >= 999999 ? 0 : +b.sortRank),
          0
        );
      }
      return 0;
    },
    getMaxCode() {
      if (this.masterRecords.data.length > 0) {
        return this.masterRecords.data.reduce(
          (a, b) => Math.max(a, +b.code),
          0
        );
      }
      return 0;
    },
    updateMachineList() {
      // 検索終了時の処理
      this.getMntFindMachineListByFacility(this.getSelectedFacilityCd).then(
        () => {
          this.messageList = [];
          let newMasterRecords = deepCopy(this.masterRecords);
          let maxSortRank = this.getMaxSortRank();
          let maxCode = this.getMaxCode();
          for (const findMntMachine of this.getMntFindMachineList) {
            const findMachine = this.machineList.find((i) => {
              return (
                i.comTypeCd === findMntMachine.comType &&
                i.comFormatCd === findMntMachine.comFormatCd
              );
            });
            if (findMachine) {
              if (findMachine.machineType !== "") {
                // mod #7663 C重複情報のメッセージ画面を表示する。 xiaosonglei start
                // const findMachineIndex = this.masterRecords.data.findIndex(
                //   x => {
                //     // 型式
                //     return (
                //       x.machineTypeCd === findMachine.machineType &&
                //       // 製造番号
                //       x.machineSerial === findMntMachine.machineSerial &&
                //       // 通信フォーマット
                //       x.comFormatCd === findMntMachine.comFormatCd &&
                //       // 通信種別
                //       Number(x.comType) === findMntMachine.comType
                //     );
                //   }
                // );
                const findMachineIndex = this.masterRecords.data.findIndex(
                  (x) => {
                    return (
                      // 施設コード
                      x.facilityCd === findMntMachine.facilityCd &&
                      // 型式
                      x.machineTypeCd === findMachine.machineType &&
                      // #10114 2024.01.23 mod 既存装置を「施設CD、製造番号、型式」にて検索を行う TDC米沢 start
                      //// 製造番号
                      //x.machineSerial === findMntMachine.machineSerial &&
                      //// 通信フォーマット
                      //x.comFormatCd === findMntMachine.comFormatCd &&
                      //// 通信種別
                      //Number(x.comType) === findMntMachine.comType
                      // 製造番号
                      x.machineSerial === findMntMachine.machineSerial
                      // #10114 2024.01.23 mod 既存装置を「施設CD、製造番号、型式」にて検索を行う TDC米沢 end
                    );
                  }
                );
                // mod #7663 C重複情報のメッセージ画面を表示する。 xiaosonglei end
                if (findMachineIndex === -1) {
                  // 新規追加
                  maxSortRank = maxSortRank + 1;
                  maxCode = maxCode + 1;
                  const treatMode = this.getMachineTypeList.find(
                    (x) => (x.value = findMachine.machineType)
                  ).treat_mode;
                  let treatModeList = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
                  if (treatMode !== null && treatMode.length >= 10) {
                    treatModeList = treatMode.split("");
                  }
                  newMasterRecords.data.push({
                    // 基本設定
                    code: maxCode,
                    edited: true,
                    operation: 1,
                    machineName: "",
                    machineTypeCd: findMachine.machineType,
                    machineSerial: findMntMachine.machineSerial,
                    comFormatCd: findMachine.comFormatCd,
                    comType: findMachine.comTypeCd,
                    ipAddress: findMntMachine.ipAddress,
                    port: 1401,
                    settingDate: dateFormat.format(new Date(), DATE_FORMAT),
                    version: "",
                    isFtp: 0,
                    isVa: 0,
                    deleteDate: "",
                    // del #7663 C重複情報のメッセージ画面を表示する。 zhou start
                    //isDisable: 0,
                    // del #7663 C重複情報のメッセージ画面を表示する。 zhou end
                    isDisp: "1",
                    // 装置モード
                    isSupportHd: treatModeList[0] ? "1" : "0",
                    isSupportEcum: treatModeList[1] ? "1" : "0",
                    isSupportHdf: treatModeList[2] ? "1" : "0",
                    isSupportHf: treatModeList[3] ? "1" : "0",
                    isSupportHdHo: treatModeList[4] ? "1" : "0",
                    isSupportEcumHo: treatModeList[5] ? "1" : "0",
                    isSupportAfbf: treatModeList[6] ? "1" : "0",
                    isSupportOhdf: treatModeList[7] ? "1" : "0",
                    isSupportOhf: treatModeList[8] ? "1" : "0",
                    isSupportIHdf: treatModeList[9] ? "1" : "0",
                    isSupportBloodPurify: treatModeList[10] ? "1" : "0",
                    // TMPゼロ補正中点
                    tmpCenterHd: -30,
                    tmpCenterEcum: -65,
                    tmpCenterHdf: -30,
                    tmpCenterHf: -65,
                    tmpCenterHdHo: -30,
                    tmpCenterOhdf: -30,
                    tmpCenterOhf: -65,
                    deviceEdgeNo: findMntMachine.deviceEdgeNo,
                    // メモ
                    memo: "",
                    // add #7663 C重複情報のメッセージ画面を表示する。 zhou start
                    isDel: "0",
                    // del #7663 C重複情報のメッセージ画面を表示する。 zhou end
                    // ソート番号
                    sortRank: maxSortRank,
                  });
                } else {
                  // #10114 2024.01.23 mod 既存装置を「施設CD、製造番号、型式」にて検索した結果、該当装置がある場合は更新を行う TDC米沢 start
                  // if (
                  //   this.masterRecords.data[findMachineIndex].ipAddress !==
                  //   findMntMachine.ipAddress
                  // ) {
                  //   // IPアドレスのチェックで違う場合は書換え
                  //   newMasterRecords.data[findMachineIndex].ipAddress =
                  //     findMntMachine.ipAddress;
                  //   newMasterRecords.data[findMachineIndex].edited = true;
                  //   newMasterRecords.data[findMachineIndex].operation = 2;
                  // } else {
                  //   // メッセージに追加
                  //   this.messageList.push({
                  //     machineTypeName: this.getMachineTypeList.find(
                  //       (x) => (x.value = findMachine.machineType)
                  //     ).text,
                  //     machineSerial: findMntMachine.machineSerial,
                  //     comFormatName: findMachine.comFormatName,
                  //     comType: findMachine.comTypeName,
                  //     ipAddress: findMntMachine.ipAddress,
                  //   });
                  // }

                  // 装置情報と検索結果を比較
                  if (
                    // 通信フォーマット
                    this.masterRecords.data[findMachineIndex].comFormatCd ===
                      findMntMachine.comFormatCd &&
                    // 通信種別
                    Number(
                      this.masterRecords.data[findMachineIndex].comType
                    ) === findMntMachine.comType &&
                    // IPアドレス
                    this.masterRecords.data[findMachineIndex].ipAddress ===
                      findMntMachine.ipAddress &&
                    // デバイスエッジNo
                    Number(
                      this.masterRecords.data[findMachineIndex].deviceEdgeNo
                    ) === findMntMachine.deviceEdgeNo &&
                    // 表示フラグ
                    this.masterRecords.data[findMachineIndex].isDisp === "1" &&
                    // 削除フラグ
                    this.masterRecords.data[findMachineIndex].isDel === "0"
                  ) {
                    // 装置情報が検索結果と同じ場合は装置情報を更新しない

                    // メッセージに追加
                    this.messageList.push({
                      machineTypeName: this.getMachineTypeList.find(
                        (x) => (x.value = findMachine.machineType)
                      ).text,
                      machineSerial: findMntMachine.machineSerial,
                      comFormatName: findMachine.comFormatName,
                      comType: findMachine.comTypeName,
                      ipAddress: findMntMachine.ipAddress,
                    });
                  } else {
                    // 装置情報が検索結果が異なる場合は装置情報を更新する
                    // 通信フォーマット
                    newMasterRecords.data[findMachineIndex].comFormatCd =
                      findMntMachine.comFormatCd;
                    // 通信種別
                    newMasterRecords.data[findMachineIndex].comType =
                      findMntMachine.comType;
                    // IPアドレス
                    newMasterRecords.data[findMachineIndex].ipAddress =
                      findMntMachine.ipAddress;
                    // デバイスエッジNo
                    newMasterRecords.data[findMachineIndex].deviceEdgeNo =
                      findMntMachine.deviceEdgeNo;

                    // 表示フラグ
                    newMasterRecords.data[findMachineIndex].isDisp = "1";
                    // 削除フラグ
                    newMasterRecords.data[findMachineIndex].isDel = "0";

                    newMasterRecords.data[findMachineIndex].edited = true;
                    newMasterRecords.data[findMachineIndex].operation = 2;
                  }
                  // #10114 2024.01.23 mod 既存装置を「施設CD、製造番号、型式」にて検索した結果、該当装置がある場合は更新を行う TDC米沢 end
                }
              }
            }
          }
          this.setMasterRecordList(newMasterRecords);
          this.setMessageList(this.messageList);
          // モーダルを非表示に
          this.hideModal();
          EventBus.$emit("messageMachine");
        }
      );
    },
    startSearch() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      const title = DIALOG_MESSAGES["00100014"].title;
      // マスタ同期
      this.notificationMachine({
        procMode: 1,
        facilityCd: this.getSelectedFacilityCd,
      })
        .then(() => {
          //共通ローダー：表示終了
          this.setLoadingScreenVisible(false);
          this.$ons.notification.alert({
            title: title,
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // message: "装置検索を開始しました。"
            message: messageFormat(DIALOG_MESSAGES["00100014"].message),
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          });
          this.searchEnabled = false;
        })
        .catch((error) => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage(
            "MntFindMachineMainModalComponent.vue",
            "startSearch",
            "装置検索開始指示の通知に失敗しました。"
          );
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          //共通ローダー：表示終了
          this.setLoadingScreenVisible(false);
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              title: title,
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // message: "装置検索開始指示の通知に失敗しました。"
              message: messageFormat(DIALOG_MESSAGES["00200069"].message),
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            });
            return;
          }
        });
    },
    startPolling() {
      this.endPolling();
      this.timerId = setInterval(this.numberOfDevices, 30000);
    },
    endPolling() {
      clearInterval(this.timerId);
    },
    numberOfDevices() {
      const that = this;
      this.getMntFindMachineListByFacility(this.getSelectedFacilityCd).then(
        () => {
          that.countDetection = that.getMntFindMachineList.length;
        }
      );
    },
    calculateModalWidthHeight() {
      document.getElementsByClassName("modal-container")[0].style.maxWidth =
        "600px";
      document.getElementsByClassName("modal-container")[0].style.maxHeight =
        "580px";
      ("70%");

      document.getElementsByClassName("modal-container")[0].style.width = "58%";
      document.getElementsByClassName("modal-container")[0].style.height =
        "70%";
      document.getElementsByClassName("modal-body")[0].style.overflow =
        "hidden";
      // mod redmine 5069 スマホ、装置検索登録モーダル内の表示不正 孔 start
      // document.getElementsByClassName("modal-body")[0].style.height =
      //   "calc(100% - 40px - 2em)";
      const modalBodyHeight =
        document.getElementsByClassName("modal-body")[0].offsetHeight;
      document.getElementsByClassName("modal-body")[0].style.height = `calc( ${
        modalBodyHeight + 5
      }px + 1em)`;
      // mod redmine 5069 スマホ、装置検索登録モーダル内の表示不正 孔 end
    },
  },
  watch: {
    windowHeight() {
      this.calculateGridHeight();
    },
    isDispMenu() {
      this.calculateGridHeight();
    },
    getFontSize() {
      this.calculateGridHeight();
    },
  },
  mounted() {
    // 画面高さと幅を調整
    this.calculateModalWidthHeight();
    // ポーリング開始
    this.startPolling();
    this.$nextTick(() => {
      this.calculateGridHeight();
    });
  },
  beforeDestroy() {
    // ポーリング終了
    this.endPolling();
  },
};
</script>

<style scoped>
#footer {
  margin: 0;
  padding: 5px 5px 0px 5px;
  bottom: 0;
  position: relative;
  width: inherit;
}

table {
  border-collapse: collapse;
}

table th,
table td {
  border: solid 1px var(--ntss-list-border-color);
}

.machine-record-list-wrapper {
  overflow: auto;
}

table.machine-list {
  width: 100%;
}

table.machine-list thead {
  color: white;
  background-color: var(--ntss-list-header-background-color);
}

table.machine-list thead tr.machine-list-header th {
  background-color: var(--ntss-list-header-background-color);
  font-weight: 100;
  position: -webkit-sticky;
  position: sticky;
  --top: 0px;
  top: var(--top);
  z-index: 1;
}

table.machine-list thead tr {
  height: 33px;
}

table.machine-list tbody tr.even-row {
  background-color: var(---ntss-list-item-background-color);
}

table.machine-list tbody tr.odd-row {
  background-color: var(--ntss-list-content-2nd-background-color);
}

table.machine-list tbody tr td.send-checkbox {
  text-align: center;
}

.title {
  width: 12em;
}

tr {
  height: 2em;
  padding: 0 0.75rem;
}

.machine-record-list-wrapper tr:hover {
  background-color: var(--master-maintenance-kgrid-item-hover-background-color);
}

.select {
  width: 99%;
  height: 2em;
  min-height: 31px;
  font-size: 1em;
  display: flex;
  align-items: center;
}

.select >>> .select-input {
  font-size: 1em;
  line-height: unset;
}

.center {
  text-align: center;
}

.vertical-middle {
  vertical-align: middle;
}

.margin-left {
  margin: 0 0 0 2.76em;
}

.infomationbox {
  width: 100%;
  background-color: #89c7de;
  color: #fff;
  text-align: center;
  padding: 13px 0;
  position: absolute;
  bottom: 0;
}

.infomationbox p {
  margin: 0;
  padding: 0;
}
</style>
