package jp.co.nikkiso.ntss.coop_api.service;

import jp.co.nikkiso.ntss.core.entity.custom.MstCoopIniInfo;

public interface MstCoopIniService {
// del 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  /**
//   * 検証時のどのシステム
//   * @param coopIniMemo {@link jp.co.nikkiso.ntss.coop_api.utils.MstCoopIniConstant.CoopIniMemo}
//   * @param facilityCd 施設コード
//   */
//  public Boolean validateCoopByFacilityCd(String coopIniMemo,String facilityCd);
// del 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

  /**
   * 初版確定前の治療実績削除で不要なイベントが登録される
   * @param mstCoopIni {@link MstCoopIniInfo}
   */
  public String getEffectValue(MstCoopIniInfo mstCoopIni);

  /**
   * 初版確定前の治療実績削除で不要なイベントが登録される
   * @param facilityCd 施設コード
   * @param key0 key0
   * @param key1 key1
   * @param key2 key2
   */
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  public MstCoopIniInfo getCoopIniInfo(String facilityCd, String key1, String key2);
  public MstCoopIniInfo getCoopIniInfo(String facilityCd, String key0, String key1, String key2);
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
}
