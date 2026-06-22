/**
* 機能帳票マスタメンテナンスレコードページ用ヘッダ
*/
<template>
  <v-card>
    <div class='header-item'>
      <v-ons-row class='mark-leftmost-header'>
        <v-ons-col class='condition-search-col'>
          <div class='condition-search-area' @click='showPopover($event)'>
            <div class='condition-search-icon-area'>
              <v-ons-icon icon='fa-search' size='2.0em' style="color:gray;"></v-ons-icon>
            </div>
            <div class='condition-items-area'>
              <label class='condition-label' v-if='condition.recordName!=""'>
                {{ condition.recordName }}
              </label>
              <br v-if='condition.recordName!=""'/>
              <label class='condition-label' v-if='condition.includeDeleted'>
                削除を表示
              </label>
            </div>
          </div>
        </v-ons-col>
        <v-ons-col>
          <div class="filter-area"></div>
        </v-ons-col>
      </v-ons-row>
    </div>
    <v-ons-popover cancelable
                   v-model:visible='popoverVisible'
                   :target='popoverTarget'
                   :direction='popoverDirection'
                   :cover-target=false
                   :class="[fontSizeSet, 'master-search']"
    >
      <div style='margin:10px;'>
        <v-ons-row class='condition-row'>
          <v-ons-col width='40%' vertical-align='center'>
            <label>名称</label>
          </v-ons-col>
          <v-ons-col width='60%' vertical-align='center'>
            <v-ons-input input-id='recordName' type='text' float  v-model='condition.recordName' @keydown.enter='onSearchEnter'></v-ons-input>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class='condition-row'>
          <v-ons-col width='40%' vertical-align='center'>
            <v-ons-checkbox input-id='includeDeleted' float  v-model='condition.includeDeleted'></v-ons-checkbox>
          </v-ons-col>
          <v-ons-col width='60%' vertical-align='center'>
            <label>削除を表示する</label>
          </v-ons-col>
        </v-ons-row>
        <div class='condition-row' style="height:30px;margin-bottom:5px;">
          <div style="float:left;">
            <v-ons-button class='btn2-cancel clear' @click='dialogClear'>クリア</v-ons-button>
          </div>
          <div style="float:right;">
            <v-ons-button class='btn3-normal ok' @click='dialogOk'>OK</v-ons-button>
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
import PopoverMixin from "@/components/PopoverMixin";

export default {
  mixins: [PopoverMixin],
  data() {
    return {
      popoverVisible: false,
      popoverTarget: null,
      popoverDirection: "down",
      condition: {
        recordName: "",
        includeDeleted: false
      },
      isSortMode: false
    };
  },
  methods: {
    ...mapActions("master-maintenance", ["setCondition"]),
    // -----------------------------------------
    // 抽出UI表示イベント
    // -----------------------------------------
    showPopover(event) {
      // ソートモード時は表示しない
      if (this.isSortMode) {
        return;
      }
      this.popoverTarget = event;
      this.popoverVisible = true;
    },
    // -----------------------------------------
    // 抽出条件クリアボタンクリックイベント
    // -----------------------------------------
    dialogClear() {
      // 検索条件クリアして画面を更新
      this.condition.recordName = "";
      this.condition.includeDeleted = false;
      // 画面を閉じる
      this.popoverVisible = false;
      this.search();
    },
    // -----------------------------------------
    // 抽出条件Enter押下時イベント
    // -----------------------------------------
    onSearchEnter : function(){
      this.dialogOk();
    },
    // -----------------------------------------
    // 抽出条件OKボタンクリックイベント
    // -----------------------------------------
    dialogOk() {
      this.popoverVisible = false;
      this.search();
    },
    // ------------------------------------------------------------------
    // 処理：抽出条件を元にした検索イベント
    // ------------------------------------------------------------------
    search() {
      // 検索条件の内容で画面を更新
      this.setCondition(JSON.parse(JSON.stringify(this.condition)));
    },
    setSortMode(isSortMode) {
      // 検索条件の内容で画面を更新
      this.isSortMode = isSortMode;
      if (this.isSortMode) {
        // ソートモード時は条件クリア
        this.dialogClear();
      }
    }
  },
  created() {
    EventBus.$on("setSortMode", this.setSortMode);
  },
  // add 性能改善メモリ不足 shan start
  beforeUnmount() {
    EventBus.$off("setSortMode", this.setSortMode);
  },
  // add 性能改善メモリ不足 shan end
  mounted() {
    EventBus.$emit("addLeftmostHeaderMargin");
  }
};
</script>
