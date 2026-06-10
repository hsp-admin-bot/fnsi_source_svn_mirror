import { mapActions } from "vuex";
export default {
  data() {
    return {
      audioStartId: 0,
      /* add by chamaojia 2022-10-19 [5622] 音声再生できないBUG修正  --start */
      audioMeasureId: 0,
      audioSendOkId: 0,
      audioErrId: 0,
      /* add by chamaojia 2022-10-19 [5622] 音声再生できないBUG修正  --end */
      playAudioErrDelay: 0,
      playAudioSendOkDelay: 0,
      playAudioMeasureDelay: 0
    };
  },
  methods: {
    ...mapActions("send-condition/scale/audio", {
      initAudio: "initAudio",
      playAudioStart: "playAudioStart",
      playAudioErr: "playAudioErr",
      playAudioSendOk: "playAudioSendOk",
      playAudioMeasure: "playAudioMeasure"
    }),
    /**
     * 音声ガイダンス再生
     */
    playAudio(audioSetting) {
      const self = this;
      return {
        /**
         * "お乗りください"
         */
        patOk() {
          const canPlay = audioSetting.pat_ok === "1";
          let delay = audioSetting.pat_ok_delay;
          if (delay) {
            delay = delay * 1000;
          } else {
            delay = 0;
          }
          if (canPlay) {
            self.audioStartId = setTimeout(() => {
              self.playAudioStart();
            }, delay);
          }
        },
        /**
         * 測定値受信音
         */
        receiveWeight() {
          const canPlay = audioSetting.receive_weight === "1";
          let delay = audioSetting.receive_weight_delay;
          if (delay) {
            delay = delay * 1000;
          } else {
            delay = 0;
          }
          if (canPlay) {
            /* modify by chamaojia 2022-10-19 [5622] 音声再生できないBUG修正  --start */
            self.audioMeasureId = setTimeout(() => {
              self.playAudioMeasure();
            }, delay);
            /* modify by chamaojia 2022-10-19 [5622] 音声再生できないBUG修正  --end */
          }
        },
        /**
         * "測定しました"
         */
        sendOk() {
          const canPlay = audioSetting.send_ok === "1";
          let delay = audioSetting.send_ok_delay;
          if (delay) {
            delay = delay * 1000;
          } else {
            delay = 0;
          }
          if (canPlay) {
            /* modify by chamaojia 2022-10-19 [5622] 音声再生できないBUG修正  --start */
            self.audioSendOkId = setTimeout(() => {
              self.playAudioSendOk();
            }, delay);
            /* modify by chamaojia 2022-10-19 [5622] 音声再生できないBUG修正  --end */
          }
        },
        /**
         * エラー音
         */
        sendNg() {
          const canPlay = audioSetting.send_ng === "1";
          let delay = audioSetting.send_ng_delay;
          if (delay) {
            delay = delay * 1000;
          } else {
            delay = 0;
          }
          if (canPlay) {
            /* modify by chamaojia 2022-10-19 [5622] 音声再生できないBUG修正  --start */
            self.audioErrId = setTimeout(() => {
              self.playAudioErr();
            }, delay);
            /* modify by chamaojia 2022-10-19 [5622] 音声再生できないBUG修正  --end */
          }
        }
      };
    },
    stopDelayAudio() {
      const self = this;
      return {
        /**
         * "お乗りください"
         */
        patOk() {
          clearTimeout(self.audioStartId);
        },
        /**
         * 測定値受信音
         */
        receiveWeight() {
          clearTimeout(self.audioMeasureId);
        },
        /**
         * "測定しました"
         */
        sendOk() {
          clearTimeout(self.audioSendOkId);
        },
        /**
         * エラー音
         */
        sendNg() {
          clearTimeout(self.audioErrId);
        }
      }
    },
    stopDelayAudioAll() {
      clearTimeout(this.audioStartId);
      clearTimeout(this.audioMeasureId);
      clearTimeout(this.audioSendOkId);
      clearTimeout(this.audioErrId);
    }
  }
};
