package jp.co.nikkiso.ntss.core.dao;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

/**
 * データ収集管理テーブルのDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MntGatheringManageDao {

    /**
     * ユーザーIDと施設コードと対象日付に紐づくデータ収集ステータスを取得.
     * @param userId ユーザーID
     * @param facilityCd 施設コード
     * @param targetDate 対象日付(yyyyMMdd形式のString)
     * @return データ収集ステータス
     */
    @Select
    Integer selectByUserIdAndFacilityCdAndDate(Long userId, String facilityCd, String targetDate);

}
