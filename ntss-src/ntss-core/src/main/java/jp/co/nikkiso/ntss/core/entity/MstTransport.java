package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.MstTransportEntityListener;
import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;
/**
 * 搬送区分クラス
 */
@Entity(listener = MstTransportEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_transport")
@Getter
@Setter
public class MstTransport extends BaseBlankEntity {
  /**
   * 搬送区分コード
   */
  @Id
  private Integer transportCd;

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * FNW+で管理する施設内の一意な搬送区分コード
   */
  private String fnTransportCd;

  /**
   * 搬送区分名
   */
  private String transportName;

  /**
   * 連携コード1
   */
  // 変数にアンスコ付けたくないからカラム名"in_hospital_cd1"にしたい、、、
  private String inHospitalCd_1;

  /**
   * 表示フラグ
   */
  private String isDisp;

  /**
   * 削除フラグ
   */
  private String isDel;

  /**
   * 登録日時
   */
  private Timestamp regDate;

  /**
   * 更新日時
   */
  private Timestamp upDate;
}
