package jp.co.nikkiso.ntss.core.entity;

import lombok.Getter;
import lombok.Setter;

import java.util.List;


/**
 * 透析情報クラス
 */
@Getter
@Setter
public class OrdMainOnly extends OrdMain {

  private String indCondInfoForMerge;
  private List<String> indCondInfoForNeedleA;
  private List<String> indCondInfoForNeedleR;
  private List<String> dialyzerTypeList;
  private String oldDeviceMode;
  private String newDeviceMode;

}
