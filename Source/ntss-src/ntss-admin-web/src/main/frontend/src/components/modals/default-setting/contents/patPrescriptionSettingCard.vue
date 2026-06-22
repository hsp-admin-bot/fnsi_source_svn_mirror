/**
 * デフォルト設定タブ - 処方設定のコンポーネント
 */
<template>
  <v-ons-list style="height: auto;" class="record-accordion">
    <v-ons-list-item modifier="nodivider" class="ntss-theme-screen" expandable v-model:expanded="isExpanded">
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
                <!--<label class="default-setting-content-label">交付日From</label>-->
                <label id="pc-show-pat-prescription" class="default-setting-content-label white-space-nowrap">交付日開始</label>
                <label id="phone-show-pat-prescription" class="default-setting-content-label white-space-nowrap">交付日開始</label>
                <!--mod FNSI-改修内容4214 任 end-->
              </td>
              <td class="default-setting-content">
                <kendo-dropdownlist
                  :data-source="lstDispTermStart"
                  v-model="startDate"
                  data-text-field="title"
                  data-value-field="value"
                />
                  </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">交付日終了</label>
              </td>
              <td class="default-setting-content">
                <kendo-dropdownlist
                  :data-source="lstDispTermEnd"
                  v-model="endDate"
                  data-text-field="title"
                  data-value-field="value"
                />
            </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <!-- mod #10184 処方画面文言修正 宮崎 start -->
                <label class="default-setting-content-label">処方区分</label>
                <!-- mod #10184 処方画面文言修正 宮崎 end -->
              </td>
              <td class="default-setting-content">
                <span
                  v-for="(filterItemHos,$index) in filterListHos"
                  :key="$index"
                >
                  <v-ons-radio
                    :input-id="'checkbox-' + $index"
                    :value="filterItemHos.code"
                    v-model="checkHos"
                    modifier="round"
                    class="popover-content-radio radio-button radio-button--round"
                  ></v-ons-radio>
                  <!--mod FNSI-改修内容4214 任 start-->
                  <!--<label @click="clickTextCheckHos(filterItemHos.code)">{{ filterItemHos.label }}</label>-->
                  <label @click="clickTextCheckHos(filterItemHos.code)" class="label">{{ filterItemHos.label }}</label>
                  <!--mod FNSI-改修内容4214 任 end-->
                </span>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title-last-row">
                <label class="default-setting-content-label">交付状況</label>
              </td>
              <td class="default-setting-content-last-row">
                <span
                  v-for="(filterItemIss,$index) in filterListIss"
                  :key="$index"
                >
                  <v-ons-radio
                    :input-id="'checkbox-' + $index"
                    :value="filterItemIss.code"
                    v-model="checkIss"
                    modifier="round"
                    class="popover-content-radio radio-button radio-button--round"
                  ></v-ons-radio>
                  <!--mod FNSI-改修内容4214 任 start-->
                  <!--<label @click="clickTextCheckIss(filterItemIss.code)">{{ filterItemIss.label }}</label>-->
                  <label @click="clickTextCheckIss(filterItemIss.code)" class="label">{{ filterItemIss.label }}</label>
                  <!--mod FNSI-改修内容4214 任 end-->
                </span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </v-ons-list-item>
  </v-ons-list>
</template>

 <script>
   import {mapGetters, mapActions} from "@/compat/vue/vuex";
   /*add FNSI-改修内容4214 任 start*/

   /*add FNSI-改修内容4214 任 end*/
   import {DATE_CHOICES, PAT_PRESCRIPTION} from "@/constants/defaultSettingConstants";
   import {deepCopy} from "@/functions/common/CommonFunctions";
   import {filterListHospital, filterListIssued} from "@/constants/filterList";
   //add FNSI-5687 劉全航 start
   import { EventBus } from "@/compat/vue/event-bus.js";
import { getScopedElementById, isScopedElementDisplayInline } from "@/functions/common/LayoutMeasureHelper";
   //add FNSI-5687 劉全航 end

   export default {
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
      funcName:"処方",
      // データ初期値
      initialValue: {},
      // 編集する処方設定レコード
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
      filterListHos: filterListHospital,
      filterListIss: filterListIssued,
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
        name: PAT_PRESCRIPTION.KEY_NAME,
        data: {}
      };
      rtnData.data[PAT_PRESCRIPTION.KEY_NAME_START_DATE] = this.editRecord[PAT_PRESCRIPTION.KEY_NAME_START_DATE];
      rtnData.data[PAT_PRESCRIPTION.KEY_NAME_END_DATE] = this.editRecord[PAT_PRESCRIPTION.KEY_NAME_END_DATE];
      rtnData.data[PAT_PRESCRIPTION.KEY_NAME_CHECK_HOS] = this.editRecord[PAT_PRESCRIPTION.KEY_NAME_CHECK_HOS];
      rtnData.data[PAT_PRESCRIPTION.KEY_NAME_CHECK_ISS] = this.editRecord[PAT_PRESCRIPTION.KEY_NAME_CHECK_ISS];
      return rtnData;
    },
    clickTextCheckHos(value) {
      if(value == null) {
        this.checkHos = "on";
      }else {
        this.checkHos = value;
      }
    },

    clickTextCheckIss(value) {
      if(value == null) {
        this.checkIss = "on"
      }else {
        this.checkIss = value;
      }
    },

  },
  computed: {
    ...mapGetters("account-edit", {
      getDefaultSetting: "getDefaultSetting"
    }),
    ...mapGetters("pat-event/list", [
      "getMstCategoryRecords",
      "getMstSubCategoryRecords"
    ]),
    startDate: {
      get() {
        return this.editRecord[PAT_PRESCRIPTION.KEY_NAME_START_DATE];
      },
      set(value) {
        this.editRecord[PAT_PRESCRIPTION.KEY_NAME_START_DATE] = value;
      }
    },
    endDate: {
      get() {
        return this.editRecord[PAT_PRESCRIPTION.KEY_NAME_END_DATE];
      },
      set(value) {
        this.editRecord[PAT_PRESCRIPTION.KEY_NAME_END_DATE] = value;
      }
    },
    checkHos: {
      get() {
        return this.editRecord[PAT_PRESCRIPTION.KEY_NAME_CHECK_HOS];
      },
      set(value) {
        this.editRecord[PAT_PRESCRIPTION.KEY_NAME_CHECK_HOS] = value;
      }
    },
    checkIss: {
      get() {
        return this.editRecord[PAT_PRESCRIPTION.KEY_NAME_CHECK_ISS];
      },
      set(value) {
        this.editRecord[PAT_PRESCRIPTION.KEY_NAME_CHECK_ISS] = value;
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
            EventBus.$emit("isChanged", {componentName: "prescription", value: true});
            return;
          }
        }
        EventBus.$emit("isChanged", {componentName: "prescription", value: false});
      },
      deep: true
    },
    //add FNSI-5687 劉全航 end
  },
  async created() {
    // 共通ローダー表示開始
    this.startLoadingScreen();
    // 初期値未設定の場合のデフォルト値
    this.initialValue[PAT_PRESCRIPTION.KEY_NAME_START_DATE] = DATE_CHOICES.BEFORE_THREE_MONTH.value; // 3ヶ月前
    this.initialValue[PAT_PRESCRIPTION.KEY_NAME_END_DATE] = DATE_CHOICES.AFTER_TWO_WEEK.value; // 2週間後
    this.initialValue[PAT_PRESCRIPTION.KEY_NAME_CHECK_HOS] = this.filterListHos[0].code;
    this.initialValue[PAT_PRESCRIPTION.KEY_NAME_CHECK_ISS] = this.filterListIss[0].code;

    this.$nextTick(() => {
      this.editRecord = deepCopy(this.getDefaultSetting[PAT_PRESCRIPTION.KEY_NAME]);
      // データが空の場合は初期値を適用する
      if (!this.editRecord || Object.keys(this.editRecord).length === 0) {
        this.editRecord = deepCopy(this.initialValue);
      } else {
        if (this.editRecord[PAT_PRESCRIPTION.KEY_NAME_START_DATE] == null) {
          this.editRecord[PAT_PRESCRIPTION.KEY_NAME_START_DATE] = this.initialValue[PAT_PRESCRIPTION.KEY_NAME_START_DATE];
        }
        if (this.editRecord[PAT_PRESCRIPTION.KEY_NAME_END_DATE] == null) {
          this.editRecord[PAT_PRESCRIPTION.KEY_NAME_END_DATE] = this.initialValue[PAT_PRESCRIPTION.KEY_NAME_END_DATE];
        }
        if (this.editRecord[PAT_PRESCRIPTION.KEY_NAME_CHECK_HOS] == null) {
          this.editRecord[PAT_PRESCRIPTION.KEY_NAME_CHECK_HOS] = this.initialValue[PAT_PRESCRIPTION.KEY_NAME_CHECK_HOS];
        }
        if (this.editRecord[PAT_PRESCRIPTION.KEY_NAME_CHECK_ISS] == null) {
          this.editRecord[PAT_PRESCRIPTION.KEY_NAME_CHECK_ISS] = this.initialValue[PAT_PRESCRIPTION.KEY_NAME_CHECK_ISS];
        }
        this.initialValue = deepCopy(this.editRecord);
      }
      /*add FNSI-改修内容4214 任 start*/
      if(isScopedElementDisplayInline("phone-show-pat-prescription", this.$el || this)){
        const phoneShowElement = getScopedElementById("phone-show-pat-prescription", this.$el || this);

        if (phoneShowElement) {

          phoneShowElement.innerText = phoneShowElement.innerText + '\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0';

        }
      }
      /*add FNSI-改修内容4214 任 end*/
      // 共通ローダー表示終了
      this.finishLoadingScreen();
      this.isExpanded = this.defaultExpanded;
    });
  },
};
</script>

<style scoped>
  /*add FNSI-改修内容4214 任 start*/
  @media (max-width: 500px){
    #pc-show-pat-prescription{display:none;}
  }
  @media (min-width: 501px){
    #phone-show-pat-prescription{display:none;}
    .label{
      margin-right: 10px;
    }
  }
  /*add FNSI-改修内容4214 任 end*/
</style>
