package jp.co.nikkiso.ntss.admin_web.response.masterMaintenance;

import lombok.AllArgsConstructor;

/**
 * マスタ編集用データのResponse.Schema部
 */
@AllArgsConstructor
public class MasterSchema {

  /**
   * マスタデータのリスト.
   */
  public MasterModel model;

  /**
   * コンストラクタ.
   */
  public MasterSchema() {
    this.model = new MasterModel();
  }

}
