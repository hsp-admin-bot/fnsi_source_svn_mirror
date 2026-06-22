package jp.co.nikkiso.ntss.admin_web.service.treatmentRecord;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordResult;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.core.dao.TreatmentRecordDao;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordMonitor;
import lombok.extern.slf4j.Slf4j;

/**
 * 治療記録画面（モニタ機能）のService実装クラス.
 */
@Service
@Slf4j
public class TreatmentRecordMonitorServiceImpl implements TreatmentRecordMonitorService {

  /**
   * 治療情報のDaoインタフェース.
   */
  @Autowired
  private TreatmentRecordDao recordDao;

  /**
   * {@link OrdMainDao}のDaoインタフェース
   */
  @Autowired
  private OrdMainDao ordMainDao;

  /**
   * {@link MstPersonalUserDao}のDaoインタフェース
   */
  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;

  /**
 	* ロギングのServiceインタフェース.
  */
  @Autowired
  private LogService logService;

  /**
   * {@inheritDoc}
   */
  @Override
  public List<TreatmentRecordMonitor> getTreatmentRecordMonitors(Long ordNo) {
    try {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("治療記録(モニタ)：データ取得 開始：オーダ番号:[" + ordNo + "]");
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // 透析開始日時を取得し、秒の値を0に置き換えた値を取得する
      TreatmentRecordResult treatmentRecordResult = recordDao.selectTreatmentRecordResultByOrdNo(ordNo);
      // オーダ番号に該当するオーダが存在しないまたは、治療開始日時が未設定（null）の場合
      // if (treatmentRecordResult == null || treatmentRecordResult.getRstStartDate() == null) {
      if (treatmentRecordResult == null) {

        eventLogMessage.setLogMessage("治療記録(モニタ)：オーダ番号に該当する情報なし:オーダ番号:[" + ordNo + "]");
        logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        // 透析開始日時が入っていなかった場合、空のリストを返す(エラー扱いとはしない)
        return Collections.emptyList();
      }

      // モニタデータを取得する
      List<TreatmentRecordMonitor> rawMonitors = recordDao.selectTreatmentRecordMonitors(ordNo);
      eventLogMessage.setLogMessage("治療記録(モニタ)：データ取得件数:[" + rawMonitors.size() +"]");
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      if (rawMonitors.isEmpty()) {
        return Collections.emptyList();
      }

      // 治療開始日時を取得する
      Timestamp rstStartDate =  null;
      // 治療開始日時が未設定の場合、モニタデータの発生日時が最古の日時を基準とする.
      if (treatmentRecordResult.getRstStartDate() == null) {
        rstStartDate = rawMonitors.get(0).getOccurDate();

        eventLogMessage.setLogMessage("治療記録(モニタ):治療開始日時設定なし");
        logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      } else {
        rstStartDate = treatmentRecordResult.getRstStartDate();
      }
      eventLogMessage.setLogMessage("治療記録(モニタ):データ取得基準日:[" + rstStartDate +"]");
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // モニタデータと手入力(画面からの修正も含む)を振り分ける
      List<TreatmentRecordMonitor> manualMonitorData =
        rawMonitors.stream().filter(m -> m.getUpdStaffId() != null).collect( Collectors.toList());

      eventLogMessage.setLogMessage("治療記録(モニタ):手入力(手修正を含む)のモニタデータ件数:[" + manualMonitorData.size() +"]");
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);

      List<TreatmentRecordMonitor> machineMonitorData =
        rawMonitors.stream().filter(m -> m.getUpdStaffId() == null).collect(Collectors.toList());

      eventLogMessage.setLogMessage("治療記録(モニタ):透析装置からのモニタデータ件数:[" +  machineMonitorData.size() + "]");
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);

      // 秒の値を0に置き換える
      LocalDateTime startDate = rstStartDate.toLocalDateTime().withSecond(0);

      //mod FNSI-redmine6161 fang start
      List<TreatmentRecordMonitor> monitors = new ArrayList<>();
      if (!machineMonitorData.isEmpty()) {
        for (TreatmentRecordMonitor monitor : machineMonitorData) {
          if (monitor != null) {
            monitors.add(monitor);
          }
        }

//        LocalDateTime maxOccurDate = machineMonitorData
//          .stream()
//          .map(e -> e.getOccurDate())
//          .max(Timestamp::compareTo)
//          .get()
//          .toLocalDateTime()
//          .plusMinutes(15);
//
//        // 基準日時を元に15分間隔でモニタデータを間引く
//        for (LocalDateTime currentTime = startDate; !currentTime.isAfter(maxOccurDate); currentTime = currentTime.plusMinutes(15L)) {
//          final LocalDateTime baseTime = currentTime;
//          Optional<TreatmentRecordMonitor> monitor = machineMonitorData
//            .stream()
//            .filter(e -> e.getOccurDateAsLocalDateTime().withSecond(0).compareTo(baseTime) <= 0)
//            .max(Comparator.comparing(TreatmentRecordMonitor::getOccurDateAsLocalDateTime));
//          if (monitor.isPresent()) {
//            monitors.add(monitor.get());
//          }
//        }
      }
      //mod FNSI-redmine6161 fang end

      // 手入力(手修正)されたデータ
      // 利用者名を設定
      manualMonitorData.stream().forEach(m ->{
        Long userId = m.getUpdStaffId();
        // 利用者情報（個人情報DB）取得
        MstPersonalUser mstPersonalUser = this.mstPersonalUserDao.selectById(userId);
        if (mstPersonalUser == null) {

          eventLogMessage.setLogMessage("治療記録(モニタ):利用者情報を取得失敗：利用者ID:["+ userId +"]");
          logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          return;
        }
        // 利用者情報（個人情報DB）取得
        m.setUserLastName(mstPersonalUser.getUserLastName());
        m.setUserFirstName(mstPersonalUser.getUserFirstName());
      });

      // マージ及び発生日時でソート
      List<TreatmentRecordMonitor> result =
        Stream.concat(monitors.stream().distinct(), manualMonitorData.stream())
          .sorted(Comparator.comparing(TreatmentRecordMonitor::getOccurDate))
          .collect(Collectors.toList());
      eventLogMessage.setLogMessage("治療記録(モニタ)：データ取得 終了：件数:[" + result.size() + "]");
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return result;
    } catch (EmptyResultDataAccessException e) {
      // 透析開始日時が取得できなかった場合、空のリストを返す(エラー扱いとはしない)
      return Collections.emptyList();
    }
  }
}
