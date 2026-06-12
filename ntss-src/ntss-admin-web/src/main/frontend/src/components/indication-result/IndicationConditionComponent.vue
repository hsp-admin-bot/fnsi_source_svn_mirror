/**
 * 予実リストの表示情報設定コンポーネント
 */
<template>
  <div class="condition">
    <div class="grid-container">
      <div class="grid-row flex-align-center">
        <!-- #5590 2023/04/18 ×を常に表示するように修正 張博 start -->
        <!-- <input type="date" min='1880-01-01' max='2099-12-31' class="ntss-input-date ntss-control-size w-100" model-event="change" v-model="treatDateFrom" @blur="search" /> -->
        <date-input  min='1880-01-01' max='2099-12-31' class="ntss-input-date ntss-control-size w-100" @blur="search" v-model="treatDateFrom" @handleClearInput="treatDateFrom = null; search()" />
        <!-- #5590 2023/04/18 ×を常に表示するように修正 張博 end -->
        <common-calendar v-model="treatDateFrom" @input="search" @todayButtonClick="search" />
        <label class="adjust">&nbsp;&nbsp;〜&nbsp;&nbsp;</label>
      </div>
      <div class="grid-row flex-align-center">
        <!-- <input type="date" min='1880-01-01' max='2099-12-31' class="ntss-input-date ntss-control-size w-100" model-event="change" v-model="treatDateTo" @blur="search" /> -->
        <date-input  min='1880-01-01' max='2099-12-31' class="ntss-input-date ntss-control-size w-100" @blur="search" v-model="treatDateTo" @handleClearInput="treatDateTo = null; search()" />
        <!-- #5590 2023/04/18 ×を常に表示するように修正 張博 end -->
        <common-calendar v-model="treatDateTo" @input="search" @todayButtonClick="search" />
        <label class="adjust">&nbsp;</label>
      </div>
      <div class="grid-row grid-align-default">
        <!-- mod FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start -->
        <!-- <ntss-dropdown-list
          :data-source="filters"
          :data-text-field="'filterName'"
          :data-value-field="'filterId'"
          @select="onSelectFilter"
          style="width:100%;"
        ></ntss-dropdown-list> -->
        <!-- mod 6463 文字サイズ：特大の際にレイアウトが崩れる 周安寧 start-->
        <!-- <ntss-dropdown-list
          :data-source="filters"
          :data-text-field="'filterName'"
          :data-value-field="'filterId'"
          v-model="selectedFilter"
          @select="onSelectFilter"
          style="width:100%;"
        ></ntss-dropdown-list> -->
        <kendo-dropdownlist
          :data-source="filters"
          :data-text-field="'filterName'"
          :data-value-field="'filterId'"
          v-model="selectedFilter"
          @select="onSelectFilter"
          style="width:100%;font-size: 0.935em"
        ></kendo-dropdownlist>
        <!-- mod 6463 文字サイズ：特大の際にレイアウトが崩れる 周安寧 end-->
        <!-- mod FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end -->
      </div>
      <!-- mod FNSI-FutreNetWeb+SI課題管理No.3876 李 start -->
      <!-- <div class="grid-row grid-align-default"> -->
      <div class="grid-row grid-align-default" style="width: 250px">
      <!-- mod FNSI-FutreNetWeb+SI課題管理No.3876 李 end -->
        <!-- del FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start -->
        <!-- <div class style="display: flex; padding-top: 0.5em"> -->
        <!-- del FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end -->
          <!-- add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start -->
          <!--mod 3879 表示項目を1つずつしか選択できない 吉 start-->
          <!--<ntss-multi-select
            v-if="expressCondList !== null"
            v-model="selectExpressCondList"
            :data-source="expressCondList"
            data-text-field="expressCondName"
            data-value-field="expressCondCd"
            style="width:100%;"
          />-->
          <kendo-multiselect
            v-if="expressCondList !== null"
            v-model="selectExpressCondList"
            :data-source="expressCondList"
            data-text-field="expressCondName"
            data-value-field="expressCondCd"
            @select="onSelectFilter"
            style="width:100%;"
            :autoClose="false"
            autocomplete="new-password"
          />
          <!--mod 3879 表示項目を1つずつしか選択できない 吉 end-->
          <!-- add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end -->
          <!-- del FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start -->
          <!-- <input
            id="type_result"
            class="toggle"
            type="checkbox"
            name="indRstType"
            v-model="result"
            @change="filter"
          >
          <label for="type_result" class="toggle">実績</label>
          <input
            id="type_indication"
            class="toggle"
            type="checkbox"
            name="indRstType"
            v-model="indication"
            @change="filter"
          >
          <label for="type_indication" class="toggle">予定</label>
          <input
            id="past_indication"
            class="toggle"
            type="checkbox"
            v-model="pastIndication"
            @change="filter"
          />
          <label for="past_indication" class="toggle">過予</label> -->
        <!-- </div> -->
        <!-- del FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end -->
      </div>
      <!-- add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start -->
      <!-- mod FNSI-FutreNetWeb+SI課題管理No.3878 李 start -->
      <div class="pastSchedule">
        <!-- <label class="radio vertical-align-center">
          <input
            id="pastSchCheck"
            type="checkbox"
            v-model="pastIndication"
            @change="filter"
          />
          <span class="label">過去予定</span>
        </label> -->
        <v-ons-checkbox
          input-id="pastSchCheck"
          float
          v-model="pastIndication"
          @change="filter"
        ></v-ons-checkbox>
        <label for="pastSchCheck">過去予定</label>
      </div>
      <!-- mod FNSI-FutreNetWeb+SI課題管理No.3878 李 end -->
      <!-- add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end -->
    </div>
  </div>
</template>

<script>
// mod FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start
// import { mapGetters } from "@/compat/vue/vuex";
import { mapGetters, mapActions } from "@/compat/vue/vuex";
// mod FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end
import commonCalender from "@/components/common/custom-calendar/CustomCalendar.vue";
import { KEY_NAME_INDICATION_RESULT, DATE_CHOICES } from "@/constants/defaultSettingConstants";
import { calcTargetDate } from "@/functions/modals/default-setting/defaultSettingUtils";
import { deepCopy } from "@/functions/common/CommonFunctions";
import { ApiHelper } from "@/apis/AxiosHelper";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
import { EventBus } from "@/compat/vue/event-bus.js";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
// #5590 2023/04/18 ×を常に表示するように修正 張博 start
import DateInput from "@/components/common/DateInput.vue";
// #5590 2023/04/18 ×を常に表示するように修正 張博 end

export default {
  components: {
    "common-calendar": commonCalender,
    // #5590 2023/04/18 ×を常に表示するように修正 張博 start
    DateInput,
    // #5590 2023/04/18 ×を常に表示するように修正 張博 end
  },

  props: {
    // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start
    pattern: {
      type: Number,
      default: 1
    }
    // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end
  },

  data() {
    return {
      selectedFilter: null,
      patId: null,
      treatDateFrom: null,
      treatDateTo: null,
      backupDates: {
        treatDateFrom: null,
        treatDateTo: null
      },
      result: true,
      indication: true,
      pastIndication: false,
      // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start
      // 患者イベント
      patEvent: false,
      // 検査結果
      inspectionResult: false,
      // 検査予定
      // 一般撮影検査予定
      genPhoto: false,
      // 処方
      prescription: false,
      // 表示条件データ初期値
      expressCondList: [
        {"expressCondCd": "001", "expressCondName": "予定"},
        {"expressCondCd": "002", "expressCondName": "実績"}
      ],
      selectExpressCondList: ["001", "002"],
      // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end
      // add FNSI-改修内容検索条件ログ対応 李 start
      initialCount: 0 // >1 初期ない
      // add FNSI-改修内容検索条件ログ対応 李 end
    }
  },

  computed: {
    ...mapGetters("pat-info", ["selectedPatId"]),
    ...mapGetters("indication-result", ["getResultUpdate"]),
    ...mapGetters("account-edit", ["getDefaultSetting"]),
    // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start
    // アカウント情報を取得する
    ...mapGetters("account-edit", ["getUseFunctions"]),
    // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end
    filters() {
      const filterList = [];
      filterList.push({"filterId": 1, "filterName": "カテゴリ、予実・日付"});
      filterList.push({"filterId": 2, "filterName": "カテゴリ、日付、予実"});
      filterList.push({"filterId": 3, "filterName": "カテゴリ、予実、日付"});
      filterList.push({"filterId": 4, "filterName": "日付、予実・カテゴリ"});
      filterList.push({"filterId": 5, "filterName": "日付、カテゴリ、予実"});
      filterList.push({"filterId": 6, "filterName": "日付、予実、カテゴリ"});
      return filterList;
    }
  },

  methods: {
    // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start
    // storeにアカウント情報取得
    ...mapActions("account-edit", ["getUserAccountInfoSignIn"]),
    // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end
    /**
     * 検索・表示切替条件を生成する.
     */
    createSearchParams() {
      const from = this.treatDateFrom
        ? this.treatDateFrom.replace(/-/g, "")
        : null;
      const to = this.treatDateTo
        ? this.treatDateTo.replace(/-/g, "")
        : null;
      return {
        patId: this.selectedPatId,
        treatDateFrom: from,
        treatDateTo: to,
        result: this.result,
        indication: this.indication,
        pastIndication: this.pastIndication,
        // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start
        // 患者イベント
        patEvent: this.patEvent,
        // 検査結果
        inspectionResult: this.inspectionResult,
        // 検査予定
        inspectionSchedule: this.inspectionSchedule,
        // 一般撮影検査予定
        genPhoto: this.genPhoto,
        // 処方
        prescription: this.prescription
        // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end
      };
    },

    /**
     * 検索ボタンクリックハンドラ（親へ検索依頼）.
     */
    search() {
      // 前回検索時と同日付の場合は検索処理を行わない
      if (this.backupDates.treatDateFrom === this.treatDateFrom &&
        this.backupDates.treatDateTo === this.treatDateTo) {
          return;
      }
      // 検索日付をバックアップ
      this.backupTreatDates();
      
      // add FNSI-改修内容検索条件ログ対応 李 start
      if (this.initialCount > 1) {
        this.logMessage('');
      } else {
        this.initialCount++;
      }
      // add FNSI-改修内容検索条件ログ対応 李 end
      // 検索依頼通知
      this.$emit("search", this.createSearchParams());
    },

    // add FNSI-改修内容検索条件ログ対応 李 start
    /**
     * 検索ボタンクリックハンドラ（親へ検索依頼）.
     */
    searchSecond() {
      // 検索日付をバックアップ
      this.backupTreatDates();
      
      // 検索依頼通知
      this.$emit("search", this.createSearchParams());
    },
    // add FNSI-改修内容検索条件ログ対応 李 end

    /**
     * フィルタ項目変更イベントハンドラ（親へ依頼）
     */
    filter() {
      // add redmine 6058 yuqizheng start
      if ( true == this.pastIndication ) {
        this.pastIndication = false;
      } else if ( false == this.pastIndication ) {
        this.pastIndication = true;
      }
      // add redmine 6057 yuqizheng start
      this.search();
      // add redmine 6057 yuqizheng end
      // add redmine 6058 yuqizheng end
      // add FNSI-改修内容検索条件ログ対応 李 start
      this.logMessage('');
      // add FNSI-改修内容検索条件ログ対応 李 end
      // フィルタリング依頼通知
      this.$emit("filter", this.createSearchParams());
    },

    onSelectFilter(e) {
      // add FNSI-改修内容検索条件ログ対応 李 start
      this.logMessage(e.dataItem.filterId);
      // add FNSI-改修内容検索条件ログ対応 李 end
      // add redmine 6057 yuqizheng start
      this.search();
      // add redmine 6057 yuqizheng end
      this.$emit("switch", e.dataItem.filterId);
    },

    // add FNSI-改修内容検索条件ログ対応 李 start
    /**
     * 検索条件ログ対応
     */
    logMessage(filterId) {
      let msg = '予実リストが[';

      // 表示タイムの設定
      if (this.treatDateFrom) msg = msg + this.treatDateFrom;
      if (this.treatDateTo) msg = msg + '、' + this.treatDateTo;

      // 表示形式の設定
      let filtersList = [];
      if (filterId) filtersList = this.filters.find(item => item.filterId == filterId);
      else filtersList = this.filters.find(item => item.filterId == this.pattern);
      msg = msg + '、' + filtersList.filterName;

      // 表示カテゴリーの設定
      if (this.selectExpressCondList) {
        this.selectExpressCondList.forEach(item => {
          const condList = this.expressCondList.find(e => e.expressCondCd == item);
          if (condList) msg = msg + '、' + condList.expressCondName;
        })
      }

      // 過去予定の設定
      if (this.pastIndication) msg = msg + '、' + '過去予定';
      msg = msg + ']で検索しました。';

      // セッションに設定する
      let param = {'message': msg, 'functionName': '予実リスト'};
      ApiHelper.put("/logs/event/conditionlog", param)
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
          getErrorMessage('IndicationConditionComponent.vue','logMessage',error);
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
        });
    },
    // add FNSI-改修内容検索条件ログ対応 李 end

    // -----------------------------------------
    // 個人設定で登録した初期値をStoreに登録する
    // -----------------------------------------
    setDefaultCondition() {
      // 初期値を入れる
      this.treatDateFrom = calcTargetDate(DATE_CHOICES.BEFORE_ONE_WEEK.value),
      this.treatDateTo = calcTargetDate(DATE_CHOICES.AFTER_ONE_WEEK.value),
      this.result = true;
      this.indication = true;
      this.pastIndication = false;

      // デフォルト設定
      const defaultCondition = deepCopy(this.getDefaultSetting[KEY_NAME_INDICATION_RESULT.KEY_NAME]);
      if (defaultCondition) {
        // デフォルト設定が存在する場合は適用
        if (defaultCondition[KEY_NAME_INDICATION_RESULT.KEY_NAME_TREAT_DATE_FROM] != null) {
          this.treatDateFrom = calcTargetDate(defaultCondition[KEY_NAME_INDICATION_RESULT.KEY_NAME_TREAT_DATE_FROM]);
        }
        if (defaultCondition[KEY_NAME_INDICATION_RESULT.KEY_NAME_TREAT_DATE_TO] != null) {
          this.treatDateTo = calcTargetDate(defaultCondition[KEY_NAME_INDICATION_RESULT.KEY_NAME_TREAT_DATE_TO]);
        }
        if (defaultCondition[KEY_NAME_INDICATION_RESULT.KEY_NAME_FILTER] != null) {
          // 表示形式は親要素に通知して切り替えを実施する
          const filterNum = parseInt(defaultCondition[KEY_NAME_INDICATION_RESULT.KEY_NAME_FILTER]);
          this.selectedFilter = filterNum;
          this.$emit("switch", filterNum);
        }
        if (defaultCondition[KEY_NAME_INDICATION_RESULT.KEY_NAME_SELECT_EXPRESS_COND_LIST] != null) {
          let tmpList = [];
          defaultCondition[KEY_NAME_INDICATION_RESULT.KEY_NAME_SELECT_EXPRESS_COND_LIST].forEach(cond => {
            if (this.expressCondList.find(item => item.expressCondCd == cond)) {
              tmpList.push(cond);
            }
          });
          this.selectExpressCondList = tmpList;
        }
        if (defaultCondition[KEY_NAME_INDICATION_RESULT.KEY_NAME_PAST_INDICATION] != null) {
          this.pastIndication = defaultCondition[KEY_NAME_INDICATION_RESULT.KEY_NAME_PAST_INDICATION];
        }
      }
      // フィルタリング依頼通知
      this.$emit("filter", this.createSearchParams());
    },
    backupTreatDates() {
      this.backupDates.treatDateFrom = this.treatDateFrom;
      this.backupDates.treatDateTo = this.treatDateTo;
    },
  },

  watch: {
    /**
     * 患者IDを監視.
     */
    selectedPatId(newVal, oldVal) {
      if (newVal !== oldVal) {
        // mod FNSI-改修内容検索条件ログ対応 李 start
        // this.search();
        this.searchSecond();
        // add FNSI-改修内容検索条件ログ対応 李 end
      }
    },
    //add redmine 6057 yuqizheng start
    /**
     * routerを監視.
     */
    $route(from,to){
      if(from.name !== to.name){
        this.searchSecond();
      }
    },
    //add redmine 6057 yuqizheng end
    /**
     * 実績情報更新日時を監視する.
     */
    getResultUpdate() {
      this.search();
    },

    // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start
    /**
     * 表示条件を監視する.
     */
    selectExpressCondList() {
      // 表示条件を初期化する
      this.indication = false;
      this.result = false;
      this.patEvent = false;
      this.inspectionResult = false;
      this.inspectionSchedule = false;
      this.genPhoto = false;
      this.prescription = false;

      // 表示条件を設定する
      this.selectExpressCondList.forEach(
        expressCondCd => {
          switch (expressCondCd) {
            // 予定
            case "001":
              this.indication = true;
              break;
            // 実績
            case "002":
              this.result = true;
              break;
            // 患者イベント
            case "003":
              this.patEvent = true;
              break;
            // 検査予定
            case "004":
              this.inspectionSchedule = true;
              break;
            // 検査結果
            case "005":
              this.inspectionResult = true;
              break;
            // 一般撮影予定
            case "006":
              this.genPhoto = true;
              break;
            // 処方
            case "007":
              this.prescription = true;
              break;
            default:
              break;
          }
      })
      // add FNSI-改修内容検索条件ログ対応 李 start
      // 検索条件ログ対応
      this.logMessage('');
      // add FNSI-改修内容検索条件ログ対応 李 end
      // フィルタリング依頼通知
      this.$emit("filter", this.createSearchParams());
      // 画面サイズが変わる
      this.$emit("screenSizeChanges");
    },

    /**
     * アカウント設定情報を監視する.
     */
    getUseFunctions() {
      this.expressCondList = [];
      this.expressCondList.push({
        "expressCondCd": "001",
        "expressCondName": "予定"
      },
      {
        "expressCondCd": "002",
        "expressCondName": "実績"
       });

      // mod #10359、#10331 編集権限について、対応する。 dengshen start
      // let useFunctionsList = this.getUseFunctions;
      // // アカウント設定情報があるの場合
      // if (useFunctionsList) {
      //   useFunctionsList.forEach(item => {
      //     switch (item) {
      //       // 患者イベント
      //       case "027":
      //         this.expressCondList.push({
      //           "expressCondCd": "003",
      //           "expressCondName": "患者イベント"
      //         });
      //         break;
      //       // 検査予定
      //       case "021":
      //         this.expressCondList.push({
      //           "expressCondCd": "004",
      //           "expressCondName": "検査予定"
      //         });
      //         break;
      //       // 検査結果
      //       case "018":
      //         this.expressCondList.push({
      //           "expressCondCd": "005",
      //           "expressCondName": "検査結果"
      //         });
      //         break;
      //       // 一般撮影予定
      //       case "022":
      //         this.expressCondList.push({
      //           "expressCondCd": "006",
      //           "expressCondName": "一般撮影予定"
      //         });
      //         break;
      //       // 処方
      //       case "029":
      //         this.expressCondList.push({
      //           "expressCondCd": "007",
      //           "expressCondName": "処方"
      //         });
      //         break;
      //     }
      //   })
      // }
      this.expressCondList.push({
        "expressCondCd": "003",
        "expressCondName": "患者イベント"
      }, {
        "expressCondCd": "004",
        "expressCondName": "検査予定"
      }, {
        "expressCondCd": "005",
        "expressCondName": "検査結果"
      }, {
        "expressCondCd": "006",
        "expressCondName": "一般撮影予定"
      }, {
        "expressCondCd": "007",
        "expressCondName": "処方"
      });
      // mod #10359、#10331 編集権限について、対応する。 dengshen end
      // 表示条件情報のソート(予定、実績、患者イベント、検査予定、検査結果、一般撮影予定、処方)
      this.expressCondList.sort((frontValue, behindValue) => frontValue.expressCondCd - behindValue.expressCondCd);
    }
    // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end
  },

  // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start
  /**
   * ユーザー権限の判断
   */
  async created() {
    // アカウント設定情報を取得する。
    // 患者検索と予実リストのコンポーネントが生成されるタイミングでサインイン時にAccountEditStoreに設定したクール指定がクリアされるため、
    // サインイン時と同じgetUserAccountInfoSignInでアカウント情報取得（時刻によるクール指定あり）を呼び出す
    await this.getUserAccountInfoSignIn();
    // 初期設定の適用
    this.setDefaultCondition();
    // add redmine 6057 yuqizheng start
    EventBus.$off("refresh", this.search);
    EventBus.$on("refresh", this.search);
    EventBus.$off("indicationRefresh", this.search);
    EventBus.$on("indicationRefresh", this.search);
    // add redmine 6057 yuqizheng end
  },
  // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end

  mounted() {

    this.$nextTick(() => {
      // 検索日付をバックアップ
      this.backupTreatDates();
      // 親へ検索依頼通知する
      this.$emit("search", this.createSearchParams());
    });
  }
};
</script>

<style scoped>
.grid-container {
  display: inline-block;
  position: relative;
}

.grid-row {
  display: flex;
  align-items: center;
  padding-top: 0.5em;
}

.grid-align-default {
  justify-content: space-between;
}

.grid-align-right {
  justify-content: flex-end;
}

input[type="checkbox"].toggle {
  display: none;
}

label.toggle {
  display: block;
  min-width: 2.5em;
  padding: 0.5em;
  margin: 0 0.5em 0.5em 0;
  border-radius: 5px;
  background-color: #c0c0c0;
  text-align: center;
  color: #333;
  font-size: 1em;
  padding: 0.2em 1em 0em 1em;
  line-height: 2em;
  background-image: -webkit-linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,.1) 100%);
  background-image: linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,.1) 100%);
  box-shadow: 0 2px 2px 0 rgba(255,255,255,.2) inset, 0 2px 20px 0 rgba(255,255,255,.5) inset, 0 -2px 2px 0 rgba(0,0,0,.1);
}

input[type="checkbox"]:checked.toggle + label.toggle {
  background-color: #0076ff;
  color: #fff;
    background-image: -webkit-linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,.1) 100%);
  background-image: linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,.1) 100%);
  box-shadow: 0 2px 2px 0 rgba(255,255,255,.2) inset, 0 2px 20px 0 rgba(255,255,255,.5) inset, 0 -2px 2px 0 rgba(0,0,0,.1);
}

label.adjust {
  margin-left: 5px;
  margin-right: 7px;
  font-size: 1em;
  width: 3em;
}

.ntss-input-date {
  padding-right: 2px;
}

/** add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start */
/* mod FNSI-FutreNetWeb+SI課題管理No.3878 李 start */
.pastSchedule{
  margin-top: 0.5em;
  display: flex;
  align-items: center;
  justify-content: flex-end;
}
/* mod FNSI-FutreNetWeb+SI課題管理No.3878 李 end */

label {
  user-select: none;
}
/** add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end */
</style>
