/**
 * 治療記録用画面破棄確認 共通コンポーネント
 */
//mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。 張玲 start
// import { mapGetters } from "@/compat/vue/vuex";
import { mapGetters, mapMutations } from "@/compat/vue/vuex";
//mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。 張玲 end
// add #11047 ②治療記録＞バイタル モニタ入力範囲が0～ではない項目にて空欄にできない。linjunfeng start
import { EventBus } from "@/compat/vue/event-bus.js";
// add #11047 ②治療記録＞バイタル モニタ入力範囲が0～ではない項目にて空欄にできない。linjunfeng end
// mod #6107 2023/03/23 メッセージボックス全調整 張博 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from '@/functions/common/MessageFormat';
// mod #6107 2023/03/23 メッセージボックス全調整 張博 end

export default {
  data() {
    return {
      isDialogOpen: false,
    };
  },
  computed: {
    ...mapGetters("treatment-record/common", ["getOrdNo", "getDialysisState"]),
    hasOrdNo() {
      return this.getOrdNo;
    }
  },
  watch: {
    getOrdNo() {
      this.refresh();
    }
  },
  methods: {
    ...mapGetters("account-edit", {
      getStateUserAccountInfo: "getStateUserAccountInfo"
    }),
    ...mapMutations("pat-info", ["setIsPatInfoChaned"]),
    discardConfirm(execFunction, cancelFunction) {
      // ダイアログの2重表示防止のためダイアログが閉じている場合のみ表示
      if (!this.isDialogOpen) {
        this.isDialogOpen = true;
        this.$ons.notification.confirm({
          // title: "内容破棄",
          title: DIALOG_MESSAGES[13000004].title,
          // message: "編集内容が破棄されます。</br>よろしいですか？",
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
          callback: (answer) => {
            if (answer === 1) {
              this.setIsPatInfoChaned(false);
              EventBus.$emit("refreshMonitorNumberInput");
              execFunction();
            } else if (typeof cancelFunction === "function") {
              cancelFunction();
            }
            this.isDialogOpen = false;
          },
        });
      } else if (typeof cancelFunction === "function") {
        cancelFunction();
      }
    },
    /**
     * 患者IDから取得した最新のOrdMainレコードが指定されていない場合は、治療記録の初期画面に遷移させる
     * @returns 最新のOrdMainレコードが指定されていない場合、false、指定されている場合、true
     */
    checkOrdNo() {
      if (!this.hasOrdNo) {
        // this.$router.push({ name: "treatment-record" });
        return false;
      }
      return true;
    }
  },
  beforeRouteLeave(to, from, next) {
    // 変更済みでサイアアウト以外の時にチェック
    // 患者IDから取得した最新のOrdMainレコードが指定されていない場合は、編集済みとみなさない.
    if (
      this.hasOrdNo &&
      this.isChanged &&
      this.getStateUserAccountInfo() !== null
    ) {
      this.discardConfirm(() => next(), () => next(false));
    } else {
      next();
    }
  }
};
