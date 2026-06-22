import Vue3TouchEvents from "vue3-touch-events";

export default {
  install(app, options = {}) {
    app?.use?.(Vue3TouchEvents, {
      disableClick: false,
      tapTolerance: 10,
      swipeTolerance: 50,
      longTapTimeInterval: 400,
      ...options
    });
  }
};
