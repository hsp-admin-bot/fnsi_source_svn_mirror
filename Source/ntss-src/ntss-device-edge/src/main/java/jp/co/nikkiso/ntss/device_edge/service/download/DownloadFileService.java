package jp.co.nikkiso.ntss.device_edge.service.download;

import java.util.Map;

public interface DownloadFileService {

  /**
   * オンプレミスSettings
   * @return
   */
  Map<String, String> getSystemDefineOfPremise();
}
