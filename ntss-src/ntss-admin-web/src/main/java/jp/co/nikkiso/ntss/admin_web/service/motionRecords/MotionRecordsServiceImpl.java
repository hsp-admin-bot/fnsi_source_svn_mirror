package jp.co.nikkiso.ntss.admin_web.service.motionRecords;

import tools.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.MotionRecordsConstants;
import jp.co.nikkiso.ntss.admin_web.response.GatheringStatusResponse;
import jp.co.nikkiso.ntss.admin_web.response.MotionRecordsResponse;
import jp.co.nikkiso.ntss.admin_web.response.details.DabTestResultDetailResponse;
import jp.co.nikkiso.ntss.admin_web.response.details.DabTestResults;
import jp.co.nikkiso.ntss.admin_web.response.details.DialyzerTestResultDetailResponse;
import jp.co.nikkiso.ntss.admin_web.response.details.DialyzerTestResults;
import jp.co.nikkiso.ntss.admin_web.response.details.DissolutionDetailResponse;
import jp.co.nikkiso.ntss.admin_web.response.details.GatheringDetailResponse;
import jp.co.nikkiso.ntss.admin_web.response.details.MNoticeDetailResponse;
import jp.co.nikkiso.ntss.admin_web.response.details.MachineRecordDetailResponse;
import jp.co.nikkiso.ntss.admin_web.response.details.PreventiveDetailResponse;
import jp.co.nikkiso.ntss.admin_web.response.details.dto.BloodLeakageTestDto;
import jp.co.nikkiso.ntss.admin_web.response.details.dto.ConcentrationTestDto;
import jp.co.nikkiso.ntss.admin_web.response.details.dto.DialysateFlowRateTestDto;
import jp.co.nikkiso.ntss.admin_web.response.details.dto.DissolutionDto;
import jp.co.nikkiso.ntss.admin_web.response.details.dto.Dry50ADissolutionDto;
import jp.co.nikkiso.ntss.admin_web.response.details.dto.GatheringDetailDto;
import jp.co.nikkiso.ntss.admin_web.response.details.dto.HemodilutionDto;
import jp.co.nikkiso.ntss.admin_web.response.details.dto.PipingDto;
import jp.co.nikkiso.ntss.admin_web.response.details.dto.UfrcTestDto;
import jp.co.nikkiso.ntss.admin_web.response.details.graph.DabGraphResponse;
import jp.co.nikkiso.ntss.admin_web.response.details.graph.DissolutionGraphResponse;
import jp.co.nikkiso.ntss.admin_web.response.details.graph.MachineGraphResponse;
import jp.co.nikkiso.ntss.admin_web.response.details.graph.dab.DabGraph1;
import jp.co.nikkiso.ntss.admin_web.response.details.graph.dab.DabGraph2;
import jp.co.nikkiso.ntss.admin_web.response.details.graph.dab.DabGraph3;
import jp.co.nikkiso.ntss.admin_web.response.details.graph.dab.DabGraph4;
import jp.co.nikkiso.ntss.admin_web.response.details.graph.dissolution.DissolutionGraph1;
import jp.co.nikkiso.ntss.admin_web.response.details.graph.dissolution.DissolutionGraph2;
import jp.co.nikkiso.ntss.admin_web.response.details.graph.dissolution.DissolutionGraph3;
import jp.co.nikkiso.ntss.admin_web.response.details.graph.dissolution.DissolutionGraph4;
import jp.co.nikkiso.ntss.admin_web.response.details.graph.machine.MachineGraph1;
import jp.co.nikkiso.ntss.admin_web.response.details.graph.machine.MachineGraph2;
import jp.co.nikkiso.ntss.admin_web.response.details.graph.machine.MachineGraph3;
import jp.co.nikkiso.ntss.admin_web.response.details.graph.machine.MachineGraph4;
import jp.co.nikkiso.ntss.admin_web.response.details.graph.machine.MachineGraph5;
import jp.co.nikkiso.ntss.admin_web.response.details.model.BloodLeakageTestModel;
import jp.co.nikkiso.ntss.admin_web.response.details.model.ConcentrationTestModel;
import jp.co.nikkiso.ntss.admin_web.response.details.model.DialysateFlowRateTestModel;
import jp.co.nikkiso.ntss.admin_web.response.details.model.DissolutionModel;
import jp.co.nikkiso.ntss.admin_web.response.details.model.HemodilutionModel;
import jp.co.nikkiso.ntss.admin_web.response.details.model.PipingModel;
import jp.co.nikkiso.ntss.admin_web.response.details.model.UfrcTestModel;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.utils.DateTimeUtils;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.ComFormat;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.GatheringStatus;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.MotionRecordDataType;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.TestType;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MntGatheringManageDao;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.dao.MntMotionRecordDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.MntMotionRecord;
import jp.co.nikkiso.ntss.core.entity.custom.ComTypeAndFormatCd;
import jp.co.nikkiso.ntss.core.entity.custom.DissolutionDetail;
import jp.co.nikkiso.ntss.core.entity.custom.GatheringDetail;
import jp.co.nikkiso.ntss.core.entity.custom.MNoticeDetail;
import jp.co.nikkiso.ntss.core.entity.custom.MachineRecordDetail;
import jp.co.nikkiso.ntss.core.entity.custom.MotionRecord;
import jp.co.nikkiso.ntss.core.entity.custom.PreventiveDetail;
import jp.co.nikkiso.ntss.core.entity.custom.TestResultDetail;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.trigger.MntMotionTrigger;
import jp.co.nikkiso.ntss.core.trigger.OperateType;
import org.seasar.doma.jdbc.Config;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import jp.co.nikkiso.ntss.core.config.DefaultDb;

/**
 * 装置動作記録のService実装クラス.
 */
@Service
public class MotionRecordsServiceImpl implements MotionRecordsService {

  /**
   * 装置動作記録Dao.
   */
  @Autowired
  private MntMotionRecordDao mntMotionRecordDao;

  // add bug #5812 通信エラー解消後に対処済みにしても赤色のまま 修正 chen start
  @Autowired
  MntMachineStateDao mntMachineStateDao;
  // add bug #5812 通信エラー解消後に対処済みにしても赤色のまま 修正 chen end

  /**
   * 装置Dao.
   */
  @Autowired
  private MstMachineDao mstMachineDao;

  /**
   * データ収集管理Dao.
   */
  @Autowired
  private MntGatheringManageDao mntGatheringManageDao;

  /**
   * 利用者マスタ(個人情報DB)Dao
   */
  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;

  /**
   * ObjectMapper.
   */
  @Autowired
  private ObjectMapper mapper;

  /**
   * ロギングのServiceインタフェース.
   */
  @Autowired
  private LogService logService;

  //DB更新ログ出力ロジック wp start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Autowired
  private LogServiceCore logServiceCore;

  @Autowired
  @DefaultDb
  private Config defaultDbConfig;
  //DB更新ログ出力ロジック wp end 20210129

  // add 11042 nkknkk施設の遠隔監視の警報対処不正動作 関 start
  @Autowired
  MntMotionTrigger mntMotionTrigger;
  // add 11042 nkknkk施設の遠隔監視の警報対処不正動作 関 end

  /**
   * {@inheritDoc}
   */
  @Override
  public MotionRecordsResponse createMotionRecordsResponse(
      String facilityCd, String machineTypeCd, String machineSerial, String userTypeCd, String baseDate) {

    // 基準日以前の、データの存在する7日分の日付を取得
    List<String> targetDates = mntMotionRecordDao.selectEventRegDates(baseDate, facilityCd, machineTypeCd,
        machineSerial);
    int datesSize = targetDates.size();
    if (datesSize == 0) {
      // 基準日以前のデータが存在しない場合、空のレスポンスを返す]
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("There are nothing targetDates before baseDate. : " + baseDate);
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return new MotionRecordsResponse();
    }

    // 指定期間の開始日・終了日設定
    String toDate = targetDates.get(0);
    String fromDate = "";

    if (MotionRecordsConstants.PERIOD > datesSize) {
      // 日付リストが7日分より小さい場合、最後のインデックスを指定する
      fromDate = targetDates.get(datesSize - 1);
    } else {
      // 上記以外の場合、インデックスに6を指定
      fromDate = targetDates.get(MotionRecordsConstants.INDEX_FROM_DATE);
    }

    // 指定された期間の装置動作記録をすべて取得
    List<MotionRecord> recordsWithinPeriod = mntMotionRecordDao.selectByMachinesInfo(facilityCd, machineTypeCd,
        machineSerial, fromDate, toDate);

    // 期間開始日を基準日として設定
    baseDate = fromDate;
    // 対象期間内のデータが存在しない場合、基準日のみセットしたレスポンスを返す
    if (recordsWithinPeriod.isEmpty()) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("There are no records within period.");
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return new MotionRecordsResponse(baseDate);
    }

    // NKKユーザー以外の場合
    if (!CoreConstant.UserType.NIKKISO.equals(userTypeCd)) {
      // データ収集記録を除外する
      recordsWithinPeriod = filterMotionRecords(recordsWithinPeriod);
      // 除外後の装置記録リストが空になった場合、基準日のみをセットしたレスポンスを返す
      if (recordsWithinPeriod.isEmpty()) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("There are no records without data gathering");
        logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        return new MotionRecordsResponse(baseDate);
      }
    }

    // データ収集可否判断
    boolean isGatheringOk = false;
    int gatheringStatus = Optional.ofNullable(recordsWithinPeriod.get(0).getGatheringStatus()).orElse(0);
    // 最新の装置記録(リストの先頭)のデータ収集ステータスが依頼中もしくは処理中のとき、データ収集不可
    if (gatheringStatus != GatheringStatus.REQUESTING && gatheringStatus != GatheringStatus.IN_PROGRESS) {
      isGatheringOk = true;
    }

    return new MotionRecordsResponse(baseDate, recordsWithinPeriod, isGatheringOk);

  }

  /**
   * {@inheritDoc}
   */
  // createMotionRecordsResponseのオーバーロードメソッド
  @Override
  public MotionRecordsResponse createMotionRecordsResponse(
      String facilityCd, String machineTypeCd, String machineSerial, String userTypeCd, String fromDate, String toDate) {

    // 指定された期間の装置動作記録をすべて取得
    List<MotionRecord> recordsWithinPeriod = mntMotionRecordDao.selectByMachinesInfo(facilityCd, machineTypeCd,
        machineSerial, fromDate, toDate);

    // 期間開始日を基準日として設定
    String baseDate = fromDate;
    // 対象期間内のデータが存在しない場合、基準日のみセットしたレスポンスを返す
    if (recordsWithinPeriod.isEmpty()) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("There are no records within period.");
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return new MotionRecordsResponse(baseDate);
    }

    // NKKユーザー以外の場合
    if (!CoreConstant.UserType.NIKKISO.equals(userTypeCd)) {
      // データ収集記録を除外する
      recordsWithinPeriod = filterMotionRecords(recordsWithinPeriod);
      // 除外後の装置記録リストが空になった場合、基準日のみをセットしたレスポンスを返す
      if (recordsWithinPeriod.isEmpty()) {
    	  EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("There are no records without data gathering");
        logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        return new MotionRecordsResponse(baseDate);
      }
    }

    // データ収集可否判断
    boolean isGatheringOk = false;
    int gatheringStatus = Optional.ofNullable(recordsWithinPeriod.get(0).getGatheringStatus()).orElse(0);
    // 最新の装置記録(リストの先頭)のデータ収集ステータスが依頼中もしくは処理中のとき、データ収集不可
    if (gatheringStatus != GatheringStatus.REQUESTING && gatheringStatus != GatheringStatus.IN_PROGRESS) {
      isGatheringOk = true;
    }

    return new MotionRecordsResponse(baseDate, recordsWithinPeriod, isGatheringOk);

  }

  /**
   * {@inheritDoc}
   */
  // createMotionRecordsResponseのオーバーロードメソッド
  @Override
  public MotionRecordsResponse createMotionRecordsResponse(
      String facilityCd, String machineTypeCd, String machineSerial, String userTypeCd, String fromDate, String toDate,
      Integer limit, Integer offset) {

    // 期間開始日を基準日として設定
    String baseDate = fromDate;

    // 指定された期間の装置動作記録をすべて取得
    List<MotionRecord> recordsWithinPeriod = new ArrayList<MotionRecord>();

    if (!CoreConstant.UserType.NIKKISO.equals(userTypeCd)) {
      // NKKユーザー以外の場合
      recordsWithinPeriod = filterMotionRecords(
          mntMotionRecordDao.selectByMachinesInfoWithoutGatherinngLimitOffset(facilityCd, machineTypeCd,
              machineSerial, fromDate, toDate, limit, offset, new ArrayList<Integer>(), ""));
    } else {
      recordsWithinPeriod = mntMotionRecordDao.selectByMachinesInfoLimitOffset(facilityCd, machineTypeCd,
          machineSerial, fromDate, toDate, limit, offset, new ArrayList<Integer>(), "");
    }

    // 対象期間内のデータが存在しない場合、基準日のみセットしたレスポンスを返す
    if (recordsWithinPeriod.isEmpty()) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("There are no records within period.");
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return new MotionRecordsResponse(baseDate);
    }

    // データ収集可否判断
    boolean isGatheringOk = false;
    int gatheringStatus = Optional.ofNullable(recordsWithinPeriod.get(0).getGatheringStatus()).orElse(0);
    // 最新の装置記録(リストの先頭)のデータ収集ステータスが依頼中もしくは処理中のとき、データ収集不可
    if (gatheringStatus != GatheringStatus.REQUESTING && gatheringStatus != GatheringStatus.IN_PROGRESS) {
      isGatheringOk = true;
    }

    return new MotionRecordsResponse(baseDate, recordsWithinPeriod, isGatheringOk);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public MotionRecordsResponse createMotionRecordsResponseWithinPeriod(String facilityCd,
      String machineTypeCd, String machineSerial, String userTypeCd, String fromDate, String toDate) {

    // 指定された期間内の装置動作記録をすべて取得
    List<MotionRecord> recordsWithinPeriod = mntMotionRecordDao.selectByMachinesInfo(facilityCd, machineTypeCd,
        machineSerial, fromDate, toDate);

    // 対象データが存在しない場合、空のレスポンスを返す
    if (recordsWithinPeriod.isEmpty()) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("There are no records within period.");
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return new MotionRecordsResponse();
    }

    // ユーザ判定
    // TODO ユーザ種別定義
    if (!"1".equals(userTypeCd)) {
      recordsWithinPeriod = filterMotionRecords(recordsWithinPeriod);
    }
    return new MotionRecordsResponse(recordsWithinPeriod);

  }

  /**
   * {@inheritDoc}
   */
  @Override
  public MotionRecordsResponse createMotionRecordsResponseWithinPeriod(String facilityCd,
      String machineTypeCd, String machineSerial, String userTypeCd, String fromDate, String toDate, Integer limit, Integer offset, List<Integer> dataType,
      String freeWord) {

    List<MotionRecord> recordsWithinPeriod = new ArrayList<MotionRecord>();
    // 指定された期間内の装置動作記録をすべて取得
    if (!"1".equals(userTypeCd)) {
     recordsWithinPeriod = filterMotionRecords(
        mntMotionRecordDao.selectByMachinesInfoWithoutGatherinngLimitOffset(facilityCd, machineTypeCd,
      machineSerial, fromDate, toDate, limit, offset, dataType, freeWord)
      );
    } else {
      recordsWithinPeriod = mntMotionRecordDao.selectByMachinesInfoLimitOffset(facilityCd, machineTypeCd,
      machineSerial, fromDate, toDate, limit, offset, dataType, freeWord);
    }

    // 対象データが存在しない場合、空のレスポンスを返す
    if (recordsWithinPeriod.isEmpty()) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("There are no records within period.");
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return new MotionRecordsResponse();
    }

    return new MotionRecordsResponse(recordsWithinPeriod);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public Integer createMotionRecordsTotal(String facilityCd,
      String machineTypeCd, String machineSerial, String userTypeCd, String fromDate, String toDate,List<Integer> dataType, String freeWord) {
        String count = "0";
    // 指定された期間内の装置動作記録の件数を取得
    if (!"1".equals(userTypeCd)) {
      count = mntMotionRecordDao.countTotalMachinesInfoWithoutGatherinngLimitOffset(facilityCd, machineTypeCd, machineSerial, fromDate, toDate, dataType, freeWord);
    } else {
      count = mntMotionRecordDao.countTotalMachinesInfoLimitOffset(facilityCd, machineTypeCd, machineSerial, fromDate, toDate, dataType, freeWord);
    }

    return Integer.valueOf(count);
  }

  /**
   * 装置動作記録のうち、データ収集記録を除外.
   * <p>
   * NKKユーザ以外の場合、データ収集記録は表示させない
   * </p>
   *
   * @param allRecords DBから取得した装置動作記録リスト
   * @return 装置動作記録のリスト
   */
  private List<MotionRecord> filterMotionRecords(List<MotionRecord> allRecords) {

    List<MotionRecord> recordsWithoutGathering = new ArrayList<MotionRecord>();

    for (MotionRecord record : allRecords) {
      // データ種別:データ収集記録以外をリストに格納
      if (MotionRecordDataType.GATHERINNG != Optional.ofNullable(record.getDataType()).orElse(-1)) {
        if (record.getUserId() != null) {
          record.setUserName(mstPersonalUserDao.selectUserNameById(record.getUserId()));
        }
        recordsWithoutGathering.add(record);
      }
    }
    return recordsWithoutGathering;

  }

  /**
   * {@inheritDoc}
   */
  @Override
  public ResponseEntity<?> createDetailResponse(Long motionRecordNo, Integer dataType,
      String facilityCd, String machineTypeCd, String machineSerial, String baseDate, Integer offset) throws IOException {

    // ターゲットのデータがあるかをフィルタするため
    List<String> jsonAddressList;

    // データ種別に応じたレスポンスを生成して返す
    switch (dataType) {
      // 1.装置記録
      case MotionRecordDataType.MACHINE:
        MachineRecordDetail machineRecordDetail = mntMotionRecordDao.selectMachineRecordDetail(motionRecordNo);
        MachineRecordDetailResponse machineRecordDetailResponse = new MachineRecordDetailResponse();
        if (machineRecordDetail != null) {
          machineRecordDetailResponse.machineRecordDetail = machineRecordDetail;
        }
        return new ResponseEntity<>(machineRecordDetailResponse, HttpStatus.OK);

      // 2.緊急発報
      case MotionRecordDataType.M_NOTICE:
        MNoticeDetail mNoticeDetail = mntMotionRecordDao.selectMNoticeDetail(motionRecordNo);
        MNoticeDetailResponse mNoticeDetailResponse = new MNoticeDetailResponse();
        if (mNoticeDetail != null) {
          // 対処者名を設定.
          if (mNoticeDetail.getCorrectedUserId() != null) {
            mNoticeDetail.setUserName(mstPersonalUserDao.selectUserNameById(mNoticeDetail.getCorrectedUserId()));
          }
          // サービス対応者名を設定.
          if (mNoticeDetail.getServiceSupportUserId() != null) {
            mNoticeDetail.setServiceSupportUserName(mstPersonalUserDao.selectUserNameById(mNoticeDetail.getServiceSupportUserId()));
          }
          mNoticeDetailResponse.mNoticeDetail = mNoticeDetail;
        }
        return new ResponseEntity<>(mNoticeDetailResponse, HttpStatus.OK);

      // 3.予防保全/故障予知
      case MotionRecordDataType.PREVENTIVE:
        PreventiveDetail preventiveDetail = mntMotionRecordDao.selectPreventiveDetail(motionRecordNo);
        PreventiveDetailResponse preventiveDetailResponse = new PreventiveDetailResponse();
        if (preventiveDetail != null) {
          // 対処者名を設定.
          if (preventiveDetail.getCorrectedUserId() != null) {
            preventiveDetail.setUserName(mstPersonalUserDao.selectUserNameById(preventiveDetail.getCorrectedUserId()));
          }
          // サービス対象者名を設定.
          if (preventiveDetail.getServiceSupportUserId() != null) {
            preventiveDetail.setServiceSupportUserName(mstPersonalUserDao.selectUserNameById(preventiveDetail.getServiceSupportUserId()));
          }
          preventiveDetailResponse.preventiveDetail = preventiveDetail;
        }
        return new ResponseEntity<>(preventiveDetailResponse, HttpStatus.OK);

      // 4.自己診断
      case MotionRecordDataType.TEST_RESULT:
        // 装置の通信種別・通信フォーマットを取得
        ComTypeAndFormatCd comTypeAndFormatCd = mstMachineDao.selectComTypeAndFormatCd(facilityCd, machineTypeCd, machineSerial);
        if (comTypeAndFormatCd == null) {
          return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
        final int comType = Optional.ofNullable(comTypeAndFormatCd.getComType()).orElse(0);
        final String comFormatCd = Optional.ofNullable(comTypeAndFormatCd.getComFormatCd()).orElse("");
        if (comType == 0 || "".equals(comFormatCd)) {
          return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }

        // DABかどうか
        boolean isDab = (comType == 2 && ComFormat.DAB.equals(comFormatCd));

        // 選択日から過去30件分の自己診断結果記録を取得
        List<TestResultDetail> testResultDetails = new ArrayList<TestResultDetail>();
        int testType = 0;
        if (isDab) {
          // testType 5,6 分のデータを取得する
          testType = 5;
          for (int i = 0; i < 2; i++) {
            // フィルタ条件の設定
            jsonAddressList = new ArrayList<String>();
            if (testType == 5) {
              String[] strs = {"6", "7", "8", "9", "10", "11", "1", "5"};
              for (int j = 0; j < strs.length; j++) {
                jsonAddressList.add(strs[j]);
              }
            } else {
              String[] strs = {"6", "4", "5"};
              for (int j = 0; j < strs.length; j++) {
                jsonAddressList.add(strs[j]);
              }
            }
            testResultDetails.addAll(mntMotionRecordDao.selectTestResults(facilityCd, machineTypeCd,
                machineSerial, baseDate, testType, offset, MotionRecordsConstants.RECORD_CNT, jsonAddressList));
            testType++;
          }
          // 取得データが存在する場合、スキップ行数に30加算する
          if (testResultDetails.size() != 0) {
            offset += MotionRecordsConstants.RECORD_CNT;
          }

          DabTestResults dabTestResults = createDabTestResults(testResultDetails);
          DabTestResultDetailResponse response = new DabTestResultDetailResponse(baseDate, dabTestResults, offset);
          return new ResponseEntity<>(response, HttpStatus.OK);
        } else {
          // testType 1,2,3,4 分のデータを取得する
          testType = 1;
          for (int i = 0; i < 4; i++) {
            // フィルタ条件の設定
            jsonAddressList = new ArrayList<String>();
            if (testType == 1) {
              String[] strs = {"47", "43", "44", "45", "49", "48", "46"};
              for (int j = 0; j < strs.length; j++) {
                jsonAddressList.add(strs[j]);
              }
            } else if (testType == 2){
              String[] strs = {"53", "54"};
              for (int j = 0; j < strs.length; j++) {
                jsonAddressList.add(strs[j]);
              }
            } else if (testType == 3){
              String[] strs = {"58"};
              for (int j = 0; j < strs.length; j++) {
                jsonAddressList.add(strs[j]);
              }
            } else {
              String[] strs = {"65", "63", "64"};
              for (int j = 0; j < strs.length; j++) {
                jsonAddressList.add(strs[j]);
              }
            }
            testResultDetails.addAll(mntMotionRecordDao.selectTestResults(facilityCd, machineTypeCd,
                machineSerial, baseDate, testType, offset, MotionRecordsConstants.RECORD_CNT, jsonAddressList));
            testType++;
          }
          // 取得データが存在する場合、スキップ行数に30加算する
          if (testResultDetails.size() != 0) {
            offset += MotionRecordsConstants.RECORD_CNT;
          }

          DialyzerTestResults dialyzerTestResults = createDialyzerTestResults(testResultDetails);
          DialyzerTestResultDetailResponse response = new DialyzerTestResultDetailResponse(baseDate, dialyzerTestResults, offset);
          return new ResponseEntity<>(response, HttpStatus.OK);
        }

        // 5.溶解記録
      case MotionRecordDataType.DISSOLUTION:
        // フィルタ条件の設定
        jsonAddressList = new ArrayList<String>();
        String[] strs = {"5", "12", "13", "8", "9", "10", "11", "6", "7"};
        for (int j = 0; j < strs.length; j++) {
          jsonAddressList.add(strs[j]);
        }
        // 選択日から過去30件分の溶解記録を取得
        List<DissolutionDetail> dissolutionDetails = mntMotionRecordDao.selectDissolutions(facilityCd, machineTypeCd,
            machineSerial, "", baseDate, offset, MotionRecordsConstants.RECORD_CNT, false, jsonAddressList);
        // 取得データが存在する場合、スキップ行数に30加算する
        if (dissolutionDetails.size() != 0) {
          offset += MotionRecordsConstants.RECORD_CNT;
        }

        // 溶解記録のリスト生成
        List<DissolutionModel> dissolutions = new ArrayList<DissolutionModel>();
        for (DissolutionDetail detail : dissolutionDetails) {
          String regDate = detail.getEventRegDate();
          String regTime = detail.getEventRegTime();
          String data = detail.getDissolutionData();
          // 取得結果(JSON)がnullの場合、このループ内の処理をスキップ
          if (data == null) {
            continue;
          }
          // JSON → Javaオブジェクト
          DissolutionDto dissolutionDto = mapper.readValue(data, DissolutionDto.class);
          DissolutionModel dissolutionModel = new DissolutionModel(regDate, regTime, dissolutionDto);
          dissolutions.add(dissolutionModel);
        }

        // 溶解記録のResponse生成
        DissolutionDetailResponse dissolutionDetailResponse = new DissolutionDetailResponse(baseDate, dissolutions, offset);
        return new ResponseEntity<>(dissolutionDetailResponse, HttpStatus.OK);

      // 6.データ収集
      case MotionRecordDataType.GATHERINNG:
        GatheringDetail gatheringDetail = mntMotionRecordDao.selectGatheringDetail(motionRecordNo);
        GatheringDetailResponse gatheringDetailResponse = new GatheringDetailResponse();
        if (gatheringDetail != null && gatheringDetail.getFileData() != null) {
          // JSON → オブジェクト
          String gatheringDetailFileData = gatheringDetail.getFileData();
          GatheringDetailDto fileData = mapper.readValue(gatheringDetailFileData, GatheringDetailDto.class);
          gatheringDetailResponse.fileData = fileData;
          gatheringDetailResponse.machineRecordMessage = gatheringDetail.getMachineRecordMessage();
          gatheringDetailResponse.gatheringUserId = gatheringDetail.getGatheredUserId();
          gatheringDetailResponse.userName = mstPersonalUserDao.selectUserNameById(gatheringDetail.getGatheredUserId());
        }
        return new ResponseEntity<>(gatheringDetailResponse, HttpStatus.OK);

      // 上記以外
      default:
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("Requested data type is invalid.");
        logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        return new ResponseEntity<>(HttpStatus.OK);
    }

  }

  /**
   * 自己診断結果(透析装置)生成.
   * @param testResultDetails 過去2週間分の自己診断結果記録
   * @return 自己診断結果(透析装置)のResponse
   * @throws IOException
   */
  private DialyzerTestResults createDialyzerTestResults(List<TestResultDetail> testResultDetails) throws IOException {

    // 結果格納用List
    List<UfrcTestModel> ufrc = new ArrayList<UfrcTestModel>();
    List<BloodLeakageTestModel> bloodLeakage = new ArrayList<BloodLeakageTestModel>();
    List<DialysateFlowRateTestModel> dialysateFlowRate = new ArrayList<DialysateFlowRateTestModel>();
    List<ConcentrationTestModel> concentration = new ArrayList<ConcentrationTestModel>();

    for (TestResultDetail detail : testResultDetails) {
      String regDate = detail.getEventRegDate();
      String regTime = detail.getEventRegTime();
      String data = detail.getTestResultData();
//      add 7801【デグレ】自己診断結果の集計が不正_再発 関 start
      String recordNo = detail.getMotionRecordNo();
//      add 7801【デグレ】自己診断結果の集計が不正_再発 関 end
      int testType = Optional.ofNullable(detail.getTestType()).orElse(0);
      // 取得データ(JSON)がnullの場合、次のループにスキップ
      if (data == null) {
        continue;
      }
      switch (testType) {
        // 1.配管(UFRC)
        case TestType.UFRC:
          // JSON → Javaオブジェクト
          UfrcTestDto ufrcTestDto = mapper.readValue(data, UfrcTestDto.class);
//          mod 7801【デグレ】自己診断結果の集計が不正_再発 関 start
//          UfrcTestModel ufrcTestModel = new UfrcTestModel(regDate, regTime, ufrcTestDto);
          UfrcTestModel ufrcTestModel = new UfrcTestModel(regDate, regTime, ufrcTestDto, recordNo);
//          mod 7801【デグレ】自己診断結果の集計が不正_再発 関 end
          ufrc.add(ufrcTestModel);
          break;

        // 2.漏血
        case TestType.BLOOD_LEAKAGE:
          // JSON → Javaオブジェクト
          BloodLeakageTestDto bloodLeakageTestDto = mapper.readValue(data, BloodLeakageTestDto.class);
//          mod 7801【デグレ】自己診断結果の集計が不正_再発 関 start
//          BloodLeakageTestModel bloodLeakageTestModel = new BloodLeakageTestModel(regDate, regTime, bloodLeakageTestDto);
          BloodLeakageTestModel bloodLeakageTestModel = new BloodLeakageTestModel(regDate, regTime, bloodLeakageTestDto, recordNo);
//          mod 7801【デグレ】自己診断結果の集計が不正_再発 関 end
          bloodLeakage.add(bloodLeakageTestModel);
          break;

        // 3.透析液流量
        case TestType.DIALYSATE_FLOW_RATE:
          // JSON → Javaオブジェクト
          DialysateFlowRateTestDto dialysateFlowRateTestDto = mapper.readValue(data, DialysateFlowRateTestDto.class);
//          mod 7801【デグレ】自己診断結果の集計が不正_再発 関 start
//          DialysateFlowRateTestModel dialysateFlowRateTestModel = new DialysateFlowRateTestModel(regDate, regTime,
//            dialysateFlowRateTestDto);
          DialysateFlowRateTestModel dialysateFlowRateTestModel = new DialysateFlowRateTestModel(regDate, regTime,
              dialysateFlowRateTestDto, recordNo);
//          mod 7801【デグレ】自己診断結果の集計が不正_再発 関 end
          dialysateFlowRate.add(dialysateFlowRateTestModel);
          break;

        // 4.濃度
        case TestType.CONCENTRAITION:
          // JSON → Javaオブジェクト
          ConcentrationTestDto concentrationTestDto = mapper.readValue(data, ConcentrationTestDto.class);
//          mod 7801【デグレ】自己診断結果の集計が不正_再発 関 start
//          ConcentrationTestModel concentrationTestModel = new ConcentrationTestModel(regDate, regTime,
//            concentrationTestDto);
          ConcentrationTestModel concentrationTestModel = new ConcentrationTestModel(regDate, regTime,
              concentrationTestDto, recordNo);
//          mod 7801【デグレ】自己診断結果の集計が不正_再発 関 end
          concentration.add(concentrationTestModel);
          break;

        // 上記以外
        default:
          break;
      }

    }

    return new DialyzerTestResults(ufrc, bloodLeakage, dialysateFlowRate, concentration);
  }

  /**
   * 自己診断結果(DAB)生成.
   *
   * @param testResultDetails 過去2週間分の自己診断結果記録
   * @return 自己診断結果(DAB)のResponse
   * @throws IOException
   */
  private DabTestResults createDabTestResults(List<TestResultDetail> testResultDetails) throws IOException {

    // 結果格納用List
    List<PipingModel> piping = new ArrayList<PipingModel>();
    List<HemodilutionModel> hemodilution = new ArrayList<HemodilutionModel>();

    for (TestResultDetail detail : testResultDetails) {
      String regDate = detail.getEventRegDate();
      String regTime = detail.getEventRegTime();
      String data = detail.getTestResultData();
      int testType = Optional.ofNullable(detail.getTestType()).orElse(0);
      // 取得データ(JSON)がnullの場合、次のループにスキップ
      if (data == null) {
        continue;
      }
      // 自己診断種別で振り分け
      if (testType == TestType.PIPING_TEST) {
        // JSON → Javaオブジェクト
        PipingDto pipingDto = mapper.readValue(data, PipingDto.class);
        //mod 8306 【デグレ】自己診断結果の値が表示されない zhao start
        //PipingModel pipingModel = new PipingModel(regDate, regTime, pipingDto);
        PipingModel pipingModel = new PipingModel(regDate, regTime, pipingDto, detail.getMotionRecordNo());
        //mod 8306 【デグレ】自己診断結果の値が表示されない zhao end
        piping.add(pipingModel);

      } else {
        // JSON → Javaオブジェクト
        HemodilutionDto hemodilutionDto = mapper.readValue(data, HemodilutionDto.class);
        //mod 8306 【デグレ】自己診断結果の値が表示されない zhao start
        //HemodilutionModel hemodilutionModel = new HemodilutionModel(regDate, regTime, hemodilutionDto);
        HemodilutionModel hemodilutionModel = new HemodilutionModel(regDate, regTime, hemodilutionDto, detail.getMotionRecordNo());
        //mod 8306 【デグレ】自己診断結果の値が表示されない zhao end
        hemodilution.add(hemodilutionModel);

      }
    }
    return new DabTestResults(piping, hemodilution);

  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public boolean updateCorrection(String motionRecordNo, Long userId, String isCorrection) {
    // Dao処理結果が0の場合、更新失敗

    //DB更新ログ出力ロジック wp start

    String mmsTbN = "mnt_motion_record";

    // SQL検索条件
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(" motion_record_no = '" + motionRecordNo + "'" +"\n");
    // logCommon設定
    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(mmsTbN, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    //DB更新ログ出力ロジック wp end

    int result = mntMotionRecordDao.updateCorrection(Long.valueOf(motionRecordNo), userId, isCorrection);

    // add bug #5812 通信エラー解消後に対処済みにしても赤色のまま 修正 chen start
    if ("1".equals(isCorrection)) {
      MntMachineState mntMachineState = mntMachineStateDao.selectNoticeCntByRecordNo(Long.valueOf(motionRecordNo));
      if (mntMachineState != null) {
        Integer mNoticeCnt = mntMachineState.getMNoticeCnt();
        if (mNoticeCnt > 0) {
          mNoticeCnt = mNoticeCnt - 1;
        } else {
          mNoticeCnt = 0;
        }
        mntMachineStateDao.updateNoticeCnt(mntMachineState.getFacilityCd(), mntMachineState.getMachineTypeCd(), mntMachineState.getMachineSerial(), mNoticeCnt);
      }
    }
    // add bug #5812 通信エラー解消後に対処済みにしても赤色のまま 修正 chen end
    // add #8640 「【デグレ】警報を対処済にしてもバックカラーが赤いまま」について、対応する。 dengshen start
    else if ("0".equals(isCorrection)){
      MntMachineState mntMachineState = mntMachineStateDao.selectNoticeCntByRecordNo(Long.valueOf(motionRecordNo));
      if (mntMachineState != null) {
        Integer mNoticeCnt = mntMachineState.getMNoticeCnt() + 1;
        mntMachineStateDao.updateNoticeCnt(mntMachineState.getFacilityCd(), mntMachineState.getMachineTypeCd(), mntMachineState.getMachineSerial(), mNoticeCnt);
      }
    }
    // add #8640 「【デグレ】警報を対処済にしてもバックカラーが赤いまま」について、対応する。 dengshen end

    //FNSI-修正 ログ対応 wp add start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && result > 0) {
      logCommon.updateLog();
    }
    //FNSI-修正 ログ対応 wp add end 20210129

    if (result != 0) {
      return true;
    }


    return false;

  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public boolean updateAllTargetCorrectinos(String facilityCd, String machineTypeCd, String machineSerial,
      Long userId, Integer dataType) {

    // データ種別が 2.緊急発報記録 または 3.予防保全/故障予知 以外の場合、falseを返す
    if (MotionRecordDataType.M_NOTICE != dataType && MotionRecordDataType.PREVENTIVE != dataType) {
      return false;
    }
    // Dao処理

    //FNSI-修正 ログ対応 wp add start
    String mmsTbN = "mnt_motion_record";

    // SQL検索条件
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(" facility_cd = '" + facilityCd + "'" +"\n");
    wheres.append(" AND\n");
    wheres.append(" machine_type_cd = '" + machineTypeCd + "'" +"\n");
    wheres.append(" AND\n");
    wheres.append(" trim(machine_serial) = trim('" + machineSerial  + "')" +"\n");
    wheres.append(" AND\n");
    wheres.append(" is_correction in ('0','2') \n");
    wheres.append(" AND\n");
    wheres.append(" data_type = " + dataType  + "\n");
    DataUpdateLogCommonNew logCommon = getLogCommon(mmsTbN, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    //FNSI-修正 ログ対応 wp add end

    int ret = mntMotionRecordDao.updateAllCorrections(facilityCd, machineTypeCd, machineSerial, userId, dataType);
    // add bug #5812 通信エラー解消後に対処済みにしても赤色のまま 修正 chen start
    mntMachineStateDao.updateClearNoticeCnt(facilityCd, machineTypeCd, machineSerial);
    // add bug #5812 通信エラー解消後に対処済みにしても赤色のまま 修正 chen end
    //FNSI-修正 ログ対応 wp add start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && ret > 0) {
      logCommon.updateLog();
    }
    //FNSI-修正 ログ対応 wp add end 20210129

    return true;
  }

  //FNSI-修正 ログ対応 wp add start
  /**


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

  //FNSI-修正 ログ対応 wp add end

  /**
   * {@inheritDoc}
   */
  @Override
  public MachineGraphResponse createMachineGraphResponse(
      String facilityCd, String machineTypeCd, String machineSerial, String baseDate, String weeks) throws IOException {

    // 基準日から指定週分の日付を取得
    String fromDate = DateTimeUtils.getPastDateWithWeeks(baseDate, Integer.valueOf(weeks));
    // 期間内の自己診断記録取得
    List<TestResultDetail> details = mntMotionRecordDao.selectAllTestResults(facilityCd, machineTypeCd, machineSerial,
        fromDate, baseDate);
//    add 7801【デグレ】自己診断結果の集計が不正_再発 関 start
    // 期間内の自己診断記録取得
    List<TestResultDetail> detailList = mntMotionRecordDao.selectAllTestResultsSelf(facilityCd, machineTypeCd, machineSerial,
      fromDate, baseDate);
//    add 7801【デグレ】自己診断結果の集計が不正_再発 関 end
    // 5グラフ分のデータ格納用List
    List<MachineGraph1> graph1s = new ArrayList<MachineGraph1>();
    List<MachineGraph2> graph2s = new ArrayList<MachineGraph2>();
    List<MachineGraph3> graph3s = new ArrayList<MachineGraph3>();
    List<MachineGraph4> graph4s = new ArrayList<MachineGraph4>();
    List<MachineGraph5> graph5s = new ArrayList<MachineGraph5>();

    // 自己診断種別ごとに処理振り分け
    for (TestResultDetail detail : details) {
      int testType = Optional.ofNullable(detail.getTestType()).orElse(-1);
      String eventRegDate = Optional.ofNullable(detail.getEventRegDate()).orElse("");
      String eventRegTime = Optional.ofNullable(detail.getEventRegTime()).orElse("");
      String data = detail.getTestResultData();
      // 取得結果(JSON)がnullの場合、このループ内の処理をスキップ
      if (data == null) {
        continue;
      }
      switch (testType) {
        // 1.配管(UFRC)
        case TestType.UFRC:
          // JSON → Javaオブジェクト
          UfrcTestDto ufrc = mapper.readValue(data, UfrcTestDto.class);
          // グラフ1、  グラフ2設定
          MachineGraph1 graph1 = new MachineGraph1(eventRegDate, eventRegTime, ufrc.getNegativePipeLeakage(),
              ufrc.getPositivePipeLeakage(),
              ufrc.getCfLeakage(), ufrc.getCf2Leakage());
          graph1s.add(graph1);
          MachineGraph2 graph2 = new MachineGraph2(eventRegDate, eventRegTime, ufrc.getRemoval(), ufrc.getBalance());
          graph2s.add(graph2);
          break;

        // 2.漏血
        case TestType.BLOOD_LEAKAGE:
          // JSON → Javaオブジェクト
          BloodLeakageTestDto bloodLeakage = mapper.readValue(data, BloodLeakageTestDto.class);
          // グラフ3設定
          MachineGraph3 graph3 = new MachineGraph3(eventRegDate, eventRegTime, bloodLeakage.getVoltageRed(),
              bloodLeakage.getVoltageGreen());
          graph3s.add(graph3);
          break;

        // 3.透析液流量
        case TestType.DIALYSATE_FLOW_RATE:
          // JSON → Javaオブジェクト
          DialysateFlowRateTestDto dialysateFlowRate = mapper.readValue(data, DialysateFlowRateTestDto.class);
          // グラフ4設定
          MachineGraph4 graph4 = new MachineGraph4(eventRegDate, eventRegTime, dialysateFlowRate.getDialysateFlowRate());
          graph4s.add(graph4);
          break;

        // 4.濃度
        case TestType.CONCENTRAITION:
          // JSON → Javaオブジェクト
          ConcentrationTestDto concentration = mapper.readValue(data, ConcentrationTestDto.class);
          // グラフ5設定
          MachineGraph5 graph5 = new MachineGraph5(eventRegDate, eventRegTime, concentration.getDialysateB(),
              concentration.getDialysateA());
          graph5s.add(graph5);
          break;

        // 上記以外
        default:
          break;
      }

    }
    // 基準日を新たに設定
    baseDate = DateTimeUtils.getPastDateWithDays(fromDate, 1);
    // レスポンスに値を詰めて返却
//    mod 7801【デグレ】自己診断結果の集計が不正_再発 関 start
//    return new MachineGraphResponse(baseDate, graph1s, graph2s, graph3s, graph4s, graph5s);
    return new MachineGraphResponse(baseDate, graph1s, graph2s, graph3s, graph4s, graph5s, detailList);
//    mod 7801【デグレ】自己診断結果の集計が不正_再発 関 end
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public DabGraphResponse createDabGraphResponse(
      String facilityCd, String machineTypeCd, String machineSerial, String baseDate, String weeks) throws IOException {

    // 基準日から指定週分の日付を取得
    String fromDate = DateTimeUtils.getPastDateWithWeeks(baseDate, Integer.valueOf(weeks));
    // 期間内の自己診断記録取得
    List<TestResultDetail> details = mntMotionRecordDao.selectAllTestResults(facilityCd, machineTypeCd, machineSerial,
        fromDate, baseDate);
//    add 7801【デグレ】自己診断結果の集計が不正_再発 関 start
    // 期間内の自己診断記録取得
    List<TestResultDetail> detailList = mntMotionRecordDao.selectAllTestResultsSelf(facilityCd, machineTypeCd, machineSerial,
      fromDate, baseDate);
//    add 7801【デグレ】自己診断結果の集計が不正_再発 関 end
    ObjectMapper mapper = new ObjectMapper();

    // 4グラフ分のデータ格納用List
    List<DabGraph1> graph1s = new ArrayList<DabGraph1>();
    List<DabGraph2> graph2s = new ArrayList<DabGraph2>();
    List<DabGraph3> graph3s = new ArrayList<DabGraph3>();
    List<DabGraph4> graph4s = new ArrayList<DabGraph4>();

    // 配管テスト/希釈テストで処理振り分け
    for (TestResultDetail detail : details) {
      int testType = Optional.ofNullable(detail.getTestType()).orElse(-1);
      String eventRegDate = Optional.ofNullable(detail.getEventRegDate()).orElse("");
      String eventRegTime = Optional.ofNullable(detail.getEventRegTime()).orElse("");

      // 配管テスト
      if (TestType.PIPING_TEST == testType) {
        // JSON → Javaオブジェクト
        PipingDto piping = mapper.readValue(detail.getTestResultData(), PipingDto.class);
        // グラフ1、グラフ2、グラフ3設定
        DabGraph1 graph1 = new DabGraph1(eventRegDate, eventRegTime, piping.getSupplyPressure(),
            piping.getDialysateFlowPressureLow(),
            piping.getDialysateFlowPressureHigh());
        graph1s.add(graph1);
        DabGraph2 graph2 = new DabGraph2(eventRegDate, eventRegTime, piping.getConcentrationCell3(),
            piping.getConcentrationCell4());
        graph2s.add(graph2);
        DabGraph3 graph3 = new DabGraph3(eventRegDate, eventRegTime, piping.getJudgementTermInjection(),
            piping.getJudgementTermDrainage());
        graph3s.add(graph3);

        // 希釈テスト
      } else if (TestType.HEMODILUTION_TEST == testType) {
        // JSON → Javaオブジェクト
        HemodilutionDto hemodilution = mapper.readValue(detail.getTestResultData(), HemodilutionDto.class);
        // グラフ4設定
        DabGraph4 graph4 = new DabGraph4(eventRegDate, eventRegTime, hemodilution.getConcentrationB(),
            hemodilution.getConcentrationDialysate());
        graph4s.add(graph4);
      }

    }
    // 基準日を新たに設定
    baseDate = DateTimeUtils.getPastDateWithDays(fromDate, 1);
    // レスポンスに値を詰めて返却
//    mod 7801【デグレ】自己診断結果の集計が不正_再発 関 start
//    return new DabGraphResponse(baseDate, graph1s, graph2s, graph3s, graph4s);
    return new DabGraphResponse(baseDate, graph1s, graph2s, graph3s, graph4s, detailList);
//    mod 7801【デグレ】自己診断結果の集計が不正_再発 関 end
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public DissolutionGraphResponse createDissolutionGraphResponse(
      String facilityCd, String machineTypeCd, String machineSerial, String baseDate, String weeks) throws IOException {

    // 基準日から指定週分の日付を取得
    String fromDate = DateTimeUtils.getPastDateWithWeeks(baseDate, Integer.valueOf(weeks));
    // 期間内の自己診断記録取得
    List<DissolutionDetail> details = mntMotionRecordDao.selectDissolutions(facilityCd, machineTypeCd, machineSerial,
        fromDate, baseDate, 0, 0, true, new ArrayList<String>());

    // 4グラフ分のデータ格納用List
    List<DissolutionGraph1> graph1s = new ArrayList<DissolutionGraph1>();
    List<DissolutionGraph2> graph2s = new ArrayList<DissolutionGraph2>();
    List<DissolutionGraph3> graph3s = new ArrayList<DissolutionGraph3>();
    List<DissolutionGraph4> graph4s = new ArrayList<DissolutionGraph4>();

    for (DissolutionDetail detail : details) {
      String eventRegDate = Optional.ofNullable(detail.getEventRegDate()).orElse("");
      String eventRegTime = Optional.ofNullable(detail.getEventRegTime()).orElse("");

      // JSON → Javaオブジェクト
      DissolutionDto dissolution = mapper.readValue(detail.getDissolutionData(), DissolutionDto.class);
      Dry50ADissolutionDto dry50Adissolution = mapper.readValue(detail.getDissolutionData(), Dry50ADissolutionDto.class);
      // グラフ1、グラフ2、グラフ3、グラフ4設定
      DissolutionGraph1 graph1 = new DissolutionGraph1(eventRegDate, eventRegTime, dissolution.getConcentrationB(),
          dissolution.getConcentrationA());
      graph1s.add(graph1);
      DissolutionGraph2 graph2 = new DissolutionGraph2(eventRegDate, eventRegTime, dissolution.getTemperatureB(),
          dissolution.getTemperatureA());
      graph2s.add(graph2);
      DissolutionGraph3 graph3 = new DissolutionGraph3(eventRegDate, eventRegTime, dissolution.getDissolutionTimeB(),
          dissolution.getDissolutionTimeA());
      graph3s.add(graph3);
      DissolutionGraph4 graph4 = new DissolutionGraph4(eventRegDate, eventRegTime, dry50Adissolution.getConcentration(),
          dry50Adissolution.getTemperature());
      graph4s.add(graph4);

    }
    // 基準日を新たに設定
    baseDate = DateTimeUtils.getPastDateWithDays(fromDate, 1);
    // レスポンスに値を詰めて返却
    return new DissolutionGraphResponse(baseDate, graph1s, graph2s, graph3s, graph4s);

  }

  /**
   * {@inheritDoc}
   */
  @Override
  public GatheringStatusResponse getGatheringStatus(Long userId, String facilityCd) {

    // システム日付を取得
    String sysDate = DateTimeUtils.getSysDate();

    // データ収集ステータスを取得
    Integer gatheringStatus = mntGatheringManageDao.selectByUserIdAndFacilityCdAndDate(userId, facilityCd, sysDate);

    // レスポンスに値を詰めて返却
    return new GatheringStatusResponse(gatheringStatus);

  }

  /**
   * {@inheritDoc}
   */
  @Override
  public boolean updateServiceSupport(Long motionRecordNo, String serviceSupportType, Long serviceSupportUserId) {
    // エンティティに引数を設定する.
    MntMotionRecord mntMotionRecord = new MntMotionRecord(){{
      setMotionRecordNo(motionRecordNo);
      setServiceSupportType(serviceSupportType);
      setServiceSupportUserId(serviceSupportUserId);
    }};

    //FNSI-修正 ログ対応 wp add start

    String mmsTbN = "mnt_motion_record";

    // SQL検索条件
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(" motion_record_no = '" + motionRecordNo + "'" +"\n");
    // logCommon設定
    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(mmsTbN, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    //FNSI-修正 ログ対応 wp add end

    int result = mntMotionRecordDao.updateServiceSupport(mntMotionRecord);

    // add 11042 nkknkk施設の遠隔監視の警報対処不正動作 関 start
    MntMotionRecord mntMotionRecordAfter = mntMotionRecordDao.selectAllByMotionRecordNo(motionRecordNo);

    if (mntMotionRecordAfter != null) {
      mntMotionTrigger.triggerMntMotionRecord(mntMotionRecordAfter, OperateType.UPDATE);
    }
    // add 11042 nkknkk施設の遠隔監視の警報対処不正動作 関 end

    //FNSI-修正 ログ対応 wp add start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && result > 0) {
      logCommon.updateLog();
    }
    //FNSI-修正 ログ対応 wp add end 20210129
    return result != 0;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  // mod 11042 nkknkk施設の遠隔監視の警報対処不正動作 関 start
  // public boolean updateAllServiceSupport(String facilityCd, String machineTypeCd, String machineSerial, Long serviceSupportUserId) {
  public boolean updateAllServiceSupport(String facilityCd, String machineTypeCd, String machineSerial, Long serviceSupportUserId, Integer dataType) {
    // mod 11042 nkknkk施設の遠隔監視の警報対処不正動作 関 end
    // エンティティに引数を設定する.
    MntMotionRecord mntMotionRecord = new MntMotionRecord(){{
      setFacilityCd(facilityCd);
      setMachineTypeCd(machineTypeCd);
      setMachineSerial(machineSerial);
      setServiceSupportUserId(serviceSupportUserId);
      // add 11042 nkknkk施設の遠隔監視の警報対処不正動作 関 start
      setDataType(dataType);
      // add 11042 nkknkk施設の遠隔監視の警報対処不正動作 関 end
    }};

    //FNSI-修正 ログ対応 wp add start

    String mmsTbN = "mnt_machine_state";
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(" facility_cd = '" + facilityCd + "'" +"\n");
    wheres.append(" AND\n");
    wheres.append(" machine_type_cd = '" + machineTypeCd + "'" +"\n");
    wheres.append(" AND\n");
    wheres.append(" trim(machine_serial) = trim('" + machineSerial  + "')" +"\n");
    wheres.append(" AND\n");
    wheres.append(" is_correction in ('0','2') \n");
    wheres.append(" AND\n");
    wheres.append(" data_type in ('2') \n");
    DataUpdateLogCommonNew logCommon = getLogCommon(mmsTbN, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    //FNSI-修正 ログ対応 wp add end

    int result = mntMotionRecordDao.updateServiceSupportAll(mntMotionRecord);

    // add 11042 nkknkk施設の遠隔監視の警報対処不正動作 関 start
    if (result > 0) {
      mntMotionTrigger.triggerMntMotionRecord(mntMotionRecord, OperateType.UPDATE);
    }
    // add 11042 nkknkk施設の遠隔監視の警報対処不正動作 関 end

    //FNSI-修正 ログ対応 wp add start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && result > 0) {
      logCommon.updateLog();
    }
    //FNSI-修正 ログ対応 wp add end 20210129


    return result != 0;
  }

  @Override
  public MntMotionRecord findByMachineAndMotionRecordNo(
      String facilityCd,
      String machineTypeCd,
      String machineSerial,
      Long motionRecordNo) {
    return mntMotionRecordDao.selectByMachineAndMotionRecordNo(facilityCd, machineTypeCd, machineSerial, motionRecordNo);
  }

  /** add by SunZelin  2023-02-01 [CodeOptimization]  start */
  @Override
  public ResponseEntity<?> getGraphData(String facilityCd, String machineTypeCd, String machineSerial, String testType, String baseDate, String weeks,EventLogMessage eventLogMessage) throws IOException {
    // 自己診断種別に応じたレスポンス生成
    switch (Integer.valueOf(testType)) {

      // 透析装置自己診断
      case TestType.UFRC:
      case TestType.BLOOD_LEAKAGE:
      case TestType.DIALYSATE_FLOW_RATE:
      case TestType.CONCENTRAITION:
        MachineGraphResponse machineGraphResponse = createMachineGraphResponse(facilityCd, machineTypeCd, machineSerial, baseDate, weeks);
        return new ResponseEntity<>(machineGraphResponse, HttpStatus.OK);

      // DAB自己診断
      case TestType.PIPING_TEST:
      case TestType.HEMODILUTION_TEST:
        DabGraphResponse dabGraphResponse = createDabGraphResponse(facilityCd, machineTypeCd,
          machineSerial, baseDate, weeks);
        return new ResponseEntity<>(dabGraphResponse, HttpStatus.OK);

      default:
        // ログ出力
        eventLogMessage.setLogMessage("REST request is BAD_REQUEST");
        logService.log(LogLevel.DEBUG, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_DETAIL, SERVICE_NAME.FNSI,
          null);
        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  /** add by SunZelin  2023-02-01 [CodeOptimization]  end */

}
