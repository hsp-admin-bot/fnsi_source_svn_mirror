import debounce from "@/compat/collections/lodash/debounce";

/**
 * クリックのデバウンス（Vue3: mounted / unmounted）
 */
export default {
  mounted(el, binding) {
    const fn = debounce(binding.value, 2000, {
      leading: true,
      trailing: false
    });
    el.__debounceClickFn__ = fn;
    el.addEventListener("click", fn);
  },
  unmounted(el) {
    if (el.__debounceClickFn__) {
      el.removeEventListener("click", el.__debounceClickFn__);
      el.__debounceClickFn__ = null;
    }
  }
};
