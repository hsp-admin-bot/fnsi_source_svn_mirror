package jp.co.nikkiso.ntss.core.entity.custom;

public class OrdMainOffWaterInfo {
  private Integer count_num;
  private Long week_cd;
  private String ind_info;
  
  public OrdMainOffWaterInfo() {}
  public OrdMainOffWaterInfo(Integer count, Long week, String info) {
    this.count_num = count;
    this.week_cd = week;
    this.ind_info = info;
  }
  
  public Integer getCount() {
    return this.count_num;
  }
  
  public Long getWeek() {
    return this.week_cd;
  }
  
  public String getIndInfo() {
    return this.ind_info;
  }
}