package jp.co.nikkiso.ntss.core.entity;

import java.sql.Date;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 宛先グループマスタのEntity.
 */
@Entity(naming=NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_address_group")
@Getter
@Setter
public class MstAddressGroup extends BaseBlankEntity {

  /**
   * 宛先グループコード.
   */
  private String addressGroupCd;

  /**
   * 宛先グループ名称.
   */
  private String addressGroupName;

  /**
   * 利用者コード.
   */
  private String userCd;

  /**
   * 登録日時.
   */
  private Date regDate;

  /**
   * 更新日時.
   */
  private Date upDate;

  /**
   * 利用者コードのリストを取得.
   * 利用者コードが設定されていない場合は、空のリストを返却
   *
   * @return 利用者コードのリスト
   */
  public List<String> getUserCds() {
    if (userCd == null) {
      return Collections.emptyList();
    }
    return Arrays.asList(userCd.split(","));
  }

}
