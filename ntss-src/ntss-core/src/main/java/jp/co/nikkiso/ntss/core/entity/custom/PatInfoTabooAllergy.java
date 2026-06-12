package jp.co.nikkiso.ntss.core.entity.custom;

import com.fasterxml.jackson.annotation.JsonIgnore;
import tools.jackson.core.JacksonException;
import tools.jackson.databind.ObjectMapper;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class PatInfoTabooAllergy {
  /** ObjectMapper */
  private static ObjectMapper objectMapper = new ObjectMapper();

  // 備考
  private String memo;
  //　管理番号
  private Integer ctl_no;
  // 内容
  private String content;
  // 表示順
  private Integer disp_order;
  // 対象区分　※0:禁忌・アレルギー、1:薬剤、2:調製薬剤、3:医療材料、4:ダイアライザ、5:フリーワード
  private String category_class;
  // 禁忌・アレルギーコード
  // mod FNSI-改修内容6618修正 xuty start
  // private Integer taboo_allergy_cd;
  private String taboo_allergy_cd;
  // mod FNSI-改修内容6618修正 xuty end
  // '1':禁忌、'2':アレルギー
  private String taboo_allergy_class;

  /**
   * 基本型の値を返す.
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
