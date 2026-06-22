/**
 * デフォルト設定タブ - 観察記録のコンポーネント
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
                <label id="pc-show-observe-record" class="default-setting-content-label white-space-nowrap">カテゴリ</label>
                <label id="phone-show-observe-record" class="default-setting-content-label white-space-nowrap">カテゴリ</label>
              </td>
			  <td class="default-setting-content">
          <div ref="observeRecordCategoryWrap" class="observe-record-category-dropdown">
            <kendo-dropdownlist
              ref="refObserveRecordCategoryDdl"
              :data-source="selectTemplates"
              v-model="obsKindList"
              data-text-field="name"
              data-value-field="code"
              @open="onObserveRecordCategoryDdlOpen"
            />
          </div>
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
  
import {mapActions, mapGetters} from "@/compat/vue/vuex";

import {DATE_CHOICES, OBSERVE_RECORD} from "@/constants/defaultSettingConstants";
import {deepCopy} from "@/functions/common/CommonFunctions";
import { isValidDefaultCategory } from "@/functions/modals/default-setting/defaultSettingUtils";
import { EventBus } from "@/compat/vue/event-bus.js";
import { getScopedElementById, isScopedElementDisplayInline } from "@/functions/common/LayoutMeasureHelper";

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
	},

    /** カテゴリ DropDown 外枠を「開始日」行の Kendo 幅に固定（患者イベント設定と同様）。 */
    pinObserveRecordCategoryDdlOuterWidth() {
      const wrap = this.$refs.observeRecordCategoryWrap;
      if (!wrap || typeof this.$el?.querySelector !== "function") {
        return;
      }
      const refPicker = this.$el.querySelector(
        "tbody tr:nth-child(2) td.default-setting-content span.k-dropdownlist.k-picker",
      );
      if (!refPicker) {
        wrap.style.width = "";
        wrap.style.minWidth = "";
        return;
      }
      const refW = refPicker.getBoundingClientRect().width ?? 0;
      if (!(refW > 2)) {
        wrap.style.width = "";
        wrap.style.minWidth = "";
        return;
      }
      const td = wrap.closest?.("td");
      const tdW = td?.getBoundingClientRect?.().width ?? refW;
      const wPx = `${Math.round(Math.min(refW, tdW || refW))}px`;
      wrap.style.width = wPx;
      wrap.style.minWidth = wPx;
    },

    schedulePinObserveRecordCategoryDdlOuterWidth() {
      window.requestAnimationFrame(() => {
        this.$nextTick(() => this.pinObserveRecordCategoryDdlOuterWidth());
      });
      window.setTimeout(() => this.pinObserveRecordCategoryDdlOuterWidth(), 0);
      window.setTimeout(() => this.pinObserveRecordCategoryDdlOuterWidth(), 120);
    },

    onObserveRecordCategoryDdlOpen() {
      const squeeze = () => {
        const wrap = this.$el?.querySelector?.(".observe-record-category-dropdown");
        const ddl = this.$refs.refObserveRecordCategoryDdl;
        if (!wrap || !ddl) {
          return;
        }
        const w =
          typeof wrap.getBoundingClientRect === "function"
            ? wrap.getBoundingClientRect().width
            : wrap.offsetWidth ?? 0;
        if (!(w > 0)) {
          return;
        }
        const px = `${Math.round(w)}px`;
        ddl.applyPopupSurfaceWidth?.(px);
        ddl.applyPopupSurfaceStyles?.({
          width: px,
          maxWidth: px,
          minWidth: px,
          boxSizing: "border-box"
        });
        const popupRoot = typeof ddl.popupRootEl === "function" ? ddl.popupRootEl() : null;
        if (popupRoot?.style) {
          popupRoot.style.maxWidth = px;
          popupRoot.style.boxSizing = "border-box";
        }
      };
      requestAnimationFrame(() => {
        this.$nextTick(squeeze);
      });
      window.setTimeout(squeeze, 0);
      window.setTimeout(squeeze, 50);
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
    },
    isExpanded() {
      this.schedulePinObserveRecordCategoryDdlOuterWidth();
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
        } else if (!isValidDefaultCategory(this.editRecord[OBSERVE_RECORD.KEY_NAME_OBS_KIND_LIST], this.getMstCategoryRecords, this.subCategoryObserveList)) {
          // NOTE: マスタ削除された場合、「0-0 : 全カテゴリ」を再設定
          this.editRecord[OBSERVE_RECORD.KEY_NAME_OBS_KIND_LIST] = "0-0";
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
      if(isScopedElementDisplayInline("phone-show-observe-record", this.$el || this)){
        const phoneShowElement = getScopedElementById("phone-show-observe-record", this.$el || this);

        if (phoneShowElement) {

          phoneShowElement.innerText = phoneShowElement.innerText + '\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0';

        }
      }
      // 共通ローダー表示終了
      this.finishLoadingScreen();
      this.isExpanded = this.defaultExpanded;
      this.schedulePinObserveRecordCategoryDdlOuterWidth();
    });
  },
  mounted() {
    this.schedulePinObserveRecordCategoryDdlOuterWidth();
    this._onObserveRecordWinResizePin = () => this.schedulePinObserveRecordCategoryDdlOuterWidth();
    window.addEventListener("resize", this._onObserveRecordWinResizePin, { passive: true });
  },
  beforeUnmount() {
    if (this._onObserveRecordWinResizePin) {
      window.removeEventListener("resize", this._onObserveRecordWinResizePin);
    }
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

<style>
  /*
   * 観察記録・カテゴリ（患者イベント設定のカテゴリと同方針）
   */
  .observe-record-category-dropdown {
    display: inline-block;
    max-width: 100%;
    min-width: 0;
    vertical-align: middle;
    box-sizing: border-box;
  }

  .observe-record-category-dropdown span.k-dropdownlist.k-picker {
    box-sizing: border-box;
    display: inline-flex !important;
    align-items: stretch;
    width: 100% !important;
    max-width: 100%;
    min-width: 0;
    position: relative !important;
    overflow: hidden;
    vertical-align: middle;
  }

  .observe-record-category-dropdown span.k-dropdownlist.k-picker > span.k-input-inner.k-dropdown-wrap,
  .observe-record-category-dropdown span.k-dropdownlist.k-picker > span.k-input-inner {
    flex: 1 1 auto !important;
    min-width: 0 !important;
    max-width: 100%;
    overflow: hidden !important;
    padding-right: 2em !important;
    box-sizing: border-box;
  }

  .observe-record-category-dropdown span.k-dropdownlist.k-picker > .k-input-button.k-select {
    flex: 0 0 auto !important;
    position: absolute !important;
    right: 0;
    top: 0;
    bottom: 0;
    width: 1.85em !important;
    min-width: 1.85em !important;
    margin: 0 !important;
    z-index: 3;
    box-sizing: border-box;
  }

  .observe-record-category-dropdown span.k-input-inner .k-input-value-text,
  .observe-record-category-dropdown span.k-input-value-text.k-input {
    min-width: 0 !important;
    max-width: 100%;
    overflow: hidden !important;
    text-overflow: clip !important;
    white-space: nowrap !important;
    height: auto !important;
    flex: 1 1 auto !important;
    display: flex !important;
    align-items: center !important;
    box-sizing: border-box !important;
  }

  .ntss-kendo-popup-owner-observe-record-category-dropdown.ntss-kendo-dropdownlist-popup-legacy.k-animation-container {
    box-sizing: border-box;
    max-width: calc(100vw - 24px);
  }

  .ntss-kendo-popup-owner-observe-record-category-dropdown.ntss-kendo-dropdownlist-popup-legacy.k-animation-container .k-popup,
  .ntss-kendo-popup-owner-observe-record-category-dropdown.ntss-kendo-dropdownlist-popup-legacy.k-animation-container .k-list-container {
    box-sizing: border-box !important;
    overflow-x: hidden !important;
  }

  .ntss-kendo-popup-owner-observe-record-category-dropdown .k-list-item,
  .ntss-kendo-popup-owner-observe-record-category-dropdown .k-list-item-text {
    box-sizing: border-box;
    max-width: 100%;
    overflow: hidden !important;
    text-overflow: clip !important;
    white-space: nowrap !important;
  }
</style>
