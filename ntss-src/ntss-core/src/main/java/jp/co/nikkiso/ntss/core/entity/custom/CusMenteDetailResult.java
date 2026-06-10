package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * 日常・定期点検履歴
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE, immutable = true)
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
public class CusMenteDetailResult {
  /**
   * 日常点検結果コード
   */
  private Long detail_cd;
  /**
   * 版数
   */
  private Integer edition;
  /**
   * 検査結果
   */
  private String judge;
  /**
   * 検査官
   */
  private Long user_id;
  /**
   * 定期点検詳細コメント
   */
  private String comment;
  /**
   * インデックス
   */
  private Integer tableIndex;
  /**
   * 検査日
   */
  private String date;
  /**
   * mst_mainte_category.mainte_category_cd
   */
  private Long cate_cd;
  /**
   * mst_mainte_category.edition_no
   */
  private Integer cate_edi;
  /**
   * 補足コメント
   */
  private String sub_cmt;
  /**
   * mst_mainte_detail.edition
   */
  private Integer detail_edi;

}
