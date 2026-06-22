package jp.co.nikkiso.ntss.admin_web.response.patGroup;

import java.util.List;
import com.fasterxml.jackson.annotation.JsonProperty;
import jp.co.nikkiso.ntss.core.entity.PatGroup;
import jp.co.nikkiso.ntss.core.entity.PatGroupDetail;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

/**
 * 患者グループ詳細のResponse.
 */
@AllArgsConstructor
@Getter
@Setter
public class PatGroupDetailResponse {

	/**
	 * 返却患者グループのEntity.
	 */
	@JsonProperty("patGroupInfo")
	public PatGroup patGroupInfo;

	/**
	 * 返却患者グループ詳細のEntity.
	 */
	@JsonProperty("patGroupDetail")
	public List<PatGroupDetail> patGroupDetailList;

	public PatGroupDetailResponse() {
		this.patGroupInfo = null;
		this.patGroupDetailList = null;
	}

}
