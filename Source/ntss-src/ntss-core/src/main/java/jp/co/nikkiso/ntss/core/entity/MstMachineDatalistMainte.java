package jp.co.nikkiso.ntss.core.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import java.sql.Timestamp;


/**
 * 装置マスタのEntity.
 */
@Entity(naming=NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_machine")
@Getter
@Setter
public class MstMachineDatalistMainte extends BaseBlankEntity {

  /**
   * 型式コード.
   */
  private String machine_type_cd;

  /**
   * 製造番号.
   */
  private String machine_serial;

  /**
   * 装置名.
   */
  private String machine_name;

  /**
   * 装置番号
   */
  private Long machine_no;

  /**
   * 型式
   */
  private String machine_type;

  /**
   * ベッド名
   */
  private String bed_name;

  /**
   * 設置日
   */
  private Timestamp setting_date;

  /**
   * カテゴリー名
   */
  private String category_name;

  /**
   * 点検種別
   */
  private String mainte_type;

  /**
   * 定期/日常
   */
  private String layout_class;

  /**
   * 点検記録簿
   */
  private String detail_info_1;

  /**
   * 交換部品記録簿
   */
  private String detail_info_2;

  /**
   * 項目1（定期・日常共通）
   */
  private String mainte_content_1;

  /**
   * 項目2（定期・日常共通）
   */
  private String mainte_content_2;

  /**
   * 項目3（定期のみ）
   */
  private String mainte_content_3;

  /**
   * 実施者（定期・日常共通）
   */
  private String checker_id_1;

  /**
   * 確認者（定期のみ）
   */
  private String checker_id_2;

  /**
   * 点検結果（定期・日常共通）
   */
  private String judge;

  /**
   * 点検記録番号（定期のみ）
   */
  private String rec_no;

  /**
   * 点検コメント（日常のみ）
   */
  private String comment;

  /**
   * 補足コメント（定期・日常共通）
   */
  private String sub_cmt;

  /**
   * 点検日
   */
  private String mainte_date;

  /**
   * ランク
   */
  private String row_number;

}


