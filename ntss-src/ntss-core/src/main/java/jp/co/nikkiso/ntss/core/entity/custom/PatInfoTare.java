package jp.co.nikkiso.ntss.core.entity.custom;

public class PatInfoTare {
  private Long pat_id;
  private String tare_info_cd;
  private String tare_info;
  
  public PatInfoTare() {}
  public PatInfoTare(Long no, String info_cd, String info) {
    this.pat_id = no;
    this.tare_info_cd = info_cd;
    this.tare_info = info;
  }
  
  public Long getPatId() {
    return this.pat_id;
  }
  
  public String getTareInfoCd() {
    return this.tare_info_cd;
  }
  public String getTareInfo() {
    return this.tare_info;
  }
}