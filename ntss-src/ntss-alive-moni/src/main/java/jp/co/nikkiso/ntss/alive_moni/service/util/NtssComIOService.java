package jp.co.nikkiso.ntss.alive_moni.service.util;

public interface NtssComIOService
{
	/**
	 * DE通知API呼び出し
	 * @return true：成功、false：失敗
	 */
	public boolean SendToMessage(String commApiUri, String facilityCd, Integer deviceEdgeNo, String topic, String payload);
}
