package jp.co.nikkiso.ntss.admin_web.service.master.favoriteFacility;

import jp.co.nikkiso.ntss.core.dao.MstFavoriteFacilityDao;
import jp.co.nikkiso.ntss.core.entity.custom.MstFavoriteFacilityDataT;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.core.dao.SysFacilityDao;

import jp.co.nikkiso.ntss.core.entity.custom.SysFacilityData;

import java.util.Arrays;
import java.util.List;

@Service
public class MstFavoriteFacilityServiceImpl implements MstFavoriteFacilityService {

  /**
   * 全施設マスタのDaoインタフェース.
   */
  @Autowired
  private SysFacilityDao sysFacilityDao;

  @Autowired
  private MstFavoriteFacilityDao mstFavoriteFacilityDao;

  //add by ztc 2023-03-01 [Optimize runtime No.8372] --start /
  /**
   * {@inheritDoc}
   * 全施設マスタ一覧の取得 改ページの追加
   */
  @Override
  public List<SysFacilityData> getSysFacilityByLimitAndOffset(Integer limit, Integer offsetIer, String prefCd, String freeWord, String selectedInsCd){
    List<String> selectedInsCdList = Arrays.asList(selectedInsCd.split(","));
    return sysFacilityDao.selectJoinSysPrefByLimitAndOffset(limit, offsetIer, prefCd, freeWord, selectedInsCdList);
  }
  //add by ztc 2023-03-01 [Optimize runtime No.8372] --end /

  // add FNSI-よく使う施設の変更 関 start
  @Override
  public List<MstFavoriteFacilityDataT> getFacilityFavoriteFacility(String facilityCd) {
    return mstFavoriteFacilityDao.selectAllByFacilityCd(facilityCd);
  }
  // add FNSI-よく使う施設の変更 関 end

//
//  List<String> list = new ArrayList<>();
//// 假设 list 中包含需要排序的元素
//
//  String[] order = {"C", "B", "A"};  // 提供的元素顺序
//
//  Comparator<String> customComparator = new Comparator<String>() {
//    @Override
//    public int compare(String s1, String s2) {
//      int index1 = Arrays.asList(order).indexOf(s1);  // 获取 s1 在 order 中的索引
//      int index2 = Arrays.asList(order).indexOf(s2);  // 获取 s2 在 order 中的索引
//      return Integer.compare(index1, index2);  // 根据索引进行比较
//    }
//  };
//
//  // 使用方法引用定义自定义比较器
//  Comparator<String> comparator = customComparator::compare;
//
//// 使用自定义比较器进行排序
//Collections.sort(list, comparator);

}


