package jp.co.nikkiso.ntss.admin_web.service.patHomeDialysis;

import java.math.BigDecimal;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.TimeZone;

import jp.co.nikkiso.ntss.admin_web.service.SelectHistoryUtils;
import org.apache.commons.lang3.StringUtils;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.admin_web.response.patHomeDialysis.DialysisStatusResponse;
import jp.co.nikkiso.ntss.admin_web.response.patHomeDialysis.DialysisWeightResponse;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.utils.DateTimeUtils;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallCommonUtil;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.FacilitySettingNo;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.NotificationDefinition;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MniMonitorDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.MstPatEventCategoryDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatEventDao;
import jp.co.nikkiso.ntss.core.dao.PatHhdPatternDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.entity.MniMonitor;
import jp.co.nikkiso.ntss.core.entity.MstPatEventCategory;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatEvent;
import jp.co.nikkiso.ntss.core.entity.PatHhdPattern;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;
import jp.co.nikkiso.ntss.core.entity.custom.PatEventData;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.transaction.annotation.Transactional;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * 在宅透析患者向けのService実装クラス.
 */
@Service
public class PatHomeDialysisServiceImpl implements PatHomeDialysisService {

  /**
   * 治療情報のDaoインタフェース.
   */
  @Autowired
  private OrdMainDao ordMainDao;

  /**
   * モニタリングデータのDaoインタフェース.
   */
  @Autowired
  private MniMonitorDao mniMonitorDao;

  /**
   * 検査セットパターンDaoインタフェース.
   */
  @Autowired
  private PatHhdPatternDao patHhdPatternDao;

  /**
   * 患者イベントDaoインタフェース.
   */
  @Autowired
  private PatEventDao patEventDao;

  /**
   * 患者イベントカテゴリーマスタDaoインタフェース.
   */
  @Autowired
  private MstPatEventCategoryDao mstPatEventCategoryDao;

  /**
   * 施設設定マスタDaoインタフェース.
   */
  @Autowired
  private MstFacilitySettingDao mstFacilitySettingDao;

  /**
   * 患者個人情報Daoインタフェース.
   */
  @Autowired
  private PatPersonalMainDao patPersonalMainDao;

  /**
   * webAPI呼び出し用
   */
  @Autowired
  WebApiCallCommonUtil webApiCallCommonUtil;

  /**
  * ロギングのServiceインタフェース.
  */
  @Autowired
  private LogService logService;

  // add FNSI-改修内容追加OrdMain履歴 付 start
  @Autowired
  private SelectHistoryUtils selectHistoryUtils;
  // add FNSI-改修内容追加OrdMain履歴 付 end

  /**
   * {@inheritDoc}
   */
  @Override
  public DialysisStatusResponse createDialysisStatusResponse(Long patId, String facilityCd) {

    // 現在日付をYYYYMMDDで取得
    Calendar cl = Calendar.getInstance();
    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
    sdf.setTimeZone(TimeZone.getTimeZone("JST"));
    String today = sdf.format(cl.getTime());

    cl.add(Calendar.DAY_OF_MONTH, -1);
    String yesterday = sdf.format(cl.getTime());

    // 該当患者の透析状態を取得
    OrdMain ordMainObj = ordMainDao.selectRstDialysisStateAndOrdNo(facilityCd, today, yesterday, patId);

    if (Objects.isNull(ordMainObj)) {
      return new DialysisStatusResponse();
    }

    List<MniMonitor> monitorDataList = mniMonitorDao.selectMonitorData(facilityCd, patId, ordMainObj.getOrdNo());

    if (monitorDataList.isEmpty()) {
      return new DialysisStatusResponse(ordMainObj.getRstDialysisState(), ordMainObj.getIndTreatmentName(), "");
    }

    return new DialysisStatusResponse(ordMainObj.getRstDialysisState(), ordMainObj.getIndTreatmentName(), monitorDataList.get(0).getMonitorData());
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<PatHhdPattern> FindPatHhdPatternByFacilityCd(String facility_cd) {
    return patHhdPatternDao.selectByFacilityCd(facility_cd);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<PatHhdPattern> FindPatHhdPatternByPatId(Long pat_id) {
    return patHhdPatternDao.selectByPatId(pat_id);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<PatHhdPattern> getPatHhdPatternData(String facility_cd, Long pat_id){

    // 現在日付をYYYYMMDDで取得
    Calendar cl = Calendar.getInstance();
    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
    sdf.setTimeZone(TimeZone.getTimeZone("JST"));
    String today = sdf.format(cl.getTime());

    return patHhdPatternDao.selectByPatInfo(facility_cd,pat_id,today);
  }

  /**
   * 前体重入力時：更新対象 治療情報テーブルデータ　状況確認
   */
  public DialysisWeightResponse getDialysisStateByOrdNo(Long ord_no){
    OrdMain ordMainObj = ordMainDao.selectByOrdNo(ord_no);

    if (Objects.isNull(ordMainObj)) {
      return new DialysisWeightResponse();
    }

    return new DialysisWeightResponse(ordMainObj.getOrdNo(),ordMainObj.getRstDialysisState(),ordMainObj.getRstWeightInfo());
  }


  /**
   * {@inheritDoc}
   */
  @Override
  public DialysisWeightResponse getDialysisWeightBefore(Long patId, String facilityCd) {

    // 現在日付をYYYYMMDDで取得
    Calendar cl = Calendar.getInstance();
    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
    sdf.setTimeZone(TimeZone.getTimeZone("JST"));
    String today = sdf.format(cl.getTime());

    cl.add(Calendar.DAY_OF_MONTH, -1);
    String yesterday = sdf.format(cl.getTime());

    // 更新前データ：条件送信前
    List<String> selectState = Arrays.asList("0");

    // 該当患者の透析状態を取得
    OrdMain ordMainObj = ordMainDao.selectRstWeightInfoByPatId(facilityCd, today, yesterday, patId,selectState);

    if (Objects.isNull(ordMainObj)) {
      return new DialysisWeightResponse();
    }

    return new DialysisWeightResponse(ordMainObj.getOrdNo(),ordMainObj.getRstDialysisState(),ordMainObj.getRstWeightInfo());
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public DialysisWeightResponse getStatue(String facilityCd, String[] arr) {

	// 更新前データ：条件送信前
	List<String> selectState = Arrays.asList(arr);

    // 該当患者の透析状態を取得
    OrdMain ordMainObj = ordMainDao.selectByStatue(facilityCd,selectState);

    //mod 7311 新規に作った治療予定の存在しない施設でクールマスタを保存するとフリーズ 関俊楠 start
    Long rstOrdMainFlag = null;
    //验证当前设备下是否存在预定数据
    List<OrdMain> ordMainList = ordMainDao.selectOrdMainByFacilityCdCount(facilityCd);
    if (ordMainList.size() > 0) {
      rstOrdMainFlag = 1L;
    }

//     if (Objects.isNull(ordMainObj)) {
//      return new DialysisWeightResponse();
//    }

    if (Objects.isNull(ordMainObj)) {
      DialysisWeightResponse dialysisWeightResponse =  new DialysisWeightResponse();
      dialysisWeightResponse.setRstOrdMainFlag(rstOrdMainFlag);
      return dialysisWeightResponse;
    }
 //   return new DialysisWeightResponse(ordMainObj.getOrdNo(),ordMainObj.getRstDialysisState(),ordMainObj.getRstWeightInfo());
    return new DialysisWeightResponse(ordMainObj.getOrdNo(),ordMainObj.getRstDialysisState(),ordMainObj.getRstWeightInfo(), rstOrdMainFlag);
    //mod 7311 新規に作った治療予定の存在しない施設でクールマスタを保存するとフリーズ 関俊楠 end
  }


  /**
   * {@inheritDoc}
   */
  @Override
  public DialysisWeightResponse getDialysisWeightAfter(Long patId, String facilityCd) {

    // 現在日付をYYYYMMDDで取得
    Calendar cl = Calendar.getInstance();
    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
    sdf.setTimeZone(TimeZone.getTimeZone("JST"));
    String today = sdf.format(cl.getTime());

    cl.add(Calendar.DAY_OF_MONTH, -1);
    String yesterday = sdf.format(cl.getTime());

    // 後体重対象データ：条件送信済、送信確認済、治療中、廃液済
    List<String> selectState = Arrays.asList("1","2","3","4");

    // 該当患者の透析状態を取得
    OrdMain ordMainObj = ordMainDao.selectRstWeightInfoByPatId(facilityCd, today, yesterday, patId,selectState);

    if (Objects.isNull(ordMainObj)) {
      //return new DialysisStatusResponse("", "", "");
      return new DialysisWeightResponse();
    }

    return new DialysisWeightResponse(ordMainObj.getOrdNo(),ordMainObj.getRstDialysisState(),ordMainObj.getRstWeightInfo());
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<PatEventData> findEventByPatIdNewest(Long patId, String startEventDate, String endEventDate) {
    return patEventDao.selectByPatIdNewestCustom(patId, startEventDate, endEventDate);
  }

  /**
   * システム日時を取得します
   * @return システム日時
   */
  private java.sql.Timestamp getCurrentDate() {
    return new java.sql.Timestamp(System.currentTimeMillis());
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public boolean updateWeightBefore(Long ordNo, String weightBefore){

    String setDate = DateTimeUtils.getDateString_iso8601(new Date());
    BigDecimal setweight = new BigDecimal(weightBefore);
    try{

      // add FNSI-改修内容追加OrdMain履歴 付 start
      getHistory(ordNo);
      // mangoDb-updateWeightBefore-insertSuccess
      // add FNSI-改修内容追加OrdMain履歴 付 end

      // WeightInfoのアップデート
      ordMainDao.updateWeightBefore(ordNo,setweight,setDate);

    }catch (Exception ex) {
      // ロールバック実行
      throw new RuntimeException(ex.getMessage());
    }
    return true;
  }

  // add FNSI-改修内容追加OrdMain履歴 付 start
  private void getHistory(Long ordNo){
    selectHistoryUtils.insertMangoDbHistory(1, ordNo, null, new ArrayList<>(), new ArrayList<>(), null, null,
      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
      new ArrayList<>(), null, null);
  }
  // add FNSI-改修内容追加OrdMain履歴 付 end

  /**
   * {@inheritDoc}
   */
  @Override
  public boolean updateWeightAfter(Long ordNo, String weightAfter){


    String setDate = DateTimeUtils.getDateString_iso8601(new Date());
    BigDecimal setweight = new BigDecimal(weightAfter);
    try{

      // add FNSI-改修内容追加OrdMain履歴 付 start
      getHistory(ordNo);
      // mangoDb-updateWeightAfter-insertSuccess
      // add FNSI-改修内容追加OrdMain履歴 付 end

      // WeightInfoのアップデート
      ordMainDao.updateWeightAfter(ordNo,setweight,setDate);

    }catch (Exception ex) {
      // ロールバック実行
      throw new RuntimeException(ex.getMessage());
    }
    return true;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public int insert(Map<String, String> request) {

    // 登録時間取得
    java.sql.Timestamp regDt = getCurrentDate();

    // revisionの最大値を取得
    int revision = patHhdPatternDao.selectRevisionByPatId(Long.parseLong(request.get("patId")));

    // revisionが0:新規でない場合、患者イベントに指示変更を登録
    if (revision > 0)
    {
      // 施設設定マスタから指示変更のカテゴリIDを取得する。
      FacilitySettingInfo newFacilitySettingInfo = new FacilitySettingInfo();
      newFacilitySettingInfo = mstFacilitySettingDao.getBySettingNoAndCd(request.get("facilityCd"), FacilitySettingNo.CHANGE_IND_CATEGORY_ID);

      Long categoryCd = Long.parseLong(newFacilitySettingInfo.getValue());

      // 患者イベントカテゴリーマスタからカテゴリー名称を取得する。
      MstPatEventCategory newMstPatEventCategory = new MstPatEventCategory();
      newMstPatEventCategory = mstPatEventCategoryDao.selectByCd(categoryCd);

      String categoryName = newMstPatEventCategory.getCategoryName();

      Long newPatEventCd = patEventDao.selectNextSeqPatEventCd();

      PatEvent upPatEvent = new PatEvent() {
        {
          setPatId(Long.parseLong(request.get("patId")));
          setFacilityCd(request.get("facilityCd"));
          setCategoryCd(categoryCd);
          setIsNewest("0");
          setUpDate(regDt);
        }
      };
      patEventDao.updateIsNewest(upPatEvent);
      // 患者イベントに指示変更を登録
      PatEvent newPatEvent = new PatEvent() {
        {
          setPatEventCd(newPatEventCd);
          setPatId(Long.parseLong(request.get("patId")));
          setFacilityCd(request.get("facilityCd"));
          setCategoryCd(categoryCd);
          setCategoryName(categoryName);
          Date date = new Date(regDt.getTime());
          SimpleDateFormat format = new SimpleDateFormat("yyyyMMdd");
          setEventStartDate(format.format(date));
          setUseType(0);
//          setIsVa("0");
//          setIsObserve("0");
          setRegStaffInfo("{\"reg_staff_cd\": null, \"reg_staff_name\": null}");
          setUpStaffInfo("{\"up_staff_cd\": null, \"up_staff_name\": null}");
          setIsNewest("1");
          setIsDel("0");
          setUpDate(regDt);
          setRegDate(regDt);
        }
      };
      patEventDao.insert(newPatEvent);
    }

    PatHhdPattern newPatHhdPattern = new PatHhdPattern() {
        {
          setPatId(Long.parseLong(request.get("patId")));
          setRevision(revision);
          setFacilityCd(request.get("facilityCd"));
          setIndTreatStartDate(request.get("indTreatStartDate"));
          if(!request.get("indTreatmentCd").isEmpty())setIndTreatmentCd(Integer.parseInt(request.get("indTreatmentCd")));
          if(!request.get("bedCd").isEmpty())setBedCd(Long.parseLong(request.get("bedCd")));
          if(!request.get("machineNo").isEmpty())setMachineNo(Long.parseLong(request.get("machineNo")));
          setIndCondInfo(request.get("indCondInfo"));
          setIndMediInfo(request.get("indMediInfo"));
          setUpDate(regDt);
          setRegDate(regDt);
        }
    };

    int result = patHhdPatternDao.insertPatHhdPattern(newPatHhdPattern);

    return result;
  }


  /**
   * {@inheritDoc}
   */
  @Override
  public void registerPushNotification(Long patId) {
    //通知送信
    PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(patId);

    // 基本的情報を持った変換用JSONデータを作成
    JSONObject replaceData = new JSONObject();
    String facilityCd = patPersonalMain.getFacility_cd();
    replaceData.put("LASTNAME", patPersonalMain.getPat_last_name());
    replaceData.put("FIRSTNAME", patPersonalMain.getPat_first_name());
    replaceData.put("PATID", patId.toString());
    replaceData.put("FACILITYCD", facilityCd);
    try {
      webApiCallCommonUtil.registerNotification(NotificationDefinition.REGISTER_HOME_DIALYSIS_PAT, facilityCd, replaceData);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (!StringUtils.isEmpty(facilityCd)) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_FACILITY_HOME_DIALYSIS, SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang end
    }
  }
}
