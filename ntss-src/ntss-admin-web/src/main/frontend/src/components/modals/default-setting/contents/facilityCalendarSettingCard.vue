/**
 * デフォルト設定タブ - 施設カレンダー設定のコンポーネント
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
                <!--<label class="default-setting-content-label">集計件数表示</label>-->
                <label id="pc-show-facility-calendar" class="default-setting-content-label white-space-nowrap">集計件数表示</label>
                <label id="phone-show-facility-calendar" class="default-setting-content-label white-space-nowrap">集計件数表示</label>
                <!--mod FNSI-改修内容4214 任 end-->
              </td>
              <td class="default-setting-content">
                <v-ons-switch v-model="viewTotal"></v-ons-switch>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">表示モード</label>
              </td>
              <td class="default-setting-content">
                <input
                  type="radio"
                  name="switchTimeRange"
                  value="1"
                  id="input-date-setting"
                  class="switch-time-range identification"
                  v-model="viewMode"
                  v-on:click="changeViewMode(1)"
                />
                <label for="input-date-setting" class="label switch-time-range-label first-of-type">日</label>
                <input
                  type="radio"
                  name="switchTimeRange"
                  value="2"
                  id="input-week-setting"
                  class="switch-time-range identification"
                  v-model="viewMode"
                  v-on:click="changeViewMode(2)"
                />
                <label for="input-week-setting" class="label switch-time-range-label middle-of-type">週</label>
                <input
                  type="radio"
                  name="switchTimeRange"
                  value="3"
                  id="input-month-setting"
                  class="switch-time-range identification"
                  v-model="viewMode"
                  v-on:click="changeViewMode(3)"
                />
                <label for="input-month-setting" class="label switch-time-range-label last-of-type">月</label>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title-last-row">
                <label class="default-setting-content-label">レイアウト</label>
              </td>
              <td class="default-setting-content-last-row">
                <kendo-dropdownlist
                  :data-source="layoutMst"
                  v-model="layoutCd"
                  data-text-field="layoutName"
                  data-value-field="layoutCd"
                  filter="contafacility"
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
   import {mapGetters, mapActions} from "vuex";
   /*add FNSI-改修内容4214 任 start*/
   import $ from "jquery";
   /*add FNSI-改修内容4214 任 end*/
   import {getFacilityCalendarMasterLayout} from "@/components/facility-calendar/Functions.js";
   import {FACILITY_CALENDAR} from "@/constants/defaultSettingConstants";
   import {deepCopy} from "@/functions/common/CommonFunctions";
   import {EventBus} from "@/eventBus";

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
      funcName:"施設カレンダー",
      // データ初期値
      initialValue: {},
      // 編集する施設カレンダーの設定レコード
      editRecord: {},
      // 施設カレンダーレイアウトマスタ一覧
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
        name: FACILITY_CALENDAR.KEY_NAME,
        data: {}
      };
      rtnData.data[FACILITY_CALENDAR.KEY_NAME_VIEW_TOTAL] = this.editRecord[FACILITY_CALENDAR.KEY_NAME_VIEW_TOTAL];
      rtnData.data[FACILITY_CALENDAR.KEY_NAME_VIEW_MODE] = this.editRecord[FACILITY_CALENDAR.KEY_NAME_VIEW_MODE];
      rtnData.data[FACILITY_CALENDAR.KEY_NAME_LAYOUT_CD] = this.editRecord[FACILITY_CALENDAR.KEY_NAME_LAYOUT_CD] ? Number(this.editRecord[FACILITY_CALENDAR.KEY_NAME_LAYOUT_CD]) : this.editRecord[FACILITY_CALENDAR.KEY_NAME_LAYOUT_CD];
      // TODO 掲載日、治療日、クール、ベッドグループ保留
      return rtnData;
    },

    // add FutreNetWeb+SI課題管理No4301対応 chen start
    changeViewMode(viewMode) {
      EventBus.$emit("goFacilityCalendar", viewMode);
    }
    // add FutreNetWeb+SI課題管理No4301対応 chen end
  },
  computed: {
    ...mapGetters("account-edit", {
      getDefaultSetting: "getDefaultSetting"
    }),
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    viewTotal: {
      get() {
        return this.editRecord[FACILITY_CALENDAR.KEY_NAME_VIEW_TOTAL];
      },
      set(value) {
        this.editRecord[FACILITY_CALENDAR.KEY_NAME_VIEW_TOTAL] = value;
      }
    },
    viewMode: {
      get() {
        return this.editRecord[FACILITY_CALENDAR.KEY_NAME_VIEW_MODE];
      },
      set(value) {
        this.editRecord[FACILITY_CALENDAR.KEY_NAME_VIEW_MODE] = value;
      }
    },
    layoutCd: {
      get() {
        return this.editRecord[FACILITY_CALENDAR.KEY_NAME_LAYOUT_CD];
      },
      set(value) {
        // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_個別設定 20231117 ztc start
        //this.editRecord[FACILITY_CALENDAR.KEY_NAME_LAYOUT_CD] = value;
        this.editRecord[FACILITY_CALENDAR.KEY_NAME_LAYOUT_CD] = Number(value);
        // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_個別設定 20231117 ztc end
      }
    }
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
            EventBus.$emit("isChanged", {componentName: "facilityCalendar", value: true});
            return;
          }
        }
        EventBus.$emit("isChanged", {componentName: "facilityCalendar", value: false});
      },
      deep: true
    },
    //add FNSI-5687 劉全航 end
  },
  async created() {
    // 共通ローダー表示開始
    this.startLoadingScreen();
    // 初期値未設定の場合のデフォルト値
    this.initialValue[FACILITY_CALENDAR.KEY_NAME_VIEW_TOTAL] = true;
    this.initialValue[FACILITY_CALENDAR.KEY_NAME_VIEW_MODE] = "3";
    this.initialValue[FACILITY_CALENDAR.KEY_NAME_LAYOUT_CD] = null;

    const mstList = await getFacilityCalendarMasterLayout(this.facilityCd);
    this.layoutMst = mstList.data.map(
      ({ facilityCalendarLayoutCd, facilityCalendarLayoutName }) => ({
        layoutCd: facilityCalendarLayoutCd,
        layoutName: facilityCalendarLayoutName
      })
    );

    this.$nextTick(() => {
      this.editRecord = deepCopy(this.getDefaultSetting[FACILITY_CALENDAR.KEY_NAME]);
      // データが空の場合は初期値を適用する
      if (!this.editRecord || Object.keys(this.editRecord).length === 0) {
        this.editRecord = deepCopy(this.initialValue);
      } else {
        if (this.editRecord[FACILITY_CALENDAR.KEY_NAME_VIEW_TOTAL] == null) {
          this.editRecord[FACILITY_CALENDAR.KEY_NAME_VIEW_TOTAL] = this.initialValue[FACILITY_CALENDAR.KEY_NAME_VIEW_TOTAL];
        }
        if (this.editRecord[FACILITY_CALENDAR.KEY_NAME_VIEW_MODE] == null) {
          this.editRecord[FACILITY_CALENDAR.KEY_NAME_VIEW_MODE] = this.initialValue[FACILITY_CALENDAR.KEY_NAME_VIEW_MODE];
        }
        if (this.editRecord[FACILITY_CALENDAR.KEY_NAME_LAYOUT_CD] == null) {
          this.editRecord[FACILITY_CALENDAR.KEY_NAME_LAYOUT_CD] = this.initialValue[FACILITY_CALENDAR.KEY_NAME_LAYOUT_CD];
        }
        this.initialValue = deepCopy(this.editRecord);
      }
      /*add FNSI-改修内容4214 任 start*/
      if($("#phone-show-facility-calendar").css("display") === "inline"){
        document.getElementById("phone-show-facility-calendar").innerText =  document.getElementById("phone-show-facility-calendar").innerText + '\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0';
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
.switch-time-range {
  display: none;
}
.switch-time-range-label {
  display: block; /* ブロックレベル要素化する */
  float: left; /* 要素の左寄せ・回り込を指定する */
  height: 2em; /* ボックスの高さを指定する */
  padding-left: 8px;
  padding-right: 8px;
  color: #ffffff; /* フォントの色を指定する */
  text-align: center; /* テキストのセンタリングを指定する */
  line-height: 2em; /* 行の高さを指定する */
  cursor: pointer; /* マウスカーソルの形（リンクカーソル）を指定する */
}
.first-of-type {
  border-radius: 10px 0 0 10px;
}
.last-of-type {
  border-radius: 0 10px 10px 0;
}
/*add FNSI-改修内容4214 任 start*/
@media (max-width: 500px){
  #pc-show-facility-calendar{display:none;}
}
@media (min-width: 501px){
  #phone-show-facility-calendar{display:none;}
}
/*add FNSI-改修内容4214 任 end*/
</style>
