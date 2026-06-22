package jp.co.nikkiso.ntss.device_edge.util.EquipmentInfo;

import java.util.HashMap;
import java.util.List;

/**
 *  医療材料情報サービス
 */
public interface EquipmentInfoService {

  /**
   * 医療材料情報のJSON文字列から医療材料情報クラスに展開します。
   * 【注意】指示の医療材料情報には各項目の名前や単位がないため、
   * 本クラスの各findメソッドを使用してマスタから引き当てて下さい。
   * @param equipmentInfoJsonString
   */
  public List<EquipmentInfo> createEquipmentInfoList(String equipmentInfoJsonString);

  /**
   * 格納されている医療材料分類コードをもとに医療材料分類マスタから医療材料分類名を検索し返します。
   * @param equipmentInfo
   * @return 医療材料分類名
   */
  String findClassName(EquipmentInfo equipmentInfo);

  /**
   * 格納されている医療材料分類コードをもとに医療材料分類マスタから医療材料分類名を検索し返します。
   * @param equipmentInfoList
   * @return 医療材料分類名をセットした医療材料情報リスト
   */
  List<EquipmentInfo> findClassName(List<EquipmentInfo> equipmentInfoList);

  /**
   * 格納されている医療材料コードをもとに医療材料マスタから医療材料名、省略医療材料名、単位を検索し返します。
   * 戻り値のキー：name, shortName, unit
   * @param equipmentInfo
   * @return 医療材料名、省略医療材料名、単位を格納した連想配列
   */
  HashMap<String, String> findEquipmentName(EquipmentInfo equipmentInfo);

  /**
   * 格納されている医療材料コードをもとに医療材料マスタから医療材料名、省略医療材料名、単位を検索し返します。
   * @param equipmentInfoList
   * @return 医療材料名、省略医療材料名、単位をセットした医療材料情報リスト
   */
  List<EquipmentInfo> findEquipmentName(List<EquipmentInfo> equipmentInfoList);

  /**
   * 格納されている指示者コードをもとに利用者マスタから姓・名を検索し返します。
   * 戻り値のキー：lastName, firstName
   * @param equipmentInfo
   * @return 指示者姓名を格納した連想配列
   */
  HashMap<String, String> findIndUserName(EquipmentInfo equipmentInfo);

  /**
   * 格納されている指示者コードをもとに利用者マスタから姓・名を検索し返します。
   * @param equipmentInfoList
   * @return 指示者姓名をセットした医療材料情報リスト
   */
  List<EquipmentInfo> findIndUserName(List<EquipmentInfo> equipmentInfoList);

  /**
   * 格納されている更新者コードをもとに利用者マスタから姓・名を検索し返します。
   * 戻り値のキー：lastName, firstName
   * @param equipmentInfo
   * @return 更新者姓名を格納した連想配列
   */
  HashMap<String, String> findUpdUserName(EquipmentInfo equipmentInfo);

  /**
   * 格納されている更新者コードをもとに利用者マスタから姓・名を検索し返します。
   * @param equipmentInfoList
   * @return 更新者姓名をセットした医療材料情報リスト
   */
  List<EquipmentInfo> findUpdUserName(List<EquipmentInfo> equipmentInfoList);

}
