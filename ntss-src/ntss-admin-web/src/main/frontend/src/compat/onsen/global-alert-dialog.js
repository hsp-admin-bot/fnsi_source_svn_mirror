import { h, resolveComponent } from "@/compat/vue/runtime";
import { mapActions, mapGetters } from "@/compat/vue/vuex";

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
          index === buttonLabels.length - 1 ? "primal" : "",
          useRowFooter ? "rowfooter" : ""
        ].filter(Boolean).join(" "),
        autofocus: index === buttonLabels.length - 1,
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
        modifier: dialogModifier
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
