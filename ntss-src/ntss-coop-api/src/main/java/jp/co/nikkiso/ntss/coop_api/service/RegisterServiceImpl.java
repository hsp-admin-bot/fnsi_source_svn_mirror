package jp.co.nikkiso.ntss.coop_api.service;

// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.toJson;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end

import java.net.URI;
import java.net.URISyntaxException;
import java.sql.Timestamp;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.TimeZone;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.collections.MapUtils;
import org.apache.commons.lang3.math.NumberUtils;
import org.json.JSONArray;
import org.json.JSONObject;
import org.seasar.doma.jdbc.Config;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import org.springframework.aop.framework.AopProxyUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.http.client.HttpComponentsClientHttpRequestFactory;
import org.springframework.scheduling.annotation.Async;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestTemplate;

import com.fasterxml.jackson.core.type.TypeReference;

import jp.co.nikkiso.ntss.api.model.JournalCreateRequestPayload;
import jp.co.nikkiso.ntss.api.service.SysDataSetService;
import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.coop_api.entityLogic.EntityLogic;
import jp.co.nikkiso.ntss.coop_api.request.CallApiJournalRequest;
import jp.co.nikkiso.ntss.coop_api.request.JournalCreateRequest;
import jp.co.nikkiso.ntss.coop_api.response.JournalConvertResult.ResultKey;
import jp.co.nikkiso.ntss.coop_api.response.JournalConvertResult.ResultMap;
import jp.co.nikkiso.ntss.coop_api.utils.ClockWrapper;
import jp.co.nikkiso.ntss.coop_api.utils.CoopCdConstant;
import jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants;
import jp.co.nikkiso.ntss.coop_api.utils.JournalConvertUtil;
import jp.co.nikkiso.ntss.coop_api.utils.Key0Constant;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants.AnaResult;
import jp.co.nikkiso.ntss.coop_api.utils.ReceiveCoopOrdNoConstants;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.Db6FunctionDao;
import jp.co.nikkiso.ntss.core.dao.MstCoopFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstCoopIniDao;
import jp.co.nikkiso.ntss.core.dao.MstCoopLayoutDao;
import jp.co.nikkiso.ntss.core.dao.MstCourseDao;
import jp.co.nikkiso.ntss.core.dao.MstDialysisDifficultyDao;
import jp.co.nikkiso.ntss.core.dao.MstDialyzerDao;
import jp.co.nikkiso.ntss.core.dao.MstDiseaseDao;
import jp.co.nikkiso.ntss.core.dao.MstEquipmentDao;
import jp.co.nikkiso.ntss.core.dao.MstExamItemDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstFavoriteFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstImplantDao;
import jp.co.nikkiso.ntss.core.dao.MstInfectionDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstSelectorDao;
import jp.co.nikkiso.ntss.core.dao.MstSeverityDao;
import jp.co.nikkiso.ntss.core.dao.MstTransportDao;
import jp.co.nikkiso.ntss.core.dao.MstUserAuthenticationDao;
import jp.co.nikkiso.ntss.core.dao.MstUserDao;
import jp.co.nikkiso.ntss.core.dao.MstWardDao;
import jp.co.nikkiso.ntss.core.dao.OrdCoopNoDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainRestoreDao;
import jp.co.nikkiso.ntss.core.dao.PatCoopDetailDao;
import jp.co.nikkiso.ntss.core.dao.PatExamMainDao;
import jp.co.nikkiso.ntss.core.dao.PatGroupDetailDao;
import jp.co.nikkiso.ntss.core.dao.PatInsuranceDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatObsRecDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.PatUniqueDao;
import jp.co.nikkiso.ntss.core.dao.SysCoopJournalDao;
import jp.co.nikkiso.ntss.core.dao.SysCoopNoDao;
import jp.co.nikkiso.ntss.core.dao.SysDataSetAuthorityDao;
import jp.co.nikkiso.ntss.core.dao.SysDataSetDao;
import jp.co.nikkiso.ntss.core.dao.SysDataSetPersonalDao;
import jp.co.nikkiso.ntss.core.dao.SysFacilityDao;
import jp.co.nikkiso.ntss.core.entity.MstCoopLayout;
import jp.co.nikkiso.ntss.core.entity.MstExamItem;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstSelector;
import jp.co.nikkiso.ntss.core.entity.OrdCoopNo;
import jp.co.nikkiso.ntss.core.entity.PatInfo;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.SysDataSet;
import jp.co.nikkiso.ntss.core.entity.PatUnique;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;
import jp.co.nikkiso.ntss.core.entity.SysCoopNo;
import jp.co.nikkiso.ntss.core.entity.custom.MstCoopIniInfo;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainTreatDate;
import jp.co.nikkiso.ntss.core.entity.custom.PatGroupCustom;
import jp.co.nikkiso.ntss.core.entity.json.LayoutExtSetting;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogLevel;

import static jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants.AUX_CODE_PRELOGIC;
import static jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants.CRUD;
import static jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants.TABLE_MST_PERSONAL_USER;
import static jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants.TABLE_ORD_MAIN;
import static jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants.TABLE_PAT_PERSONAL_MAIN;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * JSON形式データをトランザクションテーブルに反映するサービスクラス。
 *
 * @see jp.co.nikkiso.ntss.coop_api.service.RegisterService
 */
@Service
public class RegisterServiceImpl implements RegisterService {

// del 2021-08-18 #5887:富士通連携設定の構築の対応 孫 start
{
//  // テーブルレコードのIDをどこから取得するかの定義
//  private static final String ID_PAT_PERSONAL_MAIN = "pat_personal_main.pat_id";
//  private static final String ID_MST_PERSONAL_USER = "mst_personal_user.user_id";
//  private static final Map<String, String> TABLE_ID_MAP;
//
//  static {
//    TABLE_ID_MAP = new HashMap<>();
//
//    TABLE_ID_MAP.put(TABLE_PAT_MAIN, ID_PAT_PERSONAL_MAIN);
//    TABLE_ID_MAP.put(TABLE_PAT_EXAM_MAIN, ID_PAT_PERSONAL_MAIN);
//    TABLE_ID_MAP.put(TABLE_PAT_UNIQUE, ID_PAT_PERSONAL_MAIN);
//    TABLE_ID_MAP.put(TABLE_PAT_COOP_DETAIL, ID_PAT_PERSONAL_MAIN);
//    TABLE_ID_MAP.put(TABLE_PAT_OBS_REC, ID_PAT_PERSONAL_MAIN);
//    TABLE_ID_MAP.put(TABLE_PAT_INSURANCE, ID_PAT_PERSONAL_MAIN);
//
//    TABLE_ID_MAP.put(TABLE_MST_USER_AUTHENTICATION, ID_MST_PERSONAL_USER);
//    TABLE_ID_MAP.put(TABLE_MST_USER, ID_MST_PERSONAL_USER);
//  }
//
//  // 患者情報連携対象テーブル（pat_personal_main以外）
//  // これらのテーブルのレコードが登録される時、pat_personal_main.pat_Idが採番済か判定する時に使用する。
//  private static final Set<String> PATIENT_TABLE_NAMES;
//
//  static {
//    PATIENT_TABLE_NAMES = new HashSet<>();
//    PATIENT_TABLE_NAMES.add(TABLE_PAT_MAIN);
//    PATIENT_TABLE_NAMES.add(TABLE_PAT_EXAM_MAIN);
//    PATIENT_TABLE_NAMES.add(TABLE_PAT_UNIQUE);
//    PATIENT_TABLE_NAMES.add(TABLE_PAT_COOP_DETAIL);
//    PATIENT_TABLE_NAMES.add(TABLE_PAT_OBS_REC);
//    PATIENT_TABLE_NAMES.add(TABLE_PAT_INSURANCE);
//    PATIENT_TABLE_NAMES.add(TABLE_ORD_MAIN);
//  }
//
//  // ユーザ情報連携対象テーブル（mst_personal_user以外）
//  // これらのテーブルのレコードが登録される時、mst_personal_user.user_Idが採番済か判定する時に使用する。
//  private static final Set<String> USER_TABLE_NAMES;
//
//  static {
//    USER_TABLE_NAMES = new HashSet<>();
//    USER_TABLE_NAMES.add(TABLE_MST_USER_AUTHENTICATION);
//    USER_TABLE_NAMES.add(TABLE_MST_USER);
//  }
}
// del 2021-08-18 #5887:富士通連携設定の構築の対応 孫 end

  // add 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 start
  private static final String ID_FACILITY_CD = "@facilityCd";
  private static final String ID_PAT_ID = "@patId";
  private static final String ID_USER_ID = "@userId";
  private static final String ID_ORD_NO = "@ordNo";
  private static final String ID_HOSP_PAT_ID = "@hospPatId";
  // add 2021-08-25 #5887:富士通連携設定の構築の対応 孫 start
  private static final String ID_CRUD = "@crud";
  // add 2021-08-25 #5887:富士通連携設定の構築の対応 孫 end
  // add 2021-11-12 #5896:SSI連携ができない(オーダ受け) 孫 start
  private static final String ID_TREAT_DATE = "@treatDate";
  // add 2021-11-12 #5896:SSI連携ができない(オーダ受け) 孫 end
// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  // 電子カルテ種別
  private static final String ID_KEY0 = "@key0";
  // 連携版番号
  private static final String ID_COOP_VERSION  = "@coopVersion";
  private static final String ID_CTL_NO  = "@ctlNo";
// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  private static final String EXAM_DETAIL_TABLE = "pat_exam_main";
  private static final String EXAM_DETAIL_ITEM_CD = "exam_result_info.item_cd";
  private static final String EXAM_DETAIL_RESULT = "exam_result_info.result";
  private static final String EXAM_LAYOUT_ITEM_CD_KEY = "$journal.detail.pat_exam_main.exam_result_info.item_cd";
  private static final String EXAM_ITEM_CD_COLUMN = "exam_item_cd";
  private static final String IN_HOSPITAL_CD1_COLUMN = "in_hospital_cd1";
  private static final String IN_HOSPITAL_CD2_COLUMN = "in_hospital_cd2";
  private static final String IN_HOSPITAL_CD3_COLUMN = "in_hospital_cd3";
  // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 del start
  //private Map<String, Object> idMap = new HashMap<>();
  // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 del end
// #8378-profile連携の患者登録処理でエラーが発生する 周 del start
//  private Map<String,Object> paraMap = new HashMap<>();
//  private Map<String, Object> resultJsonMap = new LinkedHashMap<>();
  // #8378-profile連携の患者登録処理でエラーが発生する 周 del end
  // add 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 end

  // add 2021-12-06 #5888:NEC連携ができない(スタッフマスタ連携) 孫 start
  // 暗号化項目の先頭
  private static final String ID_ENCRYP_TO = "@%%encrypto%%_";

  // パスワードエンコーダの先頭
  private static final String ID_PASSWORD_ENCODER = "@%%passwordencoder%%_";
  // add 2021-12-06 #5888:NEC連携ができない(スタッフマスタ連携) 孫 end

  // DAO群
  @Autowired
  private SysCoopJournalDao sysCoopJournalDao;

  @Autowired
  private ClockWrapper clockWrapper;

  @Autowired
  private PatPersonalMainDao patPersonalMainDao;

  @Autowired
  private PatMainDao patMainDao;

  @Autowired
  private PatExamMainDao patExamMainDao;

  @Autowired
  private PatObsRecDao patObsRecDao;

  @Autowired
  private PatUniqueDao patUniqueDao;

  @Autowired
  private PatCoopDetailDao patCoopDetailDao;

  @Autowired
  private PatInsuranceDao patInsuranceDao;

  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;

  @Autowired
  private MstUserAuthenticationDao mstUserAuthenticationDao;

  @Autowired
  private MstUserDao mstUserDao;

  @Autowired
  private OrdMainDao ordMainDao;

  @Autowired
  private OrdCoopNoDao ordCoopNoDao;

  // add 2021-01-19 No.739:新規マスタを含むオーダ受信時に該当するマスタを新規登録する機能の実装 商 start
  @Autowired
  private MstDialyzerDao mstDialyzerDao;

  @Autowired
  private MstEquipmentDao mstEquipmentDao;

  @Autowired
  private MstMedicineDao mstMedicineDao;

  @Autowired
  private MstSelectorDao mstSelectorDao;

  @Autowired
  private MstExamItemDao mstExamItemDao;

  @Autowired
  private MstCoopIniDao mstCoopIniDao;

  @Autowired
  private SysCoopNoDao sysCoopNoDao;
  // add 2021-01-19 No.739:新規マスタを含むオーダ受信時に該当するマスタを新規登録する機能の実装 商 end
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
  private MstInfectionDao mstInfectionDao;
  @Autowired
  private MstFacilityDao mstFacilityDao;
  @Autowired
  MstDialysisDifficultyDao mstDialysisDifficultyDao;
  @Autowired
  private MstFavoriteFacilityDao mstFavoriteFacilityDao;
  // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen end
  // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen Start
  @Autowired
  private SysFacilityDao sysFacilityDao;
  // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen end

  // add 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 start
  @Autowired
  private MstCoopLayoutDao mstCoopLayoutDao;

  @Autowired
  private SysDataSetDao sysDataSetDao;

  //add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 start
  @Value("${ntss.web-api.url}")
  private String webApi;
  //add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 end

  /**
   * データセット（個人情報DB）のDaoインタフェース.
   */
  @Autowired
  private SysDataSetPersonalDao sysDataSetPersonalDao;

  /**
   * データセット（認証DB）のDaoインタフェース.
   */
  @Autowired
  private SysDataSetAuthorityDao sysDataSetAuthorityDao;
  // add 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 end

  // add 2021-12-06 #5888:NEC連携ができない(スタッフマスタ連携) 孫 start
  /**
   * 個人情報DBのビットシフト暗号化関数のDaoインタフェース.
   */
  @Autowired
  private Db6FunctionDao db6FunctionDao;
  // add 2021-12-06 #5888:NEC連携ができない(スタッフマスタ連携) 孫 end

  // エンティティチェック・編集サービス群
  @Autowired
  private EntityLogic patPersonalMainLogic;

  @Autowired
  private EntityLogic patMainLogic;

  @Autowired
  private EntityLogic patExamMainLogic;

  @Autowired
  private EntityLogic patUniqueLogic;

  @Autowired
  private EntityLogic patObsRecLogic;

  @Autowired
  private EntityLogic patCoopDetailLogic;

  @Autowired
  private EntityLogic patInsuranceLogic;

  @Autowired
  private EntityLogic mstPersonalUserLogic;

  @Autowired
  private EntityLogic mstUserAuthenticationLogic;

  @Autowired
  private EntityLogic mstUserLogic;

  @Autowired
  private EntityLogic ordMainLogic;

  @Autowired
  private EntityLogic ordCoopNoLogic;

  @Autowired
  private LogService logService;

  // DB更新ログ出力ロジック wangzuo Start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Autowired
  private LogServiceCore logServiceCore;
  // DB更新ログ出力ロジック wangzuo End

  // add 2021-04-06 課題No.1:API連動設定:動作条件「処理完了時、処理エラー時、処理スキップ時」を追加 孫 start
  @Autowired
  private CallApiService callApiService;
  // add 2021-04-06 課題No.1:API連動設定:動作条件「処理完了時、処理エラー時、処理スキップ時」を追加 孫 end

  // add 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 start
  @Autowired
  private SysDataSetService sysDataSetService;

  @Autowired
  private ConvertCommonService convertCommonService;
  // add 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 end

  // add #7927 帳票に患者情報が出力されない場合がある 王永吉 start
  @Autowired
  private PatGroupDetailDao patGroupDetailDao;

  @Autowired(required = false)
  MongoTemplate mongoTemplate;
  // add #7927 帳票に患者情報が出力されない場合がある 王永吉 end
  // mod #7047 GX連携用sys_coop_noでcoop_ord_cdが重複するデータが存在する 2022-12-09 孟堅 start
  @Autowired
  MstCoopIniService mstCoopIniService;
  @Autowired
  OrdCoopNoService ordCoopNoService;
  // mod #7047 GX連携用sys_coop_noでcoop_ord_cdが重複するデータが存在する 2022-12-09 孟堅 end

  // #10453 add 死活監視が動作していない 2024-05-16 荘 start
  @Autowired
  HealthService healthService;
  // #10453 add 死活監視が動作していない 2024-05-16 荘 end

  //add #10901 #10902 mst_coop_apilinkの動作について 20241004 zhaoqi start
  @Value("${ntss.coop-api.header-name}")
  private String headerKey;
  @Value("${ntss.coop-api.header-value}")
  private String headerValue;
  /**
   * RestTemplate
   */
  private RestTemplate restTemplate;

  public RegisterServiceImpl() {
    HttpComponentsClientHttpRequestFactory clientHttpRequestFactory = new HttpComponentsClientHttpRequestFactory();
    clientHttpRequestFactory.setReadTimeout(0);
    clientHttpRequestFactory.setConnectTimeout(0);
    restTemplate = new RestTemplate(clientHttpRequestFactory);
  }

  @Autowired
  private OrdMainRestoreDao ordMainRestoreDao;

  @Autowired
  private MstCoopFacilityDao mstCoopFacilityDao;
  //add #10901 #10902 mst_coop_apilinkの動作について 20241004 zhaoqi end

  /**
   * JSON形式データをトランザクションテーブルに登録する。
   *
   * @param facilityCd 施設コード
   * @param direction  向き（送受信）
   * @param jsonList   JSON形式データ（複数テーブル分のリスト）
   * @see jp.co.nikkiso.ntss.coop_api.service.RegisterService#register(CreationDiv, java.lang.String, java.util.List)
   */
  @Override
  public void register(String facilityCd, String direction, List<ResultMap> jsonList,List<SysCoopJournal> journalList) {
    if (CollectionUtils.isEmpty(jsonList)) {
      return;
    }

    // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 del start
    // idMap.clear();
    // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 del end
    // #8378-profile連携の患者登録処理でエラーが発生する 周 del start
//    paraMap.clear();
//    resultJsonMap.clear();
    // #8378-profile連携の患者登録処理でエラーが発生する 周 del end

    for (ResultMap rm : jsonList) {
      // ジャーナルのJSON変換結果を、1件ずつDBに登録する。
      // 変換が完了した場合はジャーナルの変換状態を「完了」、
      // エラーが発生した場合は「システムエラー」に更新する。

      Long ctlNo = (Long) rm.getSpecial(JournalConvertConstants.KEY_JOURNAL_CTL_NO);
      rm.put(ResultKey.CTL_NO.getKey(), ctlNo);
      // add #5607 連動機能の実装確認 20230103 孟堅 start
      SysCoopJournal journal =journalList.stream().filter(el->el.getCtlNo()==ctlNo).findFirst().get();
      // add #5607 連動機能の実装確認 20230103 孟堅 start
      try {
        //mod #5607 連動機能の実装確認 20230103 孟堅 start
        //registerOne(facilityCd, rm);
        registerOne(facilityCd, rm,journal);
        //mod #5607 連動機能の実装確認 20230103 孟堅 end
        // del 6915 存在しない患者の検査結果取り込み時にエラーになる 吉 start
        // updateConvStatus(ctlNo, AnaResult.DONE);
        // del 6915 存在しない患者の検査結果取り込み時にエラーになる 吉 end
        // 更新結果を保持
        // #8750-検査結果の登録が行われない 周 mod start
        //rm.put(ResultKey.ANA_RESULT.getKey(), AnaResult.DONE.getResult());
        if(
            !(CoopCdConstant.EXAM_RST.equals(rm.get("%%coop_cd"))
              && null != rm.get(ResultKey.ANA_RESULT.getKey())
              && AnaResult.INTERNAL_ERROR.getResult().equals(rm.get(ResultKey.ANA_RESULT.getKey()).toString())
            )
            && !(null != rm.get(ResultKey.ANA_RESULT.getKey())
              && AnaResult.SKIP.getResult().equals(rm.get(ResultKey.ANA_RESULT.getKey()).toString()))
          ) {
          rm.put(ResultKey.ANA_RESULT.getKey(), AnaResult.DONE.getResult());
        }
        // #8750-検査結果の登録が行われない 周 mod end
        // del 6915 存在しない患者の検査結果取り込み時にエラーになる 吉 start
        // rm.put(ResultKey.MESSAGE.getKey(), "");
        // del 6915 存在しない患者の検査結果取り込み時にエラーになる 吉 end
        // add 6915 存在しない患者の検査結果取り込み時にエラーになる 吉 start
        if("exam_rst".equals(rm.get("%%coop_cd"))){
          // #8750-検査結果の登録が行われない 周 mod start
          //updateAnaResult(ctlNo, null != rm.get("message") ?rm.get("message").toString() : "", AnaResult.DONE);
          AnaResult anaResult =
            AnaResult.INTERNAL_ERROR.getResult().equals(rm.get(ResultKey.ANA_RESULT.getKey()).toString())
              ? AnaResult.INTERNAL_ERROR : AnaResult.DONE;
          updateAnaResult(ctlNo, null != rm.get("message") ?rm.get("message").toString() : "", anaResult);
          // #8750-検査結果の登録が行われない 周 mod end
          // add #9385 NKK連携 profile（XML） 未登録患者の死亡データを受信すると患者登録されないが稼働ビューアでは処理完了となっている 孟堅　20230915　　start
        }else if (CoopCdConstant.PROFILE.equals(rm.get("%%coop_cd"))
                  &&  AnaResult.DONE.getResult().equals(rm.get(ResultKey.ANA_RESULT.getKey()).toString())
                  &&  0 == journal.getPatId()){
          updateAnaResult(ctlNo,"未登録の死亡患者情報を受信しました",AnaResult.SKIP);
          // add #9385 NKK連携 profile（XML） 未登録患者の死亡データを受信すると患者登録されないが稼働ビューアでは処理完了となっている 孟堅　20230915　　　end
        } else if (AnaResult.SKIP.getResult().equals(rm.get(ResultKey.ANA_RESULT.getKey()).toString())) {
          updateAnaResult(ctlNo, rm.get(ResultKey.MESSAGE.getKey()).toString(),AnaResult.SKIP);
        }
        else{
          updateConvStatus(ctlNo, AnaResult.DONE);
          rm.put(ResultKey.MESSAGE.getKey(), "");
        }
        // add 6915 存在しない患者の検査結果取り込み時にエラーになる 吉 end
      } catch (Exception e) {
        outputErrorLog(facilityCd, "トランザクションテーブル登録でエラーが発生しました。施設コード:[" + facilityCd + "] 内容:[" + e.getMessage() + "]");
        String message = String.format("トランザクションテーブル登録でエラーが発生しました。施設コード:[%s] 内容:[%s]", facilityCd, e.getMessage());
// add 2021-11-03 #5904:日機装連携ができない(患者プロファイル) 孫 start
        StackTraceElement[]  list = null;
        String errAdd = "";
        if (e.getCause() != null && e.getCause().getStackTrace() != null
          && e.getCause().getStackTrace().length > 0) {
          list = e.getCause().getStackTrace();
          for (StackTraceElement err : list) {
            if (err != null && err.toString().startsWith("jp.co.")) {
              errAdd = errAdd + "\r\n" + err.toString();
            }
          }
        }
        if (StringUtils.isEmpty(errAdd)) {
          list = e.getStackTrace();
          for (StackTraceElement err : list) {
            if (err != null && err.toString().startsWith("jp.co.")) {
              errAdd = errAdd + "\r\n" + err.toString();
            }
          }
        }
        message = message + errAdd;
// add 2021-11-03 #5904:日機装連携ができない(患者プロファイル) 孫 end
        updateAnaResult(ctlNo, message, AnaResult.INTERNAL_ERROR);

        // #10453 add 死活監視が動作していない 2024-05-16 荘 start
        healthService.update(journal, AnaResult.INTERNAL_ERROR.getResult());
        // #10453 add 死活監視が動作していない 2024-05-16 荘 end

        // 更新結果を保持
        rm.put(ResultKey.ANA_RESULT.getKey(), AnaResult.INTERNAL_ERROR.getResult());
        rm.put(ResultKey.MESSAGE.getKey(), message);
      }
    }
  }

  //mod #10901 死亡患者受信時処理について zrx start
  /**
   *
   * @param facilityCd     施設コード
   * @param journalCreteList journallist
   * @throws Exception
   */
  @Override
  public void deathRelatedBusiness(String facilityCd, List<JournalCreateRequestPayload> journalCreteList) throws Exception {
    long startTime = System.currentTimeMillis();
    URI uri;
    StringBuilder builder = new StringBuilder("http://localhost:8080/ntss-coop-api/journal/createList");
    try {
      uri = new URI(builder.toString());
    } catch (URISyntaxException use) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setFacilityCd(facilityCd);
      eventLogMessage.setLogMessage("連携API関連付けURLの生成に失敗しました。url:[" + builder + "]");
      eventLogMessage.setInvokeClass(this.getClass().getName());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      throw new NtssException(eventLogMessage.getLogMessage());
    }
    // ヘッダ作成
    HttpHeaders headers = new HttpHeaders();
    headers.setContentType(MediaType.APPLICATION_JSON_UTF8);
    headers.set(headerKey, headerValue);
    EventLogMessage eventLogMessage = new EventLogMessage();

    List<JournalCreateRequest> journalCreateRequestList = new ArrayList<>();
    for(JournalCreateRequestPayload create : journalCreteList){
      JournalCreateRequest target = new JournalCreateRequest();
      BeanUtils.copyProperties(create, target);
      journalCreateRequestList.add(target);
    }

    JSONArray apiJsonArray = new JSONArray(journalCreateRequestList);
    try {
      RequestEntity<?> req = new RequestEntity<>(journalCreateRequestList, headers, HttpMethod.POST, uri);
	  // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
      long start = System.currentTimeMillis();
      ResponseEntity<?> response = restTemplate.exchange(req, String.class);
      long cost = System.currentTimeMillis() - start;
      Map<String, Object> map = new HashMap<>();
      map.put("logType", "RESTTEMPLATE-LOG");
      map.put("className", "jp.co.nikkiso.ntss.coop_api.service.RegisterServiceImpl");
      map.put("methodName", "deathRelatedBusiness");
      map.put("method", req.getMethod());
      map.put("url", req.getUrl());
      map.put("headers", req.getHeaders().toSingleValueMap());
      map.put("requestParameter", req.getBody());
      map.put("status",response.getStatusCode());
      map.put("cost", cost);
      map.put("result",response.getBody());
      EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
      restTemplateEventLogMessage.setLogMessage(toJson(map));
      restTemplateEventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
      eventLogMessage.setFacilityCd(facilityCd);
      eventLogMessage.setLogMessage("連携API関連付け呼び出し結果:" + response);
      eventLogMessage.setInvokeClass(this.getClass().getName());
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // 処理後続行可否
      boolean result = response.getStatusCode().value() == 200;
	  // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
      if (!result) {
        eventLogMessage.setLogMessage("$$$$$$callApiJournal 1.4 " + (System.currentTimeMillis() - startTime));
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      }
    } catch (Exception ex) {
      eventLogMessage.setLogMessage("連携API関連付けの呼び出しに失敗しました。"
        + " api_uri:[" + builder + "]"
        + " api_method:[" + HttpMethod.POST + "]"
        + " api_body:[" + apiJsonArray + "]"
        + " Message:[" + ex.getMessage() + "]");
      eventLogMessage.setInvokeClass(this.getClass().getName());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      throw new NtssException(eventLogMessage.getLogMessage());
    }
  }

//  //add #10901 #10902 mst_coop_apilinkの動作について 20241004 zhaoqi start
//
//  /**
//   * 生存情報(死亡)を受信後の関連処理
//   *
//   * @param facilityCd     施設コード
//   * @param scForCheckList 生存情報(死亡)list
//   * @throws Exception
//   */
//  @Override
//  public void deathRelatedBusiness(String facilityCd, List<SysCoopJournalExtends> scForCheckList) throws Exception {
//    long startTime = System.currentTimeMillis();
//    URI uri;
//    StringBuilder builder = new StringBuilder("http://localhost:8080/ntss-coop-api/journal/createList");
//    try {
//      uri = new URI(builder.toString());
//    } catch (URISyntaxException use) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setFacilityCd(facilityCd);
//      eventLogMessage.setLogMessage("連携API関連付けURLの生成に失敗しました。url:[" + builder + "]");
//      eventLogMessage.setInvokeClass(this.getClass().getName());
//      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
//      throw new NtssException(eventLogMessage.getLogMessage());
//    }
//    // ヘッダ作成
//    HttpHeaders headers = new HttpHeaders();
//    headers.setContentType(MediaType.APPLICATION_JSON_UTF8);
//    headers.set(headerKey, headerValue);
//    EventLogMessage eventLogMessage = new EventLogMessage();
//    List<MstCoopFacility.CoopOrdCd> coopOrdCds = new ArrayList<>();
//    MstCoopFacility mstCoopFacility = mstCoopFacilityDao.select(facilityCd);
//    if(mstCoopFacility != null){
//      MstCoopFacility.CommonSetting commonSetting = mstCoopFacility.getCommonSetting();
//      if(commonSetting != null){
//        coopOrdCds = commonSetting.getCoopOrdCds();
//      }
//    }
//
//    List<Long> ordNoList = new ArrayList<>();
//    for (SysCoopJournalExtends se : scForCheckList) {
//      if ("ord_main".equals(se.getTableName())) {
//        Long ordNo = se.getOrdNo();
//        ordNoList.add(ordNo);
//      }
//    }
//    List<OrdMainRestore> ordMainRestoreList = ordMainRestoreDao.selectListByOrdNo(ordNoList);
//
//    List<JournalCreateRequest> journalCreateRequestList = new ArrayList<>();
//
//    for (SysCoopJournalExtends se : scForCheckList) {
//      Long ordNo = se.getOrdNo();
//      String opeCd = "";
//      switch (se.getCoopCd()) {
//        case CoopCdConstant.IND_DIAL:
//          Optional<OrdMainRestore> checkHasKur = ordMainRestoreList.stream()
//            .filter(orm -> Objects.compare(orm.getOrdNo(), ordNo, Long::compareTo) == 0)
//            .findFirst();
//          if (checkHasKur.isPresent()) {
//            opeCd = "031002";
//            Integer indKurCd = checkHasKur.get().getIndKurCd();
//            if (indKurCd != null && indKurCd == 0) {
//              opeCd = "031007";
//            }
//          }
//          break;
//        case CoopCdConstant.EXAM_ORD:
//          opeCd = "031003";
//          break;
//        case CoopCdConstant.RAD_ORD:
//          opeCd = "031004";
//          break;
//        case CoopCdConstant.PHY_ORD:
//          opeCd = "031013";
//          break;
//      }
//      JournalCreateRequest journalCreateRequest = getString(opeCd, se, coopOrdCds);
//      if (!journalCreateRequestList.contains(journalCreateRequest)) {
//        journalCreateRequestList.add(journalCreateRequest);
//      }
//    }
//    JSONArray apiJsonArray = new JSONArray(journalCreateRequestList);
//    try {
//      RequestEntity<?> req = new RequestEntity<>(journalCreateRequestList, headers, HttpMethod.POST, uri);
//      ResponseEntity<?> res = restTemplate.exchange(req, String.class);
//      eventLogMessage.setFacilityCd(facilityCd);
//      eventLogMessage.setLogMessage("連携API関連付け呼び出し結果:" + res);
//      eventLogMessage.setInvokeClass(this.getClass().getName());
//      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
//      // 処理後続行可否
//      boolean result = res.getStatusCode().value() == 200;
//      if (!result) {
//        eventLogMessage.setLogMessage("$$$$$$callApiJournal 1.4 " + (System.currentTimeMillis() - startTime));
//        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
//      }
//    } catch (Exception ex) {
//      eventLogMessage.setLogMessage("連携API関連付けの呼び出しに失敗しました。"
//        + " api_uri:[" + builder + "]"
//        + " api_method:[" + HttpMethod.POST + "]"
//        + " api_body:[" + apiJsonArray + "]"
//        + " Message:[" + ex.getMessage() + "]");
//      eventLogMessage.setInvokeClass(this.getClass().getName());
//      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
//      throw new NtssException(eventLogMessage.getLogMessage());
//    }
//  }
//
//  /**
//   * @param opeCd
//   * @param se
//   * @return
//   */
//  private JournalCreateRequest getString(String opeCd, SysCoopJournalExtends se, List<MstCoopFacility.CoopOrdCd> coopOrdCds) {
//    JournalCreateRequest apiJson = new JournalCreateRequest();
//    apiJson.setCrud(CoopCdConstant.CRUD_DELETE);
//    apiJson.setOpeCd(opeCd);
//    apiJson.setPatId(se.getPatId());
//    apiJson.setCoopCd(se.getCoopCd());
//    apiJson.setUserId(se.getUserId());
//    apiJson.setFacilityCd(se.getFacilityCd());
//    String hospPatId = "";
//    PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(se.getPatId());
//    if (patPersonalMain != null) {
//      hospPatId = patPersonalMain.getHosp_pat_id();
//    }
//    apiJson.setHospPatId(hospPatId);
//    apiJson.setOrdNo(se.getOrdNo());
//    apiJson.setBaseDate(se.getBaseDate());
//    apiJson.setRegOrderClass(se.getRegOrderClass());
//    String coopVersion = "";
//    Optional<MstCoopFacility.CoopOrdCd> checkHasKur = coopOrdCds.stream()
//      .filter(coc -> se.getCoopCd().equals(coc.getCoopCd()))
//      .findFirst();
//    if (checkHasKur.isPresent()) {
//      coopVersion = checkHasKur.get().getCoopVersion();
//    }
//    apiJson.setCoopVersion(coopVersion);
//
//    return apiJson;
//  }
//  //add #10901 #10902 mst_coop_apilinkの動作について 20241004 zhaoqi end
  //mod #10901 死亡患者受信時処理について zrx end

  /**
   * JSON形式データ1件をトランザクションテーブルに登録する。
   *
   * @param facilityCd 施設コード
   * @param rm         JSON形式データ（リストのうちの1要素分）
   */
  //mod #5607 連動機能の実装確認 20230103 孟堅 start
  //public void registerOne(String facilityCd, ResultMap rm) {
  public void registerOne(String facilityCd, ResultMap rm,SysCoopJournal sysCoopJournalData) {
  //mod #5607 連動機能の実装確認 20230103 孟堅 end
    if (rm.isEmpty()) {
      return;
    }

    // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 add start
    Map<String, Object> idMap = new HashMap<>();
    // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 add end
    // #8378-profile連携の患者登録処理でエラーが発生する 周 add start
    Map<String,Object> paraMap = new HashMap<>();
    Map<String, Object> resultJsonMap = new LinkedHashMap<>();
    // #8378-profile連携の患者登録処理でエラーが発生する 周 add end

    // add 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 start
    idMap.put(ID_FACILITY_CD,facilityCd);
    idMap.put(ID_PAT_ID,null);
    idMap.put(ID_ORD_NO,null);
    // add 2021-08-26 「受信時、ord_coop_noに２つデータを追加するの問題」の対応 孫 start
    idMap.put(ID_HOSP_PAT_ID,null);
    idMap.put(ID_CRUD,null);
    // add 2021-08-26 「受信時、ord_coop_noに２つデータを追加するの問題」の対応 孫 end
    // add 2021-11-12 #5896:SSI連携ができない(オーダ受け) 孫 start
    idMap.put(ID_TREAT_DATE,null);
    // add 2021-11-12 #5896:SSI連携ができない(オーダ受け) 孫 end
// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    idMap.put(ID_KEY0,null);
    idMap.put(ID_COOP_VERSION,null);
// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    // 対象ジャーナルを取得する
    idMap.put(ID_CTL_NO,rm.getSpecial(JournalConvertConstants.KEY_JOURNAL_CTL_NO));
    SysCoopJournal journal = sysCoopJournalDao.selectByPK((Long)rm.getSpecial(JournalConvertConstants.KEY_JOURNAL_CTL_NO));
    String tempContent = journal.getTempContent();
// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    String journalKey0 = normalizeCoopKey0(journal.getKey0());
    idMap.put(ID_KEY0, journalKey0);
    String coopVersion = StringUtils.isEmpty(journal.getCoopVersion())?"":journal.getCoopVersion();
    idMap.put(ID_COOP_VERSION, coopVersion);
// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
// mod 2021-10-26 #5890:Medicom連携ができない(複数電文) 孫 start
//    JSONObject jsonObj = new JSONObject(tempContent);
    // 複数電文
    JSONArray tempContentList = new JSONArray(tempContent);
    int tempContentCnt = tempContentList.length();
    // add 6915 存在しない患者の検査結果取り込み時にエラーになる 吉 start
    boolean examRstFlag = false;
    Map<String,String> examRstMap = new HashMap<>();
    // add 7029 exam_rst連携で受信した検査データのマージが行われない 20220809 zhaoqi start
    if(rm.get("patplurallist") != null){
    // add 7029 exam_rst連携で受信した検査データのマージが行われない 20220809 zhaoqi end
      if("exam_rst".equals(rm.get("%%coop_cd")) && ((List)rm.get("patplurallist")).size()!=tempContentCnt){
        List<Object> list =(List)rm.get("patplurallist");
        for(Object ob : list){
          examRstMap.put(ob.toString(),ob.toString());
        }
        examRstFlag = true;
      }
    // add 7029 exam_rst連携で受信した検査データのマージが行われない 20220809 zhaoqi start
    }
    // add 7029 exam_rst連携で受信した検査データのマージが行われない 20220809 zhaoqi end
    // add 6915 存在しない患者の検査結果取り込み時にエラーになる 吉 end
    for (int index = 0; index < tempContentCnt; index++) {
      JSONObject jsonObj = tempContentList.getJSONObject(index);
// mod 2021-10-26 #5890:Medicom連携ができない(複数電文) 孫 end
      Map<String, Object> jsonMap = new LinkedHashMap<>();
      convertJsonToMap(jsonObj, jsonMap);
      // add 6915 存在しない患者の検査結果取り込み時にエラーになる 吉 start
      if(examRstFlag){
        if (jsonMap.containsKey(TABLE_PAT_PERSONAL_MAIN)) {
          Object ppmObj = jsonMap.get(TABLE_PAT_PERSONAL_MAIN);
          if (ppmObj instanceof JSONObject) {
            JSONObject jsonObject = ((JSONObject) ppmObj);
            String hospPatId = (String) jsonObject.get("hosp_pat_id");
            if (!examRstMap.containsKey(hospPatId)) {
              continue;
            }
          }
        }
      }
      // mod 7391 exam_rst連携で受信した検査項目コード  吉 start
//      if("exam_rst".equals(rm.get("%%coop_cd"))){
//        JSONObject json = tempContentList.getJSONObject(index);
//        Map<String, Object> LsMap = new LinkedHashMap<>();
//        if (json instanceof JSONObject) {
//          JSONObject detailJson = (JSONObject) json.get("detail");
//          JSONArray examObject = (JSONArray)detailJson.get("pat_exam_main");
//          convertJsonToMap(examObject.get(0), LsMap);
//        }
//        if (LsMap.containsKey("exam_result_info.item_cd") && "".equals(LsMap.get("exam_result_info.item_cd"))) {
//          continue;
//        }
//      }
      if("exam_rst".equals(rm.get("%%coop_cd"))){
        Object detail = jsonMap.get("detail");
        if(detail instanceof JSONObject){
          JSONObject detailJson = (JSONObject) detail;
          JSONArray examObject = (JSONArray)detailJson.get("pat_exam_main");
          for(int i = examObject.length(); i>0 ; i--){
            Map<String, Object> LsMap = convertJsonToMapIsNotNull(examObject.get(i-1));
            if(null == LsMap || LsMap.size() == 0){
              examObject.remove(i-1);
            }
          }
        }
      }
      // mod 7391 exam_rst連携で受信した検査項目コード  吉 end
      // add 6915 存在しない患者の検査結果取り込み時にエラーになる 吉 end
      // add 2021-08-25 #5887:富士通連携設定の構築の対応 孫 start
      // 電文から処理区分(ＣＲＵＤ)が有りか
      String constCrud = "";
      if (jsonMap.containsKey("const")) {
        Object ppmObj = jsonMap.get("const");
        if (ppmObj instanceof JSONObject) {
          JSONObject jsonObject = ((JSONObject) ppmObj);
          if (jsonObject.keySet().contains("crud")
            && !StringUtils.isEmpty(jsonObject.get("crud"))) {
            constCrud = String.valueOf(jsonObject.get("crud"));
          }
        }
      }
      if (StringUtils.isEmpty(constCrud)) {
        throw new NtssException("電文から処理区分(ＣＵＤ)を設定しません、または、設定内容が無し。");
// add 2021-11-26 #5888:NEC連携ができない(初回指示連携) 孫 start
      } else if ("Z".equals(constCrud)) {
        // 処理区分が[Z：中止]の場合、データ更新を行わず、「正常」応答電文を送信します。
        continue;
// add 2021-11-26 #5888:NEC連携ができない(初回指示連携) 孫 end
      } else if (!"C".equals(constCrud) && !"U".equals(constCrud) && !"D".equals(constCrud)) {
        throw new NtssException("電文から処理区分(ＣＵＤ)の設定不正。[C、U、D]以外の内容を設定しました。");
      } else {
        idMap.put(ID_CRUD, constCrud);
      }
      // add 2021-08-25 #5887:富士通連携設定の構築の対応 孫 end

      // add 2021-08-25 idMapにをID_HOSP_PAT_ID追加する 孫 start
      // idMapにをID_HOSP_PAT_ID追加する
      if (jsonMap.containsKey(TABLE_PAT_PERSONAL_MAIN)) {
        Object ppmObj = jsonMap.get(TABLE_PAT_PERSONAL_MAIN);
        if (ppmObj instanceof JSONObject) {
          JSONObject jsonObject = ((JSONObject) ppmObj);
          if (jsonObject.keySet().contains("hosp_pat_id")
            && !StringUtils.isEmpty(jsonObject.get("hosp_pat_id"))) {
// mod 2021-12-16 #5888:NEC-iS連携ができない(患者プロファイル(profile)の受信部分) 孫 start
//            idMap.put(ID_HOSP_PAT_ID, String.valueOf(jsonObject.get("hosp_pat_id")));
            // mod #8111 コンバートデータの患者の過去のrep_dial連携の内容が出力されない 王永吉 end
//            // 患者番号（連携用）の先頭の0を削除
//            idMap.put(ID_HOSP_PAT_ID, String.valueOf(jsonObject.get("hosp_pat_id")).replaceFirst("^0*", ""));
            idMap.put(ID_HOSP_PAT_ID, jsonObject.get("hosp_pat_id"));
            // mod #8111 コンバートデータの患者の過去のrep_dial連携の内容が出力されない 王永吉 end
// mod 2021-12-16 #5888:NEC-iS連携ができない(患者プロファイル(profile)の受信部分) 孫 end
          }
        }
      }
      // add 2021-08-25 idMapにをID_HOSP_PAT_ID追加する 孫 end

      // add 2021-11-12 #5896:SSI連携ができない(オーダ受け) 孫 start
      // idMapにをID_TREAT_DATE追加する
      if (jsonMap.containsKey("ord_main")) {
        Object ppmObj = jsonMap.get("ord_main");
        if (ppmObj instanceof JSONObject) {
          JSONObject jsonObject = ((JSONObject) ppmObj);
          if (jsonObject.keySet().contains("treat_date")
            && !StringUtils.isEmpty(jsonObject.get("treat_date"))) {
            idMap.put(ID_TREAT_DATE, String.valueOf(jsonObject.get("treat_date")));
          }
        }
      }
      // add 2021-11-12 #5896:SSI連携ができない(オーダ受け) 孫 end
      // ジャーナルから変換したいレイアウトを取得する
// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 start
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
////      MstCoopLayout mcl = mstCoopLayoutDao.selectAllByCoopCdSub(facilityCd, (String) rm.getSpecial(JournalConvertConstants.COOP_CD), (String) rm.getSpecial(JournalConvertConstants.COOP_CD_INDEX), (String) rm.getSpecial(JournalConvertConstants.DIRECTION), AUX_CODE_PRELOGIC);
//      MstCoopLayout mcl = mstCoopLayoutDao.selectAllByCoopCdSub(facilityCd,
//        (String) rm.getSpecial(JournalConvertConstants.COOP_CD),
//        (String) rm.getSpecial(JournalConvertConstants.COOP_CD_INDEX),
//        coopVersion,
//        (String) rm.getSpecial(JournalConvertConstants.DIRECTION), AUX_CODE_PRELOGIC);
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
        String coopCd = (String) rm.getSpecial(JournalConvertConstants.COOP_CD);
        String coopCdIndex = (String) rm.getSpecial(JournalConvertConstants.COOP_CD_INDEX);
        String direction = (String) rm.getSpecial(JournalConvertConstants.DIRECTION);
        List<MstCoopLayout> mclList = mstCoopLayoutDao.selectAllByCoopCdSub(facilityCd, coopCd, coopCdIndex,
          coopVersion, direction, AUX_CODE_PRELOGIC);
      if (mclList == null || mclList.size() == 0) {
        String errMsg = String.format("対象レイアウトファイルが存在しません。施設コード:[%s], 連携版番号:[%s], 送受信向き:[%s], 電文種別:[%s], 電文付帯情報:[%s], 電文種別補足コード:[%s,all]",
          facilityCd, coopVersion, direction, coopCd, coopCdIndex, AUX_CODE_PRELOGIC);
        outputErrorLog(facilityCd, errMsg);
        throw new NtssException(errMsg);
      } else if (mclList.size() > 1) {
        MstCoopLayout mcl0 = mclList.get(0);
        MstCoopLayout mcl1 = mclList.get(1);
        String coopCdSub0 = mcl0.getCoopCdSub();
        String coopCdSub1 = mcl1.getCoopCdSub();
        if (coopCdSub0.equals(coopCdSub1)) {
          String errMsg = String.format("対象レイアウトファイルが複数存在します。施設コード:[%s], 連携版番号:[%s], 送受信向き:[%s], 電文種別:[%s], 電文付帯情報:[%s], 電文種別補足コード:[%s]",
            facilityCd, coopVersion, direction, coopCd, coopCdIndex, coopCdSub0);
          outputErrorLog(facilityCd, errMsg);
          throw new NtssException(errMsg);
        }
      }
      MstCoopLayout mcl = mclList.get(0);
// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 end

      LayoutExtSetting layoutExtSetting = mcl.getCoopExtSetting();

      if (MapUtils.isEmpty(layoutExtSetting)) {
        String errMsg = "レイアウト拡張設定が設定されていません。";
        outputErrorLog(facilityCd, errMsg);
        throw new NtssException(errMsg);
      }

      Map<String, Object> groupMap = ObjectMapperUtil.castToStringObjectMap(layoutExtSetting.get("dataset"));
      if (MapUtils.isEmpty(groupMap)) {
        String errMsg = String.format("レイアウト拡張設定で%sが設定されていません。", "dataset");
        outputErrorLog(facilityCd, errMsg);
        throw new NtssException(errMsg);
      }
      if (CoopCdConstant.EXAM_RST.equals(rm.get("%%coop_cd")) && !"D".equals(idMap.get(ID_CRUD))
        && !filterRegisterableExamResultInfo(facilityCd, journalKey0, jsonMap, layoutExtSetting)) {
        continue;
      }
      // #8378-profile連携の患者登録処理でエラーが発生する 周 del start
//      paraMap.clear();
      // #8378-profile連携の患者登録処理でエラーが発生する 周 del end
      for (int i = 1; i <= groupMap.size(); i++) {
        String groupKey = "sqlGroup" + i;
        Object obj = groupMap.get(groupKey);
        if (obj instanceof List) {
          List<Object> list = ObjectMapperUtil.castToObjectList(obj);
          String kbn = "0"; // insert: "2"  update: "3" json-listのupdate: "9"
          boolean isDetail = false;
          isDetail = isDetail(list);
          int colCount = 1;
          if (isDetail == true) {
            colCount = getDetailCount(list, jsonMap);
          }
          // add 2021-08-18 #5887:富士通連携設定の構築の対応 孫 start
          // 追加(C)、または、修正(U)の場合、検索(S)が有りか
          boolean insert_update_Exists = false;
          boolean seelctExists = false;
          for (Object obj1 : list) {
            Map<String, Object> m1 = ObjectMapperUtil.castToStringObjectMap(obj1);
            String crud = String.valueOf(m1.get("crud"));
            if (!StringUtils.isEmpty(crud) && "S".equals(crud)) {
              seelctExists = true;
            } else if (!StringUtils.isEmpty(crud) && ("C".equals(crud) || "U".equals(crud))) {
              insert_update_Exists = true;
            }
          }
          if (insert_update_Exists == true && seelctExists == false) {
            String errMsg = String.format("レイアウト拡張設定で%s->%sの設定不正。crudがCまたはUの設定がありの場合、Sの設定が無し。", "dataset", groupKey);
            throw new NtssException(errMsg);
          }
          // add 2021-08-18 #5887:富士通連携設定の構築の対応 孫 end
          for (int j = 0; j < colCount; j++) {
            // 検索
            for (Object obj1 : list) {
              if (obj1 instanceof Map) {
                Map<String, Object> m1 = ObjectMapperUtil.castToStringObjectMap(obj1);
                String crud = String.valueOf(m1.get("crud"));
                if ("S".equals(crud)) {
                  Long sqlCode = Long.valueOf(m1.get("sqlCode").toString());
                  Map<String, Object> dataKey = new HashMap<>();
                  boolean flg = false;
                  String type = String.valueOf(m1.get("type"));
                  resultJsonMap.clear();
                  if (isDetail == false) {
                    // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod start
                    //dataKey = getDataKey(m1, jsonMap);
                    // #8378-profile連携の患者登録処理でエラーが発生する 周 mod start
                    //dataKey = getDataKey(m1, jsonMap, idMap);
                    dataKey = getDataKey(m1, jsonMap, idMap, paraMap, resultJsonMap);
                    // #8378-profile連携の患者登録処理でエラーが発生する 周 mod end
                    // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod end
                    flg = isExecute(m1, jsonMap);
                  } else {
                    // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod start
                    //dataKey = getDetailDataKey(m1, jsonMap, j, false);
                    // #8378-profile連携の患者登録処理でエラーが発生する 周 mod start
                    //dataKey = getDetailDataKey(m1, jsonMap, j, false, idMap);
                    dataKey = getDetailDataKey(m1, jsonMap, j, false, idMap, paraMap, resultJsonMap);
                    // #8378-profile連携の患者登録処理でエラーが発生する 周 mod end
                    // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod end
                    if (dataKey == null) {
                      flg = false;
                    } else {
                      flg = isDetailExecute(m1, jsonMap, j);
                    }
                  }
                  if (flg == true) {
                    List<Map<String, Object>> reportInfo;
                    reportInfo = sysDataSetService.getDataListContainsError(sqlCode, dataKey, null);
                    if (reportInfo != null && reportInfo.size() == 1) {
                      Map<String, Object> map = reportInfo.get(0);
                      if (map.containsKey("error")) {
                        String errMsg = "DB操作に失敗しました。sqlCd:" + sqlCode + " msg:" + map.get("error");
                        outputErrorLog(facilityCd, errMsg);
                        throw new NtssException(errMsg);
                      }
                    }
                    // add 2021-08-18 #5887:富士通連携設定の構築の対応 孫 start
                    // ExceptionConditionとExceptionMessageを取得する
                    if (m1.get("ExceptionCondition") != null) {
                      String exceptionCondition = m1.get("ExceptionCondition").toString();
                      if (!"=0".equals(exceptionCondition) && !"<>0".equals(exceptionCondition) && !"!=0".equals(exceptionCondition)
                        && !"=1".equals(exceptionCondition) && !"<>1".equals(exceptionCondition) && !"!=1".equals(exceptionCondition)
                        && !"=N".equals(exceptionCondition) && !"<>N".equals(exceptionCondition) && !"!=N".equals(exceptionCondition)) {
                        throw new NtssException("datasetの" + groupKey + "のExceptionConditionの内容不正。[=0、=1、=N、<>0、<>1、<>N]以外の内容を設定しました。");
                      }

                      String exceptionMessage = "DB操作に失敗しました。sqlCd:" + sqlCode + ",ExceptionCondition:" + exceptionCondition;
                      if (m1.get("ExceptionMessage") != null) {
                        exceptionMessage = m1.get("ExceptionMessage").toString();
                        for (String key : dataKey.keySet()) {
                          if (exceptionMessage.contains(key)) {
                            String keyValue = "";
                            if (dataKey.get(key) != null) {
                              keyValue = dataKey.get(key).toString();
                            }
                            exceptionMessage = exceptionMessage.replace(key, keyValue);
                          }
                        }
                      }
                      if (!StringUtils.isEmpty(exceptionCondition)) {
                        Boolean exceptionFlag = false;
                        int dataCnt = (reportInfo != null) ? reportInfo.size() : 0;
                        if ("=0".equals(exceptionCondition) && dataCnt == 0) {
                          // データが0件
                          exceptionFlag = true;
                        } else if ("=1".equals(exceptionCondition) && dataCnt == 1) {
                          // データが1件
                          exceptionFlag = true;
                        } else if ("=N".equals(exceptionCondition) && dataCnt > 1) {
                          // データがN件
                          exceptionFlag = true;
                        } else if (("<>0".equals(exceptionCondition) || "!=0".equals(exceptionCondition)) && dataCnt != 0) {
                          // データが0件以外
                          exceptionFlag = true;
                        } else if (("<>1".equals(exceptionCondition) || "!=1".equals(exceptionCondition)) && dataCnt != 1) {
                          // データが1件以外
                          exceptionFlag = true;
                        } else if (("<>N".equals(exceptionCondition) || "!=N".equals(exceptionCondition)) && dataCnt <= 1) {
                          // データがN件以外
                          exceptionFlag = true;
                        }
                        if (exceptionFlag) {
                          // mod 2021-12-02 #5888:NEC連携ができない(処方情報連携) 孫 start
//                          throw new NtssException(exceptionMessage.replace("@dataCnt", String.valueOf(dataCnt)));
                          // 正常終了(異常しません）
                          if ("NORMALEND".equals(exceptionMessage)) {
                            return;
                          } else if (exceptionMessage.startsWith("SKIPEND")) {
                            String message = exceptionMessage.replace("SKIPEND", "");
                            rm.put(ResultKey.MESSAGE.getKey(), message.trim());
                            rm.put(ResultKey.ANA_RESULT.getKey(), AnaResult.SKIP.getResult());
                            return;
                          }else {
                            throw new NtssException(exceptionMessage.replace("@dataCnt", String.valueOf(dataCnt)));
                          }
                          // mod 2021-12-02 #5888:NEC連携ができない(処方情報連携) 孫 end
                        }
                      }
                    }
                    // add 2021-08-18 #5887:富士通連携設定の構築の対応 孫 end
                    if ("json".equals(type)) {
                      if (reportInfo.size() > 0) {
                        kbn = "9";
                      }
                    } else {
                      if (reportInfo.size() == 0) {
                        // 同一連携患者番号(pat_personal_main.hosp_pat_id)が存在しないの場合、新規
                        kbn = "2";
                      } else {
                        // 同一連携患者番号(pat_personal_main.hosp_pat_id)が存在するの場合、更新
                        kbn = "3";
                      }
                    }
// del 2022-03-10 #7064:GX連携 連携対象患者の判断をini_dialで判断していない 孫 start
                    // ★★★受信前、画面がデータを作成しましたが有り、ここで検証処理を削除します。
//                    // add 2021-08-25 #5887:富士通連携設定の構築の対応 孫 start
//                    // datasetの第一グループの設定内容は患者個人情報テーブル(pat_personal_main)の場合、
//                    // 「同一連携患者番号が存在する、種別が「ini_dial」「profile」のレコードが存在する」のチェックを実施する
//                    String tableName = String.valueOf(m1.get("table").toString());
//                    if ("sqlGroup1".equals(groupKey)
//                      && !StringUtils.isEmpty(tableName) && TABLE_PAT_PERSONAL_MAIN.equals(tableName)) {
//// mod 2022-02-07 #7059:ini_dial連携で既存患者の情報を受信するとエラーが発生する 孫 start
////                      // 電文種別が浄化申し込み・初回指示 と 患者プロファイル場合、以下処理を実施する
////                      if ("ini_dial".equals(journal.getCoopCd()) || "profile".equals(journal.getCoopCd())) {
//                      // 電文種別が患者プロファイル場合、以下処理を実施する
//                      if ("profile".equals(journal.getCoopCd())) {
//// mod 2022-02-07 #7059:ini_dial連携で既存患者の情報を受信するとエラーが発生する 孫 end
//                        // 患者番号
//                        String hospPatId = "";
//                        if (idMap.get(ID_HOSP_PAT_ID) != null) {
//                          hospPatId = idMap.get(ID_HOSP_PAT_ID).toString();
//                        }
//                        if (StringUtils.isEmpty(hospPatId)) {
//                          throw new NtssException("種別が浄化申し込み・初回指示(ini_dial)と患者プロファイル(profile)の場合、電文にが患者番号無し。");
//                        }
//                        Long patId = idMap.get(ID_PAT_ID) == null ? null : (Long) idMap.get(ID_PAT_ID);
//
//                        // 対象ジャーナルから種別が「ini_dial」「profile」のレコードを取得する
//                        List<SysCoopJournal> chekJournal = sysCoopJournalDao.selectForNotCoopCheck(facilityCd, journal.getDirection(), patId, hospPatId);
//                        if ("D".equals(constCrud)) {
//                          // 電文が削除電文の場合
//                          if (chekJournal == null || chekJournal.size() == 0) {
//                            // 電文が削除電文の場合、
//                            // 同一連携患者番号が存在するの場合、種別が「ini_dial」「profile」のレコードが存在しない場合、エラー
//                            throw new NtssException("処理区分が削除の場合、同一連携患者番号が存在する、しかし、この患者[" + hospPatId + "]は連携したことがない。");
//                          }
//                        } else {
//                          // 電文が新規、または、更新電文の場合
//                          if ("3".equals(kbn) && (chekJournal == null || chekJournal.size() == 0)) {
//                            // 電文が新規、または、更新電文の場合、
//                            // TODO:問題が多すぎて、対応待ち
//                            // hospPatIdと同じデータが複数存在する場合、SysCoopJournalDaoの中でhospPatIdを条件とした検索処理はエラーが発生します。
//                            // 「hospPatIdを条件とした検索処理」は一つデータしか取れないと予想されます、今は複数のデータを取得します。
//                            // 現在の対応案：エラー
////                          // 同一連携患者番号が存在するの場合、種別が「ini_dial」「profile」のレコードが存在しない場合、更新->新規
////                          // 更新->新規
////                          kbn = "2"; // insert: "2"
////                          // 取得してデータをクリアする
////                          reportInfo.clear();
//
//                            // 同一連携患者番号が存在するの場合、種別が「ini_dial」「profile」のレコードが存在しない場合、エラー
//                            throw new NtssException("同一連携患者番号が存在する、しかし、この患者[" + hospPatId + "]は連携したことがない。");
//                          }
//                        }
//                      }
//                    }
//                    // add 2021-08-25 #5887:富士通連携設定の構築の対応 孫 end
// del 2022-03-10 #7064:GX連携 連携対象患者の判断をini_dialで判断していない 孫 end

                    // #8378-profile連携の患者登録処理でエラーが発生する 周 mod start
                    // setAllPara(m1, kbn, reportInfo);
                    setAllPara(m1, kbn, reportInfo, resultJsonMap);
                    // #8378-profile連携の患者登録処理でエラーが発生する 周 mod end
                  }
                  break;
                }
              }
            }
            if ("9".equals(kbn)) {
              // jsonの削除
              if (j == 0) {
                for (Object obj1 : list) {
                  if (obj1 instanceof Map) {
                    Map<String, Object> m1 = ObjectMapperUtil.castToStringObjectMap(obj1);
                    String crud = String.valueOf(m1.get("crud"));
                    if ("D".equals(crud)) {
                      Long sqlCode = Long.valueOf(m1.get("sqlCode").toString());
                      Map<String, Object> dataKey = new HashMap<>();
                      boolean flg = false;
                      if (isDetail == false) {
                        // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod start
                        //dataKey = getDataKey(m1, jsonMap);
                        // #8378-profile連携の患者登録処理でエラーが発生する 周 mod start
                        //dataKey = getDataKey(m1, jsonMap, idMap);
                        dataKey = getDataKey(m1, jsonMap, idMap, paraMap, resultJsonMap);
                        // #8378-profile連携の患者登録処理でエラーが発生する 周 mod end
                        // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod end
                        flg = isExecute(m1, jsonMap);
                      } else {
                        // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod start
                        //dataKey = getDetailDataKey(m1, jsonMap, j, false);
                        // #8378-profile連携の患者登録処理でエラーが発生する 周 mod start
                        //dataKey = getDetailDataKey(m1, jsonMap, j, false, idMap);
                        dataKey = getDetailDataKey(m1, jsonMap, j, false, idMap, paraMap, resultJsonMap);
                        // #8378-profile連携の患者登録処理でエラーが発生する 周 mod end
                        // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod end
                        if (dataKey == null) {
                          flg = false;
                        } else {
                          flg = isDetailExecute(m1, jsonMap, j);
                        }
                      }
                      if (flg == true) {
                        try {
                          sysDataSetService.updateData(sqlCode, dataKey, null);
                        } catch (Exception ex) {
                          String errMsg = ex.getMessage();
                          outputErrorLog(facilityCd, errMsg);
                          throw new NtssException(errMsg);
                        }
                      }
                      break;
                    }
                  }
                }
              }
              // jsonの追加
              for (Object obj1 : list) {
                if (obj1 instanceof Map) {
                  Map<String, Object> m1 = ObjectMapperUtil.castToStringObjectMap(obj1);
                  String crud = String.valueOf(m1.get("crud"));
                  if ("U".equals(crud)) {
                    Long sqlCode = Long.valueOf(m1.get("sqlCode").toString());
                    Map<String, Object> dataKey = new HashMap<>();
                    boolean flg = false;
                    if (isDetail == false) {
                      // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod start
                      //dataKey = getDataKey(m1, jsonMap);
                      // #8378-profile連携の患者登録処理でエラーが発生する 周 mod start
                      //dataKey = getDataKey(m1, jsonMap, idMap);
                      dataKey = getDataKey(m1, jsonMap, idMap, paraMap, resultJsonMap);
                      // #8378-profile連携の患者登録処理でエラーが発生する 周 mod end
                      // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod end
                      flg = isExecute(m1, jsonMap);
                    } else {
                      // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod start
                      //dataKey = getDetailDataKey(m1, jsonMap, j, true);
                      // #8378-profile連携の患者登録処理でエラーが発生する 周 mod start
                      //dataKey = getDetailDataKey(m1, jsonMap, j, true, idMap);
                      dataKey = getDetailDataKey(m1, jsonMap, j, true, idMap, paraMap, resultJsonMap);
                      // #8378-profile連携の患者登録処理でエラーが発生する 周 mod end
                      // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod end
                      if (dataKey == null) {
                        flg = false;
                      } else {
                        flg = isDetailExecute(m1, jsonMap, j);
                      }
                    }
                    if (flg == true) {
                      try {
                        sysDataSetService.updateData(sqlCode, dataKey, null);
                      } catch (Exception ex) {
                        String errMsg = ex.getMessage();
                        outputErrorLog(facilityCd, errMsg);
                        throw new NtssException(errMsg);
                      }
                    }
                    break;
                  }
                }
              }
            } else {
              // 追加
              if ("2".equals(kbn)) {
                for (Object obj1 : list) {
                  if (obj1 instanceof Map) {
                    Map<String, Object> m1 = ObjectMapperUtil.castToStringObjectMap(obj1);
                    String crud = String.valueOf(m1.get("crud"));
                    if ("C".equals(crud)) {
                      Long sqlCode = Long.valueOf(m1.get("sqlCode").toString());
                      Map<String, Object> dataKey = new HashMap<>();
                      boolean flg = false;
                      if (isDetail == false) {
                        // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod start
                        //dataKey = getDataKey(m1, jsonMap);
                        // #8378-profile連携の患者登録処理でエラーが発生する 周 mod start
                        //dataKey = getDataKey(m1, jsonMap, idMap);
                        dataKey = getDataKey(m1, jsonMap, idMap, paraMap, resultJsonMap);
                        // #8378-profile連携の患者登録処理でエラーが発生する 周 mod end
                        // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod end
                        flg = isExecute(m1, jsonMap);
                      } else {
                        // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod start
                        //dataKey = getDetailDataKey(m1, jsonMap, j, true);
                        // #8378-profile連携の患者登録処理でエラーが発生する 周 mod start
                        //dataKey = getDetailDataKey(m1, jsonMap, j, true, idMap);
                        dataKey = getDetailDataKey(m1, jsonMap, j, true, idMap, paraMap, resultJsonMap);
                        // #8378-profile連携の患者登録処理でエラーが発生する 周 mod end
                        // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod end
                        if (dataKey == null) {
                          flg = false;
                        } else {
                          flg = isDetailExecute(m1, jsonMap, j);
                        }
                      }
                      if (flg == true) {
                        try {
                          sysDataSetService.insertData(sqlCode, dataKey, null);
                        } catch (Exception ex) {
                          String errMsg = ex.getMessage();
                          outputErrorLog(facilityCd, errMsg);
                          throw new NtssException(errMsg);
                        }
                      }
                      break;
                    }
                  }
                }
              }
              // 更新
              if ("3".equals(kbn)) {
                for (Object obj1 : list) {
                  if (obj1 instanceof Map) {
                    Map<String, Object> m1 = ObjectMapperUtil.castToStringObjectMap(obj1);
                    String crud = String.valueOf(m1.get("crud"));
                    if ("U".equals(crud)) {
                      Long sqlCode = Long.valueOf(m1.get("sqlCode").toString());
                      Map<String, Object> dataKey = new HashMap<>();
                      boolean flg = false;
                      if (isDetail == false) {
                        // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod start
                        //dataKey = getDataKey(m1, jsonMap);
                        // #8378-profile連携の患者登録処理でエラーが発生する 周 mod start
                        //dataKey = getDataKey(m1, jsonMap, idMap);
                        dataKey = getDataKey(m1, jsonMap, idMap, paraMap, resultJsonMap);
                        // #8378-profile連携の患者登録処理でエラーが発生する 周 mod end
                        // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod end
                        flg = isExecute(m1, jsonMap);
                      } else {
                        // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod start
                        //dataKey = getDetailDataKey(m1, jsonMap, j, true);
                        // #8378-profile連携の患者登録処理でエラーが発生する 周 mod start
                        //dataKey = getDetailDataKey(m1, jsonMap, j, true, idMap);
                        dataKey = getDetailDataKey(m1, jsonMap, j, true, idMap, paraMap, resultJsonMap);
                        // #8378-profile連携の患者登録処理でエラーが発生する 周 mod end
                        // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod end
                        if (dataKey == null) {
                          flg = false;
                        } else {
                          flg = isDetailExecute(m1, jsonMap, j);
                        }
                      }
                      if (flg == true) {
                        try {
                          sysDataSetService.updateData(sqlCode, dataKey, null);
                        } catch (Exception ex) {
                          String errMsg = ex.getMessage();
                          outputErrorLog(facilityCd, errMsg);
                          throw new NtssException(errMsg);
                        }
                      }
                      break;
                    }
                  }
                }
              }
              // 削除
              for (Object obj1 : list) {
                if (obj1 instanceof Map) {
                  Map<String, Object> m1 = ObjectMapperUtil.castToStringObjectMap(obj1);
                  String crud = String.valueOf(m1.get("crud"));
                  if ("D".equals(crud)) {
                    Long sqlCode = Long.valueOf(m1.get("sqlCode").toString());
                    Map<String, Object> dataKey = new HashMap<>();
                    boolean flg = false;
                    if (isDetail == false) {
                      // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod start
                      //dataKey = getDataKey(m1, jsonMap);
                      // #8378-profile連携の患者登録処理でエラーが発生する 周 mod start
                      //dataKey = getDataKey(m1, jsonMap, idMap);
                      dataKey = getDataKey(m1, jsonMap, idMap, paraMap, resultJsonMap);
                      // #8378-profile連携の患者登録処理でエラーが発生する 周 mod end
                      // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod end
                      flg = isExecute(m1, jsonMap);
                    } else {
                      // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod start
                      //dataKey = getDetailDataKey(m1, jsonMap, j, false);
                      // #8378-profile連携の患者登録処理でエラーが発生する 周 mod start
                      //dataKey = getDetailDataKey(m1, jsonMap, j, false, idMap);
                      dataKey = getDetailDataKey(m1, jsonMap, j, false, idMap, paraMap, resultJsonMap);
                      // #8378-profile連携の患者登録処理でエラーが発生する 周 mod end
                      // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod end
                      if (dataKey == null) {
                        flg = false;
                      } else {
                        flg = isDetailExecute(m1, jsonMap, j);
                      }
                    }
                    if (flg == true) {
                      try {
                        sysDataSetService.deleteData(sqlCode, dataKey, null);
                      } catch (Exception ex) {
                        String errMsg = ex.getMessage();
                        outputErrorLog(facilityCd, errMsg);
                        throw new NtssException(errMsg);
                      }
                    }
                    break;
                  }
                }
              }
            }
            // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod start
            //setIdMap(facilityCd, list, jsonMap);
            setIdMap(facilityCd, list, jsonMap, idMap, coopCd, coopCdIndex, coopVersion);
            // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod end
          }
        }
        // add 2021-08-18 #5887:富士通連携設定の構築の対応 孫 start
        else {
          // groupMapがList以外場合
          String errMsg = String.format("レイアウト拡張設定で%s->%sにListが設定されていません。", "dataset", groupKey);
          throw new NtssException(errMsg);
        }
        // add 2021-08-18 #5887:富士通連携設定の構築の対応 孫 end
      }

      // ord_coop_noを登録する
// mod 2021-10-26 #5890:Medicom連携ができない(複数電文) 孫 start
//      insertOrdCoopNo(rm, jsonMap);
      if (index == tempContentCnt-1) {
        // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod start
        //insertOrdCoopNo(rm, jsonMap);
        insertOrdCoopNo(rm, jsonMap, idMap);
        // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod end
      }
// mod 2021-10-26 #5890:Medicom連携ができない(複数電文) 孫 end
      // add 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 end

      // add #7927 帳票に患者情報が出力されない場合がある 王永吉 start
      // 対象ジャーナルを再取得する
// add 2021-10-26 #5890:Medicom連携ができない(複数電文) 孫 start
    }
    //mod #5607 連動機能の実装確認 20230103 孟堅 start
    sysCoopJournalData.setPatId((Long)idMap.get(ID_PAT_ID));
    //mod #5607 連動機能の実装確認 20230103 孟堅 end
    // add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 20231027  孟堅 start
    if(CoopCdConstant.EXAM_RST.equals(rm.get("%%coop_cd"))){
      Object obj = paraMap.get("pat_exam_main");
      Map<String, Object> map = ObjectMapperUtil.castToStringObjectMap(obj);
      if (map!=null){
        String examMainCd = (String) map.get(ReceiveCoopOrdNoConstants.EXAMMAINCD);
        rm.putSpecial(JournalConvertConstants.EXAMMAINCD,examMainCd);

        if(NumberUtils.isNumber(examMainCd)) {
        	List<Long> examMainCdList = new ArrayList<Long>();
        	examMainCdList.add(Long.parseLong(examMainCd));

        	// 感染症情報更新APIを実行
        	updateInfectinfo(examMainCdList);
        }
      }
    }
    // add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 20231027  孟堅 end
// add 2021-10-26 #5890:Medicom連携ができない(複数電文) 孫 end
    // del 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 start
    /**
//    // テーブルとカラムの抽出
//    Set<String> keySet = rm.keySet();
//    ColumnValueManager columnValueManager = new ColumnValueManager();
//    // add 2021-01-19 No.739:新規マスタを含むオーダ受信時に該当するマスタを新規登録する機能の実装 商 start
//    ColumnValueManager mstColumnValueManager = new ColumnValueManager();
//    // add 2021-01-19 No.739:新規マスタを含むオーダ受信時に該当するマスタを新規登録する機能の実装 商 end
//    for (String key : keySet) {
//      Object value = rm.get(key);
//
//      String[] keys = key.split(TABLE_COLUMN_REGEXP_DELIM, 3);
//
//      switch (keys.length) {
//        case 1:
//          // shori_kbn等の特殊値はここでは処理対象外とし、無視する。
//          break;
//
//        case 2:
//          // key[0]=テーブル名、key[1]=カラム名
//          columnValueManager.add(keys[0], keys[1], value);
//          // add 2021-01-19 No.739:新規マスタを含むオーダ受信時に該当するマスタを新規登録する機能の実装 商 start
//          mstColumnValueManager.add(keys[0], keys[1], value);
//          // add 2021-01-19 No.739:新規マスタを含むオーダ受信時に該当するマスタを新規登録する機能の実装 商 end
//          break;
//
//        case 3:
//          // key[0]=テーブル名、key[1]=カラム名、key[2]=JSONキー名
//          columnValueManager.add(keys[0], keys[1], keys[2], value);
//          // add 2021-01-19 No.739:新規マスタを含むオーダ受信時に該当するマスタを新規登録する機能の実装 商 start
//          mstColumnValueManager.add(keys[0], keys[1], keys[2], value);
//          // add 2021-01-19 No.739:新規マスタを含むオーダ受信時に該当するマスタを新規登録する機能の実装 商 end
//          break;
//
//        default:
//          // ここには到達しないはず。
//          String errMsg2 = String.format("ジャーナルから取得したテーブル名とカラム名が不正です。 [%s]", key);
//          outputErrorLog(facilityCd, errMsg2);
//          throw new NtssException(errMsg2);
//      }
//    }
//
//    // 主テーブル（pat_personal_main、mst_personal_user）の主キー値を保持するマップ
//    Map<String, Long> idMap = new HashMap<>();
//
//    // 主テーブル1: pat_personal_main
//
//    // pat_personal_main.hosp_pat_idを取得する。
//    // 取得できない場合はエラーとする。
//    // （変換レイアウトでpat_personal_main.hosp_pat_idを抽出する指定が記述されていない場合）
//    String hospPatId = (String) columnValueManager.getValueByTableAndColumn(TABLE_PAT_PERSONAL_MAIN, "hosp_pat_id");
//    Long patId = null;
//    if (!StringUtils.isEmpty(hospPatId)) {
//
//      // 患者IDを取得する。
//      Map<String, Object> patPersonalMainValue = columnValueManager.getColumnValueMap().get(TABLE_PAT_PERSONAL_MAIN);
//      patPersonalMainValue.put("facility_cd", facilityCd);
//
//      patId = modifyPatPersonalMain(facilityCd, hospPatId, patPersonalMainValue);
//      idMap.put(ID_PAT_PERSONAL_MAIN, patId);
//    }
//
//    // 主テーブル2: mst_personal_user
//    // 利用者マスタ(mst_personal_user.in_hospital_cd_1を取得)
//    String inHospitalCd1 = (String) columnValueManager.getValueByTableAndColumn(TABLE_MST_PERSONAL_USER, "in_hospital_cd_1");
//    outputDebugLog(facilityCd, "mst_personal_user.in_hospital_cd_1 is " + inHospitalCd1);
//    Long userId = null;
//    if (!StringUtils.isEmpty(inHospitalCd1)) {
//
//      Map<String, Object> mstPersonalUserValue = columnValueManager.getColumnValueMap().get(TABLE_MST_PERSONAL_USER);
//      mstPersonalUserValue.put("facility_cd", facilityCd);
//
//      userId = modifyMstPersonalUser(facilityCd, inHospitalCd1, mstPersonalUserValue);
//      idMap.put(ID_MST_PERSONAL_USER, userId);
//    }
//
//    // DEFAULT DB(DB5)に属するテーブルについて処理
//    try {
//      // ord_mainおよびord_coop_no
//      controlOrdMain(columnValueManager, patId, facilityCd);
//      // add 2021-01-19 No.739:新規マスタを含むオーダ受信時に該当するマスタを新規登録する機能の実装 商 start
//      // マスタテーブル
//      mstTables(facilityCd, idMap, mstColumnValueManager);
//      // add 2021-01-19 No.739:新規マスタを含むオーダ受信時に該当するマスタを新規登録する機能の実装 商 end
//      // その他テーブル
//      registerDefaultTables(facilityCd, idMap, columnValueManager);
//    } catch (NtssException e) {
//      // DBエラーの場合はpat_personal_mainに登録したレコードを論理削除する。
//      if (patId != null) {
//        deletePatPersonalMainLogically(patId);
//      }
//      outputErrorLog(facilityCd, "ジャーナルからトランザクションテーブルに登録する処理でエラーが発生しました。");
//      throw e;
//    }
     */
    // del 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 end
  }

// del 2021-08-18 #5887:富士通連携設定の構築の対応 孫 start
{
//  // pat_personal_main 操作メソッド群
//
//  /**
//   * pat_personal_mainのレコードをinsert/update/deleteする。<br/>
//   *
//   * @param facilityCd           施設コード
//   * @param hospPatId            電文中の患者ID
//   * @param patPersonalMainValue 電文から抽出した内容
//   * @return 患者ID
//   */
//  private Long modifyPatPersonalMain(String facilityCd, String hospPatId, Map<String, Object> patPersonalMainValue) {
//
//    PatPersonalMain ppm = patPersonalMainDao.selectPatInfoByHospPatId(facilityCd, hospPatId);
//
//    // 電文でis_del=trueが指定されていた場合
//    if (getIsDel(patPersonalMainValue)) {
//      if (ppm != null) {
//        // レコードが存在していれば論理削除する。
//        deletePatPersonalMainLogically(ppm.getPat_id());
//        return ppm.getPat_id();
//      } else {
//        // レコードが存在しなかった場合は何もしない。
//        return null;
//      }
//    }
//
//    if (ppm != null) {
//      return updatePatPersonalMain(patPersonalMainValue, ppm);
//    } else {
//      return insertPatPersonalMain(patPersonalMainValue);
//    }
//  }
//
//  /**
//   * 透析情報受信制御
//   *
//   * @param columnValueManager 電文から抽出した内容
//   * @param patId              患者ID
//   * @param facilityCd         施設コード
//   */
//  @Transactional
//  private void controlOrdMain(ColumnValueManager columnValueManager, Long patId, String facilityCd) {
//
//    // ORD_MAIN処理
//    Map<String, Object> ordMainValue = columnValueManager.getColumnValueMap().get("ord_main");
//    if (ordMainValue != null && !ordMainValue.isEmpty()) {
//
//      ordMainValue.put("pat_id", patId);
//      ordMainValue.put("facility_cd", facilityCd);
//      Long ordNo = modifyOrdMain(facilityCd, ordMainValue);
//      Map<String, Object> ordCoopNoValue = columnValueManager.getColumnValueMap().get("ord_coop_no");
//      if (ordCoopNoValue != null) {
//        ordCoopNoValue.put("pat_id", patId);
//        ordCoopNoValue.put("facility_cd", facilityCd);
//        ordCoopNoValue.put("ord_no", ordNo);
//        if (JournalConvertConstants.LOGICAL_DELETE_FLAG_ON.equals(ordMainValue.get("is_del"))) {
//          ordCoopNoValue.put("is_del", JournalConvertConstants.LOGICAL_DELETE_FLAG_ON);
//        }
//
//        modifyOrdCoopNo(ordCoopNoValue, facilityCd);
//      }
//    }
//
//    // 後続処理への影響回避のため処理後にord_mainとord_coop_noを削除
//    Set<String> tableNameSet = columnValueManager.getColumnValueMap().keySet();
//    tableNameSet.remove(TABLE_ORD_MAIN);
//    tableNameSet.remove(TABLE_ORD_COOP_NO);
//  }
//
//  /**
//   * mst_personal_userのレコード insert/update/delete
//   *
//   * @param facilityCd           施設コード
//   * @param hospUserId           表示用利用者ID(院内コード1)
//   * @param mstPersonalUserValue 登録情報
//   * @return userId mst_personal_user.user_id(利用者ID(内部用ID))
//   */
//  private Long modifyMstPersonalUser(String facilityCd, String hospUserId, Map<String, Object> mstPersonalUserValue) {
//
//    MstPersonalUser mpu = mstPersonalUserDao.selectByInHospitalCd1(facilityCd, hospUserId);
//
//    // add 2020-12-31 No.725:電子カルテから利用者マスタを連携される場合、利用者連携時に特定ユーザ（システム専用ユーザ）を除外する 商 start
//    if (mpu != null && mpu.getUserType() == 2) {
//      return null;
//    }
//    // add 2020-12-31 No.725:電子カルテから利用者マスタを連携される場合、利用者連携時に特定ユーザ（システム専用ユーザ）を除外する 商 end
//
//    if (getIsDel(mstPersonalUserValue)) {
//      if (mpu == null) {
//        // 削除指定時にレコードが存在しない場合は何もしない
//        return null;
//      } else {
//        // レコードが存在する場合、論理削除する
//        deleteMstPersonalUserLogically(mpu);
//        return mpu.getUserId();
//      }
//    }
//
//    if (mpu == null) {
//      // 新規登録
//      return insertMstPersonalUser(mstPersonalUserValue);
//    } else {
//      // 更新
//      return updateMstPersonalUser(mstPersonalUserValue, mpu);
//    }
//  }
//
//  /**
//   * ord_mainのレコードをinsert/update/deleteする。<br/>
//   *
//   * @param facilityCd   施設コード
//   * @param ordMainValue 電文から抽出した内容
//   * @return オーダ番号
//   */
//  private Long modifyOrdMain(String facilityCd, Map<String, Object> ordMainValue) {
//
//    if (StringUtils.isEmpty(ordMainValue.get("pat_id"))) {
//      onIdMissing(TABLE_ORD_MAIN, facilityCd);
//    }
//
//    Long ordNo = null;
//
//    if (StringUtils.isEmpty(ordMainValue.get("ord_no"))) {
//      ordNo = insertOrdMain(ordMainValue);
//    } else {
//
//      OrdMain ordMain = ordMainDao.selectByOrdNo(Long.parseLong((String) ordMainValue.get("ord_no")));
//
//      if (ordMain == null) {
//        ordNo = insertOrdMain(ordMainValue);
//      } else {
//        updateOrdMain(ordMainValue, ordMain);
//        ordNo = ordMain.getOrdNo();
//      }
//    }
//
//    return ordNo;
//  }
//
//  /**
//   * ord_coop_noのinsert/deleteの制御
//   *
//   * @param ordCoopNoValue 電文から抽出した内容
//   */
//  private void modifyOrdCoopNo(Map<String, Object> ordCoopNoValue, String facilityCd) {
//
//    // mod 2021-04-13 連携オーダ番号の患者番号（連携用）を追加 孫 start
////    OrdCoopNo ordCoopNo = ordCoopNoDao.selectByPatIdAndCoopCdAndCoopOrdNo((Long) ordCoopNoValue.get("pat_id"), (String) ordCoopNoValue.get("coop_cd"), (String) ordCoopNoValue.get("coop_ord_no"));
//    OrdCoopNo ordCoopNo = ordCoopNoDao.selectByPatIdAndCoopCdAndCoopOrdNo(facilityCd, (Long) ordCoopNoValue.get("pat_id"), (String) ordCoopNoValue.get("hosp_pat_id"), (String) ordCoopNoValue.get("coop_cd"), (String) ordCoopNoValue.get("coop_ord_no"));
//    // mod 2021-04-13 連携オーダ番号の患者番号（連携用）を追加 孫 end
//
//    if (ordCoopNo == null) {
//      insertOrdCoopNo(ordCoopNoValue);
//    } else {
//      if (LOGICAL_DELETE_FLAG_ON.equals(ordCoopNoValue.get("is_del"))) {
//        ordCoopNo.setIsDel(LOGICAL_DELETE_FLAG_ON);
//        ordCoopNoDao.update(ordCoopNo);
//      }
//    }
//  }
//
//  /**
//   * 電文中のpat_personal_mainに対するis_delを取得する。
//   *
//   * @param patPersonalMainValue 電文から抽出した内容
//   * @return is_del="1"が指定されている場合はtrue。is_delの指定がない、is_del="0"が指定されている等の場合はfalse。
//   */
//  private boolean getIsDel(Map<String, Object> patPersonalMainValue) {
//    if (MapUtils.isEmpty(patPersonalMainValue)) {
//      return false;
//    }
//
//    if (!patPersonalMainValue.containsKey("is_del")) {
//      return false;
//    }
//
//    String val = (String) patPersonalMainValue.get("is_del");
//    return val.equals(JournalConvertConstants.LOGICAL_DELETE_FLAG_ON);
//  }
//
//  /**
//   * 電文と既存エンティティを調べ、処理区分を決定する。
//   *
//   * @param facilityCd 施設コード
//   * @param hospPatId  電文中の患者ID
//   * @param tableName  テーブル名
//   * @param mapByTable 電文から抽出した内容（テーブル単位）
//   * @param entity     対応するテーブルのエンティティ
//   * @return 処理区分
//   */
//  private CreationDiv getCreationDiv(String facilityCd, String hospPatId, String tableName,
//                                     Map<String, Object> mapByTable, Object entity) {
//    if (MapUtils.isEmpty(mapByTable)) {
//      String errMsg = String.format("電文から抽出した内容が不正です。 施設コード:[" + facilityCd + "], 患者ID:[" + hospPatId + "], テーブル名:[" + tableName + "]");
//      throw new NtssException(errMsg);
//    }
//
//    if (getIsDel(mapByTable)) {
//      return CreationDiv.DELETE;
//    }
//
//    if (entity == null) {
//      return CreationDiv.CREATE;
//    }
//
//    return CreationDiv.UPDATE;
//  }
//
//  /**
//   * 患者基本情報テーブル（pat_personal_main）にレコードを登録する。
//   *
//   * @param ppmValue pat_personal_mainに対応するマップ
//   * @return 新規登録したレコードの患者ID
//   */
//  @Transactional
//  public Long insertPatPersonalMain(Map<String, Object> ppmValue) {
//    try {
//      // ジャーナルから取得した項目のチェックと編集を実行する。
//      // 編集には以下の内容を含む。
//      // ・院内表示用の患者IDから一意な患者IDへの変換
//      // ・マスタ参照による整合性チェック
//      // ・jsonb型カラムの内容が配列の場合、新規/既存チェックと内容修正
//      String facilityCd = (String) ppmValue.get("facility_cd");
//      patPersonalMainLogic.check(facilityCd, ppmValue);
//      outputDebugLog(facilityCd, String.format("%s:RegisterServiceImpl.insertPatPersonalMain ppmValue=%s", facilityCd, ppmValue));
//
//      // 日付文字列の変換
//      adjustDate(ppmValue);
//      // JSON形式（リストとマップの多段構造）のカラム内容を文字列表現に変換する。
//      Map<String, String> flatMap = EntityJsonUtil.flatten(ppmValue);
//
//      // 登録用のエンティティを作成する。
//      PatPersonalMain ppm = new PatPersonalMain();
//      BeanUtils.copyProperties(ppm, flatMap);
//
//      Timestamp now = new Timestamp(clockWrapper.getClockMillis());
//      String nowStr = now.toString();
//      ppm.setReg_date(nowStr);
//      ppm.setUp_date(nowStr);
//
//      // エンティティを登録する。
//      patPersonalMainDao.insertWithSeq(ppm);
//
//      // シーケンスで採番されたpat_idを取得する。
//      // （insert直後に同条件でselectするのは無駄に見えるが、
//      //   @Insertアノテーションでsql=trueである、エンティティがimmutableであるという2条件を満たす場合、
//      //   この方法しかない。
//      //   sql=falseである、もしくはエンティティがimmutableであれば、insertの呼び出し1回で
//      //   登録されたレコードに対応するエンティティが取得できる。）
//      PatPersonalMain ppm2 = patPersonalMainDao.selectPatInfoByHospPatId(facilityCd,
//        (String) ppmValue.get("hosp_pat_id"));
//      return ppm2.getPat_id();
//
//    } catch (IllegalAccessException | InvocationTargetException e) {
//      String facilityCd = (String) ppmValue.get("facility_cd");
//      outputErrorLog(facilityCd, "pat_personal_mainレコードの登録でエラーが発生しました。 施設コード:[" + facilityCd + "]");
//      throw new NtssException("DBエラーが発生しました。", e);
//    }
//  }
//
//  /**
//   * ord_mainのinsert
//   *
//   * @param omValue 電文から抽出した内容
//   * @return オーダ番号
//   */
//  private Long insertOrdMain(Map<String, Object> omValue) {
//
//    String facilityCd = (String) omValue.get("facility_cd");
//
//    ordMainLogic.check(facilityCd, omValue);
//
//    // JSON形式（リストとマップの多段構造）のカラム内容を文字列表現に変換する。
//    Map<String, String> flatMap = EntityJsonUtil.flatten(omValue);
//    // 登録用のエンティティを作成する。
//    Map<String, Object> m = new HashMap<>();
//    m.putAll(flatMap);
//    OrdMain ordMain = (OrdMain) ordMainLogic.createEntity(m);
//    int insCnt = ordMainDao.insertReceive(ordMain);
//
//    if (insCnt == 1) {
//      OrdMain insOrdMain = ordMainDao.selectLastByFacilityCd(ordMain.getFacilityCd());
//      return insOrdMain.getOrdNo();
//    } else {
//      return null;
//    }
//  }
//
//  /**
//   * ord_mainのupdate
//   *
//   * @param omValue 電文から抽出した内容
//   * @param ordMain 透析情報クラス
//   */
//  private void updateOrdMain(Map<String, Object> omValue, OrdMain ordMain) {
//
//    String facilityCd = (String) omValue.get("facility_cd");
//    ordMainLogic.check(facilityCd, omValue);
//
//    outputDebugLog(facilityCd, String.format("%s:RegisterServiceImpl.insertOrdMain omValue=%s", facilityCd, omValue));
//
//    if (JournalConvertConstants.LOGICAL_DELETE_FLAG_ON.equals(omValue.get("is_del"))) {
//      Timestamp now = new Timestamp(clockWrapper.getClockMillis());
//      ordMainDao.updateDeleteByOrdNo(ordMain.getOrdNo(), now);
//    } else {
//      // JSON形式（リストとマップの多段構造）のカラム内容を文字列表現に変換する。
//      Map<String, String> flatMap = EntityJsonUtil.flatten(omValue);
//      // 登録用のエンティティを作成する。
//      Map<String, Object> m = new HashMap<>();
//      m.putAll(flatMap);
//      OrdMain ordMainUpdate = (OrdMain) ordMainLogic.createEntity(m);
//      ordMainDao.updateReceive(ordMainUpdate);
//    }
//  }
//
//  /**
//   * ord_coop_noのinsert
//   *
//   * @param omValue 電文から抽出した内容
//   */
//  private void insertOrdCoopNo(Map<String, Object> omValue) {
//
//    // JSON形式（リストとマップの多段構造）のカラム内容を文字列表現に変換する。
//    Map<String, String> flatMap = EntityJsonUtil.flatten(omValue);
//    // 登録用のエンティティを作成する。
//    Map<String, Object> m = new HashMap<>();
//    m.putAll(flatMap);
//    OrdCoopNo ordCoopNo = (OrdCoopNo) ordCoopNoLogic.createEntity(omValue);
//    ordCoopNoDao.insert(ordCoopNo);
//  }
//
//  /**
//   * Timestamp型に変換される文字列を修正する。
//   *
//   * @param map エンティティ変換用マップ
//   */
//  private void adjustDate(Map<String, Object> map) {
//    if (MapUtils.isEmpty(map)) {
//      return;
//    }
//
//    String dieDateStr = (String) map.get("die_date");
//    if (StringUtils.isEmpty(dieDateStr)) {
//      // add 2021-02-25 電文確認：mapからnullデータを削除する。 孫 start
//      map.remove("die_date");
//      // add 2021-02-25 電文確認：mapからnullデータを削除する。 孫 end
//      return;
//    }
//
//    if (DIE_DATE_ALIVE.equals(dieDateStr)) {
//      map.remove("die_date");
//      return;
//    }
//
//    DateUtil.convertDateStrToTimestamp(map, "die_date");
//  }
//
//  /**
//   * 患者基本情報テーブル（pat_personal_main）にレコードを登録する。
//   *
//   * @param ppmValue  pat_personal_mainに対応するマップ
//   * @param ppmEntity pat_personal_mainテーブルから取得したPatPersonalMainエンティティ
//   * @return pat_parsonal_mainレコードのpat_id（主キー）
//   */
//  @Transactional
//  public Long updatePatPersonalMain(Map<String, Object> ppmValue, PatPersonalMain ppmEntity) {
//    String facilityCd = (String) ppmValue.get("facility_cd");
//    patPersonalMainLogic.check(facilityCd, ppmValue, ppmEntity);
//    outputDebugLog(facilityCd, facilityCd + ":RegisterServiceImpl:updatePatPersonalMain ppmValue=" + ppmValue);
//
//    // 日付の変換
//    adjustDate(ppmValue);
//
//    PatPersonalMain entityToUpdate = (PatPersonalMain) patPersonalMainLogic.createEntity(ppmValue);
//    Long patId = ppmEntity.getPat_id();
//    entityToUpdate.setPat_id(patId);
//
//    Timestamp now = new Timestamp(clockWrapper.getClockMillis());
//    String nowStr = now.toString();
//    entityToUpdate.setUp_date(nowStr);
//
//    String isDel = (String) ppmValue.get("is_del");
//    if (LOGICAL_DELETE_FLAG_ON.equals(isDel)) {
//
//      // DB更新ログ出力ロジック wangzuo Start
//      String tableName = "pat_personal_main";
//      // SQL検索条件
//      StringBuffer wheres = new StringBuffer("");
//      wheres.append(" WHERE\n");
//      wheres.append(" pat_id = " + patId + "\n");
//      // logCommon設定
//      DataUpdateLogCommonNew logCommon = getLogCommon(patPersonalMainDao, tableName, wheres, getEventLogMessage());
//      // ログ出力カラム情報及び更新前データ情報取得
//      boolean setResult = logCommon.setInfo();
//      // DB更新ログ出力ロジック wangzuo End
//
//      int updateCount = patPersonalMainDao.updateIsDelById(patId);
//
//      // DB更新ログ出力ロジック wangzuo Start
//      // 更新後データ取得、差分あれば、log出力
//      if (setResult && updateCount > 0) {
//        logCommon.updateLog();
//      }
//      // DB更新ログ出力ロジック wangzuo End
//
//    } else {
//      patPersonalMainDao.updateById(patId, entityToUpdate);
//    }
//
//    return patId;
//  }
//
//  /**
//   * mst_personal_userの登録
//   *
//   * @param mpuValue 登録情報
//   * @return userId 採番した利用者ID(内部用ID)
//   */
//  @Transactional
//  public Long insertMstPersonalUser(Map<String, Object> mpuValue) {
//
//    // ジャーナルから取得した項目のチェックと編集
//    String facilityCd = (String) mpuValue.get("facility_cd");
//    mstPersonalUserLogic.check(facilityCd, mpuValue);
//
//    // 日付文字列の変換
//    adjustDate(mpuValue);
//    // JSON形式（リストとマップの多段構造）のカラム内容を文字列表現に変換する。
//    Map<String, String> flatMap = EntityJsonUtil.flatten(mpuValue);
//
//    // 登録用のエンティティを作成する。
//    Map<String, Object> m = new HashMap<>();
//    m.putAll(flatMap);
//    MstPersonalUser mpu = (MstPersonalUser) mstPersonalUserLogic.createEntity(m);
//
//    Timestamp now = new Timestamp(clockWrapper.getClockMillis());
//    mpu.setRegDate(now);
//    mpu.setUpDate(now);
//
//    // エンティティを登録する。
//    // （insertNewUserで暗号化項目を平文で登録した後、updateで暗号化している。
//    // 奇異ではあるが、ntss-admin-webの実装に倣った。）
//    mstPersonalUserDao.insertNewUser(mpu);
//    mstPersonalUserDao.updateEncrypt(mpu);
//
//    return mpu.getUserId();
//  }
//
//  /**
//   * mst_personal_userの更新
//   *
//   * @param mpuValue  mst_personal_userに対応するマップ
//   * @param mpuEntity pat_personal_mainテーブルから取得したPatPersonalMainエンティティ
//   * @return mst_personal_user.user_id
//   */
//  @Transactional
//  public Long updateMstPersonalUser(Map<String, Object> mpuValue, MstPersonalUser mpuEntity) {
//
//    // ジャーナルから取得した項目のチェックと編集を実行する
//    // 編集には以下の内容を含む
//    // mpuValueに連携されていない暗号対象項目はmpuEntityからコピーする
//    String facilityCd = (String) mpuValue.get("facility_cd");
//    mstPersonalUserLogic.check(facilityCd, mpuValue, mpuEntity);
//
//    // 日付文字列の変換
//    adjustDate(mpuValue);
//    // JSON形式（リストとマップの多段構造）のカラム内容を文字列表現に変換する。
//    Map<String, String> flatMap = EntityJsonUtil.flatten(mpuValue);
//
//    // 更新用のエンティティを作成する。
//    Map<String, Object> map = new HashMap<>();
//    map.putAll(flatMap);
//    MstPersonalUser mpu = (MstPersonalUser) mstPersonalUserLogic.createEntity(map);
//
//    // ユーザIDを設定
//    mpu.setUserId(mpuEntity.getUserId());
//
//    String isDel = (String) mpuValue.get("is_del");
//    if (LOGICAL_DELETE_FLAG_ON.equals(isDel)) {
//      // 削除フラグを更新
//      mstPersonalUserDao.updateIsDel(mpu);
//    } else {
//      // 更新
//      mstPersonalUserDao.updateInit(mpu);
//      // 暗号化用更新
//      mstPersonalUserDao.updateEncrypt(mpu);
//    }
//
//    return mpuEntity.getUserId();
//  }
//
//  /**
//   * mst_personal_userのレコードを論理削除
//   *
//   * @param mpu mst_personal_userのレコード
//   * @return 更新件数
//   */
//  @Transactional
//  public int deleteMstPersonalUserLogically(MstPersonalUser mpu) {
//
//    // 削除フラグ
//    mpu.setIsDel(LOGICAL_DELETE_FLAG_ON);
//
//    // 削除フラグを更新
//    return mstPersonalUserDao.updateIsDel(mpu);
//  }
//
//  /**
//   * pat_personal_mainレコードを論理削除する。
//   *
//   * @param patId 患者ID
//   * @return 削除件数
//   */
//  @Transactional
//  public int deletePatPersonalMainLogically(Long patId) {
//    if (patId == null) {
//      return 0;
//    }
//
//    // DB更新ログ出力ロジック wangzuo Start
//    String tableName = "pat_personal_main";
//    // SQL検索条件
//    StringBuffer wheres = new StringBuffer("");
//    wheres.append(" WHERE\n");
//    wheres.append(" pat_id = " + patId + "\n");
//    // logCommon設定
//    DataUpdateLogCommonNew logCommon = getLogCommon(patPersonalMainDao, tableName, wheres, getEventLogMessage());
//    // ログ出力カラム情報及び更新前データ情報取得
//    boolean setResult = logCommon.setInfo();
//    // DB更新ログ出力ロジック wangzuo End
//
//    int updateCount = patPersonalMainDao.updateIsDelById(patId);
//
//    // DB更新ログ出力ロジック wangzuo Start
//    // 更新後データ取得、差分あれば、log出力
//    if (setResult && updateCount > 0) {
//      logCommon.updateLog();
//    }
//    // DB更新ログ出力ロジック wangzuo End
//
//    return updateCount;
//  }
//
//  // DEFAULT DB(DB5)テーブル操作群
//
//  /**
//   * DEFAULT DB(DB5)に属するテーブルについて登録/更新を実行する。
//   *
//   * @param facilityCd         施設コード
//   * @param idMap              テーブル名とID（患者ID、ユーザID）を対応付けるマップ
//   * @param columnValueManager ColumnValueManager
//   */
//  @Transactional
//  public void registerDefaultTables(String facilityCd, Map<String, Long> idMap, ColumnValueManager columnValueManager) {
//    Set<String> tableNameSet = columnValueManager.getColumnValueMap().keySet();
//    tableNameSet.remove(TABLE_PAT_PERSONAL_MAIN);
//    tableNameSet.remove(TABLE_MST_PERSONAL_USER);
//
//    if (CollectionUtils.isEmpty(tableNameSet)) {
//      return;
//    }
//
//    for (String tableName : tableNameSet) {
//      String idKey = TABLE_ID_MAP.get(tableName);
//      Long recordId = idMap.get(idKey);
//      if (recordId == null) {
//        onIdMissing(tableName, facilityCd);
//      }
//      Map<String, Object> columnValue = columnValueManager.getColumnMap(tableName);
//      outputDebugLog(facilityCd, String.format("%s:RegisterServiceImpl.registerDefaultTables table=%s columnValue=%s", facilityCd, tableName, columnValue));
//      // テーブル更新
//      registerDefaultTable(facilityCd, recordId, tableName, columnValue);
//    }
//  }
//
//  // add 2021-01-19 No.739:新規マスタを含むオーダ受信時に該当するマスタを新規登録する機能の実装 商 start
//
//  /**
//   * DEFAULT DB(DB5)に属するテーブルについて登録/更新を実行する。
//   *
//   * @param facilityCd         施設コード
//   * @param idMap              テーブル名とID（患者ID、ユーザID）を対応付けるマップ
//   * @param columnValueManager ColumnValueManager
//   */
//  @Transactional
//  public void mstTables(String facilityCd, Map<String, Long> idMap, ColumnValueManager columnValueManager) {
//    Set<String> tableNameSet = columnValueManager.getColumnValueMap().keySet();
//
//    if (CollectionUtils.isEmpty(tableNameSet)) {
//      return;
//    }
//
//    for (String tableName : tableNameSet) {
//      if (TABLE_ORD_MAIN.equals(tableName)) {
//        // ダイアライザマスタ登録
//        insertMstDialyzer(tableName, facilityCd, columnValueManager, tableNameSet);
//
//        // 医療材料マスタ登録
//        insertMstEquipment(tableName, facilityCd, columnValueManager);
//
//        // 薬剤マスタ登録
//        insertMstMedicine(tableName, facilityCd, columnValueManager);
//      }
//    }
//  }
//
//  /**
//   * ダイアライザマスタ登録
//   *
//   * @param tableName
//   * @param facilityCd
//   * @param columnValueManager
//   * @param tableNameSet
//   */
//  private void insertMstDialyzer(String tableName, String facilityCd, ColumnValueManager columnValueManager, Set<String> tableNameSet) {
//    String inHospitalCd1 = null;
//    Map<String, Object> columnValue = columnValueManager.getColumnMap(tableName);
//    String modelNumber = null;
//    for (String dialyzer : tableNameSet) {
//      if ("mst_dialyzer".equals(dialyzer)) {
//        Map<String, Object> dialyzerMap = columnValueManager.getColumnMap("mst_dialyzer");
//        if (dialyzerMap != null || !dialyzerMap.isEmpty()) {
//          modelNumber = (String) dialyzerMap.get("model_number");
//        }
//        break;
//      }
//    }
//
//    if (columnValue != null || !columnValue.isEmpty()) {
//      Map<String, Object> indCondInfo = (Map<String, Object>) columnValue.get("ind_cond_info");
//      if (indCondInfo != null || !indCondInfo.isEmpty()) {
//        List<Object> list = (List<Object>) indCondInfo.get("5");
//        if (list != null && list.size() > 0) {
//          Map<String, Object> value = (Map<String, Object>) list.get(0);
//          if (value != null || !value.isEmpty()) {
//            inHospitalCd1 = (String) value.get("value");
//          }
//        }
//      }
//    }
//
//    List<MstDialyzer> mstDialyzerList = mstDialyzerDao.selectByInHospitalCd1(facilityCd, inHospitalCd1);
//    if (mstDialyzerList == null || mstDialyzerList.size() == 0) {
//      // マスタテーブル登録
//      MstDialyzer mstDialyzer = new MstDialyzer();
//      mstDialyzer.setFacilityCd(facilityCd);
//      mstDialyzer.setModelNumber(modelNumber);
//      mstDialyzer.setInHospitalCd_1(inHospitalCd1);
//      mstDialyzer.setIsDisp(ApiConstant.FlagType.FLAG_ON);
//      mstDialyzer.setIsDel(ApiConstant.FlagType.FLAG_OFF);
//      Timestamp timestamp = new Timestamp(System.currentTimeMillis());
//      mstDialyzer.setUpDate(timestamp);
//      mstDialyzer.setRegDate(timestamp);
//      int cntDialyzer = mstDialyzerDao.insertMstDialyzer(mstDialyzer);
//      if (cntDialyzer == 1) {
//        // ダイアライザコード取得
//        List<MstDialyzer> list = mstDialyzerDao.selectByInHospitalCd1(facilityCd, inHospitalCd1);
//        if (list != null && list.size() > 0) {
//          Long dialyzerCd = list.get(0).getDialyzerCd().longValue();
//          // 選択肢マスタ登録
//          insertMstSelector(dialyzerCd, modelNumber, facilityCd, "mst_dialyzer");
//        }
//      }
//    }
//  }
//
//  /**
//   * 医療材料マスタ登録
//   *
//   * @param tableName
//   * @param facilityCd
//   * @param columnValueManager
//   */
//  private void insertMstEquipment(String tableName, String facilityCd, ColumnValueManager columnValueManager) {
//    String inHospitalCd1 = null;
//    Map<String, Object> columnValue = columnValueManager.getColumnMap(tableName);
//    if (columnValue != null || !columnValue.isEmpty()) {
//      List<Object> indEquipInfoList = (List<Object>) columnValue.get("ind_equip_info");
//      if (indEquipInfoList != null && indEquipInfoList.size() > 0) {
//        for (int i = 0; i < indEquipInfoList.size(); i++) {
//          Map<String, Object> indEquipInfoMap = (Map<String, Object>) indEquipInfoList.get(i);
//          if (indEquipInfoMap != null || !indEquipInfoMap.isEmpty()) {
//            inHospitalCd1 = (String) indEquipInfoMap.get("cd");
//          }
//          List<MstEquipment> mstEquipmentList = mstEquipmentDao.selectByInHospitalCd1(facilityCd, inHospitalCd1);
//          if (mstEquipmentList == null || mstEquipmentList.size() == 0) {
//            // マスタテーブル登録
//            MstEquipment mstEquipment = new MstEquipment();
//            mstEquipment.setFacilityCd(facilityCd);
//            mstEquipment.setEquipmentName((String) indEquipInfoMap.get("name"));
//            mstEquipment.setInHospitalCd_1(inHospitalCd1);
//            mstEquipment.setIsDisp(ApiConstant.FlagType.FLAG_ON);
//            mstEquipment.setIsDel(ApiConstant.FlagType.FLAG_OFF);
//            Timestamp timestamp = new Timestamp(System.currentTimeMillis());
//            mstEquipment.setUpDate(timestamp);
//            mstEquipment.setRegDate(timestamp);
//            int cntEquipment = mstEquipmentDao.insertMstEquipment(mstEquipment);
//            if (cntEquipment == 1) {
//              // 医療材料コード取得
//              List<MstEquipment> list = mstEquipmentDao.selectByInHospitalCd1(facilityCd, inHospitalCd1);
//              if (list != null && list.size() > 0) {
//                Long equipmentCd = list.get(0).getEquipmentCd().longValue();
//                // 選択肢マスタ登録
//                insertMstSelector(equipmentCd, (String) indEquipInfoMap.get("name"), facilityCd, "mst_equipment");
//              }
//            }
//          }
//        }
//      }
//    }
//  }
//
//  /**
//   * 薬剤マスタ登録
//   *
//   * @param tableName
//   * @param facilityCd
//   * @param columnValueManager
//   */
//  private void insertMstMedicine(String tableName, String facilityCd, ColumnValueManager columnValueManager) {
//    String inHospitalCd1 = null;
//    Map<String, Object> columnValue = columnValueManager.getColumnMap(tableName);
//    if (columnValue != null || !columnValue.isEmpty()) {
//      List<Object> indMediInfoList = (List<Object>) columnValue.get("ind_medi_info");
//      if (indMediInfoList != null && indMediInfoList.size() > 0) {
//        for (int i = 0; i < indMediInfoList.size(); i++) {
//          Map<String, Object> indMediInfoMap = (Map<String, Object>) indMediInfoList.get(i);
//          if (indMediInfoMap != null || !indMediInfoMap.isEmpty()) {
//            inHospitalCd1 = (String) indMediInfoMap.get("cd");
//          }
//          List<MstMedicine> mstMedicineList = mstMedicineDao.selectByInHospitalCd1(facilityCd, inHospitalCd1);
//          if (mstMedicineList == null || mstMedicineList.size() == 0) {
//            // マスタテーブル登録
//            MstMedicine mstMedicine = new MstMedicine();
//            mstMedicine.setFacilityCd(facilityCd);
//            mstMedicine.setMedicineName((String) indMediInfoMap.get("name"));
//            mstMedicine.setUnit((String) indMediInfoMap.get("unit"));
//            mstMedicine.setInHospitalCd_1(inHospitalCd1);
//            mstMedicine.setIsDisp(ApiConstant.FlagType.FLAG_ON);
//            mstMedicine.setIsDel(ApiConstant.FlagType.FLAG_OFF);
//            Timestamp timestamp = new Timestamp(System.currentTimeMillis());
//            mstMedicine.setUpDate(timestamp);
//            mstMedicine.setRegDate(timestamp);
//            int cntMedicine = mstMedicineDao.insertMstMedicine(mstMedicine);
//            if (cntMedicine == 1) {
//              // 薬剤コード取得
//              List<MstMedicine> list = mstMedicineDao.selectByInHospitalCd1(facilityCd, inHospitalCd1);
//              if (list != null && list.size() > 0) {
//                Long medicineCd = list.get(0).getMedicineCd().longValue();
//                // 選択肢マスタ登録
//                insertMstSelector(medicineCd, (String) indMediInfoMap.get("name"), facilityCd, "mst_medicine");
//              }
//            }
//          }
//        }
//      }
//    }
//  }
//
//  /**
//   * 選択肢マスタ登録
//   *
//   * @param code
//   * @param name
//   * @param facilityCd
//   * @param masterPhysicalName
//   */
//  private void insertMstSelector(Long code, String name, String facilityCd, String masterPhysicalName) {
//    // 選択肢マスタ登録
//    MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, masterPhysicalName);
//    if (mstSelector != null) {
//      List<MstSelector.Item> items = (List<MstSelector.Item>) mstSelector.getOrderSettings().getItems();
//      if (items == null) {
//        items = new ArrayList<MstSelector.Item>();
//      }
//      addItemList(items, code, name);
//      MstSelector.OrderSettings orderSettings = new MstSelector.OrderSettings();
//      orderSettings.setItems(items);
//      mstSelector.setOrderSettings(orderSettings);
//      mstSelectorDao.updateMstExamItemSelector(mstSelector);
//    } else {
//      mstSelector = new MstSelector();
//      mstSelector.setFacilityCd(facilityCd);
//      mstSelector.setMasterPhysicalName(masterPhysicalName);
//      List<MstSelector.Item> items = new ArrayList<MstSelector.Item>();
//      addItemList(items, code, name);
//      MstSelector.OrderSettings orderSettings = new MstSelector.OrderSettings();
//      orderSettings.setItems(items);
//      mstSelector.setOrderSettings(orderSettings);
//      mstSelectorDao.insert(mstSelector);
//    }
//  }
//
//  /**
//   * マスタセレクタItem追加.
//   *
//   * @param items
//   * @param code
//   * @param name
//   */
//  private void addItemList(List<MstSelector.Item> items, Long code, String name) {
//
//    MstSelector.Item item = new MstSelector.Item();
//    item.setCode(code);
//    item.setName(name);
//    item.setJlac10Cd(null);
//    items.add(item);
//  }
//  // add 2021-01-19 No.739:新規マスタを含むオーダ受信時に該当するマスタを新規登録する機能の実装 商 end
//
//  /**
//   * レコードのID（患者ID、ユーザID）が指定されていない時、例外を発生させる。
//   *
//   * @param tableName  テーブル名
//   * @param facilityCd 施設コード
//   */
//  private void onIdMissing(String tableName, String facilityCd) {
//    // 注: ここでは患者情報テーブルかそれ以外か判別していない。
//    // より細かく例外メッセージを分ける場合は修正する。
//    if (isPatientTable(tableName)) {
//      String errMsg = String.format("患者情報テーブル[%s]登録の前提となるpat_personal_mainレコードが登録されていません。 施設コード=[%s]", tableName,
//        facilityCd);
//      throw new NtssException(errMsg);
//    }
//
//    if (isUserTable(tableName)) {
//      String errMsg = String.format("ユーザ情報テーブル[%s]登録の前提となるmst_personal_userレコードが登録されていません。 施設コード=[%s]", tableName,
//        facilityCd);
//      throw new NtssException(errMsg);
//    }
//  }
//
//  /**
//   * テーブルが患者情報テーブルか否かを判別する。
//   *
//   * @param tableName テーブル名
//   * @return 患者情報テーブルであればtrue、それ以外の場合はfalse
//   */
//  private boolean isPatientTable(String tableName) {
//    return PATIENT_TABLE_NAMES.contains(tableName);
//  }
//
//  /**
//   * テーブルが患者情報テーブルか否かを判別する。
//   *
//   * @param tableName テーブル名
//   * @return 患者情報テーブルであればtrue、それ以外の場合はfalse
//   */
//  private boolean isUserTable(String tableName) {
//    return USER_TABLE_NAMES.contains(tableName);
//  }
//
//  /**
//   * DEFAULT DB(DB5)に属するテーブルについて登録/更新を実行する。
//   *
//   * @param facilityCd  施設コード
//   * @param patId       患者ID
//   * @param tableName   テーブル名
//   * @param columnValue カラム名と値のマップ
//   */
//  private void registerDefaultTable(String facilityCd, Long patId, String tableName,
//                                    Map<String, Object> columnValue) {
//    Long copOrderNo1 = null;
//
//    if (tableName.equals(TABLE_PAT_EXAM_MAIN)) {
//      copOrderNo1 = Long.parseLong((String) columnValue.get("cop_order_no1"));
//    }
//
//    modify(facilityCd, patId, tableName, copOrderNo1, columnValue);
//  }
//
//  /**
//   * 電文で受信した内容をDBに反映（insert/update/delete（論理削除））する。<br/>
//   * 処理がinsert/update/deleteのいずれであるかは、電文内容と既存レコードの有無により決定する。
//   *
//   * @param facilityCd  施設コード
//   * @param patId       患者ID
//   * @param tableName   テーブル名
//   * @param copOrderNo1 連携オーダー番号
//   * @param mapByTable  電文受信内容（テーブル別）
//   * @return
//   */
//  private int modify(String facilityCd, Long patId, String tableName, Long copOrderNo1,
//                     Map<String, Object> mapByTable) {
//    Object entity = getEntity(tableName, patId, facilityCd, copOrderNo1);
//
//    mapByTable.put("facility_cd", facilityCd);
//
//    // 患者情報連携の場合はuser_id、ユーザ情報連携の場合はpat_idを使用しない。
//    // FIXME mst_userテーブルはpat_idカラムを持つ。
//    // FIXME 値の抽出方法（電文 or DBから取得）は仕様確認中。現状は暫定的に未設定としている。
//    mapByTable.put("pat_id", patId);
//    mapByTable.put("user_id", patId);
//
//    CreationDiv div = getCreationDiv(facilityCd, String.valueOf(patId), tableName, mapByTable, entity);
//    outputDebugLog(facilityCd, "modify target:[" + tableName + "] creationDiv:[" + div.getName() + "]");
//
//    switch (div) {
//      case CREATE:
//        return insert(tableName, mapByTable);
//
//      case UPDATE:
//        return update(tableName, mapByTable, entity);
//
//      case DELETE:
//        return delete(tableName, entity);
//
//      default:
//        onMissingTable(tableName);
//        return 0;
//    }
//  }
//
//  /**
//   * テーブルからレコードを読み込み、エンティティとして取得する。
//   *
//   * @param tableName テーブル名
//   * @param patId     患者ID
//   * @param auxId     補助ID
//   * @return エンティティ
//   */
//  private Object getEntity(String tableName, Long patId, Object... auxId) {
//    switch (tableName) {
//      case TABLE_PAT_MAIN:
//        return patMainDao.selectById(patId);
//
//      // pat_exam_main
//      // 主キー: exam_main_cd
//      case TABLE_PAT_EXAM_MAIN:
//        return patExamMainDao.selectById(patId, (String) auxId[0], (Long) auxId[1]);
//
//      // pat_unique
//      // 主キー: pat_id
//      case TABLE_PAT_UNIQUE:
//        return patUniqueDao.selectById(patId);
//
//      // pat_obs_rec
//      // 主キー: obs_rec_no
//      case TABLE_PAT_OBS_REC:
//        return patObsRecDao.selectById(patId, (String) auxId[0]);
//
//      // pat_coop_detail
//      case TABLE_PAT_COOP_DETAIL:
//        return patCoopDetailDao.selectByPatId(patId, (String) auxId[0]);
//
//      // pat_insurance
//      case TABLE_PAT_INSURANCE:
//        // pat_insuranceのレコードは施設コード、患者ID、insu_class、coop_codeによって特定されるが、
//        // ベンダーごとに電文形式が異なるため、この段階ではinsu_classとcoop_codeが取得できない。
//        // 合致するレコードのうち、ctl_noが最小のものを返す。
//        List<PatInsurance> l = patInsuranceDao.selectByPatId(patId, (String) auxId[0]);
//        outputDebugLog((String) auxId[0], "RegisterServiceImpl:delete:patinsurance: patId=" + patId + ", auxId=" + auxId[0] + "");
//        if (!CollectionUtils.isEmpty(l)) {
//          return l.get(0);
//        }
//        return null;
//
//      case TABLE_MST_USER_AUTHENTICATION:
//        // patIdには利用者ID(内部用ID)が設定されている
//        return mstUserAuthenticationDao.selectById(patId);
//
//      case TABLE_MST_USER:
//        // patIdには利用者ID(内部用ID)が設定されている
//        return mstUserDao.selectById(patId);
//
//      default:
//        onMissingTable(tableName);
//        return null;
//    }
//  }
//
//  /**
//   * テーブルにレコードを登録する。
//   *
//   * @param div         作成区分（新規、変更、削除）
//   * @param tableName   テーブル名
//   * @param columnValue レコードに対応するマップ
//   * @return 登録件数
//   */
//  @Transactional
//  public int insert(String tableName, Map<String, Object> columnValue) {
//    EntityLogic entityLogic = getEntityLogicByTableName(tableName);
//    if (entityLogic == null) {
//      return 0;
//    }
//
//    String facilityCd = (String) columnValue.get("facility_cd");
//    // 各エンティティ毎のチェック処理
//    entityLogic.check(facilityCd, columnValue);
//    outputDebugLog(facilityCd, String.format("%s:RegisterServiceImpl.insert tableName=%s, value=%s", facilityCd, tableName, columnValue));
//
//    // pat_insurance等、1電文から複数レコードを登録するテーブルの場合
//    // EntityLogic実装クラスで登録が済んでいるので、このメソッドの登録処理はスキップする。
//    Boolean isAlreadyRegistered = (Boolean) columnValue.get(IS_ALREADY_REGISTERED);
//    if (isAlreadyRegistered != null && isAlreadyRegistered) {
//      outputDebugLog(facilityCd, "個別処理でDB登録が済んでいるためスキップします。施設コード:[" + facilityCd + "], テーブル:[" + tableName + "]");
//      return 1;
//    }
//
//    Object entity = entityLogic.createEntity(columnValue);
//
//    // DAO間に互換性がない。
//    // そのため、EntityLogicのように共通インタフェースで統一的に処理する方法が使えないため、
//    // テーブル名によって分岐する方法を採っている。
//    switch (tableName) {
//      case TABLE_PAT_MAIN:
//        return patMainDao.insert((PatMain) entity);
//
//      case TABLE_PAT_EXAM_MAIN:
//        return patExamMainDao.insert((PatExamMain) entity);
//
//      case TABLE_PAT_UNIQUE:
//        return patUniqueDao.insert((PatUnique) entity);
//
//      case TABLE_PAT_OBS_REC:
//        return patObsRecDao.insert((PatObsRec) entity);
//
//      case TABLE_PAT_COOP_DETAIL:
//        return patCoopDetailDao.insert((PatCoopDetail) entity);
//
//      case TABLE_PAT_INSURANCE:
//        return patInsuranceDao.insert((PatInsurance) entity);
//
//      case TABLE_MST_USER_AUTHENTICATION:
//        return mstUserAuthenticationDao.insertNewUser((MstUserAuthentication) entity);
//
//      case TABLE_MST_USER:
//        return mstUserDao.insertNewUser((MstUser) entity);
//
//      default:
//        onMissingTable(tableName);
//        return 0;
//    }
//  }
//
//  /**
//   * テーブルのレコードを更新する。<br/>
//   * エンティティ中のフィールドの値がnullである場合、nullのフィールドは除いて更新する。
//   *
//   * @param tableName   テーブル名
//   * @param columnValue レコードに対応するマップ
//   * @param entity      テーブルから取得したエンティティ
//   * @return 更新件数
//   */
//  @Transactional
//  public int update(String tableName, Map<String, Object> columnValue, Object entity) {
//    EntityLogic entityLogic = getEntityLogicByTableName(tableName);
//
//    String facilityCd = (String) columnValue.get("facility_cd");
//    outputDebugLog(facilityCd, facilityCd + ":RegisterServiceImpl.update-before tableName=" + tableName + ", columnValue=" + columnValue);
//
//    // 各エンティティ毎のチェック処理
//    entityLogic.check(facilityCd, columnValue, entity);
//    outputDebugLog(facilityCd, facilityCd + ":RegisterServiceImpl.update-after tableName=" + tableName + ", columnValue=" + columnValue);
//    outputDebugLog(facilityCd, facilityCd + ":RegisterServiceImpl:update columnValue=" + columnValue);
//
//    Boolean isAlreadyRegistered = (Boolean) columnValue.get("registered");
//    if (isAlreadyRegistered != null && isAlreadyRegistered) {
//      outputDebugLog(facilityCd, "個別処理でDB登録が済んでいるためスキップします。施設コード:[" + facilityCd + "], テーブル:[" + tableName + "]");
//      return 1;
//    }
//
//    Object entityToUpdate = entityLogic.createEntity(columnValue);
//    outputDebugLog(facilityCd, String.format("%s:RegisterServiceImpl.update table=%s, columnValue=%s", facilityCd, tableName, columnValue));
//
//    // DAO間に互換性がない。
//    // そのため、EntityLogicのように共通インタフェースで統一的に処理する方法が使えないため、
//    // テーブル名によって分岐する方法を採っている。
//    // （テーブル名からDAOクラス名を計算し、SpringのBean管理からDAOオブジェクトを取得して実行する方法もあるが、
//    //   理解にSpring内部構造の知識が必要になり保守性に欠ける。）
//    switch (tableName) {
//      case TABLE_PAT_MAIN:
//        return patMainDao.updatePatMain((PatMain) entityToUpdate);
//
//      case TABLE_PAT_EXAM_MAIN:
//        // pat_exam_mainでは、既存レコードが存在した時論理削除し、
//        // コピーに受信内容を上書き設定してinsertする。
//        return updatePatExamMain((PatExamMain) entityToUpdate, (PatExamMain) entity);
//
//      case TABLE_PAT_UNIQUE:
//        return patUniqueDao.update((PatUnique) entityToUpdate);
//
//      case TABLE_PAT_OBS_REC:
//        return patObsRecDao.update((PatObsRec) entityToUpdate);
//
//      case TABLE_PAT_COOP_DETAIL:
//        return patCoopDetailDao.update((PatCoopDetail) entityToUpdate);
//
//      case TABLE_PAT_INSURANCE:
//        // pat_insuranceもpat_exam_mainと同様。
//        outputDebugLog(facilityCd, "trying to update PatInsurance");
//        return updatePatInsurance((PatInsurance) entityToUpdate, (PatInsurance) entity);
//
//      case TABLE_MST_USER_AUTHENTICATION:
//        return mstUserAuthenticationDao.update((MstUserAuthentication) entityToUpdate);
//
//      case TABLE_MST_USER:
//        return mstUserDao.update((MstUser) entityToUpdate);
//
//      default:
//        onMissingTable(tableName);
//        return 0;
//    }
//  }
//
//  /**
//   * pat_exam_mainレコードを更新する。<br/>
//   * 旧レコードを論理削除し、新レコードをinsertする。
//   *
//   * @param entityNew 新エンティティ
//   * @param entityOld 旧エンティティ
//   * @return
//   */
//  private int updatePatExamMain(PatExamMain entityNew, PatExamMain entityOld) {
//    PatExamMain pem = new PatExamMain();
//    pem.setExamMainCd(entityOld.getExamMainCd());
//    pem.setIsDel(JournalConvertConstants.LOGICAL_DELETE_FLAG_ON);
//    Timestamp now = new Timestamp(clockWrapper.getClockMillis());
//    pem.setUpDate(now);
//    patExamMainDao.update(pem);
//
//    // 新エンティティはPatExamMainLogicのupdate用のチェックを通っており、reg_dateが設定されていない。
//    // そのため、ここで旧エンティティからreg_dateを引き継がせる。
//    entityNew.setRegDate(entityOld.getRegDate());
//    return patExamMainDao.insert(entityNew);
//  }
//
//  /**
//   * pat_insuranceレコードを更新する。<br/>
//   * 旧レコードを論理削除し、新レコードをinsertする。
//   *
//   * @param entityNew 新エンティティ
//   * @param entityOld 旧エンティティ
//   * @return
//   */
//  private int updatePatInsurance(PatInsurance entityNew, PatInsurance entityOld) {
//    PatInsurance pi = new PatInsurance();
//    pi.setInsurance_cd(entityOld.getInsurance_cd());
//    pi.setIs_del(JournalConvertConstants.LOGICAL_DELETE_FLAG_ON);
//    Timestamp now = new Timestamp(clockWrapper.getClockMillis());
//    pi.setUp_date(String.valueOf(now));
//    patInsuranceDao.update(pi);
//
//    return patInsuranceDao.insert(entityNew);
//    // TODO pat_insuranceの場合は個別処理で登録するので、この処理は通らないはず。
//  }
//
//  /**
//   * レコードを論理削除する。
//   *
//   * @param tableName テーブル名
//   * @param entity    エンティティ
//   * @return 更新件数
//   */
//  @Transactional
//  private int delete(String tableName, Object entity) {
//    Timestamp now = new Timestamp(clockWrapper.getClockMillis());
//
//    switch (tableName) {
//      case TABLE_PAT_MAIN:
//        PatMain pm = (PatMain) entity;
//        pm.setIs_del(JournalConvertConstants.LOGICAL_DELETE_FLAG_ON);
//        pm.setUp_date(String.valueOf(now));
//        return patMainDao.updatePatMain(pm);
//
//      case TABLE_PAT_EXAM_MAIN:
//        PatExamMain pem = (PatExamMain) entity;
//        pem.setIsDel(JournalConvertConstants.LOGICAL_DELETE_FLAG_ON);
//        pem.setUpDate(now);
//        return patExamMainDao.update(pem);
//
//      case TABLE_PAT_UNIQUE:
//        PatUnique pu = (PatUnique) entity;
//        pu.setIs_del(JournalConvertConstants.LOGICAL_DELETE_FLAG_ON);
//        pu.setUp_date(String.valueOf(now));
//        return patUniqueDao.updatePatUnique(pu);
//
//      case TABLE_PAT_OBS_REC:
//        PatObsRec por = (PatObsRec) entity;
//        por.setIsDel(JournalConvertConstants.LOGICAL_DELETE_FLAG_ON);
//        por.setUpDate(now);
//        return patObsRecDao.updatePatObsRec(por);
//
//      case TABLE_PAT_COOP_DETAIL:
//        PatCoopDetail pcd = (PatCoopDetail) entity;
//        pcd.setIsDel(JournalConvertConstants.LOGICAL_DELETE_FLAG_ON);
//        pcd.setUpDate(now);
//        return patCoopDetailDao.update(pcd);
//
//      case TABLE_PAT_INSURANCE:
//        PatInsurance pi = (PatInsurance) entity;
//        pi.setIs_del(JournalConvertConstants.LOGICAL_DELETE_FLAG_ON);
//        pi.setUp_date(String.valueOf(now));
//        return patInsuranceDao.update(pi);
//
//      case TABLE_MST_USER_AUTHENTICATION:
//        // 操作なし。
//        // mst_user_authenticationは論理削除の対象外
//        MstUserAuthentication mua = (MstUserAuthentication) entity;
//        outputDebugLog(mua.getFacilityCd(), "mst_user_authenticationに対して削除で呼出。論理削除がないため削除なし");
//        return -1;
//
//      case TABLE_MST_USER:
//        MstUser mu = (MstUser) entity;
//        mu.setIsDel(JournalConvertConstants.LOGICAL_DELETE_FLAG_ON);
//        return mstUserDao.updateIsDel(mu);
//
//      default:
//        onMissingTable(tableName);
//        return 0;
//    }
//  }
//
//  /**
//   * テーブル名に対応するEntityCreatorServiceオブジェクトを取得する。
//   *
//   * @param tableName テーブル名
//   * @return EntityCreatorServiceオブジェクト
//   */
//  private EntityLogic getEntityLogicByTableName(String tableName) {
//    switch (tableName) {
//      case TABLE_PAT_MAIN:
//        return patMainLogic;
//
//      case TABLE_PAT_EXAM_MAIN:
//        return patExamMainLogic;
//
//      case TABLE_PAT_UNIQUE:
//        return patUniqueLogic;
//
//      case TABLE_PAT_OBS_REC:
//        return patObsRecLogic;
//
//      case TABLE_PAT_COOP_DETAIL:
//        return patCoopDetailLogic;
//
//      case TABLE_PAT_INSURANCE:
//        return patInsuranceLogic;
//
//      case TABLE_MST_USER_AUTHENTICATION:
//        return mstUserAuthenticationLogic;
//
//      case TABLE_MST_USER:
//        return mstUserLogic;
//
//      default:
//        onMissingTable(tableName);
//        return null;
//    }
//  }
//
//  /**
//   * 連携対象外のテーブルがレイアウトで指定された場合の動作を規定する。
//   *
//   * @param tableName テーブル名
//   */
//  private void onMissingTable(String tableName) {
//    // FIXME 現状では、対象外テーブルを後から手動で連携することを想定し、ログを出力して正常終了としている。
//    // レイアウトの設定誤りと判断して連携を失敗させる場合は、ここで例外をthrowすること。
//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage("連携対象外のテーブルが指定されています。 テーブル名:[" + tableName + "]");
//    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
//    eventLogMessage.setInvokeClass(this.getClass().getName());
//    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
//    logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
//  }
}
// del 2021-08-18 #5887:富士通連携設定の構築の対応 孫 end

  //add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 start
  @Override
  @Async
  public void setDataToMongo(SysCoopJournal journal) {
    try {
      Long patId = journal.getPatId();
      PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(patId);
      PatMain patMain = patMainDao.selectById(patId);
      PatUnique patUnique = patUniqueDao.selectById(patId);
      List<PatGroupCustom> patGroupList = patGroupDetailDao.selectPatGroupByPatId(patId);
      PatInfo patInfo = new PatInfo();
      patInfo.setPatMain(patMain);
      patInfo.setPatUnique(patUnique);
      patInfo.setPatPersonalMain(patPersonalMain);
      if (patGroupList != null) {
        patInfo.setPatGroupList(patGroupList);
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
      map.put("className", "jp.co.nikkiso.ntss.coop_api.service.RegisterServiceImpl");
      map.put("methodName", "setDataToMongo");
      map.put("method", request.getMethod());
      map.put("url", request.getUrl());
      map.put("headers", request.getHeaders().toSingleValueMap());
      map.put("requestParameter", request.getBody());
      map.put("status",response.getStatusCode());
      map.put("cost", cost);
      map.put("result",response.getBody());
      EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
      restTemplateEventLogMessage.setLogMessage(toJson(map));
      if (journal != null && !StringUtils.isEmpty(journal.getFacilityCd())) {
        restTemplateEventLogMessage.setFacilityCd(journal.getFacilityCd());
      }
      logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
    }
  }
  //add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 end

  /**
   * 検査結果から感染症の検査結果を登録
   * @param examMainCd 検査結果コード
   */
  private void updateInfectinfo(List<Long> examMainCd) {
	  if (examMainCd == null) {
		  return;
	  }
    try {
        JSONObject jsonBody = new JSONObject();
        jsonBody.put("examMainCd", examMainCd);

      RestTemplate rt = new RestTemplate();
      URI uri = new URI(webApi + "/util/updateInfectinfo");

      // リクエスト作成
      RequestEntity<String> request = RequestEntity
          .post(uri)
          .contentType(MediaType.APPLICATION_JSON)
          .header("SSECCAYEK", "NTSS-NKK-ESM-TDC-YSK")
          .body(jsonBody.toString());
	  // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
      long start = System.currentTimeMillis();
      ResponseEntity<Object> response = rt.exchange(request, Object.class);
      // log start
      long cost = System.currentTimeMillis() - start;
      Map<String, Object> map = new HashMap<>();
      map.put("logType", "RESTTEMPLATE-LOG");
      map.put("className", "jp.co.nikkiso.ntss.coop_api.service.RegisterServiceImpl");
      map.put("methodName", "updateInfectinfo");
      map.put("method", request.getMethod());
      map.put("url", request.getUrl());
      map.put("headers", request.getHeaders().toSingleValueMap());
      map.put("requestParameter", request.getBody());
      map.put("status",response.getStatusCode());
      map.put("cost", cost);
      map.put("result",response.getBody());
      EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
      restTemplateEventLogMessage.setLogMessage(toJson(map));
      logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
    }
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
  }


  /**
   * ジャーナルテーブルの変換処理ステータスを「完了」に更新する。
   *
   * @param ctlNo  ジャーナルの管理番号
   * @param status 変換ステータス
   * @return 更新件数
   */
  private int updateConvStatus(Long ctlNo, AnaResult status) {
    Timestamp now = new Timestamp(clockWrapper.getClockMillis());
    List<Long> ctlNoList = Collections.singletonList(ctlNo);

    // DB更新ログ出力ロジック wangzuo Start
    String tableName = "sys_coop_journal";
    // SQL検索条件
    String inStr = getInStr("ctl_no IN ", ctlNoList);
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(" is_del = '0'\n");
    wheres.append(" AND\n");
    wheres.append(inStr + "\n");

    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(sysCoopJournalDao, tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    // DB更新ログ出力ロジック wangzuo End

    //#8229-外部連携のSQLのロック待ちによりDBの負荷が高くなる 20230406 mod start
    //int updateCount = sysCoopJournalDao.updateConvStatusCompleted(ctlNoList, status.getResult(), now);
    int updateCount = sysCoopJournalDao.updateConvStatusCompleted(JournalConvertUtil.ctlNoListToString(ctlNoList),
      status.getResult(), now);
    //#8229-外部連携のSQLのロック待ちによりDBの負荷が高くなる 20230406 mod end

    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      logCommon.updateLog();
    }
    // DB更新ログ出力ロジック wangzuo End

    // add 2021-04-06 課題No.1:API連動設定:動作条件「処理完了時、処理エラー時、処理スキップ時」を追加 孫 start
    // 事後APIキック機能を呼び出し
    if (updateCount > 0
      && (NtssCoopApiConstants.AnaResult.DONE.getResult().equals(status.getResult())
      || NtssCoopApiConstants.AnaResult.SKIP.getResult().equals(status.getResult())
      || NtssCoopApiConstants.AnaResult.INTERNAL_ERROR.getResult().equals(status.getResult())
      || NtssCoopApiConstants.AnaResult.INTERNAL_ERROR_BY_CARTE.getResult().equals(status.getResult()))) {

      for (Long ctlNoLoop : ctlNoList) {
        SysCoopJournal journal = sysCoopJournalDao.selectByPK(ctlNoLoop);

        CallApiJournalRequest callApiJournalRequest = new CallApiJournalRequest();
        org.springframework.beans.BeanUtils.copyProperties(journal, callApiJournalRequest);
        // mod 2021-06-09 #5278 API連動処理の判定が正しくない wangchen start
        if (NtssCoopApiConstants.AnaResult.DONE.getResult().equals(status.getResult())) {
          callApiJournalRequest.setApiTimingIo(NtssCoopApiConstants.ApiTimingIoStatus.ANA_DONE.getStatus());
        } else if (NtssCoopApiConstants.AnaResult.SKIP.getResult().equals(status.getResult())) {
          callApiJournalRequest.setApiTimingIo(NtssCoopApiConstants.ApiTimingIoStatus.ANA_SKIP.getStatus());
        } else if (NtssCoopApiConstants.AnaResult.INTERNAL_ERROR.getResult().equals(status.getResult())
          || NtssCoopApiConstants.AnaResult.INTERNAL_ERROR_BY_CARTE.getResult().equals(status.getResult())) {
          callApiJournalRequest.setApiTimingIo(NtssCoopApiConstants.ApiTimingIoStatus.ANA_ERROR.getStatus());
        }
        // mod 2021-06-09 #5278 API連動処理の判定が正しくない wangchen end
        callApiJournalRequest.setApiTimingBa(NtssCoopApiConstants.ApiTimingBaStatus.AFTER.getStatus());
        boolean callResult = callApiService.callApiJournal(callApiJournalRequest, journal, null);
        if (!callResult) {
          break;
        }
      }
    }
    // add 2021-04-06 課題No.1:API連動設定:動作条件「処理完了時、処理エラー時、処理スキップ時」を追加 孫 end

    return updateCount;
  }

  /**
   * ジャーナルの変換ステータスを更新する
   * ※レコード単位での更新
   *
   * @param ctlNo   ジャーナルの管理番号
   * @param message メッセージ
   * @param status  変換ステータス
   * @return 更新件数
   */
  private int updateAnaResult(Long ctlNo, String message, AnaResult status) {
    Timestamp now = new Timestamp(clockWrapper.getClockMillis());
    // mod 2021-04-06 課題No.1:API連動設定:動作条件「処理完了時、処理エラー時、処理スキップ時」を追加 孫 start
//    return sysCoopJournalDao.updateAnaResult(ctlNo, status.getResult(), message, now);
    int updateCount = sysCoopJournalDao.updateAnaResult(ctlNo, status.getResult(), message, now);

    // 事後APIキック機能を呼び出し
    if (updateCount > 0
      && (AnaResult.DONE.getResult().equals(status.getResult())
      || AnaResult.SKIP.getResult().equals(status.getResult())
      || AnaResult.INTERNAL_ERROR.getResult().equals(status.getResult())
      || AnaResult.INTERNAL_ERROR_BY_CARTE.getResult().equals(status.getResult()))) {

      SysCoopJournal journal = sysCoopJournalDao.selectByPK(ctlNo);

      CallApiJournalRequest callApiJournalRequest = new CallApiJournalRequest();
      org.springframework.beans.BeanUtils.copyProperties(journal, callApiJournalRequest);
      // mod 2021-06-09 #5278 API連動処理の判定が正しくない wangchen start
      if (AnaResult.DONE.getResult().equals(status.getResult())) {
        callApiJournalRequest.setApiTimingIo(NtssCoopApiConstants.ApiTimingIoStatus.ANA_DONE.getStatus());
      } else if (AnaResult.SKIP.getResult().equals(status.getResult())) {
        callApiJournalRequest.setApiTimingIo(NtssCoopApiConstants.ApiTimingIoStatus.ANA_SKIP.getStatus());
      } else if (AnaResult.INTERNAL_ERROR.getResult().equals(status.getResult())
        || AnaResult.INTERNAL_ERROR_BY_CARTE.getResult().equals(status.getResult())) {
        callApiJournalRequest.setApiTimingIo(NtssCoopApiConstants.ApiTimingIoStatus.ANA_ERROR.getStatus());
      }
      // mod 2021-06-09 #5278 API連動処理の判定が正しくない wangchen end
      callApiJournalRequest.setApiTimingBa(NtssCoopApiConstants.ApiTimingBaStatus.AFTER.getStatus());
      boolean callResult = callApiService.callApiJournal(callApiJournalRequest, journal, null);
//      if (!callResult) {
//        break;
//      }
    }
    return updateCount;
    // mod 2021-04-06 課題No.1:API連動設定:動作条件「処理完了時、処理エラー時、処理スキップ時」を追加 孫 end
  }

  /**
   * ログ出力
   *
   * @param level      {@link LogLevel} ログレベル
   * @param facilityCd 施設コード
   * @param message    ログメッセージ
   */
  private void outputLog(LogLevel level, String facilityCd, String message) {
    EventLogMessage elm = new EventLogMessage();
    elm.setFacilityCd(facilityCd);
    elm.setLogMessage(message);
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
    elm.setInvokeClass(this.getClass().getName());
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
    logService.log(level, elm, null, SERVICE_NAME.FNSI, null);
  }

  /**
   * エラーログ出力
   *
   * @param facilityCd 施設コード
   * @param message    ログメッセージ
   */
  private void outputErrorLog(String facilityCd, String message) {
    outputLog(LogLevel.ERROR, facilityCd, message);
  }

  /**
   * デバッグログ出力
   *
   * @param facilityCd 施設コード
   * @param message    ログメッセージ
   */
  private void outputDebugLog(String facilityCd, String message) {
    outputLog(LogLevel.DEBUG, facilityCd, message);
  }

  // DB更新ログ出力ロジック wangzuo Start

  /**
   * ログ情報設定
   *
   * @return eventLogMessage
   */
  private EventLogMessage getEventLogMessage() {
    EventLogMessage eventLogMessage = new EventLogMessage();
    // サービス名
    eventLogMessage.setServiceName(LoggingConstant.MODULE_NAME.NTSS_COOP_API + "," + SERVICE_NAME.FNSI);
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
  public String getInStr(String fieldInfo, List<Long> inList) {
    StringBuffer inStr = new StringBuffer("");
    inStr.append(fieldInfo);
    inStr.append(" ( ");
    for (Long obj : inList) {
      inStr.append(obj);
      inStr.append(" ,");
    }
    inStr.deleteCharAt(inStr.length() - 1);
    inStr.append(" ) ");
    return String.valueOf(inStr);
  }
  // DB更新ログ出力ロジック wangzuo End

  /**
   * exam_rstの検査結果明細から、実際に登録対象となる明細だけを残す。
   *
   * @param facilityCd 施設コード
   * @param key0 連携先識別子
   * @param jsonMap 登録対象ジャーナルJSON
   * @param layoutExtSetting レイアウト拡張設定
   * @return 登録可能な検査結果明細が1件以上残った場合true
   */
  private boolean filterRegisterableExamResultInfo(String facilityCd, String key0, Map<String, Object> jsonMap,
                                                   LayoutExtSetting layoutExtSetting) {
    Object detailObj = jsonMap.get("detail");
    if (!(detailObj instanceof JSONObject)) {
      return false;
    }

    JSONObject detailJson = (JSONObject) detailObj;
    Object examObj = detailJson.has(EXAM_DETAIL_TABLE) ? detailJson.get(EXAM_DETAIL_TABLE) : null;
    if (!(examObj instanceof JSONArray)) {
      return false;
    }

    JSONArray examResultArray = (JSONArray) examObj;
    boolean convertedByCoopMstConvUtil = isExamItemConvertedByCoopMstConvUtil(layoutExtSetting);
    // Java変換済みの場合はitem_cdがexam_item_cdになっているため、SQL変換前コードとは別扱いにする。
    String codeColumn = convertedByCoopMstConvUtil ? EXAM_ITEM_CD_COLUMN
      : resolveExamItemRegisterColumn(facilityCd, key0);
    List<MstExamItem> mstExamItemList = mstExamItemDao.selectByFacilityCd(facilityCd);

    // 配列から要素を削除するため、末尾から走査する。
    for (int i = examResultArray.length(); i > 0; i--) {
      Object resultObj = examResultArray.get(i - 1);
      if (!(resultObj instanceof JSONObject)) {
        examResultArray.remove(i - 1);
        continue;
      }
      JSONObject resultJson = (JSONObject) resultObj;
      String itemCd = getJsonValue(resultJson, EXAM_DETAIL_ITEM_CD);
      String result = getJsonValue(resultJson, EXAM_DETAIL_RESULT);
      // result(検査結果値)が空の場合も登録対象外
      if (StringUtils.isEmpty(itemCd) || StringUtils.isEmpty(result)
        || !isRegisterableExamItem(mstExamItemList, codeColumn, itemCd)) {
        examResultArray.remove(i - 1);
      }
    }

    setExamResultDataCount(jsonMap, examResultArray.length());
    return examResultArray.length() > 0;
  }

  /**
   * レイアウト設定上、検査コードがCoopMstConvUtilでexam_item_cdに変換済みとなるか判定する。
   *
   * @param layoutExtSetting レイアウト拡張設定
   * @return exam_result_info.item_cdがmst_exam_item変換対象の場合true
   */
  private boolean isExamItemConvertedByCoopMstConvUtil(LayoutExtSetting layoutExtSetting) {
    if (MapUtils.isEmpty(layoutExtSetting) || !layoutExtSetting.containsKey("CoopMstConvUtil")) {
      return false;
    }
    Object coopMstConvUtil = layoutExtSetting.get("CoopMstConvUtil");
    if (StringUtils.isEmpty(coopMstConvUtil)) {
      return false;
    }
    try {
      Map<String, Object> coopMstConvMap = ObjectMapperUtil.castToStringObjectMap(coopMstConvUtil);
      if (MapUtils.isEmpty(coopMstConvMap) || !coopMstConvMap.containsKey(EXAM_LAYOUT_ITEM_CD_KEY)) {
        return false;
      }
      Map<String, Object> itemCdSetting =
        ObjectMapperUtil.castToStringObjectMap(coopMstConvMap.get(EXAM_LAYOUT_ITEM_CD_KEY));
      return !MapUtils.isEmpty(itemCdSetting)
        && "mst_exam_item".equals(String.valueOf(itemCdSetting.get("conv_type")));
    } catch (Exception ex) {
      return false;
    }
  }

  /**
   * Java変換されていない検査コードをmst_exam_itemのどの連携コード列で突合するか決定する。
   *
   * @param facilityCd 施設コード
   * @param key0 連携先識別子
   * @return mst_exam_itemの突合対象列名
   */
  private String resolveExamItemRegisterColumn(String facilityCd, String key0) {
    // 登録SQLと同じ優先順位で、MST/EXAM_ITEMを最優先にする。
    String mstExamItemValue = getEffectiveCoopIniValue(facilityCd, key0, "MST", "EXAM_ITEM");
    String mstExamItemColumn = resolveExamItemColumnByNumber(mstExamItemValue);
    if (!StringUtils.isEmpty(mstExamItemColumn)) {
      return mstExamItemColumn;
    }

    String examinCodePosition = getEffectiveCoopIniValue(facilityCd, key0, "EXAMIN_RECV", "EXAMINCODE_POSITION");
    String examinCodePositionColumn = resolveExamItemColumnByPosition(examinCodePosition);
    if (!StringUtils.isEmpty(examinCodePositionColumn)) {
      return examinCodePositionColumn;
    }

    return IN_HOSPITAL_CD1_COLUMN;
  }

  /**
   * 有効なmst_coop_ini設定値を取得する。
   *
   * @param facilityCd 施設コード
   * @param key0 連携先識別子
   * @param key1 設定キー1
   * @param key2 設定キー2
   * @return is_effectが1の設定値。valueが空の場合はdefault_v。設定がなければ空文字
   */
  private String getEffectiveCoopIniValue(String facilityCd, String key0, String key1, String key2) {
    String normalizedKey0 = normalizeCoopKey0(key0);
    MstCoopIniInfo coopIniInfo = mstCoopIniDao.selectCoopIniInfo(facilityCd, normalizedKey0, key1, key2);
    if (coopIniInfo == null && !StringUtils.isEmpty(normalizedKey0)) {
      coopIniInfo = mstCoopIniDao.selectCoopIniInfo(facilityCd, "", key1, key2);
    }
    if (coopIniInfo == null || !"1".equals(coopIniInfo.getIsEffect())) {
      return "";
    }
    return StringUtils.isEmpty(coopIniInfo.getVal()) ? nullToEmpty(coopIniInfo.getDefaultV()) : coopIniInfo.getVal();
  }

  /**
   * MST/EXAM_ITEMのコード種別番号をmst_exam_itemの連携コード列名に変換する。
   *
   * @param value コード種別番号
   * @return mst_exam_itemの連携コード列名。対応しない場合は空文字
   */
  private String resolveExamItemColumnByNumber(String value) {
    String codeType = nullToEmpty(value).trim();
    if ("3".equals(codeType)) {
      return IN_HOSPITAL_CD3_COLUMN;
    } else if ("2".equals(codeType)) {
      return IN_HOSPITAL_CD2_COLUMN;
    } else if ("1".equals(codeType)) {
      return IN_HOSPITAL_CD1_COLUMN;
    }
    return "";
  }

  /**
   * EXAMIN_RECV/EXAMINCODE_POSITIONの設定値をmst_exam_itemの突合列名に変換する。
   *
   * @param value コード位置設定値
   * @return mst_exam_itemの突合対象列名。対応しない場合は空文字
   */
  private String resolveExamItemColumnByPosition(String value) {
    String codePosition = nullToEmpty(value).trim().toUpperCase(Locale.ROOT);
    if (EXAM_ITEM_CD_COLUMN.toUpperCase(Locale.ROOT).equals(codePosition)) {
      return EXAM_ITEM_CD_COLUMN;
    } else if ("IN_HOSPITAL_CD3".equals(codePosition)) {
      return IN_HOSPITAL_CD3_COLUMN;
    } else if ("IN_HOSPITAL_CD2".equals(codePosition)) {
      return IN_HOSPITAL_CD2_COLUMN;
    } else if ("IN_HOSPITAL_CD".equals(codePosition) || "IN_HOSPITAL_CD1".equals(codePosition)) {
      return IN_HOSPITAL_CD1_COLUMN;
    }
    return "";
  }

  /**
   * 受信した検査コードが、指定列で有効なmst_exam_itemに紐づくか判定する。
   *
   * @param mstExamItemList 検査項目マスタ一覧
   * @param codeColumn 突合対象列名
   * @param itemCd 受信した検査コード
   * @return 登録可能な検査項目に一致する場合true
   */
  private boolean isRegisterableExamItem(List<MstExamItem> mstExamItemList, String codeColumn, String itemCd) {
    if (CollectionUtils.isEmpty(mstExamItemList) || StringUtils.isEmpty(codeColumn) || StringUtils.isEmpty(itemCd)) {
      return false;
    }
    for (MstExamItem mstExamItem : mstExamItemList) {
      if (!isActiveExamItem(mstExamItem)) {
        continue;
      }
      Long examItemCd = mstExamItem.getExamItemCd();
      if (itemCd.equals(getExamItemColumnValue(mstExamItem, codeColumn))) {
        return true;
      }
    }
    return false;
  }

  /**
   * 検査項目マスタが登録対象として有効か判定する。
   *
   * @param mstExamItem 検査項目マスタ
   * @return 表示対象かつ未削除の場合true
   */
  private boolean isActiveExamItem(MstExamItem mstExamItem) {
    return mstExamItem != null && "1".equals(mstExamItem.getIsDisp()) && "0".equals(mstExamItem.getIsDel());
  }

  /**
   * mst_exam_itemから指定列の値を文字列で取得する。
   *
   * @param mstExamItem 検査項目マスタ
   * @param codeColumn 取得対象列名
   * @return 指定列の値。未対応列またはnullの場合は空文字
   */
  private String getExamItemColumnValue(MstExamItem mstExamItem, String codeColumn) {
    if (EXAM_ITEM_CD_COLUMN.equals(codeColumn)) {
      return mstExamItem.getExamItemCd() == null ? "" : String.valueOf(mstExamItem.getExamItemCd());
    } else if (IN_HOSPITAL_CD3_COLUMN.equals(codeColumn)) {
      return nullToEmpty(mstExamItem.getInHospitalCd3());
    } else if (IN_HOSPITAL_CD2_COLUMN.equals(codeColumn)) {
      return nullToEmpty(mstExamItem.getInHospitalCd2());
    } else if (IN_HOSPITAL_CD1_COLUMN.equals(codeColumn)) {
      return nullToEmpty(mstExamItem.getInHospitalCd1());
    }
    return "";
  }

  /**
   * JSONObjectからキーに対応する値を取得する。
   *
   * @param jsonObject 取得元JSON
   * @param key 取得キー。ドット区切りの子要素キーも指定可能
   * @return 取得値。存在しない場合や空値の場合は空文字
   */
  private String getJsonValue(JSONObject jsonObject, String key) {
    if (jsonObject == null || StringUtils.isEmpty(key)) {
      return "";
    }
    if (jsonObject.has(key)) {
      Object value = jsonObject.get(key);
      return isEmptyJsonValue(value) ? "" : String.valueOf(value);
    }
    int dotIndex = key.indexOf(".");
    if (dotIndex > 0) {
      Object child = jsonObject.opt(key.substring(0, dotIndex));
      if (child instanceof JSONObject) {
        return getJsonValue((JSONObject) child, key.substring(dotIndex + 1));
      }
    }
    return "";
  }

  /**
   * JSON値が空として扱う値か判定する。
   *
   * @param value 判定対象値
   * @return null、JSONObject.NULL、空文字の場合true
   */
  private boolean isEmptyJsonValue(Object value) {
    return value == null || JSONObject.NULL.equals(value) || StringUtils.isEmpty(String.valueOf(value));
  }

  /**
   * 検査結果明細の件数をトップレベルのpat_exam_main.data_countに反映する。
   *
   * @param jsonMap 登録対象ジャーナルJSON
   * @param dataCount 検査結果明細件数
   */
  private void setExamResultDataCount(Map<String, Object> jsonMap, int dataCount) {
    Object patExamMainObj = jsonMap.get(EXAM_DETAIL_TABLE);
    if (patExamMainObj instanceof JSONObject) {
      ((JSONObject) patExamMainObj).put("data_count", String.valueOf(dataCount));
    }
  }

  /**
   * journal.key0をmst_coop_ini検索用の文字列に正規化する。
   *
   * @param key0 連携先識別子
   * @return null相当値の場合は空文字、それ以外は文字列表現
   */
  private String normalizeCoopKey0(Object key0) {
    if (key0 == null || JSONObject.NULL.equals(key0)) {
      return "";
    }
    String value = String.valueOf(key0);
    return "null".equals(value) ? "" : value;
  }

  /**
   * null文字列を空文字に変換する。
   *
   * @param value 変換対象文字列
   * @return valueがnullの場合は空文字、それ以外はvalue
   */
  private String nullToEmpty(String value) {
    return value == null ? "" : value;
  }

  // add 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 start
  /**
   * JsonからMapに変換する
   * @param json jsonデータ
   * @param resultMap 結果
   */
  private static void convertJsonToMap(Object json, Map<String, Object> resultMap) {
    if (json instanceof JSONObject) {
      JSONObject jsonObject = ((JSONObject) json);
      Iterator iterator = jsonObject.keySet().iterator();
      while (iterator.hasNext()) {
        String key = convertString(iterator.next());
        Object value = jsonObject.get(key);
        resultMap.put(key, value);
      }
    }
  }
  // add 7391 exam_rst連携で受信した検査項目コード  吉 start
  private Map<String, Object> convertJsonToMapIsNotNull(Object json) {
    Boolean flag = false ;
    Map<String, Object> resultMap = new HashMap<>();
    if (json instanceof JSONObject) {
      JSONObject jsonObject = ((JSONObject) json);
      Iterator iterator = jsonObject.keySet().iterator();
      while (iterator.hasNext()) {
        String key = convertString(iterator.next());
        Object value = jsonObject.get(key);
        if(key.equals("exam_result_info.item_cd") && "".equals(value)){
          flag = true;
        }else{
          resultMap.put(key, value);
        }
      }
    }
    if(flag){
      resultMap = new HashMap<>();
    }
    return resultMap;
  }
  // add 7391 exam_rst連携で受信した検査項目コード  吉 end
  /**
   * String変換
   * @param obj 変換用オブジェクト
   * @return 変換したデータ
   */
  public static String convertString(Object obj) {
    if (obj == null) {
      return "";
    }

    try {
      if (obj instanceof Timestamp) {
        DateFormat sdf = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss.SSS");
        return sdf.format(obj);
      }
    } catch (Exception e) {}

    if ("null".equals(obj.toString())) {
      return "";
    }

    return obj.toString();
  }

  /**
   * getDataKey
   *
   * @param m1
   * @param jsonMap
   * @return getDataKey
   */
  // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod start
//  private Map<String, Object> getDataKey(Map<String, Object> m1 ,Map<String, Object> jsonMap) {
//    return getDetailDataKey(m1, jsonMap, 1, false);
  // #8378-profile連携の患者登録処理でエラーが発生する 周 mod start
  //private Map<String, Object> getDataKey(Map<String, Object> m1 ,Map<String, Object> jsonMap, Map<String, Object> idMap) {
  //  return getDetailDataKey(m1, jsonMap, 1, false, idMap);
  private Map<String, Object> getDataKey(Map<String, Object> m1 ,Map<String, Object> jsonMap, Map<String, Object> idMap, Map<String, Object> paraMap, Map<String, Object> resultJsonMap) {
    return getDetailDataKey(m1, jsonMap, 1, false, idMap, paraMap, resultJsonMap);
    // #8378-profile連携の患者登録処理でエラーが発生する 周 mod end
    // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod end
  }

  /**
   * getDataKeyForDetail
   *
   * @param m1
   * @param jsonMap
   * @return getDataKeyForDetail
   */
  // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod start
  //private Map<String, Object> getDataKeyForDetail(Map<String, Object> m1 ,Map<String, Object> jsonMap) {
  // #8378-profile連携の患者登録処理でエラーが発生する 周 mod start
  //private Map<String, Object> getDataKeyForDetail(Map<String, Object> m1 ,Map<String, Object> jsonMap, Map<String, Object> idMap) {
  private Map<String, Object> getDataKeyForDetail(Map<String, Object> m1 ,Map<String, Object> jsonMap, Map<String, Object> idMap, Map<String, Object> resultJsonMap) {
    // #8378-profile連携の患者登録処理でエラーが発生する 周 mod end
  // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod end
    Map<String, Object> dataKey = new HashMap<String,Object>();
    Map<String, Object> dataPara = new HashMap<String,Object>();
    for (String key : resultJsonMap.keySet()) {
      dataKey.put(key,resultJsonMap.get(key));
    }
    for (String key : m1.keySet()) {
      if (key.startsWith("@")) {
        dataPara.put(key,m1.get(key));
      }
    }
    String tableStr = String.valueOf(m1.get("table"));
    for (String paraKey : dataPara.keySet()) {
      String paraValue = String.valueOf(dataPara.get(paraKey));
      if (paraValue.startsWith("$journal.")) {
        String[] paraValueArr = paraValue.split("\\.");
        String colParaKey = null;
        int len = paraValueArr.length;
        switch (len) {
          // add 2021-08-18 #5887:富士通連携設定の構築の対応 孫 start
          case 2:
            colParaKey = paraValueArr[1];
            break;
          // add 2021-08-18 #5887:富士通連携設定の構築の対応 孫 end
          case 3:
            colParaKey = paraValueArr[2];
            break;
          case 4:
            colParaKey = String.join(".", paraValueArr[2], paraValueArr[3]);
            String[] subParaKeys4 = paraKey.split("\\.");
            String subParaKey4 = subParaKeys4[0] + "Flg";
            dataKey.put(subParaKey4,"0");
            break;
          case 5:
            colParaKey = String.join(".", paraValueArr[2], paraValueArr[3], paraValueArr[4]);
            String[] subParaKeys5 = paraKey.split("\\.");
            String subParaKey5 = subParaKeys5[0] + "Flg";
            dataKey.put(subParaKey5,"0");
            break;
        }
        String tablePara = paraValueArr[1];
        Object tableObj = jsonMap.get(tablePara);
        // add 2021-11-29 #5888:NEC連携ができない(初回指示連携) 孫 start
        if (tableObj == null) {
          continue;
        }
        // add 2021-11-29 #5888:NEC連携ができない(初回指示連携) 孫 end
        for (String colKey : ((JSONObject) tableObj).keySet()) {
          // mod 2021-08-18 #5887:富士通連携設定の構築の対応 孫 start
//          if (colParaKey.equals(colKey)) {
          if (colParaKey != null && colParaKey.equals(colKey)) {
            // mod 2021-08-18 #5887:富士通連携設定の構築の対応 孫 end
            String colValue = String.valueOf(((JSONObject) tableObj).get(colKey));
            switch (paraKey) {
              case "@ctlNo":
                // mod 2021-09-09 #5897:CSI連携ができないの対応 孫 start
//                colValue = colValue.replace("Z","").replace("z","");
                if (!StringUtils.isEmpty(colValue)) {
                  colValue = colValue.replace("Z","").replace("z","");
                }
                // mod 2021-09-09 #5897:CSI連携ができないの対応 孫 end
                break;
            }
            if (paraKey.endsWith("_Date")) {
              colValue = setDateFormat(colValue,"yyyy-MM-dd HH:mi:ss");
            }
// add 2022-02-10 #6995:profile連携で受信した身体情報登録 孫 start
            else if (paraKey.endsWith("_GMTDate")) {
              // ⇒グリニッジ 時間
              colValue = getGMTDate(colValue);
            }
// add 2022-02-10 #6995:profile連携で受信した身体情報登録 孫 end
// add 2021-12-06 #5888:NEC連携ができない(スタッフマスタ連携) 孫 start
            // 暗号化項目か？
            if (paraKey.startsWith(ID_ENCRYP_TO)) {
              colValue = personalInfoEncrypto(colValue);
            } else if (paraKey.startsWith(ID_PASSWORD_ENCODER)) {
              colValue = passwordEncoder(colValue);
            }
// add 2021-12-06 #5888:NEC連携ができない(スタッフマスタ連携) 孫 end
            // add FNSI7519-profile連携（XML）で受信した詳細情報（患者フリーコメント） 周 start
            if(!StringUtils.isEmpty(colValue)
              && (colValue.contains("\"") || colValue.contains("\\") || colValue.contains("\\/"))) {
              String tempColVal = "";
              for(int idx = 0; idx < colValue.length(); idx++) {
                if('"' == colValue.charAt(idx) || '\\' == colValue.charAt(idx) || '/' == colValue.charAt(idx)) {
                  tempColVal = tempColVal + "\\" + colValue.charAt(idx);
                } else {
                  tempColVal = tempColVal + colValue.charAt(idx);
                }
              }
              colValue = tempColVal;
            }
            // add FNSI7519-profile連携（XML）で受信した詳細情報（患者フリーコメント） 周 end
            dataKey.put(paraKey,colValue);
            break;
          }
        }
      }
// add 2021-09-14 #5897:CSI連携ができないの対応 孫 start
      else {
        // [$journal.]以外の場合、定数を設定する
        dataKey.put(paraKey, paraValue);
      }
// add 2021-09-14 #5897:CSI連携ができないの対応 孫 end
    }
    for (String key : idMap.keySet()) {
      if (!StringUtils.isEmpty(idMap.get(key))) {
    	  // @ctlNoはsys_coop_jounal.ctl_noよりもlayoutで設定されている値を優先する
    	  if(ID_CTL_NO.equals(key) && dataKey.containsKey(ID_CTL_NO)) {
    		  continue;
    	  }
        dataKey.put(key,idMap.get(key));
      }
    }
    // #8378-profile連携の患者登録処理でエラーが発生する 周 add start
    Map<String,Object> paraMap = new HashMap<>();
    Map<String, Object> returnMap = getParaMap(tableStr,dataKey, paraMap);
    // #8378-profile連携の患者登録処理でエラーが発生する 周 add end

// add 2022-12-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    // @coopVersionと@key0が['']の場合、returnMapを追加する
    if (!returnMap.containsKey(ID_KEY0) && idMap.containsKey(ID_KEY0)) {
      returnMap.put(ID_KEY0,idMap.get(ID_KEY0));
    }
    if (!returnMap.containsKey(ID_COOP_VERSION) && idMap.containsKey(ID_COOP_VERSION)) {
      returnMap.put(ID_COOP_VERSION,idMap.get(ID_COOP_VERSION));
    }
// add 2022-12-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

    return returnMap;
  }

  /**
   * getDetailDataKey
   *
   * @param m1
   * @param jsonMap
   * @param index
   * @param flg 追加と更新の場合：true  検索の場合：false
   * @return getDetailDataKey
   */
  // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod start
  //private Map<String, Object> getDetailDataKey(Map<String, Object> m1 ,Map<String, Object> jsonMap, int index, boolean flg) {
  // #8378-profile連携の患者登録処理でエラーが発生する 周 mod start
  //private Map<String, Object> getDetailDataKey(Map<String, Object> m1 ,Map<String, Object> jsonMap, int index, boolean flg, Map<String, Object> idMap) {
  private Map<String, Object> getDetailDataKey(Map<String, Object> m1 ,Map<String, Object> jsonMap, int index,
                                               boolean flg, Map<String, Object> idMap, Map<String,Object> paraMap, Map<String, Object> resultJsonMap) {
    // #8378-profile連携の患者登録処理でエラーが発生する 周 mod end
  // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod end

    // add 2021-11-29 #5888:NEC連携ができない(初回指示連携) 孫 start
    // detail場合、detail以外項目の内容を取得する。
    // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod start
    //Map<String, Object> dataKey = getDataKeyForDetail(m1, jsonMap);
    // #8378-profile連携の患者登録処理でエラーが発生する 周 mod start
    //Map<String, Object> dataKey = getDataKeyForDetail(m1, jsonMap, idMap);
    Map<String, Object> dataKey = getDataKeyForDetail(m1, jsonMap, idMap, resultJsonMap);
    // #8378-profile連携の患者登録処理でエラーが発生する 周 mod end
    // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod end
    // add 2021-11-29 #5888:NEC連携ができない(初回指示連携) 孫 end
//    Map<String, Object> dataKey = new HashMap<String,Object>();
    Map<String, Object> dataPara = new HashMap<String,Object>();
//    for (String key : resultJsonMap.keySet()) {
//      dataKey.put(key,resultJsonMap.get(key));
//    }
    for (String key : m1.keySet()) {
      if (key.startsWith("@")) {
        dataPara.put(key,m1.get(key));
      }
    }
    Object detailObj = jsonMap.get("detail");
    String tableStr = String.valueOf(m1.get("table"));
    // add 2021-11-29 #5888:NEC連携ができない(初回指示連携) 孫 start
    // mod 2022-4-27 #7353 7352 :複数患者データ取り込みでエラー発生 周　start
    // mod 7346 profile連携（拡張）の取り込みでエラー発生  吉 start
    // if (null == detailObj || (!(((JSONObject) detailObj).keySet().contains(tableStr)))) {
    if (null == detailObj || (null != detailObj && !(((JSONObject) detailObj).keySet().contains(tableStr)))) {
    // mod 7346 profile連携（拡張）の取り込みでエラー発生  吉 start
      return dataKey;
    }
    // mod 2022-4-27 #7353 7352 :複数患者データ取り込みでエラー発生 周　end
    // add 2021-11-29 #5888:NEC連携ができない(初回指示連携) 孫 end
    Object tableObj = ((JSONObject) detailObj).get(tableStr);
    if (tableObj instanceof JSONArray) {
      JSONArray array = (JSONArray) tableObj;
      int tempIndex = 0;
      for (Object obj : array) {
        if (tempIndex == index) {
          for (String paraKey : dataPara.keySet()) {
            String paraValue = String.valueOf(dataPara.get(paraKey));
// add 2021-11-05 #5904:日機装連携ができない(患者プロファイル) 孫 start
            // [$journal.]以外の場合、定数を設定する
            if (!paraValue.startsWith("$journal.")) {
              dataKey.put(paraKey, paraValue);
              continue;
            }
// add 2021-11-05 #5904:日機装連携ができない(患者プロファイル) 孫 end
            String[] paraValueArr = paraValue.split("\\.");
            String colParaKey = null;
            int len = paraValueArr.length;
            switch (len) {
              // add 2021-08-18 #5887:富士通連携設定の構築の対応 孫 start
              case 2:
                colParaKey = paraValueArr[1];
                break;
              case 3:
                colParaKey = paraValueArr[2];
                break;
              // add 2021-08-18 #5887:富士通連携設定の構築の対応 孫 end
              case 4:
                colParaKey = paraValueArr[3];
                break;
              case 5:
                colParaKey = String.join(".", paraValueArr[3], paraValueArr[4]);
                String[] subParaKeys5 = paraKey.split("\\.");
                String subParaKey5 = subParaKeys5[0] + "Flg";
                dataKey.put(subParaKey5,"0");
                break;
              case 6:
                colParaKey = String.join(".", paraValueArr[3], paraValueArr[4], paraValueArr[5]);
                String[] subParaKeys6 = paraKey.split("\\.");
                String subParaKey6 = subParaKeys6[0] + "Flg";
                dataKey.put(subParaKey6,"0");
                break;
            }
            for (String colKey : ((JSONObject) obj).keySet()) {
              // mod 2021-08-18 #5887:富士通連携設定の構築の対応 孫 start
//              if (colParaKey.equals(colKey)) {
              if (colParaKey != null && colParaKey.equals(colKey)) {
                // mod 2021-08-18 #5887:富士通連携設定の構築の対応 孫 end
                String colValue = String.valueOf(((JSONObject) obj).get(colKey));
                // add FNSI7519-profile連携（XML）で受信した詳細情報（患者フリーコメント） 周 start
                // change for json
                if(!StringUtils.isEmpty(colValue)
                  && (colValue.contains("\"") || colValue.contains("\\") || colValue.contains("\\/"))) {
                  String tempColVal = "";
                  for(int idx = 0; idx < colValue.length(); idx++) {
                    if('"' == colValue.charAt(idx) || '\\' == colValue.charAt(idx) || '/' == colValue.charAt(idx)) {
                      tempColVal = tempColVal + "\\" + colValue.charAt(idx);
                    } else {
                      tempColVal = tempColVal + colValue.charAt(idx);
                    }
                  }
                  colValue = tempColVal;
                }
                // add FNSI7519-profile連携（XML）で受信した詳細情報（患者フリーコメント） 周 end
                switch (paraKey) {
                  case "@ctlNo":
                    // mod 2021-09-09 #5897:CSI連携ができないの対応 孫 start
//                    colValue = colValue.replace("Z","").replace("z","");
                    if (!StringUtils.isEmpty(colValue)) {
                      colValue = colValue.replace("Z","").replace("z","");
                    }
                    // mod 2021-09-09 #5897:CSI連携ができないの対応 孫 end
                    break;
                }
                if (paraKey.endsWith("_Date")) {
                  if (!StringUtils.isEmpty(colValue)) {
                    colValue = setDateFormat(colValue,"yyyy-MM-dd HH:mi:ss");
                  }
                }
                else if (paraKey.endsWith("_GMTDate")) {
                  // ⇒グリニッジ 時間
                  colValue = getGMTDate(colValue);
                }
// add 2021-12-06 #5888:NEC連携ができない(スタッフマスタ連携) 孫 start
                // 暗号化項目か？
                if (paraKey.startsWith(ID_ENCRYP_TO)) {
                  colValue = personalInfoEncrypto(colValue);
                } else if (paraKey.startsWith(ID_PASSWORD_ENCODER)) {
                  colValue = passwordEncoder(colValue);
                }
// add 2021-12-06 #5888:NEC連携ができない(スタッフマスタ連携) 孫 end
                dataKey.put(paraKey,colValue);
                break;
              }
            }
          }
          break;
        }
        tempIndex = tempIndex + 1;
      }
    }

    if (flg == true) {
      boolean nullFlg = true;
      for (String key : dataKey.keySet()) {
        if (!StringUtils.isEmpty(dataKey.get(key))) {
          nullFlg = false;
          break;
        }
      }
      if (nullFlg == true) {
        return null;
      }
    }

    for (String key : idMap.keySet()) {
      if (!StringUtils.isEmpty(idMap.get(key))) {
        dataKey.put(key,idMap.get(key));
      }
    }
    // #8378-profile連携の患者登録処理でエラーが発生する 周 mod start
    //Map<String, Object> returnMap = getParaMap(tableStr,dataKey);
    Map<String, Object> returnMap = getParaMap(tableStr,dataKey, paraMap);
    // #8378-profile連携の患者登録処理でエラーが発生する 周 mod end
    return returnMap;
  }

  /**
   * getDetailCount
   *
   * @param list
   * @param jsonMap
   * @return getDetailCount
   */
  private int getDetailCount(List<Object> list ,Map<String, Object> jsonMap) {
    int count = 0;
    Object detailObj = jsonMap.get("detail");
    if (detailObj != null) {
      for (Object obj1 : list) {
        if (obj1 instanceof Map) {
          Map<String, Object> m1 = ObjectMapperUtil.castToStringObjectMap(obj1);
          // add 2021-11-29 #5888:NEC連携ができない(初回指示連携) 孫 start
          // josn項目を更新するの場合、obj1のcrudがS以外場合、tableの内容より、データの明細件数を取得する。
          // Sの場合、次のデータを処理する
          String crud = String.valueOf(m1.get("crud"));
          if (StringUtils.isEmpty(crud) || "S".equals(crud)) {
            continue;
          }
          // add 2021-11-29 #5888:NEC連携ができない(初回指示連携) 孫 end
          String tableStr = String.valueOf(m1.get("table"));
          // mod 2021-09-01 #5887:富士通連携設定の構築の対応 孫 start
          if (detailObj instanceof JSONObject) {
            JSONObject testObject = (JSONObject)detailObj;
            if (!testObject.keySet().contains(tableStr)) {
              return count;
            }
          } else {
            throw new NtssException("外部連携用ジャーナルの臨時内容[temp_content]のdetailの内容はJson形式ではありません。");
          }
          // mod 2021-09-01 #5887:富士通連携設定の構築の対応 孫 end
          Object tableObj = ((JSONObject) detailObj).get(tableStr);
          if (tableObj instanceof JSONArray) {
            JSONArray array = (JSONArray) tableObj;
            switch (tableStr) {
              case "pat_insurance":
                for (int i = 0; i < array.length(); i++) {
                  if (!StringUtils.isEmpty(array.getJSONObject(i).get("ctl_no"))) {
                    count = count + 1;
                  } else {
                    break;
                  }
                }
                break;
              default:
                count = array.length();
                break;
            }
            break;
          }
        }
      }
    }
    return count;
  }

  /**
   * isDetail
   *
   * @param list
   * @return isDetail
   */
  private boolean isDetail(List<Object> list) {
    boolean flg = false;
    for (Object obj1 : list) {
      if (obj1 instanceof Map) {
        Map<String, Object> m1 = ObjectMapperUtil.castToStringObjectMap(obj1);
        for (String key : m1.keySet()) {
          if (key.startsWith("@")) {
            String value = String.valueOf(m1.get(key));
            String[] arr = value.split("\\.");
            if ("$journal".equals(arr[0])) {
              if ("detail".equals(arr[1])) {
                flg = true;
                break;
              }
            }
          }
        }
      }
    }
    return flg;
  }

  /**
     * isExecute
     *
     * @param m1
     * @param jsonMap
     * @return flg
     */
  private boolean isExecute(Map<String, Object> m1 ,Map<String, Object> jsonMap) {
    String kind = String.valueOf(m1.get("kind"));
    if ("0".equals(kind)) {
      return true;
    }
    if ("1".equals(kind)) {
      String judgeAll = String.valueOf(m1.get("judge"));
      return isExecuteForDetail(kind, judgeAll, jsonMap);
    }
    return true;
  }

  /**
     * isExecuteForDetail
     *
     * @param kind
     * @param judgeAll
     * @param jsonMap
     * @return flg
     */
  private boolean isExecuteForDetail(String kind, String judgeAll, Map<String, Object> jsonMap) {
// del 2021-11-26 #5888:NEC連携ができない(初回指示連携) 孫 start
//    boolean flg = false;
// del 2021-11-26 #5888:NEC連携ができない(初回指示連携) 孫 end
//    String kind = String.valueOf(m1.get("kind"));
    if ("0".equals(kind)) {
      return true;
    }

    if ("1".equals(kind)) {
// mod 2021-11-26 #5888:NEC連携ができない(初回指示連携) 孫 start
//      boolean valueFlg = false;
//// del 2021-08-30 #5887:富士通連携設定の構築の対応 孫 start
////      String table = String.valueOf(m1.get("table"));
//// del 2021-08-30 #5887:富士通連携設定の構築の対応 孫 end
//      String judge = String.valueOf(m1.get("judge"));
//// del 2021-08-30 #5887:富士通連携設定の構築の対応 孫 start
////      Object tableObj = jsonMap.get(table);
//// del 2021-08-30 #5887:富士通連携設定の構築の対応 孫 end
//      String judgeAll = String.valueOf(m1.get("judge"));
      String[] judgeList = judgeAll.split(",");
      for(String judge : judgeList) {
        boolean valueFlg = false;
        boolean flg = false;
// mod 2021-11-26 #5888:NEC連携ができない(初回指示連携) 孫 end
        String[] judgeArr = judge.split("\\#", -1);
        String[] preJudgeArr = judgeArr[0].split("\\.");
        String preJudge = null;
        int len = preJudgeArr.length;
        // add 2021-08-30 #5887:富士通連携設定の構築の対応 孫 start
        if (len < 3) {
          throw new NtssException("judgeの設定不正。[" + judge + "]のフォーマットは[$journal.[テーブル].[項目]]です。");
        }
        String table = preJudgeArr[1];
        Object tableObj = jsonMap.get(table);
        if (tableObj == null) {
          throw new NtssException("judgeの設定不正。[" + judge + "]のtable[" + table + "]関連したデータが無し。");
        }
        // add 2021-08-30 #5887:富士通連携設定の構築の対応 孫 end
        switch (len) {
          case 3:
            preJudge = preJudgeArr[2];
            break;
          case 4:
            preJudge = String.join(".", preJudgeArr[2], preJudgeArr[3]);
            break;
          case 5:
            preJudge = String.join(".", preJudgeArr[2], preJudgeArr[3], preJudgeArr[4]);
            break;
        }
        String colValue = null;

        for (String colKey : ((JSONObject) tableObj).keySet()) {
          // mod 2021-08-18 #5887:富士通連携設定の構築の対応 孫 start
//        if (preJudge.equals(colKey)) {
          if (preJudge != null && preJudge.equals(colKey)) {
            // mod 2021-08-18 #5887:富士通連携設定の構築の対応 孫 end
            colValue = String.valueOf(((JSONObject) tableObj).get(colKey));
            valueFlg = true;
            break;
          }
        }
       // del 2023-09-01 #9757:NKK連携 profile（XML） 生存情報がない限り患者の登録が行われな ljg start
       //        if (valueFlg == false) {
       //          return false;
       //        }
       // del 2023-09-01 #9757:NKK連携 profile（XML） 生存情報がない限り患者の登録が行われな ljg end
        switch (judgeArr[1]) {
          case "=":
            if ((colValue != null && colValue.equals(String.valueOf(judgeArr[2])))
              || ((colValue == null || "".equals(colValue)) && (judgeArr[2] == null || judgeArr[2].isEmpty()))) {
              flg = true;
            }
            break;
          case ">":
            if (colValue != null && !"".equals(colValue) && judgeArr[2] != null && !"".equals(judgeArr[2])
              && Integer.valueOf(colValue) > Integer.valueOf(judgeArr[2])) {
              flg = true;
            }
            break;

          case "<":
            if (colValue != null && !"".equals(colValue) && judgeArr[2] != null && !"".equals(judgeArr[2])
              && Integer.valueOf(colValue) < Integer.valueOf(judgeArr[2])) {
              flg = true;
            }
            break;

          case ">=":
            if (colValue != null && !"".equals(colValue) && judgeArr[2] != null && !"".equals(judgeArr[2])
              && Integer.valueOf(colValue) >= Integer.valueOf(judgeArr[2])) {
              flg = true;
            }
            break;

          case "<=":
            if (colValue != null && !"".equals(colValue) && judgeArr[2] != null && !"".equals(judgeArr[2])
              && Integer.valueOf(colValue) <= Integer.valueOf(judgeArr[2])) {
              flg = true;
            }
            break;

          case "!=":
          case "<>":
            if ((colValue != null && !colValue.equals(String.valueOf(judgeArr[2])))
              || ((colValue == null || "".equals(colValue)) && judgeArr[2] != null && !judgeArr[2].isEmpty())) {
              flg = true;
            }
            break;

          default:
            throw new NtssException("judgeの設定不正。[" + judge + "]に[=、>、<、>=、<=、!=、<>]以外内容を設定しました。");
        }
// mod 2021-11-26 #5888:NEC連携ができない(初回指示連携) 孫 start
//      }
//      return flg;
        // いずれかの条件が一致しない場合、直接に戻ります。
        if (flg == true) {
          continue;
        } else {
          return false;
        }
      }
    }
    return true;
// mod 2021-11-26 #5888:NEC連携ができない(初回指示連携) 孫 end
  }

  /**
   * isDetailExecute
   *
   * @param m1
   * @param jsonMap
   * @param index
   * @return flg
   */
  private boolean isDetailExecute(Map<String, Object> m1 ,Map<String, Object> jsonMap, int index) {
// del 2021-11-26 #5888:NEC連携ができない(初回指示連携) 孫 start
//    boolean flg = false;
// del 2021-11-26 #5888:NEC連携ができない(初回指示連携) 孫 end
    String kind = String.valueOf(m1.get("kind"));
    if ("0".equals(kind)) {
      return true;
    }

    if ("1".equals(kind)) {
// mod 2021-11-26 #5888:NEC連携ができない(初回指示連携) 孫 start
//      boolean valueFlg = false;
//// del 2021-08-30 #5887:富士通連携設定の構築の対応 孫 start
////      String table = String.valueOf(m1.get("table"));
//// del 2021-08-30 #5887:富士通連携設定の構築の対応 孫 end
//      String judge = String.valueOf(m1.get("judge"));
//// del 2021-08-30 #5887:富士通連携設定の構築の対応 孫 start
////      Object detailObj = jsonMap.get("detail");
////      Object tableObj = ((JSONObject) detailObj).get(table);
//// del 2021-08-30 #5887:富士通連携設定の構築の対応 孫 end
      String judgeAll = String.valueOf(m1.get("judge"));
      String[] judgeList = judgeAll.split(",");
      // judge再作成
      String judgeHead = "";
      String judgeDetail = "";
      for (String judge : judgeList) {
        if (judge.startsWith("$journal.detail.")) {
          if (StringUtils.isEmpty(judgeDetail)) {
            judgeDetail = judge;
          } else {
            judgeDetail = judgeDetail + "," + judge;
          }
        } else {
          if (StringUtils.isEmpty(judgeHead)) {
            judgeHead = judge;
          } else {
            judgeHead = judgeHead + "," + judge;
          }
        }
      }
      // add 2021-08-18 #5887:富士通連携設定の構築の対応 孫 start
      // judge項目がdetail以外の項目場合、isExecuteForDetailを呼び出し
      if (!StringUtils.isEmpty(judgeHead)) {
        boolean headFlag = isExecuteForDetail(kind, judgeHead ,jsonMap);
        if (false == headFlag) {
          return false;
        }
      }

      // judgeList再作成する
      if (StringUtils.isEmpty(judgeDetail)) {
        return true;
      }
      judgeList = judgeDetail.split(",");
      // add 2021-08-18 #5887:富士通連携設定の構築の対応 孫 end
      for(String judge : judgeList) {
        boolean valueFlg = false;
        boolean flg = false;
// mod 2021-11-26 #5888:NEC連携ができない(初回指示連携) 孫 end
        String[] judgeArr = judge.split("\\#", -1);
        String[] preJudgeArr = judgeArr[0].split("\\.");
        String colName = null;
        int len = preJudgeArr.length;
        // mod 2021-08-30 #5887:富士通連携設定の構築の対応 孫 start
        if (len < 4) {
          throw new NtssException("detailのjudgeの設定不正。[" + judge + "]のフォーマットは[$journal.detail.[テーブル].[項目].[子項目].[孫項目]]です。");
        }
        String table = preJudgeArr[2];
        Object detailObj = jsonMap.get("detail");
        Object tableObj = ((JSONObject) detailObj).get(table);
        if (tableObj == null) {
          throw new NtssException("judgeの設定不正。[" + judge + "]のtable[" + table+ "]関連したデータが無し。");
        }
        // mod 2021-08-30 #5887:富士通連携設定の構築の対応 孫 end
        switch (len) {
          case 4:
            colName = preJudgeArr[3];
            break;
          case 5:
            colName = String.join(".", preJudgeArr[3], preJudgeArr[4]);;
            break;
          case 6:
            colName = String.join(".", preJudgeArr[3], preJudgeArr[4], preJudgeArr[5]);;
            break;
        }
        String colValue = null;
        if (tableObj instanceof JSONArray) {
          JSONArray array = (JSONArray) tableObj;
          int tempIndex = 0;
          for (Object obj : array) {
            if (tempIndex == index) {
              for (String colKey : ((JSONObject) obj).keySet()) {
                // mod 2021-08-18 #5887:富士通連携設定の構築の対応 孫 start
  //              if (colName.equals(colKey)) {
                if (colName != null && colName.equals(colKey)) {
                  // mod 2021-08-18 #5887:富士通連携設定の構築の対応 孫 end
                  colValue = String.valueOf(((JSONObject) obj).get(colKey));
                  valueFlg = true;
                  break;
                }
              }
              break;
            }
            tempIndex = tempIndex + 1;
          }
        }

        if (valueFlg == false) {
          return false;
        }

        switch (judgeArr[1]) {
          case "=":
            if (colValue.equals(String.valueOf(judgeArr[2]))) {
              flg = true;
            }
            break;
          case ">":
            if (Integer.valueOf(colValue) > Integer.valueOf(judgeArr[2])) {
              flg = true;
            }
            break;

          case "<":
            if (Integer.valueOf(colValue) < Integer.valueOf(judgeArr[2])) {
              flg = true;
            }
            break;

          case ">=":
            if (Integer.valueOf(colValue) >= Integer.valueOf(judgeArr[2])) {
              flg = true;
            }
            break;

          case "<=":
            if (Integer.valueOf(colValue) <= Integer.valueOf(judgeArr[2])) {
              flg = true;
            }
            break;

          case ("!="):
          case ("<>"):
            if (!colValue.equals(String.valueOf(judgeArr[2]))) {
              flg = true;
            }
            break;

          default:
            throw new NtssException("judgeの設定不正。[" + judge + "]に[=、>、<、>=、<=、!=、<>]以外内容を設定しました。");
        }
// mod 2021-11-26 #5888:NEC連携ができない(初回指示連携) 孫 start
//    }
//    return flg;
        // いずれかの条件が一致しない場合、直接に戻ります。
        if (flg == true) {
          continue;
        } else {
          return false;
        }
      }
    }
    return true;
// mod 2021-11-26 #5888:NEC連携ができない(初回指示連携) 孫 end
  }

  /**
   * setIdMap
   *
   * @param facilityCd
   * @param list
   * @param jsonMap
   * @param idMap
   * @param coopCd
   * @param coopCdIndex
   * @param coopVersion
   */
  // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod start
  //private void setIdMap(String facilityCd, List<Object> list, Map<String, Object> jsonMap){
  private void setIdMap(String facilityCd, List<Object> list, Map<String, Object> jsonMap, Map<String, Object> idMap, String coopCd, String coopCdIndex, String coopVersion){
  // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod end
    for (Object obj : list) {
      if (obj instanceof Map) {
        Map<String, Object> map = ObjectMapperUtil.castToStringObjectMap(obj);
        String tableName = String.valueOf(map.get("table"));
        switch (tableName) {
          case TABLE_PAT_PERSONAL_MAIN:
            // mod 6915 存在しない患者の検査結果取り込み時にエラーになる 吉 start
            // if (idMap.get(ID_PAT_ID) == null) {
            if(idMap.get(ID_HOSP_PAT_ID) != null){
              // mod 6915 存在しない患者の検査結果取り込み時にエラーになる 吉 end
              String hospPatId = null;
              Long patId = null;
              Object ppmObj = jsonMap.get(tableName);
              if (ppmObj instanceof JSONObject) {
                JSONObject jsonObject = ((JSONObject) ppmObj);
                Iterator iterator = jsonObject.keySet().iterator();
                while (iterator.hasNext()) {
                  String key = convertString(iterator.next());
                  if ("hosp_pat_id".equals(key)) {
                    Object value = jsonObject.get(key);
                    hospPatId = String.valueOf(value);
                    if (!StringUtils.isEmpty(hospPatId)) {
// mod 2021-12-16 #5888:NEC-iS連携ができない(患者プロファイル(profile)の受信部分) 孫 start
//                      idMap.put(ID_HOSP_PAT_ID,hospPatId);
                      // mod #8111 コンバートデータの患者の過去のrep_dial連携の内容が出力されない 王永吉 start
//                      // 患者番号（連携用）の先頭の0を削除
//                      idMap.put(ID_HOSP_PAT_ID,hospPatId.replaceFirst("^0*", ""));
                      idMap.put(ID_HOSP_PAT_ID,hospPatId);
                      // mod #8111 コンバートデータの患者の過去のrep_dial連携の内容が出力されない 王永吉 end
// mod 2021-12-16 #5888:NEC-iS連携ができない(患者プロファイル(profile)の受信部分) 孫 end
                      // 患者IDを取得する。
                      PatPersonalMain ppm = patPersonalMainDao.selectPatInfoByHospPatId(facilityCd, hospPatId);
                      if (ppm != null) {
                        patId = ppm.getPat_id();
                      }
                    }
                    break;
                  }
                }
              }
              idMap.put(ID_PAT_ID,patId);
            }
            break;
          case TABLE_MST_PERSONAL_USER:
            // 利用者マスタ(mst_personal_user.in_hospital_cd_1を取得)
            String inHospitalCd1 = null;
            Long userId = null;
            Object mpuObj = jsonMap.get(tableName);
            if (mpuObj instanceof JSONObject) {
              JSONObject jsonObject = ((JSONObject) mpuObj);
              Iterator iterator = jsonObject.keySet().iterator();
              while (iterator.hasNext()) {
                String key = convertString(iterator.next());
                if ("in_hospital_cd_1".equals(key)) {
                  Object value = jsonObject.get(key);
                  inHospitalCd1 = String.valueOf(value);
                  if (!StringUtils.isEmpty(inHospitalCd1)) {
                    MstPersonalUser mpu = mstPersonalUserDao.selectByInHospitalCd1(facilityCd, inHospitalCd1);
                    if (mpu != null) {
                      userId = mpu.getUserId();
                    }
                  }
                  break;
                }
              }
            }
            idMap.put(ID_USER_ID,userId);
            break;
          case TABLE_ORD_MAIN:
            if (idMap.get(ID_ORD_NO) == null && idMap.get(ID_PAT_ID) != null) {
              Long ordNo = null;
              // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod start
//              OrdMain om = ordMainDao.selectLastByFacilityCd(facilityCd);
//              if (om != null) {
//                ordNo = om.getOrdNo();
//              }
              Long patId = Long.parseLong(idMap.get(ID_PAT_ID).toString());
              // #7175-連携エッジ内のファイル管理 周 mod start
              //String date = ((JSONObject)(jsonMap.get("const"))).get("date_yyyymmdd").toString();
              String date = "";
              if(((JSONObject)(jsonMap.get("const"))).has("date_yyyymmdd")) {
                date = ((JSONObject)(jsonMap.get("const"))).get("date_yyyymmdd").toString();
              } else {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
                Date today = new Date();
                date = sdf.format(today);
              }
              // #7175-連携エッジ内のファイル管理 周 mod end
              List<OrdMainTreatDate> omList = new ArrayList<OrdMainTreatDate>();

              //透析オーダ受け
              if(coopCd.equals(CoopCdConstant.ORD_DIAL)) {
                String indTreatmentName = "";
                if (jsonMap.get("ord_main") != null) {
                  if(((JSONObject)(jsonMap.get("ord_main"))).has("ind_treatment_name")) {
                    indTreatmentName = ((JSONObject)(jsonMap.get("ord_main"))).get("ind_treatment_name").toString();
                  }
                }
                if(coopCdIndex.equals("M")) {
                  //投薬オーダ受け
                  omList = ordMainDao.selectByPatIdAndTreatDateMediInfo(facilityCd, patId, date, coopCd, coopVersion, indTreatmentName);
                }else{
                  //透析オーダ受け
                  omList = ordMainDao.selectByPatIdAndTreatDateOrdMain(facilityCd, patId, date, coopCd, coopCdIndex, coopVersion, indTreatmentName);
                }
              }else{
                omList = ordMainDao.selectByPatIdAndTreatDate(facilityCd, patId, date, date);
              }

              if(null != omList && !omList.isEmpty()) {
                ordNo = omList.get(0).getOrdNo();
              }
              // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod end
              idMap.put(ID_ORD_NO,ordNo);
            }
            break;
        }
        break;
      }
    }
  }

  /**
   * insertOrdCoopNo
   *
   * @param rm
   * @param jsonMap
   */
  // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod start
  //private void insertOrdCoopNo(ResultMap rm, Map<String, Object> jsonMap){
  private void insertOrdCoopNo(ResultMap rm, Map<String, Object> jsonMap, Map<String, Object> idMap){
  // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod end
// add 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    // 連携版番号
    String coopVersion = "";
    if (idMap.containsKey(ID_COOP_VERSION)) {
      coopVersion = StringUtils.isEmpty(idMap.get(ID_COOP_VERSION))?"":String.valueOf(idMap.get(ID_COOP_VERSION));
    }
// add 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
// add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    // 電子カルテ種別
    String key0 = "";
    if (idMap.containsKey(ID_KEY0)) {
      key0 = StringUtils.isEmpty(idMap.get(ID_KEY0))?"":String.valueOf(idMap.get(ID_KEY0));
    }
// add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    boolean isExist = false;
    for (String tableName : jsonMap.keySet()) {
      if("ord_coop_no".equals(tableName)) {
        Object ocnObj = jsonMap.get(tableName);
        if (ocnObj instanceof JSONObject) {
          JSONObject jsonObject = ((JSONObject) ocnObj);
          Iterator iterator = jsonObject.keySet().iterator();
          while (iterator.hasNext()) {
            String key = convertString(iterator.next());
            if ("coop_ord_no".equals(key)) {
              isExist = true;
              break;
            }
          }
        }
        break;
      }
    }
    if (isExist == false) {
      Timestamp now = new Timestamp(clockWrapper.getClockMillis());
      // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod start
      //String coopOrdNo = getCoopOrdNo(rm);
      // mod #7047 GX連携用sys_coop_noでcoop_ord_cdが重複するデータが存在する 2022-12-09 孟堅 start
      // String coopOrdNo = getCoopOrdNo(rm, idMap);
      String coopOrdNo =null;
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//      if (mstCoopIniService.validateCoopByFacilityCd(MstCoopIniConstant.CoopIniMemo.F_HOSP.getResult(),(String) idMap.get(ID_FACILITY_CD) )) {
      if (Key0Constant.GX.equals(key0)) {
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
// mod 2023-01-12 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//        coopOrdNo =ordCoopNoService.getReceiveCoopOrdNo(rm,idMap,MstCoopIniConstant.CoopIniMemo.F_HOSP);
        coopOrdNo =ordCoopNoService.getReceiveCoopOrdNo(rm,idMap, Key0Constant.GX);
// mod 2023-01-12 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
      } else {
        coopOrdNo = getCoopOrdNo(rm, idMap);
      }
      // mod #7047 GX連携用sys_coop_noでcoop_ord_cdが重複するデータが存在する 2022-12-09 孟堅 end
      // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod end

      // add 2021-08-26 「受信時、ord_coop_noに２つデータを追加するの問題」の対応 孫 start
      // オーダ番号連携対象外の場合、本処理を抜ける
      if (!StringUtils.isEmpty(coopOrdNo)) {
        OrdCoopNo ordCoopNo = new OrdCoopNo();
// del 2021-08-26 「受信時、ord_coop_noに２つデータを追加するの問題」の対応 孫 start
//      ordCoopNo.setCtlNo(ordCoopNoDao.selectNextSeqCtlNo());
// del 2021-08-26 「受信時、ord_coop_noに２つデータを追加するの問題」の対応 孫 end
        ordCoopNo.setFacilityCd((String)idMap.get(ID_FACILITY_CD));
        ordCoopNo.setPatId((Long)idMap.get(ID_PAT_ID));
        ordCoopNo.setOrdNo((Long)idMap.get(ID_ORD_NO));
        ordCoopNo.setCoopCd((String)rm.getSpecial(JournalConvertConstants.COOP_CD));
        ordCoopNo.setCoopOrdNo(coopOrdNo);
        ordCoopNo.setUserId((Long)rm.getSpecial(JournalConvertConstants.USER_ID));
        ordCoopNo.setRegDate(now);
        ordCoopNo.setUpDate(now);
        ordCoopNo.setStatus("1");
        // mod 2021-08-25 idMapにをID_HOSP_PAT_ID追加する 孫 start
//      ordCoopNo.setHospPatId(null);
        ordCoopNo.setHospPatId((String)idMap.get(ID_HOSP_PAT_ID));
        ordCoopNo.setCoopCdIndex((String)rm.getSpecial(JournalConvertConstants.COOP_CD_INDEX));
        // mod 2021-08-25 idMapにをID_HOSP_PAT_ID追加する 孫 end
// add 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
        ordCoopNo.setCoopVersion(coopVersion);
// add 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
// mod 2021-08-26 「受信時、ord_coop_noに２つデータを追加するの問題」の対応 孫 start
//      //ord_coop_noをinsertする
//      ordCoopNoDao.insert(ordCoopNo);
        //ord_coop_noをupdateする
        ordCoopNoDao.updateByCoopOrdNo(ordCoopNo);
// mod 2021-08-26 「受信時、ord_coop_noに２つデータを追加するの問題」の対応 孫 end
      }
      // add 2021-08-26 「受信時、ord_coop_noに２つデータを追加するの問題」の対応 孫 end

      //sys_coop_journalを更新する
      Long ctlNo = (Long) rm.getSpecial(JournalConvertConstants.KEY_JOURNAL_CTL_NO);
      convertCommonService.updateCoopOrdNo(ctlNo, coopOrdNo, idMap);
    }
  }

  /**
   * getCoopOrdNo
   *
   * @param rm
   * @return 連携オーダ番号
   */
  // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod start
  //private String getCoopOrdNo(ResultMap rm) {
  private String getCoopOrdNo(ResultMap rm, Map<String, Object> idMap) {
  // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod end
    String coopOrdNo = null;
    String facilityCd = (String)idMap.get(ID_FACILITY_CD);
    boolean existsBySysCoopNo = false;
    //1. オーダ番号連携対象か否かを判定する
    List<SysCoopNo> sysCoopNoList = sysCoopNoDao.selectByFacilityCd(facilityCd);
    Long curSysCoopNoCtlNo = null;
    String coopCd = (String)rm.getSpecial(JournalConvertConstants.COOP_CD);
    String crud = (String)rm.getSpecial(CRUD);
    Long patId = (Long) idMap.get(ID_PAT_ID);
    Long ordNo = (Long)idMap.get(ID_ORD_NO);
    // add 2021-08-26 「受信時、ord_coop_noに２つデータを追加するの問題」の対応 孫 start
    String hospPatId = (String)idMap.get(ID_HOSP_PAT_ID);
    // add 2021-08-26 「受信時、ord_coop_noに２つデータを追加するの問題」の対応 孫 end
// add 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    // 連携版番号
    String coopVersionCheck = "";
    if (idMap.containsKey(ID_COOP_VERSION)) {
      coopVersionCheck = StringUtils.isEmpty(idMap.get(ID_COOP_VERSION))?"":String.valueOf(idMap.get(ID_COOP_VERSION));
    }
// add 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    //coop_ord_cd内に対象電文種別が存在するか確認し、存在しない場合には オーダ番号連携対象外とする
    for (SysCoopNo sysCoopNo : sysCoopNoList) {
// add 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
      // 連携版番号
      String coopVersion = StringUtils.isEmpty(sysCoopNo.getCoopVersion())?"":String.valueOf(sysCoopNo.getCoopVersion());
      // coop_versionに連携版番号が一致しませんの場合、 オーダ番号連携対象外とする
      if (!coopVersionCheck.equals(coopVersion)) {
        continue;
      }
// add 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
      try {
        List<Map<String, String>> coopCdMapList = ObjectMapperUtil.readTypeReference(sysCoopNo.getCoopOrdCd(), new TypeReference<List<Map<String, String>>>(){});
        for (Map<String, String> coopCdMap : coopCdMapList) {
          if (!coopCd.equals(coopCdMap.get("ord_cd"))) {
            continue;
          }
          existsBySysCoopNo = true;
          curSysCoopNoCtlNo = sysCoopNo.getCtlNo();
          break;
        }
      } catch (Exception e) {
        //対象電文種別判定失敗
        //なにもしない
      }
      if (existsBySysCoopNo) {
        break;
      }
    }

    //2.オーダ番号連携対象外の場合、本処理を抜ける
    if (!existsBySysCoopNo) {
      return "";
    }

    //3.携オーダ番号を取得する
    // 画面パラメータ[患者番号,オーダ番号,連携種別(pat_id,ord_no,coop_cd)] で、連携オーダ番号(ord_coop_no)を取得する
// mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//    // mod 2021-08-26 「受信時、ord_coop_noに２つデータを追加するの問題」の対応 孫 start
////    List<OrdCoopNo> ordCoopNoList = ordCoopNoDao.selectByPatIdAndOrdNoAndCoopCd(facilityCd, patId, null, ordNo, coopCd);
//    List<OrdCoopNo> ordCoopNoList = ordCoopNoDao.selectByPatIdAndOrdNoAndCoopCd(facilityCd, patId, hospPatId, ordNo, coopCd);
//    // mod 2021-08-26 「受信時、ord_coop_noに２つデータを追加するの問題」の対応 孫 end
    List<OrdCoopNo> ordCoopNoList = ordCoopNoDao.selectByPatIdAndOrdNoAndCoopCd(facilityCd, patId, hospPatId, ordNo,
      coopCd, coopVersionCheck);
// mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    if (!ordCoopNoList.isEmpty()) {
      // 連携オーダ番号(ord_coop_no)を取得する場合、連携オーダ番号を設定する
      coopOrdNo = ordCoopNoList.get(0).getCoopOrdNo();
    } else {
      // 連携オーダ番号(ord_coop_no)を取得しませんの場合
      // ジャーナルデータのcrud（作成更新区分）がD（削除）以外の場合、連携オーダ番号を採番する
      if (!"D".equals(crud)) {
        // 連携オーダ番号を採番する
        // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod start
        //coopOrdNo = getNewCoopOrdNo(curSysCoopNoCtlNo, rm);
        coopOrdNo = getNewCoopOrdNo(curSysCoopNoCtlNo, rm, idMap);
        // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod end
      }
    }

    // ジャーナルデータのcrud（作成更新区分）のチェックを行う。
    if ("C".equals(crud)) {
      // 連携オーダ番号(ord_coop_no)が存在、かつ、ステータスが実施済(status = 1：処理済)
      // かつ、電文種別!=[profile]の場合、crudはUにする。
      if (!ordCoopNoList.isEmpty() && "1".equals(ordCoopNoList.get(0).getStatus())
        && !"profile".equals(coopCd)) {
        crud = "U";
      }
    } else if ("U".equals(crud)) {
      // 連携オーダ番号(ord_coop_no)が存在しない、
      // または、[存在、かつ、ステータスが未処理(status = 0：未処理)]の場合、crudはCにする。
      if (ordCoopNoList.isEmpty()
        || (!ordCoopNoList.isEmpty() && "0".equals(ordCoopNoList.get(0).getStatus()))) {
        crud = "C";
      }
    } else if ("D".equals(crud)) {
      // ord_coop_noが存の場合、is_del=1を設定する
      if (!ordCoopNoList.isEmpty()) {
        Timestamp now = new Timestamp(clockWrapper.getClockMillis());

        String tableNameOrd = "ord_coop_no";
        // SQL検索条件
        StringBuffer wheresOrd = new StringBuffer("");
        wheresOrd.append(" WHERE\n");
        wheresOrd.append(" pat_id = " + patId + "\n");
        wheresOrd.append(" AND\n");
        wheresOrd.append(" ord_no = " + ordNo + "\n");
        wheresOrd.append(" AND\n");
        wheresOrd.append(" coop_cd = '" + coopCd + "'\n");
        /* add by chamaojia 2023-05-16 [8637] クエリー条件を追加してインデックス効率を向上  --start */
        wheresOrd.append(" AND\n");
        wheresOrd.append(" facility_cd = '" + facilityCd + "'\n");
        /* add by chamaojia 2023-05-16 [8637] クエリー条件を追加してインデックス効率を向上  --end */
        wheresOrd.append(" AND\n");
        wheresOrd.append(" (is_del = '0' OR is_disp = '1')" + "\n");
        wheresOrd.append(" AND\n");
        wheresOrd.append(" coop_ord_no = '" + coopOrdNo + "'\n");

        // logCommon設定
        DataUpdateLogCommonNew logCommonOrd = getLogCommon(ordCoopNoDao, tableNameOrd, wheresOrd, getEventLogMessage());
        // ログ出力カラム情報及び更新前データ情報取得
        boolean setResultOrd = logCommonOrd.setInfo();

// mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//        // mod 2021-08-26 「受信時、ord_coop_noに２つデータを追加するの問題」の対応 孫 start
////        int updateCountOrd = ordCoopNoDao.updateIsDelIsDisp(patId, null, ordNo, coopCd, now);
//        int updateCountOrd = ordCoopNoDao.updateIsDelIsDisp(patId, hospPatId, ordNo, coopCd, now);
//        // mod 2021-08-26 「受信時、ord_coop_noに２つデータを追加するの問題」の対応 孫 end
        /* modify by chamaojia 2023-05-16 [8637] クエリー条件を追加してインデックス効率を向上  --start */
        int updateCountOrd = ordCoopNoDao.updateIsDelIsDisp(patId, hospPatId, ordNo, coopCd, coopVersionCheck, now, facilityCd, coopOrdNo);
        /* modify by chamaojia 2023-05-16 [8637] クエリー条件を追加してインデックス効率を向上  --end */
// mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

        // 更新後データ取得、差分あれば、log出力
        if (setResultOrd && updateCountOrd > 0) {
        }
      }
    }

    return coopOrdNo;
  }

  /**
   * 連携オーダ番号を採番する
   *
   * @param curSysCoopNoCtlNo - 連携オーダ番号の管理番号
   * @param rm
   * @return 連携オーダ番号
   */
  // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod start
  //private String getNewCoopOrdNo(Long curSysCoopNoCtlNo, ResultMap rm) {
  private String getNewCoopOrdNo(Long curSysCoopNoCtlNo, ResultMap rm, Map<String, Object> idMap) {
  // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod end
    String coopOrdNo = "";
    String coopOrdNoCheck = "";
    Long updateByCurCoopOrdNo = null;
    boolean isNeedSaiban = true;
    String coopCd = (String)rm.getSpecial(JournalConvertConstants.COOP_CD);
    Long userId = (Long)rm.getSpecial(JournalConvertConstants.USER_ID);
    Long patId = (Long)idMap.get(ID_PAT_ID);
    Long ordNo = (Long)idMap.get(ID_ORD_NO);
    String facilityCd = (String) idMap.get(ID_FACILITY_CD);
    // mod 2021-08-26 「受信時、ord_coop_noに２つデータを追加するの問題」の対応 孫 start
    String hospPatId = (String) idMap.get(ID_HOSP_PAT_ID);
    // mod 2021-08-26 「受信時、ord_coop_noに２つデータを追加するの問題」の対応 孫 end
// add 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    // 連携版番号
    String coopVersion = "";
    if (idMap.containsKey(ID_COOP_VERSION)) {
      coopVersion = StringUtils.isEmpty(idMap.get(ID_COOP_VERSION))?"":String.valueOf(idMap.get(ID_COOP_VERSION));
    }
// add 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    //3.1.1. 1の処理で取得したctl_noをキーにしてsys_coop_noを取得する(forupdate)
    SysCoopNo curSysCoopNo = sysCoopNoDao.selectByCtlNo(curSysCoopNoCtlNo);

    while(isNeedSaiban) {
      //3.1.2. 現在の連携オーダ番号シーケンスを+1する
      if (updateByCurCoopOrdNo == null) {
        updateByCurCoopOrdNo = curSysCoopNo.getCurCoopOrdNo() + 1;
      } else {
        updateByCurCoopOrdNo ++;
      }

      //3.1.3. 上記結果が最大値を超えた場合には最小値に設定する
      if (updateByCurCoopOrdNo > curSysCoopNo.getRangeMax()) {
        updateByCurCoopOrdNo = curSysCoopNo.getRangeMin();
      }
      //3.1.4. 連携オーダ番号、パディング文字、位置、前置文字、後置文字等を用いて連携オーダ番号（文字列）を作成する
      StringBuilder coopOrdNoSb = new StringBuilder();
      //前置文字
      if (curSysCoopNo.getPrefixChar() != null) {
        coopOrdNoSb.append(curSysCoopNo.getPrefixChar());
      }
      //パティングした文字
      coopOrdNoSb.append(padding(String.valueOf(updateByCurCoopOrdNo), curSysCoopNo.getNoOfDigit(), curSysCoopNo.getPaddingChar(), curSysCoopNo.getPaddingPos()));
      //後置文字
      if (curSysCoopNo.getSuffixChar() != null) {
        coopOrdNoSb.append(curSysCoopNo.getSuffixChar());
      }

      coopOrdNo = coopOrdNoSb.toString();

      // 資源の枯渇を判断する
      if (coopOrdNo.equals(coopOrdNoCheck)) {
        String error = String.format("連携オーダ番号を採番する時、使用できる番号がなくなりました。pat_id:[%s]", patId);
        outputErrorLog(facilityCd, error);
        throw new NtssException(error);
      }
      // 最初の番号を保存します。
      if (StringUtils.isEmpty(coopOrdNoCheck)) {
        coopOrdNoCheck = coopOrdNo;
      }

      //3.1.5. 以下のsqlを発行し、結果が0件でない場合には3.1.2に戻り処理を繰り返す
// mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//// mod 2021-08-26 「受信時、ord_coop_noに２つデータを追加するの問題」の対応 孫 start
////      List<OrdCoopNo> ordCoopNoList = ordCoopNoDao.selectByPatIdAndCoopOrdNo(facilityCd ,patId,null, coopOrdNo);
//      List<OrdCoopNo> ordCoopNoList = ordCoopNoDao.selectByPatIdAndCoopOrdNo(facilityCd ,patId,hospPatId, coopOrdNo);
//// mod 2021-08-26 「受信時、ord_coop_noに２つデータを追加するの問題」の対応 孫 end
      List<OrdCoopNo> ordCoopNoList = ordCoopNoDao.selectByPatIdAndCoopOrdNo(facilityCd, coopVersion,
        patId, hospPatId, coopOrdNo);
// mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
      if (ordCoopNoList.isEmpty()) {
        isNeedSaiban = false;
        Timestamp now = new Timestamp(clockWrapper.getClockMillis());

        // DB更新ログ出力ロジック wangzuo Start
        String tableNameSys = "sys_coop_no";
        // SQL検索条件
        StringBuffer wheresSys = new StringBuffer("");
        wheresSys.append(" WHERE\n");
        wheresSys.append(" ctl_no = " + curSysCoopNoCtlNo + "\n");

        // logCommon設定
        DataUpdateLogCommonNew logCommonSys = getLogCommon(sysCoopNoDao, tableNameSys, wheresSys, getEventLogMessage());
        // ログ出力カラム情報及び更新前データ情報取得
        boolean setResultSys = logCommonSys.setInfo();
        // DB更新ログ出力ロジック wangzuo End

        //3.1.6. sys_coop_noをupdateする(対象カラム: cur_coop_ord_no )
        int updateCountSys = sysCoopNoDao.updateCurCoopOrdNo(updateByCurCoopOrdNo, curSysCoopNoCtlNo, now);

        // DB更新ログ出力ロジック wangzuo Start
        // 更新後データ取得、差分あれば、log出力
        if (setResultSys && updateCountSys > 0) {
          logCommonSys.updateLog();
        }
        // DB更新ログ出力ロジック wangzuo End

        OrdCoopNo ordCoopNo = new OrdCoopNo();
        ordCoopNo.setCtlNo(ordCoopNoDao.selectNextSeqCtlNo());
        ordCoopNo.setFacilityCd(facilityCd);
        ordCoopNo.setPatId(patId);
        ordCoopNo.setOrdNo(ordNo);
        ordCoopNo.setCoopCd(coopCd);
        ordCoopNo.setCoopOrdNo(coopOrdNo);
        ordCoopNo.setUserId(userId);
        ordCoopNo.setRegDate(now);
        ordCoopNo.setUpDate(now);
// add 2021-09-30 #6549:連携オーダ番号管理テーブルにてステータスがnullのデータが発生している 孫 start
        ordCoopNo.setStatus("0");
// add 2021-09-30 #6549:連携オーダ番号管理テーブルにてステータスがnullのデータが発生している 孫 end
// add 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
        ordCoopNo.setCoopVersion(coopVersion);
// add 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
        //3.1.8. ord_coop_noをinsertする
        ordCoopNoDao.insert(ordCoopNo);
      }
    }
    return coopOrdNo;
  }

  /**
   * Padding対応
   *
   * @param target - Padding対象
   * @param itemLength - Paddingする桁数
   * @param format パディング文字
   * @param position パディングする位置(left : 左、right : 右)
   * @return Paddingされた文字列
   */
  private String padding(String target, long itemLength, String format, String position) {
    long formatedLength = itemLength - target.getBytes().length;
    // add 2022-01-28 #7061:【デグレ】ini_dial連携の受信でエラーが発生する 孫 start
    if (formatedLength <= 0) {
      return target;
    }
    // add 2022-01-28 #7061:【デグレ】ini_dial連携の受信でエラーが発生する 孫 end

    // 半角スペース×桁数で文字列用意
    String paddingByDefaultFormat = "%".concat(String.valueOf(formatedLength)).concat("s");
    String paddingByDefault = String.format(paddingByDefaultFormat, " ");

    // パディング文字なし：０パディング、パディング文字がある場合にはパディング文字でパディングする
    String paddingOnly = StringUtils.isEmpty(format) ? paddingByDefault.replace(" ", "0") : paddingByDefault.replace(" ", format);
    return position.equals("left") ? paddingOnly.concat(target) : target.concat(paddingOnly);
  }

  /**
   * getParaMap
   *
   * @param tableName
   * @param dataKey
   * @return format後された文字列
   */
  // #8378-profile連携の患者登録処理でエラーが発生する 周 mod start
  //private Map<String, Object> getParaMap(String tableName ,Map<String, Object> dataKey) {
  private Map<String, Object> getParaMap(String tableName ,Map<String, Object> dataKey, Map<String,Object> paraMap) {
    // #8378-profile連携の患者登録処理でエラーが発生する 周 mod end
    if (paraMap.containsKey(tableName)) {
      Object obj = paraMap.get(tableName);
      Map<String, Object> map = ObjectMapperUtil.castToStringObjectMap(obj);
      for (String key : dataKey.keySet()) {
        map.put(key,dataKey.get(key));
      }
      paraMap.put(tableName,map);
    } else {
      paraMap.put(tableName,dataKey);
    }
    Object obj = paraMap.get(tableName);
    Map<String, Object> map = ObjectMapperUtil.castToStringObjectMap(obj);
    return map;
  }

  /**
   * setDateFormat
   *
   * @param value
   * @param format
   * @return format後された文字列
   */
  private String setDateFormat(String value, String format) {
    // add 2021-09-09 #5897:CSI連携ができないの対応 孫 start
    if (StringUtils.isEmpty(value)) {
      return value;
    }
    // add 2021-09-09 #5897:CSI連携ができないの対応 孫 end
    String temp = null;
    switch (format) {
      case "yyyy-MM-dd HH:mi:ss":
        // mod 2021-09-09 #5897:CSI連携ができないの対応 孫 start
//        if (value.length() == 8) {
//          value = value + "000000";
//        }
        if (value.contains(" ") || value.contains("/") || value.contains("-") || value.contains(":")) {
          value = value + "::::::";
          String[] tmp = value.split("[/|-|:|.|=| ]", 7);
          value = String.format("%04d%02d%02d%02d%02d%02d"
            , Integer.valueOf((StringUtils.isEmpty(tmp[0])?"0":tmp[0]))
            , Integer.valueOf((StringUtils.isEmpty(tmp[1])?"0":tmp[1]))
            , Integer.valueOf((StringUtils.isEmpty(tmp[2])?"0":tmp[2]))
            , Integer.valueOf((StringUtils.isEmpty(tmp[3])?"0":tmp[3]))
            , Integer.valueOf((StringUtils.isEmpty(tmp[4])?"0":tmp[4]))
            , Integer.valueOf((StringUtils.isEmpty(tmp[5])?"0":tmp[5])));
        } else {
          value = value + "00000000000000";
        }
        // mod 2021-09-09 #5897:CSI連携ができないの対応 孫 end
        temp = value.substring(0,4) + "-" + value.substring(4,6) + "-" + value.substring(6,8) +
          " " + value.substring(8,10) + ":" + value.substring(10,12) + ":" + value.substring(12,14);
        break;
      default:
        temp = value;
        break;
    }
    return temp;
  }
// add 2022-02-10 #6995:profile連携で受信した身体情報登録 孫 start
  private String getGMTDate(String value) {
  if (StringUtils.isEmpty(value)) {
    return value;
  }
  if (value.contains(" ") || value.contains("/") || value.contains("-") || value.contains(":")) {
    value = value + "::::::";
    String[] tmp = value.split("[/|-|:|.|=| ]", 7);
    value = String.format("%04d%02d%02d%02d%02d%02d"
      , Integer.valueOf((StringUtils.isEmpty(tmp[0])?"0":tmp[0]))
      , Integer.valueOf((StringUtils.isEmpty(tmp[1])?"0":tmp[1]))
      , Integer.valueOf((StringUtils.isEmpty(tmp[2])?"0":tmp[2]))
      , Integer.valueOf((StringUtils.isEmpty(tmp[3])?"0":tmp[3]))
      , Integer.valueOf((StringUtils.isEmpty(tmp[4])?"0":tmp[4]))
      , Integer.valueOf((StringUtils.isEmpty(tmp[5])?"0":tmp[5])));
  } else {
    value = value + "00000000000000";
  }

  // yyyy-MM-dd HH:mm:ss
  String tempTime = value.substring(0,4) + "-" + value.substring(4,6) + "-" + value.substring(6,8) +
    " " + value.substring(8,10) + ":" + value.substring(10,12) + ":" + value.substring(12,14);

  // HH:mm:ssが00:00:00の場合、のみYYYY-MM-DDを戻る
  if (tempTime.endsWith(" 00:00:00")) {
    return tempTime.substring(0,10);
  }

  Date newDate = null;
  String format = "yyyy-MM-dd HH:mm:ss";
  try {
    SimpleDateFormat sdFormatter = new SimpleDateFormat(format);
    newDate = sdFormatter.parse(tempTime);
  } catch (Exception e1) {
    String errMsg = String.format("日付[%s]の書式[%s]が正しくありません。[%s]", tempTime, format, e1.getMessage());
    throw new NtssException(errMsg);
  }
  // mod 2022-05-24 #7218 患者経過総合ビューアで手動実績作成しようとすると条件送信を実行できませんでしたと表示され実績作成ができない 孟堅　start
  //SimpleDateFormat sf = new SimpleDateFormat(ZONED_DATE_TIME_ISO8601);
  SimpleDateFormat sf = new SimpleDateFormat(JournalConvertConstants.ZONED_DATE_TIME_ISO8601);
  // mod 2022-05-24 #7218 患者経過総合ビューアで手動実績作成しようとすると条件送信を実行できませんでしたと表示され実績作成ができない 孟堅　end
  sf.setTimeZone(TimeZone.getTimeZone(CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO));
  String newDateString = sf.format(newDate);

  return newDateString;
}
// add 2022-02-10 #6995:profile連携で受信した身体情報登録 孫 end
  /**
   * setAllPara
   *
   * @param m1
   * @param kbn
   * @param reportInfo
   */
  // #8378-profile連携の患者登録処理でエラーが発生する 周 mod start
  //private void setAllPara(Map<String, Object> m1, String kbn, List<Map<String, Object>> reportInfo) {
  private void setAllPara(Map<String, Object> m1, String kbn, List<Map<String, Object>> reportInfo, Map<String, Object> resultJsonMap) {
    // #8378-profile連携の患者登録処理でエラーが発生する 周 mod end
    String result = null;
    resultJsonMap.clear();
    // 追加の場合
    if ("2".equals(kbn)) {
      if (m1.containsKey("insertResult")) {
        result = String.valueOf(m1.get("insertResult"));
        JSONObject resultObj = new JSONObject(result);
        convertJsonToMap(resultObj, resultJsonMap);
      }
    }
    // 更新の場合
    if ("3".equals(kbn) || "9".equals(kbn)) {
      if (m1.containsKey("updateResult")) {
        result = String.valueOf(m1.get("updateResult"));
        JSONObject resultObj = new JSONObject(result);
        Map<String, Object> resultMap = new LinkedHashMap<>();
        convertJsonToMap(resultObj, resultMap);
        for (String resultKey : resultMap.keySet()) {
          if (StringUtils.isEmpty((String)resultMap.get(resultKey))) {
            resultJsonMap.put(resultKey,"");
          } else {
            for (Map<String, Object> map : reportInfo) {
              for (String key : map.keySet()) {
                if (String.valueOf(resultMap.get(resultKey)).equals(key)) {
                  if (map.get(key) == null) {
                    resultJsonMap.put(resultKey,null);
                  } else {
                    resultJsonMap.put(resultKey,map.get(key).toString());
                  }
                  break;
                }
              }
            }
          }
        }
      }
    }
  }
  // add 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 end

  // add 2021-12-06 #5888:NEC連携ができない(スタッフマスタ連携) 孫 start
  /**
   * 個人情報ビットシフト暗号化
   */
  private String personalInfoEncrypto(String text) {
    if (StringUtils.isEmpty(text)) {
      return "";
    }
    // TODO: Java暗号化が実装できたらそっちに差し替えを行う。
    // いまは暗号化のためにDB6のファンクションを呼び出している。
    return db6FunctionDao.personalInfoEncrypto(text);
  }

  /**
   * パスワードエンコーダ
   */
  private String passwordEncoder(String password) {
    if (StringUtils.isEmpty(password)) {
      return "";
    }

    // パスワードエンコーダを作成する。
    // FIXME ntss-admin-webプロジェクトに倣い、BCryptPasswordEncoderを使用する。
    // ただし、ntss-admin-webで定義されたコンポーネントはntss-coop-apiで使用できない。
    // コンポーネント単位で共通化する場合、パスワードエンコーダコンポーネントをntss-admin-webから
    // ntss-coreに移動し、ntss-admin-webとntss-coop-apiから参照するよう変更する。
    PasswordEncoder encoder = new BCryptPasswordEncoder();

    // パスワードが指定されている場合は暗号化する。
    return encoder.encode(password);
  }
  // add 2021-12-06 #5888:NEC連携ができない(スタッフマスタ連携) 孫 end
}
