package jp.co.nikkiso.ntss.admin_web.service.rad;

import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import jp.co.nikkiso.ntss.admin_web.request.patientCapture.JournalCreateRequestPayload;
import jp.co.nikkiso.ntss.admin_web.response.rad.RadRequestResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.AsyncService;
import jp.co.nikkiso.ntss.admin_web.service.JournalService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstRadSetDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatExamMainDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatNameIdentificationDao;
import jp.co.nikkiso.ntss.core.dao.PatRadMainDao;
import jp.co.nikkiso.ntss.core.dao.PatRadMainHstDao;
import jp.co.nikkiso.ntss.core.dao.PatRadPatternDao;
import jp.co.nikkiso.ntss.core.dao.PatTreatmentPatternDao;
import jp.co.nikkiso.ntss.core.dao.PatUniqueDao;
import jp.co.nikkiso.ntss.core.entity.MstRadSet;
import jp.co.nikkiso.ntss.core.entity.PatNameIdentification;
import jp.co.nikkiso.ntss.core.entity.PatRadMain;
import jp.co.nikkiso.ntss.core.entity.PatRadMainHst;
import jp.co.nikkiso.ntss.core.entity.PatRadPattern;
import jp.co.nikkiso.ntss.core.entity.PatTreatmentPattern;
import jp.co.nikkiso.ntss.core.entity.PatUnique;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainData;
import jp.co.nikkiso.ntss.core.entity.custom.PatRadMainData;
import jp.co.nikkiso.ntss.core.entity.custom.PatRadPatternData;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.seasar.doma.jdbc.Config;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.concurrent.atomic.AtomicInteger;
import jp.co.nikkiso.ntss.core.config.DefaultDb;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;


/**
 * 放射線検査結果のService実装クラス.
 */
@Service
public class RadRequestServiceImpl implements RadRequestService {

  /**
   * 追加.
   */
  public static final String INSERT = "1";

  /**
   * 変更.
   */
  public static final String UPDATE = "2";

  /**
   * 放射線検査結果Daoインタフェース.
   */
  @Autowired
  private PatRadMainDao patRadMainDao;

  //add FNSI-「幹対応残課題一覧.xlsx」№10対応 田 start
  /**
   * 放射線検査結果Daohstインタフェース.
   */
  @Autowired
  private PatRadMainHstDao patRadMainhstDao;
  //add FNSI-「幹対応残課題一覧.xlsx」№10対応 田 end

  /**
   * 放射線検査セットマスタのDaoインタフェース.
   */
  @Autowired
  private MstRadSetDao mstRadSetDao;

  /**
   * 放射線検査セットパターンDaoインタフェース.
   */
  @Autowired
  private PatRadPatternDao patRadPatternDao;

  /**
   * 治療パターンのDaoインタフェース.
   */
  @Autowired
  private PatTreatmentPatternDao patTreatmentPatternDao;

  /**
   * 治療情報のDaoインタフェース.
   */
  @Autowired
  private OrdMainDao ordMainDao;

  /**
   * 患者情報Daoインタフェース.
   */
  @Autowired
  private PatMainDao patMainDao;

  // add FNSI-「【1006】最新の改修対象一覧.xlsx」№499対応 鄧シン start
  @Autowired
  private PatUniqueDao patUniqueDao;
  // add FNSI-「【1006】最新の改修対象一覧.xlsx」№499対応 鄧シン end

  @Autowired
  private PatExamMainDao patExamMainDao;

  // DB更新ログ出力ロジック xie Start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Autowired
  private LogServiceCore logServiceCore;
  // DB更新ログ出力ロジック xie End

  @Autowired
  private AsyncService asyncService;

  @Autowired
  private LogService logService;

  //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy start
  @Autowired
  RadRequestService radRequestService;

  @Autowired
  PatRadMainHstDao patRadMainHstDao;

  //add #12462 患者情報共有 zrx start
  @Autowired
  private PatNameIdentificationDao patNameIdentificationDao;
  //add #12462 患者情報共有 zrx end

  @Autowired
  private JournalService journalService;

  @Autowired
  @DefaultDb
  private Config defaultDbConfig;
  //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy end

  @Override
  /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */
  // public List<PatRadMain> FindPatRadMainByDateCd(int pat_id, String dialysis_date_from, String dialysis_date_to) {
  public List<PatRadMain> FindPatRadMainByDateCd(int pat_id, String dialysis_date_from, String dialysis_date_to, Integer patShareMode) {
    return patRadMainDao.selectPatRadMainByDateCd(pat_id, dialysis_date_from, dialysis_date_to, patShareMode);
  }
  /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --end */
  //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
  @Override
  public List<PatRadMain> FindPatRadMainByIsOrder(int pat_id, String dialysis_date_from, String dialysis_date_to) {
    return patRadMainDao.selectPatRadMainByIsOrder(pat_id, dialysis_date_from, dialysis_date_to);
  }
  //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end

  //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy start
  @Override
  public List<PatRadMain> FindPatRadMainByRadResultCd(int pat_id, String dialysis_date_from, String rad_result_cd) {
    return patRadMainDao.selectPatRadMainByRadResultCd(pat_id, dialysis_date_from, rad_result_cd);
  }
  //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy end

  // add FNSI-放射線検査の表示の修正 楊 start
  /**
   * 放射線検査前回検査日取得
   * @param pat_id 患者前回放射線ID
   * @param dialysis_date_from 表示開始日
   * @return 前回放射線検査結果のResponse
   */
  @Override
  /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */
  // public PatRadMain FindPatRadMainLastDateByDateCd(long pat_id, String dialysis_date_from) {
  public PatRadMain FindPatRadMainLastDateByDateCd(long pat_id, String dialysis_date_from, Integer patShareMode) {
    // 前回検査日を取得
    List<PatRadMain> lastRadDateList = patRadMainDao.selectLastRadDate(pat_id, dialysis_date_from, patShareMode);
    PatRadMain resPatRadMain  = null;

    // 最新の検査日を戻る
    if (lastRadDateList != null && lastRadDateList.size() > 0) {
      resPatRadMain = lastRadDateList.get(0);
    }

    return resPatRadMain;
  }
  /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --end */
  // add FNSI-放射線検査の表示の修正 楊 end

  /**
   * 透析予定日変更時、放射線検査依頼日追従
   * @param params 患者ID,変更前日付,変更後日付
   */
  @Override
  @Transactional
  public int updateRegRadDate(Map<String,String> params) throws Exception {
    // DB更新ログ出力ロジック xie Start
    boolean setResult = false;
    DataUpdateLogCommonNew logCommon = null;
    try {
      String tableName = "pat_rad_main";
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" pat_id = '" + params.get("patId") + "'\n");
      wheres.append(" and to_char(reg_rad_date,'YYYY/MM/DD') = '" + params.get("beforeDate") + "' \n");
      // logCommon設定
      logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      setResult = logCommon.setInfo();
    } catch(Exception e) {
      setResult = false;
    }
    /* modify by shiyw 2023-03-25 [#8101] 患者経過総合応答速度の最適化です --start */
    int updateCount = 0;
    if(setResult){
      updateCount = patRadMainDao.updateRegRadDate(params);
    }
    /* modify by shiyw 2023-03-25 [#8101] 患者経過総合応答速度の最適化です --end */
    // DB更新ログ出力ロジック xie Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --start */
      logCommon.setAfterResults();
/* modify by shiyw 2023-03-07 [#8101] --start */
//      logCommon.updateLog();
      asyncService.updateLog(logCommon);
/* modify by shiyw 2023-03-07 [#8101] --end */
      /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --end */
    }
    // DB更新ログ出力ロジック xie End

    return updateCount;
  }
  //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy start
  /**
   * 透析予定日変更時、放射線検査依頼日追従
   * @param params 患者ID,変更前日付,変更後日付
   */
  @Override
  @Transactional
  public int updateRegRadDateByRadResultCd(Map<String,String> params) throws Exception {
    // DB更新ログ出力ロジック xie Start
    boolean setResult = false;
    DataUpdateLogCommonNew logCommon = null;
    //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy start
    List<JournalCreateRequestPayload> radJournalList = new ArrayList<>();
    //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy end
    try {
      String tableName = "pat_rad_main";
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" pat_id = '" + params.get("patId") + "'\n");
      wheres.append(" and rad_result_cd = '" + params.get("radResultCd") + "'\n");
      wheres.append(" and to_char(reg_rad_date,'YYYY/MM/DD') = '" + params.get("beforeDate") + "' \n");
      // logCommon設定
      logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      setResult = logCommon.setInfo();
    } catch(Exception e) {
      setResult = false;
    }
    //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy start
    String beforeDate = params.get("beforeDate").replaceAll("/", "");
    String afterDate = params.get("afterDate").replaceAll("/", "");
    String radResultCd = params.get("radResultCd");
    AtomicInteger updateCount = new AtomicInteger();
    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
    List<PatRadMain> patRadList = radRequestService.FindPatRadMainByRadResultCd(Integer.valueOf(params.get("patId")), beforeDate, radResultCd);
    PatRadMainHst patRadMainHst = new PatRadMainHst();
    patRadList.forEach(item -> {
      JournalCreateRequestPayload journalParameter = new JournalCreateRequestPayload();
      patRadMainHst.setRadResultCd(item.getRadResultCd());
      patRadMainHst.setPatId(item.getPatId());
      patRadMainHst.setFacilityCd(item.getFacilityCd());
      patRadMainHst.setFnPatId(item.getFnPatId());
      patRadMainHst.setRegRadDate(item.getRegRadDate());
      patRadMainHst.setRegOrderClass(item.getRegOrderClass());
      patRadMainHst.setRadStatus(item.getRadStatus());
      patRadMainHst.setOrderRadSetInfo(item.getOrderRadSetInfo());
      patRadMainHst.setCopOrderNo1(item.getCopOrderNo1());
      patRadMainHst.setCopOrderNo2(item.getCopOrderNo2());
      patRadMainHst.setIsLock(item.getIsLock());
      patRadMainHst.setIndUserId(item.getIndUserId());
      patRadMainHst.setIsDel(item.getIsDel());
      patRadMainHst.setRegDate(item.getRegDate());
      patRadMainHst.setRegStaff(item.getRegStaff());
      patRadMainHst.setUpDate(item.getUpDate());
      patRadMainHst.setUpStaff(item.getUpStaff());

      patRadMainHstDao.insertOrderRadSetInfo(patRadMainHst);

      patRadMainDao.deleteByRadResultCdAndFacility(item);

      journalParameter.setAnaResult("0");
      journalParameter.setBaseDate(sdf.format(item.getRegRadDate()));
      journalParameter.setCoopCdIndex("");
      journalParameter.setCoopResult("0");
      journalParameter.setCrud("D");
      journalParameter.setDirection("S");
      journalParameter.setFacilityCd(item.getFacilityCd());
      journalParameter.setOrdNo(item.getRadResultCd());
      journalParameter.setPatId(item.getPatId());
      journalParameter.setUserId(item.getIndUserId());
      journalParameter.setOpeCd("022010");
      radJournalList.add(journalParameter);

      journalParameter = new JournalCreateRequestPayload();

      String af_year = afterDate.substring(0, 4);
      String af_month = afterDate.substring(4, 6);
      String af_day = afterDate.substring(6,8);
      SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
      Timestamp timestamp = null;
      try {
        timestamp = new Timestamp(simpleDateFormat.parse(af_year+"-"+af_month+"-"+af_day + " 00:00:00").getTime());
      } catch (ParseException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        if (item != null && item.getFacilityCd() != null) {
          eventLogMessage.setFacilityCd(item.getFacilityCd());
        }
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      }
      item.setRegRadDate(timestamp);
      item.setUpDate(new Timestamp(System.currentTimeMillis()));
      item.setRadResultCd(null);

      patRadMainDao.insertOrderRadSetInfo(item);

      journalParameter.setAnaResult("0");
      journalParameter.setBaseDate(sdf.format(item.getRegRadDate()));
      journalParameter.setCoopCdIndex("");
      journalParameter.setCoopResult("0");
      journalParameter.setCrud("C");
      journalParameter.setDirection("S");
      journalParameter.setFacilityCd(item.getFacilityCd());
      journalParameter.setOrdNo(item.getRadResultCd());
      journalParameter.setPatId(item.getPatId());
      journalParameter.setUserId(item.getIndUserId());
      journalParameter.setOpeCd("022009");
      radJournalList.add(journalParameter);

      updateCount.getAndIncrement();
    });

    if (!org.springframework.util.CollectionUtils.isEmpty(radJournalList)){
      journalService.callCreateJournalForCtrNo(radJournalList);
    }

    /* modify by shiyw 2023-03-25 [#8101] 患者経過総合応答速度の最適化です --start */

    // if(setResult){
    //  updateCount = patRadMainDao.updateRegRadDateByRadResultCd(params);
    // }
    /* modify by shiyw 2023-03-25 [#8101] 患者経過総合応答速度の最適化です --end */
    // DB更新ログ出力ロジック xie Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount.get() > 0) {
      /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --start */
      logCommon.setAfterResults();
/* modify by shiyw 2023-03-07 [#8101] --start */
//      logCommon.updateLog();
      asyncService.updateLog(logCommon);
/* modify by shiyw 2023-03-07 [#8101] --end */
      /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --end */
    }
    // DB更新ログ出力ロジック xie End

    return updateCount.get();
    //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy end
  }

  /**
   * 透析予定中止時、放射線検査依頼削除
   * @param params 患者ID,日付
   */
  @Override
  @Transactional
  public int updateIsDel(Map<String,String> params) throws Exception {
    // DB更新ログ出力ロジック xie Start
    boolean setResult = false;
    DataUpdateLogCommonNew logCommon = null;
    try {
      String tableName = "pat_rad_main";
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" pat_id = '" + params.get("patId") + "'\n");
      wheres.append(" and to_char(reg_rad_date,'YYYY/MM/DD')  = '" + params.get("date") + "'\n");
      // logCommon設定
      logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      setResult = logCommon.setInfo();
    } catch(Exception e) {
      setResult = false;
    }
    // DB更新ログ出力ロジック xie End
    /* modify by shiyw 2023-03-25 [#8101] 患者経過総合応答速度の最適化です --start */
    //int updateCount = patRadMainDao.updateIsDel(params);
    int updateCount = 0;
    if(setResult){
      updateCount = patRadMainDao.updateIsDel(params);
    }
    /* modify by shiyw 2023-03-25 [#8101] 患者経過総合応答速度の最適化です --end */

    // DB更新ログ出力ロジック xie Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      logCommon.updateLog();
    }
    // DB更新ログ出力ロジック xie End

    return updateCount;
  }

  /* add by chamaojia 2023-03-24 [6118] 日付コレクションの一括処理の追加、updateIsDelメソッドの拡張 -- start */
  /**
   * 透析予定中止時、放射線検査依頼削除
   * @param params 患者ID,日付
   */
  @Override
  @Transactional
  public int updateIsDelByPatIdAndDateList(String patId, List<String> dateList) throws Exception {
    if (dateList == null || dateList.size() == 0) {
      return 0;
    }
    // DB更新ログ出力ロジック xie Start
    boolean setResult = false;
    DataUpdateLogCommonNew logCommon = null;
    try {
      String tableName = "pat_rad_main";
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" pat_id = '").append(patId).append("'\n");
//      wheres.append(" and to_char(reg_rad_date,'YYYY/MM/DD')  = '" + params.get("date") + "'\n");
      wheres.append(" and ").append(getInStr("to_char(reg_rad_date,'YYYY/MM/DD') in ", dateList)).append("\n");
      // logCommon設定
      logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      setResult = logCommon.setInfo();
    } catch(Exception e) {
      setResult = false;
    }
    // DB更新ログ出力ロジック xie End
    /* modify by shiyw 2023-03-25 [#8101] 患者経過総合応答速度の最適化です --start */
    //int updateCount = patRadMainDao.updateIsDel(params);
    int updateCount = 0;
    if(setResult){
      updateCount = patRadMainDao.updateIsDelByPatIdAndDateList(patId, dateList);
    }
    /* modify by shiyw 2023-03-25 [#8101] 患者経過総合応答速度の最適化です --end */

    // DB更新ログ出力ロジック xie Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
//      logCommon.updateLog();
      logCommon.setAfterResults();
      asyncService.updateLog(logCommon);
    }
    // DB更新ログ出力ロジック xie End

    return updateCount;
  }
  /* add by chamaojia 2023-03-24 [6118] 日付コレクションの一括処理の追加、updateIsDelメソッドの拡張 -- end */

  /**
   * {@inheritDoc}
   */
  @Override
  //mod #12462 患者情報共有 zrx start
//  public RadRequestResponse createRadRequestResponse(List<Long> patIdList, String startDate, String facilityCd) {
    public RadRequestResponse createRadRequestResponse(
      List<Long> patIdList, String startDate, String facilityCd, Integer patientShareMode) {
    //mod #12462 患者情報共有 zrx end

    // 患者毎の透析予定日のリストを取得
    List<String> ordMainTreatDateList = ordMainDao.selectTreatDateList(patIdList, facilityCd);

    // 患者、検査セットごとの前回検査日を取得
    //List<String> lastRadDateList = patRadMainDao.selectLastRadDateList(patIdList, startDate);
    //mod 横展開管理台帳_日機装FNSI NO.4684 劉全航 start
    List<String> lastRadDateList = patRadMainDao.selectLastRadDateList(patIdList, LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy/MM/dd")));
    //mod 横展開管理台帳_日機装FNSI NO.4684 劉全航 end
    // 施設IDを元に、検査結果を取得
    List<PatRadMainData> patRadMainList = patRadMainDao.selectPatRadMainByPatIdList(patIdList, startDate);

    // 患者毎の検査パターンを取得
    List<PatRadPatternData> patRadPatternList = patRadPatternDao.selectPatRadPatternByPatIdList(patIdList, startDate, facilityCd);

    // 患者毎の治療パターンを取得
    List<PatTreatmentPattern> patTreatmentPatternList = patTreatmentPatternDao.selectByPatIdList(patIdList, facilityCd);
    //add #12462 患者は合計 by zrx start
    List<Long> pat_id_temp_list = null;
    if(null!=patIdList && patientShareMode != null && patientShareMode == 0) {
      for (Long patIdTemp : patIdList) {
        //共有情報の照会
        List<PatNameIdentification> listPatIdSrcFromPatTo = patNameIdentificationDao.getListPatIdSrcFromPatTo(patIdTemp);
        pat_id_temp_list = new ArrayList<>(listPatIdSrcFromPatTo.size());
        for (PatNameIdentification patIdSrcFromPatTo : listPatIdSrcFromPatTo) {
          pat_id_temp_list.add(patIdSrcFromPatTo.getPatIdSrc());
          // 患者毎の透析予定日のリストを取得
          List<String> ordMainTreatDateListTemp = ordMainDao.selectTreatDateList(Arrays.asList(patIdSrcFromPatTo.getPatIdSrc()), patIdSrcFromPatTo.getFacilityCdSrc());
          ordMainTreatDateList.addAll(ordMainTreatDateListTemp);
          // 患者、検査セットごとの前回検査日を取得
          //mod 横展開管理台帳_日機装FNSI NO.4684 劉全航 start
          List<String> lastRadDateListTemp = patRadMainDao.selectLastRadDateList(Arrays.asList(patIdSrcFromPatTo.getPatIdSrc()), LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy/MM/dd")));
          lastRadDateList.addAll(lastRadDateListTemp);
          //mod 横展開管理台帳_日機装FNSI NO.4684 劉全航 end
          // 施設IDを元に、検査結果を取得
          List<PatRadMainData> patRadMainListTemp = patRadMainDao.selectPatRadMainByPatIdList(Arrays.asList(patIdSrcFromPatTo.getPatIdSrc()), startDate);
          patRadMainListTemp.forEach(x->x.setPatId(patIdTemp));
          patRadMainList.addAll(patRadMainListTemp);
          // 患者毎の検査パターンを取得
          List<PatRadPatternData> patRadPatternListTemp = patRadPatternDao.selectPatRadPatternByPatIdList(Arrays.asList(patIdSrcFromPatTo.getPatIdSrc()), startDate, patIdSrcFromPatTo.getFacilityCdSrc());
          patRadPatternListTemp.forEach(x->x.setPatId(patIdTemp));
          patRadPatternList.addAll(patRadPatternListTemp);
          // 患者毎の治療パターンを取得
          List<PatTreatmentPattern> patTreatmentPatternListTemp = patTreatmentPatternDao.selectByPatIdList(Arrays.asList(patIdSrcFromPatTo.getPatIdSrc()), patIdSrcFromPatTo.getFacilityCdSrc());
          patTreatmentPatternListTemp.forEach(x->x.setPatId(patIdTemp));
          patTreatmentPatternList.addAll(patTreatmentPatternListTemp);
        }
      }
    }
    //add #12462 患者は合計 by zrx end

    // 日時(検査パターンの横軸)の取得
    List<Map<String, Integer>> tmpPatternColumnList = new ArrayList<Map<String, Integer>>();
    for (PatRadPatternData data : patRadPatternList) {
      Map<String, Integer> patternjson = new HashMap<String, Integer>();
      patternjson.put("radPattern", data.getRadPattern());
      patternjson.put("radWeek", data.getRadWeek());
      tmpPatternColumnList.add(patternjson);
    }
    List<Map<String, Integer>> patternColumnList = tmpPatternColumnList.stream().distinct().collect(Collectors.toList());


    // 日時(患者個別用検査パターンの横軸)の取得
    List<Map<String, String>> tmpPatternDetailColumnList = new ArrayList<Map<String, String>>();
    for (PatRadPatternData data : patRadPatternList) {
      Map<String, String> patternDetailjson = new HashMap<String, String>();
      patternDetailjson.put("radPattern", data.getRadPattern().toString());
      patternDetailjson.put("radWeek", data.getRadWeek().toString());
      patternDetailjson.put("radTime", data.getStrRadTime());
      tmpPatternDetailColumnList.add(patternDetailjson);
    }
    List<Map<String, String>> patternDetailColumnList = tmpPatternDetailColumnList.stream().distinct().collect(Collectors.toList());

    // 検索結果0件の場合、空のResponseを返す
    if (patRadMainList.isEmpty()) {
      List<String> tmpDateList = new ArrayList<String>();
      List<String> tmpDateTimeList = new ArrayList<String>();
      List<PatUnique> patUniqueList = new ArrayList<PatUnique>();
      return new RadRequestResponse(patRadMainList, tmpDateList, tmpDateTimeList, ordMainTreatDateList, lastRadDateList, patRadPatternList, patternColumnList, patternDetailColumnList, patUniqueList, patTreatmentPatternList);
    }

    // 日付(表の横軸)の取得
    List<String> tmpDateList = new ArrayList<String>();
    for (PatRadMainData data : patRadMainList) {
      tmpDateList.add(data.getStrRadDate());
    }

    // 日時(患者個別表の横軸)の取得
    List<String> tmpDateTimeList = new ArrayList<String>();
    for (PatRadMainData data : patRadMainList) {
      tmpDateTimeList.add(data.getStrRadDate() +"_"+ data.getStrRadTime());
    }

    // 重複を削除し、並び替え
    List<String> radDateList = new ArrayList<String>(new LinkedHashSet<>(tmpDateList));
    Collections.sort(radDateList);

    // 重複を削除し、並び替え
    List<String> radDateTimeList = new ArrayList<String>(new LinkedHashSet<>(tmpDateTimeList));
    Collections.sort(radDateTimeList);

    //add #12462 患者情報共有 zrx start
    if(null!=pat_id_temp_list) {
      patIdList.addAll(pat_id_temp_list);
    }
    //add #12462 患者情報共有 zrx end

    List<PatUnique> patUniqueList = patUniqueDao.selectByIdList(patIdList);
    return new RadRequestResponse(patRadMainList, radDateList, radDateTimeList, ordMainTreatDateList,lastRadDateList, patRadPatternList, patternColumnList, patternDetailColumnList, patUniqueList, patTreatmentPatternList);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public boolean updateMasterData(List<Map<String, String>> updateData, String facilityCd, Long userId, List<PatRadPatternData> patRadPatternList , List<Map<String, String>> patExtInfoList) {

    // スケジュール延長最終日更新
    patExtInfoList.forEach(patExtInfo -> {
      try {
        Long patId = Long.parseLong(patExtInfo.get("patId"));
        String schExtEndDate = patExtInfo.get("schExtEndDate");
        Boolean isExistEndDate = Boolean.parseBoolean(patExtInfo.get("isExistEndDate"));

        if (!isExistEndDate) {
          // DB更新ログ出力ロジック xie Start
          boolean setResult = false;
          DataUpdateLogCommonNew logCommon = null;
          try {
            String tableName = "pat_main";
            // SQL検索条件
            StringBuffer wheres = new StringBuffer("");
            wheres.append(" WHERE\n");
            wheres.append(" pat_id = '" + patId + "'\n");
            // logCommon設定
            logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
            // ログ出力カラム情報及び更新前データ情報取得
            setResult = logCommon.setInfo();
          } catch(Exception e) {
            setResult = false;
          }
          // DB更新ログ出力ロジック xie End
          int updateCount = patMainDao.updateSchExtEndDate(patId, schExtEndDate);

          // DB更新ログ出力ロジック xie Start
          // 更新後データ取得、差分あれば、log出力
          if (setResult && updateCount > 0) {
            logCommon.updateLog();
          }
          // DB更新ログ出力ロジック xie End
        }
      } catch (Exception e) {
        throw new NotExistException(e.getMessage());
      }
    });

    // 検査セットパターン登録
    patRadPatternList.forEach(e -> {

      // 登録時間取得
      java.sql.Timestamp regDt = getCurrentDate();

      PatRadPattern patRadPattern = new PatRadPattern()
      {
        {
          setRadPatternCd(e.getRadPatternCd());
          setPatId(e.getPatId());
          setFacilityCd(facilityCd);
          setRegRadDate(e.getRegRadDate());
          setRegOrderClass(e.getRegOrderClass());
          setRadPattern(e.getRadPattern());
          setRadWeek(e.getRadWeek());
          setRadFrom(e.getRadFrom());
          setRadTo(e.getRadTo());
          setOrderRadSetCd(e.getOrderRadSetCd());
          setIsDel(e.getIsDel());
          setRegDate(regDt);
          setRegStaff(userId);
          setUpDate(regDt);
          setUpStaff(userId);
          //mod FNSI-「検査予定パターン削除システムエラー.xlsx」対応 田 start
          //setIndUserId(Long.parseLong(updateData.get(0).get("indUserId")));
          setIndUserId(updateData.size() != 0 ? Long.parseLong(updateData.get(0).get("indUserId")) : null );
          //mod FNSI-「検査予定パターン削除システムエラー.xlsx」対応 田 end
        }
      };
      switch (e.getStatus()) {
        case 0:
          patRadPatternDao.updatePatRadPattern(patRadPattern);
          break;
        case 1:
          break;
        case 2:
          patRadPatternDao.insertPatRadPattern(patRadPattern);
          break;
      }


    });

    // 追加
    insertData(updateData, facilityCd, userId);
    // 更新
    updateData(updateData, userId);

    return true;
  }


  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstRadSet> selectRadSetList(String facilityCd) {
    List<MstRadSet> mstRadSetList = mstRadSetDao.selectRadSetList(facilityCd);
    return mstRadSetList;
  }

  /**
   * システム日時を取得します
   * @return システム日時
   */
  private java.sql.Timestamp getCurrentDate() {
    return new java.sql.Timestamp(System.currentTimeMillis());
  }

  /**
   * データ追加.
   *
   * @param data 画面で編集したデータ
   */
  private void insertData(List<Map<String, String>> data, String facilityCd, Long userId) {
    // アップデートタイプの定数はマスタ用の定数を借用
    data.stream().filter(e -> e.get("operation").equals(INSERT)).forEach(e -> {
      try {
        // 変換対象の日付文字列
        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd HH:mm:ss");
        // Timestamp型変換
        String radTime = e.get("strRadTime").isEmpty() ? "00:00:00" : e.get("strRadTime") + ":00";
        Timestamp regRadDate = new Timestamp(sdf.parse(e.get("regRadDate") + " " + radTime).getTime());

        // 登録時間取得
        java.sql.Timestamp regDt = getCurrentDate();
        PatRadMain patRadMain = new PatRadMain()
        {
          {
            setPatId(Long.parseLong(e.get("patId")));
            setFacilityCd(facilityCd);
            setRegRadDate(regRadDate);
            setRegOrderClass(e.get("regOrderClass"));
            setRadStatus("0");
            setOrderRadSetInfo(e.get("orderRadSetInfo"));
            setIsLock(e.get("isLock"));
            setIndUserId(Long.parseLong(e.get("indUserId")));
            setIsDel("0");
            setUpDate(regDt);
            setUpStaff(userId);
            setRegDate(regDt);
            setRegStaff(userId);
          }
        };
        patRadMainDao.insertOrderRadSetInfo(patRadMain);

        //#add 10125 検査予定に関する連携イベント作成不備 zrx start
        e.put("radResultCd", patRadMain.getRadResultCd() > 0 ? patRadMain.getRadResultCd().toString() : null);
        //#add 10125 検査予定に関する連携イベント作成不備 zrx end

      } catch (ParseException ex) {
        throw new NotExistException("日付の変換に失敗しました。");
      }
    });

  }

  /**
   * データ更新.
   *
   * @param data 画面で編集したデータ
   */
  private void updateData(List<Map<String, String>> data, Long userId) {
    // アップデートタイプの定数はマスタ用の定数を借用
    data.stream().filter(e -> e.get("operation").equals(UPDATE)).forEach(e -> {

      PatRadMain oldPatRadMain = new PatRadMain()
      {
        {
          setRadResultCd(Long.parseLong(e.get("radResultCd")));
        }
      };
      PatRadMain ma =patRadMainDao.selectPatRadMain(oldPatRadMain.getRadResultCd());

        //add FNSI-「幹対応残課題一覧.xlsx」№10対応 田 start
      try {
        // 変換対象の日付文字列
        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd HH:mm:ss");
        // Timestamp型変換
        String radTime = e.get("strRadTime").isEmpty() ? "00:00:00" : e.get("strRadTime") + ":00";
        Timestamp regRadDate = new Timestamp(sdf.parse(e.get("strRadDate") + " " + radTime).getTime());

        // 登録時間取得
        java.sql.Timestamp regDt = getCurrentDate();

        PatRadMain patRadMain = new PatRadMain()
        {
          {
            setRadResultCd(Long.parseLong(e.get("radResultCd")));
            setRegRadDate(regRadDate);
            setOrderRadSetInfo(e.get("orderRadSetInfo"));
            setIsLock(e.get("isLock"));
            setIndUserId(Long.parseLong(e.get("indUserId")));
            if (e.get("isDel").equals("1") && ma.getRadStatus().equals("0")) {
              setIsDel(e.get("isDel"));
            } else {
              // 中止で検査結果ありの場合はDELETEしない
              setIsDel("0");
            }
            setUpDate(regDt);
            setUpStaff(userId);
          }
        };
        patRadMainDao.updateOrderRadSetInfo(patRadMain);
      } catch (ParseException ex) {
        throw new NotExistException("日付の変換に失敗しました。");
      }

      PatRadMainHst patRadMainhst = new PatRadMainHst()
      {
        {
          setRadResultCd(ma.getRadResultCd());
          setPatId(ma.getPatId());
          setFacilityCd(ma.getFacilityCd());
          setFnPatId(ma.getFnPatId());
          setRegRadDate(ma.getRegRadDate());
          setRegOrderClass(ma.getRegOrderClass());
          setRadStatus(ma.getRadStatus());
          setOrderRadSetInfo(ma.getOrderRadSetInfo());
          setCopOrderNo1(ma.getCopOrderNo1());
          setCopOrderNo2(ma.getCopOrderNo2());
          setIsLock(ma.getIsLock());
          setIndUserId(ma.getIndUserId());
          setIsDel(ma.getIsDel());
          setUpDate(ma.getUpDate());
          setUpStaff(ma.getUpStaff());
          setRegDate(ma.getRegDate());
          setRegStaff(ma.getRegStaff());
        }
      };
      if (e.get("isDel").equals("1") && ma.getRadStatus().equals("0")) {
        // 中止で検査結果なしの場合はDELETEする
        patRadMainhstDao.insertOrderRadSetInfo(patRadMainhst);
        //mod 障害票一覧_一般撮影監査依頼 劉全航 start
        patRadMainDao.deleteByRadResultCd(oldPatRadMain);
        //mod 障害票一覧_一般撮影監査依頼 劉全航 end
      }
      //patRadMainDao.deleteByRadResultCd(patRadMain);
      //add FNSI-「幹対応残課題一覧.xlsx」№10対応 田 end
    });
  }

  // DB更新ログ出力ロジック xie Start
  /**
   * ログ出力共通クラス設定、取得
   * @return logCommon ログ出力共通クラス
   */
  private DataUpdateLogCommonNew getLogCommon(String tableName, StringBuffer whereStr, EventLogMessage eventLogMessage) {
    DataUpdateLogCommonNew logCommon = new DataUpdateLogCommonNew();
    logCommon.setEventLoggerFactory(eventLoggerFactory);
    logCommon.setLogServiceCore(logServiceCore);
    logCommon.setConfig(defaultDbConfig);
    logCommon.setTableName(tableName);
    logCommon.setWhereStr(whereStr);
    logCommon.setCommonEventLogMessage(eventLogMessage);
    return logCommon;
  }

  /**
   * ログ情報設定
   * @return eventLogMessage
   */
  private EventLogMessage getEventLogMessage() {
    EventLogMessage eventLogMessage = new EventLogMessage();
    NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    if (user != null) {
      // 利用者ID
      eventLogMessage.setUserId(user.getUserId().toString());
      // 施設コード
      eventLogMessage.setFacilityCd(user.getFacilityCd());
      // 接続先IPアドレス
      eventLogMessage.setClientIp(user.getClientIpAddress());
      // セッションID
      eventLogMessage.setSessionId(user.getSessionId());
    }
    // サービス名
    eventLogMessage.setServiceName(LoggingConstant.MODULE_NAME.ADMIN_WEB + "," + LoggingConstant.SERVICE_NAME.FNSI);
    return   eventLogMessage;
  }

  /**
   * longからStringに変更する
   * @param radResultCdList
   * @return
   */
  private static String getLongValueStr(ArrayList<Long> radResultCdList) {
    String str = "";
    for (int i = 0; i < radResultCdList.size(); i++) {
      Long value = radResultCdList.get(i);
      if (value == null) {
        continue;
      }
      str += value.toString() + ",";
    }

    if (str.lastIndexOf(",") == str.length() - 1) {
      return str.substring(0, str.length() - 1);
    }

    return str;
  }
  // DB更新ログ出力ロジック xie End
  //mod FNSI-検査結果を削除する場合は、一般撮影監査依頼の状態を変更する 劉全航 start
  public int updatePatRadStatus(Long patId, String examDate, String facilityCd, String radStatus){
    List<PatExamMainData> patExamMainList = patExamMainDao.selectPatExamMainByPatIdAndRegExamDateAndFacilityCd(Collections.singletonList(patId), examDate, facilityCd);
    if(patExamMainList.size() == 0){
      List<PatRadMain> patRadMainList = patRadMainDao.selectByPatIdAndRegRadDateAndFacilityCd(patId, examDate, facilityCd);
      List<Long> radResultCdList = patRadMainList.stream().map(PatRadMain::getRadResultCd).collect(Collectors.toList());
      return patRadMainDao.updateRadStatusByRadResultCd(radResultCdList,radStatus);
    }else{
      return 0;
    }
  }
  //mod FNSI-検査結果を削除する場合は、一般撮影監査依頼の状態を変更する 劉全航 end

  /**
   * 検索条件 IN情報
   *
   * @param fieldInfo カラム情報
   * @param inList    IN値リスト
   * @return inStr
   */
  public <T> String getInStr(String fieldInfo, List<T> inList) {
    StringBuffer inStr = new StringBuffer("");
    inStr.append(fieldInfo);
    inStr.append(" (");
    for (T obj : inList) {
      inStr.append(" '").append(obj).append("'");
      inStr.append(",");
    }
    inStr.deleteCharAt(inStr.length() - 1);
    inStr.append(") ");
    return String.valueOf(inStr);
  }
}
