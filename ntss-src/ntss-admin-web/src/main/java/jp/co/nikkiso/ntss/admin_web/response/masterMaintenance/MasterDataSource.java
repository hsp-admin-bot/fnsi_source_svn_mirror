package jp.co.nikkiso.ntss.admin_web.response.masterMaintenance;

import java.util.Collections;
import java.util.List;
import java.util.Map;

import lombok.AllArgsConstructor;

/**
 * マスタ編集用データのResponse.DataSource部
 */
@AllArgsConstructor
public class MasterDataSource {

  /**
   * スキーマ情報.
   */
  public MasterSchema schema;

  /**
   * マスタデータのリスト.
   */
  public List<Map<String, Object>> data;

  /**
   * コンストラクタ.
   */
  public MasterDataSource() {
    this.schema = new MasterSchema();
    this.data = Collections.emptyList();
  }

}
