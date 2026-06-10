/**
 * 複数施設DE更新モーダル 検索用コンポーネント
 */
<template>
  <v-card>
    <div class="dialog-header-item">
      <v-ons-row>
        <v-ons-col class="condition-search-col">
          <common-searcharea :lineHeight="'3.8em'" :conditionList="conditionList" @show-popover='showPopover($event)'/>
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
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="popoverPosthide"
    >
      <div style="margin:10px;">
        <v-ons-row class="condition-row">
          <v-ons-col width="50%">
            <label class="search-label-font" for="isDefaultCtrl">部署符号</label>
          </v-ons-col>
          <v-ons-col width="50%" vertical-align="center">
            <v-ons-select float v-model="condition.inProgress.departmentCd">
              <option>-</option>
              <option
                v-for="(departmentCd, idxDepartmentCd) in departmentCds"
                :key="idxDepartmentCd"
              >{{ departmentCd }}</option>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="condition-row">
          <v-ons-col width="50%" vertical-align="center">
            <label class="search-label-font">都道府県</label>
          </v-ons-col>
          <v-ons-col width="50%" vertical-align="center">
            <v-ons-select float v-model="condition.inProgress.prefName" style="display:">
              <option>-</option>
              <option v-for="prefecture in prefectures" :key="prefecture[0]">{{ prefecture[1] }}</option>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="condition-row">
          <v-ons-col width="50%">
            <label class="search-label-font">施設名</label>
          </v-ons-col>
          <v-ons-col width="50%" vertical-align="center">
            <v-ons-input
              input-id="facilityName"
              type="text"
              float
              v-model="condition.inProgress.facilityName"
            ></v-ons-input>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="condition-row">
          <v-ons-col width="50%">
            <label class="search-label-font">デバイスエッジ名</label>
          </v-ons-col>
          <v-ons-col width="50%" vertical-align="center">
            <v-ons-input
              input-id="deviceEdgeName"
              type="text"
              float
              v-model="condition.inProgress.deviceEdgeName"
            ></v-ons-input>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="condition-row">
          <v-ons-col width="50%">
            <label class="search-label-font" for="onlySendEmailCtrl">通信状態</label>
          </v-ons-col>
          <v-ons-col width="50%">
            <v-ons-select v-model="condition.inProgress.deviceEdgeStatus">
              <option
                v-for="(status , idxStatus) in statusList"
                :key="idxStatus"
                :value="status.statusCd"
              >{{ status.statusName }}</option>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="condition-row">
          <v-ons-col width="50%">
            <label class="search-label-font" for="onlySendEmailCtrl">予約状態</label>
          </v-ons-col>
          <v-ons-col width="50%">
            <v-ons-select v-model="condition.inProgress.planStatus">
              <option
                v-for="(status , idxStatus) in planList"
                :key="idxStatus"
                :value="status.statusCd"
              >{{ status.statusName }}</option>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>
        <div class="condition-row button-row">
          <div class="left">
            <v-ons-button class="btn2-cancel clear" @click="clearCondition(); closeDialog()">クリア</v-ons-button>
          </div>
          <div class="right">
            <v-ons-button class="btn1-execute ok" @click="closeDialog">OK</v-ons-button>
          </div>
        </div>
      </div>
    </v-ons-popover>
  </v-card>
</template>

<!-- スクリプト処理 -->
<script>
import { mapGetters, mapActions } from "vuex";
import { EventBus } from "@/eventBus.js";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import commonSearchArea from "@/components/common/CommonSearchArea";
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";

export default {
  components: {
    "common-searcharea": commonSearchArea
  },
  mixins: [MasterMaintenanceMixin],
  name: "MachineRecordSearchComponent",
  data() {
    const defaultCondition = {
      departmentCd: "-",
      prefName: "-",
      facilityName: "",
      deviceEdgeName: "",
      deviceEdgeStatus: null,
      planStatus: null
    };
    return {
      popoverVisible: false,
      popoverTarget: null,
      popoverDirection: "down",
      defaultCondition: defaultCondition,
      condition: {
        inProgress: {
          ...defaultCondition
        },
        inUsed: {
          ...defaultCondition
        }
      },
      statusList: [
        {
          statusName: "-",
          statusCd: null
        },
        {
          statusName: "通信正常",
          statusCd: 1
        },
        {
          statusName: "通信停止",
          statusCd: 2
        },
        {
          statusName: "通信異常",
          statusCd: 3
        }
      ],
      planList: [
        {
          statusName: "-",
          statusCd: null
        },
        {
          statusName: "予約あり",
          statusCd: 1
        },
        {
          statusName: "予約なし",
          statusCd: 2
        }
      ],
      // 共通検索エリア部品に表示するデータのリスト
      conditionList: []
    };
  },
  computed: {
    ...mapGetters("device-edge-operation", [
      "getCandidates",
      "getEmergencyCount",
      "getDefectCount",
      "getCondition"
    ]),
    departmentCds() {
      return this.getCandidates.departmentCds;
    },
    prefectures() {
      return this.getCandidates.prefectures;
    },
    commStatusLabel() {
      const cd = this.condition.inUsed.deviceEdgeStatus;
      const sel = this.statusList.find(status => status.statusCd === cd);
      return sel ? `通信状態:${sel.statusName}` : null;
    },
    planStatusLabel() {
      const cd = this.condition.inUsed.planStatus;
      const sel =  this.planList.find(plan => plan.statusCd === cd);
      return sel ? `予約状態:${sel.statusName}` : null;
    }
  },
  methods: {
    ...mapActions("multi-device-edge-manage", [
      "clearCondToEdgeListEx",
      "commitCondToEdgeListEx"
    ]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    showPopover(event) {
      this.copyConditionInUsedToInProgress();
      this.popoverTarget = event;
      this.popoverVisible = true;
    },
    clearCondition() {
      // 検索条件クリアして画面を更新
      this.clearConditionInUsedAndInProgress();
      this.clearCondToEdgeListEx();
    },
    closeDialog() {
      this.copyConditionInProgressToInUsed();
      // 画面を閉じる
      this.popoverVisible = false;
      // 設定条件
      const condition = {
        departmentCd: this.condition.inUsed.departmentCd,
        prefName: this.condition.inUsed.prefName,
        facilityName: this.condition.inUsed.facilityName,
        deviceEdgeName: this.condition.inUsed.deviceEdgeName,
        deviceEdgeStatus: this.condition.inUsed.deviceEdgeStatus,
        planStatus: this.condition.inUsed.planStatus
      };
      this.commitCondToEdgeListEx(condition);
      EventBus.$emit("setFilterCondition");
    },
    copyConditionInProgressToInUsed() {
      this.condition.inUsed.departmentCd = this.condition.inProgress.departmentCd;
      this.condition.inUsed.prefName = this.condition.inProgress.prefName;
      this.condition.inUsed.facilityName = this.condition.inProgress.facilityName;
      this.condition.inUsed.deviceEdgeName = this.condition.inProgress.deviceEdgeName;
      this.condition.inUsed.deviceEdgeStatus = this.condition.inProgress.deviceEdgeStatus;
      this.condition.inUsed.planStatus = this.condition.inProgress.planStatus;
      this.setConditionList();
    },
    copyConditionInUsedToInProgress() {
      this.condition.inProgress.departmentCd = this.condition.inUsed.departmentCd;
      this.condition.inProgress.prefName = this.condition.inUsed.prefName;
      this.condition.inProgress.facilityName = this.condition.inUsed.facilityName;
      this.condition.inProgress.deviceEdgeName = this.condition.inUsed.deviceEdgeName;
      this.condition.inProgress.deviceEdgeStatus = this.condition.inUsed.deviceEdgeStatus;
      this.condition.inProgress.planStatus = this.condition.inUsed.planStatus;
    },
    clearConditionInUsedAndInProgress() {
      this.condition.inUsed.departmentCd = this.defaultCondition.departmentCd;
      this.condition.inUsed.prefName = this.defaultCondition.prefName;
      this.condition.inUsed.facilityName = this.defaultCondition.facilityName;
      this.condition.inUsed.deviceEdgeName = this.defaultCondition.deviceEdgeName;
      this.condition.inUsed.deviceEdgeStatus = this.defaultCondition.deviceEdgeStatus;
      this.condition.inUsed.planStatus = this.defaultCondition.planStatus;

      this.condition.inProgress.departmentCd = this.defaultCondition.departmentCd;
      this.condition.inProgress.prefName = this.defaultCondition.prefName;
      this.condition.inProgress.facilityName = this.defaultCondition.facilityName;
      this.condition.inProgress.deviceEdgeName = this.defaultCondition.deviceEdgeName;
      this.condition.inProgress.deviceEdgeStatus = this.defaultCondition.deviceEdgeStatus;
      this.condition.inProgress.planStatus = this.defaultCondition.planStatus;
    },
    // -----------------------------------------
    // 共通検索エリア部品に表示するデータのリストを作成
    // -----------------------------------------
    setConditionList() {
      let condList = [];
      // 部署符号
      if (this.condition.inUsed.departmentCd != "" && this.condition.inUsed.departmentCd != "-") {
        condList.push({ name:"部署符号", text:this.condition.inUsed.departmentCd });
      }
      // 都道府県
      if (this.condition.inUsed.prefName != "" && this.condition.inUsed.prefName != "-") {
        condList.push({ name:"都道府県", text:this.condition.inUsed.prefName });
      }
      // 施設名
      if (this.condition.inUsed.facilityName != "") {
        condList.push({ name:"施設名", text:this.condition.inUsed.facilityName });
      }
      // デバイスエッジ名
      if (this.condition.inUsed.deviceEdgeName != "") {
        condList.push({ name:"デバイスエッジ名", text:this.condition.inUsed.deviceEdgeName });
      }
      // 通信状態
      if (this.condition.inUsed.deviceEdgeStatus) {
        condList.push({ name:"通信状態", text:this.commStatusLabel });
      }
      // 予約状態
      if (this.condition.inUsed.planStatus) {
        condList.push({ name:"通信状態", text:this.planStatusLabel });
      }
      this.conditionList = condList;
    }
  },
  created() {
    this.clearCondition();
  }
};
</script>

<style scoped>
.dialog-header-item {
  /* 文字色：黒テーマ字に灰色になってしまう為、黒で上書きする */
  color:#333333;
  font-size: .667em;
  height: 4.7em;
}
.button-row {
  height: 30px;
  margin: 5px 0;
}
.button-row > .left {
  float: left;
}
.button-row > .right {
  float: right;
}
.button-row >>> .button {
  width: auto;
  min-width: 80px;
}
</style>
