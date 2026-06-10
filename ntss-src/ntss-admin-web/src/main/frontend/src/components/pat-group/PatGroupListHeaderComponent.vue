<template>
  <v-card>
    <div class="header-item">
      <v-ons-row class="mark-leftmost-header">
        <v-ons-col class="condition-search-col">
          <common-searcharea :conditionList="conditionList" @show-popover='showPopover($event)'/>
        </v-ons-col>
        <v-ons-col>
          <div class="filter-area"></div>
        </v-ons-col>
      </v-ons-row>
    </div>
    <v-ons-popover cancelable
                   :visible.sync='popoverVisible'
                   :target='popoverTarget'
                   :direction='popoverDirection'
                   :cover-target=false
                   :class="[fontSizeSet, 'master-search']"
                   >
      <div style='margin:10px;'>
        <v-ons-row class='condition-row'>
          <v-ons-col width='40%' vertical-align='center'>
            <label>フリーワード</label>
          </v-ons-col>
          <!--mod FNSI-改修内容画面デザイン 任 start-->
          <!--<v-ons-col width='60%' vertical-align='center'>
            <v-ons-input
              input-id='patGroupName'
              type='text'
              float
              v-model='condition.inProgress.patGroupName'
              @keydown.enter='onSearchEnter'></v-ons-input>
          </v-ons-col>
        </v-ons-row>
        <div class='condition-row' style="height:30px;margin-bottom:5px;">
          <div style="float:left;">
            <v-ons-button class='clear' @click='dialogClear'>クリア</v-ons-button>
          </div>
          <div style="float:right;">
            <v-ons-button class='ok' @click='dialogOk'>OK</v-ons-button>-->
          <v-ons-col width='60%' vertical-align='center'>
            <v-ons-input
            input-id='patGroupName'
            type='text'
            float
            v-model='condition.inProgress.patGroupName'
            @keydown.enter='onSearchEnter'></v-ons-input>
          </v-ons-col>
        </v-ons-row>
        <div class='condition-row' style="height:30px;margin-bottom:5px;">
          <div style="float:left;">
            <v-ons-button class='clear btn2-cancel' @click='dialogClear'>クリア</v-ons-button>
          </div>
          <div style="float:right;">
            <v-ons-button class='ok btn3-normal' @click='dialogOk'>OK</v-ons-button>
            <!--mod FNSI-改修内容画面デザイン 任 end-->
          </div>
        </div>
      </div>
    </v-ons-popover>
  </v-card>
</template>

<script>
  import {EventBus} from "@/eventBus.js";
  import PopoverMixin from "@/components/PopoverMixin";
  import commonSearchArea from "@/components/common/CommonSearchArea";

  export default {
  components: {
    "common-searcharea": commonSearchArea
  },
  mixins: [PopoverMixin],
  name: "PatGroupListHeaderComponent",
  data() {
    const defaultCondition = {
      patGroupName: ""
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
      isSortMode: false,
      // 共通検索エリア部品に表示するデータのリスト
      conditionList: []
    };
  },
  methods: {
    showPopover(event) {
      if (this.isSortMode) {
        return;
      }
      this.condition.inProgress.patGroupName = this.condition.inUsed.patGroupName;
      this.popoverTarget = event;
      this.popoverVisible = true;
    },
     dialogClear() {
      this.condition.inProgress.patGroupName = this.defaultCondition.patGroupName;
      this.condition.inUsed.patGroupName = this.defaultCondition.patGroupName;
      this.popoverVisible = false;
      this.search();
    },
    dialogOk() {
      this.popoverVisible = false;
      this.condition.inUsed.patGroupName = this.condition.inProgress.patGroupName;
      this.search();
    },
    onSearchEnter : function(){
      this.dialogOk();
    },
    search() {
      EventBus.$emit("filterPatGroupist", this.condition.inUsed);
      this.setConditionList();
    },
    // 共通検索エリア部品に表示するデータのリストを作成
    setConditionList() {
      let condList = [];
      const condObj = this.condition.inUsed;
      // フリーワード
      if (condObj.patGroupName.trim() != "") {
        condList.push({ name:"フリーワード", text:condObj.patGroupName });
      }
      this.conditionList = condList;
    },
    // 並び順モードの設定
    setSortMode(isSortMode) {
      this.isSortMode = isSortMode;
      if (this.isSortMode) {
        this.dialogClear();
      }
    },
    // 検索条件のクリア
    clearCondition() {
      this.dialogClear();
      this.search();
    }
  },
  // Vueインスタンス作成後
  created() {
    EventBus.$on("setSortMode", this.setSortMode);
    EventBus.$on("clearCondition", this.clearCondition);
  },
  mounted() {
    EventBus.$emit("addLeftmostHeaderMargin");
  },
  // Vueインスタンス破棄前
  beforeDestroy() {
    EventBus.$off("setSortMode", this.setSortMode);
    EventBus.$off("clearCondition", this.clearCondition);
  }
};
</script>
<style scoped>
ons-popover >>> .popover__content {
  min-width: 350px;
}
</style>
