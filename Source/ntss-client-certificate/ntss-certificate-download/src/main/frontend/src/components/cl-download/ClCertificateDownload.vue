<template>
  <div class="cl-certificate-download-page">
    <!-- ダウンロードページのタイトル -->
    <div class="download-title">
      クライアント証明書ダウロード
    </div>
    <div class="main-container">
      <!-- コンテンツを中央に配置するための「フォームコンテナ」の使用 -->
      <div class="form-container">
        <!-- 設備名称 -->
        <div>
          <span>施設名</span>
          <span id="facility-name">{{ getFacilityName }}</span>
        </div>
        <!-- add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start -->
         <div>
          <span>施設ID</span>
          <span id="facility-id">{{ getUserId }}</span>
        </div>

        <div style="margin:0 auto;">
          <table style="margin:0 auto;">
            <thead>
            </thead>
            <tbody>
              <tr
                v-for="filter in getCerInfo"
                :key="filter.certificateCd"
                class="ntss-list-body-tr"
              >
                <td class="ntss-list-body-td"><input type="radio" name="certificateCd"  :value="filter.clCertificateId" @change="radioClick($event.target,filter.clCertificateId, filter.certificateCd)" /></td>
                <td class="ntss-list-body-td">{{ filter.certificateCd }}</td>
                <td class="ntss-list-body-td">{{ filter.certificateName }}</td>
                <td class="ntss-list-body-td" style="display: none">{{ filter.curDownload }}</td>
              </tr>
            </tbody>
          </table>
        </div>



        <!-- add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end -->
        <!-- mod FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start -->
        <div class="panel">
          <!-- ダウンロードボタン -->
          <!-- <v-ons-row>
            <v-ons-col>
              <div>
                <button
                  class="button download-btn"
                  ref="downloadBtn"
                  @click="download"
                  :disabled="isDisabled"
                >
                  証明書ダウンロード
                </button>
              </div>
            </v-ons-col>
          </v-ons-row> -->
           <v-ons-row>
             </v-ons-row>
          <v-ons-row>
            <v-ons-col>
              <div class="btn-group">
                <button
                  class="button action-btn"
                  ref="downloadBtn"
                  @click="download"
                >
                  証明書ダウンロード
                </button>
                <button
                  class="button action-btn"
                  @click="$router.push({ name: 'P12MergePage' })"
                >
                  証明書マージ
                </button>
              </div>
            </v-ons-col>
          </v-ons-row>
          <!-- mod FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end -->
          <!-- del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start -->
          <!-- ダウンロード数 -->
          <!-- <p>
            ダウロード回数 {{ currentDownloadNumber }}/{{ maxDownloadNumber }}
          </p> -->
          <!-- 証明書のリリース日 -->
          <!-- <p v-if="getFacility.expiredDate !== null">
            公開期限 <span>{{ expiredDate }}</span>
          </p> -->

          <!-- ログアウトボタン -->
          <!-- <v-ons-row>
            <v-ons-col>
              <button
                class="button"
                @click="userSignOut"
                :disabled="isAlerting"
              >
                ログアウト
              </button>
            </v-ons-col>
          </v-ons-row> -->
          <!-- del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end -->
        </div>
      </div>
    </div>
    <!-- ローディング画面 -->
    <loading-screen />
  </div>
</template>
<script>
import { mapActions, mapGetters } from "vuex";
import { downloadCertificate } from "@/apis/cl-details";
import loadingScreen from "@/components/common/LoadingScreen";
//import moment from "moment";
export default {
  mounted() {
    this.$nextTick(() => {
      this.radioTimeout = setTimeout(() => {
        let rdoObj = document.getElementsByName("certificateCd") ;
        if (rdoObj && rdoObj.length > 0) {
          rdoObj[0].click();
        }
      }, 200);
    });

  },
  data() {
    return {
      clCertificateId: '',
      certificateCd: '',
      isAlerting: false,
      radioTimeout: null
    };
  },
  computed: {

    //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
    //ダウンロードボタンを無効にする条件
    // isMax() {
    //   return this.getFacility.curDownload === this.getFacility.maxDownload;
    // },

    // isExpired() {
    //   let now = new Date();
    //   let date = new Date(this.getFacility.expiredDate);
    //   return now > date;
    // },

    // isDisabled() {
    //   return this.isMax || this.isExpired;
    // },

    // currentDownloadNumber() {
    //   if (this.getFacility.curDownload === null) {
    //     return 0;
    //   } else {
    //     return this.getFacility.curDownload;
    //   }
    // },

    // maxDownloadNumber() {
    //   if (this.getFacility.maxDownload === null) {
    //     return 0;
    //   } else {
    //     return this.getFacility.maxDownload;
    //   }
    // },
   //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
    ...mapGetters("user", {
      getUserId: "getUserId"
    }),

    ...mapGetters("cl-detail", {
      getFacility: "getFacility",
      getFacilityName: "getFacilityName",
      getCertificates: "getCertificates"
    }),
   //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
    // expiredDate() {
    //   if (this.getFacility.expiredDate === null) {
    //     return "";
    //   } else {
    //     return moment(this.getFacility.expiredDate).format("YYYY/MM/DD HH:mm");
    //   }
    // }

    getCerInfo() {
      let cerList = this.getCertificates.map(detail => {
        return {
          certificateCd: detail.manyFacilityCd,
          certificateName: detail.manyFacilityName,
          clCertificateId: detail.clCertificateId,
          maxDownload: detail.maxDownload,
          curDownload: detail.curDownload
        };
      });
      return cerList;
    }
  },
   //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
  components: {
    "loading-screen": loadingScreen
  },

  methods: {
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount: "resetLoadingScreenVisibleCount"
    }),

    ...mapActions("cl-detail", {
      updateCurDownload: "updateCurDownload",
      selectByFacilityCdWithName: "selectByFacilityCdWithName",
      selectCertificateByFacilityCd: "selectCertificateByFacilityCd",
      selectFacilityName: "selectFacilityName"
    }),

    ...mapActions("user", {
      signOut: "signOut"
    }),

    setFocus(ref) {
      this.$refs[ref].$el._input.focus();
    },

    //ログアウトしてログインページに戻る
    userSignOut() {
      this.signOut();
      this.$router.push({ name: "clDownloadLogin" });
    },

    //証明書をダウンロードする機能
    async download() {
      let isChecked = false;
      let radios = document.getElementsByName('certificateCd');
      for (let i = 0; i < radios.length; i++) {
        if (radios[i].checked) {
          isChecked = true;
          break;
        }
      }
      if (!isChecked) {
        const alert = {
          title: "証明書",
          message: "証明書が必須です。"
        };
        this.$ons.notification.alert(alert);
        return;
      }
      clearTimeout(this.radioTimeout);
      //オブジェクトをパラメーターとして渡す
      let facility = {
       //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
        clCertificateId: this.clCertificateId,
       //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
        facilityCd: this.getFacility.facilityCd,
        curDownload: this.getFacility.curDownload + 1,
        manyFacilityCd: this.certificateCd
      };
      this.setLoadingScreenVisible(true);
      //証明書をダウンロードする
      downloadCertificate(this.getUserId, facility)
        .then(() => {
              this.userSignOut();
              this.setLoadingScreenVisible(false);
        })
        .catch(() => {
          this.setLoadingScreenVisible(false);
          this.alert();
        });
    },

    alert() {
      if (!this.isAlerting) {
        // エラー保持状況フラグを更新
        this.isAlerting = true;
        this.$nextTick(() => {
          const alert = {
            title: "エラー",
            message: "ファイル認証局が見つかりません. ",
            callback: () => {
              this.isAlerting = false;
            }
          };
          this.$ons.notification.alert(alert);
        });
      }
    },

    radioClick(obj, id, certificateCd) {
      if (obj.checked == true) {
        this.clCertificateId = id;
        this.certificateCd = certificateCd;
      }
    },

  },
  created() {
    //施設コードによる施設の選択
    this.selectByFacilityCdWithName(this.getUserId);
    this.selectCertificateByFacilityCd(this.getUserId);
    this.selectFacilityName(this.getUserId);
  }
};
</script>
<style scoped>
* {
  box-sizing: border-box;
}
.cl-certificate-download-page {
  text-align: center;
  font-size: large;
  height: 100%;
  margin: 0px;
  width: 100%;
  box-shadow: none;
  border-radius: 0px;
  background-color: rgb(240, 242, 243);
  /* background-color: aqua; */
  overflow: hidden;
  padding: 16px;
}
.cl-certificate-download-page .panel {
  margin: 0 auto;
  width: 80%;
}
.download-title {
  padding: 80px 0px;
  width: 100%;
  height: 20%;
  float: left;
  font-size: 1.5em;
  font-weight: bold;
}
ons-col {
  width: inherit;
  margin: 10px;
}

ons-input {
  border: 0;
  padding: 0;
  color: #aaa;
  border: solid 1px #ccc;
  margin: 0;
  width: 100%;
  -webkit-border-radius: 5px;
  -moz-box-shadow: inset 0 0 4px rgba(0, 0, 0, 0.2);
  -moz-border-radius: 5px;
  -webkit-box-shadow: inset 0 0 4px rgba(0, 0, 0, 0.2);
  border-radius: 3px;
  box-shadow: inner 0 0 4px rgba(0, 0, 0, 0.2);
}
.p-error {
  text-align: center;
  color: red;
}
.error-link {
  text-align: center;
  display: block;
  font-size: x-small;
  margin: 20px 0px 0px 0px;
}
#facility-name {
  font-size: large;
  margin-left: 1vw;
}
/*  FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start */
#facility-id {
  font-size: large;
  margin-left: 1vw;
}
/* FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end */
/* FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start */
/*.button {
  margin: 0 0 10px 0;
}*/
.button {
  margin: 50px 0 10px 0;
}
/* FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end */
label {
  width: 50px;
}
.btn-group {
  display: inline-flex;
  flex-direction: column;
  gap: 10px;
  align-items: center;
}

.action-btn {
  width: 180px;
  margin: 0;
}
#clCertificateDownloadCol {
  text-align: end;
}
.error-message {
  margin: 10px;
}
.main-container {
  width: 100%;
  float: left;
/* FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start */
/*  height: auto;*/
/* FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end */}
.form-container {
  padding: 10px 0;
  background-color: white;
  width: 60%;
  margin: 0 auto;
  border-radius: 20px;
/* FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start */
  height: 50%;
/* FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end */
}
/*  FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start */
/*@media only screen and (max-width: 900px) {*/
  @media only screen and (max-width: 480px) {
  /*  FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start */
  .cl-certificate-download-page {
    padding: 0;
  }
 .download-title {
   padding: 20px 0;
   font-size: 1em;
   height: 20%;
 }
 .main-container {
   height: 80%;
   overflow: scroll;
 }
 .form-container {
   padding: 10px 0;
   background-color: white;
   width: 100%;
   margin: 0 auto;
   border-radius: 20px;

 }
}
</style>
