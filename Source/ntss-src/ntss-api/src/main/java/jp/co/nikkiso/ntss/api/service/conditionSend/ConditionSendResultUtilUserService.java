package jp.co.nikkiso.ntss.api.service.conditionSend;


import java.util.List;


/**
 * 条件送信3011のServiceインタフェース.
 */
public abstract interface ConditionSendResultUtilUserService {


  /**
   * 各名称取得用(一部コード)
   * @param ordNo オーダー番号
   * @return 名称
   *    key                 value
   *    pat_id              患者ID
   *    facility_cd         施設コード
   *    facility_name       施設名
   *    treatment_name      治療名
   *    kur_name            クール名
   *    bed_name            ベッド名
   *    machine_no          装置番号
   *    machine_name        装置名
   */
  public List<String[]> getUsersNames(
      List<String> facilityCdList ,
      List<Long> userIdList,
      boolean cryptoFlag
);

  /*
   * 入外区分の取得
   * @param pat_id 患者ID
   * @return 入外区分
   */
  public Integer getInOutClassbyPatId(Long pat_id) ;

}
