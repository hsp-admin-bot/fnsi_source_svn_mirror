package jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.model;

import lombok.Getter;
import lombok.Setter;

import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
public class PatTreatmentPatternDelta {

  private final List<PatTreatmentPatternUpsert> inserts = new ArrayList<>();
  private final List<PatTreatmentPatternKey> deletes = new ArrayList<>();
  private final List<PatTreatmentPatternUpsert> updates = new ArrayList<>();

  public boolean isEmpty() {
    return inserts.isEmpty() && deletes.isEmpty() && updates.isEmpty();
  }
}
