package jp.co.nikkiso.ntss.admin_web.response.mstSynchro;

import java.util.Collections;
import java.util.List;

import lombok.AllArgsConstructor;

/**
 * デバイスエッジマスタ情報のResponse.
 */
@AllArgsConstructor
public class MstDeviceEdgeResponse {
  
  /**
   * デバイスエッジ情報のリスト.
   */
  public List<MstDeviceEdge> deviceEdgeList;
  
  /**
   * 空のデバイスエッジ情報を返却するコンストラクタ.
   * 検索結果0件時のレスポンスに使用.
   */
  public MstDeviceEdgeResponse() {
    this.deviceEdgeList = Collections.emptyList();
  }
}
