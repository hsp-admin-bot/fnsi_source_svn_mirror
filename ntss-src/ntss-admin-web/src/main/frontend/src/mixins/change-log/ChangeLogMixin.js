// fix 2026/03/12 変更ログ mixin lichaolong start
import { ApiHelper } from "@/apis/AxiosHelper";
import { CHANGE_LOG_ACTION_TYPE } from './ChangeLogSymbols';
import { EventBus } from "@/eventBus.js";

const unWatchers = [];

export default {
  data() {
    return {
      flag: false
    }
  },
  // Symbol を inject key として使用し、文字列の競合を回避する
  inject: {
    [CHANGE_LOG_ACTION_TYPE]: {
      from: CHANGE_LOG_ACTION_TYPE,
      default: null
    }
  },
  created() {
    // 変更ログイベントのバインドは mounted フックで行う（DOM が利用可能な状態で初期スナップショットを取得するため）
    EventBus.$on('apiSuccess',() => {
      if (this.useMixinChangeLogGetActionType() === 'UPDATE' && !this.flag) {
        console.log('API success event received in ChangeLogMixin');
        this.flag = true
        setTimeout(() => {
          this.useMixinChangeLogSetInitial()      
        }, 1000);
      }
    })
  },
  mounted() {
    // 共通の mounted ロジック：component のスナップ取得と saveRecord 包装
    this.$nextTick(() => {
      // イベントバインドの初期化
      this.useMixinChangeLogBindEvent();
      // component 内の特定のデータをウォッチして、変更があったらスナップショットを更新する（柔軟に関数 getter を受け付ける）
      const setupWatcher = (getter, handler, callback) => {
        if (typeof handler !== 'function') return;
        if (typeof getter === 'function') {
          const unWatcher = this.$watch(getter.bind(this), (value) => {
            handler.call(this, value);
            callback && callback();
          }, { deep: true });
          unWatchers.push(unWatcher);
        } else if (typeof getter === 'string') {
          const unWatcher = this.$watch(getter, (value) => {
            handler.call(this, value);
            callback && callback();
          }, { deep: true });
          unWatchers.push(unWatcher);
        }
      };

      // useMixinChangeLogWatcher は配列形式のみを受け付けます。
      // 推奨形式: [ [getterFn, handlerFn], [getterFn, handlerFn], ... ]
      const watchers = this.useMixinChangeLogWatcher;
      if (!Array.isArray(watchers)) {
        // no watchers configured or wrong format — silently ignore
      } else {
        watchers.forEach(entry => {
          if (Array.isArray(entry) && entry.length >= 2) {
            setupWatcher(entry[0], entry[1], entry[2]);
          }
        });
      }

      if (this[this.useMixinChangeLogGetFuncName()] && !this.__wrapped_saveRecord) {
        const orig = this[this.useMixinChangeLogGetFuncName()].bind(this);
        const self = this;
        this.__wrapped_saveRecord = true;
        this[this.useMixinChangeLogGetFuncName()] = async function (...args) {
          const type = self.useMixinChangeLogGetActionType();
          const before = type === 'UPDATE' ? self._changeLog_initialSnapshot : {};
          const res = await orig(...args);
          const after = self.useMixinChangeLogCaptureMainSnapshot(self);
          const diffs = self.useMixinChangeLogComputeDiff(before, after);
          console.log('before:', before);
          console.log('after:', after);
          const pageName = (self.useMixinChangeLogGetPageName && typeof self.useMixinChangeLogGetPageName === 'function') ? self.useMixinChangeLogGetPageName() : '';
          const funcName = (self.useMixinChangeLogGetFunctionName && typeof self.useMixinChangeLogGetFunctionName === 'function') ? self.useMixinChangeLogGetFunctionName() : '';
          const message = diffs.map(d => type === 'UPDATE' ? `${d.key}:${d.beforeValue}-----→${d.afterValue}` : `${d.key}:${d.afterValue}`).filter(Boolean).join('<br/>');
          const log = { type, pageName, btnName: '保存', message: message ? `<br/>${message}<br/>` : '', functionName: funcName };
          console.log('Change log to send:', log);
          try {
            if(!message) return
            await self.useMixinChangeLogSendChangeLog(log);
            if (type === 'UPDATE') self.useMixinChangeLogSetInitial(); // 保存後の状態を次の変更前の状態としてセット
          } catch (e) {
            // noop
          }
          return res;
        };
      }
    });
  },
  methods: {
    useMixinChangeLogSetInitial () {
      this._changeLog_initialSnapshot = this.useMixinChangeLogCaptureMainSnapshot(this);
      console.log('Initial snapshot for change log:', this._changeLog_initialSnapshot);
    },
    // 変更ログのイベント名を取得するためのメソッド
    // return 変更ログを発火させるイベント名（例: 'save'）
    useMixinChangeLogGetEventName() {
      if (this.useMixinChangeLogEmitName) return this.useMixinChangeLogEmitName;
      return '';
    },
    // 変更ログのイベントを初期化するためのメソッド
    useMixinChangeLogBindEvent() {
      // 初期スナップショットを取得する関数
      const useMixinChangeLogSetInitial = () => {
        this._changeLog_initialSnapshot = this.useMixinChangeLogCaptureMainSnapshot(this);
        console.log('Initial snapshot for change log:', this._changeLog_initialSnapshot);
      };
      if (this.useMixinChangeLogGetEventName()) {
        const self = this;
        this.$on(this.useMixinChangeLogGetEventName(), async function () {
          const type = self.useMixinChangeLogGetActionType();
          const before = type === 'UPDATE' ? self._changeLog_initialSnapshot : {};
          const after = self.useMixinChangeLogCaptureMainSnapshot(self);
          const diffs = self.useMixinChangeLogComputeDiff(before, after);
          const pageName = (self.useMixinChangeLogGetPageName && typeof self.useMixinChangeLogGetPageName === 'function') ? self.useMixinChangeLogGetPageName() : '';
          const funcName = (self.useMixinChangeLogGetFunctionName && typeof self.useMixinChangeLogGetFunctionName === 'function') ? self.useMixinChangeLogGetFunctionName() : '';
          const message = diffs.map(d => type === 'UPDATE' ? `${d.key}:${d.beforeValue}-----→${d.afterValue}` : `${d.key}:${d.afterValue}`).filter(Boolean).join('<br/>');
          const log = { type, pageName, btnName: '保存', message: message ? `<br/>${message}<br/>` : '', functionName: funcName };
          console.log('Change log to send:', log);
          try {
            if(!message) return
            await self.useMixinChangeLogSendChangeLog(log);
            if (type === 'UPDATE') useMixinChangeLogSetInitial(); // 保存後の状態を次の変更前の状態としてセット
          } catch (e) {
            // noop
          }
        });
      }
    },
    // 値をトリムする
    useMixinChangeLogTrimValue(found, val) {
      if (found) {
        return typeof found.name === 'string' ? found.name.trim() : ((val === undefined || val === null) ? '空値' : val);
      } else {
        return (val === undefined || val === null) ? '空値' : val;
      }
    },

    // action type の取得：優先的に注入された changeLogActionType を使用し、次にコンポーネントで実装された useMixinChangeLogActionType にフォールバックし、最後にデフォルトの 'INSERT' を使用する
    useMixinChangeLogGetActionType() {
      // 注入された action type があればそれを使用する
      if (this[CHANGE_LOG_ACTION_TYPE]) return this[CHANGE_LOG_ACTION_TYPE];
      if (typeof this.useMixinChangeLogActionType === 'function') return this.useMixinChangeLogActionType();
      return 'INSERT';
    },

    // 辞書オプションの取得：コンポーネントが useMixinChangeLogDictOptions メソッドを実装している場合は、そのメソッドを呼び出してオプションを取得します。そうでない場合は、空の配列を返します。
    useMixinChangeLogGetDictOptions(key, val, idx, getByPath) {
      if (typeof this.useMixinChangeLogActionType === 'function') return this.useMixinChangeLogDictOptions(key, val, idx, getByPath);
      return [];
    },
    // 関数名の取得：コンポーネントが useMixinChangeLogFuncName プロパティを実装している場合、それを使用して関数名を取得します。そうでない場合は、デフォルトで 'saveRecord' となります。
    useMixinChangeLogGetFuncName() {
      if (this.useMixinChangeLogFuncName) return this.useMixinChangeLogFuncName;
      return 'saveRecord';
    },
    // 初期スナップショットを取得する（主に mainComponent のデータをシリアライズ）
    // 戻り値は path->{tag, attrs, text} のマップを JSON で返す。
    useMixinChangeLogCaptureMainSnapshot(target) {
      // fix 変更ログ: `useMixinChangeLogSubject` の定義に従って対象から値を抜き出す
      // 引数 `this` は component インスタンスを想定する。
      try {
        const subject = (target && target.useMixinChangeLogSubject) || this.useMixinChangeLogSubject;
        if (!subject || typeof subject !== "object") return {};

        // パスの分割トークンに従ってオブジェクトを再帰的にたどる。
        // 配列に到達した場合は、残りのパスを各要素に対して再帰的に適用し、最終的に基本型の配列を文字列に結合して返す。
        // 追加: reentrancy を防ぐため、現在処理中の path を追跡するガードを導入する。
        const activePaths = new Set();
        const getByPath = (obj, path) => {
          if (obj == null || !path) return null;
          if (activePaths.has(path)) return null; // 同じ path の再入を防止
          activePaths.add(path);
          try {
            const tokens = path.split('.');
            const traverse = (current, idx) => {
              if (current == null) return null;
              if (idx >= tokens.length) return current;
                const part = tokens[idx];
                const next = current[part];
                if (next == null) return null;
                // 次のトークンが残っていて next が配列なら、各要素に対して残りのパスを適用する
                if (Array.isArray(next)) {
                  const restIdx = idx + 1;
                  if (restIdx >= tokens.length) {
                    return next;
                  }
                  let mapped = [];
                  if (tokens[restIdx] && typeof Number(tokens[restIdx]) == 'number' && !isNaN(tokens[restIdx])) {
                    return traverse(next[tokens[restIdx]], restIdx + 1);
                  } else {
                    mapped = next.map(item => traverse(item, restIdx));
                  }
                  // flatten 一段階
                  const flattened = [].concat.apply([], mapped.filter(v => v !== null && v !== undefined));
                  return flattened.length === 0 ? null : flattened;
                }
                return traverse(next, idx + 1);
            };
            let cur = traverse(obj, 0);

            if (Array.isArray(cur)) {
              try {
                const mapped = cur.map((item, index) => {
                  const options = this.useMixinChangeLogGetDictOptions(path, item, index, getByPath.bind(this));
                  if (options && options.length > 0) {
                    const found = options.find(opt => opt.code === item);
                    return this.useMixinChangeLogTrimValue(found, item);
                  }
                  return  this.useMixinChangeLogTrimValue(undefined, item);
                });
                return mapped;
              } catch (e) {
                return null;
              }
            }
            const options = this.useMixinChangeLogGetDictOptions(path, cur, -1, getByPath.bind(this));
            if (options && options.length > 0) {
              const found = options.find(opt => opt.code === cur);
              return this.useMixinChangeLogTrimValue(found, cur);
            }
            return this.useMixinChangeLogTrimValue(undefined, cur);
          } finally {
            activePaths.delete(path);
          }
        };

        const out = {};
        Object.entries(subject).forEach(([funcName, pathOrPaths]) => {
          const paths = Array.isArray(pathOrPaths) ? pathOrPaths : [pathOrPaths];
          const values = paths.map(p => {
            try {
              return getByPath(target, p);
            } catch (e) {
              return null;
            }
          });
          out[funcName] = values.length === 1 ? values[0] : values;
        });
        return JSON.parse(JSON.stringify(out)); // 値をシリアライズして安定化（Vue のリアクティブオブジェクトを普通のオブジェクトに変換）
      } catch (e) {
        return {};
      }
    },

    // DOM スナップショット（path->nodeObj マップ）を比較して差分を返す
    useMixinChangeLogComputeDiff(beforeMap, afterMap) {
      // fix 変更ログ: useMixinChangeLogCaptureMainSnapshot が返す funcName->value マップ同士を比較する
      const diffs = [];
      beforeMap = beforeMap || {};
      afterMap = afterMap || {};
      const keys = new Set([...Object.keys(beforeMap), ...Object.keys(afterMap)]);
      keys.forEach(k => {
        const b = beforeMap.hasOwnProperty(k) ? beforeMap[k] : null;
        const a = afterMap.hasOwnProperty(k) ? afterMap[k] : null;
        
        // ここで b と a を文字列化して比較する。
        // 追加: 両方とも配列の場合は交差要素を取り除いてから比較する。
        let bstr;
        let astr;
        if (Array.isArray(b) && Array.isArray(a)) {
          try {
            const norm = arr => arr.map(x => {
              try { return JSON.stringify(x); } catch (e) { return String(x); }
            });
            const nb = norm(b);
            const na = norm(a);
            const aSet = new Set(na);
            const bSet = new Set(nb);
            // intersection based on normalized string values
            const inter = new Set([...nb].filter(x => aSet.has(x)));
            const beforeOnly = b.filter((item, idx) => !inter.has(nb[idx]));
            const afterOnly = a.filter((item, idx) => !inter.has(na[idx]));
            bstr = JSON.stringify(beforeOnly);
            astr = JSON.stringify(afterOnly);
          } catch (e) {
            bstr = JSON.stringify(b);
            astr = JSON.stringify(a);
          }
        } else {
          bstr = Array.isArray(b) ? JSON.stringify(b) : this.useMixinChangeLogTrimValue(undefined, b);
          astr = Array.isArray(a) ? JSON.stringify(a) : this.useMixinChangeLogTrimValue(undefined, a);
        }

        if (bstr !== astr) {
          diffs.push({ key: k, beforeValue: bstr, afterValue: astr });
        }
      });
      return diffs;
    },

    // bread-crumbs-component からページ名を取得する
    useMixinChangeLogGetPageName() {
      try {
        // まず既知の DOM id を探す
        const linkDivObj = document.getElementById(
          "BreadCrumbsComponent_breadcrumb_content_area"
        );
        if (linkDivObj) {
          const links = linkDivObj.getElementsByTagName("a");
          if (links && links.length > 0) {
            return links[links.length - 1].text || "";
          }
        }
        // 次に ref があればそこから取得
        if (this.$refs && this.$refs.breadCrumbs) {
          const el = this.$refs.breadCrumbs.$el || this.$refs.breadCrumbs;
          if (el) {
            const text = el.innerText || el.textContent || "";
            if (text) return text.trim();
          }
        }
      } catch (e) {
        // noop
      }
      return "";
    },

    // bread-crumbs-component から最初の要素を機能名として取得する
    useMixinChangeLogGetFunctionName() {
      try {
        const linkDivObj = document.getElementById(
          "BreadCrumbsComponent_breadcrumb_content_area"
        );
        if (linkDivObj) {
          const links = linkDivObj.getElementsByTagName("a");
          if (links && links.length > 0) {
            return links[0].text || "";
          }
        }
        if (this.$refs && this.$refs.breadCrumbs) {
          const el = this.$refs.breadCrumbs.$el || this.$refs.breadCrumbs;
          if (el) {
            // 取テキストのうち最初の行を機能名とみなす
            const text = (el.innerText || el.textContent || "").trim();
            if (text) {
              const parts = text.split(/\n+/);
              return parts.length ? parts[0].trim() : text;
            }
          }
        }
      } catch (e) {
        // noop
      }
      return "";
    },

    // サーバに送る（既存 API と同じエンドポイントを利用）
    async useMixinChangeLogSendChangeLog({ pageName, btnName, message, functionName = '掲示板', dataId = null }) {
      try {
        const param = {
          pageName,
          btnName,
          message,
          functionName,
          dataId
        };
        // 送信（失敗しても処理を止めない）
        await ApiHelper.put('/logs/event/dataChanged', param).catch(() => { });
      } catch (e) {
        // noop
      }
    }
  },
  beforeDestroy() {
    // 注意：ウォッチャーはコンポーネントが破棄されるときに解除する必要があります。ここでは簡略化のために実装していませんが、実際には beforeDestroy フックなどで
    unWatchers.forEach(unwatch => unwatch());
    EventBus.$off('apiSuccess');
    this.flag = false;
  }
};
// fix 2026/03/12 変更ログ mixin lichaolong end
