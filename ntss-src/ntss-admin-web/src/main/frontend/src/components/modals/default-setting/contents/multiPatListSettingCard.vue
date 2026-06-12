/**
 * デフォルト設定タブ - データリスト設定のコンポーネント
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
                <!--<label class="default-setting-content-label">レイアウト</label>-->
                <label id="pc-show-pat-list" class="default-setting-content-label white-space-nowrap">レイアウト</label>
                <label id="phone-show-pat-list" class="default-setting-content-label white-space-nowrap">レイアウト</label>
                <!--mod FNSI-改修内容4214 任 end-->
              </td>
              <td class="default-setting-content">
                <v-ons-select
                  v-model="selectedLayout"
                  style="min-width:140px"
                >
                  <option
                    v-if="layoutMst"
                    v-for="(layout, i) in layoutMst"
                    :key="`layout_${i}`"
                    :value="layout.patListLayoutCd"
                  >{{ layout.patListLayoutName }}</option>
                </v-ons-select>
              </td>
            </tr>
            <tr :style="periodDispflg">
              <td class="default-setting-content-title-last-row">
                <label class="default-setting-content-label">期間</label>
              </td>
              <td class="default-setting-content-last-row">
                <!-- mod #11873【因島】データリスト「治療予定・実績」テンプレートでサーバダウン fang start -->
                <!--<ntss-dropdown-list
                  :data-source="lstDispTermStart"
                  v-model="startDate"
                  data-text-field="title"
                  data-value-field="value"
                />-->
                <kendo-dropdownlist
                  v-if="isFromListReady"
                  :data-source="fromList"
                  v-model="startDate"
                  data-text-field="title"
                  data-value-field="value"
                />
                <!-- mod #11873【因島】データリスト「治療予定・実績」テンプレートでサーバダウン fang end -->
                <label>&nbsp;～&nbsp;</label>
                <!--mod FNSI-改修内容4214 任 start-->
                <!--<label v-if="isDayLayout">
                  本日
                </label>
                <label v-else>
                  当月
                </label>-->
                <label class="label-width" v-if="isDayLayout">
                  本日
                </label>
                <label class="label-width" v-else>
                  当月
                </label>
                <!--mod FNSI-改修内容4214 任 end-->
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
   import {DATE_CHOICES, KEY_NAME_MULTI_PAT_LIST} from "@/constants/defaultSettingConstants";
   import {deepCopy} from "@/functions/common/CommonFunctions";
   import {patListLayout} from "@/functions/mst/MstGetters.js";
   //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
   import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
   //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
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
      funcName:"データリスト",
      // データ初期値
      initialValue: {},
      // 編集するデータリスト設定レコード
      editRecord: {},
      // レイアウトリスト
      layoutMst: null,
      isShowDataFlg: false,
      isDayLayout: false,
      // 表示期間開始日・選択肢
      lstDispTermStart: [
        DATE_CHOICES.TODAY,
        DATE_CHOICES.BEFORE_ONE_MONTH,
        DATE_CHOICES.BEFORE_THREE_MONTH,
        DATE_CHOICES.BEFORE_SIX_MONTH,
        DATE_CHOICES.BEFORE_ONE_YEAR,
        DATE_CHOICES.BEFORE_THREE_YEAR
      ],
      // 開始期間の選択リスト設定状態
      isFromListReady: false,
      // カード開閉状態(初期値をfalseにすることでOnsenUI内部挙動との競合を抑制)
      isExpanded: false,
    };
  },
  computed: {
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("account-edit", {
      userInfo: "getStateUserAccountInfo",
      getDefaultSetting: "getDefaultSetting"
    }),

    // レイアウト選択に応じた項目表示条件
    periodDispflg() {
      if (this.isShowDataFlg) {
        return {};
      } else {
        return { display: "none" };
      }
    },
    // レイアウト
    selectedLayout: {
      get() {
        return this.editRecord[KEY_NAME_MULTI_PAT_LIST.KEY_NAME_SELECTED_LAYOUT];
      },
      set(value) {
        this.editRecord[KEY_NAME_MULTI_PAT_LIST.KEY_NAME_SELECTED_LAYOUT] = value;
      }
    },
    // 期間(開始)
    startDate: {
      get() {
        return this.editRecord[KEY_NAME_MULTI_PAT_LIST.KEY_NAME_START_DATE];
      },
      set(value) {
        this.editRecord[KEY_NAME_MULTI_PAT_LIST.KEY_NAME_START_DATE] = value;
      }
    },
    // add #11873【因島】データリスト「治療予定・実績」テンプレートでサーバダウン fang start
    // isFromListReady により、選択されたレイアウトの値が設定された契機で期間の選択リストを設定する
    fromList() {
      // データリストレイアウトマスタなし、またはデータリストレイアウトがデフォルト設定に未登録
      if (this.isLayoutMstEmpty() || this.selectedLayout === 0) {
        return [];
      } 
      const layoutIndex = this.layoutMst.findIndex(layout => layout.patListLayoutCd === this.selectedLayout);
      // デフォルト設定で選択されているレイアウトがレイアウトマスタから削除された場合
      if (layoutIndex === -1) {
        return [];
      }
      const layoutInfo = this.layoutMst[layoutIndex];

      if (layoutInfo.templateCd === 5) {
        return [
          DATE_CHOICES.TODAY,
          DATE_CHOICES.BEFORE_ONE_MONTH,
          DATE_CHOICES.BEFORE_THREE_MONTH
        ]
      }
      return this.lstDispTermStart;
    }
    // add #11873【因島】データリスト「治療予定・実績」テンプレートでサーバダウン fang end
  },
  methods: {
    ...mapActions(
      "loading-screen", ["startLoadingScreen","finishLoadingScreen","executeWithLoadingScreen"]
    ),
    getSaveData() {
      let rtnData = {
        name: KEY_NAME_MULTI_PAT_LIST.KEY_NAME,
        data: {}
      };
      rtnData.data[KEY_NAME_MULTI_PAT_LIST.KEY_NAME_SELECTED_LAYOUT] = this.editRecord[KEY_NAME_MULTI_PAT_LIST.KEY_NAME_SELECTED_LAYOUT];
      rtnData.data[KEY_NAME_MULTI_PAT_LIST.KEY_NAME_START_DATE] = this.editRecord[KEY_NAME_MULTI_PAT_LIST.KEY_NAME_START_DATE];

      return rtnData;
    },
    isLayoutMstEmpty() {
      return (!Array.isArray(this.layoutMst) || this.layoutMst.length === 0);
    }
  },
  watch: {
    selectedLayout: {
      handler(newValue, oldValue){
        let rtn = false;
        if (!this.isLayoutMstEmpty()) {
          const indexLayout = this.layoutMst.findIndex(layout => layout.patListLayoutCd === this.selectedLayout);
          const layoutInfo = this.layoutMst[indexLayout];
          const exclusionTemplateCds = [3, 4, 8];
          if (layoutInfo && !exclusionTemplateCds.includes(layoutInfo.templateCd)) {
            rtn = true;
            const dayLayoutTemplateCds = [1, 9, 10, 11, 12];
            this.isDayLayout = dayLayoutTemplateCds.includes(layoutInfo.templateCd);
          }

          // レイアウトの開始期間の再設定
          // 期間の選択リストが変更された契機($nextTick)で期間の値を選択する
          this.$nextTick(() => {
            // 初期化時の元のレイアウトから別のレイアウトに変更した場合
            if (newValue !== this.initialValue[KEY_NAME_MULTI_PAT_LIST.KEY_NAME_SELECTED_LAYOUT]) {
              // 本日（デフォルトの開始期間）
              this.editRecord[KEY_NAME_MULTI_PAT_LIST.KEY_NAME_START_DATE] = DATE_CHOICES.TODAY.value;
            } else {
              // デフォルト設定から読み込んだ元のレイアウトの開始期間
              this.editRecord[KEY_NAME_MULTI_PAT_LIST.KEY_NAME_START_DATE] = this.initialValue[KEY_NAME_MULTI_PAT_LIST.KEY_NAME_START_DATE];
            }
          });
        }
        this.isShowDataFlg = rtn;
      }
    },
    //add FNSI-5687 劉全航 start
    editRecord: {
      handler(newValue, oldValue){
        const keySet = Object.keys(this.initialValue);
        for(let key of keySet){
          let initialValue = this.initialValue[key];
          let editValue = newValue[key];
          if (initialValue && editValue) {
            if (JSON.stringify(initialValue) !== JSON.stringify(editValue)) {
              EventBus.$emit("isChanged", {componentName: "multiPatList", value: true});
              return;
            }
          }
        }
        EventBus.$emit("isChanged", {componentName: "multiPatList", value: false});
      },
      deep: true
    },
    //add FNSI-5687 劉全航 end
    isFromListReady: {
      handler(newValue, oldValue){
        // 開始期間の選択リストの設定完了契機
        if (newValue) {
          // 共通ローダー表示終了
          this.finishLoadingScreen();
        }
      }
    }
  },
  async created() {
    // 共通ローダー表示開始
    this.startLoadingScreen();
    // 共通ローダー付きで初期化処理を実行する
    await this.executeWithLoadingScreen(async () => {
      // マルチ患者レイアウトを取得する
      this.layoutMst = await patListLayout(this.facilityCd).catch(error => {
        getErrorMessage('multiPatListSettingCard.vue', 'created', error);
        throw new Error(error);
      });
      // レイアウトマスタ有:ヘッダ項目情報を指定してカラム表示
      if (this.mst_layout) {
        const userJobCd = parseInt(this.userInfo.jobCd);
        this.layoutMst = this.layoutMst
          .filter(item => !!item.occupations)
          .map(item => {
            item.occupations = JSON.parse(item.occupations);
            return item;
          });
        this.layoutMst = this.layoutMst.filter(item =>item.occupations.includes(userJobCd));
      }
    });

    // 表示期間開始日・選択肢の設定終了後
    this.$nextTick(() => {
      // デフォルト設定のデータリストが未登録の場合のデフォルト値の初期値を設定する
      // ・レイアウト選択リストにリスト先頭を設定する（マスタなしは初期値なしの値（空白）を表示する値で初期化する）
      this.initialValue[KEY_NAME_MULTI_PAT_LIST.KEY_NAME_SELECTED_LAYOUT] = this.layoutMst[0] ? this.layoutMst[0].patListLayoutCd : 0;
      // ・レイアウト選択した場合に期間のデフォルト値（本日）でない値（未設定）で初期化する
      this.initialValue[KEY_NAME_MULTI_PAT_LIST.KEY_NAME_START_DATE] = DATE_CHOICES.UNDETERMINED.value; // 期間の値が未設定
      // デフォルト設定のレイアウトマスタの値
      this.editRecord = deepCopy(this.getDefaultSetting[KEY_NAME_MULTI_PAT_LIST.KEY_NAME]);
      // デフォルト設定のレイアウトマスタの値が空の場合は初期値を適用する
      if (!this.editRecord || Object.keys(this.editRecord).length === 0) {
        this.editRecord = deepCopy(this.initialValue);
      } else {
        if (this.editRecord[KEY_NAME_MULTI_PAT_LIST.KEY_NAME_SELECTED_LAYOUT] == null) {
          this.editRecord[KEY_NAME_MULTI_PAT_LIST.KEY_NAME_SELECTED_LAYOUT] = this.initialValue[KEY_NAME_MULTI_PAT_LIST.KEY_NAME_SELECTED_LAYOUT];
        } else if (!this.layoutMst.some(l => +l.patListLayoutCd === +this.editRecord[KEY_NAME_MULTI_PAT_LIST.KEY_NAME_SELECTED_LAYOUT])) {
          // NOTE: マスタ削除された場合、リストの先頭
          this.editRecord[KEY_NAME_MULTI_PAT_LIST.KEY_NAME_SELECTED_LAYOUT] = this.layoutMst[0] ? this.layoutMst[0].patListLayoutCd : 0;
        }
        if (this.editRecord[KEY_NAME_MULTI_PAT_LIST.KEY_NAME_START_DATE] == null) {
          this.editRecord[KEY_NAME_MULTI_PAT_LIST.KEY_NAME_START_DATE] = this.initialValue[KEY_NAME_MULTI_PAT_LIST.KEY_NAME_START_DATE];
        }
        this.initialValue = deepCopy(this.editRecord);
      }
      /*add FNSI-改修内容4214 任 start*/
      if(isScopedElementDisplayInline("phone-show-pat-list", this.$el || this)){
        const phoneShowElement = getScopedElementById("phone-show-pat-list", this.$el || this);

        if (phoneShowElement) {

          phoneShowElement.innerText = phoneShowElement.innerText + '\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0';

        }
      }
      /*add FNSI-改修内容4214 任 end*/
      // 開始期間の選択リストの設定完了
      this.isFromListReady = true;
      this.isExpanded = this.defaultExpanded;
    });
  },
  beforeUnmount() {
    Object.assign(this.$data, this.$options.data());
  },
};
</script>

<style scoped>
  /*add FNSI-改修内容4214 任 start*/
  @media (max-width: 500px){
    #pc-show-pat-list{display:none;}
  }
  @media (min-width: 501px){
    #phone-show-pat-list{display:none;}
  }
  /*add FNSI-改修内容4214 任 end*/
  /*add FNSI-改修内容4214 任 start*/
  .default-setting-content-last-row{
    display: flex;
    align-items: center;
  }
  .label-width{
    width: 2em;
  }
  /*add FNSI-改修内容4214 任 end*/
</style>
