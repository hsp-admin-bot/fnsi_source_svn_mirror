package jp.co.nikkiso.ntss.certificate_download.response;

import lombok.AllArgsConstructor;

/**
 * ログイン成功時Response.
 */
@AllArgsConstructor
public class LoginResponse {
	/**
	 * ユーザーID(内部用).
	 */
	public final String userId;

	/**
	 * 利用者種別.
	 */
	public final String userRole;
	
	/**
	 * ユーザー名.
	 */
	public final String userName;

	/**
	 * サインイン後勝ち設定.
	 */
	public final Boolean signInRestriction;
}
