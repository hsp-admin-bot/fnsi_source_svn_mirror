package jp.co.nikkiso.ntss.api.service.utils;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;


import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.api.service.LogServiceImpl;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import lombok.extern.slf4j.Slf4j;

/**
 * 帳票Zipファイルクラス.
 */
@Slf4j
public class ReportZipFile {
  private byte[] zipData = null;

  /**
   * コンストラクタ.
   *
   * @param zipData Zipファイルデータ
   */
  public ReportZipFile(byte[] zipData) {
    this.zipData = zipData;
  }

  /**
   * Zipファイルから指定されたファイルを取得する.
   *
   * @param fileName ファイル名
   * @return ファイルデータ(byte配列)
   */
  public byte[] getFile(String fileName) {
    byte[] fileData = null;
    LogServiceImpl logService = new LogServiceImpl();
    try (ZipInputStream inputStream = new ZipInputStream(
      new ByteArrayInputStream(this.zipData))) {

      ZipEntry entry;
      while ((entry = inputStream.getNextEntry()) != null) {
        if (!fileName.equals(entry.getName()) || entry.isDirectory()) {
          continue;
        }

        // 指定されたファイルの内容を取得する
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        byte[] buffer = new byte[1024];
        while (true) {
          int len = inputStream.read(buffer);
          if (len < 0) {
            break;
          }
          outputStream.write(buffer, 0, len);
        }

        inputStream.closeEntry();
        fileData = outputStream.toByteArray();
      }
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("get file from zip failed.");
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      throw new NtssException(e);
    }

    return fileData;
  }

  /**
   * Zipファイルから指定されたファイルを文字列で取得する.
   *
   * @param fileName ファイル名
   * @return ファイルデータ(String)
   */
  public String getFileToString(String fileName) {
    return Optional.ofNullable(this.getFile(fileName))
      .map(e -> new String(e, StandardCharsets.UTF_8))
      .orElse(null);
  }

  // add 2021-04-26 外部連携:log内容を改善 孫 start
  /**
   * ZipファイルのZipしたファイル名Listを取得する.
   *
   * @return ファイル名List(List<String>)
   */
  public List<String> getFileToString() {
    List<String> fileList = new ArrayList<String>();

    try (ZipInputStream inputStream = new ZipInputStream(
      new ByteArrayInputStream(this.zipData))) {

      ZipEntry entry;
      while ((entry = inputStream.getNextEntry()) != null) {
        if (entry.isDirectory()) {
          continue;
        }
        fileList.add(entry.getName());
      }
    } catch (Exception e) {
      fileList.add(e.getMessage());
    }

    return fileList;
  }
  // add 2021-04-26 外部連携:log内容を改善 孫 end
}
