package jp.co.nikkiso.ntss.core.entity.custom;

import com.fasterxml.jackson.annotation.JsonIgnore;
import tools.jackson.core.JacksonException;
import tools.jackson.databind.ObjectMapper;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * pat_main.infect_info(患者基本情報.感染症情報)内の1要素のエンティティクラス
 */
@Getter
@Setter
@NoArgsConstructor
public class PatMainInfectInfo {
  /** ObjectMapper */
  private static ObjectMapper objectMapper = new ObjectMapper();
  
  /**
   * 管理番号
   */
  private String ctl_no;

  /**
   * 感染症コード
   */
  private Integer infection_cd;

  /**
   * 結果コード
   * 0：不明、1：(-)、2：(+)
   */
  private String infect;

  /**
   * 検査日
   */
  private String exam_date;

  /**
   * 更新日時
   */
  private String up_date;


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
