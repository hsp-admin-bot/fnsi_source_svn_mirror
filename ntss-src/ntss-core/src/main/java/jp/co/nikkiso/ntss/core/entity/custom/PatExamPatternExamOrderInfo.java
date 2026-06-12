package jp.co.nikkiso.ntss.core.entity.custom;

import com.fasterxml.jackson.annotation.JsonIgnore;
import tools.jackson.core.JacksonException;
import tools.jackson.databind.ObjectMapper;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * pat_exam_pattern.exam_order_info(患者検査パターン.検査依頼情報)内の1要素のエンティティクラス
 */
@Getter
@Setter
@NoArgsConstructor
public class PatExamPatternExamOrderInfo {
  /** ObjectMapper */
  private static ObjectMapper objectMapper = new ObjectMapper();

  /**
   * 検査項目コード（検査依頼セットを分解したもの）
   */
  private Long exam_item_cd;

  /**
   * 検査項目名称（検査依頼セットを分解したもの）
   */
  private String exam_item_name;

  /**
   * 基本型の値を返す.
   * 
   * @return 基本型の値
   */
  @JsonIgnore
  public String getValue() {
    try {
      return objectMapper.writeValueAsString(this);
    } catch (JacksonException e) {
      return null;
    }
  }

}
