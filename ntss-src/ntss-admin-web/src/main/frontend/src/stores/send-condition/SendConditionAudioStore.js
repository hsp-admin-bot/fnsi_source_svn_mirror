import { Howl } from "howler";

export default {
  strict: process.env.NODE_ENV !== "production",
  namespaced: true,
  state: {
    audioFile: {
      error: "audio/error.wav",
      measure: "audio/measure.wav",
      onorikudasai: "audio/onorikudasai.wav",
      sendOk: "audio/send_ok.wav"
    },
    soundError: null,
    soundStart: null,
    soundMeasure: null,
    soundSendOk: null
  },
  getters: {},
  actions: {
    initAudio({ commit, state }) {
      if (
        state.soundError === null ||
        state.soundError.state() === "unloaded"
      ) {
        const soundError = new Howl({
          src: [state.audioFile.error]
        });
        commit("setSoundError", soundError);
      }
      if (
        state.soundStart === null ||
        state.soundStart.state() === "unloaded"
      ) {
        const soundStart = new Howl({
          src: [state.audioFile.onorikudasai]
        });
        commit("setSoundStart", soundStart);
      }
      if (
        state.soundSendOk === null ||
        state.soundSendOk.state() === "unloaded"
      ) {
        const soundSendOk = new Howl({
          src: [state.audioFile.sendOk]
        });
        commit("setSoundSendOk", soundSendOk);
      }
      if (
        state.soundMeasure === null ||
        state.soundMeasure.state() === "unloaded"
      ) {
        const soundMeasure = new Howl({
          src: [state.audioFile.measure]
        });
        commit("setSoundMeasure", soundMeasure);
      }
    },
    playAudioStart({ state }) {
      const howlState =
        state.soundStart === null ? null : state.soundStart.state();
      if (howlState === null || howlState === "unloaded") {
        // 再生する音声ファイルがない
        return false;
      }
      if (howlState === "loaded") {
        state.soundStart.play();
      } else {
        // 再生する音声ファイルが読み込み未完了
        state.soundStart.once("load", () => state.soundStart.play());
      }
    },
    playAudioErr({ state }) {
      const howlState =
        state.soundError === null ? null : state.soundError.state();
      if (howlState === null || howlState === "unloaded") {
        // 再生する音声ファイルがない
        return false;
      }
      if (howlState === "loaded") {
        state.soundError.play();
      } else {
        // 再生する音声ファイルが読み込み未完了
        state.soundError.once("load", () => state.soundError.play());
      }
    },
    playAudioSendOk({ state }) {
      const howlState =
        state.soundSendOk === null ? null : state.soundSendOk.state();
      if (howlState === null || howlState === "unloaded") {
        // 再生する音声ファイルがない
        return false;
      }
      if (howlState === "loaded") {
        state.soundSendOk.play();
      } else {
        // 再生する音声ファイルが読み込み未完了
        state.soundSendOk.once("load", () => state.soundSendOk.play());
      }
    },
    playAudioMeasure({ state }) {
      const howlState =
        state.soundMeasure === null ? null : state.soundMeasure.state();
      if (howlState === null || howlState === "unloaded") {
        // 再生する音声ファイルがない
        return false;
      }
      if (howlState === "loaded") {
        state.soundMeasure.play();
      } else {
        // 再生する音声ファイルが読み込み未完了
        state.soundMeasure.once("load", () => state.soundMeasure.play());
      }
    }
  },
  mutations: {
    setSoundError(state, howlObj) {
      state.soundError = howlObj;
    },
    setSoundStart(state, howlObj) {
      state.soundStart = howlObj;
    },
    setSoundSendOk(state, howlObj) {
      state.soundSendOk = howlObj;
    },
    setSoundMeasure(state, howlObj) {
      state.soundMeasure = howlObj;
    }
  }
};
