package jp.co.nikkiso.ntss.core.entity.custom;

import lombok.Data;

import java.sql.Timestamp;

@Data
public class WeekChangeInfo {

  private Long patId;

  private Integer indTreatmentCd;

  private Integer oldTreatWeek;

  private Integer newTreatWeek;

  private Integer treatWeek;

  private Long patternCd;

  private Timestamp regScheduleDate;

  private Integer patternCategory;
}
