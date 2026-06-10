package jp.co.nikkiso.ntss.admin_web.service.sysMedicine;

import jp.co.nikkiso.ntss.core.dao.SysMedicineDao;
import jp.co.nikkiso.ntss.core.entity.SysMedicine;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 標準医薬品マスタのサービスクラス.
 */
@Service
public class SysMedicineServiceImpl implements SysMedicineService {

  /**
   * {@link SysMedicineDao}インタフェース.
   */
  @Autowired
  private SysMedicineDao sysMedicineDao;

  /**
   * {@inheritDoc}
   */
  @Override
  public List<SysMedicine> getSysMedicineAll() {
    return sysMedicineDao.selectAll();
  }

  /* add by zhaohan 2022-10-12 [7280] 標準医薬品マスタ検索を表示するのに時間がかかる。 --start */
  /**
   * {@inheritDoc}
   */
  @Override
  public List<SysMedicine> getSysMedicineByKeyword(String keyword, Integer offset) {
    return sysMedicineDao.selectSysMedicineByKeyword(keyword, offset);
  }
  /* add by zhaohan 2022-10-12 [7280] 標準医薬品マスタ検索を表示するのに時間がかかる。 --end */

  /**
   * {@inheritDoc}
   */
  @Override
  public SysMedicine getSysMedicineByStandardNo(String standardNo) {
    return sysMedicineDao.selectByStandardNo(standardNo);
  }

  // add redmine 6238 標準医薬品マスタでデータが表示されない 宋qy start
  /**
   * {@inheritDoc}
   */
  @Override
  public List<SysMedicine> getSysMedicineByLimitAndOffset(Integer limit, Integer offset, String keyword) {
    return sysMedicineDao.selectSysMedicineByLimitAndOffset(limit, offset, keyword);
  }
  // add redmine 6238 標準医薬品マスタでデータが表示されない 宋qy end

  // add #6930 標準医薬品マスタの抽出で追加読み込みが行われない 徐博 start
  @Override
  public String getTotal() {
    return sysMedicineDao.getTotal();
  }
  // add #6930 標準医薬品マスタの抽出で追加読み込みが行われない 徐博 end

  /***
   * 標準医薬品マスタ検索
   *
   * @param salesName 販売名
   * @return {@link SysMedicine}のリスト
   */
  @Override
  public List<SysMedicine> selectBySalesName(String salesName) {
    return sysMedicineDao.selectBySalesName(salesName);
  }
}
