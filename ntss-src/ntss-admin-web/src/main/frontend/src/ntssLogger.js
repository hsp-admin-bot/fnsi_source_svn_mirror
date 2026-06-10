
import {
    outputLog
} from "@/apis/logging";


/**
 * ログ出力
 */
export default {
    /* eslint-disable no-unused-vars */
    /**
     * 初期処理
     * @param {*} Vue Vueオブジェクト
     * @param {*} options オプション(未使用)
     */
    install(Vue, options) {
        /**
         * 
         * @param {String} logLevel ログレベル
         * @param {LogMessage} content ログ内容
         */
        function log(logLevel, content) {
            // ログAPI呼出
            outputLog("app", logLevel, content);
        }

        /**
         * ログ出力
         */
        Vue.prototype.$log = {
            /**
             * 情報ログを出力する.
             * @param {LogMessage} content 
             */
            info(content) {
                log("info", content);
            },
            /**
             * 警告ログを出力する.
             * @param {LogMessage} content 
             */
            warn(content) {
                log("warn", content);
            },
            /**
             * エラーログを出力する.
             * @param {LogMessage} content 
             */
            error(content) {
                log("error", content);
            },
            /**
             * デバッグログを出力する.
             * @param {LogMessage} content 
             */
            debug(content) {
                log("debug", content);
            }
        };
    }
};
