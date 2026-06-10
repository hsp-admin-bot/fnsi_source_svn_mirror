package jp.co.nikkiso.ntss.admin_web.service;

import com.amazonaws.AmazonServiceException;
import com.amazonaws.SdkClientException;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.model.CopyObjectRequest;
import com.amazonaws.services.s3.model.PutObjectRequest;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.config.AwsConfiguration;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.FlagType;
import jp.co.nikkiso.ntss.admin_web.constant.MstToMongoEnum;
import jp.co.nikkiso.ntss.admin_web.request.masterMaintenance.job.MstJobRequest;
import jp.co.nikkiso.ntss.admin_web.request.mstInfo.MstInfoRequest;
import jp.co.nikkiso.ntss.admin_web.response.MedicineResponse;
import jp.co.nikkiso.ntss.admin_web.response.MedicineResponseExtends;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterDataResponse;
import jp.co.nikkiso.ntss.admin_web.response.mstDialyzer.DialyzerSharingInfoResponse;
import jp.co.nikkiso.ntss.admin_web.response.mstEquipment.EquipmentSharingInfoResponse;
import jp.co.nikkiso.ntss.admin_web.response.mstMedicine.MedicineSharingInfoResponse;
import jp.co.nikkiso.ntss.admin_web.response.mstMedicineMix.MedicineMixSharingInfoResponse;
import jp.co.nikkiso.ntss.admin_web.response.mstMedicineMix.MstMedicineMixDto;
import jp.co.nikkiso.ntss.admin_web.response.sysFunction.SysFunctionResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.Utility.UtilityService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.master.MasterEditServiceImpl;
import jp.co.nikkiso.ntss.admin_web.service.master.user.MstUserService;
import jp.co.nikkiso.ntss.admin_web.service.sysSignManager.SysSigninManagerService;
import jp.co.nikkiso.ntss.admin_web.service.sysSignManager.SysSigninManagerService.ForceSignOutReason;
import jp.co.nikkiso.ntss.admin_web.service.utils.DateTimeUtils;
import jp.co.nikkiso.ntss.admin_web.service.utils.MasterCacheHandler;
import jp.co.nikkiso.ntss.admin_web.service.utils.StrUtils;
import jp.co.nikkiso.ntss.admin_web.service.master.report.MstReportService;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.IndicationUtils;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallFacilityCancelManage;
import jp.co.nikkiso.ntss.admin_web.web.rest.validation.ApiEntityMstInfo;
import jp.co.nikkiso.ntss.admin_web.web.service.MaterialsSharingPatientInformation.MaterialsSharingPatientInfomationService;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.TransactionManagerName;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MntDeviceEdgeStateDao;
import jp.co.nikkiso.ntss.core.dao.MntFacilityCancelManageDao;
import jp.co.nikkiso.ntss.core.dao.MstAddMonitorDao;
import jp.co.nikkiso.ntss.core.dao.MstAdditionDao;
import jp.co.nikkiso.ntss.core.dao.MstAlarmNotificationDao;
import jp.co.nikkiso.ntss.core.dao.MstBbsKindDao;
import jp.co.nikkiso.ntss.core.dao.MstBedDao;
import jp.co.nikkiso.ntss.core.dao.MstChecklistDao;
import jp.co.nikkiso.ntss.core.dao.MstComFixedPhraseDao;
import jp.co.nikkiso.ntss.core.dao.MstCoopFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstCourseDao;
import jp.co.nikkiso.ntss.core.dao.MstDeviceEdgeDao;
import jp.co.nikkiso.ntss.core.dao.MstDeviceSetInfoDefaultDao;
import jp.co.nikkiso.ntss.core.dao.MstDialysisDifficultyDao;
import jp.co.nikkiso.ntss.core.dao.MstDialyzerDao;
import jp.co.nikkiso.ntss.core.dao.MstDiseaseDao;
import jp.co.nikkiso.ntss.core.dao.MstEquipmentClassDao;
import jp.co.nikkiso.ntss.core.dao.MstEquipmentDao;
import jp.co.nikkiso.ntss.core.dao.MstEquipmentSetDao;
import jp.co.nikkiso.ntss.core.dao.MstExamItemDao;
import jp.co.nikkiso.ntss.core.dao.MstExamMatomeDao;
import jp.co.nikkiso.ntss.core.dao.MstExamSetDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilityCalendarLayoutDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilityHashDao;
import jp.co.nikkiso.ntss.core.dao.MstFavoriteFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstFunctionReportDao;
import jp.co.nikkiso.ntss.core.dao.MstHolidayDao;
import jp.co.nikkiso.ntss.core.dao.MstIfEdgeDao;
import jp.co.nikkiso.ntss.core.dao.MstImplantDao;
import jp.co.nikkiso.ntss.core.dao.MstInfectionDao;
import jp.co.nikkiso.ntss.core.dao.MstJobDao;
import jp.co.nikkiso.ntss.core.dao.MstKurDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicateTimingDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineClassDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineGroupDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineMixDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineSetDao;
import jp.co.nikkiso.ntss.core.dao.MstMenuGroupDao;
import jp.co.nikkiso.ntss.core.dao.MstObsKindDao;
import jp.co.nikkiso.ntss.core.dao.MstPatCalendarLayoutDao;
import jp.co.nikkiso.ntss.core.dao.MstPatEventSubCategoryDao;
import jp.co.nikkiso.ntss.core.dao.MstPatHashDao;
import jp.co.nikkiso.ntss.core.dao.MstPatListLayoutDao;
import jp.co.nikkiso.ntss.core.dao.MstPatMemoDao;
import jp.co.nikkiso.ntss.core.dao.MstPatViewerLayoutDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstProcedureDao;
import jp.co.nikkiso.ntss.core.dao.MstRadSetDao;
import jp.co.nikkiso.ntss.core.dao.MstRelationshipDao;
import jp.co.nikkiso.ntss.core.dao.MstReportDao;
import jp.co.nikkiso.ntss.core.dao.MstRoomBedGroupDao;
import jp.co.nikkiso.ntss.core.dao.MstSelectorDao;
import jp.co.nikkiso.ntss.core.dao.MstSeverityDao;
import jp.co.nikkiso.ntss.core.dao.MstSpitzDao;
import jp.co.nikkiso.ntss.core.dao.MstSupportDao;
import jp.co.nikkiso.ntss.core.dao.MstTabooAllergyDao;
import jp.co.nikkiso.ntss.core.dao.MstTakeMedicineDao;
import jp.co.nikkiso.ntss.core.dao.MstTransportDao;
import jp.co.nikkiso.ntss.core.dao.MstTreatmentDao;
import jp.co.nikkiso.ntss.core.dao.MstTreatmentSetDao;
import jp.co.nikkiso.ntss.core.dao.MstTreatmentStatusDispItemDao;
import jp.co.nikkiso.ntss.core.dao.MstUrlLinkRegisterDao;
import jp.co.nikkiso.ntss.core.dao.MstUserAuthenticationDao;
import jp.co.nikkiso.ntss.core.dao.MstUserDao;
import jp.co.nikkiso.ntss.core.dao.MstVaDao;
import jp.co.nikkiso.ntss.core.dao.MstWardDao;
import jp.co.nikkiso.ntss.core.dao.MstWaterSurveyPointDao;
import jp.co.nikkiso.ntss.core.dao.MstWaterSurveyTypeDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.SysAddressDao;
import jp.co.nikkiso.ntss.core.dao.SysCountryDao;
import jp.co.nikkiso.ntss.core.dao.SysDataListCategoryDao;
import jp.co.nikkiso.ntss.core.dao.SysFacilityDao;
import jp.co.nikkiso.ntss.core.dao.SysFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.SysFunctionAdvancedDao;
import jp.co.nikkiso.ntss.core.dao.SysFunctionDao;
import jp.co.nikkiso.ntss.core.dao.SysGenericMedicineDao;
import jp.co.nikkiso.ntss.core.dao.SysSubscriptionPlanDao;
import jp.co.nikkiso.ntss.core.dao.SysSystemDefineDao;
import jp.co.nikkiso.ntss.core.entity.MntFacilityCancelManage;
import jp.co.nikkiso.ntss.core.entity.MntMedicineSupport;
import jp.co.nikkiso.ntss.core.entity.MstAddMonitor;
import jp.co.nikkiso.ntss.core.entity.MstAddition;
import jp.co.nikkiso.ntss.core.entity.MstAlarmNotification;
import jp.co.nikkiso.ntss.core.entity.MstBbsKind;
import jp.co.nikkiso.ntss.core.entity.MstBed;
import jp.co.nikkiso.ntss.core.entity.MstBedIndex;
import jp.co.nikkiso.ntss.core.entity.MstComFixedPhrase;
import jp.co.nikkiso.ntss.core.entity.MstCoopFacility;
import jp.co.nikkiso.ntss.core.entity.MstCourse;
import jp.co.nikkiso.ntss.core.entity.MstDeviceEdge;
import jp.co.nikkiso.ntss.core.entity.MstDialysisDifficulty;
import jp.co.nikkiso.ntss.core.entity.MstDialyzer;
import jp.co.nikkiso.ntss.core.entity.MstDialyzerDto;
import jp.co.nikkiso.ntss.core.entity.MstDisease;
import jp.co.nikkiso.ntss.core.entity.MstEquipment;
import jp.co.nikkiso.ntss.core.entity.MstEquipmentClass;
import jp.co.nikkiso.ntss.core.entity.MstEquipmentDto;
import jp.co.nikkiso.ntss.core.entity.MstEquipmentExtends;
import jp.co.nikkiso.ntss.core.entity.MstEquipmentSet;
import jp.co.nikkiso.ntss.core.entity.MstExamItem;
import jp.co.nikkiso.ntss.core.entity.MstExamMatome;
import jp.co.nikkiso.ntss.core.entity.MstExamSet;
import jp.co.nikkiso.ntss.core.entity.MstFacility;
import jp.co.nikkiso.ntss.core.entity.MstFacilityCalendarLayout;
import jp.co.nikkiso.ntss.core.entity.MstFacilityHash;
import jp.co.nikkiso.ntss.core.entity.MstFavoriteFacility;
import jp.co.nikkiso.ntss.core.entity.MstIfEdge;
import jp.co.nikkiso.ntss.core.entity.MstImplant;
import jp.co.nikkiso.ntss.core.entity.MstInfection;
import jp.co.nikkiso.ntss.core.entity.MstJob;
import jp.co.nikkiso.ntss.core.entity.MstJob.NotificationSettings;
import jp.co.nikkiso.ntss.core.entity.MstKur;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.MstMedicateTiming;
import jp.co.nikkiso.ntss.core.entity.MstMedicine;
import jp.co.nikkiso.ntss.core.entity.MstMedicineClass;
import jp.co.nikkiso.ntss.core.entity.MstMedicineDto;
import jp.co.nikkiso.ntss.core.entity.MstMedicineExtendsDto;
import jp.co.nikkiso.ntss.core.entity.MstMedicineGroup;
import jp.co.nikkiso.ntss.core.entity.MstMedicineMix;
import jp.co.nikkiso.ntss.core.entity.MstMedicineMixExtendsDto;
import jp.co.nikkiso.ntss.core.entity.MstMedicineSet;
import jp.co.nikkiso.ntss.core.entity.MstMenuGroup;
import jp.co.nikkiso.ntss.core.entity.MstObsKind;
import jp.co.nikkiso.ntss.core.entity.MstPatCalendarLayout;
import jp.co.nikkiso.ntss.core.entity.MstPatEventSubCategory;
import jp.co.nikkiso.ntss.core.entity.MstPatHash;
import jp.co.nikkiso.ntss.core.entity.MstPatListLayout;
import jp.co.nikkiso.ntss.core.entity.MstPatMemo;
import jp.co.nikkiso.ntss.core.entity.MstPatViewerLayout;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstProcedure;
import jp.co.nikkiso.ntss.core.entity.MstRadSet;
import jp.co.nikkiso.ntss.core.entity.MstRelationship;
import jp.co.nikkiso.ntss.core.entity.MstReport;
import jp.co.nikkiso.ntss.core.entity.MstRoomBedGroup;
import jp.co.nikkiso.ntss.core.entity.MstSelector;
import jp.co.nikkiso.ntss.core.entity.MstSelector.Item;
import jp.co.nikkiso.ntss.core.entity.MstSeverity;
import jp.co.nikkiso.ntss.core.entity.MstSpitz;
import jp.co.nikkiso.ntss.core.entity.MstTabooAllergy;
import jp.co.nikkiso.ntss.core.entity.MstTakeMedicine;
import jp.co.nikkiso.ntss.core.entity.MstTransport;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.MstTreatmentSet;
import jp.co.nikkiso.ntss.core.entity.MstTreatmentStatusDispItem;
import jp.co.nikkiso.ntss.core.entity.MstUrlLinkRegister;
import jp.co.nikkiso.ntss.core.entity.MstUser;
import jp.co.nikkiso.ntss.core.entity.MstUser.PersonalSetting;
import jp.co.nikkiso.ntss.core.entity.MstUserAuthentication;
import jp.co.nikkiso.ntss.core.entity.MstVa;
import jp.co.nikkiso.ntss.core.entity.MstWard;
import jp.co.nikkiso.ntss.core.entity.MstWaterSurveyType;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatNameIdentification;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.SysAddress;
import jp.co.nikkiso.ntss.core.entity.SysCountry;
import jp.co.nikkiso.ntss.core.entity.SysDataListCategory;
import jp.co.nikkiso.ntss.core.entity.SysFacility;
import jp.co.nikkiso.ntss.core.entity.SysFacilitySetting;
import jp.co.nikkiso.ntss.core.entity.SysFunction;
import jp.co.nikkiso.ntss.core.entity.SysFunctionAdvanced;
import jp.co.nikkiso.ntss.core.entity.SysGenericMedicine;
import jp.co.nikkiso.ntss.core.entity.SysSubscriptionPlan;
import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvMstExamItem;
import jp.co.nikkiso.ntss.core.entity.custom.HolidayDetail;
import jp.co.nikkiso.ntss.core.entity.custom.MstPatViewerLayoutMonitorItem;
import jp.co.nikkiso.ntss.core.entity.custom.MstTabooAllergyDetailInfo;
import jp.co.nikkiso.ntss.core.entity.custom.MstUserData;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainTreatDate;
import jp.co.nikkiso.ntss.core.entity.custom.PatInfoTabooAllergy;
import jp.co.nikkiso.ntss.core.entity.custom.WaterSurveyPoint;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.trigger.MstDeviceEdgeTrigger;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.collections4.ListUtils;
import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVParser;
import org.apache.commons.csv.CSVRecord;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.seasar.doma.jdbc.Config;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.interceptor.TransactionAspectSupport;
import org.springframework.util.CollectionUtils;
import org.springframework.util.ObjectUtils;
import org.springframework.util.StringUtils;
import org.springframework.validation.BindingResult;
import org.springframework.validation.ObjectError;

import java.io.File;
import java.io.IOException;
import java.io.Reader;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.InputStreamReader;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.nio.file.FileVisitResult;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.StandardCopyOption;
import java.nio.file.StandardOpenOption;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.io.InputStream;
import java.lang.reflect.Field;
import java.net.URI;
import java.net.URISyntaxException;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.function.Function;
import java.util.stream.Collectors;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

// add redmine 4485 施設マスタの並び順が変更 宋qy start
// add redmine 4485 施設マスタの並び順が変更 宋qy end

/**
 * 各マスタ情報のServiceインタフェース.
 */
@Service
@Slf4j
public class MstInfoServiceImpl implements MstInfoService {

  private static final String NKKNKK = "nkknkk";
  // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou start
  // 施設設定マスタNo64:有効
  private static final String VALID = "1";
  /**
   * サインイン管理のServiceインターフェース.
   */
  @Autowired
  private SysSigninManagerService sysSigninManagerService;
  // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou end

  // add redmine 4485 施設マスタの並び順が変更 宋qy start
  @Autowired
  private MasterEditServiceImpl masterEditService;
  // add redmine 4485 施設マスタの並び順が変更 宋qy end

  /**
   * ベッドマスタ
   */
  @Autowired
  private MstBedDao mstBedDao;
  /**
   * ロギングのServiceインタフェース.
   */
  @Autowired
  private LogService logService;

  /**
   * 帳票マスタのServiceインタフェース.
   */
  @Autowired
  MstReportService mstReportService;

  /**
   * 施設解約API処理インタフェース
   */
  @Autowired
  private WebApiCallFacilityCancelManage webApiCallFacilityCancelManage;

  /**
   * 用法・用語マスタDao
   */
  @Autowired
  private MstTakeMedicineDao mstTakeMedicineDao;

  //DB更新ログ出力ロジック start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Autowired
  private LogServiceCore logServiceCore;
  //DB更新ログ出力ロジック end 20210201

  // ADD #8094 2023/02/05 BY HandsomeLin Start
  @Autowired
  private SysFacilitySettingDao sysFacilitySettingDao;
  // ADD #8094 2023/02/05 BY HandsomeLin End

  /**
   * 施設解約管理Dao
   */
  @Autowired
  private MntFacilityCancelManageDao mntFacilityCancelManageDao;

  // add FNSI-改修内容追加OrdMain履歴 付 start
  @Autowired
  private SelectHistoryUtils selectHistoryUtils;

  // add FNSI-改修内容追加OrdMain履歴 付 end

    // add
    //
    // 7233 デフォルト帳票について 吉 start
  @Autowired
  private MstReportDao mstReportDao;
  // add 7233 デフォルト帳票について 吉 end

  /*add by yuyifu 2023-01-31 [CodeOptimization] start*/
  @Autowired
  private PatPersonalMainDao patPersonalMainDao;

  @Autowired
  private MaterialsSharingPatientInfomationService materialsSharingPatientInfomationService;
  /*add by yuyifu 2023-01-31 [CodeOptimization] end*/

  /* add by biangang  2023-01-31 CodeOptimization  start */
  @Autowired
  private FacilitySettingService facilitySettingService;

  @Autowired
  private MstInfoService mstInfoService;
  /* add by biangang  2023-01-31 CodeOptimization  end */
  // add #8403 【デグレ】デバイスエッジマスタで新規レコードが保存できない dou start
  @Autowired
  private MntDeviceEdgeStateDao mntDeviceEdgeStateDao;
  // add #8403 【デグレ】デバイスエッジマスタで新規レコードが保存できない dou end

  @Autowired
  MstDeviceEdgeTrigger mstDeviceEdgeTrigger;
  // add #9274 空きベッドの検索NG dou start
  @Autowired
  private OrdMainDao ordMainDao;
  // add #9274 空きベッドの検索NG dou end

  /**
   * 施設マスタのDaoインタフェース.
   */
  @Autowired
  private MstSupportDao mstSupportDao;

  /**
   * 機能帳票マスタのDaoインタフェース.
   */
  @Autowired
  private MstFunctionReportDao mstFunctionReportDao;

  @Autowired
  private MstTreatmentStatusDispItemDao mstTreatmentStatusDispItemDao;

  /**
   * 取得データの並び替え.
   *
   * @param data               取得したデータ
   * @param masterPhysicalName マスタ名(物理名称)
   * @param facilityCd         施設コード
   * @return 並び替え後のデータ
   */
  private List<Object> sortData(List<Object> data, String masterPhysicalName, String facilityCd) {
    if (!"".equals(masterPhysicalName)) {
      // mstSelectorから並び順を取得
      MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, masterPhysicalName);
      if (mstSelector != null) {
        // ソート後データ
        List<Object> sortedData = new ArrayList<>();
        // ソートした配列
        List<Object> deletedCode = new ArrayList<>();
        // ソート用配列
        List<Long> sortedCodes = mstSelector.getOrderSettings().getItems().stream().map(Item::getCode).toList();
        // ソート用配列順にデータを並び替え
        for (Long sortedCode : sortedCodes) {
          data.stream().filter(obj -> {
            if (obj instanceof MstDialyzerDto mstData) {
              return sortedCode.compareTo(mstData.getDialyzerCd().longValue()) == 0;
            } else if (obj instanceof MstEquipmentDto mstData) {
              return sortedCode.compareTo(mstData.getEquipmentCd().longValue()) == 0;
            } else if (obj instanceof MstMedicineDto mstData) {
              return sortedCode.compareTo(mstData.getMedicineCd().longValue()) == 0;
            } else if (obj instanceof MstMedicineExtendsDto mstData) {
              return sortedCode.compareTo(mstData.getMedicineCd().longValue()) == 0;
            } else if (obj instanceof MstMedicineMixDto mstData) {
              return sortedCode.compareTo(mstData.getMedicineMixCd().longValue()) == 0;
            } else {
              return false;
            }
          }).findFirst().ifPresent(sortedData::add);
        }

        Set<Object> sortedDataSet = new HashSet<>(sortedData);
        for (Object item : data) {
          if (!sortedDataSet.contains(item)) {
            deletedCode.add(item);
          }
        }

        sortedData.addAll(deletedCode);
        return sortedData;
      }
    }
    return data;
  }

  @Override
  public Page<MstBed> findMstBedAll(Pageable pageable) {
    SelectOptions selectOptions = SelectOptionsUtils.get(pageable, true);
    List<MstBed> mstBedList = mstBedDao.selectAll(selectOptions);
    return new PageImpl<>(mstBedList, pageable, selectOptions.getCount());
  }

  @Override
  public Page<MstBed> findMstBedByFacilityCd(Pageable pageable, String facility_cd, String is_disp, String is_del) {
    SelectOptions selectOptions = SelectOptions.get();
    List<MstBed> mstBedList = mstBedDao.selectByFacilityCd(selectOptions, facility_cd, is_disp, is_del);
    // FNSI-修正 マスタ削除の対応 ベッド add start
    mstBedList.forEach(x -> {
      if (org.apache.commons.lang3.StringUtils.equals(x.getIsDisp(), "0")) {
        x.setBedName(LoggingConstant.MASTER_DELETE.DELETED + x.getBedName());
      }
    });
    // FNSI-修正 マスタ削除の対応 ベッド add end
    return new PageImpl<>(mstBedList, pageable, selectOptions.getCount());
  }

  // FNSI-修正 マスタ削除の対応 chen add start
  @Override
  public Page<MstBed> findMstBedByFacilityCdDel(Pageable pageable, String facility_cd) {
    SelectOptions selectOptions = SelectOptions.get();
    List<MstBed> mstBedList = mstBedDao.selectByFacilityCdDel(selectOptions, facility_cd);
    return new PageImpl<>(mstBedList, pageable, selectOptions.getCount());
  }
// FNSI-修正 マスタ削除の対応 chen add end

  @Override
  public List<MstBed> findMstBedByFacilityCd(String facility_cd) {
    List<MstBed> mstBedList = mstBedDao.selectByFacilityCdMachineNo(facility_cd);
    return mstBedList;
  }
  //add #9009 ベッドマスタにおいて治療中のベッドに対して編集可能 張 start
  @Override
  public List<MstBed> selectBedListByFacilityCd(String facility_cd) {
    List<MstBed> mstBedList = mstBedDao.selectBedListByFacilityCd(facility_cd);
    return mstBedList;
  }
  //add #9009 ベッドマスタにおいて治療中のベッドに対して編集可能 張 end
  @Override
  public String findBedNameByBedCd(Long bedCd) {
    String bedName = null;
    MstBed mstBed = mstBedDao.selectByBedCd(bedCd, "1", "0");
    if (mstBed != null) {
      bedName = mstBed.getBedName();
    }
    return bedName;
  }
  //add no4878 メイン画面と編集画面で削除済み、期限切れ、分類不一致、禁忌アレルギーの接頭付けが一致していない 張 start
  @Override
  public String findBedNameByBedCdIncludeDel(Long bedCd) {
    String bedName = null;
    MstBed mstBed = mstBedDao.selectByBedCd(bedCd, "0", "0");
    if (mstBed != null) {
      bedName = mstBed.getBedName();
    }
    return bedName;
  }

  @Override
  public List<MstBed> selectAllByFacilityCd(String facility_cd) {
    return mstBedDao.selectAllByFacilityCd(facility_cd);
  }
  //add no4878 メイン画面と編集画面で削除済み、期限切れ、分類不一致、禁忌アレルギーの接頭付けが一致していない 張 end

  /**
   * {@inheritDoc}
   */
  @Override
  //mod 11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) start
//  public List<MstBedIndex> selectForSearchFreeBeds(String facility_cd, Long pat_id, Long kur_cd, List<Integer> treat_week_list, String search_start_date,
////      mod 5619 装置と紐づいていないベッドも表示 張 start
//// add 9077 施設設定マスタNo35,39の設定に基づいたベッドリストが生成されない。20230710 ztc start
////                                              String search_end_date, Boolean is_all, Long ms_max_treat, Boolean is_valid_period, List<Integer> indTreatmentCdList, List<Long> indKurCdList) {
//                                              String search_end_date, Boolean is_all, Long ms_max_treat, Boolean is_valid_period, List<Integer> indTreatmentCdList, List<Long> indKurCdList,Long init_bed_cd, Boolean is_infiniteDate) {
//    //add 8085 【デグレ】患者経過総合ビューア>スケジュール編集にてベッドが登録されているのに未登録となる。 周安寧 start
//// add 9077 施設設定マスタNo35,39の設定に基づいたベッドリストが生成されない。20230710 ztc end
//    int searchCount = 0;
//    searchCount = mstBedDao.selectForSearchFreeBedsCount(facility_cd, pat_id, search_start_date,search_end_date);
//    //add 8085 【デグレ】患者経過総合ビューア>スケジュール編集にてベッドが登録されているのに未登録となる。 周安寧 end
//    // add 9077 施設設定マスタNo35,39の設定に基づいたベッドリストが生成されない。20230710 ztc start
//    return mstBedDao.selectForSearchFreeBeds(facility_cd, pat_id, kur_cd, treat_week_list, search_start_date,
////      search_end_date, is_all, ms_max_treat, is_valid_period, indTreatmentCdList, indKurCdList);
////      mod 5619 装置と紐づいていないベッドも表示 張 end
//      //mod 8085 【デグレ】患者経過総合ビューア>スケジュール編集にてベッドが登録されているのに未登録となる。 周安寧 start
//      //search_end_date, is_all, ms_max_treat, is_valid_period, indTreatmentCdList, indKurCdList,init_bed_cd==null?0:init_bed_cd);
//      search_end_date, is_all, ms_max_treat, is_valid_period, indTreatmentCdList, indKurCdList,init_bed_cd==null?0:init_bed_cd ,searchCount, is_infiniteDate);
//    //mod 8085 【デグレ】患者経過総合ビューア>スケジュール編集にてベッドが登録されているのに未登録となる。 周安寧 start
//    // add 9077 施設設定マスタNo35,39の設定に基づいたベッドリストが生成されない。20230710 ztc end
  public List<MstBedIndex> selectForSearchFreeBeds(String facility_cd, Long pat_id, Long kur_cd, List<Integer> treat_week_list, String search_start_date,
                                                   String search_end_date, Boolean is_all, Long ms_max_treat, List<Integer> indTreatmentCdList, List<Long> indKurCdList) {
    return mstBedDao.selectForSearchFreeBeds(facility_cd, pat_id, kur_cd, treat_week_list, search_start_date,
      search_end_date, is_all, ms_max_treat, indTreatmentCdList, indKurCdList);
    //mod 11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) end
  }

  ;

  /*
   * 共通定型文マスタ
   */
  @Autowired
  private MstComFixedPhraseDao mstComFixedPhraseDao;

  @Override
  public Page<MstComFixedPhrase> findMstComFixedPhraseAll(Pageable pageable, MstComFixedPhrase params) {
    SelectOptions selectOptions = SelectOptions.get();

    List<MstComFixedPhrase> mstComFixedPhraseList = mstComFixedPhraseDao.selectAll(selectOptions, params);
    return new PageImpl<>(mstComFixedPhraseList, pageable, selectOptions.getCount());
  }

  @Override
  public Page<MstComFixedPhrase> findMstComFixedPhraseByJobCd(Pageable pageable, MstComFixedPhrase params, String JobCd) {
    SelectOptions selectOptions = SelectOptions.get();

    List<MstComFixedPhrase> mstComFixedPhraseListAll = mstComFixedPhraseDao.selectAll(selectOptions, params);
    List<MstComFixedPhrase> mstComFixedPhraseList = new ArrayList<MstComFixedPhrase>();

    // 引数で指定されたJobCdで絞り込み
    for (MstComFixedPhrase phrase : mstComFixedPhraseListAll) {
      if (!StringUtils.isEmpty(phrase.getOccupations())) {
        List<String> lstJobCd = Arrays.asList(phrase.getOccupations().replace("[", "").replace("]", "").replace(" ", "").split(","));
        if (lstJobCd.contains(JobCd)) {
          mstComFixedPhraseList.add(phrase);
        }
      }
    }

    return new PageImpl<>(mstComFixedPhraseList, pageable, selectOptions.getCount());
  }

  /*
   * 診療科マスタ
   */
  @Autowired
  private MstCourseDao mstCourseDao;

  @Override
  public Page<MstCourse> findMstCourseAll(Pageable pageable, MstCourse params) {
    SelectOptions selectOptions = SelectOptions.get();

    List<MstCourse> mstCourseList = mstCourseDao.selectAll(selectOptions, params);
    return new PageImpl<>(mstCourseList, pageable, selectOptions.getCount());
  }

  @Override
  public Page<MstCourse> findMstCourseAllIncludDelete(Pageable pageable, MstCourse params) {
    SelectOptions selectOptions = SelectOptions.get();

    List<MstCourse> mstCourseList = mstCourseDao.selectAllIncludeDelete(selectOptions, params);
    return new PageImpl<>(mstCourseList, pageable, selectOptions.getCount());
  }

  /*
   * 透析困難マスタ
   */
  @Autowired
  private MstDialysisDifficultyDao mstDialysisDifficultyDao;

  @Override
  public Page<MstDialysisDifficulty> findMstDialysisDifficultyAll(Pageable pageable, MstDialysisDifficulty params) {
    SelectOptions selectOptions = SelectOptions.get();

    List<MstDialysisDifficulty> mstDialysisDifficultyList = mstDialysisDifficultyDao.selectAll(selectOptions, params);
    return new PageImpl<>(mstDialysisDifficultyList, pageable, selectOptions.getCount());
  }

  /*
   * ダイアライザマスタ
   */
  @Autowired
  private MstDialyzerDao mstDialyzerDao;

  @Override
  public Page<MstDialyzer> findMstDialyzerAll(Pageable pageable, MstDialyzer params) {
    SelectOptions selectOptions = SelectOptions.get();

    List<MstDialyzer> mstDialyzerList = mstDialyzerDao.selectAll(selectOptions, params);
    return new PageImpl<>(mstDialyzerList, pageable, selectOptions.getCount());
  }

  // FNSI-修正 マスタ削除の対応 chen add start
  @Override
  public Page<MstDialyzer> findMstDialyzerAllNoDel(Pageable pageable, MstDialyzer params) {
    SelectOptions selectOptions = SelectOptions.get();

    List<MstDialyzer> mstDialyzerList = mstDialyzerDao.selectAllNoDel(selectOptions, params);
    return new PageImpl<>(mstDialyzerList, pageable, selectOptions.getCount());
  }
// FNSI-修正 マスタ削除の対応 chen add end

  @Override
  public MstDialyzer findMstDialyzerByCd(String cd) {
    MstDialyzer mstDialyzer = null;
    if (StrUtils.isNumber(cd)) {
      int dialyzerCd = Integer.parseInt(cd);
      mstDialyzer = mstDialyzerDao.selectByDialyzerCd(SelectOptions.get(), dialyzerCd);
    }
    return mstDialyzer;
  }

  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 start
  @Override
  //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　Start
  public List<MstDialyzerDto> findMstDialyzerTabooAllergy(String facilityCd, Long patId, String TreatDate, boolean... isDelFlg) {
  //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　End
    SelectOptions selectOptions = SelectOptions.get();
    // ダイアライザ一覧を取得
    MstDialyzer param = new MstDialyzer() {
      {
        setFacilityCd(facilityCd);
      }
    };

//    List<MstDialyzer> lstMstDialyzer = mstDialyzerDao.selectAll(selectOptions, param);
    List<MstDialyzer> lstMstDialyzer;
    List<MstDialyzerDto> mstDialyzerDtoList = new ArrayList<>();
    if (isDelFlg.length == 0) {
      lstMstDialyzer = mstDialyzerDao.selectAll(selectOptions, param);
    } else {
      lstMstDialyzer = mstDialyzerDao.selectIncludeDeleted(selectOptions, param);
    }

    // 禁忌・アレルギーリスト一覧を取得
    MstTabooAllergy param2 = new MstTabooAllergy() {
      {
        setFacilityCd(facilityCd);
      }
    };
    List<MstTabooAllergy> lstMstTabooAllergy = mstTabooAllergyDao.selectAll(selectOptions, param2);
    //add 9706 ljx start
    //???患者の場合、patIdが「-1」である、判断追加、後の処理を実行しない。
    if(-1 == patId){
      if (lstMstDialyzer != null && !lstMstDialyzer.isEmpty()) {
        for (MstDialyzer element : lstMstDialyzer) {
          MstDialyzerDto newElement = new MstDialyzerDto();
          BeanUtils.copyProperties(element, newElement);
          newElement.setIsTaboo(false);
          newElement.setIsAllergy(false);
          mstDialyzerDtoList.add(newElement);
        }
      }
      List<Object> objects = new ArrayList<>(mstDialyzerDtoList.size());
      objects.addAll(mstDialyzerDtoList);
      objects = sortData(objects, "mst_dialyzer", facilityCd);
      List<MstDialyzerDto> res = new ArrayList<>();
      for (Object obj : objects) {
        if (obj instanceof MstDialyzerDto) {
          res.add((MstDialyzerDto) obj);
        }
      }

      return res;
    }
    //add 9706 ljx end
    // 対象患者のアレルギー情報を取得
    PatMain patMain = patMainDao.selectById(patId);

    try {
      /* modify by shiyw 2023-04-10 [#8271] jdk8->aws jdk17 --start */
      //ArrayList<PatInfoTabooAllergy> lstTabooAllergyInfo = new ObjectMapper().readValue(patMain.getTaboo_allergy_info(), new TypeReference<List<PatInfoTabooAllergy>>() {});
      ArrayList<PatInfoTabooAllergy> lstTabooAllergyInfo = new ObjectMapper().readValue(patMain.getTaboo_allergy_info(), new TypeReference<ArrayList<PatInfoTabooAllergy>>() {});
      /* modify by shiyw 2023-04-10 [#8271] jdk8->aws jdk17 --end */

      // mod FNSI-改修内容6618修正 xuty start
      // 禁忌・アレルギーダイアライザリスト
      // ArrayList<Integer> lstTabooAllergyDialyzer = new ArrayList<Integer>();
      // 禁忌ダイアライザリスト
      // ArrayList<Integer> lstTabooDialyzer = new ArrayList<Integer>();
      // アレルギーダイアライザリスト
      // ArrayList<Integer> lstAllergyDialyzer = new ArrayList<Integer>();
      ArrayList<String> lstTabooAllergyDialyzer = new ArrayList<String>();
      ArrayList<String> lstTabooDialyzer = new ArrayList<String>();
      ArrayList<String> lstAllergyDialyzer = new ArrayList<String>();
      // mod FNSI-改修内容6618修正 xuty end

      // 患者の禁忌・アレルギー情報毎にチェックを行い、禁忌ダイアライザリスト・アレルギーダイアライザリストを作成する
      for (PatInfoTabooAllergy patInfoTabooAllergy : lstTabooAllergyInfo) {
        if (patInfoTabooAllergy.getCategory_class().equals("0")) {
          // 対象区分が0:"禁忌・アレルギー" → taboo_allergy_cdの値から禁忌・アレルギーマスタを検索後、ダイアライザコードを取得
          // mod FNSI-改修内容6618修正 xuty start
          // Integer cd = patInfoTabooAllergy.getTaboo_allergy_cd();
          String cd = patInfoTabooAllergy.getTaboo_allergy_cd();
          // mod FNSI-改修内容6618修正 xuty end
          Optional<MstTabooAllergy> mstTabooAllergy = lstMstTabooAllergy.stream().filter(a -> a.getTabooAllergyCd().equals(cd)).findFirst();
          if (mstTabooAllergy.isPresent()) {
            // 禁忌・アレルギーマスタの詳細項目でclassCd(禁忌対象区分)が"4"(ダイアライザー)のデータを抽出
            /* modify by shiyw 2023-04-10 [#8271] jdk8->aws jdk17 --start */
            //ArrayList<MstTabooAllergyDetailInfo> lstTabooAllergyDetailInfo = new ObjectMapper().readValue(mstTabooAllergy.get().getDetailInfo(), new TypeReference<List<MstTabooAllergyDetailInfo>>() {});
            ArrayList<MstTabooAllergyDetailInfo> lstTabooAllergyDetailInfo = new ObjectMapper().readValue(mstTabooAllergy.get().getDetailInfo(), new TypeReference<ArrayList<MstTabooAllergyDetailInfo>>() {});
            /* modify by shiyw 2023-04-10 [#8271] jdk8->aws jdk17 --end */
            // mod FNSI-改修内容6618修正 xuty start
            // List<Integer> lstDialyzerCd = lstTabooAllergyDetailInfo.stream().filter(a -> a.getClassCd().equals("4")).map(a -> a.getCd()).collect(Collectors.toList());
            List<String> lstDialyzerCd = lstTabooAllergyDetailInfo.stream().filter(a -> a.getClassCd().equals("4")).map(a -> a.getCd()).collect(Collectors.toList());
            // mod FNSI-改修内容6618修正 xuty end
            if (patInfoTabooAllergy.getTaboo_allergy_class().equals("1")) {
              // 禁忌
              lstTabooDialyzer.addAll(lstDialyzerCd);
            } else if (patInfoTabooAllergy.getTaboo_allergy_class().equals("2")) {
              // アレルギー
              lstAllergyDialyzer.addAll(lstDialyzerCd);
            }
          }

        } else if (patInfoTabooAllergy.getCategory_class().equals("4")) {
          // 対象区分が4:ダイアライザー → taboo_allergy_cdの値がそのままダイアライザコード
          if (patInfoTabooAllergy.getTaboo_allergy_class().equals("1")) {
            // 禁忌
            lstTabooDialyzer.add(patInfoTabooAllergy.getTaboo_allergy_cd());
          } else if (patInfoTabooAllergy.getTaboo_allergy_class().equals("2")) {
            // アレルギー
            lstAllergyDialyzer.add(patInfoTabooAllergy.getTaboo_allergy_cd());
          }
        }
      }

      if (lstMstDialyzer != null && !lstMstDialyzer.isEmpty()) {
        for (MstDialyzer element : lstMstDialyzer) {
          MstDialyzerDto newElement = new MstDialyzerDto();
          BeanUtils.copyProperties(element, newElement);
          mstDialyzerDtoList.add(newElement);
        }
      }

      // 禁忌・アレルギー両方に登録があるダイアライザコードのリストを作成
      ListUtils.intersection(lstTabooDialyzer, lstAllergyDialyzer).stream().forEach(a -> lstTabooAllergyDialyzer.add(a));
      // mod FNSI-改修内容6618修正 xuty start
      // Set<Integer> setTabooDialyzer = new HashSet<Integer>(lstTabooDialyzer.stream().filter(a -> !lstTabooAllergyDialyzer.contains(a)).collect(Collectors.toList()));
      // Set<Integer> setAllergyDialyzer = new HashSet<Integer>(lstAllergyDialyzer.stream().filter(a -> !lstTabooAllergyDialyzer.contains(a)).collect(Collectors.toList()));
      Set<String> setTabooDialyzer = new HashSet<String>(lstTabooDialyzer.stream().filter(a -> !lstTabooAllergyDialyzer.contains(a)).collect(Collectors.toList()));
      Set<String> setAllergyDialyzer = new HashSet<String>(lstAllergyDialyzer.stream().filter(a -> !lstTabooAllergyDialyzer.contains(a)).collect(Collectors.toList()));
      // mod FNSI-改修内容6618修正 xuty end

      // ダイアライザリストを1件ずつ確認して禁忌・アレルギー情報に一致する場合は名称の前に定冠詞をつける
      //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　Start
      for (int idx = mstDialyzerDtoList.size() - 1; idx >= 0; idx--) {
      //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　End
        MstDialyzerDto mstDialyzer = mstDialyzerDtoList.get(idx);
        // mod FNSI-改修内容6618修正 xuty start
        if (lstTabooAllergyDialyzer.contains(mstDialyzer.getDialyzerCd().toString())) {
        // mod FNSI-改修内容6618修正 xuty end
          // 禁忌・アレルギー
          mstDialyzer.setIsTaboo(true);
          mstDialyzer.setIsAllergy(true);
          mstDialyzerDtoList.set(idx, mstDialyzer);
          // mod FNSI-改修内容6618修正 xuty start
        } else if (setTabooDialyzer.contains(mstDialyzer.getDialyzerCd().toString())) {
          // mod FNSI-改修内容6618修正 xuty end
          // 禁忌
          mstDialyzer.setIsTaboo(true);
          mstDialyzer.setIsAllergy(false);
          mstDialyzerDtoList.set(idx, mstDialyzer);
          // mod FNSI-改修内容6618修正 xuty start
        } else if (setAllergyDialyzer.contains(mstDialyzer.getDialyzerCd().toString())) {
          // mod FNSI-改修内容6618修正 xuty end
          // アレルギー
          mstDialyzer.setIsTaboo(false);
          mstDialyzer.setIsAllergy(true);
          mstDialyzerDtoList.set(idx, mstDialyzer);
        } else {
          mstDialyzer.setIsTaboo(false);
          mstDialyzer.setIsAllergy(false);
        }
        //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　Start
        String EnduseDate = mstDialyzer.getUseEndDate();
        if(TreatDate != null && EnduseDate != null) {
           int res = TreatDate.compareTo(EnduseDate);
           if (res > 0) mstDialyzerDtoList.remove(idx);
        }
        //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　End
      }

      List<Object> objects = new ArrayList<>(mstDialyzerDtoList.size());
      objects.addAll(mstDialyzerDtoList);
      objects = sortData(objects, "mst_dialyzer", facilityCd);
      List<MstDialyzerDto> res = new ArrayList<>();
      for (Object obj : objects) {
        if (obj instanceof MstDialyzerDto) {
          res.add((MstDialyzerDto) obj);
        }
      }

      return res;
    } catch (Exception e) {
      // 禁忌・アレルギー情報取得失敗時はダイアライザマスタをそのまま返却
      return mstDialyzerDtoList;
    }
  }
  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 end

  //#8484　医療材料選択IFのリスト不正　Start
  /**
   * 対象患者の禁忌・アレルギー情報を含めた ダイアライザマスタ一覧(削除済み・期限切れを含む)を取得.
   */
  @Override
  public List<MstDialyzer> findMstDialyzerTabooAllergyIncludeDeleted(String facilityCd, Long patId) {
    SelectOptions selectOptions = SelectOptions.get();
    // ダイアライザ一覧を取得
    MstDialyzer param = new MstDialyzer() {
      {
        setFacilityCd(facilityCd);
      }
    };
    List<MstDialyzer> lstMstDialyzer = mstDialyzerDao.selectAllIncludeDeleted(selectOptions, param);
    // 禁忌・アレルギー情報を付与する.
    return injectTabooAllergyToDialyzer(lstMstDialyzer, facilityCd, patId);
  }

  /**
   * 禁忌・アレルギー情報を付与する.
   */
  private  List<MstDialyzer> injectTabooAllergyToDialyzer( List<MstDialyzer> lstMstDialyzer, String facilityCd, Long patId) {
    SelectOptions selectOptions = SelectOptions.get();
    // 禁忌・アレルギーリスト一覧を取得
    MstTabooAllergy param2 = new MstTabooAllergy() {
      {
        setFacilityCd(facilityCd);
      }
    };
    List<MstTabooAllergy> lstMstTabooAllergy = mstTabooAllergyDao.selectAll(selectOptions, param2);
    // 対象患者のアレルギー情報を取得
    PatMain patMain = patMainDao.selectById(patId);

    try {
      ArrayList<PatInfoTabooAllergy> lstTabooAllergyInfo = new ObjectMapper().readValue(patMain.getTaboo_allergy_info(), new TypeReference<ArrayList<PatInfoTabooAllergy>>() {});

      // 禁忌・アレルギーダイアライザリスト
      // 禁忌ダイアライザリスト
      // アレルギーダイアライザリスト
      ArrayList<String> lstTabooAllergyDialyzer = new ArrayList<String>();
      ArrayList<String> lstTabooDialyzer = new ArrayList<String>();
      ArrayList<String> lstAllergyDialyzer = new ArrayList<String>();

      // 患者の禁忌・アレルギー情報毎にチェックを行い、禁忌ダイアライザリスト・アレルギーダイアライザリストを作成する
      for (PatInfoTabooAllergy patInfoTabooAllergy : lstTabooAllergyInfo) {
        if (patInfoTabooAllergy.getCategory_class().equals("0")) {
          // 対象区分が0:"禁忌・アレルギー" → taboo_allergy_cdの値から禁忌・アレルギーマスタを検索後、ダイアライザコードを取得
          String cd = patInfoTabooAllergy.getTaboo_allergy_cd();
          Optional<MstTabooAllergy> mstTabooAllergy = lstMstTabooAllergy.stream().filter(a -> a.getTabooAllergyCd().equals(cd)).findFirst();
          if (mstTabooAllergy.isPresent()) {
            // 禁忌・アレルギーマスタの詳細項目でclassCd(禁忌対象区分)が"4"(ダイアライザー)のデータを抽出
            ArrayList<MstTabooAllergyDetailInfo> lstTabooAllergyDetailInfo = new ObjectMapper().readValue(mstTabooAllergy.get().getDetailInfo(), new TypeReference<ArrayList<MstTabooAllergyDetailInfo>>() {});
            List<String> lstDialyzerCd = lstTabooAllergyDetailInfo.stream().filter(a -> a.getClassCd().equals("4")).map(a -> a.getCd()).collect(Collectors.toList());
            if (patInfoTabooAllergy.getTaboo_allergy_class().equals("1")) {
              // 禁忌
              lstTabooDialyzer.addAll(lstDialyzerCd);
            } else if (patInfoTabooAllergy.getTaboo_allergy_class().equals("2")) {
              // アレルギー
              lstAllergyDialyzer.addAll(lstDialyzerCd);
            }
          }

        } else if (patInfoTabooAllergy.getCategory_class().equals("4")) {
          // 対象区分が4:ダイアライザー → taboo_allergy_cdの値がそのままダイアライザコード
          if (patInfoTabooAllergy.getTaboo_allergy_class().equals("1")) {
            // 禁忌
            lstTabooDialyzer.add(patInfoTabooAllergy.getTaboo_allergy_cd());
          } else if (patInfoTabooAllergy.getTaboo_allergy_class().equals("2")) {
            // アレルギー
            lstAllergyDialyzer.add(patInfoTabooAllergy.getTaboo_allergy_cd());
          }
        }
      }

      // 禁忌・アレルギー両方に登録があるダイアライザコードのリストを作成
      ListUtils.intersection(lstTabooDialyzer, lstAllergyDialyzer).stream().forEach(a -> lstTabooAllergyDialyzer.add(a));
      Set<String> setTabooDialyzer = new HashSet<String>(lstTabooDialyzer.stream().filter(a -> !lstTabooAllergyDialyzer.contains(a)).collect(Collectors.toList()));
      Set<String> setAllergyDialyzer = new HashSet<String>(lstAllergyDialyzer.stream().filter(a -> !lstTabooAllergyDialyzer.contains(a)).collect(Collectors.toList()));

      // ダイアライザリストを1件ずつ確認して禁忌・アレルギー情報に一致する場合は名称の前に定冠詞をつける
      for (int idx = 0; idx < lstMstDialyzer.size(); idx++) {
        MstDialyzer mstDialyzer = lstMstDialyzer.get(idx);
        if (lstTabooAllergyDialyzer.contains(mstDialyzer.getDialyzerCd().toString())) {
          // 禁忌・アレルギー
          mstDialyzer.setModelNumber("【禁忌・ｱﾚﾙｷﾞｰ】" + mstDialyzer.getModelNumber());
          lstMstDialyzer.set(idx, mstDialyzer);
        } else if (setTabooDialyzer.contains(mstDialyzer.getDialyzerCd().toString())) {
          // 禁忌
          mstDialyzer.setModelNumber("【禁忌】" + mstDialyzer.getModelNumber());
          lstMstDialyzer.set(idx, mstDialyzer);
        } else if (setAllergyDialyzer.contains(mstDialyzer.getDialyzerCd().toString())) {
           // アレルギー
          mstDialyzer.setModelNumber("【ｱﾚﾙｷﾞｰ】" + mstDialyzer.getModelNumber());
          lstMstDialyzer.set(idx, mstDialyzer);
        }
      }
      return lstMstDialyzer;
    } catch (Exception e) {
      // 禁忌・アレルギー情報取得失敗時はダイアライザマスタをそのまま返却
      return lstMstDialyzer;
    }
  }
  //#8484　医療材料選択IFのリスト不正　End
  @Override
  //#8484　医療材料選択IFのリスト不正(#9978対応)　Start
  public Page<MstDialyzer> findMstDialyzerAllIncludeDeleted(Pageable pageable, MstDialyzer params) {
  //#8484　医療材料選択IFのリスト不正(#9978対応)　End
    SelectOptions selectOptions = SelectOptions.get();
    //#8484　医療材料選択IFのリスト不正(#9978対応)　Start
    // ダイアライザ一覧を取得
    List<MstDialyzer> mstDialyzerList = mstDialyzerDao.selectAllIncludeDeleted(selectOptions, params);
    //#8484　医療材料選択IFのリスト不正(#9978対応)　End
    return new PageImpl<>(mstDialyzerList, pageable, selectOptions.getCount());
  }

  /*
   * 病名マスタ
   */
  @Autowired
  private MstDiseaseDao mstDiseaseDao;

  @Override
  public Page<MstDisease> findMstDiseaseAll(Pageable pageable, MstDisease params) {
    SelectOptions selectOptions = SelectOptions.get();

    List<MstDisease> mstDiseaseList = mstDiseaseDao.selectAll(selectOptions, params);
    return new PageImpl<>(mstDiseaseList, pageable, selectOptions.getCount());
  }

  @Override
  public Page<MstDisease> findMstDiseaseAllIncludeDeleted(Pageable pageable, MstDisease params) {
    SelectOptions selectOptions = SelectOptions.get();
    List<MstDisease> mstDiseaseList = mstDiseaseDao.selectAllIncludeDeleted(selectOptions, params);
    /* mod #8592 by zhangruixue 2023-05-11 加算マスタの詳細表示に時間がかかる --start */
    List<String> diseaseCodeList = mstDiseaseDao.selectDiseaseCodeByFacilityCd(params.getFacilityCd());

    // init result list
    List<MstDisease> resultList = new ArrayList<>(mstDiseaseList.size());

    if (!CollectionUtils.isEmpty(mstDiseaseList)) {
      // Extract the code from the set and generate it into a Map set
      Map<Integer,MstDisease> diseaseMap = mstDiseaseList.stream()
        .peek(disease -> {
          if ("1".equals(disease.getIsDel()) || "0".equals(disease.getIsDisp()))
            disease.setDiseaseName("【削除済み】" + disease.getDiseaseName());
        })
        .collect(Collectors.toMap(MstDisease::getDiseaseCd, Function.identity()));

      // find the code by selector's order, remove form the Map, add it into the result.
      for (String code : diseaseCodeList) {
        MstDisease removeEntity = diseaseMap.remove(Integer.parseInt(code));
        if (removeEntity != null)  resultList.add(removeEntity);
      }

      // the remaining record is the deleted record
      if (!diseaseMap.isEmpty()) resultList.addAll(diseaseMap.values());
    }
    return new PageImpl<>(resultList, pageable, selectOptions.getCount());
    /* mod #8592 by zhangruixue 2023-05-11 --end */
  }

  /* add #9482 患者情報画面/新規患者登録の表示が遅い。2023-09-21 by liumx --start */
  @Override
  public List<MstDisease> getMstDiseaseByCds(Integer[] diseaseCds) {
    return mstDiseaseDao.getMstDiseaseByCds(diseaseCds);
  }
  /* add #9482 患者情報画面/新規患者登録の表示が遅い。2023-09-21 by liumx --end */

  /*
   * 医療材料分類マスタ
   */
  @Autowired
  private MstEquipmentClassDao mstEquipmentClassDao;

  @Override
  public Page<MstEquipmentClass> findMstEquipmentClassAll(Pageable pageable, MstEquipmentClass params) {
    SelectOptions selectOptions = SelectOptions.get();
    List<MstEquipmentClass> mstEquipmentClassList = null;
    try{
      mstEquipmentClassList = mstEquipmentClassDao.selectAll(selectOptions, params);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (params != null && params.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(params.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    }
    return new PageImpl<>(mstEquipmentClassList, pageable, selectOptions.getCount());
  }

  @Override
  public Page<MstEquipmentClass> findMstEquipmentClassAllIncludeDeleted(Pageable pageable, MstEquipmentClass params) {
    SelectOptions selectOptions = SelectOptions.get();

    List<MstEquipmentClass> mstEquipmentClassList = mstEquipmentClassDao.selectAllIncludeDeleted(selectOptions, params);
    return new PageImpl<>(mstEquipmentClassList, pageable, selectOptions.getCount());
  }

  /*
   * 医療材料マスタ
   */
  @Autowired
  private MstEquipmentDao mstEquipmentDao;

  @Override
  public Page<MstEquipment> findMstEquipmentAll(Pageable pageable, MstEquipment params) {
    SelectOptions selectOptions = SelectOptions.get();

    List<MstEquipment> mstEquipmentList = mstEquipmentDao.selectAll(selectOptions, params);
    return new PageImpl<>(mstEquipmentList, pageable, selectOptions.getCount());
  }

  // FNSI-修正 マスタ削除の対応 chen add start
  @Override
  public Page<MstEquipment> findMstEquipmentAllNoDel(Pageable pageable, MstEquipment params) {
    SelectOptions selectOptions = SelectOptions.get();

    List<MstEquipment> mstEquipmentList = mstEquipmentDao.selectAllNoDel(selectOptions, params);
    return new PageImpl<>(mstEquipmentList, pageable, selectOptions.getCount());
  }
// FNSI-修正 マスタ削除の対応 chen add end

  @Override
  public MstEquipment findMstEquipmentByCd(String cd) {
    MstEquipment mstEquipment = null;
    if (StrUtils.isNumber(cd)) {
      int equipmentCd = Integer.parseInt(cd);
      mstEquipment = mstEquipmentDao.selectByEquipmentCd(equipmentCd);
    }
    return mstEquipment;
  }

  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 start
  @Override
  // mod FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 start
  // public List<MstEquipment> findMstEquipmentTabooAllergy(String facilityCd, Long patId, List<Integer> typeCdList){
  //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　Start
  public List<MstEquipmentDto> findMstEquipmentTabooAllergy(String facilityCd, Long patId, List<Integer> typeCdList, String TreatDate, boolean... isDelFlg) {
    //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　End
    // mod FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 end
    SelectOptions selectOptions = SelectOptions.get();
    // 医療材料リスト一覧を取得
    MstEquipment param = new MstEquipment()
    {
      {
        setFacilityCd(facilityCd);
      }
    };
    List<MstEquipment> lstMstEquipment = new ArrayList<MstEquipment>();
    List<MstEquipmentDto> mstEquipmentDtoList = new ArrayList<>();
    // mod FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 start
    if (isDelFlg.length == 0) {
      if (typeCdList.size() == 0) {
        lstMstEquipment = mstEquipmentDao.selectAll(selectOptions, param);
      } else {
        lstMstEquipment = mstEquipmentDao.selectByClassType(selectOptions, param, typeCdList);
      }
    } else {
      lstMstEquipment = mstEquipmentDao.selectEquipmentAllergy(selectOptions, param);
    }
    // if (typeCdList.size() == 0) {
    //   lstMstEquipment = mstEquipmentDao.selectAll(selectOptions, param);
    // } else {
    //   lstMstEquipment = mstEquipmentDao.selectByClassType(selectOptions, param, typeCdList);
    // }
    // mod FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 end


    // 禁忌・アレルギーリスト一覧を取得
    MstTabooAllergy param2 = new MstTabooAllergy() {
      {
        setFacilityCd(facilityCd);
      }
    };
    List<MstTabooAllergy> lstMstTabooAllergy = mstTabooAllergyDao.selectAll(selectOptions, param2);

    MstEquipmentClass paramClass = new MstEquipmentClass() {
      {
        setFacilityCd(facilityCd);
      }
    };

    List<MstEquipmentClass> mstEquipmentClassList = mstEquipmentClassDao.selectAllIncludeDeleted(selectOptions, paramClass);

    //add 9706 ljx start
    //???患者の場合、patIdが「-1」である、判断追加、後の処理を実行しない。
    if(-1 == patId){

      if (lstMstEquipment != null && !lstMstEquipment.isEmpty()) {
        for (MstEquipment element : lstMstEquipment) {
          MstEquipmentDto newElement = new MstEquipmentDto();
          BeanUtils.copyProperties(element, newElement);
          mstEquipmentDtoList.add(newElement);
        }
        for (MstEquipmentDto mstEquipmentDto : mstEquipmentDtoList) {
          mstEquipmentDto.setIsTaboo(false);
          mstEquipmentDto.setIsAllergy(false);
          Integer classCd = mstEquipmentDto.getClassCd();
          Optional<MstEquipmentClass> found = mstEquipmentClassList.stream().filter(data -> data.getClassCd().equals(classCd)).findFirst();
          if (found.isPresent()) {
            MstEquipmentClass mstEquipmentClass = found.get();
            String classType = "0";
            if (mstEquipmentClass.getClassType() != null) {
              classType = String.valueOf((int)mstEquipmentClass.getClassType().doubleValue());
            }
            mstEquipmentDto.setClassType(classType);
          } else {
            mstEquipmentDto.setClassType("0");
          }
        }
      }

      List<Object> objects = new ArrayList<>(mstEquipmentDtoList.size());
      objects.addAll(mstEquipmentDtoList);
      objects = sortData(objects, "mst_equipment", facilityCd);
      List<MstEquipmentDto> res = new ArrayList<>();
      for (Object obj : objects) {
        if (obj instanceof MstEquipmentDto) {
          res.add((MstEquipmentDto) obj);
        }
      }

      return res;
    }
    //add 9706 ljx end
    // 対象患者のアレルギー情報を取得
    PatMain patMain = patMainDao.selectById(patId);

    try {
      /* modify by shiyw 2023-04-10 [#8271] jdk8->aws jdk17 --start */
      //ArrayList<PatInfoTabooAllergy> lstTabooAllergyInfo = new ObjectMapper().readValue(patMain.getTaboo_allergy_info(), new TypeReference<List<PatInfoTabooAllergy>>() {});
      ArrayList<PatInfoTabooAllergy> lstTabooAllergyInfo = new ObjectMapper().readValue(patMain.getTaboo_allergy_info(), new TypeReference<ArrayList<PatInfoTabooAllergy>>() {});
      /* modify by shiyw 2023-04-10 [#8271] jdk8->aws jdk17 --end */

      // mod FNSI-改修内容6618修正 xuty start
      // 禁忌・アレルギー医療材料リスト
      // ArrayList<Integer> lstTabooAllergyEquipment = new ArrayList<Integer>();
      // 禁忌医療材料リスト
      // ArrayList<Integer> lstTabooEquipment = new ArrayList<Integer>();
      // アレルギー医療材料リスト
      // ArrayList<Integer> lstAllergyEquipment = new ArrayList<Integer>();
      ArrayList<String> lstTabooAllergyEquipment = new ArrayList<String>();
      ArrayList<String> lstTabooEquipment = new ArrayList<String>();
      ArrayList<String> lstAllergyEquipment = new ArrayList<String>();
      // mod FNSI-改修内容6618修正 xuty end

      // 患者の禁忌・アレルギー情報毎にチェックを行い、禁忌医療材料リスト・アレルギー医療材料リストを作成する
      for (PatInfoTabooAllergy patInfoTabooAllergy : lstTabooAllergyInfo) {
        if (patInfoTabooAllergy.getCategory_class().equals("0")) {
          // 対象区分が0:"禁忌・アレルギー" → taboo_allergy_cdの値から禁忌・アレルギーマスタを検索後、医療材料コードを取得
          // mod FNSI-改修内容6618修正 xuty start
          // Integer cd = patInfoTabooAllergy.getTaboo_allergy_cd();
          String cd = patInfoTabooAllergy.getTaboo_allergy_cd();
          // mod FNSI-改修内容6618修正 xuty end
          Optional<MstTabooAllergy> mstTabooAllergy = lstMstTabooAllergy.stream().filter(a -> a.getTabooAllergyCd().equals(cd)).findFirst();
          if (mstTabooAllergy.isPresent()) {
            // 禁忌・アレルギーマスタの詳細項目でclassCd(禁忌対象区分)が"3"(医療材料)のデータを抽出
            /* modify by shiyw 2023-04-10 [#8271] jdk8->aws jdk17 --start */
            //ArrayList<MstTabooAllergyDetailInfo> lstTabooAllergyDetailInfo = new ObjectMapper().readValue(mstTabooAllergy.get().getDetailInfo(), new TypeReference<List<MstTabooAllergyDetailInfo>>() {});
            ArrayList<MstTabooAllergyDetailInfo> lstTabooAllergyDetailInfo = new ObjectMapper().readValue(mstTabooAllergy.get().getDetailInfo(), new TypeReference<ArrayList<MstTabooAllergyDetailInfo>>() {});
            /* modify by shiyw 2023-04-10 [#8271] jdk8->aws jdk17 --end */

            // mod FNSI-改修内容6618修正 xuty start
            // List<Integer> lstEquipmentCd = lstTabooAllergyDetailInfo.stream().filter(a -> a.getClassCd().equals("3")).map(a -> a.getCd()).collect(Collectors.toList());
            List<String> lstEquipmentCd = lstTabooAllergyDetailInfo.stream().filter(a -> a.getClassCd().equals("3")).map(a -> a.getCd()).collect(Collectors.toList());
            // mod FNSI-改修内容6618修正 xuty end
            if (patInfoTabooAllergy.getTaboo_allergy_class().equals("1")) {
              // 禁忌
              lstTabooEquipment.addAll(lstEquipmentCd);
            } else if (patInfoTabooAllergy.getTaboo_allergy_class().equals("2")) {
              // アレルギー
              lstAllergyEquipment.addAll(lstEquipmentCd);
            }
          }

        } else if (patInfoTabooAllergy.getCategory_class().equals("3")) {
          // 対象区分が3:医療材料 → taboo_allergy_cdの値がそのまま医療材料コード
          if (patInfoTabooAllergy.getTaboo_allergy_class().equals("1")) {
            // 禁忌
            lstTabooEquipment.add(patInfoTabooAllergy.getTaboo_allergy_cd());
          } else if (patInfoTabooAllergy.getTaboo_allergy_class().equals("2")) {
            // アレルギー
            lstAllergyEquipment.add(patInfoTabooAllergy.getTaboo_allergy_cd());
          }
        }
      }

      // 禁忌・アレルギー両方に登録がある医療材料コードのリストを作成
      ListUtils.intersection(lstTabooEquipment, lstAllergyEquipment).stream().forEach(a -> lstTabooAllergyEquipment.add(a));
      // mod FNSI-改修内容6618修正 xuty start
      // Set<Integer> setTabooMedicine = new HashSet<Integer>(lstTabooEquipment.stream().filter(a -> !lstTabooAllergyEquipment.contains(a)).collect(Collectors.toList()));
      // Set<Integer> setAllergyMedicine = new HashSet<Integer>(lstAllergyEquipment.stream().filter(a -> !lstTabooAllergyEquipment.contains(a)).collect(Collectors.toList()));
      Set<String> setTabooMedicine = new HashSet<String>(lstTabooEquipment.stream().filter(a -> !lstTabooAllergyEquipment.contains(a)).collect(Collectors.toList()));
      Set<String> setAllergyMedicine = new HashSet<String>(lstAllergyEquipment.stream().filter(a -> !lstTabooAllergyEquipment.contains(a)).collect(Collectors.toList()));
      // mod FNSI-改修内容6618修正 xuty end

      if (lstMstEquipment != null && !lstMstEquipment.isEmpty()) {
        for (MstEquipment element : lstMstEquipment) {
          MstEquipmentDto newElement = new MstEquipmentDto();
          BeanUtils.copyProperties(element, newElement);
          mstEquipmentDtoList.add(newElement);
        }
      }
      // 医療材料リストを1件ずつ確認して禁忌・アレルギー情報に一致する場合は名称の前に定冠詞をつける
      for (int idx = mstEquipmentDtoList.size() - 1; idx >= 0; idx--) {
        MstEquipmentDto mstEquipment = mstEquipmentDtoList.get(idx);
        Integer classCd = mstEquipment.getClassCd();
        Optional<MstEquipmentClass> found = mstEquipmentClassList.stream().filter(data -> data.getClassCd().equals(classCd)).findFirst();
        if (found.isPresent()) {
          MstEquipmentClass mstEquipmentClass = found.get();
          String classType = "0";
          if(mstEquipmentClass.getClassType() != null){
            classType = String.valueOf((int)mstEquipmentClass.getClassType().doubleValue());
          }
          mstEquipment.setClassType(classType);
        } else {
          mstEquipment.setClassType("0");
        }

        if (lstTabooAllergyEquipment.contains(mstEquipment.getEquipmentCd().toString())) {
          // 禁忌・アレルギー
          mstEquipment.setIsTaboo(true);
          mstEquipment.setIsAllergy(true);
          mstEquipmentDtoList.set(idx, mstEquipment);
        } else if (setTabooMedicine.contains(mstEquipment.getEquipmentCd().toString())) {
          // 禁忌
          mstEquipment.setIsTaboo(true);
          mstEquipment.setIsAllergy(false);
          mstEquipmentDtoList.set(idx, mstEquipment);
        } else if (setAllergyMedicine.contains(mstEquipment.getEquipmentCd().toString())) {
          // アレルギー
          mstEquipment.setIsTaboo(false);
          mstEquipment.setIsAllergy(true);
          mstEquipmentDtoList.set(idx, mstEquipment);
        } else {
          mstEquipment.setIsTaboo(false);
          mstEquipment.setIsAllergy(false);
        }
        String endUseDate = mstEquipment.getUseEndDate();
        if(TreatDate != null && endUseDate != null) {
           int res = TreatDate.compareTo(endUseDate);
           if (res > 0) mstEquipmentDtoList.remove(idx);
        }
      }
      List<Object> objects = new ArrayList<>(mstEquipmentDtoList.size());
      objects.addAll(mstEquipmentDtoList);
      objects = sortData(objects, "mst_equipment", facilityCd);
      List<MstEquipmentDto> res = new ArrayList<>();
      for (Object obj : objects) {
        if (obj instanceof MstEquipmentDto) {
          res.add((MstEquipmentDto) obj);
        }
      }

      return res;
    } catch (Exception e) {
      // 禁忌・アレルギー情報取得失敗時は薬剤マスタをそのまま返却
      return mstEquipmentDtoList;
    }
  }
  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 end

  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240909 start
  @Override
    //#8484　医療材料選択IFのリスト不正(#9978対応)　Start
    public Page<MstEquipmentExtends> findMstEquipmentAllIncludeDeleted(Pageable pageable, MstEquipment params) {
    //#8484　医療材料選択IFのリスト不正(#9978対応)　End
    SelectOptions selectOptions = SelectOptions.get();
    //#8484　医療材料選択IFのリスト不正(#9978対応)　Start
    // 医療材料リスト一覧を取得
    List<MstEquipment> mstEquipmentList = mstEquipmentDao.selectAllIncludeDeleted(selectOptions, params);

    MstEquipmentClass paramClass = new MstEquipmentClass() {
      {
        setFacilityCd(params.getFacilityCd());
      }
    };

    List<MstEquipmentClass> mstEquipmentClassList = mstEquipmentClassDao.selectAllIncludeDeleted(selectOptions, paramClass);
    List<MstEquipmentExtends> mstEquipmentExtendsList = new ArrayList<>();
      if (mstEquipmentList != null && !mstEquipmentList.isEmpty()) {
        for (MstEquipment element : mstEquipmentList) {
          MstEquipmentExtends newElement = new MstEquipmentExtends();
          BeanUtils.copyProperties(element, newElement);
          mstEquipmentExtendsList.add(newElement);
        }
        for (MstEquipmentExtends mstEquipmentExtends : mstEquipmentExtendsList) {
          Integer classCd = mstEquipmentExtends.getClassCd();
          Optional<MstEquipmentClass> found = mstEquipmentClassList.stream().filter(data -> data.getClassCd().equals(classCd)).findFirst();
          if (found.isPresent()) {
            MstEquipmentClass mstEquipmentClass = found.get();
            String classType = "0";
            if (mstEquipmentClass.getClassType() != null) {
              classType = String.valueOf((int)mstEquipmentClass.getClassType().doubleValue());
            }
            mstEquipmentExtends.setClassType(classType);
          } else {
            mstEquipmentExtends.setClassType("0");
          }
        }
      }

   //#8484　医療材料選択IFのリスト不正(#9978対応)　End
    return new PageImpl<>(mstEquipmentExtendsList, pageable, selectOptions.getCount());
  }
  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240909 end

  //#8484　医療材料選択IFのリスト不正　Start
  /**
   * 対象患者の禁忌・アレルギー情報を含めた 医療材料マスタ一覧(削除済み・期限切れを含む)を取得.
   */
  @Override
  public List<MstEquipment> findMstEquipmentTabooAllergyIncludeDeleted(String facilityCd, Long patId, List<Integer> typeCdList, boolean... isDelFlg) {
    SelectOptions selectOptions = SelectOptions.get();
    // 医療材料リスト一覧を取得
    MstEquipment param = new MstEquipment()
    {
      {
        setFacilityCd(facilityCd);
      }
    };
    List<MstEquipment> lstMstEquipment = new ArrayList<MstEquipment>();
    // 期限切れ・削除済を含む医療材料をmst_selectorによる並び順を反映して取得する
    lstMstEquipment = mstEquipmentDao.selectAllIncludeDeleted(selectOptions, param);
    // 禁忌・アレルギー情報を付与する
    return injectTabooAllergyToEquipment(lstMstEquipment, facilityCd, patId);
  }

  /**
   * 禁忌・アレルギー情報を付与する.
   */
  private List<MstEquipment> injectTabooAllergyToEquipment(List<MstEquipment> lstMstEquipment, String facilityCd, Long patId) {

    EventLogMessage eventLogMessage = new EventLogMessage();
    try {
      SelectOptions selectOptions = SelectOptions.get();
      // 禁忌・アレルギーリスト一覧を取得
      MstTabooAllergy param2 = new MstTabooAllergy() {
        {
          setFacilityCd(facilityCd);
        }
      };
      List<MstTabooAllergy> lstMstTabooAllergy = mstTabooAllergyDao.selectAll(selectOptions, param2);
      // 対象患者のアレルギー情報を取得
      PatMain patMain = patMainDao.selectById(patId);
      ArrayList<PatInfoTabooAllergy> lstTabooAllergyInfo = new ObjectMapper().readValue(patMain.getTaboo_allergy_info(), new TypeReference<ArrayList<PatInfoTabooAllergy>>() {});
      ArrayList<String> lstTabooAllergyEquipment = new ArrayList<String>();
      ArrayList<String> lstTabooEquipment = new ArrayList<String>();
      ArrayList<String> lstAllergyEquipment = new ArrayList<String>();

      // 患者の禁忌・アレルギー情報毎にチェックを行い、禁忌医療材料リスト・アレルギー医療材料リストを作成する
      for (PatInfoTabooAllergy patInfoTabooAllergy : lstTabooAllergyInfo) {
        if (patInfoTabooAllergy.getCategory_class().equals("0")) {
          // 対象区分が0:"禁忌・アレルギー" → taboo_allergy_cdの値から禁忌・アレルギーマスタを検索後、医療材料コードを取得
          String cd = patInfoTabooAllergy.getTaboo_allergy_cd();
          Optional<MstTabooAllergy> mstTabooAllergy = lstMstTabooAllergy.stream().filter(a -> a.getTabooAllergyCd().equals(cd)).findFirst();
          if (mstTabooAllergy.isPresent()) {
            // 禁忌・アレルギーマスタの詳細項目でclassCd(禁忌対象区分)が"3"(医療材料)のデータを抽出
            ArrayList<MstTabooAllergyDetailInfo> lstTabooAllergyDetailInfo = new ObjectMapper().readValue(mstTabooAllergy.get().getDetailInfo(), new TypeReference<ArrayList<MstTabooAllergyDetailInfo>>() {});
            List<String> lstEquipmentCd = lstTabooAllergyDetailInfo.stream().filter(a -> a.getClassCd().equals("3")).map(a -> a.getCd()).collect(Collectors.toList());

            if (patInfoTabooAllergy.getTaboo_allergy_class().equals("1")) {
              // 禁忌
              lstTabooEquipment.addAll(lstEquipmentCd);
            } else if (patInfoTabooAllergy.getTaboo_allergy_class().equals("2")) {
              // アレルギー
              lstAllergyEquipment.addAll(lstEquipmentCd);
            }
          }
        } else if (patInfoTabooAllergy.getCategory_class().equals("3")) {
          // 対象区分が3:医療材料 → taboo_allergy_cdの値がそのまま医療材料コード
          if (patInfoTabooAllergy.getTaboo_allergy_class().equals("1")) {
            // 禁忌
            lstTabooEquipment.add(patInfoTabooAllergy.getTaboo_allergy_cd());
          } else if (patInfoTabooAllergy.getTaboo_allergy_class().equals("2")) {
            // アレルギー
            lstAllergyEquipment.add(patInfoTabooAllergy.getTaboo_allergy_cd());
          }
        }
      }

      // 禁忌・アレルギー両方に登録がある医療材料コードのリストを作成
      ListUtils.intersection(lstTabooEquipment, lstAllergyEquipment).stream().forEach(a -> lstTabooAllergyEquipment.add(a));
      Set<String> setTabooMedicine = new HashSet<String>(lstTabooEquipment.stream().filter(a -> !lstTabooAllergyEquipment.contains(a)).collect(Collectors.toList()));
      Set<String> setAllergyMedicine = new HashSet<String>(lstAllergyEquipment.stream().filter(a -> !lstTabooAllergyEquipment.contains(a)).collect(Collectors.toList()));

      // 医療材料リストを1件ずつ確認して禁忌・アレルギー情報に一致する場合は名称の前に接頭辞をつける
      for (int idx = 0; idx < lstMstEquipment.size(); idx++) {
        MstEquipment mstEquipment = lstMstEquipment.get(idx);
        if (lstTabooAllergyEquipment.contains(mstEquipment.getEquipmentCd().toString())) {
          // 禁忌・アレルギー
          mstEquipment.setEquipmentName("【禁忌・ｱﾚﾙｷﾞｰ】" + mstEquipment.getEquipmentName());
          lstMstEquipment.set(idx, mstEquipment);
        } else if (setTabooMedicine.contains(mstEquipment.getEquipmentCd().toString())) {
          // 禁忌
          mstEquipment.setEquipmentName("【禁忌】" + mstEquipment.getEquipmentName());
          lstMstEquipment.set(idx, mstEquipment);
        } else if (setAllergyMedicine.contains(mstEquipment.getEquipmentCd().toString())) {
          // アレルギー
          mstEquipment.setEquipmentName("【ｱﾚﾙｷﾞｰ】" + mstEquipment.getEquipmentName());
          lstMstEquipment.set(idx, mstEquipment);
        }
      }

    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // EventLogMessage eventLogMessage = new EventLogMessage(); // TODO: 必ず回復すること
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      if (!StringUtils.isEmpty(facilityCd)) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      // 禁忌・アレルギー情報取得失敗時は医療材料マスタをそのまま返却
      return lstMstEquipment;
    }
    return lstMstEquipment;
  }
  //#8484　医療材料選択IFのリスト不正　End
  /*
   * 医療材料セットマスタ
   */
  @Autowired
  private MstEquipmentSetDao mstEquipmentSetDao;

  @Override
  public Page<MstEquipmentSet> findMstEquipmentSetAll(Pageable pageable, MstEquipmentSet params) {
    SelectOptions selectOptions = SelectOptions.get();

    List<MstEquipmentSet> mstEquipmentSetList = mstEquipmentSetDao.selectAll(selectOptions, params);
    return new PageImpl<>(mstEquipmentSetList, pageable, selectOptions.getCount());
  }

  @Override
  public List<MstEquipmentSet> findMstEquipmentSetAllTabooAllergy(String facilityCd, Long patId) {
    SelectOptions selectOptions = SelectOptions.get();
    MstEquipmentSet param = new MstEquipmentSet() {
      {
        setFacilityCd(facilityCd);
      }
    };
    // 医療材料セットリスト一覧を取得
    List<MstEquipmentSet> mstEquipmentSetList = mstEquipmentSetDao.selectAll(selectOptions, param);
    // 禁忌・アレルギーリスト一覧を取得
    MstTabooAllergy param2 = new MstTabooAllergy() {
      {
        setFacilityCd(facilityCd);
      }
    };
    List<MstTabooAllergy> lstMstTabooAllergy = mstTabooAllergyDao.selectAll(selectOptions, param2);
    //add 9706 ljx start
    //???患者の場合、patIdが「-1」である、判断追加、後の処理を実行しない。
    if(-1 == patId){
      return mstEquipmentSetList;
    }
    //add 9706 ljx end
    // 対象患者のアレルギー情報を取得
    PatMain patMain = patMainDao.selectById(patId);

    try {
      // 禁忌アレルギー医療材料を含む医療材料セット名称に接頭語を付与
      prefixEquipmentSetTabooAllergy(facilityCd, mstEquipmentSetList, lstMstTabooAllergy, patMain);

      return mstEquipmentSetList;
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
      // 禁忌・アレルギー情報取得失敗時は医療材料セットマスタをそのまま返却
      return mstEquipmentSetList;
    }
  }

  @Override
  public List<MstEquipmentSet> findMstEquipmentSetWithDeleted(String facilityCd, Long patId) {
    SelectOptions selectOptions = SelectOptions.get();
    MstEquipmentSet param = new MstEquipmentSet() {
      {
        setFacilityCd(facilityCd);
      }
    };
    // 医療材料セットリスト一覧を取得
    List<MstEquipmentSet> mstEquipmentSetList = mstEquipmentSetDao.selectWithDeleted(selectOptions, param);
    // 禁忌・アレルギーリスト一覧を取得
    MstTabooAllergy param2 = new MstTabooAllergy() {
      {
        setFacilityCd(facilityCd);
      }
    };
    List<MstTabooAllergy> lstMstTabooAllergy = mstTabooAllergyDao.selectAll(selectOptions, param2);
    //add 9706 ljx start
    //???患者の場合、patIdが「-1」である、判断追加、後の処理を実行しない。
    if(-1 == patId){
      return mstEquipmentSetList;
    }
    //add 9706 ljx end
    // 対象患者のアレルギー情報を取得
    PatMain patMain = patMainDao.selectById(patId);

    try {
      // 禁忌アレルギー医療材料を含む医療材料セット名称に接頭語を付与
      prefixEquipmentSetTabooAllergy(facilityCd, mstEquipmentSetList, lstMstTabooAllergy, patMain);

      return mstEquipmentSetList;
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
      // 禁忌・アレルギー情報取得失敗時は医療材料セットマスタをそのまま返却
      return mstEquipmentSetList;
    }
  }

  /**
   * 医療材料セットマスタのリストに対し、禁忌アレルギー医療材料を含む医療材料セット名称に接頭語を付与します。
   *
   * @param facilityCd          施設コード
   * @param mstEquipmentSetList 医療材料セットマスタのリスト
   * @param mstTabooAllergyList 禁忌・アレルギーマスタのリスト
   * @param patMain             患者情報
   */
  private void prefixEquipmentSetTabooAllergy(String facilityCd, List<MstEquipmentSet> mstEquipmentSetList, List<MstTabooAllergy> mstTabooAllergyList, PatMain patMain) throws Exception {
    // 患者の禁忌・アレルギー情報
    ArrayList<PatInfoTabooAllergy> patInfoTabooAllergyList = new ObjectMapper().readValue(patMain.getTaboo_allergy_info(), new TypeReference<ArrayList<PatInfoTabooAllergy>>() {});

    // 禁忌医療材料リスト
    ArrayList<String> tabooEquipmentList = new ArrayList<String>();
    // アレルギー医療材料リスト
    ArrayList<String> allergyEquipmentList = new ArrayList<String>();
    // 禁忌ダイアライザリスト
    ArrayList<String> tabooDialyzerList = new ArrayList<String>();
    // アレルギーダイアライザリスト
    ArrayList<String> allergyDialyzerList = new ArrayList<String>();

    // 患者の禁忌・アレルギー情報毎にチェックを行い、禁忌医療材料/禁忌ダイアライザリスト・アレルギー医療材料/アレルギーダイアライザリストを作成する
    for (PatInfoTabooAllergy patInfoTabooAllergy : patInfoTabooAllergyList) {

      if (patInfoTabooAllergy.getCategory_class().equals("0")) {
        // 対象区分が0:"禁忌・アレルギー" → taboo_allergy_cdの値から禁忌・アレルギーマスタを検索後、医療材料コード・ダイアライザコードを取得
        String cd = patInfoTabooAllergy.getTaboo_allergy_cd();
        Optional<MstTabooAllergy> mstTabooAllergy = mstTabooAllergyList.stream().filter(a -> a.getTabooAllergyCd().equals(cd)).findFirst();
        if (mstTabooAllergy.isPresent()) {
          ArrayList<MstTabooAllergyDetailInfo> tabooAllergyDetailInfoList = new ObjectMapper().readValue(mstTabooAllergy.get().getDetailInfo(), new TypeReference<ArrayList<MstTabooAllergyDetailInfo>>() {});

          // 禁忌・アレルギーマスタの詳細項目でclassCd(禁忌対象区分)が"3"(医療材料)のcd(禁忌対象コード)を取得し、医療材料コードリストを作成する
          List<String> equipmentCdList = tabooAllergyDetailInfoList.stream().filter(a -> a.getClassCd().equals("3")).map(a -> a.getCd()).collect(Collectors.toList());
          // 禁忌・アレルギーマスタの詳細項目でclassCd(禁忌対象区分)が"4"(ダイアライザ)のcd(禁忌対象コード)を取得し、ダイアライザコードリストを作成する
          List<String> dialyzerCdList = tabooAllergyDetailInfoList.stream().filter(a -> a.getClassCd().equals("4")).map(a -> a.getCd()).collect(Collectors.toList());

          if (patInfoTabooAllergy.getTaboo_allergy_class().equals("1")) {
            // 禁忌医療材料リストに追加
            tabooEquipmentList.addAll(equipmentCdList);
            // 禁忌ダイアライザリストに追加
            tabooDialyzerList.addAll(dialyzerCdList);
          } else if (patInfoTabooAllergy.getTaboo_allergy_class().equals("2")) {
            // アレルギー医療材料リストに追加
            allergyEquipmentList.addAll(equipmentCdList);
            // アレルギーダイアライザリストに追加
            allergyDialyzerList.addAll(dialyzerCdList);
          }
        }

      } else if (patInfoTabooAllergy.getCategory_class().equals("3")) {
        // 対象区分が3:医療材料 → taboo_allergy_cdの値がそのまま医療材料コード
        if (patInfoTabooAllergy.getTaboo_allergy_class().equals("1")) {
          // 禁忌医療材料リストに追加
          tabooEquipmentList.add(patInfoTabooAllergy.getTaboo_allergy_cd());
        } else if (patInfoTabooAllergy.getTaboo_allergy_class().equals("2")) {
          // アレルギー医療材料リストに追加
          allergyEquipmentList.add(patInfoTabooAllergy.getTaboo_allergy_cd());
        }

      } else if (patInfoTabooAllergy.getCategory_class().equals("4")) {
        // 対象区分が4:ダイアライザ → taboo_allergy_cdの値がそのままダイアライザコード
        if (patInfoTabooAllergy.getTaboo_allergy_class().equals("1")) {
          // 禁忌ダイアライザリストに追加
          tabooDialyzerList.add(patInfoTabooAllergy.getTaboo_allergy_cd());
        } else if (patInfoTabooAllergy.getTaboo_allergy_class().equals("2")) {
          // アレルギーダイアライザリストに追加
          allergyDialyzerList.add(patInfoTabooAllergy.getTaboo_allergy_cd());
        }
      }
    }

    // 禁忌医療材料セットリスト
    ArrayList<String> tabooEquipmentSetList = new ArrayList<String>();
    // アレルギー医療材料セットリスト
    ArrayList<String> allergyEquipmentSetList = new ArrayList<String>();

    if (tabooEquipmentList.size() > 0) {
      // 禁忌医療材料が含まれる医療材料セットを取得し、禁忌医療材料セットリストに追加
      mstEquipmentSetDao.selectByEquipmentCdList(facilityCd, 0, tabooEquipmentList).stream().forEach(a -> tabooEquipmentSetList.add(a.getEquipmentSetCd().toString()));
    }

    if (tabooDialyzerList.size() > 0) {
      // 禁忌ダイアライザが含まれる医療材料セットを取得し、禁忌医療材料セットリストに追加
      mstEquipmentSetDao.selectByEquipmentCdList(facilityCd, 1, tabooDialyzerList).stream().forEach(a -> tabooEquipmentSetList.add(a.getEquipmentSetCd().toString()));
    }

    if (allergyEquipmentList.size() > 0) {
      // アレルギー医療材料が含まれる医療材料セットを取得し、アレルギー医療材料セットリストに追加
      mstEquipmentSetDao.selectByEquipmentCdList(facilityCd, 0, allergyEquipmentList).stream().forEach(a -> allergyEquipmentSetList.add(a.getEquipmentSetCd().toString()));
    }

    if (allergyDialyzerList.size() > 0) {
      // アレルギーダイアライザが含まれる医療材料セットを取得し、アレルギー医療材料セットリストに追加
      mstEquipmentSetDao.selectByEquipmentCdList(facilityCd, 1, allergyDialyzerList).stream().forEach(a -> allergyEquipmentSetList.add(a.getEquipmentSetCd().toString()));
    }

    if (tabooEquipmentSetList.size() > 0 || allergyEquipmentSetList.size() > 0) {
      // 禁忌・アレルギー医療材料セットリスト
      ArrayList<String> tabooAllergyEquipmentSetList = new ArrayList<String>();

      // 禁忌・アレルギー両方に登録がある医療材料セットコードのリストを作成
      ListUtils.intersection(tabooEquipmentSetList, allergyEquipmentSetList).stream().forEach(a -> tabooAllergyEquipmentSetList.add(a));
      // 禁忌のみ登録がある医療材料セットコードのリスト(重複無し)を作成
      Set<String> tabooEquipmentSetSet = new HashSet<String>(tabooEquipmentSetList.stream().filter(a -> !tabooAllergyEquipmentSetList.contains(a)).collect(Collectors.toList()));
      // アレルギーのみ登録がある医療材料セットコードのリスト(重複無し)を作成
      Set<String> allergyEquipmentSetSet = new HashSet<String>(allergyEquipmentSetList.stream().filter(a -> !tabooAllergyEquipmentSetList.contains(a)).collect(Collectors.toList()));

      // 医療材料セットリストを1件ずつ確認して禁忌・アレルギー情報に一致する場合は名称の前に定冠詞をつける
      for (int idx = 0; idx < mstEquipmentSetList.size(); idx++) {
        MstEquipmentSet mstEquipmentSet = mstEquipmentSetList.get(idx);
        if (tabooAllergyEquipmentSetList.contains(mstEquipmentSet.getEquipmentSetCd().toString())) {
          // 禁忌・アレルギー
          mstEquipmentSetList.get(idx).setEquipmentSetName("【禁忌・ｱﾚﾙｷﾞｰ】" + mstEquipmentSet.getEquipmentSetName());
        } else if (tabooEquipmentSetSet.contains(mstEquipmentSet.getEquipmentSetCd().toString())) {
          // 禁忌
          mstEquipmentSetList.get(idx).setEquipmentSetName("【禁忌】" + mstEquipmentSet.getEquipmentSetName());
        } else if (allergyEquipmentSetSet.contains(mstEquipmentSet.getEquipmentSetCd().toString())) {
          // アレルギー
          mstEquipmentSetList.get(idx).setEquipmentSetName("【ｱﾚﾙｷﾞｰ】" + mstEquipmentSet.getEquipmentSetName());
        }
      }
    }
  }

  /*
   * 施設マスタ
   */
  @Autowired
  private MstFacilityDao mstFacilityDao;
  @Autowired
  private MstFacilityHashDao mstFacilityHashDao;
  @Autowired
  private MstPatHashDao mstPatHashDao;
  @Autowired
  private MstUserAuthenticationDao mstUserAuthenticationDao;
  @Autowired
  private MstUserDao mstUserDao;
  @Autowired
  private MstDeviceSetInfoDefaultDao mstDeviceSetInfoDefaultDao;
  @Autowired
  private MstChecklistDao mstChecklistDao;
  // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
  @Autowired
  private MongoService mongoService;
  // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end

  @Override
  public Page<MstFacility> findMstFacilityAll(Pageable pageable) {
    SelectOptions selectOptions = SelectOptionsUtils.get(pageable, false);
    List<MstFacility> mstFacilityList = mstFacilityDao.selectAll();
    return new PageImpl<>(mstFacilityList, pageable, selectOptions.getCount());
  }

  @Override
  public MstFacility findMstFacilityByCd(String facility_cd) {
    return mstFacilityDao.selectByCd(facility_cd);
  }

  /**
   * 施設マスタにて特定の機能がONされているか確認.
   *
   * @param mstFacility 施設マスタのレコード
   * @param functionNo  機能No
   */
  private Boolean checkFunction(MstFacility mstFacility, String functionNo) {
    String function = mstFacility.getUseFunction();
    Boolean isEnabled = false;
    try {
      JSONObject functionData = new JSONObject(function);
      JSONArray codes = functionData.getJSONArray("func_cds");
      for (int idx = 0; idx < codes.length(); idx++) {
        if (functionNo.equals(codes.getJSONObject(idx).getString("func_cd"))) {
          isEnabled = true;
          break;
        }
      }
    } catch (Exception e) {
      return isEnabled;
    }
    return isEnabled;
  }

  private Set<String> getFacilityUseFunctionCodes(MstFacility mstFacility) {
    // 施設マスタ許可機能設定(mst_facility.use_function)のON機能コードを抽出する。
    // ここで抽出した差分は、DB更新対象ではなく強制サインアウト判定だけに使う。
    Set<String> functionCodes = new HashSet<>();
    if (mstFacility == null || StringUtils.isEmpty(mstFacility.getUseFunction())) {
      return functionCodes;
    }
    try {
      JSONObject functionData = new JSONObject(mstFacility.getUseFunction());
      JSONArray codes = functionData.getJSONArray("func_cds");
      for (int idx = 0; idx < codes.length(); idx++) {
        functionCodes.add(codes.getJSONObject(idx).getString("func_cd"));
      }
    } catch (Exception e) {
      return functionCodes;
    }
    return functionCodes;
  }

  private Set<String> getFacilityAdvancedFunctionCodes(MstFacility mstFacility) {
    // 拡張機能設定(mst_facility.advanced_settings)は施設許可機能とは別JSONで保持される。
    // 旧処理では拡張機能が減った場合に施設内ユーザー全員をサインアウトしていたため、
    // DBを触らない今回の仕様でも同じ判定だけは残す。
    Set<String> functionCodes = new HashSet<>();
    if (mstFacility == null || StringUtils.isEmpty(mstFacility.getAdvancedSettings())) {
      return functionCodes;
    }
    try {
      JSONObject functionData = new JSONObject(mstFacility.getAdvancedSettings());
      JSONArray codes = functionData.getJSONArray("func_advcds");
      for (int idx = 0; idx < codes.length(); idx++) {
        Object code = codes.get(idx);
        if (code instanceof JSONObject) {
          functionCodes.add(((JSONObject) code).getString("func_advcd"));
        } else {
          functionCodes.add(code.toString());
        }
      }
    } catch (Exception e) {
      return functionCodes;
    }
    return functionCodes;
  }

  private Set<String> getRemovedFunctionCodes(Set<String> oldFunctionCodes, Set<String> newFunctionCodes) {
    // ON -> OFF になった機能だけが「権限縮小」の対象。
    // OFF -> ON は利用可能範囲が広がるだけなのでサインアウトしない。
    Set<String> removedFunctionCodes = new HashSet<>(oldFunctionCodes);
    removedFunctionCodes.removeAll(newFunctionCodes);
    return removedFunctionCodes;
  }

  private void signOutUsersForFacilityUseFunctionShrink(MstFacility mstFacilityOld, MstFacility mstFacility, Set<Long> signedOutUserIds) {
    // 施設許可機能が縮小した場合でも、mst_user.user_settings は更新しない。
    // ただし旧ロジックで authorized_functions から削除されていたはずの機能を持つ
    // ログイン中ユーザーは、現在表示中/利用中メニューが施設OFFになっている可能性がある。
    // そのため No.64 有効時は該当ユーザーだけ強制サインアウトし、再サインイン時に
    // フロント側の実効メニュー判定で最新の施設許可を反映させる。
    Set<String> removedFunctionCodes = getRemovedFunctionCodes(
      getFacilityUseFunctionCodes(mstFacilityOld),
      getFacilityUseFunctionCodes(mstFacility)
    );
    if (removedFunctionCodes.isEmpty()) {
      return;
    }

    List<MstUserAuthentication> users = mstUserAuthenticationDao.selectByFacility(mstFacility.getFacilityCd());
    for (MstUserAuthentication user : users) {
      MstUser mstUser = mstUserDao.selectById(user.getUserId());
      if (mstUser == null || mstUser.getUserSettings() == null) {
        continue;
      }
      List<String> authorizedFunctions = mstUser.getUserSettings().getAuthorizedFunctions();
      if (authorizedFunctions == null) {
        continue;
      }
      // 外部リンク/メニューグループは mst_facility.use_function に属さないため、
      // removedFunctionCodes に含まれず、この判定ではサインアウト対象にならない。
      boolean isAffected = authorizedFunctions.stream().anyMatch(removedFunctionCodes::contains);
      if (isAffected && signedOutUserIds.add(user.getUserId())) {
        sysSigninManagerService.signOutUserForMultiServer(
          user.getFacilityCd(),
          user.getUserId(),
          ForceSignOutReason.USE_AUTH_FUNCTION_CHANGED
        );
      }
    }
  }

  private void signOutAllUsersForFacilityAdvancedFunctionShrink(MstFacility mstFacilityOld, MstFacility mstFacility, Set<Long> signedOutUserIds) {
    // 拡張機能は利用者ごとの authorized_functions ではなく施設設定で効くため、
    // 縮小時は旧処理と同じく施設内ユーザー全員を対象にする。
    // signedOutUserIds で通常許可機能縮小による二重サインアウトを避ける。
    Set<String> removedFunctionCodes = getRemovedFunctionCodes(
      getFacilityAdvancedFunctionCodes(mstFacilityOld),
      getFacilityAdvancedFunctionCodes(mstFacility)
    );
    if (removedFunctionCodes.isEmpty()) {
      return;
    }

    List<MstUserAuthentication> users = mstUserAuthenticationDao.selectByFacility(mstFacility.getFacilityCd());
    for (MstUserAuthentication user : users) {
      if (signedOutUserIds.add(user.getUserId())) {
        sysSigninManagerService.signOutUserForMultiServer(
          user.getFacilityCd(),
          user.getUserId(),
          ForceSignOutReason.USE_AUTH_FUNCTION_CHANGED
        );
      }
    }
  }
  // add 7233  デフォルト帳票について 関 start
  /**
   * S3オブジェクト取得
   * @return s3 S3オブジェクト
   */
  @Autowired
  private AwsConfiguration awsS3;

  private AmazonS3 s3() {
    return awsS3.s3();
  }

  // @Value(value = "${ntss.report.s3-bucket:#{null}}")
  // private String copyPath;


  /**
   * s3 copy 例外が発生し、例外がキャッチされて直接スキップされ、次のファイルコピーが実行されます
   *
   * @param copyObjectRequestList CopyObjectRequest
   */
  private void copyObjectUtil(List<CopyObjectRequest> copyObjectRequestList) {
    for (CopyObjectRequest copyObjectRequest : copyObjectRequestList) {
      try {
        s3().copyObject(copyObjectRequest);
      } catch (AmazonServiceException e) {
        // The call was transmitted successfully, but Amazon S3 couldn't process
        // it, so it returned an error response.
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      } catch (SdkClientException e) {
        // Amazon S3 couldn't be contacted for a response, or the client
        // couldn't parse the response from Amazon S3.
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      }
    }
    copyObjectRequestList.clear();
  }

  // ADD #10637 2024/09/05 Thach Start

  /**
   * s3 upload 例外が発生し、例外がキャッチされて直接スキップされ、次のファイルコピーが実行されます
   *
   * @param putObjectRequestList PutObjectRequest
   */
  private void uploadObjectUtil(List<PutObjectRequest> putObjectRequestList) {
    for (PutObjectRequest putObjectRequest : putObjectRequestList) {
      try {
        s3().putObject(putObjectRequest);
      } catch (AmazonServiceException e) {
        // The call was transmitted successfully, but Amazon S3 couldn't process
        // it, so it returned an error response.
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));

        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      } catch (SdkClientException e) {
        // Amazon S3 couldn't be contacted for a response, or the client
        // couldn't parse the response from Amazon S3.
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      }
    }
    putObjectRequestList.clear();
  }

  // ADD #10637 2024/09/05 Thach End

  /**
   * ファイル オブジェクトとのスプライシングのためにバケットの背後にあるアドレスをインターセプトする
   *
   * @param s
   * @param count
   * @return
   */
  private String extractString(String s, int count){
    for(int i = 0; i < count; i++){
      s = s.substring(s.indexOf("/")+1);
    }
    return s;
  }

  // MOD #10637 2024/09/05 Thach Start

  /**
   * ローカル請求書のコピー
   *
   * @param map
   * @return
   */
  private void localFileCopy(Map<String, String> map){
    if (map != null) {
      Set<Map.Entry<String, String>> sets =  map.entrySet();
      for (Map.Entry<String, String> set : sets) {
        try {
          String fileLocation = "file:///" + URLEncoder.encode(set.getKey(), StandardCharsets.UTF_8.toString());

          // Create URIs for the source and destination
          URI srcUri = URI.create(fileLocation);
          Path srcFilePath = Paths.get(srcUri);

          Path desFilePath = Paths.get(set.getValue());

          try (InputStream is = Files.newInputStream(srcFilePath, StandardOpenOption.READ)) {
              Files.copy(is, desFilePath, StandardCopyOption.REPLACE_EXISTING);
          }

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
      }
    }
  }

  // MOD #10637 2024/09/05 Thach End

  // add  デフォルト帳票について 7233 関 end

  @Override
  @Transactional(TransactionManagerName.ALL)
  public void saveMstFacility(Map<String, List<String>> payload, NtssUser ntssUser) {
    try {
      ObjectMapper mapper = new ObjectMapper();
      List<PutObjectRequest> putObjectRequestList = new ArrayList<>();
      Map<String, String> saveReportMap = new HashMap<>();
      List<String> tempRpPathList = new ArrayList<String>();

      // add redmine 4485 施設マスタの並び順が変更 宋qy start
      if ("mst_facility".equals(payload.get("getFacility").get(1))) {
        List<Map<String, Object>> updateData = new ArrayList<>();
        Map<String, Object> map = null;
        for (int i = 0; payload.get("getMasterRecordList").size() > i; i++) {
          MstFacility mstFacility = mapper.readValue(payload.get("getMasterRecordList").get(i), MstFacility.class);
          Field[] declaredFields = mstFacility.getClass().getDeclaredFields();
          map = new HashMap<String, Object>();
          for (Field field : declaredFields) {
            field.setAccessible(true);
            map.put(field.getName(), field.get(mstFacility));
          }
          updateData.add(map);
        }

        String facilityCd1 = payload.get("getFacility").get(0);;
        String masterPhysicalName = payload.get("getFacility").get(1);
        masterEditService.createMstSelector(facilityCd1, masterPhysicalName, updateData);
      }
      // add redmine 4485 施設マスタの並び順が変更 宋qy end

      // 登録処理
      List<String> facilityCdList = new ArrayList<String>();

      // add 7233 デフォルト帳票について 関 start
      /**
       * ファイルアクセスモードをオンまたはオフにする
       */
      SysSystemDefine data = sysSystemDefineDao.selectOnPremise(CoreConstant.SysSystemDefine.CTL_NO_ON_PREMISE);
      ObjectMapper objectMapper = new ObjectMapper();
      HashMap<String, String> onPremise = objectMapper.readValue(data.getValue(), new TypeReference<HashMap<String, String>>(){});
      String localStore = onPremise.get("path");
      String status = onPremise.get("status");
      // add 7233 デフォルト帳票について 関 end

      for (int i = 0; payload.get("insertRecord").size() > i; i++) {
        MstFacility mstFacility = mapper.readValue(payload.get("insertRecord").get(i), MstFacility.class);
        mstFacilityDao.insert(mstFacility);

        MstFacilityHash mstFacilityHash = mapper.readValue(payload.get("insertHashRecord").get(i), MstFacilityHash.class);

        // ADD #8094 2023/02/05 BY HandsomeLin Start
        // Default value is 2, if value is empty.
        // Because the value of facility card sign in style is 2.
        // User can use card to sign in by default.
        if (StringUtils.isEmpty(mstFacilityHash.getValue())) {
          SysFacilitySetting setting = sysFacilitySettingDao
            .selectByFacilitySettingNo(CoreConstant.FacilitySettingNo.LOGIN_METHOD_SETTING_NO);
          if (setting != null) {
            mstFacilityHash.setValue(setting.getDefaultValue());
          }
        }
        // ADD #8094 2023/02/05 BY HandsomeLin End

        mstFacilityHashDao.insert(mstFacilityHash);

        // DEL #10637 2024/09/05 Thach Start

        // //add デフォルト帳票について 7233 関 start
        // List<CopyObjectRequest> copyObjectRequestList = new ArrayList<>();
        // //実際のバケット（以下で傍受する必要があります）
        // Set<String> bucketSet = new HashSet<>();
        // //mst_reportテーブルのFacilityCdをNKKNKKの基本アカウントデータセットとして取得します（report_pathの各パラメーターを取得します）
        // List<MstReport> reportList = mstReportDao.selectAll(NKKNKK);
        // for (MstReport rep : reportList) {
        // //reportList.stream().forEach(rep -> {
        //   MstReport.ReportPath rp = rep.getReportPath();
        //   String bucket = rp.getBucket();
        //   String xlsxZip = rp.getXlsxZip();
        //   String reportZip = rp.getReportZip();
        //   String xmlFilename = rp.getXmlFilename();
        //   String htmlFilename = rp.getHtmlFilename();
        //   String xlsxFilename = rp.getXlsxFilename();
        //   // add #7233 デフォルト帳票について 商 start
        //   if (xlsxZip.startsWith("_")) {
        //     xlsxZip = xlsxZip.substring(1);
        //   }
        //   if (reportZip.startsWith("_")) {
        //     reportZip = reportZip.substring(1);
        //   }
        //   // add #7233 デフォルト帳票について 商 end
        //   if ("off".equals(status)) { //s3复制账票
        //     //実際のバケット名をインターセプトする
        //     String sourceBucket = extractString(bucket, 2);
        //     sourceBucket = sourceBucket.substring(0, sourceBucket.indexOf("/"));
        //     bucketSet.add(sourceBucket);
        //     //切り出されたバケットの後半は、スプライシングオブジェクトキーとして使用されます

        //     String sourcePath = extractString(bucket, 3);
        //     String toNewFileKey = extractString(String.format(copyPath, mstFacility.getFacilityCd()), 3);
        //     /**
        //      * xlsxZip ，同じバケットにコピーされるため、ソースバケットとターゲットバケットは同じです
        //      */
        //     String sourceXlsxZipkey = sourcePath + "/" + xlsxZip;
        //     String xlsxZipNewKey = toNewFileKey + "/" + xlsxZip;
        //     copyObjectRequestList.add(new CopyObjectRequest(sourceBucket, sourceXlsxZipkey, sourceBucket, xlsxZipNewKey));
        //     /**
        //      * reportZip 同じバケットにコピーされるため、ソースバケットとターゲットバケットは同じです
        //      */
        //     String sourceReportZipkey = sourcePath + "/" + reportZip;
        //     String reportZipNewKey = toNewFileKey + "/" + reportZip;
        //     copyObjectRequestList.add(new CopyObjectRequest(sourceBucket, sourceReportZipkey, sourceBucket, reportZipNewKey));
        //     /**
        //      * xmlFilename 同じバケットにコピーされるため、ソースバケットとターゲットバケットは同じです
        //      */
        //     String sourceXmlFilenamekey = sourcePath + "/" + xmlFilename;
        //     String xmlFilenameNewKey = toNewFileKey + "/" + xmlFilename;
        //     copyObjectRequestList.add(new CopyObjectRequest(sourceBucket, sourceXmlFilenamekey, sourceBucket, xmlFilenameNewKey));
        //     /**
        //      * htmlFilename 同じバケットにコピーされるため、ソースバケットとターゲットバケットは同じです
        //      */
        //     String sourceHtmlFilenamekey = sourcePath + "/" + htmlFilename;
        //     String htmlFilenameNewKey = toNewFileKey + "/" + htmlFilename;
        //     copyObjectRequestList.add(new CopyObjectRequest(sourceBucket, sourceHtmlFilenamekey, sourceBucket, htmlFilenameNewKey));
        //     /**
        //      * xlsxFilename 同じバケットにコピーされるため、ソースバケットとターゲットバケットは同じです
        //      */
        //     String sourceXlsxFilenamekey = sourcePath + "/" + xlsxFilename;
        //     String xlsxFilenameNewKey = toNewFileKey + "/" + xlsxFilename;
        //     copyObjectRequestList.add(new CopyObjectRequest(sourceBucket, sourceXlsxFilenamekey, sourceBucket, xlsxFilenameNewKey));
        //     // s3 copy
        //     this.copyObjectUtil(copyObjectRequestList);
        //   } else { //請求書をローカルにコピーする
        //     String fileLocation = localStore + "/" + extractString(bucket, 2);
        //     // mod 7297 初回リリース対象外の機能とその関連機能を隠す 吉 start
        //     // String projectRootPath = System.getProperty("user.dir");
        //     // projectRootPath = projectRootPath.substring(0, projectRootPath.indexOf("\\"));
        //     String projectRootPath ="";
        //     if ("\\".equals(System.getProperty("file.separator"))) {
        //       projectRootPath = System.getProperty("user.dir");
        //       projectRootPath = projectRootPath.substring(0, projectRootPath.indexOf("\\"));
        //     } else {
        //       projectRootPath="";
        //     }
        //     // mod 7297 初回リリース対象外の機能とその関連機能を隠す 吉 end
        //     // プロジェクトのルート ディレクトリが配置されているドライブ レター アドレスを取得する (ウィンドウ環境)
        //     String toFilePath = projectRootPath + String.format(localStore + "/" + extractString(copyPath, 2), mstFacility.getFacilityCd());
        //     //フォルダーを作る toFilePath
        //     File file = new File(toFilePath);
        //     if (!file.exists()) {
        //       file.mkdirs();
        //     }
        //     Map<String, Path> map = new HashMap<>();
        //     /**
        //      * xlsxZip
        //      */
        //     //yml から構成を削除し、s:// を /efs に置き換えます。実際の請求書のローカル パスです。
        //     String fileLocationxlsxZip = fileLocation + "/" + xlsxZip;

        //     String toFilePathxlsxZip = toFilePath + "/" + xlsxZip;
        //     map.put(fileLocationxlsxZip, Paths.get(toFilePathxlsxZip));
        //     /**
        //      * reportZip
        //      */
        //     String fileLocationReportZip = fileLocation + "/" + reportZip;
        //     String toFilePathReportZip = toFilePath + "/" + reportZip;
        //     map.put(fileLocationReportZip, Paths.get(toFilePathReportZip));
        //     /**
        //      * xmlFilename
        //      */
        //     String fileLocationXmlFilename = fileLocation + "/" + xmlFilename;
        //     String toFilePathXmlFilename = toFilePath + "/" + xmlFilename;
        //     map.put(fileLocationXmlFilename, Paths.get(toFilePathXmlFilename));
        //     /**
        //      * htmlFilename
        //      */
        //     String fileLocationHtmlFilename = fileLocation + "/" + htmlFilename;
        //     String toFilePathHtmlFilename = toFilePath + "/" + htmlFilename;
        //     map.put(fileLocationHtmlFilename, Paths.get(toFilePathHtmlFilename));
        //     /**
        //      * xlsxFilename
        //      */
        //     String fileLocationXlsxFilename = fileLocation + "/" + xlsxFilename;
        //     String toFilePathXlsxFilename = toFilePath + "/" + xlsxFilename;
        //     map.put(fileLocationXlsxFilename, Paths.get(toFilePathXlsxFilename));
        //     //调用copy方法
        //     this.localFileCopy(map);
        //   }
        // }
        // //add 7233 デフォルト帳票について 関 end
        // // add 7233 デフォルト帳票について 吉 start
        // // mod #7922 新規施設のデフォルト帳票に作成者・更新者が登録されている / デフォルト帳票が編集できない 修正 商 start
        // // mstReportDao.bunchinsert(mstFacility.getFacilityCd());
        // // mod #7922 新規施設のデフォルト帳票に作成者・更新者が登録されている / デフォルト帳票が編集できない 再修正 商 start
        // // List<MstReport> nkkMstReportList = mstReportDao.selectNkkInfo();
        // // for(MstReport nkkMstReport : nkkMstReportList) {
        // //   MstReport.ReportPath nkkReportPath = nkkMstReport.getReportPath();
        // //   String reportZip = nkkReportPath.getReportZip();
        // //   String xlsxZip = nkkReportPath.getXlsxZip();
        // //   if (reportZip.startsWith("_")) {
        // //     reportZip = reportZip.substring(1);
        // //     nkkReportPath.setReportZip(reportZip);
        // //   }
        // //   if (xlsxZip.startsWith("_")) {
        // //     xlsxZip = xlsxZip.substring(1);
        // //     nkkReportPath.setXlsxZip(xlsxZip);
        // //   }
        // //   nkkMstReport.setReportPath(nkkReportPath);
        // //   mstReportDao.bunchinsert(mstFacility.getFacilityCd(), nkkMstReport);
        // // }
        // mstReportDao.bunchinsert(mstFacility.getFacilityCd());
        // // mod #7922 新規施設のデフォルト帳票に作成者・更新者が登録されている / デフォルト帳票が編集できない 再修正 商 end
        // // mod #7922 新規施設のデフォルト帳票に作成者・更新者が登録されている / デフォルト帳票が編集できない 修正 商 end
        // // add 7233 デフォルト帳票について 吉 end

        // // add 7233 デフォルト帳票について 関 end
        // //新しいチャリティーコードに対応するレポートのreport_pathのバケットパス（copyPath）を変更します
        // // mod #7233 デフォルト帳票について 商 start
        // //mstReportDao.updateReportPathBucket(mstFacility.getFacilityCd(), "\"" + String.format(copyPath, mstFacility.getFacilityCd()) + "\"");
        // if (reportList.size() >0) {
        //   MstReport.ReportPath rp = reportList.get(0).getReportPath();
        //   String newBucket = "";
        //   String bucket = rp.getBucket();
        //   String sourceBucket = extractString(bucket, 2);
        //   sourceBucket = sourceBucket.substring(0, sourceBucket.indexOf("/"));
        //   if (!copyPath.startsWith("s3:/")) {
        //     newBucket = "s3://" + sourceBucket + "/" + copyPath;
        //   } else {
        //     newBucket = copyPath;
        //   }
        //   mstReportDao.updateReportPathBucket(mstFacility.getFacilityCd(), "\"" + String.format(newBucket, mstFacility.getFacilityCd()) + "\"");
        // }
        // // mod #7233 デフォルト帳票について 商 end
        // //add 7233 デフォルト帳票について 関 end

        // DEL #10637 2024/09/05 Thach End

        // ADD #10637 2024/09/05 Thach Start

        /**
         * プロジェクトパス
         */
        String projectRootPath ="";
        if ("\\".equals(System.getProperty("file.separator"))) {
          projectRootPath = System.getProperty("user.dir");
          projectRootPath = projectRootPath.substring(0, projectRootPath.indexOf("\\"));
        } else {
          projectRootPath="";
        }

        /**
         * 施設追加時に登録するデフォルト帳票配置パス
         */
        data = sysSystemDefineDao.selectOnPremise(CoreConstant.SysSystemDefine.DEFAULT_REPORT_PATH);
        HashMap<String, String> defaultRpPathHm = objectMapper.readValue(data.getValue(), new TypeReference<HashMap<String, String>>(){});
        String defaultRpPath = projectRootPath + defaultRpPathHm.get("path");
        String tempRpPath = defaultRpPath + "/Temp/" + mstFacility.getFacilityCd();
        Path path = Paths.get(tempRpPath);
        if (!Files.exists(path)) {
          Files.createDirectories(path);
        }
        tempRpPathList.add(tempRpPath);

        /**
         * 帳票配置パス
         */
        data = sysSystemDefineDao.selectOnPremise(CoreConstant.SysSystemDefine.REPORT_PATH);
        HashMap<String, String> rpPathHm = objectMapper.readValue(data.getValue(), new TypeReference<HashMap<String, String>>(){});
        String desRpPath = rpPathHm.get("path"); // ntss-s3-root-service/%s/Report

        List<Map<String, String>> mstFunctionReportData = new ArrayList<>();

        /**
         * 帳票マスタのCSVを読み込む
         */
        String mstReportCsvFile = defaultRpPath + "/mst_report.csv";
        try (Reader reader = new InputStreamReader(new FileInputStream(mstReportCsvFile), StandardCharsets.UTF_8);
             CSVParser csvParser = new CSVParser(reader, CSVFormat.DEFAULT.withFirstRecordAsHeader())) {

          LocalDateTime now = LocalDateTime.now();
          DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
          for (CSVRecord csvRecord : csvParser) {
            try{
              /**
               * 帳票ファイル名を取得する
               */
              String orgFileName = csvRecord.get("report_path");
              String xmlFilename = orgFileName + ".xml";
              String htmlFilename = orgFileName + ".html";
              String xlsxFilename = orgFileName + ".xlsx";
              String baseFileName = orgFileName.substring(0, xmlFilename.indexOf('_'));

              /**
               * 新しいファイル名を確定する
               */
              String formattedNow = now.format(formatter);
              now = now.plusSeconds(1);
              String newXlsxZip = baseFileName + "_" + formattedNow + "_Excel.zip";
              String newReportZip = baseFileName + "_" + formattedNow + "_Report.zip";
              String newXmlFilename = baseFileName + "_" + formattedNow + ".xml";
              String newHtmlFilename = baseFileName + "_" + formattedNow + ".html";
              String newXlsxFilename = baseFileName + "_" + formattedNow + ".xlsx";

              /**
               * 臨時フォルダにコピーする
               */
              Map<String, String> map = new HashMap<>();
              // xmlFilename
              String defaultXmlFilePath = defaultRpPath + "/" + xmlFilename;
              String tempXmlFilePath = tempRpPath + "/" + newXmlFilename;
              map.put(defaultXmlFilePath, tempXmlFilePath);
              // htmlFilename
              String defaultHtmlFilePath = defaultRpPath + "/" + htmlFilename;
              String tempHtmlFilePath = tempRpPath + "/" + newHtmlFilename;
              map.put(defaultHtmlFilePath, tempHtmlFilePath);
              // xlsxFilename
              String defaultXlsxFilePath = defaultRpPath + "/" + xlsxFilename;
              String tempXlsxFilePath = tempRpPath + "/" + newXlsxFilename;
              map.put(defaultXlsxFilePath, tempXlsxFilePath);
              // 调用copy方法
              this.localFileCopy(map);

              /**
               * Zipする
               */
              // xlsxZip
              List<String> zipFileList = Arrays.asList(tempXlsxFilePath);
              String tempXlsxZipPath = tempRpPath + "/" + newXlsxZip;
              zipFiles(tempXlsxZipPath, zipFileList);
              // reportZip
              zipFileList = Arrays.asList(tempXmlFilePath, tempHtmlFilePath, tempXlsxFilePath);
              String tempReportZipPath = tempRpPath + "/" + newReportZip;
              zipFiles(tempReportZipPath, zipFileList);

              /**
               * 帳票マスタのInsert
               */

              // 新規登録report_pathを作成する
              MstReport.ReportPath reportPath = new MstReport.ReportPath();
              reportPath.setBucket(String.format("s3://" + desRpPath, mstFacility.getFacilityCd())); // 例：s3:// + ntss-s3-root-service/%s/Report
              reportPath.setXlsxZip(newXlsxZip);
              reportPath.setReportZip(newReportZip);
              reportPath.setXmlFilename(newXmlFilename);
              reportPath.setHtmlFilename(newHtmlFilename);
              reportPath.setXlsxFilename(newXlsxFilename);

              // 新規登録mst_reportのデータを作成する
              MstReport mstReport = new MstReport();
              mstReport.setFacilityCd(mstFacility.getFacilityCd());
              mstReport.setReportName(csvRecord.get("report_name"));
              mstReport.setReportPath(reportPath);
              if(this.isInteger(csvRecord.get("report_class"))){
                mstReport.setReportClass(Integer.parseInt(csvRecord.get("report_class")));
              }
              else{
                continue;
              }
              if(this.isInteger(csvRecord.get("report_type"))){
                mstReport.setReportType(Integer.parseInt(csvRecord.get("report_type")));
              }
              if(this.isValidJSON(csvRecord.get("extraction_condition"))) {
                mstReport.setExtractionCondition(new MstReport.Extraction(csvRecord.get("extraction_condition")));
              }
              if(this.isLong(csvRecord.get("default_printer"))) {
                mstReport.setDefaultPrinter(Long.parseLong(csvRecord.get("default_printer")));
              }
              if(this.isValidJSON(csvRecord.get("additional_info"))) {
                mstReport.setAdditionalInfo(new MstReport.AdditionalInfo(csvRecord.get("additional_info")));
              }
              if(this.isInteger(csvRecord.get("disp_order"))){
                mstReport.setDispOrder(Integer.parseInt(csvRecord.get("disp_order")));
              }
              if(this.isValidJSON(csvRecord.get("report_setting"))) {
                mstReport.setReportSetting(csvRecord.get("report_setting"));
              }
              mstReport.setIsDisp("1");
              mstReportService.insert(mstReport, ntssUser);

              /**
               * 施設用の場所にコピーするリストを準備する
               */
              if ("off".equals(status)) {// s3モード
                String desBucket = desRpPath.substring(0, desRpPath.indexOf("/")); // 例：ntss-s3-root-service
                String toNewFileKey = extractString(String.format(desRpPath, mstFacility.getFacilityCd()), 1); // 例：%s/Report

                // xlsxZip
                String xlsxZipNewKey = toNewFileKey + "/" + newXlsxZip;
                putObjectRequestList.add(new PutObjectRequest(desBucket, xlsxZipNewKey, tempXlsxZipPath));
                // reportZip
                String reportZipNewKey = toNewFileKey + "/" + newReportZip;
                putObjectRequestList.add(new PutObjectRequest(desBucket, reportZipNewKey, tempReportZipPath));
              } else { // ローカルモード
                String toFilePath = projectRootPath + String.format(localStore + "/" + desRpPath, mstFacility.getFacilityCd()); // 例：projectRootPath + /efs + / + ntss-s3-root-service/%s/Report
                //フォルダーを作る toFilePath
                File file = new File(toFilePath);
                if (!file.exists()) {
                  file.mkdirs();
                }

                // xlsxZip
                String toFilePathxlsxZip = toFilePath + "/" + newXlsxZip;
                saveReportMap.put(tempXlsxZipPath, toFilePathxlsxZip);
                // reportZip
                String toFilePathReportZip = toFilePath + "/" + newReportZip;
                saveReportMap.put(tempReportZipPath, toFilePathReportZip);
              }
            }
            catch (Exception e) {
              throw new NtssException("デフォルト帳票csvのレコード毎の処理でエラー発生", e);
            }
          }
        } catch (FileNotFoundException e) {
          // ファイルが存在しない場合はログのみ出力
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("デフォルト帳票csvが存在しません ファイルパス:" + mstReportCsvFile);
          logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.REMS, null);
        } catch (Exception e) {
          // 例外発生時は施設登録継続しない
          throw new NtssException("施設追加時のデフォルト帳票展開処理でエラーが発生しました。", e);
        }

        /**
         * 機能帳票マスタのCSVを読み込む
         */
        String mstFunctionReportCsvFile = defaultRpPath + "/mst_function_report.csv";
        try (Reader reader = new InputStreamReader(new FileInputStream(mstFunctionReportCsvFile), StandardCharsets.UTF_8);
            CSVParser csvParser = new CSVParser(reader, CSVFormat.DEFAULT.withFirstRecordAsHeader())) {
          for (CSVRecord csvRecord : csvParser) {
            Map<String, String> mstFunctionReportItem = new LinkedHashMap<>();
            mstFunctionReportItem.put("function_cd", csvRecord.get("function_cd"));
            mstFunctionReportItem.put("report_name", csvRecord.get("report_name"));
            mstFunctionReportData.add(mstFunctionReportItem);
          }

          /**
           * 機能帳票マスタのInsert
           */
          for (int j = 0; j < mstFunctionReportData.size(); j++) {
            Map<String, String> insData = mstFunctionReportData.get(j);
            mstFunctionReportDao.insertByFunctionCdAndReportName(insData.get("function_cd"), insData.get("report_name"), mstFacility.getFacilityCd());
          }
        } catch (FileNotFoundException e) {
          // ファイルが存在しない場合はログのみ出力
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("デフォルト機能帳票csvが存在しません ファイルパス:" + mstFunctionReportCsvFile);
          logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.REMS, null);
        } catch (Exception e) {
          // 例外発生時は施設登録継続しない
          throw new NtssException("施設追加時のデフォルト帳票展開処理でエラーが発生しました。", e);
        }

        // ADD #10637 2024/09/05 Thach End

        // 在宅透析患者用(026)が許可されていれば在宅患者用ハッシュを入れる
        if (true == checkFunction(mstFacility, "026")) {
          mstPatHashDao.insert(mstFacility);
        }
        // 施設追加時に用法・用語マスタデフォルトデータを生成挿入する
        mstTakeMedicineDao.insertMstDataForNewFacility(mstFacility.getFacilityCd());

        // デフォルトメニュー設定を生成
        JSONObject defaultMenuSettings = new JSONObject();
        JSONArray defaultMenuFunctions = new JSONArray();
        String initialMenuFunction = "";

        JSONArray funcCds = new JSONObject(mstFacility.getUseFunction()).getJSONArray("func_cds");
        for (int j = 0; j < funcCds.length(); j++) {
          String FuncCd = funcCds.getJSONObject(j).getString("func_cd");
          defaultMenuFunctions.put(FuncCd);
        }

        // 初期表示画面の設定
        if (defaultMenuFunctions.length() > 0) {
          initialMenuFunction = defaultMenuFunctions.getString(0);
        }

        // デフォルトメニュー設定のJSONを構成
        defaultMenuSettings.put("initial_menu_function", initialMenuFunction);
        defaultMenuSettings.put("default_menu_functions", defaultMenuFunctions);

        // 職種マスタに初期値として「医師」・「看護師」・「臨床工学技士」を追加する
        mstJobDao.insertInitMstForFacility(mstFacility.getFacilityCd(), defaultMenuSettings.toString());

        // add #10724 インプラントマスタのデフォルト。 本田 start
        mstImplantDao.insertInitMstForFacility(mstFacility.getFacilityCd());
        // add #10724 インプラントマスタのデフォルト。 本田 end

        // add #10723 続柄マスタのデフォルト。 本田 start
        mstRelationshipDao.insertInitMstForFacility(mstFacility.getFacilityCd());
        // add #10723 続柄マスタのデフォルト。 本田 end

        facilityCdList.add(mstFacility.getFacilityCd());

        // redmine 4841 新規施設追加状態で画面表示すると全行緑色 start
        String vitalGraphData[][] = {
          {"最高血圧", "#99d9ea", "solid", "circle"},
          {"最低血圧", "#ffc90e", "solid", "diamond"},
          {"平均血圧", "#ed1c24", "solid", "square"},
          {"脈拍", "#b5e61d", "solid", "triangle"},
          {"体温", "#3f48cc", "solid", "triangle-down"},
          {"血糖値", "#00a2e8", "dot", "circle"}};
        List<Map<String, Object>> mstVitalGraphData = new ArrayList<>();
        for (int j = 0; j < vitalGraphData.length; j++) {
          Map<String, Object> mstVitalGraphItem = new LinkedHashMap<>();
          mstVitalGraphItem.put("code", j + 1);
          mstVitalGraphItem.put("name", vitalGraphData[j][0]);
          mstVitalGraphItem.put("vitalLineColor", vitalGraphData[j][1]);
          mstVitalGraphItem.put("vitalLineSize", 2);
          mstVitalGraphItem.put("vitalLineTypeValue", vitalGraphData[j][2]);
          mstVitalGraphItem.put("vitalPointColor", vitalGraphData[j][1]);
          mstVitalGraphItem.put("vitalPointSize", 4);
          mstVitalGraphItem.put("vitalPointTypeValue", vitalGraphData[j][3]);
          mstVitalGraphItem.put("isDel", "");
          mstVitalGraphItem.put("isDisp", "1");
          mstVitalGraphItem.put("sortRank", j + 1);
          mstVitalGraphItem.put("sortInputTime", 0);
          mstVitalGraphItem.put("isAddRow", true);
          mstVitalGraphItem.put("operation", 1);
          mstVitalGraphData.add(mstVitalGraphItem);
        }
        masterEditService.updateMasterData("mst_vital_graph",mstFacility.getFacilityCd(), mstVitalGraphData);
        // redmine 4841 新規施設追加状態で画面表示すると全行緑色 end

      }
      SelectOptions selectOptions = SelectOptions.get();

      //職種マスタのマスタセレクタを登録
      for (String facilityCd : facilityCdList) {
        List<MstJob> list = mstJobDao.selectByFacilityCd(facilityCd, selectOptions);
        // マスタセレクタに追加
        List<Item> items = new ArrayList<Item>();
        list.stream()
          .forEach(e -> {
            items.add
              (
                new Item() {{
                  setCode(e.getJobCd());
                  setName(e.getJobName());
                }}
              );
          });
        updateMstSelector("mst_job", items, facilityCd);

      }

      // add #10724 インプラントマスタのデフォルト。 本田 start
      //インプラントマスタのマスタセレクタを登録
      for (String facilityCd : facilityCdList) {
        List<MstImplant> list = mstImplantDao.getMstImplantInfoByFacilityCd(facilityCd);
        // マスタセレクタに追加
        List<Item> items = new ArrayList<Item>();
        list.stream()
          .forEach(e -> {
            items.add
              (
                new Item() {{
                  setCode((long) e.getImplantCd());
                  setName(e.getImplantName());
                }}
              );
          });
        updateMstSelector("mst_implant", items, facilityCd);
      }
      // add #10724 インプラントマスタのデフォルト。 本田 end

      // add #10723 続柄マスタのデフォルト。 本田 start
      // 続柄マスタのマスタセレクタを登録
      for (String facilityCd : facilityCdList) {
        List<MstRelationship> list = mstRelationshipDao.getMstRelationshipInfoByFacilityCd(facilityCd);
        // マスタセレクタに追加
        List<Item> items = new ArrayList<Item>();
        list.stream()
          .forEach(e -> {
            items.add
              (
                new Item() {{
                  setCode((long) e.getRelationshipCd());
                  setName(e.getRelationshipName());
                }}
              );
          });
        updateMstSelector("mst_relationship", items, facilityCd);
      }
      // add #10723 続柄マスタのデフォルト。 本田 end

      // 患者メモマスタに初期値として「pat_memo_no（１～１０）」を追加する
      mstPatMemoDao.insertInitMstForFacility(facilityCdList);
      //患者メモマスタのマスタセレクタを登録
      for (String facilityCd : facilityCdList) {
        MstPatMemo params = new MstPatMemo();
        params.setFacilityCd(facilityCd);
        List<MstPatMemo> list = mstPatMemoDao.selectAll(selectOptions, params);

        // マスタセレクタに追加
        List<Item> items = new ArrayList<Item>();
        list.stream()
          .forEach(e -> {
            items.add
              (
                new Item() {{
                  setCode((long) e.getPatMemoNo());
                  setName(e.getTitle());
                }}
              );
          });
        updateMstSelector("mst_pat_memo", items, facilityCd);
      }

      // 装置設定デフォルトマスタに初期値を追加する
      mstDeviceSetInfoDefaultDao.insertInitMstForFacility(facilityCdList);

      // チェックリストマスタに初期値を追加する
      mstChecklistDao.insertInitMstForFacility(facilityCdList);

      // ユーザーマスタに固定ユーザー情報を追加する
      insertDefaultSystemUser(facilityCdList);
      // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
      List<Map<String, Object>> updMasterInfos =  new ArrayList<>();
      // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end
      // 更新処理
      for (int i = 0; payload.get("updateRecord").size() > i; i++) {
        MstFacility mstFacility = mapper.readValue(payload.get("updateRecord").get(i), MstFacility.class);

        //DB更新ログ出力ロジック start

        String mmsTbN = "mst_facility";

        // SQL検索条件
        StringBuffer wheres = new StringBuffer("");
        wheres.append(" WHERE\n");
        wheres.append(" facility_cd = '" + mstFacility.getFacilityCd() + "'" + "\n");
        // logCommon設定
        // logCommon設定
        DataUpdateLogCommonNew logCommon = getLogCommon(mstFacilityDao, mmsTbN, wheres, getEventLogMessage());
        // ログ出力カラム情報及び更新前データ情報取得
        boolean setResult = logCommon.setInfo();
        //DB更新ログ出力ロジック wp end

        // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
        LogEventUtils.setOperatorId(mstFacility,logService);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
        // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end

        // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou start
        // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
        MstFacility mstFacilityOld = mstFacilityDao.selectByCd(mstFacility.getFacilityCd());
        // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end
        // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou end
        int ret = mstFacilityDao.update(mstFacility);
        // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
        if (mstFacilityOld != null && mstFacility != null
                && mstFacilityOld.getFacilityName() != null && mstFacility.getFacilityName() != null
                && !mstFacilityOld.getFacilityName().equals(mstFacility.getFacilityName())) {
          Map<String, Object> updFacilityInfo = new HashMap<>();
          updFacilityInfo.put("code", mstFacility.getFacilityCd());
          updFacilityInfo.put("name", mstFacility.getFacilityName());
          updMasterInfos.add(updFacilityInfo);
        }
        // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end
        //DB更新ログ出力ロジック wp start

        // 更新後データ取得、差分あれば、log出力
        if (setResult && ret > 0) {
          logCommon.updateLog();
        }
        //DB更新ログ出力ロジック wp end


        MstFacilityHash mstFacilityHash = mapper.readValue(payload.get("updateHashRecord").get(i), MstFacilityHash.class);

        // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
        LogEventUtils.setOperatorId(mstFacilityHash,logService);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
        // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
        int hashret = mstFacilityHashDao.update(mstFacilityHash);


        // 在宅透析患者用(026)が許可されていれば在宅患者用ハッシュを入れる
        if (true == checkFunction(mstFacility, "026")) {
          MstPatHash mstPatHash = mstPatHashDao.selectByFacilityCd(mstFacility.getFacilityCd());
          // 在宅患者用ハッシュテーブルに該当施設のレコードがない場合のみInsertする
          if (null == mstPatHash) {
            // Update用のレコードは登録日時がnullなので、更新日時と同じ日時にする
            mstFacility.setRegDate(mstFacility.getUpDate());
            mstPatHashDao.insert(mstFacility);
          }
        }

        String value = facilitySettingService.getFacilitySettingValue(
          mstFacility.getFacilityCd(),
          CoreConstant.FacilitySettingNo.AUTHORITY_CHANGE_SIGN_OUT
        );
        if (VALID.equals(value)) {
          Set<Long> signedOutUserIds = new HashSet<>();
          signOutUsersForFacilityUseFunctionShrink(mstFacilityOld, mstFacility, signedOutUserIds);
          signOutAllUsersForFacilityAdvancedFunctionShrink(mstFacilityOld, mstFacility, signedOutUserIds);
        }
      }
        // 施設の許可機能設定は mst_facility.use_function のみ更新する。
        // 職種マスタ・利用者マスタのメニュー/許可設定は保存時に物理更新せず、
        // 施設許可が縮小した場合の強制サインアウトだけを行う。
      // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
      if (!CollectionUtils.isEmpty(updMasterInfos)) {
          // 施設マスタ
          mongoService.updateAndInsertPatMain(null, null, false, updMasterInfos, MstToMongoEnum.MSTFACILITY);
          mongoService.updateAndInsertPatPersonalMain(null, updMasterInfos, MstToMongoEnum.MSTFACILITY);
          mongoService.updateAndInsertPatUnique(null, updMasterInfos, MstToMongoEnum.MSTFACILITY);
      }
      // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end
      // 削除処理
      List<String> deleteCdList = payload.get("deleteCdList");
      for (int i = 0; deleteCdList.size() > i; i++) {
        String facilityCd = deleteCdList.get(i);
        mstFacilityDao.deleteByCd(facilityCd);
        mstFacilityHashDao.deleteByCd(facilityCd);
        mstPatHashDao.deleteByCd(facilityCd);
      }

      payload.get("cancelFacilityList").stream().forEach(info -> {
        JSONObject registerData = new JSONObject(info);
        try {
          // 施設解約登録API呼出し
          webApiCallFacilityCancelManage.registerFacilityCancelManage(registerData);
        } catch (URISyntaxException | RuntimeException e) {
          EventLogMessage eventLogMessage = new EventLogMessage();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          if (ntssUser != null && ntssUser.getFacilityCd() != null) {
            eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
          }
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
          eventLogMessage.setLogMessage("施設解約登録処理 例外発生 registerData:" + registerData);
          logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.REMS, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
        }
      });

      payload.get("cancelStopFacilityList").stream().forEach(info -> {
        JSONObject cancelData = new JSONObject(info);
        try {
          // 施設解約取消API呼出し
          webApiCallFacilityCancelManage.cancelFacilityCancelManage(cancelData);
        } catch (URISyntaxException | RuntimeException e) {
          EventLogMessage eventLogMessage = new EventLogMessage();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          if (ntssUser != null && ntssUser.getFacilityCd() != null) {
            eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
          }
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
          eventLogMessage.setLogMessage("施設解約取消処理 例外発生 cancelData:" + cancelData);
          logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.REMS, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
        }
      });

      payload.get("changeCancelDateList").stream().forEach(o -> {
        try {
          // 解約日の変更
          JSONObject jsonData = new JSONObject(o);

          // 解約日をtimestamp型に変換
          SimpleDateFormat sdf = new SimpleDateFormat("yyyy/MM/dd");
          Date parsedDate = sdf.parse(jsonData.get("st_date").toString());
          Timestamp ts = new Timestamp(parsedDate.getTime());

          // update処理
          MntFacilityCancelManage mfcm = new MntFacilityCancelManage();
          mfcm.setCtlNo(Long.parseLong(jsonData.get("ctl_no").toString()));
          mfcm.setStDate(ts);

          // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
          LogEventUtils.setOperatorId(mfcm,logService);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
          // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
          mntFacilityCancelManageDao.update(mfcm);

        } catch (RuntimeException e) {
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("施設解約日変更 例外発生 :" + o);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          if (ntssUser != null && ntssUser.getFacilityCd() != null) {
            eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
          }
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
          logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.REMS, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
        } catch (ParseException e) {
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("施設解約日の変換に失敗しました。" + o);
          logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.REMS, null);
        }
      });

      // ADD #10637 2024/09/05 Thach Start
      /**
       * 施設用の場所に帳票をコピーする
       */
      if(!TransactionAspectSupport.currentTransactionStatus().isRollbackOnly()){
        if ("off".equals(status)) {// s3モード
          // アップロード
          this.uploadObjectUtil(putObjectRequestList);
        } else { // ローカルモード
          //调用copy方法
          this.localFileCopy(saveReportMap);
        }
      }

      // Tempフォルダを削除する
      for (String tempRpPath : tempRpPathList) {
        this.deleteDirectory(Paths.get(tempRpPath));
      }
      // ADD #10637 2024/09/05 Thach End

      return;
    } catch (Exception e) {
      throw new NtssException(e);
    }
  }

  // ADD #10637 2024/09/05 Thach Start
  /**
   * Integerのチェック
   *
   * @param value
   * @return
   */
  private static boolean isInteger(String value) {
    try {
        Integer.parseInt(value);
        return true;
    } catch (NumberFormatException e) {
        return false;
    }
  }

  /**
   * Longのチェック
   *
   * @param value
   * @return
   */
  private static boolean isLong(String value) {
      try {
          Long.parseLong(value);
          return true;
      } catch (NumberFormatException e) {
          return false;
      }
  }

  /**
   * jsonのチェック
   *
   * @param jsonString
   * @return
   */
  private static boolean isValidJSON(String jsonString) {
    if (jsonString == null || jsonString.trim().isEmpty()) {
      return false;
    }
    try {
        ObjectMapper objectMapper = new ObjectMapper();
        objectMapper.readTree(jsonString);
        return true;
    } catch (Exception e) {
        return false;
    }
 }

  /**
   * ファイルを削除する
   *
   * @param filePaths
   * @return
   */
  private static void deleteDirectory(Path path) throws IOException {
    Files.walkFileTree(path, new SimpleFileVisitor<Path>() {
        @Override
        public FileVisitResult visitFile(Path file, BasicFileAttributes attrs) throws IOException {
            Files.delete(file);
            return FileVisitResult.CONTINUE;
        }

        @Override
        public FileVisitResult postVisitDirectory(Path dir, IOException exc) throws IOException {
            Files.delete(dir);
            return FileVisitResult.CONTINUE;
        }
    });
  }

  /**
   * ファイルを圧縮する
   */
  private static void zipFiles(String zipFileName, List<String> files) throws IOException {
    // バッファのサイズを設定します
    byte[] buffer = new byte[4096];

    File zipFile = new File(zipFileName);
    if(!zipFile.getParentFile().exists()) {
      zipFile.getParentFile().mkdirs();
    }
    zipFile.createNewFile();

    // try-with-resources文を使って、FileOutputStreamとZipOutputStreamを自動的にクローズします
    try (FileOutputStream fileOutputStream = new FileOutputStream(zipFile);
      ZipOutputStream zipOutputStream = new ZipOutputStream(fileOutputStream)) {

      // 各ファイルをZIPに追加します
      for (String file : files) {
        try (FileInputStream fileInputStream = new FileInputStream(file)) {
          // 新しいZipEntryを作成し、ZipOutputStreamに追加します
          zipOutputStream.putNextEntry(new ZipEntry(new File(file).getName()));

          int bytesRead;
          // ファイルの内容をバッファに読み込み、ZipOutputStreamに書き込みます
          while ((bytesRead = fileInputStream.read(buffer)) > 0) {
              zipOutputStream.write(buffer, 0, bytesRead);
          }

          // 現在のエントリをクローズします
          zipOutputStream.closeEntry();
        }
      }
    }
  }

  // ADD #10637 2024/09/05 Thach End

  /**
   * パスワードエンコーダ.
   */
  @Autowired
  private PasswordEncoder passwordEncoder;

  /**
   * 固定システムユーザー情報を追加
   *
   * @param facilityCdList
   */
  private void insertDefaultSystemUser(List<String> facilityCdList) {

    for (String facilityCd : facilityCdList) {

      List<MstUserData> users = new ArrayList<>();
      // 1.体重計アプリ用ユーザー
      MstUserData scaleAppUser = new MstUserData();
      scaleAppUser.setFacilityCd(facilityCd);
      scaleAppUser.setDispUserId("ScalApp4");
      scaleAppUser.setUserPassword("k6iQTzhU59xTNgie");
      scaleAppUser.setUserLastName("体重計App");  // ※ 姓名が空欄だと暗号・復号時にエラーになるため
      scaleAppUser.setUserFirstName("ユーザー");
      scaleAppUser.setUserType(2);
      scaleAppUser.setAdministrator(0);
      users.add(scaleAppUser);
      // 1.印刷サーバーAppユーザー
      MstUserData printSvAppUser = new MstUserData();
      printSvAppUser.setFacilityCd(facilityCd);
      printSvAppUser.setDispUserId("PrintSrvApp4");
      printSvAppUser.setUserPassword("PxVQ48buEgm5bCVW");
      printSvAppUser.setUserLastName("印刷SV");
      printSvAppUser.setUserFirstName("ユーザー");
      printSvAppUser.setUserType(2);
      printSvAppUser.setAdministrator(0);
      users.add(printSvAppUser);
      //カードApp用ユーザー
      MstUserData cardAppUser = new MstUserData();
      cardAppUser.setFacilityCd(facilityCd);
      cardAppUser.setDispUserId("CardApp4");
      cardAppUser.setUserPassword("sjT5YgazVfrGarF4");
      cardAppUser.setUserLastName("カードApp");
      cardAppUser.setUserFirstName("ユーザー");
      cardAppUser.setUserType(2);
      cardAppUser.setAdministrator(0);
      users.add(cardAppUser);
      // スケールベッドアプリ用ユーザー
      MstUserData scaleBedAppUser = new MstUserData();
      scaleBedAppUser.setFacilityCd(facilityCd);
      scaleBedAppUser.setDispUserId("ScalBedApp4");
      scaleBedAppUser.setUserPassword("5pXgR2s7yK9zJ4hT");
      scaleBedAppUser.setUserLastName("スケールベッドApp"); // ※ 姓名が空欄だと暗号・復号時にエラーになるため
      scaleBedAppUser.setUserFirstName("ユーザー");
      scaleBedAppUser.setUserType(2);
      scaleBedAppUser.setAdministrator(0);
      users.add(scaleBedAppUser);
      // 入口血圧計アプリ用ユーザー
      MstUserData bloodPressureAppUser = new MstUserData();
      bloodPressureAppUser.setFacilityCd(facilityCd);
      bloodPressureAppUser.setDispUserId("BPMoniApp4");
      bloodPressureAppUser.setUserPassword("B7mQ4tP9wH2cS8kL");
      bloodPressureAppUser.setUserLastName("入口血圧計App"); // ※ 姓名が空欄だと暗号・復号時にエラーになるため
      bloodPressureAppUser.setUserFirstName("ユーザー");
      bloodPressureAppUser.setUserType(2);
      bloodPressureAppUser.setAdministrator(0);
      users.add(bloodPressureAppUser);

      for (MstUserData mstUser : users) {

        // 登録時間取得
        java.sql.Timestamp regDt = new java.sql.Timestamp(System.currentTimeMillis());

        // 利用者マスタに登録して利用者ID(シーケンス発行)を取得
        MstPersonalUser newPersonalUser = new MstPersonalUser() {
          {
            setFacilityCd(mstUser.getFacilityCd());
            setUserType(mstUser.getUserType());
            setAdministrator(mstUser.getAdministrator());
            setUserLastName(mstUser.getUserLastName());
            setUserFirstName(mstUser.getUserFirstName());
            setIsDel("0");
            setIsDisp("1");
            setUpDate(regDt);
            setRegDate(regDt);
          }
        };
        mstPersonalUserDao.insertNewUser(newPersonalUser);

        // @Insertでは暗号化項目が平文で登録されてしまうためユーザ苗字・ユーザ名を更新
        mstPersonalUserDao.updateUserName(newPersonalUser);

        // 利用者マスタ(医療情報DB)に登録
        // 設定項目初期値はメニュー設定全てなしをセット
        MstUser.UserSettings usrSetting = new MstUser.UserSettings() {
          {
            setTheme(THEME_DEFAULT);
            setFontSize(FONT_SIZE_DEFAULT);
            setIsDispMenu(0);
            setUseFunctions(new ArrayList<>());
            setAuthorizedFunctions(new ArrayList<>());
            setInitialFunction("");
          }
        };
        MstUser newMstUser = new MstUser() {
          {
            setUserId(newPersonalUser.getUserId());
            setFacilityCd(mstUser.getFacilityCd());
            setIsProvisional(0);
            setUserSettings(usrSetting);
            setIsDel("0");
            setIsDisp("1");
            setUpDate(regDt);
            setRegDate(regDt);
          }
        };
        mstUserDao.insertNewUser(newMstUser);

        // 利用者マスタ(認証DB)に登録
        MstUserAuthentication newMstUserAuth = new MstUserAuthentication() {
          {
            setUserId(newPersonalUser.getUserId());
            setFacilityCd(mstUser.getFacilityCd());
            setDispUserId(mstUser.getDispUserId());
            setUserPassword(StringUtils.isEmpty(mstUser.getUserPassword()) ? null : passwordEncoder.encode(mstUser.getUserPassword()));
            setFailureCnt(0);
            setUpDate(regDt);
            setRegDate(regDt);
          }
        };
        mstUserAuthenticationDao.insertNewUser(newMstUserAuth);
      }
    }
  }

  /**
   * マスタセレクタを更新する.
   *
   * @param tableName マスタ物理名
   */
  private void updateMstSelector(String tableName, List<Item> items, String facilityCd) {
    // マスタセレクタを取得
    String masterPhysicalName = tableName;
    MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, masterPhysicalName);

    MstSelector.OrderSettings orderSettings = new MstSelector.OrderSettings();
    orderSettings.setItems(items);

    mstSelector = new MstSelector();
    mstSelector.setFacilityCd(facilityCd);
    mstSelector.setMasterPhysicalName(masterPhysicalName);
    mstSelector.setOrderSettings(orderSettings);
    mstSelectorDao.insert(mstSelector);
  }

  /**
   * 解約中を除く施設の一覧を取得する
   */
  @Override
  public Page<MstFacility> findMstFacilityAllWithoutCancelFacilities(Pageable pageable) {
    SelectOptions selectOptions = SelectOptionsUtils.get(pageable, false);
    List<MstFacility> mstFacilityList = mstFacilityDao.selectAllWithoutCancelFacilities(selectOptions);
    return new PageImpl<>(mstFacilityList, pageable, selectOptions.getCount());
  }

  /*
   * インプラントマスタ
   */
  @Autowired
  private MstImplantDao mstImplantDao;

  @Override
  public Page<MstImplant> findMstImplantAll(Pageable pageable, MstImplant params) {
    SelectOptions selectOptions = SelectOptions.get();

    List<MstImplant> mstImplantList = mstImplantDao.selectAll(selectOptions, params);
    return new PageImpl<>(mstImplantList, pageable, selectOptions.getCount());
  }

  /*add FNSI-改修内容5237 任 start*/
  @Override
  public Page<MstImplant> findMstImplantDelAll(Pageable pageable, MstImplant params) {
    SelectOptions selectOptions = SelectOptions.get();

    List<MstImplant> mstImplantList = mstImplantDao.selectDelAll(selectOptions, params);
    return new PageImpl<>(mstImplantList, pageable, selectOptions.getCount());
  }
  /*add FNSI-改修内容5237 任 end*/
  @Override
  public Page<MstImplant> findMstImplantAllIncludeDel(Pageable pageable, MstImplant params) {
    SelectOptions selectOptions = SelectOptions.get();

    List<MstImplant> mstImplantList = mstImplantDao.selectAllIncludeDel(selectOptions, params);
    return new PageImpl<>(mstImplantList, pageable, selectOptions.getCount());
  }

  @Override
  public List<MstImplant> findMstImplantNameByCdList(List<Integer> implantCdList) {
    return mstImplantDao.selectImplantByCdList(implantCdList);
  }

  /*
   * 感染症マスタ
   */
  @Autowired
  private MstInfectionDao mstInfectionDao;

  @Override
  public Page<MstInfection> findMstInfectionAll(Pageable pageable, MstInfection params) {
    SelectOptions selectOptions = SelectOptions.get();

    List<MstInfection> mstInfectionList = mstInfectionDao.selectAll(selectOptions, params);
    return new PageImpl<>(mstInfectionList, pageable, selectOptions.getCount());
  }
  /*
   * 感染症マスタ（削除済み含む）
   */
  @Override
  public List<MstInfection> findMstInfectionAllIncludeDel(String facilityCd) {
    return mstInfectionDao.getMstInfectionInfoByFacilityCd(facilityCd);
  }

  /*
   * クールマスタ
   */
  @Autowired
  private MstKurDao mstKurDao;

  @Override
  public Page<MstKur> findMstKurAll(Pageable pageable) {
    SelectOptions selectOptions = SelectOptions.get();

    List<MstKur> mstKurList = mstKurDao.selectAll(selectOptions);
    return new PageImpl<>(mstKurList, pageable, selectOptions.getCount());
  }

  @Override
  public Page<MstKur> findMstKurByFacilityCd(Pageable pageable, String facility_cd, String is_del) {
    SelectOptions selectOptions = SelectOptions.get();
    List<MstKur> mstKurList = mstKurDao.selectByFacilityCd(selectOptions, facility_cd, is_del);
    return new PageImpl<>(mstKurList, pageable, selectOptions.getCount());
  }

  // FNSI-修正 マスタ削除の対応 chen add start
  @Override
  public Page<MstKur> findMstKurByFacilityCdDel(Pageable pageable, String facility_cd) {
    SelectOptions selectOptions = SelectOptions.get();
    List<MstKur> mstKurList = mstKurDao.selectByFacilityCdDel(selectOptions, facility_cd);
    return new PageImpl<>(mstKurList, pageable, selectOptions.getCount());
  }
// FNSI-修正 マスタ削除の対応 chen add end

  @Override
  public String findKurNameByKurCd(String kurCd) {
    String kurName = null;
    MstKur mstKur = mstKurDao.selectByKurCd(kurCd);
    if (mstKur != null) {
      kurName = mstKur.getKurName();
    }
    return kurName;
  }

  /*
   * クールマスタ更新
   */
  @Override
  @Transactional
  public List<MstKur> saveMstKur(
    String facility_cd,
    Map<String, List<String>> payload
  ) throws Exception {

    try {
      List<MstKur> insertedRecode = new ArrayList<>();
      ObjectMapper mapper = new ObjectMapper();
      //del #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 start
//      List<Long> deletedKurList = new ArrayList<>();
      //del #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 end

      // 登録処理
      if (payload.get("insertRecord").size() > 0) {
        for (int i = 0; payload.get("insertRecord").size() > i; i++) {
          // mst_kur.kur_cdのシーケンス
          Integer nextSeqKurCd = mstKurDao.selectNextSeqKurCd();
          MstKur mstKur = mapper.readValue(payload.get("insertRecord").get(i), MstKur.class);

          // kur_cdを設定
          mstKur.setKurCd(nextSeqKurCd);
          mstKurDao.insert(facility_cd, mstKur);
          // 登録したレコードをリターン用に格納
          insertedRecode.add(mstKur);
        }
      }

      // 更新処理
      if (payload.get("updateRecord").size() > 0) {
        for (int i = 0; payload.get("updateRecord").size() > i; i++) {
          MstKur mstKur = mapper.readValue(payload.get("updateRecord").get(i), MstKur.class);

          mstKurDao.updateByCd(mstKur);
//del #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 start
//          int ret = mstKurDao.updateByCd(mstKur);
//
//          String isDel = mstKur.getIsDel();
//          if (isDel.equals("1")) {
//            // 削除フラグが1(削除されたクールコード)なら
//            long kurCd = mstKur.getKurCd();
//            deletedKurList.add(kurCd);
//          }
//del #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 end
        }
      }
//del #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 start
//      if (deletedKurList.size() != 0) {
//        // クールが削除されたなら
//        // 削除されたクールを使用しているord_mainのind_kur_cdを未登録へind_treat_start_timeをnullへ設定
//        updateByIndKurCd(deletedKurList, facility_cd);
//      }
//del #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 end
      return insertedRecode;

    } catch (RuntimeException e) {
      throw new RuntimeException(e);
    }
  }

  /**
   * 常勤医設定変更
   *
   * @param mstKur
   * @return
   */
  @Override
  @Transactional
  public int saveDoctorMstKur(MstKur mstKur) {
    return mstKurDao.updateDoctorByCd(mstKur);
  }

  /*
   * ord_mainのind_kur_cdを未登録へ治療開始時刻をnullへ設定
   */
  public void updateByIndKurCd(List<Long> kurList, String facility_cd) {

    // add FNSI-改修内容追加OrdMain履歴 付 start
    selectHistoryUtils.insertMangoDbHistory(4, null, null, new ArrayList<>(), kurList, facility_cd, null,
      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
      new ArrayList<>(), null, null);
    // mangoDb-updateByIndKurCd-insertSuccess
    // add FNSI-改修内容追加OrdMain履歴 付 end

    // 未登録　「ind_kur_cd： 0」 ※固定値

    //DB更新ログ出力ロジック wp start

    String mmsTbN = "ord_main";

    StringBuffer sql = getSql1(facility_cd, kurList);
    // logCommon設定
    // logCommon設定
    boolean setResult = false;
    DataUpdateLogCommonNew logCommon = new DataUpdateLogCommonNew();
    if (sql != null) {

      logCommon = getLogCommon(mstKurDao, mmsTbN, sql, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      setResult = logCommon.setInfo();

    }


    //DB更新ログ出力ロジック wp end

    int kur_cd = 0;
    int ret = mstKurDao.updateByIndKurCd(kurList, facility_cd, kur_cd);

    //DB更新ログ出力ロジック wp start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && ret > 0) {
      logCommon.updateLog();
    }
    //DB更新ログ出力ロジック wp end
  }

  /*
   * クール並び順登録・更新
   */
  @Override
  @Transactional
  public void saveMstSelector(
    String facility_cd,
    Map<String, String> payload
  ) throws Exception {

    try {
      // マスタセレクタを取得
      String mstSelector = mstKurDao.selectByName(facility_cd);
      // 並び替えデータを取得
      String master_physical_name = payload.get("master_physical_name");
      String nowDate = payload.get("nowDate");

      // 登録処理
      if (mstSelector == null) {
        mstKurDao.insertByMstSelector(facility_cd, master_physical_name, nowDate);

      } else {

        //DB更新ログ出力ロジック wp start

        String mmsTbN = "mst_selector";

        // SQL検索条件
        StringBuffer wheres = new StringBuffer("");
        wheres.append(" WHERE\n");
        wheres.append(" facility_cd = '" + facility_cd + "'" + "\n");
        wheres.append(" and \n");
        wheres.append(" master_physical_name = 'mst_kur'" + "\n");

        // logCommon設定
        // logCommon設定
        DataUpdateLogCommonNew logCommon = getLogCommon(mstKurDao, mmsTbN, wheres, getEventLogMessage());
        // ログ出力カラム情報及び更新前データ情報取得
        boolean setResult = logCommon.setInfo();
        //DB更新ログ出力ロジック wp end


        // 更新処理
        int ret = mstKurDao.updateByMasterPhysicalName(facility_cd, master_physical_name, nowDate);

        //DB更新ログ出力ロジック wp start
        // 更新後データ取得、差分あれば、log出力
        if (setResult && ret > 0) {
          logCommon.updateLog();
        }
        //DB更新ログ出力ロジック wp end

      }

    } catch (RuntimeException e) {
      throw new RuntimeException(e);
    }
  }

  /*
   * 投与タイミングマスタ
   */
  @Autowired
  private MstMedicateTimingDao mstMedicateTimingDao;

  @Override
  public Page<MstMedicateTiming> findMstMedicateTimingAll(Pageable pageable, MstMedicateTiming params) {
    SelectOptions selectOptions = SelectOptions.get();

    List<MstMedicateTiming> mstMedicateTimingList = mstMedicateTimingDao.selectAll(selectOptions, params);
    return new PageImpl<>(mstMedicateTimingList, pageable, selectOptions.getCount());
  }
  // FNSI-修正 マスタ削除の対応 chen add start
  @Override
  public Page<MstMedicateTiming> findMstMedicateTimingIncludeDeleted(Pageable pageable, MstMedicateTiming params) {
    SelectOptions selectOptions = SelectOptions.get();

    List<MstMedicateTiming> mstMedicateTimingList = mstMedicateTimingDao.selectIncludeDeleted(selectOptions, params);
    return new PageImpl<>(mstMedicateTimingList, pageable, selectOptions.getCount());
  }
  // FNSI-修正 マスタ削除の対応 chen add end

  /*
   * 薬剤分類マスタ
   */
  @Autowired
  private MstMedicineClassDao mstMedicineClassDao;

  @Override
  public Page<MstMedicineClass> findMstMedicineClassAll(Pageable pageable, MstMedicineClass params) {
    SelectOptions selectOptions = SelectOptions.get();

    List<MstMedicineClass> mstMedicineClassList = mstMedicineClassDao.selectAll(selectOptions, params);
    return new PageImpl<>(mstMedicineClassList, pageable, selectOptions.getCount());
  }

  @Override
  public Page<MstMedicineClass> findMstMedicineClassAllIncludeDeleted(Pageable pageable, MstMedicineClass params) {
    SelectOptions selectOptions = SelectOptions.get();

    List<MstMedicineClass> mstMedicineClassList = mstMedicineClassDao.selectAllIncludeDeleted(selectOptions, params);
    return new PageImpl<>(mstMedicineClassList, pageable, selectOptions.getCount());
  }

  /*
   * 薬剤マスタ
   */
  @Autowired
  private MstMedicineDao mstMedicineDao;

  @Autowired
  private PatMainDao patMainDao;

  @Override
  public Page<MstMedicine> findMstMedicineAll(Pageable pageable, MstMedicine params) {
    SelectOptions selectOptions = SelectOptions.get();

    List<MstMedicine> mstMedicineList = mstMedicineDao.selectAll(selectOptions, params);
    return new PageImpl<>(mstMedicineList, pageable, selectOptions.getCount());
  }

  // FNSI-修正 マスタ削除の対応 chen add start
  @Override
  public MstMedicine findMstMedicineByCd(MstMedicine params) {
    MstMedicine mstMedicine = mstMedicineDao.selectByCdNoDel(params.getFacilityCd(), params.getMedicineCd());
    return mstMedicine;
  }
// FNSI-修正 マスタ削除の対応 chen add end

  @Override
  public MstMedicine findMstMedicineByCd(String cd) {
    MstMedicine mstMedicine = null;
    if (StrUtils.isNumber(cd)) {
      int medicineCd = Integer.parseInt(cd);
      mstMedicine = mstMedicineDao.selectByMediCd(medicineCd);
    }
    return mstMedicine;
  }

  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 start
  @Override
  public Page<MstMedicineExtendsDto> findMstMedicineAllIncludeDeleted(Pageable pageable, MstMedicine params) {
    SelectOptions selectOptions = SelectOptions.get();

    List<MstMedicine> mstMedicineList = mstMedicineDao.selectAllIncludeDeleted(selectOptions, params);
    List<MstMedicineExtendsDto> res = new ArrayList<>();
    List<MstMedicineExtendsDto> result = new ArrayList<>();
    if(mstMedicineList != null && !mstMedicineList.isEmpty()){
      MstMedicineClass paramClass = new MstMedicineClass() {
        {
          setFacilityCd(params.getFacilityCd());
        }
      };

      List<MstMedicineClass> mstMedicineClassList = mstMedicineClassDao.selectAllIncludeDeleted(selectOptions, paramClass);

      for(MstMedicine mstMedicine : mstMedicineList){
        MstMedicineExtendsDto newElement = new MstMedicineExtendsDto();
        BeanUtils.copyProperties(mstMedicine, newElement);
        Integer classCd = mstMedicine.getClassCd();
        Optional<MstMedicineClass> found = mstMedicineClassList.stream().filter(data -> data.getClassCd().equals(classCd)).findFirst();
        if (found.isPresent()) {
          MstMedicineClass mstMedicineClass = found.get();
          String classType = "0";
          if (mstMedicineClass.getClassType() != null) {
            classType = String.valueOf((int)mstMedicineClass.getClassType().doubleValue());
          }
          newElement.setClassType(classType);
        } else {
          newElement.setClassType("0");
        }
        res.add(newElement);
      }

      List<Object> objects = new ArrayList<>(res.size());
      objects.addAll(res);
      objects = sortData(objects, "mst_medicine", params.getFacilityCd());
      for (Object obj : objects) {
        if (obj instanceof MstMedicineExtendsDto) {
          result.add((MstMedicineExtendsDto) obj);
        }
      }
    }

    return new PageImpl<>(result, pageable, selectOptions.getCount());
  }
  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 end

  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 start
  /* modify by chamaojia 2024-02-28 [10196] Add interface parameter 'selectMedicineCd' --start */
  // mod FNSI-期限切れ削除済みと表示するの修正 start
  @Override
  // public List<MstMedicine> findMstMedicineTabooAllergy(String facilityCd, Long patId){
  public List<MstMedicineDto> findMstMedicineTabooAllergy(String facilityCd, Long patId, Integer selectMedicineCd, boolean... isDelFlg) {
    // mod FNSI-期限切れ削除済みと表示するの修正 end
  /* modify by chamaojia 2024-02-28 [10196] Add interface parameter 'selectMedicineCd' --end */
  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 end
    SelectOptions selectOptions = SelectOptions.get();
    // 薬剤リスト一覧を取得
    MstMedicine param = new MstMedicine() {
      {
        setFacilityCd(facilityCd);
      }
    };

    // mod FNSI-期限切れ削除済みと表示するの修正 start
    // List<MstMedicine> lstMstMedicine = mstMedicineDao.selectAll(selectOptions, param);
    List<MstMedicine> lstMstMedicine = null;
    //add #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 start
    List<MstMedicineDto> mstMedicineDtoList = new ArrayList<>();
    //add #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 end
    if (isDelFlg.length == 0) {
      /* modify by chamaojia 2024-02-28 [10196] Add processing based on "selectMedicaineCd" query --start */
      if (selectMedicineCd == null) {
        lstMstMedicine = mstMedicineDao.selectAll(selectOptions, param);
      } else {
        MstMedicine mstMedicine = mstMedicineDao.selectIncludeDelByMediCd(selectMedicineCd);
        if (mstMedicine != null) {
          lstMstMedicine = new ArrayList<>();
          lstMstMedicine.add(mstMedicine);
        }
      }
      /* modify by chamaojia 2024-02-28 [10196] Add processing based on "selectMedicaineCd" query --end */
    } else {
      lstMstMedicine = mstMedicineDao.selectAllDel(selectOptions, param);
    }
    // mod FNSI-期限切れ削除済みと表示するの修正 end

    // 禁忌・アレルギーリスト一覧を取得
    MstTabooAllergy param2 = new MstTabooAllergy() {
      {
        setFacilityCd(facilityCd);
      }
    };
	  //add #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 start
    MstMedicineClass paramClass = new MstMedicineClass() {
      {
        setFacilityCd(facilityCd);
      }
    };

    List<MstMedicineClass> mstMedicineClassList = mstMedicineClassDao.selectAllIncludeDeleted(selectOptions, paramClass);
    //add #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 end
    List<MstTabooAllergy> lstMstTabooAllergy = mstTabooAllergyDao.selectAll(selectOptions, param2);
    //add 9706 ljx start
    //???患者の場合、patIdが「-1」である、判断追加、後の処理を実行しない。
    if(-1 == patId){
	  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 start
      if (lstMstMedicine != null && !lstMstMedicine.isEmpty()) {
        for (MstMedicine element : lstMstMedicine) {
          MstMedicineDto newElement = new MstMedicineDto();
          BeanUtils.copyProperties(element, newElement);
          mstMedicineDtoList.add(newElement);
        }
        for (MstMedicineDto mstMedicineDto : mstMedicineDtoList) {
          mstMedicineDto.setIsTaboo(false);
          mstMedicineDto.setIsAllergy(false);
          Integer classCd = mstMedicineDto.getClassCd();
          Optional<MstMedicineClass> found = mstMedicineClassList.stream().filter(data -> data.getClassCd().equals(classCd)).findFirst();
          if (found.isPresent()) {
            MstMedicineClass mstMedicineClass = found.get();
            String classType = "0";
            if (mstMedicineClass.getClassType() != null) {
              classType = String.valueOf((int)mstMedicineClass.getClassType().doubleValue());
            }
            mstMedicineDto.setClassType(classType);
          } else {
            mstMedicineDto.setClassType("0");
          }
        }
      }

      List<Object> objects = new ArrayList<>(mstMedicineDtoList.size());
      objects.addAll(mstMedicineDtoList);
      objects = sortData(objects, "mst_medicine", facilityCd);
      List<MstMedicineDto> res = new ArrayList<>();
      for (Object obj : objects) {
        if (obj instanceof MstMedicineDto) {
          res.add((MstMedicineDto) obj);
        }
      }

      return res;
	  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 end
    }
    //add 9706 ljx end
    // 対象患者のアレルギー情報を取得
    PatMain patMain = patMainDao.selectById(patId);

    try {
      /* modify by shiyw 2023-04-10 [#8271] jdk8->aws jdk17 --start */
      //ArrayList<PatInfoTabooAllergy> lstTabooAllergyInfo = new ObjectMapper().readValue(patMain.getTaboo_allergy_info(), new TypeReference<List<PatInfoTabooAllergy>>() {});
      ArrayList<PatInfoTabooAllergy> lstTabooAllergyInfo = new ObjectMapper().readValue(patMain.getTaboo_allergy_info(), new TypeReference<ArrayList<PatInfoTabooAllergy>>() {});
      /* modify by shiyw 2023-04-10 [#8271] jdk8->aws jdk17 --end */

      // mod FNSI-改修内容6618修正 xuty start
      // 禁忌・アレルギー薬剤リスト
      // ArrayList<Integer> lstTabooAllergyMedicine = new ArrayList<Integer>();
      // 禁忌薬剤リスト
      // ArrayList<Integer> lstTabooMedicine = new ArrayList<Integer>();
      // アレルギー薬剤リスト
      // ArrayList<Integer> lstAllergyMedicine = new ArrayList<Integer>();
      ArrayList<String> lstTabooAllergyMedicine = new ArrayList<String>();
      ArrayList<String> lstTabooMedicine = new ArrayList<String>();
      ArrayList<String> lstAllergyMedicine = new ArrayList<String>();
      // mod FNSI-改修内容6618修正 xuty end

      //add #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 start
      if (lstMstMedicine != null && !lstMstMedicine.isEmpty()) {
        for (MstMedicine element : lstMstMedicine) {
          MstMedicineDto newElement = new MstMedicineDto();
          BeanUtils.copyProperties(element, newElement);
          newElement.setIsAllergy(false);
          newElement.setIsTaboo(false);
          Integer classCd = element.getClassCd();
          Optional<MstMedicineClass> found = mstMedicineClassList.stream().filter(data -> data.getClassCd().equals(classCd)).findFirst();
          if (found.isPresent()) {
            MstMedicineClass mstMedicineClass = found.get();
            String classType = "0";
            if (mstMedicineClass.getClassType() != null) {
              classType = String.valueOf((int)mstMedicineClass.getClassType().doubleValue());
            }
            newElement.setClassType(classType);
          } else {
            newElement.setClassType("0");
          }
          mstMedicineDtoList.add(newElement);
        }
      }
      //add #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 end

      // 患者の禁忌・アレルギー情報毎にチェックを行い、禁忌薬剤リスト・アレルギー薬剤リストを作成する
      for (PatInfoTabooAllergy patInfoTabooAllergy : lstTabooAllergyInfo) {
        if (patInfoTabooAllergy.getCategory_class().equals("0")) {
          // 対象区分が0:"禁忌・アレルギー" → taboo_allergy_cdの値から禁忌・アレルギーマスタを検索後、薬剤コードを取得
          // mod FNSI-改修内容6618修正 xuty start
          // Integer cd = patInfoTabooAllergy.getTaboo_allergy_cd();
          String cd = patInfoTabooAllergy.getTaboo_allergy_cd();
          // mod FNSI-改修内容6618修正 xuty end
          Optional<MstTabooAllergy> mstTabooAllergy = lstMstTabooAllergy.stream().filter(a -> a.getTabooAllergyCd().equals(cd)).findFirst();
          if (mstTabooAllergy.isPresent()) {
            // 禁忌・アレルギーマスタの詳細項目でclassCd(禁忌対象区分)が"1"(薬剤)のデータを抽出
            /* modify by shiyw 2023-04-10 [#8271] jdk8->aws jdk17 --start */
            //ArrayList<MstTabooAllergyDetailInfo> lstTabooAllergyDetailInfo = new ObjectMapper().readValue(mstTabooAllergy.get().getDetailInfo(), new TypeReference<List<MstTabooAllergyDetailInfo>>() {});
            ArrayList<MstTabooAllergyDetailInfo> lstTabooAllergyDetailInfo = new ObjectMapper().readValue(mstTabooAllergy.get().getDetailInfo(), new TypeReference<ArrayList<MstTabooAllergyDetailInfo>>() {});
            /* modify by shiyw 2023-04-10 [#8271] jdk8->aws jdk17 --end */
            // mod FNSI-改修内容6618修正 xuty start
            // List<Integer> lstMedicineCd = lstTabooAllergyDetailInfo.stream().filter(a -> a.getClassCd().equals("1")).map(a -> a.getCd()).collect(Collectors.toList());
            List<String> lstMedicineCd = lstTabooAllergyDetailInfo.stream().filter(a -> a.getClassCd().equals("1")).map(a -> a.getCd()).collect(Collectors.toList());
            // mod FNSI-改修内容6618修正 xuty end
            // add FNSI-改修内容6618修正 xuty start
            List<String> standardMedicineCdList = lstTabooAllergyDetailInfo.stream().filter(a -> a.getClassCd().equals("6")).map(a -> a.getCd()).collect(Collectors.toList());
            if (standardMedicineCdList.size() > 0) {
              List<String> cdList = new ArrayList<>();
              for (String medicineCd : standardMedicineCdList) {
                cdList.add(medicineCd);
              }
              List<String> mstMedicineCdList = mstMedicineDao.selectByStandardMedicineCd(cdList);
              for (String mstMedicineCd : mstMedicineCdList) {
                lstMedicineCd.add(mstMedicineCd);
              }
            }
            // add FNSI-改修内容6618修正 xuty end
            if (patInfoTabooAllergy.getTaboo_allergy_class().equals("1")) {
              // 禁忌
              lstTabooMedicine.addAll(lstMedicineCd);
            } else if (patInfoTabooAllergy.getTaboo_allergy_class().equals("2")) {
              // アレルギー
              lstAllergyMedicine.addAll(lstMedicineCd);
            }
          }

        } else if (patInfoTabooAllergy.getCategory_class().equals("1")) {
          // 対象区分が1:薬剤 → taboo_allergy_cdの値がそのまま薬剤コード
          if (patInfoTabooAllergy.getTaboo_allergy_class().equals("1")) {
            // 禁忌
            lstTabooMedicine.add(patInfoTabooAllergy.getTaboo_allergy_cd());
          } else if (patInfoTabooAllergy.getTaboo_allergy_class().equals("2")) {
            // アレルギー
            lstAllergyMedicine.add(patInfoTabooAllergy.getTaboo_allergy_cd());
          }
        }
      }

      if (lstTabooMedicine.size() > 0 || lstAllergyMedicine.size() > 0) {
        // 禁忌・アレルギー両方に登録がある薬剤コードのリストを作成
        ListUtils.intersection(lstTabooMedicine, lstAllergyMedicine).stream().forEach(a -> lstTabooAllergyMedicine.add(a));
        // mod FNSI-改修内容6618修正 xuty start
        // Set<Integer> setTabooMedicine = new HashSet<Integer>(lstTabooMedicine.stream().filter(a -> !lstTabooAllergyMedicine.contains(a)).collect(Collectors.toList()));
        // Set<Integer> setAllergyMedicine = new HashSet<Integer>(lstAllergyMedicine.stream().filter(a -> !lstTabooAllergyMedicine.contains(a)).collect(Collectors.toList()));
        Set<String> setTabooMedicine = new HashSet<String>(lstTabooMedicine.stream().filter(a -> !lstTabooAllergyMedicine.contains(a)).collect(Collectors.toList()));
        Set<String> setAllergyMedicine = new HashSet<String>(lstAllergyMedicine.stream().filter(a -> !lstTabooAllergyMedicine.contains(a)).collect(Collectors.toList()));
        // mod FNSI-改修内容6618修正 xuty end

        //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 start
        // 薬剤リストを1件ずつ確認して禁忌・アレルギー情報に一致する場合は名称の前に定冠詞をつける
        for (int idx = 0; idx < mstMedicineDtoList.size(); idx++) {
          MstMedicineDto mstMedicine = mstMedicineDtoList.get(idx);
          Integer classCd = mstMedicine.getClassCd();
          Optional<MstMedicineClass> found = mstMedicineClassList.stream().filter(data -> data.getClassCd().equals(classCd)).findFirst();
          if (found.isPresent()) {
            MstMedicineClass mstMedicineClass = found.get();
            String classType = "0";
            if(mstMedicineClass.getClassType() != null){
              classType = String.valueOf((int)mstMedicineClass.getClassType().doubleValue());
            }
            mstMedicine.setClassType(classType);
          } else {
            mstMedicine.setClassType("0");
          }
          if (lstTabooAllergyMedicine.contains(mstMedicine.getMedicineCd().toString())) {
            // 禁忌・アレルギー
            mstMedicine.setIsTaboo(true);
            mstMedicine.setIsAllergy(true);
            mstMedicineDtoList.set(idx, mstMedicine);
          } else if (setTabooMedicine.contains(mstMedicine.getMedicineCd().toString())) {
            // 禁忌
            mstMedicine.setIsTaboo(true);
            mstMedicine.setIsAllergy(false);
            mstMedicineDtoList.set(idx, mstMedicine);
          } else if (setAllergyMedicine.contains(mstMedicine.getMedicineCd().toString())) {
            // アレルギー
            mstMedicine.setIsTaboo(false);
            mstMedicine.setIsAllergy(true);
            mstMedicineDtoList.set(idx, mstMedicine);
          } else {
            mstMedicine.setIsTaboo(false);
            mstMedicine.setIsAllergy(false);
          }
        }
        //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 end
      }
	  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 start
      List<Object> objects = new ArrayList<>(mstMedicineDtoList.size());
      objects.addAll(mstMedicineDtoList);
      objects = sortData(objects, "mst_medicine", facilityCd);
      List<MstMedicineDto> res = new ArrayList<>();
      for (Object obj : objects) {
        if (obj instanceof MstMedicineDto) {
          res.add((MstMedicineDto) obj);
        }
      }

      return res;
	  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 end
    } catch (Exception e) {
	  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 start
      // 禁忌・アレルギー情報取得失敗時は薬剤マスタをそのまま返却
      return mstMedicineDtoList;
	  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 end
    }
  }

  /*
   * 一般名処方マスタ
   */
  @Autowired
  private SysGenericMedicineDao sysGenericMedicineDao;

  @Override
  public Page<SysGenericMedicine> findSysGenericMedicineAll(Pageable pageable) {
    SelectOptions selectOptions = SelectOptions.get();
    List<SysGenericMedicine> sysGenericMedicineList = sysGenericMedicineDao.selectAll(selectOptions);
    return new PageImpl<>(sysGenericMedicineList, pageable, selectOptions.getCount());
  }

  @Override
  public Page<SysGenericMedicine> findSysGenericMedicineAllIncludeDeleted(Pageable pageable) {
    SelectOptions selectOptions = SelectOptions.get();
    List<SysGenericMedicine> sysGenericMedicineList = sysGenericMedicineDao.selectAllIncludeDeleted(selectOptions);
    return new PageImpl<>(sysGenericMedicineList, pageable, selectOptions.getCount());
  }

  /*
   * 薬剤セットマスタ
   */
  @Autowired
  private MstMedicineSetDao mstMedicineSetDao;

  @Override
  public Page<MstMedicineSet> findMstMedicineSetAll(Pageable pageable, MstMedicineSet params) {
    SelectOptions selectOptions = SelectOptions.get();

    List<MstMedicineSet> mstMedicineSetList = mstMedicineSetDao.selectAll(selectOptions, params);
    return new PageImpl<>(mstMedicineSetList, pageable, selectOptions.getCount());
  }

  @Override
  public List<MstMedicineSet> findMstMedicineSetWithDeleted(String facilityCd, Long patId) {
    SelectOptions selectOptions = SelectOptions.get();
    MstMedicineSet param = new MstMedicineSet() {
      {
        setFacilityCd(facilityCd);
      }
    };
    // 薬剤セットリスト一覧を取得
    List<MstMedicineSet> listMstMedicineSet = mstMedicineSetDao.selectWithDeleted(selectOptions, param);
    // 禁忌・アレルギーリスト一覧を取得
    MstTabooAllergy param2 = new MstTabooAllergy() {
      {
        setFacilityCd(facilityCd);
      }
    };
    List<MstTabooAllergy> lstMstTabooAllergy = mstTabooAllergyDao.selectAll(selectOptions, param2);
    //add 9706 ljx start
    //???患者の場合、patIdが「-1」である、判断追加、後の処理を実行しない。
    if(-1 == patId){
      return listMstMedicineSet;
    }
    //add 9706 ljx end
    // 対象患者のアレルギー情報を取得
    PatMain patMain = patMainDao.selectById(patId);

    try {
      // 禁忌アレルギー薬剤／調製薬剤を含む薬剤セット名称に接頭語を付与
      prefixMedicineSetTabooAllergy(facilityCd, listMstMedicineSet, lstMstTabooAllergy, patMain);

      return listMstMedicineSet;
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
      // 禁忌・アレルギー情報取得失敗時は薬剤セットマスタをそのまま返却
      return listMstMedicineSet;
    }
  }

  @Override
  public List<MstMedicineSet> findMstMedicineSetAllTabooAllergy(String facilityCd, Long patId) {
    SelectOptions selectOptions = SelectOptions.get();
    MstMedicineSet param = new MstMedicineSet() {
      {
        setFacilityCd(facilityCd);
      }
    };
    // 薬剤セットリスト一覧を取得
    List<MstMedicineSet> listMstMedicineSet = mstMedicineSetDao.selectAll(selectOptions, param);
    // 禁忌・アレルギーリスト一覧を取得
    MstTabooAllergy param2 = new MstTabooAllergy() {
      {
        setFacilityCd(facilityCd);
      }
    };
    List<MstTabooAllergy> lstMstTabooAllergy = mstTabooAllergyDao.selectAll(selectOptions, param2);
    //add 9706 ljx start
    //???患者の場合、patIdが「-1」である、判断追加、後の処理を実行しない。
    if(-1 == patId){
      return listMstMedicineSet;
    }
    //add 9706 ljx end
    // 対象患者のアレルギー情報を取得
    PatMain patMain = patMainDao.selectById(patId);

    try {
      // 禁忌アレルギー薬剤／調製薬剤を含む薬剤セット名称に接頭語を付与
      prefixMedicineSetTabooAllergy(facilityCd, listMstMedicineSet, lstMstTabooAllergy, patMain);

      return listMstMedicineSet;
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
      // 禁忌・アレルギー情報取得失敗時は薬剤セットマスタをそのまま返却
      return listMstMedicineSet;
    }
  }

  /**
   * 薬剤セットマスタのリストに対し、禁忌アレルギー薬剤／調製薬剤を含む薬剤セット名称に接頭語を付与します。
   *
   * @param facilityCd          施設コード
   * @param mstMedicineSetList  薬剤セットマスタのリスト
   * @param mstTabooAllergyList 禁忌・アレルギーマスタのリスト
   * @param patMain             患者情報
   */
  private void prefixMedicineSetTabooAllergy(String facilityCd, List<MstMedicineSet> mstMedicineSetList, List<MstTabooAllergy> mstTabooAllergyList, PatMain patMain) throws Exception {
    // 患者の禁忌・アレルギー情報
    ArrayList<PatInfoTabooAllergy> patInfoTabooAllergyList = new ObjectMapper().readValue(patMain.getTaboo_allergy_info(), new TypeReference<ArrayList<PatInfoTabooAllergy>>() {});

    // 禁忌薬剤リスト
    ArrayList<String> tabooMedicineList = new ArrayList<String>();
    // アレルギー薬剤リスト
    ArrayList<String> allergyMedicineList = new ArrayList<String>();
    // 禁忌調製薬剤リスト
    ArrayList<String> tabooMedicineMixList = new ArrayList<String>();
    // アレルギー調製薬剤リスト
    ArrayList<String> allergyMedicineMixList = new ArrayList<String>();

    // 患者の禁忌・アレルギー情報毎にチェックを行い、禁忌薬剤/禁忌調整薬剤リスト・アレルギー薬剤/アレルギー調整薬剤リストを作成する
    for (PatInfoTabooAllergy patInfoTabooAllergy : patInfoTabooAllergyList) {

      if (patInfoTabooAllergy.getCategory_class().equals("0")) {
        // 対象区分が0:"禁忌・アレルギー" → taboo_allergy_cdの値から禁忌・アレルギーマスタを検索後、薬剤コード・調整薬剤コードを取得
        String cd = patInfoTabooAllergy.getTaboo_allergy_cd();
        Optional<MstTabooAllergy> mstTabooAllergy = mstTabooAllergyList.stream().filter(a -> a.getTabooAllergyCd().equals(cd)).findFirst();
        if (mstTabooAllergy.isPresent()) {
          ArrayList<MstTabooAllergyDetailInfo> tabooAllergyDetailInfoList = new ObjectMapper().readValue(mstTabooAllergy.get().getDetailInfo(), new TypeReference<ArrayList<MstTabooAllergyDetailInfo>>() {});

          // 禁忌・アレルギーマスタの詳細項目でclassCd(禁忌対象区分)が"1"(薬剤)のcd(禁忌対象コード)を取得し、薬剤コードリストを作成する
          List<String> medicineCdList = tabooAllergyDetailInfoList.stream().filter(a -> a.getClassCd().equals("1")).map(a -> a.getCd()).collect(Collectors.toList());
          // 禁忌・アレルギーマスタの詳細項目でclassCd(禁忌対象区分)が"2"(調整薬剤)のcd(禁忌対象コード)を取得し、調整薬剤コードリストを作成する
          List<String> medicineMixCdList = tabooAllergyDetailInfoList.stream().filter(a -> a.getClassCd().equals("2")).map(a -> a.getCd()).collect(Collectors.toList());

          if (patInfoTabooAllergy.getTaboo_allergy_class().equals("1")) {
            // 禁忌薬剤リストに追加
            tabooMedicineList.addAll(medicineCdList);
            // 禁忌調製薬剤リストに追加
            tabooMedicineMixList.addAll(medicineMixCdList);
          } else if (patInfoTabooAllergy.getTaboo_allergy_class().equals("2")) {
            // アレルギー薬剤リストに追加
            allergyMedicineList.addAll(medicineCdList);
            // アレルギー調整薬剤リストに追加
            allergyMedicineMixList.addAll(medicineMixCdList);
          }
        }

      } else if (patInfoTabooAllergy.getCategory_class().equals("1")) {
        // 対象区分が1:薬剤 → taboo_allergy_cdの値がそのまま薬剤コード
        if (patInfoTabooAllergy.getTaboo_allergy_class().equals("1")) {
          // 禁忌薬剤リストに追加
          tabooMedicineList.add(patInfoTabooAllergy.getTaboo_allergy_cd());
        } else if (patInfoTabooAllergy.getTaboo_allergy_class().equals("2")) {
          // アレルギー薬剤リストに追加
          allergyMedicineList.add(patInfoTabooAllergy.getTaboo_allergy_cd());
        }

      } else if (patInfoTabooAllergy.getCategory_class().equals("2")) {
        // 対象区分が2:調整薬剤 → taboo_allergy_cdの値がそのまま調整薬剤コード
        if (patInfoTabooAllergy.getTaboo_allergy_class().equals("1")) {
          // 禁忌調製薬剤リストに追加
          tabooMedicineMixList.add(patInfoTabooAllergy.getTaboo_allergy_cd());
        } else if (patInfoTabooAllergy.getTaboo_allergy_class().equals("2")) {
          // アレルギー調製薬剤リストに追加
          allergyMedicineMixList.add(patInfoTabooAllergy.getTaboo_allergy_cd());
        }
      }
    }

    // 禁忌薬剤セットリスト
    ArrayList<String> tabooMedicineSetList = new ArrayList<String>();
    // アレルギー薬剤セットリスト
    ArrayList<String> allergyMedicineSetList = new ArrayList<String>();

    if (tabooMedicineList.size() > 0) {
      // 禁忌薬剤が含まれる薬剤セットを取得し、禁忌薬剤セットリストに追加
      mstMedicineSetDao.selectByMedicineCdList(facilityCd, 1, tabooMedicineList).stream().forEach(a -> tabooMedicineSetList.add(a.getMedicineSetCd().toString()));
      // 禁忌薬剤が含まれる調整薬剤を取得し、禁忌調整薬剤リストに追加
      mstMedicineMixDao.selectByMedicineCdList(facilityCd, tabooMedicineList).stream().forEach(a -> tabooMedicineMixList.add(a.getMedicineMixCd().toString()));
      if (tabooMedicineMixList.size() > 0) {
        // 禁忌調整薬剤が含まれる薬剤セットを取得し、禁忌薬剤セットリストに追加
        mstMedicineSetDao.selectByMedicineCdList(facilityCd, 2, tabooMedicineMixList).stream().forEach(a -> tabooMedicineSetList.add(a.getMedicineSetCd().toString()));
      }
    }

    if (allergyMedicineList.size() > 0) {
      // アレルギー薬剤が含まれる薬剤セットを取得し、アレルギー薬剤セットリストに追加
      mstMedicineSetDao.selectByMedicineCdList(facilityCd, 1, allergyMedicineList).stream().forEach(a -> allergyMedicineSetList.add(a.getMedicineSetCd().toString()));
      // アレルギー薬剤が含まれる調整薬剤を取得し、アレルギー調整薬剤リストに追加
      mstMedicineMixDao.selectByMedicineCdList(facilityCd, allergyMedicineList).stream().forEach(a -> allergyMedicineMixList.add(a.getMedicineMixCd().toString()));
      if (allergyMedicineMixList.size() > 0) {
        // アレルギー調整薬剤が含まれる薬剤セットを取得し、アレルギー薬剤セットリストに追加
        mstMedicineSetDao.selectByMedicineCdList(facilityCd, 2, allergyMedicineMixList).stream().forEach(a -> allergyMedicineSetList.add(a.getMedicineSetCd().toString()));
      }
    }

    if (tabooMedicineSetList.size() > 0 || allergyMedicineSetList.size() > 0) {
      // 禁忌・アレルギー薬剤セットリスト
      ArrayList<String> tabooAllergyMedicineSetList = new ArrayList<String>();

      // 禁忌・アレルギー両方に登録がある薬剤セットコードのリストを作成
      ListUtils.intersection(tabooMedicineSetList, allergyMedicineSetList).stream().forEach(a -> tabooAllergyMedicineSetList.add(a));
      // 禁忌のみ登録がある薬剤セットコードのリスト(重複無し)を作成
      Set<String> tabooMedicineSetSet = new HashSet<String>(tabooMedicineSetList.stream().filter(a -> !tabooAllergyMedicineSetList.contains(a)).collect(Collectors.toList()));
      // アレルギーのみ登録がある薬剤セットコードのリスト(重複無し)を作成
      Set<String> allergyMedicineSetSet = new HashSet<String>(allergyMedicineSetList.stream().filter(a -> !tabooAllergyMedicineSetList.contains(a)).collect(Collectors.toList()));

      // 薬剤セットリストを1件ずつ確認して禁忌・アレルギー情報に一致する場合は名称の前に定冠詞をつける
      for (int idx = 0; idx < mstMedicineSetList.size(); idx++) {
        MstMedicineSet mstMedicineSet = mstMedicineSetList.get(idx);
        if (tabooAllergyMedicineSetList.contains(mstMedicineSet.getMedicineSetCd().toString())) {
          // 禁忌・アレルギー
          mstMedicineSetList.get(idx).setMedicineSetName("【禁忌・ｱﾚﾙｷﾞｰ】" + mstMedicineSet.getMedicineSetName());
        } else if (tabooMedicineSetSet.contains(mstMedicineSet.getMedicineSetCd().toString())) {
          // 禁忌
          mstMedicineSetList.get(idx).setMedicineSetName("【禁忌】" + mstMedicineSet.getMedicineSetName());
        } else if (allergyMedicineSetSet.contains(mstMedicineSet.getMedicineSetCd().toString())) {
          // アレルギー
          mstMedicineSetList.get(idx).setMedicineSetName("【ｱﾚﾙｷﾞｰ】" + mstMedicineSet.getMedicineSetName());
        }
      }
    }
  }

    /*
     * 薬剤グループマスタ
     */
    @Autowired
    private MstMedicineGroupDao mstMedicineGroupDao;

    @Override
    public Page<MstMedicineGroup> findMstMedicineGroupAll(Pageable pageable, MstMedicineGroup params) {
      SelectOptions selectOptions = SelectOptions.get();

      List<MstMedicineGroup> mstMedicineGroupList = mstMedicineGroupDao.selectAll(selectOptions, params);
      return new PageImpl<>(mstMedicineGroupList, pageable, selectOptions.getCount());
    }


    // add 投薬支援マスタ 削除されたデータの処理 孔 start
    @Override
    public Page<MstMedicineGroup> findMstMedicineGroupAllIncludeDeleted(Pageable pageable, MstMedicineGroup params) {
      SelectOptions selectOptions = SelectOptions.get();

      List<MstMedicineGroup> mstMedicineGroupList = mstMedicineGroupDao.selectAllIncludeDeleted(selectOptions, params);
      return new PageImpl<>(mstMedicineGroupList, pageable, selectOptions.getCount());
    }
    // add 投薬支援マスタ 削除されたデータの処理 孔 end

    /*
     * 患者カレンダーレイアウトマスタ
     */
    @Autowired
    private MstPatCalendarLayoutDao mstPatCalendarLayoutDao;

    @Override
    public Page<MstPatCalendarLayout> findMstPatCalendarLayoutAll(Pageable pageable, MstPatCalendarLayout params) {
      SelectOptions selectOptions = SelectOptions.get();

      List<MstPatCalendarLayout> mstPatCalendarLayoutList = mstPatCalendarLayoutDao.selectAll(selectOptions, params);
      return new PageImpl<>(mstPatCalendarLayoutList, pageable, selectOptions.getCount());
    }

    /*
     * マルチ患者一覧レイアウトマスタ
     */
    @Autowired
    private MstPatListLayoutDao mstPatListLayoutDao;

    @Override
    public Page<MstPatListLayout> findMstPatListLayoutAll(Pageable pageable, MstPatListLayout params) {
      SelectOptions selectOptions = SelectOptions.get();

      List<MstPatListLayout> mstPatListLayoutList = mstPatListLayoutDao.selectAll(selectOptions, params);
      return new PageImpl<>(mstPatListLayoutList, pageable, selectOptions.getCount());
    }

    @Override
    @Transactional
    public void updateMstPatListLayoutByCd(long pat_list_layout_cd, String payload) throws Exception {

      ObjectMapper mapper = new ObjectMapper();
      MstPatListLayout mstPatListLayout = mapper.readValue(payload, MstPatListLayout.class);

      mstPatListLayoutDao.updateByCd(pat_list_layout_cd, mstPatListLayout);
      return;
    }

    /*
     * 患者メモマスタ
     */
    @Autowired
    private MstPatMemoDao mstPatMemoDao;

    @Override
    public Page<MstPatMemo> findMstPatMemoAll(Pageable pageable, MstPatMemo params) {
      SelectOptions selectOptions = SelectOptions.get();

      List<MstPatMemo> mstPatMemoList = mstPatMemoDao.selectAll(selectOptions, params);
      return new PageImpl<>(mstPatMemoList, pageable, selectOptions.getCount());
    }

    /**
     * 患者経過総合ビューアレイアウトマスタ
     * {@link MstPatViewerLayoutDao}
     */
    @Autowired
    private MstPatViewerLayoutDao mstPatViewerLayoutDao;

    /**
     * {@inheritDoc}
     */
    @Override
    public Page<MstPatViewerLayout> findMstPatViewerLayoutAll(Pageable pageable, MstPatViewerLayout params) {
      SelectOptions selectOptions = SelectOptionsUtils.get(pageable, true);
      //mod 障害票一覧_NKK.xlsxの3707 対応 韓 start
      // List<MstPatViewerLayout> mstPatViewerLayoutList = mstPatViewerLayoutDao.selectAll(selectOptions, params);
      List<MstPatViewerLayout> mstPatViewerLayoutList = mstPatViewerLayoutDao.selectAll(params);
      //mod 障害票一覧_NKK.xlsxの3707 対応 韓 end
      return new PageImpl<>(mstPatViewerLayoutList, pageable, selectOptions.getCount());
    }

  /* modify by chamaojia 2023-06-05 モニタレイアウトマスタ下拉框可以选择バイタル的项目  --start */
  /**
     * {@inheritDoc}
     */
    @Override
    public List<MstPatViewerLayoutMonitorItem> selectMonitorItemForMstPatViewerLayout(String facilityCd, String vitalMonitorClass, String isAllDisp) {

      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("患者経過総合ビューアレイアウトマスタ：バイタル・モニタ項目取得 開始:施設コード:[" + facilityCd + "]");
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      List<MstPatViewerLayoutMonitorItem> result = mstPatViewerLayoutDao.selectMonitorItem(facilityCd, vitalMonitorClass, isAllDisp);

      /* ========== 2024/06/20 #9312 レイアウトマスタバイタル・モニタ項目 Start ========== */
      /* 現在の仕様によると、「sys_monitor_item関連_9312_9183.xlsx」Sheet1に記録、これらのアイテムは追加削除し。
       * 原因：青田さん確認後の仕様、以下のアイテムは排除し */
      if (!CollectionUtils.isEmpty(result)) {
        // レイアウトマスタバイタル・モニタ項目 排除項目
        List<String> exclusionCds =
          List.of("Z101","Z11","Z102","Z202","Z222","Z103","Z104","Z232","Z354","Z364","Z21","31","0");
        result = result.stream()
          .filter(r -> !exclusionCds.contains(r.getMoniDataNo()))
          .toList();
      }
      /* ========== 2024/06/20 #9312 レイアウトマスタバイタル・モニタ項目 End ========== */

      eventLogMessage.setLogMessage("患者経過総合ビューアレイアウトマスタ：バイタル・モニタ項目取得 終了:検索件数:[" + result.size() + "]");
      eventLogMessage.setSqlIdentification("(facility_cd = " + facilityCd + ")");
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, "MstPatViewerLayoutDao/selectMonitorItem");
      return result;
    }
  /* modify by chamaojia 2023-06-05 モニタレイアウトマスタ下拉框可以选择バイタル的项目  --end */

  /*
     * 手技マスタ
     */
    @Autowired
    private MstProcedureDao mstProcedureDao;

    @Override
    public Page<MstProcedure> findMstProcedureAll(Pageable pageable, MstProcedure params) {
      SelectOptions selectOptions = SelectOptions.get();

      List<MstProcedure> mstProcedureList = mstProcedureDao.selectAll(selectOptions, params);
      return new PageImpl<>(mstProcedureList, pageable, selectOptions.getCount());
    }

    @Override
    public Page<MstProcedure> findMstProcedureAllIncludeDeleted(Pageable pageable, MstProcedure params) {
      SelectOptions selectOptions = SelectOptions.get();

      List<MstProcedure> mstProcedureList = mstProcedureDao.selectAllIncludeDeleted(selectOptions, params);
      return new PageImpl<>(mstProcedureList, pageable, selectOptions.getCount());
    }

    /*
     * 続柄マスタ
     */
    @Autowired
    private MstRelationshipDao mstRelationshipDao;

    @Override
    public Page<MstRelationship> findMstRelationshipAll(Pageable pageable, MstRelationship params) {
      SelectOptions selectOptions = SelectOptions.get();

      List<MstRelationship> mstRelationshipList = mstRelationshipDao.selectAll(selectOptions, params);
      return new PageImpl<>(mstRelationshipList, pageable, selectOptions.getCount());
    }

    /**
     * 続柄マスタ取得，包含删除
     *
     * @param pageable
     * @param params
     * @return
     */
    @Override
    public Page<MstRelationship> findMstRelationshipAllIncludeDel(Pageable pageable, MstRelationship params) {
      SelectOptions selectOptions = SelectOptions.get();

      List<MstRelationship> mstRelationshipList = mstRelationshipDao.selectAllIncludeDel(selectOptions, params);
      return new PageImpl<>(mstRelationshipList, pageable, selectOptions.getCount());
    }

    /*
     * 透析室・ベッドグループマスタ
     */
    @Autowired
    private MstRoomBedGroupDao mstRoomBedGroupDao;

    @Override
    public Page<MstRoomBedGroup> findMstRoomBedGroupAll(Pageable pageable, MstRoomBedGroup params) {
      SelectOptions selectOptions = SelectOptions.get();

      List<MstRoomBedGroup> mstRoomList = mstRoomBedGroupDao.selectAll(selectOptions, params);
      return new PageImpl<>(mstRoomList, pageable, selectOptions.getCount());
    }

    /*
     * 重症度マスタ
     */
    @Autowired
    private MstSeverityDao mstSeverityDao;

    @Override
    public Page<MstSeverity> findMstSeverityAll(Pageable pageable, MstSeverity params) {
      SelectOptions selectOptions = SelectOptions.get();

      List<MstSeverity> mstSeverityList = mstSeverityDao.selectAll(selectOptions, params);
      return new PageImpl<>(mstSeverityList, pageable, selectOptions.getCount());
    }

    @Override
    public Page<MstSeverity> findMstSeverityAllIncludeDel(Pageable pageable, MstSeverity params) {
      SelectOptions selectOptions = SelectOptions.get();

      List<MstSeverity> mstSeverityList = mstSeverityDao.selectAllIncludeDel(selectOptions, params);
      return new PageImpl<>(mstSeverityList, pageable, selectOptions.getCount());
    }

    /*
     * 禁忌・アレルギーマスタ
     */
    @Autowired
    private MstTabooAllergyDao mstTabooAllergyDao;

    @Override
    public Page<MstTabooAllergy> findMstTabooAllergyAll(Pageable pageable, MstTabooAllergy params) {
      SelectOptions selectOptions = SelectOptions.get();

      List<MstTabooAllergy> mstTabooAllergyList = mstTabooAllergyDao.selectAll(selectOptions, params);
      return new PageImpl<>(mstTabooAllergyList, pageable, selectOptions.getCount());
    }

    @Override
    public Page<MstTabooAllergy> findMstTabooAllergyAllIncludeDeleted(Pageable pageable, MstTabooAllergy params) {
      SelectOptions selectOptions = SelectOptions.get();
      List<MstTabooAllergy> mstTabooAllergyList = mstTabooAllergyDao.selectAllIncludeDeleted(selectOptions, params);
      return new PageImpl<>(mstTabooAllergyList, pageable, selectOptions.getCount());
    }

    /*
     * 搬送区分マスタ
     */
    @Autowired
    private MstTransportDao mstTransportDao;

    @Override
    public Page<MstTransport> findMstTransportAll(Pageable pageable, MstTransport params) {
      SelectOptions selectOptions = SelectOptions.get();

      List<MstTransport> mstTransportList = mstTransportDao.selectAll(selectOptions, params);
      return new PageImpl<>(mstTransportList, pageable, selectOptions.getCount());
    }

// add FutreNetWeb+SI課題管理No4770対応 趙 start
    /*
     * 検査セットマスタ
     */
    @Autowired
    private MstExamSetDao mstExamSetDao;

    @Override
    public Page<MstExamSet> findMstExamAll(Pageable pageable, MstExamSet params) {
      SelectOptions selectOptions = SelectOptions.get();

      List<MstExamSet> mstExamSetList = mstExamSetDao.selectAll(selectOptions, params);
      return new PageImpl<>(mstExamSetList, pageable, selectOptions.getCount());
    }
// add FutreNetWeb+SI課題管理No4770対応 趙 end

    /**
     * 搬送区分マスタ取得，包含删除
     *
     * @param pageable
     * @param params
     * @return
     */
    @Override
    public Page<MstTransport> findMstTransportAllIncludeDel(Pageable pageable, MstTransport params) {
      SelectOptions selectOptions = SelectOptions.get();

      List<MstTransport> mstTransportList = mstTransportDao.selectAllIncludeDel(selectOptions, params);
      return new PageImpl<>(mstTransportList, pageable, selectOptions.getCount());
    }

    /*
     * 治療方法マスタ
     */
    @Autowired
    private MstTreatmentDao mstTreatmentDao;

    @Override
    public Page<MstTreatment> findMstTreatmentAll(Pageable pageable, MstTreatment params) {
      SelectOptions selectOptions = SelectOptions.get();

      List<MstTreatment> mstTreatmentList = mstTreatmentDao.selectAll(selectOptions, params);
      return new PageImpl<>(mstTreatmentList, pageable, selectOptions.getCount());
    }

    // FNSI-修正 マスタ削除の対応 chen add start
    @Override
    public Page<MstTreatment> findMstTreatmentAllDel(Pageable pageable, MstTreatment params) {
      SelectOptions selectOptions = SelectOptions.get();

      List<MstTreatment> mstTreatmentList = mstTreatmentDao.selectAllDel(selectOptions, params);
      return new PageImpl<>(mstTreatmentList, pageable, selectOptions.getCount());
    }
// FNSI-修正 マスタ削除の対応 chen add end

    @Override
    public Page<MstTreatment> findMstTreatmentAllIncludeDeleted(Pageable pageable, MstTreatment params) {
      SelectOptions selectOptions = SelectOptions.get();

      List<MstTreatment> mstTreatmentList = mstTreatmentDao.selectAllIncludeDeleted(selectOptions, params);
      return new PageImpl<>(mstTreatmentList, pageable, selectOptions.getCount());
    }

    @Override
    public String findMstTreatmentNameByCd(Integer treatmentCd) {
      String treatmentName = null;
      MstTreatment mstTreatment = mstTreatmentDao.selectByCd(treatmentCd);
      if (mstTreatment != null) {
        treatmentName = mstTreatment.getTreatmentName();
      }
      return treatmentName;
    }

    @Override
    public List<MstTreatment> findMstTreatmentList(MstTreatment params) {
      SelectOptions selectOptions = SelectOptions.get();

      return mstTreatmentDao.selectAll(selectOptions, params);
    }

    /*
     * 治療方法セットマスタ
     */
    @Autowired
    private MstTreatmentSetDao mstTreatmentSetDao;

    @Override
    public Page<MstTreatmentSet> findMstTreatmentSetAll(Pageable pageable, MstTreatmentSet params) {
      SelectOptions selectOptions = SelectOptions.get();

      List<MstTreatmentSet> mstTreatmentSetList = mstTreatmentSetDao.selectAll(selectOptions, params);
      return new PageImpl<>(mstTreatmentSetList, pageable, selectOptions.getCount());
    }

    @Override
    public List<MstTreatmentSet> findMstTreatmentSetByCd(Integer treatment_set_cd) {
      return mstTreatmentSetDao.selectByCd(treatment_set_cd);
    }

    /*
     * 利用者マスタ
     */
    @Autowired
    private MstPersonalUserDao mstPersonalUserDao;
    @Autowired
    private MstUserService mstUserService;

    @Override
    public Page<MstPersonalUser> findMstPersonalUserAll(Pageable pageable, String facility_cd) {
      SelectOptions selectOptions = SelectOptions.get();
      MasterDataResponse masterResponse = mstUserService.getSortMasterData(facility_cd, true);
      List<Long> userIdList = new ArrayList<>();
      for (Map<String, Object> item : masterResponse.localDataSource.data) {
        userIdList.add(Long.parseLong(item.get("userId").toString()));
      }
      List<MstPersonalUser> mstPersonalUserList = mstPersonalUserDao.selectAll(selectOptions, facility_cd, "0");
      List<MstPersonalUser> mstPersonalUserListResult = new ArrayList<>();
      for (Long userId : userIdList) {
        for (MstPersonalUser mstPersonalUser : mstPersonalUserList) {
          if (userId.equals(mstPersonalUser.getUserId())) {
            mstPersonalUserListResult.add(mstPersonalUser);
            break;
          }
        }
      }
      return new PageImpl<>(mstPersonalUserListResult, pageable, selectOptions.getCount());
    }

    @Override
    public Page<MstPersonalUser> findMstPersonalUserAllIncludeDel(Pageable pageable, String facility_cd){
      SelectOptions selectOptions = SelectOptions.get();
      // mod #11608 利用者選択肢の並び順が利用者表示順マスタの並びと異なる 関 start
      MasterDataResponse masterResponse = mstUserService.getSortMasterData(facility_cd, true);
      List<Long> userIdList = masterResponse.localDataSource.data.stream()
        .map(item -> Long.parseLong(item.get("userId").toString()))
        .collect(Collectors.toList());

      List<MstPersonalUser> mstPersonalUserList = mstPersonalUserDao.selectAllIncludeDel(selectOptions, facility_cd);

      Map<Long, MstPersonalUser> userInfoMap = new HashMap<>();
      for (MstPersonalUser user : mstPersonalUserList) {
        userInfoMap.put(user.getUserId(), user);
      }

      List<MstPersonalUser> sortedList = new ArrayList<>(mstPersonalUserList.size());
      for (Long id : userIdList) {
        MstPersonalUser user = userInfoMap.remove(id);
        if (user != null) {
          sortedList.add(user);
        }
      }
      for (MstPersonalUser user : mstPersonalUserList) {
        if (userInfoMap.containsKey(user.getUserId())) {
          sortedList.add(user);
        }
      }

      return new PageImpl<>(sortedList, pageable, selectOptions.getCount());
      // mod #11608 利用者選択肢の並び順が利用者表示順マスタの並びと異なる 関 end
    }

    /**
     * 利用者マスタ,有効利用者
     * @param pageable
     * @param facility_cd
     * @return
     */
    @Override
    public Page<MstPersonalUser> findMstPersonalUserInUse(Pageable pageable, String facility_cd) {
      List<MstUserAuthentication> userAuthenticationList = mstUserAuthenticationDao.selectByFacility(facility_cd);
      List<Long> userIdList = userAuthenticationList.stream().map(item -> item.getUserId()).collect(Collectors.toList());
      SelectOptions selectOptions = SelectOptions.get();
      List<MstPersonalUser> mstPersonalUserList = mstPersonalUserDao.selectAllIncludeDel(selectOptions, facility_cd);
      List<MstPersonalUser> collect = mstPersonalUserList.parallelStream().filter(item -> userIdList.indexOf(item.getUserId()) > -1).collect(Collectors.toList());
      return new PageImpl<>(collect, pageable, selectOptions.getCount());
    }

    @Override
    public List<MstPersonalUser> getMstPersonalUserNameByIdList(List<Long> listUserId) {
      return mstPersonalUserDao.selectByIdList(listUserId);
    }

    /*
     * VAマスタ
     */
    @Autowired
    private MstVaDao mstVaDao;

    @Override
    public Page<MstVa> findMstVaAll(Pageable pageable, MstVa params) {
      SelectOptions selectOptions = SelectOptions.get();

      List<MstVa> mstVaList = mstVaDao.selectAll(selectOptions, params);
      return new PageImpl<>(mstVaList, pageable, selectOptions.getCount());
    }

    // FNSI-修正 マスタ削除の対応 chen add start
    @Override
    public Page<MstVa> findMstVaAllNoDel(Pageable pageable, MstVa params) {
      SelectOptions selectOptions = SelectOptions.get();

      List<MstVa> mstVaList = mstVaDao.selectAllNoDel(selectOptions, params);
      return new PageImpl<>(mstVaList, pageable, selectOptions.getCount());
    }
// FNSI-修正 マスタ削除の対応 chen add end
    /*
     * VAマスタ（削除済み含む）
     */
    @Override
    public List<MstVa> findMstVaAllIncludeDel(String facilityCd) {
      return mstVaDao.selectByFacilityCd(facilityCd);
    }

    /*
     * 病棟マスタ
     */
    @Autowired
    private MstWardDao mstWardDao;

    @Override
    public Page<MstWard> findMstWardAll(Pageable pageable, MstWard params) {
      SelectOptions selectOptions = SelectOptions.get();

      List<MstWard> mstWardList = mstWardDao.selectAll(selectOptions, params);
      return new PageImpl<>(mstWardList, pageable, selectOptions.getCount());
    }

    @Override
    public Page<MstWard> findMstWardAllIncludeDel(Pageable pageable, MstWard params) {
      SelectOptions selectOptions = SelectOptions.get();

      List<MstWard> mstWardList = mstWardDao.selectAllIncludeDel(selectOptions, params);
      return new PageImpl<>(mstWardList, pageable, selectOptions.getCount());
    }

    /*
     * 住所マスタ
     */
    @Autowired
    private SysAddressDao sysAddressDao;

    @Override
    public Page<SysAddress> findSysAddressAll(Pageable pageable, SysAddress params) {
      /* add by chamaojia 2024-04-08 [10473] half width full width conversion addition --start */
      if (params.getSearchString() != null) {
        params.setAddress(StrUtils.toFullWidth(params.getSearchString()));
        params.setAddressKana(StrUtils.toHalfWidth(params.getSearchString()));
        params.setZipCd(StrUtils.toHalfWidth(params.getSearchString()));
      }
      /* add by chamaojia 2024-04-08 [10473] half width full width conversion addition --end */
      SelectOptions selectOptions = SelectOptionsUtils.get(pageable, true);
      List<SysAddress> sysAddressList = sysAddressDao.selectAll(selectOptions, params);
      return new PageImpl<>(sysAddressList, pageable, selectOptions.getCount());
    }

    /*
     * 国名マスタ
     */
    @Autowired
    private SysCountryDao sysCountryDao;

    @Override
    public Page<SysCountry> findSysCountryAll(Pageable pageable) {
      SelectOptions selectOptions = SelectOptions.get();

      List<SysCountry> sysCountryList = sysCountryDao.selectAll(selectOptions);
      return new PageImpl<>(sysCountryList, pageable, selectOptions.getCount());
    }

    /*
     * デバイスエッジマスタ
     */
    @Autowired
    private MstDeviceEdgeDao mstDeviceEdgeDao;

    @Override
    @Transactional
    public void saveMstDeviceEdge(Map<String, List<String>> payload) throws Exception {
      try {
        ObjectMapper mapper = new ObjectMapper();
      /*
      List<Map<String, String>> saveRecords = payload.get("saveRecords");

      for (int i = 0; i < saveRecords.size(); i++) {

        // 更新対象レコード取得
        Map<String, String> recordObj = saveRecords.get(i);
        // 削除製造番号
        String deleteSerialNo = recordObj.get("deleteSerialNo");
        MstDeviceEdge mstDeviceEdge = mapper.readValue(recordObj.get("record"), MstDeviceEdge.class);

        if (deleteSerialNo != null) {
          // 削除製造番号がnullでなければ削除処理
          mstDeviceEdgeDao.deleteByCd(deleteSerialNo);
        } else if (orgSerialNo.isEmpty()) {
          // 元の製造番号が空なら新規レコード
          mstDeviceEdgeDao.insert(mstDeviceEdge);
        } else {
          mstDeviceEdgeDao.update(mstDeviceEdge);
        }

      }
      */

        // 登録処理
        for (int i = 0; payload.get("insertRecord").size() > i; i++) {
          MstDeviceEdge mstDeviceEdge = mapper.readValue(payload.get("insertRecord").get(i), MstDeviceEdge.class);
          mstDeviceEdgeDao.insert(mstDeviceEdge);
          // mod #8403 【デグレ】デバイスエッジマスタで新規レコードが保存できない dou start
          //add by ShiHongda 2023-02-01 [Instead of Trigger: tg_sync_mst_device_edge] --start /
          // mstDeviceEdgeDao.insertMntDeviceEdgeStateByODE(mstDeviceEdge);
          mstDeviceEdgeTrigger.triggerInsert(mstDeviceEdge);
          //add by ShiHongda 2023-02-01 [Instead of Trigger: tg_sync_mst_device_edge] --end /
          // mod #8403 【デグレ】デバイスエッジマスタで新規レコードが保存できない dou end
        }

        // 更新処理
        for (int i = 0; payload.get("updateRecord").size() > i; i++) {
          MstDeviceEdge mstDeviceEdge = mapper.readValue(payload.get("updateRecord").get(i), MstDeviceEdge.class);

          //DB更新ログ出力ロジック wp start

          String mmsTbN = "mst_device_edge";

          // SQL検索条件
          StringBuffer wheres = new StringBuffer("");
          wheres.append(" WHERE\n");
          wheres.append(" serial_no = '" + mstDeviceEdge.getSerialNo() + "'" + "\n");
          // logCommon設定
          // logCommon設定
          DataUpdateLogCommonNew logCommon = getLogCommon(mstDeviceEdgeDao, mmsTbN, wheres, getEventLogMessage());
          // ログ出力カラム情報及び更新前データ情報取得
          boolean setResult = logCommon.setInfo();
          //DB更新ログ出力ロジック wp end

          // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
          LogEventUtils.setOperatorId(mstDeviceEdge,logService);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
          // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
          int ret = mstDeviceEdgeDao.update(mstDeviceEdge);

          //DB更新ログ出力ロジック wp start
          // 更新後データ取得、差分あれば、log出力
          if (setResult && ret > 0) {
            logCommon.updateLog();
          }
          //FNSI-修正 ログ対応 wp add end
        }

        // 削除処理
        List<String> deleteCdList = payload.get("deleteCdList");
        for (int i = 0; deleteCdList.size() > i; i++) {
          String serialNo = deleteCdList.get(i);
          //add by ShiHongda 2023-02-01 [Instead of Trigger: tg_sync_mst_device_edge] --start /
          MstDeviceEdge mstDeviceEdge = mstDeviceEdgeDao.selectBySerialNoSN(serialNo);
          // mod #デバイスエッジマスタで項目を削除した際に関連マスタで表示不正 zkm start
          // mstDeviceEdgeDao.deleteByCd(serialNo);
          mstDeviceEdgeDao.updateDelByCd(serialNo);
          // mod #デバイスエッジマスタで項目を削除した際に関連マスタで表示不正 zkm end
          // mod #8403 【デグレ】デバイスエッジマスタで新規レコードが保存できない dou start
          // mstDeviceEdgeDao.deleteMntDeviceEdgeStateByODE(mstDeviceEdge);
          //mod by shiyw 2023-03-09 [change to call MstDeviceEdgeTrigger] --end /
          //mntDeviceEdgeStateDao.deleteByFacilityDeviceEdge(mstDeviceEdge.getFacilityCd(), mstDeviceEdge.getDeviceEdgeNo());
          mstDeviceEdgeTrigger.triggerDelete(mstDeviceEdge);
          //mod by shiyw 2023-03-09 [change to call MstDeviceEdgeTrigger] --end /
          // mod #8403 【デグレ】デバイスエッジマスタで新規レコードが保存できない dou end
        }

        return;

      } catch (Exception e) {
        throw new Exception(e);
      }
    }

    /*
     * システム設定
     */
    @Autowired
    private SysSystemDefineDao sysSystemDefineDao;

    @Override
    public List<SysSystemDefine> findSysSystemDefineByCtlNo(Integer ctl_no) {
      return sysSystemDefineDao.selectByCtlNo(ctl_no);
    }

    /*
     * 機能一覧マスタ
     */
    @Autowired
    private SysFunctionDao sysFunctionDao;

    @Override
    public Page<SysFunction> findSysFunction(Pageable pageable, SysFunction param) {
      SelectOptions selectOptions = SelectOptions.get();
      List<SysFunction> sysFunctionList = sysFunctionDao.selectAll(selectOptions);
      return new PageImpl<>(sysFunctionList, pageable, selectOptions.getCount());
    }

    @Override
    public Page<SysFunction> findSysFunctionDispOnly(Pageable pageable, SysFunction param) {
      SelectOptions selectOptions = SelectOptions.get();
      List<SysFunction> sysFunctionList = sysFunctionDao.selectDispOnly(selectOptions);
      return new PageImpl<>(sysFunctionList, pageable, selectOptions.getCount());
    }

    @Override
    public List<SysFunction> findSysFunctionDispOnlyNoPaging() {
      return sysFunctionDao.selectDispOnly();
    }

    @Override
    public List<SysFunction> findSelectByDelAndDisp() {
      List<String> emptyList = new ArrayList<String>();
      return sysFunctionDao.selectByDelAndDisp(FlagType.FLAG_OFF, FlagType.FLAG_ON, emptyList, emptyList);
    }

    /*
     * 職種マスタ
     */
    @Autowired
    private MstJobDao mstJobDao;

    @Override
    public Page<MstJob> findMstJobByCd(Pageable pageable, MstJob params) {
      SelectOptions selectOptions = SelectOptions.get();

      // 指定したjobCdの職種情報を取得
      List<MstJob> mstJob = mstJobDao.selectByCd(params.getJobCd(), selectOptions);
      return new PageImpl<>(mstJob, pageable, selectOptions.getCount());
    }

    @Override
    public List<MstJob> findMstJobByFacilityCd(String facilityCd) {
      SelectOptions selectOptions = SelectOptions.get();

      // 指定したfacilityCdの職種情報を全件取得
      List<MstJob> mstJob = mstJobDao.selectByFacilityCd(facilityCd, selectOptions);

      // #10097 fix mst data sort. Add by Zhou.tao Start
      List<MstJob> sortedData;

      // mstSelectorから並び順を取得
      MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, "mst_job");
      if (!CollectionUtils.isEmpty(mstJob)
        && mstSelector != null && mstSelector.getOrderSettings() != null
        && mstSelector.getOrderSettings().getItems() != null) {

        // ソート用配列
        Map<Long, MstJob> sortedCode = new LinkedHashMap<>(mstSelector.getOrderSettings().getItems().size());
        mstSelector.getOrderSettings().getItems().forEach(
          item ->
            sortedCode.put(item.getCode()
              , mstJob.stream().filter(
                  job -> Objects.equals(item.getCode(), job.getJobCd())
                ).findFirst().orElse(null)
            )
        );
        sortedData = sortedCode.values().stream().filter(Objects::nonNull).toList();
      } else {
        sortedData = mstJob;
      }
      // #10097 fix mst data sort. Add by Zhou.tao End

      return sortedData;
    }

    @Override
    @Transactional
    public void saveMstJob(Map<String, List<String>> payload) throws Exception {
      try {
        ObjectMapper mapper = new ObjectMapper();
        // 登録処理
        for (int i = 0; payload.get("insertRecord").size() > i; i++) {
          MstJob mstJob = mapper.readValue(payload.get("insertRecord").get(i), MstJob.class);
          mstJobDao.insertMstJob(mstJob);
        }

        // 更新処理
        for (int i = 0; payload.get("updateRecord").size() > i; i++) {
          MstJob mstJob = mapper.readValue(payload.get("updateRecord").get(i), MstJob.class);

          // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
          LogEventUtils.setOperatorId(mstJob,logService);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
          // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
          int ret = mstJobDao.update(mstJob);
        }

        // 削除処理
        List<String> deleteCdList = payload.get("deleteCdList");

        for (int i = 0; deleteCdList.size() > i; i++) {
          String jobCd = deleteCdList.get(i);

          //FNSI-修正 ログ対応 wp add start

          String job = "mst_job";

          // SQL検索条件
          StringBuffer jobsb = new StringBuffer("");
          jobsb.append(" WHERE\n");
          jobsb.append(" job_cd = '" + jobCd + "'" + "\n");
          // logCommon設定
          // logCommon設定
          DataUpdateLogCommonNew logCommon = getLogCommon(mstJobDao, job, jobsb, getEventLogMessage());
          // ログ出力カラム情報及び更新前データ情報取得
          boolean setResult = logCommon.setInfo();
          //FNSI-修正 ログ対応 wp add end

          int ret = mstJobDao.deleteByCd(jobCd);

          //FNSI-修正 ログ対応 wp add start
          // 更新後データ取得、差分あれば、log出力
          if (setResult && ret > 0) {
            logCommon.updateLog();
          }
          //FNSI-修正 ログ対応 wp add end

        }

        return;

      } catch (Exception e) {
        throw new Exception(e);
      }
    }

    @Override
    @Transactional
    public void updMstJobAuthorities(List<MstJobRequest> payload,NtssUser ntssUser) throws Exception {
      try {
        // 更新処理のみ処理対象
        SelectOptions selectOptions = SelectOptions.get();

        for (int i = 0; payload.size() > i; i++) {

          List<MstJob> mstJobOld = mstJobDao.selectByCd(payload.get(i).getJobCd(), selectOptions);

          if (mstJobOld.size() > 0) {
            boolean isChgDefAth = false;
            if (StringUtils.isEmpty(payload.get(i).getDefaultAuthorizedAuthorities()) && StringUtils.isEmpty(mstJobOld.get(0).getDefaultAuthorizedAuthorities())) {
              // 権限設定なしのまま変更なし(NullPointerException対策)
              isChgDefAth = false;
            } else if ((!StringUtils.isEmpty(payload.get(i).getDefaultAuthorizedAuthorities())) && StringUtils.isEmpty(mstJobOld.get(0).getDefaultAuthorizedAuthorities())) {
              // 権限情報を新しく設定
              isChgDefAth = true;
            } else if (StringUtils.isEmpty(payload.get(i).getDefaultAuthorizedAuthorities()) && (!StringUtils.isEmpty(mstJobOld.get(0).getDefaultAuthorizedAuthorities()))) {
              // 権限情報を設定済み→権限設定なし
              isChgDefAth = true;
            } else if (!payload.get(i).getDefaultAuthorizedAuthorities().equals(mstJobOld.get(0).getDefaultAuthorizedAuthorities())) {
              // 権限情報を設定済み→変更
              isChgDefAth = true;
            }
            // デフォルトメニュー設定 追加 Du Start
            boolean isChgDefMenuSet = false;
            if (StringUtils.isEmpty(payload.get(i).getDefaultMenuSettings()) && StringUtils.isEmpty(mstJobOld.get(0).getDefaultMenuSettings()))
            {
              // 権限設定なしのまま変更なし(NullPointerException対策)
              isChgDefMenuSet = false;
            }
            else if ((! StringUtils.isEmpty(payload.get(i).getDefaultMenuSettings())) && StringUtils.isEmpty(mstJobOld.get(0).getDefaultMenuSettings()))
            {
              // 権限情報を新しく設定
              isChgDefMenuSet = true;
            } else if (StringUtils.isEmpty(payload.get(i).getDefaultMenuSettings()) && (!StringUtils.isEmpty(mstJobOld.get(0).getDefaultMenuSettings())))
            {
              // 権限情報を設定済み→権限設定なし
              isChgDefMenuSet = true;
              /* modify by dengjunyi [#9408] 権限情報変更の判定方法を修正 --start */
            }
            /* else if (! payload.get(i).getDefaultMenuSettings().equals(mstJobOld.get(0).getDefaultMenuSettings()))
            {
              // 権限情報を設定済み→変更
              isChgDefMenuSet = true;
            }*/
            if(!isChgDefMenuSet) {
              if (!new JSONObject(payload.get(i).getDefaultMenuSettings()).getString("initial_menu_function")
                .equals(mstJobOld.get(0).getDefaultMenuSettings().getInitialFunction())) {
                // 権限情報を設定済み→変更
                isChgDefMenuSet = true;
              } else {
                List<Object> defaultMenuFunctions = new JSONObject(payload.get(i).getDefaultMenuSettings()).getJSONArray("default_menu_functions").toList();
                List<String> useFunctions = mstJobOld.get(0).getDefaultMenuSettings().getUseFunctions();
                if (defaultMenuFunctions.size() == useFunctions.size()) {
                  for (int i1 = 0; i1 < defaultMenuFunctions.size(); i1++) {
                    if (!defaultMenuFunctions.get(i1).equals(useFunctions.get(i1))) {
                      // 権限情報を設定済み→変更
                      isChgDefMenuSet = true;
                      break;
                    }
                  }
                } else {
                  // 権限情報を設定済み→変更
                  isChgDefMenuSet = true;
                }
              }
            }
            /* modify by dengjunyi [#9408] 権限情報変更の判定方法を修正 --end */
            boolean isChgDefDispSet = false;
            if (StringUtils.isEmpty(payload.get(i).getDefaultDispSettings()) && StringUtils.isEmpty(mstJobOld.get(0).getDefaultDispSettings())) {
              // デフォルト表示設定なしのまま変更なし(NullPointerException対策)
              isChgDefDispSet = false;
            } else if ((!StringUtils.isEmpty(payload.get(i).getDefaultDispSettings())) && StringUtils.isEmpty(mstJobOld.get(0).getDefaultDispSettings())) {
              // デフォルト表示設定を新しく設定
              isChgDefDispSet = true;
            } else if (StringUtils.isEmpty(payload.get(i).getDefaultDispSettings()) && (!StringUtils.isEmpty(mstJobOld.get(0).getDefaultDispSettings()))) {
              // デフォルト表示設定を設定済み→デフォルト表示設定なし
              isChgDefDispSet = true;
            } else if (!payload.get(i).getDefaultDispSettings().equals(mstJobOld.get(0).getDefaultDispSettings())) {
              // デフォルト表示設定を設定済み→変更
              isChgDefDispSet = true;
            }
            boolean isChgDefNotifSet = false;
            if (StringUtils.isEmpty(payload.get(i).getDefaultNotificationSettings()) && StringUtils.isEmpty(mstJobOld.get(0).getDefaultNotificationSettings())) {
              // デフォルト表示設定なしのまま変更なし(NullPointerException対策)
              isChgDefNotifSet = false;
            } else if ((!StringUtils.isEmpty(payload.get(i).getDefaultNotificationSettings())) && StringUtils.isEmpty(mstJobOld.get(0).getDefaultNotificationSettings())) {
              // デフォルト表示設定を新しく設定
              isChgDefNotifSet = true;
            } else if (StringUtils.isEmpty(payload.get(i).getDefaultNotificationSettings()) && (!StringUtils.isEmpty(mstJobOld.get(0).getDefaultNotificationSettings()))) {
              // デフォルト表示設定を設定済み→デフォルト表示設定なし
              isChgDefNotifSet = true;
            } else {
              NotificationSettings newNotificationSettings = new NotificationSettings(payload.get(i).getDefaultNotificationSettings());
              isChgDefNotifSet = !newNotificationSettings.equals(mstJobOld.get(0).getDefaultNotificationSettings());
            }
            if (isChgDefAth || isChgDefMenuSet || isChgDefDispSet || isChgDefNotifSet)
            {
              // 権限を更新した場合
              // mod #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen start
              //　List<MstPersonalUser> lstUser = mstPersonalUserDao.selectByJobCd(payload.get(i).getJobCd().toString(),ntssUser.getFacilityCd());
              List<MstPersonalUser> lstUser = mstPersonalUserDao.selectByJobCd(payload.get(i).getJobCd().toString(), payload.get(i).getFacilityCd());
              // mod #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen end

              for (MstPersonalUser user : lstUser) {
                // 該当職種のユーザーの権限情報を更新
                MstUser mstUser = mstUserDao.selectById(user.getUserId());
                MstUser.UserSettings userSettings = mstUser.getUserSettings();
                if (userSettings != null) {
                  List<String> defaultAuthorizedAuthorities = new ArrayList<String>();
                  List<String> defaultAuthorizedFunctions = new ArrayList<String>();
                  if (isChgDefAth && payload.get(i).getDefaultAuthorizedAuthorities() != null && !payload.get(i).getDefaultAuthorizedAuthorities().isEmpty()) {
                    defaultAuthorizedAuthorities = Arrays.asList(payload.get(i).getDefaultAuthorizedAuthorities().split(","));
                  }
                  if (isChgDefMenuSet && payload.get(i).getDefaultMenuSettings() != null && !payload.get(i).getDefaultMenuSettings().isEmpty()) {
                    new JSONObject(payload.get(i).getDefaultMenuSettings()).getJSONArray("default_menu_functions").forEach(e -> {
                      defaultAuthorizedFunctions.add(e.toString());
                    });
                  }
                  // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou start
                  Boolean signoutFlg = false;
                  ForceSignOutReason signOutReason = ForceSignOutReason.USER_AUTHORITY_CHANGED;
                  if (!user.getUserId().equals(ntssUser.getUserId())) {
                    String value = facilitySettingService.getFacilitySettingValue(
                      // mod #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen start
                      // ntssUser.getFacilityCd(),
                      payload.get(i).getFacilityCd(),
                      // mod #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen end
                      CoreConstant.FacilitySettingNo.AUTHORITY_CHANGE_SIGN_OUT
                    );
                    if (VALID.equals(value)) {
                      if (isChgDefAth) {
                        List<String> authorizedAuthorities = userSettings.getAuthorizedAuthorities();
                        boolean isAdd = defaultAuthorizedAuthorities.containsAll(authorizedAuthorities);
                        // 許可機能・拡張機能が増えた場合はサインアウトさせない。
                        if (!isAdd) {
                          signoutFlg = true;
                          signOutReason = ForceSignOutReason.USER_AUTHORITY_CHANGED;
                        }
                      }
                      if (!signoutFlg && isChgDefMenuSet) {
                        List<String> authorizedFunctions = userSettings.getAuthorizedFunctions();
                        boolean isAdd = defaultAuthorizedFunctions.containsAll(authorizedFunctions);
                        // 許可機能・拡張機能が増えた場合はサインアウトさせない。
                        if (!isAdd) {
                          signoutFlg = true;
                          signOutReason = ForceSignOutReason.USE_AUTH_FUNCTION_CHANGED;
                        }
                      }
                    }
                  }
                  // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou end
                  if(isChgDefAth)
                    userSettings.setAuthorizedAuthorities(defaultAuthorizedAuthorities);
                  if(isChgDefMenuSet){
                    // mod #10136 サインイン時に初期表示機能が許可状態でない場合、許可範囲上のメニュー設定の表示順最上部の項目に遷移する dengshen start
                    // userSettings.setAuthorizedFunctions(defaultAuthorizedFunctions);
                    // userSettings.setInitialFunction(new JSONObject(payload.get(i).getDefaultMenuSettings()).getString("initial_menu_function"));
                    JSONObject defaultMenuSettings = new JSONObject(payload.get(i).getDefaultMenuSettings());
                    String initialMenuFunction = defaultMenuSettings.getString("initial_menu_function");
                    if (userSettings.getUseFunctions().contains(initialMenuFunction)) {
                      userSettings.setInitialFunction(initialMenuFunction);
                    } else {
                      boolean findInitialFunctionFlg = false;

                      // 変更後権限の初期化画面は新し追加権限の場合、ユーザ使用中権限の一番画面に初期化画面を設定する。
                      for (int item = 0; item < userSettings.getUseFunctions().size(); item++) {
                        if (defaultMenuSettings.getJSONArray("default_menu_functions").toList().contains(userSettings.getUseFunctions().get(item))) {
                          userSettings.setInitialFunction(userSettings.getUseFunctions().get(item));
                          findInitialFunctionFlg = true;
                          break;
                        }
                      }

                      // すべて権限は追加の場合、変更後一番権限を利用する。
                      if (!findInitialFunctionFlg) {
                        userSettings.setInitialFunction(initialMenuFunction);
                        userSettings.getUseFunctions().add(initialMenuFunction);
                      }
                    }
                    userSettings.setAuthorizedFunctions(defaultAuthorizedFunctions);
                    // mod #10136 サインイン時に初期表示機能が許可状態でない場合、許可範囲上のメニュー設定の表示順最上部の項目に遷移する dengshen end
                  }
                  if(isChgDefDispSet) {
                    ObjectMapper mapper = new ObjectMapper();
                    JsonNode defautSetting = mapper.readTree(payload.get(i).getDefaultDispSettings());
                    userSettings.setDefaultSetting(defautSetting);
                  }
                  if(isChgDefNotifSet) {
                    List<PersonalSetting> personalSettings = userSettings.getPersonalSettings() == null ? new ArrayList<>() : new ArrayList<>(userSettings.getPersonalSettings());
                    PersonalSetting notificationSetting = new PersonalSetting(payload.get(i).getDefaultNotificationSettings());
                    boolean isUpdate = false;
                    for(PersonalSetting personalSetting : personalSettings) {
                      // 通知設定登録済みの場合は更新
                      if(personalSetting.getTabDefineCd() == notificationSetting.getTabDefineCd()) {
                        isUpdate = true;
                        personalSetting.setValues(notificationSetting.getValues());
                        personalSetting.setSettingImportant(notificationSetting.getSettingImportant());
                      }
                    }
                    // 未登録の場合は追加
                    if(!isUpdate) {
                      personalSettings.add(notificationSetting);
                    }
                    userSettings.setPersonalSettings(personalSettings);
                  }
                  // デフォルトメニュー設定 追加 Du End
                  mstUser.setUserSettings(userSettings);
                  mstUserDao.updateUserSettings(mstUser);
                  // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou start
                  if (signoutFlg) {
                    // 権限を変更した利用者をサインアウトさせる
                    sysSigninManagerService.signOutUserForMultiServer(user.getFacilityCd(), user.getUserId(),
                      signOutReason);
                  }
                  // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou end
                }
              }
            }
          }
        }
        return;

      } catch (Exception e) {
        throw new Exception(e);
      }
    }

    /*
     * 選択肢マスタ
     */
    @Autowired
    private MstSelectorDao mstSelectorDao;

    @Override
    public MstSelector findMstSelectorByMstName(String facilityCd, String masterName) {
      // mstSelectorから並び順を取得
      return mstSelectorDao.selectByName(facilityCd, masterName);
    }

    @Override
    public List<MstSelector> findMstSelectListByMstName(String facilityCd, String masterName) {
      // mstSelectorから並び順を取得
      return mstSelectorDao.selectListByName(facilityCd, masterName);
    }

    /*
     * 掲示板種別マスタ
     */
    @Autowired
    private MstBbsKindDao mstBbsKindDao;

    @Override
    public Page<MstBbsKind> findMstBbsKindByFacilityCd(Pageable pageable, MstBbsKind params) {
      SelectOptions selectOptions = SelectOptions.get();

      List<MstBbsKind> mstBbsKindList = mstBbsKindDao.selectAll(selectOptions, params);
      return new PageImpl<>(mstBbsKindList, pageable, selectOptions.getCount());
    }

    // add マスタ削除 対応 chen start
    @Override
    public List<MstBbsKind> findMstBbsKindAll(MstBbsKind params) {
      List<MstBbsKind> bbsKindList = mstBbsKindDao.selectAllContainDel(params);
      return bbsKindList;
    }
// add マスタ削除 対応 chen end

    @Override
    public List<MstBbsKind> findMstBbsKindIncludeDeleted(MstBbsKind params) {
      List<MstBbsKind> bbsKindList = mstBbsKindDao.selectByFacilityCd(params.getFacilityCd(), null);
      return bbsKindList;
    }

    /*
     * 観察記録種別マスタ
     */
    @Autowired
    private MstObsKindDao mstObsKindDao;

    @Override
    public Page<MstObsKind> selectMstObsKindByFacilityCd(Pageable pageable, MstObsKind params) {
      SelectOptions selectOptions = SelectOptions.get();

      List<MstObsKind> mst = mstObsKindDao.selectAllOrderByMstSelector(selectOptions, params);
      return new PageImpl<>(mst, pageable, selectOptions.getCount());
    }

    /*
     * 調製薬剤マスタ
     */
    @Autowired
    private MstMedicineMixDao mstMedicineMixDao;

    @Override
    public Page<MstMedicineMix> findMstMedicineMixAll(Pageable pageable, MstMedicineMix params) {
      SelectOptions selectOptions = SelectOptions.get();

      List<MstMedicineMix> mstMedicineMixList = mstMedicineMixDao.selectAll(selectOptions, params);
      return new PageImpl<>(mstMedicineMixList, pageable, selectOptions.getCount());
    }

    // FNSI-修正 マスタ削除の対応 chen add start
    @Override
    public MstMedicineMix findMstMedicineMixByCdNoDel(MstMedicineMix params) {
      MstMedicineMix mstMedicineMix = mstMedicineMixDao.selectByCdNoDel(params.getFacilityCd(), params.getMedicineMixCd());
      return mstMedicineMix;
    }
// FNSI-修正 マスタ削除の対応 chen add end

    @Override
    public MstMedicineMix findMstMedicineMixByCd(String cd) {
      MstMedicineMix mstMedicineMix = null;
      if (StrUtils.isNumber(cd)) {
        int medicineMixCd = Integer.parseInt(cd);
        mstMedicineMix = mstMedicineMixDao.selectByMedicineMixCd(medicineMixCd);
      }
      return mstMedicineMix;
    }

    @Override
    public List<MstMedicineMixDto> findMstMedicineMixTabooAllergy(String facilityCd, Long patId, Integer selectMedicineCd, boolean... isDelFlg) {
      SelectOptions selectOptions = SelectOptions.get();
      // 調製薬剤リスト一覧を取得
      MstMedicineMix param = new MstMedicineMix() {
        {
          setFacilityCd(facilityCd);
        }
      };
      // mod FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 start
      // List<MstMedicineMix> lstMstMedicineMix = mstMedicineMixDao.selectAll(selectOptions, param);
      List<MstMedicineMix> lstMstMedicineMix = new ArrayList<>();
      List<MstMedicineMixDto> mstMedicineMixDtoList = new ArrayList<>();
      if (isDelFlg.length == 0) {
        /* modify by chamaojia 2024-02-28 [10196] Add processing based on "selectMedicaineCd" query --start */
        if (selectMedicineCd == null) {
          lstMstMedicineMix = mstMedicineMixDao.selectAll(selectOptions, param);
        } else {
          MstMedicineMix mstMedicineMix = mstMedicineMixDao.selectByMedicineMixIncludeDelByCd(selectMedicineCd);
          if (mstMedicineMix != null) {
            lstMstMedicineMix = new ArrayList<>();
            lstMstMedicineMix.add(mstMedicineMix);
          }
        }
        /* modify by chamaojia 2024-02-28 [10196] Add processing based on "selectMedicaineCd" query --end */
      } else {
        lstMstMedicineMix = mstMedicineMixDao.selectMstMedicineMixAllergyData(selectOptions, param);
      }
      // mod FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 end
      // 対象患者のアレルギー情報を取得
      PatMain patMain = patMainDao.selectById(patId);

      MstMedicineClass paramClass = new MstMedicineClass() {
        {
          setFacilityCd(facilityCd);
        }
      };
      List<MstMedicineClass> mstMedicineClassList = mstMedicineClassDao.selectAllIncludeDeleted(selectOptions, paramClass);

      MstTabooAllergy mstTabooAllergyParams = new MstTabooAllergy();
      mstTabooAllergyParams.setFacilityCd(facilityCd);
      // 禁忌・アレルギーマスタ情報を取得
      List<MstTabooAllergy> mstTabooAllergyList = mstTabooAllergyDao.selectAllIncludeDeleted(selectOptions, mstTabooAllergyParams);

      MasterCacheHandler masterCacheHandler = MasterCacheHandler.get();
      //add 9706 ljx start
      //???患者の場合、patIdが「-1」である、判断追加、後の処理を実行しない。
      if(-1 == patId){
        if (lstMstMedicineMix != null && !lstMstMedicineMix.isEmpty()) {
          for (MstMedicineMix element : lstMstMedicineMix) {
            MstMedicineMixDto newElement = new MstMedicineMixDto();
            BeanUtils.copyProperties(element, newElement);
            mstMedicineMixDtoList.add(newElement);
          }

          for (MstMedicineMixDto mstMedicineMixDto : mstMedicineMixDtoList) {
            mstMedicineMixDto.setIsIncludeDel(false);
            mstMedicineMixDto.setIsTaboo(false);
            mstMedicineMixDto.setIsAllergy(false);
            Integer classCd = mstMedicineMixDto.getClassCd();
            Optional<MstMedicineClass> found = mstMedicineClassList.stream().filter(data -> data.getClassCd().equals(classCd)).findFirst();
            if (found.isPresent()) {
              MstMedicineClass mstMedicineClass = found.get();
              String classType = "0";
              if (mstMedicineClass.getClassType() != null) {
                classType = String.valueOf((int)mstMedicineClass.getClassType().doubleValue());
              }
              mstMedicineMixDto.setClassType(classType);
            } else {
              mstMedicineMixDto.setClassType("0");
            }

            String mixInfo = mstMedicineMixDto.getMixInfo();
            if (mixInfo != null) {
              JSONArray mixInfoJsonArr = new JSONArray(mixInfo);
              for (int i = 0; i < mixInfoJsonArr.length(); i++) {
                JSONObject jObj = (JSONObject) mixInfoJsonArr.get(i);
                if (jObj.has("cd")) {
                  Integer cd = jObj.getInt("cd");
                  MstMedicine mstMedicine = masterCacheHandler.getMstMedicineByCd(cd);
                  if (mstMedicine != null) {
                    String isDisp = mstMedicine.getIsDisp();
                    String isDel = mstMedicine.getIsDel();
                    boolean isNot = "0".equals(isDisp) || "1".equals(isDel);
                    mstMedicineMixDto.setIsIncludeDel(isNot);
                    if(isNot){
                      break;
                    }
                  }
                }
              }
            }
          }
        }

        List<Object> objects = new ArrayList<>(mstMedicineMixDtoList.size());
        objects.addAll(mstMedicineMixDtoList);
        objects = sortData(objects, "mst_medicine_mix", facilityCd);
        List<MstMedicineMixDto> res = new ArrayList<>();
        for (Object obj : objects) {
          if (obj instanceof MstMedicineMixDto) {
            res.add((MstMedicineMixDto) obj);
          }
        }

        return res;
      }
      //add 9706 ljx end

      try {
        if (lstMstMedicineMix != null && !lstMstMedicineMix.isEmpty()) {
          for (MstMedicineMix element : lstMstMedicineMix) {
            MstMedicineMixDto newElement = new MstMedicineMixDto();
            BeanUtils.copyProperties(element, newElement);
            newElement.setIsIncludeDel(false);
            newElement.setIsAllergy(false);
            newElement.setIsTaboo(false);
            Integer classCd = element.getClassCd();
            Optional<MstMedicineClass> found = mstMedicineClassList.stream().filter(data -> data.getClassCd().equals(classCd)).findFirst();
            if (found.isPresent()) {
              MstMedicineClass mstMedicineClass = found.get();
              String classType = "0";
              if (mstMedicineClass.getClassType() != null) {
                classType = String.valueOf((int) mstMedicineClass.getClassType().doubleValue());
              }
              newElement.setClassType(classType);
            } else {
              newElement.setClassType("0");
            }

            String mixInfo = element.getMixInfo();
            if (mixInfo != null) {
              JSONArray mixInfoJsonArr = new JSONArray(mixInfo);
              for (int i = 0; i < mixInfoJsonArr.length(); i++) {
                JSONObject jObj = (JSONObject) mixInfoJsonArr.get(i);
                if (jObj.has("cd")) {
                  Integer cd = jObj.getInt("cd");
                  MstMedicine mstMedicine = masterCacheHandler.getMstMedicineByCd(cd);
                  if (mstMedicine != null) {
                    String isDisp = mstMedicine.getIsDisp();
                    String isDel = mstMedicine.getIsDel();
                    boolean isNot = "0".equals(isDisp) || "1".equals(isDel);
                    newElement.setIsIncludeDel(isNot);
                    if(isNot){
                      break;
                    }
                  }
                }
              }
            }

            mstMedicineMixDtoList.add(newElement);
          }
        }

        // 患者の禁忌・アレルギー情報
        ArrayList<PatInfoTabooAllergy> patInfoTabooAllergyList = new ObjectMapper().readValue(patMain.getTaboo_allergy_info(), new TypeReference<ArrayList<PatInfoTabooAllergy>>() {});

        // 禁忌調製薬剤リスト
        ArrayList<String> tabooMedicineMixList = new ArrayList<String>();
        // 禁忌薬剤リスト
        ArrayList<String> tabooMedicineList = new ArrayList<String>();
        // アレルギー調製薬剤リスト
        ArrayList<String> allergyMedicineMixList = new ArrayList<String>();
        // アレルギー薬剤リスト
        ArrayList<String> allergyMedicineList = new ArrayList<String>();

        // 患者の禁忌・アレルギー情報毎にチェックを行い、禁忌調整薬剤/禁忌薬剤リスト・アレルギー調整薬剤/アレルギー薬剤リストを作成する
        for (PatInfoTabooAllergy patInfoTabooAllergy : patInfoTabooAllergyList) {

          if (patInfoTabooAllergy.getCategory_class().equals("0")) {
            // 対象区分が0:"禁忌・アレルギー" → taboo_allergy_cdの値から禁忌・アレルギーマスタを検索後、薬剤コード・調整薬剤コードを取得
            String cd = patInfoTabooAllergy.getTaboo_allergy_cd();
            Optional<MstTabooAllergy> mstTabooAllergy = mstTabooAllergyList.stream().filter(a -> a.getTabooAllergyCd().equals(cd)).findFirst();
            if (mstTabooAllergy.isPresent()) {
              ArrayList<MstTabooAllergyDetailInfo> tabooAllergyDetailInfoList = new ObjectMapper().readValue(mstTabooAllergy.get().getDetailInfo(), new TypeReference<ArrayList<MstTabooAllergyDetailInfo>>() {});

              // 禁忌・アレルギーマスタの詳細項目でclassCd(禁忌対象区分)が"1"(薬剤)のcd(禁忌対象コード)を取得し、薬剤コードリストを作成する
              List<String> medicineCdList = tabooAllergyDetailInfoList.stream().filter(a -> a.getClassCd().equals("1")).map(a -> a.getCd()).collect(Collectors.toList());
              // 禁忌・アレルギーマスタの詳細項目でclassCd(禁忌対象区分)が"2"(調整薬剤)のcd(禁忌対象コード)を取得し、調整薬剤コードリストを作成する
              List<String> medicineMixCdList = tabooAllergyDetailInfoList.stream().filter(a -> a.getClassCd().equals("2")).map(a -> a.getCd()).collect(Collectors.toList());

              if (patInfoTabooAllergy.getTaboo_allergy_class().equals("1")) {
                // 禁忌薬剤リストに追加
                tabooMedicineList.addAll(medicineCdList);
                // 禁忌調製薬剤リストに追加
                tabooMedicineMixList.addAll(medicineMixCdList);
              } else if (patInfoTabooAllergy.getTaboo_allergy_class().equals("2")) {
                // アレルギー薬剤リストに追加
                allergyMedicineList.addAll(medicineCdList);
                // アレルギー調整薬剤リストに追加
                allergyMedicineMixList.addAll(medicineMixCdList);
              }
            }

          } else if (patInfoTabooAllergy.getCategory_class().equals("1")) {
            // 対象区分が1:薬剤 → taboo_allergy_cdの値がそのまま薬剤コード
            if (patInfoTabooAllergy.getTaboo_allergy_class().equals("1")) {
              // 禁忌薬剤リストに追加
              tabooMedicineList.add(patInfoTabooAllergy.getTaboo_allergy_cd());
            } else if (patInfoTabooAllergy.getTaboo_allergy_class().equals("2")) {
              // アレルギー薬剤リストに追加
              allergyMedicineList.add(patInfoTabooAllergy.getTaboo_allergy_cd());
            }

          } else if (patInfoTabooAllergy.getCategory_class().equals("2")) {
            // 対象区分が2:調整薬剤 → taboo_allergy_cdの値がそのまま調整薬剤コード
            if (patInfoTabooAllergy.getTaboo_allergy_class().equals("1")) {
              // 禁忌調製薬剤リストに追加
              tabooMedicineMixList.add(patInfoTabooAllergy.getTaboo_allergy_cd());
            } else if (patInfoTabooAllergy.getTaboo_allergy_class().equals("2")) {
              // アレルギー調製薬剤リストに追加
              allergyMedicineMixList.add(patInfoTabooAllergy.getTaboo_allergy_cd());
            }
          }
        }

        if (tabooMedicineList.size() > 0) {
          // 禁忌薬剤が含まれる調製薬剤を取得し、禁忌調製薬剤リストに追加
          mstMedicineMixDao.selectByMedicineCdList(facilityCd, tabooMedicineList).stream().forEach(a -> tabooMedicineMixList.add(a.getMedicineMixCd().toString()));
        }

        if (allergyMedicineList.size() > 0) {
          // アレルギー薬剤が含まれる調製薬剤を取得し、アレルギー調製薬剤リストに追加
          mstMedicineMixDao.selectByMedicineCdList(facilityCd, allergyMedicineList).stream().forEach(a -> allergyMedicineMixList.add(a.getMedicineMixCd().toString()));
        }

        if (tabooMedicineMixList.size() > 0 || allergyMedicineMixList.size() > 0) {
          // 禁忌・アレルギー調製薬剤リスト
          ArrayList<String> tabooAllergyMedicineMixList = new ArrayList<String>();

          // 禁忌・アレルギー両方に登録がある調整薬剤コードのリストを作成
          ListUtils.intersection(tabooMedicineMixList, allergyMedicineMixList).stream().forEach(a -> tabooAllergyMedicineMixList.add(a));
          // 禁忌のみ登録がある調整調整コードのリスト(重複無し)を作成
          Set<String> tabooMedicineMixSet = new HashSet<String>(tabooMedicineMixList.stream().filter(a -> !tabooAllergyMedicineMixList.contains(a)).collect(Collectors.toList()));
          // アレルギーのみ登録がある調整調整コードのリスト(重複無し)を作成
          Set<String> allergyMedicineMixSet = new HashSet<String>(allergyMedicineMixList.stream().filter(a -> !tabooAllergyMedicineMixList.contains(a)).collect(Collectors.toList()));

          // 調製薬剤リストを1件ずつ確認して禁忌・アレルギー情報に一致する場合は名称の前に定冠詞をつける
          for (int idx = 0; idx < mstMedicineMixDtoList.size(); idx++) {
            MstMedicineMixDto mstMedicineMix = mstMedicineMixDtoList.get(idx);
            if (tabooAllergyMedicineMixList.contains(mstMedicineMix.getMedicineMixCd().toString())) {
              // 禁忌・アレルギー
              mstMedicineMixDtoList.get(idx).setIsTaboo(true);
              mstMedicineMixDtoList.get(idx).setIsAllergy(true);
            } else if (tabooMedicineMixSet.contains(mstMedicineMix.getMedicineMixCd().toString())) {
              // 禁忌
              mstMedicineMixDtoList.get(idx).setIsTaboo(true);
              mstMedicineMixDtoList.get(idx).setIsAllergy(false);
            } else if (allergyMedicineMixSet.contains(mstMedicineMix.getMedicineMixCd().toString())) {
              // アレルギー
              mstMedicineMixDtoList.get(idx).setIsTaboo(false);
              mstMedicineMixDtoList.get(idx).setIsAllergy(true);
            }
          }
        }

        List<Object> objects = new ArrayList<>(mstMedicineMixDtoList.size());
        objects.addAll(mstMedicineMixDtoList);
        objects = sortData(objects, "mst_medicine_mix", facilityCd);
        List<MstMedicineMixDto> res = new ArrayList<>();
        for (Object obj : objects) {
          if (obj instanceof MstMedicineMixDto) {
            res.add((MstMedicineMixDto) obj);
          }
        }

        return res;
      } catch (Exception e) {
        // 禁忌・アレルギー情報取得失敗時は調製薬剤マスタをそのまま返却
        return mstMedicineMixDtoList;
      }
    }

  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 start
    /**
     * {@inheritDoc}
     */
    @Override
    public List<MstMedicineMixDto> mstMedicineMixAddTerm(List<MstMedicineMixDto> mstMedicineMixDtoList, String facilityCd, Long PatId) {
      // 戻りデータ
      List<MstMedicineMixDto> rtn = new ArrayList<>();

      // 薬剤マスタを取得
      MstMedicine mstMedicine = new MstMedicine();
      mstMedicine.setFacilityCd(facilityCd);
      SelectOptions selectOptions = SelectOptions.get();
      List<MstMedicine> mstMedicineList = mstMedicineDao.selectAllDel(selectOptions, mstMedicine);

      for (MstMedicineMixDto mediMix : mstMedicineMixDtoList) {
        // 調製薬剤に設定されている薬剤
        // mod FNSI- NullPointerException 対応 韓 start
        // JSONArray mixInfo = new JSONArray(mediMix.getMixInfo().toString());
        JSONArray mixInfo = (mediMix.getMixInfo() == null) ? new JSONArray() : new JSONArray(mediMix.getMixInfo().toString());
        // mod FNSI- NullPointerException 対応 韓 end
        // 調製薬剤に設定されている薬剤の使用開始日、使用終了日を格納
        List<String> startDateList = new ArrayList<String>();
        List<String> endDateList = new ArrayList<String>();
        for (int idx = 0; idx < mixInfo.length(); idx++) {
          JSONObject mediObj = mixInfo.getJSONObject(idx);
          // mod FNSI-400Exception 対応 李 start
          if (!"null".equals(mediObj.get("cd").toString())) {
            // 薬剤マスタから、データを探す
            MstMedicine target = mstMedicineList.stream().filter(obj -> obj.getMedicineCd().equals(mediObj.getInt("cd"))).findFirst().orElse(null);
            // 薬剤の使用期限を格納
            if (target != null) {
              if (!StringUtils.isEmpty(target.getUseStartDate())) {
                startDateList.add(target.getUseStartDate());
              }
              if (!StringUtils.isEmpty(target.getUseEndDate())) {
                endDateList.add(target.getUseEndDate());
              }
            }
          }
          // mod FNSI-400Exception 対応 李 end
        }
        // 「大きい」順(逆順)にソートし、開始日の中で一番未来の日付を取得
        Collections.sort(startDateList, Comparator.reverseOrder());
        // 「小さい」順(正順)にソートし、終了日の中で一番過去の日付を取得
        Collections.sort(endDateList);
        MstMedicineMixDto resObj = new MstMedicineMixDto();
        // MstMedicineMix + 集計した開始日、終了日を戻したい為、MstMedicineMixのデータを全て含める
        BeanUtils.copyProperties(mediMix, resObj);
        // 集計した開始日、終了日
        resObj.setMaxUseStartDate(startDateList.size() > 0 ? startDateList.get(0) : "");
        resObj.setMinUseEndDate(endDateList.size() > 0 ? endDateList.get(0) : "");
        rtn.add(resObj);
      }
      return rtn;
    }
	//mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 end

  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 start
  @Override
  public Page<MstMedicineMixExtendsDto> findMstMedicineMixAllIncludeDeleted(Pageable pageable, MstMedicineMix params) {
    List<MstMedicineMixExtendsDto> res = new ArrayList<>();
    SelectOptions selectOptions = SelectOptions.get();
    List<MstMedicineMix> mstMedicineMixList = mstMedicineMixDao.selectAllIncludeDeleted(selectOptions, params);
    if (mstMedicineMixList != null && !mstMedicineMixList.isEmpty()) {
      MasterCacheHandler masterCacheHandler = MasterCacheHandler.get();
      for (MstMedicineMix mstMedicineMix : mstMedicineMixList) {
        MstMedicineMixExtendsDto mstMedicineMixExtendsDto = new MstMedicineMixExtendsDto();
        BeanUtils.copyProperties(mstMedicineMix, mstMedicineMixExtendsDto);
        mstMedicineMixExtendsDto.setIsIncludeDel(false);
        String mixInfo = mstMedicineMix.getMixInfo();
        if (mixInfo != null) {
          JSONArray mixInfoJsonArr = new JSONArray(mixInfo);
          for (int i = 0; i < mixInfoJsonArr.length(); i++) {
            JSONObject jObj = (JSONObject) mixInfoJsonArr.get(i);
            if (jObj.has("cd")) {
              Integer cd = jObj.getInt("cd");
              MstMedicine mstMedicine = masterCacheHandler.getMstMedicineByCd(cd);
              if (mstMedicine != null) {
                String isDisp = mstMedicine.getIsDisp();
                String isDel = mstMedicine.getIsDel();
                boolean isNot = "0".equals(isDisp) || "1".equals(isDel);
                mstMedicineMixExtendsDto.setIsIncludeDel(isNot);
                if(isNot){
                  break;
                }
              }
            }
          }
        }
        res.add(mstMedicineMixExtendsDto);
      }
    }

    return new PageImpl<>(res, pageable, selectOptions.getCount());
  }
  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 end

    /*
     * 検査項目マスタ
     */
    @Autowired
    private MstExamItemDao mstExamItemDao;

    @Override
    public Page<MstExamItem> selectMstExamItemByFacilityCd(Pageable pageable, MstExamItem params) {
      SelectOptions selectOptions = SelectOptions.get();

      List<MstExamItem> mst = mstExamItemDao.selectByFacilityCd(params.getFacilityCd());
      return new PageImpl<>(mst, pageable, selectOptions.getCount());
    }

    @Override
    public List<MstExamItem> findExamItemListForExamCalc(String facilityCd) {
      // 指定したfacilityCdの検査項目情報を全件取得
      List<MstExamItem> mstExamItem = mstExamItemDao.selectExamItemListForExamCalc(facilityCd);
      return mstExamItem;
    }

    // #9477 2023.11.21 add 検査項目マスタで「仮想端末表示がONのもの」を100件まで取得 TDC山崎 start
    @Override
    public List<MstSelector> findMstExamItemForComsvByFacilityCd(String facilityCd) {
      // 検査項目マスタで「仮想端末表示がONのもの」を100件取得する
      List<ComsvMstExamItem> comsvMstExamItem = mstExamItemDao.selectByFacilityCdComSv(facilityCd);

      // 検査項目マスタ を マスタセレクタ として準備
      var comsvMstExamItemsAsMstSelector = new MstSelector();
      comsvMstExamItemsAsMstSelector.setFacilityCd(facilityCd);
      comsvMstExamItemsAsMstSelector.setMasterPhysicalName("mst_exam_item");

      MstSelector.OrderSettings orderSettings = new MstSelector.OrderSettings();
      List<MstSelector.Item> listMsItems = new ArrayList<>();
      for (ComsvMstExamItem oneMei : comsvMstExamItem) {
        MstSelector.Item oneMsItem = new MstSelector.Item();
        oneMsItem.setCode(oneMei.getExamItemCd());
        oneMsItem.setName(oneMei.getExamItemName());

        listMsItems.add(oneMsItem);
      }
      orderSettings.setItems(listMsItems);
      comsvMstExamItemsAsMstSelector.setOrderSettings(orderSettings);

      return List.of(comsvMstExamItemsAsMstSelector);
    }
    // #9477 2023.11.21 add 検査項目マスタで「仮想端末表示がONのもの」を100件まで取得 TDC山崎 end

    /*
     * 採血管マスタ
     */
    @Autowired
    private MstSpitzDao mstSpitzDao;

    @Override
    public Page<MstSpitz> selectMstSpitzByFacilityCd(Pageable pageable, MstSpitz params) {
      SelectOptions selectOptions = SelectOptions.get();

      List<MstSpitz> mst = mstSpitzDao.selectByFacilityCd(params.getFacilityCd());
      return new PageImpl<>(mst, pageable, selectOptions.getCount());
    }

    /*
     * 放射線検査セットマスタ
     * マスタメンテナンスでの並び順で並び替え
     */
    @Autowired
    private MstRadSetDao mstRadSetDao;

    @Override
    public Page<MstRadSet> selectMstRadSetByFacilityCd(Pageable pageable, MstRadSet params) {
      SelectOptions selectOptions = SelectOptions.get();

      // データを取得
      List<MstRadSet> mst = mstRadSetDao.selectRadSetList(params.getFacilityCd());

      // マスタメンテナンス画面で指定した並び順への並び替え処理
      List<MstRadSet> sortedMst = new ArrayList<MstRadSet>();

      // mstSelectorから並び順を取得
      MstSelector mstSelector = findMstSelectorByMstName(params.getFacilityCd(), "mst_rad_set");
      if (mstSelector != null) {
        for (MstSelector.Item item : mstSelector.getOrderSettings().getItems()) {
          // 検査セットIDをキーにして検索
          MstRadSet mstRadSet = mst.stream().filter(m -> m.getRadSetCd().equals(item.getCode())).findFirst().orElse(null);
          if (mstRadSet != null) {
            sortedMst.add(mstRadSet);
          }
        }

        // 選択肢マスタに記載がないデータは全件並び順の後ろにつける
        for (MstRadSet mstRadSet : mst) {
          if (!sortedMst.stream().anyMatch(m -> m.getRadSetCd().equals(mstRadSet.getRadSetCd()))) {
            sortedMst.add(mstRadSet);
          }
        }

      } else {
        // 選択肢マスタにデータがない場合はDBから取得した結果をそのまま返す
        sortedMst = mst;
      }

      return new PageImpl<>(sortedMst, pageable, selectOptions.getCount());
    }

    /*
     * よく使う施設マスタ
     */
    @Autowired
    private MstFavoriteFacilityDao mstFavoriteFacilityDao;

    @Override
    public Page<MstFavoriteFacility> selectMstFavoriteFacilityByFacilityCd(Pageable pageable, String facilityCd) {
      SelectOptions selectOptions = SelectOptions.get();

      List<MstFavoriteFacility> mst = mstFavoriteFacilityDao.selectAll(selectOptions, facilityCd);
      return new PageImpl<>(mst, pageable, selectOptions.getCount());
    }

    /*
     * 全施設マスタ
     */
    @Autowired
    private SysFacilityDao sysFacilityDao;

    @Override
    @Transactional(TransactionManagerName.ALL)
    public void saveSysFacility(Map<String, List<String>> payload) throws Exception {
      try {
        ObjectMapper mapper = new ObjectMapper();

        // 登録処理
        for (int i = 0; payload.get("insertRecord").size() > i; i++) {
          SysFacility sysFacility = mapper.readValue(payload.get("insertRecord").get(i), SysFacility.class);
          sysFacilityDao.insert(sysFacility);
        }

        // 更新処理
        for (int i = 0; payload.get("updateRecord").size() > i; i++) {
          SysFacility sysFacility = mapper.readValue(payload.get("updateRecord").get(i), SysFacility.class);
          // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
          LogEventUtils.setOperatorId(sysFacility,logService);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
          // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
          sysFacilityDao.update(sysFacility);
        }

        // 削除処理
        List<String> deleteCdList = payload.get("deleteCdList");
        for (int i = 0; deleteCdList.size() > i; i++) {
          String medicalInstitutionCd = deleteCdList.get(i);
          sysFacilityDao.deleteByCd(medicalInstitutionCd);
        }
        // modify #6217 全施設マスタ画面が遅い guanhao start
//        // add redmine 4490 全施設マスタの並び順が変更 鞠 start
//        if ("sys_facility".equals(payload.get("getFacility").get(1))) {
//          List<Map<String, Object>> updateData = new ArrayList<>();
//          Map<String, Object> map = null;
//          for (int i = 0; payload.get("getMasterRecordList").size() > i; i++) {
//            SysFacility sysFacility = mapper.readValue(payload.get("getMasterRecordList").get(i), SysFacility.class);
//            Field[] declaredFields = sysFacility.getClass().getDeclaredFields();
//            map = new HashMap<String, Object>();
//            for (Field field : declaredFields) {
//              field.setAccessible(true);
//              map.put(field.getName(), field.get(sysFacility));
//            }
//            updateData.add(map);
//          }
//
//          String facilityCd = payload.get("getFacility").get(0);
//          String masterPhysicalName = payload.get("getFacility").get(1);
//
//          masterEditService.createMstSelector(facilityCd, masterPhysicalName, updateData);
//        }
//        // add redmine 4490 全施設マスタの並び順が変更 鞠 end
        // modify #6217 全施設マスタ画面が遅い guanhao end


        return;

      } catch (Exception e) {
        throw e;
      }
    }

    /*
     * 施設マスタのパラメータ指定による検索
     */
    @Override
    public List<SysFacility> findBySearchConditions(String prefecturesCd, String keyword, Integer limit, Integer page) {
      return sysFacilityDao.selectBySearchConditions(prefecturesCd, keyword, limit, page);
    }

    /**
     * {@link MstAddMonitorDao}のインスタンス
     */
    @Autowired
    private MstAddMonitorDao mstAddMonitorDao;

    /**
     * {@inheritDoc}
     */
    @Override
    public List<MstAddMonitor> selectMstAddMonitorByVitalMonitorClass(String facilityCd, String vitalMonitorClass) {
      MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, "mst_add_monitor");
      if(mstSelector == null){
        List<MstAddMonitor> newList = new ArrayList<>();
        return newList;
      }
      MstSelector.OrderSettings orderSettings = mstSelector.getOrderSettings();

      List<MstAddMonitor> mstAddMonitors =
        mstAddMonitorDao.selectByVitalMonitorClass(facilityCd, vitalMonitorClass);

      Map<Long, Integer> orderMap = new HashMap<>();

      if (orderSettings != null && orderSettings.getItems() != null) {
        List<Item> items = orderSettings.getItems();

        for (int i = 0; i < items.size(); i++) {
          orderMap.put(items.get(i).getCode(), i);
        }
      }

      mstAddMonitors.sort(Comparator.comparingInt(m ->
        orderMap.getOrDefault(m.getVitalMonitorItemCd(), Integer.MAX_VALUE)
      ));

      return mstAddMonitors;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public List<MstAddMonitor> selectMstAddMonitorByFacilityCd(String facilityCd) {

      MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, "mst_add_monitor");
      if(mstSelector == null){
        List<MstAddMonitor> newList = new ArrayList<>();
        return newList;
      }
      MstSelector.OrderSettings orderSettings = mstSelector.getOrderSettings();

      List<MstAddMonitor> mstAddMonitors =mstAddMonitorDao.selectAllByFacilityCd(facilityCd);

      Map<Long, Integer> orderMap = new HashMap<>();

      if (orderSettings != null && orderSettings.getItems() != null) {
        List<Item> items = orderSettings.getItems();

        for (int i = 0; i < items.size(); i++) {
          orderMap.put(items.get(i).getCode(), i);
        }
      }

      mstAddMonitors.sort(Comparator.comparingInt(m ->
        orderMap.getOrDefault(m.getVitalMonitorItemCd(), Integer.MAX_VALUE)
      ));

      return mstAddMonitors;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public MstAddMonitor selectMstAddMonitorByCd(Long vitalMonitorItemCd) {
      return mstAddMonitorDao.selectByCd(vitalMonitorItemCd);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public List<MedicineResponse> selectMedicineAllWithMix(Pageable pageable, String facilityCd) {
      List<MedicineResponse> result = new ArrayList<MedicineResponse>();
      // 通常薬剤を取得.
      MstMedicine mstMedicine = new MstMedicine();
      mstMedicine.setFacilityCd(facilityCd);
      Page<MstMedicine> mstMedicineList = findMstMedicineAll(pageable, mstMedicine);
      mstMedicineList.forEach(item -> {
        result.add(new MedicineResponse(
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
          //"1", item.getMedicineCd(), item.getMedicineName(), item.getUnit(), item.getUnitSecond(),
          1, item.getMedicineCd(), item.getMedicineName(), item.getUnit(), item.getUnitSecond(),
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
          item.getIsDisp(), item.getClassCd(), item.getUnitDecimalPoint(), item.getUnitDecimalPointSecond()
        ));
      });
      // 調製薬剤
      MstMedicineMix mstMedicineMix = new MstMedicineMix();
      mstMedicineMix.setFacilityCd(facilityCd);
      Page<MstMedicineMix> mstMedicineMixList = findMstMedicineMixAll(pageable, mstMedicineMix);
      mstMedicineMixList.forEach(item -> {
        result.add(new MedicineResponse(
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
          //"2", item.getMedicineMixCd(), item.getMedicineMixName(), item.getUnit(), null,
          2, item.getMedicineMixCd(), item.getMedicineMixName(), item.getUnit(), null,
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
          item.getIsDisp(), item.getClassCd(), item.getUnitDecimalPoint(), null
        ));
      });
      return result;
    }

    //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 start
    /**
     * {@inheritDoc}
     */
    @Override
    public List<MedicineResponseExtends> selectMedicineAllTabooAllergyWithMix(Pageable pageable, String facilityCd, Long patId, Integer classType) {
      List<MedicineResponseExtends> result = new ArrayList<MedicineResponseExtends>();
      //mod #12462 患者情報共有 zrx start
      List<PatNameIdentification> srcPatIds = new ArrayList<>();
      if (classType.compareTo(-1) == 0) {
        srcPatIds = materialsSharingPatientInfomationService.getListPatIdSrcFromPatTo(patId);
      }
      result = this.buildMedicineResponse(facilityCd, patId);
      for (PatNameIdentification patIdsrc : srcPatIds) {
        List<MedicineResponseExtends> patIdsrcResult = this.buildMedicineResponse(patIdsrc.getFacilityCdSrc(), patIdsrc.getPatIdSrc());
        if(patIdsrcResult != null && !patIdsrcResult.isEmpty()) {
          result.addAll(patIdsrcResult);
        }
      }
//      //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 start
//      List<MstMedicineDto> lstMedicine = findMstMedicineTabooAllergy(facilityCd, patId, null);
//      List<MstMedicineMixDto> lstMedicineMix = findMstMedicineMixTabooAllergy(facilityCd, patId, null);
//      //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 end
//      lstMedicine.forEach(item -> {
//        result.add(new MedicineResponseExtends(
//          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
//          //"1", item.getMedicineCd(), item.getMedicineName(), item.getUnit(), item.getUnitSecond(),
//          1, item.getMedicineCd(), item.getMedicineName(), item.getUnit(), item.getUnitSecond(),
//          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
//          item.getIsDisp(), item.getClassCd(), item.getUnitDecimalPoint(), item.getUnitDecimalPointSecond(), item.getIsTaboo(), item.getIsAllergy()
//        ));
//      });
//      lstMedicineMix.forEach(item -> {
//        result.add(new MedicineResponseExtends(
//          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
//          //"2", item.getMedicineMixCd(), item.getMedicineMixName(), item.getUnit(), null,
//          2, item.getMedicineMixCd(), item.getMedicineMixName(), item.getUnit(), null,
//          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
//          item.getIsDisp(), item.getClassCd(), item.getUnitDecimalPoint(), null, item.getIsTaboo(), item.getIsAllergy()
//        ));
//      });
      //mod #12462 患者情報共有 zrx end

      // classTypeが-1以外のとき、薬剤分類マスタの分類区分でフィルタ
      if (classType.compareTo(-1) != 0) {
        // 該当する分類区分の薬剤分類マスタコードリスト取得
        List<Integer> lstClassCd = new ArrayList<Integer>();
        List<MstMedicineClass> lstMedicineClass = mstMedicineClassDao.selectByClassType(classType, facilityCd);
        lstMedicineClass.forEach(item -> {
          lstClassCd.add(item.getClassCd());
        });
        // フィルタリング
        List<MedicineResponseExtends> filteredResult;
        filteredResult = result.stream()
          .filter(item -> lstClassCd.contains(item.getClassCd()))
          .collect(Collectors.toList());
        return filteredResult;

      }

      return result;
    }
    //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 end

    //add #12462 患者情報共有 zrx start
    private List<MedicineResponseExtends> buildMedicineResponse(String facilityCd, Long patId) {

      List<MedicineResponseExtends> result = new ArrayList<>();

      List<MstMedicineDto> lstMedicine = findMstMedicineTabooAllergy(facilityCd, patId, null);
      List<MstMedicineMixDto> lstMedicineMix = findMstMedicineMixTabooAllergy(facilityCd, patId, null);

      lstMedicine.forEach(item -> {
        result.add(new MedicineResponseExtends(
          1,
          item.getMedicineCd(),
          item.getMedicineName(),
          item.getUnit(),
          item.getUnitSecond(),
          item.getIsDisp(),
          item.getClassCd(),
          item.getUnitDecimalPoint(),
          item.getUnitDecimalPointSecond(),
          item.getIsTaboo(),
          item.getIsAllergy()
        ));
      });

      lstMedicineMix.forEach(item -> {
        result.add(new MedicineResponseExtends(
          2,
          item.getMedicineMixCd(),
          item.getMedicineMixName(),
          item.getUnit(),
          null,
          item.getIsDisp(),
          item.getClassCd(),
          item.getUnitDecimalPoint(),
          null,
          item.getIsTaboo(),
          item.getIsAllergy()
        ));
      });

      return result;
    }
    //add #12462 患者情報共有 zrx end

    /**
     * 患者カレンダーレイアウトマスタ
     */
    @Autowired
    private MstFacilityCalendarLayoutDao mstFacilityCalendarLayoutDao;

    @Override
    public Page<MstFacilityCalendarLayout> findMstFacilityCalendarLayoutAll(Pageable pageable, String facilityCd) {
      SelectOptions selectOptions = SelectOptions.get();

      List<MstFacilityCalendarLayout> mstFacilityCalendarLayoutList = mstFacilityCalendarLayoutDao.selectAll(selectOptions, facilityCd);
      return new PageImpl<>(mstFacilityCalendarLayoutList, pageable, selectOptions.getCount());
    }

    @Override
    public List<MstDialyzer> findMstDialyzerAllByFacillityCd(String facilityCd) {
      return mstDialyzerDao.selectByFacillityCd(facilityCd);
    }

    @Autowired
    private MstWaterSurveyPointDao mstWaterSurveyPointDao;

    @Override
    public List<WaterSurveyPoint> selectALLWaterSurveyPoint(Pageable pageable, String facilityCd) {
      SelectOptions selectOptions = SelectOptions.get();

      List<WaterSurveyPoint> listSurveyPoint = mstWaterSurveyPointDao.getAll(selectOptions, facilityCd);
      return listSurveyPoint;
    }

    @Override
    public WaterSurveyPoint selectWaterSurveyPointByCd(Long surveyPointCd) {
      return mstWaterSurveyPointDao.selectByCd(surveyPointCd);
    }

    @Autowired
    private MstWaterSurveyTypeDao mstWaterSurveyTypeDao;

    @Override
    public List<MstWaterSurveyType> selectALLWaterSurveyType(Pageable pageable, String facilityCd) {
      SelectOptions selectOptions = SelectOptions.get();

      List<MstWaterSurveyType> listSurveyPoint = mstWaterSurveyTypeDao.getAll(selectOptions, facilityCd);
      return listSurveyPoint;
    }

    @Override
    public MstWaterSurveyType selectWaterSurveyTypeByCd(Long surveyTypeCd) {
      return mstWaterSurveyTypeDao.selectByCd(surveyTypeCd);
    }

    /**
     * 施設マスタ
     */
    @Override
    public Page<MstFacility> findMstFacilitySortByKana(Pageable pageable) {
      SelectOptions selectOptions = SelectOptionsUtils.get(pageable, false);
      List<MstFacility> mstFacilityList = mstFacilityDao.selectAllSortByKana();
      return new PageImpl<>(mstFacilityList, pageable, selectOptions.getCount());
    }

    /*
     * 放射線検査セットマスタ
     * マスタメンテナンスでの並び順で並び替え
     */
    @Autowired
    private MstAdditionDao mstAdditionDao;

    @Override
    public Page<MstAddition> findMstAdditionByFacilityCd(Pageable pageable, MstAddition params) {
      SelectOptions selectOptions = SelectOptions.get();

      List<MstAddition> mstAdditionList = mstAdditionDao.selectByFacilityCd(params.getFacilityCd());
      return new PageImpl<>(mstAdditionList, pageable, selectOptions.getCount());
    }

    @Autowired
    MstPatEventSubCategoryDao mstPatEventSubCategoryDao;

    /**
     *
     */
    @Override
    public List<MstPatEventSubCategory> selectPatEventSubCategory(Pageable pageable, String facilityCd) {
      SelectOptions selectOptions = SelectOptions.get();
      List<MstPatEventSubCategory> mstPatEventCatList = mstPatEventSubCategoryDao.selectAll(selectOptions,
        facilityCd);
      return mstPatEventCatList;
    }

    /**
     *
     */
    @Override
    public List<MstPatEventSubCategory> selectPatEventSubCategoryIncludeDeleted(Pageable pageable, String facilityCd) {
      SelectOptions selectOptions = SelectOptions.get();
      List<MstPatEventSubCategory> mstPatEventCatList = mstPatEventSubCategoryDao.selectAllIncludeDeleted(selectOptions,
        facilityCd);
      return mstPatEventCatList;
    }

    @Autowired
    MstHolidayDao mstHolidayDao;

    @Override
    public List<HolidayDetail> selectMstHolidayByNkk(Integer holidayY) {
      return mstHolidayDao.selectHolidayDetail(holidayY);
    }

    @Autowired
    private SysFunctionAdvancedDao sysFunctionAdvancedDao;

    @Override
    public List<SysFunctionAdvanced> selectAllSysFunctionAdvanceds() {
      return sysFunctionAdvancedDao.selectAll();
    }

    @Autowired
    private MstUrlLinkRegisterDao mstUrlLinkRegisterDao;

    /**
     * 外部リンク登録マスタを取得する
     *
     * @param facilityCd 施設コード
     * @return 外部リンクリスト
     */
    @Override
    public List<MstUrlLinkRegister> selectAllMstUrlLinkRegister(String facilityCd) {
      return mstUrlLinkRegisterDao.selectAll(facilityCd);
    }

    @Autowired
    private MstMenuGroupDao mstMenuGroupDao;

    /**
     * メニューグループマスタを取得する
     *
     * @param facilityCd 施設コード
     * @return メニューグループリスト
     */
    @Override
    public List<MstMenuGroup> selectAllMstMenuGroup(String facilityCd) {
      return mstMenuGroupDao.selectAll(facilityCd);
    }

    /**
     * 職種マスタを取得する
     *
     * @param facilityCd 施設コード
     * @return 職種リスト
     */
    @Override
    public List<MstJob> selectAllMstJob(String facilityCd) {
      return mstJobDao.selectAll(facilityCd);
    }

    @Autowired
    private MstMachineDao mstMachineDao;

    /**
     * {@inheritDoc}
     */
    @Override
    public List<MstMachine> selectAllMstMachine(String facilityCd) {
      return mstMachineDao.selectByFacilityMappingSelector(facilityCd);
    }

    @Autowired
    private MstAlarmNotificationDao mstAlarmNotificationDao;
    /**
     * 汎用関数サービス
     */
    @Autowired
    private UtilityService utilityService;

    /**
     * {@inheritDoc}
     */
    @Override
    public MstAlarmNotification findAlarmNotificationDetail(Long alarmNotificationCd) {
      MstAlarmNotification result = mstAlarmNotificationDao.selectByAlarmNotificationCdForMstEdit(alarmNotificationCd);
      result.setSmsTel(utilityService.personalInfoDecrypto(result.getSmsTel()));
      return result;
    };

    @Override
    public List<SysFunctionResponse> findSysFuncAdvAndSysFuncByFacilityCd(String facilityCd) {
      MstFacility mstfacility = mstFacilityDao.selectByCd(facilityCd);
      String useFunction = mstfacility.getUseFunction();
      String advancedSettings = mstfacility.getAdvancedSettings();
      MstFacilityHash mstFacilityHash = mstFacilityHashDao.selectByFacilityCd(facilityCd);
      String systemUseSetting = mstFacilityHash.getSystemUseSetting();
      List<SysFunctionResponse> sysFunctionListResponse = new ArrayList<SysFunctionResponse>();
      List<String> isNkkList = new ArrayList<String>();
      List<String> systemUseDispList = new ArrayList<String>();

      // パラメーター設定
      // デフォルト
      isNkkList.add("0");
      systemUseDispList.add("0");

      // 日機装施設の場合、日機装フラグリストに1を追加
      if (facilityCd.equals("nkknkk")) {
        isNkkList.add("1");
      }

      // システム利用設定区分の設定
      // ReMSの場合
      if (systemUseSetting.equals("1")) {
        systemUseDispList.add("1");
      }
      // FNSiの場合
      else if (systemUseSetting.equals("2")) {
        systemUseDispList.add("2");
      }
      // FNSi+ReMSの場合
      else {
        systemUseDispList.add("1");
        systemUseDispList.add("2");
      }

      List<SysFunctionAdvanced> sysFunctionAdvancedList = sysFunctionAdvancedDao.selectByDelAndDisp(FlagType.FLAG_OFF, FlagType.FLAG_ON, isNkkList, systemUseDispList);
      if (sysFunctionAdvancedList.size() > 0) {
        sysFunctionAdvancedList.forEach(i -> {
          if (StringUtils.isEmpty(i.getTargetFacility()) || i.getTargetFacility().contains(facilityCd)) {
            SysFunctionResponse res = new SysFunctionResponse();
            res.setFunctionCd(i.getFunctionAdvCd());
            res.setFunctionName(i.getFunctionAdvName());
            res.setDispOrder(i.getDispOrder());
            res.setAdv(true);
            if (!StringUtils.isEmpty(advancedSettings) && advancedSettings.contains(i.getFunctionAdvCd())) {
              res.setUsedStatus(true);
            } else {
              res.setUsedStatus(false);
            }
            sysFunctionListResponse.add(res);
          }
        });
      }

      List<SysFunction> sysFunctionList = sysFunctionDao.selectByDelAndDisp(FlagType.FLAG_OFF, FlagType.FLAG_ON, isNkkList, systemUseDispList);
      if (sysFunctionList.size() > 0) {
        sysFunctionList.forEach(i -> {
          if (StringUtils.isEmpty(i.getTargetFacility()) || i.getTargetFacility().contains(facilityCd)) {
            SysFunctionResponse res = new SysFunctionResponse();
            res.setFunctionCd(i.getFunctionCd());
            res.setFunctionName(i.getFunctionName());
            res.setDispOrder(i.getDispOrder());
            res.setAdv(false);
            if (!StringUtils.isEmpty(useFunction) && useFunction.contains(i.getFunctionCd())) {
              res.setUsedStatus(true);
            } else {
              res.setUsedStatus(false);
            }
            sysFunctionListResponse.add(res);
          }
        });
      }

      return sysFunctionListResponse;
    }


    /**
     * {@link SysSubscriptionPlanDao}のインスタンス
     */
    @Autowired
    private SysSubscriptionPlanDao sysSubscriptionPlanDao;

    /**
     * {@inheritDoc}
     */
    @Override
    public Page<SysSubscriptionPlan> findSysSubscriptionPlan(Pageable pageable) {
      SelectOptions selectOptions = SelectOptions.get();
      List<SysSubscriptionPlan> SysSubscriptionPlanList = sysSubscriptionPlanDao.selectAll(selectOptions);
      return new PageImpl<>(SysSubscriptionPlanList, pageable, selectOptions.getCount());
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public List<MstTakeMedicine> getTakeMedicine(String listClass, String facilityCd) {
      return mstTakeMedicineDao.selectByListClass(listClass, facilityCd);
    }

    @Autowired
    MstCoopFacilityDao mstCoopFacilityDao;

    /**
     * {@inheritDoc}
     */
    @Override
    public MstCoopFacility getMstCoopFacility(String facilityCd) {
      return mstCoopFacilityDao.select(facilityCd);
    }

    @Autowired
    SysDataListCategoryDao sysDataListCategoryDao;

    /**
     * {@inheritDoc}
     */
    @Override
    public List<SysDataListCategory> findSysDataListCategoryByTemplateCd(Integer templateCd) {
      return sysDataListCategoryDao.selectByTemplateCd(templateCd);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public List<SysFunction> findSysFunctionForLogCondition() {
      return sysFunctionDao.selectSysFunctionForLogCondition();
    }

    /**
     * 検査まとめ表
     */
    @Autowired
    private MstExamMatomeDao mstExamMatomeDao;

    @Override
    public Page<MstExamMatome> findmstExamMatomeAll() {
      List<MstExamMatome> mstExamMatomeList = mstExamMatomeDao.selectAll();
      return new PageImpl<MstExamMatome>(mstExamMatomeList);
    }

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
      eventLogMessage.setServiceName(LoggingConstant.MODULE_NAME.ADMIN_WEB + "," + LoggingConstant.SERVICE_NAME.FNSI);
      return eventLogMessage;
    }


    /**
     * 検索SQL
     *
     * @param tableName テーブル名
     * @param whereStr  検索条件
     */
    private String getSql(String tableName, String whereStr) {
      StringBuffer sql = new StringBuffer("");
      sql.append("select ");
      sql.append("     * ");
      sql.append("from ");
      sql.append(" " + tableName + " ");
      if (!StringUtils.isEmpty(whereStr)) {
        sql.append(whereStr);
      }
      return String.valueOf(sql);
    }

    /**
     * 検索SQL
     *
     * @param facilityCd テーブル名
     * @param codeList   検索条件
     */
    private StringBuffer getSql1(String facilityCd, List<Long> codeList) {

      if (codeList.size() == 0 || facilityCd.equals("")) {
        return null;
      }

      StringBuffer code = new StringBuffer("");
      code.append(" ( ");
      for (Long no : codeList) {
        code.append(no);
        code.append(" ,");
      }
      code.deleteCharAt(code.length() - 1);
      code.append(" ) ");


      StringBuffer sql = new StringBuffer("");
      sql.append("select ");
      sql.append("     * ");
      sql.append("from  ord_main  ");
      sql.append(" where ");
      sql.append("  ord_no in ( ");
      sql.append(" select ");
      sql.append("   ord_no ");
      sql.append("  from  ord_main ");
      sql.append("  where facility_cd = " + facilityCd);
      sql.append("  and  ind_kur_cd in  " + code.toString());
      sql.append(" ) ");

      return sql;


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

    //FNSI-修正 ログ対応 wp add end 20210119

    /**
     * 連携エッジマスタ
     */
    @Autowired
    private MstIfEdgeDao mstIfEdgeDao;

    /**
     * 連携エッジマスタ情報を取得.
     * @param facilityCd 施設コード
     * @return 連携エッジマスタ情報
     */
    @Override
    public List<MstIfEdge> getMstIfEdgeByFacilityCd(String facilityCd){
      return mstIfEdgeDao.selectByFacilityCd(facilityCd);
    }

    /**
     * 連携エッジマスタ情報保存
     * @param mstIfEdge
     * @return
     */
    @Override
    @Transactional
    public boolean submitMstIfEdge(MstIfEdge mstIfEdge){
      Boolean ret = true;

      // 同じ施設のエッジを削除する
      List<MstIfEdge> lstMstIfEdgeToDel = mstIfEdgeDao.selectByFacilityCd(mstIfEdge.getFacilityCd());
      for(int i = 0; i < lstMstIfEdgeToDel.size(); i++)
      {
        MstIfEdge mstIfEdgeToDel = lstMstIfEdgeToDel.get(i);
        mstIfEdgeToDel.setIsDel(FlagType.FLAG_ON);
        mstIfEdgeToDel.setIsDisp(FlagType.FLAG_OFF);
        mstIfEdgeDao.update(mstIfEdgeToDel);
      }

      // 対象エッジを追加する
      MstIfEdge mstIfEdgeCheck = mstIfEdgeDao.selectBySerialNo(mstIfEdge.getSerialNo());
      if (mstIfEdgeCheck == null) {
        mstIfEdgeDao.insert(mstIfEdge);
      }
      else {
        mstIfEdgeDao.update(mstIfEdge);
      }

      return ret;
    }

    /*add FNSI-改修内容5204 任 start*/
    @Override
    public Page<MstMedicine> findMstMedicineUnit(Pageable pageable, MstMedicine params) {
      SelectOptions selectOptions = SelectOptions.get();

      List<MstMedicine> mstMedicineList = mstMedicineDao.selectAllMstMedicineUnit(selectOptions, params);
      return new PageImpl<>(mstMedicineList, pageable, selectOptions.getCount());
    }

    @Override
    public Page<MstMedicineMix> findMstMedicineMixUnit(Pageable pageable, MstMedicineMix params) {
      SelectOptions selectOptions = SelectOptions.get();

      List<MstMedicineMix> mstMedicineMixList = mstMedicineMixDao.selectAllMstMedicineMixUnit(selectOptions, params);
      return new PageImpl<>(mstMedicineMixList, pageable, selectOptions.getCount());
    }

    @Override
    public Page<MstEquipment> findMstEquipmentUnit(Pageable pageable, MstEquipment params) {
      SelectOptions selectOptions = SelectOptions.get();

      List<MstEquipment> mstEquipmentList = mstEquipmentDao.selectAllMstEquipmentUnit(selectOptions, params);
      return new PageImpl<>(mstEquipmentList, pageable, selectOptions.getCount());
    }
    /*add FNSI-改修内容5204 任 end*/

	//mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 start
    /*add by yuyifu 2023-02-03 [CodeOptimization] start*/
    /**
     * getMstMedicineMixTabooAllergy
     *
     * @param medicineMixCd medicineMixCd
     * @param patId         patId
     * @return result
     */
    public MedicineMixSharingInfoResponse getMstMedicineMixSharingInfoByCd(String medicineMixCd, Long patId) {
      MedicineMixSharingInfoResponse result = null;
      List<PatNameIdentification> patIdSrcList = materialsSharingPatientInfomationService.getListPatIdSrcFromPatDst(patId);
      MstMedicineMix res = this.findMstMedicineMixByCd(medicineMixCd);
      MstMedicineMixDto medicineMix = new MstMedicineMixDto();
      if (res != null) {
        BeanUtils.copyProperties(res, medicineMix);
        String facilityCd = medicineMix.getFacilityCd();
        for (PatNameIdentification patIdSrc : patIdSrcList) {
          PatPersonalMain patSrc = patPersonalMainDao.selectById(patIdSrc.getPatIdSrc());
          if (patSrc != null) {
            if (patSrc.getFacility_cd().equals(facilityCd)) {
              result = new MedicineMixSharingInfoResponse();
              //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 start
//              String prefix = "";
//              List<MstMedicineMixDto> listMedicineMixTaboos = this.findMstMedicineMixTabooAllergy(patSrc.getFacility_cd(),
//                patIdSrc.getPatIdSrc(), null);
//              for (MstMedicineMixDto medicineMixTaboo : listMedicineMixTaboos) {
//                if (medicineMixTaboo.getMedicineMixCd().equals(Integer.parseInt(medicineMixCd))) {
//                  if(medicineMixTaboo.getMedicineMixName().equals(medicineMix.getMedicineMixName())) {
//                    result.setIsTabooAllergy(false);
//                  } else {
//                    prefix = medicineMixTaboo.getMedicineMixName().replace(medicineMix.getMedicineMixName(), "");
//                    result.setIsTabooAllergy(true);
//                  }
//                }
//              }
//              result.setPrefix(prefix);
//              result.setMedicineMixName(medicineMix.getMedicineMixName());
              // 配下の薬剤の使用開始日、使用終了日を集計して取得
              List<MstMedicineMixDto> objList = this.mstMedicineMixAddTerm(List.of(medicineMix), patSrc.getFacility_cd(), patId);
              result.setUseStartDate(objList.get(0).getMaxUseStartDate());
              result.setUseEndDate(objList.get(0).getMinUseEndDate());
              //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 end
            }
          }
        }
      }
      return result;
    }
    /*add by yuyifu 2023-02-03 [CodeOptimization] end*/
	//mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 end

  /* add by biangang  2023-01-31 CodeOptimization  start */

  /**
   * ベッドマスタ一覧取得(空きベッド検索)
   *
   * @param bodyData         bodyData
   * @param validationResult validationResult
   * @return 正常終了:検索にヒットしたスケジュールのリスト、異常終了:null
   */
// mod 7238 2023-03-29 予定コピー画面のベッドの並び順が不正 張 start
//  public ResponseEntity<List<MstBed>> getSelectForSearchFreeBeds(ApiEntityMstInfo.ValiSearchFreeBeds bodyData
  @Override
  public ResponseEntity<List<MstBedIndex>> getSelectForSearchFreeBeds(ApiEntityMstInfo.ValiSearchFreeBeds bodyData
    , BindingResult validationResult) {
// mod 7238 2023-03-29 予定コピー画面のベッドの並び順が不正 張 end
    //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("facility_cd:" + bodyData.getFacility_cd());
    logService.log(LogLevel.INFO, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
    eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("pat_id:" + bodyData.getPat_id());
    logService.log(LogLevel.INFO, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
    eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("kur_cd:" + bodyData.getKur_cd());
    logService.log(LogLevel.INFO, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
    eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("treat_week_list:" + bodyData.getTreat_week_list());
    logService.log(LogLevel.INFO, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
    eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("ind_start_date:" + bodyData.getInd_start_date());
    logService.log(LogLevel.INFO, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
    eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("ind_end_date:" + bodyData.getInd_end_date());
    logService.log(LogLevel.INFO, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
    eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("is_all:" + bodyData.getIs_all());
    logService.log(LogLevel.INFO, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
    eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("init_bed_cd:" + bodyData.getInit_bed_cd());
    logService.log(LogLevel.INFO, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
    //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end

    // 更新対象治療方法リスト
    List<Integer> indTreatmentCdList = this.getValueList(bodyData.getInd_treatment_cd());
    // 更新対象クールリスト
    List<Long> indKurCdList = this.getLongList(bodyData.getInd_kur_cd());

    // バリデーションエラーチェック
    if (validationResult.hasErrors()) {
      // バリデーションエラーが発生した場合はパラメータ異常扱い
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("result:" + validationResult);
      logService.log(LogLevel.INFO, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
      for (ObjectError error : validationResult.getFieldErrors()) {
        //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
        eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("error:" + error.getDefaultMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
        //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
      }
      return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
    }

    //add #10784 空きベッドが候補に表示しない  start
    List<OrdMainTreatDate> ordMainTreatDates = new ArrayList<>();
    //add #10784 空きベッドが候補に表示しない  end

    // 曜日パターン情報加工
    List<Integer> weeksArray = IndicationUtils.getWeekPattern(bodyData.getTreat_week_list());
    if (null == weeksArray) {
      // 曜日パターン情報加工に発生した場合はパラメータ異常扱い
      return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
      // add #9274 空きベッドの検索NG dou start
    } else {
      //mod #10784 空きベッドが候補に表示しない  start
//      List<OrdMainTreatDate> ordMainTreatDates = ordMainDao.selectByPatIdAndTreatDate(
//        bodyData.getFacility_cd(), Long.parseLong(bodyData.getPat_id()), bodyData.getInd_start_date().replace("-",""), null);
      ordMainTreatDates = ordMainDao.selectByPatIdAndTreatDate(
        bodyData.getFacility_cd(), Long.parseLong(bodyData.getPat_id()), bodyData.getInd_start_date().replace("-",""), null);
      //mod #10784 空きベッドが候補に表示しない  end
      List<Integer> weeks = ordMainTreatDates.stream().map(x -> Integer.parseInt(x.getTreatWeek()))
        .distinct().collect(Collectors.toList());
      weeksArray = weeksArray.stream().filter(weeks::contains).collect(Collectors.toList());
      // add #9274 空きベッドの検索NG dou end
    }

    Long pat_id = Long.parseLong(bodyData.getPat_id());
    Long kur_cd = Long.parseLong(bodyData.getKur_cd());
    if (0 == kur_cd) kur_cd = null;
    String ind_start_date = bodyData.getInd_start_date().replaceAll("-", "");
    String ind_end_date = null;
    if (false == StringUtils.isEmpty(bodyData.getInd_end_date())) {
      ind_end_date = bodyData.getInd_end_date().replaceAll("-", "");
    }
    boolean is_all = false;
    boolean is_infiniteDate = false;
    try {
      is_all = Boolean.parseBoolean(bodyData.getIs_all());
    } catch (Exception e) {
      //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      //EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage = new EventLogMessage();
      //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      if (bodyData != null && bodyData.getFacility_cd() != null) {
        eventLogMessage.setFacilityCd(bodyData.getFacility_cd());
      }
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
        null);
      // 異常扱い
      return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
    }

    // 施設設定マスタより予定数しきい値を取得する。
    //mod 11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) start
    Long ms_max_treat = 0L;
//    ms_max_treat = Long.parseLong(facilitySettingService.getFacilitySettingValue(
//      bodyData.getFacility_cd(),
//      CoreConstant.FacilitySettingNo.MAX_BED_TREAT_COUNT
//    ));
//mod 11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) end

    // 空きベッド候補切替指示期間(日)を取得する。
    Long ms_bed_change_period = Long.parseLong(facilitySettingService.getFacilitySettingValue(
      bodyData.getFacility_cd(),
      CoreConstant.FacilitySettingNo.BED_SEARCH_RESULT_CHANGE_PERIOD
    ));

    //del 11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) start
    //add #10784 空きベッドが候補に表示しない  start
//    if(ind_end_date == null){
//      if(ordMainTreatDates != null && !ordMainTreatDates.isEmpty()){
//        //get last treat_date
//        ind_end_date = ordMainTreatDates.get(ordMainTreatDates.size() - 1).getTreatDate();
//      }
//    }
    //add #10784 空きベッドが候補に表示しない  end
    //del 11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) end

    // 期間日数の取得
    Long periodDays = Long.MAX_VALUE;
    if (ind_end_date != null) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      try {
        periodDays = DateTimeUtils.getDateDiff(ind_start_date, ind_end_date);
      } catch (ParseException e) {
        EventLogMessage eventLogMessageNew = new EventLogMessage();
        if (bodyData != null && bodyData.getFacility_cd() != null) {
          eventLogMessage.setFacilityCd(bodyData.getFacility_cd());
        }
        eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      //mod 11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) start
//      //add 7211 曜日パターン変更のメッセージ表示や治療予定の移動動作がおかしい 張 start
//    } else {
//      is_all = true;
//      //add 7211 曜日パターン変更のメッセージ表示や治療予定の移動動作がおかしい 張 end
      //mod 11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) end
    }

    // 期間日数が空きベッド候補切替指示期間(日)以上であるか判定
    boolean is_valid_period = false;
    //mod no5639 4676 施設設定No.39が機能していない。 張 start
//    if (periodDays.compareTo(ms_bed_change_period) >= 0) {
//      is_valid_period = true;
    if (ind_end_date != null) {
      if (periodDays.compareTo(ms_bed_change_period) >= 0) {
        //mod 11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) start
//        is_valid_period = true;
        ms_max_treat = Long.parseLong(facilitySettingService.getFacilitySettingValue(
          bodyData.getFacility_cd(),
          CoreConstant.FacilitySettingNo.MAX_BED_TREAT_COUNT
        ));
//        //add #10784 空きベッドが候補に表示しない  start
//        is_infiniteDate = true;
//        //add #10784 空きベッドが候補に表示しない  end
        //mod 11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) end
        //mod 5619 装置と紐づいていないベッドも表示 張 start
//        is_all=true;
      }
      //mod no5639 4676 施設設定No.39が機能していない。 張 end
    } else {
      //mod 11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) start
//      is_infiniteDate = true;
//      is_valid_period = true;
      ms_max_treat = Long.parseLong(facilitySettingService.getFacilitySettingValue(
        bodyData.getFacility_cd(),
        CoreConstant.FacilitySettingNo.MAX_BED_TREAT_COUNT
      ));
      //mod 11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) end
    }
    // 空きベッド検索
    //mod 11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) start
//    List<MstBedIndex> info = mstInfoService.selectForSearchFreeBeds(bodyData.getFacility_cd(), pat_id, kur_cd, weeksArray, ind_start_date, ind_end_date, is_all, ms_max_treat,
////        is_valid_period, indTreatmentCdList, indKurCdList);
//      is_valid_period, indTreatmentCdList, indKurCdList, bodyData.getInit_bed_cd(), is_infiniteDate);
    if(kur_cd == null){
      is_all = true;
    }
    List<MstBedIndex> info = mstInfoService.selectForSearchFreeBeds(bodyData.getFacility_cd(), pat_id, kur_cd, weeksArray, ind_start_date, ind_end_date,
      is_all, ms_max_treat, indTreatmentCdList, indKurCdList);
    //mod 11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) end
//mos 5619 装置と紐づいていないベッドも表示 張 end

    if (info.size() < 0) {
      // 異常扱い
      return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
    }

    return new ResponseEntity<>(info, HttpStatus.OK);
  }

  /***
   * JSON配列データから値を取得し、Integer配列データを返す
   * @param stringList
   * @return
   */
  private List<Integer> getValueList(String stringList) {
    JSONArray json;
    List<Integer> valueArry = new ArrayList<Integer>();
    try {
      if (null == stringList) return valueArry;
      json = new JSONArray(stringList);
      // 選択された値を配列に格納
      for (int i = 0; i < json.length(); i++) {
        valueArry.add((int) (json.get(i)));
      }
    } catch (JSONException e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      return new ArrayList<Integer>();
    }
    return valueArry;
  }

  /**
   * JSON配列データをLong配列に変換して返す
   *
   * @param stringList
   * @return
   */
  private List<Long> getLongList(String stringList) {
    List<Long> longList = new ArrayList<Long>();
    try {
      // 値が入っていなければ、処理を終了して空の配列を返す
      if (null == stringList) return longList;
      JSONArray json = new JSONArray(stringList);
      // 選択された値を配列に格納
      for (int i = 0; i < json.length(); i++) {
        int intData = (int) (json.getInt(i));
        long l = intData;
        longList.add(l);
      }
    } catch (JSONException e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      return new ArrayList<Long>();
    }
    return longList;
  }
  /* add by biangang  2023-01-31 CodeOptimization  end */

  /* add by biangang  2023-01-31 CodeOptimization  start */

  /**
   * ダイアライザー名を取得
   */
  public ResponseEntity<DialyzerSharingInfoResponse> getMstDialyzerSharingInfoByCd(String dialyzerCd,
                                                                                   Long patId) {
    DialyzerSharingInfoResponse result = null;
    List<PatNameIdentification> patIdSrcList = materialsSharingPatientInfomationService.getListPatIdSrcFromPatDst(patId);
    MstDialyzer dialyzer = mstInfoService.findMstDialyzerByCd(dialyzerCd);
    if (dialyzer != null) {
      String facilityCd = dialyzer.getFacilityCd();
      for (PatNameIdentification patIdSrc : patIdSrcList) {
        PatPersonalMain patSrc = patPersonalMainDao.selectById(patIdSrc.getPatIdSrc());
        if (patSrc != null) {
          if (patSrc.getFacility_cd().equals(facilityCd)) {
            result = new DialyzerSharingInfoResponse();
            String prefix = "";
            String makerName = "";
            //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 start
            //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　Start
            List<MstDialyzerDto> listDialyzerTaboos = mstInfoService.findMstDialyzerTabooAllergy(patSrc.getFacility_cd(),
              patIdSrc.getPatIdSrc(), null);
            //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　End
            //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 end
            for (MstDialyzer dialyzerTaboo : listDialyzerTaboos) {
              if (dialyzerTaboo.getDialyzerCd().equals(Integer.parseInt(dialyzerCd))) {
                if (dialyzerTaboo.getModelNumber().equals(dialyzer.getModelNumber())) {
                  result.setIsTabooAllergy(false);
                } else {
                  prefix = dialyzerTaboo.getModelNumber().replace(dialyzer.getModelNumber(), "");
                  result.setIsTabooAllergy(true);
                }
                if (dialyzer.getMaker() != null) {
                  makerName = dialyzer.getMaker();
                }
              }
            }
            result.setPrefix(prefix);
            result.setDialyzerName(prefix + makerName + "[" + dialyzer.getModelNumber() + "]");
            result.setUseStartDate(dialyzer.getUseStartDate());
            result.setUseEndDate(dialyzer.getUseEndDate());
          }
        }
      }
    }
    return new ResponseEntity<>(result, HttpStatus.OK);
  }
  /* add by biangang  2023-01-31 CodeOptimization  end */

  /* add by biangang  2023-02-01 CodeOptimization  start */

  /**
   * コードで機器を入手する
   */
  public ResponseEntity<EquipmentSharingInfoResponse> getMstEquipmentSharingInfoByCd(String equipmentCd,
                                                                                     Long patId) {
    EquipmentSharingInfoResponse result = null;
    List<PatNameIdentification> patIdSrcList = materialsSharingPatientInfomationService.getListPatIdSrcFromPatDst(patId);
    MstEquipment equipment = mstInfoService.findMstEquipmentByCd(equipmentCd);
    if (equipment != null) {
      String facilityCd = equipment.getFacilityCd();
      for (PatNameIdentification patIdSrc : patIdSrcList) {
        PatPersonalMain patSrc = patPersonalMainDao.selectById(patIdSrc.getPatIdSrc());
        if (patSrc != null) {
          if (patSrc.getFacility_cd().equals(facilityCd)) {
            result = new EquipmentSharingInfoResponse();
            String prefix = "";
            List<Integer> typeCdList = new ArrayList<>();
            //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 start
            //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　Start
            List<MstEquipmentDto> listEquipmentTaboos = mstInfoService.findMstEquipmentTabooAllergy(patSrc.getFacility_cd(),
              patIdSrc.getPatIdSrc(), typeCdList, null);
            //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　End
            for (MstEquipmentDto equipmentTaboo : listEquipmentTaboos) {
              if (equipmentTaboo.getEquipmentCd().equals(Integer.parseInt(equipmentCd))) {
                if (equipmentTaboo.getEquipmentName().equals(equipment.getEquipmentName())) {
                  result.setIsTabooAllergy(false);
                } else {
                  prefix = equipmentTaboo.getEquipmentName().replace(equipment.getEquipmentName(), "");
                  result.setIsTabooAllergy(true);
                }
              }
            }
            //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 end
            result.setPrefix(prefix);
            result.setEquipmentName(equipment.getEquipmentName());
            result.setUseStartDate(equipment.getUseStartDate());
            result.setUseEndDate(equipment.getUseEndDate());
          }
        }
      }
    }
    return new ResponseEntity<>(result, HttpStatus.OK);
  }
  /* add by biangang  2023-02-01 CodeOptimization  end */

  /* add by biangang  2023-02-01 CodeOptimization  start */

  /**
   * コードで薬を手に入れる
   */
  public ResponseEntity<MedicineSharingInfoResponse> getMstMedicineSharingInfoByCd(String medicineCd,
                                                                                   Long patId) {
    MedicineSharingInfoResponse result = null;
    List<PatNameIdentification> patIdSrcList = materialsSharingPatientInfomationService.getListPatIdSrcFromPatDst(patId);
    MstMedicine medicine = mstInfoService.findMstMedicineByCd(medicineCd);
    if (medicine != null) {
      String facilityCd = medicine.getFacilityCd();
      for (PatNameIdentification patIdSrc : patIdSrcList) {
        PatPersonalMain patSrc = patPersonalMainDao.selectById(patIdSrc.getPatIdSrc());
        if (patSrc != null) {
          if (patSrc.getFacility_cd().equals(facilityCd)) {
            result = new MedicineSharingInfoResponse();
            String prefix = "";
			      //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 start
            List<MstMedicineDto> listMedicineTaboos = mstInfoService.findMstMedicineTabooAllergy(patSrc.getFacility_cd(),
              patIdSrc.getPatIdSrc(), null);
			      //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 end
            for (MstMedicine medicineTaboo : listMedicineTaboos) {
              if (medicineTaboo.getMedicineCd().equals(Integer.parseInt(medicineCd))) {
                if (medicineTaboo.getMedicineName().equals(medicine.getMedicineName())) {
                  result.setIsTabooAllergy(false);
                } else {
                  prefix = medicineTaboo.getMedicineName().replace(medicine.getMedicineName(), "");
                  result.setIsTabooAllergy(true);
                }
              }
            }
            result.setPrefix(prefix);
            result.setMedicineName(medicine.getMedicineName());
            result.setUseStartDate(medicine.getUseStartDate());
            result.setUseEndDate(medicine.getUseEndDate());
          }
        }
      }
    }
    return new ResponseEntity<>(result, HttpStatus.OK);
  }
  /* add by biangang  2023-02-01 CodeOptimization  end */

  //add #10236 api要求をマージして、ブラウザ要求スレッドのスタックをできるだけ減らす shiyw start
  /**
   * Master情報一括取得
   * @param mstInfoRequest
   * @return Map<String, Object>
   */
  public Map<String, Object> getMstInfo(MstInfoRequest mstInfoRequest){
    String facilityCd = mstInfoRequest.getFacilityCd();
    Map<String, Object> response = new HashMap<>();
    List<String> reqMstNames = Arrays.stream(mstInfoRequest.getReqMstNames().split(",")).toList();

    // 禁忌・アレルギークラス (削除されたを含む)
    if(reqMstNames.contains(MstInfoRequest.ReqMstName.MST_TABOO_ALLERGY_INCLUDE_DELETED.getName())){
      MstTabooAllergy mstParams = new MstTabooAllergy();
      mstParams.setFacilityCd(facilityCd);
      List<MstTabooAllergy> mstDataList = mstTabooAllergyDao.selectAllIncludeDeleted( SelectOptions.get(), mstParams);
      response.put(MstInfoRequest.ReqMstName.MST_TABOO_ALLERGY_INCLUDE_DELETED.getName(), mstDataList);
    }

    // 禁忌・アレルギークラス
    if(reqMstNames.contains(MstInfoRequest.ReqMstName.MST_TABOO_ALLERGY.getName())){
      List<MstTabooAllergy> mstDataList = mstTabooAllergyDao.getMstTabooAllergyInfoByFacilityCd(facilityCd);
      response.put(MstInfoRequest.ReqMstName.MST_TABOO_ALLERGY.getName(), mstDataList);
    }

    // 薬剤クラス
    if(reqMstNames.contains(MstInfoRequest.ReqMstName.MST_MEDICINE.getName())){
      MstMedicine mstParams = new MstMedicine();
      mstParams.setFacilityCd(facilityCd);
      List<MstMedicine> mstDataList = mstMedicineDao.selectAll(SelectOptions.get(), mstParams);
      response.put(MstInfoRequest.ReqMstName.MST_MEDICINE.getName(), mstDataList);
    }

    // 薬剤クラス (削除されたを含む)
    if(reqMstNames.contains(MstInfoRequest.ReqMstName.MST_MEDICINE_INCLUDE_DELETED.getName())){
      MstMedicine mstParams = new MstMedicine();
      mstParams.setFacilityCd(facilityCd);
      List<MstMedicine> mstDataList = mstMedicineDao.selectAllIncludeDeleted(SelectOptions.get(), mstParams);
      response.put(MstInfoRequest.ReqMstName.MST_MEDICINE_INCLUDE_DELETED.getName(), mstDataList);
    }

    // 薬剤分類クラス
    if(reqMstNames.contains(MstInfoRequest.ReqMstName.MST_MEDICINE_CLASS.getName())){
      MstMedicineClass mstParams = new MstMedicineClass();
      mstParams.setFacilityCd(facilityCd);
      List<MstMedicineClass> mstDataList = mstMedicineClassDao.selectAll(SelectOptions.get(), mstParams);
      response.put(MstInfoRequest.ReqMstName.MST_MEDICINE_CLASS.getName(), mstDataList);
    }
    // 薬剤分類クラス (削除されたを含む)
    if(reqMstNames.contains(MstInfoRequest.ReqMstName.MST_MEDICINE_CLASS_INCLUDE_DELETED.getName())){
      MstMedicineClass mstParams = new MstMedicineClass();
      mstParams.setFacilityCd(facilityCd);
      List<MstMedicineClass> mstDataList = mstMedicineClassDao.selectAllIncludeDeleted(SelectOptions.get(), mstParams);
      response.put(MstInfoRequest.ReqMstName.MST_MEDICINE_CLASS_INCLUDE_DELETED.getName(), mstDataList);
    }

    // 医療材料クラス
    if(reqMstNames.contains(MstInfoRequest.ReqMstName.MST_EQUIPMENT.getName())){
      MstEquipment mstParams = new MstEquipment();
      mstParams.setFacilityCd(facilityCd);
      List<MstEquipment> mstDataList = mstEquipmentDao.selectAll(SelectOptions.get(), mstParams);
      response.put(MstInfoRequest.ReqMstName.MST_EQUIPMENT.getName(), mstDataList);
    }
    // 医療材料クラス (削除されたを含む)
    if(reqMstNames.contains(MstInfoRequest.ReqMstName.MST_EQUIPMENT_INCLUDE_DELETED.getName())){
      MstEquipment mstParams = new MstEquipment();
      mstParams.setFacilityCd(facilityCd);
      List<MstEquipment> mstDataList = mstEquipmentDao.selectAllIncludeDeleted(SelectOptions.get(), mstParams);
      response.put(MstInfoRequest.ReqMstName.MST_EQUIPMENT_INCLUDE_DELETED.getName(), mstDataList);
    }

    // 医療材料分類クラス
    if(reqMstNames.contains(MstInfoRequest.ReqMstName.MST_EQUIPMENT_CLASS.getName())){
      MstEquipmentClass mstParams = new MstEquipmentClass();
      mstParams.setFacilityCd(facilityCd);
      List<MstEquipmentClass> mstDataList = mstEquipmentClassDao.selectAll(SelectOptions.get(), mstParams);
      response.put(MstInfoRequest.ReqMstName.MST_EQUIPMENT_CLASS.getName(), mstDataList);
    }

    // ダイアライザクラス (削除されたを含む)
    if(reqMstNames.contains(MstInfoRequest.ReqMstName.MST_DIALYZER_INCLUDE_DELETED.getName())){
      MstDialyzer mstParams = new MstDialyzer();
      mstParams.setFacilityCd(facilityCd);
      List<MstDialyzer> mstDataList = mstDialyzerDao.selectAllIncludeDeleted(SelectOptions.get(), mstParams);
      response.put(MstInfoRequest.ReqMstName.MST_DIALYZER_INCLUDE_DELETED.getName(), mstDataList);
    }

    // 一般名処方クラス (削除されたを含む)
    if(reqMstNames.contains(MstInfoRequest.ReqMstName.SYS_GENERIC_MEDICINE_INCLUDE_DELETED.getName())){
      List<SysGenericMedicine> mstDataList = sysGenericMedicineDao.selectAllIncludeDeleted(SelectOptions.get());
      response.put(MstInfoRequest.ReqMstName.SYS_GENERIC_MEDICINE_INCLUDE_DELETED.getName(), mstDataList);
    }

    // 調製薬剤マスタクラス
    if(reqMstNames.contains(MstInfoRequest.ReqMstName.MST_MEDICINE_MIX.getName())){
      MstMedicineMix mstParams = new MstMedicineMix();
      mstParams.setFacilityCd(facilityCd);
      List<MstMedicineMix> mstDataList = mstMedicineMixDao.selectAll(SelectOptions.get(), mstParams);
      response.put(MstInfoRequest.ReqMstName.MST_MEDICINE_MIX.getName(), mstDataList);
    }
    // 調製薬剤マスタクラス (削除されたを含む)
    if(reqMstNames.contains(MstInfoRequest.ReqMstName.MST_MEDICINE_MIX_INCLUDE_DELETED.getName())){
      MstMedicineMix mstParams = new MstMedicineMix();
      mstParams.setFacilityCd(facilityCd);
      List<MstMedicineMix> mstDataList = mstMedicineMixDao.selectAllIncludeDeleted(SelectOptions.get(), mstParams);

      List<MstMedicineMixExtendsDto> res = new ArrayList<>();
      if (mstDataList != null && !mstDataList.isEmpty()) {
        MasterCacheHandler masterCacheHandler = MasterCacheHandler.get();
        for (MstMedicineMix mstMedicineMix : mstDataList) {
          MstMedicineMixExtendsDto mstMedicineMixExtendsDto = new MstMedicineMixExtendsDto();
          BeanUtils.copyProperties(mstMedicineMix, mstMedicineMixExtendsDto);
          mstMedicineMixExtendsDto.setIsIncludeDel(false);
          String mixInfo = mstMedicineMix.getMixInfo();
          if (mixInfo != null) {
            JSONArray mixInfoJsonArr = new JSONArray(mixInfo);
            for (int i = 0; i < mixInfoJsonArr.length(); i++) {
              JSONObject jObj = (JSONObject) mixInfoJsonArr.get(i);
              if (jObj.has("cd")) {
                Integer cd = jObj.getInt("cd");
                MstMedicine mstMedicine = masterCacheHandler.getMstMedicineByCd(cd);
                if (mstMedicine != null) {
                  String isDisp = mstMedicine.getIsDisp();
                  String isDel = mstMedicine.getIsDel();
                  boolean isNot = "0".equals(isDisp) || "1".equals(isDel);
                  mstMedicineMixExtendsDto.setIsIncludeDel(isNot);
                  if(isNot){
                    break;
                  }
                }
              }
            }
          }
          res.add(mstMedicineMixExtendsDto);
        }
      }

      response.put(MstInfoRequest.ReqMstName.MST_MEDICINE_MIX_INCLUDE_DELETED.getName(), res);
    }

    // インプラントクラス
    if(reqMstNames.contains(MstInfoRequest.ReqMstName.MST_IMPLANT.getName())){
      MstImplant mstParams = new MstImplant();
      mstParams.setFacilityCd(facilityCd);
      List<MstImplant> mstDataList = mstImplantDao.selectAll(SelectOptions.get(), mstParams);
      response.put(MstInfoRequest.ReqMstName.MST_IMPLANT.getName(), mstDataList);
    }

    // 感染症クラ
    if(reqMstNames.contains(MstInfoRequest.ReqMstName.MST_INFECTION.getName())){
      MstInfection mstParams = new MstInfection();
      mstParams.setFacilityCd(facilityCd);
      List<MstInfection> mstDataList = mstInfectionDao.selectAll(SelectOptions.get(), mstParams);
      response.put(MstInfoRequest.ReqMstName.MST_INFECTION.getName(), mstDataList);
    }

    // VAクラス
    if(reqMstNames.contains(MstInfoRequest.ReqMstName.MST_VA.getName())){
      MstVa mstParams = new MstVa();
      mstParams.setFacilityCd(facilityCd);
      List<MstVa> mstDataList = mstVaDao.selectAll(SelectOptions.get(), mstParams);
      response.put(MstInfoRequest.ReqMstName.MST_VA.getName(), mstDataList);
    }

    //  VAクラス(削除された)
    if(reqMstNames.contains(MstInfoRequest.ReqMstName.MST_VA_DELETED.getName())){
      MstVa mstParams = new MstVa();
      mstParams.setFacilityCd(facilityCd);
      List<MstVa> mstDataList = mstVaDao.selectAllNoDel(SelectOptions.get(), mstParams);
      response.put(MstInfoRequest.ReqMstName.MST_VA_DELETED.getName(), mstDataList);
    }

    // ダイアライザクラス
    if(reqMstNames.contains(MstInfoRequest.ReqMstName.MST_DIALYZE.getName())){
      MstDialyzer mstParams = new MstDialyzer();
      mstParams.setFacilityCd(facilityCd);
      List<MstDialyzer> mstDataList = mstDialyzerDao.selectAll(SelectOptions.get(), mstParams);
      response.put(MstInfoRequest.ReqMstName.MST_DIALYZE.getName(), mstDataList);
    }

    //  ダイアライザクラス(削除された)
    if(reqMstNames.contains(MstInfoRequest.ReqMstName.MST_DIALYZE_DELETED.getName())){
      MstDialyzer mstParams = new MstDialyzer();
      mstParams.setFacilityCd(facilityCd);
      List<MstDialyzer> mstDataList = mstDialyzerDao.selectAllNoDel(SelectOptions.get(), mstParams);
      response.put(MstInfoRequest.ReqMstName.MST_DIALYZE_DELETED.getName(), mstDataList);
    }

    // 手技クラス
    if(reqMstNames.contains(MstInfoRequest.ReqMstName.MST_PROCEDURE.getName())){
      MstProcedure mstParams = new MstProcedure();
      mstParams.setFacilityCd(facilityCd);
      List<MstProcedure> mstDataList = mstProcedureDao.selectAll(SelectOptions.get(), mstParams);
      response.put(MstInfoRequest.ReqMstName.MST_PROCEDURE.getName(), mstDataList);
    }

    // 投与タイミングクラス
    if(reqMstNames.contains(MstInfoRequest.ReqMstName.MST_MEDICATE_TIMING.getName())){
      MstMedicateTiming mstParams = new MstMedicateTiming();
      mstParams.setFacilityCd(facilityCd);
      List<MstMedicateTiming> mstDataList = mstMedicateTimingDao.selectAll(SelectOptions.get(), mstParams);
      response.put(MstInfoRequest.ReqMstName.MST_MEDICATE_TIMING.getName(), mstDataList);
    }

    // 投薬支援マスタ
    if(reqMstNames.contains(MstInfoRequest.ReqMstName.MNT_MEDICINE_SUPPORT.getName())){
      List<MntMedicineSupport> mstDataList = mstSupportDao.selectMedicineSupport(facilityCd);
      response.put(MstInfoRequest.ReqMstName.MNT_MEDICINE_SUPPORT.getName(), mstDataList);
    }

    // 治療方法マスタ
    if(reqMstNames.contains(MstInfoRequest.ReqMstName.MST_TREATMENT.getName())){
      MstTreatment mstParams = new MstTreatment();
      mstParams.setFacilityCd(facilityCd);
      List<MstTreatment> mstDataList = mstTreatmentDao.selectAll(SelectOptions.get(), mstParams);
      response.put(MstInfoRequest.ReqMstName.MST_TREATMENT.getName(), mstDataList);
    }

    // 治療方法マスタ(削除された)
    if(reqMstNames.contains(MstInfoRequest.ReqMstName.MST_TREATMENT_DELETED.getName())){
      MstTreatment mstParams = new MstTreatment();
      mstParams.setFacilityCd(facilityCd);
      List<MstTreatment> mstDataList = mstTreatmentDao.selectAllDel(SelectOptions.get(), mstParams);
      response.put(MstInfoRequest.ReqMstName.MST_TREATMENT_DELETED.getName(), mstDataList);
    }

    // 治療方法マスタ (削除されたを含む)
    if(reqMstNames.contains(MstInfoRequest.ReqMstName.MST_TREATMENT_INCLUDE_DELETED.getName())){
      MstTreatment mstParams = new MstTreatment();
      mstParams.setFacilityCd(facilityCd);
      List<MstTreatment> mstDataList = mstTreatmentDao.selectAllIncludeDeleted(SelectOptions.get(), mstParams);
      response.put(MstInfoRequest.ReqMstName.MST_TREATMENT_INCLUDE_DELETED.getName(), mstDataList);
    }

    // クールクラス
    if(reqMstNames.contains(MstInfoRequest.ReqMstName.MST_KUR.getName())){
      List<MstKur> mstDataList = mstKurDao.selectByFacilityCd(SelectOptions.get(), facilityCd, "0");
      response.put(MstInfoRequest.ReqMstName.MST_KUR.getName(), mstDataList);
    }

    // ベッドマスタ
    if(reqMstNames.contains(MstInfoRequest.ReqMstName.MST_BED.getName())){
      List<MstBed> mstDataList = mstBedDao.selectAllByFacilityCd(facilityCd);
      response.put(MstInfoRequest.ReqMstName.MST_BED.getName(), mstDataList);
    }

    return response;
  }
  //add #10236 api要求をマージして、ブラウザ要求スレッドのスタックをできるだけ減らす shiyw end

  /* add by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
  public Map<String, Object> getMstInfoByOrdNo(List<Long> ordNoList) {
    Map<String, Object> response = new HashMap<>();
    if (ObjectUtils.isEmpty(ordNoList)) {
      return response;
    }

    // 治療方法マスタ
    List<MstTreatment> mstTreatments = mstTreatmentDao.selectByOrdNoListToIndAndRst(ordNoList);
    response.put(MstInfoRequest.ReqMstName.MST_TREATMENT.getName(), mstTreatments);

    // 手技クラス
    List<MstProcedure> mstProcedures = mstProcedureDao.selectByOrdNoList(ordNoList);
    response.put(MstInfoRequest.ReqMstName.MST_PROCEDURE.getName(), mstProcedures);

    // 投与タイミングクラス
    List<MstMedicateTiming> mstMedicateTimings = mstMedicateTimingDao.selectByOrdNoList(ordNoList);
    response.put(MstInfoRequest.ReqMstName.MST_MEDICATE_TIMING.getName(), mstMedicateTimings);

    List<MstMedicineMix> medicineMixs = mstMedicineMixDao.selectByOrdNoList(ordNoList);
    response.put(MstInfoRequest.ReqMstName.MST_MEDICINE_MIX.getName(), medicineMixs);

    return response;
  }
  /* add by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstTreatmentStatusDispItem> getMstTreatmentStatusDispItemAll() {
    return mstTreatmentStatusDispItemDao.selectAllExceptDeleted();
  }
  //add #12462 患者情報共有- 患者カレンダー zrx start
  @Override
  public Map<String, Object> getShrMstInfoByPatId(MstInfoRequest mstInfoRequest) {
//    String facilityCd = mstInfoRequest.getFacilityCd();
    Map<String, Object> response = new HashMap<>();
    if (mstInfoRequest.getReqMstNames() == null || mstInfoRequest.getReqMstNames().isEmpty()) {
      return response;
    }
    List<String> reqMstNames = Arrays.stream(mstInfoRequest.getReqMstNames().split(",")).toList();
    List<String> targetFacilityCds = new ArrayList<>();
//    targetFacilityCds.add(facilityCd);
    Long patId = mstInfoRequest.getPatId();
    if (patId != null) {
      List<PatNameIdentification> srcPatIds = materialsSharingPatientInfomationService.getListPatIdSrcFromPatTo(patId);
      for (PatNameIdentification patIdsrc : srcPatIds) {
        String facilityCdTemp = patIdsrc.getFacilityCdSrc();
        if (facilityCdTemp != null && !targetFacilityCds.contains(facilityCdTemp)) {
          targetFacilityCds.add(facilityCdTemp);
        }
      }
    }

    if(reqMstNames.contains(MstInfoRequest.ReqMstName.MST_TABOO_ALLERGY_INCLUDE_DELETED.getName())){
      List<MstTabooAllergy> mstDataList = new ArrayList<>();
      for (String targetFacilityCd : targetFacilityCds) {
        MstTabooAllergy mstParams = new MstTabooAllergy();
        mstParams.setFacilityCd(targetFacilityCd);
        mstDataList.addAll(mstTabooAllergyDao.selectAllIncludeDeleted(SelectOptions.get(), mstParams));
      }
      response.put(MstInfoRequest.ReqMstName.MST_TABOO_ALLERGY_INCLUDE_DELETED.getName(), mstDataList);
    }

    if(reqMstNames.contains(MstInfoRequest.ReqMstName.MST_MEDICINE_INCLUDE_DELETED.getName())){
      List<MstMedicine> mstDataList = new ArrayList<>();
      for (String targetFacilityCd : targetFacilityCds) {
        MstMedicine mstParams = new MstMedicine();
        mstParams.setFacilityCd(targetFacilityCd);
        mstDataList.addAll(mstMedicineDao.selectAllIncludeDeleted(SelectOptions.get(), mstParams));
      }
      response.put(MstInfoRequest.ReqMstName.MST_MEDICINE_INCLUDE_DELETED.getName(), mstDataList);
    }

    if(reqMstNames.contains(MstInfoRequest.ReqMstName.MST_EQUIPMENT_INCLUDE_DELETED.getName())){
      List<MstEquipment> mstDataList = new ArrayList<>();
      for (String targetFacilityCd : targetFacilityCds) {
        MstEquipment mstParams = new MstEquipment();
        mstParams.setFacilityCd(targetFacilityCd);
        mstDataList.addAll(mstEquipmentDao.selectAllIncludeDeleted(SelectOptions.get(), mstParams));
      }
      response.put(MstInfoRequest.ReqMstName.MST_EQUIPMENT_INCLUDE_DELETED.getName(), mstDataList);
    }

    if(reqMstNames.contains(MstInfoRequest.ReqMstName.MST_DIALYZER_INCLUDE_DELETED.getName())){
      List<MstDialyzer> mstDataList = new ArrayList<>();
      for (String targetFacilityCd : targetFacilityCds) {
        MstDialyzer mstParams = new MstDialyzer();
        mstParams.setFacilityCd(targetFacilityCd);
        mstDataList.addAll(mstDialyzerDao.selectAllIncludeDeleted(SelectOptions.get(), mstParams));
      }
      response.put(MstInfoRequest.ReqMstName.MST_DIALYZER_INCLUDE_DELETED.getName(), mstDataList);
    }

    if(reqMstNames.contains(MstInfoRequest.ReqMstName.MST_MEDICINE_MIX_INCLUDE_DELETED.getName())){
      List<MstMedicineMix> mstDataList = new ArrayList<>();
      for (String targetFacilityCd : targetFacilityCds) {
        MstMedicineMix mstParams = new MstMedicineMix();
        mstParams.setFacilityCd(targetFacilityCd);
        mstDataList.addAll(mstMedicineMixDao.selectAllIncludeDeleted(SelectOptions.get(), mstParams));
      }
      List<MstMedicineMixExtendsDto> res = new ArrayList<>();
      if (mstDataList != null && !mstDataList.isEmpty()) {
        MasterCacheHandler masterCacheHandler = MasterCacheHandler.get();
        for (MstMedicineMix mstMedicineMix : mstDataList) {
          MstMedicineMixExtendsDto mstMedicineMixExtendsDto = new MstMedicineMixExtendsDto();
          BeanUtils.copyProperties(mstMedicineMix, mstMedicineMixExtendsDto);
          mstMedicineMixExtendsDto.setIsIncludeDel(false);
          String mixInfo = mstMedicineMix.getMixInfo();
          if (mixInfo != null) {
            JSONArray mixInfoJsonArr = new JSONArray(mixInfo);
            for (int i = 0; i < mixInfoJsonArr.length(); i++) {
              JSONObject jObj = (JSONObject) mixInfoJsonArr.get(i);
              if (jObj.has("cd")) {
                Integer cd = jObj.getInt("cd");
                MstMedicine mstMedicine = masterCacheHandler.getMstMedicineByCd(cd);
                if (mstMedicine != null) {
                  String isDisp = mstMedicine.getIsDisp();
                  String isDel = mstMedicine.getIsDel();
                  boolean isNot = "0".equals(isDisp) || "1".equals(isDel);
                  mstMedicineMixExtendsDto.setIsIncludeDel(isNot);
                  if(isNot){
                    break;
                  }
                }
              }
            }
          }
          res.add(mstMedicineMixExtendsDto);
        }
      }
      response.put(MstInfoRequest.ReqMstName.MST_MEDICINE_MIX_INCLUDE_DELETED.getName(), res);
    }

    return response;
  }
  //add #12462 患者情報共有- 患者カレンダー zrx end
}
