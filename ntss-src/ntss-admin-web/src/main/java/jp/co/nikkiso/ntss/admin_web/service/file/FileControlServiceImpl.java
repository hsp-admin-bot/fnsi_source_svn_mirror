package jp.co.nikkiso.ntss.admin_web.service.file;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashMap;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import tools.jackson.core.type.TypeReference;
import tools.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.SysSystemDefineDao;
import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;

@Service
public class FileControlServiceImpl implements FileControlService {
  /**
   * Amazon S3.
   */
  @Autowired
  private S3Client s3;
  /**
   * システム設定のDaoインタフェース.
   */
  @Autowired
  private SysSystemDefineDao sysSystemDefineDao;

  /**
  * ロギングのServiceインタフェース.
  */
  @Autowired
  private LogService logService;

  // MOD #10637 2024/09/05 Thach Start
  
  @Override
  public boolean fileUpload2S3(MultipartFile file, String facilityCd) {

    if (true == StringUtils.isEmpty(facilityCd)) {
      // 引数(facilityCd)が空の場合、処理を実施しない
      // ログ
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("[fileUpload2S3]ファイルアップロード: アップロード先施設情報が空のため処理終了");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return false;
    }

    String localStore = null;
    String status = null;
    String desBucket = null;
    String filePath = null;
    try {
      SysSystemDefine data = sysSystemDefineDao.selectOnPremise(CoreConstant.SysSystemDefine.CTL_NO_ON_PREMISE);
      ObjectMapper objectMapper = new ObjectMapper();
      HashMap<String, String> onPremise = objectMapper.readValue(data.getValue(), new TypeReference<HashMap<String, String>>(){});
      localStore = onPremise.get("path");
      status = onPremise.get("status");

      // Sys_System_Defineの39から保存先のパスを取得する
      data = sysSystemDefineDao.selectOnPremise(CoreConstant.SysSystemDefine.REPORT_PATH);
      HashMap<String, String> rpPathHm = objectMapper.readValue(data.getValue(), new TypeReference<HashMap<String, String>>(){});
      String desRpPath = rpPathHm.get("path");
      desBucket = desRpPath.substring(0, desRpPath.indexOf("/")); // 例：ntss-s3-root-service
      filePath = extractString(String.format(desRpPath, facilityCd), 1); // 例：%s/Report
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("[fileUpload2S3]ファイルアップロード: システム設定の取得に失敗[" + e.getMessage() + "]");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return false;
    }

    if (status.equals("on")) {
      // オンプレミス
      try {
        String fileLocation = localStore + "/" + desBucket + "/" + filePath + "/" + file.getOriginalFilename();
        Path pathFile = Paths.get(fileLocation);
        if (!Files.exists(pathFile)) {
          Files.createDirectories(pathFile.getParent());
          File newFile = new File(pathFile.toString());
          newFile.createNewFile();
        }

        pathFile.toFile().delete();
        Files.write(pathFile, file.getBytes());
        return true;
      } catch (IOException e) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("[fileUpload2S3]ファイルアップロード: アップロード失敗:" + e);
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      }
    } else {
      // S3使用
      try (InputStream inputStream = file.getInputStream()) {

        String path = filePath + "/" + file.getOriginalFilename();

        // S3アップロード
        s3.putObject(PutObjectRequest.builder()
            .bucket(desBucket)
            .key(path)
            .contentLength(file.getSize())
            .contentType(file.getContentType())
            .build(), RequestBody.fromInputStream(inputStream, file.getSize()));
        return true;
      } catch (Exception e) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("[fileUpload2S3]ファイルアップロード: アップロード失敗:" + e);
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      }
    }
    return false;
  }

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
  
  // MOD #10637 2024/09/05 Thach End
}
