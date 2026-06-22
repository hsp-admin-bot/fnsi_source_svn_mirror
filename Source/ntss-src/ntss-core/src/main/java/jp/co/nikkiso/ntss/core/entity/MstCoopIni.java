package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * 連携設定マスタEntity
 *
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_coop_ini")
@Getter
@Setter
public class MstCoopIni extends BaseEntity {
  /** 連携設定番号 */
  @Id
  private Long coopIniCd;
  /** 施設コード */
  private String facilityCd;
  /** 連携設定メモ */
  private String coopIniMemo;
  /** 連携設定情報 */
  private String coopIniInfo;
  /** 表示フラグ */
  private String isDisp;
  /** 削除フラグ */
  private String isDel;
  // add 2021-09-16 #5897:CSI連携ができないの対応 孫 start
  /** KEYマッピング */
  private String keyMapping;
  // add 2021-09-16 #5897:CSI連携ができないの対応 孫 end
}
