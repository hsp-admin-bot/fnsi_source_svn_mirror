package jp.co.nikkiso.ntss.certificate_download.response.error;

import lombok.Getter;
import lombok.NonNull;

/**
 * エラーResponse.
 */
@Getter
public class ErrorResponse {

	/**
	 * このレスポンスに設定されているメッセージを使用するかどうか.
	 */
	private final boolean useResponseMessage;

	/**
	 * メッセージ.
	 */
	private final String message;

	/**
	 * コンストラクタ.
	 * 
	 * @param message
	 *            メッセージ
	 */
	public ErrorResponse(@NonNull String message) {
		this.useResponseMessage = true;
		this.message = message;
	}
}
