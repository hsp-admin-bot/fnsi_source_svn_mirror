/**
 * 治療状況リスト機械室装置template
 */
<template>
  <td :colspan="colSpan" role="gridcell" :data-grid-col-index="columnIndex" v-if="dataItem[field] === null || dataItem[field] === ''" :class="className"></td>
  <td :colspan="colSpan" role="gridcell" :data-grid-col-index="columnIndex" v-else :class="[className, processStateClassName]">{{ dataItem[field] }}</td>
</template>

<script>
import { h } from "vue";
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
  },
  render() {
    const attrs = {
      colspan: this.colSpan,
      role: "gridcell",
      "data-grid-col-index": this.columnIndex,
      class: this.className
    };
    const value = this.dataItem?.[this.field];
    if (value === null || value === "") {
      return h("td", attrs);
    }
    return h("td", {
      ...attrs,
      class: [this.className, this.processStateClassName]
    }, value);
  }
};
</script>
