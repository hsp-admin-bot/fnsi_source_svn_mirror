/**
 * 治療状況リストベッド名セルテンプレート
 */
<template>
  <td :colspan="colSpan" role="gridcell" :data-grid-col-index="columnIndex" v-if="dataItem['bedName'] === null || dataItem['bedName'] === ''" :class="className"></td>
  <td :colspan="colSpan" role="gridcell" :data-grid-col-index="columnIndex" v-else :class="className" @click="onClickBedName">{{ dataItem[field]}}</td>
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
    onClickBedName(e) {
      this.$emit("clickBedName", e, this.dataItem);
    }
  }
};
</script>
