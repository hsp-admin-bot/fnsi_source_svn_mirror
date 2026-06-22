package jp.co.nikkiso.ntss.device_edge.service;

import jp.co.nikkiso.ntss.device_edge.response.comsvReloadNextPat.ComsvReloadNextPatResponse;

import java.io.IOException;
import java.net.URISyntaxException;

public interface ComsvReloadNextPatService {
  /**
   * 一括次患者更新
   * @param facility_cd 施設コード
   * @param deviceEdgeNo デバイスエッジ番号
   * @return
   */
  int reloadNextPat(String facility_cd, Integer deviceEdgeNo);

  // add 10964 ????患者が作成された際にチェックリストマスタのデータが取得できていない。 関  start
  ComsvReloadNextPatResponse reloadNoNextPat(String facilityCd, String machineTypeCd, String machineSerial) throws IOException, URISyntaxException;
  // add 10964 ????患者が作成された際にチェックリストマスタのデータが取得できていない。 関  end
}
