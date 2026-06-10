/**
 * デフォルト設定タブ - 観察記録のコンポーネント
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
                <label id="pc-show-observe-record" class="default-setting-content-label white-space-nowrap">カテゴリ</label>
                <label id="phone-show-observe-record" class="default-setting-content-label white-space-nowrap">カテゴリ</label>
              </td>
			  <td class="default-setting-content">
			    <kendo-dropdownlist
			      :data-source="selectTemplates"
			      v-model="obsKindList"
			      data-text-field="name"
			      data-value-field="code"
			    />
			  </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">開始日</label>
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
                <label class="default-setting-content-label">終了日</label>
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
              <td class="default-setting-content-title-last-row">
              </td>
              <td class="default-setting-content-last-row" style="display: flex;">
                <div class="row-flex">
                  <v-ons-checkbox input-id="chkDispIsDraft" v-model="dispIsDraft"></v-ons-checkbox>
                  <label for="chkDispIsDraft">自分が新規作成</label>
                </div>
                &nbsp;&nbsp;
                <div class="row-flex">
                  <v-ons-checkbox input-id="chkDispIsEdit" v-model="dispIsEdit"></v-ons-checkbox>
                  <label for="chkDispIsEdit">自分が最終更新</label>
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
  
import {mapActions, mapGetters} from "vuex";
import $ from "jquery";
import {DATE_CHOICES, OBSERVE_RECORD} from "@/constants/defaultSettingConstants";
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
      funcName:"観察記録",
      // データ初期値
      initialValue: {},
      // 編集する観察記録設定レコード
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
      // カード開閉状態(初期値をfalseにすることでOnsenUI内部挙動との競合を抑制)
      isExpanded: false,
    };
  },
  methods: {
	...mapActions("pat-event/list", [
	  "fetchPatEventMaster"
	]),
    ...mapActions(
      "loading-screen", ["startLoadingScreen","finishLoadingScreen"]
    ),
    getSaveData() {
      let rtnData = {
        name: OBSERVE_RECORD.KEY_NAME,
        data: {}
      };
      rtnData.data[OBSERVE_RECORD.KEY_NAME_OBS_KIND_LIST] = this.editRecord[OBSERVE_RECORD.KEY_NAME_OBS_KIND_LIST];
      rtnData.data[OBSERVE_RECORD.KEY_NAME_START_DATE] = this.editRecord[OBSERVE_RECORD.KEY_NAME_START_DATE];
      rtnData.data[OBSERVE_RECORD.KEY_NAME_END_DATE] = this.editRecord[OBSERVE_RECORD.KEY_NAME_END_DATE];
      rtnData.data[OBSERVE_RECORD.KEY_NAME_DISP_IS_DRAFT] = this.editRecord[OBSERVE_RECORD.KEY_NAME_DISP_IS_DRAFT];
      rtnData.data[OBSERVE_RECORD.KEY_NAME_DISP_IS_EDIT] = this.editRecord[OBSERVE_RECORD.KEY_NAME_DISP_IS_EDIT];
      return rtnData;
    },
	sortDispData(categories,subCategories) {
	  let sortedSubCategories = [];
	  categories.forEach(category => {
	    subCategories.forEach(subCategory => {
	      if(category.categoryCd === subCategory.categoryCd){
		    sortedSubCategories.push(subCategory);
		  }
	    })
	  })
	  return sortedSubCategories;
	}
  },
  computed: {
    ...mapGetters("account-edit", {
      getDefaultSetting: "getDefaultSetting"
    }),
    ...mapGetters("pat-event/list", [
      "getMstCategoryRecords","getMstSubCategoryRecords"
    ]),
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    obsKindList: {
      get() {
        return this.editRecord[OBSERVE_RECORD.KEY_NAME_OBS_KIND_LIST];
      },
      set(value) {
        this.editRecord[OBSERVE_RECORD.KEY_NAME_OBS_KIND_LIST] = value;
      }
    },
    startDate: {
      get() {
        return this.editRecord[OBSERVE_RECORD.KEY_NAME_START_DATE];
      },
      set(value) {
        this.editRecord[OBSERVE_RECORD.KEY_NAME_START_DATE] = value;
      }
    },
    endDate: {
      get() {
        return this.editRecord[OBSERVE_RECORD.KEY_NAME_END_DATE];
      },
      set(value) {
        this.editRecord[OBSERVE_RECORD.KEY_NAME_END_DATE] = value;
      }
    },
    dispIsDraft: {
      get() {
        return this.editRecord[OBSERVE_RECORD.KEY_NAME_DISP_IS_DRAFT];
      },
      set(value) {
        this.editRecord[OBSERVE_RECORD.KEY_NAME_DISP_IS_DRAFT] = value;
      }
    },
    dispIsEdit: {
      get() {
        return this.editRecord[OBSERVE_RECORD.KEY_NAME_DISP_IS_EDIT];
      },
      set(value) {
        this.editRecord[OBSERVE_RECORD.KEY_NAME_DISP_IS_EDIT] = value;
      }
    },
	selectTemplates() {
	  let dataTable = [];
	  dataTable.push({
	    code: "0-0",
	    name: "全カテゴリ"
	  });
	  let sortedSubCategories = this.sortDispData(this.getMstCategoryRecords,this.subCategoryObserveList);
	  let category = null;
	  for (const subCategory of sortedSubCategories) {
	    if (category === null || (category && (category.categoryCd !== subCategory.categoryCd))) {
	      category = this.getMstCategoryRecords.find(item => {
	        return item.categoryCd === subCategory.categoryCd;
	      });
	      category && dataTable.push({
	        code: "0-" + category.categoryCd,
	        name: category.categoryName
	      });
	    }
	    category && dataTable.push({
	      code: subCategory.subCategoryCd + "-" + category.categoryCd,
	      name: category.categoryName + " ＞ " + subCategory.subCategoryName
	    });
	  }
	  return dataTable;
	},
    subCategoryObserveList() {
      let list = this.getMstSubCategoryRecords || [];
      // 利用種別が2（観察記録）でフィルタリング
	  list = list.filter(item => item.useType === 2);
	  list = list.filter(obj1 => this.getMstCategoryRecords.some(obj2 => obj1.categoryCd === obj2.categoryCd));
      return list;
    }
  },
  watch: {
    editRecord: {
      handler(newValue, oldValue){
        var keySet = Object.keys(this.initialValue);
        for(let key of keySet){
          let initialValue = this.initialValue[key];
          let editValue = newValue[key];
          if(JSON.stringify(initialValue) !== JSON.stringify(editValue)){
            EventBus.$emit("isChanged", {componentName: "observeRecord", value: true});
            return;
          }
        }
        EventBus.$emit("isChanged", {componentName: "observeRecord", value: false});
      },
      deep: true
    }
  },
  async created() {
    // 共通ローダー表示開始
    this.startLoadingScreen();
    // 初期値未設定の場合のデフォルト値
    this.initialValue[OBSERVE_RECORD.KEY_NAME_OBS_KIND_LIST] = "0-0";
    this.initialValue[OBSERVE_RECORD.KEY_NAME_START_DATE] = DATE_CHOICES.BEFORE_ONE_WEEK.value; // 1週間前
    this.initialValue[OBSERVE_RECORD.KEY_NAME_END_DATE] = DATE_CHOICES.TODAY.value; // 本日
    this.initialValue[OBSERVE_RECORD.KEY_NAME_DISP_IS_DRAFT] = false;
    this.initialValue[OBSERVE_RECORD.KEY_NAME_DISP_IS_EDIT] = false;

	await this.fetchPatEventMaster(this.facilityCd);

    this.$nextTick(() => {
      this.editRecord = deepCopy(this.getDefaultSetting[OBSERVE_RECORD.KEY_NAME]);
      // データが空の場合は初期値を適用する
      if (!this.editRecord || Object.keys(this.editRecord).length === 0) {
        this.editRecord = deepCopy(this.initialValue);
      } else {
        if (this.editRecord[OBSERVE_RECORD.KEY_NAME_OBS_KIND_LIST] == null || this.editRecord[OBSERVE_RECORD.KEY_NAME_OBS_KIND_LIST].indexOf("-") === -1) {
		  this.editRecord[OBSERVE_RECORD.KEY_NAME_OBS_KIND_LIST] = this.initialValue[OBSERVE_RECORD.KEY_NAME_OBS_KIND_LIST];
        }
        if (this.editRecord[OBSERVE_RECORD.KEY_NAME_START_DATE] == null) {
          this.editRecord[OBSERVE_RECORD.KEY_NAME_START_DATE] = this.initialValue[OBSERVE_RECORD.KEY_NAME_START_DATE];
        }
        if (this.editRecord[OBSERVE_RECORD.KEY_NAME_END_DATE] == null) {
          this.editRecord[OBSERVE_RECORD.KEY_NAME_END_DATE] = this.initialValue[OBSERVE_RECORD.KEY_NAME_END_DATE];
        }
        if (this.editRecord[OBSERVE_RECORD.KEY_NAME_DISP_IS_DRAFT] == null) {
          this.editRecord[OBSERVE_RECORD.KEY_NAME_DISP_IS_DRAFT] = this.initialValue[OBSERVE_RECORD.KEY_NAME_DISP_IS_DRAFT];
        }
        if (this.editRecord[OBSERVE_RECORD.KEY_NAME_DISP_IS_EDIT] == null) {
          this.editRecord[OBSERVE_RECORD.KEY_NAME_DISP_IS_EDIT] = this.initialValue[OBSERVE_RECORD.KEY_NAME_DISP_IS_EDIT];
        }
        this.initialValue = deepCopy(this.editRecord);
      }
      if($("#phone-show-observe-record").css("display") === "inline"){
        document.getElementById("phone-show-observe-record").innerText =  document.getElementById("phone-show-observe-record").innerText + '\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0';
      }
      // 共通ローダー表示終了
      this.finishLoadingScreen();
      this.isExpanded = this.defaultExpanded;
    });
  }
};
</script>

<style scoped>
  @media (max-width: 500px){
    #pc-show-observe-record{display:none;}
  }
  @media (min-width: 501px){
    #phone-show-observe-record{display:none;}
  }
.row-flex {
  white-space: nowrap;
}
</style>
