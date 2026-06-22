package jp.co.nikkiso.ntss.certificate_management.service;

import java.util.List;
import java.sql.Timestamp;

import jp.co.nikkiso.ntss.core.dto.ClFacility.ClFacilityInfo;
import jp.co.nikkiso.ntss.core.entity.ClFacility;
import jp.co.nikkiso.ntss.certificate_management.response.clFacility.ResponseClFacilitySetting;

public interface ClFacilityService {

    /**
     * 更新機能
     * @param facilityCd 施設コード.
     * @param facilityPassword 施設パスワード.
     * @param upDate 更新日.
     * @throws Exception
     */
    void updateFacility(String facilityCd, String facilityName, String facilityPassword, Timestamp upDate) throws Exception;

    /**
     * すべての施設を選択
     *  @param OrderKey 並べ替えキー.
     * @return 施設情報一覧
     * @throws Exception
     */
    //mod FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start
    //List<ClFacilityInfo> selectAllFacility() throws Exception;
    List<ClFacilityInfo> selectAllFacility(String OrderKey) throws Exception;
    //mod FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end
    /**
     * 挿入機能
     * @param facilityCd 施設コード.
     * @param facilityPassword 施設パスワード.
     * @param attemptFail ログインに失敗した回数.
     * @param regDate 登録日.
     * @throws Exception
     */
    void insertFacility(String facilityCd, String facilityName, String facilityPassword, int attemptFail, Timestamp regDate)
            throws Exception;

    /**
     * 施設コードで選択
     * @param facilityCd 施設コード.
     * @return クライアント施設.
     * @throws Exception
     */
    ClFacility selectByFacilityCd(String facilityCd) throws Exception;

    /**
     * サインインの更新に失敗しました
     * @param facilityCd 施設コード.
     * @param facilityName 施設名.
     * @param attemptFail ログインに失敗した回数.
     * @throws Exception
     */
    void updateAttemptFail(String facilityCd, String facilityName, int attemptFail) throws Exception;

    /**
     * 施設設定の取得
     * @return 施設設置.
     * @throws Exception
     */
    ResponseClFacilitySetting getFacilitySetting() throws Exception;

}
