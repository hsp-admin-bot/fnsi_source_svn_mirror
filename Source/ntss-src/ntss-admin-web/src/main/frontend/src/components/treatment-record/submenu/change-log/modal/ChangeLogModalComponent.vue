/**
 * 変更履歴画面用ページ
 */
<template>
  <modal-base @onClose="cancel">
    <template #body>
      <div class="change-log-base">
      <div class="result-merge-candidates">
        <v-ons-row style="align-items: center;">
          <div class="change-log-list-header" style="margin-right: 0.5em;">
            <v-ons-select
              v-model="selectedRstEdition"
            >
              <template v-for="item in editionsList" :key="item.value">
                <option :value="item.value">{{ item.label }}</option>
              </template>
            </v-ons-select>
          </div>
          <div>
            <v-ons-button class="btn3-normal common-style-select-button" :disabled="!isBeforeSearch" @click="beforeSearch">前版</v-ons-button>
            <v-ons-button class="btn3-normal common-style-select-button" :disabled="!isNextSearch"  @click="nextSearch" style="margin-left: 10px">次版</v-ons-button>
          </div>
        </v-ons-row>
      </div>
      <div class="merge-items">
        <table class="ntss-list">
          <thead>
            <tr>
              <th class="ntss-list-header-th-sticky" width="20%">変更日時</th>
              <th class="ntss-list-header-th-sticky thick-border" width="60%">変更内容</th>
              <th class="ntss-list-header-th-sticky thick-border" width="20%">更新者</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(item, index) in targetItems" :key="index">
              <td
                class="ntss-list-body-td"
              >{{ item.changeDate }}</td>
              <td
                class="ntss-list-body-td" style="padding: 0"
              >
              <table border="0" cellspacing="0" cellpadding="0" width="100%">
                <!-- mod #6126 治療記録の変更履歴表示の第0版～第1版に1版の版確定の内容が表示されない 鄭爽　start -->
                <!--<tr v-for="(msg) in item.changeCmt" :key="msg" style="word-break:break-all; word-wrap:break-word">{{ msg }}</tr></table></td>-->
                <tr v-for="(msg, indexMsg) in item.changeCmt" :key="indexMsg" style="word-break:break-all; word-wrap:break-word">{{ msg }}</tr></table></td>
                <!-- mod #6126 治療記録の変更履歴表示の第0版～第1版に1版の版確定の内容が表示されない 鄭爽　end -->
              <td
                class="ntss-list-body-td"
              >{{ item.changeId }}</td>
            </tr>
          </tbody>
        </table>
      </div>
      </div>
    </template>
    <template #footer>
      <div class="modal-footer-custom">
      <v-ons-row>
        <v-ons-col>
          <v-ons-button class="btn2-cancel common-style-select-button" @click="cancel">
            閉じる
          </v-ons-button>
        </v-ons-col>
      </v-ons-row>
      </div>
    </template>
  </modal-base>
</template>

<script>
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import ModalBase from "@/components/modals/ModalBase";
import {sendRequestGetChangeLog} from "@/apis/log-reference";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
import { ApiHelper } from "@/apis/AxiosHelper";

export default {
  name: "changeLogModal",
  components: {
    "modal-base": ModalBase
  },
  data() {
    return {
      rstEditionMin: 0,
      rstEditionMax: null,
      ordNo: 0,
      selectedRstEdition: null,
      editionsList: [],
      facilityCd: "",
      targetItems: [],
    };
  },
  computed: {
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("pat-info", ["selectedPatId"]),
    ...mapGetters("treatment-record/common", [
      "getOrdNo"
    ]),
    isBeforeSearch() {
      return parseInt(this.selectedRstEdition) > parseInt(this.rstEditionMin);
    },
    isNextSearch() {
      return parseInt(this.selectedRstEdition) < parseInt(this.rstEditionMax);
    },
  },
  methods: {
    ...mapActions("multi-modal", ["hideModal"]),

    /**
     * 版リストの作成&反映処理
     */
    makeEditionsList() {
      // 判定用固定値
      const maxEdt = Number(this.rstEditionMax);
      
      // 処理用
      let lst = [];

      // 0～MAX値までの要素を配列に追加
      for (let i = 0; i <= maxEdt; i += 1) {
        let lbl = "";
        
        // MAX値の場合は次版がない為"第X版 ～ "を表示
        if (i == maxEdt) {
          lbl = `第${i}版 ～ `;
        } else {
          lbl = `第${i}版 ～ 第${i + 1}版`;
        }

        lst.push(
          {
            value: i,
            label: lbl,
          }
        );
      }

      // 反映
      this.editionsList = lst;
    },

    /**
     * キャンセル処理.
     */
    cancel() {
      this.hideModal();
    },

    beforeSearch() {
      this.selectedRstEdition = parseInt(this.selectedRstEdition) - 1;
    },

    nextSearch() {
      this.selectedRstEdition = parseInt(this.selectedRstEdition) + 1;
    },

    formatSendCondition() {
      let ordNo = 0;
      if (this.ordNo) {
        ordNo = this.ordNo;
      }
      return {
        ordNo: ordNo,
        rstEdition: this.selectedRstEdition
      };
    },

    /**
     * 一覧の取得
     */
    async search() {
      let sendCondition = this.formatSendCondition();
      const params = {
        folderName: this.facilityCd,
        condition: JSON.parse(JSON.stringify(sendCondition))
      }
      await sendRequestGetChangeLog(params).then(async response => {
        if (response.status === 200) {
          if (response.data && response.data.length > 0) {
            let list = [];
            response.data.forEach(e => {
              this.rstEditionMax = e.rstEditionMax;
              e.changeDate = e.upDate;
              e.changeCmt = e.message.split("<br>");
              e.changeId = e.upUserName;
              list.push(e);
            });
            this.targetItems = list;
          } else {
            let list = [];
            let tmp = {
              changeDate: "変更なし"
            };
            list.push(tmp);
            this.targetItems = list;
          }
        } else {
          let list = [];
          let tmp = {
            changeDate: "変更なし"
          };
          list.push(tmp);
          this.targetItems = list;
        }
      })
      .catch((err) => {
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
        getErrorMessage('ChangeLogModalComponent.vue','search',err);
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
        // console.log("Log reference error: ", err);
        let list = [];
        let tmp = {
          changeCmt: ["変更なし"]
        };
        list.push(tmp);
        this.targetItems = list;
      });
    },

    /**
     * 版の最大値を取得
     */
    async searchMinMax() {
      await ApiHelper.get(
        `/mainData/getOrdMainByOrdNo/${this.getOrdNo}`,
        { selectedPatId: this.selectedPatId }
      )
      .then(async response => {
        if (response.data) {
          this.rstEditionMax = String(response.data.rstEdition);
        }
      })
      .catch((err) => {
        getErrorMessage('ChangeLogModalComponent.vue','searchMinMax',err);
        this.targetItems = [];
      });
    },

    /**
     * モーダルOPEN時の処理
     */
    async createdProc() {
      this.ordNo = this.getOrdNo;
      this.facilityCd = this.getFacilityCd;
      // 版の最大値を取得
      await this.searchMinMax();
      // 初期表示時は版の最大値を検索するように指定
      this.selectedRstEdition = this.rstEditionMax;
    },
  },
  beforeUnmount() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
  created() {
    this.createdProc();
  },
  watch: {
    // 版最大値
    rstEditionMax: function() {
      // リストの更新
      this.makeEditionsList();
    },
    // 選択中の版
    selectedRstEdition: function() {
      // 検索実行
      this.search();
    },
  }
};
</script>

<style scoped>
.change-log-base {
  height: 100%;
  padding: 0px 4px;
}
.merge-items > table {
  position: relative;
}
.change-log-list-header {
  font-weight: bold;
  font-size: 1em;
}
th {
  z-index: 2;
}
.ntss-list-body-td {
  cursor: pointer;
}
.thick-border {
  border-left-width: 1px !important;
}
.ntss-list-body-td {
  border: solid 1px #cccccc;
}
.text-center {
  text-align: center;
}
.modal-footer-custom {
  padding: 10px;
  text-align: end;
}
.result-merge-candidates .ntss-list-body-td {
  cursor: pointer;
}
</style>
