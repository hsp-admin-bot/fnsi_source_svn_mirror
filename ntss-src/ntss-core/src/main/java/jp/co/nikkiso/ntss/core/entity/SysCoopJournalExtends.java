package jp.co.nikkiso.ntss.core.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class SysCoopJournalExtends extends SysCoopJournal {
  //add 6993 【デグレ】profile連携で受信した生存の有無登録 20221123 zhaoqi start
  /**
   * 登録時検査区分.
   */
  private String tableName;

  /**
   * 登録時検査区分.
   */
  private String regOrderClass;
  //add 6993 【デグレ】profile連携で受信した生存の有無登録 20221123 zhaoqi end

}
