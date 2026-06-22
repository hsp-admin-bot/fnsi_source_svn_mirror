package jp.co.nikkiso.ntss.admin_web.service.statusList;

import tools.jackson.core.JacksonException;
import tools.jackson.core.type.TypeReference;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;
import tools.jackson.databind.node.ArrayNode;
import tools.jackson.databind.node.ObjectNode;
import com.google.gson.Gson;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.FlagType;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.MachineType;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebMessage;
import jp.co.nikkiso.ntss.admin_web.request.deviceEdgeOrder.DeviceEdgeOrderRequest;
import jp.co.nikkiso.ntss.admin_web.request.statusList.CheckAfterWeightRequest;
import jp.co.nikkiso.ntss.admin_web.request.statusList.DeleteRecordRequest;
import jp.co.nikkiso.ntss.admin_web.response.deviceEdgeOrder.DeviceEdgeOrderResponse;
import jp.co.nikkiso.ntss.admin_web.response.statusList.CheckMediDoneResponse;
import jp.co.nikkiso.ntss.admin_web.response.statusList.DispItemListResponse;
import jp.co.nikkiso.ntss.admin_web.response.statusList.TreatmentStatusListResponse;
import jp.co.nikkiso.ntss.admin_web.response.statusList.TreatmentStatusUpdateResponse;
import jp.co.nikkiso.ntss.admin_web.response.weight.SendConditionResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.FacilitySettingService;
import jp.co.nikkiso.ntss.admin_web.service.OrdMainService;
import jp.co.nikkiso.ntss.admin_web.service.SelectHistoryUtils;
import jp.co.nikkiso.ntss.admin_web.service.SysMonitorItemService;
import jp.co.nikkiso.ntss.admin_web.service.autoPrint.AutoPrintService;
import jp.co.nikkiso.ntss.admin_web.service.deviceEdgeOrder.DeviceEdgeOrderService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.statusList.dto.StatusListDTO;
import jp.co.nikkiso.ntss.admin_web.service.statusList.dto.condInfo.CondInfo;
import jp.co.nikkiso.ntss.admin_web.service.statusList.dto.condInfo.CondInfoService;
import jp.co.nikkiso.ntss.admin_web.service.utils.DateTimeUtils;
import jp.co.nikkiso.ntss.admin_web.service.utils.StrUtils;
import jp.co.nikkiso.ntss.admin_web.service.webSocketNotify.WebSocketNotifyService;
import jp.co.nikkiso.ntss.api.service.PatMainAcceptanceStatusInfo.PatMainAcceptanceStatusInfoService;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MniMonitorDao;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.dao.MstAddMonitorDao;
import jp.co.nikkiso.ntss.core.dao.MstBedDao;
import jp.co.nikkiso.ntss.core.dao.MstComsvSettingDao;
import jp.co.nikkiso.ntss.core.dao.MstDialyzerDao;
import jp.co.nikkiso.ntss.core.dao.MstEquipmentDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.MstKurDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineTypeDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineMixDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstReportDao;
import jp.co.nikkiso.ntss.core.dao.MstRoomBedGroupDao;
import jp.co.nikkiso.ntss.core.dao.MstRoundTypeDao;
import jp.co.nikkiso.ntss.core.dao.MstSelectorDao;
import jp.co.nikkiso.ntss.core.dao.MstStatusMapBedLayoutDao;
import jp.co.nikkiso.ntss.core.dao.MstTreatmentDao;
import jp.co.nikkiso.ntss.core.dao.MstTreatmentStatusDispItemDao;
import jp.co.nikkiso.ntss.core.dao.MstTreatmentStatusLayoutDao;
import jp.co.nikkiso.ntss.core.dao.MstVaDao;
import jp.co.nikkiso.ntss.core.dao.OrdChecklistDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainRestoreDao;
import jp.co.nikkiso.ntss.core.dao.OrdMaterialSaveDao;
import jp.co.nikkiso.ntss.core.dao.PatEventDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.PatUniqueDao;
import jp.co.nikkiso.ntss.core.dao.SysMonitorItemDao;
import jp.co.nikkiso.ntss.core.dao.TreatmentStatusListDao;
import jp.co.nikkiso.ntss.core.dto.ordMaterialSave.OrdMaterialSaveDto;
import jp.co.nikkiso.ntss.core.entity.MniMonitor;
import jp.co.nikkiso.ntss.core.entity.MniMonitorCalendr;
import jp.co.nikkiso.ntss.core.entity.MntMachineFormat;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.MstAddMonitor;
import jp.co.nikkiso.ntss.core.entity.MstBed;
import jp.co.nikkiso.ntss.core.entity.MstComsvSetting;
import jp.co.nikkiso.ntss.core.entity.MstDialyzer;
import jp.co.nikkiso.ntss.core.entity.MstEquipment;
import jp.co.nikkiso.ntss.core.entity.MstKur;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.MstMachineType;
import jp.co.nikkiso.ntss.core.entity.MstMedicine;
import jp.co.nikkiso.ntss.core.entity.MstMedicineMix;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstRoomBedGroup;
import jp.co.nikkiso.ntss.core.entity.MstRoundType;
import jp.co.nikkiso.ntss.core.entity.MstSelector;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.MstTreatmentStatusDispItem;
import jp.co.nikkiso.ntss.core.entity.MstTreatmentStatusLayout;
import jp.co.nikkiso.ntss.core.entity.MstVa;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.OrdMainRestore;
import jp.co.nikkiso.ntss.core.entity.OrdMaterialSave;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.PatUnique;
import jp.co.nikkiso.ntss.core.entity.RoughMonitorData;
import jp.co.nikkiso.ntss.core.entity.SysMonitorItem;
import jp.co.nikkiso.ntss.core.entity.custom.BedMachine;
import jp.co.nikkiso.ntss.core.entity.custom.MachineKeyInfo;
import jp.co.nikkiso.ntss.core.entity.custom.MtsMachineWithMachineRecordCd;
import jp.co.nikkiso.ntss.core.entity.custom.NumberOfUserTypeByOrdNo;
import jp.co.nikkiso.ntss.core.entity.custom.TreatmentStatusLayoutViewItems;
import jp.co.nikkiso.ntss.core.entity.custom.TreatmentStatusList;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.service.ordMaterialSaveService.OrdMaterialSaveService;
import lombok.Getter;
import lombok.Setter;
import org.apache.commons.collections4.CollectionUtils;
import org.apache.commons.lang3.math.NumberUtils;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.seasar.doma.jdbc.Config;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.TransactionDefinition;
import org.springframework.transaction.TransactionStatus;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.DefaultTransactionDefinition;
import org.springframework.util.ObjectUtils;
import org.springframework.util.StringUtils;

import java.lang.reflect.Field;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Timestamp;
import java.text.DecimalFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
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
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.TimeZone;
import java.util.function.Function;
import java.util.regex.Pattern;
import java.util.stream.Collectors;
import jp.co.nikkiso.ntss.core.config.DefaultDb;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Service
public class TreatmentStatusListServiceImpl<pubulic> implements TreatmentStatusListService {
  @Autowired
  DeviceEdgeOrderService deviceEdgeOrderService;

  @Autowired
  private TreatmentStatusListService treatmentStatusListService;

  /**
   * 自動レポート印刷サービス
   */
  @Autowired
  private AutoPrintService autoPrintService;

  //add #9616 帳票印刷失敗通知がされない 李 start
  @Value("${ntss.admin-web.web-api.url}/util/notificationReciever")
  private String webApi;
  //add #9616 帳票印刷失敗通知がされない 李 end

  //add FNSI redmine 5461 劉祥霖 start
  @Getter
  @Setter
  private class DummyScheduleInfo
  {
    /**
     * 施設コード
     */
    private String facilityCd;

    /**
     * 治療日
     */
    private String treatDate;

    /**
     * 治療曜日
     */
    private Short treatWeek;

    /**
     * クールコード
     */
    private Long kurCd;

    /**
     * 治療日時(治療日+クール内標準治療開始時刻)
     */
    private String treatDatetime;

    /**
     * 患者ID
     */
    private Long patId;

    /**
     * ベッドコード
     */
    private Long bedCd;

    /**
     * ダミーフラグ(true:ダミースケジュール、false:メインスケジュール)
     */
    private Boolean isDummy;
  }

  //add FNSI redmine 5461 劉祥霖 end

  //add FNSI 治療状況リストエラーの対応 xiebzh start
  @Autowired
  LogEventUtils logUtils;
  //add FNSI 治療状況リストエラーの対応 xiebzh start

  @Autowired
  TreatmentStatusListDao treatmentStatusListDao;
  @Autowired
  MniMonitorDao mniMonitorDao;
  @Autowired
  MntMachineStateDao mntMachineStateDao;
  @Autowired
  MstTreatmentStatusLayoutDao mstTreatmentStatusLayoutDao;
  @Autowired
  MstMachineTypeDao mstMachineTypeDao;
  @Autowired
  MstMachineDao mstMachineDao;
  @Autowired
  MstBedDao mstBedDao;
  @Autowired
  PatPersonalMainDao patPersonalMainDao;
  @Autowired
  OrdMainDao ordMainDao;
  @Autowired
  MstPersonalUserDao mstPersonalUserDao;
  @Autowired
  PatMainDao patMainDao;
  @Autowired
  WebSocketNotifyService sendWsMsg;
  @Autowired
  MstTreatmentDao mstTreatmentDao;
  @Autowired
  MstKurDao mstKurDao;
  @Autowired
  CondInfoService condInfoService;
  @Autowired
  PatUniqueDao patUniqueDao;
  @Autowired
  MstSelectorDao mstSelectorDao;
  @Autowired
  PatEventDao patEventDao;
  @Autowired
  SysMonitorItemDao sysMonitorItemDao;
  //add FNSI-redmine fang start
  @Autowired
  private OrdMainRestoreDao ordMainRestoreDao;
  //add FNSI-redmine fang end
  // #10457 2024.06.18 add デバイスエッジに通知タイミングで現患者クリアを実施 TDC高村 start
  @Autowired
  private MstComsvSettingDao mstComsvSettingDao;
  // #10457 2024.06.18 add デバイスエッジに通知タイミングで現患者クリアを実施 TDC高村 end

  /**
   * add FNSI 396 治療記録 -- Sanjingye Sun 20210119
   */
  @Autowired
  private MstEquipmentDao mstEquipmentDao;

  /**
   * add FNSI 396 治療記録 -- Sanjingye Sun 20210120
   */
  @Autowired
  private MstMedicineDao mstMedicineDao;

  /**
   * add FNSI 396 治療記録 -- Sanjingye Sun 20210120
   */
  @Autowired
  private MstMedicineMixDao mstMedicineMixDao;

  /**
   * add FNSI 396 治療記録 -- Sanjingye Sun 20210125
   */
  @Autowired
  private OrdMaterialSaveDao ordMaterialSaveDao;

  // add FNSI-改修内容追加ordChecklist処理 付 start
  @Autowired
  OrdChecklistDao ordChecklistDao;
  // add FNSI-改修内容追加ordChecklist処理 付 end

    // add #6746 dao層導入追加 查 start
  @Autowired
  private MstDialyzerDao mstDialyzerDao;

  @Autowired
  private MstVaDao mstVaDao;
  // add #6746 dao層導入追加 查 end

  /* add by chamaojia 2024-03-28 [10303、10304] introduction of adding dao layer interfaces --start */
  @Autowired
  private MstStatusMapBedLayoutDao mstStatusMapBedLayoutDao;
  /* add by chamaojia 2024-03-28 [10303、10304] introduction of adding dao layer interfaces --end */

  // add #9616 帳票印刷失敗通知がされない 高　start
  @Autowired
  private MstReportDao mstReportDao;

  @Autowired
  private MstFacilitySettingDao mstFacilitySettingDao;
  // add #9616 帳票印刷失敗通知がされない 高　end

  /**
  * ロギングのServiceインタフェース.
  */
  @Autowired
  private LogService logService;

  // add FNSI-改修内容追加OrdMain履歴 付 start
  @Autowired
  private SelectHistoryUtils selectHistoryUtils;
  // add FNSI-改修内容追加OrdMain履歴 付 end
  // add 6227 張 start
  @Autowired
  OrdMainService ordMainService;
  // add 6227 張 end
  @Autowired
  PatMainAcceptanceStatusInfoService patMainAcceptanceStatusInfoService;

  //  /**
  //   * add FNSI  治療記録 -- modify by WP  20210318
  //   */
//  @Autowired
//  StatusListDTO dto;

  /**
   * ObjectMapper.
   */
  @Autowired
  private ObjectMapper mapper;

  // DB更新ログ出力ロジック wangzuo Start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;
  @Autowired
  private LogServiceCore logServiceCore;
  // DB更新ログ出力ロジック wangzuo End
  // add #8315 ord_material_save.supplies_cd, supplies_class_medicine_mix_cdの登録・更新不正 dou start
  // 13：調整薬剤
  private static final String SUPPLIES_CLASS_MEDICINE_MIX = "13";
  // 15：処置調整薬剤
  private static final String SUPPLIES_CLASS_TREAT_MEDICINE_MIX = "15";
  // 20:分解薬剤
  private static final String SUPPLIES_CLASS_MEDICINE = "20";
  // 21:処置分解薬剤
  private static final String SUPPLIES_CLASS_TREAT_MEDICINE = "21";
  // 確定フラグ(1：確定)
  private static final String IS_CONFIRM = "1";
  // 指示·実績区分(2：実績)
  private static final String RST_CLASS = "2";
  // NULL
  private static final String NULL_VALUE = null;
  // add #8315 ord_material_save.supplies_cd, supplies_class_medicine_mix_cdの登録・更新不正 dou end

  private static final Map<Integer, Map<String, String>> condSettingMap = Map.ofEntries(
          // 目標体重
          Map.entry(6, Map.of("category_no", "2", "ctl_no", "3")),
          // VA
          Map.entry(73, Map.of("category_no", "1", "ctl_no", "2")),
          // 除水量制限
          Map.entry(74, Map.of("category_no", "2", "ctl_no", "4")),
          // ダイアライザ
          Map.entry(75, Map.of("category_no", "1", "ctl_no", "5")),
          // 吸着カラム
          Map.entry(76, Map.of("category_no", "1", "ctl_no", "6")),
          // 1次膜
          Map.entry(77, Map.of("category_no", "1", "ctl_no", "7")),
          // 2次膜
          Map.entry(78, Map.of("category_no", "1", "ctl_no", "8")),
          // 穿刺針(A針)
          Map.entry(79, Map.of("category_no", "7", "ctl_no", "9")),
          // 穿刺針(V針)
          Map.entry(80, Map.of("category_no", "7", "ctl_no", "10")),
          // 穿刺針(SN)
          Map.entry(81, Map.of("category_no", "7", "ctl_no", "11")),
          // シングルニードル使用
          Map.entry(82, Map.of("category_no", "7", "ctl_no", "12")),
          // 血液回路
          Map.entry(83, Map.of("category_no", "1", "ctl_no", "13")),
          // 血流量
          Map.entry(84, Map.of("category_no", "1", "ctl_no", "14")),
          // 透析液
          Map.entry(85, Map.of("category_no", "3", "ctl_no", "15")),
          // 透析液流量
          Map.entry(86, Map.of("category_no", "3", "ctl_no", "16")),
          // 透析液量
          Map.entry(87, Map.of("category_no", "3", "ctl_no", "17")),
          // 透析液温度
          Map.entry(88, Map.of("category_no", "3", "ctl_no", "18")),
          // 補液
          Map.entry(89, Map.of("category_no", "4", "ctl_no", "19")),
          // 補液量
          Map.entry(90, Map.of("category_no", "4", "ctl_no", "20")),
          // 補液選択
          Map.entry(91, Map.of("category_no", "4", "ctl_no", "21")),
          // 補液使用数
          Map.entry(92, Map.of("category_no", "4", "ctl_no", "22")),
          // 補液温度
          Map.entry(93, Map.of("category_no", "4", "ctl_no", "23")),
          // 補液速度
          Map.entry(94, Map.of("category_no", "4", "ctl_no", "24")),
          // 抗凝固剤
          Map.entry(95, Map.of("category_no", "5", "ctl_no", "25")),
          // 抗凝固剤ワンショット量
          Map.entry(96, Map.of("category_no", "5", "ctl_no", "26")),
          // 抗凝固剤持続速度
          Map.entry(97, Map.of("category_no", "5", "ctl_no", "27")),
          // 抗凝固剤持続総量
          Map.entry(98, Map.of("category_no", "5", "ctl_no", "28")),
          // IP使用選択
          Map.entry(99, Map.of("category_no", "6", "ctl_no", "29")),
          // IPスタート
          Map.entry(100, Map.of("category_no", "6", "ctl_no", "30")),
          // IPワンショット量
          Map.entry(101, Map.of("category_no", "6", "ctl_no", "31")),
          // IP速度
          Map.entry(102, Map.of("category_no", "6", "ctl_no", "32")),
          // IP速度最大値
          Map.entry(103, Map.of("category_no", "6", "ctl_no", "33")),
          // IPワンショットスタート
          Map.entry(104, Map.of("category_no", "6", "ctl_no", "34")),
          // IP電源自動切り
          Map.entry(105, Map.of("category_no", "6", "ctl_no", "35")),
          // IP電源自動切り時間
          Map.entry(106, Map.of("category_no", "6", "ctl_no", "36")),
          // IP電源OKモニタ切り
          Map.entry(107, Map.of("category_no", "6", "ctl_no", "37")),
          // IP電源OKモニタ切り時間
          Map.entry(108, Map.of("category_no", "6", "ctl_no", "38"))
  );

  /**
   * add FNSI 1006 No.396 治療記録 part  - Sanjingye Sun 20210125
   */
  @Autowired
  private OrdMaterialSaveService ordMaterialSaveService;

  /* mod #8872 by zhangruixue 2023-06-21 --start */
  @Autowired
  private MstRoomBedGroupDao mstRoomBedGroupDao;
  /* mod #8872 by zhangruixue 2023-06-21 --end */

  // #10337 2024.04.25 add 明示的トランザクション TDC片口 start
  @Autowired
  PlatformTransactionManager transactionManager;
  // #10337 2024.04.25 add 明示的トランザクション TDC片口 end

  @Autowired
  private FacilitySettingService facilitySettingService;

  @Autowired
  private MstRoundTypeDao mstRoundTypeDao;

  @Override
  public List<TreatmentStatusList> selectAll(String facilityCd) {
    List<TreatmentStatusList> treatmentStatusList = treatmentStatusListDao.selectAll(facilityCd);

    return treatmentStatusList;
  }

  @Override
  public List<TreatmentStatusList> selectOrdMain(String facilityCd, String treatDate) {
    return treatmentStatusListDao.selectOrdMain(facilityCd, treatDate);
  }

  @Override
  public List<TreatmentStatusList> selectOrdMainOnMachine(String facilityCd) {
    return treatmentStatusListDao.selectOrdMainOnMachine(facilityCd);
  }

  @Override
  public List<TreatmentStatusList> selectOrdMainUnedition(String facilityCd) {
    return treatmentStatusListDao.selectOrdMainUnedition(facilityCd);
  }

  @Override
  public List<TreatmentStatusList> selectOrdMainOnSchedule(String facilityCd, String treatDate) {
    return treatmentStatusListDao.selectOrdMainOnSchedule(facilityCd, treatDate);
  }

  //add FNSI redmine 5461 劉祥霖 start
  public List<TreatmentStatusList> selectOrdMainRstTreatInfoByTreatDate(String facilityCd, String treatDate) {
    return treatmentStatusListDao.selectOrdMainRstTreatInfoByTreatDate(facilityCd, treatDate);
  }
  /**
   * {@inheritDoc}
   */
  @Override
  /* upd by chamaojia 2026-03-14 [12462] 患者情報共有->患者経過総合ビューア --start */
  public List<MniMonitorCalendr> monitorSelectByOrdNos(List<Map<String, Object>> facilityCdAndOrdNoList) {
    return mniMonitorDao.selectByOrdNos(facilityCdAndOrdNoList);
  }
  /* upd by chamaojia 2026-03-14 [12462] 患者情報共有->患者経過総合ビューア --end */
  //add FNSI redmine 5461 劉祥霖 end

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MniMonitor> monitorSelectByOrdNo(Long ordNo) {
    return mniMonitorDao.selectByOrdNo(ordNo);
  }

  @Override
  public List<MniMonitor> monitorSelectNowOrdNoDataType(String ordNo, Short dataType) {
    return mniMonitorDao.selectNowOrdNoDataType(ordNo, dataType);
  }

  @Override
  public List<MniMonitor> monitorSelectNowMachineDataType(String facilityCd, String machineTypeCd, String machineSerial,
      Short dataType) {
    return mniMonitorDao.selectNowMachineDataType(facilityCd, machineTypeCd, machineSerial, dataType);
  }

  @Override
  public List<MntMachineState> machineSelectAllByFacilityCd(String facilityCd) {
    List<MntMachineState> mntMachineStateList = mntMachineStateDao.selectMachinesWithModelByFacilityCd(facilityCd);

    return mntMachineStateList;
  }

  @Override
  public List<MstTreatmentStatusLayout> mstTreatmentStatusLayoutSelectByFacilityCd(String facilityCd) {

    List<MstTreatmentStatusLayout> res = new ArrayList<MstTreatmentStatusLayout>();
    // マスタセレクタ―順に整列したマスタ本体のリストを取得
    MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, "mst_treatment_status_layout");
    List<MstTreatmentStatusLayout> mstTreatmentStatusLayout = mstTreatmentStatusLayoutDao
        .selectAllByFacilityCd(facilityCd);
    if (Objects.isNull(mstSelector) || mstSelector.getOrderSettings().getItems().isEmpty()) {
      return res;
    } else {
      for (MstSelector.Item selector : mstSelector.getOrderSettings().getItems()) {
        Optional<MstTreatmentStatusLayout> grp = mstTreatmentStatusLayout.stream()
            .filter(elem -> Objects.equals(elem.getLayoutNo(), selector.getCode().longValue()))
            .findFirst();
        if (!Objects.isNull(grp) && grp.isPresent() && grp.get().getIsDisp().equals(FlagType.FLAG_ON)) {
          res.add(grp.get());
        }
      }
      return res;
    }
  }

  @Override
  public List<BedMachine> getBedMachineList(String facilityCd) {
    List<BedMachine> res = new ArrayList<BedMachine>();
    // マスタセレクタ―順に整列したマスタ本体のリストを取得
    MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, "mst_bed");
    List<BedMachine> bedMachine = mstBedDao.selectBedMachineByFacilityCd(facilityCd);
    if (Objects.isNull(mstSelector) || mstSelector.getOrderSettings().getItems().isEmpty()) {
      return res;
    } else {
      for (MstSelector.Item selector : mstSelector.getOrderSettings().getItems()) {
        Optional<BedMachine> grp = bedMachine.stream()
            .filter(elem -> Objects.equals(elem.getBedCd(), selector.getCode().longValue()))
            .findFirst();
        if (!Objects.isNull(grp) && grp.isPresent()) {
          res.add(grp.get());
        }
      }
      return res;
    }
  }

  // #10338 2024.04.25 del 実績確定処理updateCheckAfterWeightを改修し不使用になった TDC片口 start
//  /**
//   * 確認ボタン押下時処理
//   * ord_mainの初版確定、ステータス、版番号更新
//   */
//  @Override
//  @Transactional
//  public int updateCheckAfterWeight(List<CheckAfterWeightRequest> ordInfoList, String facilityCd) {
//    Date nowDate = new Date();
//    int rtn = 0;
//
//    // 投薬の実施状況を取得
//    /// まず対象となるオーダー番号のリストを作成
//    List<Long> ordNoList = new ArrayList<Long>();
//    for (int lop = 0; lop < ordInfoList.size(); lop++) {
//      CheckAfterWeightRequest ordInfo = ordInfoList.get(lop);
//      ordNoList.add(ordInfo.getOrdNo());
//    }
//    /// オーダー番号のリストに対応する投薬の実施状況を取得
//    List<OrdMain> ordMainList = ordMainDao.selectMediInfoByNoList(ordNoList);
//    //add #10196 Ord_Material_Save operation 20240126 ztc start
//    List<MaterialSaveCacheHandler.DiffResultContainer> diffMaterialSaveRstList = new ArrayList<>();
//    //add #10196 Ord_Material_Save operation 20240126 ztc end
//    for (int lop1 = 0; lop1 < ordInfoList.size(); lop1++) {
//      CheckAfterWeightRequest ordInfo = ordInfoList.get(lop1);
//      Long ordNo = ordInfo.getOrdNo();
//      Long userId = ordInfo.getUserId();
//
//      // ordNoに対応したmediInfo(JSON文字列)を取得
//      String mediInfo = "";
//      for (int lop2 = 0; lop2 < ordMainList.size(); lop2++) {
//        OrdMain ordMain = ordMainList.get(lop2);
//        if (Objects.equals(ordMain.getOrdNo(), ordNo)) {
//          mediInfo = ordMain.getRstMediInfo();
//          break;
//        }
//      }
//
//      // 未実施の投薬を実施にする場合
//      if (ordInfo.isDoCompleteMedi() && !mediInfo.isEmpty()) {
//        // mediInfo JSON文字列を更新
//        mediInfo = this.updateMediInfoToComplete(mediInfo, nowDate, userId);
//      }
//
//      // add FNSI-改修内容追加OrdMain履歴 付 start
//      getHistory(ordNo);
//      // mangoDb-updateCheckAfterWeight-insertSuccess
//      // add FNSI-改修内容追加OrdMain履歴 付 end
//
//      // DB更新ログ出力ロジック wangzuo Start
//      String tableNameCheck = "ord_main";
//      // SQL検索条件
//      StringBuffer wheresCheck = new StringBuffer("");
//      wheresCheck.append(" WHERE\n");
//      wheresCheck.append(" ord_no = " + ordNo + "\n");
//      // logCommon設定
//      DataUpdateLogCommonNew logCommonCheck = getLogCommon(ordMainDao, tableNameCheck, wheresCheck, getEventLogMessage());
//      // ログ出力カラム情報及び更新前データ情報取得
//      boolean setResultCheck = logCommonCheck.setInfo();
//      // DB更新ログ出力ロジック wangzuo End
//
//      // ord_mainを更新
//      int result = ordMainDao.updateCheckAfterWeight(ordNo, mediInfo);
//
//      OrdMain ordMainForConfirm = ordMainDao.selectByOrdNo(ordNo);
////      add 8074 【デグレ】ログに誤った利用者が記録される 関 start
//      NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
//      ordMainForConfirm.setLogUserId(user.getUserId().toString());
////      add 8074 【デグレ】ログに誤った利用者が記録される 関  end
//      ordMainForConfirm.setRstEditionDate(new Timestamp(System.currentTimeMillis()));
//
//      ordMainForConfirm.setCurEditionDate(new Timestamp(System.currentTimeMillis()));
//      //add FNSI-redmine5863&5865 fang start
//      if (ordMainForConfirm.getRstEndDate() == null) {
//        if (ordMainForConfirm.getRstInputClass() != null && "2".equals(String.valueOf(ordMainForConfirm.getRstInputClass()))) {
//          String tempTreatDate = ordMainForConfirm.getTreatDate();
//          String tempTreatStartTime = ordMainForConfirm.getIndTreatStartTime();
//          if (tempTreatDate != null && tempTreatStartTime != null
//            && !"".equals(tempTreatDate) && !"".equals(tempTreatStartTime)) {
//            String tempTreatDateAndTIme = tempTreatDate + " " + tempTreatStartTime;
//            SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd HHmm");
//            try {
//              Date tempDate = sdf.parse(tempTreatDateAndTIme);
//              if (ordMainForConfirm.getRstCondInfo() != null) {
//                JSONObject treatmentInfoObj = new JSONObject(ordMainForConfirm.getRstCondInfo());
//                if (treatmentInfoObj.has("1")) {
//                  JSONObject treatMentTimeInfo = (JSONObject) treatmentInfoObj.get("1");
//                  if (treatMentTimeInfo.has("value")) {
//// mod #6899 2022/8/10 治療状況リストで実績確定を行っても実績確定されず再度リストに表示される。 dou start
////                    Integer tempTreatTime = treatMentTimeInfo.getInt("value");
////                    if (tempTreatTime != null) {
////                      Calendar timeCalendar = Calendar.getInstance();
////                      timeCalendar.setTime(tempDate);
////                      timeCalendar.add(Calendar.MINUTE, tempTreatTime);
//                    Object tempTreatTime = treatMentTimeInfo.get("value");
//                    if (tempTreatTime != null && isInteger(String.valueOf(tempTreatTime))) {
//                      Calendar timeCalendar = Calendar.getInstance();
//                      timeCalendar.setTime(tempDate);
//                      timeCalendar.add(Calendar.MINUTE, Integer.parseInt(String.valueOf(tempTreatTime)));
//// mod #6899 2022/8/10 治療状況リストで実績確定を行っても実績確定されず再度リストに表示される。 dou end
//                      ordMainForConfirm.setRstEndDate(new Timestamp(timeCalendar.getTimeInMillis()));
//                    }
//                  }
//                }
//              }
//            } catch (ParseException e) {
//              e.printStackTrace();
//            }
//          }
//        }
//      }
//      //add FNSI-redmine5863&5865 fang end
//
//      // add #8642 「治療記録>変更履歴の内容が不正」について、対応する。 dengshen start
//      ordMainForConfirm.setUpdateFlg(false);
//      // add #8642 「治療記録>変更履歴の内容が不正」について、対応する。 dengshen end
//      ordMainDao.update(ordMainForConfirm);
//      // add #8642 「治療記録>変更履歴の内容が不正」について、対応する。 dengshen start
//      ordMainForConfirm.setUpdateFlg(true);
//      // add #8642 「治療記録>変更履歴の内容が不正」について、対応する。 dengshen end
//
//      // DB更新ログ出力ロジック wangzuo Start
//      // 更新後データ取得、差分あれば、log出力
//      if (setResultCheck && result > 0) {
//        logCommonCheck.updateLog();
//      }
//      // DB更新ログ出力ロジック wangzuo End
//
//      // add FNSI-改修内容追加OrdMain履歴 付 start
//      selectHistoryUtils.insertMangoDbHistory(7, ordNo, null, new ArrayList<>(), new ArrayList<>(), null, null,
//        null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
//        new ArrayList<>(), null, null);
//      // mangoDb-updateIsConfirm-insertSuccess
//      // add FNSI-改修内容追加OrdMain履歴 付 end
//
//      // DB更新ログ出力ロジック wangzuo Start
//      String tableNameIs = "ord_main";
//      // SQL検索条件
//      StringBuffer wheresIs = new StringBuffer("");
//      wheresIs.append(" WHERE\n");
//      wheresIs.append(" is_confirm = '0'\n");
//      wheresIs.append(" and ord_no = " + ordNo + "\n");
//      // logCommon設定
//      DataUpdateLogCommonNew logCommonIs = getLogCommon(ordMainDao, tableNameIs, wheresIs, getEventLogMessage());
//      // ログ出力カラム情報及び更新前データ情報取得
//      boolean setResultIs = logCommonIs.setInfo();
//      // DB更新ログ出力ロジック wangzuo End
//
//      // 版確定フラグを「1：確定」にする
//      int updateCountIs = ordMainDao.updateIsConfirm(ordNo, "0", "1");
//
//      // DB更新ログ出力ロジック wangzuo Start
//      // 更新後データ取得、差分あれば、log出力
//      if (setResultIs && updateCountIs > 0) {
//        logCommonIs.updateLog();
//      }
//      // DB更新ログ出力ロジック wangzuo End
//
//      // 治療記録を取得する
//      OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
//
//      //  del 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
//      // add FNSI-改修内容追加ordChecklist処理 付 start
//      //      if (Objects.equals(ordMain.getRstDialysisState(), "5")) {
//      //        ordChecklistDao.updateRstClass(ordNo);
//      //      }
//      // add FNSI-改修内容追加ordChecklist処理 付 end
//      //  del 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
//      // 透析回数の取得
//      Long dialCount = ordMain.getRstDialysisCnt() == null ? 0L : ordMain.getRstDialysisCnt();
//      // 浄化治療回数の取得
//      Long purificateCount = ordMain.getRstPurificationCnt() == null ? 0L : ordMain.getRstPurificationCnt();
//
//      // オーダーの患者IDから患者基本情報を取得
//      PatMain patMain = patMainDao.selectById(ordMain.getPatId());
//      if (patMain != null) {
//        String medicalCareInfo = patMain.getMedical_care_info() == null ? "{}" : patMain.getMedical_care_info();
//        try {
//          JsonNode nodeMedicalCareInfo = null;
//          ObjectNode objectNode = null;
//
//          //
//          nodeMedicalCareInfo = mapper.readTree(medicalCareInfo);
//          objectNode = nodeMedicalCareInfo.deepCopy();
//
//          // 治療方法を取得して患者基本情報の透析回数か浄化治療回数を更新
//          MstTreatment treat = mstTreatmentDao.selectByCd(ordMain.getRstTreatmentCd());
//          if (treat.getDeviceMode().equals(9)) {
//            // 特殊浄化：浄化治療回数「purification_count」
//            objectNode.put("purification_count", purificateCount);
//          } else {
//            // 透析：透析回数「dialysis_count」
//            objectNode.put("dialysis_count", dialCount);
//            //add 6832 【デグレ】治療記録における特殊血液浄化回数が不正 周安寧　start
//            // 患者通算透析奇数
//            Long patdialysisCount = objectNode.get("pat_dialysis_count") == null ? 0L : objectNode.get("pat_dialysis_count").asLong();
//
//            objectNode.put("pat_dialysis_count", patdialysisCount + 1);
//            //add 6832 【デグレ】治療記録における特殊血液浄化回数が不正 周安寧　end
//          }
//
//          // DB更新ログ出力ロジック wangzuo Start
//          patMain.setPat_id(ordMain.getPatId());
//          // DB更新ログ出力ロジック wangzuo End
//          //add 6832 【デグレ】治療記録における特殊血液浄化回数が不正 周安寧　start
//          patMain.setMedical_care_info(objectNode.toString());
//          //add 6832 【デグレ】治療記録における特殊血液浄化回数が不正 周安寧　end
//          // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
//          LogEventUtils.setOperatorId(patMain);
//          // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
//          patMainDao.updateById(ordMain.getPatId(), patMain);
//        } catch (Exception e) {
//          EventLogMessage eventLogMessage = new EventLogMessage();
//          eventLogMessage.setLogMessage("API updateCheckAfterWeight: update dialysis count failure. " + e.getMessage());
//          logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_TREATMENT_RECORD, SERVICE_NAME.REMS, null);
//        }
//      }
//
//      // 患者ID
//      Long patId = ordMain.getPatId();
//
//      // pat_mainのステータスを更新
//      // pat_mainのacceptance_status_infoを更新する。
//      patMainAcceptanceStatusInfoService.update(patId, ordNo, rstDialysisState.BEFORE_SEND_CONDITIOM, null, null);
//
//      //add FNSI修正 305 房 start
//      if (Objects.equals(ordMain.getRstInputClass(), 1)) {
//        // comsv_settingの次患者切り替えタイミングの設定によりmnt_machine_stateの現患者クリアAPIを呼び出す
//        // 通信サーバーに後体重確認信号を通知
//        SendConditionResponse r = postSendAfterWeightWs(ordNo, facilityCd);
//        if (r.isSuccess) {
//          EventLogMessage eventLogMessage = new EventLogMessage();
//          eventLogMessage.setLogMessage("確認ボタン押下時処理：updateCheckAfterWeight() 通信サーバーへ通知しました。(ord_no:" + ordNo + ")");
//          logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_TREATMENT_RECORD, SERVICE_NAME.REMS, null);
//        } else {
//          EventLogMessage eventLogMessage = new EventLogMessage();
//          eventLogMessage.setLogMessage(
//            "確認ボタン押下時処理：updateCheckAfterWeight() 通信サーバーへの通知に失敗しました。(ord_no:" + ordNo + ")\n" + r.errorMessage);
//          logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_TREATMENT_RECORD, SERVICE_NAME.REMS, null);
//        }
//      }
//      //add FNSI修正 305 房 end
//
//      rtn = rtn + result;
//      // mod #9845 愁訴処置に入力した薬剤がord_material_saveに登録されない start
//      //mod #10196 Ord_Material_Save operation 20240126 ztc start
////      ordMaterialSaveService.updateOrdMaterialSave(new OrdMaterialSaveDto(
//      MaterialSaveCacheHandler.DiffResultContainer diffMaterialSaveRst = ordMaterialSaveService.updateOrdMaterialSaveByDiff(new OrdMaterialSaveDto(
//        ordNo,
//        true,
//        true,
//        true,
//        true,
//        "2",
//        ordMain
//      ));
//      diffMaterialSaveRstList.add(diffMaterialSaveRst);
//      // mod #9845 愁訴処置に入力した薬剤がord_material_saveに登録されない end
//    }
//    if(diffMaterialSaveRstList.size() > 0){
//      ordMaterialSaveService.batchProcessingData(diffMaterialSaveRstList);
//    }
//    //mod #10196 Ord_Material_Save operation 20240126 ztc end
//    return rtn;
//  }
  // #10338 2024.04.25 del 実績確定処理updateCheckAfterWeightを改修し不使用になった TDC片口 end
  // add #6899 2022/8/10 治療状況リストで実績確定を行っても実績確定されず再度リストに表示される。 dou start
  public static boolean isInteger(String str) {
    Pattern pattern = Pattern.compile("^[-\\+]?[\\d]*$");
    return pattern.matcher(str).matches();
  }
  // add #6899 2022/8/10 治療状況リストで実績確定を行っても実績確定されず再度リストに表示される。 dou end

  // mod FNSI-改修内容5702修正 xuty start
  private List<MntMachineFormat> machineSelectAllWithFormatByFacilityCd(String facilityCd) {
    List<MntMachineFormat> mntMachineStateList = mntMachineStateDao.selectMachinesWithFormatByFacilityCd(facilityCd);

    return mntMachineStateList;
  }
  // mod FNSI-改修内容5702修正 xuty end

  /**
   * add FNSI - 396 治療記録 実績確定 -- Sanjingye Sun 20210126
   * @param ordMain
   */
  private void omsResultConfirm(OrdMain ordMain) {
    List<OrdMaterialSave> omsList = new ArrayList<>();

    OrdMaterialSave baseOms = new OrdMaterialSave();
    baseOms.setFacilityCd(ordMain.getFacilityCd());
    baseOms.setPatId(ordMain.getPatId());
    baseOms.setSuppliesBaseDate(ordMain.getTreatDate());
    baseOms.setSuppliesBaseNo(ordMain.getOrdNo());

    JSONObject baseOmsJO = new JSONObject(baseOms);
    String omsJson = baseOmsJO.toString();

    // データ発生元区分: 0 - 治療条件
    String rstCondInfoJson = ordMain.getRstCondInfo();
    if(rstCondInfoJson != null && !rstCondInfoJson.equals("{}")) {

      Gson g = new Gson();
      OrdMaterialSave condInfoOms = g.fromJson(omsJson, OrdMaterialSave.class);
      condInfoOms.setSuppliesSourceClass("0");

      JSONObject condInfoOmsJO = new JSONObject(condInfoOms);
      String condInfoOmsJson = condInfoOmsJO.toString();

      try {
        JSONObject condInfoObj = new JSONObject(rstCondInfoJson);

        // 物品区分 00：血液回路
        addEquipmentMaterialBySuppliesClass(omsList, condInfoOmsJson, condInfoObj, "13", "00");

        // 物品区分 01：ダイアライザ
        if(condInfoObj.has("5")) {

          Object condInfo5Obj = condInfoObj.get("5");
          if(condInfo5Obj instanceof JSONObject condInfo05JO) {

            if(!condInfo05JO.isNull("value")) {

              OrdMaterialSave condInfo01Oms = g.fromJson(condInfoOmsJson, OrdMaterialSave.class);
              condInfo01Oms.setSuppliesClass("01");

              // 物品コード
              condInfo01Oms.setSuppliesCd(String.valueOf(condInfo05JO.get("value")));

              // 指示・実績区分 2：実績
              condInfo01Oms.setIndRstClass("2");
              // 指示・実績値
              condInfo01Oms.setIndRstValue("1");
              //add 8496 2023-04-06 【IES起票】【ord_material_save】医材に関するレせ値がない 張 start
              //レセ値
              condInfo01Oms.setReceiptValue("1");
              //add 8496 2023-04-06 【IES起票】【ord_material_save】医材に関するレせ値がない 張 start
              // 確定フラグ
              condInfo01Oms.setIsConfirm("1");

              // 登録日時 and 更新日時
              Timestamp tm = Timestamp.from(Instant.now());
              condInfo01Oms.setRegDate(tm);
              condInfo01Oms.setUpDate(tm);

              omsList.add(condInfo01Oms);
            }
          }

        }

        // 物品区分 02：吸着カラム
        addEquipmentMaterialBySuppliesClass(omsList, condInfoOmsJson, condInfoObj, "6", "02");

        // 物品区分 03：1次膜
        addEquipmentMaterialBySuppliesClass(omsList, condInfoOmsJson, condInfoObj, "7", "03");

        // 物品区分 04：2次膜
        addEquipmentMaterialBySuppliesClass(omsList, condInfoOmsJson, condInfoObj, "8", "04");

        // 物品区分 05：シングルニードル
        //addEquipmentMaterialBySuppliesClass(omsList, condInfoOmsJson, condInfoObj, "12", "05");
        addEquipmentMaterialBySuppliesClass(omsList, condInfoOmsJson, condInfoObj, "11", "05");

        // 物品区分 06：穿刺針(A)
        addEquipmentMaterialBySuppliesClass(omsList, condInfoOmsJson, condInfoObj, "9", "06");

        // 物品区分 07、穿刺針(V)
        addEquipmentMaterialBySuppliesClass(omsList, condInfoOmsJson, condInfoObj, "10", "07");

        // 物品区分 08 透析液
        addEquipmentMaterialBySuppliesClass(omsList, condInfoOmsJson, condInfoObj, "15", "08");

        // 物品区分 09 補液
        addEquipmentMaterialBySuppliesClass(omsList, condInfoOmsJson, condInfoObj, "19", "09");

        // 物品区分 10 抗凝固剤
        addEquipmentMaterialBySuppliesClass(omsList, condInfoOmsJson, condInfoObj, "25", "10");

      } catch (JSONException e) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("Data rst_cond_info in table ord_main is not a valid json.\r" + e.getMessage());
        logService.log(LogLevel.WARN, eventLogMessage, FUNCTION_CODE.FUNC_TREATMENT_RECORD, SERVICE_NAME.REMS, null);
      }

    }
    // データ発生元区分: 1 - 投与薬剤
    String rstMediInfoJson = ordMain.getRstMediInfo();
    if(rstMediInfoJson != null && !rstMediInfoJson.equals("[]")) {

      Gson g = new Gson();
      OrdMaterialSave mediInfoOms = g.fromJson(omsJson, OrdMaterialSave.class);
      mediInfoOms.setSuppliesSourceClass("1");

      JSONObject mediInfoOmsJO = new JSONObject(mediInfoOms);
      String mediInfoOmsJson = mediInfoOmsJO.toString();

      try {

        JSONArray mediInfoArray = new JSONArray(rstMediInfoJson);

        // 通常薬剤 <code,amount> map
        Map<Integer, Double> commonMediMap = new HashMap<>();

        // 調整薬剤 <code, amount> map
        Map<Integer, Double> mixMediMap = new HashMap<>();

        Iterator<Object> iterator = mediInfoArray.iterator();
        while(iterator.hasNext()) {

          Object mediObj = iterator.next();
          if(mediObj instanceof JSONObject mediJO) {

            if (mediJO.has("medicine_type")
              && !mediJO.isNull("medicine_type")
              && mediJO.has("cd")
              && !mediJO.isNull("cd")) {

              //mod FNSI修正治療記録外結バッグ76 房 start
              if (mediJO.has("effect_flg") && !mediJO.isNull("effect_flg")) {
                Object effectFlg = mediJO.get("effect_flg");
                int effectFlag = 0;
                if (effectFlg instanceof Integer) {
                  effectFlag = (int)effectFlg;
                } else if (effectFlg instanceof String) {
                  effectFlag = Integer.parseInt((String)effectFlg);
                }
                if (effectFlag == 1) {
                  Object medicineTypeObj = mediJO.get("medicine_type");
                  Object mediCdObj = mediJO.get("cd");

                  if((medicineTypeObj instanceof Integer || medicineTypeObj instanceof String)
                    && (mediCdObj instanceof Integer || mediCdObj instanceof String)) {

                    // 薬剤コード
                    int mediCd = 0;
                    if(mediCdObj instanceof Integer) {
                      mediCd = (int)mediCdObj;
                    } else if(mediCdObj instanceof String) {
                      mediCd = Integer.parseInt((String)mediCdObj);
                    }
                    // 薬剤区分
                    int medicineType = 0;
                    if(medicineTypeObj instanceof Integer) {
                      medicineType = (int)medicineTypeObj;
                    } else if(medicineTypeObj instanceof String) {
                      medicineType = Integer.parseInt((String)medicineTypeObj);
                    }

                    switch(medicineType) {
                      // 通常薬剤
                      case 1:
                        // make medicine map
                        makeMediMap(commonMediMap, mediJO, mediCd);

                        break;
                      // 調製薬剤
                      case 2:
                        makeMediMap(mixMediMap, mediJO, mediCd);
                        break;
                    }
                  }
                }
              }
              //mod FNSI修正治療記録外結バッグ76 房 end
            }
          }
        }

        // Make common medicine data 物品区分 12：投与薬剤
        makeCommonMedicineData(omsList, mediInfoOmsJson, commonMediMap, "12");

        // Make mix medicine data. 物品区分 13：調整薬剤
        makeMixMedicineData(omsList, mediInfoOmsJson, mixMediMap, "13");

      } catch (JSONException e) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("Data rst_medi_info in table ord_main is not a valid json.\r" + e.getMessage());
        logService.log(LogLevel.WARN, eventLogMessage, FUNCTION_CODE.FUNC_TREATMENT_RECORD, SERVICE_NAME.REMS, null);
      }

    }

    // データ発生元区分: 2 - 医療材料
    String rstEquipInfoJson = ordMain.getRstEquipInfo();
    if(rstEquipInfoJson != null && !rstEquipInfoJson.equals("[]")) {
      Gson g = new Gson();
      OrdMaterialSave equipInfoOms = g.fromJson(omsJson, OrdMaterialSave.class);
      equipInfoOms.setSuppliesSourceClass("2");

      JSONObject equipInfoOmsJO = new JSONObject(equipInfoOms);
      String equipInfoOmsJson = equipInfoOmsJO.toString();

      try {

        JSONArray equipInfoArray = new JSONArray(rstEquipInfoJson);

        // 医療材料 <code,amount> map equipInfoMap
        /*
            {
              "${equipmentCd1}": "${amount1}",
              "${equipmentCd1}" + "ClassCd": "${equipmentClassCd1}",
              "${equipmentCd2}": "${amount2}",
              "${equipmentCd2}" + "ClassCd": "${equipmentClassCd2}",
              ...
            }
         */
        Map<String, String> equipInfoMap = new HashMap<>();

        Iterator<Object> iterator = equipInfoArray.iterator();
        while(iterator.hasNext()) {

          Object equipObj = iterator.next();
          if(equipObj instanceof JSONObject equipJO) {

            // Get equipment code.
            Object equipCdObj = equipJO.get("cd");

            // Get equipment amount.
            Object amountObj = equipJO.get("amount");

            // Get equipment class code.
            Object classCdObj = equipJO.get("class_cd");

            //FNSI-修正 #6007紐づく治療記録画面の修正、xugj modify start
            // Get equipment class code.
            Object classTypeObj = equipJO.get("class_type");

            if(
              (equipCdObj != null && (equipCdObj instanceof Integer || equipCdObj instanceof String))
              && (amountObj != null && (amountObj instanceof Number || amountObj instanceof String))
              && (classCdObj != null && (classCdObj instanceof Integer || classCdObj instanceof String))
              //FNSI-del #6824 ljx  start
              //classTypeが未登録である場合があるので、この判断を外す。
              //&& (classTypeObj != null && (classTypeObj instanceof Integer || classTypeObj instanceof String))
              //FNSI-del #6824 ljx  end
            ) {

              // 医療材料コード
              String equipCd = String.valueOf(equipCdObj);

              double amount = 0;
              if(amountObj instanceof Number) {
                amount = ((Number)amountObj).doubleValue();
              } else if(amountObj instanceof String) {
                amount = Double.parseDouble((String)amountObj);
              }

              // 医療材料分類コード
              String equipClassCd = String.valueOf(classCdObj);
              // 医療材料分類区分
              String equipClassType = String.valueOf(classTypeObj);

              // Add the same medicine amount together.
              if(equipInfoMap.containsKey(equipCd)) {
                equipInfoMap.put(equipCd, Double.parseDouble(equipInfoMap.get(equipCd)) + amount + "");
              } else {
                equipInfoMap.put(equipCd, amount + "");
                equipInfoMap.put(equipCd + "ClassCd", equipClassCd);
                equipInfoMap.put(equipCd + "ClassType", equipClassType);
              }
            }
            //FNSI-修正 #6007紐づく治療記録画面の修正、xugj modify end
          }
        }

        // 他医療材料 data
        List<OrdMaterialSave> equipInfo11OmsList = equipInfoMap.keySet().stream().filter(key -> !(key.contains("ClassCd") || key.contains("ClassType"))).map(equipCd -> {

          OrdMaterialSave equipInfo11Oms = g.fromJson(equipInfoOmsJson, OrdMaterialSave.class);

          //FNSI-修正 #6007紐づく治療記録画面の修正、xugj add start
          // 医療材料分類区分
          String classType = equipInfoMap.get(equipCd + "ClassType");
          String suppliesClass;
          switch (classType) {
            case "1":
              suppliesClass = "00";
              break;
            //FNSI-add #6824 ljx add start
            case "0":
            //FNSI-add #6824 ljx add end
            case "2":
            //FNSI-mod #6824 ljx add start
            case "3":
              suppliesClass = "11";
              break;
            case "4":
              suppliesClass = "02";
              break;
            case "5":
              suppliesClass = "03";
              break;
            case "6":
              suppliesClass = "04";
              break;
            default:
              suppliesClass = "11";
              break;
            //FNSI-mod #6824 ljx add end
          }
          //FNSI-修正 #6007紐づく治療記録画面の修正、xugj add end
          // 物品区分：他医療材料
          equipInfo11Oms.setSuppliesClass(suppliesClass);

          // 物品コード -> 医療材料コード
          equipInfo11Oms.setSuppliesCd(equipCd);

          // 分類コード
          equipInfo11Oms.setClassCd(equipInfoMap.get(equipCd + "ClassCd"));

          // 指示・実績区分
          equipInfo11Oms.setIndRstClass("2");

          // 指示・実績値
          equipInfo11Oms.setIndRstValue(Math.round(Double.parseDouble(equipInfoMap.get(equipCd)))+"");
          //add 8496 2023-04-06 【IES起票】【ord_material_save】医材に関するレせ値がない 張 start
          // レセ値・実績値
          equipInfo11Oms.setReceiptValue(Math.round(Double.parseDouble(equipInfoMap.get(equipCd)))+"");
          //add 8496 2023-04-06 【IES起票】【ord_material_save】医材に関するレせ値がない 張 end
          // 確定フラグ
          equipInfo11Oms.setIsConfirm("1");

          // 登録日時 and 更新日時
          Timestamp tm = Timestamp.from(Instant.now());
          equipInfo11Oms.setRegDate(tm);
          equipInfo11Oms.setUpDate(tm);
          return equipInfo11Oms;

        }).collect(Collectors.toList());

        omsList.addAll(equipInfo11OmsList);

      } catch (JSONException e) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("Data rst_equip_info in table ord_main is not a valid json.\r" + e.getMessage());
        logService.log(LogLevel.WARN, eventLogMessage, FUNCTION_CODE.FUNC_TREATMENT_RECORD, SERVICE_NAME.REMS, null);
      }

    }

    // データ発生元区分: 3 - 愁訴処置
    String rstTreatmentInfoJson = ordMain.getRstTreatmentInfo();
    if(rstTreatmentInfoJson != null && !rstTreatmentInfoJson.equals("[]")) {
      Gson g = new Gson();
      OrdMaterialSave treatmentInfoOms = g.fromJson(omsJson, OrdMaterialSave.class);
      treatmentInfoOms.setSuppliesSourceClass("3");

      JSONObject treatmentInfoOmsJO = new JSONObject(treatmentInfoOms);
      String treatmentInfoOmsJson = treatmentInfoOmsJO.toString();
      try {

        JSONArray treatmentInfoArray = new JSONArray(rstTreatmentInfoJson);

        // 処置薬剤 <code,amount> map
        Map<Integer, Double> treatmentMediMap = new HashMap<>();
        // 処置調整薬剤 <code, amount> map
        Map<Integer, Double> treatmentMixMediMap = new HashMap<>();

        Iterator<Object> iterator = treatmentInfoArray.iterator();
        while(iterator.hasNext()) {
          // 愁訴処置情報 Object
          Object treatmentInfoObj = iterator.next();
          if(treatmentInfoObj instanceof JSONObject treatmentInfoJO) {

            if (treatmentInfoJO.has("medicine_type")
              && !treatmentInfoJO.isNull("medicine_type")
              && treatmentInfoJO.has("treat_medicine_cd")
              && !treatmentInfoJO.isNull("treat_medicine_cd")) {

              Object medicineTypeObj = treatmentInfoJO.get("medicine_type");
              Object mediCdObj = treatmentInfoJO.get("treat_medicine_cd");

              if((medicineTypeObj instanceof Integer || medicineTypeObj instanceof String)
              && (mediCdObj instanceof Integer || mediCdObj instanceof String)) {

                // 薬剤コード
                int mediCd = 0;
                if(mediCdObj instanceof Integer) {
                  mediCd = (int)mediCdObj;
                } else if(mediCdObj instanceof String) {
                  mediCd = Integer.parseInt((String)mediCdObj);
                }
                // 薬剤区分
                int medicineType = 0;
                if(medicineTypeObj instanceof Integer) {
                  medicineType = (int)medicineTypeObj;
                } else if(medicineTypeObj instanceof String) {
                  medicineType = Integer.parseInt((String)medicineTypeObj);
                }

                switch(medicineType) {
                  // 通常薬剤
                  case 1:
                    // make medicine map
                    makeMediMap(treatmentMediMap, treatmentInfoJO, mediCd);

                    break;
                  // 調製薬剤
                  case 2:
                    makeMediMap(treatmentMixMediMap, treatmentInfoJO, mediCd);
                    break;
                }

              }

            }
          }
        }

        // Make common medicine data 物品区分 14：処置薬剤
        makeCommonMedicineData(omsList, treatmentInfoOmsJson, treatmentMediMap, "14");

        // Make mix medicine data. 物品区分 15：処置調整薬剤
        makeMixMedicineData(omsList, treatmentInfoOmsJson, treatmentMixMediMap, "15");

      } catch (JSONException e) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("Data rst_treatment_info in table ord_main is not a valid json.\r" + e.getMessage());
        logService.log(LogLevel.WARN, eventLogMessage, FUNCTION_CODE.FUNC_TREATMENT_RECORD, SERVICE_NAME.REMS, null);
      }

    }
//del FNSI redmine 6824 手動実績作成と実績確定をする際に、予定で作成される薬剤材料は削除しない。ljx start
/*    //mod FNSI修正治療記録外結バッグ76 房 start
    //mod FNSI redmine 7150 劉祥霖 start
//    List<OrdMaterialSave> ordMaterialSaves = ordMaterialSaveDao.selectOrdMaterialSaveBySuppliesBaseNo(ordMain.getOrdNo());
    List<OrdMaterialSave> ordMaterialSaves = ordMaterialSaveDao.selectOrdMaterialSaveBySuppliesBaseNo(ordMain.getOrdNo(),ordMain.getFacilityCd());
    //mod FNSI redmine 7150 劉祥霖 end
    List<Long> delOrdMaterialSaves = new ArrayList<Long>();
    if (ordMaterialSaves != null && ordMaterialSaves.size() > 0) {
      for (OrdMaterialSave ele : ordMaterialSaves) {
        //mod FNSI redmine 7150 劉祥霖 start
//        if (ele.getSuppliesSourceClass().equals("1")) {
        if (("1").equals(ele.getSuppliesSourceClass())) {
        //mod FNSI redmine 7150 劉祥霖 end
          delOrdMaterialSaves.add(ele.getOrdMaterialSaveNo());
        }
      }
    }
    if (delOrdMaterialSaves.size() > 0) {
      ordMaterialSaveDao.deleteOrdMaterialSaveByOrdMaterialSaveNo(delOrdMaterialSaves);
    }
    //mod FNSI修正治療記録外結バッグ76 房 end*/
    //del FNSI redmine 6824 手動実績作成と実績確定をする際に、予定で作成される薬剤材料は削除しない。ljx end
    // insert data
    if(!omsList.isEmpty()){
      ordMaterialSaveDao.insertBatch(omsList);
    }

  }

  /**
   * add FNSI No.396 治療記録 実績確定 -- Sanjingye Sun 20210122
   *  Extracted method. I don't know how to comment it yet.
   * @param omsList
   * @param condInfoOmsJson
   * @param condInfoObj
   * @param condInfoKey
   * @param suppliesClass
   */
  private void addEquipmentMaterialBySuppliesClass(List<OrdMaterialSave> omsList, String condInfoOmsJson, JSONObject condInfoObj, String condInfoKey, String suppliesClass) {

    if(condInfoObj.has(condInfoKey)) {
      Object condInfoXXObj = condInfoObj.get(condInfoKey);

      if (condInfoXXObj instanceof JSONObject condInfoXXJO) {
        if (condInfoXXJO.has("value") && !condInfoXXJO.isNull("value")) {
          Gson g = new Gson();
          OrdMaterialSave condInfoXXOms = g.fromJson(condInfoOmsJson, OrdMaterialSave.class);

          //FNSI-修正 #6007紐づく治療記録画面の修正、xugj add start
          Object mediCdObj = condInfoXXJO.get("value");

          // 薬剤コード
          int mediCd = 0;
          if(mediCdObj instanceof Integer) {
            mediCd = (Integer)mediCdObj;
          } else if(mediCdObj instanceof String) {
            mediCd = Integer.parseInt((String)mediCdObj);
          }

          // 薬剤情報取得
          MstMedicine mm = mstMedicineDao.selectByMediCd(mediCd);
          //add 9306 ljx start mmがnullである場合あるので、判断追加
          if(mm == null){
            return;
          }
          //add 9306 ljx end
          // 透析液、補液の場合
          if("08".equals(suppliesClass) || "09".equals(suppliesClass)) {
            String key = "";
            switch (suppliesClass) {
                // 透析液
              case "08":
                key = "17";
                break;
                // 補液
              case "09":
                key = "22";
                break;
            }
            // 物品区分
            condInfoXXOms.setSuppliesClass(suppliesClass);
            // 物品コード
            condInfoXXOms.setSuppliesCd(String.valueOf(condInfoXXJO.get("value")));
            // 分類コード
            condInfoXXOms.setClassCd(mm.getClassCd() + "");
            // 指示・実績区分 2：実績
            condInfoXXOms.setIndRstClass("2");

            // 指示or実績数量の取得
            double amount = 0;
            if(condInfoObj.has(key)) {
              Object amountObj = condInfoObj.get(key);

              if (amountObj instanceof JSONObject amountJO) {
                if (amountJO.has("value") && !amountJO.isNull("value")) {
                  if(amountJO.get("value") instanceof Number) {
                    amount = ((Number)amountJO.get("value")).doubleValue();
                  } else if(amountJO.get("value") instanceof String) {
                    amount = Double.parseDouble((String)amountJO.get("value"));
                  }
                }
              }
            }
            //FNSI-mod #6824 透析液、使用数を格納。 ljx start
            DecimalFormat df = new DecimalFormat();
            condInfoXXOms.setIndRstValue(df.format(amount));
            condInfoXXOms.setReceiptValue(df.format(amount));
            // 指示・実績値
            //condInfoXXOms.setIndRstValue(calcReceiptValue(mm, amount));
            // レセ値
            //condInfoXXOms.setReceiptValue(calcReceiptValue(mm, amount));
            //FNSI-mod #6824 透析液、使用数を格納。 ljx end
            // 確定フラグ
            condInfoXXOms.setIsConfirm("1");

            // 登録日時 and 更新日時
            Timestamp tm = Timestamp.from(Instant.now());
            condInfoXXOms.setRegDate(tm);
            condInfoXXOms.setUpDate(tm);
            //FNSI-add #6824 透析液、補液の場合は薬剤マスタで存在確認をする。 ljx start
            addMedicineMaterial(omsList, condInfoXXJO, condInfoXXOms);
            //FNSI-add #6824 透析液、補液の場合は薬剤マスタで存在確認をする。 ljx end
            // 抗凝固剤の場合
          } else if("10".equals(suppliesClass)) {
            // 抗凝固剤 <code,amount> map
            Map<Integer, Double> commonMediCondMap = new HashMap<>();
            // 抗凝固剤調製薬剤 <code, amount> map
            Map<Integer, Double> mixMediCondMap = new HashMap<>();

            Object medicineTypeObj = condInfoXXJO.get("medicine_type");
            if((medicineTypeObj instanceof Integer || medicineTypeObj instanceof String)) {
              // 薬剤区分
              int medicineType = 0;
              if(medicineTypeObj instanceof Integer) {
                medicineType = (int)medicineTypeObj;
              } else if(medicineTypeObj instanceof String) {
                medicineType = Integer.parseInt((String)medicineTypeObj);
              }

              // ワンショット量
              double oneShot = 0;
              if(condInfoObj.has("26")) {
                Object oneShotObj = condInfoObj.get("26");

                if (oneShotObj instanceof JSONObject oneShotJO) {
                  if (oneShotJO.has("value") && !oneShotJO.isNull("value")) {
                    if(oneShotJO.get("value") instanceof Number) {
                      oneShot = ((Number)oneShotJO.get("value")).doubleValue();
                    } else if(oneShotJO.get("value") instanceof String) {
                      oneShot = Double.parseDouble((String)oneShotJO.get("value"));
                    }
                  }
                }
              }
              // 持続総量
              double total = 0;
              if(condInfoObj.has("28")) {
                Object totalObj = condInfoObj.get("28");

                if (totalObj instanceof JSONObject totalJO) {
                  if (totalJO.has("value") && !totalJO.isNull("value")) {
                    if(totalJO.get("value") instanceof Number) {
                      total = ((Number)totalJO.get("value")).doubleValue();
                    } else if(totalJO.get("value") instanceof String) {
                      total = Double.parseDouble((String)totalJO.get("value"));
                    }
                  }
                }
              }
              switch(medicineType) {
                // 通常薬剤
                case 1:
                  makeCondCommonMedicineData(omsList, condInfoOmsJson, mediCd, "10", total + oneShot);
                  break;
                // 調製薬剤
                case 2:
                  makeCondMixMedicineData(omsList, condInfoOmsJson, mediCd, "17", total + oneShot);
                  break;
              }
            }
            //FNSI-修正 #6007紐づく治療記録画面の修正、xugj add end
          } else {
            // 物品区分
            condInfoXXOms.setSuppliesClass(suppliesClass);
            // データ発生元区分: 0 - 治療条件 -> 医療材料 data
            addEquipmentMaterial(omsList, condInfoXXJO, condInfoXXOms);
          }
        }
      }
    }
  }

  /**
   * 透析液、補液の場合、レセ値計算
   *
   * @param mm 薬剤情報
   * @param amount 使用数
   * @return レセ値
   */
  private String calcReceiptValue(MstMedicine mm, double amount) {
    String receipt = "";
    // get 指示・実績値
    int decimalPoint = mm.getUnitDecimalPoint();

    // 小数点桁数を正しく保持する
    // mod 内部指摘#5825対応する。「指示・実績値」の値の保存不正を修正する。 dengshen start
    // StringBuilder sb = new StringBuilder("#");
    StringBuilder sb = new StringBuilder("0");
    // mod 内部指摘#5825対応する。「指示・実績値」の値の保存不正を修正する。 dengshen end
    if (decimalPoint > 0) {
      sb.append(".");
      for (int i = 0; i <= decimalPoint; i++) {
        sb.append(0);
      }
    }

    DecimalFormat df = new DecimalFormat(sb.toString());

    if (mm.getAnticoagulantOriginalQuantity() != null && mm.getUnitConvertedAmountSecond() != null) {
      // 換算フラグ 0：換算、1：残量破棄、2：数量1固定
      String isExchange = mm.getIsExchange();
      switch (isExchange) {
        // 換算
        case "0":
          receipt = df.format(amount);
          break;
        // 残量破棄
        case "1":
          //（指示or実績数量 / 指示基準数量）(小数第一位切り上げ)＊ レセ換算値
          double midVal = 0;
          if (mm.getAnticoagulantOriginalQuantity().doubleValue() != 0.00000000000000000) {
            midVal = amount / mm.getAnticoagulantOriginalQuantity().doubleValue();
          }
          double receiptValue2 = Math.ceil(midVal) * mm.getUnitConvertedAmountSecond().doubleValue();
          receipt = df.format(receiptValue2);
          break;
        // 固定
        case "2":
          // レセ換算値
          receipt = amount + "";
          break;
      }
    }
    return receipt;
  }

  /**
   * add FNSI NO.396 治療記録 実績確定 -- Sanjingye Sun 20210122
   * Make mix medicine data
   * @param omsList
   * @param mediInfoOmsJson
   * @param mixMediMap
   */
  private void makeMixMedicineData(List<OrdMaterialSave> omsList, String mediInfoOmsJson, Map<Integer, Double> mixMediMap, String suppliesClass) {

    Set<Integer> mixMediMapKeySet = mixMediMap.keySet();

    if (mixMediMapKeySet.size() != 0) {

      List<Integer> mixMediCdList = new ArrayList<>(mixMediMapKeySet);

      List<MstMedicineMix> mmmList = mstMedicineMixDao.selectByMedicineMixCdList2(mixMediCdList);

      mmmList.stream().forEach(mmm -> {
        // add #8315 ord_material_save.supplies_cd, supplies_class_medicine_mix_cdの登録・更新不正 dou start
        Gson g = new Gson();
        OrdMaterialSave medimixInfo = g.fromJson(mediInfoOmsJson, OrdMaterialSave.class);
        // 物品区分
        medimixInfo.setSuppliesClass(suppliesClass);
        // 物品コード
        medimixInfo.setSuppliesCd(NULL_VALUE);
        // 調整薬剤コード
        medimixInfo.setMedicineMixCd(mmm.getMedicineMixCd().toString());
        // 分類コード
        medimixInfo.setClassCd(mmm.getClassCd().toString());
        // 指示·実績区分(2：実績)
        medimixInfo.setIndRstClass(RST_CLASS);
        // 指示·実績値
        int unitDecimalPoint = mmm.getUnitDecimalPoint();
        // 小数点桁数を正しく保持する
        // mod 内部指摘#5825対応する。「指示・実績値」の値の保存不正を修正する。 dengshen start
        // StringBuilder stringBuilder = new StringBuilder("#");
        StringBuilder stringBuilder = new StringBuilder("0");
        // mod 内部指摘#5825対応する。「指示・実績値」の値の保存不正を修正する。 dengshen end
        if(unitDecimalPoint > 0) {
          stringBuilder.append(".");
          // mod 8315 ljx start
          // 小数点桁数を正しく保持する
          //for(int i = 0; i <= unitDecimalPoint; i++) {
            for(int i = 0; i < unitDecimalPoint; i++) {
            stringBuilder.append(0);
          }
          // mod 8315 ljx end
        }
        DecimalFormat decimalFormat = new DecimalFormat(stringBuilder.toString());
        String indRstValueStr = decimalFormat.format(mixMediMap.get(mmm.getMedicineMixCd()));
        medimixInfo.setIndRstValue(indRstValueStr);
        // レセ値
        medimixInfo.setReceiptValue(NULL_VALUE);
        // 確定フラグ(1：確定)
        medimixInfo.setIsConfirm(IS_CONFIRM);
        // 登録日時 and 更新日時
        Timestamp tm = Timestamp.from(Instant.now());
        medimixInfo.setRegDate(tm);
        medimixInfo.setUpDate(tm);
        // add #8315 ord_material_save.supplies_cd, supplies_class_medicine_mix_cdの登録・更新不正 dou end
        String mixInfoJson = mmm.getMixInfo();

        if(mixInfoJson != null && !mixInfoJson.equals("[]")) {

          JSONArray mixInfoArray = new JSONArray(mixInfoJson);
          // 調整薬剤の通常薬剤 <code,amount> map
          Map<Integer, Double> commonMediOfMixMap = new HashMap<>();

          Iterator<Object> mixInfoIterator = mixInfoArray.iterator();
          while(mixInfoIterator.hasNext()) {
            Object mediObj = mixInfoIterator.next();
            if(mediObj instanceof JSONObject mediJO) {

              if (mediJO.has("cd") && !mediJO.isNull("cd")) {
                Object mediCdObj = mediJO.get("cd");
                if(mediCdObj instanceof Integer || mediCdObj instanceof String) {
                  // 薬剤コード
                  int mediCd = 0;
                  if (mediCdObj instanceof Integer) {
                    mediCd = (int) mediCdObj;
                  } else if (mediCdObj instanceof String) {
                    mediCd = Integer.parseInt((String) mediCdObj);
                  }

                  // make medicine map
                  makeMediMap(commonMediOfMixMap, mediJO, mediCd);
                }

              }
            }
          }

          Set<Integer> commonMediOfMixMapKeySet = commonMediOfMixMap.keySet();

          if (commonMediOfMixMapKeySet.size() != 0) {
            List<Integer> mediCdList = new ArrayList<>(commonMediOfMixMapKeySet);
            List<MstMedicine> mmList = mstMedicineDao.selectAllByCdList(SelectOptions.get(), mediCdList);

            List<OrdMaterialSave> mediInfo13OmsList = mmList.stream().map(mm -> {

              // del #8315 ord_material_save.supplies_cd, supplies_class_medicine_mix_cdの登録・更新不正 dou start
              // Gson g = new Gson();
              // del #8315 ord_material_save.supplies_cd, supplies_class_medicine_mix_cdの登録・更新不正 dou end
              OrdMaterialSave mediInfo13Oms = g.fromJson(mediInfoOmsJson, OrdMaterialSave.class);
              // 物品区分 13：調整薬剤
              // mod #8315 ord_material_save.supplies_cd, supplies_class_medicine_mix_cdの登録・更新不正 dou start
              // mediInfo13Oms.setSuppliesClass(suppliesClass);
              if (SUPPLIES_CLASS_MEDICINE_MIX.equals(suppliesClass)) {
                mediInfo13Oms.setSuppliesClass(SUPPLIES_CLASS_MEDICINE);
              } else if (SUPPLIES_CLASS_TREAT_MEDICINE_MIX.equals(suppliesClass)) {
                mediInfo13Oms.setSuppliesClass(SUPPLIES_CLASS_TREAT_MEDICINE);
              } else {
                mediInfo13Oms.setSuppliesClass(suppliesClass);
              }
              // mod #8315 ord_material_save.supplies_cd, supplies_class_medicine_mix_cdの登録・更新不正 dou end
              // 薬剤コード
              int mediCd = mm.getMedicineCd();

              // 物品コード
              mediInfo13Oms.setSuppliesCd(mediCd + "");

              //FNSI-修正 #6007紐づく治療記録画面の修正、xugj add start
              // 調製薬剤コード
              mediInfo13Oms.setMedicineMixCd(mmm.getMedicineMixCd() + "");
              //FNSI-修正 #6007紐づく治療記録画面の修正、xugj add end

              // 分類コード
              mediInfo13Oms.setClassCd(mm.getClassCd() + "");

              // 指示・実績区分 2 実績
              mediInfo13Oms.setIndRstClass("2");
              // get 指示・実績値
              int decimalPoint = mm.getUnitDecimalPoint();

              // 指示・実績値の編集処理
              Double mixMediAmount = mixMediMap.get(mmm.getMedicineMixCd());
              Double commonMediInMixAmount = commonMediOfMixMap.get(mediCd);
              // Real Medicine count = 調製薬剤*普通薬剤
              double amount = mixMediAmount.doubleValue() * commonMediInMixAmount.doubleValue();

              // 小数点桁数を正しく保持する
              // mod 内部指摘#5825対応する。「指示・実績値」の値の保存不正を修正する。 dengshen start
              // StringBuilder sb = new StringBuilder("#");
              StringBuilder sb = new StringBuilder("0");
              // mod 内部指摘#5825対応する。「指示・実績値」の値の保存不正を修正する。 dengshen end
              if(decimalPoint > 0) {
                sb.append(".");
                // mod 8315 ljx start
                // 小数点桁数を正しく保持する
                //for(int i = 0; i <= decimalPoint; i++) {
                  for(int i = 0; i < decimalPoint; i++) {
                  sb.append(0);
                }
                // mod 8315 ljx end
              }

              DecimalFormat df = new DecimalFormat(sb.toString());
              String amountStr = df.format(amount);

              // 指示・実績値
              mediInfo13Oms.setIndRstValue(amountStr);
              // mod #8315 ord_material_save.supplies_cd, supplies_class_medicine_mix_cdの登録・更新不正 dou start
              // add 6824 周安寧 start
              // String receiptValue = BigDecimal.ZERO.setScale(decimalPoint, BigDecimal.ROUND_HALF_UP).toString();
              // add 6824 周安寧 end
              Integer unitDecimalPointSecond = mm.getUnitDecimalPointSecond();
              // mod 「指示・実績値」の値の保存不正を修正する。 dengshen start
              // String receiptValue = BigDecimal.ZERO.setScale(unitDecimalPointSecond, BigDecimal.ROUND_HALF_UP).toString();
              String receiptValue = BigDecimal.ZERO.setScale(unitDecimalPointSecond, BigDecimal.ROUND_HALF_UP).toPlainString();
              // mod 「指示・実績値」の値の保存不正を修正する。 dengshen start
              // mod #8315 ord_material_save.supplies_cd, supplies_class_medicine_mix_cdの登録・更新不正 dou end
              //FNSI-修正 #6007紐づく治療記録画面の修正、xugj add start
              // del 6824 周安寧 start
              //if(mm.getAnticoagulantOriginalQuantity() != null && mm.getUnitConvertedAmountSecond() != null) {
              // del 6824 周安寧 start
                // 換算フラグ 0：換算、1：残量破棄、2：数量1固定
                String isExchange = mm.getIsExchange();
                switch (isExchange) {
                  // 換算
                  case "0":
                    // （指示or実績数量 / 指示基準数量）＊ レセ換算値
                      // mod 6824 周安寧 start
//                    double receiptValue = 0;
//                    if(mm.getAnticoagulantOriginalQuantity().doubleValue() != 0.00000000000000000) {
//                      receiptValue = (amount / mm.getAnticoagulantOriginalQuantity().doubleValue()) * mm.getUnitConvertedAmountSecond().doubleValue();
//                    }
//                    mediInfo13Oms.setReceiptValue(df.format(receiptValue));
                    if (mm.getUnitConvertedAmount() != null && BigDecimal.ZERO.compareTo(mm.getUnitConvertedAmount()) != 0 &&
                      mm.getUnitConvertedAmountSecond() != null && BigDecimal.ZERO.compareTo(mm.getUnitConvertedAmountSecond()) != 0) {
                      // （指示or実績数量 / 指示基準数量）＊ レセ換算値
                      // 指示or実績数量
                      BigDecimal indRstValue0 = new BigDecimal(amountStr);
                      // mod #8315 ord_material_save.supplies_cd, supplies_class_medicine_mix_cdの登録・更新不正 dou start
                      // BigDecimal reSeNum0 = indRstValue0.divide(mm.getUnitConvertedAmount(), decimalPoint, BigDecimal.ROUND_HALF_UP)
                      //   .multiply(mm.getUnitConvertedAmountSecond());
                      // receiptValue = reSeNum0.setScale(decimalPoint).toString();
                      BigDecimal reSeNum0 = indRstValue0.divide(mm.getUnitConvertedAmount(), unitDecimalPointSecond, BigDecimal.ROUND_HALF_UP)
                        .multiply(mm.getUnitConvertedAmountSecond());
                      // mod 「指示・実績値」の値の保存不正を修正する。 dengshen start
                      // receiptValue = reSeNum0.setScale(unitDecimalPointSecond).toString();
                      receiptValue = reSeNum0.setScale(unitDecimalPointSecond, RoundingMode.HALF_UP).toPlainString();
                      // mod 「指示・実績値」の値の保存不正を修正する。 dengshen end
                      // mod #8315 ord_material_save.supplies_cd, supplies_class_medicine_mix_cdの登録・更新不正 dou end
                      // }
                    }
                    // mod 6824 周安寧 end
                    break;
                  // 残量破棄
                  case "1":
                    //（指示or実績数量 / 指示基準数量）(小数第一位切り上げ)＊ レセ換算値
                    // mod 6824 周安寧 start
//                    double midVal = 0;
//                    if(mm.getAnticoagulantOriginalQuantity().doubleValue() != 0.00000000000000000) {
//                      midVal = amount / mm.getAnticoagulantOriginalQuantity().doubleValue();
//                    }
//                    double receiptValue2 = Math.ceil(midVal) * mm.getUnitConvertedAmountSecond().doubleValue();
//                    mediInfo13Oms.setReceiptValue(df.format(receiptValue2));
                    if (mm.getUnitConvertedAmount() != null && BigDecimal.ZERO.compareTo(mm.getUnitConvertedAmount()) != 0 &&
                      mm.getUnitConvertedAmountSecond() != null && BigDecimal.ZERO.compareTo(mm.getUnitConvertedAmountSecond()) != 0) {
                      // （指示or実績数量 / 指示基準数量）(小数第一位切り上げ)＊ レセ換算値
                      // 指示or実績数量
                      BigDecimal indRstValue1 = new BigDecimal(amountStr);
                      BigDecimal reSeNum1 = indRstValue1.divide(mm.getUnitConvertedAmount(), 0, BigDecimal.ROUND_UP)
                        .multiply(mm.getUnitConvertedAmountSecond());
                      // mod #8315 ord_material_save.supplies_cd, supplies_class_medicine_mix_cdの登録・更新不正 dou start
                      // receiptValue = reSeNum1.setScale(decimalPoint).toString();
                      // mod 「指示・実績値」の値の保存不正を修正する。 dengshen start
                      // receiptValue = reSeNum1.setScale(unitDecimalPointSecond).toString();
                      receiptValue = reSeNum1.setScale(unitDecimalPointSecond, RoundingMode.HALF_UP).toPlainString();
                      // mod 「指示・実績値」の値の保存不正を修正する。 dengshen end
                      // mod #8315 ord_material_save.supplies_cd, supplies_class_medicine_mix_cdの登録・更新不正 dou end
                      // }
                    }
                    // mod 6824 周安寧 end
                    break;
                  // 固定
                  case "2":
                    // レセ換算値
                    // mod 6824 周安寧 start
//                    mediInfo13Oms.setReceiptValue(mm.getUnitConvertedAmountSecond() + "");
                    if (mm.getUnitConvertedAmountSecond() != null && BigDecimal.ZERO.compareTo(mm.getUnitConvertedAmountSecond()) != 0) {
                      // mod #8315 ord_material_save.supplies_cd, supplies_class_medicine_mix_cdの登録・更新不正 dou start
                      // receiptValue = mm.getUnitConvertedAmountSecond().setScale(decimalPoint).toString();
                      // mod 「指示・実績値」の値の保存不正を修正する。 dengshen start
                      // receiptValue = mm.getUnitConvertedAmountSecond().setScale(unitDecimalPointSecond).toString();
                      receiptValue = mm.getUnitConvertedAmountSecond().setScale(unitDecimalPointSecond).toPlainString();
                      // mod 「指示・実績値」の値の保存不正を修正する。 dengshen end
                      // mod #8315 ord_material_save.supplies_cd, supplies_class_medicine_mix_cdの登録・更新不正 dou end
                    }
                    // mod 6824 周安寧 end
                    break;
                }
              // del 6824 周安寧 start
              //}
              // del 6824 周安寧 end

              //FNSI-修正 #6007紐づく治療記録画面の修正、xugj add end
              // add 6824 周安寧 start
              mediInfo13Oms.setReceiptValue(receiptValue);
              // add 6824 周安寧 end
              mediInfo13Oms.setIsConfirm("1");

              // 登録日時 and 更新日時
              // del #8315 ord_material_save.supplies_cd, supplies_class_medicine_mix_cdの登録・更新不正 dou start
              // Timestamp tm = Timestamp.from(Instant.now());
              // del #8315 ord_material_save.supplies_cd, supplies_class_medicine_mix_cdの登録・更新不正 dou end
              mediInfo13Oms.setRegDate(tm);
              mediInfo13Oms.setUpDate(tm);
              return mediInfo13Oms;
            }).collect(Collectors.toList());
            // add #8315 ord_material_save.supplies_cd, supplies_class_medicine_mix_cdの登録・更新不正 dou start
            omsList.add(medimixInfo);
            // add #8315 ord_material_save.supplies_cd, supplies_class_medicine_mix_cdの登録・更新不正 dou end
            omsList.addAll(mediInfo13OmsList);

          }
          // ---
        }

      });

    }
  }

  /**
   * 治療条件の抗凝固剤調整薬剤作成
   * Make mix medicine data
   * @param omsList
   * @param mediInfoOmsJson
   * @param medicineCd
   * @param suppliesClass
   * @param total
   */
  private void makeCondMixMedicineData(List<OrdMaterialSave> omsList, String mediInfoOmsJson, Integer medicineCd, String suppliesClass, double total) {

      List<Integer> mixMediCdList = new ArrayList<>();
      mixMediCdList.add(medicineCd);

      List<MstMedicineMix> mmmList = mstMedicineMixDao.selectByMedicineMixCdList2(mixMediCdList);

      mmmList.stream().forEach(mmm -> {

        String mixInfoJson = mmm.getMixInfo();

        if(mixInfoJson != null && !mixInfoJson.equals("[]")) {

          JSONArray mixInfoArray = new JSONArray(mixInfoJson);
          // 調整薬剤の通常薬剤 <code,amount> map
          Map<Integer, Double> commonMediOfMixMap = new HashMap<>();

          Iterator<Object> mixInfoIterator = mixInfoArray.iterator();
          while(mixInfoIterator.hasNext()) {
            Object mediObj = mixInfoIterator.next();
            if(mediObj instanceof JSONObject mediJO) {

              if (mediJO.has("cd") && !mediJO.isNull("cd")) {
                Object mediCdObj = mediJO.get("cd");
                if(mediCdObj instanceof Integer || mediCdObj instanceof String) {
                  // 薬剤コード
                  int mediCd = 0;
                  if (mediCdObj instanceof Integer) {
                    mediCd = (int) mediCdObj;
                  } else if (mediCdObj instanceof String) {
                    mediCd = Integer.parseInt((String) mediCdObj);
                  }

                  // make medicine map
                  makeMediMap(commonMediOfMixMap, mediJO, mediCd);
                }

              }
            }
          }

          Set<Integer> commonMediOfMixMapKeySet = commonMediOfMixMap.keySet();

          if (commonMediOfMixMapKeySet.size() != 0) {
            List<Integer> mediCdList = new ArrayList<>(commonMediOfMixMapKeySet);
            List<MstMedicine> mmList = mstMedicineDao.selectAllByCdList(SelectOptions.get(), mediCdList);

            List<OrdMaterialSave> mediInfo13OmsList = mmList.stream().map(mm -> {

              Gson g = new Gson();
              OrdMaterialSave mediInfo13Oms = g.fromJson(mediInfoOmsJson, OrdMaterialSave.class);
              //mod FNSI-redmine 8315 ljx　start
              // 物品区分 22：抗凝固剤調整薬剤
              //mediInfo13Oms.setSuppliesClass(suppliesClass);
              mediInfo13Oms.setSuppliesClass("22");

              // 薬剤コード
              int mediCd = mm.getMedicineCd();

              // 物品コード
              mediInfo13Oms.setSuppliesCd(mediCd + "");

              // 調製薬剤コード
              mediInfo13Oms.setMedicineMixCd(mmm.getMedicineMixCd() + "");

              // 分類コード
              mediInfo13Oms.setClassCd(mm.getClassCd() + "");
              //mod FNSI-redmine 8315 ljx　end

              // 指示・実績区分 2 実績
              mediInfo13Oms.setIndRstClass("2");
              // get 指示・実績値
              //int decimalPoint = mm.getUnitDecimalPoint();

              // 指示・実績値の編集処理
              //double amount = total;

              // 小数点桁数を正しく保持する
              //StringBuilder sb = new StringBuilder("#");
              /*if(decimalPoint > 0) {
                sb.append(".");
                for(int i = 0; i <= decimalPoint; i++) {
                  sb.append(0);
                }
              }*/

              //DecimalFormat df = new DecimalFormat(sb.toString());
             //del FNSI-redmine 8315 ljx　start
/*              if(mm.getAnticoagulantOriginalQuantity() != null && mm.getUnitConvertedAmountSecond() != null) {
                // 換算フラグ 0：換算、1：残量破棄、2：数量1固定
                String isExchange = mm.getIsExchange();
                switch (isExchange) {
                  // 換算
                  case "0":
                    // （指示or実績数量 / 指示基準数量）＊ レセ換算値
                    double receiptValue = 0;
                    if(mm.getAnticoagulantOriginalQuantity().doubleValue() != 0.00000000000000000) {
                      receiptValue = (amount / mm.getAnticoagulantOriginalQuantity().doubleValue()) * mm.getUnitConvertedAmountSecond().doubleValue();
                    }
                    // 指示・実績値
                    mediInfo13Oms.setIndRstValue(df.format(receiptValue));
                    // レセ値
                    mediInfo13Oms.setReceiptValue(df.format(receiptValue));
                    break;
                  // 残量破棄
                  case "1":
                    //（指示or実績数量 / 指示基準数量）(小数第一位切り上げ)＊ レセ換算値
                    double midVal = 0;
                    if(mm.getAnticoagulantOriginalQuantity().doubleValue() != 0.00000000000000000) {
                      midVal = amount / mm.getAnticoagulantOriginalQuantity().doubleValue();
                    }
                    double receiptValue2 = Math.ceil(midVal) * mm.getUnitConvertedAmountSecond().doubleValue();
                    // 指示・実績値
                    mediInfo13Oms.setIndRstValue(df.format(receiptValue2));
                    // レセ値
                    mediInfo13Oms.setReceiptValue(df.format(receiptValue2));
                    break;
                  // 固定
                  case "2":
                    // 指示・実績値
                    mediInfo13Oms.setIndRstValue(mm.getUnitConvertedAmountSecond() + "");
                    // レセ換算値
                    mediInfo13Oms.setReceiptValue(mm.getUnitConvertedAmountSecond() + "");
                    break;
                }
              }*/
              //del FNSI-redmine 8315 ljx　end
              //add FNSI-redmine 8315 ljx　start
              //receiptValueの取得は指示作成の方法に参照
              int decimalPoint = 0;
              if(mm.getUnitDecimalPoint()!=null){
                decimalPoint=mm.getUnitDecimalPoint();
              }
              // mod 内部指摘#5825対応する。「指示・実績値」の値の保存不正を修正する。 dengshen start
              // StringBuilder sb = new StringBuilder("#");
              StringBuilder sb = new StringBuilder("0");
              // mod 内部指摘#5825対応する。「指示・実績値」の値の保存不正を修正する。 dengshen end
              if(decimalPoint > 0) {
                sb.append(".");
                for(int i = 0; i < decimalPoint; i++) {
                  sb.append(0);
                }
              }

              DecimalFormat df = new DecimalFormat(sb.toString());
              BigDecimal totalBD = new BigDecimal(total);
              if(commonMediOfMixMap.get(mediCd) != null){
                 totalBD = new BigDecimal(total).multiply(new BigDecimal(commonMediOfMixMap.get(mediCd)));
              }
              String indRstValue = df.format(totalBD);
              mediInfo13Oms.setIndRstValue(indRstValue);
              String receiptValue = this.receiptValueSet(mm,indRstValue);
              mediInfo13Oms.setReceiptValue(receiptValue);
              //add FNSI-redmine 8315 ljx　end
              mediInfo13Oms.setIsConfirm("1");

              // 登録日時 and 更新日時
              Timestamp tm = Timestamp.from(Instant.now());
              mediInfo13Oms.setRegDate(tm);
              mediInfo13Oms.setUpDate(tm);
              return mediInfo13Oms;
            }).collect(Collectors.toList());
            //add FNSI-redmine 8315 ljx　start
            //調製薬剤自身は一レコードとして、ord_material_saveへ登録。
            Gson g = new Gson();
            Timestamp tm = Timestamp.from(Instant.now());
            int decimalPoint = 0;
            if(mmm.getUnitDecimalPoint()!=null){
              decimalPoint=mmm.getUnitDecimalPoint();
            }
            // mod 内部指摘#5825対応する。「指示・実績値」の値の保存不正を修正する。 dengshen start
            // StringBuilder sb = new StringBuilder("#");
            StringBuilder sb = new StringBuilder("0");
            // mod 内部指摘#5825対応する。「指示・実績値」の値の保存不正を修正する。 dengshen end
            if(decimalPoint > 0) {
              sb.append(".");
              for(int i = 0; i < decimalPoint; i++) {
                sb.append(0);
              }
            }
            DecimalFormat df = new DecimalFormat(sb.toString());
            String indRstValueStr = df.format(total);
            OrdMaterialSave OrdMaterialSaveMix = g.fromJson(mediInfoOmsJson, OrdMaterialSave.class);
            OrdMaterialSaveMix.setIndRstClass("2");
            OrdMaterialSaveMix.setClassCd(mmm.getClassCd()+"");
            OrdMaterialSaveMix.setIsConfirm("1");
            OrdMaterialSaveMix.setMedicineMixCd(medicineCd+"");
            OrdMaterialSaveMix.setSuppliesCd(null);
            OrdMaterialSaveMix.setSuppliesClass(suppliesClass);
            OrdMaterialSaveMix.setIndRstValue(indRstValueStr);
            OrdMaterialSaveMix.setRegDate(tm);
            OrdMaterialSaveMix.setUpDate(tm);
            mediInfo13OmsList.add(OrdMaterialSaveMix);
            //add FNSI-redmine 8315 ljx　end
            omsList.addAll(mediInfo13OmsList);
          }
        }
      });
  }

  /**
   * add FNSI No.396 治療記録 実績確定 -- Sanjingye Sun 20210121
   * Make medicine map. It's a <medicineCode, medicineAmount> map.
   * The map may be a mix medicine map or common medicine map.
   * NOTICE: When mediMap is a mix medicine map, it only saves amount of mix medicine, but not calcs the common medicine amount of mix medicine.
   * @param mediMap An medicine map.
   * @param mediJO  Medicine json object.
   * @param mediCd  Medicine code.
   */
  private void makeMediMap(Map<Integer, Double> mediMap, JSONObject mediJO, int mediCd) {

    // It won't insert data unless there is a medicine num.
    if(mediJO.has("amount") && !mediJO.isNull("amount")) {

      // get medicine num
      Object amountObj = mediJO.get("amount");

      if (amountObj instanceof Number || amountObj instanceof String) {
        double amount = 0;
        if(amountObj instanceof Number) {
          amount = ((Number) amountObj).doubleValue();
        } else if(amountObj instanceof String) {
          amount = Double.parseDouble((String)amountObj);
        }
        // Add the same medicine amount together.
        if(mediMap.containsKey(mediCd)) {
          mediMap.put(mediCd, mediMap.get(mediCd).doubleValue() + amount);
        } else {
          mediMap.put(mediCd, amount);
        }
      }

    }
  }

  /**
   * add FNSI No.396 治療記録 実績確定 -- Sanjingye Sun 20210121
   * make common medicine data
   * @param omsList
   * @param mediInfoOmsJson
   * @param commonMediMap
   */
  private void makeCommonMedicineData(List<OrdMaterialSave> omsList, String mediInfoOmsJson, Map<Integer, Double> commonMediMap, String suppliesClass) {

    Set<Integer> commonMediMapKeySet = commonMediMap.keySet();

    if (commonMediMapKeySet.size() != 0) {
      List<Integer> mediCdList = new ArrayList<>(commonMediMapKeySet);
      List<MstMedicine> mmList = mstMedicineDao.selectAllByCdList(SelectOptions.get(), mediCdList);

      List<OrdMaterialSave> mediInfo12OmsList = mmList.stream().map(mm -> {
        Gson g = new Gson();
        OrdMaterialSave mediInfo12Oms = g.fromJson(mediInfoOmsJson, OrdMaterialSave.class);
        // 物品区分 12：投与薬剤
        mediInfo12Oms.setSuppliesClass(suppliesClass);
        // 薬剤コード
        int mediCd = mm.getMedicineCd();
        // 物品コード
        mediInfo12Oms.setSuppliesCd(mediCd + "");

        // 分類コード
        mediInfo12Oms.setClassCd(mm.getClassCd() + "");

        // 指示・実績区分 2 実績
        mediInfo12Oms.setIndRstClass("2");
        // get 指示・実績値
        int decimalPoint = mm.getUnitDecimalPoint();

        Double amount = commonMediMap.get(mediCd);

        // 小数点桁数を正しく保持する
        // mod 内部指摘#5825対応する。「指示・実績値」の値の保存不正を修正する。 dengshen start
        // StringBuilder sb = new StringBuilder("#");
        StringBuilder sb = new StringBuilder("0");
        // mod 内部指摘#5825対応する。「指示・実績値」の値の保存不正を修正する。 dengshen end
        if(decimalPoint > 0) {
          sb.append(".");
          for(int i = 0; i <= decimalPoint; i++) {
            sb.append(0);
          }
        }

        DecimalFormat df = new DecimalFormat(sb.toString());
        String amountStr = df.format(amount);

        // 指示・実績値
        mediInfo12Oms.setIndRstValue(amountStr);
        // add 6824 周安寧 start
        // mod 「指示・実績値」の値の保存不正を修正する。 dengshen start
        // String receiptValue = BigDecimal.ZERO.setScale(decimalPoint, BigDecimal.ROUND_HALF_UP).toString();
        String receiptValue = BigDecimal.ZERO.setScale(decimalPoint, BigDecimal.ROUND_HALF_UP).toPlainString();
        // mod 「指示・実績値」の値の保存不正を修正する。 dengshen start
        // add 6824 周安寧 end
        // del 6824 周安寧 start
        //if(mm.getAnticoagulantOriginalQuantity() != null && mm.getUnitConvertedAmountSecond() != null) {
        // del 6824 周安寧 end
          // 換算フラグ 0：換算、1：残量破棄、2：数量1固定
        String isExchange = mm.getIsExchange();
        //FNSI-修正 #6007紐づく治療記録画面の修正、xugj modify start
        switch (isExchange) {
          // 換算
          case "0":
            // （指示or実績数量 / 指示基準数量）＊ レセ換算値
               // mod 6824 周安寧 start
//              double receiptValue = 0;
//              if(mm.getAnticoagulantOriginalQuantity().doubleValue() != 0.00000000000000000) {
//                    receiptValue = (amount / mm.getAnticoagulantOriginalQuantity().doubleValue()) * mm.getUnitConvertedAmountSecond().doubleValue();
//              }
//              mediInfo12Oms.setReceiptValue(df.format(receiptValue));
            if (mm.getUnitConvertedAmount() != null && BigDecimal.ZERO.compareTo(mm.getUnitConvertedAmount()) != 0 &&
              mm.getUnitConvertedAmountSecond() != null && BigDecimal.ZERO.compareTo(mm.getUnitConvertedAmountSecond()) != 0) {
              // （指示or実績数量 / 指示基準数量）＊ レセ換算値
              // 指示or実績数量
              BigDecimal indRstValue0 = new BigDecimal(amountStr);
              BigDecimal reSeNum0 = indRstValue0.divide(mm.getUnitConvertedAmount(), decimalPoint, BigDecimal.ROUND_HALF_UP)
                .multiply(mm.getUnitConvertedAmountSecond());
              receiptValue = df.format(reSeNum0);
              // }
            }
            // mod 6824 周安寧 end
            break;
          // 残量破棄
          case "1":
                 // mod 6824 周安寧 start
//              //（指示or実績数量 / 指示基準数量）(小数第一位切り上げ)＊ レセ換算値
//              double midVal = 0;
//              if(mm.getAnticoagulantOriginalQuantity().doubleValue() != 0.00000000000000000) {
//                midVal = amount / mm.getAnticoagulantOriginalQuantity().doubleValue();
//              }
//              double receiptValue2 = Math.ceil(midVal) * mm.getUnitConvertedAmountSecond().doubleValue();
//              mediInfo12Oms.setReceiptValue(df.format(receiptValue2));
            if (mm.getUnitConvertedAmount() != null && BigDecimal.ZERO.compareTo(mm.getUnitConvertedAmount()) != 0 &&
              mm.getUnitConvertedAmountSecond() != null && BigDecimal.ZERO.compareTo(mm.getUnitConvertedAmountSecond()) != 0) {
              // （指示or実績数量 / 指示基準数量）(小数第一位切り上げ)＊ レセ換算値
              // 指示or実績数量
              BigDecimal indRstValue1 = new BigDecimal(amountStr);
              BigDecimal reSeNum1 = indRstValue1.divide(mm.getUnitConvertedAmount(), 0, BigDecimal.ROUND_UP)
                .multiply(mm.getUnitConvertedAmountSecond());
              receiptValue = df.format(reSeNum1);
              // }
            }
             // mod 6824 周安寧 end
            break;
          // 固定
          case "2":
            // レセ換算値
            // mod 6824 周安寧 start
            //mediInfo12Oms.setReceiptValue(mm.getUnitConvertedAmountSecond() + "");
            if (mm.getUnitConvertedAmountSecond() != null && BigDecimal.ZERO.compareTo(mm.getUnitConvertedAmountSecond()) != 0) {
              receiptValue = mm.getUnitConvertedAmountSecond() + "";
            }
            // mod 6824 周安寧 end
            break;
        }
          //FNSI-修正 #6007紐づく治療記録画面の修正、xugj modify start
        // mod 6824 周安寧 start
        //}
        mediInfo12Oms.setReceiptValue(receiptValue);
        // mod 6824 周安寧 end
        mediInfo12Oms.setIsConfirm("1");

        // 登録日時 and 更新日時
        Timestamp tm = Timestamp.from(Instant.now());
        mediInfo12Oms.setRegDate(tm);
        mediInfo12Oms.setUpDate(tm);
        return mediInfo12Oms;
      }).collect(Collectors.toList());

      omsList.addAll(mediInfo12OmsList);

    }

  }

  /**
   * 治療条件の抗凝固剤普通薬剤作成
   *
   * @param omsList
   * @param mediInfoOmsJson
   * @param medicineCd
   * @param suppliesClass
   * @param total
   */
  private void makeCondCommonMedicineData(List<OrdMaterialSave> omsList, String mediInfoOmsJson, Integer medicineCd, String suppliesClass, double total) {
      List<Integer> mediCdList = new ArrayList<>();
      mediCdList.add(medicineCd);
      List<MstMedicine> mmList = mstMedicineDao.selectAllByCdList(SelectOptions.get(), mediCdList);

      List<OrdMaterialSave> mediInfo12OmsList = mmList.stream().map(mm -> {
        Gson g = new Gson();
        OrdMaterialSave mediInfo12Oms = g.fromJson(mediInfoOmsJson, OrdMaterialSave.class);
        // 物品区分 12：投与薬剤
        mediInfo12Oms.setSuppliesClass(suppliesClass);
        // 薬剤コード
        int mediCd = mm.getMedicineCd();
        // 物品コード
        mediInfo12Oms.setSuppliesCd(mediCd + "");

        // 分類コード
        mediInfo12Oms.setClassCd(mm.getClassCd() + "");

        // 指示・実績区分 2 実績
        mediInfo12Oms.setIndRstClass("2");
        // get 指示・実績値
        //del FNSI-redmine 8315 ljx　start
        //mod FNSI redmine 7150 劉祥霖 start
//        int decimalPoint = mm.getUnitDecimalPoint();
       /* int decimalPoint = 0;
        if(mm.getUnitDecimalPoint()!=null){
          decimalPoint=mm.getUnitDecimalPoint();
        }
        //mod FNSI redmine 7150 劉祥霖 end

        Double amount = total;

        // 小数点桁数を正しく保持する
        StringBuilder sb = new StringBuilder("#");
        if(decimalPoint > 0) {
          sb.append(".");
          for(int i = 0; i <= decimalPoint; i++) {
            sb.append(0);
          }
        }

        DecimalFormat df = new DecimalFormat(sb.toString());

        if(mm.getAnticoagulantOriginalQuantity() != null && mm.getUnitConvertedAmountSecond() != null) {
          // 換算フラグ 0：換算、1：残量破棄、2：数量1固定
          String isExchange = mm.getIsExchange();
          switch (isExchange) {
            // 換算
            case "0":
              // （指示or実績数量 / 指示基準数量）＊ レセ換算値
              double receiptValue = 0;
              if(mm.getAnticoagulantOriginalQuantity().doubleValue() != 0.00000000000000000) {
                receiptValue = (amount / mm.getAnticoagulantOriginalQuantity().doubleValue()) * mm.getUnitConvertedAmountSecond().doubleValue();
              }
              // 指示・実績値
              mediInfo12Oms.setIndRstValue(df.format(receiptValue));
              // レセ値
              mediInfo12Oms.setReceiptValue(df.format(receiptValue));
              break;
            // 残量破棄
            case "1":
              //（指示or実績数量 / 指示基準数量）(小数第一位切り上げ)＊ レセ換算値
              double midVal = 0;
              if(mm.getAnticoagulantOriginalQuantity().doubleValue() != 0.00000000000000000) {
                midVal = amount / mm.getAnticoagulantOriginalQuantity().doubleValue();
              }
              double receiptValue2 = Math.ceil(midVal) * mm.getUnitConvertedAmountSecond().doubleValue();
              // 指示・実績値
              mediInfo12Oms.setIndRstValue(df.format(receiptValue2));
              // レセ値
              mediInfo12Oms.setReceiptValue(df.format(receiptValue2));
              break;
            // 固定
            case "2":
              // 指示・実績値
              mediInfo12Oms.setIndRstValue(mm.getUnitConvertedAmountSecond() + "");
              // レセ換算値
              mediInfo12Oms.setReceiptValue(mm.getUnitConvertedAmountSecond() + "");
              break;
          }
        }*/
        //del FNSI-redmine 8315 ljx　end
        //add FNSI-redmine 8315 ljx　start
        String receiptValue = this.receiptValueSet(mm,total+"");
        mediInfo12Oms.setReceiptValue(receiptValue);
        mediInfo12Oms.setIndRstValue(total+"");
        //add FNSI-redmine 8315 ljx　end
        mediInfo12Oms.setIsConfirm("1");

        // 登録日時 and 更新日時
        Timestamp tm = Timestamp.from(Instant.now());
        mediInfo12Oms.setRegDate(tm);
        mediInfo12Oms.setUpDate(tm);
        return mediInfo12Oms;
      }).collect(Collectors.toList());

      omsList.addAll(mediInfo12OmsList);
  }

  /**
   * add FNSI 396 治療記録 -> 実績確定 -- Sanjingye Sun 20210120
   * データ発生元区分: 0 - 治療条件 -> 医療材料 data
   * @param omsList
   * @param condInfoXXJO
   * @param oms
   */
  private void addEquipmentMaterial(List<OrdMaterialSave> omsList, JSONObject condInfoXXJO, OrdMaterialSave oms) {

//    MstEquipment me = mstEquipmentDao.selectByEquipmentCd((Integer)(condInfoXXJO.get("value")));
    // add #9973 Resolve null exception for key 20240117 ztc start
    if (condInfoXXJO.has("value") && !condInfoXXJO.isNull("value")) {
    // add #9973 Resolve null exception for key 20240117 ztc end
      MstEquipment me = mstEquipmentDao.selectByEquipmentCd(Integer.parseInt(condInfoXXJO.get("value").toString()));

      if (me != null) {
        // 物品コード
        oms.setSuppliesCd(String.valueOf(condInfoXXJO.get("value")));

        // 分類コード
        oms.setClassCd(me.getClassCd() + "");
        // 指示・実績区分 2：実績
        oms.setIndRstClass("2");
        // 指示・実績値 1
        oms.setIndRstValue("1");
        //add 8496 2023-04-06 【IES起票】【ord_material_save】医材に関するレせ値がない 張 start
        //レセ値
        oms.setReceiptValue("1");
        //add 8496 2023-04-06 【IES起票】【ord_material_save】医材に関するレせ値がない 張 start
        // 確定フラグ
        oms.setIsConfirm("1");

        // 登録日時 and 更新日時
        Timestamp tm = Timestamp.from(Instant.now());
        oms.setRegDate(tm);
        oms.setUpDate(tm);

        omsList.add(oms);

      }
    }
  }
  /**
   * add 6824追加
   * @param omsList
   * @param condInfoXXJO
   * @param oms
   */
  private void addMedicineMaterial(List<OrdMaterialSave> omsList, JSONObject condInfoXXJO, OrdMaterialSave oms) {
    // add #9973 Resolve null exception for key 20240117 ztc start
    if (condInfoXXJO.has("value") && !condInfoXXJO.isNull("value")) {
    // add #9973 Resolve null exception for key 20240117 ztc end
//    MstMedicine mm = mstMedicineDao.selectByMediCd((Integer)(condInfoXXJO.get("value")));
      MstMedicine mm = mstMedicineDao.selectByMediCd(Integer.parseInt(condInfoXXJO.get("value").toString()));
      if (mm == null) {
        MstMedicineMix mmm = mstMedicineMixDao.selectByMedicineMixCd(Integer.parseInt(condInfoXXJO.get("value").toString()));
        if (mmm != null) {
          // 物品コード
          oms.setSuppliesCd(String.valueOf(condInfoXXJO.get("value")));
          oms.setClassCd(mmm.getClassCd() + "");
          // 登録日時 and 更新日時
          Timestamp tm = Timestamp.from(Instant.now());
          oms.setRegDate(tm);
          oms.setUpDate(tm);
          omsList.add(oms);
        }
      } else {
        // 物品コード
        oms.setSuppliesCd(String.valueOf(condInfoXXJO.get("value")));
        // 分類コード
        oms.setClassCd(mm.getClassCd() + "");
        // 登録日時 and 更新日時
        Timestamp tm = Timestamp.from(Instant.now());
        oms.setRegDate(tm);
        oms.setUpDate(tm);
        omsList.add(oms);
      }
    }

  }

  /**
   * ？？？？実績削除
   */
  @Transactional
  @Override
  public TreatmentStatusUpdateResponse deleteUnknownPatRecord(Long ordNo, String facilityCd) {
    //add FNSI 401対応 房 start
    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    if (AdminWebConstant.OrdMainConst.DialysisState.AFTER_DIALYSIS.equals(ordMain.getRstDialysisState())
      || AdminWebConstant.OrdMainConst.DialysisState.AFTER_WEIGHT.equals(ordMain.getRstDialysisState())
      || AdminWebConstant.OrdMainConst.DialysisState.PAST_RECORD.equals(ordMain.getRstDialysisState())) {
      //del 9324 ord_checklist共通之外的dao方法删除 gjn start
      //ordChecklistDao.deleteByOrdNo(ordNo, facilityCd);
      //del 9324 ord_checklist共通之外的dao方法删除 gjn end
    }
    //add FNSI 401対応 房 end
    TreatmentStatusUpdateResponse res = new TreatmentStatusUpdateResponse();
    res.isSuccess = false;
    // 更新日時
    Timestamp upDate = new Timestamp(System.currentTimeMillis());

    // add FNSI-改修内容追加OrdMain履歴 付 start
    getHistory(ordNo);
    // mangoDb-updateDeleteByOrdNo-insertSuccess
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
    // add FNSI-redmine fang start
    Timestamp delDate = new Timestamp(System.currentTimeMillis());
    int delCnt = ordMainRestoreDao.selectCount(ordNo, delDate);
    if (delCnt == 0) {
      OrdMain targetOrdMain = ordMainDao.selectByOrdNo(ordNo);
      if (targetOrdMain == null) {
        throw new NotExistException(String.format("？？？？患者割当:オーダ番号に該当する情報が存在しません。オーダ番号[%d]", ordNo));
      }
      OrdMainRestore ordMainRestore = new OrdMainRestore();
      Class<?> ordMainClass = targetOrdMain.getClass();
      Class<?> ordMainRestoreClass = ordMainRestore.getClass();
      Field[] ordMainFields = ordMainClass.getDeclaredFields();
      for (Field f : ordMainFields) {
        Field tempFileld = null;
        try {
          tempFileld = ordMainRestoreClass.getDeclaredField(f.getName());
          tempFileld.setAccessible(true);
          f.setAccessible(true);
          tempFileld.set(ordMainRestore, f.get(targetOrdMain));
        } catch (NoSuchFieldException | IllegalAccessException e) {
          //項目が不一致
        }
      }
      ordMainRestore.setDelDate(delDate);
      ordMainRestoreDao.insert(ordMainRestore);
    }
    List<Long> ordNoList = new ArrayList<Long>(Arrays.asList(ordNo));
    //mod #6227 2022-08-26 ord_mainの削除データ不正 赵鑫宇 start
    int updateCount = ordMainService.deleteByOrdNoQm(ordNoList);
    //mod #6227 2022-08-26 ord_mainの削除データ不正 赵鑫宇 end
    // add FNSI-redmine fang end
    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      logCommon.updateLog();
    }
    // DB更新ログ出力ロジック wangzuo End

    if (updateCount > 0) {
      res.isSuccess = true;

      // add FNSI No.396 治療記録 実績削除 start -- Sanjingye Sun 20210125
      // mod 12250 ord_material_saveの処理を2回重複実行している zkm start
//      ordMaterialSaveDao.deleteRstDataByOrdNo(ordNo);
      ordMaterialSaveService.bulkUpdateByOrdNoInCondMediEquipTreatment(Collections.singletonList(ordNo));
      // mod 12250 ord_material_saveの処理を2回重複実行している zkm end
      // del 11613 by shiyw 20250307 start
      // 「確定フラグ」を 1 → 0 に変更
      // ordMaterialSaveService.cancelSendCondition(ordNo);
      // del 11613 by shiyw 20250307 end
      // add FNSI No.396 治療記録 実績削除 end -- Sanjingye Sun 20210125

    } else {
      res.errorMessage = "削除失敗";
    }
    return res;
  }

  // del 11613 by shiyw 20250307 start
//  /**
//   * add FNSI NO.396 治療記録 版確定 -- Sanjingye Sun 20210126
//   * @param ordNo
//   */
//  @Override
//  public void resultReconfirm2Oms(Long ordNo, Long patId) {
//    //add #10196 Ord_Material_Save operation 20240126 ztc start
//
//
//    this.ordMaterialSaveService.updateIsConfirm(ordNo, patId);
//    //mod #10196 Ord_Material_Save operation 20240126 ztc end
//  }
  // del 11613 by shiyw 20250307 end

  /**
   * 後体重確認をデバイスエッジにリクエストする
   * @param ordNo
   * @return
   */
  private SendConditionResponse postSendAfterWeightWs(Long ordNo, String facilityCd) {

    SendConditionResponse res = new SendConditionResponse();
    try {
      // #10457 2024.06.18 mod デバイスエッジに通知タイミングで現患者クリアを実施 TDC高村 start
      // // 条件からベッドコードを取得し、ベッドコードから装置を取得し、デバイスエッジ番号を取得
      // // 条件から装置情報を取得
      // List<MstMachine> machines = mstMachineDao.selectByOrdNoRst(ordNo);
      // if (machines.size() == 0) {
      //   res.isSuccess = false;
      //   res.errorMessage = "通知先装置の特定失敗";
      //   return res;
      // }
      // MstMachine machine = machines.get(0);
      //
      // String topic = PayloadBuilder.BuildWeightTopic(WebSocketTopic.ComSv.CHECK_STATUS, facilityCd,
      //     machine.getDeviceEdgeNo());
      //
      // String payload = machine.getMachineNo().toString();
      //
      // // EdgeあてにWebsocket通知
      // if (sendWsMsg.sendMsg(SendTarget.main, facilityCd, machine.getDeviceEdgeNo(), topic, payload)) {
      //   res.isSuccess = true;
      // } else {
      //   res.isSuccess = false;
      //   res.errorMessage = "通信サーバーへの通知失敗";
      // }
      //　施設コード及びオーダ番号に該当する装置状態管理を取得
      List<MntMachineState> mntMachineStateList = mntMachineStateDao.selectByOrdNo(facilityCd, ordNo);
      // 装置状態管理がない場合
      if (mntMachineStateList.isEmpty()) {
        res.isSuccess = false;
        res.errorMessage = "通知先装置の特定失敗";
        return res;
      }

      // デバイスエッジ番号を取得する為のリクエスト情報を作成
      DeviceEdgeOrderRequest deviceEdgeOrderRequest = new DeviceEdgeOrderRequest();
      deviceEdgeOrderRequest.setDeviceEdgeNo(null);
      deviceEdgeOrderRequest.setOrdNo(ordNo);
      deviceEdgeOrderRequest.setMachineNo(null);
      deviceEdgeOrderRequest.setFacilityCd(facilityCd);

      // 不足している情報を補填
      DeviceEdgeOrderRequest targetInfo = deviceEdgeOrderService.findMissingData(deviceEdgeOrderRequest);

      MstMachine mstMachine = mstMachineDao.selectByMachineNo(targetInfo.getMachineNo());
      MstComsvSetting mstComsv = mstComsvSettingDao.selectByCd(facilityCd, mstMachine.getDeviceEdgeNo());
      if (mstComsv.getPatTiming().equals("1")) {
        // 現患者クリア処理実施
        Timestamp upDate = new Timestamp(System.currentTimeMillis());
        int retCnt = mntMachineStateDao.updateCurrentPatClear(facilityCd, mstMachine.getMachineTypeCd(), mstMachine.getMachineSerial(), upDate);
        if (1 != retCnt) {
          // 処理件数が1件でない場合は失敗
          res.isSuccess = false;
          res.errorMessage = "現患者クリア処理失敗";
          return res;
        }
      }
      DeviceEdgeOrderResponse checkStatusResponse =
        deviceEdgeOrderService.orderCheckStatus(facilityCd, mstMachine.getDeviceEdgeNo(), mstMachine.getMachineNo());
      res.isSuccess = false;
      if (!Objects.isNull(checkStatusResponse)) {
        res.isSuccess = checkStatusResponse.isSuccess;
      }
      if (!res.isSuccess) {
        res.errorMessage = "通信サーバーへの通知失敗";
      }
      // #10457 2024.06.18 mod デバイスエッジに通知タイミングで現患者クリアを実施 TDC高村 end
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_TREATMENT_RECORD, SERVICE_NAME.REMS, null);
      res.isSuccess = false;
      res.errorMessage = e.getMessage();
    }
    return res;
  }

  private String updateMediInfoToComplete(String mediInfo, Date nowDate, Long userId) {
    /* add by chamaojia 2024-04-02 [10196] add null judgment processing  --start */
    if (ObjectUtils.isEmpty(mediInfo)) {
      return "[]";
    }
    /* add by chamaojia 2024-04-02 [10196] add null judgment processing  --end */
    // ISO8601形式の日付文字列取得
    String nowDate_iso8601 = this.getDateString_iso8601(nowDate);
    // 戻り値格納用StringBuilder
    StringBuilder rtnBuilder = new StringBuilder();
    rtnBuilder.append("[");

    // JSON処理
    try {
      JsonNode jsonNode_array = mapper.readTree(mediInfo);

      for (int lop = 0; lop < jsonNode_array.size(); lop++) {
        JsonNode jsonNode = jsonNode_array.get(lop);
        // jsonNodeは読み取り専用のため、ObjectNodeに変換
        ObjectNode objectNode = jsonNode.deepCopy().asObject();

        if (objectNode.get("effect_flg").asInt() != 1) {
          // 値の変更
          objectNode.put("effect_flg", 1);
          objectNode.put("effect_date", nowDate_iso8601);
          objectNode.put("effect_user_id", userId);
          // userId に紐づく利用者情報を取得
          MstPersonalUser userInfo = mstPersonalUserDao.selectById(userId);
          if (userInfo != null) {
            objectNode.put("effect_user_last_name", userInfo.getUserLastName());
            objectNode.put("effect_user_first_name", userInfo.getUserFirstName());
          }
        }

        // objectNodeの文字列化
        rtnBuilder.append(mapper.writeValueAsString(objectNode));
        // 最後以外は区切りのカンマを追加
        if (lop != jsonNode_array.size() - 1) {
          rtnBuilder.append(",");
        }
      }
    } catch (tools.jackson.core.JacksonException e) {
      // TODO 自動生成された catch ブロック
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }

    rtnBuilder.append("]");

    return rtnBuilder.toString();
  }

  private String getDateString_iso8601(Date date) {
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZZZ");
    sdf.setTimeZone(TimeZone.getTimeZone("JST"));
    String dateString = sdf.format(date);
    return dateString;
  }

  /**
   * 投薬未実施チェック
   */
  @Override
  public List<CheckMediDoneResponse> checkMediDone(List<String> ordNoList) {
    List<Long> ordNoList_Long = new ArrayList<Long>();
    // 文字列OrdNoをLongに変換
    for (int lop = 0; lop < ordNoList.size(); lop++) {
      String ordNoStr = ordNoList.get(lop);
      Long ordNo = Long.valueOf(ordNoStr);
      ordNoList_Long.add(ordNo);
    }

    List<OrdMain> ordMainList = ordMainDao.selectMediInfoByNoList(ordNoList_Long);
    List<CheckMediDoneResponse> responseList = new ArrayList<CheckMediDoneResponse>();

    for (int lop = 0; lop < ordMainList.size(); lop++) {
      OrdMain ordMain = ordMainList.get(lop);
      CheckMediDoneResponse response = new CheckMediDoneResponse();

      response.setOrdNo(ordMain.getOrdNo());
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      try {
        response.setIsMediDone(ordMain.getRstMediInfo());
      } catch (JacksonException e) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      //add 実績確定修正 房 start
      response.setRstMediInfo(ordMain.getRstMediInfo());
      //add 実績確定修正 房 end

      //add 実績確定修正 徐 start
      response.setRstKurName(ordMain.getRstKurName());
      //add 実績確定修正 徐 end

      // 実績：治療方法コード
      response.setRstTreatmentCd(ordMain.getRstTreatmentCd());

      responseList.add(response);
    }

    return responseList;
  }

  @Autowired
  private MstTreatmentStatusDispItemDao mstTreatmentStatusDispItemDao;
  @Autowired
  private SysMonitorItemService sysMonitorItemService;
  @Autowired
  private MstAddMonitorDao mstAddMonitorDao;

  @Autowired
  @DefaultDb
  private Config defaultDbConfig;

  @Override
  public List<DispItemListResponse> getTreatmentStatusListDispItems(String facilityCd) {
    // レスポンス作成
    List<DispItemListResponse> response = new ArrayList<DispItemListResponse>();
    List<SysMonitorItem> sysMonitorItemList = Collections.emptyList();
    List<MstAddMonitor> mstAddMonitorList = Collections.emptyList();
    // mod #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou start
    // Integer itemCd = 500;
    Integer itemCd = -10000;
    // mod #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou end

    // 透析装置用選択項目
    // 特定項目
    List<MstTreatmentStatusDispItem> dispItemList = mstTreatmentStatusDispItemDao.selectAllExceptDeleted();
    // システム共通項目：透析装置共通
    sysMonitorItemList = sysMonitorItemService.getMonitorItemByMoniDataType("-");
    // 施設別追加項目
    // mod #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou start
    // mstAddMonitorList = mstAddMonitorDao.selectAllByFacilityCd(facilityCd);
    mstAddMonitorList = getMstAddMonitorList(facilityCd);
    // mod #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou end

    // 特定項目
    if (dispItemList != null) {
      for (MstTreatmentStatusDispItem dispItem : dispItemList) {
        DispItemListResponse res = new DispItemListResponse(dispItem);
        response.add(res);
      }
    }
    // add #9216 治療状況レイアウトマスタで患者IDの設定がNG dengshen start
    Integer itemCdAddMonitorList = 10000;
    // add #9216 治療状況レイアウトマスタで患者IDの設定がNG dengshen end
    // mod #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou start
    // 施設別追加項目：バイタル項目、モニタ項目
    if (mstAddMonitorList != null) {
      for (MstAddMonitor item : mstAddMonitorList) {
        DispItemListResponse res = new DispItemListResponse(
          // mod #9216 治療状況レイアウトマスタで患者IDの設定がNG dengshen start
          // item.getVitalMonitorItemCd().intValue(), // レイアウト表示項目番号
          item.getVitalMonitorItemCd().intValue() + itemCdAddMonitorList,
          // mod #9216 治療状況レイアウトマスタで患者IDの設定がNG dengshen end
          "0", // データ取得種別('0':変換不要/'1':変換必要)
          "0", // 装置種別('0':透析装置)
          item.getVitalMonitorItemName(), // 項目名
          "mni_monitor", // 参照先テーブル名
          "monitor_data", // 参照先フォールド名
          // mod #10077 by zhangruixue 2024-01-05 --start
//          item.getVitalMonitorItemName(), // 参照先JSONキー名
          item.getVitalMonitorItemCd().intValue() + itemCdAddMonitorList + "", // 参照先JSONキー名
          // mod #10077 by zhangruixue 2024-01-05 --end
          item.getVitalMonitorClass(), // バイタル・モニタ区分
          "" // データ型
        );
        response.add(res);
      }
    }
    // mod #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou end
    //システム共通項目：バイタル項目
    if (sysMonitorItemList != null) {
      for (SysMonitorItem item : sysMonitorItemList) {
        // バイタル・モニタ区分判定
        if (Objects.equals(item.getVitalMonitorClass(), "1")) {
          // バイタル項目
          DispItemListResponse res = new DispItemListResponse(
            // del #9312 治療状況リスト，マップの表示が不正
//              itemCd, // レイアウト表示項目番号
              Objects.equals(item.getConvItem(), null) ? "0" : "1", // データ取得種別('0':変換不要/'1':変換必要)
              "0", // 装置種別('0':透析装置)
            // #9312 Mod Display short name
              item.getMoniDataName(), // 項目名
//              item.getMoniDataShortName(),  //モニタデータ短縮名
              "mni_monitor", // 参照先テーブル名
              "monitor_data", // 参照先フォールド名
              item.getMoniDataNo(), // 参照先JSONキー名
              item.getVitalMonitorClass(), // バイタル・モニタ区分
              item.getDataType().toString() // データ型
          );
          response.add(res);
          // del #9312 治療状況リスト，マップの表示が不正 Start
          // mod #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou start
          // itemCd++;
//          itemCd--;
          // mod #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou end
          // del #9312 治療状況リスト，マップの表示が不正 End
        }
      }
    }

    // システム共通項目：透析装置
    sysMonitorItemList = sysMonitorItemService.getMonitorItemByMoniDataType(null);
    //システム共通項目：バイタル項目
    /* delete by chamaojia 2024-10-24 [9312] delete the definition of 'moniNos' --start */
//    List<String> moniNos = List.of("89","90","91","92","93","94","-1","-2","103");
    /* delete by chamaojia 2024-10-24 [9312] delete the definition of 'moniNos' --end */
    if (sysMonitorItemList != null) {
      for (SysMonitorItem item : sysMonitorItemList) {
        // バイタル・モニタ区分判定
        if (Objects.equals(item.getVitalMonitorClass(), "1")) {

          // mod 治療状況レイアウトマスタ No.13 王 start
          /* mod 内部#6409 by zhangruixue 2023-06-15 Add criteria -1  -2   --start */
//          String[] moniNos = {"89","90","91","92","93","94","-1","-2","103"};
          /* mod 内部#6409 by zhangruixue 2023-06-15 Add criteria -1  -2   --end */

          /* delete by chamaojia 2024-10-24 [9312] delete the definition of 'moniFlag' --start */
//          boolean moniFlag = moniNos.contains(item.getMoniDataNo());
          /* delete by chamaojia 2024-10-24 [9312] delete the definition of 'moniFlag' --end */
          // バイタル項目
          DispItemListResponse res = new DispItemListResponse(
            // del #9312 治療状況リスト，マップの表示が不正
//            itemCd, // レイアウト表示項目番号
            Objects.equals(item.getConvItem(), null) ? "0" : "1", // データ取得種別('0':変換不要/'1':変換必要)
            "0", // 装置種別('0':透析装置)
            // #9312 Mod Display short name
              item.getMoniDataName(), // 項目名
//            item.getMoniDataShortName(),  // モニタデータ短縮名
            /* modify by chamaojia 2024-10-24 [9312] change to direct assignment --start */
//            moniFlag ? "mni_monitor" : "mnt_machine_state", // 参照先テーブル名
            "mni_monitor",
            /* modify by chamaojia 2024-10-24 [9312] change to direct assignment --end */
            "monitor_data", // 参照先フォールド名
            item.getMoniDataNo(), // 参照先JSONキー名
            item.getVitalMonitorClass(), // バイタル・モニタ区分
            item.getDataType().toString() // データ型
          );
          // mod 治療状況レイアウトマスタ No.13 王 end
          response.add(res);

          // del #9312 治療状況リスト，マップの表示が不正 Start
          // mod #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou start
          // itemCd++;
//          itemCd--;
          // mod #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou end
          // del #9312 治療状況リスト，マップの表示が不正 End
        }
      }
    }
    // del #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou start
    // 施設別追加項目：モニタ項目
    //if (mstAddMonitorList != null) {
    //  for (MstAddMonitor item : mstAddMonitorList) {
    //    // バイタル・モニタ区分判定
    //    if (Objects.equals(item.getVitalMonitorClass(), "2")) {
    //      // モニタ項目
    //      DispItemListResponse res = new DispItemListResponse(
    //          // mod #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou start
    //          // itemCd, // レイアウト表示項目番号
    //          item.getVitalMonitorItemCd().intValue(), // レイアウト表示項目番号
    //          // mod #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou end
    //          "0", // データ取得種別('0':変換不要/'1':変換必要)
    //          "0", // 装置種別('0':透析装置)
    //          item.getVitalMonitorItemName(), // 項目名
    //          "mni_monitor", // 参照先テーブル名
    //          "monitor_data", // 参照先フォールド名
    //          item.getVitalMonitorItemName(), // 参照先JSONキー名
    //          item.getVitalMonitorClass(), // バイタル・モニタ区分
    //          "");
    //      response.add(res);
    //      // del #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou start
    //      // itemCd++;
    //      // del #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou end
    //    }
    //  }
    //}
    // del #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou end
    // システム共通項目：モニタ項目
    if (sysMonitorItemList != null) {
      for (SysMonitorItem item : sysMonitorItemList) {
        // バイタル・モニタ区分判定
        if (Objects.equals(item.getVitalMonitorClass(), "2")) {
          // mod 治療状況レイアウトマスタ No.13 王 start
          /* delete by chamaojia 2024-10-24 [9312] delete the definition of 'moniFlag' --start */
//          boolean moniFlag = moniNos.contains(item.getMoniDataNo());
          /* delete by chamaojia 2024-10-24 [9312] delete the definition of 'moniFlag' --end */
          // バイタル項目
          /* modify by chamaojia 2024-10-24 [9312] change to direct assignment --start */
          DispItemListResponse res = new DispItemListResponse(
            // del #9312 治療状況リスト，マップの表示が不正 Start
//            itemCd, // レイアウト表示項目番号
            Objects.equals(item.getConvItem(), null) ? "0" : "1", // データ取得種別('0':変換不要/'1':変換必要)
            "0", // 装置種別('0':透析装置)
            item.getMoniDataName(), // 項目名
            "mni_monitor", // 参照先テーブル名
            "monitor_data", // 参照先フォールド名
            item.getMoniDataNo(), // 参照先JSONキー名
            item.getVitalMonitorClass(), // バイタル・モニタ区分
            item.getDataType().toString() // データ型
          );
          /* modify by chamaojia 2024-10-24 [9312] change to direct assignment --end */
          // mod 治療状況レイアウトマスタ No.13 王 end
          response.add(res);
          // del #9312 治療状況リスト，マップの表示が不正 Start
          // mod #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou start
          // itemCd++;
//          itemCd--;
          // mod #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou end
          // del #9312 治療状況リスト，マップの表示が不正 end
        }
      }
    }

    // システム共通項目：特殊浄化装置
    sysMonitorItemList = sysMonitorItemService.getMonitorItemByMoniDataType("Z");
    if (sysMonitorItemList != null) {
      // システム共通項目：バイタル項目
      for (SysMonitorItem item : sysMonitorItemList) {
        // バイタル・モニタ区分判定
        if (Objects.equals(item.getVitalMonitorClass(), "1")) {
          // バイタル項目
          DispItemListResponse res = new DispItemListResponse(
            // del #9312 治療状況リスト，マップの表示が不正 Start
//              itemCd, // レイアウト表示項目番号
              Objects.equals(item.getConvItem(), null) ? "0" : "1", // データ取得種別('0':変換不要/'1':変換必要)
              "0", // 装置種別('0':透析装置)
              item.getMoniDataName(), // 項目名
              // mod 治療状況レイアウトマスタ No.13 王 start
              // "mni_monitor", // 参照先テーブル名
              "mni_monitor", // 参照先テーブル名
              // mod 治療状況レイアウトマスタ No.13 王 end
              "monitor_data", // 参照先フォールド名
              item.getMoniDataNo(), // 参照先JSONキー名
              item.getVitalMonitorClass(), // バイタル・モニタ区分
              item.getDataType().toString() // データ型
          );
          response.add(res);
          // del #9312 治療状況リスト，マップの表示が不正 Start
          // mod #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou start
          // itemCd++;
//          itemCd--;
          // mod #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou end
          // del #9312 治療状況リスト，マップの表示が不正 End
        }
      }
      // システム共通項目：モニタ項目
      for (SysMonitorItem item : sysMonitorItemList) {
        // バイタル・モニタ区分判定
        if (Objects.equals(item.getVitalMonitorClass(), "2")) {
          // モニタ項目
          // del #9312 治療状況リスト，マップの表示が不正 Start
          DispItemListResponse res = new DispItemListResponse(
//              itemCd, // レイアウト表示項目番号
              Objects.equals(item.getConvItem(), null) ? "0" : "1", // データ取得種別('0':変換不要/'1':変換必要)
              "0", // 装置種別('0':透析装置)
              item.getMoniDataName(), // 項目名
              // mod 治療状況レイアウトマスタ No.13 王 start
              // "mni_monitor", // 参照先テーブル名
              /* modify by chamaojia 2024-10-25 [9312] change to direct assignment --start */
              "mni_monitor", // 参照先テーブル名
              /* modify by chamaojia 2024-10-25 [9312] change to direct assignment --end */
              // mod 治療状況レイアウトマスタ No.13 王 end
              "monitor_data", // 参照先フォールド名
              item.getMoniDataNo(), // 参照先JSONキー名
              item.getVitalMonitorClass(), // バイタル・モニタ区分
              item.getDataType().toString() // データ型
          );
          response.add(res);
          // del #9312 治療状況リスト，マップの表示が不正 Start
          // mod #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou start
          // itemCd++;
//          itemCd--;
          // mod #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou end
          // del #9312 治療状況リスト，マップの表示が不正 End
        }
      }
    }

    // DAB用選択項目
    // システム共通項目：DAB
    sysMonitorItemList = sysMonitorItemService.getMonitorItemByMoniDataType("A");
    if (sysMonitorItemList != null) {
      // システム共通項目：バイタル項目
      for (SysMonitorItem item : sysMonitorItemList) {
        // バイタル・モニタ区分判定
        if (Objects.equals(item.getVitalMonitorClass(), "1")) {
          // バイタル項目
          DispItemListResponse res = new DispItemListResponse(
            // del #9312 治療状況リスト，マップの表示が不正 Start
//              itemCd, // レイアウト表示項目番号
              Objects.equals(item.getConvItem(), null) ? "0" : "1", // データ取得種別('0':変換不要/'1':変換必要)
              "1", // 装置種別('1':DAB)
              item.getMoniDataName(), // 項目名
              "mni_monitor", // 参照先テーブル名
              "monitor_data", // 参照先フォールド名
              item.getMoniDataNo(), // 参照先JSONキー名
              item.getVitalMonitorClass(), // バイタル・モニタ区分
              item.getDataType().toString() // データ型
          );
          response.add(res);
          // del #9312 治療状況リスト，マップの表示が不正 Start
          // mod #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou start
          // itemCd++;
//          itemCd--;
          // mod #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou end
          // del #9312 治療状況リスト，マップの表示が不正 End
        }
      }
      // システム共通項目：モニタ項目
      for (SysMonitorItem item : sysMonitorItemList) {
        // バイタル・モニタ区分判定
        if (Objects.equals(item.getVitalMonitorClass(), "2")) {
          // モニタ項目
          DispItemListResponse res = new DispItemListResponse(
            // del #9312 治療状況リスト，マップの表示が不正 Start
//              itemCd, // レイアウト表示項目番号
              Objects.equals(item.getConvItem(), null) ? "0" : "1", // データ取得種別('0':変換不要/'1':変換必要)
              "1", // 装置種別('1':DAB)
              item.getMoniDataName(), // 項目名
              "mni_monitor", // 参照先テーブル名
              "monitor_data", // 参照先フォールド名
              item.getMoniDataNo(), // 参照先JSONキー名
              item.getVitalMonitorClass(), // バイタル・モニタ区分
              item.getDataType().toString() // データ型
          );
          response.add(res);
          // del #9312 治療状況リスト，マップの表示が不正 Start
          // mod #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou start
          // itemCd++;
//          itemCd--;
          // mod #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou end
          // del #9312 治療状況リスト，マップの表示が不正 Start
        }
      }

      // #9312 Add モニタ固定項目を追加する。
      // 警報・報知固定項目
      response.add(new DispItemListResponse(
//        itemCd--, // レイアウト表示項目番号
        "0", // データ取得種別('0':変換不要/'1':変換必要)
        "1", // 装置種別('1':DAB)
        "警報・報知", // 項目名
        "mni_monitor", // 参照先テーブル名
        "monitor_data", // 参照先フォールド名
        "A99", // 参照先JSONキー名
        "2", // バイタル・モニタ区分
        "A" // データ型
      ));
    }

    // DAD用選択項目
    // システム共通項目：DAD
    sysMonitorItemList = sysMonitorItemService.getMonitorItemByMoniDataType("D");
    if (sysMonitorItemList != null) {
      // システム共通項目：バイタル項目
      for (SysMonitorItem item : sysMonitorItemList) {
        // バイタル・モニタ区分判定
        if (Objects.equals(item.getVitalMonitorClass(), "1")) {
          // バイタル項目
          DispItemListResponse res = new DispItemListResponse(
            // del #9312 治療状況リスト，マップの表示が不正 Start
//              itemCd, // レイアウト表示項目番号
              Objects.equals(item.getConvItem(), null) ? "0" : "1", // データ取得種別('0':変換不要/'1':変換必要)
              "2", // 装置種別('2':DAD)
              // #9312 Mod Display short name
              item.getMoniDataName(), // 項目名
//              item.getMoniDataShortName(),  // モニタデータ短縮名
              "mni_monitor", // 参照先テーブル名
              "monitor_data", // 参照先フォールド名
              item.getMoniDataNo(), // 参照先JSONキー名
              item.getVitalMonitorClass(), // バイタル・モニタ区分
              item.getDataType().toString() // データ型
          );
          response.add(res);
          // del #9312 治療状況リスト，マップの表示が不正 Start
          // mod #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou start
          // itemCd++;
//          itemCd--;
          // mod #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou end
          // del #9312 治療状況リスト，マップの表示が不正 End
        }
      }
      // システム共通項目：モニタ項目
      for (SysMonitorItem item : sysMonitorItemList) {
        // バイタル・モニタ区分判定
        if (Objects.equals(item.getVitalMonitorClass(), "2")) {
          // モニタ項目
          DispItemListResponse res = new DispItemListResponse(
            // del #9312 治療状況リスト，マップの表示が不正 Start
//              itemCd,                                                   // レイアウト表示項目番号
              Objects.equals(item.getConvItem(), null) ? "0" : "1",   // データ取得種別('0':変換不要/'1':変換必要)
              "2",                                                      // 装置種別('2':DAD)
              // #9312 Mod Display short name
                item.getMoniDataName(), // 項目名
//              item.getMoniDataShortName(),  // モニタデータ短縮名
              "mni_monitor",                                            // 参照先テーブル名
              "monitor_data",                                           // 参照先フォールド名
              item.getMoniDataNo(),                                     // 参照先JSONキー名
              item.getVitalMonitorClass(),                              // バイタル・モニタ区分
              item.getDataType().toString()                             // データ型
              );
          response.add(res);
          // del #9312 治療状況リスト，マップの表示が不正 Start
          // mod #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou start
          // itemCd++;
//          itemCd--;
          // mod #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou end
          // del #9312 治療状況リスト，マップの表示が不正 Start
        }
      }

      // #9312 Add モニタ固定項目を追加する。
      // 警報・報知固定項目
      response.add(new DispItemListResponse(
        // del #9312 治療状況リスト，マップの表示が不正 Start
//        itemCd--, // レイアウト表示項目番号
        "0", // データ取得種別('0':変換不要/'1':変換必要)
        "2", // 装置種別('2':DAD)
        "警報・報知", // 項目名
        "mni_monitor", // 参照先テーブル名
        "monitor_data", // 参照先フォールド名
        "D99", // 参照先JSONキー名
        "2", // バイタル・モニタ区分
        "D" // データ型
      ));
    }
    // システム共通項目：DRY-50A
    sysMonitorItemList = sysMonitorItemService.getMonitorItemByMoniDataType("I");
    if (sysMonitorItemList != null) {
      // システム共通項目：バイタル項目
      for( SysMonitorItem item : sysMonitorItemList ) {
        // バイタル・モニタ区分判定
        if ( Objects.equals( item.getVitalMonitorClass(), "1")) {
          // バイタル項目
          DispItemListResponse res = new DispItemListResponse(
            // del #9312 治療状況リスト，マップの表示が不正 Start
//              itemCd,                                                   // レイアウト表示項目番号
              Objects.equals(item.getConvItem(), null) ? "0" : "1",   // データ取得種別('0':変換不要/'1':変換必要)
              "2",                                                      // 装置種別('2':DAD)
              // #9312 Mod Display short name
                item.getMoniDataName(), // 項目名
//              item.getMoniDataShortName(),  // モニタデータ短縮名
              "mni_monitor",                                            // 参照先テーブル名
              "monitor_data",                                           // 参照先フォールド名
              item.getMoniDataNo(),                                     // 参照先JSONキー名
              item.getVitalMonitorClass(),                              // バイタル・モニタ区分
              item.getDataType().toString()                             // データ型
              );
          response.add(res);
          // del #9312 治療状況リスト，マップの表示が不正 Start
          // mod #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou start
          // itemCd++;
//          itemCd--;
          // mod #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou end
          // del #9312 治療状況リスト，マップの表示が不正 Start
        }
      }
      // システム共通項目：モニタ項目
      for (SysMonitorItem item : sysMonitorItemList) {
        // バイタル・モニタ区分判定
        if ( Objects.equals( item.getVitalMonitorClass(), "2")) {
          // モニタ項目
          DispItemListResponse res = new DispItemListResponse(
            // del #9312 治療状況リスト，マップの表示が不正 Start
//              itemCd,                                                   // レイアウト表示項目番号
              Objects.equals(item.getConvItem(), null) ? "0" : "1",   // データ取得種別('0':変換不要/'1':変換必要)
              "2",                                                      // 装置種別('2':DAD)
              // #9312 Mod Display short name
              item.getMoniDataName(), // 項目名
//              item.getMoniDataShortName(),  // モニタデータ短縮名
              "mni_monitor",                                            // 参照先テーブル名
              "monitor_data",                                           // 参照先フォールド名
              item.getMoniDataNo(),                                     // 参照先JSONキー名
              item.getVitalMonitorClass(),                              // バイタル・モニタ区分
              item.getDataType().toString()                             // データ型
              );
          response.add(res);
          // del #9312 治療状況リスト，マップの表示が不正 Start
          // mod #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou start
          // itemCd++;
//          itemCd--;
          // mod #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou end
          // del #9312 治療状況リスト，マップの表示が不正 Start
        }
      }
    }
    // システム共通項目：DRY-50B
    sysMonitorItemList = sysMonitorItemService.getMonitorItemByMoniDataType("J");
    if (sysMonitorItemList != null) {
      // システム共通項目：バイタル項目
      for( SysMonitorItem item : sysMonitorItemList ) {
        // バイタル・モニタ区分判定
        if ( Objects.equals( item.getVitalMonitorClass(), "1")) {
          // バイタル項目
          DispItemListResponse res = new DispItemListResponse(
            // del #9312 治療状況リスト，マップの表示が不正 Start
//              itemCd,                                                   // レイアウト表示項目番号
              Objects.equals(item.getConvItem(), null) ? "0" : "1",   // データ取得種別('0':変換不要/'1':変換必要)
              "2",                                                      // 装置種別('2':DAD)
              // #9312 Mod Display short name
                item.getMoniDataName(), // 項目名
//              item.getMoniDataShortName(),  // モニタデータ短縮名
              "mni_monitor",                                            // 参照先テーブル名
              "monitor_data",                                           // 参照先フォールド名
              item.getMoniDataNo(),                                     // 参照先JSONキー名
              item.getVitalMonitorClass(),                              // バイタル・モニタ区分
              item.getDataType().toString()                             // データ型
              );
          response.add(res);
          // del #9312 治療状況リスト，マップの表示が不正 Start
          // mod #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou start
          // itemCd++;
//          itemCd--;
          // mod #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou end
          // del #9312 治療状況リスト，マップの表示が不正 Start
        }
      }
      // システム共通項目：モニタ項目
      for (SysMonitorItem item : sysMonitorItemList) {
        // バイタル・モニタ区分判定
        if ( Objects.equals( item.getVitalMonitorClass(), "2")) {
          // モニタ項目
          DispItemListResponse res = new DispItemListResponse(
            // del #9312 治療状況リスト，マップの表示が不正 Start
//              itemCd,                                                   // レイアウト表示項目番号
              Objects.equals(item.getConvItem(), null) ? "0" : "1",   // データ取得種別('0':変換不要/'1':変換必要)
              "2",                                                      // 装置種別('2':DAD)
              // #9312 Mod Display short name
              item.getMoniDataName(), // 項目名
//              item.getMoniDataShortName(),  // モニタデータ短縮名
              "mni_monitor",                                            // 参照先テーブル名
              "monitor_data",                                           // 参照先フォールド名
              item.getMoniDataNo(),                                     // 参照先JSONキー名
              item.getVitalMonitorClass(),                              // バイタル・モニタ区分
              item.getDataType().toString()                             // データ型
              );
          response.add(res);
          // del #9312 治療状況リスト，マップの表示が不正 Start
          // mod #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou start
          // itemCd++;
          itemCd--;
          // mod #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou end
          // del #9312 治療状況リスト，マップの表示が不正 End
        }
      }
    }

    // DRO用選択項目
    // システム共通項目：DRO
    sysMonitorItemList = sysMonitorItemService.getMonitorItemByMoniDataType("R");
    if (sysMonitorItemList != null) {
      // システム共通項目：バイタル項目
      for (SysMonitorItem item : sysMonitorItemList) {
        // バイタル・モニタ区分判定
        if (Objects.equals(item.getVitalMonitorClass(), "1")) {
          // バイタル項目
          DispItemListResponse res = new DispItemListResponse(
            // del #9312 治療状況リスト，マップの表示が不正 Start
//              itemCd, // レイアウト表示項目番号
              Objects.equals(item.getConvItem(), null) ? "0" : "1", // データ取得種別('0':変換不要/'1':変換必要)
              "3", // 装置種別('3':DRO)
              // #9312 Mod Display short name
              item.getMoniDataName(), // 項目名
//              item.getMoniDataShortName(),  // モニタデータ短縮名
              "mni_monitor", // 参照先テーブル名
              "monitor_data", // 参照先フォールド名
              item.getMoniDataNo(), // 参照先JSONキー名
              item.getVitalMonitorClass(), // バイタル・モニタ区分
              item.getDataType().toString() // データ型
          );
          response.add(res);
          // del #9312 治療状況リスト，マップの表示が不正 Start
          // mod #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou start
          // itemCd++;
//          itemCd--;
          // mod #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou end
          // del #9312 治療状況リスト，マップの表示が不正 Start
        }
      }
      // システム共通項目：モニタ項目
      for (SysMonitorItem item : sysMonitorItemList) {
        // バイタル・モニタ区分判定
        if (Objects.equals(item.getVitalMonitorClass(), "2")) {
          // モニタ項目
          DispItemListResponse res = new DispItemListResponse(
            // del #9312 治療状況リスト，マップの表示が不正 Start
//              itemCd, // レイアウト表示項目番号
              Objects.equals(item.getConvItem(), null) ? "0" : "1", // データ取得種別('0':変換不要/'1':変換必要)
              "3", // 装置種別('3':DRO)
              // #9312 Mod Display short name
              item.getMoniDataName(), // 項目名
//              item.getMoniDataShortName(),  // モニタデータ短縮名
              "mni_monitor", // 参照先テーブル名
              "monitor_data", // 参照先フォールド名
              item.getMoniDataNo(), // 参照先JSONキー名
              item.getVitalMonitorClass(), // バイタル・モニタ区分
              item.getDataType().toString() // データ型
          );
          response.add(res);
          // del #9312 治療状況リスト，マップの表示が不正 Start
          // mod #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou start
          // itemCd++;
//          itemCd--;
          // mod #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou end
          // del #9312 治療状況リスト，マップの表示が不正 Start
        }
      }

      // #9312 Add モニタ固定項目を追加する。
      // 警報・報知固定項目
      response.add(new DispItemListResponse(
//        itemCd, // レイアウト表示項目番号
        "0", // データ取得種別('0':変換不要/'1':変換必要)
        "3", // 装置種別('3':DRO)
        "警報・報知", // 項目名
        "mni_monitor", // 参照先テーブル名
        "monitor_data", // 参照先フォールド名
        "R99", // 参照先JSONキー名
        "2", // バイタル・モニタ区分
        "R" // データ型
      ));
    }

    return response;
  }
  // add #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou start
  private List<MstAddMonitor> getMstAddMonitorList(String facilityCd) {
    List<MstAddMonitor> mstAddMonitorList = mstAddMonitorDao.selectByFacilityCd(facilityCd);
    MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, "mst_add_monitor");
    // ソート
    if (mstSelector != null) {
      List<MstAddMonitor> sortedList = new ArrayList<>();
      // ソート用配列
      List<Long> sortedCodes = mstSelector.getOrderSettings().getItems()
        .stream().map(e -> e.getCode()).collect(Collectors.toList());
      for (Long cd: sortedCodes) {
        Optional<MstAddMonitor> monitor = mstAddMonitorList.stream().filter(x -> x.getVitalMonitorItemCd().equals(cd)).findFirst();
        if (monitor.isPresent()) {
          MstAddMonitor mstAddMonitor = monitor.get();
          sortedList.add(mstAddMonitor);
        }
      }
      mstAddMonitorList = sortedList;
    }
    return mstAddMonitorList;
  }
  // add #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou end
  @Override
  public List<MstPersonalUser> getMstPersonalUser(String facilityCd) {
    // スタッフリスト情報作成
    List<MstPersonalUser> list = mstPersonalUserDao.selectAll(SelectOptions.get(), facilityCd, FlagType.FLAG_OFF);
    return list;
  }

  @Override
  public List<TreatmentStatusList> selectOrdMainRstUserInfo(Long ordNo) {
    return treatmentStatusListDao.selectOrdMainRstUserInfo(ordNo);

  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public TreatmentStatusUpdateResponse updateTreatmentStatus(String facilityCd,
      Map<String, Object> updateData) throws ParseException {

    //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
    EventLogMessage eventLogMessage = new EventLogMessage();
    //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end
    // debug
    for (Map.Entry<String, Object> entry : updateData.entrySet()) {
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
      eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(entry.getKey() + ":" + entry.getValue());
      logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_TREATMENT_RECORD, SERVICE_NAME.REMS, null);
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end
    }

    Long ordNo = Long.parseLong(updateData.get("ordNo").toString());
    Integer dataClass = Integer.parseInt(updateData.get("dataClass").toString());
    String oldValue = updateData.get("old").toString();
    String newValue = updateData.get("new").toString();
    String now_iso8601 = DateTimeUtils.getDateString_iso8601(new Date());
    String strwork = "";

    // 最新の治療状況：担当、穿刺、回収を取得
    List<TreatmentStatusList> nowInfo = this.selectOrdMainRstUserInfo(ordNo);
    if (nowInfo.size() <= 0) {
      return new TreatmentStatusUpdateResponse("no data.");
    }

    // 最新の治療状況を展開
    JsonNode nodePuncture = null;
    JsonNode nodeReturn = null;
    JsonNode nodeCharge = null;

    ObjectNode nodeRstPuncture = null;
    ObjectNode nodeRstReturn = null;
    ObjectNode nodeRstCharge = null;

    String strRstPuncture = null;
    String strRstReturn = null;
    String strRstCharge = null;

    // 実績：穿刺者情報(rst_puncture_user_info)
    try {
      strRstPuncture = nowInfo.get(0).getRstPunctureUserInfo();
      strwork = strRstPuncture == null ? "{}" : strRstPuncture;
      nodePuncture = mapper.readTree(strwork);
      nodeRstPuncture = nodePuncture.deepCopy().asObject();

      // 穿刺者1
      if (!nodeRstPuncture.hasNonNull("user_id_1")
        || !StringUtils.hasText(nodeRstPuncture.get("user_id_1").asText())) {
        nodeRstPuncture.put("user_id_1", "");
        nodeRstPuncture.put("user_last_name_1", "");
        nodeRstPuncture.put("user_first_name_1", "");
      }
      // 穿刺者2
      if (!nodeRstPuncture.hasNonNull("user_id_2")
        || !StringUtils.hasText(nodeRstPuncture.get("user_id_2").asText())) {
        nodeRstPuncture.put("user_id_2", "");
        nodeRstPuncture.put("user_last_name_2", "");
        nodeRstPuncture.put("user_first_name_2", "");
      }
      // 穿刺者1登録日付
      if (!nodeRstPuncture.hasNonNull("date_1")
        || !StringUtils.hasText(nodeRstPuncture.get("date_1").asText())) {
        nodeRstPuncture.put("date_1", "");
      }
      // 穿刺者2登録日付
      if (!nodeRstPuncture.hasNonNull("date_2")
        || !StringUtils.hasText(nodeRstPuncture.get("date_2").asText())) {
        nodeRstPuncture.put("date_2", "");
      }
      // 穿刺日付
      if (!nodeRstPuncture.hasNonNull("date")
        || !StringUtils.hasText(nodeRstPuncture.get("date").asText())) {
        nodeRstPuncture.put("date", "");
      }
    } catch (tools.jackson.core.JacksonException e) {
      // TODO 自動生成された catch ブロック
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessageNew = new EventLogMessage();
      eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
      if (!StringUtils.isEmpty(facilityCd)) {
        eventLogMessageNew.setFacilityCd(facilityCd);
      }
      logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }

    // 実績：返血者情報(rst_return_user_info)
    try {
      strRstReturn = nowInfo.get(0).getRstReturnUserInfo();
      strwork = strRstReturn == null ? "{}" : strRstReturn;
      nodeReturn = mapper.readTree(strwork);
      nodeRstReturn = nodeReturn.deepCopy().asObject();

      // 返血者1
      if (!nodeRstReturn.hasNonNull("user_id_1")
          || !StringUtils.hasText(nodeRstReturn.get("user_id_1").asText())) {
        nodeRstReturn.put("user_id_1", "");
        nodeRstReturn.put("user_last_name_1", "");
        nodeRstReturn.put("user_first_name_1", "");
      }
      // 返血者2
      if (!nodeRstReturn.hasNonNull("user_id_2")
          || !StringUtils.hasText(nodeRstReturn.get("user_id_2").asText())) {
        nodeRstReturn.put("user_id_2", "");
        nodeRstReturn.put("user_last_name_2", "");
        nodeRstReturn.put("user_first_name_2", "");
      }
      // 返血者1登録日付
      if (!nodeRstReturn.hasNonNull("date_1")
          || !StringUtils.hasText(nodeRstReturn.get("date_1").asText())) {
        nodeRstReturn.put("date_1", "");
      }
      // 返血者2登録日付
      if (!nodeRstReturn.hasNonNull("date_2")
          || !StringUtils.hasText(nodeRstReturn.get("date_2").asText())) {
        nodeRstReturn.put("date_2", "");
      }
      // 返血日付
      if (!nodeRstReturn.hasNonNull("date")
          || StringUtils.hasText(nodeRstReturn.get("date").asText())) {
        nodeRstReturn.put("date", "");
      }
    } catch (tools.jackson.core.JacksonException e) {
      // TODO 自動生成された catch ブロック
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessageNew = new EventLogMessage();
      eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
      if (!StringUtils.isEmpty(facilityCd)) {
        eventLogMessageNew.setFacilityCd(facilityCd);
      }
      logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }

    // 実績：担当者情報(rst_charge_user_info)
    try {
      strRstCharge = nowInfo.get(0).getRstChargeUserInfo();
      strwork = strRstCharge == null ? "{}" : strRstCharge;
      nodeCharge = mapper.readTree(strwork);
      nodeRstCharge = nodeCharge.deepCopy().asObject();

      // 担当者1
      if (!nodeRstCharge.hasNonNull("user_id_1")
          || !StringUtils.hasText(nodeRstCharge.get("user_id_1").asText())) {
        nodeRstCharge.put("user_id_1", "");
        nodeRstCharge.put("user_last_name_1", "");
        nodeRstCharge.put("user_first_name_1", "");
      }
      // 担当者2
      if (!nodeRstCharge.hasNonNull("user_id_2")
          || !StringUtils.hasText(nodeRstCharge.get("user_id_2").asText())) {
        nodeRstCharge.put("user_id_2", "");
        nodeRstCharge.put("user_last_name_2", "");
        nodeRstCharge.put("user_first_name_2", "");
      }
      // 担当者1登録日付
      if (!nodeRstCharge.hasNonNull("date_1")
          || !StringUtils.hasText(nodeRstCharge.get("date_1").asText())) {
        nodeRstCharge.put("date_1", "");
      }
      // 担当者2登録日付
      if (!nodeRstCharge.hasNonNull("date_2")
          || !StringUtils.hasText(nodeRstCharge.get("date_2").asText())) {
        nodeRstCharge.put("date_2", "");
      }
    } catch (tools.jackson.core.JacksonException e) {
      // TODO 自動生成された catch ブロック
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessageNew = new EventLogMessage();
      eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
      if (!StringUtils.isEmpty(facilityCd)) {
        eventLogMessageNew.setFacilityCd(facilityCd);
      }
      logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }

    // 更新情報作成
    Boolean bUpdate = true;
    try {
      switch (dataClass) {
      case 23:// 担当者1
//        strwork = nodeRstCharge.get("user_id_1").toString().equals("\"\"") ? ""
//            : nodeRstCharge.get("user_id_1").toString();
        strwork = nodeRstCharge != null
          && nodeRstCharge.hasNonNull("user_id_1")
          && StringUtils.hasText(nodeRstCharge.get("user_id_1").asText())
          ? nodeRstCharge.get("user_id_1").asText() : "";
        if (strwork.equals("") || strwork.equals(oldValue)) {
          Long newUserId = Long.parseLong(newValue);
          nodeRstCharge.put("user_id_1", newUserId);
          nodeRstCharge.put("date_1", now_iso8601);
          MstPersonalUser user = mstPersonalUserDao.selectById(newUserId);
          nodeRstCharge.put("user_last_name_1", Objects.isNull(user) ? "" : user.getUserLastName());
          nodeRstCharge.put("user_first_name_1", Objects.isNull(user) ? "" : user.getUserFirstName());

          //
          strRstCharge = mapper.writeValueAsString(nodeRstCharge).replaceAll("\"\"", "null");
        } else {
          bUpdate = false;
        }
        break;
      case 24:// 担当者1登録日時
        break;
      case 25:// 担当者2
//        strwork = nodeRstCharge.get("user_id_2").toString().equals("\"\"") ? ""
//            : nodeRstCharge.get("user_id_2").toString();
        strwork = nodeRstCharge != null
          && nodeRstCharge.hasNonNull("user_id_2")
          && StringUtils.hasText(nodeRstCharge.get("user_id_2").asText())
          ? nodeRstCharge.get("user_id_2").asText() : "";
        if ((strwork.equals("") || strwork.equals(oldValue))
          && nodeRstCharge != null) {
          Long newUserId = Long.parseLong(newValue);
          nodeRstCharge.put("user_id_2", newUserId);
          nodeRstCharge.put("date_2", now_iso8601);
          MstPersonalUser user = mstPersonalUserDao.selectById(newUserId);
          nodeRstCharge.put("user_last_name_2", Objects.isNull(user) ? "" : user.getUserLastName());
          nodeRstCharge.put("user_first_name_2", Objects.isNull(user) ? "" : user.getUserFirstName());

          //
          strRstCharge = mapper.writeValueAsString(nodeRstCharge).replaceAll("\"\"", "null");
        } else {
          bUpdate = false;
        }
        break;
      case 26:// 担当者2登録日時
        break;
      case 27:// 穿刺日時
//        strwork = nodeRstPuncture.get("date").toString().equals("\"\"") ? "" : nodeRstPuncture.get("date").toString();
        strwork = nodeRstPuncture != null
          && nodeRstPuncture.hasNonNull("date")
          && StringUtils.hasText(nodeRstPuncture.get("date").asText())
          ? nodeRstPuncture.get("date").asText() : "";

        if ((strwork.equals("") || strwork.substring(0, 17).equals(oldValue.substring(0, 17)))
            && nodeRstPuncture != null) {
          nodeRstPuncture.put("date", newValue);
          strRstPuncture = mapper.writeValueAsString(nodeRstPuncture).replaceAll("\"\"", "null");
        } else {
          bUpdate = false;
        }
        break;
      case 28:// 穿刺者1
//        strwork = nodeRstPuncture.get("user_id_1").toString().equals("\"\"") ? ""
//            : nodeRstPuncture.get("user_id_1").toString();
        strwork = nodeRstPuncture != null
          && nodeRstPuncture.hasNonNull("user_id_1")
          && StringUtils.hasText(nodeRstPuncture.get("user_id_1").asText())
          ? nodeRstPuncture.get("user_id_1").asText() : "";
        if ((strwork.equals("") || strwork.equals(oldValue)) && nodeRstPuncture != null) {
          Long newUserId = Long.parseLong(newValue);
          nodeRstPuncture.put("user_id_1", newUserId);
          nodeRstPuncture.put("date_1", now_iso8601);
          MstPersonalUser user = mstPersonalUserDao.selectById(newUserId);
          nodeRstPuncture.put("user_last_name_1", Objects.isNull(user) ? "" : user.getUserLastName());
          nodeRstPuncture.put("user_first_name_1", Objects.isNull(user) ? "" : user.getUserFirstName());

          // 穿刺日時判定
          strwork = nodeRstPuncture.hasNonNull("date")
            && StringUtils.hasText(nodeRstPuncture.get("date").asText())
            ? nodeRstPuncture.get("date").asText() : "";
          if ("".equals(strwork)) {
            nodeRstPuncture.put("date", now_iso8601);
          }

          //
          strRstPuncture = mapper.writeValueAsString(nodeRstPuncture).replaceAll("\"\"", "null");
        } else {
          bUpdate = false;
        }
        break;
      case 29:// 穿刺者1登録日時
        break;
      case 30:// 穿刺者2
//        strwork = nodeRstPuncture.get("user_id_2").toString().equals("\"\"") ? ""
//            : nodeRstPuncture.get("user_id_2").toString();
        strwork = nodeRstPuncture != null
          && nodeRstPuncture.hasNonNull("user_id_2")
          && StringUtils.hasText(nodeRstPuncture.get("user_id_2").asText())
          ? nodeRstPuncture.get("user_id_2").asText() : "";
        if ((strwork.equals("") || strwork.equals(oldValue))
            && nodeRstPuncture != null) {
          Long newUserId = Long.parseLong(newValue);
          nodeRstPuncture.put("user_id_2", newUserId);
          nodeRstPuncture.put("date_2", now_iso8601);
          MstPersonalUser user = mstPersonalUserDao.selectById(newUserId);
          nodeRstPuncture.put("user_last_name_2", Objects.isNull(user) ? "" : user.getUserLastName());
          nodeRstPuncture.put("user_first_name_2", Objects.isNull(user) ? "" : user.getUserFirstName());

          // 穿刺日時判定
          strwork = nodeRstPuncture.hasNonNull("date")
            && StringUtils.hasText(nodeRstPuncture.get("date").asText())
            ? nodeRstPuncture.get("date").asText() : "";
          if ("".equals(strwork)) {
            nodeRstPuncture.put("date", now_iso8601);
          }

          //
          strRstPuncture = mapper.writeValueAsString(nodeRstPuncture).replaceAll("\"\"", "null");
        } else {
          bUpdate = false;
        }
        break;
      case 31:// 穿刺者2登録日時
        break;
      case 32:// 返血日時
//        strwork = nodeRstReturn.get("date").toString().equals("\"\"") ? "" : nodeRstReturn.get("date").toString();
        strwork = nodeRstReturn != null
          && nodeRstReturn.hasNonNull("date")
          && StringUtils.hasText(nodeRstReturn.get("date").asText())
          ? nodeRstReturn.get("date").asText() : "";
        if (("".equals(strwork) || strwork.substring(0, 17).equals(oldValue.substring(0, 17)))
          && nodeRstReturn != null) {
          nodeRstReturn.put("date", newValue);

          //
          strRstReturn = mapper.writeValueAsString(nodeRstReturn).replaceAll("\"\"", "null");
        } else {
          bUpdate = false;
        }
        break;
      case 33:// 返血者1
//        strwork = nodeRstReturn.get("user_id_1").toString().equals("\"\"") ? ""
//            : nodeRstReturn.get("user_id_1").toString();
        strwork = nodeRstReturn != null
          && nodeRstReturn.hasNonNull("user_id_1")
          && StringUtils.hasText(nodeRstReturn.get("user_id_1").asText())
          ? nodeRstReturn.get("user_id_1").asText() : "";
        if (("".equals(strwork) || strwork.equals(oldValue))
          && nodeRstReturn != null) {
          Long newUserId = Long.parseLong(newValue);
          nodeRstReturn.put("user_id_1", newUserId);
          nodeRstReturn.put("date_1", now_iso8601);
          MstPersonalUser user = mstPersonalUserDao.selectById(newUserId);
          nodeRstReturn.put("user_last_name_1", Objects.isNull(user) ? "" : user.getUserLastName());
          nodeRstReturn.put("user_first_name_1", Objects.isNull(user) ? "" : user.getUserFirstName());

          // 返血日時判定
          //#10264：治療状況リストにて返血者1を選択するとシステムエラーになり登録できない。 Start
          strwork = nodeRstReturn.hasNonNull("date")
            && StringUtils.hasText(nodeRstReturn.get("date").asText())
            ? nodeRstReturn.get("date").asText() : "";
          //#10264：治療状況リストにて返血者1を選択するとシステムエラーになり登録できない。 End
          if ("".equals(strwork)) {
            nodeRstReturn.put("date", now_iso8601);
          }

          //
          strRstReturn = mapper.writeValueAsString(nodeRstReturn).replaceAll("\"\"", "null");
        } else {
          bUpdate = false;
        }
        break;
      case 34:// 返血者1登録日時
        break;
      case 35:// 返血者2
//        strwork = nodeRstReturn.get("user_id_2").toString().equals("\"\"") ? ""
//            : nodeRstReturn.get("user_id_2").toString();
        strwork = nodeRstReturn != null
          && nodeRstReturn.hasNonNull("user_id_2")
          && StringUtils.hasText(nodeRstReturn.get("user_id_2").asText())
          ? nodeRstReturn.get("user_id_2").asText() : "";
        if (nodeRstReturn != null
          && (strwork.equals("") || strwork.equals(oldValue))) {
          Long newUserId = Long.parseLong(newValue);
          nodeRstReturn.put("user_id_2", newUserId);
          nodeRstReturn.put("date_2", now_iso8601);
          MstPersonalUser user = mstPersonalUserDao.selectById(newUserId);
          nodeRstReturn.put("user_last_name_2", Objects.isNull(user) ? "" : user.getUserLastName());
          nodeRstReturn.put("user_first_name_2", Objects.isNull(user) ? "" : user.getUserFirstName());

          //#10264：治療状況リストにて返血者1を選択するとシステムエラーになり登録できない。 Start
          // 返血日時判定
          strwork = nodeRstReturn.hasNonNull("date")
          && StringUtils.hasText(nodeRstReturn.get("date").asText())
          ? nodeRstReturn.get("date").asText() : "";
          //#10264：治療状況リストにて返血者1を選択するとシステムエラーになり登録できない。 Start
          if ("".equals(strwork)) {
            nodeRstReturn.put("date", now_iso8601);
          }

          //
          strRstReturn = mapper.writeValueAsString(nodeRstReturn).replaceAll("\"\"", "null");
        } else {
          bUpdate = false;
        }
        break;
      case 36:// 返血者2登録日時
        break;
      }
    } catch (JacksonException e) {
      // TODO 自動生成された catch ブロック
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessageNew = new EventLogMessage();
      eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
      if (!StringUtils.isEmpty(facilityCd)) {
        eventLogMessageNew.setFacilityCd(facilityCd);
      }
      logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }

    if (bUpdate) {

      // add FNSI-改修内容追加OrdMain履歴 付 start
      getHistory(ordNo);
      // mangoDb-updateOrdMainRstUserInfo-insertSuccess
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

      int updateCount = treatmentStatusListDao.updateOrdMainRstUserInfo(ordNo, strRstPuncture, strRstReturn, strRstCharge);

      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && updateCount > 0) {
        logCommon.updateLog();
      }
      // DB更新ログ出力ロジック wangzuo End

      return new TreatmentStatusUpdateResponse();
    } else {
      return new TreatmentStatusUpdateResponse("not update.");
    }
  }

  // add FNSI-改修内容追加OrdMain履歴 付 start
  private void getHistory(Long ordNo){
    selectHistoryUtils.insertMangoDbHistory(1, ordNo, null, new ArrayList<>(), new ArrayList<>(), null, null,
      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
      new ArrayList<>(), null, null);
  }
  // add FNSI-改修内容追加OrdMain履歴 付 end

  /**
    * 装置マスタを取得
    * @param facilityCd
    * @param machineTypeCd
    * @param machineSerial
    * @return
    */
  public MachineKeyInfo getMstMachineKeyInfo(String facilityCd, Long machineNo) {
    MachineKeyInfo machine = mstMachineDao.selectKeyWithModelByMachineNo(facilityCd, machineNo, FlagType.FLAG_ON,
        FlagType.FLAG_OFF);
    // 表示フラグ有効、削除フラグ無効の装置のみ取得
    if (machine != null) {
      return machine;
    } else {
      return null;
    }
  }

  /**
    * ベッドマスタを取得
    * @param bedCd
    * @return
    */
  @Override
  public MstBed getMstBed(Long bedCd) {
    // 表示フラグ有効、削除フラグ無効のベッドのみ取得
    return mstBedDao.selectByBedCd(bedCd, FlagType.FLAG_ON, FlagType.FLAG_OFF);
  }

  /**
    * ベッドの装置を取得
    * @param bedCd
    * @return
    */
  public MachineKeyInfo getBedMachineInfo(Long bedCd) {
    MstBed bed = getMstBed(bedCd);
    if (bed != null) {
      return getMstMachineKeyInfo(bed.getFacilityCd(), bed.getMachineNo());
    } else {
      return null;
    }
  }

  /**
    * 型式マスタを取得
    * @param machineTypeCd
    * @return
    */
  @Override
  public MstMachineType getMstMachineType(String machineTypeCd) {
    return mstMachineTypeDao.selectByTypeCd(machineTypeCd);
  }

  /* add by chamaojia 2024-03-28 [10303、10304] implementation of new treatment status related functions --start */
  @Override
  public TreatmentStatusListResponse getTreatmentStatusListToOrdNo(String facilityCd, String treatDate,
                                                                   String layoutNo, String bedGroupCd, String kurCdS, String nextPat) {
    // retrieve the dataset of the bed
    List<Long> bedCdList = new ArrayList<>();
    if(StringUtils.hasText(bedGroupCd) && Long.parseLong(bedGroupCd) > 0L){
      bedCdList = getBedCdListByGroupCd(bedGroupCd);
    }

    // kur data
    List<Long> kurCdList = new ArrayList<>();
    if(StringUtils.hasText(kurCdS)){
      String[] kurCdsArray = kurCdS.split(",");
      if(kurCdsArray.length > 0 && Long.parseLong(kurCdsArray[0]) > 0L){
        kurCdList = Arrays.stream(kurCdsArray).mapToLong(Long::parseLong)
                .boxed().collect(Collectors.toList());
      }
    }

    // query the current patient list（status1-5）
    List<TreatmentStatusList> treatmentStatus = treatmentStatusListDao.selectTreatStatusListToOrd(facilityCd, bedCdList, kurCdList);
    if (!"0".equals(nextPat)) {
      // query secondary patients and organize data based on query criteria
      List<TreatmentStatusList> treatmentStatusListToNext = getNextPatTreatmentStatusInfo(facilityCd, nextPat, bedCdList, kurCdList);
      treatmentStatus.addAll(treatmentStatusListToNext);
    }

    Comparator<TreatmentStatusList> treatmentStatusListComparator = Comparator
      .comparing(TreatmentStatusList::getOrdIndex, Comparator.nullsLast(Comparator.naturalOrder()))
      .thenComparing(TreatmentStatusList::getTreatDate, Comparator.nullsLast(Comparator.naturalOrder()))
      .thenComparing(TreatmentStatusList::getKurStartTime, Comparator.nullsLast(Comparator.naturalOrder()));

    treatmentStatus.sort(treatmentStatusListComparator);

    /* modify by chamaojia 2024-10-24 [9312] add param 【functionCode】 --start */
    return makeTreatmentStatusList(facilityCd, treatDate, layoutNo, treatmentStatus, "1");
    /* modify by chamaojia 2024-10-24 [9312] add param 【functionCode】 --end */
  }

  @Override
  public TreatmentStatusListResponse getTreatmentStatusListToMachine(String facilityCd, String treatDate,
                                                                     String layoutNo, String bedGroupCd, String nextPat) {
    // find the corresponding bed information
    List<Long> bedCdList = new ArrayList<>();
    if(StringUtils.hasText(bedGroupCd) && Long.parseLong(bedGroupCd) > 0L) {
      bedCdList = getBedCdListByGroupCd(bedGroupCd);
    }

    // query dialysis device
    List<MntMachineFormat> mntMachineFormats = mntMachineStateDao.selectMachinesToTreatmentStatus(facilityCd, bedCdList);

    // current patient inquiry (machine_status.ord_no = ord_main.ord_no)
    /* modify by chamaojia 2024-10-24 [9312] add param 【functionCode】 --start */
    List<TreatmentStatusList> treatmentStatusListToNow = treatmentStatusListDao.selectTreatStatusListToMachineNow(facilityCd, bedCdList, "1");
    /* modify by chamaojia 2024-10-24 [9312] add param 【functionCode】 --end */

    List<TreatmentStatusList> treatmentStatusListToNext = new ArrayList<>();
    if (!"0".equals(nextPat)) {
      // secondary patient inquiry (machine_status.next_ord_no = ord_main.ord_no)
      treatmentStatusListToNext = getNextPatTreatmentStatusInfo(facilityCd, nextPat, bedCdList, new ArrayList<>());
    }

    List<TreatmentStatusList> bedOrdIndexList = treatmentStatusListDao.selectBedOrdIndex(facilityCd);

    List<TreatmentStatusList> treatmentStatus = new ArrayList<>();
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
    String nowDate = LocalDate.now().format(formatter);
    // using devices as data dimensions to match data
    for (MntMachineFormat mntMachineFormat : mntMachineFormats) {
      TreatmentStatusList entity = new TreatmentStatusList();

      if (!"0".equals(nextPat)) {
        // priority matching for secondary patients
        TreatmentStatusList treatmentStatusListNext = treatmentStatusListToNext.stream().filter(t -> t.getMachineTypeCd().equals(mntMachineFormat.getMachineTypeCd())
                && t.getMachineSerial().equals(mntMachineFormat.getMachineSerial())).findFirst().orElse(null);
        if (treatmentStatusListNext != null) {
          entity = treatmentStatusListNext;
          entity.setIndMstBedName(mntMachineFormat.getBedName());
          treatmentStatus.add(entity);
          continue;
        }
      }

      TreatmentStatusList treatmentStatusListNow = treatmentStatusListToNow.stream().filter(t -> t.getMachineTypeCd().equals(mntMachineFormat.getMachineTypeCd())
              && t.getMachineSerial().equals(mntMachineFormat.getMachineSerial())).findFirst().orElse(null);
      if (treatmentStatusListNow != null) {
        entity = treatmentStatusListNow;
        entity.setIndMstBedName(mntMachineFormat.getBedName());
        entity.setRstBedName(mntMachineFormat.getBedName());
        treatmentStatus.add(entity);
        continue;
      }

      TreatmentStatusList bedOrdIndex = bedOrdIndexList.stream().filter(t -> t.getIndBedCd().equals(mntMachineFormat.getBedCd())).findFirst().orElse(null);
      if (bedOrdIndex != null) {
        entity = bedOrdIndex;
      }

      entity.setMachineEntry(-1);
      entity.setIndMstBedName(mntMachineFormat.getBedName());
      entity.setTreatDate(nowDate);

      //add #10063 by zhangruixue 2024-04-08 --start
      entity.setIndBedCd(mntMachineFormat.getBedCd());
      //add #10063 by zhangruixue 2024-04-08 --end

      treatmentStatus.add(entity);
    }

    Comparator<TreatmentStatusList> treatmentStatusListComparator = Comparator
      .comparing(TreatmentStatusList::getOrdIndex, Comparator.nullsLast(Comparator.naturalOrder()))
      .thenComparing(TreatmentStatusList::getTreatDate, Comparator.nullsLast(Comparator.naturalOrder()))
      .thenComparing(TreatmentStatusList::getKurStartTime, Comparator.nullsLast(Comparator.naturalOrder()));

    treatmentStatus.sort(treatmentStatusListComparator);

    /* modify by chamaojia 2024-10-24 [9312] add param 【functionCode】 --start */
    return makeTreatmentStatusList(facilityCd, treatDate, layoutNo, treatmentStatus, "2");
    /* modify by chamaojia 2024-10-24 [9312] add param 【functionCode】 --end */
  }

  @Override
  public TreatmentStatusListResponse getTreatmentStatusMapToBed(String facilityCd, String layoutNo
          , String bedGroupCd, String nextPat, Long bedLayoutId) {
    List<Long> layoutToBedCdList = new ArrayList<>();
    if (bedLayoutId != -1) {
      layoutToBedCdList = mstStatusMapBedLayoutDao.selectByFacilityCdAndLayoutIdToBedCd(facilityCd, bedLayoutId);
    }

    List<Long> groupToBedCdList = new ArrayList<>();
    if(StringUtils.hasText(bedGroupCd) && Long.parseLong(bedGroupCd) > 0L){
      groupToBedCdList = getBedCdListByGroupCd(bedGroupCd);
    }

    // intersection of two sets
    List<Long> bedCdList = getListIntersectionToBed(layoutToBedCdList, groupToBedCdList);

    // query dialysis device
    List<MntMachineFormat> mntMachineFormats = mntMachineStateDao.selectMachinesToTreatmentStatus(facilityCd, bedCdList);

    // current patient inquiry (machine_status.ord_no = ord_main.ord_no)
    /* modify by chamaojia 2024-10-24 [9312] add param 【functionCode】 --start */
    List<TreatmentStatusList> treatmentStatusListToNow = treatmentStatusListDao.selectTreatStatusListToMachineNow(facilityCd, bedCdList, "2");
    /* modify by chamaojia 2024-10-24 [9312] add param 【functionCode】 --end */

    List<TreatmentStatusList> treatmentStatusListToNext = new ArrayList<>();
    if (!"0".equals(nextPat)) {
      // query secondary patients
      treatmentStatusListToNext = getNextPatTreatmentStatusInfo(facilityCd, nextPat, bedCdList, new ArrayList<>());
    }

    List<TreatmentStatusList> treatmentStatus = new ArrayList<>();
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
    String nowDate = LocalDate.now().format(formatter);
    // using devices as data dimensions to match data
    for (MntMachineFormat mntMachineFormat : mntMachineFormats) {
      TreatmentStatusList entity = null;

      if (!"0".equals(nextPat)) {
        // priority matching for secondary patients
        TreatmentStatusList treatmentStatusListNext = treatmentStatusListToNext.stream().filter(t -> t.getMachineTypeCd().equals(mntMachineFormat.getMachineTypeCd())
                && t.getMachineSerial().equals(mntMachineFormat.getMachineSerial())).findFirst().orElse(null);
        if (treatmentStatusListNext != null) {
          entity = treatmentStatusListNext;
          entity.setIndMstBedName(mntMachineFormat.getBedName());
          treatmentStatus.add(entity);
          continue;
        }
      }

      TreatmentStatusList treatmentStatusListNow = treatmentStatusListToNow.stream().filter(t -> t.getMachineTypeCd().equals(mntMachineFormat.getMachineTypeCd())
              && t.getMachineSerial().equals(mntMachineFormat.getMachineSerial())).findFirst().orElse(null);
      if (treatmentStatusListNow != null) {
        entity = treatmentStatusListNow;
        entity.setIndMstBedName(mntMachineFormat.getBedName());
        entity.setRstBedName(mntMachineFormat.getBedName());
        treatmentStatus.add(entity);
        continue;
      }

      //add #10063 by zhangruixue 2024-04-08 --start
      entity = new TreatmentStatusList();
      entity.setIndMstBedName(mntMachineFormat.getBedName());
      entity.setIndBedCd(mntMachineFormat.getBedCd());
      entity.setTreatDate(nowDate);
      treatmentStatus.add(entity);
      //add #10063 by zhangruixue 2024-04-08 --end
    }

    /* modify by chamaojia 2024-10-24 [9312] add param 【functionCode】 --start */
    return makeTreatmentStatusList(facilityCd, "00000000", layoutNo, treatmentStatus, "3");
    /* modify by chamaojia 2024-10-24 [9312] add param 【functionCode】 --end */
  }

  /**
   * data of Combined Bed
   * @return
   */
  private List<Long> getListIntersectionToBed(List<Long> layoutToBedCdList, List<Long> groupToBedCdList) {
    List<Long> bedCdList = new ArrayList<>();
    if (layoutToBedCdList.size() > 0 && groupToBedCdList.size() == 0) {
      bedCdList = layoutToBedCdList;
    } else if (layoutToBedCdList.size() == 0 && groupToBedCdList.size() > 0) {
      bedCdList = groupToBedCdList;
    } else if (layoutToBedCdList.size() > 0 && groupToBedCdList.size() > 0) {
      Set<Long> layoutToBedCdSet = new HashSet<>(layoutToBedCdList);
      Set<Long> groupToBedCdSet = new HashSet<>(groupToBedCdList);
      layoutToBedCdSet.retainAll(groupToBedCdSet);
      bedCdList = new ArrayList<>(layoutToBedCdSet);
    }
    return bedCdList;
  }

  /**
   * query secondary patients and assemble a dataset
   * @return
   */
  public List<TreatmentStatusList> getNextPatTreatmentStatusInfo(String facilityCd, String nextPat, List<Long> bedCdList, List<Long> kurCdList) {
    List<TreatmentStatusList> treatmentStatusLists = new ArrayList<>();
    // secondary patient inquiry
    List<TreatmentStatusList> treatmentStatusListToNext = treatmentStatusListDao.selectTreatStatusListToMachineNext(facilityCd, bedCdList, kurCdList);

    // Query 【クール】 data （ordered）
    List<MstKur> mstKurs = mstKurDao.selectByFacilityCd(SelectOptions.get(), facilityCd, AdminWebConstant.FlagType.FLAG_OFF);
    DateTimeFormatter dateFormatHms = DateTimeFormatter.ofPattern("HHmmss");
    DateTimeFormatter dateFormatYmd = DateTimeFormatter.ofPattern("yyyyMMdd");
    LocalTime nowHHmmss = LocalTime.now();
    // current date
    String nowYmd = LocalDate.now().format(dateFormatYmd);
    // after【クール】data List
    List<Long> afterKurCd = new ArrayList<>();
    // The current time corresponds to the [クール] position marker
    int currentKurPos = 0;
    for (int i = 0; i < mstKurs.size(); i++) {
      if (LocalTime.parse(mstKurs.get(i).getKurStartTime(), dateFormatHms).isBefore(nowHHmmss)
              && LocalTime.parse(mstKurs.get(i).getKurEndTime(), dateFormatHms).isAfter(nowHHmmss)) {
        currentKurPos = i;
        if (i != mstKurs.size() - 1) {
          int pos = i + 1;
          while (pos < mstKurs.size()) {
            afterKurCd.add(Long.valueOf(mstKurs.get(pos).getKurCd()));
            pos++;
          }
        }
        break;
      }
    }
//    // 次kurCode
//    Long nextKurCd = null;
    // 次kur data
    String nextKurDate = LocalDate.now().format(dateFormatYmd);
    Long nextDayFirstKurCd = null;
    Long lastFlg = null;
    // locate to the next [クール] and corresponding date
    if ("2".equals(nextPat)) { // 次クール
      //mod #12358 治療状況リスト・治療状況マップ・チェックリストの次患者表示次クールで数日先の予定が表示した。 zrx start
//      List<TreatmentStatusList> allNextPatList = null;
//      if (bedCdList.size() == 0 && kurCdList.size() == 0) {
//        allNextPatList = treatmentStatusListToNext;
//      } else {
//        // query secondary patient data for all devices
//        allNextPatList = treatmentStatusListDao.selectAllNextPatToOrdMain(facilityCd);
//      }
//
//      // is there a flag for the second [クール] of the day
//      boolean nextKurExitsFlag = false;
//      if (afterKurCd.size() > 0) {
//        for (Long kurCd : afterKurCd) {
//          List<TreatmentStatusList> dataList = allNextPatList.stream().filter(t -> t.getTreatDate().equals(nowYmd) && kurCd.equals(t.getIndKurCd())).collect(Collectors.toList());
//          if (dataList != null && dataList.size() > 0) {
//            nextKurCd = kurCd;
//            nextKurExitsFlag = true;
//            break;
//          }
//        }
//      }
//
//      if (!nextKurExitsFlag) {
//        List<TreatmentStatusList> dataList = allNextPatList.stream().filter(t -> LocalDate.parse(t.getTreatDate(), dateFormatYmd).isAfter(LocalDate.parse(nowYmd, dateFormatYmd))).collect(Collectors.toList());
//        if (dataList != null && dataList.size() > 0) {
//          TreatmentStatusList minDateEntity = Collections.min(dataList, Comparator.comparing(TreatmentStatusList::getTreatDate));
//          nextKurDate = minDateEntity.getTreatDate();
//
//          String finalNextKurDate = nextKurDate;
//          List<TreatmentStatusList> nextKurDateTreatmentStatusList = allNextPatList.stream()
//                  .filter(t -> t.getTreatDate().equals(finalNextKurDate)).collect(Collectors.toList());
//
//          for (MstKur mstKur : mstKurs) {
//            List<TreatmentStatusList> kurToDataList = nextKurDateTreatmentStatusList.stream()
//                    .filter(t -> Long.valueOf(mstKur.getKurCd()).equals(t.getIndKurCd())).collect(Collectors.toList());
//            if (kurToDataList != null && kurToDataList.size() > 0) {
//              nextKurCd = Long.valueOf(mstKur.getKurCd());
//              break;
//            }
//          }
//        }
//      }
      List<TreatmentStatusList> allNextPatList = treatmentStatusListDao.selectAllNextPatToOrdMain(facilityCd);
      if(allNextPatList != null && allNextPatList.size() > 0) {
        nextDayFirstKurCd = allNextPatList.get(0).getFirstKurCd();
        nextKurDate = allNextPatList.get(0).getTargetDate();
        lastFlg = allNextPatList.get(0).getLastFlg();
      }

      //mod #12358 治療状況リスト・治療状況マップ・チェックリストの次患者表示次クールで数日先の予定が表示した。 zrx end
    }

    for (TreatmentStatusList entity : treatmentStatusListToNext) {
      MstKur inLoopMstKur = mstKurs.stream().filter(k -> Long.valueOf(k.getKurCd()).equals(entity.getIndKurCd())).findFirst().orElse(null);
      //mod #12358 治療状況リスト・治療状況マップ・チェックリストの次患者表示次クールで数日先の予定が表示した。 zrx start
      if ("2".equals(nextPat)) {// 次クール
        if (nowYmd.equals(entity.getTreatDate())) {//当日
          treatmentStatusLists.add(entity);
        }
        if (lastFlg == 1) {//翌日
          if (nextKurDate.equals(entity.getTreatDate()) && entity.getIndKurCd().equals(nextDayFirstKurCd) ) {//翌日 午前
            treatmentStatusLists.add(entity);
          }
        }
      } else {
        // consistent dates  and  <=current[クール]
        if (nowYmd.equals(entity.getTreatDate()) && mstKurs.indexOf(inLoopMstKur) <= currentKurPos) {
          treatmentStatusLists.add(entity);
        }
      }
//      // consistent dates  and  <=current[クール]
//      if (nowYmd.equals(entity.getTreatDate()) && mstKurs.indexOf(inLoopMstKur) <= currentKurPos) {
//        treatmentStatusLists.add(entity);
//      }
//
//      if ("2".equals(nextPat) && nextKurCd != null) {  // 次クール
//        if (nextKurDate.equals(entity.getTreatDate()) && nextKurCd.equals(entity.getIndKurCd())) {
//          treatmentStatusLists.add(entity);
//        }
//      }
      //mod #12358 治療状況リスト・治療状況マップ・チェックリストの次患者表示次クールで数日先の予定が表示した。 zrx end
    }

    return treatmentStatusLists;
  }

  @Override
  public TreatmentStatusListResponse getTreatmentStatusMapToSchedule(String facilityCd, String treatDate, String layoutNo
          , String bedGroupCd, Long bedLayoutId, Long kurCd) {
    List<Long> layoutToBedCdList = new ArrayList<>();
    if (bedLayoutId != -1) {
      layoutToBedCdList = mstStatusMapBedLayoutDao.selectByFacilityCdAndLayoutIdToBedCd(facilityCd, bedLayoutId);
    }

    List<Long> groupToBedCdList = new ArrayList<>();
    if(StringUtils.hasText(bedGroupCd) && Long.parseLong(bedGroupCd) > 0L){
      groupToBedCdList = getBedCdListByGroupCd(bedGroupCd);
    }

    // intersection of two sets
    List<Long> bedCdList = getListIntersectionToBed(layoutToBedCdList, groupToBedCdList);

    //add #10063 by zhangruixue 2024-04-08 --start

    List<TreatmentStatusList> treatmentStatus = new ArrayList<>();

    // query dialysis device
    List<MntMachineFormat> mntMachineFormats = mntMachineStateDao.selectMachinesToTreatmentStatus(facilityCd, bedCdList);

    List<TreatmentStatusList> treatmentStatusList = treatmentStatusListDao.selectTreatmentStatusMapToSchedule(facilityCd, treatDate, kurCd, bedCdList);

    for (MntMachineFormat mntMachineFormat : mntMachineFormats) {
      TreatmentStatusList entity = null;
      TreatmentStatusList treatmentStatusListNow = treatmentStatusList.stream().filter(t -> Objects.equals(t.getMachineTypeCd(), mntMachineFormat.getMachineTypeCd())
              && Objects.equals(t.getMachineSerial(),mntMachineFormat.getMachineSerial())).findFirst().orElse(null);
      if (treatmentStatusListNow != null) {
        entity = treatmentStatusListNow;
        entity.setIndMstBedName(mntMachineFormat.getBedName());
        entity.setRstBedName(mntMachineFormat.getBedName());
        entity.setIndBedCd(mntMachineFormat.getBedCd());
        treatmentStatus.add(entity);
        continue;
      }

      entity = new TreatmentStatusList();
      entity.setIndMstBedName(mntMachineFormat.getBedName());
      entity.setIndBedCd(mntMachineFormat.getBedCd());
      entity.setTreatDate(treatDate);
      treatmentStatus.add(entity);
    }
    //add #10063 by zhangruixue 2024-04-08 --end

//    List<TreatmentStatusList> treatmentStatus = treatmentStatusListDao.selectTreatmentStatusMapToSchedule(facilityCd, treatDate, kurCd, bedCdList);

    /* modify by chamaojia 2024-10-24 [9312] add param 【functionCode】 --start */
    return makeTreatmentStatusList(facilityCd, treatDate, layoutNo, treatmentStatus, "4");
    /* modify by chamaojia 2024-10-24 [9312] add param 【functionCode】 --end */
  }
  /* add by chamaojia 2024-03-28 [10303、10304] implementation of new treatment status related functions --end */

  /* add #8872 by zhangruixue 2023-06-21 --start */
  /**
   * Obtain bedCd based on bedGroupCd
   * @param bedGroupCd
   * @return
   */
  public List<Long> getBedCdListByGroupCd(String bedGroupCd){
    MstRoomBedGroup mrbg = mstRoomBedGroupDao.selectByRoomBedGroupCd(bedGroupCd);
    List<Long> bedCdList = new ArrayList<>();
    try {
      if(null != mrbg && StringUtils.hasText(mrbg.getBedList())){
        bedCdList.addAll(mapper.readValue(mrbg.getBedList(), new TypeReference<List<Long>>(){}));
      }
    } catch (tools.jackson.core.JacksonException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }
    return bedCdList;
  }
  /* add #8872 by zhangruixue 2023-06-21 --end */

  /**
   * 治療状況マップ：治療状況用データ取得
   */
  @Override
  public TreatmentStatusListResponse getTreatmentStatusMapMachine(String facilityCd, String treatDate,
      String layoutNo,String bedGroupCd) {
    // 治療中
    List<TreatmentStatusList> treatmentStatus = this.getTreatmentStatusListDcs(facilityCd);

    /* add #8872 by zhangruixue 2023-06-21 --start */
    if(StringUtils.hasText(bedGroupCd) && Long.parseLong(bedGroupCd) > 0L){
      List<Long> bedCdList = getBedCdListByGroupCd(bedGroupCd);
      if(!bedCdList.isEmpty()){
        //mod 9318 9554 ベッドグループを指定すると????患者が表示されない zhao start
        //treatmentStatus = treatmentStatus.stream().filter(item -> bedCdList.contains(item.getIndBedCd())).collect(Collectors.toList());
        treatmentStatus = treatmentStatus.stream().filter(item -> bedCdList.contains(item.getIndBedCd())||bedCdList.contains(item.getRstBedCd())).collect(Collectors.toList());
        //mod 9318 9554 ベッドグループを指定すると????患者が表示されない zhao end
      }
    }
    /* add #8872 by zhangruixue 2023-06-21 --end */

    /* modify by chamaojia 2024-10-24 [9312] add param 【functionCode】 --start */
    return makeTreatmentStatusList(facilityCd, treatDate, layoutNo, treatmentStatus, "");
    /* modify by chamaojia 2024-10-24 [9312] add param 【functionCode】 --end */
  }

  //add FNSI redmine 5461 劉祥霖 start
  /**
   * 日付ー１計算
   */
  public String DateCal(String treatDate)throws ParseException{
    SimpleDateFormat df = new SimpleDateFormat("yyyyMMdd");
    Date date = df.parse(treatDate);
    Calendar calendar = Calendar.getInstance();
    calendar.setTime(date);
    calendar.add(Calendar.DATE, -1);
    Date calDate=calendar.getTime();
    String calTreatDate=df.format(calDate);
    return calTreatDate;
  }

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
    if (0 < mstKur.size()) {
      for (int i = 0; i < mstKur.size(); i++) {
        // 次クール判定
        if (true == isCurrentKur) {
          // 次クールを返す
          targetKur = MstKurEx.parse(mstKur.get(i));
          break;
        }
        // 現在クール判定(最後のクールは除外)
        if ((i != mstKur.size()-1) && (currentKurCd == Long.parseLong(mstKur.get(i).getKurCd().toString()))) {
          isCurrentKur = true;
        }
      }
      // 次クールが見つからなかった場合は最初のクールを返す
      if (false == isCurrentKur) {
        targetKur = MstKurEx.parse(mstKur.get(0));
        targetKur.setIsFirstKur(true);
      }
    }

    return targetKur;
  }

  /**
   * ダミースケジュール登録情報リスト作成
   * @param ordNoList メインスケジュールのオーダ番号リスト
   * @param searchStartDate 検索開始日(形式:yyyyMMdd) ※nullの場合はメインスケジュールの治療日を使用
   * @param searchBedCd 検索ベッドコード ※nullの場合はメインスケジュールのベッドコードを使用
   * @param searchStartKurCd 検索開始クールコード ※nullの場合はメインスケジュールのクールコードを使用
   * @param cacheMstKur クールマスタ情報 ※nullの場合は内部で取得
   * @param isIncludeMain メインスケジュール含有フラグ(true:メインスケジュールを含む、false:メインスケジュールを含めない)
   * @return 正常終了:メインスケジュールごとのダミースケジュール登録情報リスト、異常終了:null
   */
  private LinkedHashMap<Long, List<DummyScheduleInfo>> createDummyScheduleInfoList(List<Long> ordNoList, String searchStartDate, Long searchBedCd, Long searchStartKurCd, List<MstKur> cacheMstKur, Boolean isIncludeMain) {
    // メインスケジュールの治療予定リスト取得
    List<OrdMain> retInfoList = ordMainDao.selectByOrdNoList(ordNoList);
    if (null == retInfoList) {
      String strMsg = "治療予定の取得に失敗しました(ord_no=" + ordNoList + ")";
      throw new RuntimeException(strMsg);
    }
    LinkedHashMap<Long, List<DummyScheduleInfo>> dummyInfoList = new LinkedHashMap<Long, List<DummyScheduleInfo>>();
    List<MstKur> mstKur = cacheMstKur;
    for (int i = 0; i < retInfoList.size(); i++) {
      // メインスケジュールの治療予定情報取得
      OrdMain retInfo = retInfoList.get(i);
      Long ordNo = retInfo.getOrdNo();
      String facilityCd = retInfo.getFacilityCd();
      String treatDate = retInfo.getTreatDate();
      if (null != searchStartDate) {
        treatDate = searchStartDate;
      }
      Long tmpKurCd = retInfo.getIndKurCd().longValue();
      if (null != searchStartKurCd) {
        tmpKurCd = searchStartKurCd;
      }
      Long indKurCd = tmpKurCd;
      Long patId = retInfo.getPatId();
      Long indBedCd = retInfo.getIndBedCd().longValue();
      if (null != searchBedCd) {
        indBedCd = searchBedCd;
      }

      // ベッドとクールが未登録でなければダミースケジュール登録情報リスト作成処理実施
      if ((0 != indKurCd) && (0 != indBedCd)) {
        Long treatTime = null;
        // 治療時間(指示:治療条件情報)設定
        // mod bug 6968 修正 chen start
        JSONObject indCondInfo = null == retInfo.getIndCondInfo() ?
          new JSONObject() :
          new JSONObject(retInfo.getIndCondInfo());
        // JSONObject indCondInfo= new JSONObject(retInfo.getIndCondInfo());
        // mod bug 6968 修正 chen end
        try {
          // add #9973 Resolve null exception for key 20240117 ztc start
          if (indCondInfo.has("1") && !indCondInfo.isNull("1")
                  && new JSONObject(indCondInfo.get("1").toString()).has("value") && !new JSONObject(indCondInfo.get("1").toString()).isNull("value")) {
            treatTime = Long.parseLong((new JSONObject(indCondInfo.get("1").toString()).get("value").toString()));
          }else{
            String strMsg = "クールマスタから対象治療予定(" +
                    "ord_no=" + ordNo +
                    ")のクール情報の取得に失敗しました(対象治療予定のクール(クールコード):" + indKurCd + ")";
            throw new RuntimeException(strMsg);
          }
          // add #9973 Resolve null exception for key 20240117 ztc end
        }
        catch(Exception e)
        {
          EventLogMessage eventLogMessage = new EventLogMessage();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          String strMsg = "対象治療予定(" +
            "ord_no=" + ordNo +
            ")の治療時間(指示:治療条件情報)の取得に失敗しました";
          throw new RuntimeException(strMsg);
        }

        // メインスケジュールの治療日、クール(クール内標準治療開始時刻)、治療時間から治療終了予定日時の日時を算出
        if (null == mstKur) {
          mstKur = mstKurDao.selectByFacilityCd(SelectOptions.get(), facilityCd, "0");
        }
        if (0 == mstKur.size()) {
          String strMsg = "クールマスタの取得に失敗しました(取得件数:" + mstKur.size() + ")";
          throw new RuntimeException(strMsg);
        }
        List<MstKur> currentKur = mstKur.stream().filter(info -> Long.parseLong(info.getKurCd().toString()) == indKurCd).collect(Collectors.toList());
        if (0 == currentKur.size()) {
          String strMsg = "クールマスタから対象治療予定(" +
            "ord_no=" + ordNo +
            ")のクール情報の取得に失敗しました(対象治療予定のクール(クールコード):" + indKurCd + ")";
          throw new RuntimeException(strMsg);
        }
        DateTimeFormatter dateFormat = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
        DateTimeFormatter dayFormat = DateTimeFormatter.ofPattern("yyyyMMdd");
        LocalDateTime treatStartDay = LocalDateTime.parse(treatDate + "000000", dateFormat);
        //mod FNSI redmine 6575 劉祥霖　start
        String startTime=treatDate + currentKur.get(0).getKurStandardStartTime();
        if(retInfo.getRstStartDate()!=null&&!retInfo.getRstStartDate().toString().equals("")){
          startTime=retInfo.getRstStartDate().toString();
          startTime=startTime.substring(0,19);
          startTime=startTime.replace(":","").replace(" ","").replace("-","");
        }
        LocalDateTime treatEndDate = LocalDateTime.parse(startTime, dateFormat).plusMinutes(treatTime);
        //mod FNSI redmine 6575 劉祥霖　end
        // ダミースケジュール登録情報リスト作成
        List<DummyScheduleInfo> dummyInfo = new ArrayList<DummyScheduleInfo>();
        // メインスケジュール含有フラグがtrueの場合、メインスケジュールをリストに含める
        if (true == isIncludeMain) {
          DummyScheduleInfo main = new DummyScheduleInfo();
          main.setFacilityCd(facilityCd);
          main.setTreatDate(treatDate);
          main.setKurCd(indKurCd);
          main.setTreatDatetime(treatDate + currentKur.get(0).getKurStandardStartTime());
          main.setPatId(patId);
          main.setBedCd(indBedCd);
          main.setIsDummy(false);
          dummyInfo.add(main);
        }
        LocalDateTime dummyDate = treatStartDay;
        Long dummyKur = indKurCd;
        // ダミースケジュールが治療終了予定日時を超えていなければ、ダミースケジュール登録情報リストに追加
        while (true == dummyDate.isBefore(treatEndDate)) {
          // 次クール情報取得
          MstKurEx nextKurInfo = this.calcNextKurInfo(mstKur, dummyKur);
          if (null == nextKurInfo) {
            String strMsg = "対象治療予定(" +
              "ord_no=" + ordNo +
              ")のダミースケジュール作成時にダミースケジュールのクールの取得に失敗しました(ダミースケジュールのクール(クールコード):" + dummyKur + ")";
            throw new RuntimeException(strMsg);
          } else {
            DummyScheduleInfo tmp = new DummyScheduleInfo();
            // 次クールの最初のクールフラグがtrueの場合は日付を翌日に更新
            if (true == nextKurInfo.getIsFirstKur()) {
              dummyDate = dummyDate.plusDays(1);
            }
            // ダミースケジュール更新(クールの期間すべてを含んでいるかをチェックするため、ダミースケジュールの時刻はクール終了時刻を設定)
            String dummyTreatDate = dummyDate.format(dayFormat);
            dummyDate = LocalDateTime.parse(dummyTreatDate + nextKurInfo.getKurEndTime(), dateFormat);
            dummyKur = nextKurInfo.getKurCd().longValue();
            // ダミースケジュールが治療終了予定日時を超えていなければ、ダミースケジュール登録情報リストに追加
            if (false == dummyDate.isBefore(treatEndDate)) break;
            tmp.setFacilityCd(facilityCd);
            tmp.setTreatDate(dummyTreatDate);
            tmp.setTreatWeek((short)(dummyDate.getDayOfWeek().getValue()));
            tmp.setKurCd(dummyKur);
            tmp.setTreatDatetime(dummyTreatDate + nextKurInfo.getKurStandardStartTime());
            tmp.setPatId(patId);
            tmp.setBedCd(indBedCd);
            tmp.setIsDummy(true);
            dummyInfo.add(tmp);
          }
        }
        // ダミースケジュールがあれば追加
        if (0 != dummyInfo.size()) dummyInfoList.put(ordNo, dummyInfo);
      } else {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("メインスケジュールが未確定(ベッド未登録またはクール未登録)のためダミースケジュール作成処理をスキップしました(ord_no=" + ordNo + "、pat_id=" + patId + "、treat_date=" + treatDate + "、ind_bed_cd=" + indBedCd + "、ind_kur_cd=" + indKurCd + ")");
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      }
    }

    return dummyInfoList;
  }
  //add FNSI redmine 5461 劉祥霖 end
  /**********************
   *  プライベートメソッド
   **********************/

  /**
   * 治療状況リスト・マップに表示する情報を取得する
   * @param facilityCd 施設コード
   * @return
   */
  private List<TreatmentStatusList> getTreatmentStatusListDcs(String facilityCd) {
    // 治療中
    List<TreatmentStatusList> treatmentStatus = this.selectAll(facilityCd);
    // 装置状態取得
    List<MntMachineState> machineState = this.machineSelectAllByFacilityCd(facilityCd);
    // 情報の追加登録
    machineState.forEach(item -> {
      // 透析装置判定＋ベッド登録割り付けチェック
      if ((Objects.equals(item.getModel(), MachineType.Model.DCS)
          || Objects.equals(item.getModel(), MachineType.Model.PERSONAL))
          && item.getBedCd() != null) {
        // 空きベッドを追加
        TreatmentStatusList item2 = new TreatmentStatusList();
        item2.setMachineEntry(-1);
        item2.setIndBedCd(item.getBedCd());
        treatmentStatus.add(item2);
      }
    });

    return treatmentStatus;
  }

  /**
   * 治療状況リスト情報を構築する。
   * @param facilityCd
   * @param treatDate
   * @param layoutNo
   * @param treatmentStatus
   * @param functionCode "1": 治療状況リスト -> 治療状況 "2":治療状況リスト -> 装置一覧
   *                     "3": 治療状況マップ -> 治療状況 "4":治療状況マップ -> スケジュール
   * @return
   */
  private TreatmentStatusListResponse makeTreatmentStatusList(
      String facilityCd,
      String treatDate,
      String layoutNo,
      List<TreatmentStatusList> treatmentStatus,
      /* modify by chamaojia 2024-10-24 [9312] add param 【functionCode】 --start */
      String functionCode) {
      /* modify by chamaojia 2024-10-24 [9312] add param 【functionCode】 --end */
    try {

      // レイアウト取得
      MstTreatmentStatusLayout mstTreatmentStatusLayout;
      TreatmentStatusLayoutViewItems[] dcsViewItems = {};
      TreatmentStatusLayoutViewItems[] dabViewItems = {};
      TreatmentStatusLayoutViewItems[] dadViewItems = {};
      TreatmentStatusLayoutViewItems[] droViewItems = {};
      if (StrUtils.isNumber(layoutNo) &&
          StrUtils.isNumber(treatDate) &&
          treatDate.length() == 8) {
        mstTreatmentStatusLayout = mstTreatmentStatusLayoutDao.selectByLayoutNo(Long.parseLong(layoutNo));
        if (mstTreatmentStatusLayout != null) {
          dcsViewItems = getLayoutViewItems(mstTreatmentStatusLayout.getDcsViewItems());
          dabViewItems = getLayoutViewItems(mstTreatmentStatusLayout.getDabViewItems());
          dadViewItems = getLayoutViewItems(mstTreatmentStatusLayout.getDadViewItems());
          droViewItems = getLayoutViewItems(mstTreatmentStatusLayout.getDroViewItems());
        } else {
          return new TreatmentStatusListResponse("レイアウト取得結果:Null");
        }
      } else {
        throw new IllegalArgumentException("[layoutNo] is not number");
      }

      // マシンステート取得
      List<MntMachineState> machineState = this.machineSelectAllByFacilityCd(facilityCd);

      // mod FNSI-改修内容5702修正 xuty start
      List<MntMachineFormat> machineState2 = this.machineSelectAllWithFormatByFacilityCd(facilityCd);
      // mod FNSI-改修内容5702修正 xuty end

      // 「sys_monitor_item」取得
      List<SysMonitorItem> sysMonitorItemList = sysMonitorItemDao.selectAll();


      //
      final String DRO = MachineType.Model.DRO;
      final String DAB = MachineType.Model.DAB;
      final String DAD = MachineType.Model.DAD;
      final String PERSONAL = MachineType.Model.PERSONAL;
      final String DCS = MachineType.Model.DCS;
      // mod FNSI-251 付 start
      final String DRYA = MachineType.Model.DRYA;
      final String DRYB = MachineType.Model.DRYB;
      // mod FNSI-251 付 end
      final String occurDate = new StringBuilder(treatDate).insert(6, "/").insert(4, "/").toString();
      // add #6488 黒系レイアウトの際に装置名が読みにくい dou start
      machineState = machineState.stream().filter(x -> null != x.getMachineSerial()).collect(Collectors.toList());
      // add #6488 黒系レイアウトの際に装置名が読みにくい dou end
      // 機種別データ取得
      final List<MntMachineState> dabList = machineState.stream()
        .filter(state -> state.getModel() != null ? state.getModel().equals(DAB) : false)
        .collect(Collectors.toList());
      //dabList.forEach(dat -> log.debug(dat.getMachineName()));
      // mod FNSI-251 付 start
//      final List<MntMachineState> dadList = machineState.stream()
//        .filter(state -> state.getModel() != null ? state.getModel().equals(DAD) : false)
//        .collect(Collectors.toList());
      final List<MntMachineState> dadList = machineState.stream()
        .filter(state -> state.getModel() != null ? state.getModel().equals(DAD) || state.getModel().equals(DRYA) || state.getModel().equals(DRYB): false)
        .collect(Collectors.toList());
      // add FNSI-改修内容5702修正 xuty start
      final List<MntMachineFormat> dadFormatList = machineState2.stream()
        .filter(state -> state.getModel() != null ? state.getModel().equals(DAD) || state.getModel().equals(DRYA) || state.getModel().equals(DRYB): false)
        // add #6488 黒系レイアウトの際に装置名が読みにくい dou start
        .filter(x -> x.getMachineSerial() != null)
        // add #6488 黒系レイアウトの際に装置名が読みにくい dou end
        .collect(Collectors.toList());
      // add FNSI-改修内容5702修正 xuty end
      //dadList.forEach(dat -> log.debug(dat.getMachineName()));
      // mod FNSI-251 付 end
      final List<MntMachineState> droList = machineState.stream()
        .filter(state -> state.getModel() != null ? state.getModel().equals(DRO) : false)
        .collect(Collectors.toList());
      //droList.forEach(dat -> log.debug(dat.getMachineName()));
      //mod FNSI redmine 5378 劉祥霖 start
//      final List<MntMachineState> bedList = machineState.stream()
//          .filter(state -> state.getModel() != null ? state.getModel().equals(DCS) || state.getModel().equals(PERSONAL)
//              : false)
//          .collect(Collectors.toList());
      final List<MntMachineState> bedList = machineState.stream()
        .filter(state -> state.getModel() != null)
        .collect(Collectors.toList());
      //mod FNSI redmine 5378 劉祥霖 end
      //bedList.forEach(dat -> log.debug(dat.getMachineName()));

      // 装置情報取得
      List<MstMachine> machineList = this.mstMachineDao.selectByFacility(facilityCd);
      // 装置マスタ並び順取得
      MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, "mst_machine");
      Map<Long, Long> selectorMap = Util.createSelectorMap(mstSelector);
      // machineList に装置マスタ並び順を設定
      machineList.forEach(m -> m.setMachineIndex(selectorMap.get(m.getMachineNo())));

      TreatmentStatusListResponse rtn = new TreatmentStatusListResponse();
      // 各機種データ設定
      /* modify by chamaojia 2024-10-24 [9312] add param 【functionCode】 --start */
      rtn.setDcs(makeDcsJsonText(sysMonitorItemList, facilityCd, dcsViewItems, treatmentStatus, bedList, machineList, functionCode));
      /* modify by chamaojia 2024-10-24 [9312] add param 【functionCode】 --end */
      // mod FNSI-改修内容5702修正 xuty start
      // rtn.setDab(makeMachineNotBedJsonText(sysMonitorItemList, dabViewItems, dabList, occurDate, "dab", machineList));
      // rtn.setDad(makeMachineNotBedJsonText(sysMonitorItemList, dadViewItems, dadList, occurDate, "dad", machineList));
      // rtn.setDro(makeMachineNotBedJsonText(sysMonitorItemList, droViewItems, droList, occurDate, "dro", machineList));
      //mod FNSI redmine 6946 劉祥霖 start リスト・マップ画面判定
      rtn.setDab(makeMachineNotBedJsonText(sysMonitorItemList, dabViewItems, dabList, null, occurDate, "dab", machineList,mstTreatmentStatusLayout.getUseClass()));
      rtn.setDad(makeMachineNotBedJsonText(sysMonitorItemList, dadViewItems, dadList, dadFormatList, occurDate, "dad", machineList,mstTreatmentStatusLayout.getUseClass()));
      rtn.setDro(makeMachineNotBedJsonText(sysMonitorItemList, droViewItems, droList, null, occurDate, "dro", machineList,mstTreatmentStatusLayout.getUseClass()));
      //mod FNSI redmine 6946 劉祥霖 end リスト・マップ画面判定
      // mod FNSI-改修内容5702修正 xuty end
      return rtn;

    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST request error by get makeTreatmentStatusList :" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_TREATMENT_RECORD, SERVICE_NAME.REMS, null);
      return new TreatmentStatusListResponse(e.getMessage());
    }
  }

  // add FNSI-入外区分取得 付 start
  /**
   * 患者個人情報のリストから患者ID指定で入外区分を取得する
   * @param patId 患者ID
   * @param patPersonalList 患者個人情報のリスト
   * @return 入外区分コード
   */
  private int getInOutClassById(Long patId, List<PatPersonalMain> patPersonalList) {
    int rtn = 0;
    for (int lop = 0; lop < patPersonalList.size(); lop++) {
      PatPersonalMain patPersonal = patPersonalList.get(lop);
      if (Objects.equals(patPersonal.getPat_id(), patId) && patPersonal.getIn_out_class() != null) {
        rtn = patPersonal.getIn_out_class();
      }
    }
    return rtn;
  }
  // add FNSI-入外区分取得 付 end
  // add #7862 2022-10-09 【デグレ】治療状況リスト，治療状況マップの表示が不正_再発 dou start
  /**
   * 日付＋１計算
   */
  public String dateAddOneDay(String treatDate) throws ParseException{
    SimpleDateFormat df = new SimpleDateFormat("yyyyMMdd");
    Date date = df.parse(treatDate);
    Calendar calendar = Calendar.getInstance();
    calendar.setTime(date);
    calendar.add(Calendar.DATE, 1);
    Date calDate=calendar.getTime();
    String calTreatDate=df.format(calDate);
    return calTreatDate;
  }
  // add #7862 2022-10-09 【デグレ】治療状況リスト，治療状況マップの表示が不正_再発 dou end

  private Map<String, Boolean> getNeedQueryItem(TreatmentStatusLayoutViewItems[] dcsItem) {
    // which discontinuous terms need to be analyzed for treatment conditions
    Integer[] needCondInfoItemCdArr = new Integer[]{6, 7, 9, 10, 11, 13, 14, 15, 39, 40, 52, 58};
    // content representation of treatment conditions required  true: need
    boolean needCondInfoFlag = false;
    boolean isCalcurationItem = false;
    boolean isNecessaryMstKur = false;
    boolean isNecessaryPatUnique = false;
    boolean isNecessaryMniMonitor = false;
    boolean isNecessaryLastAfterWeight = false;
    boolean isNecessaryPatEventCount = false;
    boolean needMntMachineStateFlag = false;
    Integer[] needMstEquipmentArr = new Integer[]{76, 77, 78, 79, 80, 81, 83};
    boolean needMstEquipmentFlag = false;
    boolean needMstDialyzerFlag = false;
    boolean needMstVaFlag = false;
    boolean needSelfDiagnosisFlag = false;
    boolean isNecessaryMstRoundType = false;
    for (TreatmentStatusLayoutViewItems dcsView : dcsItem) {
      Integer itemCd = dcsView.getDataClass();
      if (!needCondInfoFlag) {
        // 経過時間  (sys_monitor_item->1)
        if ("mni_monitor".equals(dcsView.getTableName())
                && "monitor_data".equals(dcsView.getColumnName())
                && "1".equals(dcsView.getKeyName())) {
          needCondInfoFlag = true;
        }
        // continuous numbering comparison
        if (itemCd >= 73 && itemCd <= 108) {
          needCondInfoFlag = true;
        }
        // discontinuous numbering comparison
        for (Integer needCondInfoItemCd : needCondInfoItemCdArr) {
          if (needCondInfoItemCd == itemCd) {
            needCondInfoFlag = true;
            break;
          }
        }
      }

      if (!isCalcurationItem && isCalcurationItem(itemCd)) {
        isCalcurationItem = true;
      }
      if (!isNecessaryMstKur && isNecessaryMstKur(itemCd)) {
        isNecessaryMstKur = true;
      }
      if (!isNecessaryPatUnique && isNecessaryPatUnique(itemCd)) {
        isNecessaryPatUnique = true;
      }
      if (!isNecessaryMniMonitor && isNecessaryMniMonitor(itemCd)) {
        isNecessaryMniMonitor = true;
      }
      if (!isNecessaryLastAfterWeight && isNecessaryLastAfterWeight(itemCd)) {
        isNecessaryLastAfterWeight = true;
      }
      if (!isNecessaryPatEventCount && itemCd == 65) {
        isNecessaryPatEventCount = true;
      }
      if (!needMntMachineStateFlag
              && ("mnt_machine_state".equals(dcsView.getTableName()) || isNecessaryMniMonitor(itemCd))) {
        needMntMachineStateFlag = true;
      }
      if (!needMstEquipmentFlag) {
        for (Integer needMstEquipment : needMstEquipmentArr) {
          if (needMstEquipment == itemCd) {
            needMstEquipmentFlag = true;
            break;
          }
        }
      }
      if (!needMstDialyzerFlag && itemCd == 75) {
        needMstDialyzerFlag = true;
      }
      if (!needMstVaFlag && itemCd == 73) {
        needMstVaFlag = true;
      }
      if (!needSelfDiagnosisFlag && itemCd == 110) {
        needSelfDiagnosisFlag = true;
      }
      if (!isNecessaryMstRoundType && isNecessaryMstRoundType(itemCd)) {
        isNecessaryMstRoundType = true;
      }
    }

    Map<String, Boolean> resultMap = new HashMap<>();
    resultMap.put("needCondInfoFlag", needCondInfoFlag);
    resultMap.put("isCalcurationItem", isCalcurationItem);
    resultMap.put("isNecessaryMstKur", isNecessaryMstKur);
    resultMap.put("isNecessaryPatUnique", isNecessaryPatUnique);
    resultMap.put("isNecessaryMniMonitor", isNecessaryMniMonitor);
    resultMap.put("isNecessaryLastAfterWeight", isNecessaryLastAfterWeight);
    resultMap.put("isNecessaryPatEventCount", isNecessaryPatEventCount);
    resultMap.put("needMntMachineStateFlag", needMntMachineStateFlag);
    resultMap.put("needMstEquipmentFlag", needMstEquipmentFlag);
    resultMap.put("needMstDialyzerFlag", needMstDialyzerFlag);
    resultMap.put("needMstVaFlag", needMstVaFlag);
    resultMap.put("needSelfDiagnosisFlag", needSelfDiagnosisFlag);
    resultMap.put("isNecessaryMstRoundType", isNecessaryMstRoundType);

    return resultMap;
  }

  private ArrayNode makeDcsJsonText(
      List<SysMonitorItem> sysMonitorItemList,
      String facilityCd,
      TreatmentStatusLayoutViewItems[] dcsViewItems,
      List<TreatmentStatusList> trearmentStatusList,
      List<MntMachineState> machineStateList,
      List<MstMachine> machineList,
      /* add by chamaojia 2024-10-24 [9312] add param 【functionCode】 --start */
      /**
       * "1": 治療状況リスト -> 治療状況 "2":治療状況リスト -> 装置一覧
       * "3": 治療状況マップ -> 治療状況 "4":治療状況マップ -> スケジュール
       */
      String functionCode
      /* add by chamaojia 2024-10-24 [9312] add param 【functionCode】 --end */
      ) {
    long startTime = System.currentTimeMillis();
    EventLogMessage eventLogMessageTemp = new EventLogMessage();

    eventLogMessageTemp.setLogMessage( "$$$$$$methodName-makeDcsJsonText start : " + (System.currentTimeMillis() - startTime));
    logService.log(LogLevel.INFO, eventLogMessageTemp, null, SERVICE_NAME.FNSI, null);

    ArrayNode dcsNode = mapper.createArrayNode();
    // mod #10773 治療状況レイアウトマスタにて透析装置の項目0件だと、治療状況マップのスケジュールで患者が表示しない。 ztc start
    boolean needCondInfoFlag = false;
    boolean isCalcurationItem = false;
    boolean isNecessaryMstKur = false;
    boolean isNecessaryPatUnique = false;
    boolean isNecessaryMniMonitor = false;
    boolean isNecessaryLastAfterWeight = false;
    boolean isNecessaryPatEventCount = false;
    boolean needMntMachineStateFlag = false;
    boolean needMstEquipmentFlag = false;
    boolean needMstDialyzerFlag = false;
    boolean needMstVaFlag = false;
    boolean needSelfDiagnosisFlag = false;
    boolean isNecessaryMstRoundType = false;
    TreatmentStatusLayoutViewItems[] dcsItem = null;
    if (dcsViewItems != null && dcsViewItems.length > 0 && trearmentStatusList.size() > 0) {
      dcsItem = dcsViewItems;
      // determine which tables are needed for querying
      Map<String, Boolean> needQueryTableMap = getNeedQueryItem(dcsItem);
      needCondInfoFlag = needQueryTableMap.get("needCondInfoFlag");
      isCalcurationItem = needQueryTableMap.get("isCalcurationItem");
      isNecessaryMstKur = needQueryTableMap.get("isNecessaryMstKur");
      isNecessaryPatUnique = needQueryTableMap.get("isNecessaryPatUnique");
      isNecessaryMniMonitor = needQueryTableMap.get("isNecessaryMniMonitor");
      isNecessaryLastAfterWeight = needQueryTableMap.get("isNecessaryLastAfterWeight");
      isNecessaryPatEventCount = needQueryTableMap.get("isNecessaryPatEventCount");
      needMntMachineStateFlag = needQueryTableMap.get("needMntMachineStateFlag");
      needMstEquipmentFlag = needQueryTableMap.get("needMstEquipmentFlag");
      needMstDialyzerFlag = needQueryTableMap.get("needMstDialyzerFlag");
      needMstVaFlag = needQueryTableMap.get("needMstVaFlag");
      needSelfDiagnosisFlag = needQueryTableMap.get("needSelfDiagnosisFlag");
      isNecessaryMstRoundType = needQueryTableMap.get("isNecessaryMstRoundType");
    }
    // mod #10773 治療状況レイアウトマスタにて透析装置の項目0件だと、治療状況マップのスケジュールで患者が表示しない。 ztc end

    // 施設設定マスタ 日付フォーマット取得
    String slmdfValue = facilitySettingService.getFacilitySettingValue(facilityCd, CoreConstant.FacilitySettingNo.STATUS_LIST_MAP_DATE_FORMAT);
    String dateFormat = "0".equals(slmdfValue) ? "yyyy/MM/dd HH:mm" : "HH:mm";
    // 日付時刻表示形式
    final SimpleDateFormat dispsdf = new SimpleDateFormat(dateFormat);

    // add FNSI-7217 事前に必要なコンテンツをご覧ください 查 start
    // 装置状態リスト取得
    List<MntMachineState> mntMachineStateList = null;
    if (needMntMachineStateFlag) {
      mntMachineStateList = mntMachineStateDao.selectMntMachineStateByFacilityCd(facilityCd);
    }
    eventLogMessageTemp.setLogMessage( "$$$$$$methodName-makeDcsJsonText 1.0 : " + (System.currentTimeMillis() - startTime));
    logService.log(LogLevel.INFO, eventLogMessageTemp, null, SERVICE_NAME.FNSI, null);
    // 装置記録コード
    // del #7862 2022-10-09 【デグレ】治療状況リスト，治療状況マップの表示が不正_再発 dou start
//    List<MtsMachineWithMachineRecordCd> mtsMachineWithMachineRecordCdList = treatmentStatusListDao.selectMntMotionRecordByFacilityCd(facilityCd);
    // del #7862 2022-10-09 【デグレ】治療状況リスト，治療状況マップの表示が不正_再発 dou end
    // add FNSI-7217 事前に必要なコンテンツをご覧ください 查 end

    // ベッド情報取得
    List<MstBed> bedList = this.mstBedDao.selectByFacilityCd(facilityCd, "1", "0");
    eventLogMessageTemp.setLogMessage( "$$$$$$methodName-makeDcsJsonText 1.0.1 : " + (System.currentTimeMillis() - startTime));
    logService.log(LogLevel.INFO, eventLogMessageTemp, null, SERVICE_NAME.FNSI, null);
    List<MstKur> kurList = mstKurDao.selectByFacilityCd(SelectOptions.get(), facilityCd, "0");
    eventLogMessageTemp.setLogMessage( "$$$$$$methodName-makeDcsJsonText 1.0.2 : " + (System.currentTimeMillis() - startTime));
    logService.log(LogLevel.INFO, eventLogMessageTemp, null, SERVICE_NAME.FNSI, null);
    // add FNSI-項目表示制御の修正 徐 start
    // 治療方法の取得
    SelectOptions selectOptions = SelectOptions.get();
    MstTreatment params = new MstTreatment();
    params.setFacilityCd(facilityCd);
    List<MstTreatment> mstTreatmentList = mstTreatmentDao.selectAll(selectOptions, params);
    // add FNSI-項目表示制御の修正 徐 end
    eventLogMessageTemp.setLogMessage( "$$$$$$methodName-makeDcsJsonText 1.1 : " + (System.currentTimeMillis() - startTime));
    logService.log(LogLevel.INFO, eventLogMessageTemp, null, SERVICE_NAME.FNSI, null);

    // 治療状況データ分の患者個人情報をあらかじめ取得
    List<Long> patIds = trearmentStatusList.stream()
        .filter(o -> !Objects.isNull(o) && !Objects.isNull(o.getPatId()))
        .map(o -> o.getPatId())
        .distinct()
        .collect(Collectors.toList());
    List<PatMain> patList = new ArrayList<>();
    List<PatPersonalMain> patPersonalList = new ArrayList<>();
    List<PatUnique> patUniqueList = new ArrayList<>();
    if (patIds.size() > 0) {
      patList = patMainDao.selectByIdListFacilityCdToTreatmentStatus(patIds, facilityCd);
      eventLogMessageTemp.setLogMessage( "$$$$$$methodName-makeDcsJsonText 1.1.0 : " + (System.currentTimeMillis() - startTime));
      logService.log(LogLevel.INFO, eventLogMessageTemp, null, SERVICE_NAME.FNSI, null);
      patPersonalList = patPersonalMainDao.selectByIdListFacilityCdToTreatmentStatus(patIds, facilityCd);
      eventLogMessageTemp.setLogMessage( "$$$$$$methodName-makeDcsJsonText 1.1.1 : " + (System.currentTimeMillis() - startTime));
      logService.log(LogLevel.INFO, eventLogMessageTemp, null, SERVICE_NAME.FNSI, null);
      if (isNecessaryPatUnique) {
        patUniqueList = patUniqueDao.selectByIdListToTreatmentStatus(patIds);
        eventLogMessageTemp.setLogMessage( "$$$$$$methodName-makeDcsJsonText 1.1.2 : " + (System.currentTimeMillis() - startTime));
        logService.log(LogLevel.INFO, eventLogMessageTemp, null, SERVICE_NAME.FNSI, null);
      }
    }

    //mod 性能改善一応対応 劉 start
    List<Long> ordNos = trearmentStatusList.stream()
      .map(TreatmentStatusList::getOrdNo)
      .filter(Objects::nonNull)
      .distinct()
      .collect(Collectors.toList());

//      List<MniMonitor> mniMonitorDataType1ListAll = null;
//    List<MniMonitor> mniMonitorList = null;
    List<RoughMonitorData> roughMonitorData = null;
    if (isNecessaryMniMonitor) {
//        mniMonitorDataType1ListAll = mniMonitorDao.selectByOrdNoDataType(ordNos,
//                (short) 2,facilityCd);
      // FNSI-修正、#7217、SQLに問題があり非常に高負荷、xugj mod start
      // オーダー番号から最新のモニタデータ取得
//      mniMonitorList = mniMonitorDao.selectNewestOrdNoAllDataType(ordNos, facilityCd);
      // FNSI-修正、#7217、SQLに問題があり非常に高負荷、xugj mod end

      // #9312 追加治療・装置画面判定

      // #9312 mod By Z.T. Start
//      mniMonitorList = mniMonitorDao.selectNewestOrdNoAllDataType(ordNos, facilityCd);  // リスト
//      mniMonitorList = this.assenbleMniDatasByOrdNos(facilityCd, ordNos);
      roughMonitorData = this.assenbleMniDatasByOrdNos(facilityCd, ordNos);
      // #9312 mod By Z.T. End

      eventLogMessageTemp.setLogMessage( "$$$$$$methodName-makeDcsJsonText 1.1.4 : " + (System.currentTimeMillis() - startTime));
      logService.log(LogLevel.INFO, eventLogMessageTemp, null, SERVICE_NAME.FNSI, null);
    }

//      List<OrdMain> ordMains = ordMainDao.selectAllByOrdNoList(ordNos);
    eventLogMessageTemp.setLogMessage( "$$$$$$methodName-makeDcsJsonText 1.1.5 : " + (System.currentTimeMillis() - startTime));
    logService.log(LogLevel.INFO, eventLogMessageTemp, null, SERVICE_NAME.FNSI, null);

    List<NumberOfUserTypeByOrdNo> countUserTypeList = null;
    if (isNecessaryPatEventCount) {
      countUserTypeList = patEventDao.selectCountByOrdNoUseType(ordNos, (short) 2, facilityCd);
      eventLogMessageTemp.setLogMessage( "$$$$$$methodName-makeDcsJsonText 1.1.6 : " + (System.currentTimeMillis() - startTime));
      logService.log(LogLevel.INFO, eventLogMessageTemp, null, SERVICE_NAME.FNSI, null);
    }
    // 種別リスト取得
    List<MstRoundType> mstRoundTypeList = null;
    if (isNecessaryMstRoundType) {
      mstRoundTypeList = mstRoundTypeDao.selectByFacilityCd(facilityCd);
    }
//      List<Long> bioNos = new ArrayList<>();
    // add #6746 データの事前照会、パフォーマンスの向上 查 start
    Set<Integer> equipCds = new HashSet<>();
    Set<Integer> dialyzerCds = new HashSet<>();
    Set<Integer> vaCds = new HashSet<>();
    short[] condInfoItemKeyArr = new short[]{6, 7, 8, 9, 10, 11, 13};
    Map<String, CondInfo> indCondInfoMap = new HashMap<>();
    Map<String, CondInfo> rstCondInfoMap = new HashMap<>();
    List<String> treatDateList = new ArrayList<>(trearmentStatusList.size());
    //mnt_motion_record machineTypeCd
    List<String> recordMachineTypeCdList = new ArrayList<>();
    //mnt_motion_record machineSerial
    List<String> recordMachineSerialList = new ArrayList<>();

    // add #6746 データの事前照会、パフォーマンスの向上 查 end

    List<MtsMachineWithMachineRecordCd> queryMotionRecordCondList = new ArrayList<>();
    for (TreatmentStatusList ord : trearmentStatusList) {
//        // 体重情報取得
//        String info = ord.getRstWeightInfo();
//        if (info != null) {
//          // 再循環率参照先の管理番号取得
//          String strBioNo = this.getJsonNodeValue(info, "re_loop_rate_main");
//          if (StrUtils.isNumber(strBioNo)) {
//            bioNos.add(Long.parseLong(strBioNo));
//          }
//        }

      // add #6746 データの事前照会、パフォーマンスの向上 查 start
      if (ord.getOrdNo() != null) {
        /* modify by chamaojia 2022-10-11 [6746] NULL値判定の追加 --start */
        // 治療条件情報取得
        if (needCondInfoFlag) {
          if (!StringUtils.isEmpty(ord.getRstCondInfo()) && !"0".equals(ord.getRstDialysisState())) {
            CondInfo rstCondInfo = condInfoService.createCondInfo(ord.getRstCondInfo());
            if (!rstCondInfoMap.containsKey(ord.getRstCondInfo())) {
              rstCondInfoMap.put(ord.getRstCondInfo(), rstCondInfo);
            }
          }
          if (!StringUtils.isEmpty(ord.getIndCondInfo()) && "0".equals(ord.getRstDialysisState())) {
            CondInfo indCondInfo = condInfoService.createCondInfo(ord.getIndCondInfo());
            if (!indCondInfoMap.containsKey(ord.getIndCondInfo())) {
              indCondInfoMap.put(ord.getIndCondInfo(), indCondInfo);
            }

            for (short condInfoItemKey : condInfoItemKeyArr) {
              String itemValue = indCondInfo.getItem(condInfoItemKey).getValue();
              if (!StringUtils.isEmpty(itemValue) && StrUtils.isNumber(itemValue)) {
                equipCds.add(Integer.parseInt(itemValue));
              }
            }

            String dialyzerCd = indCondInfo.getDialyzer().getValue();
            if (!StringUtils.isEmpty(dialyzerCd) && StrUtils.isNumber(dialyzerCd)) {
              dialyzerCds.add(Integer.parseInt(dialyzerCd));
            }

            String vaCd = indCondInfo.getVa().getValue();
            if (!StringUtils.isEmpty(vaCd) && StrUtils.isNumber(vaCd)) {
              vaCds.add(Integer.parseInt(vaCd));
            }
          }
        }
        /* modify by chamaojia 2022-10-11 [6746] NULL値判定の追加 --end */
      }

      if (needSelfDiagnosisFlag) {
        Long bedCd = null;
        if (ord.getRstDialysisState() == null || ord.getRstDialysisState().isEmpty() || ord.getRstDialysisState().equals("0")) {
          bedCd = ord.getIndBedCd();
        } else {
          bedCd = ord.getRstBedCd();
        }
        if (bedCd != null && bedCd > 0 && StringUtils.hasText(ord.getTreatDate())) {
          Long tempBedCd = bedCd;
          MstBed bedInfo = bedList.stream().filter(state -> Objects.equals(state.getBedCd(), tempBedCd)).findFirst().orElse(null);
          if (bedInfo != null) {
            // 装置情報
            MstMachine machineInfo = machineList.stream().filter(state -> Objects.equals(state.getMachineNo(), bedInfo.getMachineNo())).findFirst().orElse(null);
            if (machineInfo != null) {
              if(StringUtils.hasText(machineInfo.getMachineTypeCd()) && StringUtils.hasText(machineInfo.getMachineSerial())){
                MtsMachineWithMachineRecordCd entity = new MtsMachineWithMachineRecordCd();
                entity.setMachineSerial(machineInfo.getMachineSerial());
                entity.setMachineTypeCd(machineInfo.getMachineTypeCd());
                entity.setTreatDate(ord.getTreatDate());
                queryMotionRecordCondList.add(entity);
              }
            }
          }
        }
      }
      /* modify #6746 zhangruixue 2023-03-08 治療状況リスト、治療状況マップを開くのが遅い --end */
    }
    eventLogMessageTemp.setLogMessage( "$$$$$$methodName-makeDcsJsonText 1.1.7 : " + (System.currentTimeMillis() - startTime));
    logService.log(LogLevel.INFO, eventLogMessageTemp, null, SERVICE_NAME.FNSI, null);

    Map<Integer, String> mstEquipmentMap = new HashMap<>();
    if (needMstEquipmentFlag) {
      List<MstEquipment> mstEquipments = mstEquipmentDao.selectByCdList(SelectOptions.get(), new ArrayList<>(equipCds));
      mstEquipmentMap = mstEquipments.stream().collect(Collectors.toMap(MstEquipment::getEquipmentCd, MstEquipment::getEquipmentName));
      eventLogMessageTemp.setLogMessage( "$$$$$$methodName-makeDcsJsonText 1.1.8 : " + (System.currentTimeMillis() - startTime));
      logService.log(LogLevel.INFO, eventLogMessageTemp, null, SERVICE_NAME.FNSI, null);
    }

    Map<Integer, MstDialyzer> mstDialyzerMap = new HashMap<>();
    if (needMstDialyzerFlag) {
      List<MstDialyzer> mstDialyzers = mstDialyzerDao.selectAllByCdList(SelectOptions.get(), new ArrayList<>(dialyzerCds));
      mstDialyzerMap = mstDialyzers.stream().collect(Collectors.toMap(MstDialyzer::getDialyzerCd, Function.identity()));
      eventLogMessageTemp.setLogMessage( "$$$$$$methodName-makeDcsJsonText 1.1.9 : " + (System.currentTimeMillis() - startTime));
      logService.log(LogLevel.INFO, eventLogMessageTemp, null, SERVICE_NAME.FNSI, null);
    }

    Map<Integer, String> mstVaMap = new HashMap<>();
    if (needMstVaFlag) {
      List<MstVa> mstVas = mstVaDao.selectAllByCds(new ArrayList<>(vaCds));
      mstVaMap = mstVas.stream().collect(Collectors.toMap(MstVa::getVaCd, MstVa::getVaName));
      eventLogMessageTemp.setLogMessage( "$$$$$$methodName-makeDcsJsonText 1.1.10 : " + (System.currentTimeMillis() - startTime));
      logService.log(LogLevel.INFO, eventLogMessageTemp, null, SERVICE_NAME.FNSI, null);
    }
    // add #6746 データの事前照会、パフォーマンスの向上 查 end

    // 使用する各マスタの並び順を取得
    List<MstSelector> mstSelector = mstSelectorDao.selectByNameList(facilityCd, Arrays.asList(
      "mst_round_type", // 回診記録マスタ
      "mst_va",         // VAマスタ
      "mst_dialyzer",   // ダイアライザマスタ
      "mst_equipment",  // 医材マスタ
      "mst_medicine",   // 薬剤マスタ
      "mst_medicine_mix"// 調整薬剤マスタ
    ));

    // モニタ情報取得
    /* delete by chamaojia 2024-03-28 [10303、10304] no usage location found --start */
//      List<MniMonitor> mons = mniMonitorDao.selectByBioMoniCtlNo(bioNos);
    /* delete by chamaojia 2024-03-28 [10303、10304] no usage location found --end */
    //mod 性能改善一応対応 劉 end
    /* modify #6746 zhangruixue 2023-02-24 治療状況リスト、治療状況マップを開くのが遅い --start */
    Map<String,SysMonitorItem> sysMonitorItemMap =  sysMonitorItemList.stream().collect(Collectors.toMap(SysMonitorItem::getMoniDataNo, Function.identity()));

    Map<String,String> machineRecordCdInfoMap = new HashMap<>();
    if(needSelfDiagnosisFlag && queryMotionRecordCondList.size() > 0){

      List<MtsMachineWithMachineRecordCd> mtsMachineWithMachineRecordCdAndRegDateList
              = treatmentStatusListDao.selectMntMotionRecordByFacilityCdAndRegDate(facilityCd, queryMotionRecordCondList);
      if(mtsMachineWithMachineRecordCdAndRegDateList.size() > 0){
        for(MtsMachineWithMachineRecordCd recordCd : mtsMachineWithMachineRecordCdAndRegDateList){
          StringBuffer keyString = new StringBuffer("");
          keyString.append(recordCd.getMachineTypeCd());
          keyString.append("-");
          keyString.append(recordCd.getMachineSerial());
          keyString.append("-");
          keyString.append(recordCd.getTreatDate());
          machineRecordCdInfoMap.put(keyString.toString(),recordCd.getMachineRecordCd());
        }
      }
    }
    eventLogMessageTemp.setLogMessage( "$$$$$$methodName-makeDcsJsonText 1.1.11 : " + (System.currentTimeMillis() - startTime));
    logService.log(LogLevel.INFO, eventLogMessageTemp, null, SERVICE_NAME.FNSI, null);

    /* modify #6746 zhangruixue 2023-02-24 治療状況リスト、治療状況マップを開くのが遅い --end */

    /* add by chamaojia 2023-06-16 [8637] データ早期一括クエリ --start */
    List<TreatmentStatusList> lastRstWeightList = null;
    if (isNecessaryLastAfterWeight) {
      List<TreatmentStatusList> queryLastRstWeightList = trearmentStatusList.stream().filter(m -> !Objects.isNull(m.getOrdNo()) && !Objects.isNull(m.getPatId())).collect(Collectors.toList());
      if (queryLastRstWeightList != null && queryLastRstWeightList.size() > 0) {
        lastRstWeightList = ordMainDao.selectLastRstWeightByList(queryLastRstWeightList);
      }
    }
    /* add by chamaojia 2023-06-16 [8637] データ早期一括クエリ --end */

    eventLogMessageTemp.setLogMessage( "$$$$$$methodName-makeDcsJsonText 1.2 : " + (System.currentTimeMillis() - startTime));
    logService.log(LogLevel.INFO, eventLogMessageTemp, null, SERVICE_NAME.FNSI, null);
    eventLogMessageTemp.setLogMessage( "$$$$$$methodName-makeDcsJsonText trearmentStatusList length : " + (trearmentStatusList != null ? trearmentStatusList.size() : 0));
    logService.log(LogLevel.INFO, eventLogMessageTemp, null, SERVICE_NAME.FNSI, null);
    long timeRecordO = 0L;
    long timeRecordT = 0L;
    // 治療状況データ分
    for (TreatmentStatusList ord : trearmentStatusList) {
      Map<String, JsonNode> jsonNodeMap = new HashMap<>();
      ObjectNode ordNode = mapper.createObjectNode();
      Integer itemCd = null;
      String rstDialysisState = ord.getRstDialysisState();
      try {
        boolean isOffline = false;

        // 固定項目の設定
        ordNode.put("machineEntry", ord.getMachineEntry());
        ordNode.put("ordNo", ord.getOrdNo());
        ordNode.put("treatDate", ord.getOrdNo() != null ? ord.getTreatDate() : "");
        ordNode.put("patId", ord.getPatId());
        ordNode.put("indScheduleUserInfo", ord.getIndScheduleUserInfo());
        ordNode.put("rstEdition", ord.getRstEdition());
        ordNode.put("rstDialysisState", rstDialysisState);
        ordNode.put("patName", "");
        ordNode.put("patFirstName", "");
        ordNode.put("patLastName", "");
        ordNode.put("patFirstNameKana", "");
        ordNode.put("patLastNameKana", "");
        ordNode.put("hospPatId", "");
        if (Objects.isNull(ord.getIsContentChangedForMap())) {
          ordNode.put("IsContentChanged", FlagType.FLAG_OFF);
        } else {
          ordNode.put("IsContentChanged", ord.getIsContentChangedForMap());
        }
        if ("0".equals(rstDialysisState)) {
          ordNode.put("IsContentChanged", "2");
        }

        String isSame = "";
        if (ord.getPatId() != null) {
          Long patId = ord.getPatId();

          // 患者個人名の取得
          PatPersonalMain pat = patPersonalList.stream()
              .filter(o -> Objects.equals(o.getPat_id(), patId))
              .findFirst()
              .orElse(null);
          if (pat != null) {
            String patLastName = pat.getPat_last_name() == null?"":pat.getPat_last_name();
            String patFirstName =  pat.getPat_first_name() == null?"":pat.getPat_first_name();
            ordNode.put("patName", patLastName + patFirstName);
            //ordNode.put("patName", pat.getPat_last_name() + pat.getPat_first_name());
            ordNode.put("patFirstName", pat.getPat_first_name());
            ordNode.put("patLastName", pat.getPat_last_name());
            ordNode.put("patFirstNameKana", pat.getPat_first_name_kana());
            ordNode.put("patLastNameKana", pat.getPat_last_name_kana());
            ordNode.put("hospPatId", pat.getHosp_pat_id());
            PatMain patMain = patList.stream()
                .filter(o -> Objects.equals(o.getPat_id(), patId))
                .findFirst()
                .orElse(null);
            if (patMain != null) {
              isSame = patMain.getIs_same();
            }
          }
        }
        ordNode.put("isSame", isSame);

        // add FNSI-入外区分取得 付 start
        // 入外区分取得
        Long patId = ord.getPatId();
        int inOutClass = this.getInOutClassById(patId, patPersonalList);
        ordNode.put("inOutClass", inOutClass);
        // add FNSI-入外区分取得 付 end

        // 透析予定時間
        if (rstDialysisState == null ||
                rstDialysisState.isEmpty() ||
                rstDialysisState.equals("0")) {
          // 予定
          String indCondInfo = ord.getIndCondInfo();
          if (null != indCondInfo) {
            String condTimeText = this.getJsonNodeValue(indCondInfo, "1,value", jsonNodeMap);
            if (StrUtils.isNumber(condTimeText)) {
              ordNode.put("condTime", Long.parseLong(condTimeText));
            } else {
              ordNode.put("condTime", 0);
            }
          }
        } else {
          // 実績
          String rstCondInfo = ord.getRstCondInfo();
          if (null != rstCondInfo) {
            String condTimeText = this.getJsonNodeValue(rstCondInfo, "1,value", jsonNodeMap);
            if (StrUtils.isNumber(condTimeText)) {
              ordNode.put("condTime", Long.parseLong(condTimeText));
            } else {
              ordNode.put("condTime", 0);
            }
          }
        }
        // 治療方法
        Integer treatDeviceMode;
        if (rstDialysisState == null ||
                rstDialysisState.isEmpty() ||
                rstDialysisState.equals("0")) {
          // 予定
          treatDeviceMode = ord.getIndTreatmentDeviceMode() == null ? -1 : ord.getIndTreatmentDeviceMode();
        } else {
          // 実績
          treatDeviceMode = ord.getRstTreatmentDeviceMode() == null ? -1 : ord.getRstTreatmentDeviceMode();
        }
        ordNode.put("treatDeviceMode", treatDeviceMode);

        // ベッド情報
        Long targetBedCd = null;
        if (rstDialysisState == null ||
                rstDialysisState.isEmpty() ||
                rstDialysisState.equals("0")) {
          // 予定
          ordNode.put("bedCd", ord.getIndBedCd());
          ordNode.put("bedName", ord.getIndMstBedName());
          ordNode.put("kurCd", ord.getIndKurCd());
          ordNode.put("kurName", ord.getIndMstKurName());
          //add FNSI redmine 5461 劉祥霖 start
          ordNode.put("isDummy", ord.getIsDummy());
          //add FNSI redmine 5461 劉祥霖 end
          targetBedCd = ord.getIndBedCd();
        } else {
          // 実績
          ordNode.put("bedCd", ord.getRstBedCd());
          ordNode.put("bedName", ord.getRstBedName());
          ordNode.put("kurCd", ord.getRstKurCd());
          ordNode.put("kurName", ord.getRstKurName());
          //add FNSI redmine 5461 劉祥霖 start
          ordNode.put("isDummy", ord.getIsDummy());
          //add FNSI redmine 5461 劉祥霖 end
          // 実績：透析運転時間  ※※※ 透析運転時間は透析終了(排液時)に更新されるので注意 ※※※
          Integer rstRunningTime = ord.getRstRunningTime();
          ordNode.put("rstRunningTime", null != rstRunningTime ? rstRunningTime : 0);

          // timestamp.toString()で、yyyy-mm-dd hh:mm:ss.fffffffff形式になる。
          ordNode.put("condSendDate", ord.getRstCondSendDate() != null ? ord.getRstCondSendDate().toString() : "");
          ordNode.put("startDate", ord.getRstStartDate() != null ? ord.getRstStartDate().toString() : "");
          ordNode.put("endDate", ord.getRstEndDate() != null ? ord.getRstEndDate().toString() : "");
          targetBedCd = ord.getRstBedCd();
        }

        final Long bedCd = targetBedCd;
        // モニタデータ取得用
        MntMachineState machineMonitorData = null;

        // ベッド情報(ベッド表示順)
        if (bedCd != null && bedCd > 0) {
          MstBed bed = bedList.stream()
              .filter(state -> Objects.equals(state.getBedCd(), bedCd))
              .findFirst()
              .orElse(null);
          if (bed != null) {
            ordNode.put("bedIndex", bedList.indexOf(bed));
            if (ordNode.get("bedName").isNull()) {
              ordNode.put("bedName", bed.getBedName());
            }

            // 装置情報
            MstMachine machine = machineList.stream()
                .filter(state -> Objects.equals(state.getMachineNo(), bed.getMachineNo()))
                .findFirst()
                .orElse(null);
            if (machine != null) {
              //add FNSI redmine 5984 劉祥霖　start
              ordNode.put("machineNo", machine.getMachineNo());
              //add FNSI redmine 5984 劉祥霖　end
              ordNode.put("machineTypeCd", machine.getMachineTypeCd());
              ordNode.put("machineSerial", machine.getMachineSerial());
              // add FNSI-装置自己診断の追加 徐 start

              // mod FNSI-7217 リアルタイムクエリを事前クエリに変更して抽出 查 start
              // 装置記録コード
//                String machineRecordCd = treatmentStatusListDao.selectMntMotionRecord(machine.getFacilityCd(),
//                            machine.getMachineTypeCd(), machine.getMachineSerial());
//                ordNode.put("machineRecordCd", machineRecordCd);
              // mod #7862 2022-10-09 【デグレ】治療状況リスト，治療状況マップの表示が不正_再発 dou start
//                MtsMachineWithMachineRecordCd mtsMachineWithMachineRecordCd = mtsMachineWithMachineRecordCdList.stream().filter(m -> Objects.equals(m.getMachineTypeCd(), machine.getMachineTypeCd())
//                  && Objects.equals(m.getMachineSerial(), machine.getMachineSerial())).findFirst().orElse(null);
              String beginDate = ord.getTreatDate();
              /* modify #6746 zhangruixue 2023-02-21 治療状況リスト、治療状況マップを開くのが遅い --start */
//                String endDate = ord.getTreatDate();
//                List<MtsMachineWithMachineRecordCd> mtsMachineWithMachineRecordCdList = new ArrayList<>();
              String machineRecordCd = null;
              if (!StringUtils.isEmpty(beginDate)) {
//                  endDate = dateAddOneDay(beginDate);
//                  mtsMachineWithMachineRecordCdList = treatmentStatusListDao.selectMntMotionRecordByFacilityCd(facilityCd, machine.getMachineTypeCd(), machine.getMachineSerial(), beginDate, endDate);
                StringBuffer keyString = new StringBuffer();
                keyString.append(machine.getMachineTypeCd());
                keyString.append("-");
                keyString.append(machine.getMachineSerial());
                keyString.append("-");
                keyString.append(beginDate);
                if(!machineRecordCdInfoMap.isEmpty() && StringUtils.hasText(machineRecordCdInfoMap.get(keyString.toString()))){
                  machineRecordCd = machineRecordCdInfoMap.get(keyString.toString());
                }
              }
              ordNode.put("machineRecordCd", machineRecordCd);
//                MtsMachineWithMachineRecordCd mtsMachineWithMachineRecordCd = mtsMachineWithMachineRecordCdList.stream().findFirst().orElse(null);
              // mod #7862 2022-10-09 【デグレ】治療状況リスト，治療状況マップの表示が不正_再発 dou end
//                ordNode.put("machineRecordCd", mtsMachineWithMachineRecordCd == null ? null : mtsMachineWithMachineRecordCd.getMachineRecordCd());
              /* modify #6746 zhangruixue 2023-02-21  --end */
              // mod FNSI-7217 リアルタイムクエリを事前クエリに変更して抽出 查 end

              // add FNSI-装置自己診断の追加 徐 end
              // オフライン判定
              if (machine.getComType().equals(0) && ("F").equals(machine.getComFormatCd())) {
                isOffline = true;
                ordNode.put("isOffline", 1);
              }

              // 機種判定
              MntMachineState machineState = machineStateList.stream()
                      .filter(state -> Objects.equals(state.getMachineSerial(), machine.getMachineSerial())
                              && Objects.equals(state.getMachineTypeCd(), machine.getMachineTypeCd()))
                      .findFirst()
                      .orElse(null);
              if (machineState != null) {
                ordNode.put("model", machineState.getModel() == null ? "" : machineState.getModel());
              }
              // mnt_machine_state からモニタデータ取得
              machineMonitorData = machineStateList.stream()
                      .filter(state -> Objects.equals(state.getMachineSerial(), machine.getMachineSerial())
                              && Objects.equals(state.getMachineTypeCd(), machine.getMachineTypeCd())
                              && !Objects.isNull(state.getOrdNo()) && Objects.equals(state.getOrdNo(), ord.getOrdNo()))
                      .findFirst()
                      .orElse(null);
            }
          }
        }
        // 治療中判定
        MntMachineState machine = machineStateList.stream()
            .filter(state -> Objects.equals(state.getOrdNo(), ord.getOrdNo()))
            .findFirst()
            .orElse(null);
        if (machine != null && ord.getMachineEntry() != null && ord.getMachineEntry() == 2) {
          // 装置状態にエントリーされている現患者
          ordNode.put("isPreventiveMainte", machine.getIsPreventiveMainte());
          ordNode.put("processState", machine.getProcessState());
          ordNode.put("machineStatus", machine.getMachineStatus());
          ordNode.put("machineOrdNo", machine.getOrdNo());
          ordNode.put("machineNextOrdNo", machine.getNextOrdNo());
        } else {
          machine = machineStateList.stream()
              .filter(state -> Objects.equals(state.getNextOrdNo(), ord.getOrdNo()))
              .findFirst()
              .orElse(null);
          if (machine != null && ord.getMachineEntry() != null && ord.getMachineEntry() == 1) {
            // 装置状態にエントリーされている次患者
            ordNode.put("isPreventiveMainte", machine.getIsPreventiveMainte());
            ordNode.put("processState", machine.getProcessState());
            ordNode.put("machineStatus", machine.getMachineStatus());
            ordNode.put("machineOrdNo", machine.getOrdNo());
            ordNode.put("machineNextOrdNo", machine.getNextOrdNo());
          } else if (bedCd != null && bedCd > 0) {
            machine = machineStateList.stream()
                .filter(state -> Objects.equals(state.getBedCd(), bedCd))
                .findFirst()
                .orElse(null);
            if (machine != null) {
              // スケジュール未割当ベッド・治療終了患者
              ordNode.put("isPreventiveMainte", machine.getIsPreventiveMainte());
              ordNode.put("processState", machine.getProcessState());
              ordNode.put("machineStatus", machine.getMachineStatus());
              ordNode.put("machineOrdNo", machine.getOrdNo());
              ordNode.put("machineNextOrdNo", machine.getNextOrdNo());
            }
          }
        }
        final String MNI_MONITOR = "mni_monitor";
        final String MNT_MACHINE_STATE = "mnt_machine_state";
        final String ORD_MAIN = "ord_main";

        // 算出値などテーブル名・フィールド名・JSONキー名指定で値を取得できない項目の場合

        //  /**
        //   *  FNSI  治療記録 -- modify by WP  20210318
        //   */
        StatusListDTO dto = new StatusListDTO();

        // ord_noがある情報が対象
        // DTOにオーダー情報をセット
        dto.initValue();
        dto.setOrd(ord);
        dto.setCondInfoService(condInfoService);
        dto.setOffline(isOffline);
        //add FNSI 治療状況リストエラーの対応 xiebzh start
        dto.setLogEventUtils(logUtils);
        //add FNSI 治療状況リストエラーの対応 xiebzh end
        // add #6746 データの事前照会、パフォーマンスの向上 查 start
        dto.setIndCondInfoMap(indCondInfoMap);
        dto.setRstCondInfoMap(rstCondInfoMap);
        dto.setMstEquipmentMap(mstEquipmentMap);
        dto.setMstDialyzerMap(mstDialyzerMap);
        dto.setMstVaMap(mstVaMap);
        // add #6746 データの事前照会、パフォーマンスの向上 查 end
        dto.setJsonNodeMap(jsonNodeMap);
        dto.setMstSelectors(mstSelector);
        // レイアウトされた項目により必要な情報の収集
        // dcsItemの数だけ、データ内に項目がある
        long tempStartTimeO = System.currentTimeMillis();
//          for (TreatmentStatusLayoutViewItems dcsView : dcsItem) {
//            itemCd = dcsView.getDataClass();

          if (isCalcurationItem) {

            // mst_kur参照判定
            if (isNecessaryMstKur) {
//                // 未読み込み判定
//                if (!dto.isLoadedMstKur()) {
                // オーダーのクールコードからクールマスタ情報を取得
                MstKur mstKur = kurList.stream()
                    .filter(state -> !Objects.isNull(state.getKurCd()) && !Objects.isNull(ord.getIndKurCd())
                        && Objects.equals(state.getKurCd().toString(), ord.getIndKurCd().toString()))
                    .findFirst()
                    .orElse(null);
                // DTOにセット
                dto.setMstKur(mstKur);
//                }
//                // 読み込み済み
//                dto.setLoadedMstKur(true);
            }

            // pat_unique参照判定
            if (isNecessaryPatUnique) {
//                // 未読み込み判定
//                if (!dto.isLoadedPatUnique()) {
                if (ord.getPatId() != null) {
                  // オーダーの患者IDから患者情報を取得
                  PatUnique patUnique = patUniqueList.stream()
                      .filter(o -> Objects.equals(o.getPat_id(), Long.valueOf(ord.getPatId())))
                      .findFirst()
                      .orElse(null);
                  // DTOにセット
                  if (patUnique != null) {
                    dto.setPatUnique(patUnique);
                  }
//                  }
//                  // 読み込み済み
//                  dto.setLoadedPatUnique(true);
              }
            }

            // mni_monitor参照判定
            if (isNecessaryMniMonitor) {
//                // 未読み込み判定
//                if (!dto.isLoadedMniMonitor()) {
                // delete List<MniMonitor> mniMonitorList; 性能改善一時対応 劉

                // オーダー番号判定
                if (ord.getOrdNo() != null) {
                  // オーダー番号がある場合

                  // オーダー番号から最新のモニタデータ取得
                  // mniMonitorList = mniMonitorDao.selectNewestOrdNoAllDataType(ord.getOrdNo());
                  // オーダー番号、データ種別から全モニタデータ(バイタル)取得
                  //mod FNSI 治療状況リスト画面性能改善　劉祥霖　start
                  //List<MniMonitor> mniMonitorDataType1List = mniMonitorDao.selectByOrdNoDataType(ord.getOrdNo(),
                  //    (short) 2,facilityCd);
                  //mod FNSI 治療状況リスト画面性能改善　劉祥霖　end

                  // モニタデータ取得
//                  MniMonitor mniMonitor = mniMonitorList.stream()
//                    //mod FNSI-redmine6018 劉祥霖 start
////                        .filter(o -> o.getOrdNo() == ord.getOrdNo() && (!Objects.isNull(o.getDataType()) && o.getDataType().shortValue() == (short) 1))
//                      .filter(o -> o.getOrdNo()!=null
//                        &&ord.getOrdNo().equals(o.getOrdNo())
//                        && (!Objects.isNull(o.getDataType())
//                        && o.getDataType().shortValue() == (short) 1))
//                    //mod FNSI-redmine6018 劉祥霖 end
//                    .findFirst()
//                      .orElse(null);

                  RoughMonitorData fixedRoughMonitorData =
                    Optional.ofNullable(roughMonitorData).orElse(Collections.emptyList())
                      .stream()
                      .filter(data -> ord.getOrdNo().equals(data.getOrdNo()))
                      .findFirst().orElse(null);

                  // DTOにセット
                  if (fixedRoughMonitorData != null) {
                    dto.setMniMonitor(fixedRoughMonitorData.getMonitorData());
                    // 中血圧測定取得
                    dto.setMniMonitorNowBloodPressure(fixedRoughMonitorData.getMniMonitorNowBloodPressure());
                    // 前血圧測定取得
                    dto.setMniMonitorBeforeBloodPressure(fixedRoughMonitorData.getMniMonitorBeforeBloodPressure());
                    // 後血圧測定取得
                    dto.setMniMonitorAfterBloodPressure(fixedRoughMonitorData.getMniMonitorAfterBloodPressure());
                    // 体温
                    dto.setMniMonitorTemperaturePressure(fixedRoughMonitorData.getMniMonitorTemperaturePressure());
                    // 再循環率
                    dto.setMniMonitorCyclePressure(fixedRoughMonitorData.getMniMonitorCyclePressure());
                  }

                  // mnt_machine_state からモニタデータ取得したデータをDTOにセット
                  if (machineMonitorData != null) {
                    dto.setMntMachineState(machineMonitorData);
                  }

//                    //mod 性能改善一時対応 劉 start
//                    List<MniMonitor> mniMonitorDataType1List =
//                      mniMonitorDataType1ListAll.stream()
//                        //mod FNSI redmine 6123 劉祥霖　start
//                        .filter(item -> ord.getOrdNo().equals(item.getOrdNo()))
////                      .filter(item -> item.getOrdNo() == ord.getOrdNo())
//                        //mod FNSI redmine 6123 劉祥霖　end
//                      .collect(Collectors.toList());
//                    //mod 性能改善一時対応 劉 end
//
//                    // 最新のバイタル取得
//                    if (0 < mniMonitorDataType1List.size()) {
//
//                      // 古いモニタ情報から新しいモニタ情報で存在するモニタ項目を上書き
//                      ObjectNode nodeMoni = mapper.createObjectNode();
//                      for (MniMonitor mon : mniMonitorDataType1List) {
//                        // add #8557 「治療状況リストの項目が空欄」について、対応する。 dengshen start
//                        if (mon.getMonitorData() == null) {
//                          continue;
//                        }
//                        // add #8557 「治療状況リストの項目が空欄」について、対応する。 dengshen end
//                        JsonNode node = mapper.readTree(mon.getMonitorData());
//                        Iterator<String> fldNames = node.propertyNames().iterator();
//                        while (fldNames.hasNext()) {
//                          String fldName = fldNames.next();
//                          if (!node.get(fldName).isNull()) {
//                            nodeMoni.put(fldName, node.get(fldName).asText());
//                          }
//                        }
//                      }
//                      // 最新バイタル
//                      MniMonitor moni = mniMonitorDataType1List.get(0);
//                      moni.setMonitorData(mapper.writeValueAsString(nodeMoni));
//                      dto.setMniMonitorNowBloodPressure(moni);
//                    }

                  // #11329 【たくしん会】治療状況リストに体温が表示しない Mod by Z.T Start
//                  mniMonitor = mniMonitorList.stream()
//                          .filter(o -> !Objects.isNull(o.getDataType()) && o.getDataType().shortValue() == (short) 2
//                                  && ord.getOrdNo().equals(o.getOrdNo())
//                          )
//                          .findFirst()
//                          .orElse(null);
//                  // 現在血圧
//                  if (mniMonitor != null) {
//                    dto.setMniMonitorNowBloodPressure(mniMonitor);
//                  }
                  // 現在血圧
//                  dto.setMniMonitorNowBloodPressure(
//                    mniMonitorList.stream()
//                      .filter(o -> ord.getOrdNo().equals(o.getOrdNo()))
//                      .toList()
//                  );


                  // #11329 【たくしん会】治療状況リストに体温が表示しない Mod by Z.T End

//                  mniMonitor = mniMonitorList.stream()
//                      .filter(o -> !Objects.isNull(o.getDataType()) && o.getDataType().shortValue() == (short) 5
//                          //add FNSI redmine 6408 劉祥霖 start
//                          && ord.getOrdNo().equals(o.getOrdNo())
//                        //add FNSI redmine 6408 劉祥霖 end
//                      )
//                      .findFirst()
//                      .orElse(null);
                  // 前血圧測定
//                  if (mniMonitor != null) {
//                    dto.setMniMonitorBeforeBloodPressure(mniMonitor);
//                  }

                  // add FNSI-モニタデータ取得変更 付 start
//                  mniMonitor = mniMonitorList.stream()
//                    .filter(o -> !Objects.isNull(o.getDataType()) && o.getDataType().shortValue() == (short) 2
//                        //add FNSI redmine 6408 劉祥霖 start
//                        && ord.getOrdNo().equals(o.getOrdNo())
//                      //add FNSI redmine 6408 劉祥霖 end
//                    )
//                    .findFirst()
//                    .orElse(null);
                  // 中血圧測定
//                  if (mniMonitor != null) {
//                    dto.setMniMonitorMiddleBloodPressure(mniMonitor);
//                  }
                  // 体温測定取得
//                  mniMonitor = mniMonitorList.stream()
//                    .filter(o -> !Objects.isNull(o.getDataType()) && o.getDataType().shortValue() == (short) 4
//                        //add FNSI redmine 6408 劉祥霖 start
//                        && ord.getOrdNo().equals(o.getOrdNo())
//                      //add FNSI redmine 6408 劉祥霖 end
//                    )
//                    .findFirst()
//                    .orElse(null);
                  // 体温測定
//                  if (mniMonitor != null) {
//                    dto.setMniMonitorTemperaturePressure(mniMonitor);
//                  }
                  // 再循環率測定取得
//                  mniMonitor = mniMonitorList.stream()
//                    .filter(o -> !Objects.isNull(o.getDataType()) && o.getDataType().shortValue() == (short) 3
//                        //add FNSI redmine 6408 劉祥霖 start
//                        && ord.getOrdNo().equals(o.getOrdNo())
//                      //add FNSI redmine 6408 劉祥霖 end
//                    )
//                    .findFirst()
//                    .orElse(null);
                  // 再循環率測定
//                  if (mniMonitor != null) {
//                    dto.setMniMonitorCyclePressure(mniMonitor);
//                  }
                  // add FNSI-モニタデータ取得変更 付 end

//                  mniMonitor = mniMonitorList.stream()
//                      .filter(o -> !Objects.isNull(o.getDataType()) && o.getDataType().shortValue() == (short) 6
//                          //add FNSI redmine 6408 劉祥霖 start
//                         && ord.getOrdNo().equals(o.getOrdNo())
//                      //add FNSI redmine 6408 劉祥霖 end
//                      )
//                      .findFirst()
//                      .orElse(null);
                  // 後血圧測定
//                  if (mniMonitor != null) {
//                    dto.setMniMonitorAfterBloodPressure(mniMonitor);
//                  }
                } else {
                  // オーダー番号がない場合

                  // ベッド番号
                  if (bedCd != null && bedCd > 0) {
                    // 装置状態取得
                    machine = machineStateList.stream()
                        .filter(state -> Objects.equals(state.getBedCd(), bedCd))
                        .findFirst()
                        .orElse(null);
                    if (machine != null) {
                      // 対象装置の最新のモニタデータを取得する
                      //mod FNSI redmine 6123 劉祥霖 start
                      /* modify #6746 zhangruixue 2023-03-15 治療状況リスト、治療状況マップを開くのが遅い --start */
//                      mniMonitorList = this.monitorSelectNowMachineDataType(
//                        List<MniMonitor> mniMonitorListNewest = this.monitorSelectNowMachineDataType(
//                          //mod FNSI redmine 6123 劉祥霖 end
//                          machine.getFacilityCd(),
//                          machine.getMachineTypeCd(),
//                          machine.getMachineSerial(),
//                          (short) 1);
                      String temMachineTypeCd = machine.getMachineTypeCd();
                      String temMachineSerial = machine.getMachineSerial();
                      MntMachineState machineStateDataMonitor = mntMachineStateList.stream().filter(s -> Objects.equals(s.getMachineTypeCd(), temMachineTypeCd)
                        && Objects.equals(s.getMachineSerial(), temMachineSerial)).findFirst().orElse(null);
                      if (machineStateDataMonitor != null && StringUtils.hasText(machineStateDataMonitor.getMonitorData())) {
                        MniMonitor mniMonitor = new MniMonitor();
                        mniMonitor.setMonitorData(machineStateDataMonitor.getMonitorData());
                        dto.setMniMonitor(mniMonitor);
                      }
                      // DTOにセット
                      //mod FNSI redmine 6123 劉祥霖 start
//                      if (mniMonitorList != null && 0 < mniMonitorList.size()) {
//                        dto.setMniMonitor(mniMonitorList.get(0));
//                        if (mniMonitorListNewest != null && 0 < mniMonitorListNewest.size()) {
//                          dto.setMniMonitor(mniMonitorListNewest.get(0));
//                          //mod FNSI redmine 6123 劉祥霖 end
//                        }
                      /* modify #6746 zhangruixue 2023-03-15 治療状況リスト、治療状況マップを開くのが遅い --end */
                    }
                  }
                }
//                  // 読み込み済み
//                  dto.setLoadedMniMonitor(true);
//                }
            }

            // 前回後体重要否判定
            if (isNecessaryLastAfterWeight) {
//                // 未読み込み判定
//                if (!dto.isLoadedLastWeightInfo()) {
                if (!Objects.isNull(ord.getOrdNo()) && !Objects.isNull(ord.getPatId())) {
                  // 検索基準日を取得(ord_mainの治療日treat_dateを用いる)
                  // treat_dateはYYYYMMDDだが、Timestamp型取得のためLocalDateTime型にパースするので、時刻情報を付加する
                  String treatDateStr = ord.getTreatDate() + " 00:00:00";
                  DateTimeFormatter dtf = DateTimeFormatter.ofPattern("uuuuMMdd HH:mm:ss");
                  Timestamp baseDate = Timestamp.valueOf(LocalDateTime.parse(treatDateStr, dtf));
                  try {
                    /* modify by chamaojia 2023-06-16 [8637] 一括クエリを使用して検索する --start */
                    // 前回の体重情報のJSON文字列を取得(特殊浄化を除くため第4引数を0とする)
//                      String lastWeightInfo = ordMainDao.selectLastRstWeight(Long.valueOf(ord.getPatId()),
//                              ord.getOrdNo(),
//                              baseDate, 0);
//                      // DTOにセット
//                      dto.setLastWeightInfo(lastWeightInfo);
                    if (lastRstWeightList != null && lastRstWeightList.size() > 0) {
                      TreatmentStatusList lastRstWeightEntity = lastRstWeightList.stream().filter(info -> Objects.equals(Long.valueOf(ord.getPatId()), info.getPatId())
                              && Objects.equals(ord.getOrdNo(), info.getOrdNo())
                              && Objects.equals(ord.getFacilityCd(), info.getFacilityCd())
                              && Objects.equals(ord.getTreatDate(), info.getTreatDate()))
                              .findFirst()
                              .orElse(null);
                      if (lastRstWeightEntity != null) {
                        dto.setLastWeightInfo(lastRstWeightEntity.getRstWeightInfo());
                      }
                    }
                    /* modify by chamaojia 2023-06-16 [8637] 一括クエリを使用して検索する --end */
                  } catch (Exception ex) {
                    EventLogMessage eventLogMessage = new EventLogMessage();
                    eventLogMessage
                        .setLogMessage("REST request error by get makeDcsJsonText-lastRstWeight :" + ex.getMessage());
                    eventLogMessage.setSqlIdentification("(patId = " + ord.getPatId() + ", ordNo = " + ord.getOrdNo()
                        + ", baseDate = " + baseDate + ", tokushu = " + 0 + ")");
                    logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_TREATMENT_RECORD,
                        SERVICE_NAME.REMS, "OrdMainDao/selectLastRstWeight");
                  }
                }
//                  // 読み込み済み
//                  dto.setLoadedLastWeightInfo(true);
//                }
            }

            // 観察記録件数要求判定
            if (isNecessaryPatEventCount) {
//                // 未読み込み判定
//                if (!dto.isLoadedPatEventCount()) {
                // 観察記録の件数取得
                List<NumberOfUserTypeByOrdNo> conuntUserType =
                  countUserTypeList.stream()
                    .filter(c -> c.getOrdNo().equals(ord.getOrdNo()))
                    .collect(Collectors.toList());

                dto.setPatEventCount(conuntUserType.size() > 0 ? conuntUserType.get(0).getCount() : 0);
//                  // 読み込み済み
//                  dto.setLoadedPatEventCount(true);
//                }
            }

            /* del #10102 zhangruixue 2023-12-4 治療状況リスト，マップにて再循環測定が行われると一部の項目が空欄になる --start */
            // 再循環率要求判定
//              if (itemCd.equals(72)) {
//                // 未読み込み判定
//                if (!dto.isLoadedReLoopRateMain()) {
//                      if (mons != null) {
//                        String info = ord.getRstWeightInfo();
//                        // 再循環率参照先の管理番号取得
//                        // mod NULL値判定の追加 查 start
//                        if(!StringUtils.isEmpty(info)) {
//                          String strBioNo = this.getJsonNodeValue(info, "re_loop_rate_main");
//                          if (StrUtils.isNumber(strBioNo)) {
//                            Long bioNo = Long.parseLong(strBioNo);
//                            List<MniMonitor> mon = mons.stream().filter(m -> m.getBioMoniCtlNo() == bioNo).collect(Collectors.toList());
//                              if (mon != null){
//                              // 再循環率取得
//                              dto.setReLoopRateMain(this.getJsonNodeValue(mon.get(0).getMonitorData(), "89"));
//                            }
//                          }
//                        }
//                        // mod NULL値判定の追加 查 start
//                      }
//                  }
//                  // 読み込み済み
//                  dto.setLoadedReLoopRateMain(true);
//                }
            /* del #10102 zhangruixue 2023-12-4 治療状況リスト，マップにて再循環測定が行われると一部の項目が空欄になる --end */
            // 種別マスタ参照判定
            if (isNecessaryMstRoundType && ord.getRstRoundsInfo() != null) {
              JSONObject rri = new JSONObject(ord.getRstRoundsInfo());
              // オーダーの種別コードから種別マスタ情報を取得
              MstRoundType mstRoundType = mstRoundTypeList.stream()
                  .filter(state -> !Objects.isNull(state.getRoundTypeCd()) && !Objects.isNull(rri.getInt("round_type_cd"))
                      && Objects.equals(state.getRoundTypeCd().toString(), String.valueOf(rri.getInt("round_type_cd"))))
                      .findFirst()
                      .orElse(null);
              // 種別マスタ_強調表示を返却値にセット
              ordNode.put("roundStateHighlighting", mstRoundType == null ? "" : mstRoundType.getHighlighting());
            }
          }
//          }
        timeRecordO = timeRecordO + (System.currentTimeMillis() - tempStartTimeO);
        String colValue = "";
        Long msOrderIndex = -1L;
        // レイアウトされた項目の設定
        long tempStartTimeT = System.currentTimeMillis();
        MntMachineState data = null;
        if (needMntMachineStateFlag && ordNode.has("machineTypeCd") && ordNode.has("machineSerial")) {
          data = mntMachineStateList.stream().filter(s -> Objects.equals(s.getMachineTypeCd(), ordNode.get("machineTypeCd").asText())
                  && Objects.equals(s.getMachineSerial(), ordNode.get("machineSerial").asText())).findFirst().orElse(null);
        }
        JSONObject rwi = new JSONObject();
        if (ord.getRstWeightInfo() != null) {
          rwi = new JSONObject(ord.getRstWeightInfo());
        }
        MstTreatment mstTreatment = mstTreatmentList.stream().filter(m -> m.getTreatmentCd().equals(ord.getIndTreatmentCd())).findFirst().orElse(null);
        JsonNode treatmentConditionSettingJsonNode = null;
        if (mstTreatment != null && mstTreatment.getTreatmentConditionSetting() != null) {
          String treatmentConditionSetting = mstTreatment.getTreatmentConditionSetting();
          if (jsonNodeMap.containsKey(treatmentConditionSetting)) {
            treatmentConditionSettingJsonNode = jsonNodeMap.get(treatmentConditionSetting);
          } else {
            treatmentConditionSettingJsonNode = mapper.readTree(mstTreatment.getTreatmentConditionSetting());
            jsonNodeMap.put(treatmentConditionSetting, treatmentConditionSettingJsonNode);
          }
        }
      // add #10773 治療状況レイアウトマスタにて透析装置の項目0件だと、治療状況マップのスケジュールで患者が表示しない。 ztc start
      if(dcsItem != null) {
      // add #10773 治療状況レイアウトマスタにて透析装置の項目0件だと、治療状況マップのスケジュールで患者が表示しない。 ztc end

        //add #11553 治療状況表示項目不足( 残り時間:113) zrx start
        String orderNoStr113 = "";
        //add #11553 治療状況表示項目不足( 残り時間:113) zrx end

        for (TreatmentStatusLayoutViewItems dcsView : dcsItem) {
          String fieldValue = "";
          itemCd = dcsView.getDataClass();

          String keyName = dcsView.getKeyName();
          String columnName = dcsView.getColumnName();
          String title = dcsView.getTitle();
          Integer dataClass = dcsView.getDataClass();
          String tableName = dcsView.getTableName();
          /* add by chamaojia 2024-10-24 [9312] reading of added values --start */
          String vitalMonitorClass = dcsView.getVitalMonitorClass();
          /* add by chamaojia 2024-10-24 [9312] reading of added values --end */

          try {
            colValue = null;
            msOrderIndex = -1L;
            // 項目判定
            if (itemCd < 10000 && -10000 < itemCd && isCalcurationItem(itemCd)) {
              // テーブル名・フィールド名・JSONキー名指定で値を取得できない項目の場合
              // itemCdが500以下：「mnt_treatment_status_disp_item」定義外

              if (ord.getOrdNo() != null) {
                // 計算値を取得
                StatusListDTO.ItemResult itemResult = dto.getByItemCd(itemCd, dateFormat);
                colValue = itemResult.colValue();
                msOrderIndex = itemResult.msOrderIndex(); // マスタ並び順
                // add FNSI-No387 付 start
                if ((itemCd == 4 || itemCd == 6) && !StringUtils.isEmpty(colValue)) {
                  if (colValue.indexOf(".") != -1) {
                    String[] weight = colValue.split("\\.");
                    if (weight.length == 2 && weight[1].length() == 1) {
                      colValue = colValue + "0";
                    }
                  } else {
                    colValue = colValue + ".00";
                  }
                }
                // add FNSI-No387 付 end
                //add #11553 治療状況表示項目不足( 残り時間:113) zrx start
                if(itemCd == 113) {
                  colValue = dto.get113FieldValue(rstDialysisState, columnName, functionCode, dto, machine);
                }
                //add #11553 治療状況表示項目不足( 残り時間:113) zrx end
              }
            } else
              //add FNSI redmine 6018 6123 劉祥霖 start
              //装置自己診断の場合、table_nameはnullので、処理変更
              if(tableName!=null)
              //add FNSI redmine 6018 6123 劉祥霖 end
              {
              // テーブル名・フィールド名・JSONキー名指定で値を取得可能な項目の場合
              // 参照先テーブル判定
                /* modify by chamaojia 2024-10-24 [9312] encapsulate logic into methods and correct the original logic --start */
                fieldValue = getFieldValue(tableName, keyName, dataClass, vitalMonitorClass
                        , rstDialysisState, columnName, functionCode, dto, machine, ord);
                /* modify by chamaojia 2024-10-24 [9312] encapsulate logic into methods and correct the original logic --end */

              // 取得したデータと指定された列名で項目を作成
              // 取得したデータがjson形式である場合はここで、jsonからデータを取得
              if (keyName != null && keyName.length() > 0) {

                colValue = getJsonNodeValue(fieldValue, keyName, jsonNodeMap);
                // add FNSI-測定前の値は空欄とする 徐 start
                if ("38".equals(keyName) ||
                  "68".equals(keyName) ||
                  "79".equals(keyName) ||
                  "88".equals(keyName)) {
                  if ("-1".equals(colValue)) {
                    colValue = " ";
                  }
                }
                // add FNSI-測定前の値は空欄とする 徐 end
                // add FNSI-受信した値が-32768（8000h）の場合は、空欄を表示する 徐 start
                if ("-32768".equals(colValue)) {
                  if (!"0".equals(keyName)
                    && !"16".equals(keyName)
                    && !"31".equals(keyName)
                    && !"52".equals(keyName)
                    && !"53".equals(keyName)
                    && !"81".equals(keyName)
                    && !"82".equals(keyName)
                    && !"83".equals(keyName)
                    && !"84".equals(keyName)
                    && !"85".equals(keyName)
                    && !"86".equals(keyName)
                    && !"87".equals(keyName)
                    && !"89".equals(keyName)
                    && !"95".equals(keyName)
                    && !"96".equals(keyName)
                    && !"99".equals(keyName)) {
                    colValue = " ";
                  }
                }
                // add FNSI-受信した値が-32768（8000h）の場合は、空欄を表示する 徐 end
                // add FNSI-データが届かない場合は表示「不明」 付 start
                int colCount = 0;
                String stringConvItem = "";
                /* modify #6746 zhangruixue 2023-02-24 治療状況リスト、治療状況マップを開くのが遅い --start */
//                  for (int i = 0; i < sysMonitorItemList.size(); i++) {
//                    if (Objects.equals(sysMonitorItemList.get(i).getMoniDataNo(), keyName)) {
//                      colCount++;
//                      stringConvItem = sysMonitorItemList.get(i).getConvItem();
//                      break;
//                    }
//                  }
                if(StringUtils.hasText(keyName) && sysMonitorItemMap.get(keyName) != null){
                    colCount++;
                    stringConvItem = sysMonitorItemMap.get(keyName).getConvItem();
                }
                /* modify #6746 zhangruixue 2023-02-24 治療状況リスト、治療状況マップを開くのが遅い --start */
                if (colCount > 0 && stringConvItem != null) {
                  if (colValue == null || Objects.equals(colValue, "")) {
                    colValue = convColValue(sysMonitorItemMap, "", dcsView, colValue, jsonNodeMap);
                  } else {
                    JsonNode node = null;
                    if (jsonNodeMap.containsKey(stringConvItem)) {
                      node = jsonNodeMap.get(stringConvItem);
                    } else {
                      node = mapper.readTree(stringConvItem);
                      jsonNodeMap.put(stringConvItem, node);
                    }
                    if (!node.has(colValue)) {
                      colValue = "不明";
                    } else {
                      // 変換処理
                      colValue = convColValue(sysMonitorItemMap, "", dcsView, colValue, jsonNodeMap);
                    }
                  }
                } else {
                  // 変換処理
                  colValue = convColValue(sysMonitorItemMap, "", dcsView, colValue, jsonNodeMap);
                }
                // 変換処理
//                  colValue = convColValue(sysMonitorItemList, "", dcsView, colValue);
                // add FNSI-データが届かない場合は表示「不明」 付 end

              } else {
                colValue = fieldValue;
              }
              //add #11553 治療状況表示項目不足( 残り時間:113) zrx start
              if (dataClass.equals(113)) {
                orderNoStr113 = dcsView.getOrderNo().toString();
              }
              //add #11553 治療状況表示項目不足( 残り時間:113) zrx end
            }
            // 取得した値がNullの場合は空文字とする
            // 取得した文字列がnullの場合は空文字にする
            if (colValue == null || colValue.equals("null")) {
              colValue = "";
            }

            // エスケープ処理
            if (colValue.contains("\"")) {
              // ダブルクォーテーションをエスケープ
              colValue.replaceAll("\"", "\\\"");
            }

            // フィールド名
            String fldName = columnName != null ? columnName : "";
            if (0 <= fldName.toLowerCase().indexOf("date") && !colValue.equals("")) {
              // 日付時刻変換(YYYY-MM-DD HH:MM:SS形式)
              try {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                sdf.setLenient(false);
                Date workdate = sdf.parse(colValue);
                colValue = dispsdf.format(workdate);
              } catch (Exception ex) {
              }
            }
            // キー名
            if (0 <= (keyName != null ? keyName : "").toLowerCase().indexOf("date") && !colValue.equals("")) {
              // 日付時刻変換(ISO8601形式)
              Date workDate = DateTimeUtils.dateStringToDate_iso8601(colValue);
              if (workDate != null) {
                colValue = dispsdf.format(workDate);
              }
            }

            // 戻り値のフィールド名構築
            // SQL取得時にJSONを固定フィールドで取得している場合のみ、定義済みのカラムで取得
            if (fldName.equals("rst_charge_date_a")
                || fldName.equals("rst_charge_date_b")
                || fldName.equals("rst_puncture_date_a")
                || fldName.equals("rst_puncture_date_b")
                || fldName.equals("rst_return_date_a")
                || fldName.equals("rst_return_date_b")
                || fldName.equals("rst_charge_userid_a")
                || fldName.equals("rst_charge_userid_b")
                || fldName.equals("rst_puncture_userid_a")
                || fldName.equals("rst_puncture_userid_b")
                || fldName.equals("rst_return_userid_a")
                || fldName.equals("rst_return_userid_b")) {
              ordNode.put(columnName, colValue);
            } else {
              try {
                // オフライン装置判定
                if (isOffline) {
                  // オフライン

                  // 治療状況判定
                  if (0 < Objects.compare(rstDialysisState, "2", Comparator.naturalOrder())) {
                    // 治療中の場合

                    // 残り時間(透析完了)[14]の場合
                    if (dataClass.equals(14)) {

                      // 残り時間(治療時間-経過時間)取得
                      colValue = Util.ElapsedMinutesToHHMM(dto.getRemainTime());
                    }
                  }

                  // 経過時間の場合
                  if (Objects.equals(tableName, MNI_MONITOR)
                      && Objects.equals(columnName, "monitor_data")
                      && Objects.equals(keyName, "1")) {

                    // 経過時間取得
                    colValue = Util.ElapsedMinutesToHHMM(dto.getElapsedTime());
                  }
                } else {
                  // オンライン

                  // 残り時間(透析完了)[14]の場合
                  if (dataClass.equals(14)) {
                    if (StrUtils.isNumber(colValue)) {
                      // 書式整形
                      Long work = Long.parseLong(colValue);
                      colValue = Util.ElapsedMinutesToHHMM(work);
                    }
                  }
                }
              } catch (Exception ex) {
              }
              //add FNSI　redmine 5174 劉祥霖　start
//                List<OrdMain> ordMainList =
//                  ordMains.stream()
//                    //mod FNSI redmine 6018 劉祥霖　start
////                  .filter(o -> o.getOrdNo()==ord.getOrdNo())
//                  .filter(o -> o.getOrdNo().equals(ord.getOrdNo()))
//                    //mod FNSI redmine 6018 劉祥霖　end
//                  .collect(Collectors.toList());
//                if (ordMainList != null && ordMainList.size() > 0) {
//                  JSONObject rwi = new JSONObject();
//                  if(ordMainList.get(0).getRstWeightInfo()!=null){
//                    rwi = new JSONObject(ordMainList.get(0).getRstWeightInfo());
//                  }
//                  if (ord.getRstWeightInfo() != null) {
//                    rwi = new JSONObject(ord.getRstWeightInfo());
//                  }
                if (rwi != null && !rwi.isEmpty()) {

                  List<String> AFTER_DIALYSIS_STATE = List.of("4", "5");
                  //Kt/V測定値があれば再取得
                  // mod #7862 2022-10-24 【デグレ】治療状況リスト，治療状況マップの表示が不正_再発 dou start
                  // if (itemCd == 549) {
                  if ("38".equals(keyName) && AFTER_DIALYSIS_STATE.contains(ord.getRstDialysisState())) {
                  // mod #7862 2022-10-24 【デグレ】治療状況リスト，治療状況マップの表示が不正_再発 dou start
                    // OrdMain ordMain = ordMainDao.selectByOrdNo(ord.getOrdNo());
                    //JSONObject rwi=new JSONObject(ordMain.getRstWeightInfo());
                    if (rwi.has("kt_v_measure")) {
                      colValue = rwi.get("kt_v_measure").toString();
                      if ("null".equals(colValue)) {
                        colValue = "";
                      }
                    }
                  }
                  //URRがあれば再取得
                  // mod #7862 2022-10-24 【デグレ】治療状況リスト，治療状況マップの表示が不正_再発 dou start
                  // if (itemCd == 588) {
                  if ("79".equals(keyName) && AFTER_DIALYSIS_STATE.contains(ord.getRstDialysisState())) {
                  // mod #7862 2022-10-24 【デグレ】治療状況リスト，治療状況マップの表示が不正_再発 dou end
                    // OrdMain ordMain = ordMainDao.selectByOrdNo(ord.getOrdNo());
                    //JSONObject rwi=new JSONObject(ordMain.getRstWeightInfo());
                    if (rwi.has("urr")) {
                      colValue = rwi.get("urr").toString();
                      if ("null".equals(colValue)) {
                        colValue = "";
                      }
                    }
                  }
                  // 再循環率有効値があれば再取得 ( 治療記録>体重>再循環率 のチェックボックスにチェックが入っているレコードの再循環率データを取得 )
                  if (itemCd == 72 || "89".equals(keyName)) {
                    if (rwi.has("recrcl_rt") && (!rwi.get("recrcl_rt").equals(null))) {
                      JSONObject recrclRt = new JSONObject(rwi.get("recrcl_rt").toString());
                      if (recrclRt.has("valid_no") && (!recrclRt.get("valid_no").equals(null))) {
                        String keyNo = recrclRt.get("valid_no").toString();
                        if (recrclRt.has(keyNo) && (!recrclRt.get(keyNo).equals(null))) {
                          JSONObject jsonData = new JSONObject(recrclRt.get(keyNo).toString());
                          colValue = jsonData.get("rate").toString();
                          if ("null".equals(colValue)) {
                            colValue = "";
                          }
                        }
                      }
                    }
                  }

                  // #9312 DEL by Z.T. Start layout master has been changed, col of 'bld_vl' means monitor data's bld_vl
                  // 血流量があれば再取得 ( 治療記録>体重>再循環率 のチェックボックスにチェックが入っているレコードの血液量データを取得 )
//                  String tmpTbName = tableName != null ? tableName : "";
//                  String tmpColName = columnName != null ? columnName : "";
//                  String tmpKeyName = keyName != null ? keyName : "";
//                  if (tmpTbName.equals(MNT_MACHINE_STATE) && tmpColName.equals("monitor_data") && tmpKeyName.equals("8")) {
//                    if (rwi.has("recrcl_rt") && (!rwi.get("recrcl_rt").equals(null))) {
//                      JSONObject recrclRt = new JSONObject(rwi.get("recrcl_rt").toString());
//                      if (recrclRt.has("valid_no") && (!recrclRt.get("valid_no").equals(null))) {
//                        String keyNo = recrclRt.get("valid_no").toString();
//                        if (recrclRt.has(keyNo) && (!recrclRt.get(keyNo).equals(null))) {
//                          JSONObject jsonData = new JSONObject(recrclRt.get(keyNo).toString());
//                          colValue = jsonData.get("bld_vl").toString();
//                          if ("null".equals(colValue)) {
//                            colValue = "";
//                          }
//                        }
//                      }
//                    }
//                  }
                  // DEL END

                  //静的静脈圧があれば再取得
                  if (itemCd == 14) {
                    // OrdMain ordMain = ordMainDao.selectByOrdNo(ord.getOrdNo());
                    //JSONObject rwi=new JSONObject(ordMain.getRstWeightInfo());
                    if (rwi.has("sttc_vns_prssr")) {
                      colValue = rwi.get("sttc_vns_prssr").toString();
                      if ("null".equals(colValue)) {
                        colValue = "";
                      }
                    }
                  }

                  // #9312 Add 除水積算値があれば再取得
                  if ("5".equals(keyName) && AFTER_DIALYSIS_STATE.contains(ord.getRstDialysisState())) {
                    if (rwi.has("add_total")) {
                      colValue = rwi.get("add_total").toString();
                      if ("null".equals(colValue)) {
                        colValue = "";
                      } else if (StringUtils.hasText(colValue) && -10000 >= dcsView.getDataClass()
                        && (Objects.equals(dcsView.getDataType(), "1")
                        || Objects.equals(dcsView.getDataType(), "2"))) {
                        SysMonitorItem addTotalItem = sysMonitorItemMap.get(keyName);
                        if (addTotalItem != null) {
                          colValue = Util.getFormattedNumber(colValue, addTotalItem.getDecimalFigure());
                        }
                      }
                    }
                  }
                  // #9312 Add 補液量現在値があれば再取得
                  if ("72".equals(keyName) && AFTER_DIALYSIS_STATE.contains(ord.getRstDialysisState())) {
                    if (rwi.has("add_water_total")) {
                      colValue = rwi.get("add_water_total").toString();
                      if ("null".equals(colValue)) {
                        colValue = "";
                      } else if (StringUtils.hasText(colValue) && -10000 >= dcsView.getDataClass()
                        && (Objects.equals(dcsView.getDataType(), "1")
                        || Objects.equals(dcsView.getDataType(), "2"))) {
                        SysMonitorItem addTotalItem = sysMonitorItemMap.get(keyName);
                        if (addTotalItem != null) {
                          colValue = Util.getFormattedNumber(colValue, addTotalItem.getDecimalFigure());
                        }
                      }
                    }
                  }
                }
//                }
              // add #7862 2022-09-13 【デグレ】治療状況リスト，治療状況マップの表示が不正_再発 dou start
              if ("前体重 - 目標体重".equals(title) ||
                "前体重".equals(title) ||
                "後体重".equals(title) ||
                "前体重-後体重".equals(title) ||
                "引き残し".equals(title) ||
                "除水目標".equals(title) ||
                "前回後体重".equals(title) ||
                "増加量".equals(title)) {
                if (NumberUtils.isParsable(colValue)) {
                  colValue = String.format("%.2f", Double.parseDouble(colValue));
                }
              }
              if ("治療開始".equals(title) || "終了予定".equals(title)) {
                if ("1".equals(rstDialysisState) || "2".equals(rstDialysisState)){
                  colValue = "";
                }
              }
              // add #7862 2022-09-13 【デグレ】治療状況リスト，治療状況マップの表示が不正_再発 dou end
              //add FNSI　redmine 5174 劉祥霖　end
              ordNode.put("field_" + dcsView.getOrderNo().toString(), colValue);
              // マスタ表示順が設定されている場合、画面のソートで使用するためソート用fieldにセットする
              if (!Long.valueOf(-1L).equals(msOrderIndex)) {
                ordNode.put("field_" + dcsView.getOrderNo().toString() + "_sort", msOrderIndex);
              }
              // 61: クール ソート用fieldにクール開始時刻をセットする
              if (itemCd == 61) {
                ordNode.put("field_" + dcsView.getOrderNo().toString() + "_sort", ord.getKurStartTime());
              }

              if (treatmentConditionSettingJsonNode != null && !StringUtils.hasText(colValue)) {
                ObjectNode unUseNodeData = getUnUseData(dataClass, treatmentConditionSettingJsonNode);
                ordNode.setAll(unUseNodeData);
              }
            }
          } catch (Exception e) {
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(
                "REST request error by get makeDcsJsonText : "
                    + " / machineEntry:" + ord.getMachineEntry()
                    + " / ordNo:" + ord.getOrdNo()
                    + " / bedCd:" + ordNode.get("bedCd")
                    + " / bedName:" + ordNode.get("bedName")
                    + " / itemCd:" + itemCd + " -> value:{}"
                    + e.getMessage());
            logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_TREATMENT_RECORD, SERVICE_NAME.REMS,
                null);
          }
        }
        //add #11553 治療状況表示項目不足( 残り時間:113) zrx start
        if (StringUtils.hasText(orderNoStr113)) {
          ordNode.put("field_" + orderNoStr113, dto.get113FieldValue(rstDialysisState, "monitor_data", functionCode, dto, machine));
        }
        //add #11553 治療状況表示項目不足( 残り時間:113) zrx end
        // add #10773 治療状況レイアウトマスタにて透析装置の項目0件だと、治療状況マップのスケジュールで患者が表示しない。 ztc start
      }
      // add #10773 治療状況レイアウトマスタにて透析装置の項目0件だと、治療状況マップのスケジュールで患者が表示しない。 ztc end
        timeRecordT = timeRecordT + (System.currentTimeMillis() - tempStartTimeT);
      } catch (Exception e) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("REST request error by get makeDcsJsonText :" + e.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_TREATMENT_RECORD, SERVICE_NAME.REMS, null);
      }
      dcsNode.add(ordNode);
    }
    eventLogMessageTemp.setLogMessage( "$$$$$$methodName-makeDcsJsonText timeRecordO : " + timeRecordO);
    logService.log(LogLevel.INFO, eventLogMessageTemp, null, SERVICE_NAME.FNSI, null);
    eventLogMessageTemp.setLogMessage( "$$$$$$methodName-makeDcsJsonText timeRecordT : " + timeRecordT);
    logService.log(LogLevel.INFO, eventLogMessageTemp, null, SERVICE_NAME.FNSI, null);
    eventLogMessageTemp.setLogMessage( "$$$$$$methodName-makeDcsJsonText end : " + (System.currentTimeMillis() - startTime));
    logService.log(LogLevel.INFO, eventLogMessageTemp, null, SERVICE_NAME.FNSI, null);
      // del #10773 治療状況レイアウトマスタにて透析装置の項目0件だと、治療状況マップのスケジュールで患者が表示しない。 ztc start
//    }
      // del #10773 治療状況レイアウトマスタにて透析装置の項目0件だと、治療状況マップのスケジュールで患者が表示しない。 ztc end

    return dcsNode;
  }

  /* add by chamaojia 2024-10-24 [9312] encapsulate logic into methods and correct the original logic --start */
  /**
   * retrieve corresponding content based on table name classification
   */
  private String getFieldValue(String tableName, String keyName, Integer dataClass
          , String vitalMonitorClass, String rstDialysisState, String columnName
          , String functionCode, StatusListDTO dto, MntMachineState machine
          , TreatmentStatusList ord) {
    // return value
    String fieldValue = "";
    switch (tableName) {
      /**
       * tableName = "mni_monitor" what data is available:
       * 1. mst_add_monitor (customized data items)
       * 2. sys_monitor_item  moni_data_type = "Z" (特殊浄化)
       * 3. sys_monitor_item  moni_data_type is null
       * These data all need to be read as 【mni_monitor】, but it is necessary to confirm the 【data_type】
       */
      case "mni_monitor":
        if ("1".equals(vitalMonitorClass)) {  // バイタル

          if (rstDialysisState != null) {

            // #11329 【たくしん会】治療状況リストに体温が表示しない Mod by Z.T Start
//            switch (rstDialysisState) {
//              case "0":
//              case "1":
//              case "2":
//                // 透析前  data_type=5
//                fieldValue = Util.getMniMonitorColumnData(dto.getMniMonitorBeforeBloodPressure(), columnName).toString();
//                break;
//              case "3":
//                // 透析中 data_type=2
//                fieldValue = Util.getMniMonitorColumnData(dto.getMniMonitorNowBloodPressure(), columnName).toString();
//                break;
//              case "4":
//              case "5":
//              case "6":
//                // 透析後 data_type=6
//                fieldValue = Util.getMniMonitorColumnData(dto.getMniMonitorAfterBloodPressure(), columnName).toString();
//                break;
//            }

            // データはすでに項目ごとに発生時間で組み合わせられており、各項目の最新のデータを取得しています。
            // だからで、透析中のデータを直接取得すればよいです。
            fieldValue = Util.getMniMonitorColumnData(dto.getMniMonitorNowBloodPressure(), columnName).toString();
            // #11329 【たくしん会】治療状況リストに体温が表示しない Mod by Z.T End
          }
        } else {  // モニタ
          if (keyName.startsWith("Z") || dataClass > 10000) {
            // 特殊浄化 and mst_add_monitor (customized data items)
            fieldValue = Util.getMniMonitorColumnData(dto.getMniMonitor(), columnName).toString();
          } else {
            if (rstDialysisState != null) {
              switch (rstDialysisState) {
                case "0":
                case "1":
                case "2":
                case "3":
                  // 治療状況リスト -> 治療状況/装置一覧  治療状況マップ -> 治療状況/スケジュール
                  fieldValue = Util.getMachineStateColumnData(machine, columnName).toString();
                  break;
                case "4":
                case "5":
                case "6":
                  if ("2".equals(functionCode)) {  // 治療状況リスト -> 装置一覧
                    fieldValue = Util.getMachineStateColumnData(machine, columnName).toString();
                  } else {
                    // 治療状況リスト -> 治療状況  治療状況マップ -> スケジュール
                    fieldValue = Util.getMniMonitorColumnData(dto.getMniMonitor(), columnName).toString();
                  }
                  break;
              }
            } else {
              /**
               * 2: 治療状況リスト -> 装置一覧 、3: 治療状況マップ -> 治療状況
               * these two functions require reading mnt_machine_state in the absence of a patient
               */
              if ("2".equals(functionCode) || "3".equals(functionCode)) {
                fieldValue = Util.getMachineStateColumnData(machine, columnName).toString();
              }
            }
          }
        }
        break;
      /**
       * tableName = "mnt_machine_state" what data is available:
       * 1. mst_treatment_status_disp_item table_name = "mnt_machine_state"
       * These data all need to be read as 【mnt_machine_state】
       */
      case "mnt_machine_state":
        fieldValue = Util.getMachineStateColumnData(machine, columnName).toString();
        break;
      /**
       * tableName = "ord_main" what data is available:
       * 1. mst_treatment_status_disp_item table_name = "mnt_machine_state"
       * These data all need to be read as 【ord_main】
       */
      case "ord_main":
        fieldValue = Util.getTreatmentStatusColumnData(ord, columnName).toString();
        break;
    }

    return fieldValue;
  }
  /* add by chamaojia 2024-10-24 [9312] encapsulate logic into methods and correct the original logic --end */

  private ObjectNode getUnUseData(Integer dataClass, JsonNode treatmentConditionSettingJsonNode) {
    ObjectNode returnObjectNode = mapper.createObjectNode();

    Map<String, String> dataClassValueMap = condSettingMap.get(dataClass);
    if (dataClassValueMap != null) {
      treatmentConditionSettingJsonNode.forEach(e -> {
        if (e.has("category_no") && !e.get("category_no").isNull()
                && Objects.equals(dataClassValueMap.get("category_no"), e.get("category_no").asText())) {
          final JsonNode nodeitems = e.get("items");
          nodeitems.forEach(g -> {
            if (g.has("ctl_no") && !g.get("ctl_no").isNull()
                    && g.has("is_use") && !g.get("is_use").isNull()
                    && Objects.equals(dataClassValueMap.get("ctl_no"), g.get("ctl_no").asText())
                    && Objects.equals("0", g.get("is_use").asText())) {
              returnObjectNode.put("un_use" + dataClass.toString(), true);
            }
          });
        }
      });
    }

    return returnObjectNode;
  }

  private TreatmentStatusLayoutViewItems[] getLayoutViewItems(String jsonText) {
    try {
      if (StringUtils.hasText(jsonText)) {
        return mapper.readValue(jsonText, TreatmentStatusLayoutViewItems[].class);
      } else {
        return null;
      }
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST request error by get getLayoutViewItems :" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_TREATMENT_RECORD, SERVICE_NAME.REMS, null);
      return null;
    }
  }

  private String getJsonNodeValue(String jsonText, String keyName, Map<String, JsonNode> jsonNodeMap) {
    try {
//      JsonNode node = mapper.readTree(jsonText);
      JsonNode node = null;
      if (jsonNodeMap == null) {
        node = mapper.readTree(jsonText);
      } else {
        if (jsonNodeMap.containsKey(jsonText)) {
          node = jsonNodeMap.get(jsonText);
        } else {
          node = mapper.readTree(jsonText);
          jsonNodeMap.put(jsonText, node);
        }
      }

      if (keyName.length() > 0) {
        String[] keyNameArray = keyName.split(",");
        for (String key : keyNameArray) {
          node = node != null ? node.get(key) : null;
        }
        return node != null ? node.asText().replaceAll("\"", "\\\"") : "";
      } else {
        return "";
      }
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST request error by get getJsonNodeValue : " + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_TREATMENT_RECORD, SERVICE_NAME.REMS, null);
    }
    return "null";
  }

  private ArrayNode makeMachineNotBedJsonText(
      List<SysMonitorItem> sysMonitorItemList,
      TreatmentStatusLayoutViewItems[] machineViewItems,
      List<MntMachineState> machineStateList,
      // add FNSI-改修内容5702修正 xuty start
      List<MntMachineFormat> machineFormatList,
      // add FNSI-改修内容5702修正 xuty end
      String occurDate,
      String modelName,
      List<MstMachine> machineList
      //add FNSI redmine 6946 劉祥霖 start
      //リスト・マップ画面判定
      ,String useClass
      //add FNSI redmine 6946 劉祥霖 end
      ) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    // mod #10773 治療状況レイアウトマスタにて透析装置の項目0件だと、治療状況マップのスケジュールで患者が表示しない。 ztc start
    if(machineViewItems != null && machineStateList != null){
      eventLogMessage.setLogMessage("modelName is "+ modelName + " / machineViewItems.length is " + machineViewItems.length + "/ machineStateList.size() is " + machineStateList.size());
      logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, null);
    }
    // mod #10773 治療状況レイアウトマスタにて透析装置の項目0件だと、治療状況マップのスケジュールで患者が表示しない。 ztc end

    ArrayNode machineArrayNode = mapper.createArrayNode();
    /* modify #6746 zhangruixue 2023-02-24 治療状況リスト、治療状況マップを開くのが遅い --start */
    Map<String,SysMonitorItem> sysMonitorItemMap =  sysMonitorItemList.stream().collect(Collectors.toMap(SysMonitorItem::getMoniDataNo, Function.identity()));
    /* modify #6746 zhangruixue 2023-02-24 治療状況リスト、治療状況マップを開くのが遅い --end */
    // add FNSI-改修内容5702修正 xuty startArrayNode();
    Map<String, String> formatMap = new HashMap<String, String>();
    if (machineFormatList != null && machineFormatList.size() > 0) {
      for (MntMachineFormat formatValue : machineFormatList) {
        formatMap.put(formatValue.getFacilityCd() + ";" + formatValue.getMachineTypeCd() + ";" + formatValue.getMachineSerial(), formatValue.getComFormatCd());
      }
    }
    // add FNSI-改修内容5702修正 xuty end
    if (machineStateList.size() > 0) {
      for (MntMachineState state : machineStateList) {
        ObjectNode machineNode = mapper.createObjectNode();

        // 固定項目の設定
        machineNode.put("facilityCd", state.getFacilityCd());
        machineNode.put("machineTypeCd", state.getMachineTypeCd());
        machineNode.put("machineSerial", state.getMachineSerial());
        machineNode.put("machineName", state.getMachineName());
        machineNode.put("machineStatus", state.getMachineStatus());
        machineNode.put("processState", state.getProcessState());
        machineNode.put("isPreventiveMainte", state.getIsPreventiveMainte());
        machineNode.put("model", state.getModel());
        // add FNSI-改修内容5702修正 xuty start
        if ("dad".equals(modelName)) {
          machineNode.put("comFormatCd", formatMap.get(state.getFacilityCd() + ";" + state.getMachineTypeCd() + ";" + state.getMachineSerial()));
        } else {
          machineNode.put("comFormatCd", "");
        }
        // add FNSI-改修内容5702修正 xuty end

        // 装置の通信フォーマット(機種)を取得する
        String deviceType = "";
        MstMachine machine = machineList.stream()
          .filter(info -> Objects.equals(state.getMachineSerial(), info.getMachineSerial())
            && Objects.equals(state.getMachineTypeCd(), info.getMachineTypeCd()))
          .findFirst()
          .orElse(null);
        if (machine != null) {
          // オフライン判定
          deviceType = machine.getComFormatCd();
          // 装置マスタ並び順
          machineNode.put("machineIndex", machine.getMachineIndex());
        }

        // 最新のモニタデータを取得する
        /* del #6746 by zhangruixue 2023-03-10 治療状況リスト、治療状況マップを開くのが遅い --start */
//        MniMonitor mniMonitor = null;
//        List<MniMonitor> mniMonitors = this.monitorSelectNowMachineDataType(
//          state.getFacilityCd(),
//          state.getMachineTypeCd(),
//          state.getMachineSerial(),
//          (short) 1);
//        if (mniMonitors != null && 0 < mniMonitors.size()) {
//          mniMonitor = mniMonitors.get(0);
//        }


//        final String MNI_MONITOR = "mni_monitor";
//        final String MNT_MACHINE_STATE = "mnt_machine_state";
        /* del #6746 by zhangruixue 2023-03-10 治療状況リスト、治療状況マップを開くのが遅い --end */

        // レイアウトでの可変項目の取得
      // add #10773 治療状況レイアウトマスタにて透析装置の項目0件だと、治療状況マップのスケジュールで患者が表示しない。 ztc start
      if(machineViewItems != null) {
      // add #10773 治療状況レイアウトマスタにて透析装置の項目0件だと、治療状況マップのスケジュールで患者が表示しない。 ztc end
        for (TreatmentStatusLayoutViewItems viewItem : machineViewItems) {
          Integer itemCd = null;

          // 可変項目情報を複製
          TreatmentStatusLayoutViewItems item = viewItem.clone();
          //add FNSI redmine 6946 劉祥霖 start
          if("1".equals(useClass)&&"dad".equals(modelName)){
            String a=machineNode.get("comFormatCd").toString();
            String b=item.getKeyName().substring(1, 2);
            if(!machineNode.get("comFormatCd").toString().substring(1, 2).equals(item.getKeyName().substring(0, 1))){
              continue;
            }
          }
          //add FNSI redmine 6946 劉祥霖 end
          // Jsonキー名の先頭文字[モニタデータ種別]判定
          if (item.getKeyName().substring(0, 1).equals(deviceType)) {
            // Jsonキー名の先頭文字[モニタデータ種別]を削除
            item.setKeyName(item.getKeyName().substring(1));
          }

          try {

            // テーブルのレコードデータからフィールドの値を取得
            String fieldValue = "";
            //del FNSI redmine 5742 劉祥霖 start
//            switch (viewItem.getTableName()) {
//              case MNI_MONITOR:
//                if (mniMonitor != null) {
//                  fieldValue = Util.getMniMonitorColumnData(mniMonitor, item.getColumnName()).toString();
//                }
//                break;
//
//              case MNT_MACHINE_STATE:
            //del FNSI redmine 5742 劉祥霖 end
                fieldValue = Util.getMachineStateColumnData(state, item.getColumnName()).toString();
            //del FNSI redmine 5742 劉祥霖 start
//                break;
//            }
            //del FNSI redmine 5742 劉祥霖 end
            String colValue = "";
            // 取得対象のJSON判定
            if (0 < item.getKeyName().length()) {
              // 取得したデータがjson形式である場合はここで、jsonからデータを取得
              colValue = getJsonNodeValue(fieldValue, item.getKeyName(), null);

              // 変換処理
              /* modify #6746 zhangruixue 2023-02-24 治療状況リスト、治療状況マップを開くのが遅い --start */
              colValue = convColValue(sysMonitorItemMap, deviceType, item, colValue, null);
              /* modify #6746 zhangruixue 2023-02-24 治療状況リスト、治療状況マップを開くのが遅い --end */
            } else {
              // 取得対象のデータがJSONでない場合、フィールドデータを返す値とする
              colValue = fieldValue;
            }

            // 取得した値がNullの場合空文字とする
            if (colValue == null) {
              colValue = "";
            }

            // エスケープ処理
            if (colValue.contains("\"")) {
              // ダブルクォーテーションをエスケープ
              colValue.replaceAll("\"", "\\\"");
            }

            machineNode.put("field_" + viewItem.getOrderNo().toString(), colValue);
          } catch (Exception e) {
            eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage("REST request error by get makeMachineNotBedJsonText : itemCd:" + itemCd
              + " -> value:" + e.getMessage());
            logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_TREATMENT_RECORD, SERVICE_NAME.REMS,
              null);
          }
        }
      // add #10773 治療状況レイアウトマスタにて透析装置の項目0件だと、治療状況マップのスケジュールで患者が表示しない。 ztc start
      }
      // add #10773 治療状況レイアウトマスタにて透析装置の項目0件だと、治療状況マップのスケジュールで患者が表示しない。 ztc end
        machineArrayNode.add(machineNode);
      }
    }
    eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("machineArrayNode is " + machineArrayNode.toString());
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_TREATMENT_RECORD, SERVICE_NAME.REMS, null);

    return machineArrayNode;
  }

  /**
   * 算出値など、テーブル名・フィールド名・JSONキー名だけでは値を取得できない項目に該当するか判定します。
   * ※getByItemCd()にてデータを取得する
   * @param itemCd
   * @return 該当する場合Trueを返す。
   */
  private boolean isCalcurationItem(Integer itemCd) {
    boolean rtn = false;
    if (itemCd == 4 // DW
        || itemCd == 5 // DWから
        || itemCd == 6 // 目標体重
        || itemCd == 7 // 目標体重から
        || itemCd == 8 // 透析開始
        || itemCd == 9 // 終了予測
        || itemCd == 10 // 終了予測(除水完了)
        || itemCd == 11 // 終了予測(透析終了)
        || itemCd == 112 // 終了予測(補液完了)
        || itemCd == 13 // 治療時間
        || itemCd == 15 // 遅れ時間
        || itemCd == 17 // 前血圧(最高)
        || itemCd == 18 // 前血圧(最低)
        || itemCd == 19 // 前血圧(平均)
        || itemCd == 20 // 前血圧
        || itemCd == 21 // 前脈拍
        || itemCd == 22 // 現在血圧
        || itemCd == 38 // 前体重-後体重
        || itemCd == 39 // 予想引き残し
        || itemCd == 40 // 引き残し
        || itemCd == 41 // 後血圧(最高)
        || itemCd == 42 // 後血圧(最低)
        || itemCd == 43 // 後血圧(平均)
        || itemCd == 44 // 後血圧
        || itemCd == 45 // 後脈拍
        || itemCd == 49 // 達成率
        || itemCd == 50 // 患者確認
        || itemCd == 52 // 終了予定
        || itemCd == 53 // 前回後体重
        || itemCd == 54 // 増加量
        || itemCd == 55 // 増加率
        || itemCd == 58 // 進捗率
        || itemCd == 60 // 治療日
        || itemCd == 61 // クール
        || itemCd == 62 // 回診状態
        || itemCd == 63 // 回診データ
        || itemCd == 64 // 投与状況
        || itemCd == 65 // 観察記録件数
        || itemCd == 66 // 最新愁訴
        || itemCd == 67 // 最新処置
        || itemCd == 68 // CTR
        || itemCd == 69 // 前体重風袋合計
        || itemCd == 70 // 後体重風袋合計
        || itemCd == 71 // 除水補正合計
        || itemCd == 72 // 再循環率有効値
        // 治療条件
        || itemCd == 73 // VA
        || itemCd == 74 // 除水量制限
        || itemCd == 75 // ダイアライザー
        || itemCd == 76 // 吸着カラム
        || itemCd == 77 // 1次膜
        || itemCd == 78 // 2次膜
        || itemCd == 79 // 穿刺針(A針)
        || itemCd == 80 // 穿刺針(V針)
        || itemCd == 81 // 穿刺針(SN)
        || itemCd == 82 // シングルニードル使用
        || itemCd == 83 // 血液回路
        || itemCd == 84 // 血流量
        || itemCd == 85 // 透析液
        || itemCd == 86 // 透析液流量
        || itemCd == 87 // 透析液量
        || itemCd == 88 // 透析液温度
        || itemCd == 89 // 補液
        || itemCd == 90 // 補液量
        || itemCd == 91 // 補液選択
        || itemCd == 92 // 補液使用数
        || itemCd == 93 // 補液温度
        || itemCd == 94 // 補液速度
        || itemCd == 95 // 抗凝固剤
        || itemCd == 96 // 抗凝固剤ワンショット量
        || itemCd == 97 // 抗凝固剤持続速度
        || itemCd == 98 // 抗凝固剤持続送料
        || itemCd == 99 // IP使用選択
        || itemCd == 100 // IPスタート
        || itemCd == 101 // IPワンショット量
        || itemCd == 102 // IP速度
        || itemCd == 103 // IP速度最大値
        || itemCd == 104 // IPワンショットスタート
        || itemCd == 105 // IP電源自動切
        || itemCd == 106 // IP電源自動切時間
        || itemCd == 107 // IP電源OKモニタ切
        || itemCd == 108 // IP電源OKモニタ切時間
      //add #11553 治療状況表示項目不足( 残り時間:113) zrx start
        || itemCd == 113 // 残り時間
      //add #11553 治療状況表示項目不足( 残り時間:113) zrx end
//        || itemCd >= 500 // 「mst_treatment_status_disp_item」以外
        || itemCd <= -10000 // 「sys_monitor_item」itemCd -10000以外
    ) {
      return true;
    }
    return rtn;
  }

  /**
   * 値を取得するために前回後体重が必要な項目か判定します。
   * @param itemCd
   * @return 前回後体重が必要な場合Trueを返す。
   */
  private boolean isNecessaryLastAfterWeight(Integer itemCd) {
    boolean rtn = false;
    // 「53:前回後体重」、「54:増加量」、「55:増加率」の場合前回後体重が必要
    if (itemCd == 53 || itemCd == 54 || itemCd == 55) {
      rtn = true;
    }
    return rtn;
  }

  /**
   * 値を取得するためにクールマスタ情報が必要な項目か判定します。
   * @param itemCd
   * @return クールマスタ情報が必要な場合Trueを返す。
   */
  private boolean isNecessaryMstKur(Integer itemCd) {
    boolean rtn = false;
    // 「8:透析開始」、「52:終了予定」の場合mst_kurが必要
    if (itemCd == 8 || itemCd == 52) {
      rtn = true;
    }
    return rtn;
  }

  /**
   * 値を取得するためにモニタ情報が必要な項目か判定します。
   * @param itemCd
   * @return モニタ情報が必要な場合Trueを返す。
   */
  private boolean isNecessaryMniMonitor(Integer itemCd) {
    boolean rtn = false;
    // 以下項目の場合はmni_monitorが必要
    if (itemCd == 9 // 終了予測
        || itemCd == 10 // 終了予測(除水完了)
        || itemCd == 11 // 終了予測(透析終了)
        || itemCd == 112 // 終了予測(補液完了)
        || itemCd == 15 // 遅れ時間
        || itemCd == 17 // 前血圧(最高)
        || itemCd == 18 // 前血圧(最低)
        || itemCd == 19 // 前血圧(平均)
        || itemCd == 20 // 前血圧
        || itemCd == 21 // 前脈拍
        || itemCd == 22 // 現在血圧
        || itemCd == 39 // 予想引き残し
        || itemCd == 41 // 後血圧(最高)
        || itemCd == 42 // 後血圧(最低)
        || itemCd == 43 // 後血圧(平均)
        || itemCd == 44 // 後血圧
        || itemCd == 45 // 後脈拍
        || itemCd == 49 // 達成率
        || itemCd == 56 // 血流量
        || itemCd == 57 // IP速度
        || itemCd == 58 // 進捗率
        //add #11553 治療状況表示項目不足( 残り時間:113) zrx start
        || itemCd == 113 // 残り時間
        //add #11553 治療状況表示項目不足( 残り時間:113) zrx end
//        || itemCd >= 500 // 「mst_treatment_status_disp_item」以外
        || itemCd <= -10000 // 「sys_monitor_item」itemCd -10000以外
    ) {
      rtn = true;
    }
    return rtn;
  }

  /**
   * 値を取得するために患者基本情報(pat_unique)が必要な項目か判定します。
   * @param itemCd
   * @return 患者基本情報が必要な場合Trueを返す。
   */
  private boolean isNecessaryPatUnique(Integer itemCd) {
    boolean rtn = false;
    // 以下項目の場合pat_uniqueが必要
    if (itemCd == 4 // DW
        || itemCd == 68 // CTR
    ) {
      rtn = true;
    }
    return rtn;
  }

  /**
   * 値を取得するために種別マスタ情報が必要な項目か判定します。
   * @param itemCd
   * @return 種別マスタ情報が必要な場合Trueを返す。
   */
  private boolean isNecessaryMstRoundType(Integer itemCd) {
    boolean rtn = false;
    // 「62:回診状態」の場合mst_round_typeが必要
    if (itemCd == 62) {
      rtn = true;
    }
    return rtn;
  }

  /**
   * 「sys_monitor_item」にて定義されている変換処理を行う
   * @param sysMonitorItemMap
   * @param moniDataType モニタデータ種別
   * @param itemCd 項目番号
   * @param colValue 変換前の値
   * @param viewItem 治療状況レイアウトビュー用のクラス
   * @return 返還後の値
   */
  private String convColValue(
      Map<String,SysMonitorItem> sysMonitorItemMap,
      String moniDataType,
      TreatmentStatusLayoutViewItems viewItem,
      String colValue, Map<String, JsonNode> jsonNodeMap) {

    String ret = colValue;

    try {
      // #9312 & #9216 ->「sys_monitor_item」定義判定 主キーに -10000 を減えて、itemCd にセットする。
      // 「sys_monitor_item」定義判定
      // if (500 <= viewItem.getDataClass()) {
      if (-10000 >= viewItem.getDataClass()) {

        // データ変換
        if (Objects.equals(viewItem.getConvType(), "1")) {
          /* modify #6746 zhangruixue 2023-02-24 治療状況リスト、治療状況マップを開くのが遅い --start */
          // 変換対象検索
//          SysMonitorItem item = sysMonitorItemList.stream()
//              .filter(state -> Objects.equals(state.getMoniDataNo(), moniDataType + viewItem.getKeyName()))
//              .findFirst()
//              .orElse(null);
          SysMonitorItem item = new SysMonitorItem();
          if(StringUtils.hasText(moniDataType + viewItem.getKeyName())){
              item = sysMonitorItemMap.get(moniDataType + viewItem.getKeyName());
          }else{
            item = null;
          }
          /* modify #6746 zhangruixue 2023-02-24 治療状況リスト、治療状況マップを開くのが遅い --end */
          if (item != null) {
            // 変換処理
            ret = getJsonNodeValue(item.getConvItem(), ret, jsonNodeMap);
          }
        }

        // 数値書式整形
        if ( Objects.equals( viewItem.getDataType(), "1" )
            || Objects.equals( viewItem.getDataType(), "2" )) {

          // 変換対象検索
//          SysMonitorItem item = sysMonitorItemList.stream()
//              .filter(state -> Objects.equals(state.getMoniDataNo(), moniDataType + viewItem.getKeyName()))
//              .findFirst()
//              .orElse(null);
          SysMonitorItem item = new SysMonitorItem();
          if(StringUtils.hasText(moniDataType + viewItem.getKeyName())){
            item = sysMonitorItemMap.get(moniDataType + viewItem.getKeyName());
          }else{
            item = null;
          }
          if (item != null) {
            // 変換処理
            ret = Util.getFormattedNumber( ret, item.getDecimalFigure());
          }
        }

        // 時分変換
        if (Objects.equals(viewItem.getDataType(), "3")) {
          if (StrUtils.isNumber(ret)) {
            Integer work = Integer.parseInt(ret);
            ret = Util.ElapsedMinutesToHHMM(work);
          }
        }
      }
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST request error by get convColValue : " + e.getMessage());
      logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_TREATMENT_RECORD, SERVICE_NAME.REMS, null);
    }
    return ret;
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
  // add #7660 2022/08/22 【デグレ】実績確定するまでの間は治療記録用紙に表示されない項目がある。 王永吉 start
  // mod #7660 2022/08/24 【デグレ】実績確定するまでの間は治療記録用紙に表示されない項目がある。 王永吉 start
  // public void MiddleCheck(OrdMain ordMain) {
  public void middleCheck(OrdMain ordMain) {
    //mod #10196 Ord_Material_Save operation 20240126 ztc start
    // one-line-coding style victim
    // mod 12250 ord_material_saveの処理を2回重複実行している zkm start
//    ordMaterialSaveService.batchProcessingData(
//      Collections.singletonList(
//        ordMaterialSaveService.updateOrdMaterialSaveByDiff(
//          new OrdMaterialSaveDto(
//            ordMain.getOrdNo(),
//            true,
//            true,
//            true,
//            true,
//            OrdMaterialSaveDto.RST_CLASS,
//            ordMain
//          )
//        )
//      )
//    );
    ordMaterialSaveService.bulkUpdateByOrdNoInCondMediEquipTreatment(Collections.singletonList(ordMain.getOrdNo()));
    // mod 12250 ord_material_saveの処理を2回重複実行している zkm end
    //mod #10196 Ord_Material_Save operation 20240126 ztc end
  }
  // add #7660 2022/08/22 【デグレ】実績確定するまでの間は治療記録用紙に表示されない項目がある。 王永吉 end

  // #10338 2024.03.27 mod 実績確定処理updateCheckAfterWeightを改修 TDC片口 start
//  /* add by sunmingyuan  2023-02-01 CodeOptimization  start */
//  @Override
//  @Transactional
//  public ResponseEntity<?> updateCheckAfterWeight(List<CheckAfterWeightRequest> request, NtssUser ntssUser, AllConfirmResponse allConfirmResponse) {
//    //add #9616 帳票印刷失敗通知がされない 李 start
//    boolean isSuccessAutoPrint = true;
//    // add #9616 帳票印刷失敗通知がされない 高　start
//    String reportName = "";
//    MstReport mr = new MstReport();
//    String rstTreatmentCd = null;
//    // add #9616 帳票印刷失敗通知がされない 高 2024/01/12　start
//    Long bedCd = Long.valueOf(0);
//    MstBed mstBed = new MstBed();
//    boolean autoPrintFlag = false;
//    // add #9616 帳票印刷失敗通知がされない 高 2024/01/12　end
//    // add #9616 帳票印刷失敗通知がされない 高　end
//    //add #9616 帳票印刷失敗通知がされない 李 end
//    if (request.size() != 0) {
//      try {
//        if (request.size() != 0) {
//          String facilityCd = ntssUser.getFacilityCd();
//          for (CheckAfterWeightRequest ordInfo : request) {
//            Long ordNo = ordInfo.getOrdNo();
//            OrdMainForWeightInd ord = ordMainDao.selectForWeightIndByOrdNo(ordNo);
//            // add #9616 帳票印刷失敗通知がされない 高　start
//            if (ord != null) {
//              if (ord.getRstTreatmentCd() != null) {
//                rstTreatmentCd = String.valueOf(ord.getRstTreatmentCd());
//              }
//              // add #9616 帳票印刷失敗通知がされない 高 2024/01/12　start
//              if (ord.getRstBedCd() != null) {
//                bedCd = ord.getRstBedCd();
//              }
//              // add #9616 帳票印刷失敗通知がされない 高 2024/01/12　end
//            }
//            // add #9616 帳票印刷失敗通知がされない 高 2024/01/17　start
//            // del #9616 帳票印刷失敗通知がされない 高 2024/01/25　start
////            try {
////              // add #9616 帳票印刷失敗通知がされない 高 2024/01/17　end
////              if(null != rstTreatmentCd){
////                MstTreatment mstTreatment = mstTreatmentDao.selectByCd(Integer.valueOf(rstTreatmentCd));
////                if (!StringUtils.isEmpty(mstTreatment.getReportIdAct())&&mstTreatment.getReportIdAct() != 0) {
////                  mr = mstReportDao.selectByCd((long) mstTreatment.getReportIdAct());
////                } else {
////                  FacilitySettingInfo facilitySettingInfo = mstFacilitySettingDao.getBySettingNoAndCd(ntssUser.getFacilityCd(), CoreConstant.FacilitySettingNo.DEFAULT_REPORT_TEMPLATE);
////                  // add #9616 帳票印刷失敗通知がされない 高 2024/01/17　start
////                  if (!StringUtils.isEmpty(facilitySettingInfo.getValue())) {
////                    // add #9616 帳票印刷失敗通知がされない 高 2024/01/17　end
////                    Long reportCd = Long.parseLong(facilitySettingInfo.getValue());
////                    if (reportCd != 0) {
////                      mr = mstReportDao.selectByCd(reportCd);
////                    }
////                  }
////                }
////                // add #9616 帳票印刷失敗通知がされない 高 2024/01/17　start
////              }
////              // add #9616 帳票印刷失敗通知がされない 高 2024/01/17　end
////              reportName = mr.getReportName();
////              // add #9616 帳票印刷失敗通知がされない 高 2024/01/17　start
////            } catch (Exception ex) {
////              autoPrintFlag = true;
////            }
//            // del #9616 帳票印刷失敗通知がされない 高 2024/01/25　end
//            // add #9616 帳票印刷失敗通知がされない 高 2024/01/25　start
//            reportName = autoPrintGetReportName(rstTreatmentCd,mr,ntssUser);
//            // add #9616 帳票印刷失敗通知がされない 高 2024/01/25　end
//            // add #9616 帳票印刷失敗通知がされない 高 2024/01/17　end
//
//            // add #9616 帳票印刷失敗通知がされない 高　end
//            if (AdminWebConstant.OrdMainConst.DialysisState.AFTER_WEIGHT.equals(ord.getRstDialysisState())) {
//
//              // 現患者チェック
//              List<MntMachineState> state = mntMachineStateDao.selectByOrdNo(facilityCd, ordNo);
//              if (!state.isEmpty()) {
//                // 現患者である場合
//                // オーダー番号から施設コード、デバイスエッジ番号を取得
//                DeviceEdgeOrderRequest req = new DeviceEdgeOrderRequest();
//                req.setDeviceEdgeNo(null);
//                req.setOrdNo(ordNo);
//                req.setMachineNo(null);
//                req.setFacilityCd(facilityCd);
//                DeviceEdgeOrderResponse res = new DeviceEdgeOrderResponse();
//                try {
//                  // 不足情報を補填
//                  DeviceEdgeOrderRequest targetInfo = deviceEdgeOrderService.findMissingData(req);
//                  // 治療状況確認指示(後体重確認)を通知
//                  //add FNSI修正 305 房 start
//                  OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
//                  if (Objects.equals(ord.getRstInputClass(), 1)) {
//                    res = deviceEdgeOrderService.orderCheckStatus(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo(), targetInfo.getMachineNo());
//                  }
//                  //add FNSI修正 305 房 end
//                } catch (Exception e) {
//                  EventLogMessage eventLogMessage = new EventLogMessage();
//                  eventLogMessage.setLogMessage(e.getMessage());
//                  logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, "");
//                  res.isSuccess = false;
//                  res.errorMessage = e.getMessage();
//                }
//              }
//            }
//          }
//        }
//        //更新処理
//        int rtn = updateCheckAfterWeight(request, ntssUser.getFacilityCd());
//        // add #9616 帳票印刷失敗通知がされない 高 2024/01/12　start
//        mstBed = mstBedDao.selectByBedCd(bedCd, AdminWebConstant.FlagType.FLAG_ON, AdminWebConstant.FlagType.FLAG_OFF);
//        if (!Objects.isNull(mstBed)) {
//          if (AdminWebConstant.FlagType.FLAG_ON.equals(mstBed.getIsAutoprintCommit())) {
//            // add #9616 帳票印刷失敗通知がされない 高 2024/01/12　end
//        // 自動印刷
//        allConfirmResponse.autoPrintResults = new ArrayList<AutoPrintService.AutoPrintResult>();
//        for (CheckAfterWeightRequest ordInfo : request) {
//          // add 9616 テンプレート繰返し時に元々値があるセルは上書きしないようにすること　吉 start
//          OrdMainForWeightInd ord = ordMainDao.selectForWeightIndByOrdNo(ordInfo.getOrdNo());
//          // add 9616 テンプレート繰返し時に元々値があるセルは上書きしないようにすること　吉 end
//
//          // add #9616 帳票印刷失敗通知がされない 高　start
//          if (ord != null) {
//            if (ord.getRstTreatmentCd() != null) {
//              rstTreatmentCd = String.valueOf(ord.getRstTreatmentCd());
//            }
//          }
//          // add #9616 帳票印刷失敗通知がされない 高 2024/01/17　start
//          // del #9616 帳票印刷失敗通知がされない 高 2024/01/25　start
////          try {
////            // add #9616 帳票印刷失敗通知がされない 高 2024/01/17　end
////            if(null != rstTreatmentCd){
////              MstTreatment mstTreatment = mstTreatmentDao.selectByCd(Integer.valueOf(rstTreatmentCd));
////              if (!StringUtils.isEmpty(mstTreatment.getReportIdAct())&&mstTreatment.getReportIdAct() != 0) {
////                mr = mstReportDao.selectByCd((long) mstTreatment.getReportIdAct());
////              } else {
////                FacilitySettingInfo facilitySettingInfo = mstFacilitySettingDao.getBySettingNoAndCd(ntssUser.getFacilityCd(), CoreConstant.FacilitySettingNo.DEFAULT_REPORT_TEMPLATE);
////                // add #9616 帳票印刷失敗通知がされない 高 2024/01/17　start
////                if (!StringUtils.isEmpty(facilitySettingInfo.getValue())) {
////                  // add #9616 帳票印刷失敗通知がされない 高 2024/01/17　end
////                  Long reportCd = Long.parseLong(facilitySettingInfo.getValue());
////                  if (reportCd != 0) {
////                    mr = mstReportDao.selectByCd(reportCd);
////                  }
////                }
////              }
////              // add #9616 帳票印刷失敗通知がされない 高 2024/01/17　start
////            }
////            // add #9616 帳票印刷失敗通知がされない 高 2024/01/17　end
////            reportName = mr.getReportName();
////            // add #9616 帳票印刷失敗通知がされない 高 2024/01/17　start
////          } catch (Exception ex) {
////            autoPrintFlag = true;
////          }
//          // del #9616 帳票印刷失敗通知がされない 高 2024/01/25　end
//          // add #9616 帳票印刷失敗通知がされない 高 2024/01/25　start
//          reportName = autoPrintGetReportName(rstTreatmentCd,mr,ntssUser);
//          // add #9616 帳票印刷失敗通知がされない 高 2024/01/25　end
//          // add #9616 帳票印刷失敗通知がされない 高 2024/01/17　end
//
//          // add #9616 帳票印刷失敗通知がされない 高　end
//
//          try {
//            AutoPrintService.AutoPrintResult printR = autoPrintService.reportAutoPrint(ordInfo.getOrdNo(), AutoPrintService.TimingEnum.commitEdition,
//              ntssUser.getUserId(), ntssUser.getUsername());
//            allConfirmResponse.autoPrintResults.add(printR);
//            // add FNSI-実績確定時自動印刷の修正 徐 start
//            // if (!printR.autoPrintErrorMessage.isEmpty()) {
//            if (!ObjectUtils.isEmpty(printR.autoPrintErrorMessage)) {
//              // add FNSI-実績確定時自動印刷の修正 徐 end
//              EventLogMessage eventLogMessage = new EventLogMessage();
//              eventLogMessage.setLogMessage(printR.autoPrintErrorMessage);
//              logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
//            }
//
//            //add #9616 帳票印刷失敗通知がされない 李 start
//            // mod 9616 テンプレート繰返し時に元々値があるセルは上書きしないようにすること　吉 start
//            // if(!printR.isSuccessAutoPrint){
//            if(!printR.isSuccessAutoPrint && !Objects.equals(ord.getRstInputClass(), 2)){
//              // mod 9616 テンプレート繰返し時に元々値があるセルは上書きしないようにすること　吉 end
//              isSuccessAutoPrint = printR.isSuccessAutoPrint;
//            }
//            //add #9616 帳票印刷失敗通知がされない 李 end
//          } catch (Exception ex) {
//            EventLogMessage eventLogMessage = new EventLogMessage();
//            eventLogMessage.setLogMessage(ex.getMessage());
//            logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
//            // add 9616 テンプレート繰返し時に元々値があるセルは上書きしないようにすること　吉 start
//            if( !Objects.equals(ord.getRstInputClass(), 2)){
//              // add 9616 テンプレート繰返し時に元々値があるセルは上書きしないようにすること　吉 end
//              AutoPrintService.AutoPrintResult printR = new AutoPrintService.AutoPrintResult();
//              printR.isAutoPrint = true;
//              printR.isSuccessAutoPrint = false;
//              printR.autoPrintErrorMessage = "帳票自動印刷失敗";
//              allConfirmResponse.autoPrintResults.add(printR);
//
//              //add #9616 帳票印刷失敗通知がされない 李 start
//              isSuccessAutoPrint = printR.isSuccessAutoPrint;
//              //add #9616 帳票印刷失敗通知がされない 李 end
//              // add 9423 テンプレート繰返し時に元々値があるセルは上書きしないようにすること　吉 start
//            }
//            // add 9423 テンプレート繰返し時に元々値があるセルは上書きしないようにすること　吉 end
//          }
//        }
//
//        //add #9616 帳票印刷失敗通知がされない 李 start
//        if(!isSuccessAutoPrint){
//          // mod #9616 帳票印刷失敗通知がされない 高　start
////          saveNotiMessage("治療経過表","実際確認",ntssUser.getFacilityCd());
//          // mod #9616 帳票印刷失敗通知がされない 高 2024/01/25　start
//          sendFailureNotification(reportName,ntssUser);
////            saveNotiMessage("治療経過表",reportName,ntssUser.getFacilityCd());
//          // mod #9616 帳票印刷失敗通知がされない 高 2024/01/25　end
//          // mod #9616 帳票印刷失敗通知がされない 高　end
//            // add #9616 帳票印刷失敗通知がされない 高 2024/01/12　start
//          // del #9616 帳票印刷失敗通知がされない 高 2024/01/25　start
////              }
//          // del #9616 帳票印刷失敗通知がされない 高 2024/01/25　end
//            }
//            // add #9616 帳票印刷失敗通知がされない 高 2024/01/12　end
//          }
//        }
//        //add #9616 帳票印刷失敗通知がされない 李 end
//        return new ResponseEntity<>(rtn, HttpStatus.OK);
//      } catch (Exception e) {
//        // 例外発生時、BAD_REQUESTを返す
//        EventLogMessage eventLogMessage = new EventLogMessage();
//        eventLogMessage.setLogMessage("REST request error by updateCheckAfterWeight: "+ e.getMessage());
//        logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
//        allConfirmResponse.errorMessage = "データ更新エラー";
//        allConfirmResponse.errDetail = e.getMessage();
//
//        //add #9616 帳票印刷失敗通知がされない 李 start
//        // add #9616 帳票印刷失敗通知がされない 高 2024/01/12　start
//        if (!Objects.isNull(mstBed)) {
//          if (AdminWebConstant.FlagType.FLAG_ON.equals(mstBed.getIsAutoprintCommit())) {
//            // add #9616 帳票印刷失敗通知がされない 高 2024/01/12　end
//            // del #9616 帳票印刷失敗通知がされない 高 2024/01/25　start
////            if (!StringUtils.isEmpty(reportName)) {
//            // del #9616 帳票印刷失敗通知がされない 高 2024/01/25　end
//        // mod #9616 帳票印刷失敗通知がされない 高　start
////        saveNotiMessage("治療経過表","実際確認",ntssUser.getFacilityCd());
//            // mod #9616 帳票印刷失敗通知がされない 高 2024/01/25　start
//            sendFailureNotification(reportName,ntssUser);
////              saveNotiMessage("治療経過表",reportName,ntssUser.getFacilityCd());
//            // mod #9616 帳票印刷失敗通知がされない 高 2024/01/25　end
//              // mod #9616 帳票印刷失敗通知がされない 高　end
//              // add #9616 帳票印刷失敗通知がされない 高 2024/01/12　start
//            // del #9616 帳票印刷失敗通知がされない 高 2024/01/25　start
////            }
//            // del #9616 帳票印刷失敗通知がされない 高 2024/01/25　end
//          }
//          // add #9616 帳票印刷失敗通知がされない 高 2024/01/12　end
//        }
//        //add #9616 帳票印刷失敗通知がされない 李 end
//
//        return new ResponseEntity<>(allConfirmResponse, HttpStatus.BAD_REQUEST);
//      }
//    } else {
//      // リクエスト内容がNullまたは空の場合、BAD_REQUESTを返す
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage("REST request error by get CheckMediDone : recieve data is Null or Empty.");
//      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
//      allConfirmResponse.errorMessage = "対象データなし";
//
//      // add #9616 帳票印刷失敗通知がされない 高 2024/01/17　start
//      // del #9616 帳票印刷失敗通知がされない 高 2024/01/25　start
////      try {
////        if(!StringUtils.isEmpty(rstTreatmentCd)) {
////          // add #9616 帳票印刷失敗通知がされない 高 2024/01/17　end
////          // add #9616 帳票印刷失敗通知がされない 高　start
////          MstTreatment mstTreatment = mstTreatmentDao.selectByCd(Integer.valueOf(rstTreatmentCd));
////          if (!StringUtils.isEmpty(mstTreatment.getReportIdAct())&&mstTreatment.getReportIdAct() != 0) {
////            mr = mstReportDao.selectByCd((long) mstTreatment.getReportIdAct());
////          } else {
////            FacilitySettingInfo facilitySettingInfo = mstFacilitySettingDao.getBySettingNoAndCd(ntssUser.getFacilityCd(), CoreConstant.FacilitySettingNo.DEFAULT_REPORT_TEMPLATE);
////            // add #9616 帳票印刷失敗通知がされない 高 2024/01/17　start
////            if (!StringUtils.isEmpty(facilitySettingInfo.getValue())) {
////              // add #9616 帳票印刷失敗通知がされない 高 2024/01/17　end
////              Long reportCd = Long.parseLong(facilitySettingInfo.getValue());
////              if (reportCd != 0) {
////                mr = mstReportDao.selectByCd(reportCd);
////                // add #9616 帳票印刷失敗通知がされない 高 2024/01/17　start
////              }
////            }
////          }
////          reportName = mr.getReportName();
////          // add #9616 帳票印刷失敗通知がされない 高 2024/01/17　end
////        }
////        // add #9616 帳票印刷失敗通知がされない 高 2024/01/17　start
////      } catch (Exception ex) {
////        saveNotiMessage("治療経過表","テンプレートがない",ntssUser.getFacilityCd());
////      }
//      // del #9616 帳票印刷失敗通知がされない 高 2024/01/25　end
//      // add #9616 帳票印刷失敗通知がされない 高 2024/01/25　start
//      reportName = autoPrintGetReportName(rstTreatmentCd,mr,ntssUser);
//      // add #9616 帳票印刷失敗通知がされない 高 2024/01/25　end
//      // add #9616 帳票印刷失敗通知がされない 高 2024/01/17　end
//
//      // add #9616 帳票印刷失敗通知がされない 高 2024/01/12　start
//      if (!Objects.isNull(mstBed)) {
//        if (AdminWebConstant.FlagType.FLAG_ON.equals(mstBed.getIsAutoprintCommit())) {
//          // add #9616 帳票印刷失敗通知がされない 高 2024/01/12　end
//      // add #9616 帳票印刷失敗通知がされない 高　end
//      //add #9616 帳票印刷失敗通知がされない 李 start
//          // del #9616 帳票印刷失敗通知がされない 高 2024/01/25　start
////      if (!StringUtils.isEmpty(reportName)) {
//          // del #9616 帳票印刷失敗通知がされない 高 2024/01/25　end
//        // mod #9616 帳票印刷失敗通知がされない 高　start
////      saveNotiMessage("治療経過表","実際確認",ntssUser.getFacilityCd());
//          // mod #9616 帳票印刷失敗通知がされない 高 2024/01/25　start
//          sendFailureNotification(reportName,ntssUser);
////        saveNotiMessage("治療経過表",reportName,ntssUser.getFacilityCd());
//          // mod #9616 帳票印刷失敗通知がされない 高 2024/01/25　end
//        // mod #9616 帳票印刷失敗通知がされない 高　end
//          // del #9616 帳票印刷失敗通知がされない 高 2024/01/25　start
////      }
//          // del #9616 帳票印刷失敗通知がされない 高 2024/01/25　end
//      //add #9616 帳票印刷失敗通知がされない 李 end
//          // add #9616 帳票印刷失敗通知がされない 高 2024/01/12　start
//        }
//      }
//      // add #9616 帳票印刷失敗通知がされない 高 2024/01/12　end
//
//      return new ResponseEntity<>(allConfirmResponse, HttpStatus.BAD_REQUEST);
//    }
//  }
//  /* add by sunmingyuan  2023-02-01 CodeOptimization  end */

  @Override
  public TreatmentStatusUpdateResponse updateCheckAfterWeightConfirm(List<CheckAfterWeightRequest> request, String facilityCd){
    TreatmentStatusUpdateResponse ret = new TreatmentStatusUpdateResponse();
    for(CheckAfterWeightRequest req : request) {
      // #10337 2024.04.25 add 明示的トランザクション TDC片口 start
      // トランザクション開始
      TransactionDefinition def = new DefaultTransactionDefinition();
      TransactionStatus status = transactionManager.getTransaction(def);
      // #10337 2024.04.25 add 明示的トランザクション TDC片口 end
      try {
        UpdateStateAndEdgeOrderResponse r = updateStateAndEdgeOrder(req, facilityCd);
        if (r != UpdateStateAndEdgeOrderResponse.success) {
          ret.isSuccess = false;
        }
        // #10337 2024.04.25 add 明示的トランザクション TDC片口 start
        // 例外なしで抜けてきたならばコミット
        transactionManager.commit(status);
        // #10337 2024.04.25 add 明示的トランザクション TDC片口 end
      } catch (Exception e) {
        // #10337 2024.04.25 add 明示的トランザクション TDC片口 start
        transactionManager.rollback(status);
        // #10337 2024.04.25 add 明示的トランザクション TDC片口 end
        ret.isSuccess = false;
        ret.errorMessage = e.getMessage();
      }
    }
    return ret;
  }

  private enum UpdateStateAndEdgeOrderResponse{
    success,
    failUpdate,
    failOrder
  }

  /**
   * rst_dialysis_stateの更新とDEへの通知を行う
   * @param request リクエストパラメータ
   * @param facilityCd 施設コード
   * @return 0: 成功, -1: 更新失敗
   */
  private UpdateStateAndEdgeOrderResponse updateStateAndEdgeOrder(CheckAfterWeightRequest request, String facilityCd) {

    TreatmentStatusUpdateResponse ret = new TreatmentStatusUpdateResponse();
    ret.isSuccess = true;
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setFacilityCd(facilityCd);

    Long ordNo = request.getOrdNo();
    OrdMain ord = this.ordMainDao.selectByOrdNo(ordNo);
    // 元が後体重測定済み状態ならばtrue
    boolean isBaseStateAfterWeight = AdminWebConstant.OrdMainConst.DialysisState.AFTER_WEIGHT.equals(ord.getRstDialysisState());

    // #10337 2024.04.25 add 変更履歴保存のため既存コード移植 TDC片口 start
    // add FNSI-改修内容追加OrdMain履歴 付 start
    getHistory(ordNo);
    // mangoDb-updateCheckAfterWeight-insertSuccess
    // add FNSI-改修内容追加OrdMain履歴 付 end

    // DB更新ログ出力ロジック wangzuo Start
    String tableNameCheck = "ord_main";
    // SQL検索条件
    StringBuffer wheresCheck = new StringBuffer();
    wheresCheck.append(" WHERE\n");
    wheresCheck.append(" ord_no = ").append(ordNo).append("\n");
    // logCommon設定
    DataUpdateLogCommonNew logCommonCheck = getLogCommon(tableNameCheck, wheresCheck, eventLogMessage);
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResultCheck = logCommonCheck.setInfo();
    // DB更新ログ出力ロジック wangzuo End
    // #10337 2024.04.25 add 変更履歴保存のため既存コード移植 TDC片口 end

    // #10337 2024.05.16 mod 治療ステータスと確定フラグのみ更新する TDC片口 start
//    // rst_dialysis_stateを"6"に更新する
//    int updateRet = this.ordMainDao.updateRstDialysisState(ordNo, AdminWebConstant.OrdMainConst.DialysisState.PAST_RECORD);
    // rst_dialysis_stateを"6"に更新、確定フラグを立てる
    int updateRet = this.ordMainDao.updateDialysisStateFinishBeforeEditionUp(ordNo);
    // #10337 2024.05.16 mod 治療ステータスと確定フラグのみ更新する TDC片口 end

    if (updateRet <= 0) {
      eventLogMessage.setLogMessage("rst_dialysis_state更新対象無し ord_no: " + ordNo);
      logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, "");
      return UpdateStateAndEdgeOrderResponse.failUpdate;
    }

    // #10337 2024.04.25 add 変更履歴保存のため既存コード移植 TDC片口 start
    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResultCheck) {
      logCommonCheck.updateLog();
    }
    // DB更新ログ出力ロジック wangzuo End
    // #10337 2024.04.25 add 変更履歴保存のため既存コード移植 TDC片口 end

    // 元が後体重測定済み状態ならばDEに通知を行う必要がある可能性がある
    if (isBaseStateAfterWeight) {

      // 現患者チェック
      List<MntMachineState> state = mntMachineStateDao.selectByOrdNo(facilityCd, ordNo);
      if (!state.isEmpty()) {
        // 現患者である場合
        // オーダー番号から施設コード、デバイスエッジ番号を取得
        DeviceEdgeOrderRequest req = new DeviceEdgeOrderRequest();
        req.setDeviceEdgeNo(null);
        req.setOrdNo(ordNo);
        req.setMachineNo(null);
        req.setFacilityCd(facilityCd);
        try {
          // 不足情報を補填
          DeviceEdgeOrderRequest targetInfo = deviceEdgeOrderService.findMissingData(req);

          // #10457 2024.06.18 add デバイスエッジに通知タイミングで現患者クリアを実施 TDC高村 start
          MstMachine mstMachine = mstMachineDao.selectByMachineNo(targetInfo.getMachineNo());
          MstComsvSetting mstComsv = mstComsvSettingDao.selectByCd(facilityCd, mstMachine.getDeviceEdgeNo());
          if (mstComsv.getPatTiming().equals("1")) {
            // 現患者クリア処理実施
            Timestamp upDate = new Timestamp(System.currentTimeMillis());
            int retCnt = mntMachineStateDao.updateCurrentPatClear(facilityCd, mstMachine.getMachineTypeCd(), mstMachine.getMachineSerial(), upDate);
            if (1 != retCnt) {
              // 処理件数が1件でない場合は失敗
              eventLogMessage.setLogMessage("現患者クリア処理失敗");
              logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, "");
              return UpdateStateAndEdgeOrderResponse.failUpdate;
            }
          }
          // #10457 2024.06.18 add デバイスエッジに通知タイミングで現患者クリアを実施 TDC高村 end

          eventLogMessage.setLogMessage("現患者なので後体重確認通知を送る ord_no: " + ordNo + ", device_edge_no: " + targetInfo.getDeviceEdgeNo() + ", machine_no: " + targetInfo.getMachineNo());
          logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, "");

          // 治療状況確認指示(後体重確認)を通知
          deviceEdgeOrderService.orderCheckStatus(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo(), targetInfo.getMachineNo());

        } catch (Exception e) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          if (facilityCd != null ) {
            eventLogMessage.setFacilityCd(facilityCd);
          }
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
          logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, "");
          return UpdateStateAndEdgeOrderResponse.failOrder;
        }
      }
    }
    eventLogMessage.setLogMessage("rst_dialysis_stateの更新とDEへの後体重確認通知完了 ord_no: " + ordNo);
    logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, "");
    return UpdateStateAndEdgeOrderResponse.success;
  }
  // #10338 2024.03.27 mod 実績確定処理updateCheckAfterWeightを改修 TDC片口 end

  // #10338 2024.03.27 del DialysisConfirmServiceImplへ移動 TDC片口 start
//  //add #9616 帳票印刷失敗通知がされない 李 start
//  private void saveNotiMessage(String reportType, String reportName, String facilityCd){
//    if (org.apache.commons.lang3.StringUtils.isNotBlank(reportType) && org.apache.commons.lang3.StringUtils.isNotBlank(reportName)){
//      SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
//      JSONObject replaceData = new JSONObject();
//      replaceData.put("REPORTTYPE", reportType);
//      replaceData.put("REPORTNAME", reportName);
//      replaceData.put("UP_DATE", sdf.format(new Date()));
//      JSONObject jsonBody = new JSONObject();
//      jsonBody.put("notificationNo", CoreConstant.NotificationDefinition.PRINT_FAIL);
//      jsonBody.put("facilityCd", facilityCd);
//      String base64replaceData = new String(Base64.getEncoder().encode(replaceData.toString().getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8);
//      jsonBody.put("replaceData", base64replaceData);
//      saveNotiMessage(jsonBody);
//    }
//  }
//
//  private void saveNotiMessage(JSONObject jsonBody){
//    try{
//      URI uri = new URI(webApi);
//      RestTemplate rt = new RestTemplate();
//      RequestEntity<String> request = RequestEntity
//        .post(uri)
//        .contentType(MediaType.APPLICATION_JSON)
//        .header("SSECCAYEK", "NTSS-NKK-ESM-TDC-YSK")
//        .body(jsonBody.toString());
//
//      ResponseEntity<String> response = rt.exchange(request, String.class);
//      String s = "";
//    }catch (URISyntaxException ureE){
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
//    }
//  }
//  //add #9616 帳票印刷失敗通知がされない 李 end
  // #10338 2024.03.27 del DialysisConfirmServiceImplへ移動 TDC片口 end

  /* add by sunmingyuan  2023-02-01 CodeOptimization  start */
  @Override
  @Transactional
  public ResponseEntity<TreatmentStatusUpdateResponse> updateDeleteRecord(DeleteRecordRequest request, NtssUser ntssUser) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to delete records");
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);
    try {
      // 更新処理
      Long ordNo = request.getOrdNo();
      String facilityCd = ntssUser.getFacilityCd();

      // add FNSI-バグ #7161 通信サーバ 高 start
      // オーダー番号から施設コード、デバイスエッジ番号を取得
      DeviceEdgeOrderRequest req = new DeviceEdgeOrderRequest();
      req.setDeviceEdgeNo(null);
      req.setOrdNo(ordNo);
      req.setMachineNo(null);
      req.setFacilityCd(facilityCd);
      DeviceEdgeOrderResponse res = new DeviceEdgeOrderResponse();
      // 不足情報を補填
      DeviceEdgeOrderRequest targetInfo = deviceEdgeOrderService.findMissingData(req);
      // add FNSI-バグ #7161 通信サーバ 高 end

      //mod FNSI 401対応 房 start
      TreatmentStatusUpdateResponse response = deleteUnknownPatRecord(ordNo, facilityCd);
      //mod FNSI 401対応 房 end
      if (response.isSuccess) {
        // 現患者チェック
        List<MntMachineState> state = mntMachineStateDao.selectByOrdNo(facilityCd, ordNo);
        if (!state.isEmpty()) {
          // 現患者である場合
          // オーダー番号から施設コード、デバイスエッジ番号を取得
          // del FNSI-バグ #7161 通信サーバ 高 start
//          DeviceEdgeOrderRequest req = new DeviceEdgeOrderRequest();
//          req.setDeviceEdgeNo(null);
//          req.setOrdNo(ordNo);
//          req.setMachineNo(null);
//          req.setFacilityCd(facilityCd);
//          DeviceEdgeOrderResponse res = new DeviceEdgeOrderResponse();
          try {
            // 不足情報を補填
//            DeviceEdgeOrderRequest targetInfo = deviceEdgeOrderService.findMissingData(req);
            // del FNSI-バグ #7161 通信サーバ 高 end
            // #10457 2024.06.18 mod デバイスエッジに通知タイミングで現患者クリアを実施 TDC高村 start
            // // 後体重測定指示(後体重測定)を通知
            // res = deviceEdgeOrderService.orderAfterWeight(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo(), targetInfo.getMachineNo());
            // // 治療状況確認指示(後体重確認)を通知
            // res = deviceEdgeOrderService.orderCheckStatus(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo(), targetInfo.getMachineNo());
            MstMachine mstMachine = mstMachineDao.selectByMachineNo(targetInfo.getMachineNo());
            // 現患者クリア処理実施
            Timestamp upDate = new Timestamp(System.currentTimeMillis());
            int retCnt = mntMachineStateDao.updateCurrentPatClear(facilityCd, mstMachine.getMachineTypeCd(), mstMachine.getMachineSerial(), upDate);
            if (1 != retCnt) {
              // 処理件数が1件でない場合は失敗
              res.isSuccess = false;
              res.errorMessage = "現患者クリア処理失敗";
              eventLogMessage.setLogMessage(res.errorMessage);
              logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
            } else {
              // 後体重測定指示(後体重測定)を通知
              res = deviceEdgeOrderService.orderAfterWeight(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo(), targetInfo.getMachineNo());
              // 治療状況確認指示(後体重確認)を通知
              res = deviceEdgeOrderService.orderCheckStatus(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo(), targetInfo.getMachineNo());
            }
            // #10457 2024.06.18 mod デバイスエッジに通知タイミングで現患者クリアを実施 TDC高村 end
            // add FNSI-バグ #7161 通信サーバ 高 start
            // 次患者情報転送指示を通知
            res = deviceEdgeOrderService.orderSendNextPat(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo(), targetInfo.getMachineNo(), targetInfo.getOrdNo());
            // add FNSI-バグ #7161 通信サーバ 高 end
          } catch (Exception e) {
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
            eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
            if (facilityCd != null) {
              eventLogMessage.setFacilityCd(facilityCd);
            }
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
            logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
            res.isSuccess = false;
            res.errorMessage = e.getMessage();
          }
        }
        return new ResponseEntity<>(response, HttpStatus.OK);
      } else {
        // 更新処理ができなかった場合
        eventLogMessage.setLogMessage("Exception message : "+ response.errorMessage);
        logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);
        return new ResponseEntity<>(new TreatmentStatusUpdateResponse(response.errorMessage),
          HttpStatus.BAD_REQUEST);
      }
    } catch (Exception e) {

      // 更新処理ができなかった場合
      eventLogMessage.setLogMessage("Exception message : "+ e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(new TreatmentStatusUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()),
        HttpStatus.BAD_REQUEST);
    }
  }
  /* add by sunmingyuan  2023-02-01 CodeOptimization  end */
//add FNSI-redmine 8315 ljx　start(既存の指示作成の処理に参照)
  /**
   * レセ値取得
   *
   * @param mstMedicine 通常薬剤情報
   * @param indRstValue 指示・実績値
   */
  public String receiptValueSet(MstMedicine mstMedicine,
                              String indRstValue) {
    // レセ単位小数部桁数
    if (null != mstMedicine) {
      int point = 0;
      if (mstMedicine.getUnitDecimalPointSecond() != null) {
        point = mstMedicine.getUnitDecimalPointSecond();
      }
      // mod 「指示・実績値」の値の保存不正を修正する。 dengshen start
      // String receiptValue = BigDecimal.ZERO.setScale(point, BigDecimal.ROUND_HALF_UP).toString();
      String receiptValue = BigDecimal.ZERO.setScale(point, BigDecimal.ROUND_HALF_UP).toPlainString();
      // mod 「指示・実績値」の値の保存不正を修正する。 dengshen start
      switch (mstMedicine.getIsExchange()) {
        // 固定
        case "2":
          // レセ換算値
          if (mstMedicine.getUnitConvertedAmountSecond() != null && BigDecimal.ZERO.compareTo(mstMedicine.getUnitConvertedAmountSecond()) != 0) {
            // mod 「指示・実績値」の値の保存不正を修正する。 dengshen start
            // receiptValue = mstMedicine.getUnitConvertedAmountSecond().setScale(point).toString();
            receiptValue = mstMedicine.getUnitConvertedAmountSecond().setScale(point, RoundingMode.HALF_UP).toPlainString();
            // mod 「指示・実績値」の値の保存不正を修正する。 dengshen end
          }
          break;
        // 換算
        case "0":
          // 指示基準数量レセ換算値がnull以外の場合
          if (mstMedicine.getUnitConvertedAmount() != null && BigDecimal.ZERO.compareTo(mstMedicine.getUnitConvertedAmount()) != 0 &&
            mstMedicine.getUnitConvertedAmountSecond() != null && BigDecimal.ZERO.compareTo(mstMedicine.getUnitConvertedAmountSecond()) != 0) {
            BigDecimal indRstValue0 = new BigDecimal(indRstValue);
            BigDecimal reSeNum0 = indRstValue0.divide(mstMedicine.getUnitConvertedAmount(), point, BigDecimal.ROUND_HALF_UP)
              .multiply(mstMedicine.getUnitConvertedAmountSecond());
            // mod 「指示・実績値」の値の保存不正を修正する。 dengshen start
            // receiptValue = reSeNum0.setScale(point).toString();
            receiptValue = reSeNum0.setScale(point, RoundingMode.HALF_UP).toPlainString();
            // mod 「指示・実績値」の値の保存不正を修正する。 dengshen end
            // }
          }
          break;
        // 残量破棄
        case "1":
            if (mstMedicine.getUnitConvertedAmount() != null && BigDecimal.ZERO.compareTo(mstMedicine.getUnitConvertedAmount()) != 0 &&
            mstMedicine.getUnitConvertedAmountSecond() != null && BigDecimal.ZERO.compareTo(mstMedicine.getUnitConvertedAmountSecond()) != 0) {
            BigDecimal indRstValue1 = new BigDecimal(indRstValue);
            BigDecimal reSeNum1 = indRstValue1.divide(mstMedicine.getUnitConvertedAmount(), 0, BigDecimal.ROUND_UP)
              .multiply(mstMedicine.getUnitConvertedAmountSecond());
            // mod 「指示・実績値」の値の保存不正を修正する。 dengshen start
            // receiptValue = reSeNum1.setScale(point).toString();
            receiptValue = reSeNum1.setScale(point, RoundingMode.HALF_UP).toPlainString();
            // mod 「指示・実績値」の値の保存不正を修正する。 dengshen end
          }
          break;
      }
      return receiptValue;
    } else {
      // レセ値
      return null;
    }
  }
  //add FNSI-redmine 8315 ljx　end

  protected final <T> List<T> removeDuplicates(List<T> list) {
    return new ArrayList<>(new LinkedHashSet<>(list));
  }

  // #10338 2024.03.27 del DialysisConfirmServiceImplへ移動 TDC片口 start
//  // add #9616 帳票印刷失敗通知がされない 高 2024/01/25　start
//  /**
//   * 400および117からReportCdでReportNameを取ります。(実際確認)
//   *
//   * @param rstTreatmentCd
//   * @param mr
//   * @param ntssUser
//   * @return 帳票名です.
//   *
//   * */
//  private String autoPrintGetReportName(String rstTreatmentCd,MstReport mr,NtssUser ntssUser){
//    boolean getReportNameFlag = true;
//    String reportName = "";
//    try {
//      if(!StringUtils.isEmpty(rstTreatmentCd)){
//        getReportNameFlag = true;
//        MstTreatment mstTreatment = mstTreatmentDao.selectByCd(Integer.valueOf(rstTreatmentCd));
//        if (!StringUtils.isEmpty(mstTreatment.getReportIdAct())) {
//          // 400
//          // 実際確認ReportName取得します。
//          mr = mstReportDao.selectByCd((long) mstTreatment.getReportIdAct());
//        } else {
//          // 117
//          getReportNameFlag = false;
//          FacilitySettingInfo facilitySettingInfo = mstFacilitySettingDao.getBySettingNoAndCd(ntssUser.getFacilityCd(), CoreConstant.FacilitySettingNo.DEFAULT_REPORT_TEMPLATE);
//          if (!StringUtils.isEmpty(facilitySettingInfo.getValue())) {
//            Long reportCd = Long.parseLong(facilitySettingInfo.getValue());
//            if (reportCd != 0) {
//              mr = mstReportDao.selectByCd(reportCd);
//            }
//          }
//        }
//      }
//    } catch (Exception ex) {
//      // 400 -> errorの場合
//      if (getReportNameFlag) {
//        try {
//          // 117
//          FacilitySettingInfo facilitySettingInfo = mstFacilitySettingDao.getBySettingNoAndCd(ntssUser.getFacilityCd(), CoreConstant.FacilitySettingNo.DEFAULT_REPORT_TEMPLATE);
//          if (!StringUtils.isEmpty(facilitySettingInfo.getValue())) {
//            Long reportCd = Long.parseLong(facilitySettingInfo.getValue());
//            if (reportCd != 0) {
//              mr = mstReportDao.selectByCd(reportCd);
//            }
//          }
//        } catch (Exception ex1){
//        }
//      }
//    } finally {
//      if (!StringUtils.isEmpty(mr) && !StringUtils.isEmpty(mr.getReportName())) {
//        reportName = mr.getReportName();
//      }
//    }
//    return reportName;
//  }
//
//  /**
//   * 失敗通知を送ります.
//   *
//   * @param reportName
//   * @param ntssUser
//   *
//   * */
//  private void sendFailureNotification(String reportName,NtssUser ntssUser){
//    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
//    JSONObject replaceData = new JSONObject();
//    replaceData.put("REPORTTYPE", "治療経過表");
//    replaceData.put("REPORTNAME", reportName);
//    replaceData.put("UP_DATE", sdf.format(new Date()));
//    JSONObject jsonBody = new JSONObject();
//    jsonBody.put("notificationNo", CoreConstant.NotificationDefinition.PRINT_FAIL);
//    jsonBody.put("facilityCd", ntssUser.getFacilityCd());
//    // 変換用文字列のエンコード処理(UTF-8)
//    String base64replaceData = new String(Base64.getEncoder().encode(replaceData.toString().getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8);
//    jsonBody.put("replaceData", base64replaceData);
//    saveNotiMessage(jsonBody);
//  }
//  // add #9616 帳票印刷失敗通知がされない 高 2024/01/25　end

  // #10338 2024.03.27 del DialysisConfirmServiceImplへ移動 TDC片口 end

  // #9312 Add Start
  /**
   * 治療状況モニタデータ収集
   * @param facilityCd  施設コード
   * @param ordNoList   検索オーダ番号範囲
   * @return   モニタデータ
   */
  private List<RoughMonitorData> assenbleMniDatasByOrdNos(String facilityCd, List<Long> ordNoList) {
    /* Getting Rough range Monitor data result, this results was grouped by ordNo then sorted by occurDate(or update), */
    /*   but each record contains all data. So   */
    // TODO このようなクエリを使った結果は良くなく、私がサボった結果です。
    List<MniMonitor> roughResults = this.mniMonitorDao.selectTreatmentMonitorDataByOrdNo(facilityCd, ordNoList);
    if (CollectionUtils.isNotEmpty(roughResults)) {
      return roughResults.stream().map(RoughMonitorData::new).toList();
    } else {
      return Collections.emptyList();
    }

  }
  // #9312 Add End
}
