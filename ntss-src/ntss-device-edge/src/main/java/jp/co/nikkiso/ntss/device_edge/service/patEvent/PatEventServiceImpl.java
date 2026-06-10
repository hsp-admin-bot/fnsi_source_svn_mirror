package jp.co.nikkiso.ntss.device_edge.service.patEvent;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.attribute.BasicFileAttributeView;
import java.nio.file.attribute.FileTime;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import javax.xml.bind.DatatypeConverter;

import io.micrometer.core.instrument.util.StringUtils;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.device_edge.service.LogService;
import org.seasar.doma.jdbc.Config;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.model.DeleteObjectRequest;
import com.amazonaws.services.s3.model.GetObjectRequest;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.PutObjectRequest;
import com.amazonaws.services.s3.model.S3Object;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.dao.MstPatEventCategoryDao;
import jp.co.nikkiso.ntss.core.dao.MstPatEventDataTemplateDao;
import jp.co.nikkiso.ntss.core.dao.MstPatEventSubCategoryDao;
import jp.co.nikkiso.ntss.core.dao.MstSelectorDao;
import jp.co.nikkiso.ntss.core.dao.PatEventDao;
import jp.co.nikkiso.ntss.core.dao.SysSystemDefineDao;
import jp.co.nikkiso.ntss.core.entity.MstPatEventCategory;
import jp.co.nikkiso.ntss.core.entity.MstPatEventDataTemplate;
import jp.co.nikkiso.ntss.core.entity.MstPatEventSubCategory;
import jp.co.nikkiso.ntss.core.entity.MstSelector;
import jp.co.nikkiso.ntss.core.entity.PatEvent;
import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;
import jp.co.nikkiso.ntss.device_edge.config.AwsConfiguration;
import jp.co.nikkiso.ntss.device_edge.response.patEvent.PatEventMasterResponse;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Service
public class PatEventServiceImpl implements PatEventService {
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
  @Autowired
  private LogService logService;
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end

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

  /**
   * 患者イベント用ファイル格納先フォルダ名
   */
  private final String PATEVNT_FOLDER = "P_EVENT/";

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
  private PatEventDao patEventDao;

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

  // DB更新ログ出力ロジック wangzuo Start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;
  @Autowired
  private LogServiceCore logServiceCore;
  // DB更新ログ出力ロジック wangzuo End

  @Override
  public List<PatEvent> selectByPatIdNewest(Long pat_id, Timestamp event_start_date_from,
      Timestamp event_start_date_to) {
    return patEventDao.selectByPatIdNewest(pat_id, event_start_date_from, event_start_date_to);
  }

  @Override
  public List<PatEvent> selectByCd(Long pat_event_cd) {
    return patEventDao.selectByCd(pat_event_cd);
  }

  @Override
  @Transactional
  public List<PatEvent> create(List<PatEvent> m) {
    m.forEach(e -> {
      long nextSeqPatEventCd = patEventDao.selectNextSeqPatEventCd();
      e.setPatEventCd(nextSeqPatEventCd);
      patEventDao.insert(e);
    });
    return m;
  }

  @Override
  @Transactional
  public PatEvent update(PatEvent m) {
    patEventDao.update(m);
    return m;
  }

  @Override
  @Transactional
  public PatEvent updateResultParams(PatEvent m) {
    patEventDao.updateResultParamsAndReportUrl(m.getPatEventCd(), m.getResultParams(), null);
    return m;
  }

  @Override
  @Transactional
  public PatEvent updateBbsCtlNo(PatEvent m) {

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
  public PatEventMasterResponse findPatEventMaster(String facilityCd) {
    PatEventMasterResponse res = new PatEventMasterResponse();
    res.category = selectPatEventCategory(facilityCd);
    res.subCategory = selectPatEventSubCategory(facilityCd);
    res.template = selectPatEventTemplate(facilityCd);
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
   * ファイルダウンロード
   * S3からファイルをダウンロードして16進数文字列に変換する
   * @param filename
   * @return
   */
  public String downloadEventFileAttachment(String filepath) throws Exception {
    String localStore = null;
    String status = null;
    try {
      Map<String, String> map = getLocalStoreAndStatus();
      localStore = map.get("localStore");
      status = map.get("status");
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
      throw e;
    }
    if (status.equals("on")) {
      String fileLocation = localStore + "/" + s3Bucket + "/" + filepath;
      Path path = Paths.get(fileLocation);
      byte[] content = null;
      content = Files.readAllBytes(path);
      // 16進数文字列に変換
      String hexString = DatatypeConverter.printHexBinary(content);
      return hexString;
    } else {
      S3Object object = s3().getObject(new GetObjectRequest(s3Bucket, filepath));

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
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
      throw e;
    }
    String[] event = patEvent.split("&");
    String facility_cd = event[0];
    long pat_id = Long.parseLong(event[1]);
    long pat_event_cd = Long.parseLong(event[3]);
    String path = this.PATEVNT_FOLDER + facility_cd + "/" + pat_id + "/" + pat_event_cd + "/file/"
        + file.getOriginalFilename();
    if (status.equals("on")) {
      String fileLocation = localStore + "/" + s3Bucket + "/" + path;
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

        s3().deleteObject(new DeleteObjectRequest(s3Bucket, path));
        ObjectMetadata metadata = new ObjectMetadata();
        metadata.setContentLength(file.getSize());
        // S3アップロード
        s3().putObject(new PutObjectRequest(s3Bucket, path, file.getInputStream(), metadata));
      } catch (Exception e) {
        throw e;
      }
    }
  }

  /**
   * ファイル削除 (S3上)
   * @param filename
   */
  @Transactional
  public void deleteEventFileAttachment(List<Map<String, String>> fileInfoList, Long pat_id) throws Exception {
    String localStore = null;
    String status = null;
    try {
      Map<String, String> map = getLocalStoreAndStatus();
      localStore = map.get("localStore");
      status = map.get("status");
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
      throw e;
    }
    for (Map<String, String> fileInfo : fileInfoList) {
      String path = fileInfo.get("path");
      if (status.equals("on")) {
        String fileLocation = localStore + "/" + s3Bucket + "/" + path;
        Path pathFile = Paths.get(fileLocation);
        pathFile.toFile().delete();
      } else {
        if (!path.isEmpty()) {
          // S3ファイル削除
          s3().deleteObject(new DeleteObjectRequest(s3Bucket, path));
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
      HashMap<String, String> onPremise = objectMapper.readValue(data.getValue(),
          new TypeReference<HashMap<String, String>>() {
          });
      localStore = onPremise.get("path");
      status = onPremise.get("status");
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (!StringUtils.isEmpty(facilityCd)) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
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
        List<Path> files = Files.list(Paths.get(this.cacheDir)).collect(Collectors.toList());
        List<Path> files2 = files.stream()
            .filter(s -> s.getFileName().startsWith(cacheFile.getName()))
            .collect(Collectors.toList());

        for (Path f : files2) {
          if (f.getFileName().toString().equals(cacheFile.getName())) {
            File ff = f.toFile();
            if (ff.lastModified() != lastModified) {
              ff.delete();
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
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (!StringUtils.isEmpty(facilityCd)) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
    }

    // add オンプレミスファイルパス対応 劉 start
    if (status.equals("on")) {
      String fileLocation = localStore + "/" + s3BucketInFcd + "/" + filePath;
      Path path = Paths.get(fileLocation);
      byte[] content = null;
      content = Files.readAllBytes(path);
      // 16進数文字列に変換
      String hexString = DatatypeConverter.printHexBinary(content);
      return hexString;
    }
    // add オンプレミスファイルパス対応 劉 end

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
      String path = this.PATEVNT_FOLDER + facility_cd + "/" + pat_id + "/" + pat_event_cd + "/image/" + field_name + "-"
          + image_no + "/" + file.getOriginalFilename();
      String baseName = path.replace("/", "_");
      File cacheFile = getCacheFile(baseName, null);

      String localStore = null;
      String status = null;

      SysSystemDefine data = sysSystemDefineDao.selectOnPremise(CoreConstant.SysSystemDefine.CTL_NO_ON_PREMISE);
      ObjectMapper objectMapper = new ObjectMapper();
      HashMap<String, String> onPremise = objectMapper.readValue(data.getValue(),
          new TypeReference<HashMap<String, String>>() {
          });
      localStore = onPremise.get("path");
      status = onPremise.get("status");
      if (status.equals("on")) {
        String fileLocation = localStore + "/" + s3Bucket + "/" + path;
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
            List<Path> files = Files.list(Paths.get(this.cacheDir)).collect(Collectors.toList());
            List<Path> files2 = files.stream()
                .filter(s -> s.getFileName().startsWith(cacheFile.getName()))
                .collect(Collectors.toList());

            for (Path f : files2) {
              if (f.getFileName().toString().equals(cacheFile.getName())) {
                File ff = f.toFile();
                if (ff.length() != file.getSize()) {
                  ff.delete();
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
        } catch (IOException e) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
        }
        s3().deleteObject(new DeleteObjectRequest(s3Bucket, path));
        ObjectMetadata metadata = new ObjectMetadata();
        metadata.setContentLength(file.getSize());
        // S3アップロード
        s3().putObject(new PutObjectRequest(s3Bucket, path, file.getInputStream(), metadata));
        // キャッシュにデータを保存
        Files.write(cacheFile.toPath(), file.getBytes());
        long lastModified2 = s3().getObjectMetadata(s3Bucket, path).getLastModified().getTime();
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
  public void deleteEventImageAttachment(List<Map<String, String>> fileInfoList, Long pat_id) throws Exception {
    String localStore = null;
    String status = null;

    try {
      SysSystemDefine data = sysSystemDefineDao.selectOnPremise(CoreConstant.SysSystemDefine.CTL_NO_ON_PREMISE);
      ObjectMapper objectMapper = new ObjectMapper();
      HashMap<String, String> onPremise = objectMapper.readValue(data.getValue(),
          new TypeReference<HashMap<String, String>>() {
          });
      localStore = onPremise.get("path");
      status = onPremise.get("status");
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
      throw e;
    }

    for (Map<String, String> fileInfo : fileInfoList) {
      String path = fileInfo.get("path");

      String baseName = path.replace("/", "_");
      File cacheFile = getCacheFile(baseName, null);

      if (status.equals("on")) {
        String fileLocation = localStore + "/" + s3Bucket + "/" + path;
        Path pathFile = Paths.get(fileLocation);
        pathFile.toFile().delete();
      } else {
        try {
          Path cacheDirPath = Paths.get(this.cacheDir);
          if (Files.exists(cacheDirPath)) {
            List<Path> files = Files.list(Paths.get(this.cacheDir)).collect(Collectors.toList());
            files.forEach(f -> {
              if (f.getFileName().toString().equals(cacheFile.getName())) {
                f.toFile().delete();
              }
            });
          }
        } catch (IOException e) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
        }
        if (!path.isEmpty()) {
          // S3ファイル削除
          s3().deleteObject(new DeleteObjectRequest(s3Bucket, path));
        }
      }
    }
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
    eventLogMessage.setServiceName(LoggingConstant.MODULE_NAME.NTSS_DEVICE_EDGE + "," + LoggingConstant.SERVICE_NAME.REMS);
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
}
