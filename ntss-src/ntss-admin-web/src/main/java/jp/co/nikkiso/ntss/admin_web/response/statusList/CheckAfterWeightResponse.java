package jp.co.nikkiso.ntss.admin_web.response.statusList;

import jp.co.nikkiso.ntss.admin_web.response.FlagAndMessageBaseResponse;
import lombok.NoArgsConstructor;

@NoArgsConstructor
public class CheckAfterWeightResponse extends FlagAndMessageBaseResponse {

  /**
   * コンストラクタ.
   * @param errorMessage エラーメッセージ
   */
  public CheckAfterWeightResponse(String errorMessage) {
    super(errorMessage);
  }

  /**
   * 応答情報.
   */
  //    @JsonProperty("weight_scale_no")
  //    public Long weightScaleNo;
}
