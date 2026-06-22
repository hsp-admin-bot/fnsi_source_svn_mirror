package jp.co.nikkiso.ntss.monitoring.service;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MstBioMoniFramePattern;
import jp.co.nikkiso.ntss.core.entity.custom.MstBioMoniFramePatternWithDefine;

/**
 * サービス
 */
public interface MstBioMoniFramePatternService {

  List<MstBioMoniFramePattern> select(String facility_cd);
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
  //MstBioMoniFramePattern selectByCtlCd(String facility_cd, int ctl_no);
  //String selectDefineInfo(String facility_cd, int ctl_no);
  //int delete(String facility_cd, int ctl_no);
  MstBioMoniFramePattern selectByCtlCd(String facility_cd, Long ctl_no);
  String selectDefineInfo(String facility_cd, Long ctl_no);
  int delete(String facility_cd, Long ctl_no);
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
  MstBioMoniFramePattern updatePattern(MstBioMoniFramePattern param);
  MstBioMoniFramePattern insertPattern(MstBioMoniFramePattern param);

  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
  //List<MstBioMoniFramePatternWithDefine> selectWithDefine(String facility_cd, int ctl_no);
  List<MstBioMoniFramePatternWithDefine> selectWithDefine(String facility_cd, Long ctl_no);
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
}
