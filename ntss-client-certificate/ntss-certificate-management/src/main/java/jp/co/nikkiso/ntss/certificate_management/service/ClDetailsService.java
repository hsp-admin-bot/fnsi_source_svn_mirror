package jp.co.nikkiso.ntss.certificate_management.service;

import java.sql.Timestamp;
import java.util.List;

import jp.co.nikkiso.ntss.core.dto.ClDetail.ClDetails;
import jp.co.nikkiso.ntss.core.entity.ClDetail;
import jp.co.nikkiso.ntss.core.dto.ClDetail.ClDetailsDownload;

public interface ClDetailsService {

    /**
	 * クライアント証明書を挿入
     * @param passwordCl 証明書のパスワード.
     * @param facilityCd 施設コード.
     * @param manyFacilityCd 複数施設コード.
     * @param latestIssuedUser 最後に発行されたユーザー.
     * @param regDate 登録日.
     * @param upDate 更新日.
     * @throws Exception
	 */
    //mod FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start
//    void insertCl(String passwordCl, Timestamp publicTime, int maxDownload, int curDownload,
//            String facilityCd, String latestIssuedUser, Timestamp regDate, Timestamp upDate) throws Exception;
    void insertCl(String passwordCl, String facilityCd, String manyFacilityCd, String manyFacilityName, String latestIssuedUser, Timestamp regDate, Timestamp upDate) throws Exception;
     //mod FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start
    /**
     * 施設コード別の証明書を選択
     * @param facilityCd 施設コード.
     * @return クライアントの詳細
     * @throws Exception
     */
    ClDetail selectCertificateByFacilityCd(String facilityCd) throws Exception;

    /**
     * 名前付きファシリティコードによる証明書の選択
     * @param facilityCd 施設コード.
     * @return クライアント詳細ダウンロード
     * @throws Exception
     */
    List<ClDetailsDownload> selectClCertificateByFacilityCdWithName(String facilityCd) throws Exception;

    /**
     * 更新証明書
     * @param passwordCl 証明書のパスワード.
     * @param facilityCd 施設コード.
     * @param latestIssuedUser 最後に発行されたユーザー.
     * @param upDate 更新日.
     * @throws Exception
     */
    //mod FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start
    //void updateCl(String passwordCl, Timestamp publicTime, int maxDownload, String facilityCd, String latestIssuedUser, Timestamp upDate)
            //throws Exception;
//    void updateCl(String passwordCl,String facilityCd, String latestIssuedUser, Timestamp upDate)
//      throws Exception;
    //mod FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start

//    /**
//     * 証明書の更新パスワードなし
//     * @param publicTime 公開時間.
//     * @param maxDownload 最大ダウンロード.
//     * @param facilityCd 施設コード.
//     * @param latestIssuedUser 最後に発行されたユーザー.
//     * @param upDate 更新日.
//     * @throws Exception
//     */
//    void updateClNoPassword(Timestamp publicTime, int maxDownload, String facilityCd, String latestIssuedUser, Timestamp upDate)
//            throws Exception;

//    /**
//     * 現在のダウンロードを更新
//     * @param facilityCd 施設コード.
//     * @param curDownload 現在のダウンロード.
//     * @param upDate 更新日.
//     * @throws Exception
//     */
//    void updateCurDownload(String facilityCd, int curDownload, Timestamp upDate) throws Exception;
    //add FNSI-【1006】最新の改修対象一覧.NO50を追加 周安寧 start
    /**
     * クライアント証明書を挿入
     * @param facilityCd 施設コード.
     * @throws Exception
     */
    void certificateDisable(String facilityCdClient, String manyFacilityCdClient, String id) throws Exception;

    /**
     * 更新証明書
     * @param facilityCd 施設コード.
     * @param upDate 更新日.
     * @throws Exception
     */
    void deleteCl(String facilityCd, Integer clCertificateId, Timestamp upDate)
      throws Exception;

    /**
     * 施設コード別のCL証明書発行一覧画面
     * @param facilityCd 施設コード.
     * @return クライアントの詳細
     * @throws Exception
     */
    List<ClDetails> selectAllCertificatesByFacilityCd(String facilityCd) throws Exception;
    //add FNSI-【1006】最新の改修対象一覧.NO50を追加 周安寧 end

    // add FNSI-44480修正 解 start
    String getDownloadServer() throws Exception;
    // add FNSI-44480修正 解 end
}
