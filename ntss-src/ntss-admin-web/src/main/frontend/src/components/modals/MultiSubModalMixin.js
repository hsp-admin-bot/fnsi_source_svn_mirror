/**
 * 複数画面に対応したモーダル用のmixin
 */
import { mapMutations } from "vuex";
export default {
  methods: {
    ...mapMutations("multi-sub-modal", ["hideModal"])
  }
};
