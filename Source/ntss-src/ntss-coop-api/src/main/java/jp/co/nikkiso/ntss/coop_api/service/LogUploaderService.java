package jp.co.nikkiso.ntss.coop_api.service;

import org.springframework.web.multipart.MultipartFile;

public interface LogUploaderService {


  /**
   * ログファイルアップロード
   * @param mode 処理モード[0:通常/1:分割先頭/2:分割途中/3:分割最後]
   * @param logType ログ種類
   * @param facilityCd 施設コード
   * @param appName アプリケーション名
   * @parama fileName 保存するファイル名
   * @param upFile アップロードするログファイル
   * @throws Exception
   */
  void logFileUpload(int mode, String logType, String facilityCd, String appName, String fileName, MultipartFile upFile) throws Exception;
}
