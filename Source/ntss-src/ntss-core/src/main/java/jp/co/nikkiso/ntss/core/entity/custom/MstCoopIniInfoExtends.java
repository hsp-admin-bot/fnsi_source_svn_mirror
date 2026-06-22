package jp.co.nikkiso.ntss.core.entity.custom;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class MstCoopIniInfoExtends {
  //mod 7525 rst_dial連携（拡張）ヘッダON/OFF切り替え 20230105 卓 start
//  extends MstCoopIniInfo{
  //mod 7525 rst_dial連携（拡張）ヘッダON/OFF切り替え 20230105 卓 end


  /*key2*/
  private String key2;

}
