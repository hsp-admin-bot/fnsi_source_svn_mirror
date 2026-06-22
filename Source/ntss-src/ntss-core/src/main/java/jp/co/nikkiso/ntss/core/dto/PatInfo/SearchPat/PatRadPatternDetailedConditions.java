package jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat;


import lombok.Data;

import java.util.List;

/**
 *add No338患者詳細検索の追加項目 一般撮影検査予定検索 劉全航 start
 */
@Data
public class PatRadPatternDetailedConditions {

  private List<Integer> radPattern_exam_week;

  private Integer radPattern_exam_pattern;
  //mod   吉 start
//  private Timestamp radPattern_exam_pattern_start_date;
//
//  private Timestamp radPattern_exam_pattern_end_date;
  private String radPattern_exam_pattern_start_date;

  private String radPattern_exam_pattern_end_date;
  //mod   吉 end
  private String patRadPatternRegRadDate;

  private boolean conditionIsEmpty;
}
/**
 *add No338患者詳細検索の追加項目 一般撮影検査予定検索 劉全航 end
 */
