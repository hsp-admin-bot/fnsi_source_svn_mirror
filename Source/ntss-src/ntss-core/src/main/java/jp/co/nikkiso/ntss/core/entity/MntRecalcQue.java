package jp.co.nikkiso.ntss.core.entity;

import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * mnt_recalc_que検査再計算依頼キューテーブル
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mnt_recalc_que")
@Getter
@Setter
public class MntRecalcQue extends BaseEntity{

  /**
   * 処理順(登録順）
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long recalcQueCd;

  /**
   * 施設コード.
   */
  private String facilityCd;

  /**
   * ステータス.
   */
  private String status;

  /**
   * 完了日時.
   */
  private Timestamp endDate;

  /**
   * 内容.
   */
  private String content;

  /**
   * 進捗.
   */
  private String detail;

  /**
   * 依頼者id.
   */
  private String regId;

  /**
   * 更新者ID.
   */
  private String  upId;

  /**
   * 削除フラグ.
   */
  private String delFlg;

  /**
   * 表示フラグ.
   */
  private String dispFlg;

  /**
   * ログ.
   */
  private String journal;
  
  /**
   * 再計算済患者ID.
   */
  private String calcPatId;
}
