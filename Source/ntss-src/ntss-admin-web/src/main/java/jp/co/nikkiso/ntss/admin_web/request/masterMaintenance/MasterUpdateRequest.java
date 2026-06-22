package jp.co.nikkiso.ntss.admin_web.request.masterMaintenance;

import lombok.Data;

import java.util.List;
import java.util.Map;

/**
 * マスタデータ更新APIのRequestクラス.
 */
@Data
public class MasterUpdateRequest {

  /**
   * 更新対象データ(カラム名と値のMapのリスト)
   */
  private List<Map<String, Object>> data;

}
