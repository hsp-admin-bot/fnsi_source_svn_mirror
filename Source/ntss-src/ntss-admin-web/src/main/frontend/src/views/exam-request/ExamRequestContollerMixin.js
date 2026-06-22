/**
 * 検査依頼系Viewの共通処理
 */
import { mapGetters, mapMutations } from "@/compat/vue/vuex";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import {
  isRequestDetail,
  confirmIsOk,
} from "@/functions/exam-request/ExamRequestFunctions";

export default {
  data() {
    return {
      controller: null,
      controllerData: {
        // created時のthis.$route.nameの値
        selfRouterName: "",
        // 破棄確認制御情報
        confirmDiscardChangesState: {
          progress: ConfirmProgress.Initial,
          queue: [],
        },
      },
    };
  },
  computed: {
    ...mapGetters("pat-info", ["isPatInfoChaned"]),
 
    isDetail() {
      return isRequestDetail(this.controllerData.selfRouterName);
    },
  },
  methods: {
    ...mapMutations("pat-info", ["setIsPatInfoChaned"]),

    /**
     * 変更が有り、かつ破棄確認でキャンセルした場合にfalseを返す
     * isChanged 変更がある場合はtrue（booleanでない場合は this.$refs.mainComponent.isChanged の値を使用する）
     * options.beforeConfirmCallback 破棄確認を表示する場合にその直前に呼ばれるコールバック
     * options.forRefresh trueの場合は表示更新の際のメッセージにする
     */
    async confirmAllowDiscardChanges(isChanged, options) {
      if (typeof isChanged !== "boolean") {
        isChanged = this.$refs.mainComponent.isChanged;
      }
      if (!options) {
        options = {};
      }
      const state = this.controllerData.confirmDiscardChangesState;

      // 多重に呼ばれた場合は最初の呼び出しによる結果をすべての呼び出しに返す
      if (state.progress !== ConfirmProgress.Initial) {
        if (state.progress === ConfirmProgress.Confirm) {
          // すでに破棄確認中の場合
          // 破棄確認直前コールバックが設定されていれば呼び出しておく
          options.beforeConfirmCallback?.();
        }
        return await new Promise((resolve) => {
          state.queue.push({ options, resolve });
        });
      }

      state.progress = ConfirmProgress.Checking;
      let result = true;
      if (isChanged) {
        // 破棄確認直前コールバックが設定されていれば呼び出しておく
        options.beforeConfirmCallback?.();
        state.queue.forEach((context) => {
          context.options.beforeConfirmCallback?.();
        });

        state.progress = ConfirmProgress.Confirm;
        // DIALOG_MESSAGES[13000034]
        // title: "更新確認",
        // message: "編集中の項目があります。編集内容を破棄し、カレンダーの表示を更新してもよろしいですか？",
        // DIALOG_MESSAGES[13000004]
        // title: "内容破棄",
        // message: "編集内容が破棄されます。</br>よろしいですか？",
        const messages = DIALOG_MESSAGES[options.forRefresh ? 13000034 : 13000004];
        const isOk = await confirmIsOk(messages);
        if (!isOk) {
          // キャンセルされた場合はfalseを返す
          result = false;
        }
      }

      state.progress = ConfirmProgress.Initial; // 処理中ではない
      state.queue.splice(0).forEach(context => context.resolve(result));
      return result;
    },
    /**
     * confirmAllowDiscardChanges の表示更新時用ラッパー
     * 自動的に表示更新の際のメッセージに設定する
     */
    async confirmAllowDiscardChangesForRefresh(isChanged, options) {
      if (!options) {
        options = {};
      }
      return this.confirmAllowDiscardChanges(isChanged, {
        ...options,
        forRefresh: true,
      });
    },
    /**
     * ViewのbeforeRouteLeave用のconfirmAllowDiscardChangesラッパー
     * to.name と（現在の画面に応じて） isPatInfoChaned による判定も行う
     * 確認結果によるStore情報の処理も行う
     * toName beforeRouteLeaveに渡されたtoのnameプロパティの値
     */
    async confirmAllowDiscardChangesForBeforeRouteLeave(toName, options) {
      const isChanged = (
        toName !== ToNameBySignout && (
          this.$refs.mainComponent.isChanged
          || (this.isDetail && !!this.isPatInfoChaned)
        )
      );
      const result = await this.confirmAllowDiscardChanges(isChanged, options);
      if (result) {
        if (this.isDetail) {
          this.setIsPatInfoChaned(false);
        }
      }
      return result;
    },
  },
  created() {
    this.controller = this;
    this.controllerData.selfRouterName = this.$route.name;
  },
  beforeUnmount() {
    // dataの初期化
    this.controller = null;
    this.controllerData = null;
  },
};

// confirmAllowDiscardChangesの処理状態
const ConfirmProgress = {
  // 初期状態
  Initial: 0,
  // 破棄確認の発生判定処理中
  Checking: 1,
  // notification.confirmの処理中
  Confirm: 2,
};
// サインアウト時の画面遷移かどうかの判定をbeforeRouteLeaveのtoに入っているnameの値で行う際の定数
const ToNameBySignout = "signin";
