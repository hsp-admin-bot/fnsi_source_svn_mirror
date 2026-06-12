import { Equipment } from "@/models/treatment-record/equipment/Equipment";
import { EquipmentList } from "@/models/treatment-record/equipment/EquipmentList";

describe("EquipmentList#toString", () => {
  test("no Equipment", () => {
    // arrange
    const equipmentList = new EquipmentList();
    const expected = "[]";

    // action
    const result = equipmentList.toString();

    // assert
    expect(result).toBe(expected);
  });

  test("a Equipment", () => {
    // arrange
    const equipmentList = new EquipmentList();
    equipmentList.add(getEquipment());
    const expected =
      "[{" +
      `"class_cd":101` +
      `,"class_name":"classA"` +
      `,"class_type":"classTypeA"` +
      `,"cd":1000` +
      `,"name":"equipmentName"` +
      `,"short_name":"equipmentShortName"` +
      `,"amount":1` +
      `,"unit":"L"` +
      // mod #7475 �R���o�[�g����ord_main�Ƀf�[�^������Ȍ`�ŃR���o�[�g����Ă��Ȃ� dou start
      //`,"input_class":"2"` +
      `,"input_class":2` +
      // mod #7475 �R���o�[�g����ord_main�Ƀf�[�^������Ȍ`�ŃR���o�[�g����Ă��Ȃ� dou end
      `,"is_editable":"0"` +
      `,"cop_order_no":1` +
      `,"equip_type":3` +
      "}]";

    // action
    const result = equipmentList.toString();

    // assert
    expect(result).toBe(expected);
  });

  test("two Equipment", () => {
    // arrange
    const equipmentList = new EquipmentList();
    const equipment1 = getEquipment();
    const equipment2 = getEquipment();
    equipment2.name = "equipmentName2";
    equipment2.amount = 2;
    equipmentList.addAll([equipment1, equipment2]);
    const expected =
      "[{" +
      `"class_cd":101` +
      `,"class_name":"classA"` +
      `,"class_type":"classTypeA"` +
      `,"cd":1000` +
      `,"name":"equipmentName"` +
      `,"short_name":"equipmentShortName"` +
      `,"amount":1` +
      `,"unit":"L"` +
      // mod #7475 �R���o�[�g����ord_main�Ƀf�[�^������Ȍ`�ŃR���o�[�g����Ă��Ȃ� dou start
      //`,"input_class":"2"` +
      `,"input_class":2` +
      // mod #7475 �R���o�[�g����ord_main�Ƀf�[�^������Ȍ`�ŃR���o�[�g����Ă��Ȃ� dou end
      `,"is_editable":"0"` +
      `,"cop_order_no":1` +
      `,"equip_type":3` +
      "}," +
      "{" +
      `"class_cd":101` +
      `,"class_name":"classA"` +
      `,"class_type":"classTypeA"` +
      `,"cd":1000` +
      `,"name":"equipmentName2"` +
      `,"short_name":"equipmentShortName"` +
      `,"amount":2` +
      `,"unit":"L"` +
      // mod #7475 �R���o�[�g����ord_main�Ƀf�[�^������Ȍ`�ŃR���o�[�g����Ă��Ȃ� dou start
      //`,"input_class":"2"` +
      `,"input_class":2` +
      // mod #7475 �R���o�[�g����ord_main�Ƀf�[�^������Ȍ`�ŃR���o�[�g����Ă��Ȃ� dou end
      `,"is_editable":"0"` +
      `,"cop_order_no":1` +
      `,"equip_type":3` +
      "}]";

    // action
    const result = equipmentList.toString();

    // assert
    expect(result).toBe(expected);
  });

  const getEquipment = () => {
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
    return Equipment.of(equipmentObj);
  };
});
