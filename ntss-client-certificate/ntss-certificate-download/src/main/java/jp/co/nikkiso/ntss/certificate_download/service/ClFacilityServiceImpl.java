package jp.co.nikkiso.ntss.certificate_download.service;

import jp.co.nikkiso.ntss.core.dao.ClFacilityDao;
import jp.co.nikkiso.ntss.core.entity.ClFacility;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.certificate_download.response.clFacility.ResponseClFacilitySetting;

import java.sql.Timestamp;

@Service
public class ClFacilityServiceImpl implements ClFacilityService {

    @Autowired
    public PasswordEncoder passwordEncoder;

    // 施設の最小パスワード
    @Value("${ntss.cl-certificate.cl-facility.password-min}")
    private int passwordMin;

    // 施設のロック数
    @Value("${ntss.cl-certificate.cl-facility.lock-count}")
    private int lockCount;
    //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
    @Autowired
    private ClFacilityDao clFacilityDao;
    //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
    @Override
    public ResponseClFacilitySetting getFacilitySetting() throws Exception {
        ResponseClFacilitySetting result = new ResponseClFacilitySetting();
        result.setPasswordMin(passwordMin);
        result.setLockCount(lockCount);
        return result;
    }
    //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
    @Override
    public ClFacility getProvisional(String facilityCd) throws Exception {
      ClFacility clFacility = clFacilityDao.selectByFacilityCd(facilityCd);
      return clFacility;
    }

    @Override
    public void updateProvisional(String facilityCd, int Provisional, String hashFacilityPassword, Timestamp upDate) throws Exception {
      clFacilityDao.updateProvisional(facilityCd, Provisional, hashFacilityPassword, upDate);

    }
    /**
     * {@inheritDoc}
     */
    public Boolean isMatchCurrentPassword(String CurrentPassword, String facilityCd) {
      ClFacility clFacility = clFacilityDao.selectByFacilityCd(facilityCd);
      return passwordEncoder.matches(CurrentPassword, clFacility.getFacilityPassword());
    }

  /**
   *
   * @param facilityCd
   * @return
   */
    public String getFacilityName(String facilityCd) {
      return clFacilityDao.selectNameByCd(facilityCd);
    }

  //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
}
