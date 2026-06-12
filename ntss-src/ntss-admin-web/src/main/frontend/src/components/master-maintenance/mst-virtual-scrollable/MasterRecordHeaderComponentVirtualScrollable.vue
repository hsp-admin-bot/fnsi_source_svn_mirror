/**
 * マスタメンテナンスレコードページ用ヘッダ
 */
<template>
  <v-card>
    <div class="header-item">
      <v-ons-row class="mark-leftmost-header">
        <v-ons-col class="condition-search-col">
          <common-searcharea
            :conditionList="conditionList"
            @show-popover="showPopover($event)"
          />
        </v-ons-col>
        <v-ons-col>
          <div class="filter-area"></div>
        </v-ons-col>
      </v-ons-row>
    </div>
    <v-ons-popover
      cancelable
      v-model:visible="popoverVisible"
      :target="popoverTarget"
      :direction="popoverDirection"
      :cover-target="false"
      :class="[fontSizeSet, 'master-search']"
      @posthide="onClosePopover"
    >
      <div style="margin: 10px">
        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="center">
            <label>名称</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <v-ons-input
              input-id="recordName"
              type="text"
              float
              v-model="condition.value"
              @keydown.enter="dialogOk"
            ></v-ons-input>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="condition-row" v-if="isShowDeleted">
          <v-ons-col width="40%" vertical-align="center">
            <v-ons-checkbox
              input-id="includeDeleted"
              float
              v-model="condition.includeDeleted"
            ></v-ons-checkbox>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <label for="includeDeleted">削除を表示する</label>
          </v-ons-col>
        </v-ons-row>
        <div class="condition-row" style="height: 30px; margin-bottom: 5px">
          <div style="float: left">
            <v-ons-button class="btn2-cancel clear" @click="dialogClear"
              >クリア</v-ons-button
            >
          </div>
          <div style="float: right">
            <v-ons-button class="btn3-normal ok" @click="dialogOk"
              >OK</v-ons-button
            >
          </div>
        </div>
      </div>
    </v-ons-popover>
  </v-card>
</template>

<!-- スクリプト処理 -->
<script>
import { mapState, mapMutations } from "@/compat/vue/vuex";
import { EventBus } from "@/compat/vue/event-bus.js";
import PopoverMixin from "@/components/PopoverMixin";
import { mapGetters } from "@/compat/vue/vuex";
import commonSearchArea from "@/components/common/CommonSearchArea";
import cloneDeep from "@/compat/collections/lodash/cloneDeep";
import ConditionContrastObj from "./MasterCondition.js";

export default {
  components: {
    "common-searcharea": commonSearchArea,
  },
  mixins: [PopoverMixin],
  data() {
    const defaultCondition = {
      recordName: "",
      includeDeleted: false,
    };
    return {
      popoverVisible: false,
      popoverTarget: null,
      popoverDirection: "down",
      defaultCondition: defaultCondition,
      condition: {
        value: "",
        fields: [],
        includeDeleted: false,
      },
      isSortMode: false,
      // 共通検索エリア部品に表示するデータのリスト
      conditionList: [],
    };
  },
  computed: {
    ...mapGetters("master-maintenance", {
      masterPhysicalName: "getMasterName",
    }),
    ...mapState("master-maintenance", ["virtualCondition"]),
    isShowDeleted() {
      return !["mst_favorite_facility"].includes(this.masterPhysicalName);
    }
  },
  watch: {
    virtualCondition: {
      handler(condition) {
        this.condition = cloneDeep(condition);
        this.setConditionList();
      },
      deep: true,
      immediate: true
    },
  },
  methods: {
    ...mapMutations("master-maintenance", [
      "setVirtualCondition",
      "resetVirtualCondition",
    ]),
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
    onClosePopover() {
      this.condition = cloneDeep(this.virtualCondition);
    },
    // -----------------------------------------
    // 抽出条件クリアボタンクリックイベント
    // -----------------------------------------
    dialogClear() {
      this.resetVirtualCondition();
      this.conditionList = [];
      // 画面を閉じる
      this.popoverVisible = false;
      // this.search();
    },
    // -----------------------------------------
    // 抽出条件OKボタンクリックイベント
    // -----------------------------------------
    dialogOk() {
      this.popoverVisible = false;
      this.search();
    },
    // -----------------------------------------
    // 処理：抽出条件を元にした検索イベント
    // -----------------------------------------
    search() {
      this.popoverVisible = false;
      // 検索条件の内容で画面を更新
      this.setVirtualCondition({
        value: this.condition.value,
        fields: ConditionContrastObj[this.masterPhysicalName] || [],
        includeDeleted: this.condition.includeDeleted,
      });
    },
    // -----------------------------------------
    // 共通検索エリア部品に表示するデータのリストを作成
    // -----------------------------------------
    setConditionList() {
      let condList = [];
      if (this.virtualCondition.value) {
        condList.push({ name: "名称", text: this.virtualCondition.value });
      }
      // 削除を表示
      if (this.virtualCondition.includeDeleted) {
        condList.push({ text: "削除を表示" });
      }
      this.conditionList = condList;
    },
  },
  mounted() {
    EventBus.$emit("addLeftmostHeaderMargin");
  },
};
</script>
