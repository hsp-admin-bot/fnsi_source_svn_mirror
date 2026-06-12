import { h, resolveComponent } from "@/compat/vue/runtime";
import { mapActions, mapGetters } from "@/compat/vue/vuex";
// add メッセージダイアログのデフォルトボタン（OK 等）フォーカス対応 start
import { focusAlertDialogDefaultButton, getOnsAlertDialogElement } from "@/compat/onsen/dialog";
// add メッセージダイアログのデフォルトボタン（OK 等）フォーカス対応 end

export default {
  name: "GlobalOnsAlertDialog",
  computed: {
    ...mapGetters("account-edit", ["getFontSize"]),
    ...mapGetters("app", ["getOnsDialog"]),
    fontSizeSet() {
      const names = ["small", "medium", "large", "x-large"];
      return "font-size-set-" + names[this.getFontSize];
    }
  },
  methods: {
    ...mapActions("app", ["dismissOnsAlert", "confirmOnsDialog", "cancelOnsDialog"]),
    getDialogButtonLabels() {
      const labels = this.getOnsDialog.buttonLabels;
      if (Array.isArray(labels) && labels.length > 0) {
        return labels;
      }
      return this.getOnsDialog.mode === "confirm" ? ["キャンセル", "OK"] : ["OK"];
    },
    handleOnsDialogVisibility(visible) {
      if (visible) {
        return;
      }
      if (this.getOnsDialog.mode === "confirm") {
        this.cancelOnsDialog(0);
        return;
      }
      this.dismissOnsAlert();
    },
    handleOnsDialogButtonClick(index) {
      if (this.getOnsDialog.mode === "confirm") {
        if (index === 0) {
          this.cancelOnsDialog(index);
          return;
        }
        this.confirmOnsDialog(index);
        return;
      }
      this.dismissOnsAlert();
    },
    /**
     * ダイアログ表示完了後、デフォルトボタン（OK 等）を選択状態にする。
     * $ons.notification.alert / confirm（DialogMessages 経由の 12000004、12000014 等）で使用。
     */
    focusDefaultButton() {
      const buttonLabels = this.getDialogButtonLabels();
      // confirm 時は最後のボタン（OK）、alert 時は唯一のボタン（OK）をデフォルト選択
      const options = { primaryButtonIndex: buttonLabels.length - 1 };
      this.$nextTick(() => {
        // $el 自身が ons-alert-dialog のため querySelector ではなく getOnsAlertDialogElement を使用
        focusAlertDialogDefaultButton(getOnsAlertDialogElement(this.$el), options);
      });
    }
  },
  render() {
    if (!this.getOnsDialog.visible) {
      return null;
    }
    const AlertDialog = resolveComponent("v-ons-alert-dialog");
    const AlertDialogButton = resolveComponent("v-ons-alert-dialog-button");
    const buttonLabels = this.getDialogButtonLabels();
    // 2 ボタン以上は横並び（旧 ons / v-ons-alert-dialog modifier="rowfooter" と同様。3 択「1」「2」「3」含む）
    const useRowFooter = buttonLabels.length > 1;
    const dialogModifier = [
      this.getOnsDialog.modifier,
      useRowFooter ? "rowfooter" : ""
    ].filter(Boolean).join(" ") || undefined;
    const footerChildren = buttonLabels.map((label, index) => h(
      AlertDialogButton,
      {
        modifier: [
          // 最後のボタン（OK 等）をプライマリ表示・デフォルト選択対象とする
          index === buttonLabels.length - 1 ? "primal" : "",
          useRowFooter ? "rowfooter" : ""
        ].filter(Boolean).join(" "),
        onClick: () => this.handleOnsDialogButtonClick(index)
      },
      { default: () => label }
    ));

    return h(
      AlertDialog,
      {
        // 閉じるとき resetOnsDialog で本文が先に空＋alert/OK になり、同一要素に visible:false が届くまでの一瞬が画面に出るのを避けるため、
        // visible の間だけマウントする（閉じたら null でアンマウント）。
        visible: true,
        "onUpdate:visible": this.handleOnsDialogVisibility,
        cancelable:
          this.getOnsDialog.mode === "confirm"
            ? this.getOnsDialog.cancelable !== false
            : false,
        // App.vue observeAlertDialog の handleAlertDialog は従来フッター用の <a> を差し込む。
        // Vuex 共通ダイアログは v-ons-alert-dialog-button のため、その改変を避ける（閉じた後の空白枠防止）。
        class: [this.fontSizeSet, "ntss-global-ons-dialog", this.getOnsDialog.dialogClass].filter(Boolean),
        animation: "default",
        modifier: dialogModifier,
        // 表示アニメーション完了後に OK をデフォルト選択（App.vue の observeAlertDialog は対象外）
        onPostshow: () => this.focusDefaultButton()
      },
      {
        title: () => this.getOnsDialog.title || "",
        default: () => h("span", {
          innerHTML: this.getOnsDialog.message || this.getOnsDialog.messageHTML || ""
        }),
        footer: () => footerChildren
      }
    );
  }
};
