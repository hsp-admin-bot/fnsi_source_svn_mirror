/**
 * 警報通知マスタ 装置記録検索用コンポーネント
 */
<template>
  <v-card>
    <div class='dialog-header-item'>
      <v-ons-row>
        <v-ons-col class='condition-search-col'>
          <common-searcharea :lineHeight="'3.8em'" :conditionList="conditionList" @show-popover='showPopover($event)'/>
        </v-ons-col>
      </v-ons-row>
    </div>
    <v-ons-popover cancelable
                    :visible.sync='popoverVisible'
                    :target='popoverTarget'
                    :direction='popoverDirection'
                    :cover-target="false"
                    :class="fontSizeSet"
                    @preshow="popoverPreShow"
                    @postshow="popoverPostShow"
                    @posthide="popoverPosthide">
      <div style='margin:10px;'>
        <v-ons-row class='condition-row'>
          <v-ons-col width='40%' vertical-align='center'>
            <label class="search-label-font">ﾌﾘｰﾜｰﾄﾞ</label>
          </v-ons-col>
          <v-ons-col width='60%' vertical-align='center'>
            <v-ons-input 
              input-id='machineRecord'
              type='text'
              float
              v-model='condition.inProgress.machineRecord'
            ></v-ons-input>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class='condition-row'>
          <v-ons-col width='40%'>
            <v-ons-checkbox
              input-id="isDefaultCtrl"
              v-model="condition.inProgress.isDefault"
            ></v-ons-checkbox>
          </v-ons-col>
          <v-ons-col width='60%'>
            <label class="search-label-font" for="isDefaultCtrl">推奨項目</label>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class='condition-row'>
          <v-ons-col width='40%'>
            <label class="search-label-font">ログ分類</label>
          </v-ons-col>
          <v-ons-col width='60%'>
            <v-ons-select
              v-model="condition.inProgress.logClass"
            >
              <option v-for="(item, index) in logClassAsList" :key="index" :value="item.cd">
                {{ item.text }}
              </option>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class='condition-row'>
          <v-ons-col width='40%'>
            <label class="search-label-font">対象機種</label>
          </v-ons-col>
          <v-ons-col width='60%'>
            <v-ons-select
              v-model="condition.inProgress.targetModel"
            >
              <option v-for="(item, index) in targetModelAsList" :key="index" :value="item.cd">
                {{ item.text }}
              </option>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class='condition-row'>
          <v-ons-col width='40%'>
            <v-ons-checkbox
              input-id="onlySendEmailCtrl"
              v-model="condition.inProgress.onlySendEmail"
            ></v-ons-checkbox>
          </v-ons-col>
          <v-ons-col width='60%'>
            <label class="search-label-font" for="onlySendEmailCtrl">有効項目</label>
          </v-ons-col>
        </v-ons-row>
        <div class="condition-row button-row">
          <div class="left">
            <v-ons-button class='btn2-cancel clear' @click='clearCondition(); closeDialog()'>クリア</v-ons-button>
          </div>
          <div class="right">
            <v-ons-button class='btn1-execute ok' @click='closeDialog'>OK</v-ons-button>
          </div>
        </div>
      </div>
    </v-ons-popover>
  </v-card>
</template>

<!-- スクリプト処理 -->
<script>
import { mapActions } from "vuex";
import { EventBus } from "@/eventBus.js";
import { LogClass } from "@/models/master-maintenance/mst-alarm-notification/LogClass";
import { TargetModel } from "@/models/master-maintenance/mst-alarm-notification/TargetModel";
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
      machineRecord: "",
      onlySendEmail: false,
      isDefault: false,
      logClass: "0",
      targetModel: "0"
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
      // 共通検索エリア部品に表示するデータのリスト
      conditionList: []
    };
  },
  props: {
    isNewRecord: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    logClassAsList() {
      return Object.entries(LogClass)
        .sort((a, b) => a[0] - b[0])
        .map(value => ({ cd: value[0], text: value[1] }));
    },
    targetModelAsList() {
      return Object.entries(TargetModel)
        .sort((a, b) => a[0] - b[0])
        .map(value => ({ cd: value[0], text: value[1] }));
    }
  },
  methods: {
    ...mapActions("mst-alarm-notification", [
      "setConditionMachineRecord",
      "setConditionOnlySendEmail",
      "setConditionIsDefault",
      "setConditionLogClass",
      "setConditionTargetModel",
      "conditionsClear"
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
      this.conditionsClear();
    },
    closeDialog() {
      this.copyConditionInProgressToInUsed();
      // 画面を閉じる
      this.popoverVisible = false;
      this.commitCondMachineRecord();
      this.commitCondSendEmail();
      this.commitCondIsDefault();
      this.commitCondLogClass();
      this.commitCondTargetModel();
      this.setConditionList();
      EventBus.$emit("setMachineRecordList");
    },
    commitCondMachineRecord() {
      this.setConditionMachineRecord(this.condition.inUsed.machineRecord);
    },
    commitCondSendEmail() {
      this.setConditionOnlySendEmail(this.condition.inUsed.onlySendEmail);
    },
    commitCondIsDefault() {
      this.setConditionIsDefault(this.condition.inUsed.isDefault ? "1" : "0");
    },
    commitCondLogClass() {
      this.setConditionLogClass(this.condition.inUsed.logClass);
    },
    commitCondTargetModel() {
      this.setConditionTargetModel(this.condition.inUsed.targetModel);
    },
    getLogClassName() {
      return this.condition.inUsed.logClass === 0
        ? ""
        : LogClass[this.condition.inUsed.logClass];
    },
    getTargetModelName() {
      return this.condition.inUsed.targetModel === 0
        ? ""
        : TargetModel[this.condition.inUsed.targetModel];
    },
    copyConditionInProgressToInUsed() {
      this.condition.inUsed.machineRecord = this.condition.inProgress.machineRecord;
      this.condition.inUsed.onlySendEmail = this.condition.inProgress.onlySendEmail;
      this.condition.inUsed.isDefault = this.condition.inProgress.isDefault;
      this.condition.inUsed.logClass = this.condition.inProgress.logClass;
      this.condition.inUsed.targetModel = this.condition.inProgress.targetModel;
    },
    copyConditionInUsedToInProgress() {
      this.condition.inProgress.machineRecord = this.condition.inUsed.machineRecord;
      this.condition.inProgress.onlySendEmail = this.condition.inUsed.onlySendEmail;
      this.condition.inProgress.isDefault = this.condition.inUsed.isDefault;
      this.condition.inProgress.logClass = this.condition.inUsed.logClass;
      this.condition.inProgress.targetModel = this.condition.inUsed.targetModel;
    },
    clearConditionInUsedAndInProgress() {
      this.condition.inUsed.machineRecord = this.defaultCondition.machineRecord;
      this.condition.inUsed.onlySendEmail = this.defaultCondition.onlySendEmail;
      this.condition.inUsed.isDefault = this.defaultCondition.isDefault;
      this.condition.inUsed.logClass = this.defaultCondition.logClass;
      this.condition.inUsed.targetModel = this.defaultCondition.targetModel;
      this.condition.inProgress.machineRecord = this.defaultCondition.machineRecord;
      this.condition.inProgress.onlySendEmail = this.defaultCondition.onlySendEmail;
      this.condition.inProgress.isDefault = this.defaultCondition.isDefault;
      this.condition.inProgress.logClass = this.defaultCondition.logClass;
      this.condition.inProgress.targetModel = this.defaultCondition.targetModel;
    },
    // -----------------------------------------
    // 共通検索エリア部品に表示するデータのリストを作成
    // -----------------------------------------
    setConditionList() {
      let condList = [];
      const condObj = this.condition.inUsed;
      // ﾌﾘｰﾜｰﾄﾞ
      if (condObj.machineRecord != "") {
        condList.push({ name:"ﾌﾘｰﾜｰﾄﾞ", text:condObj.machineRecord });
      }
      // 推奨項目
      if (condObj.isDefault) {
        condList.push({ text:"推奨項目" });
      }
      // ログ分類
      if (condObj.logClass !== "0") {
        condList.push({ name:"ログ分類", text:this.getLogClassName() });
      }
      // 対象機種
      if (condObj.targetModel !== "0") {
        condList.push({ name:"対象機種", text:this.getTargetModelName() });
      }
      // 有効項目
      if (condObj.onlySendEmail) {
        condList.push({ text:"有効項目" });
      }
      this.conditionList = condList;
    }
  },
  created() {
    this.condition.inUsed.onlySendEmail = !this.isNewRecord;
    this.condition.inUsed.isDefault = this.isNewRecord;
    this.setConditionList();

    // Storeにもコミット
    this.commitCondSendEmail();
    this.commitCondIsDefault();
  }
};
</script>

<style scoped>
.dialog-header-item {
  /* 文字色：黒テーマ字に灰色になってしまう為、黒で上書きする */
  color:#333333;
  font-size: .667em;
  height: 4.7em;
  background-color: var(--ntss-base-background-color);
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

.custom-condition-search-area {
  font-size: unset;
}
</style>
