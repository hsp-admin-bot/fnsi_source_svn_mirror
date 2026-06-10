import { Equipment } from "@/models/treatment-record/equipment/Equipment";

describe("Equipment#toString", () => {
  test("of by default", () => {
    // arrange
    const equipment = Equipment.of();
    /* eslint-disable*/
    const expected = "{" +
      `"class_cd":null` +
      `,"class_name":null` +
      `,"class_type":null` +
      `,"cd":null` +
      `,"name":null` +
      `,"short_name":null` +
      `,"needle_type":0` +
      `,"amount":null` +
      `,"unit":null` +
      `,"ind_user_id":null` +
      `,"ind_user_last_name":null` +
      `,"ind_user_first_name":null` +
      `,"upd_user_id":null` +
      `,"upd_user_last_name":null` +
      `,"upd_user_first_name":null` +
      // mod #7475 �R���o�[�g����ord_main�Ƀf�[�^������Ȍ`�ŃR���o�[�g����Ă��Ȃ� dou start
      //`,"input_class":"1"` +
      `,"input_class":1` +
      // mod #7475 �R���o�[�g����ord_main�Ƀf�[�^������Ȍ`�ŃR���o�[�g����Ă��Ȃ� dou end
      `,"is_editable":"1"` +
      `,"cop_order_no":null` +
      `,"equip_type":null` +
    "}";

    // action
    const result = equipment.toString();

    // assert
    expect(result).toBe(expected);
  });

  test("of", () => {
    // arrange
    const equipmentObj = {
      be_deleted: false,
      is_edited: true,
      class_cd: 101,
      class_name: "classA",
      class_type: "classTypeA",
      cd: 1000,
      name: "equipmentName",
      short_name: "equipmentShortName",
      needle_type: 0,
      amount: 1,
      unit: "L",
      ind_user_id: 4000,
      ind_user_last_name: "indLast",
      ind_user_first_name: "indFirst",
      upd_user_id: 5000,
      upd_user_last_name: "updLast",
      upd_user_first_name: "updFirst",
      // mod #7475 �R���o�[�g����ord_main�Ƀf�[�^������Ȍ`�ŃR���o�[�g����Ă��Ȃ� dou start
      //input_class: "2",
      input_class: 2,
      // mod #7475 �R���o�[�g����ord_main�Ƀf�[�^������Ȍ`�ŃR���o�[�g����Ă��Ȃ� dou end
      is_editable: "0",
      cop_order_no: 1,
      equip_type: 3
    };
    const equipment = Equipment.of(equipmentObj);
    /* eslint-disable*/
    const expected = "{" +
      `"class_cd":101` +
      `,"class_name":"classA"` +
      `,"class_type":"classTypeA"` +
      `,"cd":1000` +
      `,"name":"equipmentName"` +
      `,"short_name":"equipmentShortName"` +
      `,"needle_type":0` +
      `,"amount":1` +
      `,"unit":"L"` +
      `,"ind_user_id":4000` +
      `,"ind_user_last_name":"indLast"` +
      `,"ind_user_first_name":"indFirst"` +
      `,"upd_user_id":5000` +
      `,"upd_user_last_name":"updLast"` +
      `,"upd_user_first_name":"updFirst"` +
      // mod #7475 �R���o�[�g����ord_main�Ƀf�[�^������Ȍ`�ŃR���o�[�g����Ă��Ȃ� dou start
      //`,"input_class":"2"` +
      `,"input_class":2` +
      // mod #7475 �R���o�[�g����ord_main�Ƀf�[�^������Ȍ`�ŃR���o�[�g����Ă��Ȃ� dou end
      `,"is_editable":"0"` +
      `,"cop_order_no":1` +
      `,"equip_type":3` +
    "}";

    // action
    const result = equipment.toString();

    // assert
    expect(result).toBe(expected);
  });
});
