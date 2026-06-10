package jp.co.nikkiso.ntss.coop_api.service;

import com.amazonaws.services.s3.AmazonS3;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.dao.SysSystemDefineDao;
import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.nio.file.StandardOpenOption;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
  private AmazonS3 s3;

  @Autowired
  private SysSystemDefineDao sysSystemDefineDao;



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
  private String getLogOutputPath(String logType, String facilityCd, String appName, String fileName) throws Exception {
      String outputPath = null;
      Integer ctlNo = 0;
      List<SysSystemDefine> data = sysSystemDefineDao.selectByCtlNo(CoreConstant.SysSystemDefine.IFEDGE_LOG_OUTPUT_PATH);
      if (data.size() > 0) {
        String strJson = data.get(0).getValue();
        JSONObject objJson = new JSONObject(strJson);
        outputPath = objJson.getString("path").replace("{0}", facilityCd).replace("{1}", getOutputPath(fileName)) + logType + "/";
      } else {
          throw new Exception("システム設定のIFエッジログPath(ctl_no=1007)が無し。");
      }
      if (StringUtils.isEmpty(outputPath)) {
        throw new Exception("システム設定のIFエッジログPath(ctl_no=1007)にpathが無し。");
      }
      return outputPath;
  }

  private String getOutputPath(String fileName) {
    String[] splitName = fileName.split("_");
    if(splitName.length > 4){
      String fileDate = splitName[4];
      Date currentDate = new Date();
      SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMdd");
      String formattedDate = dateFormat.format(currentDate);
      if (!fileDate.equals(formattedDate)){
        return fileDate;
      }
    }
    return "today";
  }


  /**
   * {@inheritDoc}
   */
  public void logFileUpload(int mode, String logType, String facilityCd, String appName, String fileName, MultipartFile upFile) throws Exception {
    // ファイル読み込み
    byte[] bytes = upFile.getBytes();

    // 保存ファイル名作成
    String path = "/tmp/" + facilityCd + "/" + logType + "/";
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
        String strMovePath = this.getLogOutputPath(logType, facilityCd, appName, fileName);
        if (strMovePath.contains("today")) {
          File directory = new File(strMovePath);
          if(directory.exists()){
            File[] files = directory.listFiles();
            for (File file : files) {
              String fileNameToday = getOutputPath(file.getName());
              if(fileNameToday.equals("today")){
                continue;
              }
              moveFileToTargetDir(file.getName(), strMovePath.replace("today", fileNameToday), Paths.get(strMovePath + file.getName()));
            }
          }
        }
        // 移動先
        moveFileToTargetDir(fileName, strMovePath, filePath);
      } catch (Exception e) {
        throw e;
      }
    }
  }

  private void moveFileToTargetDir(String fileName, String strMovePath, Path filePath) throws IOException {
    Path movePath = Paths.get(strMovePath + fileName);

    // 移動先ディレクトリ作成
    Files.createDirectories(movePath.getParent());

    // ファイル移動（常に指定パスに保存。S3にはアップしない。）
    Files.move(filePath, movePath, StandardCopyOption.REPLACE_EXISTING);
  }
}
