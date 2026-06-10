import { MediInfo } from "@/models/treatment-record/medicine/MediInfo";

describe("MediInfo#toString", () => {
  test("of by default", () => {
    // arrange
    const mediInfo = MediInfo.of();
    /* eslint-disable*/
    const expected = "{" +
      `"no":0` +
      `,"class_cd":null` +
      `,"class_name":null` +
      `,"class_type":null` +
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //`,"medicine_type":"1"` +
      `,"medicine_type":1` +
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
      `,"cd":null` +
      `,"name":null` +
      `,"short_name":null` +
      `,"unit":null` +
      `,"amount":null` +
      `,"init_date":null` +
      `,"date_interval":null` +
      `,"timing_cd":null` +
      `,"timing_name":null` +
      `,"procedure_cd":null` +
      `,"procedure_name":null` +
      `,"comment":null` +
      `,"ind_user_id":null` +
      `,"ind_user_last_name":null` +
      `,"ind_user_first_name":null` +
      `,"upd_user_id":null` +
      `,"upd_user_last_name":null` +
      `,"upd_user_first_name":null` +
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
      `,"effect_date":null` +
      `,"effect_user_id":null` +
      `,"effect_user_last_name":null` +
      `,"effect_user_first_name":null` +
    "}";

    // action
    const result = mediInfo.toString();

    // assert
    // expect(result).toBe(expected);
  });

  test("of", () => {
    // arrange
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
    const mediInfo = MediInfo.of(mediInfoObj);
    /* eslint-disable*/
    const expected = "{" +
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
    "}";

    // action
    const result = mediInfo.toString();

    // assert
    expect(mediInfo.effect_time).toBe("12:00");
    // expect(result).toBe(expected);
  });
});
