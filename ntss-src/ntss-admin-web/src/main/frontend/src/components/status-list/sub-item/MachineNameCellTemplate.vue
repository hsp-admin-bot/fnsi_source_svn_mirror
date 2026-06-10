/**
 * 治療状況リスト機械室装置template
 */
<template>
  <td :colspan="colSpan" role="gridcell" :data-grid-col-index="columnIndex" v-if="dataItem[field] === null || dataItem[field] === ''" :class="className"></td>
  <td :colspan="colSpan" role="gridcell" :data-grid-col-index="columnIndex" v-else :class="[className, processStateClassName]">{{ dataItem[field] }}</td>
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
  computed: {
    processStateClassName() {
      const stateCd = this.dataItem["processState"];
      if (stateCd !== undefined && stateCd !== null) {
        return "process-state-td-" + stateCd;
      } else {
        return "";
      }
    },
  }
};
</script>
