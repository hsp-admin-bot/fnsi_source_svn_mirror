/**
 * デバイスエッジ稼働ページ用ヘッダ
 */
<template>
  <v-card>
    <div class="header-item">
      <v-ons-row ref="edgeHeaderRow" class="mark-leftmost-header">
        <v-ons-col class="condition-search-col">
          <common-searcharea :conditionList="conditionList" @show-popover='showPopover($event)'/>
        </v-ons-col>
        <v-ons-col class="mark-filter-header" style="margin-top: 0.4em">
          <div class="horizontal-div height-full">
            <div>
              <div class="filter-area" id="deviceEdgeFilter">
                <div class="filter-button">
                  <input
                    type="checkbox"
                    class="emergency"
                    id="deviceEdgeEmergency"
                    @click="checkedCheckbox($event)"
                    v-bind:checked="condition.deviceEdgeEmergency"
                  />
                  <label for="deviceEdgeEmergency" class="filterLabel">{{ emergencyCount }}</label>
                </div>
                <div class="filter-button">
                  <input
                    type="checkbox"
                    class="defect"
                    id="deviceEdgeDefect"
                    @click="checkedCheckbox($event)"
                    v-bind:checked="condition.deviceEdgeDefect"
                  />
                  <label for="deviceEdgeDefect" class="filterLabel">{{ defectCount }}</label>
                </div>
              </div>
              <div class="filter-area">
                <div class="filter-button">
                  <input
                    type="radio"
                    class="all"
                    id="deviceEdgeAll"
                    @click="checkedRadio($event)"
                    v-bind:checked="condition.deviceEdgeAll"
                  />
                  <label for="deviceEdgeAll" class="filterLabel filterLabel2">ALL</label>
                </div>
              </div>
            </div>
            <div id="modal-button-area" v-show="isNkkUser && isModalButtonAreaFrontHeader">
              <v-ons-button id="modal-button" class="btn3-normal" @click="showManageModal">一括バージョンアップ</v-ons-button>
            </div>
          </div>
        </v-ons-col>
      </v-ons-row>
    </div>
    <v-ons-popover
      cancelable
      :visible.sync="popoverVisible"
      :target="popoverTarget"
      :direction="popoverDirection"
      :cover-target="false"
      :class="fontSizeSet"
    >
      <div style="margin: 10px">
        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="center">
            <label>部署符号</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <v-ons-select float v-model="inProgressCondition.departmentCd">
              <option>-</option>
              <option
                v-for="(departmentCd, idxDepartmentCd) in departmentCds"
                :key="idxDepartmentCd"
              >
                {{ departmentCd }}
              </option>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="center">
            <label>都道府県</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <v-ons-select float v-model="inProgressCondition.prefName" style="display:">
              <option>-</option>
              <option v-for="prefecture in prefectures" :key="prefecture[0]">{{ prefecture[1] }}</option>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="center">
            <label>施設名</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <v-ons-input
              input-id="facilityName"
              type="text"
              float
              v-model="inProgressCondition.facilityName"
            ></v-ons-input>
          </v-ons-col>
        </v-ons-row>
        <!-- 未接続発生順にソート -->
        <v-ons-row class="condition-row">
          <v-ons-col width='10%' vertical-align='center'>
            <v-ons-checkbox v-model="inProgressCondition.isAlarmSort" input-id="sort"></v-ons-checkbox>
          </v-ons-col>
          <label for="sort" class="popoverFilterLabel">{{ getIsAlarmDispText() }}</label>
        </v-ons-row>
        <v-ons-row class="condition-row custom-condition-row">
          <v-ons-col>
            <v-ons-button class="btn2-cancel clear" @click="dialogClear">クリア</v-ons-button>
          </v-ons-col>
          <v-ons-col v-show="isNkkUser">
            <v-ons-button modifier="quiet" class="mst-sync-button" @click="showMstSynchroModal">.</v-ons-button>
          </v-ons-col>
          <v-ons-col>
            <v-ons-button class="btn3-normal ok" @click="dialogOk">OK</v-ons-button>
          </v-ons-col>
        </v-ons-row>
      </div>
    </v-ons-popover>
  </v-card>
</template>

<!-- スクリプト処理 -->
<script>
import { mapGetters, mapActions } from "vuex";
import { EventBus } from "@/eventBus.js";
import PopoverMixin from "@/components/PopoverMixin";
import { IS_ALARM_TEXT } from "@/constants/deviceEdgeOperationDefine";
import commonSearchArea from "@/components/common/CommonSearchArea";

export default {
  components: {
    "common-searcharea": commonSearchArea
  },
  mixins: [PopoverMixin],
  data() {
    const defaultCondition = {
      /**
       * 部署符号
       */
      departmentCd: "-",
      /**
       * 都道府県名
       */
      prefName: "-",
      /**
       * 施設名
       */
      facilityName: "",
      /**
       * 未接続発生順にソート
       */
      isAlarmSort: true
    };
    return {
      popoverVisible: false,
      popoverTarget: null,
      popoverDirection: "down",
      defaultCondition: defaultCondition,
      inProgressCondition: {
        ...defaultCondition
      },
      condition: {
        ...defaultCondition,
        deviceEdgeEmergency: false,
        deviceEdgeDefect: false,
        deviceEdgeAll: true
      },
      isModalButtonAreaFrontHeader: false,
      selfScreenName: "",
      // 共通検索エリア部品に表示するデータのリスト
      conditionList: [{ text: IS_ALARM_TEXT }]
    };
  },
  computed: {
    ...mapGetters("account-edit", ["getStateUserAccountInfo"]),
    ...mapGetters("device-edge-operation", [
      "getCandidates",
      "getEmergencyCount",
      "getDefectCount",
      "getCondition"
    ]),
    ...mapGetters("window-size", {
      // 分割された画面の幅取得
      splittedWidth: "getSplittedWidth",
      splittableFrames: "getSplittableFrames"
    }),
    // -----------------------------------------
    // 部署符号の選択肢リスト取得
    // -----------------------------------------
    departmentCds() {
      return this.getCandidates.departmentCds;
    },
    // -----------------------------------------
    // 都道府県の選択肢リスト取得
    // -----------------------------------------
    prefectures() {
      return this.getCandidates.prefectures;
    },
    // -----------------------------------------
    // 通信異常、デバイスエッジ異常の件数取得
    // -----------------------------------------
    emergencyCount() {
      return this.getEmergencyCount;
    },
    // -----------------------------------------
    // 手動停止の件数取得
    // -----------------------------------------
    defectCount() {
      return this.getDefectCount;
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
    }
  },
  methods: {
    ...mapActions("device-edge-operation", ["setCondition", "findDeviceEdges"]),
    ...mapActions("multi-modal", ["showMstSynchro", "showMultiDeviceEdgeManageModal"]),

    /**
     * 「未接続発生順にソート」の文字列を取得する.
     * ※deviceEdgeOperationDefineに記載されている.
     *
     * @returns 表示文字列
     */
    getIsAlarmDispText() {
      return IS_ALARM_TEXT;
    },
    // -----------------------------------------
    // 抽出UI表示イベント
    // -----------------------------------------
    showPopover(event) {
      this.copyConditionToInProgress();
      this.popoverTarget = event;
      this.popoverVisible = true;
    },
    // -----------------------------------------
    // 抽出条件クリアボタンクリックイベント
    // -----------------------------------------
    dialogClear() {
      this.clearCondition();
      // 画面を閉じる
      this.popoverVisible = false;
      // 検索条件クリア
      this.setCondition(this.condition);
      // 検索処理の実行
      this.findDeviceEdges(this.getStateUserAccountInfo.userId);
    },
    // -----------------------------------------
    // 抽出条件OKボタンクリックイベント
    // -----------------------------------------
    dialogOk() {
      this.copyConditionFromInProgress();
      this.popoverVisible = false;
      this.search();
    },
    // ------------------------------------------------------------------
    // 処理：抽出条件を元にした検索イベント
    // ------------------------------------------------------------------
    search() {
      this.setCondition(this.condition);
    },
    // ------------------------------------------------------------------
    // 処理：各チェックボックスクリック時のイベント
    //       全選択のラジオボタンをOFFにし、施設一覧のstateのconditionを更新する
    // 引数：event : マウスクリックイベント
    // ------------------------------------------------------------------
    checkedCheckbox(event) {
      // 選択された要素の属性:idをイベントから取得
      const checkId = event.currentTarget.id;
      if (checkId === "deviceEdgeEmergency") {
        this.condition.deviceEdgeEmergency = event.currentTarget.checked;
      } else if (checkId === "deviceEdgeDefect") {
        this.condition.deviceEdgeDefect = event.currentTarget.checked;
      }
      // 全選択のラジオボタンを未選択に設定
      this.condition.deviceEdgeAll = false;
      // チェックボックスが全てOFFになった場合の対応
      if (
        !this.condition.deviceEdgeEmergency &&
        !this.condition.deviceEdgeDefect
      ) {
        // 全選択のラジオボタンをONに設定
        this.condition.deviceEdgeAll = true;
      }
      // storeに条件を登録
      this.setCondition(this.condition);
      // フィルタリング
      this.search();
    },
    // ------------------------------------------------------------------
    // 処理：全選択のラジオボタンクリック時のイベント
    //       緊急発報、予防保守、通信異常のチェックボックスを全てOFFにし、
    //       施設一覧のstateのconditionを更新する
    // 引数：event : マウスクリックイベント
    // ------------------------------------------------------------------
    checkedRadio(event) {
      this.condition.deviceEdgeEmergency = false;
      this.condition.deviceEdgeDefect = false;
      this.condition.deviceEdgeAll = event.currentTarget.checked;
      this.setCondition(this.condition);
      // フィルタリング
      this.search();
    },
    // -----------------------------------------
    // stateから取得したconditionを変数に設定する
    // -----------------------------------------
    setStateCondition() {
      const condition = this.getCondition;
      this.condition.departmentCd = condition.departmentCd;
      this.condition.prefName = condition.prefName;
      this.condition.facilityName = condition.facilityName;
      this.condition.deviceEdgeEmergency = condition.deviceEdgeEmergency;
      this.condition.deviceEdgeDefect = condition.deviceEdgeDefect;
      this.condition.deviceEdgeAll = condition.deviceEdgeAll;
      this.condition.isAlarmSort = condition.isAlarmSort;
      this.setConditionList();
    },
    // -----------------------------------------
    // 共通検索エリア部品に表示するデータのリストを作成
    // -----------------------------------------
    setConditionList() {
      let condList = [];
      // 部署符号
      if (this.condition.departmentCd != "" && this.condition.departmentCd != "-") {
        condList.push({ name: "部署符号", text: this.condition.departmentCd });
      }
      // 都道府県
      if (this.condition.prefName != "" && this.condition.prefName != "-") {
        condList.push({ name: "都道府県", text: this.condition.prefName });
      }
      // 施設名
      if (this.condition.facilityName != "") {
        condList.push({ name: "施設名", text: this.condition.facilityName });
      }
      // 未接続発生順にソート
      if (this.condition.isAlarmSort) {
        condList.push({ text: this.getIsAlarmDispText() });
      }
      this.conditionList = condList;
    },
    // -----------------------------------------
    // マスタ同期モーダル表示
    // -----------------------------------------
    showMstSynchroModal() {
      this.popoverVisible = false;
      this.showMstSynchro();
    },
    copyConditionToInProgress() {
      this.inProgressCondition.departmentCd = this.condition.departmentCd;
      this.inProgressCondition.prefName = this.condition.prefName;
      this.inProgressCondition.facilityName = this.condition.facilityName;
      this.inProgressCondition.isAlarmSort = this.condition.isAlarmSort;
    },
    copyConditionFromInProgress() {
      this.condition.departmentCd = this.inProgressCondition.departmentCd;
      this.condition.prefName = this.inProgressCondition.prefName;
      this.condition.facilityName = this.inProgressCondition.facilityName;
      this.condition.isAlarmSort = this.inProgressCondition.isAlarmSort;
      this.setConditionList();
    },
    clearCondition() {
      this.condition.departmentCd = this.defaultCondition.departmentCd;
      this.condition.prefName = this.defaultCondition.prefName;
      this.condition.facilityName = this.defaultCondition.facilityName;
      this.condition.isAlarmSort = this.defaultCondition.isAlarmSort;
      this.inProgressCondition.departmentCd = this.defaultCondition.departmentCd;
      this.inProgressCondition.prefName = this.defaultCondition.prefName;
      this.inProgressCondition.facilityName = this.defaultCondition.facilityName;
      this.inProgressCondition.isAlarmSort = this.defaultCondition.isAlarmSort;
      // 共通検索エリア部品に表示するデータのリストを初期化
      this.conditionList = [{ text: IS_ALARM_TEXT }];
    },
    showManageModal() {
      this.showMultiDeviceEdgeManageModal();
    },
    /**
     * 子画面がない、または分割表示ならばtrue
     * 子画面が重なって表示されているとfalse
     */
    calcModalButtonAreaFrontHeader() {
      this.$nextTick(() => {
        if (this.selfScreenName === this.$router.currentRoute.name) {
          this.isModalButtonAreaFrontHeader = true;
        } else {
          this.isModalButtonAreaFrontHeader = this.splittableFrames > 1;
        }
      });
    }
  },
  watch: {
    splittableFrames() {
      this.calcModalButtonAreaFrontHeader();
    }
  },
  mounted() {
    this.calcModalButtonAreaFrontHeader();
  },
  created() {
    // add 性能改善メモリ不足 shan start
    EventBus.$off("calcModalButtonAreaFrontHeader", this.calcModalButtonAreaFrontHeader);
    // add 性能改善メモリ不足 shan end
    EventBus.$on("calcModalButtonAreaFrontHeader", this.calcModalButtonAreaFrontHeader);
    this.selfScreenName = this.$router.currentRoute.name;
    this.setStateCondition();
  },
  // add 性能改善メモリ不足 shan start
  beforeDestroy() {
    EventBus.$off("calcModalButtonAreaFrontHeader", this.calcModalButtonAreaFrontHeader);
  },
  // add 性能改善メモリ不足 shan end
};
</script>


<!-- 個別スタイル定義 -->
<style scoped>
input[type="radio"] {
  display: none; /* ラジオボタンを非表示にする */
}
input[type="checkbox"] {
  display: none; /* チェックボックスを非表示にする */
}

.filterLabel2 {
  width: 4.6em;
}

.custom-condition-row >>> ons-button.button {
  margin: unset;
}
.horizontal-div {
  display: flex;
  flex-direction: row;
}
.height-full {
  height: 100%;
}
.mst-sync-button {
  color: unset !important;
  background-image: unset !important;
}
#modal-button-area {
  height: 100%;
  align-items: center;
  display: flex;
}

#modal-button {
  margin-left: 15px;
  padding: 2px;
  font-size: 1.25em;
}
.popoverFilterLabel {
  margin-right: 7px;
  font-size: 1.6em;
}
</style>
