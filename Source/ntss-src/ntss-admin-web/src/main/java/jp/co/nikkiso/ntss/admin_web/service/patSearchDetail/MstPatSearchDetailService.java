package jp.co.nikkiso.ntss.admin_web.service.patSearchDetail;

import java.util.List;

import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.core.entity.MstPatSearchDetail;

public interface MstPatSearchDetailService {
    /**
     * 追加.
     * 
     * @param mstPatSearchDetail 詳細患者検索クラス
     * @return 作成されるレコードの数
     */
    Long create(MstPatSearchDetail mstPatSearchDetail);

    /**
     * 更新.
     * 
     * @param mstPatSearchDetail 詳細患者検索クラス
     * @return レコード数が更新されます
     */
    int update(MstPatSearchDetail mstPatSearchDetail);

    /**
     * 検索.
     * 
     * @param ntssUser NTSS認証ユーザー
     * @return 詳細患者検索クラスリスト
     */
    List<MstPatSearchDetail> get(NtssUser ntssUser);

    /**
     * 削除.
     * 
     * @param searchCd 詳細患者検索コード
     * @return 削除されたレコード数
     */
    int delete(Long searchCd);

}
