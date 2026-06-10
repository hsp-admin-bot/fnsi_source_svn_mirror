--DROP FUNCTION ntss.calBodyFluid ;
CREATE OR REPLACE FUNCTION ntss.cal_body_fluid 
  (bef_weight text, aft_weight text,
  dialysis_time text, bef_bun text, aft_bun text,
  total_remove_water text, blood text, dialysis_fluid text,
  koa text, recycling_rate text) RETURNS decimal AS
$$
  DECLARE
    i integer := 0;
    blood_per_min decimal;
    bun_rate decimal;
    calc_koa decimal;
    k1 decimal;
    body_water decimal;
    dbw decimal;
    p1 decimal;
    p2 decimal;
    p3 decimal;
    p4 decimal;
    k0 decimal;
    k2 decimal;
    rr decimal;
  BEGIN
    blood_per_min := blood::decimal / dialysis_time::decimal;
    bun_rate := aft_bun::decimal / bef_bun::decimal;
    rr := recycling_rate::decimal / 100;
    calc_koa := (-1.1985 + 0.81572 * 0.4343 * LOG(dialysis_fluid::decimal)) * koa::decimal;
    k1 := (LOG(bun_rate - 0.008 * dialysis_time::decimal / 60)+(4 - 3.5 * bun_rate) * total_remove_water::decimal / aft_weight::decimal) / dialysis_time::decimal;
    body_water := aft_weight::decimal * 400;
    WHILE i < 10000 LOOP
      dbw := total_remove_water::decimal / body_water;
      p1 := 0.8306 * 10^10 * dbw^2 - 0.1118 * 10^7 * dbw - 0.0834 * 10^4;
      p2 := -2.2858 * 10^8 * dbw^2 + 1.0900 * 10^5 * dbw + 0.2607 * 10^2;
      p3 := 0.9600 * 10^6 * dbw^2 - 1.2556 * 10^3 * dbw - 0.1732;
      p4 := 0.1248 * 10^4 * dbw^2 - 0.0728 * 10 * dbw - 0.0076 * 10^(-2);
      k2 := (k1 + p1 * k1^3 + p2 * k1^2 + p3 * k1 + p4) * body_water;
      k2 := (1 - rr) * k2 / (1 - rr - rr * k2 / blood_per_min);
      k0 := (1 - exp(calc_koa * (1 / blood_per_min::decimal - 1 / dialysis_fluid::decimal))) / ( 1 / dialysis_fluid::decimal - 1 / blood_per_min::decimal * exp(calc_koa * (1 / blood_per_min::decimal - 1 / dialysis_fluid::decimal)));
      IF k2 - k0 >= 0 THEN
        RETURN body_water;
      END IF;
      body_water := body_water + 20;
      i := i + 1;
    END LOOP;
    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN RETURN 0;
  END;
$$ LANGUAGE plpgsql;