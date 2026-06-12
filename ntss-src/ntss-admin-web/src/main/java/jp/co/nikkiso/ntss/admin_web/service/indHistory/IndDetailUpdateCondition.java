package jp.co.nikkiso.ntss.admin_web.service.indHistory;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;
import lombok.Setter;

/**
 * 指示詳細画面で更新条件
 */
@Getter
@Setter
public class IndDetailUpdateCondition {
	/**
	 * 指示タイプ： 1-受け1 2-受け2
	 * 指示タイプ： 3-承認1 4-承認2
	 */
	private int indicationType;
	/**
	 * ユーザーID
	 */
	private String userId;

  @JsonProperty("_id")
	private String _id;
}
