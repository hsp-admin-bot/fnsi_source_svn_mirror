/**
 * クリックのスロットル（Vue2 throttle ディレクティブと同等の挙動）
 */
export default {
  mounted(el, binding) {
    let throttleTime = binding.value;
    if (!throttleTime) {
      throttleTime = 2000;
    }
    let cbFun;
    const handler = (event) => {
      if (!cbFun) {
        cbFun = setTimeout(() => {
          cbFun = null;
        }, throttleTime);
      } else if (event) {
        event.stopImmediatePropagation();
      }
    };
    el.__throttleClickHandler__ = handler;
    el.addEventListener("click", handler, true);
  },
  unmounted(el) {
    if (el.__throttleClickHandler__) {
      el.removeEventListener("click", el.__throttleClickHandler__, true);
      el.__throttleClickHandler__ = null;
    }
  }
};
