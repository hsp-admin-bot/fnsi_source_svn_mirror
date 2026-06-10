/**
 * デフォルト設定タブ - 予実リスト設定のコンポーネント
 */
<template>
  <v-ons-list style="height: auto;" class="record-accordion">
    <v-ons-list-item modifier="nodivider" class="ntss-theme-screen" expandable :expanded.sync="isExpanded">
      <div class="top"><!-- OnsenUI挙動制御：自動挿入されるラッパー用divを予め書いておき適用されるスタイルを制御 -->
        <div class="center card-header color-header">
          {{ funcName }}
        </div>
        <div class="right"><!-- OnsenUI挙動制御：空にすることで矢印を抑制 --></div>
      </div>
      <div class="expandable-content card-contents">
        <table>
          <tbody>
            <tr>
              <td class="default-setting-content-title">
                <!--mod FNSI-改修内容4214 任 start-->
                <!--<label class="default-setting-content-label">開始日</label>-->
                <label id="pc-show-indication-result" class="default-setting-content-label white-space-nowrap">開始日</label>
                <label id="phone-show-indication-result" class="default-setting-content-label white-space-nowrap">開始日</label>
                <!--mod FNSI-改修内容4214 任 end-->
              </td>
              <td class="default-setting-content">
                <kendo-dropdownlist
                  :data-source="lstDispTermStart"
                  v-model="treatDateFrom"
                  data-text-field="title"
                  data-value-field="value"
                />
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">終了日</label>
              </td>
              <td class="default-setting-content">
                <kendo-dropdownlist
                  :data-source="lstDispTermEnd"
                  v-model="treatDateTo"
                  data-text-field="title"
                  data-value-field="value"
                />
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label"></label>
              </td>
              <td class="default-setting-content">
                <kendo-dropdownlist
                  :data-source="filters"
                  v-model="filter"
                  data-text-field="filterName"
                  data-value-field="filterId"
                />
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title-last-row">
                <label class="default-setting-content-label"></label>
              </td>
              <td class="default-setting-content-last-row">
                <kendo-multiselect
                  v-if="expressCondList !== null"
                  v-model="selectExpressCondList"
                  :data-source="expressCondList"
                  data-text-field="expressCondName"
                  data-value-field="expressCondCd"
                  style="width:100%;"
                  :autoClose="false"
                  autocomplete="new-password"
                />
                <div style="display: flex; flex-wrap: nowrap; align-items: center; margin-top: 0.5em">
                  <v-ons-checkbox
                    input-id="defaultPastSchCheck"
                    float
                    v-model="pastIndication"
                  ></v-ons-checkbox>
                  <label for="defaultPastSchCheck">過去予定</label>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </v-ons-list-item>
  </v-ons-list>
</template>

 <script>
   import {mapGetters, mapActions} from "vuex";
   /*add FNSI-改修内容4214 任 start*/
   import $ from "jquery";
   /*add FNSI-改修内容4214 任 end*/
   import {DATE_CHOICES, KEY_NAME_INDICATION_RESULT} from "@/constants/defaultSettingConstants";
   import {deepCopy} from "@/functions/common/CommonFunctions";
   //add FNSI-5687 劉全航 start
   import { EventBus } from "@/eventBus.js";
   //add FNSI-5687 劉全航 end

   export default {
  components: {
  },
  props: {
    // カード開閉初期状態
    defaultExpanded: {
      type: Boolean,
      default: true
    }
  },
  data() {
    return {
      // 対象の画面名
      funcName:"予実リスト",
      // データ初期値
      initialValue: {},
      // 編集する予実リスト設定レコード
      editRecord: {},
      // 表示期間開始日・選択肢
      lstDispTermStart: [
        DATE_CHOICES.TODAY,
        DATE_CHOICES.FIRSTDAY_OF_WEEK,
        DATE_CHOICES.BEFORE_ONE_WEEK,
        DATE_CHOICES.BEFORE_TWO_WEEK,
        DATE_CHOICES.BEFORE_ONE_MONTH,
        DATE_CHOICES.BEFORE_THREE_MONTH
      ],
      // 表示期間終了日・選択肢
      lstDispTermEnd: [
        DATE_CHOICES.TODAY,
        DATE_CHOICES.LASTDAY_OF_WEEK,
        DATE_CHOICES.AFTER_ONE_WEEK,
        DATE_CHOICES.AFTER_TWO_WEEK,
        DATE_CHOICES.AFTER_ONE_MONTH,
        DATE_CHOICES.AFTER_THREE_MONTH
      ],
      // 表示条件データ初期値
      expressCondList: [
        {"expressCondCd": "001", "expressCondName": "予定"},
        {"expressCondCd": "002", "expressCondName": "実績"}
      ],
      // カード開閉状態(初期値をfalseにすることでOnsenUI内部挙動との競合を抑制)
      isExpanded: false,
    };
  },
  computed: {
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("account-edit", {
      userInfo: "getStateUserAccountInfo",
      getDefaultSetting: "getDefaultSetting",
      getUseFunctions: "getUseFunctions"
    }),

    filters() {
      const filterList = [];
      filterList.push({"filterId": 1, "filterName": "カテゴリ、予実・日付"});
      filterList.push({"filterId": 2, "filterName": "カテゴリ、日付、予実"});
      filterList.push({"filterId": 3, "filterName": "カテゴリ、予実、日付"});
      filterList.push({"filterId": 4, "filterName": "日付、予実・カテゴリ"});
      filterList.push({"filterId": 5, "filterName": "日付、カテゴリ、予実"});
      filterList.push({"filterId": 6, "filterName": "日付、予実、カテゴリ"});
      return filterList;
    },

    // 開始日
    treatDateFrom: {
      get() {
        return this.editRecord[KEY_NAME_INDICATION_RESULT.KEY_NAME_TREAT_DATE_FROM];
      },
      set(value) {
        this.editRecord[KEY_NAME_INDICATION_RESULT.KEY_NAME_TREAT_DATE_FROM] = value;
      }
    },
    // 終了日
    treatDateTo: {
      get() {
        return this.editRecord[KEY_NAME_INDICATION_RESULT.KEY_NAME_TREAT_DATE_TO];
      },
      set(value) {
        this.editRecord[KEY_NAME_INDICATION_RESULT.KEY_NAME_TREAT_DATE_TO] = value;
      }
    },
    // フィルタ
    filter: {
      get() {
        return this.editRecord[KEY_NAME_INDICATION_RESULT.KEY_NAME_FILTER];
      },
      set(value) {
        this.editRecord[KEY_NAME_INDICATION_RESULT.KEY_NAME_FILTER] = value;
      }
    },
    // 表示条件
    selectExpressCondList: {
      get() {
        return this.editRecord[KEY_NAME_INDICATION_RESULT.KEY_NAME_SELECT_EXPRESS_COND_LIST];
      },
      set(value) {
        this.editRecord[KEY_NAME_INDICATION_RESULT.KEY_NAME_SELECT_EXPRESS_COND_LIST] = value;
      }
    },
    // 過去予定
    pastIndication: {
      get() {
        return this.editRecord[KEY_NAME_INDICATION_RESULT.KEY_NAME_PAST_INDICATION];
      },
      set(value) {
        this.editRecord[KEY_NAME_INDICATION_RESULT.KEY_NAME_PAST_INDICATION] = value;
      }
    }
  },
  methods: {
    ...mapActions(
      "loading-screen", ["startLoadingScreen","finishLoadingScreen"]
    ),
    getSaveData() {
      let rtnData = {
        name: KEY_NAME_INDICATION_RESULT.KEY_NAME,
        data: {}
      };
      rtnData.data[KEY_NAME_INDICATION_RESULT.KEY_NAME_TREAT_DATE_FROM] = this.editRecord[KEY_NAME_INDICATION_RESULT.KEY_NAME_TREAT_DATE_FROM];
      rtnData.data[KEY_NAME_INDICATION_RESULT.KEY_NAME_TREAT_DATE_TO] = this.editRecord[KEY_NAME_INDICATION_RESULT.KEY_NAME_TREAT_DATE_TO];
      rtnData.data[KEY_NAME_INDICATION_RESULT.KEY_NAME_FILTER] = this.editRecord[KEY_NAME_INDICATION_RESULT.KEY_NAME_FILTER];
      rtnData.data[KEY_NAME_INDICATION_RESULT.KEY_NAME_SELECT_EXPRESS_COND_LIST] = this.editRecord[KEY_NAME_INDICATION_RESULT.KEY_NAME_SELECT_EXPRESS_COND_LIST];
      rtnData.data[KEY_NAME_INDICATION_RESULT.KEY_NAME_PAST_INDICATION] = this.editRecord[KEY_NAME_INDICATION_RESULT.KEY_NAME_PAST_INDICATION];
      return rtnData;
    },
    async getExpressCondList() {
      let rtn = [];
      rtn.push({
        "expressCondCd": "001",
        "expressCondName": "予定"
      },
      {
        "expressCondCd": "002",
        "expressCondName": "実績"
      });
      let useFunctionsList = this.getUseFunctions;
      // アカウント設定情報がある場合
      if (useFunctionsList) {
        useFunctionsList.forEach(item => {
          switch (item) {
            // 患者イベント
            case "027":
              rtn.push({
                "expressCondCd": "003",
                "expressCondName": "患者イベント"
              });
              break;
            // 検査予定
            case "021":
              rtn.push({
                "expressCondCd": "004",
                "expressCondName": "検査予定"
              });
              break;
            // 検査結果
            case "018":
              rtn.push({
                "expressCondCd": "005",
                "expressCondName": "検査結果"
              });
              break;
            // 一般撮影予定
            case "022":
              rtn.push({
                "expressCondCd": "006",
                "expressCondName": "一般撮影予定"
              });
              break;
            // 処方
            case "029":
              rtn.push({
                "expressCondCd": "007",
                "expressCondName": "処方"
              });
              break;
          }
        });
      }
      // 表示条件情報のソート(予定、実績、患者イベント、検査予定、検査結果、一般撮影予定、処方)
      return rtn.sort((frontValue, behindValue) => frontValue.expressCondCd - behindValue.expressCondCd);
    }
  },
  watch: {
    //add FNSI-5687 劉全航 start
    editRecord: {
      handler(newValue, oldValue){
        var keySet = Object.keys(this.initialValue);
        for(let key of keySet){
          let initialValue = this.initialValue[key];
          let editValue = newValue[key];
          if(JSON.stringify(initialValue) !== JSON.stringify(editValue)){
            EventBus.$emit("isChanged", {componentName: "indicationResult", value: true});
            return;
          }
        }
        EventBus.$emit("isChanged", {componentName: "indicationResult", value: false});
      },
      deep: true
    }
    //add FNSI-5687 劉全航 end
  },
  async created() {
    // 共通ローダー表示開始
    this.startLoadingScreen();
    // 表示条件データを設定
    this.expressCondList = await this.getExpressCondList();
    // 初期値未設定の場合のデフォルト値
    this.initialValue[KEY_NAME_INDICATION_RESULT.KEY_NAME_TREAT_DATE_FROM] = DATE_CHOICES.BEFORE_ONE_WEEK.value; // 1週間前
    this.initialValue[KEY_NAME_INDICATION_RESULT.KEY_NAME_TREAT_DATE_TO] = DATE_CHOICES.AFTER_ONE_WEEK.value; // 1週間後
    this.initialValue[KEY_NAME_INDICATION_RESULT.KEY_NAME_FILTER] = "1";
    this.initialValue[KEY_NAME_INDICATION_RESULT.KEY_NAME_SELECT_EXPRESS_COND_LIST] = ["001", "002"];
    this.initialValue[KEY_NAME_INDICATION_RESULT.KEY_NAME_PAST_INDICATION] = false;

    this.$nextTick(() => {
      this.editRecord = deepCopy(this.getDefaultSetting[KEY_NAME_INDICATION_RESULT.KEY_NAME]);
      // データが空の場合は初期値を適用する
      if (!this.editRecord || Object.keys(this.editRecord).length === 0) {
        this.editRecord = deepCopy(this.initialValue);
      } else {
        if (this.editRecord[KEY_NAME_INDICATION_RESULT.KEY_NAME_TREAT_DATE_FROM] == null) {
          this.editRecord[KEY_NAME_INDICATION_RESULT.KEY_NAME_TREAT_DATE_FROM] = this.initialValue[KEY_NAME_INDICATION_RESULT.KEY_NAME_TREAT_DATE_FROM];
        }
        if (this.editRecord[KEY_NAME_INDICATION_RESULT.KEY_NAME_TREAT_DATE_TO] == null) {
          this.editRecord[KEY_NAME_INDICATION_RESULT.KEY_NAME_TREAT_DATE_TO] = this.initialValue[KEY_NAME_INDICATION_RESULT.KEY_NAME_TREAT_DATE_TO];
        }
        if (this.editRecord[KEY_NAME_INDICATION_RESULT.KEY_NAME_FILTER] == null) {
          this.editRecord[KEY_NAME_INDICATION_RESULT.KEY_NAME_FILTER] = this.initialValue[KEY_NAME_INDICATION_RESULT.KEY_NAME_FILTER];
        }
        if (this.editRecord[KEY_NAME_INDICATION_RESULT.KEY_NAME_SELECT_EXPRESS_COND_LIST] == null) {
          this.editRecord[KEY_NAME_INDICATION_RESULT.KEY_NAME_SELECT_EXPRESS_COND_LIST] = this.initialValue[KEY_NAME_INDICATION_RESULT.KEY_NAME_SELECT_EXPRESS_COND_LIST];
        }
        if (this.editRecord[KEY_NAME_INDICATION_RESULT.KEY_NAME_PAST_INDICATION] == null) {
          this.editRecord[KEY_NAME_INDICATION_RESULT.KEY_NAME_PAST_INDICATION] = this.initialValue[KEY_NAME_INDICATION_RESULT.KEY_NAME_PAST_INDICATION];
        }
        this.initialValue = deepCopy(this.editRecord);
      }
      /*add FNSI-改修内容4214 任 start*/
      if($("#phone-show-indication-result").css("display") === "inline"){
        document.getElementById("phone-show-indication-result").innerText =  document.getElementById("phone-show-indication-result").innerText + '\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0';
      }
      /*add FNSI-改修内容4214 任 end*/
      // 共通ローダー表示終了
      this.finishLoadingScreen();
      this.isExpanded = this.defaultExpanded;
    });
  },
  mounted() {
  }
};
</script>

<style scoped>
label.adjust {
  margin-left: 5px;
  margin-right: 7px;
  font-size: 1em;
  width: 3em;
}
/*add FNSI-改修内容4214 任 start*/
@media (max-width: 500px){
  #pc-show-indication-result{display:none;}
}
@media (min-width: 501px){
  #phone-show-indication-result{display:none;}
}
/*add FNSI-改修内容4214 任 end*/
</style>
