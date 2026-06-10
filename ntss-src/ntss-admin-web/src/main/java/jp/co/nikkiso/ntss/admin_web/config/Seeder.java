package jp.co.nikkiso.ntss.admin_web.config;

import java.util.Arrays;

import org.springframework.boot.CommandLineRunner;

import jp.co.nikkiso.ntss.core.entity.MstFacility;

//@Configuration
public class Seeder {

  //@Autowired
  //MstFacilityService mstFacilityService;

  // Insert data at initailizing phase using ReservationDao#insert
  //@Bean
  CommandLineRunner runner() {
    return args -> Arrays.asList("spring", "spring boot", "spring cloud", "doma").forEach(s -> {
      MstFacility mstFacility = new MstFacility();
      mstFacility.setFacilityName(s);
      mstFacility.setFacilityCd("");
      //mstFacilityService.create(mstFacility);
    });
  }

}
