<template>
  <div class="p12-merge-page">
    <div class="merge-title">証明書マージ</div>
    <div class="main-container">
      <div class="form-container">
        <p class="description">
          証明書をアップロードして申請します。
          各証明書のパスワードを入力してください。
        </p>

        <div class="info-box">
          <span class="info-icon">ℹ</span>
          現在ログイン中の施設用証明書「<strong>{{ getUserId }}</strong>」は、申請後の証明書に自動的に含まれます。
          追加したい他施設の証明書のみアップロードしてください。
        </div>

        <div class="section-label">アップロードする証明書（1件以上）</div>

        <div class="file-rows">
          <div
            v-for="(row, index) in rows"
            :key="index"
            class="file-row"
          >
            <label
              class="file-label"
              :for="'file-input-' + index"
            >{{ row.fileName || 'ファイルを選択...' }}</label>
            <input
              type="file"
              accept=".p12"
              :id="'file-input-' + index"
              class="file-input-hidden"
              @change="onFileChange($event, index)"
            />
            <input
              type="password"
              v-model="row.password"
              placeholder="パスワード"
              class="password-input"
            />
            <button
              v-if="rows.length > 1"
              class="button btn-remove"
              @click="removeRow(index)"
            >削除</button>
          </div>
        </div>

        <div class="add-row-area">
          <button class="button btn-add" @click="addRow">＋ 追加</button>
        </div>

        <div class="output-group">
          <div class="output-area">
            <span class="output-label">出力証明書パスワード <span class="required">*</span></span>
            <input
              type="password"
              v-model="outputPassword"
              placeholder="出力パスワード"
              class="password-input output-password-input"
            />
          </div>
          <div class="output-area">
            <span class="output-label">出力証明書パスワード（確認） <span class="required">*</span></span>
            <input
              type="password"
              v-model="outputPasswordConfirm"
              placeholder="出力パスワード（確認）"
              class="password-input output-password-input"
            />
          </div>
        </div>

        <div class="panel">
          <v-ons-row>
            <v-ons-col>
              <button class="button btn-back" @click="$router.push({ name: 'ClCertificateDownload' })">
                戻る
              </button>
              <button class="button btn-merge" @click="doMerge">
                証明書をダウンロード
              </button>
            </v-ons-col>
          </v-ons-row>
        </div>
      </div>
    </div>
    <loading-screen />
  </div>
</template>

<script>
import loadingScreen from "@/components/common/LoadingScreen";
import { mapActions, mapGetters } from "vuex";
import axios from "axios";
import router from "@/router";

export default {
  components: { "loading-screen": loadingScreen },

  data() {
    return {
      rows: [
        { file: null, fileName: "", password: "" }
      ],
      outputPassword: "",
      outputPasswordConfirm: "",
      isAlerting: false
    };
  },

  computed: {
    ...mapGetters("user", {
      getUserId: "getUserId"
    })
  },

  methods: {
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      resetLoadingScreenVisibleCount: "resetLoadingScreenVisibleCount"
    }),

    ...mapActions("user", {
      signOut: "signOut"
    }),

    addRow() {
      this.rows.push({ file: null, fileName: "", password: "" });
    },

    removeRow(index) {
      this.rows.splice(index, 1);
    },

    onFileChange(event, index) {
      const file = event.target.files[0];
      if (file) {
        this.$set(this.rows[index], "file", file);
        this.$set(this.rows[index], "fileName", file.name);
      }
    },

    getCookie(name) {
      const match = document.cookie.match(
        new RegExp("(^| )" + name + "=([^;]+)")
      );
      return match ? decodeURIComponent(match[2]) : null;
    },

    showAlert(message) {
      if (!this.isAlerting) {
        this.isAlerting = true;
        this.$nextTick(() => {
          this.$ons.notification.alert({
            title: "エラー",
            message,
            callback: () => {
              this.isAlerting = false;
            }
          });
        });
      }
    },

    async doMerge() {
      if (this.rows.length < 1) {
        this.showAlert("1つ以上の証明書をアップロードしてください。");
        return;
      }
      for (let i = 0; i < this.rows.length; i++) {
        if (!this.rows[i].file) {
          this.showAlert(`${i + 1}行目のファイルを選択してください。`);
          return;
        }
      }

      if (!this.outputPassword) {
        this.showAlert("出力証明書パスワードは必須です。");
        return;
      }
      if (this.outputPassword !== this.outputPasswordConfirm) {
        this.showAlert("出力証明書パスワードが一致しません。");
        return;
      }

      const formData = new FormData();
      this.rows.forEach(row => {
        formData.append("files", row.file);
        formData.append("passwords", row.password || "");
      });
      formData.append("outputPassword", this.outputPassword || "");

      this.setLoadingScreenVisible(true);
      try {
        const xsrfToken = this.getCookie("XSRF-TOKEN");
        const headers = { "Content-Type": "multipart/form-data" };
        if (xsrfToken) {
          headers["X-XSRF-TOKEN"] = xsrfToken;
        }

        const response = await axios.post(
          "/ntss-certificate-download/api/cl-download/mergeP12",
          formData,
          { headers, responseType: "blob" }
        );

        // レスポンスの blob をブラウザでファイルとしてダウンロードする
        const disposition = response.headers["content-disposition"] || "";
        const match = disposition.match(/filename=(.+)/);
        const fileName = match ? match[1] : "client_merged.p12";
        const url = URL.createObjectURL(new Blob([response.data]));
        const link = document.createElement("a");
        link.href = url;
        link.setAttribute("download", fileName);
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        URL.revokeObjectURL(url);

        this.resetLoadingScreenVisibleCount();
        // ダウンロード完了後、ユーザーに通知してから OK クリック時にログアウトする
        this.$ons.notification.alert({
          title: "ダウンロード完了",
          message: "証明書のダウンロードが完了しました。\nブラウザのダウンロード履歴からご確認ください。\nOKをクリックするとログアウトします。",
          callback: async () => {
            await this.signOut();
            router.push({ name: "clDownloadLogin" });
          }
        });
      } catch (e) {
        this.resetLoadingScreenVisibleCount();
        this.showAlert(
          "証明書の生成に失敗しました。パスワードまたはファイルを確認してください。"
        );
      }
    }
  }
};
</script>

<style scoped>
* {
  box-sizing: border-box;
}

.p12-merge-page {
  text-align: center;
  font-size: large;
  height: 100%;
  margin: 0;
  width: 100%;
  background-color: rgb(240, 242, 243);
  overflow: auto;
  padding: 16px;
}

.merge-title {
  padding: 40px 0 20px;
  width: 100%;
  float: left;
  font-size: 1.5em;
  font-weight: bold;
}

.main-container {
  width: 100%;
  float: left;
}

.form-container {
  padding: 24px 20px;
  background-color: white;
  width: 60%;
  margin: 0 auto;
  border-radius: 20px;
}

.description {
  color: #555;
  font-size: 0.9em;
  margin-bottom: 20px;
  line-height: 1.6;
}

.info-box {
  background-color: #e8f4fd;
  border: 1px solid #b8d9f3;
  border-radius: 6px;
  padding: 10px 14px;
  margin-bottom: 16px;
  font-size: 0.85em;
  color: #1a5f9a;
  text-align: left;
  line-height: 1.7;
}

.info-icon {
  font-style: normal;
  font-weight: bold;
  margin-right: 6px;
}

.section-label {
  font-weight: bold;
  margin-bottom: 10px;
  text-align: left;
  padding-left: 4px;
}

.file-rows {
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-bottom: 12px;
}

.file-row {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 10px;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  background: #fafafa;
}

.file-input-hidden {
  display: none;
}

.file-label {
  flex: 1;
  display: flex;
  align-items: center;
  cursor: pointer;
  height: 34px;
  padding: 0 10px;
  border: 1px solid #ccc;
  border-radius: 4px;
  background: white;
  font-size: 0.9em;
  color: #555;
  overflow: hidden;
  white-space: nowrap;
  text-overflow: ellipsis;
  min-width: 0;
  box-sizing: border-box;
}

.file-label:hover {
  border-color: #888;
}

.password-input {
  width: 180px;
  height: 34px;
  padding: 0 10px;
  border: 1px solid #ccc;
  border-radius: 4px;
  font-size: 0.9em;
  box-sizing: border-box;
}

.btn-remove {
  height: 34px;
  margin: 0;
  padding: 0 12px;
  font-size: 0.9em;
  white-space: nowrap;
  box-sizing: border-box;
  line-height: 20px;
  vertical-align: middle;
}

.add-row-area {
  text-align: left;
  margin-bottom: 20px;
}

.btn-add {
  margin: 0;
  font-size: 0.9em;
}

.output-group {
  display: inline-flex;
  flex-direction: column;
  gap: 10px;
  padding: 12px 4px;
  border-top: 1px solid #eee;
  width: 100%;
  align-items: center;
}

.output-area {
  display: flex;
  align-items: center;
  gap: 12px;
}

.output-label {
  width: 220px;
  text-align: right;
  font-size: 0.9em;
  white-space: nowrap;
  color: #333;
  flex-shrink: 0;
}

.output-password-input {
  width: 320px;
}

.required {
  color: red;
}

.panel {
  margin: 0 auto;
  width: 80%;
}

.button {
  margin: 16px 0 8px;
  padding: 8px 20px;
  cursor: pointer;
}

.btn-back {
  margin-top: 8px;
  margin-right: 12px;
}

.btn-merge {
  margin-top: 8px;
}

ons-col {
  width: inherit;
  margin: 10px;
}

@media only screen and (max-width: 480px) {
  .p12-merge-page {
    padding: 0;
  }

  .merge-title {
    padding: 20px 0;
    font-size: 1em;
  }

  .form-container {
    width: 100%;
    border-radius: 0;
  }

  .file-row {
    flex-wrap: wrap;
  }

  .file-label {
    flex: 0 0 100%;
  }

  .password-input {
    width: 100%;
  }

  .btn-remove {
    width: 100%;
  }

  .output-group {
    align-items: flex-start;
  }

  .output-area {
    flex-direction: column;
    align-items: flex-start;
  }

  .output-label {
    width: auto;
    text-align: left;
  }

  .output-area .password-input {
    width: 100%;
  }
}
</style>
