<template>
  <v-card>
    <div class="grid" id="scrollArea">
      <table id="master-list" class="ntss-list">
        <thead>
          <tr>
            <th
              v-for="column in columnsHeader"
              :key="column.key"
              :class="['ntss-list-header-th-sticky', column.additionalClass, column.key !== '' ? sortedClass(column.key) : '']"
              @click="sortBy(column.key)"
            >{{ column.title }}</th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="(order, index) in dataSource"
            :key="`func_${index}`"
            class="ntss-list-body-tr"
            :class="fontColorClass(order.subscriptionStatus)"
            :style="rowColor(order.subscriptionStatus)"
          >
            <td class="ntss-list-body-td">{{ order.facilityName }}</td>
            <td
              class="ntss-list-body-td text-center"
            >{{ getSubscriptionStatus(order.subscriptionStatus) }}</td>
            <td
              class="ntss-list-body-td"
              @click="order.sysFunctionList.length < 5 ? null : showPopOver($event, order.sysFunctionList)"
            >
              <template v-if="order.sysFunctionList.length < 5">
                <label
                  v-for="func in order.sysFunctionList"
                  :key="func.functionCd"
                  style="display: block"
                >{{ func.functionName }}</label>
              </template>
              <label
                v-else
                style="color: rgb(75, 172, 198)"
              >{{ `計${order.sysFunctionList.length}件` }}</label>
            </td>
            <td class="ntss-list-body-td text-center">{{ order.applicantName }}</td>
            <td class="ntss-list-body-td text-center">
              <span v-if="order.regDate">
                {{ formatDate(order.regDate).split(' ')[0] }}
                <br />
                {{ formatDate(order.regDate).split(' ')[1] }}
              </span>
            </td>
            <td class="ntss-list-body-td text-center">
              <span v-if="order.receptionist">{{ order.receptionistName }}</span>
              <v-ons-button
                v-if="!order.receptionist && order.subscriptionStatus !== '9'"
                class="btn1-execute"
                @click="acceptTicket(order.subscriptionNo)"
              >受付</v-ons-button>
            </td>
            <td class="ntss-list-body-td text-center">
              <span v-if="order.receptionDate">
                {{ formatDate(order.receptionDate).split(' ')[0] }}
                <br />
                {{ formatDate(order.receptionDate).split(' ')[1] }}
              </span>
            </td>
            <td class="ntss-list-body-td text-center">
              <span v-if="order.completer">{{ order.completerName }}</span>
              <v-ons-button
                v-if="!order.completer && order.receptionist && isAdminUser && order.subscriptionStatus !== '9'"
                class="btn1-execute"
                @click="completeTicket(order.subscriptionNo)"
              >完了</v-ons-button>
            </td>
            <td class="ntss-list-body-td text-center">
              <span v-if="order.completeDate">
                {{ formatDate(order.completeDate).split(' ')[0] }}
                <br />
                {{ formatDate(order.completeDate).split(' ')[1] }}
              </span>
            </td>
            <td class="ntss-list-body-td text-center">
              <v-ons-button
                v-if="!order.completeDate && order.subscriptionStatus !== '9'"
                class="btn4-alert"
                @click="cancelTicket(order.subscriptionNo)"
              >削除</v-ons-button>
              <div
                class="canceller"
                v-else>
                <p>{{ order.cancellerName }}</p>
                <span v-if="order.cancelDate">
                  {{ formatDate(order.cancelDate).split(' ')[0] }}
                  <br />
                  {{ formatDate(order.cancelDate).split(' ')[1] }}
                </span>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <v-ons-popover
      cancelable
      :visible.sync="popoverVisible"
      :target="popoverTarget"
      :cover-target="false"
      :direction="popoverDirection"
      :class="[fontSizeSet, 'app-list-popover']"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="popoverPosthide"
    >
      <div class="help-area">
        <div v-for="(func, index) in viewFuncTexts" :key="index">
          <label>{{ func.functionName }}</label>
        </div>
      </div>
    </v-ons-popover>
  </v-card>
</template>

<script>
const PER_PAGE = 15;
import { mapGetters } from "vuex";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import {
  sendRequestGetAll,
  sendUpdateReception,
  sendUpdateCompletion,
  sendUpdateCancel
} from "@/apis/application-list";
import { EventBus } from "@/eventBus.js";
import {
  DATE_TIME_FORMAT,
  dateFormat
} from "@/functions/common/DateTimeUtils.js";
import PopoverMixin from "@/components/PopoverMixin";
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
// mod #6107 2023/03/22 メッセージボックス全調整 張博 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from '@/functions/common/MessageFormat';
// mod #6107 2023/03/22 メッセージボックス全調整 張博 end

export default {
  props: {},
  mixins: [NextTransitionMixin, PopoverMixin],
  name: "ApplicationListMainComponent",
  data() {
    return {
      applicationList: [],
      statusList: [
        { cd: 0, status: "未受付", bgColor: "#FFFFCC" },
        { cd: 1, status: "受付済み", bgColor: "" },
        { cd: 2, status: "完了済み", bgColor: "#7F7F7F" },
        { cd: 9, status: "キャンセル", bgColor: "#7F7F7F" }
      ],
      sort: {
        key: "",
        isAsc: true
      },
      popoverVisible: false,
      popoverTarget: null,
      popoverDirection: "down up",
      viewFuncTexts: [],
      page: 1,
      scrollTopPos: '',
    };
  },
  computed: {
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight"
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getTheme: "getTheme",
      getUseFunctions: "getUseFunctions",
      stateUserAccountInfo: "getStateUserAccountInfo"
    }),
    ...mapGetters("application-list", ["getCondition"]),
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    columnsHeader() {
      return [
        { key: "facilityName", title: "施設名", additionalClass: "w-12-em" },
        { key: "subscriptionStatus", title: "状態", additionalClass: "text-center w-5-em"  },
        { key: "sysFunctionList", title: "申込機能", additionalClass: "text-center w-12-em"  },
        { key: "applicantName", title: "申込者", additionalClass: "text-center w-8-em"  },
        { key: "regDate", title: "申込日時", additionalClass: "text-center w-5-em"  },
        { key: "receptionist", title: "受付者", additionalClass: "text-center w-8-em"  },
        { key: "receptionDate", title: "受付日時", additionalClass: "text-center w-5-em"  },
        { key: "completer", title: "完了者", additionalClass: "text-center w-8-em"  },
        { key: "completeDate", title: "完了日時", additionalClass: "text-center w-5-em"  },
        { key: "canceller", title: "申込キャンセル", additionalClass: "text-center w-5-em"  }
      ];
    },
    // 日機装社員か否かを返す
    isNkkStaff() {
      return this.stateUserAccountInfo.facilityCd === "nkknkk";
    },
    // 管理者ユーザか否かを返す
    isAdminUser() {
      return this.stateUserAccountInfo.administrator === 1;
    },
    /**
     * 申し込みリストを返す
     */
    dataSource() {
      const retList = this.filteredApplicationList(this.sortedItems);
      return retList;
    },
    /**
     * 項目リストをソートする
     */
    sortedItems() {
      const list = this.applicationList.slice();
      if (this.sort.key) {
        list.sort((a, b) => {
          a = a[this.sort.key];
          b = b[this.sort.key];

          let sortItem1 = 0;
          let sortItem2 = 0;

          if (a === b) {
            sortItem1 = 0;
          } else if (a > b) {
            sortItem1 = 1;
          } else {
            sortItem1 = -1;
          }
          if (this.sort.isAsc) {
            sortItem2 = 1;
          } else {
            sortItem2 = -1;
          }
          return sortItem1 * sortItem2;
        });
      }
      return list;
    }
  },
  watch: {
    windowHeight() {
      this.calculateTableHeight();
    },
    isDispMenu() {
      this.calculateTableHeight();
    },
    getFontSize() {
      this.calculateTableHeight();
    }
  },
  mounted() {
    this.$nextTick(() => {
      this.calculateTableHeight();
    });
    this.$nextTick(() => {
      let scrollArea = document.getElementById('scrollArea');
      scrollArea.addEventListener('scroll', async(event) => {
        let element = event.target;
        if (element.scrollHeight - element.scrollTop === element.clientHeight)
        {
          this.page++;
          await sendRequestGetAll(this.getCondition, this.page, PER_PAGE).then(res => {
            this.applicationList.push(...res.data);
          });
        }
      });
    });
  },

  async created() {
    if (this.isNkkStaff) {
      await this.init();
    } else {
      this.$router.go(-1);
    }
  },
  methods: {
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    /**
     * 申し込みリストをフィルターする
     */
    filteredApplicationList(application) {
      if (application.length === 0 || application.length === undefined) {
        return [];
      }
      return application
        .filter(data => {
          let isFilteringMyAccepted = true;
          if (this.getCondition.myAccepted) {
            isFilteringMyAccepted =
              data.receptionist !== null &&
              data.receptionist === this.stateUserAccountInfo.userId;
          }

          return isFilteringMyAccepted;
        })
        .slice();
    },
    /**
     * ソートしたクラス名
     */
    sortedClass(key) {
      return this.sort.key === key
        ? `sorted-${this.sort.isAsc ? "desc" : "asc"}`
        : "";
    },
    /**
     * 並び替え
     */
    sortBy(key) {
      if (key === this.sort.key && !this.sort.isAsc) {
        this.sort.key = "";
        this.sort.isAsc = true;
        return;
      }
      this.sort.isAsc = this.sort.key === key ? !this.sort.isAsc : true;
      this.sort.key = key;
    },
    /**
     * 要求フィルター
     */
    async setFilterCondition() {
      this.page = 1;
      await sendRequestGetAll(this.getCondition, this.page, PER_PAGE).then(res => {
        this.applicationList = res.data;
        if (this.scrollTopPos === '') {
          this.scrollTopPos = document.getElementById("scrollArea").scrollTop;
        }
        document.getElementById("scrollArea").scrollTop = this.scrollTopPos;
      });
    },
    /**
     * 一覧領域の高さを調整
     */
    calculateTableHeight() {
      const wh = this.windowHeight;
      if (!document.querySelector("#footer-menu")) return;
      const headerHight = document.querySelector("div.header").offsetHeight;
      const fmh =
        this.isDispMenu === 1
          ? document.querySelector("#footer-menu").clientHeight
          : 0;
      let tableHeight = 0;
      const loopId = setInterval(() => {
        if (document.querySelector("div.grid")) {
          const otherElementHeight = headerHight + fmh;
          tableHeight = wh - otherElementHeight;
          document.querySelector("div.grid").style.height = `${tableHeight}px`;
          clearInterval(loopId);
        }
      }, 300);
    },
    /**
     * 初期処理
     */
    async init() {
      // add 性能改善メモリ不足 shan start
      EventBus.$off("filterApplicationList",this.setFilterCondition);
      EventBus.$on("filterApplicationList", await this.setFilterCondition);
      // add 性能改善メモリ不足 shan end
    },
    /**
     * input内部データへフォーマットを変更
     */
    formatDate(date) {
      return dateFormat.format(new Date(date), DATE_TIME_FORMAT);
    },
    /**
     * 申し込みの状態を取得する。
     */
    getSubscriptionStatus(cd) {
      let status = "";
      if (this.statusList) {
        const element = this.statusList.find(item => item.cd.toString() == cd);
        if (element) {
          status = element.status;
        }
      }
      return status;
    },
    /**
     * 申し込みをキャンセルする。
     */
    async cancelTicket(subscriptionNo) {
      this.$ons.notification.confirm({
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
        // title: "内容破棄",
        title: DIALOG_MESSAGES[13000004].title,
        // message: "編集内容が破棄されます。</br>よろしいですか？",
         message: messageFormat(DIALOG_MESSAGES[13000004].message),
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
        callback: async answer => {
          if (answer === 1) {
            let cancelResp = await sendUpdateCancel(subscriptionNo);
            if (cancelResp && cancelResp.status === 200) {
              await this.setFilterCondition();
            } else {
              // console.log("cancel ticket failed");
            }
          }
        }
      });
    },
    /**
     * 申し込みを受付する。
     */
    async acceptTicket(subscriptionNo) {
      let acceptResp = await sendUpdateReception(subscriptionNo);
      if (acceptResp && acceptResp.status === 200) {
        await this.setFilterCondition();
      } else {
        // console.log("accept ticket failed");
      }
    },
    /**
     * 申し込みを完了する。
     */
    async completeTicket(subscriptionNo) {
      let completeResp = await sendUpdateCompletion(subscriptionNo);
      if (completeResp && completeResp.status === 200) {
        await this.setFilterCondition();
      } else {
        // console.log("complete ticket failed");
      }
    },
    /**
     * 色を設定する。
     */
    rowColor(cd) {
      if (this.statusList) {
        const element = this.statusList.find(item => item.cd == cd);
        if (element) {
          return { backgroundColor: `${element.bgColor} !important` };
        }
      }
      return {};
    },
    /**
     * 色に応じて文字色設定する(黒背景の時に見えにくい色の場合は文字色を黒のままにする)。
     */
    fontColorClass(cd) {
      if (this.statusList) {
        const element = this.statusList.find(item => item.cd == cd);
        if (element && element.bgColor !== "") {
          return "app-list-status-color";
        }
      }
      return null;
    },
    /**
     * ポップオーバーを表示する。
     */
    showPopOver(event, message) {
      this.viewFuncTexts = message;
      this.popoverTarget = event;
      this.popoverVisible = true;
    }
  },

  beforeDestroy() {
    EventBus.$off("filterApplicationList", this.setFilterCondition);
  }
};
</script>
<style scoped>
.grid {
  position: relative;
  overflow: auto;
}
.app-list-status-color td {
  color: #333333;
}
#master-list th,
#master-list td {
  white-space: nowrap;
}
#master-list td:nth-child(2) {
  padding-right: 30px;
}
.w-5-em {
  min-width: 5em;
}
.w-8-em {
  min-width: 8em;
}
.w-12-em {
  min-width: 12em;
}
.ntss-list-header-th-sticky {
  z-index: 100;
}
.text-center {
  text-align: center;
}
.button {
  width: 5em;
  height: 2em;
}
.help-area {
  margin: 1em;
}
.help-area label {
  font-size: 1.5em;
}
@media screen and (min-height:700px) {
  .app-list-popover >>> .popover__content {
    max-height: 600px !important;
  }
}
</style>
