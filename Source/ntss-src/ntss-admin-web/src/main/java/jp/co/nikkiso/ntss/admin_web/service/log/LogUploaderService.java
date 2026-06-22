package jp.co.nikkiso.ntss.admin_web.service.log;

import org.springframework.web.multipart.MultipartFile;

public interface LogUploaderService {


  /**
   * ログファイルアップロード
   * @param mode 処理モード[0:通常/1:分割先頭/2:分割途中/3:分割最後]
   * @param facilityCd 施設コード
   * @param appName アプリケーション名
   * @parama fileName 保存するファイル名
   * @param upFile アップロードするログファイル
   * @throws Exception
   */
  void logFileUpload(int mode, String facilityCd, String appName, String fileName, MultipartFile upFile) throws Exception;
}
