/**
 * 治療状況リストスタッフ選択Template
 */
<template>
  <td :colspan="colSpan" role="gridcell" :data-grid-col-index="columnIndex" v-if="dataItem.inEdit!==field" :class="className" @click="onClick">{{ dataItem[field] }}</td>
  <td :colspan="colSpan" role="gridcell" :data-grid-col-index="columnIndex" v-else>
    <input v-model="dateTimeStr" type="datetime-local" @blur="changeDateTime" />
  </td>
</template>

<script>
import dayjs from "@/compat/date/dayjs";

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
      dateTimeStr: ""
    };
  },
  methods: {
    onClick() {
      if (this.dateTimeStr !== "") {
        ((this.dataItem)["inEdit"] = this.field);
        this.$emit("editStart");
      }
    },
    changeDateTime(e) {
      if (
        dayjs(this.dataItem[this.field]).format("YYYY-MM-DDTHH:mm") ===
        this.dateTimeStr
      ) {
        // 変更なし
      } else {
        const changedValue = dayjs(
          this.dateTimeStr,
          "YYYY/MM/DDTHH:mm"
        ).toDate();
        this.$emit(
          "changeDateTime",
          e,
          this.dataItem,
          this.field,
          changedValue
        );
      }
    }
  },
  mounted() {
    if (
      this.dataItem[this.field] === undefined ||
      this.dataItem[this.field] === null ||
      this.dataItem[this.field] === ""
    ) {
      this.dateTimeStr = "";
    } else {
      this.dateTimeStr = dayjs(this.dataItem[this.field]).format(
        "YYYY-MM-DDTHH:mm"
      );
    }
  }
};
</script>
