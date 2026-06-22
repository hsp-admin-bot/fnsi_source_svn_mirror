package jp.co.nikkiso.ntss.api.service.onPremise;

import java.io.IOException;
import java.nio.file.Path;
import java.sql.Timestamp;

/**
 * S3から帳票ファイルを取得するServiceインタフェース.
 */
public interface OnPremiseService {

  byte[] getReportFile(String localStore, String filePath, Timestamp upDate);

  void putFile(String localStore, String destFilePath, Path srcFilePath) throws IOException;

  /**
   * Write bytes to File
   * @param filePath
   * @param bytes
   * @throws IOException
   */
  void writeBytesToFile(String filePath, byte[] bytes) throws IOException;
}
