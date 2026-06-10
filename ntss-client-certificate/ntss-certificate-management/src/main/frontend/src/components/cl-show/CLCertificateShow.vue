<template>
  <div class="facility-add-page">
    <div class="panel">
    <div class="container" >
      <table>
        <tr>
          <td><div class="label-user-name width: 200px;">ダウンロードサイトURL：</div></td>
          <td><div class="user-name-text width: 300px;">{{ getDownloadServerPath }}</div></td>
        </tr>
        <tr>
          <td><div class="label-user-name width: 50px">発行者：</div></td>
          <td><div class="user-name-text width: 100px">{{ getUserName }}</div></td>
        </tr>
        <tr>
          <td><div class="label-user-name width: 50px">発行日時：</div></td>
          <td><div class="user-name-text width: 100px">{{ Clfalicitylist.issueDate }}</div></td>
        </tr>
      </table>
    </div>
    <br><br><br>
    <!-- mod #6794 dengshen start -->
    <!-- <div class="" style="width:100%; height:10vh; display:flex; flex-direction: column" > -->
    <div class="" style="width:100%; height:10vh; display:flex; flex-direction: column; min-height:75px" >
    <!-- mod #6794 dengshen end -->
      <div style="display: flex;">
        <!-- mod #6794 dengshen start -->
        <!-- <div style="flex:1.5;" class="label_facilityName"> -->
        <div style="min-width:98px;flex:1.5;" class="label_facilityName">
        <!-- mod #6794 dengshen end -->
          施設名
        </div>
        <!-- mod #6794 dengshen start -->
        <!-- <div style="flex:1;" class="label_facilityId"> -->
        <div style="min-width:65px;flex:1;" class="label_facilityId">
        <!-- mod #6794 dengshen end -->
          施設ID
        </div>
        <!-- mod #6794 dengshen start -->
        <!-- <div style="flex:1;" class="label_facilityId"> -->
        <div style="min-width:87px;flex:1;" class="label_facilityId">
        <!-- mod #6794 dengshen end -->
          施設PW
        </div>
        <!-- mod #6794 dengshen start -->
        <!-- <div style="flex:1;" class="label_facilityId"> -->
        <div style="min-width:88px;flex:1;" class="label_facilityId">
        <!-- mod #6794 dengshen end -->
          証明書PW
        </div>
        <!-- mod #6794 dengshen start -->
        <!-- <div style="flex:1;" class="label_facilityId"> -->
        <div style="min-width:80px;flex:1;" class="label_facilityId">
        <!-- mod #6794 dengshen end -->
          URL
        </div>
      </div>
      <div style="display: flex;">
        <div style="flex:1.5"  class="txt_facilityName">
          {{ Clfalicitylist.facilityName }}
        </div>
        <div style="flex:1" class="txt_facilityId">
          {{ Clfalicitylist.facilityCd }}
        </div>
        <div style="flex:1" class="txt_facilityId">
          {{ Clfalicitylist.facilityPassword }}
        </div>
        <div style="flex:1" class="txt_facilityId">
          {{ Clfalicitylist.passwordCl }}
        </div>
        <div style="flex:1" class="txt_facilityId">
          <kendo-qrcode :value="txtUrl" :size =80 :encoding="'UTF_8'" ></kendo-qrcode>
        </div>
      </div>
    </div>
      <!-- ログアウトボタン -->
      <div class="grid-footer">
        <v-ons-row width="100%">
          <v-ons-col width="100%">
            <v-ons-button id="closebtn" class="button denial-btn" @click="closeCertificate">閉じる</v-ons-button>
          </v-ons-col>
        </v-ons-row>
      </div>
    </div>
    <!-- ローディングコンポーネント -->
    <loading-screen />
  </div>
</template>
<script>
import { mapGetters ,mapActions } from "vuex";

export default {
  computed: {
   ...mapGetters("user", [
      "getUserName",
    ]),
    ...mapGetters("cl-detail", {
      Clfalicitylist: "getClfalicitylist",
      // add 4448修正 解 start
      getDownloadServerPath: "getDownloadServerPath"
      // add 4448修正 解 end
    }),
    txtUrl() {
      // ログインページURLを返却
      // add 4448修正 解 start
      //return 'https://cl.nksfn.com/download/#/?key='+this.Clfalicitylist.facilityCd;
      return this.getDownloadServerPath + '#/?key='+this.Clfalicitylist.facilityCd;
      // add 4448修正 解 start
    },
  },
  methods : {
    ...mapActions("cl-detail", {
      refeshCertificate: "refeshCertificate",
     }),

    closeCertificate(){
        this.refeshCertificate()
    },

  },
}
</script>
<style scoped>
.user-name-text {
  float: left;
  margin-left: 10px;
  font-size:2em;;
}
.label-user-name {
  float: left;
  font-size:2em;;
  margin-left: 10px;
}
 .label_facilityName {
  box-sizing: border-box;
  font-size: 1.5em;
  margin-left: 2px;
  border: 1em;
  background-color: rgb(100, 100, 100);
  /* del #6794 dengshen start */
  /* width: 250px; */
  /* del #6794 dengshen end */
  height: 60px;
  text-align:left
}
 .label_facilityId {
  box-sizing: border-box;
  font-size: 1.5em;
  margin-left: 2px;
  border: 1em;
  background-color: rgb(100, 100, 100);
  /* del #6794 dengshen start */
  /* width: 150px; */
  /* del #6794 dengshen end */
  height: 60px;
  text-align:left
}
.txt_facilityName {
  box-sizing: border-box;
  font-size: 1.5em;
  margin-left: 2px;
  border: 1em;
  background-color: rgb(214, 212, 212);
  /* mod #6794 dengshen start */
  /* width: 250px; */
  /* height: 120px; */
  height: 100px;
  /* mod #6794 dengshen end */
  text-align:left
}
 .txt_facilityId {
  box-sizing: border-box;
  font-size: 1.5em;
  margin-left: 2px;
  border: 1em;
  background-color: rgb(214, 212, 212);
  /* mod #6794 dengshen start */
  /* width: 150px; */
  /* height: 120px; */
  height: 100px;
  /* mod #6794 dengshen end */
  text-align:left
}
.txt_url {
  padding: 10px 10px 10px 10px;
}
.container {
  width: 100%;
  /* mod #6794 dengshen start */
  /* height: 10vh; */
  height: 20vh;
  min-height: 145px;
  /* mod #6794 dengshen end */
}
.facility-add-page {
  text-align: center;
  font-size: 10.5px;
  margin: 0px;
  background-color: rgb(240, 242, 243);
  box-shadow: none;
  border-radius: 10px;
  padding: 16px;
  height: 50vh;
  /* add #6794 dengshen start */
  min-height: 380px;
  /* add #6794 dengshen end */
}
.facility-add-page .panel {
  text-align: left;
  margin: 0 auto;
  width: 100%;
}

.grid-footer {
  padding: 5px 5px 0px 5px;
  /* mod #6794 dengshen start */
  /* margin-top: 12.5em; */
  margin-top: 8em;
  /* mod #6794 dengshen end */
  width: inherit;
  font-size: 1em;
}

.denial-btn {
  margin-right: 4vw;
  width: 150px;
  height: 35px;
  font-size: 1.5em;
  line-height: 35px;
  float: right;
  border-radius: 5px;
}

@media print {
  #closebtn {
    display:none !important;
  }
}
</style>
