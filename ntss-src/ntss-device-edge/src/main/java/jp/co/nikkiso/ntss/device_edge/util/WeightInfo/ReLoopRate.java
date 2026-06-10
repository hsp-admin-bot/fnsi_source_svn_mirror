package jp.co.nikkiso.ntss.device_edge.util.WeightInfo;

import java.util.Date;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 *  再循環率クラス.
 */
@NoArgsConstructor
@Getter
@Setter
public class ReLoopRate {

  /** 測定日時 **/
  private Date measureDate;
  /** 測定値 **/
  private String value;

}
