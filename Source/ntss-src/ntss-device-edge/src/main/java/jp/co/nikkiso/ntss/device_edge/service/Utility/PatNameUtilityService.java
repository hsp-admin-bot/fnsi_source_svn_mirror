package jp.co.nikkiso.ntss.device_edge.service.Utility;

public interface PatNameUtilityService {

  /**
   * 患者IDから患者名を取得、IDがnullならば？？？？患者とする
   * @param patId 患者ID
   * @return
   */
  PatNameInfo fetchPatName(Long patId);
}
