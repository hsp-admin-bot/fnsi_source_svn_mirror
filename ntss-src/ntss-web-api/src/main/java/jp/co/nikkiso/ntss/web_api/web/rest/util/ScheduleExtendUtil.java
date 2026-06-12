package jp.co.nikkiso.ntss.web_api.web.rest.util;

import java.math.BigDecimal;
import java.net.Inet4Address;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.sql.Types;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Base64;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;

import org.springframework.lang.NonNull;
import javax.sql.DataSource;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import tools.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import jp.co.nikkiso.ntss.core.dao.OrdScheduleDao;
import jp.co.nikkiso.ntss.core.entity.OrdSchedule;
import jp.co.nikkiso.ntss.core.entity.OrdScheduleNewKurPreview;
import jp.co.nikkiso.ntss.core.service.ordMaterialSaveService.OrdMaterialSaveService;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import org.json.JSONArray;
import org.json.JSONObject;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import org.springframework.aop.framework.AopProxyUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.dao.DataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.BatchPreparedStatementSetter;
import org.springframework.jdbc.core.PreparedStatementCallback;
import org.springframework.jdbc.support.JdbcUtils;
import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.TransactionDefinition;
import org.springframework.transaction.TransactionStatus;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.DefaultTransactionDefinition;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestTemplate;

import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.ExamRecalcStatus;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.MntBatchManagerCtlNo;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.NotificationDefinition;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MntBatchManagerDao;
import jp.co.nikkiso.ntss.core.dao.MntRecalcQueDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.MstKurDao;
import jp.co.nikkiso.ntss.core.dao.MstTreatmentDao;
import jp.co.nikkiso.ntss.core.dao.OrdCoopNoDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatExamMainDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.PatRadMainDao;
import jp.co.nikkiso.ntss.core.dao.PatTreatmentPatternDao;
import jp.co.nikkiso.ntss.core.dao.SysNotificationDao;
import jp.co.nikkiso.ntss.core.dao.SysSystemDefineDao;
import jp.co.nikkiso.ntss.core.entity.MntBatchManager;
import jp.co.nikkiso.ntss.core.entity.MntRecalcQue;
import jp.co.nikkiso.ntss.core.entity.MstFacility;
import jp.co.nikkiso.ntss.core.entity.MstKur;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatExamMain;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.PatRadMain;
import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;
import jp.co.nikkiso.ntss.core.entity.custom.PatTreatmentPatternPatMain;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.utils.TriggerUtil;
import jp.co.nikkiso.ntss.web_api.request.JournalCreateRequestPayload;
import jp.co.nikkiso.ntss.web_api.service.ExamRequestScheduleExtendUtilService;
import jp.co.nikkiso.ntss.web_api.service.ExamResultCalcUtilService;
import jp.co.nikkiso.ntss.web_api.service.FacilityCancelService;
import jp.co.nikkiso.ntss.web_api.service.FacilityExpireService;
import jp.co.nikkiso.ntss.web_api.service.InOutInfoUtilService;
import jp.co.nikkiso.ntss.web_api.service.LogService;
import jp.co.nikkiso.ntss.web_api.service.NotificationBatchService;
import jp.co.nikkiso.ntss.web_api.web.rest.NotificationResource;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import java.net.InetAddress;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import java.util.Enumeration;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.toJson;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
import static jp.co.nikkiso.ntss.web_api.constant.ScheduleConstant.IS_SCHEXT_EXCEPTION;

@Component
@ConditionalOnProperty(value = "schedule-extend.execute")
public class ScheduleExtendUtil {
  @Autowired
  OrdMainDao ordMainDao;

  @Autowired
  MstFacilityDao mstFacilityDao;

  @Autowired
  MstFacilitySettingDao mstFacilitySettingDao;

  @Autowired
  PatMainDao patMainDao;

  @Autowired
  PatTreatmentPatternDao patTreatmentPatternDao;

  @Autowired
  SysSystemDefineDao sysSystemDefineDao;

  @Autowired
  InOutInfoUtilService inOutInfoUtilService;

  @Autowired
  MntBatchManagerDao mntBatchManagerDao;

  @Autowired
  MstTreatmentDao mstTreatmentDao;

  //add #11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) zkm start
  @Autowired
  private OrdScheduleDao ordScheduleDao;
  //add #11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) zkm end

  @Autowired
  ExamRequestScheduleExtendUtilService examRequestScheduleExtendUtilService;

  @Autowired
  FacilityExpireService facilityExpireService;

  @Autowired
  FacilityCancelService facilityCancelService;

  @Autowired
  private LogService logService;

  @Autowired
  private PatPersonalMainDao patPersonalMainDao;

  @Autowired
  private PatExamMainDao patExamMainDao;

  @Autowired
  private MntRecalcQueDao mntRecalcQueDao;

  //add #10196 Ord_Material_Save code implementation 20240130 ztc start
  @Autowired
  private OrdMaterialSaveService ordMaterialSaveService;
  //add #10196 Ord_Material_Save code implementation 20240130 ztc end

  /**
   * 検査結果計算Service
   */
  @Autowired
  private ExamResultCalcUtilService examResultCalcUtilService;

  @Autowired
  PatRadMainDao patRadMainDao;

  @Autowired
  private MstKurDao mstKurDao;

  @Autowired
  OrdCoopNoDao ordCoopNoDao;

  @Autowired
  SysNotificationDao sysNotificationDao;

  @Autowired
  PlatformTransactionManager transactionManager;

  @Autowired
  private DataSource dataSource;

  @Autowired
  NotificationResource notificationResource;

  @Autowired
  NotificationBatchService notificationBatchService;

  @Value("${ntss.web-api.coop-api.url}")
  private String coopApi;

  /* add by chamaojia 2024-06-21 [10574] communication security related additions --start */
  @Value("${ntss.web-api.coop-api.header-name}")
  private String headerKey;
  @Value("${ntss.web-api.coop-api.header-value}")
  private String headerValue;
  /* add by chamaojia 2024-06-21 [10574] communication security related additions --end */

  @Autowired
  private TriggerUtil triggerUtil;
  private ScheduleExtendCache cache;

  private static final Map<String, String> coopCds = initMapData();

  LocalDate endDate = LocalDate.now().plusYears(1).with(TemporalAdjusters.lastDayOfMonth());

  @Scheduled(cron = "${schedule-extend.cron}")
  public void runDailyBatch() {
    endDate = LocalDate.now().plusYears(1).with(TemporalAdjusters.lastDayOfMonth());
    //mod 11122【総合検証NG】オンプレ環境で日次処理が実行されない zhao start
    //String hostIp = "";
    String ipAddress = "";
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("日次バッチrunDailyBatch");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    List<String> addressList = new ArrayList<>();
    try {
      // 現在実施しているサーバーのIpアドレスを取得する
      //hostIp = InetAddress.getLocalHost().getHostAddress();
        Enumeration<NetworkInterface> interfaces = NetworkInterface.getNetworkInterfaces();
        while (interfaces.hasMoreElements()) {
          NetworkInterface networkInterface = interfaces.nextElement();
          if (networkInterface.isLoopback() || networkInterface.isVirtual() || !networkInterface.isUp()) {
            continue;
          }
          Enumeration<InetAddress> addresses = networkInterface.getInetAddresses();
          while (addresses.hasMoreElements()) {
            InetAddress inetAddress = addresses.nextElement();
            if (inetAddress instanceof Inet4Address) {
              ipAddress = inetAddress.getHostAddress();
              addressList.add(ipAddress);
            }
          }
        }
    } catch (SocketException e) {
      // IPアドレス取得に失敗した場合
      eventLogMessage.setLogMessage("日次バッチ処理：PrivateIPアドレスの取得に失敗　UnknownHostException[" + e.getMessage() + "]");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return;
    }
    // バックエンドサーバのローカルIPアドレスを取得する
    List<SysSystemDefine> sysSystemDefine = sysSystemDefineDao.selectByCtlNo(34);
    if (!sysSystemDefine.isEmpty()) {
      String strJson = sysSystemDefine.get(0).getValue();
      JSONObject objJson = new JSONObject(strJson);
      ipAddress = objJson.getString("ip_address");
    }
    //if (!hostIp.equals(ipAddress)) {
     if (!addressList.contains(ipAddress)) {
       // 処理実施サーバーではない場合
       //eventLogMessage.setLogMessage("日次バッチ処理：処理対象外サーバー　システム設定[" + ipAddress + "]、確認サーバー[" + hostIp + "]");
       eventLogMessage.setLogMessage("日次バッチ処理：処理対象外サーバー　システム設定[" + ipAddress + "]、確認サーバー[" + addressList + "]");
       //mod 11122【総合検証NG】オンプレ環境で日次処理が実行されない zhao end
       logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return;
    }

    eventLogMessage.setLogMessage("日次バッチ処理を開始しました");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // システム設定テーブルよりバッチ処理の開始時間・終了時間を取得
    String targetDt = DateTimeFormatter.ofPattern("uuuuMMdd").format(LocalDate.now());
    LocalTime startTime = LocalTime.parse(targetDt + "0000", DateTimeFormatter.ofPattern("uuuuMMddHHmm"));
    LocalTime endTime = LocalTime.parse(targetDt + "2359", DateTimeFormatter.ofPattern("uuuuMMddHHmm"));

    List<SysSystemDefine> systemDefine = sysSystemDefineDao.selectByCtlNo(13);
    if (!systemDefine.isEmpty()) {
      String strJson = systemDefine.get(0).getValue();
      JSONObject objJson = new JSONObject(strJson);
      startTime = LocalTime.parse(targetDt + objJson.getString("startTime"), DateTimeFormatter.ofPattern("uuuuMMddHHmm"));
      endTime = LocalTime.parse(targetDt + objJson.getString("endTime"), DateTimeFormatter.ofPattern("uuuuMMddHHmm"));
    }

    if (LocalTime.now().isBefore(startTime) || LocalTime.now().isAfter(endTime)) {
      eventLogMessage.setLogMessage("時間外のため、日次バッチ処理を終了します(処理時間帯：" + startTime + "～" + endTime + ")");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return;
    }

    // 解約削除の割込み時間
    // システム設定テーブルより解約処理の開始時間・終了時間を取得
    LocalTime startTimeFacilityCancel = LocalTime.parse(targetDt + "0000", DateTimeFormatter.ofPattern("uuuuMMddHHmm"));
    systemDefine = sysSystemDefineDao.selectByCtlNo(32);
    if (!systemDefine.isEmpty()) {
      String strJson = systemDefine.get(0).getValue();
      JSONObject objJson = new JSONObject(strJson);
      startTimeFacilityCancel = LocalTime.parse(targetDt + objJson.getString("startTime"), DateTimeFormatter.ofPattern("uuuuMMddHHmm"));
    }

    // ログイン無効化
    runDisableLogin();

    // 入外区分更新処理起動
    runInOutUpdate();

    // スケジュール自動延長処理起動
    LocalTime end = endTime.isBefore(startTimeFacilityCancel) ? endTime : startTimeFacilityCancel;
//    List<Long> patIdList = new ArrayList<Long>();
    List<ScheduleExtendTask> tasks = new ArrayList<>();

    // DEL BY HandsomeLin At 2023/03/20
    // boolean isComplete = runScheduleExtend(startTime, end, patIdList);
    // DEL BY HandsomeLin At 2023/03/20

    // ADD BY HandsomeLin At 2023/03/20
    boolean isComplete = runScheduleExtendForFacility(startTime, end, tasks);
    // ADD BY HandsomeLin At 2023/03/20

    // 検査再計算ツール
    runQuantityCheckRecalculation(startTime, end);

    // 時間を指定
    LocalTime start = LocalTime.now().isBefore(startTimeFacilityCancel) ? startTime : startTimeFacilityCancel;
    end = endTime;
    // データ削除処理起動
    runDeleteFacility(start, end);

    // 残り時間がある場合
    // スケジュール自動延長処理起動
    if (LocalTime.now().isBefore(endTime)) {
      if (!isComplete && !tasks.isEmpty()) {
        eventLogMessage.setLogMessage("スケジュール自動延長を再開しました");
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        // スケジュール自動延長処理起動
        runScheduleExtendForFacility(startTime, endTime, tasks);
      }
    }

    if (cache != null) {
      cache.clear();
      cache = null;
    }
    eventLogMessage.setLogMessage("日次バッチ処理を終了しました");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
  }

  /**
   * 全患者を対象に入外区分更新処理を行う
   */
  public void runInOutUpdate() {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("入外区分更新処理を開始しました");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // 対象日付：当日
    String targetDt = DateTimeFormatter.ofPattern("uuuuMMdd").format(LocalDate.now());

    // 入外区分更新処理バッチ稼働状況のチェック
    MntBatchManager resultInOutUpdate = mntBatchManagerDao.selectByCtlNo(MntBatchManagerCtlNo.CTL_NO_IN_OUT_STATE_UPDATE);
    // modify 10994 by kangjie 20241028 start
//    List<MntBatchManager> mntBatchManagerListAll = mntBatchManagerDao.selectAll();
    // 終了されていないレコードがあれば処理を終了する
//    if (mntBatchManagerListAll.stream().anyMatch(e -> e.getStatus().equals("1"))) {
    if ("1".equals(resultInOutUpdate.getStatus())) {
      // modify 10994 by kangjie 20241028 end
      eventLogMessage.setLogMessage("前回バッチ処理中のため、入外区分更新処理を終了しました");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return;
    } else {
      Timestamp startDtToday = Timestamp.valueOf(targetDt.substring(0, 4) + "-" + targetDt.substring(4, 6) + "-" + targetDt.substring(6, 8) + " " + "00:00:00");
      Timestamp endDtToday = Timestamp.valueOf(targetDt.substring(0, 4) + "-" + targetDt.substring(4, 6) + "-" + targetDt.substring(6, 8) + " " + "23:59:59");
      if ((resultInOutUpdate.getStartTime() != null && resultInOutUpdate.getStartTime().after(startDtToday)) &&
        (resultInOutUpdate.getEndTime() != null && resultInOutUpdate.getEndTime().before(endDtToday))) {
        eventLogMessage.setLogMessage("本日分のバッチ処理済みのため、入外区分更新処理を終了しました");
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        return;
      }
    }

    try {
      // バッチ処理ステータス/開始時刻 を更新
      resultInOutUpdate.setStatus("1");
      resultInOutUpdate.setStartTime(new Timestamp(System.currentTimeMillis()));

      mntBatchManagerDao.updateProcessStatus(resultInOutUpdate);

      // 更新対象患者リスト：空のリスト(=全患者対象)
      List<Long> patIdList = new ArrayList<Long>();
      inOutInfoUtilService.updateInOutStateByDate(targetDt, patIdList);
    } catch (Exception e) {
      // 例外発生時にはログを記録
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    } finally {
      // バッチ処理ステータス/終了時刻 を更新
      resultInOutUpdate.setStatus("0");
      resultInOutUpdate.setEndTime(new Timestamp(System.currentTimeMillis()));

      mntBatchManagerDao.updateProcessStatus(resultInOutUpdate);

      eventLogMessage.setLogMessage("入外区分更新処理を終了しました");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }
  }

  /**
   * 検査再計算ツール
   * @param startTime バッチ処理開始時刻
   * @param endTime バッチ処理終了時刻
   */
  public void runQuantityCheckRecalculation (LocalTime startTime, LocalTime endTime){
    // 開始ログ
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("検査再計算ツール処理を開始しました");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // 検査再計算ツール処理バッチ稼働状況のチェック
    // バッチ稼働状況のチェック
    MntBatchManager recalculation = mntBatchManagerDao.selectByCtlNo(MntBatchManagerCtlNo.CTL_NO_RECALCULATION);
    // modify 10994 by kangjie 20241028 start
    // List<MntBatchManager> mntBatchManagerListAll = mntBatchManagerDao.selectAll();
    // if (mntBatchManagerListAll.stream().anyMatch(e -> ("1".equals(e.getStatus()) && "1".equals(e.getDivision())))) {
    if ("1".equals(recalculation.getStatus())
      && "1".equals(recalculation.getDivision())) {
    // modify 10994 by kangjie 20241028 end
      // 処理中の場合
      eventLogMessage.setLogMessage("前回バッチ処理中のため、検査再計算ツール処理を終了しました");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return;
    } else {
      // 処理中でない場合は、処理時間をチェック
      // 対象日付：当日
      String targetDt = DateTimeFormatter.ofPattern("uuuuMMdd").format(LocalDate.now());
      Timestamp startDtToday = Timestamp.valueOf(targetDt.substring(0, 4) + "-" + targetDt.substring(4, 6) + "-" + targetDt.substring(6, 8) + " " + "00:00:00");
      Timestamp endDtToday = Timestamp.valueOf(targetDt.substring(0, 4) + "-" + targetDt.substring(4, 6) + "-" + targetDt.substring(6, 8) + " " + "23:59:59");
      if ((null != recalculation.getStartTime() && recalculation.getStartTime().after(startDtToday)) &&
        (null != recalculation.getEndTime() && recalculation.getEndTime().before(endDtToday))) {
        eventLogMessage.setLogMessage("本日分のバッチ処理済のため、検査再計算ツール処理を終了しました");
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        return;
      }
    }
    // バッチ処理ステータス/開始時刻 を更新
    recalculation.setStatus("1");
    recalculation.setStartTime(new Timestamp(System.currentTimeMillis()));

    mntBatchManagerDao.updateProcessStatus(recalculation);
    try {
      boolean isProceed = false;
      // mod #8598 検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない dou start
      // List<String> statusList = Arrays.asList(ExamRecalcStatus.UNPROGRESS, ExamRecalcStatus.PROGRESS_PAUSE, ExamRecalcStatus.PROGRESS_STOPED);
      List<String> statusList = Arrays.asList(ExamRecalcStatus.UNPROGRESS, ExamRecalcStatus.PROGRESS_PAUSE);
      // add #8598 検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない dou end
      List<MntRecalcQue> mntRecalcQueList = mntRecalcQueDao.selectByStatusList(statusList);
      for(MntRecalcQue mntRecalcQue: mntRecalcQueList) {
        isProceed = procRecalcQue(startTime, endTime, mntRecalcQue);
        // データ削除処理開始時間を過ぎていたら検査再計算を処理終了する
        if(!isProceed) return;
      }
    } catch (Exception e ) {
      // 例外発生時にはログを記録
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    } finally {
      // バッチ処理ステータス/終了時刻 を更新
      recalculation.setStatus("0");
      recalculation.setEndTime(new Timestamp(System.currentTimeMillis()));
      mntBatchManagerDao.updateProcessStatus(recalculation);
      eventLogMessage.setLogMessage("検査再計算ツール処理を終了しました");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }
  }

  /**
   * 検査再計算依頼キュー毎に検査結果再計算処理を行う
   * @param startTime バッチ処理開始時刻
   * @param endTime バッチ処理終了時刻
   * @param mntRecalcQue 検査再計算依頼キュー
   * @return true:処理完了 / false:処理中断
   */
  private boolean procRecalcQue (LocalTime startTime, LocalTime endTime, MntRecalcQue mntRecalcQue){
    int executionNum = 0;
    int totalExecutionNum = 0;
    boolean isError = false;
    List<Object> regCalcPatid = null;
    String errExamMainCd = "";
    try {
      JSONObject content = new JSONObject(mntRecalcQue.getContent());
      JSONArray items = content.getJSONArray("item");
      List<Long> mstExamMainCd = new ArrayList<Long>();//計算する
      List<Long> mstExamMainCdNot = new ArrayList<Long>();//計算しない
      // 再計算済患者IDを取得
      String calcPatidColumn = mntRecalcQue.getCalcPatId();
      List<Object> calcPatid = calcPatidColumn != null ? new JSONObject(calcPatidColumn).getJSONArray("calc_pat_id").toList(): new ArrayList<Object>();
      regCalcPatid = calcPatid;
      //mod 9735,9741,9729 再計算 guan start
      String fromDate = StringUtils.isEmpty(content.get("from_date")) ? "1950-01-01" : content.get("from_date").toString();
      String toDate = StringUtils.isEmpty(content.get("to_date")) ? "2099-12-31" : content.get("to_date").toString();
      for (int i = 0; i< items.length(); i++) {
        if ("false".equals(items.getJSONObject(i).get("compute_cover").toString())) {
          //false計算しない
          mstExamMainCdNot.add(Long.parseLong(items.getJSONObject(i).get("exam_item_cd").toString()));
        } else {
          mstExamMainCd.add(Long.parseLong(items.getJSONObject(i).get("exam_item_cd").toString()));
        }
        errExamMainCd = items.getJSONObject(i).get("exam_item_cd").toString();
      }
      List<Long> examMainCd = new ArrayList<Long>();
      JSONArray patIds = content.getJSONArray("pat_id");
      //List<PatExamMain> patExamMainList = patExamMainDao.selectPatExamMainByPatIdAndRegOrderClass(patIds.get(0).toString());
      //患者の検査结果総数を取っているはず
      List<PatExamMain> patExamMainListTotal = new ArrayList<>();
      for (int i = 0; i< patIds.length(); i++) {
        List<PatExamMain> peml = patExamMainDao.selectPatExamMainByPatIdAndFromdateToDate(String.valueOf(patIds.get(i)), fromDate, toDate);
        if (peml.size() > 0) {
          patExamMainListTotal.addAll(peml);
        }
        Map<String,String> rtnParams = new HashMap<>();
        // 処理実行時間経過かを判定
        if (LocalTime.now().isAfter(endTime)) {
          // 時間帯が終了している場合
          processSuspension (startTime, endTime, mntRecalcQue, totalExecutionNum, executionNum, regCalcPatid);
          return false;
        }
        // 再計算済患者IDリストから対象の患者が含まれているか判定
        if (calcPatid != null && calcPatid.size() >= 1 && calcPatid.contains(patIds.get(i))) {
          continue;
        }
        this.recalcByPat(mntRecalcQue.getFacilityCd(), executionNum, patIds.get(i).toString(), mstExamMainCd, mstExamMainCdNot, examMainCd, rtnParams, peml);
        executionNum = Integer.parseInt(rtnParams.get("executionNum"));
        errExamMainCd = rtnParams.get("errExamMainCd");
        isError = "true".equals(rtnParams.get("isError")) ? true : false;
        //エラーが発生していなければ再計算済の患者IDを追加する
        if (!isError) {
          regCalcPatid.add(patIds.get(i));
        }
      }
      //患者毎の検査結果の本数は必ずしも同じではないので、患者数を掛け合わせることはできない
      //totalExecutionNum = patIds.length() * patExamMainList.size();
      totalExecutionNum = patExamMainListTotal.size();
//      for (int i = 0; i< patIds.length(); i++) {
//        Map<String,String> rtnParams = new HashMap<>();
//        // 処理実行時間経過かを判定
//        if (LocalTime.now().isAfter(endTime)) {
//          // 時間帯が終了している場合
//          processSuspension (startTime, endTime, mntRecalcQue, totalExecutionNum, executionNum, regCalcPatid);
//          return false;
//        }
//        // 再計算済患者IDリストから対象の患者が含まれているか判定
//        if (calcPatid != null && calcPatid.size() >= 1 && calcPatid.contains(patIds.get(i))) {
//          continue;
//        }
//        recalcByPat(mntRecalcQue.getFacilityCd(), executionNum, patIds.get(i).toString(), mstExamMainCd, mstExamMainCdNot, examMainCd, rtnParams, fromDate, toDate);
//        executionNum = Integer.parseInt(rtnParams.get("executionNum"));
//        errExamMainCd = rtnParams.get("errExamMainCd");
//        isError = "true".equals(rtnParams.get("isError")) ? true : false;
//        //エラーが発生していなければ再計算済の患者IDを追加する
//        if (!isError) {
//          regCalcPatid.add(patIds.get(i));
//        }
//      }
      //mod 9735,9741,9729 再計算 guan end
    } catch (Exception e ) {
      isError = true;
      // 例外発生時にはログを記録
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      eventLogMessage.setLogMessage("検査再計算処理中にエラーが発生しました。recalc_que_cd：" + mntRecalcQue.getRecalcQueCd());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    } finally {
      // エラー発生有無によって更新するステータスと文言を変更
      String status = isError ? ExamRecalcStatus.PROGRESS_STOPED : ExamRecalcStatus.PROGRESS_COMPLETE;
      // mod #8598 検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない dou start
      // String msg = isError ? "  検査再計算ツール処理を異常終了しました" : "  検査再計算ツール処理を終了しました";
      String msg = isError ? "  検査再計算ツール処理を異常終了しました" : "  再計算処理完了しました\n" + "再計算処理依頼が可能です";
      // mod #8598 検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない dou end
      LocalDateTime now = LocalDateTime.now();
      String time = now.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
      // mod #8598 検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない dou start
      // String journal = time  + " " + executionNum + "/" + totalExecutionNum + msg;
      String journal = time + " " + msg;
      // mod #8598 検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない dou end
      Timestamp ts = new Timestamp(new Date().getTime());
      JSONObject detail = new JSONObject();
      if (mntRecalcQue.getDetail() != null) {
        detail = new JSONObject(mntRecalcQue.getDetail());
      }
      detail.put("exam_main_cd", errExamMainCd);
      detail.put("done_cnt", executionNum);
      detail.put("total_cnt", totalExecutionNum);
      JSONObject finalDetail = detail;
      // JSON文字列生成
      String regcalcPatid = regCalcPatid != null ? "{\"calc_pat_id\":" + regCalcPatid.toString().replace("\"","") + "}" : null;
      MntRecalcQue recalcQue = new MntRecalcQue(){
        {
          setStatus(status);
          setRecalcQueCd(mntRecalcQue.getRecalcQueCd());
          setContent(mntRecalcQue.getContent());
          setDetail(finalDetail.toString());
          setEndDate(ts);
          setJournal(journal);
          setCalcPatId(regcalcPatid);
        }
      };
      mntRecalcQueDao.update(recalcQue);
    }
    return true;
  }


  /**
   * 検査再計算処理中断
   * @param startTime バッチ処理開始時刻
   * @param endTime バッチ処理終了時刻
   * @param mntRecalcQue 検査再計算依頼キュー
   * @param totalExecutionNum 総計算数
   * @param executionNum 計算数
   * @param regCalcPatid 再計算済み患者IDリスト
   */
  private void processSuspension (LocalTime startTime, LocalTime endTime, MntRecalcQue mntRecalcQue,
                                  int totalExecutionNum, int executionNum, List<Object> regCalcPatid){
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("解約削除の開始時間のため、処理を中断しました(" + startTime + "～" + endTime + ")");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    LocalDateTime now = LocalDateTime.now();
    // mod #8598 検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない dou start
    // String time = now.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
    // String journal = time  + " " + executionNum + "/" + totalExecutionNum + "  検査再計算ツール処理を中断しました";
    String journal = "現在再計算処理継続中です（" + executionNum + "/" + totalExecutionNum + "）";
    // mod #8598 検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない dou end
    JSONObject detail = new JSONObject();
    if (mntRecalcQue.getDetail() != null) {
      detail = new JSONObject(mntRecalcQue.getDetail());
    }
    detail.put("exam_main_cd", "");
    detail.put("done_cnt", executionNum);
    detail.put("total_cnt", totalExecutionNum);
    JSONObject finalDetail = detail;
    // JSON文字列生成
    String regcalcPatid = regCalcPatid != null ? "{\"calc_pat_id\":" + regCalcPatid.toString().replace("\"","") + "}" : null;
    MntRecalcQue recalcQue = new MntRecalcQue(){
      {
        setStatus(String.valueOf(ExamRecalcStatus.PROGRESS_PAUSE));
        setRecalcQueCd(mntRecalcQue.getRecalcQueCd());
        setContent(mntRecalcQue.getContent());
        setDetail(finalDetail.toString());
        setJournal(journal);
        setCalcPatId(regcalcPatid);
      }
    };
    mntRecalcQueDao.update(recalcQue);
  }

  /**
   * 患者毎に検査結果再計算
   * @param facilityCd 施設コード
   * @param executionNum 計算数
   * @param patId 患者ID
   * @param mstExamMainCd
   * @param mstExamMainCdNot
   * @param examMainCd
   * @param rtnParams 戻り値格納用
   */
  //mod 9735,9741,9729 再計算 guan start
  private void recalcByPat (String facilityCd, int executionNum, String patId,
                            List<Long> mstExamMainCd, List<Long> mstExamMainCdNot, List<Long> examMainCd, Map<String,String> rtnParams,
                            List<PatExamMain> patExamMains){
    String errExamMainCd = "";
    String isError = "false";
    try {
      //各検査結果の計算後に計算パフォーマンスに影響を与えないように、次回まで積み重ねる必要はありません。
      examMainCd = new ArrayList<>();
      for (PatExamMain  patExamMain : patExamMains) {
        JSONArray examResultInfo =  new JSONArray();
        if (patExamMain.getExamResultInfo() != null) {
          examResultInfo =  new JSONArray(patExamMain.getExamResultInfo());
        }
        boolean isUpdate = false;
        for (Long cd : mstExamMainCdNot) {
          for (int j = 0; j< examResultInfo.length(); j++) {
            if (cd == Long.parseLong(examResultInfo.getJSONObject(j).get("item_cd").toString())) {
              isUpdate = true;
            }
          }
          //isUpdate=falseの場合、その検査結果にチェックされていない計算式が存在しないことを表すので、その計算式は計算され、逆が存在する場合は計算する必要はありません
          if (!isUpdate) {
            mstExamMainCd.add(cd);
          }
          //判断後初期化isUpdate=false
          isUpdate = false;
          errExamMainCd = cd.toString();
        }
        examMainCd.add((patExamMain.getExamMainCd()));
        //再計算が必要な数式が存在する場合にのみ計算インタフェースが呼び出されます。そうしないと、不計算の原則に従って処理されます
        if (mstExamMainCd.size() > 0) {
          examResultCalcUtilService.calculate(examMainCd, mstExamMainCd);
          executionNum ++;
        }
        //各検査結果の計算後に計算パフォーマンスに影響を与えないように、次回まで積み重ねる必要はありません。
        examMainCd = new ArrayList<>();
      }
      //mod 9735,9741,9729 再計算 guan end
    } catch (Exception e ) {
      isError = "true";
      // 例外発生時にはログを記録
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      //患者情報取得
      PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(Long.valueOf(patId));
      eventLogMessage.setLogMessage("患者ID:" + patPersonalMain.getHosp_pat_id() + "の検査再計算処理中にエラーが発生しました。");
      eventLogMessage.setFacilityCd(facilityCd);
      eventLogMessage.setPatId(patId);
      eventLogMessage.setFunctionName("検査再計算");
      logService.log(LogLevel.MONGO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    } finally {
      rtnParams.put("executionNum", String.valueOf(executionNum));
      rtnParams.put("errExamMainCd", errExamMainCd);
      rtnParams.put("isError", isError);
    }
  }

//  /**
//   * 全患者を対象にスケジュール自動延長処理を行う
//   * @param startTime バッチ処理開始時刻
//   * @param endTime バッチ処理終了時刻
//   * @param patIdList 処理対象リスト
//   * @return true:処理完了 / false:処理中断
//   */
//  public boolean runScheduleExtend(LocalTime startTime, LocalTime endTime, List<Long> patIdList) {
//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage("スケジュール自動延長を開始しました");
//    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
//
//    boolean isComplete = true;
//    boolean isRestart = !patIdList.isEmpty();
//
//    // 対象日付：当日
//    String targetDt = DateTimeFormatter.ofPattern("uuuuMMdd").format(LocalDate.now());
//
//    // 入外区分更新処理バッチ稼働状況のチェック
//    MntBatchManager resultInOutUpdate = mntBatchManagerDao.selectByCtlNo(MntBatchManagerCtlNo.CTL_NO_SCHEDULE_EXTEND);
//    List<MntBatchManager> mntBatchManagerListAll = mntBatchManagerDao.selectAll();
//    // 終了されていないレコードがあれば処理を終了する
//    if (mntBatchManagerListAll.stream().anyMatch(e -> e.getStatus().equals("1"))) {
//      eventLogMessage.setLogMessage("前回バッチ処理中のため、スケジュール自動延長処理を終了しました");
//      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
//      return isComplete;
//    } else {
//
//      // 処理中断後の再開はチェックしない
//      if (!isRestart) {
//        Timestamp startDtToday = Timestamp.valueOf(targetDt.substring(0, 4) + "-" + targetDt.substring(4, 6) + "-" + targetDt.substring(6, 8) + " " + "00:00:00");
//        Timestamp endDtToday = Timestamp.valueOf(targetDt.substring(0, 4) + "-" + targetDt.substring(4, 6) + "-" + targetDt.substring(6, 8) + " " + "23:59:59");
//        if ((resultInOutUpdate.getStartTime() != null && resultInOutUpdate.getStartTime().after(startDtToday)) &&
//          (resultInOutUpdate.getEndTime() != null && resultInOutUpdate.getEndTime().before(endDtToday))) {
//          eventLogMessage.setLogMessage("本日分のバッチ処理済みのため、スケジュール自動延長処理を終了しました");
//          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
//          return isComplete;
//        }
//      }
//    }
//
//    // バッチ処理ステータス/開始時刻 を更新
//    resultInOutUpdate.setStatus("1");
//    resultInOutUpdate.setStartTime(new Timestamp(System.currentTimeMillis()));
//
//    mntBatchManagerDao.updateProcessStatus(resultInOutUpdate);
//
//
//
//    // 検索対象のスケジュール延長最終日(1年後の月末日)
//    String targetDate = DateTimeFormatter.ofPattern("uuuuMMdd").format(endDate);
//    // add 8008日次処理のスケジュール自動延長がされない患者が存在する。 赵 start
//    List<Long> delPatId = patMainDao.selectPatIdDelListBySchExtEndDate(targetDate);
//    if(delPatId.size()>0){
//      for(Long patId : delPatId){
//        PatMain delPatMain = new PatMain();
//        delPatMain.setPat_id(patId);
//        delPatMain.setSch_ext_end_date(endDate.format(DateTimeFormatter.ofPattern("yyyyMMdd")));
//        patMainDao.updatePatMain(delPatMain);
//      }
//    }
//    // add 8008日次処理のスケジュール自動延長がされない患者が存在する。 赵 end
//
//    List<Long> lstTargetPatId;
//    if (patIdList.isEmpty()) {
//      lstTargetPatId = patMainDao.selectPatIdListBySchExtEndDate(targetDate);
//      patIdList.addAll(lstTargetPatId);
//    } else {
//      lstTargetPatId = new ArrayList<Long>(patIdList);
//    }
//
//    List<PatTreatmentPatternPatMain> patTreatmentPatternFromDb = patTreatmentPatternDao.selectBySchExtEndDate(targetDate);
//    Map<Long, List<PatTreatmentPatternPatMain>> patTreatmentPatternByPatId = patTreatmentPatternFromDb.stream().collect(Collectors.groupingBy(o -> o.getPatId()));
//
//    // 患者ごとにスケジュール延長を行っていく
//    if (Objects.isNull(cache)) {
//      cache = new ScheduleExtendCache(patPersonalMainDao, mstTreatmentDao, patMainDao, mstFacilitySettingDao);
//      cache.init(lstTargetPatId);
//    }
//
//    for (Long patId : lstTargetPatId) {
//      // 時間帯チェック
//      if (LocalTime.now().isBefore(startTime) || LocalTime.now().plusMinutes(10).isAfter(endTime)) {
//        if (!isRestart) {
//          // 処理中断の場合
//          eventLogMessage.setLogMessage("解約削除の開始時間のため、処理を中断しました(" + startTime + "～" + endTime + ")");
//        } else {
//          eventLogMessage.setLogMessage("時間外のため、処理を中断しました(処理時間帯：" + startTime + "～" + endTime + ")");
//        }
//        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
//        break;
//      }
//
//      // 処理中であればスキップする
//      // LSS: 有待改进，一次性全部查出信息。
//      PatMain patMain = cache.getPatMainByPatId(patId);
//      // mod 8008日次処理のスケジュール自動延長がされない患者が存在する。20221018 赵 start
//      // if (patMain.getSch_ext_status().equals("1")) {
//      // continue;
//      // }
//      if (patMain != null) {
//        if (patMain.getSch_ext_status() != null && !"".equals(patMain.getSch_ext_status())) {
//          if (patMain.getSch_ext_status().equals("1")) {
//            continue;
//          }
//        } else {
//          continue;
//        }
//      } else {
//        continue;
//      }
//      // mod 8008日次処理のスケジュール自動延長がされない患者が存在する。20221018 赵 end
//      try {
//        // 患者の情報を1トランザクション内で更新する
//        if (patTreatmentPatternByPatId.containsKey(patId)) {
//          runScheduleExtendOnePatient(patId, patMain.getFacility_cd(), patTreatmentPatternByPatId.get(patId), patMain.getSch_ext_end_date());
//        } else {
//          runScheduleExtendOnePatient(patId, patMain.getFacility_cd(), null, patMain.getSch_ext_end_date());
//        }
//        // 処理済のpatIdはリストから削除
//        patIdList.remove(patId);
//      } catch (Exception e) {
//        // mod FNSI-改修内容#6013 周 start
//        //eventLogMessage.setLogMessage("エラーが発生したため、処理中患者をスキップしました(患者ID：" + patId + ")" + e);
//        eventLogMessage.setLogMessage("エラーが発生したため、処理中患者をスキップしました(患者ID：" + patId + ")" + e.getMessage());
//        // mod FNSI-改修内容#6013 周 end
//        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
//        patMain = patMainDao.selectById(patId);
//        if (patMain.getSch_ext_status().equals("1")) {
//          patMain.setSch_ext_status("0");
//          patMainDao.updatePatMain(patMain);
//        }
//        continue;
//      }
//    }
//
//    // 処理完了判定
//    isComplete = patIdList.size() == 0;
//
//    // バッチ処理ステータス/終了時刻 を更新
//    resultInOutUpdate.setStatus("0");
//    resultInOutUpdate.setEndTime(new Timestamp(System.currentTimeMillis()));
//
//    mntBatchManagerDao.updateProcessStatus(resultInOutUpdate);
//
//    eventLogMessage.setLogMessage("スケジュール自動延長を終了しました");
//    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
//
//    return isComplete;
//  }

  /**
   * 施設内患者を対象にスケジュール自動延長処理を行う
   * @param startTime バッチ処理開始時刻
   * @param endTime バッチ処理終了時刻
   * @param remainingTasks 処理残タスク
   * @return true:処理完了 / false:処理中断
   */
  public boolean runScheduleExtendForFacility(LocalTime startTime, LocalTime endTime, List<ScheduleExtendTask> remainingTasks) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("スケジュール自動延長を開始しました");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    boolean isComplete = true;
    boolean isRestart = !remainingTasks.isEmpty();

    // 対象日付：当日
    String targetDt = DateTimeFormatter.ofPattern("uuuuMMdd").format(LocalDate.now());

    // 入外区分更新処理バッチ稼働状況のチェック
    MntBatchManager resultInOutUpdate = mntBatchManagerDao.selectByCtlNo(MntBatchManagerCtlNo.CTL_NO_SCHEDULE_EXTEND);
    // modify 10994 by kangjie 20241028 start
    // List<MntBatchManager> mntBatchManagerListAll = mntBatchManagerDao.selectAll();
    // 終了されていないレコードがあれば処理を終了する
    // if (mntBatchManagerListAll.stream().anyMatch(e -> e.getStatus().equals("1"))) {
    if ("1".equals(resultInOutUpdate.getStatus())) {
      // modify 10994 by kangjie 20241028 start
      eventLogMessage.setLogMessage("前回バッチ処理中のため、スケジュール自動延長処理を終了しました");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return isComplete;
    } else {

      // 処理中断後の再開はチェックしない
      if (!isRestart) {
        Timestamp startDtToday = Timestamp.valueOf(targetDt.substring(0, 4) + "-" + targetDt.substring(4, 6) + "-" + targetDt.substring(6, 8) + " " + "00:00:00");
        Timestamp endDtToday = Timestamp.valueOf(targetDt.substring(0, 4) + "-" + targetDt.substring(4, 6) + "-" + targetDt.substring(6, 8) + " " + "23:59:59");
        if ((resultInOutUpdate.getStartTime() != null && resultInOutUpdate.getStartTime().after(startDtToday)) &&
          (resultInOutUpdate.getEndTime() != null && resultInOutUpdate.getEndTime().before(endDtToday))) {
          eventLogMessage.setLogMessage("本日分のバッチ処理済みのため、スケジュール自動延長処理を終了しました");
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          return isComplete;
        }
      }
    }

    // バッチ処理ステータス/開始時刻 を更新
    resultInOutUpdate.setStatus("1");
    resultInOutUpdate.setStartTime(new Timestamp(System.currentTimeMillis()));

    mntBatchManagerDao.updateProcessStatus(resultInOutUpdate);

    // 検索対象のスケジュール延長最終日(1年後の月末日)
    String targetDate = DateTimeFormatter.ofPattern("uuuuMMdd").format(endDate);
    // del 9281日次処理にて正しくスケジュールが作成されない事がある。 赵 start
    // add 8008日次処理のスケジュール自動延長がされない患者が存在する。 赵 start
//    List<Long> delPatId = patMainDao.selectPatIdDelListBySchExtEndDate(targetDate);
//    if(delPatId.size()>0){
//      for(Long patId : delPatId){
//        PatMain delPatMain = new PatMain();
//        delPatMain.setPat_id(patId);
//        delPatMain.setSch_ext_end_date(endDate.format(DateTimeFormatter.ofPattern("yyyyMMdd")));
//        patMainDao.updatePatMain(delPatMain);
//      }
//    }
    // add 8008日次処理のスケジュール自動延長がされない患者が存在する。 赵 end
    // del 9281日次処理にて正しくスケジュールが作成されない事がある。 赵 end

    List<ScheduleExtendTask> lstTasks;
    if (remainingTasks.isEmpty()) {
      // mod 10712 日次スケジュール自動延長処理の除外考慮修正 zkm start
//      lstTasks = mstFacilityDao.selectAll().stream().map(ScheduleExtendTask::new).collect(Collectors.toList());
      lstTasks = mstFacilityDao.selectAllOrderByMstSelector().stream().map(ScheduleExtendTask::new).collect(Collectors.toList());
      // mod 10712 日次スケジュール自動延長処理の除外考慮修正 zkm end
      remainingTasks.addAll(lstTasks);
    } else {
      lstTasks = new ArrayList<>(remainingTasks);
    }

//    List<PatTreatmentPatternPatMain> patTreatmentPatternFromDb = patTreatmentPatternDao.selectBySchExtEndDate(targetDate);
//    Map<Long, List<PatTreatmentPatternPatMain>> patTreatmentPatternByPatId = patTreatmentPatternFromDb.stream().collect(Collectors.groupingBy(o -> o.getPatId()));

    // 患者ごとにスケジュール延長を行っていく
//    if (Objects.isNull(cache)) {
//      cache = new ScheduleExtendCache(patPersonalMainDao, mstTreatmentDao, patMainDao, mstFacilitySettingDao);
//      cache.init(lstTargetPatId);
//    }

    for (ScheduleExtendTask task : lstTasks) {
      MstFacility facility = task.facility;
      // add 10378 by kangjie 20240522 start コンバートデータマッピング精査②
      if (Objects.equals(IS_SCHEXT_EXCEPTION,facility.getIsSchextException())) {
        continue;
      }
      // add 10378 by kangjie 20240522 end
      eventLogMessage.setLogMessage("施設スケジュール自動延長開始 facility = " + facility.getFacilityCd());
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

      List<PatTreatmentPatternPatMain> patTreatmentPatternFromDb = patTreatmentPatternDao.selectBySchExtEndDateAndFacilityCode(targetDate, facility.getFacilityCd());
      Map<Long, List<PatTreatmentPatternPatMain>> patTreatmentPatternByPatId = patTreatmentPatternFromDb.stream().collect(Collectors.groupingBy(o -> o.getPatId()));

      if (task.patIds.isEmpty()) {
        task.patIds = patMainDao.selectPadIdListByFacilityCodeAndSchExtEndDate(facility.getFacilityCd(), targetDate);
      }
      cache = new ScheduleExtendCache(patPersonalMainDao, mstTreatmentDao, patMainDao, mstFacilitySettingDao);
      cache.init(task.patIds);
      cache.addMstFacility(facility);//add #10196 ord_mainのデータ定義の修正 by shiyw

      boolean isBreak = false;
      List<Long> lstPatId = new ArrayList<>(task.patIds);
      for (Long patId : lstPatId) {
        eventLogMessage.setLogMessage("患者スケジュール自動延長開始 patId = " + patId.toString());
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        // 時間帯チェック
        if (LocalTime.now().isBefore(startTime) || LocalTime.now().plusMinutes(10).isAfter(endTime)) {
          if (!isRestart) {
            // 処理中断の場合
            eventLogMessage.setLogMessage("解約削除の開始時間のため、処理を中断しました(" + startTime + "～" + endTime + ")");
          } else {
            eventLogMessage.setLogMessage("時間外のため、処理を中断しました(処理時間帯：" + startTime + "～" + endTime + ")");
          }
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          isBreak = true;
          break;
        }

        // 処理中であればスキップする
        // LSS: 有待改进，一次性全部查出信息。
        PatMain patMain = cache.getPatMainByPatId(patId);
        // mod 8008日次処理のスケジュール自動延長がされない患者が存在する。20221018 赵 start
        // if (patMain.getSch_ext_status().equals("1")) {
        // continue;
        // }
        if (patMain != null) {
          if (patMain.getSch_ext_status() != null && !"".equals(patMain.getSch_ext_status())) {
            if (patMain.getSch_ext_status().equals("1")) {
              eventLogMessage.setLogMessage("スケジュール自動延長処理中のためスキップします。patId = " + patId.toString() + "sch_ext_status = " + patMain.getSch_ext_status());
              logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
              continue;
            }
          } else {
            eventLogMessage.setLogMessage("スケジュール延長処理ステータスが設定されていないためスキップします。patId = " + patId.toString() + "sch_ext_status = " + patMain.getSch_ext_status());
            logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            continue;
          }
        } else {
          eventLogMessage.setLogMessage("患者基本情報が存在しないためスキップします。patId = " + patId.toString());
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          continue;
        }
        // mod 8008日次処理のスケジュール自動延長がされない患者が存在する。20221018 赵 end
        try {
          // 患者の情報を1トランザクション内で更新する
          if (patTreatmentPatternByPatId.containsKey(patId)) {
            //mod 9281日次処理にて正しくスケジュールが作成されない事がある zhao start
//            runScheduleExtendOnePatient(patId, patMain.getFacility_cd(), patTreatmentPatternByPatId.get(patId), patMain.getSch_ext_end_date());
            runScheduleExtendOnePatient(patId, patMain.getFacility_cd(), patTreatmentPatternByPatId.get(patId), patMain.getSch_ext_end_date(),patMain);
            //mod 9281日次処理にて正しくスケジュールが作成されない事がある zhao end
          } else {
            //mod 9281日次処理にて正しくスケジュールが作成されない事がある zhao start
//            runScheduleExtendOnePatient(patId, patMain.getFacility_cd(), null, patMain.getSch_ext_end_date());
            runScheduleExtendOnePatient(patId, patMain.getFacility_cd(), null, patMain.getSch_ext_end_date(),patMain);
            //mod 9281日次処理にて正しくスケジュールが作成されない事がある zhao end
          }
        } catch (Exception e) {
          // mod FNSI-改修内容#6013 周 start
          //eventLogMessage.setLogMessage("エラーが発生したため、処理中患者をスキップしました(患者ID：" + patId + ")" + e);
          eventLogMessage.setLogMessage("エラーが発生したため、処理中患者をスキップしました(患者ID：" + patId + ")" + e.getMessage());
          // mod FNSI-改修内容#6013 周 end
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          patMain = patMainDao.selectById(patId);
          if (patMain.getSch_ext_status().equals("1")) {
            patMain.setSch_ext_status("0");
            patMainDao.updatePatMain(patMain);
          }
          continue;
        }
        task.patIds.remove(patId);
        eventLogMessage.setLogMessage("患者スケジュール自動延長終了 patId = " + patId.toString());
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      }
      if (isBreak) {
        break;
      }
      remainingTasks.remove(task);
      eventLogMessage.setLogMessage("施設スケジュール自動延長終了 facility = " + facility.getFacilityCd());
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }

    // 処理完了判定
    isComplete = remainingTasks.isEmpty();

    // バッチ処理ステータス/終了時刻 を更新
    resultInOutUpdate.setStatus("0");
    resultInOutUpdate.setEndTime(new Timestamp(System.currentTimeMillis()));

    mntBatchManagerDao.updateProcessStatus(resultInOutUpdate);

    eventLogMessage.setLogMessage("スケジュール自動延長を終了しました");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    return isComplete;
  }
    //mod 9281日次処理にて正しくスケジュールが作成されない事がある zhao start
    //private void runScheduleExtendOnePatient(Long patId, String facilityCd, List<PatTreatmentPatternPatMain> patTreatmentPatternList, String strSchExtEndDate) throws Exception {
    private void runScheduleExtendOnePatient(Long patId, String facilityCd, List<PatTreatmentPatternPatMain> patTreatmentPatternList, String strSchExtEndDate, PatMain patMain) throws Exception {
    //mod 9281日次処理にて正しくスケジュールが作成されない事がある zhao end

      // add 10712 日次スケジュール自動延長処理の除外考慮修正 zkm start
      // スケジュール処理ステータスをONにする
      patMain.setPat_id(patId);
      patMain.setSch_ext_status("1");
      patMainDao.updatePatMain(patMain);
      // add 10712 日次スケジュール自動延長処理の除外考慮修正 zkm end

    // @Transactionalではうまくいかなかったので、明示的にトランザクション管理を行う
    // トランザクション開始
    TransactionDefinition def = new DefaultTransactionDefinition();
    TransactionStatus status = transactionManager.getTransaction(def);

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("患者スケジュール自動延長トランザクション開始 patId = " + patId.toString());
    logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);

//    boolean isCommitted = false;

    List<JournalCreateRequestPayload> payloads = new ArrayList<>();

    try {
        //del 9281日次処理にて正しくスケジュールが作成されない事がある zhao start
//      PatMain patMain = new PatMain();
        //del 9281日次処理にて正しくスケジュールが作成されない事がある zhao end

      // スケジュール処理ステータスをONにする
      // HandsomeLin: 同一个事务内，最终肯定会被覆盖。
//      patMain.setPat_id(patId);
//      patMain.setSch_ext_status("1");
//      patMainDao.updatePatMain(patMain);

      List<OrdMain> toInsertOrdMains = new ArrayList<>();

      // 治療予定作成
      if (patTreatmentPatternList != null) {
        //mod 9281日次処理にて正しくスケジュールが作成されない事がある zhao start
//        List<OrdMain> ordMainList = createOrdMainList(patTreatmentPatternList, facilityCd);
        List<OrdMain> ordMainList = createOrdMainList(patTreatmentPatternList, facilityCd,patMain);
        //mod 9281日次処理にて正しくスケジュールが作成されない事がある zhao end

        // 同施設の本日以降のレコードを取得し、日付、クール、ベッドの重複チェックに使用する
        /* mod by 8242 zhangruixue 2023-05-17 --start */
//        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
//        Date currentTime = new Date();
//        List<OrdMain> ordMainInDbList = ordMainDao.selectScheduleExtendCheck(facilityCd, sdf.format(currentTime));
        // mod #11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) zkm start
//        List<OrdMain> ordMainInDbList = new ArrayList<>();
        List<OrdSchedule> dupulicateOrdScheduleList = new ArrayList<>();
        // mod #11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) zkm end
        // 日付、クール、ベッドが重複していた為、クールを未指定にして処理を行った予定を格納するリスト
        List<OrdMain> indChangeOrdList = new ArrayList<OrdMain>();

        // 重複チェック処理
        // 延長予定日・クール・ベッドが同じの場合、ベッドを外す
        Map<String, OrdMain> orderMainRepeatFlagMap = new HashMap<>();
        for (OrdMain ordMain : ordMainList) {
          // キー：治療日、クール、ベッド
          String key = ordMain.getTreatDate() + "-" + ordMain.getIndKurCd()+"-" + ordMain.getIndBedCd();
          if (orderMainRepeatFlagMap.containsKey(key)) {
            // 予定が重複しているので、ベッドを未登録にする
            ordMain.setIndBedCd(0);
            // 指示変更通知を出すリストに格納する
            indChangeOrdList.add(ordMain);
            eventLogMessage.setLogMessage("患者スケジュール自動延長 延長予定中重複ありのため、ベッド未登録に変更しました。 patId = " + patId.toString() +   "treatDate = " + ordMain.getTreatDate() +  "kurCd = " + ordMain.getIndKurCd());
            logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
          } else {
            orderMainRepeatFlagMap.put(key, ordMain);
          }
        }

        // 延長予定リストを元に、施設内既存予定との重複チェックを実施
        if(ordMainList.size() > 0){
          // チェックキー：治療予定日・クール・ベッドが同じ 且つ クール＞０・ベッド＞０ の場合
          // mod #11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) zkm start
//          ordMainInDbList = ordMainDao.selectScheduleExtendCheck(facilityCd,ordMainList);
          List<OrdScheduleNewKurPreview> ordScheduleList = ordMainList.stream().map(ord -> {
            OrdScheduleNewKurPreview ordSchedule = new OrdScheduleNewKurPreview();
            ordSchedule.setBedCd(Long.valueOf(ord.getIndBedCd()));
            ordSchedule.setKurCd(Long.valueOf(ord.getIndKurCd()));
            ordSchedule.setTreatDate(ord.getTreatDate());
            return ordSchedule;
          }).toList();
          dupulicateOrdScheduleList = ordScheduleDao.selectOrdScheduleWithNewKur(facilityCd, ordScheduleList, new ArrayList<>());
          // mod #11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) zkm end
        }

        // 施設内既存予定と重複している場合はベッドを外し、通知用リストへレコード追加
        // mod #11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) zkm start
//        if(ordMainInDbList.size() > 0){
//          eventLogMessage.setLogMessage("患者スケジュール自動延長 施設内他予定と重複あり。 patId = " + patId.toString() +   "治療予定日・クール・ベッド重複件数 = " + ordMainInDbList.size());
        if(!dupulicateOrdScheduleList.isEmpty()){
          eventLogMessage.setLogMessage("患者スケジュール自動延長 施設内他予定と重複あり。 patId = " + patId +   "治療予定日・クール・ベッド重複件数 = " + dupulicateOrdScheduleList.size());
          // mod #11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) zkm end
          logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);

          // mod #11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) zkm start
//          Map<String, OrdMain> orderMainInDbRepeatFlagMap = ordMainInDbList.stream().collect(Collectors.toMap(ordMain ->
//            ordMain.getTreatDate() + "-" + ordMain.getIndKurCd()+"-" + ordMain.getIndBedCd(),Function.identity()));
          Map<String, OrdSchedule> orderMainInDbRepeatFlagMap = dupulicateOrdScheduleList.stream().collect(Collectors.toMap(ordMain ->
            ordMain.getTreatDate() + "-" + ordMain.getKurCd()+"-" + ordMain.getBedCd(), Function.identity()));
          // mod #11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) zkm end

          for (OrdMain ordMain: ordMainList) {
            // キー：治療日、クール、ベッド
            String key = ordMain.getTreatDate() + "-" + ordMain.getIndKurCd()+"-" + ordMain.getIndBedCd();
            if(orderMainInDbRepeatFlagMap.containsKey(key)){
              // 予定が重複しているので、ベッドを未登録にする
              ordMain.setIndBedCd(0);
              // 指示変更通知を出すリストに格納する
              indChangeOrdList.add(ordMain);
              eventLogMessage.setLogMessage("患者スケジュール自動延長 予定重複のため、ベッド未登録に変更しました。 patId = " + patId.toString() +  "ordNo = " + ordMain.getOrdNo()  +  "treatDate = " + ordMain.getTreatDate() +  "kurCd = " + ordMain.getIndKurCd());
              logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
            }
          }
        }

        // 延長予定リストの中で、治療方法・治療日・クール・ベッドが同じのレコードは重複分を外す
        Set<String> ordMainSet = new HashSet<>();
        ordMainList.removeIf(ordMain -> {
          // キー：治療日、クール、ベッド、治療方法
          String key = ordMain.getTreatDate() + "-" + ordMain.getIndKurCd() + "-" + ordMain.getIndBedCd()+ "-" + ordMain.getIndTreatmentCd();
          if (ordMainSet.contains(key)) {
            // 指示変更通知を出すリストに格納する
            indChangeOrdList.add(ordMain);

            eventLogMessage.setLogMessage("患者スケジュール自動延長 治療方法・治療日・クール・ベッドが同じのレコードが存在するため、該当予定は除外とします。 patId = " + patId.toString() +   "treatmentCd = " + ordMain.getIndTreatmentCd() +   "treatDate = " + ordMain.getTreatDate() +  "kurCd = " + ordMain.getIndKurCd());
            logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);

            return true;
          } else {
            ordMainSet.add(key);

            return false;
          }
        });

        // すでに予定済みレコードと延長予定リストで治療方法・治療日・クール・ベッドが同じの重複チェック
        if(ordMainList.size() > 0){
          // チェックキー：patId・治療方法・治療予定日・クール・ベッドが同じの場合
          List<OrdMain> oneselfOrdMainInDbList = ordMainDao.selectOneselfScheduleExtendCheck(facilityCd,ordMainList);
          if(oneselfOrdMainInDbList.size() > 0){
            eventLogMessage.setLogMessage("患者スケジュール自動延長 patId・治療予定日・クール・ベッドが同じの予定あり。 patId = " + patId.toString() +   "patId・治療方法・治療予定日・クール・ベッド重複件数 = " + oneselfOrdMainInDbList.size());
            logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);

            // チェックキー：治療予定日・クール・ベッド・patId・治療方法
            Map<String, OrdMain> ordMainRepetCheckMap =oneselfOrdMainInDbList.stream().collect(Collectors.toMap(ordMain ->
                ordMain.getTreatDate() + "-" + ordMain.getIndKurCd() + "-" + ordMain.getIndBedCd() + "-" + ordMain.getPatId() + "-" + ordMain.getIndTreatmentCd(),
              Function.identity()
            ));

            Set<String> oneselfOrdMainSet = new HashSet<>();
            ordMainList.removeIf(ordMain -> {
              // キー：治療予定日・クール・ベッド・patId・治療方法
              String key = ordMain.getTreatDate() + "-" + ordMain.getIndKurCd() + "-" + ordMain.getIndBedCd() + "-" + ordMain.getPatId() + "-" + ordMain.getIndTreatmentCd();
              boolean isDuplicate = ordMainRepetCheckMap.containsKey(key) && oneselfOrdMainSet.contains(key);
              if (isDuplicate) {
                // 指示変更通知を出すリストに格納する
                indChangeOrdList.add(ordMain);

                eventLogMessage.setLogMessage("患者スケジュール自動延長 patId・治療方法・治療予定日・クール・ベッドが同じの予定が存在するため、該当予定は除外とします。 patId = " + patId.toString() +   "treatmentCd = " + ordMain.getIndTreatmentCd() +   "treatDate = " + ordMain.getTreatDate() +  "kurCd = " + ordMain.getIndKurCd());
                logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
              } else {
                oneselfOrdMainSet.add(key);
              }
              return isDuplicate;
            });

          }
        }
        toInsertOrdMains.addAll(ordMainList);

        // 指示変更通知内重複のレコードを除外する
        if(indChangeOrdList.size() > 0){
          eventLogMessage.setLogMessage("患者スケジュール自動延長 指示変更件数。 patId = " + patId.toString() +   "件数 = " + indChangeOrdList.size());
          logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);

          Set<String> rndChangeOrdSet = new HashSet<>();
          indChangeOrdList.removeIf(ordMain -> !rndChangeOrdSet.add(ordMain.getTreatDate() + "-" + ordMain.getIndKurCd() + "-" + ordMain.getIndBedCd()+ "-" + ordMain.getIndTreatmentCd()));

          eventLogMessage.setLogMessage("患者スケジュール自動延長 指示変更通知件数。 patId = " + patId.toString() +   "件数 = " + indChangeOrdList.size());
          logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
        }

        // 重複チェック処理
//        for (OrdMain ordMain: ordMainList) {
//          // クール、ベッド両方が指定されている場合は、重複チェックを行う
//          if (ordMain.getIndKurCd() > 0 && ordMain.getIndBedCd() > 0) {
//            // 生成した予約の枠が埋まっているかを確認 (同一日、同一クール、同一ベッド)
//            int doubleSize = ordMainInDbList.size() <= 0 ? 0 : ordMainInDbList.stream()
//              .filter(o -> (
//                o.getTreatDate().equals(ordMain.getTreatDate()) &&
//                  o.getIndKurCd().equals(ordMain.getIndKurCd()) &&
//                  o.getIndBedCd().equals(ordMain.getIndBedCd())
//              ))
//              .collect(Collectors.toList())
//              .size();
//            if (doubleSize > 0) {
//              // 予定が重複しているので、ベッドを未登録にする
//              ordMain.setIndBedCd(0);
//              // 指示変更通知を出すリストに格納する
//              indChangeOrdList.add(ordMain);
//
//              eventLogMessage.setLogMessage("患者スケジュール自動延長 予定重複のため、ベッド未登録に変更しました。 patId = " + patId.toString() +  "ordNo = " + ordMain.getOrdNo()  +  "treatDate = " + ordMain.getTreatDate() +  "kurCd = " + ordMain.getIndKurCd());
//              logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
//            } else {
//              // チェック対象リストに追加し、以降の予定でチェック対象になるようにする
//              ordMainInDbList.add(ordMain);
//            }
//          }
//          toInsertOrdMains.add(ordMain);
//        }
        /* mod 8242 by zhangruixue 2023-05-17 --end */

        insertOrdMainAndTrigger(toInsertOrdMains);
        //add #10196 Ord_Material_Save code implementation 20240130 ztc start
        if(toInsertOrdMains.size() > 0) {
          // mod #12250 ord_material_saveの処理を2回重複実行している zkm start
//          List<MaterialSaveCacheHandler.DiffResultContainer> diffMaterialSaveRstList = new ArrayList<>();
//          for (OrdMain ordMain : toInsertOrdMains) {
//            diffMaterialSaveRstList.add(
//              ordMaterialSaveService.updateOrdMaterialSaveByDiff(
//                new OrdMaterialSaveDto(
//                  ordMain.getOrdNo(),
//                  true,
//                  true,
//                  true,
//                  false,
//                  OrdMaterialSaveDto.IND_CLASS,
//                  ordMain
//                )));
//          }
//          ordMaterialSaveService.batchProcessingData(diffMaterialSaveRstList);
          ordMaterialSaveService.bulkUpdateByOrdNoInCondMediEquip(toInsertOrdMains.stream().map(OrdMain::getOrdNo).toList());
          // mod #12250 ord_material_saveの処理を2回重複実行している zkm end
        }
        //add #10196 Ord_Material_Save code implementation 20240130 ztc end
        // 予定が重複していた場合は指示変更通知を出す
        PatPersonalMain patPMObj = null;
        if (indChangeOrdList.size() > 0) {
          patPMObj = patPersonalMainDao.selectById(patId);

          JSONArray jsonArray = new JSONArray();
          for (OrdMain chgOrd: indChangeOrdList) {
            // 通知メッセージ及び付加情報の変換用JSONデータを作成 値は文字列型にすること
            JSONObject replaceData = new JSONObject();
            replaceData.put("HOSPPATID", Objects.isNull(patPMObj) ? "" : patPMObj.getHosp_pat_id());
            replaceData.put("LASTNAME", Objects.isNull(patPMObj) ? "" : patPMObj.getPat_last_name());
            replaceData.put("FIRSTNAME", Objects.isNull(patPMObj) ? "" : patPMObj.getPat_first_name());
            replaceData.put("TREATDATE", LocalDate.parse(chgOrd.getTreatDate(), DateTimeFormatter.ofPattern("yyyyMMdd")).format(DateTimeFormatter.ofPattern("yyyy/MM/dd")));
            replaceData.put("TREATMENTNAME", chgOrd.getIndTreatmentName());
            replaceData.put("PATID", patId.toString());
            replaceData.put("FACILITYCD", facilityCd);
            replaceData.put("DATE", chgOrd.getTreatDate());

            JSONObject jsonBody = new JSONObject();
            jsonBody.put("notificationNo", NotificationDefinition.INDICATION_CHANGE_IN_DAILY_PROC);
            jsonBody.put("facilityCd", facilityCd);
            // 変換用文字列のエンコード処理(UTF-8)
            String base64replaceData = new String(Base64.getEncoder().encode(replaceData.toString().getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8);
            jsonBody.put("replaceData", base64replaceData);
            jsonArray.put(jsonBody);
          }

          // 通知登録
          HttpStatus httpStatus = HttpStatus.OK;
          String message = null;
//          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("汎用通知レシーバー処理開始");
          try {
            logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
            ResponseEntity<?> response = notificationBatchService.genericNotificationsReceiver(jsonArray.toString());
            httpStatus = HttpStatus.valueOf(response.getStatusCode().value());
            if (HttpStatus.OK != httpStatus) {
              eventLogMessage.setLogMessage("汎用通知レシーバーへの接続失敗:" + status);
              logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
            }
          } catch (Exception e) {
            httpStatus = HttpStatus.INTERNAL_SERVER_ERROR;
            message = "汎用通知レシーバー処理で例外発生:" + e.getMessage();
            eventLogMessage.setLogMessage(message);
            logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
          }
          eventLogMessage.setLogMessage("汎用通知レシーバー処理終了");
          logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
        }

        // 生成レコードに対し、連携用のAPIをコール
//        try {
        for (OrdMain ordMain: ordMainList) {
          // クールが指定されている場合は連携イベントの発火が必要なので発火する
          if (ordMain.getIndKurCd().intValue() == 0) {
            continue;
          }
          JSONObject indScheduleUserInfoObject = new JSONObject(ordMain.getIndScheduleUserInfo());
          // mod FNSI-改修内容#6013 周 start
          //Long indUserId = Long.valueOf(indScheduleUserInfoObject.get("ind_user_id").toString());
          Long indUserId = indScheduleUserInfoObject.getLong("ind_user_id");
          // mod FNSI-改修内容#6013 周 end
          // 連携用のAPIをコール

          // Add By HandsomeLin At 2023/02/14 Start
          // #8242 連携処理の改善
          JournalCreateRequestPayload payload = new JournalCreateRequestPayload();
          payload.setFacilityCd(facilityCd);
          payload.setCoopCd("ind_dial");
          payload.setCoopCdIndex("");
          payload.setCrud("C");
          payload.setDirection("S");
          payload.setAnaResult("0");
          payload.setCoopResult("0");
          payload.setPatId(ordMain.getPatId());
          payload.setOrdNo(ordMain.getOrdNo());
          payload.setBaseDate(ordMain.getTreatDate());
          // mod 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 start
          //      payload.setOpeId(opeId);
          payload.setOpeCd("900001");
          // mod 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 end
          payload.setUserId(indUserId);
          payloads.add(payload);
          // Add By HandsomeLin At 2023/02/14 End

          // Del By HandsomeLin At 2023/02/14 Start
          // #8242 連携処理の改善
//            callCoopAPI(ordMain.getFacilityCd(), "ind_dial", "C", ordMain.getPatId(), ordMain.getOrdNo(), ordMain.getTreatDate(),
//                "900001", indUserId);
          // Del By HandsomeLin At 2023/02/14 End
        }
        // Add By HandsomeLin At 2023/02/14 Start
        // #8242 連携処理の改善
//          createJournalList(payloads);
        // Add By HandsomeLin At 2023/02/14 End
//        } catch (Exception e) {
//          EventLogMessage elm = new EventLogMessage();
//          elm.setLogMessage("連携イベント作成処理で例外発生： " + e.getMessage());
//          logService.log(LogLevel.ERROR, elm, null, SERVICE_NAME.FNSI, null);
//          e.printStackTrace();
//        }
        eventLogMessage.setLogMessage("患者スケジュール自動延長 治療予定の延長準備ができました。 patId = " + patId.toString() + " 件数 = " + ordMainList.size());
        logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      } else {
        eventLogMessage.setLogMessage("患者治療パターンが存在しないため、治療予定の延長をスキップします。 patId = " + patId.toString());
        logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      }

      // スケジュール延長開始日(pat_main.sch_ext_end_dateの翌日(nullの場合は当日))
      // mod FNSI-改修内容#6013 周 start
      LocalDate startDate = StringUtils.isEmpty(strSchExtEndDate) ? LocalDate.now() : LocalDate.parse(strSchExtEndDate, DateTimeFormatter.ofPattern("uuuuMMdd")).plusDays(1L);
      //LocalDate startDate = StringUtils.isEmpty(strSchExtEndDate) ? LocalDate.now() : LocalDate.parse(strSchExtEndDate, DateTimeFormatter.ofPattern("yyyy-MM-dd")).plusDays(1L);
      // mod FNSI-改修内容#6013 周 end
      // デフォルト指示者情報
      FacilitySettingInfo defaultDoctorInfo = cache.getFacilitySettingInfo(facilityCd);

      // 検査依頼作成
      examRequestScheduleExtendUtilService.createPatExamMain(
        patId,
        facilityCd,
        startDate.format(DateTimeFormatter.ofPattern("yyyy-MM-dd")),
        endDate.format(DateTimeFormatter.ofPattern("yyyy-MM-dd")),
        defaultDoctorInfo.getValue(),
        payloads
      );

      // 放射線検査依頼作成
      examRequestScheduleExtendUtilService.createPatRadMain(
        patId,
        facilityCd,
        startDate.format(DateTimeFormatter.ofPattern("yyyy-MM-dd")),
        endDate.format(DateTimeFormatter.ofPattern("yyyy-MM-dd")),
        defaultDoctorInfo.getValue(),
        payloads
      );

      // スケジュール延長最終日と処理ステータスを更新
      patMain.setSch_ext_end_date(endDate.format(DateTimeFormatter.ofPattern("yyyyMMdd")));
      patMain.setSch_ext_status("0");
      patMain.setPat_id(patId);
      patMainDao.updatePatMain(patMain);

      // コミット実行
      transactionManager.commit(status);
      eventLogMessage.setLogMessage("患者スケジュール自動延長トランザクションコミット patId = " + patId.toString());
      logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
    } catch (Exception e) {
      eventLogMessage.setLogMessage("患者スケジュール自動延長トランザクションロールバック patId = " + patId.toString() + " errmsg = " + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      // ロールバック処理実行
      transactionManager.rollback(status);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessageNew = new EventLogMessage();
      eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
      if (!StringUtils.isEmpty(facilityCd)) {
        eventLogMessageNew.setFacilityCd(facilityCd);
      }
      logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
      throw e;
    }
    eventLogMessage.setLogMessage("患者スケジュール自動延長連携ジャーナル作成呼び出し patId = " + patId.toString() + " 件数 = " + payloads.size());
    logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
    createJournalList(payloads);
  }
    //mod 9281日次処理にて正しくスケジュールが作成されない事がある zhao start
    //private List<OrdMain> createOrdMainList(List<PatTreatmentPatternPatMain> patTreatmentPatternList, String facilityCd) {
    private List<OrdMain> createOrdMainList(List<PatTreatmentPatternPatMain> patTreatmentPatternList, String facilityCd, PatMain patMain) {
    //mod 9281日次処理にて正しくスケジュールが作成されない事がある zhao end
    List<OrdMain> ordMainToInsert = new ArrayList<OrdMain>();
    // mod FNSI-改修内容#6013 周 start
    //Map<String, List<PatTreatmentPatternPatMain>> patTreatmentPatternByTreatmentAndKur = patTreatmentPatternList.stream().collect(Collectors.groupingBy(o -> "T:" + o.getIndTreatmentCd() + "K:" + o.getIndKurCd()));
    Map<String, List<PatTreatmentPatternPatMain>> patTreatmentPatternByTreatmentAndKur = patTreatmentPatternList.stream().collect(Collectors.groupingBy(o -> "T:" + o.getPatId() + "K:" + o.getCtlNo()));
    // mod FNSI-改修内容#6013 周 end
    List<MstTreatment> treatmentList = cache.getMstTreatmentList(facilityCd);

    // 「治療方法 + クール」ごとに治療パターンをグループ化して治療予定データを加工していく
    for (String treatmentAndKur : patTreatmentPatternByTreatmentAndKur.keySet()) {
      List<PatTreatmentPatternPatMain> treatmentAndKurList = patTreatmentPatternByTreatmentAndKur.get(treatmentAndKur);
      Map<Integer, PatTreatmentPatternPatMain> patTreatPatternListByTreatWeek = treatmentAndKurList.stream().collect(Collectors.toMap(o -> (int)o.getTreatWeek(), o -> o));
      //9281mod 日次処理にて正しくスケジュールが作成されない事がある zhao start
      LocalDate treatDate = LocalDate.parse(patTreatmentPatternList.get(0).getSchExtEndDate(), DateTimeFormatter.ofPattern("yyyyMMdd")).plusDays(1);
      //LocalDate treatDateTemp = LocalDate.parse(ordMainDao.selectMaxTreatmentDate(patTreatmentPatternList.get(0).getPatId().toString(),facilityCd), DateTimeFormatter.ofPattern("yyyyMMdd"));
      //treatDateTemp = treatDateTemp.isBefore(LocalDate.now()) ? LocalDate.now():treatDateTemp;
      //LocalDate treatDate = treatDateTemp.plusDays(1);
      //9281mod 日次処理にて正しくスケジュールが作成されない事がある zhao end

      // スケジュール延長最終日から今日の1年後の月末日まで
      while (treatDate.isBefore(endDate) || treatDate.isEqual(endDate)) {
        PatTreatmentPatternPatMain patTreatmentPattern = patTreatPatternListByTreatWeek.get(treatDate.getDayOfWeek().getValue());

        if (null != patTreatmentPattern) {
          Boolean isSkip = false;

          // 治療種別「隔日」のチェック
          if (2 == patTreatmentPattern.getTreatType()) {
            LocalDate indTreatStartDate = LocalDate.parse(patTreatmentPattern.getIndTreatStartDate(), DateTimeFormatter.ofPattern("yyyyMMdd"));
            Boolean isStartDateMWFS = indTreatStartDate.getDayOfWeek() == DayOfWeek.MONDAY || indTreatStartDate.getDayOfWeek() == DayOfWeek.WEDNESDAY || indTreatStartDate.getDayOfWeek() == DayOfWeek.FRIDAY || indTreatStartDate.getDayOfWeek() == DayOfWeek.SUNDAY;
            Boolean isStartDateTTHS = indTreatStartDate.getDayOfWeek() == DayOfWeek.TUESDAY || indTreatStartDate.getDayOfWeek() == DayOfWeek.THURSDAY || indTreatStartDate.getDayOfWeek() == DayOfWeek.SATURDAY;
            Boolean isTreatDateMWFS = treatDate.getDayOfWeek() == DayOfWeek.MONDAY || treatDate.getDayOfWeek() == DayOfWeek.WEDNESDAY || treatDate.getDayOfWeek() == DayOfWeek.FRIDAY || treatDate.getDayOfWeek() == DayOfWeek.SUNDAY;
            Boolean isTreatDateTTHS = treatDate.getDayOfWeek() == DayOfWeek.TUESDAY || treatDate.getDayOfWeek() == DayOfWeek.THURSDAY || treatDate.getDayOfWeek() == DayOfWeek.SATURDAY;
            Boolean isSameAsStartDate = ChronoUnit.WEEKS.between(indTreatStartDate.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY)), treatDate) % 2 == 0;

            if (
              (isTreatDateMWFS && isStartDateMWFS && !isSameAsStartDate) ||
                (isTreatDateMWFS && isStartDateTTHS && isSameAsStartDate) ||
                (isTreatDateTTHS && isStartDateMWFS && isSameAsStartDate) ||
                (isTreatDateTTHS && isStartDateTTHS && !isSameAsStartDate)
            ) {
              isSkip = true;
            }
          }

          // 治療種別「隔週」のチェック
          if (3 == patTreatmentPattern.getTreatType()) {
            LocalDate indTreatStartDate = LocalDate.parse(patTreatmentPattern.getIndTreatStartDate(), DateTimeFormatter.ofPattern("yyyyMMdd"));
            Boolean isBiweekly = ChronoUnit.WEEKS.between(indTreatStartDate.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY)), treatDate) % 2 == 0;

            if (!isBiweekly) {
              isSkip = true;
            }
          }

          if (!isSkip) {
            // pat_treatment_patternからのJSONデータ
            JSONObject indSchInfo = new JSONObject(patTreatmentPattern.getIndSchInfo());
            // mod bug 6968 修正 chen start
            JSONObject indCondInfo = null == patTreatmentPattern.getIndCondInfo() ?
              new JSONObject() :
              new JSONObject(patTreatmentPattern.getIndCondInfo());
            // JSONObject indCondInfo = new JSONObject(patTreatmentPattern.getIndCondInfo());
            // mod bug 6968 修正 chen end

            // ord_mainへのカラムデータ
            String indTreatStartTime = indSchInfo.isNull("ind_treat_start_time") ? null : indSchInfo.getString("ind_treat_start_time");
            Integer indBedCd = indSchInfo.isNull("ind_bed_cd") ? null : indSchInfo.getInt("ind_bed_cd");
            Integer indVaCd = null;
            if (!indCondInfo.isNull("2")) {
              indVaCd = indCondInfo.getJSONObject("2").isNull("value") ? null : indCondInfo.getJSONObject("2").getInt("value");
            }
            // del #10196 ord_mainのデータ定義の修正：予定作成時pat _treatment_pattern.ind_sch_infoは正しく構築されており、ここでは処理する必要はありません  IES_shiyw 2024-01-22 --start
//            JSONObject indScheduleUserInfo = new JSONObject();
//            indScheduleUserInfo.put("ind_user_id", indSchInfo.isNull("ind_user_id") ? JSONObject.NULL : indSchInfo.getInt("ind_user_id"));
//            indScheduleUserInfo.put("ind_user_last_name", JSONObject.NULL);
//            indScheduleUserInfo.put("ind_user_first_name", JSONObject.NULL);
//            indScheduleUserInfo.put("upd_user_id", indSchInfo.isNull("upd_user_id") ? JSONObject.NULL : indSchInfo.getInt("upd_user_id"));
//            indScheduleUserInfo.put("upd_user_last_name", JSONObject.NULL);
//            indScheduleUserInfo.put("upd_user_first_name", JSONObject.NULL);
            // del #10196 ord_mainのデータ定義の修正：予定作成時pat _treatment_pattern.ind_sch_infoは正しく構築されており、ここでは処理する必要はありません  IES_shiyw 2024-01-22 --end
            // mod 8008日次処理のスケジュール自動延長がされない患者が存在する。赵 20221018 start
            //String indMediInfo = createIndMediInfo(patTreatmentPattern.getIndMediInfo(), treatDate, false);
            JSONArray retArr = new JSONArray();
            String indMediInfo = retArr.toString();
            if (patTreatmentPattern.getIndMediInfo() != null && !"".equals(patTreatmentPattern.getIndMediInfo()) && !"[]".equals(patTreatmentPattern.getIndMediInfo())) {
              indMediInfo = createIndMediInfo(patTreatmentPattern.getIndMediInfo(), treatDate, false);
            }
            // mod 8008日次処理のスケジュール自動延長がされない患者が存在する。赵 20221018 end
            // 治療方法名の取得
            MstTreatment mstTretObj = null;
            if (treatmentList.size() > 0) {
              mstTretObj = treatmentList.stream().filter(o -> o.getTreatmentCd().equals(patTreatmentPattern.getIndTreatmentCd())).findFirst().get();
            }
            //add 9281日次処理にて正しくスケジュールが作成されない事がある zhao start
            JSONObject tareJson = new JSONObject(patMain.getTare_info());
            String tareInfo = tareJson.get(patTreatmentPattern.getTreatWeek().toString()).toString();
            JSONObject offWaterJson = new JSONObject(patMain.getOff_water_info());
            String offWaterInfo = offWaterJson.get(patTreatmentPattern.getTreatWeek().toString()).toString();
            //add 9281日次処理にて正しくスケジュールが作成されない事がある zhao end
            // インサートデータ
            OrdMain ordMain = new OrdMain();
            ordMain.setPatId(patTreatmentPattern.getPatId());
            /* add by shiyw 2024-01-29 [#10196]ord_mainのデータ定義の修正 --start */
            PatPersonalMain patPersonalMain = cache.getPatPersonalMainByPatId(patMain.getPat_id());
            ordMain.setFnPatId(patPersonalMain.getFn_pat_id() == null? null : String.valueOf(patPersonalMain.getFn_pat_id()));
            /* add by shiyw 2024-01-29 [#10196]ord_mainのデータ定義の修正 --end */
            ordMain.setTreatDate(treatDate.format(DateTimeFormatter.ofPattern("yyyyMMdd")));
            ordMain.setTreatWeek(patTreatmentPattern.getTreatWeek());
            ordMain.setFacilityCd(patTreatmentPattern.getFacilityCd());
            ordMain.setFacilityName(cache.getMstFacility(patTreatmentPattern.getFacilityCd()).getFacilityName()); //add #10196 ord_mainのデータ定義の修正 IES_shiyw 2024-01-22
            ordMain.setIndVaCd(indVaCd);
            ordMain.setIndTreatmentCd(patTreatmentPattern.getIndTreatmentCd());
            //mod #10196 ord_mainのデータ定義の修正 by shiyw --start
            //ordMain.setIndTreatmentName(Objects.isNull(mstTretObj) ? null : mstTretObj.getTreatmentName());
            ordMain.setIndTreatmentName(null);
            //mod #10196 ord_mainのデータ定義の修正 by shiyw --end
            if(patTreatmentPattern.getIndKurCd() != null){
              ordMain.setIndKurCd(patTreatmentPattern.getIndKurCd().intValue());
            }else {
              ordMain.setIndKurCd(0);
            }
            if(indBedCd != null){
              ordMain.setIndBedCd(indBedCd);
            }else {
              ordMain.setIndBedCd(0);
            }
            ordMain.setIndTreatStartTime(indTreatStartTime);
            //mod #10196 ord_mainのデータ定義の修正：予定作成時pat _treatment_pattern.ind_sch_infoは正しく構築されており、ここでは処理する必要はありません  IES_shiyw 2024-01-22 --start
//            ordMain.setIndScheduleUserInfo(indScheduleUserInfo.toString());
            //mod 10860 ind_schedule_user_infoのデータ不正 zhao start
            //ordMain.setIndScheduleUserInfo(patTreatmentPattern.getIndSchInfo());
            JSONObject indScheduleUserInfo = new JSONObject(patTreatmentPattern.getIndSchInfo());
            indScheduleUserInfo.remove("ind_bed_cd");
            indScheduleUserInfo.remove("ind_treat_start_time");
            ordMain.setIndScheduleUserInfo(indScheduleUserInfo.toString());
            //mod 10860 ind_schedule_user_infoのデータ不正 zhao end
            //mod #10196 ord_mainのデータ定義の修正：予定作成時pat _treatment_pattern.ind_sch_infoは正しく構築されており、ここでは処理する必要はありません  IES_shiyw 2024-01-22 --end
            ordMain.setIndCondInfo(patTreatmentPattern.getIndCondInfo());
            ordMain.setIndMediInfo(indMediInfo);
            ordMain.setIndEquipInfo(patTreatmentPattern.getIndEquipInfo());
            ordMain.setIndIndCommentInfo(patTreatmentPattern.getIndIndCommentInfo());
            //mod 9281日次処理にて正しくスケジュールが作成されない事がある zhao start
            //ordMain.setIndTareInfo(patTreatmentPattern.getIndTareInfo());
            //ordMain.setIndOffWaterInfo(patTreatmentPattern.getIndOffWaterInfo());
            ordMain.setIndTareInfo(tareInfo);
            ordMain.setIndOffWaterInfo(offWaterInfo);
            //mod 9281日次処理にて正しくスケジュールが作成されない事がある zhao end
            ordMain.setIndDeviceSetInfo(patTreatmentPattern.getIndDeviceSetInfo());
            ordMain.setTreatType(patTreatmentPattern.getTreatType());
            ordMain.setRstEdition(0);
            ordMain.setRstDialysisState("0");
            ordMain.setIsDel("0");
            //add #10196 ord_mainのデータ定義の修正 by shiyw -- start
            Long ind_user_id = indSchInfo.isNull("ind_user_id") ? null : indSchInfo.getLong("ind_user_id");
            Long upd_user_id = indSchInfo.isNull("upd_user_id") ? null : indSchInfo.getLong("upd_user_id");
            ordMain.setRstIsUpdateEdition(null);
            ordMain.setIsConfirm("0");
            ordMain.setUpIndUserId(ind_user_id);
            ordMain.setUpUserId(upd_user_id);
            ordMain.setBvmsPath(null);
            //add #10196 ord_mainのデータ定義の修正 by shiyw -- end
            //add 10615 月跨ぎの日次処理にて自動作成されたord_mainのreg_dateがNULL zhao start
            Timestamp regDateNow = new Timestamp(System.currentTimeMillis());
            ordMain.setRegDate(regDateNow);
            ordMain.setUpDate(regDateNow);
            //add 10615 月跨ぎの日次処理にて自動作成されたord_mainのreg_dateがNULL zhao end
            ordMainToInsert.add(ordMain);
          }
        }

        //　投与薬剤「1回／月：最終治療日」のチェック
        if (ordMainToInsert.size() > 0 && treatDate.getMonth() != treatDate.plusDays(1).getMonth()) {
          OrdMain lastTreat = ordMainToInsert.get(ordMainToInsert.size() - 1);
          LocalDate lastDate = LocalDate.parse(lastTreat.getTreatDate(), DateTimeFormatter.ofPattern("yyyyMMdd"));
          PatTreatmentPatternPatMain lastPattern = patTreatPatternListByTreatWeek.get(lastDate.getDayOfWeek().getValue());
          // mod 8008日次処理のスケジュール自動延長がされない患者が存在する。赵 20221018 start
          //lastTreat.setIndMediInfo(createIndMediInfo(lastPattern.getIndMediInfo(), lastDate, true));
          // mod 7919コンバートされた施設でスケジュール延長が反映されていない limingyang 20230130 start
          //if (lastPattern.getIndMediInfo() != null && "".equals(lastPattern.getIndMediInfo())) {
          if (lastPattern != null && lastPattern.getIndMediInfo() != null && !"".equals(lastPattern.getIndMediInfo()) && !"[]".equals(lastPattern.getIndMediInfo())) {
            // mod 7919コンバートされた施設でスケジュール延長が反映されていない limingyang 20230130 end
            lastTreat.setIndMediInfo(createIndMediInfo(lastPattern.getIndMediInfo(), lastDate, true));
          }
          // mod 8008日次処理のスケジュール自動延長がされない患者が存在する。赵 20221018 end
        }

        treatDate = treatDate.plusDays(1);
      }
    }

    return ordMainToInsert;
  }

  /**
   * 指定投与間隔により登録する投与薬剤を取得
   * @param indMediInfo 投与薬剤情報
   * @param treatDate　治療日
   * @param isLastTreatDate 最終治療日フラグ
   */
  private String createIndMediInfo(String indMediInfo, LocalDate treatDate, Boolean isLastTreatDate) {
    JSONArray mediArr = new JSONArray(indMediInfo);
    JSONArray retArr = new JSONArray();

    for (int i = 0; i < mediArr.length(); i++) {
      // 投与薬剤情報
      JSONObject medi = mediArr.getJSONObject(i);
      // 初回投与日
      /* add  by zhangruixue 2023-04-04  --start */
      if(medi.get("init_date") == null || "null".equals(medi.get("init_date").toString()) || "".equals(medi.get("init_date").toString())
        || medi.get("date_interval") == null || "null".equals(medi.get("date_interval").toString()) || "".equals(medi.get("date_interval"))){
        continue;
      }
      /* add  by zhangruixue 2023-04-04  --end */
      // add #6014 日次処理の削除処理が正常動作しない 赵 start
      if (medi.getString("init_date") == null || "".equals(medi.getString("init_date"))) {
        continue;
      }
      // add #6014 日次処理の削除処理が正常動作しない 赵 end
      LocalDate initDate = LocalDate.parse(medi.getString("init_date"), DateTimeFormatter.ofPattern("yyyyMMdd")).with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));

      // 投与間隔
      switch (medi.getInt("date_interval")) {
        // 毎回
        case 0:
          // 毎週
        case 1:
          retArr.put(medi);
          break;
        // 1回／2週
        case 2:
          if (0 == ChronoUnit.WEEKS.between(initDate, treatDate) % 2) {
            retArr.put(medi);
          }
          break;
        // 1回／3週
        case 3:
          if (0 == ChronoUnit.WEEKS.between(initDate, treatDate) % 3) {
            retArr.put(medi);
          }
          break;
        // 1回／4週
        case 4:
          if (0 == ChronoUnit.WEEKS.between(initDate, treatDate) % 4) {
            retArr.put(medi);
          }
          break;
        // 1回／月：第1曜日
        case 5:
          if (treatDate.equals(treatDate.with(TemporalAdjusters.dayOfWeekInMonth(1, treatDate.getDayOfWeek())))) {
            retArr.put(medi);
          }
          break;
        // 1回／月：第2曜日
        case 6:
          if (treatDate.equals(treatDate.with(TemporalAdjusters.dayOfWeekInMonth(2, treatDate.getDayOfWeek())))) {
            retArr.put(medi);
          }
          break;
        // 1回／月：第3曜日
        case 7:
          if (treatDate.equals(treatDate.with(TemporalAdjusters.dayOfWeekInMonth(3, treatDate.getDayOfWeek())))) {
            retArr.put(medi);
          }
          break;
        // 1回／月：第4曜日
        case 8:
          if (treatDate.equals(treatDate.with(TemporalAdjusters.dayOfWeekInMonth(4, treatDate.getDayOfWeek())))) {
            retArr.put(medi);
          }
          break;
        // 1回／月：最終曜日
        case 9:
          if (treatDate.getDayOfMonth() >= treatDate.lengthOfMonth() - 6) {
            retArr.put(medi);
          }
          break;
        // 1回／月：最終治療日
        case 10:
          if (isLastTreatDate) {
            retArr.put(medi);
          }
          break;
        default:
          break;
      }
    }

    return retArr.toString();
  }

  /**
   * ログイン無効化処理
   */
  public void runDisableLogin() {

    // 開始ログ
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("ログイン無効化処理を開始しました");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    // バッチ稼働状況のチェック
    MntBatchManager stopLogin = mntBatchManagerDao.selectByCtlNo(MntBatchManagerCtlNo.CTL_NO_STOP_LOGIN);
    // modify 10994 by kangjie 20241028 start
    // List<MntBatchManager> mntBatchManagerListAll = mntBatchManagerDao.selectAll();
    // if (mntBatchManagerListAll.stream().anyMatch(e -> ("1".equals(e.getStatus()) && "1".equals(e.getDivision())))) {
    if ("1".equals(stopLogin.getStatus())
      && "1".equals(stopLogin.getDivision())) {
      // modify 10994 by kangjie 20241028 end
      // 処理中の場合
      eventLogMessage.setLogMessage("前回バッチ処理中のため、ログイン無効化処理を終了しました");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return;
    } else {
      // 処理中でない場合は、処理時間をチェック
      // 対象日付：当日
      String targetDt = DateTimeFormatter.ofPattern("uuuuMMdd").format(LocalDate.now());
      Timestamp startDtToday = Timestamp.valueOf(targetDt.substring(0, 4) + "-" + targetDt.substring(4, 6) + "-" + targetDt.substring(6, 8) + " " + "00:00:00");
      Timestamp endDtToday = Timestamp.valueOf(targetDt.substring(0, 4) + "-" + targetDt.substring(4, 6) + "-" + targetDt.substring(6, 8) + " " + "23:59:59");
      if ((stopLogin.getStartTime() != null && stopLogin.getStartTime().after(startDtToday)) &&
        (stopLogin.getEndTime() != null && stopLogin.getEndTime().before(endDtToday))) {
        eventLogMessage.setLogMessage("本日分のバッチ処理済のため、ログイン無効化処理を終了しました");
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        return;
      }
    }

    // バッチ処理ステータス/開始時刻 を更新
    stopLogin.setStatus("1");
    stopLogin.setStartTime(new Timestamp(System.currentTimeMillis()));

    mntBatchManagerDao.updateProcessStatus(stopLogin);

    try {
      // ログイン無効化処理
      facilityCancelService.disableLogin();
    } catch (Exception e) {
      // 例外発生時にはログを記録
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }

    // バッチ処理ステータス/終了時刻 を更新
    stopLogin.setStatus("0");
    stopLogin.setEndTime(new Timestamp(System.currentTimeMillis()));

    mntBatchManagerDao.updateProcessStatus(stopLogin);

    // 終了ログ
    eventLogMessage.setLogMessage("ログイン無効化処理を終了しました");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
  }

  /**
   * データ削除処理起動
   * @param startTime バッチ処理開始時刻
   * @param endTime バッチ処理終了時刻
   */
  public void runDeleteFacility(LocalTime startTime, LocalTime endTime) {

    // 開始ログ
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("データ削除処理を開始しました");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    // バッチ稼働状況のチェック
    MntBatchManager deleteFacility = mntBatchManagerDao.selectByCtlNo(MntBatchManagerCtlNo.CTL_NO_DELETE_FACILITY);
    // modify 10994 by kangjie 20241028 start
    // List<MntBatchManager> mntBatchManagerListAll = mntBatchManagerDao.selectAll();
    // if (mntBatchManagerListAll.stream().anyMatch(e -> "1".equals(e.getStatus()))) {
    if ("1".equals(deleteFacility.getStatus())){
      // modify 10994 by kangjie 20241028 end
      // 処理中の場合
      eventLogMessage.setLogMessage("前回バッチ処理中のため、データ削除処理を終了しました");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return;
    } else {
      // 処理中でない場合は、処理時間をチェック
      // 対象日付：当日
      String targetDt = DateTimeFormatter.ofPattern("uuuuMMdd").format(LocalDate.now());
      Timestamp startDtToday = Timestamp.valueOf(targetDt.substring(0, 4) + "-" + targetDt.substring(4, 6) + "-" + targetDt.substring(6, 8) + " " + "00:00:00");
      Timestamp endDtToday = Timestamp.valueOf(targetDt.substring(0, 4) + "-" + targetDt.substring(4, 6) + "-" + targetDt.substring(6, 8) + " " + "23:59:59");
      if ((deleteFacility.getStartTime() != null && deleteFacility.getStartTime().after(startDtToday)) &&
        (deleteFacility.getEndTime() != null && deleteFacility.getEndTime().before(endDtToday))) {
        eventLogMessage.setLogMessage("本日分のバッチ処理済のため、データ削除処理を終了しました");
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        return;
      }
    }

    // バッチ処理ステータス/開始時刻 を更新
    deleteFacility.setStatus("1");
    deleteFacility.setStartTime(new Timestamp(System.currentTimeMillis()));

    mntBatchManagerDao.updateProcessStatus(deleteFacility);

    // 施設解約バックアップ
    boolean isTimeout = facilityBackup(startTime, endTime);

    // 施設解約
    if (!isTimeout) {
      isTimeout = facilityCancel(startTime, endTime);
    }

    // 期間外削除
    if (!isTimeout) {
      facilityExpire(startTime, endTime);
    }

    // バッチ処理ステータス/終了時刻 を更新
    deleteFacility.setStatus("0");
    deleteFacility.setEndTime(new Timestamp(System.currentTimeMillis()));

    mntBatchManagerDao.updateProcessStatus(deleteFacility);

    // 終了ログ
    eventLogMessage.setLogMessage("データ削除処理を終了しました");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
  }

  /**
   * 施設解約バックアップの実行
   * @param startTime バッチ処理開始時刻
   * @param endTime バッチ処理終了時刻
   */
  private boolean facilityBackup(LocalTime startTime, LocalTime endTime) {

    // 開始ログ
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("--- 施設解約バックアップを開始しました");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    boolean isTimeout = false;

    if (LocalTime.now().isBefore(startTime) || LocalTime.now().isAfter(endTime)) {
      // 時間帯が終了している場合
      eventLogMessage.setLogMessage("時間外のため、処理を中断しました(処理時間帯：" + startTime + "～" + endTime + ")");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

      isTimeout = true;
    } else {
      // 残り時間を分で取得
      Long expiration = ChronoUnit.MINUTES.between(LocalTime.now(), endTime);
      if (expiration.compareTo(1L) < 0) {
        // 残り時間が1分ない場合、実行上限時間を補正
        expiration = 1L;
      }
      eventLogMessage.setLogMessage("--- 施設解約バックアップ 実行上限(単位：分): "  + expiration);
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);

      try {
        // 施設解約のバックアップ
        // mod 8008日次処理のスケジュール自動延長がされない患者が存在する。 赵 start
        //facilityCancelService.backup(expiration);
        facilityCancelService.backup(expiration,startTime,endTime);
        // mod 8008日次処理のスケジュール自動延長がされない患者が存在する。 赵 end
      } catch (Exception e) {
        String msg = StringUtils.isEmpty(e.getMessage())? "施設解約バックアップ処理でエラーが発生しました。" : e.getMessage();
        eventLogMessage.setLogMessage(msg);
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      }
    }

    // 終了ログ
    eventLogMessage.setLogMessage("--- 施設解約バックアップ処理を終了しました");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    return isTimeout;
  }

  /**
   * 施設解約の実行
   * @param startTime バッチ処理開始時刻
   * @param endTime バッチ処理終了時刻
   */
  private boolean facilityCancel(LocalTime startTime, LocalTime endTime) {

    // 開始ログ
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("--- 施設解約を開始しました");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    boolean isTimeout = false;

    if (LocalTime.now().isBefore(startTime) || LocalTime.now().isAfter(endTime)) {
      // 時間帯が終了している場合
      eventLogMessage.setLogMessage("時間外のため、処理を中断しました(処理時間帯：" + startTime + "～" + endTime + ")");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

      isTimeout = true;
    } else {
      // 残り時間を分で取得
      Long expiration = ChronoUnit.MINUTES.between(LocalTime.now(), endTime);
      if (expiration.compareTo(1L) < 0) {
        // 残り時間が1分ない場合、実行上限時間を補正
        expiration = 1L;
      }
      eventLogMessage.setLogMessage("--- 施設解約 実行上限(単位：分): "  + expiration);
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);

      try {
        // 施設解約処理実行
        facilityCancelService.execute(expiration,startTime,endTime);
      } catch (Exception e) {
        String msg = StringUtils.isEmpty(e.getMessage())? "施設解約処理でエラーが発生しました。" : e.getMessage();
        eventLogMessage.setLogMessage(msg);
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      }
    }

    // 終了ログ
    eventLogMessage.setLogMessage("--- 施設解約処理を終了しました");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    return isTimeout;
  }


  /**
   * 期間外削除の実行
   * @param startTime バッチ処理開始時刻
   * @param endTime バッチ処理終了時刻
   */
  private void facilityExpire(LocalTime startTime, LocalTime endTime) {

    // 開始ログ
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("--- 期間外削除処理を開始しました");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    if (LocalTime.now().isBefore(startTime) || LocalTime.now().isAfter(endTime)) {
      // 時間帯が終了している場合
      eventLogMessage.setLogMessage("時間外のため、処理を中断しました(処理時間帯：" + startTime + "～" + endTime + ")");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    } else {
      try {
        // 期間外削除処理(REMSのみ施設)
        facilityExpireService.executeExpire(LocalDateTime.now(), endTime, 1, null,startTime);

        // 期間外削除処理(FNSiを含む施設)
        facilityExpireService.executeExpire(LocalDateTime.now(), endTime, 2, null,startTime);
      } catch (Exception e) {
        String msg = StringUtils.isEmpty(e.getMessage())? "期間外削除処理でエラーが発生しました。" : e.getMessage();
        eventLogMessage.setLogMessage(msg);
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      }
    }

    // 終了ログ
    eventLogMessage.setLogMessage("--- 期間外削除処理を終了しました");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
  }

  /**
   * 連携用のAPIコール処理
   */
// mod 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 start
//  public void callCoopAPI(String facilityCd, String coopCd, String crud, Long padId, Long ordNo, String baseDate, String opeId,
  public void callCoopAPI(String facilityCd, String coopCd, String crud, Long padId, Long ordNo, String baseDate, String opeCd,
// mod 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 end
                          Long indUserId) throws Exception {
    try {
      JournalCreateRequestPayload payload = new JournalCreateRequestPayload();
      payload.setFacilityCd(facilityCd);
      payload.setCoopCd(coopCd);
      payload.setCoopCdIndex("");
      payload.setCrud(crud);
      payload.setDirection("S");
      payload.setAnaResult("0");
      payload.setCoopResult("0");
      payload.setPatId(padId);
      payload.setOrdNo(ordNo);
      payload.setBaseDate(baseDate);
// mod 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 start
//      payload.setOpeId(opeId);
      payload.setOpeCd(opeCd);
// mod 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 end
      payload.setUserId(indUserId);
      // ジャーネル作成
      createJournal(payload,indUserId);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (!StringUtils.isEmpty(facilityCd)) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
      throw e;
    }
  }

  /**
   * ジャーナル更新APIリクエスト
   *
   * @param payload
   * @param userId
   * @return
   * @throws Exception
   */
  // add by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --start
  @Async("doSomethingExecutor")
  // add by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --end
  public ResponseEntity<?> createJournal(JournalCreateRequestPayload payload, Long userId) throws Exception {
    try {
      if (payload.getCrud().equals("C")) {
        RestTemplate rt = new RestTemplate();
        URI uri = new URI(coopApi + "/journal/create");
        RequestEntity<JournalCreateRequestPayload> request = RequestEntity
                .post(uri)
                .contentType(MediaType.APPLICATION_JSON)
                /* add by chamaojia 2024-06-21 [10574] communication security related additions --start */
                .header(headerKey, headerValue)
                /* add by chamaojia 2024-06-21 [10574] communication security related additions --end */
                .body(payload);
		// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
        long start = System.currentTimeMillis();
        ResponseEntity<Object> response = rt.exchange(request, Object.class);
        long cost = System.currentTimeMillis() - start;
        Map<String, Object> map = new HashMap<>();
        map.put("logType", "RESTTEMPLATE-LOG");
        map.put("className", "jp.co.nikkiso.ntss.web_api.web.rest.util.ScheduleExtendUtil");
        map.put("methodName", "createJournal");
        map.put("method", request.getMethod());
        map.put("url", request.getUrl());
        map.put("headers", request.getHeaders().toSingleValueMap());
        map.put("requestParameter", request.getBody());
        map.put("status",response.getStatusCode());
        map.put("cost", cost);
        map.put("result",response.getBody());
        EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
        restTemplateEventLogMessage.setLogMessage(toJson(map));
        if (payload != null && !StringUtils.isEmpty(payload.getFacilityCd())) {
          restTemplateEventLogMessage.setFacilityCd(payload.getFacilityCd());
        }
        logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
      }
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception ex) {
      //createNotificationMessage(userId, payload);
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(ex));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(HttpStatus.OK);
    }
  }

  /**
   * Batch call Journa API
   * @param ctlNoList
   * add by shiyw 2023-02-14
   */
  // add by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --start
  // @Async("doSomethingExecutor") // del by shiyw 2023-03-30
  // add by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --end
  public void createJournalList(List<JournalCreateRequestPayload> ctlNoList) {
    if (ctlNoList.size() > 0) {
      try {
        RestTemplate rt = new RestTemplate();
        URI uri = new URI(coopApi + "/journal/createList");
        RequestEntity<List<JournalCreateRequestPayload>> request = RequestEntity.post(uri)
                .contentType(MediaType.APPLICATION_JSON)
                /* add by chamaojia 2024-06-21 [10574] communication security related additions --start */
                .header(headerKey, headerValue)
                /* add by chamaojia 2024-06-21 [10574] communication security related additions --end */
                .body(ctlNoList);
		// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
        long start = System.currentTimeMillis();
        ResponseEntity<Object> response = rt.exchange(request, Object.class);
        // log start
        long cost = System.currentTimeMillis() - start;
        Map<String, Object> map = new HashMap<>();
        map.put("logType", "RESTTEMPLATE-LOG");
        map.put("className", "jp.co.nikkiso.ntss.web_api.web.rest.util.ScheduleExtendUtil");
        map.put("methodName", "createJournalList");
        map.put("method", request.getMethod());
        map.put("url", request.getUrl());
        map.put("headers", request.getHeaders().toSingleValueMap());
        map.put("requestParameter", request.getBody());
        map.put("status",response.getStatusCode());
        map.put("cost", cost);
        map.put("result",response.getBody());
        EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
        restTemplateEventLogMessage.setLogMessage(toJson(map));
        logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
      } catch (Exception ex) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(ex));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
        logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
        createNotificationMessage(ctlNoList);
      }
    }
  }

  /**
   * 通知機能の対応について
   *
   * @param userId ユーザーID.
   * @param payload ペイロード
   * @throws Exception
   * @throws RuntimeException
   */
  @Transactional
  public void createNotificationMessage(Long userId, JournalCreateRequestPayload payload) throws Exception, RuntimeException {
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
    Date currentTime = new Date();

    if (StringUtils.isEmpty(payload.getHospPatId())) {
      PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(payload.getPatId());
      payload.setHospPatId(patPersonalMain.getHosp_pat_id());
    }

    String targetDate = "";
    String category = "未登録";
    // 予定期限
    if (payload.getCoopCd().equals("exam_ord")) {
      // 検査結果を取得
      PatExamMain examResult = patExamMainDao.selectPatExamMainByExamMainCd(payload.getOrdNo());
      if (examResult != null) {
        targetDate = sdf.format(examResult.getRegExamDate());
        category = getRegOrderClassName(examResult.getRegOrderClass());
      }
    } else if (payload.getCoopCd().equals("rad_ord")) {
      PatRadMain patRadMain = patRadMainDao.selectByPrimaryKey(payload.getOrdNo());
      if(patRadMain != null) {
        targetDate = sdf.format(patRadMain.getRegRadDate());
        category = getRegOrderClassName(patRadMain.getRegOrderClass());
      }
    } else {
      OrdMain ordMain = ordMainDao.selectByOrdNo(payload.getOrdNo());
      if(ordMain != null) {
        targetDate = ordMain.getTreatDate();
        MstKur mstKur = mstKurDao.selectByKurCd(ordMain.getIndKurCd().toString());
        if(mstKur != null) {
          category = mstKur.getKurName();
        }
      }
    }

    // 通知メッセージ及び付加情報の変換用JSONデータを作成 値は文字列型にすること
    JSONObject replaceData = new JSONObject();
    replaceData.put("HOSP_PAT_ID", payload.getHospPatId());
    replaceData.put("COOP_CD", coopCds.get(payload.getCoopCd()));
    replaceData.put("UP_DATE", sdf.format(currentTime));
    replaceData.put("TARGET_DATE", formatDateString(targetDate, "yyyyMMdd"));
    replaceData.put("CATEGORY", category);
    replaceData.put("PAT_ID", payload.getPatId().toString());
    replaceData.put("FACILITY_CD", payload.getFacilityCd());

    // 通知登録
    HttpStatus status = HttpStatus.OK;
    String message = null;
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("汎用通知レシーバー処理開始");
    logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
    try {
      JSONObject jsonBody = new JSONObject();
      // modify 9583 by kangjie 20240410 start
//      jsonBody.put("notificationNo", NotificationDefinition.CREATE_JOURNAL);
      // modify 9583 by kangjie 20240410 end
      jsonBody.put("facilityCd", payload.getFacilityCd());
      // 変換用文字列のエンコード処理(UTF-8)
      String base64replaceData = new String(Base64.getEncoder().encode(replaceData.toString().getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8);
      jsonBody.put("replaceData", base64replaceData);
      ResponseEntity<?> response = notificationResource.genericNotificationReciever(jsonBody.toString());
      status = HttpStatus.valueOf(response.getStatusCode().value());
      if (HttpStatus.OK != status) {
        eventLogMessage.setLogMessage("汎用通知レシーバーへの接続失敗:" + status);
        logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      }
    } catch (Exception e) {
      status = HttpStatus.INTERNAL_SERVER_ERROR;
      message = "汎用通知レシーバー処理で例外発生:" + e.getMessage();
      eventLogMessage.setLogMessage(message);
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
    }
    eventLogMessage.setLogMessage("汎用通知レシーバー処理終了");
    logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
  }

  // Add By HandsomeLin At 2023/02/16 Start
  // #6174
  public void createNotificationMessage(List<JournalCreateRequestPayload> payloads) {
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
    Date currentTime = new Date();

    List<PatPersonalMain> personalMains = patPersonalMainDao
      .selectByPatIdList(payloads.stream().map(JournalCreateRequestPayload::getPatId).collect(Collectors.toList()));

    List<Long> patExamMainOrdNums = new ArrayList<>();
    List<Long> patRadMainOrdNums = new ArrayList<>();
    List<Long> orderMainOrdNums = new ArrayList<>();
    for (JournalCreateRequestPayload payload : payloads) {
      if (payload.getCoopCd().equals("exam_ord")) {
        patExamMainOrdNums.add(payload.getOrdNo());
      } else if (payload.getCoopCd().equals("rad_ord")) {
        patRadMainOrdNums.add(payload.getOrdNo());
      } else {
        orderMainOrdNums.add(payload.getOrdNo());
      }
    }

    List<PatExamMain> patExamMains = Collections.emptyList();
    List<PatRadMain> patRadMains = Collections.emptyList();
    List<OrdMain> ordMains = Collections.emptyList();
    List<MstKur> mstKurs = Collections.emptyList();

    if (!patExamMainOrdNums.isEmpty()) {
      patExamMains = patExamMainDao.selectPatExamMainByExamMainCdList(patExamMainOrdNums);
    }
    if (!patRadMainOrdNums.isEmpty()) {
      patRadMains = patRadMainDao.selectByPrimaryKeyList(patRadMainOrdNums);
    }
    if (!orderMainOrdNums.isEmpty()) {
      ordMains = ordMainDao.selectAllByOrdNoList(orderMainOrdNums);
      if (!ordMains.isEmpty()) {
        mstKurs = mstKurDao.selectByKurCdList(ordMains.stream().map(o -> o.getIndKurCd().toString()).collect(Collectors.toList()));
      }
    }

    JSONArray jsonArray = new JSONArray();
    for (JournalCreateRequestPayload payload : payloads) {
      if (StringUtils.isEmpty(payload.getHospPatId())) {
        PatPersonalMain patPersonalMain = personalMains.stream().filter(p -> p.getPat_id().equals(payload.getPatId()))
          .findFirst().orElse(null);
        if (patPersonalMain == null) {
          continue;
        }
        payload.setHospPatId(patPersonalMain.getHosp_pat_id());
      }

      String targetDate = "";
      String category = "未登録";
      // 予定期限
      if (payload.getCoopCd().equals("exam_ord")) {
        // 検査結果を取得
        PatExamMain examResult = patExamMains.stream().filter(m -> Objects.equals(m.getOrdNo(), payload.getOrdNo())).findFirst().orElse(null);
        if (examResult != null) {
          targetDate = sdf.format(examResult.getRegExamDate());
          category = getRegOrderClassName(examResult.getRegOrderClass());
        }
      } else if (payload.getCoopCd().equals("rad_ord")) {
        PatRadMain patRadMain = patRadMains.stream().filter(m -> Objects.equals(m.getRadResultCd(), payload.getOrdNo())).findFirst().orElse(null);
        if(patRadMain != null) {
          targetDate = sdf.format(patRadMain.getRegRadDate());
          category = getRegOrderClassName(patRadMain.getRegOrderClass());
        }
      } else {
        OrdMain ordMain = ordMains.stream().filter(m -> Objects.equals(m.getOrdNo(), payload.getOrdNo())).findFirst().orElse(null);
        if(ordMain != null) {
          targetDate = ordMain.getTreatDate();
          MstKur mstKur =  mstKurs.stream().filter(k -> Objects.equals(k.getKurCd(), ordMain.getIndKurCd())).findFirst().orElse(null);
          if(mstKur != null) {
            category = mstKur.getKurName();
          }
        }
      }

      // 通知メッセージ及び付加情報の変換用JSONデータを作成 値は文字列型にすること
      JSONObject replaceData = new JSONObject();
      replaceData.put("HOSP_PAT_ID", payload.getHospPatId());
      replaceData.put("COOP_CD", coopCds.get(payload.getCoopCd()));
      replaceData.put("UP_DATE", sdf.format(currentTime));
      replaceData.put("TARGET_DATE", formatDateString(targetDate, "yyyyMMdd"));
      replaceData.put("CATEGORY", category);
      replaceData.put("PAT_ID", payload.getPatId().toString());
      replaceData.put("FACILITY_CD", payload.getFacilityCd());

      JSONObject jsonBody = new JSONObject();
      // modify 9583 by kangjie 20240401 start 通知一覧の連携エラー通知の遷移不正
//      jsonBody.put("notificationNo", NotificationDefinition.CREATE_JOURNAL);
      jsonBody.put("notificationNo", NotificationDefinition.COOP_JOURNAL_ERROR);
      // modify 9583 by kangjie 20240401 end 通知一覧の連携エラー通知の遷移不正
      jsonBody.put("facilityCd", payload.getFacilityCd());
      // 変換用文字列のエンコード処理(UTF-8)
      String base64replaceData = new String(Base64.getEncoder().encode(replaceData.toString().getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8);
      jsonBody.put("replaceData", base64replaceData);

      jsonArray.put(jsonBody);
    }
    // 通知登録
    HttpStatus status = HttpStatus.OK;
    String message = null;
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("汎用通知レシーバー処理開始");
    logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    try {
      ResponseEntity<?> response = notificationBatchService.genericNotificationsReceiver(jsonArray.toString());
      status = HttpStatus.valueOf(response.getStatusCode().value());
      if (HttpStatus.OK != status) {
        eventLogMessage.setLogMessage("汎用通知レシーバーへの接続失敗:" + status);
        logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      }
    } catch (Exception e) {
      status = HttpStatus.INTERNAL_SERVER_ERROR;
      message = "汎用通知レシーバー処理で例外発生:" + e.getMessage();
      eventLogMessage.setLogMessage(message);
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
    }
    eventLogMessage.setLogMessage("汎用通知レシーバー処理終了");
    logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
  }

  /**
   * 送信電文種別ScheduleExtendUtil
   * @return HashMap
   */
  private static Map<String, String> initMapData() {
    Map<String, String> hashMap = new HashMap<>();
    hashMap.put("ind_dial", "透析予約");
    hashMap.put("rst_dial", "透析実績");
    hashMap.put("karte_ord", "カルテ記載");
    hashMap.put("vit_cop", "バイタル連携");
    hashMap.put("rep_dial", "レポート送信");
    hashMap.put("accept", "受付");
    hashMap.put("exam_ord", "検査予約");
    hashMap.put("rad_ord", "一般撮影検査予約");
    hashMap.put("profile", "患者リクエスト");
    return hashMap;
  }

  /**
   * フォーマット文字列
   * @param dateStr
   * @return
   * @throws Exception
   */
  private static String formatDateString(String dateStr, String pattern) {
    try {
      DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
      Date date = new SimpleDateFormat(pattern).parse(dateStr);
      return dateFormat.format(date);
    } catch (Exception e) {
      return dateStr;
    }
  }

  /**
   *
   * @param regOrderClass 登録時検査区分
   * @return 1:透析前 2:透析後 0:その他 の順で表示
   */
  private String getRegOrderClassName(String regOrderClass) {
    String str = "";
    if(regOrderClass != null) {
      switch (regOrderClass) {
        case "0":
          str = "その他";
          break;
        case "1":
          str = "透析前";
          break;
        case "2":
          str = "透析後";
          break;
        default:
          break;
      }
    }
    return str;
  }

  private void insertOrdMainAndTrigger(List<OrdMain> ordMains) {
    class JdbcTemplate extends org.springframework.jdbc.core.JdbcTemplate {

      public JdbcTemplate(DataSource dataSource) {
        super(dataSource);
      }

      public List<Long> batchInsert(String sql, BatchPreparedStatementSetter setter) throws DataAccessException{
        return this.execute(con -> con.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS),
          (PreparedStatementCallback<List<Long>>) ps -> {
            for (int i = 0; i < setter.getBatchSize(); i++) {
              setter.setValues(ps, i);
              ps.addBatch();
            }
            ps.executeBatch();
            List<Long> keys = new ArrayList<>();
            ResultSet rs = ps.getGeneratedKeys();
            while (rs.next()) {
              keys.add(rs.getLong(1));
            }
            JdbcUtils.closeResultSet(rs);
            return keys;
          });
      }
    }
    JdbcTemplate template = new JdbcTemplate(dataSource);

    List<Long> ordMainIds = template.batchInsert("insert into ord_main (" +
      "    pat_id, fn_pat_id, treat_date, treat_week, facility_cd, facility_name, ind_va_cd," +
      "    ind_treatment_cd, ind_treatment_name, ind_kur_cd, ind_kur_name, ind_treat_start_time, ind_bed_cd," +
      "    ind_bed_name, ind_schedule_user_info, ind_cond_info, ind_medi_info, ind_equip_info," +
      "    ind_ind_comment_info, ind_tare_info, ind_off_water_info, ind_device_set_info, rst_fn_dialysis_no," +
      "    rst_relation_dialysis_no, rst_edition, rst_is_update_edition, rst_input_class, rst_dialysis_state," +
      "    rst_treatment_cd, rst_treatment_name, rst_kur_cd, rst_kur_name, rst_bed_cd, rst_bed_name," +
      "    rst_machine_no, rst_machine_name, rst_cond_send_date, rst_accept_date, rst_start_date," +
      "    rst_end_date, rst_return_home_date, rst_in_out_class, rst_dialysis_cnt, rst_ward_cd," +
      "    rst_ward_name, rst_course_cd, rst_course_name, rst_puncture_user_info, rst_return_user_info," +
      "    rst_charge_user_info, rst_blood_circulate_total, rst_running_time, rst_kt_v, rec_set_date," +
      "    send_ctl_no, blood_purifier_name, pull_leave_amount, rst_cond_info, rst_medi_info, rst_equip_info," +
      "    rst_ind_comment_info, rst_tare_info, rst_off_water_info, rst_weight_info," +
      "    rst_complaint_info, rst_treatment_info, rst_treat_staff_info, rst_rounds_info," +
      "    is_del, up_date, reg_date, rst_dw, weight_scale_no, treat_type, is_confirm, ind_dw," +
      "    rst_purification_cnt, addition_info, up_ind_user_id, up_user_id, rst_edition_date," +
      "    cur_edition_date, fn_plural,bvms_path)" +
      "values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?," +
      "?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", new BatchPreparedStatementSetter() {
      @Override
      public void setValues(@NonNull PreparedStatement ps, int i) throws SQLException {
        OrdMain main = ordMains.get(i);
        set(ps, 1, main.getPatId());
        set(ps, 2, main.getFnPatId());
        set(ps, 3, main.getTreatDate());
        set(ps, 4, main.getTreatWeek());
        set(ps, 5, main.getFacilityCd());
        set(ps, 6, main.getFacilityName());
        set(ps, 7, main.getIndVaCd());
        set(ps, 8, main.getIndTreatmentCd());
        set(ps, 9, main.getIndTreatmentName());
        set(ps, 10, main.getIndKurCd());
        set(ps, 11, main.getIndKurName());
        set(ps, 12, main.getIndTreatStartTime());
        set(ps, 13, main.getIndBedCd());
        set(ps, 14, main.getIndBedName());
        set(ps, 15, main.getIndScheduleUserInfo());
        set(ps, 16, main.getIndCondInfo());
        set(ps, 17, main.getIndMediInfo());
        set(ps, 18, main.getIndEquipInfo());
        set(ps, 19, main.getIndIndCommentInfo());
        set(ps, 20, main.getIndTareInfo());
        set(ps, 21, main.getIndOffWaterInfo());
        set(ps, 22, main.getIndDeviceSetInfo());
        set(ps, 23, main.getRstFnDialysisNo());
        set(ps, 24, main.getRstRelationDialysisNo());
        set(ps, 25, main.getRstEdition());
        set(ps, 26, main.getRstIsUpdateEdition());
        set(ps, 27, main.getRstInputClass());
        set(ps, 28, main.getRstDialysisState());
        set(ps, 29, main.getRstTreatmentCd());
        set(ps, 30, main.getRstTreatmentName());
        set(ps, 31, main.getRstKurCd());
        set(ps, 32, main.getRstKurName());
        set(ps, 33, main.getRstBedCd());
        set(ps, 34, main.getRstBedName());
        set(ps, 35, main.getRstMachineNo());
        set(ps, 36, main.getRstMachineName());
        set(ps, 37, main.getRstCondSendDate());
        set(ps, 38, main.getRstAcceptDate());
        set(ps, 39, main.getRstStartDate());
        set(ps, 40, main.getRstEndDate());
        set(ps, 41, main.getRstReturnHomeDate());
        set(ps, 42, main.getRstInOutClass());
        set(ps, 43, main.getRstDialysisCnt());
        set(ps, 44, main.getRstWardCd());
        set(ps, 45, main.getRstWardName());
        set(ps, 46, main.getRstCourseCd());
        set(ps, 47, main.getRstCourseName());
        set(ps, 48, main.getRstPunctureUserInfo());
        set(ps, 49, main.getRstReturnUserInfo());
        set(ps, 50, main.getRstChargeUserInfo());
        set(ps, 51, main.getRstBloodCirculateTotal());
        set(ps, 52, main.getRstRunningTime());
        set(ps, 53, main.getRstKtV());
        set(ps, 54, main.getRecSetDate());
        set(ps, 55, main.getSendCtlNo());
        set(ps, 56, main.getBloodPurifierName());
        set(ps, 57, main.getPullLeaveAmount());
        set(ps, 58, main.getRstCondInfo());
        set(ps, 59, main.getRstMediInfo());
        set(ps, 60, main.getRstEquipInfo());
        set(ps, 61, main.getRstIndCommentInfo());
        set(ps, 62, main.getRstTareInfo());
        set(ps, 63, main.getRstOffWaterInfo());
//        set(ps, 64, main.getRstDeviceSetInfo()); // del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正
        set(ps, 64, main.getRstWeightInfo());
//        set(ps, 65, main.getRstVitalInfo()); // del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正
        set(ps, 65, main.getRstComplaintInfo());
        set(ps, 66, main.getRstTreatmentInfo());
        set(ps, 67, main.getRstTreatStaffInfo());
        set(ps, 68, main.getRstRoundsInfo());
        set(ps, 69, main.getIsDel());
        set(ps, 70, main.getUpDate());
        set(ps, 71, main.getRegDate());
        set(ps, 72, main.getRstDw());
        set(ps, 73, main.getWeightScaleNo());
        set(ps, 74, main.getTreatType());
        set(ps, 75, main.getIsConfirm());
        set(ps, 76, main.getIndDw());
        set(ps, 77, main.getRstPurificationCnt());
        set(ps, 78, main.getAdditionInfo());
        set(ps, 79, main.getUpIndUserId());
        set(ps, 80, main.getUpUserId());
        set(ps, 81, main.getRstEditionDate());
        set(ps, 82, main.getCurEditionDate());
        set(ps, 83, main.getFnPlural()); // modify by shiyw 2024-03-04 [#10196]ord_mainのデータ定義の修正: change "main.getFnPatId()" to "main.getFnPlural()"
        set(ps, 84, main.getBvmsPath()); // add by shiyw 2024-01-29 [#10196]ord_mainのデータ定義の修正
      }

      @Override
      public int getBatchSize() {
        return ordMains.size();
      }
    });

    for (int i = 0; i < ordMainIds.size(); i++) {
      ordMains.get(i).setOrdNo(ordMainIds.get(i));
    }

    if (!ordMains.isEmpty()) {
//            List<OrdMain> resultOrdMainList = ordMains.stream()
//                .filter(item -> ordMains.stream().map(e -> e.getOrdNo())
//                    .collect(Collectors.toList()).contains(item.getOrdNo()))
//                .collect(Collectors.toList());

      Set<Long> ordNoSet = new HashSet<>();
      template.query(
        " select " +
          "  os.ord_no, count(*) " +
          " from " +
          "   ord_schedule os " +
          " where os.ord_no in ( " +
          ordMains.stream().map(e -> String.valueOf(e.getOrdNo())).collect(Collectors.joining(",")) +
          " ) group by os.ord_no ", rs -> {
          long ordNo = rs.getLong(1);
          long cnt = rs.getLong(2);
          if (cnt > 0) {
            ordNoSet.add(ordNo);
          }
        });

      List<OrdMain> triggerOrdMainList = ordMains.stream()
        .filter(item -> !ordNoSet.contains(item.getOrdNo()))
        .collect(Collectors.toList());

      if (!triggerOrdMainList.isEmpty()) {
        // mod 11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) 関 start
        List<Long> ordNoList = triggerOrdMainList.stream().map(OrdMain::getOrdNo).distinct().collect(Collectors.toList());
        OrdMain firstOrdMain = triggerOrdMainList.get(0);
        String facilityCd = firstOrdMain.getFacilityCd();
        List<OrdScheduleNewKurPreview> dummyScheduleList = ordScheduleDao.selectOrdMainWithNewKur(facilityCd, ordNoList);

        /*template.batchUpdate("INSERT INTO ord_schedule ( " +
          "  facility_cd, " +
          "  ord_no, " +
          "  treat_date, " +
          "  kur_cd, " +
          "  bed_cd, " +
          "  pat_id, " +
          "  is_dummy, " +
          "  up_date, " +
          "  reg_date, " +
          "  treat_week " +
          ") " +
          "VALUES ( " +
          "  ?, " +
          "  ?, " +
          "  ?, " +
          "  ?, " +
          "  ?, " +
          "  ?, " +
          "  '0', " +
          "  current_timestamp, " +
          "  current_timestamp, " +
          "  ?)", new BatchPreparedStatementSetter() {
          @Override
          public void setValues(@NonNull PreparedStatement ps, int i) throws SQLException {
            OrdMain ord = triggerOrdMainList.get(i);
            set(ps, 1, ord.getFacilityCd());
            set(ps,2, ord.getOrdNo());
            set(ps,3, ord.getTreatDate());
            set(ps,4, ord.getIndKurCd());
            set(ps,5, ord.getIndBedCd());
            set(ps,6, ord.getPatId());
            set(ps,7, ord.getTreatWeek());
          }

          @Override
          public int getBatchSize() {
            return triggerOrdMainList.size();
          }
        });*/
        template.batchUpdate("INSERT INTO ord_schedule ( " +
          "  facility_cd, " +
          "  ord_no, " +
          "  treat_date, " +
          "  kur_cd, " +
          "  bed_cd, " +
          "  pat_id, " +
          "  is_dummy, " +
          "  up_date, " +
          "  reg_date, " +
          "  treat_week " +
          ") " +
          "VALUES ( " +
          "  ?, " +
          "  ?, " +
          "  ?, " +
          "  ?, " +
          "  ?, " +
          "  ?, " +
          "  ?, " +
          "  current_timestamp, " +
          "  current_timestamp, " +
          "  ?)", new BatchPreparedStatementSetter() {
          @Override
          public void setValues(@NonNull PreparedStatement ps, int i) throws SQLException {
            OrdScheduleNewKurPreview sch = dummyScheduleList.get(i);
            set(ps, 1, sch.getFacilityCd());
            set(ps,2, sch.getKeyNo());
            set(ps,3, sch.getTreatDate());
            set(ps,4, sch.getKurCd());
            set(ps,5, sch.getBedCd());
            set(ps,6, sch.getPatId());
            set(ps,7, sch.getDummy());
            set(ps,8, sch.getTreatWeek());
          }

          @Override
          public int getBatchSize() {
            return dummyScheduleList.size();
          }
        });
        // mod 11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) 関 end
      }
      //add 10037 日次処理のスケージュール延長 zhao start
      Set<Long> approveOrdNoSet = new HashSet<>();
      template.query(
        " select " +
          "  pia.ord_no, count(*) " +
          " from " +
          "   pat_ind_approve pia " +
          " where pia.ord_no in ( " +
          ordMains.stream().map(e -> String.valueOf(e.getOrdNo())).collect(Collectors.joining(",")) +
          " ) group by pia.ord_no ", rs -> {
          long ordNo = rs.getLong(1);
          long cnt = rs.getLong(2);
          if (cnt > 0) {
            approveOrdNoSet.add(ordNo);
          }
        });

      List<OrdMain> approveOrdNoSetOrdMainList = ordMains.stream()
        .filter(item -> !approveOrdNoSet.contains(item.getOrdNo()))
        .collect(Collectors.toList());

      if (!approveOrdNoSetOrdMainList.isEmpty()) {
        template.batchUpdate("INSERT INTO pat_ind_approve ( " +
          "  ord_no, " +
          "  reg_date," +
          "  is_content_changed, " +
          "  check_content, " +
          "  is_user1_checked, " +
          "  is_user2_checked, " +
          "  is_user1_approved, " +
          "  is_user2_approved, " +
          "  is_content_appd_changed, " +
          "  approve_content, " +
          "  is_content_changed_for_map, " +
          "  facility_cd " +
          ") " +
          "VALUES ( " +
          "  ?, " +
          "  current_timestamp, " +
          "  '1', " +
          "  '{}', " +
          "  '0', " +
          "  '0', " +
          "  '0', " +
          "  '0', " +
          "  '1', " +
          "  '{}', " +
          "  '0', " +
          "  ?)", new BatchPreparedStatementSetter() {
          @Override
          public void setValues(@NonNull PreparedStatement ps, int i) throws SQLException {
            OrdMain ord = approveOrdNoSetOrdMainList.get(i);
            set(ps,1, ord.getOrdNo());
            set(ps,2, ord.getFacilityCd());
          }
          @Override
          public int getBatchSize() {
            return approveOrdNoSetOrdMainList.size();
          }
        });
      }
      //add 10037 日次処理のスケージュール延長 zhao end
    }
  }

  private void set(PreparedStatement ps, int index, Short value) throws SQLException {
    if (value == null) {
      ps.setNull(index, Types.SMALLINT);
    } else {
      ps.setShort(index, value);
    }
  }

  private void set(PreparedStatement ps, int index, Long value) throws SQLException {
    if (value == null) {
      ps.setNull(index, Types.BIGINT);
    } else {
      ps.setLong(index, value);
    }
  }

  private void set(PreparedStatement ps, int index, String value) throws SQLException {
    if (value == null) {
      ps.setNull(index, Types.VARCHAR);
    } else {
      ps.setString(index, value);
    }
  }

  private void set(PreparedStatement ps, int index, Integer value) throws SQLException {
    if (value == null) {
      ps.setNull(index, Types.INTEGER);
    } else {
      ps.setInt(index, value);
    }
  }

  private void set(PreparedStatement ps, int index, BigDecimal value) throws SQLException {
    if (value == null) {
      ps.setNull(index, Types.DECIMAL);
    } else {
      ps.setBigDecimal(index, value);
    }
  }

  private void set(PreparedStatement ps, int index, Double value) throws SQLException {
    if (value == null) {
      ps.setNull(index, Types.DOUBLE);
    } else {
      ps.setDouble(index, value);
    }
  }


  private void set(PreparedStatement ps, int index, Timestamp value) throws SQLException {
    if (value == null) {
      ps.setNull(index, Types.TIMESTAMP);
    } else {
      ps.setTimestamp(index, value);
    }
  }

  public static class ScheduleExtendCache {

    private final PatPersonalMainDao patPersonalMainDao;
    private final MstTreatmentDao mstTreatmentDao;

    private final PatMainDao patMainDao;
    private final MstFacilitySettingDao mstFacilitySettingDao;
    private final Map<Long, PatPersonalMain> patPersonalMainMap = new HashMap<>();
    private final Map<String, List<MstTreatment>> facilityTreatmentMap = new HashMap<>();
    private final Map<Long, PatMain> patPatMainMap = new HashMap<>();
    private final Map<String, FacilitySettingInfo> facilitySettingInfoMap = new HashMap<>();
    private final Map<String, MstFacility> mstFacilityMap = new HashMap<>(); //add #10196 ord_mainのデータ定義の修正 by shiyw
    public ScheduleExtendCache(PatPersonalMainDao patPersonalMainDao,
                               MstTreatmentDao mstTreatmentDao,
                               PatMainDao patMainDao,
                               MstFacilitySettingDao mstFacilitySettingDao) {
      this.patPersonalMainDao = patPersonalMainDao;
      this.mstTreatmentDao = mstTreatmentDao;
      this.patMainDao = patMainDao;
      this.mstFacilitySettingDao = mstFacilitySettingDao;
    }

    //add #10196 ord_mainのデータ定義の修正 by shiyw --start
    public void addMstFacility(MstFacility mstFacility){
      mstFacilityMap.put(mstFacility.getFacilityCd(),mstFacility);
    }
    public MstFacility getMstFacility(String facilityCd){
      return mstFacilityMap.get(facilityCd);
    }
    //add #10196 ord_mainのデータ定義の修正 by shiyw --end

    public void init(List<Long> patIds) {
      patPersonalMainDao.selectByPatIdList(patIds).forEach(patPersonalMain ->
        patPersonalMainMap.put(patPersonalMain.getPat_id(), patPersonalMain)
      );
      patMainDao.selectByIdList(patIds).forEach(patMain ->
        patPatMainMap.put(patMain.getPat_id(), patMain)
      );
    }

    public void clear() {
      patPersonalMainMap.clear();
      facilityTreatmentMap.clear();
      patPatMainMap.clear();
      facilitySettingInfoMap.clear();
    }

    public PatPersonalMain getPatPersonalMainByPatId(Long patId) {
      return patPersonalMainMap.get(patId);
    }

    public List<MstTreatment> getMstTreatmentList(String facilityCd) {
      if (facilityTreatmentMap.containsKey(facilityCd)) {
        return facilityTreatmentMap.get(facilityCd);
      }
      List<MstTreatment> mstTreatmentList = mstTreatmentDao.selectByFacilityCd(facilityCd);
      if (mstTreatmentList == null) {
        mstTreatmentList = new ArrayList<>();
      }
      facilityTreatmentMap.put(facilityCd, mstTreatmentList);
      return mstTreatmentList;
    }

    public FacilitySettingInfo getFacilitySettingInfo(String facilityCd) {
      if (facilitySettingInfoMap.containsKey(facilityCd)) {
        return facilitySettingInfoMap.get(facilityCd);
      }
      FacilitySettingInfo facilitySettingInfo = mstFacilitySettingDao.getBySettingNoAndCd(facilityCd,
        CoreConstant.FacilitySettingNo.DEFAULT_SEL_DOCTOR);
      if (facilitySettingInfo == null) {
        facilitySettingInfo = new FacilitySettingInfo();
      }
      facilitySettingInfoMap.put(facilityCd, facilitySettingInfo);
      return facilitySettingInfo;
    }

    public PatMain getPatMainByPatId(Long patId) {
      return patPatMainMap.get(patId);
    }

  }

  public static class ScheduleExtendTask {
    final MstFacility facility;
    List<Long> patIds = new ArrayList<>();

    public ScheduleExtendTask(MstFacility facility) {
      this.facility = facility;
    }
  }
}
