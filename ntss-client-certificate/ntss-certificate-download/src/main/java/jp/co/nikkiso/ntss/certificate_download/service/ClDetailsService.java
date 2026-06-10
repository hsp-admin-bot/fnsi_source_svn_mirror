package jp.co.nikkiso.ntss.certificate_download.service;

import java.sql.Timestamp;
import java.util.List;

import jp.co.nikkiso.ntss.core.entity.ClDetail;
import jp.co.nikkiso.ntss.core.dto.ClDetail.ClDetailsDownload;

public interface ClDetailsService {

    /**
     * 施設コード別の証明書を選択
     * @param facilityCd 施設コード.
     * @return クライアントの詳細
     * @throws Exception
     */
    List<ClDetail> selectCertificateByFacilityCd(String facilityCd) throws Exception;

    /**
     * 名前付きファシリティコードによる証明書の選択
     * @param facilityCd 施設コード.
     * @return クライアント詳細ダウンロード
     * @throws Exception
     */
    List<ClDetailsDownload> selectClCertificateByFacilityCdWithName(String facilityCd) throws Exception;

    /**
     * 名前付きファシリティコードによる証明書の選択
     * @param facilityCd 施設コード.
     * @return クライアント詳細ダウンロード
     * @throws Exception
     */
    ClDetailsDownload selectClCertificateByFacilityCdWithNameOnly(String facilityCd) throws Exception;

    /**
     * 現在のダウンロードを更新
     * @param facilityCd 施設コード.
     * @param curDownload 現在のダウンロード.
     * @param upDate 更新日.
     * @throws Exception
     */
   //mod FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
    //void updateCurDownload(String facilityCd, int curDownload, Timestamp upDate) throws Exception;
    void updateCurDownload(int ClCertificateId ,String facilityCd, int curDownload, Timestamp upDate) throws Exception;
   //mod FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
}
