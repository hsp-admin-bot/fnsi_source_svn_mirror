package jp.co.nikkiso.ntss.web_api.service.fileIO;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FilenameFilter;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import tools.jackson.core.type.TypeReference;
import tools.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.SysSystemDefineDao;
import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.web_api.service.LogService;
import jp.co.nikkiso.ntss.web_api.service.utils.AwsCliCtrl;
import jp.co.nikkiso.ntss.web_api.service.utils.NumberCtrl;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;


/**
 * ファイルIOクラス
 *
 */
@Service
public class FileIOServiceImpl implements FileIOService {

  @Autowired
  private Environment environment;

  @Autowired
  LogService logService;

  @Autowired
  SysSystemDefineDao sysSystemDefineDao;

  /**
   * オンプレミスかどうかの判定
   * @return
   */
  @Override
  public OnPremiseInfo ChkOnPremise() {

    OnPremiseInfo info = new OnPremiseInfo();
    try {
      SysSystemDefine data = sysSystemDefineDao.selectOnPremise(CoreConstant.SysSystemDefine.CTL_NO_ON_PREMISE);
      ObjectMapper objectMapper = new ObjectMapper();
      HashMap<String, String> onPremise = objectMapper.readValue(data.getValue(), new TypeReference<HashMap<String, String>>(){});
      String localStore = onPremise.get("path");
      String status = onPremise.get("status");
      if (status.equals("on")) {
        info.setIsOnPremise(true);
        info.setLocalStore(localStore);
      }
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("[ChkOnPremise]ファイルアップロード: システム設定の取得に失敗[" + e.getMessage() + "]");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }
    return info;
  }

  /* add by chamaojia 2023-09-12 [9599] 新しいデスクトップ通知を送信できるインタフェースかどうか  --start */
  @Override
  public boolean chkSesOn() {
    try {
      SysSystemDefine data = sysSystemDefineDao.selectOnPremise(CoreConstant.SysSystemDefine.CTL_NO_ON_PREMISE);
      ObjectMapper objectMapper = new ObjectMapper();
      HashMap<String, String> onPremise = objectMapper.readValue(data.getValue(), new TypeReference<HashMap<String, String>>(){});
      String ses = onPremise.get("ses");
      if (ses.equals("on")) {
        return true;
      }
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("[chkSesOn]デスクトップ通知: システム設定の取得に失敗[" + e.getMessage() + "]");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }
    return false;
  }
  /* add by chamaojia 2023-09-12 [9599] 新しいデスクトップ通知を送信できるインタフェースかどうか  --end */

  /**
   * S3へファイルをアップロードする
   * ・外部からファイル(multipartFile)が直接送られてきた場合
   *
   * @param multipartFile 対象ファイル
   * @param uploadPath アップロード先のパス(ファイル名を含まない(s3://バケット名＋/XXXX)、末尾に"/"を含まない)
   * @return 成功:true、失敗:false
   */
  @Override
  public boolean UploadToS3(MultipartFile multipartFile, String uploadPath) {

    // 一時ディレクトリ関連情報
    String fileJoinDir = this.environment.getProperty("fileIO.upload.fileJoinDir");
    String tempDirName = this.environment.getProperty("fileIO.upload.tempDir");
    String tempPreFix = this.environment.getProperty("fileIO.upload.tempPreFix");
    String tempSufFix = this.environment.getProperty("fileIO.upload.tempSufFix");
    String delmitter = "/";

    // プロセス処理の最大待ち時間(秒)
    int processTimeout = NumberCtrl.ParseNumber(this.environment.getProperty("fileIO.processTimeout"), "300", Integer.class);

    // ファイルが空の場合は異常終了
    if (multipartFile.isEmpty()) {
      // 異常終了時の処理
      // ファイルが空だった
    	EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("[ntss-web-api]S3ファイルアップロード: 対象ファイルが存在しない");
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
        return false;
    }

    // オンプレミス判定
    Boolean isOnPremise = false;
    OnPremiseInfo onpremise = ChkOnPremise();
    isOnPremise = onpremise.getIsOnPremise();

    // ファイル名
    String fileName = multipartFile.getOriginalFilename();

    // アップされたのがDEログファイルかどうか判定
    //mod #9696 アプリケーションログのパスとファイル名の修正。 zhaoqi 20240403 start
    // ファイル名: DE_施設コード(6桁)_デバイスエッジ番号(2桁)_製造番号(任意の長さ)_作成年月日(8桁).ZIP
    //mod 9696 ファイル名の書式変更 施設コード(6桁)_DE_製造番号(11桁)_デバイスエッジ番号(2桁)_作成年月日(8桁).ZIP ljg start
    //    Boolean isLogFile = fileName.matches("^DE_.{6}_.{2}_.{11}_.{8}.+");
    Boolean isLogFile = fileName.matches("^.{6}_DE_.+_.{2}_.{8}.+");
    //mod 9696 ファイル名の書式変更 ljg end
    //mod #9696 アプリケーションログのパスとファイル名の修正。 zhaoqi 20240403 end
    // アップされたのが分割ファイルかの判定(末尾に分割ファイル番号(3桁)、又は末尾が.list)
    Boolean isSplitFile = fileName.matches(".+\\.[0-9]{3}$") || fileName.matches(".+\\.list$");

    // DEログファイルのアップロード先を取得
    if (isLogFile) {
      // ファイルパス関連情報
      String[] splittedFileName = fileName.split("_");
      //mod 9696 施設の桁修正を取ります ljg start
      String facilityCd = splittedFileName[0];
      //mod 9696 施設の桁修正を取ります ljg end
      //add 9696 ファイル名の日付と本日の日付を取得します。ljg start
      String FileNameDate= splittedFileName[4].substring(0,8);
      SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
      Date date = new Date();
      String dateNew = sdf.format(date);
      //add 9696 ファイル名の日付と本日の日付を取得します。ljg end
      // ファイルパス取得
      // 引数uploadPathは無視する
      List<SysSystemDefine> data = sysSystemDefineDao.selectByCtlNo(CoreConstant.SysSystemDefine.DEVICEEDGE_LOG_OUTPUT_PATH);
      if (data.size() > 0) {
        String strJson = data.get(0).getValue();
        JSONObject objJson = new JSONObject(strJson);
        //mod 9696 today差し替えです ljg start
        uploadPath = objJson.getString("path").replaceAll("\\{0\\}", facilityCd).replaceAll("\\{1\\}", "today");
        //mod 9696 today差し替えです ljg end
        //add 9696 todayフォルダは今日だけ残しておきます(.listとZIP00*の場合を除きます。) ljg start
        if (isSplitFile == false) {
          UploadCopy(uploadPath);
          //9696 今日のファイルでない場合は、対応する日付フォルダに保存します。 ljg start
          if (FileNameDate.equals(dateNew) == false) {
            uploadPath = uploadPath.replace("today", FileNameDate);
          }
          //9696 今日のファイルでない場合は、対応する日付フォルダに保存します。 ljg end
        }
        //add 9696 todayフォルダは今日だけ残しておきます(.listとZIP00*の場合を除きます。) ljg end
      }
      // DEログファイルの場合はS3にアップロードしない。
      isOnPremise = true;
    } else {
      // 分割ファイルだった場合は、分割ファイル保存場所(fileJoinDir)に保存する
      if (isSplitFile) {
        if (uploadPath.startsWith("s3://")) {
          uploadPath = uploadPath.substring("s3://".length());
        }
        uploadPath = fileJoinDir + "/" + uploadPath;
        isOnPremise = true;
      }
    }

    if (isOnPremise) {
      // オンプレミス
      try {
        String fileLocation = "";
        if (isLogFile || isSplitFile) {
          // ログファイルの場合、または分割ファイルの場合、ファイルパス+ファイル名
          fileLocation = uploadPath + "/" + fileName;
        } else {
          // ログファイル以外の場合、従来処理(設定のルートフォルダ+"s3://"以下のサブフォルダ+ファイル名)
          if (uploadPath.startsWith("s3://")) {
            uploadPath = uploadPath.substring("s3://".length());
          }
          fileLocation = onpremise.getLocalStore() + "/" + uploadPath + "/" + fileName;
        }
        Path pathFile = Paths.get(fileLocation);
        if (!Files.exists(pathFile)) {
          Files.createDirectories(pathFile.getParent());
          File newFile = new File(pathFile.toString());
          newFile.createNewFile();
        }

        pathFile.toFile().delete();
        Files.write(pathFile, multipartFile.getBytes());
        return true;
      } catch (IOException e) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("[ntss-web-api]ファイルアップロード: 保存失敗:" + e);
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        return false;
      }

    } else {
      // S3

      // 一時ファイルの準備
      File tempUploadFile = null;
      File tempDir = new File(tempDirName);
      BufferedOutputStream uploadFileStream = null;
      try {
        if (false == tempDir.exists()) {
          // 一時フォルダが存在しない場合
          if (false == tempDir.mkdirs()) {
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage("[ntss-web-api]S3ファイルアップロード: 一時作業フォルダの作成に失敗");
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
            return false;
          }
        }
        else if (false == tempDir.isDirectory()) {
          // 一時フォルダが存在するかと思いきや、実はフォルダではなくファイルだった場合
          // 異常終了
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("[ntss-web-api]S3ファイルアップロード: 一時アップロード先フォルダと同名のファイルが存在した為、フォルダ作成に失敗");
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
          return false;
        }

        // 一時ファイル名の組み立て
        // TempPreFix + 数字列.TempSufFix
        tempUploadFile = File.createTempFile(tempPreFix, tempSufFix, tempDir);

        // 一時ファイルとして一時フォルダに格納
        byte[] bytes = multipartFile.getBytes();
        uploadFileStream = new BufferedOutputStream(new FileOutputStream(tempUploadFile));
        uploadFileStream.write(bytes);

        String from = tempUploadFile.getPath();
        String to = uploadPath + delmitter + multipartFile.getOriginalFilename();
        // S3へ転送
        //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
        //int ret = AwsCliCtrl.S3IO(from, to, processTimeout);
        int ret = AwsCliCtrl.S3IO(from, to, processTimeout, logService);
        //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
        if (0 != ret) {
          // S3への転送(AWSCLI)で失敗
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("[ntss-web-api]S3ファイルアップロード: S3へのファイルアップロードに失敗　転送元ファイル[" + from + "]、転送先パス[" + to + "]");
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
          return false;
        }
      } catch (Exception e) {
        // 異常終了時の処理
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("[ntss-web-api]S3ファイルアップロード: S3へのファイルアップロード時に例外発生　[" + e.getMessage() + "]");
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
        return false;
      }
      finally {
        // 一時ファイルを開放する
        if (uploadFileStream != null) {
          try {
            uploadFileStream.close();
          } catch (IOException e) {
          }
        }
        if (null != tempUploadFile && true == tempUploadFile.exists()) {
          // 一時ファイルを削除
          tempUploadFile.delete();
        }
      }
    }

    return true;
  }
  /**
   * add 9696 指定フォルダ内の本日のファイルではないものを移動させます。
   * @param fileLocation　フォルダパスを指定します
   */
  public boolean UploadCopy(String fileLocation ) {
    File folder = new File(fileLocation);
    List<File> delFiles = new ArrayList<>();
    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
    Date date = new Date();
    String dateNew = sdf.format(date);
    if(folder.isDirectory()) {
      File[] todayFiles = folder.listFiles();
      for (int i = 0; i < todayFiles.length; i++) {
        //mod #9696 アプリケーションログのパスとファイル名の修正。 zhaoqi 20240403 start
        if (todayFiles[i].getName().matches("^.{6}_DE_.+_.{2}_.{8}.+")
          //mod #9696 アプリケーションログのパスとファイル名の修正。 zhaoqi 20240403 end
                && (todayFiles[i].getName().matches(".+\\.ZIP$")||todayFiles[i].getName().matches(".+\\.zip$") )
        ) {
          String filesNameDate = todayFiles[i].getName().substring(todayFiles[i].getName().length() - 12,todayFiles[i].getName().length() - 4);
          if (filesNameDate.equals(dateNew) == false) {
            String targetPath = fileLocation.replaceAll("today", filesNameDate);
            Path targetPathTo = Path.of(targetPath);
            Path sourcePath = Path.of(fileLocation + "/" + todayFiles[i].getName());
            try {
              File dirtar = new File(targetPath);
              if (!dirtar.exists()) {
                dirtar.mkdirs();
              }
              Files.copy(sourcePath, targetPathTo.resolve(todayFiles[i].getName()), StandardCopyOption.REPLACE_EXISTING);
              delFiles.add(todayFiles[i]);
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
          }
        }
      }
      for (File delFile : delFiles) {
        if (delFile.exists()) {
          delFile.delete();
        }
      }
    }
    return true;
  }
  /**
   * S3へファイルをアップロードする
   * ・既に特定のディレクトリにファイルが存在し、そのファイルをアップロードする場合
   *
   * @param targetFilePath　対象ファイルパス(ファイル名も含む)
   * @param uploadPath アップロード先のパス(ファイル名も含む、s3://バケット名＋/XXXX)
   * @param isDelete true：成功失敗に関わらず対象ファイルを削除、false:成功の場合のみ対象ファイルを削除(失敗時は残す)
   * @return 成功:true、失敗:false
   */
  @Override
  public boolean UploadToS3(String targetFilePath, String uploadPath, boolean isDelete) {

    boolean isUpload = false;

    // プロセス処理の最大待ち時間(秒)
    int processTimeout = NumberCtrl.ParseNumber(this.environment.getProperty("fileIO.processTimeout"), "300", Integer.class);

    // 一時ファイルの準備
    File targetFile = new File(targetFilePath);
    try {
      if (false == targetFile.exists()) {
        // 対象ファイルが存在しない場合
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("[ntss-web-api]S3ファイルアップロード: 一時アップロード先フォルダの作成失敗[" + targetFile + "]");
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
        return false;
      }

      // S3へ転送
      //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      //int ret = AwsCliCtrl.S3IO(targetFilePath, uploadPath, processTimeout);
      int ret = AwsCliCtrl.S3IO(targetFilePath, uploadPath, processTimeout, logService);
      //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
      if (0 != ret) {
        // S3への転送(AWSCLI)で失敗
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("[ntss-web-api]S3ファイルアップロード: 転送元ファイル[" + targetFilePath + "]、転送先パス[" + uploadPath + "]");
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
        return false;
      }

      // 結果をtrue
      isUpload = true;
    } catch (Exception e) {
      // 異常終了時の処理
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("[ntss-web-api]S3ファイルアップロード: S3へのファイルアップロード時に例外発生　[" + e.getMessage() + "]");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      return false;
    }
    finally {
      // 強制削除または成功時削除で成功していた場合、対象ファイルを削除
      if (true == isDelete || (false == isDelete && true == isUpload)) {
        if (null != targetFile && true == targetFile.exists()) {
          // 対象ファイルを削除
          targetFile.delete();
        }
      }
    }

    return true;
  }

  /**
   * S3からファイルをダウンロードする
   *
   * @param fileName 対象ファイル名
   * @param downloadFilePath ダウンロード先のパス(ファイル名を含まない、s3://バケット名＋/XXXX)
   * @param savePath ダウンロードしたファイルの格納先(ファイル名を含まない)
   * @return 成功:true、失敗:false
   */
  @Override
  public boolean DownloadFromS3(String fileName, String downloadFilePath, String savePath) {

    // プロセス処理の最大待ち時間(秒)
    int processTimeout = NumberCtrl.ParseNumber(this.environment.getProperty("fileIO.processTimeout"), "300", Integer.class);

    // 格納先の準備
    File tempDir = new File(savePath);

    try {
      if (false == tempDir.exists()) {
        // 格納先フォルダが存在しない
        if (false == tempDir.mkdir()) {
          // 格納先フォルダ作成でエラー
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("[ntss-web-api]S3ファイルダウンロード: 格納先フォルダの作成失敗[" + savePath + "]");
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
          return false;
        }
      } else if (false == tempDir.isDirectory()) {
        // 格納先フォルダが存在するかと思いきや、実はフォルダではなくファイルだった場合
        // 異常終了
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("[ntss-web-api]S3ファイルダウンロード: 格納先フォルダと同名のファイルが存在した為、フォルダ作成に失敗[" + savePath + "]");
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
        return false;
      }

      // S3からダウンロード
      //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      //int ret = AwsCliCtrl.S3IO(downloadFilePath + "/" + fileName, savePath + "/" + fileName, processTimeout);
      int ret = AwsCliCtrl.S3IO(downloadFilePath + "/" + fileName, savePath + "/" + fileName, processTimeout, logService);
      //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
      if (0 != ret) {
        // S3からのダウンロード(AWSCLI)で失敗
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("[ntss-web-api]S3ファイルダウンロード: S3からのファイルダウンロードに失敗　ダウンロードファイル[" + downloadFilePath + "]、格納先パス[" + savePath + "]");
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
        return false;
      }
    } catch (Exception e) {
      // 異常終了時の処理
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("[ntss-web-api]S3ファイルダウンロード: S3からのファイルダウンロード時に例外発生　[" + e.getMessage() + "]");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      return false;
    } finally {
      // 処理が必要か
    }

    return true;
  }

  /**
   * S3のファイルを削除
   *
   * @param deleteFilePath 削除対象ファイルパス(ファイル名も含む、s3://バケット名＋/XXXX)
   * @return 成功:true、失敗:false
   */
  @Override
  public boolean DeleteFromS3(String deleteFilePath) {

    // プロセス処理の最大待ち時間(秒)
    int processTimeout = NumberCtrl.ParseNumber(this.environment.getProperty("fileIO.processTimeout"), "300", Integer.class);

    // S3のファイルを削除
    //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
    //int ret = AwsCliCtrl.S3Delete(deleteFilePath, processTimeout);
    int ret = AwsCliCtrl.S3Delete(deleteFilePath, processTimeout, logService);
    //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
    if (0 != ret) {
      // S3のファイルを削除(AWSCLI)で失敗
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("[ntss-web-api]S3ファイル削除: S3のファイル削除に失敗　対象ファイル[" + deleteFilePath + "]");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      return false;
    }

    return true;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public boolean DeleteFromOnPremise(String deleteFilePath) {

    File deleteFile = new File(deleteFilePath);
    if (null != deleteFile && deleteFile.exists()) {
      // 対象ファイルを削除
      if (!deleteFile.delete()) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("[ntss-web-api]ファイル削除: ファイル削除に失敗　対象ファイル[" + deleteFilePath + "]");
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
        return false;
      }
    } else {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("[ntss-web-api]ファイル削除:対象ファイルなし　対象ファイル[" + deleteFilePath + "]");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      return true;
    }
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("[ntss-web-api]ファイル削除: 削除成功　対象ファイル[" + deleteFilePath + "]");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);

    return true;
  }

  /**
   * 分割ファイルを結合する
   *
   * @param workFolderPath 結合対象(分割)ファイルの格納先パス
   * @param outFileName 結合後のファイル名(分割ファイルのファイル名の先頭部分とすること ※検索に使用)
   * @param outFilePath 結合ファイルの格納先
   * @return 成功:true、失敗:false
   */
  @Override
  public boolean FileJoin(String workFolderPath, String outFileName, String outFilePath) {

    // 設定ファイル情報取得(分割ファイル削除の待ち時間の最大値(ミリ秒にするため、1000倍))
    long tmpFileDelWait = NumberCtrl.ParseNumber(this.environment.getProperty("fileIO.deleteFileTimeout"), "10", Long.class) * 1000;

    // 設定ファイル情報取得(パス区切り文字)
    String pathSep = this.environment.getProperty("fileIO.pathSeparator");

    // フォルダの存在確認
    File filepath = new File(workFolderPath);
    if (false == filepath.exists()) {
      // フォルダが存在しない
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("[ntss-web-api]ファイル結合: 分割ファイルを格納しているフォルダが存在しない　対象フォルダ名[" + workFolderPath + "]");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      return false;
    }

    // 指定文字列でフィルタし、該当するファイルを取得する
    // 引数のファイル名(outFileName)と先頭から一致するものを対象とする
    FilenameFilter filter = new FilenameFilter() {
      public boolean accept(File file, String str) {
        return str.startsWith(outFileName);
      }
    };

    // ファイルの存確認
    File[] listFile = filepath.listFiles(filter);
    if(0 == listFile.length) {
      // ファイルが存在しない
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("[ntss-web-api]ファイル結合: 結合する分割ファイルが存在しない　対象ファイル名[" + outFileName + ".*" + "]");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      return false;
    }

    // 結合の準備
    // 分割ファイルのパス(ファイル名込み)
    String filePathFrom = workFolderPath + pathSep + outFileName + ".*";
    // 結合ファイルのパス(ファイル名込み)
    String filePathTo = outFilePath + pathSep + outFileName;
    // 結合一時ファイルのパス(ファイル名込み)
    String filePathToTmp = workFolderPath + pathSep + "tmp" + outFileName;

    // 結合後のファイルの一時名
    File joinFileNameTmp = new File(filePathToTmp);
    //　結合後のファイルの本名
    File joinFileName = new File(filePathTo);

    boolean ret = false;
    try {
      // 出力先フォルダが存在しない場合は作成する
      Path outPath = Paths.get(outFilePath);
      if (!Files.exists(outPath)) {
        Files.createDirectories(outPath);
      }

      BufferedInputStream is = null;
      BufferedOutputStream os = null;

      try {
        // 結合後一時ファイルへの出力ストリーム作成
        joinFileNameTmp.createNewFile();
        os = new BufferedOutputStream(new FileOutputStream(joinFileNameTmp));
        Arrays.sort(listFile);
        // バッファ1MB
        byte[] buf = new byte[1024 * 1024];

        int len = -1;

        // ファイル結合
        for (File targetFile : listFile) {
          is = new BufferedInputStream(new FileInputStream(targetFile));

          while((len = is.read(buf)) > 0) {
            os.write(buf, 0, len);
            os.flush();
          }
          os.flush();
          is.close();
        }

        ret = true;

      } finally {
        // ストリームクローズ
        if (is != null) {
          is.close();
        }
        if (os != null) {
          os.flush();
          os.close();
        }
      }

      // 正常終了した場合、結合したファイルをリネーム
      if (ret) {
        joinFileNameTmp.renameTo(joinFileName);
      }

    } catch (IOException e) {
      // 出力先フォルダ作成失敗
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("[ntss-web-api]ファイル結合 出力先フォルダ作成失敗: 例外発生[" + e.getMessage() + "]");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      ret = false;
    } catch (Exception ex) {
      // 例外発生
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("[ntss-web-api]ファイル結合: 例外発生[" + ex.getMessage() + "]");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      ret = false;
    } finally {

      // 分割ファイル削除の処理時間確認に使用
      long start = 0;
      long end = 0;

      // 分割ファイルを削除
      for (int i = 0 ; i < listFile.length ; i++) {

        // 現在日時(ミリ秒)
        start = System.currentTimeMillis();

        // 異常終了時のファイルでプロセスにつかまれて削除できないタイミングが発生する可能性があるためリトライを加味する
        // ただし、無限ループにならないように、1fileごとに指定時間たっても削除できない場合はスルーする
        while (true == listFile[i].exists() && (end - start < tmpFileDelWait)) {
          listFile[i].delete();
          end = System.currentTimeMillis();
        }
      }

      // エラーが発生している場合は作成(結合)ファイルの消去を行う
      // 中途半端に作成されている可能性あり
      if (false == ret) {

        File delFile = null;

        if (true == joinFileName.exists()) {
          // リネーム後のファイル確認
          delFile = joinFileName;
        } else {
          // リネーム後のファイルが存在しない場合、リネーム前のファイル確認
          delFile = joinFileNameTmp;
        }

        //　作成(結合)ファイルが存在する場合は削除
        if (null != delFile) {
          // 現在日時(ミリ秒)
          start = System.currentTimeMillis();

          // 異常終了時のファイルでプロセスにつかまれて削除できないタイミングが発生する可能性があるためリトライを加味する
          // ただし、無限ループにならないように、1fileごとに指定時間たっても削除できない場合はスルーする
          while(true == delFile.exists() && (end - start < tmpFileDelWait)) {
            delFile.delete();
            end = System.currentTimeMillis();
          }
        }
      }
    }

    return ret;
  }
}
