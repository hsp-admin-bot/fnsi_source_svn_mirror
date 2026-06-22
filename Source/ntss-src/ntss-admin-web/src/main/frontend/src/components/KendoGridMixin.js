/**
 * 共通Mixin.
 */
import { captureKendoGridScrollPosition, restoreKendoGridScrollPosition } from "@/functions/common/KendoFunctions";

export default {
  data() {
    return {
      lastScrollTop: 0,
      lastScrollLeft: 0,
      onDataisAddRow:false
    }
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
      const position = captureKendoGridScrollPosition(ev?.sender || ev);
      const scrollTop = position.top;
      const scrollLeft = position.left;
      if (scrollTop != 0) {
        this.lastScrollTop = scrollTop;
      }
      if (scrollLeft != 0) {
        this.lastScrollLeft = scrollLeft;
      }

      if (this.lastScrollTop != 0 || this.lastScrollLeft != 0) {
        this.$nextTick(() => {
          restoreKendoGridScrollPosition(ev?.sender || ev, {
            top: this.lastScrollTop,
            left: this.lastScrollLeft
          });
          setTimeout(() => {
            this.lastScrollTop = 0;
            this.lastScrollLeft = 0;
          }, 1000)
        });
      }
    },
    //スクロールバーの追加
    onDataAppendKendoGrid(ev) {
      if(this.onDataisAddRow){
        requestAnimationFrame(() => {
          const content = ev.sender.content[0];
          content.scrollTop = content.scrollHeight;
          this.onDataisAddRow = false
        });
      }
      
    },
    // add マスタ性能の改善 孔 start
    onDataBoundKendoGridVirtual(ev) {
      // スクロール位置が先頭でない場合、その位置を保持する
      const position = captureKendoGridScrollPosition(ev?.sender || ev, { virtual: true });
      const scrollTop = position.top;
      const scrollLeft = position.left;
      if (scrollTop != 0) {
        this.lastScrollTop = scrollTop;
      }
      if (scrollLeft != 0) {
        this.lastScrollLeft = scrollLeft;
      }

      if (this.lastScrollTop != 0 || this.lastScrollLeft != 0) {
        this.$nextTick(() => {
          restoreKendoGridScrollPosition(ev?.sender || ev, {
            top: this.lastScrollTop,
            left: this.lastScrollLeft
          }, { virtual: true });
          setTimeout(() => {
            this.lastScrollTop = 0;
            this.lastScrollLeft = 0;
          }, 1000)
        });
      }
    }
    // add マスタ性能の改善 孔 end
  }
}
