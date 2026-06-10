using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NKKWeightScaleDB.Models
{
    public class Treatment_condition : BaseEntity
    {
        public string patient_id { get; set; }
        public string method_of_treatment { get; set; }
        public string cool { get; set; }
        public string dialysis_start_time { get; set; }
        public string treatment_time { get; set; }
        public string va { get; set; }
        public string dialyzer { get; set; }
        public string adsorption_column { get; set; }
        public string primary_membrane { get; set; }
        public string secondary_membrane { get; set; }
        public string puncture_needle_a { get; set; }
        public string puncture_needle_v { get; set; }
        public string puncture_needle_sn { get; set; }
        public string use_single_needle { get; set; }
        public string blood_circuit { get; set; }
        public string volume_of_blood_flow { get; set; }
        public string dialysate { get; set; }
        public string dialysate_flow_rate { get; set; }
        public string fluid_replacement { get; set; }
        public string dialysate_volume { get; set; }
        public string dialysate_temperature { get; set; }
        public string replacement_fluidAmount { get; set; }
        public string replacement_fluid_selection { get; set; }
        public string number_of_replacement_fluids { get; set; }
        public string fluid_replacement_temperature { get; set; }
        public string fluid_replacement_speed { get; set; }
        public string anticoagulant_drug { get; set; }
        public string anticoagulant_one_shot_amount_drug { get; set; }
        public string anticoagulant_sustained_rate { get; set; }
        public string total_amount_of_anticoagulant_sustained { get; set; }
        public string select_ip { get; set; }
        public string ip_start { get; set; }
        public string ip_one_shot_amount { get; set; }
        public string ip_speed { get; set; }
        public string ip_speed_maximum_value { get; set; }
        public string automatic_one_shot { get; set; }
        public string ip_power_off_automatically { get; set; }
        public string ip_power_off_automatically_time { get; set; }
        public string turn_off_the_ip_power_supply_ok_monitor { get; set; }
        public string ip_power_ok_monitor_turn_off_time { get; set; }
    }
}
