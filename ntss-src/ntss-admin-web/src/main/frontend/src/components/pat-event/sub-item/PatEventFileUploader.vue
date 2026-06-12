<template>
  <div>
    <!--mod FNSI-画面部品デザイン じょはく start-->
    <template v-if="this.getViewMode || !this.isShared || getIsOtherFacility || getIsOtherFacilitys">
      <div class="dropzone-container-disiabled" @click="dropzoneClick">
        <label class="dropzone-custom-title ntss-pat-event-label">ここにファイルをドロップ</label>
        <label class="dropzone-custom-subtitle ntss-pat-event-label">またはクリックしてファイルを選択</label>
      </div>
    </template>
    <template v-else>
      <div :class="'dropzone-container'+index" @click="dropzoneClick">
        <label class="ntss-pat-event-label">ここにファイルをドロップ</label>
        <label class="ntss-pat-event-label">またはクリックしてファイルを選択</label>
      </div>
    </template>
    <kendo-upload
      ref="upload"
      name="files"
      v-bind="kendoUploadOptions"
      :disabled="getViewMode || !isShared || disabled"
      @select="addFile($event)"
      @remove="removeFile($event)"
    />
    <div v-if="isDialogVisible">
      <message-dialog
        v-model:visible="isDialogVisible"
        :message-cd="messageCd"
        :type="dialogType"
        :title="title"
        @confirm="confirm"
      />
    </div>
  </div>
</template>

<script>
import { mapGetters, mapActions } from "@/compat/vue/vuex";
// 共通カレンダーコンポーネント
import messageDialog from "@/components/common/message-dialog/MessageDialog";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { sendRequestPostUpload } from "@/apis/pat-event";

//FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
// add #10359 編集権限の動作不正 start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
import { dateFormat } from "@/functions/common/DateTimeUtils.js";
import { getScopedDocument } from "@/functions/common/LayoutMeasureHelper";
// add #10359 編集権限の動作不正 end
export default {
  components: {
    "message-dialog": messageDialog
  },
  emits: ["update:modelValue", "deleteFile"],
  props: {
    // Vue3 既定 v-model は modelValue / update:modelValue を使用する。
    modelValue: {
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
    },
    index: {
      type: Number,
      required: true,
      default: 0
    },
    // add #10359 編集権限の動作不正 start
    disabled: {
      type: Boolean,
      default: false,
    },
    // add #10359 編集権限の動作不正 end
  },

  data() {
    return {
      kendoUploadOptions: {
        async: {
          // 同期アップロードを使用しない(ファイルを選択後、アップロードはしない)
          autoUpload: false,
          // 保存先のURL
          saveUrl: "api/pat_event/files"
        },
        // アップロードするファイルの一覧を表示
        showFileList: false,
        // ドラッグアンドドロップ可能DOMオブジェクトのクラス名
        dropZone: null,
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
      title: null,
      addFileEvent: null,
      isConfirm: true,
      deleteFileList: [],
      payload: [],
      fileList: [],
      dropzoneStyleTag: null
    };
  },

  computed: {
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("account-edit", ["getStateUserAccountInfo"]),
    ...mapGetters("pat-event/detail", [
      "getPatEventInputParams",
      "getPatEventResultParams",
      "getPatEventRecord",
      "getViewMode"
    ]),
    // add FNSI-共有を追加 王 20200921 start
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("treatment-record/common", ["getSharedFacilityCd"]),
    ...mapGetters("pat-event/list", ["getIsOtherFacility"]),
    ...mapGetters("observe-record/list", ["getIsOtherFacilitys"]),
    isShared() {
      if(this.getPatEventRecord.isComRec){
        return this.getFacilityCd === this.getSharedFacilityCd;
      }
      return true;
    },
    // add FNSI-共有を追加 王 20200921 end
    fileInfo() {
      const deleteNameList = this.deleteFileList.map(file => file.file_name);
      const file = this.modelValue.filter(
        file => !deleteNameList.includes(file.file_name)
      );

      return file;
    }
  },
  beforeUnmount() {
    this.dropzoneStyleTag?.parentNode?.removeChild?.(this.dropzoneStyleTag);
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
  created() {
    this.kendoUploadOptions.dropZone = ".dropzone-container" + this.index;
  },
  mounted() {
    // <style>タグを生成
    const scopedDocument = getScopedDocument(this);
    const styleTag = scopedDocument?.createElement?.('style');
    if (!styleTag) {
      return;
    }
    styleTag.textContent = `
      .dropzone-container`+ this.index + `{
        border: 2px dashed var(--ntss-border-color);
        padding: 0.5em;
        text-align: center;
        display: flex;
        flex-flow: column;
      }
    `;
    scopedDocument.head?.appendChild?.(styleTag);
    this.dropzoneStyleTag = styleTag;
  },

  methods: {
    ...mapActions("pat-event/detail", [
      "setPatEventResultParamsUpdate",
      "setPatEventRecord"
    ]),
    /**
     * @description ドラッグアンドドロップエリアをクリックする時のコールバック
     * @summary 呼び出してからファイル選択ダイアログを表示
     */
    dropzoneClick() {
      this.$refs.upload?.browse?.();
    },
    // add #10359 編集権限の動作不正 start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 end
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
        this.title = DIALOG_MESSAGES[72000002].title;
        this.isDialogVisible = true;
        return;
      }
      const maxSize = this.getPatEventInputParams[this.index].item_json
        .max_size;
      for (const file of e.files) {
        // mod #10894 患者イベントレイアウトマスタのファイル貼付サイズ上限がFNWより小さい 張玲 start
        // if (file.size > maxSize * 1000) {
        if (file.size > maxSize * 1024) {
          // ファイルサイズオーバー
          this.addFileEvent = e;
          this.messageCd = 72000004;
          this.dialogType = "1";
          this.title = DIALOG_MESSAGES[72000004].title;
          this.isDialogVisible = true;
          return;
        }
        // mod #10894 患者イベントレイアウトマスタのファイル貼付サイズ上限がFNWより小さい 張玲 end
      }
      const fileInfos = [
        ...this.fileInfo,
        ...e.files.map(i => ({
          file_name: i.name,
          file_path: null,
          file_modified_time: dateFormat.format(new Date(), "yyyyMMddhhmmss")
        }))
      ];
      this.$emit("update:modelValue", fileInfos);
      this.deleteFileList = [];
      this.fileList = fileInfos;
      for (const file of e.files) {
        const raw = file.rawFile;
        this.payload.push(raw);
      }
      // #9229 患者イべント、OKボタンをクリックします。1.txtドキュメントは、元のファイルに置き換えていません。 linjunfeng start
      this.payload = this.unique(this.payload, 'name')
      // #9229 患者イべント、OKボタンをクリックします。1.txtドキュメントは、元のファイルに置き換えていません。 linjunfeng end
      const values = {
        format_class: this.getPatEventResultParams[this.index].format_class,
        result_value: fileInfos
      };
      this.setPatEventResultParamsUpdate({
        item: values,
        index: this.index
      });
    },
    // #9229 患者イべント、OKボタンをクリックします。1.txtドキュメントは、元のファイルに置き換えていません。 linjunfeng start
    /**
     * @description オブジェクトの配列を削除し最新のオブジェクトだけを残します
     * @param {Object} e arr ターゲットです
     * @param {String} e name 対象key
     */
    unique(arr, name) {
      let hash = {}
      return arr.reduce((acc, cru, index) => {
        if (!hash[cru[name]]) {
          hash[cru[name]] = {index:index}
          acc.push(cru)
        }else{
          acc.splice(hash[cru[name]]['index'], 1, cru)
        }
        return acc;
      }, []);
    },
    // #9229 患者イべント、OKボタンをクリックします。1.txtドキュメントは、元のファイルに置き換えていません。 linjunfeng end
    /**
     * @description ファイル削除後コールバック
     * @param {Object} e kendoイベント
     * @see {@link https://docs.telerik.com/kendo-ui/api/javascript/ui/upload/events/remove}
     */
    removeFile(e) {
      const files = e.files.map(i => i.name);
      const fileInfos = this.modelValue.filter(i => !files.includes(i.name));
      this.$emit("update:modelValue", fileInfos);
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
          if (targetFile.file_name === image.name) {
            this.payload.push(image);
            break;
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
    /**
     * @description ファイルをアップロード
     */
    async upload(params) {
      let tmpPayload = [];
      if (this.payload.length !== 0) {
        tmpPayload = this.payload.slice();
      }
      this.payload = [];
      for (const targetFile of this.fileInfo) {
        for (const image of tmpPayload) {
          if (targetFile.file_name === image.name) {
            this.payload.push(image);
            break;
          }
        }
      }
      const rec = this.getPatEventRecord;
      let dt = new Date(rec.eventDate);
      let eventDate =
        dt.getFullYear() +
        ("00" + (dt.getMonth() + 1)).slice(-2) +
        ("00" + dt.getDate()).slice(-2);
      if (this.payload.length !== 0) {
        for (const file of this.payload) {
          const formData = new FormData();
          formData.append("files", file);
          const res = await sendRequestPostUpload(
            {
              facilityCd: params.facilityCd,
              patId: params.patId,
              eventDate: eventDate,
              patEventCd: rec.patEventCd,
			  fieldName: this.index
            },
            formData
          ).catch(error => {
            //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
            getErrorMessage('PatEventFileUploader.vue', 'upload', error);
            //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
            return false;
          });
          if (res.status !== 200) {
            return false;
          }
        }
      }
      //ストアの情報を更新
      let path =
        rec.patId +
        "/" +
        rec.patEventCd +
        "/" +
        "file" +
		"/" +
		this.index +
        "/";
      let tmpfileList = [];
      for (const file of this.fileInfo) {
        tmpfileList.push({
          file_name: file.file_name,
          file_path: path + file.file_name,
          file_modified_time : file.file_modified_time
        });
      }
      // #10228 2回目に新規ログインをクリックすると、操作卓エラーが発生しますundefined (reading 'format_class') linjunfeng start
      // const formatClass = this.getPatEventResultParams[this.index].format_class;
      const formatClass = this.getPatEventResultParams[this.index]?.format_class;
      // #10228 2回目に新規ログインをクリックすると、操作卓エラーが発生しますundefined (reading 'format_class') linjunfeng end
      const values = {
        format_class: formatClass,
        result_value: tmpfileList
      };
      this.setPatEventResultParamsUpdate({
        item: values,
        index: this.index
      });
      return true;
    },

    async getFileList() {
      const rec = this.getPatEventRecord;
      let path =
        rec.patId +
        "/" +
        rec.patEventCd +
        "/" +
        "file" +
		"/" +
		this.index +
        "/";
      let tmpfileList = [];
      for (const file of this.fileInfo) {
        tmpfileList.push({
          file_name: file.file_name,
          file_path: path + file.file_name,
          file_modified_time: file.file_modified_time
        });
      }
      //  #11389 患者イベントの編集での不正　V1.1A linjunfeng start
      // const formatClass = this.getPatEventResultParams[this.index].format_class;
      const formatClass = this.getPatEventResultParams[this.index]?.format_class;
      // #11389 患者イベントの編集での不正　V1.1A linjunfeng end
      return {
        index: this.index,
        format_class: formatClass,
        result_value: tmpfileList
      };
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

    hasSameRecord(addfileList) {
      const fileList = this.modelValue.map(file => file.file_name);
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
    async confirm(answer) {
      this.isDialogVisible = false;
      if (answer === "OK" && this.dialogType === "2") {
        // 上書きOK
        await this.override(this.addFileEvent.files);
        this.isConfirm = false;
        this.addFile(this.addFileEvent);
        // del #10977 インジェクション対応 linjunfeng start
        // this.addThumbnailToImages(this.addFileEvent);
        // del #10977 インジェクション対応 linjunfeng end
        this.isConfirm = true;
      }
    },

    async override(addFileList) {
      const addfileNameList = addFileList.map(file => file.name);
      const overrideFileList = this.modelValue.filter(file =>
        addfileNameList.includes(file.file_name)
      );
      this.deleteFileList = overrideFileList;
      await this.$emit("deleteFile", overrideFileList);
    },

    isUploadDisable() {
      if (this.getViewMode) {
        this.$refs.upload?.disable?.();
      } else {
        this.$refs.upload?.enable?.();
      }
    }
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
.k-upload .k-clear-selected,
.k-upload .k-actions {
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
.dropzone-container-disiabled {
  color: gainsboro;
  border: 2px dashed #e5e5e5;
  padding: 20px;
  text-align: center;
  background-color: #ebebe4;
  font-size: 1em;
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
