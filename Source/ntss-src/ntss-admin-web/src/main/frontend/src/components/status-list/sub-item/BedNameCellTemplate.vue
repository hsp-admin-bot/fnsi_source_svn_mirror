/**
 * 治療状況リストベッド名セルテンプレート
 */
<template>
  <td :colspan="colSpan" role="gridcell" :data-grid-col-index="columnIndex" v-if="dataItem['bedName'] === null || dataItem['bedName'] === ''" :class="className"></td>
  <td :colspan="colSpan" role="gridcell" :data-grid-col-index="columnIndex" v-else :class="className" @click="onClickBedName">{{ dataItem[field]}}</td>
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
  methods: {
    onClickBedName(e) {
      this.$emit("clickBedName", e, this.dataItem);
    }
  },
  render() {
    const attrs = {
      colspan: this.colSpan,
      role: "gridcell",
      "data-grid-col-index": this.columnIndex,
      class: this.className
    };
    const bedName = this.dataItem?.bedName;
    if (bedName === null || bedName === "") {
      return h("td", attrs);
    }
    return h("td", {
      ...attrs,
      onClick: this.onClickBedName
    }, this.dataItem?.[this.field]);
  }
};
</script>
