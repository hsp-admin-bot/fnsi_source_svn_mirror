/**
 * ポップオーバー用Mixin.
 */
import { mapGetters } from "@/compat/vue/vuex";

export default {
  computed: {
    ...mapGetters("account-edit", {
      getFontSize: "getFontSize"
    }),
    /**
     * フォントサイズに応じたCSSセレクタを返す.
     */
    fontSizeSet() {
      const names = ["small", "medium", "large", "x-large"];
      return "font-size-set-" + names[this.getFontSize];
    }
  }
};
