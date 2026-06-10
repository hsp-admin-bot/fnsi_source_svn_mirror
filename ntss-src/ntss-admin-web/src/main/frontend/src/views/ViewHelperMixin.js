/**
 * 画面分割コンポーネント用共通補助機能
 */
export default {
  methods: {
    // リフレッシュ処理（パンくずリストクリック時の画面再描画）
    refresh() {
      if (this.$refs.mainComponent && typeof this.$refs.mainComponent.refresh === "function") {
        this.$refs.mainComponent.refresh();
      }
    }
  }
};
