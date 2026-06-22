package jp.co.nikkiso.ntss.admin_web.service.indHistory;

import java.util.List;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;
import lombok.Setter;

/**
 * 指示受け承認検索結果
 *
 */
@Getter
@Setter
public class IndSearchResult {
	/**
	 * 患者ID
	 */
	private String patId;
	/**
	 * 患者名
	 */
	private String patName;
	/**
	 * 患者名カナ
	 */
	private String patNameKana;
	/**
	 * 値をセットした受け1件数
	 */
	private int check1;
	/**
	 * 値をセットした受け2件数
	 */
	private int check2;
	/**
	 * 値をセットした承認１件数
	 */
	private int approver1;
	/**
	 * 値をセットした承認2件数
	 */
	private int approver2;
	/**
	 * レコード件数
	 */
	private int total;
	/**
	 * _id一覧
	 */
  @JsonProperty("_id")
	private List<String> _id;

	private String hospPatId;
  // add 7570 ind_dial連携で送信する項目情報部  赵 start
  private String ordNo;
  // add 7570 ind_dial連携で送信する項目情報部  赵 end

}
