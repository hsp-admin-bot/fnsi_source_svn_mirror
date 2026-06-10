package jp.co.nikkiso.ntss.admin_web.service;

import jp.co.nikkiso.ntss.core.dao.SysMonitorItemDao;
import jp.co.nikkiso.ntss.core.entity.SysMonitorItem;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * モニタ項目のService実装クラス
 */
@Service
public class SysMonitorItemServiceImpl implements SysMonitorItemService {

  @Autowired
  private SysMonitorItemDao sysMonitorItemDao;

  /**
   * {@inheritDoc}
   */
  @Override
  public List<SysMonitorItem> getMonitorItemByMoniDataType(String moniDataType) {
    return sysMonitorItemDao.selectByMoniDataType(moniDataType);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<SysMonitorItem> getMonitorItemByMoniDataTypeAndClass(String moniDataType, String vitalMonitorClass) {
    return sysMonitorItemDao.selectByMoniDataTypeAndClass(moniDataType, vitalMonitorClass);
  }


  /**
   * {@inheritDoc}
   */
  @Override
  public List<SysMonitorItem> getMonitorItemByDefineConvItem() {
    return sysMonitorItemDao.selectByDefineConvItem();
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<SysMonitorItem> getMonitorItemAll() {
    return sysMonitorItemDao.selectAll();
  }


  /* ===== 2024-07-04 ADD #9312 Start ===== */
  //mod #12066 【横展開】酸素飽和度対応（コンバート） zrx start
//  @Override
//  public List<SysMonitorItem> getMonitorItemByItemCodes(List<String> itemCodes) {
//    if (CollectionUtils.isEmpty(itemCodes)) return null;
//    return this.sysMonitorItemDao.selectByMoniDataNoList(itemCodes);
//  }
//
//  @Override
//  public List<SysMonitorItem> getTreatmentGraphItems() {
//
//    return this.getMonitorItemByItemCodes(List.of("-2","-1","1","2","3","4","5","6","7","8","9","10","11"
//      ,"12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","32","33","34"
//      ,"35","36","37","38","39","40","41","42","43","44","45","46","47","48","49","50","51","54","55","56","57","58"
//      ,"59","60","61","62","63","64","65","66","67","68","69","70","71","72","73","74","75","76","77","78","79","80"
//      ,"81","85","86","88","90","91","92","93","94","95","96","97","98","100","101","102","103"));
//  }

  @Override
  public List<SysMonitorItem> getTreatmentGraphItems() {

    return this.sysMonitorItemDao.selectByMoniDataNoList();
  }
  //mod #12066 【横展開】酸素飽和度対応（コンバート） zrx end
  /* ===== 2024-07-04 ADD #9312 End ===== */

}
