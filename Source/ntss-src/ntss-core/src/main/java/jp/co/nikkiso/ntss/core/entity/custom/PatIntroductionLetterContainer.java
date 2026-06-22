package jp.co.nikkiso.ntss.core.entity.custom;

import lombok.Data;

@Data
public class PatIntroductionLetterContainer {
	/**
	 * 紹介状Cd
	 */
	private Long letterCd;

	/**
	 * 患者イベントCd
	 */
	private Long patEventCd;

	/**
	 * 患者Cd
	 */
	private Long patId;

	/**
	 * 施設Cd
	 */
	private String facilityCd;

	/**
	 * 発行日
	 */
	private String letterIssueDate;

	/**
	 * 紹介状区分
	 */
	private Long letterCategory;

	/**
	 * 転入出先
	 */
	private String toFacilityCd;

	/**
	 * 入力された紹介状のデータ
	 */
	private String letterInfo;

	/**
	 * プリンターCd
	 */
	private Long printerCd;

	/**
	 * 帳票Cd
	 */
	private Long reportCd;

	/**
	 * 帳票名
	 */
	private String reportName;

	/**
	 * 紹介状のHTMLテンプレート
	 */
	private String introductionLetterHtml;

	/**
	 * 患者情報
	 */
	private String patPersonalMain;

	/**
	 * isDispフラグ
	 */
	private String isDisp;

	/**
	 * delフラグ
	 */
	private String isDel;
}
