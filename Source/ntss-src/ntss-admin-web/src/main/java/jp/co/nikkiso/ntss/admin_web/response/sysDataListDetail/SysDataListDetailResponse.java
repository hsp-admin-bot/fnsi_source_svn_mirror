package jp.co.nikkiso.ntss.admin_web.response.sysDataListDetail;

import java.util.List;
import java.util.Map;

import lombok.Data;
 /**
   * データリストカテゴリ詳細レスポンス
   */
@Data
public class SysDataListDetailResponse {
  /**
   * データリスト詳細コード
   */
  private Long dataListDetailCd;

  /**
   * 表示順
   */
  private Integer dispOrder;

  /**
   * カテゴリコード
   */
  private Long categoryCd;

  /**
   * 表示パターン
   */
  private String displayName;

  /**
   * 項目リスト
   */
  private List<Map<String, Object>> items;

   // add #11528 【たくしん会】データリスト並び順不正 房 start
   /**
    * マスタ並び順
    */
   private List<Integer> itemCds;
   // add #11528 【たくしん会】データリスト並び順不正 房 end
}
