package jp.co.nikkiso.ntss.admin_web.service.log;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.nio.file.StandardCopyOption;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.amazonaws.services.s3.AmazonS3;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.admin_web.config.AwsConfiguration;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.SysSystemDefineDao;
import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;

@Service
public class LogUploderServiceImpl implements LogUploaderService {

  /**
   * 処理モード定義
   */
  public enum LogUploaderMode {
    Normal(0),
    SeparateFirst(1),
    SeparateMiddle(2),
    SeparateLast(3);

    private int value;

    private LogUploaderMode( int value ) {
      this.value = value;
    }
  };

  /**
   * Windowsアプリケーション名の定義
   */
  public static final String APP_NAME_LAYOUTDESIGNER = "FNWSiLayoutDesigner";    // 帳票レイアウトデザイナー
  public static final String APP_NAME_NKKWEIGHT = "NKKWeight";              // 体重計アプリ
  public static final String APP_NAME_NKKPRINT = "NKKPrint";                // 印刷サーバーアプリ
  public static final String APP_NAME_BLOODPURIFY = "FNWSiBloodPurify";          // 特殊浄化通信アプリ
  // add 5967 カードアプリのログアップロード名とアップロード先が正しくないため、ログの一部が消えてしまう  吉 start
  public static final String APP_NAME_NKKACCESSCARD = "NKKAccessCard";                // カード読み取りアプリ
  // add 5967 カードアプリのログアップロード名とアップロード先が正しくないため、ログの一部が消えてしまう  吉 end
  // #11987 2026.03.24 add スケールベッドアプリのTRACEログアップロード TDC伊東 start
  public static final String APP_NAME_NKKSCALEBED = "NKKScaleBed"; // スケールベッドアプリ
  // #11987 2026.03.24 add スケールベッドアプリのTRACEログアップロード TDC伊東 end
  // TODO: S3へのアップロードを行う場合には以下の処理を使用する(現時点では未使用)
  /**
   * S3バケット名
   */
  @Value("${ntss.log.s3-bucket:}")
  private String s3Bucket;

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
  private SysSystemDefineDao sysSystemDefineDao;
  @Autowired
  private MstFacilitySettingDao mstFacilitySettingDao;



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
   * ファイル名含むログ出力先の取得
   * @return
   * @throws Exception
   */
  private String getLogOutputPath(String facilityCd, String appName, String fileName) throws Exception {
      String outputPath = null;
      Integer ctlNo = 0;
      switch (appName) {
        case APP_NAME_LAYOUTDESIGNER:
          ctlNo = CoreConstant.SysSystemDefine.LAYOUTDESIGNER_LOG_OUTPUT_PATH;
          break;
        case APP_NAME_NKKWEIGHT:
          ctlNo = CoreConstant.SysSystemDefine.NKKWEIGHT_LOG_OUTPUT_PATH;
          break;
        case APP_NAME_NKKPRINT:
          ctlNo = CoreConstant.SysSystemDefine.NKKPRINT_LOG_OUTPUT_PATH;
          break;
        case APP_NAME_BLOODPURIFY:
          ctlNo = CoreConstant.SysSystemDefine.BLOODPURIFY_LOG_OUTPUT_PATH;
          break;
        // add 5967 カードアプリのログアップロード名とアップロード先が正しくないため、ログの一部が消えてしまう  吉 start
        case APP_NAME_NKKACCESSCARD:
          ctlNo = CoreConstant.SysSystemDefine.NKKACCESSCARD_LOG_OUTPUT_PATH;
          break;
        // add 5967 カードアプリのログアップロード名とアップロード先が正しくないため、ログの一部が消えてしまう  吉 end
        // #11987 2026.03.24 add スケールベッドアプリのTRACEログアップロード TDC伊東 start
        case APP_NAME_NKKSCALEBED:
          ctlNo = CoreConstant.SysSystemDefine.NKKSCALEBED_LOG_OUTPUT_PATH;
          break;
        // #11987 2026.03.24 add スケールベッドアプリのTRACEログアップロード TDC伊東 end
        default:
          ctlNo = CoreConstant.SysSystemDefine.UNKNOWNAPP_LOG_OUTPUT_PATH;
      }
      List<SysSystemDefine> data = sysSystemDefineDao.selectByCtlNo(ctlNo);
      if (data.size() > 0) {
        String strJson = data.get(0).getValue();
        JSONObject objJson = new JSONObject(strJson);
        outputPath = objJson.getString("path").replace("{0}", facilityCd) + fileName;
        // add 9696 アプリケーションログのパスとファイル名の修正。 2023/11/20 by liumx start
        outputPath = outputPath.replace("{1}", "today");
        String fileLocation = objJson.getString("path").replace("{0}", facilityCd).replace("{1}", "today");
        String rootDirectory;

        String osName = System.getProperty("os.name");
        if (osName.contains("Windows")) {
          String rootPath = System.getProperties().getProperty("user.dir");
          rootDirectory = rootPath.substring(0,1) + ":";
          fileLocation = (rootDirectory + fileLocation).replace("/","\\");
        }
        File dir = new File(fileLocation);
        if(!dir.exists()) {
          dir.mkdirs();
        }
        File folder = new File(fileLocation);
        List<File> delFiles = new ArrayList<>();
        if (folder.isDirectory()) {
          File[] files = folder.listFiles();
          for (File file : files) {
            String pattern = "^[0-9]{8}$";
            String fileNameOld = file.getName();
            String fileDate = "";
            for (String dateUrl : fileNameOld.split("_")) {
              // mod #10756 拡張しを小文字に統一すること。 dengshen start
              // if (dateUrl.contains(".ZIP")) {
              if (dateUrl.contains(".ZIP") || dateUrl.contains(".zip")) {
              // mod #10756 拡張しを小文字に統一すること。 dengshen start
                fileDate = dateUrl.substring(0, 8);
                if (Pattern.matches(pattern, fileDate)) {
                  break;
                } else {
                  continue;
                }
              }
              if (Pattern.matches(pattern, dateUrl)) {
                fileDate = dateUrl;
                break;
              }
            }
            boolean isMatch = Pattern.matches(pattern, fileDate);
            if (isMatch){
              Date currentDate = new Date();
              SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMdd");
              String formattedDate = dateFormat.format(currentDate);
              if (!fileDate.equals(formattedDate)){
                Path sourcePath;
                if (osName.contains("Windows")) {
                  sourcePath = Path.of(fileLocation + "\\" + file.getName());
                } else {
                  sourcePath = Path.of(fileLocation + "/" + file.getName());
                }
                Path targetPath =  Path.of(sourcePath.toString().replace("today", fileDate));
                File dirtar = new File(fileLocation.replace("today", fileDate));
                if(!dirtar.exists()) {
                  dirtar.mkdirs();
                }
                Files.copy(sourcePath, targetPath, StandardCopyOption.REPLACE_EXISTING);
                delFiles.add(file);
              }
            }
          }
          for (File delFile:delFiles){
            if (delFile.exists()) {
              delFile.delete();
            }
          }
        }
        // add 9696 アプリケーションログのパスとファイル名の修正。 2023/11/20 by liumx end
      }
      return outputPath;
  }


  /**
   * {@inheritDoc}
   */
  public void logFileUpload(int mode, String facilityCd, String appName, String fileName, MultipartFile upFile) throws Exception {
    // ファイル読み込み
    byte[] bytes = upFile.getBytes();

    // 保存ファイル名作成
    String path = "/tmp/" + facilityCd + "/";
    path += fileName;

    // 新規作成
    StandardOpenOption fileOption = StandardOpenOption.TRUNCATE_EXISTING;
    // 書き込みファイルの存在チェック
    Path filePath = Paths.get(path);
    if (!Files.exists(filePath)) {
      // 該当ファイルなし(新規作成)
      Files.createDirectories(filePath.getParent());
      File newFile = new File(filePath.toString());
      newFile.createNewFile();
    } else {
      // 該当ファイルあり
      // 処理モード判定
      if( LogUploaderMode.SeparateMiddle.value <= mode ) {
        // 処理モードが分割途中、分割末尾である場合

        // 書き込み先ファイルの末尾に追記
        fileOption = StandardOpenOption.APPEND;
      }
    }

    // ファイル書き込み
    Files.write(filePath, bytes, StandardOpenOption.WRITE, fileOption );

    // 処理モード判定
    if( mode == LogUploaderMode.Normal.value
     || mode == LogUploaderMode.SeparateLast.value ) {
      // 通常、分割末尾の場合

      try {
        // ログ出力先の取得
        String strMovePath = this.getLogOutputPath(facilityCd, appName, fileName);

        // 移動先
        Path movePath = Paths.get(strMovePath);

        // 移動先ディレクトリ作成
        Files.createDirectories(movePath.getParent());

        // ファイル移動（常に指定パスに保存。S3にはアップしない。）
        Files.move(filePath, movePath, StandardCopyOption.REPLACE_EXISTING);
      } catch (Exception e) {
        throw e;
      }
    }
  }
}
