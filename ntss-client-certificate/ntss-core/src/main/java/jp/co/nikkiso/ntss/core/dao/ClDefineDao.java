package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.config.ConfigAutowireableCertificateDb;
import jp.co.nikkiso.ntss.core.entity.ClDefine;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;

@ConfigAutowireableCertificateDb
@Dao
public interface ClDefineDao {

    @Select
    ClDefine selectClDefine(int ctlNO);

}
