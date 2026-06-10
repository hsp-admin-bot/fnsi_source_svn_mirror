/**
 * デフォルト設定タブ - 検査依頼画面設定のコンポーネント
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
            <!-- 共通項目： 表示形式 -->
            <tr>
              <td class="default-setting-content-title"></td>
              <td class="default-setting-content">
                <div>
                  <input
                    type="radio"
                    class="identification"
                    name="defaultPeriodType"
                    value="1"
                    id="default-show-period"
                    @click="changePeriodType(1);"
                    :checked="isShow"
                  />
                  <label for="default-show-period" class="label first-of-type">期間</label>
                  <input
                    type="radio"
                    class="identification"
                    name="defaultPeriodType"
                    value="2"
                    id="default-show-day"
                    @click="changePeriodType(2);"
                    :checked="!isShow"
                  />
                  <label for="default-show-day" class="label last-of-type">一日</label>
                </div>
              </td>
            </tr>
            <!-- 表示形式[期間] : 表示期間・開始日 -->
            <tr v-if="isShow" :key="'start-date'">
              <td class="default-setting-content-title">
                <!--mod FNSI-改修内容4214 任 start-->
                <!--<label class="default-setting-content-label">表示期間・開始日</label>-->
                <label id="pc-show-exam-request" class="default-setting-content-label white-space-nowrap">表示期間・開始日</label>
                <label id="phone-show-exam-request" class="default-setting-content-label white-space-nowrap">表示期間・開始日</label>
                <!--mod FNSI-改修内容4214 任 end-->
              </td>
              <td class="default-setting-content">
                <kendo-dropdownlist
                  :data-source="lstDispTermStart"
                  v-model="startDate"
                  data-text-field="title"
                  data-value-field="value"
                  :disabled="true"
                />
              </td>
            </tr>
            <!-- 表示形式[一日] : 検査予定日 -->
            <tr v-else :key="'scheduled-date'">
              <td class="default-setting-content-title">
                <label class="default-setting-content-label white-space-nowrap">検査予定日</label>
              </td>
              <td class="default-setting-content">
                <kendo-dropdownlist
                  :data-source="lstDispScheduled"
                  v-model="scheduledDate"
                  data-text-field="title"
                  data-value-field="value"
                  :disabled="false"
                />
              </td>
            </tr>
            <!-- 表示形式[期間] : 表示期間・終了日 -->
            <tr v-if="isShow" :key="'term-end'">
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">表示期間・終了日</label>
              </td>
              <td class="default-setting-content">
                <kendo-dropdownlist
                  :data-source="lstDispTermEnd"
                  v-model="endDate"
                  data-text-field="title"
                  data-value-field="value"
                  :disabled="false"
                />
              </td>
            </tr>
            <!-- 表示形式[一日] : 検査区分 -->
            <tr v-else :key="'exam-type'">
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">検査区分</label>
              </td>
              <td class="default-setting-content" style="display: flex;">
                <div class="row-flex">
                  <v-ons-checkbox input-id="orderClassBeforeDialysis" value="1" v-model="examTypeListLocal" />
                  <label for="orderClassBeforeDialysis">透析前</label>
                </div>
                <div class="row-flex">
                  <v-ons-checkbox input-id="orderClassAfterDialysis" value="2" v-model="examTypeListLocal" />
                  <label for="orderClassAfterDialysis">透析後</label>
                </div>
                <div class="row-flex">
                  <v-ons-checkbox input-id="orderClassOther" value="0" v-model="examTypeListLocal" />
                  <label for="orderClassOther">その他</label>
                </div>
              </td>
            </tr>
            <!-- 表示形式[期間] : 詳細・簡易 -->
            <tr v-if="isShow" :key="'details-simple'">
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">詳細・簡易</label>
              </td>
              <td class="default-setting-content">
                <v-ons-radio
                  name="radio-is-show-details-display-exam"
                  value="1"
                  id="input-radio-detail"
                  modifier="round"
                  class="popover-content-radio radio-button radio-button--round"
                  v-model="isShowDetailsDisplay"
                />
                <label @click="clickTextIsShowDetailsDisplay('1')">詳細</label>
                <v-ons-radio
                  name="radio-is-show-details-display-exam"
                  value="2"
                  id="input-radio-simple"
                  modifier="round"
                  class="popover-content-radio radio-button radio-button--round"
                  v-model="isShowDetailsDisplay"
                />
                <label @click="clickTextIsShowDetailsDisplay('2')">簡易</label>
              </td>
            </tr>
            <!-- 表示形式[一日] : 予定あり患者のみ表示 -->
            <tr v-else>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">予定あり患者のみ表示</label>
              </td>
              <td class="default-setting-content">
                <v-ons-checkbox
                  v-model="editRecord.showScheduledOnly"
                />
              </td>
            </tr>
            <!-- 共通項目：患者ID列表示 -->
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">患者ID列表示</label>
              </td>
              <td class="default-setting-content">
                <v-ons-switch v-model="isShowHospPatId"></v-ons-switch>
              </td>
            </tr>
            <!-- 共通項目：血糖検査列表示 -->
            <tr>
              <td class="default-setting-content-title-last-row">
                <label class="default-setting-content-label">血糖検査列表示</label>
              </td>
              <td class="default-setting-content-last-row">
                <v-ons-switch v-model="isShowBloodGlucoseExam"></v-ons-switch>
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
   import {DATE_CHOICES, EXAM_REQUEST} from "@/constants/defaultSettingConstants";
   import {deepCopy} from "@/functions/common/CommonFunctions";
   //add FNSI-5687 劉全航 start
   import { EventBus } from "@/eventBus.js";
   //add FNSI-5687 劉全航 end
   import { RegOrderClassTextSet } from "@/constants/examRequestConstants";

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
      funcName:"検査依頼一覧",
      // データ初期値
      initialValue: {},
      // 編集する検査依頼設定レコード
      editRecord: {},
      // 表示期間開始日・選択肢
      lstDispTermStart: [
        DATE_CHOICES.TODAY,
      ],
      // 表示期間終了日・選択肢
      lstDispTermEnd: [
        DATE_CHOICES.AFTER_THREE_MONTH,
        DATE_CHOICES.AFTER_SIX_MONTH,
        DATE_CHOICES.AFTER_ONE_YEAR
      ],
      // 検査予定日・選択肢
      lstDispScheduled: [
        DATE_CHOICES.TODAY,
        DATE_CHOICES.TOMMOROW,
        DATE_CHOICES.DAY_AFTER_TOMMOROW,
        DATE_CHOICES.NEXT_MONDAY,
      ],
      // 検査区分初期値
      examTypeListLocal: [
        RegOrderClassTextSet[0].value,
        RegOrderClassTextSet[1].value,
        RegOrderClassTextSet[2].value,
      ],
      // カード開閉状態(初期値をfalseにすることでOnsenUI内部挙動との競合を抑制)
      isExpanded: false,
    };
  },
  methods: {
    ...mapActions(
      "loading-screen", ["startLoadingScreen","finishLoadingScreen"]
    ),
    getSaveData() {
      let rtnData = {
        name: EXAM_REQUEST.KEY_NAME,
        data: {}
      };
      rtnData.data[EXAM_REQUEST.KEY_NAME_START_DATE] = this.editRecord[EXAM_REQUEST.KEY_NAME_START_DATE];
      rtnData.data[EXAM_REQUEST.KEY_NAME_END_DATE] = this.editRecord[EXAM_REQUEST.KEY_NAME_END_DATE];
      rtnData.data[EXAM_REQUEST.KEY_NAME_IS_SHOW_DETAIL_DISPLAY] = this.editRecord[EXAM_REQUEST.KEY_NAME_IS_SHOW_DETAIL_DISPLAY];
      rtnData.data[EXAM_REQUEST.KEY_NAME_IS_SHOW_HOSP_PAT_ID] = this.editRecord[EXAM_REQUEST.KEY_NAME_IS_SHOW_HOSP_PAT_ID];
      rtnData.data[EXAM_REQUEST.KEY_NAME_IS_SHOW_BLOOD_GLUCOSE_EXAM] = this.editRecord[EXAM_REQUEST.KEY_NAME_IS_SHOW_BLOOD_GLUCOSE_EXAM];
      rtnData.data[EXAM_REQUEST.KEY_NAME_PERIOD_TYPE] = this.editRecord[EXAM_REQUEST.KEY_NAME_PERIOD_TYPE];
      rtnData.data[EXAM_REQUEST.KEY_NAME_SCHEDULED_DATE] = this.editRecord[EXAM_REQUEST.KEY_NAME_SCHEDULED_DATE];
      rtnData.data[EXAM_REQUEST.KEY_NAME_EXAM_TYPE_LIST] = this.editRecord[EXAM_REQUEST.KEY_NAME_EXAM_TYPE_LIST];
      rtnData.data[EXAM_REQUEST.KEY_NAME_SHOW_SCHEDULED_ONLY] = this.editRecord[EXAM_REQUEST.KEY_NAME_SHOW_SCHEDULED_ONLY];
      return rtnData;
    },
    // 詳細・簡易ラジオボタンのラベル押下時の動作
    clickTextIsShowDetailsDisplay(mode) {
      this.isShowDetailsDisplay = mode;
    },
    // 表示形式の切替処理
    changePeriodType(periodType) {
      this.editRecord[EXAM_REQUEST.KEY_NAME_PERIOD_TYPE] = periodType;
    },
  },
  computed: {
    ...mapGetters("account-edit", {
      getDefaultSetting: "getDefaultSetting"
    }),
    ...mapGetters("user", ["getFacilityCd"]),
    startDate: {
      get() {
        return this.editRecord[EXAM_REQUEST.KEY_NAME_START_DATE];
      },
      set(value) {
        this.editRecord[EXAM_REQUEST.KEY_NAME_START_DATE] = value;
      }
    },
    endDate: {
      get() {
        return this.editRecord[EXAM_REQUEST.KEY_NAME_END_DATE];
      },
      set(value) {
        this.editRecord[EXAM_REQUEST.KEY_NAME_END_DATE] = value;
      }
    },
    isShowDetailsDisplay: {
      get() {
        return this.editRecord[EXAM_REQUEST.KEY_NAME_IS_SHOW_DETAIL_DISPLAY];
      },
      set(value) {
        this.editRecord[EXAM_REQUEST.KEY_NAME_IS_SHOW_DETAIL_DISPLAY] = value;
      }
    },
    isShowHospPatId: {
      get() {
        return this.editRecord[EXAM_REQUEST.KEY_NAME_IS_SHOW_HOSP_PAT_ID];
      },
      set(value) {
        this.editRecord[EXAM_REQUEST.KEY_NAME_IS_SHOW_HOSP_PAT_ID] = value;
      }
    },
    isShowBloodGlucoseExam: {
      get() {
        return this.editRecord[EXAM_REQUEST.KEY_NAME_IS_SHOW_BLOOD_GLUCOSE_EXAM];
      },
      set(value) {
        this.editRecord[EXAM_REQUEST.KEY_NAME_IS_SHOW_BLOOD_GLUCOSE_EXAM] = value;
      }
    },
    isShow() {
      return this.editRecord[EXAM_REQUEST.KEY_NAME_PERIOD_TYPE] === 1 ? true : false;
    },
    scheduledDate: {
      get() {
        return this.editRecord[EXAM_REQUEST.KEY_NAME_SCHEDULED_DATE];
      },
      set(value) {
        this.editRecord[EXAM_REQUEST.KEY_NAME_SCHEDULED_DATE] = value;
      }
    },
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
            EventBus.$emit("isChanged", {componentName: "examRequest", value: true});
            return;
          }
        }
        EventBus.$emit("isChanged", {componentName: "examRequest", value: false});
      },
      deep: true
    },
    //add FNSI-5687 劉全航 end
    examTypeListLocal(newVal) {
      const initial = this.initialValue[EXAM_REQUEST.KEY_NAME_EXAM_TYPE_LIST];
      // 初期値と編集項目を比較（配列の順序を無視して、選択内容に差分がないかチェック）
      const sameSet = newVal.length === initial.length && newVal.every(v => initial.includes(v));
      // NOTE: watchのeditRecordで差分ありにならないようにするため、選択した内容が同じ場合、初期値に置き換える
      this.editRecord[EXAM_REQUEST.KEY_NAME_EXAM_TYPE_LIST] = deepCopy(sameSet ? initial : newVal);
    },
  },
  async created() {
    // 共通ローダー表示開始
    this.startLoadingScreen();
    // 初期値未設定の場合のデフォルト値
    this.initialValue[EXAM_REQUEST.KEY_NAME_START_DATE] = DATE_CHOICES.TODAY.value; // 本日(固定)
    this.initialValue[EXAM_REQUEST.KEY_NAME_END_DATE] = DATE_CHOICES.AFTER_THREE_MONTH.value; // 3ヶ月後
    this.initialValue[EXAM_REQUEST.KEY_NAME_IS_SHOW_DETAIL_DISPLAY] = "1";
    this.initialValue[EXAM_REQUEST.KEY_NAME_IS_SHOW_HOSP_PAT_ID] = true;
    this.initialValue[EXAM_REQUEST.KEY_NAME_IS_SHOW_BLOOD_GLUCOSE_EXAM] = false;
    this.initialValue[EXAM_REQUEST.KEY_NAME_PERIOD_TYPE] = 1;
    this.initialValue[EXAM_REQUEST.KEY_NAME_SCHEDULED_DATE] = DATE_CHOICES.TODAY.value; // 本日
    this.initialValue[EXAM_REQUEST.KEY_NAME_EXAM_TYPE_LIST] = this.examTypeListLocal;
    this.initialValue[EXAM_REQUEST.KEY_NAME_SHOW_SCHEDULED_ONLY] = false;

    this.$nextTick(() => {
      this.editRecord = deepCopy(this.getDefaultSetting[EXAM_REQUEST.KEY_NAME]);
      // データが空の場合は初期値を適用する
      if (!this.editRecord || Object.keys(this.editRecord).length === 0) {
        this.editRecord = deepCopy(this.initialValue);
      } else {
        if (this.editRecord[EXAM_REQUEST.KEY_NAME_START_DATE] == null) {
          this.editRecord[EXAM_REQUEST.KEY_NAME_START_DATE] = this.initialValue[EXAM_REQUEST.KEY_NAME_START_DATE];
        }
        if (this.editRecord[EXAM_REQUEST.KEY_NAME_END_DATE] == null) {
          this.editRecord[EXAM_REQUEST.KEY_NAME_END_DATE] = this.initialValue[EXAM_REQUEST.KEY_NAME_END_DATE];
        }
        if (this.editRecord[EXAM_REQUEST.KEY_NAME_IS_SHOW_DETAIL_DISPLAY] == null) {
          this.editRecord[EXAM_REQUEST.KEY_NAME_IS_SHOW_DETAIL_DISPLAY] = this.initialValue[EXAM_REQUEST.KEY_NAME_IS_SHOW_DETAIL_DISPLAY];
        }
        if (this.editRecord[EXAM_REQUEST.KEY_NAME_IS_SHOW_HOSP_PAT_ID] == null) {
          this.editRecord[EXAM_REQUEST.KEY_NAME_IS_SHOW_HOSP_PAT_ID] = this.initialValue[EXAM_REQUEST.KEY_NAME_IS_SHOW_HOSP_PAT_ID];
        }
        if (this.editRecord[EXAM_REQUEST.KEY_NAME_IS_SHOW_BLOOD_GLUCOSE_EXAM] == null) {
          this.editRecord[EXAM_REQUEST.KEY_NAME_IS_SHOW_BLOOD_GLUCOSE_EXAM] = this.initialValue[EXAM_REQUEST.KEY_NAME_IS_SHOW_BLOOD_GLUCOSE_EXAM];
        }
        if (this.editRecord[EXAM_REQUEST.KEY_NAME_PERIOD_TYPE] == null) {
          this.editRecord[EXAM_REQUEST.KEY_NAME_PERIOD_TYPE] = this.initialValue[EXAM_REQUEST.KEY_NAME_PERIOD_TYPE];
        }
        if (this.editRecord[EXAM_REQUEST.KEY_NAME_SCHEDULED_DATE] == null) {
          this.editRecord[EXAM_REQUEST.KEY_NAME_SCHEDULED_DATE] = this.initialValue[EXAM_REQUEST.KEY_NAME_SCHEDULED_DATE];
        }
        if (this.editRecord[EXAM_REQUEST.KEY_NAME_EXAM_TYPE_LIST] == null) {
          this.editRecord[EXAM_REQUEST.KEY_NAME_EXAM_TYPE_LIST] = this.initialValue[EXAM_REQUEST.KEY_NAME_EXAM_TYPE_LIST];
        }
        if (this.editRecord[EXAM_REQUEST.KEY_NAME_SHOW_SCHEDULED_ONLY] == null) {
          this.editRecord[EXAM_REQUEST.KEY_NAME_SHOW_SCHEDULED_ONLY] = this.initialValue[EXAM_REQUEST.KEY_NAME_SHOW_SCHEDULED_ONLY];
        }
        this.initialValue = deepCopy(this.editRecord);
      }
      // 画面編集用の検査区分
      this.examTypeListLocal = deepCopy(this.editRecord[EXAM_REQUEST.KEY_NAME_EXAM_TYPE_LIST] || []);
      /*add FNSI-改修内容4214 任 start*/
      if($("#phone-show-exam-request").css("display") === "inline"){
        document.getElementById("phone-show-exam-request").innerText =  document.getElementById("phone-show-exam-request").innerText + '\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0';
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
  /*add FNSI-改修内容4214 任 start*/
  @media (max-width: 500px){
    #pc-show-exam-request{display:none;}
  }
  @media (min-width: 501px){
    #phone-show-exam-request{display:none;}
  }
  /*add FNSI-改修内容4214 任 end*/
  input[type="radio"] {
    display: none; /* ラジオボタンを非表示にする */
  }
  .label {
    display: block; /* ブロックレベル要素化する */
    float: left; /* 要素の左寄せ・回り込を指定する */
    width: 6em; /* ボックスの横幅を指定する */
    height: 2em; /* ボックスの高さを指定する */
    padding-left: 5px; /* ボックス内左側の余白を指定する */
    padding-right: 5px; /* ボックス内御右側の余白を指定する */
    color: #ffffff; /* フォントの色を指定する */
    text-align: center; /* テキストのセンタリングを指定する */
    line-height: 2em; /* 行の高さを指定する */
    cursor: pointer; /* マウスカーソルの形（リンクカーソル）を指定する */
  }
  .first-of-type {
    border-radius: 10px 0 0 10px;
  }
  .last-of-type {
    border-radius: 0 10px 10px 0;
  }
</style>
