package jp.co.nikkiso.ntss.admin_web.service.webPush;

import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.core.entity.SysNotificationList;

/**
 * プッシュ通知のServiceインタフェース.
 */
public interface WebPushService {

  /**
   * 非公開鍵(PrivateKey)、公開鍵(PublicKey)の取得(無ければ鍵の生成・保存を行う) .
   * @return 非公開鍵(PrivateKey)、公開鍵(PublicKey)のResponse
   */
  String getKeyPair();

  /**
   * 端末判別用のID、施設コード、利用者ID、Push通知先を紐づけて保存する .
   * @param param 保存データ
   * @return 保存処理結果
   */
  boolean saveNotificationDestination(Map<String, String> param);

  /**
   * 端末判別用のIDに該当するPush通知先を削除する .
   * @param terminalUniqueString 端末固有文字列
   * @return 削除件数
   */
  int deleteNotificationDestination(String terminalUniqueString);

  /**
   * 端末判別用のIDから宛先情報を検索する.
   * @param terminalUniqueString 端末固有文字列
   * @return 宛先情報のリスト
   */
  // mod FNSI-外結バッグを修正する 江 start
  //List<SysNotificationList> searchNotificationDestination(String terminalUniqueString);
  List<SysNotificationList> searchNotificationDestination(String terminalUniqueString,String facilityCd, String userId);
  // mod FNSI-外結バッグを修正する 江 end

}
