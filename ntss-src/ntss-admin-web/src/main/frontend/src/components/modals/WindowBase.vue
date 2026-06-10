/**
 * ModalPageレイアウト
 */
<template>
  <kendo-dialogs
    v-if="visible"
    :title="title"
    :left="left"
    :top="top"
    :width="width"
    :height="height"
    :stage="stage"
    @move="handleMove"
    @resize="handleResize"
    @close="toggleDialog"
    @stagechange="stagechange"
    class="kendo-dialogs"
  >
    <slot name="body"></slot>
    <slot name="footer"></slot>
  </kendo-dialogs>
</template>

<script>
import { mapState, mapGetters } from "vuex";
import "@progress/kendo-theme-bootstrap/dist/all.css";
import { Window } from "@progress/kendo-vue-dialogs";

export default {
  components: {
    "kendo-dialogs": Window
  },

  data() {
    return {
      left: 0,
      top: 0,
      width: 0,
      height: 0,
//add 8312 2023-02-20 17：30 投薬支援の子画面のサイズをウィンドウ外まで大きくすることができ操作不能となる 張 start
      // initwidth: 0,
      // initheight: 0,
      windowsizeFlag: false,
//add 8312 2023-02-20 17：30 投薬支援の子画面のサイズをウィンドウ外まで大きくすることができ操作不能となる 張 end
      visible: true,
      stage: "DEFAULT",
// add FNSI-redmine#8312 高 start
      nowLeft: 0,
      oldLeft: 0,
      oldWidth: 0,
      // #8312 投薬支援の子画面のサイズをウィンドウ外まで大きくすることができ操作不能となる 訾浩 start
      clientX: null,
      monitorTop: null,
      monitorTopFlag: true
      // #8312 投薬支援の子画面のサイズをウィンドウ外まで大きくすることができ操作不能となる 訾浩 end
// add FNSI-redmine#8312 高 end
    };
  },
  props: {
    setting: {
      type: Object
    },
    title: {
      type: String,
      default: ""
    },
    onClose: {
      type: Function
    },
    showFooter: {
      type: Boolean,
      default: true
    }
  },
  computed: {
    ...mapState("multi-modal", ["modalTitle"]),
    ...mapGetters("account-edit", [
      "getFontSize"
    ]),
//add 8312 2023-02-20 17：30 投薬支援の子画面のサイズをウィンドウ外まで大きくすることができ操作不能となる 張 start
         ...mapGetters("window-size", {windowWidth : "getWindowWidth",windowHeight: "getWindowHeight"}),
////add 8312 2023-02-20 17：30 投薬支援の子画面のサイズをウィンドウ外まで大きくすることができ操作不能となる 張 end
    selectedFontSize: {
      get() {
        return this.getFontSize;
      }
    },
  },
  methods: {
    stagechange (event,t,s) {
      // 表示、非表示を行わないと、top の値が内部的に反映されない為、一度非表示にする
      this.visible = false;
      if (s.state === "FULLSCREEN") {
        this.stage = "DEFAULT";
        this.handleResize({
          left: 0,
          top: 100,
          width: window.innerWidth,
          height: (window.innerHeight - 100)
        });
      } else if (s.state === "DEFAULT") {
        this.stage = "DEFAULT";
        this.handleResize({
          left: this.setting.left,
          top: this.setting.top < 100 ? 100 : this.setting.top,
          width: this.setting.width,
          height: this.setting.height,
        });
      } else if (s.state === "MINIMIZED") {
        this.stage = "MINIMIZED";
        this.handleResize({
          left: this.setting.left,
          top: this.setting.top < 100 ? 100 : this.setting.top,
          width: this.setting.width,
          height: this.setting.height,
        });
      }
    },
    handleMove (event) {
//add 8312 2023-02-20 17：30 投薬支援の子画面のサイズをウィンドウ外まで大きくすることができ操作不能となる 張 start
      if (this.windowsizeFlag) {
        event.left = this.left;
        event.top = this.top;
        event.width = this.width;
        event.height = this.height;
        this.windowsizeFlag = false;
      } else {
        if (event.width > event.target.width) {
          event.width = event.target.width;
        }
        if (event.height > event.target.height) {
          event.height = event.target.height;
        }
        // #8312 投薬支援の子画面のサイズをウィンドウ外まで大きくすることができ操作不能となる 訾浩 start
        if (event.left >= this.windowWidth - this.width) {
          event.left = this.windowWidth - this.width;
        }
        // #8312 投薬支援の子画面のサイズをウィンドウ外まで大きくすることができ操作不能となる 訾浩 end
        if (event.top > this.windowHeight - event.height) {
          event.top = this.windowHeight - event.height;
        }
        if (event.left < 1) {
          event.left = 1;
          if (this.windowWidth < 300) {
            event.width = this.windowWidth - 1;
          }
        }
        if (event.top < 1) {
          event.top = 1;
          if (this.windowHeight < 100) {
            event.height = this.windowHeight - 1;
          }
        }
        if (event.width < 300) {
          if (this.windowWidth < 300) {
            event.width = this.windowWidth - 1;
            event.left = 1;
          } else {
            event.width = 300;
          }
        }
        if (event.height < 100) {
          if (this.windowHeight < 100) {
            event.height = this.windowHeight - 1;
            event.top = 1;
          } else {
            event.height = 100;
          }
        }
      }
      this.width = event.width;
      this.height = event.height;
      this.setting.width = this.width;
      this.setting.height = this.height;
//add 8312 2023-02-20 17：30 投薬支援の子画面のサイズをウィンドウ外まで大きくすることができ操作不能となる 張 end
      this.left = event.left;
      this.top = event.top

      this.setting.left = this.left;
      this.setting.top = this.top;
      // add FNSI-redmine#8312 高 start
      this.nowLeft = this.left;
      // add FNSI-redmine#8312 高 end
    },

    handleResize (event) {
      // #8312 投薬支援の子画面のサイズをウィンドウ外まで大きくすることができ操作不能となる 訾浩 start
      this.monitorTop = event.top
      // add FNSI-redmine#8312 高 start
      if (event.left < 2 && !this.monitorTopFlag) {
        // #8312 投薬支援の子画面のサイズをウィンドウ外まで大きくすることができ操作不能となる 訾浩 start
        this.windowsizeFlag = false
      //   // #8312 投薬支援の子画面のサイズをウィンドウ外まで大きくすることができ操作不能となる 訾浩 end
      } else if (event.left < 2 && this.monitorTopFlag) {
        this.windowsizeFlag = true;
      }
       else {
        // #8312 投薬支援の子画面のサイズをウィンドウ外まで大きくすることができ操作不能となる 訾浩 end
        this.windowsizeFlag = false;
      }
      // add FNSI-redmine#8312 高 end
//add 8312 2023-02-20 17：30 投薬支援の子画面のサイズをウィンドウ外まで大きくすることができ操作不能となる 張 start
      if (this.windowsizeFlag) {
      // add FNSI-redmine#8312 高 start
        if(event.left > this.nowLeft ) {
          event.left = this.nowLeft;
        } else {
          event.left = this.left;
        }
      // add FNSI-redmine#8312 高 end
        event.top = this.top;
      // add FNSI-redmine#8312 高 start
        if (event.left < 2 && event.width < 302) {
          event.width = 300;
        } else {
          // #8312 投薬支援の子画面のサイズをウィンドウ外まで大きくすることができ操作不能となる 訾浩 start
          let div = document.querySelector("div");
          div.addEventListener("drag", (params) => {
            this.clientX = params.gesture.center.clientX
          })
          if (this.clientX <= 300 && event.width > 302) {
            event.width = this.width;
              // event.height = this.height
          } else if (event.left > 2 && event.width < 302) {
            event.width = 300;
          } else {
            if (event.width > this.windowWidth) {
              event.width = this.windowWidth - 2
            }
            // this.height = event.height
          }
    // })
        }
      // add FNSI-redmine#8312 高 end
        // event.height = this.height;
        // #8312 投薬支援の子画面のサイズをウィンドウ外まで大きくすることができ操作不能となる 訾浩 end
        this.windowsizeFlag = false;
      } else {
        if (event.left > this.windowWidth - 301) {
          event.left = this.windowWidth - 301;
        }
      // add FNSI-redmine#8312 高 start
        if(event.left > this.nowLeft && this.nowLeft != 1) {
          event.left = this.nowLeft;
        }
      // add FNSI-redmine#8312 高 end
        if (event.top > this.windowHeight - 101) {
          event.top = this.windowHeight - 101;
        }
        if (event.width > this.windowWidth) {
          event.width = this.windowWidth;
          event.left = 1;
        }
        if (event.height > this.windowHeight) {
          event.height = this.windowHeight;
          event.top = 1;
        }
        if (event.left < 1) {
          event.left = 1;
        }
        if (event.top < 1) {
          event.top = 1;
        }
        if (event.width > this.windowWidth - event.left) {
          // #8312 投薬支援の子画面のサイズをウィンドウ外まで大きくすることができ操作不能となる 訾浩 start
          // event.left = 1
          // #8312 投薬支援の子画面のサイズをウィンドウ外まで大きくすることができ操作不能となる 訾浩 end
          event.width = this.windowWidth - event.left;
        }
        if (event.height > this.windowHeight - event.top) {
          event.height = this.windowHeight - event.top;
        }
        if (event.width < 300) {
          if (this.windowWidth < 300) {
            event.width = this.windowWidth - 1;
            event.left = 1;
          } else {
            event.width = 300;
          }
        }
        if (event.height < 100) {
          if (this.windowHeight < 100) {
            event.height = this.windowHeight - 1;
            event.top = 1;
          } else {
            event.height = 100;
          }
        }
      }
      // add FNSI-redmine#8312 高 start
      if (event.left < 2 && event.width < 302) {
        event.width = 300;
      }
      // add FNSI-redmine#8312 高 end
//add 8312 2023-02-20 17：30 投薬支援の子画面のサイズをウィンドウ外まで大きくすることができ操作不能となる 張 end
      this.left = event.left;
      this.top = event.top;
      this.width = event.width;
      this.height = event.height;

      this.setting.left = this.left;
      this.setting.top = this.top;
      this.setting.width = this.width;
      // add FNSI-redmine#8312 高 start
      if (this.width > 300) {
        this.nowLeft = this.left + (this.width - 300);
      } else {
        this.nowLeft = this.left;
        this.oldLeft = this.left;
      }
      if (this.left == this.oldLeft && this.width > 300) {
        this.nowLeft = this.oldLeft;
      }
      // add FNSI-redmine#8312 高 end
      this.$nextTick(() => {
        // 表示、非表示を行わないと、top の値が内部的に反映されない為の対応
        this.visible = true;
      });
      // #8312 投薬支援の子画面のサイズをウィンドウ外まで大きくすることができ操作不能となる 訾浩 start
      this.monitorTopFlag = true
      // #8312 投薬支援の子画面のサイズをウィンドウ外まで大きくすることができ操作不能となる 訾浩 end
    },

    toggleDialog () {
      this.visible = !this.visible;
      if (!this.visible) {
        this.onClose();
      }
    },

    // ヘッダー部に文字サイズの設定を適用する処理
    setTitleFontSize(fontSize) {
      const fSize = ["0.8em", "1em", "1.1em", "1.3em"];
      const kendoObj = document.getElementsByClassName("kendo-dialogs");
      if (kendoObj.length > 0) {
        const titleObj = kendoObj[0].getElementsByClassName("k-window-title");
        for (let tidx = 0; tidx < titleObj.length; tidx++) {
          titleObj[tidx].style.fontSize = fSize[fontSize];
        }
        const iconObj = kendoObj[0].getElementsByClassName("k-icon");
        for (let iidx = 0; iidx < iconObj.length; iidx++) {
          iconObj[iidx].style.fontSize = fSize[fontSize];
        }
      }
    }
  },
  watch:{
    // #8312 投薬支援の子画面のサイズをウィンドウ外まで大きくすることができ操作不能となる 訾浩 start
    monitorTop (val) {
      if (val) {
        this.monitorTopFlag = false
      }
    },
    // #8312 投薬支援の子画面のサイズをウィンドウ外まで大きくすることができ操作不能となる 訾浩 end
    selectedFontSize(val, oldVal) {
      const newZoomVal = this.setting.zoom[val];
      const oldZoomVal = this.setting.zoom[oldVal];
      this.handleResize({
        left: this.setting.left,
        top: this.setting.top,
        width: Math.floor(this.setting.width / oldZoomVal * newZoomVal),
        height: Math.floor(this.setting.height / oldZoomVal * newZoomVal),
      });
      // ヘッダー部に文字サイズの設定を適用
      this.setTitleFontSize(val);
    },
//add 8312 2023-03-07 14：15 投薬支援の子画面のサイズをウィンドウ外まで大きくすることができ操作不能となる 張 start
    windowWidth(newval){
      if (newval < this.width) {
        this.width = newval - 1;
        this.setting.width = newval - 1;
        this.left = 1;
        this.setting.left = this.left;
        this.windowsizeFlag = true;
      }
      if (newval < this.width + this.left) {
      // add FNSI-redmine#8312 高 start
        this.left = newval - this.width;
      // add FNSI-redmine#8312 高 end
        this.width = newval - this.left - 1;
        this.setting.width = newval - this.left - 1;
        this.windowsizeFlag = true;
      }
    },
    windowHeight(newval){
      if (newval < this.height) {
        this.height = newval - 1;
        this.setting.height = newval - 1;
        this.top = 1;
        this.setting.top = this.top;
        this.windowsizeFlag = true;
      }
      if (newval < this.height + this.top) {
      // add FNSI-redmine#8312 高 start
        this.top = newval - this.height;
      // add FNSI-redmine#8312 高 end
        this.height = newval - this.top - 1;
        this.setting.height = newval - this.top - 1;
        this.windowsizeFlag = true;
      }
    }
//add 8312 2023-03-07 14：15 投薬支援の子画面のサイズをウィンドウ外まで大きくすることができ操作不能となる 張 end
  },
  async created() {
    this.left = this.setting.left;
    this.top = this.setting.top;
    this.width = this.setting.width;
    this.height = this.setting.height;
    // add FNSI-redmine#8312 高 start
    this.nowLeft = this.left;
    // add FNSI-redmine#8312 高 end
//add 8312 2023-02-20 17：30 投薬支援の子画面のサイズをウィンドウ外まで大きくすることができ操作不能となる 張 start
    // this.initwidth = this.setting.width;
    // this.initheight = this.setting.height;
//add 8312 2023-02-20 17：30 投薬支援の子画面のサイズをウィンドウ外まで大きくすることができ操作不能となる 張 end
  },
  mounted() {
    // ヘッダー部に文字サイズの設定を適用
    this.setTitleFontSize(this.getFontSize);
  },
  // #8312 投薬支援の子画面のサイズをウィンドウ外まで大きくすることができ操作不能となる 訾浩 start
  beforeDestroy () {
    let div = document.querySelector("div");
    div.removeEventListener("drag", (params) => {
      this.clientX = params.gesture.center.clientX
    })
  }
  // #8312 投薬支援の子画面のサイズをウィンドウ外まで大きくすることができ操作不能となる 訾浩 end
};
</script>

<style scoped>
@media print {
  .print-none {
    display: none;
  }
}
@import "../../assets/styles/modal.css";
.kendo-dialogs {
  z-index: 9998;
  display: table;
  transition: opacity 0.3s ease;
}

.kendo-dialogs >>> .k-window-titlebar {
  color:rgb(255, 255, 255);
  background: unset;
  background-image: linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,.1) 100%);
  background-color: var(--ntss-list-header-background-color);
  /* add FNSI-5058 投薬支援小窓のヘッダーが大きい liumx start */
  height: 11px;
  /* add FNSI-5058 投薬支援小窓のヘッダーが大きい liumx end */
}
.kendo-dialogs >>> .k-window-content {
  background-color: var(--ntss-list-background-color);
  padding-bottom: unset;
}
</style>
