package jp.co.nikkiso.ntss.core.entity.custom;

public class OrdMainInfo {
  private String ind_info_cd;
  private String ind_info;

  public OrdMainInfo() {}
  public OrdMainInfo(String info_cd, String info) {
    this.ind_info_cd = info_cd;
    this.ind_info = info;
  }

  public String getIndInfoCd() {
    return this.ind_info_cd;
  }

  public String getIndInfo() {
    return this.ind_info;
  }
}
