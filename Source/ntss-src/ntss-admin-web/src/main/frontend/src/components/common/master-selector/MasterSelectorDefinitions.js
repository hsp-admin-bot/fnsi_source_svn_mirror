/**
 * 各マスターでMasterSelectorを呼び出す際に必要な定義情報を記載します。
 */
import { CODES } from "@/constants/TreatmentRecord";

// VA
export const va = {
  filterArr: () => [
    { text: "すべて", value: 'all' },
    { text: "両方", value: "0" },
    { text: "左", value: "1" },
    { text: "右", value: "2" },
    { text: "なし", value: "3" },
    { text: "不明", value: "-" }
  ],
  filterKey: item => {
    return {
      value: item.vaCd,
      fnValue: {
        VA方向: item.vaDirect
      },
      text: item.vaName
    };
  },
  titleHeader: "VA",
  filterLabel: "VA方向",
  contentLabel: "VA名"
};

// ダイアライザ
export const dialyzer = {
  filterArr: [
    masterData => {
      // マスタデータから重複を除いたメーカー名のリストを取得する
      let classNewData = masterData
        .map(item => item.maker)
        .filter(
          (item, index, self) => item !== null && self.indexOf(item) === index
        )
        .map(item => {
          return {
            text: item,
            value: item
          };
        });
      classNewData.sort(sortPopoverValue);
      classNewData.unshift({ text: "すべて", value: 0 });
      classNewData.push({ text: "メーカー名なし", value: null });
      return classNewData;
    },
    () => {
      return [
        { text: "すべて", value: ["0","1"] },
        { text: "中空糸", value: "0" },
        { text: "積層", value: "1" }
      ];
    },
    masterData => {
      // マスタデータから重複を除いたメーカー名のリストを取得する
      let classNewData = masterData
        .map(item => item.functionClass)
        .filter(
          (item, index, self) => item !== null && self.indexOf(item) === index
        )
        .map(item => {
          return {
            text: item,
            value: item
          };
        });
      classNewData.sort(sortPopoverValue);
      classNewData.unshift({ text: "すべて", value: 0 });
      classNewData.push({ text: "未分類", value: null });
      return classNewData;
    }
  ],
  filterKey: item => {
    return {
      value: item.dialyzerCd,
      fnValue: {
        メーカー: item.maker,
        ダイアライザ種別: item.dialyzerType,
        機能分類: item.functionClass
      },
      text: item.modelNumber
    };
  },
  titleHeader: "ダイアライザ",
  filterLabel: ["メーカー", "ダイアライザ種別", "機能分類"],
  contentLabel: "ダイアライザ名"
};

// プルダウン選択肢並び替え
const sortPopoverValue = (a,b) => {
  let r = 0;
  if( a.value < b.value ){ r = -1; }
  else if( a.value > b.value ){ r = 1; }
  return r;
};

// 薬剤(抗凝固剤)
export const medicineAntiCoagulant = {
  filterArr: [
    () => {
      return [
        { text: CODES.MEDICINE_TYPE.ALL.text, value: CODES.MEDICINE_TYPE.ALL.cd },
        { text: CODES.MEDICINE_TYPE.NORMAL.text, value: CODES.MEDICINE_TYPE.NORMAL.cd },
        { text: CODES.MEDICINE_TYPE.MIX.text, value: CODES.MEDICINE_TYPE.MIX.cd }
      ];
    },
    (masterData, classData) => {
      let classNewData = classData
        .filter(
          item => item.classType === CODES.MEDICINE_CLASS.ANTI_COAGULANT.classType
        )
        .map(item => {
          return {
            text: item.className,
            value: item.classCd
          };
        });
      classNewData.unshift({ text: "すべて", value: 0 });
      return classNewData;
    }
  ],
  filterKey: item => {
    return {
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      // value: item.medicineType === CODES.MEDICINE_TYPE.NORMAL.cd
      value: item.medicineType == CODES.MEDICINE_TYPE.NORMAL.cd
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
        ? item.medicineCd : `${item.medicineCd}$`,
      text: item.medicineName,
      unit: item.unit,
      decPoint: item.unitDecimalPoint,
      fnValue: {
        薬剤区分: item.medicineType,
        薬剤分類: item.classCd
      },
    };
  },
  titleHeader: "投薬選択",
  filterLabel: ["薬剤区分", "薬剤分類"],
  contentLabel: "薬剤名"
};

//#10123:透析液/補液の薬剤選択モーダルの薬剤区分の表示が不要Start
// 薬剤(透析液)(補液)
export const medicineDialysateReplacement = {
  filterArr: [
    //#10123:透析液/補液の薬剤選択モーダルの薬剤区分の表示が不要(以下薬剤区分フィルター削除) Start
    /*
    () => {
      return [
        { text: CODES.MEDICINE_TYPE.ALL.text, value: CODES.MEDICINE_TYPE.ALL.cd },
        { text: CODES.MEDICINE_TYPE.NORMAL.text, value: CODES.MEDICINE_TYPE.NORMAL.cd },
        { text: CODES.MEDICINE_TYPE.MIX.text, value: CODES.MEDICINE_TYPE.MIX.cd }
      ];
    }, */
    //#10123:透析液/補液の薬剤選択モーダルの薬剤区分の表示が不要 End
    (masterData, classData) => {
      let classNewData = classData
        .filter(
          item => item.classType === CODES.MEDICINE_CLASS.DIALYSATE.classType
        )
        .map(item => {
          return {
            text: item.className,
            value: item.classCd
          };
        });
      classNewData.unshift({ text: "すべて", value: 0 });
      return classNewData;
    }
  ],
  filterKey: item => {
    return {
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      // value: item.medicineType === CODES.MEDICINE_TYPE.NORMAL.cd
      value: item.medicineType == CODES.MEDICINE_TYPE.NORMAL.cd
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
        ? item.medicineCd : `${item.medicineCd}$`,
      text: item.medicineName,
      unit: item.unitSecond,
      decPoint: item.unitDecimalPointSecond,
      fnValue: {
        //#10123:透析液/補液の薬剤選択モーダルの薬剤区分の表示が不要(以下薬剤区分フィルター削除) Start
        //薬剤区分: item.medicineType,
        //#10123:透析液/補液の薬剤選択モーダルの薬剤区分の表示が不要 End
        薬剤分類: item.classCd
      },
    };
  },
  titleHeader: "投薬選択",
  //#10123:透析液/補液の薬剤選択モーダルの薬剤区分の表示が不要 Start
  filterLabel: ["薬剤分類"],
  //#10123:透析液/補液の薬剤選択モーダルの薬剤区分の表示が不要 End
  contentLabel: "薬剤名"
};
//#10123:透析液/補液の薬剤選択モーダルの薬剤区分の表示が不要End

/**
 * 医療材料用FilterKey.
 */
const equipmentFilterKey = item => {
  return {
    value: item.equipmentCd,
    fnValue: {
      医療材料分類: item.classCd
    },
    text: item.equipmentName
  };
};
/**
 * 医療材料用Mapper.
 */
const equipmentMapper = item => {
  return {
    text: item.className,
    value: item.classCd
  };
};

// 医療材料
export const equipmentAll = {
  filterArr: (masterData, classData) => {
    let filterObj = classData.map(item => {
      return {
        text: item.className,
        value: item.classCd
      };
    });
    filterObj.unshift({ text: "すべて", value: 0 });

    // ダイアライザをフィルタデータに追加
    //del 6937 分類が未分類の医療材料を抽出できない 張 start
    // filterObj.push({
    //   text: "ダイアライザ",
    //   value: -1
    // });
    //del 6937 分類が未分類の医療材料を抽出できない 張 end
    return filterObj;
  },
  filterKey: item => {
    return {
      value: item.equipmentCd,
      text: item.equipmentName,
      unit: item.unit,
      fnValue: {
        医療材料分類: item.classCd
      }
    };
  },
  titleHeader: "医療材料",
  filterLabel: "医療材料分類",
  contentLabel: "医療材料名",
  // 医療材料プルダウンに「未登録」を表示しない
  hasUnregisteredOption: false
};

/**
 * @description 血液回路選択部品用のデータ作成.
 */
export const equipmentBloodCircuit = {
  filterArr: (masterData, classData) => {
    let classNewData = classData.filter(
      item =>
        item.classType === CODES.EQUIPMENT_CLASS.BLOOD_CIRCUIT.classType
    )
    .map(equipmentMapper);
    classNewData.unshift({ text: "すべて", value: 0 });
    return classNewData;
  },
  filterKey: equipmentFilterKey,
  titleHeader: "医療材料",
  filterLabel: "医療材料分類",
  contentLabel: "医療材料名"
};

// 医療材料（吸着カラム）
export const equipmentAdsorptionColumn = {
  filterArr: (masterData, classData) => {
    let classNewData = classData.filter(
      item =>
        item.classType === CODES.EQUIPMENT_CLASS.ADSORPTION_COLUMN.classType
    )
    .map(equipmentMapper);
    classNewData.unshift({ text: "すべて", value: 0 });
    return classNewData;
  },
  filterKey: equipmentFilterKey,
  titleHeader: "医療材料",
  filterLabel: "医療材料分類",
  contentLabel: "医療材料名"
};

// 医療材料（1次膜/2次膜）
export const equipmentFilm = {
  filterArr: (masterData, classData) => {
    let classNewData = classData.filter(
      item =>
        item.classType === CODES.EQUIPMENT_CLASS.ADSORBER.classType ||
        item.classType === CODES.EQUIPMENT_CLASS.SEPARATOR.classType
    )
    .map(equipmentMapper);
    classNewData.unshift({ text: "すべて", value: 0 });
    return classNewData;
  },
  filterKey: equipmentFilterKey,
  titleHeader: "医療材料",
  filterLabel: "医療材料分類",
  contentLabel: "医療材料名"
};

// 医療材料（穿刺針(A針)/(V針)）
export const equipmentPunctureNeedle = {
  filterArr: (masterData, classData) => {
    let classNewData = classData.filter(
      item =>
        item.classType === CODES.EQUIPMENT_CLASS.PUNCTURE_NEEDLE.classType
    )
    .map(equipmentMapper);
    classNewData.unshift({ text: "すべて", value: 0 });
    return classNewData;
  },
  filterKey: equipmentFilterKey,
  titleHeader: "医療材料",
  filterLabel: "医療材料分類",
  contentLabel: "医療材料名"
};

// 医療材料（穿刺針(SN)）
export const equipmentPunctureNeedleSN = {
  filterArr: (masterData, classData) => {
    let classNewData = classData.filter(
      item =>
        item.classType === CODES.EQUIPMENT_CLASS.PUNCTURE_NEEDLE_SN.classType
    )
    .map(equipmentMapper);
    classNewData.unshift({ text: "すべて", value: 0 });
    return classNewData;
  },
  filterKey: equipmentFilterKey,
  titleHeader: "医療材料",
  filterLabel: "医療材料分類",
  contentLabel: "医療材料名"
};

/**
 * 投与薬剤
 */
export const medicineAll = {
  filterArr: [
    () => {
      return [
        { text: CODES.MEDICINE_TYPE.ALL.text, value: CODES.MEDICINE_TYPE.ALL.cd },
        { text: CODES.MEDICINE_TYPE.NORMAL.text, value: CODES.MEDICINE_TYPE.NORMAL.cd },
        { text: CODES.MEDICINE_TYPE.MIX.text, value: CODES.MEDICINE_TYPE.MIX.cd }
      ];
    },
    (masterData, classData) => {
      let classNewData = classData.map(item => {
        return {
          text: item.className,
          value: item.classCd,
        };
      });
      classNewData.unshift({ text: "すべて", value: 0 });
      classNewData.push({ text: "未分類", value: null });
      return classNewData;
    }
  ],
  filterKey: item => {
    return {
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      // value: item.medicineType === CODES.MEDICINE_TYPE.NORMAL.cd
      value: item.medicineType == CODES.MEDICINE_TYPE.NORMAL.cd
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
      // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
      ? item.medicineCd : `${item.medicineCd}`,
      // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
      text: item.medicineName,
      unit: item.unit,
      decPoint: item.unitDecimalPoint,
      fnValue: {
        薬剤区分: item.medicineType,
        薬剤分類: item.classCd
      },
    };
  },
  titleHeader: "薬剤",
  filterLabel: ["薬剤区分", "薬剤分類"],
  contentLabel: "薬剤名",
  // add #9848+9849 薬剤選択IF，空選択肢なし linjunfeng start
  // 投与薬剤プルダウンに「未登録」を表示しない
  hasUnregisteredOption: false
  // add #9848+9849 薬剤選択IF，空選択肢なし linjunfeng end

};

// 処置薬剤
export const treatMedicine = Object.assign(Object.assign({}, medicineAll), {
  titleHeader: "処置薬剤選択",
  hasUnregisteredOption: true
});

// 利用者
export const personalUser = {
  filterArr: (masterData, classData) => {
    let filterObj = classData.map(item => {
      return {
        text: item.jobName,
        value: +item.jobCd
      };
    });
    filterObj.unshift({ text: "すべて", value: 0 });
    return filterObj;
  },
  filterKey: item => {
    return {
      value: item.userId,
      text: `${item.userLastName} ${item.userFirstName}`,
      personalUserInfo: {
        id: item.userId,
        lastName: item.userLastName,
        firstName: item.userFirstName,
        jobCd: +item.jobCd
      },
      fnValue: {
        職種: +item.jobCd
      },
    };
  },
  titleHeader: "利用者",
  filterLabel: "職種",
  contentLabel: "利用者名"
};

// 実施者
export const practitioner = Object.assign(Object.assign({}, personalUser), {
  titleHeader: "実施者",
  contentLabel: "実施者名"
});

// 実施者
export const usersUnregisteredOpt = Object.assign(Object.assign({}, personalUser), {
  hasUnregisteredOption: false
});

// 返血者
export const returnUser = Object.assign(Object.assign({}, personalUser), {
  titleHeader: "返血者"
});

// 穿刺者
export const punctureUser = Object.assign(Object.assign({}, personalUser), {
  titleHeader: "穿刺者"
});

// 担当者
export const chargeUser = Object.assign(Object.assign({}, personalUser), {
  titleHeader: "担当者"
});

// 処置者
export const treatUser = Object.assign(Object.assign({}, personalUser), {
  titleHeader: "処置者"
});

// 車いす
export const wheelChair = {
  filterArr: () => {},
  filterKey: item => {
    return {
      value: item.wheelChairCd,
      text: item.wheelChairName,
      weight: item.wheelChairWeight
    };
  },
  titleHeader: "車いす",
  filterLabel: "",
  contentLabel: "車いす名称"
};

// 手技
export const procedure = {
  filterArr: () => {},
  filterKey: item => {
    return {
      value: item.procedureCd,
      text: item.pricedureName  // DBのカラム名がtypo
    };
  },
  titleHeader: "手技",
  filterLabel: "",
  contentLabel: "手技名"
};
