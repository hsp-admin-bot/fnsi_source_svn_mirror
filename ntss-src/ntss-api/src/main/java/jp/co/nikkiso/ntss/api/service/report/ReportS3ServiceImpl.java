package jp.co.nikkiso.ntss.api.service.report;

import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.model.GetObjectRequest;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.PutObjectRequest;
import com.amazonaws.services.s3.model.S3Object;
import com.amazonaws.services.s3.model.S3ObjectInputStream;
import com.amazonaws.util.IOUtils;
import com.fasterxml.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.api.service.LogService;
import jp.co.nikkiso.ntss.api.service.onPremise.OnPremiseService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.SysSystemDefineDao;
import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import lombok.extern.slf4j.Slf4j;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import com.fasterxml.jackson.core.type.TypeReference;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.attribute.BasicFileAttributeView;
import java.nio.file.attribute.FileTime;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.HashMap;
import java.util.stream.Stream;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * 帳票取得のServiceインタフェース.
 */
@Service
@Slf4j
class ReportS3ServiceImpl implements ReportS3Service {

  /**
   * Amazon S3.
   */
  @Autowired(required = false)
  private AmazonS3 s3;

  /**
   * 帳票ファイルをキャッシュするディレクトリ
   */
  @Value("${ntss.report.cache-dir}")
  private String cacheDir;

  /**
   * システム設定のDaoインタフェース.
   */
  @Autowired
  private SysSystemDefineDao sysSystemDefineDao;

  /**
   * オンプレミスサービス
   */
  @Autowired
  private OnPremiseService onPremiseService;

  @Autowired
  private LogService logService;

  /**
   * オンプレミスの管理番号
   */
  private final int CTL_NO_ON_PREMISE = 14;

  public ReportS3ServiceImpl() {
  }

  /**
   * 帳票キャッシュファイル名の生成.
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
   * {@inheritDoc}
   */
  @Override
  public byte[] getReportFile(String bucket, String filePath, Timestamp upDate) throws NotExistException {
    String localStore = null;
    String status = null;
    try {
      SysSystemDefine data = sysSystemDefineDao.selectOnPremise(CoreConstant.SysSystemDefine.CTL_NO_ON_PREMISE);
      ObjectMapper objectMapper = new ObjectMapper();
      HashMap<String, String> onPremise = objectMapper.readValue(data.getValue(), new TypeReference<HashMap<String, String>>(){});
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
      return new byte[0];
    }
    if (status.equals("off")) {
      // bucket名から"s3://"を取り除く
      // "s3://"を付与している事でS3からS3Objectの取得が出来ない為
      bucket = bucket.replace("s3://", "");

      // キャッシュファイルパスの生成
      // add #7233 デフォルト帳票について 商 start
      if (filePath.startsWith("_")) {
        filePath = filePath.substring(1);
      }
      // add #7233 デフォルト帳票について 商 end
      String baseName = filePath.replace("/", "_");
      File cacheFile = getCacheFile(baseName, upDate);

      try {
        // 古いキャッシュファイルを削除
        // 帳票ファイルパスが等しく、更新日時部分が異なっているファイルを削除対象とする
        Path cacheDirPath = Paths.get(this.cacheDir);
        if (Files.exists(cacheDirPath)) {
          try (Stream<Path> streamFiles = Files.list(Paths.get(this.cacheDir))) {
            streamFiles.map(path -> path.toFile())
              .filter((f -> {
                return f.getName().startsWith(baseName)
                  && !(upDate == null || f.getName().equals(cacheFile.getName()));
              }))
              .forEach(f -> f.delete())
            ;
          }
          /*Files.list(Paths.get(this.cacheDir))
            .map(path -> path.toFile())
            .filter((f -> {
              return f.getName().startsWith(baseName)
                && !(upDate == null || f.getName().equals(cacheFile.getName()));
            }))
            .forEach(f -> f.delete())
          ;*/
        } else {
          // キャッシュディレクトリを作成
          Files.createDirectories(cacheDirPath);
        }

        // キャッシュが存在したらその内容を返す
        if (cacheFile.exists()) {
          // add 2021-04-26 外部連携:log内容を改善 孫 start
          // DEBUGログ出力
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("Debug info cacheFile:" + cacheFile.getName());
          logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          // add 2021-04-26 外部連携:log内容を改善 孫 end
          try {
            // キャッシュファイルのアクセス日時を更新
            BasicFileAttributeView view = Files.getFileAttributeView(cacheFile.toPath(), BasicFileAttributeView.class);
            view.setTimes(null, FileTime.fromMillis(System.currentTimeMillis()), null);
          } catch (Exception e) {
            // 最終アクセス時間更新失敗
          }
          return Files.readAllBytes(cacheFile.toPath());
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
        return new byte[0];
      }

      // S3オブジェクト取得
      // レスポンス用データ生成
      try (S3Object object = s3.getObject(new GetObjectRequest(bucket, filePath));
           InputStream inputStream = object.getObjectContent();
           ByteArrayOutputStream outputStream = new ByteArrayOutputStream()) {

        // add 2021-04-26 外部連携:log内容を改善 孫 start
        // DEBUGログ出力
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("Debug info S3 bucketName:" + bucket + " filePath:" + filePath);
        logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        // add 2021-04-26 外部連携:log内容を改善 孫 end

        byte[] buffer = new byte[1024];
        while (true) {
          int len = inputStream.read(buffer);
          if (len < 0) {
            break;
          }
          outputStream.write(buffer, 0, len);
        }

        // キャッシュにデータを保存
        Files.write(cacheFile.toPath(), outputStream.toByteArray());

        return outputStream.toByteArray();
      } catch (Exception e) {
        // エラーメッセージをログ出力
        EventLogMessage eventLogMessage = new EventLogMessage();
        // add #8870 帳票画面にてデータ無しのエラーメッセージが規範的ではない 王 start
        String errMessage = "テンプレートがない";
        // add #8870 帳票画面にてデータ無しのエラーメッセージが規範的ではない 王 end
        // mod #8870 帳票画面にてデータ無しのエラーメッセージが規範的ではない 王 start
        // eventLogMessage.setLogMessage(e.getMessage());
        eventLogMessage.setLogMessage(errMessage);
        // mod #8870 帳票画面にてデータ無しのエラーメッセージが規範的ではない 王 end
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        // mod #8870 帳票画面にてデータ無しのエラーメッセージが規範的ではない 王 start
        // throw new NotExistException(e.getMessage());
        throw new NotExistException(errMessage);
        // mod #8870 帳票画面にてデータ無しのエラーメッセージが規範的ではない 王 end
      }
    } else {
      // add 2021-03-11 bucket名から"s3://"を取り除く 孫 start
      // bucket名から"s3://"を取り除く
      // "s3://"を付与している事でS3からS3Objectの取得が出来ない為
      bucket = bucket.replace("s3://", "");
      // add 2021-03-11 bucket名から"s3://"を取り除く 孫 end

      localStore += "/" + bucket;
      return onPremiseService.getReportFile(localStore, filePath, upDate);
    }
  }
  // add 6589 治癒経過表：プレビューでシステムエラー 吉 start
  @Override
  public Boolean getReportFileIsExist(String bucket, String filePath, Timestamp upDate) throws NotExistException {
    String localStore = null;
    String status = null;
    boolean flag = false;
    try {
      SysSystemDefine data = sysSystemDefineDao.selectOnPremise(CoreConstant.SysSystemDefine.CTL_NO_ON_PREMISE);
      ObjectMapper objectMapper = new ObjectMapper();
      HashMap<String, String> onPremise = objectMapper.readValue(data.getValue(), new TypeReference<HashMap<String, String>>(){});
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
      return flag;
    }
    if (status.equals("off")) {
    // mod 8588 【デグレ】帳票を修正してオンライン保存できない  吉 start
//      // bucket名から"s3://"を取り除く
//      // "s3://"を付与している事でS3からS3Objectの取得が出来ない為
//      bucket = bucket.replace("s3://", "");
//      // キャッシュファイルパスの生成
//      // add #7233 デフォルト帳票について 商 start
//      if (filePath.startsWith("_")) {
//        filePath = filePath.substring(1);
//      }
//      String baseName = filePath.replace("/", "_");
//      File cacheFile = getCacheFile(baseName, upDate);
//      try {
//        // 古いキャッシュファイルを削除
//        // 帳票ファイルパスが等しく、更新日時部分が異なっているファイルを削除対象とする
//        Path cacheDirPath = Paths.get(this.cacheDir);
//        if (Files.exists(cacheDirPath)) {
//          try (Stream<Path> streamFiles = Files.list(Paths.get(this.cacheDir))) {
//            streamFiles.map(path -> path.toFile())
//              .filter((f -> {
//                return f.getName().startsWith(baseName)
//                  && !(upDate == null || f.getName().equals(cacheFile.getName()));
//              }))
//              .forEach(f -> f.delete())
//            ;
//          }
//        } else {
//          // キャッシュディレクトリを作成
//          Files.createDirectories(cacheDirPath);
//        }
//        // キャッシュが存在したらその内容を返す
//        if (cacheFile.exists()) {
//          return true;
//        }else{
//          return flag;
//        }
//      } catch (IOException e) {
//        e.printStackTrace();
//        return flag;
//      }
      bucket = bucket.replace("s3://", "");
      boolean flag1 = s3.doesObjectExist(bucket,filePath);
      if (flag1) {
        return true;
      }else{
        return flag;
      }
      // mod 8588 【デグレ】帳票を修正してオンライン保存できない  吉 end
    } else {
      bucket = bucket.replace("s3://", "");
      localStore += "/" + bucket;
      String fileLocation = localStore + "/" + filePath;
      Path path = Paths.get(fileLocation);
      if (Files.exists(path)) {
        return true;
      }else{
        return flag;
      }
    }
  }
  // add 6589 治癒経過表：プレビューでシステムエラー 吉 end

  /**
   * {@inheritDoc}
   */
  @Override
  public void putFile(String bucket, String destFilePath, Path srcFilePath) throws FileNotFoundException, IOException {
    String localStore = null;
    String status = null;
    try {
      SysSystemDefine data = sysSystemDefineDao.selectOnPremise(CTL_NO_ON_PREMISE);
      ObjectMapper objectMapper = new ObjectMapper();
      HashMap<String, String> onPremise = objectMapper.readValue(data.getValue(), new TypeReference<HashMap<String, String>>(){});
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
      throw new NtssException(e.getMessage());
    }
    if (status.equals("off")) {
      File file = srcFilePath.toFile();

      try (FileInputStream fis = new FileInputStream(file)) {
        // アップロードファイルの準備
        ObjectMetadata om = new ObjectMetadata();
        om.setContentLength(file.length());

        final PutObjectRequest putRequest = new PutObjectRequest(bucket, destFilePath, fis, om);

        // アップロード
        s3.putObject(putRequest);
      } catch (Exception e) {
        // エラーメッセージをログ出力
        EventLogMessage eventLogMessage = new EventLogMessage();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        throw new NtssException(e.getMessage());
      }
    } else {
      localStore += "/" + bucket;
      onPremiseService.putFile(localStore, destFilePath, srcFilePath);
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public byte[] getOutputFileData(String bucket, String filePath) {
    // TODO：キャッシュ処理がまだ実装できておりません。

    byte[] resultByte = new byte[0];
    // オンプレミス環境かの判定により取得先の判定 ( S3 or ローカルフォルダ )
    String localStore = null;
    String status = null;
    try {
      SysSystemDefine data = sysSystemDefineDao.selectOnPremise(CoreConstant.SysSystemDefine.CTL_NO_ON_PREMISE);
      ObjectMapper objectMapper = new ObjectMapper();
      HashMap<String, String> onPremise = objectMapper.readValue(data.getValue(), new TypeReference<HashMap<String, String>>(){});
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
      return new byte[0];
    }

    // ファイル取得処理
    try {
      if (status.equals("off")) {
        // オンプレミス環境ではない為、S3からファイルを取得
        S3Object object = s3.getObject(new GetObjectRequest(bucket, filePath));
        S3ObjectInputStream inputStream = object.getObjectContent();
        resultByte =  IOUtils.toByteArray(inputStream);

      } else {
        // オンプレミス環境の為、フォルダからファイルを取得
        String fileLocation = localStore + "/" + bucket + "/" + filePath;
        Path pathFile = Paths.get(fileLocation);
        resultByte = Files.readAllBytes(pathFile);
      }
    } catch (IOException ioException) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      ioException.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // エラーメッセージをログ出力
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(ioException));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // エラーメッセージをログ出力
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }

    return resultByte;
  }

}
