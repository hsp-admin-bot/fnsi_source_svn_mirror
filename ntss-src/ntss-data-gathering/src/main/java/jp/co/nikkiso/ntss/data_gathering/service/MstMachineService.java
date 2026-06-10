package jp.co.nikkiso.ntss.data_gathering.service;

import java.util.List;
import jp.co.nikkiso.ntss.data_gathering.entity.MstMachine;


public interface MstMachineService
{
	List<MstMachine> findById(String machineTypeCd, String machineSerial, String facilityCd, int deviceEdgeNo);
}
