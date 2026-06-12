/**
 * Vue Router 4 reads beforeRoute* from component options directly and does not
 * resolve mixins. Hoist merged guards onto route components at router init.
 */
const ROUTE_GUARD_TYPES = ["beforeRouteEnter", "beforeRouteUpdate", "beforeRouteLeave"];

function chainNavigationGuards(guards) {
  if (!guards.length) {
    return undefined;
  }
  if (guards.length === 1) {
    return guards[0];
  }

  return function chainedNavigationGuard(to, from, next) {
    const runGuardAt = (index) => {
      const guard = guards[index];
      if (!guard) {
        next();
        return;
      }

      if (guard.length >= 3) {
        guard.call(this, to, from, (valid) => {
          if (valid === false) {
            next(false);
          } else if (valid != null && valid !== true) {
            next(valid);
          } else {
            runGuardAt(index + 1);
          }
        });
        return;
      }

      let result;
      try {
        result = guard.call(this, to, from);
      } catch (error) {
        next(error);
        return;
      }

      if (result && typeof result.then === "function") {
        result
          .then((valid) => {
            if (valid === false) {
              next(false);
            } else if (valid != null && valid !== true) {
              next(valid);
            } else {
              runGuardAt(index + 1);
            }
          })
          .catch((error) => next(error));
        return;
      }

      if (result === false) {
        next(false);
      } else if (result != null && result !== true) {
        next(result);
      } else {
        runGuardAt(index + 1);
      }
    };

    runGuardAt(0);
  };
}

function collectRouteGuards(opts, guardType, collected = []) {
  if (!opts || typeof opts !== "object") {
    return collected;
  }

  const mixins = opts.mixins;
  if (Array.isArray(mixins)) {
    mixins.forEach((mixin) => {
      collectRouteGuards(mixin?.__vccOpts || mixin, guardType, collected);
    });
  }

  const guard = opts[guardType];
  if (typeof guard === "function") {
    collected.push(guard);
  } else if (Array.isArray(guard)) {
    guard.filter((entry) => typeof entry === "function").forEach((entry) => collected.push(entry));
  }

  return collected;
}

/**
 * Match Vue option merge: component guard replaces mixin guards when declared.
 */
function resolveRouteGuard(opts, guardType) {
  if (!opts || typeof opts !== "object") {
    return undefined;
  }

  const ownGuard = opts[guardType];
  if (typeof ownGuard === "function") {
    return ownGuard;
  }
  if (Array.isArray(ownGuard) && ownGuard.length > 0) {
    return chainNavigationGuards(ownGuard.filter((entry) => typeof entry === "function"));
  }

  const mixinGuards = collectRouteGuards({ ...opts, [guardType]: undefined }, guardType);
  return chainNavigationGuards(mixinGuards);
}

export function hoistRouteGuardsOnComponent(component) {
  if (!component || typeof component !== "object") {
    return;
  }

  const opts = component.__vccOpts || component;
  if (!opts || typeof opts !== "object") {
    return;
  }

  ROUTE_GUARD_TYPES.forEach((guardType) => {
    const resolved = resolveRouteGuard(opts, guardType);
    if (resolved) {
      opts[guardType] = resolved;
    }
  });
}

function hoistRouteGuardsOnRoutes(routes) {
  if (!Array.isArray(routes)) {
    return;
  }

  routes.forEach((route) => {
    if (route?.component) {
      hoistRouteGuardsOnComponent(route.component);
    }
    if (route?.components) {
      Object.values(route.components).forEach(hoistRouteGuardsOnComponent);
    }
    if (Array.isArray(route?.children)) {
      hoistRouteGuardsOnRoutes(route.children);
    }
  });
}

/** Vue Router 4: hoist mixin beforeRoute* only for 治療記録 submenu route components. */
export function hoistTreatmentRecordRouteGuards(routes) {
  if (!Array.isArray(routes)) {
    return;
  }

  routes.forEach((route) => {
    if (route.path === "/treatment-record" && Array.isArray(route.children)) {
      hoistRouteGuardsOnRoutes(route.children);
      return;
    }
    if (Array.isArray(route.children)) {
      hoistTreatmentRecordRouteGuards(route.children);
    }
  });
}
