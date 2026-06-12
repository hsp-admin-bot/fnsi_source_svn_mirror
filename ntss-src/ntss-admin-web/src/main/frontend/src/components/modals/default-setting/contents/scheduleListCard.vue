/**
 * デフォルト設定タブ - スケジュール表設定のコンポーネント
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
                <label class="default-setting-content-label">表示期間</label>
              </td>
              <td class="default-setting-content">
                <div style="display: flex;">
                  <div style="margin-right: 5px;" class="row-flex">
                    <v-ons-radio
                      v-model="dispWeekDuration"
                      name="radiogroupDispTerm"
                      value="1"
                      modifier="round"
                      input-id="radDispWeekDuration1"
                    />
                    <label for="radDispWeekDuration1" class="radio-btn-label">1週</label>
                  </div>
                  <div style="margin-right: 5px;" class="row-flex">
                    <v-ons-radio
                      v-model="dispWeekDuration"
                      name="radiogroupDispTerm"
                      value="2"
                      modifier="round"
                      input-id="radDispWeekDuration2"
                    />
                    <label for="radDispWeekDuration2" class="radio-btn-label">2週</label>
                  </div>
                  <div class="row-flex">
                    <v-ons-radio
                      v-model="dispWeekDuration"
                      name="radiogroupDispTerm"
                      value="3"
                      modifier="round"
                      input-id="radDispWeekDuration3"
                    />
                    <label for="radDispWeekDuration3" class="radio-btn-label">3週</label>
                  </div>
                </div>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">休日表示</label>
              </td>
              <td class="default-setting-content" style="display: flex;">
                <div class="row-flex">
                  <v-ons-checkbox input-id="chkDispHoliday" v-model="isCheckedHoliday" />
                  <label for="chkDispHoliday" class="radio-btn-label">休日を表示する</label>
                </div>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">クール</label>
              </td>
              <td class="default-setting-content schedule-kur-multiselect">
                <kendo-multiselect
                  v-if="kurNum !== null"
                  v-model="selectedKurIndexList"
                  :data-source="kurNamesForOption"
                  data-text-field="kurName"
                  data-value-field="kurCd"
                  placeholder="クール">
                </kendo-multiselect>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <!--mod FNSI-改修内容4214 任 start-->
                <!--<label class="default-setting-content-label" style="white-space: pre-line;">{{ "ベッドグループ\n透析室" }}</label>-->
                <label id="pc-show-schedule-list" class="default-setting-content-label white-space-nowrap" >{{ "ベッドグループ\n透析室" }}</label>
                <label id="phone-show-schedule-list" class="default-setting-content-label white-space-nowrap" >{{ "ベッドグループ\n透析室" }}</label>
                <!--mod FNSI-改修内容4214 任 end-->
              </td>
              <td class="default-setting-content">
                <v-ons-select v-if="roomBedGroupNum !== null" input-id="bedGroupCd" v-model="bedGroupCd">
                  <option
                    v-for="option in roomBedOption"
                    :key="option.length"
                    :value="option.bedCd"
                  >{{ option.bedName }}</option>
                </v-ons-select>
                <!-- <kendo-dropdownlist
                  v-if="roomBedGroupNum !== null"
                  v-model="bedGroupCd"
                  :data-source="roomBedOption"
                  data-text-field="bedName"
                  data-value-field="bedCd"
                  style="min-width: 9.6em;">
                </kendo-dropdownlist> -->
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">姓のみ表示</label>
              </td>
              <td class="default-setting-content" style="display: flex;">
                <div class="row-flex">
                  <v-ons-checkbox input-id="chkDispOnlyLastName" v-model="isCheckedName" />
                  <label for="chkDispOnlyLastName" class="radio-btn-label">姓のみ表示する</label>
                </div>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">不一致！表示</label>
              </td>
              <td class="default-setting-content" style="display: flex;">
                <div class="row-flex">
                  <v-ons-checkbox input-id="chkUnmatchMark" v-model="isCheckedUnmatch" />
                  <label for="chkUnmatchMark" class="radio-btn-label">表示する</label>
                </div>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">他の予定有◆表示</label>
              </td>
              <td class="default-setting-content" style="display: flex;">
                <div class="row-flex">
                  <v-ons-checkbox input-id="chkOtherPlanMark" v-model="isCheckedPlan" />
                  <label for="chkOtherPlanMark" class="radio-btn-label">表示する</label>
                </div>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">定期点検・水質検査予定■表示</label>
              </td>
              <td class="default-setting-content" style="display: flex;">
                <div class="row-flex">
                  <v-ons-checkbox input-id="chkMainteWaterPlanMark" v-model="isCheckedPlanMainteWater" />
                  <label for="chkMainteWaterPlanMark" class="radio-btn-label">表示する</label>
                </div>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title-last-row">
                <label class="default-setting-content-label">凡例の表示</label>
              </td>
              <td class="default-setting-content-last-row">
                <v-ons-switch v-model="isShowUsageGuide"></v-ons-switch>
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
   import {ApiHelper} from "@/apis/AxiosHelper";
   import {DEF_DISP_WEEK, DEF_KUR_MAX} from "@/components/schedule-list/Definitions.js";
   import {KEY_NAME_SCHEDULE_LIST} from "@/constants/defaultSettingConstants";
   import {deepCopy} from "@/functions/common/CommonFunctions";
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
      funcName:"スケジュール表",
      // データ初期値
      initialValue: {},
      // 編集するスケジュール表設定レコード
      editRecord: {},
      // クールリスト
      kurNamesForOption: [],
      // クール数
      kurNum: DEF_KUR_MAX,
      // ベッドグループオプション一覧
      roomBedGroupNamesForOption: [],
      // ベッドグループオプション数
      roomBedGroupNum: 0,
      // カード開閉状態(初期値をfalseにすることでOnsenUI内部挙動との競合を抑制)
      isExpanded: false,
    };
  },
  computed: {
    ...mapGetters("account-edit", {
      getDefaultSetting: "getDefaultSetting"
    }),
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),

    dispWeekDuration: {
      get() {
        return this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_DISP_WEEK_DURATION];
      },
      set(value) {
        this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_DISP_WEEK_DURATION] = value;
      }
    },
    isCheckedHoliday: {
      get() {
        return this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_HOLIDAY];
      },
      set(value) {
        this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_HOLIDAY] = value;
      }
    },
    selectedKurIndexList: {
      get() {
        return this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_SELECTED_KUR_LIST];
      },
      set(value) {
        this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_SELECTED_KUR_LIST] = value;
      }
    },
    bedGroupCd: {
      get() {
        return this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_BED_GROUP_CD];
      },
      set(value) {
        this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_BED_GROUP_CD] = value;
      }
    },
    isCheckedName: {
      get() {
        return this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_NAME];
      },
      set(value) {
        this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_NAME] = value;
      }
    },
    isCheckedUnmatch: {
      get() {
        return this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_UNMATCH];
      },
      set(value) {
        this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_UNMATCH] = value;
      }
    },
    isCheckedPlan: {
      get() {
        return this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_PLAN];
      },
      set(value) {
        this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_PLAN] = value;
      }
    },
    isCheckedPlanMainteWater: {
      get() {
        return this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_PLAN_MAINTE_WATER];
      },
      set(value) {
        this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_PLAN_MAINTE_WATER] = value;
      }
    },
    isShowUsageGuide: {
      get() {
        return this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_SHOW_GUIDE];
      },
      set(value) {
        this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_SHOW_GUIDE] = value;
      }
    },
    // ベッドグループの選択リスト
    roomBedOption() {
      return [{ bedCd: 0, bedName: "すべて" }, ...this.roomBedGroupNamesForOption];
    }
  },
  methods: {
    ...mapActions(
      "loading-screen", ["startLoadingScreen","finishLoadingScreen"]
    ),
    getSaveData() {
      let rtnData = {
        name: KEY_NAME_SCHEDULE_LIST.KEY_NAME,
        data: {}
      };
      rtnData.data[KEY_NAME_SCHEDULE_LIST.KEY_NAME_DISP_WEEK_DURATION] = this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_DISP_WEEK_DURATION];
      rtnData.data[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_HOLIDAY] = this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_HOLIDAY];
      rtnData.data[KEY_NAME_SCHEDULE_LIST.KEY_NAME_SELECTED_KUR_LIST] = this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_SELECTED_KUR_LIST];
      rtnData.data[KEY_NAME_SCHEDULE_LIST.KEY_NAME_BED_GROUP_CD] = this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_BED_GROUP_CD];
      rtnData.data[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_NAME] = this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_NAME];
      rtnData.data[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_UNMATCH] = this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_UNMATCH];
      rtnData.data[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_PLAN] = this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_PLAN];
      rtnData.data[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_PLAN_MAINTE_WATER] = this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_PLAN_MAINTE_WATER];
      rtnData.data[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_SHOW_GUIDE] = this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_SHOW_GUIDE];
      return rtnData;
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
            EventBus.$emit("isChanged", {componentName: "scheduleList", value: true});
            return;
          }
        }
        EventBus.$emit("isChanged", {componentName: "scheduleList", value: false});
      },
      deep: true
    },
    //add FNSI-5687 劉全航 end
  },
  async created() {
    // 共通ローダー表示開始
    this.startLoadingScreen();
    // クール、ベッドの取得
    const facilityCd = this.facilityCd;
    await ApiHelper.get("/scheduleList/getBedAndKurInfo", {
      facilityCd
    }).then(response => {
      this.kurNum = response.data.kur.length;
      this.roomBedGroupNum = response.data.roombedgroup.length;

      this.roomBedGroupNamesForOption = response.data.roombedgroup.map((rbr) => {
        return {bedCd: rbr.roomBedGroupCd, bedName: rbr.roomBedGroupName}
      });
      this.kurNamesForOption = response.data.kur.map((kur) => {
        return { kurCd: kur.kurCd, kurName: kur.kurName };
      });
    });

    // 初期値未設定の場合のデフォルト値を設定
    this.initialValue[KEY_NAME_SCHEDULE_LIST.KEY_NAME_DISP_WEEK_DURATION] = String(DEF_DISP_WEEK);
    this.initialValue[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_HOLIDAY] = true;
    this.initialValue[KEY_NAME_SCHEDULE_LIST.KEY_NAME_SELECTED_KUR_LIST] = this.kurNamesForOption.map((kur) => kur.kurCd);
    this.initialValue[KEY_NAME_SCHEDULE_LIST.KEY_NAME_BED_GROUP_CD] = 0;
    this.initialValue[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_NAME] = false;
    this.initialValue[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_UNMATCH] = false;
    this.initialValue[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_PLAN] = false;
    this.initialValue[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_PLAN_MAINTE_WATER] = false;
    this.initialValue[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_SHOW_GUIDE] = false;

    this.$nextTick(() => {
      this.editRecord = deepCopy(this.getDefaultSetting[KEY_NAME_SCHEDULE_LIST.KEY_NAME]);
      // データが空の場合は初期値を適用する
      if (!this.editRecord || Object.keys(this.editRecord).length === 0) {
        this.editRecord = deepCopy(this.initialValue);
      } else {
        if (this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_DISP_WEEK_DURATION] == null) {
          this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_DISP_WEEK_DURATION] = this.initialValue[KEY_NAME_SCHEDULE_LIST.KEY_NAME_DISP_WEEK_DURATION];
        }
        if (this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_HOLIDAY] == null) {
          this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_HOLIDAY] = this.initialValue[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_HOLIDAY];
        }
        if (this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_SELECTED_KUR_LIST] == null) {
          this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_SELECTED_KUR_LIST] = this.initialValue[KEY_NAME_SCHEDULE_LIST.KEY_NAME_SELECTED_KUR_LIST];
        } else {
          const validMstKurCd = this.kurNamesForOption.map(k => k.kurCd);
          const condKurCdsFilter = this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_SELECTED_KUR_LIST].filter(value => validMstKurCd.includes(value));
          if (condKurCdsFilter.length === 0) {
            // NOTE: マスタ削除しか設定しておらず、有効な選択肢が存在しない場合、初期値を再設定
            this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_SELECTED_KUR_LIST] = this.initialValue[KEY_NAME_SCHEDULE_LIST.KEY_NAME_SELECTED_KUR_LIST];
          }
        }
        if (this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_BED_GROUP_CD] == null) {
          this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_BED_GROUP_CD] = this.initialValue[KEY_NAME_SCHEDULE_LIST.KEY_NAME_BED_GROUP_CD];
        } else if (!this.roomBedGroupNamesForOption.some(rbg => +rbg.roomBedGroupCd === +this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_BED_GROUP_CD])) {
          // NOTE: マスタ削除された場合、「0 : すべて」を再設定
          this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_BED_GROUP_CD] = 0;
        }
        if (this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_NAME] == null) {
          this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_NAME] = this.initialValue[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_NAME];
        }
        if (this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_UNMATCH] == null) {
          this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_UNMATCH] = this.initialValue[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_UNMATCH];
        }
        if (this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_PLAN] == null) {
          this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_PLAN] = this.initialValue[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_PLAN];
        }
        if (this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_PLAN_MAINTE_WATER] == null) {
          // #12368でキーを後から追加したので、変更をwatchで検知出来るようにリアクティブにするため$setを使用
          ((this.editRecord)[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_PLAN_MAINTE_WATER] = this.initialValue[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_PLAN_MAINTE_WATER]);
        }
        if (this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_SHOW_GUIDE] == null) {
          this.editRecord[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_SHOW_GUIDE] = this.initialValue[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_SHOW_GUIDE];
        }
        this.initialValue = deepCopy(this.editRecord);
      }
      /*add FNSI-改修内容4214 任 start*/
      if(isScopedElementDisplayInline("phone-show-schedule-list", this.$el || this)){
        const phoneShowElement = getScopedElementById("phone-show-schedule-list", this.$el || this);

        if (phoneShowElement) {

          phoneShowElement.innerText = phoneShowElement.innerText + '\xa0\xa0';

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
.row-flex {
  display: flex;
  flex-direction: row;
  align-items: center;
}
.radio-btn-label {
  white-space: nowrap;
}
/*add FNSI-改修内容4214 任 start*/
@media (max-width: 500px){
  #pc-show-schedule-list{display:none;}
}
@media (min-width: 501px){
  #phone-show-schedule-list{display:none;}
}
/*add FNSI-改修内容4214 任 end*/
</style>
