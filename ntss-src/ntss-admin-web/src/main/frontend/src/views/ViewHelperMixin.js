/**
 * 画面分割コンポーネント用共通補助機能
 */
export default {
  provide() {
    return {
      getNtssMainComponent: () => this.getMainComponent(),
      callNtssMainComponent: (methodName, ...args) =>
        this.callMainComponentMethod(methodName, ...args)
    };
  },
  methods: {
    getMainComponent() {
      return this.$refs.mainComponent ?? null;
    },
    callMainComponentMethod(methodName, ...args) {
      const main = this.getMainComponent();
      if (!main || typeof main[methodName] !== "function") {
        return undefined;
      }
      return main[methodName](...args);
    },
    // リフレッシュ処理（パンくずリストクリック時の画面再描画）
    refresh() {
      this.callMainComponentMethod("refresh");
    }
  }
};
