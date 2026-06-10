package jp.co.nikkiso.ntss.admin_web.response;

import java.util.Collections;
import java.util.List;

import jp.co.nikkiso.ntss.core.entity.custom.DeviceEdge;
import lombok.AllArgsConstructor;

/**
 * デバイスエッジ稼働監視のResponse.
 */
@AllArgsConstructor
public class DeviceEdgesResponse {
  
  /**
   * 部署符号の重複なしリスト.
   */
  public List<String> departmentCds;
  
  /**
   * 都道府県の重複なしリスト.
   */
  public List<List<String>> prefectures;
  
  /**
   * デバイスエッジ情報のリスト.
   */
  public List<DeviceEdge> deviceEdges;
  
  /**
   * 空のデバイスエッジ情報を返却するコンストラクタ.
   * 検索結果0件時のレスポンスに使用
   */
  public DeviceEdgesResponse() {
    this.departmentCds = Collections.emptyList();
    this.prefectures = Collections.emptyList();
    this.deviceEdges = Collections.emptyList();
  }

}
