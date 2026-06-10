package jp.co.nikkiso.ntss.admin_web.service.patEvent;

import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.model.DeleteObjectRequest;
import com.amazonaws.services.s3.model.GetObjectRequest;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.PutObjectRequest;
import com.amazonaws.services.s3.model.S3Object;
import com.fasterxml.jackson.core.type.TypeReference;
// add #11470 by shiyw 20250326 start
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
// add #11470 by shiyw 20250326 end
import jp.co.nikkiso.ntss.admin_web.config.AwsConfiguration;
import jp.co.nikkiso.ntss.admin_web.request.patEvent.PatEventRequest;
import jp.co.nikkiso.ntss.admin_web.response.patEvent.PatEventMasterResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.BbsInfoService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.PatEventUtils;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallCommonUtil;
import jp.co.nikkiso.ntss.api.domain.report.ReportXmlParam;
import jp.co.nikkiso.ntss.api.service.SysDataSetService;
import jp.co.nikkiso.ntss.api.service.report.ReportS3Service;
import jp.co.nikkiso.ntss.api.service.utils.ReportUtils;
import jp.co.nikkiso.ntss.api.service.utils.ReportZipFile;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.FacilitySettingNo;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstFacilityHashDao;
import jp.co.nikkiso.ntss.core.dao.MstReportDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.MstPatEventCategoryDao;
import jp.co.nikkiso.ntss.core.dao.MstPatEventDataTemplateDao;
import jp.co.nikkiso.ntss.core.dao.MstPatEventSubCategoryDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstSelectorDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.OrdPrescriptionDao;
import jp.co.nikkiso.ntss.core.dao.PatEventDao;
import jp.co.nikkiso.ntss.core.dao.PatExamMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.PatRadMainDao;
import jp.co.nikkiso.ntss.core.dao.ShrPatInfoDao;
import jp.co.nikkiso.ntss.core.dao.SysCoopJournalDao;
import jp.co.nikkiso.ntss.core.dao.SysDataSetDao;
import jp.co.nikkiso.ntss.core.dao.SysFacilityDao;
import jp.co.nikkiso.ntss.core.dao.SysSystemDefineDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;
import jp.co.nikkiso.ntss.core.dto.indSchedule.OrdNoAndConnectedTableKeyData;
import jp.co.nikkiso.ntss.core.entity.MstFacility;
import jp.co.nikkiso.ntss.core.entity.MstPatEventCategory;
import jp.co.nikkiso.ntss.core.entity.MstPatEventDataTemplate;
import jp.co.nikkiso.ntss.core.entity.MstPatEventSubCategory;
import jp.co.nikkiso.ntss.core.entity.MstReport;
import jp.co.nikkiso.ntss.core.entity.MstSelector;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatEvent;
import jp.co.nikkiso.ntss.core.entity.PatEventShare;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.ShrPatInfo;
import jp.co.nikkiso.ntss.core.entity.SysDataSet;
import jp.co.nikkiso.ntss.core.entity.SysFacility;
import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainPatEventRecCombo;
import jp.co.nikkiso.ntss.core.entity.custom.PatEventCoopInfo;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logevent.OrdMainHisMongo;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.apache.commons.lang3.tuple.Pair;
import org.apache.commons.lang3.StringEscapeUtils;
import org.json.JSONArray;
import org.json.JSONObject;
import org.seasar.doma.jdbc.Config;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import javax.xml.bind.DatatypeConverter;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.nio.file.attribute.BasicFileAttributeView;
import java.nio.file.attribute.FileTime;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Base64;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

//add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
//add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end

@Service
public class PatEventServiceImpl implements PatEventService {

  /**
   * 定数定義：未登録
   */
  private static final String NONE = "未登録";

  // TODO: そのうちymlからの取得ではなくなるかも
  /**
   * S3バケット名
   */
  @Value("${ntss.pat-event.s3-bucket}")
  private String s3Bucket;

  /**
   * 画像ファイルをキャッシュするディレクトリ
   */
  @Value("${ntss.pat-event.cache-dir}")
  private String cacheDir;
  // add #12402 紹介状の編集で画像の追加や差し替えができない zhao start
  /**
   * イメージ
   */
  @Value("${ntss.pat-event.s3-bucket:#{null}}")
  private String s3BucketForImage;
  // add #12402 紹介状の編集で画像の追加や差し替えができない zhao end
  /**
   * S3オブジェクト取得
   * @return s3 S3オブジェクト
   */
  @Autowired
  private AwsConfiguration awsS3;

  private AmazonS3 s3() {
    return awsS3.s3();
  }

  @Autowired
  private OrdMainDao ordMainDao;

  @Autowired
  private PatEventDao patEventDao;

  @Autowired
  private PatPersonalMainDao ppmDao;

  @Autowired
  private MstPatEventDataTemplateDao mstPatEventDataTemplateDao;

  @Autowired
  private MstPatEventCategoryDao mstPatEventCategoryDao;

  @Autowired
  private MstSelectorDao mstSelectorDao;

  @Autowired
  private MstPatEventSubCategoryDao mstPatEventSubCategoryDao;

  @Autowired
  private SysSystemDefineDao sysSystemDefineDao;
  @Autowired
  private SysDataSetDao sysDataSetDao;
  @Autowired
  private MstFacilitySettingDao mstFacilitySettingDao;
  /*add FNSI-改修内容患者イベント患者情報共有より改修 任 start*/
  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;
  /*add FNSI-改修内容患者イベント患者情報共有より改修 任 end*/

  //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
  @Autowired
  private LogService logService;
  //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end

  // DB更新ログ出力ロジック wangzuo Start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;
  @Autowired
  private LogServiceCore logServiceCore;
  // DB更新ログ出力ロジック wangzuo End
  /*add FNSI-改修内容患者イベント外结No.7 任 start*/
  @Autowired
  private SysFacilityDao sysFacilityDao;
  /*add FNSI-改修内容患者イベント外结No.7 任 end*/


  /*add 20210818 #6141 FNSI-追加sysCoopJournalDao  鄭 start*/
  @Autowired
  private SysCoopJournalDao sysCoopJournalDao;
  /*add 20210818 #6141 -追加sysCoopJournalDao  鄭 end*/


  /*add 20210819 #6141 FNSI-追加patExamMainDao  鄭 start*/
  @Autowired
  private PatExamMainDao patExamMainDao;
  /*add 20210819 #6141 -追加patExamMainDao  鄭 end*/

  /*add 20210820 #6141 FNSI-追加patRadMainDao  鄭 start*/
  @Autowired
  private PatRadMainDao patRadMainDao;
  /*add 20210820 #6141 -追加patRadMainDao  鄭 end*/

  /*add 20210823 #6141 FNSI-追加mastFacilityHashDao  鄭 start*/
  @Autowired
  private MstFacilityHashDao mastFacilityHashDao;
  /*add 20210823 #6141 -追加mastFacilityHashDao  鄭 end*/

  /*add 20210826 #6141 FNSI-追加ordPrescriptionDao  鄭 start*/
  @Autowired
  private OrdPrescriptionDao ordPrescriptionDao;
  /*add 20210826 #6141 -追加ordPrescriptionDao  鄭 end*/
  @Autowired
  private WebApiCallCommonUtil webApiCallCommonUtil;
  // add #6142 施設の変更ができない 歴程 start
  @Autowired
  private MstFacilityDao mstFacilityDao;
  // add #6142 施設の変更ができない 歴程 end
  // add #9273 施設設定マスタのNo105の設定どおり動かない。  start
  /**
   * 掲示板登録情報
   */
  @Autowired
  private BbsInfoService bbsInfoService;
  // add #9273 施設設定マスタのNo105の設定どおり動かない。  end
  // add #12324 紹介状の出力時にpat_eventを参照する zhao start
  /**
   * S3から帳票を構成するファイルを取得するService
   */
  @Autowired
  private ReportS3Service reportS3Service;
  /**
   * 帳票マスタのDaoインタフェース.
   */
  @Autowired
  private MstReportDao mstReportDao;
  /**
   * SysDataSetのサービス.
   */
  @Autowired
  private SysDataSetService sysDataSetService;
  // add #12324 紹介状の出力時にpat_eventを参照する zhao end
  // add #12462 患者情報共有 zhao start
  @Autowired
  private ShrPatInfoDao shrPatInfoDao;
  // add #12462 患者情報共有 zhao end
  /**
   * {@inheritDoc}
   */
  @Override
  public List<SysDataSet> getSysDataSet(Integer mode) {
    List<SysDataSet> ret = new ArrayList<>();
    if (mode != null) {
      if (mode.intValue() == 0) {
        ret = sysDataSetDao.selectForPatEventList();
      } else if (mode.intValue() == 1) {
        ret = sysDataSetDao.selectForPatEventText();
      }
    }
    return ret;
  }

  @Override
  public List<OrdMainPatEventRecCombo> selectPatEventRecCombo(String facilityCd, Long patId,Timestamp dialysisDateFrom,
      Timestamp dialysisDateTo, Integer mode) {
    return ordMainDao.selectPatEventRecCombo(facilityCd, patId, dialysisDateFrom, dialysisDateTo, mode);
  }

  @Override
  public OrdMainPatEventRecCombo selectOrdMain(Long ordNo, Long patId) {
    return ordMainDao.selectPatEventOrd(ordNo, patId);
  }

  @Override
  public List<PatEventShare> selectByPatIdNewestShare(Long pat_id, Timestamp event_start_date_from,
                                                      Timestamp event_start_date_to, String facilityCd, Long... patEventCdList) {
    return patEventDao.selectByPatIdNewestShare(pat_id, event_start_date_from, event_start_date_to, facilityCd, patEventCdList);
  }

  @Override
  public List<PatEvent> selectByCd(Long pat_event_cd) {
    // upd #12324 紹介状の出力時にpat_eventを参照する zhao start
    // return patEventDao.selectByCd(pat_event_cd);
    List<PatEvent> patEventList = patEventDao.selectByCd(pat_event_cd);
    return editLetterInfoForScreenDisplay(patEventList);
    // upd #12324 紹介状の出力時にpat_eventを参照する zhao end
  }

  // add FNSI-観察記録を追加 楊 start
  /**
   * 患者経過総合ビューア取得用、観察記録データ取得
   * @param pat_id 患者ID
   * @param dialysis_date_from 表示開始日(YYYYMMDD)
   * @param dialysis_date_to 表示終了日(YYYYMMDD)
   * @return 観察記録のResponse
   */
  @Override
  public List<PatEvent> FindPatEventByDateCd(long pat_id, String dialysis_date_from, String dialysis_date_to) {
    return patEventDao.selectByPatIdDate(pat_id, dialysis_date_from, dialysis_date_to);
  }
  // add FNSI-観察記録を追加 楊 end

  // add FNSI-患者イベント（仮）を追加 李 start
  /**
   * 患者経過総合ビューア取得用、患者イベント（仮）データ取得
   * @param pat_id 患者ID
   * @param dialysis_date_from 表示開始日(YYYYMMDD)
   * @param dialysis_date_to 表示終了日(YYYYMMDD)
   * @return 患者イベント（仮）のResponse
   */
  @Override
  public List<PatEvent> FindPatientByDateCd(long pat_id, String dialysis_date_from, String dialysis_date_to, String facilityCd) {
    return patEventDao.selectByPatientIdDate(pat_id, dialysis_date_from, dialysis_date_to, facilityCd);
  }
  // add FNSI-患者イベント（仮）を追加 李 end
// 426 姜 start

  @Override
  @Transactional
  // mod FNSI-FutreNetWeb+SI課題管理No.4710 李 start
//  public void updateDateByCd(String patEventCd, int dataNumber) {
//    // DB更新ログ出力ロジック xie Start
//    boolean setResult = false;
//    DataUpdateLogCommonNew logCommon = null;
//    try {
//      String tableName = "pat_event";
//      // SQL検索条件
//      StringBuffer wheres = new StringBuffer("");
//      wheres.append(" WHERE\n");
//      wheres.append(" pat_event_cd = '" + patEventCd + "'\n");
//      // logCommon設定
//      logCommon = getLogCommon(patEventDao, tableName, wheres, getEventLogMessage());
//       // ログ出力カラム情報及び更新前データ情報取得
//      setResult = logCommon.setInfo();
//    } catch(Exception e) {
//      setResult = false;
//    }
//    // DB更新ログ出力ロジック xie End
////    int updateCount = patEventDao.updateDateByCd(patEventCd, dataNumber);
////
////    // DB更新ログ出力ロジック xie Start
////    // 更新後データ取得、差分あれば、log出力
////    if (setResult && updateCount > 0) {
////      logCommon.updateLog();
////    }
//    // DB更新ログ出力ロジック xie End
//  }
  public void updateDateByCd(ArrayList<String> patEventCd, int dataNumber) {
    // DB更新ログ出力ロジック xie Start
    boolean setResult = false;
    DataUpdateLogCommonNew logCommon = null;
    try {
      String tableName = "pat_event";
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" pat_event_cd = '" + patEventCd + "'\n");
      // logCommon設定
      logCommon = getLogCommon(patEventDao, tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      setResult = logCommon.setInfo();
    } catch(Exception e) {
      setResult = false;
    }
    // DB更新ログ出力ロジック xie End

    // mod #9273 施設設定マスタのNo105の設定どおり動かない。  start
    // patEventCd.stream().forEach(item -> {patEventDao.updateDateByCd(item, dataNumber);});
    patEventCd.stream().forEach(item -> {
      this.updateEventAndBbsDate(Long.valueOf(item), dataNumber);
    });
    // mod #9273 施設設定マスタのNo105の設定どおり動かない。  end

    // DB更新ログ出力ロジック xie Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult) {
      logCommon.updateLog();
    }
    // DB更新ログ出力ロジック xie End
  }
  // mod FNSI-FutreNetWeb+SI課題管理No.4710 李 end
    @Override
    @Transactional
    public void deleteDateByCd(String patEventCd) {
      // add #9273 施設設定マスタのNo105の設定どおり動かない。  start
      List<PatEvent> events = this.selectByCd(Long.valueOf(patEventCd));
      try {
        bbsInfoService.deleteBbs(events.get(0).getBbsCtlNo());
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
      // add #9273 施設設定マスタのNo105の設定どおり動かない。  end
    patEventDao.deleteDateByCd(patEventCd);
  }
  // 426 姜 end
  @Override
  public List<PatEvent> selectByOrdNo(Long ord_no,String facilityCd) {
    return patEventDao.selectByOrdNo(ord_no,facilityCd);
  }

  @Override
  @Transactional
  public List<PatEvent> create(PatEventRequest request) throws ParseException {
    // update by YangYongzhuang  2023-02-03 [CodeOptimization]  start /
    // add #12324 紹介状の出力時にpat_eventを参照する zhao start
    // del #12402 紹介状の編集で画像の追加や差し替えができない zhao start
    //editLetterInfoForDb(request.getPatEventParam());
    // del #12402 紹介状の編集で画像の追加や差し替えができない zhao end
    // add #12324 紹介状の出力時にpat_eventを参照する zhao end
    List<PatEvent> m = createPatEventRec(request);
    boolean isNotification = request.getIsNotification();
    // update by YangYongzhuang  2023-02-03 [CodeOptimization]  End /
    // add #11470 by shiyw 20250326 start
    ObjectMapper mapper = new ObjectMapper();
    // add #11470 by shiyw 20250326 end
    for (PatEvent e : m) {
      long nextSeqPatEventCd = patEventDao.selectNextSeqPatEventCd();
      e.setPatEventCd(nextSeqPatEventCd);
      // add #11470 by shiyw 20250326 start
      try {
        ArrayNode resultValueArray = (ArrayNode) mapper.readTree(e.getResultParams());
        updateResultValue(resultValueArray,nextSeqPatEventCd);
        String resultParams = mapper.writerWithDefaultPrettyPrinter().writeValueAsString(resultValueArray);
        e.setResultParams(resultParams);
      } catch (JsonProcessingException ex) {
        throw new RuntimeException(ex);
      }
      // add #12402 紹介状の編集で画像の追加や差し替えができない zhao start
      editLetterInfoForDb(e, "insert");
      // add #12402 紹介状の編集で画像の追加や差し替えができない zhao end
      // add #11470 by shiyw 20250326 end
      Integer insertCount = patEventDao.insert(e);
      // 観察記録ログ出力 = 実施の場合
      if (e.getIsObserveRecordLog()) {
        // (新規)観察記録ログの出力
        writeCreatedObserveRecordLog(e);
      }
      if (insertCount > 0 && isNotification) {
        Long patId = e.getPatId();
        String facilityCd = e.getFacilityCd();

        try {

          // 患者情報取得
          PatPersonalMain patPersonalMain = ppmDao.selectById(patId);

          JSONObject replaceData = new JSONObject();
          replaceData.put("PATID", patId.toString());
          replaceData.put("LASTNAME", patPersonalMain.getPat_last_name());
          replaceData.put("FIRSTNAME", patPersonalMain.getPat_first_name());
          replaceData.put("CATEGORY", e.getSubCategoryName());
          replaceData.put("FACILITYCD", facilityCd);
          replaceData.put("PATEVENTCD", e.getPatEventCd().toString());

          webApiCallCommonUtil.registerNotification(CoreConstant.NotificationDefinition.ADD_PAT_EVENT, facilityCd, replaceData);

        } catch (Exception e1) {
        }
      }
    }
    return m;
  }

  // add #11470 by shiyw 20250326 start
  public void updateResultValue(ArrayNode resultValueArray,Long patEventCd) {
    for (JsonNode node : resultValueArray) {
      if (node.has("result_value") && node.get("result_value").isArray()) {
        ArrayNode resultValues = (ArrayNode) node.get("result_value");
        for (JsonNode resultValue : resultValues) {
          if (resultValue.has("file_path") && !resultValue.get("file_path").asText().isEmpty()) {
            String filePath = resultValue.get("file_path").asText(); //例: "815/0/image/0-2/xxx.jpg"
            String[] parts = filePath.split("/");
            if (parts.length > 1 && parts[1].equals("0")) {
              parts[1] = "" + patEventCd; // 0をpatEventCdに置き換える
            }
            String updatedPath = String.join("/", parts);
            ((ObjectNode) resultValue).put("file_path", updatedPath);
          }
        }
      }
    }
  }
  // add #11470 by shiyw 20250326 end

  @Override
  @Transactional
  public PatEvent update(PatEvent m, Boolean isNotification) {
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(m,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    // add #12324 紹介状の出力時にpat_eventを参照する zhao start
    // mod #12402 紹介状の編集で画像の追加や差し替えができない zhao start
    //editLetterInfoForDb(m);
    editLetterInfoForDb(m, "update");
    // mod #12402 紹介状の編集で画像の追加や差し替えができない zhao end
    // add #12324 紹介状の出力時にpat_eventを参照する zhao end
    Integer insertCount = patEventDao.update(m);
    // 観察記録ログ出力 = 実施の場合
    if (m.getIsObserveRecordLog()) {
      // (更新)観察記録ログの出力
      writeUpdatedObserveRecordLog(m);
    }
    if (insertCount > 0 && isNotification) {
        Long patId = m.getPatId();
        String facilityCd = m.getFacilityCd();

        try {
          // 患者情報取得
          PatPersonalMain patPersonalMain = ppmDao.selectById(patId);

          JSONObject replaceData = new JSONObject();
          replaceData.put("PATID", patId.toString());
          replaceData.put("LASTNAME", patPersonalMain.getPat_last_name());
          replaceData.put("FIRSTNAME", patPersonalMain.getPat_first_name());
          replaceData.put("CATEGORY", m.getSubCategoryName());
          replaceData.put("FACILITYCD", facilityCd);
          replaceData.put("PATEVENTCD", m.getPatEventCd().toString());

          webApiCallCommonUtil.registerNotification(CoreConstant.NotificationDefinition.ADD_PAT_EVENT, facilityCd, replaceData);

        } catch (Exception e1) {
        }
      }
    //add  FNSI-8441 ljx start
    //観察記録を削除したあと、治療記録所属の観察記録である場合、該当ord_mainの確定フラグを「未確定」に設定。
    if (m.getOrdNo() != null && m.getOrdNo() != 0) {
      ordMainDao.updateIsConfirm(m.getOrdNo(), "1", "0");
    }
    //add  FNSI-8441 ljx end
    return m;
  }
  /*add FNSI-改修内容転入転出の患者情報連動 任 start*/
  @Override
  @Transactional
  public PatEvent updateLetterInfo(PatEvent m) {
    // DB更新ログ出力ロジック xie Start
    boolean setResult = false;
    DataUpdateLogCommonNew logCommon = null;
    try {
      String tableName = "pat_event";
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" pat_event_cd = '" + m.getPatEventCd() + "'\n");
      // logCommon設定
      logCommon = getLogCommon(patEventDao, tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      setResult = logCommon.setInfo();
    } catch(Exception e) {
      setResult = false;
    }
    // DB更新ログ出力ロジック xie End
    int updateCount = patEventDao.updateLetterInfo(m.getLetterInfo(),m.getPatEventCd());

    // DB更新ログ出力ロジック xie Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      logCommon.updateLog();
    }
// DB更新ログ出力ロジック xie End
    return m;
  }
  /*add FNSI-改修内容転入転出の患者情報連動 任 end*/

  @Override
  @Transactional
  public PatEvent updateResultParams(PatEvent m) {
    /*mod FNSI-改修内容一括で複数イベントを登録された時、一括登録された２番目からのデータが削除できない。任 start*/
    /*patEventDao.updateOnlyResultParams(m.getPatEventCd(), m.getResultParams());*/
    for(int i = 0;i < m.getPatEventCdList().size();i++){
      boolean setResult = false;
      DataUpdateLogCommonNew logCommon = null;
      try {
        String tableName = "pat_event";
        // SQL検索条件
        StringBuffer wheres = new StringBuffer("");
        wheres.append(" WHERE\n");
        wheres.append(" pat_event_cd = '" + m.getPatEventCdList().get(i) + "'\n");
        // logCommon設定
        logCommon = getLogCommon(patEventDao, tableName, wheres, getEventLogMessage());
        // ログ出力カラム情報及び更新前データ情報取得
        setResult = logCommon.setInfo();
      } catch(Exception e) {
        setResult = false;
      }
      // DB更新ログ出力ロジック xie End
      /*add FNSI-改修内容redmine4763 任 start*/
      String inputParam = m.getInputParams();
      // mod #11445 【たくしん会】pat_eventのinput_params「null」によるクエリエラー問題　V1.0B 高 start
//      if(!"null".equals(inputParam)){
      if(!"null".equals(inputParam) && !StringUtils.isEmpty(inputParam)){
        // mod #11445 【たくしん会】pat_eventのinput_params「null」によるクエリエラー問題　V1.0B 高 end
        JSONArray jsonArray = new JSONArray(inputParam);
        String resultParam = m.getResultParams();
        JSONArray jsonArrayResult = new JSONArray(resultParam);
        for(int k = 0;k < jsonArray.length();k++){
          String isRstCopy = (String)((JSONObject)jsonArray.get(k)).get("is_rst_copy");
          int formatClass = (int)((JSONObject)jsonArray.get(k)).get("format_class");
          if("0".equals(isRstCopy) && i != 0){
            for(int j = 0;j < jsonArrayResult.length();j++){
              if(((JSONObject)jsonArrayResult.get(j)).has("format_class")){
                if(formatClass == (int)((JSONObject)jsonArrayResult.get(j)).get("format_class")){
                  String[] temp = new String[]{};
                  switch (formatClass) {
                    case 0:
                    case 5:
                    case 9:
                      //内部6336患者カレンダー,DBで表示される「result_value」の値は空ですが、ページには値が表示されます　add ljx start
                      if(k == j){
                        ((JSONObject) jsonArrayResult.get(j)).put("result_value","");
                      }
                      //内部6336患者カレンダー,DBで表示される「result_value」の値は空ですが、ページには値が表示されます　add ljx end
                      break;
                    case 1:
                      String isFormatting = (String)((JSONObject)((JSONObject)jsonArray.get(k)).get("item_json")).get("is_formatting");
                      if("0".equals(isFormatting)){
                        ((JSONObject) jsonArrayResult.get(j)).put("result_value","");
                      }else{
                        ((JSONObject) jsonArrayResult.get(j)).put("result_value", StringEscapeUtils.unescapeJava("<span style=\\\"font-size: 12pt; font-family: メイリオ;\\\">\uFEFF\uFEFF</span>"));
                      }
                      break;
                    case 2:
                      JSONObject jsonObject = new JSONObject();
                      JSONArray jsonArrayNew = new JSONArray();
                      jsonObject.put("name","");
                      jsonObject.put("file_name","");
                      jsonObject.put("file_path","");
                      jsonObject.put("is_send_va","0");
                      for(int o = 0;o< ((JSONArray)((JSONObject)jsonArrayResult.get(j)).get("result_value")).length();o++){
                        jsonArrayNew.put(jsonObject);
                      }
                      ((JSONObject) jsonArrayResult.get(j)).put("result_value",jsonArrayNew);
                      break;
                    case 3:
                    case 4:
                    case 6:
                    case 7:
                      ((JSONObject) jsonArrayResult.get(j)).put("result_value",temp);
                      break;
                    case 8:
                      JSONObject jsonObject8 = new JSONObject();
                      jsonObject8.put("score","0");
                      jsonObject8.put("unit","");
                      ((JSONObject) jsonArrayResult.get(j)).put("result_value",jsonObject8);
                      break;
                    case 10:
                      JSONObject jsonObject10 = new JSONObject(m.getResultParamsOld());
                      ((JSONObject) jsonArrayResult.get(j)).put("result_value",jsonObject10);
                      break;
                  }
                }
              }
            }
          }
        }
        m.setResultParams(jsonArrayResult.toString());
      }
      /*add FNSI-改修内容redmine4763 任 end*/
      int updateCount = patEventDao.updateResultParamsAndReportUrl(m.getPatEventCdList().get(i), m.getResultParams(), m.getReportUrl());

      // DB更新ログ出力ロジック xie Start
      // 更新後データ取得、差分あれば、log出力
      try {
        if (setResult && updateCount > 0) {
          logCommon.updateLog();
        }
      } catch (Exception e) {
 //       e.printStackTrace();
      }
      // DB更新ログ出力ロジック xie End
      // 観察記録ログ出力 = 実施の場合
      if (m.getIsObserveRecordLog()) {
        // (更新)観察記録更新ログの出力
        writeUpdatedObserveRecordLog(m);
      }
    }
    //add 治療記録の観察記録修正 房 start
    if (m.getOrdNo() != null) {
      // 版確定フラグが「1：確定」の場合に「0：未確定」にする
      ordMainDao.updateIsConfirm(m.getOrdNo(), "1", "0");
    }
    //add 治療記録の観察記録修正 房 end
    /*mod FNSI-改修内容一括で複数イベントを登録された時、一括登録された２番目からのデータが削除できない。任 end*/
    return m;
  }

  @Override
  @Transactional
  public void delete(Long pat_event_cd) {
    List<PatEvent> m = patEventDao.selectByCd(pat_event_cd);
    if (m != null) {
      for (int i = 0; i < m.size(); i++) {
        patEventDao.delete(m.get(i));
      }
    }
  }

  @Override
  @Transactional
  public PatEvent updateBbsCtlNo(PatEvent m) {
    /*mod FNSI-改修内容一括で複数イベントを登録された時、一括登録された２番目からのデータが削除できない。任 start*/
    /*patEventDao.updateBbsCtlNo(m.getPatEventCd(), m.getBbsCtlNo());*/
    if(m.getBbsCtlNoList().size()==0){

      // DB更新ログ出力ロジック wangzuo Start
      String tableName = "pat_event";
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" pat_event_cd = " + m.getPatEventCd() + "\n");
      // logCommon設定
      DataUpdateLogCommonNew logCommon = getLogCommon(patEventDao, tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResult = logCommon.setInfo();
      // DB更新ログ出力ロジック wangzuo End

      int updateCount = patEventDao.updateBbsCtlNo(m.getPatEventCd(), m.getBbsCtlNo());

      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && updateCount > 0) {
        logCommon.updateLog();
      }
      // DB更新ログ出力ロジック wangzuo End

    }else{
      for(int i = 0;i < m.getBbsCtlNoList().size();i++){

        // DB更新ログ出力ロジック wangzuo Start
        String tableName = "pat_event";
        // SQL検索条件
        StringBuffer wheres = new StringBuffer("");
        wheres.append(" WHERE\n");
        wheres.append(" pat_event_cd = " + m.getPatEventCdList().get(i) + "\n");
        // logCommon設定
        DataUpdateLogCommonNew logCommon = getLogCommon(patEventDao, tableName, wheres, getEventLogMessage());
        // ログ出力カラム情報及び更新前データ情報取得
        boolean setResult = logCommon.setInfo();
        // DB更新ログ出力ロジック wangzuo End

        int updateCount = patEventDao.updateBbsCtlNo(m.getPatEventCdList().get(i), m.getBbsCtlNoList().get(i));

        // DB更新ログ出力ロジック wangzuo Start
        // 更新後データ取得、差分あれば、log出力
        if (setResult && updateCount > 0) {
          logCommon.updateLog();
        }
        // DB更新ログ出力ロジック wangzuo End
      }
    }
    /*mod FNSI-改修内容一括で複数イベントを登録された時、一括登録された２番目からのデータが削除できない。任 end*/
    return m;
  }

  @Override
  public PatEventMasterResponse findPatEventMaster(String facilityCd) {
    PatEventMasterResponse res = new PatEventMasterResponse();
    res.category = selectPatEventCategory(facilityCd);
    res.subCategory = selectPatEventSubCategory(facilityCd);
    res.template = selectPatEventTemplate(facilityCd);
    /*add FNSI-改修内容カテゴリ、サブカテゴリ、テンプレートが削除された或いは修正された場合、患者イベントの履歴の内容がもともとの内容で表示するように修正 任 start*/
    res.allCategory = selectAllPatEventCategory(facilityCd);
    res.allSubCategory = selectAllPatEventSubCategory(facilityCd);
    res.allTemplate = selectAllPatEventTemplate(facilityCd);
    /*add FNSI-改修内容カテゴリ、サブカテゴリ、テンプレートが削除された或いは修正された場合、患者イベントの履歴の内容がもともとの内容で表示するように修正 任 end*/
    return res;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstPatEventDataTemplate> selectPatEventTemplate(String facilityCd) {
    List<MstPatEventDataTemplate> templates = mstPatEventDataTemplateDao.selectByFacility(facilityCd);
    // mstSelectorから並び順を取得
    MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, "mst_pat_event_data_template");

    if (mstSelector != null) {
      // ソート後データ
      List<MstPatEventDataTemplate> sortedData = new ArrayList<>();

      // ソート用配列作成
      List<Long> sortedCodes = mstSelector.getOrderSettings().getItems()
          .stream().map(e -> e.getCode()).collect(Collectors.toList());

      // ソート用配列順にデータを並び替え
      for (Long sortedCode : sortedCodes) {
        for (MstPatEventDataTemplate item : templates) {
          if (sortedCode.equals(item.getTemplateCd())) {
            sortedData.add(item);
          }
        }
      }

      templates = sortedData;
    }
    return templates;
  }

  @Override
  public List<MstPatEventCategory> selectPatEventCategory(String facilityCd) {
    List<MstPatEventCategory> templates = mstPatEventCategoryDao.selectByFacility(facilityCd);
    // mstSelectorから並び順を取得
    MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, "mst_pat_event_category");

    if (mstSelector != null) {
      // ソート後データ
      List<MstPatEventCategory> sortedData = new ArrayList<>();

      // ソート用配列作成
      List<Long> sortedCodes = mstSelector.getOrderSettings().getItems()
          .stream().map(e -> e.getCode()).collect(Collectors.toList());

      // ソート用配列順にデータを並び替え
      for (Long sortedCode : sortedCodes) {
        for (MstPatEventCategory item : templates) {
          if (sortedCode.equals(item.getCategoryCd())) {
            sortedData.add(item);
          }
        }
      }

      templates = sortedData;
    }
    return templates;
  }

  @Override
  public List<MstPatEventSubCategory> selectPatEventSubCategory(String facilityCd) {
    List<MstPatEventSubCategory> templates = mstPatEventSubCategoryDao.selectByFacility(facilityCd);
    // mstSelectorから並び順を取得
    MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, "mst_pat_event_sub_category");

    if (mstSelector != null) {
      // ソート後データ
      List<MstPatEventSubCategory> sortedData = new ArrayList<>();

      // ソート用配列作成
      List<Long> sortedCodes = mstSelector.getOrderSettings().getItems()
          .stream().map(e -> e.getCode()).collect(Collectors.toList());

      // ソート用配列順にデータを並び替え
      for (Long sortedCode : sortedCodes) {
        for (MstPatEventSubCategory item : templates) {
          if (sortedCode.equals(item.getSubCategoryCd())) {
            sortedData.add(item);
          }
        }
      }

      templates = sortedData;
    }
    return templates;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<String> fetchStampTextCollection(String facilityCd) {

    List<String> resultValue = new ArrayList<>();

    // 施設設定から取得
    FacilitySettingInfo infoStampTextCollection = mstFacilitySettingDao.getBySettingNoAndCd(facilityCd,
        FacilitySettingNo.IMAGE_EDITOR_STAMP_TEXT_COLLECTION);

    if (Objects.isNull(infoStampTextCollection) || Objects.isNull(infoStampTextCollection.getValue())) {
      // 設定がない場合は空配列を返す
      return resultValue;
    }

    // 設定がある場合は改行コードで分割してリストを返す
    String settingValue = infoStampTextCollection.getValue();

    resultValue = Arrays.asList(settingValue.replaceAll("\r\n", "\n").split("\n"));

    return resultValue;
  }

  /**
   * ファイルダウンロード
   * S3からファイルをダウンロードして16進数文字列に変換する
   * @param filename
   * @return
   */
  public String downloadEventFileAttachment(String filepath, String facilityCd) throws Exception {
    String localStore = null;
    String status = null;
    String s3BucketInFcd = String.format(s3Bucket, facilityCd);
    try {
        Map<String, String> map = getLocalStoreAndStatus();
        localStore = map.get("localStore");
        status = map.get("status");
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
        throw e;
    }

    if (status.equals("on")) {
      String fileLocation = localStore + "/" + s3BucketInFcd + "/" + filepath;
      Path path = Paths.get(fileLocation);
      byte[] content = null;
      content = Files.readAllBytes(path);
      // 16進数文字列に変換
      String hexString = DatatypeConverter.printHexBinary(content);
      return hexString;
    } else {
      S3Object object = s3().getObject(new GetObjectRequest(s3BucketInFcd, filepath));

      // レスポンス用データ生成
      try (InputStream is = object.getObjectContent(); ByteArrayOutputStream os = new ByteArrayOutputStream();) {
        byte[] buffer = new byte[1024];
        while (true) {
          int len = is.read(buffer);
          if (len < 0) {
            break;
          }
          os.write(buffer, 0, len);
        }
        byte[] content = os.toByteArray();
        // 16進数文字列に変換
        String hexString = DatatypeConverter.printHexBinary(content);
        return hexString;
      } catch (Exception e) {
        throw e;
      }
    }
  }

  /**
   * ファイルアップロード (S3上)
   * @param file
   * @param patEvent
   */
  @Transactional
  public void uploadEventFileAttachment(MultipartFile file, String patEvent) throws Exception {
    String localStore = null;
    String status = null;
    try {
        Map<String, String> map = getLocalStoreAndStatus();
        localStore = map.get("localStore");
        status = map.get("status");
    } catch (Exception e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
        throw e;
    }
    String[] event = patEvent.split("&");
    String facility_cd = event[0];
    long pat_id = Long.parseLong(event[1]);
    long pat_event_cd = Long.parseLong(event[3]);
    long index = Long.parseLong(event[4]);
    String path = pat_id + "/" + pat_event_cd + "/file/" + index + "/"
        + file.getOriginalFilename();
    String s3BucketInFcd = String.format(s3Bucket, facility_cd);
    if (status.equals("on")) {
      String fileLocation = localStore + "/" + s3BucketInFcd + "/" + path;
      Path filePath = Paths.get(fileLocation);
      byte[] bytes = file.getBytes();
      if (!Files.exists(filePath)) {

        Files.createDirectories(filePath.getParent());
        File newFile = new File(filePath.toString());
        newFile.createNewFile();
      }
      Files.write(filePath, bytes);
    } else {
      try (InputStream inputStream = file.getInputStream()) {

        s3().deleteObject(new DeleteObjectRequest(s3BucketInFcd, path));
        ObjectMetadata metadata = new ObjectMetadata();
        metadata.setContentLength(file.getSize());
        // S3アップロード
        s3().putObject(new PutObjectRequest(s3BucketInFcd, path, file.getInputStream(), metadata));
        // DB更新
        //        patEventDao.updateOnlyResultParams(pat_event_cd, result_params);
      } catch (Exception e) {
        throw e;
      }
    }
  }

    /**
     * ファイル削除 (S3上)
     *
     * @param filename
     */
    @Transactional
    public void deleteEventFileAttachment(List<Map<String, String>> fileInfoList, Long pat_id, String facilityCd) throws Exception {
        String localStore = null;
        String status = null;
        String s3BucketInFcd = null;
        try {
            s3BucketInFcd = String.format(s3Bucket, facilityCd);
            Map<String, String> map = getLocalStoreAndStatus();
            localStore = map.get("localStore");
            status = map.get("status");
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
            throw e;
        }
        for (Map<String, String> fileInfo : fileInfoList) {
            String path = fileInfo.get("file_path");
            if (status.equals("on")) {
                String fileLocation = localStore + "/" + s3BucketInFcd + "/" + path;
                Path pathFile = Paths.get(fileLocation);
                pathFile.toFile().delete();
            } else {
                if (!path.isEmpty()) {
                    // S3ファイル削除
                    s3().deleteObject(new DeleteObjectRequest(s3BucketInFcd, path));
                }
            }
        }
    }

    /**
     * オンプレミス設定の取得
     * @return
     * @throws Exception
     */
    private Map<String, String> getLocalStoreAndStatus() throws Exception {
        String localStore = null;
        String status = null;
        SysSystemDefine data = sysSystemDefineDao.selectOnPremise(CoreConstant.SysSystemDefine.CTL_NO_ON_PREMISE);
        ObjectMapper objectMapper = new ObjectMapper();
        HashMap<String, String> onPremise = objectMapper.readValue(data.getValue(),
                new TypeReference<HashMap<String, String>>() {
                });
        localStore = onPremise.get("path");
        status = onPremise.get("status");
        Map<String, String> mapResult = new HashMap<>();
        mapResult.put("localStore", localStore);
        mapResult.put("status", status);
        return mapResult;
    }

  /**
   * キャッシュファイル名の生成.
   *
   * @param baseName ベースファイル名
   * @param upDate 帳票ファイル更新日時
   * @return 帳票キャッシュファイル名
   */
  private File getCacheFile(String baseName, Timestamp upDate) {
    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
    String name = String.format("%s.%s.cache",
        baseName,
        upDate != null ? sdf.format(upDate) : "");
    return new File(this.cacheDir, name);
  }

  /**
   * 画像ファイルダウンロード
   * S3からファイルをダウンロードして16進数文字列に変換する
   * @param filename
   * @return
   */
  public String downloadEventImageAttachment(String filePath, Timestamp upDate, String facilityCd) throws Exception {

    // キャッシュファイルパスの生成
    String baseName = filePath.replace("/", "_");
    File cacheFile = getCacheFile(baseName, upDate);
    //AmazonS3Client s3 = new AmazonS3Client();
    long lastModified = 0L;

    String localStore = null;
    String status = null;
    String s3BucketInFcd = null;
    try {
      s3BucketInFcd = String.format(s3Bucket, facilityCd);
      SysSystemDefine data = sysSystemDefineDao.selectOnPremise(CoreConstant.SysSystemDefine.CTL_NO_ON_PREMISE);
      ObjectMapper objectMapper = new ObjectMapper();
      HashMap<String, String> onPremise = objectMapper.readValue(data.getValue(), new TypeReference<HashMap<String, String>>(){});
      localStore = onPremise.get("path");
      status = onPremise.get("status");
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
      throw e;
    }

    if (status.equals("on")) {
      String fileLocation = localStore + "/" + s3BucketInFcd + "/" + filePath;
      File file = new File(fileLocation);
      lastModified = file.lastModified();
    } else {
      lastModified = s3().getObjectMetadata(s3BucketInFcd, filePath).getLastModified().getTime();
    }

    try {
      // 古いキャッシュファイルを削除
      // 画像ファイルパスが等しく、更新日時部分が異なっているファイルを削除対象とする
      Path cacheDirPath = Paths.get(this.cacheDir);
      if (Files.exists(cacheDirPath)) {
        try (Stream<Path> streamFiles = Files.list(Paths.get(this.cacheDir))) {
          // Files.listを使用する場合はtry-with-resources構文で記載することによりファイルディスクリプタの解放漏れを予防する
          List<Path> files = streamFiles.collect(Collectors.toList());
          //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(files.toString());
          logService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
          //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end
          List<Path> files2 = files.stream()
                .filter(s -> s.getFileName().startsWith(cacheFile.getName()))
                .collect(Collectors.toList());
          //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
          eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(files2.toString());
          logService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
          //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end

          for (Path f : files2) {
            if (f.getFileName().toString().equals(cacheFile.getName())) {
              File ff = f.toFile();
              if (ff.lastModified() != lastModified) {
                ff.delete();
              }
            }
          }
        }
      } else {
        // キャッシュディレクトリを作成
        Files.createDirectories(cacheDirPath);
      }
      // キャッシュが存在したらその内容を返す
      if (cacheFile.exists()) {
        try {
          // キャッシュファイルのアクセス日時を更新
          BasicFileAttributeView view = Files.getFileAttributeView(cacheFile.toPath(), BasicFileAttributeView.class);
          view.setTimes(null, FileTime.fromMillis(System.currentTimeMillis()), null);
        } catch (Exception e) {
          // 最終アクセス時間更新失敗
        }
        byte[] content = Files.readAllBytes(cacheFile.toPath());
        // 16進数文字列に変換
        String hexString = DatatypeConverter.printHexBinary(content);
        return hexString;
      }
    } catch (IOException e) {
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

    if (status.equals("on")) {
      try {
        String fileLocation = localStore +  "/" + s3BucketInFcd + "/" + filePath;
        Path path = Paths.get(fileLocation);
        byte[] content = null;
        content = Files.readAllBytes(path);

        // キャッシュにデータを保存
        Files.write(cacheFile.toPath(), content);
        long lastModified2 = new File(fileLocation).lastModified();
        cacheFile.setLastModified(lastModified2);
        // 16進数文字列に変換
        String hexString = DatatypeConverter.printHexBinary(content);
        return hexString;
      } catch (Exception e) {
        throw e;
      }
    } else {
      S3Object object = s3().getObject(new GetObjectRequest(s3BucketInFcd, filePath));
      // レスポンス用データ生成
      try (
          InputStream is = object.getObjectContent();
          ByteArrayOutputStream os = new ByteArrayOutputStream();) {
        byte[] buffer = new byte[1024];
        while (true) {
          int len = is.read(buffer);
          if (len < 0) {
            break;
          }
          os.write(buffer, 0, len);
        }
        byte[] content = os.toByteArray();
        // キャッシュにデータを保存
        Files.write(cacheFile.toPath(), os.toByteArray());
        long lastModified2 = s3().getObjectMetadata(s3BucketInFcd, filePath).getLastModified().getTime();
        cacheFile.setLastModified(lastModified2);
        // 16進数文字列に変換
        String hexString = DatatypeConverter.printHexBinary(content);
        return hexString;
      } catch (Exception e) {
        throw e;
      }
    }
  }

  /**
   * 画像ファイルアップロード (S3上)
   * @param file
   */
  @Transactional
  public void uploadEventImageAttachment(MultipartFile file, String patEvent) throws Exception {
    try (InputStream inputStream = file.getInputStream()) {
      String[] event = patEvent.split("&");
      String facility_cd = event[0];
      long pat_id = Long.parseLong(event[1]);
      long pat_event_cd = Long.parseLong(event[3]);
      String field_name = event[4];
      Integer image_no = Integer.parseInt(event[5]);
      String path = pat_id + "/" + pat_event_cd + "/image/" + field_name + "-"
          + image_no + "/" + file.getOriginalFilename();
      String s3BucketInFcd = String.format(s3Bucket, facility_cd);

      String baseName = path.replace("/", "_");
      File cacheFile = getCacheFile(baseName, null);
      //AmazonS3Client s3 = new AmazonS3Client();
      //      long lastModified = 0;
      //      try {
      //          lastModified = s3.getObjectMetadata(s3Bucket, path).getLastModified().getTime();
      //        } catch (AmazonS3Exception ex) {
      //            if(ex.getStatusCode() == 404) {
      //              lastModified = 0;
      //            }
      //      }

      String localStore = null;
      String status = null;

      SysSystemDefine data = sysSystemDefineDao.selectOnPremise(CoreConstant.SysSystemDefine.CTL_NO_ON_PREMISE);
      ObjectMapper objectMapper = new ObjectMapper();
      HashMap<String, String> onPremise = objectMapper.readValue(data.getValue(), new TypeReference<HashMap<String, String>>(){});
      localStore = onPremise.get("path");
      status = onPremise.get("status");
      if (status.equals("on")) {
        String fileLocation = localStore + "/" + s3BucketInFcd + "/" + path;
        Path pathFile = Paths.get(fileLocation);
        if (!Files.exists(pathFile)) {
          Files.createDirectories(pathFile.getParent());
          File newFile = new File(pathFile.toString());
          newFile.createNewFile();
        }

        pathFile.toFile().delete();
        Files.write(pathFile, file.getBytes());
      } else {
        try {
          Path cacheDirPath = Paths.get(this.cacheDir);
          if (Files.exists(cacheDirPath)) {
            try (Stream<Path> streamFiles = Files.list(Paths.get(this.cacheDir))) {
              // Files.listを使用する場合はtry-with-resources構文で記載することによりファイルディスクリプタの解放漏れを予防する
              List<Path> files = streamFiles.collect(Collectors.toList());
              //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
              EventLogMessage eventLogMessage = new EventLogMessage();
              eventLogMessage.setLogMessage(files.toString());
              logService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
              //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end
              List<Path> files2 = files.stream()
                    .filter(s -> s.getFileName().startsWith(cacheFile.getName()))
                    .collect(Collectors.toList());
              //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
              eventLogMessage = new EventLogMessage();
              eventLogMessage.setLogMessage(files2.toString());
              logService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
              //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end

              for (Path f : files2) {
                if (f.getFileName().toString().equals(cacheFile.getName())) {
                  File ff = f.toFile();
                  if (ff.length() != file.getSize()) {
                    ff.delete();
                  }
                }
              }
            }
          } else {
            // キャッシュディレクトリを作成
            Files.createDirectories(cacheDirPath);
          }
          // キャッシュが存在したらその内容を返す
          if (cacheFile.exists()) {
            return;
          }
        }
        catch (IOException e) {
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
        }

        s3().deleteObject(new DeleteObjectRequest(s3BucketInFcd, path));
        ObjectMetadata metadata = new ObjectMetadata();
        metadata.setContentLength(file.getSize());
        // S3アップロード
        s3().putObject(new PutObjectRequest(s3BucketInFcd, path, file.getInputStream(), metadata));
        // キャッシュにデータを保存
        Files.write(cacheFile.toPath(), file.getBytes());
        long lastModified2 = s3().getObjectMetadata(s3BucketInFcd, path).getLastModified().getTime();
        cacheFile.setLastModified(lastModified2);
      }
    } catch (Exception e) {
      throw e;
    }
  }

  /**
   * 画像ファイル削除 (S3上)
   * @param filename
   */
  @Transactional
  public void deleteEventImageAttachment(List<Map<String, String>> fileInfoList, Long pat_id, String facilityCd) throws Exception {
    String localStore = null;
    String status = null;
    String s3BucketInFcd = null;

    try {
      s3BucketInFcd = String.format(s3Bucket, facilityCd);
      SysSystemDefine data = sysSystemDefineDao.selectOnPremise(CoreConstant.SysSystemDefine.CTL_NO_ON_PREMISE);
      ObjectMapper objectMapper = new ObjectMapper();
      HashMap<String, String> onPremise = objectMapper.readValue(data.getValue(), new TypeReference<HashMap<String, String>>(){});
      localStore = onPremise.get("path");
      status = onPremise.get("status");
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
      throw e;
    }

    for (Map<String, String> fileInfo : fileInfoList) {
      String path = fileInfo.get("file_path");

      String baseName = path.replace("/", "_");
      File cacheFile = getCacheFile(baseName, null);

      if (status.equals("on")) {
        String fileLocation = localStore + "/" + s3BucketInFcd + "/" + path;
        Path pathFile = Paths.get(fileLocation);
        pathFile.toFile().delete();
      } else {
        try {
          Path cacheDirPath = Paths.get(this.cacheDir);
          if (Files.exists(cacheDirPath)) {
            try (Stream<Path> streamFiles = Files.list(Paths.get(this.cacheDir))) {
              // Files.listを使用する場合はtry-with-resources構文で記載することによりファイルディスクリプタの解放漏れを予防する
              List<Path> files = streamFiles.collect(Collectors.toList());
              files.forEach(f -> {
                if (f.getFileName().toString().equals(cacheFile.getName())) {
                  f.toFile().delete();
                }
              });
            }
          }
        } catch (IOException e) {
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
        if (!path.isEmpty()) {
          // S3ファイル削除
          s3().deleteObject(new DeleteObjectRequest(s3BucketInFcd, path));
        }
      }
    }
  }

  // del #10894 患者イベントレイアウトマスタのファイル貼付サイズ上限がFNWより小さい ztc start
//  @Configuration
//  public class MultiPartConfigure {
//      @Bean
//      public MultipartConfigElement multipartConfigElement() {
//          MultipartConfigFactory factory = new MultipartConfigFactory();
//          factory.setMaxFileSize(DataSize.parse("10MB"));
//          factory.setMaxRequestSize(DataSize.parse("10MB"));
//          return factory.createMultipartConfig();
//      }
//  }
  // del #10894 患者イベントレイアウトマスタのファイル貼付サイズ上限がFNWより小さい ztc start
  /*add FNSI-改修内容患者イベント患者情報共有より改修 任 start*/
  @Override
  public Integer findPublicFlag(Long userId) {
    return mstPersonalUserDao.selectPublicFlag(userId);
  }
  /*add FNSI-改修内容患者イベント患者情報共有より改修 任 end*/
  /*add FNSI-改修内容カテゴリ、サブカテゴリ、テンプレートが削除された或いは修正された場合、患者イベントの履歴の内容がもともとの内容で表示するように修正 任 start*/
  public List<MstPatEventDataTemplate> selectAllPatEventTemplate(String facilityCd) {
    List<MstPatEventDataTemplate> templates = mstPatEventDataTemplateDao.selectAllByFacility(facilityCd);
    return templates;
  }


  public List<MstPatEventCategory> selectAllPatEventCategory(String facilityCd) {
    List<MstPatEventCategory> templates = mstPatEventCategoryDao.selectAllByFacility(facilityCd);
    return templates;
  }

  public List<MstPatEventSubCategory> selectAllPatEventSubCategory(String facilityCd) {
    List<MstPatEventSubCategory> templates = mstPatEventSubCategoryDao.selectAllByFacility(facilityCd);
    return templates;
  }
  /*add FNSI-改修内容カテゴリ、サブカテゴリ、テンプレートが削除された或いは修正された場合、患者イベントの履歴の内容がもともとの内容で表示するように修正 任 end*/

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
    eventLogMessage.setServiceName(LoggingConstant.MODULE_NAME.ADMIN_WEB + "," + LoggingConstant.SERVICE_NAME.FNSI);
    return eventLogMessage;
  }

  /**
   * ログ出力共通クラス設定、取得
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
  // DB更新ログ出力ロジック wangzuo End

  /*add FNSI-改修内容538 連携イベントの登録適正化 任 start*/
  @Override
  public String getPatEventTreatDate(Long ordNo) {
    OrdMain ordMain = ordMainDao.selectTreatDate(ordNo);
    if(ordMain!=null){
      return ordMain.getTreatDate();
    }else{
      SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyyMMdd");
      return simpleDateFormat.format(new Date());
    }
  }
  /*add FNSI-改修内容538 連携イベントの登録適正化 任 end*/

  // add FNSI-連携イベント作成・中止ツールを追加 ウ start
  /**
   * 患者情報データ取得
   * @param facility_cd 施設コード
   * @param dialysis_date_from 表示開始日(YYYYMMDD)
   * @param dialysis_date_to 表示終了日(YYYYMMDD)
   * @return 患者イベント（仮）のResponse
   */
  @Override
  public List<PatEventCoopInfo> searchPatInfo(String facility_cd, String dialysis_date_from, String dialysis_date_to,String strkbn) {

    List<Long> lstPatInfo = new ArrayList<>();
    List<PatEventCoopInfo> lstPatInfoReceive = new ArrayList<>();

    // add 2022-10-26 bug #6153 イベント作成処理に失敗する（ord_mainとpat_personal_mainのデータ不整合問題への対応） 孫 start
    List<PatEventCoopInfo> lstPatInfoNew = new ArrayList<>();
    // add 2022-10-26 bug #6153 イベント作成処理に失敗する（ord_mainとpat_personal_mainのデータ不整合問題への対応） 孫 end

    try {
      // 患者情報データ取得リスト
      //mod 20210820  #6141:パラメータを追加するstrkbn 鄭 start
      //lstPatInfoReceive = patEventDao.selectByFacilitycdDate(facility_cd, dialysis_date_from, dialysis_date_to);
      lstPatInfoReceive = patEventDao.selectByFacilitycdDate(facility_cd, dialysis_date_from, dialysis_date_to,strkbn);
      //mod 20210820  #6141:パラメータを追加するstrkbn 鄭 start
      List<Long> patIdList = new ArrayList<>();
      lstPatInfoReceive.forEach(s -> {
        if (s.getPat_id() != null) {
          patIdList.add(s.getPat_id());
        }
      });
      //mod 20210827  #6141:パラメータを追加するstrkbn 鄭 start
      //List<PatPersonalMain> sbil = ppmDao.selectByIdList(patIdList);
      // mod 9432 透析レポートの電文作成に失敗する　吉 start
      // List<PatPersonalMain> sbil = ppmDao.selectByPatIdList(patIdList);
      List<PatPersonalMain> sbil = new ArrayList<>();
      if(null != patIdList && patIdList.size()>0){
        int numberBatch = 32767;
        int number = patIdList.size()%numberBatch;
        int count = patIdList.size()/numberBatch;
        if(number>0){
          count= count+1;
        }
        for(int i = 0; i < count; i++){
          int end = numberBatch * (i + 1);
          if(end > patIdList.size()){
            end = patIdList.size();
          }
          List <PatPersonalMain> jumpList = new ArrayList<>();
          jumpList = ppmDao.selectByPatIdList(patIdList.subList(numberBatch * i , end));
          sbil.addAll(jumpList);
        }
      }
      // mod 9432 透析レポートの電文作成に失敗する　吉 end
      //mod 20210827  #6141:パラメータを追加するstrkbn 鄭 end
      for (int pos = 0; pos < lstPatInfoReceive.size(); pos++) {
        PatEventCoopInfo oiOne = lstPatInfoReceive.get(pos);

        // 患者ID一致するPatPersonalMainのデータを抽出
        PatPersonalMain ppmOne = sbil.stream().filter(one -> com.google.common.base.Objects.equal(one.getPat_id(), oiOne.getPat_id()))
          .findFirst().orElse(new PatPersonalMain());
        // add 2022-10-26 bug #6153 イベント作成処理に失敗する（ord_mainとpat_personal_mainのデータ不整合問題への対応） 孫 start
        if (ppmOne.getPat_id() == null) {
          EventLogMessage warnLogMessage = new EventLogMessage();
          warnLogMessage.setLogMessage("ord_main[pat_id=[" + oiOne.getPat_id() + "], ord_no=[" + oiOne.getOrd_no()
              + "], treat_date=" + oiOne.getTreat_date() + "]のデータはpat_personal_mainが無し。");
          logService.log(LogLevel.WARN, warnLogMessage, "searchPatInfo", "PatEventServiceImpl", "selectByIdList");

          continue;
        }
        // add 2022-10-26 bug #6153 イベント作成処理に失敗する（ord_mainとpat_personal_mainのデータ不整合問題への対応） 孫 end
        //mod 20210826  #6141:人の名前を追加または削除する 鄭 start
        String pln = ppmOne.getPat_last_name();
        if(!ppmOne.getIs_del().equals("0")){
          pln = "【削除済み】"+ppmOne.getPat_last_name();
        }

        //mod 20210826  #6141:人の名前を追加または削除する 鄭 start
        String pfn = ppmOne.getPat_first_name();

        oiOne.setPat_name((null == pln ? "" : pln) + " " + (null == pfn ? "" : pfn));
        oiOne.setHosp_pat_id(ppmOne.getHosp_pat_id());

        // add 2022-10-26 bug #6153 イベント作成処理に失敗する（ord_mainとpat_personal_mainのデータ不整合問題への対応） 孫 start
        lstPatInfoNew.add(oiOne);
        // add 2022-10-26 bug #6153 イベント作成処理に失敗する（ord_mainとpat_personal_mainのデータ不整合問題への対応） 孫 end
      }

    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // mod 2022-10-26 bug #6153 イベント作成処理に失敗する（ord_mainとpat_personal_mainのデータ不整合問題への対応） 孫 start
//      eventLogMessage.setLogMessage(e.getMessage());
      eventLogMessage.setLogMessage(e.getMessage()  + "[" + stackTraceToString(e) + "]" );
      // mod 2022-10-26 bug #6153 イベント作成処理に失敗する（ord_mainとpat_personal_mainのデータ不整合問題への対応） 孫 end
      logService.log(LogLevel.ERROR, eventLogMessage, "searchPatInfo", "PatEventServiceImpl", "selectByIdList");
      return null;
    }
    // mod 2022-10-26 bug #6153 イベント作成処理に失敗する（ord_mainとpat_personal_mainのデータ不整合問題への対応） 孫 start
//    return lstPatInfoReceive;
    return lstPatInfoNew;
    // mod 2022-10-26 bug #6153 イベント作成処理に失敗する（ord_mainとpat_personal_mainのデータ不整合問題への対応） 孫 end
  }

  // add 2022-10-26 bug #6153 イベント作成処理に失敗する（ord_mainとpat_personal_mainのデータ不整合問題への対応） 孫 start
  public String stackTraceToString(Exception e) {
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
    return errAdd;
  }
  // add 2022-10-26 bug #6153 イベント作成処理に失敗する（ord_mainとpat_personal_mainのデータ不整合問題への対応） 孫 mod
  // add FNSI-連携イベント作成・中止ツールを追加 ウ end

  // add 20210820 #61411： FNSI-連携イベント中止ツールを追加 鄭 start
  /**
   * 患者情報データ取得
   * @param facility_cd 施設コード
   * @param dialysis_date_from 表示開始日(YYYYMMDD)
   * @param dialysis_date_to 表示終了日(YYYYMMDD)
   * @param strSyubetu 表示種別
   * @return 患者イベント（仮）のResponse
   */
  @Override
  public List<PatEventCoopInfo> searchStopPatInfo(String facility_cd, String dialysis_date_from, String dialysis_date_to,String strSyubetu) {

    List<Long> lstPatInfo = new ArrayList<>();
    List<PatEventCoopInfo> lstPatInfoReceive = new ArrayList<>();

    try {
      // 患者情報データ取得リスト
      lstPatInfoReceive = sysCoopJournalDao.selectStopPatInfoDate(facility_cd, dialysis_date_from, dialysis_date_to,strSyubetu);

      List<Long> patIdList = new ArrayList<>();
      lstPatInfoReceive.forEach(s -> {
        if (s.getPat_id() != null) {
          patIdList.add(s.getPat_id());
        }
      });

      List<PatPersonalMain> sbil = ppmDao.selectByPatIdList(patIdList);

      for (int pos = 0; pos < lstPatInfoReceive.size(); pos++) {
        PatEventCoopInfo oiOne = lstPatInfoReceive.get(pos);

        // 患者ID一致するPatPersonalMainのデータを抽出
        PatPersonalMain ppmOne = sbil.stream().filter(one -> com.google.common.base.Objects.equal(one.getPat_id(), oiOne.getPat_id()))
          .findFirst().orElse(new PatPersonalMain());

        //mod 20210826  #6141:人の名前を追加または削除する 鄭 start
        String pln = ppmOne.getPat_last_name();
        if(!ppmOne.getIs_del().equals("0")){
          pln = "【削除済み】"+ppmOne.getPat_last_name();
        }
        //mod 20210826  #6141:人の名前を追加または削除する 鄭 start
        String pfn = ppmOne.getPat_first_name();

        oiOne.setPat_name((null == pln ? "" : pln) + " " + (null == pfn ? "" : pfn));
        oiOne.setHosp_pat_id(ppmOne.getHosp_pat_id());
      }

    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facility_cd != null) {
        eventLogMessage.setFacilityCd(facility_cd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "searchPatInfo", "PatEventServiceImpl", "selectByIdList");
      return null;
    }
    return lstPatInfoReceive;
  }
  // add 20210820 #61411：FNSI-連携イベント中止ツールを追加 鄭 end


// add 20210819 #61411： FNSI-追加検査オーダ作成 鄭 start
  /**
   * 患者情報データ取得
   * @param facility_cd 施設コード
   * @param dialysis_date_from 表示開始日(YYYYMMDD)
   * @param dialysis_date_to 表示終了日(YYYYMMDD)
   * @return 患者イベント（仮）のResponse
   */
  @Override
  // mod 9899 種別単位の検索条件が正しくない donghao start
  //public List<PatEventCoopInfo> searchPatExamInfo(String facility_cd, String dialysis_date_from, String dialysis_date_to) {
  public List<PatEventCoopInfo> searchPatExamInfo(String facility_cd, String dialysis_date_from, String dialysis_date_to,boolean phyFlg) {
  // mod 9899 種別単位の検索条件が正しくない donghao end
    List<Long> lstPatInfo = new ArrayList<>();
    List<PatEventCoopInfo> lstPatInfoReceive = new ArrayList<>();

    try {
      // 患者情報データ取得リスト
      // mod 9899 種別単位の検索条件が正しくない donghao start
      //lstPatInfoReceive = patExamMainDao.selectPatExamDate(facility_cd, dialysis_date_from, dialysis_date_to);
      lstPatInfoReceive = patExamMainDao.selectPatExamDate(facility_cd, dialysis_date_from, dialysis_date_to,phyFlg);
      // mod 9899 種別単位の検索条件が正しくない donghao end
      List<Long> patIdList = new ArrayList<>();
      lstPatInfoReceive.forEach(s -> {
        if (s.getPat_id() != null) {
          patIdList.add(s.getPat_id());
        }
      });

      List<PatPersonalMain> sbil = ppmDao.selectByPatIdList(patIdList);

      for (int pos = 0; pos < lstPatInfoReceive.size(); pos++) {
        PatEventCoopInfo oiOne = lstPatInfoReceive.get(pos);

        // 患者ID一致するPatPersonalMainのデータを抽出
        PatPersonalMain ppmOne = sbil.stream().filter(one -> com.google.common.base.Objects.equal(one.getPat_id(), oiOne.getPat_id()))
          .findFirst().orElse(new PatPersonalMain());

        //mod 20210826  #6141:人の名前を追加または削除する 鄭 start
        String pln = ppmOne.getPat_last_name();
        if(!ppmOne.getIs_del().equals("0")){
          pln = "【削除済み】"+ppmOne.getPat_last_name();
        }
        //mod 20210826  #6141:人の名前を追加または削除する 鄭 start
        String pfn = ppmOne.getPat_first_name();


        oiOne.setPat_name((null == pln ? "" : pln) + " " + (null == pfn ? "" : pfn));
        oiOne.setHosp_pat_id(ppmOne.getHosp_pat_id());
      }

    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facility_cd != null) {
        eventLogMessage.setFacilityCd(facility_cd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "searchPatInfo", "PatEventServiceImpl", "selectByIdList");
      return null;
    }
    return lstPatInfoReceive;
  }
  // add 20210819 #61411：FNSI-追加検査オーダ作成 鄭 end


  // add 20210820 #61411： FNSI-追加放射線検査オーダ作成 鄭 start
  /**
   * 患者情報データ取得
   * @param facility_cd 施設コード
   * @param dialysis_date_from 表示開始日(YYYYMMDD)
   * @param dialysis_date_to 表示終了日(YYYYMMDD)
   * @return 患者イベント（仮）のResponse
   */
  @Override
  public List<PatEventCoopInfo> searchPatRadInfo(String facility_cd, String dialysis_date_from, String dialysis_date_to) {

    List<Long> lstPatInfo = new ArrayList<>();
    List<PatEventCoopInfo> lstPatInfoReceive = new ArrayList<>();

    try {
      // 患者情報データ取得リスト
      // mod 9989 種別単位の検索条件が正しくない　donghao start
      //lstPatInfoReceive = patRadMainDao.selectPatRedMainDate(facility_cd, dialysis_date_from, dialysis_date_to);
      lstPatInfoReceive = patRadMainDao.selectPatRadMainDate(facility_cd, dialysis_date_from, dialysis_date_to);
     // mod 9989 種別単位の検索条件が正しくない　donghao end
      List<Long> patIdList = new ArrayList<>();
      lstPatInfoReceive.forEach(s -> {
        if (s.getPat_id() != null) {
          patIdList.add(s.getPat_id());
        }
      });

      List<PatPersonalMain> sbil = ppmDao.selectByPatIdList(patIdList);

      for (int pos = 0; pos < lstPatInfoReceive.size(); pos++) {
        PatEventCoopInfo oiOne = lstPatInfoReceive.get(pos);

        // 患者ID一致するPatPersonalMainのデータを抽出
        PatPersonalMain ppmOne = sbil.stream().filter(one -> com.google.common.base.Objects.equal(one.getPat_id(), oiOne.getPat_id()))
          .findFirst().orElse(new PatPersonalMain());

        //mod 20210826  #6141:人の名前を追加または削除する 鄭 start
        String pln = ppmOne.getPat_last_name();
        if(!ppmOne.getIs_del().equals("0")){
          pln = "【削除済み】"+ppmOne.getPat_last_name();
        }
        //mod 20210826  #6141:人の名前を追加または削除する 鄭 start
        String pfn = ppmOne.getPat_first_name();

        oiOne.setPat_name((null == pln ? "" : pln) + " " + (null == pfn ? "" : pfn));
        oiOne.setHosp_pat_id(ppmOne.getHosp_pat_id());
      }

    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      if (facility_cd != null) {
        eventLogMessage.setFacilityCd(facility_cd);
      }
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "searchPatInfo", "PatEventServiceImpl", "selectByIdList");
      return null;
    }
    return lstPatInfoReceive;
  }
  // add 20210820 #61411：FNSI-追加放射線検査オーダ作成 鄭 end



  // add 20210826 #61411： FNSI-追加処方情報連携作成 鄭 start
  /**
   * 連携イベント作成・中止ツールデータ取得
   * @param facility_cd 施設コード
   * @param dialysis_date_from 表示開始日(YYYYMMDD)
   * @param dialysis_date_to 表示終了日(YYYYMMDD)
   * @return 患者イベント（仮）のResponse
   */
  @Override
  public List<PatEventCoopInfo> searchOrdPrescriptionInfo(String facility_cd, String dialysis_date_from, String dialysis_date_to){

    List<Long> lstPatInfo = new ArrayList<>();
    List<PatEventCoopInfo> lstPatInfoReceive = new ArrayList<>();

    try {
      // 患者情報データ取得リスト
      lstPatInfoReceive = ordPrescriptionDao.selectOrdPrescriptionDate(facility_cd, dialysis_date_from, dialysis_date_to);

      List<Long> patIdList = new ArrayList<>();
      lstPatInfoReceive.forEach(s -> {
        if (s.getPat_id() != null) {
          patIdList.add(s.getPat_id());
        }
      });

      List<PatPersonalMain> sbil = ppmDao.selectByPatIdList(patIdList);

      for (int pos = 0; pos < lstPatInfoReceive.size(); pos++) {
        PatEventCoopInfo oiOne = lstPatInfoReceive.get(pos);

        // 患者ID一致するPatPersonalMainのデータを抽出
        PatPersonalMain ppmOne = sbil.stream().filter(one -> com.google.common.base.Objects.equal(one.getPat_id(), oiOne.getPat_id()))
          .findFirst().orElse(new PatPersonalMain());

        //mod 20210826  #6141:人の名前を追加または削除する 鄭 start
        String pln = ppmOne.getPat_last_name();
        if(!ppmOne.getIs_del().equals("0")){
          pln = "【削除済み】"+ppmOne.getPat_last_name();
        }
        //mod 20210826  #6141:人の名前を追加または削除する 鄭 start
        String pfn = ppmOne.getPat_first_name();

        oiOne.setPat_name((null == pln ? "" : pln) + " " + (null == pfn ? "" : pfn));
        oiOne.setHosp_pat_id(ppmOne.getHosp_pat_id());
      }

    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      if (facility_cd != null) {
        eventLogMessage.setFacilityCd(facility_cd);
      }
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "searchPatInfo", "PatEventServiceImpl", "selectByIdList");
      return null;
    }
    return lstPatInfoReceive;

  }
  // add 20210826 #61411：FNSI-追加処方情報連携作成 鄭 end



  // add 20210823 #61411：施設のリストを取得する  鄭 start

  /**
   * 施設のリストを取得する
   * @return
   */
  public List<String> getFacilityCdInfo() {
    try{
      List<String> FacilityCd= mastFacilityHashDao.selectFacilityCdInfo();
      // add #6142 施設の変更ができない 歴程 start
      if (FacilityCd != null && FacilityCd.size() > 0) {
        List<MstFacility> listFacilityInfo = mstFacilityDao.selectByFacilityCds(FacilityCd);
        if (listFacilityInfo != null && listFacilityInfo.size() > 0) {
          for (int i = 0; i < FacilityCd.size(); i++) {
            for (int j = 0; j < listFacilityInfo.size(); j++) {
              if (FacilityCd.get(i).equals(listFacilityInfo.get(j).getFacilityCd())) {
                FacilityCd.set(i, FacilityCd.get(i) + "/" + listFacilityInfo.get(j).getFacilityName());
                break;
              }
            }
          }
        }
      }
      // add #6142 施設の変更ができない 歴程 end
      return FacilityCd;
    }catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "searchPatInfo", "PatEventServiceImpl", "selectByIdList");
      return null;
    }
  }
  // add 20210823 #61411： 施設のリストを取得する 鄭 鄭 start



  /*add FNSI-改修内容患者イベント外结No.7 任 start*/
  @Override
  public List<SysFacility> getFacilityNameByCd() {
    return sysFacilityDao.getFacilityNameByCd();
  }
  /*add FNSI-改修内容患者イベント外结No.7 任 end*/

  /**
   * {@inheritDoc}
   */
  @Override
  public List<PatEvent> selectObserveRecordByCd(Long pat_event_cd) {
    return patEventDao.selectObserveRecordByCd(pat_event_cd);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<PatEvent> selectPatIntroLetterByCd(Long pat_event_cd) {
    return patEventDao.selectPatIntroLetterByCd(pat_event_cd);
  }
  //7342 add 紹介状のイベント日付が登録日になる 張 start
  /**
   * 紹介状を取得する
   */
  @Override
  /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */
  // public List<PatEvent> selectByLetterDate(long patId, String dialysis_date_from, String dialysis_date_to, String facilityCd){
  //   return patEventDao.selectByLetterDate(patId,dialysis_date_from, dialysis_date_to, facilityCd);
  public List<PatEvent> selectByLetterDate(long patId, String dialysis_date_from, String dialysis_date_to, String facilityCd, Integer patShareMode){
    return patEventDao.selectByLetterDate(patId,dialysis_date_from, dialysis_date_to, facilityCd, patShareMode);
  }
  //7342 add 紹介状のイベント日付が登録日になる 張 end

  /*add FNSI-改修内容redmine4763 任 start*/
  /* int k = 1;*/
  /*add FNSI-改修内容redmine4763 任 end*/
  // add by YangYongzhuang  2023-02-01 [CodeOptimization]  start /
  private List<PatEvent> createPatEventRec(PatEventRequest request) throws ParseException {
    List<PatEvent> datas = new ArrayList<PatEvent>();
    String startDateTime = "";
    String endDateTime = "";
    int mode = 0;
    int interval = 0;
    String[] intervalClass = null;
    int dateClass = 0;
    int weekNo = 0;
    int dayOfWeekNo = 0;
    Calendar calendarFrom = Calendar.getInstance();
    Calendar calendarTo = Calendar.getInstance();
    String startTime = request.getStartTime();
    String formatStartTime = StringUtils.isEmpty(startTime) ? null : startTime.replace(":", "");
    String endTime = request.getEndTime();
    String formatEndTime = StringUtils.isEmpty(endTime) ? null : endTime.replace(":", "");
    if (request.getMode() != null) {
      mode = Integer.parseInt(request.getMode());
    }
    if (request.getStartDate() != null) {
      SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd");
      Date date = null;
      date = df.parse(request.getStartDate());
      startDateTime = new SimpleDateFormat("yyyyMMddHHmmss").format(date);
      int sYear = Integer.parseInt(startDateTime.substring(0, 4));
      int sMonth = Integer.parseInt(startDateTime.substring(4, 6)) - 1;
      int sDays = Integer.parseInt(startDateTime.substring(6, 8));
      int sHour = Integer.parseInt("00");
      int sMinute = Integer.parseInt("00");
      int sSecond = Integer.parseInt("00");
      calendarFrom.set(sYear, sMonth, sDays, sHour, sMinute, sSecond);
    }
    if (request.getEndDate() != null) {
      SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd");
      Date date = null;
      date = df.parse(request.getEndDate());
      endDateTime = new SimpleDateFormat("yyyyMMddHHmmss").format(date);
      int eYear = Integer.parseInt(endDateTime.substring(0, 4));
      int eMonth = Integer.parseInt(endDateTime.substring(4, 6)) - 1;
      int eDays = Integer.parseInt(endDateTime.substring(6, 8));
      int eHour = Integer.parseInt("23");
      int eMinute = Integer.parseInt("59");
      int eSecond = Integer.parseInt("59");
      calendarTo.set(eYear, eMonth, eDays, eHour, eMinute, eSecond);
    }
    if (request.getInterval() != null) {
      if (mode == 2 || mode == 3) {
        interval = Integer.parseInt(request.getInterval()) + 1;
      } else {
        if (mode == 5) {
          weekNo = Integer.parseInt(request.getInterval().substring(0, 1)) + 1;
          dayOfWeekNo = Integer.parseInt(request.getInterval().substring(2, 3)) + 1;
        } else {
          interval = Integer.parseInt(request.getInterval());
        }
      }
    }
    if (request.getIntervalClass() != null) {
      intervalClass = request.getIntervalClass();
    }
    if (request.getDateClass() != null) {
      dateClass = Integer.parseInt(request.getDateClass());
    }

    Timestamp rangeStart = new Timestamp(calendarFrom.getTimeInMillis());
    Timestamp rangeEnd = new Timestamp(calendarTo.getTimeInMillis());

    String eventStartDate = null;
    String eventEndDate = null;
    boolean secondTime = false;
    switch (mode) {
      case 1:
        PatEvent patEventRec = new PatEvent();
        patEventRec = request.getPatEventParam();
        eventStartDate = generateEventDate(calendarFrom, startTime, 0);
        eventEndDate = generateEventDate(calendarFrom, endTime, dateClass);
        patEventRec.setEventStartDate(eventStartDate);
        patEventRec.setEventEndDate(eventEndDate);
        patEventRec.setEventStartTime(formatStartTime);
        patEventRec.setEventEndTime(formatEndTime);
        patEventRec.setEventStatus("1");
        datas.add(patEventRec);
        break;
      case 2:
        while (calendarFrom.before(calendarTo) || calendarFrom.equals(calendarTo)) {
          PatEvent rec = this.copyPatEventRec(request.getPatEventParam());
          /*add FNSI-改修内容redmine4763 任 start*/
          /*String inputParam = rec.getInputParams();
          JSONArray jsonArray = new JSONArray(inputParam);
          for(int i = 0;i < jsonArray.length();i++){
            String isRstCopy = (String)((JSONObject)jsonArray.get(i)).get("is_rst_copy");
            if("0".equals(isRstCopy) && k != 1){
              jsonArray.remove(i);
              i = i - 1;
            }
          }
          rec.setInputParams(jsonArray.toString());*/
          /*add FNSI-改修内容redmine4763 任 end*/
          eventStartDate = generateEventDate(calendarFrom, startTime, 0);
          eventEndDate = generateEventDate(calendarFrom, endTime, dateClass);
          if (secondTime) {
            rec.setResultParams(jsonGenerate(rec.getInputParams(), rec.getResultParams()).toString());
            rec.setScoreTotal(0);
            rec.setOrdNo(null);
            rec.setEventStatus("0");
          } else {
            rec.setEventStatus("1");
          }
          rec.setEventStartDate(eventStartDate);
          rec.setEventEndDate(eventEndDate);
          rec.setEventStartTime(formatStartTime);
          rec.setEventEndTime(formatEndTime);
          datas.add(rec);
          secondTime = true;
          calendarFrom.add(Calendar.DAY_OF_MONTH, interval);
          /*add FNSI-改修内容redmine4763 任 start*/
          /* k++;*/
          /*add FNSI-改修内容redmine4763 任 end*/
        }
        break;
      case 3:
        while (calendarFrom.before(calendarTo) || calendarFrom.equals(calendarTo)) {
          Calendar cal = (Calendar) calendarFrom.clone();
          cal.add(Calendar.DAY_OF_WEEK,
            cal.getFirstDayOfWeek() - cal.get(Calendar.DAY_OF_WEEK));
          for (int i = 0; i < 7; i++) {
            int week = cal.get(Calendar.DAY_OF_WEEK) - 1;
            if (intervalClass[week].endsWith("1")) {
              Timestamp eventDate = new Timestamp(cal.getTimeInMillis());
              eventStartDate = generateEventDate(cal, startTime, 0);
              eventEndDate = generateEventDate(cal, endTime, dateClass);
              int diff1 = rangeStart.compareTo(eventDate);
              int diff2 = rangeEnd.compareTo(eventDate);

              if (diff1 <= 0 && diff2 >= 0) {
                PatEvent rec = this.copyPatEventRec(request.getPatEventParam());
                /*add FNSI-改修内容redmine4763 任 start*/
               /* String inputParam = rec.getInputParams();
                JSONArray jsonArray = new JSONArray(inputParam);
                for(int j = 0;j < jsonArray.length();j++){
                  String isRstCopy = (String)((JSONObject)jsonArray.get(j)).get("is_rst_copy");
                  if("0".equals(isRstCopy) && k != 1){
                    jsonArray.remove(j);
                    j = j - 1;
                  }
                }
                rec.setInputParams(jsonArray.toString());*/
                /*add FNSI-改修内容redmine4763 任 end*/
                if (secondTime) {
                  rec.setResultParams(jsonGenerate(rec.getInputParams(), rec.getResultParams()).toString());
                  rec.setScoreTotal(0);
                  rec.setOrdNo(null);
                  rec.setEventStatus("0");
                } else {
                  rec.setEventStatus("1");
                }
                rec.setEventStartDate(eventStartDate);
                rec.setEventEndDate(eventEndDate);
                rec.setEventStartTime(formatStartTime);
                rec.setEventEndTime(formatEndTime);
                datas.add(rec);
                secondTime = true;
              }
            }
            cal.add(Calendar.DAY_OF_MONTH, 1);
          }
          calendarFrom.add(Calendar.WEEK_OF_MONTH, interval);
          /*add FNSI-改修内容redmine4763 任 start*/
          /* k++;*/
          /*add FNSI-改修内容redmine4763 任 end*/
        }
        break;
      case 4:
        Calendar ccalFrom = (Calendar) calendarFrom.clone();
        while (calendarFrom.before(calendarTo) || calendarFrom.equals(calendarTo)) {
          Calendar cal = (Calendar) calendarFrom.clone();
          cal.set(Calendar.DATE, interval);
          int month = cal.get(Calendar.MONTH);
          if (intervalClass[month].endsWith("1")) {
            if (cal.after(ccalFrom) && cal.before(calendarTo)) {
              PatEvent rec = this.copyPatEventRec(request.getPatEventParam());
              /*add FNSI-改修内容redmine4763 任 start*/
              /*String inputParam = rec.getInputParams();
              JSONArray jsonArray = new JSONArray(inputParam);
              for(int i = 0;i < jsonArray.length();i++){
                String isRstCopy = (String)((JSONObject)jsonArray.get(i)).get("is_rst_copy");
                if("0".equals(isRstCopy) && k != 1){
                  jsonArray.remove(i);
                  i = i - 1;
                }
              }
              rec.setInputParams(jsonArray.toString());*/
              /*add FNSI-改修内容redmine4763 任 end*/
              if (secondTime) {
                rec.setResultParams(jsonGenerate(rec.getInputParams(), rec.getResultParams()).toString());
                rec.setScoreTotal(0);
                rec.setOrdNo(null);
                rec.setEventStatus("0");
              } else {
                rec.setEventStatus("1");
              }
              eventStartDate = generateEventDate(cal, startTime, 0);
              eventEndDate = generateEventDate(cal, endTime, dateClass);
              rec.setEventStartDate(eventStartDate);
              rec.setEventEndDate(eventEndDate);
              rec.setEventStartTime(formatStartTime);
              rec.setEventEndTime(formatEndTime);
              datas.add(rec);
              secondTime = true;
            }
          }
          calendarFrom.add(Calendar.MONTH, 1);
          /*add FNSI-改修内容redmine4763 任 start*/
          /* k++;*/
          /*add FNSI-改修内容redmine4763 任 end*/
        }
        break;
      case 5:
        Calendar calFrom = (Calendar) calendarFrom.clone();
        while (calendarFrom.before(calendarTo) || calendarFrom.equals(calendarTo)) {
          Calendar cal = (Calendar) calendarFrom.clone();

          int month = cal.get(Calendar.MONTH);
          if (intervalClass[month].endsWith("1")) {
            //第何週の曜日より日付を算出
            SimpleDateFormat format = new SimpleDateFormat("yyyy/MM/dd");
            Calendar calInfo = Calendar.getInstance();
            calInfo.set(cal.get(Calendar.YEAR), cal.get(Calendar.MONTH), 1);
            calInfo.set(Calendar.DAY_OF_WEEK_IN_MONTH, weekNo);
            calInfo.set(Calendar.DAY_OF_WEEK, dayOfWeekNo);
            //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(format.format(calInfo.getTime()));
            logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_PAT_EVENT, LoggingConstant.SERVICE_NAME.FNSI, null);
            //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end

            if (calInfo.after(calFrom) && calInfo.before(calendarTo)) {
              PatEvent rec = this.copyPatEventRec(request.getPatEventParam());
              /*add FNSI-改修内容redmine4763 任 start*/
              /*String inputParam = rec.getInputParams();
              JSONArray jsonArray = new JSONArray(inputParam);
              for(int i = 0;i < jsonArray.length();i++){
                String isRstCopy = (String)((JSONObject)jsonArray.get(i)).get("is_rst_copy");
                if("0".equals(isRstCopy) && k != 1){
                  jsonArray.remove(i);
                  i = i - 1;
                }
              }
              rec.setInputParams(jsonArray.toString());*/
              /*add FNSI-改修内容redmine4763 任 end*/
              if (secondTime) {
                rec.setResultParams(jsonGenerate(rec.getInputParams(), rec.getResultParams()).toString());
                rec.setScoreTotal(0);
                rec.setOrdNo(null);
                rec.setEventStatus("0");
              } else {
                rec.setEventStatus("1");
              }
              eventStartDate = generateEventDate(calInfo, startTime, 0);
              eventEndDate = generateEventDate(calInfo, endTime, dateClass);
              rec.setEventStartDate(eventStartDate);
              rec.setEventEndDate(eventEndDate);
              rec.setEventStartTime(formatStartTime);
              rec.setEventEndTime(formatEndTime);
              datas.add(rec);
              secondTime = true;
            }
          }
          calendarFrom.add(Calendar.MONTH, 1);
          /*add FNSI-改修内容redmine4763 任 start*/
          /* k++;*/
          /*add FNSI-改修内容redmine4763 任 end*/
        }
        break;
      default:
        // 式の値がどのcaseの値とも一致しなかったときの処理
    }
    return datas;
  }

  private String generateEventDate(Calendar calendar, String time, Integer dateClass) {
    Calendar calendarEventDate = (Calendar) calendar.clone();
    int sHour = StringUtils.isEmpty(time) ? 0 : Integer.parseInt(time.substring(0, 2));
    int sMinute = StringUtils.isEmpty(time) ? 0 : Integer.parseInt(time.substring(3, 5));
    calendarEventDate.set(calendar.get(Calendar.YEAR), calendar.get(Calendar.MONTH),
      calendar.get(Calendar.DATE), sHour, sMinute, 0);
    calendarEventDate.add(Calendar.DATE, dateClass);
    Date date = calendarEventDate.getTime();
    SimpleDateFormat format = new SimpleDateFormat("yyyyMMdd");
    String dateStr = format.format(date);
    return dateStr;
  }

  private PatEvent copyPatEventRec(PatEvent bRec) {
    PatEvent rec = new PatEvent();
    rec.setPatId(bRec.getPatId());
    rec.setFacilityCd(bRec.getFacilityCd());
    rec.setFnCtlNo(bRec.getFnCtlNo());
    rec.setEventStatus(bRec.getEventStatus());
    rec.setTemplateCd(bRec.getTemplateCd());
    rec.setTemplateName(bRec.getTemplateName());
    rec.setCategoryCd(bRec.getCategoryCd());
    rec.setCategoryName(bRec.getCategoryName());
    rec.setUseType(bRec.getUseType());
    rec.setOrdNo(bRec.getOrdNo());
    rec.setInputParams(bRec.getInputParams());
    rec.setSubCategoryCd(bRec.getSubCategoryCd());
    rec.setSubCategoryName(bRec.getSubCategoryName());
    rec.setResultParams(bRec.getResultParams());
    rec.setScoreTotal(bRec.getScoreTotal());
    rec.setRegStaffInfo(bRec.getRegStaffInfo());
    rec.setUpStaffInfo(bRec.getUpStaffInfo());
    rec.setBbsCtlNo(bRec.getBbsCtlNo());
    rec.setIsNewest(bRec.getIsNewest());
    rec.setIsDel(bRec.getIsDel());
    /*add FNSI-改修内容転入転出の患者情報連動 任 start*/
    rec.setReportUrl(bRec.getReportUrl());
    rec.setReportDate(bRec.getReportDate());
    /*add FNSI-改修内容転入転出の患者情報連動 任 end*/
    rec.setProcState(bRec.getProcState());
    rec.setIsObserveRecordLog(bRec.getIsObserveRecordLog());
    rec.setFindOrdNo(bRec.getFindOrdNo());
    rec.setTemplateLayoutDiff(bRec.getTemplateLayoutDiff());
    rec.setObserveRecordDiff(bRec.getObserveRecordDiff());
    return rec;
  }

  private JSONArray jsonGenerate(String inputParams, String resultParams) {
    List<Integer> formatClassList = new ArrayList<Integer>();
    List<String> isRstCopyList = new ArrayList<String>();

    JSONArray resultJsonArray = new JSONArray(resultParams);
    JSONArray inputJsonArray = new JSONArray(inputParams);
    for (int i = 0; i < inputJsonArray.length(); i++) {
      JSONObject jsonObject = inputJsonArray.getJSONObject(i);
      formatClassList.add((Integer) jsonObject.get("format_class"));
      isRstCopyList.add(jsonObject.has("is_rst_copy") ? jsonObject.get("is_rst_copy").toString() : "0");
    }
    JSONArray jsonArr = new JSONArray();
    int idx = 0;
    for (Iterator<Integer> it = formatClassList.iterator(); it.hasNext();) {
      int classNum = it.next();
      JSONObject json = new JSONObject();
      switch (classNum) {
        case PatEventUtils.PAT_EVENT_TEXT:
        case PatEventUtils.PAT_EVENT_TEXT_AREA:
        case PatEventUtils.PAT_EVENT_DATE:
        case PatEventUtils.PAT_EVENT_CALC_SOCORE:
        case PatEventUtils.PAT_EVENT_ORDER_LINK:
          if (isRstCopyList.get(idx).equals("1")) {
            json = resultJsonArray.getJSONObject(idx);
          } else {
            json.put("format_class", classNum);
            json.put("result_value", "");
          }
          break;
        case PatEventUtils.PAT_EVENT_FILE:
        case PatEventUtils.PAT_EVENT_IMAGE:
        case PatEventUtils.PAT_EVENT_LIST:
        case PatEventUtils.PAT_EVENT_RADIO:
        case PatEventUtils.PAT_EVENT_CHECK:
          if (isRstCopyList.get(idx).equals("1")) {
            json = resultJsonArray.getJSONObject(idx);
          } else {
            json.put("format_class", classNum);
            json.put("result_value", new JSONArray());
          }
          break;
      }
      jsonArr.put(json);
      idx++;
    }
    return jsonArr;
  }
  // add by YangYongzhuang  2023-02-01 [CodeOptimization]  End /
  // add #9273 施設設定マスタのNo105の設定どおり動かない。  start
  /**
   * イベント削除
   */
  @Override
  public void deleteEventAndBbs(String facilityCd, Long patId, String eventStartDate) {
    List<PatEvent> patEvents = patEventDao.selectByPatIdAndEventStartDate(facilityCd, patId, eventStartDate);
    patEvents = patEvents.stream().filter(x -> x.getOrdNo() == null || x.getOrdNo() == 0).collect(Collectors.toList());
    List<PatEvent> hasBbsList = patEvents.stream().filter(x -> x.getBbsCtlNo() != 0).collect(Collectors.toList());
    if (hasBbsList.size() > 0) {
      hasBbsList.forEach(x -> {
        try {
          bbsInfoService.deleteBbs(x.getBbsCtlNo());
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
      });
    }
    patEventDao.deleteByPatIdAndEventStartDate(facilityCd, patId, eventStartDate);
  }

  @Override
  public List<PatEvent> selectByPatIdAndEventStartDate(String facilityCd, Long patId, String eventStartDate) {
    return patEventDao.selectByPatIdAndEventStartDate(facilityCd, patId, eventStartDate);
  }

  @Override
  public int updateNoticeDate(Long patEventCd, int dataNumber) {
    return patEventDao.updateNoticeDate(patEventCd,dataNumber);
  }

  @Override
  public void updateEventAndBbsDate(Long patEventCd, int dataNumber) {
    patEventDao.updateDateByCd(patEventCd.toString(), dataNumber);
    patEventDao.updateNoticeDate(patEventCd, dataNumber);
    PatEvent patEvent = patEventDao.selectInfoPatEvent(patEventCd);
    bbsInfoService.updateDateByCd(patEvent.getBbsCtlNo(), dataNumber);
  }

  // add #9273 施設設定マスタのNo105の設定どおり動かない。  end

  @Override
  // mod #12462 患者情報共有 zhao start
  //public int countObsRecByCondition(Long pat_id, String startDate, String endDate, List<Pair<Long, Long>> categoryDataList, String regStaffCd, String upStaffCd) {
  public int countObsRecByCondition(Long pat_id, String startDate, String endDate, List<Pair<Long, Long>> categoryDataList, String regStaffCd, String upStaffCd,
                                    String patShareMode, String otherFacilityCd) {
    // 共有チェックON＋マージ表示を選択
    if ("0".equals(patShareMode) && StringUtils.isEmpty(otherFacilityCd)) {
      NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
      List<PatEvent> patEventList = getShrPatInfo(pat_id, user.getFacilityCd());
      if (patEventList != null && !patEventList.isEmpty()) {
        return patEventDao.countObsRecByConditionShare(pat_id, startDate, endDate, categoryDataList, regStaffCd,
          upStaffCd, patEventList);
      }
    }
    // mod #12462 患者情報共有 zhao end
    return patEventDao.countObsRecByCondition(pat_id, startDate, endDate, categoryDataList, regStaffCd, upStaffCd);
  }

  @Override
  public List<PatEventShare> getObsRecByCondition(
      Long pat_id, String startDate, String endDate,
      // mod #12462 患者情報共有 zhao start
      //List<Pair<Long, Long>> categoryDataList, String regStaffCd, String upStaffCd, Integer offset) {
      List<Pair<Long, Long>> categoryDataList, String regStaffCd, String upStaffCd, Integer offset,
      String patShareMode, String otherFacilityCd) {
    // 共有チェックON＋マージ表示を選択
    if ("0".equals(patShareMode) && StringUtils.isEmpty(otherFacilityCd)) {
      NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
      List<PatEvent> patEventList = getShrPatInfo(pat_id, user.getFacilityCd());
      if (patEventList != null && !patEventList.isEmpty()) {
        return patEventDao.selectObsRecByConditionShare(pat_id, startDate, endDate, categoryDataList, regStaffCd,
          upStaffCd, offset, patEventList);
      }
    }
    // mod #12462 患者情報共有 zhao end
    return patEventDao.selectObsRecByCondition(pat_id, startDate, endDate, categoryDataList, regStaffCd, upStaffCd, offset);
  }
  /**
   * (新規)観察記録ログの出力
   * @param patEvent 患者イベント
   */
  private void writeCreatedObserveRecordLog(PatEvent patEvent) {
    // イベントログの作成
    EventLogMessage eventLogMessage = new EventLogMessage();
    try {
      // イベントログ(開始)の出力
      eventLogMessage.setLogMessage("(新規)観察記録ログの出力 開始");
      logService.log(LogLevel.INFO, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_PAT_EVENT, LoggingConstant.SERVICE_NAME.FNSI, null);
      // OrdMainの取得
      OrdMain ordMain = ordMainDao.selectByOrdNo(patEvent.getFindOrdNo());
      // サインインユーザーの取得
      NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
      // サインインユーザーIDの設定
      ordMain.setUpUserId(user.getUserId());
      // 処理日時の設定
      ordMain.setUpDate(new Timestamp(System.currentTimeMillis()));
      // 観察記録新規ログの出力
      writeObserveRecordInsertLog(patEvent, ordMain);
      // イベントログ(終了)の出力
      eventLogMessage.setLogMessage("(新規)観察記録ログの出力 終了");
      logService.log(LogLevel.INFO, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_PAT_EVENT, LoggingConstant.SERVICE_NAME.FNSI, null);
    } catch (Exception e) {
      // 例外処理
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (patEvent !=null && patEvent.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(patEvent.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_PAT_EVENT, LoggingConstant.SERVICE_NAME.FNSI, null);
    }
  }
  /**
   * (更新)観察記録ログの出力
   * @param patEvent 患者イベント
   */
  private void writeUpdatedObserveRecordLog(PatEvent patEvent) {
    // イベントログの作成
    EventLogMessage eventLogMessage = new EventLogMessage();
    try {
      // イベントログ(開始)の出力
      eventLogMessage.setLogMessage("(更新)観察記録ログの出力 開始");
      logService.log(LogLevel.INFO, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_PAT_EVENT, LoggingConstant.SERVICE_NAME.FNSI, null);
      // OrdMainの取得
      OrdMain ordMain = ordMainDao.selectByOrdNo(patEvent.getFindOrdNo());
      // サインインユーザーの取得
      NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
      // サインインユーザーIDの設定
      ordMain.setUpUserId(user.getUserId());
      // 処理日時の設定
      ordMain.setUpDate(new Timestamp(System.currentTimeMillis()));
      // 条件分岐
      if (patEvent.getProcState().equals("1")) {
        // ・処理区分 = "1"(新規)
        // 観察記録変更ログの出力
        writeObserveRecordUpdateLog(patEvent, ordMain, patEvent.getProcState());
      } else if (patEvent.getProcState().equals("2")) {
        // ・処理区分 = "2"(変更)
        // テンプレートレイアウト変更ログの出力
        writeTemplateLayoutUpdateLog(patEvent, ordMain);
        // 観察記録変更ログの出力
        writeObserveRecordUpdateLog(patEvent, ordMain, patEvent.getProcState());
      } else if (patEvent.getProcState().equals("3")) {
        // ・処理区分 = "3"(削除)
        // 観察記録削除ログの出力
        writeObserveRecordDeleteLog(patEvent, ordMain);
      }
      // イベントログ(終了)の出力
      eventLogMessage.setLogMessage("(更新)観察記録ログの出力 終了");
      logService.log(LogLevel.INFO, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_PAT_EVENT, LoggingConstant.SERVICE_NAME.FNSI, null);
    } catch (Exception e) {
      // 例外処理
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      if (patEvent !=null && patEvent.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(patEvent.getFacilityCd());
      }
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_PAT_EVENT, LoggingConstant.SERVICE_NAME.FNSI, null);
    }
  }
  /**
   * 観察記録新規ログの出力
   * @param patEvent 患者イベント
   * @param ordMain  ordMain
   */
  private void writeObserveRecordInsertLog(PatEvent patEvent, OrdMain ordMain) {
    // 実績履歴の作成
    String LOG_MESSAGE_ORD_MAIN_HIS = "観察記録：%s %s を新規登録";
    String message = String.format(LOG_MESSAGE_ORD_MAIN_HIS, patEvent.getCategoryName(), patEvent.getSubCategoryName());
    // 観察記録履歴の作成
    doMakeRstHistoryForObserveRecord(message, ordMain);
  }
  /**
   * 観察記録削除ログの出力
   * @param patEvent 患者イベント
   * @param ordMain  ordMain
   */
  private void writeObserveRecordDeleteLog(PatEvent patEvent, OrdMain ordMain) {
    // 初期化処理
    String getEventStartDateTime = "";
    // StringBuilderの作成
    StringBuilder sbDate = new StringBuilder();
    StringBuilder sbTime = new StringBuilder();
    // 日付
    sbDate.append(patEvent.getEventStartDate());
    sbDate.insert(4, "/");
    sbDate.insert(7, "/");
    // 時刻(任意)
    if (patEvent.getEventStartTime() != null && !patEvent.getEventStartTime().equals("")) {
      sbTime.append(patEvent.getEventStartTime());
      sbTime.insert(2, ":");
    }
    // 開始日時の取得
    getEventStartDateTime = patEvent.getEventStartTime() != null && !patEvent.getEventStartTime().equals("") ? sbDate.toString() + " " + sbTime.toString() : sbDate.toString();
    // 実績履歴の作成
    String LOG_MESSAGE_ORD_MAIN_HIS = "観察記録：%s %s の開始日時 %s を削除";
    String message = String.format(LOG_MESSAGE_ORD_MAIN_HIS, patEvent.getCategoryName(), patEvent.getSubCategoryName(), getEventStartDateTime);
    // 観察記録履歴の作成
    doMakeRstHistoryForObserveRecord(message, ordMain);
  }
  /**
   * テンプレートレイアウト変更ログの出力
   * @param patEvent 患者イベント
   * @param ordMain  ordMain
   */
  private void writeTemplateLayoutUpdateLog(PatEvent patEvent, OrdMain ordMain) {
    // JSONObjectの作成
    JSONArray jsonArray = new JSONArray(patEvent.getTemplateLayoutDiff());
    // テンプレートレイアウト差分件数 > "0"の場合
    if (jsonArray.length() > 0) {
      // テンプレートレイアウト差分処理
      for (int i = 0; i < jsonArray.length(); i++) {
        // テンプレートレイアウト差分の取得
        JSONObject diff = jsonArray.getJSONObject(i);
        // 実績履歴の作成
        String LOG_MESSAGE_ORD_MAIN_HIS = "観察記録：%s %s の %s フィールドを削除";
        String message = String.format(LOG_MESSAGE_ORD_MAIN_HIS, patEvent.getCategoryName(), patEvent.getSubCategoryName(), diff.getString("column_name"));
        // 観察記録履歴の作成
        doMakeRstHistoryForObserveRecord(message, ordMain);
      }
    }
  }
  /**
   * 観察記録変更ログの出力
   * @param patEvent  患者イベント
   * @param ordMain   ordMain
   * @param procState 処理区分
   */
  private void writeObserveRecordUpdateLog(PatEvent patEvent, OrdMain ordMain, String procState) {
    // JSONObjectの作成
    JSONArray jsonArray = new JSONArray(patEvent.getObserveRecordDiff());
    // 観察記録差分件数 > "0"の場合
    if (jsonArray.length() > 0){
      // 観察記録差分処理
      for (int i = 0; i < jsonArray.length(); i++) {
        // 初期化処理
        String LOG_MESSAGE_ORD_MAIN_HIS = "";
        String message = "";
        Boolean isCreateRstHistory = false;
        // 観察記録差分の取得
        JSONObject diff = jsonArray.getJSONObject(i);
        // 条件分岐
        if (diff.getInt("format_class") == 2) {
          // ■フォーマットクラス = "2"(画像)
          LOG_MESSAGE_ORD_MAIN_HIS = "観察記録：%s %s の %s %s を %s ⇒ %s ";
          // 条件分岐
          if (procState.equals("1")) {
            // ・処理区分 = "1"(新規)
            // 編集入力済の場合
            if (!diff.getString("new_value").equals("")) {
              // 実績履歴の作成
              message = String.format(LOG_MESSAGE_ORD_MAIN_HIS, patEvent.getCategoryName(), patEvent.getSubCategoryName(), diff.getString("column_name"), diff.getString("img_name"), NONE, diff.getString("new_value"));
              isCreateRstHistory = true;
            }
          } else if (procState.equals("2")) {
            // ・処理区分 = "2"(変更)
            // 条件分岐
            if (diff.getString("old_value").equals("") && !diff.getString("new_value").equals("")) {
              // 画像無 → 画像有
              // 実績履歴の作成
              message = String.format(LOG_MESSAGE_ORD_MAIN_HIS, patEvent.getCategoryName(), patEvent.getSubCategoryName(), diff.getString("column_name"), diff.getString("img_name"), NONE, diff.getString("new_value"));
              isCreateRstHistory = true;
            } else if (!diff.getString("old_value").equals("") && !diff.getString("new_value").equals("")) {
              // 画像有 → 画像有
              // ファイル更新済の場合(同名ファイル許容)
              if (diff.getString("is_modified").equals("1")) {
                // 実績履歴の作成
                message = String.format(LOG_MESSAGE_ORD_MAIN_HIS, patEvent.getCategoryName(), patEvent.getSubCategoryName(), diff.getString("column_name"), diff.getString("img_name"), diff.getString("old_value"), diff.getString("new_value"));
                isCreateRstHistory = true;
              }
            } else if (!diff.getString("old_value").equals("") && diff.getString("new_value").equals("")) {
              // 画像有 → 画像無
              // 実績履歴の作成
              message = String.format(LOG_MESSAGE_ORD_MAIN_HIS, patEvent.getCategoryName(), patEvent.getSubCategoryName(), diff.getString("column_name"), diff.getString("img_name"), diff.getString("old_value"), NONE);
              isCreateRstHistory = true;
            }
          }
        } else if (diff.getInt("format_class") == 7) {
          // ■フォーマットクラス = "7"(添付ファイル)
          // 条件分岐
          if (procState.equals("1")) {
            // ・処理区分 = "1"(新規)
            // 編集値入力済の場合
            if (!diff.getString("new_value").equals("")) {
              LOG_MESSAGE_ORD_MAIN_HIS = "観察記録：%s %s の %s に %s を追加";
              message = String.format(LOG_MESSAGE_ORD_MAIN_HIS, patEvent.getCategoryName(), patEvent.getSubCategoryName(), diff.getString("column_name"), diff.getString("new_value"));
              isCreateRstHistory = true;
            }
          } else if (procState.equals("2")) {
            // ・処理区分 = "2"(変更)
            // 条件分岐
            if (diff.getString("old_value").equals("") && !diff.getString("new_value").equals("")) {
              // 添付ファイル無 → 添付ファイル有・・・添付ファイルの追加
              // 実績履歴の作成
              LOG_MESSAGE_ORD_MAIN_HIS = "観察記録：%s %s の %s に %s を追加";
              message = String.format(LOG_MESSAGE_ORD_MAIN_HIS, patEvent.getCategoryName(), patEvent.getSubCategoryName(), diff.getString("column_name"), diff.getString("new_value"));
              isCreateRstHistory = true;
            } else if (!diff.getString("old_value").equals("") && !diff.getString("new_value").equals("")) {
              // 添付ファイル有 → 添付ファイル有・・・添付ファイルの変更
              // ファイル更新済の場合(同名ファイル許容)
              if (diff.getString("is_modified").equals("1")) {
                // 実績履歴の作成
                LOG_MESSAGE_ORD_MAIN_HIS = "観察記録：%s %s の %s を %s ⇒ %s ";
                message = String.format(LOG_MESSAGE_ORD_MAIN_HIS, patEvent.getCategoryName(), patEvent.getSubCategoryName(), diff.getString("column_name"), diff.getString("old_value"), diff.getString("new_value"));
                isCreateRstHistory = true;
              }
            } else if (!diff.getString("old_value").equals("") && diff.getString("new_value").equals("")) {
              // 添付ファイル有 → 添付ファイル無・・・添付ファイルの削除
              // 実績履歴の作成
              LOG_MESSAGE_ORD_MAIN_HIS = "観察記録：%s %s の %s の %s を削除";
              message = String.format(LOG_MESSAGE_ORD_MAIN_HIS, patEvent.getCategoryName(), patEvent.getSubCategoryName(), diff.getString("column_name"), diff.getString("old_value"));
              isCreateRstHistory = true;
            }
          }
        } else if (diff.getInt("format_class") == 8) {
          // ■フォーマットクラス = "8"(スコア計算)
          // 条件分岐
          if (procState.equals("1")) {
            // ・処理区分 = "1"(新規)
            // 編集値入力済の場合
            if (!diff.getString("new_value").equals("")) {
              // 実績履歴の作成
              LOG_MESSAGE_ORD_MAIN_HIS = "観察記録：%s %s の %s を %s ⇒ %s %s ";
              message = String.format(LOG_MESSAGE_ORD_MAIN_HIS, patEvent.getCategoryName(), patEvent.getSubCategoryName(), diff.getString("column_name"), NONE, diff.getString("new_value"), diff.getString("new_unit"));
              isCreateRstHistory = true;
            }
          } else if (procState.equals("2")) {
            // ・処理区分 = "2"(変更)
            // 初期値 ≠ 編集値の場合
            if (!diff.getString("old_value").equals(diff.getString("new_value"))) {
              // ベースメッセージの作成
              String BASE_LOG_MESSAGE_ORD_MAIN_HIS = "観察記録：%s %s の %s をX⇒Y";
              // 入力状況の取得
              Boolean isInputOldValue = !diff.getString("old_value").equals("") ? true : false;
              Boolean isInputNewValue = !diff.getString("new_value").equals("") ? true : false;
              // 条件分岐
              if (isInputOldValue && isInputNewValue) {
                // スコア計算値有 → スコア計算値有
                // 実績履歴の作成
                LOG_MESSAGE_ORD_MAIN_HIS = BASE_LOG_MESSAGE_ORD_MAIN_HIS.replaceAll("X", " %s %s ").replaceAll("Y", " %s %s ");
                message = String.format(LOG_MESSAGE_ORD_MAIN_HIS, patEvent.getCategoryName(), patEvent.getSubCategoryName(), diff.getString("column_name"), diff.getString("old_value"), diff.getString("old_unit"), diff.getString("new_value"), diff.getString("new_unit"));
                isCreateRstHistory = true;
              } else if (!isInputOldValue && isInputNewValue) {
                // スコア計算値無 → スコア計算値有
                // 実績履歴の作成
                LOG_MESSAGE_ORD_MAIN_HIS = BASE_LOG_MESSAGE_ORD_MAIN_HIS.replaceAll("X", " %s ").replaceAll("Y", " %s %s ");
                message = String.format(LOG_MESSAGE_ORD_MAIN_HIS, patEvent.getCategoryName(), patEvent.getSubCategoryName(), diff.getString("column_name"), NONE, diff.getString("new_value"), diff.getString("new_unit"));
                isCreateRstHistory = true;
              } else if (isInputOldValue && !isInputNewValue) {
                // スコア計算値有 → スコア計算値無
                // 実績履歴の作成
                LOG_MESSAGE_ORD_MAIN_HIS = BASE_LOG_MESSAGE_ORD_MAIN_HIS.replaceAll("X", " %s %s ").replaceAll("Y", " %s ");
                message = String.format(LOG_MESSAGE_ORD_MAIN_HIS, patEvent.getCategoryName(), patEvent.getSubCategoryName(), diff.getString("column_name"), diff.getString("old_value"), diff.getString("old_unit"), NONE);
                isCreateRstHistory = true;
              }
            }
          }
        } else if (diff.getInt("format_class") == 9) {
          // ■フォーマットクラス = "9"(実績リンク)
          LOG_MESSAGE_ORD_MAIN_HIS = "観察記録：%s %s の %s を %s ⇒ %s ";
          // 条件分岐
          if (procState.equals("1")) {
            // ・処理区分 = "1"(新規)
            // 条件分岐
            if (!diff.getString("old_value").equals("") && !diff.getString("new_value").equals("")) {
              // 実績リンク有 → 実績リンク有(例.治療記録 > 観察記録の場合)
              // 実績履歴の作成
              message = String.format(LOG_MESSAGE_ORD_MAIN_HIS, patEvent.getCategoryName(), patEvent.getSubCategoryName(), diff.getString("column_name"), diff.getString("old_value"), diff.getString("new_value"));
              isCreateRstHistory = true;
            } else if (!diff.getString("old_value").equals("") && diff.getString("new_value").equals("")) {
              // 実績リンク有 → 実績リンク無(例.治療記録 > 観察記録の場合)
              // 実績履歴の作成
              message = String.format(LOG_MESSAGE_ORD_MAIN_HIS, patEvent.getCategoryName(), patEvent.getSubCategoryName(), diff.getString("column_name"), diff.getString("old_value"), NONE);
              isCreateRstHistory = true;
            } else if (diff.getString("old_value").equals("") && !diff.getString("new_value").equals("")) {
              // 実績リンク無 → 実績リンク有(例.患者イベント・観察記録の場合)
              // 実績履歴の作成
              message = String.format(LOG_MESSAGE_ORD_MAIN_HIS, patEvent.getCategoryName(), patEvent.getSubCategoryName(), diff.getString("column_name"), NONE, diff.getString("new_value"));
              isCreateRstHistory = true;
            }
          } else if (procState.equals("2")) {
            // ・処理区分 = "2"(変更)
            // 初期値 ≠ 編集値の場合
            if (!diff.getString("old_value").equals(diff.getString("new_value"))) {
              // 実績履歴の作成
              message = String.format(LOG_MESSAGE_ORD_MAIN_HIS, patEvent.getCategoryName(), patEvent.getSubCategoryName(), diff.getString("column_name"), formatValue(diff.getString("old_value")), formatValue(diff.getString("new_value")));
              isCreateRstHistory = true;
            }
          }
        } else {
          // ■開始日時・テキストボックス・テキストエリア・リストボックス・ラジオボタン・チェックボックス・日付・掲示板リンク
          LOG_MESSAGE_ORD_MAIN_HIS = "観察記録：%s %s の %s を %s ⇒ %s ";
          // 条件分岐
          if (procState.equals("1")) {
            // ・処理区分 = "1"(新規)
            // 編集値入力済の場合
            if (!diff.getString("new_value").equals("")) {
              // 実績履歴の作成
              message = String.format(LOG_MESSAGE_ORD_MAIN_HIS, patEvent.getCategoryName(), patEvent.getSubCategoryName(), diff.getString("column_name"), NONE, diff.getString("new_value"));
              isCreateRstHistory = true;
            }
          } else if (procState.equals("2")) {
            // ・処理区分 = "2"(変更)
            // 差分チェック = 実施の場合
            if (diff.getString("is_diff_check").equals("1")) {
              // 初期値 ≠ 編集値の場合
              if (!diff.getString("old_value").equals(diff.getString("new_value"))) {
                // 実績履歴の作成
                message = String.format(LOG_MESSAGE_ORD_MAIN_HIS, patEvent.getCategoryName(), patEvent.getSubCategoryName(), diff.getString("column_name"), formatValue(diff.getString("old_value")), formatValue(diff.getString("new_value")));
                isCreateRstHistory = true;
              }
            } else {
              // 実績履歴の作成
              message = String.format(LOG_MESSAGE_ORD_MAIN_HIS, patEvent.getCategoryName(), patEvent.getSubCategoryName(), diff.getString("column_name"), formatValue(diff.getString("old_value")), formatValue(diff.getString("new_value")));
              isCreateRstHistory = true;
            }
          }
        }
        // 実績履歴の作成の場合
        if (isCreateRstHistory) {
          // 観察記録履歴の作成
          doMakeRstHistoryForObserveRecord(message, ordMain);
        }
      }
    }
  }
  /**
   * 表示変換
   * @param inputValue 入力値
   */
  private String formatValue(String inputValue) {
    // 入力値 = ""(未入力)の場合
    if (inputValue.equals("")) {
      return NONE;
    } else {
      return inputValue;
    }
  }
  /**
   * 観察記録履歴の作成
   * @param message 実績履歴内容
   * @param ordMain OrdMain
   */
  private void doMakeRstHistoryForObserveRecord(String message, OrdMain ordMain){
    // 実績履歴の作成
    OrdMainHisMongo ordMainHisMongo = new OrdMainHisMongo();
    // 治療番号
    ordMainHisMongo.setOrdNo(ordMain.getOrdNo().toString());
    // 版番号
    ordMainHisMongo.setRstEdition(ordMain.getRstEdition().toString());
    // 更新日時
    ordMainHisMongo.setUpDate(new SimpleDateFormat("yyyy/MM/dd HH:mm:ss.SSS").format(ordMain.getUpDate()));
    // 最終更新者ID
    ordMainHisMongo.setUpUserId(ordMain.getUpUserId() != null ? ordMain.getUpUserId().toString() : "");
    // メッセージ
    ordMainHisMongo.setMessage(message);
    // 実績履歴(MongoDB.rst_history)の登録
    logServiceCore.createOrdMainHis(ordMainHisMongo);
  }

  // add 10409 曜日パターン変更の患者イベント修正 関  start
  @Override
  public boolean searchLinkage(String facility_cd, String dialysis_date_from, String dialysis_date_to,Long pat_id) {
    List<OrdNoAndConnectedTableKeyData> connectedPatEventList = patEventDao.selectPatEventByIsOrder(facility_cd, dialysis_date_from, dialysis_date_to, pat_id);
    boolean linkageFlag = false;
    if (connectedPatEventList.size() > 0) {
      linkageFlag = true;
    }
    return linkageFlag;
  }
  // add 10409 曜日パターン変更の患者イベント修正 関  end

  // add #11717【因島】曜日パターン変更の動作が遅い fang start
  @Override
  public List<PatEvent> selectByOrdNos(String facilityCd, Long patId, List<Long> ordNos) {
    return patEventDao.selectByOrdNos(patId, facilityCd, ordNos);
  }
  // add #11717【因島】曜日パターン変更の動作が遅い fang end
  // add #12324 紹介状の出力時にpat_eventを参照する zhao start
  /**
   * 患者情報の紹介状データに「キー」と「sqlコード、データコード、インデックス、値」を保存する
   * @param patEvent 患者情報
   * @param mode "insert":新規登録;"update":更新
   */
  // mod #12402 紹介状の編集で画像の追加や差し替えができない zhao start
  //private void editLetterInfoForDb(PatEvent patEvent) {
  private void editLetterInfoForDb(PatEvent patEvent, String mode) {
    // mod #12402 紹介状の編集で画像の追加や差し替えができない zhao end
    if (patEvent == null) {
      return;
    }
    if(patEvent.getLetterInfo() == null || "".equals(patEvent.getLetterInfo())){
      return;
    }
    // add #12370 紹介状の転入の動作不正 zhao start
    // 転入の場合
    if(!StringUtils.isEmpty(patEvent.getReportUrl())){
      return;
    }
    // add #12370 紹介状の転入の動作不正 zhao end
    // 紹介状データを取得する
    String letterInfo = patEvent.getLetterInfo();
    try {
      ObjectMapper mapper = new ObjectMapper();
      // JSON文字列をJsonNodeに解析する
      JsonNode rootNode = mapper.readTree(letterInfo);
      // 帳票Cdを取得する
      // mod #12370 紹介状の転入の動作不正 zhao start
      //Long reportCd = rootNode.get("report_cd").asLong();
      String reportCd = rootNode.get("report_cd").asText("");
      // 管理番号の設定
      //String ctlNo = rootNode.get("ctlNo").asText();
      String ctlNo = rootNode.get("ctlNo").asText("");
      // 転入の場合
      if(StringUtils.isEmpty(reportCd)){
        return;
      }
      // 帳票情報を取得する
      //MstReport mstReport = mstReportDao.selectByCd(reportCd);
      // mod #12650 登録済み紹介状が帳票マスタ削除の影響を受けるのは不適切 zhao start
      //MstReport mstReport = mstReportDao.selectByCd(Long.valueOf(reportCd));
      MstReport mstReport = mstReportDao.selectByReportCd(Long.valueOf(reportCd));
      // mod #12650 登録済み紹介状が帳票マスタ削除の影響を受けるのは不適切 zhao end
      // mod #12370 紹介状の転入の動作不正 zhao end
      // 管理番号がある場合、mstReportを設定すること。
      if (!StringUtils.isEmpty(ctlNo)) {
        MstReport.ReportHstInfo hstInfo = mstReport.getReportHstInfo();
        for (MstReport.Item item : hstInfo.getItems()) {
          if (item.getCtlNo().equals(ctlNo)) {
            MstReport.ReportPath re = new MstReport.ReportPath();
            re.setReportZip(item.getReportZip());
            re.setBucket(item.getBucket());
            re.setXlsxZip(item.getXlsxZip());
            re.setXmlFilename(item.getXmlFilename());
            re.setHtmlFilename(item.getHtmlFilename());
            re.setXlsxFilename(item.getXlsxFilename());
            mstReport.setReportPath(re);
          }
        }
      }
      // S3から帳票定義XML、帳票デザインExcelが格納されたZipファイルを取得する
      ReportZipFile reportZipFile = getReportZip(mstReport);
      // SqlCodeをもとに帳票に出力する情報を取得する
      String reportXml = this.getReportXml(mstReport, reportZipFile);
      List<ReportXmlParam> params = ReportUtils.getParamElements(reportXml);
      if (params.size() > 0) {
        ObjectMapper objectMapper = new ObjectMapper();
        // キーと値の形を変更する
        Map<String, Object> letterDataMap = objectMapper.convertValue(rootNode.get("letter_data"),
          new TypeReference<Map<String, Object>>() {});
        ObjectNode letterDataNode = (ObjectNode) rootNode.get("letter_data");
        Map<String, Integer> indexMap = new HashMap<>();

        for (Map.Entry<String, Object> entry : letterDataMap.entrySet()) {
          // キーの取得
          String key = entry.getKey();
          // 値の取得
          String value = entry.getValue().toString();
          // add #12402 紹介状の編集で画像の追加や差し替えができない zhao start
          // テンプレートに存在するかどうか
          boolean xmlFlag = false;
          // add #12402 紹介状の編集で画像の追加や差し替えができない zhao end
          // XML内容をループする
          for (ReportXmlParam param : params) {
            // sqlコードを取得する
            String sqlCode = param.getSqlCode();
            // データコードを取得する
            String dataCode = param.getDataCode();
            // 同じデータコードとsqlコードの場合、インデックスを連番する、１から
            String indexKey = sqlCode + "_" + dataCode;
            // グループ以外項目
            if (key.equals(param.getId())) {
              // インデックスを取得する
              int index = indexMap.getOrDefault(indexKey, 0);
              // インデックスを更新する
              indexMap.put(indexKey, index + 1);
              // sqlコード、データコード、インデックス、値を設定する
              ObjectNode newValue = mapper.createObjectNode();
              newValue.put("sql_cd", sqlCode);
              newValue.put("field", dataCode);
              newValue.put("index", index + 1);
              // mod #12402 紹介状の編集で画像の追加や差し替えができない zhao start
              //newValue.put("value", value);
              newValue.put("value", changePathPatEventCd(value, patEvent.getPatEventCd(), mode, patEvent.getFacilityCd()));
              // mod #12402 紹介状の編集で画像の追加や差し替えができない zhao end
              if(param.getIsImage().equals("true")){
                newValue.put("path", getSqlResult(patEvent, sqlCode, dataCode));
                // add #12402 紹介状の編集で画像の追加や差し替えができない zhao start
                if(!StringUtils.isEmpty(value) && value.indexOf("data:image/png;base64") == -1){
                  newValue.put("path", changePathPatEventCd(value, patEvent.getPatEventCd(), mode, patEvent.getFacilityCd()));
                }
                // add #12402 紹介状の編集で画像の追加や差し替えができない zhao end
              }
              letterDataNode.set(key, newValue);
              // add #12402 紹介状の編集で画像の追加や差し替えができない zhao start
              xmlFlag = true;
              break;
              // add #12402 紹介状の編集で画像の追加や差し替えができない zhao end
            } else {
              // repeatAddressを取得する
              if(null != param.getGroupId() && !"".equals(param.getGroupId())) {
                String[] cells = param.getRepeatAddress().split(",");
                if (null != cells && cells.length > 0) {
                  for (String cell : cells) {
                    // mod #12402 紹介状の編集で画像の追加や差し替えができない zhao start
                    //if (key.contains(cell)) {
                    if (key.equals(cell)) {
                      // mod #12402 紹介状の編集で画像の追加や差し替えができない zhao end
                      // インデックスを取得する
                      int index = indexMap.getOrDefault(indexKey, 0);
                      // インデックスを更新する
                      indexMap.put(indexKey, index + 1);
                      // sqlコード、データコード、インデックス、値を設定する
                      ObjectNode newValue = mapper.createObjectNode();
                      newValue.put("sql_cd", sqlCode);
                      newValue.put("field", dataCode);
                      newValue.put("index", index + 1);
                      // mod #12402 紹介状の編集で画像の追加や差し替えができない zhao start
                      //newValue.put("value", value);
                      newValue.put("value", changePathPatEventCd(value, patEvent.getPatEventCd(), mode, patEvent.getFacilityCd()));
                      // mod #12402 紹介状の編集で画像の追加や差し替えができない zhao end
                      if(param.getIsImage().equals("true")){
                        newValue.put("path", getSqlResult(patEvent, sqlCode, dataCode));
                        // add #12402 紹介状の編集で画像の追加や差し替えができない zhao start
                        if(!StringUtils.isEmpty(value) && value.indexOf("data:image/png;base64") == -1){
                          newValue.put("path", changePathPatEventCd(value, patEvent.getPatEventCd(), mode, patEvent.getFacilityCd()));
                        }
                        // add #12402 紹介状の編集で画像の追加や差し替えができない zhao end
                      }
                      letterDataNode.set(key, newValue);
                      // add #12402 紹介状の編集で画像の追加や差し替えができない zhao start
                      xmlFlag = true;
                      break;
                      // add #12402 紹介状の編集で画像の追加や差し替えができない zhao end
                    }
                  }
                }
              }
            }
          }
          // add #12402 紹介状の編集で画像の追加や差し替えができない zhao start
          if(!xmlFlag){
            String updateValue = changePathPatEventCd(value, patEvent.getPatEventCd(), mode, patEvent.getFacilityCd());
            letterDataNode.put(key, updateValue);
          }
          // add #12402 紹介状の編集で画像の追加や差し替えができない zhao end
        }
        // rootNodeをフォーマットされたJSON文字列に変換する
        String updatedJson = objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(rootNode);
        patEvent.setLetterInfo(updatedJson);
      }
    } catch (JsonProcessingException e) {
      throw new RuntimeException(e);
    }
  }

  /**
   * 帳票Zipファイルを取得します.
   *
   * @param mstReport 帳票マスタEntity
   * @return 帳票Zipファイル
   */
  private ReportZipFile getReportZip(MstReport mstReport) {
    return new ReportZipFile(
      reportS3Service.getReportFile(
        mstReport.getReportPath().getBucket(),
        mstReport.getReportPath().getReportZip(),
        mstReport.getUpDate()));
  }

  /**
   * 帳票定義XMLを取得します.
   *
   * @param mstReport 帳票マスタEntity
   * @param reportZipFile 帳票Zipファイル
   * @return 帳票定義XML
   */
  private String getReportXml(MstReport mstReport, ReportZipFile reportZipFile) {
    // 帳票定義XMLファイルを取得する
    String reportXml = reportZipFile.getFileToString(mstReport.getReportPath().getXmlFilename());
    if (StringUtils.isEmpty(reportXml)) {
      List<String> fileList = reportZipFile.getFileToString();
      throw new NtssException("帳票定義XMLファイルを取得できません。"
        + "MstReport:[" + mstReport.getReportPath().getXmlFilename() + "]"
        + " ReportZipFile:[" + fileList.toString() + "]"
      );
    }
    return reportXml;
  }

  /**
   * 患者情報の紹介状データに「キー」と「値」のみを保存する
   *
   * @param patEventList 紹介状情報
   * @return 編集後紹介状情報
   */
  private List<PatEvent> editLetterInfoForScreenDisplay(List<PatEvent> patEventList){
    // JavaオブジェクトとJSONデータの間で変換を行うためのインスタンス化
    ObjectMapper mapper = new ObjectMapper();
    for(PatEvent patEvent : patEventList){
      // add #12370 紹介状の転入の動作不正 zhao start
      if(!StringUtils.isEmpty(patEvent.getReportUrl())){
        continue;
      }
      // add #12370 紹介状の転入の動作不正 zhao end
      // 紹介状データを取得する
      String jsonLetterInfo = patEvent.getLetterInfo();
      // 紹介状データがある場合、次処理を行う
      if (!StringUtils.isEmpty(jsonLetterInfo)) {
        try {
          // JSON文字列をJsonNodeに解析する
          JsonNode rootNode = mapper.readTree(jsonLetterInfo);
          // letter_dataを取得する
          JsonNode letterDataNode = rootNode.get("letter_data");
          if(letterDataNode != null && letterDataNode.isObject()){
            // JSON文字列から、キーと値を取得する
            Iterator<Map.Entry<String, JsonNode>> fields = letterDataNode.fields();
            while (fields.hasNext()) {
              Map.Entry<String, JsonNode> field = fields.next();
              // キーを取得する
              String fieldName = field.getKey();
              // 値を取得する
              JsonNode fieldValue = field.getValue();
              // 取得した値はJSON文字列かつ、valueを含める場合、値を取得する
              if (fieldValue.isObject() && fieldValue.has("value")) {
                String value = fieldValue.path("value").asText();
                // 対応したキーにvalueを再設定する（fieldValueのJSONのネストはなし）
                // mod #12402 紹介状の編集で画像の追加や差し替えができない zhao start
                //((ObjectNode) letterDataNode).put(fieldName, value);
                ((ObjectNode) letterDataNode).put(fieldName, getImageFromS3(value, patEvent.getFacilityCd()));
                // mod #12402 紹介状の編集で画像の追加や差し替えができない zhao end
              }
              // add #12402 紹介状の編集で画像の追加や差し替えができない zhao start
              else {
                ((ObjectNode) letterDataNode).put(fieldName, getImageFromS3(fieldValue.asText(), patEvent.getFacilityCd()));
              }
              // add #12402 紹介状の編集で画像の追加や差し替えができない zhao end
            }
            // rootNodeをフォーマットされたJSON文字列に変換する
            String modifiedJson = mapper.writerWithDefaultPrettyPrinter().writeValueAsString(rootNode);
            patEvent.setLetterInfo(modifiedJson);
          }
        } catch (JsonProcessingException e) {
          throw new RuntimeException(e);
        }
      }
    }
    return patEventList;
  }

  /**
   * パースを取得する
   *
   * @param patEvent 患者情報
   * @param sqlCode SQLコード
   * @param dataCode フィールド
   * @return フィールドに対する値を戻る
   */
  private String getSqlResult(PatEvent patEvent, String sqlCode, String dataCode) {
    Map<String, Object> tempDateKey = new HashMap<>();
    tempDateKey.put("patId", patEvent.getPatId());
    tempDateKey.put("facilityCd", patEvent.getFacilityCd());
    tempDateKey.put("fromDate", patEvent.getEventStartDate());
    tempDateKey.put("toDate", patEvent.getEventEndDate());
    List<Map<String, Object>> sqlResults = new ArrayList<>();
    try {
      sqlResults = sysDataSetService.getDataListAsync(Long.valueOf(sqlCode), tempDateKey, null).get();
    } catch (Exception ex) {
      return null;
    }
    if (sqlResults != null && sqlResults.size() > 0) {
      if (sqlResults.get(0).containsKey(dataCode)
        && sqlResults.get(0).get(dataCode) != null) {
        return sqlResults.get(0).get(dataCode).toString();
      }
    }
    return "";
  }
  // add #12324 紹介状の出力時にpat_eventを参照する zhao end
  // add #12402 紹介状の編集で画像の追加や差し替えができない zhao start
  /**
   * パースのpatEventCdに連番されたpatEventCdを切替する
   * 例：924/0/image/L7-0/image.png
   * →924/patEventCd/image/L7-0/image.png
   * @param path パース
   * @param patEventCd 患者イベントコード
   * @param mode "insert":新規登録;"update":更新
   * @param facilityCd 施設コード
   * @return path 編集したパース
   */
  private String changePathPatEventCd(String path, Long patEventCd, String mode, String facilityCd){
    if(StringUtils.isEmpty(path)){
      return path;
    }
    if(patEventCd == null){
      return path;
    }
    if("update".equals(mode)){
      return path;
    }
    if(path.contains("/") && path.contains("/image/")){
      String[] sourceParts = path.split("/");
      String[] parts = path.split("/");
      String updatedPath = path;
      if (parts.length > 1 && sourceParts.length > 1) {
        if(("0".equals(parts[1]) || !patEventCd.equals(parts[1]))){
          parts[1] = "" + patEventCd; // 0をpatEventCdに置き換える
          updatedPath = String.join("/", parts);
        }
        // コピーの場合、元パースのイメージをコピーする
        if(!"0".equals(sourceParts[1]) && !patEventCd.equals(sourceParts[1])){
          copyOutputFile(path, updatedPath, facilityCd);
        }
      }
      return updatedPath;
    }
    return path;
  }

  /**
   * S3からイメージを取得する
   * @param path パース
   * @param facilityCd 施設コード
   */
  private String getImageFromS3(String path, String facilityCd){
    if (StringUtils.isEmpty(path)) {
      return path;
    }
    if(path.contains("/") && path.contains("/image/")){
      // Getting images from S3 service
      String bucket = String.format(s3BucketForImage, facilityCd);
      byte[] excelBytes = reportS3Service.getOutputFileData(bucket, path);
      if (excelBytes == null || excelBytes.length == 0) {
        return ";path:" + path;
      }
      bucket = Base64.getEncoder().encodeToString(excelBytes);
      bucket = String.format("data:image/png;base64,%s", bucket);
      String styleValue = "max-width: 25px; max-height: 25px; display: block; cursor: pointer;";
      return "<img src='" + bucket  + "' style= '" + styleValue + "' />" + ";path:" + path;
    }
    return path;
  }

  /**
   * S3にパースをコピーする
   * @param sourcePath コピー元パース
   * @param targetPath コピー先パース
   * @param facilityCd 施設コード
   */
  private Path copyOutputFile(String sourcePath, String targetPath, String facilityCd) {

    // オンプレミス環境かの判定により取得先の判定 ( S3 or ローカルフォルダ )
    String localStore = "";
    String status = "";
    String bucket = "";
    Path source = null;
    Path target = null;
    try {
      bucket = String.format(s3BucketForImage, facilityCd);
      SysSystemDefine data = sysSystemDefineDao.selectOnPremise(CoreConstant.SysSystemDefine.CTL_NO_ON_PREMISE);
      ObjectMapper objectMapper = new ObjectMapper();
      HashMap<String, String> onPremise = objectMapper.readValue(data.getValue(), new TypeReference<HashMap<String, String>>(){});
      localStore = onPremise.get("path");
      status = onPremise.get("status");
      if (status.equals("off")) {
        source = Paths.get(bucket + "/" + sourcePath);
        target = Paths.get(bucket + "/" + targetPath);
      } else {
        String sourceLocation = localStore + "/" + bucket + "/" + sourcePath;
        String targetLocation = localStore + "/" + bucket + "/" + targetPath;
        source = Paths.get(sourceLocation);
        target = Paths.get(targetLocation);
      }
      if (!Files.exists(target)) {
        Files.createDirectories(target);
      }
      Files.copy(source, target, StandardCopyOption.REPLACE_EXISTING);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 add yangxuewang end
      return null;
    }
    return null;
  }
  // add #12402 紹介状の編集で画像の追加や差し替えができない zhao end
  // add #12462 患者情報共有 zhao start
  /**
   * 患者共有情報を取得する
   * @param patId 患者ID
   * @param facilityCd 施設コード
   * @return 患者共有情報
   */
  private List<PatEvent> getShrPatInfo(Long patId, String facilityCd){
    List<ShrPatInfo> shrPatInfoList = shrPatInfoDao.selectShrPatInfoByPatId(patId, facilityCd);
    if (shrPatInfoList != null && !shrPatInfoList.isEmpty()) {
      List<PatEvent> patEventList = shrPatInfoList.stream()
        .map(info -> {
          PatEvent patEvent = new PatEvent();
          patEvent.setPatId(info.getFromPatId());
          patEvent.setFacilityCd(info.getFromFacilityCd());
          return patEvent;
        })
        .collect(Collectors.toList());
      return patEventList;
    }
    return null;
  }
  /**
   * 患者共有情報を取得する
   * @param patId 患者ID
   * @param facilityCd 施設コード
   * @return 患者共有情報
   */
  public List<ShrPatInfo> getShrPatInfoForPatId(Long patId, String facilityCd){
    List<ShrPatInfo> shrPatInfoList = shrPatInfoDao.selectShrPatInfoByPatId(patId, facilityCd);
    return shrPatInfoList;
  }
  /**
   * 治療情報を取得する
   * @param ordNo オーダ番号
   * @return 治療情報
   */
  public OrdMain selectByOrdNo(Long ordNo) {
    return ordMainDao.selectByOrdNo(ordNo);
  }
  /**
   * 患者イベント情報を取得する
   * @param pat_id
   * @param event_start_date_from
   * @param event_start_date_to
   * @param facilityCd
   * @param patShareMode
   * @param otherFacilityCd
   * @param patEventCdList
   * @return 患者イベント情報
   */
  @Override
  public List<PatEventShare> selectByPatIdNewestShareForShare(Long pat_id, Timestamp event_start_date_from,
                                                      Timestamp event_start_date_to, String facilityCd,
                                                      String patShareMode,
                                                      String otherFacilityCd,
                                                      Long... patEventCdList) {
    // 「自施設のみ」以外を選択する、かつ「マージ表示」を選択する場合、マージ表示になる、以外は自施設表示になる
    if ("0".equals(patShareMode) && StringUtils.isEmpty(otherFacilityCd)) {
      List<PatEvent> patEventList = getShrPatInfo(pat_id, facilityCd);
      if(patEventList != null && !patEventList.isEmpty()){
        return patEventDao.selectByPatIdFacilitycdNewestShare(pat_id, event_start_date_from, event_start_date_to,
          facilityCd, patEventList, patEventCdList);
      }
    }
    return patEventDao.selectByPatIdNewestShare(pat_id, event_start_date_from, event_start_date_to, facilityCd, patEventCdList);
  }
  // add #12462 患者情報共有 zhao end
}
