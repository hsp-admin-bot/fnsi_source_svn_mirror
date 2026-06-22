/**
 * デフォルト設定タブ - 体重計測定記録設定のコンポーネント
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
                <label class="default-setting-content-label">クール</label>
              </td>
              <td class="default-setting-content">
                <v-ons-select class="select-width" v-model="kurCd">
                  <option value="-1">すべて</option>
                  <option
                    v-for="option in mstKurSelector"
                    :key="option.length"
                    :value="option.code"
                  >{{ option.name }}</option>
                </v-ons-select>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <!--mod FNSI-改修内容4214 任 start-->
                <!--<label class="default-setting-content-label">ベッドグループ</label>-->
                <label id="pc-show-measure-history" class="default-setting-content-label white-space-nowrap">ベッドグループ</label>
                <label id="phone-show-measure-history" class="default-setting-content-label white-space-nowrap">ベッドグループ</label>
                <!--mod FNSI-改修内容4214 任 end-->
              </td>
              <td class="default-setting-content">
                <v-ons-select class="select-width" v-model="bedGroupCd">
                  <option :value="defaultSelect">すべて</option>
                  <option
                    v-for="(option) in mstBedGroupList"
                    :key="option.length"
                    :value="option.roomBedGroupCd"
                  >{{ option.roomBedGroupName }}</option>
                </v-ons-select>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">フリーワード</label>
              </td>
              <td class="default-setting-content">
                <v-ons-input type="text" class="select-width" v-model="freeWord"></v-ons-input>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title-last-row">
                <label class="default-setting-content-label">条件送信結果</label>
              </td>
              <td class="default-setting-content-last-row">
                <v-ons-select class="select-width" v-model="weightScaleStatus">
                  <option value="-1">すべて</option>
                  <option
                    v-for="option in weightScaleStatusList"
                    :key="option.length"
                    :value="option.no"
                  >{{ option.statusName }}</option>
                </v-ons-select>
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
   import {KEY_NAME_MEASURE_HISTORY} from "@/constants/defaultSettingConstants";
   import {deepCopy} from "@/functions/common/CommonFunctions";
   import {sendRequestGetKurSelector} from "@/apis/send-condition";
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
      funcName:"体重計測定記録",
      // データ初期値
      initialValue: {},
      // 編集する体重計測定記録設定レコード
      editRecord: {},
      // クール一覧情報
      mstKurSelector: null,
      // ベッドグループ一覧情報
      mstBedGroupList: null,
      // 体重測定状況リスト
      weightScaleStatusList: [
        { no: 0, statusName: "測定済み" },
        { no: 1, statusName: "条件送信指示中" },
        { no: 2, statusName: "待機" },
        { no: 3, statusName: "条件送信成功" },
        { no: 4, statusName: "条件送信失敗" }
      ],
      // カード開閉状態(初期値をfalseにすることでOnsenUI内部挙動との競合を抑制)
      isExpanded: false,
    };
  },
  computed: {
    ...mapGetters("account-edit", {
      getDefaultSetting: "getDefaultSetting"
    }),
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    defaultSelect: () => 0,
    // クール
    kurCd: {
      get() {
        return this.editRecord[KEY_NAME_MEASURE_HISTORY.KEY_NAME_KUR_CD];
      },
      set(value) {
        this.editRecord[KEY_NAME_MEASURE_HISTORY.KEY_NAME_KUR_CD] = value;
      }
    },
    // ベッドグループ
    bedGroupCd: {
      get() {
        return this.editRecord[KEY_NAME_MEASURE_HISTORY.KEY_NAME_BED_GROUP_CD];
      },
      set(value) {
        this.editRecord[KEY_NAME_MEASURE_HISTORY.KEY_NAME_BED_GROUP_CD] = value;
      }
    },
    // フリーワード
    freeWord: {
      get() {
        return this.editRecord[KEY_NAME_MEASURE_HISTORY.KEY_NAME_FREEWORD];
      },
      set(value) {
        this.editRecord[KEY_NAME_MEASURE_HISTORY.KEY_NAME_FREEWORD] = value;
      }
    },
    // 条件送信結果
    weightScaleStatus: {
      get() {
        return this.editRecord[KEY_NAME_MEASURE_HISTORY.KEY_NAME_WEIGHT_SCALE_STATUS];
      },
      set(value) {
        this.editRecord[KEY_NAME_MEASURE_HISTORY.KEY_NAME_WEIGHT_SCALE_STATUS] = value;
      }
    }
  },
  methods: {
    ...mapActions(
      "loading-screen", ["startLoadingScreen","finishLoadingScreen"]
    ),
    getSaveData() {
      let rtnData = {
        name: KEY_NAME_MEASURE_HISTORY.KEY_NAME,
        data: {}
      };
      rtnData.data[KEY_NAME_MEASURE_HISTORY.KEY_NAME_KUR_CD] = this.editRecord[KEY_NAME_MEASURE_HISTORY.KEY_NAME_KUR_CD];
      rtnData.data[KEY_NAME_MEASURE_HISTORY.KEY_NAME_BED_GROUP_CD] = this.editRecord[KEY_NAME_MEASURE_HISTORY.KEY_NAME_BED_GROUP_CD];
      rtnData.data[KEY_NAME_MEASURE_HISTORY.KEY_NAME_FREEWORD] = this.editRecord[KEY_NAME_MEASURE_HISTORY.KEY_NAME_FREEWORD];
      rtnData.data[KEY_NAME_MEASURE_HISTORY.KEY_NAME_WEIGHT_SCALE_STATUS] = this.editRecord[KEY_NAME_MEASURE_HISTORY.KEY_NAME_WEIGHT_SCALE_STATUS];
      return rtnData;
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
            EventBus.$emit("isChanged", {componentName: "measureHistory", value: true});
            return;
          }
        }
        EventBus.$emit("isChanged", {componentName: "measureHistory", value: false});
      },
      deep: true
    },
    //add FNSI-5687 劉全航 end
  },
  async created() {
    // 共通ローダー表示開始
    this.startLoadingScreen();
    // クールとベッドの一覧取得
    //mod 8646 【デグレ】スケジュール表のベッドグループの表示が不正 張 start
    // sendRequestGetKurSelector(1).then(response => {
    await sendRequestGetKurSelector(undefined,this.facilityCd).then(response => {
    //mod 8646 【デグレ】スケジュール表のベッドグループの表示が不正 張 end
      // 取得したクール一覧情報をセット
      this.mstKurSelector = response.data.kurSelector;
      // 取得したベッドグループ一覧情報をセット
      this.mstBedGroupList = response.data.bedGroupList.copyWithin(0, 0);
    }).catch(error => {
      //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
      getErrorMessage('measureHistorySettingCard.vue', 'created', error);
      //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
      console.error(error);
    });

    // 初期値未設定の場合のデフォルト値
    this.initialValue[KEY_NAME_MEASURE_HISTORY.KEY_NAME_KUR_CD] = "-1";
    this.initialValue[KEY_NAME_MEASURE_HISTORY.KEY_NAME_BED_GROUP_CD] = 0;
    this.initialValue[KEY_NAME_MEASURE_HISTORY.KEY_NAME_FREEWORD] = "";
    this.initialValue[KEY_NAME_MEASURE_HISTORY.KEY_NAME_WEIGHT_SCALE_STATUS] = "-1";

    this.$nextTick(() => {
      this.editRecord = deepCopy(this.getDefaultSetting[KEY_NAME_MEASURE_HISTORY.KEY_NAME]);
      // データが空の場合は初期値を適用する
      if (!this.editRecord || Object.keys(this.editRecord).length === 0) {
        this.editRecord = deepCopy(this.initialValue);
      } else {
        if (this.editRecord[KEY_NAME_MEASURE_HISTORY.KEY_NAME_KUR_CD] == null) {
          this.editRecord[KEY_NAME_MEASURE_HISTORY.KEY_NAME_KUR_CD] = this.initialValue[KEY_NAME_MEASURE_HISTORY.KEY_NAME_KUR_CD];
        } else if (!this.mstKurSelector.some(kur => +kur.kurCd === +this.editRecord[KEY_NAME_MEASURE_HISTORY.KEY_NAME_KUR_CD])) {
          // NOTE: マスタ削除された場合、「-1 : すべて」を再設定
          this.editRecord[KEY_NAME_MEASURE_HISTORY.KEY_NAME_KUR_CD] = "-1";
        }
        if (this.editRecord[KEY_NAME_MEASURE_HISTORY.KEY_NAME_BED_GROUP_CD] == null) {
          this.editRecord[KEY_NAME_MEASURE_HISTORY.KEY_NAME_BED_GROUP_CD] = this.initialValue[KEY_NAME_MEASURE_HISTORY.KEY_NAME_BED_GROUP_CD];
        } else if (!this.mstBedGroupList.some(bg => +bg.bedGroupCd === +this.editRecord[KEY_NAME_MEASURE_HISTORY.KEY_NAME_BED_GROUP_CD])) {
          // NOTE: マスタ削除された場合、「0 : すべて」を再設定
          this.editRecord[KEY_NAME_MEASURE_HISTORY.KEY_NAME_BED_GROUP_CD] = 0;
        }
        if (this.editRecord[KEY_NAME_MEASURE_HISTORY.KEY_NAME_FREEWORD] == null) {
          this.editRecord[KEY_NAME_MEASURE_HISTORY.KEY_NAME_FREEWORD] = this.initialValue[KEY_NAME_MEASURE_HISTORY.KEY_NAME_FREEWORD];
        }
        if (this.editRecord[KEY_NAME_MEASURE_HISTORY.KEY_NAME_WEIGHT_SCALE_STATUS] == null) {
          this.editRecord[KEY_NAME_MEASURE_HISTORY.KEY_NAME_WEIGHT_SCALE_STATUS] = this.initialValue[KEY_NAME_MEASURE_HISTORY.KEY_NAME_WEIGHT_SCALE_STATUS];
        }
        this.initialValue = deepCopy(this.editRecord);
      }
      /*add FNSI-改修内容4214 任 start*/
      if(isScopedElementDisplayInline("phone-show-measure-history", this.$el || this)){
        const phoneShowElement = getScopedElementById("phone-show-measure-history", this.$el || this);

        if (phoneShowElement) {

          phoneShowElement.innerText = phoneShowElement.innerText + '\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0';

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
.select-width {
  min-width: 140px;
  width: 12.4em;
}
/*add FNSI-改修内容4214 任 start*/
@media (max-width: 500px){
  #pc-show-measure-history{display:none;}
}
@media (min-width: 501px){
  #phone-show-measure-history{display:none;}
}
/*add FNSI-改修内容4214 任 end*/
</style>
