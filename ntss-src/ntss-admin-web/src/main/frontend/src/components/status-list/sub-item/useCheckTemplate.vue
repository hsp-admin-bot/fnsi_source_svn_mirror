
<template>
  <td :colspan="colSpan" role="gridcell" :data-grid-col-index="columnIndex" v-if="this.dataItem['un_use' + this.format]" :class="'un-use'">{{ dataItem[field] }}</td>
  <td :colspan="colSpan" role="gridcell" :data-grid-col-index="columnIndex" v-else >{{ dataItem[field] }}</td>
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
    colSpan: Number,
    rowIndex: Number
  }
};
</script>
