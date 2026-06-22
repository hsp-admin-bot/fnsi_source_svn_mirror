package jp.co.nikkiso.ntss.admin_web.response.patGroup;

import java.util.List;
import com.fasterxml.jackson.annotation.JsonProperty;
import jp.co.nikkiso.ntss.core.entity.PatGroup;
import lombok.AllArgsConstructor;

/**
 * 返却患者グループのResponse.
 */
@AllArgsConstructor
public class PatGroupResponse {

	/**
	 * 返却患者グループのEntity.
	 */
	@JsonProperty("patGroupInfo")
	public List<PatGroup> patGroupInfo;

	/**
	 * 患者グループ取得失敗時のレスポンスを返却するコンストラクタ.
	 */
	public PatGroupResponse() {
		this.patGroupInfo = null;
	}

}
