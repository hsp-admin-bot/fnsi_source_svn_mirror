package jp.co.nikkiso.ntss.admin_web.response.sysFunction;

import lombok.Data;

/**
 * 機能一覧返却用APIのResponseクラス.
 */
@Data
public class SysFunctionResponse {

	/**
	 * 機能コード
	 */
	private String functionCd;

	/**
	 * メニュー機能名
	 */
	private String functionName;

	/**
	 * 状態
	 */
	private boolean usedStatus;

	/**
	 * 表示順
	 */
	private Integer dispOrder;
	
	/**
	 * 拡張機能フラグ
	 */
	private boolean isAdv;

}
