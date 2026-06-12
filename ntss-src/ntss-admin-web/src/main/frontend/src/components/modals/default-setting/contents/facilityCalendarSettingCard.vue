/**
 * デフォルト設定タブ - 施設カレンダー設定のコンポーネント
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
      <div class="expandable-content card-contents facility-calendar-setting-card-inner">
        <!-- 開始日 DDL が無いため、既定の DATE_CHOICES と同構成の「見えない Kendo」を置きレイアウト DDL の横幅基準とする -->
        <div
          ref="facilityCalendarMeasureHost"
          class="facility-calendar-kendo-measure-anchor"
          aria-hidden="true"
        >
          <kendo-dropdownlist
            disabled
            :data-source="facilityCalendarMeasureDdlDs"
            v-model="facilityCalendarMeasureDdlVm"
            data-text-field="title"
            data-value-field="value"
          />
        </div>
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
                <div ref="facilityCalendarLayoutWrap" class="facility-calendar-layout-dropdown">
                  <kendo-dropdownlist
                    ref="refFacilityCalendarLayoutDdl"
                    :data-source="layoutMst"
                    v-model="layoutCd"
                    data-text-field="layoutName"
                    data-value-field="layoutCd"
                    filter="contains"
                    @open="onFacilityCalendarLayoutDdlOpen"
                  />
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
   import {mapGetters, mapActions} from "@/compat/vue/vuex";
   /*add FNSI-改修内容4214 任 start*/

   /*add FNSI-改修内容4214 任 end*/
   import {getFacilityCalendarMasterLayout} from "@/components/facility-calendar/Functions.js";
   import {DATE_CHOICES, FACILITY_CALENDAR} from "@/constants/defaultSettingConstants";
   import {deepCopy} from "@/functions/common/CommonFunctions";
   import {EventBus} from "@/compat/vue/event-bus.js";
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
      funcName:"施設カレンダー",
      // データ初期値
      initialValue: {},
      // 編集する施設カレンダーの設定レコード
      editRecord: {},
      // 施設カレンダーレイアウトマスタ一覧
      layoutMst: [],
      facilityCalendarMeasureDdlVm: DATE_CHOICES.BEFORE_ONE_WEEK.value,
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
    },
    // add FutreNetWeb+SI課題管理No4301対応 chen end

    /**
     * レイアウト DropDown 外枠を「開始日行 Kendo」と同程度の幅に固定する。
     * 表内に開始日が無いので、画面外の DATE_CHOICES 計測用 DropDown の実測幅を使う。
     */
    pinFacilityCalendarLayoutDdlOuterWidth() {
      const wrap = this.$refs.facilityCalendarLayoutWrap;
      const measureHost = this.$refs.facilityCalendarMeasureHost;
      if (!wrap || !measureHost || typeof this.$el?.querySelector !== "function") {
        return;
      }
      const measurePicker = measureHost.querySelector("span.k-dropdownlist.k-picker");
      let refW = measurePicker?.getBoundingClientRect?.().width ?? 0;
      if (!(refW > 2)) {
        wrap.style.width = "";
        wrap.style.minWidth = "";
        wrap.style.maxWidth = "";
        return;
      }
      const td = wrap.closest?.("td");
      const tdW = td?.getBoundingClientRect?.().width ?? refW;
      const wPx = `${Math.round(Math.min(refW, tdW || refW))}px`;
      wrap.style.boxSizing = "border-box";
      wrap.style.width = wPx;
      wrap.style.minWidth = wPx;
      wrap.style.maxWidth = wPx;
    },

    schedulePinFacilityCalendarLayoutDdlOuterWidth() {
      window.requestAnimationFrame(() => {
        this.$nextTick(() => this.pinFacilityCalendarLayoutDdlOuterWidth());
      });
      window.setTimeout(() => this.pinFacilityCalendarLayoutDdlOuterWidth(), 0);
      window.setTimeout(() => this.pinFacilityCalendarLayoutDdlOuterWidth(), 120);
      window.setTimeout(() => this.pinFacilityCalendarLayoutDdlOuterWidth(), 280);
      window.setTimeout(() => this.pinFacilityCalendarLayoutDdlOuterWidth(), 500);
    },

    onFacilityCalendarLayoutDdlOpen() {
      const squeeze = () => {
        const wrap = this.$el?.querySelector?.(".facility-calendar-layout-dropdown");
        const ddl = this.$refs.refFacilityCalendarLayoutDdl;
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
        this.editRecord[FACILITY_CALENDAR.KEY_NAME_LAYOUT_CD] = Number(value);
      }
    },
    /** 開始日 DDL と同等の標準横幅を得る（非表示計測用） */
    facilityCalendarMeasureDdlDs() {
      return [DATE_CHOICES.BEFORE_ONE_WEEK];
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
    isExpanded() {
      this.schedulePinFacilityCalendarLayoutDdlOuterWidth();
    }
  },
  async created() {
    // 共通ローダー表示開始
    this.startLoadingScreen();

    const mstList = await getFacilityCalendarMasterLayout(this.facilityCd);
    this.layoutMst = mstList.data.map(
      ({ facilityCalendarLayoutCd, facilityCalendarLayoutName }) => ({
        layoutCd: facilityCalendarLayoutCd,
        layoutName: facilityCalendarLayoutName
      })
    );

    // 初期値未設定の場合のデフォルト値
    this.initialValue[FACILITY_CALENDAR.KEY_NAME_VIEW_TOTAL] = true;
    this.initialValue[FACILITY_CALENDAR.KEY_NAME_VIEW_MODE] = "3";
    this.initialValue[FACILITY_CALENDAR.KEY_NAME_LAYOUT_CD] = this.layoutMst[0] ? this.layoutMst[0].layoutCd : 0;

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
        } else if (!this.layoutMst.some(l => +l.layoutCd === +this.editRecord[FACILITY_CALENDAR.KEY_NAME_LAYOUT_CD])) {
          // NOTE: マスタ削除された場合、リストの先頭
          this.editRecord[FACILITY_CALENDAR.KEY_NAME_LAYOUT_CD] = this.layoutMst[0] ? this.layoutMst[0].layoutCd : 0;
        }
        this.initialValue = deepCopy(this.editRecord);
      }
      /*add FNSI-改修内容4214 任 start*/
      if(isScopedElementDisplayInline("phone-show-facility-calendar", this.$el || this)){
        const phoneShowElement = getScopedElementById("phone-show-facility-calendar", this.$el || this);

        if (phoneShowElement) {

          phoneShowElement.innerText = phoneShowElement.innerText + '\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0';

        }
      }
      /*add FNSI-改修内容4214 任 end*/
      // 共通ローダー表示終了
      this.finishLoadingScreen();
      this.isExpanded = this.defaultExpanded;
      this.schedulePinFacilityCalendarLayoutDdlOuterWidth();
    });
  },
  mounted() {
    this.schedulePinFacilityCalendarLayoutDdlOuterWidth();
    this._onFacilityCalendarWinResizePin = () =>
      this.schedulePinFacilityCalendarLayoutDdlOuterWidth();
    window.addEventListener("resize", this._onFacilityCalendarWinResizePin, { passive: true });
  },
  beforeUnmount() {
    if (this._onFacilityCalendarWinResizePin) {
      window.removeEventListener("resize", this._onFacilityCalendarWinResizePin);
    }
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

<style>
  /*
   * レイアウト DDL：親を position 基準にし、開始日 DDL 相当の横幅を計測（画面外 Kendo）。
   */
  .facility-calendar-setting-card-inner {
    position: relative;
  }

  .facility-calendar-kendo-measure-anchor {
    position: absolute;
    left: -42000px;
    top: 0;
    width: auto;
    height: 2em;
    overflow: visible;
    pointer-events: none;
    opacity: 0;
    visibility: visible;
    z-index: -1;
  }

  /*
   * 施設カレンダー・レイアウト（開始日 DDL 相当の計測幅で外枠を固定）
   */
  .facility-calendar-layout-dropdown {
    display: inline-block;
    max-width: 100%;
    min-width: 0;
    vertical-align: middle;
    box-sizing: border-box;
  }

  .facility-calendar-layout-dropdown span.k-dropdownlist.k-picker {
    box-sizing: border-box;
    display: inline-flex !important;
    align-items: stretch;
    width: 100% !important;
    max-width: 100% !important;
    min-width: 0 !important;
    position: relative !important;
    overflow: hidden;
    vertical-align: middle;
  }

  .facility-calendar-layout-dropdown span.k-dropdownlist.k-picker > span.k-input-inner.k-dropdown-wrap,
  .facility-calendar-layout-dropdown span.k-dropdownlist.k-picker > span.k-input-inner {
    flex: 1 1 auto !important;
    min-width: 0 !important;
    max-width: 100%;
    overflow: hidden !important;
    padding-right: 2em !important;
    box-sizing: border-box;
  }

  .facility-calendar-layout-dropdown span.k-dropdownlist.k-picker > .k-input-button.k-select {
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

  .facility-calendar-layout-dropdown span.k-input-inner .k-input-value-text,
  .facility-calendar-layout-dropdown span.k-input-value-text.k-input {
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

  .ntss-kendo-popup-owner-facility-calendar-layout-dropdown.ntss-kendo-dropdownlist-popup-legacy.k-animation-container {
    box-sizing: border-box;
    max-width: calc(100vw - 24px);
  }

  .ntss-kendo-popup-owner-facility-calendar-layout-dropdown.ntss-kendo-dropdownlist-popup-legacy.k-animation-container .k-popup,
  .ntss-kendo-popup-owner-facility-calendar-layout-dropdown.ntss-kendo-dropdownlist-popup-legacy.k-animation-container .k-list-container {
    box-sizing: border-box !important;
    overflow-x: hidden !important;
  }

  .ntss-kendo-popup-owner-facility-calendar-layout-dropdown .k-list-item,
  .ntss-kendo-popup-owner-facility-calendar-layout-dropdown .k-list-item-text {
    box-sizing: border-box;
    max-width: 100%;
    overflow: hidden !important;
    text-overflow: clip !important;
    white-space: nowrap !important;
  }
</style>
