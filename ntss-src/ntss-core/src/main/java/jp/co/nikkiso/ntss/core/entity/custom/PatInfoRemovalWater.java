package jp.co.nikkiso.ntss.core.entity.custom;

public class PatInfoRemovalWater {
  private Long pat_id;
  private String off_water_info_cd;
  private String off_water_info;
  
  public PatInfoRemovalWater() {}
  public PatInfoRemovalWater(Long no, String info_cd, String info) {
    this.pat_id = no;
    this.off_water_info_cd = info_cd;
    this.off_water_info = info;
  }
  
  public Long getPatId() {
    return this.pat_id;
  }
  
  public String getOffWaterInfoCd() {
    return this.off_water_info_cd;
  }
  
  public String getOffWaterInfo() {
    return this.off_water_info;
  }
}