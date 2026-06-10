using NKKWeightScaleDB.Interfaces;
using NKKWeightScaleDB.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NKKWeightScaleDB.Services
{
    public class TreatmentConditionService : BaseService<Treatment_condition>, ITreatmentConditionService
    {
        public Treatment_condition AddOrUpdate(Treatment_condition treatment_condition)
        {
            Treatment_condition result = treatment_condition;
            var currentData = this.GetAll();
            var index = currentData.FindIndex(item => item.patient_id == treatment_condition.patient_id);
            if (index != -1)
            {
                currentData[index].patient_id = treatment_condition.patient_id;
                currentData[index].method_of_treatment = treatment_condition.method_of_treatment;
                currentData[index].cool = treatment_condition.cool;
                currentData[index].dialysis_start_time = treatment_condition.dialysis_start_time;
                currentData[index].treatment_time = treatment_condition.treatment_time;
                currentData[index].va = treatment_condition.va;
                currentData[index].dialyzer = treatment_condition.dialyzer;
                currentData[index].adsorption_column = treatment_condition.adsorption_column;
                currentData[index].primary_membrane = treatment_condition.primary_membrane;
                currentData[index].secondary_membrane = treatment_condition.secondary_membrane;
                currentData[index].puncture_needle_a = treatment_condition.puncture_needle_a;
                currentData[index].puncture_needle_v = treatment_condition.puncture_needle_v;
                currentData[index].puncture_needle_sn = treatment_condition.puncture_needle_sn;
                currentData[index].use_single_needle = treatment_condition.use_single_needle;
                currentData[index].blood_circuit = treatment_condition.blood_circuit;
                currentData[index].volume_of_blood_flow = treatment_condition.volume_of_blood_flow;
                currentData[index].dialysate = treatment_condition.dialysate;
                currentData[index].dialysate_flow_rate = treatment_condition.dialysate_flow_rate;
                currentData[index].fluid_replacement = treatment_condition.fluid_replacement;
                currentData[index].dialysate_volume = treatment_condition.dialysate_volume;
                currentData[index].dialysate_temperature = treatment_condition.dialysate_temperature;
                currentData[index].replacement_fluidAmount = treatment_condition.replacement_fluidAmount;
                currentData[index].replacement_fluid_selection = treatment_condition.replacement_fluid_selection;
                currentData[index].number_of_replacement_fluids = treatment_condition.number_of_replacement_fluids;
                currentData[index].fluid_replacement_temperature = treatment_condition.fluid_replacement_temperature;
                currentData[index].fluid_replacement_speed = treatment_condition.fluid_replacement_speed;
                currentData[index].anticoagulant_drug = treatment_condition.anticoagulant_drug;
                currentData[index].anticoagulant_one_shot_amount_drug = treatment_condition.anticoagulant_one_shot_amount_drug;
                currentData[index].anticoagulant_sustained_rate = treatment_condition.anticoagulant_sustained_rate;
                currentData[index].total_amount_of_anticoagulant_sustained = treatment_condition.total_amount_of_anticoagulant_sustained;
                currentData[index].select_ip = treatment_condition.select_ip;
                currentData[index].ip_start = treatment_condition.ip_start;
                currentData[index].ip_one_shot_amount = treatment_condition.ip_one_shot_amount;
                currentData[index].ip_speed = treatment_condition.ip_speed;
                currentData[index].ip_speed_maximum_value = treatment_condition.ip_speed_maximum_value;
                currentData[index].automatic_one_shot = treatment_condition.automatic_one_shot;
                currentData[index].ip_power_off_automatically = treatment_condition.ip_power_off_automatically;
                currentData[index].ip_power_off_automatically_time = treatment_condition.ip_power_off_automatically_time;
                currentData[index].turn_off_the_ip_power_supply_ok_monitor = treatment_condition.turn_off_the_ip_power_supply_ok_monitor;
                currentData[index].ip_power_ok_monitor_turn_off_time = treatment_condition.ip_power_ok_monitor_turn_off_time;
                result = this.Update(currentData[index]);
            }
            else
            {
                result = this.Create(treatment_condition);
            }
            return result;
        }
    }
}
