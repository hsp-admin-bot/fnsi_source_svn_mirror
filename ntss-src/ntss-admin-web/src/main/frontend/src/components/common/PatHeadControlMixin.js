/**
 * 患者ヘッダーに指定の患者をセットする用のMixin
 * mapMutations使わないもっといい方法がないか
 */
import { mapActions } from "@/compat/vue/vuex";

export default {
  methods: {
    ...mapActions("loading-screen", [
      "setLoadingScreenMessage",
      "setLoadingScreenVisible"
    ]),
    ...mapActions("pat-info", {
      selectPatToHeader: "selectPat",
      clearSelectedPatToHeader: "clearSelectedPat",
      setIsNullPat: "setIsNullPat"
    }),
    /**
     * @description 患者選択
     * @summary 選択した患者の患者情報レコードをストアに格納する
     * @param {Number} selectedPatId 患者ＩＤ
     */
    async setSelectedPatHeader(selectedPatId) {
      this.setLoadingScreenMessage("処理中・・・");
      this.setLoadingScreenVisible(true);
      try {
        await this.clearSelectedPatToHeader();
        if (selectedPatId === null) {
          // ？？？？患者
          await this.setIsNullPat(true);
        } else {
          await this.selectPatToHeader(selectedPatId);
        }
      } catch {
        // TODO: エラー処理ちゃんと考える
        throw new Error("[PatHeader.vue]setSelectedPat(): 患者選択失敗");
      } finally {
        this.setLoadingScreenVisible(false);
      }
    },

    /**
     * 患者情報ヘッダーの初期化
     */
    async resetSelectedPatHeader() {
      this.setLoadingScreenMessage("処理中・・・");
      this.setLoadingScreenVisible(true);
      this.clearSelectedPatToHeader().finally(() => {
        this.setLoadingScreenVisible(false);
      });
    }
  }
};
