package jp.co.nikkiso.ntss.core.dao;

import java.sql.Timestamp;
import java.util.List;
import java.util.Map;

import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;

import jp.co.nikkiso.ntss.core.config.ConfigAutowireablePersonalDb;
import jp.co.nikkiso.ntss.core.entity.OrdPersonalPrescription;

@ConfigAutowireablePersonalDb
@Dao
public interface OrdPersonalPrescriptionDao {

    @Insert(sqlFile = true)
    int insert(OrdPersonalPrescription ordPersonalPrescription);

    @Update(sqlFile = true)
    int update(OrdPersonalPrescription ordPersonalPrescription);

    @Update(sqlFile = true)
    int delete(Long ordPrescriptionNo, Timestamp upDate);

    @Select
    OrdPersonalPrescription selectByOrdPrescriptionNo(Long ordPrescriptionNo);

    @Update(sqlFile = true)
    int updatePrescriptionInsuDr(List<Long> ordPrescriptionNoList, Long insuDrId, String insuDrName, Timestamp upDate, String selectedPreDoctor, String facilityCd);

    // add #10988 データ項目「処方.処方箋情報.QRコード」を追加　V1.1A 吉 start
    @Select
    List<Map<String,Object>> selectByOrdPrescriptionNoForcyou(Long ordPrescriptionNo);
    // add #10988 データ項目「処方.処方箋情報.QRコード」を追加　V1.1A 吉 end
}
