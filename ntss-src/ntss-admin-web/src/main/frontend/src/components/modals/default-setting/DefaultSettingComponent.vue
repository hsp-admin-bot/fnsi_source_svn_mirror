/**
 * 個人設定タブ - デフォルト設定タブのコンポーネント
 */
 <template>
  <div class="common-tab-area">
    <div class="common-tab-content" :style="heightStyles">
      <div ref="defaultSettingList">
        <component v-for="(func, index) in sortedItems"
          :is="func.componentName"
          :ref="`${func.ref}`"
          :key="`func_${index}`"
          :defaultExpanded="true"
        />
      </div>
    </div>
    <div v-if="this.showFooter" class="common-tab-footer">
      <v-ons-row width="100%">
        <v-ons-col width="50%">
          <v-ons-button
            class="btn2-cancel denial-btn"
            style="width: auto;"
            @click="cancel"
          >キャンセル</v-ons-button>
        </v-ons-col>
        <v-ons-col width="50%" class="right">
          <v-ons-button
            class="btn1-execute registration-btn"
            style="width: auto;"
            :disabled="!isChanged"
            @click="save"
          >保存</v-ons-button>
        </v-ons-col>
      </v-ons-row>
    </div>
  </div>
</template>

<script>
  import _ from "underscore";
  import {mapActions, mapGetters} from "vuex";
  import {sendRequestGetDefaultSettingDispOrder} from "@/apis/User";
  import {
    FUNC_BBS_INFO,
    FUNC_CHECK_LIST,
    FUNC_EXAM_RECORD,
    FUNC_EXAM_REQUEST,
    FUNC_FACILITY_CALENDAR,
    FUNC_INDICATION,
    FUNC_MEASURE_HISTORY,
    FUNC_MULTI_PAT_LIST,
    FUNC_PAT_CALENDAR,
    FUNC_PAT_EVENT,
    FUNC_PAT_INFO,
    FUNC_PAT_INFO_CREATE,
    FUNC_PAT_INTRO_LETTER,
    FUNC_PAT_VIEWER,
    FUNC_PRESCRIPTION,
    FUNC_RAD_REQUEST,
    FUNC_SCHEDULE_LIST,
    FUNC_STATUS_LIST_MAIN,
    FUNC_STATUS_MAP,
    FUNC_PERIODIC_INSPECTION,
    FUNC_DAILY_CHECK,
    FUNC_WATER_QUALITY_SURVEY,
    FUNC_SHARING_PATIENT_INFORMATION,
    FUNC_OBSERVE_RECORD,
    FUNC_SCALE_BED
  } from "@/constants/function-code";
  // 患者経過総合ビューア
  import defPatViewerSet from "@/components/modals/default-setting/contents/patViewerSetCard";
  // 患者情報・新規患者登録
  import defPatInfoSet from "@/components/modals/default-setting/contents/patInfoSetCard";
  // データリスト
  import defMultiPatListSettingCard from "@/components/modals/default-setting/contents/multiPatListSettingCard";
  // スケジュール表
  import defScheduleList from "@/components/modals/default-setting/contents/scheduleListCard";
  // 治療状況リスト
  import defStatusList from "@/components/modals/default-setting/contents/statusListCard";
  // 治療状況マップ
  import defStatusMap from "@/components/modals/default-setting/contents/statusMapCard";
  // 体重計測定記録
  import defMeasureHistorySetting from "@/components/modals/default-setting/contents/measureHistorySettingCard";
  // チェックリスト
  import defCheckList from "@/components/modals/default-setting/contents/checkListSettingCard";
  // 検査結果
  import defExamRecord from "@/components/modals/default-setting/contents/examRecordSettingCard";
  // 掲示板
  import defBbsInfo from "@/components/modals/default-setting/contents/bbsInfoSettingCard";
  // 検査依頼一覧
  import defExamRequest from "@/components/modals/default-setting/contents/examRequestSettingCard";
  // 一般撮影検査依頼一覧
  import defRadRequest from "@/components/modals/default-setting/contents/radRequestSettingCard";
  // 患者カレンダー
  import defPatCalendar from "@/components/modals/default-setting/contents/patCalendarSettingCard";
  // 患者イベント
  import defPatEvent from "@/components/modals/default-setting/contents/patEventSettingCard";
  // 観察記録
  import defObserveRecord from "@/components/modals/default-setting/contents/observeRecordSettingCard";
  // 指示受け・指示承認
  import defIndication from "@/components/modals/default-setting/contents/indicationSettingCard";
  // 処方一覧
  import defPatPrescriptionListSet from "@/components/modals/default-setting/contents/patPrescriptionListSettingCard";
  // 処方
  import defPatPrescriptionSet from "@/components/modals/default-setting/contents/patPrescriptionSettingCard";
  // 紹介状
  import defPatIntroLetterSet from "@/components/modals/default-setting/contents/patIntroLetterSettingCard";
  // 水質管理
  import defWaterQualitySurveySet from "@/components/modals/default-setting/contents/waterQualitySurveySettingCard";
  // 施設カレンダー
  import defFacilityCalendarSet from "@/components/modals/default-setting/contents/facilityCalendarSettingCard";
  // 顧客検索
  import defPatientSearchSet from "@/components/modals/default-setting/contents/patientSearchSettingCard";
  // 予実リスト
  import defIndicationResultSet from "@/components/modals/default-setting/contents/indicationResultSettingCard";
  // 患者情報共有
  import defPatInfoSharingSet from "@/components/modals/default-setting/contents/patInfoSharingCard";
  // #11987 2026.01.16 add スケールベッド TDC伊東 start
  import defScaleBedSet from "@/components/modals/default-setting/contents/scaleBedSettingCard";
  // #11987 2026.01.16 add スケールベッド TDC伊東 end
  //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
  import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
  //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
  // 定期点検
  import defPeriodicInspectionSet from "@/components/modals/default-setting/contents/periodicInspectionSettingCard";
  // 日常点検
  import defDailyCheckSet from "@/components/modals/default-setting/contents/dailyCheckSettingCard";
  import { EventBus } from "@/eventBus.js";
  // add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
  import { messageFormat } from '@/functions/common/MessageFormat';
  import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
  // add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
  import cloneDeep from "lodash/cloneDeep";
  import { PATIENT_SEARCH } from "@/constants/defaultSettingConstants";

export default {
  props: {
    showFooter: {
      type: Boolean,
      default: true
    }
  },
  components: {
    defPatViewerSet,
    defPatInfoSet,
    defMultiPatListSettingCard,
    defScheduleList,
    defStatusList,
    defStatusMap,
    defMeasureHistorySetting,
    defCheckList,
    defExamRecord,
    defBbsInfo,
    defExamRequest,
    defRadRequest,
    defPatCalendar,
    defPatEvent,
    defObserveRecord,
    defIndication,
    defPatPrescriptionListSet,
    defPatPrescriptionSet,
    defPatIntroLetterSet,
    defWaterQualitySurveySet,
    defFacilityCalendarSet,
    defPatientSearchSet,
    defIndicationResultSet,
    defPeriodicInspectionSet,
    defPatInfoSharingSet,
    defDailyCheckSet,
    defScaleBedSet
  },
  data() {
    return {
      contentsAreaHeight: 200,
      defaultSettingComponents: null,
      isAllComponentsInited: false, // add by shiyinwang 2022-10-20 [5687] 編集をしていなくても内容破棄確認モーダルが表示される
      // デフォルト設定表示オブジェクト
      defaultSettingObj: [
        {
          componentName: "defPatViewerSet",
          ref: "patViewerSet",
          funcCode: FUNC_PAT_VIEWER,
          dispOrder: null
        },
        {
          componentName: "defPatInfoSet",
          ref: "patInfoSet",
          funcCode: FUNC_PAT_INFO,
          dispOrder: null
        },
        {
          componentName: "defMultiPatListSettingCard",
          ref: "multiPatListSettingCard",
          funcCode: FUNC_MULTI_PAT_LIST,
          dispOrder: null
        },
        {
          componentName: "defScheduleList",
          ref: "scheduleListCard",
          funcCode: FUNC_SCHEDULE_LIST,
          dispOrder: null
        },
        {
          componentName: "defStatusList",
          ref: "statusListCard",
          funcCode: FUNC_STATUS_LIST_MAIN,
          dispOrder: null
        },
        {
          componentName: "defStatusMap",
          ref: "statusMapCard",
          funcCode: FUNC_STATUS_MAP,
          dispOrder: null
        },
        // #11987 2026.01.16 add スケールベッドカードを追加 TDC伊東 start
        {
          componentName: "defScaleBedSet",
          ref: "scaleBedSettingCard",
          funcCode: FUNC_SCALE_BED,
          dispOrder: null
        },
        // #11987 2026.01.16 add スケールベッドカードを追加 TDC伊東 end
        {
          componentName: "defMeasureHistorySetting",
          ref: "measureHistorySettingCard",
          funcCode: FUNC_MEASURE_HISTORY,
          dispOrder: null
        },
        {
          componentName: "defCheckList",
          ref: "checkListSet",
          funcCode: FUNC_CHECK_LIST,
          dispOrder: null
        },
        {
          componentName: "defExamRecord",
          ref: "examRecordSet",
          funcCode: FUNC_EXAM_RECORD,
          dispOrder: null
        },
        {
          componentName: "defBbsInfo",
          ref: "bbsInfoSet",
          funcCode: FUNC_BBS_INFO,
          dispOrder: null
        },
        {
          componentName: "defExamRequest",
          ref: "examRequestSet",
          funcCode: FUNC_EXAM_REQUEST,
          dispOrder: null
        },
        {
          componentName: "defRadRequest",
          ref: "radRequestSet",
          funcCode: FUNC_RAD_REQUEST,
          dispOrder: null
        },
        {
          componentName: "defPatCalendar",
          /*mod FNSI-改修内容redmain4300 范*/
          /*ref: "patEventSet",*/
          ref: "patCalendarSet",
          /*mod FNSI-改修内容redmain4300 范*/
          funcCode: FUNC_PAT_CALENDAR,
          dispOrder: null
        },
        {
          componentName: "defObserveRecord",
          ref: "observeRecordSet",
          funcCode: FUNC_OBSERVE_RECORD,
          dispOrder: null
        },
        {
          componentName: "defPatEvent",
          ref: "patEventSet",
          funcCode: FUNC_PAT_EVENT,
          dispOrder: null
        },
        {
          componentName: "defIndication",
          ref: "indicationSet",
          funcCode: FUNC_INDICATION,
          dispOrder: null
        },
        {
          componentName: "defPatPrescriptionListSet",
          ref: "patPrescriptionListSet",
          funcCode: FUNC_PRESCRIPTION,
          dispOrder: null
        },
        {
          componentName: "defPatPrescriptionSet",
          ref: "patPrescriptionSet",
          funcCode: FUNC_PRESCRIPTION,
          dispOrder: null
        },
        {
          componentName: "defPatIntroLetterSet",
          ref: "patIntroLetterSet",
          funcCode: FUNC_PAT_INTRO_LETTER,
          dispOrder: null
        },
        {
          componentName: "defWaterQualitySurveySet",
          ref: "waterQualitySurveySet",
          funcCode: FUNC_WATER_QUALITY_SURVEY,
          dispOrder: null
        },
        {
          componentName: "defFacilityCalendarSet",
          ref: "facilityCalendarSet",
          funcCode: FUNC_FACILITY_CALENDAR,
          dispOrder: null
        },
        {
          componentName: "defPatientSearchSet",
          ref: "patientSearchSet",
          funcCode: null,
          dispOrder: null
        },
        {
          componentName: "defIndicationResultSet",
          ref: "indicationResultSet",
          funcCode: null,
          dispOrder: null
        },
        {
          componentName: "defPeriodicInspectionSet",
          ref: "periodicInspectionSet",
          funcCode: FUNC_PERIODIC_INSPECTION,
          dispOrder: null
        },
        {
          componentName: "defDailyCheckSet",
          ref: "dailyCheckSet",
          funcCode: FUNC_DAILY_CHECK,
          dispOrder: null
        },
        {
          componentName: "defPatInfoSharingSet",
          ref: "patInfoSharingSet",
          funcCode: FUNC_SHARING_PATIENT_INFORMATION,
          dispOrder: null
        },
      ],
      tmpDefaultSettingObj: [],
      validatMessage: null
      //add FNSI-5687 劉全航 start
      ,componentSet: new Set(),
      changeNumber : 0
      //add FNSI-5687 劉全航 end
    };
  },
  computed: {
    ...mapGetters("account-edit", {
      getAuthorizedFunctions: "getAuthorizedFunctions",
      getDefaultSetting: "getDefaultSetting",
      fontSize: "getFontSize"
    }),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight"
    }),

    /**
     * コンテンツの高さをCSS変数を利用して書き換える.
     */
    heightStyles() {
      return { height: `${this.contentsAreaHeight}px` };
    },

    /**
     * ソート処理
     * sys_function.disp_orderの昇順、disp_orderがnullの場合は最下行とする.
     * funcCodeがnullの場合は全利用者に対して表示する。患者検索、予実リストは先頭に表示する。
     */
    sortedItems() {
      let list = this.tmpDefaultSettingObj.slice(); // ソート時でstate自体の順序を書き換えないため
      // 常に先頭に持ってくるオブジェクトを保持
      let patSearchobj = null;
      let indResultSetObj = null;
      list = list.filter(func => {
        if (func.ref == "patientSearchSet") {
          patSearchobj = func;
          return;
        }
        if (func.ref == "indicationResultSet") {
          indResultSetObj = func;
          return;
        }
        return this.chkFunc(func.funcCode) || func.funcCode == null;
      });
      list = list.sort(function(a, b) {
        let nullLast = 1;
        if (a.dispOrder !== b.dispOrder) {
          nullLast = a.dispOrder === null || b.dispOrder === null ? -1 : 1;
          if (a.dispOrder < b.dispOrder) {
            return -1 * nullLast;
          }
          if (a.dispOrder > b.dispOrder) {
            return 1 * nullLast;
          }
        }
        return 0;
      });
      if (indResultSetObj) {
        list.unshift(indResultSetObj);
      }
      if (patSearchobj) {
        list.unshift(patSearchobj);
      }
      return list;
    },

    /**
     * 初期表示時と比較して変更が入っているかどうか返す.
     */
    isChanged() {
      //mod FNSI-5687 劉全航 start
      // if (!this.defaultSettingComponents) {
         // 画面標示時等、データが存在しない場合
      //   return false;
      // }

      // let defaultSettingList = Object.keys(this.defaultSettingComponents);
      // for (const setting of defaultSettingList) {
      //   // 編集前データ
      //   const initData = this.defaultSettingComponents[setting][0].initialValue;
      //   // 編集後データ
      //   const editData = this.defaultSettingComponents[setting][0].editRecord;

      //   let isEdit = false;
      //   if (JSON.stringify(initData) !== JSON.stringify(editData)) {
      //     isEdit = true;
      //   }
        /* modify by shiyinwang 2022-10-20 [5687] 編集をしていなくても内容破棄確認モーダルが表示される --start */
        // if (isEdit) {
        // if (isEdit && this.isAllComponentsInited) {
          /* modify by shiyinwang 2022-10-20 [5687] 編集をしていなくても内容破棄確認モーダルが表示される --end */
          // 編集済み
        //   return true;
        // }
      // }
      /* add by shiyinwang 2022-10-20 [5687] 編集をしていなくても内容破棄確認モーダルが表示される --start */
      // this.isAllComponentsInited = true;
      /* add by shiyinwang 2022-10-20 [5687] 編集をしていなくても内容破棄確認モーダルが表示される --start */
      // return false;
      console.log('this.changeNumber', this.changeNumber)
      if(this.changeNumber  > 0){
        return true;
      }else{
        return false;
      }
      //mod FNSI-5687 劉全航 end
    }
  },

  methods: {
    ...mapActions("account-edit", ["getUserAccountInfo", "updateDefaultSetting"]),
    ...mapActions("loading-screen", [
      "setLoadingScreenVisible"
    ]),
    ...mapActions("multi-modal", ["hideModal"]),

    /**
     * 機能コードの有効/無効を確認.
     */
    chkFunc(code) {
      if (code == FUNC_PAT_INFO || code == FUNC_PAT_INFO_CREATE) {
        return (this.getAuthorizedFunctions.includes(FUNC_PAT_INFO) || this.getAuthorizedFunctions.includes(FUNC_PAT_INFO_CREATE));
      } else {
        return this.getAuthorizedFunctions.includes(code);
      }
    },

    /**
     * キャンセルボタンクリックイベント処理.
     */
    cancel() {
      if (!this.isChanged) {
        this.hideModal();
        return;
      }

      this.$ons.notification.confirm({
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
              // title: "内容破棄",
              title: DIALOG_MESSAGES[13000004].title,
              // message: "編集内容が破棄されます。</br>よろしいですか？",
              message: messageFormat(DIALOG_MESSAGES[13000004].message),
              // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        callback: async answer => {
          if (answer === 1) await this.hideModal();
        }
      });
    },

    /**
     * 保存ボタンクリックイベント処理.
     */
    save() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);

      // 変更チェック
      if (!this.isChanged) {
        // データが編集されていない場合、メッセージを表示して処理を終了
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "設定完了",
          // message: "何も編集されていません。"
          title: DIALOG_MESSAGES[20010010].title,
          message: messageFormat(DIALOG_MESSAGES[20010010].message)
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
        this.setLoadingScreenVisible(false);
        return;
      }

      // 設定内容取得
      const saveDataList = this.getDefaultSettingStr();
      if(!saveDataList){
        this.setLoadingScreenVisible(false);
        return;
      }

      // 設定内容をパラメータに格納
      const param = {
        defaultSettingStr: JSON.stringify(saveDataList)
      };
      // 利用者マスタに保存
      this.updateDefaultSetting(param)
        .then(() => {
          // 編集内容を画面に反映
          this.getUserAccountInfo();
          this.$ons.notification
            .alert({
              title: "設定完了",
              message: "設定が完了しました。"
            })
            .then(() => {
              // 描画速度改善の為、内部項目を非表示にしてからダイアログ非表示処理を実施
              this.$refs.defaultSettingList.style.display = "none";
              this.hideModal();
            });
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
          getErrorMessage('DefaultSettingComponent.vue', 'save', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
          if (error.response.status === 400) {
            this.$ons.notification
              .alert({
                title: "設定に失敗しました。",
                message: error.response.data.errorMessage
              })
              .then(() => this.hideModal());
          }
        })
        // 共通ローダー：表示終了
        .finally(() => this.setLoadingScreenVisible(false));
    },

    /**
     * 設定内容取得処理.
     */
    getDefaultSettingStr() {
      // 編集内容を、DBから取得した default_setting のデータに合算する
      let saveDataList = cloneDeep(this.getDefaultSetting);
      let defaultSettingList = Object.keys(this.defaultSettingComponents);
      for (const setting of defaultSettingList) {
        // 編集前データ
        const initData = this.defaultSettingComponents[setting][0].initialValue;
        // 編集後データ
        const editData = this.defaultSettingComponents[setting][0].editRecord;

        // バリデーションを実施
        if (setting === "scheduleListCard") {
          // スケジュール表の設定チェック
          if (editData.selectedKurIndexList.length === 0) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "設定中断",
              // message: "スケジュール表設定のクールは未設定にできません。"
              title: DIALOG_MESSAGES["00200112"].title,
              message: messageFormat(DIALOG_MESSAGES["00200112"].message)
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            });
            return null;
          }
        }

        if (JSON.stringify(initData) !== JSON.stringify(editData)) {
          // 編集データを追加
          const rtnData = this.defaultSettingComponents[setting][0].getSaveData();
          saveDataList[rtnData.name] = rtnData.data;
        }
      }

      // 患者検索からログイン時に追加されるクールを取り除く
      if(PATIENT_SEARCH.KEY_NAME in saveDataList){
        delete saveDataList[PATIENT_SEARCH.KEY_NAME][PATIENT_SEARCH.KEY_NAME_KUR_CD_LIST]
        // クールを除いた結果空になる場合はキーごと削除する
        if(Object.keys(saveDataList[PATIENT_SEARCH.KEY_NAME]).length === 0 ){
          delete saveDataList[PATIENT_SEARCH.KEY_NAME]
        }
      }
      return saveDataList;
    },

    /**
     * Gridの高さを調整する
     */
    calculateGridHeight() {
      const contentsHeight = document.getElementsByClassName(
        "tab-contents-area"
      )[0].clientHeight;
      const footerHeight = this.showFooter ? document.getElementsByClassName(
        "common-tab-footer"
      )[0].clientHeight : 0;
      this.contentsAreaHeight = contentsHeight - footerHeight - 10;
    }
  },
  watch: {
    /**
     * ウィンドウサイズが変更された時の処理.
     */
    windowHeight() {
      this.calculateGridHeight();
    },
    /**
     * 文字サイズが変更された時の処理.
     */
    fontSize() {
      this.calculateGridHeight();
    },
    /**
     * sort処理前の表示データが読み込まれた時の処理.
     */
    tmpDefaultSettingObj() {
      this.$nextTick(() => {
        // デフォルト設定コンポーネントのrefをまとめて取得
        this.defaultSettingComponents = _.omit(this.$refs, "defaultSettingList");
      });
    }

  },
  async created() {
    // sys_function.disp_order を取得
    let sysFunctionList = await sendRequestGetDefaultSettingDispOrder();
    sysFunctionList = sysFunctionList.data;
    this.defaultSettingObj.forEach(obj => {
      let tmpObj = sysFunctionList.filter(func => {
        return Number(obj.funcCode) === Number(func.functionCd);
      });
      tmpObj = tmpObj.length !== 0 ? tmpObj[0] : [];
      obj.dispOrder = tmpObj.dispOrder ? Number(tmpObj.dispOrder) : null;
    });
    // #11987 2026.01.15 mod スケールベッドを除外してセット TDC伊東 start
    // this.tmpDefaultSettingObj = this.defaultSettingObj
    // useFunction配列を取得
    const useFunction = this.$store.state.facility.useFunction || [];
    // スケールベッド機能が有効か判定
    if(useFunction.includes(FUNC_SCALE_BED)){
      // スケールベッド機能が有効な場合のみセット
      this.tmpDefaultSettingObj = this.defaultSettingObj;
    }
    else{
      // スケールベッド機能が無効なので、スケールベッドカードを除く
      this.tmpDefaultSettingObj = this.defaultSettingObj.filter(obj => obj.funcCode !== FUNC_SCALE_BED);
    }
    // #11987 2026.01.15 mod スケールベッドを除外してセット TDC伊東 end
  },
  async mounted() {
    this.$nextTick(() => {
      this.calculateGridHeight();
    });
    //add FNSI-5687 劉全航 start
    EventBus.$on("isChanged", (obj)=> {
      if(obj.value){
        if(!this.componentSet.has(obj.componentName)){
          this.changeNumber += 1;
          this.componentSet.add(obj.componentName);
        }
      }else{
        if(this.componentSet.has(obj.componentName)){
          this.changeNumber -= 1;
          this.componentSet.delete(obj.componentName);
        }
      }
    });
    //add FNSI-5687 劉全航 end
  }
  //add FNSI-5687 劉全航 start
  ,async beforeDestroy() {
    EventBus.$off("isChanged", {});
  }
  //add FNSI-5687 劉全航 end
};
</script>

 <style scoped>
 @media print {
  .common-tab-area, .common-tab-content {
    height: auto !important;
  }
}
.common-tab-area {
  margin: 5px;
}
@media screen and (max-width: 480px) {
  .common-tab-area {
    font-size: 1.1em; /* ベースのサイズ確認要 */
  }
}
.common-tab-content {
  border-bottom: none;
  overflow-y: auto;
}
.common-tab-footer {
  margin: 5px;
}
.right {
  text-align: right;
}
.common-tab-content >>> ons-row {
  height: auto;
}
.common-tab-content >>> .tab-item {
  margin-bottom: 5px;
}

::v-deep .record-accordion {
  background-color: var(--body-background-color);
  background-image: none;
  font-size: inherit;
  font-family: inherit;
}
::v-deep .record-accordion .card-header {
  border: 1px solid;
}
::v-deep .record-accordion .card-contents {
  border: 1px solid #dddddd;
  border-top-style: hidden;
  background-color: var(--ntss-base-background-color);
}
::v-deep .record-accordion .card-contents table th {
  background-image: none !important;
}
::v-deep .record-accordion .list-item {
  padding: 0;
  margin-bottom: 2px;
}
::v-deep .record-accordion div.list-item__top {
  padding: 0;
}
::v-deep .record-accordion div.list-item__center {
  padding: 0 0 0 0.5em;
  min-height: unset;
  height: calc(2em + 2px); /* box-sizing:border-box;なので、高さにborder上下2px加算する */
}
::v-deep .record-accordion div.list-item__right {
  display: none;
}
::v-deep .record-accordion div.list-item__expandable-content {
  padding: 0.3em 0.5em;
  overflow-x: auto;
}
</style>
