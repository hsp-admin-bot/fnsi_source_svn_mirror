package jp.co.nikkiso.ntss.m_notice.service;

import java.util.Map;

/**
 * オプション申請メール送信のServiceインタフェース.
 */
public interface SalSubManSendMailService {

	/**
	   * メールを送る
	   * @param salSubscriptionManage
	   * @return 
	*/
	public void sendMail(Map<String, String> salSubscriptionManage) throws Exception;
}
