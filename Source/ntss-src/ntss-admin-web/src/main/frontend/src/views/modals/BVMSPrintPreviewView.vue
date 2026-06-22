/**
 * 印刷プレビューページ
 */
<template>
  <modal-base @onClose="cancel">
    <template #body>
      <div
        class="print-preview"
        :style="isMobileBrowser() ? 'width: 100%; box-sizing: border-box;' : 'width: fit-content'"
        v-show="previewHtml !== null"
        v-html="previewHtml"
      ></div>
    </template>
    <template #footer>
      <div class="flex-container">
      <div class="denial-btn-area" style="background:none">
        <button class="button btn2-cancel denial-btn" @click="cancel">キャンセル</button>
      </div>
      <div class="registration-btn-area" style="background:none">
        <button class="button btn3-normal registration-btn" @click="print">印刷</button>
      </div>
      </div>
    </template>
  </modal-base>
</template>

<script>
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import ModalBase from "@/components/modals/ModalBase";
import MultiModalMixin from "@/components/modals/MultiModalMixin";
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end

export default {
  name: "bvmsPrintPreview",
  mixins: [MultiModalMixin],
  components: {
    "modal-base": ModalBase
  },
  data() {
    return {
      previewHtml: null
    };
  },
  computed: {
    ...mapGetters("report", ["getMstPrinters"]),
    ...mapGetters("treatment-record/common", ["getOrdNo"])
  },
  methods: {
    ...mapActions("report", ["getReportHTMLForBVMS", "printReportForBVMS"]),
    ...mapActions("loading-screen", ["setLoadingScreenVisible"]),
    /**
     * 初期処理.
     */
    init() {
      this.setLoadingScreenVisible(true);
      this.getReportHTMLForBVMS(this.getOrdNo).then(response => {
        const processed = this.isMobileBrowser() ? this.ensureViewBox(response.data.reportHtml) : response.data.reportHtml;
        this.previewHtml = processed;
        this.setLoadingScreenVisible(false);
      });
    },
    /**
     * キャンセル処理
     */
    cancel() {
      this.hideModal();
    },
    /**
     * 印刷処理
     */
    print() {
      this.setLoadingScreenVisible(true);
      this.printReportForBVMS(true).then(response => {
        this.setLoadingScreenVisible(false);
        if (response.status === 200) {
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // this.$ons.notification.alert("印刷された", {
          //   title: "成功"
          // });
          this.$ons.notification.alert(messageFormat(DIALOG_MESSAGES['00100022'].message), {
            title: DIALOG_MESSAGES['00100022'].title
          });
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          this.hideModal();
        }
      });
    },
    /**
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
      const isIpadMacTouch = platform === 'MacIntel' && nav.maxTouchPoints && nav.maxTouchPoints > 1;
      const isIpad = isIpadUA || isIpadMacTouch;

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
      };
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
    }
  },
  created() {
    this.init();
  }
};
</script>
<style scoped>
.print-preview {
  padding: 16px;
  margin: 0px auto;
  border: 1px solid lightgray;
}
div :deep(.modal-header .toolbar) {
  background-color: var(--ntss-header-background-color);
}
div :deep(.modal-header .toolbar__title.toolbar__left) {
  color: var(--ntss-header-color) !important;
}
div :deep(.modal-search),
div :deep(.modal-body),
div :deep(.modal-footer),
div :deep(.modal-footer .bottom-bar) {
  background-color: var(--ntss-base-background-color);
  color: var(--ntss-base-color);
}
</style>
