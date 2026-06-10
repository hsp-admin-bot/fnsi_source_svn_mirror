package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.MstMedicineSet;

@ConfigAutowireable
@Dao
public interface MstMedicineSetDao {
  @Select
  List<MstMedicineSet> selectAll(SelectOptions options, MstMedicineSet params);

  @Select
  List<MstMedicineSet> selectWithDeleted(SelectOptions options, MstMedicineSet params);

  /**
   * 指定した薬剤が含まれる薬剤セットリストを返却する
   * @param facilityCd
   * @param classCd (1：通常薬剤、2：調製薬剤)
   * @param medicineCdList
   * @return
   */
  @Select
  // mod FNSI-改修内容6618修正 xuty start
  // List<MstMedicineSet> selectByMedicineCdList(String facilityCd, Integer classCd, List<Integer> medicineCdList);
  List<MstMedicineSet> selectByMedicineCdList(String facilityCd, Integer classCd, List<String> medicineCdList);
  // mod FNSI-改修内容6618修正 xuty end
}
