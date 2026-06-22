package jp.co.nikkiso.ntss.core.entity.custom;

import jp.co.nikkiso.ntss.core.entity.entityListener.CommonEntityListener;
import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.BaseEntity;
import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;

/**
 * pat_rad_main(患者放射線検査結果)のエンティティクラス
 */
@Entity(listener = CommonEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "pat_rad_main")
@Getter
@Setter
public class PatRadMainData extends BaseEntity {

  /**
   * システムで管理する一意な放射線検査結果ID.
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
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
   * 登録時検査日時(集計用文字列).
   */
  private String strRadDate;

  /**
   * 登録時検査時刻(集計用文字列).
   */
  private String strRadTime;

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
   * 検査依頼コード
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
  //add FNSI-No338,339患者詳細検索の追加項目 NO.29~32 劉全航 start
  private Integer radWeek;

  private Integer radPattern;

  private Timestamp radFrom;

  private Timestamp radTo;
  //add FNSI-No338,339患者詳細検索の追加項目 NO.29~32 劉全航 end
}
