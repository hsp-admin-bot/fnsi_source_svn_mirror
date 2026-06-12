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
    onClickContentChange(e) {
      this.$emit("clickContentChange", e, this.dataItem);
    }
  },
  render() {
    const contentChanged = this.dataItem?.IsContentChanged;
    const attrs = {
      colspan: this.colSpan,
      role: "gridcell",
      "data-grid-col-index": this.columnIndex,
      class: `${(this.className || "").trim()}${contentChanged}`
    };
    if (this.dataItem?.ordNo !== null && contentChanged === "1") {
      return h("td", { ...attrs, onClick: this.onClickContentChange }, "変更あり");
    }
    if (this.dataItem?.ordNo !== null && contentChanged === "2") {
      return h("td", attrs, "条件未送信");
    }
    if (this.dataItem?.patId !== null && (contentChanged === "0" || contentChanged === null)) {
      return h("td", { ...attrs, onClick: this.onClickContentChange }, "変更なし");
    }
    return h("td", { ...attrs, onClick: this.onClickContentChange });
  }
};
</script>
