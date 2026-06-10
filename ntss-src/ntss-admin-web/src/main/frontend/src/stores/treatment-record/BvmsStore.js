/**
 * 治療記録 体重ストア
 */
import {
  sendRequestGetBvGraph,
  sendRequestGetDdmGraph,
  sendRequestGetHtGraph,
  sendRequestGetRrGraph,
  sendRequestGetBvGraphWithUploadFile,
  sendRequestGetDdmGraphWithUploadFile,
  sendRequestGetHtGraphWithUploadFile,
  sendRequestGetRrGraphWithUploadFile,
  sendRequestUpdateListComment
} from "@/apis/treatment-record";

export default {
  strict: true,
  namespaced: true,
  state: {
    bvGraph: null,
    ddmGraph: null,
    htGraph: null,
    rrGraph: null,
    listComment: null
  },
  getters: {
    getBvGraph(state) {
      return state.bvGraph;
    },
    getDdmGraph(state) {
      return state.ddmGraph;
    },
    getHtGraph(state) {
      return state.htGraph;
    },
    getRrGraph(state) {
      return state.rrGraph;
    },
    getBvGraphWithUploadFile(state) {
      return state.bvGraph;
    },
    getDdmGraphWithUploadFile(state) {
      return state.ddmGraph;
    },
    getHtGraphWithUploadFile(state) {
      return state.htGraph;
    },
    getRrGraphWithUploadFile(state) {
      return state.rrGraph;
    }
  },
  mutations: {
    setBvGraph(state, bvGraph) {
      state.bvGraph = bvGraph;
    },
    setDdmGraph(state, ddmGraph) {
      state.ddmGraph = ddmGraph;
    },
    setHtGraph(state, htGraph) {
      state.htGraph = htGraph;
    },
    setRrGraph(state, rrGraph) {
      state.rrGraph = rrGraph;
    },
    setListComment(state, listComment) {
      state.listComment = listComment;
    }
  },
  actions: {
    getBvGraph({ commit }, payload) {
      return sendRequestGetBvGraph({
        ...{
          "graph1Y1From": -7.5,
          "graph1Y1To": 2.5,
          "graph1Y2From": 0,
          "graph1Y2To": 200,
          "graph2Y1From": 0,
          "graph2Y1To": 2,
          "graph2Y2From": 12,
          "graph2Y2To": 16
        }, ...payload
      }).then(response => {
        commit("setBvGraph", response.data);
        return response.data;
      });
    },
    getDdmGraph({ commit }, payload) {
      return sendRequestGetDdmGraph({
        ...{
          "graph1Y1From": 0,
          "graph1Y1To": 2,
          "graph1Y2From": 0,
          "graph1Y2To": 100,
          "graph2Y1From": 0,
          "graph2Y1To": 2,
          "graph2Y2From": 0,
          "graph2Y2To": 800
        }, ...payload
      }).then(response => {
        commit("setDdmGraph", response.data);
        return response.data;
      });
    },
    getHtGraph({ commit }, payload) {
      return sendRequestGetHtGraph({
        ...{
          "graph1Y1From": 10,
          "graph1Y1To": 30,
          "graph1Y2From": 0,
          "graph1Y2To": 200,
          "graph2Y1From": 0,
          "graph2Y1To": 2,
          "graph2Y2From": 12,
          "graph2Y2To": 16
        }, ...payload
      }).then(response => {
        commit("setHtGraph", response.data);
        return response.data;
      });
    },
    getRrGraph({ commit }, payload) {
      return sendRequestGetRrGraph({
        ...{
          "graphY1From": "0",
          "graphY1To": "50"
        }, ...payload
      }).then(response => {
        commit("setRrGraph", response.data);
        return response.data;
      });
    },
    getBvGraphWithUploadFile({ commit }, payload) {
      return sendRequestGetBvGraphWithUploadFile({
        ...{
          "graph1Y1From": -7.5,
          "graph1Y1To": 2.5,
          "graph1Y2From": 0,
          "graph1Y2To": 200,
          "graph2Y1From": 0,
          "graph2Y1To": 2,
          "graph2Y2From": 12,
          "graph2Y2To": 16
        }, ...payload
      }).then(response => {
        commit("setBvGraph", response.data);
        return response.data;
      });
    },
    getDdmGraphWithUploadFile({ commit }, payload) {
      return sendRequestGetDdmGraphWithUploadFile({
        ...{
          "graph1Y1From": 0,
          "graph1Y1To": 2,
          "graph1Y2From": 0,
          "graph1Y2To": 100,
          "graph2Y1From": 0,
          "graph2Y1To": 2,
          "graph2Y2From": 0,
          "graph2Y2To": 800
        }, ...payload
      }).then(response => {
        commit("setDdmGraph", response.data);
        return response.data;
      });
    },
    getHtGraphWithUploadFile({ commit }, payload) {
      return sendRequestGetHtGraphWithUploadFile({
        ...{
          "graph1Y1From": 10,
          "graph1Y1To": 30,
          "graph1Y2From": 0,
          "graph1Y2To": 200,
          "graph2Y1From": 0,
          "graph2Y1To": 2,
          "graph2Y2From": 12,
          "graph2Y2To": 16
        }, ...payload
      }).then(response => {
        commit("setHtGraph", response.data);
        return response.data;
      });
    },
    getRrGraphWithUploadFile({ commit }, payload) {
      return sendRequestGetRrGraphWithUploadFile({
        ...{
          "graphY1From": "0",
          "graphY1To": "50"
        }, ...payload
      }).then(response => {
        commit("setRrGraph", response.data);
        return response.data;
      });
    },
    async updateListComment({ commit }, payload) {
      return sendRequestUpdateListComment(payload).then(response => {
        commit("setListComment", response);
        return response;
      });
    }
  }
};
