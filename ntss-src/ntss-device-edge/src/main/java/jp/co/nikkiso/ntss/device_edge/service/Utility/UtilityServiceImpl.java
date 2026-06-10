package jp.co.nikkiso.ntss.device_edge.service.Utility;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import jp.co.nikkiso.ntss.core.dao.Db6FunctionDao;

@Service
public class UtilityServiceImpl implements UtilityService {

  @Autowired
  private Db6FunctionDao db6FunctionDao;

  /**
   * {@inheritDoc}
   */
  @Override
  public String personalInfoEncrypto(String text) {
    if (StringUtils.isEmpty(text)) {
      return "";
    }
    // TODO: Java暗号化が実装できたらそっちに差し替えを行う。
    // いまは暗号化のためにDB6のファンクションを呼び出している。
    return db6FunctionDao.personalInfoEncrypto(text);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public String personalInfoDecrypto(String text) {
    if (StringUtils.isEmpty(text)) {
      return "";
    }
    // TODO: Java復号が実装できたらそっちに差し替えを行う。
    // いまは復号のためにDB6のファンクションを呼び出している。
    return db6FunctionDao.personalInfoDecrypto(text);
  }

}
