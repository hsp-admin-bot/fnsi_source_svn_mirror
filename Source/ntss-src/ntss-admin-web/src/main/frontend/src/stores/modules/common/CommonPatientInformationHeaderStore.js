/**
 * 共通患者情報ヘッダー用ストア
 */
/* eslint-disable */

export default {
  strict: true,
  namespaced: true,
  state: {
    PatientInformation: {
      patId: '',
      hospPatId: '',
      patName: '',
      sexType: '',
      patSex: '',
      patBloodTypeAbo: '',
      patBloodTypeAboRaw: '',
      patBloodTypeRh: '',
      patBloodTypeRhRaw: '',
      patBirthday: '',
      patBirthdayRaw: '',
      patAge: '',
      inOutClass: false,
      isInfect: false,
      tabooInfo: '',
      isTaboo: false,
      isImplant: false,
      isSame: false,
      isViewPatInfo: false,
    }
  },
  getters: {
    getPatId: (state) => state.PatientInformation.patId,
    getHospPatId: (state) => state.PatientInformation.hospPatId,
    getPatName: (state) => state.PatientInformation.patName,
    getSexTypeText(state) {
      if(state.PatientInformation.patSex != null){
        return state.PatientInformation.patSex;
      }
      let text = '';
      switch (state.PatientInformation.sexType) {
        case 0:
          text = '不明';
          break;
        case 1:
          text = '男性';
          break;
        case 2:
          text = '女性';
          break;
        default:
          break;
      }
      return text;
    },
    getBloodTypeText(state) {
      if(state.PatientInformation.patBloodTypeAbo != null){
        return `${state.PatientInformation.patBloodTypeAbo}(${state.PatientInformation.patBloodTypeRh})`;
      }
      let text = '';
      switch (state.PatientInformation.patBloodTypeAboRaw) {
        case 0:
          text = '不明';
          break;
        case 1:
          text = 'A型';
          break;
        case 2:
          text = 'B型';
          break;
        case 3:
          text = 'O型';
          break;
        case 4:
          text = 'AB型';
          break;
        default:
          break;
      }

      switch (state.PatientInformation.patBloodTypeRhRaw) {
        case 0:
          text += '(不明)';
          break;
        case 1:
          text += '(Rh＋)';
          break;
        case 2:
          text += '(Rh－)';
          break;
        default:
          break;
      }

      return text;
    },
    getBirthdayText(state) {
      if(state.PatientInformation.patBirthday != null){
        return `${state.PatientInformation.patBirthday}(${state.PatientInformation.patAge}歳)`;
      }
      let text = '';
      const birthDay = state.PatientInformation.patBirthdayRaw;
      if (birthDay != null && birthDay.length === 8) {
        const birth = `${birthDay.substring(0, 4)}/${birthDay.substring(4, 6)}/${birthDay.substring(6, 8)}`;

        // Dateインスタンスに変換
        const birthDate = new Date(birth);

        // 文字列に分解
        const y2 = birthDate.getFullYear().toString().padStart(4, '0');
        const m2 = (birthDate.getMonth() + 1).toString().padStart(2, '0');
        const d2 = birthDate.getDate().toString().padStart(2, '0');

        // 今日の日付
        const today = new Date();
        const y1 = today.getFullYear().toString().padStart(4, '0');
        const m1 = (today.getMonth() + 1).toString().padStart(2, '0');
        const d1 = today.getDate().toString().padStart(2, '0');

        // 引き算
        const age = Math.floor((Number(y1 + m1 + d1) - Number(y2 + m2 + d2)) / 10000);
        text = `${birth}(${age}歳)`;
      }
      return text;
    },
    getIsIn(state) {
      let ret = false;
      if (state.PatientInformation.patId != null && state.PatientInformation.inOutClass === '0') {
        ret = true;
      }
      return ret;
    },
    getIsOut(state) {
      let ret = false;
      if (state.PatientInformation.patId != null && state.PatientInformation.inOutClass === '1') {
        ret = true;
      }
      return ret;
    },
    getIsInfect(state) {
      let ret = false;
      if (state.PatientInformation.patId != null && state.PatientInformation.isInfect === '1') {
        ret = true;
      }
      return ret;
    },
    getIsTaboo(state) {
      let ret = false;
      if(state.PatientInformation.isTaboo != null){
        if (state.PatientInformation.patId != null &&
          state.PatientInformation.isTaboo === '1') {
          ret = true;
        }
      }else{
        if (state.PatientInformation.patId != null &&
          state.PatientInformation.tabooInfo != null) {
          ret = true;
        }
      }
      return ret;
    },
    getIsImplant(state) {
      let ret = false;
      if (state.PatientInformation.patId != null && state.PatientInformation.isImplant === '1') {
        ret = true;
      }
      return ret;
    },
    getIsSame(state) {
      let ret = false;
      if (state.PatientInformation.patId != null && state.PatientInformation.isSame === '1') {
        ret = true;
      }
      return ret;
    },
    getIsViewPatInfo(state) {
      let ret = false;
      if (state.PatientInformation.patId != null && state.PatientInformation.patId != undefined) {
        ret = true;
      }
      return ret;
    }
  },
  actions:
  {
    /**
     * 患者情報を患者情報ヘッダーに表示するためのデータを格納
     * すでに表示形式になっている場合
     * @param {Object} values {dataList: 取得データ, patId: 患者ID}
     */
    async setPatient({ commit }, values) {
      commit('setPatientDispData', { dataList: values.dataList, patId: values.patId });
    },
    /**
     * 患者情報を患者情報ヘッダーに表示するためのデータを格納
     * 表示形式になっていない生値の場合（現在生体モニタで取得している形）
     * @param {Object} values
     */
    async setPatientData({ commit }, values){
      commit('setPatientRawData', values);
    },
  },
  mutations:
  {
    setPatientDispData(state, values){
      state.PatientInformation.patId = values.patId;
      state.PatientInformation.hospPatId = values.dataList.hospPatId;
      state.PatientInformation.patName = values.dataList.patName;
      state.PatientInformation.patSexDisp = values.dataList.patSex;
      state.PatientInformation.patBloodTypeAbo = values.dataList.patBloodTypeAbo;
      state.PatientInformation.patBloodTypeRh = values.dataList.patBloodTypeRh;
      state.PatientInformation.patBirthday = values.dataList.patBirthday;
      state.PatientInformation.patAge = values.dataList.patAge;
      state.PatientInformation.inOutClass = values.dataList.inOutClass;
      state.PatientInformation.isInfect = values.dataList.isInfect;
      state.PatientInformation.isTaboo = values.dataList.isTaboo;
      state.PatientInformation.isImplant = values.dataList.isImplant;
      state.PatientInformation.isSame = values.dataList.isSame;
    },
    setPatientRawData(state, values){
      state.PatientInformation.patId = values.patId;
      state.PatientInformation.hospPatId = values.hospPatId;
      state.PatientInformation.patName = values.patName;
      state.PatientInformation.patSex = null;
      state.PatientInformation.sexType = values.sexType;
      state.PatientInformation.patBloodTypeAbo = null;
      state.PatientInformation.patBloodTypeAboRaw = values.patBloodTypeAbo;
      state.PatientInformation.patBloodTypeRh = null;
      state.PatientInformation.patBloodTypeRhRaw = values.patBloodTypeRh;
      state.PatientInformation.patBirthday = null;
      state.PatientInformation.patBirthdayRaw = values.patBirthday;
      state.PatientInformation.patAge = null;
      state.PatientInformation.inOutClass = values.inOutClass;
      state.PatientInformation.isInfect = values.isInfect;
      state.PatientInformation.isTaboo = null;
      state.PatientInformation.tabooInfo = values.tabooInfo;
      state.PatientInformation.isImplant = values.isImplant;
      state.PatientInformation.isSame = values.isSame;
    },
  },
};
