package jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat;

import lombok.Data;

/**
 * pat_personal_main検索条件
 */
@Data
public class PatPersonalMainSimpleConditions {
  // フリーワード
  private String freeWord;
}