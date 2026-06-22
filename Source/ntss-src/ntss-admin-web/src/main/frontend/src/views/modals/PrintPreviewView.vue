/**
 * 印刷プレビューページ
 */
<template>
  <modal-base @onClose="cancel">
    <!--mod 6928 暗背景時のプレビューの背景が正しくない 吉 start-->
    <!--<div slot="body" class="print-preview" v-show="previewHtml !== null" v-html="previewHtml"></div>-->
    <!--mod 8466 帳票機能が使用できない  吉 start-->
    <!--<div slot="body" class="print-preview" :class="themeBlack" v-show="previewHtml !== null" v-html="previewHtml"></div>-->
    <template #body>
      <div
        class="print-preview"
        :style="isMobileBrowser() ? 'width: 100%; box-sizing: border-box;' : 'width: fit-content'"
        :class="themeBlack"
        v-show="previewHtml !== ''"
        v-html="previewHtml"
      ></div>
    </template>
    <!--mod 8466 帳票機能が使用できない  吉 end-->
    <!--mod 6928 暗背景時のプレビューの背景が正しくない 吉 end-->
    <template #footer>
      <div class="flex-container">
      <div class="denial-btn-area" style="background:none">
        <button class="button btn2-cancel denial-btn" @click="cancel">キャンセル</button>
      </div>
      <div class="registration-btn-area" style="background:none">
        <!-- プリンタ選択肢 -->
        <!-- mod #12107 帳票印刷失敗通知が行われない limingzhe 20251114 start -->
        <!--  <v-ons-select
          v-show="hasPrinter"
          v-model="selectedPrinter"
          data-non-authorize="true"
          class="printer-selection"> -->
        <v-ons-select
          :disabled="!hasPrinter || previewHtml == ''"
          v-model="selectedPrinter"
          data-non-authorize="true"
          class="printer-selection">
        <!-- mod #12107 帳票印刷失敗通知が行われない limingzhe 20251114 end -->
          <template v-for="item in getMstPrinters" :key="item.printerCd">
            <option :value="item.printerCd">{{ item.dispPrinterName }}</option>
          </template>
        </v-ons-select>
        <!--mod 8466 帳票機能が使用できない  吉 start-->
       <!-- <button
          class="button btn3-normal registration-btn"
          style="vertical-align:top;"
          :disabled="!hasPrinter"
          @click="print">印刷</button>-->
        <button
          class="button btn3-normal registration-btn"
          style="vertical-align:top;"
          :disabled="!hasPrinter || previewHtml == ''"
          @click="print">印刷</button>
        <!--mod 8466 帳票機能が使用できない  吉 end-->
      </div>
      </div>
    </template>
  </modal-base>
</template>

<script>
import { getFirstElementByClassName } from "@/functions/common/LayoutMeasureHelper";

import { mapActions, mapGetters } from "@/compat/vue/vuex";
import ModalBase from "@/components/modals/ModalBase";
import MultiModalMixin from "@/components/modals/MultiModalMixin";
import { messageFormat } from "@/functions/common/MessageFormat";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
// add 10738 機能帳票IFにてプリンターが未登録だとプレビューができない 本田 start

// add #10633 【たくしん会】【因島】帳票のフォント問題 高 end

export default {
  name: "printPreview",
  mixins: [MultiModalMixin],
  components: {
    "modal-base": ModalBase,
  },
  data() {
    return {
      /**
       * プレビュー用のHTML
       */
      previewHtml: null,
      /**
       * 選択されたプリンタ情報
       */
      selectedPrinter: null
    }
  },
  computed: {
    ...mapGetters("report", [
      "getMstPrinters",
      "getTargetPrinter"
    ]),
    // add 6928 暗背景時のプレビューの背景が正しくない 吉 start
    ...mapGetters("account-edit", {
      getTheme: "getTheme"
    }),
    // add 6928 暗背景時のプレビューの背景が正しくない 吉 end
    /**
     * プリンターが登録されているか.
     *
     * @returns true : プリンタが登録されている場合
     *          false : プリンタが登録されていない場合
     */
    hasPrinter() {
      return this.getMstPrinters.length > 0;
    },
    // add 6928 暗背景時のプレビューの背景が正しくない 吉 start
    themeBlack() {
      return this.getTheme === 1 ? "ntss-list-body-tr-black" : "";
    }
    // add 6928 暗背景時のプレビューの背景が正しくない 吉 end
  },
  methods: {
    ...mapActions("report", [
      "getReportHTMLByReportCd",
      "setTargetPrinter"
    ]),
    ...mapActions("loading-screen", ["setLoadingScreenVisible"]),
    // mod #11232 #10515で入れた制限の見直し 房 start
    /**
     * 初期処理.
     */
    async init() {
      this.setLoadingScreenVisible(true);
      // 透析レポートの場合、JSONデータを取得して、画面側でグラフ生成

      // 出力プリンタ
      this.getReportHTMLByReportCd(true)
        .then(response => {
          /* fix #12159 lichaolong 20260303 start */
          const processed = this.isMobileBrowser() ? this.ensureViewBox(response.data.reportHtml) : response.data.reportHtml;
          this.previewHtml = processed;
          /* fix #12159 lichaolong 20260303 end */
        }).finally(() => {
          if (!this.hasPrinter) {
            this.$ons.notification
              .alert({
                // mod 10738 機能帳票IFにてプリンターが未登録だとプレビューができない 本田 start
                // title: null,
                // message: "プリンターが登録されていません。"
                title: DIALOG_MESSAGES[12000341].title,
                message: messageFormat(DIALOG_MESSAGES[12000341].message)
                // mod 10738 機能帳票IFにてプリンターが未登録だとプレビューができない 本田 end
              });
          }
          this.setLoadingScreenVisible(false);
        });
      this.selectedPrinter = this.getTargetPrinter;

    },
    /**
     * fix #12159 lichaolong 20260303 start
     * モバイルブラウザでSVGのviewBoxがない場合に、viewBoxを付与する
     */
    detectPlatform() {
      const nav = (typeof navigator !== 'undefined') ? navigator : {};
      const ua = nav.userAgent ? String(nav.userAgent) : '';
      const platform = nav.platform ? String(nav.platform) : '';
      const low = ua.toLowerCase();

      const isAndroid = /android/.test(low);
      const isIphone = /iphone/.test(low) && !isAndroid;
      const isIpadUA = /ipad/.test(low);
      // iPadOS 13 以降の iPad は userAgent に "Mac" を含むため、platform と maxTouchPoints で判別
      const isIpadMacTouch = platform === 'MacIntel' && nav.maxTouchPoints && nav.maxTouchPoints > 1;
      const isIpad = isIpadUA || isIpadMacTouch;

      // iPad を Mac から除外（iPadOS は上記で処理済み）
      const isMac = (/macintosh|mac os x/.test(low) || /macintel/i.test(platform)) && !isIpad;
      const isWindows = /windows/.test(low);
      const isLinux = /linux/.test(low) && !isAndroid;

      let name = 'unknown';
      if (isAndroid) name = 'android';
      else if (isIphone) name = 'iphone';
      else if (isIpad) name = 'ipad';
      else if (isMac) name = 'mac';
      else if (isWindows) name = 'windows';
      else if (isLinux) name = 'linux';

      return {
        name,
        isAndroid,
        isIphone,
        isIpad,
        isMac,
        isWindows,
        isLinux,
        ua,
        platform
      }
    },
    isMobileBrowser() {
      const platform = this.detectPlatform();
      return platform.isAndroid || platform.isIphone || platform.isIpad;
    },
    ensureViewBox(svgString) {
      try {
        const str = String(svgString || '');
        if (!str.includes('<svg')) return str;

        const doc = new DOMParser().parseFromString(str, 'text/html');
        const svgs = Array.from(doc.querySelectorAll('svg'));
        if (svgs.length === 0) return str;

        const scaleRegex = /scale\(\s*[-+]?\d*\.?\d+(?:[eE][-+]?\d+)?(?:\s*,\s*[-+]?\d*\.?\d+(?:[eE][-+]?\d+)?)?\s*\)/g;

        svgs.forEach(svg => {
          if (!svg.hasAttribute('viewBox')) {
            const w = svg.getAttribute('width');
            const h = svg.getAttribute('height');
            const numW = w ? parseFloat(w) : NaN;
            const numH = h ? parseFloat(h) : NaN;
            if (!isNaN(numW) && !isNaN(numH)) svg.setAttribute('viewBox', `0 0 ${numW} ${numH}`);
          }
          svg.setAttribute('width', '100%');
          svg.setAttribute('height', 'auto');
          svg.setAttribute('preserveAspectRatio', 'xMidYMid meet');

          try {
            const elements = svg.querySelectorAll('[transform]');
            elements.forEach(el => {
              const t = el.getAttribute('transform');
              if (t && scaleRegex.test(t)) {
                el.setAttribute('transform', t.replace(scaleRegex, 'scale(1)'));
              }
            });
          } catch (e) {
            // ignore per-original
          }
        });

        return doc.body.innerHTML;
      } catch (e) {
        return svgString;
      }
    },
    /* fix #12159 lichaolong 20260303 end */
    /**
     * 印刷処理
    */
    async print() {
      // 選択されている出力プリンタを設定
      this.setTargetPrinter(this.selectedPrinter);
      this.getReportHTMLByReportCd(false);
      this.hideModal();
    },
    /**
     * キャンセル処理
     */
    cancel() {
      this.hideModal();
    },
  },
  // add 6928 暗背景時のプレビューの背景が正しくない 吉 start
  mounted() {
    getFirstElementByClassName("print-preview", this.$el || this)?.parentElement?.setAttribute("style", "overflow-y:auto");
  },
  // add 6928 暗背景時のプレビューの背景が正しくない 吉 end
  created() {
    this.init();
  }
};
</script>
<style scoped>
/*add 6928 暗背景時のプレビューの背景が正しくない 吉 start*/
:deep(.ntss-list-body-tr-black) {
  background-color: white;
}
/*add 6928 暗背景時のプレビューの背景が正しくない 吉 end*/
.print-preview {
  padding: 16px;
  /*add 6928 暗背景時のプレビューの背景が正しくない 吉 start*/
  /*margin: 8px;*/
  margin:0px auto;
  /*add 6928 暗背景時のプレビューの背景が正しくない 吉 end*/
  border: 1px solid lightgray;
}
/*
 * 出力プリンタ選択肢のスタイル
 * ※幅はReportSelectorComponent.vueで定義している
 *   選択肢のスタイルと一致させていてる.
 */
.printer-selection {
  width: 280px;
  margin: 0 8px;
}
@media only screen and (max-device-width:480px) {
  .printer-selection {
    width: 150px;
  }
}
@media only screen and (max-device-width:420px) {
  .printer-selection {
    width: 100px;
  }
}
@media only screen and (max-device-width:360px) {
  .printer-selection {
    width: 60px;
  }
}
</style>
