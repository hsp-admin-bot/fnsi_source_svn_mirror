<template>
  <!-- #5590 2023/04/19 ×を常に表示するように修正 林峻峰 start -->
  <time-input
    :value="displayTimeValue"
    :classes="'time-input-focus ' +classes"
    @input="inputValue"
    v-on="$listeners"
    :disabled="disabled"
    @handleClearInput="handleClearEvent"
    :is-required="isRequired"
    :max="maxValue ? maxValue : '23:59'"
    :default-time="defaultTime"
  />
  <!-- #5590 2023/04/19 ×を常に表示するように修正 林峻峰 end -->
</template>

<script>
import moment from "moment";
// 共通タグ用ベースコンポーネント
import baseCustomForm from "@/components/common/custom-form-tags/BaseCustomForm.vue";
// #5590 2023/04/19 ×を常に表示するように修正 林峻峰 start
import TimeInput from "@/components/common/TimeInput.vue";
// #5590 2023/04/19 ×を常に表示するように修正 林峻峰 end

/**
 * @description 共通日時入力タグ
 * @summary
 *   ■props
 *     ・maxValue(任意): 入力可能上限値を指定する ※HH:mm形式
 *     ・minValue(任意): 入力可能下限値を指定する ※HH:mm形式
 *     ・outrangeLoop(任意): 入力可能上下限値を超えたときループするかどうかのフラグ ※デフォルト: しない
 *     ・minutesMode(任意): 分入力モードフラグ ※例: 「01:00」は60(分)を表す ※デフォルト: 普通に時分入力
 */
export default {
  mixins: [baseCustomForm],
  // #5590 2023/04/19 ×を常に表示するように修正 林峻峰 start
  components: {
    TimeInput
  },
  // #5590 2023/04/19 ×を常に表示するように修正 林峻峰 end

  props: {
    minValue: {
      type: String,
      default: null
    },
    maxValue: {
      type: String,
      default: null
    },
    outrangeLoop: {
      type: Boolean,
      default: false
    },
    minutesMode: {
      type: Boolean,
      default: false
    },
    isShowClear: {
      type: Boolean,
      default: false
    },
    disabled: {
      type: Boolean,
      default: false
    },
    /**
     * @description 補正に使用するデフォルト値。指定無しの場合はTimeinputでsysdateの時刻で補正。
     * "HH:mm"形式で指定してください。
     */
    defaultTime: {
      type: String,
      default: ""
    }
  },

  data() {
    return {
      // 入力フィールドの値をクリアするかを判定するフラグ
      isClear: false
    };
  },

  computed: {
    displayTimeValue() {
      // 画面で入力不備がある場合、入力値をクリアする
      if (this.editValue === null && this.isClear) {
        return "defaultValue";
      }
      if (this.minutesMode) {
        // 分→時分変換
        return this.editValue === null
          ? null
          : this.convertMinutesToTime(this.editValue);
      } else {
        return this.editValue === null
          ? null
          : moment(this.editValue, "HHmm").format("HH:mm");
      }
    },
    classes() {
      let classes = "";
      if (this.isTimeEdited()) {
        classes = "time-input-edited ";
      }
      if (this.isRequired) {
        classes += "time-input-required ";
      }
      if (!this.isValid) {
        classes += "time-input-invalid ";
      }
      return classes;
    }
  },

  methods: {
    // #5590 2023/04/19 ×を常に表示するように修正 林峻峰 start
    // inputValue(event) {
    inputValue(value) {
      // const inputTime = event.target.value;
    // #5590 2023/04/19 ×を常に表示するように修正 林峻峰 end
      const inputTime = value;
      // 入力フィールドの値をクリアするかを判定するフラグを初期化
      this.isClear = false;

      // 画面で入力不備がある場合、未入力状態にする
      if (inputTime === "aN:aN") {
        this.editValue = null;
        this.isClear = true;
        return;
      }

      if (inputTime !== "") {
        // 空欄じゃなければ上下限判定
        if (
          (this.minValue !== null && inputTime < this.minValue) ||
          (this.maxValue !== null && inputTime > this.maxValue)
        ) {
          // 上下限値を超える場合
          if (this.outrangeLoop) {
            // ループ設定時はループ
            let looptime;
            if (inputTime < this.minValue) {
              // 下限超えは上限に
              looptime = this.maxValue;
            } else {
              // 上限超えは下限に
              looptime = this.minValue;
            }
            if (this.minutesMode) {
              // 分変換
              this.editValue = this.convertTimeToMinutes(looptime);
            } else {
              this.editValue = moment(looptime, "HH:mm").format("HHmm");
            }
          } else {
            // ループ設定なしの場合は入力しない
            this.$el.value = this.displayTimeValue;
            // #5590 2023/04/19 ×を常に表示するように修正 林峻峰 start
            this.editValue = this.convertTimeToMinutes(value);
            // #5590 2023/04/19 ×を常に表示するように修正 林峻峰 end
          }
          return;
        }
      }
      if (this.minutesMode) {
        // 時分→分変換
        this.editValue =
          inputTime === "" ? null : this.convertTimeToMinutes(inputTime);
      } else {
        this.editValue =
            inputTime === "" ? null : moment(inputTime, "HH:mm").format("HHmm");
      }
    },

    /**
     * @description 時分→分変換
     */
    convertTimeToMinutes(time) {
      return moment.duration(time).asMinutes();
    },

    /**
     * @description 分→時分変換
     */
    convertMinutesToTime(minutes) {
      // 分を時間と分に
      const duration = moment.duration(minutes, "minutes");
      const hour = duration.hours();
      const minute = duration.minutes();
      // 時間と分からモーメントを作成しフォーマット
      const mo = moment();
      mo.hours(hour);
      mo.minutes(minute);
      return mo.format("HH:mm");
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20240227 ztc start
    isTimeEdited(){
      let editFlag = false;
      let initTimeValue = JSON.parse(JSON.stringify(this.initValue));
      let editTimeValue = JSON.parse(JSON.stringify(this.editValue));
      if(!!initTimeValue && typeof initTimeValue === 'string' && initTimeValue.indexOf(":") !== -1){
        initTimeValue = initTimeValue.replace(':','');
      }
      if(!!editTimeValue && typeof editTimeValue === 'string' && editTimeValue.indexOf(":") !== -1){
        editTimeValue = editTimeValue.replace(':','');
      }
      if(initTimeValue != editTimeValue){
        editFlag = true;
      }
      return editFlag;
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20240227 ztc end

    /* ===== #10704 ADD START ===== */
    // clear event
    handleClearEvent() {
      this.editValue = null;
      this.isClear = true;
      this.$emit("change", null)
    }
    /* ===== #10704 ADD END ===== */
  }
};
</script>

<style scoped>
input {
  font-family: helvetica, arial, "hiragino kaku gothic pro", meiryo,
    "ms pgothic", sans-serif;
  color: var(--ntss-list-body-color);
  background-color: var(--ntss-list-background-color);
}
</style>
