package jp.co.nikkiso.ntss.admin_web.request.searchInfo;

import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.DetailedSearchRequest;
import lombok.Data;

/**
 * 患者情報リスト取得条件格納用APIのRequestクラス.
 */
@Data
public class PatInfoRequest {
  /**
   * 抽出データ（処理対象施設の施設コードリスト）
   */
  private List<String> facilityCdList;

  /**
   * 抽出データ（処理対象患者の患者IDリスト）
   */
  private List<Long> patIdList;
  /**
   *
   */
  private List<Map<String, Object>> sortConditions;

  /**
   *
   */
  private String treatDate;

  /**
   *
   */
  private String facilityCd;

  /**
   *
   */
  private List<Map<String, Object>> tmpPatList;
  // add 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 start
  private DetailedSearchRequest detailedCondtion;
  // add 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 end
}
