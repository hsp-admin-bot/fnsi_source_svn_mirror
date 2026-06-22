package jp.co.nikkiso.ntss.device_edge.service.Utility;

import jp.co.nikkiso.ntss.core.entity.MstDialyzer;
import jp.co.nikkiso.ntss.core.entity.MstEquipment;
import jp.co.nikkiso.ntss.core.entity.MstMedicine;
import jp.co.nikkiso.ntss.core.entity.MstMedicineMix;

import java.util.List;

public interface MedicineAndEquipmentUtilService {

  record MstEquipAndDialyzer(List<MstEquipment> mstEquipments, List<MstDialyzer> mstDialyzers){}
  record MstMedicineAndMix(List<MstMedicine> mstMedicines, List<MstMedicineMix> mstMedicineMixes){}

  /**
   * 医療材料指示/実績の施設設定に則ったソートを行う
   * @param facilityCd 施設コード
   * @param equipInfo 医療材料指示/実績のjson文字列
   * @return ソート後のJSON文字列
   */
  String getSortedEquipInfo(String facilityCd, String equipInfo);

  /**
   * 投与薬剤指示/実績の施設設定に則ったソートを行う
   * @param facilityCd 施設コード
   * @param mediInfo 投与薬剤指示/実績のjson文字列
   * @return ソート後のJSON文字列
   */
  String getSortedMedicineInfo(String facilityCd, String mediInfo);
  /**
   * 医療材料指示/実績の関連する医療材料マスタ、ダイアライザマスタを取得する
   * @param equipInfo 医療材料指示/実績のjson文字列
   * @return 関連する医療材料マスタ、ダイアライザマスタ
   */
  MstEquipAndDialyzer getMstEquipAndDialyzers(String equipInfo);

  /**
   * 投与薬剤指示/実績の関連する薬剤マスタ、調整薬剤マスタを取得する
   * @param mediInfo 投与薬剤指示/実績のjson文字列
   * @return 関連する薬剤マスタ、調整薬剤マスタ
   */
  MstMedicineAndMix getMstMedicineAndMixes(String mediInfo);
}
