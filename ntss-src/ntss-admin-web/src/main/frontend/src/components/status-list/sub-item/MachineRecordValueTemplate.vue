/**
 * 治療状況リスト：警報・報知セルテンプレート
 */
<template>
  <!-- mod #9371 治療状況リストにおける警報・報知の動作不良 dou start -->
  <!-- mod #9712 by zhangruixue 2023-09-26 --start  -->
  <td :colspan="colSpan" role="gridcell" :data-grid-col-index="columnIndex" v-if="getWarnInfoBlank(dataItem) === 'warn'" @click="onBlankClick">
    <img src='img/status-list/keihou.gif' class='ntss-fab-icon gif-icon' @click="onWarnClick"/>
    <img src='img/status-list/keihou_static.png' class='ntss-fab-icon static-icon'/>
  </td>
  <td :colspan="colSpan" role="gridcell" :data-grid-col-index="columnIndex" v-else-if="getWarnInfoBlank(dataItem) === 'info'" @click="onBlankClick">
    <img src='img/status-list/houchi.gif' class='ntss-fab-icon gif-icon' @click="onInfoClick"/>
    <img src='img/status-list/houchi_static.png' class='ntss-fab-icon static-icon'/>
  </td>
  <td :colspan="colSpan" role="gridcell" :data-grid-col-index="columnIndex" v-else @click="onBlankClick"></td>
  <!-- mod #9712 by zhangruixue 2023-09-26 --end  -->
  <!-- mod #9371 治療状況リストにおける警報・報知の動作不良 dou end -->
</template>

<script>
import { h } from "vue";
// mod FNSI-警報・報知追加 徐 start
import { mapGetters, mapActions, mapMutations } from "@/compat/vue/vuex";
// mod FNSI-警報・報知追加 徐 end
import commonFunctions from "@/components/status-list/StatusCommonFunction";
export default {
  props: {
    field: String,
    dataItem: Object,
    format: String,
    className: String,
    columnIndex: Number,
    columnsCount: Number,
    rowType: String,
    level: Number,
    expanded: Boolean,
    editor: String,
    colSpan: Number
  },
  // add FNSI-警報・報知追加 徐 start
  computed: {
    ...mapGetters("status-list/list", [
      "getIsAlarmDisplay",
      "getIsShowMain"
    ]),
  },
  // add FNSI-警報・報知追加 徐 end
  methods: {
    ...mapActions("status-list/list", ["setIsGoAlarmPage",
      "setIsAlarmDisplay"]),
    ...mapMutations("status-list/list", {
      setStatusFlg: "setStatusFlg",
      setStatusList: "setStatusList"
    }),
    // mod #9371 治療状況リストにおける警報・報知の動作不良 dou start
    onWarnClick(e) {
      this.$emit("warn-click", e, this.dataItem);
    },
    onInfoClick(e) {
      this.$emit("info-click", e, this.dataItem);
    },
    onBlankClick(e) {
      this.$emit("blank-click", e, this.dataItem);
    },
    // mod #9371 治療状況リストにおける警報・報知の動作不良 dou end
    /**
     * 警報 or 報知 or 空欄 かを判定
     * @param {Object} dataItem
     * @return {String} "warn": 警報、"info": 報知、"": 空欄
     */
    getWarnInfoBlank(dataItem) {
      return commonFunctions.judgeWarnInfoBlank(this.getIsShowMain, dataItem);
    }
  },
  render() {
    const attrs = {
      colspan: this.colSpan,
      role: "gridcell",
      "data-grid-col-index": this.columnIndex,
      onClick: this.onBlankClick
    };
    const warnInfo = this.getWarnInfoBlank(this.dataItem);
    if (warnInfo === "warn") {
      return h("td", attrs, [
        h("img", { src: "img/status-list/keihou.gif", class: "ntss-fab-icon gif-icon", onClick: this.onWarnClick }),
        h("img", { src: "img/status-list/keihou_static.png", class: "ntss-fab-icon static-icon" })
      ]);
    }
    if (warnInfo === "info") {
      return h("td", attrs, [
        h("img", { src: "img/status-list/houchi.gif", class: "ntss-fab-icon gif-icon", onClick: this.onInfoClick }),
        h("img", { src: "img/status-list/houchi_static.png", class: "ntss-fab-icon static-icon" })
      ]);
    }
    return h("td", attrs);
  }
};
</script>

<style>
.ntss-fab-icon {
  margin-top: 5px;
  height: 30px;
  width: 30px;
}
</style>
