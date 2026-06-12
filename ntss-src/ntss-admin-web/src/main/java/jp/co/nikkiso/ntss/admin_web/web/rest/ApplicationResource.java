package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.Files;
import java.util.Arrays;
import java.util.List;
import java.util.HashMap;
import jakarta.validation.Valid;

import jp.co.nikkiso.ntss.core.utils.HexCodecUtils;
import software.amazon.awssdk.core.ResponseInputStream;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;
import software.amazon.awssdk.services.s3.model.GetObjectResponse;
import jp.co.nikkiso.ntss.admin_web.DownloadProperties;
import jp.co.nikkiso.ntss.admin_web.SelfUpdateProperties;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.request.application.ApplicationDownloadRequest;
import jp.co.nikkiso.ntss.admin_web.request.application.ApplicationSelfUpdateRequest;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.SysApplicationDao;
import jp.co.nikkiso.ntss.core.dao.SysSystemDefineDao;
import jp.co.nikkiso.ntss.core.entity.SysApplication;
import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ResourceLoader;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import tools.jackson.core.type.TypeReference;
import tools.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.core.utils.HexCodecUtils;

/**
 * 対象アプリケーションとのResourceクラス.
 */
@RestController
@RequestMapping(Uri.APPLICATION)
public class ApplicationResource {

  private static final int FILE_READ_BUFFER_SIZE = 8192;

  /**
   * ログService.
   */
	@Autowired
	LogService logService;

  @Autowired
  private S3Client s3;

  /**
   * システム設定のDaoインタフェース.
   */
  @Autowired
  private SysSystemDefineDao sysSystemDefineDao;

  /**
   * アプリケーションダウンロードのDaoインタフェース.
   */
  @Autowired
  private SysApplicationDao sysApplicationDao;

  @Autowired
  private DownloadProperties downloadProperties;

  @Autowired
  private SelfUpdateProperties selfUpdateProperties;

  /**
   * リソースファイルアクセス用.
   */
  @Autowired
  ResourceLoader resourceLoader;

  /**
   * 単体アプリのダウンロード処理.
   *
   * @param request ファイルダウンロードのリクエスト
   * @return ファイルダウンロード用ResponseEntity
   */
  @PostMapping("/download")
  public ResponseEntity<?> downloadGathering(@Valid @RequestBody ApplicationDownloadRequest request) {
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to download.");
    eventLogMessage.setInvokeClass(this.getClass().getName());
    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);

    String filename = request.getFilename();
    String bucket;
    String fileName;
    try {
      SysApplication sysApp = sysApplicationDao.selectByFileName(filename, "1", "0");
      if(sysApp == null || StringUtils.isEmpty(sysApp.getPath())){
        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
      }
      bucket = sysApp.getPath().substring(0, sysApp.getPath().lastIndexOf("/"));
      fileName = sysApp.getPath().substring(sysApp.getPath().lastIndexOf("/") + 1);
      if(StringUtils.isEmpty(bucket) || StringUtils.isEmpty(fileName)) {
        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
      }
    } catch (Exception e) {
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

    String status;
    try {
      SysSystemDefine data = sysSystemDefineDao.selectOnPremise(CoreConstant.SysSystemDefine.CTL_NO_ON_PREMISE);
      ObjectMapper objectMapper = new ObjectMapper();
      HashMap<String, String> onPremise = objectMapper.readValue(data.getValue(), new TypeReference<HashMap<String, String>>(){});
      status = onPremise.get("status");
    } catch (Exception e) {
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }

    try {
      if (status.equals("on")) {
        if(downloadProperties != null && downloadProperties.getApplicationDl() != null && !StringUtils.isEmpty(downloadProperties.getApplicationDl().getFileLocation())) {
          byte[] res = getFilebyStrPath(downloadProperties.getApplicationDl().getFileLocation() + "/" + fileName);
          if(res != null && res.length > 0){
            HttpHeaders header = new HttpHeaders();
            header.set("Content-Type", "application/msi");
            header.set(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=" + fileName);
            return new ResponseEntity<>(res, header, HttpStatus.OK);
          }
        }

        byte[] res = getFilebyStrLocation(bucket + "/" + fileName);
        if(res != null && res.length > 0){
          HttpHeaders header = new HttpHeaders();
          header.set("Content-Type", "application/msi");
          header.set(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=" + fileName);
          return new ResponseEntity<>(res, header, HttpStatus.OK);
        }
      } else {
        if(downloadProperties != null && downloadProperties.getApplicationDl() != null && !StringUtils.isEmpty(downloadProperties.getApplicationDl().getFileLocation())) {
          byte[] res = getFileInS3(downloadProperties.getApplicationDl().getFileLocation(), fileName);
          if(res != null && res.length > 0){
            HttpHeaders header = new HttpHeaders();
            header.set("Content-Type", "application/msi");
            header.set(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=" + fileName);
            return new ResponseEntity<>(res, header, HttpStatus.OK);
          }
        }
      }
      return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    } catch (Exception e) {
      // エラーメッセージをログ出力
    	eventLogMessage.setLogMessage(e.getMessage());
    	logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
    }
    return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
  }

  /**
   * 単体アプリの自己アップデート処理.
   *
   * @param request 自己アップデートのリクエスト
   * @return 自己アップデートファイル用ResponseEntity
   */
  @PostMapping("/self_update")
  public ResponseEntity<?> applicationSelfUpdate(@Valid @RequestBody ApplicationSelfUpdateRequest request) {
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to selfupdate.");
    eventLogMessage.setInvokeClass(this.getClass().getName());
    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);

    Integer ctl_no = request.getCtl_no();

    String bucket = null;
    String fileName = null;
    try {
      SysSystemDefine pathData = sysSystemDefineDao.selectOnPremise(ctl_no);
      if (pathData == null || StringUtils.isEmpty(pathData.getValue())) {
        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
      }
      ObjectMapper objectMapper = new ObjectMapper();
      List<HashMap<String, String>> versions = objectMapper.readValue(
        pathData.getValue(),
        new TypeReference<List<HashMap<String, String>>>() {}
      );
      if (versions == null || versions.isEmpty()) {
        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
      }
      int maxVersion = 0;
      for (HashMap<String, String> item : versions) {
        String strVersion = item.getOrDefault("version", "").replace(".","");
        Integer iVersion = Integer.parseInt(strVersion);
        if (iVersion > maxVersion) {
          maxVersion = iVersion;
          bucket = item.getOrDefault("self_update_path", null);
          fileName = item.getOrDefault("self_update_filename", null);
        }
      }
      if (StringUtils.isEmpty(bucket) || StringUtils.isEmpty(fileName)) {
        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
      }
    } catch (Exception e) {
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

    String status;
    try {
      SysSystemDefine data = sysSystemDefineDao.selectOnPremise(CoreConstant.SysSystemDefine.CTL_NO_ON_PREMISE);
      ObjectMapper objectMapper = new ObjectMapper();
      HashMap<String, String> onPremise = objectMapper.readValue(data.getValue(), new TypeReference<HashMap<String, String>>(){});
      status = onPremise.get("status");
    } catch (Exception e) {
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }

    try {
      if (status.equals("on")) {
        if(selfUpdateProperties != null && selfUpdateProperties.getApplicationUd() != null && !StringUtils.isEmpty(selfUpdateProperties.getApplicationUd().getFileLocation())) {
          byte[] bytes = getFilebyStrPath(selfUpdateProperties.getApplicationUd().getFileLocation() + "/" + fileName);
          if(bytes != null && bytes.length > 0){
            // 16進数文字列に変換
            String hexString = HexCodecUtils.printHexBinary(bytes);

            return new ResponseEntity<>(hexString, HttpStatus.OK);
          }
        }

        byte[] bytes = getFilebyStrLocation(bucket + "/" + fileName);
        if(bytes != null && bytes.length > 0){
          // 16進数文字列に変換
          String hexString = HexCodecUtils.printHexBinary(bytes);
          return new ResponseEntity<>(hexString, HttpStatus.OK);
        }
      } else {
        if(selfUpdateProperties != null && selfUpdateProperties.getApplicationUd() != null && !StringUtils.isEmpty(selfUpdateProperties.getApplicationUd().getFileLocation())) {
          byte[] bytes = getFileInS3(selfUpdateProperties.getApplicationUd().getFileLocation(), fileName);
          if(bytes != null && bytes.length > 0){
            // 16進数文字列に変換
            String hexString = HexCodecUtils.printHexBinary(bytes);
            return new ResponseEntity<>(hexString, HttpStatus.OK);
          }
        }
      }
      return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    } catch (Exception e) {
      // エラーメッセージをログ出力
      eventLogMessage.setLogMessage(e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
    }
    return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
  }

  private byte[] getFilebyStrPath(String strPath) {
    Path path = Paths.get(strPath);
    if (!Files.isRegularFile(path)) {
      return null;
    }
    try {
      long fileSize = Files.size(path);
      if (fileSize == 0) {
        return new byte[0];
      }
      if (fileSize > Integer.MAX_VALUE) {
        return null;
      }
      byte[] result = new byte[(int) fileSize];
      try (InputStream inputStream = new BufferedInputStream(Files.newInputStream(path), FILE_READ_BUFFER_SIZE)) {
        int offset = 0;
        while (offset < result.length) {
          int read = inputStream.read(result, offset, result.length - offset);
          if (read == -1) {
            return offset == 0 ? null : Arrays.copyOf(result, offset);
          }
          offset += read;
        }
      }
      return result;
    } catch (IOException e) {
      return null;
    }
  }

  private byte[] getFilebyStrLocation(String strPath){
    byte[] res = null;
    try {
      URL url = resourceLoader.getResource("classpath:" + strPath).getURL();
      try (
        InputStream inputStream = url.openStream();
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream()
      ) {
        byte[] buffer = new byte[1024];
        while (true) {
          int len = inputStream.read(buffer);
          if (len < 0) {
            break;
          }
          outputStream.write(buffer, 0, len);
        }

        res = outputStream.toByteArray();
      } catch (Exception e) {
        e.printStackTrace();
      }
    } catch (IOException e) {
      e.printStackTrace();
    }
    return res;
  }

  private byte[] getFileInS3(String bucket, String filename){
    byte[] res = null;

    // bucket名から"s3://"を取り除く
    // "s3://"を付与している事でS3からS3Objectの取得が出来ない為
    bucket = bucket.replace("s3://", "");

    try (
      ResponseInputStream<GetObjectResponse> is = s3.getObject(GetObjectRequest.builder()
        .bucket(bucket)
        .key(filename)
        .build());
      ByteArrayOutputStream os = new ByteArrayOutputStream();
    ) {
      byte[] buffer = new byte[1024];
      while (true) {
        int len = is.read(buffer);
        if (len < 0) {
          break;
        }
        os.write(buffer, 0, len);
      }
      byte[] content = os.toByteArray();
      return content;
    } catch (IOException e) {
      e.printStackTrace();
    }
    return res;
  }
}
