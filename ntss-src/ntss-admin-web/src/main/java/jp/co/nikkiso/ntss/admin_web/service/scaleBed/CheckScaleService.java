package jp.co.nikkiso.ntss.admin_web.service.scaleBed;

import jp.co.nikkiso.ntss.admin_web.service.scaleBed.dto.CheckScaleMessage;
import jp.co.nikkiso.ntss.admin_web.service.scaleBed.dto.CheckingParameter;
import jp.co.nikkiso.ntss.admin_web.service.scaleBed.dto.TargetPhysicalInfo;
import jp.co.nikkiso.ntss.core.entity.MstWeight;
import jp.co.nikkiso.ntss.core.entity.custom.PatUniquePhysicalInfo;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;

public interface CheckScaleService {

  enum ScaleMode {
    BEFORE,
    NOW_DIALYSIS,
    AFTER,
  }

  /**
   * チェック用の値リスト作成
   * @param scaleValue 測定値
   * @param measureDate 測定日時
   * @param ordNo オーダー番号
   * @param scaleMode 前体重/後体重
   * @param facilityCd 施設コード
   * @param bedCdByOrdNull オーダーからベッドコードがとれない場合のベッドコード
   * @return 測定値チェック用項目群
   */
  CheckingParameter buildCheckingParameter(
    BigDecimal scaleValue,
    Timestamp measureDate,
    Long ordNo,
    ScaleMode scaleMode,
    String facilityCd,
    Long bedCdByOrdNull);

  /**
   * 測定値チェック
   * @param param 測定値チェック用項目群
   * @param mstWeight 体重計マスタのレコード
   * @param scaleMode 前体重かどうか
   * @param facilityCd 施設コード
   * @return チェックの結果、警告レベルなら 1, 重大レベルなら 2, 問題なしなら 0 を返す
   */
  int checkScaleAsNumber(
    CheckingParameter param,
    MstWeight mstWeight,
    ScaleMode scaleMode,
    String facilityCd
  );

  /**
   * 測定値チェック
   * @param param 測定値チェック用項目群
   * @param mstWeight 体重計マスタのレコード
   * @param scaleMode 前体重かどうか
   * @param facilityCd 施設コード
   * @return メッセージ情報の一覧
   */
  List<CheckScaleMessage> checkScale(
    CheckingParameter param,
    MstWeight mstWeight,
    ScaleMode scaleMode,
    String facilityCd
  );


  /**
   * 患者身体情報から、測定日以前の中から最新の各値を取得
   * @param physicalInfo 身体情報
   * @param measureDate 測定日
   * @return 最新のDW,前体重許容上下限、身長
   */
  TargetPhysicalInfo getTargetPhysicalInfo(List<PatUniquePhysicalInfo> physicalInfo, Timestamp measureDate);
}
