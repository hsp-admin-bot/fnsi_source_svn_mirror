package jp.co.nikkiso.ntss.web_api.service;

import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.EXPIRE_TARGET_TABLE_FNSI;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.EXPIRE_TARGET_TABLE_REMS_ONLY;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.FACILITY_EXPIRE_KEY_DB_CLASS;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.FACILITY_EXPIRE_KEY_EXCEPTION;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.FACILITY_EXPIRE_KEY_RETENTION_PERIOD;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.FACILITY_EXPIRE_KEY_TABLE_NAME;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.FACILITY_EXPIRE_KEY_TIME_COLUMN_NAME;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.STAT_KEY_TABLE_NAME;

import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneOffset;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.constant.CoreConstant.SystemUseSettings;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MstFacilityHashDao;
import jp.co.nikkiso.ntss.core.dao.SysSystemDefineDao;
import jp.co.nikkiso.ntss.core.entity.MstFacilityHash;
import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.web_api.config.FacilityCancelConfig;
import jp.co.nikkiso.ntss.web_api.service.component.SubTransactionComponent;
import jp.co.nikkiso.ntss.web_api.service.utils.CalendarUtil;

/**
 * 期間外削除サービス実装クラス。
 */
@Service
public class FacilityExpireServiceImpl implements FacilityExpireService {
  /** トランザクション管理を伴う処理 */
  @Autowired
  private SubTransactionComponent subTransactionComponent;

  // サービス
  /** ログサービス */
  @Autowired
  private LogService logService;

  // 設定
  /** 設定値取得 */
  @Autowired
  private FacilityCancelConfig config;

  /** システム設定 */
  @Autowired
  private SysSystemDefineDao sysSystemDefineDao;

  /** 施設マスタハッシュ */
  @Autowired
  private MstFacilityHashDao mstFacilityHashDao;

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional(noRollbackFor = { NtssException.class })
  public void executeExpire(LocalDateTime baseDate, LocalTime endTime, int mode, List<String> targetFacilityCdList,LocalTime startTime) {
    try {
      List<String> arrSystemUseSettings = new ArrayList<String>();
      arrSystemUseSettings.add(SystemUseSettings.REMS_ONLY);
      Integer ssdKey = EXPIRE_TARGET_TABLE_REMS_ONLY;
      if (mode == 2) {
        // FNSIを含む施設
        arrSystemUseSettings.clear();
        arrSystemUseSettings.add(SystemUseSettings.FNSI_ONLY);
        arrSystemUseSettings.add(SystemUseSettings.FNSI_REMS);
        ssdKey = EXPIRE_TARGET_TABLE_FNSI;
      }

      // システム利用設定に応じた施設一覧
      List<String> targetFacilities;
      if (targetFacilityCdList == null || targetFacilityCdList.size() == 0) {
        List<MstFacilityHash> lstMstFacilityHash = mstFacilityHashDao.selectAll();
        targetFacilities = lstMstFacilityHash.stream()
            .filter(facility -> arrSystemUseSettings.contains(facility.getSystemUseSetting()))
            .map(MstFacilityHash::getFacilityCd)
            .collect(Collectors.toList());
      } else {
        // 引数で対象施設が指定されている場合はその施設のみ処理する
        targetFacilities = targetFacilityCdList;
      }
      if (targetFacilities.isEmpty()) {
        // 対象施設なしの場合はここで処理終了
        return;
      }

      // 基準日を実行月の最初の日に設定
      LocalDateTime baseDateLdt = LocalDateTime.parse(DateTimeFormatter.ofPattern("uuuuMMdd").format(baseDate) + "000000", DateTimeFormatter.ofPattern("uuuuMMddHHmmss"));
      ZonedDateTime zdt = baseDateLdt.atZone(ZoneOffset.ofHours(+9));
      Long baseDateLong = zdt.toEpochSecond() * 1000;

      // 期間外削除の対象テーブルを取得する。
      SysSystemDefine ssd = sysSystemDefineDao.selectByCtlNo(ssdKey).get(0);
      String valueStr = ssd.getValue();
      JSONArray arrTempTables = new JSONArray(valueStr);
      JSONArray arrTargetTable = new JSONArray();

      // テーブル削除順序を取得する
      List<Map<String, Object>> priorityTableList = config.getPriorityTableList();
      // テーブル削除順序に沿って並べ替え
      if (priorityTableList != null) {
        for (Map<String, Object> priority : priorityTableList) {
          String tableName = (String) priority.get(STAT_KEY_TABLE_NAME);
          for (int idx = 0; idx < arrTempTables.length(); idx++) {
            JSONObject tmpTable = arrTempTables.getJSONObject(idx);
            if (tmpTable.get(FACILITY_EXPIRE_KEY_TABLE_NAME).toString().equals(tableName)) {
              // 期間外削除の対象テーブル一覧に、削除順序指定テーブルが存在した場合は優先的に削除
              arrTargetTable.put(tmpTable);
              arrTempTables.remove(idx);
              break;
            }
          }
        }
      }
      // 削除順序が指定されていない残りテーブルを全件削除テーブルリストに追加
      for (int idx = 0; idx < arrTempTables.length(); idx++) {
        arrTargetTable.put(arrTempTables.get(idx));
      }

      // 1テーブル毎に期間外データ削除処理を行う
      for (int idx = 0; idx < arrTargetTable.length(); idx++) {
        // 終了時間判定
        if (LocalTime.now().isAfter(endTime)) {
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("終了時刻を過ぎたため、期間外データ削除処理を中断します。");
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
          break;
        }

        JSONObject jsonTargetTable = arrTargetTable.getJSONObject(idx);
        Integer dbClass = Integer.valueOf(jsonTargetTable.get(FACILITY_EXPIRE_KEY_DB_CLASS).toString());
        String tableName = jsonTargetTable.get(FACILITY_EXPIRE_KEY_TABLE_NAME).toString();
        String timeColumnName = jsonTargetTable.get(FACILITY_EXPIRE_KEY_TIME_COLUMN_NAME).toString();

        // 全施設情報
        List<String> defFacilities = new ArrayList<String>(targetFacilities);

        // 削除期間をキー、削除対象施設コードの配列を値としたmapを作成
        Map<Integer, List<String>> mapDelInfo = new HashMap<Integer, List<String>>();

        // 基本削除期間
        Integer retentionPeriod = Integer.valueOf(jsonTargetTable.get(FACILITY_EXPIRE_KEY_RETENTION_PERIOD).toString());
        // 例外施設設定
        JSONObject exception = jsonTargetTable.getJSONObject(FACILITY_EXPIRE_KEY_EXCEPTION);
        Iterator<String> keys = exception.keys();
        while(keys.hasNext()) {
          // 削除期間
          String key = keys.next();
          // 施設のリスト
          List<String> lstFacilities = new ArrayList<String>();
          JSONArray jsonFacilities = exception.getJSONArray(key);
          for (int i = 0; i < jsonFacilities.length(); i++) {
            lstFacilities.add(jsonFacilities.getString(i));
            defFacilities.remove(defFacilities.indexOf(jsonFacilities.getString(i)));
          }
          if (!"0".equals(key)) {
            Integer intKey = Integer.valueOf(key);
            // 削除期間が"0"の場合は削除対象外
            if (mapDelInfo.containsKey(intKey)) {
              List<String> tmpData = mapDelInfo.get(intKey);
              tmpData.addAll(lstFacilities);
              mapDelInfo.put(intKey, tmpData);
            } else {
              mapDelInfo.put(intKey, lstFacilities);
            }
          }
        }
        // 標準の削除期間で削除を行う施設リストを追加
        if (!Integer.valueOf(0).equals(retentionPeriod)) {
          // 削除期間が"0"の場合は削除対象外
          if (mapDelInfo.containsKey(retentionPeriod)) {
            List<String> tmpData = mapDelInfo.get(retentionPeriod);
            tmpData.addAll(defFacilities);
            mapDelInfo.put(retentionPeriod, tmpData);
          } else {
            mapDelInfo.put(retentionPeriod, defFacilities);
          }
        }

        for(Integer key : mapDelInfo.keySet()){
          if (LocalTime.now().isBefore(startTime) || LocalTime.now().plusMinutes(10).isAfter(endTime)) {
            break;
          }
          Long criteriaTime = CalendarUtil.shiftMonth(baseDateLong, -key);
          subTransactionComponent.delete(dbClass, tableName, mapDelInfo.get(key), timeColumnName, criteriaTime);
        };
      }
    } catch (Exception e) {
      throw new NtssException(e);
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public void executeExpireFacility(LocalDateTime baseDate, LocalTime endTime, String facilityCd,LocalTime startTime) {
    MstFacilityHash facility = mstFacilityHashDao.selectByFacilityCd(facilityCd);
    if (facility == null) {
      throw new NtssException("指定された施設のデータが存在しません: 施設コード：" + facilityCd);
    }

    // システム利用区分判別
    int mode = 1;
    if (SystemUseSettings.FNSI_ONLY.equals(facility.getSystemUseSetting())
        || SystemUseSettings.FNSI_REMS.equals(facility.getSystemUseSetting()) ) {
      mode = 2;
    }
    // 処理対象施設
    List<String> targetFacility = new ArrayList<String>();
    targetFacility.add(facilityCd);

    // 期間外データ削除処理呼び出し
    this.executeExpire(baseDate, endTime, mode, targetFacility,startTime);
  }
  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional(noRollbackFor = { NtssException.class })
  public void executeExpire(LocalDateTime baseDate, LocalTime endTime, int mode, List<String> targetFacilityCdList) {
    try {
      List<String> arrSystemUseSettings = new ArrayList<String>();
      arrSystemUseSettings.add(SystemUseSettings.REMS_ONLY);
      Integer ssdKey = EXPIRE_TARGET_TABLE_REMS_ONLY;
      if (mode == 2) {
        // FNSIを含む施設
        arrSystemUseSettings.clear();
        arrSystemUseSettings.add(SystemUseSettings.FNSI_ONLY);
        arrSystemUseSettings.add(SystemUseSettings.FNSI_REMS);
        ssdKey = EXPIRE_TARGET_TABLE_FNSI;
      }

      // システム利用設定に応じた施設一覧
      List<String> targetFacilities;
      if (targetFacilityCdList == null || targetFacilityCdList.size() == 0) {
        List<MstFacilityHash> lstMstFacilityHash = mstFacilityHashDao.selectAll();
        targetFacilities = lstMstFacilityHash.stream()
          .filter(facility -> arrSystemUseSettings.contains(facility.getSystemUseSetting()))
          .map(MstFacilityHash::getFacilityCd)
          .collect(Collectors.toList());
      } else {
        // 引数で対象施設が指定されている場合はその施設のみ処理する
        targetFacilities = targetFacilityCdList;
      }
      if (targetFacilities.isEmpty()) {
        // 対象施設なしの場合はここで処理終了
        return;
      }

      // 基準日を実行月の最初の日に設定
      LocalDateTime baseDateLdt = LocalDateTime.parse(DateTimeFormatter.ofPattern("uuuuMMdd").format(baseDate) + "000000", DateTimeFormatter.ofPattern("uuuuMMddHHmmss"));
      ZonedDateTime zdt = baseDateLdt.atZone(ZoneOffset.ofHours(+9));
      Long baseDateLong = zdt.toEpochSecond() * 1000;

      // 期間外削除の対象テーブルを取得する。
      SysSystemDefine ssd = sysSystemDefineDao.selectByCtlNo(ssdKey).get(0);
      String valueStr = ssd.getValue();
      JSONArray arrTempTables = new JSONArray(valueStr);
      JSONArray arrTargetTable = new JSONArray();

      // テーブル削除順序を取得する
      List<Map<String, Object>> priorityTableList = config.getPriorityTableList();
      // テーブル削除順序に沿って並べ替え
      if (priorityTableList != null) {
        for (Map<String, Object> priority : priorityTableList) {
          String tableName = (String) priority.get(STAT_KEY_TABLE_NAME);
          for (int idx = 0; idx < arrTempTables.length(); idx++) {
            JSONObject tmpTable = arrTempTables.getJSONObject(idx);
            if (tmpTable.get(FACILITY_EXPIRE_KEY_TABLE_NAME).toString().equals(tableName)) {
              // 期間外削除の対象テーブル一覧に、削除順序指定テーブルが存在した場合は優先的に削除
              arrTargetTable.put(tmpTable);
              arrTempTables.remove(idx);
              break;
            }
          }
        }
      }
      // 削除順序が指定されていない残りテーブルを全件削除テーブルリストに追加
      for (int idx = 0; idx < arrTempTables.length(); idx++) {
        arrTargetTable.put(arrTempTables.get(idx));
      }

      // 1テーブル毎に期間外データ削除処理を行う
      for (int idx = 0; idx < arrTargetTable.length(); idx++) {
        // 終了時間判定
        if (LocalTime.now().isAfter(endTime)) {
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("終了時刻を過ぎたため、期間外データ削除処理を中断します。");
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
          break;
        }

        JSONObject jsonTargetTable = arrTargetTable.getJSONObject(idx);
        Integer dbClass = Integer.valueOf(jsonTargetTable.get(FACILITY_EXPIRE_KEY_DB_CLASS).toString());
        String tableName = jsonTargetTable.get(FACILITY_EXPIRE_KEY_TABLE_NAME).toString();
        String timeColumnName = jsonTargetTable.get(FACILITY_EXPIRE_KEY_TIME_COLUMN_NAME).toString();

        // 全施設情報
        List<String> defFacilities = new ArrayList<String>(targetFacilities);

        // 削除期間をキー、削除対象施設コードの配列を値としたmapを作成
        Map<Integer, List<String>> mapDelInfo = new HashMap<Integer, List<String>>();

        // 基本削除期間
        Integer retentionPeriod = Integer.valueOf(jsonTargetTable.get(FACILITY_EXPIRE_KEY_RETENTION_PERIOD).toString());
        // 例外施設設定
        JSONObject exception = jsonTargetTable.getJSONObject(FACILITY_EXPIRE_KEY_EXCEPTION);
        Iterator<String> keys = exception.keys();
        while(keys.hasNext()) {
          // 削除期間
          String key = keys.next();
          // 施設のリスト
          List<String> lstFacilities = new ArrayList<String>();
          JSONArray jsonFacilities = exception.getJSONArray(key);
          for (int i = 0; i < jsonFacilities.length(); i++) {
            lstFacilities.add(jsonFacilities.getString(i));
            defFacilities.remove(defFacilities.indexOf(jsonFacilities.getString(i)));
          }
          if (!"0".equals(key)) {
            Integer intKey = Integer.valueOf(key);
            // 削除期間が"0"の場合は削除対象外
            if (mapDelInfo.containsKey(intKey)) {
              List<String> tmpData = mapDelInfo.get(intKey);
              tmpData.addAll(lstFacilities);
              mapDelInfo.put(intKey, tmpData);
            } else {
              mapDelInfo.put(intKey, lstFacilities);
            }
          }
        }
        // 標準の削除期間で削除を行う施設リストを追加
        if (!Integer.valueOf(0).equals(retentionPeriod)) {
          // 削除期間が"0"の場合は削除対象外
          if (mapDelInfo.containsKey(retentionPeriod)) {
            List<String> tmpData = mapDelInfo.get(retentionPeriod);
            tmpData.addAll(defFacilities);
            mapDelInfo.put(retentionPeriod, tmpData);
          } else {
            mapDelInfo.put(retentionPeriod, defFacilities);
          }
        }

        for(Integer key : mapDelInfo.keySet()){
          Long criteriaTime = CalendarUtil.shiftMonth(baseDateLong, -key);
          subTransactionComponent.delete(dbClass, tableName, mapDelInfo.get(key), timeColumnName, criteriaTime);
        };
      }
    } catch (Exception e) {
      throw new NtssException(e);
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public void executeExpireFacility(LocalDateTime baseDate, LocalTime endTime, String facilityCd) {
    MstFacilityHash facility = mstFacilityHashDao.selectByFacilityCd(facilityCd);
    if (facility == null) {
      throw new NtssException("指定された施設のデータが存在しません: 施設コード：" + facilityCd);
    }

    // システム利用区分判別
    int mode = 1;
    if (SystemUseSettings.FNSI_ONLY.equals(facility.getSystemUseSetting())
      || SystemUseSettings.FNSI_REMS.equals(facility.getSystemUseSetting()) ) {
      mode = 2;
    }
    // 処理対象施設
    List<String> targetFacility = new ArrayList<String>();
    targetFacility.add(facilityCd);

    // 期間外データ削除処理呼び出し
    this.executeExpire(baseDate, endTime, mode, targetFacility);
  }
}
