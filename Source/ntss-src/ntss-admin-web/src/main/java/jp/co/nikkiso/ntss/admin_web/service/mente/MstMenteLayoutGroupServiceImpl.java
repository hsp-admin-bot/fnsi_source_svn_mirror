package jp.co.nikkiso.ntss.admin_web.service.mente;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import tools.jackson.databind.ObjectMapper;
import tools.jackson.core.type.TypeReference;
import jp.co.nikkiso.ntss.core.dao.MstMainteLayoutHstDao;
import jp.co.nikkiso.ntss.core.entity.MstMainteLayoutHst;
import jp.co.nikkiso.ntss.core.entity.MstMenteLayoutGroupByMachineType;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.core.dao.MstMenteLayoutDao;
import jp.co.nikkiso.ntss.core.dao.MstMenteLayoutGroupDao;
import jp.co.nikkiso.ntss.core.entity.MstMenteLayout;
import jp.co.nikkiso.ntss.core.entity.MstMenteLayoutGroup;

/**
 * 検査レイアウトグループのService実装クラス.
 */
@Service
public class MstMenteLayoutGroupServiceImpl implements MstMenteLayoutGroupService {

  /**
   * 検査レイアウトグループDaoインタフェース.
   */
  @Autowired
  MstMenteLayoutGroupDao mstMenteLayoutGroupDao;

  /**
   * 検査レイアウトDaoインタフェース.
   */
  @Autowired
  MstMenteLayoutDao mstMenteLayoutDao;
  // add  吉 start
  @Autowired
  MstMainteLayoutHstDao mstMainteLayoutHstDao;
  // add  吉 start
  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstMenteLayoutGroup> getAllLayoutGroup(String facilityCd) throws Exception{
    List<MstMenteLayoutGroup> layoutGroups = mstMenteLayoutGroupDao.selectAll(facilityCd);
    List<MstMenteLayoutGroup> layoutGroupresult = new ArrayList<>();
    ObjectMapper mapper = new ObjectMapper();
    for (MstMenteLayoutGroup mstMenteLayoutGroup : layoutGroups) {
      List<Long> listLayoutIds = mapper.readValue(mstMenteLayoutGroup.getLayoutList(), new TypeReference<List<Long>>() {
      });
      List<MstMenteLayout> listLayout = mstMenteLayoutDao.selectLayoutsByIdList(listLayoutIds);
      if(listLayout != null && listLayout.size() != 0){
        layoutGroupresult.add(mstMenteLayoutGroup);
      }
    }
      return layoutGroupresult;
  }
  //add 吉 start
  @Override
  public Map<String,Object> getAllLayout(String facilityCd) throws Exception{
    Map<String,Object> map =new HashMap<String,Object>();
    List<MstMenteLayout> listLayout = mstMenteLayoutDao.selectLayoutByClass(facilityCd,"2");
    map.put("1",listLayout);
    List<MstMainteLayoutHst> listLayoutHst = mstMainteLayoutHstDao.selectLayoutHstByClass(facilityCd,"2");
    map.put("2",listLayoutHst);
    return map;
  }
  //add 吉 end
    //add FNSI-8013 定期点検でマスタで設定した機種に該当しない定期点検が作成できる 2022/10/27　周安寧 start
  @Override
  public List<MstMenteLayoutGroupByMachineType> getAllLayoutGroupByMachineType(String facilityCd) throws Exception{
    return mstMenteLayoutDao.selectLayoutGroupByMachineType(facilityCd);
  }
    //add FNSI-8013 定期点検でマスタで設定した機種に該当しない定期点検が作成できる 2022/10/27　周安寧 end
}
