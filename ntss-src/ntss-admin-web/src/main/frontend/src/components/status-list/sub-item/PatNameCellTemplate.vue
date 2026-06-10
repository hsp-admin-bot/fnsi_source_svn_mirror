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
      image_src_same: require("../../../assets/name_duplication.png"),
      // 治療状況list画面患者名の横の画像は表示されません。linjunfeng end
    }
  },
  methods: {
    onClickPatName(e) {
      this.$emit("clickPatName", e, this.dataItem);
    }
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
