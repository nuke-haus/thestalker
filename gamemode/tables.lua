
// ENUMS

// stalker selection

SELECTION_MODE_KILLER = 1
SELECTION_MODE_DAMAGE = 2
SELECTION_MODE_RANDOM = 3

// loadouts

PRIMARY_P90 = 1
PRIMARY_SPAS = 2
PRIMARY_SG552 = 3
PRIMARY_FAMAS = 4

SECONDARY_PISTOL = 1
SECONDARY_SEEKER = 2
SECONDARY_SCANNER = 3
SECONDARY_TRIPMINE = 4

UTIL_AMMO = 1
UTIL_LASER = 2
UTIL_LIGHT = 3
UTIL_HEALTH = 4

// voice types

VO_DEATH = 1
VO_PAIN = 2
VO_TAUNT = 3
VO_ALERT = 4
VO_IDLE = 5
VO_YES = 6
VO_SPAWN = 7

// TABLES

// names

GM.ItemNames = {}
GM.ItemNames[1] = { "FN P90", "SPAS-12", "SG 552", "FAMAS G2" }
GM.ItemNames[2] = { "USP Compact", "Seeker Drone", "Optic Range Scanner", "Portable Sensor" }
GM.ItemNames[3] = { "Ammunition Pack", "Laser Module", "Dual Cell Battery", "Automedic System" }

GM.ItemDescriptions = {}
GM.ItemDescriptions[1] = {}
GM.ItemDescriptions[1][PRIMARY_P90] = "A compact SMG with a high magazine capacity and rate of fire."
GM.ItemDescriptions[1][PRIMARY_SPAS] = "A reliable and powerful semi-automatic shotgun."
GM.ItemDescriptions[1][PRIMARY_SG552] = "An accurate scoped assault rifle with formidable stopping power."
GM.ItemDescriptions[1][PRIMARY_FAMAS] = "A well-rounded assault rifle that fires in bursts."

GM.ItemDescriptions[2] = {}
GM.ItemDescriptions[2][SECONDARY_PISTOL] = "A powerful sidearm with unlimited reserve ammunition."
GM.ItemDescriptions[2][SECONDARY_SEEKER] = "An autonomous drone equipped with an omni-directional lifeform detector."
GM.ItemDescriptions[2][SECONDARY_SCANNER] = "A handheld scanner which augments your vision and reveals lifeforms."
GM.ItemDescriptions[2][SECONDARY_TRIPMINE] = "A deployable laser sensor that sounds off when its beam is distorted."

GM.ItemDescriptions[3] = {}
GM.ItemDescriptions[3][UTIL_AMMO] = "An additional reserve magazine for your primary weapon."
GM.ItemDescriptions[3][UTIL_LASER] = "An attachable lasersight for your primary weapon."
GM.ItemDescriptions[3][UTIL_LIGHT] = "An efficient battery which amplifies your flashlight and recharges more rapidly."
GM.ItemDescriptions[3][UTIL_HEALTH] = "An integrated automatic morphine injector for your armor."

// gameplay

GM.MagAmounts = {}
GM.MagAmounts[ PRIMARY_P90 ] = 50
GM.MagAmounts[ PRIMARY_SPAS ] = 6
GM.MagAmounts[ PRIMARY_SG552 ] = 20
GM.MagAmounts[ PRIMARY_FAMAS ] = 30

GM.WeaponTypes = {}
GM.WeaponTypes[ PRIMARY_P90 ] = "weapon_ts_p90"
GM.WeaponTypes[ PRIMARY_SPAS ] = "weapon_ts_shotgun"
GM.WeaponTypes[ PRIMARY_SG552 ] = "weapon_ts_sg552"
GM.WeaponTypes[ PRIMARY_FAMAS ] = "weapon_ts_famas"

GM.WeaponModels = {}
GM.WeaponModels[ PRIMARY_P90 ] = "models/weapons/w_smg_p90.mdl"
GM.WeaponModels[ PRIMARY_SPAS ] = "models/weapons/w_shotgun.mdl"
GM.WeaponModels[ PRIMARY_SG552 ] = "models/weapons/w_rif_sg552.mdl"
GM.WeaponModels[ PRIMARY_FAMAS ] = "models/weapons/w_rif_famas.mdl"

GM.SecondaryTypes = {}
GM.SecondaryTypes[ SECONDARY_PISTOL ] = "weapon_ts_usp"
GM.SecondaryTypes[ SECONDARY_SEEKER ] = "weapon_ts_seeker"
GM.SecondaryTypes[ SECONDARY_SCANNER ] = "weapon_ts_scanner"
GM.SecondaryTypes[ SECONDARY_TRIPMINE ] = "weapon_ts_tripmine"

// SOUND TABLES

GM.Voices = {}

GM.Voices[ VO_DEATH ] = { "npc/metropolice/die1.wav",
"npc/metropolice/die2.wav",
"npc/metropolice/die3.wav",
"npc/metropolice/die4.wav" }

GM.Voices[ VO_PAIN ] = { "npc/combine_soldier/die1.wav",
"npc/combine_soldier/die2.wav",
"npc/combine_soldier/die3.wav",
"npc/combine_soldier/pain1.wav",
"npc/combine_soldier/pain2.wav",
"npc/combine_soldier/pain3.wav",
"npc/metropolice/pain1.wav",
"npc/metropolice/pain2.wav",
"npc/metropolice/pain3.wav",
"npc/metropolice/knockout2.wav" }

GM.Voices[ VO_ALERT ] = { "npc/combine_soldier/vo/alert1.wav",
"npc/combine_soldier/vo/bodypackholding.wav",
"npc/combine_soldier/vo/bouncerbouncer.wav",
"npc/combine_soldier/vo/callcontactparasitics.wav",
"npc/combine_soldier/vo/callhotpoint.wav",
"npc/combine_soldier/vo/confirmsectornotsterile.wav",
"npc/combine_soldier/vo/contact.wav",
"npc/combine_soldier/vo/contactconfim.wav",
"npc/combine_soldier/vo/containmentproceeding.wav",
"npc/combine_soldier/vo/cover.wav",
"npc/combine_soldier/vo/coverhurt.wav",
"npc/combine_soldier/vo/coverme.wav",
"npc/combine_soldier/vo/displace.wav",
"npc/combine_soldier/vo/displace2.wav",
"npc/combine_soldier/vo/engagedincleanup.wav",
"npc/combine_soldier/vo/engaging.wav",
"npc/combine_soldier/vo/executingfullresponse.wav",
"npc/combine_soldier/vo/flaredown.wav",
"npc/combine_soldier/vo/flush.wav",
"npc/combine_soldier/vo/gosharpgosharp.wav",
"npc/combine_soldier/vo/heavyresistance.wav",
"npc/combine_soldier/vo/hunter.wav",
"npc/combine_soldier/vo/inbound.wav",
"npc/combine_soldier/vo/infected.wav",
"npc/combine_soldier/vo/motioncheckallradials.wav",
"npc/combine_soldier/vo/movein.wav",
"npc/combine_soldier/vo/necrotics.wav",
"npc/combine_soldier/vo/necroticsinbound.wav",
"npc/combine_soldier/vo/onedutyvacated.wav",
"npc/combine_soldier/vo/outbreak.wav",
"npc/combine_soldier/vo/requestmedical.wav",
"npc/combine_soldier/vo/requeststimdose.wav",
"npc/combine_soldier/vo/ripcordripcord.wav",
"npc/combine_soldier/vo/sharpzone.wav",
"npc/combine_soldier/vo/swarmoutbreakinsector.wav",
"npc/combine_soldier/vo/sweepingin.wav",
"npc/combine_soldier/vo/target.wav",
"npc/combine_soldier/vo/targetblackout.wav",
"npc/combine_soldier/vo/targetcompromisedmovein.wav",
"npc/combine_soldier/vo/targetineffective.wav",
"npc/combine_soldier/vo/targetmyradial.wav",
"npc/combine_soldier/vo/visualonexogens.wav",
"npc/metropolice/vo/acquiringonvisual.wav",
"npc/metropolice/vo/allunitscode2.wav",
"npc/metropolice/vo/allunitsrespondcode3.wav",
"npc/metropolice/vo/assaultpointsecureadvance.wav",
"npc/metropolice/vo/backmeupimout.wav",
"npc/metropolice/vo/bugsontheloose.wav",
"npc/metropolice/vo/confirmpriority1sighted.wav",
"npc/metropolice/vo/contactwithpriority2.wav",
"npc/metropolice/vo/converging.wav",
"npc/metropolice/vo/covermegoingin.wav",
"npc/metropolice/vo/cpisoverrunwehavenocontainment.wav",
"npc/metropolice/vo/destroythatcover.wav",
"npc/metropolice/vo/dontmove.wav",
"npc/metropolice/vo/firetodislocateinterpose.wav",
"npc/metropolice/vo/firingtoexposetarget.wav",
"npc/metropolice/vo/getdown.wav",
"npc/metropolice/vo/goingtotakealook.wav",
"npc/metropolice/vo/help.wav",
"npc/metropolice/vo/holdthisposition.wav",
"npc/metropolice/vo/ihave10-30my10-20responding.wav",
"npc/metropolice/vo/investigating10-103.wav",
"npc/metropolice/vo/lockyourposition.wav",
"npc/metropolice/vo/lookout.wav",
"npc/metropolice/vo/lookoutrogueviscerator.wav",
"npc/metropolice/vo/movebackrightnow.wav",
"npc/metropolice/vo/moveit.wav",
"npc/metropolice/vo/movingtocover.wav",
"npc/metropolice/vo/movingtohardpoint2.wav",
"npc/metropolice/vo/outlandbioticinhere.wav",
"npc/metropolice/vo/reinforcementteamscode3.wav",
"npc/metropolice/vo/shit.wav",
"npc/metropolice/vo/shotsfiredhostilemalignants.wav",
"npc/metropolice/vo/tag10-91d.wav",
"npc/metropolice/vo/tagonebug.wav",
"npc/metropolice/vo/tagoneparasitic.wav",
"npc/metropolice/vo/takecover.wav",
"npc/metropolice/vo/tenzerovisceratorishunting.wav",
"npc/metropolice/vo/visceratordeployed.wav",
"npc/metropolice/vo/visceratorisoc.wav",
"npc/metropolice/vo/watchit.wav",
"npc/metropolice/vo/wehavea10-108.wav" }

GM.Voices[ VO_IDLE ] = { "npc/combine_soldier/vo/antiseptic.wav",
"npc/combine_soldier/vo/apex.wav",
"npc/combine_soldier/vo/block31mace.wav",
"npc/combine_soldier/vo/block64jet.wav",
"npc/combine_soldier/vo/boomer.wav",
"npc/combine_soldier/vo/dagger.wav",
"npc/combine_soldier/vo/delivered.wav",
"npc/combine_soldier/vo/flatline.wav",
"npc/combine_soldier/vo/fullactive.wav",
"npc/combine_soldier/vo/ghost2.wav",
"npc/combine_soldier/vo/goactiveintercept.wav",
"npc/combine_soldier/vo/gosharp.wav",
"npc/combine_soldier/vo/hardenthatposition.wav",
"npc/combine_soldier/vo/hasnegativemovement.wav",
"npc/combine_soldier/vo/isatcode.wav",
"npc/combine_soldier/vo/isfieldpromoted.wav",
"npc/combine_soldier/vo/isholdingatcode.wav",
"npc/combine_soldier/vo/lostcontact.wav",
"npc/combine_soldier/vo/noviscon.wav",
"npc/combine_soldier/vo/outbreakstatusiscode.wav",
"npc/combine_soldier/vo/overwatch.wav",
"npc/combine_soldier/vo/reportallpositionsclear.wav",
"npc/combine_soldier/vo/reportallradialsfree.wav",
"npc/combine_soldier/vo/reportingclear.wav",
"npc/combine_soldier/vo/ripcord.wav",
"npc/combine_soldier/vo/sectionlockupdash4.wav",
"npc/combine_soldier/vo/sectorissecurenovison.wav",
"npc/combine_soldier/vo/sightlineisclear.wav",
"npc/combine_soldier/vo/stabilizationteamholding.wav",
"npc/combine_soldier/vo/standingby].wav",
"npc/combine_soldier/vo/stayalert.wav",
"npc/combine_soldier/vo/stayalertreportsightlines.wav",
"npc/combine_soldier/vo/sundown.wav",
"npc/combine_soldier/vo/tracker.wav",
"npc/combine_soldier/vo/uniform.wav",
"npc/combine_soldier/vo/viscon.wav",
"npc/metropolice/vo/404zone.wav",
"npc/metropolice/vo/anyonepickup647e.wav",
"npc/metropolice/vo/atcheckpoint.wav",
"npc/metropolice/vo/backup.wav",
"npc/metropolice/vo/block.wav",
"npc/metropolice/vo/blockisholdingcohesive.wav",
"npc/metropolice/vo/bugs.wav",
"npc/metropolice/vo/catchthatbliponstabilization.wav",
"npc/metropolice/vo/checkformiscount.wav",
"npc/metropolice/vo/clearno647no10-107.wav",
"npc/metropolice/vo/code100.wav",
"npc/metropolice/vo/code7.wav",
"npc/metropolice/vo/condemnedzone.wav",
"npc/metropolice/vo/control100percent.wav",
"npc/metropolice/vo/deservicedarea.wav",
"npc/metropolice/vo/dismountinghardpoint.wav",
"npc/metropolice/vo/distributionblock.wav",
"npc/metropolice/vo/document.wav",
"npc/metropolice/vo/examine.wav",
"npc/metropolice/vo/getoutofhere.wav",
"npc/metropolice/vo/hardpointscanning.wav",
"npc/metropolice/vo/highpriorityregion.wav",
"npc/metropolice/vo/holdit.wav",
"npc/metropolice/vo/holditrightthere.wav",
"npc/metropolice/vo/infestedzone.wav",
"npc/metropolice/vo/innoculate.wav",
"npc/metropolice/vo/inject.wav",
"npc/metropolice/vo/inpositionathardpoint.wav",
"npc/metropolice/vo/inpositiononeready.wav",
"npc/metropolice/vo/intercede.wav",
"npc/metropolice/vo/interlock.wav",
"npc/metropolice/vo/ivegot408hereatlocation.wav",
"npc/metropolice/vo/keepmoving.wav",
"npc/metropolice/vo/localcptreportstatus.wav",
"npc/metropolice/vo/lock.wav",
"npc/metropolice/vo/looseparasitics.wav",
"npc/metropolice/vo/malignant.wav",
"npc/metropolice/vo/moveit2.wav",
"npc/metropolice/vo/movingtohardpoint.wav",
"npc/metropolice/vo/necrotics.wav",
"npc/metropolice/vo/nocontact.wav",
"npc/metropolice/vo/nonpatrolregion.wav",
"npc/metropolice/vo/novisualonupi.wav",
"npc/metropolice/vo/patrol.wav",
"npc/metropolice/vo/pickingupnoncorplexindy.wav",
"npc/metropolice/vo/possible404here.wav",
"npc/metropolice/vo/restrictedblock.wav",
"npc/metropolice/vo/search.wav",
"npc/metropolice/vo/sociocide.wav",
"npc/metropolice/vo/sterilize.wav",
"npc/metropolice/vo/stillgetting647e.wav",
"npc/metropolice/vo/terminalrestrictionzone.wav",
"npc/metropolice/vo/unitis10-65.wav",
"npc/metropolice/vo/unitis10-8standingby.wav",
"npc/metropolice/vo/visceratorisoffgrid.wav" }

GM.Voices[ VO_TAUNT ] = { "npc/combine_soldier/vo/affirmativewegothimnow.wav",
"npc/combine_soldier/vo/callcontacttarget1.wav",
"npc/combine_soldier/vo/cleaned.wav",
"npc/combine_soldier/vo/closing.wav",
"npc/combine_soldier/vo/closing2.wav",
"npc/combine_soldier/vo/contained.wav",
"npc/combine_soldier/vo/extractoraway.wav",
"npc/combine_soldier/vo/gridsundown46.wav",
"npc/combine_soldier/vo/onecontained.wav",
"npc/combine_soldier/vo/onedown.wav",
"npc/combine_soldier/vo/overwatchconfirmhvtcontained.wav",
"npc/combine_soldier/vo/overwatchtarget1sterilized.wav",
"npc/combine_soldier/vo/overwatchtargetcontained.wav",
"npc/combine_soldier/vo/payback.wav",
"npc/combine_soldier/vo/readyextractors.wav",
"npc/combine_soldier/vo/secure.wav",
"npc/combine_soldier/vo/stabilizationteamhassector.wav",
"npc/combine_soldier/vo/suppressing.wav",
"npc/combine_soldier/vo/targetone.wav",
"npc/combine_soldier/vo/thatsitwrapitup.wav",
"npc/combine_soldier/vo/unitisclosing.wav",
"npc/metropolice/vo/administer.wav",
"npc/metropolice/vo/chuckle.wav",
"npc/metropolice/vo/clearandcode100.wav",
"npc/metropolice/vo/controlsection.wav",
"npc/metropolice/vo/get11-44inboundcleaningup.wav",
"npc/metropolice/vo/gota10-107sendairwatch.wav",
"npc/metropolice/vo/protectioncomplete.wav",
"npc/metropolice/vo/ptatlocationreport.wav",
"npc/metropolice/vo/ptgoagain.wav",
"npc/metropolice/vo/upi.wav",
"npc/metropolice/vo/suspend.wav" }

GM.Voices[ VO_SPAWN ] = { "npc/combine_soldier/vo/extractorislive.wav",
"npc/combine_soldier/vo/fixsightlinesmovein.wav",
"npc/combine_soldier/vo/isfinalteamunitbackup.wav",
"npc/combine_soldier/vo/overwatchreportspossiblehostiles.wav",
"npc/combine_soldier/vo/overwatchrequestreinforcement.wav",
"npc/combine_soldier/vo/overwatchrequestreserveactivation.wav",
"npc/combine_soldier/vo/overwatchrequestskyshield.wav",
"npc/combine_soldier/vo/overwatchrequestwinder.wav",
"npc/combine_soldier/vo/overwatchsectoroverrun.wav",
"npc/combine_soldier/vo/overwatchteamisdown.wav",
"npc/combine_soldier/vo/ovewatchorders3ccstimboost.wav",
"npc/combine_soldier/vo/prepforcontact.wav",
"npc/combine_soldier/vo/priority1objective.wav",
"npc/combine_soldier/vo/readycharges.wav",
"npc/combine_soldier/vo/readyweapons.wav",
"npc/combine_soldier/vo/readyweaponshostilesinbound.wav",
"npc/combine_soldier/vo/sectorisnotsecure.wav",
"npc/combine_soldier/vo/skyshieldreportslostcontact.wav",
"npc/combine_soldier/vo/teamdeployedandscanning.wav",
"npc/combine_soldier/vo/unitisinbound.wav",
"npc/combine_soldier/vo/unitismovingin.wav",
"npc/combine_soldier/vo/weaponsoffsafeprepforcontact.wav",
"npc/combine_soldier/vo/weareinaninfestationzone.wav",
"npc/combine_soldier/vo/wehavefreeparasites.wav",
"npc/combine_soldier/vo/wehavenontaggedviromes.wav",
"npc/metropolice/vo/allunitsmovein.wav",
"npc/metropolice/vo/cauterize.wav",
"npc/metropolice/vo/classifyasdbthisblockready.wav",
"npc/metropolice/vo/cpbolforthat243.wav",
"npc/metropolice/vo/non-taggedviromeshere.wav",
"npc/metropolice/vo/possible10-103alerttagunits.wav",
"npc/metropolice/vo/possible647erequestairwatch.wav",
"npc/metropolice/vo/preparefor1015.wav",
"npc/metropolice/vo/proceedtocheckpoints.wav",
"npc/metropolice/vo/readytoamputate.wav",
"npc/metropolice/vo/requestsecondaryviscerator.wav",
"npc/metropolice/vo/teaminpositionadvance.wav" }

GM.Voices[ VO_YES ] = { "npc/combine_soldier/vo/affirmative.wav",
"npc/combine_soldier/vo/affirmative2.wav",
"npc/combine_soldier/vo/copy.wav",
"npc/combine_soldier/vo/copythat.wav",
"npc/combine_soldier/vo/echo.wav",
"npc/combine_soldier/vo/eleven.wav",
"npc/combine_soldier/vo/five.wav",
"npc/combine_soldier/vo/ice.wav",
"npc/combine_soldier/vo/jet.wav",
"npc/combine_soldier/vo/niner.wav",
"npc/metropolice/vo/affirmative.wav",
"npc/metropolice/vo/affirmative2.wav",
"npc/metropolice/vo/apply.wav",
"npc/metropolice/vo/copy.wav",
"npc/metropolice/vo/five.wav",
"npc/metropolice/vo/responding2.wav",
"npc/metropolice/vo/rodgerthat.wav",
"npc/metropolice/vo/ten2.wav",
"npc/metropolice/vo/ten4.wav",
"npc/metropolice/vo/ten8standingby.wav",
"npc/metropolice/vo/ten97.wav" }

GM.VoiceStart = { "npc/metropolice/vo/off1.wav",
"npc/metropolice/vo/off4.wav" }

GM.VoiceEnd = { "npc/combine_soldier/vo/off1.wav",
"npc/combine_soldier/vo/off2.wav" }

GM.StalkerDie = { "npc/ichthyosaur/attack_growl1.wav",
"npc/ichthyosaur/attack_growl2.wav",
"npc/ichthyosaur/attack_growl3.wav" }

GM.PsySounds = { "ambient/levels/citadel/strange_talk1.wav",
"ambient/levels/citadel/strange_talk3.wav",
"ambient/levels/citadel/strange_talk4.wav",
"ambient/levels/citadel/strange_talk5.wav",
"ambient/levels/citadel/strange_talk6.wav",
"ambient/levels/citadel/strange_talk7.wav",
"ambient/levels/citadel/strange_talk8.wav",
"ambient/levels/citadel/strange_talk9.wav",
"ambient/levels/citadel/strange_talk10.wav",
"ambient/levels/citadel/strange_talk11.wav",
"ambient/levels/labs/teleport_weird_voices1.wav",
"ambient/levels/labs/teleport_weird_voices2.wav",
"ambient/atmosphere/city_skybeam1.wav",
"ambient/atmosphere/city_truckpass1.wav",
"ambient/atmosphere/cave_hit5.wav",
"ambient/atmosphere/cave_hit6.wav" }

GM.AutoMedic = { "hl1/fvox/automedic_on.wav",
"hl1/fvox/morphine_shot.wav",
"hl1/fvox/blood_loss.wav" }

GM.WeaponHit = { "physics/metal/weapon_footstep1.wav",
"physics/metal/weapon_footstep2.wav",
"physics/metal/weapon_impact_soft1.wav",
"physics/metal/weapon_impact_soft2.wav",
"physics/metal/weapon_impact_soft3.wav",
"physics/metal/weapon_impact_hard1.wav",
"physics/metal/weapon_impact_hard2.wav",
"physics/metal/weapon_impact_hard3.wav",
"physics/metal/metal_computer_impact_bullet3.wav" }

GM.GoreSplat = { "physics/flesh/flesh_squishy_impact_hard1.wav",
"physics/flesh/flesh_squishy_impact_hard2.wav",
"physics/flesh/flesh_squishy_impact_hard3.wav",
"physics/flesh/flesh_squishy_impact_hard4.wav",
"physics/flesh/flesh_bloody_impact_hard1.wav",
"physics/body/body_medium_break3.wav",
"npc/antlion_grub/squashed.wav",
"ambient/levels/canals/toxic_slime_sizzle1.wav",
"ambient/levels/canals/toxic_slime_gurgle8.wav"}

GM.Gore = { "nuke/gore/blood01.wav", 
"nuke/gore/blood02.wav", 
"nuke/gore/blood03.wav" }

GM.Concrete = { "player/footsteps/concrete1.wav",
"player/footsteps/concrete2.wav",
"player/footsteps/concrete3.wav",
"player/footsteps/concrete4.wav",
"player/footsteps/tile1.wav",
"player/footsteps/tile2.wav",
"player/footsteps/tile3.wav",
"player/footsteps/tile4.wav" }

GM.HumanFeet = { "npc/combine_soldier/gear1.wav",
"npc/combine_soldier/gear2.wav",
"npc/combine_soldier/gear3.wav",
"npc/combine_soldier/gear4.wav",
"npc/combine_soldier/gear5.wav",
"npc/combine_soldier/gear6.wav",
"npc/metropolice/gear1.wav",
"npc/metropolice/gear2.wav",
"npc/metropolice/gear3.wav",
"npc/metropolice/gear4.wav",
"npc/metropolice/gear5.wav",
"npc/metropolice/gear6.wav" }

GM.StalkerFeet = { "physics/plaster/ceiling_tile_impact_soft1.wav",
"physics/plaster/ceiling_tile_impact_soft2.wav",
"physics/plaster/ceiling_tile_impact_soft3.wav" } 

GM.RadioBuzz = { "ambient/levels/prison/radio_random1.wav",
"ambient/levels/prison/radio_random2.wav",
"ambient/levels/prison/radio_random3.wav",
"ambient/levels/prison/radio_random4.wav",
"ambient/levels/prison/radio_random5.wav",
"ambient/levels/prison/radio_random6.wav",
"ambient/levels/prison/radio_random7.wav",
"ambient/levels/prison/radio_random8.wav",
"ambient/levels/prison/radio_random9.wav",
"ambient/levels/prison/radio_random10.wav",
"ambient/levels/prison/radio_random11.wav",
"ambient/levels/prison/radio_random12.wav",
"ambient/levels/prison/radio_random13.wav",
"ambient/levels/prison/radio_random14.wav",
"ambient/levels/prison/radio_random15.wav" }

// models

GM.GibCorpses = { Model( "models/gibs/fast_zombie_torso.mdl" ),
Model( "models/humans/charple02.mdl" ),
Model( "models/humans/charple03.mdl" ),
Model( "models/humans/charple04.mdl" ) }

GM.ScannerGibs = { Model( "models/gibs/manhack_gib01.mdl" ), 
Model( "models/gibs/manhack_gib02.mdl" ), 
Model( "models/gibs/manhack_gib03.mdl" ),
Model( "models/gibs/manhack_gib04.mdl" ),
Model( "models/gibs/scanner_gib04.mdl" ) }

GM.SmallGibs = { Model( "models/gibs/HGIBS_scapula.mdl" ),
Model( "models/gibs/HGIBS_spine.mdl" ),
Model( "models/props_phx/misc/potato.mdl" ),
Model( "models/gibs/antlion_gib_small_1.mdl" ),
Model( "models/gibs/antlion_gib_small_2.mdl" ),
Model( "models/gibs/shield_scanner_gib1.mdl" ),
Model( "models/props_debris/concrete_chunk04a.mdl" ),
Model( "models/props_debris/concrete_chunk05g.mdl" ),
Model( "models/props_wasteland/prison_sinkchunk001h.mdl" ),
Model( "models/props_wasteland/prison_toiletchunk01f.mdl" ),
Model( "models/props_wasteland/prison_toiletchunk01i.mdl" ),
Model( "models/props_wasteland/prison_toiletchunk01l.mdl" ),
Model( "models/props_combine/breenbust_chunk02.mdl" ),
Model( "models/props_combine/breenbust_chunk04.mdl" ),
Model( "models/props_combine/breenbust_chunk05.mdl" ),
Model( "models/props_combine/breenbust_chunk06.mdl" ),
Model( "models/props_junk/watermelon01_chunk02a.mdl" ),
Model( "models/props_junk/watermelon01_chunk02b.mdl" ),
Model( "models/props_junk/watermelon01_chunk02c.mdl" ),
Model( "models/props/cs_office/computer_mouse.mdl" ),
Model( "models/props/cs_italy/banannagib1.mdl" ),
Model( "models/props/cs_italy/banannagib2.mdl" ),
Model( "models/props/cs_italy/orangegib1.mdl" ),
Model( "models/props/cs_italy/orangegib2.mdl" ) }
	
GM.BigGibs = { Model( "models/gibs/HGIBS.mdl" ),
Model( "models/weapons/w_bugbait.mdl" ),
Model( "models/gibs/antlion_gib_medium_1.mdl" ),
Model( "models/gibs/antlion_gib_medium_2.mdl" ),
Model( "models/gibs/shield_scanner_gib5.mdl" ),
Model( "models/gibs/shield_scanner_gib6.mdl" ),
Model( "models/props_junk/shoe001a.mdl" ),
Model( "models/props_junk/rock001a.mdl" ),
Model( "models/props_combine/breenbust_chunk03.mdl" ),
Model( "models/props_debris/concrete_chunk03a.mdl" ),
Model( "models/props_debris/concrete_spawnchunk001g.mdl" ),
Model( "models/props_debris/concrete_spawnchunk001k.mdl" ),
Model( "models/props_wasteland/prison_sinkchunk001c.mdl" ),
Model( "models/props_wasteland/prison_toiletchunk01j.mdl" ),
Model( "models/props_wasteland/prison_toiletchunk01k.mdl" ),
Model( "models/props_junk/watermelon01_chunk01b.mdl" ),
Model( "models/props/cs_italy/bananna.mdl" ) }


