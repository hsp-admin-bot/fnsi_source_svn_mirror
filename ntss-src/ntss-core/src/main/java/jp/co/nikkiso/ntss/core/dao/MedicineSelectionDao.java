package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MedicineSelection;
import jp.co.nikkiso.ntss.core.entity.SysGenericMedicineSelection;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

@ConfigAutowireable
@Dao
public interface MedicineSelectionDao {

    @Select
        // mod FNSI5516-処方薬剤選択画面の表示が遅い 周 start
        //List<MedicineSelection> search(Integer classCd, String medicineName, String facilityCd, String genericName,Long patId);
    List<MedicineSelection> search(Integer classCd, String medicineName, String facilityCd, String genericName,
                                   Long patId, long offset, int limit);
    // mod FNSI5516-処方薬剤選択画面の表示が遅い 周 end

    @Select
    List<MedicineSelection> selectByFacilityCdJoinMstSelector(String facilityCd, Long patId);

    @Select
    List<SysGenericMedicineSelection> searchSysGenericMedicine(Long patId);
}
