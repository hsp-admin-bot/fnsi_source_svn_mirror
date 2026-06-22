package jp.co.nikkiso.ntss.admin_web.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.admin_web.response.MachineRecordResponse;
import jp.co.nikkiso.ntss.core.dao.MstMachineRecordDao;
import jp.co.nikkiso.ntss.core.entity.MstMachineRecord;

import static java.util.stream.Collectors.toList;

/**
 * 装置記録のService実装クラス.
 */
@Service
public class MachineRecordServiceImpl implements MachineRecordService {

  /**
   * 装置記録のDaoインターフェース.
   */
  @Autowired
  private MstMachineRecordDao mstMachineRecordDao;

  /**
   * {@inheritDoc}
   */
  @Override
  public MachineRecordResponse getAllMachineRecords(String facilityCd) {
    final List<MstMachineRecord> mstMachineRecords = mstMachineRecordDao.selectByFacilityCd(facilityCd);

    List<MachineRecordResponse.MachineRecord> machineRecords = mstMachineRecords.stream()
        .map(mstMachineRecord -> new MachineRecordResponse.MachineRecord(
            mstMachineRecord.getMachineRecordCd(),
            mstMachineRecord.getMachineRecordMessage(),
            mstMachineRecord.getIsDefault(),
            mstMachineRecord.getLogClass(),
            mstMachineRecord.getTargetModel()
          )
        )
        .collect(toList());

    return new MachineRecordResponse(machineRecords);
  }

}
