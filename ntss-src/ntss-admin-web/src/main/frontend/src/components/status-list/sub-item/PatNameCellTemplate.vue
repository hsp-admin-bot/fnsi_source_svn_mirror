/**
 * 治療状況リスト患者名セル店プレート
 */
<template>
  <td :colspan="colSpan" role="gridcell" :data-grid-col-index="columnIndex"
    v-if="dataItem['patId'] === null && dataItem['ordNo'] !== null"
    :class="className"
    @click="onClickPatName"
  >？？？？</td>
  <!-- add FNSI-同姓同名患者の場合はアイコンを表示 付 start -->
  <!-- <td :colspan="colSpan" role="gridcell" :data-grid-col-index="columnIndex" v-else :class="className" @click="onClickPatName">{{ dataItem[field]}}</td> -->
  <td :colspan="colSpan" role="gridcell" :data-grid-col-index="columnIndex" v-else :class="className" :style="dataItem['inOutClass'] == 1? 'color: #A356A3;': ''" @click="onClickPatName">
    {{ dataItem[field]}}
    <!-- 治療状況list画面患者名の横の画像は表示されません。linjunfeng start -->
    <!-- <img class="same-icon" v-show="dataItem['isSame'] === '1'" src="/ntss-admin-web/img/name_duplication.9baeef13.png" /> -->
    <img class="same-icon" v-show="dataItem['isSame'] === '1'" :src="image_src_same" />
    <!-- 治療状況list画面患者名の横の画像は表示されません。linjunfeng end -->
  </td>
  <!-- add FNSI-同姓同名患者の場合はアイコンを表示 付 end -->
</template>

<script>
import { h } from "vue";
import nameDuplicationImg from "../../../assets/name_duplication.png";
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
  data() {
    return {
      // 治療状況list画面患者名の横の画像は表示されません。linjunfeng start
      image_src_same: nameDuplicationImg,
      // 治療状況list画面患者名の横の画像は表示されません。linjunfeng end
    }
  },
  methods: {
    onClickPatName(e) {
      this.$emit("clickPatName", e, this.dataItem);
    }
  },
  render() {
    const attrs = {
      colspan: this.colSpan,
      role: "gridcell",
      "data-grid-col-index": this.columnIndex,
      class: this.className,
      onClick: this.onClickPatName
    };
    if (this.dataItem?.patId === null && this.dataItem?.ordNo !== null) {
      return h("td", attrs, "？？？？");
    }
    const children = [this.dataItem?.[this.field]];
    if (this.dataItem?.isSame === "1") {
      children.push(h("img", { class: "same-icon", src: this.image_src_same }));
    }
    return h("td", {
      ...attrs,
      style: this.dataItem?.inOutClass == 1 ? "color: #A356A3;" : ""
    }, children);
  }
};
</script>
<style scoped>
/* add FNSI-同姓同名患者の場合はアイコンを表示 付 start */
.same-icon {
  position: relative;
  top: 0.25em;
  height: 20px;
}
/* add FNSI-同姓同名患者の場合はアイコンを表示 付 end */
</style>
