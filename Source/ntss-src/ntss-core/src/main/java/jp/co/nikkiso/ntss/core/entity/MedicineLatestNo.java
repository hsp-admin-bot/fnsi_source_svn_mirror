package jp.co.nikkiso.ntss.core.entity;

import lombok.AllArgsConstructor;
import lombok.Getter;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import java.sql.Timestamp;

/**
 * 投薬最新識別番号Entity
 *
 * @since 20240407
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE, immutable = true)
@Table(name = "medicine_latest_no")
@AllArgsConstructor
@Getter
public class MedicineLatestNo {

  /** 施設コード */
  @Id
  private final String facilityCd;

  /** 患者ID */
  @Id
  private final Long patId;

  /** 投薬識別番号 */
  private final Integer mediInfoNo;

  /** 登録日時 */
  private final Timestamp regDate;
  /** 更新日時 */
  private final Timestamp upDate;
  /** 表示フラグ */
  private final String isDisp;
  /** 削除フラグ */
  private final String isDel;

}
