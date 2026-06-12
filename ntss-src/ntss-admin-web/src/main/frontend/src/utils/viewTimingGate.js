import { nextTick } from "@/compat/vue/runtime";

export function createViewTimingGate(name = "view") {
  const state = {
    name,
    alive: true,
    epoch: 0,
    pending: new Map(),
    timers: new Set()
  };

  const api = {
    name() {
      return state.name;
    },
    capture() {
      return state.epoch;
    },
    isAlive() {
      return state.alive;
    },
    isCurrent(token) {
      return state.alive && token === state.epoch;
    },
    invalidate() {
      if (state.alive) {
        state.epoch += 1;
      }
      return state.epoch;
    },
    destroy() {
      state.alive = false;
      state.epoch += 1;
      state.pending.clear();
      state.timers.forEach((timerId) => clearTimeout(timerId));
      state.timers.clear();
    },
    schedule(name, runner, options = {}) {
      const token = options.token ?? state.epoch;
      const retries = Number.isFinite(options.retries) ? options.retries : 6;
      const delay = Number.isFinite(options.delay) ? options.delay : 16;
      const scheduler = typeof options.scheduler === "function"
        ? options.scheduler
        : (job) => nextTick(job);

      if (!state.alive) {
        return Promise.resolve(false);
      }
      if (name) {
        state.pending.set(name, token);
      }

      return new Promise((resolve) => {
        let remaining = retries;
        const attempt = () => {
          if (name && state.pending.get(name) !== token) {
            resolve(false);
            return;
          }
          if (!api.isCurrent(token)) {
            if (name) {
              state.pending.delete(name);
            }
            resolve(false);
            return;
          }

          const result = runner();
          if (result !== false) {
            if (name) {
              state.pending.delete(name);
            }
            resolve(result);
            return;
          }

          if (remaining <= 0) {
            if (name) {
              state.pending.delete(name);
            }
            resolve(false);
            return;
          }

          remaining -= 1;
          if (delay > 0) {
            const timerId = setTimeout(() => {
              state.timers.delete(timerId);
              scheduler(attempt);
            }, delay);
            state.timers.add(timerId);
          } else {
            scheduler(attempt);
          }
        };

        attempt();
      });
    }
  };

  return api;
}
