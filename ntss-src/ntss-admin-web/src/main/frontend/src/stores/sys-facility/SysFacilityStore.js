// import { sysFacilityForName } from "@/functions/mst/MstGetters.js";
//
// export default {
//   namespaced: true,
//   strict: process.env.NODE_ENV !== "production",
//   state: {
//     loading: false,
//     loadingQueue: [],
//     all: [],
//     filtered: [],
//   },
//   getters: {
//     // sys_facilityのデータ取得処理中ならtrue
//     isLoading(state) {
//       return state.loading;
//     },
//     // sys_facilityのデータが格納済みならtrue
//     isLoaded(state) {
//       return state.all && state.all.length > 0;
//     },
//     // 施設名表示用に非表示・削除のレコードも含めたデータ
//     getSysFacilitiesForName(state) {
//       return state.all;
//     },
//     // 施設選択用に非表示・削除のレコードを含まないデータ
//     getSysFacilities(state) {
//       return state.filtered;
//     },
//   },
//   actions: {
//     // sys_facilityのデータを直接渡して格納する
//     setSysFacilities({ commit }, sysFacilities) {
//       if (sysFacilities && Array.isArray(sysFacilities)) {
//         commit("setSysFacilities", sysFacilities);
//       }
//     },
//     // sys_facilityのデータをDBから取得して格納する
//     async loadSysFacility({ commit, getters, state }, forceReload) {
//       if (state.loading) {
//         await new Promise((resolve) => {
//           commit("addLoadingQueue", resolve);
//         });
//       }
//       if (!forceReload && getters.isLoaded) return;
//       commit("setLoading", true);
//       const response = await sysFacilityForName();
//       if (response) {
//         commit("setSysFacilities", response);
//       }
//       commit("setLoading", false);
//     },
//   },
//   mutations: {
//     setLoading(state, value) {
//       state.loading = value;
//       if (!value) {
//         // ロード待ちのPromiseのresolveを呼び出す
//         state.loadingQueue.forEach(resolve => resolve());
//         state.loadingQueue.length = 0;
//       }
//     },
//     addLoadingQueue(state, resolve) {
//       state.loadingQueue.push(resolve);
//     },
//     setSysFacilities(state, sysFacilities) {
//       state.all = [...sysFacilities];
//       state.filtered = state.all.filter(item => item.isDisp === "1" && item.isDel === "0");
//     },
//   }
// };
