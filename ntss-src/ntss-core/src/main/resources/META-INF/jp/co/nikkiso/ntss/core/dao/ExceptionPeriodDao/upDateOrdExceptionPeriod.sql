update
		ord_exception_period
set
		exception_period_from = /* exceptionPeriodFrom*/'1000-01-01',
		exception_period_to = /* exceptionPeriodTo*/'1000-01-01',
		up_date = now(),
		upd_staff_id = /* updStaffId*/0
where
		exception_period_no = /* exceptionPeriodNo*/0
