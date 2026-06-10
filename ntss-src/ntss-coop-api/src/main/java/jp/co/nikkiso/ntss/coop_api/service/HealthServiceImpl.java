package jp.co.nikkiso.ntss.coop_api.service;

import java.io.IOException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.HashMap;
import java.util.Map;
import java.util.TimeZone;

import jp.co.nikkiso.ntss.coop_api.request.HealthUpdateRequest;
import jp.co.nikkiso.ntss.coop_api.request.JournalCreateRequest;
import jp.co.nikkiso.ntss.coop_api.request.JournalDeliveryRequest;
import jp.co.nikkiso.ntss.coop_api.request.JournalUpdateRequest;
import jp.co.nikkiso.ntss.coop_api.web.websocket.IfEdgeMntSessionManager;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.dao.MstCoopFacilityDao;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.coop_api.mapping.HealthmonFacility;
import jp.co.nikkiso.ntss.coop_api.mapping.HealthmonServer;
import jp.co.nikkiso.ntss.coop_api.utils.ClockWrapper;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants.AnaResult;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants.CoopResult;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants.IFHealthMonitorStatus;
import jp.co.nikkiso.ntss.core.dao.MntIfEdgeHealthmonDao;
import jp.co.nikkiso.ntss.core.dao.SysCoopJournalDao;
import jp.co.nikkiso.ntss.core.entity.MntIfEdgeHealthmon;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.coop_api.service.LogService;
import org.springframework.util.StringUtils;

@Service
public class HealthServiceImpl implements HealthService {
  /** DI */
  @Autowired
  MntIfEdgeHealthmonDao mntIfEdgeHealthmonDao;

  @Autowired
  SysCoopJournalDao sysCoopJournalDao;

  /* add by chamaojia 2024-10-11 [11140] Add bean injection --start */
  /**
   * 連携設定マスタDao
   */
  @Autowired
  MstCoopFacilityDao mstCoopFacilityDao;

  @Autowired
  IfEdgeMntSessionManager ifEdgeMntSessionManager;
  /* add by chamaojia 2024-10-11 [11140] Add bean injection --end */

  @Autowired
  ClockWrapper clockWrapper;

  @Autowired
  private LogService logService;

  /* delete by chamaojia 2024-09-09 [10574] delete transaction annotation --start */
//  @Transactional
  /* delete by chamaojia 2024-09-09 [10574] delete transaction annotation --end */
  @Override
  public MntIfEdgeHealthmon update(HealthUpdateRequest request) {
    EventLogMessage eventLogMessage = new EventLogMessage();

    /* modify by chamaojia 2024-10-11 [11140] 【healthmon_facility_conn】 JSON structure change
                                              【mnt_if_edge_healthmon】 coop_version delete --start */
    // 連携エッジヘルスモニタを取得する
    MntIfEdgeHealthmon mntIfEdgeHealthmonToQuery = mntIfEdgeHealthmonDao
      .selectByFacilityAndIfEdgeNo(request.getFacilityCd(), request.getIfEdgeNo());

    if (mntIfEdgeHealthmonToQuery == null) {
      eventLogMessage.setLogMessage("エッジヘルスモニタテーブル更新処理で、更新対象となるレコードが存在しません。新しいレコードを作成します。");
      eventLogMessage.setInvokeClass(this.getClass().getName());
      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);

      // 連携エッジヘルスモニタが存在時、新しいのを作成する
      Timestamp now = new Timestamp(clockWrapper.getClockMillis());
      MntIfEdgeHealthmon mntIfEdgeHealthmon = new MntIfEdgeHealthmon();
      mntIfEdgeHealthmon.setFacilityCd(request.getFacilityCd());
      mntIfEdgeHealthmon.setIfEdgeNo(request.getIfEdgeNo());
//      mntIfEdgeHealthmon.setCoopVersion(coopVersion);
      mntIfEdgeHealthmon.setUpDate(now);
      mntIfEdgeHealthmon.setRegDate(now);

      try {
        Map<String, Map<String, HealthmonFacility>> hFacilityCMap =
                ifEdgeMntSessionManager.getCoopFacilitySettingToHFMap(request.getFacilityCd());
        if (!hFacilityCMap.isEmpty()) {
          mntIfEdgeHealthmon.setHealthmonFacilityConn(ObjectMapperUtil.write(hFacilityCMap));
        }
      } catch (IOException e) {
        eventLogMessage.setLogMessage("JSONとしてのデータ変換でエラーが発生しました。");
        eventLogMessage.setInvokeClass(this.getClass().getName());
        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        throw new NtssException("JSONとしてのデータ変換でエラーが発生しました。", e);
      }

      mntIfEdgeHealthmonDao.insert(mntIfEdgeHealthmon);

      mntIfEdgeHealthmonToQuery = mntIfEdgeHealthmonDao.selectByFacilityAndIfEdgeNo(request.getFacilityCd()
              , request.getIfEdgeNo());
    }

    /* modify by chamaojia 2024-09-26 [10574] change from cyclic data modification to batch data modification --start */
//// add 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//    MntIfEdgeHealthmon mntIfEdgeHealthmonReturn = null;
//    for (MntIfEdgeHealthmon mntIfEdgeHealthmon : mntIfEdgeHealthmonList) {
//// add 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//      try {
//        // エッジステータス部分を selectデータから作成する
//        Map<String, HealthmonFacility> updateHealthmonFacilityConn = createUpdateValueForHealthmonFacilityConn(
//            request.getHealthmonFacilityConn(), mntIfEdgeHealthmon.getHealthmonFacilityConn());
//        // サーバステータス部分が 指定されていなければ 更新しない
//        HealthmonServer updateHealthmonServerConn = createUpdateValueForHealthmonServerConn(
//            request.getHealthmonServerConn());
//
//        // JSON文字列に変換して update する
//        // 値がない場合は、更新対象にならないように null をセットする
//// add 2023-02-22 bug #6912 エッジの連携処理を停止しても稼働ビューア画面では正常と表示される 孫 start
//        String serverConnString = mntIfEdgeHealthmon.getHealthmonServerConn();
//        if (!StringUtils.isEmpty(serverConnString)) {
//          HealthmonServer healthmonServer = ObjectMapperUtil.read(serverConnString, HealthmonServer.class);
//          String journalInterval = healthmonServer.getJournalInterval();
//          String mainInterval = healthmonServer.getMainInterval();
//          if (!StringUtils.isEmpty(journalInterval)) {
//            updateHealthmonServerConn.setJournalInterval(journalInterval);
//          }
//          if (!StringUtils.isEmpty(mainInterval)) {
//            updateHealthmonServerConn.setMainInterval(mainInterval);
//          }
//        }
//// add 2023-02-22 bug #6912 エッジの連携処理を停止しても稼働ビューア画面では正常と表示される 孫 end
//        mntIfEdgeHealthmon.setHealthmonServerConn(null);
//        if (updateHealthmonServerConn != null) {
//          String healthmonServerConnStr = ObjectMapperUtil.write(updateHealthmonServerConn);
//          mntIfEdgeHealthmon.setHealthmonServerConn(healthmonServerConnStr);
//        }
//        // 値がない場合は、更新対象にならないように null をセットする
//        mntIfEdgeHealthmon.setHealthmonFacilityConn(null);
//        if (!updateHealthmonFacilityConn.isEmpty()) {
//          String healthmonFacilityConnStr = ObjectMapperUtil.write(updateHealthmonFacilityConn);
//          mntIfEdgeHealthmon.setHealthmonFacilityConn(healthmonFacilityConnStr);
//        }
//
//      } catch (IOException e) {
//        eventLogMessage.setLogMessage("エッジステータスの更新用データ作成処理で、データをJSONとして変換する際にエラーが発生しました。");
//        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
//        eventLogMessage.setInvokeClass(this.getClass().getName());
//        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
//        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
//        throw new NtssException("JSONとしてのデータ変換でエラーが発生しました。", e);
//      }
//      mntIfEdgeHealthmonDao.updateServerAndFacilityConn(mntIfEdgeHealthmon);
//// add 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//      if (mntIfEdgeHealthmonReturn == null) {
//        mntIfEdgeHealthmonReturn = new MntIfEdgeHealthmon();
//        BeanUtils.copyProperties(mntIfEdgeHealthmon, mntIfEdgeHealthmonReturn);
//      }
//    }
//// add 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//
//// mod 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
////    return mntIfEdgeHealthmon;
//    return mntIfEdgeHealthmonReturn;
//// mod 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

    String healthmonServerConnStr = null;
    String healthmonFacilityConnStr = null;
    try {
      // エッジステータス部分を selectデータから作成する
      Map<String, Map<String, HealthmonFacility>> updateHealthmonFacilityConn = createUpdateValueForHealthmonFacilityConn(
              request.getHealthmonFacilityConn(), request.getCoopVersion());
      // サーバステータス部分が 指定されていなければ 更新しない
      Map<String, String> updateHealthmonServerConn = createUpdateValueForHealthmonServerConn(
              request.getHealthmonServerConn());

      if (updateHealthmonServerConn != null) {
        healthmonServerConnStr = ObjectMapperUtil.write(updateHealthmonServerConn);
      }
      // 値がない場合は、更新対象にならないように null をセットする
      if (!updateHealthmonFacilityConn.isEmpty()) {
        healthmonFacilityConnStr = ObjectMapperUtil.write(updateHealthmonFacilityConn);
      }
    } catch (IOException e) {
      eventLogMessage.setLogMessage("エッジステータスの更新用データ作成処理で、データをJSONとして変換する際にエラーが発生しました。");
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      throw new NtssException("JSONとしてのデータ変換でエラーが発生しました。", e);
    }

    MntIfEdgeHealthmon mntIfEdgeHealthmon = mntIfEdgeHealthmonDao
            .updateServerAndFacilityConnByCtlNo(healthmonServerConnStr, healthmonFacilityConnStr
                    , mntIfEdgeHealthmonToQuery.getCtlNo());

    return mntIfEdgeHealthmon;
    /* modify by chamaojia 2024-09-26 [10574] change from cyclic data modification to batch data modification --end */
    /* modify by chamaojia 2024-10-11 [11140] 【healthmon_facility_conn】 JSON structure change
                                              【mnt_if_edge_healthmon】 coop_version delete --end */
  }

  /**
   * リクエストパラメータ から update用のデータを作成して返す
   *
   * @param requestValue [NULL] リクエストパラメータの サーバステータス
   * @return [NULL] {@code requestValue が NULL の場合：NULL、requestValue が NULL でない場合：リクエストの値を使用する}
   */
  /* modify by chamaojia 2024-09-26 [10574] modify the return value type --start */
  private Map<String, String> createUpdateValueForHealthmonServerConn(HealthmonServer requestValue) {
    // リクエストがない場合は、NULL を返す
    if (requestValue == null) {
      return null;
    }

    Map<String, String> resultMap = new HashMap<>();
    resultMap.put("status", requestValue.getStatus());
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    sdf.setTimeZone(TimeZone.getTimeZone(CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO));
    resultMap.put("moni_time", sdf.format(new Timestamp(clockWrapper.getClockMillis())));

    return resultMap;
  }
  /* modify by chamaojia 2024-09-26 [10574] modify the return value type --end */

  /* modify by chamaojia 2024-10-11 [11140] 【healthmon_facility_conn】 JSON structure change --start */
  /**
   * 更新対象の エッジステータスと リクエストパラメータのデータから update用のデータを作成して返す
   *
   * @param requestMap [NULL] リクエストパラメータの エッジステータス
   * @return [NOT NULL] {@code key: requestMap にあるもの、value: selectStr を元に requestMap の値を反映させたもの}
   * @throws IOException {@code selectStr をJSONオブジェクトに変換する際に異常が発生した場合}
   * @throws NtssException {@code selectStr に リクエストで指定された"電文種別"が存在しなかった場合}
   */
  private Map<String, Map<String, HealthmonFacility>> createUpdateValueForHealthmonFacilityConn(
          Map<String, HealthmonFacility> requestMap, String coopVersion) throws IOException {
    Map<String, Map<String, HealthmonFacility>> result = new HashMap<>();

    if (requestMap == null) {
      return result;
    }

    Timestamp updateTime = new Timestamp(clockWrapper.getClockMillis());
// del 2023-01-29 bug #7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 孫 start
//    Map<String, HealthmonFacility> selectMap = ObjectMapperUtil.readTypeReference(selectStr, new TypeReference<Map<String, HealthmonFacility>>() {});
// del 2023-01-29 bug #7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 孫 end

    EventLogMessage eventLogMessage = new EventLogMessage();
    for (String coopCd : requestMap.keySet()) {
// mod 2023-01-29 bug #7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 孫 start
//      HealthmonFacility healthmonFacility = selectMap.get(coopCd);
//      if (healthmonFacility == null) {
//        eventLogMessage.setLogMessage("エッジステータスの更新用データ作成処理で、マスタデータに更新対象の電文種別が存在しません。");
//        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
//        eventLogMessage.setInvokeClass(this.getClass().getName());
//        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
//        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
//        throw new NtssException("マスタデータに更新対象の電文種別が存在しません。");
//      }
      HealthmonFacility healthmonFacility = requestMap.get(coopCd);
// mod 2023-01-29 bug #7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 孫 end
      healthmonFacility.setStatus(requestMap.get(coopCd).getStatus());
      healthmonFacility.setMoniTime(updateTime);
      Map<String, HealthmonFacility> hMap = new HashMap<>();
      hMap.put(coopCd, healthmonFacility);
      if (CoreConstant.HealthmonFctJson.BUSINESS_HEADER.equals(coopCd)
              || CoreConstant.HealthmonFctJson.MANAGER_HEADER.equals(coopCd)) {
        if (result.containsKey("edge")) {
          result.get("edge").put(coopCd, healthmonFacility);
        } else {
          result.put("edge", hMap);
        }
      } else {
        if (result.containsKey(coopVersion)) {
          result.get(coopVersion).put(coopCd, healthmonFacility);
        } else {
          result.put(coopVersion, hMap);
        }
      }
    }

    return result;

  }
  /* modify by chamaojia 2024-10-11 [11140] 【healthmon_facility_conn】 JSON structure change --end */

  /**
   * 双方の値が、以下のいずれかの場合のみ更新します
   * <ul>
   *   <li>AnaResult
   *     <ul>
   *       <li>{@link AnaResult#DONE DONE}
   *     </ul>
   *   <li>CoopResult
   *     <ul>
   *       <li>{@link CoopResult#DONE DONE}
   *       <li>{@link CoopResult#INTERNAL_ERROR_BY_NTSS INTERNAL_ERROR_BY_NTSS}
   *       <li>{@link CoopResult#INTERNAL_ERROR_BY_CARTE INTERNAL_ERROR_BY_CARTE}
   *     </ul>
   * </ul>
   */
  @Transactional
  @Override
  public void update(JournalUpdateRequest request) {
    //add #9799 クールマスタ変更の場合、「連携エッジヘルスモニタ」を更新しない zhaoqi 20231215 start
    if("005001".equals(request.getOpeCd())) return;
    //add #9799 クールマスタ変更の場合、「連携エッジヘルスモニタ」を更新しない zhaoqi 20231215 end
    // 配信に対するレスポンス時のみ実施
    if (!AnaResult.DONE.isSameResult(request.getAnaResult())) {
      return;
    }
    if (!CoopResult.DONE.isSameResult(request.getCoopResult())
// add 2023-01-29 bug #7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 孫 start
        && !CoopResult.RETRY.isSameResult(request.getCoopResult())
// add 2023-01-29 bug #7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 孫 end
        && !CoopResult.INTERNAL_ERROR_BY_NTSS.isSameResult(request.getCoopResult())
        && !CoopResult.INTERNAL_ERROR_BY_CARTE.isSameResult(request.getCoopResult())) {
      return;
    }

    // エッジステータス
    IFHealthMonitorStatus facilityStatus = CoopResult.DONE.isSameResult(request.getCoopResult())
        ? IFHealthMonitorStatus.FACILITY_ACTIVE
        : IFHealthMonitorStatus.FACILITY_ERROR;

    // サーバステータスは リクエストが届いているため正常
    update(request.getCtlNo(), NtssCoopApiConstants.IF_EDGE_NO_DEFAULT,
        IFHealthMonitorStatus.SERVER_ACTIVE,  facilityStatus);
  }

  /**
   * 双方の値が、以下のいずれかの場合のみ更新します
   * <ul>
   *   <li>AnaResult
   *     <ul>
   *       <li>{@link AnaResult#UNPROCESS UNPROCESS}
   *     </ul>
   *   <li>CoopResult
   *     <ul>
   *       <li>{@link CoopResult#DONE DONE}
   *       <li>{@link CoopResult#INTERNAL_ERROR_BY_NTSS INTERNAL_ERROR_BY_NTSS}
   *       <li>{@link CoopResult#INTERNAL_ERROR_BY_CARTE INTERNAL_ERROR_BY_CARTE}
   *     </ul>
   * </ul>
   */
  @Transactional
  @Override
  public void update(JournalCreateRequest request) {
    // 受信電文のPOST時のみ実施
    if (!AnaResult.UNPROCESS.isSameResult(request.getAnaResult())) {
      return;
    }
    if (!CoopResult.DONE.isSameResult(request.getCoopResult())
// add 2023-01-29 bug #7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 孫 start
        && !CoopResult.RETRY.isSameResult(request.getCoopResult())
// add 2023-01-29 bug #7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 孫 end
        && !CoopResult.INTERNAL_ERROR_BY_NTSS.isSameResult(request.getCoopResult())
        && !CoopResult.INTERNAL_ERROR_BY_CARTE.isSameResult(request.getCoopResult())) {
      return;
    }

    // エッジステータス
    IFHealthMonitorStatus facilityStatus = CoopResult.DONE.isSameResult(request.getCoopResult())
        ? IFHealthMonitorStatus.FACILITY_ACTIVE
        : IFHealthMonitorStatus.FACILITY_ERROR;

    // サーバステータスは リクエストが届いているため正常
// mod 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//    update(request.getFacilityCd(), NtssCoopApiConstants.IF_EDGE_NO_DEFAULT,
//        IFHealthMonitorStatus.SERVER_ACTIVE, request.getCoopCd(), facilityStatus);
    String coopVersion = StringUtils.isEmpty(request.getCoopVersion())?"":request.getCoopVersion();
    update(request.getFacilityCd(), coopVersion, NtssCoopApiConstants.IF_EDGE_NO_DEFAULT,
      IFHealthMonitorStatus.SERVER_ACTIVE, request.getCoopCd(), facilityStatus);
// mod 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  }

  // #10453 add 死活監視が動作していない 2024-05-16 荘 start
  @Override
  public void update(SysCoopJournal journal, String anaResult) {
    if (!AnaResult.INTERNAL_ERROR.isSameResult(anaResult)
      ||!"R".equals(journal.getDirection())) {
      return;
    }

    // エッジステータス
    IFHealthMonitorStatus facilityStatus = AnaResult.DONE.isSameResult(anaResult)
      ? IFHealthMonitorStatus.FACILITY_ACTIVE
      : IFHealthMonitorStatus.FACILITY_ERROR;

    // サーバステータスは リクエストが届いているため正常
    update(journal.getCtlNo(), NtssCoopApiConstants.IF_EDGE_NO_DEFAULT,
      IFHealthMonitorStatus.SERVER_ACTIVE,  facilityStatus);
  }
  // #10453 add 死活監視が動作していない 2024-05-16 荘 end

  /**
   * 指定した内容を元に IFエッジヘルスモニタのデータを更新する
   *
   * @param ctlNo [NOT NULL] 管理番号
   * @param ifEdgeNo [NOT NULL] IFエッジ番号
   * @param serverStatus [NOT NULL] サーバステータス
   * @param facilityStatus [NOT NULL] エッジステータス
   */
  private void update(Long ctlNo, Integer ifEdgeNo, IFHealthMonitorStatus serverStatus, IFHealthMonitorStatus facilityStatus) {
    SysCoopJournal journal = sysCoopJournalDao.selectByPK(ctlNo);
// mod 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//    HealthUpdateRequest request = createUpdateRequest(journal.getFacilityCd(), ifEdgeNo, serverStatus);
    String coopVersion = StringUtils.isEmpty(journal.getCoopVersion())?"":journal.getCoopVersion();
    HealthUpdateRequest request = createUpdateRequest(journal.getFacilityCd(), coopVersion, ifEdgeNo, serverStatus);
// mod 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

    // #10453 mod 死活監視が動作していない 2024-05-16 荘 start
    Map<String, HealthmonFacility> facilityConn = new HashMap<>();
    //request.setHealthmonFacilityConn(facilityConn);

    HealthmonFacility healthmonFacility = new HealthmonFacility();
    facilityConn.put(journal.getCoopCd(), healthmonFacility);
    healthmonFacility.setStatus(facilityStatus.getValue());


    request.setHealthmonFacilityConn(facilityConn);
    // #10453 mod 死活監視が動作していない 2024-05-16 荘 end

    update(request);
  }

  /**
   * 指定した内容を元に IFエッジヘルスモニタのデータを更新する
   *
   * @param facilityCd [NOT NULL] 施設コード
   * @param coopVersion [NOT NULL] 連携版番号
   * @param ifEdgeNo [NOT NULL] IFエッジ番号
   * @param serverStatus [NOT NULL] サーバステータス
   * @param coopCd [NOT NULL] 電文種別
   * @param facilityStatus [NOT NULL] エッジステータス
   */
// mod 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  private void update(String facilityCd, Integer ifEdgeNo, IFHealthMonitorStatus serverStatus,
//      String coopCd, IFHealthMonitorStatus facilityStatus) {
//    HealthUpdateRequest request = createUpdateRequest(facilityCd, ifEdgeNo, serverStatus);
  private void update(String facilityCd, String coopVersion, Integer ifEdgeNo, IFHealthMonitorStatus serverStatus,
                      String coopCd, IFHealthMonitorStatus facilityStatus) {
    HealthUpdateRequest request = createUpdateRequest(facilityCd, coopVersion, ifEdgeNo, serverStatus);
// mod 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

    Map<String, HealthmonFacility> facilityConn = new HashMap<>();
    request.setHealthmonFacilityConn(facilityConn);

    HealthmonFacility healthmonFacility = new HealthmonFacility();
    facilityConn.put(coopCd, healthmonFacility);
    healthmonFacility.setStatus(facilityStatus.getValue());

    update(request);
  }

  /**
   * 指定した内容を元に IFエッジヘルスモニタ更新API の リクエストを作成し、返す
   *
   * @param facilityCd [NOT NULL] 施設コード
   * @param coopVersion [NOT NULL] 連携版番号
   * @param ifEdgeNo [NOT NULL] IFエッジ番号
   * @param serverStatus [NOT NULL] サーバステータス
   * @return [NOT NULL] 指定した値を設定した リクエスト
   */
// mod 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  private HealthUpdateRequest createUpdateRequest(String facilityCd, Integer ifEdgeNo,
//      IFHealthMonitorStatus serverStatus) {
  private HealthUpdateRequest createUpdateRequest(String facilityCd, String coopVersion, Integer ifEdgeNo,
        IFHealthMonitorStatus serverStatus) {
// mod 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    HealthUpdateRequest request = new HealthUpdateRequest();
    request.setFacilityCd(facilityCd);
    request.setIfEdgeNo(ifEdgeNo);
// add 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    request.setCoopVersion(coopVersion);
// add 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
    HealthmonFacility healthmonFacility = new HealthmonFacility();
    Map<String,HealthmonFacility> healthmonFacilityMap= new HashMap<>();
    healthmonFacility.setStatus(serverStatus.getValue());
    // #10453 mod 死活監視が動作していない 荘 2024-07-03 start
//    healthmonFacilityMap.put("accept",healthmonFacility);
    /* modify by chamaojia 2024-10-11 [11140] using constants --start */
    healthmonFacilityMap.put(CoreConstant.HealthmonFctJson.BUSINESS_HEADER,healthmonFacility);
    /* modify by chamaojia 2024-10-11 [11140] using constants --end */
    // #10453 mod 死活監視が動作していない 荘 2024-07-03 end
    request.setHealthmonFacilityConn(healthmonFacilityMap);
    // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
    HealthmonServer healthmonServer = new HealthmonServer();
    request.setHealthmonServerConn(healthmonServer);
    healthmonServer.setStatus(serverStatus.getValue());

    return request;
  }

  /* delete by chamaojia 2024-09-09 [10574] delete transaction annotation --start */
//  @Transactional
  /* delete by chamaojia 2024-09-09 [10574] delete transaction annotation --end */
  @Override
  public void update(JournalDeliveryRequest request) {
    // サーバステータスは リクエストが届いているため正常
    // サーバステータスのみ更新
// mod 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//    HealthUpdateRequest updateRequest = createUpdateRequest(request.getFacilityCd(),
//        NtssCoopApiConstants.IF_EDGE_NO_DEFAULT, IFHealthMonitorStatus.SERVER_ACTIVE);
    HealthUpdateRequest updateRequest = createUpdateRequest(request.getFacilityCd(), null,
      NtssCoopApiConstants.IF_EDGE_NO_DEFAULT, IFHealthMonitorStatus.SERVER_ACTIVE);
// mod 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

    update(updateRequest);
  }
}
