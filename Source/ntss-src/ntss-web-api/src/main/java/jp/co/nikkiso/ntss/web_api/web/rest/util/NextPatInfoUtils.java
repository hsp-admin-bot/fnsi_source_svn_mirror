package jp.co.nikkiso.ntss.web_api.web.rest.util;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import org.json.JSONObject;
import org.seasar.doma.jdbc.Config;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import jp.co.nikkiso.ntss.web_api.service.LogService;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;

import lombok.Getter;
import lombok.Setter;
import jp.co.nikkiso.ntss.core.config.DefaultDb;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Component
/** 次患者情報更新ユーティリティクラス */
public class NextPatInfoUtils {
  @Autowired
  private MntMachineStateDao mntMachineStateDao;
  @Autowired
  private OrdMainDao ordMainDao;
  @Autowired
  private WebAPICheckConditionSend webAPICheckConditionSend;

  /* del by chamaojia 2026-05-07 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
  // /**
  //  * デバイスエッジAPI接続URI
  //  */
  // private String CONNECT_BASE_URI = "http://localhost:8080/ntss-admin-web/api";
  /* del by chamaojia 2026-05-07 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
  
  @Autowired
  private LogService logService;

  // DB更新ログ出力ロジック wangzuo Start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Autowired
  private LogServiceCore logServiceCore;

  @Autowired
  @DefaultDb
  private Config defaultDbConfig;
  // DB更新ログ出力ロジック wangzuo End

  /**
   * 処理対象の装置の情報を格納するクラス
   */
  @Getter
  @Setter
  public class MachineInfo {
    /**
     * 施設コード
     */
    private String facilityCd;

    /**
     * 型式コード
     */
    private String machineTypeCd;

    /**
     * 製造番号
     */
    private String machineSerial;
    //スペースを削除する 6901 関 start
    public String getMachineSerial() {
      if (machineSerial != null) {
        return machineSerial.trim();
      }
      return machineSerial;
    }

    public void setMachineSerial(String machineSerial) {
      if (machineSerial != null) {
        this.machineSerial = machineSerial.trim();
      }
    }
    //スペースを削除する 6901 end
  }

  /**
   * 処理対象の装置の情報を格納するクラス
   */
  @Getter
  @Setter
  public class NextPatInfo {
    /**
     * 次患者ID
     */
    private Long nextPatid;

    /**
     * 次回透析オーダ番号
     */
    private Long nextOrdNo;

    /**
     * 次患者クールCD
     */
    private Long nextKurCd;

    /**
     * 透析開始予定日時
     */
    private Timestamp startPlanDate;

    /**
     * 透析終了予定日時
     */
    private Timestamp endPlanDate;
  }

  /**
   * 戻り値
   */
  public enum PROC_RESULT {
    /**
     * 正常終了
     */
    SUCCESS,
    /**
     * パラメータ異常
     */
    PARAM_ERR,
    /**
     * 異常終了
     */
    ERROR,
    /**
     * 警告(処理未実施)
     */
    WARN,
  }

  /**
   * 現患者クリアAPI
   *
   * @param machineInfo 処理対象の装置の情報
   * @param upDate      処理更新日時
   * @return PROC_RESULT 処理結果(SUCCESS:正常終了、WARN:警告終了、ERROR:異常終了(Exceptionエラー含む)、PARAM_ERR:パラメータ異常)
   */
  @Transactional
  public PROC_RESULT currentPatClear(MachineInfo machineInfo, Timestamp upDate) {
    // パラメータチェック
    String facilityCd = machineInfo.getFacilityCd();
    String machineTypeCd = machineInfo.getMachineTypeCd();
    String machineSerial = machineInfo.getMachineSerial();
    if (true == StringUtils.isEmpty(facilityCd)) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("対象装置情報(facility_cd=" + facilityCd + ")が異常なため現患者クリア処理を中断しました");
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return PROC_RESULT.PARAM_ERR;
    }
    if (true == StringUtils.isEmpty(machineTypeCd)) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("対象装置情報(machine_type_cd=" + machineTypeCd + ")が異常なため現患者クリア処理を中断しました");
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return PROC_RESULT.PARAM_ERR;
    }
    if (true == StringUtils.isEmpty(machineSerial)) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("対象装置情報(machine_serial=" + machineSerial + ")が異常なため現患者クリア処理を中断しました");
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return PROC_RESULT.PARAM_ERR;
    }
    try {
      // 患者確認済み(治療状況リストエントリー済み)チェック
      List<MntMachineState> retInfo = mntMachineStateDao.selectByEntryCheckInfo(facilityCd, machineTypeCd, machineSerial);
      if (null == retInfo) {
        return PROC_RESULT.ERROR;
      } else if (0 != retInfo.size()) {
        // 患者確認済みの場合は設定編集不可
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("対象装置(" +
          "facility_cd=" + facilityCd +
          "、machine_type_cd=" + machineTypeCd +
          "、machine_serial=" + machineSerial +
          ")に対して患者確認済み(治療状況リストエントリー済み)のため現患者クリアをスキップしました");
        eventLogMessage.setFacilityCd(facilityCd);
        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        return PROC_RESULT.WARN;
      } else {

        // DB更新ログ出力ロジック wangzuo Start
        String tableName = "mnt_machine_state";
        // SQL検索条件
        StringBuffer wheres = new StringBuffer("");
        wheres.append(" WHERE\n");
        wheres.append(" facility_cd = '" + facilityCd + "'\n");
        wheres.append(" AND\n");
        wheres.append(" machine_type_cd = '" + machineTypeCd + "'\n");
        wheres.append(" AND\n");
        wheres.append(" trim(machine_serial) = trim('" + machineSerial + "')\n");

        // logCommon設定
        DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
        // ログ出力カラム情報及び更新前データ情報取得
        boolean setResult = logCommon.setInfo();
        // DB更新ログ出力ロジック wangzuo End

        // 現患者クリア処理実施
        int retCnt = mntMachineStateDao.updateCurrentPatClear(facilityCd, machineTypeCd, machineSerial, upDate);

        // DB更新ログ出力ロジック wangzuo Start
        // 更新後データ取得、差分あれば、log出力
        if (setResult && retCnt > 0) {
          logCommon.updateLog();
        }
        // DB更新ログ出力ロジック wangzuo End

        // 処理件数が1件でない場合は異常終了
        if (1 != retCnt) {
          String strMsg = "対象装置(" +
            "facility_cd=" + facilityCd +
            "、machine_type_cd=" + machineTypeCd +
            "、machine_serial=" + machineSerial +
            ")に対して現患者クリア処理に失敗しました(処理件数:" + retCnt + ")";
          throw new RuntimeException(strMsg);
        }
      }
    } catch (Exception ex) {
      // ロールバック実行
      throw new RuntimeException(ex.getMessage());
    }

    return PROC_RESULT.SUCCESS;
  }

  /**
   * 次患者更新API
   *
   * @param machineInfo     処理対象の装置の情報
   * @param isIndChange     指示変更有無(true:指示(スケジュール情報以外)変更あり、false:指示変更なし)
   * @param searchStartTime 検索開始時刻(形式:HHmmss)
   * @param upDate          処理更新日時
   * @return PROC_RESULT 処理結果(SUCCESS:正常終了、WARN:警告終了、ERROR:異常終了(Exceptionエラー含む)、PARAM_ERR:パラメータ異常)
   */
  // #9290 2023.10.03 mod isSendCondition = true のときは元々のord_noを使用する TDC片口 start
  @Transactional
//  public String setNextPatInfo(MachineInfo machineInfo, boolean isIndChange, String searchStartTime, Timestamp upDate, boolean isSendCondition) {
  public String setNextPatInfo(MachineInfo machineInfo, boolean isIndChange, String searchStartTime, Timestamp upDate, boolean isSendCondition, Long sendConditionOrdNo) {
    // #9290 2023.10.03 mod isSendCondition = true のときは元々のord_noを使用する TDC片口 end
    // パラメータチェック
    String facilityCd = machineInfo.getFacilityCd();
    String machineTypeCd = machineInfo.getMachineTypeCd();
    String machineSerial = machineInfo.getMachineSerial();
    String tmpDeviceSetInfo = null;
    boolean isTmpDeviceSetInfo = true;
    JSONObject responseInfo = new JSONObject("{}");
    EventLogMessage eventLogMessage = new EventLogMessage();
    if (true == StringUtils.isEmpty(facilityCd)) {
      eventLogMessage.setLogMessage("対象装置情報(facility_cd=" + facilityCd + ")が異常なため次患者更新処理を中断しました");
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      responseInfo.put("PROC_RESULT", PROC_RESULT.PARAM_ERR);
      return responseInfo.toString();
    }
    if (true == StringUtils.isEmpty(machineTypeCd)) {
      eventLogMessage.setLogMessage("対象装置情報(machine_type_cd=" + machineTypeCd + ")が異常なため次患者更新処理を中断しました");
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      responseInfo.put("PROC_RESULT", PROC_RESULT.PARAM_ERR);
      return responseInfo.toString();
    }
    if (true == StringUtils.isEmpty(machineSerial)) {
      eventLogMessage.setLogMessage("対象装置情報(machine_serial=" + machineSerial + ")が異常なため次患者更新処理を中断しました");
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      responseInfo.put("PROC_RESULT", PROC_RESULT.PARAM_ERR);
      return responseInfo.toString();
    }
    try {
      // 次患者情報取得
      // #9290 2023.10.03 mod isSendCondition = true のときは元々のord_noを使用する TDC片口 start
      List<NextPatInfo> nextPatInfo = this.getNextPatInfo(facilityCd, machineTypeCd, machineSerial, searchStartTime, isSendCondition, sendConditionOrdNo);
      // #9290 2023.10.03 mod isSendCondition = true のときは元々のord_noを使用する TDC片口 end
      // #9290 2023.09.29 del 次患者情報がなくてもエラーにせずnullをセットする TDC片口 start
      /*
      // mod bug 8099 修正 chen start
      if (null == nextPatInfo || nextPatInfo.size() == 0) {
      // mod bug 8099 修正 chen end
        // エラー処理(ログはサブ関数で出力済み)
        responseInfo.put("PROC_RESULT", PROC_RESULT.ERROR);
        return responseInfo.toString();
      } else {
       */
      // #9290 2023.09.29 del 次患者情報がなくてもエラーにせずnullをセットする TDC片口 end
      // 該当装置の治療状況チェック
      List<MntMachineState> currentMachineState = mntMachineStateDao.selectByProcessState(facilityCd, machineTypeCd, machineSerial, null);
      if (1 != currentMachineState.size()) {
        eventLogMessage.setLogMessage("対象装置(" +
          "facility_cd=" + facilityCd +
          "、machine_type_cd=" + machineTypeCd +
          "、machine_serial=" + machineSerial +
          ")情報の取得に失敗しました(処理件数:" + currentMachineState.size() + ")");
        eventLogMessage.setFacilityCd(facilityCd);
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        responseInfo.put("PROC_RESULT", PROC_RESULT.ERROR);
        return responseInfo.toString();
      } else {
          // #9290 2023.09.29 del 治療ステータスに関わらず次患者更新処理を行う TDC片口 start
        /*
        // 該当装置の装置ステータスが透析治療中(Bit0オン)でなければ次患者更新実施
          if ((null != currentMachineState.get(0).getMachineStatus()) && 0x01 == (currentMachineState.get(0).getMachineStatus().intValue() & 0x01)) {
            eventLogMessage.setLogMessage("対象装置(" +
              "facility_cd=" + facilityCd +
              "、machine_type_cd=" + machineTypeCd +
              "、machine_serial=" + machineSerial +
              ")が治療中のため次患者更新処理をスキップしました)");
            eventLogMessage.setFacilityCd(facilityCd);
            logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            responseInfo.put("PROC_RESULT", PROC_RESULT.WARN);
            return responseInfo.toString();
          } else {
         */
          // #9290 2023.09.29 del 治療ステータスに関わらず次患者更新処理を行う TDC片口 end
        // 次患者情報があれば次患者情報で更新(次患者情報がなければnullで更新)
        Long nextPatid = null;
        Long nextOrdNo = null;
        Long nextKurCd = null;
        Timestamp startPlanDate = null;
        Timestamp endPlanDate = null;
        if (0 != nextPatInfo.size()) {
          nextPatid = nextPatInfo.get(0).getNextPatid();
          nextOrdNo = nextPatInfo.get(0).getNextOrdNo();
          nextKurCd = nextPatInfo.get(0).getNextKurCd();
          startPlanDate = nextPatInfo.get(0).getStartPlanDate();
          endPlanDate = nextPatInfo.get(0).getEndPlanDate();
        }
        // String deviceEdgeUri;
        // #9290 2023.10.10 add 次患者情報がなくてもエラーにせずnullをセットする TDC片口 start
        boolean isFailed = false;
        if (nextOrdNo == null) {
          tmpDeviceSetInfo = null;
        } else
        // #9290 2023.10.10 add 次患者情報がなくてもエラーにせずnullをセットする TDC片口 end
        if ((false == StringUtils.isEmpty(nextOrdNo)) &&
          ((false == nextOrdNo.equals(currentMachineState.get(0).getNextOrdNo())) ||
            ((true == nextOrdNo.equals(currentMachineState.get(0).getNextOrdNo())) && (true == isIndChange)))) {
          // 装置次患者情報送信実施チェック(「次患者情報を更新して異なる患者が次患者だった場合」または「次患者情報送信済みの次患者の設定を変更した場合」は装置次患者情報送信処理を実施)

          Map<String, Object> resChkCond = webAPICheckConditionSend.getTmpDviceSetInfo(nextOrdNo);
          String resMsgJson = (String) resChkCond.get("msg");
          // #9290 2023.10.10 mod tmp_device_set_info構築失敗時に前情報を残さずnullにする TDC片口 start
          /*
          if ((boolean) resChkCond.get("ret") == false) {
            // ロールバック実行
            throw new RuntimeException(resMsgJson);
          }
          tmpDeviceSetInfo = resChkCond.get("tmpDeviceSetInfo").toString();
          */
          if ((boolean) resChkCond.get("ret")) {
            tmpDeviceSetInfo = resChkCond.get("tmpDeviceSetInfo").toString();
          } else {
            isFailed = true;
            eventLogMessage.setLogMessage(resMsgJson);
            eventLogMessage.setFacilityCd(facilityCd);
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          }
          // #9290 2023.10.10 mod tmp_device_set_info構築失敗時に前情報を残さずnullにする TDC片口 end

                  /*
                  deviceEdgeUri = "/device_edge_order/api_cancel_condition";

                  // body作成
                  JSONObject jsonBody = new JSONObject();
                  jsonBody.put("ordNo", nextOrdNo.toString());
                  // リクエスト作成
                  //WebAPI呼び出し用Bodyデータ組み立て
                  RequestEntity<String> request = RequestEntity
                      .post(new URI(CONNECT_BASE_URI + "/WebAPICheckConditionSend/getTmpDeviceSetInfo"))
                      .contentType(MediaType.APPLICATION_JSON)
                      .header("SSECCAYEK", "NTSS-NKK-ESM-TDC-YSK")
                      .body(jsonBody.toString());
                  // リクエスト処理
                  RestTemplate rt = new RestTemplate();
                  ResponseEntity<String> response = rt.exchange(request, String.class);
                  HttpStatus status = HttpStatus.valueOf(response.getStatusCode().value());
                  JSONObject ret = new JSONObject(response.getBody());
                  Long ordNo = ret.getLong("ordNo");
                  JSONObject tmpDviceSetInfo = ret.getJSONObject("tmpDeviceSetInfo");

                  if (HttpStatus.OK != status) {
                    String strMsg = "対象装置(" +
                        "facility_cd=" + facilityCd +
                        "、machine_type_cd=" + machineTypeCd +
                        "、machine_serial=" + machineSerial +
                        ")の次患者更新処理・条件送信API(装置設定一時データ作成)に失敗しました";
                    throw new RuntimeException(strMsg);
                  }
                  webAPICheckConditionSendDao.updateInsertSendCondData(ordNo, tmpDviceSetInfo.toString());
                  */
        } else if (nextOrdNo != null && (true == nextOrdNo.equals(currentMachineState.get(0).getNextOrdNo())) && (false == isIndChange)) {
          isTmpDeviceSetInfo = false;
        }

        // DB更新ログ出力ロジック wangzuo Start
        String tableName = "mnt_machine_state";
        // SQL検索条件
        StringBuffer wheres = new StringBuffer("");
        wheres.append(" WHERE\n");
        wheres.append(" facility_cd = '" + facilityCd + "'\n");
        wheres.append(" AND\n");
        wheres.append(" machine_type_cd = '" + machineTypeCd + "'\n");
        wheres.append(" AND\n");
        wheres.append(" trim(machine_serial) = trim('" + machineSerial + "')\n");

        // logCommon設定
        DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
        // ログ出力カラム情報及び更新前データ情報取得
        boolean setResult = logCommon.setInfo();
        // DB更新ログ出力ロジック wangzuo End

        int retCnt = mntMachineStateDao.updateNextPatDate(
          facilityCd,
          machineTypeCd,
          machineSerial,
          nextPatid,
          nextOrdNo,
          nextKurCd,
          startPlanDate,
          endPlanDate,
          upDate,
          tmpDeviceSetInfo,
          isTmpDeviceSetInfo
        );

        // DB更新ログ出力ロジック wangzuo Start
        // 更新後データ取得、差分あれば、log出力
        if (setResult && retCnt > 0) {
          logCommon.updateLog();
        }
        // DB更新ログ出力ロジック wangzuo End

        // 処理件数が1件でない場合は異常終了
        if (1 != retCnt) {
          String strMsg = "対象装置(" +
            "facility_cd=" + facilityCd +
            "、machine_type_cd=" + machineTypeCd +
            "、machine_serial=" + machineSerial +
            ")の次患者更新処理に失敗しました(処理件数:" + retCnt + ")";
          throw new RuntimeException(strMsg);
        }
        responseInfo.put("device_edge_order", isTmpDeviceSetInfo);
        responseInfo.put("facilityCd", facilityCd);
        responseInfo.put("machineTypeCd", machineTypeCd);
        responseInfo.put("machineSerial", machineSerial);

                  /*
                  try {
                    // body作成
                    JSONObject jsonBody = new JSONObject();
                    MstMachine mstMachineInfo = mstMachineDao.selectByCd(machineTypeCd, machineSerial, facilityCd);
                    jsonBody.put("machineNo", mstMachineInfo.getMachineNo());
                    jsonBody.put("deviceEdgeNo", mstMachineInfo.getDeviceEdgeNo());
                    jsonBody.put("facilityCd", mstMachineInfo.getFacilityCd());

                    // リクエスト作成
                    RequestEntity<String> request = RequestEntity
                        .post(new URI(CONNECT_BASE_URI + deviceEdgeUri))
                        .contentType(MediaType.APPLICATION_JSON)
                        .header("SSECCAYEK", "NTSS-NKK-ESM-TDC-YSK")
                        .body(jsonBody.toString());

                    // リクエスト処理
                    RestTemplate rt = new RestTemplate();
                    ResponseEntity<String> response = rt.exchange(request, String.class);
                    HttpStatus status = HttpStatus.valueOf(response.getStatusCode().value());
                    JSONObject ret = new JSONObject(response.getBody());
                    if (HttpStatus.OK != status) {
                      return PROC_RESULT.ERROR;
                    } else if ("false".equals(ret.get("isSuccess").toString())) {
                    }
                  } catch (HttpClientErrorException ex) {
                    //Exception thrown when an HTTP 4xx is received.
                    if(ex.getMessage().contains("404"))
                    {
                      //デバイスエッジにつながらない場合(URIアクセスが404(Not Found))、ログを出して処理をスキップします
                    }
                    else
                    {
                      return PROC_RESULT.ERROR;
                    }
                  } catch (Exception ex) {
                    return PROC_RESULT.ERROR;
                  }
                  */
//          }
//        }
        // #9290 2023.10.10 mod tmp_device_set_info構築失敗時に前情報を残さずnullにする TDC片口 start
        if (isFailed) {
          responseInfo.put("PROC_RESULT", PROC_RESULT.ERROR);
          return responseInfo.toString();
        }
        // #9290 2023.10.10 mod tmp_device_set_info構築失敗時に前情報を残さずnullにする TDC片口 end
      }
    } catch (Exception ex) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessageNew = new EventLogMessage();
      eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(ex));
      if (!StringUtils.isEmpty(facilityCd)) {
        eventLogMessageNew.setFacilityCd(facilityCd);
      }
      logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
      // ロールバック実行
      throw new RuntimeException(ex.getMessage());
    }
    responseInfo.put("PROC_RESULT", PROC_RESULT.SUCCESS);
    return responseInfo.toString();
  }

  /**
   * 次患者情報取得
   *
   * @param facilityCd      施設コード
   * @param machineTypeCd   型式コード
   * @param machineSerial   製造番号
   * @param searchStartTime 検索開始時刻(形式:HHmmss)
   * @param isSendCondition 条件送信済みフラグ
   * @return 正常終了:次患者情報、異常終了:null
   */
  // #9290 2023.10.03 mod isSendCondition = true のときは元々のord_noを使用する TDC片口 start
//  private List<NextPatInfo> getNextPatInfo(String facilityCd, String machineTypeCd, String machineSerial, String searchStartTime, boolean isSendCondition) {
  private List<NextPatInfo> getNextPatInfo(String facilityCd, String machineTypeCd, String machineSerial, String searchStartTime, boolean isSendCondition, Long sendConditionOrdNo) {
    // #9290 2023.10.03 mod isSendCondition = true のときは元々のord_noを使用する TDC片口 start
    // 検索条件初期化(検索開始日に現在日+指定時刻を設定)
    DateTimeFormatter format = DateTimeFormatter.ofPattern("yyyyMMdd");
    DateTimeFormatter dateFormat = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");

    // 検索開始時刻が未指定の場合は"000000"を設定
    String startTime = "000000";
    if (null != searchStartTime) {
      startTime = searchStartTime;
    }
    LocalDateTime nowDate = LocalDateTime.parse(LocalDateTime.now().format(format) + startTime, dateFormat);
    String searchStartDate = nowDate.format(format);
    String searchEndDate = null;
    Long searchKurCd = null;

    // 当日以降の次患者情報取得
    // #9290 2023.10.03 mod isSendCondition = true のときは元々のord_noを使用し、そうでないときも適切なSQLを使用する TDC片口 start
//    List<OrdMain> retInfo = ordMainDao.selectByNextPatInfoCondition(facilityCd, machineTypeCd, machineSerial, searchStartDate, searchEndDate, isSendCondition);
    OrdMain o;
    if (isSendCondition && sendConditionOrdNo != null) {
      o = ordMainDao.selectByOrdNo(sendConditionOrdNo);
    } else {
      o = ordMainDao.selectByNextPat(facilityCd, machineTypeCd, machineSerial, searchStartDate);
    }
    List<OrdMain> retInfo = new ArrayList<>();
    if (o != null) {
      retInfo.add(o);
    }
    // #9290 2023.10.03 mod isSendCondition = true のときは元々のord_noを使用する、そうでないときも適切なSQLを使用する TDC片口 end

    // #9290 2023.09.28 del 不要な処理を削除 TDC片口 start
    /*
    // 対象外レコードリストを作成
    List<Integer> notTargetList = new ArrayList<Integer>();
    for (int i = 0; i < retInfo.size(); i++) {
      final Long indkurCd = retInfo.get(i).getIndKurCd().longValue();
      // 当日データの場合
      if (true == searchStartDate.equals(retInfo.get(i).getTreatDate())) {
        // 絞り込み条件にクール情報がある場合
        if (null != searchKurCd) {
          // 休日を除く当日の該当クール以外のデータを除去
          if ((false == DayOfWeek.SUNDAY.equals(LocalDateTime.parse(retInfo.get(i).getTreatDate() + "000000", dateFormat).getDayOfWeek())) &&
            (false == searchKurCd.equals(indkurCd))) {
            notTargetList.add(i);
            continue;
          }
        }
        // 翌日以降のデータの場合
      } else {
        // 絞り込み条件にクール情報がある場合
        if (null != searchKurCd) {
          // 休日を除く翌日以降のデータから該当クール以外のデータを除去
          if ((false == DayOfWeek.SUNDAY.equals(LocalDateTime.parse(retInfo.get(i).getTreatDate() + "000000", dateFormat).getDayOfWeek())) &&
            (false == searchKurCd.equals(indkurCd))) {
            notTargetList.add(i);
            continue;
          }
        }
      }
    }
    // 取得した次患者情報から対象外レコードを削除
    for (int i = notTargetList.size() - 1; i >= 0; i--) {
      retInfo.remove((int) notTargetList.get(i));
    }
     */
    // #9290 2023.09.28 del 不要な処理を削除 TDC片口 end

    // 次患者情報設定
    List<NextPatInfo> nextPatInfo = new ArrayList<NextPatInfo>();
    if (!retInfo.isEmpty()) {
      NextPatInfo tmp = new NextPatInfo();
      tmp.setNextPatid(retInfo.get(0).getPatId());
      tmp.setNextOrdNo(retInfo.get(0).getOrdNo());
      // #9290 2023.10.03 mod ????患者の場合のエラー対処 TDC片口 start
//      tmp.setNextKurCd(retInfo.get(0).getIndKurCd().longValue());
      Integer indKurCd = retInfo.get(0).getIndKurCd();
      tmp.setNextKurCd(indKurCd != null ? indKurCd.longValue() : null);
      // #9290 2023.10.03 mod ????患者の場合のエラー対処 TDC片口 end
      String indTreatStartTime = "0000";
      if (retInfo.get(0).getIndTreatStartTime() != null) {
        indTreatStartTime = retInfo.get(0).getIndTreatStartTime();
      }
      String startPlanDate = retInfo.get(0).getTreatDate() + indTreatStartTime + "00";
      tmp.setStartPlanDate(Timestamp.valueOf(LocalDateTime.parse(startPlanDate, dateFormat)));

      String IndCondInfo = retInfo.get(0).getIndCondInfo();
      if (retInfo.get(0).getIndTreatStartTime() != null && IndCondInfo != null) {
        JSONObject hoge = new JSONObject(IndCondInfo);
        if (hoge.has("1") && hoge.getJSONObject("1").has("value")) {
          int treatTime = hoge.getJSONObject("1").getInt("value");
          DateTimeFormatter f = DateTimeFormatter.ofPattern("yyyyMMddHHmm");
          LocalDateTime treatStartPlanDate = LocalDateTime.parse(retInfo.get(0).getTreatDate() + indTreatStartTime, f);
          LocalDateTime treatEndDate = treatStartPlanDate.plusMinutes(treatTime);
          String endPlanDate = treatEndDate.format(f);
          tmp.setEndPlanDate((Timestamp.valueOf(LocalDateTime.parse(endPlanDate + "00", dateFormat))));
        }
      }

      nextPatInfo.add(tmp);
    }

    return nextPatInfo;
  }

  // DB更新ログ出力ロジック wangzuo Start
  /**
   * ログ情報設定
   *
   * @return eventLogMessage
   */
  private EventLogMessage getEventLogMessage() {
    EventLogMessage eventLogMessage = new EventLogMessage();
    // サービス名
    eventLogMessage.setServiceName(LoggingConstant.MODULE_NAME.NTSS_WEB_API + "," + SERVICE_NAME.FNSI);
    return eventLogMessage;
  }

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
  // DB更新ログ出力ロジック wangzuo End
}
