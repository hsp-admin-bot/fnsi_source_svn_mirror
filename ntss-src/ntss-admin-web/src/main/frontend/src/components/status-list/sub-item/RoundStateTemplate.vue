/**
 * 治療状況リスト：回診状態セルテンプレート
 */
<template>
  <td :colspan="colSpan" role="gridcell" :data-grid-col-index="columnIndex" :class="[className, roundStateClassName]">{{ dataItem[field] }}</td>
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
    roundStateClassName() {
      const roundStateHighlighting = this.dataItem["roundStateHighlighting"];
      if (!!roundStateHighlighting) {
        return "round-state-td-highlighting-" + roundStateHighlighting;
      } else {
        return "";
      }
    },
  }
};
</script>
