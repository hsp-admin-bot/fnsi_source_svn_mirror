package jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat;

import java.util.List;
import lombok.Data;

/**
 * 患者グループリクエスト
 */
@Data
public class PatGroupSearchRequest {

	/**
	 * 患者グループリスト
	 */
	private List<Integer> patGroupCd;

	/**
	 * 検索タイプは含むか一致か
	 */
	private Integer searchType;
}