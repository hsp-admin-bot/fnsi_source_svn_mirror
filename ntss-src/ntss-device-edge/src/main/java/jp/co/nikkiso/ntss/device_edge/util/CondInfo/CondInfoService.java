package jp.co.nikkiso.ntss.device_edge.util.CondInfo;

import java.util.HashMap;

/**
 *  治療条件情報処理サービス.
 */
public interface CondInfoService {
  /**
   * 治療条件情報のJSON文字列から治療条件情報クラスに展開します。
   * 【注意】指示の治療条件情報には各項目の名前や単位がないため、
   * 本クラスの各findメソッドを使用してマスタから引き当てて下さい。
   * @param condInfoJsonString
   */
  public CondInfo createCondInfo(String condInfoJsonString);

  /**
   * 格納されているダイアライザコードをもとにダイアライザマスタからモデル番号を検索し返します
   */
  public String findDialyzerName(CondInfo condInfo);

  //add redmine bug#5525 劉 start
  /**
   * 格納されている医療材料コードをもとにダイアライザマスタからモデル番号を検索し返します
   */
  public String findEquipmentName(CondInfoItem condInfoItem);
  //add redmine bug#5525 劉 end

  /**
   * 格納されているVAコードをもとにVAマスタからVA名を検索し返します。
   */
  public String findVaName(CondInfo condInfo);

  /**
   * 格納されているA針コードをもとに医療材料マスタから医療材料名、単位を検索し、返します。
   * 戻り値のキー：name, unit
   * @param condInfo
   */
  public HashMap<String, String> findNeedleAName(CondInfo condInfo);

  /**
   * 格納されているV針コードをもとに医療材料マスタから医療材料名、単位を検索し、返します。
   * 戻り値のキー：name, unit
   * @param condInfo
   */
  public HashMap<String, String> findNeedleVName(CondInfo condInfo);

  // #9147 2024.01.25 add 次患者整形 A針だがSN使用の場合はSNの情報をセット TDC山崎 start
  /**
   * 格納されているSN針コードをもとに医療材料マスタから医療材料名、単位を検索し、返します。
   * 戻り値のキー：name, unit
   * @param condInfo
   */
  public HashMap<String, String> findNeedleSnName(CondInfo condInfo);
  // #9147 2024.01.25 add 次患者整形 A針だがSN使用の場合はSNの情報をセット TDC山崎 end

  /**
   * 格納されている透析液コードをもとに薬剤マスタから薬剤名、単位を検索し、返します。
   * 戻り値のキー：name, unit
   * @param condInfo
   */
  public HashMap<String, String> findDialysisFluidName(CondInfo condInfo);

  /**
   * 格納されている抗凝固剤コードをもとに薬剤マスタから薬剤名、単位を検索し、返します。
   * 戻り値のキー：name, unit
   * @param condInfo
   */
  public HashMap<String, String> findAnticoagulantName(CondInfo condInfo);

}
