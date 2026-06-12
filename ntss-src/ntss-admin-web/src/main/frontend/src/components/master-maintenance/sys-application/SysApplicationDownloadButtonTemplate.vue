/** ダウンロードボタンのテンプレート */
<template>
  <div>
    <a class='k-button d-button' @click='handleDownload'>
      <img class='d-img' src='img/master-maintenance/download.png' alt='ダウンロード'>
    </a>
  </div>
</template>

<script>
import axios from "@/compat/http/axios";
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
import { triggerScopedDownload } from "@/functions/common/LayoutMeasureHelper";

export default {
  name: "downloadButtonTemplate",
  props: ['templateArgs'],
  data() {
    return {
      downloadPath: "",
    };
  },
  methods: {
    /** ファイル存在チェック */
    async checkFileExists(downloadPath) {
      if (!downloadPath) return false;
      try {
        const response = await axios.head(downloadPath);
        return response.status === 200;
      } catch {
        return false;
      }
    },
    /** ファイルダウンロード処理 */
    async handleDownload(e) {
      e.preventDefault();
      // mod #11660 単体アプリの自己アップデート修正 limingzhe start
      // const fullPath = this.templateArgs.path;
      // if (!fullPath) return;
      //
      // const fileName = fullPath.split(/[/\\]/).pop();
      // const baseUrl = window.location.origin;
      // const newPath = `${baseUrl}/ntss-admin-web/${fileName}`;
      // let finalPath = '';
      //
      // if (await this.checkFileExists(newPath)) {
      //   // 最新版が格納されている方からダウンロード
      //   finalPath = newPath;
      // } else {
      //   const publicIndex = fullPath.indexOf('public');
      //   if (publicIndex !== -1) {
      //     // 従来の格納先からダウンロード
      //     finalPath = fullPath.substring(publicIndex + 'public'.length + 1).replace(/\\/g, '/');
      //   }
      // }
      //
      // if (await this.checkFileExists(finalPath)) {
      //   const link = document.createElement('a');
      //   link.href = finalPath;
      //   link.download = '';
      //   document.body.appendChild(link);
      //   link.click();
      //   document.body.removeChild(link);
      // } else {
      //   this.$ons.notification.alert(
      //     messageFormat(DIALOG_MESSAGES['00200009'].message),
      //     { title: DIALOG_MESSAGES['00200009'].title }
      //   );
      // }
      const filename = this.templateArgs.filename;
      if (!filename) return;
      let response = await axios
        .post("/ntss-admin-web/api/application/download", {
          filename: this.templateArgs.filename
        }, {
          responseType: "blob"
        })
        .then(function (response) {
          var blob = null;
          const contentDis = response.headers["content-disposition"];
          var fileName = contentDis.slice(contentDis.lastIndexOf("filename=") + 9);
          fileName = decodeURI(fileName);
          if (response.headers["content-type"] == "application/msi") {
            blob = new Blob([response.data], { type: "application/msi" });
          }
          if (!blob) {
            return;
          }
          let link = window.document.createElement("a");
          link.href = window.URL.createObjectURL(blob);
          link.download = fileName;
          document.body.append(link);
          link.click();
          link.remove();
        })
        .catch(error => {
          this.$ons.notification.alert(
            messageFormat(DIALOG_MESSAGES['00200009'].message),
            { title: DIALOG_MESSAGES['00200009'].title }
          );
        });
      // mod #11660 単体アプリの自己アップデート修正 limingzhe end
    },
  }
};
</script>

<style scoped>
.d-button {
  border-radius: 100%;
  width: 2.4em;
  height: 2.4em;
  margin-right: 5px;
  background-image: linear-gradient(#e4e7eb, #e4e7eb) !important;
  border-bottom: solid 3px var(--btn-common-border-color) !important;
  box-shadow: unset;
}
.d-img {
  width: 1.5em;
  height: 1.5em;
}
</style>
