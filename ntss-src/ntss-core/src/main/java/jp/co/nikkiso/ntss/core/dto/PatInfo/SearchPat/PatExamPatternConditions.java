package jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat;

import lombok.Data;

import java.util.List;

@Data
public class PatExamPatternConditions {
  private Integer exam_pattern;
  private List<Integer> exam_week;
  private String reg_order_class;
  private String exam_pattern_start_date;
  private String exam_pattern_end_date;
  // add FutreNetWeb+SI課題管理No4770対応 趙 start
  private List<String> exam_set_cd;;
  // add FutreNetWeb+SI課題管理No4770対応 趙 end
}
