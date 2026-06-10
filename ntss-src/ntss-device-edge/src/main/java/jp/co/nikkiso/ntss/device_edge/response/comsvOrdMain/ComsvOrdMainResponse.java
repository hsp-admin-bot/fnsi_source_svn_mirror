package jp.co.nikkiso.ntss.device_edge.response.comsvOrdMain;

import jp.co.nikkiso.ntss.core.entity.custom.ComsvNextPatInfo;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

/**
 *  通信サーバ用次患者情報のResponse.
 */
@AllArgsConstructor
@Getter
@Setter
public class ComsvOrdMainResponse extends ComsvNextPatInfo {

  /**
   * 指示：装置設定情報
   */
  private String patFirstName;

  /**
   * 感染症有無
   */
  private String patLastName;

  /**
   * コンストラクタ.
   * 親クラスの各フィールド値をインスタンスに格納します.
   * @param ComsvNextPatInfo
   */
  public ComsvOrdMainResponse(ComsvNextPatInfo comsvNextPatInfo) {
    this.setOrdNo(comsvNextPatInfo.getOrdNo());
    this.setPatId(comsvNextPatInfo.getPatId());
    this.setTreatDate(comsvNextPatInfo.getTreatDate());
    this.setFacilityCd(comsvNextPatInfo.getFacilityCd());
    this.setFacilityName(comsvNextPatInfo.getFacilityCd());
    this.setIndTreatmentCd(comsvNextPatInfo.getIndTreatmentCd());
    //    this.setIndTreatmentName(comsvNextPatInfo.getIndTreatmentName());
    //    this.setIndKurName(comsvNextPatInfo.getIndKurName());
    this.setIndTreatStartTime(comsvNextPatInfo.getIndTreatStartTime());
    this.setIndCondInfo(comsvNextPatInfo.getIndCondInfo());
    this.setIndMediInfo(comsvNextPatInfo.getIndMediInfo());
    this.setIndEquipInfo(comsvNextPatInfo.getIndEquipInfo());
    this.setIndDeviceSetInfo(comsvNextPatInfo.getIndDeviceSetInfo());
    this.setIsInfect(comsvNextPatInfo.getIsInfect());
  }

}
