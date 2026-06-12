package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstPatSearchDetail;

@ConfigAutowireable
@Dao
public interface MstPatSearchDetailDao {

    /**
     * 追加.
     * 
     * @param mstPatSearchDetail 患者メモクラス
     * @return 作成されるレコードの数
     */
    @Insert(sqlFile = true)
    int insert(MstPatSearchDetail mstPatSearchDetail);
    
    /**
     * 更新 .
     * 
     * @param mstPatSearchDetail 患者メモクラス
     * @return 作成されるレコードの数
     */
    @Update(sqlFile = true)
    int updateBySearchCd(MstPatSearchDetail mstPatSearchDetail);

    /**
     * 検索.
     * 
     * @param userId 利用者ID
     * @param facilityCd 施設コード
     * @return 作成されるレコードの数
     */
    @Select
    List<MstPatSearchDetail> selectByUserIdAndFacilityCd(Long userId, String facilityCd);

    // #11205 -ペンテスト2－4認可制御の不備  add 20260420 start
    /**
     * 詳細患者検索コードで1件取得.
     *
     * @param searchCd 詳細患者検索コード
     * @return 詳細患者検索エンティティ
     */
    @Select
    MstPatSearchDetail selectBySearchCd(Long searchCd);
    // #11205 -ペンテスト2－4認可制御の不備  add 20260420 end

    /**
     * 削除.
     *
     * @param searchCd 詳細患者検索コード
     * @return 作成されるレコードの数
     */
    @Delete(sqlFile = true)
    int delete(Long searchCd);
    
    /**
     * mst_pat_search_detail.search_cdの次のシーケンス
     */
    @Select
    Long selectNextSeqSearchCd();
}
