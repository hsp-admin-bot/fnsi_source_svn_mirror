package jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.model;

import java.util.List;
import java.util.Map;

public record PatTreatmentPatternKey(
  Long patId,
  String facilityCd,
  List<Integer> indTreatmentCds,
  List<Long> indKurCds,
  List<Integer> treatWeeks,
  Long ctlNo,
  Map<String, String> otherConditions
) { }
