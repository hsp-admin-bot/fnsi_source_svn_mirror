<!-- 処方箋のページ用ヘッダ -->
<template>
  <v-card>
    <div class='header-item'>
      <v-ons-row class='mark-leftmost-header' vertical-align="center">
        <v-ons-col class='condition-search-col' width="40%">
          <div class='condition-search-area' @click='showPopover($event)'>
            <div style="overflow: auto; height: 100%; width: 100%;" class="print_condition-search-area">
              <div class='condition-search-icon-area'>
                <v-ons-icon icon='fa-search' size='2.0em' style="color:gray;"></v-ons-icon>
              </div>
              <div class="condition-items-area">
                <label class='condition-label' v-if='condition.inUsed.viewPreOut'>
                  院外表示
                </label>
                <label class='condition-label' v-if='!condition.inUsed.viewPreOut'>
                  院外非表示
                </label>
                <label class='condition-label' v-if='condition.inUsed.viewPreIn'>
                  院内表示
                </label>
                <label class='condition-label' v-if='!condition.inUsed.viewPreIn'>
                  院内非表示
                </label>
                <label class='condition-label' v-if='condition.inUsed.searchDate'>
                  指定日：{{ getDispSearchDate() }}
                </label>
              </div>
            </div>
          </div>
        </v-ons-col>
        <v-ons-col style="flex: 0 0 30px;">
          <v-ons-button
            class="create-button btn3-normal"
            @click="showConfModal($event)"
            :disabled="!authorized"
          >
            <p class="style-text-button">一括</p>
            <p class="style-text-button">交付</p>
          </v-ons-button>
        </v-ons-col>
        <v-ons-col>
          <v-ons-button
            style="top:0px;left:5px;"
            class="create-button btn3-normal"
            @click='showOrderModal($event)'
            :disabled="!authorized"
          >
            <p class="style-text-button">一括</p>
            <p class="style-text-button">コピー</p>
          </v-ons-button>
        </v-ons-col>
      </v-ons-row>
    </div>

    <v-ons-popover cancelable
                   v-model:visible='popoverVisible'
                   :target='popoverTarget'
                   :direction='popoverDirection'
                   :cover-target=false
                   :class="fontSizeSet"
                   >
      <div style='margin:10px;'>
       <v-ons-row class='condition-row'>
          <v-ons-col width='70%' vertical-align='center'>
            <label>患者ID列表示</label>
          </v-ons-col>
          <v-ons-col width='30%' vertical-align='center'>
            <v-ons-switch input-id="switchPatId" v-model="condition.inProgress.viewPatId"></v-ons-switch>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class='condition-row'>
          <v-ons-col width='70%' vertical-align='center'>
            <label>指定日情報列表示</label>
          </v-ons-col>
          <v-ons-col width='30%' vertical-align='center'>
            <v-ons-switch input-id="switchExamDate" v-model="condition.inProgress.viewDateInfo"></v-ons-switch>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class='condition-row'>
          <v-ons-col width='30%' vertical-align='center'>
            <label>指定日</label>
          </v-ons-col>
          <v-ons-col width='70%' vertical-align='center'>
            <date-input
              v-model="condition.inProgress.searchDate"
              :classes="'input-area ntss-input-date ntss-custom-input start-date'"
              style="width:75%"
              isRequired
              />
            <common-calendar
              v-model="condition.inProgress.searchDate"
              class="calender start-date-comment"
              />
          </v-ons-col>

        </v-ons-row>
        <v-ons-row class='condition-row'>
          <v-ons-col width='100%' vertical-align='center'>
            <label>過去処方表示</label>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class='condition-row'>
          <v-ons-col width='10%' vertical-align='center'>
          </v-ons-col>
          <v-ons-col width='10%' vertical-align='center'>
            <v-ons-checkbox input-id='viewPreOut' float  v-model='condition.inProgress.viewPreOut'></v-ons-checkbox>
          </v-ons-col>
          <v-ons-col width='20%' vertical-align='center'>
            <label for="viewPreOut">院外</label>
          </v-ons-col>
          <v-ons-col width='10%' vertical-align='center'>
          </v-ons-col>
          <v-ons-col width='10%' vertical-align='center'>
            <v-ons-checkbox input-id='viewPreIn' float  v-model='condition.inProgress.viewPreIn'></v-ons-checkbox>
          </v-ons-col>
          <v-ons-col width='20%' vertical-align='center'>
            <label for="viewPreIn">院内</label>
          </v-ons-col>
        </v-ons-row>
        <div style="height:30px;margin-bottom:5px;" class="condition-row condition-button-area">
          <div style="float:left;" class="clear-button">
            <v-ons-button class="btn2-cancel common-style-cancel-button" @click="dialogClear">
              クリア
            </v-ons-button>
          </div>
          <div style="float:right;" class="ok-button">
            <v-ons-button class="btn3-normal common-style-ok-button" @click="dialogOk" :disabled="condition.inProgress.searchDate === null"  >
              OK
            </v-ons-button>
          </div>
        </div>

      </div>
    </v-ons-popover>
  </v-card>
</template>

<!-- スクリプト処理 -->
<script>
import { mapActions, mapGetters, mapMutations } from "@/compat/vue/vuex";
import dayjs from "@/compat/date/dayjs";
import { EventBus } from "@/compat/vue/event-bus.js";
import { deepCopy } from "@/functions/common/CommonFunctions";
import PopoverMixin from "@/components/PopoverMixin";

import MultiModalMixin from "@/components/modals/MultiModalMixin";
import UserAuthorityMixin from "@/components/common/UserAuthorityMixin";
import { AUTHORITY_CODES } from "@/constants/userAuthority";

import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
import DateInput from "@/components/common/DateInput.vue";
import { calcTargetDate } from "@/functions/modals/default-setting/defaultSettingUtils";
import { PAT_PRESCRIPTION_LIST } from "@/constants/defaultSettingConstants";

export default {
  mixins: [UserAuthorityMixin, MultiModalMixin, PopoverMixin],
  components: {
      "common-calendar": commonCalender,
      "date-input":DateInput,
    },
  data() {
    const defaultCondition = {
      viewPatId: true,
      viewDateInfo: true,
      searchDate: "",
      viewPreIn: true,
      viewPreOut: true,
      reSearchCount: 0
    };
    return {
      // 権限設定
      authorityCds: [ AUTHORITY_CODES.PRESCRIPTION_PEDIT, AUTHORITY_CODES.PRESCRIPTION_EDIT ],
      // ポップバー表示フラグ
      popoverVisible: false,
      popoverTarget: null,
      popoverDirection: "down",
      // 一括確定モーダルフラグ
      modalConfFlg: false,
      //権限別ボタン有効表示
      authorityOpacity: 1.0,
      condition: {
        // 入力中の検索条件
        inProgress: {
          ...defaultCondition
        },
        // 実際に検索に使用される条件
        inUsed: {
          ...defaultCondition
        }
      },
    };
  },
  computed: {
    isConfModalVisible() {
      // 画面からデータを取得
      return this.modalConfFlg;
    },
    ...mapGetters("account-edit", {
      defaultSetting: "getDefaultSetting"
    }),
    ...mapGetters("prescription/list", [
      "getCondition",
      "getDefaultCondition",
    ]),
  },
  methods: {
    ...mapActions("multi-modal", [
      "showPrescriptionConf",
      "showPrescriptionOrder"
    ]),
    ...mapActions("prescription/list", [
      "setCondition",
      "setDefaultCondition",
    ]),
    ...mapMutations("pat-prescription", [
      "setAppointedDate",
    ]),
    ...mapGetters("app", ["getQueryParameters"]),
    ...mapActions("app", ["setQueryParameters"]),
    getDispSearchDate(){
      const dispDate = dayjs(this.condition.inUsed.searchDate);
      this.setAppointedDate(dispDate.format("YYYY/MM/DD"));
      return dispDate.format("YYYY/MM/DD");
    },
    // -----------------------------------------
    // 一括確定保存モーダル表示イベント
    // -----------------------------------------
    showConfModal() {
      //登録・編集権限がある人のみ確定保存ダイアログ表示
      if(this.authorized){
        this.showPrescriptionConf();
      }
    },
    // -----------------------------------------
    // 一括処理オーダーモーダル表示イベント
    // -----------------------------------------
    showOrderModal() {
      //登録・編集権限がある人のみ確定保存ダイアログ表示
      if(this.authorized){
        this.showPrescriptionOrder();
      }
    },

    // -----------------------------------------
    // 抽出UI表示イベント
    // -----------------------------------------
    showPopover(event) {
      this.condition.inProgress = JSON.parse(JSON.stringify(this.condition.inUsed));
      this.popoverTarget = event;
      this.popoverVisible = true;
    },
    // -----------------------------------------
    // 抽出条件クリアボタンクリックイベント
    // -----------------------------------------
    dialogClear() {
      // 検索条件クリア
      this.condition.inProgress = JSON.parse(JSON.stringify(this.getDefaultCondition));      
    },
    // -----------------------------------------
    // 抽出条件OKボタンクリックイベント
    // -----------------------------------------
    dialogOk() {
      this.popoverVisible = false;
      this.search();
    },

    // ------------------------------------------------------------------
    // 処理：抽出条件を元にした検索イベント
    // ------------------------------------------------------------------
    search() {
      this.copyConditionInProgressToInUsed();
      // 検索条件の内容で画面を更新

      // 抽出条件登録
      this.setCondition(deepCopy(this.condition.inUsed));
    },

    copyConditionInProgressToInUsed() {
      this.condition.inUsed.viewPatId = this.condition.inProgress.viewPatId;
      this.condition.inUsed.viewDateInfo= this.condition.inProgress.viewDateInfo;
      this.condition.inUsed.searchDate= this.condition.inProgress.searchDate;
      this.condition.inUsed.viewPreOut= this.condition.inProgress.viewPreOut;
      this.condition.inUsed.viewPreIn= this.condition.inProgress.viewPreIn;
    },
  },
  async created() {
    if (this.getCondition){
      this.condition.inUsed = this.getCondition;
      // 画面遷移パラメータ取得
      const queryParameters = this.getQueryParameters();
      if (queryParameters.DATE) {
        const date = dayjs(queryParameters.DATE);
        if (date.isValid()) {
          this.condition.inUsed.searchDate = dayjs(queryParameters.DATE).format("YYYY-MM-DD");
        }
      }
      this.setQueryParameters({});
    } else {
      // サインインユーザのデフォルト設定を確認・設定
      const defaultPrescription = this.defaultSetting[PAT_PRESCRIPTION_LIST.KEY_NAME];
      if (defaultPrescription) {
        // 患者ID列表示
        if (defaultPrescription[PAT_PRESCRIPTION_LIST.KEY_NAME_VIEW_PAT_ID] !== undefined) {
          this.condition.inUsed.viewPatId = defaultPrescription[PAT_PRESCRIPTION_LIST.KEY_NAME_VIEW_PAT_ID];
        }
        // 指定日情報列表示
        if (defaultPrescription[PAT_PRESCRIPTION_LIST.KEY_NAME_VIEW_DATE_INFO] !== undefined) {
          this.condition.inUsed.viewDateInfo = defaultPrescription[PAT_PRESCRIPTION_LIST.KEY_NAME_VIEW_DATE_INFO];
        }
        // 指定日
        if (defaultPrescription[PAT_PRESCRIPTION_LIST.KEY_NAME_SEARCH_DATE] !== undefined && defaultPrescription[PAT_PRESCRIPTION_LIST.KEY_NAME_SEARCH_DATE] !== null) {
          this.condition.inUsed.searchDate = calcTargetDate(defaultPrescription[PAT_PRESCRIPTION_LIST.KEY_NAME_SEARCH_DATE])
        }
        // 過去処方表示
        // 院外
        if (defaultPrescription[PAT_PRESCRIPTION_LIST.KEY_NAME_VIEW_PRE_OUT] !== undefined) {
          this.condition.inUsed.viewPreOut = defaultPrescription[PAT_PRESCRIPTION_LIST.KEY_NAME_VIEW_PRE_OUT];
        }
        // 院内
        if (defaultPrescription[PAT_PRESCRIPTION_LIST.KEY_NAME_VIEW_PRE_IN] !== undefined) {
          this.condition.inUsed.viewPreIn = defaultPrescription[PAT_PRESCRIPTION_LIST.KEY_NAME_VIEW_PRE_IN];
        }
      }
      
      if (this.condition.inUsed.searchDate === "") {
        // 本日の日付をセット
        const nowDate = dayjs(new Date());
        this.condition.inUsed.searchDate = nowDate.format("YYYY-MM-DD");
      }
      
      // 初期抽出条件を設定
      this.setDefaultCondition(deepCopy(this.condition.inUsed));
    }
  },
  mounted() {
    // 抽出条件登録
    this.setCondition(deepCopy(this.condition.inUsed));
    //権限状況でボタン押下制御
    if(this.authorized){
      this.authorityOpacity = 1.0;
    }else{
      this.authorityOpacity = 0.5;
    }
    EventBus.$emit("addLeftmostHeaderMargin");
  }
};
</script>

<style scoped>
@import "../../assets/styles/modal.css";

.condition-search-icon-area-icon {
  color:gray;
  display: table-cell;
  width:2.5em;
  margin-top:1.5em;
}

.cls-prescription-box {
  color: white;
  font-size:1.1em;
  margin-top:0.3em;
  padding-top:0.3em;
  margin-right: 0.3em;
  height: 3.5em;
  background: #0076ff;
  text-align: center;
  border-radius: 5px;
}

.create-button,
.state-button {
  width: auto;
  font-size: 1em;
  display: inline-table;
  background-image: -webkit-linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,.1) 100%);
  background-image: linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,.1) 100%);
}

.style-text-button {
  margin: 0;
  line-height: 20px;
  font-size: 15px
}

@media print {
  .print_condition-search-area {
    overflow: auto !important;
  }
}

</style>
