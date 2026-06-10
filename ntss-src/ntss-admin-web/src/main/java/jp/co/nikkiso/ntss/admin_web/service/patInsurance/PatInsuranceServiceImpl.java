package jp.co.nikkiso.ntss.admin_web.service.patInsurance;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.FlagType;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.PatInsuranceClass;
import jp.co.nikkiso.ntss.core.entity.custom.PatInsuranceName;
import jp.co.nikkiso.ntss.core.entity.custom.InsuInfo;
import jp.co.nikkiso.ntss.core.dao.OrdPrescriptionDao;
import jp.co.nikkiso.ntss.core.dao.PatInsuranceDao;
import jp.co.nikkiso.ntss.core.entity.OrdPrescription;
import jp.co.nikkiso.ntss.core.entity.PatInsurance;

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class PatInsuranceServiceImpl implements PatInsuranceService {
    @Autowired
    private PatInsuranceDao patInsuranceDao;
    
    @Autowired
    private OrdPrescriptionDao ordPrescriptionDao;
    
    @Override
    public List<PatInsurance> getListPatInsuranceById(Long patId) {
        return patInsuranceDao.getListPatInsuranceById(patId);
    };

    /**
     * {@inheritDoc}
     */
    @Override
    public List<PatInsuranceName> getListPatInsuranceNameByIdAndCd(Long patId, String facilityCd, Long ordPrescriptionNo) {
      OrdPrescription ordPrescription = ordPrescriptionDao.selectByOrdPrescriptionNo(ordPrescriptionNo);
      List<PatInsuranceName> result = new ArrayList<>();
      if(ordPrescription != null && FlagType.FLAG_ON.equals(ordPrescription.getIssueState())) {
    	  PatInsuranceName insu = patInsuranceDao.getPatInsuranceNameById(ordPrescriptionNo);
    	  result.add(insu);
      }else {
    	  result = patInsuranceDao.getListPatInsuranceNameByIdAndCd(patId, facilityCd, PatInsuranceClass.OWN_EXPENSE_CLASS);
      }
      return result;
    }

    @Override
    public InsuInfo getInsuInfoByCd(Long insuranceCd) {
      return patInsuranceDao.getInsuInfoByCd(insuranceCd);
    }
}
