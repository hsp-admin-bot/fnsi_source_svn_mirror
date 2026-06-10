package jp.co.nikkiso.ntss.core.dto.pattreatmentpattern;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class EditDto {
  /** 編集種類： OVERWRITE、MERGE*/
  private String mode;
  /** 治療曜日(eg:1,3,5) */
  private String treatWeek;
  // 更新項目マップ(Map<String, Object> patch -> json)
  private String patchJson;
}
