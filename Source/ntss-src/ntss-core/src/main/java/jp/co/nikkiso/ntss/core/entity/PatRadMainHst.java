/**
 * add FNSI-「幹対応残課題一覧.xlsx」№10対応 田
 */
package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.entityListener.CommonEntityListener;
import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import java.sql.Timestamp;

/**
 * pat_rad_main(患者放射線検査結果)のエンティティクラス
 */
@Entity(listener = CommonEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "pat_rad_main_hst")
@Getter
@Setter
public class PatRadMainHst extends BaseEntity {

  /**
   * システムで管理する一意な放射線検査結果ID.
   */
  private Long radResultCd;

  /**
   * システムで管理する一意な検査結果ID.
   */
  private Long patId;

  /**
   * 施設コード.
   */
  private String facilityCd;

  /**
   * FNW+で管理する施設内の一意な患者ID.
   */
  private String fnPatId;

  /**
   * 登録時検査日時.
   */
  private Timestamp regRadDate;

  /**
   * 登録時検査区分.
   */
  private String regOrderClass;

  /**
   * 状況区分.
   * 0 : 依頼、1 : 結果あり
   */
  private String radStatus;

  /**
   * 放射線検査依頼セット情報
   */
  private String orderRadSetInfo;

  /**
   * 連携オーダ番号1.
   */
  private Long copOrderNo1;

  /**
   * 連携オーダ番号2.
   */
  private Long copOrderNo2;

  /**
   * 依頼変更可否フラグ
   * 0 : 変更可、1 : 変更不可
   */
  private String isLock;

  /**
   * 指示者.
   */
  private Long indUserId;

  /**
   * 削除フラグ.
   * 0 : 通常、1 : 削除
   */
  private String isDel;

  /**
   * 登録スタッフ.
   */
  private Long regStaff;

  /**
   * 最終更新スタッフ.
   */
  private Long upStaff;

}
