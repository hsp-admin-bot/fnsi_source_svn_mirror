<template>
  <div>
    <v-ons-row v-for="(file, index) in modelValue" :key="index" style="line-height: 1.5em; flex-wrap: nowrap;">
      <v-ons-icon class="attachment-icon" icon="fa-paperclip" />
      <div class="download-link" @click="downloadFile(file)">
        {{ file.name }}
      </div>
      <v-ons-icon
        v-show="!isRegFuncClass"
        class="trash-icon"
        :style="{ 'pointer-events': eventRegFuncClass }"
        icon="fa-trash"
        @click="deleteFile(file)"
      />
    </v-ons-row>
  </div>
</template>

<script>
import { mapGetters } from "@/compat/vue/vuex";
import { ApiHelper } from "@/apis/AxiosHelper.js";
import { sendRequestGetDownload } from "@/apis/pat-event";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import { triggerScopedDownload } from "@/functions/common/LayoutMeasureHelper";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end

export default {
  emits: ["update:modelValue"],
  props: {
    // Vue3 既定 v-model は modelValue / update:modelValue を使用する。
    modelValue: {
      type: Array,
      required: true,
      default() {
        return [];
      }
    }
  },

  data() {
    return {
      removedFiles: [],
      isDownload: false
    };
  },

  computed: {
    ...mapGetters("bbs-info", ["selectedBbs"]),
    eventRegFuncClass(){
      if(this.selectedBbs.reg_func_class === 1){
        return "none";
      }
      return "auto";
    },
    isRegFuncClass(){
      if(this.selectedBbs.reg_func_class === 1){
        return true;
      }
      return false;
    },
  },

  methods: {
    /**
     * @description ファイルをダウンロード
     * @param {String} filename
     */
    async downloadFile(file) {

      let filename = null;
      let response = null;
      if(this.selectedBbs.reg_func_class === 1){
        const filePath = file.path;
        filename = file.name;
        response = await sendRequestGetDownload(filePath);
      }else{
        const filepath = file.path;
        filename = file.name;
        response = await ApiHelper.get("bbsInfo/files", {
          filepath
        }).catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
          getErrorMessage('BbsFileDownloader.vue', 'downloadFile', 'ダウンロード失敗しました');
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
          console.log("ダウンロード失敗しました");
          throw error;
        });
      }

      const downloadData = response.request.response;

      const blob = new Blob([this.hexStringToArrayBuffer(downloadData)], {
        type: "application/zip"
      });
      triggerScopedDownload({
        blob,
        filename,
        root: this.$el
      });
    },

    /**
     * @description アップロードしたファイルをサーバーから削除
     * @param {String} filename
     */
    deleteFile(file) {
      const filepath = file.path;
      const filename = file.name;
      const fileInfo = this.modelValue.filter(i => i !== file);
      this.$emit("update:modelValue", fileInfo);
      const deletefile = JSON.stringify({ name: filename, path: filepath });
      const pathList = this.selectedBbs.file_info.map(i => i.path);

      if (pathList.includes(filepath)) {
        this.removedFiles.push({ name: deletefile, path: filepath });
      }
    },

    /**
     * @description 削除するファイルがあるかチェック
     */
    async checkForDeletedFiles(bbs_ctl_no) {
      this.isDownload = true;
      await ApiHelper.post(
        `/bbsInfo/deleteBbsFileAttachment/${bbs_ctl_no}`,
        this.removedFiles
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('BbsFileDownloader.vue', 'checkForDeletedFiles', 'ファイル削除失敗しました');
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        // this.$refsで呼び出し削除失敗：画面遷移時の編集破棄有無を非表示へ
        this.isDownload = false;
        console.log("ファイル削除失敗しました");
        throw error;
      });
      this.isDownload = false;

      // 削除済みファイルを削除するファイルのリストから取り除く
      this.removedFiles = [];
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
  },

  beforeUnmount() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
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
