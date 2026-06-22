package jp.co.nikkiso.ntss.certificate_management.service;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import static java.util.Collections.emptyList;
import java.sql.Timestamp;

import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Value;

import jp.co.nikkiso.ntss.certificate_management.response.clFacility.ResponseClFacilitySetting;
import jp.co.nikkiso.ntss.core.dao.ClDetailsDao;
import jp.co.nikkiso.ntss.core.dao.ClFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;
import jp.co.nikkiso.ntss.core.dto.ClFacility.ClFacilityInfo;
import jp.co.nikkiso.ntss.core.entity.ClDetail;
import jp.co.nikkiso.ntss.core.entity.ClFacility;
import jp.co.nikkiso.ntss.core.entity.MstFacility;

@Service
public class ClFacilityServiceImpl implements ClFacilityService {

    // クライアント機能（DB）Daoインターフェース。
    @Autowired
    private ClFacilityDao clFacilityDao;

    // クライアント証明書（DB）Daoインターフェース。
    @Autowired
    private ClDetailsDao clDetailsDao;

    // マスター機能（DB）Daoインターフェース。
    @Autowired
    private MstFacilityDao mstFacilityDao;

    @Autowired
    public PasswordEncoder passwordEncoder;

    // 施設の最小パスワード
    @Value("${ntss.cl-certificate.cl-facility.password-min}")
    private int passwordMin;

    // 施設のロック数
    @Value("${ntss.cl-certificate.cl-facility.lock-count}")
    private int lockCount;

    @Override
    public void updateFacility(String facilityCd, String facilityName, String facilityPassword, Timestamp upDate) throws Exception {
        String hashFacilityPassword = passwordEncoder.encode(facilityPassword);
        if (hashFacilityPassword != null) {
            //mod FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start
            int isProvisional = CoreConstant.ProvisionalStatus.PROVISIONAL;
            //clFacilityDao.updateFacility(facilityCd, facilityName, hashFacilityPassword, upDate)
            clFacilityDao.updateFacility(facilityCd, facilityName, hashFacilityPassword, upDate, isProvisional);
          //mod FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end
        }
    }

    @Override
    public void insertFacility(String facilityCd, String facilityName, String facilityPassword, int attemptFail, Timestamp regDate)
            throws Exception {
        String hashFacilityPassword = passwordEncoder.encode(facilityPassword);
        //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start
        int isProvisional = CoreConstant.ProvisionalStatus.PROVISIONAL;
        //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end
        if (hashFacilityPassword != null) {
            //mod FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start
            //clFacilityDao.insertFacility(facilityCd, facilityName, hashFacilityPassword, attemptFail, regDate);
              clFacilityDao.insertFacility(facilityCd, facilityName, hashFacilityPassword, attemptFail, regDate, isProvisional);
            //mod FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start
        } else {
            hashFacilityPassword = "";
            //mod FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start
            //clFacilityDao.insertFacility(facilityCd, facilityName, "", attemptFail, regDate);
            clFacilityDao.insertFacility(facilityCd, facilityName, "", attemptFail, regDate, isProvisional);
            //mod FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end
        }
    }

    @Override
    public ClFacility selectByFacilityCd(String clFacility) throws Exception {
        ClFacility result = clFacilityDao.selectByFacilityCd(clFacility);
        return result;
    }

    @Override
    public void updateAttemptFail(String facilityCd, String facilityName, int attemptFail) throws Exception {
        clFacilityDao.updateAttemptFail(facilityCd,facilityName, attemptFail);

    }

    @Override
    //mod FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start
    //public List<ClFacilityInfo> selectAllFacility() throws Exception {
    public List<ClFacilityInfo> selectAllFacility(String OrderKey) throws Exception {
      //mod FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end
        List<ClFacilityInfo> clFacilitiesInfo = new ArrayList<ClFacilityInfo>();
        List<ClFacility> clFacilities = clFacilityDao.selectAllFacility();
        List<ClDetail> clDetails = clDetailsDao.selectAllCertificates();
        List<MstFacility> mstFacilities = mstFacilityDao.selectAllOrderBy("order by prefectures_cd");
        for (MstFacility mstFacility : mstFacilities) {
            ClFacilityInfo clFacilityInfo = new ClFacilityInfo();
            clFacilityInfo.setFacilityCd(mstFacility.getFacilityCd());
            clFacilityInfo.setFacilityName(mstFacility.getFacilityName());
            clFacilityInfo.setPrefecturesCd(mstFacility.getPrefecturesCd());
            for (ClDetail clDetail : clDetails) {
                if(clDetail.getFacilityCd().equals(mstFacility.getFacilityCd())) {
                    //del FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start
//                    clFacilityInfo.setMaxDownload(clDetail.getMaxDownload());
//                    clFacilityInfo.setCurDownload(clDetail.getCurDownload());
                    //del FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start
                    clFacilityInfo.setLatestIssuedUser(clDetail.getLatestIssuedUser());
                    clFacilityInfo.setFacilityCount(clDetail.getFacilityCount());
                    //del FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start
                    //clFacilityInfo.setExpiredDate(clDetail.getExpiredDate());
                    //del FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 end
                }
            }
            for (ClFacility clFacility : clFacilities) {
                if(clFacility.getFacilityCd().equals(mstFacility.getFacilityCd())) {
                    clFacilityInfo.setAttemptFail(clFacility.getAttemptFail());
                }
            }
            clFacilitiesInfo.add(clFacilityInfo);
        }
        //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start
        switch (OrderKey) {
          case "facilityName":
            clFacilitiesInfo.sort(Comparator.comparing(ClFacilityInfo::getFacilityName,Comparator.nullsFirst(String::compareTo)));
            break;
          case "prefecturesCd":
            clFacilitiesInfo.sort(Comparator.comparing(ClFacilityInfo::getPrefecturesCd,Comparator.nullsFirst(String::compareTo)));
            break;
          case "facilityCd":
            clFacilitiesInfo.sort(Comparator.comparing(ClFacilityInfo::getFacilityCd,Comparator.nullsFirst(String::compareTo)));
            break;
          case "expiredDate":
            clFacilitiesInfo.sort(Comparator.comparing(ClFacilityInfo::getExpiredDate,Comparator.nullsFirst(Timestamp::compareTo)));
            break;
          case "latestIssuedUser":
            clFacilitiesInfo.sort(Comparator.comparing(ClFacilityInfo::getLatestIssuedUser,Comparator.nullsFirst(String::compareTo)));
            break;
          default:
            break;
        }
        //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end
        if (clFacilitiesInfo.isEmpty()) {
            return emptyList();
        }
        return clFacilitiesInfo;
    }

    @Override
    public ResponseClFacilitySetting getFacilitySetting() throws Exception {
        ResponseClFacilitySetting result = new ResponseClFacilitySetting();
        result.setPasswordMin(passwordMin);
        result.setLockCount(lockCount);
        return result;
    }

}
