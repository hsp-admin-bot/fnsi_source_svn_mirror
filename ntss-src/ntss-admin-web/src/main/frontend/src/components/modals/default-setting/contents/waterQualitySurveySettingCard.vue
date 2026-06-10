/**
 * デフォルト設定タブ - 水質管理設定のコンポーネント
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
                <label class="default-setting-content-label">開始日</label>
              </td>
              <td class="default-setting-content">
                <kendo-dropdownlist
                  :data-source="lstDispTermStart"
                  v-model="fromDate"
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
                  v-model="toDate"
                  data-text-field="title"
                  data-value-field="value"
                />
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">検査種別</label>
              </td>
              <td class="default-setting-content">
                <kendo-multiselect
                  :data-source="mstSurveyType"
                  v-model="surveyTypeCd"
                  data-text-field="surveyTypeName"
                  data-value-field="surveyTypeCd"
                  placeholder="すべて"
                />
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">ベッドグループ</label>
              </td>
              <td class="default-setting-content">
                <v-ons-select input-id="bedGroupCd" v-model="bedGroupCd">
                  <option
                    v-for="option in mstBedGroup"
                    :key="option.length"
                    :value="option.roomBedGroupCd"
                  >{{ option.roomBedGroupName }}</option>
                </v-ons-select>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">装置名列表示</label>
              </td>
              <td class="default-setting-content">
                <v-ons-switch v-model="isDispMachineName"></v-ons-switch>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title-last-row">
                <!--mod FNSI-改修内容4214 任 start-->
                <!--<label class="default-setting-content-label">調査種別列表示</label>-->
                <label id="pc-show-water-quality" class="default-setting-content-label white-space-nowrap">調査種別列表示</label>
                <label id="phone-show-water-quality" class="default-setting-content-label white-space-nowrap">調査種別列表示</label>
                <!--mod FNSI-改修内容4214 任 end-->
              </td>
              <td class="default-setting-content-last-row">
                <v-ons-switch v-model="isDispSurveyType"></v-ons-switch>
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
   import {DATE_CHOICES, WATER_QUALITY_SURVEY} from "@/constants/defaultSettingConstants";
   import {deepCopy} from "@/functions/common/CommonFunctions";
   import {ApiHelper} from "@/apis/AxiosHelper";
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
      funcName:"水質管理",
      // データ初期値
      initialValue: {},
      // 編集する水質管理設定レコード
      editRecord: {},
      // 表示期間開始日・選択肢
      lstDispTermStart: [
        DATE_CHOICES.TODAY,
        DATE_CHOICES.FIRSTDAY_OF_WEEK,
        DATE_CHOICES.BEFORE_ONE_WEEK,
        DATE_CHOICES.BEFORE_TWO_WEEK,
        DATE_CHOICES.BEFORE_ONE_MONTH,
        DATE_CHOICES.BEFORE_THREE_MONTH,
        DATE_CHOICES.BEFORE_SIX_MONTH,
        DATE_CHOICES.BEFORE_ONE_YEAR,
        DATE_CHOICES.BEFORE_THREE_YEAR
      ],
      // 表示期間終了日・選択肢
      lstDispTermEnd: [
        DATE_CHOICES.TODAY,
        DATE_CHOICES.LASTDAY_OF_WEEK,
        DATE_CHOICES.AFTER_ONE_WEEK,
        DATE_CHOICES.AFTER_TWO_WEEK,
        DATE_CHOICES.AFTER_ONE_MONTH,
        DATE_CHOICES.AFTER_THREE_MONTH,
        DATE_CHOICES.AFTER_SIX_MONTH,
        DATE_CHOICES.AFTER_ONE_YEAR
      ],
      // 調査種別一覧
      mstSurveyType: [],
      // ベッドグループ一覧
      mstBedGroup: [],
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
        name: WATER_QUALITY_SURVEY.KEY_NAME,
        data: {}
      };
      rtnData.data[WATER_QUALITY_SURVEY.KEY_NAME_FROM_DATE] = this.editRecord[WATER_QUALITY_SURVEY.KEY_NAME_FROM_DATE];
      rtnData.data[WATER_QUALITY_SURVEY.KEY_NAME_TO_DATE] = this.editRecord[WATER_QUALITY_SURVEY.KEY_NAME_TO_DATE];
      rtnData.data[WATER_QUALITY_SURVEY.KEY_NAME_SURVEY_TYPE_CD] = this.editRecord[WATER_QUALITY_SURVEY.KEY_NAME_SURVEY_TYPE_CD];
      rtnData.data[WATER_QUALITY_SURVEY.KEY_NAME_BED_GROUP_CD] = this.editRecord[WATER_QUALITY_SURVEY.KEY_NAME_BED_GROUP_CD];
      rtnData.data[WATER_QUALITY_SURVEY.KEY_NAME_IS_DISP_MACHINE_NAME] = this.editRecord[WATER_QUALITY_SURVEY.KEY_NAME_IS_DISP_MACHINE_NAME];
      rtnData.data[WATER_QUALITY_SURVEY.KEY_NAME_IS_DISP_SURVEY_TYPE] = this.editRecord[WATER_QUALITY_SURVEY.KEY_NAME_IS_DISP_SURVEY_TYPE];
      return rtnData;
    }
  },
  computed: {
    ...mapGetters("account-edit", {
      getDefaultSetting: "getDefaultSetting"
    }),
    ...mapGetters("user", ["getFacilityCd"]),
    fromDate: {
      get() {
        return this.editRecord[WATER_QUALITY_SURVEY.KEY_NAME_FROM_DATE];
      },
      set(value) {
        this.editRecord[WATER_QUALITY_SURVEY.KEY_NAME_FROM_DATE] = value;
      }
    },
    toDate: {
      get() {
        return this.editRecord[WATER_QUALITY_SURVEY.KEY_NAME_TO_DATE];
      },
      set(value) {
        this.editRecord[WATER_QUALITY_SURVEY.KEY_NAME_TO_DATE] = value;
      }
    },
    surveyTypeCd: {
      get() {
        return this.editRecord[WATER_QUALITY_SURVEY.KEY_NAME_SURVEY_TYPE_CD];
      },
      set(value) {
        this.editRecord[WATER_QUALITY_SURVEY.KEY_NAME_SURVEY_TYPE_CD] = value;
      }
    },
    bedGroupCd: {
      get() {
        return this.editRecord[WATER_QUALITY_SURVEY.KEY_NAME_BED_GROUP_CD];
      },
      set(value) {
        this.editRecord[WATER_QUALITY_SURVEY.KEY_NAME_BED_GROUP_CD] = value;
      }
    },
    isDispMachineName: {
      get() {
        return this.editRecord[WATER_QUALITY_SURVEY.KEY_NAME_IS_DISP_MACHINE_NAME];
      },
      set(value) {
        this.editRecord[WATER_QUALITY_SURVEY.KEY_NAME_IS_DISP_MACHINE_NAME] = value;
      }
    },
    isDispSurveyType: {
      get() {
        return this.editRecord[WATER_QUALITY_SURVEY.KEY_NAME_IS_DISP_SURVEY_TYPE];
      },
      set(value) {
        this.editRecord[WATER_QUALITY_SURVEY.KEY_NAME_IS_DISP_SURVEY_TYPE] = value;
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
            EventBus.$emit("isChanged", {componentName: "waterQUality", value: true});
            return;
          }
        }
        EventBus.$emit("isChanged", {componentName: "waterQUality", value: false});
      },
      deep: true
    },
    //add FNSI-5687 劉全航 end
  },
  async created() {
    // 共通ローダー表示開始
    this.startLoadingScreen();
    // 初期値未設定の場合のデフォルト値
    this.initialValue[WATER_QUALITY_SURVEY.KEY_NAME_FROM_DATE] = DATE_CHOICES.BEFORE_ONE_YEAR.value; // 1年前
    this.initialValue[WATER_QUALITY_SURVEY.KEY_NAME_TO_DATE] = DATE_CHOICES.AFTER_ONE_YEAR.value; // 1年後
    this.initialValue[WATER_QUALITY_SURVEY.KEY_NAME_SURVEY_TYPE_CD] = [];
    /* modify by shiyinwang 2022-10-20 Fix vue warning problem--start */
    // this.initialValue[WATER_QUALITY_SURVEY.KEY_NAME_BED_GROUP_CD] = [];
    // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_個別設定 20231117 ztc start
    //this.initialValue[WATER_QUALITY_SURVEY.KEY_NAME_BED_GROUP_CD] = ""; //this is a single select ,not a multi select
    this.initialValue[WATER_QUALITY_SURVEY.KEY_NAME_BED_GROUP_CD] = null;
    // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_個別設定 20231117 ztc end
    /* modify by shiyinwang 2022-10-20 Fix vue warning problem--end */
    this.initialValue[WATER_QUALITY_SURVEY.KEY_NAME_IS_DISP_MACHINE_NAME] = true;
    this.initialValue[WATER_QUALITY_SURVEY.KEY_NAME_IS_DISP_SURVEY_TYPE] = true;

    // 水質検査マスタ、透析室・ベッドグループマスタを取得
    const [
      responseMstSurveyType,
      responseBedGroup
    ] = await Promise.all([
      ApiHelper.get("/mstInfo/mstWaterSurveyType", {
        facilityCd: this.getFacilityCd
      }),
      ApiHelper.get("/mstInfo/mstRoomBedGroup", {
        facilityCd: this.getFacilityCd
      })
    ]);

    this.mstSurveyType = responseMstSurveyType.data;
    this.mstBedGroup = responseBedGroup.data;
    this.mstBedGroup.unshift({
      roomBedGroupCd: null,
      // #10997 Mod 個人設定＞デフォルト設定の各設定にてベッドグループが空値が初期表示になっている Start
      // roomBedGroupName: ""
      roomBedGroupName: "すべて"
      // #10997 Mod 個人設定＞デフォルト設定の各設定にてベッドグループが空値が初期表示になっている End
    });

    this.$nextTick(() => {
      this.editRecord = deepCopy(this.getDefaultSetting[WATER_QUALITY_SURVEY.KEY_NAME]);
      // データが空の場合は初期値を適用する
      if (!this.editRecord || Object.keys(this.editRecord).length === 0) {
        this.editRecord = deepCopy(this.initialValue);
      } else {
        if (this.editRecord[WATER_QUALITY_SURVEY.KEY_NAME_FROM_DATE] == null) {
          this.editRecord[WATER_QUALITY_SURVEY.KEY_NAME_FROM_DATE] = this.initialValue[WATER_QUALITY_SURVEY.KEY_NAME_FROM_DATE];
        }
        if (this.editRecord[WATER_QUALITY_SURVEY.KEY_NAME_TO_DATE] == null) {
          this.editRecord[WATER_QUALITY_SURVEY.KEY_NAME_TO_DATE] = this.initialValue[WATER_QUALITY_SURVEY.KEY_NAME_TO_DATE];
        }
        if (this.editRecord[WATER_QUALITY_SURVEY.KEY_NAME_SURVEY_TYPE_CD] == null) {
          this.editRecord[WATER_QUALITY_SURVEY.KEY_NAME_SURVEY_TYPE_CD] = this.initialValue[WATER_QUALITY_SURVEY.KEY_NAME_SURVEY_TYPE_CD];
        }
        if (this.editRecord[WATER_QUALITY_SURVEY.KEY_NAME_BED_GROUP_CD] == null) {
          this.editRecord[WATER_QUALITY_SURVEY.KEY_NAME_BED_GROUP_CD] = this.initialValue[WATER_QUALITY_SURVEY.KEY_NAME_BED_GROUP_CD];
        }
        if (this.editRecord[WATER_QUALITY_SURVEY.KEY_NAME_IS_DISP_MACHINE_NAME] == null) {
          this.editRecord[WATER_QUALITY_SURVEY.KEY_NAME_IS_DISP_MACHINE_NAME] = this.initialValue[WATER_QUALITY_SURVEY.KEY_NAME_IS_DISP_MACHINE_NAME];
        }
        if (this.editRecord[WATER_QUALITY_SURVEY.KEY_NAME_IS_DISP_SURVEY_TYPE] == null) {
          this.editRecord[WATER_QUALITY_SURVEY.KEY_NAME_IS_DISP_SURVEY_TYPE] = this.initialValue[WATER_QUALITY_SURVEY.KEY_NAME_IS_DISP_SURVEY_TYPE];
        }
        this.initialValue = deepCopy(this.editRecord);
      }
      /*add FNSI-改修内容4214 任 start*/
      if($("#phone-show-water-quality").css("display") === "inline"){
        document.getElementById("phone-show-water-quality").innerText =  document.getElementById("phone-show-water-quality").innerText + '\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0';
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
    #pc-show-water-quality{display:none;}
  }
  @media (min-width: 501px){
    #phone-show-water-quality{display:none;}
  }
  /*add FNSI-改修内容4214 任 end*/
</style>
