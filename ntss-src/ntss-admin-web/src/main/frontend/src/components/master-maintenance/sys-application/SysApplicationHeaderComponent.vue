/** アプリケーションダウンロードページ用ヘッダ */
<template>
  <v-card>
    <div class='header-item'>
      <v-ons-row class='mark-leftmost-header'>
        <v-ons-col class='condition-search-col'>
          <common-searcharea :conditionList='conditionList' @show-popover='showPopover($event)'/>
        </v-ons-col>
        <v-ons-col><div class='filter-area' /></v-ons-col>
      </v-ons-row>
    </div>
    <v-ons-popover 
      cancelable
      :visible.sync='popoverVisible'
      :target='popoverTarget'
      direction='down'
      :cover-target='false'
      :class="[fontSizeSet, 'master-search']"
    >
      <div class='popover-area-wrapper'>
        <div v-if='isSearchFlg'>
          <v-ons-row class='condition-row'>
            <v-ons-col width='40%' vertical-align='center'>
              <label>名称</label>
            </v-ons-col>
            <v-ons-col width='60%' vertical-align='center'>
              <v-ons-input input-id='recordName' type='text' float  v-model='condition.recordName' @keypress.enter='onSearchEnter'/>
            </v-ons-col>
          </v-ons-row>
          <div class='condition-row popover-area-btn'>
            <div class='clear-btn'>
              <v-ons-button class='btn2-cancel clear' @click='dialogClear'>クリア</v-ons-button>
            </div>
            <div class='ok-btn'>
              <v-ons-button class='btn3-normal ok' @click='dialogOk'>OK</v-ons-button>
            </div>
          </div>
        </div>
      </div>
    </v-ons-popover>
  </v-card>
</template>

<script>
import { mapActions } from "vuex";
import { EventBus } from "@/eventBus.js";
import commonSearchArea from "@/components/common/CommonSearchArea";
import PopoverMixin from "@/components/PopoverMixin";

export default {
  mixins: [PopoverMixin],
  components: {"common-searcharea": commonSearchArea},
  data() {
    return {
      popoverVisible: false,
      popoverTarget: null,
      condition: {
        recordName: ""
      },
      isSearchFlg: false,
      conditionList: []
    };
  },
  methods: {
    ...mapActions("sys-application", ["setCondition"]),
    /** 抽出UI表示イベント */
    showPopover(event) {
      this.isSearchFlg = true;
      this.popoverTarget = event;
      this.popoverVisible = true;
    },
    /** クリア処理 */
    dialogClear() {
      this.condition.recordName = "";
      this.conditionList = [];
      this.popoverVisible = false;
      this.commitCondition();
    },
    /** 入力欄Enter押下時 */
    onSearchEnter() {
      this.dialogOk();
    },
    /** OK処理 */
    dialogOk() {
      this.popoverVisible = false;
      let condList = [];
      const condObj = this.condition;
      if (condObj.recordName != "") {
        condList.push({ name: "アプリダウン名", text: condObj.recordName });
      }
      this.conditionList = condList;
      this.commitCondition();
    },
    /** 共通：抽出条件を設定 */
    commitCondition() {
      this.setCondition(JSON.parse(JSON.stringify(this.condition)));
    },
  },
  mounted() {
    EventBus.$emit("addLeftmostHeaderMargin");
  }
};
</script>

<style scoped>
.popover-area-wrapper {
  margin: 10px;
}
.popover-area-btn {
  height: 30px;
  margin-bottom: 5px;
}
.clear-btn {
  float: left;
}
.ok-btn {
  float: right;
}
</style>
