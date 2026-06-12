package jp.co.nikkiso.ntss.core.entity.custom;

import com.fasterxml.jackson.annotation.JsonIgnore;
import tools.jackson.core.JacksonException;
import tools.jackson.databind.ObjectMapper;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * pat_exam_main.exam_result_info(患者検査結果.検査結果情報)内の1要素のエンティティクラス
 */
//@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
@NoArgsConstructor
public class PatExamMainExamResultInfo {
  /** ObjectMapper */
  private static ObjectMapper objectMapper = new ObjectMapper();

  /**
   * 項目コード
   */
  private String item_cd;

  /**
   * 検査結果
   */
  private String result;

  /**
   * 検査値形態
   */
  private String hl;

  /**
   * 結果コメント
   */
  private String com_cd;

  /**
   * フリーコメント
   */
  private String freememo;

  /**
   * 検査結果日時
   */
  private String result_date;

  /**
   * 検査時検査項目名
   */
  private String item_name;

  /**
   * 検査時データ形式
   */
//add 古いデータの互換性 張 start
// mod FNSI-NO504-冗長なjsonデータを削除する 関 start
  private String type;
// mod FNSI-NO504-冗長なjsonデータを削除する 関 start
//add 古いデータの互換性 張 end

  /**
   * 検査時単位
   */
  private String unit;

  /**
   * 検査時正常値上限
   */
//add 古いデータの互換性 張 start
// mod FNSI-NO504-冗長なjsonデータを削除する 関 start
  private String upper;
// mod FNSI-NO504-冗長なjsonデータを削除する 関 end
//add 古いデータの互換性 張 end

  /**
   * 検査時正常値下限
   */
//add 古いデータの互換性 張 start
// mod FNSI-NO504-冗長なjsonデータを削除する 関 start
  private String lower;
// mod FNSI-NO504-冗長なjsonデータを削除する 関 end
//add 古いデータの互換性 張 end

  /**
   * 検査使用区分
   */
  private String exam_class;
  /**
   * JLAC10コード
   */
  // mod FNSI-NO504-冗長なjsonデータを削除する 関 start
  // mod 7391 exam_rst連携で受信した検査項目コード  吉 start
  // private String jlac10_cd;
   private String jlac10_cd;
  // mod 7391 exam_rst連携で受信した検査項目コード  吉 end
  // mod FNSI-NO504-冗長なjsonデータを削除する 関 end
//add 古いデータの互換性 張 start
   // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
   //private String disp_order;
   private Integer disp_order;
   // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
//add 古いデータの互換性 張 end
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
