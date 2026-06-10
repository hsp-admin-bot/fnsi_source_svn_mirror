/**
 * @description message メッセージフォーマット化です
 * @param {String} msg ニュース
 * @param {Object} args パラメータ
 * @returns {String} ニュース
 */
export function messageFormat (msg, ...args) {
  for (let i = 0; i < args.length; i++) {
      msg = msg.replace(/{\$\d*}/, args[i])
  }
  // add 10977 by shiyw 20241031 start
  msg = msg.replaceAll('<br>', '\n');
  msg = msg.replaceAll('</br>', '\n');
  msg = msg.replaceAll('<BR>', '\n');
  msg = msg.replace(/</g, '&lt;').replace(/>/g, '&gt;')
  // add 10977 by shiyw 20241031 end
  return msg.replaceAll(/\n/g, '<br>')
}
