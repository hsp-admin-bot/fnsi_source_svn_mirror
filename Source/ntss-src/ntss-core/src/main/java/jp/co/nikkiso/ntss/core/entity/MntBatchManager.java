package jp.co.nikkiso.ntss.core.entity;

import java.sql.Timestamp;

import jp.co.nikkiso.ntss.core.entity.entityListener.CommonEntityListener;
import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;
import org.seasar.doma.Id;

import lombok.Getter;
import lombok.Setter;

/**
 * バッチ稼働状況管理クラス.
 */
@Entity(listener = CommonEntityListener.class, naming=NamingType.SNAKE_LOWER_CASE)
@Table(name = "mnt_batch_manager")
@Getter
@Setter
public class MntBatchManager extends BaseBlankEntity {

  /**
   * 管理番号.
   */
  @Id
  private Integer ctlNo;

  /**
   * バッチ処理名称.
   */
  private String batchName;

  /**
   * 処理区分.
   */
  private String division;

  /**
   * 処理ステータス.
   */
  private String status;

  /**
   * 説明.
   */
  private String description;

  /**
   * 開始時刻.
   */
  private Timestamp startTime;

  /**
   * 終了時刻.
   */
  private Timestamp endTime;

}
