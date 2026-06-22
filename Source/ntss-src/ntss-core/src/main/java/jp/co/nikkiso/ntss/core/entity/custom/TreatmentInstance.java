package jp.co.nikkiso.ntss.core.entity.custom;

import jp.co.nikkiso.ntss.core.dto.indSchedule.IndScheduleInfo;
import lombok.Data;

@Data
public class TreatmentInstance {

  public enum Source {
    ORD_MAIN,
    PAT_TREATMENT_PATTERN
  }
  public enum ChangeType {
    MOVE,
    COPY,
    DELETE
  }

  private Long patId;

  private Long ordNo;

  private String treatDate;

  private Integer indTreatmentCd;

  private Integer treatWeek;

  private Integer bedCd;

  private Integer kurCd;

  private String start;

  private String end;

  private String treatTime;

  private Source source;

  private ChangeType changeType = TreatmentInstance.ChangeType.MOVE;

  private IndScheduleInfo beforeIndScheduleInfo;

  private IndScheduleInfo afterIndScheduleInfo;

  private String kurName;

  private String bedName;

  private String indMediInfo;

  private String moveBeforeTreatDate;

  private String rstDialysisState;

  private Integer treatType;

  public TreatmentInstance(TreatmentInstance src) {
    this.patId = src.getPatId();
    this.ordNo = src.getOrdNo();
    this.treatDate = src.getTreatDate();
    this.indTreatmentCd = src.getIndTreatmentCd();
    this.treatWeek = src.getTreatWeek();
    this.bedCd = src.getBedCd();
    this.kurCd = src.getKurCd();
    this.start = src.getStart();
    this.end = src.getEnd();
    this.treatTime = src.getTreatTime();
    this.source = src.getSource();
    this.changeType = src.getChangeType();
    this.kurName = src.getKurName();
    this.bedName = src.getBedName();
    this.indMediInfo = src.getIndMediInfo();
    this.moveBeforeTreatDate = src.getMoveBeforeTreatDate();
    this.rstDialysisState = src.getRstDialysisState();
    this.treatType = src.getTreatType();

    this.beforeIndScheduleInfo = src.getBeforeIndScheduleInfo();

    this.afterIndScheduleInfo = src.getAfterIndScheduleInfo();
  }
  public TreatmentInstance() {
  }
}
