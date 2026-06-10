package jp.co.nikkiso.ntss.admin_web.service;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MstFacility;
import jp.co.nikkiso.ntss.core.entity.MstFacilityHash;
import jp.co.nikkiso.ntss.core.entity.MntFacilityCancelManage;

/**
 * 施設マスタハッシュ用のServiceインターフェース.
 */
public interface MstFacilityService {

  /**
   * ハッシュ値に紐づくシステム利用設定の値を取得
   * @param hashValue
   * @return システム利用設定
   * @throws Exception
   */
  String getSystemUseSettingByHashValue(String hashValue) throws Exception;

  /**
   * 施設コードに紐付くレコードを取得.
   * @param facilityCd 施設コード
   * @return 施設マスタハッシュレコード.
   */
  MstFacilityHash getMstFacilityHashByFacilityCd(String facilityCd) throws Exception;

  /**
   * 全レコードを取得.
   * @return 施設マスタハッシュレコード.
   */
  List<MstFacilityHash> getMstFacilityHash() throws Exception;

  /**
   * 施設解約管理(処理区分:施設解約)全レコードを取得.
   * @return 施設マスタハッシュレコード.
   */
  List<MntFacilityCancelManage> getMntFacilityCancelManage() throws Exception;

  /**
   * 解約済施設を完全削除する
   * @param facilityCd 施設コード
   */
  void completeDeleteFacility(String facilityCd) throws Exception;

  /**
   * ReMS解約済/FNSi解約済み 施設のバックアップファイルを削除する
   * @param facilityCd 施設コード
   */
  void deleteBackupFileFacility(String facilityCd) throws Exception;

  /**
   * ハッシュ値に紐づく2要素認証失敗許容回数の値を取得
   * @param hashValue
   * @return 2要素認証失敗許容回数
   * @throws Exception
   */
  int getSystemOtpFailureCntByHashValue(String hashValue) throws Exception;

  /**
   * URLサインイン設定の設定値を取得する(サインイン画面でサインイン前に設定を取得する)
   *
   * @param hashValue
   * @return 設定値.
   * @throws Exception
   */
  String getUrlSignin(String hashValue) throws Exception;
  
  /**
   * サインインIF表示設定の設定値を取得する(サインイン画面でサインイン前に設定を取得する)
   *
   * @param hashValue
   * @return 設定値.
   * @throws Exception
   */
  String getIsSigninDisp(String hashValue) throws Exception;

  // add FNSI-3922 投薬指示機能が施設拡張設定のON\OFF制御に反映していない liumx start
  /**
   * cdによる取得mst_facility
   *
   * @param facilityCd
   * @return 施設コード情報
   * @throws Exception
   */
  List<MstFacility> getFacilityInfoByCd(String facilityCd) throws Exception;
  // add FNSI-3922 投薬指示機能が施設拡張設定のON\OFF制御に反映していない liumx end
}
