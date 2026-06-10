/** * 治療状況リストスタッフ選択Template */
<template>
  <!-- modify by chamaojia 2024-05-10 [10573] add the "isDisabled" parameter to pass in the subcomponent   start -->
  <!-- mod FNSI-画面スタイル(ボタン)対応 付 start -->
  <td :colspan="colSpan" role="gridcell" :data-grid-col-index="columnIndex" :class="[className, 'selector-cell-template']">
    <!-- mod #10359 編集権限の動作不正 dengshen start -->
    <!-- <com-master-selector -->
    <!--   :showLabelName="false" -->
    <!--   :showClassFilter="true" -->
    <!--   :readMasterData="fetchPersonalUserAll" -->
    <!--   :masterDefine="personalUserDefine" -->
    <!--   :isDisabled="isNotEdit" -->
    <!--   :exeLableName="'保存'" -->
    <!--   @changePersonalUser="onChangePersonalUser" -->
    <!--   :value="getStaffName" -->
    <!--   @click="onClick" -->
    <!--   style="btn3-normal" -->
    <!-- /> -->
    <com-master-selector
      :showLabelName="false"
      :showClassFilter="true"
      :readMasterData="fetchPersonalUserAll"
      :masterDefine="personalUserDefine"
      :isDisabled="!getItemAuthorized('StatusListMap', 'default_authority')"
      :exeLableName="'保存'"
      @changePersonalUser="onChangePersonalUser"
      :value="getStaffName"
      @click="onClick"
      style="btn3-normal"
      @popover-visible-changed="handlePopoverVisibleChange"
    />
    <!-- mod #10359 編集権限の動作不正 dengshen end -->
  </td>
  <!-- mod FNSI-画面スタイル(ボタン)対応 付 end -->
  <!-- modify by chamaojia 2024-05-10 [10573] add the "isDisabled" parameter to pass in the subcomponent   end -->
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import CommonMasterSelectorComponent from "@/components/common/master-selector/CommonMasterSelectorComponent";
import { usersUnregisteredOpt } from "@/components/common/master-selector/MasterSelectorDefinitions";
import {
  sendRequestGetMstPersonalUser,
  sendRequestMstGetJobs
} from "@/apis/user-selector-popover";
import { Master } from "@/models/common/master-selector-condition/Master";
import { mapGetters } from "vuex";

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
  components: {
    "com-master-selector": CommonMasterSelectorComponent
  },
  data() {
    return {
      selectValue: null,
      personalUserDefine: usersUnregisteredOpt
    };
  },
  computed: {
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("user-selector-popover", ["mstPersonalUser"]),
    // add 11778 【因島】実績の穿刺者や返血者の選択ダイアログでログイン者が選択されていない zkm start
    ...mapGetters("account-edit", {userInfo: "getStateUserAccountInfo"}),
    // add 11778 【因島】実績の穿刺者や返血者の選択ダイアログでログイン者が選択されていない zkm end
    getStaffName() {
      const staffCd = this.dataItem[this.field];
      if (this.mstPersonalUser) {
        const staff = this.mstPersonalUser.filter(
          data => data.userId == +staffCd
        );
        if (staff.length > 0) {
          return new Master(staff[0].userId, staff[0].userName);
        }
      }
      // mod 11778 【因島】実績の穿刺者や返血者の選択ダイアログでログイン者が選択されていない zkm start
      // return new Master();
      return new Master(this.userInfo.userId);
      // mod 11778 【因島】実績の穿刺者や返血者の選択ダイアログでログイン者が選択されていない zkm end
    },
    /* add by chamaojia 2024-05-10 [10573] check whether the addition can be modified --start */
    isNotEdit() {
      const rstDialysisState = this.dataItem["rstDialysisState"];
      if (!rstDialysisState || rstDialysisState == "0") {
        return true;
      }
      return false;
    }
    /* add by chamaojia 2024-05-10 [10573] check whether the addition can be modified --end */
  },
  methods: {
    // del FNSI-画面パフォーマンス対応 付 start
    // ...mapActions("user-selector-popover", ["getMst"]),
    // del FNSI-画面パフォーマンス対応 付 end
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
    onClick() {
      this.$set(this.dataItem, "inEdit", this.field);
      this.$emit("editStart");
    },
    onChangePersonalUser(user) {
      this.selectValue = user ? user.id : -1;
      this.$emit(
        "changeStaff",
        null,
        this.dataItem,
        this.field,
        this.selectValue
      );
    },
    fetchPersonalUserAll() {
      return Promise.all([
        sendRequestGetMstPersonalUser(this.getFacilityCd),
        sendRequestMstGetJobs(this.getFacilityCd)
      ]);
    },
    handlePopoverVisibleChange(newVal) {
      const eventName = newVal ? "editStart" :"editEnd";
      this.$emit(eventName);
    }
  },
  mounted() {
    this.selectValue = this.dataItem[this.field];
  },
  // mod FNSI-画面パフォーマンス対応 付 start
  // async created() {
  //   await this.getMst();
  // }
  created() {}
  // mod FNSI-画面パフォーマンス対応 付 end
};
</script>

<style scoped>
.selector-cell-template >>> ons-button.select-btn {
  font-size: 1em;
}
</style>
