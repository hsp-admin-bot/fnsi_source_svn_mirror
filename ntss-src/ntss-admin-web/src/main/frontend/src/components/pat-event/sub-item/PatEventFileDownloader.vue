<template>
  <div>
    <v-ons-row v-for="(file, index) in value" :key="index" style="line-height: 1.5em; flex-wrap: nowrap;">
      <v-ons-icon class="attachment-icon" icon="fa-paperclip" />
      <!-- mod #12462 患者情報共有 20260324 start -->
      <div class="download-link" @click="downloadFile(file)">{{ file.file_name }}</div>
      <v-ons-icon
        v-if="!getIsOtherFacilitys"
        v-show="!getViewMode"
        class="trash-icon"
        :style="{ 'pointer-events': getEvents }"
        icon="fa-trash"
        @click="checkForDeletedFiles(file)"
      />
      <div v-else></div>
      <!-- mod #12462 患者情報共有 20260324 end -->
    </v-ons-row>
  </div>
</template>

<script>
import { mapGetters, mapActions } from "vuex";
import {
  sendRequestGetDownload,
  sendRequestPostDelete
} from "@/apis/pat-event";
//FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
// add #10359 編集権限の動作不正 start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 end

export default {
  props: {
    value: {
      type: Array,
      required: true,
      default() {
        return [];
      }
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
      removedFiles: [],
      isDownload: false
    };
  },
  computed: {
    ...mapGetters("pat-event/detail", [
      "getPatEventResultParams",
      "getPatEventRecord",
      "getViewMode"
    ]),
    // add #12462 患者情報共有 20260317 start
      ...mapGetters("pat-event/list", ["getIsOtherFacility"]),
      ...mapGetters("observe-record/list", ["getIsOtherFacilitys"]),
    // add #12462 患者情報共有 20260317 end
    getEvents() {
      if (this.getViewMode) {
        return "none";
      }
      return "auto";
    }
  },
  beforeDestroy() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
  methods: {
    ...mapActions("pat-event/detail", [
      "setPatEventResultParamsUpdate",
      "setPatEventRecord"
    ]),
    /**
     * @description ファイルをダウンロード
     * @param {String} filename
     */
    async downloadFile(file) {
      //追加された添付ファイルをクリックして（保存をクリックしていない）「1.txt」は表示を開くことができません 修正 20230615 ztc start
      if(file.file_path === undefined || file.file_path === null || file.file_path === ""){
        return;
      }
      //追加された添付ファイルをクリックして（保存をクリックしていない）「1.txt」は表示を開くことができません 修正 20230615 ztc end
      const filepath = file.file_path;
      const filename = file.file_name;
      const response = await sendRequestGetDownload(filepath);
      const downloadData = response.request.response;
      const blob = new Blob([this.hexStringToArrayBuffer(downloadData)], {
        type: "application/zip"
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
    // add #10359 編集権限の動作不正 start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 end
    /**
     * @description 削除するファイルのリストを作成
     * @param {String} filename
     */
    async checkForDeletedFiles(file) {
      if (!this.disabled) {
      const filepath = file.file_path;
      const filename = file.file_name;
      const result = this.getPatEventResultParams[this.index].result_value;
      const fileInfo = this.value.filter(i => i !== file);
      const formatClass = this.getPatEventResultParams[this.index].format_class;
      const values = {
        format_class: formatClass,
        result_value: fileInfo
      };
      this.$emit("input", fileInfo);
      const deletefile = JSON.stringify({
        file_name: filename,
        file_path: filepath
      });
      const pathList = result?.map(i => i.file_path);
      if (pathList?.includes(filepath)) {
        await this.removedFiles.push({ file_name: deletefile, file_path: filepath });
      }
      await this.setPatEventResultParamsUpdate({
        item: values,
        index: this.index
      });
    }
    },
    /**
     * @description サーバよりファイルを削除する
     */
    async deleteFile(patId) {
      if (this.removedFiles.length === 0) {
        return true;
      }
      await sendRequestPostDelete({
        patId: patId,
        removedFiles: this.removedFiles
      }).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
        getErrorMessage('PatEventFileDownloader.vue', 'deleteFile', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
        return false;
      });
      // 削除済みファイルを削除するファイルのリストから取り除く
      this.removedFiles = [];
      return true;
    },
    /**
     * @description 16進文字列をバイト配列に変換
     * @param {String} hexStr 16進文字列
     */
    hexStringToArrayBuffer(hexStr) {
      const bytes = [];
      // 受け取った16進数文字列を符号付バイト配列に変換
      for (let i = 0; i < hexStr.length; i += 2) {
        bytes.push(this.hexToDecimalNumber(hexStr.substr(i, 2)));
      }
      // バイト配列をArrayBuffer型に変換
      const arrayBuffer = new Uint8Array(bytes);
      return arrayBuffer;
    },
    /**
     * @description 16進文字列をバイト値に変換
     * @param {String} hexStr 16進文字列
     */
    hexToDecimalNumber(hexStr) {
      let decimalNumber = "";
      // 受け取った16進数値を2進数値に変換
      const binaryNumber = parseInt(hexStr, 16).toString(2);
      // 変換した2進数値のサイズが8未満の場合、正数であるため10進数値に変換
      if (binaryNumber.length < 8) {
        decimalNumber = parseInt(hexStr, 16);
        // 変換した2進数値のサイズが8の場合、負数であるため符号付10進数値に独自変換
      } else {
        // 2進数値のサイズ分(8サイズ)回り、ビット値を入れ替える
        const binaryNumberStr = binaryNumber.toString();
        for (let i = 0; i < binaryNumberStr.length; i++) {
          if (parseInt(binaryNumberStr.substr(i, 1), 10) === 0) {
            decimalNumber += "1";
          } else if (parseInt(binaryNumberStr.substr(i, 1), 10) === 1) {
            decimalNumber += "0";
          }
        }
        // ビット値を入れ替えた2進数値を10進数値に変換し、1を足して負数に変換する
        decimalNumber = -(parseInt(decimalNumber, 2) + 1);
      }
      return decimalNumber;
    }
  }
};
</script>

<style scoped>
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
