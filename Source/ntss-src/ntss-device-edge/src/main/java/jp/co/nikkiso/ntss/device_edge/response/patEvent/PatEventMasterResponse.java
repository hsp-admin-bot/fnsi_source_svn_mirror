package jp.co.nikkiso.ntss.device_edge.response.patEvent;

import java.util.List;

import jp.co.nikkiso.ntss.device_edge.response.FlagAndMessageBaseResponse;
import jp.co.nikkiso.ntss.core.entity.MstPatEventCategory;
import jp.co.nikkiso.ntss.core.entity.MstPatEventDataTemplate;
import jp.co.nikkiso.ntss.core.entity.MstPatEventSubCategory;
import lombok.NoArgsConstructor;

@NoArgsConstructor
public class PatEventMasterResponse  extends FlagAndMessageBaseResponse {
	  /**
	   * コンストラクタ.
	   * @param errorMessage エラーメッセージ
	   */
	  public PatEventMasterResponse(String errorMessage) {
	    super(errorMessage);
	  }


	  /**
	  * 患者イベントカテゴリ情報
	  */
	  public List<MstPatEventCategory> category;

	  /**
	  * 患者イベントサブカテゴリ情報
	  */
	  public List<MstPatEventSubCategory> subCategory;

	  /**
	  * 患者イベントテンプレート情報
	  */
	  public List<MstPatEventDataTemplate> template;

}
