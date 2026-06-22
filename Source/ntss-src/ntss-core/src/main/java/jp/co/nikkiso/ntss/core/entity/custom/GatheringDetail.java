package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Column;
import org.seasar.doma.Entity;
import org.seasar.doma.Transient;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 装置動作記録詳細_データ収集取得用Entity.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class GatheringDetail {

  /**
   * 装置記録メッセージ.
   */
  private String machineRecordMessage;

  /**
   * 対処(実行)者
   */
  @Column(name = "user_id")
  private Long gatheredUserId;

  /**
   * 内容(ファイルダウンロードに必要なデータ).
   */
  @Column(name = "contents")
  private String fileData;

  /**
   * 実施者名
   */
  @Transient
  private String userName;
}
