package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.custom.PatGroupCustom;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class PatInfo {

  private PatMain patMain;

  private PatUnique patUnique;

  private PatPersonalMain patPersonalMain;

  private List<PatGroupCustom> patGroupList;

  // add #10436 同姓同名フラグの更新時に対になる患者のpat_main_historyがinsertされていない zhao start
  private String isSame;
  // add #10436 同姓同名フラグの更新時に対になる患者のpat_main_historyがinsertされていない zhao end
}
