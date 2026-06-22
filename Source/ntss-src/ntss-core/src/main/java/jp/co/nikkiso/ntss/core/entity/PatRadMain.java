package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.entityListener.CommonEntityListener;
import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.SequenceGenerator;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;
import java.util.Objects;

/**
 * pat_rad_main(患者放射線検査結果)のエンティティクラス
 */
@Entity(listener = CommonEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "pat_rad_main")
@Getter
@Setter
public class PatRadMain extends BaseEntity {

  /**
   * システムで管理する一意な放射線検査結果ID.
   */
  @Id
  //mod #10601 スケジュール表動作不正 start
//  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @GeneratedValue(strategy = GenerationType.SEQUENCE)
  @SequenceGenerator(sequence = "pat_rad_main_rad_result_cd_seq")
  //mod #10601 スケジュール表動作不正 end
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
  //add FNSI-No338,339患者詳細検索の追加項目 NO.29~32 劉全航 start
  private Integer radWeek;

  private Integer radPattern;

  private Timestamp radFrom;

  private Timestamp radTo;
  //add FNSI-No338,339患者詳細検索の追加項目 NO.29~32 劉全航 end

  //add 10553 連携イベント発生部分不正【最優先】zhao start
  @Override
  public boolean equals(Object obj) {
    if (this == obj) return true;
    if (obj == null || getClass() != obj.getClass()) return false;
    PatRadMain patRadMain = (PatRadMain) obj;
    return Objects.equals(radResultCd, patRadMain.radResultCd)&&Objects.equals(isDel, patRadMain.isDel);
  }

  @Override
  public int hashCode() {
    return Objects.hash(radResultCd,isDel);
  }
  //add 10553 連携イベント発生部分不正【最優先】zhao end
}
