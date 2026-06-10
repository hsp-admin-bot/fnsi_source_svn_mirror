package jp.co.nikkiso.ntss.admin_web.response.statusList;

import jp.co.nikkiso.ntss.admin_web.response.FlagAndMessageBaseResponse;
import lombok.AllArgsConstructor;

@AllArgsConstructor
public class TreatmentStatusUpdateResponse extends FlagAndMessageBaseResponse{
	  /**
	   * コンストラクタ.
	   * @param errorMessage エラーメッセージ
	   */
	  public TreatmentStatusUpdateResponse(String errorMessage) {
	    super(errorMessage);
	  }

}
