package jp.co.nikkiso.ntss.core.entity.custom;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

/**
 * 連携設定マスタ 連携設定情報
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class MstCoopIniInfo {
  /*key0*/
  private String key0;

  /*key1*/
  private String key1;

  /*key2*/
  private String key2;

  /*値 value*/
  private String val;

  /*コメント comment*/
  private String com;

  /*デフォルト値*/
  private String defaultV;

  /*有効*/
  private String isEffect;

}
