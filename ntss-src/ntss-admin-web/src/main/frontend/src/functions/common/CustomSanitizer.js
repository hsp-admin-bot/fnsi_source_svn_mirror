//#11219
/**
 * カスタム HTML 安全フィルタ関数
 * 「デフォルト拒否」方針で、ホワイトリスト内のタグとスタイルのみを許可し、XSS 攻撃を防御する
 * @param {string} rawHtml - 処理対象の元 HTML 文字列
 * @returns {string} 処理後の安全な HTML 文字列
 */
export const customSanitizer = (rawHtml) => {
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
        Array.from(node.childNodes).forEach(child => {
            if (child.nodeType === 1) {
                const tagName = child.tagName;

                // タグが許可されているか確認
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
};
