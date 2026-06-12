<template>
  <div class="pat-calendar" :class="classPatCalendar">
    <div class="dropdownlistWrap">
        <kendo-dropdownlist
        class="variable_width"
        ref="dropdown"
        :data-source="layoutMst"
        data-text-field="layoutName"
        data-value-field="layoutCd"
        filter="contains"
        @select="selectLayout"
        v-model="initSelected"
      />
    </div>
    <!-- add #8091 2023/03/14 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 start -->
    <span class="expand" :style="{left:expandStyle.left + 'px', top:expandStyle.top + 'px'}">
      <v-ons-checkbox :class="classPatCalendar" input-id="expand" v-model="expandFlg" @click="handleChangeExpand" />
      <label :class="classPatCalendar" for="expand">展開する</label>
    </span>
    <!-- add #8091 2023/03/14 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 end -->
    <ContentsCalendar
        ref="patCalendarRef"
        class="for-calendar"
        :class="classPatCalendar"
        :contents="calendarContents"
        v-model:base-date="currentDate"
        :center-week-mode="true"
        :pat-id="patId"
        :expandFlg="expandFlg"
        :expandStyle="expandStyle"
        :loaded-date-range="loadedDateRange"
        @content-clicked="moveToLink"
        @backChangeExpandStyle = "backChangeExpandStyle"
        @date-today-changed="handleDateTodayChanged"
    />
  </div>
</template>

<script>
import dayjs from "@/compat/date/dayjs";
// add #9562 患者カレンダーの表示が遅い 20240502 ztc start
import { mapGetters, mapActions } from "@/compat/vue/vuex";
// add #9562 患者カレンダーの表示が遅い 20240502 ztc end
import ContentsCalendar from "@/components/common/contents-calendar/ContentsCalendar.vue";
import { LAYOUT_CATEGORY_TREATINFO, LAYOUT_CATEGORY_VITALMONITORFLG_1, ROUTERLINK_BBSINFO, ROUTERLINK_EXAMRECORD_DETAIL, ROUTERLINK_EXAMREQUESTRECORD_DETAIL, ROUTERLINK_FACILITY_CALENDAR, ROUTERLINK_PATVIEWER, ROUTERLINK_PRESCRIPTIONRECORD_DETAIL, ROUTERLINK_RADEQUESTRECORD_DETAIL, ROUTERLINK_TREATMENTRECORD, VITAL_MONITOR_KEYS } from "./Definitions.js";
//add FNSI-add refresh 江 start
import { EventBus } from "@/compat/vue/event-bus.js";
//add FNSI-add refresh 江 end
import {
  createCalendarContents,
  getRequiredMst,
  getPatEventFor3Months,
  createEventDataCollectionNew,
  flatLayoutInfo,
  convertVitalInfoForPatCalendar
} from "./Functions.js";
import {PAT_CALENDAR} from "@/constants/defaultSettingConstants";
import { FUNC_PAT_EVENT } from "@/constants/function-code.js";
// add 画面印刷プレビューと印刷の実現 黄 start
import { getCurrentFunctionCd } from "@/router/routing-helper";
// add 画面印刷プレビューと印刷の実現 黄 end

//FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuxl add end

import { ApiHelper } from "@/apis/AxiosHelper";
// add #9562 患者カレンダーの表示が遅い 20240502 ztc start
import {
  getMstInfo,
  getMstOtherInfo
} from "@/apis/mst-info";
// add #9562 患者カレンダーの表示が遅い 20240502 ztc end
import PrintMixin from "@/components/PrintMixin";
export default {
  components: {
    ContentsCalendar
  },
  mixins: [PrintMixin],
  data() {
    return {
      calendarContents: [],
      mstList: null,
      selectedLayout: null,
      currentDate: null,
      // 日付IF、今日ボタン押下で表示年月日が変更されたかの判定に使用
      currentDateChangeSource: null,
      // データ読込期間 例：{ start: "20260101", end: "20260331" }
      loadedDateRange: {
        start: null,
        end: null
      },
      indInfoRaw: null,
      // add FNSI5415-カレンダー内のセルの表示に時間がかかる 周 start
      patMainHisInfoRaw: null,
      // add FNSI5415-カレンダー内のセルの表示に時間がかかる 周 end
      //add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 start
      examInfoRaw: null,
      indicationInfoRaw: null,
      examRequestInfoRaw: null,
      prescriptionInfoRaw: null,
      patEventInfoRaw: null,
      bbsInfoRaw: null,
      patMainList: [],
      //add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 end
      layoutMst: [],
      isLoading: false,
      initSelected: null,
      selfScreenName: "",
      // add #8091 2023/03/14 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 start
      expandFlg: false,
      expandStyle: {
        left: 210,
        top: 4
      },
      // add #8091 2023/03/14 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 end
      // add 9941 患者カレンダーで内容保持がされていない。 関 start
      defaultLayout: null,
      defaultExpandFlg: false,
      // add 9941 患者カレンダーで内容保持がされていない。 関 end
      // add #11347 【たくしん会】患者カレンダーで患者切替をしても前の患者の情報が表示し続ける linjunfeng start
      isChangePatIdOrLayout: false,
      // add #11347 【たくしん会】患者カレンダーで患者切替をしても前の患者の情報が表示し続ける linjunfeng end
      printTargetClass: ["calendar-body"],
      otherMST: {},
      isGetMstRequest: false
    };
  },

  computed: {
    ...mapGetters("app", ["getRefresh"]),
    // ADD BUG 6330 修正 高 start
    ...mapGetters("pat-viewer", [
      "getDateList",
      "getDialysisStateArray",
      "getDispLayoutItemListData",
      "getTreatmentData",
      "getTreatBaseDate",
      "getSelectedCondition",
      "getMstMedicineMixData",
      "getPatTabooAllergy"
    ]),
    //施設コード取得用
    ...mapGetters("user", ["getFacilityCd"]),
    // ADD BUG 6330 修正 高 end
    ...mapGetters("pat-info", {
      patId: "selectedPatId",
      patInfoRaw: "selectedPatIncludeDel",
      getIsOtherFacility: "getIsOtherFacility",
      getOtherFacilityCd: "getOtherFacilityCd"
    }),
    ...mapGetters("pat-info", ["selectedPatId"]),
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("account-edit", {
      // mod 9941 患者カレンダーで内容保持がされていない。 関 start
      // defaultSetting: "getDefaultSetting" ,
      getDefaultSetting: "getDefaultSetting" ,
      // mod 9941 患者カレンダーで内容保持がされていない。 関 end
      getAuthorizedFunctions: "getAuthorizedFunctions",
      // mod 9941 患者カレンダーで内容保持がされていない。 関 start
      // getSelectedLayout: "getSelectedLayout"}),
      getPatientShareMode: "getPatientShareMode",
      getPatientShareFacilityCdMode: "getPatientShareFacilityCdMode"
    }),
    // mod 9941 患者カレンダーで内容保持がされていない。 関 end
    // add 9941 患者カレンダーで内容保持がされていない。 関 start
    ...mapGetters("pat-calendar", {getExpandFlg: "getExpandFlg"}),
    // add 9941 患者カレンダーで内容保持がされていない。 関 end
    // add 9941 患者カレンダーで内容保持がされていない。 関 start
    ...mapGetters("pat-calendar", {getSelectedLayout: "getSelectedLayout"}),
    // add 9941 患者カレンダーで内容保持がされていない。 関 end
    ...mapGetters("window-size", {
      sidebarWidth: "getSidebarWidth"
    }),
    // ADD BUG 6330 修正 高 start
    facilityCd() {
      return this.getFacilityCd;
    },
    // ADD BUG 6330 修正 高 end
    // 画面幅が狭まった際の折り返し判定用class
    classPatCalendar() {
      if (this.sidebarWidth === 0) {
        if (this.patId && this.getAuthorizedFunctions.includes(FUNC_PAT_EVENT)) {
          return "close-btn-class checkbox"
        } else {
          return "close-class checkbox"
        }
      } else {
        if (this.patId && this.getAuthorizedFunctions.includes(FUNC_PAT_EVENT)) {
          return "open-btn-class checkbox"
        } else {
          return "open-class checkbox"
        }
      }
    }
  },

  watch: {
    async patId(newValue) {
      // 選択患者変更時イベント再作成
      
      // ヘッダで患者情報表示→保存時に選択済患者IDがクリア→再設定されるので、選択済患者IDがnullの場合は処理しない
      if (newValue === null) return;  
      
      await this.getMstOther();
      // add bug 8091 修正 chen start
      await this.getMstByPat();
      // add bug 8091 修正 chen end
      // #11347 【たくしん会】患者カレンダーで患者切替をしても前の患者の情報が表示し続ける linjunfeng start
      // await this.createCalendarContents(this.baseDate.isSame(this.currentDate, "month"));
      await this.createCalendarContents();
      // #11347 【たくしん会】患者カレンダーで患者切替をしても前の患者の情報が表示し続ける linjunfeng end
    },
    async currentDate(newDate, oldDate) {
      
      if (null !== oldDate && !newDate.isSame(oldDate, "month")) {

        if (this.currentDateChangeSource === "input") {
          // 日付IF、今日ボタン押下で表示年月日が変更された場合はデータ再読込み
          await this.createCalendarContents();
          
        } else if (!this.isChangePatIdOrLayout) {
          // 患者切替、レイアウト変更、パンくずリスト押下以外は、追加読込
          await this.refreshCalendarContents(newDate > oldDate);
        }
        
      }
      
      // 使い終わったらクリア
      this.currentDateChangeSource = null;
    },
    // add FNSI-NO542再表示時に共通Loader画面を表示する。読み込みに時間がかかる場合がある。 関 start
    async initSelected() {
      if (this.initSelected != null && this.selectedLayout != null) {
        // #11347 【たくしん会】患者カレンダーで患者切替をしても前の患者の情報が表示し続ける linjunfeng start
        // await this.createCalendarContents(this.baseDate.isSame(this.currentDate, "month"));
        await this.createCalendarContents();
        // #11347 【たくしん会】患者カレンダーで患者切替をしても前の患者の情報が表示し続ける linjunfeng end
        // add FNSI-改修内容検索条件ログ対応。 関 start
        if (this.patId != null) {
          let layoutName = "";
          this.layoutMst.forEach(everyLayout => {
            if (everyLayout.layoutCd == parseInt(this.initSelected)) {
              layoutName = everyLayout.layoutName;
            }
          });
          let msg = "患者カレンダー[" + layoutName + "]で検索しました";
          let param = {'message': msg, 'functionName': '患者カレンダー'};
          ApiHelper.put("/logs/event/conditionlog", param)
              .catch(error => {
                //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
                getErrorMessage('PatCalendar.vue', 'initSelected', error);
                //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
              });
        }
        // add FNSI-改修内容検索条件ログ対応 関 end
      }
    },
    // add FNSI-NO542再表示時に共通Loader画面を表示する。読み込みに時間がかかる場合がある。 関 end
    async getPatientShareMode() {
      await this.createCalendarContents();
    },
    async getPatientShareFacilityCdMode() {
      await this.createCalendarContents();
    },
  },

  async created() {
    // 画面名称取得
    this.selfScreenName = this.$route.name;
    this.setLoadingScreenMessage("処理中...");
    this.setLoadingScreenVisible(true);
    // 表示年月日
    this.currentDate = dayjs();
    // 各種マスタ取得
    try {
      const [requiredMst, extraMst] = await Promise.all([
        getRequiredMst(this.facilityCd),
        this.getMst()
      ]);
    
      // 必須マスタ
      this.mstList = requiredMst;
      // その他のマスタをマージ
      Object.assign(this.mstList, extraMst);
    
    } catch (error) {
      getErrorMessage("PatCalendar.vue", "created", error);
      this.setLoadingScreenVisible(false);
      throw error;
    }

    // 患者カレンダーレイアウトマスタを設定
    this.layoutMst = this.mstList.layout.map(
        ({ patCalendarLayoutCd, patCalendarLayoutName, dispItemInfo, dispClass }) => ({
          layoutCd: patCalendarLayoutCd,
          layoutName: patCalendarLayoutName,
          layoutInfo: dispItemInfo ? JSON.parse(dispItemInfo) : [],
          dispClass: dispClass
        }));

    if (this.patId) {
      // 患者に紐づくマスタ情報取得
      await this.getMstByPat();
      await this.getMstOther();
    }

    // サインインユーザのデフォルト設定を確認・設定
    this.$nextTick(() => {
      const defaultPatCalendar = this.getDefaultSetting[PAT_CALENDAR.KEY_NAME];
      if (defaultPatCalendar) {
        // レイアウト
        if (defaultPatCalendar[PAT_CALENDAR.KEY_NAME_SELECTED_LAYOUT_CD] !== undefined) {
          this.defaultLayout = this.layoutMst.find(el => el.layoutCd === Number(defaultPatCalendar[PAT_CALENDAR.KEY_NAME_SELECTED_LAYOUT_CD]));
        }
        if (defaultPatCalendar[PAT_CALENDAR.KEY_NAME_EXPAND_FLG] !== undefined) {
          this.defaultExpandFlg = defaultPatCalendar[PAT_CALENDAR.KEY_NAME_EXPAND_FLG]
        }
      }

      if (this.getSelectedLayout != null) {
        this.initSelected = this.getSelectedLayout.layoutCd;
        /* modify by chamaojia 2023-11-13 [9624] データ・オブジェクトはクエリーの結果である必要があります  --start */
        // this.selectedLayout = this.getSelectedLayout;
        this.selectedLayout = this.layoutMst.find(el => el.layoutCd === this.getSelectedLayout.layoutCd);
        /* modify by chamaojia 2023-11-13 [9624] データ・オブジェクトはクエリーの結果である必要があります  --end */
      } else {
        if (this.defaultLayout != null) {
          this.initSelected = this.defaultLayout.layoutCd;
          this.selectedLayout = this.defaultLayout;
        } else {
          this.initSelected = this.layoutMst?.length > 0 ? this.layoutMst[0].layoutCd : null;
          this.selectedLayout = this.layoutMst?.length > 0 ? this.layoutMst[0] : null;
        }
      }
      if (this.getExpandFlg != null) {
        this.expandFlg = this.getExpandFlg;
      } else {
        this.expandFlg = this.defaultExpandFlg
      }
    });

    EventBus.$on("refresh", this.refreshData);
    // mod #9562 患者カレンダーの表示が遅い 20240502 ztc start
    // EventBus.$on("customRefreshPage", this.createCalendarContents());
    EventBus.$on("customRefreshPage", this.createCalendarContents);
    // mod #9562 患者カレンダーの表示が遅い 20240502 ztc end
    // add 画面印刷プレビューと印刷の実現 黄 start
    // 印刷パラメータ要求
    EventBus.$on("requestReportParams", this.requestrReportParams);
    // add 画面印刷プレビューと印刷の実現 黄 end
    this.setLoadingScreenVisible(false);
  },

  beforeUnmount() {
    if (this.getRefresh && this.getRefresh.status === true) {
      // add FNSI redmine 4257修正 鄧シン start
      this.setSelectedLayoutForSave({
        selectedLayout: null
      });
      this.expandFlg = null;
      // add FNSI redmine 4257修正 鄧シン end
    } else {
      // add FNSI redmine 4257修正 鄧シン start
      this.setSelectedLayoutForSave({
        selectedLayout: this.selectedLayout
      });
      // add FNSI redmine 4257修正 鄧シン end
      // add 9941 患者カレンダーで内容保持がされていない。 関 start
      this.setExpandFlg(this.expandFlg);
      // add 9941 患者カレンダーで内容保持がされていない。 関 end
    }
    // #9271 他の画面への切り替え時のパンくずクリックは有効になりません。 linjunfeng start
    // EventBus.$off("refresh");
    EventBus.$off("refresh", this.refreshData);
    // add #9562 患者カレンダーの表示が遅い 20240502 ztc start
    EventBus.$off("customRefreshPage", this.createCalendarContents);
    // add #9562 患者カレンダーの表示が遅い 20240502 ztc end
    // #9271 他の画面への切り替え時のパンくずクリックは有効になりません。 linjunfeng end
    // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 start
    // EventBus.$off("requestReportParams");
    EventBus.$off("requestReportParams", this.requestrReportParams);
    // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 end
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },

  methods: {
    // upd #9562 患者カレンダーの表示が遅い 20240502 ztc start
    ...mapActions("pat-viewer", [
      "setTreatBaseDate",
      "getOrdMain",
      "setDateList"
    ]),
    ...mapActions("pat-info", ["selectPat"]),
    // upd #9562 患者カレンダーの表示が遅い 20240502 ztc end
    ...mapActions("treatment-record/common", ["setOrdNo"]),
    ...mapActions("exam-request/list", {
      setExamSelectedPatId: "setSelectedPatId"
    }),
    ...mapActions("rad-request/list", {
      setRadSelectedPatId: "setSelectedPatId"
    }),    
    // mod 9941 患者カレンダーで内容保持がされていない。 関 start
    // ...mapActions("account-edit", ["setSelectedLayoutForSave"]),
    ...mapActions("pat-calendar", ["setSelectedLayoutForSave"]),
    // mod 9941 患者カレンダーで内容保持がされていない。 関 end
    // add 9941 患者カレンダーで内容保持がされていない。 関 start
    ...mapActions("pat-calendar", ["setExpandFlg"]),
    // add 9941 患者カレンダーで内容保持がされていない。 関 end
    ...mapActions("bbs-info", {
      setBbsSelectedCondition: "setSelectedCondition",
      setSelectedBbsInfo: "setSelectedBbsInfo",
      setIsOnlyUnread: "setIsOnlyUnread"
    }),
    
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage"
    }),
    
    /** 表示年月日を日付IF、今日ボタン押下で変更時の処理 */
    handleDateTodayChanged() {
      this.currentDateChangeSource = "input";
    },
    
    /**
     * マスタ情報（削除済み含む）を取得
     * - Function.js＞getRequiredMst() で取得するマスタ以外を取得する
     *   ・薬剤マスタ（削除済み含む）
     *   ・調整薬剤マスタ（削除済み含む）
     *   ・医療材料マスタ（削除済み含む）
     *   ・ダイアライザマスタ（削除済み含む）
     *   ・禁忌アレルギーマスタ（削除済み含む）
     */
    async getMst() {
      const reqMstNamesArr = [
        "mstMedicineIncludeDeleted",
        "mstMedicineMixIncludeDeleted",
        "mstEquipmentIncludeDeleted",
        "mstDialyzerIncludeDeleted",
        "mstTabooAllergyIncludeDeleted"
      ];

      const response = await getMstInfo({ reqMstNamesArr, selectedPatId: this.selectedPatId });
      if (response.status !== 200) return {};
    
      const data = response.data ?? {};
      const result = {};
      reqMstNamesArr.forEach(key => {
        result[key] = data[key];
      });
    
      return result;
    },
    async getMstOther() {
      if (this.isGetMstRequest === true) {
        return;
      }
      this.isGetMstRequest = true;
      const reqMstNamesArr = [
        "mstMedicineIncludeDeleted",
        "mstMedicineMixIncludeDeleted",
        "mstEquipmentIncludeDeleted",
        "mstDialyzerIncludeDeleted",
        "mstTabooAllergyIncludeDeleted"
      ];
      const response = await getMstOtherInfo(reqMstNamesArr, this.patId);
      this.isGetMstRequest = false;
      if (response.status !== 200) return {};

      const data = response.data ?? {};
      const result = {};
      reqMstNamesArr.forEach(key => {
        result[key] = data[key];
      });
      this.otherMST = result;
    },
    /**
     * 患者に紐づくマスタ情報を取得
     */
    async getMstByPat() {
      const { pat_main, pat_unique } = this.patInfoRaw;
      const { taboo_allergy_info } = pat_main;
      
      /** 患者の禁忌ｱﾚﾙｷﾞｰに一致するマスタデータを抽出してセット */
      const medicineSetData = this.mstList.mstTabooAllergyIncludeDeleted ?? [];
      // 患者の禁忌・アレルギー情報
      const tabooList = taboo_allergy_info ? JSON.parse(taboo_allergy_info) : [];
      // 結果格納用
      let result = [];
      
      if (tabooList.length > 0) {
        result = medicineSetData.flatMap(detail => {
          const matched = tabooList.filter(
            item => item.taboo_allergy_cd === detail.tabooAllergyCd
          );
          if (matched.length === 0) {
            return [];
          }
          
          // tabooAllergyClass ごとにレコード生成
          return matched.map(item => ({
            ...detail,
            tabooAllergyClass: item.taboo_allergy_class
          }));
        });
      }
      // 結果を mstList にセット
      this.mstList["mstTabooAllergy"] = result;
      
      /** 入外・転入出情報から医療機関コード抽出して全施設マスタを取得 */
      try {        
        // ※全施設マスタは件数多いので医療機関コードで絞り込む必要あり
        const { in_out_visit_history_info } = pat_unique;
        const inOutInfo = in_out_visit_history_info ? JSON.parse(in_out_visit_history_info) : [];
        // 医療機関コード抽出
        const medicalInstitutionCds = inOutInfo
          .filter(info =>
            !["4", "5", "6"].includes(info.move_in_out) && // 入院・退院・外来以外
            info.facility_is_free === "0" &&               // フリー入力以外
            (info.to_facility || info.from_facility)
          )
          .map(info => info.to_facility ?? info.from_facility);  
        // 全施設マスタ取得（空なら呼ばない）
        const sysFacilityRes =
          medicalInstitutionCds.length > 0
            ? await ApiHelper.post(
                "/sysFacility/getSysFacilityByCdList",
                medicalInstitutionCds
              )
            : { data: [] };
    
        this.mstList["sysfacility"] = sysFacilityRes.data;
    
      } catch (err) {
        getErrorMessage("PatCalendar.vue", "getMstByPat", err);
      }
    },
    /**
     * 基準日を元に表示開始日・終了日を設定
     */
    async setStartEndDay(startdate, enddate) {
      // 一覧ヘッダーの日付リストの設定
      await this.setDateList({
        // mod #8091 グラフは過去未来日は表示しません。 林峻峰 start
        // startDay: this.startDay,
        // endDay: this.endDay,
        // period: this.selectedPeriod
        startDay: startdate,
        endDay: enddate,
        period: "1"
        // mod #8091 グラフは過去未来日は表示しません。 林峻峰 end
      });
    },
    //add FNSI-add refresh 江 start
    async refreshData() {
      if (this.selfScreenName !== this.$route.name) {
        return;
      }
      // 共通ローダー:表示開始
      this.setLoadingScreenMessage("処理中...");
      this.setLoadingScreenVisible(true);
      // 選択患者変更時イベント再作成
      this.calendarContents = [];
      // #11347 【たくしん会】患者カレンダーで患者切替をしても前の患者の情報が表示し続ける linjunfeng start
      // await this.refreshCalendarContents();
      await this.createCalendarContents();
      // #11347 【たくしん会】患者カレンダーで患者切替をしても前の患者の情報が表示し続ける linjunfeng end
      // 共通ローダー:表示終了
      this.setLoadingScreenVisible(false);
    },
    // add FNSI-add refresh 江 end

    // add 画面印刷プレビューと印刷の実現 黄 start
    requestrReportParams(param) {
      // 機能コード判定
      if (param.substring(0, 3) === getCurrentFunctionCd().substring(0, 3)) {
        // 機能一致

        // 印刷パラメータを応答
        const param = {
          facilityCd: this.getFacilityCd,
          patId: this.patId,
          //add 5984 機能帳票でパラメータが正しく渡されていない 吉 start
          functionCd:"02401",
          //add 5984 機能帳票でパラメータが正しく渡されていない 吉 end
          //mod #9558 機能帳票でパラメータが正しく渡されていない 房 start
          date: dayjs(this.currentDate).format("YYYY/MM/DD"),
          fromDate: dayjs(this.currentDate).format("YYYY/MM/DD"),
          toDate: dayjs(this.currentDate).add(1, "months").format("YYYY/MM/DD"),
          //mod #9558 機能帳票でパラメータが正しく渡されていない 房 end
          // add #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
          //dialysisDate: dayjs(this.currentDate).format("YYYYMMDD"),
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
          // add #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
        };
        EventBus.$emit("sendReportParams", param);
      }
    },
    // add 画面印刷プレビューと印刷の実現 黄 end

    // mod FNSI5415-カレンダー内のセルの表示に時間がかかる 周 start
    //selectLayout(e) {
    async selectLayout(e) {
      // mod FNSI5415-カレンダー内のセルの表示に時間がかかる 周 end
      this.selectedLayout = this.layoutMst.find(
          el => el.layoutCd === e.dataItem.layoutCd
      );
    },

    //add FNSi6423患者カレンダーのスクロールによる読み込み不正 周 start
    /**
     * @description カレンダー内容更新 データ追加読込
     */
    async refreshCalendarContents(direction) {
      this.setLoadingScreenVisible(true);

      if (!this.patId) {
        this.setLoadingScreenVisible(false);
        return;
      }

      // カレンダー表示内容生成
      await this.loadCalendarContents(direction);
                  
      this.setLoadingScreenVisible(false);
    },
    //add FNSi6423患者カレンダーのスクロールによる読み込み不正 周 end
    /**
     * @description カレンダー内容作成 データ再読込
     */
    async createCalendarContents() {
      
      // カレンダー表示内容再作成
      this.calendarContents = [];
      
      this.setLoadingScreenVisible(true);
      try {
        if (!this.patId) {
          return;
        }
        const patientShareMode = (this.getIsOtherFacility === false ||
          (this.getOtherFacilityCd !== null &&
            this.getOtherFacilityCd !== this.getFacilityCd)) ? 1 :
          this.getPatientShareMode;
        this.selectPat({
          selectedPatId: this.patId,
          selectedFacility: (patientShareMode == 1 ||
            (this.getOtherFacilityCd !== null &&
              this.getOtherFacilityCd !== this.getFacilityCd))
            ? this.getFacilityCd
            : null
        });
        // add #11347 【たくしん会】患者カレンダーで患者切替をしても前の患者の情報が表示し続ける linjunfeng start
        if (this.$refs?.patCalendarRef?.dateToday) {
          this.isChangePatIdOrLayout = true;
          this.currentDate = dayjs(this.$refs.patCalendarRef.dateToday);
        }
        // add #11347 【たくしん会】患者カレンダーで患者切替をしても前の患者の情報が表示し続ける linjunfeng end
        
        // カレンダー表示内容生成
        await this.loadCalendarContents();
        
        // #11347 【たくしん会】患者カレンダーで患者切替をしても前の患者の情報が表示し続ける linjunfeng start
        // this.$nextTick(()=>{
        //   this.$refs.patCalendarRef.moveCurrentMonthForDate();
        // })
        requestAnimationFrame(() => {
          if (this.$refs?.patCalendarRef?.requestMoveCurrentMonthForDate) {
            this.$refs.patCalendarRef.requestMoveCurrentMonthForDate();
          }
          this.isChangePatIdOrLayout = false;
        });
        // #11347 【たくしん会】患者カレンダーで患者切替をしても前の患者の情報が表示し続ける linjunfeng end
      } catch (err) {
        getErrorMessage('PatCalendar.vue', 'createCalendarContents', err);
      } finally {
        //add 5792患者カレンダ画面で患者を切り替えたときの動作がおかしい 張 statr
        this.setLoadingScreenVisible(false);
        //add 5792患者カレンダ画面で患者を切り替えたときの動作がおかしい 張 end
      }
    },
    
    /** カレンダー表示内容生成 */
    async loadCalendarContents(direction) {
      var startdate = dayjs(this.currentDate).subtract(1, "months").startOf("month").format("YYYYMMDD");
      var enddate = dayjs(this.currentDate).add(1, "months").endOf("month").format("YYYYMMDD");
      // バイタル・モニタグラフの表示期間をセット
      await this.setStartEndDay(startdate, enddate);
      
      // マスタレイアウトを階層構造からフラット化
      const { layoutInfo = [] } = this.selectedLayout ?? {};
      const flatLayout = flatLayoutInfo(layoutInfo);
      // layoutInfo だけ差し替えた selectedLayout を作成
      const selectedLayoutWithFlat = {
        ...this.selectedLayout,
        layoutInfo: flatLayout
      };
      
      // バイタル・モニタ用データ
      const vitalInfoDataList = [];
      // バイタル対象カテゴリをまとめて抽出
      const vitalCategories = [];
      for (const layout of flatLayout) {
        if (layout.dataKey !== LAYOUT_CATEGORY_TREATINFO.key) {
          continue;
        }
        for (const category of layout.categoryItem || []) {
          if (!VITAL_MONITOR_KEYS.includes(category.dataKey)) {
            continue;
          }
          vitalCategories.push({
            dataKey: category.dataKey,
            items: category.items
          });
        }
      }
      const hasVitalMonitor = vitalCategories.length > 0;
      
      try {
        
        // API並列実行 ※getOrdMainはバイタル・モニタのレイアウトが在るときのみ実行
        const ordMainPromise = hasVitalMonitor
          ? this.getOrdMain({ // バイタル・モニタグラフデータ取得
              facilityCd: this.facilityCd,
              patId: this.patId,
              startDay: startdate,
              endDay: enddate,
              weekPattern: `[{ 'text': '全', 'done': true, 'value': 0 }]`
            })
          : Promise.resolve(null);
        const patientShareMode = (this.getIsOtherFacility === false ||
          (this.getOtherFacilityCd !== null && this.getOtherFacilityCd !== this.getFacilityCd)) ? 1 :
          this.getPatientShareMode;
        const [result3Months, resultOrdMain] = await Promise.all([
          getPatEventFor3Months(this.patId, this.facilityCd, this.currentDate, patientShareMode),
          ordMainPromise
        ]);
        
        // 3ヶ月分イベントセット
        this.indInfoRaw = result3Months.indInfoList;
        this.examInfoRaw = result3Months.examResultInfoList;
        this.examRequestInfoRaw = result3Months.examRequestInfoList;
        this.indicationInfoRaw = result3Months.indicationInfoList;
        this.prescriptionInfoRaw = result3Months.prescriptionInfoList;
        this.patEventInfoRaw = result3Months.patEventCountInfoList;
        this.patMainHisInfoRaw = result3Months.patMainHistoryList;
        this.bbsInfoRaw = result3Months.bbsInfoList;
        this.patMainList = result3Months.patMainList;
        
        // バイタル・モニタグラフの表示データをリストに格納
        for (const category of vitalCategories) {
          const list = convertVitalInfoForPatCalendar(
            category.items,
            category.dataKey,
            resultOrdMain?.treatmentData ?? [],
            resultOrdMain?.resMniMonitors ?? []
          );
          vitalInfoDataList.push(...list);
        }
        
      } catch (err) {
        getErrorMessage('PatCalendar.vue', 'createCalendarContents', err);
        this.setLoadingScreenVisible(false);
        return;
      }
    
      const eventDataCollection = createEventDataCollectionNew(
        { patInfo: this.patInfoRaw,
          indInfo: this.indInfoRaw ,
          examInfo: this.examInfoRaw,
          examRequestInfo: this.examRequestInfoRaw,
          indicationInfo: this.indicationInfoRaw,
          prescriptionInfo: this.prescriptionInfoRaw,
          patEventInfo: this.patEventInfoRaw,
          patMainHisInfo: this.patMainHisInfoRaw,
          bbsInfo: this.bbsInfoRaw,
          patMainList: this.patMainList},
        this.currentDate
      );       
      // バイタル・モニタ用データをセット
      eventDataCollection[LAYOUT_CATEGORY_VITALMONITORFLG_1.key] = vitalInfoDataList;
      const otherMstMedicineMixData = this.getMstMedicineMixData;
      const getOtherPatTabooAllergy = this.getPatTabooAllergy;
      this.mstList["getOthetMstMixData"] = otherMstMedicineMixData ? otherMstMedicineMixData : [];
      this.mstList["getOtherPatTabooAllergy"] = getOtherPatTabooAllergy ? getOtherPatTabooAllergy : [];
      this.mstList["otherMST"] = this.otherMST;
    
      // カレンダー表示内容生成
      let tmpCalendarContents = createCalendarContents(
        selectedLayoutWithFlat,
        eventDataCollection,
        this.mstList
      );
      
      // ContentsCalendar.vueでスクロールの追加読込で読み込めている範囲の新古末端月の15日のみ発火対象にする処理があるため、
      // 患者情報はstartdate ～ enddate の範囲外も存在するのでstartdate ～ enddate の範囲に絞る
      tmpCalendarContents = tmpCalendarContents.filter(
        v => v.date >= startdate && v.date <= enddate
      );

      // スクロール時の追加読込に対応
      if (direction === true) {
      	// 下方向スクロール 追加読込
      	// データ読込期間.終了日を更新
        if (this.loadedDateRange.end < enddate) {
          this.loadedDateRange.end = enddate;
        }
        // 同日付データの重複排除して後ろに追加
        const existDates = new Set(this.calendarContents.map(v => v.date));
        this.calendarContents = this.calendarContents.concat(
          tmpCalendarContents.filter(v => !existDates.has(v.date))
        );
      } else if (direction === false) {
      	// 上方向スクロール 追加読込
      	// データ読込期間.開始日を更新
        if (this.loadedDateRange.start > startdate) {
          this.loadedDateRange.start = startdate;
        }
        // 同日付データの重複排除して前に追加
        const existDates = new Set(this.calendarContents.map(v => v.date));
        this.calendarContents = tmpCalendarContents
          .filter(v => !existDates.has(v.date))
          .concat(this.calendarContents);
      } else {
      	// createCalendarContentsから呼ばれた場合 データ再読込
        // データ読込期間.開始日/終了日を更新
        this.loadedDateRange = {
          start: startdate,
          end: enddate
        };
        this.calendarContents = tmpCalendarContents;
      }
    },

    /**
     * @description ページ遷移
     */
    moveToLink({ item, date, createNew = false, fCd }) {
      const { routerLink, ordNo, categoryCd, subCategoryCd, startDate, endDate, bbsCtlNo } = item;
      
      if (routerLink === ROUTERLINK_EXAMRECORD_DETAIL){
        // 検査結果画面へ遷移
        this.$router.push({ name: "exam-record" });
        this.$router.push({ name: "exam-record-detail" });
      }
      else if (routerLink === ROUTERLINK_RADEQUESTRECORD_DETAIL){
        // 一般撮影検査予定へ遷移
        this.setRadSelectedPatId(this.patId);
        this.$router.push({ name: "rad-request" });
        this.$router.push({ name: "rad-request-detail" });
      }
      else if (routerLink === ROUTERLINK_EXAMREQUESTRECORD_DETAIL){
        // 検査予定へ遷移
        this.setExamSelectedPatId(this.patId);
        this.$router.push({ name: "exam-request" });
        this.$router.push({ name: "exam-request-detail" });
      }
      // add #10371 編集権限について、対応する。 dengshen start
      else if (routerLink === ROUTERLINK_PRESCRIPTIONRECORD_DETAIL){
        // 処方へ遷移
        this.$router.push({ name: "prescription" });
        this.$router.push({ name: "pat-prescription" });
      }
      // mod #10371 編集権限について、対応する。 dengshen end
      else if (routerLink === ROUTERLINK_TREATMENTRECORD){
        // 治療記録へ遷移
        this.setOrdNo(ordNo);
        this.$router.push({ name: "treatment-record" });
      }
      else if (routerLink === ROUTERLINK_BBSINFO){
        // 掲示板＞施設イベント詳細へ遷移
        const searchCondition = {
          limitFrom: 0,
          limitTo: 100,
          categoryFuncList: [],
          // カテゴリ種類
          categoryKindList: [],
          // フリーワード
          freeWord: "",
          // 掲載開始日
          noticeStartDate: dayjs(startDate).format("YYYY-MM-DD"),
          // 掲載終了日
          noticeEndDate: endDate ? dayjs(endDate).format("YYYY-MM-DD") : null,
          // 治療日
          dialysisDate: null,
          // クール
          kur: null,
          // ベッドグループ ・透析室
          roomBedGroup: { bedGroupCd: null, bedCdList: [] }
        };
        this.setBbsSelectedCondition(searchCondition);
        this.setIsOnlyUnread(false);
        this.setSelectedBbsInfo({
          bbsCtlNo,
          selectedPatId: this.selectedPatId
        }).then(() => {
          this.$router.push({ name: "bbs-info" });
          this.$router.push({ name: "facility-calendar-detail" });
        });
      }
      else if (routerLink === ROUTERLINK_FACILITY_CALENDAR){
        const model = {
          currentDate: dayjs(date).format("YYYY-MM-DD")
        }
        // 施設カレンダー＞施設イベント詳細へ遷移
        this.setSelectedBbsInfo({
          bbsCtlNo,
          selectedPatId: this.selectedPatId
        }).then(() => {
          this.$router.push({ name: "facility-calendar", params: { condition: model }});
          this.$router.push({ name: "facility-calendar-detail" });
        });
      }else{
        if (routerLink === ROUTERLINK_PATVIEWER) {
          this.setTreatBaseDate(date.format("YYYY-MM-DD")).then(() =>{
            this.$nextTick(() => {
              //患者経過総合ビューアへ遷移
              this.$router.push({ name: "pat-viewer", params: { fCd } });
            })
          })
        }
        else{
          if (createNew) {
            // 患者イベント画面に遷移(新規作成)
            const model = {
              treatDate: dayjs(date).format('YYYY/MM/DD'),
              eventStartDate: dayjs(date).format('YYYY-MM-DD'),
              eventEndDate: dayjs(date).format('YYYY-MM-DD'),
              createNew: createNew
            }
            this.$router.push({ name: routerLink , params: { condition: model }});
          } else {
            // 患者イベントが２件に分かれて患者カレンダーに表示される  5791  shan  start
            const model = {
              treatDate: dayjs(date).format('YYYY/MM/DD'),
              eventStartDate: dayjs(date).format('YYYY-MM-DD'),
              eventEndDate: dayjs(date).format('YYYY-MM-DD'),
              categoryCd: categoryCd ? categoryCd + "" : null,
              subCategoryCd: subCategoryCd ? subCategoryCd + "" : null,
              subCategoryName:"",
              categoryName:"",
              //add 5575患者イベントを選択して画面遷移をした際のイベントリストの表示不正 start
              type:"pat_event",
              isRouteCreateFlg:"1",
              //add 5575患者イベントを選択して画面遷移をした際のイベントリストの表示不正 end
              // #10228 患者カレンダー ＞日付文字列押下(強制画面移動で患者イベントの新規登録状態に遷移) linjunfeng start
              patCalendarFlg: 1,
              // #10228 患者カレンダー ＞日付文字列押下(強制画面移動で患者イベントの新規登録状態に遷移) linjunfeng end
            }
            this.$router.push({ name: routerLink , params: { condition: model, fCd, type: "pat-info" }});
          }
          // 患者イベントが２件に分かれて患者カレンダーに表示される  5791  shan  end
        }
      }
    },
    // add #8091 2023/03/14 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 start
    handleChangeExpand(){
      const expandCheckbox = this.$refs?.expandArea?.querySelector?.('#expand');
      if (expandCheckbox) {
        this.expandFlg = expandCheckbox.checked;
      }
    },
    backChangeExpandStyle(expandStyle) {
      this.expandStyle = expandStyle
    }
    // add #8091 2023/03/14 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 end
  }
};
</script>

<style scoped>
.pat-calendar :deep(.k-dropdown-wrap) {
  background-color: var(--main-background-color) !important;
  color: var(--ntss-list-body-color) !important;
  height: 1.7em;
}

.pat-calendar :deep(.k-picker),
.pat-calendar :deep(.k-input-inner) {
  background-color: var(--main-background-color) !important;
  color: var(--ntss-list-body-color) !important;
  height: 1.7em;
}
.pat-calendar :deep(.k-input-value-text) {
  color: var(--ntss-list-body-color) !important;
}

.dropdownlistWrap{
  position: absolute;
  box-shadow: none!important;
}
.pat-calendar :deep(.k-picker.k-focus) {
  box-shadow: none!important;
}
.pat-calendar :deep(.k-picker) :hover {
  border:1px solid #888;
}


/* add #8091 2023/03/14 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 start */
.expand{
  position: absolute;
  /* #8091 2023/04/06 黒背景で「展開する」、プルダウンの文字列が背景と同化して見えなくなる。 start */
  color: var(--ntss-base-color);
  /* #8091 2023/04/06 黒背景で「展開する」、プルダウンの文字列が背景と同化して見えなくなる。 end */
  height: 1.7em;
}
/* add #8091 2023/03/14 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 end */

@media screen and (max-width: 750px) {
  .close-class.for-calendar :deep(.left-margin-area) {
    min-width: 115px;
  }
}

@media screen and (max-width: 1050px) {
  /* .open-class :deep(.variable_width){
    width: 110px;
  } */
  .open-class.for-calendar :deep(.left-margin-area) {
    min-width: 115px;
  }
}
.pat-calendar :deep(.k-input) {
  height: auto;
}
.pat-calendar {
  height: 100%;
  margin-left: 5px;
}

.pat-calendar :deep(.k-list-item-text){
  font-family: Helvetica Neue, Helvetica, Arial, Osaka, Meiryo, sans-serif!important;
}
</style>
