package jp.co.nikkiso.ntss.admin_web.service.scaleBed;

import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.scaleBed.dto.CheckSendableConditionResult;
import jp.co.nikkiso.ntss.admin_web.service.scaleBed.dto.ScaleBedListViewDTO;
import jp.co.nikkiso.ntss.admin_web.service.scaleBed.dto.ScaleBedWeightAndBedKey;

import java.math.BigDecimal;
import java.util.List;

public interface ScaleBedService {
  /**
   * スケールベッドの状況一覧取得
   * @param facilityCd 施設コード
   * @return 一覧
   */
  List<ScaleBedListViewDTO> getScaleBedList(String facilityCd);

  /**
   * 有効なスケールベッド設定の紐づく体重計コードとベッドコードの一覧を取得
   */

  List<ScaleBedWeightAndBedKey> getScaleBedWeightAndBedKeyList(String facilityCd);

  /**
   * 条件送信内容チェック処理とパラメータの作成
   * @param bedCd
   * @param weightCd
   * @param ordNo
   * @return
   */
  CheckSendableConditionResult checkSendableCondition(Long bedCd, Long weightCd, Long ordNo, BigDecimal measureValue, NtssUser user);
  /**
   * 後体重用の条件送信内容チェック処理とパラメータの作成
   * @param bedCd
   * @param weightCd
   * @param ordNo
   * @return
   */
  CheckSendableConditionResult checkSendableAfterWeight(Long bedCd, Long weightCd, Long ordNo, BigDecimal measureValue, NtssUser user);
}
