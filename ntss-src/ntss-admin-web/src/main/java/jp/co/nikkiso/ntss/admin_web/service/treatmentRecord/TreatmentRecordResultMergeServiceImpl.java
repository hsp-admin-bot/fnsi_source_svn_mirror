package jp.co.nikkiso.ntss.admin_web.service.treatmentRecord;

// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import tools.jackson.core.JacksonException;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import tools.jackson.core.type.TypeReference;
import tools.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.request.deviceEdgeOrder.DeviceEdgeOrderRequest;
import jp.co.nikkiso.ntss.admin_web.response.checkList.dto.ReceiveRstEquipInfoDto;
import jp.co.nikkiso.ntss.admin_web.response.checkList.dto.ReceiveRstMediInfoDto;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.OrdMainService;
import jp.co.nikkiso.ntss.admin_web.service.SelectHistoryUtils;
import jp.co.nikkiso.ntss.admin_web.service.deviceEdgeOrder.DeviceEdgeOrderService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.nextpat.NextPatService;
import jp.co.nikkiso.ntss.admin_web.service.statusList.TreatmentStatusListService;
import jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.enums.DetermineMergeStatusEnum;
import jp.co.nikkiso.ntss.admin_web.service.webSocketNotify.PayloadBuilder;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallCommonUtil;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MniMonitorDao;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.dao.MntMotionRecordDao;
import jp.co.nikkiso.ntss.core.dao.MstBedDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.dao.OrdChecklistDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.OrdTreatConditionDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.TreatmentRecordDao;
import jp.co.nikkiso.ntss.core.entity.MedicineLatestNo;
import jp.co.nikkiso.ntss.core.entity.MniMonitor;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.MntMotionRecord;
import jp.co.nikkiso.ntss.core.entity.MstBed;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordResultMerge;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.service.ordMaterialSaveService.OrdMaterialSaveService;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.seasar.doma.jdbc.Config;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import org.springframework.aop.framework.AopProxyUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.CollectionUtils;
import org.springframework.web.client.RestTemplate;

import java.net.URI;
import java.net.URISyntaxException;
import java.sql.Timestamp;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.toJson;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
import jp.co.nikkiso.ntss.core.config.DefaultDb;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end

/**
 * 治療記録（実績マージ）画面のService実装クラス.
 */
@Service
@Slf4j
public class TreatmentRecordResultMergeServiceImpl implements TreatmentRecordResultMergeService {

  /**
   * 治療情報のDaoインタフェース.
   */
  @Autowired
  private TreatmentRecordDao recordDao;

  /**
   * 患者基本情報のDaoインタフェース.
   */
  @Autowired
  private PatPersonalMainDao patPersonalDao;

  /**
   * {@link MniMonitorDao}
   */
  @Autowired
  private MniMonitorDao mniMonitorDao;

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

  //add FNSI修正486改修 房 start
  @Autowired
  OrdMainDao ordMainDao;

  @Autowired
  private MstMachineDao mstMachineDao;

  @Autowired
  MntMachineStateDao mntMachineStateDao;

  @Autowired
  DeviceEdgeOrderService deviceEdgeOrderService;

  @Autowired
  TreatmentRecordDeleteService treatmentRecordDeleteService;

  @Autowired
  OrdChecklistDao ordChecklistDao;

  @Autowired
  MntMotionRecordDao mntMotionRecordDao;

  @Autowired
  OrdTreatConditionDao ordTreatConditionDao;

  @Autowired
  MstBedDao mstBedDao;

  @Value("${ntss.admin-web.device-edge.url}")
  private String deviceEdgeUrl;
  //add FNSI修正486改修 房 end

  //add FNSI-投薬最新識別番号の設定 房 start
  @Autowired
  private OrdMainService ordMainService;
  //add FNSI-投薬最新識別番号の設定 房 end
  //add FNSI-redmine fang start
  @Autowired
  private TreatmentStatusListService treatmentStatusListService;
  //add FNSI-redmine fang end
  // add FNSI-redmine6060 fang start
  @Autowired
  private WebApiCallCommonUtil webApiCallCommonUtil;
  // add FNSI-redmine6060 fang end
  //add #10196 Ord_Material_Save code implementation 20240131 ztc start
  @Autowired
  private OrdMaterialSaveService ordMaterialSaveService;
  //add #10196 Ord_Material_Save code implementation 20240131 ztc end

  // add #10344 merge treatment record rebuild Start
  @Autowired
  private NextPatService nextPatService;

  @Autowired
  @DefaultDb
  private Config defaultDbConfig;
  // add #10344 merge treatment record rebuild End

  /**
   * {@inheritDoc}
   */
  @Override
  public List<TreatmentRecordResultMerge> getResultMergeList(Long ordNo, String facilityCd) throws NotExistException {
    try {
      // 治療記録（実績マージ情報）を取得する
      List<TreatmentRecordResultMerge> resultMerges = recordDao.selectTreatmentRecordResultMergeByOrdNo(ordNo);

      // 患者基本情報を取得する
      List<Long> patIds = resultMerges.stream()
        .filter(r -> r.getPatId() != null)
        .map(r -> r.getPatId())
        .distinct()
        .collect(Collectors.toList());
      Map<Long, PatPersonalMain> patPersonals = patPersonalDao.selectByIdListFacilityCd(patIds, facilityCd).stream()
        .collect(Collectors.toMap(p -> p.getPat_id(), p -> p));

      // 院内表示用患者ID、患者名を設定する
      resultMerges.stream().forEach(r -> {
        PatPersonalMain pat = patPersonals.getOrDefault(r.getPatId(), null);
        if (pat != null) {
          r.setHospPatId(pat.getHosp_pat_id());
          r.setPatName(String.format("%s %s", pat.getPat_last_name()==null?"":pat.getPat_last_name(), pat.getPat_first_name()==null?"":pat.getPat_first_name()));
        }
      });

      return resultMerges;

    } catch (EmptyResultDataAccessException e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("There is no TreatmentRecordResultMerge.");
      logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, null);
      throw new NotExistException("存在しない治療情報のオーダ番号を指定されています。");
    }
  }

  /**
   * {@inheritDoc}
   */
  @Transactional
  @Override
  public void updateResultMerge(Long ordNo, TreatmentRecordResultMerge treatmentRecordResultMerge) throws NotExistException {

    // add FNSI-改修内容追加OrdMain履歴 付 start
    selectHistoryUtils.insertMangoDbHistory(10, ordNo, null, new ArrayList<>(), new ArrayList<>(), null, null,
      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
      new ArrayList<>(), null, null);
    // mangoDb-updateTreatmentRecordForResultMerge-insertSuccess
    // add FNSI-改修内容追加OrdMain履歴 付 end

//    // オーダ番号を設定
//    treatmentRecordResultMerge.setOrdNo(ordNo);
//    final int updatedResultMergeCount = recordDao.updateTreatmentRecordForResultMerge(ordNo, treatmentRecordResultMerge);
    // バイタル情報、モニタ情報以外の実績マージ処理
    //add FNSI-投薬最新識別番号の設定 房 start
    if (treatmentRecordResultMerge.getRstMediInfo() != null
      && !treatmentRecordResultMerge.getRstMediInfo().equals("[]")) {
      ObjectMapper mapper = new ObjectMapper();
      List<ReceiveRstMediInfoDto> tempReceiveRstMediInfoDtos = null;
      try {
        tempReceiveRstMediInfoDtos = mapper.readValue(treatmentRecordResultMerge.getRstMediInfo(), new TypeReference<List<ReceiveRstMediInfoDto>>(){});
        OrdMain ordMain = ordMainDao.selectByOrdNo(treatmentRecordResultMerge.getOrdNo());
        for (ReceiveRstMediInfoDto element : tempReceiveRstMediInfoDtos) {
          if (element.getNo() == null || element.getNo().equals(0L)) {
            element.setNo(ordMainService.selectMaxMediInfoNo(ordMain.getFacilityCd(), String.valueOf(ordMain.getPatId())));
          }
        }
        treatmentRecordResultMerge.setRstMediInfo(mapper.writeValueAsString(tempReceiveRstMediInfoDtos));
      } catch (tools.jackson.core.JacksonException e) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
        logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, null);
      }
    }
    if (treatmentRecordResultMerge.getRstEquipInfo() != null
      && !treatmentRecordResultMerge.getRstEquipInfo().equals("[]")) {
      ObjectMapper mapper = new ObjectMapper();
      List<ReceiveRstEquipInfoDto> tempReceiveRstEquipInfoDtos = null;
      try {
        tempReceiveRstEquipInfoDtos = mapper.readValue(treatmentRecordResultMerge.getRstEquipInfo(), new TypeReference<List<ReceiveRstEquipInfoDto>>(){});
        OrdMain ordMain = ordMainDao.selectByOrdNo(treatmentRecordResultMerge.getOrdNo());
        for (ReceiveRstEquipInfoDto element : tempReceiveRstEquipInfoDtos) {
          if (element.getNo() == null || element.getNo().equals(0L)) {
            element.setNo(ordMainService.selectMaxEquipInfoNo(ordMain.getFacilityCd(), String.valueOf(ordMain.getPatId())));
          }
        }
        treatmentRecordResultMerge.setRstEquipInfo(mapper.writeValueAsString(tempReceiveRstEquipInfoDtos));
      } catch (JacksonException e) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, null);
      }
    }
    //add FNSI-投薬最新識別番号の設定 房 end
    final int updatedResultMergeCount = recordDao.updateTreatmentRecordForResultMerge(treatmentRecordResultMerge.getOrdNo(), treatmentRecordResultMerge);

    // #10196 Add by Zhou.tao 計算材料保持マージ処理 Start
    // mod 12250 ord_material_saveの処理を2回重複実行している zkm start
//    this.ordMaterialSaveService.updateOrdMaterialSaveByDiff(
//      new OrdMaterialSaveDto(ordNo, true, true, true, true
//        , OrdMaterialSaveDto.RST_CLASS)
//    );
    ordMaterialSaveService.bulkUpdateByOrdNoInCondMediEquipTreatment(Collections.singletonList(ordNo));
    // mod 12250 ord_material_saveの処理を2回重複実行している zkm end
    // #10196 Add by Zhou.tao 計算材料保持マージ処理 End

    // 更新日時
    Timestamp update = new Timestamp(System.currentTimeMillis());

    // バイタル情報マージ
    if (treatmentRecordResultMerge.isVitalMerge()) {

      // DB更新ログ出力ロジック wangzuo Start
      String tableName = "mni_monitor";
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" ord_no = " + treatmentRecordResultMerge.getMergeOrdNo() + "\n");
      wheres.append(" AND\n");
      wheres.append(" data_type in (2, 4, 5, 6)" + "'\n");

      // logCommon設定
      DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResult = logCommon.setInfo();
      // DB更新ログ出力ロジック wangzuo End

      int vitalMergeCount = mniMonitorDao.updateVitalDataByResultMerge(
        treatmentRecordResultMerge.getMergeOrdNo(),
        treatmentRecordResultMerge.getOrdNo(),
        treatmentRecordResultMerge.getPatId(),
        update,
        treatmentRecordResultMerge.getUpdStaffId());

      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && vitalMergeCount > 0) {
        logCommon.updateLog();
      }
      // DB更新ログ出力ロジック wangzuo End

      // マージ後、前血圧、後血圧が複数になる場合がある為、
      // 複数存在する場合には、データ種別を更新する。

      // オーダ番号に紐づく装置モニタデータを全件取得
      List<MniMonitor> mniMonitor =  mniMonitorDao.selectByOrdNo(treatmentRecordResultMerge.getOrdNo());

      // 「前血圧」の装置モニタデータに絞り込む
      // 発生日時の昇順
      List<MniMonitor> beforeBpMniMonitor = mniMonitor.stream()
        .filter(e -> e.getDataType() == CoreConstant.MniMonitorDataType.MONITOR_DATA_TYPE_BEFORE_BP)
        .sorted(Comparator.comparing(MniMonitor::getOccurDate))
        .collect(Collectors.toList());
      // 前血圧のデータ更新
      updateDataType(beforeBpMniMonitor, CoreConstant.MniMonitorDataType.MONITOR_DATA_TYPE_DIALYSIS_BP);

      // 「後血圧」の装置モニタデータに絞り込む
      // 発生日時の降順
      List<MniMonitor> afterBpMniMonitor = mniMonitor.stream()
        .filter(e -> e.getDataType() == CoreConstant.MniMonitorDataType.MONITOR_DATA_TYPE_AFTER_BP)
        .sorted(Comparator.comparing(MniMonitor::getOccurDate).reversed())
        .collect(Collectors.toList());
      // 後血圧のデータ更新
      updateDataType(afterBpMniMonitor, CoreConstant.MniMonitorDataType.MONITOR_DATA_TYPE_DIALYSIS_BP);

    }
    // モニタ情報マージ
    if (treatmentRecordResultMerge.isMonitorMerge()) {

      // DB更新ログ出力ロジック wangzuo Start
      String tableName = "mni_monitor";
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" ord_no = " + treatmentRecordResultMerge.getMergeOrdNo() + "\n");
      wheres.append(" AND\n");
      wheres.append(" data_type = 1" + "\n");

      // logCommon設定
      DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResult = logCommon.setInfo();
      // DB更新ログ出力ロジック wangzuo End

      int monitorMergeCount = mniMonitorDao.updateMonitorDataByResultMerge(
        treatmentRecordResultMerge.getMergeOrdNo(),
        treatmentRecordResultMerge.getOrdNo(),
        treatmentRecordResultMerge.getPatId(),
        update,
        treatmentRecordResultMerge.getUpdStaffId());

      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && monitorMergeCount > 0) {
        logCommon.updateLog();
      }
      // DB更新ログ出力ロジック wangzuo End

    }
    if (treatmentRecordResultMerge.getDeviceSetInfoFlag()) {
      ordTreatConditionDao.updateOrdNo(treatmentRecordResultMerge.getOrdNo(), treatmentRecordResultMerge.getMergeOrdNo(), update);
    }
    if (updatedResultMergeCount <= 0) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("There is no TreatmentRecordResultMerge.");
      logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, null);
      throw new NotExistException("存在しない治療情報のオーダ番号を指定されています。");
    }
    //add FNSI修正486改修 房 start
    if (treatmentRecordResultMerge.getBaseOrdNo() != null) {
      updateMntM(treatmentRecordResultMerge.getBaseOrdNo(), treatmentRecordResultMerge.getBaseBedCd(), treatmentRecordResultMerge.getBaseFacilityCd(),
        treatmentRecordResultMerge.getBaseSendMsgFlag(), treatmentRecordResultMerge.getBaseUpdateFlag(), treatmentRecordResultMerge.getPatId(), treatmentRecordResultMerge.getOrdNo(),
        treatmentRecordResultMerge.getRstDialysisState(), treatmentRecordResultMerge.getRstStartDate());
    }
    if (treatmentRecordResultMerge.getMerOrdNo() != null) {
      updateMntM(treatmentRecordResultMerge.getMerOrdNo(), treatmentRecordResultMerge.getMergeBedCd(), treatmentRecordResultMerge.getMergeFacilityCd(),
        treatmentRecordResultMerge.getMergeSendMsgFlag(), treatmentRecordResultMerge.getMergeUpdateFlag(), treatmentRecordResultMerge.getPatId(), treatmentRecordResultMerge.getOrdNo(),
        treatmentRecordResultMerge.getRstDialysisState(), treatmentRecordResultMerge.getRstStartDate());
    }
    //del FNSI修正 #6719 改修 ljx start
    /*    if (treatmentRecordResultMerge.getDeleteFlag()) {
      OrdMain delOrdMain = ordMainDao.selectByOrdNo(treatmentRecordResultMerge.getMerOrdNo());
      if (delOrdMain.getPatId() != null) {
        treatmentRecordDeleteService.deleteTreatmentRecordByOrdNo(treatmentRecordResultMerge.getMerOrdNo(), treatmentRecordResultMerge.getMergeFacilityCd());
      }ComplaintCreateModalComponent else {
        treatmentStatusListService.deleteUnknownPatRecord(treatmentRecordResultMerge.getMerOrdNo(), treatmentRecordResultMerge.getMergeFacilityCd());
      }
    }*/
    //del FNSI修正 #6719  改修 ljx end

    //del 9324 ????患者のチェックリストが不正 gjn start
//    if (treatmentRecordResultMerge.getOrdCheckListFlag()) {
//      ordChecklistDao.deleteByOrdNo(treatmentRecordResultMerge.getOrdNo(), treatmentRecordResultMerge.getBaseFacilityCd());
//      insertCheckList(treatmentRecordResultMerge.getBaseFacilityCd(), treatmentRecordResultMerge.getOrdNo());
//    }
    //del 9324 ????患者のチェックリストが不正 gjn end
    if (treatmentRecordResultMerge.getDeviceSetRecordFlag()) {
      OrdMain ordMain = ordMainDao.selectByOrdNo(treatmentRecordResultMerge.getDeviceFromOrdNo());
      if (ordMain.getRstBedCd() != null) {
        MstBed mstBed = mstBedDao.selectByBedCd(Long.valueOf(ordMain.getRstBedCd()), "1", "0");
        if (mstBed != null) {
          if (mstBed.getMachineNo() != null) {
            MstMachine mstMachine = mstMachineDao.selectByMachineNo(mstBed.getMachineNo());
            if (mstMachine != null && mstMachine.getFacilityCd() != null && mstMachine.getMachineTypeCd() != null && mstMachine.getMachineSerial() != null) {
              List<MntMotionRecord> mntMotionRecords = mntMotionRecordDao.selectMntMotionRecordByOrdNo(mstMachine.getFacilityCd(),
                mstMachine.getMachineTypeCd(), mstMachine.getMachineSerial(), treatmentRecordResultMerge.getDeviceFromOrdNo());
              if (mntMotionRecords != null && mntMotionRecords.size() > 0) {
                for (MntMotionRecord mntMotionRecord : mntMotionRecords) {
                  mntMotionRecord.setMotionRecordNo(null);
                  mntMotionRecord.setOrdNo(treatmentRecordResultMerge.getOrdNo());
                  mntMotionRecordDao.insert(mntMotionRecord);
                }
              }
            }
          }
        }
      }
    }
    //add FNSI修正486改修 房 end

    //add FNSI修正 #6719 改修 ljx start
    //最後に、？？？？患者の実績を削除する。
    if (treatmentRecordResultMerge.getDeleteFlag()) {
      OrdMain delOrdMain = ordMainDao.selectByOrdNo(treatmentRecordResultMerge.getMerOrdNo());
      if (delOrdMain.getPatId() != null) {
        treatmentRecordDeleteService.deleteTreatmentRecordByOrdNo(treatmentRecordResultMerge.getMerOrdNo(), treatmentRecordResultMerge.getMergeFacilityCd());
      } else {
        treatmentStatusListService.deleteUnknownPatRecord(treatmentRecordResultMerge.getMerOrdNo(), treatmentRecordResultMerge.getMergeFacilityCd());
      }
      //add #10196 Ord_Material_Save code implementation 20240131 ztc start
      ordMaterialSaveService.deleteOrdMaterialSave(treatmentRecordResultMerge.getMerOrdNo());
      //add #10196 Ord_Material_Save code implementation 20240131 ztc end
    }
    //add FNSI修正 #6719 改修 ljx end
  }

  //add FNSI修正486改修 房 start
  private void insertCheckList(String facilityCd, Long ordNo) {
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
    ResponseEntity<Object> response = null;
    try {
      URI uri = new URI(deviceEdgeUrl + "/api/comsv_checklist/ord/createordchecklist/" + facilityCd + "/" + ordNo);
      RequestEntity<Void> request = RequestEntity.get(uri).header("SSECCAYEK", "NTSS-NKK-ESM-TDC-YSK").build();
      RestTemplate restTemplate = new RestTemplate();
      long start = System.currentTimeMillis();
      response = restTemplate.exchange(request, Object.class);
      long cost = System.currentTimeMillis() - start;
      Map<String, Object> map = new HashMap<>();
      map.put("logType", "RESTTEMPLATE-LOG");
      map.put("className", "jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.TreatmentRecordResultMergeServiceImpl");
      map.put("methodName", "insertCheckList");
      map.put("method", request.getMethod());
      map.put("url", uri.getPath());
      map.put("headers", request.getHeaders());
      map.put("requestParameter", request.getBody());
      map.put("status",response.getStatusCode());
      map.put("cost", cost);
      map.put("result",response.getBody());
      EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
      restTemplateEventLogMessage.setLogMessage(toJson(map));
      restTemplateEventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
    } catch (URISyntaxException e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("チェックリスト情報更新API呼び出し失敗 = " + response.getStatusCode() + " message: " + e.getMessage());
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    }
  }

  private void updateMntM(Long ordNo, Long bedCd, String facilityCd, String sendMsgFlag, String updateFlag, Long mergePatId, Long mergeOrdNo, String rstDialysisState, Timestamp rstStartDate){
    Timestamp timestamp = new Timestamp(System.currentTimeMillis());
    MstBed mstBed = mstBedDao.selectByBedCd(bedCd, "1", "0");
    Long updatePatId = null;
    Long updateOrdNo = null;
    boolean nextFlag = false;

    if ("2".equals(sendMsgFlag)) {
      if ("3".equals(rstDialysisState)) {
        updatePatId = mergePatId;
        updateOrdNo = mergeOrdNo;
        nextFlag = true;
      }
    }

    if (mstBed != null && mstBed.getMachineNo() != null) {
      MstMachine mstMachine = mstMachineDao.selectByMachineNo(mstBed.getMachineNo());
      if (mstMachine != null) {
        MntMachineState mntMachineState = mntMachineStateDao.selectByKey(mstMachine.getFacilityCd(), mstMachine.getMachineTypeCd(), mstMachine.getMachineSerial());
        if (mntMachineState != null) {
          if ("1".equals(updateFlag)) {
            mntMachineStateDao.updatePatInfo(mntMachineState.getFacilityCd(), mntMachineState.getMachineTypeCd(), mntMachineState.getMachineSerial(), timestamp, updatePatId, updateOrdNo, nextFlag);
          } else {
            if ((mntMachineState.getOrdNo() != null && mntMachineState.getNextOrdNo() != null && !mntMachineState.getOrdNo().equals(mntMachineState.getNextOrdNo()))
              || (mntMachineState.getOrdNo() != null && mntMachineState.getNextOrdNo() == null)) {
              mntMachineStateDao.updatePatInfo(mntMachineState.getFacilityCd(), mntMachineState.getMachineTypeCd(), mntMachineState.getMachineSerial(), timestamp, updatePatId, updateOrdNo, nextFlag);
            }
          }
        }

        DeviceEdgeOrderRequest request = new DeviceEdgeOrderRequest();
        try {
          DeviceEdgeOrderRequest targetInfo = null;
          if ("2".equals(sendMsgFlag)) {
            request.setOrdNo(ordNo);
            request.setFacilityCd(facilityCd);
            targetInfo = deviceEdgeOrderService.findMissingData(request);
            //mod FNSI-redmine6535 fang start
            deviceEdgeOrderService.orderSetUnknownPat(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo(),
              targetInfo.getMachineNo(), mergeOrdNo, rstStartDate);
            //mod FNSI-redmine6535 fang end
          } else {
            request.setOrdNo(ordNo);
            request.setFacilityCd(facilityCd);
            targetInfo = deviceEdgeOrderService.findMissingData(request);
            deviceEdgeOrderService.orderSendNextPat(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo(),
              targetInfo.getMachineNo(), targetInfo.getOrdNo());
          }
        } catch (Exception e) {
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("There is no MstUser.");
          logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, SERVICE_NAME.REMS,
            null);
        }
      }
    }
  }
  //add FNSI修正486改修 房 end

  /**
   * 指定された{@link MniMonitor}のリストに格納されたデータ種別を更新.
   * ※リスト内のインデックス:0 は血圧情報とする為、インデックス：1 以降のデータが処理対象
   * @param targetList 更新する{@link MniMonitor}のリスト
   * @param dataType 更新するデータ種別
   * @return 更新件数
   */
  private int updateDataType(List<MniMonitor> targetList, Short dataType) {
    // 更新対象データのリストがnullまたは、1件の場合は処理しない
    if (targetList == null || targetList.size() == 1) {
      return 0;
    }
    // 更新件数
    int updateCount = 0;
    for (int idx = 1; idx < targetList.size(); idx++) {
      Long bioMniCtlNo = targetList.get(idx).getBioMoniCtlNo();

      // DB更新ログ出力ロジック wangzuo Start
      String tableName = "mni_monitor";
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" bio_moni_ctl_no = " + bioMniCtlNo + "\n");

      // logCommon設定
      DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResult = logCommon.setInfo();
      // DB更新ログ出力ロジック wangzuo End

      updateCount += mniMonitorDao.updateDataTypeByKey(bioMniCtlNo, dataType);

      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && updateCount > 0) {
        logCommon.updateLog();
      }
      // DB更新ログ出力ロジック wangzuo End
    }
    return  updateCount;
  }

  // DB更新ログ出力ロジック wangzuo Start
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
    eventLogMessage.setServiceName(LoggingConstant.MODULE_NAME.ADMIN_WEB + "," + SERVICE_NAME.FNSI);
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
  // DB更新ログ出力ロジック wangzuo End

  //add FNSI修正486改修 房 start
  /**
   * {@inheritDoc}
   */
  @Override
  public List<TreatmentRecordResultMerge> getResultMergeList(Long ordNo, String facilityCd, String startDate, String endDate, String isUnknown) throws NotExistException {
    // #10607 Mod NKKレビュー指摘 No.3 - 実績マージできるデータが0件の場合、エラー応答とならないようにしてください Start
//    try {
    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);

    // #10344 Modified 治療開始日時～治療終了日時の日にちの範囲に重複する治療
    // 治療記録（実績マージ情報）を取得する
    // #10607 mod Start

    // Remove time accuracy to the start of day
    LocalDateTime startTime = ordMain.getRstStartDate() == null
      // in case of getting a empty startDate, we will use treatDate instead of startDate.
      ? LocalDate.parse(ordMain.getTreatDate(), DateTimeFormatter.ofPattern("yyyyMMdd")).atStartOfDay()
      : ordMain.getRstStartDate().toLocalDateTime().toLocalDate().atStartOfDay();

    LocalDateTime endTime = ordMain.getRstEndDate() == null
      // 治療中の場合は治療終了日時が入っていないためその場合は現在日時を代入して処理
      ? LocalDate.now().plusDays(1L).atStartOfDay()
      : ordMain.getRstEndDate()
      .toLocalDateTime()
      .toLocalDate()
      .plusDays(1L)
      .atStartOfDay();
    // maybe a starting time of future days can be setting, so delay this endTime to this future starting time
    if (startTime.isAfter(endTime)) endTime = startTime;

    // the query param of the time, will be the start of these days
    List<TreatmentRecordResultMerge> resultMerges = recordDao.selectTreatmentRecordResultMergeListByOrdNo(facilityCd, ordNo
      , Timestamp.valueOf(startTime), Timestamp.valueOf(endTime), isUnknown, ordMain.getPatId());
    // #10607 mod End

    // 患者基本情報を取得する
    if (!CollectionUtils.isEmpty(resultMerges)) {

      List<Long> patIds = resultMerges.stream()
        .map(TreatmentRecordResultMerge::getPatId)
        .filter(Objects::nonNull)
        .distinct()
        .collect(Collectors.toList());
      Map<Long, PatPersonalMain> patPersonals = patPersonalDao.selectByIdListFacilityCd(patIds, facilityCd).stream()
        .collect(Collectors.toMap(PatPersonalMain::getPat_id, p -> p));

      // 院内表示用患者ID、患者名を設定する
      resultMerges.forEach(r -> {
        PatPersonalMain pat = patPersonals.getOrDefault(r.getPatId(), null);
        if (pat != null) {
          r.setHospPatId(pat.getHosp_pat_id());
          r.setPatName(String.format("%s %s", pat.getPat_last_name()==null?"":pat.getPat_last_name(), pat.getPat_first_name()==null?"":pat.getPat_first_name()));
          r.setPatLastName(pat.getPat_last_name());
          r.setPatLastNameKana(pat.getPat_last_name_kana());
          r.setPatFirstName(pat.getPat_first_name());
          r.setPatFirstNameKana(pat.getPat_first_name_kana());
        }
      });
    }

    return resultMerges;

//    } catch (EmptyResultDataAccessException e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage("There is no TreatmentRecordResultMerge.");
//      logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, null);
//      throw new NotExistException("存在しない治療情報のオーダ番号を指定されています。");
//    }
    // #10607 Mod NKKレビュー指摘 No.3 - 実績マージできるデータが0件の場合、エラー応答とならないようにしてください End
  }
  //add FNSI修正486改修 房 end

  // #10344 Add Start
  /**
   *  治療記録（実績マージ）
   *
   * @param treatmentRecordResultMerge  マージオプション
   */
  @Transactional
  public void treatmentRecordMergeExecution(TreatmentRecordResultMerge treatmentRecordResultMerge) {

    Timestamp nowTs = Timestamp.from(Instant.now());

    // 治療情報データの再取得
    OrdMain baseData = ordMainDao.selectByOrdNo(treatmentRecordResultMerge.getBaseOrdNo());
    OrdMain mergeData = ordMainDao.selectByOrdNo(treatmentRecordResultMerge.getMerOrdNo());


    // Deep copy baseData & mergeData, waiting for call next pat.
    OrdMain orgBaseData = new OrdMain();
    OrdMain orgMergeData = new OrdMain();
    BeanUtils.copyProperties(baseData, orgBaseData);
    BeanUtils.copyProperties(mergeData, orgMergeData);

    // 画面端マージ完了したのデータを再設定する
    this.buildBaseData(baseData, treatmentRecordResultMerge);
    // アセンブリマージデータのオプション
    Integer assemblyMergeCondition = DetermineMergeStatusEnum.assemblyMergeCondition(
      treatmentRecordResultMerge.getDeleteFlag()
      , treatmentRecordResultMerge.getDeviceSetInfoFlag()
      , treatmentRecordResultMerge.isVitalMerge()
      , treatmentRecordResultMerge.isMonitorMerge()
      , treatmentRecordResultMerge.getDeviceSetRecordFlag()
      , treatmentRecordResultMerge.getOrdCheckListFlag()
    );

    // 元投薬情報に識別番号変更の必要がありません。
    // 投薬最新識別番号を設定のために、投薬最新識別番号をマージデータのサイズを増える。
    // 必要な番号を一度にすべて埋めて、今回の操作の原子性と識別番号の一貫性を保証します。
    // SQLにはcreate or update操作が含まれており、再整合不要。
    // 投薬識別番号
    long mediInfoNo;
    String origialMergeRstMediInfo = mergeData.getRstMediInfo();

    if (StringUtils.isNotEmpty(treatmentRecordResultMerge.getMergeRstMediInfo())
      && treatmentRecordResultMerge.getMergeMediInfoArrayLen() != null
      && treatmentRecordResultMerge.getMergeMediInfoArrayLen() > 0) {
      // マージデータの最新投薬情報設定
      mergeData.setRstMediInfo(treatmentRecordResultMerge.getMergeRstMediInfo());
      // 投薬最新識別番号を更新する
      MedicineLatestNo lastPatMediNo = ordMainDao.updatePatMedicineNo(
        new MedicineLatestNo(
          baseData.getFacilityCd(), baseData.getPatId()
          , treatmentRecordResultMerge.getMergeMediInfoArrayLen()
          , nowTs, nowTs
          , AdminWebConstant.FlagType.FLAG_ON
          , AdminWebConstant.FlagType.FLAG_OFF
        )
      ).getEntity();

      // 投薬最新識別番号の取得
      mediInfoNo =
        ordMainDao.selectIndMediInfoNo(lastPatMediNo.getFacilityCd(), String.valueOf(lastPatMediNo.getPatId()));
    } else {
      mediInfoNo = 0L;
    }

    // 条件に応じて定義された実行プロセスを取得する
    DetermineMergeStatusEnum.getDetermineStatus(
      baseData.getRstDialysisState(), mergeData.getRstDialysisState(), mergeData.getPatId() == null
    ).ifPresent(
      dms -> {
        // 定義されたプロセスを実行する
        dms.getDetermineStatusHandler(
          baseData, mergeData,
          treatmentRecordResultMerge.getBaseBedCd(),
          treatmentRecordResultMerge.getMergeBedCd(),
          assemblyMergeCondition, mediInfoNo
          , treatmentRecordResultMerge.getMergeRstMediInfo()
        ).execute();

        // 更新実行後、投薬情報リストア
        mergeData.setRstMediInfo(origialMergeRstMediInfo);

        // 次患者更新実行纏め処理
        nextPatService.CallNextPatChange(baseData.getFacilityCd(), List.of(orgBaseData, orgMergeData));

        // 次患者更新済み、治療中なレコード「未登録患者割付指示」送信する必要があります
        if (dms.getBaseOmStatus().equals("3")
          || (
              !dms.getBaseOmStatus().equals("6")
              && (dms.getMergeOmStatus().equals("3", true) || dms.getMergeOmStatus().equals("3", false))
            )
        ) {
          // 指定ベッドは1つの装置に対応で
          List<MstMachine> machineInfos = mstMachineDao.selectByBedCd(mergeData.getFacilityCd(), mergeData.getRstBedCd());
          if (!CollectionUtils.isEmpty(machineInfos)) {
            deviceEdgeOrderService.sendMessageToComServer(
              mergeData.getFacilityCd()
              , machineInfos.get(0).getDeviceEdgeNo()
              , AdminWebConstant.WebSocketTopic.ComSv.SET_UNKNOWN_PAT
              , PayloadBuilder.BuildMachineAndOrdNoPayload(machineInfos.get(0).getMachineNo(), mergeData.getOrdNo()));
          }
        }
      }
    );
  }

  private void buildBaseData(OrdMain baseData, TreatmentRecordResultMerge treatmentRecordResultMerge) {
    baseData.setRstTreatmentCd(
      StringUtils.isEmpty(treatmentRecordResultMerge.getRstTreatmentCd())
        ? null : Integer.parseInt(treatmentRecordResultMerge.getRstTreatmentCd())
    );
    baseData.setRstTreatmentName(treatmentRecordResultMerge.getRstTreatmentName());
    baseData.setRstKurCd(
      treatmentRecordResultMerge.getRstKurCd() == null
        ? null : treatmentRecordResultMerge.getRstKurCd().intValue()
    );
    baseData.setRstKurName(treatmentRecordResultMerge.getRstKurName());
    baseData.setRstBedCd(treatmentRecordResultMerge.getRstBedCd());
    baseData.setRstBedName(treatmentRecordResultMerge.getRstBedName());
    baseData.setRstStartDate(treatmentRecordResultMerge.getRstStartDate());
    baseData.setRstEndDate(treatmentRecordResultMerge.getRstEndDate());
    baseData.setRstInOutClass(
      treatmentRecordResultMerge.getRstInOutClass() == null
        ? null : treatmentRecordResultMerge.getRstInOutClass().shortValue()
    );
    baseData.setRstDialysisCnt(treatmentRecordResultMerge.getRstDialysisCnt());
    baseData.setRstWardCd(treatmentRecordResultMerge.getRstWardCd());
    baseData.setRstWardName(treatmentRecordResultMerge.getRstWardName());
    baseData.setRstCourseCd(treatmentRecordResultMerge.getRstCourseCd());
    baseData.setRstCourseName(treatmentRecordResultMerge.getRstCourseName());
    baseData.setRstPunctureUserInfo(treatmentRecordResultMerge.getRstPunctureUserInfo());
    baseData.setRstReturnUserInfo(treatmentRecordResultMerge.getRstReturnUserInfo());
    baseData.setRstChargeUserInfo(treatmentRecordResultMerge.getRstChargeUserInfo());
    baseData.setRstBloodCirculateTotal(
      treatmentRecordResultMerge.getRstBloodCirculateTotal() == null
        ? null : treatmentRecordResultMerge.getRstBloodCirculateTotal().doubleValue()
    );
    baseData.setSendCtlNo(treatmentRecordResultMerge.getSendCtlNo()); // TODO 送信管理番号何に使われているか不明
    baseData.setBloodPurifierName(treatmentRecordResultMerge.getBloodPurifierName());
    baseData.setRstCondInfo(treatmentRecordResultMerge.getRstCondInfo());
    baseData.setRstMediInfo(treatmentRecordResultMerge.getRstMediInfo());
    baseData.setRstEquipInfo(treatmentRecordResultMerge.getRstEquipInfo());
    baseData.setRstIndCommentInfo(treatmentRecordResultMerge.getRstIndCommentInfo());
    baseData.setRstTareInfo(treatmentRecordResultMerge.getRstTareInfo());
    baseData.setRstOffWaterInfo(treatmentRecordResultMerge.getRstOffWaterInfo());
    baseData.setRstWeightInfo(treatmentRecordResultMerge.getRstWeightInfo());
    baseData.setRstComplaintInfo(treatmentRecordResultMerge.getRstComplaintInfo());
    baseData.setRstTreatmentInfo(treatmentRecordResultMerge.getRstTreatmentInfo());
    baseData.setRstTreatStaffInfo(treatmentRecordResultMerge.getRstTreatStaffInfo());
    baseData.setRstRoundsInfo(treatmentRecordResultMerge.getRstRoundsInfo());
    baseData.setRstPurificationCnt(treatmentRecordResultMerge.getRstPurificationCnt());
    baseData.setRstDw(treatmentRecordResultMerge.getRstDw());
    baseData.setWeightScaleNo(null);

    // #11467 【たくしん会】H12条件送信ができない。患者経過総合ビューアのDW表示が不正。　V1.0B Start
    baseData.setRstDeviceMode(treatmentRecordResultMerge.getRstDeviceMode());
    // #11467 【たくしん会】H12条件送信ができない。患者経過総合ビューアのDW表示が不正。　V1.0B End
  }
  // #10344 Add end
}
