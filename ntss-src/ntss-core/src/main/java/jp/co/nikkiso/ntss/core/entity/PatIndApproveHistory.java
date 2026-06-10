package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Column;
import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * 指示受け・承認詳細のEntity
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "pat_ind_approve_history")
@Getter
@Setter
public class PatIndApproveHistory extends BaseEntity{

  /**
   * 指示受け承認履歴番号
   */
  @Column(name = "ind_approve_history_no")
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  protected Long indApproveHistoryNo;

  /**
   * オーダ番号
   */
  @Column(name = "ord_no")
  protected Long ordNo;

  /**
   * 指示受け承認区分
   */
  @Column(name = "approve_kind")
  protected String approveKind;

  /**
   * 変更前指示受け承認者
   */
  @Column(name = "approve_bef_id")
  protected Long approveBefId;

  /**
   * 変更後指示受け承認者
   */
  @Column(name = "approve_aft_id")
  protected Long approveAftId;

  /**
   * 操作者
   */
  @Column(name = "user_id")
  protected Long userId;

 /**
  * 登録区分
  */
  @Column(name = "sign_type")
  protected String signType;

  /**
   * 表示フラグ
   */
  @Column(name = "is_disp")
  protected String isDisp;

  /**
   * 削除フラグ
   */
  @Column(name = "is_del")
  protected String isDel;

  /**
   * 施設コード
   */
  @Column(name = "facility_cd")
  protected String facilityCd;
}
