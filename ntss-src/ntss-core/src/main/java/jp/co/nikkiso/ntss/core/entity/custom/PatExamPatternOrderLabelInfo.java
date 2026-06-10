package jp.co.nikkiso.ntss.core.entity.custom;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * pat_exam_pattern.order_label_info(患者検査パターン.ラベル情報)内の1要素のエンティティクラス
 */
@Getter
@Setter
@NoArgsConstructor
public class PatExamPatternOrderLabelInfo {
  /** ObjectMapper */
  private static ObjectMapper objectMapper = new ObjectMapper();

  /**
   * 採血管コード
   */
  //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 20240410 ztc start
//  private String spitz_cd;
  private Long spitz_cd;
  //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 20240410 ztc end

  // mod FNSI-改修内容#6013 周 start
  /**
   * 枚数
   */
  //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 20240410 ztc start
//  private String label_cnt;
  private Integer label_cnt;
  //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 20240410 ztc end

  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
  //private String disp_order;
  private Integer disp_order;
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
  // mod FNSI-改修内容#6013 周 end

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
