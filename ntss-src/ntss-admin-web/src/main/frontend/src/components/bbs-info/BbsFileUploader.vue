<template>
  <div v-if="isRegFuncClass">
    <div class="dropzone-container" @click="dropzoneClick">
      <div class="dropzone-custom-title ntss-pat-event-label">ここにファイルをドロップ</div>
      <div class="dropzone-custom-subtitle ntss-pat-event-label">
        またはクリックしてファイルを選択
      </div>
    </div>
    <!-- #10977 インジェクション対応 linjunfeng start -->
    <!-- <kendo-upload
      ref="upload"
      name="files"
      v-bind="kendoUploadOptions"
      :disabled="!isRegFuncClass"
      @select="
        addFile($event);
        addThumbnailToImages($event);
      "
      @remove="removeFile"
      @upload="addCsrfTokenToRequestHeader"
      @success="onSuccess"
      @error="onError"
    /> -->
    <kendo-upload
      ref="upload"
      name="files"
      v-bind="kendoUploadOptions"
      :disabled="!isRegFuncClass"
      @select="
        addFile($event);
      "
      @remove="removeFile"
      @upload="addCsrfTokenToRequestHeader"
      @success="onSuccess"
      @error="onError"
    />
    <!-- #10977 インジェクション対応 linjunfeng end -->
    <!--mod #10894 患者イベントレイアウトマスタのファイル貼付サイズ上限がFNWより小さい 張玲 start-->
    <!-- <message-dialog
      :visible.sync="isDialogVisible"
      :message-cd="messageCd"
      :type="dialogType"
      @confirm="confirm"
    /> -->
    <message-dialog
      :visible.sync="isDialogVisible"
      :message-cd="messageCd"
      :type="dialogType"
      :title="title"
      @confirm="confirm"
    />
    <!--mod #10894 患者イベントレイアウトマスタのファイル貼付サイズ上限がFNWより小さい 張玲 end-->

  </div>
</template>

<script>
import { mapGetters, mapActions } from "vuex";
// 共通カレンダーコンポーネント
import messageDialog from "@/components/common/message-dialog/MessageDialog";
//add #10894 患者イベントレイアウトマスタのファイル貼付サイズ上限がFNWより小さい 張玲 start
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
const MAX_SIZE = '20480'
//add #10894 患者イベントレイアウトマスタのファイル貼付サイズ上限がFNWより小さい 張玲 end


export default {
  components: {
    "message-dialog": messageDialog
  },

  props: {
    value: {
      type: Array,
      required: true,
      default() {
        return [];
      }
    },

    isLoadingBbs: {
      type: Boolean,
      required: true,
      default: false
    }
  },

  data() {
    return {
      kendoUploadOptions: {
        async: {
          // 同期アップロードを使用しない(ファイルを選択後、アップロードはしない)
          autoUpload: false,
          // 保存先のURL
          saveUrl: "api/bbsInfo/files"
        },
        // アップロードするファイルの一覧を表示
        showFileList: false,
        // ドラッグアンドドロップ可能DOMオブジェクトのクラス名
        dropZone: ".dropzone-container",
        localization: {
          select: "ファイルを選択",
          headerStatusUploading: "アップロード中",
          headerStatusUploaded: "アップロード完了",
          statusUploading: "アップロード中",
          clearSelectedFiles: "クリア",
          uploadSelectedFiles: "アップロード"
        }
      },
      isDialogVisible: false,
      messageCd: null,
      dialogType: null,
      addFileEvent: null,
      isConfirm: true,
      deleteFileList: [],
      isUploaded: false,

      // 保存先掲示板管理番号
      bbsCtlNo: null,
      isUpdated: false,
      //add #10894 患者イベントレイアウトマスタのファイル貼付サイズ上限がFNWより小さい 張玲 start
      title: null,
      //add #10894 患者イベントレイアウトマスタのファイル貼付サイズ上限がFNWより小さい 張玲 end
      payload: [],
    };
  },

  computed: {
   ...mapGetters("bbs-info", [
      "selectedBbs",
    ]),
    fileInfo() {
      const deleteNameList = this.deleteFileList.map(file => file.name);
      const file = this.value.filter(
        file => !deleteNameList.includes(file.name)
      );

      return file;
    },

    isRegFuncClass(){
      if(this.selectedBbs.reg_func_class === 1){
        return false;
      }
      return true;
    },
  },

  methods: {
    ...mapActions("bbs-info", ["setSelectedBbsInfo"]),

    /**
     * @description ドラッグアンドドロップエリアをクリックする時のコールバック
     * @summary 呼び出してからファイル選択ダイアログを表示
     */
    dropzoneClick() {
      this.$refs.upload.kendoWidget().element.click();
    },

    /**
     * @description ファイル選択後コールバック
     * @param {Object} e kendoイベント
     * @see {@link https://docs.telerik.com/kendo-ui/api/javascript/ui/upload/events/select}
     */
    addFile(e) {
      if (this.hasSameRecord(e.files) && this.isConfirm) {
        // ファイル名重複あり
        this.addFileEvent = e;

        this.messageCd = 72000002;
        this.dialogType = "2";
        this.isDialogVisible = true;
        return;
      }
      //add #10894 患者イベントレイアウトマスタのファイル貼付サイズ上限がFNWより小さい 張玲 start
      for(const file of e.files){
        if(file.size > MAX_SIZE * 1024){
          // ファイルサイズオーバー
          this.addFileEvent = e;
          this.messageCd = 72000004;
          this.dialogType = "1";
          this.title = DIALOG_MESSAGES[72000004].title;
          this.isDialogVisible = true;
          return;
        }
        const raw = file.rawFile;
        this.payload.push(raw);
      }
      //add #10894 患者イベントレイアウトマスタのファイル貼付サイズ上限がFNWより小さい 張玲 end

      const fileInfo = [
        ...this.fileInfo,
        ...e.files.map(i => ({ name: i.name, path: null }))
      ];

      this.$emit("input", fileInfo);
      this.deleteFileList = [];
    },

    /**
     * @description ファイル削除後コールバック
     * @param {Object} e kendoイベント
     * @see {@link https://docs.telerik.com/kendo-ui/api/javascript/ui/upload/events/remove}
     */
    removeFile(e) {
      const files = e.files.map(i => i.name);
      const fileInfo = this.value.filter(i => !files.includes(i.name));
      this.$emit("input", fileInfo);
    },

    /**
     * @description ファイルをアップロード
     */
    upload(bbsInfo) {
      this.bbsCtlNo = bbsInfo.bbs_ctl_no;
      const bbs = `${bbsInfo.facility_cd}&${bbsInfo.bbs_ctl_no}`;

      // 保存先のURL
      const saveUrl = `api/bbsInfo/files/${bbs}`;
      this.$refs.upload.$_upload.options.async.saveUrl = saveUrl;

      if(this.fileInfo.length === 0) {
        bbsInfo.file_info = [];
      } else {
        this.$refs.upload.kendoWidget().upload();
      }
      if (!this.isUploaded) {
        // アップロードしない場合
        this.isUpdated = true;
        this.loadingDisplay();
        this.$router.go(-1);
      }
    },
    /**
     * @description アップロード対象ファイルの存在チェック
     */
    async fileExistsCheck() {
      let tmpPayload = [];
      if (this.payload.length !== 0) {
        tmpPayload = this.payload.slice();
      }
      this.payload = [];
      for (const targetFile of this.fileInfo) {
        for (const image of tmpPayload) {
          if (targetFile.name === image.name) {
            this.payload.push(image);
          }
        }
      }
      for (const file of this.payload) {
        try {
          await this.readFileAsync(file);
        } catch(error) {
          return file.name;
        }
      }
      return "";
    },
    /**
     * @description アップロード対象ファイルの読込
     */
    readFileAsync(file) {
      return new Promise((resolve, reject) => {
        let fileReader = new FileReader();
        fileReader.onload = () => resolve(fileReader.result);
        fileReader.onerror = () => reject(fileReader.error);
        fileReader.readAsDataURL(file);
      });
    },
    // del #10977 インジェクション対応 linjunfeng start
    /**
     * @description 画像ファイルにサムネイルを作って表示
     * @param {Object} e kendoイベント
     * @see {@link https://docs.telerik.com/kendo-ui/controls/editors/upload/how-to/add-image-preview}
     */
    // addThumbnailToImages(e) {
    //   if (this.hasSameRecord(e.files) && this.isConfirm) {
    //     // ファイル名重複あり
    //     this.addFileEvent = e;
    //     return;
    //   }

    //   for (const file of e.files) {
    //     const raw = file.rawFile;
    //     const reader = new FileReader();
    //     const that = this;

    //     // 画像形式のみサムネイルを作る
    //     if (![".png", ".jpg", ".jpeg"].includes(file.extension)) {
    //       continue;
    //     }

    //     if (raw) {
    //       reader.onloadend = function() {
    //         const preview = document.createElement("img");

    //         preview.setAttribute("class", "img-preview");
    //         preview.setAttribute("src", this.result);
    //         // 新しいタブで映像を開く
    //         preview.setAttribute(
    //           "onclick",
    //           `window.open().document.write('<img src="${this.result}"></img>')`
    //         );

    //         that.$refs.upload
    //           .kendoWidget()
    //           .wrapper[0].querySelectorAll(
    //             `.k-file[data-uid='${file.uid}'] .k-file-extension-wrapper`
    //           )[0].outerHTML = preview.outerHTML;
    //       };

    //       reader.readAsDataURL(raw);
    //     }
    //   }
    // },
    // del #10977 インジェクション対応 linjunfeng end

    /**
     * @description アップロードをする前のコールバック
     * @summary アップロードする前、リクエストヘッダーにCSRFトークンを埋め込む
     * @param {Object} e kendoイベント
     */
    async addCsrfTokenToRequestHeader(e) {
      this.isUploaded = true;
      const fileNameList = this.value.map(file => file.name);
      if (fileNameList.includes(e.files[0].name)) {
        // ファイル添付済み

        const xhr = e.XMLHttpRequest;
        if (xhr) {
          // CSRFトークンをクッキーから取得
          const cookie = document.cookie.split(new RegExp("[=, ]"));
          const xsrfTokenIndex = cookie.findIndex(item => {
            return item === "XSRF-TOKEN";
          });
          const xsrfToken = cookie[xsrfTokenIndex + 1];

          // CSRFトークンを設定
          xhr.addEventListener("readystatechange", function() {
            // stateがOPENED
            if (xhr.readyState === 1) {
              xhr.setRequestHeader("X-XSRF-TOKEN", xsrfToken);
            }
          });
        }
      }
    },

    hasSameRecord(addfileList) {
      const fileList = this.value.map(file => file.name);
      const addfileNameList = addfileList.map(file => file.name);
      const fileNameList = [...fileList, ...addfileNameList];

      // ファイル名リストをSetオブジェクトに(重複排除)
      const set = new Set(fileNameList);
      if (fileNameList.length !== set.size) {
        // 元のリストと重複排除リストの長さが違うなら重複あり
        return true;
      }
      return false;
    },

    /**
     * @description メッセージ返答後処理
     */
    confirm(answer) {
      this.isDialogVisible = false;
      if (answer === "OK" && this.dialogType === "2") {
        // 上書きOK
        this.override(this.addFileEvent.files);
        this.isConfirm = false;
        this.addFile(this.addFileEvent);
        // del #10977 インジェクション対応 linjunfeng start
        // this.addThumbnailToImages(this.addFileEvent);
        // del #10977 インジェクション対応 linjunfeng end
        this.isConfirm = true;
      }
    },

    override(addFileList) {
      const addfileNameList = addFileList.map(file => file.name);
      const overrideFileList = this.value.filter(file =>
        addfileNameList.includes(file.name)
      );
      this.deleteFileList = overrideFileList;
      this.$emit("deleteFile", overrideFileList);
    },

    onSuccess() {
      this.isUpdated = true;
      this.loadingDisplay();
      // 画面戻る
      this.$router.go(-1);
    },

    onError() {
      // console.log("アップロード失敗しました");
      this.loadingDisplay();
      this.messageCd = 72000003;
      this.dialogType = "1";
      this.isDialogVisible = true;
    },

    async loadingDisplay() {
      this.isUploaded = false;
      // 選択した掲示板番号の詳細情報を設定
      await this.setSelectedBbsInfo(this.bbsCtlNo);

      // storeの掲示板一覧：新規追加、再度検索を行い一覧に新たに追加,患者名一覧：患者が除外追加され更新
      await this.$emit("search");

      // ロードフラグ
      this.$emit("update:isLoadingBbs", false);
    }
  },

  beforeDestroy() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  }
};
</script>

<style>
.k-upload {
  border: none !important;
}

.k-upload .k-dropzone {
  display: none !important;
}

.k-upload .k-upload-files {
  padding-bottom: 0 !important;
}

.k-upload .k-upload-status,
.k-upload .k-file-name {
  font-size: 0.75em !important;
}

.k-upload .k-upload-button,
.k-upload .k-upload-selected,
.k-upload .k-clear-selected {
  display: none;
}

.k-upload .k-file-extension-wrapper {
  top: inherit !important;
  margin: 0 !important;
}

.k-upload .k-file-name-size-wrapper {
  min-height: inherit !important;
}

.k-upload .k-file {
  max-height: 25px;
  border-width: 1px !important;
}
</style>
<style scoped>
.dropzone-container {
  border: 2px dashed var(--ntss-border-color);
  padding: 0.3em;
  text-align: center;
}

.dropzone-custom-title,
.dropzone-custom-subtitle {
  margin: 0;
}
.img-preview {
  max-height: inherit;
  max-width: 50px;
  position: relative;
  vertical-align: top;
  margin-right: -25px;
  cursor: pointer;
}
</style>
