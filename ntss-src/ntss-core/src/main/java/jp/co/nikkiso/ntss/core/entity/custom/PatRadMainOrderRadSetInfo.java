package jp.co.nikkiso.ntss.core.entity.custom;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * pat_rad_main.order_rad_set_info(患者検査結果.検査依頼セット情報)内の1要素のエンティティクラス
 */
@Getter
@Setter
@NoArgsConstructor
public class PatRadMainOrderRadSetInfo {
  /** ObjectMapper */
  private static ObjectMapper objectMapper = new ObjectMapper();

  /**
   * 登録番号
   */
  private Integer no;

  /**
   * 検査セットコード
   */
  private Long rad_set_cd;

  /**
   * 検査セット名称
   */
  private String rad_set_name;

  /**
   * 基本型の値を返す.
   * 
   * @return 基本型の値
   */
  @JsonIgnore
  public String getValue() {
    try {
      return objectMapper.writeValueAsString(this);
    } catch (JsonProcessingException e) {
      return null;
    }
  }

}
