import _ from "@/compat/collections/lodash";
import BigNumber from "@/compat/number/bignumber";
import dayjs from "@/compat/date/dayjs";
import store from "@/stores";
import { bedIncludeDeleted as _bedIncludeDeleted, equipmentClass as _equipmentClass, medicineClass as _medicineClass, treatmentIncludeDeleted as _treatmentIncludeDeleted, implantIncludeDeleted as _implantIncludeDeleted, infectionIncludeDeleted as _infectionIncludeDeleted, kur as _kur, vaIncludeDeleted as _vaIncludeDeleted, patCalendarLayout as _patCalendarLayout, diseaseIncludeDeleted as _diseaseIncludeDeleted, patEventSubCategoryIncludeDeleted as _patEventSubCategoryIncludeDeleted, bbsKindIncludeDeleted as _bbsKindIncludeDeleted } from "@/functions/mst/MstGetters.js";
import * as Def from "./Definitions.js";
import { DISP_GROUP_MAP, LAYOUT_CATEGORY_BBSINFO, LAYOUT_CATEGORY_EXAMREQUEST, LAYOUT_CATEGORY_EXAMRESULT, LAYOUT_CATEGORY_IMPLANTINFO, LAYOUT_CATEGORY_INFECTINFO, LAYOUT_CATEGORY_INOUTINFO, LAYOUT_CATEGORY_MEDIHSTINFO, LAYOUT_CATEGORY_PATEVENT, LAYOUT_CATEGORY_PHYSICALINFO, LAYOUT_CATEGORY_PRESCRIPTION, LAYOUT_CATEGORY_RADREQUEST, LAYOUT_CATEGORY_TREATINFO, LAYOUT_CATEGORY_VITALMONITORFLG_1, LAYOUT_ITEM_INDINFO_STARTTIME, LAYOUT_ITEM_INFO_BED, LAYOUT_ITEM_INFO_KUR, LAYOUT_ITEM_INFO_STARTTIME, LAYOUT_ITEM_INFO_TREATMENT, LAYOUT_ITEM_PHYSICALINFO_BREASTDIAMETER, LAYOUT_ITEM_PHYSICALINFO_CHESTDIAMETER, LAYOUT_ITEM_PHYSICALINFO_CTR, LAYOUT_ITEM_PHYSICALINFO_DW, LAYOUT_ITEM_PHYSICALINFO_EXAMWEIGHT, LAYOUT_ITEM_PHYSICALINFO_HEIGHT, LAYOUT_ITEM_PHYSICALINFO_ORDERCLASS, LAYOUT_ITEM_PHYSICALINFO_TARGETWEIGHT, LAYOUT_ITEM_PHYSICALINFO_WEIGHTLOWER, LAYOUT_ITEM_PHYSICALINFO_WEIGHTUPPER, LAYOUT_ITEM_RSTINFO_ADDWATERTOTAL, LAYOUT_ITEM_RSTINFO_CHARGEUSER1, LAYOUT_ITEM_RSTINFO_CHARGEUSER2, LAYOUT_ITEM_RSTINFO_COURSE, LAYOUT_ITEM_RSTINFO_CTR, LAYOUT_ITEM_RSTINFO_CTRMEASUREDATE, LAYOUT_ITEM_RSTINFO_DIALYSISCNT, LAYOUT_ITEM_RSTINFO_DIALYSISTIME, LAYOUT_ITEM_RSTINFO_ENDDATE, LAYOUT_ITEM_RSTINFO_IAPRT, LAYOUT_ITEM_RSTINFO_IHDFPLL, LAYOUT_ITEM_RSTINFO_INOUTCLASS, LAYOUT_ITEM_RSTINFO_KTVMEASURE, LAYOUT_ITEM_RSTINFO_POSTBP, LAYOUT_ITEM_RSTINFO_PREBP, LAYOUT_ITEM_RSTINFO_PUNCTUREUSER1, LAYOUT_ITEM_RSTINFO_PUNCTUREUSER2, LAYOUT_ITEM_RSTINFO_RECRCLRT_BLDVL, LAYOUT_ITEM_RSTINFO_RECRCLRT_DATETIME, LAYOUT_ITEM_RSTINFO_RECRCLRT_RATE, LAYOUT_ITEM_RSTINFO_RETURNUSER1, LAYOUT_ITEM_RSTINFO_RETURNUSER2, LAYOUT_ITEM_RSTINFO_STARTDATE, LAYOUT_ITEM_RSTINFO_STTCVNSPRSSR, LAYOUT_ITEM_RSTINFO_TEMPERATURE, LAYOUT_ITEM_RSTINFO_URR, LAYOUT_ITEM_RSTINFO_WARD, LAYOUT_ITEM_RSTINFO_WATERREMOVALRST, LAYOUT_ITEM_RSTINFO_WATERREMOVALTARGET, LAYOUT_ITEM_RSTINFO_WEIGHTAFTER, LAYOUT_ITEM_RSTINFO_WEIGHTBEFORE, LAYOUT_ITEM_TREATCONDINFO_1, LAYOUT_ITEM_TREATCONDINFO_10, LAYOUT_ITEM_TREATCONDINFO_105, LAYOUT_ITEM_TREATCONDINFO_106, LAYOUT_ITEM_TREATCONDINFO_11, LAYOUT_ITEM_TREATCONDINFO_12, LAYOUT_ITEM_TREATCONDINFO_13, LAYOUT_ITEM_TREATCONDINFO_14, LAYOUT_ITEM_TREATCONDINFO_15, LAYOUT_ITEM_TREATCONDINFO_16, LAYOUT_ITEM_TREATCONDINFO_17, LAYOUT_ITEM_TREATCONDINFO_18, LAYOUT_ITEM_TREATCONDINFO_19, LAYOUT_ITEM_TREATCONDINFO_2, LAYOUT_ITEM_TREATCONDINFO_20, LAYOUT_ITEM_TREATCONDINFO_21, LAYOUT_ITEM_TREATCONDINFO_22, LAYOUT_ITEM_TREATCONDINFO_23, LAYOUT_ITEM_TREATCONDINFO_24, LAYOUT_ITEM_TREATCONDINFO_25, LAYOUT_ITEM_TREATCONDINFO_26, LAYOUT_ITEM_TREATCONDINFO_27, LAYOUT_ITEM_TREATCONDINFO_28, LAYOUT_ITEM_TREATCONDINFO_29, LAYOUT_ITEM_TREATCONDINFO_3, LAYOUT_ITEM_TREATCONDINFO_30, LAYOUT_ITEM_TREATCONDINFO_31, LAYOUT_ITEM_TREATCONDINFO_32, LAYOUT_ITEM_TREATCONDINFO_33, LAYOUT_ITEM_TREATCONDINFO_34, LAYOUT_ITEM_TREATCONDINFO_35, LAYOUT_ITEM_TREATCONDINFO_36, LAYOUT_ITEM_TREATCONDINFO_37, LAYOUT_ITEM_TREATCONDINFO_38, LAYOUT_ITEM_TREATCONDINFO_4, LAYOUT_ITEM_TREATCONDINFO_5, LAYOUT_ITEM_TREATCONDINFO_6, LAYOUT_ITEM_TREATCONDINFO_7, LAYOUT_ITEM_TREATCONDINFO_8, LAYOUT_ITEM_TREATCONDINFO_9, LAYOUT_ITEM_TREATCONDINFO_DW, PSEUDO_MST_INDCOND_IPPOWER, PSEUDO_MST_INDCOND_IPSTART, PSEUDO_MST_INDCOND_REPLENISHERSELECT, PSEUDO_MST_INDCOND_USE, PSEUDO_MST_MOVEINOUT, PSEUDO_MST_ORDER_CLASS, PSEUDO_MST_OUTCOME, PSEUDO_MST_REG_ORDER_CLASS, PSEUDO_MST_RSTINFO_INOUT, ROUTERLINK_BBSINFO, ROUTERLINK_EXAMRECORD_DETAIL, ROUTERLINK_EXAMREQUESTRECORD_DETAIL, ROUTERLINK_FACILITY_CALENDAR, ROUTERLINK_PATEVENT, ROUTERLINK_PATINFO, ROUTERLINK_PATVIEWER, ROUTERLINK_PRESCRIPTIONRECORD_DETAIL, ROUTERLINK_RADEQUESTRECORD_DETAIL, ROUTERLINK_TREATMENTRECORD, VITAL_MONITOR_KEYS } from "./Definitions.js";
import { CATEGORY_NO, SUB_CATEGORY_NO } from "@/constants/mstPatCalendarLayoutDefine";
import { ApiHelper } from "@/apis/AxiosHelper";
import { deduplicateObjects } from "@/functions/common/CommonFunctions";
import {
  getThreshold,
  getSeriesMarker
} from "@/functions/pat-viewer/PatViewerFunctions";
import { getValueWithDecPointInMst } from "../multi-pat-list/template2"

/* add by chamaojia 2026-03-27 [12462] 患者情報共有->患者経過総合ビューア --start */
const TABOO_CLASS_PREFIX = "【禁忌】";
const ALLERGY_CLASS_PREFIX = "【ｱﾚﾙｷﾞｰ】";
const TABOO_ALLERGY_CLASS_PREFIX = "【禁忌・ｱﾚﾙｷﾞｰ】";

function getTabooAllergyPrefixNew(isTaboo, isAllergy) {
  if (isTaboo && isAllergy) {
    return TABOO_ALLERGY_CLASS_PREFIX;
  } else if (isTaboo && !isAllergy) {
    return TABOO_CLASS_PREFIX;
  } else if (!isTaboo && isAllergy) {
    return ALLERGY_CLASS_PREFIX;
  }else{
    return ""
  }
}

/* add by chamaojia 2026-03-27 [12462] 患者情報共有->患者経過総合ビューア --end */

// ===== 固定ラベル =====
const TYPE_UNMATCH_LABEL = "【分類不一致】";
const DELETED_LABEL = "【削除済み】";
const DELETED_IN_LABEL = "【削除済み含む】";
const EXPIRED_LABEL = "【期限切れ】";
const TABOO_LABEL = "【禁忌】";
const ALLERGY_LABEL = "【ｱﾚﾙｷﾞｰ】";
const TABOO_ALLERGY_LABEL = "【禁忌・ｱﾚﾙｷﾞｰ】";

/**
 * @description 必要なすべてのマスタを取得
 * @param {String} facilityCd 施設コード
 * @returns {Object} { <マスタ名>: <マスタオブジェクト配列> }
 */
export const getRequiredMst = async facilityCd => {
  const [
    bedIncludeDeleted,
    equipmentClass,
    medicineClass,
    treatmentIncludeDeleted,
    implantIncludeDeleted,
    infectionIncludeDeleted,
    kurIncludeDeleted,
    vaIncludeDeleted,
    layout,
    // add 10366 患者カレンダーで特定条件下で既往歴の病名が削除済みと表示されてしまう zhao start
    diseaseIncludeDeleted,
    // add 10366 患者カレンダーで特定条件下で既往歴の病名が削除済みと表示されてしまう zhao end
    patEventSubCategoryIncludeDeleted,
    bbsKindIncludeDeleted
  ] = await Promise.all([
    _bedIncludeDeleted(facilityCd),
    _equipmentClass(facilityCd),
    _medicineClass(facilityCd),
    _treatmentIncludeDeleted(facilityCd),
    _implantIncludeDeleted(facilityCd),
    _infectionIncludeDeleted(facilityCd),
    _kur(facilityCd),
    _vaIncludeDeleted(facilityCd),
    _patCalendarLayout(facilityCd),
    // add 10366 患者カレンダーで特定条件下で既往歴の病名が削除済みと表示されてしまう zhao start
    _diseaseIncludeDeleted(facilityCd),
    // add 10366 患者カレンダーで特定条件下で既往歴の病名が削除済みと表示されてしまう zhao end
    _patEventSubCategoryIncludeDeleted(facilityCd),
    _bbsKindIncludeDeleted(facilityCd)
  ]).catch(error => {
    throw new Error(error);
  });

  return {
    bedIncludeDeleted,
    equipmentClass,
    medicineClass,
    treatmentIncludeDeleted,
    implantIncludeDeleted,
    infectionIncludeDeleted,
    kurIncludeDeleted,
    vaIncludeDeleted,
    layout,
    // add 10366 患者カレンダーで特定条件下で既往歴の病名が削除済みと表示されてしまう zhao start
    diseaseIncludeDeleted,
    // add 10366 患者カレンダーで特定条件下で既往歴の病名が削除済みと表示されてしまう zhao end
    patEventSubCategoryIncludeDeleted,
    bbsKindIncludeDeleted
  };
};

// add FNSI5415-カレンダー内のセルの表示に時間がかかる 周 start
/**
 * @description 3ヶ月分の指示を取得
 * @param {Number} patId 患者ID
 * @param {String} facilityCd 施設コード
 * @param {moment} currentDate 基準日moment
 * @returns {Array} ord_mainレコード
 */
//mod #12462 患者情報共有 Ji start
export const getPatEventFor3Months = async (patId, facilityCd, currentDate, patientShareMode) => {
  const param = {
    facility_cd: facilityCd,
    pat_id: patId,
    // 全曜日
    week_pattern: "[{'text':'全','done':false,'value':0}]",
    // 開始日(基準日の前月一日)
    ind_start_date: dayjs(currentDate).subtract(1, "months").startOf("month").format("YYYYMMDD"),
    // 終了日(基準日の翌月末日)
    ind_end_date: dayjs(currentDate).add(1, "months").endOf("month").format("YYYYMMDD"),
    patShareMode: patientShareMode
  };

  const res = await ApiHelper.post("/mainData/patCalendar3MonthsList", param);
  return res.data;
};
//mod #12462 患者情報共有 Ji end
// add FNSI5415-カレンダー内のセルの表示に時間がかかる 周 end

/**
 * @description カレンダーイベントデータ作成
 * @summary カレンダーに表示される患者情報・指示情報などをすべて集める
 * @param {Object} 表示対象の情報
 * @param {moment} currentDate 基準日moment
 */
export const createEventDataCollectionNew = (
//mod #12462 患者情報共有 Ji start
  { patInfo, indInfo , examInfo, examRequestInfo, indicationInfo, prescriptionInfo, patEventInfo, bbsInfo, patMainList },
//mod #12462 患者情報共有 Ji end
  currentDate
) => {
  // 患者情報
  const { pat_main, pat_unique } = patInfo;
  /* 3ヶ月分の指示(全種)データから必要な各指示情報を取り出す */
  const indAllInfo3MonthsEventData = createIndInfo3MonthsEventData(
    indInfo,
    currentDate
  );
  const indInfoEventData = indAllInfo3MonthsEventData.map(treat => {
    return {
      // 治療情報(指示)
      ordNo: treat.ordNo,
      treatDate: treat.treatDate,
      indTreatmentName: treat.indTreatmentName,
      indTreatmentCd: treat.indTreatmentCd,
      indKurName: treat.indKurName,
      indKurCd: treat.indKurCd,
      indBedName: treat.indBedName,
      indBedCd: treat.indBedCd,
      indTreatStartTime: treat.indTreatStartTime,
      indDw: treat.indDw,
      // 治療条件(指示)
      indCondInfoJSON: treat.indCondInfo,
      // 投与薬剤(指示)
      indMediInfoJSON: treat.indMediInfo,
      // 医療材料(指示)
      indEquipInfoJSON: treat.indEquipInfo,
      // 指示コメント(指示)
      indIndCommentInfoJSON: treat.indIndCommentInfo,
      // 治療情報(実績)
      rstDialysisState: treat.rstDialysisState,
      rstTreatmentName: treat.rstTreatmentName,
      rstTreatmentCd: treat.rstTreatmentCd,
      rstKurName: treat.rstKurName,
      rstKurCd: treat.rstKurCd,
      rstBedName: treat.rstBedName,
      rstBedCd: treat.rstBedCd,
      rstStartDate: treat.rstStartDate,
      rstEndDate: treat.rstEndDate,
      rstInOutClass: treat.rstInOutClass,
      rstDialysisCnt: treat.rstDialysisCnt,
      rstWardName: treat.rstWardName,
      rstCourseName: treat.rstCourseName,
      rstWardCd: treat.rstWardCd,
      rstCourseCd: treat.rstCourseCd,
      rstPunctureUserInfo: treat.rstPunctureUserInfo,
      rstReturnUserInfo: treat.rstReturnUserInfo,
      rstChargeUserInfo: treat.rstChargeUserInfo,
      rstWeightInfo: treat.rstWeightInfo,
      rstDw: treat.rstDw,
      rstBloodCirculateTotal: treat.rstBloodCirculateTotal,
      rstKtV: treat.rstKtV,
      pullLeaveAmount: treat.pullLeaveAmount,
      // 治療条件(実績)
      rstCondInfoJSON: treat.rstCondInfo,
      // 投与薬剤(実績)
      rstMediInfoJSON: treat.rstMediInfo,
      // 医療材料(実績)
      rstEquipInfoJSON: treat.rstEquipInfo,
      // 指示コメント(実績)
      rstIndCommentInfoJSON: treat.rstIndCommentInfo,
      // 編集不可フラグ ★pat_name_identification（名寄せテーブル）参照した場合にtrueとなるが、現状、名寄せテーブル使用していないので必ずfalse
      readOnly: treat.readOnly,
      // 前血圧、後血圧、体温
      //add #12462 患者情報共有 Ji start
      mniMonitorList: treat.mniMonitorList,
      facility_cd: treat.facilityCd,
      //add #12462 患者情報共有 Ji end
    };
  });

  //add #12462 患者情報共有 Ji start
  let infectInfo = []
  let implantInfo = []
  patMainList?.forEach(ele => {
    if (ele.infect_info) {
      JSON.parse(ele.infect_info).forEach(ele2 => {
        infectInfo.push({ ...ele2, facility_cd: ele.facility_cd })
      })
    }
    if (ele.implant_info) {
      JSON.parse(ele.implant_info).forEach(ele2 => {
        implantInfo.push({ ...ele2, facility_cd: ele.facility_cd })
      })
    }
  })
  //add #12462 患者情報共有 Ji end

  return {
    //mod #12462 患者情報共有 Ji start
    // [LAYOUT_CATEGORY_INFECTINFO.key]: pat_main.infect_info,
    // [LAYOUT_CATEGORY_IMPLANTINFO.key]: pat_main.implant_info,
    [LAYOUT_CATEGORY_INFECTINFO.key]: JSON.stringify(infectInfo),
    [LAYOUT_CATEGORY_IMPLANTINFO.key]: JSON.stringify(implantInfo),
    //mod #12462 患者情報共有 Ji end
    [LAYOUT_CATEGORY_MEDIHSTINFO.key]: pat_unique.medical_hst_info,
    [LAYOUT_CATEGORY_INOUTINFO.key]: pat_unique.in_out_visit_history_info,
    [LAYOUT_CATEGORY_PHYSICALINFO.key]: pat_unique.physical_info,
    [LAYOUT_CATEGORY_TREATINFO.key]: indInfoEventData,
    [LAYOUT_CATEGORY_EXAMRESULT.key]:examInfo,
    [LAYOUT_CATEGORY_EXAMREQUEST.key]:examRequestInfo,
    [LAYOUT_CATEGORY_RADREQUEST.key]:indicationInfo,
    [LAYOUT_CATEGORY_PRESCRIPTION.key]:prescriptionInfo,
    [LAYOUT_CATEGORY_PATEVENT.key]:patEventInfo,
    [LAYOUT_CATEGORY_BBSINFO.key]:bbsInfo
  };
};

/**
 * @description カレンダーイベントデータ作成(指示)
 * @summary 指示がない日付も含め3ヶ月分の指示イベントデータを作成する
 * @param {Array} ord_mainレコード
 * @param {moment} currentDate 基準日moment
 */
const createIndInfo3MonthsEventData = (indInfo, currentDate) => {
  /* 3ヶ月分(前月一日～翌月末日)の治療日リストを作成する */
  // 各月の日数
  const daysOfPrevMonth = dayjs(currentDate)
    .subtract(1, "months")
    .endOf("month")
    .date();
  const daysOfCurrentMonth = dayjs(currentDate)
    .endOf("month")
    .date();
  const daysOfNextMonth = dayjs(currentDate)
    .add(1, "months")
    .endOf("month")
    .date();

  // 前月一日
  const firstDayOfPrevMonth = dayjs(currentDate)
    .subtract(1, "months")
    .date(1);
  const treatDateList = Array(
    daysOfCurrentMonth + daysOfPrevMonth + daysOfNextMonth
  )
    .fill()
    .map((_, i) =>
      // 前月一日から翌月末日まで日付を割り当てる
      dayjs(firstDayOfPrevMonth)
        .add(i, "days")
        .format("YYYYMMDD")
    );
  // add bug 7872 修正 chen start
  if (!indInfo) {
    indInfo = [];
  }
  // add bug 7872 修正 chen end
  const datesWithNoIndInfo = treatDateList
    .filter(date => !indInfo.find(el => el.treatDate === date))
    .map(date => ({ ordNo: null, treatDate: date }));

  return [...indInfo, ...datesWithNoIndInfo];
};

/**
 * @description 共通カレンダーコンポーネントに渡すカレンダー内容作成
 * @summary レイアウトで指定されたカテゴリのデータを日付毎に設定する
 * @param {Array} layout カレンダーレイアウト
 * @param {Array} eventDataCollection カレンダーイベントデータ
 * @param {Object} mst 必要な全マスタ
 * @returns {Array} カレンダー内容
 */
export const createCalendarContents = (
  layout,
  eventDataCollection,
  mst
) => {
  const calendarContents = [];
  // 表示区分
  const { layoutInfo = [], dispClass: _dispClass } = layout ?? {};
  const dispClass = _dispClass ?? "0";

  // マスタで指定されたレイアウトの並び順で内容を作成する
  layoutInfo.forEach(layoutInfo => {

    const { dataKey, isDispGroup, items: layoutItems, dispGroup: layoutCategoryKey } = layoutInfo;
    const layoutCategoryTitle = DISP_GROUP_MAP[layoutCategoryKey];
    const eventData = eventDataCollection[dataKey];

    switch (dataKey) {
      case LAYOUT_CATEGORY_INFECTINFO.key:  // 患者情報-感染症
        addInfectInfoToCalendar(calendarContents, eventData, mst, layoutCategoryKey, layoutCategoryTitle, isDispGroup);
        break;

      case LAYOUT_CATEGORY_IMPLANTINFO.key: // 患者情報-インプラント
        addImplantInfoToCalendar(calendarContents, eventData, mst, layoutCategoryKey, layoutCategoryTitle, isDispGroup);
        break;

      case LAYOUT_CATEGORY_MEDIHSTINFO.key: // 患者情報-既往歴
        addMediHstInfoToCalendar(calendarContents, eventData, mst, layoutCategoryKey, layoutCategoryTitle, isDispGroup);
        break;

      case LAYOUT_CATEGORY_INOUTINFO.key:   // 患者情報-入外・転入出
        addInOutInfoToCalendar(calendarContents, eventData, mst, layoutCategoryKey, layoutCategoryTitle, isDispGroup);
        break;

      case LAYOUT_CATEGORY_PHYSICALINFO.key:  // 患者情報-身体情報
        addPhysicalInfoToCalendar(layoutItems, calendarContents, eventData, layoutCategoryKey, layoutCategoryTitle, isDispGroup);
        break;

      case LAYOUT_CATEGORY_TREATINFO.key: // 治療情報（スケジュール、治療条件、投与薬剤、医療材料、指示コメント、実績、バイタル・モニタグラフ）
        addTreatInfoToCalendar(
          layoutInfo,
          calendarContents,
          eventDataCollection,
          mst,
          layoutCategoryKey,
          dispClass
        );
        break;

      case LAYOUT_CATEGORY_EXAMRESULT.key: // 検査結果
        addExamInfoToCalendar(
          calendarContents,
          eventDataCollection[LAYOUT_CATEGORY_EXAMRESULT.key],
          layoutCategoryKey,
          layoutCategoryTitle
        );
        break;
      case LAYOUT_CATEGORY_EXAMREQUEST.key: // 検査予定
        addExamRequestInfoToCalendar(
          layoutItems,
          calendarContents,
          eventDataCollection[LAYOUT_CATEGORY_EXAMREQUEST.key],
          layoutCategoryKey,
          layoutCategoryTitle,
          isDispGroup
        );
        break;
      case LAYOUT_CATEGORY_RADREQUEST.key: // 一般撮影検査予定
        addRadRequestInfoToCalendar(
          calendarContents,
          eventDataCollection[LAYOUT_CATEGORY_RADREQUEST.key],
          layoutCategoryKey,
          layoutCategoryTitle
        );
        break;
      case LAYOUT_CATEGORY_PRESCRIPTION.key: // 処方
        addPrescriptionInfoToCalendar(
          calendarContents,
          eventDataCollection[LAYOUT_CATEGORY_PRESCRIPTION.key],
          layoutCategoryKey,
          layoutCategoryTitle,
          isDispGroup
        );
        break;
      case LAYOUT_CATEGORY_PATEVENT.key: // 患者イベント
        addPatEventInfoToCalendar(
          layoutItems,
          calendarContents,
          eventDataCollection[LAYOUT_CATEGORY_PATEVENT.key],
          mst,
          layoutCategoryKey,
          layoutCategoryTitle,
          isDispGroup
        );
        break;
      case LAYOUT_CATEGORY_BBSINFO.key: // 施設イベント
        addBbsInfoToCalendar(
          layoutItems,
          calendarContents,
          eventDataCollection[LAYOUT_CATEGORY_BBSINFO.key],
          mst,
          layoutCategoryKey,
          layoutCategoryTitle,
          isDispGroup
        );
        break;
    }
  });

  return calendarContents;
};

/**
 * 患者カレンダーレイアウトマスタのdisp_item_info を並び順保証でフラット化する
 * - 患者情報は item階層までフラット化
 * - 治療情報は フラット化しない。治療予定のisDispをisDispGroupにセットする
 * - 上記以外は subCategory階層までフラット化
 *
 * @param {Array} layout
 * @returns {Array}
 */
export const flatLayoutInfo = (layout = []) => {
  const ITEM_FLAT_TARGETS = [
    { categoryNo: CATEGORY_NO.PAT_CONTENT, subCategoryNo: SUB_CATEGORY_NO.PAT_INFO }
  ];

  return layout.flatMap(category => {
    /** 治療情報：そのまま保持 + バイタル・モニタグラフ を dataKey単位で集約 */
    if (category.categoryNo === CATEGORY_NO.TREATMENT_CONTENT) {
      const categoryItems = category.categoryItem ?? [];

      // 治療予定の isDisp → isDispGroup
      const subCategory1 = categoryItems.find(
        sub => sub.subCategoryNo === SUB_CATEGORY_NO.TREAT_PLAN
      );

      // vital_XXXX 集約用（元の順序保持）
      const vitalMap = new Map();
      const resultSubCategories = [];

      categoryItems.forEach(sub => {
        const dataKey = sub.dataKey ?? "";

        // -------- vital 集約 --------
        if (dataKey.startsWith("vital_")) {
          if (!vitalMap.has(dataKey)) {
            const groupedSub = {
              subCategoryNo: sub.subCategoryNo, // vital_XXXX 集約した塊の最初のNo
              dispGroup: sub.dispGroup,
              isDisp: sub.isDisp,
              dataKey,
              items: []
            };

            vitalMap.set(dataKey, groupedSub);
            // 最初に出現した位置で追加（順序維持）
            resultSubCategories.push(groupedSub);
          }

          // ★元のsubCategory自体をitemsに入れる
          vitalMap.get(dataKey).items.push(sub);
          return;
        }
        // バイタル・モニタグラフ 以外はそのまま
        resultSubCategories.push(sub);
      });

      return [{
        rowType: "category",

        categoryNo: category.categoryNo,
        categoryName: category.categoryName,
        categoryIsDisp: category.isDisp,
        dispGroup: category.dispGroup,

        ...(subCategory1 ? { isDispGroup: subCategory1.isDisp } : {}),

        dataKey: category.dataKey,

        // バイタル・モニタグラフ 集約後の subCategory
        categoryItem: resultSubCategories
      }];
    }

    // 治療情報以外
    return (category.categoryItem ?? []).flatMap(sub => {
      const items = sub.subCategoryItem ?? [];

      const isItemFlat = ITEM_FLAT_TARGETS.some(
        t =>
          t.categoryNo === category.categoryNo &&
          t.subCategoryNo === sub.subCategoryNo
      );

      const base = {
        categoryNo: category.categoryNo,
        categoryName: category.categoryName,
        categoryIsDisp: category.isDisp,

        subCategoryNo: sub.subCategoryNo,
        subCategoryName: sub.subCategoryName,
        dispGroup: sub.dispGroup,
        isDispGroup: sub.isDisp
      };

      // -------- item 階層までフラット化 --------
      if (isItemFlat && items.length > 0) {
        return items.map(item => ({
          rowType: "item",
          ...base,
          itemNo: item.itemNo,
          itemName: item.itemName,
          dataKey: item.dataKey,
          ...item
        }));
      }
      // -------- subCategory 単位 --------
      return [{
        rowType: "subCategory",
        ...base,
        dataKey: sub.dataKey ?? category.dataKey,
        items
      }];
    });
  });
};

/**
 * @description マスタコード→名称変換
 * @param {Array} mst 対象のマスタオブジェクト配列
 * @param {Number} code 変換するコード
 * @param {Boolean} isPseudo 疑似マスタフラグ
 * @param {String} codeString マスタオブジェクトのコードのキー名
 * @param {String} nameString マスタオブジェクトの名称のキー名
 * @param {Boolean} isPrefixDel 【削除済み】付与フラグ
 * @returns {String} マスタ名称 ※コードがnull: '未登録', コードがマスタに存在しない: '不明'
 */
const mstCodeToName = (
  mst,
  code,
  isPseudo,
  codeString = "code",
  nameString = "name",
  isPrefixDel = true
) => {
  if (!isPseudo && !code) {
    // 通常のマスタでfalsyなコードは未登録扱い
    return null;
  }

  const target = Array.isArray(mst)
    ? mst.find(el => el[codeString] == code)
    : null;
  // 削除済みを含んだマスタ
  if (target) {
    const isDeleted = target.isDisp === "0" || target.isDel === "1";
    const prefix = isPrefixDel && isDeleted ? DELETED_LABEL : "";
    return prefix + target[nameString];
  //mod #12462 患者情報共有 Ji start
  } else {
    return null;
  }
  // return target[nameString];
  //mod #12462 患者情報共有 Ji end
};

/**
 * @description 禁忌・アレルギー prefix を返す
 * @returns {String} "", "【禁忌】", "【ｱﾚﾙｷﾞｰ】", "【禁忌・ｱﾚﾙｷﾞｰ】"
 */
const getTabooAllergyPrefix = (cd, mstTabooAllergy = []) => {
  let hasTaboo = false;
  let hasAllergy = false;

  mstTabooAllergy.forEach(item => {
    if (!item.detailInfo) return;

    const detailList = JSON.parse(item.detailInfo);
    if (!detailList.some(el => el.cd == cd)) return;

    if (item.tabooAllergyClass == "1") {
      hasTaboo = true;
    } else if (item.tabooAllergyClass == "2") {
      hasAllergy = true;
    }
  });

  if (hasTaboo && hasAllergy) return TABOO_ALLERGY_LABEL;
  if (hasTaboo) return TABOO_LABEL;
  if (hasAllergy) return ALLERGY_LABEL;

  return "";
};

/**
 * @description 期限切れ prefix を返す
 * @returns {String} "" or "【期限切れ】"
 */
const getExpiredPrefix = (
  cd,
  treatDate,
  mstData = [],
  codeKey
) => {
  const target = mstData.find(
    //el => el[codeKey] == cd && el.isDisp == "1"
    el => el[codeKey] == cd
  );

  if (target?.useEndDate && treatDate > target.useEndDate) {
    return EXPIRED_LABEL;
  }

  return "";
};

/**
 * @description 分類チェックを行い、表示用 prefix を返す
 * @param {String} itemKey
 * @param {String} value
 * @param {Object} mstMap
 * @param {number|number[]} [allowClassTypes]  // 明示指定があればこちらを優先
 * @param {Object} [options]
 * @param {Object} [options.treatCondEvent]
 * @param {Object} [options.treatmentMap]
 * @returns {String} typeCheck（不一致時のみ '【分類不一致】 '）
 */
const getTypeCheck = (
  itemKey,
  value,
  mstMap,
  allowClassTypes,
  options = {}
) => {
  const { treatCondEvent, treatmentMap } = options;
  // itemKey ごとの許可 classType 定義
  const CLASS_TYPE_MAP = {
    [LAYOUT_ITEM_TREATCONDINFO_6.key]: [4],       // 吸着カラム
    [LAYOUT_ITEM_TREATCONDINFO_7.key]: [5, 6],    // 1次膜
    [LAYOUT_ITEM_TREATCONDINFO_8.key]: [5, 6],    // 2次膜
    [LAYOUT_ITEM_TREATCONDINFO_13.key]: [1],      // 血液回路
    [LAYOUT_ITEM_TREATCONDINFO_15.key]: [2],      // 透析液
    [LAYOUT_ITEM_TREATCONDINFO_25.key]: [1]       // 抗凝固剤
  };

  if (value == null) return "";

  const mst = mstMap[value];
  if (!mst) return "";

  // 呼び出し側指定があれば優先、なければitemKeyごとの定義を使用
  let allowTypes;

  // 1. 呼び出し側指定が最優先
  if (allowClassTypes != null) {
    allowTypes = Array.isArray(allowClassTypes)
      ? allowClassTypes
      : [allowClassTypes];

  // 2. itemKey 固有ルール
  } else if (itemKey === LAYOUT_ITEM_TREATCONDINFO_19.key) {  // 補液
    // 補液にオンライン治療の場合は透析液がセットされる
    if (
      treatCondEvent?.indTreatmentCd != null &&
      treatmentMap?.[treatCondEvent.indTreatmentCd] != null
    ) {
      const deviceMode = treatmentMap[treatCondEvent.indTreatmentCd];
      // 治療方法マスタ.装置モード 7:OHDF、8:OHF、10:I-HDF
      allowTypes = [7, 8, 10].includes(deviceMode)
        ? [2]
        : [3];
    }

  // 3. 通常ルール
  } else {
    allowTypes = CLASS_TYPE_MAP[itemKey];
  }

  if (!allowTypes) return "";

  return allowTypes.includes(mst.classType)
    ? ""
    : TYPE_UNMATCH_LABEL + " ";
}

/**
 * @description 表示用 prefix を返す（禁忌・ｱﾚﾙｷﾞｰ／期限切れ）
 * @param {*} cd 薬剤コード/医療材料コード
 * @param {String} treatDate 治療日 例: "20260101"
 * @param {Array} mstData 薬剤マスタ/医療材料マスタ（削除済み含む）
 * @param {String} codeKey マスタを参照するための物理カラム名
 * @param {Array} mstTabooAllergy 患者の禁忌ｱﾚﾙｷﾞｰのマスタ情報
 * @param {String} itemKey レイアウトに設定されるitemKey
 * @param {Object} mstMap 薬剤分類/医療材料分類のMap
 * @param {number|number[]} [allowClassTypes]  // 明示指定があればこちらを優先
 * @param {Object} [options]
 * @param {Object} [options.treatCondEvent]
 * @param {Object} [options.treatmentMap]
 */
const getDisplayPrefix = (
  cd,
  treatDate,
  mstData = [],
  codeKey,
  mstTabooAllergy = [],
  // --- 分類チェック用 ---
  itemKey,
  mstMap,
  allowClassTypes,
  typeCheckOptions
) => {
  // -------------------
  // 禁忌・ｱﾚﾙｷﾞｰ
  // -------------------
  const tabooPrefix =
    getTabooAllergyPrefix(cd, mstTabooAllergy);
  // -------------------
  // 分類チェック
  // -------------------
  const typePrefix = itemKey
  ? getTypeCheck(
      itemKey,
      cd,
      mstMap,
      allowClassTypes,
      typeCheckOptions
    )
  : "";
  // -------------------
  // 期限切れ
  // -------------------
  const expiredPrefix =
    getExpiredPrefix(cd, treatDate, mstData, codeKey);

  const prefix = `${tabooPrefix}${typePrefix}${expiredPrefix}`;
  return prefix;
};

/**
 * @description 調製薬剤配下の薬剤状態から、削除済み、禁忌アレルギー、期限切れチェックを行い、表示用 prefix を返す
 * @param {*} mixCd 調整薬剤コード
 * @param {String} treatDate 治療日 例: "20260101"
 * @param {Array} allMData 調整薬剤マスタ（削除済み含む）
 * @param {Array} allData 薬剤マスタ（削除済み含む）
 * @param {Array} mstTabooAllergy 患者の禁忌ｱﾚﾙｷﾞｰのマスタ情報
 * @param {String} itemKey レイアウトに設定されるitemKey
 * @param {Object} mstMap 薬剤分類/医療材料分類のMap
 * @param {number|number[]} [allowClassTypes]  // 明示指定があればこちらを優先
 * @param {Object} [options]
 * @param {Object} [options.treatCondEvent]
 * @param {Object} [options.treatmentMap]
 * @returns {String} 接頭辞
 */
const getMixMedicinePrefix = (
  mixCd,
  treatDate,
  allMData,
  allData,
  mstTabooAllergy,
  // --- 分類チェック用 ---
  itemKey,
  mstMap,
  allowClassTypes,
  typeCheckOptions
) => {
  const mixTarget = allMData.find(
    //el => el.medicineMixCd == mixCd && el.isDisp == "1"
    el => el.medicineMixCd == mixCd
  );
  if (!mixTarget) return "";

  const cdList = JSON.parse(mixTarget.mixInfo);

  // フラグ
  let inDeleted = false;
  let inExpired = false;
  let inTaboo = false;
  let inAllergy = false;
  let inTabooAllergy = false;
  let inTypeUnMatch = false;

  cdList.forEach(({ cd }) => {
    // 削除済み判定
    const mediName = mstCodeToName(
      allData,
      cd,
      false,
      "medicineCd",
      "medicineName"
    );
    if (mediName.includes(DELETED_LABEL)) {
      inDeleted = true;
    }

    // 分類不一致、禁忌・ｱﾚﾙｷﾞｰ、期限切れのチェック
    const mediPrefix = getDisplayPrefix(
      cd,
      treatDate,
      allData,
      "medicineCd",
      mstTabooAllergy,
      itemKey,
      mstMap,
      allowClassTypes,
      typeCheckOptions
    );

    if (mediPrefix.includes(TABOO_ALLERGY_LABEL)) {
      inTabooAllergy = true;
    } else {
      if (mediPrefix.includes(TABOO_LABEL)) inTaboo = true;
      if (mediPrefix.includes(ALLERGY_LABEL)) inAllergy = true;
    }

    if (mediPrefix.includes(EXPIRED_LABEL)) {
      inExpired = true;
    }
    if (mediPrefix.includes(TYPE_UNMATCH_LABEL)) {
      inTypeUnMatch = true;
    }
  });

  // prefix 決定
  let prefix = "";

  if (inTypeUnMatch) {
    prefix = TYPE_UNMATCH_LABEL;
  }

  if (inTabooAllergy || (inTaboo && inAllergy)) {
    prefix += TABOO_ALLERGY_LABEL;
  } else if (inTaboo) {
    prefix += TABOO_LABEL;
  } else if (inAllergy) {
    prefix += ALLERGY_LABEL;
  }

  if (inExpired) {
    prefix += EXPIRED_LABEL;
  }
  if (inDeleted) {
    prefix += DELETED_IN_LABEL;
  }

  return prefix;
};

/**
 * @description マスタコード→単位名称変換
 * @param {Array} mst 対象のマスタオブジェクト配列
 * @param {Number} code 変換するコード
 * @param {String} codeColumn コードのカラム名
 * @returns {String} 単位名称 ※コードがnull、またはマスタに存在しない場合は空文字
 */
const mstCodeToUnit = (mst, code, codeColumn) => {
  let unit;
  unit = mstCodeToName(mst, code, false, codeColumn, "unit", false);
  if (!unit || unit === "null") {
    unit = "";
  }

  return unit;
};

//add 8385 患者カレンダー>治療指示に表示される数値の小数点以下表示桁が患者経過総合ビューアと異なる。 zhao start
const mstCodeToUnitSecond = (mst, code, codeColumn) => {
  let unit;
  unit = mstCodeToName(mst, code, false, codeColumn, "unitSecond", false);
  if (!unit || unit === "null") {
    unit = "";
  }

  return unit;
};
//add 8385 患者カレンダー>治療指示に表示される数値の小数点以下表示桁が患者経過総合ビューアと異なる。 zhao start
/**
 * @description 感染症情報をカレンダーに追加
 * @param {Array} calendarContents 全てのカレンダー内容を保持する配列
 * @param {String} infectInfoJSON 感染症情報JSON
 * @param {Object} mst マスタ一覧オブジェクト
 * @param {String} layoutCategoryKey カテゴリキー
 * @param {String} layoutCategoryTitle カテゴリ名
 * @param {String} isDispGroup 親要素のチェック存在有無
 */
const addInfectInfoToCalendar = (calendarContents, infectInfoJSON, mst, layoutCategoryKey, layoutCategoryTitle, isDispGroup ) => {
  if (!infectInfoJSON) {
    return;
  }

  const infectInfo = JSON.parse(infectInfoJSON);
  //add #12462 患者情報共有 Ji start
  const getFacilityCd = store.getters["user/getFacilityCd"];
  //add #12462 患者情報共有 Ji end

  // 検査日が入力されている感染症
  const examinedInfectInfo = infectInfo.filter(({ exam_date }) => exam_date);
  //mod #12462 患者情報共有 Ji start
  for (const { infection_cd, infection_name, infect, exam_date, facility_cd } of examinedInfectInfo) {
    //const name = mstCodeToName(mst.infectionIncludeDeleted, infection_cd, false, "infectionCd", "infectionName");
    const name = facility_cd !== getFacilityCd
      ? infection_name
      : mstCodeToName(
        mst.infectionIncludeDeleted,
        infection_cd,
        false,
        "infectionCd",
        "infectionName"
      );
  //mod #12462 患者情報共有 Ji end
    // 「未登録」の場合に項目は表示しない
    if (name === null || name === undefined) {
      continue;
    }

    const result = infect === "0" ? "不明" : infect === "1" ? "－" : "＋";
    const calendarContent = {
      content: `${name} (${result})`,
      routerLink: ROUTERLINK_PATINFO,
      readOnly: examinedInfectInfo.readOnly,
      indRstClass: "other",
      // add #8091 2023/03/14 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 start
      layoutCategoryKey,
      layoutCategoryTitle,
      // add #8091 2023/03/14 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 end
      isDispGroup,
      //add #12462 患者情報共有 Ji start
      facility_cd: facility_cd,
      //add #12462 患者情報共有 Ji end
    };

    addContentToCalendar(calendarContents, exam_date, calendarContent);
  }
};

/**
 * @description インプラント情報をカレンダーに追加
 * @param {Array} calendarContents 全てのカレンダー内容を保持する配列
 * @param {String} implantInfoJSON インプラント情報JSON
 * @param {Object} mst マスタ一覧オブジェクト
 * @param {String} layoutCategoryKey カテゴリキー
 * @param {String} layoutCategoryTitle カテゴリ名
 * @param {String} isDispGroup 親要素のチェック存在有無
 */
const addImplantInfoToCalendar = (calendarContents, implantInfoJSON, mst, layoutCategoryKey, layoutCategoryTitle, isDispGroup) => {
  if (!implantInfoJSON) {
    return;
  }

  const implantInfo = JSON.parse(implantInfoJSON);
  //add #12462 患者情報共有 Ji start
  const getFacilityCd = store.getters["user/getFacilityCd"];
  //add #12462 患者情報共有 Ji end

  /** カレンダー表示内容生成関数 */
  const buildImplantCalendarContents = ({
    implantInfo,
    dateKey,
    mst,
    calendarContents,
    layoutCategoryKey,
    layoutCategoryTitle,
    isDispGroup,
  }) => {
    const literal = dateKey === "reg_date" ? "導入" : "除去";
    // 1. 日付があるものだけ
    const examinedInfo = implantInfo.filter(info => info[dateKey]);
    // 2. 最新日付だけ
    const latestInfo = deduplicateObjects(examinedInfo, dateKey);

    for (const info of latestInfo) {
    //mod #12462 患者情報共有 Ji start
      const { implant_cd, implant_name, facility_cd } = info;
      const date = info[dateKey];

      //const name = mstCodeToName(mst.implantIncludeDeleted, implant_cd, false, "implantCd", "implantName");
      const name = facility_cd !== getFacilityCd
        ? implant_name
        : mstCodeToName(
          mst.implantIncludeDeleted,
          implant_cd,
          false,
          "implantCd",
          "implantName"
        );
      if (name == null) continue;

      const calendarContent = {
        content: `${name} ${literal}`,
        routerLink: ROUTERLINK_PATINFO,
        readOnly: examinedInfo.readOnly,
        indRstClass: "other",
        layoutCategoryKey,
        layoutCategoryTitle,
        isDispGroup,
        facility_cd: facility_cd
        //mod #12462 患者情報共有 Ji end
      };

      addContentToCalendar(calendarContents, date, calendarContent);
    }
  };

  // 導入日 コンテンツ生成
  buildImplantCalendarContents({
    implantInfo,
    dateKey: "reg_date",
    mst,
    calendarContents,
    layoutCategoryKey,
    layoutCategoryTitle,
    isDispGroup
  });
  // 除去日 コンテンツ生成
  buildImplantCalendarContents({
    implantInfo,
    dateKey: "remove_date",
    mst,
    calendarContents,
    layoutCategoryKey,
    layoutCategoryTitle,
    isDispGroup
  });
};

/**
 * @description 入外転入出情報をカレンダーに追加
 * @param {Array} calendarContents 全てのカレンダー内容を保持する配列
 * @param {String} inOutInfoJSON 既往歴情報JSON
 * @param {Object} mst マスタ一覧オブジェクト
 * @param {String} layoutCategoryKey カテゴリキー
 * @param {String} layoutCategoryTitle カテゴリ名
 * @param {String} isDispGroup 親要素のチェック存在有無
 */
const addInOutInfoToCalendar = (calendarContents, inOutInfoJSON, mst, layoutCategoryKey, layoutCategoryTitle, isDispGroup) => {
  if (!inOutInfoJSON) {
    return;
  }

  const inOutInfo = JSON.parse(inOutInfoJSON);

  // 日付が入力されている項目のみ追加対象
  const datedInOutInfo = inOutInfo.filter(
    ({ period_start, period_end }) => period_start || period_end
  );

  /** カレンダー表示内容生成関数 */
  const buildInOutContents = ({
    move_in_out,
    moveInOut,
    period_start,
    period_end,
    facility_is_free,
    to_facility,
    from_facility,
    sysfacility,
    facility_cd,
    from_facility_name
  }) => {
    let content = "";
    let contentStart = "";
    let contentEnd = "";
    const getFacilityCd = store.getters["user/getFacilityCd"];

    // 入院・退院・外来
    if (["4", "5", "6"].includes(move_in_out)) {
      content = moveInOut;
      return { content, contentStart, contentEnd };
    }

    // 施設名取得
    let facilityName = "";
    if (facility_cd !== getFacilityCd) {
      facilityName = from_facility_name
    } else {
      if (facility_is_free === "0") {
        const cd = to_facility ?? from_facility;
        const facility = sysfacility.find(
          f => f.medicalInstitutionCd === cd
        );
        if (facility) {
          facilityName =
            (facility.isDisp === "0" ? DELETED_LABEL : "") +
            (facility.facilityName ?? "");
        }
      } else {
        facilityName = to_facility ?? from_facility ?? "";
      }
    }

    // 一時転出
    if (move_in_out === "9") {
      const endText = period_end
        ? `(～${dayjs(period_end, "YYYYMMDD").format("M/D")})`
        : "";
      const startText = period_start
        ? `(${dayjs(period_start, "YYYYMMDD").format("M/D")}～)`
        : "";

      contentStart =
        `${moveInOut}${endText}` +
        (facilityName ? `　${facilityName}` : "");
      contentEnd =
        `${moveInOut}${startText}` +
        (facilityName ? `　${facilityName}` : "");

    } else {
      // その他
      content =
        `${moveInOut}` +
        (facilityName ? `　${facilityName}` : "");
    }

    return { content, contentStart, contentEnd };
  };

  // カレンダーの基本コンテンツ
  const baseCalendarContent = {
    routerLink: ROUTERLINK_PATINFO,
    readOnly: inOutInfo.readOnly,
    indRstClass: "other",
    // add #8091 2023/03/14 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 start
    layoutCategoryKey,
    layoutCategoryTitle,
    // add #8091 2023/03/14 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 end
    isDispGroup
  };
  // カレンダー表示内容生成
  for (const info of datedInOutInfo) {

    const moveInOut = mstCodeToName(
      PSEUDO_MST_MOVEINOUT,
      info.move_in_out,
      true
    );

    // 未登録は表示しない
    if (moveInOut == null) {
      continue;
    }

    const { content, contentStart, contentEnd } =
      buildInOutContents({
        ...info,
        moveInOut,
        sysfacility: mst.sysfacility
      });

    if (info.move_in_out === "9") {
      // 一時転出：開始・終了に出力
      if (info.period_start) {
        addContentToCalendar(
          calendarContents,
          info.period_start,
          { ...baseCalendarContent, content: `${contentStart}` }
        );
      }
      if (info.period_end) {
        addContentToCalendar(
          calendarContents,
          info.period_end,
          { ...baseCalendarContent, content: `${contentEnd}` }
        );
      }

    } else {
      // その他：開始日のみ
      const targetDate = info.period_start ?? info.period_end;
      if (targetDate && content) {
        addContentToCalendar(
          calendarContents,
          targetDate,
          { ...baseCalendarContent, content: `${content}` }
        );
      }
    }
  }
};

/**
 * @description 既往歴情報をカレンダーに追加
 * @param {Array} calendarContents 全てのカレンダー内容を保持する配列
 * @param {String} mediHstInfoJSON 既往歴情報JSON
 * @param {Object} mst マスタ一覧オブジェクト
 * @param {String} layoutCategoryKey カテゴリキー
 * @param {String} layoutCategoryTitle カテゴリ名
 * @param {String} isDispGroup 親要素のチェック存在有無
 */
const addMediHstInfoToCalendar = (calendarContents, mediHstInfoJSON, mst, layoutCategoryKey, layoutCategoryTitle, isDispGroup) => {
  if (!mediHstInfoJSON) {
    return;
  }

  const mediHstInfo = JSON.parse(mediHstInfoJSON);
  //add #12462 患者情報共有 Ji start
  const getFacilityCd = store.getters["user/getFacilityCd"];
  //add #12462 患者情報共有 Ji start

  /** カレンダー表示内容生成 */
  const buildMediHstCalendarContents = ({
    mediHstInfo,
    dateKey, // "disease_date" | "out_come_date" | "die_date"
    mst,
    calendarContents,
    layoutCategoryKey,
    layoutCategoryTitle,
    isDispGroup,
    handledSet
  }) => {

    // 発症日／転帰変更日／死亡日が入力されている項目
    const examinedMediHstInfo = mediHstInfo.filter(info => {
      // 日付がないものは対象外
      if (!info[dateKey]) return false;

      // 転帰変更日(死亡除く)
      if (dateKey === "out_come_date" && info.out_come === "10") {
        return false;
      }
      return true;
    });

    for (const info of examinedMediHstInfo) {

      const targetDate = info[dateKey];

      // === 同一疾患 × 同一転帰 × 同日 は 1件にまとめる ===
      const uniqueKey = `${info.disease_cd}_${info.out_come}_${targetDate}`;
      if (handledSet.has(uniqueKey)) continue;
      handledSet.add(uniqueKey);

      // mod 10366 患者カレンダーで特定条件下で既往歴の病名が削除済みと表示されてしまう zhao start
      //mod #12462 患者情報共有 Ji start
      const name = info.facility_cd !== getFacilityCd
        ? info.disease_name
        : mstCodeToName(mst.diseaseIncludeDeleted, info.disease_cd, false, "cd", "nm", false);
      //mod #12462 患者情報共有 Ji end

      let outCome = "";
      if (info.out_come != 0) {
        outCome = mstCodeToName(PSEUDO_MST_OUTCOME, info.out_come, true);
      }
      // mod 10366 患者カレンダーで特定条件下で既往歴の病名が削除済みと表示されてしまう zhao end

      if (!name) continue;

      const calendarContent = {
        // mod 10366 患者カレンダーで特定条件下で既往歴の病名が削除済みと表示されてしまう zhao start
        content: `${name} ${outCome}`,
        // mod 10366 患者カレンダーで特定条件下で既往歴の病名が削除済みと表示されてしまう zhao end
        routerLink: ROUTERLINK_PATINFO,
        indRstClass: "other",
        // mod #8091 2023/03/14 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 start
        layoutCategoryKey,
        layoutCategoryTitle,
        // mod #8091 2023/03/14 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 end
        isDispGroup
      };

      addContentToCalendar(calendarContents, targetDate, calendarContent);
    }
  }

  const handledSet = new Set();

  // 発症日
  buildMediHstCalendarContents({
    mediHstInfo,
    dateKey: "disease_date",
    mst,
    calendarContents,
    layoutCategoryKey,
    layoutCategoryTitle,
    isDispGroup,
    handledSet
  });
  // 転帰変更日
  buildMediHstCalendarContents({
    mediHstInfo,
    dateKey: "out_come_date",
    mst,
    calendarContents,
    layoutCategoryKey,
    layoutCategoryTitle,
    isDispGroup,
    handledSet
  });
  // 死亡日
  buildMediHstCalendarContents({
    mediHstInfo,
    dateKey: "die_date",
    mst,
    calendarContents,
    layoutCategoryKey,
    layoutCategoryTitle,
    isDispGroup,
    handledSet
  });

};

/**
 * @description 身体情報をカレンダーに追加
 * @param {Array} layoutItems レイアウト項目配列
 * @param {Array} calendarContents 全てのカレンダー内容を保持する配列
 * @param {String} physicalInfoJSON 身体情報JSON
 * @param {String} layoutCategoryKey カテゴリキー
 * @param {String} layoutCategoryTitle カテゴリ名
 * @param {String} isDispGroup 親要素のチェック存在有無
 */
const addPhysicalInfoToCalendar = (
  layoutItems,
  calendarContents,
  physicalInfoJSON,
  layoutCategoryKey,
  layoutCategoryTitle,
  isDispGroup
) => {
  if (!physicalInfoJSON) {
    return;
  }

  const physicalInfoAll = JSON.parse(physicalInfoJSON);

  // 検査日の重複を排除(重複日は最新日時を残す)
  // ※検査日時の降順になっているので、日付だけにした後重複排除関数に与える
  const latestPhysicalInfo = deduplicateObjects(
    physicalInfoAll.map(physicalInfo => {
      return {
        ...physicalInfo,
        exam_date: dayjs(physicalInfo.exam_date).format("YYYYMMDD"),
        readOnly: physicalInfo.readOnly
      };
    }),
    "exam_date"
  );

  latestPhysicalInfo.forEach(physicalInfo => {
    const examDate = dayjs(physicalInfo.exam_date).format("YYYYMMDD");
    for (const items of layoutItems) {
      const { itemKey } = items;
      let content = physicalInfo[itemKey];

      // 値が「未登録」の場合に項目は表示しない
      if (
        content === null || content === undefined
      ) {
        continue;
      }

      let title;
      let unit = "";
      let content2 = "";

      switch (itemKey) {
        case LAYOUT_ITEM_PHYSICALINFO_HEIGHT.key:
          title = LAYOUT_ITEM_PHYSICALINFO_HEIGHT.title;
          unit = "cm";
          break;

        case LAYOUT_ITEM_PHYSICALINFO_ORDERCLASS.key:
          content = mstCodeToName(PSEUDO_MST_ORDER_CLASS, content, true);
          break;

        case LAYOUT_ITEM_PHYSICALINFO_EXAMWEIGHT.key:
          title = LAYOUT_ITEM_PHYSICALINFO_EXAMWEIGHT.title;
          unit = "kg";
          break;

        case LAYOUT_ITEM_PHYSICALINFO_BREASTDIAMETER.key:
          title = LAYOUT_ITEM_PHYSICALINFO_BREASTDIAMETER.title;
          break;

        case LAYOUT_ITEM_PHYSICALINFO_CHESTDIAMETER.key:
          title = LAYOUT_ITEM_PHYSICALINFO_CHESTDIAMETER.title;
          break;

        case LAYOUT_ITEM_PHYSICALINFO_CTR.key:
          title = LAYOUT_ITEM_PHYSICALINFO_CTR.title;
          unit = "%";
          break;

        case LAYOUT_ITEM_PHYSICALINFO_DW.key:
          title = LAYOUT_ITEM_PHYSICALINFO_DW.title;
          unit = "kg";
          break;

        case LAYOUT_ITEM_PHYSICALINFO_TARGETWEIGHT.key:
          content2 = "DWと同じ";
          if (content !== "-1") {
            content2 = content;
            unit = "kg";
          }
          title = LAYOUT_ITEM_PHYSICALINFO_TARGETWEIGHT.title;
          content = "変更あり ";
          break;

        case LAYOUT_ITEM_PHYSICALINFO_WEIGHTUPPER.key:
          title = LAYOUT_ITEM_PHYSICALINFO_WEIGHTUPPER.title;
          unit = "kg";
          break;

        case LAYOUT_ITEM_PHYSICALINFO_WEIGHTLOWER.key:
          title = LAYOUT_ITEM_PHYSICALINFO_WEIGHTLOWER.title;
          unit = "kg";
          break;
      }

      const calendarContent = {
        content: `${title ? title + " " : ""}${content}${content2}${unit}`,
        routerLink: ROUTERLINK_PATINFO,
        readOnly: physicalInfo.readOnly,
        indRstClass: "other",
        layoutCategoryKey,
        layoutCategoryTitle,
        isDispGroup
      };
      addContentToCalendar(calendarContents, examDate, calendarContent);
    }

  });
};

/**
 * @description 治療情報のすべての項目をカレンダーに追加
 * - 同日の複数治療は治療単位で固めて表示する
 * @param {Array} layoutItems レイアウト項目配列
 * @param {Array} calendarContents 全てのカレンダー内容を保持する配列
 * @param {Array} eventDataCollection イベントデータ群
 * @param {Object} mst
 * @param {String} layoutCategoryKey カテゴリキー
 * @param {String} isDispGroup 親要素のチェック存在有無
 * @param {String} dispClass 表示区分
 */
const addTreatInfoToCalendar = (
  layoutInfo,
  calendarContents,
  eventDataCollection,
  mst,
  layoutCategoryKey,
  dispClass
) => {

  const {
    [LAYOUT_CATEGORY_TREATINFO.key]: eventData,                 // 治療情報データ
    [LAYOUT_CATEGORY_VITALMONITORFLG_1.key]: vitalInfoDataList, // バイタル・モニタグラフの表示データ
    [LAYOUT_CATEGORY_PHYSICALINFO.key]: physicalInfoJSON        // 身体情報JSON
  } = eventDataCollection;

  // 各日付の治療情報から指定レイアウト項目を取り出しカレンダーに追加していく
  for (const treatEvent of eventData) { // 治療毎の処理
    const { rstDialysisState, treatDate, ordNo } = treatEvent;
    const { categoryItem, isDispGroup } = layoutInfo;

    if (ordNo === null) return;

    // 指示か実績か（デフォルト：実績）
    const indRstClass =
      dispClass === "1" || (dispClass === "0" && rstDialysisState === "0")
        ? "ind"
        : "rst";

    // カテゴリキー生成  同日複数治療は治療単位で表示するためindex付与
    const layoutCategoryKeyWithOrdNo = layoutCategoryKey + '--' + ordNo;
    // レイアウトが実績指定で実績になっていない場合は処理スキップ
    const skip = indRstClass === "rst" && rstDialysisState === "0";
    // カテゴリタイトル生成  出力イメージ: HD 午前 ベッド001 10:00～
    // レイアウトが実績指定で実績になっていない場合、カテゴリタイトルには指示データを表示
    const indRstClassForHeader = skip ? "ind" : indRstClass;
    const layoutCategoryTitle = buildTreatPlanTitle(treatEvent, mst, indRstClassForHeader);

    // subCategory毎にカレンダー表示内容生成
    if (!skip) {
      categoryItem.forEach(sub => {
        // 治療予定（治療条件、スケジュール）
        if (SUB_CATEGORY_NO.TREAT_PLAN === sub.subCategoryNo) {
          addTreatCondInfoToCalendar (
            sub.subCategoryItem,
            calendarContents,
            treatEvent,
            mst,
            layoutCategoryKeyWithOrdNo,
            layoutCategoryTitle,
            isDispGroup,
            indRstClass,
            physicalInfoJSON
          )
        }
        // 投与薬剤
        if (SUB_CATEGORY_NO.MEDI_INFO === sub.subCategoryNo) {
          addTreatMediInfoToCalendar(
            calendarContents,
            treatEvent,
            mst,
            layoutCategoryKeyWithOrdNo,
            layoutCategoryTitle,
            isDispGroup,
            indRstClass
          );
        }
        // 医療材料
        if (SUB_CATEGORY_NO.EQUIP_INFO === sub.subCategoryNo) {
          addTreatEquipInfoToCalendar(
            calendarContents,
            treatEvent,
            mst,
            layoutCategoryKeyWithOrdNo,
            layoutCategoryTitle,
            isDispGroup,
            indRstClass
          );
        }
        // 指示コメント
        if (SUB_CATEGORY_NO.IND_COMMENT === sub.subCategoryNo) {
          addTreatIndCommentInfoToCalendar(
            calendarContents,
            treatEvent,
            layoutCategoryKeyWithOrdNo,
            layoutCategoryTitle,
            isDispGroup,
            indRstClass
          );
        }
        // 実績
        if (
          SUB_CATEGORY_NO.IND_COMMENT < sub.subCategoryNo &&
          SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_1_1 > sub.subCategoryNo
        ) {
          addRstInfoToCalendar(
            sub.subCategoryItem,
            calendarContents,
            treatEvent,
            layoutCategoryKeyWithOrdNo,
            layoutCategoryTitle,
            isDispGroup
          );
        }

        // バイタル・モニタグラフ
        if (VITAL_MONITOR_KEYS.includes(sub.dataKey)) {
          addRstVitalmonitorInfoToCalendar(
            sub.dataKey,
            calendarContents,
            layoutCategoryKeyWithOrdNo,
            layoutCategoryTitle,
            isDispGroup,
            treatDate,
            ordNo,
            vitalInfoDataList
          );
        }

      });
    }

    // 親表示ありでカレンダー内容が空の場合は、親のみ表示したいのでダミーを追加
    if (isDispGroup && ordNo != null) {
      const day = calendarContents.find(c => c.date === treatDate);
      const exists = day?.items?.some(
        item => item.layoutCategoryKey === layoutCategoryKeyWithOrdNo
      );
      // 存在しなければダミーを追加
      if (!exists) {
        const calendarContent = {
          content: layoutCategoryTitle,
          routerLink: indRstClass === "rst" ? ROUTERLINK_TREATMENTRECORD : ROUTERLINK_PATVIEWER,
          indRstClass: indRstClassForHeader,
          layoutCategoryKey: layoutCategoryKeyWithOrdNo,
          layoutCategoryTitle,
          ordNo: ordNo,
          isDispGroup,
          isDummy: true,
          facility_cd: treatEvent.facility_cd
        };
        addContentToCalendar(
          calendarContents,
          treatDate,
          calendarContent
        );
      }

    }

  }
};

/**
 * @description 治療予定のカテゴリ名生成
 * - [治療方法][半角スペース][クール][半角スペース][ベッド名][半角スペース][治療開始時刻]～[治療終了時刻]
 * - RDS＝0の場合は指示データから表示(名称はマスタ引用必要)
 * - RDS＝1の場合は実績データから表示(ord_main内の名称を使う)
 * - RDS＝0の場合治療終了時刻はなし
 * - RDS＝0の場合治療開始時刻はord_main.ind_treat_start_time
 * @param {Array} treatEvent 治療情報データ
 * @param {Object} mst
 * @param {String} indRstClass 指示か実績か
 * @return 治療予定のカテゴリタイトル
 */
const buildTreatPlanTitle = (
  treatEvent,
  mst,
  indRstClass
) => {

  const build = (cls) => {
    let value, key, treatmentName, kurName, bedName, startTime, endTime;

    // 治療方法
    key = `${cls}TreatmentName`;
    treatmentName = treatEvent[key];
    if (!treatmentName) {
      // 名称未展開の場合はマスタから名称取得
      const keyCd = `${cls}TreatmentCd`;
      treatmentName = mstCodeToName(mst.treatmentIncludeDeleted, treatEvent[keyCd], false, "treatmentCd", "treatmentName");
    }

    // クール
    key = `${cls}KurName`;
    kurName = treatEvent[key];
    if (!kurName) {
      // 名称未展開の場合はマスタから名称取得
      const keyCd = `${cls}KurCd`;
      value = treatEvent[keyCd];
      kurName = value !== 0 ? mstCodeToName(mst.kurIncludeDeleted, value, false, "kurCd", "kurName") : "クール未登録";
    }

    // ベッド名
    key = `${cls}BedName`;
    bedName = treatEvent[key];
    if (!bedName) {
      // 名称未展開の場合はマスタから名称取得
      const keyCd = `${cls}BedCd`;
      value = treatEvent[keyCd];
      bedName = value !== 0 ? mstCodeToName(mst.bedIncludeDeleted, value, false, "bedCd", "bedName") : "ベッド未登録";
    }

    if (cls === "ind") {
      // 治療開始時刻
      value = treatEvent[LAYOUT_ITEM_INDINFO_STARTTIME.key];
      startTime = formatTimeString(value);
    }

    if (cls === "rst") {
      // 治療開始日時
      value = treatEvent[LAYOUT_ITEM_RSTINFO_STARTDATE.key];
      startTime = value ? dayjs(value).format("HH:mm") : "";
      // 治療終了日時
      value = treatEvent[LAYOUT_ITEM_RSTINFO_ENDDATE.key];
      endTime = value ? dayjs(value).format("HH:mm") : "";
    }

    return [
      treatmentName,
      kurName,
      bedName,
      startTime || endTime
        ? `${startTime ?? ""}～${endTime ?? ""}`
        : null
    ].filter(Boolean);
  };

  // 引数で指定された ind / rst でカテゴリ名を生成
  let result = build(indRstClass);

  return result.join(" ");
};

/**
 * @description 治療条件、スケジュールをカレンダーに追加
 * @param {Array} layoutItems レイアウト項目配列
 * @param {Array} calendarContents 全てのカレンダー内容を保持する配列
 * @param {Array} treatCondEvent 治療情報データ
 * @param {Object} mst
 * @param {String} layoutCategoryKey カテゴリキー
 * @param {String} layoutCategoryTitle カテゴリ名
 * @param {String} isDispGroup 親要素のチェック存在有無
 * @param {String} indRstClass 指示か実績か
 * @param {Array} physicalInfoJSON 身体情報JSON
 */
const addTreatCondInfoToCalendar = (
  layoutItems,
  calendarContents,
  treatCondEvent,
  mst,
  layoutCategoryKey,
  layoutCategoryTitle,
  isDispGroup,
  indRstClass,
  physicalInfoJSON
) => {
  // 治療条件から指定レイアウト項目を取り出しカレンダーに追加していく
  const mstTabooAllergy = mst.mstTabooAllergy;
  const allData = mst.mstMedicineIncludeDeleted;
  const allMData = mst.mstMedicineMixIncludeDeleted;
  const allEData = mst.mstEquipmentIncludeDeleted;
  const allDData = mst.mstDialyzerIncludeDeleted;
  const getFacilityCd = store.getters["user/getFacilityCd"];

  const { rstDialysisState, indCondInfoJSON, rstCondInfoJSON, indDw, rstDw, treatDate, facility_cd } = treatCondEvent;

  let otherAllData = allData;
  let otherAllMData = allMData;
  if (facility_cd !== getFacilityCd) {
    otherAllData = mst.otherMST?.mstMedicineIncludeDeleted ?? [];
    otherAllMData = mst.otherMST?.mstMedicineMixIncludeDeleted ?? [];
  }

  /**【分類不一致】判定に使用するMap生成 */
  let equipmentMap = new Object;
  let equipmentClassMap = new Object;
  // 医療材料分類マスタ
  mst.equipmentClass.forEach(function(everyEquipmentClass){
    if(everyEquipmentClass.classType != undefined){
      equipmentClassMap[everyEquipmentClass.classCd] = everyEquipmentClass.classType;
    }
  });
  // 医療材料マスタ（削除済み含む）
  allEData.forEach(function(everyEquipment){
    equipmentMap[everyEquipment.equipmentCd] = new Object;
    equipmentMap[everyEquipment.equipmentCd]["classCd"] = everyEquipment.classCd;
    equipmentMap[everyEquipment.equipmentCd]["classType"] = equipmentClassMap[everyEquipment.classCd];
  });
  let medicineMap = new Object;
  let medicineClassMap = new Object;
  // 薬剤分類マスタ
  mst.medicineClass.forEach(function(everyMedicineClass){
    if(everyMedicineClass.classType != undefined){
      medicineClassMap[everyMedicineClass.classCd] = everyMedicineClass.classType;
    }
  });
  // 薬剤マスタ（削除済み含む）
  allData.forEach(function(everyMedicine){
    medicineMap[everyMedicine.medicineCd] = new Object;
    medicineMap[everyMedicine.medicineCd]["classCd"] = everyMedicine.classCd;
    medicineMap[everyMedicine.medicineCd]["classType"] = medicineClassMap[everyMedicine.classCd];
  });
  // 治療方法（削除済み含む）
  let treatmentMap = new Object;
  mst.treatmentIncludeDeleted.forEach(function(everyTreatment){
    treatmentMap[everyTreatment.treatmentCd] = everyTreatment.deviceMode;
  });

  // デフォルト（実績）
  let treatCondInfoJSON = rstCondInfoJSON;
  let routerLink = ROUTERLINK_TREATMENTRECORD;
  if (indRstClass === "ind") {
    // 指示
    treatCondInfoJSON = indCondInfoJSON;
    routerLink = ROUTERLINK_PATVIEWER;
  }

  for (const { itemNo, itemKey: layoutItemKey } of layoutItems) {
    const itemKey = String(itemNo);

    /** スケジュール表示内容生成 */
    if (layoutItemKey) {
      addScheduleInfoToCalendar(
        layoutItemKey,
        calendarContents,
        treatCondEvent,
        mst,
        layoutCategoryKey,
        layoutCategoryTitle,
        isDispGroup,
        indRstClass
      );
      continue;
    }

    if (!treatCondInfoJSON) {
      // 治療条件なし
      continue;
    }
    const treatCondInfo = JSON.parse(treatCondInfoJSON);

    // DW、穿刺針、抗凝固剤総量は治療条件のキー項目ではないので除外
    if (itemKey !== LAYOUT_ITEM_TREATCONDINFO_DW.key &&
        itemKey !== LAYOUT_ITEM_TREATCONDINFO_105.key &&
        itemKey !== LAYOUT_ITEM_TREATCONDINFO_106.key &&
        !treatCondInfo[itemKey]) {
      continue;
    }
    /** 治療条件項目表示内容生成 */
    const value = treatCondInfo[itemKey]?.value;
    let name = "";
    let unit = "";
    let prefix = "";
    if(treatCondInfo[itemKey]?.value_name_1 != null || treatCondInfo[itemKey]?.value_name_1 != undefined){
      name = treatCondInfo[itemKey].value_name_1;
    }
    if(treatCondInfo[itemKey]?.unit != null || treatCondInfo[itemKey]?.unit != undefined){
      unit = treatCondInfo[itemKey].unit;
    }

    let content = value;

    //add #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240520 start
    let record;
    let decPoint;
    switch (itemKey) {
      case LAYOUT_ITEM_TREATCONDINFO_17.key:
        record = allData.find(d => d.medicineCd == treatCondInfo[15].value);
        if (record) {
          decPoint = record.unitDecimalPointSecond;
          content = getValueWithDecPointInMst(decPoint, rstDialysisState, value);
        }
        break;
      case LAYOUT_ITEM_TREATCONDINFO_22.key:
        record = allData.find(d => d.medicineCd == treatCondInfo[19].value);
        if (record) {
          decPoint = record.unitDecimalPointSecond;
          content = getValueWithDecPointInMst(decPoint, rstDialysisState, value);
        }
        break;
      case LAYOUT_ITEM_TREATCONDINFO_26.key:
      case LAYOUT_ITEM_TREATCONDINFO_27.key:
      case LAYOUT_ITEM_TREATCONDINFO_28.key:
        //mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240424 start
        if(treatCondInfo[25].medicine_type == "2"){
          record = otherAllMData.find(d => d.medicineMixCd == treatCondInfo[25].value);
          if (record) {
            decPoint = record.unitDecimalPoint;
            content = getValueWithDecPointInMst(decPoint, rstDialysisState, value);
          }
        }else{
          record = otherAllData.find(d => d.medicineCd == treatCondInfo[25].value);
          if (record) {
            decPoint = record.unitDecimalPoint;
            content = getValueWithDecPointInMst(decPoint, rstDialysisState, value);
          }
        }
        //mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240424 end
        break;
      case LAYOUT_ITEM_TREATCONDINFO_106.key: // 抗凝固剤総量

        // キーなしの場合は表示しない
        if (!treatCondInfo[LAYOUT_ITEM_TREATCONDINFO_25.key]) continue;

        // 抗凝固剤持続総量＋抗凝固剤ワンショット量。負の値の場合0、計算パラーメータの欠落やnullは0代入で計算する
        if (treatCondInfo[LAYOUT_ITEM_TREATCONDINFO_25.key].medicine_type == "2") {
          record = otherAllMData.find(d => d.medicineMixCd == treatCondInfo[LAYOUT_ITEM_TREATCONDINFO_25.key].value);
        } else {
          record = otherAllData.find(d => d.medicineCd == treatCondInfo[LAYOUT_ITEM_TREATCONDINFO_25.key].value);
        }
        decPoint = record ? record.unitDecimalPoint : 0;
        // null → 0
        const v26 = Number(treatCondInfo[LAYOUT_ITEM_TREATCONDINFO_26.key]?.value) || 0;
        const v28 = Number(treatCondInfo[LAYOUT_ITEM_TREATCONDINFO_28.key]?.value) || 0;
        // 総量（マイナスは 0）
        const total = Math.max(0, v26 + v28);
        // 小数部桁数補正
        content = getValueWithDecPointInMst(decPoint, 0, total);
        break;
    }
    //add #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240520 end

    // add FNSI-患者日历顯示調整 関 start
    if (
      itemKey === LAYOUT_ITEM_TREATCONDINFO_31.key ||
      itemKey === LAYOUT_ITEM_TREATCONDINFO_32.key ||
      itemKey === LAYOUT_ITEM_TREATCONDINFO_33.key
    ) {
      if (content) {
        // mod #9239 2023/09/09 文字列時で小数点制御でエラー 朴 start
        // content = content.toFixed(1);
        content = Number(content).toFixed(1);
        // mod #9239 2023/09/09 文字列時で小数点制御でエラー 朴 end
      }
    }
    // add FNSI-患者日历顯示調整 関 end
    let title = "";
    let needunit = true;

    switch (itemKey) {
      case LAYOUT_ITEM_TREATCONDINFO_1.key:
        // 単位非表示
        unit = "";
        if (value) {
          // 分を時間換算
          const totalMinutes = Number(value);
          const hours = Math.floor(totalMinutes / 60);
          const minutes = `${Math.abs(totalMinutes % 60)}`.padStart(2, "0");
          content = `${hours}:${minutes}`;  // h:mm
          needunit = false;
        }
        break;

      case LAYOUT_ITEM_TREATCONDINFO_2.key:
        if (!name) {
          // 名称未展開の場合はコードからマスタ名称取得
          name = mstCodeToName(mst.vaIncludeDeleted, value, false, "vaCd", "vaName");
        }
        content = name;
        needunit = false;
        break;

      case LAYOUT_ITEM_TREATCONDINFO_DW.key:

        // キーなしの場合は表示しない
        // DWは治療条件にキー存在しないので目標体重のキー有無で判定
        if (!treatCondInfo[LAYOUT_ITEM_TREATCONDINFO_3.key]) continue;

        content = indRstClass === "ind" ? indDw : rstDw;
        if (
          indRstClass === "ind" &&
          content == null &&
          physicalInfoJSON
        ) {
          // indDwが取得できない場合は身体情報から治療日最直近のDWを取得
          const limitDate = dayjs(treatCondEvent.treatDate, "YYYYMMDD").add(1, "day");
          const physicalInfoAll = JSON.parse(physicalInfoJSON);

          const listFacilityCd = treatCondEvent.facility_cd;
          for (const { exam_date, dw, facility_cd } of physicalInfoAll) {
            if (
              exam_date &&
              dayjs(exam_date).isBefore(limitDate) &&
              dw != null &&
              facility_cd &&
              facility_cd === listFacilityCd
            ) {
              content = dw;
              break;
            }
          }
        }
        title = LAYOUT_ITEM_TREATCONDINFO_DW.title;
        unit = "kg";
        break;

      case LAYOUT_ITEM_TREATCONDINFO_3.key:
        // 目標体重 ≠ -1(DWと同じ)の場合
        if (content != -1) {
          // 小数点下二桁の表示
          content = content ? Number(content).toFixed(2) : null;
          unit = "kg";
        } else {
          content = "DWと同じ";
          needunit = false;
        }
        break;

      case LAYOUT_ITEM_TREATCONDINFO_4.key:
        unit = "L";
        break;

      case LAYOUT_ITEM_TREATCONDINFO_5.key:
        // 単位は非表示
        unit = "";

        // 名称未展開の場合は各種チェック実施 ※名称展開済の場合はprefix付で登録されている
        if (!name) {
          // 名称未展開の場合はコードからマスタ名称取得
          if (facility_cd !== getFacilityCd) {
            name = treatCondInfo[itemKey]?.disp_name;
          } else {
            name = mstCodeToName(
              allDData,
              value,
              false,
              "dialyzerCd",
              "modelNumber"
            );
          }
          // 名称未展開の場合は禁忌ｱﾚﾙｷﾞｰ、期限切れの接頭辞を付与
          prefix = getDisplayPrefix(
            value,
            treatDate,
            allDData,
            "dialyzerCd",
            mstTabooAllergy
          );
          if (facility_cd !== getFacilityCd && mst.getOtherPatTabooAllergy?.length) {
            const otherTabooAllergyInfo = mst.getOtherPatTabooAllergy.find(item => item.cd == value);
            if (otherTabooAllergyInfo) {
              prefix = getTabooAllergyPrefixNew(otherTabooAllergyInfo.taboo, otherTabooAllergyInfo.allergy);
            }
          }
        }
        content = name ? `${prefix}${name}` : null;
        needunit = false;
        break;

      case LAYOUT_ITEM_TREATCONDINFO_6.key:
      case LAYOUT_ITEM_TREATCONDINFO_7.key:
      case LAYOUT_ITEM_TREATCONDINFO_8.key:
        // 単位は非表示
        unit = "";

        // 名称未展開の場合は各種チェック実施 ※名称展開済の場合はprefix付で登録されている
        if (!name) {
          // 名称未展開の場合はコードからマスタ名称取得
          name = mstCodeToName(
            allEData,
            value,
            false,
            "equipmentCd",
            "equipmentName"
          );
          // 名称未展開の場合は禁忌ｱﾚﾙｷﾞｰ、期限切れの接頭辞を付与
          prefix = getDisplayPrefix(
            value,
            treatDate,
            allEData,
            "equipmentCd",
            mstTabooAllergy,
            itemKey,
            equipmentMap
          );
          if (facility_cd !== getFacilityCd && mst.getOtherPatTabooAllergy?.length) {
            const otherTabooAllergyInfo = mst.getOtherPatTabooAllergy.find(item => item.cd == value);
            if (otherTabooAllergyInfo) {
              prefix = getTabooAllergyPrefixNew(otherTabooAllergyInfo.taboo, otherTabooAllergyInfo.allergy);
            }
          }
        }
        content = name ? `${prefix}${name}` : null;
        needunit = false;
        break;

      case LAYOUT_ITEM_TREATCONDINFO_105.key:

        // キーなしの場合は表示しない
        if (!treatCondInfo[LAYOUT_ITEM_TREATCONDINFO_12.key]) continue;

        // シングルニードル使用有無
        const snVal = treatCondInfo[LAYOUT_ITEM_TREATCONDINFO_12.key].value;
        // シングルニードル使用しない：A針、V針の2行表示、使用する：SNの1行表示
        const NEEDLE_LIST = (snVal == 1)
          ? [
              {
                itemKey: LAYOUT_ITEM_TREATCONDINFO_11.key,
                classType: 3,
                label: LAYOUT_ITEM_TREATCONDINFO_11.title
              }
            ]
          : [
              {
                itemKey: LAYOUT_ITEM_TREATCONDINFO_9.key,
                classType: 2,
                label: LAYOUT_ITEM_TREATCONDINFO_9.title
              },
              {
                itemKey: LAYOUT_ITEM_TREATCONDINFO_10.key,
                classType: 2,
                label: LAYOUT_ITEM_TREATCONDINFO_10.title
              }
            ];

        NEEDLE_LIST.forEach(({ itemKey, classType, label }) => {
          let content = "";
          let title = label;
          let name = "";

          const value = treatCondInfo[itemKey]?.value;

          // -----------------------------
          // 未登録 or 内容生成
          // -----------------------------
          if (value == null) {
            content = `${title} 未登録`;
          } else {
            // 名称未展開の場合は各種チェック実施 ※名称展開済の場合はprefix付で登録されている
            if (!name) {
              // 名称未展開の場合はコードからマスタ名称取得
              name = mstCodeToName(
                allEData,
                value,
                false,
                "equipmentCd",
                "equipmentName"
              );
              if (treatCondEvent.readOnly) {
                if (treatCondInfo[itemKey].disp_name && treatCondEvent.rstDialysisState == 0) {
                  name = treatCondInfo[itemKey].disp_name;
                } else if (treatCondInfo[itemKey].value_name_1) {
                  name = treatCondInfo[itemKey].value_name_1;
                }
              }
              // 分類不一致、禁忌ｱﾚﾙｷﾞｰ、期限切れのチェック
              prefix = getDisplayPrefix(
                value,
                treatDate,
                allEData,
                "equipmentCd",
                mstTabooAllergy,
                itemKey,
                equipmentMap,
                classType
              );
              if (facility_cd !== getFacilityCd && mst.getOtherPatTabooAllergy?.length) {
                const otherTabooAllergyInfo = mst.getOtherPatTabooAllergy.find(item => item.cd == value);
                const hasAnyPrefix =
                  (name || "").includes(ALLERGY_CLASS_PREFIX) ||
                  (name || "").includes(TABOO_ALLERGY_CLASS_PREFIX) ||
                  (name || "").includes(TABOO_CLASS_PREFIX);
                if (otherTabooAllergyInfo && !hasAnyPrefix) {
                  prefix = getTabooAllergyPrefixNew(otherTabooAllergyInfo.taboo, otherTabooAllergyInfo.allergy);
                }
              }
            }
            content = `${title} ${prefix}${name}`;
          }

          // -----------------------------
          // content 生成
          // -----------------------------
          const calendarContent = {
            content: content,
            routerLink,
            readOnly: treatCondEvent.readOnly,
            indRstClass,
            layoutCategoryKey,
            layoutCategoryTitle,
            ordNo: treatCondEvent.ordNo,
            isDispGroup,
            facility_cd
          };

          addContentToCalendar(
            calendarContents,
            treatCondEvent.treatDate,
            calendarContent
          );
        });
        continue; // 次のitemの処理へ

      case LAYOUT_ITEM_TREATCONDINFO_13.key:
        // 単位は非表示
        unit = "";

        // 名称未展開の場合は各種チェック実施 ※名称展開済の場合はprefix付で登録されている
        if (!name) {
          // 名称未展開の場合はコードからマスタ名称取得
          if (facility_cd !== getFacilityCd) {
            name = treatCondInfo[itemKey]?.disp_name;
          } else {
            name = mstCodeToName(
              allEData,
              value,
              false,
              "equipmentCd",
              "equipmentName"
            );
          }
          // 分類不一致、禁忌ｱﾚﾙｷﾞｰ、期限切れのチェック
          prefix = getDisplayPrefix(
            value,
            treatDate,
            allEData,
            "equipmentCd",
            mstTabooAllergy,
            itemKey,
            equipmentMap
          );
          if (facility_cd !== getFacilityCd && mst.getOtherPatTabooAllergy?.length) {
            const otherTabooAllergyInfo = mst.getOtherPatTabooAllergy.find(item => item.cd == value);
            if (otherTabooAllergyInfo) {
              prefix = getTabooAllergyPrefixNew(otherTabooAllergyInfo.taboo, otherTabooAllergyInfo.allergy);
            }
          }
        }
        content = name ? `${prefix}${name}` : null;
        needunit = false;
        break;

      case LAYOUT_ITEM_TREATCONDINFO_12.key:
        content = mstCodeToName(PSEUDO_MST_INDCOND_USE, value, true);
        break;

      case LAYOUT_ITEM_TREATCONDINFO_14.key:
      case LAYOUT_ITEM_TREATCONDINFO_16.key:
        unit = "mL/min";
        break;

      case LAYOUT_ITEM_TREATCONDINFO_15.key:
      case LAYOUT_ITEM_TREATCONDINFO_19.key:
      case LAYOUT_ITEM_TREATCONDINFO_25.key:
        // 単位は非表示
        unit = "";

        if (!name) {
          const medicineType = treatCondInfo[itemKey].medicine_type;
          if (medicineType == 2) { // 調整薬剤
            // 名称未展開の場合はコードからマスタ名称取得
            name = mstCodeToName(
              allMData,
              value,
              false,
              "medicineMixCd",
              "medicineMixName"
            );

            // 調製薬剤配下薬剤の禁忌ｱﾚﾙｷﾞｰ、期限切れ、削除済みをチェックして接頭辞を付与
            const mixPrefix = getMixMedicinePrefix(
              value,
              treatDate,
              allMData,
              allData,
              mstTabooAllergy,
              itemKey,
              medicineMap,
              null,
              {
                treatCondEvent,
                treatmentMap
              }
            );
            if (mixPrefix) {
              // name に「【削除済み】」が含まれている場合、調整薬剤配下の薬剤の【削除済み含む】は除去
              if (name?.includes(DELETED_LABEL)) {
                prefix = mixPrefix.replace(DELETED_IN_LABEL, "");
              } else {
                prefix = mixPrefix;
              }
            }

          } else {  //通常薬剤

            // 名称未展開の場合はコードからマスタ名称取得
            if (facility_cd !== getFacilityCd) {
              name = treatCondInfo[itemKey]?.disp_name;
            } else {
              name = mstCodeToName(
                allData,
                value,
                false,
                "medicineCd",
                "medicineName"
              );
            }
            // 分類不一致、禁忌ｱﾚﾙｷﾞｰ、期限切れのチェック
            prefix = getDisplayPrefix(
              value,
              treatDate,
              allData,
              "medicineCd",
              mstTabooAllergy,
              itemKey,
              medicineMap,
              null,
              {
                treatCondEvent,
                treatmentMap
              }
            );
          }
        }
        if (facility_cd !== getFacilityCd && mst.getOtherPatTabooAllergy?.length) {
          const otherTabooAllergyInfo = mst.getOtherPatTabooAllergy.find(item => item.cd == value);
          if (otherTabooAllergyInfo) {
            prefix = getTabooAllergyPrefixNew(otherTabooAllergyInfo.taboo, otherTabooAllergyInfo.allergy);
          }
        }
        content = name ? `${prefix}${name}` : null;
        needunit = false;
        break;

      case LAYOUT_ITEM_TREATCONDINFO_17.key:
        if (!unit) {
          // 単位未展開の場合はコードからマスタ単位名取得
          const code =
            treatCondInfo[LAYOUT_ITEM_TREATCONDINFO_15.key].value;
          //mod 8385 患者カレンダー>治療指示に表示される数値の小数点以下表示桁が患者経過総合ビューアと異なる。 zhao start
          unit = mstCodeToUnitSecond(allData, code, "medicineCd");
          //mod 8385 患者カレンダー>治療指示に表示される数値の小数点以下表示桁が患者経過総合ビューアと異なる。 zhao end
        }
        break;

      case LAYOUT_ITEM_TREATCONDINFO_18.key:
      case LAYOUT_ITEM_TREATCONDINFO_23.key:
        unit = "℃";
        break;

      case LAYOUT_ITEM_TREATCONDINFO_20.key:
        unit = "L";
        break;

      case LAYOUT_ITEM_TREATCONDINFO_21.key:
        content = mstCodeToName(
          PSEUDO_MST_INDCOND_REPLENISHERSELECT,
          value,
          true
        );
        break;

      case LAYOUT_ITEM_TREATCONDINFO_22.key:
        if (!unit) {
          // 単位未展開の場合はコードからマスタ単位名取得
          const code =
            treatCondInfo[LAYOUT_ITEM_TREATCONDINFO_19.key].value;
          //mod 8385 患者カレンダー>治療指示に表示される数値の小数点以下表示桁が患者経過総合ビューアと異なる。 zhao start
          unit = mstCodeToUnitSecond(allData, code, "medicineCd");
          //mod 8385 患者カレンダー>治療指示に表示される数値の小数点以下表示桁が患者経過総合ビューアと異なる。 zhao end
        }
        break;

      case LAYOUT_ITEM_TREATCONDINFO_24.key:
        unit = "L/h";
        break;

      case LAYOUT_ITEM_TREATCONDINFO_26.key:
      case LAYOUT_ITEM_TREATCONDINFO_27.key:
      case LAYOUT_ITEM_TREATCONDINFO_28.key:
      case LAYOUT_ITEM_TREATCONDINFO_106.key:

         // キーなしの場合は表示しない
        if (!treatCondInfo[LAYOUT_ITEM_TREATCONDINFO_25.key]) continue;

        if (!unit) {
          //mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 start
          let medicineType = treatCondInfo[LAYOUT_ITEM_TREATCONDINFO_25.key].medicine_type;
          // 単位未展開の場合はコードからマスタ単位名取得
          const code = treatCondInfo[LAYOUT_ITEM_TREATCONDINFO_25.key].value;
          let unitTmp = "";
          if (medicineType == "2") {
            unitTmp = mstCodeToUnit(allMData, code, "medicineMixCd");
          } else {
            unitTmp = mstCodeToUnit(allData, code, "medicineCd");
          }
          if (unitTmp !== "") {
            unit = `${unitTmp}${itemKey === LAYOUT_ITEM_TREATCONDINFO_27.key ? "/h" : ""}`;
          } else {
            const getObj = treatCondInfo[LAYOUT_ITEM_TREATCONDINFO_25.key];
            const getUnit = getObj?.unit ?? getObj?.disp_unit;
            unit = getUnit ? getUnit : "";
          }
          //mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 end
        }
        break;

      case LAYOUT_ITEM_TREATCONDINFO_29.key:
        content = mstCodeToName(PSEUDO_MST_INDCOND_USE, value, true);
        break;

      case LAYOUT_ITEM_TREATCONDINFO_30.key:
      case LAYOUT_ITEM_TREATCONDINFO_34.key:
        content = mstCodeToName(PSEUDO_MST_INDCOND_IPSTART, value, true);
        break;

      case LAYOUT_ITEM_TREATCONDINFO_31.key:
        unit = "mL";
        break;

      case LAYOUT_ITEM_TREATCONDINFO_32.key:
      case LAYOUT_ITEM_TREATCONDINFO_33.key:
        unit = "mL/h";
        break;

      case LAYOUT_ITEM_TREATCONDINFO_35.key:
      case LAYOUT_ITEM_TREATCONDINFO_37.key:
        content = mstCodeToName(PSEUDO_MST_INDCOND_IPPOWER, value, true);
        break;

      case LAYOUT_ITEM_TREATCONDINFO_36.key:
      case LAYOUT_ITEM_TREATCONDINFO_38.key:
        unit = "分前";
        break;
    }

    switch (itemKey) {
      case LAYOUT_ITEM_TREATCONDINFO_1.key:
      case LAYOUT_ITEM_TREATCONDINFO_3.key:
      case LAYOUT_ITEM_TREATCONDINFO_4.key:
      case LAYOUT_ITEM_TREATCONDINFO_12.key:
      case LAYOUT_ITEM_TREATCONDINFO_14.key:
      case LAYOUT_ITEM_TREATCONDINFO_16.key:
      case LAYOUT_ITEM_TREATCONDINFO_17.key:
      case LAYOUT_ITEM_TREATCONDINFO_18.key:
      case LAYOUT_ITEM_TREATCONDINFO_20.key:
      case LAYOUT_ITEM_TREATCONDINFO_22.key:
      case LAYOUT_ITEM_TREATCONDINFO_23.key:
      case LAYOUT_ITEM_TREATCONDINFO_24.key:
      case LAYOUT_ITEM_TREATCONDINFO_26.key:
      case LAYOUT_ITEM_TREATCONDINFO_27.key:
      case LAYOUT_ITEM_TREATCONDINFO_28.key:
      case LAYOUT_ITEM_TREATCONDINFO_106.key:
      case LAYOUT_ITEM_TREATCONDINFO_29.key:
      case LAYOUT_ITEM_TREATCONDINFO_30.key:
      case LAYOUT_ITEM_TREATCONDINFO_31.key:
      case LAYOUT_ITEM_TREATCONDINFO_32.key:
      case LAYOUT_ITEM_TREATCONDINFO_33.key:
      case LAYOUT_ITEM_TREATCONDINFO_34.key:
      case LAYOUT_ITEM_TREATCONDINFO_35.key:
      case LAYOUT_ITEM_TREATCONDINFO_36.key:
      case LAYOUT_ITEM_TREATCONDINFO_37.key:
      case LAYOUT_ITEM_TREATCONDINFO_38.key:
        title = Def[`LAYOUT_ITEM_TREATCONDINFO_${itemKey}`].title;
        break;
    }

    // 「未登録」の場合に項目は表示しない
    // mod FNSI-患者日历顯示調整 関 start
    if (content === null || content === undefined || content == '未登録') {
      if (itemKey === LAYOUT_ITEM_TREATCONDINFO_DW.key) {
        title = LAYOUT_ITEM_TREATCONDINFO_DW.title + ' 未登録';
      } else {
        title = Def[`LAYOUT_ITEM_TREATCONDINFO_${itemKey}`].title + ' 未登録';
      }
      content = '';
      unit = '';
    }
    //add 8385患者カレンダー>治療指示に表示される数値の小数点以下表示桁が患者経過総合ビューアと異なる。zhao start
    if(title && content !== ""){
      if(title.indexOf("補液量")!=-1){
        if (value == -1) {
          content = "濾過率から算出";
          unit = "";
        } else {
          content =  Number(content).toFixed(1);
        }
      }
      if(title.indexOf("補液速度")!=-1){
        if (value == -1) {
          content = "濾過率から算出";
          unit = "";
        } else {
          content =  Number(content).toFixed(2);
        }
      }
      if(title.indexOf("DW")!=-1){
        content =  Number(content).toFixed(2);
      }
      if(title.indexOf("除水量制限")!=-1){
        content =  Number(content).toFixed(2);
      }
      if(title.indexOf("透析液温度")!=-1){
        content =  Number(content).toFixed(1);
      }
      if(title.indexOf("補液温度")!=-1){
        content =  Number(content).toFixed(1);
      }
    }
    //add 8385患者カレンダー>治療指示に表示される数値の小数点以下表示桁が患者経過総合ビューアと異なる。zhao end
    // mod FNSI-患者日历顯示調整 関 end
    let overunit = unit;
    if (!needunit) {
      overunit = "";
    } else if (treatCondEvent.facility_cd !== getFacilityCd) {
      if ((treatCondInfo[itemKey]?.disp_unit && treatCondEvent.rstDialysisState == 0) || indRstClass === "ind") {
        overunit = treatCondInfo[itemKey]?.disp_unit || unit;
        if (overunit === "Kg" && itemKey == 3) {
          overunit = "kg";
        }
      } else if (treatCondInfo[itemKey]?.unit && indRstClass === "rst") {
        overunit = treatCondInfo[itemKey]?.unit;
        if (overunit === "Kg" && itemKey == 3) {
          overunit = "kg";
        }
      }
    }

    if (itemKey == 2) {
      title = "";
    }

    let displayContent = content;
    if (treatCondEvent.facility_cd !== getFacilityCd) {
      if (treatCondInfo[itemKey]?.disp_name && treatCondEvent.rstDialysisState == 0) {
        const dispName = treatCondInfo[itemKey]?.disp_name ?? "";
        const otherInfo = mst.getOtherPatTabooAllergy?.find?.(item => item.cd == value) || {};
        const prefix = getTabooAllergyPrefixNew(otherInfo?.taboo, otherInfo?.allergy);
        const hasAnyPrefix =
          dispName.includes(ALLERGY_CLASS_PREFIX) ||
          dispName.includes(TABOO_ALLERGY_CLASS_PREFIX) ||
          dispName.includes(TABOO_CLASS_PREFIX);
        if (hasAnyPrefix) {
          displayContent = dispName;
        } else if (!displayContent) {
          displayContent = prefix + dispName;
        }
      } else if (treatCondInfo[itemKey]?.value_name_1) {
        displayContent = treatCondInfo[itemKey]?.value_name_1;
      }
    }

    if (content !== displayContent) {
      title = title.replace("未登録", "");
    }

    const overcontent = `${title ? `${title} ` : ""}${displayContent}${overunit || ""}`;
    const calendarContent = {
      content: overcontent,
      routerLink: routerLink,
      readOnly: treatCondEvent.readOnly,
      indRstClass: indRstClass,
      layoutCategoryKey,
      layoutCategoryTitle,
      ordNo: treatCondEvent.ordNo,
      isDispGroup,
      facility_cd: treatCondEvent.facility_cd
    };
    addContentToCalendar(
      calendarContents,
      treatCondEvent.treatDate,
      calendarContent
    );

  }
};

/**
 * @description スケジュールの全イベントをカレンダーに追加
 * @param {Array} layoutItemKey DBのカラム名
 * @param {Array} calendarContents 全てのカレンダー内容を保持する配列
 * @param {Array} treatScheduleEvent 治療情報データ
 * @param {Object} mst
 * @param {String} layoutCategoryKey カテゴリキー
 * @param {String} layoutCategoryTitle カテゴリ名
 * @param {String} isDispGroup 親要素のチェック存在有無
 */
const addScheduleInfoToCalendar = (
  layoutItemKey,
  calendarContents,
  treatScheduleEvent,
  mst,
  layoutCategoryKey,
  layoutCategoryTitle,
  isDispGroup,
  indRstClass
) => {
  // 治療情報から指定レイアウト項目を取り出しカレンダーに追加する
  // 指示 or 実績 のDBカラム名に変換 ※"rst"から始まる場合は変換しない
  const itemKey = _.camelCase(
    layoutItemKey.startsWith("rst")
      ? layoutItemKey
      : `${indRstClass}_${layoutItemKey}`
  );
  const routerLink = indRstClass === "ind" ? ROUTERLINK_PATVIEWER : ROUTERLINK_TREATMENTRECORD;

  let value = treatScheduleEvent[itemKey];
  let title, content, key;

  switch (layoutItemKey) {

    case LAYOUT_ITEM_INFO_TREATMENT.key:
      key = `${indRstClass}TreatmentName`;
      content = treatScheduleEvent[key];
      if (!content) {
        // 名称未展開の場合はマスタから名称取得
        const keyCd = `${indRstClass}TreatmentCd`;
        value = treatScheduleEvent[keyCd];
        // 治療方法は未登録ありえない
        content = mstCodeToName(mst.treatmentIncludeDeleted, value, false, "treatmentCd", "treatmentName");
      }
      break;

    case LAYOUT_ITEM_INFO_KUR.key:
      key = `${indRstClass}KurName`;
      content = treatScheduleEvent[key];
      if (!content) {
        // 名称未展開の場合はマスタから名称取得
        const keyCd = `${indRstClass}KurCd`;
        value = treatScheduleEvent[keyCd];
        content = value !== 0 ? mstCodeToName(mst.kurIncludeDeleted, value, false, "kurCd", "kurName") : "クール 未登録";
      }
      break;

    case LAYOUT_ITEM_INFO_STARTTIME.key:
      title = "開始";
      value = treatScheduleEvent[LAYOUT_ITEM_RSTINFO_STARTDATE.key];
      content = value ? dayjs(value).format("HH:mm") : null;
      if (indRstClass === "ind") {
        title = "開始予定";
        value = treatScheduleEvent[LAYOUT_ITEM_INDINFO_STARTTIME.key];
        content = formatTimeString(value);
      }
      if (value === null) {
        title = "開始予定";
        content = "未登録"
      }
      break;

    case LAYOUT_ITEM_RSTINFO_ENDDATE.key:
      if (indRstClass === "rst") {
        title = "終了";
        content = value ? dayjs(value).format("HH:mm") : null;
      }
      break;

    case LAYOUT_ITEM_INFO_BED.key:
      key = `${indRstClass}BedName`;
      content = treatScheduleEvent[key];
      if (!content) {
        // 名称未展開の場合はマスタから名称取得
        const keyCd = `${indRstClass}BedCd`;
        value = treatScheduleEvent[keyCd];
        content = value !== 0 ? mstCodeToName(mst.bedIncludeDeleted, value, false, "bedCd", "bedName") : "ベッド 未登録";
      }
      break;
  }

  // contentがnull、undefinedの項目は表示しない
  if (content === null || content === undefined) {
    return;
  }

  const calendarContent = {
    // mod  FNSI-治療ユニットによる表示内容 関 start
    content: `${title ? `${title} ` : ""}${content}`,
    // mod  FNSI-治療ユニットによる表示内容 関 end
    routerLink: routerLink,
    readOnly: treatScheduleEvent.readOnly,
    indRstClass: indRstClass,
    layoutCategoryKey,
    layoutCategoryTitle,
    ordNo: treatScheduleEvent.ordNo,
    isDispGroup,
    facility_cd: treatScheduleEvent.facility_cd
  };

  addContentToCalendar(
    calendarContents,
    treatScheduleEvent.treatDate,
    calendarContent
  );

};

// add FNSI5415-カレンダー内のセルの表示に時間がかかる 周 start
/**
 * @description バイタル・モニタグラフNのデータをカレンダーに追加
 * @param {String} dataKey レイアウト項目識別キー
 * @param {Array} calendarContents 全てのカレンダー内容を保持する配列
 * @param {String} layoutCategoryKey カテゴリキー
 * @param {String} layoutCategoryTitle カテゴリ名
 * @param {String} isDispGroup 親要素のチェック存在有無
 * @param {String} treatDate 治療日
 * @param {Number} ordNo
 * @param {Array} vitalDataList 治療日のバイタル・モニタグラフ表示データ（①～④）
 */
const addRstVitalmonitorInfoToCalendar = (
  dataKey,
  calendarContents,
  layoutCategoryKey,
  layoutCategoryTitle,
  isDispGroup,
  treatDate,
  ordNo,
  vitalDataList
) => {
  // 出力対象のバイタル・モニタデータを抽出 ※バイタル・モニタのデータが空の場合は出力しない
  const contents = vitalDataList
    .filter(v =>
      v.date === treatDate &&
      v.content.dataKey === dataKey &&
      v.content.ordNo === ordNo &&
      v.content.chartData.some(s => s.data.length > 0)
    )
    .map(v => ({
      date: v.date,
      content: {
        ...v.content,
        layoutCategoryKey,
        layoutCategoryTitle,
        isDispGroup
      }
    }));

  // バイタル・モニタグラフの表示内容生成
  contents.forEach(({ date, content }) => {
    addContentToCalendar(
      calendarContents,
      date,
      content
    );
  });

};

/**
 * @description 実績情報の全イベントをカレンダーに追加
 * @param {Array} layoutItems レイアウト項目配列
 * @param {Array} calendarContents 全てのカレンダー内容を保持する配列
 * @param {Array} rstEvent 治療情報(実績)イベント
 * @param {Object} mst
 * @param {String} layoutCategoryKey カテゴリキー
 * @param {String} layoutCategoryTitle カテゴリ名
 * @param {String} isDispGroup 親要素のチェック存在有無
 */
const addRstInfoToCalendar = (
  layoutItems,
  calendarContents,
  rstEvent,
  layoutCategoryKey,
  layoutCategoryTitle,
  isDispGroup
) => {
  if (rstEvent.rstDialysisState === "0") {
    // 治療状況が0(条件送信前)のときはカレンダーに何も表示しない
    return;
  }

  // key → title の対応表
  const titleMap = {
    [LAYOUT_ITEM_RSTINFO_DIALYSISCNT.key]: LAYOUT_ITEM_RSTINFO_DIALYSISCNT.title,
    [LAYOUT_ITEM_RSTINFO_DIALYSISTIME.key]: LAYOUT_ITEM_RSTINFO_DIALYSISTIME.title,
    // 実績：穿刺者情報
    [LAYOUT_ITEM_RSTINFO_PUNCTUREUSER1.key]: LAYOUT_ITEM_RSTINFO_PUNCTUREUSER1.title,
    [LAYOUT_ITEM_RSTINFO_PUNCTUREUSER2.key]: LAYOUT_ITEM_RSTINFO_PUNCTUREUSER2.title,
    // 実績：返血者情報
    [LAYOUT_ITEM_RSTINFO_RETURNUSER1.key]: LAYOUT_ITEM_RSTINFO_RETURNUSER1.title,
    [LAYOUT_ITEM_RSTINFO_RETURNUSER2.key]: LAYOUT_ITEM_RSTINFO_RETURNUSER2.title,
    // 実績：担当者情報
    [LAYOUT_ITEM_RSTINFO_CHARGEUSER1.key]: LAYOUT_ITEM_RSTINFO_CHARGEUSER1.title,
    [LAYOUT_ITEM_RSTINFO_CHARGEUSER2.key]: LAYOUT_ITEM_RSTINFO_CHARGEUSER2.title,
    // 実績：体重情報
    [LAYOUT_ITEM_RSTINFO_WEIGHTBEFORE.key]: LAYOUT_ITEM_RSTINFO_WEIGHTBEFORE.title,
    [LAYOUT_ITEM_RSTINFO_WEIGHTAFTER.key]: LAYOUT_ITEM_RSTINFO_WEIGHTAFTER.title,
    [LAYOUT_ITEM_RSTINFO_CTR.key]: LAYOUT_ITEM_RSTINFO_CTR.title,
    [LAYOUT_ITEM_RSTINFO_CTRMEASUREDATE.key]: LAYOUT_ITEM_RSTINFO_CTRMEASUREDATE.title,
    [LAYOUT_ITEM_RSTINFO_WATERREMOVALTARGET.key]: LAYOUT_ITEM_RSTINFO_WATERREMOVALTARGET.title,
    [LAYOUT_ITEM_RSTINFO_WATERREMOVALRST.key]: LAYOUT_ITEM_RSTINFO_WATERREMOVALRST.title,
    [LAYOUT_ITEM_RSTINFO_ADDWATERTOTAL.key]: LAYOUT_ITEM_RSTINFO_ADDWATERTOTAL.title,
    [LAYOUT_ITEM_RSTINFO_IHDFPLL.key]: LAYOUT_ITEM_RSTINFO_IHDFPLL.title,
    [LAYOUT_ITEM_RSTINFO_KTVMEASURE.key]: LAYOUT_ITEM_RSTINFO_KTVMEASURE.title,
    [LAYOUT_ITEM_RSTINFO_URR.key]: LAYOUT_ITEM_RSTINFO_URR.title,
    [LAYOUT_ITEM_RSTINFO_RECRCLRT_RATE.key]: LAYOUT_ITEM_RSTINFO_RECRCLRT_RATE.title,         // @再循環率
    [LAYOUT_ITEM_RSTINFO_RECRCLRT_BLDVL.key]: LAYOUT_ITEM_RSTINFO_RECRCLRT_BLDVL.title,       // @再循環率
    [LAYOUT_ITEM_RSTINFO_RECRCLRT_DATETIME.key]: LAYOUT_ITEM_RSTINFO_RECRCLRT_DATETIME.title, // @再循環率
    [LAYOUT_ITEM_RSTINFO_STTCVNSPRSSR.key]: LAYOUT_ITEM_RSTINFO_STTCVNSPRSSR.title,
    [LAYOUT_ITEM_RSTINFO_IAPRT.key]: LAYOUT_ITEM_RSTINFO_IAPRT.title,
    // 前血圧
    [LAYOUT_ITEM_RSTINFO_PREBP.key]: LAYOUT_ITEM_RSTINFO_PREBP.title,
    // 後血圧
    [LAYOUT_ITEM_RSTINFO_POSTBP.key]: LAYOUT_ITEM_RSTINFO_POSTBP.title,
    // 体温
    [LAYOUT_ITEM_RSTINFO_TEMPERATURE.key]: LAYOUT_ITEM_RSTINFO_TEMPERATURE.title,
  };

  // 各日付の実績情報から指定レイアウト項目を取り出しカレンダーに追加していく
  for (const { itemKey: layoutItemKey } of layoutItems) {

    const title = titleMap[layoutItemKey] ?? "";
    const [dataKey, jsonKey, jsonKey2] = layoutItemKey != null ? layoutItemKey.split(":") : [];

    let value = rstEvent[layoutItemKey] ?? rstEvent[dataKey];
    let content = value !== "{}" ? value : null;
    let unit = "";
    switch (layoutItemKey) {
      case LAYOUT_ITEM_RSTINFO_INOUTCLASS.key:
        content = mstCodeToName(PSEUDO_MST_RSTINFO_INOUT, value, true);
        break;

      case LAYOUT_ITEM_RSTINFO_DIALYSISCNT.key:
        unit = "回";
        break;

      case LAYOUT_ITEM_RSTINFO_DIALYSISTIME.key:
        // 実績：治療開始日時、実績：治療終了日時から算出
        // 計算パラーメータの欠落やnullはデータなしとして行なし
        const start = rstEvent["rstStartDate"];
        const end = rstEvent["rstEndDate"];

        if (start && end) {
          const startMoment = dayjs(start);
          const endMoment   = dayjs(end);

          const diffMs = endMoment.diff(startMoment);
          if (diffMs >= 0) {
            const totalMinutes = Math.floor(diffMs / 60000);
            const hours = Math.floor(totalMinutes / 60);
            const minutes = totalMinutes % 60;
            content = hours + ":" + String(minutes).padStart(2, "0");
          }
        }
        break;

      case LAYOUT_ITEM_RSTINFO_WARD.key:
        break;

      case LAYOUT_ITEM_RSTINFO_COURSE.key:
        break;

      case LAYOUT_ITEM_RSTINFO_PUNCTUREUSER1.key:
      case LAYOUT_ITEM_RSTINFO_PUNCTUREUSER2.key:
      case LAYOUT_ITEM_RSTINFO_RETURNUSER1.key:
      case LAYOUT_ITEM_RSTINFO_RETURNUSER2.key:
      case LAYOUT_ITEM_RSTINFO_CHARGEUSER1.key:
      case LAYOUT_ITEM_RSTINFO_CHARGEUSER2.key:
        if (value) {
          const userInfo = JSON.parse(value);
          const lName = userInfo[`user_last_name_${jsonKey}`];
          const fName = userInfo[`user_first_name_${jsonKey}`];

          content =
            lName || fName
              ? [lName, fName].filter(v => v != null && v !== "").join(" ")
              : null;
        }
        break;

      case LAYOUT_ITEM_RSTINFO_WEIGHTBEFORE.key:
      case LAYOUT_ITEM_RSTINFO_WEIGHTAFTER.key:
      case LAYOUT_ITEM_RSTINFO_CTR.key:
      case LAYOUT_ITEM_RSTINFO_CTRMEASUREDATE.key:
      case LAYOUT_ITEM_RSTINFO_WATERREMOVALTARGET.key:
      case LAYOUT_ITEM_RSTINFO_WATERREMOVALRST.key:
      case LAYOUT_ITEM_RSTINFO_ADDWATERTOTAL.key:
      case LAYOUT_ITEM_RSTINFO_IHDFPLL.key:
      case LAYOUT_ITEM_RSTINFO_KTVMEASURE.key:
      case LAYOUT_ITEM_RSTINFO_URR.key:
      case LAYOUT_ITEM_RSTINFO_STTCVNSPRSSR.key:
      case LAYOUT_ITEM_RSTINFO_IAPRT.key:
        if (value) {
          const weightInfo = JSON.parse(value);
          content = weightInfo[jsonKey];
        }
        break;

      case LAYOUT_ITEM_RSTINFO_RECRCLRT_RATE.key:
      case LAYOUT_ITEM_RSTINFO_RECRCLRT_BLDVL.key:
      case LAYOUT_ITEM_RSTINFO_RECRCLRT_DATETIME.key:
        if (value && value !== "{}") {
          const weightInfo = JSON.parse(value);
          let jsonValue = weightInfo[jsonKey];
          // 有効値（チェックボックスON）を取得
          // jsonValue が {} の場合はスキップ
          if (!jsonValue || Object.keys(jsonValue).length === 0) {
            content = null;
          } else {
            const validNo = jsonValue.valid_no;
            const validItem = validNo != null
              ? jsonValue[String(validNo)] ?? null
              : null;
            content = validItem?.[jsonKey2];
          }
        }
        break;

      case LAYOUT_ITEM_RSTINFO_PREBP.key:
      case LAYOUT_ITEM_RSTINFO_POSTBP.key:
      case LAYOUT_ITEM_RSTINFO_TEMPERATURE.key:
        const mniMonitorList = rstEvent["mniMonitorList"];
        // 発生日時 昇順でソート
        mniMonitorList.sort((a, b) =>
          a.occur_date.localeCompare(b.occur_date)
        );

        // 血圧表示生成
        const createBpContent = (monitorData) => {
          const get = key => monitorData?.[key] ?? "-";
          return `${get(90)}/${get(91)}/${get(92)}　${get(93)}`;
        };

        // 透析前血圧
        if (layoutItemKey === LAYOUT_ITEM_RSTINFO_PREBP.key) {
          const item = mniMonitorList.findLast?.(v => v.data_type === 5)
                    ?? [...mniMonitorList].reverse().find(v => v.data_type === 5);
          if (item) {
            const monitorData = JSON.parse(item.monitor_data);
            content = createBpContent(monitorData);
          }
        }

        // 透析後血圧
        if (layoutItemKey === LAYOUT_ITEM_RSTINFO_POSTBP.key) {
          const item = mniMonitorList.findLast?.(v => v.data_type === 6)
                    ?? [...mniMonitorList].reverse().find(v => v.data_type === 6);
          if (item) {
            const monitorData = JSON.parse(item.monitor_data);
            content = createBpContent(monitorData);
          }
        }

        // 体温
        if (layoutItemKey === LAYOUT_ITEM_RSTINFO_TEMPERATURE.key) {
          const item = mniMonitorList
            .map(v => JSON.parse(v.monitor_data))
            .filter(obj => obj?.[94] !== undefined)
            .pop();
          content = item?.[94];
        }
        break;
    }

    // 「未登録」の場合に項目は表示しない
    if (content === null || content === undefined) {
      continue;
    }

    // 値の補正と単位設定
    switch (layoutItemKey) {
      case LAYOUT_ITEM_RSTINFO_WEIGHTBEFORE.key:
      case LAYOUT_ITEM_RSTINFO_WEIGHTAFTER.key:
        content =  Number(content).toFixed(2);
        unit = "kg";
        break;
      case LAYOUT_ITEM_RSTINFO_CTR.key:
      case LAYOUT_ITEM_RSTINFO_URR.key:
      case LAYOUT_ITEM_RSTINFO_RECRCLRT_RATE.key:
        content =  Number(content).toFixed(2);
        unit = "%";
        break;
      case LAYOUT_ITEM_RSTINFO_CTRMEASUREDATE.key:
        content =  formatDate(content, "YYYY/MM/DD");
        break;
      case LAYOUT_ITEM_RSTINFO_WATERREMOVALTARGET.key:
      case LAYOUT_ITEM_RSTINFO_WATERREMOVALRST.key:
      case LAYOUT_ITEM_RSTINFO_ADDWATERTOTAL.key:
      case LAYOUT_ITEM_RSTINFO_IHDFPLL.key:
        content =  Number(content).toFixed(2);
        unit = "L";
        break;
      case LAYOUT_ITEM_RSTINFO_KTVMEASURE.key:
        content =  Number(content).toFixed(2);
        break;
      case LAYOUT_ITEM_RSTINFO_RECRCLRT_BLDVL.key:
        unit = "mL/min";
        break;
      case LAYOUT_ITEM_RSTINFO_RECRCLRT_DATETIME.key:
        content =  formatDate(content, "YYYY/MM/DD HH:mm");
        break;
      case LAYOUT_ITEM_RSTINFO_STTCVNSPRSSR.key:
        unit = "mmHg";
        break;
      case LAYOUT_ITEM_RSTINFO_IAPRT.key:
        unit = "%";
        break;
      case LAYOUT_ITEM_RSTINFO_TEMPERATURE.key:
        content =  Number(content).toFixed(1);
        unit = "℃";
        break;
    }

    const calendarContent = {
      content: `${title ? `${title} ` : ""}${content}${unit}`,
      routerLink: ROUTERLINK_TREATMENTRECORD,
      readOnly: rstEvent.readOnly,
      indRstClass: "rst",
      layoutCategoryKey,
      layoutCategoryTitle,
      ordNo: rstEvent.ordNo,
      isDispGroup,
      facility_cd: rstEvent.facility_cd
    };
    addContentToCalendar(
      calendarContents,
      rstEvent.treatDate,
      calendarContent
    );

  }

};

/**
 * @description 投与薬剤の全イベントをカレンダーに追加
 * @param {Array} calendarContents 全てのカレンダー内容を保持する配列
 * @param {Array} treatEvent 治療情報データ
 * @param {Object} mst
 * @param {String} layoutCategoryKey カテゴリキー
 * @param {String} layoutCategoryTitle カテゴリ名
 * @param {String} isDispGroup 親要素のチェック存在有無
 * @param {String} indRstClass 指示か実績か
 */
const addTreatMediInfoToCalendar = (
  calendarContents,
  mediEvent,
  mst,
  layoutCategoryKey,
  layoutCategoryTitle,
  isDispGroup,
  indRstClass
) => {
  // 各日付の投与薬剤から指定レイアウト項目を取り出しカレンダーに追加していく
  const { indMediInfoJSON, rstMediInfoJSON, treatDate, facility_cd } = mediEvent;
  const mstTabooAllergy = mst.mstTabooAllergy;
  const allData = mst.mstMedicineIncludeDeleted;
  const allMData = mst.mstMedicineMixIncludeDeleted;
  const getFacilityCd = store.getters["user/getFacilityCd"];

  // デフォルト（実績）
  let treatMediInfoJSON = rstMediInfoJSON;
  let routerLink = ROUTERLINK_TREATMENTRECORD;
  if (indRstClass === "ind") {
    // 指示
    treatMediInfoJSON = indMediInfoJSON;
    routerLink = ROUTERLINK_PATVIEWER;
  }
  if (!treatMediInfoJSON) {
    return;
  }

  const treatMediInfo = JSON.parse(treatMediInfoJSON);

  for (let { cd, name, amount, unit, medicine_type, effect_flg, disp_name, disp_unit } of treatMediInfo) {
    let prefix = "";
    let effected = ""; // [投与済み■／未投与□]を付与

    if (!name) {
      // 名称未展開の場合はコードからマスタ名称取得

      if (medicine_type == 2) { // 調整薬剤
        if (facility_cd !== getFacilityCd) {
          name = disp_name;
          unit = disp_unit;
        } else {
          name = mstCodeToName(
            allMData,
            cd,
            false,
            "medicineMixCd",
            "medicineMixName"
          );
          unit = mstCodeToUnit(allMData, cd, "medicineMixCd");
        }
        allMData.forEach(function(everyMed){
          if (everyMed.medicineCd == cd) {
            amount = formatDecimalPoint(amount, everyMed.unitDecimalPoint);
          }
        });

        // 調製薬剤配下薬剤の禁忌ｱﾚﾙｷﾞｰ、期限切れ、削除済みをチェックして接頭辞を付与
        const mixPrefix = getMixMedicinePrefix(
          cd,
          treatDate,
          allMData,
          allData,
          mstTabooAllergy
        );
        if (mixPrefix) {
          // name に「【削除済み】」が含まれている場合、調整薬剤配下の薬剤の【削除済み含む】は除去
          if (name?.includes(DELETED_LABEL)) {
            prefix = mixPrefix.replace(DELETED_IN_LABEL, "");
          } else {
            prefix = mixPrefix;
          }
        }

      } else {  //通常薬剤

        if (facility_cd !== getFacilityCd) {
          name = disp_name;
          unit = disp_unit;
        } else {
          name = mstCodeToName(
            allData,
            cd,
            false,
            "medicineCd",
            "medicineName"
          );
          unit = mstCodeToUnit(allData, cd, "medicineCd");
        }
        // 名称未展開の場合は禁忌ｱﾚﾙｷﾞｰ、期限切れの接頭辞を付与
        prefix = getDisplayPrefix(
          cd,
          treatDate,
          allData,
          "medicineCd",
          mstTabooAllergy
        );
        allData.forEach(function(everyMed){
          if (everyMed.medicineCd == cd) {
            amount = formatDecimalPoint(amount, everyMed.unitDecimalPoint);
          }
        });
      }

      if (facility_cd !== getFacilityCd && mst.getOtherPatTabooAllergy?.length) {
        const otherTabooAllergyInfo = mst.getOtherPatTabooAllergy.find(item => item.cd == cd);
        if (otherTabooAllergyInfo) {
          prefix = getTabooAllergyPrefixNew(otherTabooAllergyInfo.taboo, otherTabooAllergyInfo.allergy);
        }

        if (medicine_type == 2) {
          const medicineMixData = mst.getOthetMstMixData?.find?.(item => item.medicineMixCd == cd);
          if (medicineMixData) {
            const mixInfo = JSON.parse(medicineMixData.mixInfo);
            let taboo = false;
            let allergy = false;
            for (const medicineData of mixInfo) {
              const tabooAllergyInfo = mst.getOtherPatTabooAllergy.find(item =>
                item.classType == "1" &&
                item.cd == medicineData.cd
              );

              if (tabooAllergyInfo) {
                if (tabooAllergyInfo.taboo) {
                  taboo = true;
                }
                if (tabooAllergyInfo.allergy) {
                  allergy = true;
                }
              }

              if (taboo && allergy) break;
            }
            if (taboo || allergy) {
              prefix = getTabooAllergyPrefixNew(taboo, allergy);
            }
          }
        }
      }

    } else {
      // 名称展開済（実績）の場合は頭に[投与済み■／未投与□]を付与
      effected = effect_flg ? "■" : "□";
    }

    const calendarContent = {
      content: `${effected}${prefix}${name} ${amount}${unit || ""}`,
      routerLink: routerLink,
      readOnly: mediEvent.readOnly,
      indRstClass: indRstClass,
      layoutCategoryKey,
      layoutCategoryTitle,
      ordNo: mediEvent.ordNo,
      isDispGroup,
      facility_cd
    };

    addContentToCalendar(
      calendarContents,
      mediEvent.treatDate,
      calendarContent
    );

  }

};

/**
 * @description 医療材料の全イベントをカレンダーに追加
 * @param {Array} calendarContents 全てのカレンダー内容を保持する配列
 * @param {Array} equipEvent 治療情報データ
 * @param {Object} mst
 * @param {String} layoutCategoryKey カテゴリキー
 * @param {String} layoutCategoryTitle カテゴリ名
 * @param {String} isDispGroup 親要素のチェック存在有無
 * @param {String} indRstClass 指示か実績か
 */
const addTreatEquipInfoToCalendar = (
  calendarContents,
  equipEvent,
  mst,
  layoutCategoryKey ,
  layoutCategoryTitle,
  isDispGroup,
  indRstClass
  ) => {
    // 各日付の医療材料から指定レイアウト項目を取り出しカレンダーに追加していく
    const { indEquipInfoJSON, rstEquipInfoJSON, facility_cd } = equipEvent;
    const mstTabooAllergy = mst.mstTabooAllergy;
    const allEData = mst.mstEquipmentIncludeDeleted;
    const allDData = mst.mstDialyzerIncludeDeleted;
    const getFacilityCd = store.getters["user/getFacilityCd"];

    // デフォルト（実績）
    let treatEquipInfoJSON = rstEquipInfoJSON;
    let routerLink = ROUTERLINK_TREATMENTRECORD;
    if (indRstClass === "ind") {
      // 指示
      treatEquipInfoJSON = indEquipInfoJSON;
      routerLink = ROUTERLINK_PATVIEWER;
    }
    if (!treatEquipInfoJSON) {
      return;
    }

    const treatEquipInfo = JSON.parse(treatEquipInfoJSON);

    for (let { cd, name, amount, unit, equip_type, disp_name, disp_unit } of treatEquipInfo) {

      let prefix = "";
      if (!name) {
        if(equip_type == 1){
          // ダイアライザ
          // 名称未展開の場合はコードからマスタ名称取得
          if (facility_cd !== getFacilityCd) {
            name = disp_name;
          } else {
            name = mstCodeToName(
              allDData,
              cd,
              false,
              "dialyzerCd",
              "modelNumber"
            );
          }
          // 禁忌ｱﾚﾙｷﾞｰ、期限切れのチェック
          prefix = getDisplayPrefix(
            cd,
            equipEvent.treatDate,
            allDData,
            "dialyzerCd",
            mstTabooAllergy
          );

          unit = "";
        }else{
          // 医療材料
          if (facility_cd !== getFacilityCd) {
            name = disp_name;
          } else {
            name = mstCodeToName(
              allEData,
              cd,
              false,
              "equipmentCd",
              "equipmentName"
            );
          }
          prefix = getDisplayPrefix(
            cd,
            equipEvent.treatDate,
            allEData,
            "equipmentCd",
            mstTabooAllergy
          );
          if (!unit) {
            // 単位未展開の場合はコードからマスタ単位名取得
            if (facility_cd !== getFacilityCd) {
              unit = disp_unit;
            } else {
              unit = mstCodeToUnit(allEData, cd, "equipmentCd");
            }
          }
        }
      }
      if (facility_cd !== getFacilityCd && mst.getOtherPatTabooAllergy?.length) {
        const otherTabooAllergyInfo = mst.getOtherPatTabooAllergy.find(item => item.cd == cd);
        if (otherTabooAllergyInfo) {
          prefix = getTabooAllergyPrefixNew(otherTabooAllergyInfo.taboo, otherTabooAllergyInfo.allergy);
        }
      }

      const calendarContent = {
        // 数量0のときamountにはnullが登録されているので0とする
        // mod  null ⇒ 袋、unitの値があり kang 2023/06/14 start
        content: `${prefix}${name} ${amount || 0}${unit==null ?"":unit}`,
        // mod kang 2023/06/14 end
        routerLink: routerLink,
        readOnly: equipEvent.readOnly,
        indRstClass: indRstClass,
        // add #8091 2023/03/14 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 start
        layoutCategoryKey,
        layoutCategoryTitle,
        // add #8091 2023/03/14 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 end
        ordNo: equipEvent.ordNo,
        isDispGroup,
        facility_cd
      };
      addContentToCalendar(
        calendarContents,
        equipEvent.treatDate,
        calendarContent
      );
    }

  };

/**
 * @description 指示コメントの全イベントをカレンダーに追加
 * @param {Array} calendarContents 全てのカレンダー内容を保持する配列
 * @param {Array} indCommentEvent 指示コメントイベント
 * @param {String} layoutCategoryKey カテゴリキー
 * @param {String} layoutCategoryTitle カテゴリ名
 * @param {String} isDispGroup 親要素のチェック存在有無
 * @param {String} indRstClass 指示か実績か
 */
const addTreatIndCommentInfoToCalendar = (
  calendarContents,
  indCommentEvent,
  layoutCategoryKey,
  layoutCategoryTitle,
  isDispGroup,
  indRstClass
) => {
  // 各日付の指示コメントから指定レイアウト項目を取り出しカレンダーに追加していく
  const { indIndCommentInfoJSON, rstIndCommentInfoJSON, facility_cd } = indCommentEvent;

  // デフォルト（実績）
  let treatIndCommentInfoJSON = rstIndCommentInfoJSON;
  let routerLink = ROUTERLINK_TREATMENTRECORD;
  if (indRstClass === "ind") {
    // 指示
    treatIndCommentInfoJSON = indIndCommentInfoJSON;
    routerLink = ROUTERLINK_PATVIEWER;
  }
  if (!treatIndCommentInfoJSON) {
    return;
  }

  const treatIndCommentInfo = JSON.parse(treatIndCommentInfoJSON);
  for (const { content } of treatIndCommentInfo) {
    if (content === null || content === undefined) {
      continue;
    }

    const calendarContent = {
      content: content,
      routerLink: routerLink,
      readOnly: indCommentEvent.readOnly,
      indRstClass: indRstClass,
      layoutCategoryKey,
      layoutCategoryTitle,
      ordNo: indCommentEvent.ordNo,
      isDispGroup,
      facility_cd
    };
    addContentToCalendar(
      calendarContents,
      indCommentEvent.treatDate,
      calendarContent
    );
  }

};

/**
 * @description 検査結果の全イベントをカレンダーに追加
 * @param {Array} calendarContents 全てのカレンダー内容を保持する配列
 * @param {Array} eventData 指示コメントイベント
 * @param {String} layoutCategoryKey カテゴリキー
 * @param {String} layoutCategoryTitle カテゴリ名
 */
const addExamInfoToCalendar = (
  calendarContents,
  eventData,
  // add #8091 2023/03/14 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 start
  layoutCategoryKey,
  layoutCategoryTitle
  // add #8091 2023/03/14 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 end
) => {
  for (const examCommentEvent of (eventData || [])) {
    const calendarContent = {
      content: "検査結果 あり",
      routerLink: ROUTERLINK_EXAMRECORD_DETAIL,
      readOnly: false,
      indRstClass: "other",
      // add #8091 2023/03/14 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 start
      layoutCategoryKey,
      layoutCategoryTitle,
      // add #8091 2023/03/14 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 end
      facility_cd: examCommentEvent.facility_cd
    };
    addContentToCalendar(
      calendarContents,
      examCommentEvent.strExamDate,
      calendarContent
    );
  }
};

/**
 * @description 検査予定の全イベントをカレンダーに追加
 * @param {Array} layoutItems レイアウト項目配列
 * @param {Array} calendarContents 全てのカレンダー内容を保持する配列
 * @param {Array} eventData 検査予定イベント
 * @param {String} layoutCategoryKey カテゴリキー
 * @param {String} layoutCategoryTitle カテゴリ名
 * @param {String} isDispGroup 親要素のチェック存在有無
 */
const addExamRequestInfoToCalendar = (
  layoutItems,
  calendarContents,
  eventData,
  // add #8091 2023/03/14 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 start
  layoutCategoryKey,
  layoutCategoryTitle,
  // add #8091 2023/03/14 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 end
  isDispGroup
) => {
  // データなしは表示しない
  if (!eventData || eventData.length === 0) return;

  // 検査セット名 表示あり
  const hasLayoutItems = layoutItems.length > 0;

  // 表示データを作成
  const displayEvents = hasLayoutItems
    ? (() => {
        /** 検査セット名 表示あり */
        // 検査依頼セット情報をフラット化
        const flatEventData = eventData.flatMap(event => {
          const sets = event.orderExamSetInfo
            ? JSON.parse(event.orderExamSetInfo)
            : [];

          return sets.map(set => ({
            ...event,
            setCd: set.set_cd,
            setName: set.set_name
          }));
        });

        // 検査日時 ＞ 検査区分 ＞ 検査セットコード
        const order = { "1": 0, "2": 1, "0": 2 };

        return flatEventData.sort((a, b) =>
          a.strExamDate.localeCompare(b.strExamDate) ||
          order[a.regOrderClass] - order[b.regOrderClass] ||
          a.setCd - b.setCd
        );
      })()
    : (() => {
        /** 検査セット名 表示なし */
        // strExamDate 単位で1件にまとめる
        const map = new Map();

        eventData.forEach(event => {
          if (!map.has(event.strExamDate)) {
            map.set(event.strExamDate, event);
          }
        });

        return [...map.values()];
      })();

  // トータル検査セット数
  const examDateCountMap = {};
  for (const event of eventData) {
    const key = event.strExamDate;
    const sets = event.orderExamSetInfo
      ? JSON.parse(event.orderExamSetInfo)
      : [];
    const count = sets.length;
    examDateCountMap[key] = (examDateCountMap[key] || 0) + count;
  }

  // カレンダーに追加
  for (const event of displayEvents) {
    const content = hasLayoutItems
      ? (() => {
          const orderCLassName = mstCodeToName(
            PSEUDO_MST_REG_ORDER_CLASS,
            event.regOrderClass,
            true
          );
          return `${event.setName}${orderCLassName}`;
        })()
      : `${layoutCategoryTitle} ${examDateCountMap[event.strExamDate]}セット`;

    const calendarContent = {
      content,
      routerLink: ROUTERLINK_EXAMREQUESTRECORD_DETAIL,
      indRstClass: "other",
      // add #8091 2023/03/14 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 start
      layoutCategoryKey,
      layoutCategoryTitle: `${layoutCategoryTitle} ${examDateCountMap[event.strExamDate]}セット`,
      // add #8091 2023/03/14 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 end
      isDispGroup: hasLayoutItems ? isDispGroup : false,
      facility_cd: event.facility_cd
    };

    addContentToCalendar(
      calendarContents,
      event.strExamDate,
      calendarContent
    );
  }
};

/**
 * @description 一般撮影検査予定の全イベントをカレンダーに追加
 * @param {Array} calendarContents 全てのカレンダー内容を保持する配列
 * @param {Array} eventData 一般撮影検査予定イベント
 * @param {String} layoutCategoryKey カテゴリキー
 * @param {String} layoutCategoryTitle カテゴリ名
 */
const addRadRequestInfoToCalendar = (
  calendarContents,
  eventData,
  // add #8091 2023/03/14 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 start
  layoutCategoryKey,
  layoutCategoryTitle
  // add #8091 2023/03/14 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 end
) => {

  // データなしは表示しない
  if (!eventData || eventData.length === 0) return;

  // トータル件数
  const radDateCountMap = {};
  for (const event of eventData) {
    const key = event.event_start_date;
    radDateCountMap[key] = (radDateCountMap[key] || 0) + 1;
  }

  for (const [date, count] of Object.entries(radDateCountMap)) {
    const calendarContent = {
      content: `一般撮影検査予定 あり ${count}件`,
      routerLink: ROUTERLINK_RADEQUESTRECORD_DETAIL,
      readOnly: false,
      indRstClass: "other",
      layoutCategoryKey,
      layoutCategoryTitle: `${layoutCategoryTitle} ${count}件`
    };

    addContentToCalendar(
      calendarContents,
      date,
      calendarContent
    );
  }
};

/**
 * @description 処方をカレンダーに追加
 * @param {Array} calendarContents 全てのカレンダー内容を保持する配列
 * @param {Array} eventData 処方データ
 * @param {String} layoutCategoryKey カテゴリキー
 * @param {String} layoutCategoryTitle カテゴリ名
 * @param {String} isDispGroup 親要素のチェック存在有無
 */
const addPrescriptionInfoToCalendar = (
  calendarContents,
  eventData,
  // add #8091 2023/03/14 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 start
  layoutCategoryKey,
  layoutCategoryTitle,
  // add #8091 2023/03/14 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 end
  isDispGroup
) => {

  if (!eventData || eventData.length === 0) return;

  for (const event of eventData) {

    const title = `${layoutCategoryTitle} ${event.allCount}件`;

    var calendarContent = null;
    if (event.inCount > 0) {
      calendarContent = {
        content: "院内処方: "+event.inOkCount+"/" +event.inCount +"件",
        routerLink: ROUTERLINK_PRESCRIPTIONRECORD_DETAIL,
        readOnly: false,
        indRstClass: "other",
        // add 2023/06/13 患者カレンダー 患者カレンダー画面で、処方表示不正 kang start
        layoutCategoryKey,
        layoutCategoryTitle: title,
        // add 2023/06/13 患者カレンダー 患者カレンダー画面で、処方表示不正 kang end
        isDispGroup,
        facility_cd: event.facility_cd
      };
      addContentToCalendar(
        calendarContents,
        event.eventStartDate,
        calendarContent
      );
    }
    if (event.outCount > 0) {
      calendarContent = {
        content: "院外処方: "+event.outOkCount+"/" +event.outCount +"件",
        routerLink: ROUTERLINK_PRESCRIPTIONRECORD_DETAIL,
        readOnly: false,
        indRstClass: "other",
        // add 2023/06/13 患者カレンダー 患者カレンダー画面で、処方表示不正 kang start
        layoutCategoryKey,
        layoutCategoryTitle: title,
        // add 2023/06/13 患者カレンダー 患者カレンダー画面で、処方表示不正 kang end
        isDispGroup,
        facility_cd: event.facility_cd
      };
      addContentToCalendar(
        calendarContents,
        event.eventStartDate,
        calendarContent
      );
    }

  }
};

/**
 * @description 患者イベントをカレンダーに追加
 * @param {Array} layoutItems レイアウト項目配列
 * @param {Array} calendarContents 全てのカレンダー内容を保持する配列
 * @param {Array} eventData 患者イベントデータ(サブカテゴリ単位で件数集計済)
 * @param {Object} mst
 * @param {String} layoutCategoryKey カテゴリキー
 * @param {String} layoutCategoryTitle カテゴリ名
 * @param {String} isDispGroup 親要素のチェック存在有無
 */
const addPatEventInfoToCalendar = (
  layoutItems,
  calendarContents,
  eventData,
  mst,
  // add #8091 2023/03/14 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 start
  layoutCategoryKey,
  layoutCategoryTitle,
  // add #8091 2023/03/14 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 end
  isDispGroup
) => {

  if (!eventData || eventData.length === 0) return;

  const layoutItemMap = new Map(
    layoutItems.map(item => [String(item.itemNo), item])
  );

  // 日付ごとの合計件数
  const totalCountByDate = new Map();
  // subCategoryCd ごとにまとめる
  const eventMap = new Map();
  for (const patEvent of eventData) {

    if (patEvent.subCategoryCount === 0) continue;

    const date = patEvent.eventStartDate;

    // ===== 日付ごとの合計件数 =====
    totalCountByDate.set(
      date,
      (totalCountByDate.get(date) ?? 0) + patEvent.subCategoryCount
    );

    const key = String(patEvent.subCategoryCd);

    if (patEvent.readonly == true) {
      const totalCount = totalCountByDate.get(patEvent.eventStartDate) ?? 0;
      const subCategoryName = patEvent.subCategoryName;
      const calendarContent = {
        content: `${subCategoryName}: ${patEvent.subCategoryCount}件`,
        routerLink: ROUTERLINK_PATEVENT,
        readOnly: false,
        categoryCd: `${patEvent.categoryCd}`,
        subCategoryCd: `${patEvent.subCategoryCd}`,
        indRstClass: "other",
        layoutCategoryKey: layoutCategoryKey,
        // ★ 日付ごとの子の件数
        layoutCategoryTitle: `${layoutCategoryTitle} ${totalCount}件`,
        isDispGroup: isDispGroup,
        facility_cd: patEvent.facility_cd
      };
      addContentToCalendar(
        calendarContents,
        patEvent.eventStartDate,
        calendarContent
      );
    } else {
      // layoutItems に存在しないものは対象外
      if (!layoutItemMap.has(key)) continue;
    }

    if (!eventMap.has(key)) {
      eventMap.set(key, []);
    }
    eventMap.get(key).push(patEvent);
  }

  // レイアウト項目で指定されたサブカテゴリ件数をカレンダーに追加
  for (const layoutItem of layoutItems) {

    const subCategoryCd = String(layoutItem.itemNo);
    const events = eventMap.get(subCategoryCd);
    if (!events) continue;

    const subCategoryName = mstCodeToName(
      mst.patEventSubCategoryIncludeDeleted,
      subCategoryCd,
      false,
      "subCategoryCd",
      "subCategoryName"
    );

    for (const patEvent of events) {

      const totalCount = totalCountByDate.get(patEvent.eventStartDate) ?? 0;

      const calendarContent = {
        content: `${subCategoryName}: ${patEvent.subCategoryCount}件`,
        routerLink: ROUTERLINK_PATEVENT,
        readOnly: false,
        categoryCd: `${patEvent.categoryCd}`,
        subCategoryCd: `${patEvent.subCategoryCd}`,
        indRstClass: "other",
        layoutCategoryKey: layoutCategoryKey,
        // ★ 日付ごとの子の件数
        layoutCategoryTitle: `${layoutCategoryTitle} ${totalCount}件`,
        isDispGroup: isDispGroup,
        facility_cd: patEvent.facility_cd
      };

      addContentToCalendar(
        calendarContents,
        patEvent.eventStartDate,
        calendarContent
      );
    }
  }

};

/**
 * @description 施設イベントをカレンダーに追加
 * @param {Array} layoutItems レイアウト項目配列
 * @param {Array} calendarContents 全てのカレンダー内容を保持する配列
 * @param {Array} eventData 対象患者の施設イベントデータ
 * @param {Object} mst
 * @param {String} layoutCategoryKey カテゴリキー
 * @param {String} layoutCategoryTitle カテゴリ名
 * @param {String} isDispGroup 親要素のチェック存在有無
 */
const addBbsInfoToCalendar = (
  layoutItems,
  calendarContents,
  eventData,
  mst,
  layoutCategoryKey,
  layoutCategoryTitle,
  isDispGroup
) => {
  // データなしは表示しない
  if (!eventData || eventData.length === 0) return;

  // レイアウト指定の施設イベントカテゴリをMapにする
  const layoutItemMap = new Map(
    layoutItems.map(item => [String(item.itemNo), item])
  );

  /**
   * 日付毎の子件数 集計
   * key   : `${yyyyMMdd}`
   * value : number
   */
  const countMap = new Map();

  // 施設イベントカテゴリ ごとに eventData をまとめる
  const eventMap = new Map();
  const getFacilityCd = store.getters["user/getFacilityCd"];
  const currentFacilityCd = getFacilityCd;
  const otherFacilityEvents = [];
  const otherDayMap = new Map();
  for (const bbsInfo of eventData) {
    if (bbsInfo.facility_cd != currentFacilityCd) {
      otherFacilityEvents.push(bbsInfo);
    }
    const infoDate = bbsInfo.notice_fac_cal_start_date || bbsInfo.notice_fac_cal_end_date;
    if (!infoDate) continue;
    if (!otherDayMap.has(infoDate)) {
      otherDayMap.set(infoDate, []);
    }
    otherDayMap.get(infoDate).push(bbsInfo);
    const isSameFacility = bbsInfo.facility_cd === currentFacilityCd;

    const kindKey = String(bbsInfo.kind_no);

    // layoutItems に存在しないものは対象外
    if (isSameFacility && !layoutItemMap.has(kindKey)) continue;

    // ===== 件数集計 =====
    const facStart = dayjs(
      bbsInfo.notice_fac_cal_start_date,
      "YYYYMMDD"
    );
    const facEnd = dayjs(
      bbsInfo.notice_fac_cal_end_date ?? bbsInfo.notice_fac_cal_start_date,
      "YYYYMMDD"
    );

    let current = facStart.clone();
    while (current.isSameOrBefore(facEnd)) {
      const key = `${current.format("YYYYMMDD")}`;
      countMap.set(key, (countMap.get(key) || 0) + 1);
      current.add(1, "day");
    }

    // ===== 施設イベントカテゴリ ごとにまとめる =====
    if (!eventMap.has(kindKey)) {
      eventMap.set(kindKey, []);
    }
    eventMap.get(kindKey).push(bbsInfo);
  }

  // マスタの並び順で処理する
  for (const layoutItem of layoutItems) {
    const kindNo = String(layoutItem.itemNo);
    const events = eventMap.get(kindNo);
    if (!events) continue;

    const bbsName = mstCodeToName(
      mst.bbsKindIncludeDeleted,
      kindNo,
      false,
      "kindNo",
      "kindName"
    );

    for (const bbsInfo of events) {
      const title = bbsInfo.title ?? "";
      const routerLink =
        (bbsInfo.is_disp_bbs === "1" || bbsInfo.is_disp_bbs === "3")
          ? ROUTERLINK_BBSINFO
          : ROUTERLINK_FACILITY_CALENDAR;

      const facStart = dayjs(bbsInfo.notice_fac_cal_start_date, "YYYYMMDD");
      const facEnd = bbsInfo.notice_fac_cal_end_date
        ? dayjs(bbsInfo.notice_fac_cal_end_date, "YYYYMMDD")
        : facStart.clone();

      let current = facStart.clone();
      while (current.isSameOrBefore(facEnd)) {
        const date = current.format("YYYYMMDD");
        const count = countMap.get(date) || 0;

        addContentToCalendar(calendarContents, date, {
          content: `【${bbsName}】${title}`,
          routerLink,
          readOnly: false,
          indRstClass: "other",
          layoutCategoryKey,
          layoutCategoryTitle: `${layoutCategoryTitle} ${count}件`,
          isDispGroup,
          startDate: bbsInfo.notice_start_date,
          endDate: bbsInfo.notice_end_date,
          bbsCtlNo: bbsInfo.bbs_ctl_no,
          facility_cd: bbsInfo.facility_cd
        });

        current.add(1, "day");
      }
    }
  }
  for (const bbsInfo of otherFacilityEvents) {
    const title = bbsInfo.title ?? "";
    const routerLink =
      (bbsInfo.is_disp_bbs === "1" || bbsInfo.is_disp_bbs === "3")
        ? ROUTERLINK_BBSINFO
        : ROUTERLINK_FACILITY_CALENDAR;
    const bbsName = DISP_GROUP_MAP["bbs_info"];
    const date =
      bbsInfo.notice_fac_cal_start_date ||
      bbsInfo.notice_fac_cal_end_date;
    if (!date) continue;
    const count = (otherDayMap.get(date) || []).length;
    addContentToCalendar(calendarContents, date, {
      content: `【${bbsName}】${title}`,
      routerLink,
      readOnly: false,
      indRstClass: "other",
      layoutCategoryKey,
      layoutCategoryTitle: `${layoutCategoryTitle} ${count}件`,
      isDispGroup,
      startDate: bbsInfo.notice_start_date,
      endDate: bbsInfo.notice_end_date,
      bbsCtlNo: bbsInfo.bbs_ctl_no,
      facility_cd: bbsInfo.facility_cd,
      isOtherFacility: true
    });
  }
};

/**
 * モニタ日付をローカル暦日（YYYY/MM/DD）に正規化する。
 * - DB/API が ISO(UTC) の場合もブラウザローカル日付で扱う（例: 2026-05-22T15:00:00.000Z → 2026/05/23 JST）
 * - 従来の YYYYMMDD 文字列もそのまま受け付ける
 */
const toLocalCalendarDateSlash = value => {
  if (value == null || value === "") {
    return null;
  }
  if (typeof value === "string" && /^\d{8}$/.test(value)) {
    const parsed = dayjs(value, "YYYYMMDD");
    return parsed.isValid() ? parsed.format("YYYY/MM/DD") : null;
  }
  const parsed = dayjs(value);
  return parsed.isValid() ? parsed.format("YYYY/MM/DD") : null;
};

const toLocalCalendarDateYmd = value => {
  const slash = toLocalCalendarDateSlash(value);
  return slash ? dayjs(slash, "YYYY/MM/DD").format("YYYYMMDD") : null;
};

const parseMonitorDataField = monitorItem => {
  const raw = monitorItem.monitor_data ?? monitorItem.monitorData;
  if (raw == null || raw === "") {
    return null;
  }
  if (typeof raw === "object") {
    return raw;
  }
  try {
    return JSON.parse(raw);
  } catch {
    return null;
  }
};

const normalizeMonitorRecord = monitorItem => {
  const isDeleted = monitorItem.is_del ?? monitorItem.isDel;
  if (isDeleted === "1" || isDeleted === 1) {
    return null;
  }

  const monitorData = parseMonitorDataField(monitorItem);
  if (!monitorData) {
    return null;
  }

  const occurDate = monitorItem.occur_date ?? monitorItem.occurDate;
  const treatDate = monitorItem.treat_date ?? monitorItem.treatDate;
  const treatDateSlash = toLocalCalendarDateSlash(treatDate);

  if (!treatDateSlash) {
    return null;
  }

  return {
    monitorData,
    occurDate,
    treatDate,
    treatDateSlash,
    dataType: monitorItem.data_type ?? monitorItem.dataType,
    ordNo: monitorItem.ord_no ?? monitorItem.ordNo
  };
};

/**
 * バイタルを表示用に加工
 * - 同日複数治療にも対応
 * @param {Array} layoutItems バイタル・モニタグラフのレイアウト指定項目
 * @param {string} dataKey レイアウトのdataKey vital_monitor_flg_1～4
 * @param {Array} treatmentDataList カレンダー指定期間の治療情報
 * @param {Array} resMniMonitors カレンダー指定期間のバイタル・モニタグラフ情報
 */
export const convertVitalInfoForPatCalendar = (
  layoutItems,
  dataKey,
  treatmentDataList,
  resMniMonitors
) => {
  const convertDataList = [];

  /** 日付フォーマットキャッシュ */
  const treatDateFormatMap = new Map();
  const formatTreatDate = treatDate => {
    if (!treatDateFormatMap.has(treatDate)) {
      treatDateFormatMap.set(treatDate, toLocalCalendarDateSlash(treatDate));
    }
    return treatDateFormatMap.get(treatDate);
  };

  /** 治療実績情報からチャート横軸範囲を算出 */
  const getChartRangeByOrdInfo = (copyTreatmentData, date) => {
    const treatDate = dayjs(date, "YYYY/MM/DD").format("YYYYMMDD");
    const ordInfo = copyTreatmentData[treatDate];

    // デフォルト：当日 0:00 ～ 翌日 0:00
    let startDate = dayjs(treatDate, "YYYYMMDD").startOf("day");
    let endDate   = dayjs(treatDate, "YYYYMMDD").add(1, "days").startOf("day");

    if (!ordInfo) {
      return { startDate, endDate };
    }

    // 透析前体重測定日時
    const rstWeightBeforeDate =
      ordInfo.rstWeightInfo &&
      JSON.parse(ordInfo.rstWeightInfo)?.weight_before_date
        ? dayjs(JSON.parse(ordInfo.rstWeightInfo).weight_before_date)
        : null;

    // 治療開始日時
    const rstStartDate = ordInfo.rstStartDate
      ? dayjs(ordInfo.rstStartDate)
      : null;

    if (rstWeightBeforeDate) {
      startDate = rstWeightBeforeDate;
    } else if (rstStartDate) {
      startDate = rstStartDate;
    }

    // 透析後体重測定日時
    const rstWeightAfterDate =
      ordInfo.rstWeightInfo &&
      JSON.parse(ordInfo.rstWeightInfo)?.weight_after_date
        ? dayjs(JSON.parse(ordInfo.rstWeightInfo).weight_after_date)
        : null;

    // 治療終了日時
    const rstEndDate = ordInfo.rstEndDate
      ? dayjs(ordInfo.rstEndDate)
      : null;

    if (rstWeightAfterDate) {
      endDate = rstWeightAfterDate;
    } else if (rstEndDate) {
      endDate = rstEndDate;
    }
    return { startDate, endDate };
  };

  // --------------------------------------------------------
  // 同日複数予定に紐づくバイタル・モニタグラフデータ生成
  // --------------------------------------------------------
  if (treatmentDataList.length === 0) {
    return [];
  }

  for (const copyTreatmentData of treatmentDataList) {

    if (!copyTreatmentData) {
      continue;
    }

    const series = [];
    const yAxis = [];
    let vitalInfo = [];

    /** series.data 作成 */
    const createSeriesData = vitalInfo => {
      const tempArr = {};
      vitalInfo.forEach(rec => {
        rec.monitorData && Object.keys(rec.monitorData).forEach(itemNo => {
          const pstNo = parseInt(itemNo);
          if (!tempArr[pstNo]) {
            // #8091 5.4には5.5のモニタグラフ表示される 修正 林峻峰 start
            // tempArr[pstNo] = [...[], [dayjs(rec.occurDate, "YYYYMMDD").format("YYYY/MM/DD"),rec.occurDate, Number(rec.monitorData[itemNo])]];
            tempArr[pstNo] = [...[], [rec.treatDateSlash, rec.occurDate, Number(rec.monitorData[itemNo])]];
            // #8091 5.4には5.5のモニタグラフ表示される 修正 林峻峰 end
          } else {
            // #8091 5.4には5.5のモニタグラフ表示される 修正 林峻峰 start
            // tempArr[pstNo] = [...tempArr[pstNo], [dayjs(rec.occurDate, "YYYYMMDD").format("YYYY/MM/DD"),rec.occurDate, Number(rec.monitorData[itemNo])]];
            /* modify by chamaojia 2023-10-12 [9713] 配列追加値のパフォーマンス最適化  --start */
            // 配列追加値の性能が悪く、pushに置き換える
            // tempArr[pstNo] = [...tempArr[pstNo], [dayjs(rec.treatDate, "YYYYMMDD").format("YYYY/MM/DD"), rec.occurDate, Number(rec.monitorData[itemNo])]];
            tempArr[pstNo].push([rec.treatDateSlash, rec.occurDate, Number(rec.monitorData[itemNo])]);
            /* modify by chamaojia 2023-10-12 [9713] 配列追加値のパフォーマンス最適化  --end */
            // #8091 5.4には5.5のモニタグラフ表示される 修正 林峻峰 end
          }
        });
      });

      const seriesData = series.map(record => {
        record.data = tempArr[record.no] ? tempArr[record.no]: [];
        return record;
      })
      return seriesData;
    };

    /** 全期間のグラフデータ（series）から、指定した日付のデータ点だけを抽出して、「1日分表示用のseries」を作成 */
    const createChartData = date => {
      var chartData = [];
      var chartDataList = [];
      var recordCopy = [];
      var recordCopyString = JSON.stringify(series);
      recordCopy = JSON.parse(recordCopyString);
      recordCopy.map(record => {
        for (let index = 0; index < record.data.length; index++) {
          if(record.data[index][0] == date){
            chartData.push(record.data[index]);
          }
        }
        record.data = chartData;
        chartData = [];
        chartDataList.push(record);
      })
      return chartDataList;
    };

    // ---------------------------
    // 1. vitalInfo を作る
    // ---------------------------
    for (const treatDate in copyTreatmentData) {
      const ordInfo = copyTreatmentData[treatDate];
      if (!ordInfo) continue;

      // バイタル・モニタデータ取得
      const resMniMonitor = resMniMonitors.find(y => y.ordNo == ordInfo.ordNo)?.resMniMonitor;
      if (!resMniMonitor) continue;

      resMniMonitor.data.forEach(monitorItem => {
        const normalized = normalizeMonitorRecord(monitorItem);
        if (normalized) {
          vitalInfo.push(normalized);
        }
      });
    }

    // 日付配列 & xAxis map を同時作成
    const dateSet = new Set();
    const xAxisMap = new Map(); // date -> occurDate[]

    vitalInfo.forEach(rec => {
      const date = formatTreatDate(rec.treatDate);
      dateSet.add(date);

      if (!xAxisMap.has(date)) {
        xAxisMap.set(date, []);
      }
      const occurDateSlash = toLocalCalendarDateSlash(rec.occurDate);
      if (occurDateSlash) {
        xAxisMap.get(date).push(occurDateSlash);
      }
    });

    const dateArr = [...dateSet];

    // ---------------------------
    // 2. series / yAxis 作成
    // ---------------------------
    layoutItems.forEach((category, index) => {
      const filterArr = category.subCategoryItem.map(p => p.itemNo);
      const vitalResultArr = [];

      for (const vitalItem of vitalInfo) {
        for (const key of filterArr) {
          if (Object.prototype.hasOwnProperty.call(vitalItem.monitorData || {}, key)) {
            vitalResultArr.push(vitalItem.monitorData[key]);
          }
        }
      }

      const { max, min } = getThreshold(
        category.graphMax,
        category.graphMin,
        vitalResultArr,
        "line"
      );

      yAxis.push({
        labels: { enabled: false },
        title: { text: category.subCategoryName },
        // y軸の min～max を4分割し、小数点桁数を調整しながら見た目が崩れないtick配列を作って返す ※患者経過総合ビューアと同じ
        // Highchartsの自動tickに任せると端数が汚くなる/桁数がバラつくので、それを避けるための完全手動tick制御
        tickPositioner: function () {
          const incrementCount = 4;
          const dataMax = max;
          const dataMin = min;
          const mstFixedCount = Math.max(
            (dataMin != Math.floor(dataMin)) ? (dataMin.toString()).split('.')[1].length : 0,
            (dataMax != Math.floor(dataMax)) ? (dataMax.toString()).split('.')[1].length : 0
          );
          const increment = max - min > 0 ? (max - min) / incrementCount : 0;
          const incrementFixedCount = (increment !== Math.floor(increment)) ? (increment.toString()).split('.')[1].length : 0;
          const incrementFixedMax = 3;

          const fixed = Math.max(Math.min(incrementFixedCount, incrementFixedMax), mstFixedCount);
          const positions = [];
          if (increment > 0) {
            positions.push(Number(dataMin));
            for (let index = 1; index < incrementCount; index++) {
              const valFull = dataMin + index * increment;
              const valFloor = Math.floor(valFull * Math.pow(10, fixed)) / Math.pow(10, fixed);
              positions.push(valFloor);
            }
            positions.push(Number(dataMax));
          } else {
            for (let index = 0; index < incrementCount + 1; index++) {
              const p = dataMin + index;
              positions.push(parseFloat(p.toFixed(3)));
            }
          }
          return positions;
        },
        offset: 0
      });

      category.subCategoryItem.forEach(subCategory => {
        series.push({
          yAxis: index,
          yAxisNo: category.subCategoryNo,
          yAxisName: category.subCategoryName,
          name: subCategory.itemName,
          no: subCategory.itemNo,
          color: subCategory.itemColor,
          marker: getSeriesMarker(subCategory.itemPoint, subCategory.itemColor),
          data: []
        });
      });
    });

    // ---------------------------
    // 3. 日付単位で convertDataList に追加
    // ---------------------------
    createSeriesData(vitalInfo);
    //let dateArr = createChartDate(vitalInfo);
    for (const date of dateArr) {
      // チャート横軸範囲を算出
      const { startDate, endDate } = getChartRangeByOrdInfo(copyTreatmentData, date);
      // 指定した日付の「1日分表示用のseries」を作成
      const chartData = createChartData(date);

      convertDataList.push({
        date: toLocalCalendarDateYmd(date),
        content: {
          key: dataKey,
          type: "rstChart",
          itemName: layoutItems.categoryName,
          chartData,
          chartXAxisMin: startDate.valueOf(),
          chartXAxisMax: endDate.valueOf(),
          yAxis,
          itemNameSub: [],
          routerLink: ROUTERLINK_TREATMENTRECORD,
          readOnly: false,
          ordNo: vitalInfo.find(
            v => formatTreatDate(v.treatDate) === date
          )?.ordNo,
          dataKey: dataKey
        }
      });
    }
  }
  return convertDataList;
};

/**
 * @description イベント内容をカレンダーの指定日付に追加
 * @param {Array} calendarContents 全てのカレンダー内容を保持する配列
 * @param {String} eventDate イベント発生日文字列(YYYYMMDD)
 * @param {Object} content イベント内容
 */
const addContentToCalendar = (calendarContents, eventDate, content) => {
  // 同日付のイベントが既に格納されているか確認
  const existingEvent = calendarContents.find(
    content => content.date === eventDate
  );
  if (!existingEvent) {
    // なければ新しく追加
    calendarContents.push({
      date: eventDate,
      type: "items",
      items: [content]
    });
  } else {
    existingEvent.items = [...existingEvent.items, content];
  }
};

/**
 * @description 日付文字列フォーマット
 * @param {String} date 時間文字列
 * @returns {String} フォーマット後の日付文字列
 */
const formatDate = (date, format) => {
  const mo = dayjs(date);
  return mo.isValid() ? mo.format(format) : null;
};

/**
 * @description 時間文字列フォーマット
 * @param {String} hhmm 時間文字列
 * @returns {String} 引数がHHmm形式文字列: 'HH:mm', 不正な文字列: ''
 */
const formatTimeString = hhmm => {
  const time = dayjs(hhmm, "HHmm");
  return time.isValid() ? time.format("HH:mm") : null;
};

/**
 * @description 小数点桁数フォーマット
 * @param {String} 数量
 * @param {String} 小数点桁数
 * @returns {String} 小数点桁数フォーマット数量
 */
const formatDecimalPoint = (amount, unitDecimalPoint) => {
  let amounts = amount != null ? amount : 0;
  let unitDecimalPoints = unitDecimalPoint != null ? unitDecimalPoint : 0;
  //mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 start
  let numbers = String(BigNumber(amounts).toFixed()).split('.');
  //mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 end
  let decPoint = (numbers[1]) ? numbers[1].length : 0;
  if(decPoint > unitDecimalPoints){
    return BigNumber(amounts).toFixed();
  }else{
    return BigNumber(amounts).toFixed(unitDecimalPoints);
  }
};
