/**
 * 共通Mixin.
 */
export default {
  data() {
    return {
      lastScrollTop: 0,
      lastScrollLeft: 0
    };
  },
  methods: {
    /**
     * KendoGridデータバインド時イベントハンドラ.
     * 値変更時にスクロール位置が先頭に戻ってしまう問題の対処
     *
     * @param {*} ev イベント
     */
    onDataBoundKendoGrid(ev) {
      // スクロール位置が先頭でない場合、その位置を保持する
      const scrollTop = ev.sender.content[0].scrollTop;
      const scrollLeft = ev.sender.content[0].scrollLeft;
      if (scrollTop != 0) {
        this.lastScrollTop = scrollTop;
      }
      if (scrollLeft != 0) {
        this.lastScrollLeft = scrollLeft;
      }

      if (this.lastScrollTop != 0 || this.lastScrollLeft != 0) {
        this.$nextTick(() => {
          ev.sender.content[0].scrollTop = this.lastScrollTop;
          ev.sender.content[0].scrollLeft = this.lastScrollLeft;
          setTimeout(() => {
            this.lastScrollTop = 0;
            this.lastScrollLeft = 0;
          }, 1000);
        });
      }
    }
  }
};
