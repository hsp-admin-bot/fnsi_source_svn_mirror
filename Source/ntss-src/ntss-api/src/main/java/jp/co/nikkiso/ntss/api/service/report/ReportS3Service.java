package jp.co.nikkiso.ntss.api.service.report;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.file.Path;
import java.sql.Timestamp;

/**
 * S3から帳票を構成するファイルを取得するServiceインタフェース.
 */
public interface ReportS3Service {

  /**
   * 帳票ファイル内容の取得.
   *
   * @param bucket   バケット名
   * @param filePath 帳票ファイルパス
   * @param upDate 帳票ファイル更新日時
   * @return 帳票ファイル内容
   */
  byte[] getReportFile(String bucket, String filePath, Timestamp upDate);
  // add 6589 治癒経過表：プレビューでシステムエラー 吉 start
  Boolean getReportFileIsExist(String bucket, String filePath, Timestamp upDate);
  // add 6589 治癒経過表：プレビューでシステムエラー 吉 end
  /**
   * ファイルを保存する.
   *
   * @param bucket バケット名
   * @param destFilePath 保存先ファイルパス
   * @param srcFilePath 保存元ファイルパス
   * @throws IOException
   * @throws FileNotFoundException
   */
  void putFile(String bucket, String destFilePath, Path srcFilePath) throws FileNotFoundException, IOException;

  /**
   * 帳票出力に使用する画像ファイル等を取得.
   *
   * @param bucket   バケット名
   * @param filePath 帳票ファイルパス
   * @return 取得ファイルデータ
   */
  byte[] getOutputFileData(String bucket, String filePath);

}
