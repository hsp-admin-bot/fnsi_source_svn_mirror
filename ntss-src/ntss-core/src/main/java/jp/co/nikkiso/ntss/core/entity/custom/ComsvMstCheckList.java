package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 通信サーバ用チェックリストマスタクラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class ComsvMstCheckList {

  /**
   * リストコード
   */
  private int listCd;

  /**
   * リスト名
   */
  private String listName;

  /**
   * 透析工程コード
   */
  private int listProg;

}