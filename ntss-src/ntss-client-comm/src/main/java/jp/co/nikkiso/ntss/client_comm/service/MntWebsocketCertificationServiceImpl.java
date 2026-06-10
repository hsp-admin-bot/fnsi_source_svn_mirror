package jp.co.nikkiso.ntss.client_comm.service;

import java.sql.Timestamp;
import java.time.Clock;
import java.time.LocalDateTime;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.entity.MntWebsocketCertification;
import jp.co.nikkiso.ntss.core.dao.MntWebsocketCertificationDao;


/**
 * WebSocket認証コードサービス
 */
@Service
public class MntWebsocketCertificationServiceImpl implements MntWebsocketCertificationService{

  @Autowired
  private MntWebsocketCertificationDao mntWebsocketCertificationDao;

  @Autowired
  private Clock time;


  /**
   * 指定した認証コードの情報を取得する
   *
   * @param certificationCd　認証コード
   *
   * @return 認証コード情報
   */
  @Override
  public List<MntWebsocketCertification> findByCertification(String certificationCd) {
    List<MntWebsocketCertification> mntWebsocketCertification = mntWebsocketCertificationDao.selectByCertification(certificationCd);
    return mntWebsocketCertification;
  }


  /**
   * 指定した認証コード、施設コードで認証コード情報を登録する
   *
   * @param certificationCd　認証コード
   * @param facilityCd 施設コード
   *
   * @return 登録件数
   */
  @Override
  @Transactional
  public int insert(String certificationCd, String facilityCd) {
    // 接続情報作成
    MntWebsocketCertification mntWebsocketCertification = new MntWebsocketCertification();
    mntWebsocketCertification.setCertificationCd(certificationCd);
    mntWebsocketCertification.setFacilityCd(facilityCd);

    return mntWebsocketCertificationDao.insert(mntWebsocketCertification);
  }

  /**
   * 指定した認証コード情報を削除する
   *
   * @param certificationCd 認証コード
   *
   * @return 削除件数
   */
  @Override
  @Transactional
  public int delete(String certificationCd) {
    // 接続情報作成
    MntWebsocketCertification mntWebsocketCertification = new MntWebsocketCertification();
    mntWebsocketCertification.setCertificationCd(certificationCd);

    return mntWebsocketCertificationDao.delete(mntWebsocketCertification);
  }

  /**
   * 現在日時から指定分より前の認証コード情報を削除する
   *
   * @param addMinute 加算分数
   *
   * @return 削除件数
   */
  @Override
  @Transactional
  public int deleteAfterMinute(int addMinite) {
    int ret = 0;
    LocalDateTime now = LocalDateTime.now(time);
    Timestamp regDate = Timestamp.valueOf(now.plusMinutes(addMinite));

    // 接続情報作成
    MntWebsocketCertification mntWebsocketCertification = new MntWebsocketCertification();
    mntWebsocketCertification.setRegDate( regDate );

    // 削除対象件数判定
    if( 0 < mntWebsocketCertificationDao.selectCountByRegDate(mntWebsocketCertification)) {
      // 削除対象がある場合は削除
      ret = mntWebsocketCertificationDao.deleteRegDate(mntWebsocketCertification);
    }

    return ret;
  }

  /**
   * システム日時を取得.
   *
   * @return システム日時
   */
  public Clock getTime() {
    return time;
  }
}
