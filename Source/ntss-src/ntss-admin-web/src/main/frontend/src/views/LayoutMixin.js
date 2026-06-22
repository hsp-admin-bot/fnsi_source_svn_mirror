/**
 * レイアウト用Viewコンポーネント用共通処理
 */
import { mapGetters } from "@/compat/vue/vuex";
import { getFooterMenuElement, getViewportHeight } from "@/functions/common/LayoutMeasureHelper";
import { EventBus } from "@/compat/vue/event-bus.js";
export default {
  data() {
    return {
      // 子コンポーネント領域の高さ
      mainHeight: 0
    };
  },
  methods: {
    // フッターメニューの高さから子コンポーネント領域の高さを算出
    calculateMainHeight() {
      const wh = Number(this.windowHeight) || getViewportHeight(this.$el || this);
      // mod bug 5555 修正 chen start
      // mod #10225 処方薬剤選択に一般名処方が表示しない。yqz start
      const hh = this.$refs.header?.clientHeight;
      // mod #10225 処方薬剤選択に一般名処方が表示しない。yqz end

      // ヘッダーの高さ
      let hhTmp = 0;
      if (this.isWeightMode) {
        // 体重計モード時のヘッダーの高さ (体重計モードは独自css等でntss.cssの指定をあれこれ上書きしている)

        if (this.getFontSize + "" === "0") {
          // 文字サイズ小：8px × 12.5em
          hhTmp = 100;
        } else if (this.getFontSize + "" === "1") {
          // 文字サイズ中：10px × 12.5em
          hhTmp = 125;
        } else if (this.getFontSize + "" === "2") {
          // 文字サイズ大：11px × 12.5em
          hhTmp = 137.5;
        } else if (this.getFontSize + "" === "3") {
          // 文字サイズ特大：13px × 12.5em
          hhTmp = 162.5;
        }

      } else {
        // 通常モード時のヘッダーの高さ
        if (this.getFontSize + "" === "0") {
          hhTmp = 85;
        } else if (this.getFontSize + "" === "1") {
          hhTmp = 97;
        } else if (this.getFontSize + "" === "2") {
          hhTmp = 104;
        } else if (this.getFontSize + "" === "3") {
          hhTmp = 115;
        }
      }

      const fh =
        this.isDispMenu === 1
          ? (getFooterMenuElement(this.$el || this)?.clientHeight || 0)
          : 0;
      if (hh !== 0) {
        // 実際のヘッダー高さを優先し、取得できない場合のみ従来の推定値を利用
        this.mainHeight = wh - (Number(hh) || hhTmp) - fh;
      } else {
        this.mainHeight = wh - fh;
      }
      // mod bug 5555 修正 chen end
    }
  },
  computed: {
    ...mapGetters("window-size", {
      // 分割された画面の高さ取得
      windowHeight: "getWindowHeight"
    }),
    ...mapGetters("account-edit", ["isDispMenu", "getFontSize"]),
    ...mapGetters("send-condition/weight", ["getWeightMode"]),
    // 体重計モードかどうか
    isWeightMode() {
      if (this.getWeightMode) {
        return this.getWeightMode.isWeightMode;
      }
      return false;
    },
    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.mainHeight}px` };
    }
  },
  watch: {
    windowHeight() {
      this.calculateMainHeight();
    },
    isDispMenu() {
      this.calculateMainHeight();
    },
    getFontSize() {
      this.calculateMainHeight();
    }
  },
  mounted() {
    EventBus.$on("calculateMainHeight", this.calculateMainHeight);
    this.$nextTick(() => {
      this.calculateMainHeight();
    });
  },
  beforeDestroy() {
    EventBus.$off("calculateMainHeight", this.calculateMainHeight);
  }
};
