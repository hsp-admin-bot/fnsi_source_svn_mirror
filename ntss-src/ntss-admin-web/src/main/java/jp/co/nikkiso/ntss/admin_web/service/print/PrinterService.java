package jp.co.nikkiso.ntss.admin_web.service.print;

import jp.co.nikkiso.ntss.admin_web.response.creatingReport.PrinterInfo;
import jp.co.nikkiso.ntss.core.entity.custom.MstPrinter;
import org.springframework.http.ResponseEntity;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

public interface PrinterService {

  /**
   * プリンターマスタを取得する.
   * @param facilityCd 施設コード
   * @return プリンター情報
   */
  List<PrinterInfo> getPrinterInfos(String facilityCd);

  /**
   * 印刷要求を送信する.
   * @param printerCd プリンターコード
   * @param filename S3上の印刷対象PDFファイル名
   */
  void sendPrintRequest(Long printerCd, String filename);

  //add #9616 帳票印刷失敗通知がされない 李 start
  /**
   * 印刷要求を送信する.
   * @param printerCd プリンターコード
   * @param filename S3上の印刷対象PDFファイル名
   */
  void sendPrintRequest(Long printerCd, String filename, String reportType, String reportName);

  /**
   * 帳票印刷失敗通知
   * @param reportType 帳票種別
   * @param reportName 帳票区分
   * @param facilityCd 施設コード
   */
  void saveNotiMessage(String reportType, String reportName, String facilityCd);
  //add #9616 帳票印刷失敗通知がされない 李 end

  /**
   * 指定された印刷サーバーアプリにプリンターを追加する
   * @param facilityCd 施設コード
   * @param clientKey クライアント識別子
   * @param request 追加するプリンターマスタデータ
   */
  void insert(String facilityCd, String clientKey, MstPrinter[] request);

  // add 2020-09-23 FNSI-仕様追加 印刷アプリを複数登録する 夏 start
  /**
   * 指定された印刷サーバーアプリにプリンターを削除する
   * @param facilityCd 施設コード
   * @param clientKey クライアント識別子
   * @param request 追加するプリンターマスタデータ
   */
  void delete(String facilityCd, String clientKey, MstPrinter[] request);
  // add 2020-09-23 FNSI-仕様追加 印刷アプリを複数登録する 夏 end
  /*add FNSI-改修内容転入時の紹介状取込ができない 任 start*/
  String uploadHtml(MultipartFile file, String patEvent) throws Exception;
  /*add FNSI-改修内容転入時の紹介状取込ができない 任 end*/
  //add オンプレミスの場合、転入患者さんの紹介状が取込できない 吉 start
  Map<String, String> getLocalStoreAndStatus()  throws Exception;
  //add オンプレミスの場合、転入患者さんの紹介状が取込できない 吉 end

  /**
   * キャッシュファイルPathの取得.
   * 該当のキャッシュファイルが存在しない場合は空の文字列を応答する
   *
   * @param s3Bucket S3バケット
   * @param filePath ファイルパス
   * @return キャッシュファイル名
   */
  String getCacheFilePath(String s3Bucket, String filePath);

  /* add by lvzongheng  2023-02-01 [Transaction,CodeOptimization]  start */
  ResponseEntity putClientKey(String clientKey,List<String> request);
  /* add by lvzongheng  2023-02-01 [Transaction,CodeOptimization]  end */
}
