/**
 * 稼働ビューア一覧用ストア
 */
import {
  sendRequestFindMachines,
  sendRequestGetMachine,
  sendRequestGetSelfMeasureResult
} from "@/apis/operation-viewer";

export default {
  strict: true,
  namespaced: true,
  state: {
    // 部署符号
    departmentCd: "",
    // 施設コード
    facilityCd: "",
    // 施設名
    facilityName: "",
    // 装置一覧
    machines: [],
    // 表示切替フラグ true:ベッド名、false:装置名
    displayNameFlag: true,
    // 検索条件（フィルタリング用）
    condition: {
      // 緊急発報(チェックボックス)
      machineEmergency: false,
      // 予防保守(チェックボックス)
      machineProphylaxis: false,
      // 通信不良(チェックボックス)
      machineDefect: false,
      // 全選択
      machineAll: true
    },
    // 緊急発報が1以上の装置件数
    emergencyCount: 0,
    // 予防保守が1件以上の装置件数
    prophylaxisCount: 0,
    // 通信不良が1件以上の装置件数
    defectCount: 0,
    // 選択された装置情報
    selectMachine: null,
    // サービス対応件数
    serviceSupportCount: 0,
    // 選択した装置の自己診断判定情報
    selfMeasureResultInfo: []
  },
  mutations: {
    // 装置一覧設定
    setMachines(state, machines) {
      machines.forEach(e => {
        state.machines.push(e);
      });
    },
    // 装置一覧クリア
    clearMachines(state) {
      state.machines.splice(0, state.machines.length);
    },
    // 装置一覧クリア
    clearFacilityCd(state) {
      state.facilityCd = "";
    },
    // 表示切替フラグ変更
    changeDisplayNameFlag(state, displayNameFlag) {
      state.displayNameFlag = displayNameFlag;
    },
    // -----------------------------------------
    // 抽出条件設定
    // -----------------------------------------
    setCondition(state, condition) {
      state.condition.machineEmergency = condition.machineEmergency;
      state.condition.machineProphylaxis = condition.machineProphylaxis;
      state.condition.machineDefect = condition.machineDefect;
      state.condition.machineAll = condition.machineAll;
    },
    // -----------------------------------------
    // 抽出条件クリア
    // -----------------------------------------
    clearCondition(state) {
      state.condition.machineEmergency = false;
      state.condition.machineProphylaxis = false;
      state.condition.machineDefect = false;
      state.condition.machineAll = true;
    },
    // -----------------------------------------
    // 緊急発報件数が0以上の件数
    // -----------------------------------------
    setEmergencyCount(state, count) {
      state.emergencyCount = count;
    },
    // -----------------------------------------
    // 予防保守が1件以上のレコード件数
    // -----------------------------------------
    setProphylaxisCount(state, count) {
      state.prophylaxisCount = count;
    },
    // -----------------------------------------
    // 通信不良が1件以上のレコード件数
    // -----------------------------------------
    setDefectCount(state, count) {
      state.defectCount = count;
    },
    // -----------------------------------------
    // 施設情報を格納
    // -----------------------------------------
    setFacilityInfo(state, facilityInfo) {
      state.departmentCd = facilityInfo.departmentCd;
      state.facilityCd = facilityInfo.facilityCd;
      state.facilityName = facilityInfo.facilityName;
    },
    // -----------------------------------------
    // 選択された装置情報
    // -----------------------------------------
    setSelectMachine(state, machine) {
      state.selectMachine = machine;
    },
    // -----------------------------------------
    // 施設コード、型式コード、製造番号に該当する装置情報取得
    // -----------------------------------------
    setFacilityCd(state, facilityCd) {
      state.facilityCd = facilityCd;
    },
    /**
     * サービス対応件数を設定する.
     * 
     * @param {*} state stateオブジェクト
     * @param {Number} count サービス対応件数
     */
    setServiceSupportCount(state, count) {
      state.serviceSupportCount = count;
    },
    // -----------------------------------------
    // 選択した装置の自己診断判定情報
    // -----------------------------------------
    setSelfMeasureResultInfo(state, info) {
      state.selfMeasureResultInfo = info;
    }
  },
  actions: {
    // 装置一覧クリア
    clearMachines({ commit }) {
      commit("clearMachines");
    },
    // 施設コードクリア
    clearFacilityCd({ commit }) {
      commit("clearFacilityCd");
    },
    // 施設コードに紐づく装置一覧取得
    findMachines({ commit }, {facilityCd, autoRefreshFlag}) {
      return sendRequestFindMachines(facilityCd, autoRefreshFlag).then(response => {
        const machines = response.data.machines;
        commit("clearMachines");
        commit("setMachines", machines);
        // 取得した装置一覧より緊急発報件数及び予防保守件数、通信不良件数が1件以上の件数を算出する
        let emergencyCount = 0;
        let prophylaxisCount = 0;
        let defectCount = 0;
        let serviceSupportCount = 0;
        for (const machine of machines) {
          emergencyCount += machine.mnoticeCnt > 0 ? 1 : 0;
          prophylaxisCount += machine.preventiveMainteCnt > 0 ? 1 : 0;
          defectCount += machine.isPreventiveMainte > 0 ? 1 : 0;
          serviceSupportCount += machine.serviceSupportCnt > 0 ? 1 : 0;
        }
        // 装置一覧のheaderで使用出来るようにstateに登録
        commit("setEmergencyCount", emergencyCount);
        commit("setProphylaxisCount", prophylaxisCount);
        commit("setDefectCount", defectCount);
        commit("setServiceSupportCount", serviceSupportCount);
      });
    },
    // 表示切替フラグ変更
    changeDisplayNameFlag({ commit }, displayNameFlag) {
      commit("changeDisplayNameFlag", displayNameFlag);
    },
    // -----------------------------------------
    // 抽出条件クリア
    // -----------------------------------------
    clearCondition({ commit }) {
      commit("clearCondition");
    },
    // -----------------------------------------
    // 抽出条件設定
    // -----------------------------------------
    setCondition({ commit }, condition) {
      commit("setCondition", condition);
    },
    setFacilityInfo({ commit }, facilityInfo) {
      commit("setFacilityInfo", facilityInfo);
    },
    // -----------------------------------------
    // 施設コード、型式コード、製造番号に該当する装置情報取得
    // -----------------------------------------
    getMachine({ commit }, condition) {
      commit("clearMachines");
      return sendRequestGetMachine(condition).then(response => {
        const machine = response.data;
        commit("setSelectMachine", machine);
      });
    },
    // -----------------------------------------
    // 施設コードを設定
    // -----------------------------------------
    setFacilityCd({ commit }, facilityCd) {
      commit("setFacilityCd", facilityCd);
    },
    // -----------------------------------------
    // 対象装置の自己診断判定情報を設定
    // -----------------------------------------
    async getSelfMeasureResultInfo({ state, commit, dispatch }, machine) {
      // add/ #9291 自己診断判定の対象でない項目の値が表示される tianqidong start
      const targetFacilityCd = machine.facilityCd || state.facilityCd;
      if (targetFacilityCd && targetFacilityCd !== state.facilityCd) {
        commit("setFacilityCd", targetFacilityCd);
      }
      // 先按製造番号回查装置主档，优先使用主档中的型式/版本来匹配判定信息
      let targetMachine = {
        machineTypeCd: machine.machineTypeCd,
        version: machine.version
      };
      try {
        const machineResponse = await sendRequestGetMachine({
          facilityCd: targetFacilityCd,
          machineTypeCd: machine.machineTypeCd,
          machineSerial: machine.machineSerial
        });
        if (machineResponse?.data) {
          targetMachine = {
            machineTypeCd: machineResponse.data.machineTypeCd || machine.machineTypeCd,
            version: machineResponse.data.version || machine.version
          };
        }
      } catch (e) {
        // 主档回查失败时降级使用列表行上的型式/版本，避免中断后续处理
      }

      const response = await sendRequestGetSelfMeasureResult(targetFacilityCd, targetMachine.machineTypeCd);
      const arrResInfAll = [];
      // DBから取得した自己診断判定情報から、対象装置のバージョン下限・上限・自己診断情報をまとめる
      for (let i = 0; i < response.data.length; i++) {
        const arrMachines = JSON.parse(response.data[i].machineInfo);
        const recordCode = Number(response.data[i].code);
        for (let i2 = 0; i2 < arrMachines.length; i2++) {
          const machineInf = arrMachines[i2];
          if (machineInf.type_cd === targetMachine.machineTypeCd){
            // バージョン情報の整形
            let strVerUp = "";
            if (machineInf.ver_up) {
              strVerUp = await dispatch("formatVersionInf", machineInf.ver_up);
            } else {
              // 空欄の場合は以上すべてのためMAX設定
              strVerUp = "999.999ZZZ";
            }

            let strVerLow = "";
            if (machineInf.ver_low) {
              strVerLow = await dispatch("formatVersionInf", machineInf.ver_low);
            } else {
              // 空欄の場合は以下すべてのためMIN設定
              strVerLow = "0";
            }

            const machineData = {
              machineVerUp: strVerUp,
              machineVerLow: strVerLow,
              selfMeasureResult: response.data[i].selfMeasureResult,
              // 同一レンジで複数候補がある場合は、最新(codeが大きい)を優先
              recordCode: Number.isNaN(recordCode) ? 0 : recordCode
            };
            arrResInfAll.push(machineData);
          }
        }
      }

      // ソート(minVer昇順 > maxVer昇順 > code昇順)
      arrResInfAll.sort((a, b) => {
        if (a.machineVerLow < b.machineVerLow) return -1;
        if (a.machineVerLow > b.machineVerLow) return 1;
        if (a.machineVerUp < b.machineVerUp) return -1;
        if (a.machineVerUp > b.machineVerUp) return 1;
        if (a.recordCode < b.recordCode) return -1;
        if (a.recordCode > b.recordCode) return 1;
          return 0;
      });

      let machineSelfMeasureResultInfo = "[]";
      if (arrResInfAll.length > 0){
        if (targetMachine.version) {
          const machineVer = await dispatch("formatVersionInf", targetMachine.version);
          // 装置のバージョンが登録されている場合は、レンジ一致候補から「最新」を採用
          const matchCandidates = arrResInfAll.filter((item) => {
            return machineVer >= item.machineVerLow && machineVer <= item.machineVerUp;
          });
          if (matchCandidates.length > 0) {
            matchCandidates.sort((a, b) => {
              // まずバージョンレンジの近さ(下限が高いもの)を優先
              if (a.machineVerLow < b.machineVerLow) return 1;
              if (a.machineVerLow > b.machineVerLow) return -1;
              if (a.machineVerUp < b.machineVerUp) return 1;
              if (a.machineVerUp > b.machineVerUp) return -1;
              // 同一レンジは最新codeを優先
              if (a.recordCode < b.recordCode) return 1;
              if (a.recordCode > b.recordCode) return -1;
              return 0;
            });
            machineSelfMeasureResultInfo = matchCandidates[0].selfMeasureResult;
          }
        } else {
          // 装置バージョン未登録時は、最新codeの1件を適用
          const latest = arrResInfAll.slice().sort((a, b) => {
            if (a.recordCode < b.recordCode) return 1;
            if (a.recordCode > b.recordCode) return -1;
            return 0;
          })[0];
          machineSelfMeasureResultInfo = latest?.selfMeasureResult || "[]";
        }
      }
      // add/ #9291 自己診断判定の対象でない項目の値が表示される tianqidong start
      commit("setSelfMeasureResultInfo", JSON.parse(machineSelfMeasureResultInfo));
    },
    
    // -----------------------------------------
    // バージョン情報を整形
    // -----------------------------------------
    // TODO: 局所的なeslintの設定を削除する
    /* eslint-disable no-unused-vars */
    formatVersionInf({ state }, version) {
      let retStr = "";
      const arrVer = version.split(".");
      if (arrVer.length === 1) {
        // メジャーバージョンのみ
        if (arrVer[0].length > 3) {
          retStr = arrVer[0];
        } else {
          retStr = ("000" + arrVer[0]).slice(-3);
        }
      } else if (arrVer.length === 2) {
        // メジャーバージョン + サブバージョン (+ リビジョン)
        // サブバージョンの桁数を取得
        const arrSubVer = arrVer[1].split("");
        let subVerLen = 0;
        let isSubVer = true;
        arrSubVer.forEach(str => {
          if (isSubVer) {
            let reg = /[0-9]+/;
            if (reg.test(str)) {
              subVerLen += 1;
            } else {
              // 数字以外が出現した時点でリビジョンに切り替わったと判断
              isSubVer = false;
            }
          }
        });

        if (arrVer[0].length > 3) {
          retStr = arrVer[0];
        } else {
          retStr = ("000" + arrVer[0]).slice(-3);
        }

        retStr += ".";

        if (subVerLen > 3) {
          retStr += arrVer[1];
        } else {
          const sliceNum = (3 + arrSubVer.length - subVerLen) * -1;
          retStr += ("000" + arrVer[1]).slice(sliceNum);
        }
      } else {
        // バージョン情報が規定外のためそのままの文字列で採用
        retStr = version;
      }
      
      return retStr;
    }
    
  },
  getters: {
    getMachines(state) {
      return state.machines;
    },
    getCondition(state) {
      return state.condition;
    },
    getDisplayNameFlag(state) {
      return state.displayNameFlag;
    },
    getEmergencyCount(state) {
      return state.emergencyCount;
    },
    getProphylaxisCount(state) {
      return state.prophylaxisCount;
    },
    getDefectCount(state) {
      return state.defectCount;
    },
    getFacilityCd(state) {
      return state.facilityCd;
    },
    getFacilityName(state) {
      return state.facilityName;
    },
    getSelectMachine(state) {
      return state.selectMachine;
    },
    getDepartmentCd(state) {
      return state.departmentCd;
    },
    /**
     * サービス対応件数を取得する.
     * 
     * @param {*} state stateオブジェクト
     * @returns サービス対応件数
     */
    getServiceSupportCount(state) {
      return state.serviceSupportCount;
    },
    getSelfMeasureResultInfo(state) {
      return state.selfMeasureResultInfo;
    }
  }
};
