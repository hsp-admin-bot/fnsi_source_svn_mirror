/**
 * 治療状況リスト患者名セル テンプレート
 */
<template>
  <td :colspan="colSpan" role="gridcell" :data-grid-col-index="columnIndex" v-if="dataItem['hospPatId'] != null && dataItem['hospPatId'] != '' && dataItem['hospPatId'] != undefined" :class="['hosp-pat-id-body', className]">{{ dataItem['hospPatId']}}</td>
  <td :colspan="colSpan" role="gridcell" :data-grid-col-index="columnIndex" v-else :class="['hosp-pat-id-body', className]"></td>
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
  }
};
</script>
