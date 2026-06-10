// --------------------------------------
// フィルターレベル
// --------------------------------------

export const filterListHospital = [
    //全て
    {
        code: "on",
        label: "全て",
        isDispProxy: false
    },
    //院外
    {
        code: "1",
        label: "院外",
        isDispProxy: false
    },
    //院内
    {
        code: "2",
        label: "院内",
        isDispProxy: false
    }
];

export const filterListIssued = [
    //全て
    {
        code: "on",
        label: "全て",
        isDispProxy: true,
    },
    //未
    {
        code: "0",
        label: "未",
        isDispProxy: false,
    },
    //済
    {
        code: "1",
        label: "済",
        isDispProxy: false,
    }
];