package jp.co.nikkiso.ntss.admin_web.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.fasterxml.jackson.databind.node.TextNode;
import com.google.common.collect.Lists;
import com.google.gson.Gson;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Treatment.DeviceMode;
import jp.co.nikkiso.ntss.admin_web.constant.Week;
import jp.co.nikkiso.ntss.admin_web.request.deviceEdgeOrder.DeviceEdgeOrderRequest;
import jp.co.nikkiso.ntss.admin_web.request.patientCapture.JournalCreateRequestPayload;
import jp.co.nikkiso.ntss.admin_web.response.ordMain.OrdInfoListForPatListByOrdNoResponse;
import jp.co.nikkiso.ntss.admin_web.response.ordMain.OrdMainWeekPatternResponse;
import jp.co.nikkiso.ntss.admin_web.response.weight.SendConditionCheckResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.checkList.CheckListService;
import jp.co.nikkiso.ntss.admin_web.service.exam.ExamRequestService;
import jp.co.nikkiso.ntss.admin_web.service.journal.JournalCreatePayloadService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.ordMainDelayTask.OrdMainJournalRequest;
import jp.co.nikkiso.ntss.admin_web.service.patEvent.PatEventService;
import jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.model.PatTreatmentPatternDelta;
import jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.model.PatTreatmentPatternFieldEnum;
import jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.model.PatTreatmentPatternJsonbField;
import jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.model.PatTreatmentPatternKey;
import jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.model.PatTreatmentPatternUpdateModeEnum;
import jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.model.PatTreatmentPatternUpsert;
import jp.co.nikkiso.ntss.admin_web.service.rad.RadRequestService;
import jp.co.nikkiso.ntss.admin_web.service.sendConditionCancel.SendConditionCancelService;
import jp.co.nikkiso.ntss.admin_web.service.statusList.TreatmentStatusListService;
import jp.co.nikkiso.ntss.admin_web.service.utils.DateTimeUtils;
import jp.co.nikkiso.ntss.admin_web.service.utils.MasterCacheHandler;
import jp.co.nikkiso.ntss.admin_web.web.rest.DeviceEdgeOrderResource;
import jp.co.nikkiso.ntss.admin_web.web.rest.OrdMainResource;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.IndicationUtils;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.OrdMainSchChangeUtils;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.OrdMainUtil;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.PatTreatmentPatternUtils;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebAPICheckConditionSend;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallCommonUtil;
import jp.co.nikkiso.ntss.admin_web.web.rest.validation.ApiEntityOrdMain;
import jp.co.nikkiso.ntss.admin_web.web.service.MaterialsSharingPatientInformation.MaterialsSharingPatientInfomationService;
import jp.co.nikkiso.ntss.api.service.ordChecklistService.CheckListMakeService;
import jp.co.nikkiso.ntss.api.service.utils.InvokeResult;
import jp.co.nikkiso.ntss.core.constant.CondIvEnum;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.constant.TreatmentItemsDef;
import jp.co.nikkiso.ntss.core.dao.BbsInfoDao;
import jp.co.nikkiso.ntss.core.dao.IndScheduleDao;
import jp.co.nikkiso.ntss.core.dao.IndicationResultDao;
import jp.co.nikkiso.ntss.core.dao.MniMonitorDao;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.dao.MstBedDao;
import jp.co.nikkiso.ntss.core.dao.MstChecklistDao;
import jp.co.nikkiso.ntss.core.dao.MstComsvSettingDao;
import jp.co.nikkiso.ntss.core.dao.MstDialyzerDao;
import jp.co.nikkiso.ntss.core.dao.MstEquipmentClassDao;
import jp.co.nikkiso.ntss.core.dao.MstEquipmentDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.MstImplantDao;
import jp.co.nikkiso.ntss.core.dao.MstInfectionDao;
import jp.co.nikkiso.ntss.core.dao.MstKurDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicateTimingDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineClassDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineMixDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstProcedureDao;
import jp.co.nikkiso.ntss.core.dao.MstSelectorDao;
import jp.co.nikkiso.ntss.core.dao.MstTreatmentDao;
import jp.co.nikkiso.ntss.core.dao.MstVaDao;
import jp.co.nikkiso.ntss.core.dao.OrdChecklistDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainRestoreDao;
import jp.co.nikkiso.ntss.core.dao.OrdMaterialSaveDao;
import jp.co.nikkiso.ntss.core.dao.OrdScheduleDao;
import jp.co.nikkiso.ntss.core.dao.PatExamMainDao;
import jp.co.nikkiso.ntss.core.dao.PatIndApproveDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatNameIdentificationDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.PatTreatmentPatternDao;
import jp.co.nikkiso.ntss.core.dao.SysDataItemDao;
import jp.co.nikkiso.ntss.core.dto.FacilitySettingNo.FacilitySettingNoDisplayOrder;
import jp.co.nikkiso.ntss.core.dto.OrdMain.CondInfoItem;
import jp.co.nikkiso.ntss.core.dto.OrdMain.FutureOrdMainConditionInfo;
import jp.co.nikkiso.ntss.core.dto.OrdMain.OrdMainCrudDto;
import jp.co.nikkiso.ntss.core.dto.OrdMain.OrdMainMedicineDelete;
import jp.co.nikkiso.ntss.core.dto.OrdMain.OrdMainRequest;
import jp.co.nikkiso.ntss.core.dto.OrdMain.OrdMainSharingInfo;
import jp.co.nikkiso.ntss.core.dto.OrdMain.OrdMainWithlastWeightAfter;
import jp.co.nikkiso.ntss.core.dto.OrdMain.UpdateOrdMainMediInfoDTO;
import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.OrdSearchCondition;
import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.OrdSearchInstCondition;
import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.OrdSearchTreatmentCondition;
import jp.co.nikkiso.ntss.core.dto.indSchedule.IndScheduleInfo;
import jp.co.nikkiso.ntss.core.dto.indSchedule.OrdNoAndConnectedTableKeyData;
import jp.co.nikkiso.ntss.core.dto.ordMaterialSave.OrdMaterialSaveDto;
import jp.co.nikkiso.ntss.core.entity.BbsInfo;
import jp.co.nikkiso.ntss.core.entity.FluidSpeedAndAmountEntity;
import jp.co.nikkiso.ntss.core.entity.ForecastInforResult;
import jp.co.nikkiso.ntss.core.entity.ForecastInforResultForCount;
import jp.co.nikkiso.ntss.core.entity.ForecastInforResultForPatEventCount;
import jp.co.nikkiso.ntss.core.entity.EquipmentLatestNo;
import jp.co.nikkiso.ntss.core.entity.MedicineLatestNo;
import jp.co.nikkiso.ntss.core.entity.MniMonitor;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.MstBed;
import jp.co.nikkiso.ntss.core.entity.MstChecklist;
import jp.co.nikkiso.ntss.core.entity.MstComsvSetting;
import jp.co.nikkiso.ntss.core.entity.MstDialyzer;
import jp.co.nikkiso.ntss.core.entity.MstEquipment;
import jp.co.nikkiso.ntss.core.entity.MstEquipmentClass;
import jp.co.nikkiso.ntss.core.entity.MstImplant;
import jp.co.nikkiso.ntss.core.entity.MstInfection;
import jp.co.nikkiso.ntss.core.entity.MstKur;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.MstMedicateTiming;
import jp.co.nikkiso.ntss.core.entity.MstMedicine;
import jp.co.nikkiso.ntss.core.entity.MstMedicineClass;
import jp.co.nikkiso.ntss.core.entity.MstMedicineMix;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstProcedure;
import jp.co.nikkiso.ntss.core.entity.MstSelector;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.MstTreatmentSet;
import jp.co.nikkiso.ntss.core.entity.MstVa;
import jp.co.nikkiso.ntss.core.entity.OrdChAp;
import jp.co.nikkiso.ntss.core.entity.OrdChecklist;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.OrdMainConditionSetting;
import jp.co.nikkiso.ntss.core.entity.OrdMainEsListener;
import jp.co.nikkiso.ntss.core.entity.OrdMainForCsv;
import jp.co.nikkiso.ntss.core.entity.OrdMainForJournal;
import jp.co.nikkiso.ntss.core.entity.OrdMainOnly;
import jp.co.nikkiso.ntss.core.entity.OrdMainRestore;
import jp.co.nikkiso.ntss.core.entity.OrdMainUptSchInfoVo;
import jp.co.nikkiso.ntss.core.entity.OrdMaterialSave;
import jp.co.nikkiso.ntss.core.entity.OrdSchedule;
import jp.co.nikkiso.ntss.core.entity.OrdScheduleNewKurPreview;
import jp.co.nikkiso.ntss.core.entity.PatCalendarEvent;
import jp.co.nikkiso.ntss.core.entity.PatEvent;
import jp.co.nikkiso.ntss.core.entity.PatExamMain;
import jp.co.nikkiso.ntss.core.entity.PatIndApprove;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatNameIdentification;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.PatRadMain;
import jp.co.nikkiso.ntss.core.entity.PatTreatmentPattern;
import jp.co.nikkiso.ntss.core.entity.SysDataItem;
import jp.co.nikkiso.ntss.core.entity.TreatmentConditionSetting;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordSetting;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;
import jp.co.nikkiso.ntss.core.entity.custom.OrdAdditionInfo;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainForCheckListSchedule;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainForPatList;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainIndIndCommentInfo;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainKurAndTreatmentList;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainKurBed;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainTreatDate;
import jp.co.nikkiso.ntss.core.entity.custom.OrdScheduleCustom;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainData;
import jp.co.nikkiso.ntss.core.entity.custom.PatTreatmentPatternPatMain;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.service.ordMaterialSaveService.OrdMaterialSaveService;
import jp.co.nikkiso.ntss.core.utils.TriggerUtil;
import lombok.Getter;
import lombok.Setter;
import org.apache.commons.collections4.CollectionUtils;
import org.apache.commons.lang3.SerializationUtils;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.postgresql.util.PGobject;
import org.seasar.doma.jdbc.Config;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;
import org.springframework.util.ObjectUtils;
import org.springframework.util.StringUtils;
import org.springframework.validation.BindingResult;
import org.springframework.validation.ObjectError;

import javax.annotation.Resource;
import java.io.IOException;
import java.lang.reflect.Field;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.net.URISyntaxException;
import java.sql.Timestamp;
import java.text.DateFormat;
import java.text.DecimalFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.DayOfWeek;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicReference;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import static java.util.Collections.emptyList;
import static jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.GraphSetting.DateClass.END_MAX_DATE;
import static jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.GraphSetting.FacilitySettingClass.SETTING_NO_3008;
import static jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.GraphSetting.FacilitySettingClass.VALUE_MINUS_1;
import static jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.GraphSetting.OrdMainClass.IS_DEL_0;
import static jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.GraphSetting.OrdMainClass.LEN_8;
import static jp.co.nikkiso.ntss.core.constant.CoreConstant.FacilitySettingNo.EQUIP_DISPLAY_ORDER;
import static jp.co.nikkiso.ntss.core.constant.TreatmentItemsDef.T_I_START_DATE;
import static jp.co.nikkiso.ntss.core.utils.IvCalAmountAndSpeedUtil.NO_IV;
import static jp.co.nikkiso.ntss.core.utils.IvCalAmountAndSpeedUtil.SPECIAL_DEVICE;
import static jp.co.nikkiso.ntss.core.utils.IvCalAmountAndSpeedUtil.calIvAmountAndIvSpeed;
import static jp.co.nikkiso.ntss.core.utils.LiquidCalculateUtils.getIhdfCalculateLiquidAmoutAndSpeed;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
// add 9200 by kangjie end
//2019.01.29 import jp.co.nikkiso.ntss.core.dao.DummyOrdMainDao;
//2019.01.29 import jp.co.nikkiso.ntss.core.entity.DummyOrdMain;

@Service
public class OrdMainServiceImpl implements OrdMainService {

  /* add by chamaojia 2023-04-11 [6118] 一括挿入制限数量追加 --start */
  private static final int ORD_MAIN_BATCH_INSERT_MAX_LIMIT_NUM = 100;
  /* add by chamaojia 2023-04-11 [6118] 一括挿入制限数量追加 --end */

  @Autowired
  WebAPICheckConditionSendService webAPICheckConditionSendService;

  @Autowired
  private MstBedDao mstBedDao;

  @Autowired
  private MstVaDao mstVaDao;
  @Autowired
  private OrdMainDao ordMainDao;
  // add FutreNetWeb+SI課題管理No6227 趙 start
  @Autowired
  private OrdMainRestoreDao ordMainRestoreDao;
  // add FutreNetWeb+SI課題管理No6227 趙 end
  @Autowired
  private PatMainDao patMainDao;
  //add 8116 【デグレ】薬剤コードと調整薬剤コードをと区別せずに抽出しているため、別の薬剤が表示される 赵 start
  @Autowired
  private MstMedicineDao mstMedicineDao;
  //add 8116 【デグレ】薬剤コードと調整薬剤コードをと区別せずに抽出しているため、別の薬剤が表示される 赵 start
  @Autowired
  private MstMedicineMixDao mstMedicineMixDao;
  //add 8116 【デグレ】薬剤コードと調整薬剤コードをと区別せずに抽出しているため、別の薬剤が表示される 赵 end
  // add FNSI-8142 医療材料の名称を取得。ljx  start
  @Autowired
  private MstEquipmentDao mstEquipmentDao;
  // add FNSI-8142 医療材料の名称を取得。ljx  end
  // add FNSI-8186 ダイアライザの名称を取得　ljx  start
  @Autowired
  private MstDialyzerDao mstDialyzerDao;
  // add FNSI-8186 ダイアライザの名称を取得。ljx  end
  @Autowired
  private SysDataItemDao sysDataItemDao;

  @Autowired
  private TriggerUtil triggerUtil;

  @Autowired
  private PatPersonalMainDao patPersonalMainDao;

  @Autowired
  private PatIndApproveDao patIndApproveDao;

  @Autowired
  private OrdScheduleDao ordScheduleDao;

  @Autowired
  //#8484　医療材料選択IFのリスト不正　Start
  private MstSelectorDao mstSelectorDao;
  //#8484　医療材料選択IFのリスト不正　End
  @Autowired
  private AsyncService asyncService;

  // mod FNSI-指示編集でDB登録データの更新 楊 start
  /**
   * 利用者マスタ（個人情報DB）のDaoインタフェース
   */
  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;
  // mod FNSI-指示編集でDB登録データの更新 楊 end

  /* add by luchanghai  2023-02-01 [CodeOptimization] start */
  @Autowired
  private MstTreatmentDao mstTreatmentDao;

  @Autowired
  private MstMachineDao mstMachineDao;

  @Autowired
  private MstComsvSettingDao mstComsvSettingDao;

  @Autowired
  private IndicationResultDao indicationResultDao;

  @Autowired
  private PatExamMainDao patExamMainDao;

  // add #10307 曜日パターン変更を行うと1年以降の治療予定が作成される 20240306 ztc start
  @Autowired
  private PatTreatmentPatternDao patTreatmentPatternDao;
  @Autowired
  private PatTreatmentPatternService patTreatmentPatternService;
  // add #10307 曜日パターン変更を行うと1年以降の治療予定が作成される 20240306 ztc end

  @Autowired(required = false)
  private MongoTemplate mongoTemplate;
  /* add by luchanghai  2023-02-01 [CodeOptimization] end */
  //add 2023-03-02  6817 手動実績作成に失敗しても透析回数がカウントされてしまう 張 張 start
  @Autowired
  TreatmentStatusListService treatmentStatusListService;
  @Autowired
  SendConditionCancelService sendConditionCancelService;
  @Autowired
  private OrdMaterialSaveService ordMaterialSaveService;
  @Autowired
  private OrdChecklistDao ordChecklistDao;
  @Autowired
  DeviceEdgeOrderResource deviceEdgeOrderResource;
  @Autowired
  private MstChecklistDao mstChecklistDao;
  @Autowired
  CheckListService ordCheckListService;
  //add 2023-03-02  6817 手動実績作成に失敗しても透析回数がカウントされてしまう 張 張 end
  @Autowired
  MaterialsSharingPatientInfomationService materialsSharingPatientInfomationService;
  //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy start
  @Autowired
  ScheduleListServiceImpl scheduleListServiceImpl;
  //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy start

  //add #11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) zkm start
  @Autowired
  private OrdMainSchChangeUtils ordMainSchChangeUtils;
  //add #11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) zkm end

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
  PatInfoService patInfoService;

  @Autowired
  WebApiCallCommonUtil webApiCallCommonUtil;
  @Autowired
  JournalService journalService;
  @Autowired
  FacilitySettingService facilitySettingService;
  @Autowired
  RadRequestService radRequestService;
  @Autowired
  MntMachineStateDao mntMachineStateDao;
  @Autowired
  IndHistoryMakeService indHistoryMakeService;
  @Autowired
  PatTreatmentPatternUtils patTreatmentPatternUtils;
  @Autowired
  ExamRequestService examRequestService;
  // add 9200 by kangjie
  @Autowired
  MstFacilitySettingDao mstFacilitySettingDao;
  // add 9200 by kangjie
  // add #9273 施設設定マスタのNo105の設定どおり動かない。  start
  @Autowired
  private PatEventService patEventService;
  // add #9273 施設設定マスタのNo105の設定どおり動かない。  end

  // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関  start
  @Autowired
  MstInfoService mstInfoService;

  @Autowired
  DeviceSetInfoService deviceSetInfoService;

  @Autowired
  private OrdMaterialSaveDao ordMaterialSaveDao;

  @Autowired
  private MstMedicateTimingDao mstMedicateTimingDao;

  @Autowired
  private MstEquipmentDao mstEquipDao;

  @Autowired
  private MstProcedureDao mstProcedureDao;

  @Autowired
  private MstMedicineClassDao mstMedicineClassDao;

  @Autowired
  private MstEquipmentClassDao mstEquipClassDao;

  //add #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 20240410 ztc start
  @Autowired
  private OrdMainResource ordMainResource;
  //add #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 20240410 ztc end
  // add 10409 曜日パターン変更の患者イベント修正 関  start
  @Autowired
  private IndScheduleDao indScheduleDao;
  // add 10409 曜日パターン変更の患者イベント修正 関  end

  private static final Integer MEDICINE_TYPE_NORMAL = 1;

  private static final String NULL_VALUE = null;

  // 20:分解薬剤
  private static final String SUPPLIES_CLASS_MEDICINE = "20";
  // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関  end

  /* #10282 START */
  /** Process cache containers differentiated by users */
  private static final ConcurrentHashMap<String, OrdMainForJournal> PROCESSING_STATUS = new ConcurrentHashMap<>();
  /* #10282 END */

  //add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 start
  @Autowired
  MstKurDao mstKurDao;
  //add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 end

  //add 9324 治療情報を異なる状態で変更した後のord _ checklistの再編成共通方法 gjn start
  @Autowired
  CheckListService checkListService;
  //add 9324 治療情報を異なる状態で変更した後のord _ checklistの再編成共通方法 gjn end

  // add #12235【因島】チェックリストの治療条件：抗凝固剤での小数点桁数の扱いが不正 関 start
  @Autowired
  CheckListMakeService checkListMakeService;
  // add #12235【因島】チェックリストの治療条件：抗凝固剤での小数点桁数の扱いが不正 関 end

  // add #10553 strat
  @Autowired
  private JournalCreatePayloadService journalCreatePayloadService;
  // add #10553 end

  // add 10150_9664 by kangjie 20240830 start
  @Autowired
  SameCategoryFluidComponent sameCategoryFluidComponent;
  // add 10150_9664 by kangjie 20240830 end
  @Autowired
  MniMonitorDao mniMonitorDao;
  @Autowired
  private BbsInfoDao bbsInfoDao;

  @Autowired
  private jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.service.PatTreatmentPatternService patTreatmentActualService;

  //add #12462 患者情報共有 zrx start

  @Autowired
  private PatNameIdentificationDao patNameIdentificationDao ;

  @Autowired
  private MstInfectionDao mstInfectionDao;

  @Autowired
  private MstImplantDao mstImplantDao;
  //add #12462 患者情報共有 zrx end

  @Resource(name = "crawlExecutorPool")
  private ExecutorService threadExector;
  // add FNSI-改修内容 補液量、補液速度、血流量、透析温度のチェックを追加 穆 start
  @Override
  public List<TreatmentRecordSetting> getByPatIdAndOrdNo(Long patId) {
    return ordMainDao.selectTreatmentByOrdNo(patId);
  }

  // add FNSI-改修内容 補液量、補液速度、血流量、透析温度のチェックを追加 穆 end
  @Override
  public OrdMain selectByOrdNo(Long ordNo) {
    return ordMainDao.selectByOrdNo(ordNo);
  }

  // add FNSI-7217 バッチ操作インターフェイスを追加します 查 start
  @Override
  public List<OrdMain> selectListByOrdNo(List<Long> ordNoList) {
    return ordMainDao.selectListByOrdNo(ordNoList);
  }
  // add FNSI-7217 バッチ操作インターフェイスを追加します 查 end

  @Override
  public List<OrdMain> selectByOrdNoList(List<Long> ordNoList) {
    return ordMainDao.selectByOrdNoList(ordNoList);
  }

  @Override
  public Page<OrdMain> findAll(Pageable pageable) {
    SelectOptions selectOptions = SelectOptionsUtils.get(pageable, true);
    List<OrdMain> ordMainList = ordMainDao.selectAll(selectOptions);
    return new PageImpl<>(ordMainList, pageable, selectOptions.getCount());
  }

  @Override
  public List<OrdMain> findByCd(String pat_id, String dialysis_date_from, String dialysis_date_to, Long ord_no, Integer edition, String is_del) {
    return ordMainDao.selectByCd(pat_id, dialysis_date_from, dialysis_date_to, ord_no, edition, is_del);
  }

  // mod #11716 曜日パターン変更の不正 関 start
  // add FNSI-改修内容 スケジュール移動に既に同一クール、治療が存在する場合、警告を出す（日付） 穆 start
  @Override
  public List<OrdMain> findByDateCdDayInfo(String facility_cd, Long pat_id, String dialysis_date_from, String dialysis_date_to,
                                           Long ord_no, List<Integer> weeksArry, String is_del, String indTreatmentCd) {
    return ordMainDao.selectByDateCdDayInfo(facility_cd, pat_id, dialysis_date_from, dialysis_date_to, ord_no, weeksArry,
      is_del, indTreatmentCd);
  }

  // add FNSI-改修内容 スケジュール移動に既に同一クール、治療が存在する場合、警告を出す（日付） 穆 end
  // mod #11716 曜日パターン変更の不正 関 end
  @Override
  public List<OrdMain> findByDateCd(String facility_cd, Long pat_id, String dialysis_date_from, String dialysis_date_to,
                                                       Long ord_no, List<Integer> weeksArry, String is_del) {
    return ordMainDao.selectByDateCd(facility_cd, pat_id, dialysis_date_from, dialysis_date_to, ord_no, weeksArry,
      is_del);
  }
  //add 8574  患者経過総合ビューアにてグラフ項目が正しく表示されない 張 start
  @Override
  public List<OrdMainWithlastWeightAfter> findByDateCdWithlastWeightAfter(String facility_cd, Long pat_id, String dialysis_date_from, String dialysis_date_to,
                                                                          Long ord_no, List<Integer> weeksArry, String is_del) {
    return ordMainDao.findByDateCdWithlastWeightAfter(facility_cd, pat_id, dialysis_date_from, dialysis_date_to, ord_no, weeksArry,
      is_del);
  }
//add 8574  患者経過総合ビューアにてグラフ項目が正しく表示されない 張 end

  // add FNSI-FutreNetWeb+SI課題管理No.4362 李 start
  @Override
  public List<OrdMain> findByDateCd(String facility_cd, Long pat_id, String dialysis_date_from,
                                    Long ord_no, List<Integer> weeksArry, String is_del) {
    return ordMainDao.selectWeekChangeByDateCd(facility_cd, pat_id, dialysis_date_from, ord_no, weeksArry, is_del);
  }
  // add FNSI-FutreNetWeb+SI課題管理No.4362 李 end

  //add 7307 曜日変更bug 張 start
  @Override
  public List<OrdMain> selectByFacilityCdAndTreatDate(String facilityCd, String treatDate, Short treatWeek, Integer indKurCd, Integer indBedCd) {
    return ordMainDao.selectByFacilityCdAndTreatDate(facilityCd, treatDate, treatWeek, indKurCd, indBedCd);
  }
  //add 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 start
  // add bug 7810 修正 start
  @Override
  public List<OrdMain> selectByAuxiliaryLiquidAndDeviceMode(String facilityCd,Long patId, List<Integer> deviceModeList,Double auxiliaryLiquid) {
    return ordMainDao.selectByAuxiliaryLiquidAndDeviceMode(facilityCd,patId,deviceModeList,auxiliaryLiquid);
  }
  @Override
  public List<OrdMain> selectByBloodFlowAndDeviceMode(String facilityCd, Long patId, Double dstBloodFlow) {
    return ordMainDao.selectByBloodFlowAndDeviceMode(facilityCd,patId,dstBloodFlow);
  }
  @Override
  public List<OrdMain> selectByDialysisFluidTemperatureAndDeviceMode(String facilityCd, Long patId, Double dstDialysisFluidTemperatureUp, Double dstDialysisFluidTemperatureDown) {
    return ordMainDao.selectByDialysisFluidTemperatureAndDeviceMode(facilityCd,patId,dstDialysisFluidTemperatureUp,dstDialysisFluidTemperatureDown);
  }
  // add bug 7810 修正 end
  @Override
  public List<OrdMain> selectByPatIdAndDeviceMode(String facilityCd,Long patId, Integer mode) {
    return ordMainDao.selectByPatIdAndDeviceMode(facilityCd,patId,mode);
  }

  @Override
  public List<OrdMain> selectBySingleNeedle(String facilityCd, Long patId) {
    return ordMainDao.selectBySingleNeedle(facilityCd,patId);
  }

  //mod 7068 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない 卓 START
    @Transactional
    @Override
    public OrdMainWeekPatternResponse updateWeekPatternInfo(ApiEntityOrdMain.ValiWeekPattern bodyData) {
      // add #11717【因島】曜日パターン変更の動作が遅い fang start
      OrdMainWeekPatternResponse checkResponse = doOrdMainAndPatternCheck(bodyData);
      if(checkResponse != null && !"skip".equals(checkResponse.getBody())) {
        return checkResponse;
      }
      // add #11717【因島】曜日パターン変更の動作が遅い fang end
      String facilityCd = bodyData.getFacility_cd();
      // 患者ID
      Long patId = Long.parseLong(bodyData.getPat_id());
      // 開始日
      String indTreatStartDate = bodyData.getInd_treat_start_date().replaceAll("-", "");
      // 終了日
      String endDate = StringUtils.isEmpty(bodyData.getEnd_date()) ? null : bodyData.getEnd_date().replaceAll("-", "");
      // 治療方法コード
      Integer treatmentCd = bodyData.getInd_treatment_cd() == null ? 0 : Integer.parseInt(bodyData.getInd_treatment_cd());
      // 更新日時
      Timestamp bodyUpdate = Timestamp.valueOf(bodyData.getUp_date());
      // add FNSI-改修内容 スケジュール移動に既に同一クール、治療が存在する場合、警告を出す（日付） 穆 start
      // footer
      String footerFlg = bodyData.getFooter_flg();
      // add FNSI-改修内容 スケジュール移動に既に同一クール、治療が存在する場合、警告を出す（日付） 穆 end
      // add 投与間隔月１のものが月を跨いだ場合、メッセージを出す。 李 start
      // 更新フラグ
      boolean updateFlg = bodyData.isUpdate_flg();
      // add 投与間隔月１のものが月を跨いだ場合、メッセージを出す。 李 end
      // 検査依頼結果の移動及び削除処理ように削除対象の日付を保持
      List<String> deleteDateList = new ArrayList<String>();

      //add #10412 次患者更新関連全体見直し対応 朴 start
      List<OrdMain> doCallNextPatOrdMainList = new ArrayList<>();
      //add #10412 次患者更新関連全体見直し対応 朴 end

      List<OrdMainJournalRequest> requestList=new LinkedList<OrdMainJournalRequest>();
      // 移動元曜日リストを作成
      List<Integer> srcWeek = new ArrayList<Integer>();
      JSONArray weekPatternInfo = new JSONArray(bodyData.getWeek_pattern_info());
      for (int i = 0; i < weekPatternInfo.length(); i++) {
        JSONObject obj = weekPatternInfo.getJSONObject(i);
        srcWeek.add(obj.getInt("fromWeek"));
      }

      // 移動元曜日リストの重複を除去
      srcWeek = srcWeek.stream().distinct().collect(Collectors.toList());
      // 移動先曜日リストを作成
      List<Integer> destWeeks = new ArrayList<Integer>();
      for (int i = 0; i < weekPatternInfo.length(); i++) {
        JSONObject obj = weekPatternInfo.getJSONObject(i);
        destWeeks.add(obj.getInt("value"));
      }
      //add #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy start
      Map<Integer, List<Integer>> seaman = new HashMap<Integer, List<Integer>>();
      Set<Integer> keys = new HashSet<Integer>();
      List<Integer> moveWeek = new ArrayList<Integer>();
      //add #10690 無期限で曜日パターン変更を一部の曜日を変更した際に最終週のみ変更が無かった曜日の治療予定が2重になる 20240531 ztc start
      List<Integer> missingWeekList = new ArrayList<Integer>();
      //add #10690 無期限で曜日パターン変更を一部の曜日を変更した際に最終週のみ変更が無かった曜日の治療予定が2重になる 20240531 ztc end
      for (int i = 0; i < weekPatternInfo.length(); i++) {
        JSONObject obj = weekPatternInfo.getJSONObject(i);
        //mod #10690 無期限で曜日パターン変更を一部の曜日を変更した際に最終週のみ変更が無かった曜日の治療予定が2重になる 20240531 ztc start
        int key = obj.getInt("fromWeek");
        int value = obj.getInt("value");
        if (key != value && !missingWeekList.contains(value)) {
          missingWeekList.add(value);
        }
        if (!seaman.containsKey(key)) {
          ArrayList valueTmp = new ArrayList<Integer>();
//          valueTmp.add(obj.getInt("value"));
          valueTmp.add(value);
          seaman.put(key, valueTmp);
          keys.add(key);
        }else{
//          seaman.get(key).add(obj.getInt("value"));
          seaman.get(key).add(value);
        }
        //mod #10690 無期限で曜日パターン変更を一部の曜日を変更した際に最終週のみ変更が無かった曜日の治療予定が2重になる 20240531 ztc end
      }
      keys.forEach(item -> {
        List<Integer> lisrTmp = seaman.get(item);
      if (!lisrTmp.containsAll(Arrays.asList(item))) {
        moveWeek.add(item);
      }
     });
      //add #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy end

      // 移動元のordMainレコードリストを取得
      // mod 10690 無期限で曜日パターン変更を一部の曜日を変更した際に最終週のみ変更が無かった曜日の治療予定が2重になる 関  start
      //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy start
       List<OrdMain> ordMainList = this.selectMoveTarget(patId, facilityCd, indTreatStartDate, endDate, "0", treatmentCd, srcWeek,false);
//      List<OrdMain> ordMainList = this.selectMoveTarget(patId, facilityCd, indTreatStartDate, endDate, "0", treatmentCd, moveWeek,false);
      //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy end
      // mod 10690 無期限で曜日パターン変更を一部の曜日を変更した際に最終週のみ変更が無かった曜日の治療予定が2重になる 関  end

      //add 10553 start

      List<OrdMain> resultOrdMainChangedDataInfoList = new ArrayList<>(); // 連携用、イベントログ用
      List<OrdMain> resultOrdMainChangeBeforeDataInfoList = new ArrayList<>(); // 連携用、イベントログ用

      // add 10125 検査予定に関する連携イベント作成不備 関  start
      List<PatExamMain> resultPatExamMainChangedDataInfoList = new ArrayList<>(); // 連携用、イベントログ用
      List<PatExamMain> resultPatExamMainChangeBeforeDataInfoList = new ArrayList<>(); // 連携用、イベントログ用
      List<PatRadMain> resultPatRadMainChangedDataInfoList = new ArrayList<>(); // 連携用、イベントログ用
      // add 10125 検査予定に関する連携イベント作成不備 関  end
      List<OrdMain> beforeOrdMainList = ordMainList.stream().map(SerializationUtils::clone).collect(Collectors.toList());
      Map<Long, OrdMain> oldOrdMainMap = new HashMap<>();
      if(beforeOrdMainList != null && !beforeOrdMainList.isEmpty()){
        oldOrdMainMap = beforeOrdMainList.stream().collect(Collectors.toMap(OrdMain::getOrdNo, ordMain -> ordMain));
      }
      //add 10553 end

      //add #10412 次患者更新関連全体見直し対応 朴 start
      doCallNextPatOrdMainList.addAll(beforeOrdMainList);
      //add #10412 次患者更新関連全体見直し対応 朴 end

      // add 9273 start
      List<OrdMainEsListener> ordMainListForEvent = copyOrdMainEntity(ordMainList);
      // add 10409 実績リンク有の患者イベントがキャンセルされない 関  start
      List<OrdMain> ordMainDelList = new ArrayList<>();
      // add 10409 実績リンク有の患者イベントがキャンセルされない 関  end
      // add 10409 曜日パターン変更の患者イベント修正 関  start
      List<Long> connectedOrdNoList = ordMainListForEvent.stream().map(o -> o.getOrdNo()).collect(Collectors.toList());
      List<OrdNoAndConnectedTableKeyData> connectedPatEventList = indScheduleDao.selectConnectedPatEventByOrdNoList(facilityCd, connectedOrdNoList);
      // add 10409 曜日パターン変更の患者イベント修正 関  end
      // add 10618 検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する 関  start
      List<OrdNoAndConnectedTableKeyData> connectedOrdMainExamMainCdList = indScheduleDao.selectConnectedExamMainCdByOrdNoList(facilityCd, connectedOrdNoList);
      // add 10618 検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する 関  end
      // add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 関  start
      List<OrdNoAndConnectedTableKeyData> connectedOrdMainRadResultCdList = indScheduleDao.selectConnectedRadResultCdByOrdNoList(facilityCd, connectedOrdNoList);
      // add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 関  end
      // add 9273 end
      List<Long> ordNoList = ordMainList.stream().map(item -> item.getOrdNo()).distinct().collect(Collectors.toList());
      // add 投与間隔月１のものが月を跨いだ場合、メッセージを出す。 李 start
      boolean dateIntervalFlg = false;
      A:
      for (int index = 0; index < ordMainList.size(); index++) {
        /* mod by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --start */
        // JSONArray IndMediInfoList = new JSONArray(ordMainList.get(index).getIndMediInfo());
        JSONArray IndMediInfoList = new JSONArray(ObjectUtils.isEmpty(ordMainList.get(index).getIndMediInfo()) ? "[]" : ordMainList.get(index).getIndMediInfo());
        /* mod by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --end */
        B:
        if (null != IndMediInfoList && IndMediInfoList.length() > 0 && ! updateFlg) {
          for (int i = 0; i < IndMediInfoList.length(); i++) {
            int dateIntervalNu = (int) IndMediInfoList.getJSONObject(i).get("date_interval");
            if (dateIntervalNu == 5 || dateIntervalNu == 8
              || dateIntervalNu == 9 || dateIntervalNu == 10) {
              dateIntervalFlg = true;
              break A;
            }
          }
        }
      }
      // add 投与間隔月１のものが月を跨いだ場合、メッセージを出す。 李 end

      // 移動先曜日が選択されなかった予定のリストを取得 (削除する)
      JSONArray moveTargetWeekList = new JSONArray(bodyData.getMove_target_week_list());
      List<Integer> srcDelWeek = new ArrayList<Integer>();
      for (int i = 0; i < moveTargetWeekList.length(); i++) {
        Integer weekNo = moveTargetWeekList.getInt(i);
        // del FNSI-8546 単一な曜日変更の場合(例：月→火)、下記の判断によると、曜日変更前に作成されたイベントに対しての削除イベントがないので、この判断を外す。ljx start
        //9273 mod
        if (! srcWeek.contains(weekNo)) {
          srcDelWeek.add(weekNo);
        }
        //9273 mod
        // del FNSI-8546 単一な曜日変更の場合(例：月→火)、下記の判断によると、曜日変更前に作成されたイベントに対しての削除イベントがないので、この判断を外す。ljx end
      }
      List<Long> srcDelNoList = new ArrayList<Long>();

      // del FNSI-改修内容 スケジュール移動に既に同一クール、治療が存在する場合、警告を出す（日付） 穆 start
//    // 件数が0件の場合は、中止対象が存在しない為、処理をスキップする
//    if (srcDelWeek.size() > 0) {
//      List<OrdMain> srcDelList = ordMainService.selectMoveTarget(patId, facilityCd, indTreatStartDate, endDate, "0", treatmentCd, srcDelWeek);
//      for (OrdMain src : srcDelList ) {
//        srcDelNoList.add(src.getOrdNo());
//        // 検査依頼結果の移動及び削除処理ように削除対象の日付を保持
//        deleteDateList.add(LocalDate.parse(src.getTreatDate(), DateTimeFormatter.ofPattern("yyyyMMdd")).format(DateTimeFormatter.ofPattern("yyyy/MM/dd")));
//      }
//    }
//    // 移動先のordMainレコードを取得(事前に削除する)
//    List<OrdMain> tmpDeleteOrdMainList = ordMainService.selectMoveTarget(patId, facilityCd, indTreatStartDate, endDate, null, null, destWeeks);
//    List<Long> deleteOrdNoList = new ArrayList<Long>();
//    // 移動元のordMainレコードを除外したリストを作成する
//    for( OrdMain delOrd : tmpDeleteOrdMainList ) {
//      if(!ordNoList.stream().filter(ordNo -> ordNo.equals(delOrd.getOrdNo())).findFirst().isPresent()) {
//        // 検査依頼結果の移動及び削除処理ように削除対象の日付を保持
//        deleteDateList.add(LocalDate.parse(delOrd.getTreatDate(), DateTimeFormatter.ofPattern("yyyyMMdd")).format(DateTimeFormatter.ofPattern("yyyy/MM/dd")));
//        deleteOrdNoList.add(delOrd.getOrdNo());
//      }
//    }
      // del FNSI-改修内容 スケジュール移動に既に同一クール、治療が存在する場合、警告を出す（日付） 穆 end
      // add FNSI-改修内容 スケジュール移動に既に同一クール、治療が存在する場合、警告を出す（日付） 穆 start
      // 移動先のordMainレコードを取得(事前に削除する)
      // mod FNSI-障害票一覧_患者経過総合ビューア_治療予定(曜日パターン変更) No.2 李 start
      // List<OrdMain> tmpDeleteOrdMainList = ordMainService.selectMoveTarget(patId, facilityCd, indTreatStartDate, endDate, null, null, destWeeks);
      //mod 10553 start
//      List<OrdMain> tmpDeleteOrdMainList = this.selectMoveTarget(patId, facilityCd, indTreatStartDate, endDate, null, treatmentCd, destWeeks,true);
      List<OrdMain> tmpDeleteOrdMainList = this.selectMoveTarget(patId, facilityCd, indTreatStartDate, endDate, "0", treatmentCd, destWeeks,true);
      //mod 10553 end
      // mod FNSI-障害票一覧_患者経過総合ビューア_治療予定(曜日パターン変更) No.2 李 end
      List<Long> deleteOrdNoList = new ArrayList<Long>();

      //add 10807 曜日パターン変更で、他のスケジュールとスケジュール枠がかぶった場合の処理でエラーが発生する。 zrx start
      List<OrdMain> srcDelList = new ArrayList<>();
      if (srcDelWeek.size() > 0) {
        srcDelList = this.selectMoveTarget(patId, facilityCd, indTreatStartDate, endDate, "0", treatmentCd, srcDelWeek, false);
      }
      //add 10807 曜日パターン変更で、他のスケジュールとスケジュール枠がかぶった場合の処理でエラーが発生する。 zrx end

      // 件数が0件の場合は、中止対象が存在しない為、処理をスキップする
      // 既存の予定を残すの場合
      if ("2".equals(footerFlg)) {
        for (int j = 0; j < tmpDeleteOrdMainList.size(); j++) {
          boolean itemFlg = true;
          // 移動元のordMainレコードを除外したリストを作成する
          for (int i = 0; i < ordMainList.size(); i++) {
            if (ordMainList.get(i).getIndTreatmentCd().equals(tmpDeleteOrdMainList.get(j).getIndTreatmentCd()) &&
              ordMainList.get(i).getIndKurCd().equals(tmpDeleteOrdMainList.get(j).getIndKurCd())) {
              itemFlg = false;
              break;
            }
          }
          // オーダ番号が存在しない場合
          if (itemFlg) {
            // 検査依頼結果の移動及び削除処理ように削除対象の日付を保持
            deleteDateList.add(LocalDate.parse(tmpDeleteOrdMainList.get(j).getTreatDate(), DateTimeFormatter.ofPattern("yyyyMMdd")).format(DateTimeFormatter.ofPattern("yyyy/MM/dd")));
            deleteOrdNoList.add(tmpDeleteOrdMainList.get(j).getOrdNo());
          }
        }
        //mod 10807 曜日パターン変更で、他のスケジュールとスケジュール枠がかぶった場合の処理でエラーが発生する。 zrx start
        // add #8548 修正 ljx start
        //テストの横展開、既存の予定を残すの場合も、移動元の予定にて、削除電文は作成されるはず。
//        for (Long srcDelOrdNo : ordNoList) {
//          srcDelNoList.add(srcDelOrdNo);
//        }
        // add #8548 修正 ljx end
        for (OrdMain src : srcDelList) {
          srcDelNoList.add(src.getOrdNo());
        }
        //mod 10807 曜日パターン変更で、他のスケジュールとスケジュール枠がかぶった場合の処理でエラーが発生する。 zrx end
      } else {
        if (srcDelWeek.size() > 0) {
          //del 10807 曜日パターン変更で、他のスケジュールとスケジュール枠がかぶった場合の処理でエラーが発生する。 zrx start
//          List<OrdMain> srcDelList = this.selectMoveTarget(patId, facilityCd, indTreatStartDate, endDate, "0", treatmentCd, srcDelWeek,false);
          //del 10807 曜日パターン変更で、他のスケジュールとスケジュール枠がかぶった場合の処理でエラーが発生する。 zrx end
          // add 10409 実績リンク有の患者イベントがキャンセルされない 関  start
          ordMainDelList = srcDelList;
          // add 10409 実績リンク有の患者イベントがキャンセルされない 関  end
          for (OrdMain src : srcDelList) {
            srcDelNoList.add(src.getOrdNo());
            // 検査依頼結果の移動及び削除処理ように削除対象の日付を保持
            deleteDateList.add(LocalDate.parse(src.getTreatDate(), DateTimeFormatter.ofPattern("yyyyMMdd")).format(DateTimeFormatter.ofPattern("yyyy/MM/dd")));
          }
        }
        // 移動元のordMainレコードを除外したリストを作成する
        for (OrdMain delOrd : tmpDeleteOrdMainList) {
          if (! ordNoList.stream().filter(ordNo -> ordNo.equals(delOrd.getOrdNo())).findFirst().isPresent()) {
            // 検査依頼結果の移動及び削除処理ように削除対象の日付を保持
            deleteDateList.add(LocalDate.parse(delOrd.getTreatDate(), DateTimeFormatter.ofPattern("yyyyMMdd")).format(DateTimeFormatter.ofPattern("yyyy/MM/dd")));
            deleteOrdNoList.add(delOrd.getOrdNo());
          }
        }
      }

      //del 10553 end
      // add 10409 曜日パターン変更の患者イベント修正 関  start
//      List<OrdNoAndConnectedTableKeyData> delPatEventList = new ArrayList<>();
//      if (srcDelNoList.size() > 0) {
//        delPatEventList = indScheduleDao.selectConnectedPatEventByOrdNoList(facilityCd, srcDelNoList);
//      }
      // add 10125 検査予定に関する連携イベント作成不備 関  start
      List<OrdNoAndConnectedTableKeyData> connectedOrdMainExamMainCdDelList = new ArrayList<>();
      List<OrdNoAndConnectedTableKeyData> connectedOrdMainRadResultCdDelList = new ArrayList<>();
      if (ordMainDelList.size() > 0) {
        List<Long> connectedOrdNoDelList = ordMainDelList.stream().map(o -> o.getOrdNo()).collect(Collectors.toList());
        connectedOrdMainExamMainCdDelList = indScheduleDao.selectConnectedExamMainCdByOrdNoList(facilityCd, connectedOrdNoDelList);
        connectedOrdMainRadResultCdDelList = indScheduleDao.selectConnectedRadResultCdByOrdNoList(facilityCd, connectedOrdNoDelList);
      }
      // add 10125 検査予定に関する連携イベント作成不備 関  end
      // add 10409 曜日パターン変更の患者イベント修正 関  end
      //del 10553 end

      // add FNSI-改修内容 スケジュール移動に既に同一クール、治療が存在する場合、警告を出す（日付） 穆 end
      // 移動先曜日が選択されなかった予定 の ordNo と合算し、重複を削除する
      List<Long> sumDeleteOrdNoList = new ArrayList<>();
      sumDeleteOrdNoList.addAll(srcDelNoList);
      sumDeleteOrdNoList.addAll(deleteOrdNoList);
      //add 7068 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない start
      List<OrdMain> dellist = this.selectByOrdNoList(sumDeleteOrdNoList);
      // del #10553 start
//      List<OrdMain> dellistForJournal=dellist.stream().filter(item->item.getIndKurCd()!=0).distinct().collect(Collectors.toList());
      // del #10553 end
      // add #10553 start
      if(!sumDeleteOrdNoList.isEmpty()){
        resultOrdMainChangeBeforeDataInfoList.addAll(this.selectByOrdNoList(sumDeleteOrdNoList)); // 変更前データ退避
      }
      // add #10553 end
      // del #10553 start
//      JournalCreateRequestPayload journalCreateRequestPayload = new JournalCreateRequestPayload();
//      journalCreateRequestPayload.setFacilityCd(bodyData.getFacility_cd());
//      journalCreateRequestPayload.setCrud("D");
//      journalCreateRequestPayload.setHospPatId(bodyData.getHosp_pat_id());
//      journalCreateRequestPayload.setPatId(Long.valueOf(bodyData.getPat_id()));
//      journalCreateRequestPayload.setUserId(Long.valueOf(bodyData.getInd_user()));
//      journalCreateRequestPayload.setOpeCd("004002");

      //mod 7068 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない 張 start
//    asyncService.sendExternalConnection(dellist, journalCreateRequestPayload);
//      if(!bodyData.getSkip()) {
        //mod 7068 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない 卓 start
//      asyncService.sendExternalConnection(dellist, journalCreateRequestPayload);
//        journalService.callCreateJournal(dellistForJournal, journalCreateRequestPayload,requestList);
      // del #10553 end
//      asyncService.requestApiJournalCreate(dellist, journalCreateRequestPayload);
        //mod 7068 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない 卓 end
//      }
      //mod 7068 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない 張 start
      //add 7068 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない end
      /* modify by shiyw 2023-02-21 [#8101] --start */
      // 治療予定の削除
      if(!dellist.isEmpty()){
//      int count = this.deleteByOrdNo(sumDeleteOrdNoList);
        int count = this.deleteByOrMainList(dellist);
        // 治療予定の中止に失敗した場合
        if (count <= 0) {
          HttpStatus status = HttpStatus.INTERNAL_SERVER_ERROR;
          //引数は、ボディデータ,ヘッダーデータ,ステータス
          OrdMainWeekPatternResponse response = new OrdMainWeekPatternResponse();
          response.setBody("レコードの更新に失敗しました。");
          response.setHeaders(null);
          response.setStatus(status);
          return response;
        }
        //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
        List<Long> ordNoDellist = dellist.stream().map(item -> item.getOrdNo()).distinct().collect(Collectors.toList());
        ordChecklistDao.deleteByOrdNoAndFacilityCdBatch(ordNoDellist, bodyData.getFacility_cd());
        //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
      }
      /* modify by shiyw 2023-02-21 [#8101] --end */
      // 予定の移動
      HashMap<Short, List<Short>> changeWeekList = new HashMap<Short, List<Short>>();
      // 移動元曜日毎の、移動先曜日リストを作成する
      for (int i = 0; i < weekPatternInfo.length(); i++) {
        JSONObject obj = weekPatternInfo.getJSONObject(i);
        Short weekKey = (short) obj.getInt("fromWeek");
        // リストになければキーを追加、あればキーの配列に追加
        if (changeWeekList.containsKey(weekKey)) {
          changeWeekList.get(weekKey).add((short) obj.getInt("value"));
        } else {
          List<Short> tmp = new ArrayList<Short>();
          tmp.add((short) obj.getInt("value"));
          changeWeekList.put(weekKey, tmp);
        }
      }

      LocalDate lStartDate = LocalDate.parse(indTreatStartDate, DateTimeFormatter.ofPattern("yyyyMMdd"));
      LocalDate lEndDate = StringUtils.isEmpty(endDate) ? null : LocalDate.parse(endDate, DateTimeFormatter.ofPattern("yyyyMMdd"));
      // 検査予定、放射線検査予定変更用に、変更前日付、変更後日付のセットを保持
      Map<String, String> moveDateMap = new HashMap<String, String>();
      Map<Long, String> delOrdMainTreateDateMap = new HashMap<Long, String>();
      //add 7068 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない start
      List<OrdMain> updatelist = new ArrayList<>();
      List<OrdMain> addlist = new ArrayList<>();
      //add 7307 曜日変更bug 張 start
      Set<Long> nobedlist = new HashSet<Long>();
      //add 7307 曜日変更bug 張 end
      //add 7068 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない end

      /* add by guanhao 202211213[8108] 曜日パターンが遅い。 --start*/
      List<Long> updateOrdNoList = new ArrayList<>();
      List<OrdMain> updateOrdMainList = new ArrayList<>();
      /* add by guanhao 202211213[8108] 曜日パターンが遅い。 --end*/

      /* add by chamaojia 2023-03-20 [8101] クエリ回数を減らす --start */
      List<OrdMain> ordMainSaveList = new ArrayList<>();
      List<OrdMain> ordMainMoveList = new ArrayList<>();
      MstPersonalUser user = mstPersonalUserDao.selectById(Long.parseLong(bodyData.getInd_user()));
      /* add by chamaojia 2023-03-20 [8101] クエリ回数を減らす --end */
      // add #11717【因島】曜日パターン変更の動作が遅い fang start
      List<OrdMain> updateOrdList = new ArrayList<>();
      // add #11717【因島】曜日パターン変更の動作が遅い fang end
      for (Short weekKey : changeWeekList.keySet()) {
        // 曜日番号リスト (1：月曜 ～ 7：日曜) / ソートしておく
        List<Short> toWeekList = changeWeekList.get(weekKey);
        Collections.sort(toWeekList);
        // 移動元のordMainレコードリストから、移動元曜日のレコードを抽出する
        List<OrdMain> moveTargetList = ordMainList.stream().filter(item -> item.getTreatWeek().equals(weekKey)).collect(Collectors.toList());
        //9273 start
        moveTargetList = moveTargetList.stream().sorted(Comparator.comparing(e -> (e.getTreatDate()))).collect(Collectors.toList());
        //9273 end
        //upd by ztc 2023-03-24 曜日パターン変更月木→月水金日 bug --start /
        List<OrdMain> moveTargetListDep = new ArrayList<>(moveTargetList.size());
        //9273 start
        Map directMap = new HashMap();
        //9273 end
        for (OrdMain omn : moveTargetList) {
          OrdMain newOrdMain = new OrdMain();
          BeanUtils.copyProperties(omn,newOrdMain);
          moveTargetListDep.add(newOrdMain);
        }
        //upd by ztc 2023-03-24 曜日パターン変更月木→月水金日 bug --end /
        //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
        List<Long> moveTargetListDepOrdNoList = moveTargetListDep.stream().map(item -> item.getOrdNo()).distinct().collect(Collectors.toList());
        ordChecklistDao.deleteByOrdNoAndFacilityCdBatch(moveTargetListDepOrdNoList, bodyData.getFacility_cd());
        //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end

        // 移動元のordMainレコードリスト でループ
        for (OrdMain ord : moveTargetList) {
          // add #10307 曜日パターン変更を行うと1年以降の治療予定が作成される 20240306 ztc start
          Boolean rootOrdMainDataUsage = false;
          // add #10307 曜日パターン変更を行うと1年以降の治療予定が作成される 20240306 ztc end
          //add 7307 曜日変更bug 張 start
          ordMainList.remove(ord);
          //add 7307 曜日変更bug 張 end
          // 移動対象予定の治療日を取得する
          LocalDate treatDate = LocalDate.parse(ord.getTreatDate(), DateTimeFormatter.ofPattern("yyyyMMdd"));
          // 移動後の日付を取得する (treatDate の週の月曜日を取得し、移動先曜日の曜日コードに応じて日付を加算して算出する)
          //del 10553 start
//          LocalDate tmpMonday = treatDate.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
          //del 10553 end
          List<LocalDate> toDayList = new ArrayList<LocalDate>();
          for (Short w : toWeekList) {
            //9273 start
            // 移動後の日付が、指定範囲内に収まっている場合のみ移動処理を実施
            // add 内部　6117　ljx start
            //LocalDate toMoveDay = tmpMonday.plusDays(w - 1);
            LocalDate toMoveDay = null;
            // mod #11966 【因島】実績を含む週の曜日パターン変更が不正 fang start
            int weekDay = w - weekKey;
//            int weekDay =(w - weekKey) < 0?7+w - weekKey:w - weekKey;
//            if(ord.getTreatDate().equals(moveTargetList.get(0).getTreatDate())){
//              LocalDate toMoveDay1 = treatDate.plusDays(weekDay);
//              LocalDate toMoveDay2 = treatDate.minusDays(7-weekDay);
//              // mod #9273(10277) 仕様変更:開始日より前の日付に○が付く事がある、以下の処理は開始日を比較する djy start
//              //if(toMoveDay2.isBefore(LocalDate.now())){
//              if (toMoveDay2.isBefore(lStartDate)) {
//                // mod #9273(10277) 仕様変更:開始日より前の日付に○が付く事がある、以下の処理は開始日を比較する djy end
//                //後ろ向き
//                directMap.put(weekKey+"->"+w,"future");
//              }else{
//                //前倒し
//                directMap.put(weekKey+"->"+w,"past");
//              }
//            }
//            if("past".equals(directMap.get(weekKey+"->"+w))){
//              toMoveDay = treatDate.minusDays(7-weekDay);
//            }else{
//              toMoveDay = treatDate.plusDays(weekDay);
//            }
            if(weekDay > 0) {
              toMoveDay =treatDate.plusDays(weekDay);
            } else {
              toMoveDay = treatDate.minusDays(Math.abs(weekDay));
            }
            // add 内部　6117　ljx end
            // add 投与間隔月１のものが月を跨いだ場合、メッセージを出す。 李 start
            if (! updateFlg && toMoveDay.isAfter(lStartDate) && toMoveDay.isBefore(lEndDate)) {
              // mod #11966 【因島】実績を含む週の曜日パターン変更が不正 fang end
              try {
                SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd");
                Date dateTreatDate = format.parse(treatDate.toString());
                Date dateToMoveDay = format.parse(toMoveDay.toString());
                Calendar calendar = Calendar.getInstance();
                calendar.setTime(dateTreatDate);
                calendar.getTime();
                int dateTmpMonDayMonth = calendar.get(Calendar.MONTH) + 1;
                calendar.setTime(dateToMoveDay);
                calendar.getTime();
                calendar.getTime();
                int dateToMoveDayMonth = calendar.get(Calendar.MONTH) + 1;
                if (dateIntervalFlg && dateTmpMonDayMonth != dateToMoveDayMonth) {
                  OrdMainWeekPatternResponse response = new OrdMainWeekPatternResponse();
                  response.setBody("投与間隔月１のものが月を跨いだ、ご確認ください。");
                  response.setHeaders(null);
                  response.setStatus(HttpStatus.OK);
                  return response;
                }
              } catch (ParseException e) {
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
          }
            // add 投与間隔月１のものが月を跨いだ場合、メッセージを出す。 李 end
            // mod 内部　6117　ljx start
            //mod 9273 start
            if (
              (lStartDate.equals(toMoveDay) || lStartDate.isBefore(toMoveDay)) &&
              (Objects.isNull(lEndDate) || (lEndDate.equals(toMoveDay) || lEndDate.isAfter(toMoveDay)))) {
//            if (
//              (lStartDate.equals(toMoveDay) || lStartDate.isBefore(toMoveDay)) ) {
            //mod 9273 end
              // add #10307 曜日パターン変更を行うと1年以降の治療予定が作成される 20240306 ztc start
              rootOrdMainDataUsage = true;
              // add #10307 曜日パターン変更を行うと1年以降の治療予定が作成される 20240306 ztc end
              toDayList.add(toMoveDay);
              // mod 内部　6117　ljx end
              //add 7240 曜日パターン変更の変更前に表示される曜日が正しく表示されない 張 start
            }
            // mod #11966 【因島】実績を含む週の曜日パターン変更が不正 fang start
//            else{
//              // add #10307 曜日パターン変更を行うと1年以降の治療予定が作成される 20240306 ztc start
//              if(!rootOrdMainDataUsage){
//              // add #10307 曜日パターン変更を行うと1年以降の治療予定が作成される 20240306 ztc end
//                this.delete(ord);
//              // add #10307 曜日パターン変更を行うと1年以降の治療予定が作成される 20240306 ztc start
//              }
//              // add #10307 曜日パターン変更を行うと1年以降の治療予定が作成される 20240306 ztc end
//            }
            //9273 end
            //add 7240 曜日パターン変更の変更前に表示される曜日が正しく表示されない 張 end
          }
          if(!rootOrdMainDataUsage){
            // add #10307 曜日パターン変更を行うと1年以降の治療予定が作成される 20240306 ztc end
            this.delete(ord);
            // add #10307 曜日パターン変更を行うと1年以降の治療予定が作成される 20240306 ztc start
          }
          // mod #11966 【因島】実績を含む週の曜日パターン変更が不正 fang end
          // 9273 start 移動先日付の順番を調整。移動先曜日が複数ある場合、移動元日に近い方に移動
          Comparator<LocalDate> comparator = Comparator.comparingInt(date -> (int) Math.abs(treatDate.until(date, ChronoUnit.DAYS)));
          Collections.sort(toDayList, comparator);
          //9273 end
          // 移動先の日付が1件以上ある場合の初期移動
          if (toDayList.size() > 0) {
            // 移動先曜日が複数ある場合、月曜日に近い方に移動し、投与間隔が週1等のデータを引き継ぐ
            LocalDate firstDay = toDayList.get(0);
            // 検査依頼、放射線予定変更用に、変更前日付、変更後日付のセットを取得
            moveDateMap.put(
              LocalDate.parse(ord.getTreatDate(), DateTimeFormatter.ofPattern("yyyyMMdd")).format(DateTimeFormatter.ofPattern("yyyy/MM/dd")),
              firstDay.format(DateTimeFormatter.ofPattern("yyyy/MM/dd")));

            delOrdMainTreateDateMap.put(ord.getOrdNo(),ord.getTreatDate());

            // 移動後の日付/曜日を設定
            ord.setTreatDate(firstDay.format(DateTimeFormatter.ofPattern("yyyyMMdd")));
            ord.setTreatWeek((short) firstDay.getDayOfWeek().getValue());
            // ベッドを未登録にする
            //mod 7307 曜日変更bug 張 start
//          ord.setIndBedCd(0);
//          ord.setIndBedName(null);
//upd by ztc 2023-03-24 曜日パターン変更月木→月水金日 既存操作時に古いデータベッドが空になる問題 bug --start /
//            if (!bodyData.getCover()) {
//              ord.setIndBedCd(0);
//              ord.setIndBedName(null);
//            }
//upd by ztc 2023-03-24 曜日パターン変更月木→月水金日 既存操作時に古いデータベッドが空になる問題 bug --end /
            //mod 7307 曜日変更bug 張 end
            // 更新日時
            ord.setUpDate(bodyUpdate);
            // 指示者の更新
            ord = this.addIndUserAndUpdUserInfo(ord, Long.parseLong(bodyData.getInd_user()), Long.parseLong(bodyData.getUpd_user()), user);
            // 治療情報の更新(治療日の移動)
            // add #11717【因島】曜日パターン変更の動作が遅い fang start
            if(checkResponse == null) {
              // add #11717【因島】曜日パターン変更の動作が遅い fang end
//add 7307 曜日変更bug 張 start
              if(bodyData.getCover()) {
                /* modify by shiyw 2023-03-21 [#8101] --start */
                if( (ord.getIndKurCd() != null && ord.getIndBedCd() != null) &&  (!ord.getIndKurCd().equals(0) && !ord.getIndBedCd().equals(0)) ) {
                  List<OrdMain> oMainList = this.selectByFacilityCdAndTreatDate(facilityCd, firstDay.format(DateTimeFormatter.ofPattern("yyyyMMdd")), ord.getTreatWeek(), ord.getIndKurCd(), ord.getIndBedCd());
                  OrdMain finalOrd = ord;
                  //mod 10993 曜日パターン変更での曜日入れ替えでベッド未登録になる start
//                oMainList = oMainList.stream().filter(item -> !item.getOrdNo().equals(finalOrd.getOrdNo())).collect(Collectors.toList());
                  List<OrdMain> filteredOMainList = new ArrayList<>();
                  for (OrdMain item : oMainList) {
                    if (!item.getOrdNo().equals(finalOrd.getOrdNo())){
                      if(Objects.equals(item.getPatId(), finalOrd.getPatId())){
                        if(!srcWeek.contains((finalOrd.getTreatWeek() != null ? finalOrd.getTreatWeek().intValue() : null))){
                          filteredOMainList.add(item);
                        }
                      } else {
                        filteredOMainList.add(item);
                      }
                    }
                  }
//                if (filteredOMainListoMainList.size() > 0) {
//                  oMainList.forEach(item -> {
                  if (filteredOMainList.size() > 0) {
                    filteredOMainList.forEach(item -> {
                      //mod 10993 曜日パターン変更での曜日入れ替えでベッド未登録になる end
                      //mod 10553 start
                      if (item.getIndBedCd() != 0&&item.getIndKurCd() != 0) {
                        OrdMain beforeOrd = new OrdMain();
                        BeanUtils.copyProperties(item,beforeOrd);
                        resultOrdMainChangeBeforeDataInfoList.add(beforeOrd);
                        //mod 10553 end
                        item.setIndBedCd(0);
                        item.setIndBedName(null);
                      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
                      LogEventUtils.setOperatorId(item,logService);
                      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
                        updateOrdNoList.add(item.getOrdNo());
                        nobedlist.add(item.getOrdNo());
                        updateOrdMainList.add(item);
                      }
                    });
                  }
                  /* modify by shiyw 2023-03-21 [#8101] --end */
                }
                /* modify by guanhao 202211213[8108] 曜日パターンが遅い。 --start*/
                //OrdMain finalOrd = ord;
                //oMainList.stream().filter(item -> {
                //  return item.getIndKurCd().equals(finalOrd.getIndKurCd()) && finalOrd.getIndBedCd().equals(item.getIndBedCd());
                //});
                //
                //if (oMainList.size() > 0) {
                //  oMainList.forEach(item -> {
                //    item.setIndBedCd(0);
                //    item.setIndBedName(null);
                //    this.update(item);
                //    nobedlist.add(item.getOrdNo());
                //  });
                //}
              } else{
                //upd by ztc 2023-03-24 曜日パターン変更月木→月水金日 既存操作時に古いデータベッドが空になる問題 bug --start /
                OrdMain updOrd = ord;
                Optional<OrdMain> optionalOldOrdMain = moveTargetListDep.stream()
                  .filter(oom -> oom.getTreatDate().equals(updOrd.getTreatDate()))
                  .findFirst();

                if (optionalOldOrdMain.isPresent()) {
                  OrdMain oldOrdMain = optionalOldOrdMain.get();
                  ord.setIndBedCd(oldOrdMain.getIndBedCd());
                  ord.setIndBedName(oldOrdMain.getIndBedName());
                } else {
                  //mod 10807 曜日パターン変更で、他のスケジュールとスケジュール枠がかぶった場合の処理でエラーが発生する。 zrx start
//                ord.setIndBedCd(0);
//                ord.setIndBedName(null);
                  if( (ord.getIndKurCd() != null && ord.getIndBedCd() != null) &&  (!ord.getIndKurCd().equals(0) && !ord.getIndBedCd().equals(0)) ) {
                    List<OrdMain> oMainList = this.selectByFacilityCdAndTreatDate(facilityCd, firstDay.format(DateTimeFormatter.ofPattern("yyyyMMdd")), ord.getTreatWeek(), ord.getIndKurCd(), ord.getIndBedCd());
                    OrdMain finalOrd = ord;
                    oMainList = oMainList.stream().filter(item -> !item.getOrdNo().equals(finalOrd.getOrdNo())).collect(Collectors.toList());
                    //mod 10993 曜日パターン変更での曜日入れ替えでベッド未登録になる start
                    List<OrdMain> filteredOMainList = new ArrayList<>();
                    for (OrdMain item : oMainList) {
                      if (!item.getOrdNo().equals(finalOrd.getOrdNo())){
                        if(Objects.equals(item.getPatId(), finalOrd.getPatId())){
                          if(!srcWeek.contains((finalOrd.getTreatWeek() != null ? finalOrd.getTreatWeek().intValue() : null))){
                            filteredOMainList.add(item);
                          }
                        } else {
                          filteredOMainList.add(item);
                        }
                      }
                    }
//                  if (oMainList.size() > 0) {
                    if (filteredOMainList.size() > 0) {
                      //mod 10993 曜日パターン変更での曜日入れ替えでベッド未登録になる end
                      ord.setIndBedCd(0);
                      ord.setIndBedName(null);
                    }
                  }
                  //mod 10807 曜日パターン変更で、他のスケジュールとスケジュール枠がかぶった場合の処理でエラーが発生する。 zrx end
                }
                //upd by ztc 2023-03-24 曜日パターン変更月木→月水金日 既存操作時に古いデータベッドが空になる問題 bug --end /
              }
              /* modify by guanhao 202211213[8108] 曜日パターンが遅い。 --end*/
              // add #11717【因島】曜日パターン変更の動作が遅い fang start
            }
            // add #11717【因島】曜日パターン変更の動作が遅い fang end

            //add 7307 曜日変更bug 張 end
            //mod 7068 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない start
//          ordMainService.update(ord);
            //this.delete(ord); // del by shiyw 2023-02-24 [#8101] Use following code "this.deleteList(dellist)" instead of this code
            OrdMain newOrdMain = new OrdMain();
            BeanUtils.copyProperties(ord,newOrdMain);
            //upd by ztc 2023-03-24 曜日パターン変更月木→月水金日 bug --start /
//            dellist.add(newOrdMain);
            //upd by ztc 2023-03-24 曜日パターン変更月木→月水金日 bug --end /
            /* modify by chamaojia 2023-03-20 [8101] 一括処理に変更 --start */
//            if(!bodyData.getSkip()) {
//              long ordNo = this.insert(ord);
//              ord.setOrdNo(ordNo);
//            }
//            addlist.add(ord);
            //upd by ztc 2023-03-24 曜日パターン変更月木→月水金日 bug --start /
            //9273
            //ordMainSaveList.add(newOrdMain);
            ordMainMoveList.add(newOrdMain);
            // mod 10374  患者検索において曜日パターン変更後も変更前の状態で抽出される zy start
//            ordMainDao.update(ord);
            // add #11717【因島】曜日パターン変更の動作が遅い fang start
            updateOrdList.add(newOrdMain);
//            this.update(ord);
            // add #11717【因島】曜日パターン変更の動作が遅い fang end
            // mod 10374  患者検索において曜日パターン変更後も変更前の状態で抽出される zy end
            //9273
            //upd by ztc 2023-03-24 曜日パターン変更月木→月水金日 bug --end /
            /* modify by chamaojia 2023-03-20 [8101] 一括処理に変更 --end */
            //add 7068 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない start
//          updatelist.add(ord);
            //add 7068 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない end
          }

          //mod 7068 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない end
          // 移動先が2件以上ある場合
          if (toDayList.size() > 1) {
            // 2件目以降の処理
            for (int i = 1; toDayList.size() > i; i++) {
              LocalDate lDate = toDayList.get(i);
              ord.setTreatDate(lDate.format(DateTimeFormatter.ofPattern("yyyyMMdd")));
              ord.setTreatWeek((short) lDate.getDayOfWeek().getValue());
              // mod FNSI-改修内容 治療予定－曜日パターン変更 投薬情報は若い曜日にのみ割り振る 穆 start
//            // 投与間隔等の調整
//            JSONArray editMediJson = new JSONArray(ord.getIndMediInfo());
//            // 投与間隔が 0:毎回 以外の場合は削除する
//            JSONArray tmpMediObj = new JSONArray();
//            editMediJson.forEach(medi -> {
//              JSONObject mediObj = (JSONObject)medi;
//              // 投与間隔(date_interval)を取得
//              if (mediObj.getInt("date_interval") == 0) {
//                tmpMediObj.put(mediObj);
//              }
//            });
//            ord.setIndMediInfo(tmpMediObj.toString());
              //del FNSI-7310 劉全航 start
              //ord.setIndMediInfo("[]");
              //del FNSI-7310 劉全航 end
              // mod FNSI-改修内容 治療予定－曜日パターン変更 投薬情報は若い曜日にのみ割り振る 穆 end
              // 治療情報の登録
              // add #11717【因島】曜日パターン変更の動作が遅い fang start
              if(checkResponse == null) {
                // add #11717【因島】曜日パターン変更の動作が遅い fang end
                //add 7307 曜日変更bug 張 start
                if(bodyData.getCover()) {
                  /* add by shiyw 2023-03-21 [#8101] --start */
                  if( (ord.getIndKurCd() != null && ord.getIndBedCd() != null) &&  (!ord.getIndKurCd().equals(0) && !ord.getIndBedCd().equals(0)) ) {
                    /* add by shiyw 2023-03-21 [#8101] --end */
                    List<OrdMain> oMainList = this.selectByFacilityCdAndTreatDate(facilityCd, lDate.format(DateTimeFormatter.ofPattern("yyyyMMdd")), ord.getTreatWeek(), ord.getIndKurCd(), ord.getIndBedCd());
                    OrdMain finalOrd = ord;
                    //mod 10993 曜日パターン変更での曜日入れ替えでベッド未登録になる start
//                  oMainList = oMainList.stream().filter(item -> !item.getOrdNo().equals(finalOrd.getOrdNo())).collect(Collectors.toList());
                    List<OrdMain> filteredOMainList = new ArrayList<>();
                    for (OrdMain item : oMainList) {
                      if (!item.getOrdNo().equals(finalOrd.getOrdNo())){
                        if(Objects.equals(item.getPatId(), finalOrd.getPatId())){
                          if(!srcWeek.contains((finalOrd.getTreatWeek() != null ? finalOrd.getTreatWeek().intValue() : null))){
                            filteredOMainList.add(item);
                          }
                        } else {
                          filteredOMainList.add(item);
                        }
                      }
                    }
                    /* modify by guanhao 202211213[8108] 曜日パターンが遅い。 --start*/
                    //OrdMain finalOrd1 = ord;
                    //oMainList.stream().filter(item -> {
                    //  return item.getIndKurCd().equals(finalOrd1.getIndKurCd()) && finalOrd1.getIndBedCd().equals(item.getIndBedCd());
                    //});
                    //if (oMainList.size() > 0) {
                    //  oMainList.forEach(item -> {
                    //    item.setIndBedCd(0);
                    //    item.setIndBedName(null);
                    //    this.update(item);
                    //    nobedlist.add(item.getOrdNo());
                    //  });
                    //}
//                  if (oMainList.size() > 0) {
//                    oMainList.forEach(item -> {
                    if (filteredOMainList.size() > 0) {
                      filteredOMainList.forEach(item -> {
                        //mod 10993 曜日パターン変更での曜日入れ替えでベッド未登録になる end
                        //mod 10553 start
                        if (item.getIndBedCd() != 0 && item.getIndKurCd() != 0) {
                          OrdMain beforeOrd = new OrdMain();
                          BeanUtils.copyProperties(item,beforeOrd);
                          resultOrdMainChangeBeforeDataInfoList.add(beforeOrd);
                          //mod 10553 end

                          item.setIndBedCd(0);
                          item.setIndBedName(null);
                        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
                        LogEventUtils.setOperatorId(item,logService);
                        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
                        updateOrdNoList.add(item.getOrdNo());
                          nobedlist.add(item.getOrdNo());
                          updateOrdMainList.add(item);
                        }
                      });
                      //orderMainList.addAll(oMainList);
                    }
                  }
                }else {
                  //upd by ztc 2023-03-24 曜日パターン変更月木→月水金日 既存操作時に古いデータベッドが空になる問題 bug --start /
                  OrdMain updOrd = ord;
                  Optional<OrdMain> optionalOldOrdMain = moveTargetListDep.stream()
                    .filter(oom -> oom.getTreatDate().equals(updOrd.getTreatDate()))
                    .findFirst();

                  if (optionalOldOrdMain.isPresent()) {
                    OrdMain oldOrdMain = optionalOldOrdMain.get();
                    ord.setIndBedCd(oldOrdMain.getIndBedCd());
                    ord.setIndBedName(oldOrdMain.getIndBedName());
                  } else {
                    //mod 10807 曜日パターン変更で、他のスケジュールとスケジュール枠がかぶった場合の処理でエラーが発生する。 zrx start
//                  ord.setIndBedCd(0);
//                  ord.setIndBedName(null);
                    if( (ord.getIndKurCd() != null && ord.getIndBedCd() != null) &&  (!ord.getIndKurCd().equals(0) && !ord.getIndBedCd().equals(0)) ) {
                      List<OrdMain> oMainList = this.selectByFacilityCdAndTreatDate(facilityCd, lDate.format(DateTimeFormatter.ofPattern("yyyyMMdd")), ord.getTreatWeek(), ord.getIndKurCd(), ord.getIndBedCd());
                      OrdMain finalOrd = ord;
                      //mod 10993 曜日パターン変更での曜日入れ替えでベッド未登録になる start
                      oMainList = oMainList.stream().filter(item -> !item.getOrdNo().equals(finalOrd.getOrdNo())).collect(Collectors.toList());
                      List<OrdMain> filteredOMainList = new ArrayList<>();
                      for (OrdMain item : oMainList) {
                        if (!item.getOrdNo().equals(finalOrd.getOrdNo())){
                          if(Objects.equals(item.getPatId(), finalOrd.getPatId())){
                            if(!srcWeek.contains((finalOrd.getTreatWeek() != null ? finalOrd.getTreatWeek().intValue() : null))){
                              filteredOMainList.add(item);
                            }
                          } else {
                            filteredOMainList.add(item);
                          }
                        }
                      }
//                    if (oMainList.size() > 0) {
                      if (filteredOMainList.size() > 0) {
                        //mod 10993 曜日パターン変更での曜日入れ替えでベッド未登録になる end
                        ord.setIndBedCd(0);
                        ord.setIndBedName(null);
                      }
                    }
                    //mod 10807 曜日パターン変更で、他のスケジュールとスケジュール枠がかぶった場合の処理でエラーが発生する。 zrx end
                  }
                  //upd by ztc 2023-03-24 曜日パターン変更月木→月水金日 既存操作時に古いデータベッドが空になる問題 bug --end /
                }
                /* modify by guanhao 202211213[8108] 曜日パターンが遅い。 --end*/
                // add #11717【因島】曜日パターン変更の動作が遅い fang start
              }
              // add #11717【因島】曜日パターン変更の動作が遅い fang end

              //add 7307 曜日変更bug 張 end
              //add 7068 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない start
              /* modify by chamaojia 2023-03-20 [8101] 一括処理に変更 --start */
//              if(!bodyData.getSkip()) {
//                long ordNo = this.insert(ord);
//                ord.setOrdNo(ordNo);
//              }
//              addlist.add(ord);
            //upd by ztc 2023-03-24 曜日パターン変更月木→月水金日 bug --start /
              OrdMain newOrdMain = new OrdMain();
              BeanUtils.copyProperties(ord,newOrdMain);
              ordMainSaveList.add(newOrdMain);
            //upd by ztc 2023-03-24 曜日パターン変更月木→月水金日 bug --end /
              /* modify by chamaojia 2023-03-20 [8101] 一括処理に変更 --end */
              //add 7068 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない start
            }
          }
        }
        //upd by ztc 2023-03-24 曜日パターン変更月木→月水金日 bug --start /
        //9273 del
        //this.batchDelete(moveTargetListDep);
        //9273 del
        //upd by ztc 2023-03-24 曜日パターン変更月木→月水金日 bug --end /
      }
      // add #11717【因島】曜日パターン変更の動作が遅い fang start
      if(!CollectionUtils.isEmpty(updateOrdList)) {
        this.update(updateOrdList);
      }
      // add #11717【因島】曜日パターン変更の動作が遅い fang end
      // #10196 MaterialSave add by Zhou.tao
      if (CollectionUtils.isNotEmpty(ordMainMoveList)) {
        ordMaterialSaveService.updMaterialSaveBaseDateByOrdMain(ordMainMoveList);
      }
      // add #10307 曜日パターン変更を行うと1年以降の治療予定が作成される 20240306 ztc start
      List<OrdMain> processedOrdMain = new ArrayList<>();
      processedOrdMain.addAll(ordMainMoveList);
      processedOrdMain.addAll(ordMainSaveList);
      List<String> previous7Days = new ArrayList<>();
      DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
      //締切日の7日間前のデータ（締切日を含む）
      // mod #11966 【因島】実績を含む週の曜日パターン変更が不正 fang start
      if(bodyData.getEnd_date() != null && bodyData.getMax_date() != null
        && bodyData.getEnd_date().equals(bodyData.getMax_date())) {
        for (int i = 0; i < 7; i++) {
          LocalDate minusdate = lEndDate.minusDays(i);
          DayOfWeek dayOfWeek = minusdate.getDayOfWeek();
          //mod #10690 無期限で曜日パターン変更を一部の曜日を変更した際に最終週のみ変更が無かった曜日の治療予定が2重になる 20240531 ztc start
  //        if (destWeeks.contains(dayOfWeek.getValue())) {
          if (missingWeekList.contains(dayOfWeek.getValue())) {
          //mod #10690 無期限で曜日パターン変更を一部の曜日を変更した際に最終週のみ変更が無かった曜日の治療予定が2重になる 20240531 ztc end
            previous7Days.add(minusdate.format(formatter));
          }
        }
      }
      // mod #11966 【因島】実績を含む週の曜日パターン変更が不正 fang end
      List<String> missingDateList = new ArrayList<>();
      if (CollectionUtils.isNotEmpty(previous7Days) && CollectionUtils.isNotEmpty(processedOrdMain)) {
        Set<String> ordMainDates = new HashSet<>();
        //既存のupdate、save ordMainデータ
        for (OrdMain moveOrdMain : processedOrdMain) {
          ordMainDates.add(moveOrdMain.getTreatDate());
        }
        //締切日の7日前のデータが既存のデータにあるかどうか、存在しない場合はmissingDateListに格納
        for (String preDay : previous7Days) {
          if (!ordMainDates.contains(preDay)) {
            missingDateList.add(preDay);
          }
        }
      }
      PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(patId);
      PatMain patMain = patMainDao.selectById(patId);
      List<PatTreatmentPattern> patTreatmentPatternList = patTreatmentPatternDao.getDataByPatIdAndTreatWeek(facilityCd,patId);
      List<OrdMain> calDateList = new ArrayList<>();
      if(CollectionUtils.isNotEmpty(missingDateList)){
        try {
          //pattereatmentPatternによると、ordmainに欠落しているデータを補充
          calDateList = patTreatmentPatternService.createOrdMainListByUpdateWeek(facilityCd, patPersonalMain, patMain, patTreatmentPatternList, changeWeekList, missingDateList);

//          //del #10590 次患者更新関連全体見直し対応 朴 start
//          doCallNextPatOrdMainList.addAll(calDateList.stream().map(SerializationUtils::clone).collect(Collectors.toList()));
//          //del #10590 次患者更新関連全体見直し対応 朴 end

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
        ordMainSaveList.addAll(calDateList);
      }
      // add #10307 曜日パターン変更を行うと1年以降の治療予定が作成される 20240306 ztc end
      /* add by chamaojia 2023-03-20 [8101] 一括処理に変更 --start */
      if (!ordMainSaveList.isEmpty()) {
        // 一括保存ord _mainおよびその他のテーブル操作
        /* modify by chamaojia 2023-03-25 [6118] インタフェース呼び出しエントリ参照を追加するには、プライマリ・キーを生成する必要があります --start */
        addlist.addAll(insertList(ordMainSaveList, true));
        /* modify by chamaojia 2023-03-25 [6118] インタフェース呼び出しエントリ参照を追加するには、プライマリ・キーを生成する必要があります --end */

        //add #10590 次患者更新関連全体見直し対応 朴 start
        doCallNextPatOrdMainList.addAll(ordMainSaveList.stream().map(SerializationUtils::clone).collect(Collectors.toList()));
        //add #10590 次患者更新関連全体見直し対応 朴 end

      }
      /* add by chamaojia 2023-03-20 [8101] 一括処理に変更  --end */
      //upd by ztc 2023-03-24 曜日パターン変更月木→月水金日 bug --start /
//      this.batchDelete(dellist); // add by shiyw 2023-03-25 [#8101] 患者経過総合応答速度の最適化です
      //upd by ztc 2023-03-24 曜日パターン変更月木→月水金日 bug --end /
      if (bodyData.getCover()) {
        /* modify by shiyw 2023-03-21 [#8101] --start */
        if(!updateOrdNoList.isEmpty()){
          List<OrdMain> oldOrdMains = ordMainDao.selectAllByOrdNoList(updateOrdNoList);
          selectHistoryUtils.insertMangoDbHistoryBatchByOrdMainList(oldOrdMains);
          /* modify by chamaojia 2023-03-20 [8101] リスニング・ログを削除し、手動で実装する  --start */
          String tableNameOrdMainDao = "ord_main";
          // SQL検索条件
          StringBuffer wheresOrdMainDao = new StringBuffer("");
          wheresOrdMainDao.append(" WHERE ord_no in (" + getIntegerValueStr(updateOrdNoList) +") \n");
          // logCommon設定
          DataUpdateLogCommonNew logCommonOrdMainDao = getLogCommon(ordMainDao, tableNameOrdMainDao, wheresOrdMainDao, getEventLogMessage());
          // ログ出力カラム情報及び更新前データ情報取得
          boolean setResultOrdMainDao = logCommonOrdMainDao.setInfo();

  //        List<Long> updateOrdNos = updateOrdMainList.stream().map(OrdMain::getOrdNo).collect(Collectors.toList());
          ordMainDao.update(copyOrdMainEntity(updateOrdMainList));
  //        List<OrdMain> newOrdMains = ordMainDao.selectAllByOrdNoList(updateOrdNos);
          List<OrdMain> newOrdMains = updateOrdMainList;
          triggerUtil.updateTriggerOrdMain(oldOrdMains, newOrdMains);

          // #10196 MaterialSave add by Zhou.tao
        // mod #12250 ord_material_saveの処理を2回重複実行している zkm start
//        this.ordMaterialSaveService.batchProcessingDataMod(
//          asyncMaterialSaveHandlerTask.updateOrdMaterialSaveByDiff(
//            new OrdMaterialSaveBatchHandleDTO(
//              updateOrdMainList.stream().map(OrdMain::getOrdNo).toList(),
//              updateOrdMainList,
//              OrdMaterialSaveBatchHandleDTO.getBatchModifiedMode(
//                true, true, true, false, OrdMaterialSaveDto.IND_CLASS, false
//              )
//            )
//          )
//        );
        ordMaterialSaveService.bulkUpdateByOrdNoInCondMediEquip(updateOrdMainList.stream().map(OrdMain::getOrdNo).toList());
        // mod #12250 ord_material_saveの処理を2回重複実行している zkm end

          if (setResultOrdMainDao) {
            logCommonOrdMainDao.setAfterResults();
//            logCommonOrdMainDao.updateLog();
            asyncService.updateLog(logCommonOrdMainDao);
          }
          /* modify by chamaojia 2023-03-20 [8101] リスニング・ログを削除し、手動で実装する  --end */
        }
        /* modify by shiyw 2023-03-21 [#8101] --end */
      }
//      if(!bodyData.getSkip()) {
        dellist=dellist.stream().filter(item->item.getIndKurCd()!=0).distinct().collect(Collectors.toList());
        //mod 7068 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない 卓 start
//      asyncService.sendExternalConnection(dellist, journalCreateRequestPayload);
      for (OrdMain ordMain : dellist) {
        ordMain.setTreatDate(delOrdMainTreateDateMap.get(ordMain.getOrdNo()));
      }
      //del 10553 start
      // add FNSI-8546テストの横展開。前の処理で削除イベントが作成済み、念のため、重複作成させないのため、判断を追加。ljx start
//      if(dellistForJournal == null || dellistForJournal.size() == 0){
//        journalService.callCreateJournal(dellist, journalCreateRequestPayload,requestList);
//      }
      // add FNSI-8546テストの横展開。ljx end
      //del 10553 end

//      asyncService.requestApiJournalCreate(dellist, journalCreateRequestPayload);
        //mod 7068 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない 卓 end
//      }
      //add 7068 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない start
//    updatelist=updatelist.stream().filter(item->item.getIndKurCd()!=0).distinct().collect(Collectors.toList());
      // del #10553 start
//      addlist=addlist.stream().filter(item->item.getIndKurCd()!=0).distinct().collect(Collectors.toList());
      // del #10553 end
      // add #10553 start
      if(!addlist.isEmpty()){
        List<Long> addOrdNoList = addlist.stream().map(item -> item.getOrdNo()).distinct().collect(Collectors.toList());
        resultOrdMainChangedDataInfoList.addAll(this.selectByOrdNoList(addOrdNoList)); // 変更後データ退避
      }
      // add #10553 end
      // del #10553 start
      //9273 add
      //変更電文作成用のリストを作成。（新規電文の処理に参照）
//      ordMainMoveList=ordMainMoveList.stream().filter(item->item.getIndKurCd()!=0).distinct().collect(Collectors.toList());
      //9273 add
      // del #10553 end
//    JournalCreateRequestPayload updateJournalCreateRequestPayload = new JournalCreateRequestPayload();
//    BeanUtils.copyProperties(journalCreateRequestPayload,updateJournalCreateRequestPayload);
//    updateJournalCreateRequestPayload.setCrud("U");
      //mod 7068 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない 張 start
//    asyncService.sendExternalConnection(updatelist, updateJournalCreateRequestPayload);
//    if(bodyData.getSkip()) {
//      asyncService.sendExternalConnection(updatelist, updateJournalCreateRequestPayload);
//    }

      // del #10553 start
      //mod 7068 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない 張 end
//      JournalCreateRequestPayload addJournalCreateRequestPayload = new JournalCreateRequestPayload();
//      BeanUtils.copyProperties(journalCreateRequestPayload,addJournalCreateRequestPayload);
//      addJournalCreateRequestPayload.setCrud("C");
      //mod 7068 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない 張 start
//    asyncService.sendExternalConnection(addlist, addJournalCreateRequestPayload);
//      if(!bodyData.getSkip()) {
        //mod 7068 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない 卓 start
//      asyncService.sendExternalConnection(dellist, journalCreateRequestPayload);
//        journalService.callCreateJournal(addlist, addJournalCreateRequestPayload,requestList);
//      asyncService.requestApiJournalCreate(dellist, addJournalCreateRequestPayload);
        //mod 7068 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない 卓 end
//      }
      // del #10553 end

      //9273 add
      //U電文作成
      //mod 10553 start
//      JournalCreateRequestPayload updJournalCreateRequestPayload = new JournalCreateRequestPayload();
//      BeanUtils.copyProperties(journalCreateRequestPayload,updJournalCreateRequestPayload);
//      updJournalCreateRequestPayload.setCrud("U");
      if(ordMainMoveList.size() > 0 && !oldOrdMainMap.isEmpty()){

//        List<OrdMain> dateChangeDOrdMainList = new ArrayList<>();
//        List<OrdMain> dateChangeCOrdMainList = new ArrayList<>();

        for(OrdMain afterMoveOrd : ordMainMoveList){
          Long ordNo = afterMoveOrd.getOrdNo();
          String treatDate = afterMoveOrd.getTreatDate();
          OrdMain beforeOrd = oldOrdMainMap.get(ordNo);
          if(beforeOrd != null && Objects.equals(ordNo, beforeOrd.getOrdNo())){
            if(!Objects.equals(treatDate, beforeOrd.getTreatDate())){
//              dateChangeDOrdMainList.add(beforeOrd);
//              dateChangeCOrdMainList.add(afterMoveOrd);
              resultOrdMainChangeBeforeDataInfoList.add(beforeOrd);
              resultOrdMainChangedDataInfoList.add(afterMoveOrd);
            }
          }
        }

//        JournalCreateRequestPayload cJournalCreateRequestPayload = new JournalCreateRequestPayload();
//        BeanUtils.copyProperties(journalCreateRequestPayload,cJournalCreateRequestPayload);
//        cJournalCreateRequestPayload.setCrud("C");
//        journalService.callCreateJournal(dateChangeCOrdMainList, cJournalCreateRequestPayload,requestList);
//
//        JournalCreateRequestPayload dJournalCreateRequestPayload = new JournalCreateRequestPayload();
//        BeanUtils.copyProperties(journalCreateRequestPayload,dJournalCreateRequestPayload);
//        dJournalCreateRequestPayload.setCrud("D");
//        journalService.callCreateJournal(dateChangeDOrdMainList, dJournalCreateRequestPayload,requestList);

      }
      //mod 10553 end
      //9273 add
      //mod 7068 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない 張 end
      //add 7068 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない end
      // 指示受け・承認画面のチェック状態を未チェックにする
      /* modify by shiyw 2023-03-21 [#8101] --start */
//      patIndApproveDao.updateContentChangeList(ordMainList.stream().map(item -> item.getOrdNo()).distinct().collect(Collectors.toList()), new PatIndApprove());
      patIndApproveDao.updateContentChangeList(updateOrdNoList, new PatIndApprove());
      /* modify by shiyw 2023-03-21 [#8101] --end */
      // 曜日パターンの更新 (終了日が未指定の場合のみ更新処理を実施)
      // add 10284 by kangjie 20240301 start
//      if (StringUtils.isEmpty(endDate)) {
      if (!bodyData.getIs_deadline()) {
      // add 10284 by kangjie 20240301 end
        // パラメータ用治療方法リスト
        List<Integer> treatmentCdList = new ArrayList<Integer>();
        treatmentCdList.add(treatmentCd);
        List<PatTreatmentPattern> listRet = new ArrayList<PatTreatmentPattern>();
        try {
          // 対象患者パターンを検索
          listRet = patTreatmentPatternUtils.searchPatTreatmentPattern(
            patId,
            facilityCd,
            treatmentCdList,
            new ArrayList<Long>(), // クールリスト
            srcWeek
          );
        } catch (Exception e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
        EventLogMessage eventLogMessage = new EventLogMessage();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
        if (!StringUtils.isEmpty(facilityCd)) {
          eventLogMessage.setFacilityCd(facilityCd);
        }
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
          logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
        }

        // 曜日パターン変更用データ
        List<PatTreatmentPatternUtils.PatTreatmentPatternEditDataWeekList> editDataWeekList = new ArrayList<PatTreatmentPatternUtils.PatTreatmentPatternEditDataWeekList>();
        // 曜日パターン分繰り返す
        for (int i = 0; i < listRet.size(); i++) {
          // 患者治療パターン編集データ
          PatTreatmentPatternUtils.PatTreatmentPatternEditData editData = new PatTreatmentPatternUtils.PatTreatmentPatternEditData();
          // スケジュール情報
          JSONObject schObj = new JSONObject(listRet.get(i).getIndSchInfo());
          schObj.put("ind_user_id", Integer.parseInt(bodyData.getInd_user()));
          schObj.put("upd_user_id", Integer.parseInt(bodyData.getUpd_user()));
          String indSchInfo = schObj.toString();
          // 装置設定情報
          String indDeviceSetInfo = listRet.get(i).getIndDeviceSetInfo();
          // 患者治療パターン情報を格納
          try {
            // 治療種別
            editData.setTreatType(listRet.get(i).getTreatType());
            editData.setIndTreatStartDate(indTreatStartDate);
            editData.setIndTreatmentCd(treatmentCd);
            // クールは未登録にしない為、持ち越す
            editData.setIndKurCd(listRet.get(i).getIndKurCd());
            editData.setIndSchInfo(indSchInfo);
            // 治療条件情報
            editData.setIndCondInfo(listRet.get(i).getIndCondInfo());
            // 薬剤はそのまま持ち越す
            editData.setIndMediInfo(listRet.get(i).getIndMediInfo());
            // 医療材料情報
            editData.setIndEquipInfo(listRet.get(i).getIndEquipInfo());
            // 指示コメント情報
            editData.setIndIndCommentInfo(listRet.get(i).getIndIndCommentInfo());
            // 風袋情報
            editData.setIndTareInfo(listRet.get(i).getIndTareInfo());
            // 除水補正情報
            editData.setIndOffWaterInfo(listRet.get(i).getIndOffWaterInfo());
            // Redmine#692対応前に作成された患者治療パターンの指示：装置設定のJSONは"ord"キーが存在していた為、
            // 該当レコード取得時に"ord"キーが存在する場合、"ord"キーを削除した形式に変更する
            // {"ord":{"dc":...}}
            // ↓ （以下のような形式に整形する）
            // {dc":...}
            JSONObject deviceSetInfo = new JSONObject(indDeviceSetInfo);
            if (deviceSetInfo.has("ord")) {
              // "ord"キーが存在する場合、キーに対応する値を設定する
              indDeviceSetInfo = deviceSetInfo.getJSONObject("ord").toString();
            } else {
              indDeviceSetInfo = deviceSetInfo.toString();
            }
            editData.setIndDeviceSetInfo(indDeviceSetInfo);
          } catch (Exception e) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          EventLogMessage eventLogMessage = new EventLogMessage();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          if (!StringUtils.isEmpty(facilityCd)) {
            eventLogMessage.setFacilityCd(facilityCd);
          }
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
            logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
          }

          // 編集対象曜日
          List<Integer> weekPattern = new ArrayList<Integer>();
          // 参照元の曜日を取得
          for (int j = 0; j < weekPatternInfo.length(); j++) {
            JSONObject obj = weekPatternInfo.getJSONObject(j);
            if ((int) listRet.get(i).getTreatWeek() == obj.getInt("fromWeek")) {
              weekPattern.add(obj.getInt("value"));
            }
          }
          // 患者治療パターン編集情報
          PatTreatmentPatternUtils.PatTreatmentPatternEditDataWeekList patternInfo = new PatTreatmentPatternUtils.PatTreatmentPatternEditDataWeekList();
          try {
            patternInfo.setEditData(editData);
            // 月曜日から順に処理する為、ソートしてからセットする
            Collections.sort(weekPattern);
            patternInfo.setWeekPattern(weekPattern);
          } catch (Exception e) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          EventLogMessage eventLogMessage = new EventLogMessage();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          if (!StringUtils.isEmpty(facilityCd)) {
            eventLogMessage.setFacilityCd(facilityCd);
          }
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
          logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
          }
          // 患者パターン情報を格納
          editDataWeekList.add(patternInfo);
        }
        if (editDataWeekList.size() > 0) {
          // 患者治療パターンの更新
          patTreatmentPatternUtils.deleteAndCreatePatTreatmentPattern(
            patId,
            facilityCd,
            treatmentCdList,
            new ArrayList<Long>(),
            new ArrayList<Integer>(),
            bodyUpdate,
            editDataWeekList
          );
          // add 11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) start
          patTreatmentPatternDao.updatePatTreatmentPatternBedCdZeroForWeekChange(facilityCd, patId, footerFlg,new ArrayList<Integer>(),treatmentCdList,new ArrayList<Long>());
          // add 11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) end
          // add 11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) zkm start
          // 更新範囲内、同一クール・ベッド治療を取得する
          List<OrdScheduleNewKurPreview> ordScheduleList = ordScheduleDao.selectDummyScheduleInPatId(bodyData.getFacility_cd(), Long.parseLong(bodyData.getPat_id()), destWeeks, treatmentCdList, new ArrayList<>());
          List<Long> lowPriorityCtlNoList = ordMainSchChangeUtils.searchLowPriorityNoList(bodyData.getFacility_cd(), ordScheduleList);
          if (!lowPriorityCtlNoList.isEmpty()) {
            patTreatmentPatternDao.updatePatTreatmentPatternBedCdZeroByCtlNoList(bodyData.getFacility_cd(), Long.parseLong(bodyData.getPat_id()), lowPriorityCtlNoList);
          }
          //add 11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) zkm end
        }
      }
      // 検査依頼結果の移動及び削除処理
      // 施設設定マスタから 透析予定日変更時検査予定変更機能 の設定値を取得
      //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy start
//      String resExamChangeSetting = facilitySettingService.getFacilitySettingValue(
//        bodyData.getFacility_cd(),
//        CoreConstant.FacilitySettingNo.EXAM_SCHEDULE_CHANGE
//      );
      String resExamChangeSetting = bodyData.getFacilitySettingExamValue();
      // 施設設定マスタから 透析予定日変更時放射線検査予定変更機能 の設定値を取得
//      String resRadChangeSetting = facilitySettingService.getFacilitySettingValue(
//        bodyData.getFacility_cd(),
//        CoreConstant.FacilitySettingNo.RAD_SCHEDULE_CHANGE
//      );
      String resRadChangeSetting = bodyData.getFacilitySettingRadValue();
      //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy end
      // add #9273 施設設定マスタのNo105の設定どおり動かない。  start
      // 施設設定マスタから 透析予定日変更時患者イベント予定変更機能 の設定値を取得
//      String eventChangeSetting = facilitySettingService.getFacilitySettingValue(
//        bodyData.getFacility_cd(),
//        CoreConstant.FacilitySettingNo.PAT_EVENT_CHANGE
//      );
      String eventChangeSetting = bodyData.getFacilitySettingEventValue();
      // add #9273 施設設定マスタのNo105の設定どおり動かない。  end

      //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy start
//      List<PatExamMain> patExamMains = patExamMainDao.selectExistResultByPatId(patId, bodyData.getInd_treat_start_date());
      List<PatExamMain> patExamMains = examRequestService.FindPatExamMainByIsOrder(Integer.parseInt(bodyData.getPat_id()), indTreatStartDate, endDate);
      List<PatRadMain> patRadMains = radRequestService.FindPatRadMainByIsOrder(Integer.parseInt(bodyData.getPat_id()), indTreatStartDate, endDate);
      // add #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy start
      List<PatExamMain> allPatExamMains = new ArrayList<>(patExamMains);
      List<PatRadMain> allPatRadMains = new ArrayList<>(patRadMains);
      // add #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy end

      patExamMains = patExamMains.stream().filter(exam->{
      Calendar cal = Calendar.getInstance();
      cal.setTime(exam.getRegExamDate());
      //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy start
      // int week_index = cal.get(Calendar.DAY_OF_WEEK)-1;
      int week_index = cal.get(Calendar.DAY_OF_WEEK)-1 != 0 ? cal.get(Calendar.DAY_OF_WEEK)-1 : 7;
      //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy end
      if (moveWeek.contains(week_index)){
        return  true;
      }else{
        return false;
      }
      }).collect(Collectors.toList());
      patRadMains = patRadMains.stream().filter(exam->{
      Calendar cal = Calendar.getInstance();
      cal.setTime(exam.getRegRadDate());
      //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy start
      // int week_index = cal.get(Calendar.DAY_OF_WEEK)-1;
      int week_index = cal.get(Calendar.DAY_OF_WEEK)-1 != 0 ? cal.get(Calendar.DAY_OF_WEEK)-1 : 7;
      //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy end
      if (moveWeek.contains(week_index)){
        return  true;
      }else{
        return false;
      }
      }).collect(Collectors.toList());
      //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy end
      // 施設設定により処理分岐(検体検査)
      String strPatId = String.valueOf(patId);
      switch (resExamChangeSetting) {
        case "1":
          // 変更された透析予定の日付に検体検査の日付を変更
          try {
            // mod 10125 検査予定に関する連携イベント作成不備 関  start
            List<PatExamMain> patExamMainDelList = new ArrayList<>();
            List<IndScheduleInfo> indInfoDelList = new ArrayList<>();
            if (connectedOrdMainExamMainCdDelList.size() > 0) {
              Map<Long, List<OrdNoAndConnectedTableKeyData>> connectedPatExamMainMap = connectedOrdMainExamMainCdDelList.stream().collect(Collectors.groupingBy(OrdNoAndConnectedTableKeyData::getOrdNo, Collectors.toList()));
              for (String key : deleteDateList) {
                if (!this.checkExamResult(allPatExamMains, key)) {
                  continue;
                }
                List<OrdMain> ordMains = ordMainDelList.stream().filter(x -> key.replaceAll("/", "").equals(x.getTreatDate())).collect(Collectors.toList());

                IndScheduleInfo indScheduleInfo = new IndScheduleInfo();

                ordMains.forEach(i->{
                  List<OrdNoAndConnectedTableKeyData> delPatEventListForOrdNo = connectedPatExamMainMap.getOrDefault(i.getOrdNo(), Collections.emptyList());
                  indScheduleInfo.setFacilityCd(facilityCd);
                  indScheduleInfo.setConnectedExamMainCdList(delPatEventListForOrdNo.stream().map(o -> o.getKey()).collect(Collectors.toList()));
                  indScheduleInfo.setTreatDate(key.replaceAll("/", ""));
                  indInfoDelList.add(indScheduleInfo);
                });
              }
            }
            if (indInfoDelList.size() > 0) {
              patExamMainDelList = indScheduleDao.deletePatExamMainToHistoryByIndSchdueInfoList(facilityCd, indInfoDelList);
              for (PatExamMain patExamMain : patExamMainDelList) {
                patExamMain.setIsDel("1"); // リストに追加する前にdelフラグを立てる
              }
              resultPatExamMainChangedDataInfoList.addAll(patExamMainDelList);
            }
            // mod 10618 検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する 関  start
            Map<Long, List<Long>> connectedOrdMainExamMainCdListMap = connectedOrdMainExamMainCdList.stream().collect(Collectors.groupingBy(OrdNoAndConnectedTableKeyData::getOrdNo, Collectors.mapping(OrdNoAndConnectedTableKeyData::getKey, Collectors.toList())));
            List<IndScheduleInfo> indScheduleInfoList = new ArrayList<>();
            // mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 関  start
//            List<PatExamMain> patExamMainListAfter = new ArrayList<>();
//            List<PatExamMain> patExamMainListBeforeMove = new ArrayList<>();
//            List<JournalCreateRequestPayload> examJournalList = new ArrayList<>();
            List<PatExamMain> patExamMainList = new ArrayList<>();
            List<PatExamMain> patExamMainListBefore = new ArrayList<>();
            // add 10553 連携イベント発生部分不正 関 start
//            SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
            // add 10553 連携イベント発生部分不正 関 end

            for (String key : moveDateMap.keySet()) {
              if (moveDateMap.get(key).equals(key)) {
                continue;
              }
              List<OrdMainEsListener> ordMains = ordMainListForEvent.stream().filter(x -> key.replaceAll("/", "").equals(x.getTreatDate())).collect(Collectors.toList());
              ordMains.forEach(i -> {
                IndScheduleInfo indScheduleInfo = new IndScheduleInfo();

                indScheduleInfo.setPatId(patId);
                indScheduleInfo.setFacilityCd(facilityCd);
                indScheduleInfo.setTreatDate(moveDateMap.get(key).replaceAll("/", ""));
                indScheduleInfo.setOldTreatDate( key.replaceAll("/", ""));
                indScheduleInfo.setConnectedExamMainCdList(connectedOrdMainExamMainCdListMap.getOrDefault(i.getOrdNo(), Collections.emptyList()));
                indScheduleInfoList.add(indScheduleInfo);
              });
            }
            if (indScheduleInfoList.size() > 0) {
              // 既存マージ分
              patExamMainListBefore = indScheduleDao.selectForUpdatePatExamMainByIndSchdueInfoList(facilityCd, indScheduleInfoList);
              resultPatExamMainChangeBeforeDataInfoList.addAll(patExamMainListBefore);

              //mod #10920 検査予定が透析予定の変更に追従する設定でもイベントが発生しない add
//              patExamMainList = indScheduleDao.updatePatExamMainByIndSchdueInfoList(facilityCd, indScheduleInfoList);
              List<PatExamMain> patExamMainUList = indScheduleDao.updatePatExamMainByIndSchdueInfoList(facilityCd, indScheduleInfoList);
//              resultPatExamMainChangedDataInfoList.addAll(patExamMainList);

                // 新規作成分 ※変更前データは退避しない
//              patExamMainList = indScheduleDao.insertPatExamMainByIndSchdueInfoList(facilityCd, indScheduleInfoList);
              List<PatExamMain> patExamMainCList = indScheduleDao.insertPatExamMainByIndSchdueInfoList(facilityCd, indScheduleInfoList);
//              resultPatExamMainChangedDataInfoList.addAll(patExamMainList);

              // 削除・hst退避分 ※変更前データは退避しない
//              patExamMainList = indScheduleDao.deletePatExamMainToHistoryByIndSchdueInfoList(facilityCd, indScheduleInfoList);
              List<PatExamMain> patExamMainDList = indScheduleDao.deletePatExamMainToHistoryByIndSchdueInfoList(facilityCd, indScheduleInfoList);
              for (PatExamMain patExamMain : patExamMainDList) {
                patExamMain.setIsDel("1"); // リストに追加する前にdelフラグを立てる
              }
//              resultPatExamMainChangedDataInfoList.addAll(patExamMainList);
              //mod #10920 検査予定が透析予定の変更に追従する設定でもイベントが発生しない end
              //add #10920 検査予定が透析予定の変更に追従する設定でもイベントが発生しない start
              resultPatExamMainChangedDataInfoList.addAll(patExamMainDList);
              resultPatExamMainChangedDataInfoList.addAll(patExamMainCList);
              resultPatExamMainChangedDataInfoList.addAll(patExamMainUList);
              //add #10920 検査予定が透析予定の変更に追従する設定でもイベントが発生しない end
            }
            // mod 10553 連携イベント発生部分不正 関 start
//            PatPersonalMain patSrc = patPersonalMainDao.selectById(patId);
//            if (patExamMainListBeforeMove.size() > 0) {
//              patExamMainListBeforeMove.forEach(item ->{
//                  JournalCreateRequestPayload journalParameter = new JournalCreateRequestPayload();
//                  if (item.getPhyOrdClass() != null && "1".equals(item.getPhyOrdClass() )) {
//                    journalParameter.setCoopCd("phy_ord");
//                    journalParameter.setOpeCd("004040");
//                  } else {
//                    journalParameter.setCoopCd("exam_ord");
//                    journalParameter.setOpeCd("004039");
//                  }
//                  journalParameter.setAnaResult("0");
//                  journalParameter.setCoopCdIndex("");
//                  journalParameter.setCoopResult("0");
//                  journalParameter.setCrud("D");
//                  journalParameter.setDirection("S");
//                  journalParameter.setFacilityCd(facilityCd);
//                  journalParameter.setOrdNo(item.getExamMainCd());
//                  journalParameter.setPatId(Long.parseLong(strPatId));
//                  journalParameter.setUserId(item.getIndUserId());
//                  journalParameter.setBaseDate(sdf.format(item.getRegExamDate()));
//                  if (patSrc != null) {
//                    journalParameter.setHospPatId(patSrc.getHosp_pat_id());
//                  }
//                // mod 10553 連携イベント発生部分不正 関 end
//                examJournalList.add(journalParameter);
//                }
//              );
//            }
//
//            if (patExamMainListAfter.size() > 0 ) {
//              patExamMainListAfter.forEach(item ->{
//                  JournalCreateRequestPayload journalParameter = new JournalCreateRequestPayload();
//                  if (item.getPhyOrdClass() != null && "1".equals(item.getPhyOrdClass() )) {
//                    journalParameter.setCoopCd("phy_ord");
//                    // mod 10553 連携イベント発生部分不正 関 start
//                    journalParameter.setOpeCd("004040");
//                  } else {
//                    journalParameter.setCoopCd("exam_ord");
//                    journalParameter.setOpeCd("004039");
//                  }
//                  journalParameter.setAnaResult("0");
//                  journalParameter.setCoopCdIndex("");
//                  journalParameter.setCoopResult("0");
//                  journalParameter.setCrud("U");
//                  journalParameter.setDirection("S");
//                  journalParameter.setFacilityCd(facilityCd);
//                  journalParameter.setOrdNo(item.getExamMainCd());
//                  journalParameter.setPatId(Long.parseLong(strPatId));
//                  journalParameter.setUserId(item.getIndUserId());
//                  journalParameter.setBaseDate(sdf.format(item.getRegExamDate()));
//                  if (patSrc != null) {
//                    journalParameter.setHospPatId(patSrc.getHosp_pat_id());
//                  }
//                  // mod 10553 連携イベント発生部分不正 関 end
//                  examJournalList.add(journalParameter);
//                }
//              );
//            }
//            if (patExamMainList.size() > 0) {
//              patExamMainList.forEach(item ->{
//                JournalCreateRequestPayload journalParameter = new JournalCreateRequestPayload();
//                if (item.getPhyOrdClass() != null && "1".equals(item.getPhyOrdClass() )) {
//                  journalParameter.setCoopCd("phy_ord");
//                  // mod 10553 連携イベント発生部分不正 関 start
//                  journalParameter.setOpeCd("004040");
//                } else {
//                  journalParameter.setCoopCd("exam_ord");
//                  journalParameter.setOpeCd("004039");
//                }
//                journalParameter.setAnaResult("0");
//                journalParameter.setCoopCdIndex("");
//                journalParameter.setCoopResult("0");
//                journalParameter.setCrud("C");
//                journalParameter.setDirection("S");
//                journalParameter.setFacilityCd(facilityCd);
//                journalParameter.setOrdNo(item.getExamMainCd());
//                journalParameter.setPatId(Long.parseLong(strPatId));
//                journalParameter.setUserId(item.getIndUserId());
//                journalParameter.setBaseDate(sdf.format(item.getRegExamDate()));
//                if (patSrc != null) {
//                  journalParameter.setHospPatId(patSrc.getHosp_pat_id());
//                }
//                // mod 10553 連携イベント発生部分不正 関 end
//                examJournalList.add(journalParameter);
//              });
//            }
//            if (!CollectionUtils.isEmpty(examJournalList)){
//              journalService.callCreateJournalForCtrNo(examJournalList);
//            }
            // mod 10125 検査予定に関する連携イベント作成不備 関  end
            // mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 関  end
            // mod 10618 検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する 関  end
          } catch (Exception e) {
            //エラー
            EventLogMessage eventLogMessage = new EventLogMessage();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          if (bodyData != null && bodyData.getFacility_cd() != null) {
            eventLogMessage.setFacilityCd(bodyData.getFacility_cd());
          }
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
          logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
            // mod FNSI-検体検査の表示の修正 楊 start
            // return new ResponseEntity<>("検体検査の日付更新に失敗しました。", null, HttpStatus.INTERNAL_SERVER_ERROR);
            OrdMainWeekPatternResponse response = new OrdMainWeekPatternResponse();
            response.setBody("検査予定の日付更新に失敗しました。");
            response.setHeaders(null);
            response.setStatus(HttpStatus.INTERNAL_SERVER_ERROR);
            return response;
            // mod FNSI-検体検査の表示の修正 楊 end
          }
          break;
        case "2":
          // 透析予定日が変更/中止された場合、検体検査をキャンセル
          try {
            // mod 10125 検査予定に関する連携イベント作成不備 関  start
            List<PatExamMain> patExamMainDelList = new ArrayList<>();
            List<IndScheduleInfo> indInfoDelList = new ArrayList<>();
            List<IndScheduleInfo> indInfoToDelList = new ArrayList<>();

            if (connectedOrdMainExamMainCdList.size() > 0) {
              Map<Long, List<OrdNoAndConnectedTableKeyData>> connectedPatExamMainMap = connectedOrdMainExamMainCdList.stream().collect(Collectors.groupingBy(OrdNoAndConnectedTableKeyData::getOrdNo, Collectors.toList()));
              for (String key : moveDateMap.keySet()) {
                if (moveDateMap.get(key).equals(key)) {
                  continue;
                }
                List<OrdMainEsListener> ordMains = ordMainListForEvent.stream().filter(x -> key.replaceAll("/", "").equals(x.getTreatDate())).collect(Collectors.toList());

                IndScheduleInfo indScheduleInfo = new IndScheduleInfo();
                ordMains.forEach(i->{
                  List<OrdNoAndConnectedTableKeyData> delPatEventListForOrdNo = connectedPatExamMainMap.getOrDefault(i.getOrdNo(), Collections.emptyList());
                  indScheduleInfo.setFacilityCd(facilityCd);
                  indScheduleInfo.setConnectedExamMainCdList(delPatEventListForOrdNo.stream().map(o -> o.getKey()).collect(Collectors.toList()));
                  indScheduleInfo.setTreatDate(moveDateMap.get(key).replaceAll("/", ""));
                  indInfoDelList.add(indScheduleInfo);
                });
              }
            }
            if (indInfoDelList.size() > 0) {
              patExamMainDelList = indScheduleDao.deletePatExamMainToHistoryByIndSchdueInfoList(facilityCd, indInfoDelList);
              for (PatExamMain patExamMain : patExamMainDelList) {
                patExamMain.setIsDel("1"); // リストに追加する前にdelフラグを立てる
              }
              resultPatExamMainChangedDataInfoList.addAll(patExamMainDelList);
            }

            if (connectedOrdMainExamMainCdDelList.size() > 0) {
              Map<Long, List<OrdNoAndConnectedTableKeyData>> connectedPatExamMainMap = connectedOrdMainExamMainCdDelList.stream().collect(Collectors.groupingBy(OrdNoAndConnectedTableKeyData::getOrdNo, Collectors.toList()));
              for (String key : deleteDateList) {
                if (!this.checkExamResult(allPatExamMains, key)) {
                  continue;
                }
                List<OrdMain> ordMains = ordMainDelList.stream().filter(x -> key.replaceAll("/", "").equals(x.getTreatDate())).collect(Collectors.toList());

                IndScheduleInfo indScheduleInfo = new IndScheduleInfo();
                ordMains.forEach(i->{
                  List<OrdNoAndConnectedTableKeyData> delPatEventListForOrdNo = connectedPatExamMainMap.getOrDefault(i.getOrdNo(), Collections.emptyList());
                  indScheduleInfo.setFacilityCd(facilityCd);
                  indScheduleInfo.setConnectedExamMainCdList(delPatEventListForOrdNo.stream().map(o -> o.getKey()).collect(Collectors.toList()));
                  indScheduleInfo.setTreatDate(key.replaceAll("/", ""));
                  indInfoToDelList.add(indScheduleInfo);
                });
              }
            }
            if (indInfoToDelList.size() > 0) {
              patExamMainDelList = indScheduleDao.deletePatExamMainToHistoryByIndSchdueInfoList(facilityCd, indInfoToDelList);
              for (PatExamMain patExamMain : patExamMainDelList) {
                patExamMain.setIsDel("1"); // リストに追加する前にdelフラグを立てる
              }
              resultPatExamMainChangedDataInfoList.addAll(patExamMainDelList);
            }
            // mod 10125 検査予定に関する連携イベント作成不備 関  end
          } catch (Exception e) {
            //エラー
            EventLogMessage eventLogMessage = new EventLogMessage();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          if (bodyData != null && bodyData.getFacility_cd() != null) {
            eventLogMessage.setFacilityCd(bodyData.getFacility_cd());
          }
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
          logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
            // mod FNSI-検体検査の表示の修正 楊 start
            // return new ResponseEntity<>("検体検査のキャンセルに失敗しました。", null, HttpStatus.INTERNAL_SERVER_ERROR);
            OrdMainWeekPatternResponse response = new OrdMainWeekPatternResponse();
            response.setBody("検査予定のキャンセルに失敗しました。");
            response.setHeaders(null);
            response.setStatus(HttpStatus.INTERNAL_SERVER_ERROR);
            return response;
            // mod FNSI-検体検査の表示の修正 楊 end

          }
          break;
        case "3":
          // 検体検査への処理は行わない
          break;
        default:
          break;
      }
      // 施設設定により処理分岐(放射線検査)
      switch (resRadChangeSetting) {
        case "1":
          // 変更された透析予定の日付に放射線検査の日付を変更
          try {
            // mod 10125 検査予定に関する連携イベント作成不備 関  start
            List<PatRadMain> patRadMainDelList = new ArrayList<>();
            List<IndScheduleInfo> indInfoDelList = new ArrayList<>();
            if (connectedOrdMainRadResultCdDelList.size() > 0) {
              Map<Long, List<OrdNoAndConnectedTableKeyData>> connectedOrdMainRadCdListMap = connectedOrdMainRadResultCdDelList.stream().collect(Collectors.groupingBy(OrdNoAndConnectedTableKeyData::getOrdNo, Collectors.toList()));
              for (String key : deleteDateList) {
                if (!this.checkRadResult(allPatRadMains, key)) {
                  continue;
                }
                List<OrdMain> ordMains = ordMainDelList.stream().filter(x -> key.replaceAll("/", "").equals(x.getTreatDate())).collect(Collectors.toList());

                IndScheduleInfo indScheduleInfo = new IndScheduleInfo();
                ordMains.forEach(i->{
                  List<OrdNoAndConnectedTableKeyData> delPatRadMainListForOrdNo = connectedOrdMainRadCdListMap.getOrDefault(i.getOrdNo(), Collections.emptyList());
                  indScheduleInfo.setFacilityCd(facilityCd);
                  indScheduleInfo.setConnectedRadResultCdList(delPatRadMainListForOrdNo.stream().map(o -> o.getKey()).collect(Collectors.toList()));
                  indScheduleInfo.setTreatDate(key.replaceAll("/", ""));
                  indInfoDelList.add(indScheduleInfo);
                });
              }
            }
            if (indInfoDelList.size() > 0) {
              patRadMainDelList = indScheduleDao.deletePatRadMainToHistoryByIndSchdueInfoList(facilityCd, indInfoDelList);
              for (PatRadMain patRadMain : patRadMainDelList) {
                patRadMain.setIsDel("1"); // リストに追加する前にdelフラグを立てる
              }
              resultPatRadMainChangedDataInfoList.addAll(patRadMainDelList);
            }
            //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy end
            // mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 関  start
//            for (String key : moveDateMap.keySet()) {
//              // add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 関  start
//              if (moveDateMap.get(key).equals(key)) {
//                continue;
//              }
//              // add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 関  end
//              // add #9273 施設設定マスタのNo105の設定どおり動かない。 start
//              //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy start
//              // if (this.checkExamResult(patExamMains, key)) {
//              if (!this.checkRadResult(patRadMains, key)) {
//                //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy end
//                continue;
//              }
//              //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy start
//              SimpleDateFormat sdf = new SimpleDateFormat("yyyy/MM/dd");
//              List<PatRadMain> patRadMainList = patRadMains.stream().filter(x -> key.equals(sdf.format(x.getRegRadDate()))).collect(Collectors.toList());
//              // add #9273 施設設定マスタのNo105の設定どおり動かない。 end
//              // パラメータ作成
//                if (patRadMainList != null) {
//                  patRadMainList.forEach(item-> {
//                    Map<String, String> paramsMoveInfo = new HashMap<String, String>();
//                    paramsMoveInfo.put("patId", strPatId);
//                    paramsMoveInfo.put("beforeDate", key);
//                    paramsMoveInfo.put("afterDate", moveDateMap.get(key));
//                    paramsMoveInfo.put("radResultCd", item.getRadResultCd().toString());
//                    // 放射線検査依頼の日付を変更
//                    try {
//                      radRequestService.updateRegRadDateByRadResultCd(paramsMoveInfo);
//                    } catch (Exception e) {
//                      e.printStackTrace();
//                    }
//                  });
//                }
//              //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy end
//            }
            Map<Long, List<Long>> connectedOrdMainRadResultCdListMap = connectedOrdMainRadResultCdList.stream().collect(Collectors.groupingBy(OrdNoAndConnectedTableKeyData::getOrdNo, Collectors.mapping(OrdNoAndConnectedTableKeyData::getKey, Collectors.toList())));
            List<IndScheduleInfo> indScheduleInfoList = new ArrayList<>();
            //del #10920 検査予定が透析予定の変更に追従する設定でもイベントが発生しない start
//            List<IndScheduleInfo> indScheduleInfoDelList = new ArrayList<>();
//            List<PatRadMain> patRadMainListDel = new ArrayList<>();
//            List<PatRadMain> patRadMainList = new ArrayList<>();
//            List<JournalCreateRequestPayload> radCdJournalList = new ArrayList<>();
            //del #10920 検査予定が透析予定の変更に追従する設定でもイベントが発生しない end

            for (String key : moveDateMap.keySet()) {
              if (moveDateMap.get(key).equals(key)) {
                continue;
              }
              List<OrdMainEsListener> ordMains = ordMainListForEvent.stream().filter(x -> key.replaceAll("/", "").equals(x.getTreatDate())).collect(Collectors.toList());
              ordMains.forEach(i -> {
                IndScheduleInfo indScheduleInfo = new IndScheduleInfo();

                indScheduleInfo.setPatId(patId);
                indScheduleInfo.setFacilityCd(facilityCd);
                indScheduleInfo.setTreatDate(moveDateMap.get(key).replaceAll("/", ""));
                indScheduleInfo.setOldTreatDate( key.replaceAll("/", ""));
                indScheduleInfo.setConnectedRadResultCdList(connectedOrdMainRadResultCdListMap.getOrDefault(i.getOrdNo(), Collections.emptyList()));
                indScheduleInfoList.add(indScheduleInfo);
              });
            }
            if (indScheduleInfoList.size() > 0) {

              //mod #10920 検査予定が透析予定の変更に追従する設定でもイベントが発生しない start
//              patRadMainList = indScheduleDao.insertPatRadMainByIndSchdueInfoList(facilityCd, indScheduleInfoList);
              List<PatRadMain> patRadMainCList = indScheduleDao.insertPatRadMainByIndSchdueInfoList(facilityCd, indScheduleInfoList);
//              resultPatRadMainChangedDataInfoList.addAll(patRadMainList);
              //mod #10920 検査予定が透析予定の変更に追従する設定でもイベントが発生しない end

              // 削除・hst退避分 ※変更前データは退避しない
//              patRadMainListDel = indScheduleDao.deletePatRadMainToHistoryByIndSchdueInfoList(facilityCd, indScheduleInfoList);
              List<PatRadMain> patRadMainDList = indScheduleDao.deletePatRadMainToHistoryByIndSchdueInfoList(facilityCd, indScheduleInfoList);
              for (PatRadMain patRadMain : patRadMainDList) {
                patRadMain.setIsDel("1"); // リストに追加する前にdelフラグを立てる
              }
//              resultPatRadMainChangedDataInfoList.addAll(patRadMainListDel);
              //add #10920 検査予定が透析予定の変更に追従する設定でもイベントが発生しない start
              resultPatRadMainChangedDataInfoList.addAll(patRadMainDList);
              resultPatRadMainChangedDataInfoList.addAll(patRadMainCList);
              //add #10920 検査予定が透析予定の変更に追従する設定でもイベントが発生しない end
            }
            // mod 10125 検査予定に関する連携イベント作成不備 関  end
            // mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 関  end
          } catch (Exception e) {
            //エラー
            EventLogMessage eventLogMessage = new EventLogMessage();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          if (bodyData != null && bodyData.getFacility_cd() != null) {
            eventLogMessage.setFacilityCd(bodyData.getFacility_cd());
          }
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
            logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
            OrdMainWeekPatternResponse response = new OrdMainWeekPatternResponse();
            response.setBody("放射線検査の日付更新に失敗しました。");
            response.setHeaders(null);
            response.setStatus(HttpStatus.INTERNAL_SERVER_ERROR);
            return response;
          }
          break;
        case "2":
          // 透析予定日が変更/中止された場合、放射線検査をキャンセル
          try {
            // mod 10125 検査予定に関する連携イベント作成不備 関  start
            List<PatRadMain> patRadMainDelList = new ArrayList<>();
            List<IndScheduleInfo> indInfoDelList = new ArrayList<>();
            if (connectedOrdMainRadResultCdDelList.size() > 0) {
              Map<Long, List<OrdNoAndConnectedTableKeyData>> connectedOrdMainRadCdListMap = connectedOrdMainRadResultCdDelList.stream().collect(Collectors.groupingBy(OrdNoAndConnectedTableKeyData::getOrdNo, Collectors.toList()));
              for (String key : deleteDateList) {
                if (!this.checkRadResult(allPatRadMains, key)) {
                  continue;
                }
                List<OrdMain> ordMains = ordMainDelList.stream().filter(x -> key.replaceAll("/", "").equals(x.getTreatDate())).collect(Collectors.toList());

                IndScheduleInfo indScheduleInfo = new IndScheduleInfo();
                ordMains.forEach(i->{
                  List<OrdNoAndConnectedTableKeyData> delPatRadMainListForOrdNo = connectedOrdMainRadCdListMap.getOrDefault(i.getOrdNo(), Collections.emptyList());
                  indScheduleInfo.setFacilityCd(facilityCd);
                  indScheduleInfo.setConnectedRadResultCdList(delPatRadMainListForOrdNo.stream().map(o -> o.getKey()).collect(Collectors.toList()));
                  indScheduleInfo.setTreatDate(key.replaceAll("/", ""));
                  indInfoDelList.add(indScheduleInfo);
                });
              }
            }
            if (indInfoDelList.size() > 0) {
              patRadMainDelList = indScheduleDao.deletePatRadMainToHistoryByIndSchdueInfoList(facilityCd, indInfoDelList);
              for (PatRadMain patRadMain : patRadMainDelList) {
                patRadMain.setIsDel("1"); // リストに追加する前にdelフラグを立てる
              }
              resultPatRadMainChangedDataInfoList.addAll(patRadMainDelList);
            }

            List<PatRadMain> patRadMainList = new ArrayList<>();
            List<IndScheduleInfo> indInfoList = new ArrayList<>();
            if (connectedOrdMainRadResultCdList.size() > 0) {
              Map<Long, List<OrdNoAndConnectedTableKeyData>> connectedOrdMainRadCdListMap = connectedOrdMainRadResultCdList.stream().collect(Collectors.groupingBy(OrdNoAndConnectedTableKeyData::getOrdNo, Collectors.toList()));
              for (String key : moveDateMap.keySet()) {
                if (moveDateMap.get(key).equals(key)) {
                  continue;
                }
                List<OrdMainEsListener> ordMains = ordMainListForEvent.stream().filter(x -> key.replaceAll("/", "").equals(x.getTreatDate())).collect(Collectors.toList());

                IndScheduleInfo indScheduleInfo = new IndScheduleInfo();
                ordMains.forEach(i->{
                  List<OrdNoAndConnectedTableKeyData> delPatRadMainListForOrdNo = connectedOrdMainRadCdListMap.getOrDefault(i.getOrdNo(), Collections.emptyList());
                  indScheduleInfo.setFacilityCd(facilityCd);
                  indScheduleInfo.setConnectedRadResultCdList(delPatRadMainListForOrdNo.stream().map(o -> o.getKey()).collect(Collectors.toList()));
                  indScheduleInfo.setTreatDate(moveDateMap.get(key).replaceAll("/", ""));
                  indInfoList.add(indScheduleInfo);
                });
              }
            }
            if (indInfoList.size() > 0) {
              patRadMainList = indScheduleDao.deletePatRadMainToHistoryByIndSchdueInfoList(facilityCd, indInfoList);
              for (PatRadMain patRadMain : patRadMainList) {
                patRadMain.setIsDel("1"); // リストに追加する前にdelフラグを立てる
              }
              resultPatRadMainChangedDataInfoList.addAll(patRadMainList);
            }
            // mod 10125 検査予定に関する連携イベント作成不備 関  end
          } catch (Exception e) {
            //エラー
            EventLogMessage eventLogMessage = new EventLogMessage();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          if (bodyData != null && bodyData.getFacility_cd() != null) {
            eventLogMessage.setFacilityCd(bodyData.getFacility_cd());
          }
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
            logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
            OrdMainWeekPatternResponse response = new OrdMainWeekPatternResponse();
            response.setBody("放射線検査のキャンセルに失敗しました。");
            response.setHeaders(null);
            response.setStatus(HttpStatus.INTERNAL_SERVER_ERROR);
            return response;
          }
          break;
        case "3":
          // 放射線検査への処理は行わない
          break;
        default:
          break;
      }
      // add #9273 施設設定マスタのNo105の設定どおり動かない。  start
      AtomicReference<Boolean> change = new AtomicReference<>(true);
      // add #11717【因島】曜日パターン変更の動作が遅い fang start
      List<PatEvent> allOrdPatEvents = new ArrayList<>();
      if("1".equals(eventChangeSetting) || "2".equals(eventChangeSetting)) {
        List<Long> ordNos = ordMainDelList.stream().map(el -> el.getOrdNo()).collect(Collectors.toList());
        allOrdPatEvents = patEventService.selectByOrdNos(facilityCd, patId, ordNos);
      }
      // add #11717【因島】曜日パターン変更の動作が遅い fang end
      switch (eventChangeSetting) {
        case "1":
          // mod 10409 曜日パターン変更の患者イベント修正 関  start
          Map<Long, List<OrdNoAndConnectedTableKeyData>> connectedPatEventListMap = connectedPatEventList.stream().collect(Collectors.groupingBy(OrdNoAndConnectedTableKeyData::getOrdNo, Collectors.toList()));
          List<IndScheduleInfo> indScheduleInfoList = new ArrayList<>();
          List<IndScheduleInfo> indScheduleInfoDelList = new ArrayList<>();

          for (String key : moveDateMap.keySet()) {
            // add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 関  start
            if (moveDateMap.get(key).equals(key)) {
              continue;
            }
            // add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 関  end
            List<OrdMainEsListener> ordMains = ordMainListForEvent.stream().filter(x -> key.replaceAll("/", "").equals(x.getTreatDate())).collect(Collectors.toList());
            ordMains.forEach(i -> {
              IndScheduleInfo indScheduleInfo = new IndScheduleInfo();
              List<OrdNoAndConnectedTableKeyData> connectedPatEventListForOrdNo = connectedPatEventListMap.getOrDefault(i.getOrdNo(), Collections.emptyList());

              indScheduleInfo.setFacilityCd(facilityCd);
              indScheduleInfo.setTreatDate(moveDateMap.get(key).replaceAll("/", ""));
              indScheduleInfo.setOldTreatDate( key.replaceAll("/", ""));
              indScheduleInfo.setConnectedPatEventCdList(connectedPatEventListForOrdNo.stream().map(o -> o.getKey()).collect(Collectors.toList()));
              indScheduleInfo.setConnectedBbsCtlNoList(
                connectedPatEventListForOrdNo.stream()
                  .filter(o -> o.getData() != null && (Long)o.getData() > 0)
                  .map(o -> (Long)o.getData())
                  .collect(Collectors.toList())
              );
              indScheduleInfoList.add(indScheduleInfo);
                });
              }
          if (indScheduleInfoList.size() > 0) {
            // BBSの更新
            List<BbsInfo> bbsInfoListBefore = indScheduleDao.selectForUpdateBbsInfoByIndSchdueInfoList(facilityCd, indScheduleInfoList);
            List<BbsInfo> bbsInfoList = indScheduleDao.updateBbsInfoByIndSchdueInfoList(facilityCd, indScheduleInfoList);

            // 患者イベントの更新
            List<PatEvent> patEventListBefore = indScheduleDao.selectForUpdatePatEventByIndSchdueInfoList(facilityCd, indScheduleInfoList);
            List<PatEvent> patEventList = indScheduleDao.updatePatEventByIndSchdueInfoList(facilityCd, indScheduleInfoList);
          }

          // mod 10409 曜日パターン変更の患者イベント修正 関  end
          for (String key : deleteDateList) {
            // change.set(true);
            // mod 10409 実績リンク有の患者イベントがキャンセルされない 関  start
            // List<OrdMainEsListener> ordMains = ordMainListForEvent.stream().filter(x -> key.replaceAll("/", "").equals(x.getTreatDate())).collect(Collectors.toList());
            List<OrdMain> ordMains = ordMainDelList.stream().filter(x -> key.replaceAll("/", "").equals(x.getTreatDate())).collect(Collectors.toList());
            // mod 10409 実績リンク有の患者イベントがキャンセルされない 関  end
            // List<OrdMain> ordMains = ordMainDao.selectUpdateTarget(patId, facilityCd, key.replaceAll("/", ""), key.replaceAll("/", ""), Arrays.asList(0), Arrays.asList(), Arrays.asList(), null);
            // add #11717【因島】曜日パターン変更の動作が遅い fang start
            List<PatEvent> finalAllOrdPatEvents1 = allOrdPatEvents;
            // add #11717【因島】曜日パターン変更の動作が遅い fang end
            ordMains.forEach(i -> {
              // change.set(false);
              // mod #11717【因島】曜日パターン変更の動作が遅い fang start
//            List<PatEvent> patEvents = patEventService.selectByOrdNo(i.getOrdNo(), facilityCd);
              List<PatEvent> patEvents = finalAllOrdPatEvents1.stream().filter(el -> el.getOrdNo().compareTo(i.getOrdNo()) == 0).collect(Collectors.toList());
              // mod #11717【因島】曜日パターン変更の動作が遅い fang end
              if (patEvents.size() > 0) {
                patEvents.forEach(r -> {
                  patEventService.deleteDateByCd(r.getPatEventCd().toString());
                });
              }
              // else {
              //   patEventService.deleteEventAndBbs(facilityCd, patId, key.replaceAll("/", ""));
              // }
            });
            // if (change.get()) {
            patEventService.deleteEventAndBbs(facilityCd, patId, key.replaceAll("/", ""));
            // }
          }
          break;
        //case "3":
        case "2":
          for (String key : deleteDateList) {
            // change.set(true);
            // mod 10409 実績リンク有の患者イベントがキャンセルされない 関  start
            // List<OrdMainEsListener> ordMains = ordMainListForEvent.stream().filter(x -> key.replaceAll("/", "").equals(x.getTreatDate())).collect(Collectors.toList());
            List<OrdMain> ordMains = ordMainDelList.stream().filter(x -> key.replaceAll("/", "").equals(x.getTreatDate())).collect(Collectors.toList());
            // mod 10409 実績リンク有の患者イベントがキャンセルされない 関  end
            // List<OrdMain> ordMains = ordMainDao.selectUpdateTarget(patId, facilityCd, key.replaceAll("/", ""), key.replaceAll("/", ""), Arrays.asList(0), Arrays.asList(), Arrays.asList(), null);
            // add #11717【因島】曜日パターン変更の動作が遅い fang start
            List<PatEvent> finalAllOrdPatEvents2 = allOrdPatEvents;
            // add #11717【因島】曜日パターン変更の動作が遅い fang end
            ordMains.forEach(i -> {
              // change.set(false);
              // mod #11717【因島】曜日パターン変更の動作が遅い fang start
//            List<PatEvent> patEvents = patEventService.selectByOrdNo(i.getOrdNo(), facilityCd);
              List<PatEvent> patEvents = finalAllOrdPatEvents2.stream().filter(el -> el.getOrdNo().compareTo(i.getOrdNo()) == 0).collect(Collectors.toList());
              // mod #11717【因島】曜日パターン変更の動作が遅い fang end
              if (patEvents.size() > 0) {
                patEvents.forEach(r -> {
                  patEventService.deleteDateByCd(r.getPatEventCd().toString());
                });
              }
              // else {
              //   patEventService.deleteEventAndBbs(facilityCd, patId, key.replaceAll("/", ""));
              // }
            });
            // if (change.get()) {
            patEventService.deleteEventAndBbs(facilityCd, patId, key.replaceAll("/", ""));
            // }
          }
          // add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 関  start
          List<IndScheduleInfo> indInfoDelList = new ArrayList<>();
          Map<Long, List<OrdNoAndConnectedTableKeyData>> connectedPatEventMap = connectedPatEventList.stream().collect(Collectors.groupingBy(OrdNoAndConnectedTableKeyData::getOrdNo, Collectors.toList()));
          for (String key : moveDateMap.keySet()) {
            if (moveDateMap.get(key).equals(key)) {
              continue;
            }
            List<OrdMainEsListener> ordMains = ordMainListForEvent.stream().filter(x -> key.replaceAll("/", "").equals(x.getTreatDate())).collect(Collectors.toList());
            ordMains.forEach(i -> {
              IndScheduleInfo indScheduleInfo = new IndScheduleInfo();
              List<OrdNoAndConnectedTableKeyData> connectedPatEventListForOrdNo = connectedPatEventMap.getOrDefault(i.getOrdNo(), Collections.emptyList());

              indScheduleInfo.setFacilityCd(facilityCd);
              indScheduleInfo.setTreatDate(moveDateMap.get(key).replaceAll("/", ""));
              indScheduleInfo.setOldTreatDate( key.replaceAll("/", ""));
              indScheduleInfo.setConnectedPatEventCdList(connectedPatEventListForOrdNo.stream().map(o -> o.getKey()).collect(Collectors.toList()));
              indScheduleInfo.setConnectedBbsCtlNoList(
                connectedPatEventListForOrdNo.stream()
                  .filter(o -> o.getData() != null && (Long)o.getData() > 0)
                  .map(o -> (Long)o.getData())
                  .collect(Collectors.toList())
              );
              indInfoDelList.add(indScheduleInfo);
            });
          }
          if (indInfoDelList.size() > 0) {
            // BBSの更新
            List<BbsInfo> bbsInfoListDelBefore = indScheduleDao.selectForUpdateBbsInfoToDeleteByIndSchdueInfoList(facilityCd, indInfoDelList);

            List<BbsInfo> bbsInfoListDel = indScheduleDao.updateBbsInfoToDeleteByIndSchdueInfoList(facilityCd, indInfoDelList);

            // 患者イベントの更新
            List<PatEvent> patEventListDelBefore = indScheduleDao.selectForUpdatePatEventToDeleteByIndSchdueInfoList(facilityCd, indInfoDelList);

            List<PatEvent> patEventListDel = indScheduleDao.updatePatEventToDeleteByIndSchdueInfoList(facilityCd, indInfoDelList);
          }
          // add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 関  end
          break;
        default:
          break;
      }
      // add #9273 施設設定マスタのNo105の設定どおり動かない。  end
      // 指示履歴を登録
      indHistoryMakeService.createWeekPatternHistory(
        bodyData,
        changeWeekList,
        srcDelWeek);

      //del #10412 次患者更新関連全体見直し対応 朴 start
//      // 次患者更新処理
//      // 移動対象の ordNoList と 削除対象の ordNoList を合算し、変更された ordNoのリストを作成する
//      List<Long> sumChangeOrdNoList = new ArrayList<>();
//      sumChangeOrdNoList.addAll(ordNoList);
//      sumChangeOrdNoList.addAll(sumDeleteOrdNoList);
//      List<MntMachineState> machineStateList = mntMachineStateDao.selectByNextOrdNoList(patId, facilityCd, sumChangeOrdNoList);
//      // ベッドコードを集計する
//      List<Long> bedCdList = machineStateList.size() != 0 ? machineStateList.stream().map(item -> item.getBedCd()).distinct().collect(Collectors.toList()) : new ArrayList<>();
//      // 次患者更新処理実施
//      LocalDateTime update = LocalDateTime.now();
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      for (Long bedCd : bedCdList) {
//        try {
//          if (bedCd != null && ! bedCd.equals((long) 0)) {
//            // add FNSI-FutreNetWeb+SI課題管理No.5619 李 start
//            threadExector.execute(new Runnable() {
//              @Override
//              public void run() {
//                ResponseEntity<String> res = null;
//                try {
//                  res = webApiCallCommonUtil.SetNextPatInfo(bedCd, true, update);
//                } catch (URISyntaxException e) {
//                  e.printStackTrace();
//                }
//                JSONObject json = new JSONObject(res.getBody().toString());
//                if (! json.has("isSuccess")) {
//                  // 次患者更新エラー
//                  eventLogMessage.setLogMessage("曜日変更処理：「次患者更新」失敗 facilityCd:[" + facilityCd + "] beforeBedCd:[" + bedCd + "]");
//                  logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
//                } else if (res.getStatusCode() != HttpStatus.OK) {
//                  // 次患者通知エラー
//                  eventLogMessage.setLogMessage("曜日変更処理：「次患者更新通信サーバー通知」失敗 facilityCd:[" + facilityCd + "] beforeBedCd:[" + bedCd + "]");
//                  logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
//                }
//              }
//            });
//            // add FNSI-FutreNetWeb+SI課題管理No.5619 李 end
//          }
//        } catch (RuntimeException e) {
//          eventLogMessage.setLogMessage("曜日変更処理：「次患者更新」例外発生 facilityCd:[" + facilityCd + "] beforeBedCd:[" + bedCd + "]");
//          logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
//          e.printStackTrace();
//        }
//      }
      //del #10412 次患者更新関連全体見直し対応 朴 end

      // 戻り値情報
      // add #8548 修正 ljx start
      //移動先が既に予定があり、かつ変更優先を選択する場合、元の予定の削除電文が削除されるはず、それを補足。
      //mod 10553 start
//      journalCreateRequestPayload.setCrud("D");
      List<JournalCreateRequestPayload> patInfoList = this.getPatInfo(updateOrdMainList);
//      List<OrdMain> journalOrdMainList = new ArrayList<>();;
      for(OrdMain destDelOrdMain : updateOrdMainList){
        for(JournalCreateRequestPayload payload : patInfoList){
          if(Objects.equals(destDelOrdMain.getOrdNo(), payload.getOrdNo())){
//          if(destDelOrdMain.getOrdNo().toString().equals(payload.getOrdNo().toString())){
//            journalOrdMainList.add(destDelOrdMain);
//            journalCreateRequestPayload.setHospPatId(payload.getHospPatId());
//            journalCreateRequestPayload.setPatId(payload.getPatId());
//            journalService.callCreateJournal(journalOrdMainList, journalCreateRequestPayload,requestList);
//            journalOrdMainList.clear();
            resultOrdMainChangedDataInfoList.add(destDelOrdMain); // 変更後データ退避
            break;
          }
        }
      }
      //mod 10553 end
      // add #8548 修正 ljx end
      JSONObject responseData = new JSONObject("{}");
      //add 7307 曜日変更bug 張 start
      // mod #11717【因島】曜日パターン変更の動作が遅い fang start
      responseData.put("nobedlist",new ArrayList<Long>());
      //add 7307 曜日変更bug 張 end
      OrdMainWeekPatternResponse response = new OrdMainWeekPatternResponse();
//      if(nobedlist.size()>0&&bodyData.getSkip()){
//        TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
//      }else {
        // mod #10553 start
//        response.setRequestList(requestList);
//        // add #8548 修正 ljx start
//        // いったん電文リストをフロントへ返して、全ての処理が終わてから、電文作成APIをフロントから呼び出し
//        responseData.put("jouralList",this.getJouralList(requestList));
//        // add #8548 修正 ljx end
        response.setResultOrdMainChangeBeforeDataInfoList(resultOrdMainChangeBeforeDataInfoList);
        response.setResultOrdMainChangedAfterDataInfoList(resultOrdMainChangedDataInfoList);
        // mod #10553 end
        // add 10125 検査予定に関する連携イベント作成不備 関  start
        response.setResultPatExamMainChangeBeforeDataInfoList(resultPatExamMainChangeBeforeDataInfoList);
        response.setResultPatExamMainChangedAfterDataInfoList(resultPatExamMainChangedDataInfoList);
        response.setResultPatRadMainChangedAfterDataInfoList(resultPatRadMainChangedDataInfoList);
        // add 10125 検査予定に関する連携イベント作成不備 関  end
//      }
      // mod #11717【因島】曜日パターン変更の動作が遅い fang end
      response.setBody(responseData.toString());
      response.setHeaders(null);
      response.setStatus(HttpStatus.OK);

      //add #10412 次患者更新関連全体見直し対応 朴 start
      response.setDoCallNextPatOrdMainList(doCallNextPatOrdMainList);
      //add #10412 次患者更新関連全体見直し対応 朴 end

      return response;
    }
  //mod 7068 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない 卓 END

  // add #9273 施設設定マスタのNo105の設定どおり動かない。 start
  @Override
  public boolean checkExamResult(List<PatExamMain> patListRet, String treatDate) {
    boolean result = false;
    if (!patListRet.isEmpty()) {
      SimpleDateFormat sdf = new SimpleDateFormat("yyyy/MM/dd");
      result = patListRet.stream().anyMatch(x -> treatDate.equals(sdf.format(x.getRegExamDate())));
    }
    return result;
  }
  //10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy start
  @Override
  public boolean checkRadResult(List<PatRadMain> patListRet, String treatDate) {
    boolean result = false;
    if (!patListRet.isEmpty()) {
      SimpleDateFormat sdf = new SimpleDateFormat("yyyy/MM/dd");
      result = patListRet.stream().anyMatch(x -> treatDate.equals(sdf.format(x.getRegRadDate())));
    }
    return result;
  }
  //10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy end
  // add #9273 施設設定マスタのNo105の設定どおり動かない。 end
    //add 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 end
  //add 7307 曜日変更bug 張 end
  //  add 4693 鞠 start
  @Override
  public List<OrdMain> selectOrdMainByFacilityCd(String facilityCd,String treatDate) {
    return ordMainDao.selectOrdMainByFacilityCd(facilityCd, treatDate);
  }
//  @Override
//  public int updateOrdMainByOrdNo(Long ordNo) {
//    // add 6227 張 start
////    copyOrdmainToOrdMainRestore(ordNo);
//    // add 6227 張 end
//    return ordMainDao.updateOrdMainByOrdNo(ordNo);
//  }
  //  add 4693 鞠 end
//    del 8074 【デグレ】ログに誤った利用者が記録される 関 start
//  add 8074 【デグレ】ログに誤った利用者が記録される 関 start
//  @Override
//  public int updateUseId(Long ordNo, Long upUserId) {
//    return ordMainDao.updateUseId(ordNo,upUserId);
//  }
//  add 8074 【デグレ】ログに誤った利用者が記録される 関  end
//    del 8074 【デグレ】ログに誤った利用者が記録される 関  end
  @Override
  public List<OrdMainSharingInfo> findByDateCdSharingInfo(String facility_cd, Long pat_id, String dialysis_date_from,
                                                          String dialysis_date_to, Long ord_no, List<Integer> weeksArry, String is_del) {
    List<OrdMain> list = ordMainDao.selectByDateCd(facility_cd, pat_id, dialysis_date_from, dialysis_date_to, ord_no,
      weeksArry, is_del);
    List<OrdMainSharingInfo> result = new ArrayList<>();
    for (OrdMain ordMain : list) {
//      ObjectMapper mapper = new ObjectMapper();
//      String valueMapper = "";
//      try {
//        valueMapper = mapper.writeValueAsString(ordMain);
//        OrdMainSharingInfo ordMainSharingInfo = mapper.readValue(valueMapper, OrdMainSharingInfo.class);
//        result.add(ordMainSharingInfo);
//      } catch (IOException e) {
//        throw new NtssException("JSON文字列変換でエラーが発生しました。", e);
//      }
      OrdMainSharingInfo ordMainSharingInfo = new OrdMainSharingInfo();
      BeanUtils.copyProperties(ordMain, ordMainSharingInfo);
      result.add(ordMainSharingInfo);
    }
    return result;
  }

  /* add by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
  @Override
  public List<OrdMainSharingInfo> findOrdMainByDateCdSharingInfo(String facility_cd, Long pat_id, String dialysis_date_from,
                                                          String dialysis_date_to, List<Integer> weeksArry, Integer patShareMode) {
    List<OrdMain> list = ordMainDao.selectByDateCd(facility_cd, pat_id, dialysis_date_from, dialysis_date_to, null,
            weeksArry, null);
    List<OrdMainSharingInfo> result = new ArrayList<>();
    for (OrdMain ordMain : list) {
      OrdMainSharingInfo ordMainSharingInfo = new OrdMainSharingInfo();
      BeanUtils.copyProperties(ordMain, ordMainSharingInfo);
      ordMainSharingInfo.setReadOnly(false);
      result.add(ordMainSharingInfo);
    }

    if (!ObjectUtils.isEmpty(patShareMode) && patShareMode == 0) {
      // 患者の共有データを照会する
      List<OrdMain> ordMainsToShr = ordMainDao.selectByDateCdToShr(facility_cd, pat_id, dialysis_date_from, dialysis_date_to, weeksArry);
      if (!ObjectUtils.isEmpty(ordMainsToShr)) {
        for(OrdMain ordMain : ordMainsToShr) {
          OrdMainSharingInfo ordMainSharingInfo = new OrdMainSharingInfo();
          BeanUtils.copyProperties(ordMain, ordMainSharingInfo);
          ordMainSharingInfo.setReadOnly(true);
          result.add(ordMainSharingInfo);
        }
      }
    }
    // add [11397] 薬剤、医療の並び順不正 start
    sortSharingInfoIndEquipInfo(result, facility_cd);
    sortSharingInfoIndMediInfo(result, facility_cd);
    // add [11397] 薬剤、医療の並び順不正 end
    return result;
  }
  /* add by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */

  // add [11397] 薬剤、医療の並び順不正 start
  private static final String EQUIP_SORT_REG_ORDER = "0";
  private static final String EQUIP_SORT_CLASS_ORDER = "1";
  private static final String EQUIP_SORT_CODE_ORDER = "2";
  private static final String MEDI_SORT_REG_ORDER = "0";
  private static final String MEDI_SORT_CLASS_ORDER = "1";
  private static final String MEDI_SORT_TYPE_ORDER = "2";
  private static final String MEDI_SORT_CODE_ORDER = "3";
  private static final String MEDI_SORT_TIMING_ORDER = "4";
  private static final String MEDI_SORT_PROCEDURE_ORDER = "5";
  private static final String MEDI_SORT_DATE_INTERVAL_ORDER = "6";
  private void sortSharingInfoIndEquipInfo(List<OrdMainSharingInfo> sharingInfoList, String facilityCd) {
    if (CollectionUtils.isEmpty(sharingInfoList)) {
      return;
    }
    List<String> sortKeys = getEquipmentDisplayOrderSetting(facilityCd);
    for (OrdMainSharingInfo sharingInfo : sharingInfoList) {
      String indEquipInfo = sharingInfo.getIndEquipInfo();
      if (StringUtils.isEmpty(indEquipInfo)) {
        continue;
      }
      try {
        ObjectMapper mapper = new ObjectMapper();
        JsonNode root = mapper.readTree(indEquipInfo);
        if (!(root instanceof ArrayNode)) {
          continue;
        }
        ArrayNode sortedNode = sortIndEquipInfoArray((ArrayNode) root, sortKeys, facilityCd);
        sharingInfo.setIndEquipInfo(sortedNode.toString());
      } catch (IOException e) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        eventLogMessage.setFacilityCd(facilityCd);
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      }
    }
  }

  private void sortSharingInfoIndMediInfo(List<OrdMainSharingInfo> sharingInfoList, String facilityCd) {
    if (CollectionUtils.isEmpty(sharingInfoList)) {
      return;
    }
    List<String> sortKeys = getMedicineDisplayOrderSetting(facilityCd);
    for (OrdMainSharingInfo sharingInfo : sharingInfoList) {
      String indMediInfo = sharingInfo.getIndMediInfo();
      if (StringUtils.isEmpty(indMediInfo)) {
        continue;
      }
      try {
        ObjectMapper mapper = new ObjectMapper();
        JsonNode root = mapper.readTree(indMediInfo);
        if (!(root instanceof ArrayNode)) {
          continue;
        }
        ArrayNode sortedNode = sortIndMediInfoArray((ArrayNode) root, sortKeys, facilityCd);
        sharingInfo.setIndMediInfo(sortedNode.toString());
      } catch (IOException e) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        eventLogMessage.setFacilityCd(facilityCd);
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      }
    }
  }

  private List<String> getEquipmentDisplayOrderSetting(String facilityCd) {
    List<FacilitySettingInfo> facilitySettings = mstFacilitySettingDao.selectFacilitySetting(facilityCd, EQUIP_DISPLAY_ORDER);
    String displayValue = CollectionUtils.isEmpty(facilitySettings) ? null : facilitySettings.get(0).getValue();
    if (StringUtils.isEmpty(displayValue)) {
      return Collections.singletonList(EQUIP_SORT_REG_ORDER);
    }
    String[] keyList = displayValue.replace("[", "").replace("]", "").replace("\"", "").split(",");
    List<String> sortKeys = Arrays.stream(keyList)
      .map(String::trim)
      .filter(key -> EQUIP_SORT_REG_ORDER.equals(key) || EQUIP_SORT_CLASS_ORDER.equals(key) || EQUIP_SORT_CODE_ORDER.equals(key))
      .collect(Collectors.toList());
    return normalizeEquipSortKeys(sortKeys);
  }

  private List<String> normalizeEquipSortKeys(List<String> sortKeys) {
    if (CollectionUtils.isEmpty(sortKeys)) {
      return Collections.singletonList(EQUIP_SORT_REG_ORDER);
    }

    String firstKey = sortKeys.get(0);
    // 文書定義:
    // - 先頭が 0 の場合は常に「登録順」。
    // - 先頭が 2 の場合は常に「医療材料マスタ表示順」。
    // - 先頭が 1 の場合のみ、次優先キー(0/2)で「1>0」または「1>2」を決める。
    if (EQUIP_SORT_REG_ORDER.equals(firstKey)) {
      return Collections.singletonList(EQUIP_SORT_REG_ORDER);
    }
    if (EQUIP_SORT_CODE_ORDER.equals(firstKey)) {
      return Collections.singletonList(EQUIP_SORT_CODE_ORDER);
    }
    if (EQUIP_SORT_CLASS_ORDER.equals(firstKey)) {
      String nextPriorityKey = null;
      for (int i = 1; i < sortKeys.size(); i++) {
        String candidate = sortKeys.get(i);
        if (EQUIP_SORT_REG_ORDER.equals(candidate) || EQUIP_SORT_CODE_ORDER.equals(candidate)) {
          nextPriorityKey = candidate;
          break;
        }
      }
      if (EQUIP_SORT_CODE_ORDER.equals(nextPriorityKey)) {
        return Arrays.asList(EQUIP_SORT_CLASS_ORDER, EQUIP_SORT_CODE_ORDER);
      }
      return Arrays.asList(EQUIP_SORT_CLASS_ORDER, EQUIP_SORT_REG_ORDER);
    }
    return Collections.singletonList(EQUIP_SORT_REG_ORDER);
  }

  private List<String> getMedicineDisplayOrderSetting(String facilityCd) {
    List<FacilitySettingInfo> facilitySettings = mstFacilitySettingDao.selectFacilitySetting(
      facilityCd, CoreConstant.FacilitySettingNo.MEDICINE_DISPLAY_ORDER);
    String displayValue = CollectionUtils.isEmpty(facilitySettings) ? null : facilitySettings.get(0).getValue();
    if (StringUtils.isEmpty(displayValue)) {
      return Collections.singletonList(MEDI_SORT_REG_ORDER);
    }
    String[] keyList = displayValue.replace("[", "").replace("]", "").replace("\"", "").split(",");
    List<String> sortKeys = Arrays.stream(keyList)
      .map(String::trim)
      .filter(key -> MEDI_SORT_REG_ORDER.equals(key)
        || MEDI_SORT_CLASS_ORDER.equals(key)
        || MEDI_SORT_TYPE_ORDER.equals(key)
        || MEDI_SORT_CODE_ORDER.equals(key)
        || MEDI_SORT_TIMING_ORDER.equals(key)
        || MEDI_SORT_PROCEDURE_ORDER.equals(key)
        || MEDI_SORT_DATE_INTERVAL_ORDER.equals(key))
      .distinct()
      .collect(Collectors.toList());
    if (CollectionUtils.isEmpty(sortKeys)) {
      return Collections.singletonList(MEDI_SORT_REG_ORDER);
    }
    if (!sortKeys.contains(MEDI_SORT_REG_ORDER)) {
      sortKeys.add(MEDI_SORT_REG_ORDER);
    }
    return sortKeys;
  }

  private ArrayNode sortIndEquipInfoArray(ArrayNode equipArrayNode, List<String> sortKeys, String facilityCd) {
    List<JsonNode> equipNodeList = new ArrayList<>();
    for (JsonNode node : equipArrayNode) {
      equipNodeList.add(node);
    }
    Map<Integer, Integer> classCdMapByEquipCd = buildEquipClassCdMap(equipNodeList, sortKeys, facilityCd);
    Map<Integer, Integer> classOrderRankMap = buildSimpleOrderRankMap(getOrderSettingItems(facilityCd, "mst_equipment_class"));
    Map<String, Integer> codeOrderRankMap = buildEquipCodeOrderRankMap(facilityCd);
    Map<JsonNode, Integer> originIndexMap = new HashMap<>();
    for (int i = 0; i < equipNodeList.size(); i++) {
      originIndexMap.put(equipNodeList.get(i), i);
    }
    equipNodeList.sort((o1, o2) -> {
      for (String key : sortKeys) {
        int compareResult = compareEquipByKey(o1, o2, key, classCdMapByEquipCd, classOrderRankMap, codeOrderRankMap, originIndexMap);
        if (compareResult != 0) {
          return compareResult;
        }
      }
      return Integer.compare(originIndexMap.getOrDefault(o1, Integer.MAX_VALUE), originIndexMap.getOrDefault(o2, Integer.MAX_VALUE));
    });
    ArrayNode sortedArrayNode = new ObjectMapper().createArrayNode();
    for (JsonNode node : equipNodeList) {
      sortedArrayNode.add(node);
    }
    return sortedArrayNode;
  }

  private int compareEquipByKey(JsonNode o1, JsonNode o2, String key,
                                Map<Integer, Integer> classCdMapByEquipCd,
                                Map<Integer, Integer> classOrderRankMap,
                                Map<String, Integer> codeOrderRankMap,
                                Map<JsonNode, Integer> originIndexMap) {
    switch (key) {
      case EQUIP_SORT_REG_ORDER:
        return Long.compare(getLongValue(o1, "no", Long.MAX_VALUE), getLongValue(o2, "no", Long.MAX_VALUE));
      case EQUIP_SORT_CLASS_ORDER:
        // ダイアライザ(1)を医療材料(0)より優先して並べる
        int dialyzerPriorityByClass = compareDialyzerFirst(o1, o2);
        if (dialyzerPriorityByClass != 0) {
          return dialyzerPriorityByClass;
        }
        return Integer.compare(
          getEquipClassOrderRank(o1, classCdMapByEquipCd, classOrderRankMap, originIndexMap),
          getEquipClassOrderRank(o2, classCdMapByEquipCd, classOrderRankMap, originIndexMap));
      case EQUIP_SORT_CODE_ORDER:
        // ダイアライザ(1)を医療材料(0)より優先して並べる
        int dialyzerPriorityByCode = compareDialyzerFirst(o1, o2);
        if (dialyzerPriorityByCode != 0) {
          return dialyzerPriorityByCode;
        }
        return Integer.compare(
          getEquipCodeOrderRank(o1, codeOrderRankMap, originIndexMap),
          getEquipCodeOrderRank(o2, codeOrderRankMap, originIndexMap));
      default:
        return 0;
    }
  }

  private int compareDialyzerFirst(JsonNode o1, JsonNode o2) {
    long equipType1 = getLongValue(o1, "equip_type", 0L);
    long equipType2 = getLongValue(o2, "equip_type", 0L);
    if (equipType1 == equipType2) {
      return 0;
    }
    // equip_type: 0=医療材料, 1=ダイアライザ
    if (equipType1 == 1L) {
      return -1;
    }
    if (equipType2 == 1L) {
      return 1;
    }
    return Long.compare(equipType1, equipType2);
  }

  private Map<Integer, Integer> buildEquipClassCdMap(List<JsonNode> equipNodeList, List<String> sortKeys, String facilityCd) {
    if (CollectionUtils.isEmpty(equipNodeList) || CollectionUtils.isEmpty(sortKeys) || !sortKeys.contains(EQUIP_SORT_CLASS_ORDER)) {
      return Collections.emptyMap();
    }
    List<Integer> equipCdList = equipNodeList.stream()
      .map(node -> (int) getLongValue(node, "cd", -1))
      .filter(cd -> cd > 0)
      .distinct()
      .collect(Collectors.toList());
    if (CollectionUtils.isEmpty(equipCdList)) {
      return Collections.emptyMap();
    }
    List<MstEquipment> mstEquipmentList = mstEquipmentDao.selectByCdListCheckList(SelectOptions.get(), equipCdList, facilityCd);
    Map<Integer, Integer> classCdMapByEquipCd = new HashMap<>();
    for (MstEquipment mstEquipment : mstEquipmentList) {
      if (mstEquipment != null && mstEquipment.getEquipmentCd() != null && mstEquipment.getClassCd() != null) {
        classCdMapByEquipCd.put(mstEquipment.getEquipmentCd(), mstEquipment.getClassCd());
      }
    }
    return classCdMapByEquipCd;
  }

  private long getClassCdValue(JsonNode node, Map<Integer, Integer> classCdMapByEquipCd) {
    long classCdValue = getLongValue(node, "class_cd", Long.MAX_VALUE);
    // class_cd が null / -1 / 0 の場合は未設定扱いとして後ろに回す
    if (classCdValue > 0 && classCdValue != Long.MAX_VALUE) {
      return classCdValue;
    }
    int equipCd = (int) getLongValue(node, "cd", -1);
    if (equipCd <= 0 || classCdMapByEquipCd == null) {
      return Long.MAX_VALUE;
    }
    Integer classCd = classCdMapByEquipCd.get(equipCd);
    if (classCd == null || classCd <= 0) {
      return Long.MAX_VALUE;
    }
    return classCd.longValue();
  }

  private int getEquipClassOrderRank(JsonNode node, Map<Integer, Integer> classCdMapByEquipCd,
                                     Map<Integer, Integer> classOrderRankMap, Map<JsonNode, Integer> originIndexMap) {
    long classCd = getClassCdValue(node, classCdMapByEquipCd);
    if (classCd == Long.MAX_VALUE || classCd <= 0) {
      return Integer.MAX_VALUE;
    }
    Integer rank = classOrderRankMap.get((int) classCd);
    if (rank != null) {
      return rank;
    }
    // mst_equipment_classのorder_settings.itemsに無い分類は、配列順の後ろに元の順で並べる
    return classOrderRankMap.size() + originIndexMap.getOrDefault(node, Integer.MAX_VALUE);
  }

  private Map<String, Integer> buildEquipCodeOrderRankMap(String facilityCd) {
    List<Integer> equipmentCodeOrder = getOrderSettingItems(facilityCd, "mst_equipment");
    List<Integer> dialyzerCodeOrder = getOrderSettingItems(facilityCd, "mst_dialyzer");
    Map<String, Integer> rankMap = new HashMap<>();
    int rank = 0;
    for (Integer cd : dialyzerCodeOrder) {
      rankMap.put("1:" + cd, rank++);
    }
    for (Integer cd : equipmentCodeOrder) {
      rankMap.put("0:" + cd, rank++);
    }
    return rankMap;
  }

  private int getEquipCodeOrderRank(JsonNode node, Map<String, Integer> codeOrderRankMap, Map<JsonNode, Integer> originIndexMap) {
    long equipType = getLongValue(node, "equip_type", 0L);
    long cd = getLongValue(node, "cd", Long.MAX_VALUE);
    String codeKey = equipType + ":" + cd;
    Integer rank = codeOrderRankMap.get(codeKey);
    if (rank != null) {
      return rank;
    }
    // order_settings.itemsの配列順の後ろに、削除済み(一覧に無い)コードを元の順で並べる
    return codeOrderRankMap.size() + originIndexMap.getOrDefault(node, Integer.MAX_VALUE);
  }

  private ArrayNode sortIndMediInfoArray(ArrayNode mediArrayNode, List<String> sortKeys, String facilityCd) {
    List<JsonNode> mediNodeList = new ArrayList<>();
    for (JsonNode node : mediArrayNode) {
      mediNodeList.add(node);
    }
    Map<JsonNode, Integer> originIndexMap = new HashMap<>();
    for (int i = 0; i < mediNodeList.size(); i++) {
      originIndexMap.put(mediNodeList.get(i), i);
    }
    Map<Integer, Integer> classOrderRankMap = buildSimpleOrderRankMap(getOrderSettingItems(facilityCd, "mst_medicine_class"));
    Map<String, Integer> codeOrderRankMap = buildMediCodeOrderRankMap(facilityCd);
    Map<Integer, Integer> timingOrderRankMap = buildSimpleOrderRankMap(getOrderSettingItems(facilityCd, "mst_medicate_timing"));
    Map<Integer, Integer> procedureOrderRankMap = buildSimpleOrderRankMap(getOrderSettingItems(facilityCd, "mst_procedure"));

    mediNodeList.sort((o1, o2) -> {
      for (String key : sortKeys) {
        int compareResult = compareMediByKey(o1, o2, key, classOrderRankMap, codeOrderRankMap, timingOrderRankMap,
          procedureOrderRankMap, originIndexMap);
        if (compareResult != 0) {
          return compareResult;
        }
      }
      return Integer.compare(originIndexMap.getOrDefault(o1, Integer.MAX_VALUE), originIndexMap.getOrDefault(o2, Integer.MAX_VALUE));
    });

    ArrayNode sortedArrayNode = new ObjectMapper().createArrayNode();
    for (JsonNode node : mediNodeList) {
      sortedArrayNode.add(node);
    }
    return sortedArrayNode;
  }

  private int compareMediByKey(JsonNode o1, JsonNode o2, String key,
                               Map<Integer, Integer> classOrderRankMap,
                               Map<String, Integer> codeOrderRankMap,
                               Map<Integer, Integer> timingOrderRankMap,
                               Map<Integer, Integer> procedureOrderRankMap,
                               Map<JsonNode, Integer> originIndexMap) {
    switch (key) {
      case MEDI_SORT_REG_ORDER:
        return Long.compare(getLongValue(o1, "no", Long.MAX_VALUE), getLongValue(o2, "no", Long.MAX_VALUE));
      case MEDI_SORT_CLASS_ORDER:
        return Integer.compare(
          getMediClassOrderRank(o1, classOrderRankMap, originIndexMap),
          getMediClassOrderRank(o2, classOrderRankMap, originIndexMap));
      case MEDI_SORT_TYPE_ORDER:
        return Long.compare(getLongValue(o1, "medicine_type", Long.MAX_VALUE), getLongValue(o2, "medicine_type", Long.MAX_VALUE));
      case MEDI_SORT_CODE_ORDER:
        return Integer.compare(
          getMediCodeOrderRank(o1, codeOrderRankMap, originIndexMap),
          getMediCodeOrderRank(o2, codeOrderRankMap, originIndexMap));
      case MEDI_SORT_TIMING_ORDER:
        return Integer.compare(
          getOrderRankByCd(o1, "timing_cd", timingOrderRankMap, originIndexMap),
          getOrderRankByCd(o2, "timing_cd", timingOrderRankMap, originIndexMap));
      case MEDI_SORT_PROCEDURE_ORDER:
        return Integer.compare(
          getOrderRankByCd(o1, "procedure_cd", procedureOrderRankMap, originIndexMap),
          getOrderRankByCd(o2, "procedure_cd", procedureOrderRankMap, originIndexMap));
      case MEDI_SORT_DATE_INTERVAL_ORDER:
        return Long.compare(getLongValue(o1, "date_interval", Long.MAX_VALUE), getLongValue(o2, "date_interval", Long.MAX_VALUE));
      default:
        return 0;
    }
  }

  private Map<Integer, Integer> buildSimpleOrderRankMap(List<Integer> codeOrderList) {
    if (CollectionUtils.isEmpty(codeOrderList)) {
      return Collections.emptyMap();
    }
    Map<Integer, Integer> rankMap = new HashMap<>();
    for (int i = 0; i < codeOrderList.size(); i++) {
      rankMap.put(codeOrderList.get(i), i);
    }
    return rankMap;
  }

  private int getOrderRankByCd(JsonNode node, String key, Map<Integer, Integer> rankMap, Map<JsonNode, Integer> originIndexMap) {
    long cd = getLongValue(node, key, -1);
    if (cd <= 0) {
      return Integer.MAX_VALUE;
    }
    Integer rank = rankMap.get((int) cd);
    if (rank != null) {
      return rank;
    }
    // order_settings.itemsの配列順の後ろに、一覧に無いコードを元の順で並べる
    return rankMap.size() + originIndexMap.getOrDefault(node, Integer.MAX_VALUE);
  }

  private int resolveMediClassCd(JsonNode node) {
    long classCd = getLongValue(node, "class_cd", -1);
    if (classCd > 0) {
      return (int) classCd;
    }
    long medicineType = getLongValue(node, "medicine_type", -1);
    int cd = (int) getLongValue(node, "cd", -1);
    if (cd <= 0) {
      return -1;
    }
    if (medicineType == 1) {
      MstMedicine mstMedicine = mstMedicineDao.selectByMediCd(cd);
      if (mstMedicine != null && mstMedicine.getClassCd() != null) {
        return mstMedicine.getClassCd();
      }
    } else if (medicineType == 2) {
      MstMedicineMix mstMedicineMix = mstMedicineMixDao.selectByMedicineMixCd(cd);
      if (mstMedicineMix != null && mstMedicineMix.getClassCd() != null) {
        return mstMedicineMix.getClassCd();
      }
    }
    return -1;
  }

  private int getMediClassOrderRank(JsonNode node, Map<Integer, Integer> classOrderRankMap, Map<JsonNode, Integer> originIndexMap) {
    int classCd = resolveMediClassCd(node);
    if (classCd <= 0) {
      return Integer.MAX_VALUE;
    }
    Integer rank = classOrderRankMap.get(classCd);
    if (rank != null) {
      return rank;
    }
    // mst_medicine_classのorder_settings.itemsに無い分類は、配列順の後ろに元の順で並べる
    return classOrderRankMap.size() + originIndexMap.getOrDefault(node, Integer.MAX_VALUE);
  }

  private Map<String, Integer> buildMediCodeOrderRankMap(String facilityCd) {
    List<Integer> medicineCodeOrder = getOrderSettingItems(facilityCd, "mst_medicine");
    List<Integer> medicineMixCodeOrder = getOrderSettingItems(facilityCd, "mst_medicine_mix");
    Map<String, Integer> rankMap = new HashMap<>();
    int rank = 0;
    for (Integer cd : medicineCodeOrder) {
      rankMap.put("1:" + cd, rank++);
    }
    for (Integer cd : medicineMixCodeOrder) {
      rankMap.put("2:" + cd, rank++);
    }
    return rankMap;
  }

  private int getMediCodeOrderRank(JsonNode node, Map<String, Integer> codeOrderRankMap, Map<JsonNode, Integer> originIndexMap) {
    long medicineType = getLongValue(node, "medicine_type", Long.MAX_VALUE);
    long cd = getLongValue(node, "cd", Long.MAX_VALUE);
    String codeKey = medicineType + ":" + cd;
    Integer rank = codeOrderRankMap.get(codeKey);
    if (rank != null) {
      return rank;
    }
    // order_settings.itemsの配列順の後ろに、一覧に無いコードを元の順で並べる
    return codeOrderRankMap.size() + originIndexMap.getOrDefault(node, Integer.MAX_VALUE);
  }

  private long getLongValue(JsonNode node, String key, long defaultValue) {
    if (node == null || node.isNull() || !node.has(key) || node.get(key) == null || node.get(key).isNull()) {
      return defaultValue;
    }
    String value = node.get(key).asText();
    if (StringUtils.isEmpty(value)) {
      return defaultValue;
    }
    try {
      return Long.parseLong(value);
    } catch (NumberFormatException e) {
      return defaultValue;
    }
  }
  // add [11397] 薬剤、医療の並び順不正 end

  @Override
  /* upd by chamaojia 2026-03-23 [12462] 患者情報共有->患者経過総合ビューア --start */
  // public List<OrdMain> findByBaseDate(String facilityCd, Long patId, String baseDate, Integer period, Integer pastPeriod) {
  //   return ordMainDao.selectByBaseDate(facilityCd, patId, baseDate, period, pastPeriod);
  public List<OrdMainSharingInfo> findByBaseDate(String facilityCd, Long patId, String baseDate, Integer period, Integer pastPeriod, Integer patShareMode) {
    List<OrdMainSharingInfo> result = new ArrayList<>();
    if (!ObjectUtils.isEmpty(patShareMode) && patShareMode == 0) {
      // 患者の共有データを照会する
      List<OrdMain> ordMainsToShr = ordMainDao.selectByBaseDateToShr(facilityCd, patId, baseDate, period, pastPeriod);
      if (!ObjectUtils.isEmpty(ordMainsToShr)) {
        for(OrdMain ordMain : ordMainsToShr) {
          OrdMainSharingInfo ordMainSharingInfo = new OrdMainSharingInfo();
          BeanUtils.copyProperties(ordMain, ordMainSharingInfo);
          if (facilityCd.equals(ordMainSharingInfo.getFacilityCd())) {
            ordMainSharingInfo.setReadOnly(false);
          } else {
            ordMainSharingInfo.setReadOnly(true);
          }
          result.add(ordMainSharingInfo);
        }
      }
    } else {
      List<OrdMain> list = ordMainDao.selectByBaseDate(facilityCd, patId, baseDate, period, pastPeriod);
      for (OrdMain ordMain : list) {
        OrdMainSharingInfo ordMainSharingInfo = new OrdMainSharingInfo();
        BeanUtils.copyProperties(ordMain, ordMainSharingInfo);
        ordMainSharingInfo.setReadOnly(false);
        result.add(ordMainSharingInfo);
      }
    }

    return result;
  }
  /* upd by chamaojia 2026-03-23 [12462] 患者情報共有->患者経過総合ビューア --end */

  @Override
  public List<OrdMain> findByPastBaseDate(String facilityCd, Long patId, String baseDate, Integer period) {
    return ordMainDao.selectByPastBaseDate(facilityCd, patId, baseDate, period);
  }

  @Override
  public List<OrdMainKurAndTreatmentList> getOrdMainKurAndTreatmentList(String facility_cd, Long pat_id, String dialysis_date_from, String dialysis_date_to, List<Integer> week_pattern, String is_del) {
    return ordMainDao.selectOrdMainKurAndTreatmentList(facility_cd, pat_id, dialysis_date_from, dialysis_date_to, week_pattern, is_del);
  }

  @Override
  public List<SysDataItem> findByCd(String facility_cd, Integer template_no, Integer item_category, Integer item_sub_category) {
    return sysDataItemDao.selectByCd(facility_cd, template_no, item_category, item_sub_category);
  }

  @Override
  public List<OrdMain> findUpdateTarget(Long patId, String facilityCd, String treatDateFrom, String treatDateTo, List<Integer> weeks, List<Integer> treats, List<Long> kurs, String targetDialysisState) {
    return ordMainDao.selectUpdateTarget(patId, facilityCd, treatDateFrom, treatDateTo, weeks, treats, kurs, targetDialysisState);
  }

  /* add by chamaojia 2026-05-18 [12703] 【securify】API診断を実施するとntss-admin-webが落ちる --start */
  @Override
  public List<OrdMain> selectOrdMainForTareOrOffwaterJournal(Long patId, String facilityCd, String treatDateFrom
          , String treatDateTo, List<Integer> weeks, List<Integer> treats, List<Long> kurs, String targetDialysisState) {
    return ordMainDao.selectForTareOrOffwaterJournal(patId, facilityCd, treatDateFrom, treatDateTo
            , weeks, treats, kurs, targetDialysisState);
  }
  /* add by chamaojia 2026-05-18 [12703] 【securify】API診断を実施するとntss-admin-webが落ちる --end */

  @Override
  public List<OrdMain> findUpdateTarget(Long patId, String facilityCd, String treatDateFrom, String treatDateTo, List<Integer> weeks, List<Integer> treats, List<Long> kurs) {
    return ordMainDao.selectUpdateTarget(patId, facilityCd, treatDateFrom, treatDateTo, weeks, treats, kurs, null);
  }
  // add 9664 by kangjie 20231205 start
  @Override
  public List<OrdMain> findUpdateTargetOrdMain(String facilityCd, String treatDateFrom, Integer treatmentCd) {
    return ordMainDao.findUpdateTargetOrdMain(facilityCd,treatDateFrom,treatmentCd);
  }
  // add 9664 by kangjie 20231205 end

  // add #11731_【因島：改良】指示コメント番号の指定方法 start
  // 指示コメント情報（指示コメント番号で集約）の取得
  @Override
  public List<OrdMainIndIndCommentInfo> getIndIndCommentInfo(Long patId, String facilityCd, String treatDateFrom, String treatDateTo, List<Integer> weeks, List<Integer> treats, List<Long> kurs) {
    return ordMainDao.selectIndIndCommentInfo(patId, facilityCd, treatDateFrom, treatDateTo, weeks, treats, kurs);
  }
  // add #11731_【因島：改良】指示コメント番号の指定方法 end

//add 8204 周安寧 start
 @Override
  public List<TreatmentConditionSetting> getTreatmentConditionSetting(Long patId, String facilityCd, String treatDateFrom, String treatDateTo, List<Integer> weeks, List<Integer> treats, List<Long> kurs) {
    return ordMainDao.selectTreatmentConditionSetting(patId, facilityCd, treatDateFrom, treatDateTo, weeks, treats, kurs);
  }
//add 8204 周安寧 end
  @Override
  public List<String> weekPerTreatCdList(Long pat_id, String facility_cd, String dialysis_date_from, String dialysis_date_to, String rst_dialysis_state) {
    return ordMainDao.selectWeekPerTreatCdList(pat_id, facility_cd, dialysis_date_from, dialysis_date_to, rst_dialysis_state);
  }

  ;

  @Override
  @Transactional
  public OrdMain create(OrdMain m) {
    ordMainDao.insert(m);
    OrdMain newOrdMain = ordMainDao.selectByOrdNo(m.getOrdNo());
    triggerUtil.insertTriggerOrdMain(Collections.singletonList(newOrdMain));
    return m;
  }

  @Override
  @Transactional
  public OrdMain update(OrdMain m) {
    // add FNSI-改修内容追加OrdMain履歴 付 start
//      mod 5720 2023-03-06 患者経過総合ビューアにて指示追加時 → 実績反映させる場合に実績の履歴に対象が登録されない。張 start
//    getHistory(m.getOrdNo());
    // mangoDb-update
    // add FNSI-改修内容追加OrdMain履歴 付 end
    // add 6227 張 start
//    copyOrdmainToOrdMainRestore(m.getOrdNo());
    // add 6227 張 end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(m,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    OrdMain oldOrdMain = ordMainDao.selectByOrdNo(m.getOrdNo());
    ordMainDao.update(m);
    getHistory(m.getOrdNo());
    OrdMain newOrdMain = ordMainDao.selectByOrdNo(m.getOrdNo());
    triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain), Collections.singletonList(newOrdMain));
    return m;
  }

  @Override
  @Transactional
//2019.01.29  public long insert(DummyOrdMain ordMain)
  public long insert(OrdMain ordMain) {
//2019.01.29    DummyOrdMain data = dummyOrdMainDao.selectMaxNo();
    OrdMain data = ordMainDao.selectMaxNo();
    long ordNo = data.getOrdNo();
    ordMain.setOrdNo(ordNo);
//2019.01.29    long count = dummyOrdMainDao.insert(ordMain);
    long count = ordMainDao.insert(ordMain);
    if (1 != count) {
      ordNo = -1;
    }
    if (0 < count) {
      ordScheduleDao.insertOrdSchedule(ordMain);
      patIndApproveDao.insert(ordNo, ordMain.getFacilityCd());
    }
    return ordNo;
  }

  /* modify by chamaojia 2023-03-25 [6118] プライマリ・キーを生成する必要があるかどうかの判断条件を追加 --start */
  /* add by chamaojia 2023-03-20 [8101] 新規一括メソッド  --start */
  @Transactional
  public List<OrdMain> insertList(List<OrdMain> ordMainList, boolean useNewOrdNoFlag) {
    List<OrdMain> saveOrdMainList = new ArrayList<>();
    if (useNewOrdNoFlag) {
      for (OrdMain ordMain : ordMainList) {
        OrdMain data = ordMainDao.selectMaxNo();
        long ordNo = data.getOrdNo();
        ordMain.setOrdNo(ordNo);
      }
    }

    /* modify by chamaojia 2023-04-11 [6118] 一括挿入方式の変更 --start */
    // 挿入に単一の成功を返す必要はないと判断します
//    int[] results = ordMainDao.insertList(ordMainList);
//    for (int i = 0; i < ordMainList.size(); i++) {
//      if (results[i] > 0) {
//        saveOrdMainList.add(ordMainList.get(i));
//      } else {
//        ordMainList.get(i).setOrdNo(-1L);
//      }
//    }
    int results = insertBatch(ordMainList);
    if (results > 0) {
      saveOrdMainList.addAll(ordMainList);
    }
    /* modify by chamaojia 2023-04-11 [6118] 一括挿入方式の変更 --end */

    if (!saveOrdMainList.isEmpty()) {

      // #10196 MaterialSave Add by zhou.tao
//      this.ordMaterialSaveService.batchProcessingData(
//        ordMainList.stream().map(
//          ordMain ->
//            ordMaterialSaveService.updateOrdMaterialSaveByDiff(
//              new OrdMaterialSaveDto(
//                ordMain.getOrdNo(),
//                true, true, true, false,
//                OrdMaterialSaveDto.IND_CLASS, ordMain
//              )
//            )
//        ).toList()
//      );

      // Using multi-threads batch generation of records

      // mod #12250 ord_material_saveの処理を2回重複実行している zkm start
//      ordMaterialSaveService.batchProcessingDataMod(
//        asyncMaterialSaveHandlerTask.updateOrdMaterialSaveByDiff(
//          new OrdMaterialSaveBatchHandleDTO(
//            ordMainList.stream().map(OrdMain::getOrdNo).toList(),
//            ordMainList,
//            OrdMaterialSaveBatchHandleDTO.getBatchModifiedMode(
//              true, true, true, false, OrdMaterialSaveDto.IND_CLASS, false
//            )
//          )
//        )
//      );
      ordMaterialSaveService.bulkUpdateByOrdNoInCondMediEquip(ordMainList.stream().map(OrdMain::getOrdNo).toList());
      // mod #12250 ord_material_saveの処理を2回重複実行している zkm end

      ordScheduleDao.insertOrdScheduleList(saveOrdMainList);
      patIndApproveDao.insertList(saveOrdMainList.stream().map(OrdMain::getOrdNo).collect(Collectors.toList())
        , saveOrdMainList.get(0).getFacilityCd());
    }

    return ordMainList;
  }
  /* add by chamaojia 2023-03-20 [8101] 新規一括メソッド  --end */
  /* modify by chamaojia 2023-03-25 [6118] プライマリ・キーを生成する必要があるかどうかの判断条件を追加 --end */


  // add 12250 ord_material_saveの処理を2回重複実行している zkm start
  @Transactional
  public List<OrdMain> insertListWithoutMaterialSave(List<OrdMain> ordMainList, boolean useNewOrdNoFlag) {
    List<OrdMain> saveOrdMainList = new ArrayList<>();
    if (useNewOrdNoFlag) {
      for (OrdMain ordMain : ordMainList) {
        OrdMain data = ordMainDao.selectMaxNo();
        long ordNo = data.getOrdNo();
        ordMain.setOrdNo(ordNo);
      }
    }

    int results = insertBatch(ordMainList);
    if (results > 0) {
      saveOrdMainList.addAll(ordMainList);
    }

    if (!saveOrdMainList.isEmpty()) {
      ordScheduleDao.insertOrdScheduleList(saveOrdMainList);
      patIndApproveDao.insertList(saveOrdMainList.stream().map(OrdMain::getOrdNo).collect(Collectors.toList())
        , saveOrdMainList.get(0).getFacilityCd());
    }
    return ordMainList;
  }
  // add 12250 ord_material_saveの処理を2回重複実行している zkm end

  public int insertBatch(List<OrdMain> ordMainList) {
    int successCount = 0;
    int loopCount = ordMainList.size() / ORD_MAIN_BATCH_INSERT_MAX_LIMIT_NUM;
    for (int i = 0; i <= loopCount; i++) {
      List<OrdMain> saveList;
      if (i == loopCount) {
        saveList = ordMainList.subList(i * ORD_MAIN_BATCH_INSERT_MAX_LIMIT_NUM
          , ordMainList.size());
      } else {
        saveList = ordMainList.subList(i * ORD_MAIN_BATCH_INSERT_MAX_LIMIT_NUM
          , (i + 1) * ORD_MAIN_BATCH_INSERT_MAX_LIMIT_NUM);
      }

      if (!saveList.isEmpty()) {
        successCount = successCount + ordMainDao.insertList(saveList);
      }
    }
    return successCount;
  }
  /* add by chamaojia 2023-04-11 [6118] 一括グループ挿入方法の追加 --end */

//  @Override
//  @Transactional
//  public int delete(Long pat_id, String dialysis_date_from, String dialysis_date_to, List<Integer> treatment_cd, List<Integer> kur_cd) {
//
//    // add FNSI-改修内容追加OrdMain履歴 付 start
//    List<Long> kur = new ArrayList<>();
//    for (Integer integer : kur_cd) {
//      kur.add(integer.longValue());
//    }
//    List<Long> treatmen = new ArrayList<>();
//    for (Integer integer : treatment_cd) {
//      treatmen.add(integer.longValue());
//    }
//    selectHistoryUtils.insertMangoDbHistory(13, null, pat_id, new ArrayList<>(), kur, null, null,
//      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
//      treatmen, dialysis_date_from, dialysis_date_to);
//    // mangoDb-delete-insertSuccess
//    // add FNSI-改修内容追加OrdMain履歴 付 end
//
////2019.01.29    int count = dummyOrdMainDao.delete(null, pat_id, dialysis_date_from, dialysis_date_to, treatment_cd, kur_cd, user_info);
//    // add 6227 張 start
//    List<OrdMain> ordNoList=ordMainDao.selectDelete(null, pat_id, dialysis_date_from, dialysis_date_to, treatment_cd, kur_cd);
//    ordNoList.forEach(item->{
//      copyOrdmainToOrdMainRestore(item.getOrdNo());
//    });
//    // add 6227 張 end
//    int count = ordMainDao.delete(null, pat_id, dialysis_date_from, dialysis_date_to, treatment_cd, kur_cd);
//    return count;
//  }

  @Override
  @Transactional
  public int deleteByOrdNo(List<Long> ordNoList) {

    //modify  by guanyingshuai 2023.02.10  [#6118-optimize runtime]   start
    // add FNSI-改修内容追加OrdMain履歴 付 start
//    selectHistoryUtils.insertMangoDbHistory(3, null, null, ordNoList, new ArrayList<>(), null, null,
//      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
//      new ArrayList<>(), null, null);
    selectHistoryUtils.insertMangoDbHistoryBatch(ordNoList);
    //modify  by guanyingshuai 2023.02.10  [#6118-optimize runtime]   end
    // mangoDb-deleteByOrdNo-insertSuccess
    // add FNSI-改修内容追加OrdMain履歴 付 end
    //add #6227 2022-08-26 ord_mainの削除データ不正 赵鑫宇 start
    // del #6227 2022-08-11 ord_mainの削除データ不正 赵鑫宇 start
    // add 6227 張 start
    List<OrdMainRestore> ordMainRestoreList = new ArrayList<>();
    //add 8008 日次処理のスケジュール自動延長がされない患者が存在する start zhao
    NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    //add 8008 日次処理のスケジュール自動延長がされない患者が存在する end zhao
    /* modify by wangying 2022-10-27[6118] 予定中止ボタンを押下時間問題の修正 --start */
    Timestamp delDate = new Timestamp(System.currentTimeMillis());
     ordNoList.forEach(item->{
//        copyOrdmainToOrdMainRestore(item);
       OrdMain ordMain = selectByOrdNo(item);
       if (ordMain!=null) {
         OrdMainRestore ordMainRestore = new OrdMainRestore();
         BeanUtils.copyProperties(ordMain, ordMainRestore);
         ordMainRestore.setDelDate(delDate);
         //add 8008 日次処理のスケジュール自動延長がされない患者が存在する start zhao
         if (user != null) {
           ordMainRestore.setUpIndUserId(user.getUserId());
           ordMainRestore.setUpUserId(user.getUserId());
         }
         //add 8008 日次処理のスケジュール自動延長がされない患者が存在する end zhao
         ordMainRestoreList.add(ordMainRestore);
//         ordMainRestoreDao.insert(ordMainRestore);
       }
      });
     if (!ordMainRestoreList.isEmpty()) {
       ordMainRestoreDao.insertList(ordMainRestoreList);
     }
    /* modify by wangying 2022-10-27[6118] 予定中止ボタンを押下時間問題の修正 --end */

    // add 6227 張 end
    // del #6227 2022-08-11 ord_mainの削除データ不正 赵鑫宇 end
    //add #6227 2022-08-26 ord_mainの削除データ不正 赵鑫宇 start
    List<OrdMain> oldOrdMains = ordMainDao.selectAllByOrdNoList(ordNoList);
    int count = ordMainDao.deleteByOrdNo(ordNoList);
    triggerUtil.deleteTriggerOrdMain(oldOrdMains);
    if (0 != count) {
      patIndApproveDao.deleteByOrdNoList(ordNoList);
    }
    return count;
  }

  /* add by shiyw 2023-02-21 [#8101] --start */
  @Override
  @Transactional
  public int deleteByOrMainList(List<OrdMain> ordMainList) {
    selectHistoryUtils.insertMangoDbHistoryBatchByOrdMainList(ordMainList);
    List<OrdMainRestore> ordMainRestoreList = new ArrayList<>();
    NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    Timestamp delDate = new Timestamp(System.currentTimeMillis());
    ordMainList.forEach(ordMain->{
      OrdMainRestore ordMainRestore = new OrdMainRestore();
      BeanUtils.copyProperties(ordMain, ordMainRestore);
      ordMainRestore.setDelDate(delDate);
      if (user != null) {
        ordMainRestore.setUpIndUserId(user.getUserId());
        ordMainRestore.setUpUserId(user.getUserId());
      }
      ordMainRestoreList.add(ordMainRestore);
    });
    if (!ordMainRestoreList.isEmpty()) {
      /* mod #6353 by zhangruixue 2023-06-12 --start */
      List<List<OrdMainRestore>> partitionList = Lists.partition(ordMainRestoreList, 100);
      for (List<OrdMainRestore> partition : partitionList) {
        ordMainRestoreDao.insertList(partition);
      }
      /* mod #6353 by zhangruixue 2023-06-12 --end */
    }
    List<OrdMain> oldOrdMains = ordMainList;
    List<Long> ordNoList = oldOrdMains.stream().map(ordMain -> ordMain.getOrdNo()).collect(Collectors.toList());
    int count = ordMainDao.deleteByOrdNo(ordNoList);
    triggerUtil.deleteTriggerOrdMain(oldOrdMains);
    if (0 != count) {

      // #10196 materialSave
      OrdMain optionalOrdMain = ordMainList.stream().findFirst().orElse(new OrdMain());
      this.ordMaterialSaveService.deleteBatchByCondition(
        optionalOrdMain.getFacilityCd(),
        String.valueOf(optionalOrdMain.getPatId()),
        ordNoList,
        null,
        List.of(OrdMaterialSaveDto.IND_CLASS, OrdMaterialSaveDto.RST_CLASS),
        new ArrayList<>()
      );
      patIndApproveDao.deleteByOrdNoList(ordNoList);
    }
    return count;
  }
  /* add by shiyw 2023-02-21 [#8101] --end */

  // mod #11716 曜日パターン変更の不正 関 start
  //modify  by guanyingshuai 2023.02.10  [#6118-optimize runtime]   start
  @Override
  @Transactional
  public int batchDeleteByOrdNo(List<Long> ordNoList) {
    selectHistoryUtils.insertMangoDbHistoryBatch(ordNoList);
    List<OrdMainRestore> ordMainRestoreList = new ArrayList<>();
    NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    Timestamp delDate = new Timestamp(System.currentTimeMillis());

    ordMainRestoreDao.insertListByOrdNoList(ordNoList, user.getUserId(), delDate);

    int count = ordMainDao.deleteByOrdNo(ordNoList);
    String facilityCd = user.getFacilityCd();
    ordScheduleDao.deleteScheduleByOrdNoList(facilityCd, ordNoList);

    if (0 != count) {
      patIndApproveDao.deleteByOrdNoList(ordNoList);
    }
    return count;
  }
  //modify  by guanyingshuai 2023.02.10  [#6118-optimize runtime]   end
  // mod #11716 曜日パターン変更の不正 関 end

  //add #6227 2022-08-26 ord_mainの削除データ不正 赵鑫宇 start
  @Override
  @Transactional
  public int deleteByOrdNoQm(List<Long> ordNoList) {
    selectHistoryUtils.insertMangoDbHistory(3, null, null, ordNoList, new ArrayList<>(), null, null,
      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
      new ArrayList<>(), null, null);
    List<OrdMain> oldOrdMains = ordMainDao.selectAllByOrdNoList(ordNoList);
    int count = ordMainDao.deleteByOrdNo(ordNoList);
    triggerUtil.deleteTriggerOrdMain(oldOrdMains);
    if (0 != count) {
      patIndApproveDao.deleteByOrdNoList(ordNoList);
    }
    return count;
  }
  //add #6227 2022-08-26 ord_mainの削除データ不正 赵鑫宇 end

  @Override
  @Transactional
  public void copyDataById(List<Long> ordNoList) {
    OrdMainRestore ordMainRestore = new OrdMainRestore();
    List<OrdMain> targetOrdMain = ordMainDao.selectAllByOrdNoList(ordNoList);
    //add 8008 日次処理のスケジュール自動延長がされない患者が存在する start zhao
    NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    //add 8008 日次処理のスケジュール自動延長がされない患者が存在する end zhao
    if (targetOrdMain != null && targetOrdMain.size() > 0) {
      Timestamp delDate = new Timestamp(System.currentTimeMillis());
      for (OrdMain ordMain : targetOrdMain) {
        Class<?> ordMainClass = ordMain.getClass();
        Class<?> ordMainRestoreClass = ordMainRestore.getClass();
        Field[] ordMainFields = ordMainClass.getDeclaredFields();
        for (Field f : ordMainFields) {
          Field tempFileld = null;
          try {
            tempFileld = ordMainRestoreClass.getDeclaredField(f.getName());
            tempFileld.setAccessible(true);
            f.setAccessible(true);
            tempFileld.set(ordMainRestore, f.get(ordMain));
          } catch (NoSuchFieldException | IllegalAccessException e) {
            //項目が不一致
          }
        }
        ordMainRestore.setDelDate(delDate);
        //add 8008 日次処理のスケジュール自動延長がされない患者が存在する start zhao
        if (user != null) {
          ordMainRestore.setUpIndUserId(user.getUserId());
          ordMainRestore.setUpUserId(user.getUserId());
        }
        //add 8008 日次処理のスケジュール自動延長がされない患者が存在する end zhao
        ordMainRestoreDao.insert(ordMainRestore);
      }
    }
  }

  @Override
  @Transactional
  public int copyData(OrdMain m) {
    OrdMain oldOrdMain = ordMainDao.selectByOrdNo(m.getOrdNo());
    //add #9289 直近の過去指示(投与薬剤を含まない)を使った治療予定作成時にエラー発生 zy start
    OrdMain OrdMain =ordMainDao.selectMaxNo();
    long newNO = OrdMain.getOrdNo();
    m.setOrdNo(newNO);
    //add #9289 直近の過去指示(投与薬剤を含まない)を使った治療予定作成時にエラー発生 zy end
    //add 10860 ind_schedule_user_infoのデータ不正 zhao start
    JSONObject indScheduleUserInfoObject = new JSONObject(m.getIndScheduleUserInfo());
    indScheduleUserInfoObject.put("ind_kur_cd_before",JSONObject.NULL);
    indScheduleUserInfoObject.put("ind_treat_start_time_before",JSONObject.NULL);
    m.setIndScheduleUserInfo(indScheduleUserInfoObject.toString());
    //add 10860 ind_schedule_user_infoのデータ不正 zhao end
    int insertCount = ordMainDao.copyData(m);
    OrdMain newOrdMain = ordMainDao.selectByOrdNo(m.getOrdNo());
    triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain), Collections.singletonList(newOrdMain));

    return insertCount;
  }

  /**
   * move data proc
   *
   * @param ordMain          order no
   * @param indScheduleUserInfo moving distination of dialysis date
   */
  @Override
  @Transactional
  public int moveDataToIndDate(
    OrdMain ordMain,
    String indScheduleUserInfo) {

    // add FNSI-改修内容追加OrdMain履歴 付 start
//    getHistory(ordMain.getOrdNo());
    // mangoDb-moveDataToIndDate-insertSuccess
    // add FNSI-改修内容追加OrdMain履歴 付 end
    // add 6227 張 start
//    copyOrdmainToOrdMainRestore(ordMain.getOrdNo());
    // add 6227 張 end
    OrdMain oldOrdMain = ordMainDao.selectByOrdNo(ordMain.getOrdNo());
    int updateCount = ordMainDao.moveDataToIndDate(
      ordMain,
      indScheduleUserInfo);
    OrdMain newOrdMain = ordMainDao.selectByOrdNo(ordMain.getOrdNo());
    triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain), Collections.singletonList(newOrdMain));
    getHistory(ordMain.getOrdNo());
    // add FNSI-障害票一覧_患者経過総合ビューアNo.22-27 李 start
    if ("0".equals(ordMain.getRstDialysisState())) {
      OrdMain oldOrdMain2 = ordMainDao.selectByOrdNo(ordMain.getOrdNo());
      ordMainDao.moveDataToIndDateCanel(ordMain);
      OrdMain newOrdMain2 = ordMainDao.selectByOrdNo(ordMain.getOrdNo());
      triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain2), Collections.singletonList(newOrdMain2));

    }
    // add FNSI-障害票一覧_患者経過総合ビューアNo.22-27 李 end

    if (1 == updateCount) {
      PatIndApprove patIndApprove = new PatIndApprove();
      patIndApprove.setOrd_no(ordMain.getOrdNo());

      try {
        updateContentChangeSingleWithNotification(ordMain.getOrdNo(), patIndApprove);
      } catch (Exception e) {
      }

    }

    return updateCount;
  }

  // mod #10196 rst=456 move Treatment plan ztc 20240304 start
  /**
   * move data proc
   *
   * @param ordMain          order no
   * @param indScheduleUserInfo moving distination of dialysis date
   */
  @Override
  @Transactional
  public int moveDataToIndDateOfRst(OrdMain ordMain, String indScheduleUserInfo) {
    OrdMain oldOrdMain = ordMainDao.selectByOrdNo(ordMain.getOrdNo());
    int updateCount = ordMainDao.moveDataToIndDateOfRst(ordMain, indScheduleUserInfo);
    OrdMain newOrdMain = ordMainDao.selectByOrdNo(ordMain.getOrdNo());
    triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain), Collections.singletonList(newOrdMain));
    getHistory(ordMain.getOrdNo());
    if (1 == updateCount) {
      PatIndApprove patIndApprove = new PatIndApprove();
      patIndApprove.setOrd_no(ordMain.getOrdNo());
      try {
        updateContentChangeSingleWithNotification(ordMain.getOrdNo(), patIndApprove);
      } catch (Exception e) {
      }
    }
    return updateCount;
  }
  // mod #10196 rst=456 move Treatment plan ztc 20240304 end

  @Override
  @Transactional
  public int updateTreatMethod(String treatItemCd, List<Integer> ordNo) {

    // add FNSI-改修内容追加OrdMain履歴 付 start
    List<Long> ordList = new ArrayList<>();
    for (Integer integer : ordNo) {
      ordList.add(integer.longValue());
    }
//    selectHistoryUtils.insertMangoDbHistory(3, null, null, ordList, new ArrayList<>(), null, null,
//      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
//      new ArrayList<>(), null, null);
    // mangoDb-updateTreatMethod-insertSuccess
    // add FNSI-改修内容追加OrdMain履歴 付 end

    // DB更新ログ出力ロジック wangzuo Start
    String tableName = "ord_main";
    // SQL検索条件
    String inStr = getInStr("ord_no in ", ordNo);
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(inStr + "\n");
    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(ordMainDao, tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    // DB更新ログ出力ロジック wangzuo End
    // add 6227 張 start
//    copyOrdmainToOrdMainRestore(Long.valueOf(ordNo.toString()));
    // add 6227 張 end
    List<Long> updateOrdNos = new ArrayList<>();
    ordNo.forEach(o -> updateOrdNos.add(Long.parseLong(String.valueOf(o == null ? 0 : o))));
    List<OrdMain> oldOrdMains = ordMainDao.selectAllByOrdNoList(updateOrdNos);
    int updateCount = ordMainDao.updateTreatMethod(treatItemCd, ordNo);
    List<OrdMain> newOrdMains = ordMainDao.selectAllByOrdNoList(updateOrdNos);
    triggerUtil.updateTriggerOrdMain(oldOrdMains, newOrdMains);
    selectHistoryUtils.insertMangoDbHistory(3, null, null, ordList, new ArrayList<>(), null, null,
      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
      new ArrayList<>(), null, null);
    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --start */
      logCommon.setAfterResults();
//      logCommon.updateLog();
      asyncService.updateLog(logCommon);
      /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --end */
    }
    // DB更新ログ出力ロジック wangzuo End

    return 0;
  }

//  @Override
//  @Transactional
//  public int updateCommentInfo(Long ordNo, String commentInfo, String isRstUpdate) {
//
//    // add FNSI-改修内容追加OrdMain履歴 付 start
//    getHistory(ordNo);
//    // mangoDb-updateCommentInfo-insertSuccess
//    // add FNSI-改修内容追加OrdMain履歴 付 end
//    // add 6227 張 start
////    copyOrdmainToOrdMainRestore(ordNo);
//    // add 6227 張 end
//    // mod FNSI-【1006】最新の改修対象一覧のIES475対応 韓 start
//    int updateCount = 0;
//    if ("true".equals(isRstUpdate)) {
//      updateCount = ordMainDao.updateCommentInfo(
//        ordNo, commentInfo);
//    } else {
//      updateCount = ordMainDao.updateIndCommentInfo(
//        ordNo, commentInfo);
//    }
//    // mod FNSI-【1006】最新の改修対象一覧のIES475対応 韓 end
//    // 更新件数が0件の場合はロールバック
//    if (0 == updateCount) {
//      throw new RuntimeException("指示コメントの更新に失敗しました");
//    }
//    PatIndApprove patIndApprove = new PatIndApprove();
//    patIndApprove.setOrd_no(ordNo);
//
//    try {
//      updateContentChangeSingleWithNotification(ordNo, patIndApprove);
//    } catch (Exception e) {
//    }
//
//    return updateCount;
//  }

//  @Override
//  @Transactional
// // add キャンセル（実績に反映しない）を選択　⇒　実績に反映される修正  xmj 2022-08-11 start
//  public int deleteCommentInfo(Long ordNo, String commentInfo, Boolean isNewRegistration,String isRstUpdate) {
//
//    // add FNSI-改修内容追加OrdMain履歴 付 start
//    getHistory(ordNo);
//    // mangoDb-deleteCommentInfo-insertSuccess
//    // add FNSI-改修内容追加OrdMain履歴 付 end
//
//    // add 6227 張 start
////    copyOrdmainToOrdMainRestore(ordNo);
//    // add 6227 張 end
//    int updateCount = ordMainDao.deleteCommentInfo(
//      ordNo, commentInfo,isRstUpdate);
// // add キャンセル（実績に反映しない）を選択　⇒　実績に反映される修正  xmj 2022-08-11 end
//    // 更新件数が0件の場合はロールバック
//    if (0 == updateCount) {
//      throw new RuntimeException("指示コメントの更新に失敗しました");
//    }
//    PatIndApprove patIndApprove = new PatIndApprove();
//    patIndApprove.setOrd_no(ordNo);
//
//    if (isNewRegistration) {
//      // 新規登録時：通知せず指示受け・承認テーブルを更新
//      patIndApproveDao.updateContentChange(patIndApprove);
//    } else {
//      // 削除時：通知+指示受け・承認テーブルを更新
//      try {
//        updateContentChangeSingleWithNotification(ordNo, patIndApprove);
//      } catch (Exception e) {
//      }
//    }
//    return updateCount;
//  }

  @Override
  @Transactional
  /**
   * {@inheritDoc}
   */
  public Boolean updateOrdMainScheduleInfo(
    List<Long> ordNoList,
    Long indKurCd,
    String indKurName,
    String indTreatStartTime,
    Long indBedCd,
    String indBedName,
    Long indUserId,
    Long updUserid,
    Integer updateMode,
    // add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.79(外結)対応 韓 start
    boolean rstUpdFlg) {
    // add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.79(外結)対応 韓 end
    try {

      // add FNSI-改修内容追加OrdMain履歴 付 start
//      selectHistoryUtils.insertMangoDbHistory(3, null, null, ordNoList, new ArrayList<>(), null, null,
//        null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
//        new ArrayList<>(), null, null);
      // mangoDb-updateOrdMainScheduleInfo-insertSuccess
      // add FNSI-改修内容追加OrdMain履歴 付 end
      // mod FNSI-指示編集でDB登録データの更新 楊 start
      /* mod #5482 by zhangruixue 2023-03-03 スケジュール --start */
//      MstPersonalUser user = mstPersonalUserDao.selectById(indUserId.longValue());
      MstPersonalUser user = MasterCacheHandler.get().getMstPersonalUser(indUserId.longValue());
      // add 10196 by kangjie 20240122 start
      MstPersonalUser updUser = mstPersonalUserDao.selectById(updUserid);
      // add 100196 by kangjie 20240122 end
      /* mod #5482 by zhangruixue 2023-03-03 スケジュール --start */
      // mod FNSI-指示編集でDB登録データの更新 楊 end
      // メインスケジュール更新
      // add 6227 張 start
//      ordNoList.forEach(item->{
//        copyOrdmainToOrdMainRestore(item);
//      });
      // add 6227 張 end
      List<OrdMain> oldOrdMains = ordMainDao.selectAllByOrdNoList(ordNoList);
      int updateCount = ordMainDao.updateOrdMainScheduleInfo(
        ordNoList,
        indKurCd,
        indKurName,
        indTreatStartTime,
        indBedCd,
        indBedName,
        indUserId,
        updUserid,
        // mod FNSI-指示編集でDB登録データの更新 楊 start
        user.getUserLastName(),
        user.getUserFirstName(),
        // add 100196 by kangjie 20240122 start
        updUser.getUserLastName(),
        updUser.getUserFirstName(),
        // add 100196 by kangjie 20240122 end
        // mod FNSI-指示編集でDB登録データの更新 楊 end
        updateMode,
        // add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.79(外結)対応 韓 start
        rstUpdFlg);
      List<OrdMain> newOrdMains = ordMainDao.selectAllByOrdNoList(ordNoList);
      triggerUtil.updateTriggerOrdMain(oldOrdMains, newOrdMains);
        // add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.79(外結)対応 韓 end
      selectHistoryUtils.insertMangoDbHistory(3, null, null, ordNoList, new ArrayList<>(), null, null,
        null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
        new ArrayList<>(), null, null);
      if (0 == updateCount) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("スケジュール更新に失敗しました(更新対象オーダ番号リスト=" + ordNoList + ")");
        eventLogMessage.setSqlIdentification(
          "(ordNoList = " + ordNoList + ", indKurCd = " + indKurCd + ", indKurName = " + indKurName + ", indTreatStartTime = " + indTreatStartTime
            + ", indBedCd = " + indBedCd + ", indBedName = " + indBedName + ", indUserId = " + indUserId + ", updUserid = " + updUserid
            + ", updateMode = " + updateMode + ")");
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS,
          "OrdMainDao/updateOrdMainScheduleInfo");
        return false;
      }
      // DB更新ログ出力ロジック wangzuo Start
      String tableName = "pat_ind_approve";
      // SQL検索条件
      String inStr = getInStr("ord.ord_no IN ", ordNoList);
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append("ord_no IN (" + "\n");
      wheres.append("SELECT ord.ord_no" + "\n");
      wheres.append("FROM ord_main as ord" + "\n");
      wheres.append("JOIN mst_facility_setting as setting" + "\n");
      wheres.append("ON ord.facility_cd = setting.facility_cd" + "\n");
      wheres.append("WHERE" + "\n");
      wheres.append(inStr + "\n");
      wheres.append("AND setting.facility_setting_no = '1022'" + "\n");
      wheres.append("AND value = '1')" + "\n");
      // logCommon設定
      DataUpdateLogCommonNew logCommon = getLogCommon(patIndApproveDao, tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResult = logCommon.setInfo();
      // DB更新ログ出力ロジック wangzuo End
      int patUpdateCount = updateContentChangeListByBedControlWithNotification(ordNoList, new PatIndApprove());
      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && patUpdateCount > 0) {
        /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --start */
        logCommon.setAfterResults();
//        logCommon.updateLog();
        asyncService.updateLog(logCommon);
        /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --end */
      }
      // DB更新ログ出力ロジック wangzuo End

    } catch (Exception e) {
      // ロールバック実行
      throw new RuntimeException(e.getMessage());
    }

    return true;
  }

  /* modify by chamaojia 2023-10-27 [9973] A針/V針とSN針の排他条件追加  --start */
  @Override
  @Transactional
  // mod 10495 無期限治療条件変更時のpat_treatment_patternの更新バグ 関  start
  // public int updateOrdMainInfo(List<Long> ord_no, String ord_info, Long up_ind_user_id, Long up_user_id, Map<Long, JSONObject> coagulantInfo, String needExcludeItem) {
  public int updateOrdMainInfo(List<Long> ord_no, String ord_info, Long up_ind_user_id, Long up_user_id, Map<Long, JSONObject> coagulantInfo, String needExcludeItem, Long patId) {
    // mod 10495 無期限治療条件変更時のpat_treatment_patternの更新バグ 関  end
    // add 10150_9664 by kangjie 20240830 start
    JSONObject updateDataJSON = new JSONObject(ord_info);
    sameCategoryFluidComponent.removeFluidDataCommon(updateDataJSON);
    // add 10150_9664 by kangjie 20240830 end

    /** modify by wangying 2022-10-31[6118]　治療指示変更時間問題の修正 -- start */
    // add FNSI-改修内容追加OrdMain履歴 付 start
//    selectHistoryUtils.insertMangoDbHistory(3, null, null, ord_no, new ArrayList<>(), null, null,
//      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
//      new ArrayList<>(), null, null);
    // mangoDb-updateOrdMainInfo-insertSuccess
    // add FNSI-改修内容追加OrdMain履歴 付 end
//    selectHistoryUtils.insertMangoDbHistoryBatch(ord_no);
    /** modify by wangying 2022-10-31[6118]　治療指示変更時間問題の修正 -- end */

    // DB更新ログ出力ロジック wangzuo Start
    String tableNameOrdMainDao = "ord_main";
    // SQL検索条件
    StringBuffer wheresOrdMainDao = new StringBuffer("");
    wheresOrdMainDao.append(" WHERE ord_no in (" + getIntegerValueStr(ord_no) +") \n");
    // logCommon設定
    DataUpdateLogCommonNew logCommonOrdMainDao = getLogCommon(ordMainDao, tableNameOrdMainDao, wheresOrdMainDao, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResultOrdMainDao = logCommonOrdMainDao.setInfo();
    // DB更新ログ出力ロジック wangzuo End
    // add 6227 張 start
//    ord_no.forEach(item->{
//      copyOrdmainToOrdMainRestore(item);
//    });
    // add 6227 張 end
    // TODO: 2023/6/13  循环 ordNo修改indCountInfo key=28的值
    // mode kang start
    AtomicInteger updateCount = new AtomicInteger();
    if (null != coagulantInfo) {
      coagulantInfo.forEach((key,value)->{
        // mode 10150_9664 by kangjie 20240830 start
//        JSONObject jsonObject = new JSONObject(ord_info);
        JSONObject jsonObject = new JSONObject(updateDataJSON.toString());
        // mode 10150_9664 by kangjie 20240830 end
        jsonObject.put("28",value);
        List<Long> ordNoList = new ArrayList<>();
        ordNoList.add(key);
        updateCount.set(ordMainDao.updateOrdMainInfo(ordNoList, jsonObject.toString(), up_ind_user_id, up_user_id, needExcludeItem));
      });
    } else {
      // mod 10495 無期限治療条件変更時のpat_treatment_patternの更新バグ 関  start
      /* modify by chamaojia 2023-04-06 [8537、8476、6118] 新しい処理を呼び出し、sqlが最適化されました  --start */
      // updateCount.set(ordMainDao.updateOrdMainInfoByOrdNos(ord_no, ord_info, up_ind_user_id, up_user_id, needExcludeItem));
      /* modify by chamaojia 2023-04-06 [8537、8476、6118] 新しい処理を呼び出し、sqlが最適化されました  --end */
      // mod 10443 身体情報・DW・目標体重バグ 関 start
      // mode 10150_9664 by kangjie 20240830 start
//      JSONObject editOrdInfo = new JSONObject(ord_info);
      JSONObject editOrdInfo = new JSONObject(updateDataJSON.toString());
      // mode 10150_9664 by kangjie 20240830 end

      JSONObject indDwUserInfo = new JSONObject();
      if (editOrdInfo.has("39")) {
        indDwUserInfo.put("ind_user_id", editOrdInfo.getJSONObject("39").get("ind_user_id"));
        indDwUserInfo.put("ind_user_last_name", editOrdInfo.getJSONObject("39").get("ind_user_last_name"));
        indDwUserInfo.put("ind_user_first_name", editOrdInfo.getJSONObject("39").get("ind_user_first_name"));

        indDwUserInfo.put("upd_user_id", editOrdInfo.getJSONObject("39").get("upd_user_id"));
        indDwUserInfo.put("upd_user_last_name", editOrdInfo.getJSONObject("39").get("upd_user_last_name"));
        indDwUserInfo.put("upd_user_first_name", editOrdInfo.getJSONObject("39").get("upd_user_first_name"));
      }
      // mode 10150_9664 by kangjie 20240830 start
//      int count = ordMainDao.updateOrdMainInfoByOrdNos(ord_no, ord_info, up_ind_user_id, up_user_id, needExcludeItem, patId, indDwUserInfo.toString());
      int count = ordMainDao.updateOrdMainInfoByOrdNos(ord_no, updateDataJSON.toString(), up_ind_user_id, up_user_id, needExcludeItem, patId, indDwUserInfo.toString());
      // mode 10150_9664 by kangjie 20240830 end
      if (editOrdInfo.has("12") && !editOrdInfo.getJSONObject("12").isNull("value")) {
        String needleSelectionVal = String.valueOf(
          editOrdInfo.getJSONObject(TreatmentItemsDef.T_I_NEEDLE_SELECTION.getItemCode()).get("value")
        );
        if ("1".equals(needleSelectionVal)) {
          editOrdInfo.remove("9");
          editOrdInfo.remove("10");
        }
      }
      editOrdInfo.remove("12");
      editOrdInfo.remove("11");
      count = count + ordMainDao.updateOrdMainInfoByOrdNosAndPatId(ord_no, editOrdInfo.toString(), up_ind_user_id, up_user_id, patId, indDwUserInfo.toString());
      // mod 10443 身体情報・DW・目標体重バグ 関 end
      updateCount.set(count);
    }
    // mod 10495 無期限治療条件変更時のpat_treatment_patternの更新バグ 関  end
    // mode kang end

    //add #11841 【たくしん会】ord_mainの登録不正 zrx start
    if(ord_no != null && !ord_no.isEmpty()) {
      ordMainDao.updateOrdMainInfoDelJsonByOrdNos(ord_no);
    }
    //add #11841 【たくしん会】ord_mainの登録不正 zrx end

    selectHistoryUtils.insertMangoDbHistoryBatch(ord_no);
    List<OrdMain> newOrdMains = ordMainDao.selectAllByOrdNoList(ord_no);
    /* modify by chamaojia 2023-03-07 [6118] 新しいバッチ処理を呼び出す方法  --start */
    triggerUtil.insertListTriggerOrdMain(newOrdMains);
    /* modify by chamaojia 2023-03-07 [6118] 新しいバッチ処理を呼び出す方法  --end */

    // #10196 Add by Zhou.tao Start
    // 計算材料保持
    // mod 12250 ord_material_saveの処理を2回重複実行している zkm start
//    List<MaterialSaveCacheHandler.DiffResultContainer> diffMaterialSaveRstList = new LinkedList<>();
//    for (OrdMain ord : newOrdMains) {
//      MaterialSaveCacheHandler.DiffResultContainer diffMaterialSaveRst =
//        ordMaterialSaveService.updateOrdMaterialSaveByDiff(
//          new OrdMaterialSaveDto(
//            ord.getOrdNo(),
//            true,
//            false,
//            false,
//            false,
//            OrdMaterialSaveDto.IND_CLASS,
//            ord
//          )
//        );
//      diffMaterialSaveRstList.add(diffMaterialSaveRst);
//    }
//    if (!diffMaterialSaveRstList.isEmpty()) ordMaterialSaveService.batchProcessingData(diffMaterialSaveRstList);
    if (CollectionUtils.isNotEmpty(newOrdMains)) {
      ordMaterialSaveService.bulkUpdateByOrdNoInCond(newOrdMains.stream().map(OrdMain::getOrdNo).toList());
    }
    // mod 12250 ord_material_saveの処理を2回重複実行している zkm end
    // #10196 Add by Zhou.tao End

    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResultOrdMainDao && updateCount.get() > 0) {
      /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --start */
      logCommonOrdMainDao.setAfterResults();
//       logCommonOrdMainDao.updateLog();
      asyncService.updateLog(logCommonOrdMainDao);
      /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --end */
    }
    // DB更新ログ出力ロジック wangzuo End
    if (0 != updateCount.get()) {

      // DB更新ログ出力ロジック wangzuo Start
      String tableName = "pat_ind_approve";
      // SQL検索条件
      String inStr = getInStr("ord_no in ", ord_no);
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(inStr + "\n");
      // logCommon設定
      DataUpdateLogCommonNew logCommon = getLogCommon(patIndApproveDao, tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResult = logCommon.setInfo();
      // DB更新ログ出力ロジック wangzuo End


      int patUpdateCount = 0;
      try {
        patUpdateCount = updateContentChangeListWithNotification(ord_no, new PatIndApprove());
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

      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && patUpdateCount > 0) {
        /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --start */
        logCommon.setAfterResults();
//        logCommon.updateLog();
        asyncService.updateLog(logCommon);
        /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --end */
      }
      // DB更新ログ出力ロジック wangzuo End
    }
    return updateCount.get();
  }
  /* modify by chamaojia 2023-10-27 [9973] A針/V針とSN針の排他条件追加  --end */

  ;

  /**
  * @Author kangjie
  * @Description
  * @Date 2024/08/30 11:48
  * @Param [fluidSpeedAndAmountEntities]
  * @return 10150_9664
  **/
  @Override
  public int updateFluidSpeedAndAmount(List<FluidSpeedAndAmountEntity> fluidSpeedAndAmountEntities, boolean rstDialysisState) {
    return ordMainDao.updateFluidSpeedAndAmount(fluidSpeedAndAmountEntities,rstDialysisState);
  }

  @Override
  @Transactional
  public int updateRstOrdMainInfo(List<Long> ord_no, String rst_info, String needExcludeItem) {

    // add FNSI-改修内容追加OrdMain履歴 付 start
//    selectHistoryUtils.insertMangoDbHistory(3, null, null, ord_no, new ArrayList<>(), null, null,
//      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
//      new ArrayList<>(), null, null);
    // mangoDb-updateRstOrdMainInfo-insertSuccess
    // add FNSI-改修内容追加OrdMain履歴 付 end
    // add 6227 張 start
//    ord_no.forEach(item->{
//      copyOrdmainToOrdMainRestore(item);
//    });
    // add 6227 張 end
    /* modify by chamaojia 2023-11-29 [9973] A針/V針とSN針の排他条件追加  --start */
    int updateCount = ordMainDao.updateRstOrdMainInfo(ord_no, rst_info, needExcludeItem);
    /* modify by chamaojia 2023-11-29 [9973] A針/V針とSN針の排他条件追加  --end */
    selectHistoryUtils.insertMangoDbHistory(3, null, null, ord_no, new ArrayList<>(), null, null,
      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
      new ArrayList<>(), null, null);
    List<OrdMain> newOrdMains = ordMainDao.selectAllByOrdNoList(ord_no);
    triggerUtil.updateOrdMainTriggerForOrdScheduleInsert(newOrdMains);

    // #10196 Add by Zhou.tao Start
    // 計算材料保持
    // mod 12250 ord_material_saveの処理を2回重複実行している zkm start
//    List<MaterialSaveCacheHandler.DiffResultContainer> diffMaterialSaveRstList = new LinkedList<>();
//    for (OrdMain ord : newOrdMains) {
//      MaterialSaveCacheHandler.DiffResultContainer diffMaterialSaveRst =
//        ordMaterialSaveService.updateOrdMaterialSaveByDiff(
//          new OrdMaterialSaveDto(
//            ord.getOrdNo(),
//            true,
//            false,
//            false,
//            false,
//            OrdMaterialSaveDto.RST_CLASS,
//            ord
//          )
//        );
//      diffMaterialSaveRstList.add(diffMaterialSaveRst);
//    }
//    if (!diffMaterialSaveRstList.isEmpty()) ordMaterialSaveService.batchProcessingData(diffMaterialSaveRstList);
    if (CollectionUtils.isNotEmpty(newOrdMains)) {
      ordMaterialSaveService.bulkUpdateByOrdNoInCondMediEquip(newOrdMains.stream().map(OrdMain::getOrdNo).toList());
    }
    // mod 12250 ord_material_saveの処理を2回重複実行している zkm end
    // #10196 Add by Zhou.tao End

    if (0 != updateCount) {

      // DB更新ログ出力ロジック wangzuo Start
      String tableName = "pat_ind_approve";
      // SQL検索条件
      String inStr = getInStr("ord_no in ", ord_no);
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(inStr + "\n");
      // logCommon設定
      DataUpdateLogCommonNew logCommon = getLogCommon(patIndApproveDao, tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResult = logCommon.setInfo();
      // DB更新ログ出力ロジック wangzuo End

      int patUpdateCount = patIndApproveDao.updateContentChangeList(ord_no, new PatIndApprove());

      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && patUpdateCount > 0) {
        /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --start */
        logCommon.setAfterResults();
//        logCommon.updateLog();
        asyncService.updateLog(logCommon);
        /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --end */
      }
      // DB更新ログ出力ロジック wangzuo End
    }
    return updateCount;
  }

  ;

//  @Override
//  @Transactional
//  public int updateOrdMainEquipInfo(
//    Long ord_no,
//    String ord_info,
//    String rst_info) {
//
//    // add FNSI-改修内容追加OrdMain履歴 付 start
//    getHistory(ord_no);
//    // mangoDb-updateOrdMainEquipInfo-insertSuccess
//    // add FNSI-改修内容追加OrdMain履歴 付 end
//
//    // DB更新ログ出力ロジック wangzuo Start
//    String tableName = "ord_main";
//    // SQL検索条件
//    StringBuffer wheres = new StringBuffer("");
//    wheres.append(" WHERE\n");
//    wheres.append(" ord_no = " + ord_no + "\n");
//    // logCommon設定
//    DataUpdateLogCommonNew logCommon = getLogCommon(ordMainDao, tableName, wheres, getEventLogMessage());
//    // ログ出力カラム情報及び更新前データ情報取得
//    boolean setResult = logCommon.setInfo();
//    // DB更新ログ出力ロジック wangzuo End
//    // add 6227 張 start
////    copyOrdmainToOrdMainRestore(ord_no);
//    // add 6227 張 end
//
//    int updateCount = ordMainDao.updateOrdMainEquipInfo(
//      ord_no,
//      ord_info,
//      rst_info);
//
//    // DB更新ログ出力ロジック wangzuo Start
//    // 更新後データ取得、差分あれば、log出力
//    if (setResult && updateCount > 0) {
//      //logCommon.updateLog();
//      asyncService.updateLog(logCommon);
//    }
//    // DB更新ログ出力ロジック wangzuo End
//
//    PatIndApprove patIndApprove = new PatIndApprove();
//    patIndApprove.setOrd_no(ord_no);
//
//    try {
//      updateContentChangeSingleWithNotification(ord_no, patIndApprove);
//    } catch (Exception e) {
//    }
//
//    return updateCount;
//  }

  // add FNSI-改修内容追加OrdMain履歴 付 start
  private void getHistory(Long ordNo) {
    selectHistoryUtils.insertMangoDbHistory(1, ordNo, null, new ArrayList<>(), new ArrayList<>(), null, null,
      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
      new ArrayList<>(), null, null);
  }

  //upd by ztc 2023-03-20 Treatment method change branch 2, 3 optimization --start /
  private void getListByMode1History(List<Long> ordNos) {
    selectHistoryUtils.insertMangoDbHistory(1, null, null, ordNos, new ArrayList<>(), null, null,
      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
      new ArrayList<>(), null, null);
  }
  //upd by ztc 2023-03-20 Treatment method change branch 2, 3 optimization --end /
  // add FNSI-改修内容追加OrdMain履歴 付 end

//  @Override
//  @Transactional
//  public int updateOrdMainMediInfo(
//    Long ord_no,
//    String ord_info,
//    String rst_info,
//    Boolean log_update_flg) {
//    // add FNSI-改修内容追加OrdMain履歴 付 start
//    getHistory(ord_no);
//    // mangoDb-updateOrdMainMediInfo-insertSuccess
//    // add FNSI-改修内容追加OrdMain履歴 付 end
//    // add 6227 張 start
////    copyOrdmainToOrdMainRestore(ord_no);
//    // add 6227 張 end
//
//    int updateCount = ordMainDao.updateOrdMainMediInfo(
//      ord_no,
//      ord_info,
//      rst_info);
//
//    // mod FNSI-FutreNetWeb+SI課題管理No.5686 李 start
//    if (log_update_flg) {
//      // DB更新ログ出力ロジック wangzuo Start
//      String tableName = "ord_main";
//      // SQL検索条件
//      StringBuffer wheres = new StringBuffer("");
//      wheres.append(" WHERE\n");
//      wheres.append(" ord_no = " + ord_no + "\n");
//      // logCommon設定
//      DataUpdateLogCommonNew logCommon = getLogCommon(ordMainDao, tableName, wheres, getEventLogMessage());
//      // ログ出力カラム情報及び更新前データ情報取得
//      boolean setResult = logCommon.setInfo();
//      // DB更新ログ出力ロジック wangzuo End
//
//      // DB更新ログ出力ロジック wangzuo Start
//      // 更新後データ取得、差分あれば、log出力
//      if (setResult && updateCount > 0) {
//        //logCommon.updateLog();
//        asyncService.updateLog(logCommon);
//      }
//      // DB更新ログ出力ロジック wangzuo End
//    }
//    // mod FNSI-FutreNetWeb+SI課題管理No.5686 李 end
//
//    if (0 != updateCount) {
//      PatIndApprove patIndApprove = new PatIndApprove();
//      patIndApprove.setOrd_no(ord_no);
//      try {
//        updateContentChangeSingleWithNotification(ord_no, patIndApprove);
//      } catch (Exception e) {
//      }
//
//    }
//    return updateCount;
//  }

  @Override
  @Transactional
  public void delete(Long ord_no, Integer edition) {
    List<OrdMain> m = ordMainDao.selectByCd(null, null, null, ord_no, edition, null);
    if (m != null) {
      for (int i = 0; i < m.size(); i++) {

        // add FNSI-改修内容追加OrdMain履歴 付 start
        selectHistoryUtils.insertMangoDbHistory(13, m.get(i).getOrdNo(), null, new ArrayList<>(), new ArrayList<>(), null, null,
          null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
          new ArrayList<>(), null, null);
        // mangoDb-delete-insertSuccess
        // add FNSI-改修内容追加OrdMain履歴 付 end
        // add 6227 張 start
           // modify by shiyw 20230205 for [#8101] 患者経過総合応答速度の最適化です start
        //copyOrdmainToOrdMainRestore(m.get(i).getOrdNo());
        copyOrdmainToOrdMainRestore(m.get(i));
           // modify by shiyw 20230205 for [#8101] 患者経過総合応答速度の最適化です end
        // add 6227 張 end
        OrdMain oldOrdMain = ordMainDao.selectByOrdNo(m.get(i).getOrdNo());
        ordMainDao.delete(m.get(i));
        triggerUtil.deleteTriggerOrdMain(Collections.singletonList(oldOrdMain));
      }
    }
  }

  @Override
  @Transactional
  public List<OrdMain> findByTreatItemCd(String pat_id, String dialysis_date_from, String dialysis_date_to,
                                         List<Integer> weeks_array, String kur_cd, String treat_item_cd_before, Integer edition, String is_del) {
    return ordMainDao.selectByTreatItemCd(pat_id, dialysis_date_from, dialysis_date_to, weeks_array, kur_cd, treat_item_cd_before, edition, is_del);
  }

  @Override
   public long selectMaxIndMediInfoNo() {
   return ordMainDao.selectMaxIndMediInfoNo();
   }

  @Override
  // add FNSI-投薬最新識別番号の設定 李 start
  public long selectMaxMediInfoNo(String facilityCd, String patId) {
    // mod #12471 投薬最新識別番号の設定 zkm start
//    // 投薬最新識別番号の取得
//    long mediInfoNo = ordMainDao.selectIndMediInfoNo(facilityCd, patId);
//    // 識別番号が取得する場合
////    mod 8189 【デグレ】新規患者の初回の治療予定作成以降の治療予定作成ができない 関 start
////    if (mediInfoNo > 0) {
//    if (mediInfoNo >= 0) {
////    mod 8189 【デグレ】新規患者の初回の治療予定作成以降の治療予定作成ができない 関  end
//      long maxMediInfoNo = mediInfoNo + 1;
//      // 投薬最新識別番号の更新
//      ordMainDao.updateIndMediInfoNo(facilityCd, patId, maxMediInfoNo);
//      return maxMediInfoNo;
//    // 識別番号が取得しない場合
//    } else {
//      // 投薬最新識別番号の登録
//      //mod 8151 選択したものと異なる薬剤の指示編集画面が表示する。 張 start
////      ordMainDao.insertIndMediInfoNo(facilityCd, patId);
//      ordMainDao.insertIndMediInfoNo(facilityCd, patId,1);
//      //mod 8151 選択したものと異なる薬剤の指示編集画面が表示する。 張 end
//      return 1;
//    }

    Long mediInfoNo = ordMainDao.lockMaxIndMediInfoNo(facilityCd, patId);
    Timestamp nowTs = Timestamp.from(Instant.now());
    ordMainDao.updatePatMedicineNo(
      new MedicineLatestNo(facilityCd, Long.valueOf(patId), 1, nowTs, nowTs
        , AdminWebConstant.FlagType.FLAG_ON, AdminWebConstant.FlagType.FLAG_OFF)
    );
    return ordMainDao.selectIndMediInfoNo(facilityCd, patId);
    // mod #12471 投薬最新識別番号の設定 zkm end
  }
  // add FNSI-投薬最新識別番号の設定 李 end

  @Override
  // add FNSI-医療材料最新識別番号の設定 start
  public long selectMaxEquipInfoNo(String facilityCd, String patId) {
    // 医療材料最新識別番号を採番する
    ordMainDao.lockMaxIndEquipInfoNo(facilityCd, patId);
    Timestamp nowTs = Timestamp.from(Instant.now());
    ordMainDao.updatePatEquipmentNo(
      new EquipmentLatestNo(facilityCd, Long.valueOf(patId), 1, nowTs, nowTs
        , AdminWebConstant.FlagType.FLAG_ON, AdminWebConstant.FlagType.FLAG_OFF)
    );
    return ordMainDao.selectIndEquipInfoNo(facilityCd, patId);
  }
  // add FNSI-医療材料最新識別番号の設定 end

  @Override
  @Transactional
  public int updateTreatmentMethod(List<Long> ordNoList, OrdMain ordMain, Long indUserId, Long updUserId) {
    // add FNSI-改修内容追加OrdMain履歴 付 start
//    selectHistoryUtils.insertMangoDbHistory(3, null, null, ordNoList, new ArrayList<>(), null, null,
//      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
//      new ArrayList<>(), null, null);
    // mangoDb-updateTreatmentMethod-insertSuccess
    // add FNSI-改修内容追加OrdMain履歴 付 end
    // add 6227 張 start
//    ordNoList.forEach(item->{
//      copyOrdmainToOrdMainRestore(item);
//    });
    // add 6227 張 end
    List<OrdMain> oldOrdMains = ordMainDao.selectAllByOrdNoList(ordNoList);
    int updateCount = ordMainDao.updateTreatmentMethod(ordNoList, ordMain, indUserId, updUserId);
    List<OrdMain> newOrdMains = ordMainDao.selectAllByOrdNoList(ordNoList);
    triggerUtil.updateTriggerOrdMain(oldOrdMains, newOrdMains);
    selectHistoryUtils.insertMangoDbHistory(3, null, null, ordNoList, new ArrayList<>(), null, null,
      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
      new ArrayList<>(), null, null);
    if (0 != updateCount) {

      // DB更新ログ出力ロジック wangzuo Start
      String tableName = "pat_ind_approve";
      // SQL検索条件
      String inStr = getInStr("ord_no in ", ordNoList);
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(inStr + "\n");
      // logCommon設定
      DataUpdateLogCommonNew logCommon = getLogCommon(patIndApproveDao, tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResult = logCommon.setInfo();
      // DB更新ログ出力ロジック wangzuo End


      int patUpdateCount = 0;
      try {
        /* modify by chamaojia 2023-04-14 [5482 No.16、17、18] 一括メソッドの呼び出し --start */
//        patUpdateCount = updateContentChangeListWithNotification(ordNoList, new PatIndApprove());
        patUpdateCount = updateContentChangeListByBedControlWithNotification(ordNoList, new PatIndApprove());
        /* modify by chamaojia 2023-04-14 [5482 No.16、17、18] 一括メソッドの呼び出し --end */
      } catch (Exception e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        if (ordMain != null && !StringUtils.isEmpty(ordMain.getFacilityCd())) {
          eventLogMessage.setFacilityCd(ordMain.getFacilityCd());
        }
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      }

      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && patUpdateCount > 0) {
        /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --start */
        logCommon.setAfterResults();
//        logCommon.updateLog();
        asyncService.updateLog(logCommon);
        /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --end */
      }
      // DB更新ログ出力ロジック wangzuo End
    }
    return updateCount;
  }

  @Override
  @Transactional
  public int updateRstTreatmentMethod(List<Long> ordNoList, Integer treatmentCd, String treatmentName) {

    // add FNSI-改修内容追加OrdMain履歴 付 start
//    selectHistoryUtils.insertMangoDbHistory(3, null, null, ordNoList, new ArrayList<>(), null, null,
//      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
//      new ArrayList<>(), null, null);
    // mangoDb-updateRstTreatmentMethod-insertSuccess
    // add FNSI-改修内容追加OrdMain履歴 付 end

    // DB更新ログ出力ロジック wangzuo Start
    String tableName = "ord_main";
    // SQL検索条件
    String inStr = getInStr("ord_no in ", ordNoList);
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(inStr + "\n");
    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(ordMainDao, tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    // DB更新ログ出力ロジック wangzuo End
    // add 6227 張 start
//    ordNoList.forEach(item->{
//      copyOrdmainToOrdMainRestore(item);
//    });
    // add 6227 張 end
    List<OrdMain> oldOrdMains = ordMainDao.selectAllByOrdNoList(ordNoList);
    int updateCount = ordMainDao.updateRstTreatmentMethod(ordNoList, treatmentCd, treatmentName);
    List<OrdMain> newOrdMains = ordMainDao.selectAllByOrdNoList(ordNoList);
    triggerUtil.updateTriggerOrdMain(oldOrdMains, newOrdMains);
    selectHistoryUtils.insertMangoDbHistory(3, null, null, ordNoList, new ArrayList<>(), null, null,
      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
      new ArrayList<>(), null, null);
    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --start */
      logCommon.setAfterResults();
//      logCommon.updateLog();
      asyncService.updateLog(logCommon);
      /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --end */
    }
    // DB更新ログ出力ロジック wangzuo End

    return updateCount;
  }

  @Override
  public List<OrdMain> selectByDeleteOrdNo(Long pat_id, String dialysis_date_from, String dialysis_date_to, List<Integer> treatment_cd, List<Integer> kur_cd) {
    return ordMainDao.selectByDeleteOrdNo(null, pat_id, dialysis_date_from, dialysis_date_to, treatment_cd, kur_cd);
  }

  @Override
  public List<OrdMain> selectMoveTarget(
    Long pat_id,
    String facility_cd,
    String dialysis_date_from,
    String dialysis_date_to,
    String rst_dialysis_state,
    Integer treatment_cd,
    List<Integer> treat_week,
    boolean hasIndKurCd) {
    return ordMainDao.selectMoveTarget(pat_id, facility_cd, dialysis_date_from, dialysis_date_to, rst_dialysis_state, treatment_cd, treat_week,hasIndKurCd);
  }

  ;

  @Override
  public List<OrdChAp> getOrderByTreatmentCondition(OrdSearchTreatmentCondition searchTreatmentCondition,
                                                    OrdSearchCondition searchCondition) {
    List<OrdChAp> ordChAps = ordMainDao.selectOrderByTreatmentCondition(
      searchTreatmentCondition.getTreatDate(),
      searchTreatmentCondition.getTreatmentCode(), searchTreatmentCondition.getKurCode(),
      searchTreatmentCondition.getBedGroup(),
      searchCondition.getChecker1(), searchCondition.getChecker2(),
      searchCondition.getApprover1(), searchCondition.getApprover2(),
      searchCondition.getInstructorId(), searchCondition.getFacilityCd());
    return this.filterOrdChApsByPatPersonalMainId(ordChAps);
  }

  @Override
  public List<OrdChAp> getOrderByInstCondition(OrdSearchInstCondition searchInstCondition,
                                               OrdSearchCondition searchCondition) {
    List<OrdChAp> ordChAps = ordMainDao.selectOrderByInstCondition(
      searchInstCondition.getTreatStartTime(),
      searchInstCondition.getTreatStartDate(), searchInstCondition.getTreatEndDate(),
      searchCondition.getChecker1(), searchCondition.getChecker2(),
      searchCondition.getApprover1(), searchCondition.getApprover2(),
      searchCondition.getInstructorId(), searchCondition.getFacilityCd());
    return this.filterOrdChApsByPatPersonalMainId(ordChAps);
  }

  @Override
  public List<OrdMain> findForSearchFreeBedDate(String facility_cd, Long pat_id, Long kur_cd, List<Integer> treat_week_list, String search_start_date, String search_end_date, Boolean is_all, Long bed_cd) {
    return ordMainDao.selectForSearchFreeBedDate(facility_cd, pat_id, kur_cd, treat_week_list, search_start_date, search_end_date, is_all, bed_cd);
  }

  ;

  @Override
  public List<OrdMain> selectTreatDateListAll(Long patId, String facilityCd, String treatDateFrom, String treatDateTo, List<Integer> weeks, List<Integer> treats, List<Long> kurs) {
    return ordMainDao.selectTreatDateListAll(patId, facilityCd, treatDateFrom, treatDateTo, weeks, treats, kurs);
  }

  @Override
  public List<OrdMain> getOrdMainRegExamDate(String facility_cd, Long pat_id, String start_date, String end_date, List<String> reg_order_class, List<Integer> weeksArry, String is_del) {
    return ordMainDao.selectByRegExamDate(facility_cd, pat_id, start_date, end_date, reg_order_class, weeksArry, is_del);
  }

  @Override
  public Page<OrdMainTreatDate> getOrdNoList(Pageable pageable, Long pat_id) {
    SelectOptions selectOptions = SelectOptionsUtils.get(pageable, true);
    List<OrdMainTreatDate> ordMainList = ordMainDao.selectOrdNoList(selectOptions, pat_id);

    List<PatNameIdentification> srcPatIds = materialsSharingPatientInfomationService.getListPatIdSrcFromPatDst(pat_id);

    if (!srcPatIds.isEmpty()) {
      for (PatNameIdentification srcPatId : srcPatIds) {
        List<OrdMainTreatDate> newList = new ArrayList<OrdMainTreatDate>();
        newList = ordMainDao.selectOrdNoList(selectOptions, srcPatId.getPatIdSrc());

        for (OrdMainTreatDate retSrc : newList) {
          retSrc.setReadOnly(true);
        }
        if (!newList.isEmpty()) {
          ordMainList.addAll(newList);
        }
      }
    }
    return new PageImpl<>(ordMainList, pageable, selectOptions.getCount());
  }

  // add FNSI-FutreNetWeb+SI課題管理No.4362 李 start
  @Override
  public String getMaxTreatmentDate(String patId, String facilityCd) {
    String maxTreatmentDate = ordMainDao.selectMaxTreatmentDate(patId, facilityCd);
    return maxTreatmentDate;
  }
  // add FNSI-FutreNetWeb+SI課題管理No.4362 李 end

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public int updateIndRstDw(Long ordNo, Double dw) {

    // add FNSI-改修内容追加OrdMain履歴 付 start
//    getHistory(ordNo);
    // mangoDb-updateIndRstDw-insertSuccess
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
    // add 6227 張 start
//    copyOrdmainToOrdMainRestore(ordNo);
    // add 6227 張 end
    OrdMain oldOrdMain = ordMainDao.selectByOrdNo(ordNo);
    int updateCount = ordMainDao.updateIndRstDw(ordNo, dw);
    OrdMain newOrdMain = ordMainDao.selectByOrdNo(ordNo);
    triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain), Collections.singletonList(newOrdMain));
    getHistory(ordNo);
    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --start */
      logCommon.setAfterResults();
//      logCommon.updateLog();
      asyncService.updateLog(logCommon);
      /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --end */
    }
    // DB更新ログ出力ロジック wangzuo End

    return updateCount;
  }

  @Override
  public void updateAddInfoById(Long ordNo, String additionInfo) {
    try {

      // add FNSI-改修内容追加OrdMain履歴 付 start
//      getHistory(ordNo);
      // mangoDb-updateManualAddInfoById-insertSuccess
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
      // add 6227 張 start
//      copyOrdmainToOrdMainRestore(ordNo);
      // add 6227 張 end
      OrdMain oldOrdMain = ordMainDao.selectByOrdNo(ordNo);
      int updateCount = ordMainDao.updateManualAddInfoById(ordNo, additionInfo);
      OrdMain newOrdMain = ordMainDao.selectByOrdNo(ordNo);
      triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain), Collections.singletonList(newOrdMain));
      getHistory(ordNo);
      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && updateCount > 0) {
        /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --start */
        logCommon.setAfterResults();
//        logCommon.updateLog();
        asyncService.updateLog(logCommon);
        /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --end */
      }
      // DB更新ログ出力ロジック wangzuo End

    } catch (RuntimeException e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      eventLogMessage.setSqlIdentification("(ord_no = " + ordNo + ", addition_info = " + additionInfo + ")");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, "OrdMainDao/updateManualAddInfoById");
      throw new RuntimeException(e);
    }
  }

  @Override
  public List<String> getAdditionShortNameList(String facilityCd, Long patId, Long ordNo) {
    List<String> resultList = ordMainDao.selectAdditionShortName(facilityCd, patId, ordNo);
    return resultList;
  }

  @Override
  public List<OrdAdditionInfo> selectAdditionInfo(String facilityCd, Long patId, Long ordNo) {
    List<OrdAdditionInfo> resultList = ordMainDao.selectAdditionInfo(facilityCd, patId, ordNo);
    return resultList;
  }

  //add #12462 患者情報共有 zrx start
  @Override
  public List<OrdAdditionInfo> selectAdditionInfo(Long ordNo) {
    List<OrdAdditionInfo> resultList = ordMainDao.selectAdditionInfoOtherfacilities(ordNo);
    return resultList;
  }
  //add #12462 患者情報共有 zrx end

  private List<OrdChAp> filterOrdChApsByPatPersonalMainId(List<OrdChAp> ordChAps) {
    if (CollectionUtils.isEmpty(ordChAps)) {
      return Collections.emptyList();
    } else {
      List<OrdChAp> ordChApsResponse = new ArrayList<>();
      ordChAps.forEach(ordChAp -> {
        PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(ordChAp.getPat_id());
        if (Objects.nonNull(patPersonalMain)) {
          ordChAp.setHosp_pat_id(patPersonalMain.getHosp_pat_id());
          ordChAp.setPat_first_name(patPersonalMain.getPat_first_name());
          ordChAp.setPat_first_name_kana(patPersonalMain.getPat_first_name_kana());
          ordChAp.setPat_last_name(patPersonalMain.getPat_last_name());
          ordChAp.setPat_last_name_kana(patPersonalMain.getPat_last_name_kana());
          ordChApsResponse.add(ordChAp);
        }
      });
      return ordChApsResponse;
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<OrdScheduleCustom> getOrdScheduleByOrdNoList(String facilityCd, List<Long> ordNoList) {
    return ordScheduleDao.selectByOrdNoList(facilityCd, ordNoList);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  // mod FNSI-FutreNetWeb+SI課題管理No.4220 李 start
  // public List<OrdSchedule> getReservedOrdScheduleByTreatDate(String facilityCd, String treatDate, Long patId) {
  //   return ordScheduleDao.selectReservedTreatPlanByTreatDate(facilityCd, treatDate, patId);
  // }
  public List<OrdSchedule> getReservedOrdScheduleByTreatDate(String facilityCd, String treatDate) {
    return ordScheduleDao.selectReservedTreatPlanByTreatDate(facilityCd, treatDate);
  }
  // mod FNSI-FutreNetWeb+SI課題管理No.4220 李 end

  /**
   * {@inheritDoc}
   */
  @Override
  public List<OrdMainKurBed> selectByPatIdsWithBedAndKur(List<Long> patIds, String facilityCd, String treatDate) {
    return ordMainDao.selectByPatIdsWithBedAndKur(patIds, facilityCd, treatDate);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public String getOrdIndTreatStartTime(Long ordNo) {
    return ordMainDao.getOrdIndTreatStartTime(ordNo);
  }

  // add FNSI-修正 共有設定 start
  @Override
  public Page<OrdMainTreatDate> selectOrdNoListWithShared(Pageable pageable, Long pat_id, String sharedFlag) {
    SelectOptions selectOptions = SelectOptionsUtils.get(pageable, true);
    List<String> states = new ArrayList<String>(Arrays.asList(new String[]{"5"}));
    List<OrdMainTreatDate> ordMainList = ordMainDao.selectOrdNoListWithShared(selectOptions, pat_id, states);
    states = new ArrayList<String>(Arrays.asList(new String[]{"1", "2", "3", "4"}));
    List<OrdMainTreatDate> tempList = ordMainDao.selectOrdNoListWithShared(selectOptions, pat_id, states);
    if (tempList != null && tempList.size() > 0) {
      ordMainList.addAll(tempList);
    }
    //add FNSI-redmine5676 fang start
    states = new ArrayList<String>(Arrays.asList(new String[]{"6"}));
    List<OrdMainTreatDate> sixStates = ordMainDao.selectOrdNoListWithShared(selectOptions, pat_id, states);
    if (sixStates != null && sixStates.size() > 0) {
      // FNSI-修正 #6681,6356,5676,5755,5356、ソート順変更 del xugj start
//      sixStates.sort(new Comparator<OrdMainTreatDate>() {
//        @Override
//        public int compare(OrdMainTreatDate o1, OrdMainTreatDate o2) {
//          if (o1.getCurEditionDate() != null && o2.getCurEditionDate() != null) {
//            long result = o1.getCurEditionDate().getTime() - o2.getCurEditionDate().getTime();
//            if (result > 0) {
//              return -1;
//            } else if (result < 0) {
//              return 1;
//            }
//          }
//          return 0;
//        }
//      });
      // FNSI-修正 #6681,6356,5676,5755,5356、ソート順変更 del xugj end
      ordMainList.addAll(sixStates);
    }
    //add FNSI-redmine5676 fang end

    if ("1".equals(sharedFlag)) {
      // delete 元のクエリ情報を削除 #12462 患者情報共有 zrx start
//      List<PatNameIdentification> srcPatIds = materialsSharingPatientInfomationService.getListPatIdSrcFromPatDst(pat_id);
      // delete #12462 患者情報共有 zrx end
      // add #12462 患者情報共有 zrx start
      List<PatNameIdentification> srcPatIds = patNameIdentificationDao.getListPatIdSrcFromPatTo(pat_id);
      // add #12462 患者情報共有 zrx end
      if (!srcPatIds.isEmpty()) {
        for (PatNameIdentification srcPatId : srcPatIds) {
          List<OrdMainTreatDate> newList = new ArrayList<OrdMainTreatDate>();
          newList = ordMainDao.selectOrdNoList(selectOptions, srcPatId.getPatIdSrc());

          for (OrdMainTreatDate retSrc : newList) {
            retSrc.setReadOnly(true);
          }
          if (!newList.isEmpty()) {
            ordMainList.addAll(newList);
          }
        }
      }
    }
    // add FNSI-改修 单体 バーグ No.20 孫灝 20201207 start
//    ordMainList.sort(Comparator.comparingInt(ordMain -> Integer.parseInt(ordMain.getTreatDate())));
    // add FNSI-改修 单体 バーグ No.20 孫灝 20201207 end

    return new PageImpl<>(ordMainList, pageable, selectOptions.getCount());
  }
  // add FNSI-修正 共有設定 end


  //add クールマスタ 王 start
  /*mod #8494 by zhangruixue 2023-03-27  GC overhead limit exceeded start*/
  public List<Long> selectByFacilityCd(String facilityCd) {
    // TODO Auto-generated method stub
    return ordMainDao.selectOrdNoByFacilityCd(facilityCd);
  }
  /*mod #8494 by zhangruixue 2023-03-27  GC overhead limit exceeded end*/

  @Override
  public List<OrdMain> selectKurByFacilityCd(String facilityCd) {
    return ordMainDao.selectKurByFacilityCd(facilityCd);
  }
  //add クールマスタ 王 end

  // add FNSI-最終更新指示者のカラム追加と更新処理 楊 start

  /**
   * 最終更新指示者のカラム追加と更新
   *
   * @param ordMainCdList 　オーダー番号リスト
   * @param upIndUseId    最終更新指示者ID
   * @param upUseId       最終更新者ID
   * @return
   */
  @Override
  @Transactional
  public int updUpUseId(List<Long> ordMainCdList, Long upIndUseId, Long upUseId) {
    // OrdMain履歴
//    selectHistoryUtils.insertMangoDbHistory(3, null, null, ordMainCdList, new ArrayList<>(), null, null,
//      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
//      new ArrayList<>(), null, null);

    // 最終更新指示者のカラム追加と更新
    // mod FNSI-sqlパフォーマンスの最適化 李 start
    /* int updateCount = ordMainDao.updateUpUseId(
      ordMainCdList,
      upIndUseId,
      upUseId); */
    int updateCount = 0;
    for (Long ordMainCd: ordMainCdList) {
      // add 6227 張 start
//      copyOrdmainToOrdMainRestore(ordMainCd);
      // add 6227 張 end
      OrdMain oldOrdMain = ordMainDao.selectByOrdNo(ordMainCd);
      ordMainDao.updateUpUseId(ordMainCd, upIndUseId, upUseId);
      OrdMain newOrdMain = ordMainDao.selectByOrdNo(ordMainCd);
      triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain), Collections.singletonList(newOrdMain));

      updateCount++;
    }
    // mod FNSI-sqlパフォーマンスの最適化 李 end
    selectHistoryUtils.insertMangoDbHistory(3, null, null, ordMainCdList, new ArrayList<>(), null, null,
      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
      new ArrayList<>(), null, null);
    if (0 != updateCount) {

      // DB更新ログ出力ロジック wangzuo Start
      String tableName = "pat_ind_approve";
      // SQL検索条件
      String inStr = getInStr("ord_no in ", ordMainCdList);
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(inStr + "\n");
      // logCommon設定
      DataUpdateLogCommonNew logCommon = getLogCommon(patIndApproveDao, tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResult = logCommon.setInfo();
      // DB更新ログ出力ロジック wangzuo End

      int patUpdateCount = patIndApproveDao.updateContentChangeList(ordMainCdList, new PatIndApprove());

      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && patUpdateCount > 0) {
        /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --start */
        logCommon.setAfterResults();
//         logCommon.updateLog();
        asyncService.updateLog(logCommon);
        /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --end */
      }
      // DB更新ログ出力ロジック wangzuo End
    }
    return updateCount;
  }
  // add FNSI-最終更新指示者のカラム追加と更新処理 楊 end

  // add FNSI-改修No.324,No,325 再循環率、IHDF引き残し、静的静脈圧、IAPRatioの有効値更新 夏 start

  /**
   * 情報取得
   *
   * @param ordNo オーダ番号
   * @return JSON文字列
   */
  @Override
  public String selectWeightInfo(Long ordNo) {
    return ordMainDao.selectWeightInfo(ordNo);
  }

  /**
   * 情報更新
   *
   * @param ordNo オーダ番号
   * @return
   */
  @Override
  @Transactional
  public int updateWeightInfo(Long ordNo, String weightInfo) {
// add 6227 張 start
//    copyOrdmainToOrdMainRestore(ordNo);
// add 6227 張 end
    OrdMain oldOrdMain = ordMainDao.selectByOrdNo(ordNo);
    int updateCount = ordMainDao.updateWeightInfo(ordNo, weightInfo);
    OrdMain newOrdMain = ordMainDao.selectByOrdNo(ordNo);
    triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain), Collections.singletonList(newOrdMain));
    return updateCount;
  }
  // add FNSI-改修No.324,No,325 再循環率、IHDF引き残し、静的静脈圧、IAPRatioの有効値更新 夏 end

  // add FNSI-No.396 使用物品の指示、レセ換算結果の保持に対応 李 start

  /**
   * ord_noの取得
   *
   * @param patId      患者ID
   * @param facilityCd 施設コード
   * @param treatDate  治療日
   * @return
   */
  public List<String> selectOrdNo(String patId, String facilityCd, String treatDate) {
    return ordMainDao.selectOrdNo(patId, facilityCd, treatDate);
  }

  ;
  // add FNSI-No.396 使用物品の指示、レセ換算結果の保持に対応 李 end

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
   *
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
  // DB更新ログ出力ロジック wangzuo End

  // add FNSI-薬剤、医療材料の表示順の設定を追加する 李 start
  /**
   * 薬剤、医療材料の表示順取得
   * @return 薬剤、医療材料の表示順
   */
  public List<FacilitySettingNoDisplayOrder> selectMedEquipDisplayOrder(String facilityCd) {
    return ordMainDao.selectMedEquipDisplayOrder(facilityCd);
  };
  // add FNSI-薬剤、医療材料の表示順の設定を追加する 李 end

  // DB更新ログ出力ロジック xie Start

  /**
   * sqlパラメータ
   * @param list
   * @return
   */
  private static String getIntegerValueStr(List<Long> list) {
    String str = "";
    for (int i = 0; i < list.size(); i++) {
      Long value = list.get(i);
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


  /**
   * {@inheritDoc}
   */
  @Override
  public int updateContentChangeSingleWithNotification(Long ordNo, PatIndApprove patIndApprove) throws Exception {
    // 指示変更ありフラグの追加処理
    Integer patUpdateCount = patIndApproveDao.updateContentChangeSingle(ordNo, patIndApprove);
    // 更新できた場合、通知発火
    if (patUpdateCount > 0) {
      registerUpdateContentChangeNotification(ordNo);
    }
    return patUpdateCount;
  }

  /* add by chamaojia 2023-03-22 [6961] 新しいバッチ処理インタフェース、updateContentChangeSingleWithNotification  --start */
  private int updateContentChangeSingleWithNotificationByList(List<Long> ordNoList) throws Exception {
    Integer rtnUpdateCount = 0;
    List<OrdMain> ordMainList = ordMainDao.selectByOrdNoList(ordNoList);
    Map<Long, OrdMain> ordMainMap = ordMainList.stream()
      .collect(Collectors.toMap(o -> o.getOrdNo(), o -> o));
    for (Long ordNo : ordNoList) {
      // 指示変更ありフラグの追加処理     指令变更标志的附加处理
      Integer patUpdateCount = patIndApproveDao.updateContentChangeSingle(ordNo, new PatIndApprove());
      // 更新できた場合、通知発火     更新成功触发通知
      if (patUpdateCount > 0) {
        rtnUpdateCount += patUpdateCount;
        registerUpdateContentChangeNotificationByOrdMain(ordMainMap.get(ordNo));
      }
    }
    return rtnUpdateCount;
  }
  /* add by chamaojia 2023-03-22 [6961] 新しいバッチ処理インタフェース、updateContentChangeSingleWithNotification  --end */

  /**
   * {@inheritDoc}
   */
  @Override
  public int updateContentChangeListWithNotification(List<Long> ordNoList, PatIndApprove patIndApprove) throws Exception {
    Integer rtnUpdateCount = 0;
    /* add by chamaojia 2023-03-07 [6118] 一括クエリ呼び出し  --start */
    List<OrdMain> ordMainList = ordMainDao.selectByOrdNoList(ordNoList);
    Map<Long, OrdMain> ordMainMap = ordMainList.stream()
      .collect(Collectors.toMap(o -> o.getOrdNo(), o -> o));
    /* add by chamaojia 2023-03-07 [6118] 一括クエリ呼び出し  --end */
    for (Long ordNo : ordNoList) {
      // 指示変更ありフラグの追加処理
      Integer patUpdateCount = patIndApproveDao.updateContentChangeSingle(ordNo, patIndApprove);
      // 更新できた場合、通知発火
      if (patUpdateCount > 0) {
        rtnUpdateCount += patUpdateCount;
        /* modify by chamaojia 2023-03-07 [6118] 新しいメソッドの呼び出し、クエリ回数の削減  --start */
        registerUpdateContentChangeNotificationByOrdMain(ordMainMap.get(ordNo));
        /* modify by chamaojia 2023-03-07 [6118] 新しいメソッドの呼び出し、クエリ回数の削減  --end */
      }
    }
    return rtnUpdateCount;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public int updateContentChangeListByBedControlWithNotification(List<Long> ordNoList, PatIndApprove patIndApprove) throws Exception {
    Integer rtnUpdateCount = 0;

    /* modify by chamaojia 2023-04-10 [6118] コンテンツの事前検出、一括変更  --start */
    List<PatIndApprove> patIndApproves = patIndApproveDao.selectBySettingNoAndOrdNoList(ordNoList, "1022", "1");
    if (patIndApproves != null && !patIndApproves.isEmpty()) {
      List<Long> ordNos = patIndApproves.stream().map(o -> o.getOrd_no()).collect(Collectors.toList());
      rtnUpdateCount = patIndApproveDao.updateContentChangeSingleByOrdNoList(ordNos);
      List<OrdMain> ordMainList = ordMainDao.selectByOrdNoList(ordNos);
      for (OrdMain ordMain : ordMainList) {
        registerUpdateContentChangeNotificationByOrdMain(ordMain);
      }
    }
//    for (Long ordNo : ordNoList) {
//      // 指示変更ありフラグの追加処理
//      Integer patUpdateCount = patIndApproveDao.updateContentChangeSingleByBedControl(ordNo, patIndApprove);
//      // 更新できた場合、通知発火
//      if (patUpdateCount > 0) {
//        rtnUpdateCount += patUpdateCount;
//        registerUpdateContentChangeNotification(ordNo);
//      }
//    }
    /* modify by chamaojia 2023-04-10 [6118] コンテンツの事前検出、一括変更  --end */

    return rtnUpdateCount;
  }

  // add FNSI-マスタ削除表示の対応課題--治療方法 李 start
  @Override
  public String selectMstTreatmentNameByCd(String treatmentCd){
    return ordMainDao.selectMstTreatmentNameByCd(treatmentCd);
  }
  // add FNSI-マスタ削除表示の対応課題--治療方法 李 end

  // add FNSI-マスタ削除表示の対応課題--予実リスト 鄧シン start
  @Override
  public String selectMstBedNameByCd(String bedCd){
    return ordMainDao.selectMstBedNameByCd(bedCd);
  }
  @Override
  public String selectMstKurNameByCd(String kurCd){
    return ordMainDao.selectMstKurNameByCd(kurCd);
  }
  // add FNSI-マスタ削除表示の対応課題--予実リスト 鄧シン end

  /**
   * 治療中指示変更通知発火処理
   * @param ordNo オーダー番号
   * @return アップデート件数
   * @throws Exception
   */
  private void registerUpdateContentChangeNotification(Long ordNo) throws Exception {
    OrdMain ord = ordMainDao.selectByOrdNo(ordNo);

    // 条件送信後から後体重測定前までの間のみ処理する
    int dialysisState = Integer.parseInt(ord.getRstDialysisState());
    if (dialysisState >= 1 && dialysisState <= 4) {

      Long patId = ord.getPatId();
      String facilityCd = ord.getFacilityCd();
      String bedName = ord.getIndBedName() != null ? ord.getIndBedName() : "未登録";

      Map<String, String> patInfo = patInfoService.selectById(patId , facilityCd);
      ObjectMapper mapper = new ObjectMapper();
      PatPersonalMain patPersonalMain = mapper.readValue(patInfo.get("pat_personal_main"), PatPersonalMain.class);
      JSONObject replaceData = new JSONObject();
      replaceData.put("PATID", patId.toString());
      replaceData.put("LASTNAME", patPersonalMain.getPat_last_name());
      replaceData.put("FIRSTNAME", patPersonalMain.getPat_first_name());
      replaceData.put("BEDNAME", bedName);
      replaceData.put("FACILITYCD", facilityCd);
      replaceData.put("ORDNO", ordNo.toString());
      webApiCallCommonUtil.registerNotification(CoreConstant.NotificationDefinition.INDICATION_CHANGE_IN_TREATMENT, facilityCd, replaceData);
    }
  }

  /* add by chamaojia 2023-03-07 [6118] 新しいアプローチの追加、クエリ回数の削減  --start */
  /**
   * 治療中指示変更通知発火処理
   * @param ord
   * @return アップデート件数
   * @throws Exception
   */
  private void registerUpdateContentChangeNotificationByOrdMain(OrdMain ord) throws Exception {
    // 条件送信後から後体重測定前までの間のみ処理する
    int dialysisState = Integer.parseInt(ord.getRstDialysisState());
    if (dialysisState >= 1 && dialysisState <= 4) {

      Long patId = ord.getPatId();
      String facilityCd = ord.getFacilityCd();
      String bedName = ord.getIndBedName() != null ? ord.getIndBedName() : "未登録";

      Map<String, String> patInfo = patInfoService.selectById(patId , facilityCd);
      ObjectMapper mapper = new ObjectMapper();
      PatPersonalMain patPersonalMain = mapper.readValue(patInfo.get("pat_personal_main"), PatPersonalMain.class);
      JSONObject replaceData = new JSONObject();
      replaceData.put("PATID", patId.toString());
      replaceData.put("LASTNAME", patPersonalMain.getPat_last_name());
      replaceData.put("FIRSTNAME", patPersonalMain.getPat_first_name());
      replaceData.put("BEDNAME", bedName);
      replaceData.put("FACILITYCD", facilityCd);
      replaceData.put("ORDNO", ord.getOrdNo().toString());
      webApiCallCommonUtil.registerNotification(CoreConstant.NotificationDefinition.INDICATION_CHANGE_IN_TREATMENT, facilityCd, replaceData);
    }
  }
  /* add by chamaojia 2023-03-07 [6118] 新しいアプローチの追加、クエリ回数の削減  --end */

  /**
   * {@inheritDoc}
   */
  public Boolean notifyKurNotSet(String facilityCd, Long userId) throws Exception {
    // クール未登録件数 SQLで検索すること
    Integer count = ordMainDao.countTodayKurNotSet(facilityCd);

    // 未登録件数が1件以上の時に通知
    if (count > 0) {
      JSONObject replaceData = new JSONObject();
      replaceData.put("COUNT", count.toString());
      replaceData.put("FACILITYCD", facilityCd);
      replaceData.put("USERID", userId.toString());

      ResponseEntity<String> result = webApiCallCommonUtil.registerNotification(CoreConstant.NotificationDefinition.NOTIFY_KUR_NOT_SET, facilityCd, replaceData);

      if (result.getStatusCode() == HttpStatus.OK) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  // add FNSi6002-補液速度操作範囲上限を超えて設定できる 周 start
  /**
   * {@inheritDoc}
   */
  public List<OrdMain> selectFutureScheduleByDateCd(String facility_cd, Long pat_id) {
    return ordMainDao.selectFutureScheduleByDateCd(facility_cd, pat_id);
  }
  // add FNSi6002-補液速度操作範囲上限を超えて設定できる 周 end

  /**
   * {@inheritDoc}
   */
  public Boolean notifyBedNotSet(String facilityCd, Long userId) throws Exception {
    // ベッド未登録件数 SQLで検索すること
    Integer count = ordMainDao.countTodayBedNotSet(facilityCd);

    // 未登録件数が1件以上の時に通知
    if (count > 0) {
      JSONObject replaceData = new JSONObject();
      replaceData.put("COUNT", count.toString());
      replaceData.put("FACILITYCD", facilityCd);
      replaceData.put("USERID", userId.toString());

      ResponseEntity<String> result = webApiCallCommonUtil.registerNotification(CoreConstant.NotificationDefinition.NOTIFY_BED_NOT_SET, facilityCd, replaceData);

      if (result.getStatusCode() == HttpStatus.OK) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }
  // redmine 4672  姜 start
  public SendConditionCheckResponse checkFuicchi(ApiEntityOrdMain.CheckFuicchi bodyData) {

    // 装置モード不一致チェックMsgFlg
    Boolean deviceModeMismatchMsgFlg = false;
    // VA方向不一致チェックMsgFlg
    Boolean vaDirectionInconsistentMsgFlg = false;
    // 感染症不一致チェックMsgFlg
    Boolean infectionNotConsistentMsgFlg = false;

    String treatModeCdString = getDeviceModeFromMstTreatment(bodyData.getOrd_no());
    Integer treatModeCd = null;
    if (treatModeCdString != null) {
      treatModeCd = Integer.valueOf(treatModeCdString);
    }
    SendConditionCheckResponse res = new SendConditionCheckResponse();
    //mod 7579 【デグレ】対応していない治療方法，シャント位置のベッドへ移動した時に注意喚起メッセージが出ない 周安寧　start
    //if (treatModeCd != null) {
    if (treatModeCd != null && bodyData.getInd_bed_cd() != null) {
      //deviceModeMismatchMsgFlg = this.checkDeviceMode(treatModeCd,bodyData.getOrd_no());
      deviceModeMismatchMsgFlg = this.checkDeviceMode(treatModeCd,bodyData.getFacility_cd(),
        Long.valueOf(bodyData.getInd_bed_cd()));
      //mod 7579 【デグレ】対応していない治療方法，シャント位置のベッドへ移動した時に注意喚起メッセージが出ない 周安寧　end
    }
    // 12.VA方向不一致チェック
    String shuntPosition = "";
    // 感染症フラグ
    String isInfection = "";
    // 指示：ベッドコード
    if (bodyData.getInd_bed_cd() != null) {
      MstBed mstbed = mstBedDao.selectByBedCd(Long.valueOf(bodyData.getInd_bed_cd()) , null, "0");
      if (mstbed != null) {
        shuntPosition = String.valueOf(mstbed.getShuntPosition());
        isInfection = mstbed.getIsInfection();
      }
    }
    Integer ind_va_cd = this.getIndVaCd(bodyData.getOrd_no());
    // 指示：VAコード
    String vaDirect = "";
    if (ind_va_cd != null) {
      MstVa mstVa = mstVaDao.selectByCd(ind_va_cd);
      if (mstVa != null) {
        vaDirect = mstVa.getVaDirect();
      }
    }
    //mod 7579 【デグレ】対応していない治療方法，シャント位置のベッドへ移動した時に注意喚起メッセージが出ない 周安寧　start
//    if (!StringUtils.isEmpty(vaDirect) && !StringUtils.isEmpty(shuntPosition)) {
//      if ("-".equals(vaDirect)) {
//        vaDirectionInconsistentMsgFlg = true;
//      } else if (!"0".equals(shuntPosition) && !"0".equals(vaDirect)) {
//        if (!vaDirect.equals(shuntPosition)) {
//          vaDirectionInconsistentMsgFlg = true;
//        }
//      } else if ("0".equals(vaDirect)) {
//        if (!"0".equals(shuntPosition) && !"1".equals(shuntPosition) && !"2".equals(shuntPosition)) {
//          vaDirectionInconsistentMsgFlg = true;
//        }
//      } else if ("0".equals(shuntPosition)) {
//        if (!"0".equals(vaDirect) && !"1".equals(vaDirect) && !"2".equals(vaDirect)) {
//          vaDirectionInconsistentMsgFlg = true;
//        }
//      }
//    }
    //mod #11999 患者経過総合ビューアで予定移動操作時、VA一致不一致判定ロジックが不正 zrx start
//    if (StringUtils.isEmpty(vaDirect) || StringUtils.isEmpty(shuntPosition )|| vaDirect.equals(shuntPosition)
//    ) {
//      // ①どちらかあるいは両方null(or空文字)、または一致する場合、一致
//      vaDirectionInconsistentMsgFlg = true;
//    } else if ("3".equals(vaDirect) || "-".equals(vaDirect) ||
//      "3".equals(shuntPosition) || "-".equals(shuntPosition)
//    ) {
//      // ②どちらかがシャント位置「なし」、「不明」の場合は、不一致
//      vaDirectionInconsistentMsgFlg = false;
//    } else if ("0".equals(vaDirect)|| "0".equals(shuntPosition)
//    ) {
//      // ③どちらかがシャント位置「両方」の場合、一致
//      vaDirectionInconsistentMsgFlg = true;
//    } else {
//      // ④その他、不一致
//      vaDirectionInconsistentMsgFlg = false;
//    }
    //mod 7579 【デグレ】対応していない治療方法，シャント位置のベッドへ移動した時に注意喚起メッセージが出ない 周安寧　end
    /**
     * 0:両方
     * 1:左
     * 2:右
     * 3:無
     * -:不明
     */
    if (StringUtils.isEmpty(vaDirect)) {
      vaDirectionInconsistentMsgFlg = true;
    }
    if (Objects.equals(shuntPosition, "3") || Objects.equals(vaDirect, "3")) {
      // 3:無
      vaDirectionInconsistentMsgFlg = true;
    } else if (Objects.equals(vaDirect, "-")) {
      // -:不明
      vaDirectionInconsistentMsgFlg = false;
    }  else if (Objects.equals(vaDirect, shuntPosition)) {
      vaDirectionInconsistentMsgFlg = true;
    }
    //mod #11999 患者経過総合ビューアで予定移動操作時、VA一致不一致判定ロジックが不正 zrx end

    res.vaDirectionInconsistentMsgFlg = vaDirectionInconsistentMsgFlg;
    // 13.感染症不一致チェック
    PatMain patMain = patMainDao.selectById(bodyData.getPat_id());

    if (patMain != null) {
      //del 7579 【デグレ】対応していない治療方法，シャント位置のベッドへ移動した時に注意喚起メッセージが出ない 周安寧　start
      //mod 9273 mst _ bedもpat _ mainも感染症フラグを設定している場合、判断する必要があります shiyw start
      if (!StringUtils.isEmpty(isInfection) && !StringUtils.isEmpty(patMain.getIs_infect())) {
      //mod 9273 mst _ bedもpat _ mainも感染症フラグを設定している場合、判断する必要があります shiyw end
      //del 7579 【デグレ】対応していない治療方法，シャント位置のベッドへ移動した時に注意喚起メッセージが出ない 周安寧　end
        if (!isInfection.equals(patMain.getIs_infect())) {
          infectionNotConsistentMsgFlg = true;
        }
      }
    }
    res.deviceModeMismatchMsgFlg = deviceModeMismatchMsgFlg;
    res.vaDirectionInconsistentMsgFlg = vaDirectionInconsistentMsgFlg;
    res.infectionNotConsistentMsgFlg = infectionNotConsistentMsgFlg;

    return res;
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
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      retDeviceMode = null;
    }
    return retDeviceMode;
  }
    //mod 7579 【デグレ】対応していない治療方法，シャント位置のベッドへ移動した時に注意喚起メッセージが出ない 周安寧　start
  //private Boolean checkDeviceMode(Integer treatModeCd,Long ordNo) {
  private Boolean checkDeviceMode(Integer treatModeCd,String facilityCd,Long indBedCd) {
    // 装置マスタ情報取得(ord_mainに紐付く情報の抽出)     mst_machine,mst_bed,ord_mainから取得
    //HashMap<WebAPICheckConditionSend.PARAMKEY, Object> retMaster = this.getDataFromMstMachine(ordNo);
    HashMap<WebAPICheckConditionSend.PARAMKEY, Object> retMaster = this.getDataFromMstMachineByBed(facilityCd,indBedCd);
    //mod 7579 【デグレ】対応していない治療方法，シャント位置のベッドへ移動した時に注意喚起メッセージが出ない 周安寧　end
    //mod FNSI-7057 劉全航 start
    Optional<HashMap<WebAPICheckConditionSend.PARAMKEY, Object>> retMasterOptional = Optional.ofNullable(retMaster);
    if(!retMasterOptional.isPresent()){
      return false;
    }
    //mod FNSI-7057 劉全航 end
    Boolean deviceModeMismatchMsgFlg = false;
    if (AdminWebConstant.Treatment.DeviceMode.HD.equals(treatModeCd)) {
      // 装置モード(HD)
      String isSupportHd = (String) retMaster.get(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_HD);
      if ("0".equals(isSupportHd)) {
        deviceModeMismatchMsgFlg = true;
      }
    } else if (AdminWebConstant.Treatment.DeviceMode.ECUM.equals(treatModeCd)) {
      // 装置モード(ECUM)
      String isSupportEcum = (String) retMaster.get(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_ECUM);
      if ("0".equals(isSupportEcum)) {
        deviceModeMismatchMsgFlg = true;
      }
    } else if (AdminWebConstant.Treatment.DeviceMode.HDF.equals(treatModeCd)) {
      // 装置モード(HDF)
      String isSupportHdf = (String) retMaster.get(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_HDF);
      if ("0".equals(isSupportHdf)) {
        deviceModeMismatchMsgFlg = true;
      }
    } else if (AdminWebConstant.Treatment.DeviceMode.HF.equals(treatModeCd)) {
      // 装置モード(HF)
      String isSupportHf = (String) retMaster.get(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_HF);
      if ("0".equals(isSupportHf)) {
        deviceModeMismatchMsgFlg = true;
      }
    } else if (AdminWebConstant.Treatment.DeviceMode.HD_AND_REPLACEMENT.equals(treatModeCd)) {
      // 装置モード(HD+補液)
      String isSupportHdHo = (String) retMaster.get(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_HD_HO);
      if ("0".equals(isSupportHdHo)) {
        deviceModeMismatchMsgFlg = true;
      }
    } else if (AdminWebConstant.Treatment.DeviceMode.ECUM_AND_REPLACEMENT.equals(treatModeCd)) {
      // 装置モード(ECUM+補液)
      String isSupportEcumHo = (String) retMaster.get(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_ECUM_HO);
      if ("0".equals(isSupportEcumHo)) {
        deviceModeMismatchMsgFlg = true;
      }
    } else if (AdminWebConstant.Treatment.DeviceMode.AFBF.equals(treatModeCd)) {
      // 装置モード(AFBF)
      String isSupportAfbf = (String) retMaster.get(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_AFBF);
      if ("0".equals(isSupportAfbf)) {
        deviceModeMismatchMsgFlg = true;
      }
    } else if (AdminWebConstant.Treatment.DeviceMode.OHDF.equals(treatModeCd)) {
      // 装置モード(OHDF)
      String isSupportOhdf = (String) retMaster.get(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_OHDF);
      if ("0".equals(isSupportOhdf)) {
        deviceModeMismatchMsgFlg = true;
      }
    }  else if (AdminWebConstant.Treatment.DeviceMode.OHF.equals(treatModeCd)) {
      // 装置モード(OHF)
      String isSupportOhf = (String) retMaster.get(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_OHF);
      if ("0".equals(isSupportOhf)) {
        deviceModeMismatchMsgFlg = true;
      }
    } else if (AdminWebConstant.Treatment.DeviceMode.I_HDF.equals(treatModeCd)) {
      // 装置モード(I-HDF)
      String isSupportIhdf = (String) retMaster.get(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_I_HDF);
      if ("0".equals(isSupportIhdf)) {
        deviceModeMismatchMsgFlg = true;
      }
    } else if (AdminWebConstant.Treatment.DeviceMode.PURIFICATION.equals(treatModeCd)) {
      // 装置モード(特殊浄化)
      String isSupportBloodPurify = (String) retMaster.get(WebAPICheckConditionSend.PARAMKEY.IS_SUPPORT_BLOOD_PURIFY);
      if ("0".equals(isSupportBloodPurify)) {
        deviceModeMismatchMsgFlg = true;
      }
      //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx start
    } else if (AdminWebConstant.Treatment.DeviceMode.UNKNOWN.equals(treatModeCd)) {
      // 治療方法が「不明」の場合
      deviceModeMismatchMsgFlg = true;
    }
    //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx end
    return deviceModeMismatchMsgFlg;
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
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      retVal = null;
    }

    return retVal;

  }
  //add 7579 【デグレ】対応していない治療方法，シャント位置のベッドへ移動した時に注意喚起メッセージが出ない 周安寧　start
  /**
   * 通信フォーマット取得処理
   * 装置マスタから情報を取得する
   * @param facilityCd 施設コード
   * @param indBedCd ベッドコード
   * @return 取得した値　<PARAMKEY,value>
   */
  private HashMap<WebAPICheckConditionSend.PARAMKEY, Object> getDataFromMstMachineByBed(
    String facilityCd,
    Long indBedCd
  ) {
    // 戻り値
    HashMap<WebAPICheckConditionSend.PARAMKEY, Object> retVal = new HashMap<>();

    String result = null;

    // データ抽出
    try {
      // DBからのデータ取得
      List<Map<String, Object>> list = webAPICheckConditionSendService.getDataFromMstMachineByBed(facilityCd,indBedCd);

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
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      retVal = null;
    }

    return retVal;

  }
  //add 7579 【デグレ】対応していない治療方法，シャント位置のベッドへ移動した時に注意喚起メッセージが出ない 周安寧　end
  public Integer getIndVaCd(Long ord_no){
    Integer indVaCd = ordMainDao.getIndVaCd(ord_no);
    return indVaCd;
  }
  // redmine 4672  姜 end

  //add FutreNetWeb+SI課題管理 no.5485 劉全航 start
  @Override
  public HashMap<String, List<Integer>> selectPatOrdMainAfterTreatDate(Long patId, String facilityCd, String treatDate) {
    List<OrdMain> ordMains = ordMainDao.selectPatOrdMainAfterTreatDate(patId, facilityCd, treatDate);
    HashMap<String, List<Integer>> equipCdToTreatDateMap = new HashMap<>();
    List<OrdMain> ordMainList = ordMains.stream().filter(o -> !o.getIndEquipInfo().isEmpty()).collect(Collectors.toList());
    for (OrdMain ordMain : ordMainList) {
      JSONArray equipArray = new JSONArray(ordMain.getIndEquipInfo());
      for (int j = 0; j < equipArray.length(); j++) {
        JSONObject jsonObject = equipArray.getJSONObject(j);
        String equipCd = String.valueOf(jsonObject.getInt("cd"));
        if (!equipCdToTreatDateMap.containsKey(equipCd)) {
          List<Integer> dateList = new ArrayList<>();
          dateList.add(Integer.valueOf(ordMain.getTreatDate()));
          equipCdToTreatDateMap.put(equipCd, dateList);
        } else {
          equipCdToTreatDateMap.get(equipCd).add(Integer.valueOf(ordMain.getTreatDate()));
        }
      }
    }
    return equipCdToTreatDateMap;
  }

  //add FutreNetWeb+SI課題管理 no.5485 劉全航 end
// add 6227 張 start

  /**
   * ordMainバックアップデータ
   * @param ordMain
   */
/* modify by shiyw 2023-03-25 [#8101] 患者経過総合応答速度の最適化です --start */
//  public void copyOrdmainToOrdMainRestore(Long ordNo) {
//    OrdMain ordMain =selectByOrdNo(ordNo);
    public void copyOrdmainToOrdMainRestore(OrdMain ordMain) {
 /* modify by shiyw 2023-03-25 [#8101] 患者経過総合応答速度の最適化です --end */
    //add 8008 日次処理のスケジュール自動延長がされない患者が存在する start zhao
    NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    Timestamp delDate = new Timestamp(System.currentTimeMillis());
    //add 8008 日次処理のスケジュール自動延長がされない患者が存在する end zhao
    if (ordMain!=null) {
      OrdMainRestore ordMainRestore = new OrdMainRestore();
      BeanUtils.copyProperties(ordMain, ordMainRestore);
      ordMainRestore.setDelDate(delDate);
      //add 8008 日次処理のスケジュール自動延長がされない患者が存在する start zhao
      if (user != null) {
        ordMainRestore.setUpIndUserId(user.getUserId());
        ordMainRestore.setUpUserId(user.getUserId());
      }
      //add 8008 日次処理のスケジュール自動延長がされない患者が存在する end zhao
      ordMainRestoreDao.insert(ordMainRestore);
    }
  }

  /* add by shiyw 2023-03-25 [#8101] 患者経過総合応答速度の最適化です --start */
  public void batchCopyOrdMainToOrdMainRestore(List<OrdMain> ordList) {
    NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    List<OrdMainRestore> ordMainRestoreList = new ArrayList<>();
    Timestamp delDate = new Timestamp(System.currentTimeMillis());
    for(OrdMain ordMain: ordList){
      OrdMainRestore ordMainRestore = new OrdMainRestore();
      BeanUtils.copyProperties(ordMain, ordMainRestore);
      ordMainRestore.setDelDate(delDate);
      if (user != null) {
        ordMainRestore.setUpIndUserId(user.getUserId());
        ordMainRestore.setUpUserId(user.getUserId());
      }
      ordMainRestoreList.add(ordMainRestore);
    }
    ordMainRestoreDao.insertList(ordMainRestoreList);
  }
  /* add by shiyw 2023-03-25 [#8101] 患者経過総合応答速度の最適化です --end */

  @Override
  public int delete(OrdMain ordNo) {
    // add 6227 張 start
    copyOrdmainToOrdMainRestore(ordNo);
    // add 6227 張 end
    int updateCount = ordMainDao.delete(ordNo);
    /* modify by shiyw 2023-02-24 [#8101] Append the where condition facilityCd, matching the primary key [facility_cd,ord_no], to improve the del speed --start */
    //ordScheduleDao.deleteScheduleByOrdNoList(Collections.singletonList(ordNo.getOrdNo()));
    ordScheduleDao.deleteScheduleByOrdNoList(ordNo.getFacilityCd(),Collections.singletonList(ordNo.getOrdNo()));
    /* modify by shiyw 2023-02-24 [#8101] Append the where condition facilityCd, matching the primary key [facility_cd,ord_no], to improve the del speed --end */
    // #10196 delete materialSave when ordMain has been del.
    ordMaterialSaveService.deleteMaterialSaveByBaseNo(ordNo.getOrdNo());
    return updateCount;
  }

  /* add by shiyw 2023-02-24 [#8101]  --start */
  @Override
  public int batchDelete(List<OrdMain> ordList) {
    if(ordList == null && ordList.isEmpty()){
      return 0;
    }
    batchCopyOrdMainToOrdMainRestore(ordList);
    List<Long> ordNoList = ordList.stream().map(ord -> ord.getOrdNo()).collect(Collectors.toList());
    int updateCount = ordMainDao.deleteByOrdNo(ordNoList);
    /* modify by shiyw 2023-02-24 [#8101] Append the where condition facilityCd, matching the primary key [facility_cd,ord_no], to improve the del speed --start */
    //ordScheduleDao.deleteScheduleByOrdNoList(ordNoList);
    String facilityCd = ordList.get(0).getFacilityCd();
    ordScheduleDao.deleteScheduleByOrdNoList(facilityCd,ordNoList);
    /* modify by shiyw 2023-02-24 [#8101] Append the where condition facilityCd, matching the primary key [facility_cd,ord_no], to improve the del speed --end */
    return updateCount;
  }
  /* add by shiyw 2023-02-24 [#8101]  --end */

//  @Override
//  public int updateWeightBefore(Long ordNo, BigDecimal setweight, String setDate) {
////    copyOrdmainToOrdMainRestore(ordNo);
//    return ordMainDao.updateWeightBefore(ordNo,setweight,setDate);
//  }

//  @Override
//  public int updateWeightAfter(Long ordNo, BigDecimal setweight, String setDate) {
////    copyOrdmainToOrdMainRestore(ordNo);
//    return ordMainDao.updateWeightAfter(ordNo,setweight,setDate);
//  }

//  @Override
//  public int updateReturnHomeDateAndState(Long ordNo, Timestamp measureDate, String afterWeight) {
////    copyOrdmainToOrdMainRestore(ordNo);
//    return ordMainDao.updateReturnHomeDateAndState(ordNo,measureDate,afterWeight);
//  }

//  @Override
//  public int updateRstTare(Long ordNo, String buildRstTareInfoWheelChair) {
////    copyOrdmainToOrdMainRestore(ordNo);
//    return ordMainDao.updateRstTare(ordNo,buildRstTareInfoWheelChair);
//  }

//  @Override
//  public int updateRstOffWater(Long ordNo, String offWater) {
////    copyOrdmainToOrdMainRestore(ordNo);
//    return ordMainDao.updateRstOffWater(ordNo,offWater);
//  }

//  @Override
//  public int updateBeforeWeight(Long ordNo, String writeValueAsString, String offWater, String buildRstTareInfoWithWheelChair, Timestamp acceptDate, String dw) {
////    copyOrdmainToOrdMainRestore(ordNo);
//    return ordMainDao.updateBeforeWeight(ordNo,writeValueAsString,offWater,buildRstTareInfoWithWheelChair,acceptDate,dw);
//  }

//  @Override
//  public int updateIndStartTareAndOffWater(Long ordNo, String offWaterInfo, String tareInfo) {
////    copyOrdmainToOrdMainRestore(ordNo);
//    return ordMainDao.updateIndStartTareAndOffWater(ordNo,offWaterInfo,tareInfo);
//  }

//  @Override
//  public int updateRstTareOffWaterInfo(Long ordNo, String tareInfo, String offWaterInfo, Timestamp upDate) {
////    copyOrdmainToOrdMainRestore(ordNo);
//    return ordMainDao.updateRstTareOffWaterInfo(ordNo,tareInfo,offWaterInfo,upDate);
//  }

//  @Override
//  public int updateTareAndOffWater(long parseLong, String tareInfo, String offWaterInfo) {
////    copyOrdmainToOrdMainRestore(parseLong);
//    return ordMainDao.updateTareAndOffWater(parseLong,tareInfo,offWaterInfo);
//  }

//  @Override
//  public int updateIndTareOffWaterInfo(Long ordNo, String tareInfo, String offWaterInfo, Timestamp upDate) {
////    copyOrdmainToOrdMainRestore(ordNo);
//    return ordMainDao.updateIndTareOffWaterInfo(ordNo,tareInfo,offWaterInfo,upDate);
//  }

//  @Override
//  public int updateRstTareAndOffWater(Long ordNo, String tareInfo, String offWaterInfo, Timestamp upDate) {
////    copyOrdmainToOrdMainRestore(ordNo);
//    return ordMainDao.updateRstTareAndOffWater(ordNo,tareInfo,offWaterInfo);
//  }

//  @Override
//  public int updateFutureIndTareAndOffWater(Long patId, String treatDate, Integer treatWeek, String tareInfo, String offWaterInfo, Timestamp upDate) {
////    List<OrdMain> list=selectFutureIndTareAndOffWater(patId,treatDate,treatWeek);
////    list.forEach(item->{
////      copyOrdmainToOrdMainRestore(item.getOrdNo());
////    });
//    return ordMainDao.updateFutureIndTareAndOffWater(patId,treatDate,treatWeek,tareInfo,offWaterInfo,upDate);
//  }

  @Override
  public List<OrdMain> selectFutureIndTareAndOffWater(Long patId, String treatDate, Integer treatWeek) {
    return ordMainDao.selectFutureIndTareAndOffWater(patId,treatDate,treatWeek);
  }

//  @Override
//  public int updateDeviceInfo(Long ord_no, String facility_cd, Long pat_id, String start_date, String end_date, List<Integer> week, List<Integer> treat_method, List<Integer> kur_cd, String device_info) {
////    copyOrdmainToOrdMainRestore(ord_no);
//    return ordMainDao.updateDeviceInfo(ord_no,facility_cd,pat_id,start_date,end_date,week,treat_method,kur_cd,device_info);
//  }

//  @Override
//  public int updateRstDeviceSetInfo(Long ord_no, String facility_cd, Long pat_id, String start_date, String end_date, List<Integer> week, List<Integer> treat_method, List<Integer> kur_cd, String device_info) {
////    copyOrdmainToOrdMainRestore(ord_no);
//    return ordMainDao.updateRstDeviceSetInfo(ord_no,facility_cd,pat_id,start_date,end_date,week,treat_method,kur_cd,device_info);
//  }

//  @Override
//  public int immediateCommitOffWater(Long ordNo, String offWaterInfo) {
////    copyOrdmainToOrdMainRestore(ordNo);
//    return ordMainDao.immediateCommitOffWater(ordNo,offWaterInfo);
//  }

//  @Override
//  public int immediateCommitTare(Long ordNo, String tareInfo) {
////    copyOrdmainToOrdMainRestore(ordNo);
//    return ordMainDao.immediateCommitTare(ordNo,tareInfo);
//  }

//  @Override
//  public int updateCheckAfterWeight(Long ordNo, String mediInfo) {
////    copyOrdmainToOrdMainRestore(ordNo);
//    return ordMainDao.updateCheckAfterWeight(ordNo,mediInfo);
//  }

//  @Override
//  public int updateMediInfo(Long ordNo, String mediInfo) {
////    copyOrdmainToOrdMainRestore(ordNo);
//    return ordMainDao.updateMediInfo(ordNo,mediInfo);
//  }

//  @Override
//  public int updateDeviceSetInfo(Long ord_no, String deviceSetInfoJson) {
////    copyOrdmainToOrdMainRestore(ord_no);
//    return ordMainDao.updateDeviceSetInfo(ord_no,deviceSetInfoJson);
//  }

//  @Override
//  public int updateCancelSendCondition(Long ordNo, Timestamp timestamp) {
////    copyOrdmainToOrdMainRestore(ordNo);
//    return ordMainDao.updateCancelSendCondition(ordNo,timestamp);
//  }

//  @Override
//  public int updatePatId(Long patId, Long ordNo, Timestamp update) {
////    copyOrdmainToOrdMainRestore(ordNo);
//    return ordMainDao.updatePatId(patId,ordNo,update);
//  }

//  @Override
//  public int updateRstDialysisCnt(Long ordNo, Long dialCount) {
////    copyOrdmainToOrdMainRestore(ordNo);
//    return ordMainDao.updateRstDialysisCnt(ordNo,dialCount);
//  }

//  @Override
//  public void updateScheduleAssignment(OrdMainUpdateForScheduleAssignment baseordMain, Timestamp update) {
////    copyOrdmainToOrdMainRestore(baseordMain.getOrdNo());
//    ordMainDao.updateScheduleAssignment(baseordMain,update);
//  }

//  @Override
//  public int updateDeleteByOrdNo(Long ordNo, Timestamp upDate) {
////    copyOrdmainToOrdMainRestore(ordNo);
//    return ordMainDao.updateDeleteByOrdNo(ordNo,upDate);
//  }

//  @Override
//  public int updateDeleteByPatId(Long pat_id) {
////    List<OrdMain> list=selectByPatId(pat_id);
////    list.forEach(item->{
////      copyOrdmainToOrdMainRestore(item.getOrdNo());
////    });
//    return ordMainDao.updateDeleteByPatId(pat_id);
//  }
  @Override
  public List<OrdMain> selectByPatId(Long pat_id) {
    return ordMainDao.selectByPatId(pat_id);
  }

//  @Override
//  public int updateIsConfirm(Long ordNo, String updateTargetIsConfirm, String isConfirm) {
////    copyOrdmainToOrdMainRestore(ordNo);
//    return ordMainDao.updateIsConfirm(ordNo,updateTargetIsConfirm,isConfirm);
//  }

//  @Override
//  public int updateIndCondInfoWithTreatCondSetting(List<Long> ordNoList, String toAddTreatCond, List<String> toDeleteTreatCondList, Boolean isUpdateRst) {
////    ordNoList.forEach(item->{
////      copyOrdmainToOrdMainRestore(item);
////    });
//    return ordMainDao.updateIndCondInfoWithTreatCondSetting(ordNoList,toAddTreatCond,toDeleteTreatCondList,isUpdateRst);
//  }

//  @Override
//  public int updateIndCondInfoWithTreatMethodNonReplenish(List<Long> ordNoList, Boolean isUpdateReplenishLiquid) {
////    ordNoList.forEach(item->{
////      copyOrdmainToOrdMainRestore(item);
////    });
//    return ordMainDao.updateIndCondInfoWithTreatMethodNonReplenish(ordNoList,isUpdateReplenishLiquid);
//  }

//  @Override
//  public int updateIndCondInfoWithTreatMethodReplenish(List<Long> ordNoList, Boolean isUpdateReplenishLiquid) {
////    ordNoList.forEach(item->{
////      copyOrdmainToOrdMainRestore(item);
////    });
//    return ordMainDao.updateIndCondInfoWithTreatMethodReplenish(ordNoList,isUpdateReplenishLiquid);
//  }

//  @Override
//  public int updateIndCondInfoWithTreatMethodNonReplenishSup(List<Long> ordNoList, Boolean isUpdateReplenishLiquid, Long oldDeviceMode) {
////    ordNoList.forEach(item->{
////      copyOrdmainToOrdMainRestore(item);
////    });
//    return ordMainDao.updateIndCondInfoWithTreatMethodNonReplenishSup(ordNoList,isUpdateReplenishLiquid,oldDeviceMode);
//  }

//  @Override
//  public int updateIndCondInfoWithTreatMethodReplenishSup(List<Long> ordNoList, Boolean isUpdateReplenishLiquid, Long oldDeviceMode) {
////    ordNoList.forEach(item->{
////      copyOrdmainToOrdMainRestore(item);
////    });
//    return ordMainDao.updateIndCondInfoWithTreatMethodReplenishSup(ordNoList,isUpdateReplenishLiquid,oldDeviceMode);
//  }
  // add 6227 張 end

  // #7068 add 2022-11-22 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない   卓 START
  /**
   * 指示者・更新者情報を付加
   *
   * @param ordMain     更新情報
   * @param ind_user_id 指示者ID
   * @param upd_user_id 更新者ID
   * @return ordMain 更新情報に指示者IDと更新者IDをつけて返す
   */
  @Override
  public OrdMain addIndUserAndUpdUserInfo(OrdMain ordMain, Long ind_user_id, Long upd_user_id) {
    // mod FNSI-指示編集でDB登録データの更新 楊 start
    // Map<String, Long> map = new HashMap<String, Long>();
    Map<String, Object> map = new HashMap<String, Object>();
    // mod FNSI-指示編集でDB登録データの更新 楊 end
    map.put("ind_user_id", ind_user_id);
    map.put("upd_user_id", upd_user_id);
    // mod FNSI-指示編集でDB登録データの更新 楊 start
    MstPersonalUser user = mstPersonalUserDao.selectById(ind_user_id);
    // 指示者名_姓
    map.put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
    // 指示者名_名
    map.put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
    // mod FNSI-指示編集でDB登録データの更新 楊 end

    // add 10096 by kangjie 20240119 start
    MstPersonalUser updUser = mstPersonalUserDao.selectById(upd_user_id);
    map.put("upd_user_last_name",updUser.getUserLastName());
    map.put("upd_user_first_name",updUser.getUserFirstName());
    // add 10096 by kangjie 20240119 end

    // 指示:治療予定指示者情報に格納
    ordMain.setIndScheduleUserInfo(OrdMainUtil.updateRecursionJSONObject(ordMain.getIndScheduleUserInfo(), map, 0));
    // 指示:治療条件情報に格納
    ordMain.setIndCondInfo(OrdMainUtil.updateRecursionJSONObject(ordMain.getIndCondInfo(), map, 1));
    // 指示:投与薬剤情報に格納
    ordMain.setIndMediInfo(OrdMainUtil.updateRecursionJSONObject(ordMain.getIndMediInfo(), map, 0));
    // 指示:医療材料情報に格納
    ordMain.setIndEquipInfo(OrdMainUtil.updateRecursionJSONObject(ordMain.getIndEquipInfo(), map, 0));
    // 指示:指示コメント情報に格納
    ordMain.setIndIndCommentInfo(OrdMainUtil.updateRecursionJSONObject(ordMain.getIndIndCommentInfo(), map, 0));
    // 指示:装置設定情報に格納
    ordMain.setIndDeviceSetInfo(OrdMainUtil.updateRecursionJSONObject(ordMain.getIndDeviceSetInfo(), map, 1));

    return ordMain;
  }

  /* add by chamaojia 2023-03-20 [8101] クエリを減らす新しい方法の追加  --start */
  /**
   * 指示者・更新者情報を付加
   *
   * @param ordMain     更新情報
   * @param ind_user_id 指示者ID
   * @param upd_user_id 更新者ID
   * @param user
   * @return ordMain 更新情報に指示者IDと更新者IDをつけて返す
   */
  private OrdMain addIndUserAndUpdUserInfo(OrdMain ordMain, Long ind_user_id, Long upd_user_id, MstPersonalUser user) {
    // mod FNSI-指示編集でDB登録データの更新 楊 start
    // Map<String, Long> map = new HashMap<String, Long>();
    Map<String, Object> map = new HashMap<String, Object>();
    // mod FNSI-指示編集でDB登録データの更新 楊 end
    map.put("ind_user_id", ind_user_id);
    map.put("upd_user_id", upd_user_id);
    // mod FNSI-指示編集でDB登録データの更新 楊 start
//    MstPersonalUser user = mstPersonalUserDao.selectById(ind_user_id);
    // 指示者名_姓
    map.put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
    // 指示者名_名
    map.put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
    // mod FNSI-指示編集でDB登録データの更新 楊 end

    // 指示:治療予定指示者情報に格納
    ordMain.setIndScheduleUserInfo(OrdMainUtil.updateRecursionJSONObject(ordMain.getIndScheduleUserInfo(), map, 0));
    // 指示:治療条件情報に格納
    ordMain.setIndCondInfo(OrdMainUtil.updateRecursionJSONObject(ordMain.getIndCondInfo(), map, 1));
    // 指示:投与薬剤情報に格納
    ordMain.setIndMediInfo(OrdMainUtil.updateRecursionJSONObject(ordMain.getIndMediInfo(), map, 0));
    // 指示:医療材料情報に格納
    ordMain.setIndEquipInfo(OrdMainUtil.updateRecursionJSONObject(ordMain.getIndEquipInfo(), map, 0));
    // 指示:指示コメント情報に格納
    ordMain.setIndIndCommentInfo(OrdMainUtil.updateRecursionJSONObject(ordMain.getIndIndCommentInfo(), map, 0));
    // 指示:装置設定情報に格納
    ordMain.setIndDeviceSetInfo(OrdMainUtil.updateRecursionJSONObject(ordMain.getIndDeviceSetInfo(), map, 1));

    return ordMain;
  }
  /* add by chamaojia 2023-03-20 [8101] クエリを減らす新しい方法の追加  --end */

  // #7068 add 2022-11-22 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない   卓 END

  // add by liuzhibo 2022-12-14#6961_#5698＿無期限医材変更　補填あり変更時間問題の修正 -- start /
  public int updateOrdMainMediInfo(
    OrdMain ord,
    String ord_info,
    String rst_info,
    Boolean log_update_flg,
    Long upIndUseId,
    Long upUseId) {
//    getHistory(ord.getOrdNo());  // 优化：移动到外面，并改为批量插入mongo
    OrdMain oldOrdMain = ordMainDao.selectByOrdNo(ord.getOrdNo());
    /* modify by chamaojia 2024-01-22 [10196]  No need to modify the content of 'indScheduleUserInfo' --start */
    int updateCount = ordMainDao.updateOrdMainMedInfoAndUserId(
      ord.getOrdNo(),
      ord_info,
      rst_info,
//      ord.getIndScheduleUserInfo(),
      upIndUseId,
      upUseId,
      //mod 9806 start ljx 投与薬剤
      //現状：ここの処理を利用する箇所がないので、一旦falseを設定、SQLファイルに追加された処理が実行しないようにする。
      false);
    //mod 9806 end ljx
    /* modify by chamaojia 2024-01-22 [10196]  No need to modify the content of 'indScheduleUserInfo' --end */
    OrdMain newOrdMain = ordMainDao.selectByOrdNo(ord.getOrdNo());
    triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain), Collections.singletonList(newOrdMain));
    getHistory(ord.getOrdNo());
//    mod 5720 2023-03-06 患者経過総合ビューアにて指示追加時 → 実績反映させる場合に実績の履歴に対象が登録されない。張 end
    if (log_update_flg) {
      String tableName = "ord_main";
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" ord_no = " + ord.getOrdNo() + "\n");
      // logCommon設定
      DataUpdateLogCommonNew logCommon = getLogCommon(ordMainDao, tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResult = logCommon.setInfo();
      // 更新後データ取得、差分あれば、log出力
      if (setResult && updateCount > 0) {
        /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --start */
        logCommon.setAfterResults();
//        logCommon.updateLog();
        asyncService.updateLog(logCommon);
        /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --end */
      }
      // DB更新ログ出力ロジック wangzuo End
    }
    if (0 != updateCount) {
      PatIndApprove patIndApprove = new PatIndApprove();
      patIndApprove.setOrd_no(ord.getOrdNo());
      try {
        updateContentChangeSingleWithNotification(ord.getOrdNo(), patIndApprove);
      } catch (Exception e) {
      }
    }
    return updateCount;
  }

  /* add by chamaojia 2023-03-22 [6961] 新しいバッチ処理インタフェース、updateOrdMainMediInfo  --start */
  public int updateOrdMainMediInfoByList(
    //mod 9806 start ljx 投与薬剤
    //List<UpdateOrdMainMediInfoDTO> dataList, Boolean log_update_flg) {
    //パラメータ追加：rst_update_flg、実績データへの反映要否、true：反映、false:反映しない。
    //追加されたパラメータによって、is_confirmを更新するかの判断をする。
    List<UpdateOrdMainMediInfoDTO> dataList, Boolean log_update_flg,Boolean rst_update_flg) {
    //mod 9806 end ljx
//    getHistory(ord.getOrdNo());  // 最適化：外部に移動し、一括挿入mongoに変更
    List<Long> ordNoList = dataList.stream().map(o -> o.getOrdMain().getOrdNo()).collect(Collectors.toList());

    // del 12250 ord_material_saveの処理を2回重複実行している zkm start
//    List<MaterialSaveCacheHandler.DiffResultContainer> diffMaterialSaveRstList = new ArrayList<>();
    // del 12250 ord_material_saveの処理を2回重複実行している zkm end

    List<OrdMain> oldOrdMainList = ordMainDao.selectListByOrdNo(ordNoList);

    boolean setResult = false;
    DataUpdateLogCommonNew logCommon = null;
    if (log_update_flg) {
      String tableName = "ord_main";
      // SQL検索条件
      String inStr = getInStr("ord_no in ", ordNoList);
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(inStr + "\n");
      // logCommon設定
      logCommon = getLogCommon(ordMainDao, tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      setResult = logCommon.setInfo();
    }

    int updateCount = 0;
    for (UpdateOrdMainMediInfoDTO infoEntity : dataList) {
      //add #11841 【たくしん会】ord_mainの登録不正 zrx start
      if(Objects.equals("0", infoEntity.getOrdMain().getRstDialysisState())) {
        OrdMain ordMain = infoEntity.getOrdMain();
        ordMain.setIndMediInfo(infoEntity.getOrdInfo());
        ordMain = this.delJSONKey(ordMain);
        infoEntity.setOrdInfo(ordMain.getIndMediInfo());
      }
      //add #11841 【たくしん会】ord_mainの登録不正 zrx end
      /* modify by chamaojia 2024-01-22 [10196]  No need to modify the content of 'indScheduleUserInfo' --start */
      updateCount = updateCount + ordMainDao.updateOrdMainMedInfoAndUserId(
        infoEntity.getOrdMain().getOrdNo(),
        infoEntity.getOrdInfo(),
        infoEntity.getRstInfo(),
//        infoEntity.getOrdMain().getIndScheduleUserInfo(),
        infoEntity.getUpIndUseId(),
        infoEntity.getUpUseId(),
        //mod 9806 start ljx 投与薬剤
        rst_update_flg);
      //mod 9806 end ljx
      /* modify by chamaojia 2024-01-22 [10196]  No need to modify the content of 'indScheduleUserInfo' --end */

      infoEntity.getOrdMain().setIndMediInfo(infoEntity.getOrdInfo());
      // del 12250 ord_material_saveの処理を2回重複実行している zkm start
//      MaterialSaveCacheHandler.DiffResultContainer diffMaterialSaveInd
//        = ordMaterialSaveService.updateOrdMaterialSaveByDiff(
//        new OrdMaterialSaveDto(
//          infoEntity.getOrdMain().getOrdNo(),
//          false,
//          true,
//          false,
//          false,
//          "1",
//          infoEntity.getOrdMain()
//        )
//      );
//      diffMaterialSaveRstList.add(diffMaterialSaveInd);
//      if (rst_update_flg) {
//        infoEntity.getOrdMain().setRstMediInfo(infoEntity.getRstInfo());
//        MaterialSaveCacheHandler.DiffResultContainer diffMaterialSaveRst
//          = ordMaterialSaveService.updateOrdMaterialSaveByDiff(
//          new OrdMaterialSaveDto(
//            infoEntity.getOrdMain().getOrdNo(),
//            false,
//            true,
//            false,
//            false,
//            "2",
//            infoEntity.getOrdMain()
//          )
//        );
//        diffMaterialSaveRstList.add(diffMaterialSaveRst);
//      }
      // del 12250 ord_material_saveの処理を2回重複実行している zkm end
    }
    // mod 12250 ord_material_saveの処理を2回重複実行している zkm start
//    if(CollectionUtils.isNotEmpty(diffMaterialSaveRstList)){
//      ordMaterialSaveService.batchProcessingData(diffMaterialSaveRstList);
//    }
    if (rst_update_flg) {
      ordMaterialSaveService.bulkUpdateByOrdNoInCondMediEquip(ordNoList);
    } else {
      ordMaterialSaveService.bulkUpdateByOrdNoInMedi(ordNoList);
    }
    // mod 12250 ord_material_saveの処理を2回重複実行している zkm end

    List<OrdMain> newOrdMainList = ordMainDao.selectListByOrdNo(ordNoList);
    triggerUtil.updateTriggerOrdMain(oldOrdMainList, newOrdMainList);
//    getHistory(ord.getOrdNo());
    getListByMode1History(ordNoList);
//    mod 5720 2023-03-06 患者経過総合ビューアにて指示追加時 → 実績反映させる場合に実績の履歴に対象が登録されない。張 end
    if (log_update_flg) {
      // 更新後データ取得、差分あれば、log出力
      if (setResult && updateCount > 0) {
        /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --start */
        logCommon.setAfterResults();
//        logCommon.updateLog();
        asyncService.updateLog(logCommon);
        /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --end */
      }
      // DB更新ログ出力ロジック wangzuo End
    }
    if (0 != updateCount) {
      String tableName = "pat_ind_approve";
      String inStr = getInStr("ord_no in ", ordNoList);
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(inStr + "\n");
      // logCommon設定
      DataUpdateLogCommonNew patIndApprovelogCommon = getLogCommon(patIndApproveDao, tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean patIndApproveSetResult = patIndApprovelogCommon.setInfo();
      int patUpdateCount = 0;
      try {
        patUpdateCount = updateContentChangeSingleWithNotificationByList(ordNoList);
      } catch (Exception e) {
      }

      if (patIndApproveSetResult && patUpdateCount > 0) {
        patIndApprovelogCommon.setAfterResults();
//        patIndApprovelogCommon.updateLog();
        asyncService.updateLog(patIndApprovelogCommon);
      }
    }
    return updateCount;
  }
  /* add by chamaojia 2023-03-22 [6961] 新しいバッチ処理インタフェース、updateOrdMainMediInfo  --end */

  public int updateOrdMainEquipInfo(
    OrdMain ord,
    Long upIndUseId,
    Long upUseId) {
    // getHistory(ord.getOrdNo());  // 优化：移动到外面，并改为批量插入mongo
    String tableName = "ord_main";
    // SQL検索条件
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(" ord_no = " + ord.getOrdNo() + "\n");
    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(ordMainDao, tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    /* modify by chamaojia 2024-01-23 [10196]  No need to modify the content of 'indScheduleUserInfo' --start */
    int updateCount = ordMainDao.updateOrdMainEquipInfoAndUserId(
      ord.getOrdNo(),
      ord.getIndEquipInfo(),
      ord.getRstEquipInfo(),
//      ord.getIndScheduleUserInfo(),
      upIndUseId,
      upUseId,
      //mod 9806 start ljx 投与薬剤
      //現状：ここの処理を利用する箇所がないので、一旦falseを設定、SQLファイルに追加された処理が実行しないようにする。
      false);
      //mod 9806 end ljx
    /* modify by chamaojia 2024-01-23 [10196]  No need to modify the content of 'indScheduleUserInfo' --end */
    triggerUtil.updateOrdMainTriggerForOrdScheduleInsert(Collections.singletonList(ord));
    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --start */
      logCommon.setAfterResults();
//      logCommon.updateLog();
      asyncService.updateLog(logCommon);
      /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --end */
    }
    // DB更新ログ出力ロジック wangzuo End
    PatIndApprove patIndApprove = new PatIndApprove();
    patIndApprove.setOrd_no(ord.getOrdNo());
    try {
      updateContentChangeSingleWithNotification(ord.getOrdNo(), patIndApprove);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ord != null && !StringUtils.isEmpty(ord.getFacilityCd())) {
        eventLogMessage.setFacilityCd(ord.getFacilityCd());
      }
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }
    return updateCount;
  }
// add by liuzhibo 2022-12-14#6961_#5698＿無期限医材変更　補填あり変更時間問題の修正 -- end /

    /* add by chamaojia 2023-03-22 [6961] 新しいバッチ処理インタフェース、上のupdateOrdMainEquipInfoメソッドの拡張  --start */
  public int updateOrdMainEquipInfoByOrdMainList(
    //mod 9806 ljx start 医療材料
    //List<OrdMain> ordMainList, Long upIndUseId, Long upUseId) {
    List<OrdMain> ordMainList, Long upIndUseId, Long upUseId,Boolean rst_update_flg) {
    //mod 9806 ljx end

    List<Long> ordNoList = ordMainList.stream().map(o -> o.getOrdNo()).collect(Collectors.toList());
    String tableName = "ord_main";
    // SQL検索条件
    String inStr = getInStr("ord_no in ", ordNoList);
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(inStr + "\n");
    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(ordMainDao, tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    // DB更新ログ出力ロジック wangzuo End

    int updateCount = 0;
    for (OrdMain ord : ordMainList) {
      //mod #11841 【たくしん会】ord_mainの登録不正 zrx start
      if(Objects.equals("0", ord.getRstDialysisState())) {
        ord = this.delJSONKey(ord);
      }
      //mod #11841 【たくしん会】ord_mainの登録不正 zrx end
      /* modify by chamaojia 2024-01-23 [10196]  No need to modify the content of 'indScheduleUserInfo' --start */
      updateCount = updateCount +
        ordMainDao.updateOrdMainEquipInfoAndUserId(
          ord.getOrdNo(),
          ord.getIndEquipInfo(),
          ord.getRstEquipInfo(),
//          ord.getIndScheduleUserInfo(),
          upIndUseId,
          upUseId,
          //mod 9806 ljx start 医療材料
          rst_update_flg);
      //mod 9806 ljx end
      /* modify by chamaojia 2024-01-23 [10196]  No need to modify the content of 'indScheduleUserInfo' --end */
    }

    triggerUtil.insertListTriggerOrdMain(ordMainList);
    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --start */
      logCommon.setAfterResults();
//      logCommon.updateLog();
      asyncService.updateLog(logCommon);
      /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --end */
    }
    // DB更新ログ出力ロジック wangzuo End
    if (updateCount > 0) {
      tableName = "pat_ind_approve";
      // logCommon設定
      DataUpdateLogCommonNew patIndApprovelogCommon = getLogCommon(patIndApproveDao, tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean patIndApproveSetResult = patIndApprovelogCommon.setInfo();

      int patUpdateCount = 0;
      try {
        patUpdateCount = updateContentChangeSingleWithNotificationByList(ordNoList);
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

      if (patIndApproveSetResult && patUpdateCount > 0) {
        patIndApprovelogCommon.setAfterResults();
//        patIndApprovelogCommon.updateLog();
        asyncService.updateLog(patIndApprovelogCommon);
      }

    }
    return updateCount;
  }
  /* add by chamaojia 2023-03-22 [6961] 新しいバッチ処理インタフェース、上のupdateOrdMainEquipInfoメソッドの拡張  --end */

  /* add by luchanghai  2023-02-01 [CodeOptimization]  start */
  @Override
  public List<String> getDuplicatedOrdList(String facilityCd, List<Long> ordNoList) {
    // スケジュールリストの取得
    List<OrdScheduleCustom> ordScheduleList = getOrdScheduleByOrdNoList(facilityCd, ordNoList);
    List<OrdMain> ordMainList = ordMainDao.selectByOrdNoList(ordNoList);
    List<MstTreatment> mstTreatmentList = mstTreatmentDao.selectByOrdNoList(ordNoList);

    List<String> updatedOrdList = new ArrayList<>();
    for (OrdScheduleCustom ordSch : ordScheduleList) {

      // スケジュール情報の作成
      String scheduleInfo = "";

      // 日付の整形 yyyyMMdd → yyyy/MM/dd
      String treatDate = ordSch.getTreatDate();
      String year = treatDate.substring(0, 4);
      String month = treatDate.substring(4, 6);
      String day = treatDate.substring(6);
      String treatDateFormatted = year + "/" + month + "/" + day;
      scheduleInfo = scheduleInfo + treatDateFormatted;

      // 曜日の整形
      Short treatWeek = ordSch.getTreatWeek();
      Optional<Week> enumWeek = Week.valueOf(treatWeek);
      String treatWeekFormatted = "";
      if (enumWeek.isPresent()) {
        treatWeekFormatted = "(" + enumWeek.get().getText() + ")";
      }
      scheduleInfo = scheduleInfo + treatWeekFormatted;

      // クール名称を設定
      String kurName = ordSch.getKurName();
      scheduleInfo = scheduleInfo + kurName;

      // 治療方法の取得
      Optional<Integer> trearmentCdResult = ordMainList.stream()
        .filter(e -> e.getOrdNo().equals(ordSch.getOrdNo()))
        .map(e -> e.getIndTreatmentCd())
        .findFirst();

      Integer trearmentCd = trearmentCdResult.orElse(0);

      if (trearmentCd.compareTo(0) > 0) {
        Optional<String> trearmentNameResult = mstTreatmentList.stream()
          .filter(e -> e.getTreatmentCd().equals(trearmentCd))
          .map(e -> e.getTreatmentName())
          .findFirst();

        String trearmentName = trearmentNameResult.orElse("");

        if (! trearmentName.isEmpty()) {
          scheduleInfo = scheduleInfo + " " + trearmentName;
        }
      }
      updatedOrdList.add(scheduleInfo);
    }
    return updatedOrdList;
  }

  @Override
  public boolean getPatSwitchFlag(String facilityCd, Long ordNo, String rstState) {
    boolean patSwitchFlg = false;
    // mnt_machine_state(装置状態管理)の情報を取得する。
    List<MntMachineState> mntMachineStateList = mntMachineStateDao.selectByOrdNo(facilityCd, ordNo);
    for (MntMachineState dataInfo : mntMachineStateList) {
      if (dataInfo.getNextOrdNo() != null && ! ordNo.equals(dataInfo.getNextOrdNo())) {
        //未送信の場合
        if (rstState.equals("4")) {
          // 4：排液済（治療終了）の場合
          patSwitchFlg = true;
        } else if (rstState.equals("5")) {
          //5：後体重測定済み(実績未確定)の場合
          // mst_machine(装置マスタ	)からdevice_edge_noを取得する。
          MstMachine mstMachine = mstMachineDao.selectByCd(dataInfo.getMachineTypeCd(), dataInfo.getMachineSerial(), facilityCd);
          // mst_comsv_setting(通信サーバー設定)からpat_timingを取得する。
          if (mstMachine != null && mstMachine.getDeviceEdgeNo() != null) {
            MstComsvSetting mstComsvInfo = mstComsvSettingDao.selectByCd(facilityCd, mstMachine.getDeviceEdgeNo());
            if (mstComsvInfo != null && mstComsvInfo.getPatTiming() != null) {
              String patTiming = mstComsvInfo.getPatTiming();
              // '0':後体重測定、'1':実績初版確定
              if (patTiming.equals("1")) {
                patSwitchFlg = true;
              }
            }
          }
        }
      }
    }
    return patSwitchFlg;
  }

  /**
   * 治療予定登録 with オーダ番号
   *
   * @param bodyData 必要パラメータの記載されたJson文字列
   * @return
   * @throws URISyntaxException
   * @throws ParseException
   * @throws JSONException
   */
  @Override
  @Transactional
  public ResponseEntity<String> insertByOrdNo(
    ApiEntityOrdMain.ValiCreateTreatPlanByOrdNo bodyData, BindingResult validationResult
  ) throws ParseException {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to insertByOrdNo OrdMain : " + bodyData.getOrd_no() + bodyData.getUp_date());
    logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
    eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("insertByOrdNoを開始");
    logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
    // バリデーションエラーチェック
    if (validationResult.hasErrors()) {
      // バリデーションエラーが発生した場合はパラメータ異常扱い
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("result:" + validationResult);
      logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
      for (ObjectError error : validationResult.getFieldErrors()) {
        //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
        eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("error:" + error.getDefaultMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
        //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
      }
      // 引数は、ボディデータ、ヘッダーデータ、ステータス
      return new ResponseEntity<>("パラメータエラー", null, HttpStatus.BAD_REQUEST);
    }
    List<Integer> weeksArry = new ArrayList<Integer>();
    weeksArry.add(0);

    // 治療方法セット取得
    List<OrdMain> listOrdMainRet = findByDateCd(bodyData.getFacility_cd(), null, null, null, Long.valueOf(bodyData.getOrd_no()), weeksArry, null);
    if (1 != listOrdMainRet.size()) {
      HttpStatus status = HttpStatus.BAD_REQUEST;
      //引数は、ボディデータ,ヘッダーデータ,ステータス
      ResponseEntity<String> re = new ResponseEntity<>("治療情報参照エラー", null, status);
      return re;
    }
    //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
    eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("更新日時(引数(変換前)):" + bodyData.getUp_date());
    logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
    //mod #9289 直近の過去指示(投与薬剤を含まない)を使った治療予定作成時にエラー発生 zy start
//    Timestamp bodyUpdate = new Timestamp(new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ").parse(bodyData.getUp_date()).getTime());
    Timestamp bodyUpdate = new Timestamp(DateTimeUtils.dateStringToDate_iso8601(bodyData.getUp_date()).getTime());
    //mod #9289 直近の過去指示(投与薬剤を含まない)を使った治療予定作成時にエラー発生 zy end
    if (false == listOrdMainRet.get(0).getUpDate().equals(bodyUpdate)) {
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("治療方法セットが更新されている為、治療予定登録を中止");
      logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("更新日時(マスタ):" + listOrdMainRet.get(0).getUpDate()
        + " 更新日時(引数):" + bodyUpdate);
      logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
      HttpStatus status = HttpStatus.BAD_REQUEST;
      //引数は、ボディデータ,ヘッダーデータ,ステータス
      ResponseEntity<String> re = new ResponseEntity<>("排他エラー", null, status);
      return re;
    }

    // 対象のpat_mainレコード(1人)を取得
    List<Long> patIdList = new ArrayList<>();
    patIdList.add(Long.parseLong(bodyData.getPat_id()));
    List<PatMain> listPatMain = patMainDao.selectByIdListFacilityCd(patIdList, bodyData.getFacility_cd());
    if (listPatMain.size() == 0) {
      HttpStatus status = HttpStatus.BAD_REQUEST;
      //引数は、ボディデータ,ヘッダーデータ,ステータス
      ResponseEntity<String> re = new ResponseEntity<>("患者情報(pat_main)参照エラー", null, status);
      return re;
    }
    PatMain patMain = listPatMain.get(0);
    JSONObject tareJson = new JSONObject(patMain.getTare_info());
    JSONObject offWaterJson = new JSONObject(patMain.getOff_water_info());

    // スケジュール延長処理中の場合、予定作成を中止する
    if (true == patMain.getSch_ext_status().equals("1")) {
      JSONObject msgJson = new JSONObject("{}");
      msgJson.put("msgCd", 22020004);
      return new ResponseEntity<String>(msgJson.toString(), HttpStatus.OK);
    }

    OrdMain ordMain = selectByOrdNo(Long.valueOf(bodyData.getOrd_no()));
    //del #9289 直近の過去指示(投与薬剤を含まない)を使った治療予定作成時にエラー発生 zy start
//    ordMain.setOrdNo(null);
    //del #9289 直近の過去指示(投与薬剤を含まない)を使った治療予定作成時にエラー発生 zy end
    // 治療方法コードの登録
    ordMain.setIndTreatmentCd(listOrdMainRet.get(0).getIndTreatmentCd());
    // 指示：クールコード 未登録(固定)
    ordMain.setIndKurCd(0);
    // 指示：ベッドコード 未登録(固定)
    ordMain.setIndBedCd(0);
    // 投与薬剤は空で登録する
    ordMain.setIndMediInfo("[]");

    JSONArray ordNoList = new JSONArray();
    JSONArray treatDays = new JSONArray(bodyData.getTreatDays());
    List<Short> patTreatPatternWeek = new ArrayList<Short>();
    //add #12680 直近の過去指示（投与薬剤を含まない）で予定を作成すると不正データが発生する zrx start
    List<OrdMain> ordMainAfterList = new ArrayList<>();
    //add #12680 直近の過去指示（投与薬剤を含まない）で予定を作成すると不正データが発生する zrx end
    for (int i = 0; i < treatDays.length(); i++) {
      // 治療日
      ordMain.setTreatDate(treatDays.getString(i));

      // 治療日から治療曜日を取得
      SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMdd");
      Date treatDay = dateFormat.parse(treatDays.getString(i));
      Calendar cal = Calendar.getInstance();
      cal.setTime(treatDay);
      int dayOfWeek = cal.get(Calendar.DAY_OF_WEEK) - 1;
      if (0 == dayOfWeek) dayOfWeek = 7;

      // 患者治療パターン用曜日を格納
      if (! patTreatPatternWeek.contains((short) dayOfWeek)) {
        patTreatPatternWeek.add((short) dayOfWeek);
      }

      ordMain.setIndTareInfo(tareJson.getJSONObject(String.valueOf(dayOfWeek)).toString());
      ordMain.setIndOffWaterInfo(offWaterJson.getJSONObject(String.valueOf(dayOfWeek)).toString());

      // 治療曜日
      ordMain.setTreatWeek((short) dayOfWeek);
      //add #11841 【たくしん会】ord_mainの登録不正 zrx start
      ordMain = this.delJSONKey(ordMain);
      //add #11841 【たくしん会】ord_mainの登録不正 zrx end
      ordMain = addIndUserAndUpdUserInfo(ordMain, Long.parseLong(bodyData.getInd_user_id()), Long.parseLong(bodyData.getUpd_user_id()));
      // 治療情報の登録
      int insertCount = copyData(ordMain);
      //add #12680 直近の過去指示（投与薬剤を含まない）で予定を作成すると不正データが発生する zrx start
      ordMainAfterList.add(SerializationUtils.clone(ordMain));
      //add #12680 直近の過去指示（投与薬剤を含まない）で予定を作成すると不正データが発生する zrx end
      if (0 >= insertCount) {
        //レコード作成に失敗した場合
        HttpStatus status = HttpStatus.INTERNAL_SERVER_ERROR;
        //引数は、ボディデータ,ヘッダーデータ,ステータス
        ResponseEntity<String> re = new ResponseEntity<>("レコードの作成に失敗しました。", null, status);

        return re;
      } else {
        ordNoList.put(insertCount);
      }
    }

    if ("false".equals(bodyData.getIs_deadline())) {
      // 患者治療パターン編集データ
      PatTreatmentPatternUtils.PatTreatmentPatternEditData editData = new PatTreatmentPatternUtils.PatTreatmentPatternEditData();
      //mod 10860 ind_schedule_user_infoのデータ不正 zhao start
      MstPersonalUser user = MasterCacheHandler.get().getMstPersonalUser(Long.parseLong(bodyData.getInd_user_id()));
      MstPersonalUser updUser = mstPersonalUserDao.selectById(Long.parseLong(bodyData.getUpd_user_id()));
      //String indSchInfo = patTreatmentPatternUtils.createIndSchInfo((long) ordMain.getIndBedCd(), ordMain.getIndTreatStartTime(), Long.parseLong(bodyData.getInd_user_id()), Long.parseLong(bodyData.getUpd_user_id()));
      String indSchInfo = patTreatmentPatternUtils.createPatternIndSchInfo((long) ordMain.getIndBedCd(), ordMain.getIndTreatStartTime(),Long.parseLong(bodyData.getInd_user_id()),user, Long.parseLong(bodyData.getUpd_user_id()),updUser,null);
      //mod 10860 ind_schedule_user_infoのデータ不正 zhao end
      if (null == indSchInfo) {
        String strMsg = "患者治療パターン登録に失敗しました(スケジュール情報異常:[ベッドコード=" + ordMain.getIndBedCd() + "、治療開始時刻=" + ordMain.getIndTreatStartTime() + "、指示者=" + bodyData.getInd_user_id() + "、更新者=" + bodyData.getUpd_user_id() + "])";
        eventLogMessage.setLogMessage(strMsg);
        logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
        return new ResponseEntity<>("患者治療パターン情報の登録に失敗しました。", null, HttpStatus.INTERNAL_SERVER_ERROR);
      }
      editData.setTreatType(Double.parseDouble(bodyData.getTreat_type()));
      editData.setIndTreatStartDate(treatDays.getString(0));
      editData.setIndSchInfo(indSchInfo);
      editData.setIndTreatmentCd(ordMain.getIndTreatmentCd());
      editData.setIndKurCd((long) ordMain.getIndKurCd());
      editData.setIndCondInfo(ordMain.getIndCondInfo());
      editData.setIndMediInfo(ordMain.getIndMediInfo());
      editData.setIndEquipInfo(ordMain.getIndEquipInfo());
      editData.setIndIndCommentInfo(ordMain.getIndIndCommentInfo());
      editData.setIndTareInfo(ordMain.getIndTareInfo());
      editData.setIndOffWaterInfo(ordMain.getIndOffWaterInfo());
      editData.setIndDeviceSetInfo(ordMain.getIndDeviceSetInfo());
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("変更対象曜日パターン:" + patTreatPatternWeek.toString()
        + " 治療方法コード:" + editData.getIndTreatmentCd());
      logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
      for (int i = 0; i < patTreatPatternWeek.size(); i++) {
        editData.setTreatWeek(patTreatPatternWeek.get(i));
        List<Integer> weekArr = new ArrayList<Integer>();
        weekArr.add((int) patTreatPatternWeek.get(i));
        int patPatternCount = patTreatmentPatternUtils.createPatTreatmentPatternForTreatPlan(
          Long.parseLong(bodyData.getPat_id()),
          bodyData.getFacility_cd(),
          weekArr,
          Timestamp.valueOf(LocalDateTime.now()),
          editData
        );
      }
    }
    //add #12680 直近の過去指示（投与薬剤を含まない）で予定を作成すると不正データが発生する zrx start
    if(!ordMainAfterList.isEmpty()) {
      List<Long> createdOrdNoList = ordMainAfterList.stream().map(OrdMain::getOrdNo).toList();
      // ord_schedule
      ordScheduleDao.insertOrdScheduleList(ordMainAfterList);
      // pat_ind_approve
      patIndApproveDao.insertList(createdOrdNoList, bodyData.getFacility_cd());
      // ord_material_save
      ordMaterialSaveService.bulkCreateByOrdNoInCondMediEquip(createdOrdNoList.get(0), createdOrdNoList);
      // 最終日が未指定の場合にスケジュール延長最終日を更新
      if (null == patMain.getSch_ext_end_date() && "false".equals(bodyData.getIs_deadline()) ) {
        // フロント IndMedicineCreateBase.maxDate と同様: 本日 +1 年の月末を YYYYMMDD で保持
        String schExtEnd = LocalDate.now()
          .plusYears(1)
          .with(TemporalAdjusters.lastDayOfMonth())
          .format(DateTimeFormatter.BASIC_ISO_DATE);
        patMain.setSch_ext_end_date(schExtEnd);
        patMainDao.update(patMain);
      }

      // 指示履歴・連携関連呼出はトランザクション確定後に実行
      List<OrdMain> createdOrdMains = new ArrayList<>(ordMainAfterList);
      TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
        @Override
        public void afterCommit() {
          try {
            // 指示履歴
            if (indHistoryMakeService.isToMongo()) {
              ApiEntityOrdMain.ValiCreateTreatPlan historyBodyData = new ApiEntityOrdMain.ValiCreateTreatPlan();
              historyBodyData.setFacility_cd(bodyData.getFacility_cd());
              historyBodyData.setPat_id(bodyData.getPat_id());
              historyBodyData.setStart_date(createdOrdMains.get(0).getTreatDate().replaceAll("(\\d{4})(\\d{2})(\\d{2})", "$1-$2-$3"));
              historyBodyData.setEnd_date(createdOrdMains.get(createdOrdMains.size() - 1).getTreatDate().replaceAll("(\\d{4})(\\d{2})(\\d{2})", "$1-$2-$3"));
              historyBodyData.setIs_deadline(bodyData.getIs_deadline());
              historyBodyData.setInd_kur_cd(String.valueOf(createdOrdMains.get(0).getIndKurCd()));
              historyBodyData.setInd_user_id(new java.math.BigInteger(bodyData.getInd_user_id()));
              historyBodyData.setUpd_user_id(new java.math.BigInteger(bodyData.getUpd_user_id()));
              historyBodyData.setTreat_type(bodyData.getTreat_type());
              indHistoryMakeService.createPlanHistory(
                historyBodyData,
                createdOrdMains.get(0),
                createdOrdMains.stream().map(OrdMain::getTreatWeek).map(Short::intValue).distinct().toList()
              );
            }

            // 連携関連呼出
            List<Object> objectList = new ArrayList<>(createdOrdMains);
            Map<String, List<Object>> journalResultAllChangedDataInfoList = new HashMap<>();
            journalResultAllChangedDataInfoList.put("ord_main", objectList);
            List<JournalCreateRequestPayload> journalList = journalCreatePayloadService.createJournalPayload(
              bodyData.getFacility_cd(),
              journalResultAllChangedDataInfoList,
              null,
              List.of(Long.parseLong(bodyData.getPat_id())),
              Long.parseLong(bodyData.getUpd_user_id()),
              "PAT_VIEWER_PLAN"
            );
            if (!CollectionUtils.isEmpty(journalList)) {
              journalService.callCreateJournalForCtrNo(journalList);
            }
          } catch (Exception e) {
            EventLogMessage afterCommitLog = new EventLogMessage();
            afterCommitLog.setLogMessage("insertByOrdNo afterCommit 連携関連呼出 " + e.getMessage());
            logService.log(LogLevel.ERROR, afterCommitLog, LoggingConstant.FUNCTION_CODE.FUNC_SCHEDULE_LIST,
              LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
      });
    }
    //add #12680 直近の過去指示（投与薬剤を含まない）で予定を作成すると不正データが発生する zrx end
    return new ResponseEntity<>(ordNoList.toString(), null, HttpStatus.OK);
  }

  //add #11841 【たくしん会】ord_mainの登録不正 zrx start
  @Override
  public OrdMain delJSONKey(OrdMain ordMain) {
    try {
      ObjectMapper mapper = new ObjectMapper();
      String indCondInfo = ordMain.getIndCondInfo();

      JsonNode indCondJsonNode = mapper.readTree(indCondInfo);
      Iterator<Map.Entry<String, JsonNode>> indCondFields = indCondJsonNode.fields();
      while(indCondFields.hasNext()) {
        Map.Entry<String, JsonNode> field = indCondFields.next();
        String key = field.getKey();
        JsonNode value = field.getValue();
        if ("5".equals(key)) {
          ((ObjectNode) value).remove("value_name_2");
        }
        ((ObjectNode) value).remove("unit");
        ((ObjectNode) value).remove("value_name_1");
      }
      ordMain.setIndCondInfo(indCondJsonNode.toString());

      String indMediInfo = ordMain.getIndMediInfo();
      if(!ObjectUtils.isEmpty(indMediInfo)){
        ArrayNode indMediInfoArray = (ArrayNode) mapper.readTree(indMediInfo);
        for (JsonNode itemNode : indMediInfoArray) {
          if (itemNode.isObject()) {
            ObjectNode objNode = (ObjectNode) itemNode;
            objNode.remove("class_cd");
            objNode.remove("class_name");
            objNode.remove("class_type");
            objNode.remove("name");
            objNode.remove("short_name");
            objNode.remove("unit");
            objNode.remove("timing_name");
            objNode.remove("procedure_name");
          }
        }
        ordMain.setIndMediInfo(indMediInfoArray.toString());
      }

      String indEquipInfo = ordMain.getIndEquipInfo();
      if(!ObjectUtils.isEmpty(indEquipInfo)){
        ArrayNode indEquipArray = (ArrayNode) mapper.readTree(indEquipInfo);
        for (JsonNode itemNode : indEquipArray) {
          if (itemNode.isObject()) {
            ObjectNode objNode = (ObjectNode) itemNode;
            objNode.remove("name");
            objNode.remove("short_name");
            objNode.remove("class_cd");
            objNode.remove("class_name");
            objNode.remove("class_type");
            objNode.remove("unit");
          }
        }
        ordMain.setIndEquipInfo(indEquipArray.toString());
      }
    }catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ordMain != null && !StringUtils.isEmpty(ordMain.getFacilityCd())) {
        eventLogMessage.setFacilityCd(ordMain.getFacilityCd());
      }
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }
    return ordMain;
  }
  //add #11841 【たくしん会】ord_mainの登録不正 zrx end

  @Override
  //mod #12462 患者共有情報- 患者カレンダー by zrx start
//  public PatCalendarEvent selectPatCalendarFor3Months(String startDate, String endDate, String weekPattern, String facilityCd, Long patId) {
  public PatCalendarEvent selectPatCalendarFor3Months(String startDate, String endDate,
                                                      String weekPattern, String facilityCd, Long patId, Integer patShareMode) {
    //mod #12462 患者共有情報- 患者カレンダー by zrx end
    PatCalendarEvent result = new PatCalendarEvent();

    //指示を取得
    List<OrdMainSharingInfo> indInfoList = new ArrayList<>();
    String dateFrom = ((null != startDate) && (false == "".equals(startDate))) ? startDate : null;
    String dateTo = ((null != endDate) && (false == "".equals(endDate))) ? endDate : null;
    // 治療方法変更の対象となるレコードを抽出
    List<Integer> weeksArry = IndicationUtils.getWeekPattern(weekPattern);
    indInfoList = findByDateCdSharingInfo(facilityCd,
      patId,
      dateFrom,
      dateTo,
      null,
      weeksArry,
      null);
    if (indInfoList == null) {
      indInfoList = new ArrayList<>();
    }

    // バイタルデータを取得（透析前血圧、透析後血圧、体温）
    List<Long> ordNoList =
      indInfoList.stream().filter(info -> !"1".equals(info.getRstDialysisState()))
        .map(OrdMainSharingInfo::getOrdNo)
	      .collect(Collectors.toList());
    List<MniMonitor> mniMonitorList = mniMonitorDao.selectVitalByFacilityCdAndOrdNos(facilityCd, ordNoList);
    for (OrdMainSharingInfo info : indInfoList) {
      List<MniMonitor> monitors = new ArrayList<>();
      for (MniMonitor monitor : mniMonitorList) {
        if (info.getOrdNo().equals(monitor.getOrdNo())) {
            monitors.add(monitor);
      }
      }
      info.setMniMonitorList(monitors);
    }

    //add #12462 患者共有情報- 患者カレンダー by zrx start
    if(patShareMode != null && patShareMode == 0) {
      List<OrdMain> srcPatIdsOrdMains = materialsSharingPatientInfomationService.findOrdMainByDateCdSharingInfo(
        facilityCd, patId, dateFrom, dateTo, weeksArry);
      if(srcPatIdsOrdMains != null && !srcPatIdsOrdMains.isEmpty()) {
        List<OrdMainSharingInfo> listRetSrc = srcPatIdsOrdMains.stream()
          .map(ord -> {
            OrdMainSharingInfo info = new OrdMainSharingInfo();
            BeanUtils.copyProperties(ord, info);
            info.setReadOnly(true);
            return info;
          })
          .toList();
        if(listRetSrc != null && !listRetSrc.isEmpty()) {
          List<MniMonitor> srcMniMonitorList = new ArrayList<>();
          // 共有元施設が複数の場合、施設毎にDAOをループ実行していたが、
          // (facility_cd, ord_no)ペアを纏めて1回のIN検索で取得するよう変更
          List<Map<String, Object>> facilityCdAndOrdNoList = listRetSrc.stream()
            .filter(info -> !"1".equals(info.getRstDialysisState()))
            .map(info -> {
              Map<String, Object> pair = new HashMap<>();
              pair.put("facility_cd", info.getFacilityCd());
              pair.put("ord_no", info.getOrdNo());
              return pair;
            })
            .collect(Collectors.toList());
          if (!facilityCdAndOrdNoList.isEmpty()) {
            srcMniMonitorList.addAll(
              mniMonitorDao.selectVitalByFacilityCdAndOrdNoList(facilityCdAndOrdNoList)
            );
          }
          // 複数施設のバイタル情報が混在する可能性があるため、(facility_cd, ord_no)で照合
          for (OrdMainSharingInfo info : listRetSrc) {
            List<MniMonitor> monitors = new ArrayList<>();
            for (MniMonitor monitor : srcMniMonitorList) {
              if (info.getOrdNo().equals(monitor.getOrdNo())
                && info.getFacilityCd() != null
                && info.getFacilityCd().equals(monitor.getFacilityCd())) {
                monitors.add(monitor);
              }
            }
            info.setMniMonitorList(monitors);
          }

          indInfoList.addAll(listRetSrc);
        }
      }
    }
    //add #12462 患者共有情報- 患者カレンダー by zrx end

    result.setIndInfoList(indInfoList);

    //検査結果を取得
    List<PatExamMainData> examResultInfoList =
      patExamMainDao.selectPatExamMainByPatIdAndFacilityCode(facilityCd, patId, dateFrom, dateTo);
//    result.setExamResultInfoList(examResultInfoList);

    //検査予定を取得
    List<PatExamMainData> examRequestInfoList =
      patExamMainDao.selectPatExamRequestByPatIdAndFacilityCode(facilityCd, patId, dateFrom, dateTo);
//    result.setExamRequestInfoList(examRequestInfoList);

    //一般撮影検査予定を取得
    List<ForecastInforResult> indicationInfoList =
      indicationResultDao.selectGenPhotoInsResultByPatIdAndFacilityCode(dateFrom, dateTo, patId, facilityCd);
//    result.setIndicationInfoList(indicationInfoList);

    //add #12462 患者共有情報 by zrx start
    List<PatNameIdentification> srcPatIds = new ArrayList<>();
    if(patShareMode != null && patShareMode == 0) {
      srcPatIds = materialsSharingPatientInfomationService.getListPatIdSrcFromPatTo(patId);
    }
    //add #12462 患者共有情報 by zrx end

    //処方を取得
    List<ForecastInforResultForCount> prescriptionInfoList = new ArrayList<>();
    List<ForecastInforResult> listResult =
      indicationResultDao.selectPrescriptionResultList(dateFrom, dateTo, patId, facilityCd);
    //add #12462 患者共有情報 by zrx start
    if (srcPatIds != null && !srcPatIds.isEmpty()) {
      if (listResult == null) {
        listResult = new ArrayList<>();
      }
      for (PatNameIdentification patIdsrc : srcPatIds) {
        List<ForecastInforResult> srcListResult = indicationResultDao.selectPrescriptionResultList(
          dateFrom, dateTo, patIdsrc.getPatIdSrc(), patIdsrc.getFacilityCdSrc());
        if(srcListResult != null && !srcListResult.isEmpty()) {
          srcListResult.forEach(item -> item.setReadonly(true));
          listResult.addAll(srcListResult);
        }
      }
    }
    //add #12462 患者共有情報 by zrx end

    for (int i = Integer.parseInt(dateFrom); i < Integer.parseInt(dateTo); i++) {
      ForecastInforResultForCount forecastItem = new ForecastInforResultForCount();
      forecastItem.setEventStartDate(String.valueOf(i));
      for (ForecastInforResult item : listResult) {
        if (item.getEventStartDate().equals(forecastItem.getEventStartDate())) {
          //全件
          forecastItem.setAllCount(forecastItem.getAllCount() + 1);
          //院外処方
          if (item.getPrescriptionType().equals("1")) {
            //院外処方全件
            forecastItem.setOutCount(forecastItem.getOutCount() + 1);
            if (item.getIssueState().equals("1")) {
              //院外処方済み件
              forecastItem.setOutOkCount(forecastItem.getOutOkCount() + 1);
            }
          }
          //院内処方
          else {
            //院内処方全件
            forecastItem.setInCount(forecastItem.getInCount() + 1);
            if (item.getIssueState().equals("1")) {
              //院内処方済み件
              forecastItem.setInOkCount(forecastItem.getInOkCount() + 1);
            }
          }
          //add #12462 患者共有情報 by zrx start
          if(patShareMode != null && patShareMode == 0) {
            forecastItem.setReadonly(item.isReadonly());
          }
          //add #12462 患者共有情報 by zrx end
        }
      }
      if (forecastItem.getAllCount() > 0) {
        forecastItem.setAllOkCount(forecastItem.getInOkCount() + forecastItem.getOutOkCount());
        prescriptionInfoList.add(forecastItem);
      }
    }
    result.setPrescriptionInfoList(prescriptionInfoList);

    // 患者イベントを取得
    List<ForecastInforResultForPatEventCount> patEventCountInfoList =
      indicationResultDao.selectPatEventCategoryCountResult(dateFrom, dateTo, patId, facilityCd);
//    result.setPatEventCountInfoList(patEventCountInfoList);

    // 施設イベントを取得
    List<BbsInfo> bbsList = bbsInfoDao.selectByIdListForCalendar(
        facilityCd,
        Collections.emptyList(),
        dateFrom,
        dateTo,
        null,
        null,
        Collections.emptyList(),
        null,
        true
    );
    // 施設イベントリストから対象患者のリスト抽出
    List<BbsInfo> filteredBbsList = bbsList.stream()
      .filter(bbs -> {
          JSONObject obj = new JSONObject(bbs.getPat_info());
          String target = obj.optString("target");

          // 全体向け
          if ("1".equals(target)) {
              return true;
      }
          // 個別対象
          if ("0".equals(target)) {
              return obj.getJSONArray("detail")
                        .toList()
                        .stream()
                        .anyMatch(id -> id.toString().equals(patId.toString()));
    }
          // 対象なし
          return false;
      })
      .collect(Collectors.toList());
//    result.setBbsInfoList(filteredBbsList);
    //add #12462 患者共有情報 by zrx start
    //患者基本情報
    List<PatMain> patMainList = new ArrayList<>();
    List<Long> patIdList = new ArrayList<>();
    PatMain patMain = patMainDao.selectById(patId);
    if(patMain != null) {
      patMainList.add(patMain);
    }

    if (srcPatIds != null && !srcPatIds.isEmpty()) {

      if (examResultInfoList == null) {
        examResultInfoList = new ArrayList<>();
      }
      if (examRequestInfoList == null) {
        examRequestInfoList = new ArrayList<>();
      }
      if (indicationInfoList == null) {
        indicationInfoList = new ArrayList<>();
      }
      if (patEventCountInfoList == null) {
        patEventCountInfoList = new ArrayList<>();
      }
      if(filteredBbsList == null) {
        filteredBbsList = new ArrayList<>();
      }

      for (PatNameIdentification patIdsrc : srcPatIds) {
        String facilityCdTemp = patIdsrc.getFacilityCdSrc();
        Long patIdTemp = patIdsrc.getPatIdSrc();
        patIdList.add(patIdTemp);
        // 検査結果
        examResultInfoList.addAll(
          patExamMainDao.selectPatExamMainByPatIdAndFacilityCode(
            facilityCdTemp,
            patIdTemp,
            dateFrom,
            dateTo
          )
        );

        // 検査予定
        examRequestInfoList.addAll(
          patExamMainDao.selectPatExamRequestByPatIdAndFacilityCode(
            facilityCdTemp,
            patIdTemp,
            dateFrom,
            dateTo
          )
        );

        // 一般撮影検査予定を取得
        indicationInfoList.addAll(
          indicationResultDao.selectGenPhotoInsResultByPatIdAndFacilityCode(
            dateFrom,
            dateTo,
            patIdTemp,
            facilityCdTemp)
        );

        //患者イベントを取得
        List<ForecastInforResultForPatEventCount> patEventInfoTempList =
          indicationResultDao.selectPatEventCategoryCountResult(
            dateFrom,
            dateTo,
            patIdTemp,
            facilityCdTemp);
        if(patEventInfoTempList != null && !patEventInfoTempList.isEmpty()) {
          for(ForecastInforResultForPatEventCount patEventCount : patEventInfoTempList) {
            patEventCount.setReadonly(true);
          }
          patEventCountInfoList.addAll(patEventInfoTempList);
        }

        //掲示板
        List<BbsInfo> srcBbsList = bbsInfoDao.selectByIdListForCalendar(
          facilityCdTemp,
          Collections.emptyList(),
          dateFrom,
          dateTo,
          null,
          null,
          Collections.emptyList(),
          null,
          true
        );
        List<BbsInfo> srcFilteredBbsList = srcBbsList.stream()
          .filter(bbs -> {
            JSONObject obj = new JSONObject(bbs.getPat_info());
            String target = obj.optString("target");

            // 全体向け
            if ("1".equals(target)) {
              return true;
            }
            // 個別対象
            if ("0".equals(target)) {
              return obj.getJSONArray("detail")
                .toList()
                .stream()
                .anyMatch(id -> id.toString().equals(patIdTemp.toString()));
            }
            // 対象なし
            return false;
          })
          .collect(Collectors.toList());
        if(srcFilteredBbsList != null && !srcFilteredBbsList.isEmpty()) {
          filteredBbsList.addAll(srcFilteredBbsList);
        }

      }
      //患者基本情報
      List<PatMain> patMainSrcList = patMainDao.selectByIdList(patIdList);
      if(patMainSrcList != null && !patMainSrcList.isEmpty()) {
        for (PatMain patMainResult : patMainSrcList) {
          //感染症
          JSONArray pastInfectJson = new JSONArray(patMainResult.getInfect_info());
          for (int i = 0; i < pastInfectJson.length(); i++) {
            JSONObject jsonObj = pastInfectJson.getJSONObject(i);
            Integer infectionCd = Integer.valueOf(jsonObj.get("infection_cd").toString());
            MstInfection mstInfection = mstInfectionDao.selectByCd(infectionCd);
            jsonObj.put("readonly", true);
            jsonObj.put("infection_name", mstInfection.getInfectionName());
          }
          //インプラント情報
          JSONArray pastImplantJson = new JSONArray(patMainResult.getImplant_info());
          for (int i = 0; i < pastImplantJson.length(); i++) {
            JSONObject jsonObj = pastImplantJson.getJSONObject(i);
            Integer implantCd = Integer.valueOf(jsonObj.get("implant_cd").toString());
            MstImplant mstImplant = mstImplantDao.selectByCd(implantCd);
            jsonObj.put("readonly", true);
            jsonObj.put("implant_name", mstImplant.getImplantName());
          }
          //感染症
          patMainResult.setInfect_info(pastInfectJson.toString());
          //インプラント情報
          patMainResult.setImplant_info(pastImplantJson.toString());
        }
        patMainList.addAll(patMainSrcList);
      }
    }
    result.setExamResultInfoList(examResultInfoList);
    result.setExamRequestInfoList(examRequestInfoList);
    result.setIndicationInfoList(indicationInfoList);
    result.setPatEventCountInfoList(patEventCountInfoList);
    result.setBbsInfoList(filteredBbsList);
    result.setPatMainList(patMainList);
    //add #12462 患者共有情報 by zrx end
    return result;
  }

  // del 11454 時間外加算自動処理が機能していない zkm start
//add 2023-03-02  6817 手動実績作成に失敗しても透析回数がカウントされてしまう 張 start
//  @Override
//  @Transactional
//  public ResponseEntity<String> getStringResponseEntity(Long ord_no, Long patId) throws URISyntaxException, RuntimeException {
//    // 戻り値情報
//    JSONObject responseData = new JSONObject();
//    // 条件送信処理呼び出し
//    ResponseEntity<String> ret = webApiCallCommonUtil.sendCondResultOnly(ord_no);
//    //mod FNSI-6817 劉全航 start
//    // メッセージ情報を格納
//    if (ret.getStatusCode() != HttpStatus.OK) {
//      responseData.put("retMsg", 99999998);
//      return new ResponseEntity<>(responseData.toString(), null, HttpStatus.OK);
//    }
//    //mod FNSI-6817 劉全航 end
//    OrdMain ordMain = ordMainDao.selectByOrdNo(ord_no);
//
//    //del 6832 【デグレ】治療記録における特殊血液浄化回数が不正 周安寧　start
//    // pat_mainを開く
//    //add redmine bug#6484 徐 start
////    EventLogMessage eventLogMessage = new EventLogMessage();
////    try {
////      PatMain pat = patMainDao.selectById(patId);
////
////      MedicalCareInfo medicalCareInfo = new MedicalCareInfo();
////      ObjectMapper mapper1 = new ObjectMapper();
////      try {
////        if (! Strings.isNullOrEmpty(pat.getMedical_care_info())) {
////          medicalCareInfo = mapper1.readValue(pat.getMedical_care_info(), MedicalCareInfo.class);
////        }
////      } catch (IOException e) {
////        e.printStackTrace();
////      }
////
////      //浄化治療回数の更新(特殊浄化の場合は更新します)
////      if (ordMainDao.checkSpecialPurification(ord_no)) {
////        Integer purificationCount = StrToInteger(medicalCareInfo.purification_count);
////        if (null != purificationCount) {
////          ++ purificationCount;
////        } else {
////          purificationCount = 1;
////        }
////        medicalCareInfo.purification_count = purificationCount.toString();
////      } else {
////        //FNSI-修正 #6484、特殊浄化場合、患者通算透析回数と自施設通算透析回数も加算されてしまった、再修正 xugj modify start
////        //透析回数の更新
////        Integer dialysisCount = StrToInteger(medicalCareInfo.dialysis_count);
////        if (null != dialysisCount) {
////          ++ dialysisCount;
////        } else {
////          dialysisCount = 1;
////        }
////        medicalCareInfo.dialysis_count = dialysisCount.toString();
////
////        //自施設透析回数の更新
////        Integer patDialysisCount = StrToInteger(medicalCareInfo.pat_dialysis_count);
////        if (null != patDialysisCount) {
////          ++ patDialysisCount;
////        } else {
////          patDialysisCount = 1;
////        }
////        medicalCareInfo.pat_dialysis_count = patDialysisCount.toString();
////        //FNSI-修正 #6484 xugj modify end
////      }
////
////      ObjectMapper mapper = new ObjectMapper();
////      patMainDao.updateMedicalCareInfo(patId, mapper.writeValueAsString(medicalCareInfo));
////
////    } catch (Exception ex) {
////      eventLogMessage.setLogMessage("患者基本情報[pat_main]の治療進捗状態[acceptance_status_info]更新 patId:" + patId + " 更新失敗 " + ex.getMessage());
////      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
////    }
//    //add redmine bug#6484 徐 end
//    //del 6832 【デグレ】治療記録における特殊血液浄化回数が不正 周安寧　end
//
//    //del #10412 次患者更新関連全体見直し対応 朴 start
////    String facilityCd = ordMain.getFacilityCd();
////    Long skipCode = Long.parseLong("0");
////    Long indbedCd = Long.parseLong(ordMain.getIndBedCd().toString());
////    Long beforeBedCd = indbedCd == null ? skipCode : indbedCd;
////    LocalDateTime update = LocalDateTime.now();
////    // 登録されているベッド(条件送信キャンセルとして処理させるため変更前ベッドに設定)
////    //mod  6345 過去の未実施スケジュールを実施済みにすると対象のベッドの装置の次患者が再送される 張 start
////    Date treat = null;
////    Date now = null;
////    SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMdd");
////    try {
////      treat = formatter.parse(ordMain.getTreatDate());
////      now = formatter.parse(formatter.format(new Date()));
////    } catch (ParseException e) {
////      e.printStackTrace();
////    }
////    if (! treat.before(now)) {
////      callDoCancelSetNextPatInfo(facilityCd, beforeBedCd, null, ord_no, false, update);
////    }
//    //del #10412 次患者更新関連全体見直し対応 朴 end
//
//    String treatDate = ordMain.getTreatDate();
//    String indTreatStartTime = ordMain.getIndTreatStartTime();
//    // add 10954 by kangjie 20240801 start
//    if (StringUtils.isEmpty(indTreatStartTime)) {
//      Integer indKurCd = ordMain.getIndKurCd();
//      MstKur mstKur = mstKurDao.selectByKurCd(indKurCd.toString());
//      indTreatStartTime = mstKur.getKurStandardStartTime().substring(0,4);
//    }
//    // add 10954 by kangjie 20240801 end
//    LocalDate day = LocalDate.parse(treatDate, DateTimeFormatter.BASIC_ISO_DATE);
//    /* mod #10043 by zhangruixue 2023-03-02  --start */
////    LocalTime time = LocalTime.of(Integer.parseInt(indTreatStartTime.substring(0, 2)), Integer.parseInt(indTreatStartTime.substring(3)));
//    LocalTime time = LocalTime.of(Integer.parseInt(indTreatStartTime.substring(0, 2)), Integer.parseInt(indTreatStartTime.substring(2,indTreatStartTime.length())));
//    /* mod #10043 by zhangruixue 2023-03-02  --end */
//    LocalDateTime dateTime = LocalDateTime.of(day, time);
//    ordMain.setRstStartDate(Timestamp.valueOf(dateTime));
//    NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
//    ordMain.setLogUserId(user.getUserId().toString());
//    ordMainDao.update(ordMain);
//    // 手動実績作成の場合「条件送信前⇒チェックリスト実績を新規作成」「実施状態（0：未実施）」「実績区分（1：条件送信後）」
//    // 手動実績作成の場合「条件送信前⇒チェックリスト実績を更新」   「実績区分（0：条件送信前）⇒（1：条件送信後）」
//    // 手動実績作成の場合「条件送信前⇒チェックリスト実績を新規作成」「実施状態（9：リスト基準）」
//    //9324 gjn start
//    List<Long> ordnoList = new ArrayList<>();
//    ordnoList.add(ordMain.getOrdNo());
//    updateOrdChecklistByActionBeCurrent(
//      OrdMainResource.OrdMainActionForChecklist.TREATPLAN_RESULT_CREATE,
//      ordnoList
//    );
//    //9324 gjn end
//    // #10196 del by Zhou.tao Start  >> There's no need to rebuild materialSave record.
////    treatmentStatusListService.middleCheck(ordMain);
//    // #10196 del by Zhou.tao End
//    return new ResponseEntity<>(responseData.toString(), null, HttpStatus.OK);
//  }
  // del 11454 時間外加算自動処理が機能していない zkm end

  /* del by chamaojia 2026-05-07 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
  // public static class MedicalCareInfo {
  //   public String facility_cd;            //施設コード
  //   public String ward_cd;                //病棟コード
  //   public String main_course_cd;         //診療科主科コード
  //   public String dialysis_course_cd;     //診療科透析実施科コード
  //   // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
  //   //public String dialysis_count;         //透析回数
  //   //public String pat_dialysis_count;     //自施設透析回数
  //   //public String other_dialysis_count;   //他施設透析回数
  //   //public String purification_count;     //浄化治療回数
  //   public Integer dialysis_count;         //透析回数
  //   public Integer pat_dialysis_count;     //自施設透析回数
  //   public Integer other_dialysis_count;   //他施設透析回数
  //   public Integer purification_count;     //浄化治療回数
  //   // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
  //   public String dialysis_start_date;    //透析導入日
  //   public String hospital_start_date;    //当院開始日
  // }
  /* del by chamaojia 2026-05-07 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */

  /**
   * 数字文字列をIntegerに変換する
   *
   * @param text 変換を行う文字列
   * @return null：変換失敗/else：変換値
   */
  private Integer StrToInteger(String text) {
    Integer ret = null;
    try {
      // mod 8138 修正 chen start
      if (text != null && ! text.isEmpty() && !jsonNodeIsNull(text)) {
        // mod 8138 修正 chen end
        ret = Integer.parseInt(text);
      }
    } catch (Exception ex) {
    }
    return ret;
  }
  private boolean jsonNodeIsNull(Object obj) {
    return Objects.isNull(obj) || "null".equals(obj.toString()) || "".equals(obj.toString());
  }

  //del #10412 次患者更新関連全体見直し対応 朴 start
//  /**
//   * 条件送信キャンセル・次患者更新実行
//   *
//   * @param facilityCd
//   * @param beforeBedCd 変更前ベッドコード※未登録など処理不要の場合 null
//   * @param afterBedCd  変更後ベッドコード※未登録など処理不要の場合 null
//   * @param targetOrdNo ord_no
//   * @param isIndChange ord_main治療条件変更フラグ※変更なしの場合 false
//   * @param update      更新日時
//   * @return message
//   * @description パラメータで条件送信キャンセル処理しない場合がある
//   */
//  public String callDoCancelSetNextPatInfo(String facilityCd, Long beforeBedCd, Long afterBedCd, Long targetOrdNo, boolean isIndChange, LocalDateTime update) {
//    JSONObject errorMsgJson = new JSONObject("{}");
//    int doCancelErrorCounter = 0;
//    int postOrderCancelConditionErrorCounter = 0;
//    int setNextPatInfoErrorCounter = 0;
//    int postOrderSendNextPatErrorCounter = 0;
//    boolean isDoCancelSuccess = false;
//
//    //開始ログ
//    final String className = new Object() {
//    }.getClass().getEnclosingClass().getName();
//    final String methodName = new Object() {
//    }.getClass().getEnclosingMethod().getName();
//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage(className + "." + methodName + " 処理開始");
//    eventLogMessage.setLogMessage(className + "." + methodName + " 処理開始");
//    logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
//    OrdMain targetOrdMain = ordMainDao.selectByOrdNo(targetOrdNo);
//    Date treat = null;
//    Date now = null;
//    SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMdd");
//    OrdMain currOrdMain = null;
//    String message = "";
//    if (beforeBedCd != null && beforeBedCd != 0) {
//      eventLogMessage.setLogMessage(className + "." + methodName + " 変更前ベッド：処理開始");
//      logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
//      List<MstMachine> machines = mstMachineDao.selectByBedCd(facilityCd, beforeBedCd);
//      if (machines.size() != 0) {
//        // mst_machine_stateに設定(対象あり)
//        //【条件送信キャンセル処理】
//        // 装置取得(条件送信キャンセル対象)
//        MstMachine machine = machines.get(0);
//        try {
//          ComsvMntMachineState machineState = mntMachineStateDao.selectMachineKey(facilityCd, machine.getMachineTypeCd(), machine.getMachineSerial());
//          Long sendOrdNo = machineState.getOrdNo();
//          eventLogMessage.setLogMessage(className + "." + methodName + " 変更前ベッド：mnt_machine_state.ord_no:[" + sendOrdNo + "]");
//          logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
//          currOrdMain = ordMainDao.selectByOrdNo(sendOrdNo);
//          boolean isNotOrdMain = false;
//          if (sendOrdNo != null && currOrdMain == null) {
//            eventLogMessage.setLogMessage(className + "." + methodName + " 変更前ベッド：ord_mainが存在しない。ord_no:[" + sendOrdNo + "]");
//            logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
//            // 条件送信状態でord_mainが存在しない場合は問答無用で条件送信キャンセルを実行する
//            isNotOrdMain = true;
//          }
//          boolean isSendCondition = isSendCondition(facilityCd, currOrdMain, true);
//
//          if (isSendCondition && targetOrdNo.equals(sendOrdNo) || isNotOrdMain) {
//            // 条件送信済みが存在しかつ条件送信済みord_noなら条件送信キャンセル実行
//            // 以下の順で処理を行う
//            //   1. 条件送信キャンセルのDB更新
//            //   2. 次患者更新API要求(通知は不要 ※条件送信キャンセル通知を受けたDE側で実施)
//            //   3. 条件送信キャンセル通知
//
//            // ◆1. 条件送信キャンセルのDB更新
//            // ◆2. 次患者更新API要求
//            //※doCancelにて1と2を実行
//            eventLogMessage.setLogMessage(className + "." + methodName + " 変更前ベッド：条件送信キャンセルDB更新&次患者更新API要求開始(doCancel) facilityCd:[" + facilityCd + "] machineTypeCd:[" + machine.getMachineTypeCd() + "] machineSerial:[" + machine.getMachineSerial() + "] ord_no:[" + targetOrdNo + "]");
//            logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
//            SendConditionCancelResponse sendConditionCancelRes = sendConditionCancelService.doCancel(machine, targetOrdNo, null, sendOrdNo);
//
//            if (sendConditionCancelRes.isSuccess) {
//              isDoCancelSuccess = true;
//              // 条件送信キャンセル成功なら通信サーバー通知
//              // ◆3. 条件送信キャンセル通知
//              eventLogMessage.setLogMessage(className + "." + methodName + " 変更前ベッド：doCancel成功／条件送信キャンセル通知開始 facilityCd:[" + facilityCd + "] deviceEdgeNo:[" + machine.getDeviceEdgeNo() + "] machineNo:[" + machine.getMachineNo() + "]");
//              logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
//              ResponseEntity<?> responsePostOrderCancelCondition = postOrderCancelCondition(facilityCd, machine.getDeviceEdgeNo(), machine.getMachineNo());
//              if (responsePostOrderCancelCondition.getStatusCode() != HttpStatus.OK) {
//                postOrderCancelConditionErrorCounter++;
//                eventLogMessage.setLogMessage(className + "." + methodName + " 変更前ベッド：「条件送信キャンセル通信サーバー通知」失敗 facilityCd:[" + facilityCd + "] deviceEdgeNo:[" + machine.getDeviceEdgeNo() + "] machineNo:[" + machine.getMachineNo() + "]");
//                logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
//              }
//            } else {
//              doCancelErrorCounter++;
//              message = "「条件送信キャンセル」失敗しました";
//              eventLogMessage.setLogMessage(className + "." + methodName + " 変更前ベッド：" + message + "(doCancelに失敗 ベッドコード=" + beforeBedCd);
//              logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
//            }
//          } else {
//            // 条件送信キャンセル対象外ベッド
//            eventLogMessage.setLogMessage(className + "." + methodName + " 変更前ベッド：条件送信キャンセル対象外 facilityCd:[" + facilityCd + "] beforeBedCd:[" + beforeBedCd + "] targetOrdNo:[" + targetOrdNo + "]");
//            logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
//          }
//        } catch (RuntimeException e) {
//          message = "「条件送信キャンセル」失敗しました";
//          eventLogMessage.setLogMessage(className + "." + methodName + " 変更前ベッド：" + message + "(例外発生 facilityCd:[" + facilityCd + "] beforeBedCd:[" + beforeBedCd + "] targetOrdNo:[" + targetOrdNo + "])");
//          logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
//          e.printStackTrace();
//        }
//        // mod FNSI - 1006 No.396 end -- Sanjingye Sun 20210118
//
//        //【次患者更新処理】
//        try {
//          List<MntMachineState> machineStateList = mntMachineStateDao.selectByBedCd(beforeBedCd);
//          MntMachineState machineState = machineStateList.get(0);
//          Long sendOrdNo = machineState.getNextOrdNo();
//          OrdMain sendOrdMain = ordMainDao.selectByOrdNo(sendOrdNo);
//          boolean isSendCondition = isSendCondition(facilityCd, sendOrdMain, false);
//          Long nextOrdNo = machineState.getNextOrdNo();
//          boolean isFastAfterKurTime = isFastAfterKurTime(facilityCd, targetOrdNo, nextOrdNo, machineState.getStartPlanDate(), update);
//
//          if (! isSendCondition && isFastAfterKurTime) {
//            // 条件送信済みが存在しないかつ現患者の前に移動するなら
//            eventLogMessage.setLogMessage(className + "." + methodName + " 変更前ベッド：次患者更新開始");
//            logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
//            // 次患者更新&通信サーバー通知
//            // mod 6963 過去のスケジュールを編集すると対象のベッドの装置の次患者が再送される 房 start
//            ResponseEntity<String> responseSetNextPatInfo = null;
//            if (targetOrdMain != null && targetOrdMain.getTreatDate() != null) {
//              try {
//                treat = formatter.parse(targetOrdMain.getTreatDate());
//                now = formatter.parse(formatter.format(new Date()));
//                if (!treat.before(now)) {
//                  responseSetNextPatInfo = webApiCallCommonUtil.SetNextPatInfo(beforeBedCd, isIndChange, update);
//                }
//              } catch (ParseException e) {
//                e.printStackTrace();
//              }
//            }
//            if (responseSetNextPatInfo != null) {
//              JSONObject json = new JSONObject(responseSetNextPatInfo.getBody().toString());
//              if (! json.has("isSuccess")) {
//                // 次患者更新エラー
//                setNextPatInfoErrorCounter++;
//                eventLogMessage.setLogMessage(className + "." + methodName + " 変更前ベッド：「次患者更新」失敗 facilityCd:[" + facilityCd + "] beforeBedCd:[" + beforeBedCd + "]");
//                logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
//              } else if (responseSetNextPatInfo.getStatusCode() != HttpStatus.OK) {
//                // 次患者通知エラー
//                postOrderSendNextPatErrorCounter++;
//                eventLogMessage.setLogMessage(className + "." + methodName + " 変更前ベッド：「次患者更新通信サーバー通知」失敗 facilityCd:[" + facilityCd + "] beforeBedCd:[" + beforeBedCd + "]");
//                logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
//              }
//            }
//            // mod 6963 過去のスケジュールを編集すると対象のベッドの装置の次患者が再送される 房 end
//          }
//        } catch (URISyntaxException | RuntimeException e) {
//          message = "「次患者更新」失敗しました";
//          eventLogMessage.setLogMessage(className + "." + methodName + " 変更前ベッド：" + message + "(例外発生 facilityCd:[" + facilityCd + "] beforeBedCd:[" + beforeBedCd + "] targetOrdNo:[" + targetOrdNo + "])");
//          logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
//          e.printStackTrace();
//        }
//      }
//      eventLogMessage.setLogMessage(className + "." + methodName + " 変更前ベッド：処理終了");
//      logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
//    } else {
//      eventLogMessage.setLogMessage(className + "." + methodName + " 変更前ベッド：処理なし");
//      logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
//    }
//
//    if (afterBedCd != null && afterBedCd != 0 && ! beforeBedCd.equals(afterBedCd)) {
//      // --------------------
//      // 変更後のベッド
//      // --------------------
//      eventLogMessage.setLogMessage(className + "." + methodName + " 変更後ベッド：処理開始");
//      logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
//
//      List<MntMachineState> machineStateList = mntMachineStateDao.selectByBedCd(afterBedCd);
//      MntMachineState machineState = machineStateList.get(0);
//      Long sendOrdNo = machineState.getOrdNo();
//      OrdMain sendOrdMain = ordMainDao.selectByOrdNo(sendOrdNo);
//      boolean isSendCondition = isSendCondition(facilityCd, sendOrdMain, false);
//      Long nextOrdNo = machineState.getNextOrdNo();
//
//      try {
//        if (! isSendCondition || targetOrdNo.equals(sendOrdNo)) {
//          // 条件送信済み～治療中ではない、または、送信済みord_noと同じなら
//          boolean isFastAfterKurTime = isFastAfterKurTime(facilityCd, targetOrdNo, nextOrdNo, machineState.getStartPlanDate(), update);
//          if (isFastAfterKurTime) {
//            eventLogMessage.setLogMessage(className + "." + methodName + " 変更後ベッド：次患者更新開始");
//            logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
//            // 設定されている時刻より前なら
//            // mod 6963 過去のスケジュールを編集すると対象のベッドの装置の次患者が再送される 房 start
//            ResponseEntity<String> responseSetNextPatInfo = null;
//            if (targetOrdMain != null && targetOrdMain.getTreatDate() != null) {
//              try {
//                treat = formatter.parse(targetOrdMain.getTreatDate());
//                now = formatter.parse(formatter.format(new Date()));
//                if (!treat.before(now)) {
//                  // #9290 2023.10.03 mod isSendCondition = true のときは元々のord_noを使用する TDC片口 start
////                  responseSetNextPatInfo = webApiCallCommonUtil.OverrideSetNextPatInfo(afterBedCd, isIndChange, update, targetOrdNo.equals(sendOrdNo));
//                  responseSetNextPatInfo = webApiCallCommonUtil.OverrideSetNextPatInfo(afterBedCd, isIndChange, update, targetOrdNo.equals(sendOrdNo), targetOrdNo.equals(sendOrdNo) ? targetOrdNo : null);
//                  // #9290 2023.10.03 mod isSendCondition = true のときは元々のord_noを使用する TDC片口 start
//                }
//              } catch (ParseException e) {
//                e.printStackTrace();
//              }
//            }
//            if (responseSetNextPatInfo != null) {
//              JSONObject json = new JSONObject(responseSetNextPatInfo.getBody().toString());
//              if (! json.has("isSuccess")) {
//                // 次患者更新エラー処理
//                setNextPatInfoErrorCounter++;
//                eventLogMessage.setLogMessage(className + "." + methodName + " 変更後ベッド：「次患者更新」失敗 facilityCd:[" + facilityCd + "] afterBedCd:[" + afterBedCd + "]");
//                logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
//              } else if (responseSetNextPatInfo.getStatusCode() != HttpStatus.OK) {
//                postOrderSendNextPatErrorCounter++;
//                eventLogMessage.setLogMessage(className + "." + methodName + " 変更後ベッド：「次患者更新通信サーバー通知」失敗 facilityCd:[" + facilityCd + "] afterBedCd:[" + afterBedCd + "]");
//                logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
//              }
//            }
//            // mod 6963 過去のスケジュールを編集すると対象のベッドの装置の次患者が再送される 房 end
//          }
//
//        } else {
//          eventLogMessage.setLogMessage(className + "." + methodName + " 変更後ベッド：条件送信済みが存在するため「次患者更新」処理しない" + "(facilityCd:[" + facilityCd + "] afterBedCd:[" + afterBedCd + "])");
//          logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
//        }
//      } catch (URISyntaxException | RuntimeException e) {
//        message = "「次患者更新」失敗しました";
//        eventLogMessage.setLogMessage(className + "." + methodName + " 変更後ベッド：" + message + "(例外発生 facilityCd:[" + facilityCd + "] afterBedCd:[" + afterBedCd + "] targetOrdNo:[" + targetOrdNo + "])");
//        logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
//        e.printStackTrace();
//      }
//      eventLogMessage.setLogMessage(className + "." + methodName + " 変更後ベッド：処理終了");
//      logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
//    } else {
//      eventLogMessage.setLogMessage(className + "." + methodName + " 変更後ベッド：処理なし");
//      logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
//    }
//
//    // add FNSI 1006 No.396 start -- Sanjingye Sun 20210118
//    if (currOrdMain != null) {
//      ordMaterialSaveService.cancelSendCondition(currOrdMain.getOrdNo());
//    }
//    // add FNSI 1006 No.396 end -- Sanjingye Sun 20210118
//
//    errorMsgJson.put("message", message);
//    errorMsgJson.put("doCancel", doCancelErrorCounter);
//    errorMsgJson.put("postOrderCancelCondition", postOrderCancelConditionErrorCounter);
//    errorMsgJson.put("setNextPatInfo", setNextPatInfoErrorCounter);
//    errorMsgJson.put("postOrderSendNextPat", postOrderSendNextPatErrorCounter);
//    errorMsgJson.put("isDoCancelSuccess", isDoCancelSuccess);
//    eventLogMessage.setLogMessage(className + "." + methodName + " 処理終了");
//    logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
//    return errorMsgJson.toString();
//  }
  //del #10412 次患者更新関連全体見直し対応 朴 end

  // add FNSI-チェックリスト仕様変更対応#401、#439_患者経過総合ビューア機能分。 周 start


  //add 9324 治療情報を異なる状態で変更した後のord_checklistの再編成共通方法 gjn start
  /**
   * ord_checklist作成共通方法 admin-web
   *
   * @param action
   * @param insOrdNoList
   */
  public void updateOrdChecklistByActionBeCurrent(OrdMainResource.OrdMainActionForChecklist action, List<Long> insOrdNoList) {
    List<OrdMainForCheckListSchedule> ordMainList = ordMainDao.selectByOrdNoListChecklist(insOrdNoList);
    for (OrdMainForCheckListSchedule ordMain : ordMainList) {
      if (ordMain == null) {
        ordChecklistDao.deleteByOrdNo(ordMain.getOrdNo(), ordMain.getFacilityCd());
        return;
      }
      String rstDialysisState = ordMain.getRstDialysisState();
      switch (action) {
        // 治療情報移動の場合「条件送信前⇒チェックリスト実績を物理削除」
        case TREATPLAN_DELETE:
        case TREATPLAN_UPDATE_METHOD_DELETE:
          // 治療情報中止の場合「条件送信前⇒チェックリスト実績を物理削除」
          //OrdMain ordMainTreatplanDelete = ordMainDao.selectByOrdNo(insOrdNo);
          //rstDialysisState = ordMainTreatplanDelete.getRstDialysisState();
//        if ("0".equals(rstDialysisState)) {
          // 実績：治療状況「条件送信前」
          // チェックリスト実績を物理削除
          ordChecklistDao.deleteByOrdNo(ordMain.getOrdNo(), ordMain.getFacilityCd());
//        }
          break;
        case TREATPLAN_RESULT_CREATE:
          // 手動実績作成の場合「条件送信前⇒チェックリスト実績を新規作成」「実施状態（0：未実施）」「実績区分（1：条件送信後）」
          // 手動実績作成の場合「条件送信前⇒チェックリスト実績を更新」   「実績区分（0：条件送信前）⇒（1：条件送信後）」
          // 手動実績作成の場合「条件送信前⇒チェックリスト実績を新規作成」「実施状態（9：リスト基準）」
          //手动实际做成里面有与预定是check状态的marge过程
          try {
            syncOrdChecklistForResult(ordMain.getOrdNo());
          } catch (IOException e) {
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
            logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
          }
          break;
        // add FNSI-#401患者経過総合ビューア機能分仕様追加対応 周 end
        case TREATMENT_METHODS_CHANG: //実際の治療方法の変更
        case TREATPLAN_MOVE: //预定移动
        case CONDITION_DO_CANCEL: //条件送信キャンセル処理
        case TREATPLAN_UPDATE_METHOD_ALL: //预定更新
          // 治療方法変更の場合「治療方法セットの内容で全て変更」「変更後⇒登録」
          // チェックリスト実績を同期「治療条件」「投与薬剤」「医療材料」
        case TREATPLAN_UPDATE_METHOD_NOMEDICINE:
//        // 治療方法変更の場合「治療方法セットの内容で治療条件と医療材料を変更」「変更後⇒登録」
        case TREATPLAN_CONDITION_UPDATE:
          // 治療条件更新の場合「条件送信前⇒チェックリスト実績を物理削除」
          // 治療条件更新の場合「条件送信以降⇒チェックリスト実績を同期」
        case TREATPLAN_MEDICINE_CREATE:
          // 投与薬剤登録の場合「条件送信前⇒対象外」
          // 投与薬剤登録の場合「条件送信以降⇒チェックリスト実績を同期」
        case TREATPLAN_MEDICINE_UPDATE:
          // 投与薬剤更新の場合「条件送信前⇒チェックリスト実績を更新」
          // 投与薬剤更新の場合「条件送信以降⇒チェックリスト実績を同期」
        case TREATPLAN_MEDICINE_DELETE:
          // 投与薬剤削除の場合「条件送信前⇒チェックリスト実績を物理削除」
          // 投与薬剤削除の場合「条件送信以降⇒チェックリスト実績を同期」
          // チェックリスト実績を同期「投与薬剤」
          //syncOrdChecklist(insOrdNo, false, true, false);
        case TREATPLAN_EQUIPMENT_CREATE:
          // 医療材料登録の場合「条件送信前⇒対象外」
          // 医療材料登録の場合「条件送信以降⇒チェックリスト実績を同期」
        case TREATPLAN_EQUIPMENT_UPDATE:
          // 医療材料更新の場合「条件送信前⇒チェックリスト実績を更新」
          // 医療材料更新の場合「条件送信以降⇒チェックリスト実績を同期」
        case TREATPLAN_EQUIPMENT_DELETE:
          // 医療材料削除の場合「条件送信前⇒チェックリスト実績を物理削除」
          // 医療材料削除の場合「条件送信以降⇒チェックリスト実績を同期」
          // チェックリスト実績を同期「医療材料」
          makeOrdCheckListByOrdChange(ordMain, rstDialysisState);
          break;
      }
    }
    //add 9324 治療情報を異なる状態で変更した後のord_checklistの再編成共通方法 gjn end
  }


  //add 9324 治療情報を異なる状態で変更した後のord_checklistの再編成共通方法 gjn start
  /**
   * 治療情報を異なる状態で変更した後のord _ checklistの再編成共通方法
   *
   * @param ordMains
   * @param rstDialysisState
   */
  public void makeOrdCheckListByOrdChange(OrdMainForCheckListSchedule ordMains, String rstDialysisState) {
    try {
      // marge后的治療情報を取得
      List<OrdChecklist> checklistsOld = checkListService.getOrdCheckListByOrdNO(ordMains.getOrdNo());
      if (!"0".equals(rstDialysisState)) {
        //によって患者のchecklistsは、当時のmst _ checklistdのデータを逆生成し、JsonNodeフォーマットを作成して返す
        Map<String, JsonNode> jsonNodeMap = checkListService.makeMstChecklistByOrdChecklist(checklistsOld);
        String checklistCd = jsonNodeMap.keySet().size() == 1 ? jsonNodeMap.keySet().iterator().next() : null;
        // mod #12235【因島】チェックリストの治療条件：抗凝固剤での小数点桁数の扱いが不正 関 start
        //merge後のord _ mainデータと逆プッシュされたmst _ checklistdのデータに基づいて、共通を呼び出し、新しいord _ checklistデータを生成する
        List<OrdChecklist> regList = checkListMakeService.getRegisterChecklistRst(ordMains, jsonNodeMap.get(checklistCd), Long.parseLong(checklistCd), true);
        //marge後にDBを更新
        checkListMakeService.margeOrdCheckListInsCheckLeft(checklistsOld, regList);
        // mod #12235【因島】チェックリストの治療条件：抗凝固剤での小数点桁数の扱いが不正 関 end
      } else {
        //所定の状態、indデータを取得してord _ checklistを生成する
        //治療情報から指示治療条件、投与薬剤、医療材料のMstデータを取得
        // 0, dializer, 1, equipment, 2, medicine, 3, medicineMix
        List<OrdMainForCheckListSchedule> ordMainList = new ArrayList<>();
        ordMainList.add(ordMains);
        List<Object> mstData = checkListService.getMstData(ordMainList);
        // 最新のチェックリストマスタを取得
        List<MstChecklist> mstChecklist = mstChecklistDao.selectByFacilityCd(SelectOptions.get(), ordMains.getFacilityCd(), "0");
        MstChecklist nowMstChecklist = mstChecklist.get(0);
        String strSetting = nowMstChecklist.getChecklistSettings();
        ObjectMapper map = new ObjectMapper();
        JsonNode node = map.readTree(strSetting);
        //merge後のord _ mainデータと逆プッシュされたmst _ checklistdのデータに基づいて、共通を呼び出し、新しいord _ checklistデータを生成する
        List<OrdChecklist> regList = checkListService.getRegisterChecklist(ordMains, node, nowMstChecklist.getChecklistCd(), false, mstData);
        //marge後にDBを削除
        checkListService.margeOrdCheckListInsDel(checklistsOld, regList);
      }
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ordMains != null && !StringUtils.isEmpty(ordMains.getFacilityCd())) {
        eventLogMessage.setFacilityCd(ordMains.getFacilityCd());
      }
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }
  }
  //add 9324 治療情報を異なる状態で変更した後のord_checklistの再編成共通方法 gjn end


  /**
   * 条件送信済みフラグ
   *
   * @param facilityCd
   * @param ordMain    治療状況を取得したいord_noを設定
   * @param isCancel   条件送信キャンセルを行う場合trueを設定
   */
  private boolean isSendCondition(String facilityCd, OrdMain ordMain, boolean isCancel) {
    if (ordMain == null) {
      return false;
    }

    String rstDialysisState = ordMain.getRstDialysisState();
    if (isCancel) {
      // 条件送信済みキャンセル実行するなら
      return "1".equals(rstDialysisState) || "2".equals(rstDialysisState);
    } else {
      return "1".equals(rstDialysisState) || "2".equals(rstDialysisState) || "3".equals(rstDialysisState);
    }
  }
  private ResponseEntity<?> postOrderCancelCondition(String facilityCd, Integer deviceEdgeNo, Long machineNo) {
    HttpStatus status = HttpStatus.OK;
    String retMsg = "";

    final String className = new Object() {
    }.getClass().getEnclosingClass().getName();
    final String methodName = new Object() {
    }.getClass().getEnclosingMethod().getName();
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(className + "." + methodName + " 処理開始");
    logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    DeviceEdgeOrderRequest deviceEdgeOrder = new DeviceEdgeOrderRequest();
    deviceEdgeOrder.setFacilityCd(facilityCd);
    deviceEdgeOrder.setDeviceEdgeNo(deviceEdgeNo);
    deviceEdgeOrder.setMachineNo(machineNo);

    ResponseEntity<?> res = deviceEdgeOrderResource.PostOrderCancelCondition(deviceEdgeOrder, null);
    status = res.getStatusCode();
    if (status != HttpStatus.OK) {
      retMsg = "通信サーバーへの通知失敗";
      eventLogMessage.setLogMessage(className + "." + methodName + " " + retMsg);
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    }

    eventLogMessage.setLogMessage(className + "." + methodName + " 処理終了");
    logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    return new ResponseEntity<String>(retMsg, null, status);
  }
  /**
   * 条件送信済みクールと登録治療予定クール比較
   *
   * @param facilityCd
   * @param targetOrdNo            次患者のord_no
   * @param nextOrdNo              現患者のord_no
   * @param startPlanDateTimestamp 現患者の治療開始日時
   * @param update                 現日時
   */
  private boolean isFastAfterKurTime(String facilityCd, Long targetOrdNo, Long nextOrdNo, Timestamp startPlanDateTimestamp, LocalDateTime update) {

    final String className = new Object() {
    }.getClass().getEnclosingClass().getName();
    final String methodName = new Object() {
    }.getClass().getEnclosingMethod().getName();
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(className + "." + methodName + " 処理開始(facilityCd:[" + facilityCd + "] targetOrdNo:[" + targetOrdNo + "] nextOrdNo:[" + nextOrdNo + "] startPlanDateTimestamp:[" + startPlanDateTimestamp + "] update:[" + update + "]");
    logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);

    OrdMain targetOrdMain = ordMainDao.selectByOrdNo(targetOrdNo);
    OrdMain nextOrdMain = ordMainDao.selectByOrdNo(nextOrdNo);
    if (nextOrdMain == null) {
      eventLogMessage.setLogMessage(className + "." + methodName + " 処理終了(nextOrdMain:null 返り値：true)");
      logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      return true;
    }

    // 移動対象のord_noと移動元（または移動先）ベッドの次患者のord_noを比較し
    // 同じの場合、同じベッド間移動と判別し、次患者更新を実施する
    if (nextOrdNo.equals(targetOrdNo)) {
      return true;
    }

    String treatDate = targetOrdMain.getTreatDate();
    String indTreatStartTime = targetOrdMain.getIndTreatStartTime();

    if (startPlanDateTimestamp == null) {
      eventLogMessage.setLogMessage(className + "." + methodName + " 処理終了(startPlanDateTimestamp:null 返り値：true)");
      logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      return true;
    }
    LocalDateTime startPlanDateTime = startPlanDateTimestamp.toLocalDateTime();
    LocalDateTime nowDateTime = LocalDateTime.now();
    LocalDate startPlanDate = LocalDate.of(startPlanDateTime.getYear(), startPlanDateTime.getMonth(), startPlanDateTime.getDayOfMonth());
    LocalDate nowDate = LocalDate.of(nowDateTime.getYear(), nowDateTime.getMonth(), nowDateTime.getDayOfMonth());
    if (nowDate.compareTo(startPlanDate) > 0) {
      // 設定値が本日以前のデータなら
      eventLogMessage.setLogMessage(className + "." + methodName + " 処理終了(startPlanDate:過去日 返り値：true)");
      logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      return true;
    }

    DateTimeFormatter format = DateTimeFormatter.ofPattern("yyyyMMddHHmm");
    LocalDateTime targetStartPlanDateTime = LocalDateTime.parse(treatDate + indTreatStartTime, format);

    // 移動元（または移動先）ベッドの次患者のord_noに対応する治療開始時刻がnullの場合、
    // クール未登録からの移動、またはクール未登録への移動となるため、次患者更新を実施しない。
    if (nextOrdMain.getIndTreatStartTime() == null) {
      return false;
    }

    // 現患者より次患者が前に来ているなら
    Boolean ret = startPlanDateTime.compareTo(targetStartPlanDateTime) >= 0;
    eventLogMessage.setLogMessage(className + "." + methodName + " 処理終了(startPlanDateTime:[" + startPlanDateTime + "] targetStartPlanDateTime:[" + targetStartPlanDateTime + "] 返り値：" + ret + ")");
    logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    return ret;
  }
  /**
   * 患者経過総合ビューア用、チェックリスト実績同期処理
   *
   * @param ordNo               更新対象番号「治療情報」
   * @param updateFlagCondition 治療条件更新フラグ
   * @param updateFlagMedicine  投与薬剤更新フラグ
   * @param updateFlagEquipment 医療材料更新フラグ
   */
  public boolean syncOrdChecklist(
    Long ordNo,
    boolean updateFlagCondition,
    boolean updateFlagMedicine,
    boolean updateFlagEquipment) throws IOException {
    // チェックリスト実績対象リスト「登録」「更新」「削除」
    List<OrdChecklist> insertList = new ArrayList<OrdChecklist>();
    List<OrdChecklist> updateList = new ArrayList<OrdChecklist>();
    List<OrdChecklist> deleteList = new ArrayList<OrdChecklist>();
    // チェックリスト実績対象リスト「ダミーデータ」
    List<OrdChecklist> dummyList = new ArrayList<OrdChecklist>();
    LocalDateTime update = LocalDateTime.now();

    // 治療情報を取得「治療情報番号」
    OrdMainForCheckListSchedule ordMain = ordMainDao.selectByOrdNoChecklist(ordNo);
    // ord_mainに情報がない場合
    if (ordMain == null) {
      return false;
    }

    // 条件送信以降フラグ（０：false）
    boolean isIcouFlag = false;
    String rstDialysisState = ordMain.getRstDialysisState();
    // 治療状況が空の場合は条件送信前扱い
    if ("".equals(rstDialysisState) || rstDialysisState == null || "0".equals(rstDialysisState)) {
      isIcouFlag = false;
    } else {
      isIcouFlag = true;
    }
    boolean finalIsIcouFlag = isIcouFlag;

    // チェックリスト実績情報を取得「治療情報番号」
    List<OrdChecklist> ordCheckListChecked = ordChecklistDao.selectByOrdNo(SelectOptions.get(), ordNo);

    // 治療条件更新の場合
    if (updateFlagCondition) {
      List<OrdChecklist> insertListCondition = new ArrayList<OrdChecklist>();
      List<OrdChecklist> updateListCondition = new ArrayList<OrdChecklist>();
      List<OrdChecklist> deleteListCondition = new ArrayList<OrdChecklist>();
      // add FNSI-redmine_#3905_治療条件更新エラーを修正 周 start
      List<OrdChecklist> skipListCondition = new ArrayList<OrdChecklist>();
      // add FNSI-redmine_#3905_治療条件更新エラーを修正 周 end
      List<OrdChecklist> ordCheckListCheckedCondition = ordCheckListChecked.stream()
        .filter(p ->
          // チェックリスト実績「機能種別」（１：治療情報）
          Objects.equals(Short.parseShort("1"), p.getFuncClass()) &&
            // チェックリスト実績「実績区分」（９：ダミーデータ）以外
            ! Objects.equals(Short.parseShort("9"), p.getRstClass())
        )
        .collect(Collectors.toList());
      // 対象の治療条件取得
      String indCondInfo = ordMain.getIndCondInfo();
      String rstCondInfo = ordMain.getRstCondInfo();
      ObjectMapper map = new ObjectMapper();
      JsonNode condNodeList = finalIsIcouFlag ? map.readTree(rstCondInfo) : map.readTree(indCondInfo);

      // 医材コードリスト
      List<String> itemCodeList = new ArrayList<String>() {
        {
          // ダイアライザ
          add("5");
          // 吸着カラム
          add("6");
          // 1次膜
          add("7");
          // 2次膜
          add("8");
          // 穿刺針(A針)
          add("9");
          // 穿刺針(V針)
          add("10");
          // 穿刺針(SN)
          add("11");
          // 血液回路
          add("13");
          // 透析液
          add("15");
          // 補液
          add("19");
          // 抗凝固剤
          add("25");
        }
      };

      // 分類コード別「更新用」「登録用」
      itemCodeList.forEach(classCode -> {
        if (! condNodeList.has(classCode)) {
          return;
        }

        JsonNode item = condNodeList.get(classCode);
        // 設定値「医材コード」
        JsonNode valueNode = jsonNodeIsNull(item) ? null : item.get("value");
//        Integer value = jsonNodeIsNull(valueNode) ? null : Integer.parseInt(valueNode.toString());
        Integer value = jsonNodeIsNull(valueNode) ? null : Integer.parseInt(valueNode.asText());
        // del 10310 needle _ typeの使用を削除するには gjn start
        // 穿刺針区分(0: 未指定、1: A針、2: V針、3: SN)
//        Short needleType = null;
//        if (jsonNodeIsNull(value)) {
//          needleType = 0;
//        } else if (Objects.equals(classCode, "9")) {
//          needleType = 1;
//        } else if (Objects.equals(classCode, "10")) {
//          needleType = 2;
//        } else if (Objects.equals(classCode, "11")) {
//          needleType = 3;
//        }
//        Short finalNeedleType = needleType;
        // del 10310 needle _ typeの使用を削除するには gjn end
        // 翻訳1
        JsonNode valueName1Node = item.get("value_name_1");
        String valueName1 = jsonNodeIsNull(valueName1Node) ? "null" : valueName1Node.asText();
        // 薬剤区分
        JsonNode medicineTypeNode = jsonNodeIsNull(item) ? null : item.get("medicine_type");
        // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
        //Short medicineType = jsonNodeIsNull(medicineTypeNode) ? null : Short.parseShort(medicineTypeNode.toString().replaceAll("\"", ""));
        Integer medicineType = jsonNodeIsNull(medicineTypeNode) ? null : Integer.parseInt(medicineTypeNode.asText());
        // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
        // 数量
        JsonNode amountNode = item.get("amount");
        String amount = jsonNodeIsNull(amountNode) ? "null" : amountNode.asText();
        // 単位
        JsonNode unitNode = item.get("unit");
        String unit = jsonNodeIsNull(unitNode) ? "null" : unitNode.asText();

        // 更新用リスト作成「実績存在」
        ordCheckListCheckedCondition.stream()
          .filter(p ->
              // チェックリスト実績「医材コード」⇒治療情報「医材コード」
              Objects.equals(p.getRstChecklistInfo().getCode(), value) &&
                // チェックリスト実績「薬剤区分」⇒治療情報「薬剤区分」
                Objects.equals(p.getRstChecklistInfo().getMedicineType(), medicineType) &&
                // mod FNSI-redmine_#3905_治療条件更新エラーを修正 周 start
                // // チェックリスト実績「穿刺針区分」⇒治療情報「穿刺針区分」
                // Objects.equals(p.getRstChecklistInfo().getNeedleType(), finalNeedleType)
                // チェックリスト実績「分類コード」⇒治療情報「項目番号」
                Objects.equals(p.getRstChecklistInfo().getClassCd(), Integer.parseInt(classCode))
            // mod FNSI-redmine_#3905_治療条件更新エラーを修正 周 end
          )
          .forEach(matchItem -> {
            if (finalIsIcouFlag) {
              // 条件送信以降場合⇒チェックリスト実績を更新
              boolean updateFlag = false;
              boolean updateCheckInfoFlag = false;
              // 条件送信以降（１：実施済み⇒０：未実施）のみ
              if (AdminWebConstant.FlagType.FLAG_ON.equals(matchItem.getIsCheck())) {
                // チェックリスト実績「実施状態」（１：実施済み⇒０：未実施）
                matchItem.setIsCheck(AdminWebConstant.FlagType.FLAG_OFF);

                OrdChecklist.OrdChecklistRegStaffInfo regStaffInfo = matchItem.getRegStaffInfo();
                regStaffInfo.setRegStaffCd(null);
                regStaffInfo.setRegStaffUpdate(null);
                // 実施者情報をクリア
                matchItem.setRegStaffInfo(regStaffInfo);

                updateFlag = true;
              }

              OrdChecklist.OrdChecklistRegCheckInfo rstChecklistInfo = matchItem.getRstChecklistInfo();
              if (! Objects.equals(rstChecklistInfo.getName(), valueName1)) {
                // チェックリスト実績.チェックリスト項目情報「項目名称」
                rstChecklistInfo.setName(valueName1);

                updateFlag = true;
                updateCheckInfoFlag = true;
              }
              if (! Objects.equals(rstChecklistInfo.getAmount(), amount)) {
                // チェックリスト実績.チェックリスト項目情報「数量」
                rstChecklistInfo.setAmount(amount);

                updateFlag = true;
                updateCheckInfoFlag = true;
              }
              if (! Objects.equals(rstChecklistInfo.getUnit(), unit)) {
                // チェックリスト実績.チェックリスト項目情報「単位」
                rstChecklistInfo.setUnit(unit);

                updateFlag = true;
                updateCheckInfoFlag = true;
              }

              if (updateCheckInfoFlag) {
                // チェックリスト実績.チェックリスト項目情報を更新
                matchItem.setRstChecklistInfo(rstChecklistInfo);
              }

              if (updateFlag) {
                // チェックリスト実績を更新
                updateListCondition.add(matchItem);
              }
            } else {
              // 条件送信前場合⇒チェックリスト実績を削除
              OrdChecklist.OrdChecklistRegCheckInfo rstChecklistInfo = matchItem.getRstChecklistInfo();
              // mod FNSI-redmine_#3905_治療条件更新エラーを修正 周 start
              // // 数量更新時
              // if (!Objects.equals(rstChecklistInfo.getAmount(), amount)) {
              //   deleteListCondition.add(matchItem);
              // }

              if (Objects.equals(classCode, "15") || Objects.equals(classCode, "19") || Objects.equals(classCode, "25")) {
                // 数量更新時
                if (! Objects.equals(rstChecklistInfo.getAmount(), amount)) {
                  deleteListCondition.add(matchItem);
                } else {
                  skipListCondition.add(matchItem);
                }
              } else {
                // 数量更新時「1固定」
                if (! Objects.equals(rstChecklistInfo.getAmount(), "1")) {
                  deleteListCondition.add(matchItem);
                } else {
                  skipListCondition.add(matchItem);
                }
              }
              // mod FNSI-redmine_#3905_治療条件更新エラーを修正 周 end
            }
          });

        // 登録用リスト作成「条件送信以降のみ」
        if (finalIsIcouFlag) {
          boolean insertFlag = ordCheckListCheckedCondition.stream()
            .filter(p ->
                // チェックリスト実績「医材コード」⇒治療情報「医材コード」
                Objects.equals(p.getRstChecklistInfo().getCode(), value) &&
                  // チェックリスト実績「薬剤区分」⇒治療情報「薬剤区分」
                  Objects.equals(p.getRstChecklistInfo().getMedicineType(), medicineType) &&
                  // mod FNSI-redmine_#3905_治療条件更新エラーを修正 周 start
                  // // チェックリスト実績「穿刺針区分」⇒治療情報「穿刺針区分」
                  // Objects.equals(p.getRstChecklistInfo().getNeedleType(), finalNeedleType)
                  // チェックリスト実績「分類コード」⇒治療情報「項目番号」
                  Objects.equals(p.getRstChecklistInfo().getClassCd(), Integer.parseInt(classCode))
              // mod FNSI-redmine_#3905_治療条件更新エラーを修正 周 end
            )
            .collect(Collectors.toList())
            .size() == 0;

          // 登録用リスト作成
          if (insertFlag) {
            OrdChecklist insertItem = new OrdChecklist();
            // チェックリスト実績「治療情報管理番号」
            insertItem.setOrdNo(ordNo);
            // チェックリスト実績「実施状態」（０：未実施）
            insertItem.setIsCheck(AdminWebConstant.FlagType.FLAG_OFF);
            // チェックリスト実績「実績区分」※再設定
            // チェックリスト実績「リストコード」※再設定
            // チェックリスト実績「機能種別」（１：治療情報）
            insertItem.setFuncClass(Short.parseShort("1"));
            // チェックリスト実績「削除フラグ」（０：通常）
            insertItem.setIsDel(AdminWebConstant.FlagType.FLAG_OFF);
            // チェックリスト実績「施設コード」
            insertItem.setFacilityCd(ordMain.getFacilityCd());

            OrdChecklist.OrdChecklistRegCheckInfo regCheckInfo = new OrdChecklist.OrdChecklistRegCheckInfo();
            // チェックリスト実績.チェックリスト項目情報「チェックリストコード」※再設定
            // チェックリスト実績.チェックリスト項目情報「項目番号」※再設定
            // チェックリスト実績.チェックリスト項目情報「分類コード」
            regCheckInfo.setClassCd(Integer.parseInt(classCode));
            // チェックリスト実績.チェックリスト項目情報「医材コード」
            regCheckInfo.setCode(value);
            // チェックリスト実績.チェックリスト項目情報「医材コード更新日時」
            regCheckInfo.setCodeUpdate(null);
            // チェックリスト実績.チェックリスト項目情報「項目名称」
            regCheckInfo.setName(valueName1);

            if (Objects.equals(classCode, "5") || Objects.equals(classCode, "7") || Objects.equals(classCode, "8")) {
              // ダイアライザ
              // チェックリスト実績.チェックリスト項目情報「穿刺針区分」
              // del 10310 needle _ typeの使用を削除するには gjn start
//              regCheckInfo.setNeedleType(null);
              // del 10310 needle _ typeの使用を削除するには gjn end
              // チェックリスト実績.チェックリスト項目情報「薬剤区分」
              regCheckInfo.setMedicineType(null);
              // チェックリスト実績.チェックリスト項目情報「数量」
              regCheckInfo.setAmount("1");
              // チェックリスト実績.チェックリスト項目情報「単位」
              regCheckInfo.setUnit("本");
            } else if (Objects.equals(classCode, "15") || Objects.equals(classCode, "19") || Objects.equals(classCode, "25")) {
              // 薬剤
              // チェックリスト実績.チェックリスト項目情報「穿刺針区分」
              // del 10310 needle _ typeの使用を削除するには gjn start
//              regCheckInfo.setNeedleType(null);
              // del 10310 needle _ typeの使用を削除するには gjn end
              // チェックリスト実績.チェックリスト項目情報「薬剤区分」
              regCheckInfo.setMedicineType(medicineType);
              // チェックリスト実績.チェックリスト項目情報「数量」
              if (Objects.equals(classCode, "15")) {
                // 「17：透析液使用数」
                JsonNode item17Node = condNodeList.has("17") ? condNodeList.get("17") : new TextNode(null);
                JsonNode item17valueNode = jsonNodeIsNull(item17Node) || ! item17Node.has("value") ? new TextNode(null) : item17Node.get("value");
                BigDecimal item17 = jsonNodeIsNull(item17valueNode) ? BigDecimal.ZERO : new BigDecimal(item17valueNode.asText());

//                regCheckInfo.setAmount(item17.toString());
                regCheckInfo.setAmount(item17.toPlainString());
              } else if (Objects.equals(classCode, "19")) {
                // 「22：補液使用数」
                JsonNode item22Node = condNodeList.has("22") ? condNodeList.get("22") : new TextNode(null);
                JsonNode item22valueNode = jsonNodeIsNull(item22Node) || ! item22Node.has("value") ? new TextNode(null) : item22Node.get("value");
                BigDecimal item22 = jsonNodeIsNull(item22valueNode) ? BigDecimal.ZERO : new BigDecimal(item22valueNode.asText());

//                regCheckInfo.setAmount(item22.toString());
                regCheckInfo.setAmount(item22.toPlainString());
              } else if (Objects.equals(classCode, "25")) {
                // 「26：抗凝固剤ワンショット量」＋「28：抗凝固剤持続総量」
                JsonNode item26Node = condNodeList.has("26") ? condNodeList.get("26") : new TextNode(null);
                JsonNode item26valueNode = jsonNodeIsNull(item26Node) || ! item26Node.has("value") ? new TextNode(null) : item26Node.get("value");
                BigDecimal item26 = jsonNodeIsNull(item26valueNode) ? BigDecimal.ZERO : new BigDecimal(item26valueNode.asText());
                JsonNode item28Node = condNodeList.has("28") ? condNodeList.get("28") : new TextNode(null);
                JsonNode item28valueNode = jsonNodeIsNull(item28Node) || ! item28Node.has("value") ? new TextNode(null) : item28Node.get("value");
                BigDecimal item28 = jsonNodeIsNull(item28valueNode) ? BigDecimal.ZERO : new BigDecimal(item28valueNode.asText());

//                regCheckInfo.setAmount(item26.add(item28).toString());
                regCheckInfo.setAmount(item26.add(item28).toPlainString());
              }
              // チェックリスト実績.チェックリスト項目情報「単位」
              regCheckInfo.setUnit(unit);
            } else {
              // 医療材料
              // チェックリスト実績.チェックリスト項目情報「穿刺針区分」
              // del 10310 needle _ typeの使用を削除するには gjn start
//              regCheckInfo.setNeedleType(finalNeedleType);
              // del 10310 needle _ typeの使用を削除するには gjn end
              // チェックリスト実績.チェックリスト項目情報「薬剤区分」
              regCheckInfo.setMedicineType(null);
              // チェックリスト実績.チェックリスト項目情報「数量」
              regCheckInfo.setAmount("1");
              // チェックリスト実績.チェックリスト項目情報「単位」
              regCheckInfo.setUnit(unit);
            }

            insertItem.setRstChecklistInfo(regCheckInfo);

            OrdChecklist.OrdChecklistRegStaffInfo regStaffInfo = new OrdChecklist.OrdChecklistRegStaffInfo();
            regStaffInfo.setRegStaffCd(null);
            regStaffInfo.setRegStaffUpdate(null);
            insertItem.setRegStaffInfo(regStaffInfo);

            insertListCondition.add(insertItem);
          }
        }
      });

      // マップデータ「削除用」
      Map<Long, Object> mapData = updateListCondition.stream()
        .collect(Collectors.toMap(OrdChecklist::getChecklistCtlNo, item -> item, (k1, k2) -> k1));
      // add FNSI-redmine_#3905_治療条件更新エラーを修正 周 start
      // マップデータ「スキップ用」
      Map<Long, Object> mapData2 = skipListCondition.stream()
        .collect(Collectors.toMap(OrdChecklist::getChecklistCtlNo, item -> item, (k1, k2) -> k1));
      // add FNSI-redmine_#3905_治療条件更新エラーを修正 周 end
      // 削除用リスト作成
      ordCheckListChecked.stream()
        .filter(p ->
            // チェックリスト実績「機能種別」（１：治療情報）
            Objects.equals(Short.parseShort("1"), p.getFuncClass()) &&
              // 更新リスト以外場合
              // mod FNSI-redmine_#3905_治療条件更新エラーを修正 周 start
              // !mapData.containsKey(p.getChecklistCtlNo())
              ! mapData.containsKey(p.getChecklistCtlNo()) &&
              // スキップリスト以外場合
              ! mapData2.containsKey(p.getChecklistCtlNo())
          // mod FNSI-redmine_#3905_治療条件更新エラーを修正 周 end
        )
        .forEach(deleteItem -> {
          deleteListCondition.add(deleteItem);
        });

      insertList.addAll(insertListCondition);
      updateList.addAll(updateListCondition);
      deleteList.addAll(deleteListCondition);
    }

    // 投与薬剤更新の場合
    if (updateFlagMedicine) {
      List<OrdChecklist> insertListMedicine = new ArrayList<OrdChecklist>();
      List<OrdChecklist> updateListMedicine = new ArrayList<OrdChecklist>();
      List<OrdChecklist> deleteListMedicine = new ArrayList<OrdChecklist>();
      // add FNSI-redmine_#3905_治療条件更新エラーを修正 周 start
      List<OrdChecklist> skipListMedicine = new ArrayList<OrdChecklist>();
      // add FNSI-redmine_#3905_治療条件更新エラーを修正 周 end
      List<OrdChecklist> ordCheckListCheckedMedicine = ordCheckListChecked.stream()
        .filter(p ->
          // チェックリスト実績「機能種別」（３：投与薬剤）
          Objects.equals(Short.parseShort("3"), p.getFuncClass()) &&
            // チェックリスト実績「実績区分」（９：ダミーデータ）以外
            ! Objects.equals(Short.parseShort("9"), p.getRstClass())
        )
        .collect(Collectors.toList());
      // 対象の投与薬剤取得
      /* modify by chamaojia 2024-04-02 [10196] add null judgment processing  --start */
//      String indMediInfo = ordMain.getIndMediInfo();
//      String rstMediInfo = ordMain.getRstMediInfo();
      String indMediInfo = ObjectUtils.isEmpty(ordMain.getIndMediInfo()) ? "[]" : ordMain.getIndMediInfo();
      String rstMediInfo = ObjectUtils.isEmpty(ordMain.getRstMediInfo()) ? "[]" : ordMain.getRstMediInfo();
      /* modify by chamaojia 2024-04-02 [10196] add null judgment processing  --end */
      ObjectMapper map = new ObjectMapper();
      JsonNode mediNodeList = finalIsIcouFlag ? map.readTree(rstMediInfo) : map.readTree(indMediInfo);

      mediNodeList.forEach(mediItem -> {
        // 薬剤コード
        JsonNode codeNode = mediItem.get("cd");
        Integer code = jsonNodeIsNull(codeNode) ? null : Integer.parseInt(codeNode.asText());
        // 単位
        JsonNode unitNode = mediItem.get("unit");
        String unit = jsonNodeIsNull(unitNode) ? "null" : unitNode.asText();
        // 数量
        JsonNode amountNode = mediItem.get("amount");
        String amount = jsonNodeIsNull(amountNode) ? "null" : amountNode.asText();
        // 薬剤名
        JsonNode nameNode = mediItem.get("name");
        String name = jsonNodeIsNull(nameNode) ? "null" : nameNode.asText();
        // 薬剤区分
        JsonNode medicineTypeNode = mediItem.get("medicine_type");
        // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
        //Short medicineType = jsonNodeIsNull(medicineTypeNode) ? null : Short.parseShort(medicineTypeNode.toString().replaceAll("\"", ""));
        Integer medicineType = jsonNodeIsNull(medicineTypeNode) ? null : Integer.parseInt(medicineTypeNode.asText());
        // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
        // 分類コード
        JsonNode classCdNode = mediItem.get("class_cd");
        Integer classCd = jsonNodeIsNull(classCdNode) ? null : Integer.parseInt(classCdNode.asText());

        // 更新用リスト作成「実績存在」
        ordCheckListCheckedMedicine.stream()
          .filter(p ->
            // チェックリスト実績「医材コード」⇒治療情報「薬剤コード」
            Objects.equals(p.getRstChecklistInfo().getCode(), code) &&
              // チェックリスト実績「薬剤区分」⇒治療情報「薬剤区分」
              Objects.equals(p.getRstChecklistInfo().getMedicineType(), medicineType)
          )
          .forEach(matchItem -> {
            if (finalIsIcouFlag) {
              // 条件送信以降場合⇒チェックリスト実績を更新
              boolean updateFlag = false;
              boolean updateCheckInfoFlag = false;
              // 条件送信以降（１：実施済み⇒０：未実施）のみ
              if (AdminWebConstant.FlagType.FLAG_ON.equals(matchItem.getIsCheck())) {
                // チェックリスト実績「実施状態」（１：実施済み⇒０：未実施）
                matchItem.setIsCheck(AdminWebConstant.FlagType.FLAG_OFF);

                OrdChecklist.OrdChecklistRegStaffInfo regStaffInfo = matchItem.getRegStaffInfo();
                regStaffInfo.setRegStaffCd(null);
                regStaffInfo.setRegStaffUpdate(null);
                // 実施者情報をクリア
                matchItem.setRegStaffInfo(regStaffInfo);

                updateFlag = true;
              }

              OrdChecklist.OrdChecklistRegCheckInfo rstChecklistInfo = matchItem.getRstChecklistInfo();
              if (! Objects.equals(rstChecklistInfo.getName(), name)) {
                // チェックリスト実績.チェックリスト項目情報「項目名称」
                rstChecklistInfo.setName(name);

                updateFlag = true;
                updateCheckInfoFlag = true;
              }
              if (! Objects.equals(rstChecklistInfo.getAmount(), amount)) {
                // チェックリスト実績「数量」
                rstChecklistInfo.setAmount(amount);

                updateFlag = true;
                updateCheckInfoFlag = true;
              }
              if (! Objects.equals(rstChecklistInfo.getUnit(), unit)) {
                // チェックリスト実績「単位」
                rstChecklistInfo.setUnit(unit);

                updateFlag = true;
                updateCheckInfoFlag = true;
              }

              if (updateCheckInfoFlag) {
                // チェックリスト実績.チェックリスト項目情報を更新
                matchItem.setRstChecklistInfo(rstChecklistInfo);
              }

              if (updateFlag) {
                // チェックリスト実績を更新
                updateListMedicine.add(matchItem);
              }
            } else {
              // 条件送信前場合⇒チェックリスト実績を削除
              OrdChecklist.OrdChecklistRegCheckInfo rstChecklistInfo = matchItem.getRstChecklistInfo();
              // 数量更新時
              if (! Objects.equals(rstChecklistInfo.getAmount(), amount)) {
                deleteListMedicine.add(matchItem);
                // mod FNSI-redmine_#3905_治療条件更新エラーを修正 周 start
                // }
              } else {
                skipListMedicine.add(matchItem);
              }
              // mod FNSI-redmine_#3905_治療条件更新エラーを修正 周 end
            }
          });

        // 登録用リスト作成「条件送信以降のみ」
        if (finalIsIcouFlag) {
          boolean insertFlag = ordCheckListCheckedMedicine.stream()
            .filter(p ->
              // チェックリスト実績「医材コード」⇒治療情報「薬剤コード」
              Objects.equals(p.getRstChecklistInfo().getCode(), code) &&
                // チェックリスト実績「薬剤区分」⇒治療情報「薬剤区分」
                Objects.equals(p.getRstChecklistInfo().getMedicineType(), medicineType)
            )
            .collect(Collectors.toList())
            .size() == 0;

          // 登録用リスト作成
          if (insertFlag) {
            OrdChecklist insertItem = new OrdChecklist();
            // チェックリスト実績「治療情報管理番号」
            insertItem.setOrdNo(ordNo);
            // チェックリスト実績「実施状態」（０：未実施）
            insertItem.setIsCheck(AdminWebConstant.FlagType.FLAG_OFF);
            // チェックリスト実績「実績区分」※再設定
            // チェックリスト実績「リストコード」※再設定
            // チェックリスト実績「機能種別」（３：投与薬剤）
            insertItem.setFuncClass(Short.parseShort("3"));
            // チェックリスト実績「削除フラグ」（０：通常）
            insertItem.setIsDel(AdminWebConstant.FlagType.FLAG_OFF);
            // チェックリスト実績「施設コード」
            insertItem.setFacilityCd(ordMain.getFacilityCd());

            OrdChecklist.OrdChecklistRegCheckInfo regCheckInfo = new OrdChecklist.OrdChecklistRegCheckInfo();
            // チェックリスト実績.チェックリスト項目情報「チェックリストコード」※再設定
            // チェックリスト実績.チェックリスト項目情報「項目番号」※再設定
            // チェックリスト実績.チェックリスト項目情報「分類コード」
            regCheckInfo.setClassCd(classCd);
            // チェックリスト実績.チェックリスト項目情報「医材コード」
            regCheckInfo.setCode(code);
            // チェックリスト実績.チェックリスト項目情報「医材コード更新日時」
            regCheckInfo.setCodeUpdate(null);
            // チェックリスト実績.チェックリスト項目情報「薬剤区分」
            regCheckInfo.setMedicineType(medicineType);
            // チェックリスト実績.チェックリスト項目情報「項目名称」
            regCheckInfo.setName(name);
            // チェックリスト実績.チェックリスト項目情報「穿刺針区分」
            // del 10310 needle _ typeの使用を削除するには gjn start
//            regCheckInfo.setNeedleType(null);
            // del 10310 needle _ typeの使用を削除するには gjn end
            // チェックリスト実績.チェックリスト項目情報「数量」
            regCheckInfo.setAmount(amount);
            // チェックリスト実績.チェックリスト項目情報「単位」
            regCheckInfo.setUnit(unit);
            insertItem.setRstChecklistInfo(regCheckInfo);

            OrdChecklist.OrdChecklistRegStaffInfo regStaffInfo = new OrdChecklist.OrdChecklistRegStaffInfo();
            regStaffInfo.setRegStaffCd(null);
            regStaffInfo.setRegStaffUpdate(null);
            insertItem.setRegStaffInfo(regStaffInfo);

            insertListMedicine.add(insertItem);
          }
        }
      });

      // マップデータ「削除用」
      Map<Long, Object> mapData = updateListMedicine.stream()
        .collect(Collectors.toMap(OrdChecklist::getChecklistCtlNo, item -> item, (k1, k2) -> k1));
      // add FNSI-redmine_#3905_治療条件更新エラーを修正 周 start
      // マップデータ「スキップ用」
      Map<Long, Object> mapData2 = skipListMedicine.stream()
        .collect(Collectors.toMap(OrdChecklist::getChecklistCtlNo, item -> item, (k1, k2) -> k1));
      // add FNSI-redmine_#3905_治療条件更新エラーを修正 周 end
      // 削除用リスト作成
      ordCheckListChecked.stream()
        .filter(p ->
            // チェックリスト実績「機能種別」（３：投与薬剤）
            Objects.equals(Short.parseShort("3"), p.getFuncClass()) &&
              // 更新リスト以外場合
              // mod FNSI-redmine_#3905_治療条件更新エラーを修正 周 start
              // !mapData.containsKey(p.getChecklistCtlNo())
              ! mapData.containsKey(p.getChecklistCtlNo()) &&
              // スキップリスト以外場合
              ! mapData2.containsKey(p.getChecklistCtlNo())
          // mod FNSI-redmine_#3905_治療条件更新エラーを修正 周 end
        )
        .forEach(deleteListMedicine::add);

      insertList.addAll(insertListMedicine);
      updateList.addAll(updateListMedicine);
      deleteList.addAll(deleteListMedicine);
    }

    // 医療材料更新の場合
    if (updateFlagEquipment) {
      List<OrdChecklist> insertListEquipment = new ArrayList<OrdChecklist>();
      List<OrdChecklist> updateListEquipment = new ArrayList<OrdChecklist>();
      List<OrdChecklist> deleteListEquipment = new ArrayList<OrdChecklist>();
      // add FNSI-redmine_#3905_治療条件更新エラーを修正 周 start
      List<OrdChecklist> skipListEquipment = new ArrayList<OrdChecklist>();
      // add FNSI-redmine_#3905_治療条件更新エラーを修正 周 end
      List<OrdChecklist> ordCheckListCheckedEquipment = ordCheckListChecked.stream()
        .filter(p ->
          // チェックリスト実績「機能種別」（２：医療材料）
          Objects.equals(Short.parseShort("2"), p.getFuncClass()) &&
            // チェックリスト実績「実績区分」（９：ダミーデータ）以外
            ! Objects.equals(Short.parseShort("9"), p.getRstClass())
        )
        .toList();
      // 対象の医療材料取得
      String indEquipInfo = ordMain.getIndEquipInfo();
      String rstEquipInfo = ordMain.getRstEquipInfo();
      ObjectMapper map = new ObjectMapper();
      JsonNode equipNodeList = finalIsIcouFlag ? map.readTree(rstEquipInfo) : map.readTree(indEquipInfo);

      equipNodeList.forEach(equipItem -> {
        // 薬剤コード
        JsonNode codeNode = equipItem.get("cd");
        Integer code = jsonNodeIsNull(codeNode) ? null : Integer.parseInt(codeNode.asText());
        // 単位
        JsonNode unitNode = equipItem.get("unit");
        String unit = jsonNodeIsNull(unitNode) ? "null" : unitNode.asText();
        // 数量
        JsonNode amountNode = equipItem.get("amount");
        String amount = jsonNodeIsNull(amountNode) ? "null" : amountNode.asText();
        // 薬剤名
        JsonNode nameNode = equipItem.get("name");
        String name = jsonNodeIsNull(nameNode) ? "null" : nameNode.asText();
        // del 10310 needle _ typeの使用を削除するには gjn start
        // 穿刺針区分
//        JsonNode needleTypeNode = equipItem.get("needle_type");
        //upd 計画ページ変更治療法、needle _type処理エラー 2023-07-11 ztc start
        //Short needleType = jsonNodeIsNull(needleTypeNode) ? null : Short.parseShort(needleTypeNode.toString());
//        Short needleType = jsonNodeIsNull(needleTypeNode) ? null : Short.parseShort(needleTypeNode.asText());
        // del 10310 needle _ typeの使用を削除するには gjn end

        //upd 計画ページ変更治療法、needle _type処理エラー 2023-07-11 ztc end
        // 分類コード
        JsonNode classCdNode = equipItem.get("class_cd");
        Integer classCd = jsonNodeIsNull(classCdNode) ? null : Integer.parseInt(classCdNode.asText());
        // 医療材料区分「0：医療材料、1：ダイアライザ」
        JsonNode equipTypeNode = equipItem.get("equip_type");
//        boolean isDialyzer = jsonNodeIsNull(equipTypeNode) ? false : Objects.equals(equipTypeNode.toString(), "1");
        boolean isDialyzer = equipTypeNode != null && !jsonNodeIsNull(equipTypeNode) && "1".equals(equipTypeNode.asText());

        // 更新用リスト作成「実績存在」
        ordCheckListCheckedEquipment.stream()
          .filter(p ->
            // チェックリスト実績「医材コード」⇒治療情報「薬剤コード」
            Objects.equals(p.getRstChecklistInfo().getCode(), code)
            // del 10310 needle _ typeの使用を削除するには gjn start
              // チェックリスト実績「穿刺針区分」⇒治療情報「穿刺針区分」
              //Objects.equals(p.getRstChecklistInfo().getNeedleType(), needleType)
            // del 10310 needle _ typeの使用を削除するには gjn end
          )
          .forEach(matchItem -> {
            if (finalIsIcouFlag) {
              // 条件送信以降場合⇒チェックリスト実績を更新
              boolean updateFlag = false;
              boolean updateCheckInfoFlag = false;
              // 条件送信以降（１：実施済み⇒０：未実施）のみ
              if (AdminWebConstant.FlagType.FLAG_ON.equals(matchItem.getIsCheck())) {
                // チェックリスト実績「実施状態」（１：実施済み⇒０：未実施）
                matchItem.setIsCheck(AdminWebConstant.FlagType.FLAG_OFF);

                OrdChecklist.OrdChecklistRegStaffInfo regStaffInfo = matchItem.getRegStaffInfo();
                regStaffInfo.setRegStaffCd(null);
                regStaffInfo.setRegStaffUpdate(null);
                // 実施者情報をクリア
                matchItem.setRegStaffInfo(regStaffInfo);

                updateFlag = true;
              }

              OrdChecklist.OrdChecklistRegCheckInfo rstChecklistInfo = matchItem.getRstChecklistInfo();
              if (! Objects.equals(rstChecklistInfo.getName(), name)) {
                // チェックリスト実績.チェックリスト項目情報「項目名称」
                rstChecklistInfo.setName(name);

                updateFlag = true;
                updateCheckInfoFlag = true;
              }
              if (! Objects.equals(matchItem.getRstChecklistInfo().getUnit(), unit)) {
                // チェックリスト実績「単位」
                rstChecklistInfo.setUnit(unit);

                updateFlag = true;
                updateCheckInfoFlag = true;
              }
              if (! Objects.equals(matchItem.getRstChecklistInfo().getAmount(), amount)) {
                // チェックリスト実績「数量」
                rstChecklistInfo.setAmount(amount);

                updateFlag = true;
                updateCheckInfoFlag = true;
              }

              if (updateCheckInfoFlag) {
                // チェックリスト実績.チェックリスト項目情報を更新
                matchItem.setRstChecklistInfo(rstChecklistInfo);
              }

              if (updateFlag) {
                // チェックリスト実績を更新
                updateListEquipment.add(matchItem);
              }
            } else {
              // 条件送信前場合⇒チェックリスト実績を削除
              OrdChecklist.OrdChecklistRegCheckInfo rstChecklistInfo = matchItem.getRstChecklistInfo();
              // 数量更新時
              if (! Objects.equals(matchItem.getRstChecklistInfo().getAmount(), amount)) {
                deleteListEquipment.add(matchItem);
                // mod FNSI-redmine_#3905_治療条件更新エラーを修正 周 start
                // }
              } else {
                skipListEquipment.add(matchItem);
              }
              // mod FNSI-redmine_#3905_治療条件更新エラーを修正 周 end
            }
          });

        // 登録用リスト作成「条件送信以降のみ」
        if (finalIsIcouFlag) {
          boolean insertFlag = ordCheckListCheckedEquipment.stream()
            .filter(p ->
              // チェックリスト実績「医材コード」⇒治療情報「薬剤コード」
              Objects.equals(p.getRstChecklistInfo().getCode(), code)
              // del 10310 needle _ typeの使用を削除するには gjn start
                // チェックリスト実績「穿刺針区分」⇒治療情報「穿刺針区分」
                //Objects.equals(p.getRstChecklistInfo().getNeedleType(), needleType)
              // del 10310 needle _ typeの使用を削除するには gjn end
            )
            .collect(Collectors.toList())
            .size() == 0;

          // 登録用リスト作成
          if (insertFlag) {
            OrdChecklist insertItem = new OrdChecklist();
            // チェックリスト実績「治療情報管理番号」
            insertItem.setOrdNo(ordNo);
            // チェックリスト実績「実施状態」（０：未実施）
            insertItem.setIsCheck(AdminWebConstant.FlagType.FLAG_OFF);
            // チェックリスト実績「実績区分」※再設定
            // チェックリスト実績「リストコード」※再設定
            // チェックリスト実績「機能種別」（２：医療材料）
            insertItem.setFuncClass(Short.parseShort("2"));
            // チェックリスト実績「削除フラグ」（０：通常）
            insertItem.setIsDel(AdminWebConstant.FlagType.FLAG_OFF);
            // チェックリスト実績「施設コード」
            insertItem.setFacilityCd(ordMain.getFacilityCd());

            OrdChecklist.OrdChecklistRegCheckInfo regCheckInfo = new OrdChecklist.OrdChecklistRegCheckInfo();
            // チェックリスト実績.チェックリスト項目情報「チェックリストコード」※再設定
            // チェックリスト実績.チェックリスト項目情報「項目番号」※再設定
            if (isDialyzer) {
              // チェックリスト実績.チェックリスト項目情報「分類コード」
              regCheckInfo.setClassCd(Integer.parseInt("0"));
              // del 10310 needle _ typeの使用を削除するには gjn start
              // チェックリスト実績.チェックリスト項目情報「穿刺針区分」
//              regCheckInfo.setNeedleType(null);
              // del 10310 needle _ typeの使用を削除するには gjn end
              // チェックリスト実績.チェックリスト項目情報「単位」
              regCheckInfo.setUnit("本");
            } else {
              // チェックリスト実績.チェックリスト項目情報「分類コード」
              regCheckInfo.setClassCd(classCd);
              // del 10310 needle _ typeの使用を削除するには gjn start
              // チェックリスト実績.チェックリスト項目情報「穿刺針区分」
              //regCheckInfo.setNeedleType(needleType);
              // del 10310 needle _ typeの使用を削除するには gjn end
              // チェックリスト実績.チェックリスト項目情報「単位」
              regCheckInfo.setUnit(unit);
            }
            // チェックリスト実績.チェックリスト項目情報「医材コード」
            regCheckInfo.setCode(code);
            // チェックリスト実績.チェックリスト項目情報「医材コード更新日時」
            regCheckInfo.setCodeUpdate(null);
            // チェックリスト実績.チェックリスト項目情報「薬剤区分」
            regCheckInfo.setMedicineType(null);
            // チェックリスト実績.チェックリスト項目情報「項目名称」
            regCheckInfo.setName(name);
            // チェックリスト実績.チェックリスト項目情報「数量」
            regCheckInfo.setAmount(amount);
            insertItem.setRstChecklistInfo(regCheckInfo);

            OrdChecklist.OrdChecklistRegStaffInfo regStaffInfo = new OrdChecklist.OrdChecklistRegStaffInfo();
            regStaffInfo.setRegStaffCd(null);
            regStaffInfo.setRegStaffUpdate(null);
            insertItem.setRegStaffInfo(regStaffInfo);

            insertListEquipment.add(insertItem);
          }
        }
      });

      // マップデータ「削除用」
      Map<Long, Object> mapData = updateListEquipment.stream()
        .collect(Collectors.toMap(OrdChecklist::getChecklistCtlNo, item -> item, (k1, k2) -> k1));
      // add FNSI-redmine_#3905_治療条件更新エラーを修正 周 start
      // マップデータ「スキップ用」
      Map<Long, Object> mapData2 = skipListEquipment.stream()
        .collect(Collectors.toMap(OrdChecklist::getChecklistCtlNo, item -> item, (k1, k2) -> k1));
      // add FNSI-redmine_#3905_治療条件更新エラーを修正 周 end
      // 削除用リスト作成
      ordCheckListChecked.stream()
        .filter(p ->
            // チェックリスト実績「機能種別」（２：医療材料）
            Objects.equals(Short.parseShort("2"), p.getFuncClass()) &&
              // 更新リスト以外場合
              // mod FNSI-redmine_#3905_治療条件更新エラーを修正 周 start
              // !mapData.containsKey(p.getChecklistCtlNo())
              ! mapData.containsKey(p.getChecklistCtlNo()) &&
              // スキップリスト以外場合
              ! mapData2.containsKey(p.getChecklistCtlNo())
          // mod FNSI-redmine_#3905_治療条件更新エラーを修正 周 end
        )
        .forEach(deleteItem -> {
          deleteListEquipment.add(deleteItem);
        });

      insertList.addAll(insertListEquipment);
      updateList.addAll(updateListEquipment);
      deleteList.addAll(deleteListEquipment);
    }

    // 条件送信以降
    if (isIcouFlag) {
      // チェックリスト実績を更新
      updateList.stream().forEach(item -> {
        // mod FNSI-#401患者経過総合ビューア機能分仕様追加対応 周 start
        // ordChecklistDao.update(item);
        OrdChecklist updItem = item.clone();
        // チェックリスト実績「実績区分」（１：条件送信後「１～５」場合）（２：条件送信後「６」場合）
        updItem.setRstClass("6".equals(rstDialysisState) ? Short.parseShort("2") : Short.parseShort("1"));

        //del 9324 ord_checklist共通之外的dao方法删除 gjn start
        //ordChecklistDao.update(updItem);
        //del 9324 ord_checklist共通之外的dao方法删除 gjn end
        // mod FNSI-#401患者経過総合ビューア機能分仕様追加対応 周 end
      });
      // チェックリスト実績を登録
      List<OrdChecklist> finalInsertList = new ArrayList<OrdChecklist>();
      insertList.stream().forEach(item -> {
        // マスタ情報を取得「ダミーデータ含む」
        List<OrdChecklist> mstChecklist = ordCheckListChecked.stream()
          .filter(p ->
            // チェックリスト実績「機能種別」
            Objects.equals(item.getFuncClass(), p.getFuncClass()) &&
              // チェックリスト実績「分類コード」
              Objects.equals(item.getRstChecklistInfo().getClassCd(), p.getRstChecklistInfo().getClassCd())
            // del 10310 needle _ typeの使用を削除するには gjn start
              // チェックリスト実績「穿刺針区分」
              //Objects.equals(item.getRstChecklistInfo().getNeedleType(), p.getRstChecklistInfo().getNeedleType())
            // del 10310 needle _ typeの使用を削除するには gjn end
          )
          .collect(Collectors.toList());

        mstChecklist.forEach(mst -> {
          OrdChecklist addItem = item.clone();
          // mod FNSI-#401患者経過総合ビューア機能分仕様追加対応 周 start
          // // チェックリスト実績「実績区分」（１：）
          // addItem.setRstClass(Short.parseShort("1"));
          // チェックリスト実績「実績区分」（１：条件送信後「１～５」場合）（２：条件送信後「６」場合）
          addItem.setRstClass("6".equals(rstDialysisState) ? Short.parseShort("2") : Short.parseShort("1"));
          // mod FNSI-#401患者経過総合ビューア機能分仕様追加対応 周 end
          // チェックリスト実績「リストコード」
          addItem.setListCd(mst.getListCd());
          // チェックリスト実績「発生日時」
          addItem.setOccurDate(Timestamp.valueOf(update));

          OrdChecklist.OrdChecklistRegCheckInfo regCheckInfo = addItem.getRstChecklistInfo();
          // チェックリスト実績.チェックリスト項目情報「チェックリストコード」
          regCheckInfo.setChecklistCd(mst.getRstChecklistInfo().getChecklistCd());
          // チェックリスト実績.チェックリスト項目情報「項目番号」
          regCheckInfo.setItemNumber(mst.getRstChecklistInfo().getItemNumber());

          addItem.setRstChecklistInfo(regCheckInfo);

          //del 9324 ord_checklist共通之外的dao方法删除 gjn start
          //ordChecklistDao.insert(addItem);
          //del 9324 ord_checklist共通之外的dao方法删除 gjn end
          finalInsertList.add(addItem);
        });
      });
      // チェックリスト実績を削除
      deleteList.stream().forEach(item -> {
        // ダミーデータ登録フラグ
        boolean insertDummyFlag = true;
        // ダミーデータリスト存在する場合、登録しない
        if (insertDummyFlag &&
          dummyList.stream()
            .filter(p ->
              // チェックリスト実績「リストコード」
              Objects.equals(item.getListCd(), p.getListCd()) &&
                // チェックリスト実績.チェックリスト項目情報「項目番号」
                Objects.equals(item.getRstChecklistInfo().getItemNumber(), p.getRstChecklistInfo().getItemNumber()) &&
                // チェックリスト実績.チェックリスト項目情報「分類コード」
                Objects.equals(item.getRstChecklistInfo().getClassCd(), p.getRstChecklistInfo().getClassCd()))
            .collect(Collectors.toList())
            .size() > 0) {
          insertDummyFlag = false;
        }
        // 登録データリスト存在する場合、登録しない
        if (insertDummyFlag &&
          finalInsertList.stream()
            .filter(p ->
              // チェックリスト実績「リストコード」
              Objects.equals(item.getListCd(), p.getListCd()) &&
                // チェックリスト実績.チェックリスト項目情報「項目番号」
                Objects.equals(item.getRstChecklistInfo().getItemNumber(), p.getRstChecklistInfo().getItemNumber()) &&
                // チェックリスト実績.チェックリスト項目情報「分類コード」
                Objects.equals(item.getRstChecklistInfo().getClassCd(), p.getRstChecklistInfo().getClassCd()))
            .collect(Collectors.toList())
            .size() > 0) {
          insertDummyFlag = false;
        }
        // 更新データリスト存在する場合、登録しない
        if (insertDummyFlag &&
          updateList.stream()
            .filter(p ->
              // チェックリスト実績「リストコード」
              Objects.equals(item.getListCd(), p.getListCd()) &&
                // チェックリスト実績.チェックリスト項目情報「項目番号」
                Objects.equals(item.getRstChecklistInfo().getItemNumber(), p.getRstChecklistInfo().getItemNumber()) &&
                // チェックリスト実績.チェックリスト項目情報「分類コード」
                Objects.equals(item.getRstChecklistInfo().getClassCd(), p.getRstChecklistInfo().getClassCd()))
            .collect(Collectors.toList())
            .size() > 0) {
          insertDummyFlag = false;
        }

        if (insertDummyFlag) {
          // 削除リスト数
          Integer deleteCount = deleteList.stream()
            .filter(p ->
              // チェックリスト実績「リストコード」
              Objects.equals(item.getListCd(), p.getListCd()) &&
                // チェックリスト実績.チェックリスト項目情報「項目番号」
                Objects.equals(item.getRstChecklistInfo().getItemNumber(), p.getRstChecklistInfo().getItemNumber()) &&
                // チェックリスト実績.チェックリスト項目情報「分類コード」
                Objects.equals(item.getRstChecklistInfo().getClassCd(), p.getRstChecklistInfo().getClassCd()))
            .collect(Collectors.toList())
            .size();
          // 既存リスト数「ダミーデータ含まない」
          Integer kisonCount = ordCheckListChecked.stream()
            .filter(p ->
              // チェックリスト実績「リストコード」
              Objects.equals(item.getListCd(), p.getListCd()) &&
                // チェックリスト実績.チェックリスト項目情報「項目番号」
                Objects.equals(item.getRstChecklistInfo().getItemNumber(), p.getRstChecklistInfo().getItemNumber()) &&
                // チェックリスト実績.チェックリスト項目情報「分類コード」
                Objects.equals(item.getRstChecklistInfo().getClassCd(), p.getRstChecklistInfo().getClassCd()))
            .collect(Collectors.toList())
            .size();
          if (deleteCount < kisonCount) {
            insertDummyFlag = false;
          }
        }

        if (insertDummyFlag) {
          OrdChecklist dummy = item.clone();
          // チェックリスト実績「実施状態」（０：未実施）
          dummy.setIsCheck(AdminWebConstant.FlagType.FLAG_OFF);
          // チェックリスト実績「実績区分」（９：ダミーデータ）
          dummy.setRstClass(Short.parseShort("9"));
          // チェックリスト実績「表示フラグ」（０：非表示）
          dummy.setIsDisp(AdminWebConstant.FlagType.FLAG_OFF);

          OrdChecklist.OrdChecklistRegCheckInfo regCheckInfo = dummy.getRstChecklistInfo();
          // チェックリスト実績.チェックリスト項目情報「医材コード」
          regCheckInfo.setCode(null);
          // チェックリスト実績.チェックリスト項目情報「医材コード更新日時」
          regCheckInfo.setCodeUpdate(null);
          // チェックリスト実績.チェックリスト項目情報「薬剤区分」
          regCheckInfo.setMedicineType(null);
          // チェックリスト実績.チェックリスト項目情報「項目名称」
          regCheckInfo.setName(null);
          // del 10310 needle _ typeの使用を削除するには gjn start
          // チェックリスト実績.チェックリスト項目情報「穿刺針区分」
          //regCheckInfo.setNeedleType(null);
          // del 10310 needle _ typeの使用を削除するには gjn end
          // チェックリスト実績.チェックリスト項目情報「数量」
          regCheckInfo.setAmount(null);
          // チェックリスト実績.チェックリスト項目情報「単位」
          regCheckInfo.setUnit(null);
          dummy.setRstChecklistInfo(regCheckInfo);

          // ダミーデータリストを登録
          dummyList.add(dummy);
        }
//del 9324 ord_checklist共通之外的dao方法删除 gjn start
        //ordChecklistDao.delete(item);
      });
      // チェックリスト実績を修正「ダミーデータ」
//      dummyList.stream().forEach(item -> {
//        ordChecklistDao.insert(item);
//      });
    } else {
      // チェックリスト実績を更新
//      updateList.stream().forEach(item -> {
//        ordChecklistDao.update(item);
//      });
      // チェックリスト実績を削除
//      deleteList.stream().forEach(item -> {
//        ordChecklistDao.delete(item);
//      });
      //del 9324 ord_checklist共通之外的dao方法删除 gjn end
    }
    return true;
  }
  /**
   * 患者経過総合ビューア用、チェックリスト実績同期処理「条件送信場合」
   *
   * @param ordNo 更新対象番号「治療情報」
   */
  private boolean syncOrdChecklistForResult(Long ordNo) throws IOException {
    // チェックリスト実績対象リスト「登録」「更新」
    List<OrdChecklist> insertList = new ArrayList<OrdChecklist>();
    List<OrdChecklist> updateList = new ArrayList<OrdChecklist>();
    LocalDateTime update = LocalDateTime.now();
    // 治療情報を取得
    OrdMainForCheckListSchedule ordMain = ordMainDao.selectByOrdNoChecklist(ordNo);
    // 治療情報がない場合
    if (ordMain == null) {
      return false;
    }

    // 最新のチェックリストマスタを取得
    List<MstChecklist> mstChecklist = mstChecklistDao.selectByFacilityCd(SelectOptions.get(), ordMain.getFacilityCd(), "0");
    MstChecklist nowMstChecklist = mstChecklist.get(0);
    String strSetting = nowMstChecklist.getChecklistSettings();
    ObjectMapper map = new ObjectMapper();
    JsonNode node = map.readTree(strSetting);

    // 登録用チェックリストデータを作成
    // mod #12235【因島】チェックリストの治療条件：抗凝固剤での小数点桁数の扱いが不正 関 start
    List<OrdChecklist> regList = checkListMakeService.getRegisterChecklistRst(ordMain, node, (long) nowMstChecklist.getChecklistCd(), true);
    // mod #12235【因島】チェックリストの治療条件：抗凝固剤での小数点桁数の扱いが不正 関 end
    if (regList != null) {
      // チェックリスト実績情報を取得（治療情報別）
      List<OrdChecklist> ordCheckListJisseki = ordChecklistDao.selectByOrdNo(SelectOptions.get(), ordNo);
      //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
      //      regList.forEach(item -> {
      //        OrdChecklist.OrdChecklistRegCheckInfo itemCheckInfo = (OrdChecklist.OrdChecklistRegCheckInfo) item.getRstChecklistInfo();
      //        // チェックリスト実績情報を取得（内訳別）
      //        OrdChecklist jisseki = ordCheckListJisseki.stream()
      //          .filter(p ->
      //            Objects.equals(p.getRstChecklistInfo().getCode(), itemCheckInfo.getCode()) &&
      //              Objects.equals(p.getRstChecklistInfo().getClassCd(), itemCheckInfo.getClassCd()))
      //          .findFirst()
      //          .orElse(null);
      //
      //        if (jisseki == null) {
      //          // チェックリスト実績情報「存在しない場合」
      //          List<OrdChecklist> exist = new ArrayList<>();
      //          // チェックリスト実績「実績区分」（９：ダミーデータ）
      //          if (Objects.equals(Short.parseShort("9"), item.getRstClass())) {
      //            // 登録一覧存在判定「ダミーデータ場合」
      //            exist = insertList.stream()
      //              .filter(p ->
      //                //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
      //                // // チェックリスト実績「実績区分」
      //                // Objects.equals(p.getRstClass(), item.getRstClass()) &&
      //                // // チェックリスト実績「リストコード」
      //                // Objects.equals(p.getListCd(), item.getListCd()) &&
      //                // // チェックリスト実績「機能種別」
      //                // Objects.equals(p.getFuncClass(), item.getFuncClass()) &&
      //                // // チェックリスト実績「チェックリスト項目情報」「チェックリストコード」
      //                // Objects.equals(p.getRstChecklistInfo().getChecklistCd(), item.getRstChecklistInfo().getChecklistCd()) &&
      //                // // チェックリスト実績「チェックリスト項目情報」「分類コード」
      //                // Objects.equals(p.getRstChecklistInfo().getClassCd(), item.getRstChecklistInfo().getClassCd()))
      //                Objects.equals(p.getRstClass(), item.getRstClass()) &&
      //                  // チェックリスト実績「リストコード」
      //                  Objects.equals(p.getListCd(), item.getListCd()) &&
      //                  // チェックリスト実績「機能種別」
      //                  Objects.equals(p.getFuncClass(), item.getFuncClass()) &&
      //                  // チェックリスト実績「チェックリスト項目情報」「チェックリストコード」
      //                  Objects.equals(p.getRstChecklistInfo().getChecklistCd(), item.getRstChecklistInfo().getChecklistCd()) &&
      //                  // チェックリスト実績「チェックリスト項目情報」「項目番号」
      //                  Objects.equals(p.getRstChecklistInfo().getItemNumber(), item.getRstChecklistInfo().getItemNumber()) &&
      //                  // チェックリスト実績「チェックリスト項目情報」「分類コード」
      //                  Objects.equals(p.getRstChecklistInfo().getClassCd(), item.getRstChecklistInfo().getClassCd()) &&
      //                  // チェックリスト実績「チェックリスト項目情報」「医材コード」
      //                  Objects.equals(p.getRstChecklistInfo().getCode(), item.getRstChecklistInfo().getCode()) &&
      //                  Objects.equals(p.getRstChecklistInfo().getMedicineType(), item.getRstChecklistInfo().getMedicineType()) &&
      //                  Objects.equals(p.getRstChecklistInfo().getMedicineNo(), item.getRstChecklistInfo().getMedicineNo()) &&
      //                  Objects.equals(p.getRstChecklistInfo().getEquipType(), item.getRstChecklistInfo().getEquipType()))
      //              //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
      //              .collect(Collectors.toList());
      //          } else {
      //            // 登録一覧存在判定「その他場合」
      //            exist = insertList.stream()
      //              .filter(p ->
      //                //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
      //                // // チェックリスト実績「実績区分」
      //                // Objects.equals(p.getRstClass(), item.getRstClass()) &&
      //                // // チェックリスト実績「リストコード」
      //                // Objects.equals(p.getListCd(), item.getListCd()) &&
      //                // // チェックリスト実績「機能種別」
      //                // Objects.equals(p.getFuncClass(), item.getFuncClass()) &&
      //                // // チェックリスト実績「チェックリスト項目情報」「項目番号」
      //                // Objects.equals(p.getRstChecklistInfo().getItemNumber(), item.getRstChecklistInfo().getItemNumber()) &&
      //                // // チェックリスト実績「チェックリスト項目情報」「分類コード」
      //                // Objects.equals(p.getRstChecklistInfo().getClassCd(), item.getRstChecklistInfo().getClassCd()) &&
      //                // // チェックリスト実績「チェックリスト項目情報」「医材コード」
      //                // Objects.equals(p.getRstChecklistInfo().getCode(), item.getRstChecklistInfo().getCode()) &&
      //                // // チェックリスト実績「チェックリスト項目情報」「穿刺針区分」ヌル存在の場合
      //                // Objects.equals(p.getRstChecklistInfo().getNeedleType(), item.getRstChecklistInfo().getNeedleType()))
      //                Objects.equals(p.getRstClass(), item.getRstClass()) &&
      //                  // チェックリスト実績「リストコード」
      //                  Objects.equals(p.getListCd(), item.getListCd()) &&
      //                  // チェックリスト実績「機能種別」
      //                  Objects.equals(p.getFuncClass(), item.getFuncClass()) &&
      //                  Objects.equals(p.getRstChecklistInfo().getChecklistCd(), item.getRstChecklistInfo().getChecklistCd()) &&
      //                  // チェックリスト実績「チェックリスト項目情報」「項目番号」
      //                  Objects.equals(p.getRstChecklistInfo().getItemNumber(), item.getRstChecklistInfo().getItemNumber()) &&
      //                  // チェックリスト実績「チェックリスト項目情報」「分類コード」
      //                  Objects.equals(p.getRstChecklistInfo().getClassCd(), item.getRstChecklistInfo().getClassCd()) &&
      //                  // チェックリスト実績「チェックリスト項目情報」「医材コード」
      //                  Objects.equals(p.getRstChecklistInfo().getCode(), item.getRstChecklistInfo().getCode()) &&
      //                  Objects.equals(p.getRstChecklistInfo().getMedicineNo(), item.getRstChecklistInfo().getMedicineNo()) &&
      //                  Objects.equals(p.getRstChecklistInfo().getEquipType(), item.getRstChecklistInfo().getEquipType()))
      //              //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
      //              .collect(Collectors.toList());
      //          }
      //          if (exist.size() == 0) {
      //            // チェックリスト実績情報を登録「存在しない場合」「登録一覧存在しない場合」
      //            OrdChecklist insertItem = item.clone();
      //            // チェックリスト実績「発生日時」
      //            insertItem.setOccurDate(Timestamp.valueOf(update));
      //
      //            insertList.add(insertItem);
      //          }
      //        } else {
      //          //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
      //          // チェックリスト実績情報を更新「存在する場合」
      //          // OrdChecklist updateItem = jisseki.clone();
      //          // // チェックリスト実績「実績区分」（１：条件送信後）
      //          // updateItem.setRstClass(Short.parseShort("1"));
      //          OrdChecklist updateItem = item.clone();
      //          updateItem.setIsCheck(jisseki.getIsCheck());
      //          updateItem.setOccurDate(Timestamp.valueOf(update));
      //          //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
      //          updateList.add(updateItem);
      //        }
      //      });
      for (int i = 0; i < regList.size(); i++) {
        Boolean regflg = true;
        for (int j = 0; j < ordCheckListJisseki.size(); j++) {
          if (regList.get(i).getFuncClass() == 0) {
            if (Objects.equals(regList.get(i).getRstChecklistInfo().getItemNumber(), ordCheckListJisseki.get(j).getRstChecklistInfo().getItemNumber())
              &&
              Objects.equals(regList.get(i).getRstChecklistInfo().getName(), ordCheckListJisseki.get(j).getRstChecklistInfo().getName())
              &&
              Objects.equals(regList.get(i).getRstClass(), ordCheckListJisseki.get(j).getRstClass())
              &&
              Objects.equals(regList.get(i).getListCd(), ordCheckListJisseki.get(j).getListCd())
              &&
              Objects.equals(regList.get(i).getFuncClass(), ordCheckListJisseki.get(j).getFuncClass())
            ) {
              // 登録しない
              regflg = false;
              break;
            }
          } else {
            if (Objects.equals(regList.get(i).getListCd(), ordCheckListJisseki.get(j).getListCd()) &&
              Objects.equals(regList.get(i).getFuncClass(), ordCheckListJisseki.get(j).getFuncClass()) &&
              Objects.equals(regList.get(i).getRstChecklistInfo().getItemNumber(),
                ordCheckListJisseki.get(j).getRstChecklistInfo().getItemNumber())
              &&
              Objects.equals(regList.get(i).getRstChecklistInfo().getClassCd(),
                ordCheckListJisseki.get(j).getRstChecklistInfo().getClassCd())
              &&
              Objects.equals(regList.get(i).getRstChecklistInfo().getCode(),
                ordCheckListJisseki.get(j).getRstChecklistInfo().getCode())
              // del 10310 needle _ typeの使用を削除するには gjn start
//              &&
//              Objects.equals(regList.get(i).getRstChecklistInfo().getNeedleType(),
//                ordCheckListJisseki.get(j).getRstChecklistInfo().getNeedleType())
              // del 10310 needle _ typeの使用を削除するには gjn end
              &&
              Objects.equals(regList.get(i).getRstClass(), ordCheckListJisseki.get(j).getRstClass())
              &&
              Objects.equals(regList.get(i).getRstChecklistInfo().getMedicineType(), ordCheckListJisseki.get(j).getRstChecklistInfo().getMedicineType())
              &&
              Objects.equals(regList.get(i).getRstChecklistInfo().getMedicineNo(), ordCheckListJisseki.get(j).getRstChecklistInfo().getMedicineNo())
              &&
              Objects.equals(regList.get(i).getRstChecklistInfo().getEquipType(), ordCheckListJisseki.get(j).getRstChecklistInfo().getEquipType())
              &&
              Objects.equals(regList.get(i).getRstChecklistInfo().getAmount(), ordCheckListJisseki.get(j).getRstChecklistInfo().getAmount()))
            {
              // 登録しない
              regflg = false;
              break;
            }
          }
        }
        // 未登録の実績のみ
        if (regflg) {
          // 実績作成
          ordChecklistDao.insert(regList.get(i));
        }
      }
      //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
    }

    //  del 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
    // チェックリスト実績を更新
    //    updateList.stream().forEach(item -> {
    //      ordChecklistDao.update(item);
    //    });
    //    // チェックリスト実績を登録
    //    insertList.stream().forEach(item -> {
    //      ordChecklistDao.insert(item);
    //    });
    //  del 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end

    return true;
  }
  //add 2023-03-02  6817 手動実績作成に失敗しても透析回数がカウントされてしまう 張 end

  /* add by chamaojia 2023-03-20 [8101] 新しいアセンブリオブジェクト変換  --start */
  private List<OrdMainEsListener> copyOrdMainEntity(List<OrdMain> ordMainList) {
    List<OrdMainEsListener> ordMainEsListenerList = new ArrayList<>();
    for (OrdMain ordMain : ordMainList) {
      OrdMainEsListener ordMainEsListener = new OrdMainEsListener();
      BeanUtils.copyProperties(ordMain, ordMainEsListener);
      ordMainEsListenerList.add(ordMainEsListener);
    }
    return ordMainEsListenerList;
  }
  /* add by chamaojia 2023-03-20 [8101] 新しいアセンブリオブジェクト変換  --end */

  //upd by ztc 2023-03-20 Treatment method change branch 2, 3 optimization --start /
  public int uptOrdMainInfoList(List<OrdMainEsListener> ordMainUptList){
    List<Long> ordNos = ordMainUptList.stream().map(OrdMainEsListener::getOrdNo).collect(Collectors.toList());
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.batchSetOperatorId(ordMainUptList,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
//    OrdMain oldOrdMain = ordMainDao.selectByOrdNo(m.getOrdNo());
        // upd 一括治療方法変更届出ミス 20230712 ztc start
    int updateCount = 0;
    List<List<OrdMainEsListener>> partitionList = Lists.partition(ordMainUptList, 30);
    for (List<OrdMainEsListener> partition : partitionList) {
      updateCount = ordMainDao.updateOrdMainEsListener(partition);
    }
    // upd 一括治療方法変更届出ミス 20230712 ztc end
    getListByMode1History(ordNos);
//    OrdMain newOrdMain = ordMainDao.selectByOrdNo(m.getOrdNo());
//    triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain), Collections.singletonList(newOrdMain));
    return updateCount;
  }

  // add 9200 by kangjie 20230914 start
  @Override
  public List<OrdMain> getOrdMainOfIndMediInfo(ApiEntityOrdMain.ValiIndMediInfoSearchCondition bodyData) {
    FacilitySettingInfo bySettingNoAndCd = mstFacilitySettingDao.getBySettingNoAndCd(bodyData.getFacilityCd(), SETTING_NO_3008);
    if (StringUtils.isEmpty(bySettingNoAndCd.getValue())){
      return new ArrayList<>();
    }
    String startTime = "";
    String emdTime = "";
    String baseDay = bodyData.getStartTime();
    startTime = baseDay.replace("-","");
    String value = bySettingNoAndCd.getValue();
    // -1の場合は上限なし
    if (VALUE_MINUS_1.equals(value)){
      emdTime = END_MAX_DATE;
    }else {
      try {
        String futureDate = getFutureDateAsString(baseDay, Integer.valueOf(bySettingNoAndCd.getValue().replace("日","")));
        emdTime = futureDate.replace("-","");
      } catch (ParseException e) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setSqlIdentification("getOrdMainOfIndMediInfo Exception:"+ e.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        throw new RuntimeException(e);
      }
    }
    List<OrdMain> ordMains = null;
    try {
      List<Integer> list = new ArrayList<>();
      list.add(0);
      ordMains = ordMainDao.selectByDateCd(bodyData.getFacilityCd(), Long.valueOf(bodyData.getPatId()), startTime, emdTime, null, list, IS_DEL_0);

      /* add by chamaojia 2026-03-17 [12462] 患者情報共有->患者経過総合ビューア --start */
      Integer patShareMode = bodyData.getPatShareMode();
      if (!ObjectUtils.isEmpty(patShareMode) && patShareMode == 0) {
        List<OrdMain> ordMainsToShr = ordMainDao.selectByDateCdToPatShr(bodyData.getFacilityCd(), Long.valueOf(bodyData.getPatId()), startTime, emdTime);
        if (!ObjectUtils.isEmpty(ordMainsToShr)) {
          ordMains.addAll(ordMainsToShr);
        }
      }
      /* add by chamaojia 2026-03-17 [12462] 患者情報共有->患者経過総合ビューア --end */

    }catch (Exception e){
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (bodyData != null && !StringUtils.isEmpty(bodyData.getFacilityCd())) {
        eventLogMessage.setFacilityCd(bodyData.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang end
      eventLogMessage.setSqlIdentification("getOrdMainOfIndMediInfo Exception:"+ e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }
    return ordMains;
  }
  // add 9200 by kangjie 20230914 end
  /**
   *
   * @param inputDateString 期日です
   * @param daysToAdd  時間間隔です。
   * @return
   * @throws ParseException
   */

  public static String getFutureDateAsString(String inputDateString,int daysToAdd) throws ParseException {
    int len = inputDateString.length();
    if ( LEN_8 == len) {
      String year = inputDateString.substring(0, 4);
      String month = inputDateString.substring(4, 6);
      String day = inputDateString.substring(6, 8);
      String formattedDate = String.format("%s-%s-%s", year, month, day);
      SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
      Date date = sdf.parse(formattedDate);
      Calendar calendar = Calendar.getInstance();
      calendar.setTime(date);
      calendar.add(Calendar.DATE, daysToAdd);
      return sdf.format(calendar.getTime());
    }
    return "";
  }
  public void batchUpdateOrdMainScheduleInfo(List<OrdMainUptSchInfoVo> ordMainUptSchInfoVoList){
    try {

      // add FNSI-改修内容追加OrdMain履歴 付 start
//      selectHistoryUtils.insertMangoDbHistory(3, null, null, ordNoList, new ArrayList<>(), null, null,
//        null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
//        new ArrayList<>(), null, null);
      // mangoDb-updateOrdMainScheduleInfo-insertSuccess
      // add FNSI-改修内容追加OrdMain履歴 付 end
      // mod FNSI-指示編集でDB登録データの更新 楊 start
      /* mod #5482 by zhangruixue 2023-03-03 スケジュール --start */
//      MstPersonalUser user = mstPersonalUserDao.selectById(indUserId.longValue());
//      MstPersonalUser user = MasterCacheHandler.get().getMstPersonalUser(indUserId.longValue());
      /* mod #5482 by zhangruixue 2023-03-03 スケジュール --start */
      // mod FNSI-指示編集でDB登録データの更新 楊 end
      // メインスケジュール更新
      // add 6227 張 start
//      ordNoList.forEach(item->{
//        copyOrdmainToOrdMainRestore(item);
//      });
      // add 6227 張 end
//      List<OrdMain> oldOrdMains = ordMainDao.selectAllByOrdNoList(ordNoList);
      List<Long> ordNoList = ordMainUptSchInfoVoList.stream().map(OrdMainUptSchInfoVo::getOrdNo).collect(Collectors.toList());
      int[] uptDoneOrdNos = ordMainDao.updateOrdMainScheduleInfoByOrdNo(ordMainUptSchInfoVoList);
//      List<OrdMain> newOrdMains = ordMainDao.selectAllByOrdNoList(ordNoList);
//      triggerUtil.updateTriggerOrdMain(oldOrdMains, newOrdMains);
      // add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.79(外結)対応 韓 end
      selectHistoryUtils.insertMangoDbHistory(3, null, null, ordNoList, new ArrayList<>(), null, null,
        null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
        new ArrayList<>(), null, null);
      List<Long> getIndexWithZeros = this.getUpdFailOrdNoWithZero(uptDoneOrdNos,ordMainUptSchInfoVoList);
      if (uptDoneOrdNos != null && !getIndexWithZeros.isEmpty()) {
        getIndexWithZeros.forEach(ord -> {
          OrdMainUptSchInfoVo findErrOrdMain = ordMainUptSchInfoVoList.stream().filter(omus -> ord.equals(omus.getOrdNo())).findFirst().orElse(null);
          if(!Objects.isNull(findErrOrdMain)){
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage("スケジュール更新に失敗しました(更新対象オーダ番号リスト=" + ordNoList + ")");
            eventLogMessage.setSqlIdentification(
              "(ordNoList = " + ordNoList + ", indKurCd = " + findErrOrdMain.getIndKurCd() +
                ", indKurName = " + findErrOrdMain.getIndKurName() + ", indTreatStartTime = " + findErrOrdMain.getIndTreatStartTime()
                + ", indBedCd = " + findErrOrdMain.getIndBedCd() + ", indBedName = " + findErrOrdMain.getIndBedName()
                + ", indUserId = " + findErrOrdMain.getIndUserId() + ", updUserid = " + findErrOrdMain.getUpdUserid()
                + ", updateMode = " + findErrOrdMain.getUpdateMode() + ")");
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS,
              "OrdMainDao/updateOrdMainScheduleInfo");
            String opeMode = "3";
            if(findErrOrdMain.getIndKurCd() == 0 || findErrOrdMain.getIndBedCd() == 0){
              opeMode = "2";
              try {
                webApiCallCommonUtil.operateDummySchedule(Arrays.asList(findErrOrdMain.getOrdNo()), findErrOrdMain.getIndBedCd(), findErrOrdMain.getIndKurCd(), opeMode);
              } catch (URISyntaxException e) {
                // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
                // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
                // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
                EventLogMessage eventLogMessageNew = new EventLogMessage();
                eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
                logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
                // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
              }
            }
          }
        });
      }
      // DB更新ログ出力ロジック wangzuo Start
      String tableName = "pat_ind_approve";
      // SQL検索条件
      String inStr = getInStr("ord.ord_no IN ", ordNoList);
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append("ord_no IN (" + "\n");
      wheres.append("SELECT ord.ord_no" + "\n");
      wheres.append("FROM ord_main as ord" + "\n");
      wheres.append("JOIN mst_facility_setting as setting" + "\n");
      wheres.append("ON ord.facility_cd = setting.facility_cd" + "\n");
      wheres.append("WHERE" + "\n");
      wheres.append(inStr + "\n");
      wheres.append("AND setting.facility_setting_no = '1022'" + "\n");
      wheres.append("AND value = '1')" + "\n");
      // logCommon設定
      DataUpdateLogCommonNew logCommon = getLogCommon(patIndApproveDao, tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResult = logCommon.setInfo();
      // DB更新ログ出力ロジック wangzuo End

      int patUpdateCount = updateContentChangeListByBedControlWithNotification(ordNoList, new PatIndApprove());
      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && patUpdateCount > 0) {
        /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --start */
        logCommon.setAfterResults();
//        logCommon.updateLog();
        asyncService.updateLog(logCommon);
        /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --end */
      }
      // DB更新ログ出力ロジック wangzuo End

    } catch (Exception e) {
      // ロールバック実行
      throw new RuntimeException(e.getMessage());
    }
  }

  public List<Long> getUpdFailOrdNoWithZero(int[] uptDoneOrdNos, List<OrdMainUptSchInfoVo> ordMainUptSchInfoVoList) {
    List<Long> UpdFailOrdNos = new ArrayList<>();
    for (int i = 0; i < uptDoneOrdNos.length; i++) {
      if (uptDoneOrdNos[i] == 0) {
        UpdFailOrdNos.add(ordMainUptSchInfoVoList.get(i).getOrdNo());
      }
    }
    return UpdFailOrdNos;
  }
//upd by ztc 2023-03-20 Treatment method change branch 2, 3 optimization --end /
  // add #8548 修正 ljx start
  /**
   *
   * @param updateOrdMainList 移動先に既に存在する予定
   * @return
   */
  private List<JournalCreateRequestPayload> getPatInfo (List<OrdMain> updateOrdMainList){
    List<Long> patIdList = new ArrayList<>();
    for(OrdMain ordMain:updateOrdMainList){
      //存在する予定のordMainより、患者IDを取得。
      patIdList.add(ordMain.getPatId());
    }
    //患者IDより、患者情報を取得。
    List<PatPersonalMain> patPersonalMainList =  patPersonalMainDao.selectByIdList(patIdList);
    List<JournalCreateRequestPayload> journalList = new ArrayList<>();
    JournalCreateRequestPayload journal = null;
    for(int i = 0;i<patIdList.size();i++){
      for(int j = 0;j<patPersonalMainList.size();j++){
        if(patPersonalMainList.get(j).getPat_id().toString().equals(patIdList.get(i).toString())){
          journal = new JournalCreateRequestPayload();
          journal.setHospPatId(patPersonalMainList.get(j).getHosp_pat_id());
          journal.setPatId(patPersonalMainList.get(j).getPat_id());
          journal.setOrdNo(updateOrdMainList.get(i).getOrdNo());
          journalList.add(journal);
        }
      }
    }
    return journalList;
  }

  /**
   * 電文リスト作成
   * @param requestList
   * @return
   */
  private List<JournalCreateRequestPayload> getJouralList(List<OrdMainJournalRequest> requestList) {
    List<JournalCreateRequestPayload> jouralList = new ArrayList<>();
    if (null != requestList && requestList.size() > 0) {
      for (OrdMainJournalRequest ord : requestList) {
        JournalCreateRequestPayload journalCreateRequestPayload = new JournalCreateRequestPayload();
        JournalCreateRequestPayload journalTmp = ord.getPayload();
        journalCreateRequestPayload.setFacilityCd(journalTmp.getFacilityCd());
        journalCreateRequestPayload.setCrud(journalTmp.getCrud());
        journalCreateRequestPayload.setHospPatId(journalTmp.getHospPatId());
        journalCreateRequestPayload.setPatId(journalTmp.getPatId());
        journalCreateRequestPayload.setUserId(journalTmp.getUserId());
        journalCreateRequestPayload.setOpeCd(journalTmp.getOpeCd());
        journalCreateRequestPayload.setOrdNo(journalTmp.getOrdNo());
        journalCreateRequestPayload.setBaseDate(journalTmp.getBaseDate());
        jouralList.add(journalCreateRequestPayload);
      }
    }
    return jouralList;
  }
  // add #8548 修正 ljx end
  // add FNSI-9355 ljx start
  @Override
  public List<OrdMain> deepCopyList(List<OrdMain> targetList){
    List<OrdMain> ordMainList = new ArrayList<>();
    /* mod #10276 by zhangruixue 2024-03-12  --start */
    targetList.forEach(item -> {
      OrdMain copyedOrdMain = new OrdMain();
      BeanUtils.copyProperties(item,copyedOrdMain);
      ordMainList.add(copyedOrdMain);
    });
    /* mod #10276 by zhangruixue 2024-03-12  --end */
    return ordMainList;
  }
  // add FNSI-9355 ljx end

   //#8484　医療材料選択IFのリスト不正　Start
  /**
   * 選択肢マスタ(mst_selector)による部材コードの並び替え.
   * @param String facility_cd 医療施設コード.
   * @param List<Integer> equip_cds 医療材料毎の部材コード一覧.
   * @param String equip_type 部材コード一覧の医療材料区分(0: 医療材料, 1: ダイアライザ)
   * @return 選択肢マスタ(mst_selector)の並び順を反映した部材コード一覧.
   */
  public List<Integer> getCodesOrderByMstSelector(String facility_cd, List<Integer> equip_cds, String equip_type) {
    String target_table_name = "0".equals(equip_type) ? "mst_equipment" : "mst_dialyzer";
    // 選択肢マスタ(mst_selector)より並び順に沿ったコード一覧を取得
    List<Integer> codes = getOrderSettingItems(facility_cd, target_table_name);

    // コードの並び順に従いソートする
    List<Integer> sorted_cds = new ArrayList<>();
    codes.stream().forEach(code -> {
      equip_cds.stream()
        .filter(e -> e.equals(code))
        .findFirst()
        .ifPresent(e -> sorted_cds.add(e));
    });
    // 削除済の部材を抽出して最後に追加
    return Stream.concat
      (
        sorted_cds.stream(),
        equip_cds.stream()
        .filter(e -> !codes.contains(e))
      )
      .collect(Collectors.toList());
  }

  /**
   * 対象施設の対象マスタの並び順管理情報を取得します.
   * @param facilityCd 施設コード
   * @param tableName マスタ物理名
   * @return 並び順
   */
  private List<Integer> getOrderSettingItems(String facilityCd, String tableName) {
    List<Integer> seq = new ArrayList<>();
    MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, tableName);
    if(Objects.isNull(mstSelector)) {
      return emptyList();
    }
    return mstSelector.getOrderSettings()
      .getItems()
      .stream()
      .map(i -> Integer.parseInt(i.getCode().toString()))
      .collect(Collectors.toList());
  }
  //#8484　医療材料選択IFのリスト不正　End

  //add 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy start
  @Override
  public List<OrdMainMedicineDelete> getPatIndAndRstMmdicine(OrdMainRequest ordMainRequest) {
    return ordMainDao.getPatIndAndRstMmdicine(ordMainRequest);
  }

  @Override
  public List<OrdMainMedicineDelete> getPatIndMmdicine(OrdMainRequest ordMainRequest) {
    return ordMainDao.getPatIndMmdicine(ordMainRequest);
  }
  //add 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy start
  // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関  start
  public InvokeResult<Map<String,List>> updatetByTreatSetCdOptimizeImpl(ApiEntityOrdMain.ValiCreateTreatPlan bodyData, NtssUser ntssUser,
                                                                        List<JournalCreateRequestPayload> ctlNoList, long mediInfoNo) throws Exception {
    EventLogMessage eventLogMessage = new EventLogMessage();
    InvokeResult<Map<String,List>> invokeResult = new InvokeResult<>();
    Map<String,List> resultData = new HashMap<>();
    HashSet msglist = new HashSet();
    ArrayList<String> error = new ArrayList<>();
    boolean isTreatSet = true;
    // フラグが0の場合、治療方法のみ変更
    if (0 == Integer.parseInt(bodyData.getTreat_method_flag())) {
      isTreatSet = false;
    }
    // 更新情報の作成
    // 更新対象治療方法リスト
    List<Integer> initTreatmentCdList;
    // 更新対象クールリスト
    List<Integer> initKurCdList;
    // 変更後治療方法リスト
    Integer editTreatmentCd = null;
    final String facilityCd = bodyData.getFacility_cd();

    Integer targetTreatmentCd = Integer.parseInt(bodyData.getTreatment_set_cd());
    List<MstTreatmentSet> listMstTreatSet = mstInfoService.findMstTreatmentSetByCd(Integer.parseInt(bodyData.getTreatment_set_cd()));
    PatMain patMain = patMainDao.selectById(Long.parseLong(bodyData.getPat_id()));
    List<Long> patIdList = new ArrayList<>();
    patIdList.add(Long.parseLong(bodyData.getPat_id()));
    MstPersonalUser user = mstPersonalUserDao.selectById(bodyData.getInd_user_id().longValue());
    MstPersonalUser updUser = mstPersonalUserDao.selectById(bodyData.getUpd_user_id().longValue());
    String targetTreatmentCdList = bodyData.getInd_treatment_cd();
    String deviceSetInfo = patMain.getDevice_set_info();
    if (isTreatSet) {
      // 更新対象治療方法コードを格納
      initTreatmentCdList = this.getValueList(bodyData.getInd_treatment_cd());
      // 更新対象クールコードを格納
      initKurCdList = this.getIntegerList(bodyData.getInd_kur_cd());

      targetTreatmentCd = listMstTreatSet.get(0).getTreatmentCd();
    } else {
      // 治療方法のみで変更する場合
      // 更新対象治療方法コードを格納
      initTreatmentCdList = this.getValueList(bodyData.getInd_treatment_cd());
      // 更新対象クールコードを格納
      initKurCdList = this.getIntegerList(bodyData.getInd_kur_cd());
      // 変更後の治療方法を格納
      editTreatmentCd = Integer.parseInt(bodyData.getTreatment_set_cd());
    }
    long maxMediInfoNo = 1;
    // 識別番号が取得する場合
    if (mediInfoNo >= 0) {
      maxMediInfoNo = mediInfoNo + 1;
    }

    List<OrdMain> ordMainAllList = ordMainDao.selectUpdateTarget(
      Long.parseLong(bodyData.getPat_id()),
      bodyData.getFacility_cd(),
      bodyData.getStart_date().replaceAll("-", ""),
      bodyData.getEnd_date().replaceAll("-", ""),
      IndicationUtils.getWeekPattern(bodyData.getWeek_pattern()),
      new ArrayList<>(),
      new ArrayList<>(),
      null
    );
    StringBuilder keyTmp = new StringBuilder();
    List<OrdMain> ordMainList = new ArrayList<>();
    Map<String, String> duplicateOrdMain = new HashMap<>();
    // 条件送信キャンセル対象リスト
    List<OrdMain> timeChangeList = new ArrayList<>();
    Integer selectTreatmentTime = null;
    if (isTreatSet) {
      JSONObject selectIndCondInfo = new JSONObject(listMstTreatSet.get(0).getIndCondInfo());
      if (selectIndCondInfo.has("1")
        && ! "null".equals(selectIndCondInfo.getJSONObject("1").get("value").toString())) {
        selectTreatmentTime = Integer.parseInt(selectIndCondInfo.getJSONObject("1").get("value").toString());
      }
    }
    for (OrdMain item : ordMainAllList) {
      int dialysisState = Integer.parseInt(item.getRstDialysisState());
      keyTmp.setLength(0);
      keyTmp.append(item.getTreatDate());
      keyTmp.append(",");
      keyTmp.append(item.getIndKurCd());
      keyTmp.append(",");
      if ((initTreatmentCdList.size() == 0 || initTreatmentCdList.contains(item.getIndTreatmentCd()))
        && (initKurCdList.size() == 0 || initKurCdList.contains(item.getIndKurCd()))) {
        keyTmp.append(targetTreatmentCd.toString());
        if (! duplicateOrdMain.containsKey(keyTmp.toString())) {
          if (0 == dialysisState || !"0".equals(bodyData.getStartsFlg())) {
            ordMainList.add(item);
            if (selectTreatmentTime != null && (item.getIndKurCd() != 0 || item.getIndTreatStartTime() != null) && item.getIndBedCd() != 0) {
              JSONObject oldIndCondInfo = new JSONObject(item.getIndCondInfo());
              if (oldIndCondInfo.has("1")
                && ! "null".equals(oldIndCondInfo.getJSONObject("1").get("value").toString()) &&
                Integer.parseInt(oldIndCondInfo.getJSONObject("1").get("value").toString()) != selectTreatmentTime) {
                timeChangeList.add(item);
              }
            }
          }
        }
      } else {
        keyTmp.append(item.getIndTreatmentCd());
      }
      if (! duplicateOrdMain.containsKey(keyTmp.toString())) {
        duplicateOrdMain.put(keyTmp.toString(), "");
      } else {
        msglist.add("22010011");
        resultData.put("msglist", new ArrayList<String>(msglist));
        invokeResult.success(resultData);
        return invokeResult;
      }
    }
    if (ordMainList.size() == 0) {
      error.add("");
      resultData.put("error", error);
      invokeResult.success(resultData);
      return invokeResult;
    }
    Long selectOrdNo = null;
    if (!"0".equals(bodyData.getStartsFlg())) {
      selectOrdNo = ordMainList.get(0).getOrdNo();
    }

    MstTreatment treatmentParams = new MstTreatment();
    treatmentParams.setFacilityCd(bodyData.getFacility_cd());
    MstTreatment selectedTreat;
    if (isTreatSet) {
      selectedTreat = mstTreatmentDao.selectByCd(listMstTreatSet.get(0).getTreatmentCd());
    } else {
      selectedTreat = mstTreatmentDao.selectByCd(Integer.parseInt(bodyData.getTreatment_set_cd()));
    }
    List<Long> ordNoList = ordMainList.stream().map(OrdMain::getOrdNo).distinct().collect(Collectors.toList());
    //del 9324 治療法変更直接コールord）checklist共通 gjn start
    //ordChecklistDao.deleteByOrdNoAndFacilityCdBatch(ordNoList, bodyData.getFacility_cd());
    //del 9324 治療法変更直接コールord）checklist共通 gjn end


    Map<Integer, MstDialyzer> mstDialyzerMap = new HashMap<>();
    for (OrdMain item : ordMainList) {
      // mod #11408 特殊浄化の治療方法セットマスタで治療方法の変更できない zkm start
//      JSONObject mstIndCondInfo = new JSONObject(item.getIndCondInfo());
      JSONObject mstIndCondInfo = new JSONObject(StringUtils.isEmpty(item.getIndCondInfo()) ? "{}" : item.getIndCondInfo());
      // mod #11408 特殊浄化の治療方法セットマスタで治療方法の変更できない zkm end
      JSONArray conditionSetting = new JSONArray(selectedTreat.getTreatmentConditionSetting());
      Boolean isUse = this.checkTreatCondIsUse(conditionSetting, "19");
      if (!mstIndCondInfo.has("19") && isUse) {
        msglist.add("16010001");
      }
      // 装置設定
      JSONObject oldIndDeviceSetInfo = new JSONObject(item.getIndDeviceSetInfo());
      // 除水プログラム
      JSONObject oldUfrInfo = new JSONObject(oldIndDeviceSetInfo.getJSONObject("ufr")
        .getJSONObject("dev")
        .getJSONObject("A")
        .toString());
      // 透析液濃度プログラム
      JSONObject oldDcInfo = new JSONObject(oldIndDeviceSetInfo.getJSONObject("dc")
        .getJSONObject("dev")
        .getJSONObject("A")
        .toString());
      // 血流量・透析液流量プログラム
      JSONObject oldQbqdInfo = new JSONObject(oldIndDeviceSetInfo.getJSONObject("qbqd")
        .getJSONObject("dev")
        .getJSONObject("A")
        .toString());
      // BV-UFC
      JSONObject oldBvufcInfo = new JSONObject(oldIndDeviceSetInfo.getJSONObject("bvufc")
        .getJSONObject("dev")
        .getJSONObject("A")
        .toString());
      // 透析量プログラム
      JSONObject oldDiaInfo = new JSONObject(oldIndDeviceSetInfo.getJSONObject("dia")
        .getJSONObject("dev")
        .getJSONObject("A")
        .toString());
      // Na注入プログラム
      JSONObject oldNaInfo = new JSONObject(oldIndDeviceSetInfo.getJSONObject("na")
        .getJSONObject("dev")
        .getJSONObject("A")
        .toString());
      JSONObject oldIndCondInfo = null == item.getIndCondInfo() ?
        new JSONObject() :
        new JSONObject(item.getIndCondInfo());
      // 血流量操作範囲上限
      JSONObject deviceSetInfoObject = (deviceSetInfo == null || deviceSetInfo.isEmpty()) ?
        new JSONObject() :
        new JSONObject(deviceSetInfo);
      JSONObject opeDev = new JSONObject(deviceSetInfoObject.getJSONObject("ope")
        .getJSONObject("dev")
        .toString());
      // 透析液温度操作範囲上限
      JSONObject opeTemperature = new JSONObject(opeDev.get("A").toString());
      JSONObject warA = new JSONObject(deviceSetInfoObject.getJSONObject("war")
        .getJSONObject("dev")
        .getJSONObject("A")
        .toString());
      //"182":透析液温度操作範囲上限   183:透析液温度操作範囲下限
      if (oldIndCondInfo.has("18")
        && opeTemperature.has("182")
        && opeTemperature.has("183")
        && ! jsonNodeIsNull(oldIndCondInfo.getJSONObject("18").get("value").toString())
        && ! jsonNodeIsNull(opeTemperature.get("182").toString())
        && ! jsonNodeIsNull(opeTemperature.get("183").toString())
        && (Double.parseDouble(oldIndCondInfo.getJSONObject("18").get("value").toString()) >
        Double.parseDouble(opeTemperature.get("182").toString()) ||
        Double.parseDouble(oldIndCondInfo.getJSONObject("18").get("value").toString()) <
          Double.parseDouble(opeTemperature.get("183").toString()))) {
        msglist.add("12000021");
      }

      if (DeviceMode.HDF.equals(selectedTreat.getDeviceMode()) || DeviceMode.HF.equals(selectedTreat.getDeviceMode())
        || DeviceMode.OHDF.equals(selectedTreat.getDeviceMode()) || DeviceMode.OHF.equals(selectedTreat.getDeviceMode())
        || DeviceMode.AFBF.equals(selectedTreat.getDeviceMode())) {
        boolean isECUMSet = false;
        // 装置設定情報を取得(装置設定デフォルトマスタ)
        // HD/ECUMのECUMがある場合は切替をHDに強制変更。警告メッセージ
        // 0: "HD",  1: "ECUM"
        for (int j = 291; j <= 300; j++) {
          if ("1".equals(oldUfrInfo.get(String.valueOf(j)))) {
            isECUMSet = true;
          }
        }
        if (isECUMSet) {
          msglist.add("12000074");
        }
      }
      // 5.除水プログラム、ONの場合は強制的にOFFに変更する。
      if (DeviceMode.I_HDF.equals(selectedTreat.getDeviceMode())) {
        if (! "0".equals(oldUfrInfo.get("290").toString())) {
          msglist.add("12000075");
        }
      }
      // 6.Na注入プログラム、ONの場合は強制的にOFFに変更する。
      if (DeviceMode.PURIFICATION.equals(selectedTreat.getDeviceMode())) {
        if (! "0".equals(oldNaInfo.get("315").toString())) {
          msglist.add("12000080");
        }
      }
      // 6.B液濃度プログラム、ONの場合は強制的にOFFに変更する。
      // 6.透析液濃度プログラム、ONの場合は強制的にOFFに変更する。
      if (DeviceMode.AFBF.equals(selectedTreat.getDeviceMode())) {
        if (! "0".equals(oldDcInfo.get("340").toString())) {
          msglist.add("12000076");
        }
      }
      if (DeviceMode.I_HDF.equals(selectedTreat.getDeviceMode())) {
        // 7.血流量・透析液流量プログラム、ONの場合は強制的にOFFに変更する。
        if (! "0".equals(oldQbqdInfo.get("430").toString())) {
          msglist.add("12000077");
        }
        // 8.BV-UFC、ONの場合は強制的にOFFに変更する。
        if (! "0".equals(oldBvufcInfo.get("196").toString())) {
          msglist.add("12000078");
        }
      }
      // 9.透析量プログラム  ONの場合は強制的にOFFに変更する。
      // メッセージ表示
      if (DeviceMode.HDF.equals(selectedTreat.getDeviceMode()) || DeviceMode.HF.equals(selectedTreat.getDeviceMode())
        || DeviceMode.OHDF.equals(selectedTreat.getDeviceMode()) || DeviceMode.OHF.equals(selectedTreat.getDeviceMode())
        || DeviceMode.AFBF.equals(selectedTreat.getDeviceMode()) || DeviceMode.I_HDF.equals(selectedTreat.getDeviceMode())
        || DeviceMode.PURIFICATION.equals(selectedTreat.getDeviceMode())) {
        if (! "0".equals(oldDiaInfo.get("282").toString())) {
          msglist.add("12000079");
        }
      }
      // シングルニードル使用するの場合
      // ・使用しない強制変更
      // ・穿刺針(SN)も未登録に強制変更
      // メッセージを表示
      if (DeviceMode.I_HDF.equals(selectedTreat.getDeviceMode()) || DeviceMode.AFBF.equals(selectedTreat.getDeviceMode())) {
        if (oldIndCondInfo.has("12")                // シングルニードル使用するの場合
          && ! "null".equals(oldIndCondInfo.getJSONObject("12").get("value").toString())
          && "1".equals(oldIndCondInfo.getJSONObject("12").get("value").toString())) {
          msglist.add("12000024");
        }
      }
      if (isTreatSet) {
        if (DeviceMode.HD.equals(selectedTreat.getDeviceMode()) || DeviceMode.ECUM.equals(selectedTreat.getDeviceMode())
          || DeviceMode.HDF.equals(selectedTreat.getDeviceMode()) || DeviceMode.HF.equals(selectedTreat.getDeviceMode())
          || DeviceMode.OHDF.equals(selectedTreat.getDeviceMode()) || DeviceMode.OHF.equals(selectedTreat.getDeviceMode())
          || DeviceMode.AFBF.equals(selectedTreat.getDeviceMode()) || DeviceMode.I_HDF.equals(selectedTreat.getDeviceMode())) {
          // 1.変更対象の予定に治療時間が10:00以上の予定が存在する場合、注意メッセージ表示
          JSONObject newindCondInfo = new JSONObject(listMstTreatSet.get(0).getIndCondInfo());
          if (newindCondInfo.has("1")
            && ! "null".equals(newindCondInfo.getJSONObject("1").get("value").toString())
            && Integer.parseInt(newindCondInfo.getJSONObject("1").get("value").toString()) >= 600) {
            msglist.add("12000020");
          }
        }
      } else {
        JSONObject indCondInfo = null == item.getIndCondInfo() ?
          new JSONObject() :
          new JSONObject(item.getIndCondInfo());
        //特殊浄化以外
        if (DeviceMode.HD.equals(selectedTreat.getDeviceMode()) || DeviceMode.ECUM.equals(selectedTreat.getDeviceMode())
          || DeviceMode.HDF.equals(selectedTreat.getDeviceMode()) || DeviceMode.HF.equals(selectedTreat.getDeviceMode())
          || DeviceMode.OHDF.equals(selectedTreat.getDeviceMode()) || DeviceMode.OHF.equals(selectedTreat.getDeviceMode())
          || DeviceMode.AFBF.equals(selectedTreat.getDeviceMode()) || DeviceMode.I_HDF.equals(selectedTreat.getDeviceMode())) {

          //1.変更対象の予定に治療時間が10:00以上の予定が存在する場合、注意メッセージ表示
          if (indCondInfo.has("1")
            && ! jsonNodeIsNull(indCondInfo.getJSONObject("1").get("value").toString())
            && Integer.parseInt(indCondInfo.getJSONObject("1").get("value").toString()) >= 600) {
            msglist.add("12000020");
          }
        }

        // 3:積層型ダイアライザが設定されていた場合、注意メッセージ
        if (indCondInfo.has("5") && ! jsonNodeIsNull(indCondInfo.getJSONObject("5").get("value").toString())) {
          Integer diaAnalyzer = Integer.parseInt(indCondInfo.getJSONObject("5").get("value").toString());
          MstDialyzer dialyzer;
          if (mstDialyzerMap.containsKey(diaAnalyzer)) {
            dialyzer = mstDialyzerMap.get(diaAnalyzer);
          } else {
            dialyzer = mstDialyzerDao.selectByDialyzerCd(SelectOptions.get(), diaAnalyzer);
            mstDialyzerMap.put(diaAnalyzer, dialyzer);
          }
          // '1':積層
          if (selectedTreat.getDeviceMode().equals(DeviceMode.I_HDF)
            && dialyzer != null
            && "1".equals(dialyzer.getDialyzerType())) {
            //mod #10154_#10183 zhao start
            //msglist.add("13000165");
            msglist.add("12000025");
            //mod #10154_#10183 zhao end
          }
        }

        //10.TMP自動追従が選択されていた
        String autoTracking = warA.get("240").toString();
        // AFBFの場合にTMP自動追従が選択されていた場合、注意メッセージを表示
        if (DeviceMode.AFBF.equals(selectedTreat.getDeviceMode()) && "0".equals(autoTracking)) {
          if (! msglist.contains("12000019")) {
            msglist.add("12000019");
          }
        }

        if (DeviceMode.HD.equals(selectedTreat.getDeviceMode()) || DeviceMode.ECUM.equals(selectedTreat.getDeviceMode())
          || DeviceMode.HDF.equals(selectedTreat.getDeviceMode()) || DeviceMode.HF.equals(selectedTreat.getDeviceMode())
          || DeviceMode.OHDF.equals(selectedTreat.getDeviceMode()) || DeviceMode.OHF.equals(selectedTreat.getDeviceMode())
          || DeviceMode.AFBF.equals(selectedTreat.getDeviceMode()) || DeviceMode.I_HDF.equals(selectedTreat.getDeviceMode())) {
          //179 血流量操作範囲上限
          if (indCondInfo.has("14")
            && ! jsonNodeIsNull(indCondInfo.getJSONObject("14").get("value").toString())
            && ! "null".equals(indCondInfo.getJSONObject("14").get("value").toString())
            && Double.parseDouble(indCondInfo.getJSONObject("14").get("value").toString()) >
            Double.parseDouble(opeTemperature.get("179").toString())) {
            //mod #10625 指示制約修正 zrx start
//            msglist.add("12000021");
            msglist.add("12000351");
            //mod #10625 指示制約修正 zrx end
          }
          //"182":透析液温度操作範囲上限   183:透析液温度操作範囲下限
          if (indCondInfo.has("18")
            && opeTemperature.has("182")
            && opeTemperature.has("183")
            && ! jsonNodeIsNull(indCondInfo.getJSONObject("18").get("value").toString())
            && ! jsonNodeIsNull(opeTemperature.get("182").toString())
            && ! jsonNodeIsNull(opeTemperature.get("183").toString())
            && (Double.parseDouble(indCondInfo.getJSONObject("18").get("value").toString()) >
            Double.parseDouble(opeTemperature.get("182").toString()) ||
            Double.parseDouble(indCondInfo.getJSONObject("18").get("value").toString()) <
              Double.parseDouble(opeTemperature.get("183").toString()))) {
            msglist.add("12000021");
          }
        }
        // del #12472 治療方法の変更で補液なし治療からオンライン補液あり治療に、「治療方法のみ」で変更するとpat_treatment_patternに欠損データが発生する。 関 start
        //        if (DeviceMode.AFBF.equals(selectedTreat.getDeviceMode())) {
        //          msglist.add("16010001");
        //          msglist.add("12000082");
        //        }
        // del #12472 治療方法の変更で補液なし治療からオンライン補液あり治療に、「治療方法のみ」で変更するとpat_treatment_patternに欠損データが発生する。 関 end
      }
    }

    OrdMainOnly ordMainDemo = new OrdMainOnly();

    // 治療方法セットの内容で全て変更、治療方法セットの内容で治療条件と医療材料を変更 フラグ
    int selectMethod = Integer.parseInt(bodyData.getTreat_method_flag());
    // 装置モード
    Integer deviceMode = selectedTreat.getDeviceMode();
    // 治療方法セット設定
    JSONArray treatCondSetting = null == selectedTreat.getTreatmentConditionSetting() ?
      new JSONArray() :
      new JSONArray(selectedTreat.getTreatmentConditionSetting());

    // 治療方法のみ変更 実績：治療状況0
    if (!isTreatSet && selectOrdNo == null) {
      if (0 == selectMethod) {
        ordNoList = null == ordNoList ? new ArrayList<>() : ordNoList;
        // 実績更新対象リストを取得
        List<OrdMain> rstOrdMain = ordMainList.stream().filter(item -> Integer.parseInt(item.getRstDialysisState()) != 0).distinct().collect(Collectors.toList());
        if(!rstOrdMain.isEmpty()){
          msglist.add("22020003");
        }
        JSONObject toAddTreatCond = new JSONObject();
        boolean isUpdateReplenishLiquid = false;
        for (int i = 1; i <= 38; i++) {
          String key = Integer.toString(i);
          Boolean isUse = this.checkTreatCondIsUse(treatCondSetting, key);
          if (isUse) {
            JSONObject newTreatJson = this.editIndJson(bodyData, user, updUser);
            if ("12".equals(key) && isUse) {
              newTreatJson.put("value", "0");
            }
            // add #12472 治療方法の変更で補液なし治療からオンライン補液あり治療に、「治療方法のみ」で変更するとpat_treatment_patternに欠損データが発生する。 関 start
            if ("19".equals(key) && isUse) {
              newTreatJson.put("medicine_type", JSONObject.NULL);
            }
            if ("20".equals(key) && isUse) {
              newTreatJson.put("value", "0.0");
            }
            if ("21".equals(key) && isUse) {
              newTreatJson.put("value", "1");
            }
            if ("22".equals(key) && isUse) {
              newTreatJson.put("value", "0");
            }
            if ("23".equals(key) && isUse) {
              newTreatJson.put("value", "36.0");
            }
            if ("24".equals(key) && isUse) {
              newTreatJson.put("value", "0.00");
            }
            // add #12472 治療方法の変更で補液なし治療からオンライン補液あり治療に、「治療方法のみ」で変更するとpat_treatment_patternに欠損データが発生する。 関 end
            toAddTreatCond.put(key, newTreatJson);
          }
        }

        ordMainDemo.setIndCondInfo(toAddTreatCond.toString());

        if (DeviceMode.HD_AND_REPLACEMENT.equals(selectedTreat.getDeviceMode()) ||
          DeviceMode.OHDF.equals(selectedTreat.getDeviceMode()) ||
          DeviceMode.OHF.equals(selectedTreat.getDeviceMode()) ||
          DeviceMode.I_HDF.equals(selectedTreat.getDeviceMode())) {
          isUpdateReplenishLiquid = true;
        }

        // 治療条件強制更新
        JSONObject updateTreatCond = new JSONObject();
        if (DeviceMode.AFBF.equals(selectedTreat.getDeviceMode()) || DeviceMode.I_HDF.equals(selectedTreat.getDeviceMode())) {
          JSONObject singleNeedleJson = this.editIndJson(bodyData, user, updUser);
          singleNeedleJson.put("value" , "0");
          List<String> needleKeyA = Arrays.asList("9", "10", "12");
          List<String> needleKeyR = Collections.singletonList("11");

          updateTreatCond.put("12", singleNeedleJson);
          ordMainDemo.setIndCondInfoForNeedleA(needleKeyA);
          ordMainDemo.setIndCondInfoForNeedleR(needleKeyR);
        } else {
          List<String> needleKeyA = Arrays.asList("9", "10", "11", "12");
          List<String> needleKeyR = Arrays.asList("9", "10", "11", "12");
          ordMainDemo.setIndCondInfoForNeedleA(needleKeyA);
          ordMainDemo.setIndCondInfoForNeedleR(needleKeyR);
        }
        // del #12472 治療方法の変更で補液なし治療からオンライン補液あり治療に、「治療方法のみ」で変更するとpat_treatment_patternに欠損データが発生する。 関 start
        //        if(DeviceMode.AFBF.equals(selectedTreat.getDeviceMode())) {
        //          JSONObject dialysesJson = this.editIndJson(bodyData, user, updUser);
        //          JSONObject ivJson = this.editIndJson(bodyData, user, updUser);
        //
        //          updateTreatCond.put("15", dialysesJson);
        //          updateTreatCond.put("19", ivJson);
        //        }
        // del #12472 治療方法の変更で補液なし治療からオンライン補液あり治療に、「治療方法のみ」で変更するとpat_treatment_patternに欠損データが発生する。 関 end

        ordMainDemo.setIndCondInfoForMerge(updateTreatCond.toString());

        // del #10154_#10183 zhao start
//        if(DeviceMode.I_HDF.equals(selectedTreat.getDeviceMode())) {
//          List<MstDialyzer> mstDialyzers = mstDialyzerDao.selectByFacillityCd(bodyData.getFacility_cd());
//          List<String> dialyzerCds = mstDialyzers.stream()
//            .filter(item -> "1".equals(item.getDialyzerType()))
//            .map(vo -> {
//              return String.valueOf(vo.getDialyzerCd());
//            }).collect(Collectors.toList());
//          ordMainDemo.setDialyzerTypeList(dialyzerCds);
//        }
        // del #10154_#10183 zhao end

        ordMainDemo.setUpDate(new Timestamp(System.currentTimeMillis()));

        // 装置設定強制変更
        JSONObject jsonIndDeviceSetInfo = new JSONObject();

        if (DeviceMode.HD.equals(selectedTreat.getDeviceMode())) {
          JSONObject jsonObjectA = new JSONObject();
          JSONObject jsonObjectDev = new JSONObject();
          JSONObject jsonObjectIhdf = new JSONObject();
          jsonObjectDev.put("A", jsonObjectA);
          jsonObjectIhdf.put("dev", jsonObjectDev);
          jsonIndDeviceSetInfo.put("ihdf", jsonObjectIhdf);
          jsonIndDeviceSetInfo.getJSONObject("ihdf")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("432", "0");
          // 指示者コード
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("ind_user_id", user.getUserId());
          // 指示者名_姓
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("upd_user_id", ntssUser.getUserId());
          // 更新者名_姓
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
        }
        if (DeviceMode.ECUM.equals(selectedTreat.getDeviceMode())) {
          JSONObject jsonObjectA = new JSONObject();
          JSONObject jsonObjectDev = new JSONObject();
          JSONObject jsonObjectIhdf = new JSONObject();
          jsonObjectDev.put("A", jsonObjectA);
          jsonObjectIhdf.put("dev", jsonObjectDev);
          jsonIndDeviceSetInfo.put("ihdf", jsonObjectIhdf);
          jsonIndDeviceSetInfo.getJSONObject("ihdf")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("432", "0");
          // 指示者コード
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("ind_user_id", user.getUserId());
          // 指示者名_姓
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("upd_user_id", ntssUser.getUserId());
          // 更新者名_姓
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
        }
        if (DeviceMode.HDF.equals(selectedTreat.getDeviceMode())) {
          JSONObject jsonObjectA = new JSONObject();
          JSONObject jsonObjectDev = new JSONObject();
          JSONObject jsonObjectUfr = new JSONObject();
          jsonObjectDev.put("A", jsonObjectA);
          jsonObjectUfr.put("dev", jsonObjectDev);
          jsonIndDeviceSetInfo.put("ufr", jsonObjectUfr);
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("291", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("292", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("293", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("294", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("295", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("296", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("297", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("298", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("299", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("300", "0");
          // 指示者コード
          jsonIndDeviceSetInfo.getJSONObject("ufr").put("ind_user_id", user.getUserId());
          // 指示者名_姓
          jsonIndDeviceSetInfo.getJSONObject("ufr").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          jsonIndDeviceSetInfo.getJSONObject("ufr").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          jsonIndDeviceSetInfo.getJSONObject("ufr").put("upd_user_id", ntssUser.getUserId());
          // 更新者名_姓
          jsonIndDeviceSetInfo.getJSONObject("ufr").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          jsonIndDeviceSetInfo.getJSONObject("ufr").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

          jsonObjectA = new JSONObject();
          jsonObjectDev = new JSONObject();
          JSONObject jsonObjectIhdf = new JSONObject();
          jsonObjectDev.put("A", jsonObjectA);
          jsonObjectIhdf.put("dev", jsonObjectDev);
          jsonIndDeviceSetInfo.put("ihdf", jsonObjectIhdf);
          jsonIndDeviceSetInfo.getJSONObject("ihdf")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("432", "0");
          // 指示者コード
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("ind_user_id", user.getUserId());
          // 指示者名_姓
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("upd_user_id", ntssUser.getUserId());
          // 更新者名_姓
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);


          jsonObjectA = new JSONObject();
          jsonObjectDev = new JSONObject();
          JSONObject jsonObjectdia = new JSONObject();
          jsonObjectDev.put("A", jsonObjectA);
          jsonObjectdia.put("dev", jsonObjectDev);
          jsonIndDeviceSetInfo.put("dia", jsonObjectdia);
          jsonIndDeviceSetInfo.getJSONObject("dia")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("282", "0");
          // 指示者コード
          jsonIndDeviceSetInfo.getJSONObject("dia").put("ind_user_id", user.getUserId());
          // 指示者名_姓
          jsonIndDeviceSetInfo.getJSONObject("dia").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          jsonIndDeviceSetInfo.getJSONObject("dia").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          jsonIndDeviceSetInfo.getJSONObject("dia").put("upd_user_id", ntssUser.getUserId());
          // 更新者名_姓
          jsonIndDeviceSetInfo.getJSONObject("dia").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          jsonIndDeviceSetInfo.getJSONObject("dia").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

        }
        if (DeviceMode.HF.equals(selectedTreat.getDeviceMode())) {
          JSONObject jsonObjectA = new JSONObject();
          JSONObject jsonObjectDev = new JSONObject();
          JSONObject jsonObjectUfr = new JSONObject();
          jsonObjectDev.put("A", jsonObjectA);
          jsonObjectUfr.put("dev", jsonObjectDev);
          jsonIndDeviceSetInfo.put("ufr", jsonObjectUfr);
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("291", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("292", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("293", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("294", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("295", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("296", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("297", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("298", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("299", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("300", "0");
          // 指示者コード
          jsonIndDeviceSetInfo.getJSONObject("ufr").put("ind_user_id", user.getUserId());
          // 指示者名_姓
          jsonIndDeviceSetInfo.getJSONObject("ufr").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          jsonIndDeviceSetInfo.getJSONObject("ufr").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          jsonIndDeviceSetInfo.getJSONObject("ufr").put("upd_user_id", ntssUser.getUserId());
          // 更新者名_姓
          jsonIndDeviceSetInfo.getJSONObject("ufr").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          jsonIndDeviceSetInfo.getJSONObject("ufr").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

          jsonObjectA = new JSONObject();
          jsonObjectDev = new JSONObject();
          JSONObject jsonObjectIhdf = new JSONObject();
          jsonObjectDev.put("A", jsonObjectA);
          jsonObjectIhdf.put("dev", jsonObjectDev);
          jsonIndDeviceSetInfo.put("ihdf", jsonObjectIhdf);
          jsonIndDeviceSetInfo.getJSONObject("ihdf")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("432", "0");
          // 指示者コード
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("ind_user_id", user.getUserId());
          // 指示者名_姓
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("upd_user_id", ntssUser.getUserId());
          // 更新者名_姓
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

          jsonObjectA = new JSONObject();
          jsonObjectDev = new JSONObject();
          JSONObject jsonObjectdia = new JSONObject();
          jsonObjectDev.put("A", jsonObjectA);
          jsonObjectdia.put("dev", jsonObjectDev);
          jsonIndDeviceSetInfo.put("dia", jsonObjectdia);
          jsonIndDeviceSetInfo.getJSONObject("dia")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("282", "0");
          // 指示者コード
          jsonIndDeviceSetInfo.getJSONObject("dia").put("ind_user_id", user.getUserId());
          // 指示者名_姓
          jsonIndDeviceSetInfo.getJSONObject("dia").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          jsonIndDeviceSetInfo.getJSONObject("dia").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          jsonIndDeviceSetInfo.getJSONObject("dia").put("upd_user_id", ntssUser.getUserId());
          // 更新者名_姓
          jsonIndDeviceSetInfo.getJSONObject("dia").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          jsonIndDeviceSetInfo.getJSONObject("dia").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

        }
        if (DeviceMode.AFBF.equals(selectedTreat.getDeviceMode())) {
          JSONObject jsonObjectA = new JSONObject();
          JSONObject jsonObjectDev = new JSONObject();
          JSONObject jsonObjectUfr = new JSONObject();
          jsonObjectDev.put("A", jsonObjectA);
          jsonObjectUfr.put("dev", jsonObjectDev);
          jsonIndDeviceSetInfo.put("ufr", jsonObjectUfr);
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("291", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("292", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("293", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("294", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("295", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("296", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("297", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("298", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("299", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("300", "0");
          // 指示者コード
          jsonIndDeviceSetInfo.getJSONObject("ufr").put("ind_user_id", user.getUserId());
          // 指示者名_姓
          jsonIndDeviceSetInfo.getJSONObject("ufr").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          jsonIndDeviceSetInfo.getJSONObject("ufr").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          jsonIndDeviceSetInfo.getJSONObject("ufr").put("upd_user_id", ntssUser.getUserId());
          // 更新者名_姓
          jsonIndDeviceSetInfo.getJSONObject("ufr").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          jsonIndDeviceSetInfo.getJSONObject("ufr").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

          jsonObjectA = new JSONObject();
          jsonObjectDev = new JSONObject();
          JSONObject jsonObjectIhdf = new JSONObject();
          jsonObjectDev.put("A", jsonObjectA);
          jsonObjectIhdf.put("dev", jsonObjectDev);
          jsonIndDeviceSetInfo.put("ihdf", jsonObjectIhdf);
          jsonIndDeviceSetInfo.getJSONObject("ihdf")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("432", "0");
          // 指示者コード
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("ind_user_id", user.getUserId());
          // 指示者名_姓
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("upd_user_id", ntssUser.getUserId());
          // 更新者名_姓
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

          jsonObjectA = new JSONObject();
          jsonObjectDev = new JSONObject();
          JSONObject jsonObjectdia = new JSONObject();
          jsonObjectDev.put("A", jsonObjectA);
          jsonObjectdia.put("dev", jsonObjectDev);
          jsonIndDeviceSetInfo.put("dia", jsonObjectdia);
          jsonIndDeviceSetInfo.getJSONObject("dia")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("282", "0");
          // 指示者コード
          jsonIndDeviceSetInfo.getJSONObject("dia").put("ind_user_id", user.getUserId());
          // 指示者名_姓
          jsonIndDeviceSetInfo.getJSONObject("dia").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          jsonIndDeviceSetInfo.getJSONObject("dia").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          jsonIndDeviceSetInfo.getJSONObject("dia").put("upd_user_id", ntssUser.getUserId());
          // 更新者名_姓
          jsonIndDeviceSetInfo.getJSONObject("dia").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          jsonIndDeviceSetInfo.getJSONObject("dia").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

          jsonObjectA = new JSONObject();
          jsonObjectDev = new JSONObject();
          JSONObject jsonObjectdc = new JSONObject();
          jsonObjectDev.put("A", jsonObjectA);
          jsonObjectdc.put("dev", jsonObjectDev);
          jsonIndDeviceSetInfo.put("dc", jsonObjectdc);
          jsonIndDeviceSetInfo.getJSONObject("dc")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("340", "0");
          // 指示者コード
          jsonIndDeviceSetInfo.getJSONObject("dc").put("ind_user_id", user.getUserId());
          // 指示者名_姓
          jsonIndDeviceSetInfo.getJSONObject("dc").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          jsonIndDeviceSetInfo.getJSONObject("dc").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          jsonIndDeviceSetInfo.getJSONObject("dc").put("upd_user_id", ntssUser.getUserId());
          // 更新者名_姓
          jsonIndDeviceSetInfo.getJSONObject("dc").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          jsonIndDeviceSetInfo.getJSONObject("dc").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);


          jsonObjectA = new JSONObject();
          jsonObjectDev = new JSONObject();
          JSONObject jsonObjectqbqd = new JSONObject();
          jsonObjectDev.put("A", jsonObjectA);
          jsonObjectqbqd.put("dev", jsonObjectDev);
          jsonIndDeviceSetInfo.put("qbqd", jsonObjectqbqd);
          jsonIndDeviceSetInfo.getJSONObject("qbqd")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("431", "0");
          jsonIndDeviceSetInfo.getJSONObject("qbqd")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("430", "0");
          // 指示者コード
          jsonIndDeviceSetInfo.getJSONObject("qbqd").put("ind_user_id", user.getUserId());
          // 指示者名_姓
          jsonIndDeviceSetInfo.getJSONObject("qbqd").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          jsonIndDeviceSetInfo.getJSONObject("qbqd").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          jsonIndDeviceSetInfo.getJSONObject("qbqd").put("upd_user_id", ntssUser.getUserId());
          // 更新者名_姓
          jsonIndDeviceSetInfo.getJSONObject("qbqd").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          jsonIndDeviceSetInfo.getJSONObject("qbqd").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

        }
        if (DeviceMode.OHDF.equals(selectedTreat.getDeviceMode())) {
          JSONObject jsonObjectA = new JSONObject();
          JSONObject jsonObjectDev = new JSONObject();
          JSONObject jsonObjectUfr = new JSONObject();
          jsonObjectDev.put("A", jsonObjectA);
          jsonObjectUfr.put("dev", jsonObjectDev);
          jsonIndDeviceSetInfo.put("ufr", jsonObjectUfr);
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("291", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("292", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("293", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("294", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("295", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("296", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("297", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("298", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("299", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("300", "0");
          // 指示者コード
          jsonIndDeviceSetInfo.getJSONObject("ufr").put("ind_user_id", user.getUserId());
          // 指示者名_姓
          jsonIndDeviceSetInfo.getJSONObject("ufr").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          jsonIndDeviceSetInfo.getJSONObject("ufr").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          jsonIndDeviceSetInfo.getJSONObject("ufr").put("upd_user_id", ntssUser.getUserId());
          // 更新者名_姓
          jsonIndDeviceSetInfo.getJSONObject("ufr").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          jsonIndDeviceSetInfo.getJSONObject("ufr").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

          jsonObjectA = new JSONObject();
          jsonObjectDev = new JSONObject();
          JSONObject jsonObjectIhdf = new JSONObject();
          jsonObjectDev.put("A", jsonObjectA);
          jsonObjectIhdf.put("dev", jsonObjectDev);
          jsonIndDeviceSetInfo.put("ihdf", jsonObjectIhdf);
          jsonIndDeviceSetInfo.getJSONObject("ihdf")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("432", "0");
          // 指示者コード
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("ind_user_id", user.getUserId());
          // 指示者名_姓
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("upd_user_id", ntssUser.getUserId());
          // 更新者名_姓
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

          jsonObjectA = new JSONObject();
          jsonObjectDev = new JSONObject();
          JSONObject jsonObjectdia = new JSONObject();
          jsonObjectDev.put("A", jsonObjectA);
          jsonObjectdia.put("dev", jsonObjectDev);
          jsonIndDeviceSetInfo.put("dia", jsonObjectdia);
          jsonIndDeviceSetInfo.getJSONObject("dia")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("282", "0");
          // 指示者コード
          jsonIndDeviceSetInfo.getJSONObject("dia").put("ind_user_id", user.getUserId());
          // 指示者名_姓
          jsonIndDeviceSetInfo.getJSONObject("dia").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          jsonIndDeviceSetInfo.getJSONObject("dia").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          jsonIndDeviceSetInfo.getJSONObject("dia").put("upd_user_id", ntssUser.getUserId());
          // 更新者名_姓
          jsonIndDeviceSetInfo.getJSONObject("dia").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          jsonIndDeviceSetInfo.getJSONObject("dia").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
        }
        if (DeviceMode.OHF.equals(selectedTreat.getDeviceMode())) {
          JSONObject jsonObjectA = new JSONObject();
          JSONObject jsonObjectDev = new JSONObject();
          JSONObject jsonObjectUfr = new JSONObject();
          jsonObjectDev.put("A", jsonObjectA);
          jsonObjectUfr.put("dev", jsonObjectDev);
          jsonIndDeviceSetInfo.put("ufr", jsonObjectUfr);
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("291", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("292", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("293", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("294", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("295", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("296", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("297", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("298", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("299", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("300", "0");
          // 指示者コード
          jsonIndDeviceSetInfo.getJSONObject("ufr").put("ind_user_id", user.getUserId());
          // 指示者名_姓
          jsonIndDeviceSetInfo.getJSONObject("ufr").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          jsonIndDeviceSetInfo.getJSONObject("ufr").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          jsonIndDeviceSetInfo.getJSONObject("ufr").put("upd_user_id", ntssUser.getUserId());
          // 更新者名_姓
          jsonIndDeviceSetInfo.getJSONObject("ufr").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          jsonIndDeviceSetInfo.getJSONObject("ufr").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

          jsonObjectA = new JSONObject();
          jsonObjectDev = new JSONObject();
          JSONObject jsonObjectIhdf = new JSONObject();
          jsonObjectDev.put("A", jsonObjectA);
          jsonObjectIhdf.put("dev", jsonObjectDev);
          jsonIndDeviceSetInfo.put("ihdf", jsonObjectIhdf);
          jsonIndDeviceSetInfo.getJSONObject("ihdf")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("432", "0");
          // 指示者コード
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("ind_user_id", user.getUserId());
          // 指示者名_姓
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("upd_user_id", ntssUser.getUserId());
          // 更新者名_姓
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);


          jsonObjectA = new JSONObject();
          jsonObjectDev = new JSONObject();
          JSONObject jsonObjectdia = new JSONObject();
          jsonObjectDev.put("A", jsonObjectA);
          jsonObjectdia.put("dev", jsonObjectDev);
          jsonIndDeviceSetInfo.put("dia", jsonObjectdia);
          jsonIndDeviceSetInfo.getJSONObject("dia")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("282", "0");
          // 指示者コード
          jsonIndDeviceSetInfo.getJSONObject("dia").put("ind_user_id", user.getUserId());
          // 指示者名_姓
          jsonIndDeviceSetInfo.getJSONObject("dia").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          jsonIndDeviceSetInfo.getJSONObject("dia").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          jsonIndDeviceSetInfo.getJSONObject("dia").put("upd_user_id", ntssUser.getUserId());
          // 更新者名_姓
          jsonIndDeviceSetInfo.getJSONObject("dia").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          jsonIndDeviceSetInfo.getJSONObject("dia").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
        }
        if (DeviceMode.PURIFICATION.equals(selectedTreat.getDeviceMode())) {
          JSONObject jsonObjectA = new JSONObject();
          JSONObject jsonObjectDev = new JSONObject();
          JSONObject jsonObjectUfr = new JSONObject();
          jsonObjectDev.put("A", jsonObjectA);
          jsonObjectUfr.put("dev", jsonObjectDev);
          jsonIndDeviceSetInfo.put("ufr", jsonObjectUfr);
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("290", "0");
          // 指示者コード
          jsonIndDeviceSetInfo.getJSONObject("ufr").put("ind_user_id", user.getUserId());
          // 指示者名_姓
          jsonIndDeviceSetInfo.getJSONObject("ufr").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          jsonIndDeviceSetInfo.getJSONObject("ufr").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          jsonIndDeviceSetInfo.getJSONObject("ufr").put("upd_user_id", ntssUser.getUserId());
          // 更新者名_姓
          jsonIndDeviceSetInfo.getJSONObject("ufr").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          jsonIndDeviceSetInfo.getJSONObject("ufr").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

          jsonObjectA = new JSONObject();
          jsonObjectDev = new JSONObject();
          JSONObject jsonObjectna = new JSONObject();
          jsonObjectDev.put("A", jsonObjectA);
          jsonObjectna.put("dev", jsonObjectDev);
          jsonIndDeviceSetInfo.put("na", jsonObjectna);
          jsonIndDeviceSetInfo.getJSONObject("na")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("315", "0");
          // 指示者コード
          jsonIndDeviceSetInfo.getJSONObject("na").put("ind_user_id", user.getUserId());
          // 指示者名_姓
          jsonIndDeviceSetInfo.getJSONObject("na").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          jsonIndDeviceSetInfo.getJSONObject("na").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          jsonIndDeviceSetInfo.getJSONObject("na").put("upd_user_id", ntssUser.getUserId());
          // 更新者名_姓
          jsonIndDeviceSetInfo.getJSONObject("na").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          jsonIndDeviceSetInfo.getJSONObject("na").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

          jsonObjectA = new JSONObject();
          jsonObjectDev = new JSONObject();
          JSONObject jsonObjectdc = new JSONObject();
          jsonObjectDev.put("A", jsonObjectA);
          jsonObjectdc.put("dev", jsonObjectDev);
          jsonIndDeviceSetInfo.put("dc", jsonObjectdc);
          jsonIndDeviceSetInfo.getJSONObject("dc")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("340", "0");
          // 指示者コード
          jsonIndDeviceSetInfo.getJSONObject("dc").put("ind_user_id", user.getUserId());
          // 指示者名_姓
          jsonIndDeviceSetInfo.getJSONObject("dc").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          jsonIndDeviceSetInfo.getJSONObject("dc").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          jsonIndDeviceSetInfo.getJSONObject("dc").put("upd_user_id", ntssUser.getUserId());
          // 更新者名_姓
          jsonIndDeviceSetInfo.getJSONObject("dc").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          jsonIndDeviceSetInfo.getJSONObject("dc").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

          jsonObjectA = new JSONObject();
          jsonObjectDev = new JSONObject();
          JSONObject jsonObjectqbqd = new JSONObject();
          jsonObjectDev.put("A", jsonObjectA);
          jsonObjectqbqd.put("dev", jsonObjectDev);
          jsonIndDeviceSetInfo.put("qbqd", jsonObjectqbqd);
          jsonIndDeviceSetInfo.getJSONObject("qbqd")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("430", "0");
          jsonIndDeviceSetInfo.getJSONObject("qbqd")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("431", "0");
          // 指示者コード
          jsonIndDeviceSetInfo.getJSONObject("qbqd").put("ind_user_id", user.getUserId());
          // 指示者名_姓
          jsonIndDeviceSetInfo.getJSONObject("qbqd").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          jsonIndDeviceSetInfo.getJSONObject("qbqd").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          jsonIndDeviceSetInfo.getJSONObject("qbqd").put("upd_user_id", ntssUser.getUserId());
          // 更新者名_姓
          jsonIndDeviceSetInfo.getJSONObject("qbqd").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          jsonIndDeviceSetInfo.getJSONObject("qbqd").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

          jsonObjectA = new JSONObject();
          jsonObjectDev = new JSONObject();
          JSONObject jsonObjectIhdf = new JSONObject();
          jsonObjectDev.put("A", jsonObjectA);
          jsonObjectIhdf.put("dev", jsonObjectDev);
          jsonIndDeviceSetInfo.put("ihdf", jsonObjectIhdf);
          jsonIndDeviceSetInfo.getJSONObject("ihdf")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("432", "0");
          // 指示者コード
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("ind_user_id", user.getUserId());
          // 指示者名_姓
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("upd_user_id", ntssUser.getUserId());
          // 更新者名_姓
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          jsonIndDeviceSetInfo.getJSONObject("ihdf").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

          jsonObjectA = new JSONObject();
          jsonObjectDev = new JSONObject();
          JSONObject jsonObjectbvufc = new JSONObject();
          jsonObjectDev.put("A", jsonObjectA);
          jsonObjectbvufc.put("dev", jsonObjectDev);
          jsonIndDeviceSetInfo.put("bvufc", jsonObjectbvufc);
          jsonIndDeviceSetInfo.getJSONObject("bvufc")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("196", "0");
          // 指示者コード
          jsonIndDeviceSetInfo.getJSONObject("bvufc").put("ind_user_id", user.getUserId());
          // 指示者名_姓
          jsonIndDeviceSetInfo.getJSONObject("bvufc").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          jsonIndDeviceSetInfo.getJSONObject("bvufc").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          jsonIndDeviceSetInfo.getJSONObject("bvufc").put("upd_user_id", ntssUser.getUserId());
          // 更新者名_姓
          jsonIndDeviceSetInfo.getJSONObject("bvufc").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          jsonIndDeviceSetInfo.getJSONObject("bvufc").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

          jsonObjectA = new JSONObject();
          jsonObjectDev = new JSONObject();
          JSONObject jsonObjectdia = new JSONObject();
          jsonObjectDev.put("A", jsonObjectA);
          jsonObjectdia.put("dev", jsonObjectDev);
          jsonIndDeviceSetInfo.put("dia", jsonObjectdia);
          jsonIndDeviceSetInfo.getJSONObject("dia")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("282", "0");
          // 指示者コード
          jsonIndDeviceSetInfo.getJSONObject("dia").put("ind_user_id", user.getUserId());
          // 指示者名_姓
          jsonIndDeviceSetInfo.getJSONObject("dia").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          jsonIndDeviceSetInfo.getJSONObject("dia").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          jsonIndDeviceSetInfo.getJSONObject("dia").put("upd_user_id", ntssUser.getUserId());
          // 更新者名_姓
          jsonIndDeviceSetInfo.getJSONObject("dia").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          jsonIndDeviceSetInfo.getJSONObject("dia").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
        }
        if (DeviceMode.I_HDF.equals(selectedTreat.getDeviceMode())) {
          JSONObject jsonObjectA = new JSONObject();
          JSONObject jsonObjectDev = new JSONObject();
          JSONObject jsonObjectUfr = new JSONObject();
          jsonObjectDev.put("A", jsonObjectA);
          jsonObjectUfr.put("dev", jsonObjectDev);
          jsonIndDeviceSetInfo.put("ufr", jsonObjectUfr);
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("290", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("291", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("292", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("293", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("294", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("295", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("296", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("297", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("298", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("299", "0");
          jsonIndDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("300", "0");
          // 指示者コード
          jsonIndDeviceSetInfo.getJSONObject("ufr").put("ind_user_id", user.getUserId());
          // 指示者名_姓
          jsonIndDeviceSetInfo.getJSONObject("ufr").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          jsonIndDeviceSetInfo.getJSONObject("ufr").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          jsonIndDeviceSetInfo.getJSONObject("ufr").put("upd_user_id", ntssUser.getUserId());
          // 更新者名_姓
          jsonIndDeviceSetInfo.getJSONObject("ufr").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          jsonIndDeviceSetInfo.getJSONObject("ufr").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

          jsonObjectA = new JSONObject();
          jsonObjectDev = new JSONObject();
          JSONObject jsonObjectqbqd = new JSONObject();
          jsonObjectDev.put("A", jsonObjectA);
          jsonObjectqbqd.put("dev", jsonObjectDev);
          jsonIndDeviceSetInfo.put("qbqd", jsonObjectqbqd);
          jsonIndDeviceSetInfo.getJSONObject("qbqd")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("430", "0");
          jsonIndDeviceSetInfo.getJSONObject("qbqd")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("431", "0");
          // 指示者コード
          jsonIndDeviceSetInfo.getJSONObject("qbqd").put("ind_user_id", user.getUserId());
          // 指示者名_姓
          jsonIndDeviceSetInfo.getJSONObject("qbqd").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          jsonIndDeviceSetInfo.getJSONObject("qbqd").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          jsonIndDeviceSetInfo.getJSONObject("qbqd").put("upd_user_id", ntssUser.getUserId());
          // 更新者名_姓
          jsonIndDeviceSetInfo.getJSONObject("qbqd").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          jsonIndDeviceSetInfo.getJSONObject("qbqd").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

          jsonObjectA = new JSONObject();
          jsonObjectDev = new JSONObject();
          JSONObject jsonObjectbvufc = new JSONObject();
          jsonObjectDev.put("A", jsonObjectA);
          jsonObjectbvufc.put("dev", jsonObjectDev);
          jsonIndDeviceSetInfo.put("bvufc", jsonObjectbvufc);
          jsonIndDeviceSetInfo.getJSONObject("bvufc")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("196", "0");
          // 指示者コード
          jsonIndDeviceSetInfo.getJSONObject("bvufc").put("ind_user_id", user.getUserId());
          // 指示者名_姓
          jsonIndDeviceSetInfo.getJSONObject("bvufc").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          jsonIndDeviceSetInfo.getJSONObject("bvufc").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          jsonIndDeviceSetInfo.getJSONObject("bvufc").put("upd_user_id", ntssUser.getUserId());
          // 更新者名_姓
          jsonIndDeviceSetInfo.getJSONObject("bvufc").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          jsonIndDeviceSetInfo.getJSONObject("bvufc").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

          jsonObjectA = new JSONObject();
          jsonObjectDev = new JSONObject();
          JSONObject jsonObjectdia = new JSONObject();
          jsonObjectDev.put("A", jsonObjectA);
          jsonObjectdia.put("dev", jsonObjectDev);
          jsonIndDeviceSetInfo.put("dia", jsonObjectdia);
          jsonIndDeviceSetInfo.getJSONObject("dia")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("282", "0");
          // 指示者コード
          jsonIndDeviceSetInfo.getJSONObject("dia").put("ind_user_id", user.getUserId());
          // 指示者名_姓
          jsonIndDeviceSetInfo.getJSONObject("dia").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          jsonIndDeviceSetInfo.getJSONObject("dia").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          jsonIndDeviceSetInfo.getJSONObject("dia").put("upd_user_id", ntssUser.getUserId());
          // 更新者名_姓
          jsonIndDeviceSetInfo.getJSONObject("dia").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          jsonIndDeviceSetInfo.getJSONObject("dia").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
        }
        ordMainDemo.setIndDeviceSetInfo(jsonIndDeviceSetInfo.toString());
        ordMainDemo.setUpDate(new Timestamp(System.currentTimeMillis()));

        selectHistoryUtils.insertMangoDbHistory(5, null, null, ordNoList, new ArrayList<>(), null, null,
          null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
          new ArrayList<>(), null, null);

        selectHistoryUtils.insertMangoDbHistory(6, null, null, ordNoList, new ArrayList<>(), null, isUpdateReplenishLiquid,
          null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
          new ArrayList<>(), null, null);

        selectHistoryUtils.insertMangoDbHistory(3, null, null, ordNoList, new ArrayList<>(), null, null,
          null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
          new ArrayList<>(), null, null);


        // 患者治療パターン更新
        if ("false".equals(bodyData.getIs_deadline())) {
          // mod #12472 治療方法の変更で補液なし治療からオンライン補液あり治療に、「治療方法のみ」で変更するとpat_treatment_patternに欠損データが発生する。 関 start
//          List<PatTreatmentPatternUtils.IND_ITEM> updateIndItemList = Arrays.asList(PatTreatmentPatternUtils.IND_ITEM.TREATMENT
//            , PatTreatmentPatternUtils.IND_ITEM.COND, PatTreatmentPatternUtils.IND_ITEM.DEVICE_SET_INFO);
          PatTreatmentPatternUtils.PatTreatmentPatternEditData editData = new PatTreatmentPatternUtils.PatTreatmentPatternEditData();
          editData.setIndTreatmentCd(editTreatmentCd);
          editData.setDeviceMode(bodyData.getDevice_mode());
          editData.setIndUserId(bodyData.getInd_user_id().longValue());

//          int patPatternCount = patTreatmentPatternUtils.updatePatTreatmentPatternIndItemForTreat(
//            Long.parseLong(bodyData.getPat_id()),
//            bodyData.getFacility_cd(),
//            this.getValueList(targetTreatmentCdList),
//            this.getLongList(bodyData.getInd_kur_cd()),
//            IndicationUtils.getWeekPattern(bodyData.getWeek_pattern()),
//            updateIndItemList,
//            Timestamp.valueOf(LocalDateTime.now()),
//            editData
//          );

          Map<String, String> otherConditions = new HashMap<>();
          otherConditions.put("editTreatmentCd", editTreatmentCd.toString());
          otherConditions.put("updUserId", updUser.getUserId().toString());
          otherConditions.put("updUserLastName", updUser.getUserLastName());
          otherConditions.put("updUserFirstName", updUser.getUserFirstName());
          otherConditions.put("indUserId", user.getUserId().toString());
          otherConditions.put("indUserLastName", user.getUserLastName());
          otherConditions.put("indUserFirstName", user.getUserFirstName());

          PatTreatmentPatternKey key = new PatTreatmentPatternKey(
            Long.parseLong(bodyData.getPat_id()),
            bodyData.getFacility_cd(),
            this.getValueList(targetTreatmentCdList),
            this.getLongList(bodyData.getInd_kur_cd()),
            IndicationUtils.getWeekPattern(bodyData.getWeek_pattern()),
            null,
            otherConditions
          );
          JSONObject jsonObject = new JSONObject();

          PatTreatmentPatternJsonbField field = new PatTreatmentPatternJsonbField(
            PatTreatmentPatternUpdateModeEnum.MERGE,
            jsonObject.toString());
          PatTreatmentPatternUpsert upsert = new PatTreatmentPatternUpsert(key);
          upsert.addJsonbUpdate(PatTreatmentPatternFieldEnum.TREATMENT_METHOD_ONLY, field);
          PatTreatmentPatternDelta delta = new PatTreatmentPatternDelta();
          delta.getUpdates().add(upsert);

          // パタン共通を呼びだす
          Map<jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.service.PatTreatmentPatternService.RESULT_TYPE, List<PatTreatmentPattern>> responseMap =
            patTreatmentActualService.applyPatTreatmentPatterns(delta);
          // mod #12472 治療方法の変更で補液なし治療からオンライン補液あり治療に、「治療方法のみ」で変更するとpat_treatment_patternに欠損データが発生する。 関 end
        }
      }
    } else if (isTreatSet){
      // シングルニードル取得
      String singleNeedle = "";

      // 指示：治療条件情報
      String buf = listMstTreatSet.get(0).getIndCondInfo();
      JSONObject setCond = new JSONObject(buf);
      JSONArray keys = setCond.names();
      JSONObject condInfoJson = new JSONObject();
      for (int i = 0; i < keys.length(); i++) {
        String key = keys.getString(i);
        JSONObject obj = setCond.getJSONObject(key);
        Object value = null;
        Integer medicineType = null;
        if (null != obj) {
          if (! obj.isNull("value")) {
            value = obj.get("value");
          }
          if (! obj.isNull("medicine_type")) {
            medicineType = Integer.parseInt(obj.get("medicine_type").toString());
          }
        }
        if ("2".equals(key)) {
          if (null != obj && ! obj.isEmpty() && ! obj.isNull("value")) {
            ordMainDemo.setIndVaCd(obj.getInt("value"));
          }
        }
        if ("12".equals(key)) {
          singleNeedle = (null == value) ? "" : value.toString();
        }
        // 治療方法の治療条件設定で「未使用」の場合、登録しない
        if (! this.checkTreatCondIsUse(treatCondSetting, key)) {
          continue;
        }
        JSONObject bufJson = new JSONObject();
        // 設定値
        bufJson.put("value", (null == value) ? JSONObject.NULL : value);
        if ("15".equals(key) || "19".equals(key) || "25".equals(key)) {
          // 薬剤区分
          bufJson.put("medicine_type", (null == medicineType) ? JSONObject.NULL : medicineType);
        }
        // 指示者コード
        bufJson.put("ind_user_id", bodyData.getInd_user_id());
        // 指示者名_姓
        bufJson.put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
        // 指示者名_名
        bufJson.put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
        // 更新者コード
        bufJson.put("upd_user_id", bodyData.getUpd_user_id());
        // 更新者名_姓
        bufJson.put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
        // 更新者名_名
        bufJson.put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
        // 登録区分
        bufJson.put("input_class", 1);
        // 編集可否フラグ
        bufJson.put("is_editable", "1");
        // 連携オーダ番号
        bufJson.put("cop_order_no", JSONObject.NULL);
        // 実績：治療状況1-6
        if (selectOrdNo != null && !"0".equals(ordMainList.get(0).getRstDialysisState())) {
          // 翻訳1
          bufJson.put("value_name_1", JSONObject.NULL);
          // 単位
          bufJson.put("unit", JSONObject.NULL);
        }
        if ("3".equals(key)) {
          bufJson.put("value", "-1");
        }
        condInfoJson.put(key, bufJson);
      }
      JSONObject deviceSetInfoObject = (deviceSetInfo == null || deviceSetInfo.isEmpty()) ?
        new JSONObject() :
        new JSONObject(deviceSetInfo);
      // del 10150_9664 by kangjie 20240912 start
//      // HDF
//      if (DeviceMode.HDF.equals(deviceMode)) {
//        if (! JSONObject.NULL.equals(condInfoJson.getJSONObject("20").get("value"))) {
//          String amountStr = condInfoJson.getJSONObject(
//            TreatmentItemsDef.T_I_IV_AMOUNT.getItemCode()).get("value").toString();
//          String delayTimeStr = deviceSetInfoObject.getJSONObject("ope").getJSONObject("dev")
//            .getJSONObject("A").get("398").toString();
//          String treatTimeStr = condInfoJson.getJSONObject(
//            TreatmentItemsDef.T_I_START_DATE.getItemCode()).get("value").toString();
//
//          amountStr = org.apache.commons.lang3.StringUtils.isNotEmpty(amountStr)
//            && (TreatmentItemsDef.isFloat(amountStr) || TreatmentItemsDef.isInteger(amountStr))
//            ? amountStr : TreatmentItemsDef.T_I_IV_AMOUNT.getDefaultValue();
//          delayTimeStr = org.apache.commons.lang3.StringUtils.isNotEmpty(delayTimeStr)
//            && (TreatmentItemsDef.isFloat(delayTimeStr) || TreatmentItemsDef.isInteger(delayTimeStr))
//            ? delayTimeStr : "0";
//          treatTimeStr = org.apache.commons.lang3.StringUtils.isNotEmpty(treatTimeStr)
//            && (TreatmentItemsDef.isFloat(treatTimeStr) || TreatmentItemsDef.isInteger(treatTimeStr))
//            ? treatTimeStr : TreatmentItemsDef.T_I_START_DATE.getDefaultValue();
//
//          BigDecimal amount = new BigDecimal(amountStr);
//          BigDecimal delayTime = new BigDecimal(delayTimeStr);
//          BigDecimal treatTime = new BigDecimal(treatTimeStr);
//
//          if (treatTime.compareTo(delayTime) > 0) {
//            BigDecimal speed = amount.divide(
//              treatTime.subtract(delayTime).divide(new BigDecimal("60")
//                , 3, RoundingMode.HALF_UP), 3, RoundingMode.HALF_UP);
//            JSONObject jsonObject1 = condInfoJson.getJSONObject(TreatmentItemsDef.T_I_IV_AMOUNT.getItemCode())
//              .put("value", TreatmentItemsDef.T_I_IV_AMOUNT.getFormattedValue(amount));
//            JSONObject jsonObject2 = condInfoJson.getJSONObject(TreatmentItemsDef.T_I_IV_FLOW_RATE.getItemCode())
//              .put("value", TreatmentItemsDef.T_I_IV_FLOW_RATE.getFormattedValue(speed));
//            condInfoJson.put("20", jsonObject1);
//            condInfoJson.put("24", jsonObject2);
//          }
//        }
//      }
//      // HF
//      if (DeviceMode.HF.equals(deviceMode)) {
//        if (! JSONObject.NULL.equals(condInfoJson.getJSONObject("20").get("value"))) {
//          String amountStr = condInfoJson.getJSONObject(
//            TreatmentItemsDef.T_I_IV_AMOUNT.getItemCode()).get("value").toString();
//          String delayTimeStr = deviceSetInfoObject.getJSONObject("ope").getJSONObject("dev")
//            .getJSONObject("A").get("398").toString();
//          String treatTimeStr = condInfoJson.getJSONObject(
//            TreatmentItemsDef.T_I_START_DATE.getItemCode()).get("value").toString();
//
//          amountStr = org.apache.commons.lang3.StringUtils.isNotEmpty(amountStr)
//            && (TreatmentItemsDef.isFloat(amountStr) || TreatmentItemsDef.isInteger(amountStr))
//            ? amountStr : TreatmentItemsDef.T_I_IV_AMOUNT.getDefaultValue();
//          delayTimeStr = org.apache.commons.lang3.StringUtils.isNotEmpty(delayTimeStr)
//            && (TreatmentItemsDef.isFloat(delayTimeStr) || TreatmentItemsDef.isInteger(delayTimeStr))
//            ? delayTimeStr : "0";
//          treatTimeStr = org.apache.commons.lang3.StringUtils.isNotEmpty(treatTimeStr)
//            && (TreatmentItemsDef.isFloat(treatTimeStr) || TreatmentItemsDef.isInteger(treatTimeStr))
//            ? treatTimeStr : TreatmentItemsDef.T_I_START_DATE.getDefaultValue();
//
//          BigDecimal amount = new BigDecimal(amountStr);
//          BigDecimal delayTime = new BigDecimal(delayTimeStr);
//          BigDecimal treatTime = new BigDecimal(treatTimeStr);
//
//          if (treatTime.compareTo(delayTime) > 0) {
//            BigDecimal speed = amount.divide(
//              treatTime.subtract(delayTime).divide(new BigDecimal("60")
//                , 3, RoundingMode.HALF_UP), 3, RoundingMode.HALF_UP);
//            JSONObject jsonObject1 = condInfoJson.getJSONObject(TreatmentItemsDef.T_I_IV_AMOUNT.getItemCode())
//              .put("value", TreatmentItemsDef.T_I_IV_AMOUNT.getFormattedValue(amount));
//            JSONObject jsonObject2 = condInfoJson.getJSONObject(TreatmentItemsDef.T_I_IV_FLOW_RATE.getItemCode())
//              .put("value", TreatmentItemsDef.T_I_IV_FLOW_RATE.getFormattedValue(speed));
//            condInfoJson.put("20", jsonObject1);
//            condInfoJson.put("24", jsonObject2);
//          }
//        }
//      }
//      // AFBF
//      if (DeviceMode.AFBF.equals(deviceMode)) {
//        if (condInfoJson.has("20") && ! JSONObject.NULL.equals(condInfoJson.getJSONObject("20").get("value"))) {
//          String amountStr = condInfoJson.getJSONObject(
//            TreatmentItemsDef.T_I_IV_AMOUNT.getItemCode()).get("value").toString();
//          String delayTimeStr = deviceSetInfoObject.getJSONObject("ope").getJSONObject("dev")
//            .getJSONObject("A").get("398").toString();
//          String treatTimeStr = condInfoJson.getJSONObject(
//            TreatmentItemsDef.T_I_START_DATE.getItemCode()).get("value").toString();
//
//          amountStr = org.apache.commons.lang3.StringUtils.isNotEmpty(amountStr)
//            && (TreatmentItemsDef.isFloat(amountStr) || TreatmentItemsDef.isInteger(amountStr))
//            ? amountStr : TreatmentItemsDef.T_I_IV_AMOUNT.getDefaultValue();
//          delayTimeStr = org.apache.commons.lang3.StringUtils.isNotEmpty(delayTimeStr)
//            && (TreatmentItemsDef.isFloat(delayTimeStr) || TreatmentItemsDef.isInteger(delayTimeStr))
//            ? delayTimeStr : "0";
//          treatTimeStr = org.apache.commons.lang3.StringUtils.isNotEmpty(treatTimeStr)
//            && (TreatmentItemsDef.isFloat(treatTimeStr) || TreatmentItemsDef.isInteger(treatTimeStr))
//            ? treatTimeStr : TreatmentItemsDef.T_I_START_DATE.getDefaultValue();
//
//          BigDecimal amount = new BigDecimal(amountStr);
//          BigDecimal delayTime = new BigDecimal(delayTimeStr);
//          BigDecimal treatTime = new BigDecimal(treatTimeStr);
//
//          if (treatTime.compareTo(delayTime) > 0) {
//            BigDecimal speed = amount.divide(
//              treatTime.subtract(delayTime).divide(new BigDecimal("60")
//                , 3, RoundingMode.HALF_UP), 3, RoundingMode.HALF_UP);
//            JSONObject jsonObject1 = condInfoJson.getJSONObject(TreatmentItemsDef.T_I_IV_AMOUNT.getItemCode())
//              .put("value", TreatmentItemsDef.T_I_IV_AMOUNT.getFormattedValue(amount));
//            JSONObject jsonObject2 = condInfoJson.getJSONObject(TreatmentItemsDef.T_I_IV_FLOW_RATE.getItemCode())
//              .put("value", TreatmentItemsDef.T_I_IV_FLOW_RATE.getFormattedValue(speed));
//            condInfoJson.put("20", jsonObject1);
//            condInfoJson.put("24", jsonObject2);
//          }
//        }
//      }
//      // OHDF
//      if (DeviceMode.OHDF.equals(deviceMode)) {
//        //補液計算優先項目
//        String liquidCalPriority = deviceSetInfoObject.getJSONObject("ope").getJSONObject("dev")
//          .getJSONObject("A").get("389").toString();
//        // 0  補液速度算出
//        // 1  補液量設定算出
//        // 2  補液比率
//        // 3  濾過率から算出
//
//        BigDecimal sixtyConst = new BigDecimal("60");
//        BigDecimal hundredConst = new BigDecimal("100");
//        BigDecimal thousandConst = new BigDecimal("1000");
//
//        //補液速度算出
//        if ("0".equals(liquidCalPriority)) {
//          if (! JSONObject.NULL.equals(condInfoJson.getJSONObject("20").get("value"))) {
//            String amountStr = condInfoJson.getJSONObject(
//              TreatmentItemsDef.T_I_IV_AMOUNT.getItemCode()).get("value").toString();
//            String delayTimeStr = deviceSetInfoObject.getJSONObject("ope").getJSONObject("dev")
//              .getJSONObject("A").get("398").toString();
//            String treatTimeStr = condInfoJson.getJSONObject(
//              TreatmentItemsDef.T_I_START_DATE.getItemCode()).get("value").toString();
//
//            amountStr = org.apache.commons.lang3.StringUtils.isNotEmpty(amountStr)
//              && (TreatmentItemsDef.isFloat(amountStr) || TreatmentItemsDef.isInteger(amountStr))
//              ? amountStr : TreatmentItemsDef.T_I_IV_AMOUNT.getDefaultValue();
//            delayTimeStr = org.apache.commons.lang3.StringUtils.isNotEmpty(delayTimeStr)
//              && (TreatmentItemsDef.isFloat(delayTimeStr) || TreatmentItemsDef.isInteger(delayTimeStr))
//              ? delayTimeStr : "0";
//            treatTimeStr = org.apache.commons.lang3.StringUtils.isNotEmpty(treatTimeStr)
//              && (TreatmentItemsDef.isFloat(treatTimeStr) || TreatmentItemsDef.isInteger(treatTimeStr))
//              ? treatTimeStr : TreatmentItemsDef.T_I_START_DATE.getDefaultValue();
//
//            BigDecimal amount = new BigDecimal(amountStr);
//            BigDecimal delayTime = new BigDecimal(delayTimeStr);
//            BigDecimal treatTime = new BigDecimal(treatTimeStr);
//
//            if (treatTime.compareTo(delayTime) > 0) {
//              BigDecimal speed = amount.divide(
//                treatTime.subtract(delayTime).divide(sixtyConst, 3, RoundingMode.HALF_UP), 3
//                , RoundingMode.HALF_UP);
//              JSONObject jsonObject1 = condInfoJson.getJSONObject(TreatmentItemsDef.T_I_IV_AMOUNT.getItemCode())
//                .put("value", TreatmentItemsDef.T_I_IV_AMOUNT.getFormattedValue(amount));
//              JSONObject jsonObject2 = condInfoJson.getJSONObject(TreatmentItemsDef.T_I_IV_FLOW_RATE.getItemCode())
//                .put("value", TreatmentItemsDef.T_I_IV_FLOW_RATE.getFormattedValue(speed));
//              condInfoJson.put("20", jsonObject1);
//              condInfoJson.put("24", jsonObject2);
//            }
//          }
//          // 1 補液量設定算出
//        } else if ("1".equals(liquidCalPriority)) {
//          if (! JSONObject.NULL.equals(condInfoJson.getJSONObject("24").get("value"))) {
//            String speedStr = condInfoJson.getJSONObject(
//              TreatmentItemsDef.T_I_IV_FLOW_RATE.getItemCode()).get("value").toString();
//            String delayTimeStr = deviceSetInfoObject.getJSONObject("ope").getJSONObject("dev")
//              .getJSONObject("A").get("398").toString();
//            String treatTimeStr = condInfoJson.getJSONObject(
//              TreatmentItemsDef.T_I_START_DATE.getItemCode()).get("value").toString();
//
//            speedStr = org.apache.commons.lang3.StringUtils.isNotEmpty(speedStr)
//              && (TreatmentItemsDef.isFloat(speedStr) || TreatmentItemsDef.isInteger(speedStr))
//              ? speedStr : TreatmentItemsDef.T_I_IV_FLOW_RATE.getDefaultValue();
//            delayTimeStr = org.apache.commons.lang3.StringUtils.isNotEmpty(delayTimeStr)
//              && (TreatmentItemsDef.isFloat(delayTimeStr) || TreatmentItemsDef.isInteger(delayTimeStr))
//              ? delayTimeStr : "0";
//            treatTimeStr = org.apache.commons.lang3.StringUtils.isNotEmpty(treatTimeStr)
//              && (TreatmentItemsDef.isFloat(treatTimeStr) || TreatmentItemsDef.isInteger(treatTimeStr))
//              ? treatTimeStr : TreatmentItemsDef.T_I_START_DATE.getDefaultValue();
//
//            BigDecimal speed = new BigDecimal(speedStr);
//            BigDecimal delayTime = new BigDecimal(delayTimeStr);
//            BigDecimal treatTime = new BigDecimal(treatTimeStr);
//
//            if (treatTime.compareTo(delayTime) > 0) {
//              BigDecimal amount = speed.multiply(treatTime.subtract(delayTime).divide(sixtyConst, 3
//                , RoundingMode.HALF_UP));
//              JSONObject jsonObject1 = condInfoJson.getJSONObject(TreatmentItemsDef.T_I_IV_AMOUNT.getItemCode())
//                .put("value", TreatmentItemsDef.T_I_IV_AMOUNT.getFormattedValue(amount));
//              JSONObject jsonObject2 = condInfoJson.getJSONObject(TreatmentItemsDef.T_I_IV_FLOW_RATE.getItemCode())
//                .put("value", TreatmentItemsDef.T_I_IV_FLOW_RATE.getFormattedValue(speed));
//              condInfoJson.put("20", jsonObject1);
//              condInfoJson.put("24", jsonObject2);
//            }
//          }
//          // 2 補液比率
//        } else if ("2".equals(liquidCalPriority)) {
//          if (! JSONObject.NULL.equals(condInfoJson.getJSONObject("21").get("value"))) {
//            String beforeOrAfter = condInfoJson.getJSONObject("21").get("value").toString();
//            String rateStr;
//            // 補液選択
//            if ("1".equals(beforeOrAfter)) { // 前補液
//              rateStr = String.valueOf(deviceSetInfoObject.getJSONObject("ope").getJSONObject("dev")
//                .getJSONObject("A").get("379"));
//            } else {
//              rateStr = String.valueOf(deviceSetInfoObject.getJSONObject("ope").getJSONObject("dev")
//                .getJSONObject("B").get("39"));
//            }
//            String bloodFlowValueStr = condInfoJson.getJSONObject("14").has("value")
//              ? condInfoJson.getJSONObject("14").get("value").toString() : "0";
//
//            BigDecimal rate = org.apache.commons.lang3.StringUtils.isNotEmpty(rateStr)
//              && (TreatmentItemsDef.isFloat(rateStr) || TreatmentItemsDef.isInteger(rateStr))
//              ? new BigDecimal(rateStr) : BigDecimal.ZERO;
//            BigDecimal bloodFlowValue = org.apache.commons.lang3.StringUtils.isNotEmpty(bloodFlowValueStr)
//              && (TreatmentItemsDef.isFloat(bloodFlowValueStr) || TreatmentItemsDef.isInteger(bloodFlowValueStr))
//              ? new BigDecimal(bloodFlowValueStr) : BigDecimal.ZERO;
//            BigDecimal speed = bloodFlowValue.multiply(rate.divide(hundredConst, 3, RoundingMode.HALF_UP))
//              .multiply(hundredConst).divide(thousandConst, 3, RoundingMode.HALF_UP);
//            String delayTimeStr = String.valueOf(deviceSetInfoObject.getJSONObject("ope").getJSONObject("dev")
//              .getJSONObject("A").get("398"));
//            String treatTimeStr = condInfoJson.getJSONObject("1").get("value").toString();
//            BigDecimal delayTime = org.apache.commons.lang3.StringUtils.isNotEmpty(delayTimeStr)
//              && (TreatmentItemsDef.isFloat(delayTimeStr) || TreatmentItemsDef.isInteger(delayTimeStr))
//              ? new BigDecimal(delayTimeStr) : BigDecimal.ZERO;
//            BigDecimal treatTime = org.apache.commons.lang3.StringUtils.isNotEmpty(treatTimeStr)
//              && (TreatmentItemsDef.isFloat(treatTimeStr) || TreatmentItemsDef.isInteger(treatTimeStr))
//              ? new BigDecimal(treatTimeStr) : BigDecimal.ZERO;
//
//            if (treatTime.compareTo(delayTime) > 0) {
//              BigDecimal amount = speed.multiply(treatTime.subtract(delayTime)).divide(sixtyConst, 3, RoundingMode.HALF_UP);
//              JSONObject jsonObject1 = condInfoJson.getJSONObject(TreatmentItemsDef.T_I_IV_AMOUNT.getItemCode())
//                .put("value", TreatmentItemsDef.T_I_IV_AMOUNT.getFormattedValue(amount));
//              JSONObject jsonObject2 = condInfoJson.getJSONObject(TreatmentItemsDef.T_I_IV_FLOW_RATE.getItemCode())
//                .put("value", TreatmentItemsDef.T_I_IV_FLOW_RATE.getFormattedValue(speed));
//              condInfoJson.put("20", jsonObject1);
//              condInfoJson.put("24", jsonObject2);
//            }
//          }
//          // 3 濾過率から算出
//        } else if ("3".equals(liquidCalPriority)) {
//          JSONObject jsonObject1 = condInfoJson.getJSONObject("20").put("value", "-1");
//          JSONObject jsonObject2 = condInfoJson.getJSONObject("24").put("value", "-1");
//          condInfoJson.put("20", jsonObject1);
//          condInfoJson.put("24", jsonObject2);
//        }
//      }
//      // OHF
//      if (DeviceMode.OHF.equals(deviceMode)) {
//        // 補液計算優先項目
//        String liquidCalPriority = deviceSetInfoObject.getJSONObject("ope").getJSONObject("dev")
//          .getJSONObject("A").get("389").toString();
//        // 0 補液速度算出
//        // 1 補液量設定算出
//        // 2 補液比率
//        // 3 濾過率から算出
//
//        BigDecimal sixtyConst = new BigDecimal("60");
//        BigDecimal hundredConst = new BigDecimal("100");
//        BigDecimal thousandConst = new BigDecimal("1000");
//
//        // 補液速度算出
//        if ("0".equals(liquidCalPriority)) {
//          if (! JSONObject.NULL.equals(condInfoJson.getJSONObject("20").get("value"))) {
//            String amountStr = condInfoJson.getJSONObject(
//              TreatmentItemsDef.T_I_IV_AMOUNT.getItemCode()).get("value").toString();
//            String delayTimeStr = deviceSetInfoObject.getJSONObject("ope").getJSONObject("dev")
//              .getJSONObject("A").get("398").toString();
//            String treatTimeStr = condInfoJson.getJSONObject(
//              TreatmentItemsDef.T_I_START_DATE.getItemCode()).get("value").toString();
//
//            amountStr = org.apache.commons.lang3.StringUtils.isNotEmpty(amountStr)
//              && (TreatmentItemsDef.isFloat(amountStr) || TreatmentItemsDef.isInteger(amountStr))
//              ? amountStr : TreatmentItemsDef.T_I_IV_AMOUNT.getDefaultValue();
//            delayTimeStr = org.apache.commons.lang3.StringUtils.isNotEmpty(delayTimeStr)
//              && (TreatmentItemsDef.isFloat(delayTimeStr) || TreatmentItemsDef.isInteger(delayTimeStr))
//              ? delayTimeStr : "0";
//            treatTimeStr = org.apache.commons.lang3.StringUtils.isNotEmpty(treatTimeStr)
//              && (TreatmentItemsDef.isFloat(treatTimeStr) || TreatmentItemsDef.isInteger(treatTimeStr))
//              ? treatTimeStr : TreatmentItemsDef.T_I_START_DATE.getDefaultValue();
//
//            BigDecimal amount = new BigDecimal(amountStr);
//            BigDecimal delayTime = new BigDecimal(delayTimeStr);
//            BigDecimal treatTime = new BigDecimal(treatTimeStr);
//
//            if (treatTime.compareTo(delayTime) > 0) {
//              BigDecimal speed = amount.divide(
//                treatTime.subtract(delayTime).divide(sixtyConst, 3, RoundingMode.HALF_UP), 3
//                , RoundingMode.HALF_UP);
//              JSONObject jsonObject1 = condInfoJson.getJSONObject(TreatmentItemsDef.T_I_IV_AMOUNT.getItemCode())
//                .put("value", TreatmentItemsDef.T_I_IV_AMOUNT.getFormattedValue(amount));
//              JSONObject jsonObject2 = condInfoJson.getJSONObject(TreatmentItemsDef.T_I_IV_FLOW_RATE.getItemCode())
//                .put("value", TreatmentItemsDef.T_I_IV_FLOW_RATE.getFormattedValue(speed));
//              condInfoJson.put("20", jsonObject1);
//              condInfoJson.put("24", jsonObject2);
//            }
//          }
//          // 1 補液量設定算出
//        } else if ("1".equals(liquidCalPriority)) {
//          if (! JSONObject.NULL.equals(condInfoJson.getJSONObject("24").get("value"))) {
//            String speedStr = condInfoJson.getJSONObject(
//              TreatmentItemsDef.T_I_IV_FLOW_RATE.getItemCode()).get("value").toString();
//            String delayTimeStr = deviceSetInfoObject.getJSONObject("ope").getJSONObject("dev")
//              .getJSONObject("A").get("398").toString();
//            String treatTimeStr = condInfoJson.getJSONObject(
//              TreatmentItemsDef.T_I_START_DATE.getItemCode()).get("value").toString();
//
//            speedStr = org.apache.commons.lang3.StringUtils.isNotEmpty(speedStr)
//              && (TreatmentItemsDef.isFloat(speedStr) || TreatmentItemsDef.isInteger(speedStr))
//              ? speedStr : TreatmentItemsDef.T_I_IV_FLOW_RATE.getDefaultValue();
//            delayTimeStr = org.apache.commons.lang3.StringUtils.isNotEmpty(delayTimeStr)
//              && (TreatmentItemsDef.isFloat(delayTimeStr) || TreatmentItemsDef.isInteger(delayTimeStr))
//              ? delayTimeStr : "0";
//            treatTimeStr = org.apache.commons.lang3.StringUtils.isNotEmpty(treatTimeStr)
//              && (TreatmentItemsDef.isFloat(treatTimeStr) || TreatmentItemsDef.isInteger(treatTimeStr))
//              ? treatTimeStr : TreatmentItemsDef.T_I_START_DATE.getDefaultValue();
//
//            BigDecimal speed = new BigDecimal(speedStr);
//            BigDecimal delayTime = new BigDecimal(delayTimeStr);
//            BigDecimal treatTime = new BigDecimal(treatTimeStr);
//
//            if (treatTime.compareTo(delayTime) > 0) {
//              BigDecimal amount = speed.multiply(treatTime.subtract(delayTime).divide(sixtyConst, 3
//                , RoundingMode.HALF_UP));
//              JSONObject jsonObject1 = condInfoJson.getJSONObject(TreatmentItemsDef.T_I_IV_AMOUNT.getItemCode())
//                .put("value", TreatmentItemsDef.T_I_IV_AMOUNT.getFormattedValue(amount));
//              JSONObject jsonObject2 = condInfoJson.getJSONObject(TreatmentItemsDef.T_I_IV_FLOW_RATE.getItemCode())
//                .put("value", TreatmentItemsDef.T_I_IV_FLOW_RATE.getFormattedValue(speed));
//              condInfoJson.put("20", jsonObject1);
//              condInfoJson.put("24", jsonObject2);
//            }
//          }
//          // 2 補液比率
//        } else if ("2".equals(liquidCalPriority)) {
//          if (! JSONObject.NULL.equals(condInfoJson.getJSONObject("21").get("value"))) {
//            String beforeOrAfter = condInfoJson.getJSONObject("21").get("value").toString();
//            String rateStr;
//            // 補液選択
//            if ("1".equals(beforeOrAfter)) { // 前補液
//              rateStr = String.valueOf(deviceSetInfoObject.getJSONObject("ope").getJSONObject("dev")
//                .getJSONObject("A").get("379"));
//            } else {
//              rateStr = String.valueOf(deviceSetInfoObject.getJSONObject("ope").getJSONObject("dev")
//                .getJSONObject("B").get("39"));
//            }
//            String bloodFlowValueStr = condInfoJson.getJSONObject("14").has("value")
//              ? condInfoJson.getJSONObject("14").get("value").toString() : "0";
//
//            BigDecimal rate = org.apache.commons.lang3.StringUtils.isNotEmpty(rateStr)
//              && (TreatmentItemsDef.isFloat(rateStr) || TreatmentItemsDef.isInteger(rateStr))
//              ? new BigDecimal(rateStr) : BigDecimal.ZERO;
//            BigDecimal bloodFlowValue = org.apache.commons.lang3.StringUtils.isNotEmpty(bloodFlowValueStr)
//              && (TreatmentItemsDef.isFloat(bloodFlowValueStr) || TreatmentItemsDef.isInteger(bloodFlowValueStr))
//              ? new BigDecimal(bloodFlowValueStr) : BigDecimal.ZERO;
//            BigDecimal speed = bloodFlowValue.multiply(rate.divide(hundredConst, 3, RoundingMode.HALF_UP))
//              .multiply(hundredConst).divide(thousandConst, 3, RoundingMode.HALF_UP);
//            String delayTimeStr = String.valueOf(deviceSetInfoObject.getJSONObject("ope").getJSONObject("dev")
//              .getJSONObject("A").get("398"));
//            String treatTimeStr = condInfoJson.getJSONObject("1").get("value").toString();
//            BigDecimal delayTime = org.apache.commons.lang3.StringUtils.isNotEmpty(delayTimeStr)
//              && (TreatmentItemsDef.isFloat(delayTimeStr) || TreatmentItemsDef.isInteger(delayTimeStr))
//              ? new BigDecimal(delayTimeStr) : BigDecimal.ZERO;
//            BigDecimal treatTime = org.apache.commons.lang3.StringUtils.isNotEmpty(treatTimeStr)
//              && (TreatmentItemsDef.isFloat(treatTimeStr) || TreatmentItemsDef.isInteger(treatTimeStr))
//              ? new BigDecimal(treatTimeStr) : BigDecimal.ZERO;
//
//            if (treatTime.compareTo(delayTime) > 0) {
//              BigDecimal amount = speed.multiply(treatTime.subtract(delayTime)).divide(sixtyConst, 3, RoundingMode.HALF_UP);
//              JSONObject jsonObject1 = condInfoJson.getJSONObject(TreatmentItemsDef.T_I_IV_AMOUNT.getItemCode())
//                .put("value", TreatmentItemsDef.T_I_IV_AMOUNT.getFormattedValue(amount));
//              JSONObject jsonObject2 = condInfoJson.getJSONObject(TreatmentItemsDef.T_I_IV_FLOW_RATE.getItemCode())
//                .put("value", TreatmentItemsDef.T_I_IV_FLOW_RATE.getFormattedValue(speed));
//              condInfoJson.put("20", jsonObject1);
//              condInfoJson.put("24", jsonObject2);
//            }
//          }
//          // 3 濾過率から算出
//        } else if ("3".equals(liquidCalPriority)) {
//          JSONObject jsonObject1 = condInfoJson.getJSONObject("20").put("value", "-1");
//          JSONObject jsonObject2 = condInfoJson.getJSONObject("24").put("value", "-1");
//          condInfoJson.put("20", jsonObject1);
//          condInfoJson.put("24", jsonObject2);
//        }
//      }
//
      // del 10150_9664 by kangjie 20240912 end

      // 指示：医療材料情報
      SelectOptions selectOptions = SelectOptions.get();
      if ("0".equals(ordMainList.get(0).getRstDialysisState())) {
        /* #10757 mod コンバートされた治療方法セットで指示が作成できない 2024-06-26 卓 start */
        // buf = listMstTreatSet.get(0).getIndEquipInfo();
        buf = ObjectUtils.isEmpty(listMstTreatSet.get(0).getIndEquipInfo())? "[]" : listMstTreatSet.get(0).getIndEquipInfo();
        /* #10757 mod コンバートされた治療方法セットで指示が作成できない 2024-06-26 卓 end */
        JSONArray setEquip = new JSONArray(buf);
        JSONArray equipInfoJson = new JSONArray();
        MstEquipment mstEquipment = new MstEquipment();
        mstEquipment.setFacilityCd(bodyData.getFacility_cd());
        List<MstEquipment> mstEquipments = mstEquipDao.selectAll(selectOptions, mstEquipment);
        MstDialyzer mstDialyzerCond = new MstDialyzer();
        mstDialyzerCond.setFacilityCd(bodyData.getFacility_cd());
        List<MstDialyzer> mstDialyzers = mstDialyzerDao.selectAll(selectOptions, mstDialyzerCond);
        for (int i = 0; i < setEquip.length(); i++) {
          JSONObject obj = setEquip.getJSONObject(i);
          Integer cd = null;
          String needleType = null;
          String amount = null;
          String unitValue = null;
          int equipType = obj.optInt("equip_type");
          if (null != obj) {
            int equipCode = obj.optInt("cd");

            String isDisp;
            if (equipType == 0) {
              isDisp = mstEquipments.stream().filter(
                e -> e.getEquipmentCd().equals(equipCode)
              ).findFirst().orElse(new MstEquipment()).getIsDisp();
              unitValue = mstEquipments.stream().filter(
                e -> e.getEquipmentCd().equals(equipCode)
              ).findFirst().orElse(new MstEquipment()).getUnit();
            } else {
              isDisp = mstDialyzers.stream().filter(
                d -> d.getDialyzerCd().equals(equipCode)
              ).findFirst().orElse(new MstDialyzer()).getIsDisp();
            }
            if (! obj.isNull("cd")) cd = (int) obj.get("cd");
            if (! obj.isNull("needle_type"))
              needleType = obj.get("needle_type").toString();
            if (! obj.isNull("amount") && ("1".equals(isDisp)))
              amount = String.valueOf(obj.getInt("amount"));
          }

          JSONObject bufJson = new JSONObject();
          // 医療材料コード
          bufJson.put("cd", (null == cd) ? JSONObject.NULL : cd);
          // 穿刺針区分
          // del #11586 治療記録＞医療材料にてダイアライザを追加すると保存できない。 関 start
          // bufJson.put("needle_type", (null == needleType) ? JSONObject.NULL : needleType);
          // del #11586 治療記録＞医療材料にてダイアライザを追加すると保存できない。 関 end
          // 数量
          bufJson.put("amount", (null == amount) ? JSONObject.NULL : amount);
          // 指示者コード
          bufJson.put("ind_user_id", bodyData.getInd_user_id());
          // 指示者名_姓
          bufJson.put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          bufJson.put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          bufJson.put("upd_user_id", bodyData.getUpd_user_id());
          // 更新者名_姓
          bufJson.put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          bufJson.put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
          // 登録区分
          bufJson.put("input_class", 1);
          // 編集可否フラグ
          bufJson.put("is_editable", "1");
          // 連携オーダ番号
          bufJson.put("cop_order_no", JSONObject.NULL);
          // 医療材料区分
          bufJson.put("equip_type", equipType);

          equipInfoJson.put(bufJson);
        }
        ordMainDemo.setIndEquipInfo(equipInfoJson.toString());
      }
      // 指示:装置設定情報(ord)の指示者を設定
      JSONObject deviceUserJson = new JSONObject();
      deviceUserJson.put("ind_user_id", bodyData.getInd_user_id());
      deviceUserJson.put("upd_user_id", bodyData.getUpd_user_id());
      ordMainDemo.setIndDeviceUserInfo(deviceUserJson.toString());

      // 装置設定情報を取得
      String indDeviceSetInfo = null;
      try {
        // 装置設定情報を取得(装置設定デフォルトマスタ)
        // mod #11166 予定が新規登録すると、device_set_infoの中で1001と1002のkeyが必要がない、取得SQLを新規する zkm start
//        String bufDefault = deviceSetInfoService.getDeviceSetInfoMst(bodyData.getFacility_cd());
        String bufDefault = deviceSetInfoService.getDeviceSetInfoMstWithoutTmpZero(bodyData.getFacility_cd());
        // mod #11166 予定が新規登録すると、device_set_infoの中で1001と1002のkeyが必要がない、取得SQLを新規する zkm end
        // 装置設定情報を取得(治療方法セットマスタ)
        String bufTreatSet = listMstTreatSet.get(0).getIndDeviceSetInfo();
        JSONObject indDeviceSetInfoDefault = (bufDefault == null || bufDefault.isEmpty()) ?
          new JSONObject() :
          new JSONObject(bufDefault);
        JSONObject indDeviceSetInfoTreatSet = (bufTreatSet == null || bufTreatSet.isEmpty()) ?
          new JSONObject() :
          new JSONObject(bufTreatSet);
        JSONObject bvA = new JSONObject(deviceSetInfoObject.getJSONObject("bv")
          .getJSONObject("dev")
          .getJSONObject("A")
          .toString());
        JSONObject tmpA = new JSONObject(deviceSetInfoObject.getJSONObject("war")
          .getJSONObject("dev")
          .getJSONObject("A")
          .toString());
        //BV計_ブラッドボリューム計使用の選択
        String bvMeter = bvA.get("267").toString();
        //アクセス再循環測定使用選択
        String AccessRec = bvA.get("258").toString();
        //TMP監視モード 0:TMP自動追従
        String tmpMonitoring = tmpA.get("240").toString();
        if (DeviceMode.AFBF.equals(deviceMode) && "0".equals(tmpMonitoring)) {
          msglist.add("12000019");
        }
        // シングルニードル使用するの予定を作成する場合に、BV計使用する患者だった場合は注意メッセージ表示 1 :ON
        if ("1".equals(singleNeedle) && "1".equals(bvMeter)) {
          msglist.add("12000017");
        }
        //シングルニードル使用するの予定を作成する場合に、アクセス再循環率使用する患者だった場合は注意メッセージ表示。 1 :ON
        if ("1".equals(singleNeedle) && "1".equals(AccessRec)) {
          msglist.add("12000018");
        }
        JSONObject indDeviceSetInfoJson = this.deviceSetInfoMerge(indDeviceSetInfoDefault.getJSONObject("ord"), indDeviceSetInfoTreatSet);
        for (String key : JSONObject.getNames(indDeviceSetInfoJson)) {
          JSONObject usrJson = (JSONObject) indDeviceSetInfoJson.get(key);

          // 指示者コード
          usrJson.put("ind_user_id", bodyData.getInd_user_id());
          // 指示者名_姓
          usrJson.put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          usrJson.put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          usrJson.put("upd_user_id", bodyData.getUpd_user_id());
          // 更新者名_姓
          usrJson.put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          usrJson.put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
          indDeviceSetInfoJson.put(key, usrJson);
        }
        indDeviceSetInfo = indDeviceSetInfoJson.toString();
      } catch (Exception e) {
        eventLogMessage.setLogMessage("getDeviceSetInfoMst: " + e);
        logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
        HttpStatus status = HttpStatus.INTERNAL_SERVER_ERROR;
        // 引数は、ボディデータ,ヘッダーデータ,ステータス
        error.add("装置設定情報の作成に失敗しました。");
        resultData.put("error", error);
        invokeResult.success(resultData);
        return invokeResult;
      }
      ordMainDemo.setIndDeviceSetInfo(indDeviceSetInfo);
      ordMainDemo.setUpDate(new Timestamp(System.currentTimeMillis()));

      // add 10150_9664 by kangjie 20240912 start
      if (!SPECIAL_DEVICE.contains(deviceMode) && !NO_IV.contains(deviceMode)) {
        Map<String,String> ivAmountAndSpeedMap = null;
        if (DeviceMode.I_HDF.equals(deviceMode)) {
          String treatTimeStr = condInfoJson.getJSONObject(T_I_START_DATE.getItemCode())
            .getString("value");
          ivAmountAndSpeedMap = getIhdfCalculateLiquidAmoutAndSpeed(new JSONObject(indDeviceSetInfo),treatTimeStr);
        }else {
          ivAmountAndSpeedMap = calIvAmountAndIvSpeed(condInfoJson,deviceSetInfo,deviceMode);
        }
        if (!ObjectUtils.isEmpty(ivAmountAndSpeedMap)) {
          ivAmountAndSpeedMap.forEach((key,value)->{
            JSONObject ivAmountAndSpeedJSON = condInfoJson.getJSONObject(key);
            if (!ObjectUtils.isEmpty(ivAmountAndSpeedJSON)) {
              ivAmountAndSpeedJSON.put("value",value);
              ivAmountAndSpeedJSON.put("ind_user_id", bodyData.getInd_user_id());
              ivAmountAndSpeedJSON.put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
              ivAmountAndSpeedJSON.put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
              ivAmountAndSpeedJSON.put("upd_user_id", bodyData.getUpd_user_id());
              ivAmountAndSpeedJSON.put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
              ivAmountAndSpeedJSON.put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
            }
          });
        }
      }
      // add 10150_9664 by kangjie 20240912 end

      ordMainDemo.setIndCondInfo(condInfoJson.toString());

      // 治療方法セットの内容で全て変更
      if (1 == selectMethod) {
        // 投与薬剤情報
        JSONArray mediInfoJson = new JSONArray();
        // 指示コメント情報
        JSONArray commInfoJson = new JSONArray();

        try {
          // 指示：投与薬剤情報
          /* #10757 mod コンバートされた治療方法セットで指示が作成できない 2024-06-26 卓 start */
          // buf = listMstTreatSet.get(0).getIndMediInfo();
          buf = ObjectUtils.isEmpty(listMstTreatSet.get(0).getIndMediInfo())? "[]" :  listMstTreatSet.get(0).getIndMediInfo();
          /* #10757 mod コンバートされた治療方法セットで指示が作成できない 2024-06-26 卓 end */
          JSONArray setMedi = new JSONArray(buf);
          MstMedicine mstMedicine = new MstMedicine();
          mstMedicine.setFacilityCd(bodyData.getFacility_cd());
          List<MstMedicine> mstMedicines = mstMedicineDao.selectAll(selectOptions, mstMedicine);
          // 薬剤マスタ
          MstMedicine paramMedicine = new MstMedicine();
          paramMedicine.setFacilityCd(facilityCd);
          List<MstMedicine> lstMstMedicine = mstMedicineDao.selectAllDel(selectOptions, paramMedicine);
          // 調製薬剤マスタ
          MstMedicineMix paramMedicineMix = new MstMedicineMix();
          paramMedicineMix.setFacilityCd(facilityCd);
          List<MstMedicineMix> lstMstMedicineMix = mstMedicineMixDao.selectMstMedicineMixAllergyData(selectOptions, paramMedicineMix);
          // 薬剤分類マスタ
          MstMedicineClass paramMedicineClass = new MstMedicineClass();
          paramMedicineClass.setFacilityCd(facilityCd);
          List<MstMedicineClass>  lstMstMedicineClass = mstMedicineClassDao.selectAll(selectOptions, paramMedicineClass);
          // 投与タイミング
          MstMedicateTiming paramMstMedicateTiming = new MstMedicateTiming();
          paramMstMedicateTiming.setFacilityCd(facilityCd);
          List<MstMedicateTiming>  lstMstMedicateTiming = mstMedicateTimingDao.selectAllIncludeDeleted(selectOptions, paramMstMedicateTiming);
          // 手技マスタ
          MstProcedure paramMstProcedure = new MstProcedure();
          paramMstProcedure.setFacilityCd(facilityCd);
          List<MstProcedure> lstMstProcedure = mstProcedureDao.selectAllIncludeDeleted(selectOptions, paramMstProcedure);

          for (int i = 0; i < setMedi.length(); i++) {
            JSONObject obj = setMedi.getJSONObject(i);
            String medicineComment = null;
            if (obj.has("medicine_comment") && obj.get("medicine_comment") != null) {
              medicineComment = obj.get("medicine_comment").toString();
            }
            Integer medicineType = null;
            Integer cd = null;
            Object amount = null;
            Integer timingCd = null;
            Integer procedureCd = null;
            String initDate = null;
            Integer dateInterval = null;
            String name = null;
            String unit = null;
            Integer classCd = null;
            String className = null;
            Double classType = null;
            String shortName = null;
            String timingName = null;
            String procedureName = null;

            if (null != obj) {
              String isDisp = null;
              if (! obj.isNull("cd")) {
                cd = (int) obj.get("cd");
                if (! obj.isNull("medicine_type")) {
                  medicineType = Integer.parseInt(obj.get("medicine_type").toString());
                  if (MEDICINE_TYPE_NORMAL.equals(medicineType)) {
                    final Integer finalCd = cd;
                    List<MstMedicine> medicines = mstMedicines.stream().filter(a -> a.getMedicineCd().equals(finalCd)).collect(Collectors.toList());
                    if (null != medicines && 0 != medicines.size()) {
                      isDisp = medicines.get(0).getIsDisp();
                    }
                  } else {
                    MstMedicineMix mstMedicineMix = mstMedicineMixDao.selectByCd(bodyData.getFacility_cd(), cd);
                    if (null != mstMedicineMix) {
                      isDisp = mstMedicineMix.getIsDisp();
                    }
                  }
                }
              }
              if (! obj.isNull("amount") && ("1".equals(isDisp)))
                amount = obj.get("amount");
              if (! obj.isNull("timing_cd"))
                timingCd = (int) obj.get("timing_cd");
              if (! obj.isNull("procedure_cd"))
                procedureCd = (int) obj.get("procedure_cd");
              initDate = bodyData.getStart_date().replaceAll("-", ""); //初回投与日は開始日で設定
              dateInterval = 0; //投与間隔は毎回で設定

              if (selectOrdNo != null && !"0".equals(ordMainList.get(0).getRstDialysisState())) {
                int medicineCd = Integer.parseInt(obj.get("cd").toString());
                Integer tC = timingCd;
                Integer pC = procedureCd;
                if (MEDICINE_TYPE_NORMAL.equals(medicineType)) {
                  MstMedicine mstMe = lstMstMedicine.stream().filter(
                    d -> d.getMedicineCd().equals(medicineCd)
                  ).findFirst().orElse(new MstMedicine());
                  name = mstMe.getMedicineName();
                  unit = mstMe.getUnit();
                  classCd = mstMe.getClassCd();
                  shortName = mstMe.getMedicineShortName();
                  if (!"null".equals(classCd)) {
                    MstMedicineClass mstMedicineClass = lstMstMedicineClass.stream().filter(
                      d -> d.getClassCd().equals(mstMe.getClassCd())
                    ).findFirst().orElse(new MstMedicineClass());
                    className = mstMedicineClass.getClassName();
                    classType = mstMedicineClass.getClassType();
                  }
                  if (!"null".equals(tC)) {
                    MstMedicateTiming mstMedicateTiming = lstMstMedicateTiming.stream().filter(
                      d -> d.getMedicateTimingCd().equals(tC)
                    ).findFirst().orElse(new MstMedicateTiming());

                    timingName = mstMedicateTiming.getMedicateTimingName();
                  }
                  if (!"null".equals(pC)) {

                    MstProcedure mstProcedure = lstMstProcedure.stream().filter(
                      d -> d.getProcedureCd().equals(pC)
                    ).findFirst().orElse(new MstProcedure());

                    procedureName = mstProcedure.getPricedureName();
                  }
                }else {
                  MstMedicineMix mstMeMix = lstMstMedicineMix.stream().filter(
                    d -> d.getMedicineMixCd().equals(medicineCd)
                  ).findFirst().orElse(new MstMedicineMix());
                  name = mstMeMix.getMedicineMixName();
                  unit = mstMeMix.getUnit();
                  classCd = mstMeMix.getClassCd();
                  shortName = mstMeMix.getMedicineMixShortName();
                  if (!"null".equals(classCd)) {
                    MstMedicineClass mstMedicineClass = lstMstMedicineClass.stream().filter(
                      d -> d.getClassCd().equals(mstMeMix.getClassCd())
                    ).findFirst().orElse(new MstMedicineClass());
                    className = mstMedicineClass.getClassName();
                    classType = mstMedicineClass.getClassType();
                  }
                  if (!"null".equals(tC)) {
                    MstMedicateTiming mstMedicateTiming = lstMstMedicateTiming.stream().filter(
                      d -> d.getMedicateTimingCd().equals(tC)
                    ).findFirst().orElse(new MstMedicateTiming());

                    timingName = mstMedicateTiming.getMedicateTimingName();
                  }
                  if (!"null".equals(pC)) {

                    MstProcedure mstProcedure = lstMstProcedure.stream().filter(
                      d -> d.getProcedureCd().equals(pC)
                    ).findFirst().orElse(new MstProcedure());

                    procedureName = mstProcedure.getPricedureName();
                  }
                }

              }

            }
            long indMediInfoNo = maxMediInfoNo + i;

            JSONObject bufJson = new JSONObject();
            // 識別番号
            bufJson.put("no", indMediInfoNo);
            // 薬剤区分
            bufJson.put("medicine_type", (null == medicineType) ? JSONObject.NULL : medicineType);
            // 薬剤(調整薬剤)コード
            bufJson.put("cd", (null == cd) ? JSONObject.NULL : cd);
            // 数量
            bufJson.put("amount", (null == amount) ? JSONObject.NULL : amount.toString());
            // 初回投与日
            bufJson.put("init_date", (null == initDate) ? JSONObject.NULL : initDate);
            // 投与間隔
            bufJson.put("date_interval", (null == dateInterval) ? JSONObject.NULL : dateInterval);
            // 投与タイミングコード
            bufJson.put("timing_cd", (null == timingCd) ? JSONObject.NULL : timingCd);
            // 手技コード
            bufJson.put("procedure_cd", (null == procedureCd) ? JSONObject.NULL : procedureCd);
            // コメント
            bufJson.put("comment", medicineComment != null ? medicineComment : JSONObject.NULL);
            // 指示者コード
            bufJson.put("ind_user_id", bodyData.getInd_user_id());
            // 指示者名_姓
            bufJson.put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
            // 指示者名_名
            bufJson.put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
            // 更新者コード
            bufJson.put("upd_user_id", bodyData.getUpd_user_id());
            // 更新者名_姓
            bufJson.put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
            // 更新者名_名
            bufJson.put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
            // 登録区分
            bufJson.put("input_class", 1);
            // 編集可否フラグ
            bufJson.put("is_editable", "1");
            // 連携オーダ番号
            bufJson.put("cop_order_no", JSONObject.NULL);
            if (selectOrdNo != null && !"0".equals(ordMainList.get(0).getRstDialysisState())) {
              bufJson.put("name", name != null ? name : JSONObject.NULL);
              bufJson.put("unit", unit != null ? unit : JSONObject.NULL);
              bufJson.put("class_cd", classCd != null ? classCd : JSONObject.NULL);
              bufJson.put("class_name", className != null ? className : JSONObject.NULL);
              bufJson.put("class_type", classType != null ? classType : JSONObject.NULL);
              bufJson.put("short_name", shortName != null ? shortName : JSONObject.NULL);
              bufJson.put("timing_name", timingName != null ? timingName : JSONObject.NULL);
              bufJson.put("procedure_name", procedureName != null ? procedureName : JSONObject.NULL);
            }
            mediInfoJson.put(bufJson);
          }
          ordMainDemo.setIndMediInfo(mediInfoJson.toString());

          // 指示：指示コメント情報
          /* #10757 mod コンバートされた治療方法セットで指示が作成できない 2024-06-26 卓 start */
          // buf = listMstTreatSet.get(0).getIndIndCommentInfo();
          buf = ObjectUtils.isEmpty(listMstTreatSet.get(0).getIndIndCommentInfo())? "[]" : listMstTreatSet.get(0).getIndIndCommentInfo();
          /* #10757 mod コンバートされた治療方法セットで指示が作成できない 2024-06-26 卓 end */
          JSONArray setComment = new JSONArray(buf);
          for (int i = 0; i < setComment.length(); i++) {
            JSONObject obj = setComment.getJSONObject(i);
            Integer no = null;
            String content = null;

            if (null != obj) {
              if (! obj.isNull("no")) no = (int) obj.get("no");
              if (! obj.isNull("content"))
                content = obj.get("content").toString();
            }

            JSONObject bufJson = new JSONObject();
            // 指示コメント番号
            bufJson.put("no", (null == no) ? JSONObject.NULL : no);
            // 内容
            bufJson.put("content", (null == content) ? JSONObject.NULL : content);
            // 指示者コード
            bufJson.put("ind_user_id", bodyData.getInd_user_id());
            // 指示者名_姓
            bufJson.put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
            // 指示者名_名
            bufJson.put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
            // 更新者コード
            bufJson.put("upd_user_id", bodyData.getUpd_user_id());
            // 更新者名_姓
            bufJson.put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
            // 更新者名_名
            bufJson.put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
            // 登録区分
            bufJson.put("input_class", 1);
            // 編集可否フラグ
            bufJson.put("is_editable", "1");
            // 連携オーダ番号
            bufJson.put("cop_order_no", JSONObject.NULL);

            commInfoJson.put(bufJson);
          }
          ordMainDemo.setIndIndCommentInfo(commInfoJson.toString());

        } catch (Exception e) {
          eventLogMessage.setLogMessage("insertByTreatSetCd Exception: " + e);
          logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
          HttpStatus status = HttpStatus.INTERNAL_SERVER_ERROR;
          //引数は、ボディデータ,ヘッダーデータ,ステータス
          error.add("登録用情報の作成に失敗しました。");
          resultData.put("error", error);
          invokeResult.success(resultData);
          return invokeResult;
        }
      }

      // 治療予定が登録された場合以下の処理
      if (0 != ordNoList.size()) {
        // 治療予定が登録されかつ、終了日が設定されていない場合以下の処理
        if ("false".equals(bodyData.getIs_deadline())) {
          // 治療種別を調整
          String treatType = bodyData.getTreat_type();
          // 治療種別をDBと合わせる TODO:画面側では治療種別が0->通常、1->隔日、2->隔週となっている
          treatType = treatType.equals("0") ? "1" : treatType.equals("1") ? "2" : treatType.equals("2") ? "3" : null;

          Timestamp bodyUpdate = new Timestamp(new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ").parse(bodyData.getUp_date()).getTime());

          // 曜日パターン
          List<Integer> weekPattern = new ArrayList<>();
          if (null == bodyData.getUpdate_week_pattern()) {
            weekPattern = IndicationUtils.getWeekPattern(bodyData.getWeek_pattern());
          } else {
            JSONArray pattern = new JSONArray(bodyData.getUpdate_week_pattern());
            for (int i = 0; i < pattern.length(); i++) {
              weekPattern.add(pattern.getInt(i));
            }
          }
          // 患者治療パターン編集データ
          // mod #12472 治療方法の変更で補液なし治療からオンライン補液あり治療に、「治療方法のみ」で変更するとpat_treatment_patternに欠損データが発生する。 関 start
          OrdMainCrudDto dto = OrdMainCrudDto.builder()
            .patId(Long.parseLong(bodyData.getPat_id()))
            .facilityCd(facilityCd)
            .treatmentSetCd(bodyData.getTreatment_set_cd())
            .treatMethodFlag(bodyData.getTreat_method_flag())
            .startDate(bodyData.getStart_date().replaceAll("-", ""))
            .upIndUserId(bodyData.getInd_user_id().longValue())
            .upUserId(bodyData.getUpd_user_id().longValue())
            .treatType(bodyData.getTreat_type())
            .build();

          JSONObject userInfoJson = new JSONObject();
          {
            // 指示者コード
            userInfoJson.put("ind_user_id", bodyData.getInd_user_id());
            userInfoJson.put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
            userInfoJson.put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
            userInfoJson.put("upd_user_id", bodyData.getUpd_user_id());
            userInfoJson.put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
            userInfoJson.put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
          }

          Map<String, String> otherConditions = new HashMap<>();
          otherConditions.put("ind_treatment_cd", listMstTreatSet.get(0).getTreatmentCd().toString());

          PatTreatmentPattern newPatTreatmentPattern = patTreatmentPatternDao.createPatTreatmentPatternFromMstTreatmentSet(userInfoJson.toString(), dto);
          // 必須なパラメータを設定する
          PatTreatmentPatternKey key = new PatTreatmentPatternKey(
            Long.parseLong(bodyData.getPat_id()),
            facilityCd,
            this.getValueList(bodyData.getInd_treatment_cd()),
            this.getLongList(bodyData.getInd_kur_cd()),
            weekPattern,
            null,
            otherConditions
          );
          JSONObject jsonObject = new JSONObject();

          PatTreatmentPatternUpsert upsert = new PatTreatmentPatternUpsert(key);

          upsert.setIndTreatmentCd(newPatTreatmentPattern.getIndTreatmentCd());
          upsert.addJsonbUpdate(PatTreatmentPatternFieldEnum.IND_COND_INFO, new PatTreatmentPatternJsonbField(
            PatTreatmentPatternUpdateModeEnum.OVERWRITE, newPatTreatmentPattern.getIndCondInfo()));
          upsert.addJsonbUpdate(PatTreatmentPatternFieldEnum.IND_EQUIP_INFO, new PatTreatmentPatternJsonbField(
            PatTreatmentPatternUpdateModeEnum.OVERWRITE, newPatTreatmentPattern.getIndEquipInfo()));
          upsert.addJsonbUpdate(PatTreatmentPatternFieldEnum.IND_DEVICE_SET_INFO, new PatTreatmentPatternJsonbField(
            PatTreatmentPatternUpdateModeEnum.OVERWRITE, newPatTreatmentPattern.getIndDeviceSetInfo()));
          upsert.addJsonbUpdate(PatTreatmentPatternFieldEnum.TREATMENT_METHOD_SET_CHANGE, new PatTreatmentPatternJsonbField(
            PatTreatmentPatternUpdateModeEnum.MERGE,
            jsonObject.toString()));
          if (bodyData.getTreat_method_flag().equals("1")) {
            upsert.addJsonbUpdate(PatTreatmentPatternFieldEnum.IND_MEDI_INFO, new PatTreatmentPatternJsonbField(
              PatTreatmentPatternUpdateModeEnum.OVERWRITE, newPatTreatmentPattern.getIndMediInfo()));
            upsert.addJsonbUpdate(PatTreatmentPatternFieldEnum.IND_COMMENT_INFO, new PatTreatmentPatternJsonbField(
              PatTreatmentPatternUpdateModeEnum.OVERWRITE, newPatTreatmentPattern.getIndIndCommentInfo()));
          }
          PatTreatmentPatternDelta delta = new PatTreatmentPatternDelta();
          delta.getUpdates().add(upsert);

          // パタン共通を呼びだす
          Map<jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.service.PatTreatmentPatternService.RESULT_TYPE, List<PatTreatmentPattern>> responseMap =
            patTreatmentActualService.applyPatTreatmentPatterns(delta);
          //mod 10813 無期限で治療予定を作成した際、pat_treatment_patternのreg_dateとup_dateが、選択した治療方法セットのreg_dateとup_dateの日時になる zhao start
//          int patPatternCount = patTreatmentPatternUtils.updatePatTreatmentPatternIndItemForTreatSet(
//            Long.parseLong(bodyData.getPat_id()),
//            bodyData.getFacility_cd(),
//            this.getValueList(bodyData.getInd_treatment_cd()),
//            this.getLongList(bodyData.getInd_kur_cd()),
//            weekPattern,
//            updateIndItemList,
//            bodyUpdate,
//            editData
//          );
          Timestamp regDateNow = new Timestamp(System.currentTimeMillis());
          // add 11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる 関 start
          List<PatTreatmentPatternPatMain> beforePatternList= patTreatmentPatternDao.selectByTreatmentCdAndTreatWeek(bodyData.getFacility_cd(), Long.parseLong(bodyData.getPat_id()),this.getValueList(bodyData.getInd_treatment_cd()), weekPattern,this.getLongList(bodyData.getInd_kur_cd()));
          List<Long> beforeCtlNoList = beforePatternList.stream()
            .map(PatTreatmentPatternPatMain::getCtlNo)
            .collect(Collectors.toList());
          // add 11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる 関 end

//          int patPatternCount = patTreatmentPatternUtils.updatePatTreatmentPatternIndItemForTreatSet(
//            Long.parseLong(bodyData.getPat_id()),
//            bodyData.getFacility_cd(),
//            this.getValueList(bodyData.getInd_treatment_cd()),
//            this.getLongList(bodyData.getInd_kur_cd()),
//            weekPattern,
//            updateIndItemList,
//            regDateNow,
//            editData
//          );
          List<PatTreatmentPattern> changePattern = responseMap.get(jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.service.PatTreatmentPatternService.RESULT_TYPE.NEW);
          //mod 10813 無期限で治療予定を作成した際、pat_treatment_patternのreg_dateとup_dateが、選択した治療方法セットのreg_dateとup_dateの日時になる zhao end
          //add #11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) zkm start
          if (changePattern.size() > 0) {
            patTreatmentPatternDao.updatePatTreatmentPatternBedCdZeroForTreatMethod(bodyData.getFacility_cd(),Long.parseLong(bodyData.getPat_id()), "2", beforeCtlNoList);

            // 更新後スケジュールを展開する
            List<OrdScheduleNewKurPreview> ordScheduleList = ordScheduleDao.selectDummyScheduleInPatId(bodyData.getFacility_cd(), Long.parseLong(bodyData.getPat_id()), weekPattern,
              this.getValueList(bodyData.getInd_treatment_cd()), this.getLongList(bodyData.getInd_kur_cd()));
            List<Long> lowPriorityCtlNoList = ordMainSchChangeUtils.searchLowPriorityNoList(bodyData.getFacility_cd(), ordScheduleList);

            if (!lowPriorityCtlNoList.isEmpty()) {
              patTreatmentPatternDao.updatePatTreatmentPatternBedCdZeroByCtlNoList(bodyData.getFacility_cd(), Long.parseLong(bodyData.getPat_id()), lowPriorityCtlNoList);
            }
          }
          //add #11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) zkm end
          // mod #12472 治療方法の変更で補液なし治療からオンライン補液あり治療に、「治療方法のみ」で変更するとpat_treatment_patternに欠損データが発生する。 関 end
        }
      }
    }
    boolean setResult;
    DataUpdateLogCommonNew logCommon = null;
    try {
      String tableName = "ord_main";
      // SQL検索条件
      String inStr = getInStr("ord_no in ", ordNoList);
      StringBuffer wheres = new StringBuffer();
      wheres.append(" WHERE\n");
      wheres.append(inStr).append("\n");
      logCommon = getLogCommon(ordMainDao, tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      setResult = logCommon.setInfo();
    } catch (Exception e) {
      setResult = false;
    }

    int updCount = 0;
    if (selectOrdNo == null) {
      if (isTreatSet) {
        updCount = ordMainDao.updateByTreatmentCd(targetTreatmentCd, ordMainDemo, ordNoList, bodyData.getInd_user_id(), ntssUser.getUserId());
      } else {
        if (DeviceMode.HD.equals(selectedTreat.getDeviceMode())) {
          updCount = ordMainDao.updateByTreatmentCdOnlyForHD(targetTreatmentCd, ordMainDemo, ordNoList, bodyData.getInd_user_id(), ntssUser.getUserId());
        }
        if (DeviceMode.HDF.equals(selectedTreat.getDeviceMode())) {
          updCount = ordMainDao.updateByTreatmentCdOnlyForHDF(targetTreatmentCd, ordMainDemo, ordNoList, bodyData.getInd_user_id(), ntssUser.getUserId());
        }
        if (DeviceMode.HF.equals(selectedTreat.getDeviceMode())) {
          updCount = ordMainDao.updateByTreatmentCdOnlyForHF(targetTreatmentCd, ordMainDemo, ordNoList, bodyData.getInd_user_id(), ntssUser.getUserId());
        }
        if (DeviceMode.ECUM.equals(selectedTreat.getDeviceMode())) {
          updCount = ordMainDao.updateByTreatmentCdOnlyForECUM(targetTreatmentCd, ordMainDemo, ordNoList, bodyData.getInd_user_id(), ntssUser.getUserId());
        }
        if (DeviceMode.PURIFICATION.equals(selectedTreat.getDeviceMode())) {
          updCount = ordMainDao.updateByTreatmentCdOnlyForPURIFICATION(targetTreatmentCd, ordMainDemo, ordNoList, bodyData.getInd_user_id(), ntssUser.getUserId());
        }
        if (DeviceMode.AFBF.equals(selectedTreat.getDeviceMode())) {
          updCount = ordMainDao.updateByTreatmentCdOnlyForAFBF(targetTreatmentCd, ordMainDemo, ordNoList, bodyData.getInd_user_id(), ntssUser.getUserId());
        }
        if (DeviceMode.OHDF.equals(selectedTreat.getDeviceMode())) {
          updCount = ordMainDao.updateByTreatmentCdOnlyForOHDF(targetTreatmentCd, ordMainDemo, ordNoList, bodyData.getInd_user_id(), ntssUser.getUserId());
        }
        if (DeviceMode.OHF.equals(selectedTreat.getDeviceMode())) {
          updCount = ordMainDao.updateByTreatmentCdOnlyForOHF(targetTreatmentCd, ordMainDemo, ordNoList, bodyData.getInd_user_id(), ntssUser.getUserId());
        }
        if (DeviceMode.I_HDF.equals(selectedTreat.getDeviceMode())) {
          updCount = ordMainDao.updateByTreatmentCdOnlyForIHDF(targetTreatmentCd, ordMainDemo, ordNoList, bodyData.getInd_user_id(), ntssUser.getUserId());
        }
        // mod 11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) 関 start
        if (DeviceMode.UNKNOWN.equals(selectedTreat.getDeviceMode())) {
          updCount = ordMainDao.updateByTreatmentCdOnlyForPURIFICATION(targetTreatmentCd, ordMainDemo, ordNoList, bodyData.getInd_user_id(), ntssUser.getUserId());
        }
        // mod 11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) 関 end
      }
      // add #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 start
      patIndApproveDao.updateAppContentChangeSingleByOrdNoList(ordNoList);
      // add #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 end
    } else {
      // 治療方法のみ変更、治療方法セットの内容で全て変更、治療方法セットの内容で治療条件と医療材料を変更
      // 初版確定済みの場合
      if ("6".equals(ordMainList.get(0).getRstDialysisState())) {
        // 特殊浄化
        if (DeviceMode.PURIFICATION.equals(selectedTreat.getDeviceMode())) {
          // 透析回数がnullで更新
          ordMainDemo.setRstDialysisCnt(null);
          // 特殊浄化以外
        }else {
          // 特殊浄化回数nullで更新
          ordMainDemo.setRstPurificationCnt(null);
        }
        //初版確定未済の場合
      }else if("5".equals(ordMainList.get(0).getRstDialysisState())) {
        if (DeviceMode.PURIFICATION.equals(selectedTreat.getDeviceMode())) {
          ordMainDemo.setRstDialysisCnt(0);
          JSONObject medicalCareInfo= new JSONObject(patMain.getMedical_care_info());
          int rstPurificationCnt = jsonNodeIsNull(medicalCareInfo.get("purification_count"))
            ? 1 : Integer.parseInt(medicalCareInfo.get("purification_count").toString())+1;
          // 透析回数がnullで更新
          ordMainDemo.setRstDialysisCnt(rstPurificationCnt);
        }else{
          // 特殊浄化回数nullで更新
          ordMainDemo.setRstPurificationCnt(null);
          JSONObject medicalCareInfo= new JSONObject(patMain.getMedical_care_info());
          int rstDialysisCnt = jsonNodeIsNull(medicalCareInfo.get("dialysis_count"))
            ? 1 : Integer.parseInt(medicalCareInfo.get("dialysis_count").toString())+1;
          ordMainDemo.setRstDialysisCnt(rstDialysisCnt);
        }
      }
      MstEquipment mstEquipment = new MstEquipment();
      mstEquipment.setFacilityCd(bodyData.getFacility_cd());
      SelectOptions selectOptions = SelectOptions.get();
      List<MstEquipment> mstEquipments = mstEquipDao.selectIncludeDeleted(selectOptions, mstEquipment);
      MstDialyzer mstDialyzerCond = new MstDialyzer();
      mstDialyzerCond.setFacilityCd(bodyData.getFacility_cd());
      List<MstDialyzer> mstDialyzers = mstDialyzerDao.selectIncludeDeleted(selectOptions, mstDialyzerCond);
      //ord_main json更新
      // 治療方法セットの内容で全て変更、治療方法セットの内容で治療条件と医療材料を変更
      if (isTreatSet) {
        JSONObject condInfoJson = new JSONObject(ordMainDemo.getIndCondInfo());

        // 実績値の編集
        if (!"0".equals(ordMainList.get(0).getRstDialysisState())) {
          for (int i = 1; i <= 38; i++) {
            String key = Integer.toString(i);
            switch (i) {
              case 1:
                if (condInfoJson.has(key)) {
                  condInfoJson.getJSONObject(key).put("unit", "分");
                }
                break;
              case 2:
                if (condInfoJson.has(key) && !condInfoJson.getJSONObject(key).isNull("value")) {
                  Gson gson = new Gson();
                  CondInfoItem condInfoItem = gson.fromJson(condInfoJson.get(key).toString(), CondInfoItem.class);
                  // マスタ情報取得
                  MstVa mstVa = mstVaDao.selectAllByCd(Integer.parseInt(condInfoItem.getValue()));

                  condInfoJson.getJSONObject(key).put("value_name_1", (null == mstVa.getVaName()) ? JSONObject.NULL : mstVa.getVaName());
                }
                break;
              case 3:
                if (condInfoJson.has(key)) {
                  condInfoJson.getJSONObject(key).put("unit", "Kg");
                }
                break;
              case 4:
              case 20:
                if (condInfoJson.has(key)) {
                  condInfoJson.getJSONObject(key).put("unit", "L");
                }
                break;
              case 5:
                if (condInfoJson.has(key)) {
                  condInfoJson.getJSONObject(key).put("unit", "本");
                  if (!condInfoJson.getJSONObject(key).isNull("value")) {
                    Gson gson = new Gson();
                    CondInfoItem condInfoItem = gson.fromJson(condInfoJson.get(key).toString(), CondInfoItem.class);
                    // マスタ情報取得
                    MstDialyzer mstDialyzer = mstDialyzers.stream().filter(
                      d -> d.getDialyzerCd().equals(Integer.parseInt(condInfoItem.getValue()))
                    ).findFirst().orElse(new MstDialyzer());

                    condInfoJson.getJSONObject(key).put("value_name_1", (null == mstDialyzer.getModelNumber()) ? JSONObject.NULL : mstDialyzer.getModelNumber());
                    condInfoJson.getJSONObject(key).put("value_name_2", (null == mstDialyzer.getMaker()) ? JSONObject.NULL : mstDialyzer.getMaker());
                  }
                }
                break;
              case 6:
              case 7:
              case 8:
              case 9:
              case 10:
              case 11:
              case 13:
                if (condInfoJson.has(key) && !condInfoJson.getJSONObject(key).isNull("value")) {
                  Gson gson = new Gson();
                  CondInfoItem condInfoItem = gson.fromJson(condInfoJson.get(key).toString(), CondInfoItem.class);
                  // マスタ情報取得
                  MstEquipment mste = mstEquipments.stream().filter(
                    e -> e.getEquipmentCd().equals(Integer.parseInt(condInfoItem.getValue()))
                  ).findFirst().orElse(new MstEquipment());
                  condInfoJson.getJSONObject(key).put("unit", (null == mste.getUnit()) ? JSONObject.NULL : mste.getUnit());
                  condInfoJson.getJSONObject(key).put("value_name_1", (null == mste.getEquipmentName()) ? JSONObject.NULL : mste.getEquipmentName());
                }
                break;
              case 12:
              case 29:
                if (condInfoJson.has(key) && !condInfoJson.getJSONObject(key).isNull("value")) {
                  Gson gson = new Gson();
                  CondInfoItem condInfoItem = gson.fromJson(condInfoJson.get(key).toString(), CondInfoItem.class);
                  if ("0".equals(condInfoItem.getValue())) {
                    condInfoJson.getJSONObject(key).put("value_name_1", "使用しない");
                  }else if("1".equals(condInfoItem.getValue())) {
                    condInfoJson.getJSONObject(key).put("value_name_1", "使用する");
                  }
                }
                break;
              case 15:
                if (condInfoJson.has(key) && !condInfoJson.getJSONObject(key).isNull("value")) {
                  Gson gson = new Gson();
                  CondInfoItem condInfoItem = gson.fromJson(condInfoJson.get(key).toString(), CondInfoItem.class);
                  // マスタ情報取得
                  MstMedicine mstMedicine = mstMedicineDao.selectAllByMediCd(Integer.parseInt(condInfoItem.getValue()));

                  condInfoJson.getJSONObject(key).put("value_name_1", (null == mstMedicine.getMedicineName()) ? JSONObject.NULL : mstMedicine.getMedicineName());
                  condInfoJson.getJSONObject(key).put("unit", (null == mstMedicine.getUnit()) ? JSONObject.NULL : mstMedicine.getUnit());
                  condInfoJson.getJSONObject("17").put("unit", (null == mstMedicine.getUnitSecond()) ? JSONObject.NULL : mstMedicine.getUnitSecond());
                }
                break;
              case 19:
                if (condInfoJson.has(key) && !condInfoJson.getJSONObject(key).isNull("value")) {
                  Gson gson = new Gson();
                  CondInfoItem condInfoItem = gson.fromJson(condInfoJson.get(key).toString(), CondInfoItem.class);
                  // マスタ情報取得
                  MstMedicine mstMedicine = mstMedicineDao.selectAllByMediCd(Integer.parseInt(condInfoItem.getValue()));

                  condInfoJson.getJSONObject(key).put("value_name_1", (null == mstMedicine.getMedicineName()) ? JSONObject.NULL : mstMedicine.getMedicineName());
                  condInfoJson.getJSONObject(key).put("unit", (null == mstMedicine.getUnit()) ? JSONObject.NULL : mstMedicine.getUnit());
                  condInfoJson.getJSONObject("22").put("unit", (null == mstMedicine.getUnitSecond()) ? JSONObject.NULL : mstMedicine.getUnitSecond());
                }
                break;
              case 14:
              case 16:
                if (condInfoJson.has(key)) {
                  condInfoJson.getJSONObject(key).put("unit", "mL/min");
                }
                break;
              case 21:
                if (condInfoJson.has(key) && !condInfoJson.getJSONObject(key).isNull("value")) {
                  Gson gson = new Gson();
                  CondInfoItem condInfoItem = gson.fromJson(condInfoJson.get(key).toString(), CondInfoItem.class);
                  if ("1".equals(condInfoItem.getValue())) {
                    condInfoJson.getJSONObject(key).put("value_name_1", "前補液");
                  }else if("0".equals(condInfoItem.getValue())) {
                    condInfoJson.getJSONObject(key).put("value_name_1", "後補液");
                  }
                }
                break;
              case 18:
              case 23:
                if (condInfoJson.has(key)) {
                  condInfoJson.getJSONObject(key).put("unit", "℃");
                }
                break;
              case 24:
                if (condInfoJson.has(key)) {
                  condInfoJson.getJSONObject(key).put("unit", "L/h");
                }
                break;
              case 25:
                if (condInfoJson.has(key) && !condInfoJson.getJSONObject(key).isNull("value")) {
                  Gson gson = new Gson();
                  CondInfoItem condInfoItem = gson.fromJson(condInfoJson.get(key).toString(), CondInfoItem.class);
                  if (!jsonNodeIsNull(condInfoJson.getJSONObject(key).get("medicine_type")) && "1".equals(condInfoJson.getJSONObject(key).get("medicine_type").toString())) {
                    // マスタ情報取得
                    MstMedicine mstMedicine = mstMedicineDao.selectAllByMediCd(Integer.parseInt(condInfoItem.getValue()));
                    condInfoJson.getJSONObject(key).put("value_name_1", (null == mstMedicine.getMedicineName()) ? JSONObject.NULL : mstMedicine.getMedicineName());
                    condInfoJson.getJSONObject(key).put("unit", (null == mstMedicine.getUnit()) ? JSONObject.NULL : mstMedicine.getUnit());
                    condInfoJson.getJSONObject("26").put("unit", (null == mstMedicine.getUnit()) ? JSONObject.NULL : mstMedicine.getUnit());
                    condInfoJson.getJSONObject("27").put("unit", (null == mstMedicine.getUnit()) ? JSONObject.NULL : mstMedicine.getUnit()+"/h");
                    condInfoJson.getJSONObject("28").put("unit", (null == mstMedicine.getUnit()) ? JSONObject.NULL : mstMedicine.getUnit());
                  }else if (!jsonNodeIsNull(condInfoJson.getJSONObject(key).get("medicine_type")) && "2".equals(condInfoJson.getJSONObject(key).get("medicine_type").toString())) {
                    MstMedicineMix mstMedicineMix = mstMedicineMixDao.selectByCdNoDel(bodyData.getFacility_cd(), Integer.parseInt(condInfoItem.getValue()));
                    condInfoJson.getJSONObject(key).put("value_name_1", (null == mstMedicineMix.getMedicineMixName()) ? JSONObject.NULL : mstMedicineMix.getMedicineMixName());
                    condInfoJson.getJSONObject(key).put("unit", (null == mstMedicineMix.getUnit()) ? JSONObject.NULL : mstMedicineMix.getUnit());
                    condInfoJson.getJSONObject("26").put("unit", (null == mstMedicineMix.getUnit()) ? JSONObject.NULL : mstMedicineMix.getUnit());
                    condInfoJson.getJSONObject("27").put("unit", (null == mstMedicineMix.getUnit()) ? JSONObject.NULL : mstMedicineMix.getUnit()+"/h");
                    condInfoJson.getJSONObject("28").put("unit", (null == mstMedicineMix.getUnit()) ? JSONObject.NULL : mstMedicineMix.getUnit());
                  }
                }
                break;
              case 30:
              case 34: // IPワンショットスタート
                if (condInfoJson.has(key) && !condInfoJson.getJSONObject(key).isNull("value")) {
                  Gson gson = new Gson();
                  CondInfoItem condInfoItem = gson.fromJson(condInfoJson.get(key).toString(), CondInfoItem.class);
                  if ("0".equals(condInfoItem.getValue())) {
                    condInfoJson.getJSONObject(key).put("value_name_1", "手動");
                  }else if("1".equals(condInfoItem.getValue())) {
                    condInfoJson.getJSONObject(key).put("value_name_1", "自動");
                  }
                }
                break;
              case 35:
              case 37:
                if (condInfoJson.has(key) && !condInfoJson.getJSONObject(key).isNull("value")) {
                  Gson gson = new Gson();
                  CondInfoItem condInfoItem = gson.fromJson(condInfoJson.get(key).toString(), CondInfoItem.class);
                  if ("0".equals(condInfoItem.getValue())) {
                    condInfoJson.getJSONObject(key).put("value_name_1", "切");
                  }else if("1".equals(condInfoItem.getValue())) {
                    condInfoJson.getJSONObject(key).put("value_name_1", "入");
                  }
                }
                break;
              case 31:
                if (condInfoJson.has(key)) {
                  condInfoJson.getJSONObject(key).put("unit", "mL");
                }
                break;
              case 32:
              case 33:
                if (condInfoJson.has(key)) {
                  condInfoJson.getJSONObject(key).put("unit", "mL/h");
                }
                break;
              case 36:
              case 38:
                if (condInfoJson.has(key)) {
                  condInfoJson.getJSONObject(key).put("unit", "分前");
                }
                break;
            }
          }
          ordMainDemo.setIndTreatmentName(Objects.isNull(selectedTreat) ? null : selectedTreat.getTreatmentName());
          /* add by chamaojia 2025-02-26 [11471] 【ind_device_mode】 value change supplement --start */
          ordMainDemo.setIndDeviceMode(Objects.isNull(selectedTreat) ? null : selectedTreat.getDeviceMode());
          /* add by chamaojia 2025-02-26 [11471] 【ind_device_mode】 value change supplement --end */
          ordMainDemo.setIndCondInfo(condInfoJson.toString());
        }
        JSONObject rstCondInfoJson = condInfoJson;
        JSONObject jsonCondItem = new JSONObject();

        for (String key : rstCondInfoJson.keySet()) {
          jsonCondItem = (JSONObject) rstCondInfoJson.get(key);
          jsonCondItem.remove("ind_user_id");
          jsonCondItem.remove("ind_user_last_name");
          jsonCondItem.remove("ind_user_first_name");
          jsonCondItem.remove("upd_user_id");
          jsonCondItem.remove("upd_user_last_name");
          jsonCondItem.remove("upd_user_first_name");
        }
        if ("true".equals(bodyData.getRst_flag())) {
          ordMainDemo.setRstCondInfo(rstCondInfoJson.toString());
        }

        // 実績：医療材料情報
        /* #10757 mod コンバートされた治療方法セットで指示が作成できない 2024-06-26 卓 start */
        // String buf = listMstTreatSet.get(0).getIndCondInfo();
        // buf = listMstTreatSet.get(0).getIndEquipInfo();
        String buf = ObjectUtils.isEmpty(listMstTreatSet.get(0).getIndEquipInfo())? "[]" : listMstTreatSet.get(0).getIndEquipInfo();
        /* #10757 mod コンバートされた治療方法セットで指示が作成できない 2024-06-26 卓 end */
        JSONArray setEquip = new JSONArray(buf);
        JSONArray equipInfoJson = new JSONArray();

        for (int i = 0; i < setEquip.length(); i++) {
          JSONObject obj = setEquip.getJSONObject(i);
          Integer cd = null;
          String needleType = null;
          String amount = null;
          String unitValue = null;
          String name = null;
          Double classType = null;
          String className = null;
          Integer classCd = null;
          String modelNumber = null;
          String shortName = null;
          int equipType = obj.optInt("equip_type");
          if (null != obj) {
            int equipCode = obj.optInt("cd");

            String isDisp;
            if (equipType == 0) {
              isDisp = mstEquipments.stream().filter(
                e -> e.getEquipmentCd().equals(equipCode)
              ).findFirst().orElse(new MstEquipment()).getIsDisp();
              unitValue = mstEquipments.stream().filter(
                e -> e.getEquipmentCd().equals(equipCode)
              ).findFirst().orElse(new MstEquipment()).getUnit();
              shortName = mstEquipments.stream().filter(
                e -> e.getEquipmentCd().equals(equipCode)
              ).findFirst().orElse(new MstEquipment()).getEquipmentShortName();
              if (selectOrdNo != null && !"0".equals(ordMainList.get(0).getRstDialysisState())) {
                name = mstEquipments.stream().filter(
                  e -> e.getEquipmentCd().equals(equipCode)
                ).findFirst().orElse(new MstEquipment()).getEquipmentName();
                classCd = mstEquipments.stream().filter(
                  e -> e.getEquipmentCd().equals(equipCode)
                ).findFirst().orElse(new MstEquipment()).getClassCd();

                if(classCd != null) {
                  MstEquipmentClass equipmentClass = mstEquipClassDao.selectByCd(classCd);
                  if (equipmentClass != null) {
                    classType = equipmentClass.getClassType();
                    className = equipmentClass.getClassName();
                  }
                }
              }
            } else {
              isDisp = mstDialyzers.stream().filter(
                d -> d.getDialyzerCd().equals(equipCode)
              ).findFirst().orElse(new MstDialyzer()).getIsDisp();
              modelNumber = mstDialyzers.stream().filter(
                d -> d.getDialyzerCd().equals(equipCode)
              ).findFirst().orElse(new MstDialyzer()).getModelNumber();
            }
            if (! obj.isNull("cd")) cd = (int) obj.get("cd");
            if (! obj.isNull("needle_type"))
              needleType = obj.get("needle_type").toString();
            if (! obj.isNull("amount") && ("1".equals(isDisp)))
              amount = String.valueOf(obj.getInt("amount"));
          }

          JSONObject bufJson = new JSONObject();
          // 医療材料コード
          bufJson.put("cd", (null == cd) ? JSONObject.NULL : cd);
          // 医療材料名
          bufJson.put("name", JSONObject.NULL);
          // 穿刺針区分
          // del #11586 治療記録＞医療材料にてダイアライザを追加すると保存できない。 関 start
          // bufJson.put("needle_type", (null == needleType) ? JSONObject.NULL : needleType);
          // del #11586 治療記録＞医療材料にてダイアライザを追加すると保存できない。 関 end
          // 数量
          bufJson.put("amount", (null == amount) ? JSONObject.NULL : amount);
          // 登録区分
          bufJson.put("input_class", 1);
          // 編集可否フラグ
          bufJson.put("is_editable", "1");
          // 連携オーダ番号
          bufJson.put("cop_order_no", JSONObject.NULL);
          // 医療材料区分
          bufJson.put("equip_type", equipType);
          // 実績医療材料
          if (equipType == 0) {
            bufJson.put("name",  (null == name) ? JSONObject.NULL : name);
            bufJson.put("class_cd",  (null == classCd) ? JSONObject.NULL : classCd);
            bufJson.put("class_type",  (null == classType) ? JSONObject.NULL : classType);
            bufJson.put("class_name",  (null == className) ? JSONObject.NULL : className);
            // 単位
            bufJson.put("unit", (null == unitValue) ? JSONObject.NULL : unitValue);
            // 省略医療材料名
            bufJson.put("short_name", (null == shortName) ? JSONObject.NULL : shortName);
          } else if (equipType == 1) {
            bufJson.put("name",  (null == modelNumber) ? JSONObject.NULL : modelNumber);
            // add #11586 治療記録＞医療材料にてダイアライザを追加すると保存できない。 関 start
            bufJson.put("class_cd", JSONObject.NULL);
            bufJson.put("class_type", JSONObject.NULL);
            bufJson.put("class_name", JSONObject.NULL);
            // 単位
            bufJson.put("unit", "本");
            // 省略医療材料名
            bufJson.put("short_name",  (null == modelNumber) ? JSONObject.NULL : modelNumber);
            // add #11586 治療記録＞医療材料にてダイアライザを追加すると保存できない。 関 end
          }

          equipInfoJson.put(bufJson);
        }
        if ("true".equals(bodyData.getRst_flag())) {
          ordMainDemo.setRstEquipInfo(equipInfoJson.toString());
        }

        JSONArray indEquipInfo = equipInfoJson;
        JSONObject jsonEquipItem = new JSONObject();

        for (Object key : indEquipInfo) {
          jsonEquipItem = (JSONObject) key;
          jsonEquipItem.put("ind_user_id", bodyData.getInd_user_id());
          jsonEquipItem.put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          jsonEquipItem.put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          jsonEquipItem.put("upd_user_id", bodyData.getUpd_user_id());
          jsonEquipItem.put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          jsonEquipItem.put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
        }
        if (!"0".equals(ordMainList.get(0).getRstDialysisState())) {
          ordMainDemo.setIndEquipInfo(indEquipInfo.toString());
        }

        // 投与薬剤情報、指示コメント情報
        if (1 == selectMethod) {

          // 実績：投与薬剤情報
          if (!"0".equals(ordMainList.get(0).getRstDialysisState())) {
            JSONArray mediInfoJson = new JSONArray();

            OrdMain selectOrdMain = ordMainAllList.get(0);
            /* mod by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --start */
            //JSONArray beforeMediInfo = new JSONArray(selectOrdMain.getRstMediInfo());
            JSONArray beforeMediInfo = new JSONArray(ObjectUtils.isEmpty(selectOrdMain.getRstMediInfo())? "[]" : selectOrdMain.getRstMediInfo());
            /* mod by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --end */
            JSONObject jsonObjectItem = null;
            StringBuffer mapKey = null;
            List<String> hasMediInfo = new ArrayList<>();
            List<JSONObject> hasMediInfoJson = new ArrayList<>();
            Long noTmp = maxMediInfoNo;
            Integer dateInterval = null;
            String initDate = bodyData.getStart_date().replaceAll("-", "");

            // 薬剤マスタ
            MstMedicine paramMedicine = new MstMedicine();
            paramMedicine.setFacilityCd(facilityCd);
            List<MstMedicine> lstMstMedicine = mstMedicineDao.selectAllDel(selectOptions, paramMedicine);
            // 調製薬剤マスタ
            MstMedicineMix paramMedicineMix = new MstMedicineMix();
            paramMedicineMix.setFacilityCd(facilityCd);
            List<MstMedicineMix> lstMstMedicineMix = mstMedicineMixDao.selectMstMedicineMixAllergyData(selectOptions, paramMedicineMix);
            // 薬剤分類マスタ
            MstMedicineClass paramMedicineClass = new MstMedicineClass();
            paramMedicineClass.setFacilityCd(facilityCd);
            List<MstMedicineClass>  lstMstMedicineClass = mstMedicineClassDao.selectAll(selectOptions, paramMedicineClass);
            // 投与タイミング
            MstMedicateTiming paramMstMedicateTiming = new MstMedicateTiming();
            paramMstMedicateTiming.setFacilityCd(facilityCd);
            List<MstMedicateTiming>  lstMstMedicateTiming = mstMedicateTimingDao.selectAllIncludeDeleted(selectOptions, paramMstMedicateTiming);
            // 手技マスタ
            MstProcedure paramMstProcedure = new MstProcedure();
            paramMstProcedure.setFacilityCd(facilityCd);
            List<MstProcedure> lstMstProcedure = mstProcedureDao.selectAllIncludeDeleted(selectOptions, paramMstProcedure);

            for (Object jsonItem : beforeMediInfo) {
              jsonObjectItem = (JSONObject) jsonItem;
              if (jsonObjectItem.has("effect_flg") && "1".equals(jsonObjectItem.get("effect_flg").toString())) {
                hasMediInfoJson.add(jsonObjectItem);
                mapKey = new StringBuffer();
                mapKey.append(jsonObjectItem.has("cd") ? jsonObjectItem.get("cd") : "").append(",");
                mapKey.append(jsonObjectItem.has("medicine_type") ? jsonObjectItem.get("medicine_type") : "").append(",");
                mapKey.append(jsonObjectItem.has("amount") ? jsonObjectItem.get("amount") : "").append(",");
                mapKey.append(jsonObjectItem.has("procedure_cd") ? jsonObjectItem.get("procedure_cd") : "").append(",");
                mapKey.append(jsonObjectItem.has("timing_cd") ? jsonObjectItem.get("timing_cd") : "");
                hasMediInfo.add(mapKey.toString());
              }
            }
            /* #10757 mod コンバートされた治療方法セットで指示が作成できない 2024-06-26 卓 start */
            // JSONArray afterMediInfo = new JSONArray(listMstTreatSet.get(0).getIndMediInfo());
            JSONArray afterMediInfo = new JSONArray( ObjectUtils.isEmpty(listMstTreatSet.get(0).getIndMediInfo())? "[]" : listMstTreatSet.get(0).getIndMediInfo());
            /* #10757 mod コンバートされた治療方法セットで指示が作成できない 2024-06-26 卓 end */
            for (Object jsonItem : afterMediInfo) {
              jsonObjectItem = (JSONObject) jsonItem;
              mapKey = new StringBuffer();
              mapKey.append(jsonObjectItem.has("cd") ? jsonObjectItem.get("cd") : "").append(",");
              mapKey.append(jsonObjectItem.has("medicine_type") ? jsonObjectItem.get("medicine_type") : "").append(",");
              mapKey.append(jsonObjectItem.has("amount") ? jsonObjectItem.get("amount") : "").append(",");
              mapKey.append(jsonObjectItem.has("procedure_cd") ? jsonObjectItem.get("procedure_cd") : "").append(",");
              mapKey.append(jsonObjectItem.has("timing_cd") ? jsonObjectItem.get("timing_cd") : "");
              if (hasMediInfo.contains(mapKey.toString())) {
                int index = hasMediInfo.indexOf(mapKey.toString());
                JSONObject jsonObject = hasMediInfoJson.get(index);
                jsonObject.put("no", noTmp);
                noTmp++;
                mediInfoJson.put(jsonObject);
                hasMediInfoJson.remove(index);
                hasMediInfo.remove(index);
              } else {
                int medicineCd = Integer.parseInt(jsonObjectItem.get("cd").toString());
                Integer medicineType = Integer.parseInt(jsonObjectItem.get("medicine_type").toString());
                if (MEDICINE_TYPE_NORMAL.equals(medicineType)) {
                  MstMedicine mstMedicine = lstMstMedicine.stream().filter(
                    d -> d.getMedicineCd().equals(medicineCd)
                  ).findFirst().orElse(new MstMedicine());
                  dateInterval = 0;
                  jsonObjectItem.put("name", (null == mstMedicine.getMedicineName()) ? JSONObject.NULL : mstMedicine.getMedicineName());
                  jsonObjectItem.put("unit", (null == mstMedicine.getUnit()) ? JSONObject.NULL : mstMedicine.getUnit());
                  jsonObjectItem.put("class_cd", (null == mstMedicine.getClassCd()) ? JSONObject.NULL : mstMedicine.getClassCd());
                  jsonObjectItem.put("short_name", (null == mstMedicine.getMedicineShortName()) ? JSONObject.NULL : mstMedicine.getMedicineShortName());
                  jsonObjectItem.put("comment", jsonObjectItem.isNull("medicine_comment") ? JSONObject.NULL : jsonObjectItem.get("medicine_comment"));
                  jsonObjectItem.remove("medicine_comment");
                  if (!jsonObjectItem.isNull("timing_cd")) {
                    int timingCd = Integer.parseInt(jsonObjectItem.get("timing_cd").toString());
                    if (!"null".equals(timingCd)) {
                      MstMedicateTiming mstMedicateTiming = lstMstMedicateTiming.stream().filter(
                        d -> d.getMedicateTimingCd().equals(timingCd)
                      ).findFirst().orElse(new MstMedicateTiming());

                      jsonObjectItem.put("timing_name", (null == mstMedicateTiming.getMedicateTimingName()) ? JSONObject.NULL : mstMedicateTiming.getMedicateTimingName());
                    }
                  }
                  if (!jsonObjectItem.isNull("procedure_cd")) {
                    int procedureCd = Integer.parseInt(jsonObjectItem.get("procedure_cd").toString());

                    if (!"null".equals(procedureCd)) {

                      MstProcedure mstProcedure = lstMstProcedure.stream().filter(
                        d -> d.getProcedureCd().equals(procedureCd)
                      ).findFirst().orElse(new MstProcedure());

                      jsonObjectItem.put("procedure_name", (null == mstProcedure.getPricedureName()) ? JSONObject.NULL : mstProcedure.getPricedureName());
                    }
                  }

                  if (!"null".equals(mstMedicine.getClassCd())) {
                    MstMedicineClass mstMedicineClass = lstMstMedicineClass.stream().filter(
                      d -> d.getClassCd().equals(mstMedicine.getClassCd())
                    ).findFirst().orElse(new MstMedicineClass());

                    jsonObjectItem.put("class_type", (null == mstMedicineClass.getClassType()) ? JSONObject.NULL : mstMedicineClass.getClassType());
                    jsonObjectItem.put("class_name", (null == mstMedicineClass.getClassName()) ? JSONObject.NULL : mstMedicineClass.getClassName());
                  }

                  jsonObjectItem.put("effect_flg", 0);
                  jsonObjectItem.put("effect_date", JSONObject.NULL);
                  jsonObjectItem.put("effect_user_id", JSONObject.NULL);
                  jsonObjectItem.put("effect_user_last_name", JSONObject.NULL);
                  jsonObjectItem.put("effect_user_first_name", JSONObject.NULL);
                  jsonObjectItem.put("init_date",  (null == initDate) ? JSONObject.NULL : initDate);
                  // 登録区分
                  jsonObjectItem.put("input_class", 1);
                  // 編集可否フラグ
                  jsonObjectItem.put("is_editable", "1");
                  // 連携オーダ番号
                  jsonObjectItem.put("cop_order_no", JSONObject.NULL);
                  // 投与間隔
                  jsonObjectItem.put("date_interval", (null == dateInterval) ? JSONObject.NULL : dateInterval);

                  jsonObjectItem.put("no", noTmp);
                  noTmp++;
                  mediInfoJson.put(jsonObjectItem);
                }else {
                  MstMedicineMix mstMedicineMix = lstMstMedicineMix.stream().filter(
                    d -> d.getMedicineMixCd().equals(medicineCd)
                  ).findFirst().orElse(new MstMedicineMix());
                  dateInterval = 0;
                  jsonObjectItem.put("name", (null == mstMedicineMix.getMedicineMixName()) ? JSONObject.NULL : mstMedicineMix.getMedicineMixName());
                  jsonObjectItem.put("unit", (null == mstMedicineMix.getUnit()) ? JSONObject.NULL : mstMedicineMix.getUnit() );
                  jsonObjectItem.put("class_cd", (null == mstMedicineMix.getClassCd()) ? JSONObject.NULL : mstMedicineMix.getClassCd());
                  jsonObjectItem.put("short_name", (null == mstMedicineMix.getMedicineMixShortName()) ? JSONObject.NULL : mstMedicineMix.getMedicineMixShortName());
                  jsonObjectItem.put("comment",jsonObjectItem.get("medicine_comment"));
                  jsonObjectItem.remove("medicine_comment");

                  if (!"null".equals(mstMedicineMix.getClassCd())) {
                    MstMedicineClass mstMedicineClass = lstMstMedicineClass.stream().filter(
                      d -> d.getClassCd().equals(mstMedicineMix.getClassCd())
                    ).findFirst().orElse(new MstMedicineClass());

                    jsonObjectItem.put("class_type", (null == mstMedicineClass.getClassType()) ? JSONObject.NULL : mstMedicineClass.getClassType());
                    jsonObjectItem.put("class_name", (null == mstMedicineClass.getClassName()) ? JSONObject.NULL : mstMedicineClass.getClassName());
                  }

                  if (!jsonObjectItem.isNull("timing_cd")) {
                    int timingCd = Integer.parseInt(jsonObjectItem.get("timing_cd").toString());
                    if (!"null".equals(timingCd)) {
                      MstMedicateTiming mstMedicateTiming = lstMstMedicateTiming.stream().filter(
                        d -> d.getMedicateTimingCd().equals(timingCd)
                      ).findFirst().orElse(new MstMedicateTiming());

                      jsonObjectItem.put("timing_name", (null == mstMedicateTiming.getMedicateTimingName()) ? JSONObject.NULL : mstMedicateTiming.getMedicateTimingName());
                    }
                  }

                  if (!jsonObjectItem.isNull("procedure_cd")) {
                    int procedureCd = Integer.parseInt(jsonObjectItem.get("procedure_cd").toString());

                    if (!"null".equals(procedureCd)) {

                      MstProcedure mstProcedure = lstMstProcedure.stream().filter(
                        d -> d.getProcedureCd().equals(procedureCd)
                      ).findFirst().orElse(new MstProcedure());

                      jsonObjectItem.put("procedure_name", (null == mstProcedure.getPricedureName()) ? JSONObject.NULL : mstProcedure.getPricedureName());
                    }
                  }
                  jsonObjectItem.put("effect_flg", 0);
                  jsonObjectItem.put("effect_date", JSONObject.NULL);
                  jsonObjectItem.put("effect_user_id", JSONObject.NULL);
                  jsonObjectItem.put("effect_user_last_name", JSONObject.NULL);
                  jsonObjectItem.put("effect_user_first_name", JSONObject.NULL);
                  jsonObjectItem.put("init_date",  (null == initDate) ? JSONObject.NULL : initDate);
                  // 登録区分
                  jsonObjectItem.put("input_class", 1);
                  // 編集可否フラグ
                  jsonObjectItem.put("is_editable", "1");
                  // 連携オーダ番号
                  jsonObjectItem.put("cop_order_no", JSONObject.NULL);
                  // 投与間隔
                  jsonObjectItem.put("date_interval", (null == dateInterval) ? JSONObject.NULL : dateInterval);

                  jsonObjectItem.put("no", noTmp);
                  noTmp++;
                  mediInfoJson.put(jsonObjectItem);
                }
              }
            }
            for(JSONObject item : hasMediInfoJson) {
              item.put("no", noTmp);
              noTmp++;
              mediInfoJson.put(item);
            }
            if ("true".equals(bodyData.getRst_flag())) {
              JSONArray commInfoJson = new JSONArray();
              /* #10757 mod コンバートされた治療方法セットで指示が作成できない 2024-06-26 卓 start */
              // buf = listMstTreatSet.get(0).getIndIndCommentInfo();
              buf = ObjectUtils.isEmpty(listMstTreatSet.get(0).getIndIndCommentInfo())? "[]" : listMstTreatSet.get(0).getIndIndCommentInfo();
              /* #10757 mod コンバートされた治療方法セットで指示が作成できない 2024-06-26 卓 end */
              JSONArray setComment = new JSONArray(buf);
              for (int i = 0; i < setComment.length(); i++) {
                JSONObject obj = setComment.getJSONObject(i);
                Integer no = null;
                String content = null;

                if (null != obj) {
                  if (!obj.isNull("no")) no = (int) obj.get("no");
                  if (!obj.isNull("content"))
                    content = obj.get("content").toString();
                }

                JSONObject bufJson = new JSONObject();
                // 指示コメント番号
                bufJson.put("no", (null == no) ? JSONObject.NULL : no);
                // 内容
                bufJson.put("content", (null == content) ? JSONObject.NULL : content);
                // 登録区分
                bufJson.put("input_class", 1);
                // 編集可否フラグ
                bufJson.put("is_editable", "1");
                // 連携オーダ番号
                bufJson.put("cop_order_no", JSONObject.NULL);

                commInfoJson.put(bufJson);
              }

              ordMainDemo.setRstIndCommentInfo(commInfoJson.toString());
              ordMainDemo.setRstMediInfo(mediInfoJson.toString());
            }
          }
        }
        if ("true".equals(bodyData.getRst_flag())) {
          ordMainDemo.setRstTreatmentName(Objects.isNull(selectedTreat) ? null : selectedTreat.getTreatmentName());
          ordMainDemo.setRstTreatmentCd(targetTreatmentCd);
          /* add by chamaojia 2025-02-26 [11471] 【rst_device_mode】 value change supplement --start */
          ordMainDemo.setRstDeviceMode(Objects.isNull(selectedTreat) ? null : selectedTreat.getDeviceMode());
          /* add by chamaojia 2025-02-26 [11471] 【rst_device_mode】 value change supplement --end */
          ordMainDemo.setRstIsUpdateEdition("1");
//          ordMaterialSaveService.updateOrdMaterialSave(new OrdMaterialSaveDto(
//            ordMainAllList.get(0).getOrdNo(),
//            true,
//            true,
//            true,
//            false,
//            "2"
//          ));
          // add #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 start
          patIndApproveDao.updateContentChangeSingleByOrdNoList(ordNoList);
          // add #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 end
        }
        // add #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 start
        else {
          patIndApproveDao.updateAppContentChangeSingleByOrdNoList(ordNoList);
        }
        // add #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 end
        ordMainDemo.setUpDate(new Timestamp(System.currentTimeMillis()));
        updCount = ordMainDao.updateByTreatmentCdIndRst(targetTreatmentCd, ordMainDemo, ordNoList, bodyData.getInd_user_id(), ntssUser.getUserId());
      } else {
        OrdMain selectOrdMain = ordMainAllList.get(0);
        JSONObject indCondInfo = null == selectOrdMain.getIndCondInfo() ?
          new JSONObject() :
          new JSONObject(selectOrdMain.getIndCondInfo());
        JSONObject indDeviceSetInfo = null == selectOrdMain.getIndDeviceSetInfo() ?
          new JSONObject() :
          new JSONObject(selectOrdMain.getIndDeviceSetInfo());
        if (!"0".equals(ordMainList.get(0).getRstDialysisState())) {
          for (int i = 1; i <= 38; i++) {
            String key = Integer.toString(i);
            Boolean isUse = this.checkTreatCondIsUse(treatCondSetting, key);
            // is_useは1であり、かつ変更前の治療条件にこのkeyは存在せず、追加
            if (isUse && !indCondInfo.has(String.valueOf(i))) {
              JSONObject bufJson = this.editRstJson(bodyData, user);

              indCondInfo.put(key, bufJson);
              switch (i) {
                case 1:
                  if (indCondInfo.has(key)) {
                    indCondInfo.getJSONObject(key).put("unit", "分");
                  }
                  break;
                case 3:
                  if (indCondInfo.has(key)) {
                    indCondInfo.getJSONObject(key).put("unit", "Kg");
                  }
                  break;
                case 4:
                case 20:
                  if (indCondInfo.has(key)) {
                    indCondInfo.getJSONObject(key).put("unit", "L");
                  }
                  break;
                case 5:
                  if (indCondInfo.has(key)) {
                    indCondInfo.getJSONObject(key).put("unit", "本");
                  }
                  break;
                case 14:
                case 16:
                  if (indCondInfo.has(key)) {
                    indCondInfo.getJSONObject(key).put("unit", "mL/min");
                  }
                  break;
                case 15:
                case 19:
                case 25:
                  if (indCondInfo.has(key) && indCondInfo.getJSONObject(key).isNull("value")) {
                    // 薬剤区分
                    indCondInfo.getJSONObject(key).put("medicine_type", JSONObject.NULL);
                  }
                  break;
                case 18:
                case 23:
                  if (indCondInfo.has(key)) {
                    indCondInfo.getJSONObject(key).put("unit", "℃");
                  }
                  break;
                case 24:
                  if (indCondInfo.has(key)) {
                    indCondInfo.getJSONObject(key).put("unit", "L/h");
                  }
                  break;
                case 31:
                  if (indCondInfo.has(key)) {
                    indCondInfo.getJSONObject(key).put("unit", "mL");
                  }
                  break;
                case 32:
                case 33:
                  if (indCondInfo.has(key)) {
                    indCondInfo.getJSONObject(key).put("unit", "mL/h");
                  }
                  break;
                case 36:
                case 38:
                  if (indCondInfo.has(key)) {
                    indCondInfo.getJSONObject(key).put("unit", "分前");
                  }
                  break;
              }
              // 指示者コード
              indCondInfo.getJSONObject(key).put("ind_user_id", bodyData.getInd_user_id());
              // 指示者名_姓
              indCondInfo.getJSONObject(key).put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
              // 指示者名_名
              indCondInfo.getJSONObject(key).put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
              // 更新者コード
              indCondInfo.getJSONObject(key).put("upd_user_id", bodyData.getUpd_user_id());
              // 更新者名_姓
              indCondInfo.getJSONObject(key).put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
              // 更新者名_名
              indCondInfo.getJSONObject(key).put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
              // is_useは0であり、変更前の治療条件にこのkeyが存在し、削除
            } else if (!isUse && indCondInfo.has(String.valueOf(i))) {
              indCondInfo.remove(String.valueOf(i));
            }
          }
          ordMainDemo.setIndTreatmentName(Objects.isNull(selectedTreat) ? null : selectedTreat.getTreatmentName());
          /* add by chamaojia 2025-02-26 [11471] 【ind_device_mode】 value change supplement --start */
          ordMainDemo.setIndDeviceMode(Objects.isNull(selectedTreat) ? null : selectedTreat.getDeviceMode());
          /* add by chamaojia 2025-02-26 [11471] 【ind_device_mode】 value change supplement --end */
          ordMainDemo.setIndCondInfo(indCondInfo.toString());
        }else{
          for (int i = 1; i <= 38; i++) {
            String key = Integer.toString(i);
            Boolean isUse = this.checkTreatCondIsUse(treatCondSetting, key);
            // is_useは1であり、かつ変更前の治療条件にこのkeyは存在せず、追加
            if (isUse && !indCondInfo.has(String.valueOf(i))) {
              JSONObject bufJson = this.editIndJson(bodyData, user, updUser);
              // add #12472 治療方法の変更で補液なし治療からオンライン補液あり治療に、「治療方法のみ」で変更するとpat_treatment_patternに欠損データが発生する。 関 start
              if ("12".equals(key) && isUse) {
                bufJson.put("value", "0");
              }
              if ("19".equals(key) && isUse) {
                bufJson.put("medicine_type", JSONObject.NULL);
              }
              if ("20".equals(key) && isUse) {
                bufJson.put("value", "0.0");
              }
              if ("21".equals(key) && isUse) {
                bufJson.put("value", "1");
              }
              if ("22".equals(key) && isUse) {
                bufJson.put("value", "0");
              }
              if ("23".equals(key) && isUse) {
                bufJson.put("value", "36.0");
              }
              if ("24".equals(key) && isUse) {
                bufJson.put("value", "0.00");
              }
              // add #12472 治療方法の変更で補液なし治療からオンライン補液あり治療に、「治療方法のみ」で変更するとpat_treatment_patternに欠損データが発生する。 関 end
              indCondInfo.put(key, bufJson);
              // is_useは0であり、変更前の治療条件にこのkeyが存在し、削除
            } else if (!isUse && indCondInfo.has(String.valueOf(i))) {
              indCondInfo.remove(String.valueOf(i));
            }
          }
        }
        if (DeviceMode.I_HDF.equals(selectedTreat.getDeviceMode()) || DeviceMode.AFBF.equals(selectedTreat.getDeviceMode())) {
          if (indCondInfo.has("12")) {
            indCondInfo.getJSONObject("12").put("value", "0");
            // 指示者コード
            indCondInfo.getJSONObject("12").put("ind_user_id", bodyData.getInd_user_id());
            // 指示者名_姓
            indCondInfo.getJSONObject("12").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
            // 指示者名_名
            indCondInfo.getJSONObject("12").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
            // 更新者コード
            indCondInfo.getJSONObject("12").put("upd_user_id", bodyData.getUpd_user_id());
            // 更新者名_姓
            indCondInfo.getJSONObject("12").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
            // 更新者名_名
            indCondInfo.getJSONObject("12").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
          }
        }
        // mod 11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) 関 start
        /*if ("0".equals(indCondInfo.getJSONObject("12").get("value"))) {
          indCondInfo.remove("11");
        }else if ("1".equals(indCondInfo.getJSONObject("12").get("value"))) {
          indCondInfo.remove("9");
          indCondInfo.remove("10");
        }*/
        if (indCondInfo.has("12") && "0".equals(indCondInfo.getJSONObject("12").get("value"))) {
          indCondInfo.remove("11");
        }else if (indCondInfo.has("12") && "1".equals(indCondInfo.getJSONObject("12").get("value"))) {
          indCondInfo.remove("9");
          indCondInfo.remove("10");
        }
        // mod 11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) 関 end
        if (DeviceMode.OHDF.equals(selectedTreat.getDeviceMode()) || DeviceMode.OHF.equals(selectedTreat.getDeviceMode())
          || DeviceMode.I_HDF.equals(selectedTreat.getDeviceMode())) {
          if (indCondInfo.getJSONObject("15").has("value")
            && !indCondInfo.getJSONObject("15").isNull("value")
            && !indCondInfo.getJSONObject("15").get("value").equals(indCondInfo.getJSONObject("19").get("value"))) {
            indCondInfo.getJSONObject("19").put("value",indCondInfo.getJSONObject("15").get("value"));
            indCondInfo.getJSONObject("19").put("medicine_type",indCondInfo.getJSONObject("15").get("medicine_type") != null ? indCondInfo.getJSONObject("15").get("medicine_type") : JSONObject.NULL);
            // 指示者コード
            indCondInfo.getJSONObject("19").put("ind_user_id", bodyData.getInd_user_id());
            // 指示者名_姓
            indCondInfo.getJSONObject("19").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
            // 指示者名_名
            indCondInfo.getJSONObject("19").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
            // 更新者コード
            indCondInfo.getJSONObject("19").put("upd_user_id", bodyData.getUpd_user_id());
            // 更新者名_姓
            indCondInfo.getJSONObject("19").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
            // 更新者名_名
            indCondInfo.getJSONObject("19").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
            if (!"0".equals(ordMainList.get(0).getRstDialysisState())) {
              // マスタ情報取得
              MstMedicine mstMedicine = mstMedicineDao.selectAllByMediCd(Integer.parseInt(indCondInfo.getJSONObject("19").get("value").toString()));
              indCondInfo.getJSONObject("19").put("value_name_1", (null == mstMedicine.getMedicineName()) ? JSONObject.NULL : mstMedicine.getMedicineName());
            }

            indCondInfo.getJSONObject("20").put("value", "0");
            // 指示者コード
            indCondInfo.getJSONObject("20").put("ind_user_id", bodyData.getInd_user_id());
            // 指示者名_姓
            indCondInfo.getJSONObject("20").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
            // 指示者名_名
            indCondInfo.getJSONObject("20").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
            // 更新者コード
            indCondInfo.getJSONObject("20").put("upd_user_id", bodyData.getUpd_user_id());
            // 更新者名_姓
            indCondInfo.getJSONObject("20").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
            // 更新者名_名
            indCondInfo.getJSONObject("20").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

            indCondInfo.getJSONObject("21").put("value", "1");
            // 指示者コード
            indCondInfo.getJSONObject("21").put("ind_user_id", bodyData.getInd_user_id());
            // 指示者名_姓
            indCondInfo.getJSONObject("21").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
            // 指示者名_名
            indCondInfo.getJSONObject("21").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
            // 更新者コード
            indCondInfo.getJSONObject("21").put("upd_user_id", bodyData.getUpd_user_id());
            // 更新者名_姓
            indCondInfo.getJSONObject("21").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
            // 更新者名_名
            indCondInfo.getJSONObject("21").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

            indCondInfo.getJSONObject("22").put("value", "0");
            // 指示者コード
            indCondInfo.getJSONObject("22").put("ind_user_id", bodyData.getInd_user_id());
            // 指示者名_姓
            indCondInfo.getJSONObject("22").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
            // 指示者名_名
            indCondInfo.getJSONObject("22").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
            // 更新者コード
            indCondInfo.getJSONObject("22").put("upd_user_id", bodyData.getUpd_user_id());
            // 更新者名_姓
            indCondInfo.getJSONObject("22").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
            // 更新者名_名
            indCondInfo.getJSONObject("22").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

            indCondInfo.getJSONObject("23").put("value", "36");
            // 指示者コード
            indCondInfo.getJSONObject("23").put("ind_user_id", bodyData.getInd_user_id());
            // 指示者名_姓
            indCondInfo.getJSONObject("23").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
            // 指示者名_名
            indCondInfo.getJSONObject("23").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
            // 更新者コード
            indCondInfo.getJSONObject("23").put("upd_user_id", bodyData.getUpd_user_id());
            // 更新者名_姓
            indCondInfo.getJSONObject("23").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
            // 更新者名_名
            indCondInfo.getJSONObject("23").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

            indCondInfo.getJSONObject("24").put("value", "0");
            // 指示者コード
            indCondInfo.getJSONObject("24").put("ind_user_id", bodyData.getInd_user_id());
            // 指示者名_姓
            indCondInfo.getJSONObject("24").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
            // 指示者名_名
            indCondInfo.getJSONObject("24").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
            // 更新者コード
            indCondInfo.getJSONObject("24").put("upd_user_id", bodyData.getUpd_user_id());
            // 更新者名_姓
            indCondInfo.getJSONObject("24").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
            // 更新者名_名
            indCondInfo.getJSONObject("24").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
          }
        }
        // del #12472 治療方法の変更で補液なし治療からオンライン補液あり治療に、「治療方法のみ」で変更するとpat_treatment_patternに欠損データが発生する。 関 start
        //        if (DeviceMode.AFBF.equals(selectedTreat.getDeviceMode())) {
        //          if (indCondInfo.has("15")) {
        //            indCondInfo.getJSONObject("15").put("value", JSONObject.NULL);
        //            // 指示者コード
        //            indCondInfo.getJSONObject("15").put("ind_user_id", bodyData.getInd_user_id());
        //            // 指示者名_姓
        //            indCondInfo.getJSONObject("15").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
        //            // 指示者名_名
        //            indCondInfo.getJSONObject("15").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
        //            // 更新者コード
        //            indCondInfo.getJSONObject("15").put("upd_user_id", bodyData.getUpd_user_id());
        //            // 更新者名_姓
        //            indCondInfo.getJSONObject("15").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
        //            // 更新者名_名
        //            indCondInfo.getJSONObject("15").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
        //          }
        //          if (indCondInfo.has("19")) {
        //            indCondInfo.getJSONObject("19").put("value", JSONObject.NULL);
        //            // 指示者コード
        //            indCondInfo.getJSONObject("19").put("ind_user_id", bodyData.getInd_user_id());
        //            // 指示者名_姓
        //            indCondInfo.getJSONObject("19").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
        //            // 指示者名_名
        //            indCondInfo.getJSONObject("19").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
        //            // 更新者コード
        //            indCondInfo.getJSONObject("19").put("upd_user_id", bodyData.getUpd_user_id());
        //            // 更新者名_姓
        //            indCondInfo.getJSONObject("19").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
        //            // 更新者名_名
        //            indCondInfo.getJSONObject("19").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
        //          }
        //        }
        // del #12472 治療方法の変更で補液なし治療からオンライン補液あり治療に、「治療方法のみ」で変更するとpat_treatment_patternに欠損データが発生する。 関 end
        // del #10154_#10183 zhao start
//        if (DeviceMode.I_HDF.equals(selectedTreat.getDeviceMode())) {
//          if (indCondInfo.has("5") && !indCondInfo.getJSONObject("5").isNull("value")) {
//            Set<Integer> dialyzerCds = new HashSet<>();
//            dialyzerCds.add(Integer.parseInt(indCondInfo.getJSONObject("5").get("value").toString()));
//            List<MstDialyzer> mstDialyzer = mstDialyzerDao.selectAllByCdList(SelectOptions.get(), new ArrayList<>(dialyzerCds));
//            if (!mstDialyzer.isEmpty() &&
//              "1".equals(mstDialyzer.get(0).getDialyzerType())
//            ) {
//              indCondInfo.getJSONObject("5").put("value", JSONObject.NULL);
//              // 指示者コード
//              indCondInfo.getJSONObject("5").put("ind_user_id", bodyData.getInd_user_id());
//              // 指示者名_姓
//              indCondInfo.getJSONObject("5").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
//              // 指示者名_名
//              indCondInfo.getJSONObject("5").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
//              // 更新者コード
//              indCondInfo.getJSONObject("5").put("upd_user_id", bodyData.getUpd_user_id());
//              // 更新者名_姓
//              indCondInfo.getJSONObject("5").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
//              // 更新者名_名
//              indCondInfo.getJSONObject("5").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
//            }
//          }
//        }
        // del #10154_#10183 zhao end
        ordMainDemo.setIndCondInfo(indCondInfo.toString());

        if (DeviceMode.HD.equals(selectedTreat.getDeviceMode())) {
          indDeviceSetInfo.getJSONObject("ihdf")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("432", "0");
          // 指示者コード
          indDeviceSetInfo.getJSONObject("ihdf").put("ind_user_id", bodyData.getInd_user_id());
          // 指示者名_姓
          indDeviceSetInfo.getJSONObject("ihdf").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          indDeviceSetInfo.getJSONObject("ihdf").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          indDeviceSetInfo.getJSONObject("ihdf").put("upd_user_id", bodyData.getUpd_user_id());
          // 更新者名_姓
          indDeviceSetInfo.getJSONObject("ihdf").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          indDeviceSetInfo.getJSONObject("ihdf").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
        }
        if (DeviceMode.ECUM.equals(selectedTreat.getDeviceMode())) {
          indDeviceSetInfo.getJSONObject("ihdf")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("432", "0");
          // 指示者コード
          indDeviceSetInfo.getJSONObject("ihdf").put("ind_user_id", bodyData.getInd_user_id());
          // 指示者名_姓
          indDeviceSetInfo.getJSONObject("ihdf").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          indDeviceSetInfo.getJSONObject("ihdf").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          indDeviceSetInfo.getJSONObject("ihdf").put("upd_user_id", bodyData.getUpd_user_id());
          // 更新者名_姓
          indDeviceSetInfo.getJSONObject("ihdf").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          indDeviceSetInfo.getJSONObject("ihdf").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
        }
        if (DeviceMode.HDF.equals(selectedTreat.getDeviceMode())) {
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("291", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("292", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("293", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("294", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("295", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("296", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("297", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("298", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("299", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("300", "0");
          // 指示者コード
          indDeviceSetInfo.getJSONObject("ufr").put("ind_user_id", bodyData.getInd_user_id());
          // 指示者名_姓
          indDeviceSetInfo.getJSONObject("ufr").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          indDeviceSetInfo.getJSONObject("ufr").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          indDeviceSetInfo.getJSONObject("ufr").put("upd_user_id", bodyData.getUpd_user_id());
          // 更新者名_姓
          indDeviceSetInfo.getJSONObject("ufr").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          indDeviceSetInfo.getJSONObject("ufr").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
          indDeviceSetInfo.getJSONObject("ihdf")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("432", "0");
          // 指示者コード
          indDeviceSetInfo.getJSONObject("ihdf").put("ind_user_id", bodyData.getInd_user_id());
          // 指示者名_姓
          indDeviceSetInfo.getJSONObject("ihdf").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          indDeviceSetInfo.getJSONObject("ihdf").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          indDeviceSetInfo.getJSONObject("ihdf").put("upd_user_id", bodyData.getUpd_user_id());
          // 更新者名_姓
          indDeviceSetInfo.getJSONObject("ihdf").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          indDeviceSetInfo.getJSONObject("ihdf").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
          indDeviceSetInfo.getJSONObject("dia")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("282", "0");
          // 指示者コード
          indDeviceSetInfo.getJSONObject("dia").put("ind_user_id", bodyData.getInd_user_id());
          // 指示者名_姓
          indDeviceSetInfo.getJSONObject("dia").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          indDeviceSetInfo.getJSONObject("dia").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          indDeviceSetInfo.getJSONObject("dia").put("upd_user_id", bodyData.getUpd_user_id());
          // 更新者名_姓
          indDeviceSetInfo.getJSONObject("dia").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          indDeviceSetInfo.getJSONObject("dia").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
        }
        if (DeviceMode.HF.equals(selectedTreat.getDeviceMode())) {
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("291", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("292", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("293", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("294", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("295", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("296", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("297", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("298", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("299", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("300", "0");
          // 指示者コード
          indDeviceSetInfo.getJSONObject("ufr").put("ind_user_id", bodyData.getInd_user_id());
          // 指示者名_姓
          indDeviceSetInfo.getJSONObject("ufr").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          indDeviceSetInfo.getJSONObject("ufr").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          indDeviceSetInfo.getJSONObject("ufr").put("upd_user_id", bodyData.getUpd_user_id());
          // 更新者名_姓
          indDeviceSetInfo.getJSONObject("ufr").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          indDeviceSetInfo.getJSONObject("ufr").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
          indDeviceSetInfo.getJSONObject("ihdf")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("432", "0");
          // 指示者コード
          indDeviceSetInfo.getJSONObject("ihdf").put("ind_user_id", bodyData.getInd_user_id());
          // 指示者名_姓
          indDeviceSetInfo.getJSONObject("ihdf").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          indDeviceSetInfo.getJSONObject("ihdf").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          indDeviceSetInfo.getJSONObject("ihdf").put("upd_user_id", bodyData.getUpd_user_id());
          // 更新者名_姓
          indDeviceSetInfo.getJSONObject("ihdf").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          indDeviceSetInfo.getJSONObject("ihdf").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
          indDeviceSetInfo.getJSONObject("dia")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("282", "0");
          // 指示者コード
          indDeviceSetInfo.getJSONObject("dia").put("ind_user_id", bodyData.getInd_user_id());
          // 指示者名_姓
          indDeviceSetInfo.getJSONObject("dia").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          indDeviceSetInfo.getJSONObject("dia").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          indDeviceSetInfo.getJSONObject("dia").put("upd_user_id", bodyData.getUpd_user_id());
          // 更新者名_姓
          indDeviceSetInfo.getJSONObject("dia").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          indDeviceSetInfo.getJSONObject("dia").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
        }
        if (DeviceMode.AFBF.equals(selectedTreat.getDeviceMode())) {
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("291", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("292", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("293", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("294", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("295", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("296", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("297", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("298", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("299", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("300", "0");
          // 指示者コード
          indDeviceSetInfo.getJSONObject("ufr").put("ind_user_id", bodyData.getInd_user_id());
          // 指示者名_姓
          indDeviceSetInfo.getJSONObject("ufr").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          indDeviceSetInfo.getJSONObject("ufr").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          indDeviceSetInfo.getJSONObject("ufr").put("upd_user_id", bodyData.getUpd_user_id());
          // 更新者名_姓
          indDeviceSetInfo.getJSONObject("ufr").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          indDeviceSetInfo.getJSONObject("ufr").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
          indDeviceSetInfo.getJSONObject("ihdf")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("432", "0");
          // 指示者コード
          indDeviceSetInfo.getJSONObject("ihdf").put("ind_user_id", bodyData.getInd_user_id());
          // 指示者名_姓
          indDeviceSetInfo.getJSONObject("ihdf").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          indDeviceSetInfo.getJSONObject("ihdf").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          indDeviceSetInfo.getJSONObject("ihdf").put("upd_user_id", bodyData.getUpd_user_id());
          // 更新者名_姓
          indDeviceSetInfo.getJSONObject("ihdf").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          indDeviceSetInfo.getJSONObject("ihdf").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
          indDeviceSetInfo.getJSONObject("dia")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("282", "0");
          // 指示者コード
          indDeviceSetInfo.getJSONObject("dia").put("ind_user_id", bodyData.getInd_user_id());
          // 指示者名_姓
          indDeviceSetInfo.getJSONObject("dia").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          indDeviceSetInfo.getJSONObject("dia").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          indDeviceSetInfo.getJSONObject("dia").put("upd_user_id", bodyData.getUpd_user_id());
          // 更新者名_姓
          indDeviceSetInfo.getJSONObject("dia").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          indDeviceSetInfo.getJSONObject("dia").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
          indDeviceSetInfo.getJSONObject("dc")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("340", "0");
          // 指示者コード
          indDeviceSetInfo.getJSONObject("dc").put("ind_user_id", bodyData.getInd_user_id());
          // 指示者名_姓
          indDeviceSetInfo.getJSONObject("dc").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          indDeviceSetInfo.getJSONObject("dc").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          indDeviceSetInfo.getJSONObject("dc").put("upd_user_id", bodyData.getUpd_user_id());
          // 更新者名_姓
          indDeviceSetInfo.getJSONObject("dc").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          indDeviceSetInfo.getJSONObject("dc").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
          indDeviceSetInfo.getJSONObject("qbqd")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("431", "0");
          indDeviceSetInfo.getJSONObject("qbqd")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("430", "0");
          // 指示者コード
          indDeviceSetInfo.getJSONObject("qbqd").put("ind_user_id", bodyData.getInd_user_id());
          // 指示者名_姓
          indDeviceSetInfo.getJSONObject("qbqd").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          indDeviceSetInfo.getJSONObject("qbqd").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          indDeviceSetInfo.getJSONObject("qbqd").put("upd_user_id", bodyData.getUpd_user_id());
          // 更新者名_姓
          indDeviceSetInfo.getJSONObject("qbqd").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          indDeviceSetInfo.getJSONObject("qbqd").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
        }
        if (DeviceMode.OHDF.equals(selectedTreat.getDeviceMode())) {
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("291", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("292", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("293", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("294", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("295", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("296", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("297", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("298", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("299", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("300", "0");
          // 指示者コード
          indDeviceSetInfo.getJSONObject("ufr").put("ind_user_id", bodyData.getInd_user_id());
          // 指示者名_姓
          indDeviceSetInfo.getJSONObject("ufr").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          indDeviceSetInfo.getJSONObject("ufr").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          indDeviceSetInfo.getJSONObject("ufr").put("upd_user_id", bodyData.getUpd_user_id());
          // 更新者名_姓
          indDeviceSetInfo.getJSONObject("ufr").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          indDeviceSetInfo.getJSONObject("ufr").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
          indDeviceSetInfo.getJSONObject("ihdf")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("432", "0");
          // 指示者コード
          indDeviceSetInfo.getJSONObject("ihdf").put("ind_user_id", bodyData.getInd_user_id());
          // 指示者名_姓
          indDeviceSetInfo.getJSONObject("ihdf").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          indDeviceSetInfo.getJSONObject("ihdf").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          indDeviceSetInfo.getJSONObject("ihdf").put("upd_user_id", bodyData.getUpd_user_id());
          // 更新者名_姓
          indDeviceSetInfo.getJSONObject("ihdf").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          indDeviceSetInfo.getJSONObject("ihdf").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
          indDeviceSetInfo.getJSONObject("dia")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("282", "0");
          // 指示者コード
          indDeviceSetInfo.getJSONObject("dia").put("ind_user_id", bodyData.getInd_user_id());
          // 指示者名_姓
          indDeviceSetInfo.getJSONObject("dia").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          indDeviceSetInfo.getJSONObject("dia").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          indDeviceSetInfo.getJSONObject("dia").put("upd_user_id", bodyData.getUpd_user_id());
          // 更新者名_姓
          indDeviceSetInfo.getJSONObject("dia").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          indDeviceSetInfo.getJSONObject("dia").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
        }
        if (DeviceMode.OHF.equals(selectedTreat.getDeviceMode())) {
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("291", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("292", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("293", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("294", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("295", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("296", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("297", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("298", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("299", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("300", "0");
          // 指示者コード
          indDeviceSetInfo.getJSONObject("ufr").put("ind_user_id", bodyData.getInd_user_id());
          // 指示者名_姓
          indDeviceSetInfo.getJSONObject("ufr").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          indDeviceSetInfo.getJSONObject("ufr").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          indDeviceSetInfo.getJSONObject("ufr").put("upd_user_id", bodyData.getUpd_user_id());
          // 更新者名_姓
          indDeviceSetInfo.getJSONObject("ufr").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          indDeviceSetInfo.getJSONObject("ufr").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
          indDeviceSetInfo.getJSONObject("ihdf")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("432", "0");
          // 指示者コード
          indDeviceSetInfo.getJSONObject("ihdf").put("ind_user_id", bodyData.getInd_user_id());
          // 指示者名_姓
          indDeviceSetInfo.getJSONObject("ihdf").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          indDeviceSetInfo.getJSONObject("ihdf").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          indDeviceSetInfo.getJSONObject("ihdf").put("upd_user_id", bodyData.getUpd_user_id());
          // 更新者名_姓
          indDeviceSetInfo.getJSONObject("ihdf").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          indDeviceSetInfo.getJSONObject("ihdf").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
          indDeviceSetInfo.getJSONObject("dia")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("282", "0");
          // 指示者コード
          indDeviceSetInfo.getJSONObject("dia").put("ind_user_id", bodyData.getInd_user_id());
          // 指示者名_姓
          indDeviceSetInfo.getJSONObject("dia").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          indDeviceSetInfo.getJSONObject("dia").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          indDeviceSetInfo.getJSONObject("dia").put("upd_user_id", bodyData.getUpd_user_id());
          // 更新者名_姓
          indDeviceSetInfo.getJSONObject("dia").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          indDeviceSetInfo.getJSONObject("dia").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
        }
        if (DeviceMode.PURIFICATION.equals(selectedTreat.getDeviceMode())) {
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("290", "0");
          // 指示者コード
          indDeviceSetInfo.getJSONObject("ufr").put("ind_user_id", bodyData.getInd_user_id());
          // 指示者名_姓
          indDeviceSetInfo.getJSONObject("ufr").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          indDeviceSetInfo.getJSONObject("ufr").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          indDeviceSetInfo.getJSONObject("ufr").put("upd_user_id", bodyData.getUpd_user_id());
          // 更新者名_姓
          indDeviceSetInfo.getJSONObject("ufr").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          indDeviceSetInfo.getJSONObject("ufr").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
          indDeviceSetInfo.getJSONObject("na")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("315", "0");
          // 指示者コード
          indDeviceSetInfo.getJSONObject("na").put("ind_user_id", bodyData.getInd_user_id());
          // 指示者名_姓
          indDeviceSetInfo.getJSONObject("na").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          indDeviceSetInfo.getJSONObject("na").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          indDeviceSetInfo.getJSONObject("na").put("upd_user_id", bodyData.getUpd_user_id());
          // 更新者名_姓
          indDeviceSetInfo.getJSONObject("na").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          indDeviceSetInfo.getJSONObject("na").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
          indDeviceSetInfo.getJSONObject("dc")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("340", "0");
          // 指示者コード
          indDeviceSetInfo.getJSONObject("dc").put("ind_user_id", bodyData.getInd_user_id());
          // 指示者名_姓
          indDeviceSetInfo.getJSONObject("dc").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          indDeviceSetInfo.getJSONObject("dc").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          indDeviceSetInfo.getJSONObject("dc").put("upd_user_id", bodyData.getUpd_user_id());
          // 更新者名_姓
          indDeviceSetInfo.getJSONObject("dc").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          indDeviceSetInfo.getJSONObject("dc").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
          indDeviceSetInfo.getJSONObject("qbqd")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("430", "0");
          indDeviceSetInfo.getJSONObject("qbqd")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("431", "0");
          // 指示者コード
          indDeviceSetInfo.getJSONObject("qbqd").put("ind_user_id", bodyData.getInd_user_id());
          // 指示者名_姓
          indDeviceSetInfo.getJSONObject("qbqd").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          indDeviceSetInfo.getJSONObject("qbqd").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          indDeviceSetInfo.getJSONObject("qbqd").put("upd_user_id", bodyData.getUpd_user_id());
          // 更新者名_姓
          indDeviceSetInfo.getJSONObject("qbqd").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          indDeviceSetInfo.getJSONObject("qbqd").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
          indDeviceSetInfo.getJSONObject("ihdf")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("432", "0");
          // 指示者コード
          indDeviceSetInfo.getJSONObject("ihdf").put("ind_user_id", bodyData.getInd_user_id());
          // 指示者名_姓
          indDeviceSetInfo.getJSONObject("ihdf").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          indDeviceSetInfo.getJSONObject("ihdf").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          indDeviceSetInfo.getJSONObject("ihdf").put("upd_user_id", bodyData.getUpd_user_id());
          // 更新者名_姓
          indDeviceSetInfo.getJSONObject("ihdf").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          indDeviceSetInfo.getJSONObject("ihdf").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
          indDeviceSetInfo.getJSONObject("bvufc")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("196", "0");
          // 指示者コード
          indDeviceSetInfo.getJSONObject("bvufc").put("ind_user_id", bodyData.getInd_user_id());
          // 指示者名_姓
          indDeviceSetInfo.getJSONObject("bvufc").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          indDeviceSetInfo.getJSONObject("bvufc").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          indDeviceSetInfo.getJSONObject("bvufc").put("upd_user_id", bodyData.getUpd_user_id());
          // 更新者名_姓
          indDeviceSetInfo.getJSONObject("bvufc").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          indDeviceSetInfo.getJSONObject("bvufc").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
          indDeviceSetInfo.getJSONObject("dia")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("282", "0");
          // 指示者コード
          indDeviceSetInfo.getJSONObject("dia").put("ind_user_id", bodyData.getInd_user_id());
          // 指示者名_姓
          indDeviceSetInfo.getJSONObject("dia").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          indDeviceSetInfo.getJSONObject("dia").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          indDeviceSetInfo.getJSONObject("dia").put("upd_user_id", bodyData.getUpd_user_id());
          // 更新者名_姓
          indDeviceSetInfo.getJSONObject("dia").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          indDeviceSetInfo.getJSONObject("dia").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
        }
        if (DeviceMode.I_HDF.equals(selectedTreat.getDeviceMode())) {
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("290", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("291", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("292", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("293", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("294", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("295", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("296", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("297", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("298", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("299", "0");
          indDeviceSetInfo.getJSONObject("ufr")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("300", "0");
          // 指示者コード
          indDeviceSetInfo.getJSONObject("ufr").put("ind_user_id", bodyData.getInd_user_id());
          // 指示者名_姓
          indDeviceSetInfo.getJSONObject("ufr").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          indDeviceSetInfo.getJSONObject("ufr").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          indDeviceSetInfo.getJSONObject("ufr").put("upd_user_id", bodyData.getUpd_user_id());
          // 更新者名_姓
          indDeviceSetInfo.getJSONObject("ufr").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          indDeviceSetInfo.getJSONObject("ufr").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
          indDeviceSetInfo.getJSONObject("qbqd")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("430", "0");
          indDeviceSetInfo.getJSONObject("qbqd")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("431", "0");
          // 指示者コード
          indDeviceSetInfo.getJSONObject("qbqd").put("ind_user_id", bodyData.getInd_user_id());
          // 指示者名_姓
          indDeviceSetInfo.getJSONObject("qbqd").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          indDeviceSetInfo.getJSONObject("qbqd").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          indDeviceSetInfo.getJSONObject("qbqd").put("upd_user_id", bodyData.getUpd_user_id());
          // 更新者名_姓
          indDeviceSetInfo.getJSONObject("qbqd").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          indDeviceSetInfo.getJSONObject("qbqd").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
          indDeviceSetInfo.getJSONObject("bvufc")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("196", "0");
          // 指示者コード
          indDeviceSetInfo.getJSONObject("bvufc").put("ind_user_id", bodyData.getInd_user_id());
          // 指示者名_姓
          indDeviceSetInfo.getJSONObject("bvufc").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          indDeviceSetInfo.getJSONObject("bvufc").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          indDeviceSetInfo.getJSONObject("bvufc").put("upd_user_id", bodyData.getUpd_user_id());
          // 更新者名_姓
          indDeviceSetInfo.getJSONObject("bvufc").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          indDeviceSetInfo.getJSONObject("bvufc").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
          indDeviceSetInfo.getJSONObject("dia")
            .getJSONObject("dev")
            .getJSONObject("A")
            .put("282", "0");
          // 指示者コード
          indDeviceSetInfo.getJSONObject("dia").put("ind_user_id", bodyData.getInd_user_id());
          // 指示者名_姓
          indDeviceSetInfo.getJSONObject("dia").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
          // 指示者名_名
          indDeviceSetInfo.getJSONObject("dia").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
          // 更新者コード
          indDeviceSetInfo.getJSONObject("dia").put("upd_user_id", bodyData.getUpd_user_id());
          // 更新者名_姓
          indDeviceSetInfo.getJSONObject("dia").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
          // 更新者名_名
          indDeviceSetInfo.getJSONObject("dia").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
        }
        ordMainDemo.setIndCondInfo(indCondInfo.toString());
        ordMainDemo.setIndDeviceSetInfo(indDeviceSetInfo.toString());
        if ("true".equals(bodyData.getRst_flag())) {
          ordMainDemo.setRstCondInfo(indCondInfo.toString());
          /* del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正 --start */
//          ordMainDemo.setRstDeviceSetInfo(indDeviceSetInfo.toString());
          /* del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正 --end */
          ordMainDemo.setRstTreatmentName(Objects.isNull(selectedTreat) ? null : selectedTreat.getTreatmentName());
          ordMainDemo.setRstTreatmentCd(targetTreatmentCd);
          /* add by chamaojia 2025-02-26 [11471] 【rst_device_mode】 value change supplement --start */
          ordMainDemo.setRstDeviceMode(Objects.isNull(selectedTreat) ? null : selectedTreat.getDeviceMode());
          /* add by chamaojia 2025-02-26 [11471] 【rst_device_mode】 value change supplement --end */
          ordMainDemo.setRstIsUpdateEdition("1");
//          ordMaterialSaveService.updateOrdMaterialSave(new OrdMaterialSaveDto(
//            selectOrdMain.getOrdNo(),
//            true,
//            true,
//            true,
//            false,
//            "2"
//          ));
          // add #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 start
          patIndApproveDao.updateContentChangeSingleByOrdNoList(ordNoList);
          // add #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 end
        }
        // add #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 start
        else {
          patIndApproveDao.updateAppContentChangeSingleByOrdNoList(ordNoList);
        }
        // add #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 end
        ordMainDemo.setUpDate(new Timestamp(System.currentTimeMillis()));
        updCount = ordMainDao.updateByTreatmentCdIndRst(targetTreatmentCd, ordMainDemo, ordNoList, bodyData.getInd_user_id(), ntssUser.getUserId());
      }
    }
    // add 11061 治療方法変更治療時間が長すぎて他の予定と衝突する 関 start
    List<Long> duplicatedOrdNoList = new ArrayList<>();
    if (isTreatSet) {
      duplicatedOrdNoList = this.findChangeOrdNoList(facilityCd, ordNoList, bodyData, ntssUser.getUserId());

      if (duplicatedOrdNoList.size() > 0) {
        msglist.add("12010007");
      }
    }
    // add 11061 治療方法変更治療時間が長すぎて他の予定と衝突する 関 end
    List<Integer> weeksArray = new ArrayList<>();
    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
    Calendar cal = Calendar.getInstance();
    for (OrdMain ordMainValue : ordMainList) {
      String treatDayStr = ordMainValue.getTreatDate();
      Date treatDay = sdf.parse(treatDayStr);
      cal.setTime(treatDay);
      int dayOfWeek = cal.get(Calendar.DAY_OF_WEEK) - 1;
      if (0 == dayOfWeek) dayOfWeek = 7;

      //指示履歴用に曜日をリストに追加
      weeksArray.add(dayOfWeek);
    }
    //曜日リストで重複したものを除く
    Set<Integer> simpleSet = new LinkedHashSet<>(weeksArray);
    //重複していない曜日リストを格納
    weeksArray = new ArrayList<>(simpleSet);
    // 指示履歴未登録フラグがtrue立っていない場合のみ指示履歴を登録する
    if (indHistoryMakeService.isToMongo() && ! " true".equals(bodyData.getIs_unregistered_history())) {
      ordMainDemo.setIndTreatmentCd(targetTreatmentCd);
      // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//      indHistoryMakeService.createPlanHistory(bodyData, ordMainDemo, weeksArray);
      if (null == ordMainDemo.getIndIndCommentInfo()) {
        ordMainList.forEach(o -> o.setIndIndCommentInfo(null));
      }
      indHistoryMakeService.createMethodHistory(bodyData, ordMainDemo, ordMainList, weeksArray);
      // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
    }
    // schedule
    DateFormat dateFormat = new SimpleDateFormat("yyyyMMddHHmm");
    Calendar calendar = Calendar.getInstance();
    List<MstKur> kurList = mstKurDao.selectByFacilityCd(SelectOptions.get(), facilityCd, "0");
    List<Long> bedChangeOrdNoList = new ArrayList<>();
    for (OrdMain timeChangeOrd : timeChangeList) {
      JSONObject oldIndCondInfo = new JSONObject(timeChangeOrd.getIndCondInfo());
      if (selectTreatmentTime > Integer.parseInt(oldIndCondInfo.getJSONObject("1").get("value").toString())) {
        String treatStartTime;
        if (timeChangeOrd.getIndTreatStartTime() != null) {
          treatStartTime = timeChangeOrd.getIndTreatStartTime();
        } else {
          MstKur kur = kurList.stream().filter(a -> a.getKurCd().equals(timeChangeOrd.getIndKurCd())).collect(Collectors.toList()).get(0);
          if (kur.getKurStandardStartTime() != null) {
            treatStartTime = kur.getKurStandardStartTime().substring(0, 4);
          } else {
            treatStartTime = kur.getKurStartTime().substring(0, 4);
          }
        }
        List<Integer> useKurList = new ArrayList<>();
        Date treatStartDate = dateFormat.parse(timeChangeOrd.getTreatDate() + treatStartTime);
        calendar.setTime(treatStartDate);
        calendar.add(Calendar.MINUTE, selectTreatmentTime);
        Date treatEndDate = calendar.getTime();
        for (MstKur kur : kurList) {
          Date kurStartDate = dateFormat.parse(timeChangeOrd.getTreatDate() + kur.getKurStartTime().substring(0, 4));
          Date kurEndDate = dateFormat.parse(timeChangeOrd.getTreatDate() + kur.getKurEndTime().substring(0, 4));
          if (treatStartDate.compareTo(kurStartDate) < 0 && treatEndDate.compareTo(kurEndDate) > 0) {
            useKurList.add(kur.getKurCd());
          }
        }
        for (OrdMain ord : ordMainAllList) {
          if (timeChangeOrd.getIndBedCd().equals(ord.getIndBedCd()) && useKurList.contains(ord.getIndKurCd()) && ord.getTreatDate().equals(timeChangeOrd.getTreatDate())) {
            bedChangeOrdNoList.add(timeChangeOrd.getOrdNo());
          }
        }
      }
    }
    if (bedChangeOrdNoList.size() > 0) {
      // 指示：治療予定指示者情報
      JSONObject userInfoJson = new JSONObject();
      // 指示者コード
      userInfoJson.put("ind_user_id", bodyData.getInd_user_id());
      if(user != null){
        // 指示者名_姓
        userInfoJson.put("ind_user_last_name", user.getUserLastName());
        // 指示者名_名
        userInfoJson.put("ind_user_first_name", user.getUserFirstName());
      }else {
        // 指示者名_姓
        userInfoJson.put("ind_user_last_name", JSONObject.NULL);
        // 指示者名_名
        userInfoJson.put("ind_user_first_name", JSONObject.NULL);
      }
      // 更新者コード
      userInfoJson.put("upd_user_id", bodyData.getUpd_user_id());
      // 更新者名_姓
      userInfoJson.put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
      // 更新者名_名
      userInfoJson.put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

      ordMainDao.updateBedToNullByOrdNo(bedChangeOrdNoList, userInfoJson.toString());
    }

    List<Long> timeChangeOrdNoList = timeChangeList.stream().map(OrdMain::getOrdNo).distinct().collect(Collectors.toList());
    triggerUtil.updateTriggerOrdMain(timeChangeList, ordMainDao.selectAllByOrdNoList(timeChangeOrdNoList));

    if (setResult && updCount > 0) {
      logCommon.setAfterResults();
      asyncService.updateLog(logCommon);
    }

    List<OrdMain> newOrdMains = ordMainDao.selectAllByOrdNoList(ordNoList);
    triggerUtil.updateTriggerOrdMain(ordMainList, newOrdMains);

    //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
    updateOrdChecklistByActionBeCurrent(OrdMainResource.OrdMainActionForChecklist.TREATPLAN_UPDATE_METHOD_ALL, ordNoList);
    //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end

    // #10196 materialSave Start
    // mod 12250 ord_material_saveの処理を2回重複実行している zkm start
//    List<MaterialSaveCacheHandler.DiffResultContainer> diffResultContainers = new ArrayList<>();
//    for (OrdMain ordMain: newOrdMains) {
//      // 指示
//      diffResultContainers.add(
//        ordMaterialSaveService.updateOrdMaterialSaveByDiff(
//          new OrdMaterialSaveDto(
//            ordMain.getOrdNo(),
//            true, true, true, false,
//            OrdMaterialSaveDto.IND_CLASS,
//            ordMain
//          )
//        )
//      );
//      // Rst part
//      if (StringUtils.hasText(ordMain.getRstDialysisState())
//        && !"0".equals(ordMain.getRstDialysisState())) {
//        diffResultContainers.add(
//          ordMaterialSaveService.updateOrdMaterialSaveByDiff(
//            new OrdMaterialSaveDto(
//              ordMain.getOrdNo(),
//              true, true, true, true,
//              OrdMaterialSaveDto.RST_CLASS,
//              ordMain
//            )
//          )
//        );
//      }
//    }
//    if (!CollectionUtils.isEmpty(diffResultContainers)) {
//      ordMaterialSaveService.batchProcessingData(diffResultContainers);
//    }
    List<Long> ordMaterialSaveOrdNoList = newOrdMains.stream().map(OrdMain::getOrdNo).toList();
    ordMaterialSaveService.bulkUpdateByOrdNoInCondMediEquip(ordMaterialSaveOrdNoList);
    // mod 12250 ord_material_saveの処理を2回重複実行している zkm end
    // #10196 materialSave End

    resultData.put("ordMainList", ordMainList);
    resultData.put("msglist", new ArrayList<String>(msglist));
    // add 11061 治療方法変更治療時間が長すぎて他の予定と衝突する 関 start
    resultData.put("duplicatedOrdNoList", duplicatedOrdNoList);
    // add 11061 治療方法変更治療時間が長すぎて他の予定と衝突する 関 end
    invokeResult.success(resultData);
    return invokeResult;
  }
  // add 11061 治療方法変更治療時間が長すぎて他の予定と衝突する 関 start
  public List<Long> findChangeOrdNoList(String facilityCd, List<Long> ordNoList, ApiEntityOrdMain.ValiCreateTreatPlan bodyData, Long userId) {

    List<Long> duplicatedOrdNoList = new ArrayList<>();

    List<OrdScheduleNewKurPreview> beforeExcludeHimScheduleList = ordScheduleDao.selectOrdMainWithNewKur(facilityCd, ordNoList);

    List<OrdMain> updateAfterOrdMainList = ordMainDao.selectListByOrdNo(ordNoList);

    List<Long> beforeExcludeHimOrdNoList = beforeExcludeHimScheduleList.stream().map(OrdScheduleNewKurPreview::getKeyNo).distinct().collect(Collectors.toList());

    List<OrdSchedule> outsideScopeConflictSchList = new ArrayList<>();

    //変更範囲外衝突処理
    if (beforeExcludeHimScheduleList.size() >0) {

      outsideScopeConflictSchList = ordScheduleDao.selectOrdScheduleWithNewKur(facilityCd, beforeExcludeHimScheduleList, beforeExcludeHimOrdNoList);
      if (outsideScopeConflictSchList.size() >0) {
        List<OrdSchedule> finalOutsideScopeConflictSchList = outsideScopeConflictSchList;

        List <Long> outsideScopeConflictOrdList = beforeExcludeHimScheduleList.stream().filter(sch -> finalOutsideScopeConflictSchList.stream().anyMatch(e -> e.getTreatDate().equals(sch.getTreatDate())
        && e.getKurCd().equals(sch.getKurCd()) && e.getBedCd().equals(sch.getBedCd()))).map(OrdScheduleNewKurPreview::getKeyNo).collect(Collectors.toList());
        if (outsideScopeConflictOrdList.size() >0) {
          List<OrdMain> oldOrdMainList = ordMainDao.selectListByOrdNo(outsideScopeConflictOrdList);
          ordMainDao.updateBedAndScheToNullByOrdNo(outsideScopeConflictOrdList, bodyData.getInd_user_id(), userId);
          List<OrdMain> newOrdMainList = ordMainDao.selectListByOrdNo(outsideScopeConflictOrdList);
          triggerUtil.updateTriggerOrdMain(oldOrdMainList, newOrdMainList);
          duplicatedOrdNoList.addAll(outsideScopeConflictOrdList);
        }
      }
    }
    // 変更範囲内の競合処理
    List<OrdScheduleNewKurPreview> withinScopeConflictSchList = ordScheduleDao.selectOrdMainWithNewKur(facilityCd, ordNoList);

    // 同日同クールグループリスト作成
    Map<String, List<OrdScheduleNewKurPreview>> groupedList = withinScopeConflictSchList.stream()
      .collect(Collectors.groupingBy(record -> record.getTreatDate() + "_" + record.getKurCd() + "_" + record.getBedCd(), LinkedHashMap::new, Collectors.toList()));

    // 治療方法マスタselector表示順取得
    MstTreatment mstTreatmentSearchData = new MstTreatment();
    mstTreatmentSearchData.setFacilityCd(facilityCd);
    List<MstTreatment> mstTreatmentmList = mstInfoService.findMstTreatmentList(mstTreatmentSearchData);
    // -1:不明
    List<Integer> unknownList = mstTreatmentmList.stream()
      .filter(treatment -> Objects.nonNull(treatment.getDeviceMode()) && treatment.getDeviceMode() == -1)
      .map(MstTreatment::getTreatmentCd)
      .collect(Collectors.toList());
    // 9:特殊浄化
    List<Integer> purificationList = mstTreatmentmList.stream()
      .filter(treatment -> Objects.nonNull(treatment.getDeviceMode()) && treatment.getDeviceMode() == 9)
      .map(MstTreatment::getTreatmentCd)
      .collect(Collectors.toList());
    // 0:HD、1:ECUM,2:HDF、3:HF、4:HD+補液、5:ECUM+補液、6:AFBF、7:OHDF、8:OHF、10:I-HDF
    List<Integer> nomalList = mstTreatmentmList.stream()
      .filter(treatment -> Objects.nonNull(treatment.getDeviceMode()) && treatment.getDeviceMode() != -1 && treatment.getDeviceMode() != 9)
      .map(MstTreatment::getTreatmentCd)
      .collect(Collectors.toList());

    List<Long> changeOrdNoList = new ArrayList<>();
    for (List<OrdScheduleNewKurPreview> group : groupedList.values()) {
      List<Long> finalChangeOrdNoList = changeOrdNoList;
      group = group.stream().filter(s -> !finalChangeOrdNoList.contains(s.getKeyNo())).toList();
      if (group.size() > 1) {
        List<OrdScheduleNewKurPreview> finalGroup = group;
        Optional<Integer> unknownLast = unknownList.stream()
          .filter(i -> finalGroup.stream().anyMatch(e -> e.getIndTreatmentCd().equals(i)))
          .reduce((first, second) -> second);

        Optional<Integer> purificationLast = purificationList.stream()
          .filter(i -> finalGroup.stream().anyMatch(e -> e.getIndTreatmentCd().equals(i)))
          .reduce((first, second) -> second);

        Optional<Integer> nomalListLast = nomalList.stream()
          .filter(i -> finalGroup.stream().anyMatch(e -> e.getIndTreatmentCd().equals(i)))
          .reduce((first, second) -> second);

        Integer unknownTreatmentCd = unknownLast.orElse(0);
        if (unknownTreatmentCd.compareTo(0) > 0) {

          List<Long> unknowOrdNoList = group.stream()
            .filter(e -> e.getIndTreatmentCd().equals(unknownTreatmentCd))
            .sorted(Comparator.comparing(OrdScheduleNewKurPreview::getTreatDate))
            .map(OrdScheduleNewKurPreview::getKeyNo)
            .collect(Collectors.toCollection(ArrayList::new));
          if (unknowOrdNoList.size() > 0) {
            unknowOrdNoList.remove(0);
            changeOrdNoList.addAll(unknowOrdNoList);
          }
          continue;
        }
        Integer purificationTreatmentCd = purificationLast.orElse(0);
        if (purificationTreatmentCd.compareTo(0) > 0) {
          List<Long> puOrdNoList = group.stream()
            .filter(e -> e.getIndTreatmentCd().equals(purificationTreatmentCd))
            .sorted(Comparator.comparing(OrdScheduleNewKurPreview::getTreatDate))
            .map(OrdScheduleNewKurPreview::getKeyNo)
            .collect(Collectors.toCollection(ArrayList::new));

          if (puOrdNoList.size() > 0) {
            puOrdNoList.remove(0);
            changeOrdNoList.addAll(puOrdNoList);
          }
          continue;
        }
        if (unknownTreatmentCd.compareTo(0) == 0 && purificationTreatmentCd.compareTo(0) == 0){
          Integer nomalTreatmentCd = nomalListLast.orElse(0);
          List<Long> noOrdNoList = group.stream()
            .filter(e -> e.getIndTreatmentCd().equals(nomalTreatmentCd))
            .sorted(Comparator.comparing(OrdScheduleNewKurPreview::getTreatDate))
            .map(OrdScheduleNewKurPreview::getKeyNo)
            .collect(Collectors.toCollection(ArrayList::new));
          if (noOrdNoList.size() > 0) {
            noOrdNoList.remove(0);
            changeOrdNoList.addAll(noOrdNoList);
          }
        }
      }
    }
    if (changeOrdNoList.size() > 0) {
      changeOrdNoList = changeOrdNoList.stream().distinct().collect(Collectors.toList());
      List<OrdMain> oldOrdMainList = ordMainDao.selectListByOrdNo(changeOrdNoList);
      ordMainDao.updateBedAndScheToNullByOrdNo(changeOrdNoList, bodyData.getInd_user_id(), userId);
      List<OrdMain> newOrdMainList = ordMainDao.selectListByOrdNo(changeOrdNoList);
      triggerUtil.updateTriggerOrdMain(oldOrdMainList, newOrdMainList);
      duplicatedOrdNoList.addAll(changeOrdNoList);
    }
    if (updateAfterOrdMainList.size() > 0) {
      Map<Integer, Map<Integer, List<OrdMain>>> ordMainGroup = updateAfterOrdMainList.stream().collect(Collectors.groupingBy(OrdMain::getIndKurCd, Collectors.groupingBy(OrdMain::getIndBedCd)));
      for (Iterator<Map.Entry<Integer, Map<Integer, List<OrdMain>>>> entryKur = ordMainGroup.entrySet().iterator(); entryKur.hasNext(); ) {
        Map.Entry<Integer, Map<Integer, List<OrdMain>>> entryKurInfo = entryKur.next();
        Long indKurCd = entryKurInfo.getKey().longValue();
        Map<Integer, List<OrdMain>> ordMainKurGroup = entryKurInfo.getValue();
        for (Iterator<Map.Entry<Integer, List<OrdMain>>> entryBed = ordMainKurGroup.entrySet().iterator(); entryBed.hasNext(); ) {
          Map.Entry<Integer, List<OrdMain>> entryBedInfo = entryBed.next();
          Long indBedCd = entryBedInfo.getKey().longValue();
          List<OrdMain> ordMainKurBedGroup = entryBedInfo.getValue();
          List<Long> newOrdNoList = new ArrayList<Long>();
          // 処理対象オーダ番号リスト作成
          for (int i = 0; i < ordMainKurBedGroup.size(); i++) {
            newOrdNoList.add(ordMainKurBedGroup.get(i).getOrdNo());
          }
          // ダミースケジュール操作処理実施(クール未登録、ベッド未登録の場合はダミースケジュールを削除)
          String opeMode = "3";
          try {
            ResponseEntity<String> retDummy = webApiCallCommonUtil.operateDummySchedule(newOrdNoList, indBedCd, indKurCd, opeMode);
          }catch (URISyntaxException e) {
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
        }
      }
    }
    return duplicatedOrdNoList;
  }
  // add 11061 治療方法変更治療時間が長すぎて他の予定と衝突する 関 end

  private JSONObject editIndJson(ApiEntityOrdMain.ValiCreateTreatPlan bodyData, MstPersonalUser user, MstPersonalUser updUser) {
    JSONObject bufJson = new JSONObject();
    // 設定値
    bufJson.put("value", JSONObject.NULL);
    // 指示者コード
    bufJson.put("ind_user_id", bodyData.getInd_user_id());
    // 指示者名_姓
    bufJson.put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
    // 指示者名_名
    bufJson.put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
    // 更新者コード
    bufJson.put("upd_user_id", bodyData.getUpd_user_id());
    // 更新者名_姓
    bufJson.put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
    // 更新者名_名
    bufJson.put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
    // 登録区分
    bufJson.put("input_class", 1);
    // 編集可否フラグ
    bufJson.put("is_editable", "1");
    // 連携オーダ番号
    bufJson.put("cop_order_no", JSONObject.NULL);

    return bufJson;
  }
  private JSONObject editRstJson(ApiEntityOrdMain.ValiCreateTreatPlan bodyData, MstPersonalUser user) {
    JSONObject bufJson = new JSONObject();
    // 設定値
    bufJson.put("value", JSONObject.NULL);
    // 翻訳1
    bufJson.put("value_name_1", JSONObject.NULL);
    // 単位
    bufJson.put("unit", JSONObject.NULL);
    // 登録区分
    bufJson.put("input_class", 1);
    // 編集可否フラグ
    bufJson.put("is_editable", "1");
    // 連携オーダ番号
    bufJson.put("cop_order_no", JSONObject.NULL);

    return bufJson;
  }

  /***
   * JSON配列データから値を取得し、Integer配列データを返す
   * @param stringList
   * @return
   */
  public List<Integer> getValueList(String stringList) {
    JSONArray json;
    List<Integer> valueArry = new ArrayList<>();
    try {
      if (null == stringList) return valueArry;
      json = new JSONArray(stringList);
      // 選択された値を配列に格納
      for (int i = 0; i < json.length(); i++) {
        valueArry.add((int) (json.get(i)));
      }
    } catch (JSONException e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("エラー発生：" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      return null;
    }
    return valueArry;
  }

  /**
   * JSON配列データをLong配列に変換して返す
   *
   * @param stringList
   * @return
   */
  public List<Long> getLongList(String stringList) {
    List<Long> longList = new ArrayList<>();
    try {
      // 値が入っていなければ、処理を終了して空の配列を返す
      if (null == stringList) return longList;
      JSONArray json = new JSONArray(stringList);
      // 選択された値を配列に格納
      for (int i = 0; i < json.length(); i++) {
        longList.add((long) json.getInt(i));
      }
    } catch (JSONException e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("エラー発生：" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      return null;
    }
    return longList;
  }

  /**
   * JSON配列データをLong配列に変換して返す
   *
   * @param stringList
   * @return
   */
  public List<Integer> getIntegerList(String stringList) {
    List<Integer> integerList = new ArrayList<>();
    try {
      // 値が入っていなければ、処理を終了して空の配列を返す
      if (null == stringList) return integerList;
      JSONArray json = new JSONArray(stringList);
      // 選択された値を配列に格納
      for (int i = 0; i < json.length(); i++) {
        integerList.add(json.getInt(i));
      }
    } catch (JSONException e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("エラー発生：" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      return null;
    }
    return integerList;
  }
  /**
   * 治療方法による治療条件設定使用チェック
   *
   * @param treatCondSetting 治療方法設定
   * @param treatKey         治療条件項目番号
   * @return 使用フラグ
   */
  private Boolean checkTreatCondIsUse(JSONArray treatCondSetting, String treatKey) {
    for (int i = 0; i < treatCondSetting.length(); i++) {
      JSONArray items = treatCondSetting.getJSONObject(i).getJSONArray("items");
      for (int j = 0; j < items.length(); j++) {
        if (
          items.getJSONObject(j).get("ctl_no").equals(treatKey) &&
            items.getJSONObject(j).get("is_use").equals("0")
        ) {
          return false;
        }
      }
    }

    return true;
  }
  /**
   * 装置設定用マージ関数(nullを無視する)
   *
   * @param mstDefault  装置設定デフォルトマスタの装置設定
   * @param mstTreatSet 治療方法セットマスタの装置設定
   * @return マージしたJSONObject
   */
  private JSONObject deviceSetInfoMerge(JSONObject mstDefault, JSONObject mstTreatSet) throws JSONException {
    JSONObject retVal = new JSONObject();

    if (mstDefault.length() == 0) {
      retVal = mstTreatSet;
    } else if (mstTreatSet.length() == 0) {
      retVal = mstDefault;
    } else if (mstDefault.length() != 0 && mstTreatSet.length() != 0) {
      retVal = new JSONObject(mstDefault.toString());

      for (String key : JSONObject.getNames(mstTreatSet)) {
        Object val = mstTreatSet.get(key);

        if (val instanceof JSONObject) {
          retVal.put(key, deviceSetInfoMerge(mstDefault.getJSONObject(key), mstTreatSet.getJSONObject(key)));
        } else if (! mstTreatSet.isNull(key)) {
          retVal.put(key, val);
        }
      }
    }

    return retVal;
  }
  private HashMap<String, Object> indCondJsonToMap(JSONObject setCond) {
    HashMap<String, Object> setCondMap = new HashMap<>();
    String[] keyArr = {"13","5","6","7","8","12","9","10","11","15","19","22","25","26","28","17"};
    for(String key : keyArr){
      if(setCond.has(key)){
        JSONObject jsonObject = setCond.getJSONObject(key);
        String value = jsonObject.get("value").toString();
        setCondMap.put(key,value);
        if("25".equals(key)){
          if(!jsonObject.isNull("medicine_type")){
            Integer medicineType = Integer.parseInt(jsonObject.get("medicine_type").toString());
            setCondMap.put("25->medicine_type", medicineType);
          }else {
            setCondMap.put("25->medicine_type", null);
          }
        }
      }
    }
    return setCondMap;
  }
  private OrdMaterialSave ordMaterialCreate(ApiEntityOrdMain.ValiOrdMaterialSave conditions) {
    OrdMaterialSave oms = new OrdMaterialSave();
    // 施設コード
    oms.setFacilityCd(conditions.getFacility_cd());
    // 患者ID
    oms.setPatId(Long.parseLong(conditions.getPat_id()));
    // データ基準日
    oms.setSuppliesBaseDate(conditions.getBase_date());
    // データ基準番号
    oms.setSuppliesBaseNo(Long.parseLong(conditions.getSupplies_base_no()));
    // データ発生元区分
    oms.setSuppliesSourceClass(String.valueOf(conditions.getSupplies_source_class()));
    // 物品区分
    oms.setSuppliesClass(conditions.getSupplies_class());
    // 物品コード
    oms.setSuppliesCd(conditions.getSupplies_cd());
    // 調整薬剤コード
    oms.setMedicineMixCd(conditions.getMedicine_mix_cd());
    // 分類コード
    oms.setClassCd(conditions.getClass_cd());
    // 指示・実績区分
    oms.setIndRstClass(conditions.getInd_rst_class());
    // 指示・実績値
    oms.setIndRstValue(conditions.getInd_rst_value());
    // レセ値
    oms.setReceiptValue(conditions.getReceipt_value());
    // 確定フラグ
    oms.setIsConfirm(conditions.getIs_confirm());
    // 登録日時 and 更新日時
    Timestamp tm = Timestamp.from(Instant.now());
    oms.setRegDate(tm);
    oms.setUpDate(tm);
    return oms;
  }
  private void clearConditions(ApiEntityOrdMain.ValiOrdMaterialSave conditions) {
    // データ発生元区分
    conditions.setSupplies_source_class(null);
    // 物品区分
    conditions.setSupplies_class(null);
    // 物品コード
    conditions.setSupplies_cd(null);
    // 調整薬剤コード
    conditions.setMedicine_mix_cd(null);
    // 分類コード
    conditions.setClass_cd(null);
    // 指示・実績値
    conditions.setInd_rst_value(null);
    // レセ値
    conditions.setReceipt_value(null);
  }
  /**
   * レセ値取得
   *
   * @param conditions  条件
   * @param mstMedicine 通常薬剤情報
   * @param indRstValue 指示・実績値
   */
  public void receiptValueSet(ApiEntityOrdMain.ValiOrdMaterialSave conditions, MstMedicine mstMedicine,
                              String indRstValue) {
    // レセ単位小数部桁数
    if (null != mstMedicine) {
      int point = 0;
      if (mstMedicine.getUnitDecimalPointSecond() != null) {
        point = mstMedicine.getUnitDecimalPointSecond();
      }
      String receiptValue = BigDecimal.ZERO.setScale(point, BigDecimal.ROUND_HALF_UP).toPlainString();
      switch (mstMedicine.getIsExchange()) {
        // 固定DD
        case "2":
          // レセ換算値
          if (mstMedicine.getUnitConvertedAmountSecond() != null && BigDecimal.ZERO.compareTo(mstMedicine.getUnitConvertedAmountSecond()) != 0) {
            receiptValue = mstMedicine.getUnitConvertedAmountSecond().setScale(point, RoundingMode.HALF_UP).toPlainString();
          }
          break;
        // 換算
        case "0":
          // 指示基準数量レセ換算値がnull以外の場合
          if (mstMedicine.getUnitConvertedAmount() != null && BigDecimal.ZERO.compareTo(mstMedicine.getUnitConvertedAmount()) != 0 &&
            mstMedicine.getUnitConvertedAmountSecond() != null && BigDecimal.ZERO.compareTo(mstMedicine.getUnitConvertedAmountSecond()) != 0) {
            // （指示or実績数量 / 指示基準数量）＊ レセ換算値
            // 指示or実績数量
            BigDecimal indRstValue0 = new BigDecimal(indRstValue);
            BigDecimal reSeNum0 = indRstValue0.divide(mstMedicine.getUnitConvertedAmount(), point, BigDecimal.ROUND_HALF_UP)
              .multiply(mstMedicine.getUnitConvertedAmountSecond());
            receiptValue = reSeNum0.setScale(point, RoundingMode.HALF_UP).toPlainString();
          }
          break;
        // 残量破棄
        case "1":
          // 指示基準数量レセ換算値がnull以外の場合
          if (mstMedicine.getUnitConvertedAmount() != null && BigDecimal.ZERO.compareTo(mstMedicine.getUnitConvertedAmount()) != 0 &&
            mstMedicine.getUnitConvertedAmountSecond() != null && BigDecimal.ZERO.compareTo(mstMedicine.getUnitConvertedAmountSecond()) != 0) {
            // （指示or実績数量 / 指示基準数量）(小数第一位切り上げ)＊ レセ換算値
            // 指示or実績数量
            BigDecimal indRstValue1 = new BigDecimal(indRstValue);
            BigDecimal reSeNum1 = indRstValue1.divide(mstMedicine.getUnitConvertedAmount(), 0, BigDecimal.ROUND_UP)
              .multiply(mstMedicine.getUnitConvertedAmountSecond());
            receiptValue = reSeNum1.setScale(point, RoundingMode.HALF_UP).toPlainString();
          }
          break;
      }
      // レセ値
      conditions.setReceipt_value(receiptValue);
    } else {
      // レセ値
      conditions.setReceipt_value(null);
    }
  }
  /**
   * 同じ種類の計算材料を取得します
   *
   * @param setMedi 計算材料
   * @return 同じ種類の計算材料
   */
  public Map<String, Map<String, Double>> sameKindCalculation(JSONArray setMedi) {
    Map<String, Map<String, Double>> typeCdAmountMap = new HashMap<>();
    // 調整薬剤の投与薬剤
    Map<String, Double> cdAmountMapType0 = new HashMap<>();
    // 投与薬剤
    Map<String, Double> cdAmountMapType1 = new HashMap<>();
    // 調整薬剤
    Map<String, Double> cdAmountMapType2 = new HashMap<>();
    for (int i = 0; i < setMedi.length(); i++) {
      JSONObject jsonObject = setMedi.getJSONObject(i);
      // 薬剤コード
      String cd = jsonObject.get("cd").toString();
      // 薬剤の数
      Double amount = 0.0;
      if (jsonObject.has("amount") && !jsonNodeIsNull(jsonObject.get("amount").toString())) {
        amount = Double.parseDouble(jsonObject.get("amount").toString());
      }
      // 薬剤のカテゴリー
      if (jsonObject.has("medicine_type")) {
        if ("1".equals(jsonObject.get("medicine_type").toString())) {
          // 最初のデータ
          if (i != 0) {
            Boolean testFlg = false;
            Double entryValue = null;
            // マップに追加された値と比較し、マップをトラバースします
            for (Map.Entry<String, Double> entry : cdAmountMapType1.entrySet()) {
              // 現在のデータと比較して、同じ状況の場合は金額が加算され、状況がない場合は値がマップに加算されます
              if (entry.getKey().equals(cd)) {
                testFlg = true;
                entryValue = entry.getValue();
                break;
              }
            }

            if (testFlg) {
              amount = amount + entryValue;
            }
          }
          cdAmountMapType1.put(cd, amount);
          typeCdAmountMap.put("1", cdAmountMapType1);
        } else if ("2".equals(jsonObject.get("medicine_type").toString())) {
          // 最初のデータ
          if (i != 0) {
            Boolean testFlg = false;
            Double entryValue = null;
            // マップに追加された値と比較し、マップをトラバースします
            for (Map.Entry<String, Double> entry : cdAmountMapType2.entrySet()) {
              // 現在のデータと比較して、同じ状況の場合は金額が加算され、状況がない場合は値がマップに加算されます
              if (entry.getKey().equals(cd)) {
                testFlg = true;
                entryValue = entry.getValue();
                break;
              }
            }

            if (testFlg) {
              amount = amount + entryValue;
            }
          }
          cdAmountMapType2.put(cd, amount);
          typeCdAmountMap.put("2", cdAmountMapType2);
        }
      } else {
        String equiptype = "";
        if (jsonObject.has("equip_type")){
          equiptype = jsonObject.get("equip_type").toString();
        }
        // 最初のデータ
        if (i == 0) {
          if (!StringUtils.isEmpty(equiptype)) {
            cdAmountMapType0.put(cd +"-" + equiptype, amount);
          } else {
            cdAmountMapType0.put(cd, amount);
          }
        } else {
          boolean testFlg = false;
          Double entryValue = null;
          // マップに追加された値と比較し、マップをトラバースします
          for (Map.Entry<String, Double> entry : cdAmountMapType0.entrySet()) {
            // 現在のデータと比較して、同じ状況の場合は金額が加算され、状況がない場合は値がマップに加算されます
            if (entry.getKey().equals(cd)) {
              testFlg = true;
              entryValue = entry.getValue();
              break;
            }
          }

          if (testFlg) {
            amount = amount + entryValue;
          }
          if (!StringUtils.isEmpty(equiptype)) {
            cdAmountMapType0.put(cd +"-" + equiptype, amount);
          } else {
            cdAmountMapType0.put(cd, amount);
          }
        }
        typeCdAmountMap.put("0", cdAmountMapType0);
      }
    }
    return typeCdAmountMap;
  }
  private String setMixDecimal(Map.Entry<String, Double> cdAmountenEntry, MstMedicineMix medicineMix) {
    // 小数点桁数を正しく保持する
    int decimalPoint = 0;
    if (null != medicineMix) {
      if (null != medicineMix.getUnitDecimalPoint()) {
        decimalPoint = medicineMix.getUnitDecimalPoint();
      }
    }
    StringBuilder sb = new StringBuilder("0");
    if (decimalPoint > 0) {
      sb.append(".");
      for (int i = 0; i < decimalPoint; i++) {
        sb.append(0);
      }
    }
    DecimalFormat df = new DecimalFormat(sb.toString());
    return df.format(cdAmountenEntry.getValue());
  }
  /**
   * 396 調製薬剤の数量固定 張
   *
   * @param setMedi
   * @return 調製薬剤の数量固定
   */
  public Map<String, Boolean> sameKindSolvent(JSONArray setMedi) {
    Map<String, Boolean> cdSolventMap = new HashMap<>();
    for (int i = 0; i < setMedi.length(); i++) {
      JSONObject jsonObject = setMedi.getJSONObject(i);
      // 薬剤コード
      String cd = jsonObject.get("cd").toString();
      // 薬剤の数量固定（0：なし、1：固定）
      Boolean solvent = "1".equals(jsonObject.get("solvent"));
      cdSolventMap.put(cd, solvent);
    }
    return cdSolventMap;
  }
  // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関  end

  //add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 start

  /**
   * ダミースケジュール再作成
   * @param facilityCd 施設コード
   * @param userId ユーザID
   * @param updUserId
   * @return
   * @throws Exception
   */
  @Override
  @Transactional
  //mod #10634 クールマスタで標準治療開始時刻を変更した際のダミー予定・連携イベント作成処理不正 zrx start
//  public OrdMainForJournal updateIndScheduleOnceForAll(String facilityCd, Long userId, Long updUserId, String processKey) throws Exception {
  public OrdMainForJournal updateIndScheduleOnceForAll(String facilityCd, Long userId, Long updUserId, String processKey, List<MstKur> oldMstKurList) throws Exception {
    //mod #10634 クールマスタで標準治療開始時刻を変更した際のダミー予定・連携イベント作成処理不正 zrx end
    OrdMainForJournal result = new OrdMainForJournal();
    try {
      List<String> resList = new ArrayList<>();
      List<OrdMain> journalList = new ArrayList<>();
      //ord_mainから処理対象の取得処理（SQLで）(範囲外)
      List<OrdMain> ordMainList = ordMainDao.checkChangedOrdMainAndGetAllOrdNo(facilityCd);

      setUpdKurProcess(processKey, 1);  // #10282 ADD synchronize processing progress

      List<Long> ordNoList = new ArrayList<>();
      for (OrdMain om : ordMainList) {
        ordNoList.add(om.getOrdNo());
      }
      String ordNoStr = "-1";
      if (!ordNoList.isEmpty()) {
        ordNoStr = ordNoList.toString()
          .replace("[", "").replace("]", "").replace(" ", "");
      }
      EventLogMessage outOfRangeLogMessage = new EventLogMessage();
      outOfRangeLogMessage.setLogMessage("out of range data: " + ordNoStr);
      outOfRangeLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.INFO, outOfRangeLogMessage, null, SERVICE_NAME.FNSI, null);
      //変更後の最新なmst_kurテーブル情報取得
      List<MstKur> mstKur = mstKurDao.selectByFacilityCd(SelectOptions.get(), facilityCd, AdminWebConstant.FlagType.FLAG_OFF);

      setUpdKurProcess(processKey, 2);  // #10282 ADD synchronize processing progress

      DateTimeFormatter dateFormat = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
      DateTimeFormatter dayFormat = DateTimeFormatter.ofPattern("yyyyMMdd");

      SelectOptions options = SelectOptions.get();
      List<MstKur> mstKurList = mstKurDao.selectByFacilityCd(options, facilityCd, "0");

      setUpdKurProcess(processKey, 3);  // #10282 ADD synchronize processing progress

      //新規用ord_scheduleのデータリスト
      List<OrdSchedule> ordScheduleList = new ArrayList<>();

      //衝突用のord_scheduleリスト
      List<OrdMain> ordMainDeleteAllList = new ArrayList<>();
      List<Long> ordNoDeleteAllList = new ArrayList<>();
      List<OrdSchedule> needToDelOsList = new ArrayList<>();

      // add #10282 fixed OOM issue. ztc 20240516 start
      //mod #10634 クールマスタで標準治療開始時刻を変更した際のダミー予定・連携イベント作成処理不正 zrx start
//      List<Long> undeleteBedCdData = ordMainDao.getAllUndeleteBedCdData(facilityCd);
      List<Long> undeleteBedCdData = ordMainDao.getAllUndeleteBedCdData(facilityCd, oldMstKurList);
      //mod #10634 クールマスタで標準治療開始時刻を変更した際のダミー予定・連携イベント作成処理不正 zrx end
      if(CollectionUtils.isNotEmpty(undeleteBedCdData)) {

        double loopPerProcess = 1.0 / undeleteBedCdData.size();
        Double loopProcess = 3.0d;

        for(Long indBedCd : undeleteBedCdData) {
          //determine if it exists
          List<OrdSchedule> osList = ordScheduleDao.selectByFacilityCd(facilityCd, indBedCd);
      // add #10282 fixed OOM issue. ztc 20240516 end
          //scheduleに削除の予定ないord_main情報取得(範囲内)（order by 治療日、クール開始時刻）
          // mod #10282 fixed OOM issue. ztc 20240516 start
//          List<OrdMain> unDeleteData = ordMainDao.getAllUndeleteData(facilityCd);
          List<OrdMain> unDeleteData = ordMainDao.getAllUndeleteData(facilityCd, indBedCd);
          // mod #10282 fixed OOM issue. ztc 20240516 end
          //sort by treat_date and ind_treat_start_time
          unDeleteData.sort(Comparator.comparing(OrdMain::getTreatDate).thenComparing(OrdMain::getIndTreatStartTime));
          EventLogMessage inRangeLogMessage = new EventLogMessage();
          StringBuilder inRangeData = new StringBuilder("in range data: ");
          for (OrdMain unDeleteDatum : unDeleteData) {
            inRangeData.append(", ").append(unDeleteDatum.getOrdNo());
          }
          inRangeLogMessage.setLogMessage(inRangeData.toString());
          logService.log(LogLevel.INFO, inRangeLogMessage, null, SERVICE_NAME.FNSI, null);

          loopProcess += loopPerProcess;
          setUpdKurProcess(processKey, loopProcess.intValue());  // #10282 ADD synchronize processing progress

          //処理(scheduleに削除の予定ないord_main情報取得(範囲内))で取得の情報リストをループする
          for (int i = 0; i < unDeleteData.size(); i++) {

            Long ordNo = unDeleteData.get(i).getOrdNo();
            //内部変数の治療開始日時を作成
            Integer indKurCd = unDeleteData.get(i).getIndKurCd();
            // del #10282 fixed OOM issue. ztc 20240516 start
//            Integer indBedCd = unDeleteData.get(i).getIndBedCd();
            // del #10282 fixed OOM issue. ztc 20240516 end
            String treatDate = unDeleteData.get(i).getTreatDate();
            String startTime = unDeleteData.get(i).getIndTreatStartTime();
            long treatTime = 0L;
            JSONObject indCondInfo = new JSONObject(unDeleteData.get(i).getIndCondInfo());
            if (indCondInfo.has("1")) {
              Object treatTimeStr = new JSONObject(indCondInfo.get("1").toString()).get("value");
              if (treatTimeStr != null && !treatTimeStr.toString().isEmpty()) {
                treatTime = Long.parseLong((new JSONObject(indCondInfo.get("1").toString()).get("value").toString()));
              }
            }
            //治療開始日時＝治療日＋指示：治療開始時刻
            LocalDateTime treatStartDate = LocalDateTime.parse(treatDate + startTime, dateFormat);
            //治療終了日時 = (治療日＋指示：治療開始時刻) + 治療時間 - 1s
            LocalDateTime treatEndDate = LocalDateTime.parse(treatDate + startTime, dateFormat).plusMinutes(treatTime).minusSeconds(1);

            LocalDateTime dummyDate = LocalDateTime.parse(unDeleteData.get(i).getTreatDate() + "000000", dateFormat);
            long dummyKur = unDeleteData.get(i).getIndKurCd();
            Optional<MstKur> kur = mstKurList.stream().filter(data -> data.getKurCd().equals(indKurCd)).findFirst();
            if (!kur.isPresent()) continue;
            String dummyTreatDate = dummyDate.format(dayFormat);
            dummyDate = LocalDateTime.parse(dummyTreatDate + kur.get().getKurEndTime(), dateFormat);
            Long patId = unDeleteData.get(i).getPatId();
            while (!dummyDate.isAfter(treatEndDate)) {
              // 次クール情報取得
              MstKurEx nextKurInfo = this.calcNextKurInfo(mstKur, dummyKur);
              if (nextKurInfo != null) {
                OrdSchedule tmp = new OrdSchedule();
                // 次クールの最初のクールフラグがtrueの場合は日付を翌日に更新
                if (nextKurInfo.getIsFirstKur()) {
                  dummyDate = dummyDate.plusDays(1);
                }
                // ダミースケジュール更新(クールの期間すべてを含んでいるかをチェックするため、ダミースケジュールの時刻はクール終了時刻を設定)
                dummyTreatDate = dummyDate.format(dayFormat);
                dummyDate = LocalDateTime.parse(dummyTreatDate + nextKurInfo.getKurEndTime(), dateFormat);
                dummyKur = nextKurInfo.getKurCd().longValue();
                //判断ルール、				（衝突の判断）
                //現在ord _mainの内部変数の治療開始日時から内部変数の治療終了日時までの間に、
                //相同に指示：ベッドコードがあれば、　且つ、　
                //治療開始時間はある所定の治療時間区間内にあり
                LocalDateTime tempDummyDate = dummyDate;
                // mod #10282 fixed OOM issue. ztc 20240516 start
//                boolean inOrOut = unDeleteData.stream().anyMatch(data ->
//                        data.getIndBedCd().equals(indBedCd)
//                                && !data.getPatId().equals(patId)
//                                && LocalDateTime.parse(data.getTreatDate() + data.getIndTreatStartTime(), dateFormat).isAfter(treatStartDate)
//                                && !LocalDateTime.parse(data.getTreatDate() + data.getIndTreatStartTime(), dateFormat).isAfter(treatEndDate)
//                                && !treatEndDate.isBefore(tempDummyDate));
                boolean inOrOut = !treatEndDate.isBefore(tempDummyDate) && unDeleteData.stream().anyMatch(data -> {
                  LocalDateTime treatDateTime = LocalDateTime.parse(data.getTreatDate() + data.getIndTreatStartTime(), dateFormat);
                  return !data.getPatId().equals(patId)
                          && treatDateTime.isAfter(treatStartDate)
                          && !treatDateTime.isAfter(treatEndDate);
                });
                // mod #10282 fixed OOM issue. ztc 20240516 end
                if (inOrOut) {
                  EventLogMessage LogMessage = new EventLogMessage();
                  LogMessage.setLogMessage("need to delete data: ord_no:" + unDeleteData.get(i).getOrdNo());
                  LogMessage.setFacilityCd(facilityCd);
                  logService.log(LogLevel.DEBUG, LogMessage, null, SERVICE_NAME.FNSI, null);
                  //上記trueの場合					（予定、指示：ベッドコード　が衝突の場合）
                  //ダミースケジュールを削除
                  ordNoDeleteAllList.add(unDeleteData.get(i).getOrdNo());
                  OrdMain om = new OrdMain();
                  om.setPatId(unDeleteData.get(i).getPatId());
                  om.setOrdNo(unDeleteData.get(i).getOrdNo());
                  //（※ジャーナル作成(/journal/create)）
                  ordMainDeleteAllList.add(om);
                } else {
                  //完全に占領されていない状況の補足
                  if (dummyDate.isAfter(treatEndDate)) {
                    OrdSchedule os = new OrdSchedule();
                    os.setOrdNo(ordNo);
                    os.setTreatDate(dummyTreatDate);
                    os.setKurCd(dummyKur);
                    os.setBedCd(indBedCd);
                    needToDelOsList.add(os);
                  } else {
                    //上記falseの場合					（予定、指示：ベッドコード　が衝突ないの場合）
                    //ダミースケジュールとしては、最後まで詰め込まれていない場合、作成しない
                    Long tempDummyKur = dummyKur;
                    String finalDummyTreatDate = dummyTreatDate;
                    if (osList.stream().anyMatch(data ->
                      data.getOrdNo().equals(ordNo)
                        && data.getTreatDate().equals(finalDummyTreatDate)
                        && data.getKurCd().equals(tempDummyKur))) continue;
                    tmp.setFacilityCd(facilityCd);
                    tmp.setOrdNo(ordNo);
                    tmp.setTreatDate(dummyTreatDate);
                    tmp.setTreatWeek((short) (dummyDate.getDayOfWeek().getValue()));
                    tmp.setKurCd(tempDummyKur);
                    tmp.setPatId(patId);
                    tmp.setBedCd(indBedCd);
                    tmp.setIsDummy("1");
                    //mod #10634 クールマスタで標準治療開始時刻を変更した際のダミー予定・連携イベント作成処理不正 zrx start
//                    ordScheduleList.add(tmp);
                    //determine if it exists Dummy
                    List<OrdSchedule> dummyExistsList = ordScheduleDao.selectByTreatDateBedCd(facilityCd, dummyTreatDate, indBedCd);
                    //Exists set ind_kur_cd = 0
                    if(dummyExistsList != null && !dummyExistsList.isEmpty() && dummyExistsList.size() > 1) {
                      boolean existsOrdMain = ordMainList.stream().anyMatch(o -> Objects.equals(o.getOrdNo(), ordNo));
                      if(!existsOrdMain) {
                        OrdMain om = new OrdMain();
                        om.setFacilityCd(facilityCd);
                        om.setPatId(patId);
                        om.setOrdNo(ordNo);
                        om.setTreatDate(dummyTreatDate);
                        ordMainList.add(om);
                        ordNoStr = ordNoStr + "," + ordNo.toString();
                      }
                    } else {//Does not exist insert ordSchedule
                      ordScheduleList.add(tmp);
                    }
                    //mod #10634 クールマスタで標準治療開始時刻を変更した際のダミー予定・連携イベント作成処理不正 zrx end
                  }
                }
              }
            }
          }

          loopProcess += loopPerProcess;
          setUpdKurProcess(processKey, loopProcess.intValue());  // #10282 ADD synchronize processing progress
      // add #10282 fixed OOM issue. ztc 20240516 start
        } // End of undeleteBedCdData loop

      } // End of undeleteBedCdData if
      // add #10282 fixed OOM issue. ztc 20240516 end


      List<PatPersonalMain> ppmList = patPersonalMainDao.selectSomePatColumnsListByFacility(facilityCd);
      //データ処理の最適化
      String ordNoDeleteAllStr = "-1";
      if (!ordNoDeleteAllList.isEmpty()) {
        ordNoDeleteAllStr = ordNoDeleteAllList.toString()
          .replace("[", "").replace("]", "").replace(" ", "");
        ordNoStr = ordNoStr + "," + ordNoDeleteAllStr;
        ordNoList.addAll(ordNoDeleteAllList);
      }
      StringBuilder errorMsg = new StringBuilder();
      if (!ordNoStr.isEmpty()) {
        List<OrdMainForCsv> csvList = ordMainDao.getAllDataBeforeChange(ordNoStr);
        for (OrdMainForCsv omfc : csvList) {
          Long patId = omfc.getPatId();
          String firstName = "";
          String lastName = "";
          List<PatPersonalMain> filterList = ppmList.stream().filter(person -> person.getPat_id().equals(patId)).toList();
          if (!filterList.isEmpty()) {
            firstName = filterList.get(0).getPat_first_name();
            lastName = filterList.get(0).getPat_last_name();
          } else {
            errorMsg.append("pat_id:").append(patId).append("，患者の名前が検索されませんでした");
          }
          String year = "";
          String month = "";
          String day = "";
          if (!omfc.getTreatDate().isEmpty() && omfc.getTreatDate().length() >= 8) {
            year = omfc.getTreatDate().substring(0, 4);
            month = omfc.getTreatDate().substring(4, 6);
            day = omfc.getTreatDate().substring(6, 8);
          } else {
            errorMsg.append("，患者の治療日を調べることができなかった");
          }
          String kurName = omfc.getKurName();
          String bedName = omfc.getBedName();
          String indTreatStartTimeBefore = omfc.getIndTreatStartTimeBefore();
          if (!"0".equals(indTreatStartTimeBefore) && indTreatStartTimeBefore.length() >= 4) {
            indTreatStartTimeBefore = indTreatStartTimeBefore.substring(0, 2) + ":" + indTreatStartTimeBefore.substring(2, 4);
          } else {
            indTreatStartTimeBefore = "未登録";
          }
          String indTreatStartTimeAfter = omfc.getIndTreatStartTimeAfter();
          resList.add(patId + "," + firstName + " " + lastName + "," + year + "/" + month + "/" + day + ","
            + kurName + "," + bedName + "," + indTreatStartTimeBefore + "," + indTreatStartTimeAfter + "\n");
        }

        if (CollectionUtils.isNotEmpty(csvList)) {
          PROCESSING_STATUS.get(processKey).setCsvList(resList);
        }

        setUpdKurProcess(processKey, 6);  // #10282 ADD synchronize processing progress

        //クールコード　と　指示：kur_cd，治療開始時刻が"未登録"を設定する。
        MstPersonalUser user = mstPersonalUserDao.selectById(userId);
        String userLastName = null;
        String userFirstName = null;
        if (user != null) {
          userFirstName = user.getUserFirstName();
          userLastName = user.getUserLastName();
        }
        MstPersonalUser updUser = mstPersonalUserDao.selectById(updUserId);
        String updUserLastName = null;
        String updUserFirstName = null;
        if (updUser != null) {
          updUserFirstName = updUser.getUserFirstName();
          updUserLastName = updUser.getUserLastName();
        }

        EventLogMessage resetLogMessage = new EventLogMessage();
        resetLogMessage.setLogMessage("reset data: " + ordNoStr);
        resetLogMessage.setFacilityCd(facilityCd);
        logService.log(LogLevel.DEBUG, resetLogMessage, null, SERVICE_NAME.FNSI, null);

        setUpdKurProcess(processKey, 7);  // #10282 ADD synchronize processing progress

        ordMainDao.resetAllChangedOrdMain(ordNoStr, userId, userLastName, userFirstName, updUserId, updUserLastName, updUserFirstName);

        setUpdKurProcess(processKey, 8);  // #10282 ADD synchronize processing progress

        //一括削除（isDummy=１）
        ordScheduleDao.deleteDummyScheduleByIsDummy(ordNoStr);
        setUpdKurProcess(processKey, 9);  // #10282 ADD synchronize processing progress

        //一括更新（isDummy=0のダミースケジュールに対して、クールコードが'0'を設定する。）
        ordScheduleDao.updateOrdScheduleForZeroData(ordNoStr);

        setUpdKurProcess(processKey, 10);  // #10282 ADD synchronize processing progress
      }

      if (!errorMsg.isEmpty()) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(errorMsg.toString());
        eventLogMessage.setFacilityCd(facilityCd);
        logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      }

      List<OrdSchedule> needToDelWithoutOrdMain = ordScheduleDao.getAllDeleteSchedule(facilityCd);
      if (!needToDelWithoutOrdMain.isEmpty()) {
        needToDelOsList.addAll(needToDelWithoutOrdMain);
      }

      setUpdKurProcess(processKey, 12);  // #10282 ADD synchronize processing progress

      if (!needToDelOsList.isEmpty()) {
        List<List<OrdSchedule>> tmpRes = new ArrayList<>();
        int size = needToDelOsList.size();
        int maxSize = 5000;
        for (int i = 0; i < size; i += maxSize) {
          int end = Math.min(i + maxSize, size);
          tmpRes.add(needToDelOsList.subList(i, end));
        }

        for (List<OrdSchedule> tmpList : tmpRes) {
          ordScheduleDao.deleteDummyByPrimaryKeys(facilityCd, tmpList);
        }

        setUpdKurProcess(processKey, 13);  // #10282 ADD synchronize processing progress
      }

      if (!ordMainDeleteAllList.isEmpty()) {
        journalList.addAll(ordMainDeleteAllList);
      }

      if (!ordScheduleList.isEmpty()) {
        //batch insert to schedule
        ordScheduleDao.batchInsert(ordScheduleList);
        setUpdKurProcess(processKey, 14);  // #10282 ADD synchronize processing progress
      }

      //（※ジャーナル作成(/journal/create)）
      if (!ordMainList.isEmpty()) {
        journalList.addAll(ordMainList);
      }

      //mod #10634 クールマスタで標準治療開始時刻を変更した際のダミー予定・連携イベント作成処理不正 zrx start
      List<OrdMain> distinctList = journalList.stream()
        .collect(Collectors.toMap(
          OrdMain::getOrdNo,   // key = ordNo
          o -> o,
          (oldVal, newVal) -> oldVal
        ))
        .values()
        .stream()
        .collect(Collectors.toList());

//      result.setJournalList(journalList);
      result.setJournalList(distinctList);
      //mod #10634 クールマスタで標準治療開始時刻を変更した際のダミー予定・連携イベント作成処理不正 zrx end

    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      EventLogMessage errorMsgs = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang start
      errorMsgs.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang end
      errorMsgs.setFacilityCd(facilityCd);
      logService.log(LogLevel.ERROR, errorMsgs, null, SERVICE_NAME.FNSI, null);
      throw new Exception(e.getMessage());
    }
    return result;
  }

  /* #10282 Create a new interface to synchronize processing progress. START */
  /**
   * Set the current processing progress to the global cache variables.
   *
   * @param key cache key
   * @param process current processing progress
   */
  @Override
  public void setUpdKurProcess(String key, int process) {

    if (PROCESSING_STATUS.containsKey(key)) {
      PROCESSING_STATUS.get(key).updateHasProcessedSize(process);
    }
  }

  /**
   * Retrieve the current processing progress from the global cache variables.
   *
   * @param key cache key
   * @return  current processing progress
   */
  @Override
  public OrdMainForJournal getUpdKurProcess(String key) {
    if (!StringUtils.hasText(key)) return null;
    if (PROCESSING_STATUS.containsKey(key)) {

      OrdMainForJournal processing = PROCESSING_STATUS.get(key);
      // When this progress was completed, we will remove this key from cache.
      if (processing != null) {

//        processing.synchronizeProcessed();

//        if ((Objects.equals(processing.getHasProcessedSize(), processing.getSpentTime().size())
        if (processing.getProcessing() == 100.0f || processing.getErrorCode() == 500) {
          // then a copy will return, and the original record will be removed.
          OrdMainForJournal tmpResult = new OrdMainForJournal();
          BeanUtils.copyProperties(processing, tmpResult);
          PROCESSING_STATUS.remove(key);
          return tmpResult;
        }
        return processing;
      }
    }
    return null;
  }

  /** initialize process progress */
  @Override
  public void initializeProcessCount(String facilityCd, String key) {
    if (this.checkUpdKurProcessIsRunning(facilityCd)) {

      //
//      List<Integer> processCounts = this.ordScheduleDao.getModifiedRecordRange(facilityCd);
//      if (CollectionUtils.isNotEmpty(processCounts))
//        PROCESSING_STATUS.put(key
//          , new OrdMainForJournal(
//            processCounts.get(0)
//            , processCounts.get(1)
//            , processCounts.get(2)));
      PROCESSING_STATUS.put(key, new OrdMainForJournal(0));
    }
  }

  /** remove cache */
  public void mainProcessHasFail(String key) {
    if (StringUtils.hasText(key) && PROCESSING_STATUS.containsKey(key)) {
      PROCESSING_STATUS.get(key).setErrorCode(HttpStatus.INTERNAL_SERVER_ERROR.value());
    }
  }

  /** Check process is running, is the process is running, the request will be refused. */
  public boolean checkUpdKurProcessIsRunning(String facilityCd) {
    // Step1: does cache is empty?
    boolean result = PROCESSING_STATUS.isEmpty();
    // Step2: dose cache has this key?
    if (!result) result = !PROCESSING_STATUS.containsKey(facilityCd);
    // Step3: dose cache keys contains?
    if (!result)
      result = PROCESSING_STATUS.keySet().stream().noneMatch(
        k -> StringUtils.startsWithIgnoreCase(k, facilityCd)
      );
    // Step4: does main process has finish?
    if (!result)
      result = PROCESSING_STATUS
        .entrySet().stream().noneMatch(
          entry ->
            StringUtils.startsWithIgnoreCase(entry.getKey(), facilityCd)
              && Objects.equals(entry.getValue().getHasProcessedSize(), entry.getValue().getSpentTime().size())

        );

    return result;
  }
  // add 9664 by kangjie 20240425 start
  @Override
  public void updateNewSteps(String fluidJsonString, List<Long> ords) {
    JSONObject json = new JSONObject(fluidJsonString);
    Long upIndUserId = null;
    Long upUserId = null;
    Iterator<String> keys = json.keys();
    while(keys.hasNext()) {
      String key = keys.next();
      JSONObject valueObject = json.getJSONObject(key);
      upIndUserId = valueObject.get("ind_user_id")==null? null:Long.valueOf(String.valueOf(valueObject.get("ind_user_id")));
      upUserId = valueObject.get("upd_user_id")==null? null:Long.valueOf(String.valueOf(valueObject.get("upd_user_id")));
      break;
    }
    ordMainDao.updateNewSteps(fluidJsonString,ords,upIndUserId,upUserId);
  }
  // add 9664 by kangjie 20240425 end
  // add 9664 by kangjie 20240513 start
  @Override
  public FutureOrdMainConditionInfo findFutureOrdMainConditionInfo(Long patId, String facilityCd, String treatDateFrom, String treatDateTo, List<Integer> weeks, List<Integer> treats, List<Long> kurs) {
    OrdMainConditionSetting ordMainConditionSetting = ordMainDao.findFutureOrdMainConditionInfo(patId, facilityCd, treatDateFrom, treatDateTo, weeks, treats, kurs);
    FutureOrdMainConditionInfo result = new FutureOrdMainConditionInfo();
    if(ordMainConditionSetting != null) {
      Integer indDeviceMode = ordMainConditionSetting.getIndDeviceMode();
      CondIvEnum condIvEnum = CondIvEnum.getByDeviceMode(indDeviceMode);
      if(condIvEnum.equals(CondIvEnum.特殊浄化) || condIvEnum.equals(CondIvEnum.不明)) {
        JSONArray conditionSetting = new JSONArray(ordMainConditionSetting.getTreatmentConditionSetting());
        boolean isUseCondIv = this.checkTreatCondIsUse(conditionSetting, "19");
        result.setIndTreatCondIvMode(isUseCondIv ? CondIvEnum.OFF_LINE : CondIvEnum.NO_IV);
      }else {
        result.setIndTreatCondIvMode(condIvEnum.getState());
      }
      List<Integer> isUsedCtlNos = ordMainDao.findFutureOrdMainConditionIsUsedCtlNos(patId, facilityCd, treatDateFrom, treatDateTo, weeks, treats, kurs);
      result.setIsUsedCtlNos(isUsedCtlNos);
    }
    return result;
  }
  // add 9664 by kangjie 20240513 end
  /* #10282 Create a new interface to synchronize processing progress. END */

  /** クールマスタの拡張情報を格納するクラス */
  @Getter
  @Setter
  private static class MstKurEx extends MstKur {
    /**
     * 最初のクールフラグ(true:最初のクール、false:最後のクール以外)
     */
    private Boolean isFirstKur;

    private static MstKurEx parse(MstKur base) {
      MstKurEx ret = new MstKurEx();
      ret.setKurCd(base.getKurCd());
      ret.setKurStandardStartTime(base.getKurStandardStartTime());
      ret.setKurStartTime(base.getKurStartTime());
      ret.setKurEndTime(base.getKurEndTime());
      ret.setIsFirstKur(false);
      return ret;
    }
  }

  /**
   * 次クール情報取得
   * @param mstKur クールマスタ情報
   * @param currentKurCd 現在クール
   * @return 正常終了:次クール情報、異常終了:null
   */
  private MstKurEx calcNextKurInfo(List<MstKur>mstKur, long currentKurCd) {
    MstKurEx targetKur = null;
    Boolean isCurrentKur = false;
    if (!mstKur.isEmpty()) {
      for (int i = 0; i < mstKur.size(); i++) {
        // 次クール判定
        if (isCurrentKur) {
          // 次クールを返す
          targetKur = MstKurEx.parse(mstKur.get(i));
          break;
        }
        // 現在クール判定(最後のクールは除外)
        if ((i != mstKur.size()-1) && (currentKurCd == mstKur.get(i).getKurCd().longValue())) {
          isCurrentKur = true;
        }
      }
      // 次クールが見つからなかった場合は最初のクールを返す
      if (!isCurrentKur) {
        targetKur = MstKurEx.parse(mstKur.get(0));
        targetKur.setIsFirstKur(true);
      }
    }

    return targetKur;
  }
  //add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 end

  // add #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc start
  public int findByPatIdDateListCd(String facility_cd, Long pat_id, List<Map<String, String>> moveOutDateMapList){
    return ordMainDao.findByPatIdDateListCd(facility_cd, pat_id, moveOutDateMapList);
  }
  // add #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc end

  // add 10443 身体情報・DW・目標体重バグ 関  start
  public OrdMain getTreatDate(Long patId, String facilityCd, String treatDateFrom, List<Integer> weeks, List<Integer> treats, List<Long> kurs, boolean isIndFlag) {
    return ordMainDao.selectFirstTreatDate(patId, facilityCd, treatDateFrom, weeks, treats, kurs, isIndFlag);
  }
  // add 10443 身体情報・DW・目標体重バグ 関  end

  // add #11717【因島】曜日パターン変更の動作が遅い fang start
  @Transactional
  public void update(List<OrdMain> ordMains) {
    List<OrdMain> oldList = ordMainDao.selectByOrdNoList(ordMains.stream().map(el -> el.getOrdNo()).collect(Collectors.toList()));
    if(ordMains.size() > 300) {
      for(int i = 0; i < ordMains.size(); i = i + 300) {
        if(i + 300 > ordMains.size()) {
          ordMainDao.batchUpdate(ordMains.subList(i, ordMains.size()));
        } else {
          ordMainDao.batchUpdate(ordMains.subList(i, i + 300));
        }
      }
    } else {
      ordMainDao.batchUpdate(ordMains);
    }
    getHistoryBatch(ordMains.stream().map(el -> el.getOrdNo()).collect(Collectors.toList()));
    List<OrdMain> newList = ordMainDao.selectByOrdNoList(ordMains.stream().map(el -> el.getOrdNo()).collect(Collectors.toList()));
    triggerUtil.updateTriggerOrdMain(oldList, newList);
  }

  private void getHistoryBatch(List<Long> ordNos) {
    selectHistoryUtils.insertMangoDbHistoryBatch(ordNos);
  }

  /**
   * 曜日パターン変更チェック
   * @param bodyData
   * @return
   */
  private OrdMainWeekPatternResponse doOrdMainAndPatternCheck(ApiEntityOrdMain.ValiWeekPattern bodyData) {
    if(bodyData.getSkip()) {
      List<OrdMain> result = ordMainDao.doOrdMainCheckOfWeekChange(bodyData.getFacility_cd(), Long.parseLong(bodyData.getPat_id()),
        bodyData.getInd_treat_start_date().replace("-", ""), bodyData.getEnd_date().replace("-", ""),
        bodyData.getUpdateList(), bodyData.getCopyList(), bodyData.getDelList(), Integer.parseInt(bodyData.getInd_treatment_cd()));
      OrdMainWeekPatternResponse response = new OrdMainWeekPatternResponse();
      if(result != null && result.size() > 0) {
        JSONObject responseData = new JSONObject("{}");
        responseData.put("nobedlist",result.stream().map(el -> el.getOrdNo()).collect(Collectors.toList()));
        response.setBody(responseData.toString());
        response.setHeaders(null);
        response.setStatus(HttpStatus.OK);
      } else {
        response.setBody("skip");
      }
      return response;
    }
    return null;
  }
  // add #11717【因島】曜日パターン変更の動作が遅い fang end

  @Override
  public HashMap<String,OrdInfoListForPatListByOrdNoResponse> getOrdInfoListForPatListByOrdNo(String facilityCd, List<Long> ordNoList) {
    // 対象の治療情報取得
    List<OrdMainForPatList> ordMainForPatList = ordMainDao.selectOrdInfoListForPatListByOrdNo(facilityCd, ordNoList);

    // 返却値設定
    // オーダー番号をキーとするマップで返す
    HashMap<String,OrdInfoListForPatListByOrdNoResponse> resMap = new HashMap<String,OrdInfoListForPatListByOrdNoResponse>();
    for (OrdMainForPatList data : ordMainForPatList) {
      OrdInfoListForPatListByOrdNoResponse res = new OrdInfoListForPatListByOrdNoResponse();

      // 共通値設定
      res.setRstDialysisState(data.getRstDialysisState());
      res.setViewTreatDate(data.getTreatDate().substring(0, 4) + "/" + data.getTreatDate().substring(4, 6) + "/"
          + data.getTreatDate().substring(6));
      res.setRoundState(org.apache.commons.lang3.StringUtils.isEmpty(data.getRstRoundsInfo()) ? "未" : "済");
      res.setRoundHighlighting(data.getRoundHighlighting());
      res.setKurStartTime(data.getRstDialysisState().equals("0") ? data.getIndKurStartTime() :data.getRstKurStartTime());
      res.setBedOrderIndex(data.getRstDialysisState().equals("0") ? data.getIndBedOrderIndex() : data.getRstBedOrderIndex());

      // 回診状態ソート用値算出
      String roundStateSort = "0";
      if(org.apache.commons.lang3.StringUtils.isEmpty(data.getRstRoundsInfo())) {
        // 回診なしは重要度が一番最大になるように大きな値を設定
        roundStateSort = "999";
      }else if(org.apache.commons.lang3.StringUtils.isNotEmpty(data.getRoundHighlighting())) {
        roundStateSort = data.getRoundHighlighting();
      }

      // ソート用の値設定
      res.setTreatDateForSort(data.getTreatDate());
      res.setRoundStateForSort(roundStateSort);

      // 開始・終了・終了予定の日時とソート用値を算出
      SimpleDateFormat sdf = new SimpleDateFormat("HH:mm");
      SimpleDateFormat sdf2 = new SimpleDateFormat("yyyyMMddHHmm");

      String startTime = ObjectUtils.isEmpty(data.getRstStartDate()) ? "" : sdf.format(data.getRstStartDate());
      String startTimeForSort = ObjectUtils.isEmpty(data.getRstStartDate()) ? null : sdf2.format(data.getRstStartDate());
      String endTime = ObjectUtils.isEmpty(data.getRstEndDate()) ? "" : sdf.format(data.getRstEndDate());
      String endTimeForSort = ObjectUtils.isEmpty(data.getRstEndDate()) ? null : sdf2.format(data.getRstEndDate());
      String endScheduleTime = "";
      String endScheduleTimeForSort = null;

      // 終了予定はステータス1～3のみで使用なのでその場合のみ計算
      if (List.of("1", "2", "3").stream().anyMatch(data.getRstDialysisState()::contains)) {
        Long treatTime = getTreatTimeByOrdMainForPatList(data.getTreatTime());
        if (org.apache.commons.lang3.StringUtils.isNotEmpty(startTime) && !ObjectUtils.isEmpty(treatTime)) {
          LocalDateTime endSchedule = data.getRstStartDate().toLocalDateTime().plusMinutes(treatTime);
          endScheduleTime = endSchedule.format(DateTimeFormatter.ofPattern("HH:mm"));
          endScheduleTimeForSort = endSchedule.format(DateTimeFormatter.ofPattern("uuuuMMddHHmm"));
        }
      }

      // 治療状況ごとの設定
      switch (data.getRstDialysisState()) {
      case "0":
        setOrdInfoListForPatListByOrdNoResEachDialysisState(res,"予定","",null,"",null,"",null);
        break;
      case "1":
        setOrdInfoListForPatListByOrdNoResEachDialysisState(res,"前体重測定済",startTime,startTimeForSort,endScheduleTime,endScheduleTimeForSort,"",null);
        break;
      case "2":
        setOrdInfoListForPatListByOrdNoResEachDialysisState(res,"患者確認済",startTime,startTimeForSort,endScheduleTime,endScheduleTimeForSort,"",null);
        break;
      case "3":
        setOrdInfoListForPatListByOrdNoResEachDialysisState(res,"治療中",startTime,startTimeForSort,endScheduleTime,endScheduleTimeForSort,"",null);
        break;
      case "4":
        setOrdInfoListForPatListByOrdNoResEachDialysisState(res,"後体重未測定",startTime,startTimeForSort,endTime,endTimeForSort,endTime,endTimeForSort);
        break;
      case "5":
        setOrdInfoListForPatListByOrdNoResEachDialysisState(res,"未確定実績",startTime,startTimeForSort,endTime,endTimeForSort,endTime,endTimeForSort);
        break;
      case "6":
        setOrdInfoListForPatListByOrdNoResEachDialysisState(res,"確定実績",startTime,startTimeForSort,endTime,endTimeForSort,endTime,endTimeForSort);
        break;
      }

      // オーダーNoをキーに返却値のモデルを値として返却
      resMap.put(String.valueOf(data.getOrdNo()), res);
    }
    return resMap;
  }

  /**
   * 患者リスト用治療情報レスポンス設定(治療状況別部分)
   *
   * @param res レスポンス
   * @param DialysisState 治療状況
   * @param startTime 開始時刻
   * @param startTimeForSort 開始時刻(ソート用)
   * @param endScheduleTime 終了予定時刻
   * @param endScheduleTimeForSort 終了予定時刻(ソート用)
   * @param endTime 終了時刻
   * @param EndTimeForSort 終了時刻(ソート用)
   */
  private void setOrdInfoListForPatListByOrdNoResEachDialysisState(OrdInfoListForPatListByOrdNoResponse res,
      String DialysisState,
      String startTime,
      String startTimeForSort,
      String endScheduleTime,
      String endScheduleTimeForSort,
      String endTime,
      String EndTimeForSort) {
    res.setDialysisState(DialysisState);
    res.setStartTime(startTime);
    res.setStartTimeForSort(startTimeForSort);
    res.setEndScheduleTime(endScheduleTime);
    res.setEndScheduleTimeForSort(endScheduleTimeForSort);
    res.setEndTime(endTime);
    res.setEndTimeForSort(EndTimeForSort);
  }

  /**
   * 患者リスト用治療情報治療時間取得
   *
   * @param json jsonデータ
   * @return 治療時間
   */
  private Long getTreatTimeByOrdMainForPatList(String json) {
    Long treatTime = null;
    if (org.apache.commons.lang3.StringUtils.isNotEmpty(json)) {
      JSONObject jsonObject = new JSONObject(json);
      if (jsonObject.has("value")) {
        Object treatTimeStr = jsonObject.get("value");
        if (treatTimeStr != JSONObject.NULL && !treatTimeStr.toString().isEmpty()) {
          treatTime = Long.parseLong(treatTimeStr.toString());
        }
      }
    }
    return treatTime;
  }
}
