/**
 * MainComponent用次画面遷移機能共通コンポーネント
 * (※パンくずComponentに依存します)
 */
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import { getRouterItemsByFunctionCd } from "@/router/routing-helper";
import { FUNC_OPERATION_VIEWER } from "@/constants/function-code";
import { EventBus } from "@/compat/vue/event-bus.js";

// 稼働ビューアの画面遷移情報
const ROUTE_NAMES = getRouterItemsByFunctionCd(FUNC_OPERATION_VIEWER).map(
  item => item.routes
);

export default {
  data() {
    return {
      nextTransitionPromise: null,
      nextTransitionKey: null
    };
  },
  props: {
    historyKey: {
      type: String,
      required: true
    }
  },
  methods: {
    ...mapGetters("bread-crumb", ["getHistory"]),
    ...mapActions("window-size", [
      "setSplittableFrames"
    ]),

    // 現画面ルート名取得
    getCurrentRouteName() {
      const histories = this.getHistory();
      const e = histories.find(x => x.historyKey === this.historyKey);
      return e ? e.routerName : "";
    },

    // 次画面ルート名取得（稼働ビューア用）
    getNextRouterName() {
      const currentRouteName = this.getCurrentRouteName();
      if (currentRouteName === "") {
        return "";
      }
      for (const routes of ROUTE_NAMES) {
        // 現画面の履歴の位置(index)を取得（次が無い(末尾）の場合は、-1）
        const index = routes.findIndex((name, index, arr) => {
          return name === currentRouteName && index < arr.length - 1;
        });
        if (index >= 0) {
          return routes[index + 1];
        }
      }
      return "";
    },

    // 次画面遷移（稼働ビューア用）
    goNextView() {
      this.goSpecifiedView(this.getNextRouterName());
    },

    // 患者情報共有における分割画面への遷移処理
    goShrSplitView(routerName) {
      if (!routerName || this.$route.name === routerName) return;
      this.setSplittableFrames();
      this.$router.push({ name: routerName }).catch(() => {});
    },

    // 指定された画面へ遷移
    goSpecifiedView(routerName) {
      // 画面幅に応じてサイドバーを閉じる
      EventBus.$emit("sidebarCloseByWidth");
      // 遷移元の画面
      const currentRouteName = this.getCurrentRouteName();
      if (routerName !== "") {
        // 操作が行われた画面から指定画面へ遷移する際に分割画面が指定画面である場合に、すでにその画面が分割表示されている場合、
        // 同じ画面にルーティングされることになるため、画面遷移と分割画面の再表示が正常に行われるように、
        // 一旦、遷移元の画面に遷移してからルート変更の完了後に指定画面へ遷移させる
        // 例:
        // 遠隔監視から装置記録に初めて分割表示される場合は遷移先のルートが異なるため装置記録のコンポーネントがロードされる。
        // 遠隔監視と装置記録が分割表示中は装置記録にルーティングしても同じルートになるためコンポーネントが再ロードされない。
        // 現在のルートを強制的に置き換えるためには、現在のルートと異なるルート（遷移元:currentRouteName）に遷移完了後に
        // 遷移先のルートへ遷移させる。
        // ※ 遷移元の画面へ一旦ルーティングを戻した後（非同期処理の完了後）に遷移先のルートに遷移する

        const transitionKey = `${currentRouteName}->${routerName}`;
        if (this.nextTransitionPromise && this.nextTransitionKey === transitionKey) {
          return this.nextTransitionPromise;
        }

        this.nextTransitionKey = transitionKey;
        this.nextTransitionPromise = this.$router.push({ name: currentRouteName })
          .then(() => {
            // ルート変更の完了後（非同期処理の完了後）に指定画面へ遷移する
            return this.$router.push({ name: routerName });
          })
          .finally(() => {
            if (this.nextTransitionKey === transitionKey) {
              this.nextTransitionPromise = null;
              this.nextTransitionKey = null;
            }
          });

        return this.nextTransitionPromise;
      }
    }
  }
};
