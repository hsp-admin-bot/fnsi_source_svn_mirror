package jp.co.nikkiso.ntss.admin_web.request.rad;

import lombok.Data;

import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.core.entity.custom.PatRadPatternData;

/**
 * 検査依頼保存APIのRequestクラス.
 */
@Data
public class SaveRadRequest {

  /**
   * 検査依頼リスト.
   */
  private List<Map<String, String>> patRadMainList;

  /**
   * 検査パターンリスト.
   */
  private List<PatRadPatternData> patRadPatternList;

  /**
   * 患者情報スケジュール延長最終日更新リスト.
   */
  private List<Map<String, String>> patExtInfoList;
  // add by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --start
  /**
   * 一般撮影検査依頼一覧画面 or 一般撮影検査依頼画面.
   */
  private String isRadDetail;
// add by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --end

}
