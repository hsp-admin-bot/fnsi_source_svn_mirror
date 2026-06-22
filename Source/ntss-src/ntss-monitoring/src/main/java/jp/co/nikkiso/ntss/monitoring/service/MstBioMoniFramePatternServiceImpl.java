package jp.co.nikkiso.ntss.monitoring.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.core.dao.MstBioMoniFramePatternDao;
import jp.co.nikkiso.ntss.core.entity.MstBioMoniFramePattern;
import jp.co.nikkiso.ntss.core.entity.custom.MstBioMoniFramePatternWithDefine;

@Service
public class MstBioMoniFramePatternServiceImpl implements MstBioMoniFramePatternService {

  @Autowired
  private MstBioMoniFramePatternDao mstBioMoniFramePatternDao;

  @Override
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
  //public String selectDefineInfo(String facility_cd, int ctl_no) {
  public String selectDefineInfo(String facility_cd, Long ctl_no) {
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
    return mstBioMoniFramePatternDao.selectDefineInfo(facility_cd, Math.toIntExact(ctl_no));
  }

  @Override
  public List<MstBioMoniFramePattern> select(String facility_cd) {
    return mstBioMoniFramePatternDao.selectAll(facility_cd);
  }

  @Override
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
  //public MstBioMoniFramePattern selectByCtlCd(String facility_cd, int ctl_no) {
  public MstBioMoniFramePattern selectByCtlCd(String facility_cd, Long ctl_no) {
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
    return mstBioMoniFramePatternDao.selectByCtlNo(facility_cd, Math.toIntExact(ctl_no));
  }

  @Override
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
  //public int delete(String facility_cd, int ctl_no) {
  public int delete(String facility_cd, Long ctl_no) {
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
    MstBioMoniFramePattern ptn = mstBioMoniFramePatternDao.selectByCtlNo(facility_cd, Math.toIntExact(ctl_no));
    if(ptn != null) {
      return mstBioMoniFramePatternDao.delete(ptn);
    }
    return 0;
  }

  @Override
  public MstBioMoniFramePattern updatePattern(MstBioMoniFramePattern param) {
    if (mstBioMoniFramePatternDao.updatePattern(param) == 1) {
      return param;
    }
    return null;
  }

  @Override
  public MstBioMoniFramePattern insertPattern(MstBioMoniFramePattern param) {
    if (mstBioMoniFramePatternDao.insertPattern(param) == 1) {
      return param;
    }
    return null;

  }

  @Override
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
  //public List<MstBioMoniFramePatternWithDefine> selectWithDefine(String facility_cd, int ctl_no) {
  public List<MstBioMoniFramePatternWithDefine> selectWithDefine(String facility_cd, Long ctl_no) {
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
    return mstBioMoniFramePatternDao.selectWithFrameDefine(facility_cd, Math.toIntExact(ctl_no));
  }

}
