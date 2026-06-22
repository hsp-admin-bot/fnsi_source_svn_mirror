package jp.co.nikkiso.ntss.admin_web.service.weight.state;

import jp.co.nikkiso.ntss.core.entity.MntScaleBedState;
import jp.co.nikkiso.ntss.core.entity.OrdWeightScale;

import java.math.BigDecimal;

public interface ScaleBedStateService {
  MntScaleBedState selectByBedCd(Long bedCd);

  int insert(MntScaleBedState param);

  int update(MntScaleBedState param);

  /**
   * mnt_scale_bed_state.is_connectを更新
   */
  int updateIsConnect(Long bedCd, String isConnect);

  /**
   * 前体重のmnt_scale_bed_state.scale_valueなどを更新
   */
  int updateScaleValueBefore(Long bedCd, Long weightCd, String facilityCd, Long weightScaleNo);

  /**
   * 後体重のmnt_scale_bed_state.scale_valueなどを更新
   */
  int updateScaleValueAfter(Long bedCd, Long weightCd, String facilityCd,  Long weightScaleNo);

  /**
   * mnt_scale_bed_state.send_statusを0:正常に更新
   * @param bedCd 対象ベッドコード
   * @param isBeforeWeight 前体重フラグ
   * @param weightScaleNo 測定履歴番号
   */
  void updateSendStatusNormalize(Long bedCd, boolean isBeforeWeight, Long weightScaleNo);
  /**
   * mnt_scale_bed_state.send_statusを0:正常に更新
   * @param bedCd 対象ベッドコード
   * @param isBeforeWeight 前体重フラグ
   * @param weightScaleNo 測定履歴番号
   */
  void updateSendStatusNormalize(Long bedCd, boolean isBeforeWeight, Long weightScaleNo, BigDecimal scaleValue);
  /**
   * mnt_scale_bed_state.send_statusを軽微な問題に更新
   * @param bedCd 対象ベッドコード
   * @param isBeforeWeight 前体重フラグ
   * @param weightScaleNo 測定履歴番号
   */
  void updateSendStatusWarning(Long bedCd, boolean isBeforeWeight, Long weightScaleNo);
  /**
   * mnt_scale_bed_state.send_statusを重大な問題に更新
   * @param bedCd 対象ベッドコード
   * @param isBeforeWeight 前体重フラグ
   * @param weightScaleNo 測定履歴番号
   */
  void updateSendStatusError(Long bedCd, boolean isBeforeWeight, Long weightScaleNo);

  /**
   * 対象ベッドコードとオーダー番号からord_weight_scaleに書き込むべき情報を収集する
   *
   * @param bedCd 対象ベッドコード
   * @param targetOrdNo 対象のオーダー番号
   */
  OrdWeightScale selectForOrdWeightScaleByBedCd(Long bedCd, Long targetOrdNo, boolean isAfter);
}
