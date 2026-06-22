<template>
  <div>
    <div class="container" id="container" :height="containerHeight">
      <!-- ログインした名前を表示する -->
      <div class="user-name">
        <div class="user-name-text">{{ getUserName }}</div>
        <div class="label-user-name">ログイン名</div>
      </div>

      <div
        id="main-content-area-facility"
        class="main-content-area master-maintenance-page"
      >
        <div class="ntss-list">
          <kendo-grid-toolbar class="k-grid-toolbar kendo-grid-toolbar-style" :style="heightStyles" >
            <div class="header-btn-area">
              <label class="grid-align-default">【施設名】</label>
              <label class="grid-align-default">{{ facilityName }}</label>
              <label class="grid-align-default">【施設コード】</label>
              <label class="grid-align-default">{{ facilityCd }}</label>
            </div>
            <div class="grid-container">
              <kendo-grid
                ref="facilityGrid"
                id="facility-grid"
                :dataSource="DownloadList"
                :editable="true"
                :selectable="true"
                :reorderable="false"
                :height="kendoGridHeight"
                :scrollable="true"
                :resizable="true"
                :sortable="true"
              >
                <template v-for="(column, index) in certificateColumns" :key="index">
                  <kendo-grid-column
                    v-if="column.field === '$modalType'"
                    :title="column.title"
                    :field="column.field"
                    :hidden="column.hidden"
                    :locked="column.locked"
                    :editable="column.editable"
                    :width="column.width"
                    :format="column.format"
                    :values="column.values"
                    :sortable="column.sortable"
                    :template="column.template"
                    @editor="editorDropDown"

                  />
                  <kendo-grid-column
                    v-else
                    :title="column.title"
                    :field="column.field"
                    :hidden="column.hidden"
                    :locked="column.locked"
                    :editable="column.editable"
                    :width="column.width"
                    :format="column.format"
                    :values="column.values"
                    :sortable="column.sortable"
                  ></kendo-grid-column>
                </template>
              </kendo-grid>
            </div>
            <!-- 戻るボタン -->
            <div class="grid-footer">
              <v-ons-row width="100%">
                <v-ons-col width="100%">
                  <v-ons-button class="button denial-btn" @click="closeClDetails">戻る</v-ons-button>
                </v-ons-col>
              </v-ons-row>
            </div>
          </kendo-grid-toolbar>
        </div>
      </div>
    </div>

    <!-- ローディング画面 -->
    <loading-screen />
  </div>
</template>
<script>
import { mapGetters ,mapActions } from "vuex";
import $ from "jquery";
import { ApiHelper } from "@/apis/AxiosHelper";
import loadingScreen from "@/components/common/LoadingScreen";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
import moment from "moment";
export default {
   components: {
    "loading-screen": loadingScreen
  },
  created(){
     this.facilityCd = this.modalDetailsCondition.facilityCd ===""
                      ? sessionStorage.getItem('facilityCd')
                      : this.modalDetailsCondition.facilityCd;
     this.facilityName = this.modalDetailsCondition.facilityName ===""
                      ? sessionStorage.getItem('facilityName')
                      : this.modalDetailsCondition.facilityName;
     this.selectAllCertificatesByFacilityCd(this.facilityCd)
  },
  computed: {
  ...mapGetters("user", [
      "getUserName",
    ]),
  ...mapGetters("cl-detail", {
    modalDetailsCondition: "getModalDetailsCondition",
    clDownloadList: "getclDownloadList"}),
  ...mapGetters("user", [
      "isAdminUser"
    ]),

    containerHeight() {
      return { "--height": `${this.mainContainerHeight}px` };
    },


    heightStyles() {
          // main部の高さをCSS変数を利用して書き換え
          return { "--height": `${this.kendoGridToolbarHeight}px` };
        },
    ...mapGetters("window-size", {
          windowHeight: "getWindowHeight",
          windowWidth: "getWindowWidth"
        }),

   DownloadList() {

      let i = 1;
      let downloadList = this.clDownloadList.map(detail => {
        return {
          No: i++,
          curDownload: detail.curDownload,
          upDate: detail.isDelete === '0' ? (detail.upDate === null ? "" : moment(detail.upDate).format("YYYY/MM/DD HH:mm:ss")): "失効",
          facilityName: detail.manyFacilityName !== "" && detail.manyFacilityName !== null ? detail.manyFacilityName : this.facilityName,
          facilityCd: detail.facilityCd ,
          manyFacilityCd: detail.manyFacilityCd ,
          isDelete: detail.isDelete,
          clCertificateId: detail.clCertificateId
        };
      });
      sessionStorage.setItem("facilityCd", this.facilityCd);
      sessionStorage.setItem("facilityName", this.facilityName);
      return downloadList
    },
  },
  mounted() {
      this.calculateTableHeight();
      this.calculateMarginModalHeight();
    },

  data() {
    return {

      messageCd: 99999996,
      deletemessageCd: 99999995,
      facilityCd : "",
      facilityName : "",
      //施設テーブルの列
      certificateColumns: [
        {
          field: "No",
          title: "No",
          hidden: false,
          locked: false,
          editable: () => false,
          values: null,
          sortable: true,
          width: 5
        },
        {
          field: "curDownload",
          title: "ダウロード数",
          hidden: false,
          locked: false,
          editable: () => false,
          values: null,
          sortable: true,
          width: 10
        },
        {
          field: "upDate",
          title: "最終ダウンロード日時",
          hidden: false,
          locked: false,
          editable: () => false,
          values: null,
          sortable: true,
          width: 20
        },
        {
          field: "facilityName",
          title: "証明書許可施設",
          hidden: false,
          locked: false,
          editable: () => false,
          values: null,
          sortable: true,
          width: 50
        },
        {
          field: "facilityCd",
          title: "",
          hidden: true,
          locked: false,
          editable: () => false,
          values: null,
          sortable: true
        },
        {
          field: "isDelete",
          title: "",
          hidden: true,
          locked: false,
          editable: () => false,
          values: null,
          sortable: true
        },
        {
          field: "$modalType",
          title: " ",
          hidden: false,
          locked: false,
          editable: () => true,
          values: null,
          sortable: false,
          width: 10,
          template: (dataItem) => {
            if (!this.isAdminUser || dataItem.isDelete ==="1") {
              return ''
            }
            return `<span style='color:rgb(69,173,278)'>操作<i class='fas fa-caret-down'></i></span>`
          }
        },
        {
          field: "clCertificateId",
          title: "7777",
          hidden: true,
          locked: false,
          editable: () => false,
          values: null,
          sortable: false
        },
        {
          field: "manyFacilityCd",
          title: "",
          hidden: true,
          locked: false,
          editable: () => false,
          values: null,
          sortable: false
        }

      ],
      //データ
      dropDownDataSource: ["失効"],

      kendoGridToolbarHeight: 400,
      kendoGridHeight: 400,
      mainContainerHeight: 0,
      modalMargin: 100
    }
  },
  watch: {
      windowHeight() {
        this.calculateTableHeight();
        this.calculateMarginModalHeight();
      },
      windowWidth() {
        this.calculateTableHeight();
        this.calculateMarginModalHeight();
      }
    },
  methods : {
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount: "resetLoadingScreenVisibleCount"
    }),
    ...mapActions("cl-detail", {
      selectAllCertificatesByFacilityCd: "selectAllCertificatesByFacilityCd"
    }),
     ...mapActions("cl-detail", {
      setModalDetails: "setModalDetailsCondition"
    }),
    calculateTableHeight() {
          let tabstripHeight = document.getElementsByClassName(
            "user-name"
          )[0].scrollHeight;
          let headerBtnArea = document.getElementsByClassName("header-btn-area")[0]
            .scrollHeight;
          let gridFooter = document.getElementsByClassName("grid-footer")[0]
            .scrollHeight;
          let kPaperWrap = document.getElementsByClassName("grid-footer")[0]
            .scrollHeight + 30;

          let subElementHeight =
            tabstripHeight + headerBtnArea + gridFooter + kPaperWrap ;
          let tableHeight = this.windowHeight - subElementHeight;
          this.kendoGridToolbarHeight = tableHeight + kPaperWrap;
          this.kendoGridHeight = tableHeight;
        },
        calculateMarginModalHeight() {
          let tabstripHeight = document.getElementsByClassName("modal-common");
          Array.from(tabstripHeight)?.forEach(item => {
            if (item.scrollHeight != 0) {
              let margin = (this.windowHeight - item.scrollHeight) / 2;
              if (this.windowHeight <= item.scrollHeight) {
                this.modalMargin = 0;
              } else if (item.scrollHeight != 0) {
                this.modalMargin = margin;
              }
            }
          });
        },

    //列をクリックしたときにドロップダウンリストを表示
    editorDropDown(container, data) {
      //失効」は、ユーザ権限が「管理者」の場合に表示される。一般ユーザは非活性とする。
      if (!this.isAdminUser || data.model.isDelete ==="1" ) {
        return
      }
      $(`<input class="k-textbox" name="${data.field}"/>`)
        .appendTo(container)
        .kendoDropDownList({
          dataSource: this.dropDownDataSource,
          optionLabel: "操作",
          change: () => {
            let val = data.model[data.field];
            if (val === "失効") {
              this.$ons.notification.confirm({
              title: "",
              message: DIALOG_MESSAGES[this.messageCd].replace(/{\$\d*}/, data.model.facilityName) ,
              callback: answer => {
                if (answer === 1) {
                  this.certificateDelete(data.model.facilityCd, data.model.manyFacilityCd, data.model.clCertificateId);
                  }
                }
              })
            }
            data.model[data.field] = "操作";
          },
          open: () => {
            $(".k-list-optionlabel").hide();
          }
        });
    },

    async certificateDelete( facilityCd, manyFacilityCd, clCertificateId ) {
      //CL証明書と施設を削除しました。
      this.setLoadingScreenMessage("処理中・・・");
      this.setLoadingScreenVisible(true);
      try {
        let obj = {
          facilityCd: facilityCd,
          manyFacilityCd: manyFacilityCd,
          clCertificateId: clCertificateId
        };
        await ApiHelper.post("/cl-details/deleteCl", obj);
        await this.selectAllCertificatesByFacilityCd(this.facilityCd);
        this.resetLoadingScreenVisibleCount();
      } catch {
        this.setLoadingScreenVisible(false);
        this.$ons.notification.alert({
          title: "",
          message: DIALOG_MESSAGES[this.deletemessageCd]
        });
      }
   },
   //戻るボタン
   closeClDetails() {
     //施設でsessionStorageを削除する。
    sessionStorage.removeItem("facilityCd", this.facilityCd);
    sessionStorage.removeItem("facilityName", this.facilityName);
    //施設一覧を戻る。
    // add #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen start
    // this.$router.push({ name: "clManagementView" });
    // this.$router.push({
    //   name: "clManagementView",
    //   params: {
    //     page: this.$route.params.page || 1,
    //     sort: this.$route.params.sort || null
    //   }
    // });
    this.$router.push({
  name: "clManagementView",
  query: {
    page: this.$route.query.page || 1,
    sort: this.$route.query.sort || null
  }
});

    // add #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen end
  }
  },
}

</script>
<style scoped>
#app > div {
  background-color: rgb(232, 247, 251);
  width: 100%;
  height: 100%;
}
.container {
  width: 100%;
  height: 100vh;
  max-height: 100vh;
  overflow-y: scroll;
  overflow-x: hidden;
}
.user-name {
  z-index: 1;
  font-size: 1.5em;
  font-weight: bold;
  width: 100%;
  text-align: right;
  height: 4em;
  line-height: 2.5em;
}

.user-name-text {
  width: auto;
  float: right;
  margin-right: 4vw;
}
.label-user-name {
  width: auto;
  float: right;
  padding-right: 5px;
}
.user-name p {
  margin-right: 100px;
}

#facility-grid td {
  overflow: visible;
}

.main-content-area {
  position: relative;
  z-index: 0;
  width: 99%;
  margin-left: 1%;
  overflow-y: unset;
  height: auto;
}
.right {
  text-align: right;
}
.header-btn-area {
  height: auto;
  padding: 0.1em 0.1em 0.1em 0.1em;
}
.grid-footer {
  padding: 5px 5px 0px 5px;
  margin-top: 1.5em;
  width: inherit;
  font-size: 0.7em;
}
.kendo-grid-toolbar-style {
  height: 200px;
  border-bottom: none;
}
.toolbar-btn {
  font-size: 1em;
  padding: 0.2em 1em 0em 1em;
  line-height: 2em;
  width: auto;
}
.k-grid-toolbar {
  padding: 1.5em 0.3em;
}
.kendo-grid-toolbar-style :deep(.k-tooltip.k-tooltip-validation) {
  width: auto;
}
.btn-kendo {
  background: black;
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
.k-grid-toolbar :deep(* + *) {
  margin-left: 0;
}

/*add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start*/
.grid-align-default {
  padding: 0.3em 0.3em 0.3em 0.3em;
  font-size: 1.2em;
}
/*add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end*/
@media only screen and (max-width: 900px) {

  .cl-add-page {
    padding: 0;
  }
  .main-content-area {
    position: relative;
    z-index: 0;
    width: 100%;
    margin-left: 1%;
    overflow-y: unset;
  }
  .container {
    width: 100%;
    height: 80vh;
    min-height: 100vh;
    overflow-y: scroll;
    overflow-x: hidden;
  }
   .grid-container {
    overflow: auto;
  }
  #facility-grid {
    width: 1600px;
  }
  #user-grid {
    width: 1600px;
  }

  #facility-grid :deep(.k-auto-scrollable) {
    width: auto;
  }
}


</style>
