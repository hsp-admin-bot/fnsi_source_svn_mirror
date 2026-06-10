package jp.co.nikkiso.ntss.core.dto.OrdMain;

import lombok.Data;

import java.util.List;

/**
 * @className: FutureOrdMainConditionInfo
 * @author: kangjie
 * @date: 2024/05/21 18:36
 * @Version: 1.0
 * @description: 10150_9664
 */
@Data
public class FutureOrdMainConditionInfo {

  private String indTreatCondIvMode;

  private List<Integer> isUsedCtlNos;

  public String getIndTreatCondIvMode() {
    return indTreatCondIvMode;
  }

  public void setIndTreatCondIvMode(String indTreatCondIvMode) {
    this.indTreatCondIvMode = indTreatCondIvMode;
  }

  public List<Integer> getIsUsedCtlNos() {
    return isUsedCtlNos;
  }

  public void setIsUsedCtlNos(List<Integer> isUsedCtlNos) {
    this.isUsedCtlNos = isUsedCtlNos;
  }


}
