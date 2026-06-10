package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import lombok.Getter;
import lombok.Setter;

@Entity(naming = NamingType.NONE)
@Table(name = "pat_personal_main")
@Getter
@Setter
public class PatPersonalMainData extends PatPersonalMain {
  // 同姓同名フラグ
  private String is_same;
  //add 患者検索設定後処理不正 修正 20230601 ztc start
  private String in_out_current_state;
  //add 患者検索設定後処理不正 修正 20230601 ztc end
}
