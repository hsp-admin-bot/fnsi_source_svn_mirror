package jp.co.nikkiso.ntss.admin_web.response.weight;

import java.math.BigDecimal;

import jp.co.nikkiso.ntss.admin_web.response.FlagAndMessageBaseResponse;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * ユーザ設定のResponse.
 */
@NoArgsConstructor
@Getter
@Setter
public class WeighthistoryResponse extends FlagAndMessageBaseResponse {

  /**
   * コンストラクタ.
   * @param errorMessage エラーメッセージ
   */
  public WeighthistoryResponse(String errorMessage) {
    super(errorMessage);
  }
  /**
   * ordNo
   */
  public Long ordNo;
  /**
   * 治療日
   */
  public String treatDate;
  /**
   * 治療曜日
   */
  public Short treatWeek;
  /**
   * DW
   */
  public BigDecimal rstDw;
  /**
   * 透析前体重
   */
  public BigDecimal weightBefore;
  /**
   * 透析後体重
   */
  public BigDecimal weightAfter;
  /**
   * 前体重 - 前回後体重
   */
  public BigDecimal difWeight;
  /**
   * 目標体重（実績:治療条件情報）
   */
  public String rstCondInfo;
  /**
   * 装置モード
   */
  public Integer deviceMode;

}
