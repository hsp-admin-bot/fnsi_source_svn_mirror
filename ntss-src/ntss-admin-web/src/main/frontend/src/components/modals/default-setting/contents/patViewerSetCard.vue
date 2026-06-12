/**
 * デフォルト設定タブ - 患者経過総合ビューア設定のコンポーネント
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
            <!-- 治療日のみ表示 -->
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">治療日のみ表示</label>
              </td>
              <td class="default-setting-content">
                <v-ons-checkbox
                  v-model="editRecord.isTreatmentOnly"
                />
              </td>
            </tr>
            <!-- 期間/レイアウト -->
            <tr>
              <td style="vertical-align: baseline;" class="default-setting-content-title">
                <!--mod FNSI-改修内容4214 任 start-->
                <!--<label class="default-setting-content-label">期間 / レイアウト</label>-->
                <label id="pc-show-pat-viewer" class="default-setting-content-label white-space-nowrap">期間 / レイアウト</label>
                <label id="phone-show-pat-viewer" class="default-setting-content-label white-space-nowrap">期間 / レイアウト</label>
                <!--mod FNSI-改修内容4214 任 end-->
              </td>
              <!-- mod FutreNetWeb+SI課題管理No4905対応 呉 start -->
              <td style="padding-bottom: 0.5em;" class="default-setting-content">
                <div style="display: flex;">
                  <div style="margin-right: 5px;" class="row-flex">
                    <v-ons-radio
                      v-model="editRecord.selectedPeriod"
                      :input-id="'rdoPeriod1'"
                      :value="'1'"
                      modifier="round"
                    />
                    <label :for="'rdoPeriod1'" class="radio-btn-label">3日分</label>
                  </div>
                  <div style="margin-right: 5px;" class="row-flex">
                    <v-ons-radio
                      v-model="editRecord.selectedPeriod"
                      :input-id="'rdoPeriod2'"
                      :value="'2'"
                      modifier="round"
                    />
                    <label :for="'rdoPeriod2'" class="radio-btn-label">7日分</label>
                  </div>
                  <div class="row-flex">
                    <v-ons-radio
                      v-model="editRecord.selectedPeriod"
                      :input-id="'rdoPeriod3'"
                      :value="'3'"
                      modifier="round"
                    />
                    <label :for="'rdoPeriod3'" class="radio-btn-label">14日分</label>
                  </div>
                </div>
                <v-ons-select
                  v-model="editRecord.setSelectedLayoutCd"
                  :disabled="!(3 >= editRecord.selectedPeriod)"
                  style="width:140px"
                >
                  <option
                    v-for="(layoutItem, layoutIndex) in smallPeriodDispItemOptions"
                    id="selectDispLayoutItem"
                    :key="layoutIndex"
                    :value="layoutItem.layoutCd"
                  >
                    {{ layoutItem.layoutName }}
                  </option>
                </v-ons-select>
              </td>
              <!-- mod FutreNetWeb+SI課題管理No4905対応 呉 end -->
            </tr>
            <tr>
              <td class="default-setting-content-title"></td>
              <!-- mod FutreNetWeb+SI課題管理No4905対応 呉 start -->
              <td class="default-setting-content">
                <div style="display: flex;">
                  <div style="margin-right: 5px;" class="row-flex">
                    <v-ons-radio
                      v-model="editRecord.selectedPeriod"
                      :input-id="'rdoPeriod4'"
                      :value="'4'"
                      modifier="round"
                    />
                    <label :for="'rdoPeriod4'" class="radio-btn-label">12週</label>
                  </div>
                  <div style="margin-right: 5px;" class="row-flex">
                    <v-ons-radio
                      v-model="editRecord.selectedPeriod"
                      :input-id="'rdoPeriod5'"
                      :value="'5'"
                      modifier="round"
                    />
                    <label :for="'rdoPeriod5'" class="radio-btn-label">6ヶ月</label>
                  </div>
                  <div style="margin-right: 5px;" class="row-flex">
                    <v-ons-radio
                      v-model="editRecord.selectedPeriod"
                      :input-id="'rdoPeriod6'"
                      :value="'6'"
                      modifier="round"
                    />
                    <label :for="'rdoPeriod6'" class="radio-btn-label">1年</label>
                  </div>
                  <div class="row-flex">
                    <v-ons-radio
                      v-model="editRecord.selectedPeriod"
                      :input-id="'rdoPeriod7'"
                      :value="'7'"
                      modifier="round"
                    />
                    <label :for="'rdoPeriod7'" class="radio-btn-label">3年</label>
                  </div>
                </div>
                <v-ons-select
                  v-model="editRecord.setSelectedLayoutCd"
                  :disabled="!(editRecord.selectedPeriod > 3)"
                  style="width:140px"
                >
                  <option
                    v-for="(layoutItem, layoutIndex) in largePeriodDispItemOptions"
                    id="selectDispLayoutItem"
                    :key="layoutIndex"
                    :value="layoutItem.layoutCd"
                  >
                    {{ layoutItem.layoutName }}
                  </option>
                </v-ons-select>
              </td>
              <!-- mod FutreNetWeb+SI課題管理No4905対応 呉 end -->
            </tr>
            <!-- 拡張表示 -->
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">拡張表示</label>
              </td>
              <td class="default-setting-content">
                <v-ons-checkbox v-model="editRecord.isExtendedView"></v-ons-checkbox>
              </td>
            </tr>
            <!-- 指示/実績の表示 -->
            <tr>
              <td style="vertical-align: baseline;" class="default-setting-content-title-last-row">
                <label class="default-setting-content-label">指示 / 実績の表示</label>
              </td>
              <td class="default-setting-content-last-row">
                <label
                  v-for="(data, index) in selectShowIndRstOptions"
                  :key="index"
                >
                  <!-- mod FutreNetWeb+SI課題管理No4905対応 呉 start -->
                  <v-ons-radio
                    v-model="editRecord.selectedShowIndRst"
                    :input-id="data.inputId"
                    :value="data.value"
                    modifier="round"
                  />
                  <!-- mod FutreNetWeb+SI課題管理No4905対応 呉 end -->
                    {{ data.label }}
                  <br v-if="1 === index" />
                </label>
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
  import {deepCopy} from "@/functions/common/CommonFunctions";
  import {KEY_NAME_PAT_VIEWER} from "@/constants/defaultSettingConstants";
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
      funcName:"患者経過総合ビューア",
      // データ初期値
      initialValue: {
        // 治療日のみ表示
        isTreatmentOnly: false,
        // 期間/レイアウト(期間/初期値：7日)
        selectedPeriod: "2",
        // 期間/レイアウト(レイアウト)
        setSelectedLayoutCd: null,
        // 拡張表示
        isExtendedView: false,
        // 指示・実績の表示(初期値：実績優先)
        selectedShowIndRst: "2"
      },
      // 編集する患者情報レコード
      editRecord: {},
      //add FNSI-5687 劉全航 start
      isCreated: false,
      //add FNSI-5687 劉全航 end
      // 指示・実績表示選択リスト
      selectShowIndRstOptions: [
        { label: "指示のみ", value: "1", inputId: "indRst1" },
        { label: "実績優先", value: "2", inputId: "indRst2" },
        { label: "実績指示併記", value: "3", inputId: "indRst3" }
      ],
      // 表示レイアウト項目
      dispLayoutItem: [],
      selectedLayoutCdByPeriodType: {
        small: null,
        large: null
      },
      // カード開閉状態(初期値をfalseにすることでOnsenUI内部挙動との競合を抑制)
      isExpanded: false,
    };
  },
  computed: {
    ...mapGetters("pat-viewer", [
      "getDispLayoutItemListData",
      "getSelectedCondition"
    ]),
    ...mapGetters("account-edit", {
      getDefaultSetting: "getDefaultSetting"
    }),
    //施設コード取得用
    ...mapGetters("user", ["getFacilityCd"]),

    /**
     * 3日・7日・14日選択時のレイアウト選択肢リスト
     */
    smallPeriodDispItemOptions() {
      return 3 >= this.editRecord.selectedPeriod ? this.dispLayoutItem : [];
    },

    /**
     * 12週・6ヶ月・1年・3年選択時のレイアウト選択肢リスト
     */
    largePeriodDispItemOptions() {
      return this.editRecord.selectedPeriod > 3 ? this.dispLayoutItem : [];
    },
  },
  methods: {
    ...mapActions("pat-viewer", [
      "getDispLayoutItemList"
    ]),
    ...mapActions(
      "loading-screen", ["startLoadingScreen","finishLoadingScreen"]
    ),
    /**
     * 表示項目リストの設定
     * @description 表示期間選択時の表示項目設定
     */
    setDispItemList() {
      this.dispLayoutItem = this.getDispLayoutItemListData.filter(item => {
        // 表示項目リストが格納されている場合
        if (0 !== item.dispItemInfo.length) {
          if (4 > Number(this.editRecord.selectedPeriod)) {
            // 3日・7日・14日選択時の項目設定
            return "0" === item.dispPeriodClass;
          } else {
            // 12週・6ヶ月・1年・3年選択時の項目設定
            return "1" === item.dispPeriodClass;
          }
        }
      });

      // レイアウトコードの先頭を格納
      if (this.dispLayoutItem.length === 0) {
        this.editRecord.setSelectedLayoutCd = null;
      } else {
        const periodType = +this.editRecord.selectedPeriod < 4 ? "small" : "large";
        const prevLayoutCd = this.selectedLayoutCdByPeriodType[periodType];
        const prevLayout = this.dispLayoutItem.find(
          layout => layout.layoutCd === prevLayoutCd
        );
        if (prevLayout) {
          // 3日・7日・14日選択時 <> 12週・6ヶ月・1年・3年選択時の以前の選択肢を適用
          this.editRecord.setSelectedLayoutCd = prevLayout.layoutCd;
        } else {
          // 初回表示の時、レイアウトリスト内に選択値が含まれている場合は、なにもしない / 含まれていなければ先頭を初期選択する
          const selectChk = this.dispLayoutItem.filter(item => {
            return this.editRecord.setSelectedLayoutCd == item.layoutCd;
          });
          if (selectChk.length === 0) {
            this.editRecord.setSelectedLayoutCd = this.dispLayoutItem[0].layoutCd;
          }
        }
      }
    },

    /**
     * 保存データ取得
     * @description 保存処理の時に、保存データを集計して渡す
     */
    getSaveData() {
      let rtnData = {
        name: KEY_NAME_PAT_VIEWER.KEY_NAME,
        data: {}
      };
      rtnData.data[KEY_NAME_PAT_VIEWER.KEY_NAME_TREAT_ONLY] = this.editRecord.isTreatmentOnly;
      rtnData.data[KEY_NAME_PAT_VIEWER.KEY_NAME_SELECTED_PERIOD] = this.editRecord.selectedPeriod;
      rtnData.data[KEY_NAME_PAT_VIEWER.KEY_NAME_EXTENDED_VIEW] = this.editRecord.isExtendedView;
      rtnData.data[KEY_NAME_PAT_VIEWER.KEY_NAME_SELECTED_SHOW_INDRST] = this.editRecord.selectedShowIndRst;
      rtnData.data[KEY_NAME_PAT_VIEWER.KEY_NAME_SELECTED_LAYOUT_CD] = this.editRecord.setSelectedLayoutCd;
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
          if((JSON.stringify(initialValue) !== JSON.stringify(editValue)) && this.isCreated){
            EventBus.$emit("isChanged", {componentName: "patViewer", value: true});
            return;
          }
        }
        EventBus.$emit("isChanged", {componentName: "patViewer", value: false});
      },
      deep: true
    },
    //add FNSI-5687 劉全航 end
    /**
     * 期間選択時
     */
    "editRecord.selectedPeriod"(value) {
      // 表示項目リストの設定
      // add #12459 デフォルト設定の患者経過総合ビューアレイアウトがサインイン後だけ表示が不正 zkm start
      if (this.getDispLayoutItemListData.length === 0) return;
      // add #12459 デフォルト設定の患者経過総合ビューアレイアウトがサインイン後だけ表示が不正 zkm end
      this.setDispItemList(value);
    },
    /**
     * 期間/レイアウト(レイアウト) のレイアウト選択が変更された場合の処理
     */
    "editRecord.setSelectedLayoutCd"(selectedLayoutCd) {
      const periodType = +this.editRecord.selectedPeriod < 4 ? "small" : "large";
      this.selectedLayoutCdByPeriodType[periodType] = selectedLayoutCd;
    }
  },
  async created() {
    // 共通ローダー表示開始
    this.startLoadingScreen();
    // store のデータを取得
    this.editRecord = deepCopy(this.getDefaultSetting[KEY_NAME_PAT_VIEWER.KEY_NAME]);
    if (!this.editRecord || Object.keys(this.editRecord).length === 0) {
      // データが空の場合は初期値を適用する
      this.editRecord = deepCopy(this.initialValue);
    } else {
      // データが存在する場合は、個別に存在しないデータをチェックする
      if (this.editRecord[KEY_NAME_PAT_VIEWER.KEY_NAME_TREAT_ONLY] == null) {
        this.editRecord[KEY_NAME_PAT_VIEWER.KEY_NAME_TREAT_ONLY] = this.initialValue.isTreatmentOnly;
      }
      if (this.editRecord[KEY_NAME_PAT_VIEWER.KEY_NAME_SELECTED_PERIOD] == null) {
        this.editRecord[KEY_NAME_PAT_VIEWER.KEY_NAME_SELECTED_PERIOD] = this.initialValue.selectedPeriod;
      }
      if (this.editRecord[KEY_NAME_PAT_VIEWER.KEY_NAME_EXTENDED_VIEW] == null) {
        this.editRecord[KEY_NAME_PAT_VIEWER.KEY_NAME_EXTENDED_VIEW] = this.initialValue.isExtendedView;
      }
      if (this.editRecord[KEY_NAME_PAT_VIEWER.KEY_NAME_SELECTED_SHOW_INDRST] == null) {
        this.editRecord[KEY_NAME_PAT_VIEWER.KEY_NAME_SELECTED_SHOW_INDRST] = this.initialValue.selectedShowIndRst;
      }
      if (this.editRecord[KEY_NAME_PAT_VIEWER.KEY_NAME_SELECTED_LAYOUT_CD] == null) {
        this.editRecord[KEY_NAME_PAT_VIEWER.KEY_NAME_SELECTED_LAYOUT_CD] = this.initialValue.setSelectedLayoutCd;
      }
      this.initialValue = deepCopy(this.editRecord);
    }
    // 項目作成の初期操作
    await this.getDispLayoutItemList({ facilityCd: this.getFacilityCd }).catch(
      error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
        getErrorMessage('patViewerSetCard.vue', 'created', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
        throw error;
      });
    // 取得したレイアウトが0の場合処理終了
    if (0 !== this.getDispLayoutItemListData.length) {
      // 選択された期間から項目候補・初期値を設定
      this.setDispItemList();
      this.$nextTick(() => {
        // 初期値を補正
        this.initialValue.setSelectedLayoutCd = this.editRecord.setSelectedLayoutCd;
        /*add FNSI-改修内容4214 任 start*/
        if(isScopedElementDisplayInline("phone-show-pat-viewer", this.$el || this)){
          const phoneShowElement = getScopedElementById("phone-show-pat-viewer", this.$el || this);

          if (phoneShowElement) {

            phoneShowElement.innerText = phoneShowElement.innerText + '\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0';

          }
        }
        /*add FNSI-改修内容4214 任 end*/
        //add FNSI-5687 劉全航 start
        this.isCreated = true;
        //add FNSI-5687 劉全航 end
      });
    }
    this.$nextTick(() => {
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
  #pc-show-pat-viewer{display:none;}
}
@media (min-width: 501px){
  #phone-show-pat-viewer{display:none;}
}
/*add FNSI-改修内容4214 任 end*/
</style>
