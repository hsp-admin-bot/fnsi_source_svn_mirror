package jp.co.nikkiso.ntss.admin_web.request.exam;

import lombok.Data;

import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.core.entity.custom.PatExamPatternData;

/**
 * 検査依頼保存APIのRequestクラス.
 */
@Data
public class SaveExamRequest {

  /**
   * 検査依頼リスト.
   */
  private List<Map<String, String>> patExamMainList;

  /**
   * 検査パターンリスト.
   */
  private List<PatExamPatternData> patExamPatternList;

  /**
   * 患者情報スケジュール延長最終日更新リスト.
   */
  private List<Map<String, String>> patExtInfoList;

// add by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --start
  /**
   * 検査依頼ジャーナルリスト.
   */
  private List<Map<String, String>> requestJournalList;
// add by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --end
}
