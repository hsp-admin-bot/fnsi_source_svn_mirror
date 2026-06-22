package jp.co.nikkiso.ntss.core.entity;

import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.SequenceGenerator;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * 施設解約管理Entity
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mnt_facility_cancel_manage")
@Getter
@Setter
@NoArgsConstructor
public class MntFacilityCancelManage extends BaseEntity {
  /** 管理番号 */
  @Id
  @GeneratedValue(strategy = GenerationType.SEQUENCE)
  @SequenceGenerator(sequence = "mnt_facility_cancel_manage_ctl_no_seq")
  private Long ctlNo;

  /** 施設コード */
  private String facilityCd;

  /** 処理区分 */
  private String procClass;

  /** 処理対象期間 */
  private Integer procPeriod;

  /** 処理開始日 */
  private Timestamp stDate;

  /** 統計情報 */
  private String stats;

  /** 統計情報(NoSQLDB) */
  private String statsNosql;

  /** ステータス */
  private String procStatus;

  /** 表示フラグ */
  private String isDisp;

  /** 削除フラグ */
  private String isDel;
}
