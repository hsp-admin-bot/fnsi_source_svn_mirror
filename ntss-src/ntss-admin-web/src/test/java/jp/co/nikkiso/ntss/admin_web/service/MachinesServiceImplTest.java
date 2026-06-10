package jp.co.nikkiso.ntss.admin_web.service;

import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.notNullValue;
import static org.junit.Assert.assertThat;
import static org.mockito.BDDMockito.given;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.junit4.SpringRunner;

import jp.co.nikkiso.ntss.admin_web.response.MachinesResponse;
import jp.co.nikkiso.ntss.admin_web.service.machines.MachinesService;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.entity.custom.Machine;

/**
 * MachineServiceImplのテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
public class MachinesServiceImplTest {

  /**
   * テストクラス.
   */
  @Autowired
  private MachinesService target;

  /**
   * 装置状態管理DaoのMockBean.
   */
  @MockBean
  private MntMachineStateDao mntMachineStateDao;

  /**
   * getMachines()の検証.
   * <p>
   * 条件：施設に紐づく装置なし
   * 結果：空のリストが設定されたResponseが返却されること
   * <p>
   */
  @Test
  public void test_getMachines_正常_取得結果0件() {

    // 事前準備
    List<Machine> machines = Collections.emptyList();

    // Mock化
    given(mntMachineStateDao.selectMachinesByFacilityCd(anyString())).willReturn(machines);

    // 実行
    MachinesResponse results = target.createMachinesResponse("aaa", true);

    // 検証
    verify(mntMachineStateDao, times(1)).selectMachinesByFacilityCd("aaa");
    assertThat(results, notNullValue());
    assertThat(results.machines, is(Collections.emptyList()));

  }

  /**
   * getMachines()の検証.
   * <p>
   * 条件：施設に紐づく装置が1件存在
   * 結果：装置1件のリストが設定されたResponseが返却されること
   * <p>
   */
  @Test
  public void test_getMachines_正常_取得結果1件() {

    // 事前準備
    Machine machine = new Machine() {
      {
        setFacilityName("テスト施設");
        setFacilityCd("000001");
        setMachineTypeCd("001");
        setMachineType("テスト型式");
        setMachineSerial("00000001");
        setModel("001");
        setMachineName("テスト装置");
        setBedName("テストベッド");
        setProcessState("01");
        setMNoticeCnt(0);
        setPreventiveMainteCnt(0);
        setIsPreventiveMainte(0);
        setColorFlg(0);
        setComFormatCd("A");
        setComType(1);
        setDeviceEdgeNo(1);
        setIsFtp("0");
        setServiceSupportCnt(0);
        setVersion("1");
      }
    };
    List<Machine> machines = Arrays.asList(machine);


    // Mock化
    given(mntMachineStateDao.selectMachinesByFacilityCd(anyString())).willReturn(machines);

    // 実行
    MachinesResponse results = target.createMachinesResponse("000001", true);

    // 検証
    verify(mntMachineStateDao, times(1)).selectMachinesByFacilityCd("000001");
    assertThat(results, notNullValue());
    assertThat(results.machines, hasSize(1));
    assertThat(results.machines.get(0).getFacilityName(), is("テスト施設"));
    assertThat(results.machines.get(0).getFacilityCd(), is("000001"));
    assertThat(results.machines.get(0).getMachineTypeCd(), is("001"));
    assertThat(results.machines.get(0).getMachineType(), is("テスト型式"));
    assertThat(results.machines.get(0).getMachineSerial(), is("00000001"));
    assertThat(results.machines.get(0).getModel(), is("001"));
    assertThat(results.machines.get(0).getMachineName(), is("テスト装置"));
    assertThat(results.machines.get(0).getBedName(), is("テストベッド"));
    assertThat(results.machines.get(0).getProcessState(), is("01"));
    assertThat(results.machines.get(0).getMNoticeCnt(), is(0));
    assertThat(results.machines.get(0).getPreventiveMainteCnt(), is(0));
    assertThat(results.machines.get(0).getIsPreventiveMainte(), is(0));
    assertThat(results.machines.get(0).getColorFlg(), is(0));
    assertThat(results.machines.get(0).getComFormatCd(), is("A"));
    assertThat(results.machines.get(0).getComType(), is(1));
    assertThat(results.machines.get(0).getDeviceEdgeNo(), is(1));
    assertThat(results.machines.get(0).getIsFtp(), is("0"));
    assertThat(results.machines.get(0).getVersion(), is("1"));
  }

  /**
   * getMachines()の検証.
   * <p>
   * 条件：施設に紐づく装置が2件存在
   * 結果：装置2件のリストが設定されたResponseが返却されること
   * <p>
   */
  @Test
  public void test_getMachines_正常_取得結果2件() {

    // 事前準備
    List<Machine> machines = Arrays.asList(
      new Machine() {
        {
          setFacilityName("テスト施設");
          setFacilityCd("000001");
          setMachineTypeCd("001");
          setMachineType("テスト型式");
          setMachineSerial("00000001");
          setModel("001");
          setMachineName("テスト装置");
          setBedName("テストベッド");
          setProcessState("01");
          setMNoticeCnt(0);
          setPreventiveMainteCnt(0);
          setIsPreventiveMainte(0);
          setColorFlg(0);
          setComFormatCd("A");
          setComType(1);
          setDeviceEdgeNo(1);
          setIsFtp("0");
          setServiceSupportCnt(0);
          setVersion("1");
        }
      },
      new Machine() {
        {
          setFacilityName("テスト施設");
          setFacilityCd("000001");
          setMachineTypeCd("002");
          setMachineType("テスト型式2");
          setMachineSerial("00000002");
          setModel("002");
          setMachineName("テスト装置2");
          setBedName("テストベッド2");
          setProcessState("02");
          setMNoticeCnt(1);
          setPreventiveMainteCnt(1);
          setIsPreventiveMainte(1);
          setColorFlg(1);
          setComFormatCd("I");
          setComType(2);
          setDeviceEdgeNo(2);
          setIsFtp("1");
          setServiceSupportCnt(0);
          setVersion("2");
        }
      }
    );


    // Mock化
    given(mntMachineStateDao.selectMachinesByFacilityCd(anyString())).willReturn(machines);

    // 実行
    MachinesResponse results = target.createMachinesResponse("000001", true);

    // 検証
    verify(mntMachineStateDao, times(1)).selectMachinesByFacilityCd("000001");
    assertThat(results, notNullValue());
    assertThat(results.machines, hasSize(machines.size()));
    for (int i = 0; i < machines.size(); i++) {
      Machine machine = results.machines.get(i);
      assertThat(machine.getFacilityName(), is(machines.get(i).getFacilityName()));
      assertThat(machine.getFacilityCd(), is(machines.get(i).getFacilityCd()));
      assertThat(machine.getMachineTypeCd(), is(machines.get(i).getMachineTypeCd()));
      assertThat(machine.getMachineType(), is(machines.get(i).getMachineType()));
      assertThat(machine.getMachineSerial(), is(machines.get(i).getMachineSerial()));
      assertThat(machine.getModel(), is(machines.get(i).getModel()));
      assertThat(machine.getMachineName(), is(machines.get(i).getMachineName()));
      assertThat(machine.getBedName(), is(machines.get(i).getBedName()));
      assertThat(machine.getProcessState(), is(machines.get(i).getProcessState()));
      assertThat(machine.getMNoticeCnt(), is(machines.get(i).getMNoticeCnt()));
      assertThat(machine.getPreventiveMainteCnt(), is(machines.get(i).getPreventiveMainteCnt()));
      assertThat(machine.getIsPreventiveMainte(), is(machines.get(i).getIsPreventiveMainte()));
      assertThat(machine.getColorFlg(), is(machines.get(i).getColorFlg()));
      assertThat(machine.getComFormatCd(), is(machines.get(i).getComFormatCd()));
      assertThat(machine.getComType(), is(machines.get(i).getComType()));
      assertThat(machine.getDeviceEdgeNo(), is(machines.get(i).getDeviceEdgeNo()));
      assertThat(machine.getIsFtp(), is(machines.get(i).getIsFtp()));
    }

  }
}
