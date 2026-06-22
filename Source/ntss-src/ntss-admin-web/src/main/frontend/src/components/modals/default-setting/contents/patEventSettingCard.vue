/**
 * デフォルト設定タブ - 患者イベント設定のコンポーネント
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
                <!--<label class="default-setting-content-label">カテゴリー</label>-->
                <label id="pc-show-pat-event" class="default-setting-content-label white-space-nowrap">カテゴリ</label>
                <label id="phone-show-pat-event" class="default-setting-content-label white-space-nowrap">カテゴリ</label>
                <!--mod FNSI-改修内容4214 任 end-->
              </td>
              <td class="default-setting-content">
                <div ref="patEventCategoryWrap" class="pat-event-category-dropdown">
                  <kendo-dropdownlist
                    ref="refPatEventCategoryDdl"
                    :data-source="selectTemplates"
                    v-model="relationCategoryCd"
                    data-text-field="name"
                    data-value-field="code"
                    @open="onPatEventCategoryDdlOpen"
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
              <td class="default-setting-content-title-last-row">
                <label class="default-setting-content-label">終了日</label>
              </td>
              <td class="default-setting-content-last-row">
                <kendo-dropdownlist
                  :data-source="lstDispTermEnd"
                  v-model="endDate"
                  data-text-field="title"
                  data-value-field="value"
                />
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
   /*add FNSI-改修内容4214 任 start*/

   /*add FNSI-改修内容4214 任 end*/
   import {DATE_CHOICES, PAT_EVENT} from "@/constants/defaultSettingConstants";
   import {deepCopy} from "@/functions/common/CommonFunctions";
   import { isValidDefaultCategory } from "@/functions/modals/default-setting/defaultSettingUtils";
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
      funcName:"患者イベント",
      // データ初期値
      initialValue: {},
      // 編集する患者イベント設定レコード
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
      // 患者イベントサブカテゴリー
      mstSubCategoryRecordsPatIntroLetter: [],
      // add 9868 特定の操作で紹介状で紹介状以外の患者イベントを新規作成できてしまう 関 start
      categories: [],
      // add 9868 特定の操作で紹介状で紹介状以外の患者イベントを新規作成できてしまう 関 end
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
        name: PAT_EVENT.KEY_NAME,
        data: {}
      };
      rtnData.data[PAT_EVENT.KEY_NAME_RELATION_CATEGORY_CD] = this.editRecord[PAT_EVENT.KEY_NAME_RELATION_CATEGORY_CD];
      rtnData.data[PAT_EVENT.KEY_NAME_START_DATE] = this.editRecord[PAT_EVENT.KEY_NAME_START_DATE];
      rtnData.data[PAT_EVENT.KEY_NAME_END_DATE] = this.editRecord[PAT_EVENT.KEY_NAME_END_DATE];
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

    /**
     * カテゴリの外側（閉じた DropDown）は「開始日」行の横幅に固定し、選択テキストの長さでは伸縮しない。
     * 開始日と同様のサイズになり、リスト（ポップアップ）は @open で同幅に収める。
     */
    pinPatEventCategoryDdlOuterWidth() {
      const wrap = this.$refs.patEventCategoryWrap;
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

    schedulePinPatEventCategoryDdlOuterWidth() {
      window.requestAnimationFrame(() => {
        this.$nextTick(() => this.pinPatEventCategoryDdlOuterWidth());
      });
      window.setTimeout(() => this.pinPatEventCategoryDdlOuterWidth(), 0);
      window.setTimeout(() => this.pinPatEventCategoryDdlOuterWidth(), 120);
    },

    /** Kendo が長いリスト項目でポップアップ幅まで伸ばすのを抑止する（トリガーと同じ幅に固定）。 */
    onPatEventCategoryDdlOpen() {
      const squeeze = () => {
        const wrap = this.$el?.querySelector?.(".pat-event-category-dropdown");
        const ddl = this.$refs.refPatEventCategoryDdl;
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
      "getMstCategoryRecords",
      "getMstSubCategoryRecords"
    ]),
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    relationCategoryCd: {
      get() {
        return this.editRecord[PAT_EVENT.KEY_NAME_RELATION_CATEGORY_CD];
      },
      set(value) {
        this.editRecord[PAT_EVENT.KEY_NAME_RELATION_CATEGORY_CD] = value;
      }
    },
    startDate: {
      get() {
        return this.editRecord[PAT_EVENT.KEY_NAME_START_DATE];
      },
      set(value) {
        this.editRecord[PAT_EVENT.KEY_NAME_START_DATE] = value;
      }
    },
    endDate: {
      get() {
        return this.editRecord[PAT_EVENT.KEY_NAME_END_DATE];
      },
      set(value) {
        this.editRecord[PAT_EVENT.KEY_NAME_END_DATE] = value;
      }
    },
    selectTemplates() {
      let dataTable = [];
      dataTable.push({
        code: "0-0",
        name: "全カテゴリ"
      });
	  this.mstSubCategoryRecordsPatIntroLetter  = this.sortDispData(this.categories,this.mstSubCategoryRecordsPatIntroLetter);
      let category = null;
      for (const subCategory of this.mstSubCategoryRecordsPatIntroLetter) {
        if (
          category === null ||
          // #9868 特定の操作で紹介状で紹介状以外の患者イベントを新規作成できてしまう linjunfeng start
          // category.categoryCd !== subCategory.categoryCd
          (category && (category.categoryCd !== subCategory.categoryCd))
          // #9868 特定の操作で紹介状で紹介状以外の患者イベントを新規作成できてしまう linjunfeng end
        ) {
          // mod 9868 特定の操作で紹介状で紹介状以外の患者イベントを新規作成できてしまう 関 start
          // category = categories.find(item => {
          //   return item.categoryCd === subCategory.categoryCd;
          // });
          category = this.categories.find(item => {
            return item.categoryCd === subCategory.categoryCd;
          });
          // mod 9868 特定の操作で紹介状で紹介状以外の患者イベントを新規作成できてしまう 関 end
          // #9868 特定の操作で紹介状で紹介状以外の患者イベントを新規作成できてしまう linjunfeng start
          // dataTable.push({
          category && dataTable.push({
          // #9868 特定の操作で紹介状で紹介状以外の患者イベントを新規作成できてしまう linjunfeng end
            code: "0-" + category.categoryCd,
            name: category.categoryName
          });
                  }
        // #9868 特定の操作で紹介状で紹介状以外の患者イベントを新規作成できてしまう linjunfeng start
        // dataTable.push({
        category && dataTable.push({
        // #9868 特定の操作で紹介状で紹介状以外の患者イベントを新規作成できてしまう linjunfeng end  
          code: subCategory.subCategoryCd + "-" + category.categoryCd,
          name: category.categoryName + " ＞ " + subCategory.subCategoryName
        });
      }
      return dataTable;
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
            EventBus.$emit("isChanged", {componentName: "patEvent", value: true});
            return;
          }
        }
        EventBus.$emit("isChanged", {componentName: "patEvent", value: false});
      },
      deep: true
    },
   //add FNSI-5687 劉全航 end
    isExpanded() {
      this.schedulePinPatEventCategoryDdlOuterWidth();
    },
  },
  async created() {
    // 共通ローダー表示開始
    this.startLoadingScreen();
    // 初期値未設定の場合のデフォルト値
    this.initialValue[PAT_EVENT.KEY_NAME_RELATION_CATEGORY_CD] = "0-0";
    this.initialValue[PAT_EVENT.KEY_NAME_START_DATE] = DATE_CHOICES.BEFORE_ONE_WEEK.value; // 1週間前
    this.initialValue[PAT_EVENT.KEY_NAME_END_DATE] = DATE_CHOICES.TODAY.value; // 本日

    await this.fetchPatEventMaster(this.facilityCd);
    this.mstSubCategoryRecordsPatIntroLetter = this.getMstSubCategoryRecords.filter(obj1 => this.getMstCategoryRecords.some(obj2 => obj1.categoryCd === obj2.categoryCd));
    // add 9868 特定の操作で紹介状で紹介状以外の患者イベントを新規作成できてしまう 関 start
    this.categories = this.getMstCategoryRecords;
    // add 9868 特定の操作で紹介状で紹介状以外の患者イベントを新規作成できてしまう 関 end

    this.$nextTick(() => {
      this.editRecord = deepCopy(this.getDefaultSetting[PAT_EVENT.KEY_NAME]);
      // データが空の場合は初期値を適用する
      if (!this.editRecord || Object.keys(this.editRecord).length === 0) {
        this.editRecord = deepCopy(this.initialValue);
      } else {
        if (this.editRecord[PAT_EVENT.KEY_NAME_RELATION_CATEGORY_CD] == null) {
          this.editRecord[PAT_EVENT.KEY_NAME_RELATION_CATEGORY_CD] = this.initialValue[PAT_EVENT.KEY_NAME_RELATION_CATEGORY_CD];
        } else if (!isValidDefaultCategory(this.editRecord[PAT_EVENT.KEY_NAME_RELATION_CATEGORY_CD], this.getMstCategoryRecords, this.getMstSubCategoryRecords)) {
          // NOTE: マスタ削除された場合、「0-0 : 全カテゴリ」を再設定
          this.editRecord[PAT_EVENT.KEY_NAME_RELATION_CATEGORY_CD] = "0-0";
        }
        if (this.editRecord[PAT_EVENT.KEY_NAME_START_DATE] == null) {
          this.editRecord[PAT_EVENT.KEY_NAME_START_DATE] = this.initialValue[PAT_EVENT.KEY_NAME_START_DATE];
        }
        if (this.editRecord[PAT_EVENT.KEY_NAME_END_DATE] == null) {
          this.editRecord[PAT_EVENT.KEY_NAME_END_DATE] = this.initialValue[PAT_EVENT.KEY_NAME_END_DATE];
        }
        this.initialValue = deepCopy(this.editRecord);
      }
      /*add FNSI-改修内容4214 任 start*/
      if(isScopedElementDisplayInline("phone-show-pat-event", this.$el || this)){
        const phoneShowElement = getScopedElementById("phone-show-pat-event", this.$el || this);

        if (phoneShowElement) {

          phoneShowElement.innerText = phoneShowElement.innerText + '\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0';

        }
      }
      /*add FNSI-改修内容4214 任 end*/
      // 共通ローダー表示終了
      this.finishLoadingScreen();
      this.isExpanded = this.defaultExpanded;
      this.schedulePinPatEventCategoryDdlOuterWidth();
    });
  },
  mounted() {
    this.schedulePinPatEventCategoryDdlOuterWidth();
    this._onPatEventWinResizePin = () => this.schedulePinPatEventCategoryDdlOuterWidth();
    window.addEventListener("resize", this._onPatEventWinResizePin, { passive: true });
  },
  beforeUnmount() {
    if (this._onPatEventWinResizePin) {
      window.removeEventListener("resize", this._onPatEventWinResizePin);
    }
  },
};
</script>

<style scoped>
  /*add FNSI-改修内容4214 任 start*/
  @media (max-width: 500px){
    #pc-show-pat-event{display:none;}
  }
  @media (min-width: 501px){
    #phone-show-pat-event{display:none;}
  }
  /*add FNSI-改修内容4214 任 end*/

</style>

<style>
  /*
   * カテゴリのみ。外側サイズは pinPatEventCategoryDdlOuterWidth() で「開始日」と同じ幅に固定する。
   * 選択テキストが長くても外枠は伸びない（クリップ／三角は従来通り）。
   */
  .pat-event-category-dropdown {
    display: inline-block;
    max-width: 100%;
    min-width: 0;
    vertical-align: middle;
    box-sizing: border-box;
  }

  .pat-event-category-dropdown span.k-dropdownlist.k-picker {
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

  .pat-event-category-dropdown span.k-dropdownlist.k-picker > span.k-input-inner.k-dropdown-wrap,
  .pat-event-category-dropdown span.k-dropdownlist.k-picker > span.k-input-inner {
    flex: 1 1 auto !important;
    min-width: 0 !important;
    max-width: 100%;
    overflow: hidden !important;
    padding-right: 2em !important;
    box-sizing: border-box;
  }

  .pat-event-category-dropdown span.k-dropdownlist.k-picker > .k-input-button.k-select {
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

  .pat-event-category-dropdown span.k-input-inner .k-input-value-text,
  .pat-event-category-dropdown span.k-input-value-text.k-input {
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

  /*
   * 同上カテゴリの開いたリストポップアップ syncLegacyPopupOwnerScope で
   * ntss-kendo-popup-owner-pat-event-category-dropdown が付与される。
   * 項目が長くてもパネルを横に伸ばさない（JS と併用）。
   */
  .ntss-kendo-popup-owner-pat-event-category-dropdown.ntss-kendo-dropdownlist-popup-legacy.k-animation-container {
    box-sizing: border-box;
    max-width: calc(100vw - 24px);
  }

  .ntss-kendo-popup-owner-pat-event-category-dropdown.ntss-kendo-dropdownlist-popup-legacy.k-animation-container .k-popup,
  .ntss-kendo-popup-owner-pat-event-category-dropdown.ntss-kendo-dropdownlist-popup-legacy.k-animation-container .k-list-container {
    box-sizing: border-box !important;
    overflow-x: hidden !important;
  }

  .ntss-kendo-popup-owner-pat-event-category-dropdown .k-list-item,
  .ntss-kendo-popup-owner-pat-event-category-dropdown .k-list-item-text {
    box-sizing: border-box;
    max-width: 100%;
    overflow: hidden !important;
    text-overflow: clip !important;
    white-space: nowrap !important;
  }
</style>
