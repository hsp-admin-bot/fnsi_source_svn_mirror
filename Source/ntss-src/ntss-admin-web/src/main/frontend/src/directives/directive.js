import debounce from "@/directives/debounce/index.js";
import throttle from "@/directives/throttle/index.js";
import monthWheel from "@/directives/monthWheel/index.js";
import kendoValidator, { installKendoValidatorInstanceState } from "@/directives/kendoValidator/index.js";
import rules from "@/directives/rules/index.js";


const directives = {
  debounce,
  throttle,
  monthWheel,
  kendoValidator,
  rules
};

//#11219 カスタム HTML 安全フィルタ指令への差し替え
function customSanitizer(rawHtml) {
  if (!rawHtml) return '';

  const parser = new DOMParser();
  const decodedHtml = rawHtml.replace(/\\"/g, '"');
  const doc = parser.parseFromString(decodedHtml, 'text/html');

  // 1. タグのホワイトリスト：'IMG' を追加
  const allowedTags = ['P', 'SPAN', 'BR', 'B', 'STRONG', 'I', 'EM', 'DEL', 'U', 'IMG'];

  // 2. スタイルのホワイトリスト：従来どおり、画像向けに width/height を追加
  const allowedStyles = [
    'font-family', 'font-size', 'color', 'background-color',
    'text-decoration', 'white-space', 'width', 'height'
  ];

  const sanitizeNode = (node) => {
    var htmlText = '';
    Array.from(node.childNodes).forEach(child => {
      if (child.nodeType === 1) {
        const tagName = child.tagName;

        // タグが許可されているか確認
        // console.log(allowedTags.includes(tagName),tagName);
        if (!allowedTags.includes(tagName)) {
          // 1. child ノードを文字列に変換する（タグ自体を含む）
          const nodeAsString = child.outerHTML;
          // 2. テキストノードを作成し、直前に変換した文字列を内容とする
          // 注意：createTextNode は < > などの文字を自動エスケープし、ブラウザによる HTML 解析を防ぐ
          const textNode = document.createTextNode(nodeAsString);
          child.parentNode.replaceChild(textNode, child);
          return;
        }

        // --- 属性処理ロジック ---
        const styles = child.style;
        const safeStylePairs = [];
        let safeSrc = '';

        // スタイルを処理
        allowedStyles.forEach(prop => {
          const value = styles.getPropertyValue(prop);
          if (value) safeStylePairs.push(`${prop}: ${value}`);
        });

        // IMG の src 属性を専用処理
        if (tagName === 'IMG') {
          const src = child.getAttribute('src') || '';
          // 安全検証：http、https、base64 画像のみ許可
          if (src.match(/^(https?:\/\/|data:image\/)/i)) {
            safeSrc = src;
          } else {
            const nodeAsString = child.outerHTML;
            // 2. テキストノードを作成し、直前に変換した文字列を内容とする
            // 注意：createTextNode は < > などの文字を自動エスケープし、ブラウザによる HTML 解析を防ぐ
            const textNode = document.createTextNode(nodeAsString);
            child.parentNode.replaceChild(textNode, child);
            return;
          }
        }

        // 元の属性をすべて削除（onerror、onclick などを除去）
        while (child.attributes.length > 0) {
          child.removeAttribute(child.attributes[0].name);
        }

        // 安全な属性を再設定
        if (safeStylePairs.length > 0) {
          child.setAttribute('style', safeStylePairs.join('; '));
        }
        if (tagName === 'IMG' && safeSrc) {
          child.setAttribute('src', safeSrc);
          // 画像がコンテナをはみ出さないようデフォルトスタイルを付与
          child.style.maxWidth = '100%';
        }

        sanitizeNode(child);
      }
    });
  };

  sanitizeNode(doc.body);
  return doc.body.innerHTML;
}

const updateSafeHtml = (el, binding) => {
  let value = binding.value;

  if (typeof value === 'string') {
    el.innerHTML = customSanitizer(value);
    return;
  }
  const bbs = binding.value || {};
  const title = bbs.title || '';
  const content = bbs.html_content || '';

  // 結合ロジック
  const combined = title ? `${title}<br />${content}` : content;

  // 安全フィルタを適用して描画
  el.innerHTML = customSanitizer(combined);
};

export default {
  install(app) {
    installKendoValidatorInstanceState(app);
    Object.keys(directives).forEach((key) => {
      app.directive(key, directives[key]);
    });
    app.directive("safe-html", {
      mounted: updateSafeHtml,
      updated: updateSafeHtml
    });
  }
};
