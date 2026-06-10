import { Minutes } from "@/models/treatment-record/setting/Minutes";

describe("", () => {
  test("秒をHH:mmにフォーマットできること", () => {
    // arrange
    // action
    // assert
    expect(new Minutes("90").getHHmm()).toBe("01:30");
    expect(new Minutes("200").getHHmm()).toBe("03:20");
    expect(new Minutes("1440").getHHmm()).toBe("24:00");
    expect(new Minutes("1530").getHHmm()).toBe("25:30");
    expect(new Minutes("2880").getHHmm()).toBe("48:00");
    expect(new Minutes("3000").getHHmm()).toBe("50:00");
    expect(new Minutes("0").getHHmm()).toBe("00:00");
    expect(new Minutes("").getHHmm()).toBe("");
    expect(new Minutes(null).getHHmm()).toBe("");
    expect(new Minutes(undefined).getHHmm()).toBe("");
  });
});

