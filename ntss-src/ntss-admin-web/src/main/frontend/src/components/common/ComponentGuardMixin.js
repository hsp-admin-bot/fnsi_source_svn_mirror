/**
 * コンポーネント単位ガードを行うMixin.
 */
import UserAuthorityMixin from "@/components/common/UserAuthorityMixin";

export default {
  /**
   * このコンポーネントを描画するルートが確立する前に呼ばれます.
   * @param to 次にナビゲーションされる対象のRouteオブジェクト.
   * @param from ナビゲーションされる前の現在のRouteオブジェクト.
   * @param next hook関数
   */
  beforeRouteEnter(to, from, next) {
    next(vm => {
      // 権限がない場合入力部品を操作不可にする
      vm.disableElement(vm.$el);
    });
  },
  mixins: [UserAuthorityMixin]
};
