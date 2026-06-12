package utils;

import batch.ApplicationConst;
import batch.listener.JobStartEndLIstener;
import tools.jackson.core.type.TypeReference;
import tools.jackson.databind.ObjectMapper;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.DeleteObjectRequest;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.ApplicationContext;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import org.springframework.util.ObjectUtils;
import web.config.EventLoggerUtil;
import web.constant.CoreConstant;
import web.entity.SysSystemDefine;
import web.logger.EventLogMessage;
import web.logger.LogLevel;

import javax.sql.DataSource;
import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.*;

@Component
public class PatEventService {

  /**
   * 終了ステータス
   */
  public static class STOP_STATUS {
    /** 正常終了 */
    public static final String NORMAL = "Normal";
    /** 警告終了 */
    public static final String WARN = "Warning";
    /** エラー終了 */
    public static final String ERROR = "Error";
  }

  // TODO: そのうちymlからの取得ではなくなるかも
  /**
   * S3バケット名
   */
  @Value("${ntss.pat-event.s3-bucket}")
  private String s3Bucket;

  /**
   * S3オブジェクト取得
   *
   * @return s3 S3オブジェクト
   */
    @Autowired
  private S3Client s3Client;

  private S3Client s3() {
    return s3Client;
  }

  /**
   * ロギング ツール クラスの導入
   */
  @Autowired
  private EventLoggerUtil eventLoggerUtil;

  @Autowired
  ApplicationContext appContext;

  private String localStore = "";
  private String status = "";

  // add #8600 ローカル保存設定で患者イベントなどの画像ファイルがコンバートされない limingyang start
  public void setStatus(String status) {
    this.status = status;
  }
  // add #8600 ローカル保存設定で患者イベントなどの画像ファイルがコンバートされない limingyang end

  /**
   * 患者イベントのファイルをアップロードする (S3上)
   *
   * @param facilityCd 施設コード
   * @param inputFilePath 処理対象ファイル名
   * @param basePathTmp 親パス
   * @param subPathKey 子パスキー
   * @return 終了ステータス
   */
  public String UploadEventAddedFiles(String facilityCd, String inputFilePath, String basePathTmp, String subPathKey, Integer maxPrimaryForConvert) {
	GlobalContext globalContext = JobStartEndLIstener.getGlobalContext();
    String basePath = resolveUploadEventBasePath(inputFilePath, basePathTmp);

    // 患者イベントのアップロードファイルを取得する
    HashMap<String, String> s3FileInfoList = GetEventUploadFiles(facilityCd, inputFilePath,maxPrimaryForConvert);
    if (s3FileInfoList == null) {
      return STOP_STATUS.ERROR;
    } else if (s3FileInfoList.isEmpty()) {
      return STOP_STATUS.NORMAL;
    }

    // 指定された子パスキーより、親パスから、患者イベントのファイルのパスを取得する
    String addedFileBasePath = getSpecifiedPath(facilityCd, basePath, subPathKey);
    globalContext.picPath = addedFileBasePath;
    if (ObjectUtils.isEmpty(addedFileBasePath)) {
      String error = String.format("子パスキー[%s]のパスがなし。親パス[%s]", subPathKey, basePath);
      //ログ
      EventLogMessage eventLogMessageS3 = eventLoggerUtil.getEventLogMessage(error,
              facilityCd, "uploadEventAddedFiles(String facilityCd, String inputFilePath, String basePathTmp, String subPathKey)");
      eventLoggerUtil.recordLog(facilityCd, eventLogMessageS3, LogLevel.ERROR);
      return STOP_STATUS.ERROR;
    }
    return uploadEventFilesAndDetermineStatus(facilityCd, s3FileInfoList, addedFileBasePath);
  }

  /**
   * アップロード対象ファイルの親パスを解決する
   */
  private String resolveUploadEventBasePath(String inputFilePath, String basePathTmp) {
    String basePath = basePathTmp;
    int index1 = inputFilePath.indexOf("ExportData_");
    if (index1 != -1) {
      int index2 = inputFilePath.indexOf(File.separator, index1);
      if (index2 != -1) {
        basePath = inputFilePath.substring(0, index2);
      }
    }
    return basePath;
  }

  /**
   * 患者イベントファイルをS3へアップロードし終了ステータスを返す
   */
  private String uploadEventFilesAndDetermineStatus(String facilityCd, HashMap<String, String> s3FileInfoList, String addedFileBasePath) {
    // ファイルアップロード (S3上)
    int okCnt  = 0;
    for(String s3File : s3FileInfoList.keySet()) {
      String oldFilePart = s3FileInfoList.get(s3File);
      // add #8597 PAT_EVENTの参照パスがネットワーク越しで指定している状態(\\xxx.xxx.xxx\UPLOAD\・・・)  limingyang start
      if (oldFilePart.startsWith("\\\\")) {
        oldFilePart = oldFilePart.substring(2);
      }
      // add #8597 PAT_EVENTの参照パスがネットワーク越しで指定している状態(\\xxx.xxx.xxx\UPLOAD\・・・)  limingyang end
      String oldFile = String.format("%s%s%s", addedFileBasePath, File.separator, oldFilePart);
      okCnt = okCnt + uploadFileToS3(facilityCd, oldFile, s3File);
    }

    //ログ
    String uploadInfo = String.format("アップロードファイル:合計%d件、成功%d件、失敗%d件",
            s3FileInfoList.size(), okCnt, (s3FileInfoList.size() - okCnt));
    EventLogMessage eventLogMessageS3_1 = eventLoggerUtil.getEventLogMessage(uploadInfo,
            facilityCd, "uploadEventAddedFiles(String facilityCd, String inputFilePath, String basePathTmp, String subPathKey)");
    eventLoggerUtil.recordLog(facilityCd, eventLogMessageS3_1, LogLevel.INFO);

    if (okCnt == 0) {
      return STOP_STATUS.ERROR;
    } else if (okCnt != s3FileInfoList.size()) {
      return STOP_STATUS.WARN;
    } else {
      return STOP_STATUS.NORMAL;
    }
  }

  /**
   * 患者イベントのアップロードファイルを取得する
   *
   * @param facilityCd 施設コード
   * @return アップロードファイル
   */
  private HashMap<String, String> GetEventUploadFiles(String facilityCd, String inputFilePath,Integer maxPrimaryForConvert) {
    HashMap<String, String> uploadFiles = new HashMap<String, String>();
    boolean useDiffFilter = inputFilePath.contains("[diff]");
    String sql = buildPatEventUploadSql(useDiffFilter);

    int[] errorCounts = new int[3];
    try {
      DataSource ds = (DataSource) appContext.getBean(ApplicationConst.DbType.CONVERT);
      JdbcTemplate jdbcTemplate = new JdbcTemplate(ds);

      List<Object> params = buildPatEventUploadSqlParams(facilityCd, maxPrimaryForConvert, useDiffFilter);
      List<Map<String,Object>> eventList = jdbcTemplate.queryForList(sql, params.toArray());
      populateEventUploadFilesFromQueryResult(facilityCd, uploadFiles, eventList, errorCounts);
    } catch (Exception ex) {
      EventLogMessage eventLogMessageS3 = eventLoggerUtil.getEventLogMessage(Arrays.toString(ex.getStackTrace()),
              facilityCd, "GetEventUploadFiles(String facilityCd)");
      eventLoggerUtil.recordLog(facilityCd, eventLogMessageS3, LogLevel.ERROR);

      eventLoggerUtil.recordLog(
              facilityCd,
              eventLoggerUtil.getEventLogMessage(
                      "GetEventUploadFiles(String facilityCd)："  + EventLoggerUtil.excetionStackTraceToString(ex),
                      facilityCd,
                      ex.getClass().getName() + ".GetEventUploadFiles()"),
              LogLevel.ERROR);
      return null;
    }

    logEventUploadFileErrorSummary(facilityCd, errorCounts[0], errorCounts[1], errorCounts[2]);
    return uploadFiles;
  }

  /**
   * 患者イベントアップロード用SQLを組み立てる
   */
  private String buildPatEventUploadSql(boolean useDiffFilter) {
    String sql = "WITH s3_file AS ( "
            + " SELECT "
            + " pat_event_cd, "
            + " pat_id, "
            + " fn_ctl_no, "
            + " json_array_elements((info->>'result_value') :: json) :: TEXT AS result_value "
            + "FROM "
            + "  pat_event "
            + "  CROSS JOIN LATERAL json_array_elements (result_params :: json) info "
            + "WHERE "
            + "  facility_cd = ? "
            + "  AND info->>'format_class' = '2' "
            + "  AND (info->>'result_value' IS NOT NULL AND info->>'result_value' != '' AND info->>'result_value' != '[]') "
            + "  AND info->>'result_value' like '%old_full_file_name%' ";
    if (useDiffFilter) {
      sql += " and pat_event_cd > ? ";
    }
    sql += " ) SELECT pat_event_cd, pat_id, fn_ctl_no, result_value FROM s3_file WHERE result_value like '%old_full_file_name%' "
            + "UNION ALL "
            + "(SELECT "
            + " pat_event_cd, "
            + " pat_id, "
            + " fn_ctl_no, "
            + " (info->>'result_value') :: TEXT AS result_value "
            + "FROM "
            + "  pat_event "
            + "  CROSS JOIN LATERAL json_array_elements (result_params :: json) info "
            + "WHERE "
            + "  facility_cd = ? "
            + "  AND info->>'format_class' = '7' "
            + "  AND (info->>'result_value' IS NOT NULL AND info->>'result_value' != '' AND info->>'result_value' != '[]') "
            + "  AND info->>'result_value' like '%old_full_file_name%' ";
    if (useDiffFilter) {
      sql += " and pat_event_cd > ? ";
    }
    sql += ") ";
    return sql;
  }

    /**
     * 患者イベントアップロード用SQLのパラメータを組み立てる
     */
    private List<Object> buildPatEventUploadSqlParams(String facilityCd, Integer maxPrimaryForConvert, boolean useDiffFilter) {
      List<Object> params = new ArrayList<>();
      params.add(facilityCd);
      if (useDiffFilter) {
        params.add(maxPrimaryForConvert);
      }
      params.add(facilityCd);
      if (useDiffFilter) {
        params.add(maxPrimaryForConvert);
      }
      return params;
    }

  /**
   * クエリ結果からアップロードファイルMapを構築する
   */
  private void populateEventUploadFilesFromQueryResult(String facilityCd, HashMap<String, String> uploadFiles,
                                                       List<Map<String,Object>> eventList, int[] errorCounts) throws Exception {
    if (eventList == null || eventList.isEmpty()) {
      return;
    }
        ObjectMapper objectMapper = new ObjectMapper();
        for (Map<String,Object> event : eventList) {
          Long patEventCd = null;
          Long patId = null;
          Long fnCtlNo = null;
          String resultValue = "";
          if (event.containsKey((Object)"pat_event_cd")) {
            patEventCd = (Long)event.get("pat_event_cd");
          }
          if (event.containsKey((Object)"pat_id")) {
            patId = (Long)event.get("pat_id");
          }
          if (event.containsKey((Object)"fn_ctl_no")) {
            fnCtlNo = (Long)event.get("fn_ctl_no");
          }
          if (event.containsKey((Object)"result_value")) {
            String resultTmp = event.get("result_value").toString();
            if (resultTmp.startsWith("[")) {
              int tmpLen = resultTmp.length();
              resultValue = resultTmp.substring(1, tmpLen-1);
            } else {
              resultValue = resultTmp;
            }
          }

          Map<String, String> json = objectMapper.readValue(resultValue, new TypeReference<Map<String, String>>() {});
          Object oldFileObj = json.get("old_full_file_name");
          String oldFile = (oldFileObj == null)?"":oldFileObj.toString();
          Object s3FileObj = json.get("file_path");
          String s3File = (s3FileObj == null)?"":s3FileObj.toString();
          Object fileNameObj = json.get("file_name");
          String fileName = (fileNameObj == null)?"":fileNameObj.toString();

          if (!ObjectUtils.isEmpty(fileName) && !s3File.endsWith(fileName)) {
            s3File = s3File + File.separator+ fileName;
          }

          String checkS3File = s3File;
          if (ObjectUtils.isEmpty(fileName) && !ObjectUtils.isEmpty(s3File)
            && (s3File.endsWith("/") ||  s3File.endsWith("\\") || s3File.endsWith(File.separator))) {
            checkS3File = "";
          }
          if (ObjectUtils.isEmpty(oldFile) && ObjectUtils.isEmpty(checkS3File)) {
            // 参照ファイルが無し
            continue;
          }

          if (ObjectUtils.isEmpty(oldFile)) {
            errorCounts[0]++;

            // FNWファイル名がなし
            String error = String.format("pat_eventにFNWファイル名は存在しません。patEventCd=%d，patId=%d, fnCtlNo=%d, fileName=[FNW:%s, FNSi:%s]"
                    , patEventCd, patId, fnCtlNo, oldFile, s3File);
            EventLogMessage eventLogMessageS3 = eventLoggerUtil.getEventLogMessage(error, facilityCd, "GetEventUploadFiles(String facilityCd)");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessageS3, LogLevel.ERROR);
            continue;
          }
          if (ObjectUtils.isEmpty(s3File)) {
            errorCounts[1]++;

            // FNSiファイル名がなし
            String error = String.format("pat_eventにFNSiファイル名は存在しません。patEventCd=%d，patId=%d, fnCtlNo=%d, fileName=[FNW:%s, FNSi:%s]"
                    , patEventCd, patId, fnCtlNo, oldFile, s3File);
            EventLogMessage eventLogMessageS3 = eventLoggerUtil.getEventLogMessage(error, facilityCd, "GetEventUploadFiles(String facilityCd)");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessageS3, LogLevel.ERROR);
            continue;
          }
          if (uploadFiles.containsKey(s3File)){
            if (!oldFile.equals(uploadFiles.get(s3File))) {
              errorCounts[2]++;

              // FNSiファイル名は同じですが、FNWファイル名は異なります
              String error = String.format("pat_eventにFNSiファイル名は同じですが、FNWファイル名は異なります。patEventCd=%d，patId=%d, fnCtlNo=%d, fileName=[FNW:%s, FNSi:%s]->[FNW:%s, FNSi:%s]"
                      , patEventCd, patId, fnCtlNo, oldFile, s3File, uploadFiles.containsKey(s3File), s3File);
              EventLogMessage eventLogMessageS3 = eventLoggerUtil.getEventLogMessage(error, facilityCd, "GetEventUploadFiles(String facilityCd)");
              eventLoggerUtil.recordLog(facilityCd, eventLogMessageS3, LogLevel.ERROR);
            }
            continue;
          }
          // Mapを追加
          String[] tmpList = oldFile.split(":");
          if (tmpList.length >= 2) {
            oldFile = tmpList[1];
          }
          uploadFiles.put(s3File, oldFile);
        }
      }
  /**
   * アップロードファイル取得時のエラー件数をログ出力する
   */
  private void logEventUploadFileErrorSummary(String facilityCd, int oldErrorCnt, int s3ErrorCnt, int otherErrorCnt) {
    if (oldErrorCnt != 0 || s3ErrorCnt != 0 || otherErrorCnt != 0) {
      //ログ
      String uploadInfo = String.format("FNWファイル名がなし[%d]件、FNSiファイル名がなし[%d]件、FNSiファイル名は同じですが、FNWファイル名は異なります[%d]件",
              oldErrorCnt, s3ErrorCnt, otherErrorCnt);
      EventLogMessage eventLogMessageS3_1 = eventLoggerUtil.getEventLogMessage(uploadInfo,
              facilityCd, "uploadEventAddedFiles(String facilityCd, String basePath, String subPathKey)");
      eventLoggerUtil.recordLog(facilityCd, eventLogMessageS3_1, LogLevel.ERROR);
    }
  }

  /**
   * 指定された子パスキーより、親パスから、患者イベントのファイルのパスを取得する
   *
   * @param facilityCd 施設コード
   * @param parentPath 親パス
   * @param subPathKey 子パスキー
   * @return サブパス
   */
  private String getSpecifiedPath(String facilityCd, String parentPath, String subPathKey) {
    String specifiedPath = "";
    if (ObjectUtils.isEmpty(parentPath) || ObjectUtils.isEmpty(subPathKey)) {
      String error = String.format("親パス、または子パスキーがNULLです.親パス[%s], 子パスキー[%s]", parentPath, subPathKey);
      EventLogMessage eventLogMessageS3 = eventLoggerUtil.getEventLogMessage(error,
              facilityCd, "getSpecifiedPath(String facilityCd, String parentPath, String subPathKey)");
      eventLoggerUtil.recordLog(facilityCd, eventLogMessageS3, LogLevel.DEBUG);
      return specifiedPath;
    }

    try {
      File file = new File(parentPath);
      if (file.exists()) {
        File[] tempList = file.listFiles();
        if (tempList != null && tempList.length > 0) {
            for (File value : tempList) {
                if (value.isDirectory()) {
                    if ((value.toString()).endsWith(String.format("%s%s", File.separator, subPathKey))) {
                        specifiedPath = value.toString();
                        break;
                    } else {
                        String tmpPath = getSpecifiedPath(facilityCd, value.toString(), subPathKey);
                        if (!ObjectUtils.isEmpty(tmpPath)) {
                            specifiedPath = tmpPath;
                            break;
                        }
                    }
                }
            }
        }
      }
    } catch (Exception ex) {
      //ログ
      EventLogMessage eventLogMessageS3_1 = eventLoggerUtil.getEventLogMessage(Arrays.toString(ex.getStackTrace()),
              facilityCd, "getSpecifiedPath(String facilityCd, String parentPath, String subPathKey)");
      eventLoggerUtil.recordLog(facilityCd, eventLogMessageS3_1, LogLevel.DEBUG);

      String error = String.format("サブパス取得に失敗しました。親パス[%s], 子パスキー[%s]", parentPath, subPathKey);
      EventLogMessage eventLogMessageS3_2 = eventLoggerUtil.getEventLogMessage(error,
              facilityCd, "getSpecifiedPath(String facilityCd, String parentPath, String subPathKey)");
      eventLoggerUtil.recordLog(facilityCd, eventLogMessageS3_2, LogLevel.DEBUG);

      eventLoggerUtil.recordLog(
        facilityCd,
        eventLoggerUtil.getEventLogMessage(
                "getSpecifiedPath(String facilityCd, String parentPath, String subPathKey) サブパス取得に失敗しました。親パス[%s], 子パスキー："  + EventLoggerUtil.excetionStackTraceToString(ex),
                facilityCd,
                ex.getClass().getName() + ".getSpecifiedPath()"),
        LogLevel.ERROR);
    }
    return specifiedPath;
  }

  /**
   * ファイルアップロード (S3上)
   *
   * @param facilityCd 施設コード
   * @param uploadFileName アップロードファイル名
   * @param s3FileName S3上のフルパスファイル名
   */
  private int uploadFileToS3(String facilityCd, String uploadFileName, String s3FileName) {
    try {
      String uploadFileNameTmp = Paths.get(PathFormat(uploadFileName)).toString();
      String s3FileNameTmp = Paths.get(PathFormat(s3FileName)).toString();
      uploadFileName = uploadFileNameTmp;
      s3FileName = s3FileNameTmp;

      String s3Path = s3FileName;
      if (s3FileName.charAt(0) == '/' || s3FileName.charAt(0) == '\\' || s3FileName.charAt(0) == File.separatorChar) {
        s3Path = s3FileName.substring(1);
      }
      String s3BucketInFcd = String.format(s3Bucket, facilityCd);

      if (GetS3Status(facilityCd).equals("on")) {
        String fileLocation = localStore + "/" + s3BucketInFcd + "/" + s3Path;
        Path pathFile = Paths.get(fileLocation);
        if (!Files.exists(pathFile)) {
          Files.createDirectories(pathFile.getParent());
          File newFile = new File(pathFile.toString());
          newFile.createNewFile();
        }

        pathFile.toFile().delete();
        Files.copy(Paths.get(uploadFileName), pathFile);
      } else {
        File uploadFile = new File(uploadFileName);
        // S3アップロード
        s3().putObject(PutObjectRequest.builder().bucket(s3BucketInFcd).key(s3Path).build(), RequestBody.fromFile(uploadFile));
      }

    } catch (Exception ex) {
      //ログ
      EventLogMessage eventLogMessageS3_1 = eventLoggerUtil.getEventLogMessage(Arrays.toString(ex.getStackTrace()),
              facilityCd, "uploadFileToS3(String facilityCd, String uploadFileName, String s3FileName)");
      eventLoggerUtil.recordLog(facilityCd, eventLogMessageS3_1, LogLevel.ERROR);

      String error = String.format("ファイルアップロード(S3上)に失敗しました。Status[%s],localStore[%s],S3Bucket[%s],ローカルファイル[%s],S3ファイル[%s]"
              , status, localStore, String.format(s3Bucket, facilityCd), uploadFileName, s3FileName);
      EventLogMessage eventLogMessageS3_2 = eventLoggerUtil.getEventLogMessage(error + " ： " + EventLoggerUtil.excetionStackTraceToString(ex),
              facilityCd, "uploadFileToS3(String facilityCd, String uploadFileName, String s3FileName)");
      eventLoggerUtil.recordLog(facilityCd, eventLogMessageS3_2, LogLevel.ERROR);
      return 0;
    }
    return 1;
  }

  private String PathFormat(String path) {
    String newPath = "";
    if (ObjectUtils.isEmpty(path)) {
      return newPath;
    }

    String[] splitList = path.split("/|\\\\");
    if (splitList != null && splitList.length > 0) {
      for (String s : splitList) {
          if (!ObjectUtils.isEmpty(s)) {
              newPath = newPath + "/" + s;
          }
      }
    }
    return newPath;
  }

  /**
   * S3情報を取得する
   *
   * @param facilityCd 施設コード
   * @return S3情報
   */
  private String GetS3Status(String facilityCd) {
    if (ObjectUtils.isEmpty(status)) {
      try {
        SysSystemDefine systemDefine = getSystemDefine(CoreConstant.SysSystemDefine.CTL_NO_ON_PREMISE);

        if (!ObjectUtils.isEmpty(systemDefine.getValue())) {
          ObjectMapper objectMapper = new ObjectMapper();
          Map<String, String> onPremise = objectMapper.readValue(systemDefine.getValue(), new TypeReference<Map<String, String>>() {
          });
          localStore = onPremise.get("path");
          status = onPremise.get("status");
        }
      } catch (Exception ex) {
        //ログ
        EventLogMessage eventLogMessageS3 = eventLoggerUtil.getEventLogMessage(Arrays.toString(ex.getStackTrace()),
                facilityCd, "GetS3Status(String facilityCd)");
        eventLoggerUtil.recordLog(facilityCd, eventLogMessageS3, LogLevel.ERROR);

        eventLoggerUtil.recordLog(
          facilityCd,
          eventLoggerUtil.getEventLogMessage(
                  "GetS3Status(String facilityCd)："  + EventLoggerUtil.excetionStackTraceToString(ex),
                  facilityCd,
                  ex.getClass().getName() + ".GetS3Status()"),
          LogLevel.ERROR);
      }
    }
    return status;
  }

  /**
   * 管理番号よりシステム設定を取得する
   *
   * @param ctlNo 管理番号
   * @return システム設定
   */
  private SysSystemDefine getSystemDefine(int ctlNo) {
    // SQLインジェクション対策：パラメータ化クエリを使用
    String sql = "select ctl_no as ctlNo, service_cd as serviceCd, name, value, description, " +
            "is_enable as isEnable, up_date as upDate  from sys_system_define where ctl_no = ?";
    DataSource dataSource = (DataSource) appContext.getBean(ApplicationConst.DbType.NKK5);
    JdbcTemplate jdbcTemplate = new JdbcTemplate(dataSource);
    SysSystemDefine systemDefine = new SysSystemDefine();
    List<SysSystemDefine> userList = jdbcTemplate.query(sql, new Object[]{ctlNo}, new BeanPropertyRowMapper<>(SysSystemDefine.class));
    if(!userList.isEmpty()){
      systemDefine = userList.get(0);
    }
    return systemDefine;
  }

  /**
   *　差分する時、ファイル削除
   *
   * @param pathList 管理番号
   * @return
   */
  public void deleteFiles(List<String> pathList, String facilityCd){
    String status = GetS3Status(facilityCd);
    String s3BucketInFcd = String.format(s3Bucket, facilityCd);
    String fileLocation = localStore + "/" + s3BucketInFcd ;
    for (String path : pathList) {
      path = path.replace("\"","");
      if (path.charAt(0) == '/' || path.charAt(0) == '\\' || path.charAt(0) == File.separatorChar) {
        path = path.substring(1);
      }
      String oldFilePath = fileLocation + "/" + path;
      if (status.equals("on")) {
        Path pathFile = Paths.get(oldFilePath);
        if (Files.exists(pathFile)) {
          pathFile.toFile().delete();
        }
      } else {
        try {
          s3().deleteObject(DeleteObjectRequest.builder().bucket(s3BucketInFcd).key(path).build());
        } catch (Exception e) {
          String info = String.format("deleteObject無効。Status[%s],localStore[%s],S3Bucket[%s],S3ファイル[%s]"
                  , status, localStore, String.format(s3Bucket, facilityCd),  oldFilePath);
          EventLogMessage eventLogMessageS3 = eventLoggerUtil.getEventLogMessage(info,
                  facilityCd, " s3().deleteObject(new DeleteObjectRequest(s3BucketInFcd, s3Path));");
          eventLoggerUtil.recordLog(facilityCd, eventLogMessageS3, LogLevel.INFO);

          eventLoggerUtil.recordLog(
            facilityCd,
            eventLoggerUtil.getEventLogMessage(
                    "s3().deleteObject(new DeleteObjectRequest(s3BucketInFcd, s3Path))："  + EventLoggerUtil.excetionStackTraceToString(e),
                    facilityCd,
                    e.getClass().getName() + ".deleteObject()"),
            LogLevel.ERROR);
        }
      }
    }
  }
}
