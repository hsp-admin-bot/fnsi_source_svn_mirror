<template>
  <div id="main-id" class='main-content-area'>
    <table class="status-area">
      <tbody>
      <tr>
        <td>
          <label class="status">申込状況：{{ dataSource.length > 0 ? subscriptionStatus : '' }}</label>
        </td>
        <td v-if="!isNkk && subscriptionStatusCd === 0">
          <!-- 申込キャンセル -->
          <v-ons-button class="td-button button-font button" @click="cancelTicket">申込キャンセル</v-ons-button>
        </td>
        <td v-if="lastOrder && (subscriptionStatusCd === 0 || subscriptionStatusCd === 1)">
          <!--  -->
          <label v-if="lastOrder.applicant" class="status">申込者：{{ applicantName() }}</label>
        </td>
        </tr>
    
      </tbody>
    </table>
    <div class="grid">
      <table id="master-list" class="ntss-list">
        <thead>
          <tr>
            <th
              v-for="column in columnsHeader"
              :key="column.key"
              :class="[
                'ntss-list-header-th-sticky',
                column.additionalClass
              ]"
            >{{ column.title }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(func, index) in sortedItems" :key="`func_${index}`" class="ntss-list-body-tr">
            <td class="ntss-list-body-td text-center">{{ func.functionCd }}</td>
            <td class="ntss-list-body-td" style="position: relative">
              {{ func.functionName }}
              <v-ons-icon
                class="icon-tips"
                icon="fa-question-circle"
                @click="showTipsPopOver($event, func)"
              />
            </td>
            <td class="ntss-list-body-td text-center">
              <v-ons-checkbox
                v-if="!func.usedStatus"
                :value="func.functionCd"
                v-model="checkedFunction"
                :class="{'avoid-clicks': isInPlan(func.functionCd)}"
                :disabled="disableCheckboxCondition() || isInPlan(func.functionCd)"
              ></v-ons-checkbox>
            </td>
            <td class="ntss-list-body-td text-center">
              <span :class="{'used-func': func.usedStatus}">{{ func.usedStatus ? "利用中" : "未使用" }}</span>
            </td>
            <td class="ntss-list-body-td text-center">
              <!--add 利用開始日の表現を正しいようにする対応 劉 start-->
              <!--<span v-if="func.completeDate">{{ func.completeDate }}</span>-->
              <span v-if="func.completeDate && func.usedStatus">{{ func.completeDate }}</span>
              <!--add 利用開始日の表現を正しいようにする対応 劉 end-->
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div class="action-button">
      <div style="float:left;">
        <!--mod 印刷不正 修正 xie start-->
        <!-- <v-ons-button class="btn2-cancel denial-btn" @click="close">キャンセル</v-ons-button> -->
        <v-ons-button class="btn2-cancel denial-btn print_hidden" @click="close">キャンセル</v-ons-button>
        <!--mod 印刷不正 修正 xie end-->
      </div>
      <div style="float:right;">
      <!--mod 印刷不正 修正 xie start-->
      <!--  <v-ons-button
          class="btn1-execute registration-btn"
          :disabled="disableSubmitButtonCondition()"
          @click="submitTicket"
        >{{ isNkk ? "機能解放" : "申込" }}</v-ons-button>-->

        <v-ons-button
                  class="btn1-execute registration-btn print_hidden"
                  :disabled="disableSubmitButtonCondition()"
                  @click="submitTicket"
                >{{ isNkk ? "機能解放" : "申込" }}</v-ons-button>
      <!--mod 印刷不正 修正 xie end-->
      </div>
    </div>
    <v-ons-popover
      cancelable
      v-model:visible="popoverVisible"
      :target="popoverTarget"
      :cover-target="false"
      :direction="popoverDirection"
      :class="['tips-popover', fontSizeSet]"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="popoverPosthide"
    >
      <div class="help-area">
        <label>{{ viewTipsTexts }}</label>
      </div>
    </v-ons-popover>
  </div>
</template>

<script>
import NextTransitionMixin from "@/components/NextTransitionMixin";
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import {
  getSysAllFunction,
  getSalSubscriptionManage,
  createSalSubscriptionManage,
  sendRequestUpdateCancel
} from "@/apis/usage-subscription";
import dayjs from "@/compat/date/dayjs";
import {
  stringToArray,
  processStatus,
  functionContent
} from "@/components/usage-subscription/UsageSubscriptionFunction";
import { dateFormat } from "@/functions/common/DateTimeUtils.js";
import PopoverMixin from "@/components/PopoverMixin";
import { EventBus } from "@/compat/vue/event-bus.js";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end

export default {

  mixins: [NextTransitionMixin, PopoverMixin],
  name: "UsageSubscriptionMainComponent",
  data() {
    return {
      sysFunc: [],
      sysFuncAdvanced: [],
      dataSource: [],
      checkedFunction: [],
      lastOrder: null,
      isFirst: false,
      subscriptionStatusCd: -1,
      subscriptionStatus: "",
      // 吹き出し関連制御
      popoverVisible: false,
      popoverTarget: null,
      popoverDirection: null,
      viewTipsTexts: [],
      userList: [],
      selfScreenName: ""
    };
  },
  computed: {
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("account-edit", {
      stateUserAccountInfo: "getStateUserAccountInfo",
    }),
    ...mapGetters("usage-subscription", {
      selectedFacility: "selectedFacility",
      selectedPlan: "selectedPlan",
      subscriptionPlanName: "subscriptionPlanName"
    }),
    columnsHeader() {
      return [
        { key: "index", title: "No", additionalClass: "text-center w-3-em" },
        { key: "functionName", title: "機能", additionalClass: "" },
        { key: "application", title: "申込", additionalClass: "text-center w-8-em" },
        { key: "situation", title: "状況", additionalClass: "text-center w-8-em" },
        { key: "completeDate", title: "利用開始日", additionalClass: "text-center w-8-em" },
      ];
    },
    // add 利用申込 データを更新してマスタ一覧リンクを押下した後、メッセージが表示されない 孔s start
    isChanged(){
      return !this.disableSubmitButtonCondition;
    },
    // add 利用申込 データを更新してマスタ一覧リンクを押下した後、メッセージが表示されない 孔s end
    /**
     * ログインがnkkかどうかを確認します
     */
    isNkk() {
      return this.stateUserAccountInfo.facilityCd === "nkknkk";
    },
    /**
     * ソート順は
     * 1：申込中＞未使用＞利用中
     * 2：sys_function.disp_order>sys_function_advanced.disp_order
     */
    sortedItems() {
      const list = this.dataSource.slice();
      let that = this;

      list.sort((checkA, checkB) => {
        if ((that.subscriptionStatusCd === 0 || that.subscriptionStatusCd === 1) &&
          that.checkedFunction && that.checkedFunction.length > 0
        ) {
          if (that.checkedFunction.find(c => c === checkA["functionCd"]) && !that.checkedFunction.find(c => c === checkB["functionCd"])) {
            return -1;
          }
          if (that.checkedFunction.find(c => c === !checkA["functionCd"]) && that.checkedFunction.find(c => c === checkB["functionCd"])) {
            return 1;
          }
        }

        if (checkA["usedStatus"] < checkB["usedStatus"]) {
          return -1;
        }
        if (checkA["usedStatus"] > checkB["usedStatus"]) {
          return 1;
        }

        // add 申込一覧 障害対応 ソート順修正 孔 start
        if (checkA["adv"] < checkB["adv"]) {
          return -1
        }
        if (checkA["adv"] > checkB["adv"]) {
          return 1
        }
        // add 申込一覧 障害対応 ソート順修正 孔 end

        if (checkA["dispOrder"] < checkB["dispOrder"]) {
          return -1;
        }
        if (checkA["dispOrder"] > checkB["dispOrder"]) {
          return 1;
        }

        // del 申込一覧 障害対応 ソート順修正 孔 start
        // if (checkA["functionCd"].includes("A") > checkB["functionCd"].includes("A")) {
        //   return -1;
        // }
        // if (checkA["functionCd"].includes("A") < checkB["functionCd"].includes("A")) {
        //   return 1;
        // }
        // del 申込一覧 障害対応 ソート順修正 孔 end
      })
      return list;
    },
  },
  watch: {
    selectedFacility() {
      this.checkedFunction = [];
      this.getData();
    },
    selectedPlan() {
      this.forceCheckedForPlan();
    },
    dataSource() {
      this.isFirst =
        this.dataSource &&
        this.dataSource.filter(func => func.usedStatus === true).length > 0;
    },
    isFirst() {
      this.setIsFirst(this.isFirst);
    }
  },

  async created() {
    // 画面名称取得
    this.selfScreenName = this.$route.name;
    await this.getData();
  },
  methods: {
    ...mapActions("usage-subscription", ["setPlanName", "setIsFirst"]),
    ...mapActions("mst-user", ["getUserDataList"]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    /**
     * アプリケーションをキャンセルする
     */
    async cancelTicket() {
      this.$ons.notification.confirm({
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
        // title: "申込キャンセル",
        title: DIALOG_MESSAGES[13000151].title,
        // message: "お申込みいただいた内容を破棄しますがよろしいですか？",
        message: messageFormat(DIALOG_MESSAGES[13000151].message),
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        callback: async answer => {
          if (answer === 1) {
            let cancelResp;
            try {
              cancelResp = await sendRequestUpdateCancel( this.lastOrder.subscriptionNo );
            if (cancelResp && cancelResp.status === 200) {
              await this.getData();
              }
            } catch (error) {
              //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
              getErrorMessage('UsageSubscriptionMainComponent.vue','cancelTicket',error);
              //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
              if (error) {
              this.$ons.notification.alert({
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                  // title: "申込キャンセル不可",
                  // message: "既に申込受付済みのため申込キャンセルできませんでした。"
                  title: DIALOG_MESSAGES[12000274].title,
                  message: messageFormat(DIALOG_MESSAGES[12000274].message)  
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              });
            }
            
          }
        }
        }
      });
    },
    /**
     * 前の画面に戻る
     */
    close() {
      this.$router.go(-1);
    },
    /**
     * 新しい注文を作成する
     */
    async submitTicket() {
      let subscriptionFnc = [];
      let subscriptionAdv = [];
      this.checkedFunction.forEach(func => {
        const subFunction = this.dataSource.find(
          subFunc => subFunc.functionCd === func
        );
        if (subFunction) {
          if (subFunction.adv) {
            subscriptionAdv.push(func);
          } else {
            subscriptionFnc.push(func);
          }
        }
      });
      let planName = "";
      if (this.isFirst && this.selectedPlan) {
        planName = this.selectedPlan.subscriptionPlanName;
      } else if (this.subscriptionPlanName) {
        planName = this.subscriptionPlanName;
      }
      const param = {
        facilityCd: this.selectedFacility,
        isFirst: this.isFirst ? "1" : "0",
        subscriptionPlanName: planName,
        subscriptionFnc: JSON.stringify({
          item_cd: subscriptionFnc
        }),
        subscriptionAdv: JSON.stringify({
          item_cd: subscriptionAdv
        }),
        subscriptionStatus: "0"
      };
      // 申込確認メッセージを表示する。メッセージ文は後提示
      this.$ons.notification.confirm({
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
        // title: "",
        title: DIALOG_MESSAGES[13000152].title,
        // message: "申込を実行しますか。",
        message: messageFormat(DIALOG_MESSAGES[13000152].message),
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        callback: answer => {
          if (answer == 1) {
            this.sendRequestCreateSal(param);
          }
        }
      });
    },
    /**
     * 新しい注文を作成する
     */
    async sendRequestCreateSal(param) {
      let saveResp = await createSalSubscriptionManage(param);
      if (saveResp && saveResp.status === 200) {
        this.checkedFunction = [];
        await this.getData();
      } else {
        this.$ons.notification.alert({
          title: "",
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // message: "登録に失敗しました。"
          message: messageFormat(DIALOG_MESSAGES['00200028'].message),
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
      }
    },
    /**
     * 情報機能、情報オーダーの取得
     */
    async getData() {
      if (this.selectedFacility) {
        const sysAllFunction = await getSysAllFunction(this.selectedFacility);
        this.dataSource = sysAllFunction.data;
        const salSubscriptionManage = await getSalSubscriptionManage(
          this.selectedFacility
        );
        if (
          salSubscriptionManage.data &&
          salSubscriptionManage.data.length > 0
        ) {
          this.getLastOrder(salSubscriptionManage.data);
          this.getCompletedDate(salSubscriptionManage.data);
          this.isFirst = false;
        } else {
          this.isFirst = true;
          this.setPlanName(null);
          this.subscriptionStatusCd = -1;
          this.lastOrder = null;
        }
      } else {
        this.dataSource = [];
      }

      this.subscriptionStatus = processStatus(
        this.subscriptionStatusCd,
        this.isNkk
      );

      await this.getUser();
    },

    /**
     * ユーザーリストを取得する
     */
    async getUser() {
      if (this.lastOrder !== null) {
      this.getUserDataList(this.lastOrder.facilityCd).then(response => {
        if (response) {
          this.userList = response.data.localDataSource.data;
        }
      });
      }
    },
    /**
     * 申請者名
     */
    applicantName() {
      let user = this.userList.find(
        user => user.userId === this.lastOrder.applicant
      );
      return user ? user.userName : "";
    },

    /**
     * 最後の注文を取得
     */
    getLastOrder(order) {
      this.lastOrder = null;
      order.forEach(ord => {
        if (this.lastOrder) {
          if (dayjs(this.lastOrder.regDate) < dayjs(ord.regDate)) {
            this.lastOrder = ord;
          }
        } else {
          this.lastOrder = ord;
        }
      });
      if (this.lastOrder) {
        this.subscriptionStatusCd = parseInt(this.lastOrder.subscriptionStatus);
        this.setPlanName(this.lastOrder.subscriptionPlanName);
        this.forceCheckedLastOrder();
      }
    },

    getCompletedDate(order) {
      let listCompetedDate = [];
      let sysFunc = [];
      let sysFuncAdvanced = [];
      order.forEach(ord => {
        if (ord.completeDate) {
          sysFunc = stringToArray(ord.subscriptionFnc).item_cd;
          sysFuncAdvanced = stringToArray(ord.subscriptionAdv).item_cd;
          listCompetedDate.push({
            cd: [...sysFunc, ...sysFuncAdvanced],
            date: dateFormat.normalDate(new Date(ord.completeDate))
          });
          [...sysFunc, ...sysFuncAdvanced].forEach(func => {
            let foundFunc = this.dataSource.find(
              data => data.functionCd === func
            );
            if (foundFunc) {
              foundFunc.completeDate = dateFormat.normalDate(new Date(ord.completeDate));
            }
          });
        }
      });
    },

    /**
     *
     */
    showTipsPopOver(event, _function) {
      const currentFunction = functionContent.find(f => f.code == _function.functionCd);
      this.viewTipsTexts = currentFunction ? currentFunction.content : _function.functionName;
      this.popoverTarget = event;
      this.popoverVisible = true;
    },
    /**
     * 選択した申込プランに含まれる機能の申込チェックボックスを強制ONとして変更不可とする。
     */
    forceCheckedForPlan() {
      this.checkedFunction = [];
      this.sysFunc = [];
      this.sysFuncAdvanced = [];

      if (this.selectedPlan) {
        this.sysFunc = stringToArray(this.selectedPlan.subscriptionPlanFnc).item_cd;
        this.sysFuncAdvanced = stringToArray(this.selectedPlan.subscriptionPlanAdv).item_cd;
        [...this.sysFunc, ...this.sysFuncAdvanced].forEach(fnc => {
          const unusedFunc = this.dataSource.find(
            func => func.functionCd === fnc && !func.usedStatus
          );
          if (unusedFunc) {
            this.checkedFunction.push(fnc);
          }
        });
      }
    },
    /**
     * 登録中の機能が受信されていません
     */
    forceCheckedLastOrder() {
      this.checkedFunction = [];
      this.sysFunc = [];
      this.sysFuncAdvanced = [];
      if (this.lastOrder && (this.subscriptionStatusCd === 0 || this.subscriptionStatusCd === 1)) {
        this.sysFunc = stringToArray(this.lastOrder.subscriptionFnc).item_cd;
        this.sysFuncAdvanced = stringToArray(this.lastOrder.subscriptionAdv).item_cd;
        [...this.sysFunc, ...this.sysFuncAdvanced].forEach(fnc => {
          const unusedFunc = this.dataSource.find(
            func => func.functionCd === fnc && !func.usedStatus
          );
          if (unusedFunc) {
            this.checkedFunction.push(fnc);
          }
        });
      }
    },
    /**
     * 選択した申込プランに含まれる機能の申込チェックボックスを強制ONとして変更不可とする。
     */
    isInPlan(cd) {
      return [...this.sysFunc, ...this.sysFuncAdvanced].find(
        func => func === cd
      );
    },
    /**
     * 申込中の場合
     * 申込チェックボックス
     * 申込ボタン
     */
    disableCheckboxCondition() {
      return this.subscriptionStatusCd === 0 || this.subscriptionStatusCd === 1;
    },
    /**
     * 申込中の場合
     * 申込チェックボックス
     * 申込ボタン
     */
    disableSubmitButtonCondition() {
      // add 申込パターンの非活性バッグを対応 劉 start
      let selectPlan = ()=> {
        if (!this.isNkk){
          return !this.subscriptionPlanName;
        }
        else {
          return this.subscriptionPlanName !== null? !this.subscriptionPlanName : !this.selectedPlan;
        }
      }
      // add 申込パターンの非活性バッグを対応 劉 end
      return (
        !this.checkedFunction ||
        this.checkedFunction.length === 0 ||
        this.subscriptionStatusCd === 0 ||
        this.subscriptionStatusCd === 1 ||
        // mod 申込パターンの非活性バッグを対応 劉 start
        // return !this.selectedPlan;
        selectPlan()
        // mod 申込パターンの非活性バッグを対応 劉 end
      );
    },
    async refresh() {
      if (this.selfScreenName === this.$route.name) {
        // #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start
        // this.dataSource = [];
        await this.getData();
        // #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end
      }
    }
  },
  mounted() {
    // add 性能改善メモリ不足 shan start
    EventBus.$off("refresh", this.refresh);
    // add 性能改善メモリ不足 shan end
    EventBus.$on("refresh", this.refresh);
  },
  beforeUnmount() {
    EventBus.$off("refresh", this.refresh);
  }
};
</script>
<style scoped>
.grid {
  position: relative;
  overflow: auto;
  height: calc(100% - 100px);
}
#master-list th,
#master-list td {
  white-space: nowrap;
}
#master-list td:nth-child(2) {
  padding-right: 30px;
}
.ntss-list-header-th-sticky {
  z-index: 100;
}
.text-center {
  text-align: center;
}
.td-button {
  width: fit-content;
  height: 1.7em;
  line-height: 1.4em;
}
.status-area {
  display: flex;
  align-items: center;
  font-size: 1em;
  color: var(--ntss-list-body-color);
  height: 40px;
}
.status-area td:nth-child(n + 2) {
  padding-left: 18px;
}
.action-button {
  position: absolute;
  width: 100%;
  height: 50px;
}
.used-func {
  background-color: #00b050;
  padding: 8px 16px;
  color: white;
}
.w-3-em {
  width: 3em;
}
.w-8-em {
  width: 8em;
}
.help-area {
  margin: 10px;
}
.help-area label {
  font-size: 1.5em;
  white-space: pre-line;
}
.icon-tips {
  position: absolute;
  right: 8px;
}
.ntss-list-body-tr {
  border: solid 1px var(--ntss-list-border-color);
  color: var(--ntss-list-body-color);
  background-color: var(--ntss-list-item-background-color);
  height: 3em;
}
.avoid-clicks {
  pointer-events: none;
}
.action-button ons-button {
  padding: 0.2em 1em 0em 1em;
  line-height: 2em;
  margin-top: 16px;
}
.tips-popover :deep(.popover),
.tips-popover :deep(.popover__content) {
  min-width: fit-content;
  min-height: fit-content;
}

/* mod 印刷不正 修正 xie start */
@media print {
  .print_hidden {
    visibility: hidden;
  }
}
/* mod 印刷不正 修正 xie end */
</style>
