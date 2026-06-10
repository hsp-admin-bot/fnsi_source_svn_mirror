package jp.co.nikkiso.ntss.admin_web.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.request.deviceEdgeOrder.DeviceEdgeOrderRequest;
import jp.co.nikkiso.ntss.admin_web.service.bloodPurify.MntMachineStateService;
import jp.co.nikkiso.ntss.admin_web.service.deviceEdgeOrder.DeviceEdgeOrderService;
import jp.co.nikkiso.ntss.admin_web.service.utils.MasterCacheHandler;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.PatTreatmentPatternUtils;
import jp.co.nikkiso.ntss.admin_web.web.rest.validation.ApiEntityDeviceSetInfo;
import jp.co.nikkiso.ntss.core.dao.MstDeviceSetInfoDefaultDao;
import jp.co.nikkiso.ntss.core.dao.MstTreatmentDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatNameIdentificationDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.PatUniqueDao;
import jp.co.nikkiso.ntss.core.entity.DeviceSetInfo;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.OrdMainEsListener;
import jp.co.nikkiso.ntss.core.entity.PatNameIdentification;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainForDeviceSetInfo;
import jp.co.nikkiso.ntss.core.utils.LiquidCalculateUtils;
import jp.co.nikkiso.ntss.core.utils.TriggerUtil;
import org.json.JSONArray;
import org.json.JSONObject;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.util.StringUtils;
import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
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

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Service
public class DeviceSetInfoService {
  @Autowired
  private MstDeviceSetInfoDefaultDao mstDeviceSetInfoDefaultDao;
  @Autowired
  private PatMainDao patMainDao;
  @Autowired
  private OrdMainDao ordMainDao;
  //    add 7074 2022-12-02 設定していないホスト報知が通知される 張 start
  /* add by KongShuai  2023-02-01 CodeOptimization start */
  @Autowired
  private MstTreatmentDao mstTreatmentDao;
  @Autowired
  private PatNameIdentificationDao patNameIdentificationDao;
  @Autowired
  private PatUniqueDao patUniqueDao;

  @Autowired
  private PatPersonalMainDao patPersonalMainDao;
  /* add by KongShuai  2023-02-01 CodeOptimization end */
  @Autowired
  private DeviceEdgeOrderService deviceEdgeOrderService;
  @Autowired
  private MntMachineStateService mntMachineStateService;
  //    add 7074 2022-12-02 設定していないホスト報知が通知される 張 start

  /* add by KongShuai  2023-02-01 CodeOptimization start */
  @Autowired
  private PatTreatmentPatternUtils patTreatmentPatternUtils;
  /* add by KongShuai  2023-02-01 CodeOptimization end */
  /**
   * ロギングのServiceインタフェース.
   */
  @Autowired
  private LogService logService;

  // add FNSI-改修内容追加OrdMain履歴 付 start
  @Autowired
  private SelectHistoryUtils selectHistoryUtils;
  // add FNSI-改修内容追加OrdMain履歴 付 end

  // DB更新ログ出力ロジック wangzuo Start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Autowired
  private LogServiceCore logServiceCore;
  // DB更新ログ出力ロジック wangzuo End

  @Autowired
  private TriggerUtil triggerUtil;

  @Autowired
  private AsyncService asyncService;

  /* add #9355  by zhangruixue 2023-09-06 --start */
  @Autowired
  private IndHistoryMakeService indHistoryMakeService;
  /* add #9355  by zhangruixue 2023-09-06 --end */

  /**
   * 装置設定(マスタ)取得
   *
   * @param facility_cd
   * @return 装置設定JSON
   */
  public String getDeviceSetInfoMst(String facility_cd) throws Exception {
    return mstDeviceSetInfoDefaultDao.selectDeviceSetInfo(facility_cd);
  }

  // add #11166 予定が新規登録すると、device_set_infoの中で1001と1002のkeyが必要がない、取得SQLを新規する zkm start
  /**
   * 装置設定(マスタ)取得
   *   device_set_infoの中で1001と1002のkeyが除外する
   *
   * @param facility_cd
   * @return 装置設定JSON
   */
  public String getDeviceSetInfoMstWithoutTmpZero(String facility_cd) {
    return mstDeviceSetInfoDefaultDao.selectDeviceSetInfoWithoutTmpZero(facility_cd);
  }
  // add #11166 予定が新規登録すると、device_set_infoの中で1001と1002のkeyが必要がない、取得SQLを新規する zkm end

  /**
   * 装置設定(患者情報)取得
   *
   * @param pat_id
   * @return 装置設定JSON
   */
  public String getDeviceSetInfoPat(Long pat_id) throws Exception {
    return patMainDao.selectDeviceSetInfo(pat_id);
  }

  /**
   * #12462 患者情報共有 zrx
   * add 装置設定(患者情報)取得
   *
   * @param pat_id id
   * @param facility_cd code
   * @return 装置設定JSON
   */
  public String getDeviceSetInfoPat(Long pat_id,String facility_cd) throws Exception {
    String pat_id_name = patUniqueDao.selectFacilityCdById(pat_id);
    if(!facility_cd.equals(pat_id_name)) {
      List<PatNameIdentification> listPatIdSrcFromPatDstAndId = patNameIdentificationDao.getListPatIdSrcFromPatDstAndId(pat_id, facility_cd);
      pat_id = listPatIdSrcFromPatDstAndId.stream().findFirst().orElse(new PatNameIdentification()).getPatIdSrc();
    }
    return patMainDao.selectDeviceSetInfo(pat_id);
  }

  /**
   * 装置設定(指示)取得
   *
   * @param ord_no
   * @return 装置設定JSON
   */
  public String getDeviceSetInfoOrd(Long ord_no) throws Exception {
    return ordMainDao.selectDeviceSetInfo(ord_no);
  }

  /* add by chamaojia 2023-03-07 [6118] 一括クエリー方法の追加  --start */
  /**
   * 装置設定(指示)取得(バッチ)
   *
   * @param ordNoList
   * @return 装置設定JSON
   */
  public List<OrdMainForDeviceSetInfo> getDeviceSetInfoOrds(List<Long> ordNoList) throws Exception {
    return ordMainDao.selectDeviceSetInfos(ordNoList);
  }
  /* add by chamaojia 2023-03-07 [6118] 一括クエリー方法の追加  --end */

  /**
   * 装置設定(マスタ)更新
   *
   * @param facility_cd
   * @param deviceSetInfoJson 装置設定JSON
   */
  @Transactional
  public void updateDeviceSetInfoMst(String facility_cd, String deviceSetInfoJson) {
    // DB更新ログ出力ロジック xie Start
    boolean setResult = false;
    DataUpdateLogCommonNew logCommon = null;
    try {
      String tableName = "mst_device_set_info_default";
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" facility_cd = '" + facility_cd + "'\n");
      // logCommon設定
      logCommon = getLogCommon(mstDeviceSetInfoDefaultDao, tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      setResult = logCommon.setInfo();
    } catch(Exception e) {
      setResult = false;
    }
    // DB更新ログ出力ロジック xie End
    int updateCount = mstDeviceSetInfoDefaultDao.updateDeviceSetInfo(facility_cd, deviceSetInfoJson);
    // DB更新ログ出力ロジック xie Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      logCommon.updateLog();
    }
    // DB更新ログ出力ロジック xie End
    return;
  }

  /**
   * 装置設定(患者情報)更新
   *
   * @param pat_id
   * @param deviceSetInfoJson 装置設定JSON
   */
  @Transactional
  public void updateDeviceSetInfoPat(Long patId, String facilityCd, String deviceSetInfoJson) {
    // DB更新ログ出力ロジック xie Start
    boolean setResult = false;
    DataUpdateLogCommonNew logCommon = null;
    try {
      String tableName = "pat_main";
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" pat_id = '" + patId + "' and \n");
      wheres.append(" facility_cd = '" + facilityCd + "' \n");
      // logCommon設定
      logCommon = getLogCommon(patMainDao, tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      setResult = logCommon.setInfo();
    } catch(Exception e) {
      setResult = false;
    }
    // DB更新ログ出力ロジック xie End
    int updateCount = patMainDao.updateDeviceSetInfo(patId, facilityCd, deviceSetInfoJson);

    // DB更新ログ出力ロジック xie Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      logCommon.updateLog();
    }
    // DB更新ログ出力ロジック xie End
    return;
  }

  /**
   * 装置設定(指示)更新
   *
   * @param ord_no            オーダー番号
   * @param deviceSetInfoJson 装置設定JSON
   */
  @Transactional
  public int updateDeviceSetInfoOrd(Long ord_no, String deviceSetInfoJson) {

    // add FNSI-改修内容追加OrdMain履歴 付 start
    getHistory(ord_no);
    // mangoDb-updateDeviceSetInfo-insertSuccess
    // add FNSI-改修内容追加OrdMain履歴 付 end

    // DB更新ログ出力ロジック xie Start
    boolean setResult = false;
    DataUpdateLogCommonNew logCommon = null;
    try {
      String tableName = "ord_main";
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" ord_no = " + ord_no + " \n");
      // logCommon設定
      logCommon = getLogCommon(ordMainDao, tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      setResult = logCommon.setInfo();
    } catch(Exception e) {
      setResult = false;
    }
    // DB更新ログ出力ロジック xie End
    OrdMain oldOrdMain = ordMainDao.selectByOrdNo(ord_no);
    int updateCount = ordMainDao.updateDeviceSetInfo(ord_no, deviceSetInfoJson);
    OrdMain newOrdMain = ordMainDao.selectByOrdNo(ord_no);
    triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain),
      Collections.singletonList(newOrdMain));

    // DB更新ログ出力ロジック xie Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      logCommon.updateLog();
    }
    // DB更新ログ出力ロジック xie End
    return updateCount;
  }


  //add by ztc 2023-02-27 [Optimize runtime No.5482] --start
  /**
   * 装置設定(指示)更新
   *
   * @param deviceSetInfoOrdVoList オーダー番号 装置設定JSON
   */
  @Transactional
  public int updateDeviceSetInfoOrdList(List<OrdMainEsListener> deviceSetInfoOrdVoList) {
    List<Long> ordNoList = deviceSetInfoOrdVoList.stream().map(OrdMainEsListener::getOrdNo).collect(Collectors.toList());
    // add FNSI-改修内容追加OrdMain履歴 付 start
    getHistoryList(ordNoList);
    // mangoDb-updateDeviceSetInfo-insertSuccess
    // add FNSI-改修内容追加OrdMain履歴 付 end

    // DB更新ログ出力ロジック xie Start
    boolean setResult = false;
    DataUpdateLogCommonNew logCommon = null;
    try {
      String tableName = "ord_main";
      // SQL検索条件
      //upd by ztc 2023-03-14 [Batch modify data, log_event table has no data] --start /
      StringBuffer wheres = new StringBuffer("");
      String inStr = getInStr("ord_no in ", ordNoList);
      wheres.append(" WHERE\n");
      wheres.append(inStr + "\n");
      //upd by ztc 2023-03-14 [Batch modify data, log_event table has no data] --end /
      // logCommon設定
      logCommon = getLogCommon(ordMainDao, tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      setResult = logCommon.setInfo();
    } catch(Exception e) {
      setResult = false;
    }
    // DB更新ログ出力ロジック xie End
    List<OrdMain> oldOrdMain = ordMainDao.selectListByOrdNo(ordNoList);
    int updateCount = ordMainDao.updateDeviceSetInfoList(deviceSetInfoOrdVoList);
    List<OrdMain> newOrdMain = ordMainDao.selectListByOrdNo(ordNoList);

    // add #10150 装置プログラムのI-HDF設定を変更する場合、ord_mainの治療条件の補液量(key:20)と補液速度(key:24)を再計算する zkm start
    String indDeviceSetInfo = deviceSetInfoOrdVoList.get(0).getIndDeviceSetInfo();
    if (!StringUtils.isEmpty(indDeviceSetInfo) && new JSONObject(indDeviceSetInfo).has("ihdf")) {
      List<OrdMain> ihdfLiquidAmoutAndSpeedOrdMainList = newOrdMain.stream()
        .map(ord -> {
          if (StringUtils.isEmpty(ord.getIndCondInfo())) {
            return ord;
          }
          JSONObject condInfo = new JSONObject(ord.getIndCondInfo());
          String treatTimeStr = condInfo.getJSONObject("1").getString("value");
          Map<String, String> liquidAmoutAndSpeed = LiquidCalculateUtils.getIhdfCalculateLiquidAmoutAndSpeed(new JSONObject(ord.getIndDeviceSetInfo()), StringUtils.isEmpty(treatTimeStr) ? null : treatTimeStr);
          JSONObject updObj = new JSONObject();
          liquidAmoutAndSpeed.forEach((k, v) -> {
            if (condInfo.has(k)) {
                JSONObject jsonObj = condInfo.getJSONObject(k);
                jsonObj.put("value", v);
                updObj.put(k, jsonObj);
            }
          });
          ord.setIndCondInfo(updObj.toString());
          return ord;
        }).toList();
      ordMainDao.updateCondWithDeviceIhdf(ihdfLiquidAmoutAndSpeedOrdMainList);
      newOrdMain = ordMainDao.selectListByOrdNo(ordNoList);
    }
    // add #10150 装置プログラムのI-HDF設定を変更する場合、ord_mainの治療条件の補液量(key:20)と補液速度(key:24)を再計算する zkm end

    triggerUtil.updateTriggerOrdMain(oldOrdMain, newOrdMain);

    // DB更新ログ出力ロジック xie Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --start */
      logCommon.setAfterResults();
//      logCommon.updateLog();
      asyncService.updateLog(logCommon);
      /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --end */
    }
    // DB更新ログ出力ロジック xie End
    return updateCount;
  }
  //add by ztc 2023-02-27 [Optimize runtime No.5482] --end

  /**
   * 装置設定データ取得処理
   *
   * @param table_flag
   * @param facility_cd
   * @param screen_key
   * @param pat_id
   * @param ord_no
   * @param start_date
   * @param end_date
   * @param week
   * @param treat_method
   * @param kur_cd
   * @return 抽出条件を満たした装置設定情報
   * @throws 指定したテーブルのレコードが存在しないときはエラーをなげる
   */
  @Transactional
  public List<String> selectDeviceInfo(int table_flag, String facility_cd, String screen_key, Long pat_id, Long ord_no, String start_date, String end_date, List<Integer> week, List<Integer> treat_method, List<Integer> kur_cd) throws Exception {
    //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("tabla_flag: " + table_flag);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end
    String first_key = null;
    String second_key = null;
    // 各テーブルのレコードオブジェクトをシリアライズし、テーブル名をキーとする連想配列にマッピング
    List<String> payload = new ArrayList<String>();
    ObjectMapper mapper = new ObjectMapper();
    if (table_flag == 0) {
      if (screen_key == null) {
        first_key = null;
      } else if (screen_key.equals("ufr") || screen_key.equals("na") || screen_key.equals("dc") || screen_key.equals("qbqd") || screen_key.equals("ihdf") || screen_key.equals("bvufc") || screen_key.equals("dia")) {
        // 指示系の画面キー
        first_key = "ord";
        second_key = screen_key;
      } else {
        // 患者系の画面キー
        first_key = "pat";
        second_key = screen_key;
      }
    } else {
      second_key = screen_key;
    }
    //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
    eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("first_key: " + first_key);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("second_key: " + second_key);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end
    if (table_flag == 0) {
      // 対象のmst_device_set_info_default抽出
      List<DeviceSetInfo> listSysFacility = mstDeviceSetInfoDefaultDao.selectDeviceInfo(facility_cd, first_key, second_key);
      if (listSysFacility.size() == 0) {
        //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
        //EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage = new EventLogMessage();
        //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end
        eventLogMessage.setLogMessage("装置設定API: 指定された引数でのmst_device_set_info_defaultレコードが存在しません。(facility_cd: " + facility_cd + ", 画面キー:" + second_key + ")");
        eventLogMessage.setPatId(pat_id.toString());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, "MstDeviceSetInfoDefaultDao/selectDeviceInfo");
        throw new Exception();
      }
      payload.add(mapper.writeValueAsString(listSysFacility));
    } else if (table_flag == 1) {
      //対象のpat_main取得
      List<DeviceSetInfo> listPatMain = patMainDao.selectDeviceInfo(pat_id, second_key);
      if (listPatMain.size() == 0) {
        //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
        //EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage = new EventLogMessage();
        //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end
        eventLogMessage.setLogMessage("装置設定API: 指定された引数でのpat_mainレコードが存在しません。(pat_id: " + pat_id + ", 画面キー:" + second_key + ")");
        eventLogMessage.setPatId(pat_id.toString());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, "PatMainDao/selectDeviceInfo");
        throw new Exception();
      }
      payload.add(mapper.writeValueAsString(listPatMain));
    } else if (table_flag == 2) {
      //対象のord_main(指示)を取得
      List<DeviceSetInfo> listOrdMain = ordMainDao.selectDeviceInfo(ord_no, facility_cd, pat_id, start_date, end_date, week, treat_method, kur_cd, second_key);
      if (listOrdMain.size() == 0) {
        //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
        //EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage = new EventLogMessage();
        //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end
        eventLogMessage.setLogMessage("装置設定API: 指定された引数のord_main(指示)レコードが存在しません。(ord_no: " + ord_no + ", facility_cd:" + facility_cd +
          ", pat_id:" + pat_id + ", start_date:" + start_date + ", end_date:" + end_date + ", week:" + week + ", treat_method:" + treat_method + ", kur_cd:" + kur_cd +
          ", 画面キー:" + second_key + ")");
        eventLogMessage.setPatId(pat_id.toString());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, "OrdMainDao/selectDeviceInfo");
        throw new Exception();
      }
      payload.add(mapper.writeValueAsString(listOrdMain));
    } else if (3 == table_flag) {
      // 対象のordMain(実績)を取得
      List<DeviceSetInfo> listResOrdMain = ordMainDao.selectRstDeveiceInfo(ord_no, facility_cd, pat_id, start_date, end_date, week, treat_method, kur_cd, second_key);
      if (0 == listResOrdMain.size()) {
        //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
        //EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage = new EventLogMessage();
        //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end
        eventLogMessage.setLogMessage("装置設定API: 指定された引数のord_main(実績)レコードが存在しません。(ord_no: " + ord_no + ", facility_cd:" + facility_cd +
          ", pat_id:" + pat_id + ", start_date:" + start_date + ", end_date:" + end_date + ", week:" + week + ", treat_method:" + treat_method + ", kur_cd:" + kur_cd +
          ", 画面キー:" + second_key + ")");
        eventLogMessage.setPatId(pat_id.toString());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, "OrdMainDao/selectRstDeveiceInfo");
        throw new Exception();
      }
      payload.add(mapper.writeValueAsString(listResOrdMain));
    }
    // 取得データを配列で渡す
    return payload;
  }

  /**
   * 風袋・除水データ取得
   *
   * @param pat_id
   * @return 抽出条件を満たした風袋・除水補正情報
   * @throws 指定したテーブルのレコードが存在しないときはエラーをなげる
   */
  @Transactional
  public List<String> selectTareAndOffWater(String facility_cd, Long pat_id, Long ord_no, Integer flgIndRst) throws Exception {
    List<String> payload = new ArrayList<String>();
    ObjectMapper mapper = new ObjectMapper();

    // add #12462 患者情報共有 zrx start
    if(null!=facility_cd&&null!=pat_id) {
      String pat_id_name = patUniqueDao.selectFacilityCdById(pat_id);
      if(!facility_cd.equals(pat_id_name)) {
        List<PatNameIdentification> listPatIdSrcFromPatDstAndId = patNameIdentificationDao.getListPatIdSrcFromPatDstAndId(pat_id, facility_cd);
        pat_id = listPatIdSrcFromPatDstAndId.stream().findFirst().orElse(new PatNameIdentification()).getPatIdSrc();
      }
      facility_cd=null;
    }
    // add 患者共有patid置換 #12462 患者情報共有 zrx end

    // 装置設定デフォルトマスタ
    if (null != facility_cd) {
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("装置設定デフォルトマスタ");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end
      List<DeviceSetInfo> listPatMain = mstDeviceSetInfoDefaultDao.selectTareAndOffWater(facility_cd);
      if (listPatMain.size() == 0) {
        //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
        //EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage = new EventLogMessage();
        //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end
        eventLogMessage.setLogMessage("装置設定(風袋・除水補正)API: 指定されたfacility_cdのmst_device_set_info_defaultレコードが存在しません。(facility_cd: " + facility_cd + ")");
        if(pat_id != null){
          eventLogMessage.setPatId(pat_id.toString());
        }
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, "MstDeviceSetInfoDefaultDao/selectTareAndOffWater");
        throw new Exception();
      } else {
        payload.add(mapper.writeValueAsString(listPatMain.get(0)));
      }
    }

    // 患者情報
    if (null != pat_id) {
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("患者情報");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end
      List<DeviceSetInfo> listPatMain = patMainDao.selectTareAndOffWater(pat_id);
      if (listPatMain.size() == 0) {
        //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
        //EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage = new EventLogMessage();
        //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end
        eventLogMessage.setLogMessage("装置設定(風袋・除水補正)API: 指定されたpat_idのpat_mainレコードが存在しません。(pat_id: " + pat_id + ")");
        eventLogMessage.setPatId(pat_id.toString());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, "PatMainDao/selectTareAndOffWater");
        throw new Exception();
      } else {
        payload.add(mapper.writeValueAsString(listPatMain.get(0)));
      }
    }

    // 治療情報
    if (null != ord_no) {
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("治療情報");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end
      List<DeviceSetInfo> listOrdMain = ordMainDao.selectTareAndOffWater(ord_no, flgIndRst);
      if (listOrdMain.size() == 0) {
        //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
        //EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage = new EventLogMessage();
        //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end
        eventLogMessage.setLogMessage("装置設定(風袋・除水補正)API: 指定されたord_noのord_mainレコードが存在しません。(ord_no: " + ord_no + ")");
        eventLogMessage.setPatId(pat_id.toString());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, "OrdMainDao/selectTareAndOffWater");
        throw new Exception();
      } else {
        payload.add(mapper.writeValueAsString(listOrdMain.get(0)));
      }
    }

//     if (table_flag == 0) {
//       // 患者情報テーブルの風袋・除水データの取得
//       List<DeviceSetInfo> listPatMain = patMainDao.selectTareAndOffWater(id);
//       if (listPatMain.size() == 0) {
//         NtssLogger.LogOutput(this, LogLevel.ERROR, "装置設定(風袋・除水補正)API: 指定されたpat_idのpat_mainレコードが存在しません。(pat_id: " + id + ")");
//         throw new Exception();
//       } else {
//         payload.add(mapper.writeValueAsString(listPatMain.get(0)));
//       }
//     } else {
//       // 治療情報テーブルの風袋・除水データの取得
//       List<DeviceSetInfo> listOrdMain = ordMainDao.selectTareAndOffWater(id);
//       if (listOrdMain.size() == 0) {
//         NtssLogger.LogOutput(this, LogLevel.ERROR, "装置設定(風袋・除水補正)API: 指定されたord_noのord_mainレコードが存在しません。(ord_no: " + id + ")");
//         throw new Exception();
//       } else {
//         payload.add(mapper.writeValueAsString(listOrdMain.get(0)));
//       }
//     }
    return payload;
  }


  /**
   * 風袋・除水データの更新対象取得
   */
  @Transactional
  public List<String> selectTareAndOffWaterByWeek(Long pat_id, String fromDate, String toDate) throws Exception {
    List<String> payload = new ArrayList<String>();
    ObjectMapper mapper = new ObjectMapper();
    List<DeviceSetInfo> listOrdMain = ordMainDao.selectTareAndOffWaterByWeek(pat_id, fromDate, toDate);
    if (listOrdMain.size() == 0) {
      payload.add(mapper.writeValueAsString(null));
    } else {
      payload.add(mapper.writeValueAsString(listOrdMain));
    }
    return payload;
  }


  /**
   * ホスト報知データ取得
   * @param facility_cd
   * @param pat_id
   * @return 抽出条件を満たしたホスト報知情報
   * @throws 指定したテーブルのレコードが存在しないときはエラーをなげる
   */
  @Transactional
  public List<String> selectHostNotice(String facility_cd, Long pat_id) throws Exception {
    List<String> payload = new ArrayList<String>();
    ObjectMapper mapper = new ObjectMapper();
// add 患者共有patid置換 #12462 患者情報共有 zrx start
    if(null!=facility_cd&&null!=pat_id) {
      String pat_id_name = patUniqueDao.selectFacilityCdById(pat_id);
      if(!facility_cd.equals(pat_id_name)) {
        List<PatNameIdentification> listPatIdSrcFromPatDstAndId = patNameIdentificationDao.getListPatIdSrcFromPatDstAndId(pat_id, facility_cd);
        pat_id = listPatIdSrcFromPatDstAndId.stream().findFirst().orElse(new PatNameIdentification()).getPatIdSrc();
      }
      facility_cd=null;
    }
    // add 患者共有patid置換 #12462 患者情報共有 zrx end

    // 装置設定デフォルトマスタ
    if (null != facility_cd) {
      String hostNotification = mstDeviceSetInfoDefaultDao.selectHostNoticeByFacilityCd(facility_cd);
      if (StringUtils.isEmpty(hostNotification)) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("装置設定(ホスト報知)API: 指定されたfacility_cdのmst_device_set_info_defaultレコードが存在しません。(facility_cd: " + facility_cd + ")");
        logService.log(LogLevel.ERROR, eventLogMessage,null, SERVICE_NAME.FNSI, "MstDeviceSetInfoDefaultDao/selectHostNotice");
        throw new Exception();
      } else {
        payload.add(mapper.writeValueAsString(hostNotification));
      }
    }

    // 患者情報
    if (null != pat_id) {
      String hostNotification = patMainDao.selectHostNotificationById(pat_id);
      if (StringUtils.isEmpty(hostNotification)) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("装置設定(ホスト報知)API: 指定されたpat_idのpat_mainレコードが存在しません。(pat_id: " + pat_id + ")");
        eventLogMessage.setPatId(pat_id.toString());
        logService.log(LogLevel.ERROR, eventLogMessage,null, SERVICE_NAME.FNSI, "PatMainDao/selectHostNotificationById");
        throw new Exception();
      } else {
        payload.add(mapper.writeValueAsString(hostNotification));
      }
    }

    return payload;
  }

  /**
   * 患者状況が「治療中」または「排液済み」でかつ、
   * 2日以上前の版が確定していない透析中以降の実績の抽出
   */
  @Transactional
  public List<String> selectDisableUpdate(Long pat_id, String from_date) throws Exception {
    List<String> payload = new ArrayList<String>();
    ObjectMapper mapper = new ObjectMapper();
    List<DeviceSetInfo> listOrdMain = ordMainDao.selectDisableUpdate(pat_id, from_date);
    if (listOrdMain.size() == 0) {
      payload.add(mapper.writeValueAsString(null));
    } else {
      payload.add(mapper.writeValueAsString(listOrdMain));
    }
    return payload;
  }


  /**
   * 装置設定データ更新処理
   *
   * @param table_flag
   * @param facility_cd
   * @param pat_id
   * @param ord_no
   * @param start_date
   * @param end_date
   * @param week
   * @param treat_method
   * @param kur_cd
   * @param device_info
   * @return updateCount
   */
  @Transactional
  public int updateDeviceInfo(int table_flag, String facility_cd, Long pat_id, Long ord_no, String start_date, String end_date, List<Integer> week, List<Integer> treat_method, List<Integer> kur_cd, String device_info) {
    int updateCount = 0;
    if (0 == table_flag) {
      // mst_device_set_info_defaultテーブルの更新処理
      // DB更新ログ出力ロジック xie Start
      boolean setResult = false;
      DataUpdateLogCommonNew logCommon = null;
      try {
        String tableName = "mst_device_set_info_default";
        // SQL検索条件
        StringBuffer wheres = new StringBuffer("");
        wheres.append(" WHERE\n");
        wheres.append(" facility_cd = '" + facility_cd + "'\n");
        // logCommon設定
        logCommon = getLogCommon(mstDeviceSetInfoDefaultDao, tableName, wheres, getEventLogMessage());
        // ログ出力カラム情報及び更新前データ情報取得
        setResult = logCommon.setInfo();
      } catch(Exception e) {
        setResult = false;
      }
      // DB更新ログ出力ロジック xie End
      updateCount = mstDeviceSetInfoDefaultDao.updateDeviceInfo(facility_cd, device_info);
      // DB更新ログ出力ロジック xie Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && updateCount > 0) {
        logCommon.updateLog();
      }
      // DB更新ログ出力ロジック xie End
    } else if (1 == table_flag) {
      // pat_mainテーブルの更新処理
      // DB更新ログ出力ロジック xie Start
      boolean setResult = false;
      DataUpdateLogCommonNew logCommon = null;
      try {
        String tableName = "pat_main";
        // SQL検索条件
        StringBuffer wheres = new StringBuffer("");
        wheres.append(" WHERE\n");
        wheres.append(" pat_id = '" + pat_id + "' and \n");
        wheres.append(" facility_cd = '" + facility_cd + "'\n");
        // logCommon設定
        logCommon = getLogCommon(patMainDao, tableName, wheres, getEventLogMessage());
        // ログ出力カラム情報及び更新前データ情報取得
        setResult = logCommon.setInfo();
      } catch(Exception e) {
        setResult = false;
      }
      // DB更新ログ出力ロジック xie End
      updateCount = patMainDao.updateDeviceInfo(pat_id, facility_cd, device_info);

      // DB更新ログ出力ロジック xie Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && updateCount > 0) {
        logCommon.updateLog();
      }
      // DB更新ログ出力ロジック xie End
    } else if (2 == table_flag) {

      // add FNSI-改修内容追加OrdMain履歴 付 start
      List<Long> kurList = new ArrayList<>();
      for (Integer integer : kur_cd) {
        kurList.add(integer.longValue());
      }
      selectHistoryUtils.insertMangoDbHistory(11, ord_no, pat_id, new ArrayList<>(), new ArrayList<>(), facility_cd, null,
        null, start_date, end_date, week, treat_method, null, null, null,
        kurList, null, null);
      // mangoDb-updateDeviceInfo-insertSuccess
      // add FNSI-改修内容追加OrdMain履歴 付 end

      // ord_mainテーブルの更新処理(指示、実績)
      // DB更新ログ出力ロジック xie Start
      boolean setResult = false;
      DataUpdateLogCommonNew logCommon = null;
      try {
        String tableName = "ord_main";
        // SQL検索条件
        StringBuffer wheres = new StringBuffer("");
        wheres.append(" WHERE\n");

        if (ord_no != null) {
          wheres.append(" ord_no = '" + ord_no + "' and \n");
        } else {
          wheres.append(" pat_id = " + pat_id + " and \n");
        }

        wheres.append(" facility_cd = '" + facility_cd + "' \n");
        if (!StringUtils.isEmpty(start_date)) {
          wheres.append(" and treat_date >= '" + start_date + "'  \n");
        }

        if (!StringUtils.isEmpty(end_date)) {
          wheres.append(" and treat_date <= '" + end_date + "'  \n");
        }

        if (week != null && week.size() > 0) {
          wheres.append(" and treat_week in (" + getIntegerValueStr(week) + ")  \n");
        }

        if (treat_method != null && treat_method.size() > 0) {
          wheres.append(" and ind_treatment_cd in (" + getIntegerValueStr(treat_method) + ")  \n");
        }

        if (kur_cd != null && kur_cd.size() > 0) {
          wheres.append(" and ind_kur_cd in (" + getIntegerValueStr(kur_cd) + ")  \n");
        }

        // logCommon設定
        logCommon = getLogCommon(ordMainDao, tableName, wheres, getEventLogMessage());
        // ログ出力カラム情報及び更新前データ情報取得
        setResult = logCommon.setInfo();
      } catch(Exception e) {
        setResult = false;
      }
      // DB更新ログ出力ロジック xie End

      List<OrdMain> oldOrdMains = ordMainDao.selectDeviceInfos(ord_no, facility_cd, pat_id, start_date, end_date, week, treat_method, kur_cd);
      updateCount = ordMainDao.updateDeviceInfo(ord_no, facility_cd, pat_id, start_date, end_date, week, treat_method, kur_cd, device_info);
      List<OrdMain> newOrdMains = ordMainDao.selectDeviceInfos(ord_no, facility_cd, pat_id, start_date, end_date, week, treat_method, kur_cd);
      triggerUtil.updateTriggerOrdMain(oldOrdMains, newOrdMains);

      // DB更新ログ出力ロジック xie Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && updateCount > 0) {
        logCommon.updateLog();
      }
      // DB更新ログ出力ロジック xie End
    } else if (3 == table_flag) {

      // add FNSI-改修内容追加OrdMain履歴 付 start
      List<Long> kurList = new ArrayList<>();
      for (Integer integer : kur_cd) {
        kurList.add(integer.longValue());
      }
      selectHistoryUtils.insertMangoDbHistory(8, ord_no, pat_id, new ArrayList<>(), new ArrayList<>(), facility_cd, null,
        null, start_date, end_date, week, treat_method, null, null, null,
        kurList, null, null);
      // mangoDb-updateRstDeviceSetInfo-insertSuccess
      // add FNSI-改修内容追加OrdMain履歴 付 end

      // ord_mainテーブルの更新処理(実績)
      // DB更新ログ出力ロジック xie Start
      boolean setResult = false;
      DataUpdateLogCommonNew logCommon = null;
      try {
        String tableName = "ord_main";
        // SQL検索条件
        StringBuffer wheres = new StringBuffer("");
        wheres.append(" WHERE\n");

        if (ord_no != null) {
          wheres.append(" ord_no = '" + ord_no + "' and \n");
        } else {
          wheres.append(" pat_id = " + pat_id + " and \n");
        }

        wheres.append(" facility_cd = '" + facility_cd + "' \n");
        if (!StringUtils.isEmpty(start_date)) {
          wheres.append(" and treat_date >= '" + start_date + "'  \n");
        }

        if (!StringUtils.isEmpty(end_date)) {
          wheres.append(" and treat_date <= '" + end_date + "'  \n");
        }

        if (week != null && week.size() > 0) {
          wheres.append(" and treat_week in (" + getIntegerValueStr(week) + ")  \n");
        }

        if (treat_method != null && treat_method.size() > 0) {
          wheres.append(" and ind_treatment_cd in (" + getIntegerValueStr(treat_method) + ")  \n");
        }

        if (kur_cd != null && kur_cd.size() > 0) {
          wheres.append(" and ind_kur_cd in (" + getIntegerValueStr(kur_cd) + ")  \n");
        }

        // logCommon設定
        logCommon = getLogCommon(ordMainDao, tableName, wheres, getEventLogMessage());
        // ログ出力カラム情報及び更新前データ情報取得
        setResult = logCommon.setInfo();
      } catch(Exception e) {
        setResult = false;
      }
      // DB更新ログ出力ロジック xie End
      List<OrdMain> oldOrdMains = ordMainDao.selectRstDeviceSetInfos(ord_no, facility_cd, pat_id, start_date, end_date, week, treat_method, kur_cd);
      updateCount = ordMainDao.updateRstDeviceSetInfo(ord_no, facility_cd, pat_id, start_date, end_date, week, treat_method, kur_cd, device_info);
      List<OrdMain> newOrdMains = ordMainDao.selectRstDeviceSetInfos(ord_no, facility_cd, pat_id, start_date, end_date, week, treat_method, kur_cd);
      triggerUtil.updateTriggerOrdMain(oldOrdMains, newOrdMains);

      // DB更新ログ出力ロジック xie Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && updateCount > 0) {
        logCommon.updateLog();
      }
      // DB更新ログ出力ロジック xie End
    }
    return updateCount;
  }


  /**
   * 風袋・除水補正初回更新(患者情報)
   */
  @Transactional
  public int updateStartTareAndOffWater(Long patId, String offWaterInfo, String tareInfo) {

    // DB更新ログ出力ロジック wangzuo Start
    String tableName = "pat_main";
    // SQL検索条件
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(" pat_id = " + patId + "\n");
    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(patMainDao, tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    // DB更新ログ出力ロジック wangzuo End

    int updateCount = patMainDao.updateStartTareAndOffWater(patId, offWaterInfo, tareInfo);

    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      logCommon.updateLog();
    }
    // DB更新ログ出力ロジック wangzuo End

    return updateCount;
  }


  /**
   * 風袋・除水補正初回更新(治療情報)
   */
  @Transactional
  public int updateIndStartTareAndOffWater(Long ordNo, String offWaterInfo, String tareInfo) {

    // add FNSI-改修内容追加OrdMain履歴 付 start
    getHistory(ordNo);
    // mangoDb-updateIndStartTareAndOffWater-insertSuccess
    // add FNSI-改修内容追加OrdMain履歴 付 end

    // DB更新ログ出力ロジック wangzuo Start
    String tableName = "ord_main";
    // SQL検索条件
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(" ord_no = " + ordNo + "\n");
    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(ordMainDao, tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    // DB更新ログ出力ロジック wangzuo End

    OrdMain oldOrdMain = ordMainDao.selectByOrdNo(ordNo);
    int updateCount = ordMainDao.updateIndStartTareAndOffWater(ordNo, offWaterInfo, tareInfo);
    OrdMain newOrdMain = ordMainDao.selectByOrdNo(ordNo);
    triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain),
      Collections.singletonList(newOrdMain));

    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      logCommon.updateLog();
    }
    // DB更新ログ出力ロジック wangzuo End

    return updateCount;
  }

  // add FNSI-改修内容追加OrdMain履歴 付 start
  private void getHistory(Long ordNo) {
    selectHistoryUtils.insertMangoDbHistory(1, ordNo, null, new ArrayList<>(), new ArrayList<>(), null, null,
      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
      new ArrayList<>(), null, null);
  }
  // add FNSI-改修内容追加OrdMain履歴 付 end

  //add by ztc 2023-02-23 [Optimize runtime No.5482] --start /
  private void getHistoryList(List<Long> ordNoList) {
    selectHistoryUtils.insertMangoDbHistory(1, null, null, ordNoList, new ArrayList<>(), null, null,
      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
      new ArrayList<>(), null, null);
  }
  //add by ztc 2023-02-23 [Optimize runtime No.5482] --end /

  /**
   * 除水即時コミット(患者情報)
   *
   * @param patId
   * @param offWaterInfo
   * @return
   */
  @Transactional
  public int immediateCommitOffWater(Long patId, String offWaterInfo) {
    int updateCount = patMainDao.immediateCommitRemovalWater(patId, offWaterInfo);
    return updateCount;
  }

  /**
   * 風袋即時コミット(患者情報)
   *
   * @param patId
   * @param tareInfo
   * @return
   */
  @Transactional
  public int immediateCommitTare(Long patId, String tareInfo) {
    int updateCount = patMainDao.immediateCommitTare(patId, tareInfo);
    return updateCount;
  }


  /**
   * 除水即時コミット(治療情報)
   *
   * @param ordNo
   * @param offWaterInfo
   * @return
   */
  @Transactional
  public int immediateCommitIndOffWater(Long OrdNo, String offWaterInfo) {

    // add FNSI-改修内容追加OrdMain履歴 付 start
    getHistory(OrdNo);
    // mangoDb-immediateCommitOffWater-insertSuccess
    // add FNSI-改修内容追加OrdMain履歴 付 end

    OrdMain oldOrdMain = ordMainDao.selectByOrdNo(OrdNo);
    int updateCount = ordMainDao.immediateCommitOffWater(OrdNo, offWaterInfo);
    OrdMain newOrdMain = ordMainDao.selectByOrdNo(OrdNo);
    triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain),
      Collections.singletonList(newOrdMain));
    return updateCount;
  }


  /**
   * 風袋即時コミット(治療情報)
   *
   * @param ordNo
   * @param tareInfo
   * @return
   */
  @Transactional
  public int immediateCommitIndTare(Long ordNo, String tareInfo) {

    // add FNSI-改修内容追加OrdMain履歴 付 start
    getHistory(ordNo);
    // mangoDb-immediateCommitTare-insertSuccess
    // add FNSI-改修内容追加OrdMain履歴 付 end

    OrdMain oldOrdMain = ordMainDao.selectByOrdNo(ordNo);
    int updateCount = ordMainDao.immediateCommitTare(ordNo, tareInfo);
    OrdMain newOrdMain = ordMainDao.selectByOrdNo(ordNo);
    triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain),
      Collections.singletonList(newOrdMain));
    return updateCount;
  }


  /**
   * 風袋・除水指示側への反映(前日もしくは本日治療中)
   *
   * @param ordNo(List型)
   * @param edition
   * @param is_del
   * @param weekday
   * @param jsonTareValue
   * @param jsonOffWaterValue
   * @return updateCount
   */
  @Transactional
  public int updateRstTareOffWaterInfo(
    Long ordNo,
    String tareInfo,
    String offWaterInfo,
    Timestamp upDate
  ) {

    // add FNSI-改修内容追加OrdMain履歴 付 start
    getHistory(ordNo);
    // mangoDb-updateRstTareOffWaterInfo-insertSuccess
    // add FNSI-改修内容追加OrdMain履歴 付 end

    // DB更新ログ出力ロジック xie Start
    boolean setResult = false;
    DataUpdateLogCommonNew logCommon = null;
    try {
      String tableName = "ord_main";
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" ord_no = " + ordNo + "\n");
      // logCommon設定
      logCommon = getLogCommon(ordMainDao, tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      setResult = logCommon.setInfo();
    } catch(Exception e) {
      setResult = false;
    }
    // DB更新ログ出力ロジック xie End
    OrdMain oldOrdMain = ordMainDao.selectByOrdNo(ordNo);
    int updateCount = ordMainDao.updateRstTareOffWaterInfo(ordNo, tareInfo, offWaterInfo, upDate);
    OrdMain newOrdMain = ordMainDao.selectByOrdNo(ordNo);
    triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain),
      Collections.singletonList(newOrdMain));
    // DB更新ログ出力ロジック xie Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      logCommon.updateLog();
    }
    // DB更新ログ出力ロジック xie End
    return updateCount;
  }

  /**
   * 風袋・除水補正更新(patMain)
   */
  @Transactional
  public int updateTareAndOffWater(
    String id,
    String tareInfo,
    String offWaterInfo,
    Integer tableFlag
  ) {
    int updateCount;
    if (0 == tableFlag) {
      // DB更新ログ出力ロジック xie Start
      boolean setResult = false;
      DataUpdateLogCommonNew logCommon = null;
      try {
        String tableName = "mst_device_set_info_default";
        // SQL検索条件
        StringBuffer wheres = new StringBuffer("");
        wheres.append(" WHERE\n");
        wheres.append(" facility_cd = '" + id + "'\n");
        // logCommon設定
        logCommon = getLogCommon(mstDeviceSetInfoDefaultDao, tableName, wheres, getEventLogMessage());
        // ログ出力カラム情報及び更新前データ情報取得
        setResult = logCommon.setInfo();
      } catch(Exception e) {
        setResult = false;
      }
      updateCount = mstDeviceSetInfoDefaultDao.updateTareAndOffWater(id, tareInfo, offWaterInfo);
      // DB更新ログ出力ロジック xie Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && updateCount > 0) {
        logCommon.updateLog();
      }
      // DB更新ログ出力ロジック xie End
    } else if (1 == tableFlag) {
      // DB更新ログ出力ロジック xie Start
      boolean setResult = false;
      DataUpdateLogCommonNew logCommon = null;
      try {
        String tableName = "pat_main";
        // SQL検索条件
        StringBuffer wheres = new StringBuffer("");
        wheres.append(" WHERE\n");
        wheres.append(" pat_id = " + id + "\n");
        // logCommon設定
        logCommon = getLogCommon(patMainDao, tableName, wheres, getEventLogMessage());
        // ログ出力カラム情報及び更新前データ情報取得
        setResult = logCommon.setInfo();
      } catch(Exception e) {
        setResult = false;
      }
      // DB更新ログ出力ロジック xie End
      updateCount = patMainDao.updateTareAndOffWater(Long.parseLong(id), tareInfo, offWaterInfo);
      // DB更新ログ出力ロジック xie Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && updateCount > 0) {
        logCommon.updateLog();
      }
      // DB更新ログ出力ロジック xie End
    } else {

      // add FNSI-改修内容追加OrdMain履歴 付 start
      getHistory(Long.parseLong(id));
      // mangoDb-updateTareAndOffWater-insertSuccess
      // add FNSI-改修内容追加OrdMain履歴 付 end

      // DB更新ログ出力ロジック xie Start
      boolean setResult = false;
      DataUpdateLogCommonNew logCommon = null;
      try {
        String tableName = "ord_main";
        // SQL検索条件
        StringBuffer wheres = new StringBuffer("");
        wheres.append(" WHERE\n");
        wheres.append(" ord_no = " + id + "\n");
        // logCommon設定
        logCommon = getLogCommon(ordMainDao, tableName, wheres, getEventLogMessage());
        // ログ出力カラム情報及び更新前データ情報取得
        setResult = logCommon.setInfo();
      } catch(Exception e) {
        setResult = false;
      }
      // DB更新ログ出力ロジック xie End
      OrdMain oldOrdMain = ordMainDao.selectByOrdNo(Long.parseLong(id));
      updateCount = ordMainDao.updateTareAndOffWater(Long.parseLong(id), tareInfo, offWaterInfo);
      OrdMain newOrdMain = ordMainDao.selectByOrdNo(Long.parseLong(id));
      triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain),
        Collections.singletonList(newOrdMain));
      // DB更新ログ出力ロジック xie Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && updateCount > 0) {
        logCommon.updateLog();
      }
      // DB更新ログ出力ロジック xie End
    }
    return updateCount;
  }

  /**
   * 装置設定デフォルトマスタ:風袋・除水補正更新
   *
   * @param facilityCd   施設コード
   * @param tareInfo     風袋情報
   * @param offWaterInfo 除水補正情報
   * @param upDate       更新日時
   */
  @Transactional
  public int updateSysTareOffWaterInfo(
    String facilityCd,
    String tareInfo,
    String offWaterInfo,
    Timestamp upDate
  ) {
    // DB更新ログ出力ロジック xie Start
    boolean setResult = false;
    DataUpdateLogCommonNew logCommon = null;
    try {
      String tableName = "mst_device_set_info_default";
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" facility_cd = '" + facilityCd + "'\n");
      // logCommon設定
      logCommon = getLogCommon(mstDeviceSetInfoDefaultDao, tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      setResult = logCommon.setInfo();
    } catch(Exception e) {
      setResult = false;
    }
    // DB更新ログ出力ロジック xie End
    int updateCount = mstDeviceSetInfoDefaultDao.updateSysTareOffWaterInfo(
      facilityCd,
      tareInfo,
      offWaterInfo,
      upDate
    );

    // DB更新ログ出力ロジック xie Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      logCommon.updateLog();
    }
    // DB更新ログ出力ロジック xie End
    return updateCount;
  }


  /**
   * 患者情報:風袋・除水補正更新
   *
   * @param patId        患者ID
   * @param tareInfo     風袋情報
   * @param offWaterInfo 除水補正情報
   * @param upDate       更新日時
   */
  @Transactional
  public int updatePatTareOffWaterInfo(
    Long patId,
    String facilityCd,
    String tareInfo,
    String offWaterInfo,
    Timestamp upDate
  ) {

    // DB更新ログ出力ロジック xie Start
    String tableName = "pat_main";
    // SQL検索条件
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    if (!StringUtils.isEmpty(patId)) {
      wheres.append(" pat_id = " + patId + "\n");
    }

    if (!StringUtils.isEmpty(facilityCd)) {
      wheres.append(" AND\n");
      wheres.append(" facility_cd = '" + facilityCd + "'\n");
    }

    boolean hasResult = false;
    DataUpdateLogCommonNew logCommon = null;
    try {
      // logCommon設定
      logCommon = getLogCommon(patMainDao, tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      hasResult = logCommon.setInfo();
    } catch (Exception e) {
      hasResult = false;
    }
    // DB更新ログ出力ロジック xie End

    int updateCount = patMainDao.updatePatTareOffWaterInfo(
      patId,
      facilityCd,
      tareInfo,
      offWaterInfo,
      upDate
    );

    // add bug 6660 性能の改善 修正 wang start
    // DB更新ログ出力ロジック xie Start
    // 更新後データ取得、差分あれば、log出力
    // if (hasResult && updateCount > 0) {
    //   logCommon.updateLog();
    // }
    // DB更新ログ出力ロジック xie End
    // add bug 6660 性能の改善 修正 wang end

    return updateCount;
  }

  /**
   * 指示:風袋・除水補正更新
   *
   * @param ordNo        オーダー番号
   * @param tareInfo     風袋情報
   * @param offWaterInfo 除水補正情報
   * @param upDate       更新日時
   */
  @Transactional
  public int updateIndTareOffWaterInfo(
    Long ordNo,
    String tareInfo,
    String offWaterInfo,
    Timestamp upDate
  ) {

    // add FNSI-改修内容追加OrdMain履歴 付 start
    getHistory(ordNo);
    // mangoDb-updateIndTareOffWaterInfo-insertSuccess
    // add FNSI-改修内容追加OrdMain履歴 付 end

    // DB更新ログ出力ロジック xie Start
    boolean setResult = false;
    DataUpdateLogCommonNew logCommon = null;
    try {
      String tableName = "ord_main";
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" ord_no = " + ordNo + "\n");
      // logCommon設定
      logCommon = getLogCommon(ordMainDao, tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      setResult = logCommon.setInfo();
    } catch(Exception e) {
      setResult = false;
    }
    // DB更新ログ出力ロジック xie End

    OrdMain oldOrdMain = ordMainDao.selectByOrdNo(ordNo);
    int updateCount = ordMainDao.updateIndTareOffWaterInfo(
      ordNo,
      tareInfo,
      offWaterInfo,
      upDate
    );
    OrdMain newOrdMain = ordMainDao.selectByOrdNo(ordNo);
    triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain),
      Collections.singletonList(newOrdMain));
    // DB更新ログ出力ロジック xie Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      logCommon.updateLog();
    }
    // DB更新ログ出力ロジック xie End
    return updateCount;
  }

  //add by ztc 2023-02-23 [Optimize runtime No.5482] --start /
  /**
   * 指示:風袋・除水補正更新
   *
   * @param ordNoList    オーダー番号
   * @param tareInfo     風袋情報
   * @param offWaterInfo 除水補正情報
   * @param upDate       更新日時
   */
  @Transactional
  public int updateIndTareOffWaterInfoList(
    List<Long> ordNoList,
    String tareInfo,
    String offWaterInfo,
    Timestamp upDate,
    // add 10196 by kangjie 20240124 start
    String indUser
    // add 10196 by kangjie 20240124 end
  ) {
    getHistoryList(ordNoList);
    boolean setResult = false;
    DataUpdateLogCommonNew logCommon = null;
    try {
      String tableName = "ord_main";
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      //upd by ztc 2023-03-14 [Batch modify data, log_event table has no data] --start /
      String inStr = getInStr("ord_no in ", ordNoList);
      wheres.append(" WHERE\n");
      wheres.append(inStr + "\n");
      //upd by ztc 2023-03-14 [Batch modify data, log_event table has no data] --end /
      // logCommon設定
      logCommon = getLogCommon(ordMainDao, tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      setResult = logCommon.setInfo();
    } catch(Exception e) {
      setResult = false;
    }

    //List<OrdMain> oldOrdMainList = ordMainDao.selectListByOrdNo(ordNoList); // del by shiyw 2023-03-16 Performance optimization : Simplify trigger processing logic
    int updateCount = ordMainDao.updateIndTareOffWaterInfoList(
      ordNoList,
      tareInfo,
      offWaterInfo
      // add 10196 by kangjie 20240124 start
      // del 11119 by kangjie 20241008 start
//      ,indUser
      // del 11119 by kangjie 20241008 end
      // add 10196 by kangjie 20240124 end
    );
    List<OrdMain> newOrdMainList = ordMainDao.selectListByOrdNo(ordNoList);
    // modify by shiyw 2023-03-16 Performance optimization : Simplify trigger processing logic --start
    // triggerUtil.updateTriggerOrdMain(oldOrdMainList, newOrdMainList);
    triggerUtil.insertTriggerOrdMain(newOrdMainList);
    // modify by shiyw 2023-03-16 Performance optimization : Simplify trigger processing logic --end
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --start */
      logCommon.setAfterResults();
//      logCommon.updateLog();
      asyncService.updateLog(logCommon);
      /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --end */
    }
    return updateCount;
  }
  //add by ztc 2023-02-23 [Optimize runtime No.5482] --end /


  //upd by ztc 2023-03-14 [Batch modify data, log_event table has no data] --start /
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
    inStr.append(" ( ");
    for (T obj : inList) {
      inStr.append(obj);
      inStr.append(" ,");
    }
    inStr.deleteCharAt(inStr.length() - 1);
    inStr.append(" ) ");
    return String.valueOf(inStr);
  }
  //upd by ztc 2023-03-14 [Batch modify data, log_event table has no data] --end /

  /**
   * 風袋・除水指示側への反映(今日含む未来日)
   * 患者情報更新時に指示にも変更内容を更新する
   *
   * @param patId        患者ID
   * @param treatDate    治療日
   * @param treatWeek    治療曜日
   * @param tareInfo     風袋情報
   * @param offWaterInfo 除水補正情報
   * @param upDate
   */
  @Transactional
  public int updateFutureIndTareAndOffWater(
    Long patId,
    String treatDate,
    Integer treatWeek,
    String tareInfo,
    String offWaterInfo,
    Timestamp upDate
  ) {

    // add FNSI-改修内容追加OrdMain履歴 付 start
    selectHistoryUtils.insertMangoDbHistory(12, null, patId, new ArrayList<>(), new ArrayList<>(), null, null,
      null, null, null, new ArrayList<>(), new ArrayList<>(), null, treatDate, treatWeek,
      new ArrayList<>(), null, null);
    // mangoDb-updateFutureIndTareAndOffWater-insertSuccess
    // add FNSI-改修内容追加OrdMain履歴 付 end

    // DB更新ログ出力ロジック wangzuo Start
    String tableName = "ord_main";
    // SQL検索条件
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(" pat_id = " + patId + "\n");
    wheres.append(" AND\n");
    wheres.append(" treat_date >= '" + treatDate + "'\n");
    wheres.append(" AND\n");
    wheres.append(" treat_week = " + treatWeek + "\n");
    wheres.append(" AND\n");
    wheres.append(" rst_dialysis_state = '0'" + "\n");

    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(ordMainDao, tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    // DB更新ログ出力ロジック wangzuo End

    List<OrdMain> oldOrdMains = ordMainDao.selectFutureIndTareAndOffWater(patId, treatDate, treatWeek);
    int updateCount = ordMainDao.updateFutureIndTareAndOffWater(
      patId,
      treatDate,
      treatWeek,
      tareInfo,
      offWaterInfo,
      upDate
    );
    List<OrdMain> newOrdMains = ordMainDao.selectFutureIndTareAndOffWater(patId, treatDate, treatWeek);
    triggerUtil.updateTriggerOrdMain(oldOrdMains, newOrdMains);

    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      logCommon.updateLog();
    }
    // DB更新ログ出力ロジック wangzuo End

    return updateCount;
  }

  /**
   * 装置設定デフォルトマスタ:ホスト報知更新
   * @param facilityCd 施設コード
   * @param hostNotificationInfo ホスト報知情報
   * @param upDate 更新日時
   */
  @Transactional
  public int updateSysHostNotificationInfo(
    String facilityCd,
    String hostNotificationInfo,
    Timestamp upDate
  ) {
    // DB更新ログ出力ロジック xie Start
    boolean setResult = false;
    DataUpdateLogCommonNew logCommon = null;
    try {
      String tableName = "mst_device_set_info_default";
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" facility_cd = '" + facilityCd + "'\n");
      // logCommon設定
      logCommon = getLogCommon(mstDeviceSetInfoDefaultDao, tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      setResult = logCommon.setInfo();
    } catch(Exception e) {
      setResult = false;
    }
    // DB更新ログ出力ロジック xie End
    int updateCount = mstDeviceSetInfoDefaultDao.updateSysHostNotificationInfo(
      facilityCd,
      hostNotificationInfo,
      upDate
    );
    // DB更新ログ出力ロジック xie Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      logCommon.updateLog();
    }
   // DB更新ログ出力ロジック xie End
    return updateCount;
  }

  /**
   * 患者情報:ホスト報知更新
   * @param patId 患者ID
   * @param facilityCd 施設コード
   * @param hostNotificationInfo ホスト報知情報
   * @param upDate 更新日時
   */
  @Transactional
  public int updatePatHostNotificationInfo(
    Long patId,
    String facilityCd,
    String hostNotificationInfo,
    Timestamp upDate
  ) {
    // DB更新ログ出力ロジック xie Start
    boolean setResult = false;
    DataUpdateLogCommonNew logCommon = null;
    try {
      String tableName = "pat_main";
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");

      if (patId != null) {
        wheres.append(" pat_id = " + patId + "\n");
      }

      if (!StringUtils.isEmpty(facilityCd)) {
        wheres.append(" and facility_cd = '" + facilityCd + "'\n");
      }

      // logCommon設定
      logCommon = getLogCommon(patMainDao, tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      setResult = logCommon.setInfo();
    } catch(Exception e) {
      setResult = false;
    }
    // DB更新ログ出力ロジック xie End
    /* mod #内部6474 by zhangruixue  --start */
    int updateCount = patMainDao.updatePatHostNotification(
      patId,
      facilityCd,
      hostNotificationInfo,
      upDate
    );
    // DB更新ログ出力ロジック xie Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      logCommon.updateLog();
    }
    /* mod #内部6474 by zhangruixue  --end */
//    add 7074 2022-12-02 設定していないホスト報知が通知される 張 start
    JSONObject hostNotificationInfoJson =new JSONObject(hostNotificationInfo);
    if ((hostNotificationInfoJson.has("bp_max")&&new JSONObject(hostNotificationInfoJson.get("bp_max").toString()).has("judge"))||
          (hostNotificationInfoJson.has("bp_min")&&new JSONObject(hostNotificationInfoJson.get("bp_min").toString()).has("judge"))||
          (hostNotificationInfoJson.has("bp_ave")&&new JSONObject(hostNotificationInfoJson.get("bp_ave").toString()).has("judge"))||
          (hostNotificationInfoJson.has("pulse")&&new JSONObject(hostNotificationInfoJson.get("pulse").toString()).has("judge"))||
          (hostNotificationInfoJson.has("blood_flow")&&new JSONObject(hostNotificationInfoJson.get("blood_flow").toString()).has("judge"))||
          (hostNotificationInfoJson.has("ip_speed")&&new JSONObject(hostNotificationInfoJson.get("ip_speed").toString()).has("judge"))||
          (hostNotificationInfoJson.has("ufr")&&new JSONObject(hostNotificationInfoJson.get("ufr").toString()).has("judge"))||
          (hostNotificationInfoJson.has("vp")&&new JSONObject(hostNotificationInfoJson.get("vp").toString()).has("judge"))||
          (hostNotificationInfoJson.has("ap")&&new JSONObject(hostNotificationInfoJson.get("ap").toString()).has("judge"))||
          (hostNotificationInfoJson.has("na_conc")&&new JSONObject(hostNotificationInfoJson.get("na_conc").toString()).has("judge"))||
          (hostNotificationInfoJson.has("dialys_temp")&&new JSONObject(hostNotificationInfoJson.get("dialys_temp").toString()).has("judge"))||
          (hostNotificationInfoJson.has("d_bv_roc")&&new JSONObject(hostNotificationInfoJson.get("d_bv_roc").toString()).has("judge"))||
          (hostNotificationInfoJson.has("ldqb")&&new JSONObject(hostNotificationInfoJson.get("ldqb").toString()).has("judge"))||
          (hostNotificationInfoJson.has("bpmi")&&new JSONObject(hostNotificationInfoJson.get("bpmi").toString()).has("judge"))||
          (hostNotificationInfoJson.has("care_i")&&new JSONObject(hostNotificationInfoJson.get("care_i").toString()).has("judge"))
    ){
      List<MntMachineState> list=mntMachineStateService.selectByPatId(patId);
      list.forEach(item->{
//        deviceEdgeOrderService.sendHostNotificationDefinition(facilityCd,Integer.valueOf(patId.toString()),null);
        DeviceEdgeOrderRequest dres = new DeviceEdgeOrderRequest();
        dres.setOrdNo(item.getOrdNo());
        dres.setFacilityCd(facilityCd);
        try{
        DeviceEdgeOrderRequest targetInfo = deviceEdgeOrderService.findMissingData(dres);
          deviceEdgeOrderService.sendHostNotificationDefinition(facilityCd,targetInfo.getDeviceEdgeNo(),targetInfo.getMachineNo(),targetInfo.getOrdNo());
      } catch (Exception e) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("There is no MstUser.");
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
        if (!StringUtils.isEmpty(facilityCd)) {
          eventLogMessage.setFacilityCd(facilityCd);
        }
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
        logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, SERVICE_NAME.REMS,
          null);
      }
      });
        }
    //    add 7074 2022-12-02 設定していないホスト報知が通知される 張 end
// DB更新ログ出力ロジック xie End
    // add #10210 帳票における患者情報の取得元について limingzhe start
    try{
      selectHistoryUtils.insertMongoPatHistoryInto(patId);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end

      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (!StringUtils.isEmpty(facilityCd)) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }
    // add #10210 帳票における患者情報の取得元について limingzhe end
    return updateCount;
  }

  // DB更新ログ出力ロジック wangzuo Start
  /**
   * ログ情報設定
   *
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
    eventLogMessage.setServiceName(LoggingConstant.MODULE_NAME.ADMIN_WEB + "," + SERVICE_NAME.FNSI);
    return eventLogMessage;
  }

  /**
   * ログ出力共通クラス設定、取得
   * @return logCommon ログ出力共通クラス
   */
  private DataUpdateLogCommonNew getLogCommon(Object dao, String tableName, StringBuffer whereStr, EventLogMessage eventLogMessage) {
    DataUpdateLogCommonNew logCommon = new DataUpdateLogCommonNew();
    logCommon.setEventLoggerFactory(eventLoggerFactory);
    logCommon.setLogServiceCore(logServiceCore);
    logCommon.setConfig(Config.get(dao));
    logCommon.setTableName(tableName);
    logCommon.setWhereStr(whereStr);
    logCommon.setCommonEventLogMessage(eventLogMessage);
    return logCommon;
  }
  // DB更新ログ出力ロジック wangzuo End

  // DB更新ログ出力ロジック xie Start

  /**
   * sqlパラメータ
   * @param list
   * @return
   */
  private static String getIntegerValueStr(List<Integer> list) {
    String str = "";
    for (int i = 0; i < list.size(); i++) {
      Integer value = list.get(i);
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

  /* add by KongShuai  2023-02-01 CodeOptimization start */
  public void updateDeviceSetInfo(List<Integer> tableList, String facility_cd, Long pat_id, Long ord_no, String start_date, String end_date, List<Integer> week, List<Integer> treat_method, List<Integer> kur_cd, String update_date) {
    for (int i = 0; i < tableList.size(); i++) {
      JSONObject jobj = new  JSONObject();
      // 更新データ
      String deviceInfo;
      if (tableList.size() == 2) {
        if (i == 0 && tableList.get(i) == 0) {
          if (tableList.get(i + 1) == 1) {
            jobj.put("pat", new JSONObject(update_date));
            deviceInfo = jobj.toString();
          } else {
            jobj.put("ord", new JSONObject(update_date));
            deviceInfo = jobj.toString();
          }
        } else {
          deviceInfo = update_date;
        }
      } else {
        if (tableList.get(i) == 0) {
          jobj.put("pat", new JSONObject(update_date));
          deviceInfo = jobj.toString();
        } else {
          deviceInfo = update_date;
        }
      }
      this.updateDeviceInfo(tableList.get(i), facility_cd, pat_id, ord_no, start_date, end_date, week, treat_method, kur_cd, deviceInfo);
    }
  }
  /* add by KongShuai  2023-02-01 CodeOptimization end */

  /* add by KongShuai  2023-02-01 CodeOptimization start */
  /**
   * 装置設定(指示)更新
   */
  /* mod #9355  by zhangruixue 2023-09-06 --start */
  public void updateDeviceSetInfoOrd(ApiEntityDeviceSetInfo.ValiDeviceSetInfo bodyData, String facilityCd, List<Integer> treatmentList,
                                     List<OrdMain> ordMain, JSONObject responseData, String imageFlg, JSONObject ordnewTmp,List<Integer> treatWeekList) throws Exception {
    /* mod #9355  by zhangruixue 2023-09-06 --end */
    String singleNeedle;
    List<MstTreatment> mstTreatList = treatmentList.stream().map(treatCd -> mstTreatmentDao.selectByCd(treatCd)).collect(Collectors.toList());
    //add 7809 濃度プログラムとNa注入プログラムを同時にONにしようとした際の動作不正 張 start
    Set<String> msglist = new HashSet<>();
    //add 7809 濃度プログラムとNa注入プログラムを同時にONにしようとした際の動作不正 張 start
    //add by ztc 2023-02-27 [Optimize runtime No.5482] --start
    List<OrdMainEsListener> deviceSetInfoOrdVoList = new LinkedList<>();
    //add by ztc 2023-02-27 [Optimize runtime No.5482] --start
    // add #11129 コンバート施設で除水プログラムを変更すると500エラーとなる dengshen start
    // del #11291 除水プログラムの編集でフリーズする 関 start
    //    JSONObject beforeUpdate = new JSONObject(bodyData.getInd_device_set_info());
    //    List<String> updateKeyLst = new ArrayList<>(beforeUpdate.keySet());
    // del #11291 除水プログラムの編集でフリーズする 関 end
    // add #11129 コンバート施設で除水プログラムを変更すると500エラーとなる dengshen end
    for (int i = 0; i < ordMain.size(); i++) {
      //add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 start
      // 治療情報を取得
      OrdMain ord= ordMain.get(i);
      // 治療情報を取得
      JSONObject indDeviceSetInfoDefault = new JSONObject();

      // 装置設定情報を取得(装置設定デフォルトマスタ)
      String bufDefault = this.getDeviceSetInfoOrd(ordMain.get(i).getOrdNo());
      indDeviceSetInfoDefault = (bufDefault == null || bufDefault.isEmpty()) ?
              new JSONObject() :
              new JSONObject(bufDefault);
      bodyData.setInd_device_set_info(ordnewTmp.toString());
      // add #11291 除水プログラムの編集でフリーズする 関 start
      List<String> updateKeyLst = new ArrayList<>(ordnewTmp.keySet());
      // add #11291 除水プログラムの編集でフリーズする 関 end
      // BV-UFC
      JSONObject ordnew = new JSONObject(bodyData.getInd_device_set_info());
      JSONObject bvufc = (!indDeviceSetInfoDefault.has("bvufc")) ? null : new JSONObject(indDeviceSetInfoDefault.get("bvufc").toString());
      JSONObject bvufcDev = (bvufc == null || !bvufc.has("dev")) ? null : new JSONObject(bvufc.get("dev").toString());
      JSONObject bvufcInfo = (bvufcDev == null || !bvufcDev.has("A")) ? null : new JSONObject(bvufcDev.get("A").toString());

      // 除水プログラム
      JSONObject ufr = (!indDeviceSetInfoDefault.has("ufr")) ? null : new JSONObject(indDeviceSetInfoDefault.get("ufr").toString());
      JSONObject ufrDev = (ufr == null || !ufr.has("dev")) ? null : new JSONObject(ufr.get("dev").toString());
      JSONObject ufrInfo = (ufrDev == null || !ufrDev.has("A")) ? null : new JSONObject(ufrDev.get("A").toString());
      // 透析液濃度プログラム
      JSONObject dc = (!indDeviceSetInfoDefault.has("dc")) ? null : new JSONObject(indDeviceSetInfoDefault.get("dc").toString());
      JSONObject dcDev = (dc == null || !dc.has("dev")) ? null : new JSONObject(dc.get("dev").toString());
      JSONObject dcInfo = (dcDev == null || !dcDev.has("A")) ? null : new JSONObject(dcDev.get("A").toString());
      // Ｎａ注入プログラム
      JSONObject na = (!indDeviceSetInfoDefault.has("na")) ? null : new JSONObject(indDeviceSetInfoDefault.get("na").toString());
      JSONObject naDev = (na == null || !na.has("dev")) ? null : new JSONObject(na.get("dev").toString());
      JSONObject naA = (naDev == null || !naDev.has("A")) ? null : new JSONObject(naDev.get("A").toString());
      // 血流量・透析液流量プログラム
      JSONObject qbqd = (!indDeviceSetInfoDefault.has("qbqd")) ? null : new JSONObject(indDeviceSetInfoDefault.get("qbqd").toString());
      JSONObject qbqdDev = (qbqd == null || !qbqd.has("dev")) ? null : new JSONObject(qbqd.get("dev").toString());
      JSONObject qbqdA = (qbqdDev == null || !qbqdDev.has("dev")) ? null : new JSONObject(qbqdDev.get("A").toString());
      //add 7809 濃度プログラムとNa注入プログラムを同時にONにしようとした際の動作不正 張 start
      if(mstTreatList.size()==0){
        SelectOptions selectOptions = SelectOptions.get();
        MstTreatment params = new MstTreatment();
        params.setFacilityCd(facilityCd);
        mstTreatList=mstTreatmentDao.selectAll(selectOptions,params);
      }
      //add 7809 濃度プログラムとNa注入プログラムを同時にONにしようとした際の動作不正 張 end
      for (MstTreatment mstTreat : mstTreatList) {
        if(mstTreat.getTreatmentCd().equals(ordMain.get(i).getIndTreatmentCd())){
          if ("2".equals(imageFlg)  && ((AdminWebConstant.Treatment.DeviceMode.HDF.equals(mstTreat.getDeviceMode()) ||
                  AdminWebConstant.Treatment.DeviceMode.HF.equals(mstTreat.getDeviceMode()) ||
                  AdminWebConstant.Treatment.DeviceMode.OHDF.equals(mstTreat.getDeviceMode()) ||
                  AdminWebConstant.Treatment.DeviceMode.OHF.equals(mstTreat.getDeviceMode()) ||
                  AdminWebConstant.Treatment.DeviceMode.AFBF.equals(mstTreat.getDeviceMode())))) {
            //HD/ECUMのECUMがある場合は切替をHDに強制変更。警告メッセージ
            //    0: "HD",  1: "ECUM"
            JSONObject ufrord =  (ordnew == null || !ordnew.has("ufr")) ? null : new JSONObject(ordnew.get("ufr").toString());
            JSONObject ufrordDev = (ufrord == null || !ufrord.has("dev")) ? null : new JSONObject(ufrord.get("dev").toString());
            JSONObject ufrordInfo = (ufrordDev == null || !ufrordDev.has("A")) ? null : new JSONObject(ufrordDev.get("A").toString());
            for (int j = 291; j <= 300; j++) {
              if (ufrordInfo != null && ufrordInfo.has(String.valueOf(j))) {
                if ("1".equals(ufrordInfo.get(String.valueOf(j)))) {
                  msglist.add("12000032");
                  indDeviceSetInfoDefault.put("ufr", ufr);
                  //7810 add 治療条件・装置設定変更時の動作不備（412.xlsx）張 start
                  ordnew.put("ufr",ufr);
                  // add #11291 除水プログラムの編集でフリーズする 関 start
                  updateKeyLst.remove("ufr");
                  // add #11291 除水プログラムの編集でフリーズする 関 end
                  //7810 add 治療条件・装置設定変更時の動作不備（412.xlsx）張 end
                  bodyData.setInd_device_set_info(indDeviceSetInfoDefault.toString());
                  break;
                }
              }
            }
          }
          if (!msglist.contains("12000032")) {
            if ("4".equals(imageFlg) && (AdminWebConstant.Treatment.DeviceMode.HD.equals(mstTreat.getDeviceMode()) ||
                    AdminWebConstant.Treatment.DeviceMode.ECUM.equals(mstTreat.getDeviceMode()) ||
                    AdminWebConstant.Treatment.DeviceMode.HDF.equals(mstTreat.getDeviceMode()) ||
                    AdminWebConstant.Treatment.DeviceMode.HF.equals(mstTreat.getDeviceMode()) ||
                    AdminWebConstant.Treatment.DeviceMode.OHDF.equals(mstTreat.getDeviceMode()) ||
                    AdminWebConstant.Treatment.DeviceMode.OHF.equals(mstTreat.getDeviceMode()) ||
                    AdminWebConstant.Treatment.DeviceMode.AFBF.equals(mstTreat.getDeviceMode()))) {
              if (ufrInfo != null && ufrInfo.has("290")) {
                if (!"0".equals(ufrInfo.get("290").toString())) {
                  //mod FNSI-7295 劉全航 start
                  JSONObject bvufcJson = new JSONObject(ordnew.get("bvufc").toString());
                  JSONObject devJson = new JSONObject(bvufcJson.get("dev").toString());
                  JSONObject aJSON = new JSONObject(devJson.get("A").toString());
                  if (!aJSON.get("196").equals("0")) {
                    msglist.add("12000041");
                    //mod 8053 患者経過総合ビューアにて除水プログラムとBV-UFCを両方入りに出来る 張 start
                  }

                  //mod 8053 患者経過総合ビューアにて除水プログラムとBV-UFCを両方入りに出来る 張 end
                  //mod FNSI-7295 劉全航 end
//                msglist.add("12000041");
                }
              }
            }
            if ("2".equals(imageFlg) && (AdminWebConstant.Treatment.DeviceMode.HD.equals(mstTreat.getDeviceMode()) ||
                    AdminWebConstant.Treatment.DeviceMode.ECUM.equals(mstTreat.getDeviceMode()) ||
                    AdminWebConstant.Treatment.DeviceMode.HDF.equals(mstTreat.getDeviceMode()) ||
                    AdminWebConstant.Treatment.DeviceMode.HF.equals(mstTreat.getDeviceMode()) ||
                    AdminWebConstant.Treatment.DeviceMode.OHDF.equals(mstTreat.getDeviceMode()) ||
                    AdminWebConstant.Treatment.DeviceMode.OHF.equals(mstTreat.getDeviceMode()) ||
                    AdminWebConstant.Treatment.DeviceMode.AFBF.equals(mstTreat.getDeviceMode()))) {
              // 8.BV-UFC、ONの場合は強制的にOFFに変更する。
              if (bvufcInfo != null && bvufcInfo.has("196")) {
                if (!"0".equals(bvufcInfo.get("196").toString())) {
                  //mod 8053 患者経過総合ビューアにて除水プログラムとBV-UFCを両方入りに出来る 張 start
                  JSONObject ufrJson = new JSONObject(ordnew.get("ufr").toString());
                  JSONObject devJson = new JSONObject(ufrJson.get("dev").toString());
                  JSONObject aJSON = new JSONObject(devJson.get("A").toString());
                  if (ufrJson != null && aJSON.has("290")) {
                    if (!"0".equals(aJSON.get("290").toString())) {
                      msglist.add("12000031");
                      //add 7295除水プログラムONの時にBV-UFCがONにできてしまう 張 start
                      //mod 6925
//                if( AdminWebConstant.Treatment.DeviceMode.HDF.equals(mstTreat.getDeviceMode()) ||
//                  AdminWebConstant.Treatment.DeviceMode.HF.equals(mstTreat.getDeviceMode()) ||
//                  AdminWebConstant.Treatment.DeviceMode.OHDF.equals(mstTreat.getDeviceMode()) ||
//                  AdminWebConstant.Treatment.DeviceMode.OHF.equals(mstTreat.getDeviceMode()) ||
//                  AdminWebConstant.Treatment.DeviceMode.AFBF.equals(mstTreat.getDeviceMode())) {
//                  indDeviceSetInfoDefault.put("ufr", ufr.put("dev", ufrDev.put("A", ufrInfo.put("290", "1"))));
//                }else {
//                }
                      //mod 6925
                    }
                    indDeviceSetInfoDefault.put("ufr", ufrJson);
                    bodyData.setInd_device_set_info(indDeviceSetInfoDefault.toString());
                  }
                  //mod 8053 患者経過総合ビューアにて除水プログラムとBV-UFCを両方入りに出来る 張 end
                  //add 7295除水プログラムONの時にBV-UFCがONにできてしまう 張 end
                }
              }
            }
          }
          if( "0".equals(imageFlg)  && ((AdminWebConstant.Treatment.DeviceMode.HD.equals(mstTreat.getDeviceMode()) ||
                  AdminWebConstant.Treatment.DeviceMode.ECUM.equals(mstTreat.getDeviceMode()) ||
                  AdminWebConstant.Treatment.DeviceMode.HDF.equals(mstTreat.getDeviceMode()) ||
                  AdminWebConstant.Treatment.DeviceMode.HF.equals(mstTreat.getDeviceMode()) ||
                  AdminWebConstant.Treatment.DeviceMode.OHDF.equals(mstTreat.getDeviceMode()) ||
                  AdminWebConstant.Treatment.DeviceMode.OHF.equals(mstTreat.getDeviceMode()) ||
                  AdminWebConstant.Treatment.DeviceMode.AFBF.equals(mstTreat.getDeviceMode()) ||
                  AdminWebConstant.Treatment.DeviceMode.I_HDF.equals(mstTreat.getDeviceMode())))) {
            JSONObject NAord = (ordnew == null || !ordnew.has("na")) ? null : new JSONObject(ordnew.get("na").toString());
            JSONObject NADev = (NAord == null || !NAord.has("dev")) ? null : new JSONObject(NAord.get("dev").toString());
            JSONObject NAa = (NADev == null || !NADev.has("A")) ? null : new JSONObject(NADev.get("A").toString());
            if (dcInfo != null && dcInfo.has("340") && NAa != null && NAa.has("315")) {
              if (!"0".equals(dcInfo.get("340").toString())
                      && !"0".equals(NAa.get("315").toString())) {
                //mod FNSI-7287 劉全航 start
//                msglist.add("12000035");
                msglist.add("12000054");
              }
              indDeviceSetInfoDefault.put("na", NAord);
              bodyData.setInd_device_set_info(indDeviceSetInfoDefault.toString());
              //mod FNSI-7287 劉全航 end
            }
          }
          if( "1".equals(imageFlg)  && (AdminWebConstant.Treatment.DeviceMode.HD.equals(mstTreat.getDeviceMode()) ||
                  AdminWebConstant.Treatment.DeviceMode.ECUM.equals(mstTreat.getDeviceMode()) ||
                  AdminWebConstant.Treatment.DeviceMode.HDF.equals(mstTreat.getDeviceMode()) ||
                  AdminWebConstant.Treatment.DeviceMode.HF.equals(mstTreat.getDeviceMode()) ||
                  AdminWebConstant.Treatment.DeviceMode.OHDF.equals(mstTreat.getDeviceMode()) ||
                  AdminWebConstant.Treatment.DeviceMode.OHF.equals(mstTreat.getDeviceMode()) ||
                  AdminWebConstant.Treatment.DeviceMode.I_HDF.equals(mstTreat.getDeviceMode()))) {
            JSONObject dcord = !ordnew.has("dc") ? null : new JSONObject(ordnew.get("dc").toString());
            JSONObject dcordDev = (dcord == null || !dcord.has("dev")) ? null : new JSONObject(dcord.get("dev").toString());
            JSONObject dcordInfo = (dcordDev == null || !dcordDev.has("A")) ? null : new JSONObject(dcordDev.get("A").toString());
            if (dcordInfo != null && dcordInfo.has("340") && naA != null && naA.has("315")) {
              if (!"0".equals(dcordInfo.get("340").toString())
                      && !"0".equals(naA.get("315").toString())) {
                //mod FNSI-7287 劉全航 start
//                msglist.add("12000036");
                msglist.add("12000053");
              }
              indDeviceSetInfoDefault.put("dc", dcord);
              bodyData.setInd_device_set_info(indDeviceSetInfoDefault.toString());
              //mod FNSI-7287 劉全航 end
            }
          }
          JSONObject indCondInfo = null == ord.getIndCondInfo() ?
                  new JSONObject() :
                  new JSONObject(ord.getIndCondInfo());
          // mod #9973 Resolve null exception for key 20240117 ztc start
//          singleNeedle = (null == indCondInfo.getJSONObject("12") && null == indCondInfo.getJSONObject("12").get("value")) ? ""
//                  : indCondInfo.getJSONObject("12").get("value").toString();
          // mod #11120 by kangjie 20241004 start fix jsonObject not found[12]
//          singleNeedle = (null == indCondInfo.getJSONObject("12") || null == indCondInfo.getJSONObject("12").get("value")) ? ""
//            : indCondInfo.getJSONObject("12").get("value").toString();

          singleNeedle = (!indCondInfo.has("12")||null == indCondInfo.getJSONObject("12") || null == indCondInfo.getJSONObject("12").get("value")) ? ""
                  : indCondInfo.getJSONObject("12").get("value").toString();
          // mod #11120 by kangjie 20241004 end fix jsonObject not found[12]
          // mod #9973 Resolve null exception for key 20240117 ztc end
          //add 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 start
          if(AdminWebConstant.Treatment.DeviceMode.HD.equals(mstTreat.getDeviceMode()) ||
                  AdminWebConstant.Treatment.DeviceMode.ECUM.equals(mstTreat.getDeviceMode())){
            // 透析量プログラム
            JSONObject dia = (!ordnew.has("dia")) ? null :new JSONObject(ordnew.get("dia").toString());
            JSONObject diaDev = (dia == null || !dia.has("dev")) ? null : new JSONObject(dia.get("dev").toString());
            JSONObject diaInfo =(diaDev == null || !diaDev.has("A")) ? null :  new JSONObject(diaDev.get("A").toString());
            //透析量プログラムを使用する予定が含まれている場合、シングルニードル使用するを展開する際は警告。警告。
            if (diaInfo!=null&&! "0".equals(diaInfo.get("282").toString()) && "1".equals(singleNeedle)) {
              msglist.add("12000083");
            }
          }
          if(AdminWebConstant.Treatment.DeviceMode.HDF.equals(mstTreat.getDeviceMode()) ||
                  AdminWebConstant.Treatment.DeviceMode.HF.equals(mstTreat.getDeviceMode()) ||
                  AdminWebConstant.Treatment.DeviceMode.OHDF.equals(mstTreat.getDeviceMode()) ||
                  AdminWebConstant.Treatment.DeviceMode.OHF.equals(mstTreat.getDeviceMode()) ||
                  AdminWebConstant.Treatment.DeviceMode.AFBF.equals(mstTreat.getDeviceMode()) ||
                  AdminWebConstant.Treatment.DeviceMode.I_HDF.equals(mstTreat.getDeviceMode())||
                  AdminWebConstant.Treatment.DeviceMode.PURIFICATION.equals(mstTreat.getDeviceMode())){
            // 透析量プログラム
            JSONObject dia = (!ordnew.has("dia")) ? null :new JSONObject(ordnew.get("dia").toString());
            JSONObject diaDev = (dia == null || !dia.has("dev")) ? null : new JSONObject(dia.get("dev").toString());
            JSONObject diaInfo =(diaDev == null || !diaDev.has("A")) ? null :  new JSONObject(diaDev.get("A").toString());
            //透析量プログラムを使用する予定が含まれている場合、シングルニードル使用するを展開する際は警告。警告。
            if (diaInfo!=null&&!"0".equals(diaInfo.get("282").toString())) {
              diaInfo.put("282","0");
              diaDev.put("A",diaInfo);
              dia.put("dev",diaDev);
              ordnew.put("dia",dia);
              msglist.add("12000044");
            }
            bodyData.setInd_device_set_info(ordnew.toString());
          }
          //add 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 end

          if ( "4".equals(imageFlg)  &&(AdminWebConstant.Treatment.DeviceMode.HD.equals(mstTreat.getDeviceMode()) ||
                  AdminWebConstant.Treatment.DeviceMode.ECUM.equals(mstTreat.getDeviceMode()) ||
                  AdminWebConstant.Treatment.DeviceMode.HDF.equals(mstTreat.getDeviceMode()) ||
                  AdminWebConstant.Treatment.DeviceMode.HF.equals(mstTreat.getDeviceMode()) ||
                  AdminWebConstant.Treatment.DeviceMode.OHDF.equals(mstTreat.getDeviceMode()) ||
                  AdminWebConstant.Treatment.DeviceMode.OHF.equals(mstTreat.getDeviceMode()) ||
                  AdminWebConstant.Treatment.DeviceMode.AFBF.equals(mstTreat.getDeviceMode())) ||
                  AdminWebConstant.Treatment.DeviceMode.PURIFICATION.equals(mstTreat.getDeviceMode())){
            if (!"null".equals(singleNeedle) && "1".equals(singleNeedle)){
              JSONObject ordnewbvufc = (ordnew == null || !ordnew.has("bvufc")) ? null : new JSONObject(ordnew.get("bvufc").toString());
              JSONObject ordnewbvufcDev = (ordnewbvufc == null || !ordnewbvufc.has("dev")) ? null : new JSONObject(ordnewbvufc.get("dev").toString());
              JSONObject ordnewbvufcInfo = (ordnewbvufcDev == null || !ordnewbvufcDev.has("A")) ? null : new JSONObject(ordnewbvufcDev.get("A").toString());
              if (ordnewbvufcInfo != null && ordnewbvufcInfo.has("196") && ordnewbvufcDev != null && ordnewbvufc != null && ordnew != null) {
                if (!"0".equals(ordnewbvufcInfo.get("196").toString())) {
                  msglist.add("12000042");
                }
              }

            }
          }

          if( "2".equals(imageFlg) && AdminWebConstant.Treatment.DeviceMode.I_HDF.equals(mstTreat.getDeviceMode())) {
            JSONObject ordnewufr = (ordnew == null || !ordnew.has("ufr")) ? null : new JSONObject(ordnew.get("ufr").toString());
            JSONObject ordnewufrDev = (ordnewufr == null || !ordnewufr.has("dev")) ? null : new JSONObject(ordnewufr.get("dev").toString());
            JSONObject ordnewufrInfo = (ordnewufrDev == null || !ordnewufrDev.has("A")) ? null : new JSONObject(ordnewufrDev.get("A").toString());
            if (ordnewufrInfo != null && ordnewufrInfo.has("290") && ordnewufrDev != null && ordnewufr != null && ordnew != null) {
              if (!"0".equals(ordnewufrInfo.get("290").toString())) {
                ordnewufrInfo.put("290", "0");
                ordnewufrDev.put("A", ordnewufrInfo);
                ordnewufr.put("dev", ordnewufrDev);
                ordnew.put("ufr", ordnewufr);
                msglist.add("12000034");
              }
              indDeviceSetInfoDefault.put("ufr", ordnewufr);
              bodyData.setInd_device_set_info(indDeviceSetInfoDefault.toString());
            }

          }
          if( "1".equals(imageFlg) && AdminWebConstant.Treatment.DeviceMode.AFBF.equals(mstTreat.getDeviceMode())) {
            JSONObject ordnewdc = (ordnew == null || !ordnew.has("dc")) ? null : new JSONObject(ordnew.get("dc").toString());
            JSONObject ordnewdcDev = (ordnewdc == null || !ordnewdc.has("dev")) ? null : new JSONObject(ordnewdc.get("dev").toString());
            JSONObject ordnewdcInfo = (ordnewdcDev == null || !ordnewdcDev.has("A")) ? null : new JSONObject(ordnewdcDev.get("A").toString());
            if (ordnewdcInfo != null && ordnewdcInfo.has("340") && ordnewdcDev != null && ordnewdc != null && ordnew != null) {
              //mod 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 start
              //if ("1".equals(ordnewdcInfo.get("340").toString())) {
              if (!"0".equals(ordnewdcInfo.get("340").toString())) {
                //mod 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 end
                ordnewdcInfo.put("340", "0");
                ordnewdcDev.put("A", ordnewdcInfo);
                ordnewdc.put("dev", ordnewdcDev);
                ordnew.put("dc", ordnewdc);
                //mod 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 start
//                msglist.add("12000034");
                msglist.add("12000037");
                //mod 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 end
              }
              //add 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 start
              bodyData.setInd_device_set_info(ordnew.toString());
              //add 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 end
            }
          }
          if( "3".equals(imageFlg)  && AdminWebConstant.Treatment.DeviceMode.I_HDF.equals(mstTreat.getDeviceMode())) {
            JSONObject ordnewqbqd = (ordnew == null || !ordnew.has("qbqd")) ? null : new JSONObject(ordnew.get("qbqd").toString());
            JSONObject ordnewqbqdDev = (ordnewqbqd == null || !ordnewqbqd.has("dev")) ? null : new JSONObject(ordnewqbqd.get("dev").toString());
            JSONObject ordnewqbqdA = (ordnewqbqdDev == null || !ordnewqbqdDev.has("A")) ? null : new JSONObject(ordnewqbqdDev.get("A").toString());
            if (ordnewqbqdA != null && ordnewqbqdA.has("430") && ordnewqbqdDev != null && ordnewqbqd != null && ordnew != null) {
              //mod 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 start
//              if ("1".equals(ordnewqbqdA.get("430").toString())) {
              if (!"0".equals(ordnewqbqdA.get("430").toString())||!"0".equals(ordnewqbqdA.get("431").toString())) {
                //mod 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 end

                ordnewqbqdA.put("430", "0");
                ordnewqbqdA.put("431", "0");
                ordnewqbqdDev.put("A", ordnewqbqdA);
                ordnewqbqd.put("dev", ordnewqbqdDev);
                ordnew.put("qbqd", ordnewqbqd);
                //add 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 start
//                msglist.add("12000034");
                msglist.add("12000039");
                //mod 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 end
              }
              bodyData.setInd_device_set_info(ordnew.toString());
            }
          }
          if( "4".equals(imageFlg)  && AdminWebConstant.Treatment.DeviceMode.I_HDF.equals(mstTreat.getDeviceMode())) {
            JSONObject ordnewbvufc = (ordnew == null || !ordnew.has("bvufc")) ? null : new JSONObject(ordnew.get("bvufc").toString());
            JSONObject ordnewbvufcDev = (ordnewbvufc == null || !ordnewbvufc.has("dev")) ? null : new JSONObject(ordnewbvufc.get("dev").toString());
            JSONObject ordnewbvufcInfo = (ordnewbvufcDev == null || !ordnewbvufcDev.has("A")) ? null : new JSONObject(ordnewbvufcDev.get("A").toString());
            if (ordnewbvufcInfo != null && ordnewbvufcInfo.has("196") && ordnewbvufcDev != null && ordnewbvufc != null && ordnew != null) {
              if (!"0".equals(ordnewbvufcInfo.get("196").toString())) {
                ordnewbvufcInfo.put("196", "0");
                ordnewbvufcDev.put("A", ordnewbvufcInfo);
                ordnewbvufc.put("dev", ordnewbvufcDev);
                ordnew.put("bvufc", ordnewbvufc);
                msglist.add("12000034");
              }
              bodyData.setInd_device_set_info(ordnew.toString());
            }
          }
        }
      }
      //7810 mod 治療条件・装置設定変更時の動作不備（412.xlsx）張 end
      responseData.put("msglist",msglist);
      //add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 end
      //upd by ztc 2023-02-27 [Optimize runtime No.5482] --start
//      this.updateDeviceSetInfoOrd(
//              ordMain.get(i).
//                      getOrdNo(),
//              bodyData.getInd_device_set_info()
//      );
      OrdMainEsListener updateDeviceSetInfo = new OrdMainEsListener();
      updateDeviceSetInfo.setOrdNo(ordMain.get(i).getOrdNo());
      // mod #11291 除水プログラムの編集でフリーズする 関 start
      // updateDeviceSetInfo.setIndDeviceSetInfo(bodyData.getInd_device_set_info());
      // deviceSetInfoOrdVoList.add(updateDeviceSetInfo);
      Long indUserId = null;
      Long updUserId = null;
      String indDeviceSetInfo = bodyData.getInd_device_set_info();
      ObjectMapper mapper = new ObjectMapper();
      try {
        JsonNode jsonNode = mapper.readTree(indDeviceSetInfo);
        Iterator<Map.Entry<String, JsonNode>> fields = jsonNode.fields();
        while (fields.hasNext()) {
          Map.Entry<String, JsonNode> next = fields.next();
          String key = next.getKey();
          if (!updateKeyLst.contains(key)) continue;
          JsonNode value = next.getValue();
          indUserId = value.get("ind_user_id").asLong();
          updUserId = value.get("upd_user_id").asLong();
          if (indUserId != 0) {
            MstPersonalUser indUser = MasterCacheHandler.get().getMstPersonalUser(indUserId);
            if (indUser != null) {
              ((ObjectNode)value).put("ind_user_first_name",indUser.getUserFirstName());
              ((ObjectNode)value).put("ind_user_last_name",indUser.getUserLastName());
            }
          }
          if (updUserId != 0) {
            MstPersonalUser updUser = MasterCacheHandler.get().getMstPersonalUser(updUserId);
            if (updUser != null) {
              ((ObjectNode)value).put("upd_user_first_name",updUser.getUserFirstName());
              ((ObjectNode)value).put("upd_user_last_name",updUser.getUserLastName());
            }
          }
        }
        updateDeviceSetInfo.setIndDeviceSetInfo(jsonNode.toString());
        updateDeviceSetInfo.setUpIndUserId(indUserId);
        updateDeviceSetInfo.setUpUserId(updUserId);
      } catch (JsonProcessingException e) {
        throw new RuntimeException(e);
      }
      deviceSetInfoOrdVoList.add(updateDeviceSetInfo);
      // mod #11291 除水プログラムの編集でフリーズする 関 end
    }
    if(!deviceSetInfoOrdVoList.isEmpty()){
      // del #11291 除水プログラムの編集でフリーズする 関 start
      // add 10196 by kangjie 20240124 start

      //      deviceSetInfoOrdVoList.stream().forEach(item -> {
      //        Long indUserId = null;
      //        Long updUserId = null;
      //        String indDeviceSetInfo = item.getIndDeviceSetInfo();
      //        ObjectMapper mapper = new ObjectMapper();
      //        try {
      //          JsonNode jsonNode = mapper.readTree(indDeviceSetInfo);
      //          Iterator<Map.Entry<String, JsonNode>> fields = jsonNode.fields();
      //          while (fields.hasNext()) {
      //            Map.Entry<String, JsonNode> next = fields.next();
      //            String key = next.getKey();
      //            // add #11129 コンバート施設で除水プログラムを変更すると500エラーとなる dengshen start
      //            if (!updateKeyLst.contains(key)) continue;
      //            // add #11129 コンバート施設で除水プログラムを変更すると500エラーとなる dengshen end
      //            JsonNode value = next.getValue();
      //            indUserId = value.get("ind_user_id").asLong();
      //            updUserId = value.get("upd_user_id").asLong();
      //            MstPersonalUser indUser = MasterCacheHandler.get().getMstPersonalUser(indUserId);
      //            MstPersonalUser updUser = MasterCacheHandler.get().getMstPersonalUser(updUserId);
      //            ((ObjectNode)value).put("ind_user_first_name",indUser.getUserFirstName());
      //            ((ObjectNode)value).put("ind_user_last_name",indUser.getUserLastName());
      //            ((ObjectNode)value).put("upd_user_first_name",updUser.getUserFirstName());
      //            ((ObjectNode)value).put("upd_user_last_name",updUser.getUserLastName());
      //          }
      //          item.setIndDeviceSetInfo(jsonNode.toString());
      //          item.setUpIndUserId(indUserId);
      //          item.setUpUserId(updUserId);
      //        } catch (JsonProcessingException e) {
      //          throw new RuntimeException(e);
      //        }
      //      });
      // add 10196 by kangjie 20240124 end
      // del #11291 除水プログラムの編集でフリーズする 関 end
      this.updateDeviceSetInfoOrdList(deviceSetInfoOrdVoList);
      // del 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//      /* add #9355  by zhangruixue 2023-09-06 --start  */
//      //指示履歴を登録
//      indHistoryMakeService.createDeviceSetInfoHistory(bodyData, "2", treatWeekList, ordMain);
//      /* add #9355  by zhangruixue 2023-09-06 --end  */
      // del 11555 指示履歴への記録の残り方が仕様と異なる zkm end
    }
    //upd by ztc 2023-02-27 [Optimize runtime No.5482] --end
  }
  /* add by KongShuai 2023-02-01 CodeOptimization end */

  /* add by KongShuai 2023-02-01 [Transaction,CodeOptimization] start */
  /**
   * 指示:風袋・除水補正(未来)
   * @description 患者情報を更新時に未来への指示へ更新を許可した際に行う処理
   */
  @Transactional
  public void updateFutureIndTareOffWaterInfo(ApiEntityDeviceSetInfo.ValiTareAndOffWater bodyData) throws Exception {
    // 患者情報
    Long patId = this.getLongPattern(bodyData.getPat_id());
    // 本日の日付け取得
    LocalDateTime nowDate = LocalDateTime.now();
    DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("yyyyMMdd");
    String today = nowDate.format(dateTimeFormatter);
    // 更新日時
    Timestamp upDate = Timestamp.valueOf(bodyData.getUp_date());
    List<String> getTateAndOffWater = null;
    // 対象患者の風袋・除水補正情報を取得
    getTateAndOffWater = this.selectTareAndOffWater(null, patId, null, null);

    JSONObject tareAndOffWaterInfo = new JSONObject(getTateAndOffWater.get(0));
    // 風袋もしくは除水補正情報(患者情報)
    JSONObject patInfo = null;
    // 風袋もしくは除水補正の反映曜日
    JSONArray weeksArr = null;
    // 風袋、除水補正反映フラグ(0->風袋、1->除水補正)
    int isFlag = null != bodyData.getTare_info() ? 0 : 1;

    // 風袋情報格納処理
    if (0 == isFlag) {
      patInfo = new JSONObject(tareAndOffWaterInfo.getString("tare_info"));
      weeksArr = new JSONArray(bodyData.getTare_info());
      // 除水補正情報格納処理
    } else {
      patInfo = new JSONObject(tareAndOffWaterInfo.getString("off_water_info"));
      weeksArr = new JSONArray(bodyData.getOff_water_info());
    }

    for (int i = 0; i < weeksArr.length(); i++) {
      String tareInfo = null;
      String offWaterInfo = null;
      if (0 == isFlag) {
        tareInfo = patInfo.getJSONObject(weeksArr.getString(i)).toString();
      } else {
        offWaterInfo = patInfo.getJSONObject(weeksArr.getString(i)).toString();
      }

      // 更新処理(ord_main更新)
      this.updateFutureIndTareAndOffWater(
              patId,
              today,
              weeksArr.getInt(i),
              tareInfo,
              offWaterInfo,
              upDate
      );
      String facilityCd = null;
      if (facilityCd == null && patId != null) {
        List<Long> patIdList = new ArrayList<Long>();
        patIdList.add(patId);
        List<PatPersonalMain> listPatPersonalMain = patPersonalMainDao.selectByIdList(patIdList);
        PatPersonalMain patPersonalMain = listPatPersonalMain.get(0);
        facilityCd = patPersonalMain.getFacility_cd();
      }
      // 次患者更新呼び出し
      // del #7188 2023/01/14 治療条件，装置設定を変更すると次患者が再送される dou start
      // callDoCancelSetNextPatInfo(facilityCd, patId);
      // del #7188 2023/01/14 治療条件，装置設定を変更すると次患者が再送される dou end
      // 更新処理(pat_treatment_pattern更新)
      patTreatmentPatternUtils.updateIndTareAndOffWater(
              tareInfo,
              offWaterInfo,
              patId,
              facilityCd,
              weeksArr.getInt(i)
      );
    }
  }
  /**
   * String型 -> Long型 変換
   * @param  longPattern
   * @return Long型
   */
  private Long getLongPattern(String longPattern){
    Long longData;
    if (longPattern == null) {
      return null;
    } else {
      longData = Long.parseLong(longPattern);
      return longData;
    }
  }
  /* add by KongShuai 2023-02-01 [Transaction,CodeOptimization] end */
}



