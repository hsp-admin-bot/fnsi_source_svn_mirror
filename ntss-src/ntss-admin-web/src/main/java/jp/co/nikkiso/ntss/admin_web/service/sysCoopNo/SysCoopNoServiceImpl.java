package jp.co.nikkiso.ntss.admin_web.service.sysCoopNo;


import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.dao.SysCoopNoDao;
import jp.co.nikkiso.ntss.core.entity.SysCoopNo;


@Service
public class SysCoopNoServiceImpl implements SysCoopNoService {

    @Autowired
    SysCoopNoDao sysCoopNoDao;

    @Override
    /* FacilityCdによってSysCoopNoを選択します */
    public List<SysCoopNo> selectSysCoopNoByFacilityCd(String facilityCd) throws Exception {
        List<SysCoopNo> sysCoopNos = sysCoopNoDao.selectByFacilityCd(facilityCd);
        return sysCoopNos;
    }

    
    /* 保存 */
    @Override
    @Transactional
	public Boolean submit(SysCoopNo sysCoopNo, final Long userId) throws Exception{
        Boolean ret = true;

        SysCoopNo sysCoopNoCheck = sysCoopNoDao.selectByCtlNo(sysCoopNo.getCtlNo());
        if (sysCoopNoCheck == null) {
            sysCoopNo.setUserId(userId);
            sysCoopNoDao.insert(sysCoopNo);
        } 
        else {
            sysCoopNoDao.update(sysCoopNo);
        }

        return ret;
    }
}
