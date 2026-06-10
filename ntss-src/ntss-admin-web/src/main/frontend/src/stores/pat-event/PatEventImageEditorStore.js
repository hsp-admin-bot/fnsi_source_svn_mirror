import { sendRequestGetTextStampCollection } from "@/apis/pat-event";
import { sendRequestGetMstFacilitySettingValue as getMstFacilitySettingValue } from "@/apis/facility-setting";
import { GRID_SIZE_INFO } from "@/constants/facilitySetting";

export default {
  strict: true,
  namespaced: true,
  state: {
    /** ReDo用確保メモリ量 */
    unReDoNum: 40,
    /** VA画像編集可能最大画素数 */
    vaEditMaxPixel: 5 * 1024 * 1024,
    /**
     * テキスト選択情報
     *
     * id: 内部処理用コード
     * name: 選択リストに表示する文字列
     * text: テキスト出力文字列
     */
    stampTextInfo: [
      { id: "0", name: "Ｖ", text: "Ｖ" },
      { id: "1", name: "Ａ", text: "Ａ" },
      { id: "2", name: "良好", text: "良好" },
      { id: "3", name: "不良", text: "不良" },
      { id: "4", name: "狭窄", text: "狭窄" },
      { id: "5", name: "閉塞", text: "閉塞" },
      { id: "6", name: "禁止", text: "禁止" }
    ],
    /**
     * グリッド選択情報
     *
     * id ：内部処理用のコード
     * name ：選択リストに表示する文字列
     * size ：グリッドの横分割数
     * hSize ：グリッドの縦分割数
     * lineWidth ：グリッド線の太さ[1～]
     */
    gridSizeInfo: [
      { id: "0", name: "10 × 10", wSize: 10, hSize: 10, lineWidth: 1 },
      { id: "1", name: "10 × 15", wSize: 15, hSize: 10, lineWidth: 1 },
      { id: "2", name: "15 × 20", wSize: 20, hSize: 15, lineWidth: 1 }
    ]
  },
  getters: {
    /** ReDo用確保メモリ量 */
    getUnRedoNum: state => state.unReDoNum,
    /** VA画像編集可能最大画素数取得*/
    getVaEditMaxPixel: state => state.vaEditMaxPixel,
    /** テキスト選択情報取得 */
    getStampTextInfo: state => state.stampTextInfo,
    /** グリッド選択情報取得 */
    getGridSizeInfo: state => state.gridSizeInfo
  },
  mutations: {
    /** ReDo用確保メモリ量設定 */
    setUnRedoNum(state, value) {
      state.unReDoNum = value;
    },
    /** VA画像編集可能最大画素数設定*/
    setVaEditMaxPixel(state, value) {
      state.vaEditMaxPixel = value;
    },
    /**
     * テキスト選択情報設定
     * @param {Object} state
     * @param {String[]} values
     */
    setStampTextInfo(state, values) {
      state.stampTextInfo = [];
      let idCount = 0;
      for (let idx = 0; idx < values.length; idx++) {
        const str = values[idx];
        if (!str) {
          continue;
        }
        state.stampTextInfo.push({
          id: String(idCount),
          name: str,
          text: str
        });
        idCount++;
      }
    },
    /** グリッド選択情報設定 */
    setGridSizeInfo(state, value) {
      state.gridSizeInfo = value;
    }
  },
  actions: {
    /** ReDo用確保メモリ量設定 */
    setUnRedoNum({ commit }, value) {
      commit("setUnRedoNum", value);
    },
    /** VA画像編集可能最大画素数設定*/
    setVaEditMaxPixel({ commit }, value) {
      commit("setVaEditMaxPixel", value);
    },
    /** テキスト選択情報を施設設定から取得して設定 */
    initStampTextInfo({ commit }) {
      sendRequestGetTextStampCollection().then(r => {
        commit("setStampTextInfo", r.data);
      });
    },
    /** グリッド選択情報設定 */
    setGridSizeInfo({ commit }, value) {
      commit("setGridSizeInfo", value);
    },
    /** グリッド設定 */
    async fetchGridSizeInfo({ commit, rootGetters }) {
      const defaultValues = [{ id: "0", name: "", hSize: 0, wSize: 0, lineWidth: 1 }];
      try {
        const facilityCd = rootGetters["user/getFacilityCd"];
        /* グリッド設定情報取得 */
        const response = await getMstFacilitySettingValue(facilityCd, GRID_SIZE_INFO);
        /* 取得した情報を画面表示用に加工 */
        let counter = 0;
        const values = response.data.split('\n').map((item) => {
          const [hSize, wSize] = item.split('*').map(Number);
          if (!isNaN(hSize) && !isNaN(wSize) && hSize > 0 && hSize < 101 && wSize > 0 && wSize < 101) {
            const id = counter.toString();
            counter++;
            return {
              id: id,
              name: `${hSize} × ${wSize}`,
              hSize,
              wSize,
              lineWidth: 1
            };
          }
        }).filter(item => item !== undefined);
        commit("setGridSizeInfo", values.length > 0 ? values : defaultValues);
      } catch (error) {
        commit("setGridSizeInfo", defaultValues);
      }
    },
  }
};
