/**
 * 定期点検一覧用ストア
 */
export default {
  strict: true,
  namespaced: true,
  state: {
    partsRunningResult: {
      // 通信種別
      comType: 0,
      // 通信フォーマット
      comFormatCd: "",
      // 運転/交換時間
      partsRunning: {
        dialyzeDevice: {
          0: "",
          1: "",
          2: "",
          3: "",
          4: "",
          5: "",
          6: "",
          7: "",
          8: "",
          9: "",
          10: "",
          11: "",
          12: "",
          13: "",
          14: "",
          15: "",
          16: "",
          17: "",
          18: "",
          19: "",
          20: "",
          21: "",
          22: "",
          23: "",
          24: "",
          25: "",
          26: "",
          27: "",
          28: "",
          29: "",
          30: "",
          31: "",
          32: "",
          33: "",
          34: "",
          35: "",
        },
        dab: {
          1: "",
          2: "",
          3: "",
          4: "",
          5: "",
          6: "",
          7: "",
          8: "",
          9: "",
          10: "",
          11: "",
          12: "",
          13: "",
          14: "",
          15: "",
          16: ""
        },
        dad: {
          1: "",
          2: "",
          3: "",
          4: "",
          5: "",
          6: "",
          7: "",
          8: "",
          9: ""
        },
        dro: {
          1: "",
          2: "",
          3: "",
          4: "",
          5: "",
          6: "",
          7: "",
          8: ""
        }
      }
    }
  },
  mutations: {
    // 部品の運転/交換時間取得結果を反映
    setPartsRunningResult(state, result) {
      const comType = result.comType;
      const comFormatCd = result.comFormatCd;
      state.partsRunningResult.comType = comType;
      state.partsRunningResult.comFormatCd = comFormatCd;
      const partsRunning = result.partsRunning;
      if (comType === 1) {
        state.partsRunningResult.partsRunning.dialyzeDevice = partsRunning;
      } else if (comType === 2) {
        switch (comFormatCd) {
          case "A": {
            state.partsRunningResult.partsRunning.dab = partsRunning;
            break;
          }
          case "D": {
            state.partsRunningResult.partsRunning.dad = partsRunning;
            break;
          }
          case "R": {
            state.partsRunningResult.partsRunning.dro = partsRunning;
            break;
          }
          default:
            break;
        }
      }
    }
  },
  actions: {
    setPartsRunningResult({ commit }, info){
      commit("setPartsRunningResult", info);
    }
  },
  getters: {
    getPartsRunningResult(state) {
      return state.partsRunningResult;
    }
  }
};
