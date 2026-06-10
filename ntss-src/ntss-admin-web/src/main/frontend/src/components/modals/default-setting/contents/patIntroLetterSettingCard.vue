/**
 * デフォルト設定タブ - 紹介状設定のコンポーネント
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
                <!--<label class="default-setting-content-label">カテゴリー</label>-->
                <label id="pc-show-pat-introletter" class="default-setting-content-label white-space-nowrap">カテゴリ</label>
                <label id="phone-show-pat-introletter" class="default-setting-content-label white-space-nowrap">カテゴリ</label>
                <!--mod FNSI-改修内容4214 任 end-->
              </td>
              <td class="default-setting-content">
                <kendo-dropdownlist
                  :data-source="selectTemplates"
                  v-model="relationCategoryCd"
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
   import {mapActions, mapGetters} from "vuex";
   /*add FNSI-改修内容4214 任 start*/
   import $ from "jquery";
   /*add FNSI-改修内容4214 任 end*/
   import {DATE_CHOICES, PAT_INTRO_LETTER} from "@/constants/defaultSettingConstants";
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
      funcName:"紹介状",
      // データ初期値
      initialValue: {},
      // 編集する紹介状設定レコード
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
        name: PAT_INTRO_LETTER.KEY_NAME,
        data: {}
      };
      rtnData.data[PAT_INTRO_LETTER.KEY_NAME_RELATION_CATEGORY_CD] = this.editRecord[PAT_INTRO_LETTER.KEY_NAME_RELATION_CATEGORY_CD];
      rtnData.data[PAT_INTRO_LETTER.KEY_NAME_START_DATE] = this.editRecord[PAT_INTRO_LETTER.KEY_NAME_START_DATE];
      rtnData.data[PAT_INTRO_LETTER.KEY_NAME_END_DATE] = this.editRecord[PAT_INTRO_LETTER.KEY_NAME_END_DATE];
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
        return this.editRecord[PAT_INTRO_LETTER.KEY_NAME_RELATION_CATEGORY_CD];
      },
      set(value) {
        this.editRecord[PAT_INTRO_LETTER.KEY_NAME_RELATION_CATEGORY_CD] = value;
      }
    },
    startDate: {
      get() {
        return this.editRecord[PAT_INTRO_LETTER.KEY_NAME_START_DATE];
      },
      set(value) {
        this.editRecord[PAT_INTRO_LETTER.KEY_NAME_START_DATE] = value;
      }
    },
    endDate: {
      get() {
        return this.editRecord[PAT_INTRO_LETTER.KEY_NAME_END_DATE];
      },
      set(value) {
        this.editRecord[PAT_INTRO_LETTER.KEY_NAME_END_DATE] = value;
      }
    },
    selectTemplates() {
      let dataTable = [];
      dataTable.push({
        code: "0-0",
        name: "全カテゴリ"
      });
      this.mstSubCategoryRecordsPatIntroLetter = this.sortDispData(this.categories,this.mstSubCategoryRecordsPatIntroLetter);
      // del 9868 特定の操作で紹介状で紹介状以外の患者イベントを新規作成できてしまう 関 start
      // const categories = this.getMstCategoryRecords;
      // del 9868 特定の操作で紹介状で紹介状以外の患者イベントを新規作成できてしまう 関 end
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
            EventBus.$emit("isChanged", {componentName: "patIntro", value: true});
            return;
          }
        }
        EventBus.$emit("isChanged", {componentName: "patIntro", value: false});
      },
      deep: true
    },
    //add FNSI-5687 劉全航 end
  },
  async created() {
    // 共通ローダー表示開始
    this.startLoadingScreen();
    // 初期値未設定の場合のデフォルト値
    this.initialValue[PAT_INTRO_LETTER.KEY_NAME_RELATION_CATEGORY_CD] = "0-0";
    this.initialValue[PAT_INTRO_LETTER.KEY_NAME_START_DATE] = DATE_CHOICES.BEFORE_ONE_WEEK.value; // 1週間前
    this.initialValue[PAT_INTRO_LETTER.KEY_NAME_END_DATE] = DATE_CHOICES.TODAY.value; // 本日

    await this.fetchPatEventMaster(this.facilityCd);
    let filteredSub = this.getMstSubCategoryRecords.filter(rec => {
      return rec.useType === 3;
    });
	filteredSub = filteredSub.filter(obj1 => this.getMstCategoryRecords.some(obj2 => obj1.categoryCd === obj2.categoryCd));
    this.mstSubCategoryRecordsPatIntroLetter = filteredSub;
    // add 9868 特定の操作で紹介状で紹介状以外の患者イベントを新規作成できてしまう 関 start
    this.categories = this.getMstCategoryRecords;
    // add 9868 特定の操作で紹介状で紹介状以外の患者イベントを新規作成できてしまう 関 end

    this.$nextTick(() => {
      this.editRecord = deepCopy(this.getDefaultSetting[PAT_INTRO_LETTER.KEY_NAME]);
      // データが空の場合は初期値を適用する
      if (!this.editRecord || Object.keys(this.editRecord).length === 0) {
        this.editRecord = deepCopy(this.initialValue);
      } else {
        if (this.editRecord[PAT_INTRO_LETTER.KEY_NAME_RELATION_CATEGORY_CD] == null) {
          this.editRecord[PAT_INTRO_LETTER.KEY_NAME_RELATION_CATEGORY_CD] = this.initialValue[PAT_INTRO_LETTER.KEY_NAME_RELATION_CATEGORY_CD];
        }
        if (this.editRecord[PAT_INTRO_LETTER.KEY_NAME_START_DATE] == null) {
          this.editRecord[PAT_INTRO_LETTER.KEY_NAME_START_DATE] = this.initialValue[PAT_INTRO_LETTER.KEY_NAME_START_DATE];
        }
        if (this.editRecord[PAT_INTRO_LETTER.KEY_NAME_END_DATE] == null) {
          this.editRecord[PAT_INTRO_LETTER.KEY_NAME_END_DATE] = this.initialValue[PAT_INTRO_LETTER.KEY_NAME_END_DATE];
        }
        this.initialValue = deepCopy(this.editRecord);
      }
      /*add FNSI-改修内容4214 任 start*/
      if($("#phone-show-pat-introletter").css("display") === "inline"){
        document.getElementById("phone-show-pat-introletter").innerText =  document.getElementById("phone-show-pat-introletter").innerText + '\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0';
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
    #pc-show-pat-introletter{display:none;}
  }
  @media (min-width: 501px){
    #phone-show-pat-introletter{display:none;}
  }
  /*add FNSI-改修内容4214 任 end*/
</style>
