package jp.co.nikkiso.ntss.core.entity;

import java.sql.Timestamp;
import org.seasar.doma.Column;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;
import com.fasterxml.jackson.annotation.JsonProperty;
import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * 指示受け・承認のEntity.
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "pat_ind_approve")
@Getter
@Setter
public class PatIndApprove extends BaseEntity {
  /**
   * ord_mainのオーダ番号
   */
  @Id
  @Column(name = "ord_no")
  protected Long ord_no;

  /**
   * チェック者１のID
   */
  @Column(name = "check_user1_cd")
  protected Long check_user1_cd;

  /**
   * チェック者２のID
   */
  @Column(name = "check_user2_cd")
  protected Long check_user2_cd;

  /**
   * 承認者１のID
   */
  @Column(name = "approve_user1_cd")
  protected Long approve_user1_cd;

  /**
   * 承認者２のID
   */
  @Column(name = "approve_user2_cd")
  protected Long approve_user2_cd;

  /**
   * チェック者１がチェックした日時
   */
  @Column(name = "check_user1_time")
  protected Timestamp check_user1_time;

  /**
   * チェック者２がチェックした日時
   */
  @Column(name = "check_user2_time")
  protected Timestamp check_user2_time;

  /**
   * 承認者１が承認した日時
   */
  @Column(name = "approve_user1_time")
  protected Timestamp approve_user1_time;

  /**
   * 承認者２が承認した日時
   */
  @Column(name = "approve_user2_time")
  protected Timestamp approve_user2_time;

  /**
   * 登録日
   */
  @Column(name = "reg_date")
  protected Timestamp reg_date;

  /**
   * 更新日
   */
  @Column(name = "up_date")
  protected Timestamp up_date;

  /**
   * 指示受け後の変更があるかの判断
   */
  @Column(name = "is_content_changed")
  protected String is_content_changed;


  /**
   * チェック者１がチェックした時点の内容
   */
  @JsonProperty("check_content")
  @Column(name = "check_content")
  protected String check_content;

  /**
   * チェック者１のチェック状態
   */
  @Column(name = "is_user1_checked")
  protected String is_user1_checked;

  /**
   * チェック者２のチェック状態
   */
  @Column(name = "is_user2_checked")
  protected String is_user2_checked;

  /**
   * 承認者１の承認状態
   */
  @Column(name = "is_user1_approved")
  protected String is_user1_approved;

  /**
   * 承認者２の承認状態
   */
  @Column(name = "is_user2_approved")
  protected String is_user2_approved;

  @JsonProperty("approve_content")
  @Column(name = "approve_content")
  protected String approve_content;

  @Column(name = "is_content_appd_changed")
  protected String is_content_appd_changed;

  /**
   * 治療状況マップ指示変更ありフラグ
   */
  @Column(name = "is_content_changed_for_map")
  protected String is_content_changed_for_map;

  /**
   * 治療状況マップ確認時指示内容
   */
  @Column(name = "content_for_map")
  protected String content_for_map;

  /**
   * 施設コード
   */
  @Column(name = "facility_cd")
  protected String facility_cd;
}
