package jp.co.nikkiso.ntss.admin_web.response.patGroup;

import java.util.List;
import com.fasterxml.jackson.annotation.JsonProperty;
import jp.co.nikkiso.ntss.core.entity.custom.PatGroupCustom;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

/**
 * カスタム患者グループのResponse.
 */
@AllArgsConstructor
@Getter
@Setter
public class PatGroupCustomResponse {

	/**
	 * カスタム患者グループのEntity.
	 */
	@JsonProperty("patGroupList")
	public List<PatGroupCustom> patGroupList;

	public PatGroupCustomResponse() {
		this.patGroupList = null;
	}

}
