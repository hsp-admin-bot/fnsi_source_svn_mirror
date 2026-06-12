<script>
import {
  multiplyDecimal,
  divideDecimal,
  plusDecimal
} from "@/functions/treatment-record/NumberFunctions.js";
import BigNumber from "@/compat/number/bignumber";

const ARROW_UP_KEYCODE = 38;
const ARROW_DOWN_KEYCODE = 40;

export default {
  props: {
    unitName: {
      type: String
    },
    step: {
      type: Number,
      default: 1
    },
    min: {
      type: Number
    },
    max: {
      type: Number
    },
    base: {
      type: Number,
      default: 1
    },
    //add FNSI修正-redmine4745 房 start
    initValue: {
      type: Number
    }
    //add FNSI修正-redmine4745 房 end
  },
  computed: {
    // currentValue: {
    //   get() {
    //     // Mixinを組み込む側で実装
    //     return null;
    //   },
    //   set() {
    //     // Mixinを組み込む側で実装
    //   }
    // },
    decimalLength() {
      const numbers = String(new BigNumber(this.step).toFixed()).split(".");
      return numbers[1] ? numbers[1].length : 0;
    }
  },
  methods: {
    /**
     * blurイベントハンドラ.
     */
    onBlur(event) {
      //mod FNSI修正-redmine4745 房 start
      if (this.initValue !== this.currentValue) {
        // mod 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 start
        let nowValue = this.currentValue;
        // mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue start
        // this.currentValue = 0;
        this.currentValue = null;
        // mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue end
        this.$nextTick(() => {
          if (nowValue) {
            // add #5589 数値が焦点を失い、入力が最大値より大きく、最小値より小さくなった場合です。最大値最小値を表示します 林峻峰 start
            // if (this.max && nowValue > this.max) {
            //   nowValue = this.max;
            // }
            // if (this.min && nowValue < this.min) {
            //   nowValue = this.min;
            // }
            if (nowValue == this.inputMax && this.blurFlg) {
              nowValue = this.inputMin;
              this.blurFlg = false
            }else if (nowValue == this.inputMin && this.blurFlg) {
              nowValue = this.inputMax;
              this.blurFlg = false
            }
            // add #5589 数値が焦点を失い、入力が最大値より大きく、最小値より小さくなった場合です。最大値最小値を表示します 林峻峰 end
            this.currentValue = this.getRoundedValue(Number(nowValue));
          } else {
            this.currentValue = null;
          }
          // del #11416 【たくしん会】治療記録＞再循環率の入力IFバグ　V1.0B linjunfeng start
          // this.$emit("blur", event);
          // del #11416 【たくしん会】治療記録＞再循環率の入力IFバグ　V1.0B linjunfeng end
        });
        // mod 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 end
      }
      // add #11416 【たくしん会】治療記録＞再循環率の入力IFバグ　V1.0B linjunfeng start
      this.$nextTick(() => {
        this.$emit("blur", event);
      });
      // add #11416 【たくしん会】治療記録＞再循環率の入力IFバグ　V1.0B linjunfeng end
      //mod FNSI修正-redmine4745 房 end
    },
    /**
     * keypressイベントハンドラ.
     */
    onKeyPress(event) {
      if ("0123456789.-".indexOf(event.key) < 0) {
        event.preventDefault();
      }
    },
    /**
     * keydownイベントハンドラ.
     */
    onKeyDown(event) {
      if ([ARROW_UP_KEYCODE, ARROW_DOWN_KEYCODE].includes(event.keyCode)) {
        // カーソルキー上下での値増減
        this.currentValue = this.getRoundedValue(
          plusDecimal(
            Number(this.currentValue),
            this.step * (event.keyCode === ARROW_UP_KEYCODE ? 1 : -1)
          )
        );
        event.preventDefault();
      }
    },
		onMousewheel(event){
			//console.log(document.activeElement)
			//console.log(event.target)
			const ownerDocument = event?.target?.ownerDocument || this.$el?.ownerDocument || document;
			if(event.target === ownerDocument.activeElement){
				this.currentValue = this.getRoundedValue(
				  plusDecimal(
					Number(this.currentValue),
					this.step * (event.wheelDelta > 0 ? 1 : -1)
				  )
				);
				event.preventDefault();
				// console.log(event)
			}
		},
    /**
     * 数値の丸め処理(計算の中身).
     */
    getRoundedValue(value) {
      if (value == null) {
        // 数値でない場合はnullを返す
        return null;
      }

      // 小数点の切り捨て
      // TODO step数が0.3など、中途半端な（10であまりがでるような数値）ものは考慮していない
      const log = this.step ? Math.log10(this.step) : null;
      if (!log) {
        // stepが指定されていないもしくは1(Math.log10が0になる)の場合、小数点以下を切り捨て
        value = Math.floor(value);
      } else if (log && log < 0 && Number.isInteger(Math.abs(log))) {
        // stepが小数点(0.1, 0.01, 0.001, ..など)で指定されている場合、指定の桁数内で切り捨てる
        const multiple = 10 ** Math.abs(log);
        value = divideDecimal(
          Math.floor(multiplyDecimal(value, multiple)),
          multiple
        );
      }

      //add FNSI-修正 最大、最小が未設定 孫灝 20201028 start
      // 最大、最小が未設定
      // if (!this.min || !this.max) {
      //   return value;
      // }
      let isMinExist = Number(this.min) ? true : this.min == 0 ? true : false;
      let isMaxExist = Number(this.max) ? true : this.max == 0 ? true : false;
      if (!isMinExist || !isMaxExist) {
        return value;
      }
      //add FNSI-修正 最大、最小が未設定 孫灝 20201028 end

      // 数値の丸め
      if (value < this.min) {
        value = this.min;
      } else if (value > this.max) {
        value = this.max;
      }

      return value;
    },
    /**
     * 値の丸め.
     */
    roundValue() {
      this.currentValue = this.getRoundedValue(Number(this.currentValue));
    }
  }
};
</script>
