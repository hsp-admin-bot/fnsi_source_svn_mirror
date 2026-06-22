/**
 * デフォルト設定タブ - 患者カレンダー設定のコンポーネント
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
                <label id="pc-show-pat-calendar" class="default-setting-content-label white-space-nowrap">レイアウト</label>
                <label id="phone-show-pat-calendar" class="default-setting-content-label white-space-nowrap">レイアウト</label>
                <!--mod FNSI-改修内容4214 任 end-->
              </td>
              <td class="default-setting-content">
                <kendo-dropdownlist
                  :data-source="layoutMst"
                  v-model="selectedLayout"
                  data-text-field="layoutName"
                  data-value-field="layoutCd"
                  filter="contains"
                />
              </td>
            </tr>
            <!-- add #8091 2023/03/15 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 start -->
            <tr>
              <td class="default-setting-content-title-last-row">
                <label class="default-setting-content-label white-space-nowrap">展開する</label>
              </td>
              <td class="default-setting-content-last-row">
                <v-ons-checkbox class="expand" input-id="expand" v-model="expandFlg" @click="handleExpandFlg"/>
                <label class="expand-name" for="expand">展開する</label>
              </td>
            </tr>
            <!-- add #8091 2023/03/15 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 end -->
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
   import {PAT_CALENDAR} from "@/constants/defaultSettingConstants";
   import {deepCopy} from "@/functions/common/CommonFunctions";
   import {patCalendarLayout} from "@/functions/mst/MstGetters.js";
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
      funcName:"患者カレンダー",
      // データ初期値
      initialValue: {},
      // 編集する患者カレンダー設定レコード
      editRecord: {},
      // 患者カレンダーレイアウトマスタ一覧
      layoutMst: [],
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
        name: PAT_CALENDAR.KEY_NAME,
        data: {}
      };
      rtnData.data[PAT_CALENDAR.KEY_NAME_SELECTED_LAYOUT_CD] = this.editRecord[PAT_CALENDAR.KEY_NAME_SELECTED_LAYOUT_CD];
      // #8091 2023/03/15 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 start
      rtnData.data[PAT_CALENDAR.KEY_NAME_EXPAND_FLG] = this.editRecord[PAT_CALENDAR.KEY_NAME_EXPAND_FLG];
      // #8091 2023/03/15 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 end
      return rtnData;
    },
    // add #8091 2023/03/25 個人設定の展開するcheckbox をON/OFFするしても、保存ボタンは非活性化のまま 林峻峰 start
    handleExpandFlg(event) {
      if(JSON.stringify(this.initialValue.expandFlg) !== JSON.stringify(event.target.checked)){
        EventBus.$emit("isChanged", {componentName: "patCalendar", value: true});
        return;
      }
      EventBus.$emit("isChanged", {componentName: "patCalendar", value: false});
    }
    // add #8091 2023/03/25 個人設定の展開するcheckbox をON/OFFするしても、保存ボタンは非活性化のまま 林峻峰 end
  },
  computed: {
    ...mapGetters("account-edit", {
      getDefaultSetting: "getDefaultSetting"
    }),
    // add bug #4293 修正 chen start
    ...mapGetters("user", {facilityCd: "getFacilityCd"}),
    // add bug #4293 修正 chen end
    ...mapGetters("pat-event/list", [
      "getMstCategoryRecords",
      "getMstSubCategoryRecords"
    ]),
    selectedLayout: {
      get() {
        return this.editRecord[PAT_CALENDAR.KEY_NAME_SELECTED_LAYOUT_CD];
      },
      set(value) {
        this.editRecord[PAT_CALENDAR.KEY_NAME_SELECTED_LAYOUT_CD] = value;
      }
    },
    // #8091 2023/03/15 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 start
    expandFlg: {
      get() {
        return this.editRecord[PAT_CALENDAR.KEY_NAME_EXPAND_FLG];
      },
      set(value) {
        this.editRecord[PAT_CALENDAR.KEY_NAME_EXPAND_FLG] = value;
      }
    },
    // #8091 2023/03/15 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 end
  },
  watch: {
    //add FNSI-5687 劉全航 start
    editRecord: {
      handler(newValue, oldValue){
        var keySet = Object.keys(this.initialValue);
        for(let key of keySet){
          let initialValue = this.initialValue[key];
          // mod #5687 個人設定	編集をしていなくても内容破棄確認モーダルが表示される 林峻峰 start
          // let editValue = parseInt(newValue[key]);
          let editValue = newValue[key];
          if (key === PAT_CALENDAR.KEY_NAME_SELECTED_LAYOUT_CD) {
            initialValue = parseInt(initialValue);
            editValue = parseInt(editValue);
          }
          // mod #5687 個人設定	編集をしていなくても内容破棄確認モーダルが表示される 林峻峰 end
          if(JSON.stringify(initialValue) !== JSON.stringify(editValue)){
            EventBus.$emit("isChanged", {componentName: "patCalendar", value: true});
            return;
          }
        }
        EventBus.$emit("isChanged", {componentName: "patCalendar", value: false});
      },
      deep: true
    },
    //add FNSI-5687 劉全航 end
  },
  async created() {
    // 共通ローダー表示開始
    this.startLoadingScreen();
    const mstPatCalendarLayout = await patCalendarLayout(this.facilityCd);
    this.layoutMst = mstPatCalendarLayout.map(
      ({ patCalendarLayoutCd, patCalendarLayoutName }) => ({
        layoutCd: patCalendarLayoutCd,
        layoutName: patCalendarLayoutName
      })
    );

    // 初期値未設定の場合のデフォルト値
    this.initialValue[PAT_CALENDAR.KEY_NAME_SELECTED_LAYOUT_CD] = "";

    if(this.layoutMst.length > 0) {
      this.initialValue[PAT_CALENDAR.KEY_NAME_SELECTED_LAYOUT_CD] = this.layoutMst[0].layoutCd;
      this.selectedLayout = this.layoutMst[0].layoutCd;
    }
    // mod #8091 2023/03/25 個人設定の展開するcheckbox をON/OFFするしても、保存ボタンは非活性化のまま 林峻峰 start
    this.initialValue[PAT_CALENDAR.KEY_NAME_EXPAND_FLG] = false;
    // mod #8091 2023/03/25 個人設定の展開するcheckbox をON/OFFするしても、保存ボタンは非活性化のまま 林峻峰 end

    this.$nextTick(() => {
      this.editRecord = deepCopy(this.getDefaultSetting[PAT_CALENDAR.KEY_NAME]);
      // データが空の場合は初期値を適用する
      if (!this.editRecord || Object.keys(this.editRecord).length === 0) {
        this.editRecord = deepCopy(this.initialValue);
      } else {
        if (this.editRecord[PAT_CALENDAR.KEY_NAME_SELECTED_LAYOUT_CD] == null) {
          this.editRecord[PAT_CALENDAR.KEY_NAME_SELECTED_LAYOUT_CD] = this.initialValue[PAT_CALENDAR.KEY_NAME_SELECTED_LAYOUT_CD];
        } else if (!this.layoutMst.some(l => +l.layoutCd === +this.editRecord[PAT_CALENDAR.KEY_NAME_SELECTED_LAYOUT_CD])) {
          // NOTE: マスタ削除された場合、リストの先頭を再設定
          this.editRecord[PAT_CALENDAR.KEY_NAME_SELECTED_LAYOUT_CD] = this.layoutMst.length > 0 ? this.layoutMst[0].layoutCd : "";
        }
        // add #8091 2023/03/25 個人設定の展開するcheckbox をON/OFFするしても、保存ボタンは非活性化のまま 林峻峰 start
        if (this.editRecord[PAT_CALENDAR.KEY_NAME_EXPAND_FLG] == null) {
          this.editRecord[PAT_CALENDAR.KEY_NAME_EXPAND_FLG] = this.initialValue[PAT_CALENDAR.KEY_NAME_EXPAND_FLG];
        }
        // add #8091 2023/03/25 個人設定の展開するcheckbox をON/OFFするしても、保存ボタンは非活性化のまま 林峻峰 end
        this.initialValue = deepCopy(this.editRecord);
      }
      /*add FNSI-改修内容4214 任 start*/
      if(isScopedElementDisplayInline("phone-show-pat-calendar", this.$el || this)){
        const phoneShowElement = getScopedElementById("phone-show-pat-calendar", this.$el || this);

        if (phoneShowElement) {

          phoneShowElement.innerText = phoneShowElement.innerText + '\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0';

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
    #pc-show-pat-calendar{display:none;}
  }
  @media (min-width: 501px){
    #phone-show-pat-calendar{display:none;}
  }
  /*add FNSI-改修内容4214 任 end*/
</style>
