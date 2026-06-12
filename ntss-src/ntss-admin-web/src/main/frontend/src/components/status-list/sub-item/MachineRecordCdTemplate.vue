/**
 * 治療状況リスト：装置自己診断セルテンプレート
 */
<template>
<!-- mod #10063 by zhangruixue 2023-11-17  rollback 7192--start -->
  <td :colspan="colSpan" role="gridcell" :data-grid-col-index="columnIndex" v-if="dataItem['machineRecordCd'] === 'G100'" @click="onClickMachineRecordCd">合格</td>
  <td :colspan="colSpan" role="gridcell" :data-grid-col-index="columnIndex" v-else-if="dataItem['machineRecordCd'] === 'G101'" @click="onClickMachineRecordCd">不合格</td>
  <td :colspan="colSpan" role="gridcell" :data-grid-col-index="columnIndex" v-else-if="dataItem['machineRecordCd'] === 'G102'" @click="onClickMachineRecordCd">合格(注意)</td>
<!--  <td :colspan="colSpan" role="gridcell" :data-grid-col-index="columnIndex" v-if="dataItem['machineRecordCd'] === '- '" @click="onClickMachineRecordCd">合格</td>-->
<!--  <td :colspan="colSpan" role="gridcell" :data-grid-col-index="columnIndex" v-else-if="dataItem['machineRecordCd'] === '-   '" @click="onClickMachineRecordCd">不合格</td>-->
<!--  <td :colspan="colSpan" role="gridcell" :data-grid-col-index="columnIndex" v-else-if="dataItem['machineRecordCd'] === '-  '" @click="onClickMachineRecordCd">合格(注意)</td>-->
<!-- mod #10063 by zhangruixue 2023-11-17  rollback 7192--end -->
  <td :colspan="colSpan" role="gridcell" :data-grid-col-index="columnIndex" v-else @click="onClickMachineRecordCd">未実施</td>
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
    onClickMachineRecordCd(e) {
      this.$emit("clickMachineRecordCd", e, this.dataItem);
    }
  }
};
</script>
