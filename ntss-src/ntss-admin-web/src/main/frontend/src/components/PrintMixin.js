/**
 * 画面印刷共通Mixin.
 */
import Highcharts, { Boost } from "@/compat/charts/highcharts";
import { EventBus } from "@/compat/vue/event-bus.js";

Boost(Highcharts);

export default {
  data() {
    return {
      // --- 各コンポーネントでこれらを上書きしてカスタマイズ ---
      /** グラフ調整変数群 */
      /** 横幅 */
      printTargetClass: [], // デフォルトの横幅指定するクラス名 配列で複数指定可能 各画面から指定する場合の例：["list-content"]
      printFixedWidth: "1024px", // デフォルトの固定幅

      /** 横スクロール右端調整用変数群 */
      scrollQuerySelector: "", // スクロール範囲のクエリセレクタ 各画面から指定する場合の例：".main"、"#wrapper"
      addClassTargetQuerySelector: [], // scroll-rightmostクラスを付与する対象のクエリセレクタ 配列で複数指定可能 各画面から指定する場合の例：[".list-content","#table"]
      // ---------------------------------------------------

      // 画面印刷中かのフラグ
      isPrint: false
    };
  },
  computed: {
    // content-containerに倍率調整用のscroll-adjustzoomクラスを付与するかのフラグ 各画面でcomputedを上書きして使用
    adjustZoom() {
      return false; // デフォルト
    }
  },
  created() {
    EventBus.$off("printing", this._handlePrinting);
    EventBus.$off("print-end", this._handlePrintEnd);
    EventBus.$on("printing", this._handlePrinting);
    EventBus.$on("print-end", this._handlePrintEnd);
  },
  mounted() {
    window.addEventListener("beforeprint", this._handleBeforePrintInternal);
    window.addEventListener("afterprint", this._handleAfterPrintInternal);
    
    this.shouldResizeWidth = this.printTargetClass && this.printTargetClass.length > 0;

    window.addEventListener("beforeprint", this._handleBeforePrintScroll);
    window.addEventListener("afterprint", this._handleAfterPrintScroll);
  },
  beforeUnmount() {
    window.removeEventListener("beforeprint", this._handleBeforePrintInternal);
    window.removeEventListener("afterprint", this._handleAfterPrintInternal);

    window.removeEventListener("beforeprint", this._handleBeforePrintScroll);
    window.removeEventListener("afterprint", this._handleAfterPrintScroll);

    EventBus.$off("printing", this._handlePrinting);
    EventBus.$off("print-end", this._handlePrintEnd);
  },
  methods: {
    _handleBeforePrintInternal() {
      /** グラフサイズ調整 */
      if (this.shouldResizeWidth) {
        // 1. 指定されたクラス名の要素をすべて取得
        const selector = this.printTargetClass
          .map(c => `.${c}`)
          .join(",");
        const elements = document.querySelectorAll(selector);
        
        elements.forEach((el) => {
          // 幅を固定
          el.style.setProperty("width", this.printFixedWidth, "important");
        });
        // 2. 画面に表示されている全グラフをreflow
        if (Highcharts && Highcharts.charts) {
          Highcharts.charts.forEach(chart => chart?.reflow());
        }
      }
    },

    _handleAfterPrintInternal() {
      /** グラフサイズ調整 */
      if (this.shouldResizeWidth) {
        // 1. 幅を元に戻す
        const selector = this.printTargetClass
          .map(c => `.${c}`)
          .join(",");
        const elements = document.querySelectorAll(selector);
        elements.forEach((el) => {
          el.style.width = "100%";
        });
        // 2. 画面に表示されている全グラフをreflow
        if (Highcharts && Highcharts.charts) {
          Highcharts.charts.forEach(chart => chart?.reflow());
        }
      }
    },

    _handleBeforePrintScroll() {
      if (!this.scrollQuerySelector || !this.addClassTargetQuerySelector || !this.addClassTargetQuerySelector.length) return;
      this.addScrollClass(this.scrollQuerySelector, this.addClassTargetQuerySelector);
    },

    _handleAfterPrintScroll() {
      if (!this.scrollQuerySelector || !this.addClassTargetQuerySelector || !this.addClassTargetQuerySelector.length) return;
      this.removeScrollClass(this.addClassTargetQuerySelector);
    },
    
    /** 横スクロール右端調整用クラスの付与 */
    addScrollClass(scrollSelector, targetSelectors) {
      const scroll = document.querySelector(scrollSelector);

      // content-containerに倍率調整用のscroll-adjustzoomクラス付与 ※ntss_print.cssで倍率調整
      if (this.adjustZoom) {
        if (!scroll) return;
        // スクロールバーなしは何もしない
        const hasHorizontalScrollbar = scroll.scrollWidth > scroll.clientWidth;
        if (!hasHorizontalScrollbar) return;
        const container = document.querySelector(".content-container");
        container.classList.add('scroll-adjustzoom');
      }
      
      // スクロール範囲と右端時用のクラスを付与する対象を取得
      if (!scroll || !scroll.scrollLeft) return;
      // スクロール範囲より現在の横スクロール割合を算出
      const scrollRange = scroll.scrollWidth - scroll.clientWidth;
      if (0 >= scrollRange) return;
      const percent = scroll.scrollLeft / scrollRange;
      // 横スクロール位置が全体の99%を超えている場合は対象に右端時用クラスを付与(ntss_print参照、必要に応じて各画面のstyleで上書きの上調整必須)
      if (percent > 0.99) {
        const selector = targetSelectors.join(',');
        const elements = document.querySelectorAll(selector);
        elements.forEach((el) => {
          el.classList.add('scroll-rightmost');
        });
      }
    },
    
    /** 印刷前に付与したクラスを削除 */
    removeScrollClass(targetSelectors) {
      if (this.adjustZoom) {
        const container = document.querySelector(".content-container");
        container.classList.remove('scroll-adjustzoom');
      }
      
      const selector = targetSelectors.join(',');
      const elements = document.querySelectorAll(selector);
      elements.forEach((el) => {
        el.classList.remove('scroll-rightmost');
      });
    },

    _handlePrinting() {
      this.isPrint = true;
    },
    _handlePrintEnd() {
      // RootView.vueのprintStart()でフォントサイズを強制で中に変更するので、watchの処理が走らないようにnextTick使用
      this.$nextTick(() => {
        this.isPrint = false;
      });
    }
  }
}
