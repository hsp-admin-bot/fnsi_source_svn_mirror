import { describe, expect, test } from "vitest";
import {
  createMemoryHistory,
  createRouter,
  hydrateLegacyRouteParams,
  normalizeLegacyNamedRouteLocation
} from "@/compat/vue/router";

function createCompatRouter() {
  return createRouter({
    history: createMemoryHistory(),
    routes: [
      {
        path: "/",
        name: "root"
      },
      {
        path: "/indication/list/detail/receive/:patId",
        name: "indication-receive-details"
      },
      {
        path: "/pat-group/list/edit/:patGroupCd",
        name: "pat-group-edit"
      }
    ]
  });
}

function createAppCompatRouter() {
  const router = createCompatRouter();
  router.beforeEach((to) => {
    hydrateLegacyRouteParams(to);
    return true;
  });
  return router;
}

describe("Vue2 route params compatibility", () => {
  test("keeps child path slash routes under their Vue2 parent route", () => {
    const router = createRouter({
      history: createMemoryHistory(),
      routes: [
        {
          path: "/report-menu",
          redirect: { name: "report-menu" },
          children: [
            {
              path: "/",
              name: "report-menu"
            }
          ]
        }
      ]
    });

    expect(router.resolve({ name: "report-menu" }).path).toBe("/report-menu/");
  });

  test("keeps undeclared params out of the URL while restoring them to route params", () => {
    const router = createCompatRouter();
    const _id = ["69f2e47181ba7900de672af9", "69f2e47181ba7900de672afa"];

    const normalized = normalizeLegacyNamedRouteLocation({
      name: "indication-receive-details",
      params: {
        patId: "64782",
        _id,
        method: "receive"
      }
    }, router);

    expect(normalized.params).toEqual({ patId: "64782" });
    expect(normalized.query).toEqual({});

    const route = {
      name: "indication-receive-details",
      params: { patId: "64782" },
      query: {}
    };

    hydrateLegacyRouteParams(route);

    expect(route.params._id).toBe(_id);
    expect(route.params.method).toBe("receive");
  });

  test("restores undeclared params on the active route after navigation", async () => {
    const router = createAppCompatRouter();
    const _id = ["69f2e47181ba7900de672af9", "69f2e47181ba7900de672afa"];

    await router.push({
      name: "indication-receive-details",
      params: {
        patId: "64782",
        _id,
        method: "receive"
      }
    });

    expect(router.currentRoute.value.params).toMatchObject({
      patId: "64782",
      _id,
      method: "receive"
    });
  });

  test("preserves Vue2 hidden context params such as sameList", () => {
    const router = createCompatRouter();
    const sameList = [{ pat_id: 1, is_same: 1 }];

    const normalized = normalizeLegacyNamedRouteLocation({
      name: "pat-group-edit",
      params: {
        patGroupCd: "123",
        sameList
      }
    }, router);

    expect(normalized.params).toEqual({ patGroupCd: "123" });
    expect(normalized.query).toEqual({});

    const route = {
      name: "pat-group-edit",
      params: { patGroupCd: "123" },
      query: {}
    };

    hydrateLegacyRouteParams(route);

    expect(route.params.sameList).toBe(sameList);
  });

  test("preserves hidden params on guard redirects when normalized by the guard", async () => {
    const router = createCompatRouter();
    const sameList = [{ pat_id: 1, is_same: 1 }];

    router.beforeEach((to) => {
      hydrateLegacyRouteParams(to);
      if (to.name !== "root") {
        return true;
      }
      return normalizeLegacyNamedRouteLocation({
        name: "pat-group-edit",
        params: {
          patGroupCd: "123",
          sameList
        }
      }, router);
    });

    await router.push({ name: "root" });

    expect(router.currentRoute.value.name).toBe("pat-group-edit");
    expect(router.currentRoute.value.params).toMatchObject({
      patGroupCd: "123",
      sameList
    });
  });
});
