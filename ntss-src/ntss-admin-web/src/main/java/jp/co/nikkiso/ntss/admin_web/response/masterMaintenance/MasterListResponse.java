package jp.co.nikkiso.ntss.admin_web.response.masterMaintenance;

import java.util.Collections;
import java.util.List;

import lombok.AllArgsConstructor;

/**
 * マスタ一覧のResponse.
 */
@AllArgsConstructor
public class MasterListResponse {
  
  /**
   * マスタ一覧のリスト.
   */
  public List<MasterInfo> masterList;
  
  /**
   * コンストラクタ.
   */
  public MasterListResponse() {
    this.masterList = Collections.emptyList();
  }
  
}
