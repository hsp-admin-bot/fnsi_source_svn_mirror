package jp.co.nikkiso.ntss.certificate_download.service;

import jp.co.nikkiso.ntss.certificate_download.response.clFacility.ResponseClFacilitySetting;
import jp.co.nikkiso.ntss.core.entity.ClFacility;

import java.sql.Timestamp;

public interface ClFacilityService {

    /**
     * 施設設定の取得
     * @return 施設設置.
     * @throws Exception
     */
    ResponseClFacilitySetting getFacilitySetting() throws Exception;

    //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
    /**
     * 仮登録フラグの取得
     * @return 仮登録フラグ.
     * @throws Exception
     */
    ClFacility getProvisional(String facilityCd) throws Exception;

    /**
     * 更新機能
     * @param facilityCd 施設コード.
     * @param Provisional 仮登録フラグ.
     * @param upDate 更新日.
     * @throws Exception
     */
    void updateProvisional(String facilityCd, int Provisional, String hashFacilityPassword ,Timestamp upDate) throws Exception;

    /**
     * 入力された「現在のパスワード」がDB上のパスワードと合っているか確認する.
     * @param CurrentPassword 更新件数
     * @param facilityCd 施設コード
     * @return 合っていればtrue
     */
    Boolean isMatchCurrentPassword(String CurrentPassword, String facilityCd);

    String getFacilityName(String facilityCd);

  //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
}
