import { OrdTreatConditionBase } from "@/models/treatment-record/setting/OrdTreatConditionBase";

describe("OrdTreatConditionBase#getFormattedReceiveDate", () => {
  test("「MM/dd + 半角スペース + HH:mm」にフォーマットされること", () => {
    // arrange
    const ordTreatConditionBase = new OrdTreatConditionBase(
      "2019-12-14T19:30:00+09:00",
      0
    );

    // action
    const result = ordTreatConditionBase.getFormattedReceiveDate();

    // assert
    expect(result).toBe("12/14 19:30");
  });
  test("「MM/dd + 半角スペース + HH:mm」にフォーマットされること 1桁の月・日・時・分は「0」がつくこと", () => {
    // arrange
    const ordTreatConditionBase = new OrdTreatConditionBase(
      "2019-06-02T08:01:00+09:00",
      0
    );

    // action
    const result = ordTreatConditionBase.getFormattedReceiveDate();

    // assert
    expect(result).toBe("06/02 08:01");
  });
});

describe("OrdTreatConditionBase#getTreatClassName", () => {
  test("区分の日本語表記を取得できること", () => {
    // arrange
    const base0 = new OrdTreatConditionBase("2019-12-14T19:30:00+09:00", 0);
    const base1 = new OrdTreatConditionBase("2019-12-14T19:30:00+09:00", 1);
    const base2 = new OrdTreatConditionBase("2019-12-14T19:30:00+09:00", 2);
    const base3 = new OrdTreatConditionBase("2019-12-14T19:30:00+09:00", 3);
    const base4 = new OrdTreatConditionBase("2019-12-14T19:30:00+09:00", 4);

    // action
    // assert
    expect(base0.getTreatClassName()).toBe("条件送信前");
    expect(base1.getTreatClassName()).toBe("条件送信");
    expect(base2.getTreatClassName()).toBe("運転開始");
    expect(base3.getTreatClassName()).toBe("排液検出");
    expect(base4.getTreatClassName()).toBe("手動");
  });
  test("区分が0~4以外だった場合は、その数字を取得できること", () => {
    // arrange
    const baseNegative1 = new OrdTreatConditionBase("2019-12-14T19:30:00+09:00", -1);
    const base5 = new OrdTreatConditionBase("2019-12-14T19:30:00+09:00", 5);

    // action
    // assert
    expect(baseNegative1.getTreatClassName()).toBe("-1");
    expect(base5.getTreatClassName()).toBe("5");
  });
  test("区分がnullだった場合は、空文字を取得できること", () => {
    // arrange
    const baseNull = new OrdTreatConditionBase("2019-12-14T19:30:00+09:00", null);

    // action
    // assert
    expect(baseNull.getTreatClassName()).toBe("");
  });
});

describe("OrdTreatConditionBase#getAfterConversionValue", () => {
  test("カテゴリーと値を指定して変換できること", () => {
    // arrange
    const base = new OrdTreatConditionBase("2019-12-14T19:30:00+09:00", 0);

    // action
    // assert
    expect(base.getAfterConversionValue("15", 7)).toBe("OHDF");
  });
  test("存在しないカテゴリーを指定した場合は、空文字を取得できること", () => {
    // arrange
    const base = new OrdTreatConditionBase("2019-12-14T19:30:00+09:00", 0);

    // action
    // assert
    expect(base.getAfterConversionValue("999", 7)).toBe("");
  });
  test("変換ルールにない値を指定した場合は、その値を取得できること", () => {
    // arrange
    const base = new OrdTreatConditionBase("2019-12-14T19:30:00+09:00", 0);

    // action
    // assert
    expect(base.getAfterConversionValue("15", 99)).toBe(99);
  });
  test("値にundefinedを指定した場合は、空文字を取得できること", () => {
    // arrange
    const base = new OrdTreatConditionBase("2019-12-14T19:30:00+09:00", 0);

    // action
    // assert
    expect(base.getAfterConversionValue("15", undefined)).toBe("");
  });
  test("値にnullを指定した場合は、空文字を取得できること", () => {
    // arrange
    const base = new OrdTreatConditionBase("2019-12-14T19:30:00+09:00", 0);

    // action
    // assert
    expect(base.getAfterConversionValue("15", null)).toBe("");
  });
});

describe("OrdTreatConditionBase#getUnit", () => {
  test("カテゴリーを指定して単位を取得できること", () => {
    // arrange
    const base = new OrdTreatConditionBase("2019-12-14T19:30:00+09:00", 0);

    // action
    // assert
    expect(base.getUnit("14")).toBe("分");
  });
  test("存在しないカテゴリーを指定した場合は、空文字を取得できること", () => {
    // arrange
    const base = new OrdTreatConditionBase("2019-12-14T19:30:00+09:00", 0);

    // action
    // assert
    expect(base.getUnit("999")).toBe("");
  });
});
