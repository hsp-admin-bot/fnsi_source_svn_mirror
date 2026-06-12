package jp.co.nikkiso.ntss.admin_web.service;


import jp.co.nikkiso.ntss.core.config.PersonalDb;
import tools.jackson.core.JacksonException;
import tools.jackson.core.type.TypeReference;
import tools.jackson.databind.DeserializationFeature;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;
import com.google.common.collect.Lists;
import com.mongodb.BasicDBObject;
import com.mongodb.client.FindIterable;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.InOutVisitHistoryInfoMoveInOut;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.PatInfoMoveInOut;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.request.patientCapture.JournalCreateRequestPayload;
import jp.co.nikkiso.ntss.admin_web.response.patInfo.PatByFCAndPIdsResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.deviceEdgeOrder.DeviceEdgeOrderService;
import jp.co.nikkiso.ntss.admin_web.service.indHistory.IndHistory;
import jp.co.nikkiso.ntss.admin_web.service.indHistory.IndHistoryService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.master.wheelChair.MstWheelChairService;
import jp.co.nikkiso.ntss.admin_web.service.notificationMessage.NotificationMessageService;
import jp.co.nikkiso.ntss.admin_web.service.patHistory.PatInsuranceHistory;
import jp.co.nikkiso.ntss.admin_web.service.patHistory.PatMainHistory;
import jp.co.nikkiso.ntss.admin_web.service.patHistory.PatPersonalMainHistory;
import jp.co.nikkiso.ntss.admin_web.service.patHistory.PatUniqueHistory;
import jp.co.nikkiso.ntss.admin_web.service.patHistory.patUniqueHistoryDetail.InOutVisitHistoryInfo;
import jp.co.nikkiso.ntss.admin_web.service.patHistory.patUniqueHistoryDetail.MedicalHstInfo;
import jp.co.nikkiso.ntss.admin_web.service.patHistory.patUniqueHistoryDetail.PhysicalInfo;
import jp.co.nikkiso.ntss.admin_web.service.utils.DateIsoUtils;
import jp.co.nikkiso.ntss.admin_web.service.utils.DateTimeUtils;
import jp.co.nikkiso.ntss.admin_web.service.utils.MasterCacheHandler;
import jp.co.nikkiso.ntss.admin_web.web.rest.OrdMainResource;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallCommonUtil;
import jp.co.nikkiso.ntss.admin_web.web.service.MaterialsSharingPatientInformation.MaterialsSharingPatientInfomationService;
import jp.co.nikkiso.ntss.api.service.deathRelatedProcess.DeathServiceImpl;
import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.FacilitySettingNo;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.NotificationDefinition;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.TransactionManagerName;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.dao.MstAdditionDao;
import jp.co.nikkiso.ntss.core.dao.MstCoopFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstCourseDao;
import jp.co.nikkiso.ntss.core.dao.MstDialysisDifficultyDao;
import jp.co.nikkiso.ntss.core.dao.MstDiseaseDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.MstFavoriteFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstImplantDao;
import jp.co.nikkiso.ntss.core.dao.MstInfectionDao;
import jp.co.nikkiso.ntss.core.dao.MstKurDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstRelationshipDao;
import jp.co.nikkiso.ntss.core.dao.MstRoomBedGroupDao;
import jp.co.nikkiso.ntss.core.dao.MstSelectorDao;
import jp.co.nikkiso.ntss.core.dao.MstSeverityDao;
import jp.co.nikkiso.ntss.core.dao.MstTabooAllergyDao;
import jp.co.nikkiso.ntss.core.dao.MstTransportDao;
import jp.co.nikkiso.ntss.core.dao.MstUserAuthenticationDao;
import jp.co.nikkiso.ntss.core.dao.MstUserDao;
import jp.co.nikkiso.ntss.core.dao.MstWardDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainRestoreDao;
import jp.co.nikkiso.ntss.core.dao.OrdScheduleDao;
import jp.co.nikkiso.ntss.core.dao.PatEventDao;
import jp.co.nikkiso.ntss.core.dao.PatExamMainDao;
import jp.co.nikkiso.ntss.core.dao.PatExamPatternDao;
import jp.co.nikkiso.ntss.core.dao.PatGroupDao;
import jp.co.nikkiso.ntss.core.dao.PatGroupDetailDao;
import jp.co.nikkiso.ntss.core.dao.PatIndApproveDao;
import jp.co.nikkiso.ntss.core.dao.PatInsuranceDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatNameIdentificationDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.PatRadMainDao;
import jp.co.nikkiso.ntss.core.dao.PatRadPatternDao;
import jp.co.nikkiso.ntss.core.dao.PatTreatmentPatternDao;
import jp.co.nikkiso.ntss.core.dao.PatUniqueDao;
import jp.co.nikkiso.ntss.core.dao.SysFacilityDao;
import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.DetailedSearchRequest;
import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.OrdMainDetailedConditions;
import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.OrdScheduleDetailedConditions;
import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.OrdScheduleSimpleConditions;
import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.PatEventDetailedConditions;
import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.PatExamPatternConditions;
import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.PatGroupSearchRequest;
import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.PatInsuranceConditions;
import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.PatMainDetailedConditions;
import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.PatPersonalMainDetailedConditions;
import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.PatRadPatternDetailedConditions;
import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.PatUniqueDetailedConditions;
import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.SimpleSearchRequest;
import jp.co.nikkiso.ntss.core.dto.patUnique.OrdMainForUpdTargetWeightDTO;
import jp.co.nikkiso.ntss.core.dto.patUnique.PatDWEffectsTimeLineDTO;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.MstAddition;
import jp.co.nikkiso.ntss.core.entity.MstCoopFacility;
import jp.co.nikkiso.ntss.core.entity.MstCourse;
import jp.co.nikkiso.ntss.core.entity.MstDialysisDifficulty;
import jp.co.nikkiso.ntss.core.entity.MstDisease;
import jp.co.nikkiso.ntss.core.entity.MstFacility;
import jp.co.nikkiso.ntss.core.entity.MstImplant;
import jp.co.nikkiso.ntss.core.entity.MstInfection;
import jp.co.nikkiso.ntss.core.entity.MstKur;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstRelationship;
import jp.co.nikkiso.ntss.core.entity.MstRoomBedGroup;
import jp.co.nikkiso.ntss.core.entity.MstSelectorToPatGroup;
import jp.co.nikkiso.ntss.core.entity.MstSeverity;
import jp.co.nikkiso.ntss.core.entity.MstTabooAllergy;
import jp.co.nikkiso.ntss.core.entity.MstTransport;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.MstUser;
import jp.co.nikkiso.ntss.core.entity.MstWard;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.OrdMainRestore;
import jp.co.nikkiso.ntss.core.entity.OrdSchedule;
import jp.co.nikkiso.ntss.core.entity.PatCourseInfo;
import jp.co.nikkiso.ntss.core.entity.PatDoctorInfo;
import jp.co.nikkiso.ntss.core.entity.PatGroup;
import jp.co.nikkiso.ntss.core.entity.PatGroupDetail;
import jp.co.nikkiso.ntss.core.entity.PatHistoryInfo;
import jp.co.nikkiso.ntss.core.entity.PatIndApprove;
import jp.co.nikkiso.ntss.core.entity.PatInfo;
import jp.co.nikkiso.ntss.core.entity.PatInsurance;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatNameIdentification;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.PatUnique;
import jp.co.nikkiso.ntss.core.entity.SysFacility;
import jp.co.nikkiso.ntss.core.entity.custom.AdditionInfo;
import jp.co.nikkiso.ntss.core.entity.custom.AdditionInfoOrdMain;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;
import jp.co.nikkiso.ntss.core.entity.custom.MstFavoriteFacilityData;
import jp.co.nikkiso.ntss.core.entity.custom.MstTabooAllergyDetailInfo;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainBedAndKur;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainKurBed;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainTreatDate;
import jp.co.nikkiso.ntss.core.entity.custom.PatGroupCustom;
import jp.co.nikkiso.ntss.core.entity.custom.PatGroupCustomForPg;
import jp.co.nikkiso.ntss.core.entity.custom.PatInfoTabooAllergy;
import jp.co.nikkiso.ntss.core.entity.custom.PatInsuInfo;
import jp.co.nikkiso.ntss.core.entity.custom.PatPersonalMainData;
import jp.co.nikkiso.ntss.core.entity.custom.PatTabooAllergyRes;
import jp.co.nikkiso.ntss.core.entity.custom.PatUniquePhysicalInfo;
import jp.co.nikkiso.ntss.core.entity.custom.SharedPatFacilityInfo;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.logger.LogObjectUtils;
import jp.co.nikkiso.ntss.core.utils.BeanBuilderUtils;
import jp.co.nikkiso.ntss.core.utils.MongoHealthCheckService;
import jp.co.nikkiso.ntss.core.utils.PatSortCommonUtil;
import jp.co.nikkiso.ntss.core.utils.TriggerUtil;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.collections4.CollectionUtils;
import org.bson.Document;
import org.bson.conversions.Bson;
import org.json.JSONArray;
import org.json.JSONObject;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import org.jsoup.internal.StringUtil;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import org.seasar.doma.DomaException;
import org.seasar.doma.MapKeyNamingType;
import org.seasar.doma.jdbc.Config;
import org.seasar.doma.jdbc.OptimisticLockException;
import org.seasar.doma.jdbc.SqlKind;
import org.seasar.doma.jdbc.SqlLogType;
import org.seasar.doma.jdbc.builder.SelectBuilder;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import org.springframework.aop.framework.AopProxyUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.util.ObjectUtils;
import org.springframework.dao.DataAccessResourceFailureException;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.TransactionStatus;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.DefaultTransactionDefinition;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestTemplate;

import java.io.IOException;
import java.lang.reflect.Field;
import java.net.URI;
import java.net.URISyntaxException;
import java.sql.Savepoint;
import java.sql.Timestamp;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
// add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 start
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Queue;
import java.util.Set;
import java.util.TimeZone;
import java.util.concurrent.atomic.AtomicInteger;
// add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 end
import java.util.function.Function;
import java.util.stream.Collectors;

import static com.mongodb.client.model.Filters.and;
import static com.mongodb.client.model.Filters.eq;
import static com.mongodb.client.model.Filters.gt;
import static com.mongodb.client.model.Filters.lt;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.logevent.DataUpdateLogInfoUtil.convertString;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.toJson;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
import jp.co.nikkiso.ntss.core.config.DefaultDb;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end

/* add by chenshijie  2023-02-02 [CodeOptimization]  start */
/* add by chenshijie  2023-02-02 [CodeOptimization]  end */


// add FNSI-MongoDB 関 start
// add FNSI-共有された患者情報作成を見直し 江 start
// add FNSI-共有された患者情報作成を見直し 江 end
// add FNSI-MongoDB 関 end
// add FNSI-患者情報共有よりの改修 江 start
// add FNSI-患者情報共有よりの改修 江 end
// add FNSI-排他処理 劉 start
// add FNSI-排他処理 劉 end
// add MongoDB共通インターフェース 関 start
// add FNSI-add encryption 関 start
// add FNSI-add encryption 関 end

// add MongoDB共通インターフェース 関 end

@Service
@Slf4j
public class PatInfoService {
  @Autowired
  private PatPersonalMainDao patPersonalMainDao;
  @Autowired
  private PatMainDao patMainDao;
  @Autowired
  private PatUniqueDao patUniqueDao;
  @Autowired
  private OrdScheduleDao ordScheduleDao;
  @Autowired
  private OrdMainDao ordMainDao;
  // add FutreNetWeb+SI課題管理No6227 趙 start
  @Autowired
  private OrdMainRestoreDao ordMainRestoreDao;
  // add FutreNetWeb+SI課題管理No6227 趙 end
  @Autowired
  private PatGroupDetailDao patGroupDetailDao;
  @Autowired
  private PatInsuranceDao patInsuranceDao;
  @Autowired
  private MstUserDao mstUserDao;
  @Autowired
  OrdMainResource ordMainResource;
  @Autowired
  MntMachineStateDao mntMachineStateDao;
  @Autowired
  MasterMaintenanceGenericDao masterMaintenanceGenericDao;
  @Autowired
  MstDialysisDifficultyDao mstDialysisDifficultyDao;
  @Autowired
  MstInfectionDao mstInfectionDao;
  // add FNSI-共有された患者情報作成を見直し 江 start
  @Autowired
  MstRelationshipDao mstRelationshipDao;
  // add FNSI-共有された患者情報作成を見直し 江 end
  // add FNSI-MongoDB 関 start
  @Autowired(required = false)
  MongoTemplate mongoTemplate;
//  @Value("${spring.config.activate:on-profile}")
//  private String profiles;
  // add FNSI-MongoDB 関 end
  //add No338,339患者詳細検索の追加項目 患者イベント 劉全航 start
  @Autowired
  private PatEventDao patEventDao;
  //add No338,339患者詳細検索の追加項目 患者イベント 劉全航 end
  //add No338患者詳細検索の追加項目 一般撮影検査予定検索 劉全航 start
  @Autowired
  private PatRadPatternDao patRadPatternDao;
  //add No338患者詳細検索の追加項目 一般撮影検査予定検索 劉全航 end
  // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen Start
  @Autowired
  private MstDiseaseDao mstDiseaseDao;
  @Autowired
  private MstCourseDao mstCourseDao;
  @Autowired
  private MstImplantDao mstImplantDao;
  @Autowired
  private MstWardDao mstWardDao;
  @Autowired
  private MstSeverityDao mstSeverityDao;
  @Autowired
  private MstTransportDao mstTransportDao;
  @Autowired
  private MstFavoriteFacilityDao mstFavoriteFacilityDao;
  // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen end
  // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen Start
  @Autowired
  private SysFacilityDao sysFacilityDao;
  // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen end
  /**
   * 患者検査結果Dao.
   */
  @Autowired
  private PatExamMainDao patExamMainDao;

  /**
   * 患者放射線メインダオ
   */
   @Autowired
  PatRadMainDao patRadMainDao;

  /*
   * クールマスタ
   */
  @Autowired
  private MstKurDao mstKurDao;
  // add 12005 患者削除時の予定中止は行われるが検査依頼・一般撮影検査依頼の削除が行われない zkm start
  @Autowired
  private DeathServiceImpl deathService;
  // add 12005 患者削除時の予定中止は行われるが検査依頼・一般撮影検査依頼の削除が行われない zkm end

  /**
  * ロギングのServiceインタフェース.
  */
  @Autowired
  private LogService logService;
  @Autowired
  NotificationMessageService notificationService;
  @Autowired
  MaterialsSharingPatientInfomationService materialsSharingPatientInfomationService;

  private static final Map<String, String> coopCds = initMapData();
  @Value("${ntss.admin-web.coop-api.url}")
  private String coopApi;

  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;
  @Autowired
  private PatGroupDao patGroupDao;
  // add FNSI-No.341 患者リストのソート項目不足 吉 start
  @Autowired
  private MstSelectorDao mstSelectorDao;
  // add FNSI-No.341 患者リストのソート項目不足  吉 end

  @Autowired
  private MstCoopFacilityDao mstCoopFacilityDao;
  /**
   * webAPI呼び出し用
   */
  @Autowired
  WebApiCallCommonUtil webApiCallCommonUtil;

  /**
   * 施設設定一覧Service
   */
  @Autowired
  private MstFacilitySettingDao mstFacilitySettingDao;

  // add FNSI-患者情報共有よりの改修 江 start
  @Autowired
  private MstFacilityDao mstFacilityDao;
  // add FNSI-患者情報共有よりの改修 江 end

  // add FNSI-改修内容追加OrdMain履歴 付 start
  @Autowired
  private SelectHistoryUtils selectHistoryUtils;
  // add FNSI-改修内容追加OrdMain履歴 付 end
  // add no338 患者检索 張岩 start
  @Autowired
  private PatExamPatternDao patExamPatternDao;
  // add no338 患者检索 張岩 end

  // DB更新ログ出力ロジック wangzuo Start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Autowired
  private LogServiceCore logServiceCore;
  // DB更新ログ出力ロジック wangzuo End

  @Autowired
  private TriggerUtil triggerUtil;

  // add #10210 帳票における患者情報の取得元について limingzhe start
  @Autowired
  MstWheelChairService mstWheelChairSerive;
  // add #10210 帳票における患者情報の取得元について limingzhe end
  // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
  @Autowired
  private MstUserAuthenticationDao mstUserAuthenticationDao;

  @Autowired
  private MstAdditionDao mstAdditionDao;

  @Value("${ntss.admin-web.web-api.url}")
  private String webApi;
  // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end

  // #10443 Import necessary recourse START
  @Autowired
  private ObjectMapper objectMapper;

  @Autowired
  private PatIndApproveDao patIndApproveDao;

  @Autowired
  private PatTreatmentPatternDao patTreatmentPatternDao;

  @Autowired
  private IndHistoryService indHistoryService;

  @Autowired
  @PersonalDb
  private Config personalDbConfig;

  private static final String FORMAT_DATE = "yyyyMMddHHmmssSSS";
  // #10443 Import necessary recourse END

  @Autowired
  private PatTreatmentPatternService patTreatmentPatternService;

  //add 10880 start
  @Autowired
  private DeviceEdgeOrderService deviceEdgeOrderService;

  @Autowired
  private MstMachineDao mstMachineDao;
  //add 10880 end

  @Autowired
  private MstRoomBedGroupDao mstRoomBedGroupDao;

  /* add by chamaojia 2026-03-27 [12462] 患者情報共有->患者経過総合ビューア --start */
  @Autowired
  private MstTabooAllergyDao mstTabooAllergyDao;
  /* add by chamaojia 2026-03-27 [12462] 患者情報共有->患者経過総合ビューア --end */
  // #10710
  /** ジャーナル作成のServiceインターフェース */
  @Autowired
  private JournalService journalService;
  @Autowired
  private DataSourceTransactionManager dsTransactionManager;

  //add #12462 患者共有情報- 患者カレンダー  by zrx start
  @Autowired
  private PatNameIdentificationDao patNameIdentificationDao;
  //add #12462 患者共有情報- 患者カレンダー  by zrx end

  @Transactional(TransactionManagerName.ALL)
  public Long create(Map<String, String> payload) throws Exception {
    // 各レコードのJSONを対応するクラスにマッピング
    log.info("create pat is begin"+System.currentTimeMillis());
    ObjectMapper mapper = new ObjectMapper();
    PatPersonalMain patPersonalMain = mapper.readValue(payload.get("pat_personal_main"), PatPersonalMain.class);
    PatMain patMain = mapper.readValue(payload.get("pat_main"), PatMain.class);
    PatUnique patUnique = mapper.readValue(payload.get("pat_unique"), PatUnique.class);
    // add #11159 特定の患者だけ患者情報編集時にエラーが発生する ztc 20241008 start
    this.handleUniqueDiseaseName(patUnique);
    // add #11159 特定の患者だけ患者情報編集時にエラーが発生する ztc 20241008 end
    // add FNSI-共有された患者情報作成を見直し 江 start
    if(patPersonalMain.getPat_id() != null){
      String dstfacilityCd = patPersonalMain.getFacility_cd();
      PatPersonalMain srcPatPersonalMain= patPersonalMainDao.selectContactInfoById(patPersonalMain.getPat_id());
      String srcOtherContactInfoStr =srcPatPersonalMain.getOther_contact_info();
      String srcfacilityCd = srcPatPersonalMain.getFacility_cd();
      String srcVendorContactInfo = srcPatPersonalMain.getVendor_contact_info();
      List<Map<String, Object>> otherContactInfoList = ObjectMapperUtil.readListOfMap(srcOtherContactInfoStr);
      List<Map<String, Object>> ContactInfoList;
      PatPersonalMain otherContactInfoPatPersonalMain;
      String srcOtherContacthospatid;
      String contactInfo;
      List<Map<String, Object>> otherContactInfoListCopy = new ArrayList();
      for (Map<String, Object> otherContactInfo : otherContactInfoList) {
        if(otherContactInfo.get("pat_id") != null){
          srcOtherContacthospatid = otherContactInfo.get("pat_id").toString();
          Long otherContactpatid = patPersonalMainDao.selectOtherContactPatId(srcfacilityCd,srcOtherContacthospatid);
          List<String> otherContactPatIdList = patMainDao.selectOtherContactPatIdListById(otherContactpatid,dstfacilityCd,srcfacilityCd);
          if (otherContactPatIdList.size() != 0){
            otherContactInfoPatPersonalMain = patPersonalMainDao.selectById(Long.parseLong(otherContactPatIdList.get(0)));
            if(otherContactInfo.get("relation_cd") != null){
              List<MstRelationship> relationShipList=mstRelationshipDao.selectByRelationName(dstfacilityCd,otherContactInfo.get("relation_name").toString());
              if(relationShipList.size() != 0){
                otherContactInfo.replace("relation_cd",relationShipList.get(0).getRelationshipCd());
                otherContactInfo.replace("relation_name",relationShipList.get(0).getRelationshipName());
              }else{
                otherContactInfo.replace("relation_cd",JSONObject.NULL);
                otherContactInfo.replace("relation_name",JSONObject.NULL);
              }
            }
            contactInfo ="[" + otherContactInfoPatPersonalMain.getPat_contact_info() + "]";
            ContactInfoList= ObjectMapperUtil.readListOfMap(contactInfo);
            if(otherContactInfo.get("first_name") != null){
              otherContactInfo.replace("first_name",otherContactInfoPatPersonalMain.getPat_first_name());
            }else{
              otherContactInfo.replace("first_name",JSONObject.NULL);
            }
            if(otherContactInfo.get("first_name_kana") != null){
              otherContactInfo.replace("first_name_kana",otherContactInfoPatPersonalMain.getPat_first_name_kana());
            }else{
              otherContactInfo.replace("first_name_kana",JSONObject.NULL);
            }
            if(otherContactInfo.get("last_name") != null){
              otherContactInfo.replace("last_name",otherContactInfoPatPersonalMain.getPat_last_name());
            }else{
              otherContactInfo.replace("last_name",JSONObject.NULL);
            }
            if(otherContactInfo.get("last_name_kana") != null){
              otherContactInfo.replace("last_name_kana",otherContactInfoPatPersonalMain.getPat_last_name_kana());
            }else{
              otherContactInfo.replace("last_name_kana",JSONObject.NULL);
            }
            if(otherContactInfo.get("pat_id") != null){
              otherContactInfo.replace("pat_id",otherContactInfoPatPersonalMain.getHosp_pat_id());
            }else{
              otherContactInfo.replace("pat_id",JSONObject.NULL);
            }
            if(otherContactInfo.get("fax") != null){
              otherContactInfo.replace("fax",ContactInfoList.get(0).get("fax"));
            }else{
              otherContactInfo.replace("fax",JSONObject.NULL);
            }
            if(otherContactInfo.get("tel1") != null){
              otherContactInfo.replace("tel1",ContactInfoList.get(0).get("tel1"));
            }else{
              otherContactInfo.replace("tel1",JSONObject.NULL);
            }
            if(otherContactInfo.get("tel2") != null){
              otherContactInfo.replace("tel2",ContactInfoList.get(0).get("tel2"));
            }else{
              otherContactInfo.replace("tel2",JSONObject.NULL);
            }
            if(otherContactInfo.get("memo1") != null){
              otherContactInfo.replace("memo1",ContactInfoList.get(0).get("memo1"));
            }else{
              otherContactInfo.replace("memo1",JSONObject.NULL);
            }
            if(otherContactInfo.get("memo2") != null){
              otherContactInfo.replace("memo2",ContactInfoList.get(0).get("memo2"));
            }else{
              otherContactInfo.replace("memo2",JSONObject.NULL);
            }
            if(otherContactInfo.get("e_mail") != null){
              otherContactInfo.replace("e_mail",ContactInfoList.get(0).get("e_mail"));
            }else{
              otherContactInfo.replace("e_mail",JSONObject.NULL);
            }
            if(otherContactInfo.get("zip_cd") != null){
              otherContactInfo.replace("zip_cd",ContactInfoList.get(0).get("zip_cd"));
            }else{
              otherContactInfo.replace("zip_cd",JSONObject.NULL);
            }
            if(otherContactInfo.get("address") != null){
              otherContactInfo.replace("address",ContactInfoList.get(0).get("address"));
            }else{
              otherContactInfo.replace("address",JSONObject.NULL);
            }
            if(otherContactInfo.get("work_tel") != null){
              otherContactInfo.replace("work_tel",ContactInfoList.get(0).get("work_tel"));
            }else{
              otherContactInfo.replace("work_tel",JSONObject.NULL);
            }
            if(otherContactInfo.get("work_name") != null){
              otherContactInfo.replace("work_name",ContactInfoList.get(0).get("work_name"));
            }else{
              otherContactInfo.replace("work_name",JSONObject.NULL);
            }
            if(otherContactInfo.get("work_address") != null) {
              otherContactInfo.replace("work_address", ContactInfoList.get(0).get("work_address"));
            }else{
              otherContactInfo.replace("work_address",JSONObject.NULL);
            }
            otherContactInfoListCopy.add(otherContactInfo);
          }
        }
      }
      String strOtherContactInfo=JSONObject.valueToString(otherContactInfoListCopy);
      patPersonalMain.setOther_contact_info(strOtherContactInfo);
      patPersonalMain.setVendor_contact_info(srcVendorContactInfo);
    }
    // add FNSI-共有された患者情報作成を見直し 江 end
    // pat_personal_main.pat_idのシーケンス
    Long nextSeqPatId = patPersonalMainDao.selectNextSeqPatId();
    // add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 start
    List<PatGroupCustomForPg> patGroupCustomForPgs = new ArrayList<>();
    // add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 end
    if (payload.get("pat_group_info") != null) {
      Map<String, String> patGroupList =  mapper.readValue(payload.get("pat_group_info"),  new TypeReference<Map<String, String>>() {});
      List<PatGroup> patGroup =  mapper.readValue(patGroupList.get("pat_group_list"),  new TypeReference<List<PatGroup>>() {});
      PatGroupDetail patGroupDetail = new PatGroupDetail();
      // add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 start
      AtomicInteger atomicInteger = new AtomicInteger(1);
      // add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 end
      for (PatGroup item : patGroup) {
        patGroupDetail.setPatGroupCd(item.getPatGroupCd());
        patGroupDetail.setPatId(nextSeqPatId);
        patGroupDetail.setFacilityCd(patPersonalMain.getFacility_cd());
        patGroupDetailDao.insert(patGroupDetail);
        // add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 start
        PatGroupCustomForPg pgCustomForPg = new PatGroupCustomForPg();
        pgCustomForPg.setCtl_no(atomicInteger.getAndIncrement());
        pgCustomForPg.setPatGroupCd(item.getPatGroupCd() != null ? item.getPatGroupCd().toString() : "");
        patGroupCustomForPgs.add(pgCustomForPg);
        // add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 end
      }
    }
    // add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 start
    patMain.setPat_group_info(mapper.writeValueAsString(patGroupCustomForPgs));
    // add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 end
    // 発行されたpat_idを使って残りの3テーブルにインサートする
    patPersonalMain.setPat_id(nextSeqPatId);
    patMain.setPat_id(nextSeqPatId);
    patUnique.setPat_id(nextSeqPatId);
    patUnique.setFacility_cd(patPersonalMain.getFacility_cd());
    // add #6931 【デグレ】患者情報を編集した際ログに編集していない感染症を編集した記録が残る 鄭爽 start
    String changeInfectInfoStr = patMain.getInfect_info();
    if (changeInfectInfoStr != null) {
      JSONArray changeInfectInfoJson = new JSONArray(changeInfectInfoStr);
      JSONArray changeInfectInfoJsonNew = new JSONArray();
      for(int i = 0; i < changeInfectInfoJson.length(); i++) {
        JSONObject jsonObj = changeInfectInfoJson.getJSONObject(i);
        if (!(jsonObj.isNull("exam_date") && "0".equals(jsonObj.get("infect").toString()) && jsonObj.isNull("up_date"))) {
          changeInfectInfoJsonNew.put(jsonObj);
        }
      }
      String changeStaffInfoStrNew = changeInfectInfoJsonNew.toString();
      patMain.setInfect_info(changeStaffInfoStrNew);
    }
    // add #6931 【デグレ】患者情報を編集した際ログに編集していない感染症を編集した記録が残る 鄭爽 end
    log.info("create pat.insert is begin"+System.currentTimeMillis());
    patPersonalMainDao.insert(patPersonalMain);
    patMainDao.insert(patMain);
    patUniqueDao.insert(patUnique);
    log.info("create pat.insert is end"+System.currentTimeMillis());

    if(mongoTemplate != null) {
      //add #10532 mongoDBがダウン中の操作について（新患登録） limingzhe start
      try {
        if (MongoHealthCheckService.getMongoDBConnected()) {
      //add #10532 mongoDBがダウン中の操作について（新患登録） limingzhe end
          // mod #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
          patPersonalMain.setIs_del("0");
          patMain.setIs_del("0");
          patMain.setSch_ext_status("0");
          patUnique.setIs_del("0");

          PatInfo patInfo = new PatInfo();
          patInfo.setPatPersonalMain(patPersonalMain);
          patInfo.setPatMain(patMain);
          patInfo.setPatUnique(patUnique);
          List<PatGroupCustom> patGroupCustoms = new ArrayList<>();
          if (payload.containsKey("pat_group_info")) {
            Map maps = BasicDBObject.parse(payload.get("pat_group_info"));
            List<Map<String, Object>> patGroupDetailT = ObjectMapperUtil.readListOfMap(maps.get("pat_group_list").toString());
            for (int i = 0; i < patGroupDetailT.size(); i++) {
              PatGroupCustom patGroupCustom = new PatGroupCustom();
              if (patGroupDetailT.get(i).containsKey("patGroupCd")) {
                // mod #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 start
//                patGroupCustom.setPatGroupCd(Integer.parseInt(patGroupDetailT.get(i).get("patGroupCd").toString()));
                patGroupCustom.setPatGroupCd(patGroupDetailT.get(i).get("patGroupCd").toString());
                // mod #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 end
              }
              if (patGroupDetailT.get(i).containsKey("patGroupName")) {
                patGroupCustom.setPatGroupName(patGroupDetailT.get(i).get("patGroupName").toString());
              }
              patGroupCustoms.add(patGroupCustom);
            }
          }
          if (patGroupCustoms != null) {
            patInfo.setPatGroupList(patGroupCustoms);
          }
          RestTemplate rt = new RestTemplate();
          URI uri = new URI(webApi + "/util/insertPatToMongo");
          RequestEntity<PatInfo> request = RequestEntity
            .put(uri)
            .contentType(MediaType.APPLICATION_JSON)
            .header("SSECCAYEK", "NTSS-NKK-ESM-TDC-YSK")
            .body(patInfo);
		// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
          long start = System.currentTimeMillis();
          ResponseEntity<Object> response = rt.exchange(request, Object.class);
          long cost = System.currentTimeMillis() - start;
          Map<String, Object> map = new HashMap<>();
          map.put("logType", "RESTTEMPLATE-LOG");
          map.put("className", "jp.co.nikkiso.ntss.admin_web.service.PatInfoService");
          map.put("methodName", "create");
          map.put("method", request.getMethod());
          map.put("url", uri.getPath());
          map.put("headers", request.getHeaders());
          map.put("requestParameter", request.getBody());
          map.put("status",response.getStatusCode());
          map.put("cost", cost);
          map.put("result",response.getBody());
          EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
          restTemplateEventLogMessage.setLogMessage(toJson(map));
          logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
		  // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
          // mod #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end
      //add #10532 mongoDBがダウン中の操作について（新患登録） limingzhe start
        }
      } catch (DataAccessResourceFailureException exception) {
        MongoHealthCheckService.setMongoDBConnected(false);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//            exception.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(exception));
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      }
      //add #10532 mongoDBがダウン中の操作について（新患登録） limingzhe end

    }

    return nextSeqPatId;
  }

  // add #11159 特定の患者だけ患者情報編集時にエラーが発生する ztc 20241008 start
  private void handleUniqueDiseaseName(PatUnique patUnique) {
    String medicalHstInfo = patUnique.getMedical_hst_info();
    if (StringUtils.hasText(medicalHstInfo)) {
      JSONArray medicalHstInfoArray = new JSONArray(medicalHstInfo);
      for (int i = 0; i < medicalHstInfoArray.length(); i++) {
        JSONObject medicalHstInfoObject = medicalHstInfoArray.getJSONObject(i);
        medicalHstInfoObject.remove("disease_name");
      }
      patUnique.setMedical_hst_info(medicalHstInfoArray.toString());
    }
  }
  // add #11159 特定の患者だけ患者情報編集時にエラーが発生する ztc 20241008 end

  // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen start
  public void inputCdCheck(JSONObject jsonObj, String cd, String name, Map<String, Map<String, String>> getMstNames, String mstName, String changeKbn) {
    if (!jsonObj.has(cd) || "null".equals(jsonObj.get(cd))) {
      jsonObj.put(name, "");
    } else {
      if ("1".equals(changeKbn)) {
        jsonObj.put(name, jsonObj.get(cd));
      } else {
        jsonObj.put(name, this.getCodeName(getMstNames, mstName, jsonObj.get(cd)));
      }
    }
  }
  // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen end
  // add #10735 患者情報を保存できない dengshen start
  public String checkCodeStr(JSONObject codeList, String codeName) {
    Object code = codeList.has(codeName) ? codeList.get(codeName) : "";
    return code != null ? code.toString() : "";
  }
  // add #10735 患者情報を保存できない dengshen end
  // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen start
  // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
  /**
   *
   * @param patPersonalMain
   * @param patMain
   * @param patUnique
   * @return Map<String MstName, Map<String MstKey, String MstName>>
   */
//  public Map<String, Map<String, String>> getMstNames(PatPersonalMainHistory patPersonalMainHistory,
//                                                      PatMainHistory patMainHistory,
//                                                      PatUniqueHistory patUniqueHistory){
  public Map<String, Map<String, String>> getMstNames(PatPersonalMain patPersonalMain,
                                                      PatMain patMain,
                                                      PatUnique patUnique){

    // 共通診療情報を取得する。
//JSONObject medicalCareInfoJson = new JSONObject(patMainHistory.getMedical_care_info());
    JSONObject medicalCareInfoJson = new JSONObject(patMain.getMedical_care_info());

    // 既往歴情報を取得する。
//    JSONArray medicalHstInfoJson = this.getJSONArray(patUniqueHistory.getMedical_hst_info());
    JSONArray medicalHstInfoJson = this.getJSONArray(patUnique.getMedical_hst_info());

    // 入外・転入出情報を取得する。
//    JSONArray inoutVisitHistoryInfoJson = this.getJSONArray(patUniqueHistory.getIn_out_visit_history_info());
    JSONArray inoutVisitHistoryInfoJson = this.getJSONArray(patUnique.getIn_out_visit_history_info());

    // 身体情報を取得する。
//    JSONArray physicalInfoJson = this.getJSONArray(patUniqueHistory.getPhysical_info());
    JSONArray physicalInfoJson = this.getJSONArray(patUnique.getPhysical_info());

    // 感染症情報を取得する。
//    JSONArray infectInfoJson = this.getJSONArray(patMainHistory.getInfect_info());
    JSONArray infectInfoJson = this.getJSONArray(patMain.getInfect_info());

    // インプラント情報を取得する。
//    JSONArray implantInfoJson = this.getJSONArray(patMainHistory.getImplant_info());
    JSONArray implantInfoJson = this.getJSONArray(patMain.getImplant_info());

    // 担当スタッフ情報を取得する。
//    JSONArray chargeStaffInfoJson = this.getJSONArray(patMainHistory.getCharge_staff_info());
    JSONArray chargeStaffInfoJson = this.getJSONArray(patMain.getCharge_staff_info());

    // 透析困難情報を取得する。
//    JSONArray dialDiffComInfoJson = this.getJSONArray(patPersonalMainHistory.getDial_diff_com_info());
    JSONArray dialDiffComInfoJson = this.getJSONArray(patPersonalMain.getDial_diff_com_info());
    // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
    // 加算
//    JSONArray additionInfoJson = this.getJSONArray(patMainHistory.getAddition_info());
    JSONArray additionInfoJson = this.getJSONArray(patMain.getAddition_info());
    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end
    // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end
    // 施設
    List<String> facilitys = new ArrayList<>();

    // 施設施設
    List<String> favoriteFacilitys = new ArrayList<>();

    // 病名マス
    List<Integer> diseases = new ArrayList<>();

    // 診療科
    List<Integer> courses = new ArrayList<>();

    // 感染症
    List<Integer> infections = new ArrayList<>();

    // インプラント
    List<Integer> implants = new ArrayList<>();

    // 病棟
    List<Integer> wards = new ArrayList<>();

    // 利用者
    List<Integer> personalUsers = new ArrayList<>();

    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
    // 重症度
//    List<String> severitys = new ArrayList<>();
    List<Integer> severitys = new ArrayList<>();

    // 搬送区分
//    List<String> transports = new ArrayList<>();
    List<Integer> transports = new ArrayList<>();
    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end

    // 透析困難情報
    List<Integer> mstDialysisDifficulties = new ArrayList<>();
    // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
    // 加算
    List<Integer> additions = new ArrayList<>();
    // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end
    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
    // 登録施設名
//    facilitys.add(patPersonalMainHistory.getFacility_cd());
    facilitys.add(patPersonalMain.getFacility_cd());

    // 登録施設名
//    facilitys.add(patMainHistory.getFacility_cd());
    facilitys.add(patMain.getFacility_cd());
    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end

    // 導入施設名
    favoriteFacilitys.add(this.getCode(medicalCareInfoJson, "facility_cd", String.class));

    // 登録施設名
    facilitys.addAll(this.getJsonObjCodeStr(medicalHstInfoJson, "facility_cd"));

    // 施設施設名
    favoriteFacilitys.addAll(this.getJsonObjCodeStr(medicalHstInfoJson, "diagnosis_facility_cd"));

    // 登録施設名
    facilitys.addAll(this.getJsonObjCodeStr(inoutVisitHistoryInfoJson, "facility_cd"));

    // 施設名
    facilitys.addAll(this.getJsonObjCodeStr(physicalInfoJson, "facility_cd"));

    // 死因
    Integer dieCd = null;
    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
//    if (patPersonalMainHistory.getDie_cd() != null && !"".equals(patPersonalMainHistory.getDie_cd())) {
    if (patPersonalMain.getDie_cd() != null && !"".equals(patPersonalMain.getDie_cd())) {
//      dieCd = Integer.valueOf(patPersonalMainHistory.getDie_cd());
      dieCd = Integer.valueOf(patPersonalMain.getDie_cd());
    }
    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end
    diseases.add(this.getCode(dieCd, Integer.class));

    // 原疾患
    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
//    diseases.add(this.getCode(patPersonalMainHistory.getPrimary_disease_cd(), Integer.class));
    diseases.add(this.getCode(patPersonalMain.getPrimary_disease_cd(), Integer.class));
    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end

    // 病名マスタ.病名
    diseases.addAll(this.getJsonObjCodeInt(medicalHstInfoJson, "disease_cd"));

    // 主科名
    courses.add(this.getCode(medicalCareInfoJson, "main_course_cd", Integer.class));

    // 透析実施科名
    courses.add(this.getCode(medicalCareInfoJson, "dialysis_course_cd", Integer.class));

    // 診療科名
    courses.addAll(this.getJsonObjCodeInt(medicalHstInfoJson, "course_cd"));

    // 感染症名
    infections.addAll(this.getJsonObjCodeInt(infectInfoJson, "infection_cd"));

    // インプラント名
    implants.addAll(this.getJsonObjCodeInt(implantInfoJson, "implant_cd"));

    // 病棟名
    wards.add(this.getCode(medicalCareInfoJson, "ward_cd", Integer.class));

    // 指示者
    personalUsers.addAll(this.getJsonObjCodeInt(physicalInfoJson, "indicator_cd"));

    // add 10708 by kangjie 20240618 start 更新者を増やします翻訳
    // 更新者
    personalUsers.addAll(this.getJsonObjCodeInt(physicalInfoJson, "changer_cd"));
    // add 10708 by kangjie 20240618 end

    // スタッフ
    personalUsers.addAll(this.getJsonObjCodeInt(chargeStaffInfoJson, "staff_cd"));

    // 診断医名
    personalUsers.addAll(this.getJsonObjCodeInt(medicalHstInfoJson, "diagnostician_cd"));

    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
    // 重症度名
//    severitys.add(this.getCode(patPersonalMainHistory.getSeverity_cd(), String.class));
    severitys.add(this.getCode(patPersonalMain.getSeverity_cd(), Integer.class));

    // 搬送区分
//    transports.add(this.getCode(patPersonalMainHistory.getTransport_cd(), String.class));
    transports.add(this.getCode(patPersonalMain.getTransport_cd(), Integer.class));
    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end

    // 透析困難名
    mstDialysisDifficulties.addAll(this.getJsonObjCodeInt(dialDiffComInfoJson, "dial_diff_cd"));

    // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen start
    if (inoutVisitHistoryInfoJson != null && inoutVisitHistoryInfoJson.length() != 0) {
      for (int i = 0; i < inoutVisitHistoryInfoJson.length(); i++) {
        String moveInOut = this.getCode(inoutVisitHistoryInfoJson.getJSONObject(i), "move_in_out", String.class);
        // 元施設
        String fromFacility = this.getCode(inoutVisitHistoryInfoJson.getJSONObject(i), "from_facility", String.class);
        // 先施設
        String toFacility = this.getCode(inoutVisitHistoryInfoJson.getJSONObject(i), "to_facility", String.class);

        switch (moveInOut) {
          case "3":
          case "4":
          case "5":
          case "9":
            // 元施設
            facilitys.add(fromFacility);
            // 先施設
            favoriteFacilitys.add(toFacility);
            break;
          case "1":
          case "2":
          case "6":
          case "7":
          case "8":
          case "10":
            // 元施設
            favoriteFacilitys.add(fromFacility);
            // 先施設
            facilitys.add(toFacility);
            break;
        }
      }
    }

    // 元科
    courses.addAll(this.getJsonObjCodeInt(inoutVisitHistoryInfoJson, "from_course"));

    // 元施設医
    personalUsers.addAll(this.getJsonObjCodeInt(inoutVisitHistoryInfoJson, "from_doctor"));

    // 元医療機関
    List<String> medicalInstitutionCds = new ArrayList<>();
    medicalInstitutionCds.addAll(this.getJsonObjCodeStr(inoutVisitHistoryInfoJson, "from_medicalInstitutionCd"));

    // 先科
    courses.addAll(this.getJsonObjCodeInt(inoutVisitHistoryInfoJson, "to_course"));

    // 先施設医
    personalUsers.addAll(this.getJsonObjCodeInt(inoutVisitHistoryInfoJson, "to_doctor"));

    // 先医療機関
    medicalInstitutionCds.addAll(this.getJsonObjCodeStr(inoutVisitHistoryInfoJson, "to_medicalInstitutionCd"));
    // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
    //加算
    additions.addAll(getJsonObjCodeInt(additionInfoJson, "cd"));
    // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end
    // 全施設マスタ情報を取得する。→→→→→→　Map<String MedicalInstitutionCd, String FacilityName>
    Map<String, String> medicalInstitutionNames = new HashMap<>();
    medicalInstitutionCds = this.cleanStrLst(medicalInstitutionCds);
    if (diseases.size() > 0) {
      sysFacilityDao.selectAllName(medicalInstitutionCds).stream()
        .collect(Collectors.toMap(SysFacility::getMedicalInstitutionCd, SysFacility::getFacilityName))
        .forEach((key, value) -> medicalInstitutionNames.put(String.valueOf(key), value));
    }
    // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen end

    // 施設マスタ情報を取得する。→→→→→→　Map<String FacilityCd, String FacilityName>
    Map<String, String> facilityNames = mstFacilityDao.selectNamesByCd(this.cleanStrLst(facilitys)).stream()
      .collect(Collectors.toMap(MstFacility::getFacilityCd, MstFacility::getFacilityName));

    // 病名マスタ情報を取得する。→→→→→→　Map<String DiseaseCd, String DiseaseName>
    Map<String, String> diseaseNames = new HashMap<>();
    diseases = this.cleanIntLst(diseases);
    if (diseases.size() > 0) {
      mstDiseaseDao.selectAllName(diseases).stream()
        .collect(Collectors.toMap(MstDisease::getDiseaseCd, MstDisease::getDiseaseName))
        .forEach((key, value) -> diseaseNames.put(String.valueOf(key), value));
    }

    // 診療科マスタ情報を取得する。→→→→→→　Map<String CourseCd, String CourseName>
    Map<String, String> courseNames = new HashMap<String, String>();
    courses = this.cleanIntLst(courses);
    if (courses.size() > 0) {
      mstCourseDao.selectAllName(courses).stream()
        .collect(Collectors.toMap(MstCourse::getCourseCd, MstCourse::getCourseName))
        .forEach((key, value) -> courseNames.put(String.valueOf(key), value));
    }

    // 感染症マスタ情報を取得する。→→→→→→　Map<String InfectionCd, String InfectionName>
    Map<String, String> infectionNames = new HashMap<String, String>();
    infections = this.cleanIntLst(infections);
    if (infections.size() > 0) {
      mstInfectionDao.selectAllName(infections).stream()
        .collect(Collectors.toMap(MstInfection::getInfectionCd, MstInfection::getInfectionName))
        .forEach((key, value) -> infectionNames.put(String.valueOf(key), value));
    }

    // インプラント情報を取得する。→→→→→→　Map<String InfectionCd, String InfectionName>
    Map<String, String> implantNames = new HashMap<String, String>();
    implants = this.cleanIntLst(implants);
    if (implants.size() > 0) {
      mstImplantDao.selectAllName(implants).stream()
        .collect(Collectors.toMap(MstImplant::getImplantCd, MstImplant::getImplantName))
        .forEach((key, value) -> implantNames.put(String.valueOf(key), value));
    }

    // 病棟マスタ情報を取得する。→→→→→→　Map<String WardCd, String WardName>
    Map<String, String> wardNames = new HashMap<String, String>();
    wards = this.cleanIntLst(wards);
    if (wards.size() > 0) {
      mstWardDao.selectAllName(wards).stream()
        .collect(Collectors.toMap(MstWard::getWardCd, MstWard::getWardName))
        .forEach((key, value) -> wardNames.put(String.valueOf(key), value));
    }

    // 利用者マスタ情報を取得する。→→→→→→　Map<String UserId, String UserFirstName+UserLastName>
    Map<String, String> personalUserNames = new HashMap<>();
    personalUsers = this.cleanIntLst(personalUsers);
    if (personalUsers.size() > 0) {
      mstPersonalUserDao.selectAllName(personalUsers).stream()
        .collect(Collectors.toMap(MstPersonalUser::getUserId, MstPersonalUser::getUserName))
        .forEach((key, value) -> personalUserNames.put(String.valueOf(key), value));
    }

    // 重症度マスタ情報を取得する。→→→→→→　Map<String SeverityCd, String SeverityName>
    Map<String, String> severityNames = new HashMap<String, String>();
    List<Integer> severitysInt = new ArrayList<>();
    severitys.stream().distinct().filter(Objects::nonNull).collect(Collectors.toList())
      .forEach(item -> severitysInt.add(Integer.valueOf(item)));
    if (severitys.size() > 0) {
      mstSeverityDao.selectAllName(severitysInt).stream()
        .collect(Collectors.toMap(MstSeverity::getSeverityCd, MstSeverity::getSeverityName))
        .forEach((key, value) -> severityNames.put(String.valueOf(key), value));
    }

    // 搬送区分マスタ情報を取得する。→→→→→→　Map<String TransportCd, String TransportName>
    Map<String, String> transportNames = new HashMap<String, String>();
    List<Integer> transportsInt = new ArrayList<>();
    transports.stream().distinct().filter(Objects::nonNull).collect(Collectors.toList())
      .forEach(item -> transportsInt.add(Integer.valueOf(item)));
    if (transports.size() > 0) {
      mstTransportDao.selectAllName(transportsInt).stream()
        .collect(Collectors.toMap(MstTransport::getTransportCd, MstTransport::getTransportName))
        .forEach((key, value) -> transportNames.put(String.valueOf(key), value));
    }

    // 透析困難情報を取得する。→→→→→→　Map<String TransportCd, String TransportName>
    Map<String, String> mstDialysisDifficultyNames = new HashMap<String, String>();
    mstDialysisDifficulties = this.cleanIntLst(mstDialysisDifficulties);
    if (mstDialysisDifficulties.size() > 0) {
      mstDialysisDifficultyDao.selectAllName(mstDialysisDifficulties).stream()
        .collect(Collectors.toMap(MstDialysisDifficulty::getDialysisDifficultyCd, MstDialysisDifficulty::getDialysisDifficultyName))
        .forEach((key, value) -> mstDialysisDifficultyNames.put(String.valueOf(key), value));
    }

    // 施設施設を取得する。→→→→→→　Map<String MedicalInstitutionCd, String MedicalInstitutionName>
    Map<String, String> sysFacilityNames = new HashMap<String, String>();
    favoriteFacilitys = this.cleanStrLst(favoriteFacilitys);
    if (favoriteFacilitys.size() > 0) {
      mstFavoriteFacilityDao.selectAllName(favoriteFacilitys).stream()
        .collect(Collectors.toMap(MstFavoriteFacilityData::getMedicalInstitutionCd, MstFavoriteFacilityData::getFavoriteFacilityName))
        .forEach((key, value) -> sysFacilityNames.put(key, value));
    }
    // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
    // 加算マスタ情報を取得する。→→→→→→　Map<String AdditionCd, String AdditionName>
    Map<String, String> additionNames = new HashMap<String, String>();
    Map<String, String> additionKinds = new HashMap<String, String>();
    Map<String, String> additionLastDates = new HashMap<String, String>();
    additions = this.cleanIntLst(additions);
    if (additions.size() > 0) {
      mstAdditionDao.selectAllName(additions).stream()
        .collect(Collectors.toMap(MstAddition::getAdditionCd, MstAddition::getAdditionName))
        .forEach((key, value) -> additionNames.put(String.valueOf(key), value));
      mstAdditionDao.selectAllName(additions).stream()
        .collect(Collectors.toMap(MstAddition::getAdditionCd, MstAddition::getAdditionKind))
        .forEach((key, value) -> additionKinds.put(String.valueOf(key), value));
      String date = null;
      // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
//      ordMainDao.selectCalculationDateList(null, patMain.getFacility_cd(), Long.parseLong(patMain.getPat_id()), date).stream()
      ordMainDao.selectCalculationDateList(null, patMain.getFacility_cd(), patMain.getPat_id(), date).stream()
                .collect(Collectors.toMap(AdditionInfoOrdMain::getCd, AdditionInfoOrdMain::getLast_date))
        .forEach((key, value) -> additionLastDates.put(String.valueOf(key), value));
      // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end
    }
    // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end
    Map<String, Map<String, String>> names = new HashMap<>();
    names.put("facilityNames", facilityNames);
    names.put("diseaseNames", diseaseNames);
    names.put("courseNames", courseNames);
    names.put("infectionNames", infectionNames);
    names.put("implantNames", implantNames);
    names.put("wardNames", wardNames);
    names.put("personalUserNames", personalUserNames);
    names.put("severityNames", severityNames);
    names.put("transportNames", transportNames);
    names.put("mstDialysisDifficultyNames", mstDialysisDifficultyNames);
    names.put("sysFacilityNames", sysFacilityNames);

    // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen start
    names.put("medicalInstitutionNames", medicalInstitutionNames);
    // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen end
    // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
    names.put("additionNames", additionNames);
    names.put("additionKinds", additionKinds);
    names.put("additionLastDates", additionLastDates);
    // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end
    return names;
  }

  public String getCodeName(Map<String, Map<String, String>> codeMap, String mstName, Object code) {
    String name = "";
    String codeStr = code != null ? code.toString() : "";
    if (codeMap.get(mstName).get(codeStr) != null) {
      name = codeMap.get(mstName).get(codeStr);
    }
    return name;
  }

  public JSONArray getJSONArray(String json) {
    JSONArray jsonArray = new JSONArray();
    if (json != null) {
      jsonArray = new JSONArray(json);
    }
    return jsonArray;
  }

  public <T> T getCode(Object code, Class<T> clazz){
    if (code == null) {
      return null;
    } else if (Integer.class.equals(clazz)) {
      return clazz.cast((Integer) code);
    } else if (String.class.equals(clazz)) {
      return clazz.cast((String) code);
    } else {
      return null;
    }
  }

  public <T> T getCode(JSONObject obj, String code, Class<T> clazz){
    // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen start
    try {
    // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen end
      // mod #10735 患者情報を保存できない dengshen start
      // Object value = obj.get(code);
      Object value = obj.has(code) ? obj.get(code) : "";
      // mod #10735 患者情報を保存できない dengshen end
      if (value == null || value.equals(null)) {
        return null;
      } else if (Integer.class.equals(clazz)) {
        return clazz.cast((Integer) value);
      } else if (String.class.equals(clazz)) {
        return clazz.cast((String) value);
      } else {
        return null;
      }
    // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen start
    } catch (Exception e) {
      return null;
    }
    // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen end
  }

  public List<String> getJsonObjCodeStr(JSONArray jsonArray, String code){
    List<String> codeValue = new ArrayList<>();
    if (jsonArray != null && jsonArray.length() != 0) {
      for (int i = 0; i < jsonArray.length(); i++) {
        codeValue.add(this.getCode(jsonArray.getJSONObject(i), code, String.class));
      }
    }
    return codeValue;
  }

  public static List<Integer> getJsonObjCodeInt(JSONArray jsonArray, String code){
    List<Integer> codeValue = new ArrayList<>();
    if (jsonArray != null && jsonArray.length() != 0) {
      for (int i = 0; i < jsonArray.length(); i++) {
        JSONObject jsonObject = jsonArray.getJSONObject(i);
        // mod #10735 患者情報を保存できない dengshen start
        // Object value = jsonObject.get(code);
        Object value = jsonObject.has(code) ? jsonObject.get(code) : "";
        // mod #10735 患者情報を保存できない dengshen end
        if (value instanceof String) {
          String valueStr = (String) value;
          if(StringUtils.hasText(valueStr)){
            if(org.apache.commons.lang3.StringUtils.isNumeric(valueStr)){
              codeValue.add(Integer.valueOf(valueStr));
            }else{
              continue;
            }
          }
        } else if (value instanceof Integer) {
          codeValue.add((Integer) value);
        } else {
          continue;
        }
      }
    }
    return codeValue;
  }

  public List<String> cleanStrLst (List<String> lst) {
    return lst.stream().distinct().filter(Objects::nonNull).collect(Collectors.toList());
  }

  public List<Integer> cleanIntLst (List<Integer> lst) {
    return lst.stream().distinct().filter(Objects::nonNull).collect(Collectors.toList());
  }
  // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen end
// //  nkk-外部結合テストNo.80 姜 start
  public List<PatUnique> selectPatInfoById(Long pat_id) throws Exception {
    List<PatUnique> listPatUnique = patUniqueDao.selectPatInfoById(pat_id);
    return listPatUnique;
  }
// //  nkk-外部結合テストNo.80 姜 end

  public Map<String, String> selectById(Long pat_id, String facilityCd) throws Exception {
    // 各レコードのJSONを対応するクラスにマッピング
    ObjectMapper mapper = new ObjectMapper();

    // 対象のpat_personal_mainレコード(1人)を取得
    List<Long> patIdList = new ArrayList<Long>();
    patIdList.add(pat_id);
    List<PatPersonalMain> listPatPersonalMain = patPersonalMainDao.selectByIdListFacilityCd(patIdList, facilityCd);
    if (listPatPersonalMain.size() == 0) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("患者情報API：selectById() 指定されたpat_idのpat_personal_mainレコードが存在しません。(pat_id: " + pat_id + ")");
      eventLogMessage.setPatId(pat_id.toString());
      eventLogMessage.setSqlIdentification("(PatIdList = " + patIdList + ")");
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, "PatPersonalMainDao/selectByIdList");
      return null;
    }
    PatPersonalMain patPersonalMain = listPatPersonalMain.get(0);

    // 対象のpat_mainレコード(1人)を取得
    List<PatMain> listPatMain = patMainDao.selectByIdListFacilityCd(patIdList, facilityCd);
    if (listPatMain.size() == 0) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("患者情報API：selectById() 指定されたpat_idのpat_mainレコードが存在しません。(pat_id: " + pat_id + ")");
      eventLogMessage.setPatId(pat_id.toString());
      eventLogMessage.setSqlIdentification("(PatIdList = " + patIdList + ")");
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, "PatMainDao/selectByIdList");
      return null;
    }
    PatMain patMain = listPatMain.get(0);

    // 対象のpat_uniqueレコード(1人)を取得
    List<PatUnique> listPatUnique = patUniqueDao.selectByIdList(patIdList);
    if (listPatUnique.size() == 0) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("患者情報API：selectById() 指定されたpat_idのpat_uniqueレコードが存在しません。(pat_id: " + pat_id + ")");
      eventLogMessage.setPatId(pat_id.toString());
      eventLogMessage.setSqlIdentification("(PatIdList = " + patIdList + ")");
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, "PatUniqueDao/selectByIdList");
      return null;
    }
    PatUnique patUnique = listPatUnique.get(0);

    // 各テーブルのレコードオブジェクトをシリアライズし、テーブル名をキーとする連想配列にマッピング
    List<PatGroupCustom> patGroupList =  patGroupDetailDao.selectPatGroupByPatId(pat_id);

    Map<String, Object> patGroupInfor = new HashMap<>();
    patGroupInfor.put("pat_group_list", mapper.writeValueAsString(patGroupList));

    Map<String, String> payload = new HashMap<>();
    payload.put("pat_personal_main", mapper.writeValueAsString(patPersonalMain));
    payload.put("pat_main", mapper.writeValueAsString(patMain));
    payload.put("pat_unique", mapper.writeValueAsString(patUnique));
    payload.put("pat_group_info", mapper.writeValueAsString(patGroupInfor));
    return payload;
  }
  /**
   * 患者共有機能
   * 患者と開示元患者両方の情報を取得する
   * @param pat_id 患者ID
   * @return
   * @throws Exception
   */
  public Map<String, String> selectPatSharingById(Long pat_id) throws Exception {
    // 各レコードのJSONを対応するクラスにマッピング
    ObjectMapper mapper = new ObjectMapper();

    // 対象のpat_personal_mainレコード(1人)を取得
    List<Long> patIdList = new ArrayList<Long>();
    patIdList.add(pat_id);
    // del FNSI-共有された患者情報作成を見直し 江 start
    ////開示した元患者IDを取得
    //List<Long> srcPatIds = materialsSharingPatientInfomationService.getListPatIdSrcFromPatDst(pat_id);
    ////patIdlistに追加
    //for(Long id : srcPatIds){
    //  patIdList.add(id);
    //}
    // del FNSI-共有された患者情報作成を見直し 江 end

    List<PatPersonalMain> listPatPersonalMain = patPersonalMainDao.selectByIdList(patIdList);
    if (listPatPersonalMain == null || listPatPersonalMain.isEmpty()) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(
          "患者情報API：selectById() 指定されたpat_idのpat_personal_mainレコードが存在しません。(pat_id: " + pat_id + ")");
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI,
          "patPersonalMainDao/selectByIdList");
      return null;
    }
    // 現在選択した患者
    PatPersonalMain patPersonalMain = listPatPersonalMain.stream()
      .filter(item -> item.getPat_id().equals(pat_id))
      .findFirst().get();

    //  add #12462 患者情報共有 zrx start
    JSONArray dialDiffComInfoArray = this.getJSONArray(patPersonalMain.getDial_diff_com_info());
    for (int i = 0; i < dialDiffComInfoArray.length(); i++) {
      JSONObject jsonObject = dialDiffComInfoArray.getJSONObject(i);
      if (jsonObject.has("dial_diff_cd") && !jsonObject.isNull("dial_diff_cd")) {
        Object cd = jsonObject.get("dial_diff_cd");
        Integer cd_int = (Integer) cd;
        MstDialysisDifficulty mstDialysisDifficulty = mstDialysisDifficultyDao.selectByCd(cd_int);
        if (null == mstDialysisDifficulty) {
          continue;
        }
        String fnDialysisDifficultyCd = mstDialysisDifficulty.getFnDialysisDifficultyCd();
        String dialysisDifficultyName = mstDialysisDifficulty.getDialysisDifficultyName();
        jsonObject.put("dialysis_difficulty_name", dialysisDifficultyName);

        if (!StringUtil.isBlank(fnDialysisDifficultyCd)) {
          Integer i1 = Integer.valueOf(fnDialysisDifficultyCd);
          jsonObject.put("fn_dial_diff_cd", i1);
        }
      }
    }
    patPersonalMain.setDial_diff_com_info(dialDiffComInfoArray.toString());
    //add #12462 患者情報共有 zrx end
    // 開示した元患者
    List<PatPersonalMain> patPersonalMainSrc = listPatPersonalMain.stream()
                                                .filter(item -> !item.getPat_id().equals(pat_id))
                                                .collect(Collectors.toList());
    //開示した元のデータを繰り返す
    for(PatPersonalMain patPMSrc : patPersonalMainSrc){
      //other_contact_info 連絡先
      patPersonalMain.setOther_contact_info(addPastDataWithReadOnly(patPersonalMain.getOther_contact_info(),patPMSrc.getOther_contact_info()));
      //dial_diff_com_info 透析困難・重症度・搬送区分
      JSONArray pastDateJson = this.getJSONArray(patPMSrc.getDial_diff_com_info());
      JSONArray currenDataJson = this.getJSONArray(patPersonalMain.getDial_diff_com_info());
      for (int i = 0; i < pastDateJson.length(); i++) {
        //編集不可キーを追加
        JSONObject jsonObj = pastDateJson.getJSONObject(i);
        Integer dialDiffCd =  Integer.valueOf(jsonObj.get("dial_diff_cd").toString());
        MstDialysisDifficulty mstDialysisDifficulty = mstDialysisDifficultyDao.selectByCd(dialDiffCd);
        jsonObj.put("readonly",true);
        jsonObj.put("dialysis_difficulty_name",mstDialysisDifficulty.getDialysisDifficultyName());
        //現在データに入れる
        currenDataJson.put(jsonObj);
      }
      patPersonalMain.setDial_diff_com_info(currenDataJson.toString());
    }

    // 対象のpat_mainレコード(1人)を取得
    List<PatMain> listPatMain = patMainDao.selectByIdList(patIdList);
    if (listPatMain == null || listPatMain.isEmpty()) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage
          .setLogMessage("患者情報API：selectById() 指定されたpat_idのpat_mainレコードが存在しません。(pat_id: " + pat_id + ")");
      logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, "patMainDao/selectByIdList");
      return null;
    }
    // 現在選択した患者
    PatMain patMain = listPatMain.stream()
                          .filter(item -> item.getPat_id().equals(pat_id))
                          .findFirst().get();
    // 開示した元患者
    List<PatMain> patMainSrc = listPatMain.stream()
                                  .filter(item -> !item.getPat_id().equals(pat_id))
                                  .collect(Collectors.toList());

    for(PatMain patMSrc : patMainSrc){
      //Charge_staff_info担当者
      patMain.setCharge_staff_info(addPastDataWithReadOnly(patMain.getCharge_staff_info(), patMSrc.getCharge_staff_info()) );
      //Taboo_allergy_info禁忌アレルギー
      patMain.setTaboo_allergy_info(addPastDataWithReadOnly(patMain.getTaboo_allergy_info(), patMSrc.getTaboo_allergy_info()));
      //Infect_info
      JSONArray pastDateJson = new JSONArray(patMSrc.getInfect_info());
	    JSONArray currenDataJson = new JSONArray(patMain.getInfect_info());
      for (int i = 0; i < pastDateJson.length(); i++) {
        //編集不可キーを追加
        JSONObject jsonObj = pastDateJson.getJSONObject(i);
        Integer infectionCd =  Integer.valueOf(jsonObj.get("infection_cd").toString());
        MstInfection mstInfection = mstInfectionDao.selectByCd(infectionCd);
        jsonObj.put("readonly",true);
        jsonObj.put("infection_name",mstInfection.getInfectionName());
        //現在データに入れる
        currenDataJson.put(jsonObj);
      }
      patMain.setInfect_info(currenDataJson.toString());
      //Implant_info
      patMain.setImplant_info(addPastDataWithReadOnly(patMain.getImplant_info(), patMSrc.getImplant_info()));
    }
    //add #12462 患者情報共有 zrx start
    List<Long> listPatIdSrcFromListPatDst = patNameIdentificationDao.getListPatIdSrcFromListPatTo(patIdList);
    listPatIdSrcFromListPatDst.addAll(patIdList);
    listPatIdSrcFromListPatDst = listPatIdSrcFromListPatDst.stream()
      .filter(Objects::nonNull)
      .collect(Collectors.toList());

    //add #12462 患者情報共有 zrx end

    // 対象のpat_uniqueレコード(1人)を取得
    List<PatUnique> listPatUnique = patUniqueDao.selectByIdList(listPatIdSrcFromListPatDst);
    if (listPatUnique.size() == 0) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage
            .setLogMessage( "患者情報API：selectById() 指定されたpat_idのpat_uniqueレコードが存在しません。(pat_id: " + pat_id + ")");
        logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, "patUniqueDao/selectByIdList");
          return null;
    }

    // add #12462 患者情報共有 zrx start
    List<String> list = listPatUnique.stream().map(PatUnique::getFacility_cd).toList();
    List<String> jsonFacilityCd = getJsonFacilityCd(listPatUnique);
    List<SysFacility> sysFacilityByCdList = sysFacilityDao.getSysFacilityByCdList(jsonFacilityCd);

    List<PatHistoryInfo> hospitalByIdList = patNameIdentificationDao.getHospitalByIdList(list);
    Map<String, String> hospitalMap = hospitalByIdList.stream().collect(Collectors.toMap(PatHistoryInfo::getFacilityCd, PatHistoryInfo::getFacilityName));
    Map<String, String> collect = sysFacilityByCdList.stream().collect(Collectors.toMap(SysFacility::getMedicalInstitutionCd, SysFacility::getFacilityName));
    hospitalMap.putAll(collect);

    List<PatDoctorInfo> patDoctorByFacilityCdList = mstPersonalUserDao.getPatDoctorByFacilityCdList(list);
    Map<Integer, String> doctorMap = patDoctorByFacilityCdList.stream().collect(Collectors.toMap(PatDoctorInfo::getUserId, x -> x.getUserLastName().trim() + x.getUserFirstName().trim()));
    List<PatCourseInfo> courseByFacilityCdList = mstCourseDao.getCourseByFacilityCdList(list);
    Map<Integer, String> courseMap = courseByFacilityCdList.stream().collect(Collectors.toMap(PatCourseInfo::getCourseCd, PatCourseInfo::getCourseName));

    // 現在選択した患者
    PatUnique patUnique = listPatUnique.stream()
      .filter(item -> item.getPat_id().equals(pat_id))
      .findFirst().orElse(new PatUnique());

    // mod codeに応じたnameパラメータの追加
    //Medical_hst_info代入facility_cd
    patUnique.setMedical_hst_info(editPastDataWithReadOnly(patUnique.getMedical_hst_info(), patUnique.getFacility_cd(), hospitalMap, doctorMap, courseMap));
    //In_out_visit_history_info代入facility_cd
    patUnique.setIn_out_visit_history_info(editPastDataWithReadOnly(patUnique.getIn_out_visit_history_info(), patUnique.getFacility_cd(), hospitalMap, doctorMap, courseMap));
    //Physical_info代入facility_cd
    patUnique.setPhysical_info(editPastDataWithReadOnly(patUnique.getPhysical_info(), patUnique.getFacility_cd(), hospitalMap, doctorMap, courseMap));
    // mod codeに応じたnameパラメータの追加
    // 開示した元患者
    List<PatUnique> patUniqueSrc = listPatUnique.stream()
                                  .filter(item -> !item.getPat_id().equals(pat_id))
                                  .collect(Collectors.toList());

    for (PatUnique patUSrc : patUniqueSrc) {
      // mod codeに応じたnameパラメータの追加
      //Medical_hst_info
      patUnique.setMedical_hst_info(addPastDataWithReadOnly(patUnique.getMedical_hst_info(), patUSrc.getMedical_hst_info(), patUSrc.getFacility_cd(), hospitalMap, doctorMap, courseMap));
      //In_out_visit_history_info
      patUnique.setIn_out_visit_history_info(addPastDataWithReadOnly(patUnique.getIn_out_visit_history_info(), patUSrc.getIn_out_visit_history_info(), patUSrc.getFacility_cd(), hospitalMap, doctorMap, courseMap));
      //Physical_info
      patUnique.setPhysical_info(addPastDataWithReadOnly(patUnique.getPhysical_info(), patUSrc.getPhysical_info(), patUSrc.getFacility_cd(), hospitalMap, doctorMap, courseMap));
      // mod codeに応じたnameパラメータの追加
    }
    // add 課取得 #12462 患者情報共有 zrx end

    // # 9482 病名検索を追加し、対応病名を既往歴のJSONに一時的に追加
    if (StringUtils.hasText(patUnique.getMedical_hst_info()))
      patUnique.setMedical_hst_info(addDiseaseName(patUnique.getMedical_hst_info()));

    // add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 start
    // 対象のpat_insuranceレコード(1人)を取得
    List<PatInsurance> listPatInsurance = patInsuranceDao.getListPatInsuranceById(pat_id);
    PatInsurance patInsurance = new PatInsurance();
    if (listPatInsurance.size() != 0) {
      // del 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 start
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage
//        .setLogMessage( "患者情報API：selectById() 指定されたpat_idのpat_insuranceレコードが存在しません。(pat_id: " + pat_id + ")");
//      logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, "patInsuranceDao/getListPatInsuranceById");
//      return null;
      // del 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 end
      // 現在選択した患者
      patInsurance = listPatInsurance.stream()
        .filter(item -> item.getPat_id().equals(pat_id))
        .findFirst().get();
      // 開示した元患者
      List<PatInsurance> patInsuranceSrc = listPatInsurance.stream()
        .filter(item -> !item.getPat_id().equals(pat_id))
        .collect(Collectors.toList());

      for(PatInsurance patISrc : patInsuranceSrc){
        //insu_info
        patInsurance.setInsu_info(addPastDataWithReadOnly(patInsurance.getInsu_info(), patISrc.getInsu_info()));
        //insu_pub_info
        patInsurance.setInsu_pub_info(addPastDataWithReadOnly(patInsurance.getInsu_pub_info(), patISrc.getInsu_pub_info()));
        //insu_set_info
        patInsurance.setInsu_set_info(addPastDataWithReadOnly(patInsurance.getInsu_set_info(), patISrc.getInsu_set_info()));
        //insu_self_info
        patInsurance.setInsu_self_info(addPastDataWithReadOnly(patInsurance.getInsu_self_info(), patISrc.getInsu_self_info()));
      }
    }
    // add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 end
    // 各テーブルのレコードオブジェクトをシリアライズし、テーブル名をキーとする連想配列にマッピング
    List<PatGroupCustom> patGroupList =  patGroupDetailDao.selectPatGroupByPatId(pat_id);

    Map<String, Object> patGroupInfor = new HashMap<>();
    patGroupInfor.put("pat_group_list", mapper.writeValueAsString(patGroupList));

    Map<String, String> payload = new HashMap<>();
    payload.put("pat_personal_main", mapper.writeValueAsString(patPersonalMain));
    payload.put("pat_main", mapper.writeValueAsString(patMain));
    payload.put("pat_unique", mapper.writeValueAsString(patUnique));
    // add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 start
    payload.put("pat_insurance_info", mapper.writeValueAsString(patInsurance));
    // add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 end
    payload.put("pat_group_info", mapper.writeValueAsString(patGroupInfor));
    return payload;
  }

  /**
   * 編集不可キー(read only)を紐づける開示した元データを現在データにいれる
   * @param currentDataStr 現在データ
   * @param pastDataStr 開示した元データ
   * @return
   */
  private String addPastDataWithReadOnly(String currentDataStr, String pastDataStr) {
    JSONArray pastDateJson = new JSONArray(pastDataStr);
    JSONArray currenDataJson = new JSONArray(currentDataStr);
      for (int i = 0; i < pastDateJson.length(); i++) {
        //編集不可キーを追加
        JSONObject jsonObj = pastDateJson.getJSONObject(i);
        jsonObj.put("readonly",true);
        //現在データに入れる
        currenDataJson.put(jsonObj);
      }
      return currenDataJson.toString();
  }

  // #9482 Translate disease name through code Start
  /** 病名をコードで翻訳する */
  private String addDiseaseName(String mHisJOBStr) {
    JSONArray mHisDateJson = new JSONArray(mHisJOBStr);

    if (!mHisDateJson.isEmpty()) {
      List<Integer> diseaseCdArray = new ArrayList<>(mHisDateJson.length());

      // First Loop : Extract Code
      for (int i = 0; i < mHisDateJson.length(); i++) {
        JSONObject currentDataObj = mHisDateJson.getJSONObject(i);
        if (currentDataObj.has("disease_cd") && !currentDataObj.isNull("disease_cd"))
          diseaseCdArray.add(currentDataObj.getInt("disease_cd"));
      }
      // get Mst data by Extract Code
      List<MstDisease> diseaseList = mstDiseaseDao.getMstDiseaseByCds(diseaseCdArray.toArray(Integer[]::new));
      Map<Integer, MstDisease> diseaseMap = diseaseList.stream()
        .collect(Collectors.toMap(MstDisease::getDiseaseCd, Function.identity()));

      // Second loop : Translate disease name through code
      for (int i = 0; i < mHisDateJson.length(); i++) {
        JSONObject currentDataObj = mHisDateJson.getJSONObject(i);
        if (currentDataObj.has("disease_cd") && !currentDataObj.isNull("disease_cd")) {
          MstDisease desData = diseaseMap.get(currentDataObj.getInt("disease_cd"));
          if (desData != null) {
            String desName = ("1".equals(desData.getIsDel()) || "0".equals(desData.getIsDisp()) ? "【削除済み】" : "")
              + desData.getDiseaseName();
            currentDataObj.put("disease_name", desName);
          }
        }
      }
    }

    return mHisDateJson.toString();
  }
  // #9482 Translate disease name through code End

  public List<PatInsurance> selectInsuById(Long pat_id, String facilityCd) throws Exception {

    if (null == facilityCd) {
      return patInsuranceDao.getListPatInsuranceById(pat_id);
    }

    //add #12462 患者情報共有 zrx start
    String pat_id_name = patUniqueDao.selectFacilityCdById(pat_id);
    if (!facilityCd.equals(pat_id_name)) {

      List<PatNameIdentification> listPatIdSrcFromPatDstAndId = patNameIdentificationDao.getListPatIdSrcFromPatDstAndId(pat_id, facilityCd);
      pat_id = listPatIdSrcFromPatDstAndId.stream().findFirst().orElse(new PatNameIdentification()).getPatIdSrc();
    }
    //add #12462 患者情報共有 zrx end
    return patInsuranceDao.getListPatInsuranceById(pat_id);
  }

  /**
   * 患者情報リスト取得用
   * @param patIdList 抽出データ（処理対象患者の患者IDリスト）
   * @return 抽出条件を満たした患者の患者情報リスト
   * @throws Exception エラー情報をスロー
   */
  public Map<String, String> selectByIdList(List<Long> patIdList, String facilityCd,Integer postType) throws Exception {
    // 対象の患者レコード(リスト)を取得
    List<PatPersonalMain> listPatPersonalMain = patPersonalMainDao.selectByIdListFacilityCd(patIdList, facilityCd);
    if (listPatPersonalMain.size() != patIdList.size()) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("患者情報API：selectByIdList() 指定されたpat_idのいずれかがpat_personal_mainレコードが存在しません。");
      eventLogMessage.setSqlIdentification("(PatIdList = " + patIdList + ")");
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, "PatPersonalMainDao/selectByIdList");
      return null;
    }
    /*mod FNSI-改修内容5195 任 start*/
    List<PatMain> listPatMain = new ArrayList<PatMain>();
    if(postType == 1){
      listPatMain= patMainDao.selectByIdListFacilityCd(patIdList, facilityCd);
    }else{
      listPatMain= patMainDao.selectByIdListFacilityCdMultiPatList(patIdList, facilityCd);
    }
    /*mod FNSI-改修内容5195 任 end*/
    if (listPatMain.size() != patIdList.size()) {
      // add 7946 施設コード999998の施設にてREST呼び出しに失敗する 趙 start
//      List<Long> removeList = new ArrayList();
//      for(int i=0;i<patIdList.size();i++){
//        boolean flag=false;
//        for(int y=0;y<listPatMain.size();y++){
//          if(patIdList.get(i).equals(listPatMain.get(y).getPat_id())){
//            flag=false;
//            break;
//          }else{
//            flag=true;
//          }
//        }
//        if(flag){
//          removeList.add(patIdList.get(i));
//        }
//      }
//        patIdList.removeAll(removeList);

        // add 7946 施設コード999998の施設にてREST呼び出しに失敗する 趙 end
        // del 7946 施設コード999998の施設にてREST呼び出しに失敗する 趙 start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("患者情報API：selectByIdList() 指定されたpat_idのいずれかがpat_mainレコードが存在しません。");
      eventLogMessage.setSqlIdentification("(PatIdList = " + patIdList + ")");
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, "PatMainDao/selectByIdList");
      return null;
        // del 7946 施設コード999998の施設にてREST呼び出しに失敗する 趙 end
    }
    List<PatUnique> listPatUnique = patUniqueDao.selectByIdList(patIdList);
    // del FutreNetWeb+SI課題管理No6632 趙 start
    // if (listPatUnique.size() != patIdList.size()) {
    // EventLogMessage eventLogMessage = new EventLogMessage();
    // eventLogMessage.setLogMessage("患者情報API：selectById() 指定されたpat_idのいずれかがpat_uniqueレコードが存在しません。");
    // eventLogMessage.setSqlIdentification("(PatIdList = " + patIdList + ")");
    // logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, "PatUniqueDao/selectByIdList");
    // return null;
    // }
    // del FutreNetWeb+SI課題管理No6632 趙 end
// add データリストの患者情報修正 陳 start
    /*List<OrdMain> ordMainList = ordMainDao.selectByPatIdList(patIdList);*/
    List<OrdMain> ordMainList = new ArrayList<>();
    if(patIdList.size()>0){
      //mod #12096 データリストにてDWおよび目標体重を登録するとサーバダウン zrx start
      ordMainList = ordMainDao.selectByPatIdList(patIdList, facilityCd);
//      for(int i =0;i<patIdList.size();i++){
//        List<OrdMain> ordMainList1 = ordMainDao.selectByPatIdList(patIdList.get(i), facilityCd);
//        if(ordMainList1.size()>0){
//          for(int j = 0;j<ordMainList1.size();j++){
//            ordMainList.add(ordMainList1.get(j));
//          }
//        }
//      }
      //mod #12096 データリストにてDWおよび目標体重を登録するとサーバダウン zrx end
    }
// add データリストの患者情報修正 陳 end
    // 各テーブルのレコードオブジェクトをシリアライズし、テーブル名をキーとする連想配列にマッピング
    Map<String, String> payload = new HashMap<>();
    ObjectMapper mapper = new ObjectMapper();
    payload.put("pat_personal_main", mapper.writeValueAsString(listPatPersonalMain));
    payload.put("pat_main", mapper.writeValueAsString(listPatMain));
    payload.put("pat_unique", mapper.writeValueAsString(listPatUnique));
// add データリストの患者情報修正 陳 start
    payload.put("ord_main", mapper.writeValueAsString(ordMainList));
// add データリストの患者情報修正 陳 end
    // add FNSI-No.341 患者リストのソート項目不足 吉 start
//    List<OrdMain> ordMainAllList = ordMainDao.selectAllByPatIdList(patIdList,facilityCd);
    payload.put("ord_main_all", mapper.writeValueAsString(ordMainList));
    //mod #12096 データリストにてDWおよび目標体重を登録するとサーバダウン zrx start
    String codeJson = mstSelectorDao.selectItemCodesByNameList(facilityCd);
    if(codeJson != null ) {
      Map<String, List<String>> codeMap = mapper.readValue(codeJson, new TypeReference<Map<String, List<String>>>(){});
      for (Map.Entry<String, List<String>> entry : codeMap.entrySet()) {
        String key = entry.getKey();
        Object list = entry.getValue();
        payload.put(key, mapper.writeValueAsString(list));
      }
    }
//    List<String> masterPhysicalNameList = new ArrayList<>();
//    masterPhysicalNameList.add("mst_treatment");
//    masterPhysicalNameList.add("mst_severity");
//    masterPhysicalNameList.add("mst_transport");
//    masterPhysicalNameList.add("mst_disease");
//    masterPhysicalNameList.add("mst_course");
//    masterPhysicalNameList.add("mst_ward");
//    masterPhysicalNameList.add("mst_dialysis_difficulty");
//    List<MstSelector> mstOrdList = mstSelectorDao.selectByNameList(facilityCd,masterPhysicalNameList);
//    if(null != mstOrdList && mstOrdList.size()>0){
//      for(MstSelector mst : mstOrdList){
//        if(mst.getMasterPhysicalName().equals("mst_treatment")){
//          JSONObject obj = new JSONObject(mst.getOrderSettings());
//          JSONArray jsonArray = new JSONArray(obj.get("items").toString());
//          List<String> list = new ArrayList<>();
//          for(int i=0;i<jsonArray.length();i++){
//            JSONObject jsonObj = jsonArray.getJSONObject(i);
//            String code =jsonObj.get("code").toString();
//            list.add(code);
//          }
//          payload.put("mst_treatment", mapper.writeValueAsString(list));
//        }
//        if(mst.getMasterPhysicalName().equals("mst_severity")){
//          JSONObject obj = new JSONObject(mst.getOrderSettings());
//          JSONArray jsonArray = new JSONArray(obj.get("items").toString());
//          List<String> list = new ArrayList<>();
//          for(int i=0;i<jsonArray.length();i++){
//            JSONObject jsonObj = jsonArray.getJSONObject(i);
//            String code =jsonObj.get("code").toString();
//            list.add(code);
//          }
//          payload.put("mst_severity", mapper.writeValueAsString(list));
//        }
//        if(mst.getMasterPhysicalName().equals("mst_transport")){
//          JSONObject obj = new JSONObject(mst.getOrderSettings());
//          JSONArray jsonArray = new JSONArray(obj.get("items").toString());
//          List<String> list = new ArrayList<>();
//          for(int i=0;i<jsonArray.length();i++){
//            JSONObject jsonObj = jsonArray.getJSONObject(i);
//            String code =jsonObj.get("code").toString();
//            list.add(code);
//          }
//          payload.put("mst_transport", mapper.writeValueAsString(list));
//        }
//        if(mst.getMasterPhysicalName().equals("mst_disease")){
//          JSONObject obj = new JSONObject(mst.getOrderSettings());
//          JSONArray jsonArray = new JSONArray(obj.get("items").toString());
//          List<String> list = new ArrayList<>();
//          for(int i=0;i<jsonArray.length();i++){
//            JSONObject jsonObj = jsonArray.getJSONObject(i);
//            String code =jsonObj.get("code").toString();
//            list.add(code);
//          }
//          payload.put("mst_disease", mapper.writeValueAsString(list));
//        }
//        if(mst.getMasterPhysicalName().equals("mst_course")){
//          JSONObject obj = new JSONObject(mst.getOrderSettings());
//          JSONArray jsonArray = new JSONArray(obj.get("items").toString());
//          List<String> list = new ArrayList<>();
//          for(int i=0;i<jsonArray.length();i++){
//            JSONObject jsonObj = jsonArray.getJSONObject(i);
//            String code =jsonObj.get("code").toString();
//            list.add(code);
//          }
//          payload.put("mst_course", mapper.writeValueAsString(list));
//        }
//        if(mst.getMasterPhysicalName().equals("mst_ward")){
//          JSONObject obj = new JSONObject(mst.getOrderSettings());
//          JSONArray jsonArray = new JSONArray(obj.get("items").toString());
//          List<String> list = new ArrayList<>();
//          for(int i=0;i<jsonArray.length();i++){
//            JSONObject jsonObj = jsonArray.getJSONObject(i);
//            String code =jsonObj.get("code").toString();
//            list.add(code);
//          }
//          payload.put("mst_ward", mapper.writeValueAsString(list));
//        }
//        if(mst.getMasterPhysicalName().equals("mst_dialysis_difficulty")){
//          JSONObject obj = new JSONObject(mst.getOrderSettings());
//          JSONArray jsonArray = new JSONArray(obj.get("items").toString());
//          List<String> list = new ArrayList<>();
//          for(int i=0;i<jsonArray.length();i++){
//            JSONObject jsonObj = jsonArray.getJSONObject(i);
//            String code =jsonObj.get("code").toString();
//            list.add(code);
//          }
//          payload.put("mst_dialysis_difficulty", mapper.writeValueAsString(list));
//        }
//      }
//    }
    //mod #12096 データリストにてDWおよび目標体重を登録するとサーバダウン zrx end
    // add FNSI-No.341 患者リストのソート項目不足  吉 end
    return payload;
  }


  // mod 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 start
  // 保持 add by gjn 10389 患者リストのソートが遅い --start
  public Map<String, String> selectPatByIdList(List<Map<String, Object>> sortConditions, List<Long> patIdList, String facilityCd) throws Exception {
    EventLogMessage tmpEventLogMessage = new EventLogMessage();
    tmpEventLogMessage.setFacilityCd(facilityCd);
    Map<String, String> payload = new HashMap<>();
    ObjectMapper mapper = new ObjectMapper();
    // 対象の患者レコード(リスト)を取得
    List<PatPersonalMain> listPatPersonalMain = patPersonalMainDao.selectByIdListFacilityCdToPatGroup(patIdList, facilityCd);
    List<PatMain> listPatMain = patMainDao.selectByIdListFacilityCdToPatGroup(patIdList, facilityCd);
    List<PatUnique> listPatUnique = patUniqueDao.selectByIdListToPatGroup(patIdList);
    // 各テーブルのレコードオブジェクトをシリアライズし、テーブル名をキーとする連想配列にマッピング
    payload.put("pat_personal_main", mapper.writeValueAsString(listPatPersonalMain));
    payload.put("pat_main", mapper.writeValueAsString(listPatMain));
    payload.put("pat_unique", mapper.writeValueAsString(listPatUnique));

    List<String> masterPhysicalNameList = new ArrayList<>();
    if (sortConditions.size() > 0
      && !Objects.isNull(sortConditions.get(0))
      && !Objects.isNull(sortConditions.get(0).get("key"))) {
      masterPhysicalNameList.add(getSortConditionskey(sortConditions.get(0).get("key").toString()));
    }
    if (sortConditions.size() > 0
      && !Objects.isNull(sortConditions.get(1))
      && !Objects.isNull(sortConditions.get(1).get("key"))) {
      masterPhysicalNameList.add(getSortConditionskey(sortConditions.get(1).get("key").toString()));
    }
    if (sortConditions.size() > 0
      && !Objects.isNull(sortConditions.get(2))
      && !Objects.isNull(sortConditions.get(2).get("key"))) {
      masterPhysicalNameList.add(getSortConditionskey(sortConditions.get(2).get("key").toString()));
    }
    if (masterPhysicalNameList.size() > 0) {
      List<MstSelectorToPatGroup> mstSelectorList = mstSelectorDao.selectByNameListToPatGroup(facilityCd, masterPhysicalNameList);
      for (String masterPhysicalName : masterPhysicalNameList) {
        List<String> codeList = mstSelectorList.stream().filter(m -> masterPhysicalName.equals(m.getMasterPhysicalName()))
          .map(m -> m.getCode()).collect(Collectors.toList());
        payload.put(masterPhysicalName, mapper.writeValueAsString(codeList));
      }
    }
    return payload;
  }
  // 保持 add by gjn 10389 患者リストのソートが遅い --end
  private String getSortConditionskey(String sortKey) {
    String masterPhysicalName = "";
    switch (sortKey) {
      case "severity_cd":
        masterPhysicalName = "mst_severity";
        break;
      case "transport_cd":
        masterPhysicalName = "mst_transport";
        break;
      case "main_course_cd":
      case "dialysis_course_cd":
        masterPhysicalName = "mst_course";
        break;
      case "ward_cd":
        masterPhysicalName = "mst_ward";
        break;
      case "dial_diff_cd":
      case "dial_diff_com_info":
        masterPhysicalName = "mst_dialysis_difficulty";
        break;
      case "is_dia_under_dis":
      case "is_main_disease":
        masterPhysicalName = "mst_disease";
        break;
      case "is_wheel_chair":
        masterPhysicalName = "mst_wheel_chair";
        break;
      case "pat_kur":
        masterPhysicalName = "mst_kur";
        break;
      case "pat_bed_name":
        masterPhysicalName = "mst_bed";
        break;
      case "ind_tr_cd":
        masterPhysicalName = "mst_treatment";
        break;
    }
    return masterPhysicalName;
  }
  // mod 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 end

  /**
   * pat_idを指定して患者取得.
   * @param patIdList 抽出データ（処理対象患者の患者IDリスト）
   * @param facilityCd 抽出データ（処理対象施設の施設コード）
   * @return 患者リスト
   */
  public List<PatMain> selectPatMainByIdList(List<Long> patIdList, String facilityCd) {
    return patMainDao.selectByIdListFacilityCd(patIdList, facilityCd);
  }

  // add 10626 データリストのCTR・DW一括登録修正 房 start
  /**
   * 患者更新
   * @param pat_id　患者ID
   * @param payload
   * @param patGroupDiff
   * @throws Exception
   */
  @Transactional(TransactionManagerName.ALL)
  public void updateById(Long pat_id, Map<String, String> payload,JSONObject patGroupDiff) throws Exception {
    updateById(pat_id, payload, patGroupDiff, null);
  }
  // add 10626 データリストのCTR・DW一括登録修正 房 end

  @Transactional(TransactionManagerName.ALL)
  // mod 6931 【デグレ】患者情報を編集した際ログに編集していない感染症を編集した記録が残る 周安寧　start
  //public void updateById(Long pat_id, Map<String, String> payload) throws Exception {
  // mod 10626 データリストのCTR・DW一括登録修正 房 start
  public void updateById(Long pat_id, Map<String, String> payload,JSONObject patGroupDiff, List<PatInfo> patInfos) throws Exception {
    // mod 10626 データリストのCTR・DW一括登録修正 房 end
  // mod 6931 【デグレ】患者情報を編集した際ログに編集していない感染症を編集した記録が残る 周安寧　end
    // 各レコードのJSONを対応するクラスにマッピング
    ObjectMapper mapper = new ObjectMapper();
    PatPersonalMain patPersonalMain = mapper.readValue(payload.get("pat_personal_main"), PatPersonalMain.class);
    PatMain patMain = mapper.readValue(payload.get("pat_main"), PatMain.class);
    /* mod #6062 by zhangruixue 2023-06-01 --start */
    String pat_unique = payload.get("pat_unique");
    if(StringUtils.hasText(pat_unique) && pat_unique.contains(",\"unSavedPatInfo\":null}")){
      pat_unique = pat_unique.replace(",\"unSavedPatInfo\":null}", "}");
    }
    PatUnique patUnique = mapper.readValue(pat_unique, PatUnique.class);
    // add #11159 特定の患者だけ患者情報編集時にエラーが発生する ztc 20241008 start
    this.handleUniqueDiseaseName(patUnique);
    // add #11159 特定の患者だけ患者情報編集時にエラーが発生する ztc 20241008 end
    /* mod #6062 by zhangruixue 2023-06-01 --end */
    // add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 start
    PatInsurance patInsurance = new PatInsurance();
    if (payload.containsKey("pat_insurance_info")){
      patInsurance = mapper.readValue(payload.get("pat_insurance_info"), PatInsurance.class);
    }
    // add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 end
    //add FNSI-患者情報の連絡先の施設内患者の選択による登録変更同期を追加 江 start
    String hosp_pat_id = patPersonalMain.getHosp_pat_id();
    String contactInfo ="[" + patPersonalMain.getPat_contact_info() + "]";
    List<Map<String, Object>> contactInfoList = ObjectMapperUtil.readListOfMap(contactInfo);
    String fax = "";
    String tel1 = "";
    String tel2 = "";
    String memo1 = "";
    String memo2 = "";;
    String e_mail = "";
    String zip_cd = "";
    String address = "";
    String work_tel = "";
    String work_name = "";
    String first_name = "";
    String last_name = "";
    String first_name_kana = "";
    String last_name_kana = "";
    // add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 start
    String die_date  = "";
    String die_cd = "";
    String pat_sex = "";
    String pat_blood_type_abo = "";
    String pat_blood_type_rh = "";
    String pat_blood_type_serovar = "";
    String in_out_class = "";
    String severity_cd = "";
    String transport_cd = "";
    // add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 end
    boolean changedFlg = false;
    if(contactInfoList.get(0).get("fax") != null){
      fax = contactInfoList.get(0).get("fax").toString();
    }
    if(contactInfoList.get(0).get("tel1") != null){
      tel1 = contactInfoList.get(0).get("tel1").toString();
    }
    if(contactInfoList.get(0).get("tel2") != null){
      tel2 = contactInfoList.get(0).get("tel2").toString();
    }
    if(contactInfoList.get(0).get("memo1") != null){
      memo1 = contactInfoList.get(0).get("memo1").toString();
    }
    if(contactInfoList.get(0).get("memo2") != null){
      memo2 = contactInfoList.get(0).get("memo2").toString();
    }
    if(contactInfoList.get(0).get("e_mail") != null){
      e_mail = contactInfoList.get(0).get("e_mail").toString();
    }
    if(contactInfoList.get(0).get("zip_cd") != null){
      zip_cd = contactInfoList.get(0).get("zip_cd").toString();
    }
    if(contactInfoList.get(0).get("address") != null){
      address = contactInfoList.get(0).get("address").toString();
    }
    if(contactInfoList.get(0).get("work_tel") != null){
      work_tel = contactInfoList.get(0).get("work_tel").toString();
    }
    if(contactInfoList.get(0).get("work_name") != null){
      work_name = contactInfoList.get(0).get("work_name").toString();
    }
    if(patPersonalMain.getPat_first_name() != null){
      first_name = patPersonalMain.getPat_first_name();
    }
    if(patPersonalMain.getPat_last_name() != null){
      last_name = patPersonalMain.getPat_last_name();
    }
    if(patPersonalMain.getPat_first_name_kana() != null){
      first_name_kana = patPersonalMain.getPat_first_name_kana();
    }
    if(patPersonalMain.getPat_last_name_kana() != null){
      last_name_kana = patPersonalMain.getPat_last_name_kana();
    }
    // add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 start
    if(patPersonalMain.getDie_date() != null){
      die_date = patPersonalMain.getDie_date().toString();
    }
    if(patPersonalMain.getDie_cd() != null){
      die_cd = patPersonalMain.getDie_cd().toString();
    }
    if(patPersonalMain.getPat_sex() != null){
      pat_sex = patPersonalMain.getPat_sex().toString();
    }
    if(patPersonalMain.getPat_blood_type_abo() != null){
      pat_blood_type_abo = patPersonalMain.getPat_blood_type_abo().toString();
    }
    if(patPersonalMain.getPat_blood_type_rh() != null){
      pat_blood_type_rh = patPersonalMain.getPat_blood_type_rh().toString();
    }
    if(patPersonalMain.getPat_blood_type_serovar() != null){
      pat_blood_type_serovar = patPersonalMain.getPat_blood_type_serovar().toString();
    }
    if(patPersonalMain.getIn_out_class() != null){
      in_out_class = patPersonalMain.getIn_out_class().toString();
    }
    if(patPersonalMain.getSeverity_cd() != null){
      severity_cd = patPersonalMain.getSeverity_cd().toString();
    }
    if(patPersonalMain.getTransport_cd() != null){
      transport_cd = patPersonalMain.getTransport_cd().toString();
    }
    // add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 end
    List<Map<String, Object>> otherContactInfoListCopy = new ArrayList();

    // add 10626 データリストのCTR・DW一括登録修正 房 start
    PatPersonalMain patPersonalMainHaiTa = patPersonalMainDao.selectById(patPersonalMain.getPat_id());
    boolean contactIsChange = patInfoIsChange(patPersonalMainHaiTa, patPersonalMain, contactInfoList.get(0));
    if(contactIsChange) {
      // add 10626 データリストのCTR・DW一括登録修正 房 end
      // mod 10626 データリストのCTR・DW一括登録修正 房 start
//    List<PatPersonalMain> patList = patPersonalMainDao.selectPatListByFacility(patPersonalMain.getFacility_cd());
      List<PatPersonalMain> patList = patPersonalMainDao.selectPatListByFacilityAndOtherPatId(patPersonalMain.getFacility_cd(), hosp_pat_id);
      // mod 10626 データリストのCTR・DW一括登録修正 房 end
    String other_contact_info;
    List<Map<String, Object>> otherContactInfoList;
    for (PatPersonalMain pat : patList) {
      other_contact_info = pat.getOther_contact_info();
      otherContactInfoList = ObjectMapperUtil.readListOfMap(other_contact_info);
      for(Map<String, Object> otherContactInfo : otherContactInfoList){
        if(otherContactInfo.get("pat_id") != null){
          if(otherContactInfo.get("pat_id").equals(hosp_pat_id)){
            if(otherContactInfo.get("fax") != null){
              otherContactInfo.replace("fax",fax);
            }else{
              otherContactInfo.put("fax",fax);
            }
            if(otherContactInfo.get("memo1") != null){
              otherContactInfo.replace("memo1",memo1);
            }else{
              otherContactInfo.put("memo1",memo1);
            }
            if(otherContactInfo.get("memo2") != null){
              otherContactInfo.replace("memo2",memo2);
            }else{
              otherContactInfo.put("memo2",memo2);
            }
            if(otherContactInfo.get("tel1") != null){
              otherContactInfo.replace("tel1",tel1);
            }else{
              otherContactInfo.put("tel1",tel1);
            }
            if(otherContactInfo.get("tel2") != null){
              otherContactInfo.replace("tel2",tel2);
            }else{
              otherContactInfo.put("tel2",tel2);
            }
            if(otherContactInfo.get("e_mail") != null){
              otherContactInfo.replace("e_mail",e_mail);
            }else{
              otherContactInfo.put("e_mail",e_mail);
            }
            if(otherContactInfo.get("zip_cd") != null){
              otherContactInfo.replace("zip_cd",zip_cd);
            }else{
              otherContactInfo.put("zip_cd",zip_cd);
            }
            if(otherContactInfo.get("address") != null){
              otherContactInfo.replace("address",address);
            }else{
              otherContactInfo.put("address",address);
            }
            if(otherContactInfo.get("work_tel") != null){
              otherContactInfo.replace("work_tel",work_tel);
            }else{
              otherContactInfo.put("work_tel",work_tel);
            }
            if(otherContactInfo.get("work_name") != null){
              otherContactInfo.replace("work_name",work_name);
            }else{
              otherContactInfo.put("work_name",work_name);
            }
            if(otherContactInfo.get("first_name") != null){
              otherContactInfo.replace("first_name",first_name);
            }else{
              otherContactInfo.put("first_name",first_name);
            }
            if(otherContactInfo.get("last_name") != null){
              otherContactInfo.replace("last_name",last_name);
            }else{
              otherContactInfo.put("last_name",last_name);
            }
            if(otherContactInfo.get("first_name_kana") != null){
              otherContactInfo.replace("first_name_kana",first_name_kana);
            }else{
              otherContactInfo.put("first_name_kana",first_name_kana);
            }
            if(otherContactInfo.get("last_name_kana") != null){
              otherContactInfo.replace("last_name_kana",last_name_kana);
            }else{
              otherContactInfo.put("last_name_kana",last_name_kana);
            }
            changedFlg=true;
          }
            otherContactInfoListCopy.add(otherContactInfo);
        }
      }
      if(changedFlg){
        String strOtherContactInfo=JSONObject.valueToString(otherContactInfoListCopy);
        pat.setOther_contact_info(strOtherContactInfo);
        // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
        LogEventUtils.setOperatorId(pat,logService);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
        // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
        patPersonalMainDao.updateById(pat.getPat_id(), pat);
        changedFlg = false;
      }
      otherContactInfoListCopy.clear();
    }
      // add 10626 データリストのCTR・DW一括登録修正 房 start
    }
    // add 10626 データリストのCTR・DW一括登録修正 房 end
    //add FNSI-患者情報の連絡先の施設内患者の選択による登録変更同期を追加 江 end
    // add FNSI-排他処理 劉 start
    // PatPersonalMain排他チェック
    // del 10626 データリストのCTR・DW一括登録修正 房 start
    // PatPersonalMain patPersonalMainHaiTa = patPersonalMainDao.selectById(patPersonalMain.getPat_id());
    // del 10626 データリストのCTR・DW一括登録修正 房 end
    if (patPersonalMain.getOld_up_date_personal() != null && patPersonalMainHaiTa != null){
      if (!patPersonalMain.getOld_up_date_personal().equals(patPersonalMainHaiTa.getOld_up_date_personal()) ) {
        throw new OptimisticLockException(SqlLogType.NONE, SqlKind.UPDATE, "", "", "");
      }
    } else if (patPersonalMain.getOld_up_date_personal() != null && patPersonalMainHaiTa == null){
      throw new OptimisticLockException(SqlLogType.NONE, SqlKind.UPDATE, "", "", "");
    }

    // PatMain排他チェック
    PatMain patMainHaiTa = patMainDao.selectById(patMain.getPat_id());
    if (patMain.getOld_up_date() != null && patMainHaiTa != null){
      if (!patMain.getOld_up_date().equals(patMainHaiTa.getOld_up_date()) ) {
        throw new OptimisticLockException(SqlLogType.NONE, SqlKind.UPDATE, "", "", "");
      }
    } else if (patMain.getOld_up_date() != null && patMainHaiTa == null){
      throw new OptimisticLockException(SqlLogType.NONE, SqlKind.UPDATE, "", "", "");
    }
    // PatUnique排他チェック
    PatUnique patUniqueHaiTa = patUniqueDao.selectById(patUnique.getPat_id());
    if (patUnique.getOld_up_date_unique() != null && patUniqueHaiTa != null){
      if (!patUnique.getOld_up_date_unique().equals(patUniqueHaiTa.getOld_up_date_unique()) ) {
        throw new OptimisticLockException(SqlLogType.NONE, SqlKind.UPDATE, "", "", "");
      }
    } else if (patUnique.getOld_up_date_unique() != null && patUniqueHaiTa == null){
      throw new OptimisticLockException(SqlLogType.NONE, SqlKind.UPDATE, "", "", "");
    }
    // add FNSI-排他処理 劉 end

    // DB更新ログ出力ロジック wangzuo Start
    patPersonalMain.setPat_id(pat_id);
    patMain.setPat_id(pat_id);
    patUnique.setPat_id(pat_id);
    // add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 start
    patInsurance.setPat_id(pat_id);
    // add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 end
    // DB更新ログ出力ロジック wangzuo End

    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(patPersonalMain,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    patPersonalMainDao.updateById(pat_id, patPersonalMain);
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(patMain,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end

    //add #7503 profile連携（XML）で受信した指示医コード・名称 20220930 zhaoqi start
    String chargeStaffInfoStr = patMain.getCharge_staff_info();
    if(chargeStaffInfoStr != null){
      JSONArray chargeStaffInfoJson = new JSONArray(chargeStaffInfoStr);
      for(int i=0;i<chargeStaffInfoJson.length();i++){
        JSONObject jsonObj = chargeStaffInfoJson.getJSONObject(i);
        //del #7503 profile連携（XML）で受信した指示医コード・名称 20221024 zhaoqi start
        //jsonObj.put("ctl_no", i+1);
        //add #7503 profile連携（XML）で受信した指示医コード・名称 20221024 zhaoqi end
        //add #7503 profile連携（XML）で受信した指示医コード・名称 20221024 zhaoqi start
        jsonObj.put("disp_order", i+1);
        //add #7503 profile連携（XML）で受信した指示医コード・名称 20221024 zhaoqi end
      }
      String chargeStaffInfoStrNew = chargeStaffInfoJson.toString();
      patMain.setCharge_staff_info(chargeStaffInfoStrNew);
    }

    //add #7503 profile連携（XML）で受信した指示医コード・名称 20220930 zhaoqi end
    // add #6931 【デグレ】患者情報を編集した際ログに編集していない感染症を編集した記録が残る 鄭爽 start
    String changeInfectInfoStr = patMain.getInfect_info();
    if (changeInfectInfoStr != null) {
      JSONArray changeInfectInfoJson = new JSONArray(changeInfectInfoStr);
      JSONArray changeInfectInfoJsonNew = new JSONArray();
      for(int i = 0; i < changeInfectInfoJson.length(); i++) {
        JSONObject jsonObj = changeInfectInfoJson.getJSONObject(i);
        if (!(jsonObj.isNull("exam_date") && "0".equals(jsonObj.get("infect").toString()) && jsonObj.isNull("up_date"))) {
          changeInfectInfoJsonNew.put(jsonObj);
        }
      }
      String changeStaffInfoStrNew = changeInfectInfoJsonNew.toString();
      patMain.setInfect_info(changeStaffInfoStrNew);
    }
    // add #6931 【デグレ】患者情報を編集した際ログに編集していない感染症を編集した記録が残る 鄭爽 end
    // mod #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 start
    if (payload.get("pat_group_info") != null) {
      Map<String, String> patGroupList =  mapper.readValue(payload.get("pat_group_info"),  new TypeReference<Map<String, String>>() {});
      List<PatGroup> patGroup =  mapper.readValue(patGroupList.get("pat_group_list"),  new TypeReference<List<PatGroup>>() {});
      List<PatGroupCustomForPg> patGroupCustomForPgs = new ArrayList<>();
      if (patGroup != null && patGroup.size() > 0) {
        AtomicInteger atomicInteger = new AtomicInteger(1);
        for (PatGroup pg : patGroup) {
          PatGroupCustomForPg pgCustomForPg = new PatGroupCustomForPg();
          pgCustomForPg.setCtl_no(atomicInteger.getAndIncrement());
          pgCustomForPg.setPatGroupCd(pg.getPatGroupCd() != null ? pg.getPatGroupCd().toString() : "");
          patGroupCustomForPgs.add(pgCustomForPg);
        }
        patMain.setPat_group_info(mapper.writeValueAsString(patGroupCustomForPgs));
      }
    }
    // mod #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 end
    patMainDao.updateById(pat_id, patMain);
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(patUnique,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    // del 8669 【デグレ】患者情報画面内の感染症リストがマスタと一致していない 関 start
    // #8297 患者固有情報 身体情報 ソートの問題 sichengbo start
//    List<LinkedHashMap<String,Object>> list = ObjectMapperUtil.readListOfLinkedHashMap(patUnique.getPhysical_info());
//    if (CollectionUtils.isNotEmpty(list)){
//      List<LinkedHashMap<String,Object>> physicalInfoItemList = new LinkedList<>();
//      for (LinkedHashMap map : list){
//        physicalInfoItemList.add(0, map);
//      }
//      Gson gson = new GsonBuilder().serializeNulls().create();
//      patUnique.setPhysical_info(gson.toJson(physicalInfoItemList));
//    }
    // #8297 患者固有情報 身体情報 ソートの問題 sichengbo end
    // del 8669 【デグレ】患者情報画面内の感染症リストがマスタと一致していない 関 end

    // #10710 ADD START
    // Update OrdMain's data: target_weight at ind_cond & so on.
    // get these params for updating.
    String facilityCd = patUnique.getFacility_cd();
//    String editMod = payload.get("dw_edit_mod");
    String savePhysicalItem = payload.get("save_physical_item");
    // add 10626 データリストのCTR・DW一括登録修正 房 start
    int updCnt = 0;
    // add 10626 データリストのCTR・DW一括登録修正 房 end

    // Param rationality verification
    if (StringUtils.hasText(savePhysicalItem)) {
      NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
      // read the edit record as JsonNode
      JsonNode savePhysicalItemNode = this.objectMapper.readTree(savePhysicalItem);
      // 患者情報から身体情報(DW，目標体重)を登録しての時、Mongoに保存する
      String logDate = new SimpleDateFormat(FORMAT_DATE).format(new Date());
      selectHistoryUtils.insertLogIntoMongo(payload, pat_id, patUniqueHaiTa, logDate);

      // init logic edit params
      List<OrdMainTreatDate> effectsOrdNos = null;
      boolean editedDw = savePhysicalItemNode.hasNonNull("dw");
      boolean editedTw = savePhysicalItemNode.hasNonNull("target_weight");

      // get timeLine before upd PhysicalInfo.
      List<PatDWEffectsTimeLineDTO> beforeModTimeLine = this.patUniqueDao.selectDwEffectsTimeLine(pat_id);

      // mod 10626 データリストのCTR・DW一括登録修正 房 start
      // upd PhysicalInfo
      //int updCnt = this.patUniqueDao.updatePhysicalInfoById(pat_id, patUnique);
      updCnt = this.patUniqueDao.updateById(pat_id, patUnique);
      // mod 10626 データリストのCTR・DW一括登録修正 房 end

      // get timeLine after upd PhysicalInfo.
      List<PatDWEffectsTimeLineDTO> afterModTimeLine = this.patUniqueDao.selectDwEffectsTimeLine(pat_id);

      // we can find the time period affected by changed record now.
      if (editedDw) {
        List<PatDWEffectsTimeLineDTO> effectsIntervalList = this.findChangedInterval(
          "I",
          savePhysicalItemNode.hasNonNull("ctl_no") ? savePhysicalItemNode.get("ctl_no").asInt() : 0,
          beforeModTimeLine, afterModTimeLine
        );

        // find the affected interval, then mapping the ordMain & patIndApprove.
        if (CollectionUtils.isNotEmpty(effectsIntervalList)) {
          effectsOrdNos = this.updDwIndApprove(facilityCd, pat_id, effectsIntervalList);
        }
        // if there has affect on target weight, we also need to upd the pat's ordMain records.
        if (updCnt > 0
          && editedTw
          && savePhysicalItemNode.hasNonNull("indicator_start_date")) {

          List<OrdMainTreatDate> targetWeightEIList =
            this.updateTargetWeightByPhysicalInfo(facilityCd, pat_id, savePhysicalItemNode, user.getUserId(), logDate);

          // find out affected ordNo, these ordMain need send journal
          if (CollectionUtils.isNotEmpty(targetWeightEIList)) {
            if (CollectionUtils.isNotEmpty(effectsOrdNos)) {
              List<Long> dwODList = effectsOrdNos.stream().map(OrdMainTreatDate::getOrdNo).toList();
              List<Long> twODList = targetWeightEIList.stream().map(OrdMainTreatDate::getOrdNo).toList();
              //
              effectsOrdNos.addAll(
                targetWeightEIList.stream()
                  .filter(rec -> twODList.stream().filter(no -> !dwODList.contains(no)).toList().contains(rec.getOrdNo()))
                  .toList()
              );
            } else {
              effectsOrdNos = targetWeightEIList;
            }
          }
        }
        this.createJournalForInsertLog(logDate, patUniqueHaiTa);
      }

      // 身体情報のDW、目標体重設定するの目標体重、変更の相関のジャーナル作成
      if (CollectionUtils.isNotEmpty(effectsOrdNos)) {
        journalService.sendJournalForDwAndTw(pat_id, effectsOrdNos, user.getUserId(), facilityCd, "I"
          , savePhysicalItemNode.get("exam_date").asText());
        // mod #10553 連携イベント発生部分不正【最優先】ope_cd修正 荘 2024-07-30 start
        // }
      } else {
        journalService.sendJournalForNotDwAndTw(pat_id, user.getUserId(), facilityCd, "I"
          , savePhysicalItemNode.get("exam_date").asText());
      }
      // mod #10553 連携イベント発生部分不正【最優先】ope_cd修正 荘 2024-07-30 end
    }

    // mod 10626 データリストのCTR・DW一括登録修正 房 start
    if(updCnt == 0) {
    patUniqueDao.updateById(pat_id, patUnique);
    }
    // mod 10626 データリストのCTR・DW一括登録修正 房 end
    // #10710 ADD END

    if(mongoTemplate != null) {
      //add #10532 mongoDBがダウン中の操作について（新患登録） limingzhe start
      try {
        if (MongoHealthCheckService.getMongoDBConnected()) {
      //add #10532 mongoDBがダウン中の操作について（新患登録） limingzhe end
          // mod #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
          PatInfo patInfo = new PatInfo();
          patInfo.setPatPersonalMain(patPersonalMain);
          patInfo.setPatMain(patMain);
          patInfo.setPatUnique(patUnique);
          List<PatGroupCustom> patGroupCustoms = new ArrayList<PatGroupCustom>();
          if (payload.containsKey("pat_group_info")) {
            Map maps = BasicDBObject.parse(payload.get("pat_group_info"));
            List<Map<String, Object>> patGroupDetailT = ObjectMapperUtil.readListOfMap(maps.get("pat_group_list").toString());
            for (int i = 0; i < patGroupDetailT.size(); i++) {
              PatGroupCustom patGroupCustom = new PatGroupCustom();
              if (patGroupDetailT.get(i).containsKey("patGroupCd")) {
                // mod #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 start
//                patGroupCustom.setPatGroupCd(Integer.parseInt(patGroupDetailT.get(i).get("patGroupCd").toString()));
                patGroupCustom.setPatGroupCd(patGroupDetailT.get(i).get("patGroupCd").toString());
                // mod #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 end
              }
              if (patGroupDetailT.get(i).containsKey("patGroupName")) {
                patGroupCustom.setPatGroupName(patGroupDetailT.get(i).get("patGroupName").toString());
              }
              patGroupCustoms.add(patGroupCustom);
            }
          }
          if (patGroupCustoms != null) {
            patInfo.setPatGroupList(patGroupCustoms);
          }
          // mod 10626 データリストのCTR・DW一括登録修正 房 start
          if(patInfos == null) {
            RestTemplate rt = new RestTemplate();
            URI uri = new URI(webApi + "/util/insertPatToMongo");
            RequestEntity<PatInfo> request = RequestEntity
              .put(uri)
              .contentType(MediaType.APPLICATION_JSON)
              .header("SSECCAYEK", "NTSS-NKK-ESM-TDC-YSK")
              .body(patInfo);
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
            long start = System.currentTimeMillis();
            ResponseEntity<Object> response = rt.exchange(request, Object.class);
            long cost = System.currentTimeMillis() - start;
            Map<String, Object> map = new HashMap<>();
            map.put("logType", "RESTTEMPLATE-LOG");
            map.put("className", "jp.co.nikkiso.ntss.admin_web.service.PatInfoService");
            map.put("methodName", "updateById");
            map.put("method", request.getMethod());
            map.put("url", uri.getPath());
            map.put("headers", request.getHeaders());
            map.put("requestParameter", request.getBody());
            map.put("status",response.getStatusCode());
            map.put("cost", cost);
            map.put("result",response.getBody());
            EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
            restTemplateEventLogMessage.setLogMessage(toJson(map));
            logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
          } else {
            patInfos.add(patInfo);
          }
          // mod 10626 データリストのCTR・DW一括登録修正 房 end
          // mod #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end
      //add #10532 mongoDBがダウン中の操作について（新患登録） limingzhe start
        }
      } catch (DataAccessResourceFailureException exception) {
        MongoHealthCheckService.setMongoDBConnected(false);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//            exception.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(exception));
          if (!StringUtils.isEmpty(facilityCd)) {
            eventLogMessage.setFacilityCd(facilityCd);
          }
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      }
      //add #10532 mongoDBがダウン中の操作について（新患登録） limingzhe end

    }
    // add FNSI-MongoDB 関 end
    //del #10412 次患者更新関連全体見直し対応 朴 start
//    if ("true".equals(payload.get("is_changed_next_pat_info")) && pat_id != null && patPersonalMain.getFacility_cd() != null) {
//      String facilityCd = patPersonalMain.getFacility_cd();
//      comSvNotifySetNextPatInfo(facilityCd, pat_id);
//    }
    //del #10412 次患者更新関連全体見直し対応 朴 end
    // マルチ患者一覧からの更新処理では患者グループ情報が存在せずエラーしていたため判定を追加
    if (payload.get("pat_group_info") != null) {
      Map<String, String> patGroupList =  mapper.readValue(payload.get("pat_group_info"),  new TypeReference<Map<String, String>>() {});
      List<PatGroup> patGroup =  mapper.readValue(patGroupList.get("pat_group_list"),  new TypeReference<List<PatGroup>>() {});
      // del 6931 【デグレ】患者情報を編集した際ログに編集していない感染症を編集した記録が残る 周安寧　start
      // add 6471 患者グループの編集した記録がログに残らない 周安寧 start
      //List<PatGroupDetail> patGroupDetailOld = patGroupDetailDao.selectPatGroupDetailByPatId(pat_id);
      // add 6471 患者グループの編集した記録がログに残らない 周安寧 end
      // del 6931 【デグレ】患者情報を編集した際ログに編集していない感染症を編集した記録が残る 周安寧　end
      patGroupDetailDao.deleteByPatId(pat_id);
      // del 6931 【デグレ】患者情報を編集した際ログに編集していない感染症を編集した記録が残る 周安寧　start
      // add 6471 患者グループの編集した記録がログに残らない 周安寧 start
      //for (PatGroupDetail item : patGroupDetailOld) {
        //outputLogForNoJosn("患者グループID",convertString(item.getPatGroupCd()),"",pat_id,patPersonalMain.getFacility_cd(),"患者情報","患者グループ詳細");
        //outputLogForNoJosn("患者ID",convertString(item.getPatId()),"",pat_id,patPersonalMain.getFacility_cd(),"患者情報","患者グループ詳細");
        //outputLogForNoJosn("施設コード",convertString(item.getFacilityCd()),"",pat_id,patPersonalMain.getFacility_cd(),"患者情報","患者グループ詳細");
      //}
      // add 6471 患者グループの編集した記録がログに残らない 周安寧 end
      // del 6931 【デグレ】患者情報を編集した際ログに編集していない感染症を編集した記録が残る 周安寧　end
          PatGroupDetail patGroupDetail = new PatGroupDetail();
          for (PatGroup item : patGroup) {
              patGroupDetail.setPatGroupCd(item.getPatGroupCd());
              patGroupDetail.setPatId(pat_id);
              patGroupDetail.setFacilityCd(patPersonalMain.getFacility_cd());
              patGroupDetailDao.insert(patGroupDetail);
            // del 6931 【デグレ】患者情報を編集した際ログに編集していない感染症を編集した記録が残る 周安寧　start
            // add 6471 患者グループの編集した記録がログに残らない 周安寧 start
            //outputLogForNoJosn("患者グループID","",convertString(item.getPatGroupCd()),pat_id,patPersonalMain.getFacility_cd(),"患者情報","患者グループ詳細");
            //outputLogForNoJosn("患者ID","",convertString(pat_id),pat_id,patPersonalMain.getFacility_cd(),"患者情報","患者グループ詳細");
            //outputLogForNoJosn("施設コード","",convertString(patPersonalMain.getFacility_cd()),pat_id,patPersonalMain.getFacility_cd(),"患者情報","患者グループ詳細");
            // add 6471 患者グループの編集した記録がログに残らない 周安寧 end
            // del 6931 【デグレ】患者情報を編集した際ログに編集していない感染症を編集した記録が残る 周安寧　end
        }
      // add 6931 【デグレ】患者情報を編集した際ログに編集していない感染症を編集した記録が残る 周安寧 start
      // 削除
      JSONArray delPatGroupCd = new JSONArray(patGroupDiff.getString("delete_pat_group_cd"));
      for (int idxDel = 0; idxDel < delPatGroupCd.length(); idxDel++) {
        Long patGroupCd = delPatGroupCd.getLong(idxDel);
        outputLogForNoJosn("患者グループID",convertString(patGroupCd),"",pat_id,patPersonalMain.getFacility_cd(),"患者情報","患者グループ詳細");
        outputLogForNoJosn("患者ID",convertString(pat_id),"",pat_id,patPersonalMain.getFacility_cd(),"患者情報","患者グループ詳細");
        outputLogForNoJosn("施設コード",convertString(patPersonalMain.getFacility_cd()),"",pat_id,patPersonalMain.getFacility_cd(),"患者情報","患者グループ詳細");
      }

      JSONArray addPatGroupCd = new JSONArray(patGroupDiff.getString("add_pat_group_cd"));
      for (int idxAdd = 0; idxAdd < addPatGroupCd.length(); idxAdd++) {
        Long patGroupCd = addPatGroupCd.getLong(idxAdd);
        PatGroup patGroupADD = patGroupDao.selectById(patGroupCd, patPersonalMain.getFacility_cd());
        outputLogForNoJosn("患者グループID","",convertString(patGroupCd),pat_id,patPersonalMain.getFacility_cd(),"患者情報","患者グループ詳細");
        outputLogForNoJosn("患者ID","",convertString(pat_id),pat_id,patPersonalMain.getFacility_cd(),"患者情報","患者グループ詳細");
        outputLogForNoJosn("施設コード","",convertString(patPersonalMain.getFacility_cd()),pat_id,patPersonalMain.getFacility_cd(),"患者情報","患者グループ詳細");
      }
      // add 6931 【デグレ】患者情報を編集した際ログに編集していない感染症を編集した記録が残る 周安寧 end
    }
  }

  @Autowired
  private IndHistoryMakeService indHistoryMakeService;

  @Autowired
  @DefaultDb
  private Config defaultDbConfig;

  public void createJournalForInsertLog(String logDate, PatUnique patUniqueHaiTa) {
	    try {
	      IndHistory indHistory = new IndHistory();
	      // callCreateJournalで必要な情報を設定
	      indHistory.setLogDate(logDate);
	      indHistory.setFacilityCd(patUniqueHaiTa.getFacility_cd());
	      indHistory.setPatId(String.valueOf(patUniqueHaiTa.getPat_id()));

	      // 現在のユーザー情報を取得
	      try {
	        NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
	        indHistory.setCreatedUserId(user.getUserId());
	      } catch (Exception userEx) {
	        // ユーザー情報が取得できない場合はデフォルト値を設定
	        indHistory.setCreatedUserId(Long.parseLong("-1"));
	      }

	      indHistoryMakeService.callCreateJournal(indHistory);
	    } catch (Exception e) {
	      // Journal作成に失敗した場合も処理は継続
	    }
	  }

  // add 6471 患者グループの編集した記録がログに残らない 周安寧 start
  private void outputLogForNoJosn(String column, String oldValue, String newValue,
                                          Long pat_id ,String facility_cd,String functionName,String tableName){
    EventLogMessage eventLogMessage = null;
    /** Jsonがないコラムのメッセージ */
    String LOG_MESSAGE_NO_JSON = "[%s]の[%s]が[%s]→[%s]に変更されました。";
    String logMessage = "";
    eventLogMessage = new EventLogMessage();
    eventLogMessage.setInvokeClass(this.getClass().getName());
    eventLogMessage.setPatId(convertString(pat_id));
    eventLogMessage.setFacilityCd(facility_cd);
    NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    eventLogMessage.setUserId(user.getUserId().toString());
    logMessage = String.format(LOG_MESSAGE_NO_JSON, tableName,
      column,
      convertString(oldValue),
      convertString(newValue));
    eventLogMessage.setLogMessage(logMessage);
    eventLogMessage.setClientIp(user.getClientIpAddress());
    eventLogMessage.setEc2Identification(LogObjectUtils.getHostAddress());
    eventLogMessage.setFunctionName(functionName);
    logServiceCore.log(LogLevel.INFO, eventLogMessage, "", "", "",null);
  }
  // add 6471 患者グループの編集した記録がログに残らない 周安寧 end
  // add FNSI-add encryption 関 start
  private String getPersonalInfoEncrypt(String inData) {
    if (StringUtils.isEmpty(inData)) {
      return "";
    }
    String returnValue = "";
    Config config = personalDbConfig;
    SelectBuilder selectBuilder = SelectBuilder.newInstance(config);
    selectBuilder.sql("select personal_info_encrypt('" + inData +"') as encrypt_value");
    List<Map<String, Object>> results = selectBuilder.getMapResultList(MapKeyNamingType.NONE);

    if (results.isEmpty()) {
      return "";
    }

    for (Map<String, Object> result : results) {
      returnValue = convertString(result.get("encrypt_value"));
      break;
    }

    return returnValue;
  }
  private String getEncrypt(String stringData) {
    if (stringData == null || stringData.equals("")) {
      return "";
    }
    else {
      return DataUpdateLogCommonNew.CUT_STR+getPersonalInfoEncrypt(stringData)+DataUpdateLogCommonNew.CUT_STR;
    }
  }
  // add FNSI-add encryption 関 end
  @Transactional
  public void updateInsuById(PatInsuInfo patInsuInfo) throws Exception {
    //add 10532 mongoDBがダウン中の操作について（新患登録） xuehongda start
    PatInsurance patInsuranceHaiTa = patInsuranceDao.selectById(patInsuInfo.getInsurance_cd());
    if (patInsuInfo.getOld_up_date() != null && patInsuranceHaiTa != null) {
      if (!patInsuInfo.getOld_up_date().equals(patInsuranceHaiTa.getOld_up_date())) {
        throw new OptimisticLockException(SqlLogType.NONE, SqlKind.UPDATE, "", "", "");
      }
    } else if (patInsuInfo.getOld_up_date() != null && patInsuranceHaiTa == null) {
      throw new OptimisticLockException(SqlLogType.NONE, SqlKind.UPDATE, "", "", "");
    }
    //  add 10525 保険区分が「セット」のときクラス「処方情報」が出力できない 関  start
    // 保険情報
    if (patInsuInfo.getInsu_class().equals(0)) {
      patInsuInfo.setInsu_pub_info(null);
      patInsuInfo.setInsu_set_info(null);
      patInsuInfo.setInsu_self_info(null);
      // 公費情報
    }else if(patInsuInfo.getInsu_class().equals(1)) {
      patInsuInfo.setInsu_info(null);
      patInsuInfo.setInsu_set_info(null);
      patInsuInfo.setInsu_self_info(null);
      // セット情報
    }else if(patInsuInfo.getInsu_class().equals(2)) {
      patInsuInfo.setInsu_info(null);
      patInsuInfo.setInsu_self_info(null);
      patInsuInfo.setInsu_pub_info(null);
      // 自費情報
    }else if (patInsuInfo.getInsu_class().equals(3)) {
      patInsuInfo.setInsu_info(null);
      patInsuInfo.setInsu_set_info(null);
      patInsuInfo.setInsu_pub_info(null);
    }
    //  add 10525 保険区分が「セット」のときクラス「処方情報」が出力できない 関  end
    if ("0".equals(patInsuInfo.getIs_del())) {
      patInsuranceDao.updateById(patInsuInfo);
    } else {
      patInsuranceDao.updateByIdDel(patInsuInfo);
    }
    //add 10532 mongoDBがダウン中の操作について（新患登録） xuehongda end
    //add #10532 mongoDBがダウン中の操作について（新患登録） limingzhe start
    try {
      if (MongoHealthCheckService.getMongoDBConnected()) {
    //add #10532 mongoDBがダウン中の操作について（新患登録） limingzhe end
        // mod #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
        List<PatInsuInfo> patInsuInfos = new ArrayList<PatInsuInfo>();
        patInsuInfos.add(patInsuInfo);
        RestTemplate rtForInsurance = new RestTemplate();
        URI uriForInsu = new URI(webApi + "/util/bulkUpdatePatInsu");
        RequestEntity<List<PatInsuInfo>> requestForInsurance = RequestEntity
          .put(uriForInsu)
          .contentType(MediaType.APPLICATION_JSON)
          .header("SSECCAYEK", "NTSS-NKK-ESM-TDC-YSK")
          .body(patInsuInfos);
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
        long start = System.currentTimeMillis();
        ResponseEntity<Object> response = rtForInsurance.exchange(requestForInsurance, Object.class);
        long cost = System.currentTimeMillis() - start;
        Map<String, Object> map = new HashMap<>();
        map.put("logType", "RESTTEMPLATE-LOG");
        map.put("className", "jp.co.nikkiso.ntss.admin_web.service.PatInfoService");
        map.put("methodName", "updateInsuById");
        map.put("method", requestForInsurance.getMethod());
        map.put("url", uriForInsu.getPath());
        map.put("headers", requestForInsurance.getHeaders());
        map.put("requestParameter", requestForInsurance.getBody());
        map.put("status",response.getStatusCode());
        map.put("cost", cost);
        map.put("result",response.getBody());
        EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
        restTemplateEventLogMessage.setLogMessage(toJson(map));
        if (patInsuInfo != null && org.apache.commons.lang3.StringUtils.isNotEmpty(patInsuInfo.getFacility_cd())) {
          restTemplateEventLogMessage.setFacilityCd(patInsuInfo.getFacility_cd());
        }
        logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
        // mod #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end
    //add #10532 mongoDBがダウン中の操作について（新患登録） limingzhe start
      }
    } catch (DataAccessResourceFailureException exception) {
      MongoHealthCheckService.setMongoDBConnected(false);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//            exception.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(exception));
          if (patInsuInfo != null && !StringUtils.isEmpty(patInsuInfo.getFacility_cd())) {
            eventLogMessage.setFacilityCd(patInsuInfo.getFacility_cd());
          }
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }
    //add #10532 mongoDBがダウン中の操作について（新患登録） limingzhe end
  }

  @Transactional
  public void updateBulkUpdatePatInsu(List<PatInsuInfo> patInsuInfos) throws Exception {
    //add 10532 mongoDBがダウン中の操作について（新患登録） xuehongda start
    List<PatInsuInfo> updatePatInsuInfos = new ArrayList<>();
    for (PatInsuInfo patInsuInfo : patInsuInfos) {
      PatInsurance patInsuranceHaiTa = patInsuranceDao.selectById(patInsuInfo.getInsurance_cd());
      if (patInsuInfo.getOld_up_date() != null && patInsuranceHaiTa != null) {
        if (!patInsuInfo.getOld_up_date().equals(patInsuranceHaiTa.getOld_up_date())) {
          throw new OptimisticLockException(SqlLogType.NONE, SqlKind.UPDATE, "", "", "");
        }
      } else if (patInsuInfo.getOld_up_date() != null && patInsuranceHaiTa == null) {
        throw new OptimisticLockException(SqlLogType.NONE, SqlKind.UPDATE, "", "", "");
      }
      // 保険情報
      if (patInsuInfo.getInsu_class().equals(0)) {
        patInsuInfo.setInsu_pub_info(null);
        patInsuInfo.setInsu_set_info(null);
        patInsuInfo.setInsu_self_info(null);
        // 公費情報
      } else if (patInsuInfo.getInsu_class().equals(1)) {
        patInsuInfo.setInsu_info(null);
        patInsuInfo.setInsu_set_info(null);
        patInsuInfo.setInsu_self_info(null);
        // セット情報
      } else if (patInsuInfo.getInsu_class().equals(2)) {
        patInsuInfo.setInsu_info(null);
        patInsuInfo.setInsu_self_info(null);
        patInsuInfo.setInsu_pub_info(null);
        // 自費情報
      } else if (patInsuInfo.getInsu_class().equals(3)) {
        patInsuInfo.setInsu_info(null);
        patInsuInfo.setInsu_set_info(null);
        patInsuInfo.setInsu_pub_info(null);
      }
      patInsuranceDao.updateById(patInsuInfo);
      updatePatInsuInfos.add(patInsuInfo);
    }
    //add 10532 mongoDBがダウン中の操作について（新患登録） xuehongda end
    //add #10532 mongoDBがダウン中の操作について（新患登録） limingzhe start
    try {
      if (MongoHealthCheckService.getMongoDBConnected()) {
    //add #10532 mongoDBがダウン中の操作について（新患登録） limingzhe end
        // mod #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
        RestTemplate rtForInsurance = new RestTemplate();
        URI uriForInsu = new URI(webApi + "/util/bulkUpdatePatInsu");
        RequestEntity<List<PatInsuInfo>> requestForInsurance = RequestEntity
          .put(uriForInsu)
          .contentType(MediaType.APPLICATION_JSON)
          .header("SSECCAYEK", "NTSS-NKK-ESM-TDC-YSK")
          //mod 10532 mongoDBがダウン中の操作について（新患登録） xuehongda start
          .body(updatePatInsuInfos);
          //mod 10532 mongoDBがダウン中の操作について（新患登録） xuehongda end
        rtForInsurance.exchange(requestForInsurance, Object.class);
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
        long start = System.currentTimeMillis();
        ResponseEntity<Object> response = rtForInsurance.exchange(requestForInsurance, Object.class);
        long cost = System.currentTimeMillis() - start;
        Map<String, Object> map = new HashMap<>();
        map.put("logType", "RESTTEMPLATE-LOG");
        map.put("className", "jp.co.nikkiso.ntss.admin_web.service.PatInfoService");
        map.put("methodName", "updateBulkUpdatePatInsu");
        map.put("method", requestForInsurance.getMethod());
        map.put("url", uriForInsu.getPath());
        map.put("headers", requestForInsurance.getHeaders());
        map.put("requestParameter", requestForInsurance.getBody());
        map.put("status",response.getStatusCode());
        map.put("cost", cost);
        map.put("result",response.getBody());
        EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
        restTemplateEventLogMessage.setLogMessage(toJson(map));
        logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
        // mod #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end
    //add #10532 mongoDBがダウン中の操作について（新患登録） limingzhe start
      }
    } catch (DataAccessResourceFailureException exception) {
      MongoHealthCheckService.setMongoDBConnected(false);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//            exception.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(exception));
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }
    //add #10532 mongoDBがダウン中の操作について（新患登録） limingzhe end
  }
  //  add 10525 保険区分が「セット」のときクラス「処方情報」が出力できない 関  start
  @Transactional
  public void updateUpdatePatInsu(List<PatInsuInfo> patInsuInfos) throws Exception {
    //add 10532 mongoDBがダウン中の操作について（新患登録） xuehongda start
    List<PatInsuInfo> updatePatInsuInfos = new ArrayList<>();
    for (PatInsuInfo patInsuInfo : patInsuInfos) {
      PatInsurance patInsuranceHaiTa = patInsuranceDao.selectById(patInsuInfo.getInsurance_cd());
      if (patInsuInfo.getOld_up_date() != null && patInsuranceHaiTa != null) {
        if (!patInsuInfo.getOld_up_date().equals(patInsuranceHaiTa.getOld_up_date())) {
          throw new OptimisticLockException(SqlLogType.NONE, SqlKind.UPDATE, "", "", "");
        }
      } else if (patInsuInfo.getOld_up_date() != null && patInsuranceHaiTa == null) {
        throw new OptimisticLockException(SqlLogType.NONE, SqlKind.UPDATE, "", "", "");
      }
      // 保険情報
      if (patInsuInfo.getInsu_class().equals(0)) {
        patInsuInfo.setInsu_pub_info(null);
        patInsuInfo.setInsu_set_info(null);
        patInsuInfo.setInsu_self_info(null);
        // 公費情報
      } else if (patInsuInfo.getInsu_class().equals(1)) {
        patInsuInfo.setInsu_info(null);
        patInsuInfo.setInsu_set_info(null);
        patInsuInfo.setInsu_self_info(null);
        // セット情報
      } else if (patInsuInfo.getInsu_class().equals(2)) {
        patInsuInfo.setInsu_info(null);
        patInsuInfo.setInsu_self_info(null);
        patInsuInfo.setInsu_pub_info(null);
        // 自費情報
      } else if (patInsuInfo.getInsu_class().equals(3)) {
        patInsuInfo.setInsu_info(null);
        patInsuInfo.setInsu_set_info(null);
        patInsuInfo.setInsu_pub_info(null);
      }
      patInsuranceDao.updateById(patInsuInfo);
      updatePatInsuInfos.add(patInsuInfo);
    }
    //add 10532 mongoDBがダウン中の操作について（新患登録） xuehongda end
    try {
      if (MongoHealthCheckService.getMongoDBConnected()) {
        RestTemplate rtForInsurance = new RestTemplate();
        URI uriForInsu = new URI(webApi + "/util/allUpdatePatInsu");
        RequestEntity<List<PatInsuInfo>> requestForInsurance = RequestEntity
          .put(uriForInsu)
          .contentType(MediaType.APPLICATION_JSON)
          .header("SSECCAYEK", "NTSS-NKK-ESM-TDC-YSK")
          //mod 10532 mongoDBがダウン中の操作について（新患登録） xuehongda start
          .body(updatePatInsuInfos);
          //mod 10532 mongoDBがダウン中の操作について（新患登録） xuehongda end
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
        long start = System.currentTimeMillis();
        ResponseEntity<Object> response = rtForInsurance.exchange(requestForInsurance, Object.class);
        long cost = System.currentTimeMillis() - start;
        Map<String, Object> map = new HashMap<>();
        map.put("logType", "RESTTEMPLATE-LOG");
        map.put("className", "jp.co.nikkiso.ntss.admin_web.service.PatInfoService");
        map.put("methodName", "updateUpdatePatInsu");
        map.put("method", requestForInsurance.getMethod());
        map.put("url", uriForInsu.getPath());
        map.put("headers", requestForInsurance.getHeaders());
        map.put("requestParameter", requestForInsurance.getBody());
        map.put("status",response.getStatusCode());
        map.put("cost", cost);
        map.put("result",response.getBody());
        EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
        restTemplateEventLogMessage.setLogMessage(toJson(map));
        logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
      }
    } catch (DataAccessResourceFailureException exception) {
      MongoHealthCheckService.setMongoDBConnected(false);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//            exception.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(exception));
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }
  }
  //  add 10525 保険区分が「セット」のときクラス「処方情報」が出力できない 関  end
  @Transactional
  public void insertInsu(PatInsuInfo patInsuInfo) throws Exception {
    Long nextSeqInsuId = patInsuranceDao.selectNextSeqInsuCd();
    patInsuInfo.setInsurance_cd(nextSeqInsuId);
    //  add 10525 保険区分が「セット」のときクラス「処方情報」が出力できない 関  start
    // 保険情報
    if (patInsuInfo.getInsu_class().equals(0)) {
      patInsuInfo.setInsu_pub_info(null);
      patInsuInfo.setInsu_set_info(null);
      patInsuInfo.setInsu_self_info(null);
      // 公費情報
    }else if(patInsuInfo.getInsu_class().equals(1)) {
      patInsuInfo.setInsu_info(null);
      patInsuInfo.setInsu_set_info(null);
      patInsuInfo.setInsu_self_info(null);
      // セット情報
    }else if(patInsuInfo.getInsu_class().equals(2)) {
      patInsuInfo.setInsu_info(null);
      patInsuInfo.setInsu_self_info(null);
      patInsuInfo.setInsu_pub_info(null);
      // 自費情報
    }else if (patInsuInfo.getInsu_class().equals(3)) {
      patInsuInfo.setInsu_info(null);
      patInsuInfo.setInsu_set_info(null);
      patInsuInfo.setInsu_pub_info(null);
    }
    //  add 10525 保険区分が「セット」のときクラス「処方情報」が出力できない 関  end
    patInsuranceDao.insert(patInsuInfo);
    // add #10193 身体情報と保険情報の保存でがmongodbの患者情報履歴に登録されない。 dengshen start
    if(mongoTemplate != null) {
      // mod #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
      PatInsurance insuInfo = patInsuranceDao.selectByCd(patInsuInfo.getInsurance_cd());
      if(insuInfo == null) return;
      Timestamp now = new Timestamp(new Date().getTime());
      PatInsuranceHistory patInsuranceHistory = new PatInsuranceHistory();
      BeanUtils.copyProperties(insuInfo, patInsuranceHistory);
      // mod #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end
      patInsuranceHistory.setIns_date(now);
      String pat_idR = patInsuInfo.getPat_id().toString();
      patInsuranceHistory.setPat_id(pat_idR);
      //  mod 10525 保険区分が「セット」のときクラス「処方情報」が出力できない 崔  start
      LocalDateTime currentTime = LocalDateTime.now();
      DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSS");
      patInsuranceHistory.setUp_date(currentTime.format(formatter));
      //  mod 10525 保険区分が「セット」のときクラス「処方情報」が出力できない 崔  end
      // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
      if(insuInfo.getInsurance_cd() != null){
        patInsuranceHistory.setInsurance_cd(insuInfo.getInsurance_cd().toString());
      }
      if(insuInfo.getCtl_no() != null){
        patInsuranceHistory.setCtl_no(insuInfo.getCtl_no().toString());
      }
      // セット情報
      JSONObject insuSetInfoJson = new JSONObject(patInsuranceHistory.getInsu_set_info());
      //  mod 10525 保険区分が「セット」のときクラス「処方情報」が出力できない 関  start
      JSONArray insuSetInfo = new JSONArray();
      // 保険名
      String insuCd =  "";
      // mod #10735 患者情報を保存できない dengshen start
      // if(!StringUtils.isEmpty(insuSetInfoJson.get("insu_cd").toString()) && !"null".equals(insuSetInfoJson.get("insu_cd").toString())){
      if(insuSetInfoJson.has("insu_cd") && !StringUtils.isEmpty(insuSetInfoJson.get("insu_cd").toString()) && !"null".equals(insuSetInfoJson.get("insu_cd").toString())){
      // mod #10735 患者情報を保存できない dengshen end
        PatInsurance insuInfo1 = patInsuranceDao.selectByCd(Long.parseLong(String.valueOf(insuSetInfoJson.get("insu_cd"))));
        // add #10735 患者情報を保存できない dengshen start
        if (insuInfo1 != null) {
        // add #10735 患者情報を保存できない dengshen end
        insuCd = insuInfo1.getInsu_name() != null ? insuInfo1.getInsu_name() : "";
        //mod #10510 Number→Staring 杜 start
        //Long insuCode = insuInfo1.getInsurance_cd() != null ? insuInfo1.getInsurance_cd(): null;
        String insuCode = insuInfo1.getInsurance_cd() != null ? insuInfo1.getInsurance_cd().toString(): null;
        String insuInfoName = insuInfo1.getInsu_name() != null ? insuInfo1.getInsu_name() : null;
        //Integer insuClass = insuInfo1.getInsu_class() != null ? insuInfo1.getInsu_class() : null;
        String insuClass = insuInfo1.getInsu_class() != null ? insuInfo1.getInsu_class().toString() : null;
        //mod #10510 Number→Staring 杜 end
        String insuNameShort = insuInfo1.getInsu_name_short() != null ? insuInfo1.getInsu_name_short() : null;

        if(insuInfo.getInsu_class().equals(2)) {
          JSONObject insuInfoJson = new JSONObject(insuInfo1.getInsu_info());
          insuInfoJson.put("insu_cd",insuCode != null && !insuCode.equals("null") ? insuCode : JSONObject.NULL);
          insuInfoJson.put("insu_info_name", insuInfoName != null && !insuInfoName.equals("null") ? insuInfoName : JSONObject.NULL);
          insuInfoJson.put("insu_info_name_short", insuNameShort != null && !insuNameShort.equals("null") ? insuNameShort : JSONObject.NULL);
          insuInfoJson.put("insu_class", insuClass != null && !insuClass.equals("null") ? insuClass : JSONObject.NULL);

          insuSetInfo.put(insuInfoJson);
        }
        // add #10735 患者情報を保存できない dengshen start
        }
        // add #10735 患者情報を保存できない dengshen end
      }
      insuSetInfoJson.put("insu_name", insuCd);
      // 保険情報.公費1
      String insuPub1Cd =  "";
      // mod #10735 患者情報を保存できない dengshen start
      // if(!StringUtils.isEmpty(insuSetInfoJson.get("insu_pub1_cd").toString()) && !"null".equals(insuSetInfoJson.get("insu_pub1_cd").toString())){
      if(insuSetInfoJson.has("insu_pub1_cd") && !StringUtils.isEmpty(insuSetInfoJson.get("insu_pub1_cd").toString()) && !"null".equals(insuSetInfoJson.get("insu_pub1_cd").toString())){
      // mod #10735 患者情報を保存できない dengshen end
        PatInsurance insuInfo1 = patInsuranceDao.selectByCd(Long.parseLong(String.valueOf(insuSetInfoJson.get("insu_pub1_cd").toString())));
        // add #10735 患者情報を保存できない dengshen start
        if (insuInfo1 != null) {
        // add #10735 患者情報を保存できない dengshen end
        insuPub1Cd = insuInfo1.getInsu_name() != null ? insuInfo1.getInsu_name() : "";
        //mod #10510 Number→Staring 杜 start
        //Long insuCode = insuInfo1.getInsurance_cd() != null ? insuInfo1.getInsurance_cd() : null;
        String insuCode = insuInfo1.getInsurance_cd() != null ? insuInfo1.getInsurance_cd().toString() : null;
        String insuInfoName = insuInfo1.getInsu_name() != null ? insuInfo1.getInsu_name() : null;
        //Integer insuClass = insuInfo1.getInsu_class() != null ? insuInfo1.getInsu_class() : null;
        String insuClass = insuInfo1.getInsu_class() != null ? insuInfo1.getInsu_class().toString() : null;
        //mod #10510 Number→Staring 杜 end
        String insuNameShort = insuInfo1.getInsu_name_short() != null ? insuInfo1.getInsu_name_short() : null;

        if(insuInfo.getInsu_class().equals(2)) {
          JSONObject insuPubInfoJson = new JSONObject(insuInfo1.getInsu_pub_info());
          // mod #10735 患者情報を保存できない dengshen start
          // String insuPub1Name = insuPubInfoJson.get("insu_pub_name") != null && !insuPubInfoJson.get("insu_pub_name").equals("null") ? insuPubInfoJson.get("insu_pub_name") .toString() : null;
          // String insuPubNo = insuPubInfoJson.get("insu_pub_no") != null && !insuPubInfoJson.get("insu_pub_no").equals("null") ? insuPubInfoJson.get("insu_pub_no").toString() : null;
          // String insuPubPatNo = insuPubInfoJson.get("insu_pub_pat_no") != null && !insuPubInfoJson.get("insu_pub_pat_no").equals("null") ? insuPubInfoJson.get("insu_pub_pat_no").toString() : null;
          String insuPub1Name = insuPubInfoJson.has("insu_pub_name") && insuPubInfoJson.get("insu_pub_name") != null && !insuPubInfoJson.get("insu_pub_name").equals("null") ? insuPubInfoJson.get("insu_pub_name") .toString() : null;
          String insuPubNo = insuPubInfoJson.has("insu_pub_no") && insuPubInfoJson.get("insu_pub_no") != null && !insuPubInfoJson.get("insu_pub_no").equals("null") ? insuPubInfoJson.get("insu_pub_no").toString() : null;
          String insuPubPatNo = insuPubInfoJson.has("insu_pub_pat_no") && insuPubInfoJson.get("insu_pub_pat_no") != null && !insuPubInfoJson.get("insu_pub_pat_no").equals("null") ? insuPubInfoJson.get("insu_pub_pat_no").toString() : null;
          // mod #10735 患者情報を保存できない dengshen end
          insuPubInfoJson.put("insu_pub1_cd", insuCode != null && !insuCode.equals("null") ? insuCode : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub1_info_name", insuInfoName != null && !insuInfoName.equals("null") ? insuInfoName : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub1_info_name_short", insuNameShort != null && !insuNameShort.equals("null") ? insuNameShort : JSONObject.NULL);
          insuPubInfoJson.put("insu_class", insuClass != null && !insuClass.equals("null") ? insuClass : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub1_name", insuPub1Name != null && !insuPub1Name.equals("null") ? insuPub1Name : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub1_no", insuPubNo != null && !insuPubNo.equals("null") ? insuPubNo : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub1_pat_no",insuPubPatNo != null && !insuPubPatNo.equals("null")? insuPubPatNo : JSONObject.NULL);
          //add #10510 「障害者手帳番号1」拡張 杜天成　start
          // mod #10735 患者情報を保存できない dengshen start
          // insuPubInfoJson.put("insu_pub1_passbook_no",insuPubInfoJson.get("passbook_no") != null && !insuPubInfoJson.get("passbook_no").equals("null")? insuPubInfoJson.get("passbook_no") : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub1_passbook_no", insuPubInfoJson.has("passbook_no") && insuPubInfoJson.get("passbook_no") != null && !insuPubInfoJson.get("passbook_no").equals("null")? insuPubInfoJson.get("passbook_no") : JSONObject.NULL);
          // mod #10735 患者情報を保存できない dengshen end
          insuPubInfoJson.remove("passbook_no");
          //add #10510 「障害者手帳番号1」拡張 杜天成　end
          insuPubInfoJson.remove("insu_pub_name");
          insuPubInfoJson.remove("insu_pub_no");
          insuPubInfoJson.remove("insu_pub_pat_no");

          insuSetInfo.put(insuPubInfoJson);
        }
        // add #10735 患者情報を保存できない dengshen start
        }
        // add #10735 患者情報を保存できない dengshen end
      }
      insuSetInfoJson.put("insu_pub1_name", insuPub1Cd);
      // 保険情報.公費2
      String insuPub2Cd =  "";
      // mod #10735 患者情報を保存できない dengshen start
      // if(!StringUtils.isEmpty(insuSetInfoJson.get("insu_pub2_cd").toString()) && !"null".equals(insuSetInfoJson.get("insu_pub2_cd").toString())){
      if(insuSetInfoJson.has("insu_pub2_cd") && !StringUtils.isEmpty(insuSetInfoJson.get("insu_pub2_cd").toString()) && !"null".equals(insuSetInfoJson.get("insu_pub2_cd").toString())){
      // mod #10735 患者情報を保存できない dengshen end
        PatInsurance insuInfo1 = patInsuranceDao.selectByCd(Long.parseLong(String.valueOf(insuSetInfoJson.get("insu_pub2_cd").toString())));
        // add #10735 患者情報を保存できない dengshen start
        if (insuInfo1 != null) {
        // add #10735 患者情報を保存できない dengshen end
        insuPub2Cd = insuInfo1.getInsu_name() != null ? insuInfo1.getInsu_name() : "";
        //mod #10510 Number→Staring 杜 start
        //Long insuCode = insuInfo1.getInsurance_cd() != null ? insuInfo1.getInsurance_cd() : null;
        String insuCode = insuInfo1.getInsurance_cd() != null ? insuInfo1.getInsurance_cd().toString() : null;
        String insuInfoName = insuInfo1.getInsu_name() != null ? insuInfo1.getInsu_name() : null;
        //Integer insuClass = insuInfo1.getInsu_class() != null ? insuInfo1.getInsu_class() : null;
        String insuClass = insuInfo1.getInsu_class() != null ? insuInfo1.getInsu_class().toString() : null;
        //mod #10510 Number→Staring 杜 end
        String insuNameShort = insuInfo1.getInsu_name_short() != null ? insuInfo1.getInsu_name_short() : null;
        if(insuInfo.getInsu_class().equals(2)) {
          JSONObject insuPubInfoJson = new JSONObject(insuInfo1.getInsu_pub_info());
          // mod #10735 患者情報を保存できない dengshen start
          // String insuPub1Name = insuPubInfoJson.get("insu_pub_name") != null && !insuPubInfoJson.get("insu_pub_name").equals("null") ? insuPubInfoJson.get("insu_pub_name").toString() : null;
          // String insuPubNo = insuPubInfoJson.get("insu_pub_no") != null && !insuPubInfoJson.get("insu_pub_no").equals("null") ? insuPubInfoJson.get("insu_pub_no").toString() : null;
          // String insuPubPatNo = insuPubInfoJson.get("insu_pub_pat_no") != null && !insuPubInfoJson.get("insu_pub_pat_no").equals("null") ? insuPubInfoJson.get("insu_pub_pat_no").toString() : null;
          String insuPub1Name = insuPubInfoJson.has("insu_pub_name") && insuPubInfoJson.get("insu_pub_name") != null && !insuPubInfoJson.get("insu_pub_name").equals("null") ? insuPubInfoJson.get("insu_pub_name").toString() : null;
          String insuPubNo = insuPubInfoJson.has("insu_pub_no") && insuPubInfoJson.get("insu_pub_no") != null && !insuPubInfoJson.get("insu_pub_no").equals("null") ? insuPubInfoJson.get("insu_pub_no").toString() : null;
          String insuPubPatNo = insuPubInfoJson.has("insu_pub_pat_no") && insuPubInfoJson.get("insu_pub_pat_no") != null && !insuPubInfoJson.get("insu_pub_pat_no").equals("null") ? insuPubInfoJson.get("insu_pub_pat_no").toString() : null;
          // mod #10735 患者情報を保存できない dengshen end

          insuPubInfoJson.put("insu_pub2_cd", insuCode != null && !insuCode.equals("null") ? insuCode : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub2_info_name", insuInfoName != null && !insuInfoName.equals("null") ? insuInfoName : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub2_info_name_short", insuNameShort != null && !insuNameShort.equals("null") ? insuNameShort : JSONObject.NULL);
          insuPubInfoJson.put("insu_class", insuClass != null && !insuClass.equals("null") ? insuClass : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub2_name", insuPub1Name != null && !insuPub1Name.equals("null") ? insuPub1Name : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub2_no", insuPubNo != null && !insuPubNo.equals("null") ? insuPubNo : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub2_pat_no",insuPubPatNo != null && !insuPubPatNo.equals("null") ? insuPubPatNo : JSONObject.NULL);
          //add #10510 「障害者手帳番号2」拡張 杜天成　start
          // mod #10735 患者情報を保存できない dengshen start
          // insuPubInfoJson.put("insu_pub2_passbook_no",insuPubInfoJson.get("passbook_no") != null && !insuPubInfoJson.get("passbook_no").equals("null")? insuPubInfoJson.get("passbook_no") : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub2_passbook_no", insuPubInfoJson.has("passbook_no") && insuPubInfoJson.get("passbook_no") != null && !insuPubInfoJson.get("passbook_no").equals("null")? insuPubInfoJson.get("passbook_no") : JSONObject.NULL);
          // mod #10735 患者情報を保存できない dengshen end
          insuPubInfoJson.remove("passbook_no");
          //add #10510 「障害者手帳番号2」拡張 杜天成　end
          insuPubInfoJson.remove("insu_pub_name");
          insuPubInfoJson.remove("insu_pub_no");
          insuPubInfoJson.remove("insu_pub_pat_no");

          insuSetInfo.put(insuPubInfoJson);
        }
        // add #10735 患者情報を保存できない dengshen start
        }
        // add #10735 患者情報を保存できない dengshen end
      }
      insuSetInfoJson.put("insu_pub2_name", insuPub2Cd);
      // 保険情報.公費3
      String insuPub3Cd =  "";
      // mod #10735 患者情報を保存できない dengshen start
      // if(!StringUtils.isEmpty(insuSetInfoJson.get("insu_pub3_cd").toString()) && !"null".equals(insuSetInfoJson.get("insu_pub3_cd").toString())){
      if(insuSetInfoJson.has("insu_pub3_cd") && !StringUtils.isEmpty(insuSetInfoJson.get("insu_pub3_cd").toString()) && !"null".equals(insuSetInfoJson.get("insu_pub3_cd").toString())){
      // mod #10735 患者情報を保存できない dengshen end
        PatInsurance insuInfo1 = patInsuranceDao.selectByCd(Long.parseLong(String.valueOf(insuSetInfoJson.get("insu_pub3_cd").toString())));
        // add #10735 患者情報を保存できない dengshen start
        if (insuInfo1 != null) {
        // add #10735 患者情報を保存できない dengshen end
        insuPub3Cd = insuInfo1.getInsu_name() != null ? insuInfo1.getInsu_name() : "";
        //mod #10510 Number→Staring 杜 start
        //Long insuCode = insuInfo1.getInsurance_cd() != null ? insuInfo1.getInsurance_cd() : null;
        String insuCode = insuInfo1.getInsurance_cd() != null ? insuInfo1.getInsurance_cd().toString() : null;
        String insuInfoName = insuInfo1.getInsu_name() != null ? insuInfo1.getInsu_name() : null;
        //Integer insuClass = insuInfo1.getInsu_class() != null ? insuInfo1.getInsu_class() : null;
        String insuClass = insuInfo1.getInsu_class() != null ? insuInfo1.getInsu_class().toString() : null;
        //mod #10510 Number→Staring 杜 end
        String insuNameShort = insuInfo1.getInsu_name_short() != null ? insuInfo1.getInsu_name_short() : null;
        if(insuInfo.getInsu_class().equals(2)) {
          JSONObject insuPubInfoJson = new JSONObject(insuInfo1.getInsu_pub_info());
          // mod #10735 患者情報を保存できない dengshen start
          // String insuPub1Name = insuPubInfoJson.get("insu_pub_name") != null && !insuPubInfoJson.get("insu_pub_name").equals("null") ? insuPubInfoJson.get("insu_pub_name").toString() : null;
          // String insuPubNo = insuPubInfoJson.get("insu_pub_no") != null && !insuPubInfoJson.get("insu_pub_no").equals("null") ? insuPubInfoJson.get("insu_pub_no").toString() : null;
          // String insuPubPatNo = insuPubInfoJson.get("insu_pub_pat_no") != null && !insuPubInfoJson.get("insu_pub_pat_no").equals("null")  ? insuPubInfoJson.get("insu_pub_pat_no").toString() : null;
          String insuPub1Name = insuPubInfoJson.has("insu_pub_name") && insuPubInfoJson.get("insu_pub_name") != null && !insuPubInfoJson.get("insu_pub_name").equals("null") ? insuPubInfoJson.get("insu_pub_name").toString() : null;
          String insuPubNo = insuPubInfoJson.has("insu_pub_no") && insuPubInfoJson.get("insu_pub_no") != null && !insuPubInfoJson.get("insu_pub_no").equals("null") ? insuPubInfoJson.get("insu_pub_no").toString() : null;
          String insuPubPatNo = insuPubInfoJson.has("insu_pub_pat_no") && insuPubInfoJson.get("insu_pub_pat_no") != null && !insuPubInfoJson.get("insu_pub_pat_no").equals("null")  ? insuPubInfoJson.get("insu_pub_pat_no").toString() : null;
          // mod #10735 患者情報を保存できない dengshen end

          insuPubInfoJson.put("insu_pub3_cd", insuCode != null && !insuCode.equals("null") ? insuCode : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub3_info_name", insuInfoName != null && !insuInfoName.equals("null") ? insuInfoName : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub3_info_name_short", insuNameShort != null && !insuNameShort.equals("null") ? insuNameShort : JSONObject.NULL);
          insuPubInfoJson.put("insu_class", insuClass != null && !insuClass.equals("null") ? insuClass : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub3_name", insuPub1Name != null && !insuPub1Name.equals("null") ? insuPub1Name : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub3_no", insuPubNo != null && !insuPubNo.equals("null") ? insuPubNo : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub3_pat_no",insuPubPatNo != null && !insuPubPatNo.equals("null") ? insuPubPatNo : JSONObject.NULL);
          //add #10510 「障害者手帳番号3」拡張 杜天成　start
          // mod #10735 患者情報を保存できない dengshen start
          // insuPubInfoJson.put("insu_pub3_passbook_no",insuPubInfoJson.get("passbook_no") != null && !insuPubInfoJson.get("passbook_no").equals("null")? insuPubInfoJson.get("passbook_no") : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub3_passbook_no", insuPubInfoJson.has("passbook_no") && insuPubInfoJson.get("passbook_no") != null && !insuPubInfoJson.get("passbook_no").equals("null")? insuPubInfoJson.get("passbook_no") : JSONObject.NULL);
          // mod #10735 患者情報を保存できない dengshen end
          insuPubInfoJson.remove("passbook_no");
          //add #10510 「障害者手帳番号3」拡張 杜天成　end
          insuPubInfoJson.remove("insu_pub_name");
          insuPubInfoJson.remove("insu_pub_no");
          insuPubInfoJson.remove("insu_pub_pat_no");


          insuSetInfo.put(insuPubInfoJson);
        }
        // add #10735 患者情報を保存できない dengshen start
        }
        // add #10735 患者情報を保存できない dengshen end
      }
      insuSetInfoJson.put("insu_pub3_name", insuPub3Cd);
      // 保険情報.公費4
      String insuPub4Cd =  "";
      // mod #10735 患者情報を保存できない dengshen start
      // if(!StringUtils.isEmpty(insuSetInfoJson.get("insu_pub4_cd").toString()) && !"null".equals(insuSetInfoJson.get("insu_pub4_cd").toString())){
      if(insuSetInfoJson.has("insu_pub4_cd") && !StringUtils.isEmpty(insuSetInfoJson.get("insu_pub4_cd").toString()) && !"null".equals(insuSetInfoJson.get("insu_pub4_cd").toString())){
      // mod #10735 患者情報を保存できない dengshen end
        PatInsurance insuInfo1 = patInsuranceDao.selectByCd(Long.parseLong(String.valueOf(insuSetInfoJson.get("insu_pub4_cd").toString())));
        // add #10735 患者情報を保存できない dengshen start
        if (insuInfo1 != null) {
        // add #10735 患者情報を保存できない dengshen end
        insuPub4Cd = insuInfo1.getInsu_name() != null ? insuInfo1.getInsu_name() : "";
        //mod #10510 Number→Staring 杜 start
        //Long insuCode = insuInfo1.getInsurance_cd() != null ? insuInfo1.getInsurance_cd() : null;
        String insuCode = insuInfo1.getInsurance_cd() != null ? insuInfo1.getInsurance_cd().toString() : null;
        String insuInfoName = insuInfo1.getInsu_name() != null ? insuInfo1.getInsu_name() : null;
        //Integer insuClass = insuInfo1.getInsu_class() != null ? insuInfo1.getInsu_class() : null;
        String insuClass = insuInfo1.getInsu_class() != null ? insuInfo1.getInsu_class().toString() : null;
        //mod #10510 Number→Staring 杜 end
        String insuNameShort = insuInfo1.getInsu_name_short() != null ? insuInfo1.getInsu_name_short() : null;
        if(insuInfo.getInsu_class().equals(2)) {
          JSONObject insuPubInfoJson = new JSONObject(insuInfo1.getInsu_pub_info());
          // mod #10735 患者情報を保存できない dengshen start
          // String insuPub1Name = insuPubInfoJson.get("insu_pub_name") != null && !insuPubInfoJson.get("insu_pub_name").equals("null") ? insuPubInfoJson.get("insu_pub_name").toString() : null;
          // String insuPubNo = insuPubInfoJson.get("insu_pub_no") != null && !insuPubInfoJson.get("insu_pub_no").equals("null") ? insuPubInfoJson.get("insu_pub_no").toString() : null;
          // String insuPubPatNo = insuPubInfoJson.get("insu_pub_pat_no") != null && !insuPubInfoJson.get("insu_pub_pat_no").equals("null") ? insuPubInfoJson.get("insu_pub_pat_no").toString() : null;
          String insuPub1Name = insuPubInfoJson.has("insu_pub_name") && insuPubInfoJson.get("insu_pub_name") != null && !insuPubInfoJson.get("insu_pub_name").equals("null") ? insuPubInfoJson.get("insu_pub_name").toString() : null;
          String insuPubNo = insuPubInfoJson.has("insu_pub_no") && insuPubInfoJson.get("insu_pub_no") != null && !insuPubInfoJson.get("insu_pub_no").equals("null") ? insuPubInfoJson.get("insu_pub_no").toString() : null;
          String insuPubPatNo = insuPubInfoJson.has("insu_pub_pat_no") && insuPubInfoJson.get("insu_pub_pat_no") != null && !insuPubInfoJson.get("insu_pub_pat_no").equals("null") ? insuPubInfoJson.get("insu_pub_pat_no").toString() : null;
          // mod #10735 患者情報を保存できない dengshen end
          insuPubInfoJson.put("insu_pub4_cd", insuCode != null && !insuCode.equals("null") ? insuCode : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub4_info_name", insuInfoName != null && !insuInfoName.equals("null") ? insuInfoName : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub4_info_name_short", insuNameShort != null && !insuNameShort.equals("null") ? insuNameShort : JSONObject.NULL);
          insuPubInfoJson.put("insu_class", insuClass != null && !insuClass.equals("null") ? insuClass : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub4_name", insuPub1Name != null && !insuPub1Name.equals("null") ? insuPub1Name : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub4_no", insuPubNo != null && !insuPubNo.equals("null") ? insuPubNo : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub4_pat_no",insuPubPatNo != null && !insuPubPatNo.equals("null") ? insuPubPatNo : JSONObject.NULL);
          //add #10510 「障害者手帳番号4」拡張 杜天成　start
          // mod #10735 患者情報を保存できない dengshen start
          // insuPubInfoJson.put("insu_pub4_passbook_no",insuPubInfoJson.get("passbook_no") != null && !insuPubInfoJson.get("passbook_no").equals("null")? insuPubInfoJson.get("passbook_no") : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub4_passbook_no", insuPubInfoJson.has("passbook_no") && insuPubInfoJson.get("passbook_no") != null && !insuPubInfoJson.get("passbook_no").equals("null")? insuPubInfoJson.get("passbook_no") : JSONObject.NULL);
          // mod #10735 患者情報を保存できない dengshen end
          insuPubInfoJson.remove("passbook_no");
          //add #10510 「障害者手帳番号4」拡張 杜天成　end
          insuPubInfoJson.remove("insu_pub_name");
          insuPubInfoJson.remove("insu_pub_no");
          insuPubInfoJson.remove("insu_pub_pat_no");

          insuSetInfo.put(insuPubInfoJson);
        }
        // add #10735 患者情報を保存できない dengshen start
        }
        // add #10735 患者情報を保存できない dengshen end
      }
      insuSetInfoJson.put("insu_pub4_name", insuPub4Cd);

      patInsuranceHistory.setInsu_set_info(insuSetInfo.toString());
      // 保険情報
      if (insuInfo.getInsu_class().equals(0)) {
        patInsuranceHistory.setInsu_pub_info(null);
        patInsuranceHistory.setInsu_set_info(null);
        patInsuranceHistory.setInsu_self_info(null);
        // 公費情報
      }else if(insuInfo.getInsu_class().equals(1)) {
        patInsuranceHistory.setInsu_info(null);
        patInsuranceHistory.setInsu_set_info(null);
        patInsuranceHistory.setInsu_self_info(null);
        // セット情報
      }else if(insuInfo.getInsu_class().equals(2)) {
        patInsuranceHistory.setInsu_info(null);
        patInsuranceHistory.setInsu_self_info(null);
        patInsuranceHistory.setInsu_pub_info(null);
        // 自費情報
      }else if (insuInfo.getInsu_class().equals(3)) {
        patInsuranceHistory.setInsu_info(null);
        patInsuranceHistory.setInsu_set_info(null);
        patInsuranceHistory.setInsu_pub_info(null);
      }
      //  mod 10525 保険区分が「セット」のときクラス「処方情報」が出力できない 関  end
      // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end
      //add #10532 mongoDBがダウン中の操作について（新患登録） zhao start
      try {
        if (MongoHealthCheckService.getMongoDBConnected()) {
      //add #10532 mongoDBがダウン中の操作について（新患登録） zhao end
          mongoTemplate.insert(patInsuranceHistory);
      //add #10532 mongoDBがダウン中の操作について（新患登録） zhao start
        }
      } catch (DataAccessResourceFailureException exception) {
        MongoHealthCheckService.setMongoDBConnected(false);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//            exception.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(exception));
          if (patInsuInfo != null && !StringUtils.isEmpty(patInsuInfo.getFacility_cd())) {
            eventLogMessage.setFacilityCd(patInsuInfo.getFacility_cd());
          }
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      }
      //add #10532 mongoDBがダウン中の操作について（新患登録） zhao end
    }
    // add #10193 身体情報と保険情報の保存でがmongodbの患者情報履歴に登録されない。 dengshen end
  }

  // #10553 Mod データリスト保存排他チェックロジック最適化 Start
//  @Transactional
//  public void updateByList(List<Map<String, String>> payload) throws Exception {
//    for (Map<String, String> patRecord: payload) {
//      // mod 6931 【デグレ】患者情報を編集した際ログに編集していない感染症を編集した記録が残る 周安寧　start
//      //updateById(Long.parseLong(patRecord.get("pat_id")), patRecord);
//      // 患者グループの差異を検索
//      JSONObject patGroupDiff = getPatGroupDiff(Long.parseLong(patRecord.get("pat_id")), patRecord);
//
//      updateById(Long.parseLong(patRecord.get("pat_id")), patRecord,patGroupDiff);
//      // mod 6931 【デグレ】患者情報を編集した際ログに編集していない感染症を編集した記録が残る 周安寧　end
//
//      //del #10412 次患者更新関連全体見直し対応 朴 start
////      Long patId = Long.parseLong(patRecord.get("pat_id"));
////      String facilityCd = patRecord.get("facility_cd");
////      if ("true".equals(patRecord.get("is_changed_next_pat_info")) && patId != null && facilityCd != null) {
////        comSvNotifySetNextPatInfo(facilityCd, patId);
////      }
//      //del #10412 次患者更新関連全体見直し対応 朴 end
//    }
//    //del #10185 DW一括登録時に連携イベントが発生しない zhaoqi 20240105 start
//    //既存の無効なコード
////    return;
//    //del #10185 DW一括登録時に連携イベントが発生しない zhaoqi 20240105 end
//  }

  /**
   * 2フェーズコミット(Likely)みたいの患者情報更新
   *
   * @param payload 患者情報リスト
   */
  public void segmentedUpdateByList(List<Map<String, String>> payload) {

    final int MAX_COMMIT_SIZE = 25;
    // add 10626 データリストのCTR・DW一括登録修正 房 start
    List<PatInfo> patInfos = new ArrayList<>();
    // add 10626 データリストのCTR・DW一括登録修正 房 end
    if (CollectionUtils.isNotEmpty(payload)) {

      outerLoop:
      for (int idx = 0; idx < payload.size(); idx += MAX_COMMIT_SIZE) {
        int endPos = idx + MAX_COMMIT_SIZE;
        List<Map<String, String>> subPayload = payload.subList(idx, Math.min(payload.size(), endPos));

        // Handle transaction manually.
        DefaultTransactionDefinition transactionDefinition = new DefaultTransactionDefinition();
        transactionDefinition.setPropagationBehavior(DefaultTransactionDefinition.PROPAGATION_REQUIRES_NEW);
        TransactionStatus transactionStatus = this.dsTransactionManager.getTransaction(transactionDefinition);

        for (Map<String, String> patRecord : subPayload) {
          // Create a savePoint at beginning of every loop
          Savepoint savePoint = (Savepoint) transactionStatus.createSavepoint();
          try {
            // 患者グループの差異を検索
            JSONObject patGroupDiff = getPatGroupDiff(Long.parseLong(patRecord.get("pat_id")), patRecord);
            // mod 10626 データリストのCTR・DW一括登録修正 房 start
            this.updateById(Long.parseLong(patRecord.get("pat_id")), patRecord,patGroupDiff, patInfos);
            // mod 10626 データリストのCTR・DW一括登録修正 房 end
          }
          catch (DomaException dbException) {
            /* 患者情報保存の時、レコード排他チェックがあり。
             * この楽観ロックは単一患者情報レコードに対してのみ、全てデータに作用するべきではない。 */
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(dbException.getMessage());
            eventLogMessage.setPatId(patRecord.get("pat_id"));
            logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, "");

            // When OptimisticLock happened, roll back only locked record, just the savepoint at beginning.
            transactionStatus.rollbackToSavepoint(savePoint);
          }
          // TODO Unpredictable anomalies, exclusive RollBack;
          catch (Exception badException) {

            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(badException.getMessage());
            logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, "");

            // stop handling, break to outerLoop;
            break outerLoop;
          }
        }

        // Commit record at last of sublist's loop.
        this.dsTransactionManager.commit(transactionStatus);
      }
      // add 10626 データリストのCTR・DW一括登録修正 房 start
      if(patInfos != null && patInfos.size() > 0) {
        try {
          RestTemplate rt = new RestTemplate();
          URI uri = new URI(webApi + "/util/insertPatsInfoToMongo");
          RequestEntity<List<PatInfo>> request = RequestEntity
            .put(uri)
            .contentType(MediaType.APPLICATION_JSON)
            .header("SSECCAYEK", "NTSS-NKK-ESM-TDC-YSK")
            .body(patInfos);
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
          long start = System.currentTimeMillis();
          ResponseEntity<Object> response = rt.exchange(request, Object.class);
          long cost = System.currentTimeMillis() - start;
          Map<String, Object> map = new HashMap<>();
          map.put("logType", "RESTTEMPLATE-LOG");
          map.put("className", "jp.co.nikkiso.ntss.admin_web.service.PatInfoService");
          map.put("methodName", "segmentedUpdateByList");
          map.put("method", request.getMethod());
          map.put("url", uri.getPath());
          map.put("headers", request.getHeaders());
          map.put("requestParameter", request.getBody());
          map.put("status",response.getStatusCode());
          map.put("cost", cost);
          map.put("result",response.getBody());
          EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
          restTemplateEventLogMessage.setLogMessage(toJson(map));
          logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);

        } catch (Exception e) {
          EventLogMessage eventLogMessage = new EventLogMessage();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
        }
      }
      // add 10626 データリストのCTR・DW一括登録修正 房 end
    }
  }
  // #10553 Mod データリスト保存排他チェックロジック最適化 End
  /*
   * 身体情報更新
   */
  @Transactional
  public List<OrdMainTreatDate> updatePhysicalInfoById(Long pat_id, Map<String, String> payload, Long optUserCd) throws Exception {
    try {
      ObjectMapper mapper = new ObjectMapper();
      // add #11159 特定の患者だけ患者情報編集時にエラーが発生する ztc 20241003 start
      mapper = mapper.rebuild().configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false).build();
      // add #11159 特定の患者だけ患者情報編集時にエラーが発生する ztc 20241003 end
      PatUnique patUnique = mapper.readValue(payload.get("pat_unique"), PatUnique.class);
      //add 11007 「pat_unique_history」で「facility_cd」が登録されていない zhao start
      patUnique.setFacility_cd(payload.get("facility_cd"));
      //add 11007 「pat_unique_history」で「facility_cd」が登録されていない zhao end
      // add FNSI-排他処理 劉 start
      // PatUnique排他チェック
      PatUnique patUniqueHaiTa = patUniqueDao.selectById(pat_id);
      if (patUnique.getOld_up_date_unique() != null && patUniqueHaiTa != null){
        if (!patUnique.getOld_up_date_unique().equals(patUniqueHaiTa.getOld_up_date_unique()) ) {
          throw new OptimisticLockException(SqlLogType.NONE, SqlKind.UPDATE, "", "", "");
        }
      } else if (patUnique.getOld_up_date_unique() != null && patUniqueHaiTa == null){
        throw new OptimisticLockException(SqlLogType.NONE, SqlKind.UPDATE, "", "", "");
      }
      // add FNSI-排他処理 劉 end
      //add mongoDBの中でlogを加入する 顔 start
      //if(!((boolean)dw_log_info.get("is_change") && dw_log_info.get("dw_aft").equals(dw_log_info.get("dw_pre")))){
      String logDate = new SimpleDateFormat(FORMAT_DATE).format(new Date());
      selectHistoryUtils.insertLogIntoMongo(payload, pat_id, patUniqueHaiTa, logDate);
      //}
      //add mongoDBの中でlogを加入する 顔 end

      // DB更新ログ出力ロジック xie start
      patUnique.setPat_id(pat_id);
      // DB更新ログ出力ロジック xie end

      // ISSUES#10443: Update OrdMain's data: target_weight at ind_cond & so on. START
      // get these params for updating.
      String hasBeenAdd = payload.get("has_been_added");
      String editMod = payload.get("edit_mod");
      String savePhysicalItem = payload.get("save_physical_item");
      String facilityCd = payload.get("facility_cd");

      // Param rationality verification
      if (!StringUtils.hasText(hasBeenAdd) || !StringUtils.hasText(savePhysicalItem)) return null;

      // read the edit record as JsonNode
      JsonNode savePhysicalItemNode = this.objectMapper.readTree(savePhysicalItem);

      // init logic edit params
      List<OrdMainTreatDate> effectsOrdNos = null;
      boolean editedDw = savePhysicalItemNode.hasNonNull("dw");
      boolean editedTw = savePhysicalItemNode.hasNonNull("target_weight");

      // get timeLine before upd PhysicalInfo.
      List<PatDWEffectsTimeLineDTO> beforeModTimeLine = this.patUniqueDao.selectDwEffectsTimeLine(pat_id);

      // upd PhysicalInfo
      int updCnt = this.patUniqueDao.updatePhysicalInfoById(pat_id, patUnique);

      // get timeLine after upd PhysicalInfo.
      List<PatDWEffectsTimeLineDTO> afterModTimeLine = this.patUniqueDao.selectDwEffectsTimeLine(pat_id);

      // we can find the time period affected by changed record now.
      if (editedDw) {
        List<PatDWEffectsTimeLineDTO> effectsIntervalList = this.findChangedInterval(
          editMod,
          savePhysicalItemNode.hasNonNull("ctl_no") ? savePhysicalItemNode.get("ctl_no").asInt() : 0,
          beforeModTimeLine, afterModTimeLine
        );

        // find the affected interval, then mapping the ordMain & patIndApprove.
        if (CollectionUtils.isNotEmpty(effectsIntervalList)) {
          effectsOrdNos = this.updDwIndApprove(facilityCd, pat_id, effectsIntervalList);
        }

        // if there has affect on target weight, we also need to upd the pat's ordMain records.
        if (updCnt > 0
          && editedTw
          && "I".equals(editMod)
          && savePhysicalItemNode.hasNonNull("indicator_start_date")) {

          List<OrdMainTreatDate> targetWeightEIList =
            this.updateTargetWeightByPhysicalInfo(facilityCd, pat_id, savePhysicalItemNode, optUserCd, logDate);

          // find out affected ordNo, these ordMain need send journal
          if (CollectionUtils.isNotEmpty(targetWeightEIList)) {
            if (CollectionUtils.isNotEmpty(effectsOrdNos)) {
              List<Long> dwODList = effectsOrdNos.stream().map(OrdMainTreatDate::getOrdNo).toList();
              List<Long> twODList = targetWeightEIList.stream().map(OrdMainTreatDate::getOrdNo).toList();
              //
              effectsOrdNos.addAll(
                targetWeightEIList.stream()
                  .filter(rec -> twODList.stream().filter(no -> !dwODList.contains(no)).toList().contains(rec.getOrdNo()))
                  .toList()
              );
            } else {
              effectsOrdNos = targetWeightEIList;
            }
          }
        }
      }
      this.createJournalForInsertLog(logDate, patUniqueHaiTa);
      // ISSUES#10443: Update OrdMain's data: target_weight at ind_cond & so on. END

      //del #10412 次患者更新関連全体見直し対応 朴 start
//      if (Objects.equals(payload.get("is_changed_next_pat_info"), FlagType.FLAG_ON) && pat_id != null) {
//        PatMain pat = patMainDao.selectById(pat_id);
//        String facilityCd = pat.getFacility_cd();
//        comSvNotifySetNextPatInfo(facilityCd, pat_id);
//      }
      //del #10412 次患者更新関連全体見直し対応 朴 end
      //add #10532 mongoDBがダウン中の操作について（新患登録） zhao start
      try {
        if (MongoHealthCheckService.getMongoDBConnected()) {
      //add #10532 mongoDBがダウン中の操作について（新患登録） zhao end
      // add #10193 身体情報と保険情報の保存でがmongodbの患者情報履歴に登録されない。 dengshen start
      if(mongoTemplate != null) {
        PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(pat_id);
        PatMain patMain = patMainDao.selectById(pat_id);

        Timestamp now = new Timestamp(new Date().getTime());

        PatPersonalMainHistory patPersonalMainHistory = new PatPersonalMainHistory();
        BeanUtils.copyProperties(patPersonalMain, patPersonalMainHistory);
        patPersonalMainHistory.setIns_date(now);
        String pat_idR = patPersonalMain.getPat_id().toString();
        patPersonalMainHistory.setPat_id(pat_idR);

        PatMainHistory patMainHistory = new PatMainHistory();
        BeanUtils.copyProperties(patMain, patMainHistory);
        patMainHistory.setIns_date(now);
        pat_idR = patMain.getPat_id().toString();
        patMainHistory.setPat_id(pat_idR);

        PatUniqueHistory patUniqueHistory = new PatUniqueHistory();
        BeanUtils.copyProperties(patUnique, patUniqueHistory);
        patUniqueHistory.setIns_date(now);
        pat_idR = patUnique.getPat_id().toString();
        patUniqueHistory.setPat_id(pat_idR);

        // add #10193 身体情報と保険情報の保存でがmongodbの患者情報履歴に登録されない。 dengshen start
        PatUnique getPatUnique = patUniqueDao.selectByPatId(Long.parseLong(pat_idR));
        patUniqueHistory.setReg_date(getPatUnique.getReg_date());
        patUniqueHistory.setIs_del(getPatUnique.getIs_del());
        // add #10193 身体情報と保険情報の保存でがmongodbの患者情報履歴に登録されない。 dengshen end
        // add #10193 身体情報と保険情報の保存でがmongodbの患者情報履歴に登録されない。 dengshen start
        // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
//        patUniqueHistory.setMedical_hst_info(getPatUnique.getMedical_hst_info());
//        patUniqueHistory.setIn_out_visit_history_info(getPatUnique.getIn_out_visit_history_info());
        // add #10193 身体情報と保険情報の保存でがmongodbの患者情報履歴に登録されない。 dengshen end

//        Map<String, Map<String, String>> getMstNames = this.getMstNames(patPersonalMainHistory, patMainHistory, patUniqueHistory);
        Map<String, Map<String, String>> getMstNames = this.getMstNames(patPersonalMain, patMain, getPatUnique);

        // 既往歴情報を取得する。
//        JSONArray medicalHstInfoJson = this.getJSONArray(patUniqueHistory.getMedical_hst_info());
        JSONArray medicalHstInfoJson = this.getJSONArray(getPatUnique.getMedical_hst_info());
        // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end

        // 既往歴情報
        for(int i = 0; i < medicalHstInfoJson.length(); i++) {
          JSONObject jsonObj = medicalHstInfoJson.getJSONObject(i);
          // 登録施設名
          // mod #10735 患者情報を保存できない dengshen start
          // jsonObj.put("facility_name", this.getCodeName(getMstNames, "facilityNames", jsonObj.get("facility_cd")));
          jsonObj.put("facility_name", this.getCodeName(getMstNames, "facilityNames", this.checkCodeStr(jsonObj, "facility_cd")));
          // mod #10735 患者情報を保存できない dengshen end
          // 病名マスタ.病名
          // mod #10735 患者情報を保存できない dengshen start
          // jsonObj.put("disease_name", this.getCodeName(getMstNames, "diseaseNames", jsonObj.get("disease_cd")));
          jsonObj.put("disease_name", this.getCodeName(getMstNames, "diseaseNames", this.checkCodeStr(jsonObj, "disease_cd")));
          // mod #10735 患者情報を保存できない dengshen end
          // 施設施設名
          // mod #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen start
          // jsonObj.put("diagnosis_facility_name", this.getCodeName(getMstNames, "mstFavoriteFacilityNames", jsonObj.get("diagnosis_facility_cd")));
          // mod #10735 患者情報を保存できない dengshen start
          // inputCdCheck(jsonObj, "diagnosis_facility_cd", "diagnosis_facility_name", getMstNames, "sysFacilityNames", jsonObj.get("diagnosis_facility_is_free").toString());
          inputCdCheck(jsonObj, "diagnosis_facility_cd", "diagnosis_facility_name", getMstNames, "sysFacilityNames", this.checkCodeStr(jsonObj, "diagnosis_facility_is_free"));
          // mod #10735 患者情報を保存できない dengshen end
          // mod #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen end
          // 診断医名
          // mod #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen start
          // jsonObj.put("diagnostician_name", this.getCodeName(getMstNames, "personalUserNames", jsonObj.get("diagnostician_cd")));
          // mod #10735 患者情報を保存できない dengshen start
          // inputCdCheck(jsonObj, "diagnostician_cd", "diagnostician_name", getMstNames, "personalUserNames", jsonObj.get("diagnostician_is_free").toString());
          inputCdCheck(jsonObj, "diagnostician_cd", "diagnostician_name", getMstNames, "personalUserNames", this.checkCodeStr(jsonObj, "diagnostician_is_free"));
          // mod #10735 患者情報を保存できない dengshen end
          // mod #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen end
          // 診療科名
          // mod #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen start
          // jsonObj.put("course_name", this.getCodeName(getMstNames, "courseNames", jsonObj.get("course_cd")));
          // mod #10735 患者情報を保存できない dengshen start
          // inputCdCheck(jsonObj, "course_cd", "course_name", getMstNames, "courseNames", jsonObj.get("course_is_free").toString());
          inputCdCheck(jsonObj, "course_cd", "course_name", getMstNames, "courseNames", this.checkCodeStr(jsonObj, "course_is_free"));
          // mod #10735 患者情報を保存できない dengshen end
          // mod #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen end
          // 病名マスタ.病名連携コード
          String diseaseHospitalCd = "";
          if (jsonObj.has("disease_cd") && jsonObj.get("disease_cd") != null && !jsonObj.get("disease_cd").toString().isEmpty() && !"null".equals(jsonObj.get("disease_cd").toString())) {
            MstDisease mstDisease = mstDiseaseDao.selectByCd(Integer.parseInt(jsonObj.get("disease_cd").toString()));
            diseaseHospitalCd = mstDisease != null && mstDisease.getInHospitalCd_1() != null ? mstDisease.getInHospitalCd_1() : "";
          }
          jsonObj.put("dis_in_hospital_cd_1", diseaseHospitalCd);
        }
        // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
//        patUniqueHistory.setMedical_hst_info(medicalHstInfoJson.toString());
        List<MedicalHstInfo> medicalHstInfos = mapper.readValue(medicalHstInfoJson.toString(), new TypeReference<List<MedicalHstInfo>>() {});
        patUniqueHistory.setMedical_hst_info(medicalHstInfos);

        // 入外・転入出情報を取得する。
//        JSONArray inoutVisitHistoryInfoJson = this.getJSONArray(patUniqueHistory.getIn_out_visit_history_info());
        JSONArray inoutVisitHistoryInfoJson = this.getJSONArray(getPatUnique.getIn_out_visit_history_info());
        // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end

        // 入外・転入出情報
        for (int i = 0; i < inoutVisitHistoryInfoJson.length(); i++) {
          JSONObject jsonObj = inoutVisitHistoryInfoJson.getJSONObject(i);
          // 登録施設名
          // mod #10735 患者情報を保存できない dengshen start
          // jsonObj.put("facility_name", this.getCodeName(getMstNames, "facilityNames", jsonObj.get("facility_cd")));
          jsonObj.put("facility_name", this.getCodeName(getMstNames, "facilityNames", this.checkCodeStr(jsonObj, "facility_cd")));
          // mod #10735 患者情報を保存できない dengshen end
          // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen start
          String moveInOut = this.getCode(inoutVisitHistoryInfoJson.getJSONObject(i), "move_in_out", String.class);
          switch (moveInOut) {
            case "3":
            case "4":
            case "5":
            case "9":
              // 元施設
              // mod #10735 患者情報を保存できない dengshen start
              // inputCdCheck(jsonObj, "from_facility", "from_facility_name", getMstNames, "facilityNames", jsonObj.get("facility_is_free").toString());
              inputCdCheck(jsonObj, "from_facility", "from_facility_name", getMstNames, "facilityNames", this.checkCodeStr(jsonObj, "facility_is_free"));
              // mod #10735 患者情報を保存できない dengshen end
              // 先施設
              // mod #10735 患者情報を保存できない dengshen start
              // inputCdCheck(jsonObj, "to_facility", "to_facility_name", getMstNames, "sysFacilityNames", jsonObj.get("facility_is_free").toString());
              inputCdCheck(jsonObj, "to_facility", "to_facility_name", getMstNames, "sysFacilityNames", this.checkCodeStr(jsonObj, "facility_is_free"));
              // mod #10735 患者情報を保存できない dengshen end
              break;
            case "1":
            case "2":
            case "6":
            case "7":
            case "8":
            case "10":
              // 元施設
              // mod #10735 患者情報を保存できない dengshen start
              // inputCdCheck(jsonObj, "from_facility", "from_facility_name", getMstNames, "sysFacilityNames", jsonObj.get("facility_is_free").toString());
              inputCdCheck(jsonObj, "from_facility", "from_facility_name", getMstNames, "sysFacilityNames", this.checkCodeStr(jsonObj, "facility_is_free"));
              // mod #10735 患者情報を保存できない dengshen end
              // 先施設
              // mod #10735 患者情報を保存できない dengshen start
              // inputCdCheck(jsonObj, "to_facility", "to_facility_name", getMstNames, "facilityNames", jsonObj.get("facility_is_free").toString());
              inputCdCheck(jsonObj, "to_facility", "to_facility_name", getMstNames, "facilityNames", this.checkCodeStr(jsonObj, "facility_is_free"));
              // mod #10735 患者情報を保存できない dengshen end
              break;
          }
          // 元科
          // mod #10735 患者情報を保存できない dengshen start
          // inputCdCheck(jsonObj, "from_course", "from_course_name", getMstNames, "courseNames", jsonObj.get("course_is_free").toString());
          inputCdCheck(jsonObj, "from_course", "from_course_name", getMstNames, "courseNames", this.checkCodeStr(jsonObj, "course_is_free"));
          // mod #10735 患者情報を保存できない dengshen end
          // 元施設医
          // mod #10735 患者情報を保存できない dengshen start
          // inputCdCheck(jsonObj, "from_doctor", "from_doctor_name", getMstNames, "personalUserNames", jsonObj.get("doctor_is_free").toString());
          inputCdCheck(jsonObj, "from_doctor", "from_doctor_name", getMstNames, "personalUserNames", this.checkCodeStr(jsonObj, "doctor_is_free"));
          // mod #10735 患者情報を保存できない dengshen end
          // 元医療機関
          jsonObj.put("from_medicalInstitution_name", this.getCodeName(getMstNames, "medicalInstitutionNames",
            jsonObj.has("from_medicalInstitutionCd") ? jsonObj.get("from_medicalInstitutionCd") : ""));
          // 先科
          // mod #10735 患者情報を保存できない dengshen start
          // inputCdCheck(jsonObj, "to_course", "to_course_name", getMstNames, "courseNames", jsonObj.get("course_is_free").toString());
          inputCdCheck(jsonObj, "to_course", "to_course_name", getMstNames, "courseNames", this.checkCodeStr(jsonObj, "course_is_free"));
          // mod #10735 患者情報を保存できない dengshen end
          // 先施設医
          // mod #10735 患者情報を保存できない dengshen start
          // inputCdCheck(jsonObj, "to_doctor", "to_doctor_name", getMstNames, "personalUserNames", jsonObj.get("doctor_is_free").toString());
          inputCdCheck(jsonObj, "to_doctor", "to_doctor_name", getMstNames, "personalUserNames", this.checkCodeStr(jsonObj, "doctor_is_free"));
          // mod #10735 患者情報を保存できない dengshen end
          // 先医療機関
          jsonObj.put("to_medicalInstitution_name", this.getCodeName(getMstNames, "medicalInstitutionNames",
            jsonObj.has("to_medicalInstitutionCd") ? jsonObj.get("to_medicalInstitutionCd") : ""));
          // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen end
        }
        // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
//        patUniqueHistory.setIn_out_visit_history_info(inoutVisitHistoryInfoJson.toString());
        List<InOutVisitHistoryInfo> inoutVisitHistoryInfos = mapper.readValue(inoutVisitHistoryInfoJson.toString(), new TypeReference<List<InOutVisitHistoryInfo>>() {});
        patUniqueHistory.setIn_out_visit_history_info(inoutVisitHistoryInfos);

        // 身体情報を取得する。
//        JSONArray physicalInfoJson = this.getJSONArray(patUniqueHistory.getPhysical_info());
        JSONArray physicalInfoJson = this.getJSONArray(getPatUnique.getPhysical_info());
        // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end

        // 身体情報
        for (int i = 0; i < physicalInfoJson.length(); i++) {
          JSONObject jsonObj = physicalInfoJson.getJSONObject(i);
          // 指示者
          // mod #10735 患者情報を保存できない dengshen start
          // jsonObj.put("indicator_name", this.getCodeName(getMstNames, "personalUserNames", jsonObj.get("indicator_cd")));
          jsonObj.put("indicator_name", this.getCodeName(getMstNames, "personalUserNames", this.checkCodeStr(jsonObj, "indicator_cd")));
          // mod #10735 患者情報を保存できない dengshen end

          // add 10708 by kangjie 20240617 start 【身体情報関連】⑤帳票
          jsonObj.put("changer_name", this.getCodeName(getMstNames, "personalUserNames", this.checkCodeStr(jsonObj, "changer_cd")));
          // add 10708 by kangjie 20240617 end

          // 施設名
          // mod #10735 患者情報を保存できない dengshen start
          // jsonObj.put("facility_name", this.getCodeName(getMstNames, "facilityNames", jsonObj.get("facility_cd")));
          jsonObj.put("facility_name", this.getCodeName(getMstNames, "facilityNames", this.checkCodeStr(jsonObj, "facility_cd")));
          // mod #10735 患者情報を保存できない dengshen end
        }
        // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
//        patUniqueHistory.setPhysical_info(physicalInfoJson.toString());
        List<PhysicalInfo> physicalInfos = mapper.readValue(physicalInfoJson.toString(), new TypeReference<List<PhysicalInfo>>() {});
        patUniqueHistory.setPhysical_info(physicalInfos);
        // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end
        // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
        patUniqueHistory.setLatest_flag("on");
        // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end
        // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
        Query query = new Query();
        Update update = new Update();
        query.addCriteria(Criteria.where("pat_id").is(pat_id.toString()));
        query.addCriteria(Criteria.where("latest_flag").ne("off"));
        update.set("latest_flag", "off");
        mongoTemplate.updateMulti(query, update, PatUniqueHistory.class);
        // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end
        mongoTemplate.insert(patUniqueHistory);
      }
      // add #10193 身体情報と保険情報の保存でがmongodbの患者情報履歴に登録されない。 dengshen end

      //add #10532 mongoDBがダウン中の操作について（新患登録） zhao start
        }
      } catch (DataAccessResourceFailureException exception) {
        MongoHealthCheckService.setMongoDBConnected(false);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//            exception.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(exception));
          if (!StringUtils.isEmpty(facilityCd)) {
            eventLogMessage.setFacilityCd(facilityCd);
          }
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      }
      //add #10532 mongoDBがダウン中の操作について（新患登録） zhao end
      return effectsOrdNos;
    // add FNSI-排他処理 劉 start
    } catch (OptimisticLockException e) {
      throw e;
    // add FNSI-排他処理 劉 end
    } catch (RuntimeException e) {
      throw new RuntimeException(e);
    }
  }

  /**
   * 同姓同名フラグ更新
   * @param payload
   * @throws Exception
   */
  // #11205 -ペンテスト2－4認可制御の不備  mod 20260427 start
  @Transactional
  public void updateIsSame(Map<String, String> payload, String facilityCd) throws Exception {
  // #11205 -ペンテスト2－4認可制御の不備  mod 20260427 end
    ObjectMapper mapper = new ObjectMapper();
    List<Long> patIdList = mapper.readValue(payload.get("patIdList"), new TypeReference<List<Long>>() {});
    String is_same = payload.get("is_same");

    // DB更新ログ出力ロジック wangzuo Start
    String tableName = "pat_main";
    // SQL検索条件
    String inStr = getInStr("pat_id in ", patIdList);
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(inStr + "\n");
    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    // DB更新ログ出力ロジック wangzuo End
    //int updateCount = patMainDao.updateIsSame(patIdList, is_same);
    //7206 mod 同姓同名のチェックが正しく行われない 趙 start
    int updateCount = 0;
    if(patIdList.size()==1){
      // #11205 -ペンテスト2－4認可制御の不備  mod 20260427 start
      if (facilityCd != null && !facilityCd.isEmpty()) {
        updateCount = patMainDao.updateIsSameByFacilityCd(patIdList, is_same, facilityCd);
      } else {
        updateCount = patMainDao.updateIsSame(patIdList, is_same);
      }
      // #11205 -ペンテスト2－4認可制御の不備  mod 20260427 end

      // mod #10436 同姓同名フラグの更新時に対になる患者のpat_main_historyがinsertされていない zhao start
      // #11205 -ペンテスト2－4認可制御の不備  mod 20260427 start
      if (updateCount > 0) {
        isSameToMoGo(patIdList.get(0));
      }
      // #11205 -ペンテスト2－4認可制御の不備  mod 20260427 end
      // mod #10436 同姓同名フラグの更新時に対になる患者のpat_main_historyがinsertされていない zhao end
    }
    //7206 mod 同姓同名のチェックが正しく行われない 趙 end
    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      logCommon.updateLog();
    }
    // DB更新ログ出力ロジック wangzuo End
    return;
  }

  // add #10436 同姓同名フラグの更新時に対になる患者のpat_main_historyがinsertされていない zhao start
  public void isSameToMoGo(Long patId) throws URISyntaxException {
    PatInfo patInfo = new PatInfo();
    patInfo.setIsSame("1");
    PatMain patMain = patMainDao.selectById(patId);
    patInfo.setPatMain(patMain);
    RestTemplate rt = new RestTemplate();
    URI uri = new URI(webApi + "/util/insertPatToMongo");
    RequestEntity<PatInfo> request = RequestEntity
      .put(uri)
      .contentType(MediaType.APPLICATION_JSON)
      .header("SSECCAYEK", "NTSS-NKK-ESM-TDC-YSK")
      .body(patInfo);
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
    long start = System.currentTimeMillis();
    ResponseEntity<Object> response = rt.exchange(request, Object.class);
    long cost = System.currentTimeMillis() - start;
    Map<String, Object> map = new HashMap<>();
    map.put("logType", "RESTTEMPLATE-LOG");
    map.put("className", "jp.co.nikkiso.ntss.admin_web.service.PatInfoService");
    map.put("methodName", "isSameToMoGo");
    map.put("method", request.getMethod());
    map.put("url", uri.getPath());
    map.put("headers", request.getHeaders());
    map.put("requestParameter", request.getBody());
    map.put("status",response.getStatusCode());
    map.put("cost", cost);
    map.put("result",response.getBody());
    EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
    restTemplateEventLogMessage.setLogMessage(toJson(map));
    logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
  }
  // add #10436 同姓同名フラグの更新時に対になる患者のpat_main_historyがinsertされていない zhao end

  @Transactional
  public int immediateCommitOffWater(Long patId, String offWaterInfo) {
    int updateCount = patMainDao.immediateCommitRemovalWater(patId, offWaterInfo);
    return updateCount;
  }

  @Transactional
  public int immediateCommitTare(Long patId, String tareInfo) {
    int updateCount = patMainDao.immediateCommitTare(patId, tareInfo);
    return updateCount;
  }

  // add FNSI-保険選択の変更 関 start
  // #11205 -ペンテスト2－4認可制御の不備  add 20260427 start
  @Transactional
  public int updateInsuranceSelectById(Long pat_id, Long insuranceCd , Integer isSelected, String facilityCd) {
  // #11205 -ペンテスト2－4認可制御の不備  add 20260427 end

    // DB更新ログ出力ロジック wangzuo Start
    String tableName = "pat_insurance";
    // SQL検索条件
    StringBuffer wheresClear = new StringBuffer("");
    wheresClear.append(" WHERE\n");
    wheresClear.append(" pat_id = " + pat_id + "\n");
    // logCommon設定
    DataUpdateLogCommonNew logCommonClear = getLogCommon(tableName, wheresClear, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResultClear = logCommonClear.setInfo();
    // DB更新ログ出力ロジック wangzuo End

    // #11205 -ペンテスト2－4認可制御の不備  mod 20260427 start
    int clearSelect;
    if (!ObjectUtils.isEmpty(facilityCd)) {
      clearSelect = patInsuranceDao.clearSelectByPatIdFacilityCd(pat_id, facilityCd);
    } else {
      clearSelect = patInsuranceDao.clearSelectByPatId(pat_id);
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260427 end

    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResultClear && clearSelect > 0) {
      logCommonClear.updateLog();
    }
    // DB更新ログ出力ロジック wangzuo End

    // SQL検索条件
    StringBuffer wheresUpdate = new StringBuffer("");
    wheresUpdate.append(" WHERE\n");
    wheresUpdate.append(" insurance_cd = " + insuranceCd + "\n");
    // logCommon設定
    DataUpdateLogCommonNew logCommonUpdate = getLogCommon(tableName, wheresUpdate, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResultUpdate = logCommonUpdate.setInfo();
    // DB更新ログ出力ロジック wangzuo End

    // #11205 -ペンテスト2－4認可制御の不備  mod 20260427 start
    int updateSelect;
    if (!ObjectUtils.isEmpty(facilityCd)) {
      updateSelect = patInsuranceDao.updateSelectByCdFacilityCd(insuranceCd, isSelected, facilityCd);
    } else {
      updateSelect = patInsuranceDao.updateSelectByCd(insuranceCd , isSelected);
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260427 end

    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResultUpdate && updateSelect > 0) {
      logCommonUpdate.updateLog();
    }
    // DB更新ログ出力ロジック wangzuo End

    return updateSelect;
  }
  // add FNSI-保険選択の変更 関 end

  /**
   * 簡易検索
   */
  public List<PatPersonalMainData> getPatInfoBySimpleSearchCondition(SimpleSearchRequest searchConditions, String facilityCd) throws Exception {
    // リクエストから検索条件を取得
    OrdScheduleSimpleConditions osConditions = searchConditions.getOrd_schedule();
    // クエリ検索が行われていた場合の検索結果患者IDリスト
    List<Long> patIdList = searchConditions.getPatIdList();
    List<String> facilityCdList = searchConditions.getFacilityCdList();
    PatGroupSearchRequest patGroupSearch = searchConditions.getPatGroupSearch();

    // 検索結果pat_idリスト
    List<Long> resultPatIdList = new ArrayList<Long>();
    if (osConditions!= null) {
      // ord_schedule検索
      //add 4748 5269 5402治療方法ごとの治療経過表での出力ができない  吉 start
      String rstDialysisStateFlag = "";
      if(null != osConditions.getRstDialysisState()){
        if(osConditions.getRstDialysisState().size() == 2){
          rstDialysisStateFlag  = "2";
        }
        if(osConditions.getRstDialysisState().size() == 1){
          if(osConditions.getRstDialysisState().get(0) == 2){
            rstDialysisStateFlag  = "1";
          }else{
            rstDialysisStateFlag  = "2";
          }
        }
      }

      // ベッドグループコードからベッドコードリスト取得
      List<Long> bedCdList = new ArrayList<>();
      if (null != osConditions.getBedGroupCd()) {
        ObjectMapper mapper = new ObjectMapper();
        MstRoomBedGroup mrbg = mstRoomBedGroupDao.selectByRoomBedGroupCd(osConditions.getBedGroupCd());
        if (null != mrbg && StringUtils.hasText(mrbg.getBedList())){
          try {
            bedCdList.addAll(mapper.readValue(mrbg.getBedList(), new TypeReference<List<Long>>(){}));
          } catch (tools.jackson.core.JacksonException e) {
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
      osConditions.setBedCdList(bedCdList);

      //add 4748 5269 5402治療方法ごとの治療経過表での出力ができない  吉 end
      resultPatIdList = ordScheduleDao.selectBySimpleSearchCondition(osConditions, patIdList, facilityCdList,rstDialysisStateFlag);
      if (resultPatIdList.size() == 0) {
        // 検索結果0件なら空の患者リストを返す
        return new ArrayList<PatPersonalMainData>();
      }

    }

    // pat_group_detail検索
    if(patGroupSearch != null) {
        if(patGroupSearch.getPatGroupCd().size() > 0) {
        	if(patGroupSearch.getSearchType() == 1) {
        		resultPatIdList = patGroupDetailDao.selectIncludeSearch(resultPatIdList, patGroupSearch.getPatGroupCd());
        	}else {
            // mod FNSI-改修内容 FutreNetWeb+SI課題管理No4816 趙 start
            // mod FNSI-改修内容 患者検索外結No5対応 吉 Start
            resultPatIdList = patGroupDetailDao.selectMatchSearch(resultPatIdList, patGroupSearch.getPatGroupCd());
            // String patGroupStr ="";
            // if(null != patGroupSearch.getPatGroupCd()){
            //   Collections.sort(patGroupSearch.getPatGroupCd());
            //   for(Integer group : patGroupSearch.getPatGroupCd() ){
            //       patGroupStr+=group+",";
            //   }
            //   patGroupStr=patGroupStr.substring(0,patGroupStr.lastIndexOf(","));
            // }
            // resultPatIdList = patGroupDetailDao.selectMatchSearch(resultPatIdList, patGroupSearch.getPatGroupCd(),patGroupStr);
            // mod FNSI-改修内容 患者検索外結No5対応 吉 end
            // mod FNSI-改修内容 FutreNetWeb+SI課題管理No4816 趙 end
        	}
            if (resultPatIdList.size() == 0) {
              // 検索結果0件なら空の患者リストを返す
              return new ArrayList<PatPersonalMainData>();
            }
        }
    }

    List<PatPersonalMain> patList = new ArrayList<PatPersonalMain>();
    List<PatMain> patMainList = new ArrayList<PatMain>();
    FacilitySettingInfo settingValue
      = mstFacilitySettingDao.getBySettingNoAndCd(facilityCd, FacilitySettingNo.SIMPLE_SEARCH_CONDITIONS);
    int conditionalSearchPatient = Integer.parseInt(settingValue.getValue());
    if (resultPatIdList.size() == 0) {
      // 条件未指定の場合は施設内の全患者取得
      //upd 患者検索設定後処理不正 修正 20230601 ztc start
//      patList = patPersonalMainDao.selectAllAndSetting(facilityCdList, conditionalSearchPatient);
//      patMainList = patMainDao.selectByCdList(facilityCdList);
      patList = patPersonalMainDao.selectByFacilityCdList(facilityCdList);
      patMainList = patMainDao.selectByCdListAndSetting(facilityCdList, conditionalSearchPatient);
      //upd 患者検索設定後処理不正 修正 20230601 ztc end
    }
    else {
      // 検索結果pat_idの患者を取得(条件未指定の場合は全患者取得)
      //upd 患者検索設定後処理不正 修正 20230601 ztc start
//      patList = patPersonalMainDao.selectByIdListFacilityCdAndSetting(resultPatIdList, facilityCd, conditionalSearchPatient);
//      patMainList = patMainDao.selectByIdListFacilityCd(resultPatIdList, facilityCd);
      patList = patPersonalMainDao.selectByPatIdListAndFacilityCd(resultPatIdList, facilityCd);
      patMainList = patMainDao.selectByPatIdListFacilityCdAndSetting(resultPatIdList, facilityCd, conditionalSearchPatient);
      //upd 患者検索設定後処理不正 修正 20230601 ztc end
    }

    // 検索結果の表示に必要な情報のみにする
    List<PatPersonalMainData> patListOnlyIdName = new ArrayList<PatPersonalMainData>();
    //upd 患者検索設定後処理不正 修正 20230601 ztc start
    for (PatMain patMain: patMainList) {
      PatPersonalMainData patOnlyIdName = new PatPersonalMainData();
      // 患者基本情報から同姓同名フラグを取得
      patOnlyIdName.setIs_same(patMain.getIs_same());
      patOnlyIdName.setIn_out_current_state(patMain.getIn_out_current_state());
      for (PatPersonalMain pat: patList) {
        if (pat.getPat_id().equals(Long.valueOf(patMain.getPat_id()))) {
          patOnlyIdName.setPat_id(pat.getPat_id());
          patOnlyIdName.setFacility_cd(pat.getFacility_cd());
          patOnlyIdName.setHosp_pat_id(pat.getHosp_pat_id());
          patOnlyIdName.setPat_sex(pat.getPat_sex());
          patOnlyIdName.setPat_last_name(pat.getPat_last_name());
          patOnlyIdName.setPat_first_name(pat.getPat_first_name());
          patOnlyIdName.setPat_first_name_kana(pat.getPat_first_name_kana());
          patOnlyIdName.setPat_last_name_kana(pat.getPat_last_name_kana());
          // add FNSI-NO423入院患者名の配布 江 start
          patOnlyIdName.setIn_out_class(pat.getIn_out_class());
          // add FNSI-NO423入院患者名の配布 江 end
          break;
        }
      }
      patListOnlyIdName.add(patOnlyIdName);
    }
    // add 9580 サイドコンテンツの患者詳細検索にて全患者検索で患者一覧をクリアしていない zkm start
    // return patListOnlyIdName.stream().filter(pat -> pat.getPat_id() != null).collect(Collectors.toList());
    // mod 9948 患者IDのソートが桁数を考慮せずに左端の数字からソートされる zkm start
    // return patListOnlyIdName.stream().filter(pat -> pat.getPat_id() != null)
    //   .sorted(Comparator.comparing(PatPersonalMainData::getHosp_pat_id)).toList();
    // mod #9948 患者IDのソートが桁数を考慮せずに左端の数字からソートされる 吉 start
//    return patListOnlyIdName.stream().filter(pat -> pat.getPat_id() != null)
//      .sorted(Comparator.comparing((PatPersonalMainData patPersonal) ->
//          org.apache.commons.lang3.StringUtils.leftPad(patPersonal.getHosp_pat_id(), 12, "0"),
//        String.CASE_INSENSITIVE_ORDER).reversed()
//        .thenComparing(PatPersonalMain::getHosp_pat_id, Comparator.nullsLast(Comparator.naturalOrder())).reversed())
//      .collect(Collectors.toList());
    // mod 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 start
    List<PatPersonalMainData> jumpList = patListOnlyIdName.stream().filter(pat -> pat.getPat_id() != null && "".equals(pat.getHosp_pat_id().replace("0", "")))
      .collect(Collectors.toList());
    List<PatPersonalMainData> jumpList1 = patListOnlyIdName.stream().filter(pat -> pat.getPat_id() != null &&  !"".equals(pat.getHosp_pat_id().replace("0", "")))
      .collect(Collectors.toList());
    jumpList.addAll(jumpList1);
    return jumpList.stream().sorted(this::comparePatId).toList();
    // mod #9948 患者IDのソートが桁数を考慮せずに左端の数字からソートされる 吉 end
    // mod 9948 患者IDのソートが桁数を考慮せずに左端の数字からソートされる zkm end
    // add 9580 サイドコンテンツの患者詳細検索にて全患者検索で患者一覧をクリアしていない zkm end
    //upd 患者検索設定後処理不正 修正 20230601 ztc end
  }

  private int comparePatId(PatPersonalMain pat1, PatPersonalMain pat2) {
    return PatSortCommonUtil.compareHospPatIdFunc(pat1.getHosp_pat_id(), pat2.getHosp_pat_id(), true);
  }
  // mod 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 end

  /**
   * 詳細検索
   */
  public List<PatPersonalMainData> getPatInfoByDetailedSearchCondition(DetailedSearchRequest searchConditions, String facilityCd) throws Exception {
    // リクエストからテーブルごとの検索条件を取得
    PatPersonalMainDetailedConditions ppmConditions = searchConditions.getPat_personal_main();
    PatMainDetailedConditions pmConditions = searchConditions.getPat_main();
    PatUniqueDetailedConditions puConditions = searchConditions.getPat_unique();
    OrdScheduleDetailedConditions osConditions = searchConditions.getOrd_schedule();
    OrdMainDetailedConditions omConditions = searchConditions.getOrd_main();
    PatGroupSearchRequest patGroupSearch = searchConditions.getPatGroupSearch();
    // add 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 start
    PatGroupSearchRequest simpleSearchPatGroupSearch = searchConditions.getSimpleSearchPatGroupSearch();
    // add 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 end
    List<String> facilityCdList = searchConditions.getFacilityCdList();
    PatInsuranceConditions patInsuranceConditions = searchConditions.getPat_insurance();
    PatExamPatternConditions patExamPatternConditions = searchConditions.getPat_exam_pattern();
    //add No338,339患者詳細検索の追加項目 患者イベント 劉全航 start
    PatEventDetailedConditions peConditions = searchConditions.getPatEvent();
    //add No338,339患者詳細検索の追加項目 患者イベント 劉全航 end
    PatRadPatternDetailedConditions prpConditions = searchConditions.getPat_rad_pattern();

    // 検索結果pat_idを格納していくリスト
    List<Long> patIdList = new ArrayList<Long>();
    //mod 患者詳細検索debug 劉全航 start
    if (ppmConditions.isConditionIsEmpty() == false) {
      //mod 患者詳細検索debug 劉全航 end
      // pat_personal_main検索
      patIdList = patPersonalMainDao.selectByDetailedSearchCondition(ppmConditions, facilityCdList);
      if (patIdList.size() == 0) {
        // 検索結果0件なら空の患者リストを返す
        return new ArrayList<PatPersonalMainData>();
      }
    }
      ////mod 患者詳細検索debug 劉全航 start
    if (pmConditions.isConditionIsEmpty() == false) {
      //mod 患者詳細検索debug 劉全航 end
      // 在院状態の条件を編集
      if(pmConditions.getInOutStateList().size() > 0) {
        List<String> inOutCurrentStateList = pmConditions.getInOutStateList().stream()
            .filter(d -> Integer.parseInt(d) < 100)
            .collect(Collectors.toList());
        List<String> inOutPlanStateList = pmConditions.getInOutStateList().stream()
            .filter(d -> Integer.parseInt(d) >= 100)
            .map(d -> String.valueOf((Integer.parseInt(d) - 100)))
            .collect(Collectors.toList());
        pmConditions.setInOutCurrentStateList(inOutCurrentStateList);
        pmConditions.setInOutPlanStateList(inOutPlanStateList);
      }
      // pat_main検索
      // mod 11315【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 start
      boolean unknownFlag = false;
      if (!CollectionUtils.isEmpty(pmConditions.getInOutCurrentStateList())) {
        List<String> inOutPlanStateList = searchConditions.getPat_main().getInOutCurrentStateList();
        unknownFlag = inOutPlanStateList.contains("10") ? true : false;
      }

      patIdList = patMainDao.selectByDetailedSearchCondition(pmConditions, patIdList, facilityCdList, unknownFlag);
      // mod 11315【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 end
      if (patIdList.size() == 0) {
        // 検索結果0件なら空の患者リストを返す
        return new ArrayList<PatPersonalMainData>();
      }
    }

    if (puConditions != null) {
      // pat_unique検索
      patIdList = patUniqueDao.selectByDetailedSearchCondition(puConditions, patIdList, facilityCdList);
      if (patIdList.size() == 0) {
        // 検索結果0件なら空の患者リストを返す
        return new ArrayList<PatPersonalMainData>();
      }
    }

    // mod 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 start
    List<Long> ordNoList = new ArrayList<>();
    if (osConditions != null) {
      // ベッドグループコードからベッドコードリスト取得
      List<Long> bedCdList = new ArrayList<>();
      List<Integer> bedGroupCdList = osConditions.getBedGroupCdList();
      if (bedGroupCdList != null && !bedGroupCdList.isEmpty()) {
        String tmpFacilityCd = (facilityCdList != null && !facilityCdList.isEmpty()) ? facilityCdList.get(0) : null;
        List<MstRoomBedGroup> mrbgList = mstRoomBedGroupDao.selectByListBedGroupCd(bedGroupCdList, tmpFacilityCd);
        if (mrbgList.isEmpty()) {
          // ベッドグループがマスタから削除されている場合は取得結果が空になるため全ベッドでの検索とする
          osConditions.setBedGroupCdList(null);
        } else {
          // ベッドコードリスト取得
          ObjectMapper mapper = new ObjectMapper();
          for (MstRoomBedGroup mrbg : mrbgList) {
            if (StringUtils.hasText(mrbg.getBedList())) {
              try {
                bedCdList.addAll(mapper.readValue(mrbg.getBedList(), new TypeReference<List<Long>>(){}));
              } catch (tools.jackson.core.JacksonException e) {
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
      }
      osConditions.setBedCdList(bedCdList);

      List<Long> simpleSearchBedCdList = new ArrayList<>();
      if (null != osConditions.getSimpleSearchBedGroupCd()) {
        ObjectMapper mapper = new ObjectMapper();
        MstRoomBedGroup mrbg = mstRoomBedGroupDao.selectByRoomBedGroupCd(osConditions.getSimpleSearchBedGroupCd());
        if (null != mrbg && StringUtils.hasText(mrbg.getBedList())){
          try {
            simpleSearchBedCdList.addAll(mapper.readValue(mrbg.getBedList(), new TypeReference<List<Long>>(){}));
          } catch (tools.jackson.core.JacksonException e) {
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

      osConditions.setSimpleSearchBedCdList(simpleSearchBedCdList);

      // ord_schedule検索
      List<OrdSchedule> ordScheduleList = ordScheduleDao.selectByDetailedSearchCondition(osConditions, patIdList, facilityCdList);
      if (ordScheduleList.size() == 0) {
        // 検索結果0件なら空の患者リストを返す
        return new ArrayList<PatPersonalMainData>();
      }
      if (ordScheduleList.size() > 0) {
        patIdList = ordScheduleList.stream().map(ord -> ord.getPatId()).distinct().collect(Collectors.toList());
        ordNoList = ordScheduleList.stream().map(ord -> ord.getOrdNo()).distinct().collect(Collectors.toList());
      }
    }
    if ((patGroupSearch!= null && patGroupSearch.getPatGroupCd().size() > 0) ||
      (simpleSearchPatGroupSearch != null && simpleSearchPatGroupSearch.getPatGroupCd().size() > 0)) {
      // pat_group_detail検索
      patIdList = patGroupDetailDao.selectPatGroupDetailByGroupList(patIdList, patGroupSearch != null ? patGroupSearch.getPatGroupCd() : new ArrayList<>(),
        patGroupSearch != null ? patGroupSearch.getSearchType() : null,
        simpleSearchPatGroupSearch != null ? simpleSearchPatGroupSearch.getPatGroupCd() : new ArrayList<>(),
        simpleSearchPatGroupSearch != null ? simpleSearchPatGroupSearch.getSearchType() : null);
      if (patIdList.size() == 0) {
        // 検索結果0件なら空の患者リストを返す
        return new ArrayList<PatPersonalMainData>();
      }
    }
    // mod 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 end
    //add No338患者詳細検索の追加項目 患者イベント検索 劉全航 start
    if(peConditions != null){
      patIdList = patEventDao.selectByDetailedSearchCondition(patIdList, peConditions);
      if(patIdList.size() == 0){
        return new ArrayList<PatPersonalMainData>();
      }
    }
    //add No338患者詳細検索の追加項目 患者イベント検索 劉全航 end
    //add No338患者詳細検索の追加項目 保険当月未確認 張岩 start
    if (patInsuranceConditions != null) {
      if (!"".equals(patInsuranceConditions.getInsurance_check_date())) {
        patIdList = patInsuranceDao.selectByDetailedSearchCondition(patInsuranceConditions, patIdList, facilityCdList);
      }
      if (patIdList.size() == 0) {
        return new ArrayList<PatPersonalMainData>();
      }
    }
    if (patExamPatternConditions != null) {
      //mod No.9   吉 start
//      patIdList = patExamPatternDao.selectByDetailedSearchCondition(patExamPatternConditions, patIdList, facilityCdList);
      patIdList = patExamMainDao.selectByDetailedSearchCondition(patExamPatternConditions, patIdList, facilityCdList);
      //mod No.9   吉 end
      if (patIdList.size() == 0) {
        return new ArrayList<PatPersonalMainData>();
      }
    }
    //add No338患者詳細検索の追加項目 保険当月未確認 張岩 end

    //add No338患者詳細検索の追加項目 一般撮影検査予定検索 劉全航 start
    if(prpConditions.isConditionIsEmpty() == false){
      //mod No.9   吉 start
//      patIdList = patRadPatternDao.selectByDetailedSearchCondition(patIdList, prpConditions,facilityCdList);
      patIdList = patRadMainDao.selectByDetailedSearchCondition(patIdList, prpConditions,facilityCdList);
      //mod No.9   吉 end
      if (patIdList.size() == 0) {
        return new ArrayList<PatPersonalMainData>();
      }
    }
    //add No338患者詳細検索の追加項目 一般撮影検査予定検索 劉全航 end
    if (omConditions!= null) {
      boolean flg = false;
      // ord_main検索
      if(omConditions.getDialysisConditionRangeValueList() != null && omConditions.getDialysisConditionRangeValueList().size() > 0) {
        for (int idx = 0; idx < omConditions.getDialysisConditionRangeValueList().size(); idx++) {
          if ("3".equals(omConditions.getConditionId(idx))) {
            flg = true;
            break;
          }
        }
      }
      String rstDialysisStateFlag = "";
      if (omConditions.getSimpleSearchRstDialysisState() != null) {
        if(null != omConditions.getSimpleSearchRstDialysisState()){
          if(omConditions.getSimpleSearchRstDialysisState().size() == 1){
            if(omConditions.getSimpleSearchRstDialysisState().get(0) == 2){
              rstDialysisStateFlag  = "1";
            }else{
              rstDialysisStateFlag  = "2";
            }
          }
        }
      }
      List<OrdMain> ordMainList = ordMainDao.selectByDetailedSearchConditionadd(omConditions, facilityCdList, rstDialysisStateFlag, patIdList);
      if (ordMainList.size() == 0) {
        // 検索結果0件なら空の患者リストを返す
        return new ArrayList<PatPersonalMainData>();
      }
      if (ordMainList.size() > 0) {
        ordMainList = getOrdMainList(ordMainList, ordNoList);
        if (ordMainList.size() > 0) {
          patIdList = ordMainList.stream().map(ord -> ord.getPatId()).distinct().collect(Collectors.toList());
          ordNoList = ordMainList.stream().map(ord -> ord.getOrdNo()).distinct().collect(Collectors.toList());
        }else{
          patIdList = new ArrayList<>();
          ordNoList = new ArrayList<>();
        }
      }else{
        patIdList = new ArrayList<>();
        ordNoList = new ArrayList<>();
      }
      // DW 検索
      boolean dwSearchFlag = false;
      if(omConditions.getDialysisConditionRangeValueList() != null && omConditions.getDialysisConditionRangeValueList().size() > 0) {
        for (int idx = 0; idx < omConditions.getDialysisConditionRangeValueList().size(); idx++) {
          if ("39".equals(omConditions.getConditionId(idx))) {
            dwSearchFlag = true;
            break;
          }
        }
      }
      // 目標体重検索
      if(dwSearchFlag || flg){
        List<OrdMain> patUniqueList = ordMainDao.selectByDetailedSearchCondition(omConditions, facilityCdList, patIdList);
        if (patUniqueList.size() == 0) {
          // 検索結果0件なら空の患者リストを返す
          return new ArrayList<PatPersonalMainData>();
        }
        if (patUniqueList.size() > 0) {
          patUniqueList = getOrdMainList(patUniqueList, ordNoList);
          if (ordMainList.size() > 0) {
            patIdList = patUniqueList.stream().map(ord -> ord.getPatId()).distinct().collect(Collectors.toList());
            ordNoList = patUniqueList.stream().map(ord -> ord.getOrdNo()).distinct().collect(Collectors.toList());
          }else{
            patIdList = new ArrayList<>();
            ordNoList = new ArrayList<>();
          }
        }else{
          patIdList = new ArrayList<>();
          ordNoList = new ArrayList<>();
        }
      }
      if (patIdList.size() == 0) {
        // 検索結果0件なら空の患者リストを返す
        return new ArrayList<PatPersonalMainData>();
      }
    }

    List<PatPersonalMain> patList = new ArrayList<PatPersonalMain>();
    List<PatMain> patMainList = new ArrayList<PatMain>();
    if (patIdList.size() == 0) {
      // 条件未指定の場合は施設内の全患者取得
      patList = patPersonalMainDao.selectAll(facilityCdList);
      patMainList = patMainDao.selectByCdList(facilityCdList);
    }
    else {
      // 検索結果pat_idの患者を取得(条件未指定の場合は全患者取得)
      patList = patPersonalMainDao.selectByIdListFacilityCd(patIdList, facilityCd);
      patMainList = patMainDao.selectByIdListFacilityCd(patIdList, facilityCd);
    }
    // 検索結果の表示に必要な情報のみにする
    List<PatPersonalMainData> patListOnlyIdName = new ArrayList<PatPersonalMainData>();
    // mod 10389 患者リストのソートが遅い gjn start
    for (PatPersonalMain pat: patList) {
      for (PatMain patMain: patMainList) {
        if (pat.getPat_id().equals(patMain.getPat_id())) {
          PatPersonalMainData patOnlyIdName = new PatPersonalMainData();
          patOnlyIdName.setPat_id(pat.getPat_id());
          patOnlyIdName.setFacility_cd(pat.getFacility_cd());
          patOnlyIdName.setHosp_pat_id(pat.getHosp_pat_id());
          patOnlyIdName.setPat_sex(pat.getPat_sex());
          patOnlyIdName.setPat_last_name(pat.getPat_last_name());
          patOnlyIdName.setPat_first_name(pat.getPat_first_name());
          //add FNSI-検査結果内結バグの改修 江 start
          patOnlyIdName.setPat_last_name_kana(pat.getPat_last_name_kana());
          patOnlyIdName.setPat_first_name_kana(pat.getPat_first_name_kana());
          //add FNSI-検査結果内結バグの改修 江 end
          // add FNSI-NO423入院患者名の配布 江 start
          patOnlyIdName.setIn_out_class(pat.getIn_out_class());
          // add FNSI-NO423入院患者名の配布 江 end
          // 患者基本情報から同姓同名フラグを取得
          patOnlyIdName.setIs_same(patMain.getIs_same());
          patListOnlyIdName.add(patOnlyIdName);
        }
      }
    }
    // mod 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 start
    //    return patListOnlyIdName;
    return patListOnlyIdName.stream().sorted(this::comparePatId).toList();
    // mod 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 end
    // mod 10389 患者リストのソートが遅い gjn end
  }

  /**
   * 患者情報検索
   */
  public List<PatPersonalMainData> getPatPersonalMainByList(List<Long> patIdList, String FacilityCd) throws Exception {
    List<PatPersonalMain> patList = new ArrayList<PatPersonalMain>();
    List<PatMain> patMainList = new ArrayList<PatMain>();
    // 検索結果pat_idの患者を取得(条件未指定の場合は全患者取得)
    patList = patPersonalMainDao.selectByIdListFacilityCd(patIdList, FacilityCd);
    patMainList = patMainDao.selectByIdListFacilityCd(patIdList, FacilityCd);

    // 検索結果の表示に必要な情報のみにする
    List<PatPersonalMainData> patListOnlyIdName = new ArrayList<PatPersonalMainData>();
    for (PatPersonalMain pat: patList) {
      PatPersonalMainData patOnlyIdName = new PatPersonalMainData();
      patOnlyIdName.setPat_id(pat.getPat_id());
      patOnlyIdName.setFacility_cd(pat.getFacility_cd());
      patOnlyIdName.setHosp_pat_id(pat.getHosp_pat_id());
      patOnlyIdName.setPat_sex(pat.getPat_sex());
      patOnlyIdName.setPat_last_name(pat.getPat_last_name());
      patOnlyIdName.setPat_first_name(pat.getPat_first_name());
      //add FNSI-検査結果内結バグの改修 江 start
      patOnlyIdName.setPat_first_name_kana(pat.getPat_first_name_kana());
      patOnlyIdName.setPat_last_name_kana(pat.getPat_last_name_kana());
      patOnlyIdName.setIn_out_class(pat.getIn_out_class());
      //add FNSI-検査結果内結バグの改修 江 end
      // 患者基本情報から同姓同名フラグを取得
      for (PatMain patMain: patMainList) {
        if (pat.getPat_id().equals(Long.valueOf(patMain.getPat_id()))) {
          patOnlyIdName.setIs_same(patMain.getIs_same());
          break;
        }
      }
      patListOnlyIdName.add(patOnlyIdName);
    }
    // mod #9948 患者IDのソートが桁数を考慮せずに左端の数字からソートされる 吉 start
    // return patListOnlyIdName;
    List<PatPersonalMainData> jumpList = patListOnlyIdName.stream().filter(pat -> pat.getPat_id() != null && "".equals(pat.getHosp_pat_id().replace("0", "")))
      .sorted(Comparator.comparing((PatPersonalMainData patPersonal) -> patPersonal.getHosp_pat_id(),
        Comparator.nullsLast(Comparator.naturalOrder())).reversed()
        .thenComparing(PatPersonalMain -> PatPersonalMain.getHosp_pat_id().length())
        .thenComparing(PatPersonalMain::getHosp_pat_id, Comparator.nullsLast(Comparator.naturalOrder())).reversed())
      .collect(Collectors.toList());
    List<PatPersonalMainData> jumpList1 = patListOnlyIdName.stream().filter(pat -> pat.getPat_id() != null &&  !"".equals(pat.getHosp_pat_id().replace("0", "")))
      .sorted(Comparator.comparing((PatPersonalMainData patPersonal) ->
          org.apache.commons.lang3.StringUtils.leftPad(patPersonal.getHosp_pat_id(), 12, "0"),
        String.CASE_INSENSITIVE_ORDER).reversed()
        .thenComparing(PatPersonalMain::getHosp_pat_id, Comparator.nullsLast(Comparator.naturalOrder())).reversed())
      .collect(Collectors.toList());
    jumpList.addAll(jumpList1);
    return jumpList;
    // mod #9948 患者IDのソートが桁数を考慮せずに左端の数字からソートされる 吉 end
  }

  /**
   * 施設内の患者名一覧取得
   */
public List<PatPersonalMain> getPatByFacilityCd(List<String> facilityCdList) {
    List<PatPersonalMain> patList = new ArrayList<PatPersonalMain>();
    /* update by chamaojia 2026-02-05 [11893] キャッシュ軽減対応 --start */
    patList = patPersonalMainDao.selectPatByFacilityCd(facilityCdList, new ArrayList<>());
    /* update by chamaojia 2026-02-05 [11893] キャッシュ軽減対応 --end */
    return patList;
  }

  /**
   * 転入・転出履歴取得SQL
   */
  //  add FNSI- 徐博 start
  public List<Map<String, Object>> selectInOut(Long pat_id, String facilityCd) throws Exception {
    List<String> facilityCdList = new ArrayList<>();
    facilityCdList.add(facilityCd);
    List<Long> patIdList = new ArrayList<>();
    patIdList.add(pat_id);
    //  add FNSI- 徐博 end
    List<Map<String, Object>> inOut = patUniqueDao.selectInOut(facilityCdList, patIdList);
    if (inOut.size() == 0) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("患者情報selectInOut() 指定されたpat_idのin_out_visit_history_infoカラムが存在しません。(pat_id: " + pat_id + ")");
      eventLogMessage.setPatId(pat_id.toString());
      eventLogMessage.setSqlIdentification("(FacilityCdList = " + facilityCdList + ", PatIdList = " + patIdList + ")");
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, "PatUniqueDao/selectInOut");
      return null;
    }
    return inOut;
  }

  /* add by chamaojia 2026-02-05 [11893] キャッシュ軽減対応 --start */
  public List<PatByFCAndPIdsResponse> getPatByFacilityAndIds(List<Long> patIds, String facilityCd) {
    List<String> facilityCdList = Collections.singletonList(facilityCd);

    List<PatPersonalMain> patPersonalMains = patPersonalMainDao.selectPatByFacilityCd(facilityCdList, patIds);
    List<PatMain> patMains = patMainDao.selectPatIsSame(facilityCdList, patIds);

    Map<Long, PatMain> patMainMap = patMains.stream()
            .collect(Collectors.toMap(
                    PatMain::getPat_id,
                    Function.identity()
            ));

    List<PatByFCAndPIdsResponse> responseList = new ArrayList<>();
    for (PatPersonalMain p : patPersonalMains) {
      PatByFCAndPIdsResponse response = new PatByFCAndPIdsResponse();
      response.setPat_id(p.getPat_id());
      response.setHosp_pat_id(p.getHosp_pat_id());
      response.setPat_first_name(p.getPat_first_name());
      response.setPat_last_name(p.getPat_last_name());
      response.setPat_first_name_kana(p.getPat_first_name_kana());
      response.setPat_last_name_kana(p.getPat_last_name_kana());
      response.setIn_out_class(p.getIn_out_class());

      PatMain patMain = patMainMap.get(p.getPat_id());
      response.setIs_same(patMain != null ? patMain.getIs_same() : "0");

      responseList.add(response);
    }

    return responseList;
  }
  /* add by chamaojia 2026-02-05 [11893] キャッシュ軽減対応 --end */

  /**
   * 確定・予定転入出状態更新・入外区分更新関数呼び出し
   * @param {pat_id} 患者ID
   * @param {in_out_current_state}　 確定転入出状態
   * @param {in_out_plan_state}　予定転入出状態
   * @param {in_out_plan_date}　予定転入出日時
   * @param {in_out_class}　入外区分
   * @param {payload}　更新日時
   */
  @Transactional
  public void updateInOut(
      Long pat_id,
      String in_out_current_state,
      String in_out_plan_state,
      String in_out_plan_date,
      Integer in_out_class,
      Map<String, String> payload
    ) throws Exception {

    try {
      // mod No.20 じょはく start
//      modify by maxueqiang
      if (String.valueOf(in_out_class).equals("2")) {
        updateInOutState(pat_id, "11", in_out_plan_state, in_out_plan_date, payload);
      } else {
        updateInOutState(pat_id, in_out_current_state, in_out_plan_state, in_out_plan_date, payload);
      }
      // mod No.20 じょはく end
      updateInOutClassById(pat_id, in_out_class, payload);

    } catch (RuntimeException e) {
      throw new RuntimeException(e);
    }
  }

  /**
   * 確定・予定転入出状態更新
   * @param {pat_id} 患者ID
   * @param {in_out_current_state}　 確定転入出状態
   * @param {in_out_plan_state}　予定転入出状態
   * @param {in_out_plan_date}　予定転入出日時
   * @param {payload}　更新日時
   */
  public void updateInOutState(Long pat_id, String in_out_current_state, String in_out_plan_state, String in_out_plan_date, Map<String, String> payload) throws Exception {
    // 各レコードのJSONを対応するクラスにマッピング
    ObjectMapper mapper = new ObjectMapper();
    PatMain pat = mapper.readValue(payload.get("pat_main"), PatMain.class);

    if (in_out_current_state == null && in_out_plan_state == null && in_out_plan_date == null) {
      // DB更新ログ出力ロジック wangzuo Start
      pat.setPat_id(pat_id);
      // DB更新ログ出力ロジック wangzuo End

      patMainDao.updateInOutState(pat_id, null, null, null, pat);
      return;
    }

    // 予定転入出が未定の場合
    if (in_out_plan_state == null || in_out_plan_date == null) {
      in_out_plan_state = null;
      in_out_plan_date = null;
    }

    // DB更新ログ出力ロジック wangzuo Start
    pat.setPat_id(pat_id);
    // DB更新ログ出力ロジック wangzuo End

    patMainDao.updateInOutState(pat_id, in_out_current_state, in_out_plan_state, in_out_plan_date, pat);
    return;
  }

  /**
   * 入外区分更新
   * @param {pat_id}　 患者ID
   * @param {in_out_class}　入外区分
   * @param {payload}　更新日時
   */
  @Transactional
  public void updateInOutClassById(Long pat_id, Integer in_out_class, Map<String, String> payload) throws Exception {
    try {
      // 各レコードのJSONを対応するクラスにマッピング
      ObjectMapper mapper = new ObjectMapper();
      PatPersonalMain pat = mapper.readValue(payload.get("pat_personal_main"), PatPersonalMain.class);

      // DB更新ログ出力ロジック wangzuo Start
      pat.setPat_id(pat_id);
      // DB更新ログ出力ロジック wangzuo End

      patPersonalMainDao.updateInOutClassById(pat_id, in_out_class, pat);
      return;

    } catch (RuntimeException e) {
      throw new RuntimeException(e);
    }
  }

  /**
   * 確定・予定転入出状態取得
   */
  public Map<String, Object> selectInOutState(String facility_cd, Long pat_id) {
    // 患者情報以外でSQLが呼ばれる場合、複数の施設、患者IDから検索をかけるため、それに沿って引数をListに変換
    Map<String, Object> inOutInfoState = patMainDao.selectInOutState(facility_cd, pat_id);

    if (inOutInfoState.size() == 0) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("患者情報selectInOutState() 指定されたpat_idのin_out_plan_state と in_out_plan_dateカラムが存在しません。(pat_id: " + pat_id + ")");
      eventLogMessage.setPatId(pat_id.toString());
      eventLogMessage.setSqlIdentification("(Facility_cd = " + facility_cd + ", Pat_id = " + pat_id + ")");
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, "PatMainDao/selectInOutState");
      return null;
    }
    return inOutInfoState;
  }

  public List<Long> selectPatIdByTreatDate(String treatDate, String facilityCd) throws Exception {
    return ordScheduleDao.selectPatIdByTreatDate(treatDate, facilityCd);
  }

  /**
   * 患者情報論理削除
   * @param {pat_id}　 患者ID
   */
  @Transactional
  // modify 10880 start */
//  public void updateIsDelById(Long pat_id) throws Exception {
  // mod 12005 患者削除時の予定中止は行われるが検査依頼・一般撮影検査依頼の削除が行われない zkm start
//  public void updateIsDelById(Long pat_id,List<OrdMain> oldOrdMains) throws Exception {
  public void updateIsDelById(Long pat_id,List<OrdMain> oldOrdMains, NtssUser ntssUser) throws Exception {
    // mod 12005 患者削除時の予定中止は行われるが検査依頼・一般撮影検査依頼の削除が行われない zkm end
    // modify 10880 end */
    try {

      // DB更新ログ出力ロジック wangzuo Start
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" pat_id = " + pat_id + "\n");
      // logCommon設定
      String tableNameMain = "pat_main";
      DataUpdateLogCommonNew logCommonMain = getLogCommon(tableNameMain, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResultMain = logCommonMain.setInfo();
      // DB更新ログ出力ロジック wangzuo End

      int updateCountMain = patMainDao.updateIsDelById(pat_id);
      // add by maxueqiang bug:5401
      PatPersonalMain patMain = patPersonalMainDao.selectById(pat_id);
      List<PatPersonalMain> patPersonalMains = patPersonalMainDao.selectByPatName(
        patMain.getFacility_cd(),
        patMain.getPat_last_name(),
        patMain.getPat_first_name(),
        patMain.getPat_last_name_kana(),
        patMain.getPat_first_name_kana(),
        patMain.getPat_last_name_alpha(),
        patMain.getPat_first_name_alpha(),
        patMain.getPat_id());
      if (CollectionUtils.isNotEmpty(patPersonalMains) && patPersonalMains.size() == 1){
        patMainDao.updateIsSame(Arrays.asList(patPersonalMains.get(0).getPat_id()), "0");
        // mod #10436 同姓同名フラグの更新時に対になる患者のpat_main_historyがinsertされていない zhao start
        isSameToMoGo(patPersonalMains.get(0).getPat_id());
        // mod #10436 同姓同名フラグの更新時に対になる患者のpat_main_historyがinsertされていない zhao end
      }
      // add by maxueqiang bug:5401
      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      if (setResultMain && updateCountMain > 0) {
        logCommonMain.updateLog();
      }
      // DB更新ログ出力ロジック wangzuo End

      // logCommon設定
      String tableNamePer = "pat_personal_main";
      DataUpdateLogCommonNew logCommonPer = getLogCommon(tableNamePer, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResultPer = logCommonPer.setInfo();
      // DB更新ログ出力ロジック wangzuo End

      int updateCountPer = patPersonalMainDao.updateIsDelById(pat_id);

      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      if (setResultPer && updateCountPer > 0) {
        logCommonPer.updateLog();
      }
      // DB更新ログ出力ロジック wangzuo End

      // add 12005 患者削除時の予定中止は行われるが検査依頼・一般撮影検査依頼の削除が行われない zkm start
      List<jp.co.nikkiso.ntss.api.model.JournalCreateRequestPayload> journalCreateRequestPayloads = deathService
        .deathRelatedProcess(ntssUser.getFacilityCd(), List.of(pat_id), ntssUser.getUserId(), "PAT_DEL");
      if (!CollectionUtils.isEmpty(journalCreateRequestPayloads)) {
        List<JournalCreateRequestPayload> payloads = journalCreateRequestPayloads.stream().map(j -> {
          JournalCreateRequestPayload item = new JournalCreateRequestPayload();
          BeanUtils.copyProperties(j, item);
          return item;
        }).toList();
        journalService.callCreateJournalForCtrNo(payloads);
      }
      // add 12005 患者削除時の予定中止は行われるが検査依頼・一般撮影検査依頼の削除が行われない zkm end

      // logCommon設定
      String tableNameUni = "pat_unique";
      DataUpdateLogCommonNew logCommonUni = getLogCommon(tableNameUni, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResultUni = logCommonUni.setInfo();
      // DB更新ログ出力ロジック wangzuo End

      int updateCountUni = patUniqueDao.updateIsDelById(pat_id);

      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      if (setResultUni && updateCountUni > 0) {
        logCommonUni.updateLog();
      }
      // DB更新ログ出力ロジック wangzuo End

      // add FNSI-改修内容追加OrdMain履歴 付 start
      // del 12005 患者削除時の予定中止は行われるが検査依頼・一般撮影検査依頼の削除が行われない zkm start
//      selectHistoryUtils.insertMangoDbHistory(2, null, pat_id, new ArrayList<>(), new ArrayList<>(), null, null,
//        null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
//        new ArrayList<>(), null, null);
      // del 12005 患者削除時の予定中止は行われるが検査依頼・一般撮影検査依頼の削除が行われない zkm end
      // mangoDb-updateDeleteByPatId-insertSuccess
      // add FNSI-改修内容追加OrdMain履歴 付 end

      // DB更新ログ出力ロジック wangzuo Start
      // del 12005 患者削除時の予定中止は行われるが検査依頼・一般撮影検査依頼の削除が行われない zkm start
//      String tableNameOrd = "ord_main";
//      // SQL検索条件
//      StringBuffer wheresOrd = new StringBuffer("");
//      wheresOrd = new StringBuffer("");
//      wheresOrd.append(" WHERE\n");
//      wheresOrd.append(" pat_id = " + pat_id + "\n");
//      // logCommon設定
//      DataUpdateLogCommonNew logCommonOrd = getLogCommon(tableNameOrd, wheresOrd, getEventLogMessage());
//      // ログ出力カラム情報及び更新前データ情報取得
//      boolean setResultOrd = logCommonOrd.setInfo();
      // del 12005 患者削除時の予定中止は行われるが検査依頼・一般撮影検査依頼の削除が行われない zkm end
      // DB更新ログ出力ロジック wangzuo End

      // mod 10880 start */
//      List<OrdMain> oldOrdMains = ordMainDao.selectByPatId(pat_id);
//      int updateCountOrd = ordMainDao.updateDeleteByPatId(pat_id);
//      triggerUtil.deleteTriggerOrdMain(oldOrdMains);
      // del 12005 患者削除時の予定中止は行われるが検査依頼・一般撮影検査依頼の削除が行われない zkm start
//      int updateCountOrd = ordMainDao.updateDeleteByPatId(pat_id);
//      if(updateCountOrd > 0){
//        triggerUtil.deleteTriggerOrdMain(oldOrdMains);
//      }
      // del 12005 患者削除時の予定中止は行われるが検査依頼・一般撮影検査依頼の削除が行われない zkm end

      // mod 10880 end */

      // add 10880 start */
      //mnt_machine_stateのpat_idに削除対象患者が存在し、その実績がrst_dialysis_state＝4～5の場合は。現患者クリアを実行する。
      List<OrdMain> state45OrdMainList = new ArrayList<>();
      if(oldOrdMains != null && !oldOrdMains.isEmpty()){
        state45OrdMainList = oldOrdMains.stream().filter(item -> "4".equals(item.getRstDialysisState()) || "5".equals(item.getRstDialysisState()))
          .collect(Collectors.toList());
      }
      if(state45OrdMainList != null && !state45OrdMainList.isEmpty()){
        List<Long> state45OrdNoList = state45OrdMainList.stream().map(item -> item.getOrdNo()).distinct().collect(Collectors.toList());
        String facilityCd = state45OrdMainList.get(0).getFacilityCd();
        List<MntMachineState> stateList = mntMachineStateDao.selectByOrdNoList(facilityCd, state45OrdNoList);
        if (stateList != null && !stateList.isEmpty()) {
          for(MntMachineState state : stateList){
            mntMachineStateDao.updateCurrentPatClear(facilityCd, state.getMachineTypeCd(), state.getMachineSerial(), new Timestamp(System.currentTimeMillis()));
          }
        }
      }
      // add 10880 end */

      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      // del 12005 患者削除時の予定中止は行われるが検査依頼・一般撮影検査依頼の削除が行われない zkm start
//      if (setResultOrd && updateCountOrd > 0) {
//        logCommonOrd.updateLog();
//      }
      // del 12005 患者削除時の予定中止は行われるが検査依頼・一般撮影検査依頼の削除が行われない zkm end
      // DB更新ログ出力ロジック wangzuo End

    } catch (RuntimeException e) {
      throw new RuntimeException(e);
    }
  }

  // add FutreNetWeb+SI課題管理No6227 趙 start
  @Transactional
  public void copyDataById(Long pat_id) throws Exception {
    try {
      OrdMainRestore ordMainRestore = new OrdMainRestore();
      List<OrdMain> targetOrdMain = ordMainDao.selectByPatId(pat_id);
      if (targetOrdMain != null && targetOrdMain.size() > 0) {
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
          ordMainRestore.setDelDate(new Timestamp(System.currentTimeMillis()));
          ordMainRestoreDao.insert(ordMainRestore);
        }
      }
    } catch (RuntimeException e) {
      throw new RuntimeException(e);
    }
  }
  // add FutreNetWeb+SI課題管理No6227 趙 end

  /**
   * 患者IDでベッド名とクール名を取得 ※1日指定、期間指定に対応
   * @param patIds
   * @param facilityCd
   * @param treatDate
   * @return
   * @throws Exception
   */
  public List<OrdMainBedAndKur> getBedAndKurByIdsAndRange(List<Long> patIds, String facilityCd, String treatDateStart, String treatDateEnd, String treatDate) throws Exception {
    List<OrdMainBedAndKur> ordMainBedAndKurs = new ArrayList<>();
    ordMainBedAndKurs = ordMainDao.selectBedAndKurDetailByIdsAndRange(patIds, facilityCd, treatDateStart, treatDateEnd, treatDate);
    return ordMainBedAndKurs;
  }

  /**
   * 在宅患者の検索
   * @param {pat_id}　 患者ID
   */
  @Transactional
  public MstUser selectByPatId(Long pat_id, String facilityCd) throws Exception {
    try {
      return mstUserDao.selectByPatId(pat_id, facilityCd);
    } catch (RuntimeException e) {
      throw new RuntimeException(e);
    }
  }

  /**
   * 身体情報を取得
   * @param patId 患者ID
   * @return
   * @throws Exception
   */
  /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */
  // public List<PatUniquePhysicalInfo> selectPhysicalInfoOfOrderNewest(Long patId) throws Exception {
  public List<PatUniquePhysicalInfo> selectPhysicalInfoOfOrderNewest(Long patId, Integer patShareMode) throws Exception {
    try {
      // return patUniqueDao.selectPhysicalInfoOfOrderNewest(patId);
      return patUniqueDao.selectPhysicalInfoOfOrderNewest(patId, patShareMode);
    } catch (RuntimeException e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(e.getLocalizedMessage());
      eventLogMessage.setPatId(patId.toString());
      eventLogMessage.setSqlIdentification("(PatId = " + patId + ")");
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, "PatUniqueDao/selectPhysicalInfoOfOrderNewest");
      throw new RuntimeException(e);
    }
  }
  /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --end */

  /**
	 *
	 * @param patId
	 * @param additionInfo
	 * @return
	 * @throws Exception
	 */
	public int updateAddInfoById(Long patId, String additionInfo) throws Exception {
		try {
      // DB更新ログ出力ロジック wangzuo Start
      String tableName = "pat_main";
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" pat_id = " + patId + "\n");
      // logCommon設定
      DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResult = logCommon.setInfo();
      // DB更新ログ出力ロジック wangzuo End

			int count = patMainDao.updateManualAddInfoById(patId, additionInfo);

      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && count > 0) {
        logCommon.updateLog();
      }
      // DB更新ログ出力ロジック wangzuo End

			return count;
		} catch (RuntimeException e) {
			EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
	        eventLogMessage.setPatId(patId.toString());
	        eventLogMessage.setSqlIdentification("(PatId = " + patId + ", addition_info = " + additionInfo +  ")");
	        logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, "PatMainDao/updateManualAddInfoById");
			throw new RuntimeException(e);
		}
	}

  //del #10412 次患者更新関連全体見直し対応 朴 start
//  /**
//   * 次患者更新呼び出し
//   */
//  public void comSvNotifySetNextPatInfo(String facilityCd, Long pat_id) {
//    String message;
//    try {
//      List<MntMachineState> machineStateList = mntMachineStateDao.selectByNextPatId(facilityCd, pat_id);
//      List<Long> ordNoList = machineStateList.stream().map(item -> item.getNextOrdNo()).distinct().collect(Collectors.toList());
//      List<OrdMain> ordMainList = ordMainDao.selectByOrdNoList(ordNoList);
//      LocalDateTime update = LocalDateTime.now();
//      Long beforeBedCode = Long.parseLong("0");
//      // 次患者更新処理
//      for (OrdMain ord: ordMainList) {
//        Long bedCd = Long.parseLong(ord.getIndBedCd().toString());
//        Long targetOrdNo = ord.getOrdNo();
//        // 登録されているベッド(ベッド移動なしのため変更後として処理※変更前は条件送信キャンセルとして処理されるため)
//        /* mod #5482 by zhangruixue 2023-03-02 スケジュール --start */
////        message = ordMainResource.callDoCancelSetNextPatInfo(facilityCd, beforeBedCode, bedCd, targetOrdNo, true, update);
//        message = ordMainResource.callDoCancelSetNextPatInfo(facilityCd, beforeBedCode, bedCd, ord, true, update);
//        /* mod #5482 by zhangruixue 2023-03-02 スケジュール --end */
//      }
//    } catch (RuntimeException e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage("「条件送信キャンセル」「次患者更新」処理失敗");
//      eventLogMessage.setPatId(pat_id.toString());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
//      eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      eventLogMessage.setPatId(pat_id.toString());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
//      e.printStackTrace();
//    }
//  }
  //del #10412 次患者更新関連全体見直し対応 朴 end

  /**
   * 患者メモマスタ更新に伴う患者メモ展開
   * @param facilityCd 施設コード
   * @param strSql JSON更新用SQL
   * @return
   */
  @Transactional
  public void updatePatMemoInfo(String facilityCd, String strSql) throws Exception {
    try {
      masterMaintenanceGenericDao.updatePatMemoInfo(facilityCd, strSql);
    } catch (RuntimeException e) {
      throw new RuntimeException(e);
    }
  }

  public List<AdditionInfo> selectPatAdditionInfo(String facilityCd, Long patId) {
    List<AdditionInfo> list = new ArrayList<AdditionInfo>();
    try {
      list = patMainDao.selectAdditionInfo(facilityCd, patId);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      eventLogMessage.setPatId(patId.toString());
      eventLogMessage.setSqlIdentification("(patId = " + patId + ", facility_cd = " + facilityCd +  ")");
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, "PatMainDao/selectAdditionInfo");
      throw new RuntimeException(e);
    }
    return list;
  }

  /**
   * 検索(患者名)
   * @param patIdList 患者IDリスト
   * @return 検索にヒットした患者名のリスト
   */
  public List<PatPersonalMain>getPatListName(List<Long> patIdList, String facilityCd) {
    // 検索結果pat_idの患者を取得(条件未指定の場合は全患者取得)
    List<PatPersonalMain> patList = patPersonalMainDao.selectByIdListFacilityCd(patIdList, facilityCd);

    // 検索結果の表示に必要な情報のみにする
    List<PatPersonalMain> patListOnlyName = new ArrayList<PatPersonalMain>();
    for (PatPersonalMain pat: patList) {
      PatPersonalMain patOnlyName= new PatPersonalMain();
      patOnlyName.setPat_id(pat.getPat_id());
      patOnlyName.setPat_last_name(pat.getPat_last_name());
      patOnlyName.setPat_first_name(pat.getPat_first_name());
      patListOnlyName.add(patOnlyName);
    }

    return patListOnlyName;
  }

  /**
   * 検査依頼用患者情報検索
   * @param patIdList 患者IDリスト
   * @return 検索にヒットした患者情報のリスト
   */
  public List<PatMain>getPatSchExtEndDateList(List<Long> patIdList) {
    // 検索結果pat_idの患者を取得(条件未指定の場合は全患者取得)
    List<PatMain> patInfoList = patMainDao.selectByIdList(patIdList);

    // 検索結果の表示に必要な情報のみにする
    List<PatMain> patListOnlyNeed = new ArrayList<PatMain>();
    for (PatMain pat: patInfoList) {
      PatMain patOnlyNeed= new PatMain();
      patOnlyNeed.setPat_id(pat.getPat_id());
      patOnlyNeed.setSch_ext_end_date(pat.getSch_ext_end_date());
      patListOnlyNeed.add(patOnlyNeed);
    }

    return patListOnlyNeed;
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

    // mod FNSI-連携イベントの登録適正化 楊 start
    String lastName = "";
    String fristName = "";
    if (null != payload.getHospPatId()) {
      PatPersonalMain patPersonalMain = patPersonalMainDao.selectPatInfoByHospPatId(payload.getFacilityCd(), payload.getHospPatId());
      lastName = patPersonalMain.getPat_last_name();
      fristName = patPersonalMain.getPat_first_name();
    }

    MstCoopFacility.CoopOrdCd coopCd = this.getCoopOrdCd(payload.getFacilityCd(), payload.getOpeCd());

//    if (StringUtils.isEmpty(payload.getHospPatId())) {
//      PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(payload.getPatId());
//      payload.setHospPatId(patPersonalMain.getHosp_pat_id());
//    }

//    String targetDate = "";
//    String category = "未登録";
//    // 予定期限
//    if (payload.getCoopCd().equals("exam_ord")) {
//        // 検査結果を取得
//        PatExamMain examResult = patExamMainDao.selectPatExamMainByExamMainCd(payload.getOrdNo());
//        if (examResult != null) {
//          targetDate = sdf.format(examResult.getRegExamDate());
//          category = getRegOrderClassName(examResult.getRegOrderClass());
//        }
//    } else if (payload.getCoopCd().equals("rad_ord")) {
//      PatRadMain patRadMain = patRadMainDao.selectByPrimaryKey(payload.getOrdNo());
//      if(patRadMain != null) {
//        targetDate = sdf.format(patRadMain.getRegRadDate());
//        category = getRegOrderClassName(patRadMain.getRegOrderClass());
//      }
//    } else {
//      OrdMain ordMain = ordMainDao.selectByOrdNo(payload.getOrdNo());
//      if(ordMain != null) {
//        targetDate = ordMain.getTreatDate();
//        MstKur mstKur = mstKurDao.selectByKurCd(ordMain.getIndKurCd().toString());
//        if(mstKur != null) {
//          category = mstKur.getKurName();
//        }
//      }
//    }
    // mod FNSI-連携イベントの登録適正化 楊 end
    // 通知メッセージ及び付加情報の変換用JSONデータを作成 値は文字列型にすること
    JSONObject replaceData = new JSONObject();
    replaceData.put("HOSP_PAT_ID", payload.getHospPatId());
    // mod FNSI-連携イベントの登録適正化 楊 start
//    replaceData.put("COOP_CD", coopCds.get(payload.getCoopCd()));
    replaceData.put("LASTNAME", lastName);
    replaceData.put("FIRSTNAME", fristName);
  	replaceData.put("COOP_CD", "不明");
    //replaceData.put("COOP_CD", coopCd.getCoopName());
    // mod FNSI-連携イベントの登録適正化 楊 end

    // del FNSI-連携イベントの登録適正化 楊 start
//    replaceData.put("UP_DATE", sdf.format(currentTime));
    // del FNSI-連携イベントのd登録適正化 楊 end
    replaceData.put("TARGET_DATE", formatDateString(payload.getBaseDate(), "yyyyMMdd"));
    // del FNSI-連携イベントの登録適正化 楊 start
//    replaceData.put("CATEGORY", category);
//    replaceData.put("PAT_ID", payload.getPatId().toString());
//    replaceData.put("FACILITY_CD", payload.getFacilityCd());
    // del FNSI-連携イベントの登録適正化 楊 end


    // 通知登録
    // modify 9583 by kangjie 20240410 start
//    webApiCallCommonUtil.registerNotification(NotificationDefinition.CREATE_JOURNAL, payload.getFacilityCd(), replaceData);
    // modify 9583 by kangjie 20240410 end
  }

  // mod FNSI-連携イベントの登録適正化 楊 start
  /**
   * 連携対象の電文種別を取得する。
   *
   * @param facilityCd 施設コード
   * @param opeCd オペコード
   * @return 連携対象の電文種別
   */
  public MstCoopFacility.CoopOrdCd getCoopOrdCd(String facilityCd, String opeCd) {
    MstCoopFacility.CoopOrdCd coopCd = null;
    // オペコードを取得する
    MstCoopFacility mstCoopFacility = mstCoopFacilityDao.select(facilityCd);
    if (mstCoopFacility != null) {
      MstCoopFacility.CommonSetting commonSetting = mstCoopFacility.getCommonSetting();
      if (commonSetting != null) {
        MstCoopFacility.CoopOpeCd coopOpeCd = commonSetting.getCoopOpeCd();
        if (coopOpeCd != null) {
          // オペコード
          List<MstCoopFacility.OpeCdStatus> opeCdSends = coopOpeCd.getOpeCdSends();
          if (opeCdSends != null && opeCdSends.size() != 0) {
            // オペコードをループ
            for(MstCoopFacility.OpeCdStatus opeStatus : opeCdSends) {
              // オペコード存在の場合
              if (opeCd.equals(opeStatus.getOpeCd())) {
                // 「on:有効」の場合
                if ("on".equals(opeStatus.getStatus())) {
                  List<MstCoopFacility.CoopOrdCd> coopOrdCds = commonSetting.getCoopOrdCds();
                  for(MstCoopFacility.CoopOrdCd coopOrdCd : coopOrdCds) {
                    List<String> opeCds = coopOrdCd.getOpeCds();
                    if (opeCds != null && opeCds.size() != 0
                      && opeCds.contains(opeCd)) {
                      coopCd = coopOrdCd;
                      break;
                    }
                  }
                } else {
                  // 「off:無効」の場合
                  return coopCd;
                }
                break;
              }
            }
          }
        }
      }
    }
    return coopCd;
  }
  // mod FNSI-連携イベントの登録適正化 楊 end
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

  /**
   * 送信電文種別
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
    hashMap.put("exam_ord", "検査オーダ");
    hashMap.put("rad_ord", "放射線オーダ");
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
   * プッシュ通知登録(web-apiに登録)
   * @param assignedPatId 内部患者ID
   * @param payload 登録情報
   * @param patGroupDiff 患者グループの差分
   * @param isCreated 新規患者登録かどうか
   */
  public void registerPushNotification(Long assignedPatId, Map<String, String> payload, JSONObject patGroupDiff, Boolean isCreated) {
    try {
      // 各レコードのJSONを対応するクラスにマッピング
      ObjectMapper mapper = new ObjectMapper();
      PatPersonalMain patPersonalMain = mapper.readValue(payload.get("pat_personal_main"), PatPersonalMain.class);
      PatUnique patUnique = mapper.readValue(payload.get("pat_unique"), PatUnique.class);
      PatMain patMain = mapper.readValue(payload.get("pat_main"), PatMain.class);

      // 患者情報抽出用のデータを設定
      JSONObject changedRecord = new JSONObject(payload.get("changed_record"));
      JSONObject patGroupInfo = new JSONObject(payload.get("pat_group_info"));
      String facilityCd = patPersonalMain.getFacility_cd();

      // 基本的情報を持った変換用JSONデータを作成
      JSONObject baseReplaceData = new JSONObject();
      baseReplaceData.put("LASTNAME", patPersonalMain.getPat_last_name());
      baseReplaceData.put("FIRSTNAME", patPersonalMain.getPat_first_name());

      // No.1 新規患者登録通知
      if (isCreated) {
        // 通知メッセージ及び付加情報の変換用JSONデータを作成 値は文字列型にすること
        JSONObject replaceData = new JSONObject(baseReplaceData, JSONObject.getNames(baseReplaceData));
        replaceData.put("PATID", assignedPatId.toString());
        replaceData.put("HOSPPATID", patPersonalMain.getHosp_pat_id());
        replaceData.put("FACILITYCD", facilityCd);
        webApiCallCommonUtil.registerNotification(NotificationDefinition.CREATE_PAT, facilityCd, replaceData);
      }
      // No.2 感染症患者ON通知
      if (changedRecord.has("is_infect")) {
        if (changedRecord.getJSONObject("is_infect").getString("editValue").equals("1")) {
          // 通知メッセージ及び付加情報の変換用JSONデータを作成 値は文字列型にすること
          JSONObject replaceData = new JSONObject(baseReplaceData, JSONObject.getNames(baseReplaceData));
          replaceData.put("PATID", assignedPatId.toString());
          replaceData.put("FACILITYCD", facilityCd);
          webApiCallCommonUtil.registerNotification(NotificationDefinition.REGISTER_INFECT_PAT, facilityCd, replaceData);
        }
      }
      // No.3 感染症(＋)に変更通知
      if (changedRecord.has("infect_info")) {
        Boolean notifyFlg = false;
        // 感染症を+に変更したものがあるか検索 １つでもあれば通知する
        JSONArray infectInfoArray = changedRecord.getJSONArray("infect_info");
        for (int idx = 0; idx < infectInfoArray.length(); idx++) {
          JSONObject infectInfo = infectInfoArray.getJSONObject(idx);
          if (infectInfo.has("infect")) {
            if (infectInfo.getJSONObject("infect").getString("editValue").equals("2")) {
              notifyFlg = true;
            }
          }
        }
        if (notifyFlg) {
          // 通知メッセージ及び付加情報の変換用JSONデータを作成 値は文字列型にすること
          JSONObject replaceData = new JSONObject(baseReplaceData, JSONObject.getNames(baseReplaceData));
          replaceData.put("PATID", assignedPatId.toString());
          replaceData.put("FACILITYCD", facilityCd);
          webApiCallCommonUtil.registerNotification(NotificationDefinition.CHANGE_INFECT_POSITIVE, facilityCd, replaceData);
        }
      }
      // No.4 禁忌・ｱﾚﾙｷﾞｰ追加・更新・削除通知
      if (changedRecord.has("taboo_allergy_info")) {
        // 通知メッセージ及び付加情報の変換用JSONデータを作成 値は文字列型にすること
        JSONObject replaceData = new JSONObject(baseReplaceData, JSONObject.getNames(baseReplaceData));
        replaceData.put("PATID", assignedPatId.toString());
        replaceData.put("FACILITYCD", facilityCd);
        webApiCallCommonUtil.registerNotification(NotificationDefinition.UPDATE_TABOO_ALLERGY, facilityCd, replaceData);
      }
      // No.5～10 入外・転入出
      if (changedRecord.has("in_out_visit_history_info")) {
        // 入外・転入出の変更箇所のみのデータ（変更がない箇所は空データ、initValue/editValueを含む）
        JSONArray changedInOutVisitHistInfoArray = changedRecord.getJSONArray("in_out_visit_history_info");
        // pat_mainから取得した入外・転入出のデータ（変更にかかわらず全データ保持、initValue/editValueを含まない）
        JSONArray patMainInOutVisitHistInfoArray = new JSONArray(patUnique.getIn_out_visit_history_info());

        // 入外・転入出レコードをそれぞれ検索
        for (int idx = 0; idx < changedInOutVisitHistInfoArray.length(); idx++) {
          JSONObject changedinOutVisitHistInfo = changedInOutVisitHistInfoArray.getJSONObject(idx);
          if (changedinOutVisitHistInfo.has("move_in_out")) {
            // 入外区分
            String moveInOut = changedinOutVisitHistInfo.getJSONObject("move_in_out").getString("editValue");
            // 日付データ
            String startDate = makeStartDate(patMainInOutVisitHistInfoArray.getJSONObject(idx));

            // 通知メッセージ及び付加情報の変換用JSONデータを作成 値は文字列型にすること
            JSONObject replaceData = new JSONObject(baseReplaceData, JSONObject.getNames(baseReplaceData));
            replaceData.put("STARTDATE", startDate);
            replaceData.put("PATID", assignedPatId.toString());
            replaceData.put("FACILITYCD", facilityCd);

            switch (moveInOut) {
              case "2":
                // No.5 転入通知
                webApiCallCommonUtil.registerNotification(NotificationDefinition.MOVE_IN, facilityCd, replaceData);
                break;
              case "3":
                // No.6 転出通知
                webApiCallCommonUtil.registerNotification(NotificationDefinition.MOVING_OUT, facilityCd, replaceData);
                break;
              case "7":
                // No.8 離脱通知
                webApiCallCommonUtil.registerNotification(NotificationDefinition.WITHDRAWAL, facilityCd, replaceData);
                break;
              case "8":
                // No.9 移植通知
                webApiCallCommonUtil.registerNotification(NotificationDefinition.IMPLANTATION, facilityCd, replaceData);
                break;
              case "9":
                // No.7 一時転出通知
                // 日付データ（終了日）
                String endDate = makeEndDate(patMainInOutVisitHistInfoArray.getJSONObject(idx));
                replaceData.put("ENDDATE", endDate);
                webApiCallCommonUtil.registerNotification(NotificationDefinition.TEMPORARILY_MOVING_OUT, facilityCd, replaceData);
                break;
              default:
                break;
            }
          }
        }
      }

      // No.10 死亡通知
      if (changedRecord.has("is_die")) {
        String dieDate = "未指定";
        if (changedRecord.getJSONObject("is_die").getString("editValue").equals("1")) {
          if (changedRecord.has("medical_hst_info")) {
            JSONArray medicalHstInfoArray = changedRecord.getJSONArray("medical_hst_info");
            // 既往歴レコードをそれぞれ検索
            for (int idx = 0; idx < medicalHstInfoArray.length(); idx++) {
              JSONObject medicalHstInfo = medicalHstInfoArray.getJSONObject(idx);
              // 死亡日があるレコードがあれば死亡日をセット
              if (medicalHstInfo.has("die_date")) {
                dieDate = makeDieDate(medicalHstInfo.getJSONObject("die_date").getString("editValue"));
              }
            }
          }
          // 通知メッセージ及び付加情報の変換用JSONデータを作成 値は文字列型にすること
          JSONObject replaceData = new JSONObject(baseReplaceData, JSONObject.getNames(baseReplaceData));
          replaceData.put("DIEDATE", dieDate);
          replaceData.put("PATID", assignedPatId.toString());
          replaceData.put("FACILITYCD", facilityCd);
          webApiCallCommonUtil.registerNotification(NotificationDefinition.DEATH, facilityCd, replaceData);
        }
      }

      // No.13 患者グループ通知
      // 新規登録時は登録している患者グループすべてについて通知
      if (isCreated) {
        if (!patGroupInfo.getString("pat_group_list").equals("[]")) {
          JSONArray patGroupDetailFromPayload = new JSONArray(patGroupInfo.getString("pat_group_list"));
          for (int idx = 0; idx < patGroupDetailFromPayload.length(); idx++) {
            JSONObject patGroupDetail = patGroupDetailFromPayload.getJSONObject(idx);
            // 通知メッセージ及び付加情報の変換用JSONデータを作成 値は文字列型にすること
            JSONObject replaceData = new JSONObject(baseReplaceData, JSONObject.getNames(baseReplaceData));
            replaceData.put("PATGROUP", patGroupDetail.getString("patGroupName"));
            replaceData.put("PATID", assignedPatId.toString());
            replaceData.put("FACILITYCD", facilityCd);
            // mode 9546 by kangjie 20230830 start
            replaceData.put("PATGROUPCD", String.valueOf(patGroupDetail.getLong("patGroupCd")));
            // mode 9546 by kangjie 20230830 end
            webApiCallCommonUtil.registerNotification(NotificationDefinition.ADD_PAT_GROUP, facilityCd, replaceData);
          }
        }
      } else {
        // 更新時は追加/削除された患者グループのみに絞って通知
        // 追加
        JSONArray addPatGroupCd = new JSONArray(patGroupDiff.getString("add_pat_group_cd"));
        for (int idxAdd = 0; idxAdd < addPatGroupCd.length(); idxAdd++) {
          Long patGroupCd = addPatGroupCd.getLong(idxAdd);
          PatGroup patGroup = patGroupDao.selectById(patGroupCd, facilityCd);
          // 通知メッセージ及び付加情報の変換用JSONデータを作成 値は文字列型にすること
          JSONObject replaceData = new JSONObject(baseReplaceData, JSONObject.getNames(baseReplaceData));
          replaceData.put("PATGROUP", patGroup.getPatGroupName());
          replaceData.put("OPERATION", "に追加");
          replaceData.put("PATID", assignedPatId.toString());
          replaceData.put("FACILITYCD", facilityCd);
          // mode 9546 by kangjie 20230830 start
          replaceData.put("PATGROUPCD", String.valueOf(patGroupCd));
          // mode 9546 by kangjie 20230830 end
          webApiCallCommonUtil.registerNotification(NotificationDefinition.ADD_PAT_GROUP, facilityCd, replaceData);
        }

        // 削除
        JSONArray delPatGroupCd = new JSONArray(patGroupDiff.getString("delete_pat_group_cd"));
        for (int idxDel = 0; idxDel < delPatGroupCd.length(); idxDel++) {
          Long patGroupCd = delPatGroupCd.getLong(idxDel);
          PatGroup patGroup = patGroupDao.selectById(patGroupCd, facilityCd);
          // 通知メッセージ及び付加情報の変換用JSONデータを作成 値は文字列型にすること
          JSONObject replaceData = new JSONObject(baseReplaceData, JSONObject.getNames(baseReplaceData));
          replaceData.put("PATGROUP", patGroup.getPatGroupName());
          replaceData.put("OPERATION", "から削除");
          replaceData.put("PATID", assignedPatId.toString());
          replaceData.put("FACILITYCD", facilityCd);
          // mode 9546 by kangjie 20230830 start
          replaceData.put("PATGROUPCD", String.valueOf(patGroupCd));
          // mode 9546 by kangjie 20230830 end
          webApiCallCommonUtil.registerNotification(NotificationDefinition.ADD_PAT_GROUP, facilityCd, replaceData);
        }
      }

      // No.15 担当者に設定通知
      if (changedRecord.has("charge_staff_info")) {
        // 担当者の変更箇所のみのデータ（変更がない箇所は空データ、initValue/editValueを含む）
        JSONArray changedStaffInfoArray = changedRecord.getJSONArray("charge_staff_info");
        // pat_mainから取得した担当者のデータ（変更にかかわらず全データ保持、initValue/editValueを含まない）
        JSONArray patMainStaffInfoArray = new JSONArray(patMain.getCharge_staff_info());

        // 何かしら値の入っている場合個別に通知
        for (int idx = 0; idx < changedStaffInfoArray.length(); idx++) {
          JSONObject changedStaffInfo = changedStaffInfoArray.getJSONObject(idx);
          if (changedStaffInfo.length() > 0) {
            JSONObject patMainStaffInfo = patMainStaffInfoArray.getJSONObject(idx);
            Long userId = patMainStaffInfo.getLong("staff_cd");
            // 利用者名の取得
            MstPersonalUser staffUser = mstPersonalUserDao.selectById(userId);
            String staffLastName = staffUser.getUserLastName();
            String staffFirstName = staffUser.getUserFirstName();
            // 担当者種別の取得
            String mainStaff = changedStaffInfo.has("is_main") && changedStaffInfo.getJSONObject("is_main").getString("editValue").equals("1")
                ? "主治医"
                : "";
            String chargeStaff = changedStaffInfo.has("is_charge") && changedStaffInfo.getJSONObject("is_charge").getString("editValue").equals("1")
                ? "担当者"
                : "";
            String punctureStaff = changedStaffInfo.has("is_puncture") && changedStaffInfo.getJSONObject("is_puncture").getString("editValue").equals("1")
                ? "穿刺者"
                : "";
            String comma1 = !mainStaff.equals("") && !chargeStaff.equals("") ? "、" : "";
            String comma2 = !chargeStaff.equals("") && !punctureStaff.equals("") ? "、" : "";
            String StaffType = mainStaff + comma1 + chargeStaff + comma2 + punctureStaff;
            // チェックONにしたときのみ通知する
            if (!StaffType.equals("")) {
              // 通知メッセージ及び付加情報の変換用JSONデータを作成 値は文字列型にすること
              JSONObject replaceData = new JSONObject(baseReplaceData, JSONObject.getNames(baseReplaceData));
              replaceData.put("STAFFLASTNAME", staffLastName);
              replaceData.put("STAFFFIRSTNAME", staffFirstName);
              replaceData.put("STAFFTYPE", StaffType);
              replaceData.put("PATID", assignedPatId.toString());
              replaceData.put("FACILITYCD", facilityCd);
              //5794 add 担当者に設定された際の通知が関係のないユーザーに発生する 関俊楠 start
              replaceData.put("USERID", userId.toString());
              //5794 add 担当者に設定された際の通知が関係のないユーザーに発生する 関俊楠 end
              webApiCallCommonUtil.registerNotification(NotificationDefinition.SET_CHARGE_STAFF, facilityCd, replaceData);
            }
          }
        }
      }
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();

      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
    }
  }

  /**
   * 通知用日付データの作成(開始日)
   * @param inputData 入外・転入出 １レコード分
   * @return 日付（YYYY年M月D日） 欠損登録部分は非表示
   */
  private String makeStartDate(JSONObject inputData) {
    String year = "";
    String month = "";
    String day = "";

    // 年がnull→全欠損
    if (inputData.isNull("period_start_year")) {
      return "未指定";
    } else {
      year = inputData.getString("period_start_year") + "年";
    }

    // 月がnull→月・日欠損
    if (inputData.isNull("period_start_month")) {
      return year;
    } else {
      month = inputData.getString("period_start_month").replaceFirst("^0+", "") + "月";
    }

    // 日がnull→日欠損
    if (inputData.isNull("period_start_day")) {
      return year + month;
    } else {
      day = inputData.getString("period_start_day").replaceFirst("^0+", "") + "日";
    }
    return year + month + day;
  }

  /**
   * 通知用日付データの作成(終了日)
   * @param inputData 入外・転入出 １レコード分
   * @return 日付（YYYY年M月D日） 欠損登録部分は非表示
   */
  private String makeEndDate(JSONObject inputData) {
    String year = "";
    String month = "";
    String day = "";

    // 年がnull→全欠損
    if (inputData.isNull("period_end_year")) {
      return "未指定";
    } else {
      year = inputData.getString("period_end_year") + "年";
    }

    // 月がnull→月・日欠損
    if (inputData.isNull("period_end_month")) {
      return year;
    } else {
      month = inputData.getString("period_end_month").replaceFirst("^0+", "") + "月";
    }

    // 日がnull→日欠損
    if (inputData.isNull("period_end_day")) {
      return year + month;
    } else {
      day = inputData.getString("period_end_day").replaceFirst("^0+", "") + "日";
    }
    return year + month + day;
  }

  /**
   * 通知用日付データの作成(死亡日)
   * @param inputData 日付(YYYYMMDD)
   * @return 日付（YYYY年M月D日） 欠損登録部分は非表示
   */
  private String makeDieDate(String inputData) {
    String year = inputData.substring(0, 4).replaceFirst("^0+", "") + "年";
    String month = inputData.substring(4, 6).replaceFirst("^0+", "") + "月";
    String day = inputData.substring(6).replaceFirst("^0+", "") + "日";
    return year + month + day;
  }

  /**
   * 患者グループの差異を検索
   * @param payload 登録情報
   * @return 患者グループの差異
   */
  public JSONObject getPatGroupDiff(Long patId, Map<String, String> payload) {
    JSONObject patGroupDiff = new JSONObject();
    /* mod #6062 by zhangruixue 2023-06-01 --start */
    // 削除リスト
    List<Long> deletePatGroupCd = new ArrayList<Long>();
    // 元データの取得
    List<PatGroupDetail> patGroupDetailFromDb = patGroupDetailDao.selectByPatId(patId);
    // 追加リスト
    List<Long> addPatGroupCd = new ArrayList<Long>();

    if(payload.get("pat_group_info") != null){
      /* mod #6062 by zhangruixue 2023-06-01 --end */
      JSONObject patGroupInfo = new JSONObject(payload.get("pat_group_info"));
      JSONArray patGroupDetailFromPayload = new JSONArray(patGroupInfo.getString("pat_group_list"));



      // 削除リストの抽出
      patGroupDetailFromDb.stream().forEach(item -> {
        Boolean isDeleted = true; // 削除フラグ：初期値trueで登録情報側に同じpatGroupCdがいればfalseになる
        for (int i = 0; i < patGroupDetailFromPayload.length(); i++) {
          JSONObject patGroupDetail = patGroupDetailFromPayload.getJSONObject(i);
          //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("patGroupDetail: " + patGroupDetail.toString());
          logService.log(LogLevel.INFO, eventLogMessage,FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
          //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end
          if (Long.valueOf(patGroupDetail.getLong("patGroupCd")).equals(item.getPatGroupCd())) {
            isDeleted = false;
            // add 10626 データリストのCTR・DW一括登録修正 房 start
            break;
            // add 10626 データリストのCTR・DW一括登録修正 房 end
          }
        }
        if (isDeleted) {
          deletePatGroupCd.add(item.getPatGroupCd());
        }
      });



      // 追加リストの抽出
      for (int j = 0; j < patGroupDetailFromPayload.length(); j++) {
        Boolean isAdded = true; // 追加フラグ：初期値trueで登録情報側に同じpatGroupCdがいればfalseになる
        JSONObject patGroupDetail = patGroupDetailFromPayload.getJSONObject(j);
        for (PatGroupDetail item : patGroupDetailFromDb) {
          if (item.getPatGroupCd().equals(patGroupDetail.getLong("patGroupCd"))) {
            isAdded = false;
            // add 10626 データリストのCTR・DW一括登録修正 房 start
            break;
            // add 10626 データリストのCTR・DW一括登録修正 房 end
          }
        }
        if (isAdded) {
          addPatGroupCd.add(patGroupDetail.getLong("patGroupCd"));
        }
      }

    }
    patGroupDiff.put("delete_pat_group_cd", deletePatGroupCd.toString());
    patGroupDiff.put("add_pat_group_cd", addPatGroupCd.toString());
    return patGroupDiff;
  }

  // add FNSI-紹介状を追加 楊 start
  /**
   * 紹介状データの検索
   * @param patId 患者ID
   * @return 紹介状データ
   */
  public PatUnique getLetterDataList (Long patId) {
    return patUniqueDao.selectById(patId);
  }
  // add FNSI-紹介状を追加 楊 end

  /*add FNSI-改修内容転入転出の患者情報連動 任 start*/
  @Transactional
  public void updateUniqueById(Long pat_id, Map<String, String> payload) throws Exception {
    ObjectMapper mapper = new ObjectMapper();
    PatUnique patUnique = mapper.readValue(payload.get("pat_unique"), PatUnique.class);

    // DB更新ログ出力ロジック wangzuo Start
    patUnique.setPat_id(pat_id);
    // DB更新ログ出力ロジック wangzuo End

    patUniqueDao.updateUniqueById(pat_id, patUnique);
  }
  /*add FNSI-改修内容転入転出の患者情報連動 任 end*/

  // add FNSI-患者情報共有よりの改修 江 start
  public List<SharedPatFacilityInfo> selectFacilityList(String facilityCd, Long patId) {
    List<SharedPatFacilityInfo> list = new ArrayList<SharedPatFacilityInfo>();
    try {
      list = patMainDao.selectFacilityList(facilityCd, patId);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      eventLogMessage.setPatId(patId.toString());
      eventLogMessage.setSqlIdentification("(patId = " + patId + ", facility_cd = " + facilityCd +  ")");
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, "PatMainDao/selectFacilityList");
      throw new RuntimeException(e);
    }
    return list;
  }

  public int checkIsPrint(Map<String,Object>parm) {
    try {
      int count = patMainDao.checkIsPrint(parm.get("facilityCd").toString(),Integer.valueOf(parm.get("patId").toString()),
        parm.get("treatDate").toString(),Integer.valueOf(parm.get("reportCd").toString()));
      return count;
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, "patMainDao/checkIsPrint");
      throw new RuntimeException(e);
    }
  }

  public List<MstFacility> selectNewPatFacility(String facilityCd) {
    List<MstFacility> list = new ArrayList<MstFacility>();
    try {
      MstFacility mstFacility = mstFacilityDao.selectByCd(facilityCd);
      list.add(mstFacility);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      eventLogMessage.setSqlIdentification("facility_cd = " + facilityCd +  ")");
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, "MstFacilityDao/selectByCd");
      throw new RuntimeException(e);
    }
    return list;
  }


  // add FNSI-患者情報共有よりの改修 江 end
  // add MongoDB共通インターフェース 関 start
  // #11205 -ペンテスト2－4認可制御の不備  add 20260427 start
  public List getPatHistory(Map<String, ?> payload, String facilityCd) {
  // #11205 -ペンテスト2－4認可制御の不備  add 20260427 end
    try {
      List list = new ArrayList<Object>();
      String collection = "";
      if (payload.get("collection") != null) {
        collection = (String) payload.get("collection");
      }else {
        return list;
      }
      Bson bson = null;
      ArrayList<Bson> arr = new ArrayList();
      if (payload.get("filter") != null) {
        Map<String,String> filter = (Map) payload.get("filter");
        for(String key : filter.keySet()){
          arr.add(eq(key , filter.get(key)));
        }
      }
      if (payload.get("from") != null && payload.get("to") != null) {
        String from = (String) payload.get("from");
        String to =  (String) payload.get("to");
        SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        formatter.setTimeZone(TimeZone.getTimeZone("Asia/Tokyo"));
        Date strToDate = formatter.parse(from);
        Date fromDate = DateIsoUtils.dateToISODate(strToDate);
        arr.add(gt("ins_date", fromDate));

        strToDate = formatter.parse(to);
        Date toDate = DateIsoUtils.dateToISODate(strToDate);
        arr.add(lt("ins_date", toDate));
      }
      // #11205 -ペンテスト2－4認可制御の不備  add 20260427 start
      if (!ObjectUtils.isEmpty(facilityCd)) {
        arr.add(eq("facility_cd", facilityCd));
      }
      // #11205 -ペンテスト2－4認可制御の不備  add 20260427 end
      if (arr.size() > 1) {
        bson = and(arr);
      }
      else if (arr.size() == 1) {
        bson = arr.get(0);
      }
      FindIterable<Document> findResult = null;
      //add 10248 mongodbリンク可能状態による関連操作の処理 gjn start
      try {
        if (MongoHealthCheckService.getMongoDBConnected()) {
          if (bson == null) {
            findResult = mongoTemplate.getCollection(collection).find();
          }
          else {
            findResult = mongoTemplate.getCollection(collection).find(bson);
          }
        }
      } catch (DataAccessResourceFailureException exception) {
        MongoHealthCheckService.setMongoDBConnected(false);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//            exception.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(exception));
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      }
      //add 10248 mongodbリンク可能状態による関連操作の処理 gjn end
      if (findResult != null) {
        for (Document document : findResult) {
          if (payload.get("column") != null) {
            Map<String, Object> map = new HashMap();
            ArrayList<String> colArr = (ArrayList) payload.get("column");
            colArr.forEach(everyCol -> {
              map.put(everyCol, document.get(everyCol));

            });
            list.add(map);
          } else {
            list.add(document);
          }
        }
      }
      return list;
    }
    catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      throw new RuntimeException(e);
    }
  }
  // add MongoDB共通インターフェース 関 end
  // mod FNSI-NO423入院患者名の配布 関 start
  public Map getPatSameAndInOutClass(Map<String, ?> payload) {
    Map<Long, Map<String, String>> patMessage = new HashMap<>();
    List<PatPersonalMain> patList = new ArrayList<PatPersonalMain>();
    List<PatMain> patMainList = new ArrayList<PatMain>();
    List<String> facilityCdList = (List<String>) payload.get("facilityCdList");
    patList = patPersonalMainDao.selectAllAndSetting(facilityCdList, 0);
    patMainList = patMainDao.selectByCdList(facilityCdList);
    patList.forEach(everyPat -> {
      if (patMessage.get(everyPat.getPat_id()) == null) {
        patMessage.put(everyPat.getPat_id(), new HashMap<>());
        if (everyPat.getIn_out_class() == null) {
          patMessage.get(everyPat.getPat_id()).put("in_out_class", "2");
        }
        else {
          patMessage.get(everyPat.getPat_id()).put("in_out_class", everyPat.getIn_out_class().toString());
        }
        patMessage.get(everyPat.getPat_id()).put("is_same", "0");
      }
      else {
        if (everyPat.getIn_out_class() == null) {
          patMessage.get(everyPat.getPat_id()).put("in_out_class", "2");
        }
        else {
          patMessage.get(everyPat.getPat_id()).put("in_out_class", everyPat.getIn_out_class().toString());
        }
      }
    });
    patMainList.forEach(everyPat -> {
      if (patMessage.get(everyPat.getPat_id()) == null) {
        patMessage.put(everyPat.getPat_id(), new HashMap<>());
        patMessage.get(everyPat.getPat_id()).put("in_out_class", "2");
        patMessage.get(everyPat.getPat_id()).put("is_same", everyPat.getIs_same());
      }
      else {
        patMessage.get(everyPat.getPat_id()).put("is_same", everyPat.getIs_same());
      }
    });
    return patMessage;
  }
  // mod FNSI-NO423入院患者名の配布 関 end

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
      if (obj instanceof String) {
        inStr.append(" '");
        inStr.append(obj);
        inStr.append("' ");
        inStr.append(" ,");
      } else {
        inStr.append(obj);
        inStr.append(" ,");
      }
    }
    inStr.deleteCharAt(inStr.length() - 1);
    inStr.append(" ) ");
    return String.valueOf(inStr);
  }
  // DB更新ログ出力ロジック wangzuo End

  //del #10412 次患者更新関連全体見直し対応 朴 start
//  //add FNSI-redmine4498 房 start
//  /*
//   * 身体情報更新
//   */
//  @Transactional
//  public void updatePhysicalInfoById(Long pat_id) throws Exception {
//    try {
//      PatMain pat = patMainDao.selectById(pat_id);
//      String facilityCd = pat.getFacility_cd();
//      comSvNotifySetNextPatInfo(facilityCd, pat_id);
//      return;
//      // add FNSI-排他処理 劉 start
//    } catch (OptimisticLockException e) {
//      throw e;
//      // add FNSI-排他処理 劉 end
//    } catch (RuntimeException e) {
//      throw new RuntimeException(e);
//    }
//  }
//  //add FNSI-redmine4498 房 end
  //del #10412 次患者更新関連全体見直し対応 朴 end

  /* add by chenshijie  2023-02-02 [CodeOptimization]  start */
  @Autowired
  LogEventUtils logEventUtils;
  public ResponseEntity<Map<String, Object>> updateInOutStateService(long pat_id, Map<String, String> payload, NtssUser ntssUser) {
    String mappingUrl = Uri.PAT_INFO + "/updateInOutState/{pat_id}";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id, payload, ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      Map<String, String> patInfo = selectById(pat_id, ntssUser.getFacilityCd());
      ObjectMapper mapper = new ObjectMapper();
      PatPersonalMain patPersonalMain = mapper.readValue(patInfo.get("pat_personal_main"), PatPersonalMain.class);
      String is_die = patPersonalMain.getIs_die();
      String facility_cd = payload.get("facility_cd");
      // DB入外区分取得
      Map<String, String> patInfoJson = null;
      patInfoJson = selectById(pat_id, ntssUser.getFacilityCd());
      PatPersonalMain initPatPersonalMain = mapper.readValue(patInfoJson.get("pat_personal_main"), PatPersonalMain.class);
      Integer initInOutClass = initPatPersonalMain.getIn_out_class();

      if ("1".equals(is_die)) {
        // 死亡フラグが立っている場合

        // 死亡コード
        Integer death_cd = 2;
        // 確定・予定転入出状態更新・入外区分更新
        // 確定・予定転入出状態死亡設定がないためnullへ・入外区分死亡へ
        updateInOut(pat_id, null, null, null, death_cd, payload);

        //del #10412 次患者更新関連全体見直し対応 朴 start
//        // modify by maxueqiang
//        if (null != initInOutClass) {
//          // 入外区分が変更された場合:次患者更新
//          comSvNotifySetNextPatInfo(facility_cd, pat_id);
//        }
//        //add FNSI-画面部品デザイン じょはく start
//        //mod No.20 じょはく start
//        updateInOut(pat_id, null, null, null, 2, payload);
//        //mod No.20 じょはく end
//        //add FNSI-画面部品デザイン じょはく end
        //del #10412 次患者更新関連全体見直し対応 朴 end

        Map<String, Object> in_out_info = setMoveInOutInfo(null, death_cd);
        // add FNSi5712アプリケーションログが出力しない 周 start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
          AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id, payload, ntssUser));
        // add FNSi5712アプリケーションログが出力しない 周 end
        return new ResponseEntity<>(in_out_info, HttpStatus.OK);
      }

      /* 転入・転出履歴取得 */
      //  mod FNSI- 徐博 start
      List<Map<String, Object>> inOut = selectInOut(pat_id, ntssUser.getFacilityCd());
      //  mod FNSI- 徐博 end
      if (inOut == null) {
        // 確定・予定転入出状態null更新・入外区分null更新
        // mod FNSI- 徐博 start
        // 本人情報の入外は不明の時、in_out_classは3(不明)に変わる
        // patInfoService.updateInOut(pat_id, null, null, null, null, payload);
        updateInOut(pat_id, null, null, null, 3, payload);

        //del #10412 次患者更新関連全体見直し対応 朴 start
//        // mod FNSI- 徐博 end
//        if (initInOutClass != null) {
//          // 入外区分が変更された場合:次患者更新
//          comSvNotifySetNextPatInfo(facility_cd, pat_id);
//        }
        //del #10412 次患者更新関連全体見直し対応 朴 end

        Map<String, Object> in_out_info = setMoveInOutInfo(null, null);
        // add FNSi5712アプリケーションログが出力しない 周 start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
          AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id, payload, ntssUser));
        // add FNSi5712アプリケーションログが出力しない 周 end
        return new ResponseEntity<>(in_out_info, HttpStatus.OK);
      }

      // 転入出履歴を1件ずつチェック
      int numberDate = Integer.parseInt(DateTimeFormatter.ofPattern("uuuuMMdd").format(LocalDateTime.now()));
      String targetDt = "";
      // 翌日処理する転入出情報("転出","離脱","移植","一時転出")
      List<String> lstMoveInOutNextDay = new ArrayList<String>();
      lstMoveInOutNextDay.add(InOutVisitHistoryInfoMoveInOut.MOVE_IN_OUT_CLASS_MOVING_OUT);
      lstMoveInOutNextDay.add(InOutVisitHistoryInfoMoveInOut.MOVE_IN_OUT_CLASS_WITHDRAWAL);
      lstMoveInOutNextDay.add(InOutVisitHistoryInfoMoveInOut.MOVE_IN_OUT_CLASS_IMPLANTATION);
      lstMoveInOutNextDay.add(InOutVisitHistoryInfoMoveInOut.MOVE_IN_OUT_CLASS_TEMPORARILY_MOVING_OUT);

      //add FNSI-「本人情報」の「入外区分」と「入外・転入出」の「区分」を一致させる 鄧シン start
      if (inOut.get(inOut.size() - 1).get("move_in_out") == null && initInOutClass != null){
        Integer inoutClass = null;
        if ("0".equals(initInOutClass.toString()) || "1".equals(initInOutClass.toString())){
          inoutClass = initInOutClass + 2;
          inOut.get(inOut.size() - 1).put("move_in_out", inoutClass.toString());
          updateInOut(pat_id, null, initInOutClass.toString(), null, null, payload);
        }
      } else if (inOut.get(inOut.size() - 1).get("move_in_out") != null && initInOutClass == null){
        if ("2".equals(inOut.get(inOut.size() - 1).get("move_in_out")) || "3".equals(inOut.get(inOut.size() - 1).get("move_in_out"))){
          initInOutClass = Integer.valueOf(inOut.get(inOut.size() - 1).get("move_in_out").toString());
          this.updateInOutClassById(pat_id, initInOutClass, payload);
        }
      }
      //add FNSI-「本人情報」の「入外区分」と「入外・転入出」の「区分」を一致させる 鄧シン end

      for (int i = 0; inOut.size() > i; i++) {
        if (inOut.get(i).get("move_in_out") == null || inOut.get(i).get("period_start") == null) {
          //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("区分または日付が入力されていません");
          logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
          //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
          Map<String, Object> in_out_info = setMoveInOutInfo(null, null);
          // add FNSi5712アプリケーションログが出力しない 周 start
          logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
            AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id, payload, ntssUser));
          // add FNSi5712アプリケーションログが出力しない 周 end
          return new ResponseEntity<>(in_out_info, HttpStatus.OK);
        }
        // 当日を含む直近過去日付を保持
        if (targetDt.equals("")) {
          int periodStart = Integer.parseInt(inOut.get(i).get("period_start").toString());
          String moveInOut = inOut.get(i).get("move_in_out").toString();
          // 当日以前の日付
          if (periodStart == numberDate && !lstMoveInOutNextDay.contains(moveInOut)) {
            // 当日分は"導入","転入","入院","退院","外来","通院拒否・不明"のみを処理
            targetDt = inOut.get(i).get("period_start").toString();
          } else if (periodStart < numberDate) {
            // 過去日の入外区分
            if (lstMoveInOutNextDay.contains(moveInOut)) {
              // "転出","離脱","移植","一時転出"は翌日処理なので１日加算
              targetDt = DateTimeFormatter.ofPattern("uuuuMMdd").format(LocalDate.parse(inOut.get(i).get("period_start").toString(), DateTimeFormatter.ofPattern("uuuuMMdd")).plusDays(1));
            } else {
              targetDt = inOut.get(i).get("period_start").toString();
            }
          }
        }
      }

      if (targetDt.equals("")) {
        // 未来日以降の入外情報のみ存在する場合
        if (inOut.size() > 0) {
          // 直近未来の入外情報取得
          String moveInOut = inOut.get(inOut.size() - 1).get("move_in_out").toString();
          String periodStart = inOut.get(inOut.size() - 1).get("period_start").toString();
          String inOutState = null;

          if (InOutVisitHistoryInfoMoveInOut.MOVE_IN_OUT_CLASS_INTRODUCTION.equals(moveInOut)) {
            // 導入 → 導入予定、予定在院状態：在院
            inOutState = PatInfoMoveInOut.MOVE_IN_OUT_INTRODUCTION_PLAN;
            moveInOut = PatInfoMoveInOut.MOVE_IN_OUT_HOSPITALIZATION;
          } else if (InOutVisitHistoryInfoMoveInOut.MOVE_IN_OUT_CLASS_MOVE_IN.equals(moveInOut)) {
            // 転入 → 転入予定、予定在院状態：在院
            inOutState = PatInfoMoveInOut.MOVE_IN_OUT_MOVE_IN_PLAN;
            moveInOut = PatInfoMoveInOut.MOVE_IN_OUT_HOSPITALIZATION;
          } else if (InOutVisitHistoryInfoMoveInOut.MOVE_IN_OUT_CLASS_MOVING_OUT.equals(moveInOut)) {
            // 転出 → 在院
            inOutState = PatInfoMoveInOut.MOVE_IN_OUT_HOSPITALIZATION;
          } else if (InOutVisitHistoryInfoMoveInOut.MOVE_IN_OUT_CLASS_HOSPITALIZATION.equals(moveInOut)
            || InOutVisitHistoryInfoMoveInOut.MOVE_IN_OUT_CLASS_DISCHARGE.equals(moveInOut)
            || InOutVisitHistoryInfoMoveInOut.MOVE_IN_OUT_CLASS_OUTPATIENT.equals(moveInOut)) {
            // 入院・退院・外来 → 予定在院状態：在院
            moveInOut = PatInfoMoveInOut.MOVE_IN_OUT_HOSPITALIZATION;
          } else if (InOutVisitHistoryInfoMoveInOut.MOVE_IN_OUT_CLASS_TEMPORARILY_MOVING_OUT.equals(moveInOut)) {
            // 一時転出 → 在院
            inOutState = PatInfoMoveInOut.MOVE_IN_OUT_HOSPITALIZATION;
          }

          // 確定・予定転入出状態更新・入外区分更新
          updateInOut(pat_id, inOutState, moveInOut, periodStart, null, payload);
        }
      } else {
        // 一部の当日分入外情報もしくは過去日の入外情報が存在する場合は、入外区分・在院状態更新APIをコール
        List<Long> patIdList = new ArrayList<Long>();
        patIdList.add(pat_id);
        // add 6625【ST試験】【S12_患者の既往・転入履歴】患者情報：患者状態が変更された場合、ページ頭部状態は変更されない zhou　start
        String patinOutClass = payload.get("in_out_class") ;
        // true の場合、入外区分再更新、画面の入外区分”-”以外⇒”-”の場合、入外区分”-”保存
        if ("true".equals(patinOutClass)){
          // add 6625【ST試験】【S12_患者の既往・転入履歴】患者情報：患者状態が変更された場合、ページ頭部状態は変更されない zhou　end
          ResponseEntity<String> ret = webApiCallCommonUtil.updatePatInOutInfo(targetDt, patIdList);
          // 失敗時
          if (ret.getStatusCode() != HttpStatus.OK) {
            // add FNSi5712アプリケーションログが出力しない 周 start
            logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
              AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id, payload, ntssUser));
            // add FNSi5712アプリケーションログが出力しない 周 end
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
          }
          // add 6625【ST試験】【S12_患者の既往・転入履歴】患者情報：患者状態が変更された場合、ページ頭部状態は変更されない zhou　start
        }
         // add 6625【ST試験】【S12_患者の既往・転入履歴】患者情報：患者状態が変更された場合、ページ頭部状態は変更されない zhou　end
      }

      // 更新処理実行後の確定・予定転入出状態取得
      Map<String, Object> updInOutInfoState = selectInOutState(facility_cd, pat_id);

      // 更新後の入外区分を取得
      patInfoJson = selectById(pat_id, ntssUser.getFacilityCd());
      PatPersonalMain updPatPersonalMain = mapper.readValue(patInfoJson.get("pat_personal_main"), PatPersonalMain.class);
      Integer updInOutClass = updPatPersonalMain.getIn_out_class();

      if (updInOutClass == null) {
        // 入外区分がnullの場合、過去の転入出履歴内に入外区分を設定した履歴が存在しないか確認
        // 直近過去日に区分："一時転出"の履歴のみ存在する場合は入外区分が正しく設定できないため、そこをフォローする
        for (int i = 0; inOut.size() > i; i++) {
          int periodStart = Integer.parseInt(inOut.get(i).get("period_start").toString());
          if (periodStart < numberDate) {
            if (inOut.get(i).get("in_out") != null) {
              // 入外区分が設定されている中で2番目に近い過去履歴の入外区分で更新をかける
              updInOutClass = Integer.parseInt(inOut.get(i).get("in_out").toString());
              updateInOutClassById(pat_id, updInOutClass, payload);
              break;
            }
          }
        }
      }

      //del #10412 次患者更新関連全体見直し対応 朴 start
//      // 入外区分変更時には次患者更新処理を呼び出し
//      if (updInOutClass == null) {
//        if (updInOutClass != initInOutClass) {
//          comSvNotifySetNextPatInfo(facility_cd, pat_id);
//        }
//      } else if (! updInOutClass.equals(initInOutClass)) {
//        comSvNotifySetNextPatInfo(facility_cd, pat_id);
//      }
      //del #10412 次患者更新関連全体見直し対応 朴 end

      Map<String, Object> in_out_info = setMoveInOutInfo(updInOutInfoState.get("in_out_current_state") == null ? null : updInOutInfoState.get("in_out_current_state").toString(), updInOutClass);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id, payload, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(in_out_info, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id, payload, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }

  }
  private String getClassName() {
    return this.getClass().getName();
  }
  private String getMethodName() {
    return Thread.currentThread().getStackTrace()[2].getMethodName();
  }
  private static Map<String, Object> setMoveInOutInfo(String in_out_current_state, Integer in_out) {
    Map<String, Object> in_out_info = new HashMap<String, Object>();

    in_out_info.put("in_out_current_state", in_out_current_state);
    in_out_info.put("in_out_class", in_out);

    return in_out_info;
  }
  /* add by chenshijie  2023-02-02 [CodeOptimization]  end */

  /* #10443 身体情報・DW・目標体重バグ対応 Add by 2024-05-07 START */

  /**
   * 患者の治療情報中の目標体重更新
   *
   * @param facilityCd  施設コード
   * @param patId       システムで管理する一意な患者ID
   * @param patPhysicalInfo 身体情報文字列
   * @param optUserCd
   * @param logDate
   */
	private List<OrdMainTreatDate> updateTargetWeightByPhysicalInfo(String facilityCd, Long patId, JsonNode patPhysicalInfo, Long optUserCd, String logDate) {
    List<OrdMainTreatDate> targetWeightEIList = null;

    if (patPhysicalInfo != null && !patPhysicalInfo.isNull()) {
      //mod #12096 データリストにてDWおよび目標体重を登録するとサーバダウン zrx start
//      String nowDateStr = DateTimeUtils.getSysDate();
      String nowDateStr = patPhysicalInfo.hasNonNull("indicator_start_date")
        ? patPhysicalInfo.get("indicator_start_date").asText() : DateTimeUtils.getSysDate();
      //mod #12096 データリストにてDWおよび目標体重を登録するとサーバダウン zrx end

      MstPersonalUser optUser = MasterCacheHandler.get().getMstPersonalUser(optUserCd);
      final MstPersonalUser optUserInfo = optUser == null ? new MstPersonalUser() : optUser;

      Long indicatorCd = patPhysicalInfo.hasNonNull("indicator_cd")
        ? patPhysicalInfo.get("indicator_cd").asLong() : null;
      MstPersonalUser indicatorUser = MasterCacheHandler.get().getMstPersonalUser(indicatorCd);
      final MstPersonalUser indicatorUserInfo = indicatorUser == null ? new MstPersonalUser() : indicatorUser;


      String targetWeight = patPhysicalInfo.hasNonNull("target_weight")
        ? patPhysicalInfo.get("target_weight").asText() : null;

      // get All ordMain's record, and then we'll found out which record going to be updated.
      //mod #12096 データリストにてDWおよび目標体重を登録するとサーバダウン zrx start
//      List<OrdMainForUpdTargetWeightDTO> omList =
//        this.patUniqueDao.selectOrdMainForUpdTargetWeight(facilityCd, patId, nowDateStr);
      List<OrdMainForUpdTargetWeightDTO> targetUpdList =
        this.patUniqueDao.selectOrdMainForUpdTargetWeight(facilityCd, patId, nowDateStr);

      String originalWeight = null;

      // found out which record going to be updated
//      if (CollectionUtils.isNotEmpty(omList)) {
      if (CollectionUtils.isNotEmpty(targetUpdList)) {
//        List<OrdMainForUpdTargetWeightDTO> targetUpdList = omList.stream()
//          .filter(r -> !org.apache.commons.lang3.StringUtils.equals(r.getOriginalWeight(), r.getTargetWeight()))
//          .peek(r -> {
//            if (Objects.isNull(r.getChangerCd())) r.setChangerCd(String.valueOf(optUserCd));
//          })
//          .toList();

        // if there are have records needs to be updated, means indApprove needs to be updated too.
        originalWeight = targetUpdList.get(targetUpdList.size() - 1).getOriginalWeight();
        if(indicatorCd != null) {
          MstPersonalUser indUser = mstPersonalUserDao.selectById(indicatorCd);
          MstPersonalUser updUser = mstPersonalUserDao.selectById(optUserCd);
          targetUpdList.forEach(r -> {
            r.setTargetWeight(targetWeight);
            r.setIndicatorCd(indicatorCd.toString());
            r.setChangerCd(optUserCd > 0L ? String.valueOf(optUserCd) : "0");
            r.setIndUserLastName(indUser != null ? indUser.getUserLastName() : null);
            r.setIndUserFirstName(indUser != null ? indUser.getUserFirstName() : null);
            r.setUpdUserLastName(updUser != null ? updUser.getUserLastName() : null);
            r.setUpdUserFirstName(updUser != null ? updUser.getUserFirstName() : null);
          });
        }
        // upd ordMain
        this.ordMainDao.updateTargetWeightByPhyInfo(targetUpdList);


        // upd patTreatmentPattern
//        this.patTreatmentPatternDao
//          .updateTargetWeightByPhyicalInfo(facilityCd
//            , patId
//            , targetUpdList.get(targetUpdList.size() - 1).getTargetWeight());
        this.patTreatmentPatternDao.updateTargetWeightByPhyicalInfo(facilityCd, patId, targetWeight);
        //mod #12096 データリストにてDWおよび目標体重を登録するとサーバダウン zrx end

        // upd patIndApprove
        this.patIndApproveDao.updateContentChangeList(
          targetUpdList.stream()
            .map(OrdMainForUpdTargetWeightDTO::getOrdNo)
            .toList()
          , BeanBuilderUtils
            .of(PatIndApprove::new)
            .with(PatIndApprove::setUpDate, Timestamp.from(Instant.now()))
            .build()
        );

        targetWeightEIList = new ArrayList<>(targetUpdList.size());
        for (OrdMainForUpdTargetWeightDTO ordMainForUpdTargetWeightDTO : targetUpdList) {
          OrdMainTreatDate targetWeightEI =  new OrdMainTreatDate();
          targetWeightEI.setOrdNo(ordMainForUpdTargetWeightDTO.getOrdNo());
          targetWeightEI.setTreatDate(ordMainForUpdTargetWeightDTO.getTreatDate());
          targetWeightEI.setIndKurCd(ordMainForUpdTargetWeightDTO.getIndKurCd().longValue());
          targetWeightEI.setIndTreatmentCd(ordMainForUpdTargetWeightDTO.getIndTreatmentCd().toString());
          targetWeightEIList.add(targetWeightEI);
        }

      }

      // insert ind_history
      this.indHistoryService.create(
        BeanBuilderUtils.of(IndHistory::new)
          .with(IndHistory::setFacilityCd, facilityCd)
          .with(IndHistory::setPatId, patId.toString())
          .with(IndHistory::setLogDate, logDate)
          .with(IndHistory::setTreatmentStartDate, patPhysicalInfo.get("indicator_start_date").asText())
          .with(IndHistory::setTreatmentMethod, "すべて")  // 治療方法名
          .with(IndHistory::setTreatmentCourse, "すべて")      // クール名
          .with(IndHistory::setTreatmentWeekday
            , "月, 火, 水, 木, 金, 土, 日")
          .with(IndHistory::setLogTarget, "目標体重")
          .with(IndHistory::setLogClass, "変更")
          .with(IndHistory::setSortNo, 100)
          .with(IndHistory::setLogContent
            , this.targetWeightContextTranslation(originalWeight, targetWeight))
          .with(IndHistory::setCreatedUserId, indicatorCd)
          .with(IndHistory::setUpdatedUserId, optUserCd)
          .with(IndHistory::setCreatedBy, indicatorUserInfo.getUserName())
          .with(IndHistory::setUpdatedBy, optUserInfo.getUserName())
          .build()
      );

    }
    return targetWeightEIList;
  }

  /**
   * DW変更影響の時間範囲確認
   *
   * @param editMode  変更パターン
   * @param modifiedRecCtlNo 変更レコードの管理番号
   * @param beforeModTimeLine 変更前の影響の時間範囲
   * @param afterModTimeLine  変更後の影響の時間範囲
   * @return  DW変更影響の時間範囲
   */
  private List<PatDWEffectsTimeLineDTO> findChangedInterval(
    String editMode,
    Integer modifiedRecCtlNo,
    List<PatDWEffectsTimeLineDTO> beforeModTimeLine,
    List<PatDWEffectsTimeLineDTO> afterModTimeLine

  ){
    // 差分が必要な場合：前後に時間区間が存在する
    if (CollectionUtils.isNotEmpty(beforeModTimeLine)
      && CollectionUtils.isNotEmpty(afterModTimeLine)) {

      // 変更パターン
      switch (editMode) {
        // 新規
        case "I" -> {
          return afterModTimeLine.stream()
                    .filter(r -> Objects.equals(r.getCtlNo(), modifiedRecCtlNo))
                    .toList();
        }
        // 削除
        case "D" -> {
          return beforeModTimeLine.stream()
                    .filter(r -> Objects.equals(r.getCtlNo(), modifiedRecCtlNo))
                    .toList();
        }
        // 更新
        case "U" -> {
          /* キューを利用して、ネストされたループを作り、区間の変化を比較します。各pollから1つの要素が出るたびに、異なる要素は変更点になります。
              baseと同じ場合：同じ要素は両方をスキップします。
              baseとは異なる：
                A、baseの次の要素がdiff要素と同じかどうかを探知する
                B、diffの次の要素がbaseと同じかどうかを探知する
                  Aが満足し、Bが満足しない場合、diff中のは挿入要素であること。diffを記録し、diffをスキップし、続行
                  Aが満たされず、Bが満たされていなければ、diff中は削除要素であること、baseを記録、baseをスキップ、続行
                  Aが満足し、Bが満足していれば、base、diff対調要素であること、両方を記録し、両方をスキップし、続行
              次がなければdiffを記録するだけです。 */
          // Base queue
          Queue<PatDWEffectsTimeLineDTO> baseQueue = new ArrayDeque<>(beforeModTimeLine);
          // Diff queue
          Queue<PatDWEffectsTimeLineDTO> diffQueue = new ArrayDeque<>(afterModTimeLine);

          // different elements
          List<PatDWEffectsTimeLineDTO> diffContainer = new ArrayList<>();

          if (!baseQueue.isEmpty()) {
            // 判断AとB
            boolean chargeACtg, chargeBCtg;

            while (!diffQueue.isEmpty()) {
              // Base要素が無しの場合、Diff要素を追加
              if (baseQueue.isEmpty()) {
                diffContainer.add(diffQueue.poll());
                continue;
              }
              // 今回Base要素
              PatDWEffectsTimeLineDTO baseElement = baseQueue.peek();
              // 今回Diff要素
              PatDWEffectsTimeLineDTO diffElement = diffQueue.peek();

              // 同じ要素は両方をスキップします
              // #9929 mod 身体情報でDWを登録しても連携イベントが発生しない 荘 2024-06-21 start
              // if (Objects.equals(baseElement.getCtlNo(), diffElement.getCtlNo())
              if (Objects.equals(baseElement.getCtlNo(), diffElement.getCtlNo())
              && Objects.equals(baseElement.getDw(), diffElement.getDw())
              && Objects.equals(baseElement.getStartDate(), diffElement.getStartDate())
              && Objects.equals(baseElement.getEndDate(), diffElement.getEndDate())) {
              // #9929 mod 身体情報でDWを登録しても連携イベントが発生しない 荘 2024-06-21 end
                baseQueue.poll();
                diffQueue.poll();
                continue;
              }

              // #9929 del 身体情報でDWを登録しても連携イベントが発生しない 荘 2024-06-21 start
//              // baseの次の要素 と diffの次の要素
//              Iterator<PatDWEffectsTimeLineDTO> baseIter = baseQueue.iterator();
//              Iterator<PatDWEffectsTimeLineDTO> diffIter = diffQueue.iterator();
//              baseIter.next();
//              diffIter.next();
//              if (baseIter.hasNext() && !diffIter.hasNext()) {
//                diffContainer.add(baseQueue.poll());
//                continue;
//              }else if (diffIter.hasNext() && !baseIter.hasNext()) {
//                diffContainer.add(diffQueue.poll());
//                continue;
//              }else if (!diffIter.hasNext() && !baseIter.hasNext()) {
//                diffContainer.add(diffQueue.poll());
//                diffContainer.add(baseQueue.poll());
//                break;
//              }
//              PatDWEffectsTimeLineDTO nextBaseElement = baseIter.next();
//              PatDWEffectsTimeLineDTO nextDiffElement = diffIter.next();
//
//              // 限界判断 - Base
//              if (Objects.isNull(nextBaseElement)) {
//                diffContainer.add(diffQueue.poll());
//                continue;
//              }
//              // 限界判断 - Diff
//              if (Objects.isNull(nextDiffElement)) {
//                diffContainer.add(baseQueue.poll());
//                continue;
//              }
//
//              // 判断A:baseの次の要素がdiff要素と同じかどうかを探知する
//              chargeACtg = Objects.equals(baseElement.getCtlNo(), diffElement.getCtlNo());
//              // 判断B:diffの次の要素がbaseと同じかどうかを探知する
//              chargeBCtg = Objects.equals(baseElement.getCtlNo(), nextDiffElement.getCtlNo());
//
//              // Aが満足し、Bが満足しない場合、diff中のは挿入要素であること。diffを記録し、diffをスキップし、続行
//              if (chargeACtg && !chargeBCtg) {
//                diffContainer.add(baseQueue.poll());
//                continue;
//              }
//
//              // Aが満たされず、Bが満たされていなければ、diff中は削除要素であること、baseを記録、baseをスキップ、続行
//              if (!chargeACtg && chargeBCtg) {
//                diffContainer.add(diffQueue.poll());
//                continue;
//              }
//
//              // Aが満足し、Bが満足していれば、base、diff対調要素であること、両方を記録し、両方をスキップし、続行
//              if (chargeACtg) {
//                diffContainer.add(baseQueue.poll());
//                diffContainer.add(diffQueue.poll());
//              }
//              // A、B同時に満足しないの場合、Baseに
              // #9929 del 身体情報でDWを登録しても連携イベントが発生しない 荘 2024-06-21 end

              // #9929 add 身体情報でDWを登録しても連携イベントが発生しない 荘 2024-06-21 start
              // 時間帯設定
              ZoneOffset offset = ZoneOffset.ofHours(9);

              // 時間変数声明
              OffsetDateTime baseStart;
              OffsetDateTime baseEnd;
              OffsetDateTime diffStart;
              OffsetDateTime diffEnd;

              // 今回Base開始時間と結束時間の取得
              if (baseElement.getStartDate().length() == 10) {
                baseStart = OffsetDateTime.parse(baseElement.getStartDate()+ "T00:00:00.000+09:00", DateTimeFormatter.ISO_OFFSET_DATE_TIME);
              } else {
                baseStart = OffsetDateTime.parse(baseElement.getStartDate(), DateTimeFormatter.ISO_OFFSET_DATE_TIME);
              }
              baseStart = baseStart.withOffsetSameLocal(offset);

              if (Objects.equals(baseElement.getEndDate(),null)){
                baseEnd = OffsetDateTime.parse("2099-12-31T00:00:00.000+09:00", DateTimeFormatter.ISO_OFFSET_DATE_TIME);
              } else if ( baseElement.getEndDate().length() == 10) {
                baseEnd = OffsetDateTime.parse(baseElement.getEndDate()+ "T00:00:00.000+09:00", DateTimeFormatter.ISO_OFFSET_DATE_TIME);
              } else {
                baseEnd = OffsetDateTime.parse(baseElement.getEndDate(), DateTimeFormatter.ISO_OFFSET_DATE_TIME);
              }
              baseEnd = baseEnd.withOffsetSameLocal(offset);

              // 今回diff開始時間と結束時間の取得
              if (diffElement.getStartDate().length() == 10) {
                diffStart = OffsetDateTime.parse(diffElement.getStartDate()+ "T00:00:00.000+09:00", DateTimeFormatter.ISO_OFFSET_DATE_TIME);
              } else {
                diffStart = OffsetDateTime.parse(diffElement.getStartDate(), DateTimeFormatter.ISO_OFFSET_DATE_TIME);
              }
              diffStart = diffStart.withOffsetSameLocal(offset);

              if (Objects.equals(diffElement.getEndDate(),null)) {
                diffEnd = OffsetDateTime.parse("2099-12-31T00:00:00.000+09:00", DateTimeFormatter.ISO_OFFSET_DATE_TIME);
              } else if ( diffElement.getEndDate().length() == 10) {
                diffEnd = OffsetDateTime.parse(diffElement.getEndDate()+ "T00:00:00.000+09:00", DateTimeFormatter.ISO_OFFSET_DATE_TIME);
              } else {
                diffEnd = OffsetDateTime.parse(diffElement.getEndDate(), DateTimeFormatter.ISO_OFFSET_DATE_TIME);
              }
              diffEnd = diffEnd.withOffsetSameLocal(offset);

              // CtlNo同じ、開始時間不同の場合
              if (!Objects.equals(baseElement.getStartDate(), diffElement.getStartDate())
                && Objects.equals(baseElement.getCtlNo(), diffElement.getCtlNo())) {
                // diff開始時間～base開始時間を記録する
                if (baseStart.isAfter(diffStart)) {
                  // 今回diffの取得
                  PatDWEffectsTimeLineDTO diffPat = diffQueue.poll();
                  // 結束時間が今回baseの開始時間の設定する
                  diffPat.setEndDate(baseElement.getStartDate());
                  diffContainer.add(diffPat);
                  // 今回baseを捨てる
                  baseQueue.poll();
                  continue;
                } else {
                  // 今回Baseの取得
                  PatDWEffectsTimeLineDTO basePat = baseQueue.poll();
                  // 結束時間が今回diffの開始時間の設定する
                  basePat.setEndDate(diffElement.getStartDate());
                  diffContainer.add(basePat);
                  // 今回diffを捨てる
                  diffQueue.poll();
                  continue;
                }
              }

              // 開始時間不同、結束時間不同の場合
              if (!Objects.equals(baseElement.getStartDate(), diffElement.getStartDate())
                && !Objects.equals(baseElement.getEndDate(), diffElement.getEndDate())) {
                // baseの開始時間とdiffの結束時間が同じの場合、diffを記録する
                if (Objects.equals(baseElement.getStartDate(), diffElement.getEndDate())) {
                  diffContainer.add(diffQueue.poll());
                  continue;
                }
                // diffの開始時間とbaseの結束時間が同じの場合、baseを記録する
                if (Objects.equals(baseElement.getEndDate(), diffElement.getStartDate())) {
                  diffContainer.add(baseQueue.poll());
                  continue;
                }
              }

              // 開始時間同じ、結束時間不同の場合
              if (Objects.equals(baseElement.getStartDate(), diffElement.getStartDate())
              && !Objects.equals(baseElement.getEndDate(), diffElement.getEndDate())) {
                // diffが大の場合
                if (diffEnd.isAfter(baseEnd)) {
                  baseQueue.poll();
                  PatDWEffectsTimeLineDTO basePat = baseQueue.poll();
                  // 次のbaseの結束時間はnullの場合、次のbaseの開始時間～今のdiffの結束時間を記録する
                  if (basePat.getEndDate() == null) {
                    basePat.setEndDate(diffElement.getEndDate());
                    diffContainer.add(basePat);
                    break;
                  } else {
                    // その他の場合、次のbaseを記録する
                    diffContainer.add(basePat);
                    diffQueue.poll();
                    continue;
                  }
                }
                // baseが大の場合
                if (baseEnd.isAfter(diffEnd)) {
                  diffQueue.poll();
                  PatDWEffectsTimeLineDTO diffPat = diffQueue.poll();
                  // 次のdiffの結束時間はnullの場合、次のdiffの開始時間～今のbaseの結束時間を記録する
                  if (diffPat.getEndDate() == null) {
                    diffPat.setEndDate(baseElement.getEndDate());
                    diffContainer.add(diffPat);
                    break;
                  } else {
                    // その他の場合、次のdiffを記録する
                    diffContainer.add(diffPat);
                    baseQueue.poll();
                    continue;
                  }
                }
              }

              // DW不同の場合、diffを記録する
              if (!Objects.equals(baseElement.getDw(), diffElement.getDw())) {
                baseQueue.poll();
                diffContainer.add(diffQueue.poll());
              }
              // #9929 add 身体情報でDWを登録しても連携イベントが発生しない 荘 2024-06-21 end
            }
          }
          else {
            diffContainer.addAll(afterModTimeLine);
          }
          //
          return diffContainer.stream().distinct().toList();
        }
        // TODO Unknown editMode
        default -> throw new IllegalStateException("Unexpected value: " + editMode);
      }

    }
    // 有から無へ、あるいは無から有への状態かもしれない。
    else {
      return CollectionUtils.isEmpty(beforeModTimeLine) ? afterModTimeLine : beforeModTimeLine;
    }
  }

  /**
   * DW変更影響の時間範囲中に指示受け承認情報更新
   *
   * @param facilityCd  施設コード
   * @param patId       システムで管理する一意な患者ID
   * @param effectsIntervalList DW変更影響の時間範囲確認
   */
  private List<OrdMainTreatDate> updDwIndApprove(
    String facilityCd, Long patId,
    List<PatDWEffectsTimeLineDTO> effectsIntervalList
  ) {
    if (CollectionUtils.isNotEmpty(effectsIntervalList)) {
      // DW変更で情報に変更の必要がない
      List<OrdMainTreatDate> effectsOrdNos = this.patUniqueDao.selectDwEffectsInterval(facilityCd, patId, effectsIntervalList);

      if (CollectionUtils.isNotEmpty(effectsOrdNos)) {
        // upd patIndApprove
        this.patIndApproveDao.updateContentChangeList(
          effectsOrdNos.stream().map(OrdMainTreatDate::getOrdNo).toList()
          , BeanBuilderUtils
            .of(PatIndApprove::new)
            .with(PatIndApprove::setUpDate, Timestamp.from(Instant.now()))
            .build()
        );
      }
      return effectsOrdNos;
    }

    return null;
  }

  private String targetWeightContextTranslation(String originalWeight, String targetWeight) {
    if (!StringUtils.hasText(originalWeight)) originalWeight = "未登録";
    if (!StringUtils.hasText(targetWeight)) targetWeight = "未登録";
    if ("-1".equals(originalWeight)) originalWeight = "DWと同じ";
    if ("-1".equals(targetWeight)) targetWeight = "DWと同じ";

    return originalWeight + " → " + targetWeight;
  }

  private String getTargetTreatmentName(String facilityCd, Integer treatmentCd) {

    List<MstTreatment> treatmentList = MasterCacheHandler.get().getMstTreatmentInfo(facilityCd);
    if (CollectionUtils.isEmpty(treatmentList)) treatmentList = List.of();

    return treatmentList
      .stream()
      .filter(r -> r.getTreatmentCd().equals(treatmentCd))
      .findFirst()
      .map(MstTreatment::getTreatmentName)
      .orElse(null);
  }


  private String getTragetKurName(String facilityCd, Integer kurCd) {
    List<MstKur> kurList = MasterCacheHandler.get().getMstKurInfo(facilityCd);
    if (CollectionUtils.isEmpty(kurList)) kurList = List.of();

    return kurList.stream()
      .filter(r -> r.getKurCd().equals(kurCd))
      .findFirst()
      .map(MstKur::getKurName)
      .orElse(null);
  }
  /* #10443 身体情報・DW・目標体重バグ対応 Add by 2024-05-07 START */

  // add 10626 データリストのCTR・DW一括登録修正 房 start

  /**
   * 連絡情報変化するかどうか
   * @param before
   * @param after
   * @param afterContactInfo
   * @return
   * @throws IOException
   */
  private boolean patInfoIsChange(PatPersonalMain before, PatPersonalMain after, Map<String, Object> afterContactInfo) throws IOException {
    boolean result = false;
    Map<String, Object> beforeContactInfo = null;
    if(before.getPat_contact_info() != null) {
      String contactInfo ="[" + before.getPat_contact_info() + "]";
      List<Map<String, Object>> contactInfoList = ObjectMapperUtil.readListOfMap(contactInfo);
      if(contactInfoList != null && contactInfoList.size() > 0) {
        beforeContactInfo = contactInfoList.get(0);
      }
    }
    if(beforeContactInfo == null && afterContactInfo != null) {
      result = true;
    } else if(beforeContactInfo != null && afterContactInfo == null) {
      result = true;
    }
    if(checkContactInfoElement(beforeContactInfo.get("fax"), afterContactInfo.get("fax"))){
      result = true;
    }
    if(checkContactInfoElement(beforeContactInfo.get("tel1"), afterContactInfo.get("tel1"))){
      result = true;
    }
    if(checkContactInfoElement(beforeContactInfo.get("tel2"), afterContactInfo.get("tel2"))){
      result = true;
    }
    if(checkContactInfoElement(beforeContactInfo.get("memo1"), afterContactInfo.get("memo1"))){
      result = true;
    }
    if(checkContactInfoElement(beforeContactInfo.get("memo2"), afterContactInfo.get("memo2"))){
      result = true;
    }
    if(checkContactInfoElement(beforeContactInfo.get("e_mail"), afterContactInfo.get("e_mail"))){
      result = true;
    }
    if(checkContactInfoElement(beforeContactInfo.get("zip_cd"), afterContactInfo.get("zip_cd"))){
      result = true;
    }
    if(checkContactInfoElement(beforeContactInfo.get("address"), afterContactInfo.get("address"))){
      result = true;
    }
    if(checkContactInfoElement(beforeContactInfo.get("work_tel"), afterContactInfo.get("work_tel"))){
      result = true;
    }
    if(checkContactInfoElement(beforeContactInfo.get("work_name"), afterContactInfo.get("work_name"))){
      result = true;
    }
    if(checkContactInfoElement(before.getPat_first_name(), after.getPat_first_name())){
      result = true;
    }
    if(checkContactInfoElement(before.getPat_last_name(), after.getPat_last_name())){
      result = true;
    }
    if(checkContactInfoElement(before.getPat_first_name_kana(), after.getPat_first_name_kana())){
      result = true;
    }
    if(checkContactInfoElement(before.getPat_last_name_kana(), after.getPat_last_name_kana())){
      result = true;
    }
    if(checkContactInfoElement(before.getDie_date(), after.getDie_date())){
      result = true;
    }
    if(checkContactInfoElement(before.getDie_cd(), after.getDie_cd())){
      result = true;
    }
    if(checkContactInfoElement(before.getPat_sex(), after.getPat_sex())){
      result = true;
    }
    if(checkContactInfoElement(before.getPat_blood_type_abo(), after.getPat_blood_type_abo())){
      result = true;
    }
    if(checkContactInfoElement(before.getPat_blood_type_rh(), after.getPat_blood_type_rh())){
      result = true;
    }
    if(checkContactInfoElement(before.getPat_blood_type_serovar(), after.getPat_blood_type_serovar())){
      result = true;
    }
    if(checkContactInfoElement(before.getIn_out_class(), after.getIn_out_class())){
      result = true;
    }
    if(checkContactInfoElement(before.getSeverity_cd(), after.getSeverity_cd())){
      result = true;
    }
    if(checkContactInfoElement(before.getTransport_cd(), after.getTransport_cd())){
      result = true;
    }
    return result;
  }

  private boolean checkContactInfoElement(Object before, Object after) {
    if(before == null || "".equals(before)) {
      if(after != null && !"".equals(after)) {
        return true;
      }
    }
    if(after == null || "".equals(after)) {
      if(before != null && !"".equals(before)) {
        return true;
      }
    }
    if(before != null && after != null) {
      return !before.toString().equals(after.toString());
    }
    return false;
  }
  // add 10626 データリストのCTR・DW一括登録修正 房 end
  // add 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 start
  // 簡易詳細条件フィルタリングによる条件に合った治療
  public List<OrdMainKurBed> getDetailedSimpleConditionFilterOrdMain(DetailedSearchRequest searchConditions, List<Long> patIdList, String facilityCd) {

    OrdScheduleDetailedConditions osConditions = searchConditions.getOrd_schedule();
    OrdMainDetailedConditions omConditions = searchConditions.getOrd_main();

    List<Long> ordNoList = new ArrayList<>();
    List<String> facilityCdList = new ArrayList<>();
    facilityCdList.add(facilityCd);
    List<OrdMainKurBed> OrdMainKurBedList = new ArrayList<>();
    if (osConditions != null) {
      // ベッドグループコードからベッドコードリスト取得
      List<Long> bedCdList = new ArrayList<>();
      List<Integer> bedGroupCdList = osConditions.getBedGroupCdList();
      if (bedGroupCdList != null && !bedGroupCdList.isEmpty()) {
        List<MstRoomBedGroup> mrbgList = mstRoomBedGroupDao.selectByListBedGroupCd(bedGroupCdList, facilityCd);
        if (mrbgList.isEmpty()) {
          // ベッドグループがマスタから削除されている場合は取得結果が空になるため全ベッドでの検索とする
          osConditions.setBedGroupCdList(null);
        } else {
          // ベッドコードリスト取得
          ObjectMapper mapper = new ObjectMapper();
          for (MstRoomBedGroup mrbg : mrbgList) {
            if (StringUtils.hasText(mrbg.getBedList())) {
              try {
                bedCdList.addAll(mapper.readValue(mrbg.getBedList(), new TypeReference<List<Long>>(){}));
              } catch (tools.jackson.core.JacksonException e) {
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
      }
      osConditions.setBedCdList(bedCdList);

      List<Long> simpleSearchBedCdList = new ArrayList<>();
      if (null != osConditions.getSimpleSearchBedGroupCd()) {
        ObjectMapper mapper = new ObjectMapper();
        MstRoomBedGroup mrbg = mstRoomBedGroupDao.selectByRoomBedGroupCd(osConditions.getSimpleSearchBedGroupCd());
        if (null != mrbg && StringUtils.hasText(mrbg.getBedList())){
          try {
            simpleSearchBedCdList.addAll(mapper.readValue(mrbg.getBedList(), new TypeReference<List<Long>>(){}));
          } catch (tools.jackson.core.JacksonException e) {
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

      osConditions.setSimpleSearchBedCdList(simpleSearchBedCdList);

      // ord_schedule検索
      List<OrdSchedule> ordScheduleList = ordScheduleDao.selectByDetailedSearchCondition(osConditions, patIdList, facilityCdList);
      if (ordScheduleList.size() == 0) {
        return new ArrayList<OrdMainKurBed>();
      }
      if (ordScheduleList.size() > 0) {
        patIdList = ordScheduleList.stream().map(ord -> ord.getPatId()).distinct().collect(Collectors.toList());
        ordNoList = ordScheduleList.stream().map(ord -> ord.getOrdNo()).distinct().collect(Collectors.toList());
      }
    }
    if (omConditions!= null) {
      boolean flg = false;
      // ord_main検索
      if(omConditions.getDialysisConditionRangeValueList() != null && omConditions.getDialysisConditionRangeValueList().size() > 0) {
        for (int idx = 0; idx < omConditions.getDialysisConditionRangeValueList().size(); idx++) {
          if ("3".equals(omConditions.getConditionId(idx))) {
            flg = true;
            break;
          }
        }
      }
      String rstDialysisStateFlag = "";
      if (omConditions.getSimpleSearchRstDialysisState() != null) {
        if(null != omConditions.getSimpleSearchRstDialysisState()){
          if(omConditions.getSimpleSearchRstDialysisState().size() == 1){
            if(omConditions.getSimpleSearchRstDialysisState().get(0) == 2){
              rstDialysisStateFlag  = "1";
            }else{
              rstDialysisStateFlag  = "2";
            }
          }
        }
      }
      List<OrdMain> ordMainList = ordMainDao.selectByDetailedSearchConditionadd(omConditions, facilityCdList, rstDialysisStateFlag, patIdList);
      if (ordMainList.size() == 0) {
        return new ArrayList<OrdMainKurBed>();
      }
      if (ordMainList.size() > 0) {
        ordMainList = getOrdMainList(ordMainList, ordNoList);
        if (ordMainList.size() > 0) {
          patIdList = ordMainList.stream().map(ord -> ord.getPatId()).distinct().collect(Collectors.toList());
          ordNoList = ordMainList.stream().map(ord -> ord.getOrdNo()).distinct().collect(Collectors.toList());
        }else{
          patIdList = new ArrayList<>();
          ordNoList = new ArrayList<>();
        }
      }else{
        patIdList = new ArrayList<>();
        ordNoList = new ArrayList<>();
      }
      // DW 検索
      boolean dwSearchFlag = false;
      if(omConditions.getDialysisConditionRangeValueList() != null && omConditions.getDialysisConditionRangeValueList().size() > 0) {
        for (int idx = 0; idx < omConditions.getDialysisConditionRangeValueList().size(); idx++) {
          if ("39".equals(omConditions.getConditionId(idx))) {
            dwSearchFlag = true;
            break;
          }
        }
        if (dwSearchFlag) {
          List<OrdMain> patUniqueList = patUniqueDao.selectByDwSearchCondition(omConditions, facilityCdList, patIdList);
          if (patUniqueList.size() == 0) {
            return new ArrayList<OrdMainKurBed>();
          }
          if (patUniqueList.size() > 0) {
            patUniqueList = getOrdMainList(patUniqueList, ordNoList);
            if (ordMainList.size() > 0) {
              patIdList = patUniqueList.stream().map(ord -> ord.getPatId()).distinct().collect(Collectors.toList());
              ordNoList = patUniqueList.stream().map(ord -> ord.getOrdNo()).distinct().collect(Collectors.toList());
            }else{
              patIdList = new ArrayList<>();
              ordNoList = new ArrayList<>();
            }
          }else{
            patIdList = new ArrayList<>();
            ordNoList = new ArrayList<>();
          }
        }
      }
      // 目標体重検索
      if(flg){
        List<OrdMain> patUniqueList = ordMainDao.selectByDetailedSearchCondition(omConditions, facilityCdList, patIdList);
        if (patUniqueList.size() == 0) {
          // 検索結果0件なら空の患者リストを返す
          return new ArrayList<OrdMainKurBed>();
        }
        if (patUniqueList.size() > 0) {
          patUniqueList = getOrdMainList(patUniqueList, ordNoList);
          if (ordMainList.size() > 0) {
            patIdList = patUniqueList.stream().map(ord -> ord.getPatId()).distinct().collect(Collectors.toList());
            ordNoList = patUniqueList.stream().map(ord -> ord.getOrdNo()).distinct().collect(Collectors.toList());
          }else{
            patIdList = new ArrayList<>();
            ordNoList = new ArrayList<>();
          }
        }else{
          patIdList = new ArrayList<>();
          ordNoList = new ArrayList<>();
        }
      }
    }
    if (ordNoList.size() > 0) {
      for(List<Long> subList : Lists.partition(ordNoList, 5000)) {
        OrdMainKurBedList.addAll(ordMainDao.selectByPatIdListWithBedAndKur(subList, facilityCd));
      }
    }
    return OrdMainKurBedList;
  }
  public List<OrdMain> getOrdMainList(List<OrdMain> ordMainList, List<Long> ordNoList) {
    Set<Long> ordNoSet = new HashSet<>(ordNoList);
    List<OrdMain> filteredList = new ArrayList<>();
    if (ordNoList.size() > 0) {
      for (OrdMain ord : ordMainList) {
        if (ordNoSet.contains(ord.getOrdNo())) {
          filteredList.add(ord);
        }
      }
      return filteredList;
    }else {
      return ordMainList;
    }
  }
  // add 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 end

  /* add by chamaojia 2026-03-27 [12462] 患者情報共有->患者経過総合ビューア --start */
  /**
   * 患者に関連する禁忌情報を取得する
   * @param facilityCd  施設コード
   * @param patId  患者ID
   * @return
   */
  public List<PatTabooAllergyRes> selectPatTabooAllergyByPatId(String facilityCd, Long patId)
          throws JacksonException {

    // 患者（共有含む）情報を取得
    List<PatMain> patMains = patMainDao.selectSharePatByPatId(facilityCd, patId);

    // ObjectMapperはコストが高いため使い回し
    ObjectMapper mapper = new ObjectMapper();

    // 結果格納用リスト
    List<PatTabooAllergyRes> resultList = new ArrayList<>();

    // マスタ検索用（重複排除のためSet使用）
    Set<String> tabooAllergyCdSet = new HashSet<>();

    // JSONパース結果キャッシュ（同一データの再パース防止）
    Map<PatMain, List<PatInfoTabooAllergy>> parsedMap = new HashMap<>();

    // ===== 1回目ループ：JSON解析 + CD収集 + category=0以外を処理 =====
    for (PatMain patMain : patMains) {

      // 患者の禁忌・アレルギー情報(JSON)をパース
      List<PatInfoTabooAllergy> infos =
              mapper.readValue(patMain.getTaboo_allergy_info(), new TypeReference<>() {});

      // パース結果をキャッシュ
      parsedMap.put(patMain, infos);

      for (PatInfoTabooAllergy info : infos) {
        String categoryClass = info.getCategory_class();

        // category=0 は後続処理用にCDのみ収集
        if ("0".equals(categoryClass)) {
          tabooAllergyCdSet.add(info.getTaboo_allergy_cd());
          continue;
        }

        // category=1-4 はその場で結果生成
        resultList.add(buildRes(
                patMain.getPat_id(),
                categoryClass,
                info.getTaboo_allergy_cd(),
                info.getTaboo_allergy_class()
        ));
      }
    }

    // ===== マスタ情報取得 =====
    // 収集したCDを元に禁忌・アレルギーマスタを取得し、Map化
    Map<String, MstTabooAllergy> tabooAllergyMap =
            mstTabooAllergyDao.getMstTabooAllergyInfoByCds(new ArrayList<>(tabooAllergyCdSet))
                    .stream()
                    .collect(Collectors.toMap(
                            MstTabooAllergy::getTabooAllergyCd,
                            Function.identity(),
                            (a, b) -> a // 重複キー対策（先勝ち）
                    ));

    // ===== 2回目ループ：category=0 の詳細展開 =====
    for (PatMain patMain : patMains) {

      // キャッシュから取得（再パースしない）
      List<PatInfoTabooAllergy> infos = parsedMap.get(patMain);

      for (PatInfoTabooAllergy info : infos) {

        // category=0 のみ対象
        if (!"0".equals(info.getCategory_class())) continue;

        // マスタから該当情報取得
        MstTabooAllergy mst = tabooAllergyMap.get(info.getTaboo_allergy_cd());
        if (mst == null) continue;

        // マスタの詳細情報(JSON)をパース
        List<MstTabooAllergyDetailInfo> details =
                mapper.readValue(mst.getDetailInfo(), new TypeReference<>() {});

        // 詳細ごとに結果生成
        for (MstTabooAllergyDetailInfo d : details) {
          resultList.add(buildRes(
                  patMain.getPat_id(),
                  d.getClassCd(),
                  d.getCd(),
                  info.getTaboo_allergy_class()
          ));
        }
      }
    }

    // 重複データを除去し、taboo / allergy を OR 条件でマージする
    Map<String, PatTabooAllergyRes> mergedMap = resultList.stream()
            .collect(Collectors.toMap(
                    // キー：patId + classType + cd で一意化
                    res -> res.getPatId() + "_" + res.getClassType() + "_" + res.getCd(),

                    // 値：そのまま
                    Function.identity(),

                    // 重複時のマージ処理
                    (existing, incoming) -> {
                      // taboo：どちらか true なら true
                      existing.setTaboo(existing.isTaboo() || incoming.isTaboo());

                      // allergy：どちらか true なら true
                      existing.setAllergy(existing.isAllergy() || incoming.isAllergy());

                      return existing;
                    }
            ));

    resultList = new ArrayList<>(mergedMap.values());

    return resultList;
  }

  /**
   * レスポンス生成共通処理
   *
   * @param patId 患者ID
   * @param classType 区分（カテゴリ）
   * @param cd コード
   * @param tabooClass 禁忌区分（"1": 禁忌）
   * @return PatTabooAllergyRes
   */
  private PatTabooAllergyRes buildRes(Long patId, String classType, String cd, String tabooClass) {

    PatTabooAllergyRes res = new PatTabooAllergyRes();

    res.setPatId(patId);
    res.setClassType(classType);
    res.setCd(cd);

    // 禁忌フラグ判定
    boolean isTaboo = "1".equals(tabooClass);

    res.setTaboo(isTaboo);
    res.setAllergy(!isTaboo);

    return res;
  }
  /* add by chamaojia 2026-03-27 [12462] 患者情報共有->患者経過総合ビューア --end */

  /**
   * 対象車いす割当済みの患者IDリストを取得
   *
   * @param facilityCd  施設コード
   * @param wheelChairCd  車いすコード
   * @return 患者IDリスト
   */
  public List<Long> getWheelChairAssigningPatIdList(String facilityCd, Long wheelChairCd) {
    return patMainDao.selectPadIdListByWheelChairCd(facilityCd, wheelChairCd);
  }

  //add #12462 患者情報共有 zrx start
  /**
   * 現在の施しidは過去の施し情報を取得する
   *
   * @param pat_id 現在の施しid
   * @return
   * @throws Exception
   */
  public List<PatHistoryInfo> getPatHospitalById(Long pat_id,String facilityCd) throws Exception {
    List<PatNameIdentification> listPatIdSrcFromPatDst = patNameIdentificationDao.getListPatIdSrcFromPatTo(pat_id);

    List<PatHistoryInfo> resultList = new ArrayList<>();

    if (null == listPatIdSrcFromPatDst || listPatIdSrcFromPatDst.size() == 0) {
      return resultList;
    }

    List<String> list = new ArrayList<>();

    String patIdName = patUniqueDao.selectFacilityCdById(pat_id);
    if (!StringUtil.isBlank(patIdName)) {
      list.add(patIdName);
    }

    List<String> FacilityCdSrcList = listPatIdSrcFromPatDst.stream().map(PatNameIdentification::getFacilityCdSrc).toList();
    list.addAll(FacilityCdSrcList);
    List<String> finalList = list.stream()
      .filter(cd ->
        !cd.equals(facilityCd))
      .toList();
    if (finalList.isEmpty()) {
      return resultList;
    }
    List<PatHistoryInfo> hospitalByIdList = patNameIdentificationDao.getHospitalByIdList(finalList);
    resultList.addAll(hospitalByIdList);
    return resultList;
  }

  /**
   * add 患者共有機能
   * add 患者と開示元患者両方の情報を取得する
   *
   * @param pat_id 患者ID
   * @return
   * @throws Exception
   */
  public Map<String, String> selectPatSharingById(Long pat_id, String facilityCd) throws Exception {
    // 各レコードのJSONを対応するクラスにマッピング
    ObjectMapper mapper = new ObjectMapper();

    if (pat_id == null || facilityCd == null) {
      return null;
    }

    Long patIdSrc = pat_id;

    String pat_id_name = patUniqueDao.selectFacilityCdById(pat_id);

    if (!facilityCd.equals(pat_id_name)) {

      List<PatNameIdentification> listPatIdSrcFromPatDstAndId = patNameIdentificationDao.getListPatIdSrcFromPatDstAndId(pat_id, facilityCd);
      patIdSrc = listPatIdSrcFromPatDstAndId.stream().findFirst().orElse(new PatNameIdentification()).getPatIdSrc();
    }

    // 対象のpat_personal_mainレコード(1人)を取得
    List<Long> patIdList = new ArrayList<Long>();

    if (null == patIdSrc) {
      return null;
    }

    Long pat_id_temp = patIdSrc;

    patIdList.add(patIdSrc);

    List<PatPersonalMain> listPatPersonalMain = patPersonalMainDao.selectByIdList(Arrays.asList(pat_id, patIdSrc));
    if (listPatPersonalMain == null || listPatPersonalMain.isEmpty()) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(
        "患者情報API：selectById() 指定されたpat_idのpat_personal_mainレコードが存在しません。(pat_id: " + pat_id + ")");
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI,
        "patPersonalMainDao/selectByIdList");
      return null;
    }

    // 現在選択した患者
    PatPersonalMain patPersonalMain = listPatPersonalMain.stream()
      .filter(item -> item.getPat_id().equals(pat_id_temp))
      .findFirst().orElse(new PatPersonalMain());

    JSONArray dialDiffComInfoArray = this.getJSONArray(patPersonalMain.getDial_diff_com_info());
    for (int i = 0; i < dialDiffComInfoArray.length(); i++) {
      JSONObject jsonObject = dialDiffComInfoArray.getJSONObject(i);
      if (jsonObject.has("dial_diff_cd") && !jsonObject.isNull("dial_diff_cd")) {
        Object cd = jsonObject.get("dial_diff_cd");
        Integer cd_int = (Integer) cd;
        MstDialysisDifficulty mstDialysisDifficulty = mstDialysisDifficultyDao.selectByCd(cd_int);
        if (null == mstDialysisDifficulty || !mstDialysisDifficulty.getFacilityCd().equals(facilityCd)) {
          continue;
        }
        String fnDialysisDifficultyCd = mstDialysisDifficulty.getFnDialysisDifficultyCd();
        String dialysisDifficultyName = mstDialysisDifficulty.getDialysisDifficultyName();
        jsonObject.put("dialysis_difficulty_name", dialysisDifficultyName);

        if (!StringUtil.isBlank(fnDialysisDifficultyCd)) {
          Integer i1 = Integer.valueOf(fnDialysisDifficultyCd);
          jsonObject.put("fn_dial_diff_cd", i1);
        }
      }
    }
    patPersonalMain.setDial_diff_com_info(dialDiffComInfoArray.toString());

    PatPersonalMain patPersonalMainTitle = listPatPersonalMain.stream()
      .filter(item -> item.getPat_id().equals(pat_id))
      .findFirst().orElse(new PatPersonalMain());

    PatPersonalMain patPersonalMainFac = listPatPersonalMain.stream()
      .filter(item -> item.getFacility_cd().equals(facilityCd))
      .findFirst().orElse(new PatPersonalMain());
    if(patPersonalMainFac != null) {
      patPersonalMain.setPrimary_disease_cd(patPersonalMainFac.getPrimary_disease_cd());
    }

    // 対象のpat_mainレコード(1人)を取得
    List<PatMain> listPatMain = patMainDao.selectByIdList(Arrays.asList(pat_id, patIdSrc));
    if (listPatMain == null || listPatMain.isEmpty()) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage
        .setLogMessage("患者情報API：selectById() 指定されたpat_idのpat_mainレコードが存在しません。(pat_id: " + pat_id + ")");
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, "patMainDao/selectByIdList");
      return null;
    }
    // 現在選択した患者
    PatMain patMain = listPatMain.stream()
      .filter(item -> item.getPat_id().equals(pat_id_temp))
      .findFirst().get();

    PatMain patMainTitle = listPatMain.stream()
      .filter(item -> item.getPat_id().equals(pat_id))
      .findFirst().orElse(new PatMain());

    PatMain patMainFac = listPatMain.stream()
      .filter(item -> item.getFacility_cd().equals(facilityCd))
      .findFirst().get();
    if(patMainFac != null) {
      patMain.setIs_diabetes(patMainFac.getIs_diabetes());
      patMain.setIs_blood_suger_exam(patMainFac.getIs_blood_suger_exam());
    }

    //過去の病院記録を調べる
    List<Long> listPatIdSrcFromListPatDst = patNameIdentificationDao.getListPatIdSrcFromListPatTo(patIdList);
    listPatIdSrcFromListPatDst.addAll(patIdList);
    // 対象のpat_uniqueレコード(1人)を取得
    List<PatUnique> listPatUnique = patUniqueDao.selectByIdList(listPatIdSrcFromListPatDst);
    if (listPatUnique.size() == 0) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage
        .setLogMessage("患者情報API：selectById() 指定されたpat_idのpat_uniqueレコードが存在しません。(pat_id: " + pat_id + ")");
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, "patUniqueDao/selectByIdList");
      return null;
    }

    // 組み込み構築
    List<String> list = listPatUnique.stream().map(PatUnique::getFacility_cd).toList();
    List<String> jsonFacilityCd = getJsonFacilityCd(listPatUnique);
    List<SysFacility> sysFacilityByCdList = sysFacilityDao.getSysFacilityByCdList(jsonFacilityCd);

    // 施しname取得
    List<PatHistoryInfo> hospitalByIdList = patNameIdentificationDao.getHospitalByIdList(list);
    Map<String, String> hospitalMap = hospitalByIdList.stream().collect(Collectors.toMap(PatHistoryInfo::getFacilityCd, PatHistoryInfo::getFacilityName));
    Map<String, String> collect = sysFacilityByCdList.stream().collect(Collectors.toMap(SysFacility::getMedicalInstitutionCd, SysFacility::getFacilityName));
    hospitalMap.putAll(collect);

    // 医師取得
    List<PatDoctorInfo> patDoctorByFacilityCdList = mstPersonalUserDao.getPatDoctorByFacilityCdList(list);
    Map<Integer, String> doctorMap = patDoctorByFacilityCdList.stream().collect(Collectors.toMap(PatDoctorInfo::getUserId, x -> x.getUserLastName().trim() + x.getUserFirstName().trim()));

    // 課取得
    List<PatCourseInfo> courseByFacilityCdList = mstCourseDao.getCourseByFacilityCdList(list);
    Map<Integer, String> courseMap = courseByFacilityCdList.stream().collect(Collectors.toMap(PatCourseInfo::getCourseCd, PatCourseInfo::getCourseName));

    // 現在選択した患者
    PatUnique patUnique = listPatUnique.stream()
      .filter(item -> item.getFacility_cd().equals(facilityCd))
      .findFirst().orElse(new PatUnique());

    //Medical_hst_info代入facility_cd
    patUnique.setMedical_hst_info(editPastDataWithReadOnly(patUnique.getMedical_hst_info(), patUnique.getFacility_cd(), hospitalMap, doctorMap, courseMap));
    //In_out_visit_history_info代入facility_cd
    patUnique.setIn_out_visit_history_info(editPastDataWithReadOnly(patUnique.getIn_out_visit_history_info(), patUnique.getFacility_cd(), hospitalMap, doctorMap, courseMap));
    //Physical_info代入facility_cd
    patUnique.setPhysical_info(editPastDataWithReadOnly(patUnique.getPhysical_info(), patUnique.getFacility_cd(), hospitalMap, doctorMap, courseMap));

    // # 9482 病名検索を追加し、対応病名を既往歴のJSONに一時的に追加
    if (StringUtils.hasText(patUnique.getMedical_hst_info()))
      patUnique.setMedical_hst_info(addDiseaseName(patUnique.getMedical_hst_info()));

    // add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 start
    // 対象のpat_insuranceレコード(1人)を取得
    List<PatInsurance> listPatInsurance = patInsuranceDao.getListPatInsuranceById(pat_id_temp);
    PatInsurance patInsurance = new PatInsurance();
    if (listPatInsurance.size() != 0) {
      // 現在選択した患者
      patInsurance = listPatInsurance.stream()
        .filter(item -> item.getPat_id().equals(pat_id_temp))
        .findFirst().get();
      // 開示した元患者
      List<PatInsurance> patInsuranceSrc = listPatInsurance.stream()
        .filter(item -> !item.getPat_id().equals(pat_id_temp))
        .collect(Collectors.toList());

      for (PatInsurance patISrc : patInsuranceSrc) {
        //insu_info
        patInsurance.setInsu_info(addPastDataWithReadOnly(patInsurance.getInsu_info(), patISrc.getInsu_info()));
        //insu_pub_info
        patInsurance.setInsu_pub_info(addPastDataWithReadOnly(patInsurance.getInsu_pub_info(), patISrc.getInsu_pub_info()));
        //insu_set_info
        patInsurance.setInsu_set_info(addPastDataWithReadOnly(patInsurance.getInsu_set_info(), patISrc.getInsu_set_info()));
        //insu_self_info
        patInsurance.setInsu_self_info(addPastDataWithReadOnly(patInsurance.getInsu_self_info(), patISrc.getInsu_self_info()));
      }
    }
    // add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 end
    // 各テーブルのレコードオブジェクトをシリアライズし、テーブル名をキーとする連想配列にマッピング
    List<PatGroupCustom> patGroupList = patGroupDetailDao.selectPatGroupByPatId(pat_id_temp);

    Map<String, Object> patGroupInfor = new HashMap<>();
    patGroupInfor.put("pat_group_list", mapper.writeValueAsString(patGroupList));

    patPersonalMain.setPat_id(pat_id);
    patMain.setPat_id(pat_id);
    patUnique.setPat_id(pat_id);
    patInsurance.setPat_id(pat_id);

    Map<String, String> payload = new HashMap<>();
    payload.put("pat_personal_main", mapper.writeValueAsString(patPersonalMain));
    payload.put("pat_personal_main_title", mapper.writeValueAsString(patPersonalMainTitle));
    payload.put("pat_main", mapper.writeValueAsString(patMain));
    payload.put("pat_main_title", mapper.writeValueAsString(patMainTitle));
    payload.put("pat_unique", mapper.writeValueAsString(patUnique));
    payload.put("pat_insurance_info", mapper.writeValueAsString(patInsurance));
    payload.put("pat_group_info", mapper.writeValueAsString(patGroupInfor));
    return payload;
  }

  /**
   * jsonにおける施しデータの取得
   *
   * @param listPatUnique json情報ソース
   * @return
   */
  private List<String> getJsonFacilityCd(List<PatUnique> listPatUnique) {
    List<String> list = new ArrayList<>();
    for (PatUnique patUnique : listPatUnique) {
      String medicalHstInfo = patUnique.getMedical_hst_info();
      String inOutVisitHistoryInfo = patUnique.getIn_out_visit_history_info();
      JSONArray medicalArray = new JSONArray(medicalHstInfo);
      JSONArray inOutArray = new JSONArray(inOutVisitHistoryInfo);
      for (int i = 0; i < medicalArray.length(); i++) {
        JSONObject jsonObject = medicalArray.getJSONObject(i);
        if (jsonObject.has("diagnosis_facility_cd") && !jsonObject.isNull("diagnosis_facility_cd")) {
          list.add(jsonObject.getString("diagnosis_facility_cd"));
        }
      }
      for (int i = 0; i < inOutArray.length(); i++) {
        JSONObject jsonObject = inOutArray.getJSONObject(i);
        if (jsonObject.has("to_facility") && !jsonObject.isNull("to_facility")) {
          list.add(jsonObject.getString("to_facility"));
        }
        if (jsonObject.has("from_facility") && !jsonObject.isNull("from_facility")) {
          list.add(jsonObject.getString("from_facility"));
        }
      }
    }
    return list;
  }

  /**
   * add 編集不可キー(read only)を紐づける開示した元データを現在データにいれる
   *
   * @param currentDataStr 現在データ
   * @param pastDataStr    開示した元データ
   * @param facilityCd     コード
   * @return
   */
  private String addPastDataWithReadOnly(String currentDataStr, String pastDataStr, String facilityCd, Map<String, String> hospitalMap, Map<Integer, String> doctorMap, Map<Integer, String> courseMap) {
    JSONArray pastDateJson = new JSONArray(pastDataStr);
    JSONArray currenDataJson = new JSONArray(currentDataStr);
    for (int i = 0; i < pastDateJson.length(); i++) {
      //編集不可キーを追加
      JSONObject jsonObj = pastDateJson.getJSONObject(i);
      jsonObj.put("facility_name", hospitalMap.get(facilityCd));
      if (jsonObj.has("course_cd") && !jsonObj.isNull("course_cd")) {
        jsonObj.put("course_name", courseMap.get(jsonObj.get("course_cd")));
      }
      if (jsonObj.has("from_course") && !jsonObj.isNull("from_course")) {
        jsonObj.put("from_course_name", courseMap.get(jsonObj.get("from_course")));
      }
      if (jsonObj.has("to_course") && !jsonObj.isNull("to_course")) {
        jsonObj.put("to_course_name", courseMap.get(jsonObj.get("to_course")));
      }
      if (jsonObj.has("to_facility") && !jsonObj.isNull("to_facility")) {
        jsonObj.put("to_facility_name", hospitalMap.get(jsonObj.get("to_facility")));
      }
      if (jsonObj.has("from_facility") && !jsonObj.isNull("from_facility")) {
        jsonObj.put("from_facility_name", hospitalMap.get(jsonObj.get("from_facility")));
      }
      if (jsonObj.has("diagnosis_facility_cd") && !jsonObj.isNull("diagnosis_facility_cd")) {
        jsonObj.put("diagnosis_facility_name", hospitalMap.get(jsonObj.get("diagnosis_facility_cd")));
      }
      if (jsonObj.has("to_doctor") && !jsonObj.isNull("to_doctor")) {
        jsonObj.put("to_doctor_name", doctorMap.get(jsonObj.get("to_doctor")));
      }
      if (jsonObj.has("from_doctor") && !jsonObj.isNull("from_doctor")) {
        jsonObj.put("from_doctor_name", doctorMap.get(jsonObj.get("from_doctor")));
      }
      if (jsonObj.has("diagnostician_cd") && !jsonObj.isNull("diagnostician_cd")) {
        jsonObj.put("diagnostician_name", doctorMap.get(jsonObj.get("diagnostician_cd")));
      }
      if (jsonObj.has("indicator_cd") && !jsonObj.isNull("indicator_cd")) {
        String indicatorCd = jsonObj.get("indicator_cd").toString().trim();
        if (!StringUtil.isBlank(indicatorCd)) {
          String indicator_name = doctorMap.get(Integer.valueOf(indicatorCd));
          jsonObj.put("indicator_name", indicator_name);
        }
      }
      jsonObj.put("facility_cd", facilityCd);
      jsonObj.put("readonly", true);
      //現在データに入れる
      currenDataJson.put(jsonObj);
    }
    return currenDataJson.toString();
  }

  /**
   * add 編集不可キー(read only)を紐づける開示した元データを現在データにいれる
   *
   * @param currentDataStr 現在データ
   * @param facilityCd     コード
   * @return
   */
  private String editPastDataWithReadOnly(String currentDataStr, String facilityCd, Map<String, String> hospitalMap, Map<Integer, String> doctorMap, Map<Integer, String> courseMap) {
    JSONArray currenDataJson = new JSONArray(currentDataStr);

    //エルゴード代入
    for (int i = 0; i < currenDataJson.length(); i++) {
      //代入facility_cd
      JSONObject jsonObj = currenDataJson.getJSONObject(i);
      jsonObj.put("facility_cd", facilityCd);
      jsonObj.put("facility_name", hospitalMap.get(facilityCd));
      if (jsonObj.has("course_cd") && !jsonObj.isNull("course_cd")) {
        jsonObj.put("course_name", courseMap.get(jsonObj.get("course_cd")));
      }
      if (jsonObj.has("from_course") && !jsonObj.isNull("from_course")) {
        jsonObj.put("from_course_name", courseMap.get(jsonObj.get("from_course")));
      }
      if (jsonObj.has("to_course") && !jsonObj.isNull("to_course")) {
        jsonObj.put("to_course_name", courseMap.get(jsonObj.get("to_course")));
      }
      if (jsonObj.has("to_facility") && !jsonObj.isNull("to_facility")) {
        jsonObj.put("to_facility_name", hospitalMap.get(jsonObj.get("to_facility")));
      }
      if (jsonObj.has("from_facility") && !jsonObj.isNull("from_facility")) {
        jsonObj.put("from_facility_name", hospitalMap.get(jsonObj.get("from_facility")));
      }
      if (jsonObj.has("diagnosis_facility_cd") && !jsonObj.isNull("diagnosis_facility_cd")) {
        jsonObj.put("diagnosis_facility_name", hospitalMap.get(jsonObj.get("diagnosis_facility_cd")));
      }
      if (jsonObj.has("to_doctor") && !jsonObj.isNull("to_doctor")) {
        jsonObj.put("to_doctor_name", doctorMap.get(jsonObj.get("to_doctor")));
      }
      if (jsonObj.has("from_doctor") && !jsonObj.isNull("from_doctor")) {
        jsonObj.put("from_doctor_name", doctorMap.get(jsonObj.get("from_doctor")));
      }
      if (jsonObj.has("diagnostician_cd") && !jsonObj.isNull("diagnostician_cd")) {
        jsonObj.put("diagnostician_name", doctorMap.get(jsonObj.get("diagnostician_cd")));
      }
      if (jsonObj.has("indicator_cd") && !jsonObj.isNull("indicator_cd")) {
        String indicatorCd = jsonObj.get("indicator_cd").toString().trim();
        if (!StringUtil.isBlank(indicatorCd)) {
          String indicator_name = doctorMap.get(Integer.valueOf(indicatorCd));
          jsonObj.put("indicator_name", indicator_name);
        }
      }
      if (jsonObj.has("disease_cd") && !jsonObj.isNull("disease_cd")) {
        String diseaseCd = jsonObj.get("disease_cd").toString().trim();
        if (!StringUtil.isBlank(diseaseCd)) {
          MstDisease mstDisease = mstDiseaseDao.selectByCd(Integer.parseInt(diseaseCd));
          jsonObj.put("disease_name", mstDisease.getDiseaseName());
        }
      }
    }

    return currenDataJson.toString();
  }
  //add #12462 患者情報共有 zrx end
}
