package jp.co.nikkiso.ntss.device_edge.util.MedicineInfo;

import java.util.HashMap;
import java.util.List;

/**
 *  薬剤情報サービス
 */
public interface MedicineInfoService {

  /**
   * 薬剤情報のJSON文字列から薬剤情報クラスに展開します。
   * 【注意】指示の薬剤情報には各項目の名前や単位がないため、
   * 本クラスの各findメソッドを使用してマスタから引き当てて下さい。
   * @param medicineInfoJsonString
   */
  public List<MedicineInfo> createMedicineInfoList(String medicineInfoJsonString);

  /**
   * 格納されている薬剤分類コードをもとに薬剤分類マスタから薬剤分類名を検索し返します。
   * @param medicineInfo
   * @return 薬剤分類名
   */
  String findClassName(MedicineInfo medicineInfo);

  /**
   * 格納されている薬剤分類コードをもとに薬剤分類マスタから薬剤分類名を検索し返します。
   * @param medicineInfoList
   * @return 薬剤分類名をセットした薬剤情報リスト
   */
  List<MedicineInfo> findClassName(List<MedicineInfo> medicineInfoList);

  /**
   * 格納されている薬剤コードをもとに薬剤マスタから薬剤名、省略薬剤名、単位を検索し返します。
   * 戻り値のキー：name, shortName, unit
   * @param medicineInfo
   * @return 薬剤名、省略薬剤名、単位を格納した連想配列
   */
  HashMap<String, String> findMedicineName(MedicineInfo medicineInfo);

  /**
   * 格納されている薬剤コードをもとに薬剤マスタから薬剤名、省略薬剤名、単位を検索し返します。
   * @param medicineInfoList
   * @return 薬剤名、省略薬剤名、単位ををセットした薬剤情報リスト
   */
  List<MedicineInfo> findMedicineName(List<MedicineInfo> medicineInfoList);

  /**
   * 格納されている指示者コードをもとに利用者マスタから姓・名を検索し返します。
   * 戻り値のキー：lastName, firstName
   * @param medicineInfo
   * @return 指示者姓名を格納した連想配列
   */
  HashMap<String, String> findIndUserName(MedicineInfo medicineInfo);

  /**
   * 格納されている指示者コードをもとに利用者マスタから姓・名を検索し返します。
   * @param medicineInfoList
   * @return 指示者姓名をセットした薬剤情報リスト
   */
  List<MedicineInfo> findIndUserName(List<MedicineInfo> medicineInfoList);

  /**
   * 格納されている更新者コードをもとに利用者マスタから姓・名を検索し返します。
   * 戻り値のキー：lastName, firstName
   * @param medicineInfo
   * @return 更新者姓名を格納した連想配列
   */
  HashMap<String, String> findUpdUserName(MedicineInfo medicineInfo);

  /**
   * 格納されている更新者コードをもとに利用者マスタから姓・名を検索し返します。
   * @param medicineInfoList
   * @return 更新者姓名をセットした薬剤情報リスト
   */
  List<MedicineInfo> findUpdUserName(List<MedicineInfo> medicineInfoList);

}
