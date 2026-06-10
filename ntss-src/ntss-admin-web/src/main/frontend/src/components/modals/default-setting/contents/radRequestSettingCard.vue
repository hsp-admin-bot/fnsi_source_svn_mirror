/**
 * デフォルト設定タブ - 一般撮影検査依頼一覧画面設定のコンポーネント
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
                <!--<label class="default-setting-content-label">表示期間・開始日</label>-->
                <label id="pc-show-rad-request" class="default-setting-content-label white-space-nowrap">表示期間・開始日</label>
                <label id="phone-show-rad-request" class="default-setting-content-label white-space-nowrap">表示期間・開始日</label>
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
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">表示期間・終了日</label>
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
                <label class="default-setting-content-label">詳細・簡易</label>
              </td>
              <td class="default-setting-content">
                <v-ons-radio
                  name="radio-is-show-details-display-rad"
                  value="1"
                  id="input-radio-detail"
                  modifier="round"
                  class="popover-content-radio radio-button radio-button--round"
                  v-model="isShowDetailsDisplay"
                />
                <label @click="clickTextIsShowDetailsDisplay('1')" class="label">詳細</label>
                <v-ons-radio
                  name="radio-is-show-details-display-rad"
                  value="2"
                  id="input-radio-simple"
                  modifier="round"
                  class="popover-content-radio radio-button radio-button--round"
                  v-model="isShowDetailsDisplay"
                />
                <label @click="clickTextIsShowDetailsDisplay('2')" class="label">簡易</label>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title-last-row">
                <label class="default-setting-content-label">患者ID列表示</label>
              </td>
              <td class="default-setting-content-last-row">
                <v-ons-switch v-model="isShowHospPatId"></v-ons-switch>
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
   import {DATE_CHOICES, RAD_REQUEST} from "@/constants/defaultSettingConstants";
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
      funcName:"一般撮影検査依頼一覧",
      // データ初期値
      initialValue: {},
      // 編集する一般撮影検査設定レコード
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
        name: RAD_REQUEST.KEY_NAME,
        data: {}
      };
      rtnData.data[RAD_REQUEST.KEY_NAME_START_DATE] = this.editRecord[RAD_REQUEST.KEY_NAME_START_DATE];
      rtnData.data[RAD_REQUEST.KEY_NAME_END_DATE] = this.editRecord[RAD_REQUEST.KEY_NAME_END_DATE];
      rtnData.data[RAD_REQUEST.KEY_NAME_IS_SHOW_DETAIL_DISPLAY] = this.editRecord[RAD_REQUEST.KEY_NAME_IS_SHOW_DETAIL_DISPLAY];
      rtnData.data[RAD_REQUEST.KEY_NAME_IS_SHOW_HOSP_PAT_ID] = this.editRecord[RAD_REQUEST.KEY_NAME_IS_SHOW_HOSP_PAT_ID];
      return rtnData;
    },
    // 詳細・簡易ラジオボタンのラベル押下時の動作
    clickTextIsShowDetailsDisplay(mode) {
      this.isShowDetailsDisplay = mode;
    }
  },
  computed: {
    ...mapGetters("account-edit", {
      getDefaultSetting: "getDefaultSetting"
    }),
    ...mapGetters("user", ["getFacilityCd"]),
    startDate: {
      get() {
        return this.editRecord[RAD_REQUEST.KEY_NAME_START_DATE];
      },
      set(value) {
        this.editRecord[RAD_REQUEST.KEY_NAME_START_DATE] = value;
      }
    },
    endDate: {
      get() {
        return this.editRecord[RAD_REQUEST.KEY_NAME_END_DATE];
      },
      set(value) {
        this.editRecord[RAD_REQUEST.KEY_NAME_END_DATE] = value;
      }
    },
    isShowDetailsDisplay: {
      get() {
        return this.editRecord[RAD_REQUEST.KEY_NAME_IS_SHOW_DETAIL_DISPLAY];
      },
      set(value) {
        this.editRecord[RAD_REQUEST.KEY_NAME_IS_SHOW_DETAIL_DISPLAY] = value;
      }
    },
    isShowHospPatId: {
      get() {
        return this.editRecord[RAD_REQUEST.KEY_NAME_IS_SHOW_HOSP_PAT_ID];
      },
      set(value) {
        this.editRecord[RAD_REQUEST.KEY_NAME_IS_SHOW_HOSP_PAT_ID] = value;
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
            EventBus.$emit("isChanged", {componentName: "radRequest", value: true});
            return;
          }
        }
        EventBus.$emit("isChanged", {componentName: "radRequest", value: false});
      },
      deep: true
    },
    //add FNSI-5687 劉全航 end
  },
  async created() {
    // 共通ローダー表示開始
    this.startLoadingScreen();
    // 初期値未設定の場合のデフォルト値
    this.initialValue[RAD_REQUEST.KEY_NAME_START_DATE] = DATE_CHOICES.TODAY.value; // 本日(固定)
    this.initialValue[RAD_REQUEST.KEY_NAME_END_DATE] = DATE_CHOICES.AFTER_THREE_MONTH.value; // 3ヶ月後
    this.initialValue[RAD_REQUEST.KEY_NAME_IS_SHOW_DETAIL_DISPLAY] = "1";
    this.initialValue[RAD_REQUEST.KEY_NAME_IS_SHOW_HOSP_PAT_ID] = false;

    this.$nextTick(() => {
      this.editRecord = deepCopy(this.getDefaultSetting[RAD_REQUEST.KEY_NAME]);
      // データが空の場合は初期値を適用する
      if (!this.editRecord || Object.keys(this.editRecord).length === 0) {
        this.editRecord = deepCopy(this.initialValue);
      } else {
        if (this.editRecord[RAD_REQUEST.KEY_NAME_START_DATE] == null) {
          this.editRecord[RAD_REQUEST.KEY_NAME_START_DATE] = this.initialValue[RAD_REQUEST.KEY_NAME_START_DATE];
        }
        if (this.editRecord[RAD_REQUEST.KEY_NAME_END_DATE] == null) {
          this.editRecord[RAD_REQUEST.KEY_NAME_END_DATE] = this.initialValue[RAD_REQUEST.KEY_NAME_END_DATE];
        }
        if (this.editRecord[RAD_REQUEST.KEY_NAME_IS_SHOW_DETAIL_DISPLAY] == null) {
          this.editRecord[RAD_REQUEST.KEY_NAME_IS_SHOW_DETAIL_DISPLAY] = this.initialValue[RAD_REQUEST.KEY_NAME_IS_SHOW_DETAIL_DISPLAY];
        }
        if (this.editRecord[RAD_REQUEST.KEY_NAME_IS_SHOW_HOSP_PAT_ID] == null) {
          this.editRecord[RAD_REQUEST.KEY_NAME_IS_SHOW_HOSP_PAT_ID] = this.initialValue[RAD_REQUEST.KEY_NAME_IS_SHOW_HOSP_PAT_ID];
        }
        this.initialValue = deepCopy(this.editRecord);
      }
      /*add FNSI-改修内容4214 任 start*/
      if($("#phone-show-rad-request").css("display") === "inline"){
        document.getElementById("phone-show-rad-request").innerText =  document.getElementById("phone-show-rad-request").innerText + '\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0';
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
    #pc-show-rad-request{display:none;}
  }
  @media (min-width: 501px){
    #phone-show-rad-request{display:none;}
  }
  /*add FNSI-改修内容4214 任 end*/
</style>
