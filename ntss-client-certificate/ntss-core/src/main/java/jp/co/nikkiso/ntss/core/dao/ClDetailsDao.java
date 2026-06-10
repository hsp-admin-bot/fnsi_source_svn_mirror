package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.dto.ClDetail.ClDetails;
import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.core.config.ConfigAutowireableCertificateDb;

import jp.co.nikkiso.ntss.core.entity.ClDetail;
import org.seasar.doma.jdbc.SqlLogType;

@ConfigAutowireableCertificateDb
@Dao
public interface ClDetailsDao {

    @Insert(sqlFile = true)
      //mod FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start
    //int insertCl(String passwordCl, Timestamp expiredDate, int maxDownload, int curDownload,
            //String facilityCd, String latestIssuedUser, Timestamp regDate, Timestamp upDate);
    int insertCl(String passwordCl, String facilityCd, String manyFacilityCd, String manyFacilityName, String latestIssuedUser, Timestamp regDate, Timestamp upDate);
     //mod FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start

    // ntss-certificate-download の証明書マージ機能専用 INSERT
    // （is_merge_issued='1' を設定し、fileRandSuffix でファイル名の重複を回避する）
    @Insert(sqlFile = true)
    int insertClMerge(String passwordCl, String facilityCd, String manyFacilityCd, String manyFacilityName, String latestIssuedUser, Timestamp regDate, Timestamp upDate, String fileRandSuffix);

    // clCertificateId による1件取得（ファイル読み取り時の file_rand_suffix 参照に使用）
    @Select
    ClDetail selectById(Integer clCertificateId);
    @Select
    List<ClDetail> selectClCertificateByFacilityCd(String facilityCd);

    @Select
    ClDetail selectClCertificateByFacilityCdOnly(String facilityCd);

    @Select
    ClDetail selectNotDeteteClCertificateByFacilityCd(String facilityCd);

    @Select
    List<ClDetail> selectAllCertificates();

    @Update(sqlFile = true)
      //mod FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start
    //int updateCl(String passwordCl, Timestamp expiredDate, int maxDownload, String facilityCd, String latestIssuedUser, Timestamp upDate);
    int updateCl(String passwordCl, String facilityCd, String latestIssuedUser, Timestamp upDate);
    //mod FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start
    @Update(sqlFile = true)
    int updateClNoPassword(Timestamp expiredDate, int maxDownload, String facilityCd, String latestIssuedUser, Timestamp upDate);

    @Update(sqlFile = true)
    //mod FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
    //int updateCurDownload(String facilityCd, int curDownload, Timestamp upDate);
    int updateCurDownload(int clCertificateId,  Timestamp upDate);
    //mod FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
    //add FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start
    @Update(sqlFile = true)
    int deleteClDetails(String facilityCd, Integer clCertificateId, Timestamp upDate);

    @Select
    List<ClDetails> selectAllCertificatesByFacilityCd(String facilityCd);
    //add FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start

    // add #7831 「ログにPWが出力されている」について、対応する。 鄧シン start
    @Select(sqlLog = SqlLogType.NONE)
    List<String> selectPasswordEncrypt(String passwordCl);
    // add #7831 「ログにPWが出力されている」について、対応する。 鄧シン end

}
