package jp.co.nikkiso.ntss.admin_web.service.file;

import org.springframework.web.multipart.MultipartFile;

/**
 * 帳票・ＤＥ管理など用のファイルアップロード処理
 *
 */
public interface FileControlService {
  /**
   * ファイルをＳ３にアップロード
   * @param file ファイル情報
   * @param filePath ファイルパス
   * @return
   */
  boolean fileUpload2S3(MultipartFile file, String facilityCd);
}
