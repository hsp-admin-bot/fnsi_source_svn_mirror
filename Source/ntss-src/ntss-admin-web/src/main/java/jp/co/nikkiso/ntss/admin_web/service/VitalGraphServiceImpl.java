package jp.co.nikkiso.ntss.admin_web.service;

import jp.co.nikkiso.ntss.admin_web.response.vital.VitalGraphDefineResponse;
import jp.co.nikkiso.ntss.core.dao.MstVitalGraphDao;
import jp.co.nikkiso.ntss.core.dao.SysMasterDefineDao;
import jp.co.nikkiso.ntss.core.entity.MstVitalGraph;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

import static java.util.Collections.emptyList;

/**
 * モニタグラフ用のService実装クラス.
 */
@Service
public class VitalGraphServiceImpl implements VitalGraphService {

  /**
   * モニタグラフのDaoインターフェース.
   */
  @Autowired
  private MstVitalGraphDao mstVitalGraphDao;

  /**
   * 並び順管理マスタのDaoインタフェース.
   */
  @Autowired
  private SysMasterDefineDao sysMasterDefineDao;

  /**
   * {@inheritDoc}
   */
  @Override
  public List<VitalGraphDefineResponse> createVitalGraphDefineResponse(String facilityCd) {
    final List<MstVitalGraph> vitalGraphs = mstVitalGraphDao
        .selectByFacilityCd(facilityCd);

    if (vitalGraphs.isEmpty()) {
      return emptyList();
    }
    final List<VitalGraphDefineResponse> result = new ArrayList<>();
    if (vitalGraphs != null && vitalGraphs.size() > 0) {
      for (MstVitalGraph mstVitalGraph : vitalGraphs) {
        VitalGraphDefineResponse response
          = new VitalGraphDefineResponse(
          mstVitalGraph.getVitalGraphCd(),
          mstVitalGraph.getVitalGraphName(),
          mstVitalGraph.getVitalLineColor(),
          mstVitalGraph.getVitalLineSize(),
          mstVitalGraph.getVitalLineTypeValue(),
          mstVitalGraph.getVitalPointColor(),
          mstVitalGraph.getVitalPointSize(),
          mstVitalGraph.getVitalPointTypeValue()
        );
        result.add(response);
      }
    }

    return result;
  }

}
