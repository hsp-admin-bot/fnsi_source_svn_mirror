package jp.co.nikkiso.ntss.admin_web.service.indHistory;

import java.util.List;
import java.util.Map;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class IndListUpdateCondition {
	/**
	 * 指示タイプ： 1-受け1 2-受け2 指示タイプ： 3-承認1 4-承認2
	 */
	private int indicationType;

	/**
	 * ログインID
	 */
	private String userId;
	/**
	 * _id list
	 */
  @JsonProperty("_ids")
	private List<String> _ids;
  // add by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --start
  private Boolean checkAll;
  private Boolean isTreatmentUnit;
  private String ope_cd;
  private String facility_cd;
  private String base_date;
	/* upd EOL対応内部 #7010 by ztc 2023-07-09 --start */
  private List<Map<String, Object>> indication;
	/* upd EOL対応内部 #7010 by ztc 2023-07-09 --end */
  // add by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --end
}
