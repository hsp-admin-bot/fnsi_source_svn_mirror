package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import jp.co.nikkiso.ntss.core.config.ConfigAutowireableCertificateDb;

import jp.co.nikkiso.ntss.core.entity.ClFacility;
import java.sql.Timestamp;
@ConfigAutowireableCertificateDb
@Dao
public interface ClFacilityDao {

    @Update(sqlFile = true)
      //mod FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start
    //int updateFacility(String facilityCd, String facilityName, String facilityPassword, Timestamp upDate);
    int updateFacility(String facilityCd, String facilityName, String facilityPassword, Timestamp upDate, int isProvisional);
    //mod FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end

    @Select
    ClFacility selectByFacilityCd(String facilityCd);

    @Insert(sqlFile = true)
      //mod FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start
    //int insertFacility(String facilityCd,  String facilityName, String facilityPassword, int attemptFail, Timestamp regDate);
    int insertFacility(String facilityCd,  String facilityName, String facilityPassword, int attemptFail, Timestamp regDate, int isProvisional);
     //mod FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end
    @Select
    List<ClFacility> selectAllFacility();

    @Update(sqlFile = true)
    int updateAttemptFail(String facilityCd, String facilityName, int attemptFail);

    @Select
    String selectNameByCd(String facilityCd);

    //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
    @Update(sqlFile = true)
    int updateProvisional(String facilityCd, int Provisional, String hashFacilityPassword, Timestamp upDate);

    @Update(sqlFile = true)
    int deleteClFacility(String facilityCd, Timestamp upDate);
    //add FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start
}
