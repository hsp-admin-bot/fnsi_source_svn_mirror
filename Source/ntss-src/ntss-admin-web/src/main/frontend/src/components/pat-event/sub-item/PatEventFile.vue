<template>
  <div class="vertical-div">
    <!--mod FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 start-->
    <!--<div class="disp-item-area">
      <div>-->
    <!--<div class="disp-item-area" style="display: flex;width: 180px">-->
      <!--<div class="topTitle">
        <div class="borderRight">
          &lt;!&ndash;mod FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 end&ndash;&gt;
          <label class="title ntss-pat-event-label">{{getTemplateFieldName}}&emsp;</label>
          &lt;!&ndash;add FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 start&ndash;&gt;
        </div>
        &lt;!&ndash;add FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 end&ndash;&gt;
      </div>-->

    <div class="borderRight">
      <div class="disp-item-area topTitle">
        <label class="title ntss-pat-event-label">{{getTemplateFieldName}}&emsp;</label>
      </div>
    </div>
    <div class="rightLine">
      <div class="file-area">
        <!--#9937:患者イベント画面を開くと添付ファイルのフィールドがなくなる。Start -->
        <!--患者イベントの編集モード又は患者イベント以外はアップロード表示 -->
        <!-- mod #10359 編集権限の動作不正 start -->
        <!-- <file-uploader
          v-if="
            this.getShowFile || this.$route.name !== 'pat-event'
          "
          ref="fileUploader"
          v-model="file_info"
          v-model:is-loading-bbs="isLoadingBbs"
          :index="index"
          @deleteFile="deleteFile"
        />   -->
        <file-uploader
          v-if="
            this.getShowFile || this.$route.name !== 'pat-event'
          "
          ref="fileUploader"
          v-model="file_info"
          v-model:is-loading-bbs="isLoadingBbs"
          :key="'uploader-' + index"
          :index="index"
          :disabled="
            !getItemAuthorized('PatEvent', 'default_authority') ||
            getIsOtherFacility ||
            getIsOtherFacilitys
          "
          @deleteFile="deleteFile"
        />
        <!-- mod #10359 編集権限の動作不正 end -->
        <!--#9937:患者イベント画面を開くと添付ファイルのフィールドがなくなる。End -->
        <!--mod FNSI-改修内容添付ファイル修正 任 end-->
        <!-- mod #10359 編集権限の動作不正 start -->
        <!-- <file-downloader ref="fileDownloader" v-model="file_info" :index="index" /> -->
        <file-downloader
          ref="fileDownloader"
          v-model="file_info"
          :disabled="
            !getItemAuthorized('PatEvent', 'default_authority')
          "
          :key="'downloader-' + index"
          :index="index"
        />
        <!-- mod #10359 編集権限の動作不正 end -->
      </div>
      <!--mod FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 end-->
    </div>
      <!--add FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 start-->
     <!-- <div class="rightLine">
        &lt;!&ndash;add FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 end&ndash;&gt;
        <div class="file-area">
          &lt;!&ndash;mod FNSI-改修内容添付ファイル修正 任 start&ndash;&gt;
          &lt;!&ndash;<file-uploader
            ref="fileUploader"
            v-model="file_info"
            v-model:is-loading-bbs="isLoadingBbs"
            :index="index"
            @deleteFile="deleteFile"
          />&ndash;&gt;
          <file-uploader
            v-if="this.getShowFile"
            ref="fileUploader"
            v-model="file_info"
            v-model:is-loading-bbs="isLoadingBbs"
            :index="index"
            @deleteFile="deleteFile"
          />
          &lt;!&ndash;mod FNSI-改修内容添付ファイル修正 任 end&ndash;&gt;
          <file-downloader ref="fileDownloader" v-model="file_info" :index="index" />
          &lt;!&ndash;add FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 start&ndash;&gt;
        </div>
        &lt;!&ndash;add FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 end&ndash;&gt;
      </div>-->
    <!--</div>-->
  </div>
</template>

<script>
  import {mapActions, mapGetters} from "@/compat/vue/vuex";
  import FileUploader from "@/components/pat-event/sub-item/PatEventFileUploader";
  import FileDownloader from "@/components/pat-event/sub-item/PatEventFileDownloader";
// add #10359 編集権限の動作不正 start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 end

  export default {
    name: "PatEventFile",
    props: ["propsIndex"],
    components: {
      FileUploader,
      FileDownloader
    },
    data() {
      return {
        inputModel: {
          scoreName: ""
        },
        isLoadingBbs: false,
        file_info: [],
        index: 0
      };
    },

    computed: {
      ...mapGetters("user", { facilityCd: "getFacilityCd" }),
      ...mapGetters("account-edit", ["getStateUserAccountInfo"]),
      ...mapGetters("pat-event/detail", [
        "getPatEventInputParams",
        "getPatEventResultParams",
        "getPatEventRecord",
        "getPatEventRegStaffInfo",
        /*add FNSI-改修内容添付ファイル修正 任 start*/
        "getShowFile",
        /*add FNSI-改修内容添付ファイル修正 任 end*/
        "getPatEventUpStaffInfo"
      ]),
      ...mapGetters("pat-event/list", ["getIsOtherFacility"]),
      ...mapGetters("observe-record/list", ["getIsOtherFacilitys"]),
      getTemplateMaxSize() {
        return this.getPatEventInputParams[this.propsIndex].item_json.max_size;
      },
      getTemplateFieldName() {
        const flag = this.getPatEventInputParams[this.propsIndex]
          .is_field_display;
        if (flag === "1") {
          return this.getPatEventInputParams[this.propsIndex].field_name;
        } else {
          return "";
        }
      },
      getResultSelectFileInfo() {
        return this.getPatEventResultParams[this.propsIndex].result_value;
      }
    },
    beforeUnmount() {
      // dataの初期化
      Object.assign(this.$data, this.$options.data());
    },

    mounted() {
      this.initFile();
      this.index = this.propsIndex;
    },
    methods: {
      ...mapActions("pat-event/detail", [
        "setPatEventResultParamsUpdate",
        "setPatEventRecord"
      ]),
      initFile() {
        this.file_info = this.getResultSelectFileInfo;
      },
      /**
       * ファイルの削除対象リスト作成
       */
      deleteFile(deleteList) {
        deleteList.forEach(file =>
          this.$refs.fileDownloader.checkForDeletedFiles(file)
        );
      },
      // add #10359 編集権限の動作不正 start
      getItemAuthorized(pageCd, itemCd) {
        return getAuthorized(pageCd, itemCd);
      },
      // add #10359 編集権限の動作不正 end
      /**
       * アップロード対象ファイルの存在チェック処理
       */
      async uploadFileExistsCheck() {
        return await this.$refs.fileUploader?.fileExistsCheck();
      },
      /**
       * ファイルのS3削除処理
       */
      async deleteS3File() {
        const deleteFileInfo = this.file_info;
        if (deleteFileInfo.length !== 0) {
          // 画面に表示されているファイルを削除するためのリスト作成
          deleteFileInfo.forEach(file =>
            this.$refs.fileDownloader.checkForDeletedFiles(file)
          );
        }
        const patId = this.getPatEventRecord.patId;
        // サーバよりファイルを削除
        return await this.$refs.fileDownloader.deleteFile(patId);
      },
      async uploadS3File() {
        const patId = this.getPatEventRecord.patId;
        // サーバよりファイルを削除
        const ret = await this.$refs.fileDownloader.deleteFile(patId);
        if (ret) {
          // 今回、追加したファイルのアップロード
          //upd #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc start
          return await this.$refs.fileUploader?.upload({
          //upd #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc end
            facilityCd: this.facilityCd,
            patId: patId
          });
        }
        return false;
      },
      async uploadS3List() {
        //upd #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc start
        return await this.$refs.fileUploader?.getFileList();
        //upd #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc end
      }
    }
  };
</script>

<style scoped>
  .vertical-div {
    display: flex;
    /*add FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 start*/
    border-bottom: #595959 solid 1.5px;
    /*add FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 end*/
  }
  .disp-item-area {
    /*width: 100%;*/
    border-collapse: collapse;
  }
  .disp-item-area tr {
    height: 50px;
  }
  .disp-item-area tr th {
    text-align: left;
  }
  .disp-item-area tr th:first-child,
  .disp-item-area tr th:nth-child(2) {
    width: 30%;
  }
  .disp-item-area tr td:first-child,
  .disp-item-area tr td:nth-child(2),
  .disp-item-area tr td:nth-child(3) {
    text-align: left;
  }
  .onscol {
    padding-top: 10px;
  }
  .title {
    margin-left: 10px;
    margin-top: 10px;
    overflow: hidden;
    word-spacing: normal;
    word-break: break-all;
  }
  .file-area {
    margin-left: 10px;
    margin-top: 10px;
    /*add FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 start*/
    margin-bottom: 10px;
  }
  .topTitle {
    margin-bottom: 10px;
    /*white-space: nowrap;*/
    /*border-right: #595959 solid 1px;*/
    display: flex;
    align-items: center;
  }
  .rightLine {
    /*width: 100%;*/
    width: 75%;
    margin-bottom: 10px;
    /*add FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 end*/
  }
  .borderRight {
    margin-bottom: 10px;
    width: calc(100% / 4);
  }
</style>
