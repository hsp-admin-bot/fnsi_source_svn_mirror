/**
 * Vue2 の fontSizeSet 算出を Vue3 でも共通提供する互換 mixin。
 *
 * Vue2 では App.vue / MasterMaintenanceMixin など複数の共通層が
 * `font-size-set-*` クラスを算出しており、各画面はその前提で
 * `:class="fontSizeSet"` を参照していた。
 * Vue3 で画面側を direct jq 化した場合でも、ページ個別に同じ算出を
 * 横展開せず、共通層から同じクラス名だけを補完する。
 */
const FONT_SIZE_SET_NAMES = ["small", "medium", "large", "x-large"];

function normalizeFontSizeIndex(value) {
  const index = Number(value);
  if (!Number.isFinite(index) || !FONT_SIZE_SET_NAMES[index]) {
    return 1;
  }
  return index;
}

function resolveFontSize(vm) {
  const storeValue = vm?.$store?.getters?.["account-edit/getFontSize"];
  if (storeValue !== undefined && storeValue !== null) {
    return storeValue;
  }
  return vm?.getFontSize;
}

export default {
  computed: {
    fontSizeSet() {
      const index = normalizeFontSizeIndex(resolveFontSize(this));
      return `font-size-set-${FONT_SIZE_SET_NAMES[index]}`;
    }
  }
};
