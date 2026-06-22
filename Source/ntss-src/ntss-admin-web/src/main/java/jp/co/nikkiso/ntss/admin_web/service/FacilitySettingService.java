package jp.co.nikkiso.ntss.admin_web.service;

import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.core.entity.MstSelector;
import jp.co.nikkiso.ntss.core.exception.NotExistException;


/**
 * 施設設定用のServiceインターフェース.
 */
public interface FacilitySettingService {

  /**
   * 施設の設定値を取得する(defaultValue無/0件時Exception)
   *
   * @param facilityCd 施設コード.
   * @param facilitySettingNo 管理番号.
   * @throws NotExistException 対象データが0件の場合に発生
   * @return 設定値.
   */
  String getFacilitySettingValue(String facilityCd, String facilitySettingNo) throws NotExistException;

  // add FNSI-7217 バッチ操作インターフェイスを追加します 查 start
  /**
   * 施設の設定値を取得する(defaultValue無/0件時Exception)
   *
   * @param facilityCd 施設コード.
   * @param facilitySettingNos 施設設定番号の集合
   * @throws NotExistException オブジェクトデータがクエリーコレクションの数より小さい場合に発生する
   * @return 設定値Map
   */
  Map<String, String> getFacilitySettingValueMap(String facilityCd, List<String> facilitySettingNos) throws NotExistException;
  // add FNSI-7217 バッチ操作インターフェイスを追加します 查 end

  /**
   * 施設のログイン方式の値を取得する
   * @param facilityCdHash
   * @return
   * @throws Exception
   */
  String getFacilityLoginMethodValue(String facilityCdHash) throws Exception;

 /**
   * カードコードでユーザCDを取得する
   * @param facilityHash
   * @param userId アクセスカードに保存されたユーザーID
   * @param cardIdm アクセスカード番号
   * @return ユーザー名
   * @throws Exception
   */
  String getUserIdByCard(String facilityHash, String userId, String cardIdm) throws Exception;

  /**
   * 並び順管理マスタ
   * (施設設定マスタの参照型コンボボックスに使用)
   *
   * @param facilityCd 施設コード
   * @param masterPhysicalNameList マスタ物理名のリスト
   * @return 並び順管理マスタ
   */
  List<MstSelector> getSelectorDataList(String facilityCd, List<String> masterPhysicalNameList);
}
