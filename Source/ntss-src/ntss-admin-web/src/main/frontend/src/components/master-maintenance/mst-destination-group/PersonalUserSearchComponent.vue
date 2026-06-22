/**
 * 送信先グループマスタ スタッフ検索用コンポーネント
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
                    v-model:visible='popoverVisible'
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
            <label class="search-label-font">スタッフ名</label>
          </v-ons-col>
          <v-ons-col width='60%' vertical-align='center'>
            <v-ons-input 
              input-id='staffName'
              type='text'
              float
              v-model='condition.inProgress.staffName'
            ></v-ons-input>
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
            <label class="search-label-font" for="onlySendEmailCtrl">ONのみ表示</label>
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
import { mapActions } from "@/compat/vue/vuex";
import { EventBus } from "@/compat/vue/event-bus.js";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import commonSearchArea from "@/components/common/CommonSearchArea";
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";

export default {
  components: {
    "common-searcharea": commonSearchArea
  },
  mixins: [MasterMaintenanceMixin],
  name: "PersonalUserSearchComponent",
  data() {
    const defaultCondition = {
      staffName: "",
      onlySendEmail: false
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
  methods: {
    ...mapActions("mst-destination-group", [
      "setConditionStaffName",
      "setConditionOnlySendEmail",
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
      this.commitCondStaffName();
      this.commitCondSendEmail();
      EventBus.$emit("setStaffList");
    },
    commitCondStaffName() {
      this.setConditionStaffName(this.condition.inUsed.staffName);
    },
    commitCondSendEmail() {
      this.setConditionOnlySendEmail(this.condition.inUsed.onlySendEmail);
    },
    copyConditionInProgressToInUsed() {
      this.condition.inUsed.staffName = this.condition.inProgress.staffName;
      this.condition.inUsed.onlySendEmail = this.condition.inProgress.onlySendEmail;
      this.setConditionList();
    },
    copyConditionInUsedToInProgress() {
      this.condition.inProgress.staffName = this.condition.inUsed.staffName;
      this.condition.inProgress.onlySendEmail = this.condition.inUsed.onlySendEmail;
    },
    clearConditionInUsedAndInProgress() {
      this.condition.inUsed.staffName = this.defaultCondition.staffName;
      this.condition.inUsed.onlySendEmail = this.defaultCondition.onlySendEmail;
      this.condition.inProgress.staffName = this.defaultCondition.staffName;
      this.condition.inProgress.onlySendEmail = this.defaultCondition.onlySendEmail;
    },
    // 共通検索エリア部品に表示するデータのリストを作成
    setConditionList() {
      let condList = [];
      const condObj = this.condition.inUsed;
      // スタッフ名
      if (condObj.staffName != "") {
        condList.push({ name:"スタッフ名", text:condObj.staffName });
      }
      // ONのみ表示
      if (condObj.onlySendEmail) {
        condList.push({ text:"ONのみ表示" });
      }
      this.conditionList = condList;
    }
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
.button-row :deep(.button) {
  width: auto;
  min-width: 80px;
}

.custom-condition-search-area {
  font-size: unset;
}
</style>
