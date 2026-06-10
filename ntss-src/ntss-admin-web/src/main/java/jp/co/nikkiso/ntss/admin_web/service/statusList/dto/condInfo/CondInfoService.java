package jp.co.nikkiso.ntss.admin_web.service.statusList.dto.condInfo;

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
   * VAコードをもとにVAマスタからVA名を検索し返します。
   */
  public String findVaName(String cd);

  /**
   * ダイアライザコードをもとにダイアライザマスタからモデル番号を検索し返します
   */
  public String findDialyzerName(String cd);

  /**
   * 医療材料コードをもとに医療材料マスタから医療材料名、単位を検索し、返します。
   * 戻り値のキー：name, unit
   */
  public HashMap<String, String> findEquipmentInfo(String cd);

  /**
   * 格納されている薬剤区分、薬剤コードをもとに薬剤マスタか調整薬剤マスタから薬剤名、単位を検索し、返します。
   * 戻り値のキー：name, unit
   */
  public HashMap<String,String> findMedicineInfo(String medicineType, String cd);
}

