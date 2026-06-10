package jp.co.nikkiso.ntss.admin_web.response.masterMaintenance;

import java.util.HashMap;
import java.util.Map;

import lombok.AllArgsConstructor;

/**
 * マスタ編集用データのResponse.Model部
 */
@AllArgsConstructor
public class MasterModel {

  /**
   * Idカラム.
   */
  public String id;

  /**
   * フィールド一覧のリスト. フィールドには、String/Boolean/JSON等が設定されるため、Objectで定義
   */
  public Map<String, Object> fields;

  /**
   * コンストラクタ.
   */
  public MasterModel() {
    this.id = "";
    this.fields = new HashMap<String, Object>();
  }
}
