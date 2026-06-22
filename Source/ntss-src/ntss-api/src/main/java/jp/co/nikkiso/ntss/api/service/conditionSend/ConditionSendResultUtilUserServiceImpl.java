package jp.co.nikkiso.ntss.api.service.conditionSend;

import jp.co.nikkiso.ntss.core.dao.DBAppWebAPIUserDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * 条件送信3011系のService実装クラス.
 */
@Service
public class ConditionSendResultUtilUserServiceImpl implements ConditionSendResultUtilUserService {

  /**
   * 条件送信画面系Dao.
   */
  @Autowired
  private DBAppWebAPIUserDao dBAppWebAPIUserDao;

  @Autowired
  private PatPersonalMainDao patPersonalMainDao;


  /**
   * 各名称取得用
   * @param ordNo オーダー番号
   * @return 名称
   * @throws Exception
   */
  public List<String[]> getUsersNames(
          List<String> facilityCdList,
          List<Long> userIdList,
          boolean cryptoFlag)
  {
    List<String[]> retList = new ArrayList<String[]>() ;

    List<Map<String,Object>> retListFromDB = dBAppWebAPIUserDao.selectNamesFromPatPersonalMain(facilityCdList, userIdList, cryptoFlag);

    for(int i = 0 ; i < retListFromDB.size() ; i++)
    {
      String[] retStrDim = new String[3] ;
      retStrDim[0] = String.valueOf(retListFromDB.get(i).get("user_id")) ;
      retStrDim[1] = (String)retListFromDB.get(i).get("user_last_name") ;
      retStrDim[2] = (String)retListFromDB.get(i).get("user_first_name") ;
      retList.add(retStrDim) ;
    }

    return retList ;
  }

  /*
   * 入外区分の取得
   * @param pat_id 患者ID
   * @return 入外区分
   */
  public Integer getInOutClassbyPatId(Long pat_id) {
    Integer ret = null ;

    List<Long> patIdList = new ArrayList<Long>() ;
    patIdList.add(pat_id) ;
    List<PatPersonalMain> list = patPersonalMainDao.selectByIdList(patIdList) ;

    if(null != list && 1 == list.size())
    {
      ret = list.get(0).getIn_out_class() ;
    }

    return ret ;
  }

}
