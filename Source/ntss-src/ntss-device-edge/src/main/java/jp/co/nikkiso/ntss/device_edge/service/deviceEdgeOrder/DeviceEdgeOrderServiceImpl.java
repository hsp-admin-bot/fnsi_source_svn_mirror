package jp.co.nikkiso.ntss.device_edge.service.deviceEdgeOrder;

import java.util.List;
import java.util.Objects;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.device_edge.request.deviceEdgeOrder.DeviceEdgeOrderRequest;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.entity.MstMachine;

@Service
public class DeviceEdgeOrderServiceImpl implements DeviceEdgeOrderService {

  @Autowired
  private MstMachineDao mstMachineDao;

  /**
   * {@inheritDoc}
   */
  @Override
  public DeviceEdgeOrderRequest findMissingData(DeviceEdgeOrderRequest request) {
    if (request.getMachineNo() == null) {
      // 装置番号の取得
      List<MstMachine> machines = null;
      if (request.getOrdNo() != null) {
        // オーダー番号が指定されていればmst_machineを取得して施設コードを取得
        machines = mstMachineDao.selectByOrdNoRst(request.getOrdNo());
        if (machines.size() == 0) {
          machines = mstMachineDao.selectByOrdNoInd(request.getOrdNo());
        }
      }
      if (machines.size() > 0) {
        MstMachine machine = machines.get(0);
        request.setMachineNo(machine.getMachineNo());
        if (request.getFacilityCd() == null || Objects.equals(request.getFacilityCd(), "")) {
          request.setFacilityCd(machine.getFacilityCd());
        }
        if (request.getDeviceEdgeNo() == null) {
          request.setDeviceEdgeNo(machine.getDeviceEdgeNo());
        }
      }
    }
    if (request.getFacilityCd() == null || Objects.equals(request.getFacilityCd(), "")
        || request.getDeviceEdgeNo() == null) {
      // 施設コードの取得
      List<MstMachine> machines = null;
      MstMachine machine = null;
      if (request.getMachineNo() != null) {
        // 装置番号が指定されていればmst_machineから施設コードを取得
        machine = mstMachineDao.selectByMachineNo(request.getMachineNo());
      } else if (request.getOrdNo() != null) {
        // オーダー番号が指定されていればmst_machineを取得して施設コードを取得
        machines = mstMachineDao.selectByOrdNoRst(request.getOrdNo());
        if (machines.size() == 0) {
          machines = mstMachineDao.selectByOrdNoInd(request.getOrdNo());
        }
        if (machines.size() > 0) {
          machine = machines.get(0);
        }
      }
      if (machine != null) {
        if (request.getFacilityCd() == null || Objects.equals(request.getFacilityCd(), "")) {
          request.setFacilityCd(machine.getFacilityCd());
        }
        if (request.getDeviceEdgeNo() == null) {
          request.setDeviceEdgeNo(machine.getDeviceEdgeNo());
        }
      }
    }
    return request;
  }

}
