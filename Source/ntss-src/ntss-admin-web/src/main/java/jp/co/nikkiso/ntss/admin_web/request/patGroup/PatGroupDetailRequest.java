package jp.co.nikkiso.ntss.admin_web.request.patGroup;

import lombok.Data;

import java.util.List;

@Data
public class PatGroupDetailRequest {

	/**
	 * 患者グループリスト
	 */
	private List<Long> patGroupList;

	/**
	 * 患者リスト
	 */
	private List<Long> patList;
}
