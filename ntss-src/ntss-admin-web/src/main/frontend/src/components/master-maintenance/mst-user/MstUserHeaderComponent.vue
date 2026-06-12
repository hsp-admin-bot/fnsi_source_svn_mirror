/**
 * 利用者マスタメンテナンスレコードページ用ヘッダ
 */
<template>
  <v-card>
    <div class='header-item'>
      <v-ons-row class='mark-leftmost-header'>
        <v-ons-col class='condition-search-col'>
          <common-searcharea :conditionList="conditionList" @show-popover='showPopover($event)'/>
        </v-ons-col>
        <v-ons-col>
          <div class="filter-area"></div>
          <v-ons-button class="btn3-normal delete-mail-btn" v-if="isMasterNkkUser" @click="showPopoverDeleteMail($event)">ﾒｰﾙｱﾄﾞﾚｽ<br>削除</v-ons-button>
        </v-ons-col>
      </v-ons-row>
    </div>
    <v-ons-popover cancelable
                   v-model:visible='popoverVisible'
                   :target='popoverTarget'
                   :direction='popoverDirection'
                   :cover-target=false
                   :class="[fontSizeSet, 'master-search']"
                   >
      <div style='margin:10px;'>
        <div v-if="isSearchFlg">
          <v-ons-row class='condition-row'>
            <v-ons-col width='40%' vertical-align='center'>
              <label>名称</label>
            </v-ons-col>
            <v-ons-col width='60%' vertical-align='center'>
              <v-ons-input input-id='recordName' type='text' float  v-model='condition.recordName' @keypress.enter='onSearchEnter'></v-ons-input>
            </v-ons-col>
          </v-ons-row>
          <div class='condition-row' style="height:30px;margin-bottom:5px;">
            <div style="float:left;">
              <v-ons-button class='btn2-cancel clear' @click='dialogClear'>クリア</v-ons-button>
            </div>
            <div style="float:right;">
              <v-ons-button class='btn3-normal ok' @click='dialogOk'>OK</v-ons-button>
            </div>
          </div>
        </div>
        <div v-if="isDeleteMailFlg">
          <v-ons-row class='condition-row'>
            <v-ons-col width='100%' vertical-align='center'>
              <label>メールアドレス</label>
            </v-ons-col>
          </v-ons-row>
          <v-ons-row class='condition-row'>
            <v-ons-col width='100%' vertical-align='center'>
              <v-ons-input type='email' input-id='targetEmailAddress' float v-model='targetEmailAddress'/>
            </v-ons-col>
          </v-ons-row>
          <div class='condition-row' style="height:30px;margin-bottom:5px;">
            <div style="float:left;">
              <v-ons-button class='btn2-cancel clear' @click='dialogDeleteMailClear'>クリア</v-ons-button>
            </div>
            <div style="float:right;">
              <v-ons-button class='btn4-alert ok' @click='dialogDeleteMail' style="background-color: red;">削除</v-ons-button>
            </div>
          </div>
        </div>
      </div>
    </v-ons-popover>
    <message-dialog
      v-model:visible="checkDialogVisible"
      :message-cd="15010003"
      type="2"
      :string-params="checkDialogParams"
      @confirm="confirm"
    />
    <message-dialog
      v-model:visible="resultDialogVisible"
      :message-cd="15010003"
      type="1"
      :string-params="resultDialogParams"
    />
  </v-card>
</template>

<!-- スクリプト処理 -->
<script>
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import { EventBus } from "@/compat/vue/event-bus.js";
import messageDialog from "@/components/common/message-dialog/MessageDialog";
import commonSearchArea from "@/components/common/CommonSearchArea";
import PopoverMixin from "@/components/PopoverMixin";

export default {
  mixins: [PopoverMixin],
  components: {
    "message-dialog": messageDialog,
    "common-searcharea": commonSearchArea
  },
  data() {
    return {
      popoverVisible: false,
      popoverTarget: null,
      popoverDirection: "down",
      condition: {
        recordName: ""
      },
      targetEmailAddress: "",
      isSortMode: false,
      isSearchFlg: false,
      isDeleteMailFlg: false,
      checkDialogVisible: false,
      checkDialogParams: [""],
      resultDialogVisible: false,
      resultDialogParams: [""],
      // 共通検索エリア部品に表示するデータのリスト
      conditionList: []
    };
  },
  computed: {
    ...mapGetters("account-edit", {
      getTheme: "getTheme",
      getStateUserAccountInfo: "getStateUserAccountInfo"
    }),
    isMasterNkkUser() {
      return this.getStateUserAccountInfo.userType == 1 &&
        this.getStateUserAccountInfo.administrator == 1
        ? true
        : false;
    }
  },
  methods: {
    ...mapActions("mst-user", [
      "setCondition",
      "checkDeleteTargetEmailAddress",
      "sendRequestDeleteEmailAddress"
    ]),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),
    ...mapGetters("mst-user", {
      getDeleteTargetEmailAddress: "getDeleteTargetEmailAddress"
    }),

    // -----------------------------------------
    // 抽出UI表示イベント
    // -----------------------------------------
    showPopover(event) {
      // ソートモード時は表示しない
      if (this.isSortMode) {
        return;
      }
      this.isSearchFlg = true;
      this.isDeleteMailFlg = false;
      this.popoverTarget = event;
      this.popoverVisible = true;
    },
    // -----------------------------------------
    // メールアドレス削除UI表示イベント
    // -----------------------------------------
    showPopoverDeleteMail(event) {
      this.isSearchFlg = false;
      this.isDeleteMailFlg = true;
      this.popoverTarget = event;
      this.popoverVisible = true;
    },
    // -----------------------------------------
    // 抽出条件クリアボタンクリックイベント
    // -----------------------------------------
    dialogClear() {
      // 検索条件クリアして画面を更新
      this.condition.recordName = "";
      // 共通検索エリア部品に表示するデータのリストを初期化
      this.conditionList = [];
      // 画面を閉じる
      this.popoverVisible = false;
      this.search();
    },
    // -----------------------------------------
    // メールアドレス削除クリアボタンクリックイベント
    // -----------------------------------------
    dialogDeleteMailClear() {
      // 削除メールアドレスをクリア
      this.targetEmailAddress = "";
      // 画面を閉じる
      this.popoverVisible = false;
    },
    // -----------------------------------------
    // 抽出条件Enter押下時イベント
    // -----------------------------------------
    onSearchEnter : function(){
      this.dialogOk();
    },
    // -----------------------------------------
    // 抽出条件OKボタンクリックイベント
    // -----------------------------------------
    dialogOk() {
      this.popoverVisible = false;
      this.setConditionList();
      this.search();
    },
    // -----------------------------------------
    // メールアドレス削除ボタンクリックイベント
    // -----------------------------------------
    async dialogDeleteMail() {
      this.popoverVisible = false;

      // 入力がなかった場合
      if (this.targetEmailAddress == "") {
        this.resultDialogParams = [
          "削除するメールアドレスを入力してください。"
        ];
        this.resultDialogVisible = true;
        return;
      }

      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);

      //削除対象メールを検索
      const response = await this.checkDeleteTargetEmailAddress(
        this.targetEmailAddress
      );
      if (response === 0) {
        // メールアドレス欄をクリア
        this.targetEmailAddress = "";

        let message = this.getDeleteTargetEmailAddress();
        // 共通ローダー:表示終了
        this.setLoadingScreenVisible(false);
        if (message === "") {
          // 削除対象メールアドレスが存在しなかった場合
          this.resultDialogParams = ["入力されたアドレスがありませんでした。"];
          this.resultDialogVisible = true;
        } else {
          // 確認ダイアログ表示
          message += "削除しますか？";
          this.checkDialogParams = [message];
          this.checkDialogVisible = true;
        }
      }else{
        // 共通ローダー:表示終了(response無しケース)
        this.setLoadingScreenVisible(false);
      }

    },
    // -----------------------------------------
    // メールアドレス削除実行
    // -----------------------------------------
    async confirm(answer) {
      if (answer === "OK") {
        // 共通ローダー:表示開始
        this.setLoadingScreenVisible(true);
        const response = await this.sendRequestDeleteEmailAddress();
        if (response === 0) {
          // 共通ローダー:表示終了
          this.setLoadingScreenVisible(false);
          let message = this.getDeleteTargetEmailAddress();
          message += "削除しました。";
          this.resultDialogParams = [message];
          this.resultDialogVisible = true;
        }else{
          // 共通ローダー:表示終了(response無しケース)
          this.setLoadingScreenVisible(false);
        }
      }
    },
    // -----------------------------------------
    // 処理：抽出条件を元にした検索イベント
    // -----------------------------------------
    search() {
      //スクロールバーの位置をクリア
      EventBus.$emit("clearScrollPosition");
      // 検索条件の内容で画面を更新
      this.setCondition(JSON.parse(JSON.stringify(this.condition)));
    },
    setSortMode(isSortMode) {
      // 検索条件の内容で画面を更新
      this.isSortMode = isSortMode;
      if (this.isSortMode) {
        // ソートモード時は条件クリア
        this.dialogClear();
      }
    },
    // -----------------------------------------
    // 共通検索エリア部品に表示するデータのリストを作成
    // -----------------------------------------
    setConditionList() {
      let condList = [];
      const condObj = this.condition;
      // 氏名
      if (condObj.recordName != "") {
        condList.push({ name:"氏名", text:condObj.recordName });
      }
      this.conditionList = condList;
    }
  },
  created() {
    EventBus.$on("setSortMode", this.setSortMode);
    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");
  },
  // add 性能改善メモリ不足 shan start
  beforeUnmount() {
    EventBus.$off("setSortMode", this.setSortMode);
  },
  // add 性能改善メモリ不足 shan end
  mounted() {
    EventBus.$emit("addLeftmostHeaderMargin");
  }
};
</script>

<!-- 個別スタイル定義 -->
<style scoped>
.delete-mail-btn {
  line-height: normal;
  margin-top: 0.4em;
  width: auto;
  font-size: 1.4em;
  padding: 0.2em 0.8em;
  height: auto;
}
</style>
