package jp.co.nikkiso.ntss.admin_web.response.facilities;

import java.util.Collections;
import java.util.List;

import lombok.AllArgsConstructor;

/**
 *　稼働ビューア施設一覧のResponse.
 */
@AllArgsConstructor
public class FacilitiesResponse {
  
  /**
   * 部署符号の重複なしリスト.
   */
  public List<String> departmentCds;
  
  /**
   * 都道府県名の重複なしリスト.
   */
  public List<List<String>> prefectures;
  
  /**
   * 施設情報のリスト.
   */
  public List<Facility> facilities;
  
  /**
   * 空の施設情報を返却するコンストラクタ.
   * 検索結果0件時のレスポンスに使用
   */
  public FacilitiesResponse() {
    this.departmentCds = Collections.emptyList();
    this.prefectures = Collections.emptyList();
    this.facilities = Collections.emptyList();
  }

}
