package jp.co.nikkiso.ntss.core.entity.custom;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class MstTabooAllergyDetailInfo {
  /** ObjectMapper */
  private static ObjectMapper objectMapper = new ObjectMapper();

  // 禁忌対象区分
  private String classCd;
  //　禁忌対象コード
  // mod FNSI-改修内容6618修正 xuty start
  // private Integer cd;
  private String cd;
  // mod FNSI-改修内容6618修正 xuty end
  // 禁忌対象名
  private String name;

  // add 禁忌対象typeの追加に伴う漏れを対応 劉
  // 禁忌対象type
  private Integer type;
  // add 禁忌対象typeの追加に伴う漏れを対応 劉

  // add #9987 コンバートによるアレルギーの調製薬剤の参照側修正 20240320 ztc start
  private String index;
  // add #9987 コンバートによるアレルギーの調製薬剤の参照側修正 20240320 ztc start

  /**
   * 基本型の値を返す.
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
