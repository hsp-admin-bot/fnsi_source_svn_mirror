package jp.co.nikkiso.ntss.api.service.utils;

import java.nio.file.Path;

/**
 * 一時ファイル作成サービスのインタフェース.
 */
public interface TmpFileService {

  /**
   * 一時ファイルを作成する.
   *
   * @param dir 一時ファイルディレクトリPath
   * @param prefix プレフィックス
   * @param suffix サフィックス
   * @return Path 一時ファイルのPath
   */
  Path createTmpDirectoryAndFile(String dir, String prefix, String suffix) throws Exception;
}
