package jp.co.nikkiso.ntss.admin_web.service.scaleBed.dto;

import jp.co.nikkiso.ntss.core.entity.custom.ScaleBedAllState;
import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import java.math.BigDecimal;

@Getter
@Setter
public class ScaleBedListViewDTO extends ScaleBedAllState {
  /**
   * 患者の入外区分
   */
  private Integer inOutClass;
  /**
   * 院内患者ID
   */
  private String hospPatId;
  /**
   * 患者名
   */
  private String patName;
  /**
   * 患者氏名(カタカナ姓)
   */
  private String patLastNameKana;
  /**
   * 患者氏名(カタカナ名)
   */
  private String patFirstNameKana;

  public ScaleBedListViewDTO(ScaleBedAllState scaleBedAllState, Integer inOutClass, String hospPatId, String patName, String patFirstNameKana, String patLastNameKana) {
    super();
    this.inOutClass = inOutClass;
    this.hospPatId = hospPatId;
    this.patName = patName;
    this.patFirstNameKana = patFirstNameKana;
    this.patLastNameKana = patLastNameKana;

    /* 患者情報 */
    this.setOrdNo(scaleBedAllState.getOrdNo());
    this.setPatId(scaleBedAllState.getPatId());
    this.setIsSame(scaleBedAllState.getIsSame());
    this.setWheelChairCd(scaleBedAllState.getWheelChairCd());
    this.setIsWheelChair(scaleBedAllState.getIsWheelChair());
    this.setRstTareInfo(scaleBedAllState.getRstTareInfo());

    /* 患者測定実績情報 */
    this.setRstDialysisState(scaleBedAllState.getRstDialysisState());
    this.setWeightScaleStatus(scaleBedAllState.getWeightScaleStatus());
    this.setScaleValue(scaleBedAllState.getScaleValue());
    this.setWeightScaleNo(scaleBedAllState.getWeightScaleNo());
    this.setScaleMode(scaleBedAllState.getScaleMode());
    this.setIndTareInfo(scaleBedAllState.getIndTareInfo());
    this.setScaleClass(scaleBedAllState.getScaleClass());
    this.setRstWeightInfo(scaleBedAllState.getRstWeightInfo());
    this.setWeightBefore(scaleBedAllState.getWeightBefore());

    /* 装置関連情報 */
    this.setIsConnect(scaleBedAllState.getIsConnect());
    this.setWeightCd(scaleBedAllState.getWeightCd());
    this.setWeightNo(scaleBedAllState.getWeightNo());
    this.setProcessState(scaleBedAllState.getProcessState());
    this.setComFormatCd(scaleBedAllState.getComFormatCd());
    this.setComType(scaleBedAllState.getComType());
    this.setFacilityCd(scaleBedAllState.getFacilityCd());
    this.setBedCd(scaleBedAllState.getBedCd());
    this.setBedName(scaleBedAllState.getBedName());
    this.setIsDefaultPrintBefore(scaleBedAllState.getIsDefaultPrintBefore());
    this.setIsDefaultPrintAfter(scaleBedAllState.getIsDefaultPrintAfter());

    /* スケールベッドステータス情報 */
    this.setSendStatus(scaleBedAllState.getSendStatus());
    this.setSsWeightScaleNo(scaleBedAllState.getSsWeightScaleNo());

    /* スケジュール情報 */
    this.setKurCd(scaleBedAllState.getKurCd());
    this.setBedOrderIndex(scaleBedAllState.getBedOrderIndex());
  }
}

