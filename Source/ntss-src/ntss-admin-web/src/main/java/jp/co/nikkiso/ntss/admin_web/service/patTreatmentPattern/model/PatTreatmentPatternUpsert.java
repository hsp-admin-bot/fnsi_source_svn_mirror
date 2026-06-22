package jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.model;


import lombok.Getter;
import lombok.Setter;

import java.util.EnumMap;
import java.util.Map;

@Getter
public class PatTreatmentPatternUpsert {

  private final PatTreatmentPatternKey key;

  /* ===== 更新したい値 ===== */
  @Setter
  private Integer indTreatmentCd;
  @Setter
  private Long indKurCd;
  @Setter
  private Short treatWeek;
  @Setter
  private Double treatType;
  @Setter
  private String indTreatStartDate;

  /* ===== JSONB フィールド ===== */
  private final Map<PatTreatmentPatternFieldEnum, PatTreatmentPatternJsonbField> jsonbUpdates =
    new EnumMap<>(PatTreatmentPatternFieldEnum.class);

  public PatTreatmentPatternUpsert(PatTreatmentPatternKey key) {
    this.key = key;
  }

  public void addJsonbUpdate(PatTreatmentPatternFieldEnum field, PatTreatmentPatternJsonbField update) {
    this.jsonbUpdates.put(field, update);
  }

  public boolean hasUpdate() {
    return indTreatmentCd != null
      || indKurCd != null
      || treatWeek != null
      || !jsonbUpdates.isEmpty();
  }
}
