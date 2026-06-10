package jp.co.nikkiso.ntss.admin_web.service.bvms;

import java.sql.Timestamp;
import java.util.Calendar;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.FlagType;
import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.BVMSZipFileStructureDTO;
import jp.co.nikkiso.ntss.core.dao.MstBedDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.entity.MstBed;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import lombok.NonNull;

@Service
public class BVMSZipFileServiceImpl implements BVMSZipFileService {

    @Autowired
    private OrdMainDao ordMainDao;

    @Autowired
    private MstBedDao mstBedDao;

    @Autowired
    private MstMachineDao mstMachineDao;

    // {データ収集管理番号[可変長]}_{型式コード[3桁]}_{製造番号[7～8桁]}_{データ収集開始年月日[8桁]時分秒[6桁]}_FTP.zip
    @Override
    public BVMSZipFileStructureDTO buildZipFileStructureDTO(Long ordNo) {
        OrdMain ordMain = getOrdMain(ordNo);
		    //mod 8347【デグレ】????患者治療割り当てができない zhao start
		    //Integer rstBedCd = ordMain.getRstBedCd();
//        Integer rstBedCd = ordMain.getRstBedCd().intValue();
//        String treatDate = ordMain.getTreatDate();
//        MstMachine machine = getMachine(Long.valueOf(rstBedCd));
        String treatDate = ordMain.getTreatDate();
        MstMachine machine = getMachine(ordMain.getRstBedCd());
        //mod 8347【デグレ】????患者治療割り当てができない zhao end

        // 型式コード[3桁]
        String machineTypeCd = machine.getMachineTypeCd();
        // 製造番号[7～8桁 'mst_machine.com_format_cd' + 'mst_machine.machine_serial'
        String comFormatCd = machine.getComFormatCd();
        String machineSerial = machine.getMachineSerial();

        Timestamp rstStartDate = ordMain.getRstStartDate();
        Timestamp rstEndDate = ordMain.getRstEndDate();
        if(rstStartDate == null) {
            throw new NtssException("rstStartDate is null");
        }

        if(rstEndDate == null) {
            throw new NtssException("rstEndDate is null");
        }
        // データ収集開始年月日[8桁]
        String startTime = getHourMinuteSecond(rstStartDate);
        String endTime = getHourMinuteSecond(rstEndDate);


        BVMSZipFileStructureDTO dto = new BVMSZipFileStructureDTO();
        dto.setMachineTypeCd(machineTypeCd);
        dto.setComFormatCd(comFormatCd);
        dto.setMachineSerial(machineSerial);
        dto.setTreatDate(treatDate);
        dto.setEndTime(endTime);
        dto.setStartTime(startTime);
        return dto;
    }

    private String getHourMinuteSecond(Timestamp timestamp) {
        Calendar cal = Calendar.getInstance();
        cal.setTime(timestamp);
        int hour = cal.get(Calendar.HOUR_OF_DAY);
        int minute = cal.get(Calendar.MINUTE);
        int second = cal.get(Calendar.SECOND);
        return formatNumber(hour) + formatNumber(minute) + formatNumber(second);
    }

    @NonNull
    private OrdMain getOrdMain(Long ordNo) {
        OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
        if (ordMain == null) {
            throw new NtssException("システムで管理する一意なオーダ番号 : " + ordNo);
        }
        return ordMain;
    }

    @NonNull
    private MstMachine getMachine(Long rstBedCd) {
        MstBed bed = mstBedDao.selectByBedCd(rstBedCd, FlagType.FLAG_ON, FlagType.FLAG_OFF);
        if (bed == null) {
            throw new NtssException("ベッドコードが見つかりません : " + bed);
        }

        MstMachine machine = mstMachineDao.selectByMachineNo(bed.getMachineNo());
        if (machine == null) {
            throw new NtssException("装置番号かりません : " + bed.getMachineNo());
        }
        return machine;

    }

    private String formatNumber(int num) {
        return (num < 10 ? "0" : "") + num;
    }
}
