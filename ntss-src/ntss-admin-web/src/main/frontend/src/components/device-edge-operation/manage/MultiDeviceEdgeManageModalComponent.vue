/**
 * 複数施設DE更新モーダルPage
 */
 <template>
  <modal-base @onClose="closeDeviceEdgeManageModal">
    <template #header>
      <div>
      <component :is="header"></component>
    </div>
    </template>
    <template #body>
      <div>
      <div id="de-manage-modal-header">
        <!-- 共通IF -->
        <v-ons-row>
          <div class="horizontal-div">
            <!-- 実行時刻 -->
            <div>
              <label class="de-manage-modal-label" :disabled="!isAdminUser">実行日時</label>
            </div>
            <div>
              <input type="datetime-local" v-model="planDayStartTime" :disabled="!isAdminUser" />
            </div>
            <!-- 適用ファイル -->
            <div>
              <label class="de-manage-modal-label">適用ファイル</label>
            </div>
            <div>
              <input
                type="text"
                placeholder="更新用zipファイルパス"
                v-model="targetFilePath"
                :disabled="!isAdminUser"
              />
              <label class="path-separator">/</label>
              <input
                type="text"
                class="input-filename"
                v-model="targetFileName"
                placeholder="ファイル名"
                :disabled="!isAdminUser"
              />
            </div>
          </div>
        </v-ons-row>
      </div>
      <div modal-body>
        <!-- デバイスエッジ一括管理検索 -->
        <div class="de-manage-search-wrapper" id="de-manage-search-area">
          <multi-device-manage-search />
        </div>
        <!-- 一覧 -->
        <div
          class="de-manage-list-wrapper"
          :style="{ 'height':gridHeight + 'px', 'width':gridWidth + 'px' }"
        >
          <!-- グリッド -->
          <table class="ntss-list" id="de-manage-list">
            <thead>
              <tr class="de-manage-list-header">
                <th id="column-01">
                  <v-ons-checkbox
                    class="head-check"
                    :checked="isAllSelect"
                    @change="onAllSelect"
                    :disabled="!isAdminUser"
                  ></v-ons-checkbox>
                </th>
                <th id="column-02">部署符号</th>
                <th id="column-03">都道府県</th>
                <th id="column-04">施設</th>
                <th id="column-05">デバイスエッジ名</th>
                <th id="column-06">
                  個別実行日時
                  <v-ons-icon
                    icon="fa-question-circle"
                    @click="showPopOver($event, '日時が未設定の場合は共通の実行日時を使用します')"
                  ></v-ons-icon>
                </th>
                <th id="column-08">
                  個別適用ファイル
                  <v-ons-icon
                    icon="fa-question-circle"
                    @click="showPopOver($event, 'ファイル名が未設定の場合は共通の適用ファイルを使用します')"
                  ></v-ons-icon>
                </th>
                <th id="column-09">予約状態・日時</th>
                <th id="column-10">キャンセル</th>
                <th
                  class="column-11"
                  v-for="(keyName, idx) in deviceEdgeVersionKeys"
                  :key="keyName + idx"
                >{{ keyName.replace('ntss_', '').replace('.exe', '') }}</th>
              </tr>
            </thead>
            <tr
              v-for="(deData, idx) in filterDeviceEdge"
              :key="idx"
              :class="getRowClass(deData) + ' ntss-list-body-tr'"
            >
              <td id="column-01" class="ntss-list-body-td">
                <v-ons-checkbox
                  :input-id="'checkbox-' + idx"
                  v-model="deData.isSend"
                  @change="onSingleSelect(deData)"
                  :disabled="!isAdminUser"
                ></v-ons-checkbox>
              </td>
              <td id="column-02" class="ntss-list-body-td">{{deData.departmentCd}}</td>
              <td id="column-03" class="ntss-list-body-td">{{deData.prefName}}</td>
              <td id="column-04" class="ntss-list-body-td">{{deData.facilityName}}</td>
              <td id="column-05" class="ntss-list-body-td">{{deData.deviceEdgeName}}</td>
              <td id="column-06" class="ntss-list-body-td">
                <input type="datetime-local" v-model="deData.sendDateTime" :disabled="!isAdminUser" />
              </td>
              <td id="column-08" class="ntss-list-body-td">
                <input
                  type="text"
                  v-model="deData.targetPath"
                  placeholder="更新用zipファイルパス"
                  :disabled="!isAdminUser"
                />
                <label class="path-separator">/</label>
                <input
                  type="text"
                  class="input-filename"
                  v-model="deData.targetFile"
                  placeholder="ファイル名"
                  :disabled="!isAdminUser"
                />
              </td>
              <td id="column-09" class="ntss-list-body-td">
                <!-- #12003 2025.12.24 mod 指示後のデータ再取得時に未応答ならば専用表示 TDC片口 start -->
                <!-- {{deData.deviceStatus}}
                <v-ons-icon
                  v-if="deData.deviceErrMessage"
                  icon="fa-question-circle"
                  @click="showPopOver($event, deData.deviceErrMessage)"
                ></v-ons-icon>
                <br />
                {{deData.managePlanDate}} -->
                <template
                  v-if="checkIsOrderedTargetEdge('request', deData.facilityCd, deData.deviceEdgeNo)"
                >
                  {{ autoReloadCount >= 5 ? '予約失敗' : '予約実行済み' }}
                </template>
                <template
                  v-else-if="checkIsOrderedTargetEdge('cancel', deData.facilityCd, deData.deviceEdgeNo)"
                >
                  {{ autoReloadCount >= 5 ? '予約取消失敗' : '予約取消実行済み' }}
                </template>
                <template v-else>
                  {{deData.deviceStatus}}
                  <v-ons-icon
                    v-if="deData.deviceErrMessage"
                    icon="fa-question-circle"
                    @click="showPopOver($event, deData.deviceErrMessage)"
                  ></v-ons-icon>
                  <br />
                  {{deData.managePlanDate}}
                </template>
                <!-- #12003 2025.12.24 mod 指示後のデータ再取得時に未応答ならば専用表示 TDC片口 end -->
              </td>
              <td id="column-10" class="ntss-list-body-td">
                <v-ons-button
                  class="button btn2-cancel denial-btn"
                  :disabled="!isAdminUser"
                  @click="onPlanCancelSingle(deData)"
                >予約取消</v-ons-button>
              </td>
              <td
                class="column-11 ntss-list-body-td"
                v-for="(keyName, idx) in deviceEdgeVersionKeys"
                :key="keyName + idx"
              >{{deData.versionInformation ? deData.versionInformation[keyName] : ""}}</td>
            </tr>
          </table>
        </div>
      </div>
    </div>
    </template>

    <template #footer>
      <div class="flex-container" style="overflow-x: auto;">
      <div class="denial-btn-area" style="background:none">
        <v-ons-button class="button btn2-cancel denial-btn" @click="closeDeviceEdgeManageModal">キャンセル</v-ons-button>
        <v-ons-button
          id="multi-plan-cancel-button"
          class="button btn4-alert denial-btn"
          @click="onPlanCancel"
          :disabled="!isAdminUser"
        >予約取消</v-ons-button>
      </div>
      <div class="registration-btn-area" style="background:none">
        <v-ons-button class="button btn1-execute registration-btn" @click="confirm" :disabled="!isAdminUser">実行</v-ons-button>
      </div>
      <v-ons-popover
        cancelable
        v-model:visible="userMenuPopoverVisible"
        :target="userMenuPopoverTarget"
        :cover-target="false"
        :direction="userMenuPopoverDirection"
        :class="fontSizeSet"
      >
        <div class="help-area">
          <label id="pop-over-de-message" ref="popOverMessage">テスト</label>
        </div>
      </v-ons-popover>
    </div>
    </template>
  </modal-base>
</template>

<script>
import { getScopedElementById, getViewportWidth } from "@/functions/common/LayoutMeasureHelper";
import ModalBase from "@/components/modals/ModalBase";
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import { getScopedWindow } from "@/functions/common/LayoutMeasureHelper";
import { EventBus } from "@/compat/vue/event-bus.js";
import MultiDeviceManageSearchComponent from "@/components/device-edge-operation/manage/MultiDeviceManageSearchComponent";
import dayjs from "@/compat/date/dayjs";
import PopoverMixin from "@/components/PopoverMixin";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end

export default {
  mixins: [PopoverMixin],
  name: "MultiDeviceEdgeManageModal",
  components: {
    "modal-base": ModalBase,
    "multi-device-manage-search": MultiDeviceManageSearchComponent
  },
  data() {
    return {
      header: "",
      tableTop: 0,
      gridToolbarHeight: 500,
      gridHeight: 300,
      gridWidth: 300,
      isAllSelect: false,
      planDayStartTime: null,
      deviceEdgeList: [],
      deviceEdgeVersionKeys: [],
      filterDeviceEdge: [],
      targetFilePath: "",
      targetFileName: "DE_UpdateX.zip",
      // 吹き出し関連制御
      userMenuPopoverVisible: false,
      userMenuPopoverTarget: null,
      userMenuPopoverDirection: "left right",
      // #12003 2025.12.24 add 指示後のデータ再取得時に未応答ならば専用表示 TDC片口 start
      /** @type {Array<{facilityCd:string, deviceEdgeNo:number}>} */
      orderedTargetEdges: [],
      cancelOrderedTargetEdges: [],
      autoReloadTimer: null,
      autoReloadCount: 0,
      // #12003 2025.12.24 add 指示後のデータ再取得時に未応答ならば専用表示 TDC片口 end
    };
  },
  computed: {
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth"
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo"
    }),
    ...mapGetters("device-edge-operation", ["getDeviceEdges"]),
    ...mapGetters("multi-device-edge-manage", ["getCondToEdgeListEx"]),
    // -----------------------------------------
    // 管理者ユーザーか否か
    // 管理者ユーザーの場合、trueを返します。
    // -----------------------------------------
    isAdminUser() {
      return 1 === this.getStateUserAccountInfo.administrator;
    },
    const() {
      return {
        mainAppPhrase: "ntss_main",
        updAppPhrase: "ntss_updater"
      };
    }
  },
  methods: {
    ...mapActions("multi-modal", ["hideModal"]),
    ...mapActions("device-edge-manage", [
      "fetchDeviceEdgeBaseBucket",
      "fetchDeviceEdgeStateAll"
    ]),
    ...mapActions("multi-device-edge-manage", [
      "clearCondToEdgeListEx",
      "orderDeviceEdgeUpdatePlanAll",
      "orderDeviceEdgePlanCancel"
    ]),
    /**
     * デバイスエッジ情報構築
     * @param {Object[]} stateDataList DE状態一覧
     * @param {boolean} isClearDEList true: 一から構築 false: 更新
     */
    buildDeviceEdgeParams(stateDataList, isClearDEList) {
      if (isClearDEList) {
        this.deviceEdgeList = [];
      }
      this.deviceEdgeVersionKeys = [];
      let mainKeys = [], updKeys = [], verKeys = [];
      for (const device of this.getDeviceEdges) {
        const state = stateDataList.find(
          d =>
            d.facilityCd === device.facilityCd &&
            d.deviceEdgeNo === device.deviceEdgeNo
        );
        if (state) {
          if (state.versionInformation && typeof state.versionInformation === "string") {
            state.versionInformation = JSON.parse(state.versionInformation);

            // バージョン情報のキーを収集
            let keys = Object.keys(state.versionInformation);
            for (const key of keys) {
              if (verKeys.includes(key) || mainKeys.includes(key) || updKeys.includes(key)) {
                continue;
              }
              if (key.includes(this.const.mainAppPhrase)) {
                mainKeys.push(key);
              } else if (key.includes(this.const.updAppPhrase)) {
                updKeys.push(key);
              } else {
                verKeys.push(key);
              }
            }
          }
          const planInfo = this.planInfo(state);
          const findEdge = this.deviceEdgeList.find(
            d => d.facilityCd === device.facilityCd && d.deviceEdgeNo === device.deviceEdgeNo
          );

          if (findEdge) {
            findEdge.aliveMoniStatus = device.aliveMoniStatus;
            findEdge.versionInformation = state.versionInformation;
            findEdge.manageInfo = state.manageInfo;
            findEdge.responseStatus = state.responseStatus;
            findEdge.orderClass = state.orderClass;
            findEdge.orderTargetClass = state.orderTargetClass;
            findEdge.manageNo = state.manageNo;
            findEdge.managePlanDate= planInfo.date;
            findEdge.deviceStatus = planInfo.status;
            findEdge.deviceErrMessage = planInfo.message;
          } else {
            this.deviceEdgeList.push({
              facilityCd: state.facilityCd,
              facilityName: device.facilityName,
              deviceEdgeNo: device.deviceEdgeNo,
              deviceEdgeName: device.deviceName,
              aliveMoniStatus: device.aliveMoniStatus,
              versionInformation: state.versionInformation,
              manageInfo: state.manageInfo,
              responseStatus: state.responseStatus,
              orderClass: state.orderClass,
              orderTargetClass: state.orderTargetClass,
              manageNo: state.manageNo,
              managePlanDate: planInfo.date,
              isSend: false,
              sendDateTime: null,
              targetPath: "",
              targetFile: "",
              deviceStatus: planInfo.status,
              deviceErrMessage: planInfo.message,
              departmentCd: device.departmentCd,
              prefName: device.prefName
            });
          }
        }
      }
      this.deviceEdgeVersionKeys = mainKeys.concat(verKeys).concat(updKeys);
    },
    getDeviceEdgeOwnerWindow() {
      return getScopedWindow(this.$el || this);
    },
    getScopedElementById(id) {
      return this.$el?.querySelector?.(`#${id}`) || this.$el?.ownerDocument?.getElementById?.(id) || null;
    },
    getScopedClassElement(className) {
      return this.$el?.getElementsByClassName?.(className)?.[0] || null;
    },
    // Windowの高さからGirdコンポーネント領域の高さを算出
    calculateGridHeight() {
      // モーダルのbodyの高さ
      const mb = this.getScopedClassElement("modal-body");
      const mh = mb ? mb.clientHeight : 0;
      const mw = mb ? mb.clientWidth : 0;
      // モーダルのヘッダの高さ
      const hElm = this.getScopedElementById("de-manage-modal-header");
      const hElm2 = this.getScopedElementById("de-manage-search-area");
      const hh = hElm ? hElm.clientHeight : 0;
      const hh2 = hElm2 ? hElm2.clientHeight : 0;
      this.gridToolbarHeight = mh - hh - hh2;
      this.gridToolbarHeight =
        this.gridToolbarHeight < 100 ? 100 : this.gridToolbarHeight;
      this.gridHeight = this.gridToolbarHeight - 10;
      this.gridWidth = mw - 1;
      if (mh + hh === 0) {
        setTimeout(this.calculateGridHeight, 10);
      }
    },
    closeDeviceEdgeManageModal() {
      // #12003 2025.12.24 add 指示後のデータ再取得時に未応答ならば専用表示 TDC片口 start
      this.getDeviceEdgeOwnerWindow()?.clearTimeout?.(this.autoReloadTimer);
      // #12003 2025.12.24 add 指示後のデータ再取得時に未応答ならば専用表示 TDC片口 end
      // モーダルを非表示に
      this.hideModal();
    },
    // 行の背景色を付与する為のクラスを取得する
    getRowClass(deviceEdge) {
      const aliveMoniStatus = deviceEdge.aliveMoniStatus;
      if (aliveMoniStatus === "F1" || aliveMoniStatus === "F2") {
        return "emergency-row";
      } else if (aliveMoniStatus === "F0") {
        return "com-problem-row";
      }
      return "";
    },
    planInfo(deviceEdge) {
      // 予約があれば「予約あり + 時刻」を表示
      if (deviceEdge.manageNo) {
        const planDate = dayjs(deviceEdge.managePlanDate);
        if (deviceEdge.responseStatus === 3) {
          return {
            cd: deviceEdge.responseStatus,
            status: "予約あり",
            date: planDate.format("YYYY/MM/DD HH:mm:ss"),
            message: null
          };
        } else if (deviceEdge.responseStatus === 2) {
          return {
            cd: deviceEdge.responseStatus,
            status: null,
            date: null,
            message: null
          };
        } else if (deviceEdge.responseStatus >= 0) {
          return {
            cd: deviceEdge.responseStatus,
            status: "依頼中 (応答待ち)",
            date: null,
            message: null
          };
        } else {
          return {
            cd: deviceEdge.responseStatus,
            status: "指示失敗",
            date: null,
            message: deviceEdge.manageInfo.message
          };
        }
      } else {
        return {
          cd: null,
          status: null,
          date: null,
          message: null
        };
      }
    },
    async validConfirm(targetEdge) {
      let count = targetEdge.length;
      if (count === 0) {
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "確認",
          // message: "更新対象が指定されていません"
          title: DIALOG_MESSAGES['00200013'].title,
          message: messageFormat(DIALOG_MESSAGES['00200013'].message)
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
        return false;
      // #12003 2025.12.19 mod 個別実行日時/ファイルのチェック修正 TDC片口 start
      // } else if (!this.planDayStartTime) {
      } else if (!this.validateScheduleDateTime(targetEdge)) {
      // #12003 2025.12.19 mod 個別実行日時/ファイルのチェック修正 TDC片口 end
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "確認",
          // message: "実行日時が指定されていません"
          title: DIALOG_MESSAGES['00200014'].title,
          message: messageFormat(DIALOG_MESSAGES['00200014'].message)
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
        return false;
      // #12003 2025.12.19 mod 個別実行日時/ファイルのチェック修正 TDC片口 start
      // } else if (!this.targetFilePath || !this.targetFileName) {
      } else if (!this.validateScheduleTargetFile(targetEdge)) {
      // #12003 2025.12.19 mod 個別実行日時/ファイルのチェック修正 TDC片口 end
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "確認",
          // message: "更新ファイルが指定されていません"
          title: DIALOG_MESSAGES['00200015'].title,
          message: messageFormat(DIALOG_MESSAGES['00200015'].message)
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
        return false;
      } else {
        // #12003 2025.12.19 mod 個別実行日時/ファイルのチェック修正 TDC片口 start
        // let scheduleDate = dayjs(this.planDayStartTime);
        // let nowDate = dayjs(new Date());
        // let hasBefore = scheduleDate.isBefore(nowDate);
        const scheduleDate = this.planDayStartTime ? dayjs(this.planDayStartTime) : null;
        const nowDate = dayjs(new Date());
        let hasBefore = scheduleDate ? scheduleDate.isBefore(nowDate) : false;
        // #12003 2025.12.19 mod 個別実行日時/ファイルのチェック修正 TDC片口 end
        let preMsg = "";
        if (!hasBefore) {
          for (const target of targetEdge) {
            if (target.sendDateTime) {
              // 個別日付チェック
              const dt = dayjs(target.sendDateTime);
              hasBefore = dt.isBefore(nowDate);
              if (hasBefore) {
                preMsg = "一部の";
                break;
              }
            }
          }
        }
        if (hasBefore) {
          const resOk = await this.$ons.notification.confirm({
            // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
            // title: "確認",
            title: DIALOG_MESSAGES[13000021].title,
            // message: `${preMsg}実行日時に過去が指定されています。<br>即時に更新処理が実行されますがよろしいですか？`
            message: messageFormat(DIALOG_MESSAGES[13000021].message, preMsg),
            // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
          });
          if (resOk !== 1) {
            return false;
          }
        }
        let hasPlan = false;
        for (const target of targetEdge) {
          if (target.manageNo && target.responseStatus >= 0 && target.responseStatus != 2) {
            // 予約あり
            hasPlan = true;
            break;
          }
        }
        if (hasPlan) {
          const resOk = await this.$ons.notification.confirm({
            // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
            // title: "確認",
            title: DIALOG_MESSAGES[13000022].title,
            // message: "予約済みのデバイスエッジがある場合は指示が上書きされますがよろしいですか？"
            message: messageFormat(DIALOG_MESSAGES[13000022].message),
            // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
          });
          if (resOk !== 1) {
            return false;
          }
        }
      }
      return true;
    },
    // #12003 2025.12.19 add 個別実行日時/ファイルのチェック修正 TDC片口 start
    validateScheduleDateTime(targetEdge) {
      let isValid = !!this.planDayStartTime;
      if (isValid) {
        // 共通日付チェック通過ならばそのままtrueを返す
        return true;
      }
      for (const target of targetEdge) {
        if (!target.sendDateTime) {
          // 共通日付が未設定なのに個別日付も未設定ならばfalseを返す
          return false;
        }
      }
      return true;
    },
    validateScheduleTargetFile(targetEdge) {
      let isValid = !!(this.targetFilePath && this.targetFileName);
      if (isValid) {
        // 共通ファイルチェック通過ならばそのままtrueを返す
        return true;
      }
      for (const target of targetEdge) {
        if (!target.targetPath || !target.targetFile) {
          // 共通ファイルが未設定なのに個別ファイルも未設定ならばfalseを返す
          return false;
        }
      }
      return true;
    },
    // #12003 2025.12.19 add 個別実行日時/ファイルのチェック修正 TDC片口 end
    async confirm() {
      // 実行
      const targetEdge = this.deviceEdgeList.filter(de => de.isSend);
      if (!await this.validConfirm(targetEdge)) {
        return false;
      }
      let count = targetEdge.length;
      // #12003 2025.12.19 mod 個別実行日時/ファイルのチェック修正 TDC片口 start
      // let scheduleDate = dayjs(this.planDayStartTime);

      // const resOk = await this.$ons.notification.confirm({
      //   // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
      //   // title: "確認",
      //   title: DIALOG_MESSAGES[13000023].title,
      //   // message: `${count}件のデバイスエッジに${scheduleDate.format("YYYY/MM/DD HH:mm:ss")}予約の更新指示を行います。`
      //   message: messageFormat(DIALOG_MESSAGES[13000023].message,count,scheduleDate.format("YYYY/MM/DD HH:mm:ss")),
      //   // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
      // });
      // if (resOk === 1) {
      //   this.sendPlanOrderDeviceEdge(scheduleDate.format("YYYYMMDDHHmmss"), targetEdge);
      // }

      const scheduleDate = this.planDayStartTime ? dayjs(this.planDayStartTime) : null;

      const resOk = await this.$ons.notification.confirm({
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
        // title: "確認",
        title: DIALOG_MESSAGES[13000023].title,
        // message: `${count}件のデバイスエッジに${scheduleDate.format("YYYY/MM/DD HH:mm:ss")}予約の更新指示を行います。`
        message: messageFormat(DIALOG_MESSAGES[13000023].message, count, scheduleDate?.format("YYYY/MM/DD HH:mm:ss") ?? "個別指定"),
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
      });
      if (resOk === 1) {
        this.sendPlanOrderDeviceEdge(scheduleDate?.format("YYYYMMDDHHmmss") ?? "", targetEdge);
      }
      // #12003 2025.12.19 mod 個別実行日時/ファイルのチェック修正 TDC片口 end
    },
    /**
     * 予約指示発行
     */
    async sendPlanOrderDeviceEdge(basePlanDate, targets) {
      // 指示
      let successCount = 0;
      let errInfo = [];

      // #12003 2025.12.24 add 指示後のデータ再取得時に未応答ならば専用表示 TDC片口 start
      /** @type {Array<{facilityCd:string, deviceEdgeNo:number, manageNo:number}>} */
      const orderedTargets = [];
      // #12003 2025.12.24 add 指示後のデータ再取得時に未応答ならば専用表示 TDC片口 end
      for (const target of targets) {
        const payload = {
          facilityCd: target.facilityCd,
          deviceEdgeNo: target.deviceEdgeNo,
          uploadBucket: this.targetFilePath,
          fileName: this.targetFileName,
          planDate: basePlanDate
        };
        if (target.sendDateTime) {
          // 個別日付に差し替え
          const dt = dayjs(target.sendDateTime);
          payload.planDate = dt.format("YYYYMMDDHHmmss");
        }
        if (target.targetPath && target.targetFile) {
          // 個別ファイルに差し替え
          payload.uploadBucket = target.targetPath;
          payload.fileName = target.targetFile;
        }
        try {
          // #12003 2025.12.24 mod 指示後のデータ再取得時に未応答ならば専用表示 TDC片口 start
          // await this.orderDeviceEdgeUpdatePlanAll(payload);
          // successCount++;

          const result = await this.orderDeviceEdgeUpdatePlanAll(payload);
          successCount++;
          orderedTargets.push({
            facilityCd: target.facilityCd,
            deviceEdgeNo: target.deviceEdgeNo,
            manageNo: result.data.manageParam.manageNo,
          });
          // #12003 2025.12.24 mod 指示後のデータ再取得時に未応答ならば専用表示 TDC片口 end
        } catch(error) {
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
          getErrorMessage('MultiDeviceEdgeManageModalComponent.vue', 'sendPlanOrderDeviceEdge', error);
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end

          if (error.response && error.response.data) {
            errInfo.push(`${target.facilityName} ${target.deviceEdgeName}: ${error.response.data.errorMessage}`);
          } else {
            errInfo.push(`${target.facilityName} ${target.deviceEdgeName}: 処理エラーが発生しました`);
          }
        }
      }
      if (errInfo.length) {
        if (successCount > 0) {
          await this.$ons.notification.alert({
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // title: "失敗あり",
            // message: `${successCount}件の通知を行いました</br>以下の通知が失敗しました。</br>` + errInfo.join("</br>")
            title: DIALOG_MESSAGES['00200016'].title,
            message: messageFormat(DIALOG_MESSAGES['00200016'].message, successCount, errInfo.join("</br>"))
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          });
        } else {
          await this.$ons.notification.alert({
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // title: "失敗",
            // message: errInfo.join("</br>")
            title: DIALOG_MESSAGES["00300013"].title,
            message: errInfo.join("</br>")
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          });
        }
      } else {
        await this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "完了",
          // message: `${successCount}件の通知を行いました`
          title: DIALOG_MESSAGES['00100005'].title,
          message: messageFormat(DIALOG_MESSAGES['00100005'].message, successCount)
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });

      }
      // #12003 2025.12.24 mod 指示後のデータ再取得時に未応答ならば専用表示 TDC片口 start
      // this.refreshDeviceEdges();
      this.autoReloadCount = 0;
      this.orderedTargetEdges = orderedTargets;
      this.refreshDeviceEdges();
      // #12003 2025.12.24 mod 指示後のデータ再取得時に未応答ならば専用表示 TDC片口 end
    },
    async onPlanCancelSingle(target) {
      // 単体キャンセル指示実行
      const resOk = await this.$ons.notification.confirm({
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
        // title: "確認",
        title: DIALOG_MESSAGES[13000024].title,
        // message: `${target.facilityName} ${target.deviceEdgeName}に予約を取消する指示を行います。`
        message: messageFormat(DIALOG_MESSAGES[13000024].message,target.facilityName,target.deviceEdgeName),
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
      });
      if (resOk === 1) {
        this.sendPlanCancelDeviceEdge([target]);
      }
    },
    async onPlanCancel() {
      // 複数キャンセル指示実行
      const targetEdge = this.deviceEdgeList.filter(de => de.isSend);
      let count = targetEdge.length;
      if (count === 0) {
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "確認",
          // message: "予約を取消する対象が指定されていません"
          title: DIALOG_MESSAGES['00200018'].title,
          message: messageFormat(DIALOG_MESSAGES['00200018'].message)
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
        return false;
      }

      const resOk = await this.$ons.notification.confirm({
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
        // title: "確認",
        title: DIALOG_MESSAGES[13000025].title,
        // message: `${count}件のデバイスエッジに予約を取消する指示を行います。`
        message: messageFormat(DIALOG_MESSAGES[13000025].message,count),
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
      });
      if (resOk === 1) {
        this.sendPlanCancelDeviceEdge(targetEdge);
      }
    },
    /**
     * 予約キャンセル指示発行
     */
    async sendPlanCancelDeviceEdge(targets) {
      // 指示
      let successCount = 0;
      let errInfo = [];

      // #12003 2025.12.24 add 指示後のデータ再取得時に未応答ならば専用表示 TDC片口 start
      /** @type {Array<{facilityCd:string, deviceEdgeNo:number, manageNo:number}>} */
      const orderedTargets = [];
      // #12003 2025.12.24 add 指示後のデータ再取得時に未応答ならば専用表示 TDC片口 end

      for (const target of targets) {
        const payload = {
          facilityCd: target.facilityCd,
          deviceEdgeNo: target.deviceEdgeNo
        };
        try {
          // #12003 2025.12.24 mod 指示後のデータ再取得時に未応答ならば専用表示 TDC片口 start
          // await this.orderDeviceEdgePlanCancel(payload);
          // successCount++;

          const result = await this.orderDeviceEdgePlanCancel(payload);
          successCount++;
          orderedTargets.push({
            facilityCd: target.facilityCd,
            deviceEdgeNo: target.deviceEdgeNo,
            manageNo: result.data.manageParam.manageNo,
          });
          // #12003 2025.12.24 mod 指示後のデータ再取得時に未応答ならば専用表示 TDC片口 end
        } catch(error) {
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
          getErrorMessage('MultiDeviceEdgeManageModalComponent.vue', 'sendPlanCancelDeviceEdge', error);
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end

          if (error.response && error.response.data) {
            errInfo.push(`${target.facilityName} ${target.deviceEdgeName}: ${error.response.data.errorMessage}`);
          } else {
            errInfo.push(`${target.facilityName} ${target.deviceEdgeName}: 処理エラーが発生しました`);
          }
        }
      }
      if (errInfo.length) {
        if (successCount > 0) {
          await this.$ons.notification.alert({
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // title: "失敗あり",
            // message: `${successCount}件の通知を行いました</br>以下の通知が失敗しました。</br>` + errInfo.join("</br>")
            title: DIALOG_MESSAGES['00200016'].title,
            message: messageFormat(DIALOG_MESSAGES['00200016'].message, successCount, errInfo.join("</br>"))
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          });
        } else {
          await this.$ons.notification.alert({
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // title: "失敗",
            // message: errInfo.join("</br>")
            title: DIALOG_MESSAGES["00300013"].title,
            message: errInfo.join("</br>")
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          });
        }
      } else {
        await this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "完了",
          // message: `${successCount}件の通知を行いました`
          title: DIALOG_MESSAGES['00100005'].title,
          message: messageFormat(DIALOG_MESSAGES['00100005'].message, successCount)
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
      }
      // #12003 2025.12.24 mod 指示後のデータ再取得時に未応答ならば専用表示 TDC片口 start
      // this.refreshDeviceEdges();
      this.autoReloadCount = 0;
      this.cancelOrderedTargetEdges = orderedTargets;
      this.refreshDeviceEdges();
      // #12003 2025.12.24 mod 指示後のデータ再取得時に未応答ならば専用表示 TDC片口 end
    },
    // #12003 2025.12.24 mod 指示後のデータ再取得時に未応答ならば専用表示 TDC片口 start
    // refreshDeviceEdges() {
    //   this.fetchDeviceEdgeStateAll().then(r => {
    //     this.buildDeviceEdgeParams(r.data, false);
    //     this.setFilterCondition();
    //   });
    // },

    /**
     * 指示後のデータ再取得処理
     */
    refreshDeviceEdges() {
      this.fetchDeviceEdgeStateAll().then(r => {
        this.buildDeviceEdgeParams(r.data, false);
        this.setFilterCondition();
        this.checkOrderedStatus();
        this.autoReload();
      });
    },
    checkOrderedStatus() {
      // 指示済みデバイスエッジの状態確認
      this.orderedTargetEdges = this.orderedTargetEdges.filter(ete => {
        const findEdge = this.deviceEdgeList.find(
          de => de.facilityCd === ete.facilityCd && de.deviceEdgeNo === ete.deviceEdgeNo
        );
        if (findEdge) {
          // 管理番号が違う場合は継続
          return findEdge.manageNo !== ete.manageNo;
        }
        return false;
      });
      this.cancelOrderedTargetEdges = this.cancelOrderedTargetEdges.filter(ete => {
        const findEdge = this.deviceEdgeList.find(
          de => de.facilityCd === ete.facilityCd && de.deviceEdgeNo === ete.deviceEdgeNo
        );
        if (findEdge) {
          // 管理番号がnullになってない場合は継続
          return findEdge.manageNo !== null;
        }
        return false;
      });
    },
    autoReload() {
      if (this.autoReloadCount >= 5) {
        // 最大5回まで
        this.getDeviceEdgeOwnerWindow()?.clearTimeout?.(this.autoReloadTimer);
        this.autoReloadTimer = null;
        return;
      }
      if (this.orderedTargetEdges.length === 0 && this.cancelOrderedTargetEdges.length === 0) {
        // 指示済みデバイスエッジが無ければ終了
        this.getDeviceEdgeOwnerWindow()?.clearTimeout?.(this.autoReloadTimer);
        this.autoReloadTimer = null;
        this.autoReloadCount = 0;
        return;
      }
      this.autoReloadTimer = this.getDeviceEdgeOwnerWindow()?.setTimeout?.(() => {
        this.refreshDeviceEdges();
        this.autoReloadCount++;
      }, 2000);
    },
    /**
     * 指示済みデバイスエッジか否かを判定
     * @param {"request" | "cancel"} mode
     * @param {string} facilityCd
     * @param {number} deviceEdgeNo
     * @returns {boolean} 指示済みならばtrue
     */
    checkIsOrderedTargetEdge(mode, facilityCd, deviceEdgeNo) {
      if (mode === "cancel") {
        return this.cancelOrderedTargetEdges.some(
          (ete) => ete.facilityCd === facilityCd && ete.deviceEdgeNo === deviceEdgeNo
        );
      }
      return this.orderedTargetEdges.some(
        (ete) => ete.facilityCd === facilityCd && ete.deviceEdgeNo === deviceEdgeNo
      );
    },
    // #12003 2025.12.24 mod 指示後のデータ再取得時に未応答ならば専用表示 TDC片口 end

    onAllSelect() {
      this.isAllSelect = !this.isAllSelect;
      this.$nextTick(() => {
        for (let de of this.filterDeviceEdge) {
          de.isSend = this.isAllSelect;
        }
      });
    },
    onSingleSelect(de) {
      this.isAllSelect = false;
      de.isSend = !de.isSend;
    },
    setFilterCondition() {
      this.filterDeviceEdge = [];
      const condition = this.getCondToEdgeListEx;
      const _departmentCd = condition.departmentCd;
      const _prefName = condition.prefName;
      const _facilityName = condition.facilityName;
      const _deviceEdgeName = condition.deviceEdgeName;
      const _deviceEdgeStatus = condition.deviceEdgeStatus;
      const _planStatus = condition.planStatus;
      for (const deviceEdge of this.deviceEdgeList) {
        let isFilter = true;
        if (_departmentCd && _departmentCd !== "-") {
          isFilter = deviceEdge.departmentCd === _departmentCd;
        }
        if (_prefName && _prefName !== "-" && isFilter) {
          isFilter = deviceEdge.prefName === _prefName;
        }
        if (_facilityName && _facilityName !== "" && isFilter) {
          isFilter = deviceEdge.facilityName.indexOf(_facilityName) !== -1;
        }
        if (_deviceEdgeName && _deviceEdgeName !== "" && isFilter) {
          isFilter = deviceEdge.deviceEdgeName.indexOf(_deviceEdgeName) !== -1;
        }
        if (_deviceEdgeStatus && isFilter) {
          const aliveMoniStatus = deviceEdge.aliveMoniStatus;
          if (aliveMoniStatus === "F1" || aliveMoniStatus === "F2") {
            // 通信異常
            isFilter = _deviceEdgeStatus === 3;
          } else if (aliveMoniStatus === "F0") {
            // 通信停止
            isFilter = _deviceEdgeStatus === 2;
          } else {
            // 通信中
            isFilter = _deviceEdgeStatus === 1;
          }
        }
        if (_planStatus && isFilter) {
          if (deviceEdge.manageNo && deviceEdge.responseStatus === 3) {
            // 予約有り
            isFilter = _planStatus === 1;
          } else if (
            deviceEdge.manageNo === null
            || (deviceEdge.responseStatus !== null && deviceEdge.responseStatus < 0)
          ) {
            // 予約なし
            isFilter = _planStatus === 2;
          }
        }
        if (isFilter) {
          this.filterDeviceEdge.push(deviceEdge);
        }
      }
    },
    /**
     * 吹き出し表示処理
     */
    showPopOver(event, message) {
      var pop = this.$refs.popOverMessage || this.getScopedElementById("pop-over-de-message");
      pop.innerText = message;
      this.userMenuPopoverTarget = event;
      this.userMenuPopoverVisible = true;
    },
    /**
     * 吹き出しの表示方向を判定
     */
    setPopoverDirection() {
      if (getViewportWidth() <= 420) {
        this.userMenuPopoverDirection = "up down";
      } else {
        this.userMenuPopoverDirection = "left right";
      }
    },
  },
  watch: {
    windowHeight() {
      this.calculateGridHeight();
    },
    windowWidth() {
      this.calculateGridHeight();
      // 吹き出しの表示方向を判定
      this.setPopoverDirection();
    },
    isDispMenu() {
      this.calculateGridHeight();
    },
    getFontSize() {
      this.calculateGridHeight();
    }
  },
  mounted() {
    this.$nextTick(() => {
      this.calculateGridHeight();
      // 吹き出しの表示方向を判定
      this.setPopoverDirection();
    });
  },
  created() {
    this.clearCondToEdgeListEx();
    this.fetchDeviceEdgeBaseBucket().then(r => {
      this.targetFilePath = r.data.bucket;
      this.fetchDeviceEdgeStateAll().then(r => {
        this.buildDeviceEdgeParams(r.data, true);
        this.setFilterCondition();
      });
    });
    // add 性能改善メモリ不足 shan start
    EventBus.$off("setFilterCondition", this.setFilterCondition);
    // add 性能改善メモリ不足 shan end
    EventBus.$on("setFilterCondition", this.setFilterCondition);
  },
  // add 性能改善メモリ不足 shan start
  beforeUnmount() {
    EventBus.$off("setFilterCondition", this.setFilterCondition);
  }
  // add 性能改善メモリ不足 shan end
};
</script>

<!-- 個別スタイル定義 -->
<style scoped>
.horizontal-div {
  display: flex;
  flex-direction: row;
}
table.ntss-list thead tr {
  height: 33px;
}
tr {
  height: 2em;
  padding: 0 0.75rem;
}

.ntss-list-body-td :deep(ons-button.select-btn) {
  font-size: 1em;
}
.custom-de-manage-modal-list {
  font-size: unset;
}
table.ntss-list thead tr.de-manage-list-header th {
  color: var(--ntss-header-color);
  background-color: var(--ntss-list-header-background-color);
  font-weight: 100;
  position: -webkit-sticky;
  position: sticky;
  --top: 0px;
  top: var(--top);
  z-index: 1;
}
#de-manage-modal-header {
  margin: 4px;
  margin-top: 0;
}
#column-01 {
  min-width: 2em;
}
#column-02 {
  min-width: 4em;
}
#column-03 {
  min-width: 5em;
}
#column-04 {
  min-width: 7em;
}
#column-05 {
  min-width: 8em;
}
#column-06 {
  min-width: 7em;
}
#column-07 {
  min-width: 4em;
  width: 5em;
}
#column-08 {
  min-width: 22em;
}
#column-09 {
  min-width: 10em;
}
#column-10 {
  min-width: 5em;
}
.column-11 {
  min-width: 5em;
}
.input-filename {
  width: 8em;
}
.de-manage-list-wrapper {
  width: 500px;
  height: 250px;
  overflow-x: auto;
  margin-bottom: 5px;
}
#de-manage-list {
  position: relative;
  top: 0;
}
.de-manage-search-wrapper {
  position: sticky;
  position: -webkit-sticky;
  top: 0;
  z-index: 1;
}
#multi-plan-cancel-button {
  margin-right: 10px;
  margin-left: 10px;
}
.path-separator {
  margin-left: 2px;
  margin-right: 2px;
  font-size: 1.25em;
  font-weight: bold;
}
.help-area {
  margin: 10px;
}
@media print {
  /** 折り返して幅を収める */
  div :deep(.modal-container){
    width: 100%
  }
  .de-manage-list-wrapper {
    width: 100% !important;
  }
  #de-manage-list {
    width: 100% !important;
  }
  #de-manage-list th,
  #de-manage-list td {
    word-break: break-all;
    white-space: normal !important;
  }
  .ntss-list-body-td {
    padding: 2px;
  }
  #column-01,
  #column-02,
  #column-03,
  #column-04,
  #column-05,
  #column-06,
  #column-07,
  #column-08,
  #column-09,
  #column-10,
  .column-11 {
    min-width: unset !important;
  }
  #de-manage-list :deep(input[type="datetime-local"]){
    width: 9em;
    -webkit-appearance: none;
    appearance: none;
  }
  input[type="datetime-local"]::-webkit-calendar-picker-indicator {
    display: none;
  }
  #de-manage-list :deep(input[type="text"]){
    max-width: 11em;
  }
  #de-manage-list :deep(.denial-btn){
    writing-mode: vertical-rl;
    text-orientation: upright;
    min-width: 0.6em;
    width: 0.6em;
    height: auto;
  }
  /** フッター位置調整 */
  .de-manage-list-wrapper {
    height: auto !important;
  }
}
</style>
