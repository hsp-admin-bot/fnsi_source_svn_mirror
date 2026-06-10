<template>
  <div id="app">
    <router-view />
  </div>
</template>

<script>
import { mapGetters, mapActions } from "vuex";

export default {
  name: "app",
  computed: {
    ...mapGetters("account-edit", ["getTheme", "getFontSize"]),

    fontSizeSet() {
      const names = ["small", "medium", "large", "x-large"];
      return "font-size-set-" + names[this.getFontSize];
    }
  },
  watch: {
    getTheme() {
      this.readThemeCss();
    }
  },
  methods: {
    ...mapActions("window-size", ["setSize"]),
    // Windowリサイズイベントハンドラ
    handleResizeWindow() {
      // Windowリサイズ時、幅をStoreに格納
      this.setSize({
        windowHeight: document.documentElement.clientHeight,
        windowWidth: document.documentElement.clientWidth
      });

      // Windowリサイズ時、パンくずリストを右に寄せる
      this.$nextTick(() => {
        document.querySelectorAll(".breadcrumb-content").forEach(e => {
          e.scrollLeft = 1000;
        });
      });
    },

    // cssファイル読み込み
    readCss() {
      let ntssCss = document.createElement("link");
      ntssCss.rel = "stylesheet";
      ntssCss.href = "./css/ntss.css";
      document.head.appendChild(ntssCss);
    },

    // 印刷用cssファイル読み込み
    readPrintCss() {
      let ntssCss = document.createElement("link");
      ntssCss.rel = "stylesheet";
      ntssCss.media = "print";
      ntssCss.href = "./css/ntss_print.css";
      document.head.appendChild(ntssCss);
    },

    // themeのcssファイル読み込み
    readThemeCss() {
      const names = ["ntss_variables_w", "ntss_variables_b"];
      let themeCss = document.createElement("link");
      themeCss.rel = "stylesheet";
      themeCss.href = "./css/" + names[this.getTheme] + ".css";
      document.head.appendChild(themeCss);
    },
    // 各input要素にreadonly属性を設定
    setInputReadOnly(elem, flag) {
      const isInput = elem.tagName === "INPUT";
      const isInputTypeValid = [
        "date",
        "time",
        "number",
        "datetime-local"
      ].includes(elem.type);

      if (!isInput || !isInputTypeValid) return;

      const arrInput = [...document.getElementsByTagName("input")];
      const arrText = [...document.getElementsByTagName("textarea")];

      arrInput.map(item => (item.readOnly = item !== elem ? flag : false));
      arrText.map(item => (item.readOnly = flag));
    }
  },
  created() {
    window.addEventListener("resize", this.handleResizeWindow, false);
    
    // cssファイルを読み込む
    this.readCss();
    this.readPrintCss();
    this.readThemeCss();
  },
  mounted() {
    // 初期Windowサイズ(幅)設定
    this.$nextTick(() => {
      if (
        window.performance.navigation.type ===
        window.performance.navigation.TYPE_RELOAD
      ) {
        // リロード対策：DOM生成やCSSロードより後に高さの調整を遅延させる。
        this.setSize({
          windowHeight: document.documentElement.clientHeight - 100,
          windowWidth: document.documentElement.clientWidth
        });
      }
      setTimeout(() => {
        this.handleResizeWindow();
      }, 200);
    })

    // 入力フォカスアウト対策:onFocus時に編集対象以外の各input要素のreadonly属性をONにする
    window.addEventListener(
      "focus",
      e => {
        this.setInputReadOnly(e.target, true);
      },
      true
    );

    // 入力フォカスアウト対策:onBlur時に各input要素のreadonly属性をOFFにする
    window.addEventListener(
      "blur",
      e => {
        this.setInputReadOnly(e.target, false);
      },
      true
    );
  }
};
</script>

<style>
#app {
  margin: 0;
  padding: 0;
  width: 100%;
  height: 100%;
  /*add FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start*/
  overflow: auto;
  /*add FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 end*/
}
</style>
