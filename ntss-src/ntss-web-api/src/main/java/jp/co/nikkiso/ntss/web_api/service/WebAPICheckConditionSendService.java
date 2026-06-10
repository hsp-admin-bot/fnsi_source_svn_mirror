package jp.co.nikkiso.ntss.web_api.service;

import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.core.entity.MstDialyzer;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatUnique;

/**
 * 条件送信画面系のServiceインタフェース.
 */
public abstract interface WebAPICheckConditionSendService {

  /**
   * 装置オプション取得用
   * @param ordNo オーダー番号
   * @return 装置オプション
   * @throws Exception
   */
  List<String> getMachineOptionsFromMstMachine(Long ordNo);
  /**
   * オーダーメイン取得用
   * @param ordNo オーダー番号
   * @return OrdMainエンティティ
   * @throws Exception
   */
  OrdMain getDataFromOrdMain(Long ordNo);
  /**
   * 装置タイプ取得用
   * @param ordNo オーダー番号
   * @return 装置タイプ情報
   * @throws Exception
   */
  List<Map<String,Object>> getMachineTypeFromMstMachine(Long ordNo);
  /**
   * 装置マスタ取得用
   * @param ordNo オーダー番号
   * @return 装置マスタ情報
   * @throws Exception
   */
  List<Map<String,Object>> getDataFromMstMachine(Long ordNo);
  /**
   * 身体情報取得用
   * @param patId 患者ID
   * @return 身体情報
   * @throws Exception
   */
  List<PatUnique> getDataFromPatUnique(Long patId);
  /**
   * 装置設定情報取得用
   * @param ordNo オーダー番号
   * @return 装置設定情報
   * @throws Exception
   */
  List<Map<String,Object>> getMachineSetting(Long ordNo);
  /**
   * 装置モード取得用
   * @param ordNo オーダー番号
   * @return 装置モード
   * @throws Exception
   */
  List<String> getDeviceModeFromMstTreatment(Long ordNo);
  /**
   * ダイアライザ情報取得用
   * @param dialysisCd ダイアライザコード
   * @return ダイアライザ情報
   * @throws Exception
   */
  MstDialyzer getDialyzerInfoFromDialyzer(
                                Integer dialyzerCd
                            );
  /**
   * 患者情報(患者名)取得用
   * @param patId 患者ID
   * @return 患者(患者名)情報
   * @throws Exception
   */
  Map<String,Object> getPatNameFromPatPersonalMain(Long patId);
  /**
   * 条件送信データ格納用
   * @param ordNo オーダー番号
   * @param sendCondData 条件送信データ(Json文字列)
   * @return 更新件数
   * @throws Exception
   */
  int insertSendCondData(Long ordNo,String sendCondData);
}
