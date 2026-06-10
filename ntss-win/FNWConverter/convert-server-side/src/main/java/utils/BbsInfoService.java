package utils;

import batch.ApplicationConst;
import batch.listener.JobStartEndLIstener;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.model.DeleteObjectRequest;
import com.amazonaws.services.s3.model.PutObjectRequest;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.ApplicationContext;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import web.config.EventLoggerUtil;
import web.constant.CoreConstant;
import web.entity.SysSystemDefine;
import web.logger.EventLogMessage;
import web.logger.LogLevel;

import javax.sql.DataSource;
import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Component
public class BbsInfoService {

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
  @Value("${ntss.bbs-info.s3-bucket}")
  private String s3Bucket;

  /**
   * S3オブジェクト取得
   *
   * @return s3 S3オブジェクト
   */
  @Autowired
  private AwsConfiguration awsS3;
  private AmazonS3 s3() {
    return awsS3.s3();
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
    public String UploadEventAddedFiles(String facilityCd, String inputFilePath, String basePathTmp, String subPathKey,String localSqlKeys,String localSqlNewKeys) {
        GlobalContext globalContext = JobStartEndLIstener.getGlobalContext();
    // アップロードしたファイルをパスを取得する
    String basePath = basePathTmp;
    int index1 = inputFilePath.indexOf("ExportData_");
    if (index1 != -1) {
      int index2 = inputFilePath.indexOf(File.separator, index1);
      if (index2 != -1) {
        basePath = inputFilePath.substring(0, index2);
      }
    }

    // 患者イベントのアップロードファイルを取得する
        HashMap<String, String> s3FileInfoList = GetEventUploadFiles(facilityCd, inputFilePath,localSqlKeys,localSqlNewKeys);
    if (s3FileInfoList == null) {
      return STOP_STATUS.ERROR;
    } else if (s3FileInfoList.size() == 0) {
      return STOP_STATUS.NORMAL;
    }

    // 指定された子パスキーより、親パスから、患者イベントのファイルのパスを取得する
    String addedFileBasePath = getSpecifiedPath(facilityCd, basePath, subPathKey);
        globalContext.picPath = addedFileBasePath;
    if (StringUtils.isEmpty(addedFileBasePath)) {
      String error = String.format("子パスキー[%s]のパスがなし。親パス[%s]", subPathKey, basePath);
      //ログ
      EventLogMessage eventLogMessageS3 = eventLoggerUtil.getEventLogMessage(error,
              facilityCd, "uploadEventAddedFiles(String facilityCd, String inputFilePath, String basePathTmp, String subPathKey)");
      eventLoggerUtil.recordLog(facilityCd, eventLogMessageS3, LogLevel.ERROR);
      return STOP_STATUS.ERROR;
    }

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
  private HashMap<String, String> GetEventUploadFiles(String facilityCd, String inputFilePath,String localSqlKeys,String localSqlNewKeys) {
    HashMap<String, String> uploadFiles = new HashMap<String, String>();
    String sql = "SELECT "
            + " bbs_ctl_no, "
            + " file_info[0] ->> 'path' as pathName "
            + "FROM "
            + "  bbs_info "
            + "WHERE "
            + "  facility_cd = ? "
            + "  AND (file_info[0] ->>'path' IS NOT NULL AND file_info[0] ->>'path' != '' AND file_info != '[]') "
            +  " AND fn_seq_id is not null ";
    if (inputFilePath.contains("[diff]")) {
      String diffSql = "";
      if (StringUtils.hasText(localSqlKeys)) {
        diffSql = " bbs_ctl_no in (" + localSqlKeys + ") ";
      }
      if (StringUtils.hasText(localSqlNewKeys)) {
        if(!diffSql.isEmpty()){
          diffSql +=  " or concat_ws('',fn_seq_id,is_disp_bbs) in (" + localSqlNewKeys + ") ";
        } else{
          diffSql +=  " concat_ws('',fn_seq_id,is_disp_bbs) in (" + localSqlNewKeys + ") ";
        }
      }
      if(!diffSql.isEmpty()){
        sql += "AND (" + diffSql + ")";
      }
    }

    try {
      DataSource ds = (DataSource) appContext.getBean(ApplicationConst.DbType.NKK5);
      JdbcTemplate jdbcTemplate = new JdbcTemplate(ds);

      List<Map<String,Object>> bbsList = jdbcTemplate.queryForList(sql, new Object[] {facilityCd});
      if (bbsList != null && bbsList.size() > 0) {
        for (Map<String,Object> bbs : bbsList) {
          Long bbsCtlNo = null;
          String pathName = "";
          String newPath = "";
          if (bbs.containsKey((Object)"bbs_ctl_no")) {
            bbsCtlNo = (Long)bbs.get("bbs_ctl_no");
          }
          if (bbs.containsKey((Object)"pathName")) {
            pathName = bbs.get("pathName").toString();
            String[] pathList = pathName.split(":");
            if(pathList.length >1){
              pathName = pathList[1];
            }
            if (pathName.startsWith("\\")) {
              pathName = pathName.substring(1);
            }
            String filesName = pathName.substring(pathName.lastIndexOf("\\")+1,pathName.length());
            newPath = bbsCtlNo + "/" + filesName;
          }
          // Mapを追加
          if (!newPath.isEmpty()){
            uploadFiles.put(newPath, pathName);
            String updSql = "update bbs_info set file_info = jsonb_set(file_info, '{0,path}', '\""+newPath+"\"') where bbs_ctl_no = " + bbsCtlNo;
            jdbcTemplate.execute(updSql);
          }
        }
      }
    } catch (Exception ex) {
      ex.printStackTrace();
      //ログ
      EventLogMessage eventLogMessageS3 = eventLoggerUtil.getEventLogMessage(Arrays.toString(ex.getStackTrace()),
              facilityCd, "GetEventUploadFiles(String facilityCd)");
      eventLoggerUtil.recordLog(facilityCd, eventLogMessageS3, LogLevel.ERROR);
      return null;
    }

    return uploadFiles;
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
    if (StringUtils.isEmpty(parentPath) || StringUtils.isEmpty(subPathKey)) {
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
          for (int i=0; i<tempList.length; i++) {
            if (tempList[i].isDirectory()) {
              if ((tempList[i].toString()).endsWith(String.format("%s%s", File.separator, subPathKey))) {
                specifiedPath = tempList[i].toString();
                break;
              } else {
                String tmpPath = getSpecifiedPath(facilityCd, tempList[i].toString(), subPathKey);
                if (!StringUtils.isEmpty(tmpPath)) {
                  specifiedPath = tmpPath;
                  break;
                }
              }
            }
          }
        }
      }
    } catch (Exception ex) {
      ex.printStackTrace();
      //ログ
      EventLogMessage eventLogMessageS3_1 = eventLoggerUtil.getEventLogMessage(Arrays.toString(ex.getStackTrace()),
              facilityCd, "getSpecifiedPath(String facilityCd, String parentPath, String subPathKey)");
      eventLoggerUtil.recordLog(facilityCd, eventLogMessageS3_1, LogLevel.DEBUG);

      String error = String.format("サブパス取得に失敗しました。親パス[%s], 子パスキー[%s]", parentPath, subPathKey);
      EventLogMessage eventLogMessageS3_2 = eventLoggerUtil.getEventLogMessage(error,
              facilityCd, "getSpecifiedPath(String facilityCd, String parentPath, String subPathKey)");
      eventLoggerUtil.recordLog(facilityCd, eventLogMessageS3_2, LogLevel.DEBUG);
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
        s3().putObject(new PutObjectRequest(s3Bucket, s3Path, uploadFile));
      }
    } catch (Exception ex) {

      //ログ
      EventLogMessage eventLogMessageS3_1 = eventLoggerUtil.getEventLogMessage(Arrays.toString(ex.getStackTrace()),
              facilityCd, "uploadFileToS3(String facilityCd, String uploadFileName, String s3FileName)");
      eventLoggerUtil.recordLog(facilityCd, eventLogMessageS3_1, LogLevel.ERROR);

      String error = String.format("ファイルアップロード(S3上)に失敗しました。Status[%s],localStore[%s],S3Bucket[%s],ローカルファイル[%s],S3ファイル[%s]"
              , status, localStore, String.format(s3Bucket, facilityCd), uploadFileName, s3FileName);
      EventLogMessage eventLogMessageS3_2 = eventLoggerUtil.getEventLogMessage(error,
              facilityCd, "uploadFileToS3(String facilityCd, String uploadFileName, String s3FileName)");
      eventLoggerUtil.recordLog(facilityCd, eventLogMessageS3_2, LogLevel.ERROR);

      return 0;
    }
    return 1;
  }

  private String PathFormat(String path) {
    String newPath = "";
    if (StringUtils.isEmpty(path)) {
      return newPath;
    }

    String[] splitList = path.split("/|\\\\");
    if (splitList != null && splitList.length > 0) {
      int cnt = splitList.length;
      for (int i=0; i< cnt ; i++) {
        if (!StringUtils.isEmpty(splitList[i])) {
          newPath = newPath + "/" + splitList[i];
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
    if (StringUtils.isEmpty(status)) {
      try {
        SysSystemDefine systemDefine = getSystemDefine(CoreConstant.SysSystemDefine.CTL_NO_ON_PREMISE);

        if (!StringUtils.isEmpty(systemDefine.getValue())) {
          ObjectMapper objectMapper = new ObjectMapper();
          Map<String, String> onPremise = objectMapper.readValue(systemDefine.getValue(), new TypeReference<Map<String, String>>() {
          });
          localStore = onPremise.get("path");
          status = onPremise.get("status");
        }
      } catch (Exception ex) {
        ex.printStackTrace();
        //ログ
        EventLogMessage eventLogMessageS3 = eventLoggerUtil.getEventLogMessage(Arrays.toString(ex.getStackTrace()),
                facilityCd, "GetS3Status(String facilityCd)");
        eventLoggerUtil.recordLog(facilityCd, eventLogMessageS3, LogLevel.ERROR);
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
    String sql = "select ctl_no as ctlNo, service_cd as serviceCd, name, value, description, " +
            "is_enable as isEnable, up_date as upDate  from sys_system_define where ctl_no = " + ctlNo;
    DataSource dataSource = (DataSource) appContext.getBean(ApplicationConst.DbType.NKK5);
    JdbcTemplate jdbcTemplate = new JdbcTemplate(dataSource);
    SysSystemDefine systemDefine = new SysSystemDefine();
    List<SysSystemDefine> userList = jdbcTemplate.query(sql, new Object[]{}, new BeanPropertyRowMapper<>(SysSystemDefine.class));
    if(userList.size() > 0){
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
          s3().deleteObject(new DeleteObjectRequest(s3BucketInFcd, path));
        } catch (Exception e) {
          e.printStackTrace();
          String info = String.format("deleteObject無効。Status[%s],localStore[%s],S3Bucket[%s],S3ファイル[%s]"
                  , status, localStore, String.format(s3Bucket, facilityCd),  oldFilePath);
          EventLogMessage eventLogMessageS3 = eventLoggerUtil.getEventLogMessage(info,
                  facilityCd, " s3().deleteObject(new DeleteObjectRequest(s3BucketInFcd, s3Path));");
          eventLoggerUtil.recordLog(facilityCd, eventLogMessageS3, LogLevel.INFO);
        }
      }
    }
  }
}
