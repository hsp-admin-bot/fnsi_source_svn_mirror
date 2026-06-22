package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "sys_coop_no")
@Getter
@Setter
public class SysCoopNo extends BaseEntity {
  /** 管理番号 */
  @Id
  private Long ctlNo;
  /** 施設コード */
  private String facilityCd;
  /** 連携オーダ種別 */
  private String coopOrdCd;
  /** 現在の連携オーダ番号シーケンス */
  private Long curCoopOrdNo;
  /** 連携オーダ番号_桁数 */
  private Long noOfDigit;
  /** 連携オーダ番号_パディング文字 */
  private String paddingChar;
  /** 連携オーダ番号_パディング位置 */
  private String paddingPos;
  /** 連携オーダ番号_最大値 */
  private Long rangeMax;
  /** 連携オーダ番号_最小値 */
  private Long rangeMin;
  /** 連携オーダ番号_前置文字 */
  private String prefixChar;
  /** 連携オーダ番号_後置文字 */
  private String suffixChar;
  /** 表示フラグ */
  private String isDisp;
  /** 削除フラグ */
  private String isDel;
  /** 操作者ID */
  private Long userId;
  /** 連携種別 */
  private String coopCd;
  /** 付帯情報（電文） */
  private String coopCdIndex;
// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  /** 連携版番号 */
  private String coopVersion;
// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
}
