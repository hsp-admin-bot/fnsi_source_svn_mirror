package jp.co.nikkiso.ntss.admin_web.response.patEvent;

import java.util.List;

import jp.co.nikkiso.ntss.admin_web.response.FlagAndMessageBaseResponse;
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

  /*add FNSI-改修内容カテゴリ、サブカテゴリ、テンプレートが削除された或いは修正された場合、患者イベントの履歴の内容がもともとの内容で表示するように修正 任 start*/
  /**
   * 患者イベントカテゴリ情報
   */
  public List<MstPatEventCategory> allCategory;

  /**
   * 患者イベントサブカテゴリ情報
   */
  public List<MstPatEventSubCategory> allSubCategory;

  /**
   * 患者イベントテンプレート情報
   */
  public List<MstPatEventDataTemplate> allTemplate;
  /*add FNSI-改修内容カテゴリ、サブカテゴリ、テンプレートが削除された或いは修正された場合、患者イベントの履歴の内容がもともとの内容で表示するように修正 任 end*/
}
