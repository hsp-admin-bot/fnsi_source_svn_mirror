<template>
  <!-- #10410 指示単位の指示受け・指示承認から指示受けor指示承認へ画面が開かない linjunfeng start -->
  <!-- <table class="indication-detail-type" cellspacing="0">
    <tr>
      <td>{{ userFullName }}</td> -->
  <div class="indication-detail-type">
    <div>{{ userFullName }}</div>
  <!-- #10410 指示単位の指示受け・指示承認から指示受けor指示承認へ画面が開かない linjunfeng end -->  
    <!-- mod 改行されている 修正 陳 start-->
    <!-- <td>-->
    <!-- #10410 指示単位の指示受け・指示承認から指示受けor指示承認へ画面が開かない linjunfeng start -->
    <!-- <td style="width: 60px;"> -->
    <div style="width: 60px;">
    <!-- #10410 指示単位の指示受け・指示承認から指示受けor指示承認へ画面が開かない linjunfeng end -->
    <!-- mod 改行されている 修正 陳 end-->
      <!--            mod    FNSI-権限 陳 start-->
      <!-- mod #10359 編集権限の動作不正 dengshen start -->
      <!-- <button class="button btn1-execute" @click="updateDetails" :disabled="!hasIndReceiveAuthority"> -->
      <button class="button btn1-execute" @click="updateDetails" :disabled="!getItemAuthorized('IndicationList', 'default_authority')">
      <!-- mod #10359 編集権限の動作不正 dengshenend -->
<!--          <button class="button" @click="updateDetails">-->
        <!--            mod    FNSI-権限 陳 end-->
        <img :src="okIcon" class="ok-icon" alt="ok icon" />
      </button>
    <!-- #10410 指示単位の指示受け・指示承認から指示受けor指示承認へ画面が開かない linjunfeng start -->  
    <!-- </td>
    </tr>
  </table> -->
    </div>
  </div>
  <!-- #10410 指示単位の指示受け・指示承認から指示受けor指示承認へ画面が開かない linjunfeng end -->
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
export default {
  name: "IndicationDetailButtonsComponent",
  mounted() {
    const indicationType = this.templateArgs.indicationType;
    const parentComponent = this.templateArgs.parentComponent;
    let list = parentComponent.mstPersonalUser;
// add  FNSI-権限 陳 start
    this.hasIndReceiveAuthority = parentComponent.hasIndReceiveAuthority;
// add  FNSI-権限 陳 end

    list.forEach(detail => {
      if (
        Number(this.templateArgs.item[indicationType]) === Number(detail.userId)
      ) {
        this.userFullName = detail.userFullName;
      }
    });
  },
  methods: {
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
    updateDetails: function() {
      this.templateArgs.parentComponent.onClickUpdateDetails(
        this.templateArgs.item,
        this.templateArgs.indicationType
      );
    }
  },
  data() {
    return {
      templateArgs: {},
      userFullName: "",
// add  FNSI-権限 陳 start
      hasIndReceiveAuthority: "",
// add  FNSI-権限 陳 end
      okIcon: require("../../assets/ok.png")
    };
  }
};
</script>

<style scoped>
.indication-detail-type {
  width: 100%;
  background: none;
  border-right: none !important;
  /* #10410 指示単位の指示受け・指示承認から指示受けor指示承認へ画面が開かない linjunfeng start */
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  /* #10410 指示単位の指示受け・指示承認から指示受けor指示承認へ画面が開かない linjunfeng end */
}
/* #10410 指示単位の指示受け・指示承認から指示受けor指示承認へ画面が開かない linjunfeng start */
/* .indication-detail-type tr {
  background: transparent !important;
}
.indication-detail-type td {
  border: 0;
  padding: 0 !important;
  background: none;
} */
.indication-detail-type div {
  border: 0;
  padding: 0 !important;
  background: transparent !important;
  align-self: center;
}
/* #10410 指示単位の指示受け・指示承認から指示受けor指示承認へ画面が開かない linjunfeng end */
.indication-detail-type .button {
  padding: 5px;
  float: right;
  height: 2.2em;
}
.ok-icon {
  width: 1.5em;
}
</style>
