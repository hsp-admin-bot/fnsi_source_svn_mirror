/**
 * 複数画面に対応したモーダル用のmixin
 */
import { mapMutations } from "@/compat/vue/vuex";
export default {
  methods: {
    ...mapMutations("multi-modal", ["hideModal"])
  }
};
