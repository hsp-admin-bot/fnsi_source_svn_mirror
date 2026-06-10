package jp.co.nikkiso.ntss.admin_web.service.exceptionPeriod;

import jp.co.nikkiso.ntss.admin_web.response.exceptionPeriod.ExceptionPeriodResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.core.dao.ExceptionPeriodDao;
import jp.co.nikkiso.ntss.core.entity.ExceptionPeriod;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
public class ExceptionPeriodServicelmpl implements ExceptionPeriodService {

  @Autowired
  private ExceptionPeriodDao exceptionPeriodDao;

  @Override
  public List<ExceptionPeriodResponse> selectOrdExceptionPeriod (String facilityCd, Long patId) {
    List<ExceptionPeriodResponse> res = new ArrayList<>();
    try {
      List<ExceptionPeriod> ExceptionPeriodList = exceptionPeriodDao.selectOrdExceptionPeriod(facilityCd, patId);
      if (ExceptionPeriodList != null && ExceptionPeriodList.size() > 0) {

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        SimpleDateFormat ymd = new SimpleDateFormat("yyyyMMdd");

        for (int i = 0; i < ExceptionPeriodList.size(); i++) {

          ExceptionPeriodResponse exceptionPeriodResponse = new ExceptionPeriodResponse();

          ExceptionPeriod exceptionPeriod = ExceptionPeriodList.get(i);
          try {

            exceptionPeriodResponse.setPatId(exceptionPeriod.getPatId());

            exceptionPeriodResponse.setFacilityCd(exceptionPeriod.getFacilityCd());

            exceptionPeriodResponse.setExceptionPeriodNo(exceptionPeriod.getExceptionPeriodNo());
            // 除外期間開始日
            exceptionPeriodResponse.setExceptionPeriodFrom(sdf.format(ymd.parse(exceptionPeriod.getExceptionPeriodFrom())));
            // 除外期間終了日
            exceptionPeriodResponse.setExceptionPeriodTo(sdf.format(ymd.parse(exceptionPeriod.getExceptionPeriodTo())));
          } catch (ParseException e) {
            e.getErrorOffset();
          }
          res.add(exceptionPeriodResponse);
        }
      }
    } catch (Exception ex) {
      // ロールバック実行
      throw new RuntimeException(ex.getMessage());
    }
    return res;
  }

  @Override
  @Transactional
  public int updateOrdExceptionPeriod (List<ExceptionPeriodResponse> exceptionPeriodList, NtssUser ntssUser) {

    Timestamp nowDate = null;
    nowDate = Timestamp.valueOf(LocalDateTime.now());
    int res = 0;
    for (int i = 0; i < exceptionPeriodList.size(); i++) {
      ExceptionPeriod cond = new ExceptionPeriod();

      ExceptionPeriodResponse exceptionPeriod = exceptionPeriodList.get(i);
      cond.setExceptionPeriodNo(exceptionPeriod.getExceptionPeriodNo());
      cond.setFacilityCd(exceptionPeriod.getFacilityCd());
      cond.setPatId(exceptionPeriod.getPatId());
      cond.setRegStaffId(ntssUser.getUserId());
      cond.setUpdStaffId(ntssUser.getUserId());

      if (exceptionPeriod.getExceptionPeriodNo() == null
        && !StringUtils.isEmpty(exceptionPeriod.getExceptionPeriodFrom())
        && !StringUtils.isEmpty(exceptionPeriod.getExceptionPeriodTo())
        && !"1".equals(exceptionPeriod.getIsDel())) {

        cond.setExceptionPeriodFrom(exceptionPeriod.getExceptionPeriodFrom().replace("-",""));
        cond.setExceptionPeriodTo(exceptionPeriod.getExceptionPeriodTo().replace("-",""));
        cond.setRegDate(nowDate);

        res = exceptionPeriodDao.insert(cond);
      } else if (exceptionPeriod.getExceptionPeriodNo() != null
        && !StringUtils.isEmpty(exceptionPeriod.getExceptionPeriodFrom())
        && !StringUtils.isEmpty(exceptionPeriod.getExceptionPeriodTo())
        && !"1".equals(exceptionPeriod.getIsDel())) {

        cond.setExceptionPeriodFrom(exceptionPeriod.getExceptionPeriodFrom().replace("-",""));
        cond.setExceptionPeriodTo(exceptionPeriod.getExceptionPeriodTo().replace("-",""));
        cond.setUpDate(nowDate);

        res = exceptionPeriodDao.upDateOrdExceptionPeriod(exceptionPeriod.getExceptionPeriodNo(),
          exceptionPeriod.getExceptionPeriodFrom().replace("-",""),
          exceptionPeriod.getExceptionPeriodTo().replace("-",""),
          ntssUser.getUserId());
      } else if (exceptionPeriod.getExceptionPeriodNo() != null) {
        if ("1".equals(exceptionPeriod.getIsDel())) {
          res = exceptionPeriodDao.deleteOrdExceptionPeriod(exceptionPeriod.getExceptionPeriodNo());
        } else if (StringUtils.isEmpty(exceptionPeriod.getExceptionPeriodFrom()) || StringUtils.isEmpty(exceptionPeriod.getExceptionPeriodTo())) {
          res = exceptionPeriodDao.deleteOrdExceptionPeriod(exceptionPeriod.getExceptionPeriodNo());
        }
      }
    }
    return res;
  }
}
