package jp.co.nikkiso.ntss.web_api.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MniMonitorDao;
import jp.co.nikkiso.ntss.core.dao.MstExamItemDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.MstPatMemoDao;
import jp.co.nikkiso.ntss.core.dao.MstTreatmentDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatExamMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.PatUniqueDao;
import jp.co.nikkiso.ntss.core.entity.MniMonitor;
import jp.co.nikkiso.ntss.core.entity.MstExamItem;
import jp.co.nikkiso.ntss.core.entity.MstPatMemo;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatExamMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.custom.ExamResult;
import jp.co.nikkiso.ntss.core.entity.custom.ExamResultParam;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainListInfo;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainRstWeightInfo;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainExamResultInfo;
import jp.co.nikkiso.ntss.core.entity.custom.PatUniquePhysicalInfo;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.web_api.constant.ExamResultCalcConstant;
import jp.co.nikkiso.ntss.web_api.constant.ExamResultCalcConstant.ExamClass;
import jp.co.nikkiso.ntss.web_api.constant.ExamResultCalcConstant.ExamItemSystemDefaultCalcFormulaId;
import jp.co.nikkiso.ntss.web_api.util.DateUtil;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.TemporalField;
import java.time.temporal.WeekFields;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Comparator;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

// mod #8144 【デグレ】検査計算結果が検査後にしか反映されない dou start

/**
 * 検査結果計算のService実装クラス.
 */
@Service
public class ExamResultCalcUtilServiceImpl implements ExamResultCalcUtilService {

  /**
   * 患者検査結果Dao.
   */
  @Autowired
  private PatExamMainDao patExamMainDao;
  /**
   * 検査項目Dao.
   */
  @Autowired
  private MstExamItemDao mstExamItemDao;
  /**
   * 治療予実Dao.
   */
  @Autowired
  private OrdMainDao ordMainDao;
  /**
   * 患者基本情報Dao.
   */
  @Autowired
  private PatUniqueDao patUniqueDao;
  /**
   * 患者情報Dao.
   */
  @Autowired
  private PatPersonalMainDao patPersonalMainDao;
  /**
   * 施設設定Dao.
   */
  @Autowired
  private MstFacilitySettingDao mstFacilitySettingDao;

  @Autowired
  private LogService logService;
  // add FNSI-No196 透析前後の判断の最適化 関 start
  @Autowired
  private MstPatMemoDao mstPatMemoDao;

  @Autowired
  private MstTreatmentDao mstTreatmentDao;

  @Autowired
  private MniMonitorDao mniMonitorDao;
// add FNSI-No196 透析前後の判断の最適化 関 end

  /**
   * {@inheritDoc}
   */
  public void calculate(List<Long> examMainCds, List<Long> recalculationExamItem) {

    for (Long cd : examMainCds) {
      // 検査結果を取得
      PatExamMain selectExamResult = patExamMainDao.selectPatExamMainByExamMainCd(cd);

      // 検査結果更新用文字列
      StringBuilder strUpdResultInfo = new StringBuilder();

      // 一つの検査結果で同じシステム標準計算・検査計算は一度しかしないようにするため、計算済みの計算項目を保持しておく
      List<String> lstCalculated = new ArrayList<String>();

      // 性別不明の場合の扱いを施設設定より取得
      String unKnownSexVal = mstFacilitySettingDao.getBySettingNoAndCd(selectExamResult.getFacilityCd(), CoreConstant.FacilitySettingNo.PAT_SEX_NON).getValue();
      //add 透析前後の判断の最適化 関 start
      Timestamp regExamDate = selectExamResult.getRegExamDate();
      String regOrderClass = selectExamResult.getRegOrderClass();
      //add 透析前後の判断の最適化 関 end
      if (selectExamResult != null) {
        String resultInfo = selectExamResult.getExamResultInfo();
        if (!StringUtils.isEmpty(resultInfo)) {
          // 検査結果有り
          try {
            List<PatExamMainExamResultInfo> examResultInfo = new ObjectMapper().readValue(resultInfo, new TypeReference<List<PatExamMainExamResultInfo>>() {
            });
            Long patId = selectExamResult.getPatId();
            Integer SX = patPersonalMainDao.selectById(patId).getPat_sex();
            String facilityCd = selectExamResult.getFacilityCd();

            SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
            String targetDt = sdf.format(selectExamResult.getResultExamDate());
            Timestamp timestamp = new Timestamp(System.currentTimeMillis());
            sdf = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
            String strUpDt = sdf.format(timestamp);

            ExamResultParam examResultParam = new ExamResultParam();
            examResultParam.setPatId(patId);
            examResultParam.setExamMainCd(cd);
            examResultParam.setFacilityCd(facilityCd);
            examResultParam.setTargetDt(targetDt);
            // add #8782 検査計算項目が計算されない ztc 20230607 start
            examResultParam.setTargetDtTime(selectExamResult.getResultExamDate());
            // add #8782 検査計算項目が計算されない ztc 20230607 end
            examResultParam.setRegExamDate(regExamDate);
            examResultParam.setRegOrderClass(regOrderClass);
            examResultParam.setSex(SX);
            examResultParam.setStrUpDt(strUpDt);
            examResultParam.setUnKnownSexVal(unKnownSexVal);
            ExamResult examResult = new ExamResult();
            //add 9735,9741,9729 再計算 guan start
            // *********システム標準計算項目*********
            examResult = systemStandardCalculationItemHandle(recalculationExamItem, lstCalculated, examResultInfo, examResultParam, examResult);
            // *********検査計算項目*********
            examResultInfo = inspectionCalculationItemHandle(recalculationExamItem, resultInfo, examResultInfo, examResultParam);
            examResultInfo = examResultInfo.stream()
              .filter(x -> !ExamClass.EXAM_ITEM.equals(x.getExam_class()))
              .filter(x -> !x.getItem_cd().equals(examResultParam.getCorCaItemCd())).collect(Collectors.toList());
            //mod 9615 因島帳票の表示不具合（検査結果出力1~4）zhao start
            //this.editGroup(examResultInfo, examResult);
            this.editGroup(examResultInfo, examResult, facilityCd);
            //mod 9615 因島帳票の表示不具合（検査結果出力1~4）zhao end
            //補正化Caの特殊処理
            if (!StringUtils.isEmpty(examResultParam.getCorCaItemCd())) {
              this.setCorrectionCa(examResultParam);
            }
            //add 9737 TAC_BUN修正 gjn start
            //TAC_BUN的item_cd取得
            List<MstExamItem> mstExamItemList = mstExamItemDao.selectByExamItemCdListToTacBun(facilityCd,
              ExamClass.SYSTEM_DEFAULT_CALC_ITEM, ExamItemSystemDefaultCalcFormulaId.TAC_BUN);
            Long examItemCd = null;
            Integer inputDecimalFigure = null;
            if (mstExamItemList.size() == 1) { //TAC_BUNは1つしかない
              examItemCd = mstExamItemList.get(0).getExamItemCd();
              inputDecimalFigure = mstExamItemList.get(0).getInputDecimalFigure();
            }
            if ((recalculationExamItem.size() > 0 && recalculationExamItem.contains(examItemCd)) || recalculationExamItem.size() == 0) {
              this.systemComputeTacBun(examResultParam, inputDecimalFigure, examItemCd);
            }
            //add 9737 TAC_BUN修正 gjn end

            //add 9735,9741,9729 再計算 guan end
          } catch (Exception e) {
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
            // エラーログを出力
            EventLogMessage eventLogMessage = new EventLogMessage();
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
            eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
            eventLogMessage.setSqlIdentification("(examResult = " + selectExamResult);
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, "patExamMainDao/updateResultExamSetInfo");
            // 例外発生時はスキップして次の検査結果を処理する
          }
        }
      }
    }
  }


  //add 9737 TAC_BUN修正 gjn start
  /**
   * TAC_BUNの計算処理
   *
   * @param examResultParam
   * @param inputDecimalFigure
   * @param examItemCd
   * @throws JsonProcessingException
   */
  private void systemComputeTacBun (ExamResultParam examResultParam, Integer inputDecimalFigure, Long examItemCd) throws JsonProcessingException {
    //TODO 1.現在の検査結果から今回のすべての検査結果を取得し、検査時間順にソートし、最も時間の小さい透析前BUN値と所在するグループを取り出した
    String todayBunBefor = ""; //今回の透析前
    String lastBunAfter = ""; //前回透析後
    String todayBunAfter = ""; //今回の透析後
    String nextBunBefor = ""; //次回透析前
    List<PatExamMain> patExamMainListTodayGroup = new ArrayList<>(); //今回の最小透析前のグループ
    List<PatExamMain> patExamMainListNextGroup = new ArrayList<>(); //次回时间最小透析前のグループ

    LocalDateTime regExamDate = examResultParam.getRegExamDate().toLocalDateTime();
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    String currExamResultDate = regExamDate.format(formatter);
    //当日の全検査結果のうち透析前と他（透析前）に区分された検査結果を取得する
    List<PatExamMain> patExamMainsToday = patExamMainDao.selectPatExamMainByPatIdAndFromdateToDate(String.valueOf(examResultParam.getPatId()), currExamResultDate, currExamResultDate);

    List<PatExamMain> patExamMainLists = new ArrayList<>();
    List<PatExamMain> listBefore = new ArrayList<>();
    List<PatExamMain> listOther = new ArrayList<>();
    listBefore = patExamMainsToday.stream().filter(x -> ExamResultCalcConstant.OrderClass.BEFORE_DIALYSIS.equals(x.getRegOrderClass())).collect(Collectors.toList());
    listOther = patExamMainsToday.stream().filter(x -> ExamResultCalcConstant.OrderClass.OTHER_DIALYSIS.equals(x.getRegOrderClass())).collect(Collectors.toList());

    //BUN透析前、透析後のmstからデータを取り出す
    ArrayList<String> defaultCalcExamItemCdList = new ArrayList<>();
    defaultCalcExamItemCdList.add(ExamResultCalcConstant.ExamResultCalcColumns.BUN);
    List<MstExamItem> mstExamItems = mstExamItemDao.selectByDefaultCalcExamItemCdListAndExamClass(examResultParam.getFacilityCd(), defaultCalcExamItemCdList, ExamClass.EXAM_ITEM);

    patExamMainLists.addAll(listBefore);
    //curr _other_リストには透析後の
    for (PatExamMain patExamMain : listOther) {
      String dnfg = this.checkExamForType(mstExamItems, patExamMain);
      if (ExamResultCalcConstant.DialysisProgressFlag.BEFORE.equals(dnfg)) { //mstBUN登録の透析前
        patExamMainLists.add(patExamMain);
      }
    }
    //当日時間最小の透析前検査結果
    PatExamMain patExamMain_today = null;
    //昇順ソート
    patExamMainLists = patExamMainLists.stream().sorted(Comparator.comparing(PatExamMain::getRegExamDate)).collect(Collectors.toList());
    for (PatExamMain patExamMain : patExamMainLists) {
      //時間昇順に時間が最も小さい透析前のBUN値をとり、最も小さいものに値がない場合は後方へ取る
      String examResultInfo = patExamMain.getExamResultInfo();
      JSONArray info = new JSONArray(examResultInfo);
      for (int i = 0; i < info.length(); i++) {
        JSONObject object = info.getJSONObject(i);
        if (object.has("result") && !StringUtils.isEmpty(object.get("result").toString())
          && object.has("item_cd") && !StringUtils.isEmpty(object.get("item_cd"))) {
          List<MstExamItem> examItems = mstExamItems.stream().filter(x -> object.get("item_cd").toString().equals(x.getExamItemCd().toString())).collect(Collectors.toList());
          if (examItems.size() == 1) {
            //TAC_BUNの今回の透析前BUNパラメータは、時間が最小である検査結果の中の
            todayBunBefor = String.valueOf(object.get("result"));
            patExamMain_today = patExamMain;
            break;
          }
        }
      }
      if (!StringUtils.isEmpty(todayBunBefor)) {
        break;
      }
    }
    //今回最小時間の検査結果に対応するグループを取り出す
    patExamMainListTodayGroup = this.getExamRsultAtGroup(patExamMain_today);

    //TODO 2.前回時間が最も大きかった透析後またはその他（透析後）の値を取り出すには、1週間以内の制限がある
    //前回の日付取得
    LocalDate lastExamDate = null;
    List<PatExamMain> patExamMainsLast = patExamMainDao.selectPatExamMainByPatIdAndDateLast(examResultParam.getPatId(), currExamResultDate);
    List<PatExamMain> patExamMainListsLast = new ArrayList<>();
    List<PatExamMain> listAfterLast = new ArrayList<>();
    List<PatExamMain> listOtherLast = new ArrayList<>();
    listAfterLast = patExamMainsLast.stream().filter(x -> ExamResultCalcConstant.OrderClass.AFTER_DIALYSIS.equals(x.getRegOrderClass())).collect(Collectors.toList());
    listOtherLast = patExamMainsLast.stream().filter(x -> ExamResultCalcConstant.OrderClass.OTHER_DIALYSIS.equals(x.getRegOrderClass())).collect(Collectors.toList());
    patExamMainListsLast.addAll(listAfterLast);
    //curr _other_リストには透析後の
    for (PatExamMain patExamMain : listOtherLast) {
      String dnfg = this.checkExamForType(mstExamItems, patExamMain);
      if (ExamResultCalcConstant.DialysisProgressFlag.AFTER.equals(dnfg)) { //mstBUN登録の透析前
        patExamMainListsLast.add(patExamMain);
      }
    }
    //前回すべての透析後の順序付け
    patExamMainListsLast = patExamMainListsLast.stream().sorted(Comparator.comparing(PatExamMain::getRegExamDate).reversed()).collect(Collectors.toList());
    for (PatExamMain patExamMain : patExamMainListsLast) {
      //時間昇順に時間が最も小さい透析前のBUN値をとり、最も小さいものに値がない場合は後方へ取る
      String examResultInfo = patExamMain.getExamResultInfo();
      JSONArray info = new JSONArray(examResultInfo);
      for (int i = 0; i < info.length(); i++) {
        JSONObject object = info.getJSONObject(i);
        if (object.has("result") && !StringUtils.isEmpty(object.get("result").toString())
          && object.has("item_cd") && !StringUtils.isEmpty(object.get("item_cd"))) {
          List<MstExamItem> examItems = mstExamItems.stream().filter(x -> object.get("item_cd").toString().equals(x.getExamItemCd().toString())).collect(Collectors.toList());
          if (examItems.size() == 1) {
            //TAC_BUNの前回最大時間透析後値取得
            lastBunAfter = String.valueOf(object.get("result"));
            lastExamDate = patExamMain.getRegExamDate().toLocalDateTime().toLocalDate();
            break;
          }
        }
      }
      if (!StringUtils.isEmpty(lastBunAfter)) {
        break;
      }
    }
    //TODO 3.前回透析後の検査結果と今回透析前の検査結果が同一週以内であるかどうかを検証する
    LocalDate currExamRsultDate = regExamDate.toLocalDate();
    TemporalField weekOfYear = WeekFields.ISO.weekOfWeekBasedYear();
    int weekNumber1 = currExamRsultDate != null ? currExamRsultDate.get(weekOfYear) : -1;
    int weekNumber2 = lastExamDate != null ? lastExamDate.get(weekOfYear) : -2;
    if (weekNumber1 == weekNumber2) {
    } else {
      lastBunAfter = "";
    }
    //TODO 4.TAC _BUNの計算式：（今回透析前BUN＋前回透析後BUN）/2
    Double ret = this.getTacBunValue(todayBunBefor, lastBunAfter, inputDecimalFigure);

    //TODO 5.TAC _BUNのjsonデータを、今回の最小時間透析前のグループに追加（patExamMainListToday）してDBに保存する
    this.saveExamRsultToDb(examResultParam.getFacilityCd(), ret, patExamMainListTodayGroup);
    //TODO 6.patExamMainListTodayGroup以外のグループが当日存在する場合、他のグループの検査結果はTAC _BUNの結果JSON
    this.filterGroupOutTacBunExamRsult(patExamMainsToday, patExamMainListTodayGroup, examItemCd);

    //TODO 7.今回時間最大透析後のBUN値を取得
    todayBunAfter = getMaxBunAfterByExamRsult(patExamMainsToday, mstExamItems, weekOfYear, weekNumber1);
    if (StringUtils.isEmpty(todayBunAfter)) { //今回は透析後BUN値は存在しなかった
      //前回透析後の検査結果取得集合
      List<PatExamMain> patExamMainsLastAfter = patExamMainDao.selectPatExamMainByPatIdAndDateLast(examResultParam.getPatId(), currExamResultDate);
      todayBunAfter = getMaxBunAfterByExamRsult(patExamMainsLastAfter, mstExamItems, weekOfYear, weekNumber1);
    }

    //TODO 8.次回時間最小透析前のBUN値を取得し、所在する検査結果群
    DateTimeFormatter formatterNext = DateTimeFormatter.ofPattern("yyyyMMdd");
    String currExamResultDateNext = regExamDate.format(formatterNext);
    List<PatExamMain> patExamMainsNext = patExamMainDao.selectPatExamMainByPatIdAndDateNext(examResultParam.getPatId(), currExamResultDateNext);

    List<PatExamMain> patExamMainListsNext = new ArrayList<>();
    List<PatExamMain> listBeforeNext = new ArrayList<>();
    List<PatExamMain> listOtherNext = new ArrayList<>();
    listBeforeNext = patExamMainsNext.stream().filter(x -> ExamResultCalcConstant.OrderClass.BEFORE_DIALYSIS.equals(x.getRegOrderClass())).collect(Collectors.toList());
    listOtherNext = patExamMainsNext.stream().filter(x -> ExamResultCalcConstant.OrderClass.OTHER_DIALYSIS.equals(x.getRegOrderClass())).collect(Collectors.toList());

    patExamMainListsNext.addAll(listBeforeNext);
    for (PatExamMain patExamMain : listOtherNext) {
      String dnfg = this.checkExamForType(mstExamItems, patExamMain);
      if (ExamResultCalcConstant.DialysisProgressFlag.BEFORE.equals(dnfg)) { //mstBUN登録の透析前
        patExamMainListsNext.add(patExamMain);
      }
    }
    //二次全透析前の順序付け
    patExamMainListsNext = patExamMainListsNext.stream().sorted(Comparator.comparing(PatExamMain::getRegExamDate)).collect(Collectors.toList());
    //回有効計算の検査結果
    PatExamMain nextExamItem = null;
    //チェック時間順にソートし、最小時間の開始からBUN値をトラバースします
    for (PatExamMain patExamMain : patExamMainListsNext) {
      //時間昇順に時間が最も小さい透析前のBUN値をとり、最も小さいものに値がない場合は後方へ取る
      String examResultInfo = patExamMain.getExamResultInfo();
      JSONArray info = new JSONArray(examResultInfo);
      for (int i = 0; i < info.length(); i++) {
        JSONObject object = info.getJSONObject(i);
        if (object.has("result") && !StringUtils.isEmpty(object.get("result").toString())
          && object.has("item_cd") && !StringUtils.isEmpty(object.get("item_cd"))) {
          List<MstExamItem> examItems = mstExamItems.stream().filter(x -> object.get("item_cd").toString().equals(x.getExamItemCd().toString())).collect(Collectors.toList());
          if (examItems.size() == 1) {
            //TAC_BUNの二次最小時間透析前のBUN値取得
            nextBunBefor = String.valueOf(object.get("result"));
            //有効な検査結果を取り出す
            nextExamItem = patExamMain;
            break;
          }
        }
      }
      if (!StringUtils.isEmpty(nextBunBefor)) {
        break;
      }
    }
    patExamMainListNextGroup = this.getExamRsultAtGroup(nextExamItem);

    //TODO 9.今回の最大透析後と次回の最小透析前の検査時間が同じ週内であるかどうかを検証する
    //セカンダリチェック日取得
    LocalDate nextExamDate = nextExamItem != null && nextExamItem.getRegExamDate() != null ? nextExamItem.getRegExamDate().toLocalDateTime().toLocalDate() : null;
    int weekNumber3 = nextExamDate != null ? nextExamDate.get(weekOfYear) : -2;
    if (weekNumber1 == weekNumber3) {
    } else {
      nextBunBefor = "";
    }
    //TODO 10.TAC _BUNの計算式：
    Double retNext = this.getTacBunValue(nextBunBefor, todayBunAfter, inputDecimalFigure);

    //TODO 11.TAC _BUNのjsonデータを、次回最小時間透析前のグループ（patExamMainListNext）に追加してDBに保存する
    this.saveExamRsultToDb(examResultParam.getFacilityCd(), retNext, patExamMainListNextGroup);
    //TODO 12.空回透析前群以外の検査結果におけるTAC _BUNの計算結果
    List<PatExamMain> patExamMainsNextAll = new ArrayList<>();
    //次回透析前の日付取得
    String nextExamDateOne = nextExamItem != null ? nextExamItem.getRegExamDate().toLocalDateTime().format(formatter) : "";
    if (!StringUtils.isEmpty(nextExamDateOne)) {
      patExamMainsNextAll = patExamMainDao.selectPatExamMainByPatIdAndFromdateToDate(String.valueOf(examResultParam.getPatId()), nextExamDateOne, nextExamDateOne);
      this.filterGroupOutTacBunExamRsult(patExamMainsNextAll, patExamMainListNextGroup, examItemCd);
    }
    //TODO 13.今回の透析後を削除した場合、そして今回は透析後がなくなり、todayBunAfterは空に等しい場合、以下の論理処理を行う
    /*
     * 今回の透析後が空であれば、今回は透析後のBUN値がないことを示し、今回の透析後のデータが今回削除されたことを防ぐため、todayBunAfterが空である場合、
     * 最も近い透析後のBUN値を前に取り続け、計算を行う必要がある、
     * 前取透析後のBUN値も存在しない場合は、二次透析前のTAC _BUN計算式
     * */
    if (StringUtils.isEmpty(todayBunAfter)) {
        //今回までの検査結果が存在しなかったり、以前の検査結果に透析後のBUN値が存在しなかったりすると、回分の検査結果のTAC _BUN計算式すべてクリア
      List<PatExamMain> patExamMainListOut = patExamMainDao.selectPatExamMainByPatIdAndDateNext(examResultParam.getPatId(), currExamResultDateNext);
      if (patExamMainListOut.size() > 0) {
        patExamMainListOut = patExamMainListOut.stream().sorted(Comparator.comparing(PatExamMain::getRegExamDate)).collect(Collectors.toList());
        LocalDate localDate = patExamMainListOut.get(0).getResultExamDate().toLocalDateTime().toLocalDate();
        String currResultDate = localDate.format(formatter);
        //当日の全検査結果のうち透析前と他（透析前）に区分された検査結果を取得する
        List<PatExamMain> nextPatExamMainListOut = patExamMainDao.selectPatExamMainByPatIdAndFromdateToDate(String.valueOf(examResultParam.getPatId()), currResultDate, currResultDate);
        //nextPatExamMainListOut内のすべての検査結果のTAC _BUN計算式
        for (PatExamMain next_patExamMain : nextPatExamMainListOut) {
          StringBuilder strUpdResultInfo = new StringBuilder();
          strUpdResultInfo.append("[");
          // patExamMainの検査結果JSON取得
          List<PatExamMainExamResultInfo> examResultInfos =
            next_patExamMain.getExamResultInfo() == null || next_patExamMain.getExamResultInfo().isEmpty()
                ? new ArrayList<>()
                : new ObjectMapper().readValue(next_patExamMain.getExamResultInfo(), new TypeReference<List<PatExamMainExamResultInfo>>() {});
          for (PatExamMainExamResultInfo patExamMainExamResultInfo : examResultInfos) {
            //検査結果にTAC _BUNの計算結果、存在する場合はresult値とResult _date
            if ("1".equals(patExamMainExamResultInfo.getExam_class()) && !StringUtils.isEmpty(patExamMainExamResultInfo.getItem_cd())
                && String.valueOf(examItemCd).equals(patExamMainExamResultInfo.getItem_cd())) {
                //TAC_BUNスキップ（位相変化削除）
                continue;
            }
            strUpdResultInfo.append(patExamMainExamResultInfo.getValue());
            strUpdResultInfo.append(",");
          }
          strUpdResultInfo.deleteCharAt(strUpdResultInfo.length() - 1);
            strUpdResultInfo.append("]");
            // 計算完了後検査結果を更新する
          next_patExamMain.setExamResultInfo(strUpdResultInfo.toString());
          next_patExamMain.setUpDate(new Timestamp(System.currentTimeMillis()));
          patExamMainDao.updateResultExamSetInfo(next_patExamMain);
        }
      }
    }
  }


  /**
   * 検査結果集合で最も時間の大きい透析後BUN値を取得する
   *
   * @param patExamMainsToday
   * @param mstExamItems
   * @param weekOfYear
   * @param weekNumber1
   * @return
   */
  private String getMaxBunAfterByExamRsult (List<PatExamMain> patExamMainsToday, List<MstExamItem> mstExamItems, TemporalField weekOfYear, int weekNumber1) {
    String todayBunAfter = "";
    List<PatExamMain> patExamMainLists_todayAfter = new ArrayList<>();
    List<PatExamMain> listAfter_today = new ArrayList<>();
    List<PatExamMain> listOther_todayAfter = new ArrayList<>();
    listAfter_today = patExamMainsToday.stream().filter(x -> ExamResultCalcConstant.OrderClass.AFTER_DIALYSIS.equals(x.getRegOrderClass())).collect(Collectors.toList());
    listOther_todayAfter = patExamMainsToday.stream().filter(x -> ExamResultCalcConstant.OrderClass.OTHER_DIALYSIS.equals(x.getRegOrderClass())).collect(Collectors.toList());

    patExamMainLists_todayAfter.addAll(listAfter_today);
    //curr _other_リストには透析後の
    for (PatExamMain patExamMain : listOther_todayAfter) {
      String dnfg = this.checkExamForType(mstExamItems, patExamMain);
      if (ExamResultCalcConstant.DialysisProgressFlag.AFTER.equals(dnfg)) { //mstBUN登録の透析后
        patExamMainLists_todayAfter.add(patExamMain);
      }
    }
    //降順ソート
    patExamMainLists_todayAfter = patExamMainLists_todayAfter.stream().sorted(Comparator.comparing(PatExamMain::getRegExamDate).reversed()).collect(Collectors.toList());
    for (PatExamMain patExamMain : patExamMainLists_todayAfter) {
      //各透析後の検査結果を処理する際には、その検査結果の検査日時と計算する透析前日時とが同一週以内であるかどうかを事前に判定し、直接終了しなければ、todayBunAfterは空に戻る
      LocalDate lastExamDate = patExamMain.getResultExamDate().toLocalDateTime().toLocalDate();
      int weekNumber2 = lastExamDate != null ? lastExamDate.get(weekOfYear) : -2;
      if (weekNumber1 == weekNumber2) {
      } else {
        todayBunAfter = "";
        break;
      }
      //時間昇順に時間が最も小さい透析前のBUN値をとり、最も小さいものに値がない場合は後方へ取る
      String examResultInfo = patExamMain.getExamResultInfo();
      JSONArray info = new JSONArray(examResultInfo);
      for (int i = 0; i < info.length(); i++) {
        JSONObject object = info.getJSONObject(i);
        if (object.has("result") && !StringUtils.isEmpty(object.get("result").toString())
          && object.has("item_cd") && !StringUtils.isEmpty(object.get("item_cd"))) {
          List<MstExamItem> examItems = mstExamItems.stream().filter(x -> object.get("item_cd").toString().equals(x.getExamItemCd().toString())).collect(Collectors.toList());
          if (examItems.size() == 1) {
            //TAC_BUNの今回の最大時間透析後BUN値取得
            todayBunAfter = String.valueOf(object.get("result"));
            break;
          }
        }
      }
      if (!StringUtils.isEmpty(todayBunAfter)) {
        break;
      }
    }
    return todayBunAfter;
  }


  /**
   * TAC _BUNはグループ以外の検査結果を計算し、TAC _BUNの計算結果
   *
   * @param patExamMainListAll
   * @param patExamMainListGroup
   * @param examItemCd
   * @throws JsonProcessingException
   */
  private void filterGroupOutTacBunExamRsult (List<PatExamMain> patExamMainListAll, List<PatExamMain> patExamMainListGroup, Long examItemCd) throws JsonProcessingException {
    List<PatExamMain> patExamMainListOut = new ArrayList<>();
    //非計算グループ内のメンバーをフィルタする
    for (PatExamMain patExamMain : patExamMainListAll) {
      boolean isCon = true;
      String examItemCdAll = patExamMain.getExamMainCd().toString();
      for (PatExamMain patExamMain1 : patExamMainListGroup) {
        String examItemCdGroup = patExamMain1.getExamMainCd().toString();
        if (examItemCdGroup.equals(examItemCdAll)) {
          isCon = false;
        }
      }
      if (isCon) {
        patExamMainListOut.add(patExamMain);
      }
    }
    if (patExamMainListOut.size() > 0) {
      for (PatExamMain next_patExamMain : patExamMainListOut) {
        StringBuilder strUpdResultInfo = new StringBuilder();
        strUpdResultInfo.append("[");
        // patExamMainの検査結果JSON取得
        List<PatExamMainExamResultInfo> examResultInfos =
          next_patExamMain.getExamResultInfo() == null || next_patExamMain.getExamResultInfo().isEmpty()
            ? new ArrayList<>()
            : new ObjectMapper().readValue(next_patExamMain.getExamResultInfo(), new TypeReference<List<PatExamMainExamResultInfo>>() {});
        for (PatExamMainExamResultInfo patExamMainExamResultInfo : examResultInfos) {
          //検査結果にTAC _BUNの計算結果、存在する場合はresult値とResult _date
          if ("1".equals(patExamMainExamResultInfo.getExam_class()) && !StringUtils.isEmpty(patExamMainExamResultInfo.getItem_cd())
            && String.valueOf(examItemCd).equals(patExamMainExamResultInfo.getItem_cd())) {
            //TAC_BUNスキップ（位相変化削除）
           continue;
          }
          strUpdResultInfo.append(patExamMainExamResultInfo.getValue());
          strUpdResultInfo.append(",");
        }
        strUpdResultInfo.deleteCharAt(strUpdResultInfo.length() - 1);
        strUpdResultInfo.append("]");
        // 計算完了後検査結果を更新する
        next_patExamMain.setExamResultInfo(strUpdResultInfo.toString());
        next_patExamMain.setUpDate(new Timestamp(System.currentTimeMillis()));
        patExamMainDao.updateResultExamSetInfo(next_patExamMain);
      }
    }
  }


  /**
   * TAC_BUNの計算過程
   *
   * @param bunbefor
   * @param bunAfter
   * @param inputDecimalFigure
   * @return
   */
  private Double getTacBunValue (String bunbefor, String bunAfter, Integer inputDecimalFigure) {
    Double ret; //計算結果
    int decimalPlaces = inputDecimalFigure != null ? inputDecimalFigure : 2; //mst配置的小数位，默认为保留两位小数
    //10140 パラメータが不足している場合は、計算せずにnullに戻ります
    if (StringUtils.isEmpty(bunbefor) || StringUtils.isEmpty(bunAfter)) {
      ret = null;
    } else {
      //mod 10140 計算エラー,NaNで更新 gjn start
      try {
        BigDecimal befBun = new BigDecimal(bunbefor);
        BigDecimal aftBun = new BigDecimal(bunAfter);
        ret = (aftBun.add(befBun)).divide(BigDecimal.valueOf(2), decimalPlaces, RoundingMode.DOWN).doubleValue();
      } catch (Exception exception) {
        ret = Double.NaN;
      }
      //mod 10140 計算エラー,NaNで更新 gjn end
    }
    return ret;
  }

  /**
   * TAC_BUN結果は対応するグループのDBに更新される
   *
   * @param facilityCd
   * @param ret
   * @param patExamMainList
   * @throws JsonProcessingException
   */
  private void saveExamRsultToDb (String facilityCd, Double ret, List<PatExamMain> patExamMainList) throws JsonProcessingException {
    if (ret != null) {
      if (patExamMainList != null && patExamMainList.size() > 0) {
        //TAC _mstにおけるBUNのデータ
        List<MstExamItem> mstExamItemList = mstExamItemDao.selectByExamItemCdListToTacBun(facilityCd, ExamClass.SYSTEM_DEFAULT_CALC_ITEM, ExamItemSystemDefaultCalcFormulaId.TAC_BUN);
        Long examItemCd = null;
        String examItemName = "";
        if (mstExamItemList.size() == 1) { //TAC_BUN只能有一个
          examItemCd = mstExamItemList.get(0).getExamItemCd();
          examItemName = mstExamItemList.get(0).getExamItemName();
        }
        //回透析前のグループのTAC _BUN値
        for (PatExamMain next_patExamMain : patExamMainList) {
          StringBuilder strUpdResultInfo = new StringBuilder();
          strUpdResultInfo.append("[");
          // patExamMainの検査結果JSON取得
          List<PatExamMainExamResultInfo> examResultInfos =
            next_patExamMain.getExamResultInfo() == null || next_patExamMain.getExamResultInfo().isEmpty()
              ? new ArrayList<>()
              : new ObjectMapper().readValue(next_patExamMain.getExamResultInfo(), new TypeReference<List<PatExamMainExamResultInfo>>() {});
          boolean isExist = false;
          for (PatExamMainExamResultInfo patExamMainExamResultInfo : examResultInfos) {
            //検査結果にTAC _BUNの計算結果、存在する場合はresult値とResult _date
            if ("1".equals(patExamMainExamResultInfo.getExam_class()) && !StringUtils.isEmpty(patExamMainExamResultInfo.getItem_cd())
              && String.valueOf(examItemCd).equals(patExamMainExamResultInfo.getItem_cd())) {
              //TAC_BUN
              patExamMainExamResultInfo.setResult(ret == null ? "" : ret.toString().equals("0.0") ? "" : ret.toString());
              patExamMainExamResultInfo.setResult_date(new Timestamp(System.currentTimeMillis()).toString());
              isExist = true;
            }
            strUpdResultInfo.append(patExamMainExamResultInfo.getValue());
            strUpdResultInfo.append(",");
          }
          if (!isExist) {
            //現在の検査結果にTAC _BUN計算式の場合、TAC _BUNデータjson挿入
            PatExamMainExamResultInfo patExamMainExamResultInfoNew = new PatExamMainExamResultInfo();
            patExamMainExamResultInfoNew.setResult_date(new Timestamp(System.currentTimeMillis()).toString());
            patExamMainExamResultInfoNew.setResult(String.valueOf(ret));
            patExamMainExamResultInfoNew.setHl("");
            patExamMainExamResultInfoNew.setCom_cd("");
            patExamMainExamResultInfoNew.setExam_class("1");
            patExamMainExamResultInfoNew.setItem_cd(String.valueOf(examItemCd));
            patExamMainExamResultInfoNew.setItem_name(examItemName);
            strUpdResultInfo.append(patExamMainExamResultInfoNew.getValue());
          } else  {
            strUpdResultInfo.deleteCharAt(strUpdResultInfo.length() - 1);
          }
          strUpdResultInfo.append("]");
          // 計算完了後検査結果を更新する
          next_patExamMain.setExamResultInfo(strUpdResultInfo.toString());
          next_patExamMain.setUpDate(new Timestamp(System.currentTimeMillis()));
          patExamMainDao.updateResultExamSetInfo(next_patExamMain);
        }
      }
    }
  }

  /**
   * 検査結果オブジェクトに基づいて存在するグループコレクションを取得する
   *
   * @param patExamMain
   * @return
   */
  private List<PatExamMain> getExamRsultAtGroup (PatExamMain patExamMain) {
    //通常、3つの判断はすべてnullであるべきではありません
    if (patExamMain == null || patExamMain.getResultExamDate() == null || patExamMain.getPatId() == null) {
      return new ArrayList<PatExamMain>();
    }
    ExamResultParam examResultParamToday = new ExamResultParam();
    examResultParamToday.setPatId(patExamMain.getPatId());
    examResultParamToday.setExamMainCd(patExamMain.getExamMainCd());
    examResultParamToday.setFacilityCd(patExamMain.getFacilityCd());

    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
    String targetDt = sdf.format(patExamMain.getResultExamDate());
    Timestamp timestamp = new Timestamp(System.currentTimeMillis());
    sdf = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
    String strUpDt = sdf.format(timestamp);
    examResultParamToday.setTargetDt(targetDt);
    examResultParamToday.setStrUpDt(strUpDt);
    examResultParamToday.setTargetDtTime(patExamMain.getResultExamDate());
    examResultParamToday.setRegExamDate(patExamMain.getRegExamDate());
    examResultParamToday.setRegOrderClass(patExamMain.getRegOrderClass());
    Long patId = patExamMain.getPatId();
    Integer SX = patPersonalMainDao.selectById(patId).getPat_sex();
    examResultParamToday.setSex(SX);
    // 性別不明の場合の扱いを施設設定より取得
    String unKnownSexVal = mstFacilitySettingDao.getBySettingNoAndCd(patExamMain.getFacilityCd(), CoreConstant.FacilitySettingNo.PAT_SEX_NON).getValue();
    examResultParamToday.setUnKnownSexVal(unKnownSexVal);
    //取得パケットexamResultParamLast.getPatExamMains()で取得
    this.getExamResult(examResultParamToday);
    return examResultParamToday.getPatExamMains();
  }
  //add 9737 TAC_BUN修正 gjn end


  /**
   * システム計算処理
   *
   * @param recalculationExamItem
   * @param lstCalculated
   * @param examResultInfo
   * @param examResultParam
   * @param examResult
   * @return ExamResult
   * @throws ParseException
   * @throws JsonProcessingException
   */
  private ExamResult systemStandardCalculationItemHandle(List<Long> recalculationExamItem, List<String> lstCalculated, List<PatExamMainExamResultInfo> examResultInfo,
                                                         ExamResultParam examResultParam, ExamResult examResult) throws ParseException, JsonProcessingException {
    // 検査結果を1件ずつ確認して計算項目の再計算を行う
    examResult = this.getExamResult(examResultParam);
    for (int idx = 0; idx < examResultInfo.size(); idx++) {
      PatExamMainExamResultInfo result = examResultInfo.get(idx);
      // add FNSI-改修内容redmain6183 任 start*/
      examResultParam.setSystemDefaultCalcFormulaId(ExamItemSystemDefaultCalcFormulaId.BMI);
      List<PatExamMainExamResultInfo> lstExamResultInfoBmi = makeExamResultInfo(examResultParam, examResult);
      for (PatExamMainExamResultInfo info : lstExamResultInfoBmi) {
        // 結果をUPSERT
        boolean isUpd = false;
        for (int idx2 = 0; idx2 < examResultInfo.size(); idx2++) {
          if (info.getItem_cd().equals(examResultInfo.get(idx2).getItem_cd())) {
            info.setFreememo(examResultInfo.get(idx2).getFreememo());
            examResultInfo.set(idx2, info);
            isUpd = true;
          }
        }
        if (!isUpd) {
          examResultInfo.add(info);
        }
      }
      // add FNSI-改修内容redmain6183 任 end
      //TODO 检查项目
      if (result.getExam_class().equals(ExamClass.EXAM_ITEM)) {
        // 検査項目
        MstExamItem examItem = this.getMstExamItem(examResultParam.getMstExamItems(), result);
        // mod FNSI-No196 透析前後の判断の最適化 関 start
        // if (examItem != null) {
        if (examItem != null && examItem.getIsDisp().equals("1")) {
          // mod FNSI-No196 透析前後の判断の最適化 関 end
          //add FNSI-検証値が空です 関 start
          if (examItem.getFreeCalc() == null) {
            examItem.setFreeCalc("");
          }
          if (examItem.getDefaultCalcExamItemCd() == null) {
            continue;
          }
          //add FNSI-検証値が空です 関 end
          if (examItem.getDefaultCalcExamItemCd().equals(ExamResultCalcConstant.ExamResultCalcColumns.BUN)) {
            // BUN
            // KT/V
            if (!lstCalculated.contains(ExamItemSystemDefaultCalcFormulaId.KT_V)) {
              // 計算済み・更新を行う検査結果一覧を取得
              examResultParam.setSystemDefaultCalcFormulaId(ExamItemSystemDefaultCalcFormulaId.KT_V);
              List<PatExamMainExamResultInfo> lstExamResultInfo = makeExamResultInfo(examResultParam, examResult);
              for (PatExamMainExamResultInfo info : lstExamResultInfo) {
                // 結果をUPSERT
                boolean isUpd = false;
                for (int idx2 = 0; idx2 < examResultInfo.size(); idx2++) {
                  if (examResultInfo.get(idx2).getItem_cd().equals(info.getItem_cd())) {
                    info.setFreememo(examResultInfo.get(idx2).getFreememo());
                    examResultInfo.set(idx2, info);
                    isUpd = true;
                    break;
                  }
                }
                if (!isUpd) {
                  examResultInfo.add(info);
                }
              }
              lstCalculated.add(ExamItemSystemDefaultCalcFormulaId.KT_V);
            }
            // KT/Ve
            if (!lstCalculated.contains(ExamItemSystemDefaultCalcFormulaId.KT_VE)) {
              // 計算済み・更新を行う検査結果一覧を取得
              examResultParam.setSystemDefaultCalcFormulaId(ExamItemSystemDefaultCalcFormulaId.KT_VE);
              List<PatExamMainExamResultInfo> lstExamResultInfo = makeExamResultInfo(examResultParam, examResult);
              for (PatExamMainExamResultInfo info : lstExamResultInfo) {
                // 結果をUPSERT
                boolean isUpd = false;
                for (int idx2 = 0; idx2 < examResultInfo.size(); idx2++) {
                  if (examResultInfo.get(idx2).getItem_cd().equals(info.getItem_cd())) {
                    info.setFreememo(examResultInfo.get(idx2).getFreememo());
                    examResultInfo.set(idx2, info);
                    isUpd = true;
                    break;
                  }
                }
                if (!isUpd) {
                  examResultInfo.add(info);
                }
              }
              lstCalculated.add(ExamItemSystemDefaultCalcFormulaId.KT_VE);
            }
            // KT/Vsp
            if (!lstCalculated.contains(ExamItemSystemDefaultCalcFormulaId.KT_VSP)) {
              // 計算済み・更新を行う検査結果一覧を取得
              examResultParam.setSystemDefaultCalcFormulaId(ExamItemSystemDefaultCalcFormulaId.KT_VSP);
              List<PatExamMainExamResultInfo> lstExamResultInfo = makeExamResultInfo(examResultParam, examResult);
              for (PatExamMainExamResultInfo info : lstExamResultInfo) {
                // 結果をUPSERT
                boolean isUpd = false;
                for (int idx2 = 0; idx2 < examResultInfo.size(); idx2++) {
                  if (examResultInfo.get(idx2).getItem_cd().equals(info.getItem_cd())) {
                    info.setFreememo(examResultInfo.get(idx2).getFreememo());
                    examResultInfo.set(idx2, info);
                    isUpd = true;
                    break;
                  }
                }
                if (!isUpd) {
                  examResultInfo.add(info);
                }
              }
              lstCalculated.add(ExamItemSystemDefaultCalcFormulaId.KT_VSP);
            }
            // Daugirdas Kt/V
            if (!lstCalculated.contains(ExamItemSystemDefaultCalcFormulaId.DAUGIRDAS_KT_V)) {
              // 計算済み・更新を行う検査結果一覧を取得
              examResultParam.setSystemDefaultCalcFormulaId(ExamItemSystemDefaultCalcFormulaId.DAUGIRDAS_KT_V);
              List<PatExamMainExamResultInfo> lstExamResultInfo = makeExamResultInfo(examResultParam, examResult);
              for (PatExamMainExamResultInfo info : lstExamResultInfo) {
                // 結果をUPSERT
                boolean isUpd = false;
                for (int idx2 = 0; idx2 < examResultInfo.size(); idx2++) {
                  if (examResultInfo.get(idx2).getItem_cd().equals(info.getItem_cd())) {
                    info.setFreememo(examResultInfo.get(idx2).getFreememo());
                    examResultInfo.set(idx2, info);
                    isUpd = true;
                    break;
                  }
                }
                if (!isUpd) {
                  examResultInfo.add(info);
                }
              }
              lstCalculated.add(ExamItemSystemDefaultCalcFormulaId.DAUGIRDAS_KT_V);
            }
            // BUN除去率
            if (!lstCalculated.contains(ExamItemSystemDefaultCalcFormulaId.EXCLUSION_RATE)) {
              // 計算済み・更新を行う検査結果一覧を取得
              examResultParam.setSystemDefaultCalcFormulaId(ExamItemSystemDefaultCalcFormulaId.EXCLUSION_RATE);
              List<PatExamMainExamResultInfo> lstExamResultInfo = makeExamResultInfo(examResultParam, examResult);
              for (PatExamMainExamResultInfo info : lstExamResultInfo) {
                // 結果をUPSERT
                boolean isUpd = false;
                for (int idx2 = 0; idx2 < examResultInfo.size(); idx2++) {
                  if (examResultInfo.get(idx2).getItem_cd().equals(info.getItem_cd())) {
                    info.setFreememo(examResultInfo.get(idx2).getFreememo());
                    examResultInfo.set(idx2, info);
                    isUpd = true;
                    break;
                  }
                }
                if (!isUpd) {
                  examResultInfo.add(info);
                }
              }
              lstCalculated.add(ExamItemSystemDefaultCalcFormulaId.EXCLUSION_RATE);
            }
            //del 9737 TAC_BUN修正 gjn start
            // TAC_BUN
//            if (!lstCalculated.contains(ExamItemSystemDefaultCalcFormulaId.TAC_BUN)) {
              // 計算済み・更新を行う検査結果一覧を取得
//              examResultParam.setSystemDefaultCalcFormulaId(ExamItemSystemDefaultCalcFormulaId.TAC_BUN);
//              List<PatExamMainExamResultInfo> lstExamResultInfo = makeExamResultInfo(examResultParam, examResult);
//              for (PatExamMainExamResultInfo info : lstExamResultInfo) {
//                // 結果をUPSERT
//                boolean isUpd = false;
//                for (int idx2 = 0; idx2 < examResultInfo.size(); idx2++) {
//                  if (examResultInfo.get(idx2).getItem_cd().equals(info.getItem_cd())) {
//                    info.setFreememo(examResultInfo.get(idx2).getFreememo());
//                    examResultInfo.set(idx2, info);
//                    isUpd = true;
//                    break;
//                  }
//                }
//                if (!isUpd) {
//                  examResultInfo.add(info);
//                }
//              }
//              lstCalculated.add(ExamItemSystemDefaultCalcFormulaId.TAC_BUN);
//            }
            //del 9737 TAC_BUN修正 gjn end
            // クリアスペース率
            if (!lstCalculated.contains(ExamItemSystemDefaultCalcFormulaId.CLEAR_SPACE)) {
              // 計算済み・更新を行う検査結果一覧を取得
              examResultParam.setSystemDefaultCalcFormulaId(ExamItemSystemDefaultCalcFormulaId.CLEAR_SPACE);
              List<PatExamMainExamResultInfo> lstExamResultInfo = makeExamResultInfo(examResultParam, examResult);
              for (PatExamMainExamResultInfo info : lstExamResultInfo) {
                // 結果をUPSERT
                boolean isUpd = false;
                for (int idx2 = 0; idx2 < examResultInfo.size(); idx2++) {
                  if (examResultInfo.get(idx2).getItem_cd().equals(info.getItem_cd())) {
                    info.setFreememo(examResultInfo.get(idx2).getFreememo());
                    examResultInfo.set(idx2, info);
                    isUpd = true;
                    break;
                  }
                }
                if (!isUpd) {
                  examResultInfo.add(info);
                }
              }
              lstCalculated.add(ExamItemSystemDefaultCalcFormulaId.CLEAR_SPACE);
            }
            // PCR
            if (!lstCalculated.contains(ExamItemSystemDefaultCalcFormulaId.PCR)) {
              // 計算済み・更新を行う検査結果一覧を取得
              examResultParam.setSystemDefaultCalcFormulaId(ExamItemSystemDefaultCalcFormulaId.PCR);
              List<PatExamMainExamResultInfo> lstExamResultInfo = makeExamResultInfo(examResultParam, examResult);
              for (PatExamMainExamResultInfo info : lstExamResultInfo) {
                // 結果をUPSERT
                boolean isUpd = false;
                for (int idx2 = 0; idx2 < examResultInfo.size(); idx2++) {
                  if (examResultInfo.get(idx2).getItem_cd().equals(info.getItem_cd())) {
                    info.setFreememo(examResultInfo.get(idx2).getFreememo());
                    examResultInfo.set(idx2, info);
                    isUpd = true;
                    break;
                  }
                }
                if (!isUpd) {
                  examResultInfo.add(info);
                }
              }
              lstCalculated.add(ExamItemSystemDefaultCalcFormulaId.PCR);
            }
            // Kt/V(shinzato)
            if (!lstCalculated.contains(ExamItemSystemDefaultCalcFormulaId.KT_V_SHINZATO)) {
              // 計算済み・更新を行う検査結果一覧を取得
              examResultParam.setSystemDefaultCalcFormulaId(ExamItemSystemDefaultCalcFormulaId.KT_V_SHINZATO);
              List<PatExamMainExamResultInfo> lstExamResultInfo = makeExamResultInfo(examResultParam, examResult);
              for (PatExamMainExamResultInfo info : lstExamResultInfo) {
                // 結果をUPSERT
                boolean isUpd = false;
                for (int idx2 = 0; idx2 < examResultInfo.size(); idx2++) {
                  if (examResultInfo.get(idx2).getItem_cd().equals(info.getItem_cd())) {
                    info.setFreememo(examResultInfo.get(idx2).getFreememo());
                    examResultInfo.set(idx2, info);
                    isUpd = true;
                    break;
                  }
                }
                if (!isUpd) {
                  examResultInfo.add(info);
                }
              }
              lstCalculated.add(ExamItemSystemDefaultCalcFormulaId.KT_V_SHINZATO);
            }
          } else if (examItem.getDefaultCalcExamItemCd().equals(ExamResultCalcConstant.ExamResultCalcColumns.SERUM_CA_CONCENTRATION)) {
            // 血清Ca濃度
            // 補正化 Ca
            if (!lstCalculated.contains(ExamItemSystemDefaultCalcFormulaId.COR_CA)) {
              List<MstExamItem> mstExamItems = mstExamItemDao.selectExamItemSystemDefaultCalc(examResultParam.getFacilityCd(), ExamItemSystemDefaultCalcFormulaId.COR_CA);
              if (mstExamItems.size() > 0) {
                examResultParam.setCorCaItemCd(mstExamItems.get(0).getExamItemCd().toString());
                lstCalculated.add(ExamItemSystemDefaultCalcFormulaId.COR_CA);
              }
            }
          } else if (examItem.getDefaultCalcExamItemCd().equals(ExamResultCalcConstant.ExamResultCalcColumns.SERUM_ALBUMIN_CONCENTRATION)) {
            // 血清アルブミン
            // 補正化 Ca
            if (!lstCalculated.contains(ExamItemSystemDefaultCalcFormulaId.COR_CA)) {
              List<MstExamItem> mstExamItems = mstExamItemDao.selectExamItemSystemDefaultCalc(examResultParam.getFacilityCd(), ExamItemSystemDefaultCalcFormulaId.COR_CA);
              if (mstExamItems.size() > 0) {
                examResultParam.setCorCaItemCd(mstExamItems.get(0).getExamItemCd().toString());
                lstCalculated.add(ExamItemSystemDefaultCalcFormulaId.COR_CA);
              }
            }
            // GNRI
            if (!lstCalculated.contains(ExamItemSystemDefaultCalcFormulaId.GNRI)) {
              // 計算済み・更新を行う検査結果一覧を取得
              examResultParam.setSystemDefaultCalcFormulaId(ExamItemSystemDefaultCalcFormulaId.GNRI);
              List<PatExamMainExamResultInfo> lstExamResultInfo = makeExamResultInfo(examResultParam, examResult);
              for (PatExamMainExamResultInfo info : lstExamResultInfo) {
                // 結果をUPSERT
                boolean isUpd = false;
                for (int idx2 = 0; idx2 < examResultInfo.size(); idx2++) {
                  if (examResultInfo.get(idx2).getItem_cd().equals(info.getItem_cd())) {
                    info.setFreememo(examResultInfo.get(idx2).getFreememo());
                    examResultInfo.set(idx2, info);
                    isUpd = true;
                    break;
                  }
                }
                if (!isUpd) {
                  examResultInfo.add(info);
                }
              }
              lstCalculated.add(ExamItemSystemDefaultCalcFormulaId.GNRI);
            }
          } else if (examItem.getDefaultCalcExamItemCd().equals(ExamResultCalcConstant.ExamResultCalcColumns.CREATININE)) {
            // クレアチニン
            // CreatininIndex
            if (!lstCalculated.contains(ExamItemSystemDefaultCalcFormulaId.CREATININ_INDEX)) {
              // 計算済み・更新を行う検査結果一覧を取得
              examResultParam.setSystemDefaultCalcFormulaId(ExamItemSystemDefaultCalcFormulaId.CREATININ_INDEX);
              List<PatExamMainExamResultInfo> lstExamResultInfo = makeExamResultInfo(examResultParam, examResult);
              for (PatExamMainExamResultInfo info : lstExamResultInfo) {
                // 結果をUPSERT
                boolean isUpd = false;
                for (int idx2 = 0; idx2 < examResultInfo.size(); idx2++) {
                  if (examResultInfo.get(idx2).getItem_cd().equals(info.getItem_cd())) {
                    info.setFreememo(examResultInfo.get(idx2).getFreememo());
                    examResultInfo.set(idx2, info);
                    isUpd = true;
                    break;
                  }
                }
                if (!isUpd) {
                  examResultInfo.add(info);
                }
              }
              lstCalculated.add(ExamItemSystemDefaultCalcFormulaId.CREATININ_INDEX);
            }
            // Cr除去率
            if (!lstCalculated.contains(ExamItemSystemDefaultCalcFormulaId.CR_EXCLUSION_RATE)) {
              // 計算済み・更新を行う検査結果一覧を取得
              examResultParam.setSystemDefaultCalcFormulaId(ExamItemSystemDefaultCalcFormulaId.CR_EXCLUSION_RATE);
              List<PatExamMainExamResultInfo> lstExamResultInfo = makeExamResultInfo(examResultParam, examResult);
              for (PatExamMainExamResultInfo info : lstExamResultInfo) {
                // 結果をUPSERT
                boolean isUpd = false;
                for (int idx2 = 0; idx2 < examResultInfo.size(); idx2++) {
                  if (examResultInfo.get(idx2).getItem_cd().equals(info.getItem_cd())) {
                    info.setFreememo(examResultInfo.get(idx2).getFreememo());
                    examResultInfo.set(idx2, info);
                    isUpd = true;
                    break;
                  }
                }
                if (!isUpd) {
                  examResultInfo.add(info);
                }
              }
              lstCalculated.add(ExamItemSystemDefaultCalcFormulaId.CR_EXCLUSION_RATE);
            }
          } else if (examItem.getDefaultCalcExamItemCd().equals(ExamResultCalcConstant.ExamResultCalcColumns.SERUM_FE)) {
            // 血清鉄
            // TSAT
            if (!lstCalculated.contains(ExamItemSystemDefaultCalcFormulaId.T_SAT)) {
              // 計算済み・更新を行う検査結果一覧を取得
              examResultParam.setSystemDefaultCalcFormulaId(ExamItemSystemDefaultCalcFormulaId.T_SAT);
              List<PatExamMainExamResultInfo> lstExamResultInfo = makeExamResultInfo(examResultParam, examResult);
              for (PatExamMainExamResultInfo info : lstExamResultInfo) {
                // 結果をUPSERT
                boolean isUpd = false;
                for (int idx2 = 0; idx2 < examResultInfo.size(); idx2++) {
                  if (examResultInfo.get(idx2).getItem_cd().equals(info.getItem_cd())) {
                    info.setFreememo(examResultInfo.get(idx2).getFreememo());
                    examResultInfo.set(idx2, info);
                    isUpd = true;
                    break;
                  }
                }
                if (!isUpd) {
                  examResultInfo.add(info);
                }
              }
              lstCalculated.add(ExamItemSystemDefaultCalcFormulaId.T_SAT);
            }
          } else if (examItem.getDefaultCalcExamItemCd().equals(ExamResultCalcConstant.ExamResultCalcColumns.TIBC)) {
            // 総鉄結合能
            // TSAT
            if (!lstCalculated.contains(ExamItemSystemDefaultCalcFormulaId.T_SAT)) {
              // 計算済み・更新を行う検査結果一覧を取得
              examResultParam.setSystemDefaultCalcFormulaId(ExamItemSystemDefaultCalcFormulaId.T_SAT);
              List<PatExamMainExamResultInfo> lstExamResultInfo = makeExamResultInfo(examResultParam, examResult);
              for (PatExamMainExamResultInfo info : lstExamResultInfo) {
                // 結果をUPSERT
                boolean isUpd = false;
                for (int idx2 = 0; idx2 < examResultInfo.size(); idx2++) {
                  if (examResultInfo.get(idx2).getItem_cd().equals(info.getItem_cd())) {
                    info.setFreememo(examResultInfo.get(idx2).getFreememo());
                    examResultInfo.set(idx2, info);
                    isUpd = true;
                    break;
                  }
                }
                if (!isUpd) {
                  examResultInfo.add(info);
                }
              }
              lstCalculated.add(ExamItemSystemDefaultCalcFormulaId.T_SAT);
            }
          }
        }
      //TODO 系统计算项目
      } else if (result.getExam_class().equals(ExamClass.SYSTEM_DEFAULT_CALC_ITEM)) {
        // システム標準計算
        MstExamItem examItem = this.getMstExamItem(examResultParam.getMstExamItemsSys(), result);
        /* mod #IES_6602 by zhangruixue 2023-06-28 --start */
        if (null == examItem || examItem.getIsDisp().equals("0") || StringUtils.isEmpty(examItem.getDefaultCalcExamItemCd())) {
          continue;
        }
        /* mod #IES_6602 by zhangruixue 2023-06-28 --end */
        if (examItem.getDefaultCalcExamItemCd().equals(ExamItemSystemDefaultCalcFormulaId.KT_V)) {
          // KT/V
          // 再計算して反映する
          //add 9735,9741,9729 再計算 guan start
          //recalculationExamItem.size（）＞0はbatch再計算呼び出しから実行されることを表し、通常画面計算呼び出しのrecalculationExamItem.size（）＝＝0
          if (recalculationExamItem.size() > 0 && !recalculationExamItem.contains(examItem.getExamItemCd())) {
            continue;
          }
          //add 9735,9741,9729 再計算 guan end
          examResultParam.setSystemDefaultCalcFormulaId(ExamItemSystemDefaultCalcFormulaId.KT_V);
          examResultParam.setExamResultCalcColumnVal(ExamResultCalcConstant.ExamResultCalcColumns.BUN);
          examResult = this.setResult(examResultParam, examResult);
          Double resultCalc = getCalcKtV(examResult);
          result.setResult(resultCalc == null ? ExamResultCalcConstant.CALC_RESULT_NONE : String.format("%1$.20f", resultCalc));
          result.setResult_date(examResultParam.getStrUpDt());
          examResultInfo.set(idx, result);
          lstCalculated.add(ExamItemSystemDefaultCalcFormulaId.KT_V);
        } else if (examItem.getDefaultCalcExamItemCd().equals(ExamItemSystemDefaultCalcFormulaId.KT_VE)) {
          // KT/Ve
          // 再計算して反映する
          //add 9735,9741,9729 再計算 guan start
          //recalculationExamItem.size（）＞0はbatch再計算呼び出しから実行されることを表し、通常画面計算呼び出しのrecalculationExamItem.size（）＝＝0
          if (recalculationExamItem.size() > 0 && !recalculationExamItem.contains(examItem.getExamItemCd())) {
            continue;
          }
          //add 9735,9741,9729 再計算 guan end
          examResultParam.setSystemDefaultCalcFormulaId(ExamItemSystemDefaultCalcFormulaId.KT_VE);
          examResultParam.setExamResultCalcColumnVal(ExamResultCalcConstant.ExamResultCalcColumns.BUN);
          examResult = this.setResult(examResultParam, examResult);
          Double resultCalc = getCalcKtVe(examResultParam, examResult);
          result.setResult(resultCalc == null ? ExamResultCalcConstant.CALC_RESULT_NONE : String.format("%1$.20f", resultCalc));
          result.setResult_date(examResultParam.getStrUpDt());
          examResultInfo.set(idx, result);
          lstCalculated.add(ExamItemSystemDefaultCalcFormulaId.KT_VE);
        } else if (examItem.getDefaultCalcExamItemCd().equals(ExamItemSystemDefaultCalcFormulaId.KT_VSP)) {
          // KT/Vsp
          // 再計算して反映する
          //add 9735,9741,9729 再計算 guan start
          //recalculationExamItem.size（）＞0はbatch再計算呼び出しから実行されることを表し、通常画面計算呼び出しのrecalculationExamItem.size（）＝＝0
          if (recalculationExamItem.size() > 0 && !recalculationExamItem.contains(examItem.getExamItemCd())) {
            continue;
          }
          //add 9735,9741,9729 再計算 guan end
          examResultParam.setSystemDefaultCalcFormulaId(ExamItemSystemDefaultCalcFormulaId.KT_VSP);
          examResultParam.setExamResultCalcColumnVal(ExamResultCalcConstant.ExamResultCalcColumns.BUN);
          examResult = this.setResult(examResultParam, examResult);
          Double resultCalc = getCalcKtVsp(examResultParam, examResult);
          result.setResult(resultCalc == null ? ExamResultCalcConstant.CALC_RESULT_NONE : String.format("%1$.20f", resultCalc));
          result.setResult_date(examResultParam.getStrUpDt());
          examResultInfo.set(idx, result);
          lstCalculated.add(ExamItemSystemDefaultCalcFormulaId.KT_VSP);
        } else if (examItem.getDefaultCalcExamItemCd().equals(ExamItemSystemDefaultCalcFormulaId.DAUGIRDAS_KT_V)) {
          // Daugirdas Kt/V
          // 再計算して反映する
          //add 9735,9741,9729 再計算 guan start
          //recalculationExamItem.size（）＞0はbatch再計算呼び出しから実行されることを表し、通常画面計算呼び出しのrecalculationExamItem.size（）＝＝0
          if (recalculationExamItem.size() > 0 && !recalculationExamItem.contains(examItem.getExamItemCd())) {
            continue;
          }
          //add 9735,9741,9729 再計算 guan end
          examResultParam.setSystemDefaultCalcFormulaId(ExamItemSystemDefaultCalcFormulaId.DAUGIRDAS_KT_V);
          examResultParam.setExamResultCalcColumnVal(ExamResultCalcConstant.ExamResultCalcColumns.BUN);
          examResult = this.setResult(examResultParam, examResult);
          Double resultCalc = getCalcDaugirdasKtV(examResultParam, examResult);
          result.setResult(resultCalc == null ? ExamResultCalcConstant.CALC_RESULT_NONE : String.format("%1$.20f", resultCalc));
          result.setResult_date(examResultParam.getStrUpDt());
          examResultInfo.set(idx, result);
          lstCalculated.add(ExamItemSystemDefaultCalcFormulaId.DAUGIRDAS_KT_V);
        } else if (examItem.getDefaultCalcExamItemCd().equals(ExamItemSystemDefaultCalcFormulaId.EXCLUSION_RATE)) {
          // BUN除去率
          // 再計算して反映する
          //add 9735,9741,9729 再計算 guan start
          //recalculationExamItem.size（）＞0はbatch再計算呼び出しから実行されることを表し、通常画面計算呼び出しのrecalculationExamItem.size（）＝＝0
          if (recalculationExamItem.size() > 0 && !recalculationExamItem.contains(examItem.getExamItemCd())) {
            continue;
          }
          //add 9735,9741,9729 再計算 guan end
          examResultParam.setSystemDefaultCalcFormulaId(ExamItemSystemDefaultCalcFormulaId.EXCLUSION_RATE);
          examResultParam.setExamResultCalcColumnVal(ExamResultCalcConstant.ExamResultCalcColumns.BUN);
          examResult = this.setResult(examResultParam, examResult);
          Double resultCalc = getCalcExclusionRate(examResult);
          result.setResult(resultCalc == null ? ExamResultCalcConstant.CALC_RESULT_NONE : String.format("%1$.20f", resultCalc));
          result.setResult_date(examResultParam.getStrUpDt());
          examResultInfo.set(idx, result);
          lstCalculated.add(ExamItemSystemDefaultCalcFormulaId.EXCLUSION_RATE);
          //del 9737 TAC_BUN修正 gjn start
//        } else if (examItem.getDefaultCalcExamItemCd().equals(ExamItemSystemDefaultCalcFormulaId.TAC_BUN)) {
          // TAC_BUN
          // 再計算して反映する
//          examResultParam.setSystemDefaultCalcFormulaId(ExamItemSystemDefaultCalcFormulaId.TAC_BUN);
//          examResultParam.setExamResultCalcColumnVal(ExamResultCalcConstant.ExamResultCalcColumns.BUN);
//          examResult = this.setResult(examResultParam, examResult);
//          Double resultCalc = getCalcTacBun(examResultParam, examResult);
//          result.setResult(resultCalc == null ? ExamResultCalcConstant.CALC_RESULT_NONE : String.format("%1$.20f", resultCalc));
//          result.setResult_date(examResultParam.getStrUpDt());
//          examResultInfo.set(idx, result);
//          lstCalculated.add(ExamItemSystemDefaultCalcFormulaId.TAC_BUN);
          //del 9737 TAC_BUN修正 gjn end
        } else if (examItem.getDefaultCalcExamItemCd().equals(ExamItemSystemDefaultCalcFormulaId.COR_CA)) {
          // 補正化 Ca
          // 再計算して反映する
          //add 9735,9741,9729 再計算 guan start
          //recalculationExamItem.size（）＞0はbatch再計算呼び出しから実行されることを表し、通常画面計算呼び出しのrecalculationExamItem.size（）＝＝0
          if (recalculationExamItem.size() > 0 && !recalculationExamItem.contains(examItem.getExamItemCd())) {
            continue;
          }
          //add 9735,9741,9729 再計算 guan end
          examResultParam.setCorCaItemCd(result.getItem_cd());
        } else if (examItem.getDefaultCalcExamItemCd().equals(ExamItemSystemDefaultCalcFormulaId.CLEAR_SPACE)) {
          // クリアスペース率
          // 再計算して反映する
          //add 9735,9741,9729 再計算 guan start
          //recalculationExamItem.size（）＞0はbatch再計算呼び出しから実行されることを表し、通常画面計算呼び出しのrecalculationExamItem.size（）＝＝0
          if (recalculationExamItem.size() > 0 && !recalculationExamItem.contains(examItem.getExamItemCd())) {
            continue;
          }
          //add 9735,9741,9729 再計算 guan end
          examResultParam.setSystemDefaultCalcFormulaId(ExamItemSystemDefaultCalcFormulaId.CLEAR_SPACE);
          examResultParam.setExamResultCalcColumnVal(ExamResultCalcConstant.ExamResultCalcColumns.BUN);
          examResult = this.setResult(examResultParam, examResult);
          Double resultCalc = getCalcClearSpace(examResultParam, examResult);
          result.setResult(resultCalc == null ? ExamResultCalcConstant.CALC_RESULT_NONE : String.format("%1$.20f", resultCalc));
          result.setResult_date(examResultParam.getStrUpDt());
          examResultInfo.set(idx, result);
          lstCalculated.add(ExamItemSystemDefaultCalcFormulaId.CLEAR_SPACE);
        } else if (examItem.getDefaultCalcExamItemCd().equals(ExamItemSystemDefaultCalcFormulaId.PCR)) {
          // PCR
          // 再計算して反映する
          //add 9735,9741,9729 再計算 guan start
          //recalculationExamItem.size（）＞0はbatch再計算呼び出しから実行されることを表し、通常画面計算呼び出しのrecalculationExamItem.size（）＝＝0
          if (recalculationExamItem.size() > 0 && !recalculationExamItem.contains(examItem.getExamItemCd())) {
            continue;
          }
          //add 9735,9741,9729 再計算 guan end
          examResultParam.setSystemDefaultCalcFormulaId(ExamItemSystemDefaultCalcFormulaId.PCR);
          examResultParam.setExamResultCalcColumnVal(ExamResultCalcConstant.ExamResultCalcColumns.BUN);
          examResult = this.setResult(examResultParam, examResult);
          Double resultCalc = getCalcPcr(examResultParam, examResult);
          result.setResult(resultCalc == null ? ExamResultCalcConstant.CALC_RESULT_NONE : String.format("%1$.20f", resultCalc));
          result.setResult_date(examResultParam.getStrUpDt());
          examResultInfo.set(idx, result);
          lstCalculated.add(ExamItemSystemDefaultCalcFormulaId.PCR);
        } else if (examItem.getDefaultCalcExamItemCd().equals(ExamItemSystemDefaultCalcFormulaId.CREATININ_INDEX)) {
          // CreatininIndex
          // 再計算して反映する
          //add 9735,9741,9729 再計算 guan start
          //recalculationExamItem.size（）＞0はbatch再計算呼び出しから実行されることを表し、通常画面計算呼び出しのrecalculationExamItem.size（）＝＝0
          if (recalculationExamItem.size() > 0 && !recalculationExamItem.contains(examItem.getExamItemCd())) {
            continue;
          }
          //add 9735,9741,9729 再計算 guan end
          examResultParam.setSystemDefaultCalcFormulaId(ExamItemSystemDefaultCalcFormulaId.CREATININ_INDEX);
          examResultParam.setExamResultCalcColumnVal(ExamResultCalcConstant.ExamResultCalcColumns.CREATININE);
          examResult = this.setResult(examResultParam, examResult);
          Double resultCalc = getCalcCreatininIndex(examResultParam, examResult);
          result.setResult(resultCalc == null ? ExamResultCalcConstant.CALC_RESULT_NONE : String.format("%1$.20f", resultCalc));
          result.setResult_date(examResultParam.getStrUpDt());
          examResultInfo.set(idx, result);
          lstCalculated.add(ExamItemSystemDefaultCalcFormulaId.CREATININ_INDEX);
        } else if (examItem.getDefaultCalcExamItemCd().equals(ExamItemSystemDefaultCalcFormulaId.KT_V_SHINZATO)) {
          // Kt/V(shinzato)
          // 再計算して反映する
          //add 9735,9741,9729 再計算 guan start
          //recalculationExamItem.size（）＞0はbatch再計算呼び出しから実行されることを表し、通常画面計算呼び出しのrecalculationExamItem.size（）＝＝0
          if (recalculationExamItem.size() > 0 && !recalculationExamItem.contains(examItem.getExamItemCd())) {
            continue;
          }
          //add 9735,9741,9729 再計算 guan end
          examResultParam.setSystemDefaultCalcFormulaId(ExamItemSystemDefaultCalcFormulaId.KT_V_SHINZATO);
          examResultParam.setExamResultCalcColumnVal(ExamResultCalcConstant.ExamResultCalcColumns.BUN);
          examResult = this.setResult(examResultParam, examResult);
          Double resultCalc = getCalcKtVShinzato(examResultParam, examResult);
          result.setResult(resultCalc == null ? ExamResultCalcConstant.CALC_RESULT_NONE : String.format("%1$.20f", resultCalc));
          result.setResult_date(examResultParam.getStrUpDt());
          examResultInfo.set(idx, result);
          lstCalculated.add(ExamItemSystemDefaultCalcFormulaId.KT_V_SHINZATO);
        } else if (examItem.getDefaultCalcExamItemCd().equals(ExamItemSystemDefaultCalcFormulaId.BMI)) {
          // BMI
          // 再計算して反映する
          //add 9735,9741,9729 再計算 guan start
          //recalculationExamItem.size（）＞0はbatch再計算呼び出しから実行されることを表し、通常画面計算呼び出しのrecalculationExamItem.size（）＝＝0
          if (recalculationExamItem.size() > 0 && !recalculationExamItem.contains(examItem.getExamItemCd())) {
            continue;
          }
          //add 9735,9741,9729 再計算 guan end
          examResultParam.setSystemDefaultCalcFormulaId(ExamItemSystemDefaultCalcFormulaId.BMI);
          examResultParam.setExamResultCalcColumnVal(ExamResultCalcConstant.ExamResultCalcColumns.BUN);
          examResult = this.setResult(examResultParam, examResult);
          Double resultCalc = getCalcBmi(examResultParam, examResult);
          result.setResult(resultCalc == null ? ExamResultCalcConstant.CALC_RESULT_NONE : String.format("%1$.20f", resultCalc));
          result.setResult_date(examResultParam.getStrUpDt());
          examResultInfo.set(idx, result);
          lstCalculated.add(ExamItemSystemDefaultCalcFormulaId.BMI);
        } else if (examItem.getDefaultCalcExamItemCd().equals(ExamItemSystemDefaultCalcFormulaId.GNRI)) {
          // GNRI
          // 再計算して反映する
          //add 9735,9741,9729 再計算 guan start
          //recalculationExamItem.size（）＞0はbatch再計算呼び出しから実行されることを表し、通常画面計算呼び出しのrecalculationExamItem.size（）＝＝0
          if (recalculationExamItem.size() > 0 && !recalculationExamItem.contains(examItem.getExamItemCd())) {
            continue;
          }
          //add 9735,9741,9729 再計算 guan end
          examResultParam.setSystemDefaultCalcFormulaId(ExamItemSystemDefaultCalcFormulaId.GNRI);
          examResultParam.setExamResultCalcColumnVal(ExamResultCalcConstant.ExamResultCalcColumns.SERUM_ALBUMIN_CONCENTRATION);
          examResult = this.setResult(examResultParam, examResult);
          Double resultCalc = getCalcGnri(examResultParam, examResult);
          result.setResult(resultCalc == null ? ExamResultCalcConstant.CALC_RESULT_NONE : String.format("%1$.20f", resultCalc));
          result.setResult_date(examResultParam.getStrUpDt());
          examResultInfo.set(idx, result);
          lstCalculated.add(ExamItemSystemDefaultCalcFormulaId.GNRI);
        } else if (examItem.getDefaultCalcExamItemCd().equals(ExamItemSystemDefaultCalcFormulaId.CR_EXCLUSION_RATE)) {
          // Cr除去率
          // 再計算して反映する
          //add 9735,9741,9729 再計算 guan start
          //recalculationExamItem.size（）＞0はbatch再計算呼び出しから実行されることを表し、通常画面計算呼び出しのrecalculationExamItem.size（）＝＝0
          if (recalculationExamItem.size() > 0 && !recalculationExamItem.contains(examItem.getExamItemCd())) {
            continue;
          }
          //add 9735,9741,9729 再計算 guan end
          examResultParam.setSystemDefaultCalcFormulaId(ExamItemSystemDefaultCalcFormulaId.CR_EXCLUSION_RATE);
          examResultParam.setExamResultCalcColumnVal(ExamResultCalcConstant.ExamResultCalcColumns.CREATININE);
          examResult = this.setResult(examResultParam, examResult);
          Double resultCalc = getCalcCrExclusionRate(examResult);
          result.setResult(resultCalc == null ? ExamResultCalcConstant.CALC_RESULT_NONE : String.format("%1$.20f", resultCalc));
          result.setResult_date(examResultParam.getStrUpDt());
          examResultInfo.set(idx, result);
          lstCalculated.add(ExamItemSystemDefaultCalcFormulaId.CR_EXCLUSION_RATE);
        } else if (examItem.getDefaultCalcExamItemCd().equals(ExamItemSystemDefaultCalcFormulaId.T_SAT)) {
          // TSAT
          // 再計算して反映する
          //add 9735,9741,9729 再計算 guan start
          //recalculationExamItem.size（）＞0はbatch再計算呼び出しから実行されることを表し、通常画面計算呼び出しのrecalculationExamItem.size（）＝＝0
          if (recalculationExamItem.size() > 0 && !recalculationExamItem.contains(examItem.getExamItemCd())) {
            continue;
          }
          //add 9735,9741,9729 再計算 guan end
          examResultParam.setSystemDefaultCalcFormulaId(ExamItemSystemDefaultCalcFormulaId.T_SAT);
          examResultParam.setExamResultCalcColumnVal(ExamResultCalcConstant.ExamResultCalcColumns.SERUM_FE);
          examResult = this.setResult(examResultParam, examResult);
          Double resultCalc = getCalcTsat(examResult);
          result.setResult(resultCalc == null ? ExamResultCalcConstant.CALC_RESULT_NONE : String.format("%1$.20f", resultCalc));
          result.setResult_date(examResultParam.getStrUpDt());
          examResultInfo.set(idx, result);
          lstCalculated.add(ExamItemSystemDefaultCalcFormulaId.T_SAT);
        }
      }
    }
    return examResult;
  }





  private MstExamItem getMstExamItem(List<MstExamItem> mstExamItems, PatExamMainExamResultInfo result) {
    Optional<MstExamItem> item = mstExamItems.stream().filter(x -> x.getExamItemCd().toString().equals(result.getItem_cd())).findFirst();
    if (item.isPresent()) {
      return item.get();
    } else {
      return null;
    }
  }

  /**
   * 計算項目のチェック（カスタム計算）処理
   *
   * @param recalculationExamItem
   * @param resultInfo
   * @param examResultInfo
   * @param examResultParam
   * @return
   * @throws IOException
   */
  private List<PatExamMainExamResultInfo> inspectionCalculationItemHandle(List<Long> recalculationExamItem, String resultInfo,
                                                                          List<PatExamMainExamResultInfo> examResultInfo, ExamResultParam examResultParam) throws IOException {
    // 登録済みの検査計算を全件行う
    List<MstExamItem> lstUserExamCalc = mstExamItemDao.selectExamItemUserExamCalc(examResultParam.getFacilityCd());
    for (MstExamItem userExamCalc : lstUserExamCalc) {
      // add FNSI-No196 透析前後の判断の最適化 関 start
      if (userExamCalc.getIsDisp().equals("0")) {
        continue;
      }
      // add FNSI-No196 透析前後の判断の最適化 関 end
      //add 9735,9741,9729 再計算 guan start
      //recalculationExamItem.size（）＞0はbatch再計算呼び出しから実行されることを表し、通常画面計算呼び出しのrecalculationExamItem.size（）＝＝0
      if (recalculationExamItem.size() > 0 && !recalculationExamItem.contains(userExamCalc.getExamItemCd())) {
        continue;
      }
      //add 9735,9741,9729 再計算 guan end
      Double valCalculation = getExamCalc(examResultParam, userExamCalc.getFreeCalc());

      PatExamMainExamResultInfo resultUserExamCalc = new PatExamMainExamResultInfo() {
        {
          setItem_cd(userExamCalc.getExamItemCd().toString());
          // mod FNSI-小数点桁数制御 江 start
          //setResult(valCalculation == null ? ExamResultCalcConstant.CALC_RESULT_NONE : String.format("%1$.2f", valCalculation));
          setResult(valCalculation == null ? ExamResultCalcConstant.CALC_RESULT_NONE : String.format("%1$.20f", valCalculation));
          // mod FNSI-小数点桁数制御 江 end
          setHl("");
          setCom_cd("");
          setFreememo("");
          setResult_date(examResultParam.getStrUpDt());
          setItem_name(userExamCalc.getExamItemName());
          setUnit(userExamCalc.getUnit());
          setExam_class(userExamCalc.getExamClass());
          //add #12462 患者情報共有 zrx start
          setJlac10_cd(userExamCalc.getJlac10Cd());
          //add #12462 患者情報共有 zrx end
        }
      };
      // 結果をUPSERT
      boolean isUpd = false;
      for (int idx2 = 0; idx2 < examResultInfo.size(); idx2++) {
        if (resultUserExamCalc.getItem_cd().equals(examResultInfo.get(idx2).getItem_cd())) {
          resultUserExamCalc.setFreememo(examResultInfo.get(idx2).getFreememo());
          examResultInfo.set(idx2, resultUserExamCalc);
          isUpd = true;
          break;
        }
      }
      if (!isUpd) {
        examResultInfo.add(resultUserExamCalc);
      }
    }
    List<PatExamMainExamResultInfo> dispExamResultInfo = new ArrayList<>();
    for (int i = 0; i < examResultInfo.size(); i++) {
      MstExamItem examItem = mstExamItemDao.selectByExamItemCd(examResultInfo.get(i).getItem_cd() != null ? Long.parseLong(examResultInfo.get(i).getItem_cd()) : null);
      if (examItem!=null && examItem.getIsDisp().equals("1")) {
        dispExamResultInfo.add(examResultInfo.get(i));
      }
    }
    return dispExamResultInfo;
  }

  //mod 9615 因島帳票の表示不具合（検査結果出力1~4）zhao start
  private void editGroup(List<PatExamMainExamResultInfo> examResultInfo, ExamResult examResult, String facilityCd) throws IOException {
    List<PatExamMain> patExamMainList = examResult.getPatExamMainList();
    for (PatExamMain patExamMain : patExamMainList) {
      String info = patExamMain.getExamResultInfo();
      List<PatExamMainExamResultInfo> resInfo = new ObjectMapper().readValue(info, new TypeReference<List<PatExamMainExamResultInfo>>() {});
      //boolean finalIsEquals = isEquals;
      resInfo = resInfo.stream().map(x -> {
        for (PatExamMainExamResultInfo y : examResultInfo) {
          if (x.getItem_cd().equals(y.getItem_cd())) {
            return y;
          }
        }
        return x;
      }).collect(Collectors.toList());
      resInfo.addAll(examResultInfo);
      //mod 10140 検査計算にて計算結果が計算できない項目で空データが登録される gjn start
      resInfo = resInfo.stream().filter(f -> (!StringUtils.isEmpty(f.getResult()))).distinct().collect(Collectors.toList());
      //mod 10140 検査計算にて計算結果が計算できない項目で空データが登録される gjn end
      //add 10372 フィルタの種類によってグループタブからフィルタ設定できるようにする gjn start
      this.checkMaxAndMinValue(resInfo, patExamMain.getFacilityCd(), patExamMain.getPatId());
      //add 10372 フィルタの種類によってグループタブからフィルタ設定できるようにする gjn end
      StringBuilder strUpdResultInfo = new StringBuilder();
      strUpdResultInfo.append("[");
      for (PatExamMainExamResultInfo examResultOne : resInfo) {
        //add 9615 因島帳票の表示不具合（検査結果出力1~4）zhao start
        examResultOne = this.getDecimal(examResultOne,facilityCd);
        //add 9615 因島帳票の表示不具合（検査結果出力1~4）zhao end
        strUpdResultInfo.append(examResultOne.getValue());
        strUpdResultInfo.append(",");
      }
      strUpdResultInfo.deleteCharAt(strUpdResultInfo.length() - 1);
      strUpdResultInfo.append("]");
      // 計算完了後検査結果を更新する
      patExamMain.setExamResultInfo(strUpdResultInfo.toString());
      patExamMain.setUpDate(new Timestamp(System.currentTimeMillis()));
      patExamMainDao.updateResultExamSetInfo(patExamMain);
    }
  }

  //add 10372 フィルタの種類によってグループタブからフィルタ設定できるようにする gjn start
  /**
   * 計算後の正常範囲値のサンプリングロジックのチェック（性別や共通による）
   *
   * @param resInfo
   * @param facilityCd
   * @param patId
   * @return
   */
  private List<PatExamMainExamResultInfo> checkMaxAndMinValue(List<PatExamMainExamResultInfo> resInfo, String facilityCd, Long patId) {
    //患者の性別取得
    PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(patId);
    // 施設設定マスタから 検査結果取込 項目コード出力先設定機能 の設定値を取得
    final FacilitySettingInfo settingValue
      = mstFacilitySettingDao.getBySettingNoAndCd(facilityCd, CoreConstant.FacilitySettingNo.PAT_SEX_NON);
    String value = settingValue.getValue();
    //全ての検査結果における検査項目（入力項）、System計算式を補足し、計算項目計算式（自由計算式）の範囲u最大値最小値、及び単位値を検査する
    List<Long> itemCdList = new ArrayList<>();
    List<MstExamItem> mstExamItems = new ArrayList<>();
    resInfo.forEach(r -> {
      itemCdList.add(r.getItem_cd() != null ? Long.parseLong(r.getItem_cd()) : null);
    });
    if (itemCdList.size() > 0) {
      mstExamItems = mstExamItemDao.selectByExamItemCdList(facilityCd, itemCdList);
    }
    for (MstExamItem mstExamItem : mstExamItems) {
      for (PatExamMainExamResultInfo patExamMainExamResultInfo : resInfo) {
        if (patExamMainExamResultInfo.getItem_cd().equals(String.valueOf(mstExamItem.getExamItemCd()))) {
          patExamMainExamResultInfo.setUnit(mstExamItem.getUnit()); // 単位
          //共通か男女かを判定する
          if ("0".equals(mstExamItem.getNormalValueClass())) { //共通
            patExamMainExamResultInfo.setLower(String.valueOf(mstExamItem.getNormalValueLower()));
            patExamMainExamResultInfo.setUpper(String.valueOf(mstExamItem.getNormalValueUpper()));
          } else {
            //患者の性別を判断する
            if (patPersonalMain.getPat_sex() == 1) { //男
              patExamMainExamResultInfo.setLower(String.valueOf(mstExamItem.getNormalValueLowerM()));
              patExamMainExamResultInfo.setUpper(String.valueOf(mstExamItem.getNormalValueUpperM()));
            } else if (patPersonalMain.getPat_sex() == 2) { //女
              patExamMainExamResultInfo.setLower(String.valueOf(mstExamItem.getNormalValueLowerW()));
              patExamMainExamResultInfo.setUpper(String.valueOf(mstExamItem.getNormalValueUpperW()));
            } else { // FacilitySetting構成による代入が不明です
              if ("1".equals(value)) { // 男性に不明
                patExamMainExamResultInfo.setLower(String.valueOf(mstExamItem.getNormalValueLowerM()));
                patExamMainExamResultInfo.setUpper(String.valueOf(mstExamItem.getNormalValueUpperM()));
              } else if ("2".equals(value)) { // 女性に不明
                patExamMainExamResultInfo.setLower(String.valueOf(mstExamItem.getNormalValueLowerW()));
                patExamMainExamResultInfo.setUpper(String.valueOf(mstExamItem.getNormalValueUpperW()));
              } else { // 不明な場合にnullを与える
                patExamMainExamResultInfo.setLower(null);
                patExamMainExamResultInfo.setUpper(null);
              }
            }
          }
        }
      }
    }
    return resInfo;
  }
  //add 10372 フィルタの種類によってグループタブからフィルタ設定できるようにする gjn end

  //add 9737 TAC_BUN修正 gjn start
  /**
   * 検査結果取得MSTにおける検査区分
   *
   * @param mstExamItemsList
   * @param patExamMain1
   * @return
   */
  private String checkExamForType (List<MstExamItem> mstExamItemsList, PatExamMain patExamMain1) {
    List<PatExamMainExamResultInfo> examResultInfos = null;
    try {
      //取得当时の検査结果
      examResultInfos = null != patExamMain1 && (patExamMain1.getExamResultInfo() == null || patExamMain1.getExamResultInfo().isEmpty()) ?
        new ArrayList<>() : new ObjectMapper().readValue(patExamMain1.getExamResultInfo(), new TypeReference<List<PatExamMainExamResultInfo>>() {});
    } catch (JsonProcessingException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (patExamMain1 !=null && !StringUtils.isEmpty(patExamMain1.getFacilityCd())) {
        eventLogMessage.setFacilityCd(patExamMain1.getFacilityCd());
      }
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
    }
    examResultInfos = examResultInfos.stream().filter(f -> ("0".equals(f.getExam_class()))).distinct().collect(Collectors.toList());
    String dialysisProgressFlag = "";
    if (examResultInfos.size() == 1) {
      for (MstExamItem mstExamItems : mstExamItemsList) {
        String examItemCd = String.valueOf(mstExamItems.getExamItemCd());
        if (examItemCd.equals(examResultInfos.get(0).getItem_cd())) {
          dialysisProgressFlag = mstExamItems.getDialysisProgressFlag();
        }
      }
    } else if (examResultInfos.size() > 1) {
      for (MstExamItem mstExamItems : mstExamItemsList) {
        String examItemCd = String.valueOf(mstExamItems.getExamItemCd());
        for (PatExamMainExamResultInfo patExamMainExamResultInfo : examResultInfos) {
          if (examItemCd.equals(patExamMainExamResultInfo.getItem_cd())) {
            dialysisProgressFlag = mstExamItems.getDialysisProgressFlag();
          }
        }
      }
    }
    return dialysisProgressFlag;
  }
  //add 9737 TAC_BUN修正 gjn end




  //add 9737 Ca gjn start
  /**
   * 文字列をBigDecimalタイプに変換できるかどうかを判断する
   *
   * @param str
   * @return boolean
   */
  public static boolean isBigDecimal(String str){
    if(str==null || str.trim().length() == 0){
      return false;
    }
    char[] chars = str.toCharArray();
    int sz = chars.length;
    int i = (chars[0] == '-') ? 1 : 0;
    if(i == sz) return false;

    if(chars[i] == '.') return false;//マイナス記号を除いて、1位は「小数点」ではありません

    boolean radixPoint = false;
    for(; i < sz; i++){
      if(chars[i] == '.'){
        if(radixPoint) return false;
        radixPoint = true;
      }else if(!(chars[i] >= '0' && chars[i] <= '9')){
        return false;
      }
    }
    return true;
  }
  //add 9737 Ca gjn end


  //mod 10188 検査計算の有効桁数について gjn start
  //add 9615 因島帳票の表示不具合（検査結果出力1~4）zhao start
  private PatExamMainExamResultInfo getDecimal(PatExamMainExamResultInfo examResultOne,String facilityCd){
    List<MstExamItem> mstExamItemList = mstExamItemDao.selectByFacilityCd(facilityCd);
    //add 10508 検査計算処理を行った後の文字型以外の桁合わせ処理で検査計算項目以外の通常検査項目に対して桁合わせが行われる gjn start
    // 小数点以下の桁数のチェックを行う場合は計算式（自由計算とシステム計算）をチェックし、チェック項目の入力のチェックを除外するだけ
    mstExamItemList = mstExamItemList.stream().filter(f -> (!"0".equals(f.getExamClass()))).distinct().collect(Collectors.toList());
    //add 10508 検査計算処理を行った後の文字型以外の桁合わせ処理で検査計算項目以外の通常検査項目に対して桁合わせが行われる gjn end
    int point = 0;
    for(int i=0;i<mstExamItemList.size();i++){
      // add 10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy start
      if ("0".equals(mstExamItemList.get(i).getDataType())) {
        continue;
      }
      // add 10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy end
      if(examResultOne.getItem_cd().equals(mstExamItemList.get(i).getExamItemCd().toString())
        && !StringUtils.isEmpty(examResultOne.getResult()) && isBigDecimal(examResultOne.getResult())){
        if(mstExamItemList.get(i).getInputDecimalFigure()!=null){
          point=mstExamItemList.get(i).getInputDecimalFigure();
        }else {
          point=2;
        }
        examResultOne.setResult(new BigDecimal(examResultOne.getResult()).setScale(point,BigDecimal.ROUND_DOWN).toPlainString());
        continue;
      }
    }
    return examResultOne;
  }
  //add 9615 因島帳票の表示不具合（検査結果出力1~4）zhao end
  //mod 10188 検査計算の有効桁数について gjn end
  /**
   * システム標準検査結果を計算する
   */
  private List<PatExamMainExamResultInfo> makeExamResultInfo(ExamResultParam examResultParam, ExamResult examResult) {
    //mod 透析前後の判断の最適化 関 end
    List<PatExamMainExamResultInfo> ret = new ArrayList<PatExamMainExamResultInfo>();
    // 指定したシステム標準計算が設定された検査一覧を取得する
    List<MstExamItem> lstDefaultCalcItem = mstExamItemDao.selectExamItemSystemDefaultCalc(examResultParam.getFacilityCd(), examResultParam.getSystemDefaultCalcFormulaId());
    if (lstDefaultCalcItem.size() > 0) {
      // 計算実行
      Double valCalculation = 0.0;
      //mod 透析前後の判断の最適化 関 start
      if (examResultParam.getSystemDefaultCalcFormulaId().equals(ExamItemSystemDefaultCalcFormulaId.KT_V)) {
        examResultParam.setExamResultCalcColumnVal(ExamResultCalcConstant.ExamResultCalcColumns.BUN);
        examResult = this.setResult(examResultParam, examResult);
        valCalculation = getCalcKtV(examResult);
      } else if (examResultParam.getSystemDefaultCalcFormulaId().equals(ExamItemSystemDefaultCalcFormulaId.KT_VE)) {
        examResultParam.setExamResultCalcColumnVal(ExamResultCalcConstant.ExamResultCalcColumns.BUN);
        examResult = this.setResult(examResultParam, examResult);
        valCalculation = getCalcKtVe(examResultParam, examResult);
      } else if (examResultParam.getSystemDefaultCalcFormulaId().equals(ExamItemSystemDefaultCalcFormulaId.KT_VSP)) {
        examResultParam.setExamResultCalcColumnVal(ExamResultCalcConstant.ExamResultCalcColumns.BUN);
        examResult = this.setResult(examResultParam, examResult);
        valCalculation = getCalcKtVsp(examResultParam, examResult);
      } else if (examResultParam.getSystemDefaultCalcFormulaId().equals(ExamItemSystemDefaultCalcFormulaId.DAUGIRDAS_KT_V)) {
        examResultParam.setExamResultCalcColumnVal(ExamResultCalcConstant.ExamResultCalcColumns.BUN);
        examResult = this.setResult(examResultParam, examResult);
        valCalculation = getCalcDaugirdasKtV(examResultParam, examResult);
      } else if (examResultParam.getSystemDefaultCalcFormulaId().equals(ExamItemSystemDefaultCalcFormulaId.EXCLUSION_RATE)) {
        examResultParam.setExamResultCalcColumnVal(ExamResultCalcConstant.ExamResultCalcColumns.BUN);
        examResult = this.setResult(examResultParam, examResult);
        valCalculation = getCalcExclusionRate(examResult);
        //del 9737 TAC_BUN修正 gjn start
      //} else if (examResultParam.getSystemDefaultCalcFormulaId().equals(ExamItemSystemDefaultCalcFormulaId.TAC_BUN)) {
       //examResultParam.setExamResultCalcColumnVal(ExamResultCalcConstant.ExamResultCalcColumns.BUN);
       //examResult = this.setResult(examResultParam, examResult);
       //valCalculation = getCalcTacBun(examResultParam, examResult);
       // del 9737 TAC_BUN修正 gjn end
      } else if (examResultParam.getSystemDefaultCalcFormulaId().equals(ExamItemSystemDefaultCalcFormulaId.COR_CA)) {
        examResultParam.setExamResultCalcColumnVal(ExamResultCalcConstant.ExamResultCalcColumns.SERUM_CA_CONCENTRATION);
        examResult = this.setResult(examResultParam, examResult);
        valCalculation = getCalcCorCa(examResult);
      } else if (examResultParam.getSystemDefaultCalcFormulaId().equals(ExamItemSystemDefaultCalcFormulaId.CLEAR_SPACE)) {
        examResultParam.setExamResultCalcColumnVal(ExamResultCalcConstant.ExamResultCalcColumns.BUN);
        examResult = this.setResult(examResultParam, examResult);
        valCalculation = getCalcClearSpace(examResultParam, examResult);
      } else if (examResultParam.getSystemDefaultCalcFormulaId().equals(ExamItemSystemDefaultCalcFormulaId.PCR)) {
        examResultParam.setExamResultCalcColumnVal(ExamResultCalcConstant.ExamResultCalcColumns.BUN);
        examResult = this.setResult(examResultParam, examResult);
        valCalculation = getCalcPcr(examResultParam, examResult);
      } else if (examResultParam.getSystemDefaultCalcFormulaId().equals(ExamItemSystemDefaultCalcFormulaId.CREATININ_INDEX)) {
        examResultParam.setExamResultCalcColumnVal(ExamResultCalcConstant.ExamResultCalcColumns.CREATININE);
        examResult = this.setResult(examResultParam, examResult);
        valCalculation = getCalcCreatininIndex(examResultParam, examResult);
      } else if (examResultParam.getSystemDefaultCalcFormulaId().equals(ExamItemSystemDefaultCalcFormulaId.KT_V_SHINZATO)) {
        examResultParam.setExamResultCalcColumnVal(ExamResultCalcConstant.ExamResultCalcColumns.BUN);
        examResult = this.setResult(examResultParam, examResult);
        valCalculation = getCalcKtVShinzato(examResultParam, examResult);
      } else if (examResultParam.getSystemDefaultCalcFormulaId().equals(ExamItemSystemDefaultCalcFormulaId.BMI)) {
        examResultParam.setExamResultCalcColumnVal(ExamResultCalcConstant.ExamResultCalcColumns.BUN);
        examResult = this.setResult(examResultParam, examResult);
        valCalculation = getCalcBmi(examResultParam, examResult);
      } else if (examResultParam.getSystemDefaultCalcFormulaId().equals(ExamItemSystemDefaultCalcFormulaId.GNRI)) {
        examResultParam.setExamResultCalcColumnVal(ExamResultCalcConstant.ExamResultCalcColumns.SERUM_ALBUMIN_CONCENTRATION);
        examResult = this.setResult(examResultParam, examResult);
        valCalculation = getCalcGnri(examResultParam, examResult);
      } else if (examResultParam.getSystemDefaultCalcFormulaId().equals(ExamItemSystemDefaultCalcFormulaId.CR_EXCLUSION_RATE)) {
        examResultParam.setExamResultCalcColumnVal(ExamResultCalcConstant.ExamResultCalcColumns.CREATININE);
        examResult = this.setResult(examResultParam, examResult);
        valCalculation = getCalcCrExclusionRate(examResult);
      } else if (examResultParam.getSystemDefaultCalcFormulaId().equals(ExamItemSystemDefaultCalcFormulaId.T_SAT)) {
        examResultParam.setExamResultCalcColumnVal(ExamResultCalcConstant.ExamResultCalcColumns.SERUM_FE);
        examResult = this.setResult(examResultParam, examResult);
        valCalculation = getCalcTsat(examResult);
      }
      for (MstExamItem defaultCalcItem : lstDefaultCalcItem) {
        // システム標準計算設定された検査項目を再計算して検査結果に登録する
        PatExamMainExamResultInfo resultCalc = new PatExamMainExamResultInfo() {
          {
            setItem_cd(defaultCalcItem.getExamItemCd().toString());
            setHl("");
            setCom_cd("");
            setFreememo("");
            setResult_date(examResultParam.getStrUpDt());
            setItem_name(defaultCalcItem.getExamItemName());
            setUnit(defaultCalcItem.getUnit());
            setExam_class(defaultCalcItem.getExamClass());
            //add #12462 患者情報共有 zrx start
            setJlac10_cd(defaultCalcItem.getJlac10Cd());
            //add #12462 患者情報共有 zrx end
          }
        };
        resultCalc.setResult(valCalculation == null ? ExamResultCalcConstant.CALC_RESULT_NONE : String.format("%1$.20f", valCalculation));
        ret.add(resultCalc);
      }
    }

    return ret;
  }



  /**
   * {@inheritDoc}
   */
  public Double getCalcKtV(ExamResult examResult) {
    String strBunBef = examResult.getBunBefore();
    String strBunAft = examResult.getBunAfter();
    Double ret;
    //10140 パラメータが不足している場合は、計算せずにnullに戻ります
    if (!StringUtils.isEmpty(strBunBef) && !StringUtils.isEmpty(strBunAft)) {
      // 透析量(Kt/V)計算
      BigDecimal befBun = new BigDecimal(strBunBef);
      BigDecimal aftBun = new BigDecimal(strBunAft);
      try {
        ret = Math.log((aftBun.divide(befBun, 10, RoundingMode.HALF_UP)).doubleValue()) * -1;
      } catch (Exception e) {
        //mod 10140 計算エラー,NaNで更新 gjn start
        // 检查结果计算异常返回NaN
        ret = Double.NaN;
        //mod 10140 計算エラー,NaNで更新 gjn end
      }
    } else {
      // 検査結果が取得できない場合はnullを返却
      ret = null;
    }
    return ret;
  }

  /**
   * {@inheritDoc}
   */
  public Double getCalcKtVe(ExamResultParam examResultParam, ExamResult examResult) {
    Double ret;
    // KT/Vspを取得
    Double ktVsp = getCalcKtVsp(examResultParam, examResult);
    //10140 パラメータが不足している場合は、計算せずにnullに戻ります
    if (ktVsp != null) {
      // KT/Vspが計算できた場合は計算を行う
      try {
        // 指定日の透析実績を取得して透析時間を計算
        this.setOrdMain(examResultParam, examResult);
        //10140 パラメータが不足している場合は、計算せずにnullに戻ります
        if (null != examResult.getOrdMain()) {
          OrdMain ordMain = examResult.getOrdMain();
          try {
            // 透析時間を開始・終了時刻から計算
            double treatTime = ((double) (ordMain.getRstEndDate().getTime() - ordMain.getRstStartDate().getTime())) / (60 * 60 * 1000);
            ret = ktVsp - 0.6 * ktVsp / treatTime + 0.03;
          } catch (Exception exception) {
            //add 10140 計算エラー,NaNで更新 gjn start
            ret = Double.NaN;
            //add 10140 計算エラー,NaNで更新 gjn end
          }
        } else {
          ret = null;
        }
      } catch (Exception e) {
        ret = null;
      }
    } else {
      // KT/Vspが計算できない場合はnullを返却
      ret = null;
    }
    return ret;
  }

  /**
   * {@inheritDoc}
   */
  public Double getCalcKtVsp(ExamResultParam examResultParam, ExamResult examResult) {
    Double ret;
    String strBunBef = examResult.getBunBefore();
    String strBunAft = examResult.getBunAfter();
    //10140 パラメータが不足している場合は、計算せずにnullに戻ります
    if (!StringUtils.isEmpty(strBunBef) && !StringUtils.isEmpty(strBunAft)) {
      try {
        // 透析量(Kt/Vsp)計算
        BigDecimal befBun = new BigDecimal(strBunBef);
        BigDecimal aftBun = new BigDecimal(strBunAft);
        // 指定日の透析実績・体重情報を取得
        this.setOrdMain(examResultParam, examResult);
        //10140 パラメータが不足している場合は、計算せずにnullに戻ります
        if (null != examResult.getOrdMain()) {
          // 該当日の透析実績が複数件ある場合は最後の透析実績を採用
          OrdMain ordMain = examResult.getOrdMain();
          String weight = ordMain.getRstWeightInfo();
          //10140 パラメータが不足している場合は、計算せずにnullに戻ります
          if (!StringUtils.isEmpty(weight)) {
            OrdMainRstWeightInfo dto = new ObjectMapper().readValue(weight, OrdMainRstWeightInfo.class);
            try {
              // 透析時間を開始・終了時刻から計算
              BigDecimal treatTime = BigDecimal.valueOf(((double) (ordMain.getRstEndDate().getTime() - ordMain.getRstStartDate().getTime())) / (60 * 60 * 1000));
              BigDecimal val1 = aftBun.divide(befBun, 10, RoundingMode.HALF_UP).subtract(BigDecimal.valueOf(0.008).multiply(treatTime));
              Double val2 = -1 * Math.log(val1.doubleValue());
              BigDecimal val3 = BigDecimal.valueOf(4).subtract(BigDecimal.valueOf(3.5).multiply(aftBun.divide(befBun, 10, RoundingMode.HALF_UP)));
              // mod #7572 手動で作成した実績では検査計算されない gaoey start
              BigDecimal val4 = null;
              //mod 9480 実績除水量と除水積算値は同じ意味であるため、実績除水量を用いて計算する gjn start
              if (dto.getWaterRemovalRst() != null) {
                val4 = val3.multiply(dto.getWaterRemovalRst()).divide(dto.getWeightAfter(), 10, RoundingMode.HALF_UP);
              } else { // 実績除水量がnullの場合は、除水積算値を用いて計算する
                val4 = val3.multiply(dto.getAddTotal()).divide(dto.getWeightAfter(), 10, RoundingMode.HALF_UP);
              }
              //mod 9480 実績除水量と除水積算値は同じ意味であるため、実績除水量を用いて計算する gjn start
              // mod #7572 手動で作成した実績では検査計算されない gaoey end
              ret = val2 + val4.doubleValue();
            } catch (Exception exception) {
              //add 10140 計算エラー,NaNで更新 gjn start
              ret = Double.NaN;
              //add 10140 計算エラー,NaNで更新 gjn end
            }
          } else {
            // 体重情報がない場合はnullを返却
            ret = null;
          }
        } else {
          // 治療実績がない場合はnullを返却
          ret = null;
        }
      } catch (Exception e) {
        ret = null;
      }
    } else {
      // 検査結果が取得できない場合はnullを返却
      ret = null;
    }
    return ret;
  }

  /**
   * {@inheritDoc}
   */
  public Double getCalcDaugirdasKtV(ExamResultParam examResultParam, ExamResult examResult) {
    Double ret;
    String strBunBef = examResult.getBunBefore();
    String strBunAft = examResult.getBunAfter();
    //10140 パラメータが不足している場合は、計算せずにnullに戻ります
    if (!StringUtils.isEmpty(strBunBef) && !StringUtils.isEmpty(strBunAft)) {
      try {
        // 透析量(Daugirdas Kt/V)計算
        BigDecimal befBun = new BigDecimal(strBunBef);
        BigDecimal aftBun = new BigDecimal(strBunAft);
        // 指定日の透析実績・体重情報を取得
        this.setOrdMain(examResultParam, examResult);
        //10140 パラメータが不足している場合は、計算せずにnullに戻ります
        if (null != examResult.getOrdMain()) {
          // 該当日の透析実績が複数件ある場合は最後の透析実績を採用
          OrdMain ordMain = examResult.getOrdMain();
          String weight = ordMain.getRstWeightInfo();
          //10140 パラメータが不足している場合は、計算せずにnullに戻ります
          if (!StringUtils.isEmpty(weight)) {
            OrdMainRstWeightInfo dto = new ObjectMapper().readValue(weight, OrdMainRstWeightInfo.class);
            try {
              // 透析時間を開始・終了時刻から計算
              BigDecimal treatTime = BigDecimal.valueOf(((double) (ordMain.getRstEndDate().getTime() - ordMain.getRstStartDate().getTime())) / (60 * 60 * 1000));
              BigDecimal val1 = aftBun.divide(befBun, 10, RoundingMode.HALF_UP).subtract(BigDecimal.valueOf(0.008).multiply(treatTime));
              Double val2 = -1 * Math.log(val1.doubleValue());
              BigDecimal val3 = BigDecimal.valueOf(4).subtract(BigDecimal.valueOf(3.5).multiply(aftBun.divide(befBun, 10, RoundingMode.HALF_UP)));
              BigDecimal val4 = val3.multiply(dto.getWeightDecreased()).divide(dto.getWeightAfter(), 10, RoundingMode.HALF_UP);
              ret = val2 + val4.doubleValue();
            } catch (Exception exception) {
              //add 10140 計算エラー,NaNで更新 gjn start
              ret = Double.NaN;
              //add 10140 計算エラー,NaNで更新 gjn end
            }
          } else {
            // 体重情報がない場合はnullを返却
            ret = null;
          }
        } else {
          // 治療実績がない場合はnullを返却
          ret = null;
        }
      } catch (Exception e) {
        ret = null;
      }
    } else {
      // 検査結果が取得できない場合はnullを返却
      ret = null;
    }
    return ret;
  }

  /**
   * {@inheritDoc}
   */
  public Double getCalcExclusionRate(ExamResult examResult) {
    String strBunBef = examResult.getBunBefore();
    String strBunAft = examResult.getBunAfter();
    //mod 透析前後の判断の最適化 関 end
    Double ret;
    //10140 パラメータが不足している場合は、計算せずにnullに戻ります
    if (!StringUtils.isEmpty(strBunBef) && !StringUtils.isEmpty(strBunAft)) {
      try {
        // BUN除去率計算
        BigDecimal befBun = new BigDecimal(strBunBef);
        BigDecimal aftBun = new BigDecimal(strBunAft);
        ret = ((befBun.subtract(aftBun)).divide(befBun, 10, RoundingMode.HALF_UP).multiply(BigDecimal.valueOf(100))).doubleValue();
      } catch (Exception e) {
        //mod 10140 計算エラー,NaNで更新 gjn start
        //ret = null;
        ret = Double.NaN;
        //mod 10140 計算エラー,NaNで更新 gjn end
      }
    } else {
      // 検査結果が取得できない場合はnullを返却
      ret = null;
    }

    return ret;
  }

  /**
   * TAC_BUN计算
   *
   * {@inheritDoc}
   */
  public Double getCalcTacBun(ExamResultParam examResultParam, ExamResult examResult) {
    Double ret;
    String bunAft = examResult.getLastTimeBunAfter();
    String bunBef = examResult.getBunBefore();
    //mstFacilitySettingにおける検査結果の前回取値範囲取得（facility _ setting _ no=3012）
    final FacilitySettingInfo settingValue =
      mstFacilitySettingDao.getBySettingNoAndCd(examResultParam.getFacilityCd(),"3012");
    int mst_date = !StringUtils.isEmpty(settingValue.getValue()) ? Integer.parseInt(settingValue.getValue()) : 1;
    mst_date = mst_date * -1;
    //10140 パラメータが不足している場合は、計算せずにnullに戻ります
    if (!StringUtils.isEmpty(bunBef) && StringUtils.isEmpty(bunAft)) {
      LocalDate today = LocalDate.parse(examResultParam.getTargetDt(), DateTimeFormatter.ofPattern("yyyyMMdd"));
      LocalDate lastYearDay = today.plusDays(mst_date);
      List<PatExamMain> patExamMains = patExamMainDao.selectPatExamMainByPatIdAndDate(examResultParam.getPatId(), lastYearDay.toString(), examResultParam.getTargetDt());
      if (patExamMains.size() > 0) {
        for (int i = patExamMains.size() - 1; i >= 0; i--) {
          if (null != examResult.getLastTimeBunAfter()) {
            break;
          }
          this.setLastTimeBunAfterHandle(examResultParam, examResult, patExamMains.get(i));
        }
        if (null != examResult.getLastTimeBunAfter()) {
          bunAft = examResult.getLastTimeBunAfter();
        }
      }
    }
    //10140 パラメータが不足している場合は、計算せずにnullに戻ります
    if (bunBef == null || bunBef.equals("") || bunAft == null || bunAft.equals("")) {
      return null;
    }
    //mod 10140 計算エラー,NaNで更新 gjn start
    try {
      BigDecimal befBun = new BigDecimal(bunBef);
      BigDecimal aftBun = new BigDecimal(bunAft);
      ret = (aftBun.add(befBun)).divide(BigDecimal.valueOf(2), 10, RoundingMode.HALF_UP).doubleValue();
    } catch (Exception exception) {
      ret = Double.NaN;
    }
    //mod 10140 計算エラー,NaNで更新 gjn end
    return ret;
  }

  //mod 9737 Ca gjn start
  /**
   * {@inheritDoc}
   */
  public Double getCalcCorCa(ExamResult examResult) {
    String strCa = examResult.getCa(); //血清Ca浓度
    String strAlb = examResult.getAlb(); //血清アルブミン濃度
    Double ret;
    //10140 パラメータが不足している場合は、計算せずにnullに戻ります
    if (!StringUtils.isEmpty(strCa) && !StringUtils.isEmpty(strAlb)) {
      // 補正化Ca計算
      BigDecimal valCa = new BigDecimal(strCa); //血清Ca浓度
      BigDecimal calAlb = new BigDecimal(strAlb); //血清アルブミン濃度
      try {
        // 血清アルブミン値が4以下の場合は補正
        if (calAlb.compareTo(BigDecimal.valueOf(4)) <= 0) { //血清アルブミン濃度4以下の場合
          ret = (valCa.add(BigDecimal.valueOf(4)).subtract(calAlb)).doubleValue();
        } else { //血清アルブミン濃度4より大きい場合，すぐに血清Ca浓度割り当て＃ワリアテ＃補正化Ca濃度
          ret = valCa.doubleValue();
        }
      } catch (Exception e) {
        //mod 10140 計算エラー,NaNで更新 gjn start
        ret = Double.NaN;
        //mod 10140 計算エラー,NaNで更新 gjn end
      }
    } else {
      // 検査結果が取得できない場合はnullを返却
      ret = null;
    }
    return ret;
  }
  //mod 9737 Ca gjn end

  /**
   * {@inheritDoc}
   */
  public Double getCalcClearSpace(ExamResultParam examResultParam, ExamResult examResult) {
    Double ret;
    String strBunBef = examResult.getBunBefore();
    String strBunAft = examResult.getBunAfter();
    //10140 パラメータが不足している場合は、計算せずにnullに戻ります
    if (!StringUtils.isEmpty(strBunBef) && !StringUtils.isEmpty(strBunAft)) {
      try {
        // クリアスペース率計算
        BigDecimal befBun = new BigDecimal(strBunBef);
        BigDecimal aftBun = new BigDecimal(strBunAft);

        // 指定日の透析実績・体重情報を取得
        this.setOrdMain(examResultParam, examResult);
        //10140 パラメータが不足している場合は、計算せずにnullに戻ります
        if (null != examResult.getOrdMain()) {
          // 該当日の透析実績が複数件ある場合は最後の透析実績を採用
          OrdMain ordMain = examResult.getOrdMain();
          String weight = ordMain.getRstWeightInfo();
          //10140 パラメータが不足している場合は、計算せずにnullに戻ります
          if (!StringUtils.isEmpty(weight)) {
            OrdMainRstWeightInfo dto = new ObjectMapper().readValue(weight, OrdMainRstWeightInfo.class);
            try {
              // 透析時間を開始・終了時刻から計算
              BigDecimal treatTime = BigDecimal.valueOf(((double) (ordMain.getRstEndDate().getTime() - ordMain.getRstStartDate().getTime())) / (60 * 60 * 1000));
              // 計算実行
              // 計算式：[1 - [(透析後BUN/透析前BUN - 0.008*透析時間) * (1 - 0.6/透析時間) + 0.008 * 透析時間] / [1 + 1.81 * (除水量 / 後体重)]] * 100
              BigDecimal val1 = aftBun.divide(befBun, 10, RoundingMode.HALF_UP).subtract(BigDecimal.valueOf(0.008).multiply(treatTime));
              BigDecimal val2 = BigDecimal.ONE.subtract(BigDecimal.valueOf(0.6).divide(treatTime, 10, RoundingMode.HALF_UP));
              BigDecimal val3 = BigDecimal.valueOf(0.008).multiply(treatTime);
              BigDecimal val4 = val1.multiply(val2).add(val3);
              BigDecimal val5 = BigDecimal.ONE.add(BigDecimal.valueOf(1.81).multiply(dto.getWaterRemovalRst().divide(dto.getWeightAfter(), 10, RoundingMode.HALF_UP)));
              BigDecimal val6 = BigDecimal.ONE.subtract(val4.divide(val5, 10, RoundingMode.HALF_UP));
              ret = val6.multiply(BigDecimal.valueOf(100)).doubleValue();
            } catch (Exception exception) {
              //add 10140 計算エラー,NaNで更新 gjn start
              ret = Double.NaN;
              //add 10140 計算エラー,NaNで更新 gjn end
            }
          } else {
            // 体重情報がない場合はnullを返却
            ret = null;
          }
        } else {
          // 治療実績がない場合はnullを返却
          ret = null;
        }
      } catch (Exception e) {
        ret = null;
      }
    } else {
      // 検査結果が取得できない場合はnullを返却
      ret = null;
    }
    return ret;
  }

  /**
   * {@inheritDoc}
   */
  public Double getCalcPcr(ExamResultParam examResultParam, ExamResult examResult) {
    //mod 10140 計算エラー,NaNで更新 gjn start
    Double PCR = null;
    try {
      Double prePCR = calcPcrPre(examResultParam, examResult);
      //10140 パラメータが不足している場合は、計算せずにnullに戻ります
      if (prePCR != null) {
        try {
          int intPrePcr = (int) (prePCR * 100 + 0.5);
          PCR = (double) intPrePcr / 100;
        } catch (Exception exception) {
          return Double.NaN;
        }
      } else {
        return null;
      }
    } catch (Exception exception) {
      return null;
    }
    return PCR;
    //mod 10140 計算エラー,NaNで更新 gjn end
  }

  private Double calcPcrPre(ExamResultParam examResultParam, ExamResult examResult) {
    BigDecimal RVU = BigDecimal.valueOf(0.5538);
    BigDecimal TD;
    BigDecimal BW1;
    BigDecimal BW2;
    BigDecimal BUNA;
    BigDecimal BUNB;
    try {
      // 指定日の透析実績・体重情報を取得
      this.setOrdMain(examResultParam, examResult);
      if (null != examResult.getOrdMain()) {
        // 該当日の透析実績が複数件ある場合は最後の透析実績を採用
        OrdMain ordMain = examResult.getOrdMain();
        String weight = ordMain.getRstWeightInfo();
        if (!StringUtils.isEmpty(weight)) {

          OrdMainRstWeightInfo dto = new ObjectMapper().readValue(weight, OrdMainRstWeightInfo.class);
          // 透析時間を開始・終了時刻から計算(分単位)
          TD = BigDecimal.valueOf((ordMain.getRstEndDate().getTime() - ordMain.getRstStartDate().getTime()) / (60 * 1000));
          // 体重情報
          BW1 = dto.getWeightBefore().multiply(BigDecimal.valueOf(1000));
          BW2 = dto.getWeightAfter().multiply(BigDecimal.valueOf(1000));
        } else {
          // 体重情報がない場合はnullを返却
          return null;
        }
      } else {
        // 治療実績がない場合はnullを返却
        return null;
      }
      // 透析前後のBUN値を取得
      String strBunBef = examResult.getBunBefore();
      BUNA = new BigDecimal(strBunBef).divide(BigDecimal.valueOf(100), 10, RoundingMode.HALF_UP);
      String strBunAft = examResult.getBunAfter();
      BUNB = new BigDecimal(strBunAft).divide(BigDecimal.valueOf(100), 10, RoundingMode.HALF_UP);
      //mod 透析前後の判断の最適化 関 end
      BigDecimal TI = BigDecimal.valueOf(48).multiply(BigDecimal.valueOf(60)).subtract(TD);
      BigDecimal TIE = BigDecimal.valueOf(72).multiply(BigDecimal.valueOf(60)).subtract(TD);
      BigDecimal TW = BigDecimal.valueOf(7).multiply(BigDecimal.valueOf(24)).multiply(BigDecimal.valueOf(60));
      BigDecimal VU = BW2.multiply(RVU);
      Double KTVL = Math.log((BUNA.divide(BUNB, 10, RoundingMode.HALF_UP)).doubleValue());
      Double KDL = KTVL / TD.doubleValue();
      Double YY = ((BUNA.subtract(BUNB)).divide(TI, 10, RoundingMode.HALF_UP)).doubleValue() / KDL;
      Double KTVH = BUNB.doubleValue() - YY;
      KTVH = Math.log((BUNA.doubleValue() - YY) / KTVH);
      Double KDH = KTVH / TD.doubleValue();
      Double R = Math.exp(KTVL * -1);
      Double X = TW.doubleValue() - (1 - R) * (2 + R) * (TI.doubleValue() - 1 / KTVL * TD.doubleValue()) - 3 * TD.doubleValue();
      Double ZL = KDL * X - (1 + R) * (1 - R) * (1 - R);
      ZL = BUNA.doubleValue() * (R * KDL * X + (1 - R) * (1 - R)) / ZL;
      R = Math.exp(KTVH * -1);
      X = TW.doubleValue() - (1 - R) * (2 + R) * (TI.doubleValue() - 1 / KTVH * TD.doubleValue()) - 3 * TD.doubleValue();
      Double ZH = KDH * X - (1 + R) * (1 - R) * (1 - R);
      ZH = BUNA.doubleValue() * (R * KDH * X + (1 - R) * (1 - R)) / ZH;
      Double X0 = KTVH - KTVL;
      Double X1 = Math.log(BUNB.doubleValue()) - (Math.log(ZL) * KTVH - Math.log(ZH) * KTVL) / X0;
      Double X2 = (Math.log(ZH) - Math.log(ZL)) / X0;
      Double KTV = X1 / X2;
      Double G = 1 - Math.exp(KTV * -1);
      G = (BUNB.doubleValue() - BUNA.doubleValue() * Math.exp(KTV * -1)) * KTV / TD.doubleValue() / G;
      Double GU = (G + (BW1.subtract(BW2)).divide(VU, 10, RoundingMode.HALF_UP).multiply(BUNA).divide(TIE, 10, RoundingMode.HALF_UP).doubleValue()) * 1000;
      Double II = 9.35 * RVU.doubleValue() * GU + 0.29 * RVU.doubleValue();
      II = 0.96 * II + 0.07;
      return II;
    } catch (Exception e) {
      // 計算できない場合はnullを返却
      return null;
    }
  }

  /**
   * {@inheritDoc}
   */
  public Double getCalcCreatininIndex(ExamResultParam examResultParam, ExamResult examResult) {
    BigDecimal RVC = BigDecimal.valueOf(0.49);
    BigDecimal TD;
    BigDecimal NENREI;
    Integer SX = patPersonalMainDao.selectById(examResultParam.getPatId()).getPat_sex();
    BigDecimal BW1;
    BigDecimal BW2;
    BigDecimal CRA;
    BigDecimal CRB;
    try {
      // 指定日の透析実績・体重情報を取得
      this.setOrdMain(examResultParam, examResult);
      //10140 パラメータが不足している場合は、計算せずにnullに戻ります
      if (null != examResult.getOrdMain()) {
        // 該当日の透析実績が複数件ある場合は最後の透析実績を採用
        OrdMain ordMain = examResult.getOrdMain();
        String weight = ordMain.getRstWeightInfo();
        //10140 パラメータが不足している場合は、計算せずにnullに戻ります
        if (!StringUtils.isEmpty(weight)) {
          OrdMainRstWeightInfo dto = new ObjectMapper().readValue(weight, OrdMainRstWeightInfo.class);
          // 透析時間を開始・終了時刻から計算(分単位)
          TD = BigDecimal.valueOf((ordMain.getRstEndDate().getTime() - ordMain.getRstStartDate().getTime()) / (60 * 1000));
          // 体重情報
          BW1 = dto.getWeightBefore().multiply(BigDecimal.valueOf(1000));
          BW2 = dto.getWeightAfter().multiply(BigDecimal.valueOf(1000));
        } else {
          // 体重情報がない場合はnullを返却
          return null;
        }
      } else {
        // 治療実績がない場合はnullを返却
        return null;
      }
      // 年齢計算
      PatPersonalMain patInfo = patPersonalMainDao.selectById(examResultParam.getPatId());
      SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
      try {
        NENREI = BigDecimal.valueOf((Integer.parseInt(sdf.format(new Date())) - Integer.parseInt(patInfo.getPat_birthday())) / 10000);
        // 透析前後のクレアチニンを取得
        String strCra = examResult.getCrAfter();
        CRA = (new BigDecimal(strCra)).divide(BigDecimal.valueOf(100), 10, RoundingMode.HALF_UP);
        String strCrb = examResult.getCrBefore();
        CRB = (new BigDecimal(strCrb)).divide(BigDecimal.valueOf(100), 10, RoundingMode.HALF_UP);
        BigDecimal TI = BigDecimal.valueOf(48).multiply(BigDecimal.valueOf(60)).subtract(TD);
        BigDecimal TIE = BigDecimal.valueOf(72).multiply(BigDecimal.valueOf(60)).subtract(TD);
        int t = TD.divide(BigDecimal.valueOf(60), 10, RoundingMode.HALF_UP).intValue();
        BigDecimal VC = BW2.multiply(RVC);
        BigDecimal KR = BigDecimal.valueOf(0.04).divide(BigDecimal.valueOf(24), 14, RoundingMode.HALF_UP).divide(BigDecimal.valueOf(60), 8, RoundingMode.HALF_UP).divide(RVC, 8, RoundingMode.HALF_UP);
        BigDecimal KTVI = KR.multiply(BigDecimal.valueOf(48 - t)).multiply(BigDecimal.valueOf(60));
        BigDecimal KTVIE = KR.multiply(BigDecimal.valueOf(72 - t)).multiply(BigDecimal.valueOf(60));
        Double RI = Math.exp(KTVI.doubleValue() * -1);
        Double RIE = Math.exp(KTVIE.doubleValue() * -1);
        Double KD = Math.log((CRA.divide(CRB, 10, RoundingMode.HALF_UP)).doubleValue()) / TD.doubleValue();
        Double CE = (81.6215 * KD + 0.942497) * CRB.doubleValue();
        Double KTVL = Math.log(CRA.doubleValue() / CE);
        Double KDL = KTVL / TD.doubleValue();
        Double YY = (CRA.doubleValue() - CE) / TI.doubleValue() / KDL;
        Double KTVH = CE - YY;
        KTVH = Math.log((CRA.doubleValue() - CE) / KTVH);
        Double KDH = KTVH / TD.doubleValue();
        Double RD = Math.exp(KTVL * -1);
        Double A1 = RI * (1 - RD) * (1 + RD * RI);
        Double A2 = (1 - RI) * (1 + RD * RI);
        Double A3 = (RD * RD) * (RI * RI) * (1 - RIE);
        Double B1 = (1 - RD) * ((1 - RI) * (RD * RI + 2) / KR.doubleValue() + (RI * (1 - RD) - 3) / KDL);
        Double B2 = (1 - RI) * ((RD * (1 - RI) - 2) / KR.doubleValue() + (1 - RD) / KDL);
        Double B3 = (1 - RIE) * ((RD * (1 - RI) * (RD * RI + 1) - 1) / KR.doubleValue() + (1 - RD) * (RD * RI + 1) / KDL);
        Double XXX = B1 + B2 + B3;
        Double YYY = A1 + A2 + A3;
        Double ZL = (KDL * XXX + YYY * (1 - RD));
        ZL = CRA.doubleValue() * (RD * KDL * XXX - (1 - RD) * (1 - RD)) / ZL;
        RD = Math.exp(KTVH * -1);
        A1 = RI * (1 - RD) * (1 + RD * RI);
        A2 = (1 - RI) * (1 + RD * RI);
        A3 = (RD * RD) * (RI * RI) * (1 - RIE);
        B1 = (1 - RD) * ((1 - RI) * (RD * RI + 2) / KR.doubleValue() + (RI * (1 - RD) - 3) / KDH);
        B2 = (1 - RI) * ((RD * (1 - RI) - 2) / KR.doubleValue() + (1 - RD) / KDH);
        B3 = (1 - RIE) * ((RD * (1 - RI) * (RD * RI + 1) - 1) / KR.doubleValue() + (1 - RD) * (RD * RI + 1) / KDH);
        XXX = B1 + B2 + B3;
        YYY = A1 + A2 + A3;
        Double ZH = (KDH * XXX + YYY * (1 - RD));
        ZH = CRA.doubleValue() * (RD * KDH * XXX - (1 - RD) * (1 - RD)) / ZH;
        Double X0 = KTVH - KTVL;
        Double X1 = Math.log(CE) - (Math.log(ZL) * KTVH - Math.log(ZH) * KTVL) / X0;
        Double X2 = (Math.log(ZH) - Math.log(ZL)) / X0;
        Double KTV = X1 / X2;
        Double G = 1 - Math.exp(KTV * -1);
        G = (CE - CRA.doubleValue() * Math.exp(KTV * -1)) * KTV / TD.doubleValue() / G;
        Double GCC = (G + (BW1.subtract(BW2)).doubleValue() / VC.doubleValue() * CRA.doubleValue() / TIE.doubleValue()) * 1000;
        Double GC = GCC * RVC.doubleValue();
        Double II = calcPcrPre(examResultParam, examResult);
        Double GG = GC * 60 * 24 - (3.49 * II - 0.32);
        Double SG;
        if (SX.equals(2)) {
          // 女性
          SG = 19.6 - 0.12 * NENREI.doubleValue();
        } else {
          // 男性、不明
          SG = 23.5 - 0.15 * NENREI.doubleValue();
        }
        Double CRIND = GG / SG * 100;
        int intCreIdx = (int) (CRIND * 10 + 0.5);
        Double CreIdx = (double) intCreIdx / 10;
        return CreIdx;
      } catch (Exception exception) {
        //mod 10140 計算エラー,NaNで更新 gjn start
        return Double.NaN;
        //mod 10140 計算エラー,NaNで更新 gjn end
      }
    } catch (Exception e) {
      return null;
    }
  }

  /**
   * {@inheritDoc}
   */
  public Double getCalcKtVShinzato(ExamResultParam examResultParam, ExamResult examResult) {
    BigDecimal RVU = BigDecimal.valueOf(0.5538);
    BigDecimal TD;
    BigDecimal BW1;
    BigDecimal BW2;
    BigDecimal BUNA;
    BigDecimal BUNB;
    try {
      // 指定日の透析実績・体重情報を取得
      this.setOrdMain(examResultParam, examResult);
      //10140 パラメータが不足している場合は、計算せずにnullに戻ります
      if (null != examResult.getOrdMain()) {
        // 該当日の透析実績が複数件ある場合は最後の透析実績を採用
        OrdMain ordMain = examResult.getOrdMain();
        String weight = ordMain.getRstWeightInfo();
        //10140 パラメータが不足している場合は、計算せずにnullに戻ります
        if (!StringUtils.isEmpty(weight)) {
          OrdMainRstWeightInfo dto = new ObjectMapper().readValue(weight, OrdMainRstWeightInfo.class);
          // 透析時間を開始・終了時刻から計算(分単位)
          TD = BigDecimal.valueOf((ordMain.getRstEndDate().getTime() - ordMain.getRstStartDate().getTime()) / (60 * 1000));
          // 体重情報
          BW1 = dto.getWeightBefore().multiply(BigDecimal.valueOf(1000));
          BW2 = dto.getWeightAfter().multiply(BigDecimal.valueOf(1000));
        } else {
          // 体重情報がない場合はnullを返却
          return null;
        }
      } else {
        // 治療実績がない場合はnullを返却
        return null;
      }
      // 透析前後のBUN値を取得
      String strBunBef = examResult.getBunBefore();
      try {
        BUNA = new BigDecimal(strBunBef).divide(BigDecimal.valueOf(100), 10, RoundingMode.HALF_UP);
        String strBunAft = examResult.getBunAfter();
        BUNB = new BigDecimal(strBunAft).divide(BigDecimal.valueOf(100), 10, RoundingMode.HALF_UP);
        BigDecimal TI = BigDecimal.valueOf(48).multiply(BigDecimal.valueOf(60)).subtract(TD);
        BigDecimal TIE = BigDecimal.valueOf(72).multiply(BigDecimal.valueOf(60)).subtract(TD);
        BigDecimal TW = BigDecimal.valueOf(7).multiply(BigDecimal.valueOf(24)).multiply(BigDecimal.valueOf(60));
        BigDecimal VU = BW2.multiply(RVU);
        Double KTVL = Math.log((BUNA.divide(BUNB, 10, RoundingMode.HALF_UP)).doubleValue());
        Double KDL = KTVL / TD.doubleValue();
        Double YY = ((BUNA.subtract(BUNB)).divide(TI, 10, RoundingMode.HALF_UP)).doubleValue() / KDL;
        Double KTVH = Math.log((BUNA.doubleValue() - YY) / (BUNB.doubleValue() - YY));
        Double KDH = KTVH / TD.doubleValue();
        Double R = Math.exp(KTVL * -1);
        Double X = TW.doubleValue() - (1 - R) * (2 + R) * (TI.doubleValue() - 1 / KTVL * TD.doubleValue()) - 3 * TD.doubleValue();
        Double ZL = BUNA.doubleValue() * (R * KDL * X + (1 - R) * (1 - R)) / (KDL * X - (1 + R) * (1 - R) * (1 - R));
        R = Math.exp(KTVH * -1);
        X = TW.doubleValue() - (1 - R) * (2 + R) * (TI.doubleValue() - 1 / KTVH * TD.doubleValue()) - 3 * TD.doubleValue();
        Double ZH = BUNA.doubleValue() * (R * KDH * X + (1 - R) * (1 - R)) / (KDH * X - (1 + R) * (1 - R) * (1 - R));
        Double X1 = Math.log(BUNB.doubleValue()) - (Math.log(ZL) * KTVH - Math.log(ZH) * KTVL) / (KTVH - KTVL);
        Double X2 = (Math.log(ZH) - Math.log(ZL)) / (KTVH - KTVL);
        Double KTV = X1 / X2;
        Double KD = KTV / TD.doubleValue();
        Double G = (BUNB.doubleValue() - BUNA.doubleValue() * Math.exp(KTV * -1)) * KTV / TD.doubleValue() / (1 - Math.exp(KTV * -1));
        Double IT = (BUNA.doubleValue() - G / KD) / KD * (1 - Math.exp(KTV * -1)) + G / KD * TD.doubleValue();
        Double KTVU = KTV + ((BW1.subtract(BW2)).divide(VU, 10, RoundingMode.HALF_UP).multiply(BUNA).multiply(TD.divide(TIE, 10, RoundingMode.HALF_UP).add(BigDecimal.ONE)).multiply(TD)).doubleValue() / IT;
        int intKTVshinzato = (int) (KTVU * 100 + 0.5);
        Double KTVshinzato = (double) intKTVshinzato / 100;
        return KTVshinzato;
      } catch (Exception exception) {
        //mod 10140 計算エラー,NaNで更新 gjn start
        return Double.NaN;
        //mod 10140 計算エラー,NaNで更新 gjn end
      }
    } catch (Exception e) {
      return null;
    }
  }

  /**
   * {@inheritDoc}
   */
  public Double getCalcBmi(ExamResultParam examResultParam, ExamResult examResult) {
    BigDecimal BW2;
    BigDecimal height;
    try {
      // 指定日の透析実績・体重情報を取得
      this.setOrdMain(examResultParam, examResult);
      //10140 パラメータが不足している場合は、計算せずにnullに戻ります
      if (null != examResult.getOrdMain()) {
        // 該当日の透析実績が複数件ある場合は最後の透析実績を採用
        OrdMain ordMain = examResult.getOrdMain();
        String weight = ordMain.getRstWeightInfo();
        //10140 パラメータが不足している場合は、計算せずにnullに戻ります
        if (!StringUtils.isEmpty(weight)) {
          OrdMainRstWeightInfo dto = new ObjectMapper().readValue(weight, OrdMainRstWeightInfo.class);
          // 後体重
          BW2 = dto.getWeightAfter().multiply(BigDecimal.valueOf(10000));
        } else {
          // 体重情報がない場合はnullを返却
          return null;
        }
      } else {
        // 治療実績がない場合はnullを返却
        return null;
      }
      // 患者情報を取得
      //mod 8781 【デグレ】検査計算項目BMI，GNRIが計算しない 張 start
      //List<PatUniquePhysicalInfo> patUniquePhysicalInfo = patUniqueDao.selectPhysicalInfoOfOrderNewest(examResultParam.getPatId());
      List<PatUniquePhysicalInfo> patUniquePhysicalInfo = patUniqueDao.selectPhysicalInfoByPatIdAndExamDate(examResultParam.getPatId(),examResultParam.getRegExamDate().toString());
      patUniquePhysicalInfo = patUniquePhysicalInfo.stream().filter(item->item.getHeight() != null).collect(Collectors.toList());
      //mod 8781 【デグレ】検査計算項目BMI，GNRIが計算しない 張 end
      //10140 パラメータが不足している場合は、計算せずにnullに戻ります
      if (patUniquePhysicalInfo.size() > 0) {
        height = new BigDecimal(patUniquePhysicalInfo.get(0).getHeight());
      } else {
        // 身長が取得できない場合はnullを返却
        return null;
      }
      //mod 10140 計算エラー,NaNで更新 gjn start
      Double result;
      try {
        // BMI計算
        BigDecimal BMI = BW2.divide(height, 10, RoundingMode.HALF_UP).divide(height, 10, RoundingMode.HALF_UP);
        result = BMI.doubleValue();
      } catch (Exception exception) {
        return Double.NaN;
      }
      return result;
      //mod 10140 計算エラー,NaNで更新 gjn end
    } catch (Exception e) {
      return null;
    }
  }

  /**
   * {@inheritDoc}
   */
  public Double getCalcGnri(ExamResultParam examResultParam, ExamResult examResult) {
    BigDecimal BW2;
    BigDecimal height;
    BigDecimal Al1;
    try {
      // 指定日の透析実績・体重情報を取得
      this.setOrdMain(examResultParam, examResult);
      //10140 パラメータが不足している場合は、計算せずにnullに戻ります
      if (null != examResult.getOrdMain()) {
        // 該当日の透析実績が複数件ある場合は最後の透析実績を採用
        OrdMain ordMain = examResult.getOrdMain();
        String weight = ordMain.getRstWeightInfo();
        //10140 パラメータが不足している場合は、計算せずにnullに戻ります
        if (!StringUtils.isEmpty(weight)) {
          OrdMainRstWeightInfo dto = new ObjectMapper().readValue(weight, OrdMainRstWeightInfo.class);
          // 後体重
          //mod FNSI-検査結果の身長が取得の対応 田 start
          BW2 = dto.getWeightAfter();
          //mod FNSI-検査結果の身長が取得の対応 田 end
        } else {
          // 体重情報がない場合はnullを返却
          return null;
        }
      } else {
        // 治療実績がない場合はnullを返却
        return null;
      }
      // 患者情報を取得
      //mod 8781 【デグレ】検査計算項目BMI，GNRIが計算しない 張 start
      //List<PatUniquePhysicalInfo> patUniquePhysicalInfo = patUniqueDao.selectPhysicalInfoOfOrderNewest(examResultParam.getPatId());
      List<PatUniquePhysicalInfo> patUniquePhysicalInfo = patUniqueDao.selectPhysicalInfoByPatIdAndExamDate(examResultParam.getPatId(),examResultParam.getRegExamDate().toString());
      patUniquePhysicalInfo = patUniquePhysicalInfo.stream().filter(item-> item.getHeight() != null).collect(Collectors.toList());
      //mod 8781 【デグレ】検査計算項目BMI，GNRIが計算しない 張 end
      //10140 パラメータが不足している場合は、計算せずにnullに戻ります
      if (patUniquePhysicalInfo.size() > 0) {
        //mod FNSI-検査結果の身長が取得の対応 田 start
        height = new BigDecimal(patUniquePhysicalInfo.get(0).getHeight()).divide(BigDecimal.valueOf(100), 10, RoundingMode.HALF_UP);
        //mod FNSI-検査結果の身長が取得の対応 田 end
      } else {
        // 身長が取得できない場合はnullを返却
        return null;
      }
      // 透析前血清アルブミン濃度を取得
      String strAlb = "";
      strAlb = examResult.getAlbBefore();
      Al1 = new BigDecimal(strAlb);
      try {
        BigDecimal IBW = BigDecimal.valueOf(22).multiply(height).multiply(height);
        BigDecimal wRet = BigDecimal.ONE;
        if (BW2.compareTo(IBW) < 0) {
          wRet = BW2.divide(IBW, 10, RoundingMode.HALF_UP);
        }
        // GNRI計算
        BigDecimal GNRI = (BigDecimal.valueOf(14.89).multiply(Al1)).add(BigDecimal.valueOf(41.7).multiply(wRet));
        return GNRI.doubleValue();
      } catch (Exception exception) {
        //mod 10140 計算エラー,NaNで更新 gjn start
        return Double.NaN;
        //mod 10140 計算エラー,NaNで更新 gjn end
      }
    } catch (Exception e) {
      return null;
    }
  }

  /**
   * {@inheritDoc}
   */
  public Double getCalcCrExclusionRate(ExamResult examResult) {
    String strCrBef = examResult.getCrBefore();
    String strCrAft = examResult.getCrAfter();
    Double ret;
    //10140 パラメータが不足している場合は、計算せずにnullに戻ります
    if (!StringUtils.isEmpty(strCrBef) && !StringUtils.isEmpty(strCrAft)) {
      try {
        // 透析量(Kt/V)計算
        BigDecimal befCr = new BigDecimal(strCrBef);
        BigDecimal aftCr = new BigDecimal(strCrAft);
        ret = (befCr.subtract(aftCr)).divide(befCr, 10, RoundingMode.HALF_UP).multiply(BigDecimal.valueOf(100)).doubleValue();
      } catch (Exception e) {
        //mod 10140 計算エラー,NaNで更新 gjn start
        ret = Double.NaN;
        //mod 10140 計算エラー,NaNで更新 gjn end
      }
    } else {
      // 検査結果が取得できない場合はnullを返却
      ret = null;
    }
    return ret;
  }

  /**
   * {@inheritDoc}
   */
  public Double getCalcTsat(ExamResult examResult) {
    String strFeBef = examResult.getFeBefore();
    String strTibcBef = examResult.getTibcBefore();
    Double ret;
    //10140 パラメータが不足している場合は、計算せずにnullに戻ります
    if (!StringUtils.isEmpty(strFeBef) && !StringUtils.isEmpty(strTibcBef)) {
      try {
        // 透析量(Kt/V)計算
        BigDecimal befFe = new BigDecimal(strFeBef);
        BigDecimal befTibc = new BigDecimal(strTibcBef);
        ret = befFe.divide(befTibc, 10, RoundingMode.HALF_UP).multiply(BigDecimal.valueOf(100)).doubleValue();
      } catch (Exception e) {
        //mod 10140 計算エラー,NaNで更新 gjn start
        ret = Double.NaN;
        //mod 10140 計算エラー,NaNで更新 gjn end
      }
    } else {
      // 検査結果が取得できない場合はnullを返却
      ret = null;
    }
    return ret;
  }

  /**
   * 指定患者・日付・タイミングの検査値を取得する
   *
   * @param examResultParam
   * @return ExamResult
   */
  private ExamResult getExamResult(ExamResultParam examResultParam) {
    ExamResult result = new ExamResult();
    LocalDate today = LocalDate.parse(examResultParam.getTargetDt(), DateTimeFormatter.ofPattern("yyyyMMdd"));
    LocalDate nextDay = today.plusDays(1);
    List<PatExamMain> lstExamMain = patExamMainDao.selectPatExamMainByPatIdAndDate(examResultParam.getPatId(), today.toString(), nextDay.toString());
    if (lstExamMain.size() == 0) {
      return result;
    }

    Long examMainCd = examResultParam.getExamMainCd();
    List<PatExamMain> mainList = lstExamMain.stream().filter(x -> examMainCd.equals(x.getExamMainCd())).collect(Collectors.toList());
    if (mainList.size() != 1) {
      return result;
    }

    Map<Timestamp, List<PatExamMain>> collect = lstExamMain.stream().collect(Collectors.groupingBy(PatExamMain::getRegExamDate));
    final List<List<PatExamMain>> lists = new ArrayList<>();
    collect.forEach((x, y) -> lists.add(y));
    final List<List<PatExamMain>> newLists = lists.stream().sorted(Comparator.comparing(x -> x.get(0).getRegExamDate())).collect(Collectors.toList());

    List<List<PatExamMain>> beforeList = new ArrayList<>();
    List<List<PatExamMain>> afterList = newLists;
    PatExamMain main = mainList.get(0);
    List<PatExamMain> mains = new ArrayList<>();
    for (int i = 0; i < newLists.size(); i++) {
      if (!newLists.get(i).contains(main)) {
        beforeList.add(newLists.get(i));
      } else {
        mains = newLists.get(i);
        afterList.remove(newLists.get(i));
        break;
      }
    }
    afterList.removeAll(beforeList);

    List<List<PatExamMain>> beforeGroup = new ArrayList<>();
    List<List<PatExamMain>> afterGroup = new ArrayList<>();
    if (mains.size() == 1) {
      // beforeGroup
      // 1:透析前
      if (ExamResultCalcConstant.OrderClass.BEFORE_DIALYSIS.equals(examResultParam.getRegOrderClass())) {
        this.beforeGroupBeforeHandle(examResultParam, result, beforeList, beforeGroup);
        // 2:透析後
      } else if (ExamResultCalcConstant.OrderClass.AFTER_DIALYSIS.equals(examResultParam.getRegOrderClass())) {
        this.beforeGroupAfterHandle(examResultParam, result, beforeList, beforeGroup, false);
        // 0:その他
      } else {
        List<String> differentFlagList = this.getDifferentFlagList(examResultParam, main);
        differentFlagList = differentFlagList.stream().filter(x -> !StringUtils.isEmpty(x)).filter(x -> !ExamResultCalcConstant.DialysisProgressFlag.EMPTY.equals(x)).collect(Collectors.toList());
        //mod 9734 guan start
        if (differentFlagList.size() == 1) {
          if (differentFlagList.contains(ExamResultCalcConstant.DialysisProgressFlag.BEFORE)) {
            //TODO 前
            this.beforeGroupBeforeHandle(examResultParam, result, beforeList, beforeGroup);
          } else if (differentFlagList.contains(ExamResultCalcConstant.DialysisProgressFlag.AFTER)) {
            //TODO 後
            this.beforeGroupAfterHandle(examResultParam, result, beforeList, beforeGroup, false);
          } else if (differentFlagList.contains(ExamResultCalcConstant.DialysisProgressFlag.ALL)) {
            //TODO 当前是全（会儿）忽略，向前找，因为是向前找所以把当前的会儿当成后（因为当成后之后无论向前遇到前还是遇到后都不会停下来）。下面会把当前的会儿加入到beforeGroup中
            this.beforeGroupAfterHandle(examResultParam, result, beforeList, beforeGroup, false);
          }
        } else {
          //TODO differentFlagListの2つの場合には、前後、前ALL、後ALLが含まれます。differentFlagListの3つの場合：前後にALLが前を含むので、beforeメソッドを歩く
          this.beforeGroupBeforeHandle(examResultParam, result, beforeList, beforeGroup);
        }
        //mod 9734 guan end
      }

      // afterGroup 現在の検査結果を基準にして同じグループの検査結果を後ろに探す
      // 1:透析前
      if (ExamResultCalcConstant.OrderClass.BEFORE_DIALYSIS.equals(examResultParam.getRegOrderClass())) {
        this.afterGroupBeforeHandle(examResultParam, afterList, afterGroup);
        // 2:透析後
      } else if (ExamResultCalcConstant.OrderClass.AFTER_DIALYSIS.equals(examResultParam.getRegOrderClass())) {
        this.afterGroupAfterHandle(examResultParam, afterList, afterGroup);
        // 0:その他
      } else {
        List<String> differentFlagList = this.getDifferentFlagList(examResultParam, main);
        differentFlagList = differentFlagList.stream().filter(x -> !StringUtils.isEmpty(x)).filter(x -> !ExamResultCalcConstant.DialysisProgressFlag.EMPTY.equals(x)).collect(Collectors.toList());
        //mod 9734 guan start
        if (differentFlagList.size() == 1) {
          if (differentFlagList.contains(ExamResultCalcConstant.DialysisProgressFlag.BEFORE)) { //TODO 与当前是前等效
            this.afterGroupBeforeHandle(examResultParam, afterList, afterGroup);
          } else if (differentFlagList.contains(ExamResultCalcConstant.DialysisProgressFlag.AFTER)) { //TODO 与当前是后等效
            this.afterGroupAfterHandle(examResultParam, afterList, afterGroup);
          } else { //todo ALL在向前找的时候已经加入到beforGroup中了，再加就重复了
            //this.afterGroupAfterHandle(examResultParam, afterList, afterGroup);
            //TODO 当前是その他是ALL的情况下向后找，要看beforGroup的最后一个是啥，作为向后找的依据
            this.afterGroupOtherHandle(examResultParam, afterList, afterGroup, beforeGroup);
          }
        } else { //TODO 多个的情况下可以只认为有前和后（有前有后当后用，因为是向后找），ALL可以忽略    ------2つ（前後、前ALL、後All）または3つ（前後ALL）を含む
          //後を基準として、前を後ろに探す
          this.afterGroupAfterHandle(examResultParam, afterList, afterGroup);
        }
        //mod 9734 guan end
      }
    } else { //TODO 同一時刻現在は複数の検査結果
      //TODO beforeGroup 往前找
      List<PatExamMain> filterBefore = mains.stream().filter(x -> ExamResultCalcConstant.OrderClass.BEFORE_DIALYSIS.equals(x.getRegOrderClass())).collect(Collectors.toList());
      List<PatExamMain> filterAfter = mains.stream().filter(x -> ExamResultCalcConstant.OrderClass.AFTER_DIALYSIS.equals(x.getRegOrderClass())).collect(Collectors.toList());
      List<PatExamMain> filterOther = mains.stream().filter(x -> ExamResultCalcConstant.OrderClass.OTHER_DIALYSIS.equals(x.getRegOrderClass())).collect(Collectors.toList());
      Boolean otherHasBefore = false;
      Boolean otherHasAfter = false;
      if (filterOther.size() == 1) {
        List<String> differentFlagList = this.getDifferentFlagList(examResultParam, filterOther.get(0));
        differentFlagList = differentFlagList.stream().filter(x -> !StringUtils.isEmpty(x)).filter(x -> !ExamResultCalcConstant.DialysisProgressFlag.EMPTY.equals(x)).collect(Collectors.toList());
        if (differentFlagList.contains(ExamResultCalcConstant.DialysisProgressFlag.BEFORE)) {
          otherHasBefore = true;
        }
        if (differentFlagList.contains(ExamResultCalcConstant.DialysisProgressFlag.AFTER)) {
          otherHasAfter = true;
        }
        //mod 9734 guan start
        if (differentFlagList.contains(ExamResultCalcConstant.DialysisProgressFlag.ALL)) { //TODO ALL是会儿，啥也不标记了，下面会把当前直接放到beforGroup中
//          otherHasBefore = true;
//          otherHasAfter = true;
        }
      }
      if (filterBefore.size() == 1 || otherHasBefore) { //TODO 有前或その他里有前
        //前を探して、現在は前があります
        this.beforeGroupBeforeHandle(examResultParam, result, beforeList, beforeGroup);
      }
      if (filterAfter.size() == 1 || otherHasAfter) { //TODO 进到这里只有后或者その他里有后
        //前に探して、今は後ろで、（先に探して、それから探して）
        this.beforeGroupAfterHandle(examResultParam, result, beforeList, beforeGroup, false);
      }

      //TODO afterGroup 当前多个的向后找
      if (filterAfter.size() == 1 || otherHasAfter) { //有后，その他里有后，その他是ALL(忽略)
        //後ろに探して、今は後ろで、（前に会って終わり）
        this.afterGroupAfterHandle(examResultParam, afterList, afterGroup);
      } else { //TODO 有前，その他里带前，その他是ALL（忽略）
        //後ろに探して、今は前か他の中が前で、（先に探して、前を探しています。終了）
        this.afterGroupBeforeHandle(examResultParam, afterList, afterGroup);
      }
    }
    //TODO 把当前这个加入到beforeGroup
    beforeGroup.add(mains);
    beforeGroup.addAll(afterGroup);
    List<PatExamMain> list = new ArrayList<>();
    for (List<PatExamMain> group : beforeGroup) {
      list.addAll(group);
    }
    result.setPatExamMainList(list);
    if (list.size() > 0) {
      List<PatExamMain> patExamMains = list.stream().sorted(Comparator.comparing(PatExamMain::getRegExamDate)
        .thenComparing(PatExamMain::getUpDate)
        .thenComparing(PatExamMain::getRegDate))
        .collect(Collectors.toList());
      List<Timestamp> timestampList = patExamMains.stream().map(PatExamMain::getRegExamDate).collect(Collectors.toList());
      //TODO グループの開始時間と終了時間を取得
      if (timestampList.size() > 0) {
        result.setExamStratTime(timestampList.get(0));
        result.setExamEndTime(timestampList.get(timestampList.size() - 1));
      }
      //TODO 検査項目リスト（0：検査項目）
      List<Long> examMainCdList = new ArrayList<>();
      //TODO 1：システム標準計算項目
      List<Long> examMainCdListSys = new ArrayList<>();
      for (PatExamMain patExamMain : patExamMains) {
        JSONArray info = new JSONArray(patExamMain.getExamResultInfo());
        for (int i = 0; i < info.length(); i++) {
          JSONObject object = info.getJSONObject(i);
          if (object.has("item_cd") && !StringUtils.isEmpty(object.get("item_cd")) && object.has("exam_class")) {
            if (ExamClass.EXAM_ITEM.equals(object.get("exam_class"))) {
              examMainCdList.add(Long.parseLong(object.get("item_cd").toString()));
            } else if (ExamClass.SYSTEM_DEFAULT_CALC_ITEM.equals(object.get("exam_class"))) {
              examMainCdListSys.add(Long.parseLong(object.get("item_cd").toString()));
            }
          }
        }
      }
      examMainCdList = examMainCdList.stream().distinct().collect(Collectors.toList());
      examMainCdListSys = examMainCdListSys.stream().distinct().collect(Collectors.toList());
      List<MstExamItem> mstExamItems = mstExamItemDao.selectByExamItemCdList(examResultParam.getFacilityCd(), examMainCdList);
      List<MstExamItem> mstExamItemsSys = mstExamItemDao.selectByExamItemCdList(examResultParam.getFacilityCd(), examMainCdListSys);
      examResultParam.setMstExamItems(mstExamItems);
      examResultParam.setMstExamItemsSys(mstExamItemsSys);
      //TODO 現在のグループの検査結果
      examResultParam.setPatExamMains(patExamMains);
    }
    return result;
  }
  //mod 9734 guan end




  private ExamResult setResult(ExamResultParam examResultParam, ExamResult examResult) {
    List<MstExamItem> mstExamItems = examResultParam.getMstExamItems();
    List<PatExamMain> patExamMains = examResultParam.getPatExamMains();

    if (examResultParam.getExamResultCalcColumnVal().equals(ExamResultCalcConstant.ExamResultCalcColumns.BUN)) {
      List<MstExamItem> examItems = mstExamItems.stream().filter(x -> ExamResultCalcConstant.ExamResultCalcColumns.BUN.equals(x.getDefaultCalcExamItemCd())).collect(Collectors.toList());
      examResult = this.setValue(examResult, patExamMains, examItems, ExamResultCalcConstant.ExamResultCalcColumns.BUN);
    }
    if (examResultParam.getExamResultCalcColumnVal().equals(ExamResultCalcConstant.ExamResultCalcColumns.SERUM_ALBUMIN_CONCENTRATION)) {
      List<MstExamItem> items = mstExamItems.stream().filter(x -> ExamResultCalcConstant.ExamResultCalcColumns.SERUM_ALBUMIN_CONCENTRATION.equals(x.getDefaultCalcExamItemCd())).collect(Collectors.toList());
      examResult = this.setValue(examResult, patExamMains, items, ExamResultCalcConstant.ExamResultCalcColumns.SERUM_ALBUMIN_CONCENTRATION);
    }
    if (examResultParam.getExamResultCalcColumnVal().equals(ExamResultCalcConstant.ExamResultCalcColumns.CREATININE)) {
      List<MstExamItem> examItems = mstExamItems.stream().filter(x -> ExamResultCalcConstant.ExamResultCalcColumns.BUN.equals(x.getDefaultCalcExamItemCd())).collect(Collectors.toList());
      examResult = this.setValue(examResult, patExamMains, examItems, ExamResultCalcConstant.ExamResultCalcColumns.BUN);
      List<MstExamItem> items = mstExamItems.stream().filter(x -> ExamResultCalcConstant.ExamResultCalcColumns.CREATININE.equals(x.getDefaultCalcExamItemCd())).collect(Collectors.toList());
      examResult = this.setValue(examResult, patExamMains, items, ExamResultCalcConstant.ExamResultCalcColumns.CREATININE);
    }
    if (examResultParam.getExamResultCalcColumnVal().equals(ExamResultCalcConstant.ExamResultCalcColumns.SERUM_FE)) {
      List<MstExamItem> examItems = mstExamItems.stream().filter(x -> ExamResultCalcConstant.ExamResultCalcColumns.SERUM_FE.equals(x.getDefaultCalcExamItemCd())).collect(Collectors.toList());
      examResult = this.setValue(examResult, patExamMains, examItems, ExamResultCalcConstant.ExamResultCalcColumns.SERUM_FE);
      List<MstExamItem> items = mstExamItems.stream().filter(x -> ExamResultCalcConstant.ExamResultCalcColumns.TIBC.equals(x.getDefaultCalcExamItemCd())).collect(Collectors.toList());
      examResult = this.setValue(examResult, patExamMains, items, ExamResultCalcConstant.ExamResultCalcColumns.TIBC);
    }
    if (examResultParam.getExamResultCalcColumnVal().equals(ExamResultCalcConstant.ExamResultCalcColumns.HEMATOCRIT)) {
      List<MstExamItem> examItems = mstExamItems.stream().filter(x -> ExamResultCalcConstant.ExamResultCalcColumns.HEMATOCRIT.equals(x.getDefaultCalcExamItemCd())).collect(Collectors.toList());
      examResult = this.setValue(examResult, patExamMains, examItems, ExamResultCalcConstant.ExamResultCalcColumns.HEMATOCRIT);
    }
    return examResult;
  }




  /**
   * 補正化Ca計算処理
   *
   * @param examResultParam
   * @throws IOException
   */
  private void setCorrectionCa(ExamResultParam examResultParam) throws IOException {
    ExamResult result = new ExamResult();
    List<PatExamMain> list = new ArrayList<>();
    //examResultParamに格納されている検査結果は、すでに最新の計算後の検査結果ではないので、その患者の検査結果データをDBから読み直す必要がある
    List<Long> examMainCds = new ArrayList<>();
    List<PatExamMain> patExamMainList = examResultParam.getPatExamMains();
    for (PatExamMain patExamMain : patExamMainList) {
      examMainCds.add(patExamMain.getExamMainCd());
    }
    list = patExamMainDao.selectPatExamMainByExamMainCdList(examMainCds);
    result.setPatExamMainList(list);

    if (list.size() > 0) {
      List<PatExamMain> patExamMains = list.stream().sorted(Comparator.comparing(PatExamMain::getRegExamDate)
        .thenComparing(PatExamMain::getRegOrderClass))
        .collect(Collectors.toList());
      ArrayList<String> defaultCalcExamItemCdList = new ArrayList<>();
      defaultCalcExamItemCdList.add(ExamResultCalcConstant.ExamResultCalcColumns.SERUM_CA_CONCENTRATION);
      defaultCalcExamItemCdList.add(ExamResultCalcConstant.ExamResultCalcColumns.SERUM_ALBUMIN_CONCENTRATION);
      List<MstExamItem> mstExamItems = mstExamItemDao.selectByDefaultCalcExamItemCdListAndExamClass(examResultParam.getFacilityCd(), defaultCalcExamItemCdList, ExamClass.EXAM_ITEM);

      for (PatExamMain data : patExamMains) {
        if (data.getExamResultInfo() != null && !data.getExamResultInfo().isEmpty()) {
          JSONArray info = new JSONArray(data.getExamResultInfo());
          if (ExamResultCalcConstant.OrderClass.BEFORE_DIALYSIS.equals(data.getRegOrderClass())) { //透析前
            for (int i = 0; i < info.length(); i++) {
              JSONObject object = info.getJSONObject(i);
              if (object.has("result") && !StringUtils.isEmpty(object.get("result").toString())
                && object.has("item_cd") && !StringUtils.isEmpty(object.get("item_cd"))) {
                List<MstExamItem> examItems = mstExamItems.stream().filter(x -> object.get("item_cd").toString().equals(x.getExamItemCd().toString())).collect(Collectors.toList());
                if (examItems.size() == 1) {
                  if (ExamResultCalcConstant.DialysisProgressFlag.BEFORE.equals(examItems.get(0).getDialysisProgressFlag())
                    || ExamResultCalcConstant.DialysisProgressFlag.ALL.equals(examItems.get(0).getDialysisProgressFlag())) {
                    if (ExamResultCalcConstant.ExamResultCalcColumns.SERUM_CA_CONCENTRATION.equals(examItems.get(0).getDefaultCalcExamItemCd())) {
                      result.setCaBefore(object.get("result").toString());
                    } else if (ExamResultCalcConstant.ExamResultCalcColumns.SERUM_ALBUMIN_CONCENTRATION.equals(examItems.get(0).getDefaultCalcExamItemCd())) {
                      result.setAlbBefore(object.get("result").toString());
                    }
                  }
                }
              }
            }
          } else if (ExamResultCalcConstant.OrderClass.AFTER_DIALYSIS.equals(data.getRegOrderClass())) { //透析后
            for (int i = 0; i < info.length(); i++) {
              JSONObject object = info.getJSONObject(i);
              if (object.has("result") && !StringUtils.isEmpty(object.get("result").toString())
                && object.has("item_cd") && !StringUtils.isEmpty(object.get("item_cd"))) {
                List<MstExamItem> examItems = mstExamItems.stream().filter(x -> object.get("item_cd").toString().equals(x.getExamItemCd().toString())).collect(Collectors.toList());
                if (examItems.size() == 1) {
                  if (ExamResultCalcConstant.DialysisProgressFlag.AFTER.equals(examItems.get(0).getDialysisProgressFlag())
                    || ExamResultCalcConstant.DialysisProgressFlag.ALL.equals(examItems.get(0).getDialysisProgressFlag())) {
                    if (ExamResultCalcConstant.ExamResultCalcColumns.SERUM_CA_CONCENTRATION.equals(examItems.get(0).getDefaultCalcExamItemCd())) {
                      result.setCaAfter(object.get("result").toString());
                    } else if (ExamResultCalcConstant.ExamResultCalcColumns.SERUM_ALBUMIN_CONCENTRATION.equals(examItems.get(0).getDefaultCalcExamItemCd())) {
                      result.setAlbAfter(object.get("result").toString());
                    }
                  }
                }
              }
            }
            //add 9737 Ca gjn start
          } else { //その他
            for (int i = 0; i < info.length(); i++) {
              JSONObject object = info.getJSONObject(i);
              if (object.has("result") && !StringUtils.isEmpty(object.get("result").toString())
                && object.has("item_cd") && !StringUtils.isEmpty(object.get("item_cd"))) {
                List<MstExamItem> examItems = mstExamItems.stream().filter(x -> object.get("item_cd").toString().equals(x.getExamItemCd().toString())).collect(Collectors.toList());
                if (examItems.size() == 1) {
                  if (ExamResultCalcConstant.DialysisProgressFlag.BEFORE.equals(examItems.get(0).getDialysisProgressFlag())) {
                    if (ExamResultCalcConstant.ExamResultCalcColumns.SERUM_CA_CONCENTRATION.equals(examItems.get(0).getDefaultCalcExamItemCd())) {
                      result.setCaBefore(object.get("result").toString());
                    } else if (ExamResultCalcConstant.ExamResultCalcColumns.SERUM_ALBUMIN_CONCENTRATION.equals(examItems.get(0).getDefaultCalcExamItemCd())) {
                      result.setAlbBefore(object.get("result").toString());
                    }
                  }
                  if (ExamResultCalcConstant.DialysisProgressFlag.AFTER.equals(examItems.get(0).getDialysisProgressFlag())) {
                    if (ExamResultCalcConstant.ExamResultCalcColumns.SERUM_CA_CONCENTRATION.equals(examItems.get(0).getDefaultCalcExamItemCd())) {
                      result.setCaAfter(object.get("result").toString());
                    } else if (ExamResultCalcConstant.ExamResultCalcColumns.SERUM_ALBUMIN_CONCENTRATION.equals(examItems.get(0).getDefaultCalcExamItemCd())) {
                      result.setAlbAfter(object.get("result").toString());
                    }
                  }
                }
              }
            }
            //add 9737 Ca gjn end
          }
        }
      }
    }
    result.setCa(result.getCaBefore());
    result.setAlb(result.getAlbBefore());
    Double calcCorCaBefore = this.getCalcCorCa(result);
    result.setCa(result.getCaAfter());
    result.setAlb(result.getAlbAfter());
    Double calcCorCaAfter = this.getCalcCorCa(result);
    String valueBefore = calcCorCaBefore == null ? ExamResultCalcConstant.CALC_RESULT_NONE : String.format("%1$.20f", calcCorCaBefore);
    String valueAfter = calcCorCaAfter == null ? ExamResultCalcConstant.CALC_RESULT_NONE : String.format("%1$.20f", calcCorCaAfter);

    //add 9737 Ca gjn start
    List<PatExamMain> listBefore = new ArrayList<>();
    List<PatExamMain> listAfter = new ArrayList<>();

    listBefore = list.stream().filter(x -> ExamResultCalcConstant.OrderClass.BEFORE_DIALYSIS.equals(x.getRegOrderClass())).collect(Collectors.toList());
    listAfter = list.stream().filter(x -> ExamResultCalcConstant.OrderClass.AFTER_DIALYSIS.equals(x.getRegOrderClass())).collect(Collectors.toList());

    //補正化Caに対応する血清Ca濃度と血清アルブミンのmst中のデータを取り出す
    ArrayList<String> defaultCalcExamItemCdList = new ArrayList<>();
    defaultCalcExamItemCdList.add(ExamResultCalcConstant.ExamResultCalcColumns.SERUM_CA_CONCENTRATION);
    defaultCalcExamItemCdList.add(ExamResultCalcConstant.ExamResultCalcColumns.SERUM_ALBUMIN_CONCENTRATION);
    List<MstExamItem> mstExamItems = mstExamItemDao.selectByDefaultCalcExamItemCdListAndExamClass(examResultParam.getFacilityCd(), defaultCalcExamItemCdList, ExamClass.EXAM_ITEM);

    //その他の検査項目をlistAfterに入れる
    List<PatExamMain> patExamMains_other = list.stream().filter(x -> ExamResultCalcConstant.OrderClass.OTHER_DIALYSIS.equals(x.getRegOrderClass())).collect(Collectors.toList());
    for (PatExamMain patExamMain_type : patExamMains_other) {
        String dfp = this.checkExamForType(mstExamItems, patExamMain_type);
      if (ExamResultCalcConstant.DialysisProgressFlag.BEFORE.equals(dfp)) {
        listBefore.add(patExamMain_type);
      } else if (ExamResultCalcConstant.DialysisProgressFlag.AFTER.equals(dfp)) {
        listAfter.add(patExamMain_type);
      } else if (StringUtils.isEmpty(dfp)) { //血清アルブミン濃度と血清Ca濃度が空の検査項目は、listBeforeに一時的に追加し、以下に単独で処理する
        listBefore.add(patExamMain_type);
      } else {
        //その他（すべて）排除する
      }
    }
    //add 9737 Ca gjn end

    if (listBefore.size() > 0) {
      for (PatExamMain patExamMain : listBefore) {
        String info = patExamMain.getExamResultInfo();
        List<PatExamMainExamResultInfo> resInfo = new ObjectMapper().readValue(info, new TypeReference<List<PatExamMainExamResultInfo>>() {});
        List<PatExamMainExamResultInfo> filter = resInfo.stream().filter(x -> x.getItem_cd().equals(examResultParam.getCorCaItemCd())).collect(Collectors.toList());
        //mod 9737 Ca gjn start
        if (filter.size() > 0) {
          //血清Ca濃度と血清アルブミン濃度の両方の検査項目がresInfoで空であるかどうかを検証する
          boolean isCun = false;
          for (PatExamMainExamResultInfo patExamMainExamResultInfo : resInfo) {
            for (MstExamItem mstExamItem : mstExamItems) {
              if (String.valueOf(mstExamItem.getExamItemCd()).equals(patExamMainExamResultInfo.getItem_cd())) {
                isCun=true;
              }
            }
          }
          if (isCun) {
            resInfo = resInfo.stream().map(x -> {
              if (x.getItem_cd().equals(examResultParam.getCorCaItemCd())) {
                x.setResult(valueBefore);
              }
              return x;
            }).collect(Collectors.toList());
          } else {
            resInfo = resInfo.stream().map(x -> {
              if (x.getItem_cd().equals(examResultParam.getCorCaItemCd())) {
                x.setResult("");
              }
              return x;
            }).collect(Collectors.toList());
          }
          //mod 9737 Ca gjn end
        } else {
          MstExamItem mstExamItem = mstExamItemDao.selectByExamItemCd(Long.parseLong(examResultParam.getCorCaItemCd()));
          if (null != mstExamItem) {
            resInfo.add(new PatExamMainExamResultInfo() {
              {
                setItem_cd(mstExamItem.getExamItemCd().toString());
                setHl("");
                setCom_cd("");
                setFreememo("");
                setResult_date(examResultParam.getStrUpDt());
                setItem_name(mstExamItem.getExamItemName());
                setType(mstExamItem.getDataType());
                setUnit(mstExamItem.getUnit());
                if (null != mstExamItem.getNormalValueUpper()) {
                  setUpper(mstExamItem.getNormalValueUpper().toString());
                } else {
                  setUpper("");
                }
                if (null != mstExamItem.getNormalValueLower()) {
                  setLower(mstExamItem.getNormalValueLower().toString());
                } else {
                  setLower("");
                }
                setExam_class(mstExamItem.getExamClass());
                setJlac10_cd(mstExamItem.getJlac10Cd());
                setResult(valueBefore);
              }
            });
          }
        }
        //add 10140 透析前-補正化Caパラメータが欠落している場合にその計算式を削除する gjn start
        resInfo = resInfo.stream().filter(f -> (!StringUtils.isEmpty(f.getResult()))).distinct().collect(Collectors.toList());
        //add 10140 透析前-補正化Caパラメータが欠落している場合にその計算式を削除する gjn end
        StringBuilder strUpdResultInfo = new StringBuilder();
        strUpdResultInfo.append("[");
        for (PatExamMainExamResultInfo examResultOne : resInfo) {
          //add 9615 因島帳票の表示不具合（検査結果出力1~4）zhao start
          examResultOne = this.getDecimal(examResultOne,examResultParam.getFacilityCd());
          //add 9615 因島帳票の表示不具合（検査結果出力1~4）zhao end
          strUpdResultInfo.append(examResultOne.getValue());
          strUpdResultInfo.append(",");
        }
        strUpdResultInfo.deleteCharAt(strUpdResultInfo.length() - 1);
        strUpdResultInfo.append("]");
        // 計算完了後検査結果を更新する
        patExamMain.setExamResultInfo(strUpdResultInfo.toString());
        patExamMain.setUpDate(new Timestamp(System.currentTimeMillis()));
        patExamMainDao.updateResultExamSetInfo(patExamMain);
      }
    }
    if (listAfter.size() > 0) {
      for (PatExamMain patExamMain : listAfter) {
        String info = patExamMain.getExamResultInfo();
        List<PatExamMainExamResultInfo> resInfo = new ObjectMapper().readValue(info, new TypeReference<List<PatExamMainExamResultInfo>>() {
        });
        List<PatExamMainExamResultInfo> filter = resInfo.stream().filter(x -> x.getItem_cd().equals(examResultParam.getCorCaItemCd())).collect(Collectors.toList());
        //mod 9737 Ca gjn start
        if (filter.size() > 0) {
          //血清Ca濃度と血清アルブミン濃度の両方の検査項目がresInfoで空であるかどうかを検証する
          boolean isCun = false;
          for (PatExamMainExamResultInfo patExamMainExamResultInfo : resInfo) {
            for (MstExamItem mstExamItem : mstExamItems) {
              if (String.valueOf(mstExamItem.getExamItemCd()).equals(patExamMainExamResultInfo.getItem_cd())) {
                isCun=true;
              }
            }
          }
          if (isCun) {
            resInfo = resInfo.stream().map(x -> {
              if (x.getItem_cd().equals(examResultParam.getCorCaItemCd())) {
                x.setResult(valueAfter);
              }
              return x;
            }).collect(Collectors.toList());
          } else {
            resInfo = resInfo.stream().map(x -> {
              if (x.getItem_cd().equals(examResultParam.getCorCaItemCd())) {
                x.setResult("");
              }
              return x;
            }).collect(Collectors.toList());
          }
          //mod 9737 Ca gjn end
        } else {
          MstExamItem mstExamItem = mstExamItemDao.selectByExamItemCd(Long.parseLong(examResultParam.getCorCaItemCd()));
          if (null != mstExamItem) {
            resInfo.add(new PatExamMainExamResultInfo() {
              {
                setItem_cd(mstExamItem.getExamItemCd().toString());
                setHl("");
                setCom_cd("");
                setFreememo("");
                setResult_date(examResultParam.getStrUpDt());
                setItem_name(mstExamItem.getExamItemName());
                setType(mstExamItem.getDataType());
                setUnit(mstExamItem.getUnit());
                if (null != mstExamItem.getNormalValueUpper()) {
                  setUpper(mstExamItem.getNormalValueUpper().toString());
                } else {
                  setUpper("");
                }
                if (null != mstExamItem.getNormalValueLower()) {
                  setLower(mstExamItem.getNormalValueLower().toString());
                } else {
                  setLower("");
                }
                setExam_class(mstExamItem.getExamClass());
                setJlac10_cd(mstExamItem.getJlac10Cd());
                setResult(valueAfter);
              }
            });
          }
        }
        //add 10140 透析後−補正化Caパラメータが欠落している場合にその計算式を削除する gjn start
        resInfo = resInfo.stream().filter(f -> (!StringUtils.isEmpty(f.getResult()))).distinct().collect(Collectors.toList());
        //add 10140 透析後−補正化Caパラメータが欠落している場合にその計算式を削除する gjn end
        StringBuilder strUpdResultInfo = new StringBuilder();
        strUpdResultInfo.append("[");
        for (PatExamMainExamResultInfo examResultOne : resInfo) {
          //add 9615 因島帳票の表示不具合（検査結果出力1~4）zhao start
          examResultOne = this.getDecimal(examResultOne,examResultParam.getFacilityCd());
          //add 9615 因島帳票の表示不具合（検査結果出力1~4）zhao end
          strUpdResultInfo.append(examResultOne.getValue());
          strUpdResultInfo.append(",");
        }
        strUpdResultInfo.deleteCharAt(strUpdResultInfo.length() - 1);
        strUpdResultInfo.append("]");
        // 計算完了後検査結果を更新する
        patExamMain.setExamResultInfo(strUpdResultInfo.toString());
        patExamMain.setUpDate(new Timestamp(System.currentTimeMillis()));
        patExamMainDao.updateResultExamSetInfo(patExamMain);
      }
    }
  }

  private ExamResult setValue(ExamResult examResult, List<PatExamMain> patExamMains, List<MstExamItem> mstExamItems, String examResultCalcColumn) {
    for (PatExamMain data : patExamMains) {
      if (data.getExamResultInfo() != null && !data.getExamResultInfo().isEmpty()) {
        JSONArray info = new JSONArray(data.getExamResultInfo());
        if (ExamResultCalcConstant.OrderClass.BEFORE_DIALYSIS.equals(data.getRegOrderClass())) {
          for (int i = 0; i < info.length(); i++) {
            JSONObject object = info.getJSONObject(i);
            if (object.has("result") && !StringUtils.isEmpty(object.get("result").toString())
              && object.has("item_cd") && !StringUtils.isEmpty(object.get("item_cd"))) {
              List<MstExamItem> examItems = mstExamItems.stream().filter(x -> object.get("item_cd").toString().equals(x.getExamItemCd().toString())).collect(Collectors.toList());
              if (examItems.size() == 1) {
                if (ExamResultCalcConstant.DialysisProgressFlag.BEFORE.equals(examItems.get(0).getDialysisProgressFlag())
                  || ExamResultCalcConstant.DialysisProgressFlag.ALL.equals(examItems.get(0).getDialysisProgressFlag())) {
                  if (ExamResultCalcConstant.ExamResultCalcColumns.BUN.equals(examResultCalcColumn)) {
                    examResult.setBunBefore(object.get("result").toString());
                  } else if (ExamResultCalcConstant.ExamResultCalcColumns.SERUM_CA_CONCENTRATION.equals(examResultCalcColumn)) {
                    examResult.setCaBefore(object.get("result").toString());
                  } else if (ExamResultCalcConstant.ExamResultCalcColumns.SERUM_ALBUMIN_CONCENTRATION.equals(examResultCalcColumn)) {
                    examResult.setAlbBefore(object.get("result").toString());
                  } else if (ExamResultCalcConstant.ExamResultCalcColumns.CREATININE.equals(examResultCalcColumn)) {
                    examResult.setCrBefore(object.get("result").toString());
                  } else if (ExamResultCalcConstant.ExamResultCalcColumns.SERUM_FE.equals(examResultCalcColumn)) {
                    examResult.setFeBefore(object.get("result").toString());
                  } else if (ExamResultCalcConstant.ExamResultCalcColumns.TIBC.equals(examResultCalcColumn)) {
                    examResult.setTibcBefore(object.get("result").toString());
                  } else if (ExamResultCalcConstant.ExamResultCalcColumns.HEMATOCRIT.equals(examResultCalcColumn)) {
                    examResult.setValHemBefore(object.get("result").toString());
                  }
                } else if (ExamResultCalcConstant.DialysisProgressFlag.AFTER.equals(examItems.get(0).getDialysisProgressFlag())) {
                  if (ExamResultCalcConstant.ExamResultCalcColumns.BUN.equals(examResultCalcColumn)) {
                    examResult.setBunAfter(object.get("result").toString());
                  } else if (ExamResultCalcConstant.ExamResultCalcColumns.SERUM_CA_CONCENTRATION.equals(examResultCalcColumn)) {
                    examResult.setCaAfter(object.get("result").toString());
                  } else if (ExamResultCalcConstant.ExamResultCalcColumns.SERUM_ALBUMIN_CONCENTRATION.equals(examResultCalcColumn)) {
                    examResult.setAlbAfter(object.get("result").toString());
                  } else if (ExamResultCalcConstant.ExamResultCalcColumns.CREATININE.equals(examResultCalcColumn)) {
                    examResult.setCrAfter(object.get("result").toString());
                  } else if (ExamResultCalcConstant.ExamResultCalcColumns.HEMATOCRIT.equals(examResultCalcColumn)) {
                    examResult.setValHemAfter(object.get("result").toString());
                  }
                }
              }
            }
          }
        } else if (ExamResultCalcConstant.OrderClass.AFTER_DIALYSIS.equals(data.getRegOrderClass())) {
          for (int i = 0; i < info.length(); i++) {
            JSONObject object = info.getJSONObject(i);
            if (object.has("result") && !StringUtils.isEmpty(object.get("result").toString())
              && object.has("item_cd") && !StringUtils.isEmpty(object.get("item_cd"))) {
              List<MstExamItem> examItems = mstExamItems.stream().filter(x -> object.get("item_cd").toString().equals(x.getExamItemCd().toString())).collect(Collectors.toList());
              if (examItems.size() == 1) {
                if (ExamResultCalcConstant.DialysisProgressFlag.AFTER.equals(examItems.get(0).getDialysisProgressFlag())
                  || ExamResultCalcConstant.DialysisProgressFlag.ALL.equals(examItems.get(0).getDialysisProgressFlag())) {
                  if (ExamResultCalcConstant.ExamResultCalcColumns.BUN.equals(examResultCalcColumn)) {
                    examResult.setBunAfter(object.get("result").toString());
                  } else if (ExamResultCalcConstant.ExamResultCalcColumns.SERUM_CA_CONCENTRATION.equals(examResultCalcColumn)) {
                    examResult.setCaAfter(object.get("result").toString());
                  } else if (ExamResultCalcConstant.ExamResultCalcColumns.SERUM_ALBUMIN_CONCENTRATION.equals(examResultCalcColumn)) {
                    examResult.setAlbAfter(object.get("result").toString());
                  } else if (ExamResultCalcConstant.ExamResultCalcColumns.CREATININE.equals(examResultCalcColumn)) {
                    examResult.setCrAfter(object.get("result").toString());
                  } else if (ExamResultCalcConstant.ExamResultCalcColumns.HEMATOCRIT.equals(examResultCalcColumn)) {
                    examResult.setValHemAfter(object.get("result").toString());
                  }
                } else if (ExamResultCalcConstant.DialysisProgressFlag.BEFORE.equals(examItems.get(0).getDialysisProgressFlag())) {
                  if (ExamResultCalcConstant.ExamResultCalcColumns.BUN.equals(examResultCalcColumn)) {
                    examResult.setBunBefore(object.get("result").toString());
                  } else if (ExamResultCalcConstant.ExamResultCalcColumns.SERUM_CA_CONCENTRATION.equals(examResultCalcColumn)) {
                    examResult.setCaBefore(object.get("result").toString());
                  } else if (ExamResultCalcConstant.ExamResultCalcColumns.SERUM_ALBUMIN_CONCENTRATION.equals(examResultCalcColumn)) {
                    examResult.setAlbBefore(object.get("result").toString());
                  } else if (ExamResultCalcConstant.ExamResultCalcColumns.CREATININE.equals(examResultCalcColumn)) {
                    examResult.setCrBefore(object.get("result").toString());
                  } else if (ExamResultCalcConstant.ExamResultCalcColumns.SERUM_FE.equals(examResultCalcColumn)) {
                    examResult.setFeBefore(object.get("result").toString());
                  } else if (ExamResultCalcConstant.ExamResultCalcColumns.TIBC.equals(examResultCalcColumn)) {
                    examResult.setTibcBefore(object.get("result").toString());
                  } else if (ExamResultCalcConstant.ExamResultCalcColumns.HEMATOCRIT.equals(examResultCalcColumn)) {
                    examResult.setValHemBefore(object.get("result").toString());
                  }
                }
              }
            }
          }
        } else {
          for (int i = 0; i < info.length(); i++) {
            JSONObject object = info.getJSONObject(i);
            if (object.has("result") && !StringUtils.isEmpty(object.get("result").toString())
              && object.has("item_cd") && !StringUtils.isEmpty(object.get("item_cd"))) {
              List<MstExamItem> examItems = mstExamItems.stream().filter(x -> object.get("item_cd").toString().equals(x.getExamItemCd().toString())).collect(Collectors.toList());
              if (examItems.size() == 1) {
                if (ExamResultCalcConstant.DialysisProgressFlag.BEFORE.equals(examItems.get(0).getDialysisProgressFlag())) {
                  if (ExamResultCalcConstant.ExamResultCalcColumns.BUN.equals(examResultCalcColumn)) {
                    examResult.setBunBefore(object.get("result").toString());
                  } else if (ExamResultCalcConstant.ExamResultCalcColumns.SERUM_CA_CONCENTRATION.equals(examResultCalcColumn)) {
                    examResult.setCaBefore(object.get("result").toString());
                  } else if (ExamResultCalcConstant.ExamResultCalcColumns.SERUM_ALBUMIN_CONCENTRATION.equals(examResultCalcColumn)) {
                    examResult.setAlbBefore(object.get("result").toString());
                  } else if (ExamResultCalcConstant.ExamResultCalcColumns.CREATININE.equals(examResultCalcColumn)) {
                    examResult.setCrBefore(object.get("result").toString());
                  } else if (ExamResultCalcConstant.ExamResultCalcColumns.SERUM_FE.equals(examResultCalcColumn)) {
                    examResult.setFeBefore(object.get("result").toString());
                  } else if (ExamResultCalcConstant.ExamResultCalcColumns.TIBC.equals(examResultCalcColumn)) {
                    examResult.setTibcBefore(object.get("result").toString());
                  } else if (ExamResultCalcConstant.ExamResultCalcColumns.HEMATOCRIT.equals(examResultCalcColumn)) {
                    examResult.setValHemBefore(object.get("result").toString());
                  }
                } else if (ExamResultCalcConstant.DialysisProgressFlag.AFTER.equals(examItems.get(0).getDialysisProgressFlag())) {
                  if (ExamResultCalcConstant.ExamResultCalcColumns.BUN.equals(examResultCalcColumn)) {
                    examResult.setBunAfter(object.get("result").toString());
                  } else if (ExamResultCalcConstant.ExamResultCalcColumns.SERUM_CA_CONCENTRATION.equals(examResultCalcColumn)) {
                    examResult.setCaAfter(object.get("result").toString());
                  } else if (ExamResultCalcConstant.ExamResultCalcColumns.SERUM_ALBUMIN_CONCENTRATION.equals(examResultCalcColumn)) {
                    examResult.setAlbAfter(object.get("result").toString());
                  } else if (ExamResultCalcConstant.ExamResultCalcColumns.CREATININE.equals(examResultCalcColumn)) {
                    examResult.setCrAfter(object.get("result").toString());
                  } else if (ExamResultCalcConstant.ExamResultCalcColumns.HEMATOCRIT.equals(examResultCalcColumn)) {
                    examResult.setValHemAfter(object.get("result").toString());
                  }
                }
              }
            }
          }
        }
      }
    }
    return examResult;
  }

  private void afterGroupAfterHandle(ExamResultParam examResultParam, List<List<PatExamMain>> afterList, List<List<PatExamMain>> afterGroup) {
    if (afterList.size() == 0) {
      return;
    }
    for (int i = 0; i < afterList.size(); i++) {
      List<PatExamMain> thisOne = afterList.get(i);
      if (thisOne.size() == 1) {
        if (ExamResultCalcConstant.OrderClass.BEFORE_DIALYSIS.equals(thisOne.get(0).getRegOrderClass())) {
          break;
        } else if (ExamResultCalcConstant.OrderClass.AFTER_DIALYSIS.equals(thisOne.get(0).getRegOrderClass())) {
          afterGroup.add(thisOne);
        } else {
          List<String> differentFlagList = this.getDifferentFlagList(examResultParam, thisOne.get(0));
          differentFlagList = differentFlagList.stream().filter(x -> !StringUtils.isEmpty(x)).filter(x -> !ExamResultCalcConstant.DialysisProgressFlag.EMPTY.equals(x)).collect(Collectors.toList());
          //mod 9734 guan start
          if (differentFlagList.contains(ExamResultCalcConstant.DialysisProgressFlag.BEFORE)) { //TODO ALL不能break了 || differentFlagList.contains(ExamResultCalcConstant.DialysisProgressFlag.ALL)) {
            break;
          } else if (differentFlagList.contains(ExamResultCalcConstant.DialysisProgressFlag.AFTER)) {
            afterGroup.add(thisOne);
          } else { //TODO ALL（会儿）加入afterGroup
            afterGroup.add(thisOne);
          }
        }
      } else {
        List<PatExamMain> filterBefore = thisOne.stream().filter(x -> ExamResultCalcConstant.OrderClass.BEFORE_DIALYSIS.equals(x.getRegOrderClass())).collect(Collectors.toList());
        if (filterBefore.size() == 1) {
          break;
        } else { //同時刻に複数本の下に前がなく、それは後ろとALLだけである
          List<PatExamMain> filterOther = thisOne.stream().filter(x -> ExamResultCalcConstant.OrderClass.OTHER_DIALYSIS.equals(x.getRegOrderClass())).collect(Collectors.toList());
 //         if (filterOther.size() == 1) {
            List<String> differentFlagList = this.getDifferentFlagList(examResultParam, filterOther.get(0));
            differentFlagList = differentFlagList.stream().filter(x -> !StringUtils.isEmpty(x)).filter(x -> !ExamResultCalcConstant.DialysisProgressFlag.EMPTY.equals(x)).collect(Collectors.toList());
            if (differentFlagList.contains(ExamResultCalcConstant.DialysisProgressFlag.BEFORE)) { //TODO ALL不能break || differentFlagList.contains(ExamResultCalcConstant.DialysisProgressFlag.ALL)) {
              break;
            } else if (differentFlagList.contains(ExamResultCalcConstant.DialysisProgressFlag.AFTER) || differentFlagList.contains(ExamResultCalcConstant.DialysisProgressFlag.ALL)) {
              afterGroup.add(thisOne); //TODO 含める後もALLもグループに入れる必要があります
            }
//          } else {
//            afterGroup.add(thisOne);
//          }
          //mod 9734 guan end
        }
      }
    }
  }

  private void afterGroupBeforeHandle(ExamResultParam examResultParam, List<List<PatExamMain>> afterList, List<List<PatExamMain>> afterGroup) {
    if (afterList.size() == 0) {
      return;
    }
    Boolean isHasAfter = false;
    for (int i = 0; i < afterList.size(); i++) {
      List<PatExamMain> thisOne = afterList.get(i);
      if (thisOne.size() == 1) {
        if (ExamResultCalcConstant.OrderClass.BEFORE_DIALYSIS.equals(thisOne.get(0).getRegOrderClass())) {
          if (isHasAfter) {
            break;
          } else {
            afterGroup.add(thisOne);
          }
        } else if (ExamResultCalcConstant.OrderClass.AFTER_DIALYSIS.equals(thisOne.get(0).getRegOrderClass())) {
          afterGroup.add(thisOne);
          isHasAfter = true;
        } else {
          List<String> differentFlagList = this.getDifferentFlagList(examResultParam, thisOne.get(0));
          differentFlagList = differentFlagList.stream().filter(x -> !StringUtils.isEmpty(x)).filter(x -> !ExamResultCalcConstant.DialysisProgressFlag.EMPTY.equals(x)).collect(Collectors.toList());
          //mod 9734 guan start
          if (isHasAfter) { //帯後
            if (differentFlagList.contains(ExamResultCalcConstant.DialysisProgressFlag.BEFORE)){ //TODO || differentFlagList.contains(ExamResultCalcConstant.DialysisProgressFlag.ALL)) {
              break;
            } else if (differentFlagList.contains(ExamResultCalcConstant.DialysisProgressFlag.AFTER)) {
              afterGroup.add(thisOne);
            } else { //TODO ALL（全）単独判定が必要
              afterGroup.add(thisOne); //TODO グループ内に入れて後ろに探し続ける
            }
          } else { //バックバンドなし
            if (differentFlagList.contains(ExamResultCalcConstant.DialysisProgressFlag.AFTER)){ //TODO ALLの場合は後ろマークが必要なく、グループ内に入れるだけなので || differentFlagList.contains(ExamResultCalcConstant.DialysisProgressFlag.ALL)) {
              isHasAfter = true;
            }
            //前、後、ALLはすべて参加します
            afterGroup.add(thisOne);
          }
//          if (isHasAfter && differentFlagList.contains(ExamResultCalcConstant.DialysisProgressFlag.BEFORE)) {
//            break;
//          } else if (differentFlagList.contains(ExamResultCalcConstant.DialysisProgressFlag.AFTER)) {
//            afterGroup.add(thisOne);
//            isHasAfter = true;
//          } else {
//            afterGroup.add(thisOne);
//          }
        //mod 9734 guan end
        }
      } else {
        //mod 9734 guan start
        List<PatExamMain> filterBefore = thisOne.stream().filter(x -> ExamResultCalcConstant.OrderClass.BEFORE_DIALYSIS.equals(x.getRegOrderClass())).collect(Collectors.toList());
        if (filterBefore.size() == 1) {
          if (isHasAfter) {
            break;
          }
        }
        List<PatExamMain> filterOther = thisOne.stream().filter(x -> ExamResultCalcConstant.OrderClass.OTHER_DIALYSIS.equals(x.getRegOrderClass())).collect(Collectors.toList());
        if (filterOther.size() == 1) {
          List<String> differentFlagList = this.getDifferentFlagList(examResultParam, filterOther.get(0));
          differentFlagList = differentFlagList.stream().filter(x -> !StringUtils.isEmpty(x)).filter(x -> !ExamResultCalcConstant.DialysisProgressFlag.EMPTY.equals(x)).collect(Collectors.toList());
          if (differentFlagList.contains(ExamResultCalcConstant.DialysisProgressFlag.BEFORE)){ //TODO ALL不能break || differentFlagList.contains(ExamResultCalcConstant.DialysisProgressFlag.ALL)) {
            if (isHasAfter) {
              break;
            }
          }
          if (differentFlagList.contains(ExamResultCalcConstant.DialysisProgressFlag.AFTER)){ //TODO ALL需要单独判断，不需要标记有后了 || differentFlagList.contains(ExamResultCalcConstant.DialysisProgressFlag.ALL)) {
            isHasAfter = true;
          }
          //TODO ALL的情况下无需判断了，下面会直接加入到afterGroup
        }
        List<PatExamMain> filterAfter = thisOne.stream().filter(x -> ExamResultCalcConstant.OrderClass.AFTER_DIALYSIS.equals(x.getRegOrderClass())).collect(Collectors.toList());
        if (filterAfter.size() == 1) {
          isHasAfter = true;
        }
        //mod 9734 guan end
        afterGroup.add(thisOne);
      }
    }
  }

  //mod 9734 guan start
  /**
   * 当前是その他是ALL的情况下向后找，要看beforGroup的最后一个是啥，作为向后找的依据
   *
   * @param examResultParam
   * @param afterList
   * @param afterGroup
   * @param beforeGroup
   */
  private void afterGroupOtherHandle (ExamResultParam examResultParam, List<List<PatExamMain>> afterList, List<List<PatExamMain>> afterGroup, List<List<PatExamMain>> beforeGroup) {
    if (beforeGroup.size() > 0) { //前面有
      for (int i = 0; i < beforeGroup.size(); i++) {
        if (beforeGroup.get(i).size() == 1) { //前面同一时刻有一个的情况下，因为beforeGroup.get(0)第一个是最先放进去的
          if (beforeGroup.get(i).get(0).getRegOrderClass().equals(ExamResultCalcConstant.OrderClass.BEFORE_DIALYSIS)) {
            this.afterGroupBeforeHandle(examResultParam, afterList, afterGroup); //前一个前，按照前向后找
            break;
          } else if (beforeGroup.get(i).get(0).getRegOrderClass().equals(ExamResultCalcConstant.OrderClass.AFTER_DIALYSIS)) {
            this.afterGroupAfterHandle(examResultParam, afterList, afterGroup); //前一个后，按照后向后找
            break;
          } else { //ALL
            continue; //前一个ALL全，继续循环向前找
          }
        } else { //前面同一时刻有多个的情况下(前后，前ALl，后ALL, 前后ALL)
          List<PatExamMain> filterAfter = beforeGroup.get(i).stream().filter(x -> ExamResultCalcConstant.OrderClass.AFTER_DIALYSIS.equals(x.getRegOrderClass())).collect(Collectors.toList());
          List<PatExamMain> filterBefor = beforeGroup.get(i).stream().filter(x -> ExamResultCalcConstant.OrderClass.BEFORE_DIALYSIS.equals(x.getRegOrderClass())).collect(Collectors.toList());
          if (filterAfter.size() == 1) { //有后
            this.afterGroupAfterHandle(examResultParam, afterList, afterGroup); //前一个多个的情况下，有后按照当前是后向后找
            break;
          }
          if (filterBefor.size() == 1) { //有前
            this.afterGroupBeforeHandle(examResultParam, afterList, afterGroup); //前一个多个的情况下，没后有前按照当前是前向后找
            break;
          }
          //TODO ALL 多个情况下有ALL要忽略
        }
      }
    } else { //当前その他 前面没有检查结果的情况下，按照当前是前向后找，是没有问题的
      this.afterGroupBeforeHandle(examResultParam, afterList, afterGroup);
    }
  }
//mod 9734 guan end

  //mod 9734 guan start
  private void beforeGroupAfterHandle(ExamResultParam examResultParam, ExamResult examResult, List<List<PatExamMain>> beforeList, List<List<PatExamMain>> beforeGroup, Boolean isHasBefore) {
    if (beforeList.size() == 0) {
      return;
    }
    for (int i = beforeList.size() - 1; i >= 0; i--) {
      List<PatExamMain> thisOne = beforeList.get(i);
      if (thisOne.size() == 1) {
        // 1:透析前
        if (ExamResultCalcConstant.OrderClass.BEFORE_DIALYSIS.equals(thisOne.get(0).getRegOrderClass())) {
          beforeGroup.add(thisOne);
          isHasBefore = true;
        } else if (ExamResultCalcConstant.OrderClass.AFTER_DIALYSIS.equals(thisOne.get(0).getRegOrderClass())) {
          if (isHasBefore) {
            this.setLastTimeBunAfter(examResultParam, examResult, beforeList, i);
            break;
          } else {
            beforeGroup.add(thisOne);
          }
        } else {
          List<String> differentFlagList = this.getDifferentFlagList(examResultParam, thisOne.get(0));
          differentFlagList = differentFlagList.stream().filter(x -> !StringUtils.isEmpty(x)).filter(x -> !ExamResultCalcConstant.DialysisProgressFlag.EMPTY.equals(x)).collect(Collectors.toList());
          if (isHasBefore) {
            if (differentFlagList.contains(ExamResultCalcConstant.DialysisProgressFlag.AFTER)) {
              this.setLastTimeBunAfter(examResultParam, examResult, beforeList, i);
              break;
            } else if (differentFlagList.contains(ExamResultCalcConstant.DialysisProgressFlag.ALL)) {
              //break; //TODO 会儿 扔到组内继续向前找
              beforeGroup.add(thisOne);
            } else if (differentFlagList.contains(ExamResultCalcConstant.DialysisProgressFlag.BEFORE)) {
              beforeGroup.add(thisOne);
              //isHasBefore = true;
            }
          } else  {
            if (differentFlagList.contains(ExamResultCalcConstant.DialysisProgressFlag.ALL)
              || differentFlagList.contains(ExamResultCalcConstant.DialysisProgressFlag.BEFORE)) {
              beforeGroup.add(thisOne);
              isHasBefore = true;
            } else { // if (differentFlagList.contains(ExamResultCalcConstant.DialysisProgressFlag.AFTER)) {
              beforeGroup.add(thisOne);
            }
          }
        }
      } else {
        List<PatExamMain> filterAfter = thisOne.stream().filter(x -> ExamResultCalcConstant.OrderClass.AFTER_DIALYSIS.equals(x.getRegOrderClass())).collect(Collectors.toList());
        List<PatExamMain> filterBefore = thisOne.stream().filter(x -> ExamResultCalcConstant.OrderClass.BEFORE_DIALYSIS.equals(x.getRegOrderClass())).collect(Collectors.toList());
        List<PatExamMain> filterOther = thisOne.stream().filter(x -> ExamResultCalcConstant.OrderClass.OTHER_DIALYSIS.equals(x.getRegOrderClass())).collect(Collectors.toList());
        //同時刻における複数の検査結果の前処理透析後は、同時刻における複数の検査結果の透析前とその他がisHasBeforeをtrueに早める
        if (filterAfter.size() == 1) {
          if (isHasBefore) {
            this.setLastTimeBunAfter(examResultParam, examResult, beforeList, i);
            break;
          }
        }
        //その他
        if (filterOther.size() == 1) {
          List<String> differentFlagList = this.getDifferentFlagList(examResultParam, filterOther.get(0));
          differentFlagList = differentFlagList.stream().filter(x -> !StringUtils.isEmpty(x)).filter(x -> !ExamResultCalcConstant.DialysisProgressFlag.EMPTY.equals(x)).collect(Collectors.toList());
          if (isHasBefore) {
            if (differentFlagList.contains(ExamResultCalcConstant.DialysisProgressFlag.AFTER)) {
                this.setLastTimeBunAfter(examResultParam, examResult, beforeList, i);
                break;
//            } else if (differentFlagList.contains(ExamResultCalcConstant.DialysisProgressFlag.ALL)) {
//              break; //TODO 会儿 啥也不操作，也不需要判断了，因为下面只有前了，所以会把当前这个放进组里
//              //isHasBefore = true;
            }
          } else {
            if (differentFlagList.contains(ExamResultCalcConstant.DialysisProgressFlag.BEFORE)) { //TODO 会儿，不需要判断了 ||  differentFlagList.contains(ExamResultCalcConstant.DialysisProgressFlag.ALL)) {
              isHasBefore = true;
            }
          }
//          if (differentFlagList.contains(ExamResultCalcConstant.DialysisProgressFlag.BEFORE)) {
//            isHasBefore = true;
//          } else if (differentFlagList.contains(ExamResultCalcConstant.DialysisProgressFlag.AFTER)) {
//            if (isHasBefore) {
//              this.setLastTimeBunAfter(examResultParam, examResult, beforeList, i);
//              break;
//            }
//          }
        }
        if (filterBefore.size() == 1) {
          isHasBefore = true;
        }
        beforeGroup.add(thisOne);
      }
    }
  }
 //mod 9734 guan end

  private void beforeGroupBeforeHandle(ExamResultParam examResultParam, ExamResult examResult, List<List<PatExamMain>> beforeList, List<List<PatExamMain>> beforeGroup) {
    if (beforeList.size() == 0) {
      return;
    }
    //mod 9734 guan start
    for (int i = beforeList.size() - 1; i >= 0; i--) {
      List<PatExamMain> thisOne = beforeList.get(i);
      if (thisOne.size() == 1) {
        // 1:透析前
        if (ExamResultCalcConstant.OrderClass.BEFORE_DIALYSIS.equals(thisOne.get(0).getRegOrderClass())) {
          beforeGroup.add(thisOne);
          // 2:透析後
        } else if (ExamResultCalcConstant.OrderClass.AFTER_DIALYSIS.equals(thisOne.get(0).getRegOrderClass())) {
          this.setLastTimeBunAfter(examResultParam, examResult, beforeList, i);
          break;
          // その他を読み替え
        } else {
          List<String> differentFlagList = this.getDifferentFlagList(examResultParam, thisOne.get(0));
          differentFlagList = differentFlagList.stream().filter(x -> !StringUtils.isEmpty(x)).filter(x -> !ExamResultCalcConstant.DialysisProgressFlag.EMPTY.equals(x)).collect(Collectors.toList());
          if (differentFlagList.contains(ExamResultCalcConstant.DialysisProgressFlag.AFTER)) {
            this.setLastTimeBunAfter(examResultParam, examResult, beforeList, i);
            break;
          } else if (differentFlagList.contains(ExamResultCalcConstant.DialysisProgressFlag.ALL)) {
            //break; //TODO 何もしないで、前に進み続けて、今は前に進み続けて
            beforeGroup.add(thisOne);
          } else if (differentFlagList.contains(ExamResultCalcConstant.DialysisProgressFlag.BEFORE)) {
            beforeGroup.add(thisOne);
          }
        }
      } else {
        // 2:透析後
        List<PatExamMain> filterAfter = thisOne.stream().filter(x -> ExamResultCalcConstant.OrderClass.AFTER_DIALYSIS.equals(x.getRegOrderClass())).collect(Collectors.toList());
        if (filterAfter.size() == 1) {
          this.setLastTimeBunAfter(examResultParam, examResult, beforeList, i);
          break;
        } else {
          // 0:その他
          List<PatExamMain> filterOther = thisOne.stream().filter(x -> ExamResultCalcConstant.OrderClass.OTHER_DIALYSIS.equals(x.getRegOrderClass())).collect(Collectors.toList());
          if (filterOther.size() == 1) {
            List<String> differentFlagList = this.getDifferentFlagList(examResultParam, filterOther.get(0));
            differentFlagList = differentFlagList.stream().filter(x -> !StringUtils.isEmpty(x)).filter(x -> !ExamResultCalcConstant.DialysisProgressFlag.EMPTY.equals(x)).collect(Collectors.toList());
            if (differentFlagList.contains(ExamResultCalcConstant.DialysisProgressFlag.AFTER)) {
              this.setLastTimeBunAfter(examResultParam, examResult, beforeList, i);
              break;
            } else if (differentFlagList.contains(ExamResultCalcConstant.DialysisProgressFlag.ALL)) {
              //break; //TODO 何もしないで、前に進み続けて、まだ前に進み続けて、後ろはここまで歩いてこないので
              beforeGroup.add(thisOne);
            } else if (differentFlagList.contains(ExamResultCalcConstant.DialysisProgressFlag.BEFORE)) {
              beforeGroup.add(thisOne);
            }
            // 1:透析前
          } else {
            beforeGroup.add(thisOne);
          }
        }
      }
    }
    //mod 9734 guan end
  }

  private void setLastTimeBunAfter(ExamResultParam examResultParam, ExamResult examResult, List<List<PatExamMain>> beforeList, int x) {
    for (int i = x - 1; i >= 0; i--) {
      if (null != examResult.getLastTimeBunAfter()) {
        break;
      }
      List<PatExamMain> lastOne = beforeList.get(i);
      if (lastOne.size() == 1) {
        setLastTimeBunAfterHandle(examResultParam, examResult, lastOne.get(0));
      } else {
        for (int j = lastOne.size() - 1; j >= 0; j--) {
          if (null != examResult.getLastTimeBunAfter()) {
            break;
          }
          setLastTimeBunAfterHandle(examResultParam, examResult, lastOne.get(j));
        }
      }
    }
  }

  //mod 9734 グループ化後の計算値の修正 guan start
  private void setLastTimeBunAfterHandle(ExamResultParam examResultParam, ExamResult examResult, PatExamMain lastOne) {
    JSONArray info = new JSONArray(lastOne.getExamResultInfo());
    ArrayList<String> list = new ArrayList<>();
    list.add(ExamResultCalcConstant.ExamResultCalcColumns.BUN);
    List<MstExamItem> mstExamItems = mstExamItemDao.selectByDefaultCalcExamItemCdListAndExamClass(examResultParam.getFacilityCd(), list, ExamClass.EXAM_ITEM);
    for (int j = 0; j < info.length(); j++) {
      JSONObject object = info.getJSONObject(j);
      if (object.has("result") && !StringUtils.isEmpty(object.get("result").toString())
        && object.has("item_cd") && !StringUtils.isEmpty(object.get("item_cd"))) {
        Optional<MstExamItem> mstExamItem = mstExamItems.stream().filter(y -> y.getExamItemCd().toString().equals(object.get("item_cd").toString())).findFirst();
        if (mstExamItem.isPresent() && ExamResultCalcConstant.ExamResultCalcColumns.BUN.equals(mstExamItem.get().getDefaultCalcExamItemCd())) {
          if (ExamResultCalcConstant.DialysisProgressFlag.ALL.equals(mstExamItem.get().getDialysisProgressFlag())) { //TODO（すべて選択=3）
            if (ExamResultCalcConstant.OrderClass.OTHER_DIALYSIS.equals(lastOne.getRegOrderClass())) { //TODO 登録時検査区分=0の場合代表はその他
              break;
            } else if (ExamResultCalcConstant.OrderClass.AFTER_DIALYSIS.equals(lastOne.getRegOrderClass())) { //TODO TAC_BUNは前グループとの透析後のみ計算されるため、透析後の場合のみ値を取る
              examResult.setLastTimeBunAfter(object.get("result").toString());
            } else {
              break;
            }
          } else if (ExamResultCalcConstant.DialysisProgressFlag.AFTER.equals(mstExamItem.get().getDialysisProgressFlag())) {  //TODO 検査項目mstで透析後にチェックした場合、透析後のBUN値をそのまま取って使用し、前に探すのをやめた
            examResult.setLastTimeBunAfter(object.get("result").toString());
          } else { //TODO 検査項目mstにおいて透析前にチェックされている場合は、透析前に計算し、直接スキップし、次の検査結果を見る
            break;
          }
        }
      }
    }
  }
  //mod 9734 グループ化後の計算値の修正 guan end

  private List<String> getDifferentFlagList(ExamResultParam examResultParam, PatExamMain thisOne) {
    ArrayList<Long> itemCdList = new ArrayList<>();
    JSONArray examResultInfo = new JSONArray(thisOne.getExamResultInfo());
    for (int i = 0; i < examResultInfo.length(); i++) {
      JSONObject object = examResultInfo.getJSONObject(i);
      if (object.has("result") && !StringUtils.isEmpty(object.get("result")) && object.has("item_cd")) {
        String itemCd = object.get("item_cd").toString();
        itemCdList.add(Long.parseLong(itemCd));
      }
    }
    List<MstExamItem> mstExamItems = mstExamItemDao.selectByExamItemCdList(examResultParam.getFacilityCd(), itemCdList);
    List<String> dialysisProgressFlagList = mstExamItems.stream().map(MstExamItem::getDialysisProgressFlag).collect(Collectors.toList());
    List<String> differentFlagList = dialysisProgressFlagList.stream().filter(x -> null != x).distinct().collect(Collectors.toList());
    return differentFlagList;
  }

  private void setOrdMain(ExamResultParam examResultParam, ExamResult examResult) {
    // 指定日の透析実績・体重情報を取得
    List<OrdMainListInfo> ordMainList = ordMainDao.selectCdByFacilityCd(String.valueOf(examResultParam.getPatId()), examResultParam.getTargetDt(), examResultParam.getTargetDt(), null, null, "0");
    /* modify by chamaojia 2025-02-25 [11471] 【rst_device_mode】 no translation required --start */
//    List<MstTreatment> mstTreatmentList = mstTreatmentDao.selectDeviceModeByFacilityCd(examResultParam.getFacilityCd());
    Integer ordMainListFlg = null;
    OrdMainListInfo ordMainInfo = new OrdMainListInfo();
//    for (OrdMainListInfo ordMain : ordMainList) {
//      for (MstTreatment mstTreat : mstTreatmentList) {
//        if (ordMain.getRstTreatmentCd().equals(mstTreat.getTreatmentCd())) {
//          ordMain.setDeviceMode(mstTreat.getDeviceMode());
//        }
//      }
//    }
    /* modify by chamaojia 2025-02-25 [11471] 【rst_device_mode】 no translation required --end */

    for (OrdMainListInfo ordMain : ordMainList) {
      if (((ordMain.getRstStartDate().after(examResult.getExamStratTime()) && ordMain.getRstStartDate().before(examResult.getExamEndTime()))
        || (ordMain.getRstEndDate().after(examResult.getExamStratTime()) && ordMain.getRstEndDate().before(examResult.getExamEndTime())))
        && !ordMain.getDeviceMode().equals(9)) {
        ordMainListFlg = 1;
        ordMainInfo = ordMain;
        break;
      }
    }
    if (StringUtils.isEmpty(ordMainListFlg)) {
      for (OrdMainListInfo ordMain : ordMainList) {
        if (((ordMain.getRstStartDate().after(examResult.getExamStratTime()) && ordMain.getRstStartDate().before(examResult.getExamEndTime()))
          || (ordMain.getRstEndDate().after(examResult.getExamStratTime()) && ordMain.getRstEndDate().before(examResult.getExamEndTime())))
          && ordMain.getDeviceMode().equals(9)) {
          ordMainListFlg = 1;
          ordMainInfo = ordMain;
          break;
        }
      }
    }
    if (StringUtils.isEmpty(ordMainListFlg)) {
      for (OrdMainListInfo ordMain : ordMainList) {
        if (ordMain.getRstStartDate().compareTo(examResult.getExamEndTime()) > 0 && !ordMain.getDeviceMode().equals(9)) {
          ordMainListFlg = 2;
          ordMainInfo = ordMain;
          break;
        }
      }
    }
    if (StringUtils.isEmpty(ordMainListFlg)) {
      for (OrdMainListInfo ordMain : ordMainList) {
        if (ordMain.getRstStartDate().compareTo(examResult.getExamEndTime()) > 0 && ordMain.getDeviceMode().equals(9)) {
          ordMainListFlg = 2;
          ordMainInfo = ordMain;
          break;
        }
      }
    }
    if (StringUtils.isEmpty(ordMainListFlg)) {
      for (OrdMainListInfo ordMain : ordMainList) {
        if (ordMain.getRstStartDate().compareTo(examResult.getExamEndTime()) < 0 && !ordMain.getDeviceMode().equals(9)) {
          ordMainListFlg = 3;
          ordMainInfo = ordMain;
        }
      }
    }
    if (StringUtils.isEmpty(ordMainListFlg)) {
      for (OrdMainListInfo ordMain : ordMainList) {
        if (ordMain.getRstStartDate().compareTo(examResult.getExamEndTime()) < 0 && ordMain.getDeviceMode().equals(9)) {
          ordMainInfo = ordMain;
        }
      }
    }
    OrdMain ordMain = new OrdMain();
    ordMain.setRstWeightInfo(ordMainInfo.getRstWeightInfo());
    ordMain.setRstStartDate(ordMainInfo.getRstStartDate());
    ordMain.setRstEndDate(ordMainInfo.getRstEndDate());
    examResult.setOrdMain(ordMain);
  }

  /**
   * 指定された計算式で検査計算を行い、結果を返却する
   *
   * @param examResultParam
   * @param strFreeCalc
   */
  private Double getExamCalc(ExamResultParam examResultParam, String strFreeCalc) {
    try {
      // 計算を行うため、計算式内で指定された"取得可能情報"を計算値と置き換える
      StringBuilder sbFreeCalc = new StringBuilder();
      String[] arrFreeCalc = strFreeCalc.split("”");
      if (arrFreeCalc.length == 1) {
        // 取得可能情報がない場合はそのまま計算式を適用
        sbFreeCalc.append(arrFreeCalc[0]);
      } else {
        for (int idx = 0; idx < arrFreeCalc.length; idx++) {
          // "取得可能情報"かチェック[取得可能情報名]【[取得可能情報インデックス(1～6)],[検査項目番号],[検査タイミング]】
          if (arrFreeCalc[idx].matches(".+【.*,.*,.*,.*】")) {
            String strAddWordAll = arrFreeCalc[idx];
            String strAddWordParam = strAddWordAll.split("【")[1];
            String param_1 = strAddWordParam.split(",")[0];
            String param_2 = strAddWordParam.split(",")[1];
            String param_3 = strAddWordParam.split(",")[2];
            String param_4 = strAddWordParam.split(",")[3].replace("】", "");
            String strAddWordVal = "";
            //TODO 患者情報(計算)
            if (param_1.equals("1")) {
              //TODO 患者情報-年齢（歳）
              if (param_2.equals("1")) {
                PatPersonalMain patPersonalMainMsg = patPersonalMainDao.selectById(examResultParam.getPatId());
                String birthday = patPersonalMainMsg.getPat_birthday();
                //10140 パラメータが不足している場合は、計算せずにnullに戻ります
                if (birthday == null) {
                  return null;
                } else {
                  SimpleDateFormat format = new SimpleDateFormat("yyyyMMdd");
                  Date birth = format.parse(birthday);
                  Date target = format.parse(examResultParam.getTargetDt());
                  //10140 パラメータが不足している場合は、計算せずにnullに戻ります
                  if (birth.compareTo(target) > 0) {
                    return null;
                  } else {
                    Calendar birthCalendar = Calendar.getInstance();
                    birthCalendar.setTime(birth);
                    Calendar targetCalendar = Calendar.getInstance();
                    targetCalendar.setTime(target);
                    int birthYear = birthCalendar.get(Calendar.YEAR);
                    int birthMonth = birthCalendar.get(Calendar.MONTH);
                    int birthDay = birthCalendar.get(Calendar.DAY_OF_MONTH);

                    int targetYear = targetCalendar.get(Calendar.YEAR);
                    // mod FNSI-Fix Calculate Bug 関 start
                    int targetMonth = targetCalendar.get(Calendar.MONTH);
                    int targetDay = targetCalendar.get(Calendar.DAY_OF_MONTH);

                    int age = targetYear - birthYear - 1;
                    // mod FNSI-Fix Calculate Bug 関 end
                    if (targetMonth > birthMonth) {
                      age += 1;
                    } else if (targetMonth == birthMonth) {
                      if (targetDay >= birthDay) {
                        age += 1;
                      }
                    }
                    strAddWordVal = String.valueOf(age);
                  }
                }
              }
              //TODO 患者情報-性别
              else if (param_2.equals("2")) {
                PatPersonalMain patPersonalMainMsg = patPersonalMainDao.selectById(examResultParam.getPatId());
                Integer sex = patPersonalMainMsg.getPat_sex();
                if (sex.equals(1)) {
                  strAddWordVal = param_3;
                } else {
                  strAddWordVal = param_4;
                }
              }
              //TODO 患者情報-身長
              else if (param_2.equals("3")) {
                /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */
                // List<PatUniquePhysicalInfo> patUniquePhysicalInfo = patUniqueDao.selectPhysicalInfoOfOrderNewest(examResultParam.getPatId());
                List<PatUniquePhysicalInfo> patUniquePhysicalInfo = patUniqueDao.selectPhysicalInfoOfOrderNewest(examResultParam.getPatId(), 1);
                /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */
                BigDecimal height = null;
                //10140 パラメータが不足している場合は、計算せずにnullに戻ります
                if (patUniquePhysicalInfo.size() > 0) {
                  // mod #10147 患者情報を更新時に検査計算(更新)されない zkm start
//                  height = new BigDecimal(patUniquePhysicalInfo.get(0).getHeight());
                  height = new BigDecimal(patUniquePhysicalInfo.stream()
                    .filter(r -> StringUtils.hasText(r.getHeight()) && r.getExam_date().before(examResultParam.getTargetDtTime()))
                    .max(Comparator.comparing(PatUniquePhysicalInfo::getExam_date))
                    .orElse(patUniquePhysicalInfo.get(patUniquePhysicalInfo.size()-1)).getHeight());
                  // mod #10147 患者情報を更新時に検査計算(更新)されない zkm end
                } else {
                  // 身長が取得できない場合はnullを返却
                  return null;
                }
                //10140 パラメータが不足している場合は、計算せずにnullに戻ります
                if (height == null) {
                  return null;
                }
                //TODO 患者情報-身長(m)
                if (param_4.equals("1")) {
                  BigDecimal p = new BigDecimal("0.01");
                  strAddWordVal = height.multiply(p).toString();
                }
                //TODO 患者情報-身長(cm)
                else if (param_4.equals("2")) {
                  strAddWordVal = height.toString();
                }
              }
              //TODO 患者情報-患者メモ
              else if (param_2.equals("4")) {
                if (!param_3.equals("")) {
                  MstPatMemo patMemo = mstPatMemoDao.selectByFacilityCdAndPatMemoNo(examResultParam.getFacilityCd(), Short.parseShort(param_3));
                  //10140 パラメータが不足している場合は、計算せずにnullに戻ります
                  if (patMemo == null) {
                    return null;
                  } else {
                    if (patMemo.getContent() == null) {
                      //10140 パラメータが不足している場合は、計算せずにnullに戻ります
                      if (param_4.equals("1")) {
                        return null;
                      } else if (param_4.equals("2")) {
                        strAddWordVal = "0";
                      }
                    } else {
                      strAddWordVal = ToDBC(patMemo.getContent());
                    }
                  }
                }
              }
            }
            //TODO 実績情報(計算)
            else if (param_1.equals("3")) {
              Map<String, List<PatExamMain>> targetGroup = getExamGroupAllExamDateTime(examResultParam);
              List<PatExamMain> groupBeforeList = targetGroup.get("before");
              List<PatExamMain> groupAfterList = targetGroup.get("after");

              Timestamp examStartTime = null;
              Timestamp examEndTime = null;
              if (groupBeforeList.size() > 0) {
                examStartTime = groupBeforeList.get(0).getRegExamDate();
                if (groupAfterList.size() > 0) {
                  examEndTime = groupAfterList.get(groupAfterList.size() - 1).getRegExamDate();
                } else {
                  examEndTime = groupBeforeList.get(groupBeforeList.size() - 1).getRegExamDate();
                }
              } else {
                examStartTime = groupAfterList.get(0).getRegExamDate();
                examEndTime = groupAfterList.get(groupAfterList.size() - 1).getRegExamDate();
              }
              List<OrdMain> targetDayOrdMainList = ordMainDao.selectPatOrdMainByTreatDate(examResultParam.getPatId(), examResultParam.getFacilityCd(), examResultParam.getTargetDt());
              //同日中にのみ実際の透析予定があること
              if (targetDayOrdMainList.size() == 0) {
                return null;
              } else {
                List<OrdMain> inNomal = new ArrayList<>();
                List<OrdMain> inSpecial = new ArrayList<>();
                List<OrdMain> afterNomal = new ArrayList<>();
                List<OrdMain> afterSpecial = new ArrayList<>();
                List<OrdMain> beforeNomal = new ArrayList<>();
                List<OrdMain> beforeSpecial = new ArrayList<>();
                List<MstTreatment> treatmentList = mstTreatmentDao.selectByFacilityCd(examResultParam.getFacilityCd());
                Map<String, MstTreatment> treatmentMap = new HashMap<>();
                for (MstTreatment mstTreatment : treatmentList) {
                  treatmentMap.put(mstTreatment.getTreatmentCd().toString(), mstTreatment);
                }

                for (OrdMain ordMain : targetDayOrdMainList) {
                  if (ordMain.getRstStartDate() == null || ordMain.getIndTreatmentCd() == null) {
                    continue;
                  }
                  if (!treatmentMap.containsKey(ordMain.getIndTreatmentCd().toString())) {
                    continue;
                  }
                  if (ordMain.getRstStartDate().before(examStartTime)) { //実際の治療時間前
                    if (treatmentMap.get(ordMain.getIndTreatmentCd().toString()).getDeviceMode().equals(9)) { //9特殊净化
                      beforeSpecial.add(ordMain);
                    } else { //実際の治療時間前の正常透析
                      beforeNomal.add(ordMain);
                    }
                  } else if (ordMain.getRstStartDate().after(examEndTime)) { //実際の治療時間後
                    if (treatmentMap.get(ordMain.getIndTreatmentCd().toString()).getDeviceMode().equals(9)) { //9特殊净化
                      afterSpecial.add(ordMain);
                    } else { //実際の治療時間後の正常透析
                      afterNomal.add(ordMain);
                    }
                  } else { //実際の治療において
                    if (treatmentMap.get(ordMain.getIndTreatmentCd().toString()).getDeviceMode().equals(9)) { //9特殊净化
                      inSpecial.add(ordMain);
                    } else { //実際の治療時間における正常透析
                      inNomal.add(ordMain);
                    }
                  }
                }
                OrdMain selectOrdMain = null;
                //同じ日に、まず実際の治療時間内を取って、もしないならば、更に実際の治療時間を取った後に、もしないならば、更に実際の治療時間の前に行きます
                if (inNomal.size() > 0) {
                  selectOrdMain = inNomal.get(0);
                } else if (inSpecial.size() > 0) {
                  selectOrdMain = inSpecial.get(0);
                } else if (afterNomal.size() > 0) {
                  selectOrdMain = afterNomal.get(0);
                } else if (beforeNomal.size() > 0) {
                  selectOrdMain = beforeNomal.get(0);
                } else if (afterSpecial.size() > 0) {
                  selectOrdMain = afterSpecial.get(0);
                } else if (beforeSpecial.size() > 0) {
                  selectOrdMain = beforeSpecial.get(0);
                }
                //10140 パラメータが不足している場合は、計算せずにnullに戻ります
                if (selectOrdMain == null) {
                  return null;
                }
                //TODO 実績情報-前体重
                if (param_2.equals("1")) {
                  String weightInfo = selectOrdMain.getRstWeightInfo();
                  //10140 パラメータが不足している場合は、計算せずにnullに戻ります
                  if (!StringUtils.isEmpty(weightInfo) && !weightInfo.equals("{}")) {
                    OrdMainRstWeightInfo dto = new ObjectMapper().readValue(weightInfo, OrdMainRstWeightInfo.class);
                    strAddWordVal = dto.getWeightBefore().toPlainString();
                    //10140 パラメータが不足している場合は、計算せずにnullに戻ります
                    if (StringUtils.isEmpty(strAddWordVal)) {
                      return null;
                    }
                  } else {
                    return null;
                  }
                }
                //TODO 実績情報-後体重
                else if (param_2.equals("2")) {
                  String weightInfo = selectOrdMain.getRstWeightInfo();
                  //10140 パラメータが不足している場合は、計算せずにnullに戻ります
                  if (!StringUtils.isEmpty(weightInfo) && !weightInfo.equals("{}")) {
                    OrdMainRstWeightInfo dto = new ObjectMapper().readValue(weightInfo, OrdMainRstWeightInfo.class);
                    strAddWordVal = dto.getWeightAfter().toPlainString();
                    //10140 パラメータが不足している場合は、計算せずにnullに戻ります
                    if (StringUtils.isEmpty(strAddWordVal)) {
                      return null;
                    }
                  } else {
                    return null;
                  }
                }
                //TODO 実績情報-透析時間（H）
                else if (param_2.equals("3")) {
                  //10140 パラメータが不足している場合は、計算せずにnullに戻ります
                  if (selectOrdMain.getRstEndDate() != null && selectOrdMain.getRstStartDate() != null) {
                    BigDecimal treatTime = BigDecimal.valueOf(((double) (selectOrdMain.getRstEndDate().getTime() - selectOrdMain.getRstStartDate().getTime())) / (60 * 60 * 1000));
                    strAddWordVal = treatTime.toPlainString();
                  } else {
                    return null;
                  }
                }
                //TODO 実績情報-前回からの体重増加量（Kg）
                else if (param_2.equals("4")) {
                  //mod 9480 実績情報-前回からの体重増加量（Kg）修正 gjn start
                  OrdMain previousOrdMain = null;
                  /**
                   * 今回の実際の治療を参照して、前回の実際の治療データを取り出し、
                   * 前回同日内に複数の実治療を行った場合、実透析を優先し、特殊血液浄化を副次的とし、複数の実透析治療または複数の特殊血液浄化を行った場合に最も時間がかかったもの
                   */
                  String nowTreatDate = selectOrdMain.getTreatDate();
                  List<OrdMain> lastOrdMainList = ordMainDao.selectPatOrdMainLastTreatDate(examResultParam.getPatId(), examResultParam.getFacilityCd(), nowTreatDate);
                  //前回治療の治療日を取得する
//                  String lastTreatDate = lastOrdMainList.get(0).getTreatDate();
                  //10140 パラメータが不足している場合は、計算せずにnullに戻ります
                  if (lastOrdMainList.size() > 0) {
                    for (OrdMain ordMain : lastOrdMainList) {
                      //前回治療の治療日以内に、特殊血液浄化治療データであるかどうかを判断する
//                      if (lastTreatDate.equals(ordMain.getTreatDate())) { //同一日付または前日付の同一日付判定
                      MstTreatment mstTreatment = mstTreatmentDao.selectIndByOrdNo(ordMain.getOrdNo());
                      if (!mstTreatment.getDeviceMode().equals(9)) { //特殊な血液浄化ではありません
//                            String weightInfo = ordMain.getRstWeightInfo();
//                            ObjectMapper mapper = new ObjectMapper();
//                            // 親ノード
//                            JsonNode jsonNode = mapper.readTree(weightInfo);
//                            if (jsonNode.has("weight_after") && jsonNode.get("weight_after").asDouble() > 0.0) {
                        previousOrdMain = ordMain;
//                            } else {
                        //正常血液透析の後体重が0未満またはnullの場合は、直接計算しない
                        break;
//                            }
                      }
//                      } else {
//                        if (previousOrdMain != null) {
//                          break;
//                        }
//                        //lastTreatDate治療日をリセットする（日付が変わったため）
//                        lastTreatDate = ordMain.getTreatDate();
//                        continue;
//                      }
                    }
                    //10140 パラメータが不足している場合は、計算せずにnullに戻ります
                    if (previousOrdMain == null) {
                      //前回後の体重が空の場合は計算せずにnullに戻る
                      return null;
                    }
                  } else {
                    return null;
                  }
                  //TODO 今回の前体重と前体重を取り出す
                  String weightInfo = selectOrdMain.getRstWeightInfo();
                  String previousWeightInfo = previousOrdMain.getRstWeightInfo();
                  if (!StringUtils.isEmpty(weightInfo) && !weightInfo.equals("{}") && !StringUtils.isEmpty(previousWeightInfo) && !previousWeightInfo.equals("{}")) {
                    //今回の前体重
                    OrdMainRstWeightInfo dto = new ObjectMapper().readValue(weightInfo, OrdMainRstWeightInfo.class);
                    //前回の後体重
                    OrdMainRstWeightInfo previousDto = new ObjectMapper().readValue(previousWeightInfo, OrdMainRstWeightInfo.class);
                    //今回の前体重または前回の後体重のいずれかのパラメータがnullであると判定した場合、計算結果は空である
                    if (dto.getWeightBefore() == null || previousDto.getWeightAfter() == null) {
                      strAddWordVal = "";
                    } else {
                      //計算後の前回からの体重増加量（Kg）
                      strAddWordVal = dto.getWeightBefore().add(previousDto.getWeightAfter().divide(BigDecimal.valueOf(-1))).toPlainString();
                    }
                  }
                  //mod 9480 実績情報-前回からの体重増加量（Kg）修正 gjn end
                }
                //TODO 実績情報-体重減少量（Kg）
                else if (param_2.equals("5")) {
                  String weightInfo = selectOrdMain.getRstWeightInfo();
                  //10140 パラメータが不足している場合は、計算せずにnullに戻ります
                  if (!StringUtils.isEmpty(weightInfo) && !weightInfo.equals("{}")) {
                    OrdMainRstWeightInfo dto = new ObjectMapper().readValue(weightInfo, OrdMainRstWeightInfo.class);
                    //10140 パラメータが不足している場合は、計算せずにnullに戻ります
                    if (dto.getWeightDecreased() == null) {
                      return null;
                    }
                    strAddWordVal = dto.getWeightDecreased().toPlainString();
                    //10140 パラメータが不足している場合は、計算せずにnullに戻ります
                    if (StringUtils.isEmpty(strAddWordVal)) {
                      return null;
                    }
                  } else {
                    return null;
                  }
                }
                //TODO 実績情報-今回除水量（L）
                else if (param_2.equals("6")) {
                  String weightInfo = selectOrdMain.getRstWeightInfo();
                  //10140 パラメータが不足している場合は、計算せずにnullに戻ります
                  if (!StringUtils.isEmpty(weightInfo) && !weightInfo.equals("{}")) {
                    OrdMainRstWeightInfo dto = new ObjectMapper().readValue(weightInfo, OrdMainRstWeightInfo.class);
                    //10140 パラメータが不足している場合は、計算せずにnullに戻ります
                    if (dto.getWaterRemovalRst() == null) {
                      return null;
                    }
                    strAddWordVal = dto.getWaterRemovalRst().toPlainString();
                    //10140 パラメータが不足している場合は、計算せずにnullに戻ります
                    if (StringUtils.isEmpty(strAddWordVal)) {
                      return null;
                    }
                  } else {
                    return null;
                  }
                }
                //TODO 実績情報-次回透析までの時間（H）
                else if (param_2.equals("7")) {
                  List<OrdMain> futureDayOrdMainList = ordMainDao.selectPatOrdMainAfterTreatDate(examResultParam.getPatId(), examResultParam.getFacilityCd(), examResultParam.getTargetDt());
                  //10140 パラメータが不足している場合は、計算せずにnullに戻ります
                  if (futureDayOrdMainList.size() == 0) {
                    return null;
                  } else {
                    //mod 9480 次回透析までの時間（H）计算修正 gjn start
                    OrdMain futureOrdMain = futureDayOrdMainList.get(0);
                    String indTreatStartTime = futureOrdMain.getIndTreatStartTime();
                    indTreatStartTime = indTreatStartTime.substring(0, 2) + ":" + indTreatStartTime.substring(2);
                    String indTime = futureOrdMain.getTreatDate() + " " + indTreatStartTime + ":00";
                    //mod 9480 次回透析までの時間（H）计算修正 gjn end
                    SimpleDateFormat format = new SimpleDateFormat("yyyyMMdd HHmmss");
                    Date indDate = format.parse(indTime);
                    Timestamp indTimestamp = new Timestamp(indDate.getTime());
                    if (selectOrdMain.getRstEndDate() == null) {
                      return null;
                    }
                    BigDecimal treatTime = BigDecimal.valueOf(((double) (indTimestamp.getTime() - selectOrdMain.getRstEndDate().getTime()) / (60 * 60 * 1000)));
                    strAddWordVal = treatTime.toPlainString();
                  }
                }
                //TODO 実績情報-週あたり透析回数（回）
                else if (param_2.equals("8")) {
                  //mod 9480 過去1週間の透析回数計算の修正 gjn strat
                  Date today = new SimpleDateFormat("yyyyMMdd").parse(examResultParam.getTargetDt());
                  Date targetMonday = DateUtil.getThisWeekMonday(today);
                  Calendar calendar = new GregorianCalendar();
                  calendar.setTime(targetMonday);
                  calendar.add(Calendar.DATE, -7);
                  Date lastMonday = calendar.getTime();
                  String endFormat = new SimpleDateFormat("yyyyMMdd").format(targetMonday);
                  String startFormat = new SimpleDateFormat("yyyyMMdd").format(lastMonday);
                  List<OrdMain> weekOrdMain = ordMainDao.selectPatOrdMainBetweenDate(examResultParam.getPatId(), examResultParam.getFacilityCd(), startFormat, endFormat);
                  //10140 パラメータが不足している場合は、計算せずにnullに戻ります
                  if (weekOrdMain.size() == 0) {
                    return null;
                  } else {
                    int diaNum = 0;
                    for (OrdMain ordMain : weekOrdMain) {
                      if (ordMain.getRstDialysisCnt() != null) {
                        diaNum += ordMain.getRstDialysisCnt();
                      }
                    }
                    strAddWordVal = String.valueOf(diaNum);
                  }
                  //mod 9480 過去1週間の透析回数計算の修正 gjn end
                }
                //TODO 実績情報-前血圧=9,後血圧=10
                else if (param_2.equals("9") || param_2.equals("10")) {
                  //mod 9480 前血圧,後血圧计算修正 gjn start
                  List<MniMonitor> monitorDate = mniMonitorDao.selectByOrdNo(selectOrdMain.getOrdNo());
                  /**
                   * MniMonitor中非5：透析前血圧、6：透析後血圧のデータを濾過する
                   */
                  List<MniMonitor> monitorDateBefor = monitorDate.stream().filter(f -> (f.getDataType()==5)).distinct().collect(Collectors.toList());
                  List<MniMonitor> monitorDateAfter = monitorDate.stream().filter(f -> (f.getDataType()==6)).distinct().collect(Collectors.toList());
                  //10140 パラメータが不足している場合は、計算せずにnullに戻ります
                  if (monitorDateBefor.size() == 0 && monitorDateAfter.size() == 0) {
                    return null;
                  } else {
                    Double frontMax = 0.0;
                    Double frontMin = 0.0;
                    Double frontAvg = 0.0;
                    Double backendMax = 0.0;
                    Double backendMin = 0.0;
                    Double backendAvg = 0.0;
                    //TODO 前血圧
                    if (param_2.equals("9")) {
                      //前血圧中の最高血圧値、最低血圧値、平均血圧値を取る
                      for (MniMonitor everyMonitor : monitorDateBefor) {
                        String monitorMsg = everyMonitor.getMonitorData();
                        ObjectMapper mapper = new ObjectMapper();
                        // 親ノード
                        JsonNode jsonNode = mapper.readTree(monitorMsg);
                        //最高血圧
                        if (jsonNode.has("90")) {
                          JsonNode jsonNode1 = jsonNode.get("90");
                          frontMax = jsonNode1.asDouble();
                        }
                        //最高血圧
                        if (jsonNode.has("91")) {
                          JsonNode jsonNode2 = jsonNode.get("91");
                          frontMin = jsonNode2.asDouble();
                        }
                        //平均血圧
                        if (jsonNode.has("92")) {
                          JsonNode jsonNode3 = jsonNode.get("92");
                          frontAvg = jsonNode3.asDouble();
                        }
                      }
                      switch (param_4) {
                        case "1":
                          strAddWordVal = String.valueOf(frontMax);
                          break;
                        case "2":
                          strAddWordVal = String.valueOf(frontMin);
                          break;
                        case "3":
                          strAddWordVal = String.valueOf(frontAvg);
                          break;
                      }
                      //TODO 後血圧
                    } else if (param_2.equals("10")) {
                      //取後血圧中の最高血圧値、最低血圧値、平均血圧値
                      for (MniMonitor everyMonitor : monitorDateAfter) {
                        String monitorMsg = everyMonitor.getMonitorData();
                        ObjectMapper mapper = new ObjectMapper();
                        // 親ノード
                        JsonNode jsonNode = mapper.readTree(monitorMsg);
                        //最高血圧
                        if (jsonNode.has("90")) {
                          JsonNode jsonNode4 = jsonNode.get("90");
                          backendMax = jsonNode4.asDouble();
                        }
                        //最高血圧
                        if (jsonNode.has("91")) {
                          JsonNode jsonNode5 = jsonNode.get("91");
                          backendMin = jsonNode5.asDouble();
                        }
                        //平均血圧
                        if (jsonNode.has("92")) {
                          JsonNode jsonNode6 = jsonNode.get("92");
                          backendAvg = jsonNode6.asDouble();
                        }
                      }
                      switch (param_4) {
                        case "1":
                          strAddWordVal = String.valueOf(backendMax);
                          break;
                        case "2":
                          strAddWordVal = String.valueOf(backendMin);
                          break;
                        case "3":
                          strAddWordVal = String.valueOf(backendAvg);
                          break;
                      }
                    } else {
                      return null;
                    }
                  }
                  //mod 9480 前血圧,後血圧计算修正 gjn end
                }
                //TODO 実績情報-補液積算値
                else if (param_2.equals("11")) {
                  String weightInfo = selectOrdMain.getRstWeightInfo();
                  //10140 パラメータが不足している場合は、計算せずにnullに戻ります
                  if (!StringUtils.isEmpty(weightInfo) && !weightInfo.equals("{}")) {
                    OrdMainRstWeightInfo dto = new ObjectMapper().readValue(weightInfo, OrdMainRstWeightInfo.class);
                    //10140 パラメータが不足している場合は、計算せずにnullに戻ります
                    if (dto.getAddWaterTotal() == null) {
                      return null;
                    }
                    strAddWordVal = dto.getAddWaterTotal().toPlainString();
                    //10140 パラメータが不足している場合は、計算せずにnullに戻ります
                    if (StringUtils.isEmpty(strAddWordVal)) {
                      return null;
                    }
                  } else {
                    return null;
                  }
                }
              }
            }
            //TODO 検査結果(計算)
            else if (param_1.equals("4")) {
              List<PatExamMain> selectExamGroup = null;
              Timestamp examDateFrom;
              Timestamp examDateTo;
              List<PatExamMain> lstExamMain;
              List<List<PatExamMain>> examMainGroup;
              //TODO 検査結果-今回検査値
              switch (param_2) {
                case "1":
                  Map<String, List<PatExamMain>> targetGroup = getExamGroupAllExamDateTime(examResultParam);
                  selectExamGroup = new ArrayList<>(targetGroup.get("before"));
                  selectExamGroup.addAll(targetGroup.get("after"));
                  break;
                //TODO 検査結果-前回検査値,前々回検査値
                case "2":
                case "4":
                  List<FacilitySettingInfo> searchDaySetting = mstFacilitySettingDao.selectFacilitySetting(examResultParam.getFacilityCd(), "3012");
                  long searchDay = 30;
                  if (searchDaySetting.size() > 0) {
                    searchDay = Integer.parseInt(searchDaySetting.get(0).getValue());
                  }
                  //upd 8287 検査計算項目が計算されない 修正 ztc 20230623 strat
//                  examDateTo = new Timestamp(new SimpleDateFormat("yyyyMMdd HHmmss").parse(examResultParam.getTargetDt() + " 000000").getTime());
//                  examDateFrom = new Timestamp(new SimpleDateFormat("yyyyMMdd HHmmss").parse(examResultParam.getTargetDt() + " 000000").getTime() - (86400000L * searchDay));
                  examDateTo = examResultParam.getTargetDtTime();
                  examDateFrom = new Timestamp(examResultParam.getTargetDtTime().getTime() - (86400000L * searchDay));
                  lstExamMain = patExamMainDao.selectPatExamMainByPatIdExamEquRangeDate(examResultParam.getPatId(), examDateFrom, examDateTo);
                  //upd 8287 検査計算項目が計算されない 修正 ztc 20230623 end
                  //10140 パラメータが不足している場合は、計算せずにnullに戻ります
                  if (lstExamMain.size() == 0) {
                    return null;
                  }
                  examMainGroup = makeExamMainGroup(lstExamMain);
                  //10140 パラメータが不足している場合は、計算せずにnullに戻ります
                  if (examMainGroup.size() == 0) {
                    return null;
                  }
                  if (param_2.equals("2")) {
                    //upd 8287 検査計算項目が計算されない 修正 ztc 20230623 strat
                    selectExamGroup = examMainGroup.get(examMainGroup.size() - 2);
                    //upd 8287 検査計算項目が計算されない 修正 ztc 20230623 end
                  } else {
                    if (examMainGroup.size() >= 2) {
                      //upd 8287 検査計算項目が計算されない 修正 ztc 20230623 strat
                      selectExamGroup = examMainGroup.get(examMainGroup.size() - 3);
                      //upd 8287 検査計算項目が計算されない 修正 ztc 20230623 end
                    }
                  }
                  break;
                //TODO 検査結果-次回検査値
                case "3":
                  examDateFrom = new Timestamp(new SimpleDateFormat("yyyyMMdd HHmmss").parse(examResultParam.getTargetDt() + " 000000").getTime() + 86400000);
                  examDateTo = new Timestamp(System.currentTimeMillis());
                  lstExamMain = patExamMainDao.selectPatExamMainByPatIdExamdate(examResultParam.getPatId(), examDateFrom, examDateTo);
                  //10140 パラメータが不足している場合は、計算せずにnullに戻ります
                  if (lstExamMain.size() == 0) {
                    return null;
                  }
                  examMainGroup = makeExamMainGroup(lstExamMain);
                  //10140 パラメータが不足している場合は、計算せずにnullに戻ります
                  if (examMainGroup.size() == 0) {
                    return null;
                  }
                  selectExamGroup = examMainGroup.get(0);
                  break;
              }
              //10140 パラメータが不足している場合は、計算せずにnullに戻ります
              if (selectExamGroup == null) {
                return null;
              }
              // check exam result from group results
              String selectItemCd = param_3;
              MstExamItem selectItem = mstExamItemDao.selectByExamItemCd(Long.parseLong(selectItemCd));
              //10140 パラメータが不足している場合は、計算せずにnullに戻ります
              if (selectItem == null) {
                return null;
              }
              //検査結果計算ロジック修正  Du start
//              if (selectItem.getDialysisProgressFlag() != null && !selectItem.getDialysisProgressFlag().equals("3")) {
//                if (!selectItem.getDialysisProgressFlag().equals(param_4)) {
//                    return null;
//                }
//              }
              //検査結果計算ロジック修正  Du end
              List<PatExamMain> beforeExam = new ArrayList<>();
              List<PatExamMain> afterExam = new ArrayList<>();
              List<PatExamMain> otherExam = new ArrayList<>();
              //mod 9734 再計算結果がペアリング対象外区分にも登録されている guan start
              //selectExamGroup.forEach(everyExam -> {
              for (PatExamMain everyExam : selectExamGroup) {
                if (everyExam.getRegOrderClass().equals(ExamResultCalcConstant.OrderClass.BEFORE_DIALYSIS)) {
                  beforeExam.add(everyExam);
                } else if (everyExam.getRegOrderClass().equals(ExamResultCalcConstant.OrderClass.AFTER_DIALYSIS)) {
                  afterExam.add(everyExam);
                } else if (everyExam.getRegOrderClass().equals(ExamResultCalcConstant.OrderClass.OTHER_DIALYSIS)) {
                  //その他の論理処理の追加
                  List<MstExamItem> mstExamItems = examResultParam.getMstExamItems();
                  for (MstExamItem mstExamItem : mstExamItems) {
                    Long examItemCd = mstExamItem.getExamItemCd();
                    try {
                      List<PatExamMainExamResultInfo> examResultInfo = everyExam.getExamResultInfo() == null || everyExam.getExamResultInfo().isEmpty() ? new ArrayList<>()
                        : new ObjectMapper().readValue(everyExam.getExamResultInfo(), new TypeReference<List<PatExamMainExamResultInfo>>() {
                      });
                      examResultInfo = examResultInfo.stream().filter(f -> (ExamClass.EXAM_ITEM.equals(f.getExam_class()))).distinct().collect(Collectors.toList());
                      for (PatExamMainExamResultInfo patExamMainExamResultInfo : examResultInfo) {
                        if (String.valueOf(examItemCd).equals(patExamMainExamResultInfo.getItem_cd()) && !StringUtils.isEmpty(patExamMainExamResultInfo.getResult())) {
                          //TODO この検査項目の値が存在します
                          if (ExamResultCalcConstant.DialysisProgressFlag.BEFORE.equals(mstExamItem.getDialysisProgressFlag())) {
                            beforeExam.add(everyExam);
                          }
                          if (ExamResultCalcConstant.DialysisProgressFlag.AFTER.equals(mstExamItem.getDialysisProgressFlag())) {
                            afterExam.add(everyExam);
                          }
                          //TODO DialysisProgressFlag=3の考慮なし
                        }
                      }
                    } catch (Exception e) {
                      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
                      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
                      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
                      EventLogMessage eventLogMessage = new EventLogMessage();
                      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
                      if (examResultParam != null && !StringUtils.isEmpty(examResultParam.getFacilityCd())) {
                        eventLogMessage.setFacilityCd(examResultParam.getFacilityCd());
                      }
                      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
                      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
                    }
                  }
                }
                //  });
              }
              //mod 9734 再計算結果がペアリング対象外区分にも登録されている guan end
              PatExamMain selectExam = null;
              switch (param_4) {
                case "1":
                  if (beforeExam.size() == 0) {
                    //10140 パラメータが不足している場合は、計算せずにnullに戻ります
                    if (selectItem.getDialysisProgressFlag() == null || selectItem.getDialysisProgressFlag().equals(ExamResultCalcConstant.DialysisProgressFlag.ALL)) {
                      return null;
                    } else {
                      //selectExam = afterExam.get(afterExam.size() - 1);
                      //afterExam排序（按照时间降序）
                      afterExam = afterExam.stream().sorted(Comparator.comparing(PatExamMain::getRegExamDate).reversed()).collect(Collectors.toList());
                      for (int i=0;i<afterExam.size();i++) {
                        if (this.getValuePatExamItem(afterExam.get(i), selectItem)) {
                          selectExam = afterExam.get(i);
                          break;
                        }
                      }
                    }
                  } else {
                    //selectExam = beforeExam.get(beforeExam.size() - 1);
                    //beforeExam排序（按照时间降序）
                    beforeExam = beforeExam.stream().sorted(Comparator.comparing(PatExamMain::getRegExamDate).reversed()).collect(Collectors.toList());
                    for (int i=0;i<beforeExam.size();i++) {
                      if (this.getValuePatExamItem(beforeExam.get(i), selectItem)) {
                        selectExam = beforeExam.get(i);
                        break;
                      }
                    }
                  }
                  break;
                case "2":
                  if (afterExam.size() == 0) {
                    //10140 パラメータが不足している場合は、計算せずにnullに戻ります
                    if (selectItem.getDialysisProgressFlag() == null || selectItem.getDialysisProgressFlag().equals(ExamResultCalcConstant.DialysisProgressFlag.ALL)) {
                      return null;
                    } else {
                      //selectExam = beforeExam.get(beforeExam.size() - 1);
                      //beforeExam排序（按照时间降序）
                      beforeExam = beforeExam.stream().sorted(Comparator.comparing(PatExamMain::getRegExamDate).reversed()).collect(Collectors.toList());
                      for (int i=0;i<beforeExam.size();i++) {
                        if (this.getValuePatExamItem(beforeExam.get(i), selectItem)) {
                          selectExam = beforeExam.get(i);
                          break;
                        }
                      }
                    }
                  } else {
                    //selectExam = afterExam.get(afterExam.size() - 1);
                    //afterExam排序（按照时间降序）
                    afterExam = afterExam.stream().sorted(Comparator.comparing(PatExamMain::getRegExamDate).reversed()).collect(Collectors.toList());
                    for (int i=0;i<afterExam.size();i++) {
                      if (this.getValuePatExamItem(afterExam.get(i), selectItem)) {
                        selectExam = afterExam.get(i);
                        break;
                      }
                    }
                  }
                  break;
                case "0":
                  //10140 パラメータが不足している場合は、計算せずにnullに戻ります
                  if (beforeExam.size() == 0) {
                    return null;
                  } else {
//                    beforeExam.forEach(everyExam -> {
//                      if (everyExam.getRegOrderClass().equals(ExamResultCalcConstant.OrderClass.OTHER_DIALYSIS)) {
//                        otherExam.add(everyExam);
//                      }
//                    });
                    for (PatExamMain everyExam : beforeExam) {
                      if (everyExam.getRegOrderClass().equals(ExamResultCalcConstant.OrderClass.OTHER_DIALYSIS)) {
                        otherExam.add(everyExam);
                      }
                    }
                    //10140 パラメータが不足している場合は、計算せずにnullに戻ります
                    if (otherExam.size() == 0) {
                      return null;
                    } else {
                      //selectExam = otherExam.get(otherExam.size() - 1);
                      //otherExam排序（按照时间降序）
                      otherExam = otherExam.stream().sorted(Comparator.comparing(PatExamMain::getRegExamDate).reversed()).collect(Collectors.toList());
                      for (int i=0;i<otherExam.size();i++) {
                        if (this.getValuePatExamItem(otherExam.get(i), selectItem)) {
                          selectExam = otherExam.get(i);
                          break;
                        }
                      }
                    }
                  }
                  break;
              }
              //10140 パラメータが不足している場合は、計算せずにnullに戻ります
              if (selectExam == null) {
                return null;
              }
              List<PatExamMainExamResultInfo> examResultInfo = new ArrayList<>();
              examResultInfo = selectExam.getExamResultInfo() == null || selectExam.getExamResultInfo().isEmpty() ? new ArrayList<>()
                : new ObjectMapper().readValue(selectExam.getExamResultInfo(), new TypeReference<List<PatExamMainExamResultInfo>>() {
              });
              for (PatExamMainExamResultInfo patExamMainExamResultInfo : examResultInfo) {
                if (patExamMainExamResultInfo.getItem_cd().equals(selectItem.getExamItemCd().toString())) {
                  strAddWordVal = ToDBC(patExamMainExamResultInfo.getResult());
                }
              }
            }
            //関数,除去率,透析前BUN
            else if (param_1.equals("5")) {
              //
              if (param_2.equals(ExamResultCalcConstant.OrderClass.BEFORE_DIALYSIS)) {
                examResultParam.setExamItemCd(param_3);
                examResultParam.setOrderClass(ExamResultCalcConstant.OrderClass.BEFORE_DIALYSIS);
                String befVal = getExamResultByExamItemCd(examResultParam);
                examResultParam.setOrderClass(ExamResultCalcConstant.OrderClass.AFTER_DIALYSIS);
                String aftVal = getExamResultByExamItemCd(examResultParam);
                //mod 透析前後の判断の最適化 関 end
                //10140 パラメータが不足している場合は、計算せずにnullに戻ります
                if (StringUtils.isEmpty(befVal) || StringUtils.isEmpty(aftVal)) {
                  // 指定した検査項目値が取得できない場合はnullを返却
                  return null;
                }
                strAddWordVal = "(" + befVal + "-" + aftVal + ") * 100 / " + befVal;
              } else if (param_2.equals(ExamResultCalcConstant.OrderClass.AFTER_DIALYSIS)) {
                examResultParam.setExamItemCd(param_3);
                examResultParam.setOrderClass(ExamResultCalcConstant.OrderClass.BEFORE_DIALYSIS);
                String befVal2 = getExamResultByExamItemCd(examResultParam);
                examResultParam.setOrderClass(ExamResultCalcConstant.OrderClass.AFTER_DIALYSIS);
                String aftVal2 = getExamResultByExamItemCd(examResultParam);
                //mod 9737 関数横展開テストの変更点 gjn start
                //examResultParam.setExamItemCd(ExamResultCalcConstant.ExamResultCalcColumns.HEMATOCRIT);
                examResultParam.setExamResultCalcColumnVal(ExamResultCalcConstant.ExamResultCalcColumns.HEMATOCRIT);
                //mod 9737 関数横展開テストの変更点 gjn end
                examResultParam.setOrderClass(ExamResultCalcConstant.OrderClass.BEFORE_DIALYSIS);
                ExamResult examResult = this.getExamResult(examResultParam);
                examResult = this.setResult(examResultParam, examResult);
                String befValHem = examResult.getValHemBefore();
                examResultParam.setOrderClass(ExamResultCalcConstant.OrderClass.AFTER_DIALYSIS);
                examResult = this.getExamResult(examResultParam);
                examResult = this.setResult(examResultParam, examResult);
                String aftValHem = examResult.getValHemAfter();
                //mod 透析前後の判断の最適化 関 end
                //10140 パラメータが不足している場合は、計算せずにnullに戻ります
                if (StringUtils.isEmpty(befVal2) || StringUtils.isEmpty(aftVal2) || StringUtils.isEmpty(befValHem) || StringUtils.isEmpty(aftValHem)) {
                  // 指定した検査項目値が取得できない場合はnullを返却
                  return null;
                }
                strAddWordVal = "(1-(" + befValHem + "*(1-" + aftValHem + "/100)*" + aftVal2 + ")/(" + aftValHem + "*(1-" + befValHem + "/100)*" + befVal2 + "))*100";
              }
            }
            sbFreeCalc.append(strAddWordVal);
          } else {
            sbFreeCalc.append(arrFreeCalc[idx]);
          }
          // mod FNSI-No196 透析前後の判断の最適化 関 end
        }
      }
      //mod 10140 計算エラー,NaNで更新 gjn start
      double result;
      try {
        BigDecimal ret = new Parser(sbFreeCalc.toString()).exprs();
        result = ret.doubleValue();
      } catch (Exception exception) {
        // 計算中に例外が発生,NaN
        return Double.NaN;
      }
      return result;
    } catch (Exception e) {
      //計算外例外代入null
      return null;
    }
    //mod 10140 計算エラー,NaNで更新 gjn end
  }


  /**
   * カスタム計算式の値を取得するときは、デフォルトでは同じ検査区分の最後の値が選択され、最後の値がNULLの場合は、前に同じ検査結果区分の値が選択されます
   *
   * @param selectExam
   * @param selectItem
   * @return
   * @throws JsonProcessingException
   */
  private boolean getValuePatExamItem (PatExamMain selectExam, MstExamItem selectItem) throws JsonProcessingException {
    String strAddWordVal = "";
    List<PatExamMainExamResultInfo> examResultInfo = new ArrayList<>();
    examResultInfo = selectExam.getExamResultInfo() == null || selectExam.getExamResultInfo().isEmpty() ? new ArrayList<>()
      : new ObjectMapper().readValue(selectExam.getExamResultInfo(), new TypeReference<List<PatExamMainExamResultInfo>>() {
    });
    for (PatExamMainExamResultInfo patExamMainExamResultInfo : examResultInfo) {
      if (patExamMainExamResultInfo.getItem_cd().equals(selectItem.getExamItemCd().toString())) {
        strAddWordVal = ToDBC(patExamMainExamResultInfo.getResult());
      }
    }
    if (!StringUtils.isEmpty(strAddWordVal)) {
      return true;
    }
    return false;
  }


  /**
   * 指定患者・日付・タイミングの検査値を取得する
   *
   * @param examResultParam
   * @return
   */
  private String getExamResultByExamItemCd(ExamResultParam examResultParam) {
    String strVal = "";
    try {
      List<PatExamMain> selectExamGroup = null;
      Timestamp examDateFrom;
      Timestamp examDateTo;
      List<PatExamMain> lstExamMain;
      List<List<PatExamMain>> examMainGroup;
      Map<String, List<PatExamMain>> targetGroup = getExamGroupAllExam(examResultParam);
      selectExamGroup = new ArrayList<>(targetGroup.get("before"));
      selectExamGroup.addAll(targetGroup.get("after"));
      MstExamItem selectItem = mstExamItemDao.selectByExamItemCd(Long.parseLong(examResultParam.getExamItemCd()));
      if (selectItem == null) {
        return null;
      }
      if (selectItem.getDialysisProgressFlag() != null && !selectItem.getDialysisProgressFlag().equals(ExamResultCalcConstant.DialysisProgressFlag.ALL)) {
        if (!selectItem.getDialysisProgressFlag().equals(examResultParam.getOrderClass())) {
          return null;
        }
      }
      List<PatExamMain> beforeExam = new ArrayList<>();
      List<PatExamMain> afterExam = new ArrayList<>();
      List<PatExamMain> otherExam = new ArrayList<>();
      //mod 9737 関数横展開テストの変更点 gjn start
      selectExamGroup.forEach(everyExam -> {
        if (everyExam.getRegOrderClass().equals(ExamResultCalcConstant.OrderClass.BEFORE_DIALYSIS)) {
          //|| everyExam.getRegOrderClass().equals(ExamResultCalcConstant.OrderClass.OTHER_DIALYSIS)) {
          beforeExam.add(everyExam);
        } else if (everyExam.getRegOrderClass().equals(ExamResultCalcConstant.OrderClass.AFTER_DIALYSIS)) {
          afterExam.add(everyExam);
        } else {
          //TODO 検査結果区分がその他であることを確定する場合、その他が透析前か透析後かを選別する
          if (ExamResultCalcConstant.DialysisProgressFlag.BEFORE.equals(selectItem.getDialysisProgressFlag())) { //透析前
            beforeExam.add(everyExam);
          }
          if (ExamResultCalcConstant.DialysisProgressFlag.AFTER.equals(selectItem.getDialysisProgressFlag())) {
            afterExam.add(everyExam);
          }
          //TODO DialysisProgressFlag=3の場合は計算に参加しないので、何もしません
        }
      });
      //mod 9737 関数横展開テストの変更点 gjn end
      PatExamMain selectExam = null;
      switch (examResultParam.getOrderClass()) {
        case "1":
          if (beforeExam.size() == 0) {
            if (selectItem.getDialysisProgressFlag() == null || selectItem.getDialysisProgressFlag().equals(ExamResultCalcConstant.DialysisProgressFlag.ALL)) {
              return null;
            } else {
              selectExam = afterExam.get(afterExam.size() - 1);
            }
          } else {
            selectExam = beforeExam.get(beforeExam.size() - 1);
          }
          break;
        case "2":
          if (afterExam.size() == 0) {
            if (selectItem.getDialysisProgressFlag() == null || selectItem.getDialysisProgressFlag().equals(ExamResultCalcConstant.DialysisProgressFlag.ALL)) {
              return null;
            } else {
              selectExam = beforeExam.get(beforeExam.size() - 1);
            }
          } else {
            selectExam = afterExam.get(afterExam.size() - 1);
          }
          break;
        case "0":
          if (beforeExam.size() == 0) {
            return null;
          } else {
            beforeExam.forEach(everyExam -> {
              if (everyExam.getRegOrderClass().equals(ExamResultCalcConstant.OrderClass.OTHER_DIALYSIS)) {
                otherExam.add(everyExam);
              }
            });
            if (otherExam.size() == 0) {
              return null;
            } else {
              selectExam = otherExam.get(otherExam.size() - 1);
            }
          }
          break;
      }
      if (selectExam == null) {
        return null;
      }

      List<PatExamMainExamResultInfo> examResultInfo = new ArrayList<>();
      examResultInfo = selectExam.getExamResultInfo() == null || selectExam.getExamResultInfo().isEmpty() ? new ArrayList<>()
        : new ObjectMapper().readValue(selectExam.getExamResultInfo(), new TypeReference<List<PatExamMainExamResultInfo>>() {
      });
      for (PatExamMainExamResultInfo patExamMainExamResultInfo : examResultInfo) {
        if (patExamMainExamResultInfo.getItem_cd().equals(selectItem.getExamItemCd().toString())) {
          strVal = patExamMainExamResultInfo.getResult();
        }
      }
      return strVal;
    } catch (Exception e) {
      return "";
    }
  }

  // 検査計算の計算式解析基底クラス
  private class Source {
    private final String str;
    private int pos;

    public Source(String str) {
      this.str = str;
    }

    public final int peek() {
      if (pos < str.length()) {
        return str.charAt(pos);
      }
      return -1;
    }

    public final void next() {
      ++pos;
    }
  }

  // 検査計算の計算式解析
  class Parser extends Source {
    public Parser(String str) {
      super(str);
    }

    private final double number() {
      StringBuilder sb = new StringBuilder();
      int ch;
      while ((ch = peek()) >= 0 && (Character.isDigit(ch) || ch == '.' || ch == '．')) {
        sb.append((char) ch);
        next();
      }
      return Double.parseDouble(sb.toString());
    }

    // expr = term, {("+", term) | ("-", term)}
    public final double expr() {
      double x = term();
      for (; ; ) {
        switch (peek()) {
          case '+':
            next();
            x += term();
            continue;
          case '-':
            next();
            x -= term();
            continue;
        }
        break;
      }
      return x;
    }

    // add BigDecimal Calculate fix 関 start
    public final BigDecimal exprs() {
      BigDecimal x = terms();
      for (; ; ) {
        switch (peek()) {
          case '+':
            next();
            x = x.add(terms());
            continue;
          case '-':
            next();
            x = x.subtract(terms());
            continue;
        }
        break;
      }
      return x;
    }

    private final BigDecimal terms() {
      BigDecimal x = factorSmalls();
      for (; ; ) {
        switch (peek()) {
          case '*':
            next();
            x = x.multiply(factorSmalls());
            continue;
          case '/':
            next();
            x = x.divide(factorSmalls(), 20, RoundingMode.HALF_UP);
            continue;
        }
        break;
      }
      return x;
    }

    private final BigDecimal factorSmalls() {
      BigDecimal ret;
      spaces();
      if (peek() == '(') {
        next();
        ret = exprs();
        if (peek() == ')') {
          next();
        }
      } else {
        ret = BigDecimal.valueOf(number());
      }
      spaces();
      return ret;
    }

    // add BigDecimal Calculate fix 関 end
    // term = factorSmall, {("*", factorSmall) | ("/", factor)}
    private final double term() {
      double x = factorSmall();
      for (; ; ) {
        switch (peek()) {
          case '*':
            next();
            x *= factorSmall();
            continue;
          case '/':
            next();
            x /= factorSmall();
            continue;
        }
        break;
      }
      return x;
    }

    // factorSmall = [spaces], ("(", expr, ")") | number, [spaces]
    private final double factorSmall() {
      double ret;
      spaces();
      if (peek() == '(') {
        next();
        ret = expr();
        if (peek() == ')') {
          next();
        }
      } else {
        ret = number();
      }
      spaces();
      return ret;
    }

    private void spaces() {
      while (peek() == ' ') {
        next();
      }
    }
  }

  // add FNSI-No196 TacBun計算式の変更 関 end
  private List<List<PatExamMain>> makeExamMainGroup(List<PatExamMain> patExamMain) {
    List<List<PatExamMain>> groupExam = new ArrayList<>();
    int i = 0;
    int flag = 0;
    for (int n = 0; n < patExamMain.size(); n++) {
      //TODO 透析前
      if (patExamMain.get(n).getRegOrderClass().equals(ExamResultCalcConstant.OrderClass.BEFORE_DIALYSIS) || patExamMain.get(n).getRegOrderClass().equals(ExamResultCalcConstant.OrderClass.OTHER_DIALYSIS)) {
        if (flag == 0) {
          if (groupExam.size() < i + 1) {
            groupExam.add(i, new ArrayList<>());
          }
          groupExam.get(i).add(patExamMain.get(n));
        } else {
          i++;
          flag = 0;
          if (groupExam.size() < i + 1) {
            groupExam.add(i, new ArrayList<>());
          }
          groupExam.get(i).add(patExamMain.get(n));
        }
      }
      //TODO 透析后
      if (patExamMain.get(n).getRegOrderClass().equals(ExamResultCalcConstant.OrderClass.AFTER_DIALYSIS)) {
        if (flag == 0) {
          flag = 1;

        }
        if (groupExam.size() < i + 1) {
          groupExam.add(i, new ArrayList<>());
        }
        groupExam.get(i).add(patExamMain.get(n));
      }
    }

    return groupExam;
  }
  // add FNSI-No196 TacBun計算式の変更 関 end

  private Map<String, List<PatExamMain>> getExamGroupAllExamDateTime(ExamResultParam examResultParam) throws ParseException {
    Map<String, List<PatExamMain>> groupExam = new HashMap<>();
    // upd #8782 検査計算項目が計算されない ztc 20230607 start
    //upd #8287 検査計算項目が計算されない 修正 ztc 20230623 strat
//    SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy/MM/dd hh:mm:ss");
//    Timestamp examDate = new Timestamp(new SimpleDateFormat("yyyy/MM/dd HH:mm:ss").parse(examResultParam.getTargetDt()).getTime());
//    List<PatExamMain> lstExamMain = patExamMainDao.selectPatExamMainByPatIdExamDateTimeList(examResultParam.getPatId(), examDate);
//    List<PatExamMain> lstExamMain = patExamMainDao.selectPatExamMainByPatIdExamDateTimeList(examResultParam.getPatId(), examResultParam.getTargetDtTime());

    //mod 9488 検査計算項目が検査後の値が更新しないと計算されない 関俊楠 start
    //SimpleDateFormat inputFormat = new SimpleDateFormat("yyyyMMdd");
    //SimpleDateFormat timestampFormat = new SimpleDateFormat("yyyyMMdd HH:mm:ss");
    //Date date = timestampFormat.parse(examResultParam.getTargetDt() + " 00:00:00");
    //Timestamp examDate = new Timestamp(date.getTime());
    //upd 8287 検査計算項目が計算されない 修正 ztc 20230623 strat
    //List<PatExamMain> lstExamMain = patExamMainDao.selectPatExamMainByPatIdExamEquRangeDate(examResultParam.getPatId(), examDate, examResultParam.getTargetDtTime());
    //upd #8287 検査計算項目が計算されない 修正 ztc 20230623 end
    // upd #8782 検査計算項目が計算されない ztc 20230607 end
    List<PatExamMain> lstExamMain = examResultParam.getPatExamMains();
    //mod 9488 検査計算項目が検査後の値が更新しないと計算されない 関俊楠 end

    List<PatExamMain> groupBeforeList = new ArrayList<PatExamMain>();
    List<PatExamMain> groupAfterList = new ArrayList<PatExamMain>();
    //mod 9734 再計算結果がペアリング対象外区分にも登録されている guan start
    for (int i = 0; i < lstExamMain.size(); i++) {
      if (lstExamMain.get(i).getRegOrderClass().equals(ExamResultCalcConstant.OrderClass.BEFORE_DIALYSIS)
      //  || lstExamMain.get(i).getRegOrderClass().equals(ExamResultCalcConstant.OrderClass.OTHER_DIALYSIS)
      ) {
        groupBeforeList.add(lstExamMain.get(i));
      } else if (lstExamMain.get(i).getRegOrderClass().equals(ExamResultCalcConstant.OrderClass.AFTER_DIALYSIS)) {
        groupAfterList.add(lstExamMain.get(i));
      } else if (lstExamMain.get(i).getRegOrderClass().equals(ExamResultCalcConstant.OrderClass.OTHER_DIALYSIS)) {
        //検査結果がALl全体の場合は、その検査項目が（透析前＝1）か（透析後＝2）か（すべて＝3）か、
        List<MstExamItem> mstExamItems = examResultParam.getMstExamItems();
        if (mstExamItems.size() == 1 && ExamClass.EXAM_ITEM.equals(mstExamItems.get(0).getExamClass())) {
          String dialysisProgressFlag = mstExamItems.get(0).getDialysisProgressFlag();
          if (ExamResultCalcConstant.DialysisProgressFlag.BEFORE.equals(dialysisProgressFlag)) {
            groupBeforeList.add(lstExamMain.get(i));
          }
          if (ExamResultCalcConstant.DialysisProgressFlag.AFTER.equals(dialysisProgressFlag)) {
            groupAfterList.add(lstExamMain.get(i));
          }
          //ExamResultCalcConstant.DialysisProgressFlag.ALL.equals(dialysisProgressFlag) //TODO すべて選択（すべて計算に関与しないため、beforとafterのいずれにも入れない）
        } else { //TODO mstExamItemsに複数のデータバーがある場合
          for (MstExamItem mstExamItem : mstExamItems) {
            Long examItemCd = mstExamItem.getExamItemCd();
            try {
              List<PatExamMainExamResultInfo> examResultInfo = lstExamMain.get(i).getExamResultInfo() == null || lstExamMain.get(i).getExamResultInfo().isEmpty() ? new ArrayList<>()
                : new ObjectMapper().readValue(lstExamMain.get(i).getExamResultInfo(), new TypeReference<List<PatExamMainExamResultInfo>>() {
              });
              examResultInfo = examResultInfo.stream().filter(f -> (ExamClass.EXAM_ITEM.equals(f.getExam_class()))).distinct().collect(Collectors.toList());
              for (PatExamMainExamResultInfo patExamMainExamResultInfo : examResultInfo) {
                if (String.valueOf(examItemCd).equals(patExamMainExamResultInfo.getItem_cd()) && !StringUtils.isEmpty(patExamMainExamResultInfo.getResult())) {
                  //TODO この検査項目の値が存在します
                  if (ExamResultCalcConstant.DialysisProgressFlag.BEFORE.equals(mstExamItem.getDialysisProgressFlag())) {
                    groupBeforeList.add(lstExamMain.get(i));
                  }
                  if (ExamResultCalcConstant.DialysisProgressFlag.AFTER.equals(mstExamItem.getDialysisProgressFlag())) {
                    groupAfterList.add(lstExamMain.get(i));
                  }
                  //TODO DialysisProgressFlag=3の考慮なし
                }
              }
            } catch (Exception e) {
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
              EventLogMessage eventLogMessage = new EventLogMessage();
              eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
              if (examResultParam != null && !StringUtils.isEmpty(examResultParam.getFacilityCd())) {
                eventLogMessage.setFacilityCd(examResultParam.getFacilityCd());
              }
              logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
            }
          }

        }
      }
    }
    //mod 9734 再計算結果がペアリング対象外区分にも登録されている guan end
    groupExam.put("before", groupBeforeList);
    groupExam.put("after", groupAfterList);
    return groupExam;
  }

  private Map<String, List<PatExamMain>> getExamGroupAllExam(ExamResultParam examResultParam) throws ParseException {
    Map<String, List<PatExamMain>> groupExam = new HashMap<>();
    Timestamp examDateFrom = new Timestamp(new SimpleDateFormat("yyyyMMdd HHmmss").parse(examResultParam.getTargetDt() + " 000000").getTime());
    Timestamp examDateTo = new Timestamp(new SimpleDateFormat("yyyyMMdd HHmmss").parse(examResultParam.getTargetDt() + " 000000").getTime() + 86400000);
    List<PatExamMain> lstExamMain = patExamMainDao.selectPatExamMainByPatIdExamdate(examResultParam.getPatId(), examDateFrom, examDateTo);

    int n = 0;
    int mid = 0;
    for (int i = 0; i < lstExamMain.size(); i++) {
      if (lstExamMain.get(i).getRegExamDate().equals(examResultParam.getRegExamDate())) {
        n = i;
      }
    }
    List<PatExamMain> groupBeforeList = new ArrayList<PatExamMain>();
    List<PatExamMain> groupAfterList = new ArrayList<PatExamMain>();
    if (examResultParam.getRegOrderClass().equals(ExamResultCalcConstant.OrderClass.BEFORE_DIALYSIS) || examResultParam.getRegOrderClass().equals(ExamResultCalcConstant.OrderClass.OTHER_DIALYSIS)) {
      //beforeExam
      for (int i = n; i >= 0; i--) {
        if (lstExamMain.get(i).getRegOrderClass().equals(ExamResultCalcConstant.OrderClass.BEFORE_DIALYSIS) || lstExamMain.get(i).getRegOrderClass().equals(ExamResultCalcConstant.OrderClass.OTHER_DIALYSIS)) {
          groupBeforeList.add(0, lstExamMain.get(i));
        } else if (lstExamMain.get(i).getRegOrderClass().equals(ExamResultCalcConstant.OrderClass.AFTER_DIALYSIS)) {
          break;
        }
      }
      for (int i = n + 1; i < lstExamMain.size(); i++) {
        if (lstExamMain.get(i).getRegOrderClass().equals(ExamResultCalcConstant.OrderClass.BEFORE_DIALYSIS) || lstExamMain.get(i).getRegOrderClass().equals(ExamResultCalcConstant.OrderClass.OTHER_DIALYSIS)) {
          groupBeforeList.add(lstExamMain.get(i));
        } else if (lstExamMain.get(i).getRegOrderClass().equals(ExamResultCalcConstant.OrderClass.AFTER_DIALYSIS)) {
          mid = i;
          break;
        }
      }
      //afterExam
      for (int i = mid; i < lstExamMain.size(); i++) {
        if (lstExamMain.get(i).getRegOrderClass().equals(ExamResultCalcConstant.OrderClass.AFTER_DIALYSIS)) {
          groupAfterList.add(lstExamMain.get(i));
        } else {
          break;
        }
      }
    } else if (examResultParam.getRegOrderClass().equals(ExamResultCalcConstant.OrderClass.AFTER_DIALYSIS)) {
      //afterExam
      for (int i = n; i < lstExamMain.size(); i++) {
        if (lstExamMain.get(i).getRegOrderClass().equals(ExamResultCalcConstant.OrderClass.AFTER_DIALYSIS)) {
          groupAfterList.add(lstExamMain.get(i));
        } else if (lstExamMain.get(i).getRegOrderClass().equals(ExamResultCalcConstant.OrderClass.BEFORE_DIALYSIS) || lstExamMain.get(i).getRegOrderClass().equals(ExamResultCalcConstant.OrderClass.OTHER_DIALYSIS)) {
          break;
        }
      }
      for (int i = n - 1; i >= 0; i--) {
        if (lstExamMain.get(i).getRegOrderClass().equals(ExamResultCalcConstant.OrderClass.AFTER_DIALYSIS)) {
          groupAfterList.add(0, lstExamMain.get(i));
        } else if (lstExamMain.get(i).getRegOrderClass().equals(ExamResultCalcConstant.OrderClass.BEFORE_DIALYSIS) || lstExamMain.get(i).getRegOrderClass().equals(ExamResultCalcConstant.OrderClass.OTHER_DIALYSIS)) {
          mid = i;
          break;
        }
      }
      //beforeExam
      for (int i = mid; i >= 0; i--) {
        if (lstExamMain.get(i).getRegOrderClass().equals(ExamResultCalcConstant.OrderClass.BEFORE_DIALYSIS) || lstExamMain.get(i).getRegOrderClass().equals(ExamResultCalcConstant.OrderClass.OTHER_DIALYSIS)) {
          groupBeforeList.add(0, lstExamMain.get(i));
        } else {
          break;
        }
      }
    }
    groupExam.put("before", groupBeforeList);
    groupExam.put("after", groupAfterList);
    return groupExam;
  }

  /**
   * 全角の数値を半角に変換する
   *
   * @param input
   * @return
   */
  private String ToDBC(String input) {
    if (input == null) {
      return null;
    }
    char[] c = input.toCharArray();
    for (int i = 0; i < c.length; i++) {
      if (c[i] == '\u3000') {
        c[i] = ' ';
      } else if (c[i] > '\uFF00' && c[i] < '\uFF5F') {
        c[i] = (char) (c[i] - 65248);
      }
    }
    return new String(c);
  }
  // mod #8144 【デグレ】検査計算結果が検査後にしか反映されない dou end
}
