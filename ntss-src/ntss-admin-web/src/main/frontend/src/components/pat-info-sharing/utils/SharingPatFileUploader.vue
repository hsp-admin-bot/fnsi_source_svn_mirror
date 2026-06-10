<template>
  <div v-if="!hidden">
    <div
      class="dropzone-container"
      :class="[{ 'uploader-disabled': disabled }, $attrs.class]"
      @click="dropzoneClick"
    >
      <div class="dropzone-custom-title ntss-pat-event-label">
        ここにファイルをドロップ
      </div>
      <div class="dropzone-custom-subtitle ntss-pat-event-label">
        またはクリックしてファイルを選択
      </div>
    </div>

    <kendo-upload
      ref="upload"
      name="files"
      v-bind="kendoUploadOptions"
      :disabled="disabled"
      @select="addFile"
      @remove="removeFile"
    />
  </div>
</template>

<script>
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
const DEFAULT_MAX_SIZE = "20480";

export default {
  name: "CommonFileUploader",
  props: {
    value: {
      type: Array,
      required: true,
      default: () => [],
    },
    disabled: {
      type: Boolean,
      default: false,
    },
    hidden: {
      type: Boolean,
      default: false,
    },
    isLoading: {
      type: Boolean,
      default: false,
    },
    maxSize: {
      type: String,
      default: DEFAULT_MAX_SIZE,
    },
  },
  data() {
    return {
      kendoUploadOptions: {
        async: {
          autoUpload: false,
        },
        showFileList: false,
        dropZone: ".dropzone-container",
        localization: {
          select: "ファイルを選択",
          clearSelectedFiles: "クリア",
        },
      },
      payload: [],
    };
  },
  methods: {
    /**
     * ドロップゾーンクリック処理
     */
    dropzoneClick() {
      if (!this.disabled) {
        this.$refs.upload.kendoWidget().element.click();
      }
    },
    /**
     * ファイル追加処理
     */
    addFile(e) {
      this.$emit("clear-error");
      if (this.hasSameRecord(e.files)) {
        this.$emit("error", DIALOG_MESSAGES[72000002].message);
        return;
      }
      for (const file of e.files) {
        if (file.size > parseInt(this.maxSize) * 1024) {
          this.$emit("error", DIALOG_MESSAGES[72000004].message);
          return;
        }
        this.payload.push(file.rawFile);
      }
      const updatedInfo = [
        ...this.value,
        ...e.files.map((i) => ({ name: i.name, path: null })),
      ];
      this.$emit("input", updatedInfo);
    },
    /**
     * ファイル削除処理
     */
    removeFile(e) {
      this.$emit("clear-error");
      const fileName = e.files[0].name;
      this.payload = this.payload.filter((f) => f.name !== fileName);
      const updatedInfo = this.value.filter((i) => i.name !== fileName);
      this.$emit("input", updatedInfo);
    },
    /**
     * ファイル存在チェック処理
     */
    async fileExistsCheck() {
      const currentNames = this.value.map((i) => i.name);
      this.payload = this.payload.filter((f) => currentNames.includes(f.name));
      return "";
    },
    /**
     * 同名ファイルチェック処理
     */
    hasSameRecord(addfileList) {
      const currentNames = new Set(this.value.map((file) => file.name));
      const hasDuplicateWithCurrent = addfileList.some((file) =>
        currentNames.has(file.name)
      );
      const newNames = addfileList.map((file) => file.name);
      const hasDuplicateInNew = newNames.length !== new Set(newNames).size;
      return hasDuplicateWithCurrent || hasDuplicateInNew;
    },
  },
  watch: {
    value(newValue) {
      if (!newValue || newValue.length === 0) {
        this.payload = [];
        const uploadWidget = this.$refs.upload.kendoWidget();
        if (uploadWidget) uploadWidget.removeAllFiles();
        return;
      }
      const currentNames = newValue.map(i => i.name);
      this.payload = this.payload.filter(f => currentNames.includes(f.name));
    }
  },
  beforeDestroy() {
    Object.assign(this.$data, this.$options.data());
  },
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
  cursor: pointer;
}
.uploader-disabled {
  background-color: #ebebe4;
  color: #aaa !important;
  -webkit-text-fill-color: #aaa !important;
  cursor: not-allowed;
  border-color: #e5e5e5;
  opacity: 0.6 !important;
}
.dropzone-custom-title,
.dropzone-custom-subtitle {
  margin: 0;
}
.custom-select-edited .dropzone-container {
  border-color: green !important;
  border-style: solid !important;
}
.custom-select-edited .ntss-pat-event-label {
  color: green !important;
  font-weight: bold !important;
}
</style>
