package jp.co.nikkiso.ntss.admin_web.service.weight;

import tools.jackson.core.JacksonException;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;
import tools.jackson.databind.node.ObjectNode;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.FlagType;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.OrdMainConst;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.OrdMainConst.DialysisState;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Treatment;
import jp.co.nikkiso.ntss.admin_web.request.weight.SendConditionRequest;
import jp.co.nikkiso.ntss.admin_web.response.weight.*;
import jp.co.nikkiso.ntss.admin_web.response.weight.WeightOrderResponse.MachineState;
import jp.co.nikkiso.ntss.admin_web.response.weight.WeightOrderResponse.WheelChairScaleMode;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.SelectHistoryUtils;
import jp.co.nikkiso.ntss.admin_web.service.WebAPICheckConditionSendService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.statusList.dto.physicalInfo.PhysicalInfo;
import jp.co.nikkiso.ntss.admin_web.service.statusList.dto.physicalInfo.PhysicalInfoItem;
import jp.co.nikkiso.ntss.admin_web.service.utils.DateTimeUtils;
import jp.co.nikkiso.ntss.admin_web.service.weight.state.ScaleBedStateService;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebAPICheckConditionSend;
import jp.co.nikkiso.ntss.api.service.PatMainAcceptanceStatusInfo.PatMainAcceptanceStatusInfoService;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.ComFormat;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.ComType;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.FacilitySettingNo;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.rstDialysisState;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.*;
import jp.co.nikkiso.ntss.core.entity.*;
import jp.co.nikkiso.ntss.core.entity.custom.*;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.utils.TriggerUtil;
import org.apache.commons.collections4.CollectionUtils;
import org.json.JSONObject;
import org.postgresql.util.PGobject;
import org.seasar.doma.jdbc.Config;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.time.format.ResolverStyle;
import java.util.*;
import java.util.stream.Collectors;
import jp.co.nikkiso.ntss.core.config.DefaultDb;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Service
public class WeightServiceImpl implements WeightService {

  @Autowired
  private OrdMainDao ordMainDao;
  @Autowired
  private MntMachineStateDao mntMachineStateDao;
  @Autowired
  private PatPersonalMainDao patPersonalMainDao;
  @Autowired
  private OrdWeightScaleDao ordWeightScaleDao;
  @Autowired
  private MstMachineDao mstMachineDao;
  @Autowired
  private MstKurDao mstKurDao;
  @Autowired
  private MstRoomBedGroupDao mstRoomBedGroupDao;
  @Autowired
  private MstWheelChairDao mstWheelChairDao;
  @Autowired
  private PatUniqueDao patUniqueDao;
  @Autowired
  private PatMainDao patMainDao;
  @Autowired
  private MstFacilityDao mstFacilityDao;
  @Autowired
  private MstSelectorDao mstSelectorDao;
  @Autowired
  private MstFacilitySettingDao mstFacilitySettingDao;
  @Autowired
  private PatExamMainDao patExamMainDao;
  @Autowired
  private MstWeightScaleDao mstWeightScaleDao;

  //FNSI-修正 ログ対応 wp add start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Autowired
  private LogServiceCore logServiceCore;
  //FNSI-修正 ログ対応 wp add end 20210128

  @Autowired
  PatMainAcceptanceStatusInfoService patMainAcceptanceStatusInfoService;
  // add FNSI-改修内容追加OrdMain履歴 付 start
  @Autowired
  private SelectHistoryUtils selectHistoryUtils;
  // add FNSI-改修内容追加OrdMain履歴 付 end
  // add FNSI-分類不一致判断の追加 徐 start
  @Autowired
  WebAPICheckConditionSendService webAPICheckConditionSendService;

  @Autowired
  private MstDialyzerDao mstDialyzerDao;

  @Autowired
  private MstBedDao mstBedDao;

  @Autowired
  private MstVaDao mstVaDao;
  // add FNSI-分類不一致判断の追加 徐 end
  // add FNSI-確定フラグを”1”に更新 徐 start
  @Autowired
  private OrdMaterialSaveDao ordMaterialSaveDao;
  // add FNSI-確定フラグを”1”に更新 徐 end

  // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 start
  @Autowired
  private ScaleBedStateService scaleBedStateService;
  // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 end

  /**
   * TMP補液制御対象装置
   */
  private static String[] USE_TMP_CONTROL_MACHINES = {
    "069", // DCS-200Si
    "070", // DBB-200Si
    "071", // DCS-100NX
    "072" // DBB-100NX
  };

  /**
   * ロギングのServiceインタフェース.
   */
  @Autowired
  private LogService logService;
  /**
   * ObjectMapper.
   */
  @Autowired
  private ObjectMapper mapper;

  @Autowired
  private TriggerUtil triggerUtil;

  @Autowired
  @DefaultDb
  private Config defaultDbConfig;

  /**
   * {@inheritDoc}
   */
  @Override
  public Long getPatId(String facilityCd, String hospPatId) {
    Long patId = null;
    if (hospPatId != null && hospPatId.length() > 0) {
      // 患者IDの取得
      patId = patPersonalMainDao.selectPatIdByHospPatId(facilityCd, hospPatId);

      // 該当患者が存在しない場合
      if (patId == null) {
        // nullを返す
        return null;
      }
    }
    return patId;
  }
  // add FNSI-次回同じ患者を検索する場合測定値保存する 徐 start

  /**
   * {@inheritDoc}
   */
  @Override
  public double getMeasuredValue(String facilityCd, Long patId) {
    double measuredValue = 0.00;
    measuredValue = ordWeightScaleDao.selectMeasuredValueByPatId(facilityCd, patId);
    return measuredValue;
  }
  // add FNSI-次回同じ患者を検索する場合測定値保存する 徐 end

  /**
   * {@inheritDoc}
   */
  @Override
  public String getCurrentDialysisState(Long ordNo) {
    // オーダー情報の取得
    OrdMainForWeightInd ord = ordMainDao.selectForWeightIndByOrdNo(ordNo);
    return ord.getRstDialysisState();
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<WeightScheduleResponse> selectWeightSchedule(String facilityCd, String hospPatId, String treatDate,
                                                           boolean isPast) {
    // NOTE: 施設コード＋is_del=0で版番号rst_treat_statusが５のもの以外（実績確定前）で抽出
    // ①予定日が一致して、かつrst_treat_statusが1～3で治療完了前のもの
    // ②治療終了日が一致して、かつrst_treat_statusが4～5で治療完了から実績確定前のもの
    // ③予定日が指定日より前で、rst_treat_statusが3で治療中のもの
    // isPastがtrueで過去日指定のものは、①を対象としない


    List<WeightScheduleResponse> res = new ArrayList<>();
    Long patId = null;
    if (hospPatId != null && hospPatId.length() > 0) {
      // 患者IDの取得
      patId = patPersonalMainDao.selectPatIdByHospPatId(facilityCd, hospPatId);

      // 該当患者が存在しない場合
      if (patId == null) {
        // nullを返す
        return res;
      }
    }
    // NOTE: 前日の後体重測定待ちも検索対象とする
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("uuuuMMddHHmmss").withResolverStyle(ResolverStyle.STRICT);
    LocalDateTime ldt = LocalDate.now().atStartOfDay();
    try {
      ldt = LocalDateTime.parse(treatDate + "000000", formatter);
    } catch (Exception e) {
      // TODO: エラーログ出力
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      eventLogMessage.setFacilityCd(facilityCd);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
    }
    Timestamp treatLocalDate = Timestamp.valueOf(ldt);
    Timestamp treatLocalDateLast = Timestamp.valueOf(ldt.plusDays(1L));

    List<OrdMainForWeightSchedule> scheduleList = ordMainDao.selectScheduleForWeight(facilityCd, patId, treatDate,
      treatLocalDate, treatLocalDateLast, isPast);
    List<Long> patIdList = scheduleList.stream().map(s -> s.getPatId()).distinct().collect(Collectors.toList());
    patIdList.removeAll(Collections.singleton(null)); // null削除
    List<PatPersonalMain> pats = patPersonalMainDao.selectByIdListFacilityCd(patIdList, facilityCd);
    List<PatPersonalMain> pat;
    String patLastName = "";
    String patFirstName = "";
    String patLastNameKana = "";
    String patFirstNameKana = "";
    String patBirthday = "";
    String scheduleHospPatId = "";
    Long kurCd = 0L;
    Long bedCd = 0L;
    Integer treatmentCd = 0;
    String kurName = "";
    String bedName = "";
    String treatmentName = "";
    Integer deviceMode = 0;
    // FNSI-add 入院・同姓同名配布 徐 start
    Integer inOutClass = 0;
    // FNSI-add 入院・同姓同名配布 徐 end
    String kurStartTime = null;
    Long treatmentOrderIndex = null;
    Long bedOrderIndex = null;
    for (OrdMainForWeightSchedule schedule : scheduleList) {
      kurCd = 0L;
      bedCd = 0L;
      treatmentCd = 0;
      kurName = "";
      bedName = "";
      treatmentName = "";
      deviceMode = 0;
      kurStartTime = null;
      treatmentOrderIndex = null;
      bedOrderIndex = null;
      if (schedule.getRstDialysisState().equals(OrdMainConst.DialysisState.BEFORE_SEND)
        || schedule.getRstDialysisState().equals(OrdMainConst.DialysisState.AFTER_SEND)) {
        // 透析前（条件送信確認前）
        kurCd = schedule.getIndKurCd();
        bedCd = schedule.getIndBedCd();
        kurName = schedule.getIndKurName();
        bedName = schedule.getIndBedName();
        treatmentCd = schedule.getIndTreatmentCd();
        treatmentName = schedule.getIndTreatmentName();
        deviceMode = schedule.getIndDeviceMode();
        kurStartTime = schedule.getIndKurStartTime();
        treatmentOrderIndex = schedule.getIndTreatmentOrderIndex();
        bedOrderIndex = schedule.getIndBedOrderIndex();
      } else {
        // 実績作成後
        kurCd = schedule.getRstKurCd();
        bedCd = schedule.getRstBedCd();
        kurName = schedule.getRstKurName();
        bedName = schedule.getRstBedName();
        treatmentCd = schedule.getRstTreatmentCd();
        treatmentName = schedule.getRstTreatmentName();
        deviceMode = schedule.getRstDeviceMode();
        kurStartTime = schedule.getRstKurStartTime();
        treatmentOrderIndex = schedule.getRstTreatmentOrderIndex();
        bedOrderIndex = schedule.getRstBedOrderIndex();
      }

      // 患者名取得
      pat = pats.stream().filter(p -> Objects.equals(p.getPat_id(), schedule.getPatId())).collect(Collectors.toList());
      patLastName = "";
      patFirstName = "";
      patLastNameKana = "";
      patFirstNameKana = "";
      scheduleHospPatId = "";
      patBirthday = "";
      // FNSI-add 入院・同姓同名配布 徐 start
      inOutClass = 0;
      // FNSI-add 入院・同姓同名配布 徐 end
      if (pat.size() > 0) {
        patLastName = pat.get(0).getPat_last_name();
        patFirstName = pat.get(0).getPat_first_name();
        patLastNameKana = pat.get(0).getPat_last_name_kana();
        patFirstNameKana = pat.get(0).getPat_first_name_kana();
        scheduleHospPatId = pat.get(0).getHosp_pat_id();
        patBirthday = pat.get(0).getPat_birthday();
        // FNSI-add 入院・同姓同名配布 徐 start
        inOutClass = pat.get(0).getIn_out_class();
        // FNSI-add 入院・同姓同名配布 徐 end
      }

      // 応答用スケジュール情報作成
      WeightScheduleResponse r = new WeightScheduleResponse(
        schedule.getOrdNo(), schedule.getPatId(), scheduleHospPatId, patLastName, patFirstName,
        schedule.getFacilityCd(), schedule.getIsSame(), schedule.getTreatDate(),
        treatmentCd, treatmentName, deviceMode,
        kurCd, kurName, schedule.getIndTreatStartTime(),
        bedCd, bedName, schedule.getRstEdition(), schedule.getRstDialysisState(), schedule.getRstStartDate(), patBirthday,
        // FNSI-add 入院・同姓同名配布 徐 start
        inOutClass,
        // FNSI-add 入院・同姓同名配布 徐 end
        patLastNameKana, patFirstNameKana,
        kurStartTime, treatmentOrderIndex, bedOrderIndex
      );

      res.add(r);
    }
    return res;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public MachineCurrentOrdDataSet findMachineStateByBed(String facilityCd, Long bedCd) {
    MachineCurrentOrdDataSet res = new MachineCurrentOrdDataSet();
    // 条件から装置情報を取得
    List<MstMachine> machines = mstMachineDao.selectByBedCd(facilityCd, bedCd);
    if (machines.size() == 0) {
      return res;
    }
    MstMachine machine = machines.get(0);
    MntMachineState machineState = mntMachineStateDao.selectByKey(facilityCd,
      machine.getMachineTypeCd(), machine.getMachineSerial());
    // 条件送信済みオーダー番号
    Long ordNo = machineState.getOrdNo();
    // 次患者オーダー番号
    Long nextOrdNo = machineState.getNextOrdNo();

    res.machine = machine;
    res.state = machineState;
    res.targetMachineCurrentOrdNo = ordNo;
    res.targetMachineNextOrdNo = nextOrdNo;

    return res;
  }

  @Override
  public currentOrdTargetAction validationCurrentOrdTargetAction(Long targetOrdNo) {

    if (targetOrdNo == null) {
      // 条件送信済みデータなし
      return currentOrdTargetAction.canSendCondition;
    }
    OrdMainForWeightInd ord = ordMainDao.selectForWeightIndByOrdNo(targetOrdNo);
    if (ord == null || DialysisState.BEFORE_SEND.equals(ord.getRstDialysisState())) {
      // 条件送信済みデータなし
      return currentOrdTargetAction.canSendCondition;
    } else if (DialysisState.PAST_RECORD.equals(ord.getRstDialysisState())
      || DialysisState.AFTER_WEIGHT.equals(ord.getRstDialysisState())
      || DialysisState.AFTER_DIALYSIS.equals(ord.getRstDialysisState())) {
      // 実績確認後（現患者として残っているのはおかしい）
      // 後体重測定済み（実績確認ボタンが押されていない）
      // 排液済み（後体重測定が行われていない）
      // これらの状態で次患者が条件送信された場合、現患者クリアする
      return currentOrdTargetAction.clearCurrentOrd;
    } else if (DialysisState.AFTER_SEND.equals(ord.getRstDialysisState())) {
      // 条件送信済み
      // 条件送信キャンセルが必要
      return currentOrdTargetAction.doCancel;
    } else if (DialysisState.DIALYSIS.equals(ord.getRstDialysisState())) {
      // 治療中
      // 条件送信不可
      return currentOrdTargetAction.dialysis;
    } else if (DialysisState.CHECKED_SEND.equals(ord.getRstDialysisState())) {
      // 条件確認済み
      // 条件送信不可
      return currentOrdTargetAction.checked;
    }
    return currentOrdTargetAction.doCancel;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public boolean updateMachineNextOrdInfo(MstMachine machine, Long nextOrdNo) {

    int retCnt = 0;
    DateTimeFormatter dateFormat = DateTimeFormatter.ofPattern("yyyyMMddHHmm");

    OrdMainForWeightInd ord = ordMainDao.selectForWeightIndByOrdNo(nextOrdNo);
    // modify 10954 by kangjie 20240805 start
    //    String startPlanDateStr = ord.getTreatDate() + ord.getIndTreatStartTime();
    String indStartTime = ord.getIndTreatStartTime();
    if (StringUtils.isEmpty(indStartTime)) {
      Long indKurCd = ord.getIndKurCd();
      indStartTime = mstKurDao.selectByKurCd(indKurCd.toString()).getKurStandardStartTime().substring(0,4);;
    }
    String startPlanDateStr = ord.getTreatDate() + indStartTime;
    // modify 10954 by kangjie 20240805 end

    Timestamp startPlanDate = Timestamp.valueOf(LocalDateTime.parse(startPlanDateStr, dateFormat));

    //FNSI-修正 ログ対応 wp add start

    String tableName = "mnt_machine_state";
    // SQL検索条件
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(" facility_cd = '" + machine.getFacilityCd() + "'" + "\n");
    wheres.append(" AND\n");
    wheres.append(" machine_type_cd = '" + machine.getMachineTypeCd() + "'" + "\n");
    wheres.append(" AND\n");
    wheres.append(" trim(machine_serial) = trim('" + machine.getMachineSerial() + "')" + "\n");

    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    //FNSI-修正 ログ対応 wp add end

    int ret = retCnt = mntMachineStateDao.updateNextPatInfo(machine.getFacilityCd(), machine.getMachineTypeCd(),
      machine.getMachineSerial(), ord.getPatId(), nextOrdNo, ord.getIndKurCd(), startPlanDate,
      new Timestamp(System.currentTimeMillis()));

    //FNSI-修正 ログ対応 wp add start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && ret > 0) {
      logCommon.updateLog();
    }
    //FNSI-修正 ログ対応 wp add end 20210128


    // 処理件数が1件でない場合は異常終了
    if (1 != retCnt) {
      String strMsg = "次患者更新処理に失敗しました(処理件数:" + retCnt + ")";
      throw new RuntimeException(strMsg);
    }

    return true;
  }

  /**
   * 体重測定履歴のステータス変更を行う(同オーダーと同装置の過去の履歴で指示中のままのものがあったらタイムアウトにする)
   *
   * @param cond 各パラメータ
   * @return
   */
  int updateOrdWeightTimeout(OrdWeightScale cond) {
    try {
      int ret = 0;
      if (!Objects.isNull(cond.getFacilityCd())
        && (!Objects.isNull(cond.getOrdNo()) || !Objects.isNull(cond.getMachineNo()))) {

        // DB更新ログ出力ロジック wangzuo Start
        String tableName = "ord_weight_scale";
        // SQL検索条件
        StringBuffer wheres = new StringBuffer("");
        wheres.append(" WHERE\n");
        wheres.append("facility_cd = '" + cond.getFacilityCd() + "'\n");
        wheres.append(" AND\n");
        wheres.append("/*%if " + cond.getOrdNo() + " != null && " + cond.getMachineNo() + " != null*/" + "\n");
        wheres.append("(ord_no = " + cond.getOrdNo() + " or machine_no = " + cond.getMachineNo() + ")\n");
        wheres.append(" AND\n");
        wheres.append("/*%elseif " + cond.getOrdNo() + " != null*/" + "\n");
        wheres.append("ord_no = " + cond.getOrdNo() + "\n");
        wheres.append(" AND\n");
        wheres.append("/*%elseif " + cond.getMachineNo() + " != null*/" + "\n");
        wheres.append("machine_no = " + cond.getMachineNo() + "\n");
        wheres.append(" AND\n");
        wheres.append("/*%end*/" + "\n");
        wheres.append("weight_scale_status = 1" + "\n");
        // logCommon設定
        DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
        // ログ出力カラム情報及び更新前データ情報取得
        boolean setResult = logCommon.setInfo();
        // DB更新ログ出力ロジック wangzuo End

        // 過去の同オーダーをすべてタイムアウトにする
        // 過去の同装置をすべてタイムアウトにする
        int updateCount = ordWeightScaleDao.updateOldDataTimeOut(cond.getFacilityCd(), cond.getOrdNo(), cond.getMachineNo());

        // DB更新ログ出力ロジック wangzuo Start
        // 更新後データ取得、差分あれば、log出力
        if (setResult && updateCount > 0) {
          logCommon.updateLog();
        }
        // DB更新ログ出力ロジック wangzuo End

        return updateCount;
      }
      return ret;
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (cond.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(cond.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      eventLogMessage.setSqlIdentification("(facilityCd = " + cond.getFacilityCd() + ", ordNo = " + cond.getOrdNo()
        + ", machineNo = " + cond.getMachineNo() + ")");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS,
        "OrdWeightScaleDao/updateOldDataTimeOut");
      return -1;
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public SendConditionResponse saveSendConditionOrdWeightScale(SendConditionRequest request, Short weightScaleStatus) {
    SendConditionResponse res = new SendConditionResponse();
    OrdWeightScale cond = new OrdWeightScale();
    try {
      // 測定履歴をステータスで記録する
      if (Objects.isNull(request.getOrdNo())) {
        cond = BuildOrdWeightScaleWeight(request, weightScaleStatus);
      } else {
        cond = BuildOrdWeightScaleInd(request, weightScaleStatus);
      }
      updateOrdWeightTimeout(cond);

      if (request.getWeightScaleNo() != null) {
        cond.setWeightScaleNo(request.getWeightScaleNo());
        // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
        LogEventUtils.setOperatorId(cond,logService);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
        // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
        if (ordWeightScaleDao.update(cond) > 0) {
          res.isSuccess = true;
          res.printWeightScaleNo = cond.getWeightScaleNo(); // 印刷対象
          // #11987 2026.02.11 add スケールベッド状態書込み TDC片口 start
          // この処理では「測定済み」状態なのでステータスは通常
          scaleBedStateService.updateSendStatusNormalize(request.getScaleBedBedCd(), true, cond.getWeightScaleNo(), cond.getScaleValue());
          // #11987 2026.02.11 add スケールベッド状態書込み TDC片口 end
          return res;
        }
      } else {
        if (ordWeightScaleDao.insert(cond) > 0) {
          res.isSuccess = true;
          res.printWeightScaleNo = cond.getWeightScaleNo(); // 印刷対象
          // #11987 2026.02.11 add スケールベッド状態書込み TDC片口 start
          // この処理では「測定済み」状態なのでステータスは通常
          scaleBedStateService.updateSendStatusNormalize(request.getScaleBedBedCd(), true, cond.getWeightScaleNo(), cond.getScaleValue());
          // #11987 2026.02.11 add スケールベッド状態書込み TDC片口 end
          return res;
        }
      }
      res.isSuccess = false;
      res.errorMessage = "測定記録書き込み失敗";
      return res;

    } catch (Exception ex) {
      // ロールバック実行
      throw new RuntimeException(ex.getMessage());
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public SendConditionResponse saveBeforeWeight(SendConditionRequest request) {
    SendConditionResponse res = new SendConditionResponse();
    try {
      if (request.getOrdNo() == null) {
        // 実績書き込み先がないのでそのまま成功とする
        res.isSuccess = true;
      } else {
        //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
//res = checkIsOrderCondConfirm(request.getOrdNo());
        res = checkIsOrderCondConfirm(request.getOrdNo(),request.getFacilityCd());
        //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
        if (res.isSuccess) {
          // スケジュールあり患者の場合はord_mainに実績保存
          saveOrdMainBeforeWeight(request);
        }
      }
      return res;
    } catch (Exception ex) {
      // ロールバック実行
      throw new RuntimeException(ex.getMessage());
    }
  }
  //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
//  private SendConditionResponse checkIsOrderCondConfirm(Long ordNo) {
  private SendConditionResponse checkIsOrderCondConfirm(Long ordNo,String facilityCd) {
    //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
    SendConditionResponse res = new SendConditionResponse();
    //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
//    OrdMainForWeightInd ord = ordMainDao.selectForWeightIndByOrdNo(ordNo);
    OrdMainForWeightInd ord = ordMainDao.selectForWeightIndByOrdNoAndFacilityCd(ordNo,facilityCd);
    //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
    ConditionState state = checkIsCanBeforeSendConditonState(ord.getRstDialysisState());
    if (state == ConditionState.USING) {
      res.isSuccess = false;
      res.errorMessage = "治療が始まっています";
      return res;
    }
    if (ord.getIndBedCd() != null && ord.getIndBedCd() > 0L) {
      // 条件から装置情報を取得
      List<MstMachine> machines = mstMachineDao.selectByBedCd(ord.getFacilityCd(), ord.getIndBedCd());
      if (machines.size() == 0) {
        res.isSuccess = false;
        res.errorMessage = "条件送信先装置の特定に失敗";
        return res;
      }
    }

    res.isSuccess = true;
    return res;

  }

  /**
   * ステータスが条件送信可能状態かどうかを返す
   *
   * @param state
   * @return
   */
  private ConditionState checkIsCanBeforeSendConditonState(String state) {
    if (Objects.equals(state, DialysisState.BEFORE_SEND) || Objects.equals(state, DialysisState.AFTER_SEND)) {
      return ConditionState.CAN_SEND;
    } else if (Objects.equals(state, DialysisState.CHECKED_SEND)) {
      return ConditionState.CHECKED_SEND;
    }
    return ConditionState.USING;
  }

  private enum ConditionState {
    CAN_SEND, CHECKED_SEND, USING
  }

  /**
   * 最後にCTRに値がセットされた患者個人身体情報を取得
   *
   * @param physicalInfo
   * @param baseDate     yyyyMMdd
   * @return
   */
  private PhysicalInfoItem lastCtrMeasure(PhysicalInfo physicalInfo, String baseDate) {

    LocalDateTime baseDateTime;
    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("uuuu-MM-dd'T'HH:mm:ssZZZ");
    DateTimeFormatter dtf2 = DateTimeFormatter.ofPattern("uuuu-MM-dd");
    if (Objects.isNull(baseDate)) {
      baseDateTime = LocalDate.now().plusDays(1).atTime(0, 0);
    } else {
      try {
        LocalDate localBaseDate = LocalDate.parse(baseDate, DateTimeFormatter.ofPattern("uuuuMMdd"));
        baseDateTime = localBaseDate.plusDays(1).atTime(0, 0);
      } catch (Exception ex) {
        baseDateTime = LocalDate.now().plusDays(1).atTime(0, 0);
      }
    }

    // 全記録格納フィールドを測定日時[ExaminDate]で降順ソート
    List<PhysicalInfoItem> records = physicalInfo.getAllRecords();
    records.sort((a, b) -> {
      String examDateA = a.getExamDate();
      String examDateB = b.getExamDate();
      if (examDateA.length() < 11) {
        examDateA += "T00:00:00.000+09:00";
      }
      if (examDateB.length() < 11) {
        examDateB += "T00:00:00.000+09:00";
      }
      Date A = DateTimeUtils.dateStringToDate_iso8601(examDateA);
      Date B = DateTimeUtils.dateStringToDate_iso8601(examDateB);
      return B.compareTo(A);
    });

    for (PhysicalInfoItem record : records) {
      LocalDateTime examDate;
      String examDateStr = record.getExamDate();
      if (examDateStr.length() < 11) {
        examDateStr += "T00:00:00.000+09:00";
      }
      try {
        Date A = DateTimeUtils.dateStringToDate_iso8601(examDateStr);
        Instant instant = A.toInstant();
        examDate = LocalDateTime.ofInstant(instant, ZoneId.systemDefault());
      } catch (Exception e) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
        logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.REMS, null);
        // 変換できない日付は未来にして対象外とする
        examDate = LocalDateTime.now().plusYears(10);
      }
      if (examDate.isAfter(baseDateTime) || examDate.isEqual(baseDateTime)) {
        // 基準日よりも後に登録したデータは無視
        continue;
      }
      if (record.getCtr() != null && !record.getCtr().isEmpty() && !Objects.equals(record.getCtr(), "null")) {
        // 最後にCTRに値がセットされている時点のレコード
        return record;
      }
    }
    return null;
  }

  /**
   * 前体重保存処理
   *
   * @param request
   * @throws IOException
   * @throws JacksonException
   * @throws JsonMappingException
   * @throws JacksonException
   */
  private void saveOrdMainBeforeWeight(SendConditionRequest request)
    throws IOException, JacksonException {
    // 対象オーダーの取得
    OrdMainForWeightInd ord = ordMainDao.selectForWeightIndByOrdNo(request.getOrdNo());
    String weight = ordMainDao.selectWeightInfo(request.getOrdNo());

    OrdMainRstWeightInfo dto = weight == null || weight.isEmpty() ? new OrdMainRstWeightInfo()
      : mapper.readValue(weight, OrdMainRstWeightInfo.class);

    // 対象患者の最新身体情報を取得
    List<Long> patIdList = new ArrayList<>();
    patIdList.add(request.getPatId());
    List<PatUnique> patUniqueList = patUniqueDao.selectByIdList(patIdList);
    PatUnique patUnique = new PatUnique();
    String dw = request.getDw();
    if (patUniqueList.size() > 0) {
      patUnique = patUniqueList.get(0);
      String physicalInfoStr = patUnique.getPhysical_info();
      if (physicalInfoStr != null && physicalInfoStr.length() != 0) {
        // 患者基本情報から身体情報を取得する
        PhysicalInfo physicalInfo = new PhysicalInfo(physicalInfoStr);
        //ctr
        PhysicalInfoItem ctrItem = lastCtrMeasure(physicalInfo, ord.getTreatDate());
        if (ctrItem != null) {
          try {
            dto.setCtr(new BigDecimal(ctrItem.getCtr()));
          } catch (NumberFormatException ex) {
            dto.setCtr(null);
          }
          try {
            // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
            //dto.setCtrWeight(new BigDecimal(ctrItem.getCtrWeight()));
            dto.setCtrWeight(ctrItem.getCtrWeight());
            // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
          } catch (NumberFormatException ex) {
            dto.setCtrWeight(null);
          }
          try {
            dto.setCtrMeasureDate(
              DateTimeUtils.getDateString_iso8601(DateTimeUtils.dateStringToDate_iso8601(ctrItem.getExamDate())));
          } catch (Exception ex) {
            dto.setCtrMeasureDate(null);
          }
        }
      }
    }
    // 前体重と前体重測定日時を体重実績に構築
    dto.setWeightBefore(request.getWeightValue()); // 前体重
    dto.setWeightBeforeDate(request.getMeasureDate()); // 前体重測定日時
    dto.setWeightMeasureBefore(request.getScaleValue()); // 前体重測定値
    dto.setWeightBeforeDate(request.getMeasureDate()); // 前体重測定日時
    dto.setWaterRemovalTarget(request.getTargetOffWater()); // 目標除水量

    Timestamp acceptDate = null;
    try {
      if (!Objects.isNull(request.getMeasureDate()) && !request.getMeasureDate().isEmpty()) {
        acceptDate = new Timestamp(DateTimeUtils.dateStringToDate_iso8601(request.getMeasureDate()).getTime());
      }
    } catch (Exception e) {
      acceptDate = Timestamp.valueOf(LocalDateTime.now());
    }

    // add FNSI-改修内容追加OrdMain履歴 付 start
    // mangoDb-updateBeforeWeight-insertSuccess
    getHistory(request.getOrdNo());
    // add FNSI-改修内容追加OrdMain履歴 付 end

    // 体重実績、車いす情報を含んだ風袋、除水補正、DWを実績に保存
    OrdMain oldOrdMain = ordMainDao.selectByOrdNo(request.getOrdNo());
    ordMainDao.updateBeforeWeightWithVariousTbl(request.getOrdNo(), mapper.writeValueAsString(dto), request.getOffWater(),
      BuildRstTareInfoWithWheelChair(request, rstTareCategory.BEFORE_AND_AFTER_TEMPLATE), acceptDate,
      dw);
    OrdMain newOrdMain = ordMainDao.selectByOrdNo(request.getOrdNo());
    triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain),
      Collections.singletonList(newOrdMain));

    // 前体重測定日時の保存[mnt_machine_state]
    MstMachine machine = getMachineByOrderInd(request.getOrdNo());
    if (machine != null) {
      //FNSI-修正 ログ対応 wp add start

      String tableName = "mnt_machine_state";
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" facility_cd = '" + machine.getFacilityCd() + "'" + "\n");
      wheres.append(" AND\n");
      wheres.append(" machine_type_cd = '" + machine.getMachineTypeCd() + "'" + "\n");
      wheres.append(" AND\n");
      wheres.append(" trim(machine_serial) = trim('" + machine.getMachineSerial() + "')" + "\n");
      // logCommon設定
      // logCommon設定
      DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResult = logCommon.setInfo();
      //FNSI-修正 ログ対応 wp add end
      int ret = mntMachineStateDao.updateWeighBeforeDate(machine.getFacilityCd(), machine.getMachineTypeCd(),
        machine.getMachineSerial(), acceptDate);

      //FNSI-修正 ログ対応 wp add start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && ret > 0) {
        logCommon.updateLog();
      }
      //FNSI-修正 ログ対応 wp add end 20210128
    }

    // add FNSI-改修内容追加OrdMain履歴 付 start
    // mangoDb-updateWeightScaleNo-insertSuccess
    getHistory(request.getOrdNo());
    // add FNSI-改修内容追加OrdMain履歴 付 end

    // DB更新ログ出力ロジック wangzuo Start
    String tableName = "ord_main";
    // SQL検索条件
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(" ord_no = " + request.getOrdNo() + "\n");
    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    // DB更新ログ出力ロジック wangzuo End

    // 体重＋車いす一時状態の主キーを削除
    oldOrdMain = ordMainDao.selectByOrdNo(request.getOrdNo());
    int updateCount = ordMainDao.updateWeightScaleNo(request.getOrdNo(), null);
    newOrdMain = ordMainDao.selectByOrdNo(request.getOrdNo());
    triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain),
      Collections.singletonList(newOrdMain));

    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      logCommon.updateLog();
    }
    // DB更新ログ出力ロジック wangzuo End
  }

  // add FNSI-改修内容追加OrdMain履歴 付 start
  private void getHistory(Long ordNo) {
    selectHistoryUtils.insertMangoDbHistory(1, ordNo, null, new ArrayList<>(), new ArrayList<>(), null, null,
      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
      new ArrayList<>(), null, null);
  }
  // add FNSI-改修内容追加OrdMain履歴 付 end

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public OrdWeightScale insertOrdWeight(SendConditionRequest request, Short weightScaleStatus) throws IOException {
    OrdWeightScale cond = new OrdWeightScale();
    try {
      // 履歴のみ保存
      cond = BuildOrdWeightScaleWeight(request, weightScaleStatus);
      if (ordWeightScaleDao.insert(cond) > 0) {
        return cond;
      }
      return null;

    } catch (Exception ex) {
      // ロールバック実行
      throw new RuntimeException(ex.getMessage());
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public OrdWeightScale insertSendConditionWeightAndChair(SendConditionRequest request, Short weightScaleStatus)
    throws IOException {

    try {
      // 条件送信履歴に測定履歴をステータスで記録する
      OrdWeightScale cond = BuildOrdWeightScaleInd(request, weightScaleStatus);
      cond.setMessage("車いす未測定");
      boolean isOk = false;

      if (request.getWeightScaleNo() != null) {
        cond.setWeightScaleNo(request.getWeightScaleNo());
        // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
        LogEventUtils.setOperatorId(cond,logService);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
        // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
        isOk = (ordWeightScaleDao.update(cond) > 0);
      } else {
        isOk = (ordWeightScaleDao.insert(cond) > 0);
      }
      if (isOk) {
        // add FNSI-改修内容追加OrdMain履歴 付 start
        // mangoDb-updateWeightScaleNo-insertSuccess
        getHistory(request.getOrdNo());
        // add FNSI-改修内容追加OrdMain履歴 付 end

        // DB更新ログ出力ロジック wangzuo Start
        String tableName = "ord_main";
        // SQL検索条件
        StringBuffer wheres = new StringBuffer("");
        wheres.append(" WHERE\n");
        wheres.append(" ord_no = " + request.getOrdNo() + "\n");
        // logCommon設定
        DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
        // ログ出力カラム情報及び更新前データ情報取得
        boolean setResult = logCommon.setInfo();
        // DB更新ログ出力ロジック wangzuo End

        // 体重＋車いす一時状態の主キーを保存
        OrdMain oldOrdMain = ordMainDao.selectByOrdNo(request.getOrdNo());
        int updateCount = ordMainDao.updateWeightScaleNo(request.getOrdNo(), cond.getWeightScaleNo());
        OrdMain newOrdMain = ordMainDao.selectByOrdNo(request.getOrdNo());
        triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain),
          Collections.singletonList(newOrdMain));

        // DB更新ログ出力ロジック wangzuo Start
        // 更新後データ取得、差分あれば、log出力
        if (setResult && updateCount > 0) {
          logCommon.updateLog();
        }
        // DB更新ログ出力ロジック wangzuo End

        return cond;
      }
      return null;

    } catch (Exception ex) {
      // ロールバック実行
      throw new RuntimeException(ex.getMessage());
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public OrdWeightScale insertSendConditionChairInfo(SendConditionRequest request, Short weightScaleStatus) {

    try {
      // 条件送信履歴に測定履歴をステータスで記録する

      OrdWeightScale cond = BuildOrdWeightScaleInd(request, weightScaleStatus);
      cond.setWeightValue(null);
      // FNSI-add 透析中測定値の修正 徐 start
//      cond.setScaleValue(null);
      //mod #12236 【因島】体重測定の動作不正 zrx start
//      cond.setScaleValue(request.getScaleValue().divide(new BigDecimal(1000), 2, BigDecimal.ROUND_FLOOR));
      BigDecimal scaleValue = request.getScaleValue();
      if (scaleValue != null) {
        cond.setScaleValue(scaleValue.divide(new BigDecimal(1000), 2, BigDecimal.ROUND_FLOOR));
      } else {
        cond.setScaleValue(null);
      }
      //mod #12236 因島】体重測定の動作不正 zrx end
      // FNSI-add 透析中測定値の修正 徐 end
      // add FNSI-メッセージ修正 トウ start
      cond.setMessage("体重＋車いす未測定");
      // add FNSI-メッセージ修正 トウ end
      boolean isOk = false;

      if (request.getWeightScaleNo() != null) {
        cond.setWeightScaleNo(request.getWeightScaleNo());
        // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
        LogEventUtils.setOperatorId(cond,logService);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
        // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
        isOk = (ordWeightScaleDao.update(cond) > 0);
      } else {
        isOk = (ordWeightScaleDao.insert(cond) > 0);
      }
      if (isOk) {


        // add FNSI-改修内容追加OrdMain履歴 付 start
        // mangoDb-updateWeightScaleNo-insertSuccess
        getHistory(request.getOrdNo());
        // add FNSI-改修内容追加OrdMain履歴 付 end

        // DB更新ログ出力ロジック wangzuo Start
        String tableName = "ord_main";
        // SQL検索条件
        StringBuffer wheres = new StringBuffer("");
        wheres.append(" WHERE\n");
        wheres.append(" ord_no = " + request.getOrdNo() + "\n");
        // logCommon設定
        DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
        // ログ出力カラム情報及び更新前データ情報取得
        boolean setResult = logCommon.setInfo();
        // DB更新ログ出力ロジック wangzuo End

        // 体重＋車いす一時状態の主キーを保存
        OrdMain oldOrdMain = ordMainDao.selectByOrdNo(request.getOrdNo());
        int updateCount = ordMainDao.updateWeightScaleNo(request.getOrdNo(), cond.getWeightScaleNo());
        OrdMain newOrdMain = ordMainDao.selectByOrdNo(request.getOrdNo());
        triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain),
          Collections.singletonList(newOrdMain));

        // DB更新ログ出力ロジック wangzuo Start
        // 更新後データ取得、差分あれば、log出力
        if (setResult && updateCount > 0) {
          logCommon.updateLog();
        }
        // DB更新ログ出力ロジック wangzuo End

        return cond;
      }
      return null;

    } catch (Exception ex) {
      // ロールバック実行
      throw new RuntimeException(ex.getMessage());
    }
  }

  /**
   * 車いすのみ風袋JSON
   */
  public class RstTareInfoWheelChair {
    public Long wheel_chair_cd;
    public String wheel_chair_name;
    public BigDecimal wheel_chair_weight;
  }

  /**
   * 風袋実績カテゴリ
   */
  private enum rstTareCategory {
    BAFORE, AFTER, BEFORE_AND_AFTER_TEMPLATE
  }

  /**
   * 風袋実績JSON文字列の作成
   *
   * @param request
   * @param category
   * @return
   */
  private String BuildRstTareInfoWheelChair(SendConditionRequest request, rstTareCategory category) {
    RstTareInfoWheelChair rstWheelChair = new RstTareInfoWheelChair();
    rstWheelChair.wheel_chair_cd = request.getWheelChairCd();
    rstWheelChair.wheel_chair_name = request.getWheelChairName();
    rstWheelChair.wheel_chair_weight = request.getWheelChairWeight();

    String keyBefore = "before";
    String keyAfter = "after";

    if (category == rstTareCategory.BEFORE_AND_AFTER_TEMPLATE) {
      String rstWheelChairStrBefore;
      String rstWheelChairStrAfter;
      try {
        rstWheelChairStrBefore = mapper.writeValueAsString(rstWheelChair);

        rstWheelChair.wheel_chair_cd = null;
        rstWheelChair.wheel_chair_name = null;
        rstWheelChair.wheel_chair_weight = null;
        rstWheelChairStrAfter = mapper.writeValueAsString(rstWheelChair);
      } catch (JacksonException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        if (request != null && !StringUtils.isEmpty(request.getFacilityCd())) {
          eventLogMessage.setFacilityCd(request.getFacilityCd());
        }
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
        rstWheelChairStrBefore = "{}";
        rstWheelChairStrAfter = "{}";
      }
      return "{\"" + keyBefore + "\":" + rstWheelChairStrBefore + ", \"" + keyAfter + "\":" + rstWheelChairStrAfter
        + "}";

    } else {
      String rstWheelChairStr;
      String categoryName = category == rstTareCategory.BAFORE ? keyBefore : keyAfter;
      try {
        rstWheelChairStr = mapper.writeValueAsString(rstWheelChair);
      } catch (JacksonException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        if (request != null && !StringUtils.isEmpty(request.getFacilityCd())) {
          eventLogMessage.setFacilityCd(request.getFacilityCd());
        }
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
        rstWheelChairStr = "{}";
      }
      return "{\"" + categoryName + "\":" + rstWheelChairStr + "}";

    }
  }

  /**
   * 風袋実績JSON文字列の作成
   *
   * @param request
   * @param category
   * @return
   */
  private String BuildRstTareInfoWithWheelChair(SendConditionRequest request, rstTareCategory category) {
    TareOrOffWaterJson tareJson = buidlTareOrOffWaterJson(request.getTare());
    OrdMainRstTareChild rstWheelChair = new OrdMainRstTareChild();
    rstWheelChair.setWheelChairCd(request.getWheelChairCd());
    rstWheelChair.setWheelChairName(request.getWheelChairName());
    rstWheelChair.setWheelChairWeight(request.getWheelChairWeight());
    rstWheelChair.setName_1(tareJson.getName_1());
    rstWheelChair.setName_2(tareJson.getName_2());
    rstWheelChair.setName_3(tareJson.getName_3());
    rstWheelChair.setName_4(tareJson.getName_4());
    rstWheelChair.setName_5(tareJson.getName_5());
    rstWheelChair.setWeight_1(tareJson.getWeight_1());
    rstWheelChair.setWeight_2(tareJson.getWeight_2());
    rstWheelChair.setWeight_3(tareJson.getWeight_3());
    rstWheelChair.setWeight_4(tareJson.getWeight_4());
    rstWheelChair.setWeight_5(tareJson.getWeight_5());

    String keyBefore = "before";
    String keyAfter = "after";

    if (category == rstTareCategory.BEFORE_AND_AFTER_TEMPLATE) {
      String rstWheelChairStrBefore;
      String rstWheelChairStrAfter;
      try {
        rstWheelChairStrBefore = mapper.writeValueAsString(rstWheelChair);

        rstWheelChair.setWheelChairCd(null);
        rstWheelChair.setWheelChairName(null);
        rstWheelChair.setWheelChairWeight(null);
        rstWheelChairStrAfter = mapper.writeValueAsString(rstWheelChair);
      } catch (JacksonException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          if (request != null && !StringUtils.isEmpty(request.getFacilityCd())) {
            eventLogMessage.setFacilityCd(request.getFacilityCd());
          }
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
        rstWheelChairStrBefore = "{}";
        rstWheelChairStrAfter = "{}";
      }
      return "{\"" + keyBefore + "\":" + rstWheelChairStrBefore + ", \"" + keyAfter + "\":" + rstWheelChairStrAfter
        + "}";

    } else {
      String rstWheelChairStr;
      String categoryName = category == rstTareCategory.BAFORE ? keyBefore : keyAfter;
      try {
        rstWheelChairStr = mapper.writeValueAsString(rstWheelChair);
      } catch (JacksonException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          if (request != null && !StringUtils.isEmpty(request.getFacilityCd())) {
            eventLogMessage.setFacilityCd(request.getFacilityCd());
          }
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
        rstWheelChairStr = "{}";
      }
      return "{\"" + categoryName + "\":" + rstWheelChairStr + "}";

    }
  }

  /**
   * 風袋・除水補正のJSON分解
   *
   * @param jsonStr
   * @return
   */
  private TareOrOffWaterJson buidlTareOrOffWaterJson(String jsonStr) {
    TareOrOffWaterJson ret = new TareOrOffWaterJson();
    try {
      ret = jsonStr == null || jsonStr.isEmpty() ? new TareOrOffWaterJson()
        : mapper.readValue(jsonStr, TareOrOffWaterJson.class);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }
    return ret;
  }

  private OrdWeightScale BuildOrdWeightScaleInd(SendConditionRequest request, Short weightScaleStatus) {

    OrdWeightScaleBuildInfo ordCondBuild = ordMainDao.selectWithTreatInfo(request.getOrdNo());
    OrdWeightScale cond = new OrdWeightScale();

    Timestamp measureDate = null;
    try {
      if (!Objects.isNull(request.getMeasureDate()) && !request.getMeasureDate().isEmpty()) {
        measureDate = new Timestamp(DateTimeUtils.dateStringToDate_iso8601(request.getMeasureDate()).getTime());
      }
    } catch (Exception e) {
      measureDate = Timestamp.valueOf(LocalDateTime.now());
    }

    cond.setOrdNo(request.getOrdNo());
    cond.setFacilityCd(request.getFacilityCd());
    cond.setMachineNo(ordCondBuild.getMachineNo());
    cond.setMachineName(ordCondBuild.getMachineName());
    cond.setMeasureDate(measureDate);
    cond.setPatId(ordCondBuild.getPatId());
    cond.setKurCd(request.getKurCd());
    cond.setKurName(request.getKurName());
    cond.setBedCd(request.getBedCd());
    cond.setBedName(request.getBedName());
    cond.setOffWaterLimit(request.getLimitOffWater());
    cond.setRstOffWaterInfo(request.getOffWater());
    cond.setRstTareInfo(request.getTare());
    cond.setWeightCd(request.getWeightCd());
    cond.setWeightName(request.getWeightName());
    cond.setScaleClass(request.getScaleClass());
    cond.setScaleMode(request.getScaleMode());
    cond.setScaleValue(request.getScaleValue());
    cond.setWeightScaleStatus(weightScaleStatus); // 状態
    cond.setTargetWeightValue(request.getTargetWeight());
    cond.setUserId(request.getUserId());
    cond.setWeightValue(request.getWeightValue());
    cond.setWheelChairCd(request.getWheelChairCd());
    cond.setWheelChairName(request.getWheelChairName());
    cond.setWheelChairWeight(request.getWheelChairWeight());
    cond.setTreatmentCd(request.getTreatmentCd());
    cond.setTreatmentName(request.getTreatmentName());
    cond.setDeviceMode(request.getDeviceMode());
    if (Objects.equals(request.getIsPrint(), FlagType.FLAG_ON)) {
      cond.setPrintStatus(1);
      cond.setPrintContent(request.getPrintContent());
    } else {
      cond.setPrintStatus(0);
    }

    return cond;
  }

  /**
   * 指示のない場合の測定記録残し
   *
   * @param request
   * @param weightScaleStatus
   * @return
   */
  private OrdWeightScale BuildOrdWeightScaleWeight(SendConditionRequest request, Short weightScaleStatus) {

    Timestamp measureDate = null;
    try {
      if (!Objects.isNull(request.getMeasureDate()) && !request.getMeasureDate().isEmpty()) {
        measureDate = new Timestamp(DateTimeUtils.dateStringToDate_iso8601(request.getMeasureDate()).getTime());
      }
    } catch (Exception e) {
      measureDate = Timestamp.valueOf(LocalDateTime.now());
    }

    OrdWeightScale cond = new OrdWeightScale();
    cond.setOrdNo(request.getOrdNo());
    cond.setFacilityCd(request.getFacilityCd());
    cond.setMachineNo(null);
    cond.setMeasureDate(measureDate);
    cond.setPatId(request.getPatId());
    cond.setKurCd(request.getKurCd());
    cond.setKurName(request.getKurName());
    cond.setBedCd(request.getBedCd());
    cond.setBedName(request.getBedName());
    cond.setOffWaterLimit(request.getLimitOffWater());
    cond.setRstOffWaterInfo(request.getOffWater());
    cond.setRstTareInfo(request.getTare());
    cond.setWeightCd(request.getWeightCd());
    cond.setWeightName(request.getWeightName());
    cond.setScaleClass(request.getScaleClass());
    cond.setScaleMode(request.getScaleMode());
    cond.setScaleValue(request.getScaleValue());
    cond.setWeightScaleStatus(weightScaleStatus); // 状態
    cond.setTargetWeightValue(request.getTargetWeight());
    cond.setUserId(request.getUserId());
    cond.setWeightValue(request.getWeightValue());
    cond.setWheelChairCd(request.getWheelChairCd());
    cond.setWheelChairName(request.getWheelChairName());
    cond.setWheelChairWeight(request.getWheelChairWeight());
    cond.setTreatmentCd(request.getTreatmentCd());
    cond.setTreatmentName(request.getTreatmentName());
    cond.setDeviceMode(request.getDeviceMode());
    if (Objects.equals(request.getIsPrint(), FlagType.FLAG_ON)) {
      cond.setPrintStatus(1);
      cond.setPrintContent(request.getPrintContent());
    } else {
      cond.setPrintStatus(0);
    }

    return cond;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public OrdWeightScale fetchLastWeightScale(Long ordNo, Short scaleClass) {
    // 日付
    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
    String today = sdf.format(new Date());

    // 測定履歴の取得1 同一のord_noおよび区分（前・後）のうち最新の測定履歴
    OrdWeightScale weightScale = null;
    weightScale = ordWeightScaleDao.selectLastHistoryByScaleClass(ordNo, scaleClass);

    // 測定履歴が取得できないとき、前体重であれば別ord_noやスケジュールなし履歴を参照
    if (weightScale == null && scaleClass.equals((short)0)) {
      // 測定履歴の取得2 同一ord_no(＝スケジュールあり)の同日の前体重履歴
      weightScale = ordWeightScaleDao.selectLastHistoryByOrdNoSameDay(ordNo, today);

      if (weightScale == null) {
        // ordNoに紐づくordMainの取得
        OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);

        // 測定履歴の取得3 同一患者の別ord_noの同日の前体重履歴
        OrdWeightScale weightScale3 = null;
        weightScale3 = ordWeightScaleDao.selectLastHistoryAnotherOrdNoSameDay(ordNo, ordMain.getPatId(), today);
        // 測定履歴の取得4 スケジュールなし履歴の同日の前体重履歴
        OrdWeightScale weightScale4 = null;
        // mod #7716 2022/11/18 患者の体重測定値にも値が入力されてしまっている(何の値か不明) dou start
        // weightScale4 = ordWeightScaleDao.selectLastHistoryByPatIdNoSchedule(ordMain.getPatId());
        weightScale4 = ordWeightScaleDao.selectLastHistoryByPatIdAndToday(ordMain.getPatId(), today);
        // mod #7716 2022/11/18 患者の体重測定値にも値が入力されてしまっている(何の値か不明) dou end
        if (weightScale3 == null && weightScale4 == null) {
          weightScale = null;
        } else if (weightScale3 == null) {
          weightScale = weightScale4;
        } else if (weightScale4 == null) {
          weightScale = weightScale3;
        } else if (weightScale3.getMeasureDate().after(weightScale4.getMeasureDate())) {
          // 同一患者の別ord_noの同日の前体重履歴 が スケジュールなし履歴の同日の前体重履歴 よりも新しい
          weightScale = weightScale3;
        } else {
          // スケジュールなし履歴の同日の前体重履歴 が 同一患者の別ord_noの同日の前体重履歴 よりも新しい
          weightScale = weightScale4;
        }
      }
    }

    return weightScale;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public OrdWeightScale fetchLastScaleNoSchedule(Long patId) {
    return ordWeightScaleDao.selectLastHistoryByPatIdNoSchedule(patId);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public OrdWeightScale fetchTargetWeightScale(Long weightScaleCd) {
    return ordWeightScaleDao.selectByCd(weightScaleCd);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public OrdWeightScale insertSendAfterWeightInfo(SendConditionRequest request, Short weightScaleStatus)
    throws IOException {

    try {
      // 対象オーダーの取得
      String weight = ordMainDao.selectWeightInfo(request.getOrdNo());
      OrdWeightScaleBuildInfo ordCondBuild = ordMainDao.selectWithTreatInfo(request.getOrdNo());

      Timestamp measureDate = null;
      try {
        if (!Objects.isNull(request.getMeasureDate()) && !request.getMeasureDate().isEmpty()) {
          measureDate = new Timestamp(DateTimeUtils.dateStringToDate_iso8601(request.getMeasureDate()).getTime());
        }
      } catch (Exception e) {
        measureDate = Timestamp.valueOf(LocalDateTime.now());
      }
      // 後体重測定日時の保存[mnt_machine_state]
      MstMachine machine = getMachineByOrderRst(request.getOrdNo());
      if (machine != null) {

        //FNSI-修正 ログ対応 wp add start

        String tableName = "mnt_machine_state";
        // SQL検索条件
        StringBuffer wheres = new StringBuffer("");
        wheres.append(" WHERE\n");
        wheres.append(" facility_cd = '" + machine.getFacilityCd() + "'" + "\n");
        wheres.append(" AND\n");
        wheres.append(" machine_type_cd = '" + machine.getMachineTypeCd() + "'" + "\n");
        wheres.append(" AND\n");
        wheres.append(" trim(machine_serial) = trim('" + machine.getMachineSerial() + "')" + "\n");

        // logCommon設定
        DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
        // ログ出力カラム情報及び更新前データ情報取得
        boolean setResult = logCommon.setInfo();
        //FNSI-修正 ログ対応 wp add end

        int ret = mntMachineStateDao.updateWeighAfterDate(machine.getFacilityCd(), machine.getMachineTypeCd(),
          machine.getMachineSerial(), measureDate);

        //FNSI-修正 ログ対応 wp add start
        // 更新後データ取得、差分あれば、log出力
        if (setResult && ret > 0) {
          logCommon.updateLog();
        }
        //FNSI-修正 ログ対応 wp add end 20210128

      }

      // 後体重と後体重測定日時の保存[ord_main]
      OrdMainRstWeightInfo dto = weight == null || weight.isEmpty() ? new OrdMainRstWeightInfo()
        : mapper.readValue(weight, OrdMainRstWeightInfo.class);
      dto.setWeightAfter(request.getWeightValue()); // 後体重
      dto.setWeightAfterDate(request.getMeasureDate()); // 後体重測定日時
      dto.setWeightMeasureAfter(request.getScaleValue()); // 後体重測定値
      if (dto.getWeightBefore() != null) {
        dto.setWeightDecreased(dto.getWeightBefore().subtract(dto.getWeightAfter()));
      }

      // add FNSI-改修内容追加OrdMain履歴 付 start
      // mangoDb-updateWeightInfo-insertSuccess
      getHistory(request.getOrdNo());
      // add FNSI-改修内容追加OrdMain履歴 付 end

      OrdMain oldOrdMain = ordMainDao.selectByOrdNo(request.getOrdNo());
      ordMainDao.updateWeightInfo(request.getOrdNo(), mapper.writeValueAsString(dto));
      OrdMain newOrdMain = ordMainDao.selectByOrdNo(request.getOrdNo());
      triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain),
        Collections.singletonList(newOrdMain));

      // add FNSI-改修内容追加OrdMain履歴 付 start
      // mangoDb-updateReturnHomeDateAndState-insertSuccess
      getHistory(request.getOrdNo());
      // add FNSI-改修内容追加OrdMain履歴 付 end

      // DB更新ログ出力ロジック wangzuo Start
      String tableName = "ord_main";
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" ord_no = " + request.getOrdNo() + "\n");
      // logCommon設定
      DataUpdateLogCommonNew logCommon1 = getLogCommon(tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResult = logCommon1.setInfo();
      // DB更新ログ出力ロジック wangzuo End

      // 帰宅日時の保存と、治療状況の更新[ord_main]
      oldOrdMain = ordMainDao.selectByOrdNo(request.getOrdNo());
      int updateCount = ordMainDao.updateReturnHomeDateAndState(request.getOrdNo(), measureDate,
        rstDialysisState.AFTER_WEIGHT);
      newOrdMain = ordMainDao.selectByOrdNo(request.getOrdNo());
      triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain),
        Collections.singletonList(newOrdMain));

      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      // del #8642 「治療記録>変更履歴の内容が不正」について、対応する。 dengshen start
      // if (setResult && updateCount > 0) {
      //   logCommon1.updateLog();
      // }
      // del #8642 「治療記録>変更履歴の内容が不正」について、対応する。 dengshen end
      // DB更新ログ出力ロジック wangzuo End

      // 風袋実績記録[ord_main]
      if (request.getTareFlg() != null && request.getTareFlg().intValue() == 1) {

        // add FNSI-改修内容追加OrdMain履歴 付 start
        // mangoDb-updateRstTare-insertSuccess
        getHistory(request.getOrdNo());
        // add FNSI-改修内容追加OrdMain履歴 付 end

        // 車いす情報と風袋を同時に保存
        oldOrdMain = ordMainDao.selectByOrdNo(request.getOrdNo());
        ordMainDao.updateRstTare(request.getOrdNo(), BuildRstTareInfoWithWheelChair(request, rstTareCategory.AFTER));
        newOrdMain = ordMainDao.selectByOrdNo(request.getOrdNo());
        triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain),
          Collections.singletonList(newOrdMain));
      } else {

        // add FNSI-改修内容追加OrdMain履歴 付 start
        // mangoDb-updateRstTare-insertSuccess
        getHistory(request.getOrdNo());
        // add FNSI-改修内容追加OrdMain履歴 付 end

        // 車いす情報を実績に保存
        oldOrdMain = ordMainDao.selectByOrdNo(request.getOrdNo());
        ordMainDao.updateRstTare(request.getOrdNo(), BuildRstTareInfoWheelChair(request, rstTareCategory.AFTER));
        newOrdMain = ordMainDao.selectByOrdNo(request.getOrdNo());
        triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain),
          Collections.singletonList(newOrdMain));
      }

      // 除水補正実績記録[ord_main]
      if (request.getOffWaterFlg() > 0) {

        // add FNSI-改修内容追加OrdMain履歴 付 start
        getHistory(request.getOrdNo());
        // mangoDb-updateRstOffWater-insertSuccess
        // add FNSI-改修内容追加OrdMain履歴 付 end
        oldOrdMain = ordMainDao.selectByOrdNo(request.getOrdNo());
        ordMainDao.updateRstOffWater(request.getOrdNo(), request.getOffWater());
        newOrdMain = ordMainDao.selectByOrdNo(request.getOrdNo());
        triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain),
          Collections.singletonList(newOrdMain));
      }

      // 除水補正指示記録[ord_main]
      if (request.getOffWaterFlg() != null && request.getOffWaterFlg().intValue() == 2) {

        // add FNSI-改修内容追加OrdMain履歴 付 start
        getHistory(request.getOrdNo());
        // mangoDb-updateIndStartTareAndOffWater-insertSuccess
        // add FNSI-改修内容追加OrdMain履歴 付 end

        // DB更新ログ出力ロジック wangzuo Start
        // logCommon設定
        DataUpdateLogCommonNew logCommon2 = getLogCommon(tableName, wheres, getEventLogMessage());
        // ログ出力カラム情報及び更新前データ情報取得
        setResult = logCommon2.setInfo();
        // DB更新ログ出力ロジック wangzuo End

        oldOrdMain = ordMainDao.selectByOrdNo(request.getOrdNo());
        updateCount = ordMainDao.updateIndStartTareAndOffWater(request.getOrdNo(), request.getOffWater(), null);
        newOrdMain = ordMainDao.selectByOrdNo(request.getOrdNo());
        triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain),
          Collections.singletonList(newOrdMain));

        // DB更新ログ出力ロジック wangzuo Start
        // 更新後データ取得、差分あれば、log出力
        if (setResult && updateCount > 0) {
          logCommon2.updateLog();
        }
        // DB更新ログ出力ロジック wangzuo End
      }

      // pat_mainのacceptance_status_infoを更新する。
      patMainAcceptanceStatusInfoService.update(ordCondBuild.getPatId(), request.getOrdNo(), rstDialysisState.AFTER_WEIGHT, null, null);

      // add FNSI-改修内容追加OrdMain履歴 付 start
      getHistory(request.getOrdNo());
      // mangoDb-updateWeightScaleNo-insertSuccess
      // add FNSI-改修内容追加OrdMain履歴 付 end

      // DB更新ログ出力ロジック wangzuo Start
      // logCommon設定
      DataUpdateLogCommonNew logCommon3 = getLogCommon(tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      setResult = logCommon3.setInfo();
      // DB更新ログ出力ロジック wangzuo End

      // 体重＋車いす一時状態の主キーを削除
      oldOrdMain = ordMainDao.selectByOrdNo(request.getOrdNo());
      updateCount = ordMainDao.updateWeightScaleNo(request.getOrdNo(), null);
      newOrdMain = ordMainDao.selectByOrdNo(request.getOrdNo());
      triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain),
        Collections.singletonList(newOrdMain));

      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && updateCount > 0) {
        logCommon3.updateLog();
      }
      // DB更新ログ出力ロジック wangzuo End

      // 体重計測定記録に測定履歴をステータスで記録する[ord_weight_scale]
      OrdWeightScale cond = new OrdWeightScale();
      cond.setOrdNo(request.getOrdNo());
      cond.setFacilityCd(request.getFacilityCd());
      cond.setMachineNo(ordCondBuild.getMachineNo());
      cond.setMachineName(ordCondBuild.getMachineName());
      cond.setMeasureDate(measureDate);
      cond.setPatId(ordCondBuild.getPatId());
      cond.setKurCd(ordCondBuild.getRstKurCd());
      cond.setKurName(ordCondBuild.getRstKurName());
      cond.setBedCd(ordCondBuild.getRstBedCd());
      cond.setBedName(ordCondBuild.getRstBedName());
      cond.setOffWaterLimit(request.getLimitOffWater());
      cond.setRstOffWaterInfo(request.getOffWater());
      cond.setRstTareInfo(request.getTare());
      cond.setWeightCd(request.getWeightCd());
      cond.setWeightName(request.getWeightName());
      cond.setScaleClass(request.getScaleClass());
      cond.setScaleMode(request.getScaleMode());
      cond.setScaleValue(request.getScaleValue());
      cond.setWeightScaleStatus(weightScaleStatus); // 測定済み
      cond.setTargetWeightValue(request.getTargetWeight());
      cond.setUserId(request.getUserId());
      cond.setWeightValue(request.getWeightValue());
      cond.setWheelChairCd(request.getWheelChairCd());
      cond.setWheelChairName(request.getWheelChairName());
      cond.setWheelChairWeight(request.getWheelChairWeight());
      cond.setTreatmentCd(request.getTreatmentCd());
      cond.setTreatmentName(request.getTreatmentName());
      cond.setDeviceMode(request.getDeviceMode());
      if (Objects.equals(request.getIsPrint(), FlagType.FLAG_ON)) {
        cond.setPrintStatus(1);
        cond.setPrintContent(request.getPrintContent());
      } else {
        cond.setPrintStatus(0);
      }

      if (request.getWeightScaleNo() != null) {
        cond.setWeightScaleNo(request.getWeightScaleNo());
        // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
        LogEventUtils.setOperatorId(cond,logService);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
        // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
        if (ordWeightScaleDao.update(cond) > 0) {
          return cond;
        }
      } else {
        if (ordWeightScaleDao.insert(cond) > 0) {
          return cond;
        }
      }
      return null;

    } catch (Exception ex) {
      // ロールバック実行
      throw new RuntimeException(ex.getMessage());
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public OrdWeightScaleBuildInfo updateStateAfterWeight(Long ordNo, String facilityCd) {

    try {
      // 対象オーダーの取得
      String weight = ordMainDao.selectWeightInfo(ordNo);
      OrdWeightScaleBuildInfo ordCondBuild = ordMainDao.selectWithTreatInfo(ordNo);
      OrdMainRstWeightInfo dto = Objects.isNull(weight) || weight.isEmpty() ? new OrdMainRstWeightInfo()
        : mapper.readValue(weight, OrdMainRstWeightInfo.class);

      Timestamp weightAfterDate = null;
      try {
        if (!Objects.isNull(dto.getWeightAfterDate()) && !dto.getWeightAfterDate().isEmpty()) {
          weightAfterDate = new Timestamp(DateTimeUtils.dateStringToDate_iso8601(dto.getWeightAfterDate()).getTime());
        }
      } catch (Exception e) {
        weightAfterDate = Timestamp.valueOf(LocalDateTime.now());
      }
      // 後体重測定日時の保存[mnt_machine_state]
      MstMachine machine = getMachineByOrderRst(ordNo);
      if (machine != null) {

        //FNSI-修正 ログ対応 wp add start


        String tableName = "mnt_machine_state";
        // SQL検索条件
        StringBuffer wheres = new StringBuffer("");
        wheres.append(" WHERE\n");
        wheres.append(" facility_cd = '" + machine.getFacilityCd() + "'" + "\n");
        wheres.append(" AND\n");
        wheres.append(" machine_type_cd = '" + machine.getMachineTypeCd() + "'" + "\n");
        wheres.append(" AND\n");
        wheres.append(" trim(machine_serial) = trim('" + machine.getMachineSerial() + "')" + "\n");
        // logCommon設定
        // logCommon設定
        DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
        // ログ出力カラム情報及び更新前データ情報取得
        boolean setResult = logCommon.setInfo();
        //FNSI-修正 ログ対応 wp add end

        int ret = mntMachineStateDao.updateWeighAfterDate(machine.getFacilityCd(), machine.getMachineTypeCd(),
          machine.getMachineSerial(), weightAfterDate);

        //FNSI-修正 ログ対応 wp add start
        // 更新後データ取得、差分あれば、log出力
        if (setResult && ret > 0) {
          logCommon.updateLog();
        }
        //FNSI-修正 ログ対応 wp add end 20210128
      }

      // add FNSI-改修内容追加OrdMain履歴 付 start
      getHistory(ordNo);
      // mangoDb-updateReturnHomeDateAndState-insertSuccess
      // add FNSI-改修内容追加OrdMain履歴 付 end

      // DB更新ログ出力ロジック wangzuo Start
      String tableName = "ord_main";
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" ord_no = " + ordNo + "\n");
      // logCommon設定
      DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResult = logCommon.setInfo();
      // DB更新ログ出力ロジック wangzuo End

      // 帰宅日時の保存と、治療状況の更新[ord_main]
      OrdMain oldOrdMain = ordMainDao.selectByOrdNo(ordNo);
      int updateCount = ordMainDao.updateReturnHomeDateAndState(ordNo, weightAfterDate, rstDialysisState.AFTER_WEIGHT);
      OrdMain newOrdMain = ordMainDao.selectByOrdNo(ordNo);
      triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain),
        Collections.singletonList(newOrdMain));

      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && updateCount > 0) {
        logCommon.updateLog();
      }
      // DB更新ログ出力ロジック wangzuo End

      // pat_mainのacceptance_status_infoを更新する。
      patMainAcceptanceStatusInfoService.update(ordCondBuild.getPatId(), ordNo, rstDialysisState.AFTER_WEIGHT, null, null);

      return ordCondBuild;

    } catch (Exception ex) {
      // ロールバック実行
      throw new RuntimeException(ex.getMessage());
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public OrdWeightScale updateOrdWeightStatus(Long weightScaleCd, Short weightScaleStatus, String message) {
    try {
      // 条件送信履歴に測定履歴をステータスを書き換え
      OrdWeightScale cond = ordWeightScaleDao.selectByCd(weightScaleCd);
      cond.setWeightScaleStatus(weightScaleStatus);
      cond.setMessage(message);
//      add 8074 【デグレ】ログに誤った利用者が記録される 関 start
      NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
      cond.setLogUserId(user.getUserId().toString());
//      add 8074 【デグレ】ログに誤った利用者が記録される 関  end
      // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
      LogEventUtils.setOperatorId(cond,logService);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
      // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
      if (ordWeightScaleDao.update(cond) > 0) {
        return cond;
      }
      return null;
    } catch (Exception ex) {
      // ロールバック実行
      throw new RuntimeException(ex.getMessage());
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public MstMachine getMachineByOrderRst(Long ordNo) {
    // 条件から装置情報を取得
    List<MstMachine> res = mstMachineDao.selectByOrdNoRst(ordNo);
    if (res.size() == 0) {
      return null;
    }
    return res.get(0);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public MstMachine getMachineByOrderInd(Long ordNo) {
    // 条件から装置情報を取得
    List<MstMachine> res = mstMachineDao.selectByOrdNoInd(ordNo);
    if (res.size() == 0) {
      return null;
    }
    return res.get(0);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public String getTmpDeviceSetInfo(MstMachine machine) {
    // 条件送信用の条件取得
    ComsvMntMachineState state = mntMachineStateDao.selectMachineKey(machine.getFacilityCd(),
      machine.getMachineTypeCd(), machine.getMachineSerial());

    return state.getTmpDeviceSetInfo();
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public String findFacilityName(String facilityCd) {
    String facilityName = mstFacilityDao.selectNameByCd(facilityCd);
    return facilityName;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public String fetchEnableWeightSelect(String facilityCd) {
    FacilitySettingInfo infoEnableWeightSelect = mstFacilitySettingDao.getBySettingNoAndCd(facilityCd,
      FacilitySettingNo.ENABLE_WEIGHT_SELECT);
    return infoEnableWeightSelect.getValue();
  }

  private WheelChairScaleMode getFacilitySettingWheelChair(String facilityCd) {
    FacilitySettingInfo infoWheelChairMeasureOrderModeBefore = mstFacilitySettingDao.getBySettingNoAndCd(facilityCd,
      FacilitySettingNo.WHEEL_CHAIR_MEASURE_ORDER_MODE_BEFORE);
    String chairMeasureModeBefore = infoWheelChairMeasureOrderModeBefore.getValue();
    FacilitySettingInfo infoWheelChairMeasureOrderModeAfter = mstFacilitySettingDao.getBySettingNoAndCd(facilityCd,
      FacilitySettingNo.WHEEL_CHAIR_MEASURE_ORDER_MODE_AFTER);
    String chairMeasureModeAfter = infoWheelChairMeasureOrderModeAfter.getValue();
    WheelChairScaleMode ret = new WeightOrderResponse().new WheelChairScaleMode();

    ret.chairMeasureModeBefore = chairMeasureModeBefore;
    ret.chairMeasureModeAfter = chairMeasureModeAfter;

    return ret;
  }

  /**
   * 装置状態テーブルから状態と確認済みフラグを取得する
   *
   * @param bedCd ベッドコード nullならば初期値のMachineStateを返す
   * @return
   */
  private MachineState getWeightOrderResponseMachineState(Long bedCd) {
    MachineState ret = new WeightOrderResponse().new MachineState();
    ret.machineTypeCd = "";
    ret.comFormatCd = "";
    ret.isCommonComFormatProtocol = FlagType.FLAG_OFF;
    ret.isOfflineMachine = FlagType.FLAG_OFF;
    ret.isOfflineTreat = FlagType.FLAG_OFF;
    ret.isConnectError = FlagType.FLAG_OFF;
    ret.isPatVerified = FlagType.FLAG_OFF;
    ret.isTreating = FlagType.FLAG_OFF;
    ret.isUseTmpControl = FlagType.FLAG_OFF;

    if (bedCd != null) {
      MachineTreatingState state = mntMachineStateDao.selectByMstBedCd(bedCd);
      if (state != null) {
        ret = validateSendableByMachineState(state);
      }
    }

    return ret;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public currentMachineTreatState validationMachineStateCanSend(MachineCurrentOrdDataSet machineCurrentOrdDataSet) {
    MachineTreatingState state = new MachineTreatingState();
    state.setComType(machineCurrentOrdDataSet.machine.getComType());
    state.setComFormatCd(machineCurrentOrdDataSet.machine.getComFormatCd());
    state.setIsPatVerified(machineCurrentOrdDataSet.state.getIsPatVerified());
    state.setStartDate(machineCurrentOrdDataSet.state.getStartDate());
    state.setEndDate(machineCurrentOrdDataSet.state.getEndDate());
    state.setProcessState(machineCurrentOrdDataSet.state.getProcessState());
    state.setMachineStatus(machineCurrentOrdDataSet.state.getMachineStatus());
    MachineState mState = validateSendableByMachineState(state);
    if (Objects.equals(mState.isConnectError, "1")) {
      return currentMachineTreatState.connectError;
    } else if (Objects.equals(mState.isTreating, "1")) {
      return currentMachineTreatState.treating;
    } else {
      return currentMachineTreatState.canSendCondition;
    }
  }

  /**
   * 装置が治療中や通信断ではなく条件送信可能な状態かどうか
   *
   * @param state
   * @return
   */
  MachineState validateSendableByMachineState(MachineTreatingState state) {
    MachineState ret = new WeightOrderResponse().new MachineState();
    ret.machineTypeCd = state.getMachineTypeCd();
    ret.comFormatCd = state.getComFormatCd();
    ret.isCommonComFormatProtocol = FlagType.FLAG_OFF;
    ret.isConnectError = FlagType.FLAG_OFF;
    ret.isPatVerified = FlagType.FLAG_OFF;
    ret.isTreating = FlagType.FLAG_OFF;
    ret.isPatVerified = state.getIsPatVerified();
    ret.isUseTmpControl = FlagType.FLAG_OFF;
    ret.comType = state.getComType();
    ret.isOfflineMachine = (Objects.equals(state.getComType(), ComType.OFFLINE)
      && Objects.equals(state.getComFormatCd(), ComFormat.OFFLINE)) ? FlagType.FLAG_ON : FlagType.FLAG_OFF;
    ret.isOfflineTreat = state.getIsOffline();
    if (Objects.equals(ret.isOfflineMachine, FlagType.FLAG_ON)
      ||
      Objects.equals(ret.isOfflineTreat, FlagType.FLAG_ON)) {
      // オフライン透析装置またはオフラインモード治療中　
      // 治療開始日があって終了日がない場合に治療中
      if (Objects.isNull(state.getStartDate()) == false && Objects.isNull(state.getEndDate())) {
        ret.isTreating = "1";
      }
    } else {
      // 透析装置
      if (Objects.isNull(state.getProcessState()) || Objects.equals(state.getProcessState(), "99")) {
        // 通信断
        ret.isConnectError = "1";
      } else {
        // 通信中
        if (!Objects.isNull(state.getMachineStatus()) && (state.getMachineStatus().intValue() & 0x01) == 0x01) {
          // 治療中
          ret.isTreating = "1";
        }
      }
    }
    String[] coms = {ComFormat.COMMON1, ComFormat.COMMON2, ComFormat.COMMON3, ComFormat.COMMON4};
    if (Arrays.asList(coms).contains(state.getComFormatCd())) {
      // 通信共通
      ret.isCommonComFormatProtocol = FlagType.FLAG_ON;
    }
    if (Arrays.asList(USE_TMP_CONTROL_MACHINES).contains(state.getMachineTypeCd())) {
      // NXシリーズ
      ret.isUseTmpControl = FlagType.FLAG_ON;
    }
    return ret;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public WeightOrderResponse buildOrderResponseNoPat(String facilityCd) {
    OrdMainForWeightInd ord = new OrdMainForWeightInd();
    OrdWeightScale scale = null;
    List<PatUniquePhysicalInfo> physicalInfo = new ArrayList<>();
    List<MstWheelChair> chair = new ArrayList<>();
    OrdMainForWeightNextSchedule nextOrd = new OrdMainForWeightNextSchedule();
    String facilityName = mstFacilityDao.selectNameByCd(facilityCd);
    WheelChairScaleMode wheelChairInfo = getFacilitySettingWheelChair(facilityCd);
    wheelChairInfo.isWheelChair = FlagType.FLAG_OFF;
    return new WeightOrderResponse(facilityName, ord, physicalInfo, scale, nextOrd, wheelChairInfo, chair,
      getWeightOrderResponseMachineState(null), null);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public WeightOrderResponse buildOrderResponse(Long ordNo) {
    OrdMainForWeightInd ord = ordMainDao.selectForWeightIndByOrdNo(ordNo);
    OrdWeightScale scale = new OrdWeightScale();
    List<PatUniquePhysicalInfo> physicalInfo = new ArrayList<>();
    List<MstWheelChair> chair = new ArrayList<>();
    // ord_mainから取得した測定記録キーから測定記録を取得
    if (ord != null) {
      if (ord.getWeightScaleNo() != null) {
        scale = ordWeightScaleDao.selectTempDataByCd(ord.getWeightScaleNo());
      }
      if (ord.getPatId() != null) {
        chair = mstWheelChairDao.selectByPatId(ord.getPatId(), FlagType.FLAG_ON, FlagType.FLAG_OFF);
        /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */
        // physicalInfo = patUniqueDao.selectPhysicalInfoOfOrderNewest(ord.getPatId());
        physicalInfo = patUniqueDao.selectPhysicalInfoOfOrderNewest(ord.getPatId(), 1);
        /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --end */
      }
    } else {
      // 削除済みオーダー番号

      WheelChairScaleMode wheelChairInfo = new WeightOrderResponse().new WheelChairScaleMode();
      wheelChairInfo.isWheelChair = FlagType.FLAG_OFF;
      return new WeightOrderResponse("", ord, physicalInfo, scale, new OrdMainForWeightNextSchedule(),
        wheelChairInfo, chair, getWeightOrderResponseMachineState(null), null);
    }
    OrdMainForWeightNextSchedule nextOrd = new OrdMainForWeightNextSchedule();
    // #11017 2024.08.22 mod 次回透析予定は翌日以降で検索を行う TDC米沢 start
    // DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("yyyyMMddHHmm");
    // String baseDateTimeStr = "";
    // if (ord != null && ord.getRstEndDate() != null) {
    //   LocalDateTime baseDateTime = ord.getRstEndDate().toLocalDateTime();
    //   baseDateTimeStr = baseDateTime.format(dateTimeFormatter);
    // } else {
    //   baseDateTimeStr = LocalDateTime.now().format(dateTimeFormatter);
    // }
    // 検索条件に当日の23：59を指定する(翌日以降の透析予定を対象とする)
    String baseDateTimeStr = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd2359"));
    // #11017 2024.08.22 mod 次回透析予定は翌日以降で検索を行う TDC米沢 end

    nextOrd = ordMainDao.selectNextShceduleByPat(ord.getPatId(), baseDateTimeStr);
    String facilityName = mstFacilityDao.selectNameByCd(ord.getFacilityCd());
    WheelChairScaleMode wheelChairInfo = getFacilitySettingWheelChair(ord.getFacilityCd());
    wheelChairInfo.isWheelChair = ord.getIsWheelChair();
    // ベッドコードから関連づいている装置の状態を取得　実績がない場合に指示から取得
    MachineState state = getWeightOrderResponseMachineState(
      ord.getRstBedCd() == null ? ord.getIndBedCd() : ord.getRstBedCd());
    String patDeviceSet = null;
    if (ord != null && ord.getPatId() != null) {
      PatMain patMain = patMainDao.selectById(ord.getPatId());
      if (patMain != null) {
        patDeviceSet = patMain.getDevice_set_info();
      }
    }
    return new WeightOrderResponse(facilityName, ord, physicalInfo, scale, nextOrd, wheelChairInfo, chair, state,
      patDeviceSet);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public WeightOrderResponse buildOrderResponseNoSchedule(Long patId, String facilityCd) {
    LocalDateTime nowTime = LocalDateTime.now();
    OrdMainForWeightInd ord = new OrdMainForWeightInd();
    OrdWeightScale scale = null;
    List<MstWheelChair> chair = new ArrayList<>();
    chair = mstWheelChairDao.selectByPatId(patId, FlagType.FLAG_ON, FlagType.FLAG_OFF);
    OrdMainForWeightNextSchedule nextOrd = new OrdMainForWeightNextSchedule();
    // #11017 2024.08.22 mod 次回透析予定は翌日以降で検索を行う TDC米沢 start
    // DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("yyyyMMddHHmm");
    // String baseDateTimeStr = "";
    // baseDateTimeStr = nowTime.format(dateTimeFormatter);
    // 検索条件に当日の23：59を指定する(翌日以降の透析予定を対象とする)
    String baseDateTimeStr = nowTime.format(DateTimeFormatter.ofPattern("yyyyMMdd2359"));
    // #11017 2024.08.22 mod 次回透析予定は翌日以降で検索を行う TDC米沢 end
    // 患者情報を取得
    PatMain patMain = patMainDao.selectById(patId);
    /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */
    // List<PatUniquePhysicalInfo> physicalInfo = patUniqueDao.selectPhysicalInfoOfOrderNewest(patId);
    List<PatUniquePhysicalInfo> physicalInfo = patUniqueDao.selectPhysicalInfoOfOrderNewest(patId, 9);
    /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --end */
    String isWheelChair = FlagType.FLAG_OFF;
    if (patMain != null) {
      isWheelChair = patMain.getIs_wheel_chair();
    }

    // 指示がないぶん、体重測定に必要な項目を患者情報から取得する
    Integer dayOfWeek = nowTime.getDayOfWeek().getValue();
    TareAndOffWater tareAndOffWater = patMainDao.selectTareAndOffWaterByDayOfWeek(patId, dayOfWeek.toString(),
      dayOfWeek.toString());

    ord.setIndTareInfo(tareAndOffWater.getTareInfo());
    ord.setIndOffWaterInfo(tareAndOffWater.getOffWaterInfo());

    // 目標体重と除水制限は取得しない

    nextOrd = ordMainDao.selectNextShceduleByPat(patId, baseDateTimeStr);
    String facilityName = mstFacilityDao.selectNameByCd(facilityCd);
    WheelChairScaleMode wheelChairInfo = getFacilitySettingWheelChair(facilityCd);
    wheelChairInfo.isWheelChair = isWheelChair;
    String patDeviceSet = null;
    if (patMain != null) {
      patDeviceSet = patMain.getDevice_set_info();
    }
    return new WeightOrderResponse(facilityName, ord, physicalInfo, scale, nextOrd, wheelChairInfo, chair,
      getWeightOrderResponseMachineState(null), patDeviceSet);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public boolean updateIndTare(Long ordNo, String tareInfo) {
    try {

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
      DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResult = logCommon.setInfo();
      // DB更新ログ出力ロジック wangzuo End

      OrdMain oldOrdMain = ordMainDao.selectByOrdNo(ordNo);
      int updateCount = ordMainDao.updateIndStartTareAndOffWater(ordNo, null, tareInfo);
      OrdMain newOrdMain = ordMainDao.selectByOrdNo(ordNo);
      triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain),
        Collections.singletonList(newOrdMain));

      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && updateCount > 0) {
        logCommon.updateLog();
      }
      // DB更新ログ出力ロジック wangzuo End

      return (updateCount > 0);
    } catch (Exception ex) {
      // ロールバック実行
      throw new RuntimeException(ex.getMessage());
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public boolean updateIndOffWater(Long ordNo, String offWaterInfo) {
    try {

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
      DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResult = logCommon.setInfo();
      // DB更新ログ出力ロジック wangzuo End

      OrdMain oldOrdMain = ordMainDao.selectByOrdNo(ordNo);
      int updateCount = ordMainDao.updateIndStartTareAndOffWater(ordNo, offWaterInfo, null);
      OrdMain newOrdMain = ordMainDao.selectByOrdNo(ordNo);
      triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain),
        Collections.singletonList(newOrdMain));

      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && updateCount > 0) {
        logCommon.updateLog();
      }
      // DB更新ログ出力ロジック wangzuo End

      return (updateCount > 0);
    } catch (Exception ex) {
      // ロールバック実行
      throw new RuntimeException(ex.getMessage());
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public WeightKurBedResponse getKurBedSelector(String facilityCd, short excludeDialysisRoom) {
    WeightKurBedResponse res = new WeightKurBedResponse();
    // クールマスタのマスタセレクタ―を取得
    MstSelector mstSelectorKur = mstSelectorDao.selectByName(facilityCd, "mst_kur");
    if (Objects.isNull(mstSelectorKur) || mstSelectorKur.getOrderSettings().getItems().isEmpty()) {
      res.kurSelector = new ArrayList<MstSelector.Item>();
    } else {
      res.kurSelector = mstSelectorKur.getOrderSettings().getItems();
    }
    // ベッドグループマスタはマスタセレクタ―順に整列したマスタ本体のリストを取得
    MstSelector mstSelectorBedGroup = mstSelectorDao.selectByName(facilityCd, "mst_room_bed_group");
    List<MstRoomBedGroup> bedGroupList = mstRoomBedGroupDao.selectByFacility(facilityCd);
    if (Objects.isNull(mstSelectorBedGroup) || mstSelectorBedGroup.getOrderSettings().getItems().isEmpty()) {
      res.bedGroupList = new ArrayList<MstRoomBedGroup>();
    } else {
      res.bedGroupList = new ArrayList<MstRoomBedGroup>();
      for (MstSelector.Item selector : mstSelectorBedGroup.getOrderSettings().getItems()) {
        Optional<MstRoomBedGroup> grp = bedGroupList.stream()
          .filter(elem -> Objects.equals((long) elem.getRoomBedGroupCd(), selector.getCode().longValue()))
          .findFirst();
        if (!Objects.isNull(grp) && grp.isPresent() && grp.get().getIsDisp().equals(FlagType.FLAG_ON)) {
          if (excludeDialysisRoom == -1) {
            // isDisp が有効なレコードを全て取得
            res.bedGroupList.add(grp.get());
          } else if (excludeDialysisRoom == 1 && !grp.get().getGroupClass().equals((short)2)) {
            // isDisp が有効なレコードから、透析室(group_class = 2)を除外して、それ以外を取得する
            res.bedGroupList.add(grp.get());
          }
        }
      }
    }
    return res;
  }

  @Override
  public List<MstKur> getKurList(String facilityCd) {
    return mstKurDao.selectByFacilityCd(SelectOptions.get(), facilityCd, FlagType.FLAG_OFF);
  }

  @Override
  public List<MstRoomBedGroup> getBedGroupList(String facilityCd) {
    return mstRoomBedGroupDao.selectByFacility(facilityCd);
  }

  @Override
  public OrdMainRstWeightInfo getLastWeightRecord(Long ordNo, Integer previousWeightSourceClass) throws ParseException {
    OrdMainForWeightInd ind = ordMainDao.selectForWeightIndByOrdNo(ordNo);
    if (ind == null) {
      return null;
    }
    Long patId = ind.getPatId();
    String treatYYYYMMDD = ind.getTreatDate();
    String treatStartHHMM = ind.getIndTreatStartTime();
    Timestamp baseDate;
    // 検索基準日の設定
    if (treatStartHHMM != null && treatStartHHMM.length() == 4) {
      baseDate = new Timestamp(new SimpleDateFormat("yyyyMMddHHmm").parse(treatYYYYMMDD + treatStartHHMM).getTime());
    } else {
      baseDate = new Timestamp(new SimpleDateFormat("yyyyMMdd").parse(treatYYYYMMDD).getTime());
    }
    String weight;
    if (Objects.equals(previousWeightSourceClass, 1)) {
      // 分類区別無し
      weight = ordMainDao.selectLastRstWeight(patId, ordNo, baseDate, null);
    } else {
      Integer deviceMode = ind.getRstDeviceMode();
      if (ind.getRstDialysisState().equals(OrdMainConst.DialysisState.BEFORE_SEND)
        || ind.getRstDialysisState().equals(OrdMainConst.DialysisState.AFTER_SEND)) {
        // 条件送信確認前ならば指示を使用する
        deviceMode = ind.getIndDeviceMode();
      }

      if (Objects.equals(deviceMode, Treatment.DeviceMode.PURIFICATION)) {
        weight = ordMainDao.selectLastRstWeight(patId, ordNo, baseDate, 1);
      } else {
        weight = ordMainDao.selectLastRstWeight(patId, ordNo, baseDate, 0);
      }
    }
    OrdMainRstWeightInfo dto;
    try {
      dto = weight == null || weight.isEmpty() ? new OrdMainRstWeightInfo()
        : mapper.readValue(weight, OrdMainRstWeightInfo.class);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      return null;
    }
    return dto;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public OrdMainRstWeightInfo getLastWeightRecordPat(Long patId, Integer previousWeightSourceClass)
    throws ParseException {

    String weight;
    // 検索基準日の設定
    Timestamp baseDate = Timestamp.valueOf(LocalDateTime.now());
    if (Objects.equals(previousWeightSourceClass, 1)) {
      // 分類区別無し
      weight = ordMainDao.selectLastRstWeight(patId, null, baseDate, null);
    }

    weight = ordMainDao.selectLastRstWeight(patId, null, baseDate, 0);
    OrdMainRstWeightInfo dto;
    try {
      dto = weight == null || weight.isEmpty() ? new OrdMainRstWeightInfo()
        : mapper.readValue(weight, OrdMainRstWeightInfo.class);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      return null;
    }
    return dto;
  }

  /* #10443 ADD 測定日と同日の治療日の治療データから、測定タイミングと一致する体重を対象にデータ取得をする Start */
  /**
   * 測定日と同日の治療日の治療データから、測定タイミングと一致する体重を対象にデータ取得をする
   *
   * @param facilityCd  施設コード
   * @param patId       患者ID
   * @param ordClass    測定タイミング
   * @param treatDate   測定日
   * @param treatTime   測定時間
   * @return  測定タイミングと一致する体重
   */
  @Override
  public String getNearestWeightRecordForPat(String facilityCd, Long patId, String ordClass,
                                             String treatDate, String treatTime) {

    if (StringUtils.hasText(facilityCd)
      && StringUtils.hasText(treatDate)
      && patId != null) {

      if (!StringUtils.hasText(treatTime) || "null".equals(treatTime)) treatTime = "00:00";

      // found out all record from these date
      List<OrdMainLatelyWeightInfo> ordMainLatelyWeightInfo
        = this.ordMainDao.getNearestWeightRecordForPat(facilityCd, patId, treatDate, treatDate + " " + treatTime);

      OrdMainLatelyWeightInfo latelyWeightInfo = this.getLatelyRecord(ordMainLatelyWeightInfo, ordClass);
      if (latelyWeightInfo != null) return latelyWeightInfo.getWeightByOrdClass(ordClass);
    }
    return null;
  }

  /**
   * これらのレコードから適切な1つを選別する
   * @param recordList  測定日と同日の治療日の治療データ
   * @param ordClass    測定タイミング
   * @return            適切な1つレコード
   */
  private OrdMainLatelyWeightInfo getLatelyRecord(List<OrdMainLatelyWeightInfo> recordList, String ordClass) {

    if (CollectionUtils.isEmpty(recordList)) return null;
    // 1つだけの場合は、この1つに戻ります
    if (this.tryToFoundTheResult(recordList)) return recordList.get(0);

    // 体重情報を持つデータをフィルタリング
    List<OrdMainLatelyWeightInfo> hasWeightInfoList = recordList.stream()
      .filter(r -> !Objects.isNull(r.getWeightByOrdClass(ordClass)))
      .toList();

    if (CollectionUtils.isEmpty(hasWeightInfoList)) return null;
    // 1つだけの場合は、この1つに戻ります
    if (this.tryToFoundTheResult(hasWeightInfoList)) return hasWeightInfoList.get(0);

    // 治療方法に基づくグループ化
    Map<Boolean, List<OrdMainLatelyWeightInfo>> treatmentHasWeightInfos = hasWeightInfoList.stream()
      // （特殊浄化 or 不明）
      .collect(Collectors.groupingBy(weight -> Treatment.DeviceMode.UNKNOWN.equals(weight.getDeviceMode())
        || Treatment.DeviceMode.PURIFICATION.equals(weight.getDeviceMode())));

    if (!treatmentHasWeightInfos.isEmpty()) {
      // 透析治療
      if (CollectionUtils.isNotEmpty(treatmentHasWeightInfos.get(false))) {
        // 1つだけの場合は、この1つに戻ります
        if (this.tryToFoundTheResult(treatmentHasWeightInfos.get(false)))
          return treatmentHasWeightInfos.get(false).get(0);

        OrdMainLatelyWeightInfo targetInfo =
          this.tryToFoundTheResultFromWeightInfoList(treatmentHasWeightInfos.get(false), ordClass);
        if (targetInfo != null) return targetInfo;
      }
      // 非透析治療（特殊浄化 or 不明）
      else if (CollectionUtils.isNotEmpty(treatmentHasWeightInfos.get(true))) {
        // 1つだけの場合は、この1つに戻ります
        if (this.tryToFoundTheResult(treatmentHasWeightInfos.get(true))) {
          return treatmentHasWeightInfos.get(true).get(0);
        } else {

          OrdMainLatelyWeightInfo targetInfo =
            this.tryToFoundTheResultFromWeightInfoList(treatmentHasWeightInfos.get(true), ordClass);
          if (targetInfo != null) return targetInfo;
        }
      }
    }

    return hasWeightInfoList.stream().filter(
        weight -> !(Treatment.DeviceMode.UNKNOWN.equals(weight.getDeviceMode())
          || Treatment.DeviceMode.PURIFICATION.equals(weight.getDeviceMode()))
      )
      .findFirst()
      .orElse(hasWeightInfoList.get(0));
  }

  private OrdMainLatelyWeightInfo tryToFoundTheResultFromWeightInfoList(
    List<OrdMainLatelyWeightInfo> recordList
    , String ordClass) {

    // 治療時間があるのレコードを探して
    List<OrdMainLatelyWeightInfo> weightInfoWithRstDateList = recordList.stream()
      .filter(wr ->
        !Objects.isNull(wr.getRstDateByClass(ordClass)) || !Objects.isNull(wr.getWTimeDiffByClass(ordClass))
      )
      .toList();

    if (CollectionUtils.isNotEmpty(weightInfoWithRstDateList)) {

      // 治療時間が近くのレコードを探して
      return weightInfoWithRstDateList.stream()
        .filter(nr -> nr.getTimeDiffClassByClass(ordClass) && nr.getTimeDiffByClass(ordClass) != null)
        .min(Comparator.comparingLong(n -> Math.abs(n.getTimeDiffByClass(ordClass))))
        //体重測定時間が近くのレコードを探して
        .orElseGet(() ->
          weightInfoWithRstDateList.stream()
            .filter(nr -> nr.getWTimeDiffClassByClass(ordClass) && nr.getWTimeDiffByClass(ordClass) != null)
            .min(Comparator.comparing(n -> Math.abs(n.getWTimeDiffByClass(ordClass))))
            // 見つからない場合は治療時間反方向に探す必要がある。
            .orElseGet(() ->
              weightInfoWithRstDateList.stream()
                .filter(nr -> !nr.getTimeDiffClassByClass(ordClass) && nr.getTimeDiffByClass(ordClass) != null)
                .min(Comparator.comparingLong(n -> Math.abs(n.getTimeDiffByClass(ordClass))))
                // 体重測定時間反方向に探す
                .orElseGet(() ->
                  weightInfoWithRstDateList.stream()
                    .filter(nr -> !nr.getWTimeDiffClassByClass(ordClass) && nr.getWTimeDiffByClass(ordClass) != null)
                    .min(Comparator.comparingLong(n -> Math.abs(n.getWTimeDiffByClass(ordClass))))
                    //
                    .orElse(null)
                )
            )
        );
    }

    return null;
  }

  /** 1つだけの場合は、この1つに戻ります */
  private boolean tryToFoundTheResult(List<OrdMainLatelyWeightInfo> recordList) {
    // 1つだけの場合は、この1つに戻ります
    return CollectionUtils.isNotEmpty(recordList) && recordList.size() == 1;
  }

  /* #10443 ADD 測定日と同日の治療日の治療データから、測定タイミングと一致する体重を対象にデータ取得をする End */

  /**
   * {@inheritDoc}
   */
  @Override
  public OrdMainRstWeightInfo getWeightByTreatDate(Long patId, Integer previousWeightSourceClass, String treatDate)
    throws ParseException {

    String weight;
    String baseDate;
    // 検索基準日の設定
    if (treatDate == null) {
      DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("yyyyMMdd");
      baseDate = LocalDateTime.now().format(dateTimeFormatter);
    } else {
      baseDate = treatDate;
    }
    if (Objects.equals(previousWeightSourceClass, 1)) {
      // 分類区別無し
      weight = ordMainDao.selectWeightByTreatDate(patId, null, baseDate, null);
    }

    weight = ordMainDao.selectWeightByTreatDate(patId, null, baseDate, 0);
    OrdMainRstWeightInfo dto;
    try {
      dto = weight == null || weight.isEmpty() ? new OrdMainRstWeightInfo()
        : mapper.readValue(weight, OrdMainRstWeightInfo.class);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      return null;
    }
    return dto;
  }

  @Override
  public List<WeighthistoryResponse> getWeighthistoryInfo(String facilityCd, Long patId, String treatDate,
                                                          Integer previousWeightSourceClass) throws ParseException {
    String endtreatDate = treatDate;
    String satrttreatDate;
    //    Timestamp basetreatDate;
    //    basetreatDate = new Timestamp(new SimpleDateFormat("yyyyMMdd").parse(treatDate).getTime());
    int year = Integer.parseInt(treatDate.substring(0, 4));
    int month = Integer.parseInt(treatDate.substring(4, 6));
    int days = Integer.parseInt(treatDate.substring(6));
    Calendar calendar = Calendar.getInstance();
    //    calendar.setTime(basetreatDate);
    calendar.set(year, month - 1, days);
    calendar.add(Calendar.MONTH, -3);
    satrttreatDate = new SimpleDateFormat("yyyyMMdd").format(calendar.getTime());
    // ord_mainをもとに体重履歴情報を取得する
    List<OrdMainForWeightModal> WeighthistoryList = ordMainDao.selectWeighthistory(facilityCd, patId, satrttreatDate,
      endtreatDate);
    //    List<OrdMainForWeightModal> WeighthistoryList = ordMainDao.selectWeighthistory(facilityCd, patId, basetreatDate);
    // レスポンス格納配列作成
    List<WeighthistoryResponse> responseList = new ArrayList<WeighthistoryResponse>();

    for (int lop = 0; lop < WeighthistoryList.size(); lop++) {
      // リストから体重履歴情報取り出し
      OrdMainForWeightModal historyInfo = WeighthistoryList.get(lop);
      // それぞれのレスポンスインスタンス
      WeighthistoryResponse response = new WeighthistoryResponse();
      // ordno（前回後体重計算時必要）
      Long ordno = historyInfo.getOrdNo();
      response.setOrdNo(ordno);
      // 治療日（透析日）
      String treatdate = historyInfo.getTreatDate();
      response.setTreatDate(treatdate);
      // 治療曜日（曜日）
      Short treatweek = historyInfo.getTreatWeek();
      response.setTreatWeek(treatweek);
      // DW
      BigDecimal rstdw = historyInfo.getRstDw();
      response.setRstDw(rstdw);
      // 目標体重情報（治療条件情報:jsonデータ）
      String CondInfo = historyInfo.getRstCondInfo();
      response.setRstCondInfo(CondInfo);
      // 装置モード
      Integer devmode = historyInfo.getDeviceMode();
      response.setDeviceMode(devmode);
      String weight = historyInfo.getRstWeightInfo();
      // jsonデータからの取り出し
      try {
        OrdMainRstWeightInfo dto = weight == null || weight.isEmpty() ? new OrdMainRstWeightInfo()
          : mapper.readValue(weight, OrdMainRstWeightInfo.class);
        // 透析前体重
        response.setWeightBefore(dto.getWeightBefore());
        // 透析後体重
        response.setWeightAfter(dto.getWeightAfter());
      } catch (tools.jackson.core.JacksonException e) {
        // TODO 自動生成された catch ブロック
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
      // レスポンスリストに格納
      responseList.add(response);
    }
    // 1:特殊浄化を区別しない
    if (previousWeightSourceClass == 1) {
      for (int lop2 = 0; lop2 < responseList.size(); lop2++) {
        if (responseList.size() >= lop2 + 1) {
          BigDecimal beforeweight = responseList.get(lop2).getWeightBefore();
          BigDecimal afterweight = null;
          BigDecimal lastafterweight = null;
          if (responseList.get(lop2).getWeightBefore() != null) {
            if (responseList.get(lop2 + 1).getWeightAfter() != null) {
              // 前体重-前回後体重
              afterweight = responseList.get(lop2 + 1).getWeightAfter();
              lastafterweight = beforeweight.subtract(afterweight);
              //            // 透析後体重
              ////            response.setDifWeightBody(lastafterweight);
              //            responseList.get(lop2).difWeight = lastafterweight;

            } else {
              // 前回後体重がない場合（さらに前回を探す）
              for (int i = lop2 + 1; i < responseList.size(); i++) {
                if (responseList.size() != i + 1) {
                  if (responseList.get(i + 1).getWeightAfter() != null) {
                    afterweight = responseList.get(i + 1).getWeightAfter();
                    // 前体重-前回後体重
                    lastafterweight = beforeweight.subtract(afterweight);
                    break;
                  }
                } else {
                  lastafterweight = getLastweightafter(responseList, lop2, patId, previousWeightSourceClass);
                }
              }
            }
            // 透析後体重
            responseList.get(lop2).difWeight = lastafterweight;
          }
        }
      }
    } else {
      // 0:透析・特殊浄化を区別する
      for (int lop3 = 0; lop3 < responseList.size(); lop3++) {
        if (responseList.size() >= lop3 + 1) {
          BigDecimal beforeweight = responseList.get(lop3).getWeightBefore();
          BigDecimal lastafterweight = null;
          if (responseList.get(lop3).getWeightBefore() != null) {
            if (responseList.get(lop3).getDeviceMode() != null) {
              // デバイスモード：9
              if (responseList.get(lop3).getDeviceMode().equals(Treatment.DeviceMode.PURIFICATION)) {
                // 前回デバイスモードない場合は探す
                for (int i = lop3 + 1; i <= responseList.size(); i++) {
                  BigDecimal afterweight = null;
                  if (responseList.size() != i) {
                    if (responseList.get(i).getDeviceMode() != null) {
                      if (responseList.get(i).getDeviceMode().equals(Treatment.DeviceMode.PURIFICATION)) {
                        //                      if (responseList.get(lop3).getWeightBefore() != null) {
                        if (responseList.get(i).getWeightAfter() != null) {
                          // 前体重-前回後体重
                          afterweight = responseList.get(i).getWeightAfter();
                          lastafterweight = beforeweight.subtract(afterweight);
                          break;
                        }
                        //                    }
                      }
                    }
                  } else {
                    lastafterweight = getLastweightafter(responseList, lop3, patId, previousWeightSourceClass);
                  }
                }
              } else {
                //  デバイスモード：9以外
                for (int i = lop3 + 1; i <= responseList.size(); i++) {
                  BigDecimal afterweight = null;
                  if (responseList.size() != i) {
                    if (responseList.get(i).getDeviceMode() != null) {
                      if (!responseList.get(i).getDeviceMode().equals(Treatment.DeviceMode.PURIFICATION)) {
                        //                    if (responseList.get(lop3).getWeightBefore() != null) {
                        if (responseList.get(i).getWeightAfter() != null) {
                          // 前体重-前回後体重
                          afterweight = responseList.get(i).getWeightAfter();
                          lastafterweight = beforeweight.subtract(afterweight);
                          break;
                        }
                        //                    }
                      }
                    }
                  } else {
                    lastafterweight = getLastweightafter(responseList, lop3, patId, previousWeightSourceClass);
                  }
                }
              }
              // 透析後体重
              responseList.get(lop3).difWeight = lastafterweight;
            }
          }
        }
      }
    }
    return responseList;
  }

  private BigDecimal getLastweightafter(List<WeighthistoryResponse> responseList, int lop, Long patId,
                                        Integer previousWeightSourceClass) throws ParseException {
    Timestamp baseDate;
    BigDecimal getafterweight = null;
    BigDecimal getlastafterweight = null;
    String weightafter;

    String treatdate = responseList.get(lop).getTreatDate();
    baseDate = new Timestamp(new SimpleDateFormat("yyyyMMdd").parse(treatdate).getTime());
    Long ordNo = responseList.get(lop).getOrdNo();
    // 前回後体重取得処理
    // 特殊浄化を区別する
    weightafter = ordMainDao.selectLastRstWeight(patId, ordNo, baseDate, previousWeightSourceClass);
    OrdMainRstWeightInfo dto;
    try {
      dto = weightafter == null || weightafter.isEmpty() ? new OrdMainRstWeightInfo()
        : mapper.readValue(weightafter, OrdMainRstWeightInfo.class);
      // 後体重
      BigDecimal getbeforeweight = responseList.get(lop).getWeightBefore();
      getafterweight = dto.getWeightAfter();
      if (getafterweight != null) {
        getlastafterweight = getbeforeweight.subtract(getafterweight);
        //          responseList.get(lop3).difWeight = getlastafterweight;
      }
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      return null;
    }
    return getlastafterweight;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  // FNSI-add redmine4656 徐 start
  //  public List<PatExamMainWeightPrint> fetchExamForPrint(String facilityCd, Long patId, String strBaseDate,
  //                                                        List<String> itemCdList) {
  public List<PatExamMainWeightPrint> fetchExamForPrint(String facilityCd, Long patId, String strBaseDate,
                                                        List<PatExamPrint> itemCdList) {
    // FNSI-add redmine4656 徐 end

    List<PatExamMainWeightPrint> ret = new ArrayList<>();
    MstWeightScale mstWeightScale = mstWeightScaleDao.selectByFacility(facilityCd);
    if (Objects.isNull(mstWeightScale)) {
      return ret;
    }
    LocalDateTime maxDate = null;
    try {
      LocalDate localBaseDate = LocalDate.parse(strBaseDate, DateTimeFormatter.ofPattern("uuuuMMdd"));
      maxDate = localBaseDate.plusDays(1).atTime(0, 0);
    } catch (Exception ex) {
      maxDate = LocalDate.now().plusDays(1).atTime(0, 0);
    }
    Timestamp maxDateT = Timestamp.valueOf(maxDate);

    LocalDateTime limitDate = null;
    Timestamp limitDateT = null;

    // limitDate算出
    if (Objects.isNull(mstWeightScale.getExamPeriod()) || mstWeightScale.getExamPeriod().intValue() < 1) {
      limitDate = null;
    } else {
      limitDate = maxDate.minusDays(mstWeightScale.getExamPeriod());
      limitDateT = Timestamp.valueOf(limitDate);
    }

    // 検査結果のうち同じ検査項目は最新の1件のみ
    // FNSI-add redmine4656 徐 start
//    List<String> itemCdListDistinct = itemCdList.stream().distinct().collect(Collectors.toList());
    List<String> itemCdListString = new ArrayList<String>();
    if (itemCdList != null && itemCdList.size() > 0) {
      for (int i = 0; i < itemCdList.size(); i++) {
        String itemCd = itemCdList.get(i).getItem_cd();
        itemCdListString.add(itemCd);
      }
      List<String> itemCdListDistinct = itemCdListString.stream().distinct().collect(Collectors.toList());

      List<PatExamMainWeightPrint> list = patExamMainDao.selectExamForWeight(patId, maxDateT, limitDateT,
        itemCdListDistinct);
      for (PatExamPrint itemCd : itemCdList) {
        for (PatExamMainWeightPrint item : list) {
          if (Objects.equals(itemCd.getItem_cd(), item.getItemCd()) && Objects.equals(itemCd.getExam_class(), item.getRegOrderClass())) {
            ret.add(item);
            break;
          }
        }
      }
    }
    //    List<PatExamMainWeightPrint> list = patExamMainDao.selectExamForWeight(patId, maxDateT, limitDateT,
//      itemCdListDistinct);
//    for (String itemCd : itemCdListDistinct) {
//      for (PatExamMainWeightPrint item : list) {
//        if (Objects.equals(itemCd, item.getItemCd())) {
//          ret.add(item);
//          break;
//        }
//      }
//    }
    // FNSI-add redmine4656 徐 end

    return ret;
  }

  // add 2020-08-08 FNSI-仕様追加 カード読み込み時にIdmでカード有効無効なチェック処理 夏 start

  /**
   * {@inheritDoc}
   */
  @Override
  public String getCardIdm(Long patId) {
    String selectCardIdm = patMainDao.selectCardIdm(patId);
    if (selectCardIdm == null) {
      return "";
    }
    return selectCardIdm;
  }
  // add 2020-08-08 FNSI-仕様追加 カード読み込み時にIdmでカード有効無効なチェック処理 夏 end
  // add FNSI-分類不一致判断の追加 徐 start

  /**
   * {@inheritDoc}
   */
  @Override
  public SendConditionCheckResponse getChkIndCondInfoData(Long ordNo, Long ordNos, Boolean chkIndCondInfoFlg, Boolean mstDelFlg, Boolean mstOverdueFlg) {

    SendConditionCheckResponse res = new SendConditionCheckResponse();
    // 治療条件分類不一致MsgList
    List<String> msgList = new ArrayList<String>();
    String msg = "";
    // 治療条件未登録MsgList
    List<String> indCondInfoNoLoginMsgList = new ArrayList<String>();
    String indCondInfoNoLoginMsg = "";
    // 治療条件上限MsgList
    List<String> indCondInfoTopLimitMsgList = new ArrayList<String>();
    String indCondInfoTopLimitMsg = "";
    // IHDF治療条件不整合MsgList
    List<String> indCondInfoUseIHDFMsgList = new ArrayList<String>();
    String indCondInfoUseIHDFMsg = "";
    // 治療条件下限MsgList
    List<String> indCondInfoLowerLimitMsgList = new ArrayList<String>();
    String indCondInfoLowerLimitMsg = "";
    // AFBF治療条件不整合MsgList
    List<String> indCondInfoUseAFBFMsgList = new ArrayList<String>();
    String indCondInfoUseAFBFMsg = "";
    // SN治療条件不整合MsgList
    List<String> indCondInfoUseSNMsgList = new ArrayList<String>();
    String indCondInfoUseSNMsg = "";
    // Na注入プログラム使用Flg
    Boolean naInjectionProgramFlg = false;
    // シングルニードル使用Flg
    Boolean singleNeedleFlg = false;
    // TMP自動追従使用Flg
    Boolean tmpAutomaticTrackingFlg = false;
    // add #7810 2022/11/20 BVUFCを使用する予定に除水プログラム使用するを展開する場合は警告。。 dou start
    Boolean diversionBvufcFlg = false;
    // add #7810 2022/11/20 BVUFCを使用する予定に除水プログラム使用するを展開する場合は警告。。 dou end
    // 装置オプション不整合MsgList
    List<String> deviceOptionsMsgList = new ArrayList<String>();
    String deviceOptionsMsg = "";
    // 特殊浄化MsgFlg
    Boolean isPurificationMsgFlg = false;
    // 補液量と補液速度についてMsgFlg
    Boolean replenishmentMsgFlg = false;
    // 補液量と補液比率についてMsgFlg
    Boolean replenishmentMsgFlg2 = false;
    // 補液量と濾過率についてMsgFlg
    Boolean replenishmentMsgFlg3 = false;
    // add FutreNetWeb+SI課題管理No7195 趙 start
    // HDF・HF 補液量と補液速度についてMsgFlg
    Boolean replenishmentMsgFlg4 = false;
    // add FutreNetWeb+SI課題管理No7195 趙 end
    // 装置モード不一致チェックMsgFlg
    Boolean deviceModeMismatchMsgFlg = false;
    //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx start
    Boolean deviceModeUnknownMsgFlg = false;
    Boolean isPurificationWarnMsgFlg = false;
    //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx end
    // VA方向不一致チェックMsgFlg
    Boolean vaDirectionInconsistentMsgFlg = false;
    // 感染症不一致チェックMsgFlg
    Boolean infectionNotConsistentMsgFlg = false;
    // マスタ削除MsgList
    List<String> mstDelFlgMsgList = new ArrayList<String>();
    String mstDelFlgMsg = "";
    // del #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen start
    // // マスタ削除MsgList
    // List<String> mstDelSpecialMsgList = new ArrayList<String>();
    // del #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen end
    // マスタ期限切れMsgList
    List<String> mstOverdueMsgList = new ArrayList<String>();
    String mstOverdueMsg = "";

    // 治療条件情報
    JSONObject indCondInfo = null;

    String tmp;
    try {
      if (ordNos == 0) {
        ordNos = null;
      }
      List<OrdMain> OrdMainList = ordMainDao.selectChkIndCondInfoData(ordNo, ordNos);
      if (OrdMainList != null && OrdMainList.size() > 0) {
        //add 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
        List<MstEquipmentMstMedicine> classTypeEquipment = ordMainDao.selectClassTypeFromMstEquipmentByFacility(OrdMainList.get(0).getFacilityCd());
        Map<Integer, MstEquipmentMstMedicine> mstEquipmentMap1 = new HashMap<Integer, MstEquipmentMstMedicine>();
        if(null != classTypeEquipment && classTypeEquipment.size()>0) {
          for (MstEquipmentMstMedicine classType : classTypeEquipment) {
            mstEquipmentMap1.put(classType.getCode(), classType);
          }
        }
        List<MstEquipmentMstMedicine> mstEquipmentMap = ordMainDao.selectClassTypeFromMstEquipmentByFacility1(OrdMainList.get(0).getFacilityCd());
        Map<Integer, MstEquipmentMstMedicine> mstEquipmentMap2 = new HashMap<Integer, MstEquipmentMstMedicine>();
        if(null != mstEquipmentMap && mstEquipmentMap.size()>0) {
          for (MstEquipmentMstMedicine classType : mstEquipmentMap) {
            mstEquipmentMap2.put(classType.getCode(), classType);
          }
        }
        List<MstEquipmentMstMedicine> classTypeEquipmentMix = ordMainDao.selectClassTypeFromMstEquipmentByFacility2(OrdMainList.get(0).getFacilityCd());
        Map<Integer, MstEquipmentMstMedicine> mstEquipmentMap3 = new HashMap<Integer, MstEquipmentMstMedicine>();
        if(null != classTypeEquipmentMix && classTypeEquipmentMix.size()>0) {
          for (MstEquipmentMstMedicine classType : classTypeEquipmentMix) {
            mstEquipmentMap3.put(classType.getCode(), classType);
          }
        }
        //add 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
        for (int i = 0; i < OrdMainList.size(); i++) {
          OrdMain ordMainData = OrdMainList.get(i);
          // 装置モード      mst_treatmentから取得：条件(ord_no)
          String treatModeCdString = getDeviceModeFromMstTreatment(ordMainData.getOrdNo());
          Integer treatModeCd = null;
          if (treatModeCdString != null) {
            treatModeCd = Integer.valueOf(treatModeCdString);
          }
          // 特殊浄化フラグ
          boolean isPurification = Objects.equals(treatModeCd, Treatment.DeviceMode.PURIFICATION);

          // 装置マスタ情報取得(ord_mainに紐付く情報の抽出)     mst_machine,mst_bed,ord_mainから取得
          HashMap<WebAPICheckConditionSend.PARAMKEY, Object> retMaster = this.getDataFromMstMachine(ordMainData.getOrdNo());
          // 装置設定情報の取得  ※ord_main,pat_mainから取得
          HashMap<WebAPICheckConditionSend.PARAMKEY, Object> retMachineSetting = this.getMachineSetting(ordMainData.getOrdNo());
          // 装置設定JSON(入力用) ※DBから取得
          JSONObject machineSettingDevJson = new JSONObject();

          machineSettingDevJson = (JSONObject) retMachineSetting.get(WebAPICheckConditionSend.PARAMKEY.DEV);

          // 指示:治療条件情報の取得
          if (StringUtils.isEmpty(ordMainData.getIndCondInfo())) {
            indCondInfo = null;
          } else {
            indCondInfo = new JSONObject(ordMainData.getIndCondInfo());
          }
          // マスタ削除チェック
          if (!mstDelFlg) {
            // 特殊浄化以外
            if (!isPurification) {
              // VA
              tmp = this.getDataFromIndCond(indCondInfo, "2");
              if (tmp != null) {
                MstVa mstVa = mstVaDao.selectByCd(Integer.valueOf(tmp));
                if (mstVa != null) {
                  if ("0".equals(mstVa.getIsDisp())) {
                    mstDelFlgMsg =  "治療条件" + "：" + mstVa.getVaName() + "：" + "VAマスタ";
                    mstDelFlgMsgList.add(mstDelFlgMsg);
                  }
                } else {
                  mstDelFlgMsg =  "治療条件" + "：" + "VA" + "：" + "VAマスタ";
                  mstDelFlgMsgList.add(mstDelFlgMsg);
                }
              }
              // ダイアライザ
              tmp = this.getDataFromIndCond(indCondInfo, "5");
              if (tmp != null) {
                Integer diaAnalyzer = Integer.parseInt(tmp);
                MstDialyzer dialyzer = mstDialyzerDao.selectByDialyzerCd(SelectOptions.get(), diaAnalyzer);
                if (dialyzer != null) {
                  if ("0".equals(dialyzer.getIsDisp())) {
                    mstDelFlgMsg =  "治療条件" + "：" + dialyzer.getModelNumber() + "：" + "ダイアライザマスタ";
                    mstDelFlgMsgList.add(mstDelFlgMsg);
                    // del #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen start
                    // mstDelSpecialMsgList.add(mstDelFlgMsg);
                    // del #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen end
                  }
                } else {
                  mstDelFlgMsg =  "治療条件" + "：" + "ダイアライザ" + "：" + "ダイアライザマスタ";
                  mstDelFlgMsgList.add(mstDelFlgMsg);
                  // del #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen start
                  // mstDelSpecialMsgList.add(mstDelFlgMsg);
                  // del #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen end
                }
              }
              // 吸着カラム
              tmp = this.getDataFromIndCond(indCondInfo, "6");
              if (tmp != null) {
                //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
//                MstEquipmentMstMedicine classType = this.getClassType(Integer.valueOf(tmp), 0, ordMainData.getFacilityCd());
                MstEquipmentMstMedicine classType = this.getClassTypeMap(Integer.valueOf(tmp), 0, mstEquipmentMap1, mstEquipmentMap2, mstEquipmentMap3);
                //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
                if (classType != null) {
                  if ("0".equals(classType.getIsDisp()) || "1".equals(classType.getIsDel())) {
                    mstDelFlgMsg =  "治療条件" + "：" + classType.getEquipmentName() + "：" + "医療材料マスタ";
                    mstDelFlgMsgList.add(mstDelFlgMsg);
                  }
                } else {
                  mstDelFlgMsg =  "治療条件" + "：" + "吸着カラム" + "：" + "医療材料マスタ";
                  mstDelFlgMsgList.add(mstDelFlgMsg);
                }
              }
              // 1次膜
              tmp = this.getDataFromIndCond(indCondInfo, "7");
              if (tmp != null) {
                //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
//                MstEquipmentMstMedicine classType = this.getClassType(Integer.valueOf(tmp), 0, ordMainData.getFacilityCd());
                MstEquipmentMstMedicine classType = this.getClassTypeMap(Integer.valueOf(tmp), 0, mstEquipmentMap1, mstEquipmentMap2, mstEquipmentMap3);
                //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
                if (classType != null) {
                  if ("0".equals(classType.getIsDisp()) || "1".equals(classType.getIsDel())) {
                    mstDelFlgMsg =  "治療条件" + "：" + classType.getEquipmentName() + "：" + "医療材料マスタ";
                    mstDelFlgMsgList.add(mstDelFlgMsg);
                  }
                } else {
                  mstDelFlgMsg =  "治療条件" + "：" + "1次膜" + "：" + "医療材料マスタ";
                  mstDelFlgMsgList.add(mstDelFlgMsg);
                }
              }
              // 2次膜
              tmp = this.getDataFromIndCond(indCondInfo, "8");
              if (tmp != null) {
                //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
//                MstEquipmentMstMedicine classType = this.getClassType(Integer.valueOf(tmp), 0, ordMainData.getFacilityCd());
                MstEquipmentMstMedicine classType = this.getClassTypeMap(Integer.valueOf(tmp), 0, mstEquipmentMap1, mstEquipmentMap2, mstEquipmentMap3);
                //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
                if (classType != null) {
                  if ("0".equals(classType.getIsDisp()) || "1".equals(classType.getIsDel())) {
                    mstDelFlgMsg =  "治療条件" + "：" + classType.getEquipmentName() + "：" + "医療材料マスタ";
                    mstDelFlgMsgList.add(mstDelFlgMsg);
                  }
                } else {
                  mstDelFlgMsg =  "治療条件" + "：" + "2次膜" + "：" + "医療材料マスタ";
                  mstDelFlgMsgList.add(mstDelFlgMsg);
                }
              }
              // 穿刺針(A針)
              tmp = this.getDataFromIndCond(indCondInfo, "9");
              if (tmp != null) {
                //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
//                MstEquipmentMstMedicine classType = this.getClassType(Integer.valueOf(tmp), 0, ordMainData.getFacilityCd());
                MstEquipmentMstMedicine classType = this.getClassTypeMap(Integer.valueOf(tmp), 0, mstEquipmentMap1, mstEquipmentMap2, mstEquipmentMap3);
                //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
                if (classType != null) {
                  if ("0".equals(classType.getIsDisp()) || "1".equals(classType.getIsDel())) {
                    mstDelFlgMsg =  "治療条件" + "：" + classType.getEquipmentName() + "：" + "医療材料マスタ";
                    mstDelFlgMsgList.add(mstDelFlgMsg);
                  }
                } else {
                  mstDelFlgMsg =  "治療条件" + "：" + "穿刺針(A針)" + "：" + "医療材料マスタ";
                  mstDelFlgMsgList.add(mstDelFlgMsg);
                }
              }
              // 穿刺針(V針)
              tmp = this.getDataFromIndCond(indCondInfo, "10");
              if (tmp != null) {
                //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
//                MstEquipmentMstMedicine classType = this.getClassType(Integer.valueOf(tmp), 0, ordMainData.getFacilityCd());
                MstEquipmentMstMedicine classType = this.getClassTypeMap(Integer.valueOf(tmp), 0, mstEquipmentMap1, mstEquipmentMap2, mstEquipmentMap3);
                //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
                if (classType != null) {
                  if ("0".equals(classType.getIsDisp()) || "1".equals(classType.getIsDel())) {
                    mstDelFlgMsg =  "治療条件" + "：" + classType.getEquipmentName() + "：" + "医療材料マスタ";
                    mstDelFlgMsgList.add(mstDelFlgMsg);
                  }
                } else {
                  mstDelFlgMsg =  "治療条件" + "：" + "穿刺針(V針)" + "：" + "医療材料マスタ";
                  mstDelFlgMsgList.add(mstDelFlgMsg);
                }
              }
              // 穿刺針(SN)
              tmp = this.getDataFromIndCond(indCondInfo, "11");
              if (tmp != null) {
                //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
//                MstEquipmentMstMedicine classType = this.getClassType(Integer.valueOf(tmp), 0, ordMainData.getFacilityCd());
                MstEquipmentMstMedicine classType = this.getClassTypeMap(Integer.valueOf(tmp), 0, mstEquipmentMap1, mstEquipmentMap2, mstEquipmentMap3);
                //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
                if (classType != null) {
                  if ("0".equals(classType.getIsDisp()) || "1".equals(classType.getIsDel())) {
                    mstDelFlgMsg =  "治療条件" + "：" + classType.getEquipmentName() + "：" + "医療材料マスタ";
                    mstDelFlgMsgList.add(mstDelFlgMsg);
                  }
                } else {
                  mstDelFlgMsg =  "治療条件" + "：" + "穿刺針(SN)" + "：" + "医療材料マスタ";
                  mstDelFlgMsgList.add(mstDelFlgMsg);
                }
              }
              // 血液回路
              tmp = this.getDataFromIndCond(indCondInfo, "13");
              if (tmp != null) {
                //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
//                MstEquipmentMstMedicine classType = this.getClassType(Integer.valueOf(tmp), 0, ordMainData.getFacilityCd());
                MstEquipmentMstMedicine classType = this.getClassTypeMap(Integer.valueOf(tmp), 0, mstEquipmentMap1, mstEquipmentMap2, mstEquipmentMap3);
                //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
                if (classType != null) {
                  if ("0".equals(classType.getIsDisp()) || "1".equals(classType.getIsDel())) {
                    mstDelFlgMsg =  "治療条件" + "：" + classType.getEquipmentName() + "：" + "医療材料マスタ";
                    mstDelFlgMsgList.add(mstDelFlgMsg);
                  }
                } else {
                  mstDelFlgMsg =  "治療条件" + "：" + "血液回路" + "：" + "医療材料マスタ";
                  mstDelFlgMsgList.add(mstDelFlgMsg);
                }
              }
              if (Treatment.DeviceMode.OHDF.equals(treatModeCd)
                || Treatment.DeviceMode.OHF.equals(treatModeCd)
                || Treatment.DeviceMode.HDF.equals(treatModeCd)
                || Treatment.DeviceMode.HF.equals(treatModeCd)
                || Treatment.DeviceMode.I_HDF.equals(treatModeCd)) {
                // 補液
                tmp = this.getDataFromIndCond(indCondInfo, "19");
                if (tmp != null) {
                  /* add by shiyw 2024-01-29 [#10196]ord_mainのデータ定義の修正 --start */
                  int classTypeflg = 1;
                  String medicineType = String.valueOf(indCondInfo.getJSONObject("19").get("medicine_type"));
                  if("1".equals(medicineType)){ // 薬剤場合
                    classTypeflg = 1;
                  }else  if("2".equals(medicineType)){ // 調整薬剤場合
                    classTypeflg = 2;
                  }
                  /* add by shiyw 2024-01-29 [#10196]ord_mainのデータ定義の修正 --end */
                  //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
//                  MstEquipmentMstMedicine classType = this.getClassType(Integer.valueOf(tmp), 1, ordMainData.getFacilityCd());
                  MstEquipmentMstMedicine classType = this.getClassTypeMap(Integer.valueOf(tmp), classTypeflg, mstEquipmentMap1, mstEquipmentMap2, mstEquipmentMap3);
                  //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
                  if (classType != null) {
                    if ("0".equals(classType.getIsDisp()) || "1".equals(classType.getIsDel())) {
                      mstDelFlgMsg =  "治療条件" + "：" + classType.getMedicineName() + "：" + "薬剤マスタ";
                      mstDelFlgMsgList.add(mstDelFlgMsg);
                      // del #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen start
                      // mstDelSpecialMsgList.add(mstDelFlgMsg);
                      // del #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen end
                    } else if ("0".equals(classType.getIsDispMix()) || "1".equals(classType.getIsDelMix())) {
                      mstDelFlgMsg =  "治療条件" + "：" + classType.getMedicineName() + "：" + "調製薬剤マスタ";
                      mstDelFlgMsgList.add(mstDelFlgMsg);
                      // del #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen start
                      // mstDelSpecialMsgList.add(mstDelFlgMsg);
                      // del #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen end
                    }
                  } else {
                    mstDelFlgMsg =  "治療条件" + "：" + "補液" + "：" + "薬剤マスタ";
                    mstDelFlgMsgList.add(mstDelFlgMsg);
                    // del #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen start
                    // mstDelSpecialMsgList.add(mstDelFlgMsg);
                    // del #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen end
                  }
                }
              }
              // 透析液
              tmp = this.getDataFromIndCond(indCondInfo, "15");
              if (tmp != null) {
                /* add by shiyw 2024-01-29 [#10196]ord_mainのデータ定義の修正 --start */
                int classTypeflg = 1;
                String medicineType = String.valueOf(indCondInfo.getJSONObject("15").get("medicine_type"));
                if("1".equals(medicineType)){ // 薬剤場合
                  classTypeflg = 1;
                }else  if("2".equals(medicineType)){ // 調整薬剤場合
                  classTypeflg = 2;
                }
                /* add by shiyw 2024-01-29 [#10196]ord_mainのデータ定義の修正 --end */
                //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
//                MstEquipmentMstMedicine classType = this.getClassType(Integer.valueOf(tmp), 1, ordMainData.getFacilityCd());
                MstEquipmentMstMedicine classType = this.getClassTypeMap(Integer.valueOf(tmp), classTypeflg, mstEquipmentMap1, mstEquipmentMap2, mstEquipmentMap3);
                //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
                if (classType != null) {
                  if ("0".equals(classType.getIsDisp()) || "1".equals(classType.getIsDel())) {
                    mstDelFlgMsg =  "治療条件" + "：" + classType.getMedicineName() + "：" + "薬剤マスタ";
                    mstDelFlgMsgList.add(mstDelFlgMsg);
                  } else if ("0".equals(classType.getIsDispMix()) || "1".equals(classType.getIsDelMix())) {
                    mstDelFlgMsg =  "治療条件" + "：" + classType.getMedicineName() + "：" + "調製薬剤マスタ";
                    mstDelFlgMsgList.add(mstDelFlgMsg);
                  }
                } else {
                  mstDelFlgMsg =  "治療条件" + "：" + "透析液" + "：" + "薬剤マスタ";
                  mstDelFlgMsgList.add(mstDelFlgMsg);
                }
              }
              // 抗凝固剤
              tmp = this.getDataFromIndCond(indCondInfo, "25");
              if (tmp != null) {
                /* add by shiyw 2024-01-29 [#10196]ord_mainのデータ定義の修正 --start */
                int classTypeflg = 1;
                String medicineType = String.valueOf(indCondInfo.getJSONObject("25").get("medicine_type"));
                if("1".equals(medicineType)){ // 薬剤場合
                  classTypeflg = 1;
                }else  if("2".equals(medicineType)){ // 調整薬剤場合
                  classTypeflg = 2;
                }
                /* add by shiyw 2024-01-29 [#10196]ord_mainのデータ定義の修正 --end */
                //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
//                MstEquipmentMstMedicine classType = this.getClassType(Integer.valueOf(tmp), 1, ordMainData.getFacilityCd());
                MstEquipmentMstMedicine classType = this.getClassTypeMap(Integer.valueOf(tmp), classTypeflg, mstEquipmentMap1, mstEquipmentMap2, mstEquipmentMap3);
                //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
                if (classType != null) {
                  if ("0".equals(classType.getIsDisp()) || "1".equals(classType.getIsDel())) {
                    mstDelFlgMsg =  "治療条件" + "：" + classType.getMedicineName() + "：" + "薬剤マスタ";
                    mstDelFlgMsgList.add(mstDelFlgMsg);
                  } else if ("0".equals(classType.getIsDispMix()) || "1".equals(classType.getIsDelMix())) {
                    mstDelFlgMsg =  "治療条件" + "：" + classType.getMedicineName() + "：" + "調製薬剤マスタ";
                    mstDelFlgMsgList.add(mstDelFlgMsg);
                    // del #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen start
                    // mstDelSpecialMsgList.add(mstDelFlgMsg);
                    // del #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen end
                  }
                } else {
                  mstDelFlgMsg =  "治療条件" + "：" + "抗凝固剤" + "：" + "薬剤マスタ";
                  mstDelFlgMsgList.add(mstDelFlgMsg);
                  // del #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen start
                  // mstDelSpecialMsgList.add(mstDelFlgMsg);
                  // del #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen end
                }
              }
            }
            // 指示：投与薬剤情報
            if (!StringUtils.isEmpty(ordMainData.getIndMediInfo())) {
              ObjectMapper mapper = new ObjectMapper();
              JsonNode jsonNodeIndMedi = mapper.readTree(ordMainData.getIndMediInfo());
              for (int j = 0; j < jsonNodeIndMedi.size(); j++) {
                JsonNode jsonNode = jsonNodeIndMedi.get(j);
                // jsonNodeIndMediは読み取り専用のため、ObjectNodeに変換
                ObjectNode objectNode = jsonNode.deepCopy().asObject();

                tmp = objectNode.get("cd").asText();
                if (tmp != null) {
                  /* add by shiyw 2024-01-29 [#10196]ord_mainのデータ定義の修正 --start */
                  int classTypeflg = 1;
                  String medicineType = objectNode.get("medicine_type").asText();
                  if("1".equals(medicineType)){ // 薬剤場合
                    classTypeflg = 1;
                  }else  if("2".equals(medicineType)){ // 調整薬剤場合
                    classTypeflg = 2;
                  }
                  /* add by shiyw 2024-01-29 [#10196]ord_mainのデータ定義の修正 --end */
                  //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
//                  MstEquipmentMstMedicine classType = this.getClassType(Integer.valueOf(tmp), 1, ordMainData.getFacilityCd());
                  MstEquipmentMstMedicine classType = this.getClassTypeMap(Integer.valueOf(tmp), classTypeflg, mstEquipmentMap1, mstEquipmentMap2, mstEquipmentMap3);
                  //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
                  if (classType != null) {
                    if ("0".equals(classType.getIsDisp()) || "1".equals(classType.getIsDel())) {
                      mstDelFlgMsg =  "投与薬剤" + "：" + classType.getMedicineName() + "：" + "薬剤マスタ";
                      mstDelFlgMsgList.add(mstDelFlgMsg);
                    } else if ("0".equals(classType.getIsDispMix()) || "1".equals(classType.getIsDelMix())) {
                      mstDelFlgMsg =  "投与薬剤" + "：" + classType.getMedicineName() + "：" + "調製薬剤マスタ";
                      mstDelFlgMsgList.add(mstDelFlgMsg);
                    }
                  } else {
                    mstDelFlgMsg =  "投与薬剤" + "：" + "投与薬剤" + "：" + "薬剤マスタ";
                    mstDelFlgMsgList.add(mstDelFlgMsg);
                  }
                }
              }
            }
            // 指示：医療材料情報
            if (!StringUtils.isEmpty(ordMainData.getIndEquipInfo())) {
              ObjectMapper mapper = new ObjectMapper();
              JsonNode jsonNodeIndEquip = mapper.readTree(ordMainData.getIndEquipInfo());
              for (int j = 0; j < jsonNodeIndEquip.size(); j++) {
                JsonNode jsonNode = jsonNodeIndEquip.get(j);
                // jsonNodeIndMediは読み取り専用のため、ObjectNodeに変換
                ObjectNode objectNode = jsonNode.deepCopy().asObject();

                tmp = objectNode.get("cd").asText();
                if (tmp != null) {
                  // add #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen start
                  if ("1".equals(objectNode.get("equip_type").asText())) {
                    Integer diaAnalyzer = Integer.parseInt(tmp);
                    MstDialyzer dialyzer = mstDialyzerDao.selectByDialyzerCd(SelectOptions.get(), diaAnalyzer);
                    if (dialyzer != null) {
                      if ("0".equals(dialyzer.getIsDisp())) {
                        mstDelFlgMsg =  "医療材料" + "：" + dialyzer.getModelNumber() + "：" + "ダイアライザマスタ";
                        mstDelFlgMsgList.add(mstDelFlgMsg);
                      }
                    } else {
                      mstDelFlgMsg =  "医療材料" + "：" + "ダイアライザ" + "：" + "ダイアライザマスタ";
                      mstDelFlgMsgList.add(mstDelFlgMsg);
                    }
                  } else {
                  // add #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen end
                  //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
//                  MstEquipmentMstMedicine classType = this.getClassType(Integer.valueOf(tmp), 0, ordMainData.getFacilityCd());
                  MstEquipmentMstMedicine classType = this.getClassTypeMap(Integer.valueOf(tmp), 0, mstEquipmentMap1, mstEquipmentMap2, mstEquipmentMap3);
                  //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
                  if (classType != null) {
                    if ("0".equals(classType.getIsDisp()) || "1".equals(classType.getIsDel())) {
                      mstDelFlgMsg =  "医療材料" + "：" + classType.getEquipmentName() + "：" + "医療材料マスタ";
                      mstDelFlgMsgList.add(mstDelFlgMsg);
                    }
                  } else {
                    mstDelFlgMsg =  "医療材料" + "：" + "医療材料" + "：" + "医療材料マスタ";
                    mstDelFlgMsgList.add(mstDelFlgMsg);
                  }
                  // add #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen start
                  }
                  // add #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen end
                }
              }
            }
          }
          // マスタ期限切れチェック
          if (!mstOverdueFlg) {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
            String sysDate = sdf.format(new Date());
            // ダイアライザ
            tmp = this.getDataFromIndCond(indCondInfo, "5");
            if (tmp != null) {
              Integer diaAnalyzer = Integer.parseInt(tmp);
              MstDialyzer dialyzer = mstDialyzerDao.selectByDialyzerCd(SelectOptions.get(), diaAnalyzer);
              if (dialyzer != null && !StringUtils.isEmpty(dialyzer.getUseEndDate())) {
                // add #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen start
                // if (Integer.valueOf(sysDate) > Integer.valueOf(dialyzer.getUseEndDate())) {
                if (dialyzer.getUseEndDate() != null && Integer.valueOf(sysDate) > Integer.valueOf(dialyzer.getUseEndDate())) {
                // add #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen end
                  mstOverdueMsg =  "治療条件" + "：" + dialyzer.getModelNumber() + "：" + "ダイアライザマスタ";
                  mstOverdueMsgList.add(mstOverdueMsg);
                }
              }
            }
            // 吸着カラム
            tmp = this.getDataFromIndCond(indCondInfo, "6");
            if (tmp != null) {
              //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
//              MstEquipmentMstMedicine classType = this.getClassType(Integer.valueOf(tmp), 0, ordMainData.getFacilityCd());
              MstEquipmentMstMedicine classType = this.getClassTypeMap(Integer.valueOf(tmp), 0, mstEquipmentMap1, mstEquipmentMap2, mstEquipmentMap3);
              //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
              if (classType != null && !StringUtils.isEmpty(classType.getUseEndDate())) {
                // add #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen start
                // if (Integer.valueOf(sysDate) > Integer.valueOf(classType.getUseEndDate())) {
                if (classType.getUseEndDate() != null && Integer.valueOf(sysDate) > Integer.valueOf(classType.getUseEndDate())) {
                // add #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen end
                  mstOverdueMsg =  "治療条件" + "：" + classType.getEquipmentName() + "：" + "医療材料マスタ";
                  mstOverdueMsgList.add(mstOverdueMsg);
                }
              }
            }
            // 1次膜
            tmp = this.getDataFromIndCond(indCondInfo, "7");
            if (tmp != null) {
              //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
//              MstEquipmentMstMedicine classType = this.getClassType(Integer.valueOf(tmp), 0, ordMainData.getFacilityCd());
              MstEquipmentMstMedicine classType = this.getClassTypeMap(Integer.valueOf(tmp), 0, mstEquipmentMap1, mstEquipmentMap2, mstEquipmentMap3);
              //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
              if (classType != null && !StringUtils.isEmpty(classType.getUseEndDate())) {
                // add #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen start
                // if (Integer.valueOf(sysDate) > Integer.valueOf(classType.getUseEndDate())) {
                if (classType.getUseEndDate() != null && Integer.valueOf(sysDate) > Integer.valueOf(classType.getUseEndDate())) {
                // add #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen end
                  mstOverdueMsg =  "治療条件" + "：" + classType.getEquipmentName() + "：" + "医療材料マスタ";
                  mstOverdueMsgList.add(mstOverdueMsg);
                }
              }
            }
            // 2次膜
            tmp = this.getDataFromIndCond(indCondInfo, "8");
            if (tmp != null) {
              //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
//              MstEquipmentMstMedicine classType = this.getClassType(Integer.valueOf(tmp), 0, ordMainData.getFacilityCd());
              MstEquipmentMstMedicine classType = this.getClassTypeMap(Integer.valueOf(tmp), 0, mstEquipmentMap1, mstEquipmentMap2, mstEquipmentMap3);
              //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
              if (classType != null && !StringUtils.isEmpty(classType.getUseEndDate())) {
                // add #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen start
                // if (Integer.valueOf(sysDate) > Integer.valueOf(classType.getUseEndDate())) {
                if (classType.getUseEndDate() != null && Integer.valueOf(sysDate) > Integer.valueOf(classType.getUseEndDate())) {
                // add #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen end
                  mstOverdueMsg =  "治療条件" + "：" + classType.getEquipmentName() + "：" + "医療材料マスタ";
                  mstOverdueMsgList.add(mstOverdueMsg);
                }
              }
            }
            // 穿刺針(A針)
            tmp = this.getDataFromIndCond(indCondInfo, "9");
            if (tmp != null) {
              //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
//              MstEquipmentMstMedicine classType = this.getClassType(Integer.valueOf(tmp), 0, ordMainData.getFacilityCd());
              MstEquipmentMstMedicine classType = this.getClassTypeMap(Integer.valueOf(tmp), 0, mstEquipmentMap1, mstEquipmentMap2, mstEquipmentMap3);
              //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
              if (classType != null && !StringUtils.isEmpty(classType.getUseEndDate())) {
                // add #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen start
                // if (Integer.valueOf(sysDate) > Integer.valueOf(classType.getUseEndDate())) {
                if (classType.getUseEndDate() != null && Integer.valueOf(sysDate) > Integer.valueOf(classType.getUseEndDate())) {
                // add #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen end
                  mstOverdueMsg =  "治療条件" + "：" + classType.getEquipmentName() + "：" + "医療材料マスタ";
                  mstOverdueMsgList.add(mstOverdueMsg);
                }
              }
            }
            // 穿刺針(V針)
            tmp = this.getDataFromIndCond(indCondInfo, "10");
            if (tmp != null) {
              //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
//              MstEquipmentMstMedicine classType = this.getClassType(Integer.valueOf(tmp), 0, ordMainData.getFacilityCd());
              MstEquipmentMstMedicine classType = this.getClassTypeMap(Integer.valueOf(tmp), 0, mstEquipmentMap1, mstEquipmentMap2, mstEquipmentMap3);
              //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
              if (classType != null && !StringUtils.isEmpty(classType.getUseEndDate())) {
                // add #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen start
                // if (Integer.valueOf(sysDate) > Integer.valueOf(classType.getUseEndDate())) {
                if (classType.getUseEndDate() != null && Integer.valueOf(sysDate) > Integer.valueOf(classType.getUseEndDate())) {
                // add #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen end
                  mstOverdueMsg =  "治療条件" + "：" + classType.getEquipmentName() + "：" + "医療材料マスタ";
                  mstOverdueMsgList.add(mstOverdueMsg);
                }
              }
            }
            // 穿刺針(SN)
            tmp = this.getDataFromIndCond(indCondInfo, "11");
            if (tmp != null) {
              //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
//              MstEquipmentMstMedicine classType = this.getClassType(Integer.valueOf(tmp), 0, ordMainData.getFacilityCd());
              MstEquipmentMstMedicine classType = this.getClassTypeMap(Integer.valueOf(tmp), 0, mstEquipmentMap1, mstEquipmentMap2, mstEquipmentMap3);
              //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
              if (classType != null && !StringUtils.isEmpty(classType.getUseEndDate())) {
                // add #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen start
                // if (Integer.valueOf(sysDate) > Integer.valueOf(classType.getUseEndDate())) {
                if (classType.getUseEndDate() != null && Integer.valueOf(sysDate) > Integer.valueOf(classType.getUseEndDate())) {
                // add #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen end
                  mstOverdueMsg =  "治療条件" + "：" + classType.getEquipmentName() + "：" + "医療材料マスタ";
                  mstOverdueMsgList.add(mstOverdueMsg);
                }
              }
            }
            // 血液回路
            tmp = this.getDataFromIndCond(indCondInfo, "13");
            if (tmp != null) {
              //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
//              MstEquipmentMstMedicine classType = this.getClassType(Integer.valueOf(tmp), 0, ordMainData.getFacilityCd());
              MstEquipmentMstMedicine classType = this.getClassTypeMap(Integer.valueOf(tmp), 0, mstEquipmentMap1, mstEquipmentMap2, mstEquipmentMap3);
              //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
              if (classType != null && !StringUtils.isEmpty(classType.getUseEndDate())) {
                // add #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen start
                // if (Integer.valueOf(sysDate) > Integer.valueOf(classType.getUseEndDate())) {
                if (classType.getUseEndDate() != null && Integer.valueOf(sysDate) > Integer.valueOf(classType.getUseEndDate())) {
                // add #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen end
                  mstOverdueMsg =  "治療条件" + "：" + classType.getEquipmentName() + "：" + "医療材料マスタ";
                  mstOverdueMsgList.add(mstOverdueMsg);
                }
              }
            }
            // 透析液
            tmp = this.getDataFromIndCond(indCondInfo, "15");
            if (tmp != null) {
              /* add by shiyw 2024-01-29 [#10196]ord_mainのデータ定義の修正 --start */
              int classTypeflg = 1;
              String medicineType = String.valueOf(indCondInfo.getJSONObject("15").get("medicine_type"));
              if("1".equals(medicineType)){ // 薬剤場合
                classTypeflg = 1;
              }else  if("2".equals(medicineType)){ // 調整薬剤場合
                classTypeflg = 2;
              }
              /* add by shiyw 2024-01-29 [#10196]ord_mainのデータ定義の修正 --end */
              //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
//              MstEquipmentMstMedicine classType = this.getClassType(Integer.valueOf(tmp), 1, ordMainData.getFacilityCd());
              MstEquipmentMstMedicine classType = this.getClassTypeMap(Integer.valueOf(tmp), classTypeflg, mstEquipmentMap1, mstEquipmentMap2, mstEquipmentMap3);
              //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
              if (classType != null && !StringUtils.isEmpty(classType.getUseEndDate())) {
                // add #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen start
                // if (Integer.valueOf(sysDate) > Integer.valueOf(classType.getUseEndDate())) {
                if (classType.getUseEndDate() != null && Integer.valueOf(sysDate) > Integer.valueOf(classType.getUseEndDate())) {
                // add #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen end
                  mstOverdueMsg =  "治療条件" + "：" + classType.getMedicineName() + "：" + "薬剤マスタ";
                  mstOverdueMsgList.add(mstOverdueMsg);
                }
              }
            }
            // 補液
            tmp = this.getDataFromIndCond(indCondInfo, "19");
            if (tmp != null) {
              /* add by shiyw 2024-01-29 [#10196]ord_mainのデータ定義の修正 --start */
              int classTypeflg = 1;
              String medicineType = String.valueOf(indCondInfo.getJSONObject("19").get("medicine_type"));
              if("1".equals(medicineType)){ // 薬剤場合
                classTypeflg = 1;
              }else  if("2".equals(medicineType)){ // 調整薬剤場合
                classTypeflg = 2;
              }
              /* add by shiyw 2024-01-29 [#10196]ord_mainのデータ定義の修正 --end */
              //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
//              MstEquipmentMstMedicine classType = this.getClassType(Integer.valueOf(tmp), 1, ordMainData.getFacilityCd());
              MstEquipmentMstMedicine classType = this.getClassTypeMap(Integer.valueOf(tmp), classTypeflg, mstEquipmentMap1, mstEquipmentMap2, mstEquipmentMap3);
              //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
              if (classType != null && !StringUtils.isEmpty(classType.getUseEndDate())) {
                // add #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen start
                // if (Integer.valueOf(sysDate) > Integer.valueOf(classType.getUseEndDate())) {
                if (classType.getUseEndDate() != null && Integer.valueOf(sysDate) > Integer.valueOf(classType.getUseEndDate())) {
                // add #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen end
                  mstOverdueMsg =  "治療条件" + "：" + classType.getMedicineName() + "：" + "薬剤マスタ";
                  mstOverdueMsgList.add(mstOverdueMsg);
                }
              }
            }
            // 抗凝固剤
            tmp = this.getDataFromIndCond(indCondInfo, "25");
            if (tmp != null) {
              /* add by shiyw 2024-01-29 [#10196]ord_mainのデータ定義の修正 --start */
              int classTypeflg = 1;
              String medicineType = String.valueOf(indCondInfo.getJSONObject("25").get("medicine_type"));
              if("1".equals(medicineType)){ // 薬剤場合
                classTypeflg = 1;
              }else  if("2".equals(medicineType)){ // 調整薬剤場合
                classTypeflg = 2;
              }
              /* add by shiyw 2024-01-29 [#10196]ord_mainのデータ定義の修正 --end */
              //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
//              MstEquipmentMstMedicine classType = this.getClassType(Integer.valueOf(tmp), 1, ordMainData.getFacilityCd());
              MstEquipmentMstMedicine classType =this.getClassTypeMap(Integer.valueOf(tmp), classTypeflg, mstEquipmentMap1, mstEquipmentMap2, mstEquipmentMap3);
              //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
              if (classType != null && !StringUtils.isEmpty(classType.getUseEndDate())) {
                // add #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen start
                // if (Integer.valueOf(sysDate) > Integer.valueOf(classType.getUseEndDate())) {
                if (classType.getUseEndDate() != null && Integer.valueOf(sysDate) > Integer.valueOf(classType.getUseEndDate())) {
                // add #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen end
                  mstOverdueMsg =  "治療条件" + "：" + classType.getMedicineName() + "：" + "薬剤マスタ";
                  mstOverdueMsgList.add(mstOverdueMsg);
                }
              }
            }
            // 指示：投与薬剤情報
            if (!StringUtils.isEmpty(ordMainData.getIndMediInfo())) {
              ObjectMapper mapper = new ObjectMapper();
              JsonNode jsonNodeIndMedi = mapper.readTree(ordMainData.getIndMediInfo());
              for (int j = 0; j < jsonNodeIndMedi.size(); j++) {
                JsonNode jsonNode = jsonNodeIndMedi.get(j);
                // jsonNodeIndMediは読み取り専用のため、ObjectNodeに変換
                ObjectNode objectNode = jsonNode.deepCopy().asObject();

                tmp = objectNode.get("cd").asText();
                if (tmp != null) {
                  /* add by shiyw 2024-01-29 [#10196]ord_mainのデータ定義の修正 --start */
                  int classTypeflg = 1;
                  String medicineType = objectNode.get("medicine_type").asText();
                  if("1".equals(medicineType)){ // 薬剤場合
                    classTypeflg = 1;
                  }else  if("2".equals(medicineType)){ // 調整薬剤場合
                    classTypeflg = 2;
                  }
                  /* add by shiyw 2024-01-29 [#10196]ord_mainのデータ定義の修正 --end */
                  //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
//                  MstEquipmentMstMedicine classType = this.getClassType(Integer.valueOf(tmp), 1, ordMainData.getFacilityCd());
                  MstEquipmentMstMedicine classType = this.getClassTypeMap(Integer.valueOf(tmp), classTypeflg, mstEquipmentMap1, mstEquipmentMap2, mstEquipmentMap3);
                  //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
                  if (classType != null && !StringUtils.isEmpty(classType.getUseEndDate())) {
                    // add #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen start
                    // if (Integer.valueOf(sysDate) > Integer.valueOf(classType.getUseEndDate())) {
                    if (classType.getUseEndDate() != null && Integer.valueOf(sysDate) > Integer.valueOf(classType.getUseEndDate())) {
                    // add #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen end
                      mstOverdueMsg =  "投与薬剤" + "：" + classType.getMedicineName() + "：" + "薬剤マスタ";
                      mstOverdueMsgList.add(mstOverdueMsg);
                    }
                  }
                }
              }
            }
            // 指示：医療材料情報
            if (!StringUtils.isEmpty(ordMainData.getIndEquipInfo())) {
              ObjectMapper mapper = new ObjectMapper();
              JsonNode jsonNodeIndEquip = mapper.readTree(ordMainData.getIndEquipInfo());
              for (int j = 0; j < jsonNodeIndEquip.size(); j++) {
                JsonNode jsonNode = jsonNodeIndEquip.get(j);
                // jsonNodeIndMediは読み取り専用のため、ObjectNodeに変換
                ObjectNode objectNode = jsonNode.deepCopy().asObject();

                tmp = objectNode.get("cd").asText();
                if (tmp != null) {
                  // add #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen start
                  // mod #9973 Resolve null exception for key 20240117 ztc start
//                  if ("1".equals(objectNode.get("equip_type").toString())) {
                  if ("1".equals(objectNode.get("equip_type").asText())) {
                  // mod #9973 Resolve null exception for key 20240117 ztc end
                    Integer diaAnalyzer = Integer.parseInt(tmp);
                    MstDialyzer dialyzer = mstDialyzerDao.selectByDialyzerCd(SelectOptions.get(), diaAnalyzer);
                    if (dialyzer != null) {
                      // add #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen start
                      // if (Integer.valueOf(sysDate) > Integer.valueOf(dialyzer.getUseEndDate())) {
                      if (dialyzer.getUseEndDate() != null && Integer.valueOf(sysDate) > Integer.valueOf(dialyzer.getUseEndDate())) {
                        // add #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen end
                        mstOverdueMsg =  "医療材料" + "：" + dialyzer.getModelNumber() + "：" + "ダイアライザマスタ";
                        mstOverdueMsgList.add(mstOverdueMsg);
                      }
                    }
                  } else {
                  // add #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen end
                  //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
//                  MstEquipmentMstMedicine classType = this.getClassType(Integer.valueOf(tmp), 0, ordMainData.getFacilityCd());
                    // #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen start
                    // MstEquipmentMstMedicine classType = this.getClassTypeMap(Integer.valueOf(tmp), 1, mstEquipmentMap1, mstEquipmentMap2, mstEquipmentMap3);
                    MstEquipmentMstMedicine classType = this.getClassTypeMap(Integer.valueOf(tmp), 0, mstEquipmentMap1, mstEquipmentMap2, mstEquipmentMap3);
                    // #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen end
                  //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
                  if (classType != null && !StringUtils.isEmpty(classType.getUseEndDate())) {
                    // add #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen start
                    // if (Integer.valueOf(sysDate) > Integer.valueOf(classType.getUseEndDate())) {
                    if (classType.getUseEndDate() != null && Integer.valueOf(sysDate) > Integer.valueOf(classType.getUseEndDate())) {
                    // add #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen end
                      mstOverdueMsg =  "医療材料" + "：" + classType.getEquipmentName() + "：" + "医療材料マスタ";
                      mstOverdueMsgList.add(mstOverdueMsg);
                    }
                  }
                }
                // add #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen start
                }
                // add #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen end
              }
            }
          }
          // 分類不一致チェック
          if (!chkIndCondInfoFlg) {
            // 吸着カラム
            tmp = this.getDataFromIndCond(indCondInfo, "6");
            if (tmp != null) {
              //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
//              MstEquipmentMstMedicine classType = this.getClassType(Integer.valueOf(tmp), 0, ordMainData.getFacilityCd());
              MstEquipmentMstMedicine classType = this.getClassTypeMap(Integer.valueOf(tmp), 0, mstEquipmentMap1, mstEquipmentMap2, mstEquipmentMap3);
              //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
              if (classType != null) {
                if (4 != classType.getClassType()) {
                  msg = "吸着カラム" + "：" + classType.getEquipmentName() + "：" + classType.getClassName();
                  msgList.add(msg);
                }
              }
            }
            // 1次膜
            tmp = this.getDataFromIndCond(indCondInfo, "7");
            if (tmp != null) {
              //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
//              MstEquipmentMstMedicine classType = this.getClassType(Integer.valueOf(tmp), 0, ordMainData.getFacilityCd());
              MstEquipmentMstMedicine classType = this.getClassTypeMap(Integer.valueOf(tmp), 0, mstEquipmentMap1, mstEquipmentMap2, mstEquipmentMap3);
              //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
              if (classType != null) {
                if (5 != classType.getClassType() && 6 != classType.getClassType()) {
                  msg = "1次膜" + "：" + classType.getEquipmentName() + "：" + classType.getClassName();
                  msgList.add(msg);
                }
              }
            }
            // 2次膜
            tmp = this.getDataFromIndCond(indCondInfo, "8");
            if (tmp != null) {
              //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
//              MstEquipmentMstMedicine classType = this.getClassType(Integer.valueOf(tmp), 0, ordMainData.getFacilityCd());
              MstEquipmentMstMedicine classType = this.getClassTypeMap(Integer.valueOf(tmp), 0, mstEquipmentMap1, mstEquipmentMap2, mstEquipmentMap3);
              //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
              if (classType != null) {
                if (5 != classType.getClassType() && 6 != classType.getClassType()) {
                  msg = "2次膜" + "：" + classType.getEquipmentName() + "：" + classType.getClassName();
                  msgList.add(msg);
                }
              }
            }
            // 穿刺針(A針)
            tmp = this.getDataFromIndCond(indCondInfo, "9");
            if (tmp != null) {
              //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
//              MstEquipmentMstMedicine classType = this.getClassType(Integer.valueOf(tmp), 0, ordMainData.getFacilityCd());
              MstEquipmentMstMedicine classType = this.getClassTypeMap(Integer.valueOf(tmp), 0, mstEquipmentMap1, mstEquipmentMap2, mstEquipmentMap3);
              //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
              if (classType != null) {
                if (2 != classType.getClassType()) {
                  msg = "穿刺針(A針)" + "：" + classType.getEquipmentName() + "：" + classType.getClassName();
                  msgList.add(msg);
                }
              }
            }
            // 穿刺針(V針)
            tmp = this.getDataFromIndCond(indCondInfo, "10");
            if (tmp != null) {
              //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
//              MstEquipmentMstMedicine classType = this.getClassType(Integer.valueOf(tmp), 0, ordMainData.getFacilityCd());
              MstEquipmentMstMedicine classType = this.getClassTypeMap(Integer.valueOf(tmp), 0, mstEquipmentMap1, mstEquipmentMap2, mstEquipmentMap3);
              //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
              if (classType != null) {
                if (2 != classType.getClassType()) {
                  msg = "穿刺針(V針)" + "：" + classType.getEquipmentName() + "：" + classType.getClassName();
                  msgList.add(msg);
                }
              }
            }
            // 穿刺針(SN)
            tmp = this.getDataFromIndCond(indCondInfo, "11");
            if (tmp != null) {
              //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
//              MstEquipmentMstMedicine classType = this.getClassType(Integer.valueOf(tmp), 0, ordMainData.getFacilityCd());
              MstEquipmentMstMedicine classType = this.getClassTypeMap(Integer.valueOf(tmp), 0, mstEquipmentMap1, mstEquipmentMap2, mstEquipmentMap3);
              //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
              if (classType != null) {
                if (3 != classType.getClassType()) {
                  msg = "穿刺針(SN)" + "：" + classType.getEquipmentName() + "：" + classType.getClassName();
                  msgList.add(msg);
                }
              }
            }
            // 血液回路
            tmp = this.getDataFromIndCond(indCondInfo, "13");
            if (tmp != null) {
              //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
//              MstEquipmentMstMedicine classType = this.getClassType(Integer.valueOf(tmp), 0, ordMainData.getFacilityCd());
              MstEquipmentMstMedicine classType = this.getClassTypeMap(Integer.valueOf(tmp), 0, mstEquipmentMap1, mstEquipmentMap2, mstEquipmentMap3);
              //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
              if (classType != null) {
                if (1 != classType.getClassType()) {
                  msg = "血液回路" + "：" + classType.getEquipmentName() + "：" + classType.getClassName();
                  msgList.add(msg);
                }
              }
            }

            // オンライン治療（OHDF、I-HDF、OHF）の場合
            if (Treatment.DeviceMode.OHDF.equals(treatModeCd)
              || Treatment.DeviceMode.OHF.equals(treatModeCd)
              || Treatment.DeviceMode.I_HDF.equals(treatModeCd)) {
              // 補液
              tmp = this.getDataFromIndCond(indCondInfo, "19");
              if (tmp != null) {
                /* add by shiyw 2024-01-29 [#10196]ord_mainのデータ定義の修正 --start */
                int classTypeflg = 1;
                String medicineType = String.valueOf(indCondInfo.getJSONObject("19").get("medicine_type"));
                if("1".equals(medicineType)){ // 薬剤場合
                  classTypeflg = 1;
                }else  if("2".equals(medicineType)){ // 調整薬剤場合
                  classTypeflg = 2;
                }
                /* add by shiyw 2024-01-29 [#10196]ord_mainのデータ定義の修正 --end */
                //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
//                MstEquipmentMstMedicine classType = this.getClassType(Integer.valueOf(tmp), 1, ordMainData.getFacilityCd());
                MstEquipmentMstMedicine classType = this.getClassTypeMap(Integer.valueOf(tmp), classTypeflg, mstEquipmentMap1, mstEquipmentMap2, mstEquipmentMap3);
                //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
                if (classType != null) {
                  if (2 != classType.getClassType()) {
                    msg = "補液" + "：" + classType.getMedicineName() + "：" + classType.getClassName();
                    msgList.add(msg);
                  }
                }
              }
              // 透析液
              tmp = this.getDataFromIndCond(indCondInfo, "15");
              if (tmp != null) {
                /* add by shiyw 2024-01-29 [#10196]ord_mainのデータ定義の修正 --start */
                int classTypeflg = 1;
                String medicineType = String.valueOf(indCondInfo.getJSONObject("15").get("medicine_type"));
                if("1".equals(medicineType)){ // 薬剤場合
                  classTypeflg = 1;
                }else  if("2".equals(medicineType)){ // 調整薬剤場合
                  classTypeflg = 2;
                }
                /* add by shiyw 2024-01-29 [#10196]ord_mainのデータ定義の修正 --end */
                //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
//                MstEquipmentMstMedicine classType = this.getClassType(Integer.valueOf(tmp), 1, ordMainData.getFacilityCd());
                MstEquipmentMstMedicine classType = this.getClassTypeMap(Integer.valueOf(tmp), classTypeflg, mstEquipmentMap1, mstEquipmentMap2, mstEquipmentMap3);
                //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
                if (classType != null) {
                  if (2 != classType.getClassType()) {
                    msg = "透析液" + "：" + classType.getMedicineName() + "：" + classType.getClassName();
                    msgList.add(msg);
                  }
                }
              }
              // 抗凝固剤
              tmp = this.getDataFromIndCond(indCondInfo, "25");
              if (tmp != null) {
                /* add by shiyw 2024-01-29 [#10196]ord_mainのデータ定義の修正 --start */
                int classTypeflg = 1;
                String medicineType = String.valueOf(indCondInfo.getJSONObject("25").get("medicine_type"));
                if("1".equals(medicineType)){ // 薬剤場合
                  classTypeflg = 1;
                }else  if("2".equals(medicineType)){ // 調整薬剤場合
                  classTypeflg = 2;
                }
                /* add by shiyw 2024-01-29 [#10196]ord_mainのデータ定義の修正 --end */
                //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
//                MstEquipmentMstMedicine classType = this.getClassType(Integer.valueOf(tmp), 1, ordMainData.getFacilityCd());
                MstEquipmentMstMedicine classType = this.getClassTypeMap(Integer.valueOf(tmp), classTypeflg, mstEquipmentMap1, mstEquipmentMap2, mstEquipmentMap3);
                //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
                if (classType != null) {
                  if (1 != classType.getClassType()) {
                    msg = "抗凝固剤" + "：" + classType.getMedicineName() + "：" + classType.getClassName();
                    msgList.add(msg);
                  }
                }
              }
            } else {
              // 透析液
              tmp = this.getDataFromIndCond(indCondInfo, "15");
              if (tmp != null) {
                /* add by shiyw 2024-01-29 [#10196]ord_mainのデータ定義の修正 --start */
                int classTypeflg = 1;
                String medicineType = String.valueOf(indCondInfo.getJSONObject("15").get("medicine_type"));
                if("1".equals(medicineType)){ // 薬剤場合
                  classTypeflg = 1;
                }else  if("2".equals(medicineType)){ // 調整薬剤場合
                  classTypeflg = 2;
                }
                /* add by shiyw 2024-01-29 [#10196]ord_mainのデータ定義の修正 --end */
                //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
//                MstEquipmentMstMedicine classType = this.getClassType(Integer.valueOf(tmp), 1, ordMainData.getFacilityCd());
                MstEquipmentMstMedicine classType = this.getClassTypeMap(Integer.valueOf(tmp), classTypeflg, mstEquipmentMap1, mstEquipmentMap2, mstEquipmentMap3);
                //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
                if (classType != null) {
                  if (2 != classType.getClassType()) {
                    msg = "透析液" + "：" + classType.getMedicineName() + "：" + classType.getClassName();
                    msgList.add(msg);
                  }
                }
              }
              // 補液
              tmp = this.getDataFromIndCond(indCondInfo, "19");
              if (tmp != null) {
                /* add by shiyw 2024-01-29 [#10196]ord_mainのデータ定義の修正 --start */
                int classTypeflg = 1;
                String medicineType = String.valueOf(indCondInfo.getJSONObject("19").get("medicine_type"));
                if("1".equals(medicineType)){ // 薬剤場合
                  classTypeflg = 1;
                }else  if("2".equals(medicineType)){ // 調整薬剤場合
                  classTypeflg = 2;
                }
                /* add by shiyw 2024-01-29 [#10196]ord_mainのデータ定義の修正 --end */
                //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
//                MstEquipmentMstMedicine classType = this.getClassType(Integer.valueOf(tmp), 1, ordMainData.getFacilityCd());
                MstEquipmentMstMedicine classType = this.getClassTypeMap(Integer.valueOf(tmp), classTypeflg, mstEquipmentMap1, mstEquipmentMap2, mstEquipmentMap3);
                //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
                if (classType != null) {
                  if (3 != classType.getClassType()) {
                    msg = "補液" + "：" + classType.getMedicineName() + "：" + classType.getClassName();
                    msgList.add(msg);
                  }
                }
              }
              // 抗凝固剤
              tmp = this.getDataFromIndCond(indCondInfo, "25");
              if (tmp != null) {
                /* add by shiyw 2024-01-29 [#10196]ord_mainのデータ定義の修正 --start */
                int classTypeflg = 1;
                String medicineType = String.valueOf(indCondInfo.getJSONObject("25").get("medicine_type"));
                if("1".equals(medicineType)){ // 薬剤場合
                  classTypeflg = 1;
                }else  if("2".equals(medicineType)){ // 調整薬剤場合
                  classTypeflg = 2;
                }
                /* add by shiyw 2024-01-29 [#10196]ord_mainのデータ定義の修正 --end */
                //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
//                MstEquipmentMstMedicine classType = this.getClassType(Integer.valueOf(tmp), 1, ordMainData.getFacilityCd());
                MstEquipmentMstMedicine classType = this.getClassTypeMap(Integer.valueOf(tmp), classTypeflg, mstEquipmentMap1, mstEquipmentMap2, mstEquipmentMap3);
                //mod 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
                if (classType != null) {
                  if (1 != classType.getClassType()) {
                    msg = "抗凝固剤" + "：" + classType.getMedicineName() + "：" + classType.getClassName();
                    msgList.add(msg);
                  }
                }
              }
            }
          }
          if (!isPurification) {
            // 1.治療条件未登録のチェック
            // ダイアライザ
            tmp = this.getDataFromIndCond(indCondInfo, "5");
            if (tmp == null) {
              indCondInfoNoLoginMsg = "ダイアライザ";
              indCondInfoNoLoginMsgList.add(indCondInfoNoLoginMsg);
            }
            // 除水量制限
            tmp = this.getDataFromIndCond(indCondInfo, "4");
            if (tmp == null) {
              indCondInfoNoLoginMsg = "除水量制限";
              indCondInfoNoLoginMsgList.add(indCondInfoNoLoginMsg);
            }

            // I-HDF & AFBF治療モードの以外場合（特殊浄化例外）、シングルニードルの「使用する」チェックON　AND　穿刺針（SN）未選択の場合
            if (!Treatment.DeviceMode.I_HDF.equals(treatModeCd)
              && !Treatment.DeviceMode.AFBF.equals(treatModeCd)) {
              // シングルニードル使用選択
              tmp = this.getDataFromIndCond(indCondInfo, "12");
              if (!StringUtils.isEmpty(tmp) && !"0".equals(tmp)) {
                // 穿刺針(SN)
                String tmpSn = this.getDataFromIndCond(indCondInfo, "11");
                if (tmpSn == null) {
                  indCondInfoNoLoginMsg = "シングルニードル使用選択";
                  indCondInfoNoLoginMsgList.add(indCondInfoNoLoginMsg);
                }
              }
            }
            // 血流量
            tmp = this.getDataFromIndCond(indCondInfo, "14");
            if (tmp == null) {
              indCondInfoNoLoginMsg = "血流量";
              indCondInfoNoLoginMsgList.add(indCondInfoNoLoginMsg);
            }
            // 透析液流量
            tmp = this.getDataFromIndCond(indCondInfo, "16");
            if (tmp == null) {
              indCondInfoNoLoginMsg = "透析液流量";
              indCondInfoNoLoginMsgList.add(indCondInfoNoLoginMsg);
            }
            // 透析液温度
            tmp = this.getDataFromIndCond(indCondInfo, "18");
            if (tmp == null) {
              indCondInfoNoLoginMsg = "透析液温度";
              indCondInfoNoLoginMsgList.add(indCondInfoNoLoginMsg);
            }
            // 抗凝固剤
            tmp = this.getDataFromIndCond(indCondInfo, "25");
            if (tmp == null) {
              indCondInfoNoLoginMsg = "抗凝固剤";
              indCondInfoNoLoginMsgList.add(indCondInfoNoLoginMsg);
            }
            // FNSI-add 仕様は未定です 徐 start
            // TODO: 2021/05/28 仕様は未定ですが、今後対応します。馮さんに連絡してください
//            // IP使用選択
//            tmp = this.getDataFromIndCond(indCondInfo, "29");
//            if (tmp == null) {
//              indCondInfoNoLoginMsg = "IP使用選択";
//              indCondInfoNoLoginMsgList.add(indCondInfoNoLoginMsg);
//            }
//            // IPスタート
//            tmp = this.getDataFromIndCond(indCondInfo, "30");
//            if (tmp == null) {
//              indCondInfoNoLoginMsg = "IPスタート";
//              indCondInfoNoLoginMsgList.add(indCondInfoNoLoginMsg);
//            }
//            // IPワンショット量
//            tmp = this.getDataFromIndCond(indCondInfo, "31");
//            if (tmp == null) {
//              indCondInfoNoLoginMsg = "IPワンショット量";
//              indCondInfoNoLoginMsgList.add(indCondInfoNoLoginMsg);
//            }
            // FNSI-add 仕様は未定です 徐 end
            // IP速度
            tmp = this.getDataFromIndCond(indCondInfo, "32");
            if (tmp == null) {
              indCondInfoNoLoginMsg = "IP速度";
              indCondInfoNoLoginMsgList.add(indCondInfoNoLoginMsg);
            }
            // IP速度最大値
            tmp = this.getDataFromIndCond(indCondInfo, "33");
            if (tmp == null) {
              indCondInfoNoLoginMsg = "IP速度最大値";
              indCondInfoNoLoginMsgList.add(indCondInfoNoLoginMsg);
            }
            // 自動ワンショット
            tmp = this.getDataFromIndCond(indCondInfo, "34");
            if (tmp == null) {
              indCondInfoNoLoginMsg = "自動ワンショット";
              indCondInfoNoLoginMsgList.add(indCondInfoNoLoginMsg);
            }
            // IP電源自動切り
            tmp = this.getDataFromIndCond(indCondInfo, "35");
            if (tmp == null) {
              indCondInfoNoLoginMsg = "IP電源自動切り";
              indCondInfoNoLoginMsgList.add(indCondInfoNoLoginMsg);
            }
            // IP電源自動切り時間
            tmp = this.getDataFromIndCond(indCondInfo, "36");
            if (tmp == null) {
              indCondInfoNoLoginMsg = "IP電源自動切り時間";
              indCondInfoNoLoginMsgList.add(indCondInfoNoLoginMsg);
            }
            // IP電源OKモニタ切り
            tmp = this.getDataFromIndCond(indCondInfo, "37");
            if (tmp == null) {
              indCondInfoNoLoginMsg = "IP電源OKモニタ切り";
              indCondInfoNoLoginMsgList.add(indCondInfoNoLoginMsg);
            }
            // IP電源OKモニタ切り時間
            tmp = this.getDataFromIndCond(indCondInfo, "38");
            if (tmp == null) {
              indCondInfoNoLoginMsg = "IP電源OKモニタ切り時間";
              indCondInfoNoLoginMsgList.add(indCondInfoNoLoginMsg);
            }
            if (Treatment.DeviceMode.OHDF.equals(treatModeCd)
              || Treatment.DeviceMode.OHF.equals(treatModeCd)
              || Treatment.DeviceMode.HDF.equals(treatModeCd)
              || Treatment.DeviceMode.HF.equals(treatModeCd)
              || Treatment.DeviceMode.I_HDF.equals(treatModeCd)) {
              // 補液
              tmp = this.getDataFromIndCond(indCondInfo, "19");
              if (tmp == null) {
                indCondInfoNoLoginMsg = "補液";
                indCondInfoNoLoginMsgList.add(indCondInfoNoLoginMsg);
              }
              // 補液選択
              tmp = this.getDataFromIndCond(indCondInfo, "21");
              if (tmp == null) {
                indCondInfoNoLoginMsg = "補液選択";
                indCondInfoNoLoginMsgList.add(indCondInfoNoLoginMsg);
              }
              // 補液温度
              tmp = this.getDataFromIndCond(indCondInfo, "23");
              if (tmp == null) {
                indCondInfoNoLoginMsg = "補液温度";
                indCondInfoNoLoginMsgList.add(indCondInfoNoLoginMsg);
              }
            }
            // 2.治療条件上限のチェック
            // 補液量、補液速度の整合チェック
            // 補液量
            Double condReplenishMeasure = 0.0;
            tmp = this.getDataFromIndCond(indCondInfo, "20");
            try {
              if (tmp != null) {
                condReplenishMeasure = Double.parseDouble(tmp);
              }
            } catch (Exception e) {
              EventLogMessage eventLogMessage = new EventLogMessage();
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
              eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
              logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            }
            if (Treatment.DeviceMode.HDF.equals(treatModeCd)
              || Treatment.DeviceMode.HF.equals(treatModeCd)) {
              if (condReplenishMeasure > 30) {
                indCondInfoTopLimitMsg = "補液量";
                indCondInfoTopLimitMsgList.add(indCondInfoTopLimitMsg);
              }
            }
            if (Treatment.DeviceMode.OHDF.equals(treatModeCd)
              || Treatment.DeviceMode.OHF.equals(treatModeCd)) {
              // 補液量上限
              String replenishMeasureUperLimit = this.getItemFromJson(machineSettingDevJson, "A", WebAPICheckConditionSend.MACHINESETTINGKEY.ADR0383.get());

              // 補液量上限(double)
              Double dUpperLimit = 0.0;
              try {
                if (replenishMeasureUperLimit != null) {
                  dUpperLimit = Double.parseDouble(replenishMeasureUperLimit);
                }
              } catch (Exception e) {
                EventLogMessage eventLogMessage = new EventLogMessage();
                // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
                eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
                // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
                logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
              }
              if (condReplenishMeasure > dUpperLimit) {
                indCondInfoTopLimitMsg = "補液量";
                indCondInfoTopLimitMsgList.add(indCondInfoTopLimitMsg);
              }
            }
            // HDF、HF、OHDF、OHF、AFBF 治療モードの場合、補液速度上限値のチェック
            if (Treatment.DeviceMode.HDF.equals(treatModeCd)
              || Treatment.DeviceMode.HF.equals(treatModeCd)
              || Treatment.DeviceMode.OHDF.equals(treatModeCd)
              || Treatment.DeviceMode.OHF.equals(treatModeCd)
              || Treatment.DeviceMode.AFBF.equals(treatModeCd)) {
              // 補液速度
              Double replenishSpeed = 0.0;
              tmp = this.getDataFromIndCond(indCondInfo, "24");
              try {
                if (tmp != null) {
                  replenishSpeed = Double.parseDouble(tmp);
                }
              } catch (Exception e) {
                EventLogMessage eventLogMessage = new EventLogMessage();
                // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
                logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
              }
              // 補液選択 1:前補液 0:後補液
              tmp = this.getDataFromIndCond(indCondInfo, "21");
              // 補液速度操作範囲上限
              String replenishSpeedUperLimit = null;
              // HDF治療モードの場合
              if (Treatment.DeviceMode.HDF.equals(treatModeCd)) {
                if ("1".equals(tmp)) {
                  // 前補液  補液速度操作範囲上限（HDF）
                  replenishSpeedUperLimit = this.getItemFromJson(machineSettingDevJson, "A", WebAPICheckConditionSend.MACHINESETTINGKEY.ADR0185.get());
                } else if ("0".equals(tmp)) {
                  // 後補液  補液速度操作範囲上限（HDF）
                  replenishSpeedUperLimit = this.getItemFromJson(machineSettingDevJson, "B", WebAPICheckConditionSend.MACHINESETTINGKEY.ADRB0031.get());
                }
                // HF治療モードの場合
              } else if (Treatment.DeviceMode.HF.equals(treatModeCd)) {
                if ("1".equals(tmp)) {
                  // 前補液  補液速度操作範囲上限（HF）
                  replenishSpeedUperLimit = this.getItemFromJson(machineSettingDevJson, "A", WebAPICheckConditionSend.MACHINESETTINGKEY.ADR0186.get());
                } else if ("0".equals(tmp)) {
                  // 後補液  補液速度操作範囲上限（HF）
                  replenishSpeedUperLimit = this.getItemFromJson(machineSettingDevJson, "B", WebAPICheckConditionSend.MACHINESETTINGKEY.ADRB0032.get());
                }
                // OHDF治療モードの場合
              } else if (Treatment.DeviceMode.OHDF.equals(treatModeCd)) {
                if ("1".equals(tmp)) {
                  // 前補液  補液速度操作範囲上限（OHDF）
                  replenishSpeedUperLimit = this.getItemFromJson(machineSettingDevJson, "A", WebAPICheckConditionSend.MACHINESETTINGKEY.ADR0396.get());
                } else if ("0".equals(tmp)) {
                  // 後補液  補液速度操作範囲上限（OHDF）
                  replenishSpeedUperLimit = this.getItemFromJson(machineSettingDevJson, "B", WebAPICheckConditionSend.MACHINESETTINGKEY.ADRB0034.get());
                }
                // OHF治療モードの場合
              } else if (Treatment.DeviceMode.OHF.equals(treatModeCd)) {
                if ("1".equals(tmp)) {
                  // 前補液  補液速度操作範囲上限（OHF）
                  replenishSpeedUperLimit = this.getItemFromJson(machineSettingDevJson, "A", WebAPICheckConditionSend.MACHINESETTINGKEY.ADR0397.get());
                } else if ("0".equals(tmp)) {
                  // 後補液  補液速度操作範囲上限（OHF）
                  replenishSpeedUperLimit = this.getItemFromJson(machineSettingDevJson, "B", WebAPICheckConditionSend.MACHINESETTINGKEY.ADRB0035.get());
                }
                // AFBF治療モードの場合
              } else if (Treatment.DeviceMode.AFBF.equals(treatModeCd)) {
                // 治療モードAFBFでは、補液比率使用選択を「使用する」に設定している場合、AFBF速度操作範囲上限下限のチェックをする必要は無い
                String replenishSpeedUperAuto = this.getItemFromJson(machineSettingDevJson, "A", WebAPICheckConditionSend.MACHINESETTINGKEY.ADR0384.get());

                if (!"1".equals(replenishSpeedUperAuto)) {
                  // 補液速度設定範囲下限（AFBF）
                  String replenishSpeedLowerLimit = this.getItemFromJson(machineSettingDevJson, "A", WebAPICheckConditionSend.MACHINESETTINGKEY.ADR0387.get());
                  Double replenishSpeedDownLimit = 0.0;
                  try {
                    if (replenishSpeedLowerLimit != null) {
                      replenishSpeedDownLimit = Double.parseDouble(replenishSpeedLowerLimit);
                    }
                  } catch (Exception e) {
                    EventLogMessage eventLogMessage = new EventLogMessage();
                    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
                    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
                  }
                  if (replenishSpeed < replenishSpeedDownLimit) {
                    indCondInfoLowerLimitMsg = "補液速度";
                    indCondInfoLowerLimitMsgList.add(indCondInfoLowerLimitMsg);
                  }
                }
                // 補液速度設定範囲上限（AFBF）
                replenishSpeedUperLimit = this.getItemFromJson(machineSettingDevJson, "A", WebAPICheckConditionSend.MACHINESETTINGKEY.ADR0386.get());
              }
              // 治療モードAFBFでは、補液比率使用選択を「使用する」に設定している場合、AFBF速度操作範囲上限下限のチェックをする必要は無い
              String replenishSpeedUperAuto = this.getItemFromJson(machineSettingDevJson, "A", WebAPICheckConditionSend.MACHINESETTINGKEY.ADR0384.get());
              if (!"1".equals(replenishSpeedUperAuto) || !Treatment.DeviceMode.AFBF.equals(treatModeCd)) {
                // 補液速度操作範囲上限
                Double replenishSpeedTopLimit = 0.0;
                try {
                  if (replenishSpeedUperLimit != null) {
                    replenishSpeedTopLimit = Double.parseDouble(replenishSpeedUperLimit);
                  }
                } catch (Exception e) {
                  EventLogMessage eventLogMessage = new EventLogMessage();
                  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
                  logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
                }
                if (replenishSpeed > replenishSpeedTopLimit) {
                  indCondInfoTopLimitMsg = "補液速度";
                  indCondInfoTopLimitMsgList.add(indCondInfoTopLimitMsg);
                }
              }
            }
            // IP速度の最大値チェック
            // IP速度
            tmp = this.getDataFromIndCond(indCondInfo, "32");
            Double ipSpeed = 0.0;
            try {
              if (tmp != null) {
                ipSpeed = Double.parseDouble(tmp);
              }
            } catch (Exception e) {
              EventLogMessage eventLogMessage = new EventLogMessage();
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
              logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            }
            // IP速度最大値
            tmp = this.getDataFromIndCond(indCondInfo, "33");
            Double ipSpeedTopLimit = 0.0;
            try {
              if (tmp != null) {
                ipSpeedTopLimit = Double.parseDouble(tmp);
              }
            } catch (Exception e) {
              EventLogMessage eventLogMessage = new EventLogMessage();
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
              logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            }
            if (ipSpeed > ipSpeedTopLimit) {
              indCondInfoTopLimitMsg = "IP速度";
              indCondInfoTopLimitMsgList.add(indCondInfoTopLimitMsg);
            }
            // オンライン治療（OHDF、I-HDF、OHF）の場合
            if (Treatment.DeviceMode.OHDF.equals(treatModeCd)
              || Treatment.DeviceMode.OHF.equals(treatModeCd)
              || Treatment.DeviceMode.I_HDF.equals(treatModeCd)) {

              if (retMaster != null) {
                // 通信フォーマット
                String comFormat = (String) retMaster.get(WebAPICheckConditionSend.PARAMKEY.COM_FORMAT_CD);
                // 通信種別
                String comType = (String) retMaster.get(WebAPICheckConditionSend.PARAMKEY.COM_TYPE);

                String overNxseries = (String) retMaster.get(WebAPICheckConditionSend.PARAMKEY.OVER_NXSERIES);
                // 治療時間
                tmp = this.getDataFromIndCond(indCondInfo, "1");
                Integer treatmentTime = 0;
                try {
                  if (tmp != null) {
                    treatmentTime = Integer.valueOf(tmp);
                  }
                } catch (Exception e) {
                  EventLogMessage eventLogMessage = new EventLogMessage();
                  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
                  logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
                }

                // 治療時間の上限チェック
                // 新通信＋over_nxseries=0 or 医器工V3：上限7:59
                if (("1".equals(comType) && "0".equals(overNxseries))
                  || ("3".equals(comType) && "W".equals(comFormat))) {
                  if (treatmentTime > 479) {
                    indCondInfoTopLimitMsg = "治療時間";
                    indCondInfoTopLimitMsgList.add(indCondInfoTopLimitMsg);
                  }
                }

                // 新通信＋over_nxseries=1 or 医器工V4：上限10:00
                if (("1".equals(comType) && "1".equals(overNxseries))
                  || ("3".equals(comType) && "V".equals(comFormat))) {
                  if (treatmentTime > 600) {
                    indCondInfoTopLimitMsg = "治療時間";
                    indCondInfoTopLimitMsgList.add(indCondInfoTopLimitMsg);
                  }
                }
              }
            }
            // 血流量の上限チェック
            // 血流量
            Double bloodFlow = 0.0;
            tmp = this.getDataFromIndCond(indCondInfo, "14");
            try {
              if (tmp != null) {
                bloodFlow = Double.parseDouble(tmp);
              }
            } catch (Exception e) {
              EventLogMessage eventLogMessage = new EventLogMessage();
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
              logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            }
            // 血流量の上限
            Double bloodFlowTopLimit = 0.0;
            String bloodFlowUperLimit = this.getItemFromJson(machineSettingDevJson, "A", WebAPICheckConditionSend.MACHINESETTINGKEY.ADR0179.get());

            if (bloodFlowUperLimit != null) {
              try {
                bloodFlowTopLimit = Double.parseDouble(bloodFlowUperLimit);
              } catch (Exception e) {
                EventLogMessage eventLogMessage = new EventLogMessage();
                // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
                logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
              }
            }
            if (bloodFlow > bloodFlowTopLimit) {
              indCondInfoTopLimitMsg = "血流量";
              indCondInfoTopLimitMsgList.add(indCondInfoTopLimitMsg);
            }
            // 透析液温度の上限チェック
            // 透析液温度
            Double DialysateTemperature = 0.0;
            tmp = this.getDataFromIndCond(indCondInfo, "18");
            try {
              if (tmp != null) {
                DialysateTemperature = Double.parseDouble(tmp);
              }
            } catch (Exception e) {
              EventLogMessage eventLogMessage = new EventLogMessage();
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
              logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            }

            // 透析液温度の上限
            Double DialysateTemperatureTopLimit = 0.0;
            String DialysateTemperatureUperLimit = this.getItemFromJson(machineSettingDevJson, "A", WebAPICheckConditionSend.MACHINESETTINGKEY.ADR0182.get());
            // add #7810 2022/11/17 透析液温度操作範囲下限を超えた際の条件送信時のチェックがされていない。 dou start
            Double DialysateTemperatureLowerLimit = 0.0;
            String strDialysateTemperatureLowerLimit = this.getItemFromJson(machineSettingDevJson, "A", WebAPICheckConditionSend.MACHINESETTINGKEY.ADR0183.get());
            // add #7810 2022/11/17 透析液温度操作範囲下限を超えた際の条件送信時のチェックがされていない。 dou end
            // add #7810 2022/11/20 BVUFCを使用する予定に除水プログラム使用するを展開する場合は警告。。 dou start
            // 除水プログラム
            String diversionProgram = this.getItemFromJson(machineSettingDevJson, "A", WebAPICheckConditionSend.MACHINESETTINGKEY.ADR0290.get());
            // BVUFCプログラム
            String bvufcProgram = this.getItemFromJson(machineSettingDevJson, "A", WebAPICheckConditionSend.MACHINESETTINGKEY.ADR0196.get());
            if (!StringUtils.isEmpty(diversionProgram) && !"0".equals(diversionProgram)
              && !StringUtils.isEmpty(bvufcProgram) && !"0".equals(bvufcProgram)) {
              if (Treatment.DeviceMode.HD.equals(treatModeCd)
                || Treatment.DeviceMode.ECUM.equals(treatModeCd)
                || Treatment.DeviceMode.HDF.equals(treatModeCd)
                || Treatment.DeviceMode.HF.equals(treatModeCd)
                || Treatment.DeviceMode.OHDF.equals(treatModeCd)
                || Treatment.DeviceMode.OHF.equals(treatModeCd)
                || Treatment.DeviceMode.AFBF.equals(treatModeCd)) {
                diversionBvufcFlg = true;
              }
            }
            // add #7810 2022/11/20 BVUFCを使用する予定に除水プログラム使用するを展開する場合は警告。。 dou end

            if (bloodFlowUperLimit != null) {
              try {
                DialysateTemperatureTopLimit = Double.parseDouble(DialysateTemperatureUperLimit);
                // add #7810 2022/11/17 透析液温度操作範囲下限を超えた際の条件送信時のチェックがされていない。 dou start
                DialysateTemperatureLowerLimit = Double.parseDouble(strDialysateTemperatureLowerLimit);
                // add #7810 2022/11/17 透析液温度操作範囲下限を超えた際の条件送信時のチェックがされていない。 dou end
              } catch (Exception e) {
                EventLogMessage eventLogMessage = new EventLogMessage();
                // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
                logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
              }
            }
            if (DialysateTemperature > DialysateTemperatureTopLimit) {
              indCondInfoTopLimitMsg = "透析液温度";
              indCondInfoTopLimitMsgList.add(indCondInfoTopLimitMsg);
              // add #7810 2022/11/17 透析液温度操作範囲下限を超えた際の条件送信時のチェックがされていない。 dou start
            } else if (DialysateTemperature < DialysateTemperatureLowerLimit) {
              indCondInfoTopLimitMsg = "透析液温度";
              indCondInfoLowerLimitMsgList.add(indCondInfoTopLimitMsg);
              // add #7810 2022/11/17 透析液温度操作範囲下限を超えた際の条件送信時のチェックがされていない。 dou end
            }
            // 3.I-HDF治療モードの場合,I-HDF治療条件不整合のチェック
            if (Treatment.DeviceMode.I_HDF.equals(treatModeCd)) {
              // シングルニードル使用する
              tmp = this.getDataFromIndCond(indCondInfo, "12");
              if (!StringUtils.isEmpty(tmp) && !"0".equals(tmp)) {
                indCondInfoUseIHDFMsg = "シングルニードル";
                indCondInfoUseIHDFMsgList.add(indCondInfoUseIHDFMsg);
              }
              // 積層型ダイアライザ
              tmp = this.getDataFromIndCond(indCondInfo, "5");
              if (tmp != null) {
                Integer diaAnalyzer = Integer.parseInt(tmp);
                MstDialyzer dialyzer = mstDialyzerDao.selectByDialyzerCd(SelectOptions.get(), diaAnalyzer);
                if (!StringUtils.isEmpty(dialyzer.getDialyzerType()) && !"0".equals(dialyzer.getDialyzerType())) {
                  indCondInfoUseIHDFMsg = "積層型ダイアライザ";
                  indCondInfoUseIHDFMsgList.add(indCondInfoUseIHDFMsg);
                }
              }
              // 除水プログラム使用する(ＵＦＲプログラム電源ＳＷ)
              // del #7810 2022/11/20 BVUFCを使用する予定に除水プログラム使用するを展開する場合は警告。。 dou start
              // String diversionProgram = this.getItemFromJson(machineSettingDevJson, "A", WebAPICheckConditionSend.MACHINESETTINGKEY.ADR0290.get());
              // del #7810 2022/11/20 BVUFCを使用する予定に除水プログラム使用するを展開する場合は警告。。 dou end
              if (!StringUtils.isEmpty(diversionProgram) && !"0".equals(diversionProgram)) {
                indCondInfoUseIHDFMsg = "除水プログラム";
                indCondInfoUseIHDFMsgList.add(indCondInfoUseIHDFMsg);
              }
              // QB・QDプログラム使用する
              // QBプログラム電源
              String QBProgram = this.getItemFromJson(machineSettingDevJson, "A", WebAPICheckConditionSend.MACHINESETTINGKEY.ADR0430.get());
              // QDプログラム電源
              String QDProgram = this.getItemFromJson(machineSettingDevJson, "A", WebAPICheckConditionSend.MACHINESETTINGKEY.ADR0431.get());
              if (!StringUtils.isEmpty(QBProgram) && !"0".equals(QBProgram)) {
                indCondInfoUseIHDFMsg = "QBプログラム電源";
                indCondInfoUseIHDFMsgList.add(indCondInfoUseIHDFMsg);
              }
              if (!StringUtils.isEmpty(QDProgram) && !"0".equals(QDProgram)) {
                indCondInfoUseIHDFMsg = "QDプログラム電源";
                indCondInfoUseIHDFMsgList.add(indCondInfoUseIHDFMsg);
              }
              // BV-UFC使用する
              // BV-UFC使用選択
              // del #7810 2022/11/20 BVUFCを使用する予定に除水プログラム使用するを展開する場合は警告。。 dou start
              // String bvufcProgram = this.getItemFromJson(machineSettingDevJson, "A", WebAPICheckConditionSend.MACHINESETTINGKEY.ADR0196.get());
              // del #7810 2022/11/20 BVUFCを使用する予定に除水プログラム使用するを展開する場合は警告。。 dou end
              if (!StringUtils.isEmpty(bvufcProgram) && !"0".equals(bvufcProgram)) {
                indCondInfoUseIHDFMsg = "BV-UFC";
                indCondInfoUseIHDFMsgList.add(indCondInfoUseIHDFMsg);
              }
            }
            // 4.AFBF治療モードの場合、治療条件不整合のチェック
            if (Treatment.DeviceMode.AFBF.equals(treatModeCd)) {
              // シングルニードル使用する
              tmp = this.getDataFromIndCond(indCondInfo, "12");
              if (!StringUtils.isEmpty(tmp) && !"0".equals(tmp)) {
                indCondInfoUseAFBFMsg = "シングルニードル";
                indCondInfoUseAFBFMsgList.add(indCondInfoUseAFBFMsg);
              }
              // 透析液濃度プログラム使用する
              String dialysisSolutionConcentrationProgram = this.getItemFromJson(machineSettingDevJson, "A", WebAPICheckConditionSend.MACHINESETTINGKEY.ADR0340.get());

              if (!StringUtils.isEmpty(dialysisSolutionConcentrationProgram) && !"0".equals(dialysisSolutionConcentrationProgram)) {
                indCondInfoUseAFBFMsg = "透析液濃度プログラム";
                indCondInfoUseAFBFMsgList.add(indCondInfoUseAFBFMsg);
              }
              // Na注入プログラム使用する。
              String naInjectionProgram = this.getItemFromJson(machineSettingDevJson, "A", WebAPICheckConditionSend.MACHINESETTINGKEY.ADR0315.get());
              if (!StringUtils.isEmpty(naInjectionProgram) && !"0".equals(naInjectionProgram)) {
                indCondInfoUseAFBFMsg = "Na注入プログラム。";
                indCondInfoUseAFBFMsgList.add(indCondInfoUseAFBFMsg);
              }
              if (!"4".equals(ordMainData.getRstDialysisState())) {
                // TMP自動追従チェックON
                String tmpAutomaticTracking = this.getItemFromJson(machineSettingDevJson, "A", WebAPICheckConditionSend.MACHINESETTINGKEY.ADR0240.get());
                // mod #6440 2022/10/12 治療モードAFBFを通信共通プロトコルの装置に条件送信する時のメッセージが異常 dou start
                // if (!StringUtils.isEmpty(tmpAutomaticTracking) && "0".equals(tmpAutomaticTracking)) {
                // 通信フォーマット
                String comFormat = (String) retMaster.get(WebAPICheckConditionSend.PARAMKEY.COM_FORMAT_CD);
                // 通信種別
                String comType = (String) retMaster.get(WebAPICheckConditionSend.PARAMKEY.COM_TYPE);
                if (!StringUtils.isEmpty(tmpAutomaticTracking) && "0".equals(tmpAutomaticTracking)
                  && !("3".equals(comType) && ("V".equals(comFormat) || "W".equals(comFormat)))) {
                  // mod #6440 2022/10/12 治療モードAFBFを通信共通プロトコルの装置に条件送信する時のメッセージが異常 dou end
                  tmpAutomaticTrackingFlg = true;
                }
              }
            }
            // 5.シングルニードル使用するの場合、SN治療条件不整合
            // シングルニードル使用する
            tmp = this.getDataFromIndCond(indCondInfo, "12");
            if (!StringUtils.isEmpty(tmp) && !"0".equals(tmp)) {
              // BV-UFC使用する
              // del #7810 2022/11/20 BVUFCを使用する予定に除水プログラム使用するを展開する場合は警告。。 dou start
              // String bvufcProgram = this.getItemFromJson(machineSettingDevJson, "A", WebAPICheckConditionSend.MACHINESETTINGKEY.ADR0196.get());
              // del #7810 2022/11/20 BVUFCを使用する予定に除水プログラム使用するを展開する場合は警告。。 dou end
              if (!StringUtils.isEmpty(bvufcProgram) && !"0".equals(bvufcProgram)) {
                indCondInfoUseSNMsg = "BV-UFC";
                indCondInfoUseSNMsgList.add(indCondInfoUseSNMsg);
              }

              // 透析量プログラム使用する
              String dialysisDoseProgram = this.getItemFromJson(machineSettingDevJson, "A", WebAPICheckConditionSend.MACHINESETTINGKEY.ADR0282.get());
              if (!StringUtils.isEmpty(dialysisDoseProgram) && !"0".equals(dialysisDoseProgram)) {
                indCondInfoUseSNMsg = "透析量プログラム";
                indCondInfoUseSNMsgList.add(indCondInfoUseSNMsg);
              }
              // add #7810 治療条件・装置設定変更時の動作不備（412.xlsx） dou start
              String bloodVolumeMeter = this.getItemFromJson(machineSettingDevJson, "A", WebAPICheckConditionSend.MACHINESETTINGKEY.ADR0267.get());
              // ブラッドボリューム計使用の選択>「使用する」チェックON
              if (!StringUtils.isEmpty(bloodVolumeMeter) && !"0".equals(bloodVolumeMeter)) {
                indCondInfoUseSNMsg = "BV計";
                indCondInfoUseSNMsgList.add(indCondInfoUseSNMsg);
              }
              // アクセス再循環測定使用選択＞「使用する」チェックON
              String accessRecirculation = this.getItemFromJson(machineSettingDevJson, "A", WebAPICheckConditionSend.MACHINESETTINGKEY.ADR0258.get());
              if (!StringUtils.isEmpty(accessRecirculation) && !"0".equals(accessRecirculation)) {
                indCondInfoUseSNMsg = "アクセス再循環";
                indCondInfoUseSNMsgList.add(indCondInfoUseSNMsg);
              }
              // add #7810 治療条件・装置設定変更時の動作不備（412.xlsx） dou end
            }
            if (!"4".equals(ordMainData.getRstDialysisState())) {
              // 6.透析液濃度プログラム使用するの場合(透析液、B液のいずれか)
              String dialysisSolutionConcentrationProgram = this.getItemFromJson(machineSettingDevJson, "A", WebAPICheckConditionSend.MACHINESETTINGKEY.ADR0340.get());
              if (!StringUtils.isEmpty(dialysisSolutionConcentrationProgram) && !"0".equals(dialysisSolutionConcentrationProgram)) {
                // Na注入プログラム使用する。
                String naInjectionProgram = this.getItemFromJson(machineSettingDevJson, "A", WebAPICheckConditionSend.MACHINESETTINGKEY.ADR0315.get());
                if (!StringUtils.isEmpty(naInjectionProgram) && !"0".equals(naInjectionProgram)) {
                  naInjectionProgramFlg = true;
                }
              }
              // 7.シングルニードル使用するの場合
              tmp = this.getDataFromIndCond(indCondInfo, "12");
              if (!StringUtils.isEmpty(tmp) && !"0".equals(tmp)) {
                // ブラッドボリューム計使用の選択>「使用する」チェックON
                String bloodVolumeMeter = this.getItemFromJson(machineSettingDevJson, "A", WebAPICheckConditionSend.MACHINESETTINGKEY.ADR0267.get());
                if (!StringUtils.isEmpty(bloodVolumeMeter) && !"0".equals(bloodVolumeMeter)) {
                  // アクセス再循環測定使用選択＞「使用する」チェックON
                  String accessRecirculation = this.getItemFromJson(machineSettingDevJson, "A", WebAPICheckConditionSend.MACHINESETTINGKEY.ADR0258.get());
                  if (!StringUtils.isEmpty(accessRecirculation) && !"0".equals(accessRecirculation)) {
                    singleNeedleFlg = true;
                  }
                }
              }
            }
          }
          if (retMaster != null) {
            // 通信種別
            String comType = (String) retMaster.get(WebAPICheckConditionSend.PARAMKEY.COM_TYPE);
            // 装置オプション
            JSONObject machineOptionJson = (JSONObject) retMaster.get(WebAPICheckConditionSend.PARAMKEY.MACHINE_OPTION);
            // 通信フォーマット
            String comFormat = (String) retMaster.get(WebAPICheckConditionSend.PARAMKEY.COM_FORMAT_CD);
            // 8.装置オプションの整合チェック
            // 新通信 透析の治療モードにてチェック
            if ("1".equals(comType)
              && (Treatment.DeviceMode.OHDF.equals(treatModeCd)
              // add #7799 2022/10/11 【デグレ】オプションの無い装置へ条件送信する際の注意喚起メッセージが表示されない dou start
              || Treatment.DeviceMode.HD.equals(treatModeCd)
              // add #7799 2022/10/11 【デグレ】オプションの無い装置へ条件送信する際の注意喚起メッセージが表示されない dou end
              || Treatment.DeviceMode.OHF.equals(treatModeCd)
              || Treatment.DeviceMode.I_HDF.equals(treatModeCd))
              // mod #8161 2022/12/08 二回目以降の後体重測定時にオプションなしで使用できない旨の注意喚起メッセージが表示される dou start
              // && !"4".equals(ordMainData.getRstDialysisState())) {
              && ("0".equals(ordMainData.getRstDialysisState())
              || "1".equals(ordMainData.getRstDialysisState())
              || "2".equals(ordMainData.getRstDialysisState()))) {
              // mod #8161 2022/12/08 二回目以降の後体重測定時にオプションなしで使用できない旨の注意喚起メッセージが表示される dou end
              // 8.1対象装置のオプションの2-14がOFFで装置設定のアクセス再循環場合
              String accessRecirculation = this.getItemFromJson(machineSettingDevJson, "A", WebAPICheckConditionSend.MACHINESETTINGKEY.ADR0258.get());
              // アクセス再循環測定使用選択＞「使用する」チェックON
              if (!StringUtils.isEmpty(accessRecirculation) && !"0".equals(accessRecirculation)) {
                // オプション＞「アクセス再循環」空白
                if (machineOptionJson != null) {
                  String item2_14_opt = this.getItemFromJson(machineOptionJson, "opt_2_14");
                  if (StringUtils.isEmpty(item2_14_opt) || "0".equals(item2_14_opt)) {
                    deviceOptionsMsg = "アクセス再循環";
                    deviceOptionsMsgList.add(deviceOptionsMsg);
                  }
                }
              }
              // 8.2指示の透析量プログラムが使用するで、対象装置のオプション2-12がOFFの場合
              // mod #8095 2022/11/20 条件送信時の条件チェック仕様がおかしい dou start
              // String QDProgram = this.getItemFromJson(machineSettingDevJson, "A", WebAPICheckConditionSend.MACHINESETTINGKEY.ADR0431.get());
              // // QDプログラム＞「入」チェックON
              // if (!StringUtils.isEmpty(QDProgram) && !"0".equals(QDProgram)) {
              String DialysisProgram = this.getItemFromJson(machineSettingDevJson, "A", WebAPICheckConditionSend.MACHINESETTINGKEY.ADR0282.get());
              // 透析量プログラム ＞「入」チェックON
              if (!StringUtils.isEmpty(DialysisProgram) && !"0".equals(DialysisProgram)) {
                // mod #8095 2022/11/20 条件送信時の条件チェック仕様がおかしい dou end
                // オプション＞「透析量プログラム」空白
                String item2_12_opt = this.getItemFromJson(machineOptionJson, "opt_2_12");
                if (StringUtils.isEmpty(item2_12_opt) || "0".equals(item2_12_opt)) {
                  deviceOptionsMsg = "透析量プログラム";
                  deviceOptionsMsgList.add(deviceOptionsMsg);
                }
              }
              // 8.3指示のBV-UFCが使用するで、対象装置のオプション3-7がOFFの場合
              String bvufcProgram = this.getItemFromJson(machineSettingDevJson, "A", WebAPICheckConditionSend.MACHINESETTINGKEY.ADR0196.get());
              // BV-UFC使用
              if (!StringUtils.isEmpty(bvufcProgram) && !"0".equals(bvufcProgram)) {
                // オプション＞「BV除水制御」空白
                String item3_7_opt = this.getItemFromJson(machineOptionJson, "opt_3_7");
                if (StringUtils.isEmpty(item3_7_opt) || "0".equals(item3_7_opt)) {
                  deviceOptionsMsg = "BV-UFC";
                  deviceOptionsMsgList.add(deviceOptionsMsg);
                }
              }
              // 8.4指示のNa注入プログラム使用するで、対象装置のオプション3-5がOFFの場合
              String naInjectionProgram = this.getItemFromJson(machineSettingDevJson, "A", WebAPICheckConditionSend.MACHINESETTINGKEY.ADR0315.get());
              // Na注入プログラム使用
              if (!StringUtils.isEmpty(naInjectionProgram) && !"0".equals(naInjectionProgram)) {
                // オプション＞「Na注入」空白
                String item3_5_opt = this.getItemFromJson(machineOptionJson, "opt_3_5");
                if (StringUtils.isEmpty(item3_5_opt) || "0".equals(item3_5_opt)) {
                  deviceOptionsMsg = "Na注入プログラム";
                  deviceOptionsMsgList.add(deviceOptionsMsg);
                }
              }
              // 装置設定のBV計使用選択が使用するで、対象装置のオプション1_8がOFFの場合
              String bloodVolumeMeter = this.getItemFromJson(machineSettingDevJson, "A", WebAPICheckConditionSend.MACHINESETTINGKEY.ADR0267.get());
              // ブラッドボリューム計使用の選択>「使用する」チェックON

              if (!StringUtils.isEmpty(bloodVolumeMeter) && !"0".equals(bloodVolumeMeter)) {
                // オプション＞「ブラッドボリューム計」空白
                String item1_8_opt = this.getItemFromJson(machineOptionJson, "opt_1_8");
                // オプション＞「BVplus」空白
                String item1_10_opt = this.getItemFromJson(machineOptionJson, "opt_1_10");
                if ((StringUtils.isEmpty(item1_8_opt) || "0".equals(item1_8_opt))
                  && (StringUtils.isEmpty(item1_10_opt) || "0".equals(item1_10_opt))) {
                  deviceOptionsMsg = "BV計";
                  deviceOptionsMsgList.add(deviceOptionsMsg);
                }
              }
            }
            // 9.特殊浄化治療＋新通信or医器工V3or医器工V4の装置での条件送信
            //mod #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx start
//            if (isPurification
//              && ("1".equals(comType) || ("3".equals(comType) && ("V".equals(comFormat) || "W".equals(comFormat))))) {
//              // 特殊浄化治療のため透析装置に送信する場合は強制オフラインとなる。これを通知。
//              isPurificationMsgFlg = true;
//            }
            if (isPurification) {
              List<Map<String, Object>> list = webAPICheckConditionSendService.getDataFromMstMachineByBed(ordMainData.getFacilityCd(),ordMainData.getIndBedCd().longValue());
              if (null != list && 1 == list.size()) {
                // 装置モード(特殊浄化)の対応可否（0：未対応、1：対応）
                Object tmpObj = list.get(0).get(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_BLOOD_PURIFY.get());
                String result = null == tmpObj ? null : String.valueOf(tmpObj);
                if(Objects.equals(FlagType.FLAG_ON, result)) {
                  isPurificationWarnMsgFlg = false;//一致
                } else {
                  isPurificationWarnMsgFlg = true;//不一致
                }
              }
              if("1".equals(comType) || ("3".equals(comType) && ("V".equals(comFormat) || "W".equals(comFormat)))) {
                // 特殊浄化治療のため透析装置に送信する場合は強制オフラインとなる。これを通知。
                isPurificationMsgFlg = true;
              }
            }
            //mod #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx end

            // 10.医器工V3、医器工V4＋OHDF、OHF、HDF、HF
            // mod FutreNetWeb+SI課題管理No7195 趙 start
            // if (("3".equals(comType) && ("V".equals(comFormat) || "W".equals(comFormat)))
            // && (Treatment.DeviceMode.OHDF.equals(treatModeCd)
            //   || Treatment.DeviceMode.OHF.equals(treatModeCd)
            //   || Treatment.DeviceMode.HDF.equals(treatModeCd)
            //   || Treatment.DeviceMode.HF.equals(treatModeCd))) {
            if (("3".equals(comType) && ("V".equals(comFormat) || "W".equals(comFormat)))
              && (Treatment.DeviceMode.OHDF.equals(treatModeCd)
              || Treatment.DeviceMode.OHF.equals(treatModeCd))) {
              // mod FutreNetWeb+SI課題管理No7195 趙 end
              // OHDF/OHF補液計算優先項目選択
              String index = this.getItemFromJson(machineSettingDevJson, "A", WebAPICheckConditionSend.MACHINESETTINGKEY.ADR0389.get());
              // 補液量と補液速度について通知。
              replenishmentMsgFlg = true;
              if ("0".equals(index)) {
                // 補液量と補液速度について通知。
                replenishmentMsgFlg = true;
                // 補液量と補液比率についてMsgFlg
                replenishmentMsgFlg2 = false;
                // 補液量と濾過率についてMsgFlg
                replenishmentMsgFlg3 = false;
              } else if ("2".equals(index)) {
                // 補液量と補液速度について通知。
                replenishmentMsgFlg = false;
                // 補液量と補液比率についてMsgFlg
                replenishmentMsgFlg2 = true;
                // 補液量と濾過率についてMsgFlg
                replenishmentMsgFlg3 = false;
              } else if ("3".equals(index)) {
                // 補液量と補液速度について通知。
                replenishmentMsgFlg = false;
                // 補液量と補液比率についてMsgFlg
                replenishmentMsgFlg2 = false;
                // 補液量と濾過率についてMsgFlg
                replenishmentMsgFlg3 = true;
              } else {
                // 補液量と補液速度について通知。
                replenishmentMsgFlg = true;
                // 補液量と補液比率についてMsgFlg
                replenishmentMsgFlg2 = false;
                // 補液量と濾過率についてMsgFlg
                replenishmentMsgFlg3 = false;
              }
            }
            // add FutreNetWeb+SI課題管理No7195 趙 start
            if (("3".equals(comType) && ("V".equals(comFormat) || "W".equals(comFormat)))
              && (Treatment.DeviceMode.HDF.equals(treatModeCd)
              || Treatment.DeviceMode.HF.equals(treatModeCd))) {
              replenishmentMsgFlg4 = true;
            }
            // add FutreNetWeb+SI課題管理No7195 趙 end
            // 11.装置モード不一致チェック
            if (!"4".equals(ordMainData.getRstDialysisState())) {
              if (Treatment.DeviceMode.HD.equals(treatModeCd)) {
                // 装置モード(HD)
                String isSupportHd = (String) retMaster.get(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_HD);
                if ("0".equals(isSupportHd)) {
                  deviceModeMismatchMsgFlg = true;
                }
              } else if (Treatment.DeviceMode.ECUM.equals(treatModeCd)) {
                // 装置モード(ECUM)
                String isSupportEcum = (String) retMaster.get(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_ECUM);
                if ("0".equals(isSupportEcum)) {
                  deviceModeMismatchMsgFlg = true;
                }
              } else if (Treatment.DeviceMode.HDF.equals(treatModeCd)) {
                // 装置モード(HDF)
                String isSupportHdf = (String) retMaster.get(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_HDF);
                if ("0".equals(isSupportHdf)) {
                  deviceModeMismatchMsgFlg = true;
                }
              } else if (Treatment.DeviceMode.HF.equals(treatModeCd)) {
                // 装置モード(HF)
                String isSupportHf = (String) retMaster.get(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_HF);
                if ("0".equals(isSupportHf)) {
                  deviceModeMismatchMsgFlg = true;
                }
              } else if (Treatment.DeviceMode.HD_AND_REPLACEMENT.equals(treatModeCd)) {
                // 装置モード(HD+補液)
                String isSupportHdHo = (String) retMaster.get(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_HD_HO);
                if ("0".equals(isSupportHdHo)) {
                  deviceModeMismatchMsgFlg = true;
                }
              } else if (Treatment.DeviceMode.ECUM_AND_REPLACEMENT.equals(treatModeCd)) {
                // 装置モード(ECUM+補液)
                String isSupportEcumHo = (String) retMaster.get(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_ECUM_HO);
                if ("0".equals(isSupportEcumHo)) {
                  deviceModeMismatchMsgFlg = true;
                }
              } else if (Treatment.DeviceMode.AFBF.equals(treatModeCd)) {
                // 装置モード(AFBF)
                String isSupportAfbf = (String) retMaster.get(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_AFBF);
                if ("0".equals(isSupportAfbf)) {
                  deviceModeMismatchMsgFlg = true;
                }
              } else if (Treatment.DeviceMode.OHDF.equals(treatModeCd)) {
                // 装置モード(OHDF)
                String isSupportOhdf = (String) retMaster.get(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_OHDF);
                if ("0".equals(isSupportOhdf)) {
                  deviceModeMismatchMsgFlg = true;
                }
              }  else if (Treatment.DeviceMode.OHF.equals(treatModeCd)) {
                // 装置モード(OHF)
                String isSupportOhf = (String) retMaster.get(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_OHF);
                if ("0".equals(isSupportOhf)) {
                  deviceModeMismatchMsgFlg = true;
                }
              } else if (Treatment.DeviceMode.I_HDF.equals(treatModeCd)) {
                // 装置モード(I-HDF)
                String isSupportIhdf = (String) retMaster.get(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_I_HDF);
                if ("0".equals(isSupportIhdf)) {
                  deviceModeMismatchMsgFlg = true;
                }
                //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx start
              } else if (Treatment.DeviceMode.UNKNOWN.equals(treatModeCd)) {
                // 装置モード(不明) -- message: 治療方法が不明です
                deviceModeUnknownMsgFlg = true;
              }
              //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx end
              // del FutreNetWeb+SI課題管理No6594 趙 start
              // else if (Treatment.DeviceMode.PURIFICATION.equals(treatModeCd)) {
              // 装置モード(特殊浄化)
              // String isSupportBloodPurify = (String) retMaster.get(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_BLOOD_PURIFY);
              // if ("0".equals(isSupportBloodPurify)) {
              // deviceModeMismatchMsgFlg = true;
              // }
              // }
              // del FutreNetWeb+SI課題管理No6594 趙 end
            }
          }
          if (!"4".equals(ordMainData.getRstDialysisState())) {
            // 12.VA方向不一致チェック
            String shuntPosition = "";
            // 感染症フラグ
            String isInfection = "";
            // 指示：VAコード
            if (ordMainData.getIndBedCd() != null) {
              MstBed mstbed = mstBedDao.selectByBedCd(Long.valueOf(ordMainData.getIndBedCd()) , null, "0");
              if (mstbed != null) {
                shuntPosition = String.valueOf(mstbed.getShuntPosition());
                isInfection = mstbed.getIsInfection();
              }
            }
            // 指示：ベッドコード
            String vaDirect = "";
            if (ordMainData.getIndVaCd() != null) {
              MstVa mstVa = mstVaDao.selectByCd(ordMainData.getIndVaCd());
              if (mstVa != null) {
                vaDirect = mstVa.getVaDirect();
              }
            }
            if (!StringUtils.isEmpty(vaDirect) && !StringUtils.isEmpty(shuntPosition)) {
              // mod #11654 治療状況マップ＞スケジュール画面のVA方向一致不一致判定が不正 関 start
              if ("3".equals(vaDirect) || "3".equals(shuntPosition)) {
                vaDirectionInconsistentMsgFlg = false;
              }else if (!vaDirect.equals(shuntPosition)) {
                vaDirectionInconsistentMsgFlg = true;
              }
              // mod #11654 治療状況マップ＞スケジュール画面のVA方向一致不一致判定が不正 関 end
            }
            // 13.感染症不一致チェック
            PatMain patMain = patMainDao.selectById(ordMainData.getPatId());

            if (patMain != null) {
              if (!StringUtils.isEmpty(isInfection) && !StringUtils.isEmpty(patMain.getIs_infect())) {
                if (!isInfection.equals(patMain.getIs_infect())) {
                  infectionNotConsistentMsgFlg = true;
                }
              }
            }
          }
        }
      }
      res.mstOverdueMsgList = mstOverdueMsgList;

      // del #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen start
      // res.mstDelSpecialMsgList = mstDelSpecialMsgList;
      // del #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen end

      res.mstDelFlgMsgList = mstDelFlgMsgList;

      res.infectionNotConsistentMsgFlg = infectionNotConsistentMsgFlg;

      res.vaDirectionInconsistentMsgFlg = vaDirectionInconsistentMsgFlg;

      res.deviceModeMismatchMsgFlg = deviceModeMismatchMsgFlg;

      //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx start
      res.deviceModeUnknownMsgFlg = deviceModeUnknownMsgFlg;
      res.isPurificationWarnMsgFlg = isPurificationWarnMsgFlg;
      //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx end

      res.replenishmentMsgFlg = replenishmentMsgFlg;

      res.replenishmentMsgFlg2 = replenishmentMsgFlg2;

      res.replenishmentMsgFlg3 = replenishmentMsgFlg3;

      // add FutreNetWeb+SI課題管理No7195 趙 start
      res.replenishmentMsgFlg4 = replenishmentMsgFlg4;
      // add FutreNetWeb+SI課題管理No7195 趙 end

      res.isPurificationMsgFlg = isPurificationMsgFlg;

      res.deviceOptionsMsgList = deviceOptionsMsgList;

      res.tmpAutomaticTrackingFlg = tmpAutomaticTrackingFlg;

      res.singleNeedleFlg = singleNeedleFlg;

      res.naInjectionProgramFlg = naInjectionProgramFlg;
      // add #7810 2022/11/20 BVUFCを使用する予定に除水プログラム使用するを展開する場合は警告。。 dou start
      res.diversionBvufcFlg = diversionBvufcFlg;
      // add #7810 2022/11/20 BVUFCを使用する予定に除水プログラム使用するを展開する場合は警告。。 dou end
      res.indCondInfoUseSNMsgList = indCondInfoUseSNMsgList;

      res.indCondInfoUseAFBFMsgList = indCondInfoUseAFBFMsgList;

      res.indCondInfoLowerLimitMsgList = indCondInfoLowerLimitMsgList;

      res.indCondInfoUseIHDFMsgList = indCondInfoUseIHDFMsgList;

      res.indCondInfoTopLimitMsgList = indCondInfoTopLimitMsgList;

      res.indCondInfoNoLoginMsgList = indCondInfoNoLoginMsgList;

      res.msgList = msgList;
      return res;
    } catch (Exception ex) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(ex));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      msg = "分類不一致判断のチェックエラー";
      msgList.add(msg);
      res.msgList = msgList;
      return res;
    }
  }

  /**
   * 条件指示からのデータ取得処理
   * 条件指示の構造は、以下
   * ['1':{'value':'2.3',...},'2':{'value':'2.5'...},{},{},{}.......,{}]
   *
   * @param jsonObj
   * @param key
   * @return
   */
  private String getDataFromIndCond(JSONObject jsonObj, String key) {
    String ret = null;
    // add #9973 Resolve null exception for key 20240117 ztc start
    if (jsonObj.has(key)) {
    // add #9973 Resolve null exception for key 20240117 ztc end
      try {
        ret = String.valueOf(jsonObj.getJSONObject(key).get("value"));
        if ("null".equals(ret)) {
          ret = null;
        }
      } catch (Exception e) {
        ret = null;
      }
    }
    return ret;
  }
  //add 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
  private MstEquipmentMstMedicine getClassTypeMap(int cd, int classTypeflg, Map<Integer,MstEquipmentMstMedicine> mstEquipmentMap1,
                                                  Map<Integer,MstEquipmentMstMedicine> mstEquipmentMap2, Map<Integer,MstEquipmentMstMedicine> mstEquipmentMap3) {
    MstEquipmentMstMedicine classType = new MstEquipmentMstMedicine();
    if (classTypeflg == 0) { // 医療材料の場合
      classType = mstEquipmentMap1.get(cd);
      if (classType != null) {
        if (0 == classType.getClassType()) {
          classType.setClassName("該当なし");
        } else if (1 == classType.getClassType()) {
          classType.setClassName("血液回路");
        } else if (2 == classType.getClassType()) {
          classType.setClassName("穿刺針(SN以外)");
        } else if (3 == classType.getClassType()) {
          classType.setClassName("穿刺針(SN)");
        } else if (4 == classType.getClassType()) {
          classType.setClassName("吸着カラム");
        } else if (5 == classType.getClassType()) {
          classType.setClassName("吸着器");
        } else if (6 == classType.getClassType()) {
          classType.setClassName("分離器");
        }
      }
    }
    /* modify by shiyw 2024-01-29 [#10196]ord_mainのデータ定義の修正 --start */
    if (classTypeflg == 1) { // 薬剤場合
      classType = mstEquipmentMap2.get(cd);
      if (classType != null) {
        if (0 == classType.getClassType()) {
          classType.setClassName("該当なし");
        } else if (1 == classType.getClassType()) {
          classType.setClassName("抗凝固剤");
        } else if (2 == classType.getClassType()) {
          classType.setClassName("透析液");
        } else if (3 == classType.getClassType()) {
          classType.setClassName("補液");
        }
      }
    }
    if (classTypeflg == 2) { // 調整薬剤場合
        classType = mstEquipmentMap3.get(cd);
      if (classType != null) {
        if (0 == classType.getClassType()) {
          classType.setClassName("該当なし");
        } else if (1 == classType.getClassType()) {
          classType.setClassName("抗凝固剤");
        } else if (2 == classType.getClassType()) {
          classType.setClassName("透析液");
        } else if (3 == classType.getClassType()) {
          classType.setClassName("補液");
        }
      }
    }
    /* modify by shiyw 2024-01-29 [#10196]ord_mainのデータ定義の修正 --end */
    return classType;
  }
  //add 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
  /**
   * 分類区分取得処理
   *
   * @param cd           医療材料コードと薬剤コード
   * @param classTypeflg 0:医療材料分類; 1:薬剤分類;
   * @param facilityCd   施設コード
   * @return classType
   */
  private MstEquipmentMstMedicine getClassType(int cd, int classTypeflg, String facilityCd) {
    MstEquipmentMstMedicine classType = new MstEquipmentMstMedicine();
    if (classTypeflg == 0) {
      classType = ordMainDao.selectClassTypeFromMstEquipment(cd, facilityCd);
      if (classType != null) {
        if (0 == classType.getClassType()) {
          classType.setClassName("該当なし");
        } else if (1 == classType.getClassType()) {
          classType.setClassName("血液回路");
        } else if (2 == classType.getClassType()) {
          classType.setClassName("穿刺針(SN以外)");
        } else if (3 == classType.getClassType()) {
          classType.setClassName("穿刺針(SN)");
        } else if (4 == classType.getClassType()) {
          classType.setClassName("吸着カラム");
        } else if (5 == classType.getClassType()) {
          classType.setClassName("吸着器");
        } else if (6 == classType.getClassType()) {
          classType.setClassName("分離器");
        }
      }
    }
    if (classTypeflg == 1) {
      classType = ordMainDao.selectClassTypeFromMstMedicine(cd, facilityCd);
      if (classType == null) {
        classType = ordMainDao.selectClassTypeFromMstMedicineMix(cd, facilityCd);
      }
      if (classType != null) {
        if (0 == classType.getClassType()) {
          classType.setClassName("該当なし");
        } else if (1 == classType.getClassType()) {
          classType.setClassName("抗凝固剤");
        } else if (2 == classType.getClassType()) {
          classType.setClassName("透析液");
        } else if (3 == classType.getClassType()) {
          classType.setClassName("補液");
        }
      }
    }

    return classType;
  }

  /**
   * 装置モード取得処理
   * 治療方法マスタから情報を取得する
   * ord_mainを経由(等価Join:施設コード＆治療方法コード)して取得
   *
   * @param ordNo オーダー番号
   * @return 取得した値　<PARAMKEY,value>
   * PARAMKEY.DEVICE_MODE:装置モード
   */
  private String getDeviceModeFromMstTreatment(Long ordNo) {
    //戻り値
    String retDeviceMode = null;

    //データ抽出
    try {
      //DBからのデータ取得
      List<String> list = webAPICheckConditionSendService.getDeviceModeFromMstTreatment(ordNo);
      //SELECT結果の受け取り
      if (null != list && 1 == list.size()) {
        retDeviceMode = list.get(0);
      } else {
        //データがなかった
        retDeviceMode = null;
      }
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      retDeviceMode = null;
    }
    return retDeviceMode;
  }

  // add FNSI-分類不一致判断の追加 徐 end
  // del 11613 by shiyw 20250307 start
//  // add FNSI-確定フラグを”1”に更新 徐 start
//  public int updateIsConfirm(Long ordNo, Long patId) {
//    return ordMaterialSaveDao.updateIsConfirm(ordNo, patId);
//  }
//  // add FNSI-確定フラグを”1”に更新 徐 end
  // del 11613 by shiyw 20250307 start

  //FNSI-修正 ログ対応 wp add start

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
   *
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

  // add FNSI-分類不一致判断の追加 徐 start

  /**
   * 装置設定取得処理
   * ord_main,pat_mainから装置設定情報を取得する
   * ord_mainを経由(等価Join:施設コード＆患者ID)して取得
   *
   * @param ordNo オーダー番号：抽出キー
   * @return 取得した値　<PARAMKEY,value>
   * PARAMKEY.
   */
  private HashMap<WebAPICheckConditionSend.PARAMKEY, Object> getMachineSetting(Long ordNo) {
    //戻り値
    HashMap<WebAPICheckConditionSend.PARAMKEY, Object> retVal = new HashMap<>();
    try {
      //DBからのデータ取得
      List<Map<String, Object>> list = webAPICheckConditionSendService.getMachineSetting(ordNo);

      //SELECT結果の受け取り
      if (null != list && 1 == list.size()) {
        //Jsonデータを受け取るためにいったんPGobjectで受けます
        String pgDev = list.get(0).get(WebAPICheckConditionSend.PARAMKEY.DEV.get()).toString();
        //PGobjectの値(String)をJSONObject化します
        JSONObject devJson = null;
        if (pgDev.compareTo("null") != 0) {
          devJson = new JSONObject(pgDev);
        }
        //返却値の格納
        retVal.put(WebAPICheckConditionSend.PARAMKEY.DEV, devJson);

        //Jsonデータを受け取るためにいったんPGobjectで受けます
        PGobject pgPat = (PGobject) list.get(0).get(WebAPICheckConditionSend.PARAMKEY.PAT.get());
        if (null != pgPat) {
          devJson = new JSONObject(pgPat.getValue());
        }
        //返却値の格納
        retVal.put(WebAPICheckConditionSend.PARAMKEY.PAT, devJson);
      } else {
        //データがなかった
        retVal = null;
      }
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      retVal = null;
    }
    return retVal;
  }

  /**
   * Json文字列から指定したキー(アドレス文字列)の情報を取得する
   * 呼び出し例）
   * getItemFromJson(inputJson,"B","25")
   *
   * @param jsonObject 取得元Json
   * @param path       取得キーの付加文字
   * @param key        取得キー(アドレス文字列)
   * @return　取得文字列 取得途中でJson文字列でないものもしくはキーに該当がなかった場合、戻り値はnull
   * 　取得キー(取得キーの最後のキー)に該当する値がなかった場合、戻り値はnull
   */
  String getItemFromJson(
    JSONObject jsonObject,
    String path,
    String key
  ) {
    //戻り値の初期化
    String ret = null;

    if (key.compareTo("ord_no") != 0) {
      //頭0埋め3桁化&頭にpathを付加
      key = ("000" + key);
      key = path + key.substring(key.length() - 3);
    }

    try {
      //値の取得

      ret = String.valueOf(jsonObject.get(key));
    } catch (Exception e) {
      //キーがなかった or パースエラー
      ret = null;
    }

    return ret;
  }

  /**
   * 通信フォーマット取得処理
   * 装置マスタから情報を取得する
   * ord_mainとベッドマスタを経由(等価Join:施設コード＆ベッドコード)して取得(等価Join:施設コード＆装置番号)
   *
   * @param ordNo オーダー番号
   * @return 取得した値　<PARAMKEY,value>
   */
  private HashMap<WebAPICheckConditionSend.PARAMKEY, Object> getDataFromMstMachine(
    Long ordNo
  ) {
    // 戻り値
    HashMap<WebAPICheckConditionSend.PARAMKEY, Object> retVal = new HashMap<>();

    String result = null;

    // データ抽出
    try {
      // DBからのデータ取得
      List<Map<String, Object>> list = webAPICheckConditionSendService.getDataFromMstMachine(ordNo);

      // SELECT結果の受け取り
      if (null != list && 1 == list.size()) {
        //Jsonデータを受け取るためにいったんPGobjectで受けます
        PGobject pgMachineOption = (PGobject) list.get(0).get(WebAPICheckConditionSend.PARAMKEY.MACHINE_OPTION.get());
        //PGobjectの値(String)をJSONObject化します
        JSONObject machineOption = null;
        if (null != pgMachineOption) {
          machineOption = new JSONObject(pgMachineOption.getValue());
        }
        // 装置オプションの格納
        retVal.put(WebAPICheckConditionSend.PARAMKEY.MACHINE_OPTION, machineOption);

        // 通信フォーマットの取得＆格納
        Object tmpObj = list.get(0).get(WebAPICheckConditionSend.PARAMKEY.COM_FORMAT_CD.get());
        result = null == tmpObj ? null : String.valueOf(tmpObj);
        retVal.put(WebAPICheckConditionSend.PARAMKEY.COM_FORMAT_CD, result);
        // 通信種別の取得＆格納
        tmpObj = list.get(0).get(WebAPICheckConditionSend.PARAMKEY.COM_TYPE.get());
        result = null == tmpObj ? null : String.valueOf(tmpObj);
        retVal.put(WebAPICheckConditionSend.PARAMKEY.COM_TYPE, result);

        tmpObj = list.get(0).get(WebAPICheckConditionSend.PARAMKEY.OVER_NXSERIES.get());
        result = null == tmpObj ? null : String.valueOf(tmpObj);
        retVal.put(WebAPICheckConditionSend.PARAMKEY.OVER_NXSERIES, result);
        // 装置モード(HD)の対応可否（0：未対応、1：対応）
        tmpObj = list.get(0).get(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_HD.get());
        result = null == tmpObj ? null : String.valueOf(tmpObj);
        retVal.put(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_HD, result);
        // 装置モード(ECUM)の対応可否（0：未対応、1：対応）
        tmpObj = list.get(0).get(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_ECUM.get());
        result = null == tmpObj ? null : String.valueOf(tmpObj);
        retVal.put(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_ECUM, result);
        // 装置モード(HDF)の対応可否（0：未対応、1：対応）
        tmpObj = list.get(0).get(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_HDF.get());
        result = null == tmpObj ? null : String.valueOf(tmpObj);
        retVal.put(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_HDF, result);
        // 装置モード(HF)の対応可否（0：未対応、1：対応）
        tmpObj = list.get(0).get(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_HF.get());
        result = null == tmpObj ? null : String.valueOf(tmpObj);
        retVal.put(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_HF, result);
        // 装置モード(HD+補液)の対応可否（0：未対応、1：対応）
        tmpObj = list.get(0).get(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_HD_HO.get());
        result = null == tmpObj ? null : String.valueOf(tmpObj);
        retVal.put(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_HD_HO, result);
        // 装置モード(ECUM+補液)の対応可否（0：未対応、1：対応）
        tmpObj = list.get(0).get(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_ECUM_HO.get());
        result = null == tmpObj ? null : String.valueOf(tmpObj);
        retVal.put(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_ECUM_HO, result);
        // 装置モード(AFBF)の対応可否（0：未対応、1：対応）
        tmpObj = list.get(0).get(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_AFBF.get());
        result = null == tmpObj ? null : String.valueOf(tmpObj);
        retVal.put(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_AFBF, result);
        // 装置モード(OHDF)の対応可否（0：未対応、1：対応）
        tmpObj = list.get(0).get(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_OHDF.get());
        result = null == tmpObj ? null : String.valueOf(tmpObj);
        retVal.put(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_OHDF, result);
        // 装置モード(OHF)の対応可否（0：未対応、1：対応）
        tmpObj = list.get(0).get(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_OHF.get());
        result = null == tmpObj ? null : String.valueOf(tmpObj);
        retVal.put(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_OHF, result);
        // 装置モード(I-HDF)の対応可否（0：未対応、1：対応）
        tmpObj = list.get(0).get(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_I_HDF.get());
        result = null == tmpObj ? null : String.valueOf(tmpObj);
        retVal.put(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_I_HDF, result);
        // 装置モード(特殊浄化)の対応可否（0：未対応、1：対応）
        tmpObj = list.get(0).get(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_BLOOD_PURIFY.get());
        result = null == tmpObj ? null : String.valueOf(tmpObj);
        retVal.put(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_BLOOD_PURIFY, result);
      } else {
        // データがなかった
        retVal = null;
      }
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      retVal = null;
    }

    return retVal;

  }

  /**
   * Json文字列から指定したキーの情報を取得する
   *
   * @param jsonObject  取得元Json
   * @param key  取得キー
   * @return　取得文字列 取得途中でJson文字列でないものもしくはキーに該当がなかった場合、戻り値はnull
   * 　取得キー(取得キーの最後のキー)に該当する値がなかった場合、戻り値はnull
   */
  String getItemFromJson(
    JSONObject jsonObject,
    String key
  ) {
    //戻り値の初期化
    String ret = null;
    try {
      //値の取得

      ret = String.valueOf(jsonObject.get(key));
    } catch (Exception e) {
      //キーがなかった or パースエラー
      ret = null;
    }

    return ret;
  }
  // add FNSI-分類不一致判断の追加 徐 end

}
