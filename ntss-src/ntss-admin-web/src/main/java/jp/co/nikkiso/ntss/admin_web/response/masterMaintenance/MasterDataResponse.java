package jp.co.nikkiso.ntss.admin_web.response.masterMaintenance;

import java.util.Collections;
import java.util.List;

import lombok.AllArgsConstructor;

/**
 * マスタ編集用データのResponse.
 */
@AllArgsConstructor
public class MasterDataResponse {

  /**
   * カラム情報.
   */
  public List<MasterColumn> columns;

  /**
   * データソース部.
   */
  public MasterDataSource localDataSource;

  /**
   * コンストラクタ.
   */
  public MasterDataResponse() {
    this.columns = Collections.emptyList();
    this.localDataSource = new MasterDataSource();
  }

}
