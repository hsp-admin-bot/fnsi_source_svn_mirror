/**
 * デフォルト設定タブ - 処方一覧設定のコンポーネント
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
                <label id="pc-show-pat-prescription-list" class="default-setting-content-label white-space-nowrap">患者ID列表示</label>
                <label id="phone-show-pat-prescription-list" class="default-setting-content-label white-space-nowrap">患者ID列表示</label>
              </td>
              <td class="default-setting-content">
                <v-ons-switch v-model="viewPatId"></v-ons-switch>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label id="pc-show-pat-prescription-list" class="default-setting-content-label white-space-nowrap">指示日情報列表示</label>
                <label id="phone-show-pat-prescription-list" class="default-setting-content-label white-space-nowrap">指示日情報列表示</label>
              </td>
              <td class="default-setting-content">
                <v-ons-switch v-model="viewDateInfo"></v-ons-switch>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">指定日</label>
              </td>
              <td class="default-setting-content">
                <kendo-dropdownlist
                  :data-source="lstDispSearchDate"
                  v-model="searchDate"
                  data-text-field="title"
                  data-value-field="value"
                />
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">過去処方表示</label>
              </td>
              <td class="default-setting-content" style="display: flex;">
                <div class="row-flex">
                  <v-ons-checkbox input-id="chkViewPreOut" v-model="viewPreOut" />
                  <label for="chkViewPreOut" class="radio-btn-label">院外</label>
                </div>
                <div class="row-flex">
                  <v-ons-checkbox input-id="chkViewPreIn" v-model="viewPreIn" />
                  <label for="chkViewPreIn" class="radio-btn-label">院内</label>
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
   import $ from "jquery";
   import {DATE_CHOICES, PAT_PRESCRIPTION_LIST} from "@/constants/defaultSettingConstants";
   import {deepCopy} from "@/functions/common/CommonFunctions";
   import { EventBus } from "@/eventBus.js";

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
      funcName:"処方一覧",
      // データ初期値
      initialValue: {},
      // 編集する処方一覧設定レコード
      editRecord: {},
      // 指示日・選択肢
      lstDispSearchDate: [
        DATE_CHOICES.TODAY,
        DATE_CHOICES.TOMMOROW,
        DATE_CHOICES.DAY_AFTER_TOMMOROW,
        DATE_CHOICES.NEXT_MONDAY,
        DATE_CHOICES.AFTER_ONE_WEEK,
        DATE_CHOICES.AFTER_ONE_MONTH,
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
        name: PAT_PRESCRIPTION_LIST.KEY_NAME,
        data: {}
      };
      rtnData.data[PAT_PRESCRIPTION_LIST.KEY_NAME_VIEW_PAT_ID] = this.editRecord[PAT_PRESCRIPTION_LIST.KEY_NAME_VIEW_PAT_ID];
      rtnData.data[PAT_PRESCRIPTION_LIST.KEY_NAME_VIEW_DATE_INFO] = this.editRecord[PAT_PRESCRIPTION_LIST.KEY_NAME_VIEW_DATE_INFO];
      rtnData.data[PAT_PRESCRIPTION_LIST.KEY_NAME_SEARCH_DATE] = this.editRecord[PAT_PRESCRIPTION_LIST.KEY_NAME_SEARCH_DATE];
      rtnData.data[PAT_PRESCRIPTION_LIST.KEY_NAME_VIEW_PRE_OUT] = this.editRecord[PAT_PRESCRIPTION_LIST.KEY_NAME_VIEW_PRE_OUT];
      rtnData.data[PAT_PRESCRIPTION_LIST.KEY_NAME_VIEW_PRE_IN] = this.editRecord[PAT_PRESCRIPTION_LIST.KEY_NAME_VIEW_PRE_IN];
      return rtnData;
    }
  },
  computed: {
    ...mapGetters("account-edit", {
      getDefaultSetting: "getDefaultSetting"
    }),
    viewPatId: {
      get() {
        return this.editRecord[PAT_PRESCRIPTION_LIST.KEY_NAME_VIEW_PAT_ID];
      },
      set(value) {
        this.editRecord[PAT_PRESCRIPTION_LIST.KEY_NAME_VIEW_PAT_ID] = value;
      }
    },
    viewDateInfo: {
      get() {
        return this.editRecord[PAT_PRESCRIPTION_LIST.KEY_NAME_VIEW_DATE_INFO];
      },
      set(value) {
        this.editRecord[PAT_PRESCRIPTION_LIST.KEY_NAME_VIEW_DATE_INFO] = value;
      }
    },
    searchDate: {
      get() {
        return this.editRecord[PAT_PRESCRIPTION_LIST.KEY_NAME_SEARCH_DATE];
      },
      set(value) {
        this.editRecord[PAT_PRESCRIPTION_LIST.KEY_NAME_SEARCH_DATE] = value;
      }
    },
    viewPreOut: {
      get() {
        return this.editRecord[PAT_PRESCRIPTION_LIST.KEY_NAME_VIEW_PRE_OUT];
      },
      set(value) {
        this.editRecord[PAT_PRESCRIPTION_LIST.KEY_NAME_VIEW_PRE_OUT] = value;
      }
    },
    viewPreIn: {
      get() {
        return this.editRecord[PAT_PRESCRIPTION_LIST.KEY_NAME_VIEW_PRE_IN];
      },
      set(value) {
        this.editRecord[PAT_PRESCRIPTION_LIST.KEY_NAME_VIEW_PRE_IN] = value;
      }
    },
  },
  watch: {
    editRecord: {
      handler(newValue, oldValue){
        var keySet = Object.keys(this.initialValue);
        for(let key of keySet){
          let initialValue = this.initialValue[key];
          let editValue = newValue[key];
          if(JSON.stringify(initialValue) !== JSON.stringify(editValue)){
            EventBus.$emit("isChanged", {componentName: "prescriptionList", value: true});
            return;
          }
        }
        EventBus.$emit("isChanged", {componentName: "prescriptionList", value: false});
      },
      deep: true
    },
  },
  async created() {
    // 共通ローダー表示開始
    this.startLoadingScreen();
    // 初期値未設定の場合のデフォルト値
    this.initialValue[PAT_PRESCRIPTION_LIST.KEY_NAME_VIEW_PAT_ID] = true
    this.initialValue[PAT_PRESCRIPTION_LIST.KEY_NAME_VIEW_DATE_INFO] = true;
    this.initialValue[PAT_PRESCRIPTION_LIST.KEY_NAME_SEARCH_DATE] = DATE_CHOICES.TODAY.value; // 本日
    this.initialValue[PAT_PRESCRIPTION_LIST.KEY_NAME_VIEW_PRE_OUT] = true;
    this.initialValue[PAT_PRESCRIPTION_LIST.KEY_NAME_VIEW_PRE_IN] = true;

    this.$nextTick(() => {
      this.editRecord = deepCopy(this.getDefaultSetting[PAT_PRESCRIPTION_LIST.KEY_NAME]);
      // データが空の場合は初期値を適用する
      if (!this.editRecord || Object.keys(this.editRecord).length === 0) {
        this.editRecord = deepCopy(this.initialValue);
      } else {
        if (this.editRecord[PAT_PRESCRIPTION_LIST.KEY_NAME_VIEW_PAT_ID] == null) {
          this.editRecord[PAT_PRESCRIPTION_LIST.KEY_NAME_VIEW_PAT_ID] = this.initialValue[PAT_PRESCRIPTION_LIST.KEY_NAME_VIEW_PAT_ID];
        }
        if (this.editRecord[PAT_PRESCRIPTION_LIST.KEY_NAME_VIEW_DATE_INFO] == null) {
          this.editRecord[PAT_PRESCRIPTION_LIST.KEY_NAME_VIEW_DATE_INFO] = this.initialValue[PAT_PRESCRIPTION_LIST.KEY_NAME_VIEW_DATE_INFO];
        }
        if (this.editRecord[PAT_PRESCRIPTION_LIST.KEY_NAME_SEARCH_DATE] == null) {
          this.editRecord[PAT_PRESCRIPTION_LIST.KEY_NAME_SEARCH_DATE] = this.initialValue[PAT_PRESCRIPTION_LIST.KEY_NAME_SEARCH_DATE];
        }
        if (this.editRecord[PAT_PRESCRIPTION_LIST.KEY_NAME_VIEW_PRE_OUT] == null) {
          this.editRecord[PAT_PRESCRIPTION_LIST.KEY_NAME_VIEW_PRE_OUT] = this.initialValue[PAT_PRESCRIPTION_LIST.KEY_NAME_VIEW_PRE_OUT];
        }
        if (this.editRecord[PAT_PRESCRIPTION_LIST.KEY_NAME_VIEW_PRE_IN] == null) {
          this.editRecord[PAT_PRESCRIPTION_LIST.KEY_NAME_VIEW_PRE_IN] = this.initialValue[PAT_PRESCRIPTION_LIST.KEY_NAME_VIEW_PRE_IN];
        }
        this.initialValue = deepCopy(this.editRecord);
      }
      if($("#phone-show-pat-prescription-list").css("display") === "inline"){
        document.getElementById("phone-show-pat-prescription-list").innerText =  document.getElementById("phone-show-pat-prescription-list").innerText + '\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0';
      }
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
  @media (max-width: 500px){
    #pc-show-pat-prescription-list{display:none;}
  }
  @media (min-width: 501px){
    #phone-show-pat-prescription-list{display:none;}
    .label{
      margin-right: 10px;
    }
  }
</style>
