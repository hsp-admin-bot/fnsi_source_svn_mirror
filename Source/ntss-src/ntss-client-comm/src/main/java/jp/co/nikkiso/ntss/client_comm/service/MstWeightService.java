package jp.co.nikkiso.ntss.client_comm.service;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MstWeight;
import jp.co.nikkiso.ntss.core.entity.MstWeightScale;

public interface MstWeightService {

  List<MstWeight> mstWeightSelectByFacilityCd(String facilityCd);
  MstWeight mstWeightSelectByScaleCd(Long weightCd);
  MstWeight mstWeightSelectByFacilityCdWeightNo(String facilityCd, int weightNo);

  int mstWeightInsert(MstWeight param);
  int mstWeightUpdate(MstWeight param);

  int mstWeightUpdateCheckContent(Long weightCd, String checkContent);
  int mstWeightUpdatePrintSetting(Long weightCd, String printSetting);
  int mstWeightUpdateColorSetting(Long weightCd, String colorSetting);
  int mstWeightUpdateAudioSetting(Long weightCd, String audioSetting);

  MstWeightScale mstWeightScaleSelectByFacility(String facilityCd);
  int mstWeightScaleInsert(MstWeightScale param);
  int mstWeightScaleUpdate(MstWeightScale param);
}
