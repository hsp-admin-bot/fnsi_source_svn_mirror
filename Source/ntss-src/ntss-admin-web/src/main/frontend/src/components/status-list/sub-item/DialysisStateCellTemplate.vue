/**
 * 治療状況リスト治療状況template
 */
<template>
  <td :colspan="colSpan" role="gridcell" :data-grid-col-index="columnIndex"
    v-if="dataItem['patId'] === null && dataItem['ordNo'] !== null && dataItem['rstDialysisState'] >= 4"
    :class="[processStateClassName, classNm]"
    style="text-align: center; padding: 0.25rem 0rem !important"
  >
    <!-- add FNSI-治療状況の權限 付 start -->
    <!-- <button
      class="status-list-unknown-delete-button button status-list-grid-button registration-btn"
      @click="onClickDeleteOrder"
    >削除</button> -->
    <!-- mod FNSI-画面スタイル(ボタン)対応 付 start -->
    <!-- mod #10359 編集権限の動作不正 dengshen start -->
    <!-- <button -->
    <!--   class="status-list-unknown-delete-button button status-list-grid-button registration-btn btn4-alert" -->
    <!--   @click="onClickDeleteOrder" -->
    <!--   :disabled="!getTreatmentRecordAuthority" -->
    <!-- >削除</button> -->
    <!-- mod #10359_NG対応 編集権限の動作不正 dengshen start -->
    <!-- <button -->
    <!--   class="status-list-unknown-delete-button button status-list-grid-button registration-btn btn4-alert" -->
    <!--   @click="onClickDeleteOrder" -->
    <!--   :disabled="!getItemAuthorized('StatusListMap', 'item_delete_btn')" -->
    <!-- >削除</button> -->
    <button
      class="status-list-unknown-delete-button button status-list-grid-button registration-btn btn4-alert"
      :style="{ 'opacity': this.getItemAuthorized('StatusListMap', 'item_delete_btn') ? 1 : 0.6}"
      @click="onClickDeleteOrder"
    >削除</button>
    <!-- mod #10359_NG対応 編集権限の動作不正 dengshen end -->
    <!-- mod #10359 編集権限の動作不正 dengshen end -->
    <!-- mod FNSI-画面スタイル(ボタン)対応 付 end -->
    <!-- add FNSI-治療状況の權限 付 end -->
  </td>
  <td :colspan="colSpan" role="gridcell" :data-grid-col-index="columnIndex"
    v-else-if="dataItem['rstDialysisState'] == 5"
    :class="[classNm, processStateClassName]"
    style="text-align: center; padding: 0.25rem 0rem !important"
  >
    <!-- mod FNSI-画面スタイル(ボタン)対応 付 start -->
    <!-- mod #10359 編集権限の動作不正 dengshen start -->
    <!-- <button-->
    <!--   class="status-list-confirm-button button status-list-grid-button registration-btn btn1-execute"-->
    <!--   @click="onClickConfirmOrder"-->
    <!-- >確定</button>-->
    <button
      class="status-list-confirm-button button status-list-grid-button registration-btn btn1-execute"
      @click="onClickConfirmOrder"
      :disabled="!getItemAuthorized('StatusListMap', 'default_authority')"
    >確定</button>
    <!-- mod #10359 編集権限の動作不正 dengshen end -->
    <!-- mod FNSI-画面スタイル(ボタン)対応 付 end -->
  </td>
  <td :colspan="colSpan" role="gridcell" :data-grid-col-index="columnIndex" v-else :class="[classNm, processStateClassName]"></td>
</template>

<script>
import { h } from "vue";
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
// add FNSI-治療状況の權限 付 start
// del #10359 編集権限の動作不正 dengshen start
// import { AUTHORITY_CODES } from "@/constants/userAuthority";
// del #10359 編集権限の動作不正 dengshen end
import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
import { mapGetters } from "@/compat/vue/vuex";
// add FNSI-治療状況の權限 付 end
// add #10359_NG対応 編集権限の動作不正 dengshen start
import { messageFormat } from '@/functions/common/MessageFormat'
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages'
// add #10359_NG対応 編集権限の動作不正 dengshen end
export default {
  // add FNSI-治療状況の權限 付 start
  mixins: [ComponentGuardMixin],
  // add FNSI-治療状況の權限 付 end
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
    ...mapGetters("status-list/list", [
      "getIsShowMain"
    ]),
    classNm () {
      const classArr = this.className?.split(' ');
      const index = classArr?.findIndex((item) => {
        return item.includes('dialysis-state-td-')
      })
      if (index > -1) {
        classArr[index] += this.dataItem['rstDialysisState'];
      }
      return classArr?.join(' ')
    },
    processStateClassName() {
      const stateCd = this.dataItem["processState"];
      let rtn = "";
      if (stateCd === "99") {
        // 通信エラーに限り、治療状況セルの色を変える
        if (!this.getIsShowMain) {
          // 装置一覧表示中：無条件でセルの色を変える
          rtn =  "process-state-td-" + stateCd;
        }
        if (this.dataItem["endOfTreatment"] === true
         && this.dataItem["machineNextOrdNo"] !== undefined
         && this.dataItem["machineNextOrdNo"] !== null
         && this.dataItem["machineNextOrdNo"] === this.dataItem["ordNo"]) {
          // 現患者が治療終了以降であれば次患者の色も変える
          rtn =  "process-state-td-" + stateCd;
        }
        if (this.dataItem["machineOrdNo"] !== undefined
         && this.dataItem["machineOrdNo"] !== null
         && this.dataItem["machineOrdNo"] === this.dataItem["ordNo"]) {
          // mnt_machine_state.ord_noと一致すれば色を変える
          rtn =  "process-state-td-" + stateCd;
        } else if (this.dataItem["machineOrdNo"] === null
         && this.dataItem["machineNextOrdNo"] !== undefined
         && this.dataItem["machineNextOrdNo"] !== null
         && this.dataItem["machineNextOrdNo"] === this.dataItem["ordNo"]) {
          // mnt_machine_state.ord_noがnullかつmnt_machine_state.next_ord_noと一致すれば色を変える
          rtn =  "process-state-td-" + stateCd;
        }
        // add #6488 黒系レイアウトの際に装置名が読みにくい dou start
      } else if (this.dataItem.isOffline != "0"){
        rtn = "locked-td" + " process-state-td-" + stateCd;
      } else {
        rtn =  "";
      }
      return rtn;
    },
    // del #10359 編集権限の動作不正 dengshen start
    // // add FNSI-治療状況の權限 付 start
    // // 治療状況の權限を取得する
    // getTreatmentRecordAuthority() {
    //   return this.hasAuthorityByCd(AUTHORITY_CODES.DEL_RST);
    // }
    // // add FNSI-治療状況の權限 付 end
    // del #10359 編集権限の動作不正 dengshen end
  },
  // del #10359 編集権限の動作不正 dengshen start
  // // add #10359、#10331 編集権限について、対応する。 dengshen start
  // data() {
  //   return {
  //     disabelFlg: false,
  //   }
  // },
  // created() {
  //   this.disabelFlg = this.hasAuthorityByCd(AUTHORITY_CODES.RST_PEDIT) || this.hasAuthorityByCd(AUTHORITY_CODES.RST_EDIT);
  // },
  // // add #10359、#10331 編集権限について、対応する。 dengshen end
  // del #10359 編集権限の動作不正 dengshen end
  methods: {
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
    onClickDeleteOrder(e) {
      // add #10359_NG対応 編集権限の動作不正 dengshen start
      if (!this.getItemAuthorized('StatusListMap', 'item_delete_btn')) {
        this.$ons.notification.alert({
          // title: "権限エラー",
          // message: functionName+"を操作する権限がありません。管理者に確認してください。"
          title: DIALOG_MESSAGES[12000315].title,
          message: messageFormat(DIALOG_MESSAGES[12000315].message, "治療実績削除")
        });
        return;
      }
      // add #10359_NG対応 編集権限の動作不正 dengshen end
      this.$emit("clickDeleteOrder", e, this.dataItem);
    },
    onClickConfirmOrder(e) {
      this.$emit("clickConfirmOrder", e, this.dataItem);
    }
  },
  render() {
    const cellBase = {
      colspan: this.colSpan,
      role: "gridcell",
      "data-grid-col-index": this.columnIndex
    };
    const centeredStyle = "text-align: center; padding: 0.25rem 0rem !important";
    if (this.dataItem?.patId === null && this.dataItem?.ordNo !== null && this.dataItem?.rstDialysisState >= 4) {
      return h("td", {
        ...cellBase,
        class: [this.processStateClassName, this.classNm],
        style: centeredStyle
      }, [h("button", {
        class: "status-list-unknown-delete-button button status-list-grid-button registration-btn btn4-alert",
        style: { opacity: this.getItemAuthorized('StatusListMap', 'item_delete_btn') ? 1 : 0.6 },
        onClick: this.onClickDeleteOrder
      }, "削除")]);
    }
    if (this.dataItem?.rstDialysisState == 5) {
      return h("td", {
        ...cellBase,
        class: [this.classNm, this.processStateClassName],
        style: centeredStyle
      }, [h("button", {
        class: "status-list-confirm-button button status-list-grid-button registration-btn btn1-execute",
        disabled: !this.getItemAuthorized('StatusListMap', 'default_authority'),
        onClick: this.onClickConfirmOrder
      }, "確定")]);
    }
    return h("td", {
      ...cellBase,
      class: [this.classNm, this.processStateClassName]
    });
  }
};
</script>
