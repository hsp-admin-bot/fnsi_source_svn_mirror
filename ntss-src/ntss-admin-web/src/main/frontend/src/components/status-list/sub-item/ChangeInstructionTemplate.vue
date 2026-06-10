/**
 * 治療状況リスト：指示変更セルテンプレート
 */
<template>
  <td :colspan="colSpan" role="gridcell" :data-grid-col-index="columnIndex"
    v-if="dataItem['ordNo'] !== null && dataItem['IsContentChanged'] === '1'"
    :class="className.trim() + dataItem['IsContentChanged']"
    @click="onClickContentChange"
  >変更あり</td>
  <td :colspan="colSpan" role="gridcell" :data-grid-col-index="columnIndex"
    v-else-if="dataItem['ordNo'] !== null && dataItem['IsContentChanged'] === '2'"
    :class="className.trim() + dataItem['IsContentChanged']"
  >条件未送信</td>
  <!--#10407:変更なしでも画面を表示させる Start -->
  <td :colspan="colSpan" role="gridcell" :data-grid-col-index="columnIndex" 
    v-else-if="dataItem['patId'] !== null && (dataItem['IsContentChanged'] === '0' || dataItem['IsContentChanged'] === null)"
    :class="className.trim() + dataItem['IsContentChanged']"
    @click="onClickContentChange"
  >変更なし</td>
  <td :colspan="colSpan" role="gridcell" :data-grid-col-index="columnIndex" 
    v-else :class="className.trim() + dataItem['IsContentChanged']"
    @click="onClickContentChange"
  ></td>
  <!--#10407:変更なしでも画面を表示させる End -->
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
  methods: {
    onClickContentChange(e) {
      this.$emit("clickContentChange", e, this.dataItem);
    }
  }
};
</script>
