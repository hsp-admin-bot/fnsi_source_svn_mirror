package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "ord_coop_no")
@Getter
@Setter
public class OrdCoopNo extends BaseEntity {
  /** 管理番号 */
  @Id
  private Long ctlNo;
  /** 施設コード */
  private String facilityCd;
  /** 患者番号 */
  private Long patId;
  /** オーダ番号 */
  private Long ordNo;
  /** 連携種別 */
  private String coopCd;
  /** 付帯情報（電文） */
  private String coopCdIndex;
  /** 連携オーダ番号 */
  private String coopOrdNo;
  /** 表示フラグ */
  private String isDisp;
  /** 削除フラグ */
  private String isDel;
  /** 操作者ID */
  private Long userId;
  // add 2020-12-17 FNSI-改修 外部連携721(前回処理結果による処理変更) 夏 start
  /** ステータス */
  private String status;
  // add 2020-12-17 FNSI-改修 外部連携721(前回処理結果による処理変更) 夏 end
  // add 2021-04-13 連携オーダ番号の患者番号（連携用）を追加 孫 start
  /** 患者番号(連携用) */
  private String hospPatId;
  // add 2021-04-13 連携オーダ番号の患者番号（連携用）を追加 孫 end
// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  /** 連携版番号 */
  private String coopVersion;
// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
}
