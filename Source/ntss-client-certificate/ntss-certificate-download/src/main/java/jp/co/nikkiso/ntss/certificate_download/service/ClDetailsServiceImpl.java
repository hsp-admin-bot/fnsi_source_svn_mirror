package jp.co.nikkiso.ntss.certificate_download.service;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.core.dao.ClDetailsDao;
import jp.co.nikkiso.ntss.core.dto.ClDetail.ClDetailsDownload;
import jp.co.nikkiso.ntss.core.entity.ClDetail;
import jp.co.nikkiso.ntss.core.dao.ClFacilityDao;
import org.springframework.util.StringUtils;

@Service
public class ClDetailsServiceImpl implements ClDetailsService {

    // クライアント証明書（認証DB）Daoインターフェース。
    @Autowired
    ClDetailsDao clDetailsDao;

    // クライアント機能（DB）Daoインターフェース。
    @Autowired
    private ClFacilityDao clFacilityDao;

    @Override
    public List<ClDetail> selectCertificateByFacilityCd(String facilityCd) throws Exception {
        List<ClDetail> clDetails = clDetailsDao.selectClCertificateByFacilityCd(facilityCd);
      for (ClDetail clDetail: clDetails) {
        if(clDetail != null) {
          clDetail.setPasswordCl(null);
        }
      }

      return clDetails;
    }

    @Override
    public List<ClDetailsDownload> selectClCertificateByFacilityCdWithName(String facilityCd) throws Exception {
        String facilityName = clFacilityDao.selectNameByCd(facilityCd);
        List<ClDetail> clDetails = clDetailsDao.selectClCertificateByFacilityCd(facilityCd);
        List<ClDetailsDownload>  clDetailsDownloads = new ArrayList<ClDetailsDownload>();
        for (ClDetail clDetail: clDetails) {
          ClDetailsDownload clDetailsDownload = new ClDetailsDownload();
          if(clDetail != null) {
            if (StringUtils.isEmpty(clDetail.getManyFacilityCd())) {
              continue;
            }
            clDetailsDownload.setPasswordCl(null);
            clDetailsDownload.setExpiredDate(clDetail.getExpiredDate());
            clDetailsDownload.setMaxDownload(clDetail.getMaxDownload());
            clDetailsDownload.setCurDownload(clDetail.getCurDownload());
            clDetailsDownload.setFacilityCd(clDetail.getFacilityCd());
            //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
            clDetailsDownload.setClCertificateId(clDetail.getClCertificateId());
            //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
            clDetailsDownload.setFacilityName(facilityName);
            clDetailsDownload.setManyFacilityCd(clDetail.getManyFacilityCd());
            clDetailsDownload.setManyFacilityName(clDetail.getManyFacilityName());
          }
          clDetailsDownloads.add(clDetailsDownload);
        }

        return clDetailsDownloads;
    }

  @Override
  public ClDetailsDownload selectClCertificateByFacilityCdWithNameOnly(String facilityCd) throws Exception {
    String facilityName = clFacilityDao.selectNameByCd(facilityCd);
    ClDetail clDetail = clDetailsDao.selectClCertificateByFacilityCdOnly(facilityCd);

    ClDetailsDownload clDetailsDownload = new ClDetailsDownload();
    if(clDetail != null) {
      clDetailsDownload.setPasswordCl(null);
      clDetailsDownload.setExpiredDate(clDetail.getExpiredDate());
      clDetailsDownload.setMaxDownload(clDetail.getMaxDownload());
      clDetailsDownload.setCurDownload(clDetail.getCurDownload());
      clDetailsDownload.setFacilityCd(clDetail.getFacilityCd());
      //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
      clDetailsDownload.setClCertificateId(clDetail.getClCertificateId());
      //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
      clDetailsDownload.setFacilityName(facilityName);
      clDetailsDownload.setManyFacilityName(clDetail.getManyFacilityName());
    }

    return clDetailsDownload;
  }
   //mod FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
    @Override
//    public void updateCurDownload(String facilityCd, int curDownload, Timestamp upDate) throws Exception {
//        clDetailsDao.updateCurDownload(facilityCd, curDownload, upDate);
//    }
    public void updateCurDownload(int ClCertificateId, String facilityCd, int curDownload, Timestamp upDate) throws Exception {
      clDetailsDao.updateCurDownload(ClCertificateId, upDate);
    }
   //mod FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
}
