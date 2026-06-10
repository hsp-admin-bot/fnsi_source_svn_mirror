// import _throttle from 'lodash/debounce'
// let fn = null
const throttle = {
  // inserted: function(el, binding) {
  //   fn = _throttle(binding.value, 2000, {
  //     leading: true,
  //     trailing: false
  //   })
  //   el.addEventListener('click', fn)
  // },
  // unbind: function(el) {
  //   fn && el.removeEventListener('click', fn)
  // }
  bind: function (el, binding) {
    let throttleTime = binding.value;
    if (!throttleTime) {
      throttleTime = 2000;
    }
    let cbFun;
    el.addEventListener('click', event => {
      if (!cbFun) {
        cbFun = setTimeout(() => {
          cbFun = null;
        }, throttleTime);
      } else {
        event && event.stopImmediatePropagation();
      }
    }, true);
  }
}

export default throttle
