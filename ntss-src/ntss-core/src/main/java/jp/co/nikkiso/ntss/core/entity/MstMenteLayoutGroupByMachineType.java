package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class MstMenteLayoutGroupByMachineType extends BaseBlankEntity {

  /**
   * 点検レイアウトグループコード
    */
  private String mainteLayoutGroupCd;

  /**
   * 点検レイアウトグループ名
   */

  private String groupName;

  /**
   * マシンタイプリスト
   */
  private String typeInfo;
}
