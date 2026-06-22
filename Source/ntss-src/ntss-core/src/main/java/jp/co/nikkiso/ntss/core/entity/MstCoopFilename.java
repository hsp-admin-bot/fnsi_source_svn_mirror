package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * 外部連携ファイル名 Entity
 * ※ファイル名の管理テーブル
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_coop_filename")
@Getter
@Setter
public class MstCoopFilename extends BaseEntity {

   /** 管理番号 */
  @Id
  private Long ctlNo;

  /** 施設コード */
  private String facilityCd;

  /** 電文種別 */
  private String coopCd;

  /** 付帯情報（電文） */
  private String coopCdIndex;

  /** PDFファイル名 */
  private String pdfName;

  /** 電文パス名 */
  private String dumpName;

  /** 圧縮ファイル名 */
  private String compressionName;

  /** 表示フラグ */
  private String isDisp;

  /** 削除フラグ */
  private String isDel;

  /** 操作者ID */
  private Long userId;

// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  /** 連携版番号 */
  private String coopVersion;
// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

}
