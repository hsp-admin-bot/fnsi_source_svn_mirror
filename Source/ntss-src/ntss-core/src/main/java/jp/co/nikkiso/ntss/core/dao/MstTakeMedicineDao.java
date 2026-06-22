package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstTakeMedicine;

@ConfigAutowireable
@Dao
public interface MstTakeMedicineDao {

    /**
     * 用法・用語マスタ情報選択する.
     * 
     * @param listClass リスト種別
     * @param facilityCd 施設コード
     * @return 処方
     */
    @Select
    public List<MstTakeMedicine> selectByListClass(String listClass, String facilityCd);

    /**
     * 新しい施設のマスタデータ登録
     * 
     * @param facilityCd 施設コード
     * @return 挿入件数
     */
    @Insert(sqlFile = true)
    public int insertMstDataForNewFacility(String facilityCd);
}
