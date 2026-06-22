package jp.co.nikkiso.ntss.core.entity.custom;

import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 装置マスタクラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class MstBioMoniFramePatternWithDefine {
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * 管理番号
   */
  private Integer ctlNo;
  /**
   * テンプレート名
   */
  private String templateName;
  /**
   * フレーム種別 0：一覧、1：詳細
   */
  private short frameType;
  /**
   * フレーム番号
   */
  private short frameNo;
  /**
   * 定義情報
   */
  private String defineInfo;
  /**
   * フレーム定義情報
   */
  private String frameDefine;

  /**
   * 登録日時
   */
  private Timestamp regDate;
  /**
   * 更新日時
   */
  private Timestamp upDate;
}
