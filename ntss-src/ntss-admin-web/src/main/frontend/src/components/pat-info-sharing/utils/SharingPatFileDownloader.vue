<template>
  <div>
    <v-ons-row
      v-for="(file, index) in value"
      :key="index"
      class="attachment-file"
    >
      <v-ons-icon class="attachment-icon" icon="fa-paperclip" />
      <div class="download-link" @click="downloadFile(file)">
        {{ file.name }}
      </div>
      <v-ons-icon
        class="trash-icon"
        icon="fa-trash"
        @click="deleteFile(file)"
      />
    </v-ons-row>
  </div>
</template>

<script>
import { mapGetters } from "vuex";
import { sendRequestGetDownload } from "@/apis/pat-info-sharing";

export default {
  props: {
    value: {
      type: Array,
      required: true,
      default() {
        return [];
      },
    },
  },

  data() {
    return {
      removedFiles: [],
      isDownload: false,
    };
  },

  computed: {
    ...mapGetters("pat-info-sharing", ["getSelectedShrInfo"]),
  },

  methods: {
    /**
     * ファイルダウンロード処理
     */
    async downloadFile(file) {
      let filename = null;
      let response = null;
      const filePath = file.path;
      filename = file.name;
      response = await sendRequestGetDownload(filePath);
      const downloadData = response.request.response;
      const blob = new Blob([this.hexStringToArrayBuffer(downloadData)], {
        type: "application/zip",
      });
      if (window.navigator.msSaveBlob) {
        window.navigator.msSaveBlob(blob, filename);
      } else {
        const downloadUrl = (window.URL || window.webkitURL).createObjectURL(
          blob
        );
        const link = document.createElement("a");
        link.href = downloadUrl;
        link.download = filename;
        link.click();
        (window.URL || window.webkitURL).revokeObjectURL(blob);
      }
    },
    /**
     * ファイル削除処理
     */
    async deleteFile(file) {
      this.$emit("clear-error");
      const filepath = file.path;
      const filename = file.name;
      const fileInfo = this.value.filter((i) => i !== file);
      this.$emit("input", fileInfo);
      const deletefile = JSON.stringify({ name: filename, path: filepath });
      const pathList = this.getSelectedShrInfo.fileInfo.map((i) => i.path);
      if (pathList.includes(filepath)) {
        this.removedFiles.push({ name: deletefile, path: filepath });
      }
    },
    /**
     * 16進数文字列を配列バッファに変換する処理
     */
    hexStringToArrayBuffer(hexStr) {
      const bytes = [];
      for (let i = 0; i < hexStr.length; i += 2) {
        bytes.push(this.hexToDecimalNumber(hexStr.substr(i, 2)));
      }
      const arrayBuffer = new Uint8Array(bytes);
      return arrayBuffer;
    },
    /**
     * 16進数を10進数に変換する処理
     */
    hexToDecimalNumber(hexStr) {
      let decimalNumber = "";
      const binaryNumber = parseInt(hexStr, 16).toString(2);
      if (binaryNumber.length < 8) {
        decimalNumber = parseInt(hexStr, 16);
      } else {
        const binaryNumberStr = binaryNumber.toString();
        for (let i = 0; i < binaryNumberStr.length; i++) {
          if (parseInt(binaryNumberStr.substr(i, 1), 10) === 0) {
            decimalNumber += "1";
          } else if (parseInt(binaryNumberStr.substr(i, 1), 10) === 1) {
            decimalNumber += "0";
          }
        }
        decimalNumber = -(parseInt(decimalNumber, 2) + 1);
      }
      return decimalNumber;
    },
  },
  beforeDestroy() {
    Object.assign(this.$data, this.$options.data());
  },
};
</script>

<style scoped>
.attachment-file {
  line-height: 1.5em;
  flex-wrap: nowrap;
}
.attachment-icon {
  margin-right: 3px;
}
.trash-icon {
  cursor: pointer;
  margin-left: 5px;
}
.attachment-icon,
.trash-icon {
  color: gray;
  font-size: 1.04em;
  margin-top: 1px;
}
.download-link {
  color: blue;
  cursor: pointer;
  word-break: break-all;
}
</style>