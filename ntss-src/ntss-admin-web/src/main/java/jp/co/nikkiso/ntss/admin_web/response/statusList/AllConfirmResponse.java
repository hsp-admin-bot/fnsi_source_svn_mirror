package jp.co.nikkiso.ntss.admin_web.response.statusList;

import java.util.List;

import jp.co.nikkiso.ntss.admin_web.response.FlagAndMessageBaseResponse;
import jp.co.nikkiso.ntss.admin_web.service.autoPrint.AutoPrintService.AutoPrintResult;

public class AllConfirmResponse extends FlagAndMessageBaseResponse{
	  /**
	   * コンストラクタ.
	   * @param errorMessage エラーメッセージ
	   */
	  public AllConfirmResponse(String errorMessage) {
	    super(errorMessage);
	  }
	  public String errDetail;

	  public List<AutoPrintResult> autoPrintResults;

}
