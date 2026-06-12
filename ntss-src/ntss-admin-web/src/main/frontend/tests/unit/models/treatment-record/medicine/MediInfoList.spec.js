import { MediInfo } from "@/models/treatment-record/medicine/MediInfo";
import { MediInfoList } from "@/models/treatment-record/medicine/MediInfoList";

describe("MediInfoList#toString", () => {
  test("no MediInfo", () => {
    // arrange
    const mediInfoList = new MediInfoList();

    // action
    const result = mediInfoList.toString();

    // assert
    // expect(result).toBe("[]");
  });

  test("a MediInfo", () => {
    // arrange
    const mediInfoList = new MediInfoList();
    mediInfoList.add(getMediInfo());
    const expected = "[{" +
      `"no":100` +
      `,"class_cd":101` +
      `,"class_name":"classA"` +
      `,"class_type":"classTypeA"` +
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //`,"medicine_type":"1"` +
      `,"medicine_type":1` +
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      `,"cd":1000` +
      `,"name":"medicineName"` +
      `,"short_name":"medicineShortName"` +
      `,"unit":"L"` +
      `,"amount":1` +
      `,"init_date":"2019-01-01T12:05:00+09:00"` +
      `,"date_interval":2` +
      `,"timing_cd":2000` +
      `,"timing_name":"timingA"` +
      `,"procedure_cd":3000` +
      `,"procedure_name":"pName"` +
      `,"comment":"comment1"` +
      `,"ind_user_id":4000` +
      `,"ind_user_last_name":"indLast"` +
      `,"ind_user_first_name":"indFirst"` +
      `,"upd_user_id":5000` +
      `,"upd_user_last_name":"updLast"` +
      `,"upd_user_first_name":"updFirst"` +
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //`,"input_class":"1"` +
      `,"input_class":1` +
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
      `,"is_editable":"1"` +
      `,"cop_order_no":null` +
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //`,"effect_flg":"0"` +
      `,"effect_flg":0` +
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
      `,"effect_date":"2019-01-01T12:00:00+09:00"` +
      `,"effect_user_id":6000` +
      `,"effect_user_last_name":"effectLast"` +
      `,"effect_user_first_name":"effectFirst"` +
    "}]";
    // action
    const result = mediInfoList.toString();

    // assert
    // expect(result).toBe(expected);
  });

  test("two MediInfo", () => {
    // arrange
    const mediInfoList = new MediInfoList();
    const mediInfo1 = getMediInfo();
    const mediInfo2 = getMediInfo();
    mediInfo2.cd = 1002;
    mediInfo2.name = "medicineName2";
    mediInfoList.addAll([mediInfo1, mediInfo2]);
    const expected = "[{" +
      `"no":100` +
      `,"class_cd":101` +
      `,"class_name":"classA"` +
      `,"class_type":"classTypeA"` +
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //`,"medicine_type":"1"` +
      `,"medicine_type":1` +
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
      `,"cd":1000` +
      `,"name":"medicineName"` +
      `,"short_name":"medicineShortName"` +
      `,"unit":"L"` +
      `,"amount":1` +
      `,"init_date":"2019-01-01T12:05:00+09:00"` +
      `,"date_interval":2` +
      `,"timing_cd":2000` +
      `,"timing_name":"timingA"` +
      `,"procedure_cd":3000` +
      `,"procedure_name":"pName"` +
      `,"comment":"comment1"` +
      `,"ind_user_id":4000` +
      `,"ind_user_last_name":"indLast"` +
      `,"ind_user_first_name":"indFirst"` +
      `,"upd_user_id":5000` +
      `,"upd_user_last_name":"updLast"` +
      `,"upd_user_first_name":"updFirst"` +
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //`,"input_class":"1"` +
      `,"input_class":1` +
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
      `,"is_editable":"1"` +
      `,"cop_order_no":null` +
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //`,"effect_flg":"0"` +
      `,"effect_flg":0` +
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
      `,"effect_date":"2019-01-01T12:00:00+09:00"` +
      `,"effect_user_id":6000` +
      `,"effect_user_last_name":"effectLast"` +
      `,"effect_user_first_name":"effectFirst"` +
    "}" +
    ",{" +
      `"no":100` +
      `,"class_cd":101` +
      `,"class_name":"classA"` +
      `,"class_type":"classTypeA"` +
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //`,"medicine_type":"1"` +
      `,"medicine_type":1` +
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
      `,"cd":1002` +
      `,"name":"medicineName2"` +
      `,"short_name":"medicineShortName"` +
      `,"unit":"L"` +
      `,"amount":1` +
      `,"init_date":"2019-01-01T12:05:00+09:00"` +
      `,"date_interval":2` +
      `,"timing_cd":2000` +
      `,"timing_name":"timingA"` +
      `,"procedure_cd":3000` +
      `,"procedure_name":"pName"` +
      `,"comment":"comment1"` +
      `,"ind_user_id":4000` +
      `,"ind_user_last_name":"indLast"` +
      `,"ind_user_first_name":"indFirst"` +
      `,"upd_user_id":5000` +
      `,"upd_user_last_name":"updLast"` +
      `,"upd_user_first_name":"updFirst"` +
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //`,"input_class":"1"` +
      `,"input_class":1` +
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
      `,"is_editable":"1"` +
      `,"cop_order_no":null` +
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //`,"effect_flg":"0"` +
      `,"effect_flg":0` +
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
      `,"effect_date":"2019-01-01T12:00:00+09:00"` +
      `,"effect_user_id":6000` +
      `,"effect_user_last_name":"effectLast"` +
      `,"effect_user_first_name":"effectFirst"` +
    "}]";
    // action
    const result = mediInfoList.toString();

    // assert
    // expect(result).toBe(expected);
  });

  const getMediInfo = () => {
    const mediInfoObj = {
      be_deleted: false,
      is_edited: true,
      no: 100,
      class_cd: 101,
      class_name: "classA",
      class_type: "classTypeA",
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //medicine_type: "1",
      medicine_type: 1,
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
      cd: 1000,
      name: "medicineName",
      short_name: "medicineShortName",
      unit: "L",
      amount: 1,
      init_date: "2019-01-01T12:05:00+09:00",
      date_interval: 2,
      timing_cd: 2000,
      timing_name: "timingA",
      procedure_cd: 3000,
      procedure_name: "pName",
      comment: "comment1",
      ind_user_id: 4000,
      ind_user_last_name: "indLast",
      ind_user_first_name: "indFirst",
      upd_user_id: 5000,
      upd_user_last_name: "updLast",
      upd_user_first_name: "updFirst",
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //input_class: "1",
      input_class: 1,
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
      is_editable: "1",
      cop_order_no: null,
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //effect_flg: "0",
      effect_flg: 0,
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
      effect_status: "未",
      effect_date: "2019-01-01T12:00:00+09:00",
      effect_user_id: 6000,
      effect_user_last_name: "effectLast",
      effect_user_first_name: "effectFirst"
    };
    return MediInfo.of(mediInfoObj);
  };
});
