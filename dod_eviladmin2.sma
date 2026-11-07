new eviltargetburn;
new dodevil_melee[33];
new dodevil_glow[33];
new dodevil_lowhealth[33];
new dodevil_health90[33];
new dodevil_stfu[33];
new dodevil_mirrordmg[33];
new dodevil_slowdown[33];
new dodevil_bury[33];
new dodevil_vision[33];
new dodevil_noprone[33];
new dodevil_cowbell[33];
new dodevil_shield[33];
new dodevil_noflag[33];
new Float:last_origin[33][3];
new Float:last_cowbell_time[33];


#include <amxmodx.inc>
#include <amxmisc.inc>
#include <dodfun.inc>
#include <dodx.inc>
#include <engine.inc>
#include <fun.inc>


///////////////////////////////////////////////////////////////////////////////////////
// Sounds used
//
#define SOUNDFILES 7


new soundName[SOUNDFILES][] =
{
	"smb_powerup.wav",		// Mario Powerup Sound
	"misc/shut-up-for-a-sec.wav",   // Shut Up for a Second
	"misc/rules.wav", // you must be mistaken rules do not apply to you
	"misc/choke.wav", // Choke sound
	"misc/nvg_on.wav", // NVG on sound
	"ambience/thunder_clap.wav", // Thunder Clap sound
	"mapsounds/cowbell.wav" // Cowbell sound
}

enum
{
	mariopowerup = 0,
	shutupforasec,
	rules,
	choke,
	nvg_on,
	thunder_clap,
	cowbell
}

new ishatsloaded = -1; // HATS plugin loaded flag

public plugin_init()
{
	register_plugin("DoD EvilAdmin", "1.0", "g-man");
	register_concmd("amx_evilslay", "eviladmin_slay", ADMIN_LEVEL_B, "<player> = Slay target with explosion");
	register_concmd("amx_evilslowdown", "eviladmin_slowdown", ADMIN_LEVEL_B, "<player> = Depleat targets stamina");
	register_concmd("amx_evilunslowdown", "eviladmin_unslowdown", ADMIN_LEVEL_B, "<player> = Depleat targets stamina");
	register_concmd("amx_evilmelee", "eviladmin_melee", ADMIN_LEVEL_B, "<player> = Only allow melee weapons for target");
	register_concmd("amx_evilunmelee", "eviladmin_unmelee", ADMIN_LEVEL_B, "<player> = Only allow melee weapons for target");
	register_concmd("amx_evilmirrordmg", "eviladmin_mirrordmg", ADMIN_LEVEL_B, "<player> = Enable MirrorDamage for Target");
	register_concmd("amx_evilunmirrordmg", "eviladmin_unmirrordmg", ADMIN_LEVEL_B, "<player> = Enable MirrorDamage for Target");
	register_concmd("amx_evillowhealth", "eviladmin_lowhealth", ADMIN_LEVEL_B, "<player> = Target has only 1hp");
	register_concmd("amx_evilunlowhealth", "eviladmin_unlowhealth", ADMIN_LEVEL_B, "<player> = Target has only 1hp");
	register_concmd("amx_evilhealth90", "eviladmin_health90", ADMIN_LEVEL_B, "<player> = Target has only 90hp");
	register_concmd("amx_evilunhealth90", "eviladmin_unhealth90", ADMIN_LEVEL_B, "<player> = Target has only 90hp");
	register_concmd("amx_evilglow", "eviladmin_glow", ADMIN_LEVEL_B, "<player> = Target glows in his team color");
	register_concmd("amx_evilunglow", "eviladmin_unglow", ADMIN_LEVEL_B, "<player> = Target glows in his team color");
	register_concmd("amx_evilstfu", "eviladmin_stfu", ADMIN_LEVEL_B, "<player> = Disables VoiceComm/Chat for the target");
	register_concmd("amx_evilunstfu", "eviladmin_unstfu", ADMIN_LEVEL_B, "<player> = Disables VoiceComm/Chat for the target");
	register_concmd("amx_evilpimpslap", "eviladmin_pimpslap", ADMIN_LEVEL_B, "<player> = Pimpslap target to death");
	register_concmd("amx_evilbury", "eviladmin_bury", ADMIN_LEVEL_B, "<player> = Bury target into the ground");
	register_concmd("amx_evilunbury", "eviladmin_unbury", ADMIN_LEVEL_B, "<player> = Bury target into the ground");
	register_concmd("amx_evilkick", "eviladmin_kick", ADMIN_LEVEL_B, "<player> = Boot player off DoD");
	register_concmd("amx_evilvision", "eviladmin_vision", ADMIN_LEVEL_B, "<player> = Change targets view");
	register_concmd("amx_evilunvision", "eviladmin_unvision", ADMIN_LEVEL_B, "<player> = Change targets view");
	register_concmd("amx_evilnoprone", "eviladmin_noprone", ADMIN_LEVEL_B, "<player> = Disallow proning for target");
	register_concmd("amx_evilunnoprone", "eviladmin_unnoprone", ADMIN_LEVEL_B, "<player> = Disallow proning for target");
	register_concmd("amx_evilcowbell", "eviladmin_cowbell", ADMIN_LEVEL_B, "<player> = Play cowbell sound when target moves");
	register_concmd("amx_eviluncowbell", "eviladmin_uncowbell", ADMIN_LEVEL_B, "<player> = Stop cowbell sound when target moves");
	register_concmd("amx_evilshield", "eviladmin_shield", ADMIN_LEVEL_B, "<player> = Give target 500 health on spawn");
	register_concmd("amx_evilunshield", "eviladmin_unshield", ADMIN_LEVEL_B, "<player> = Remove shield effect from target");
    register_concmd("amx_evilnoflag", "eviladmin_noflag", ADMIN_LEVEL_B, "<player> = Block target from capturing flags");
    register_concmd("amx_evilunnoflag", "eviladmin_unnoflag", ADMIN_LEVEL_B, "<player> = Allow target to capture flags again");
	register_concmd("amx_rules", "eviladmin_rules", ADMIN_LEVEL_B, "<player> = Play the rules sound for target");

	register_cvar("sv_evil_spshellthick", "25") // Cvar for controlling the glow shell thickness	
	register_event("CurWeapon", "check_evilmelee", "be", "1=1");

	register_event("SetFOV", "check_evilvision", "be", "1!160");
	register_event("ResetHUD", "evil_respawn", "be");

    // Register flag capture prevention
    register_event("ControlPoint", "check_flag_capture", "be");
    register_event("RoundState", "check_flag_capture", "a");

	register_clcmd("say", "check_evilstfu");
	register_clcmd("say_team", "check_evilstfu");

	// Verify HATS Plugin is loaded or not. 
	ishatsloaded = is_plugin_loaded("HATS")


	return PLUGIN_CONTINUE;
}

public plugin_precache()
{
	// Precache sounds
	precache_sound(soundName[mariopowerup]);
	precache_sound(soundName[shutupforasec]);
	precache_sound(soundName[rules]);
	precache_sound(soundName[choke]);
	precache_sound(soundName[nvg_on]);
	precache_sound(soundName[thunder_clap]);
	precache_sound(soundName[cowbell]);

	// Precache models
	eviltargetburn = precache_model("sprites/explode1.spr");

	return PLUGIN_CONTINUE;
}



public client_command(id)
{
//	if (is_user_connected(id) && is_user_alive(id) && dodevil_noprone[id] == 0)
	if (!is_user_connected(id) || !is_user_alive(id) || dodevil_noprone[id] == 0)
	{
		return PLUGIN_CONTINUE;
	}
	new pronecmd[16];

	read_argv(0, pronecmd, 15);

	if (equali(pronecmd, "sprone"))
	{
		client_print(id, print_chat, "[DoD EvilAdmin] You are not allowed to go prone!");
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}

public check_evilmelee(id)
{
	if (dodevil_melee[id] == 1)
	{
		new ammo;
		new clip;
		new currweap = dod_get_user_weapon(id, clip, ammo);

		if (currweap != DODW_AMERKNIFE  && currweap != DODW_BRITKNIFE && currweap != DODW_SPADE && currweap != DODW_GERKNIFE)
		{
			new eviltarget = id;
			set_task(0.1, "evil_melee", eviltarget);
			return PLUGIN_CONTINUE;
		}
		return PLUGIN_CONTINUE;
	}
	return PLUGIN_CONTINUE;
}

public client_authorized(id)
{
	dodevil_melee[id] = 0;
	dodevil_glow[id] = 0;
	dodevil_lowhealth[id] = 0;
	dodevil_health90[id] = 0;
	dodevil_slowdown[id] = 0;
	dodevil_stfu[id] = 0;
	dodevil_mirrordmg[id] = 0;
	dodevil_bury[id] = 0;
	dodevil_vision[id] = 0;
	dodevil_noprone[id] = 0;
	dodevil_cowbell[id] = 0;
	dodevil_shield[id] = 0;
	dodevil_noflag[id] = 0;
	last_origin[id][0] = 0.0;
	last_origin[id][1] = 0.0;
	last_origin[id][2] = 0.0;
	last_cowbell_time[id] = 0.0;

	return PLUGIN_CONTINUE;
}

public client_damage(attacker, victim, damage, wpnindex, hitplace, TA)
{
	if (dodevil_mirrordmg[attacker] == 1)
	{
		new param[3];
		param[0] = victim;
		param[1] = attacker;
		param[2] = damage;
		set_task(0.1, "evil_mirrordmg", 0, param, 3);
		return PLUGIN_CONTINUE;
	}
	return PLUGIN_CONTINUE;
}

public evil_mirrordmg(param[])
{
	if (is_user_alive(param[0]) == 1)
	{
		set_user_health(param[0], param[2] + get_user_health(param[0]));
	}
	if (is_user_alive(param[1]) == 1)
	{
		new oldhealth = get_user_health(param[1]);
		if (param[2] + 5 < oldhealth)
		{
			set_user_health(param[1], get_user_health(param[1]) - param[2] + 5);
		}
		else
		{
			if (param[2] + 5 >= oldhealth)
			{
				user_kill(param[1], 0);
			}
		}
	}
	return PLUGIN_HANDLED;
}

public evil_slowdown(eviltarget)
{
	if (is_user_alive(eviltarget) == 1)
	{
		dod_set_stamina(eviltarget,STAMINA_SET,0,0)
		return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}

public evil_health90(eviltarget)
{
	if (is_user_alive(eviltarget) == 1)
	{
		set_user_health(eviltarget,90);
		return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}

public evil_lowhealth(eviltarget)
{
	if (is_user_alive(eviltarget) == 1)
	{
		set_user_health(eviltarget,1);
		return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}
/**
 * Sets a glow effect on the target player.
 * 
 * You can customize the glow effect by changing these parameters:
 *
 * Render Effects
 * 	kRenderFxNone — No special effect
 * 	kRenderFxGlowShell — Glow shell (used here)
 * 	kRenderFxPulseFast — Fast pulsing
 * 	kRenderFxPulseSlow — Slow pulsing
 * 
 * Render Modes
 *  kRenderFxDistort — Distorted effect
 *  kRenderNormal — Standard rendering
 *  kRenderTransColor — Transparent color
 *  kRenderTransTexture — Transparent texture
 *  kRenderTransAlpha — Transparent alpha
 *  kRenderGlow — Glow effect
 * 
 * Colors
 *  Change the RGB values for different colors:
 *   Red: 255, 0, 0
 *   Green: 0, 255, 0
 *   Blue: 0, 0, 255
 *   Yellow: 255, 255, 0
 *   White: 255, 255, 255
 */

public evil_glow(eviltarget)
{
	new SPShell = get_cvar_num("sv_evil_spshellthick")
	new username[MAX_NAME_LENGTH];
	get_user_name(eviltarget, username, sizeof(username));

	if (is_user_alive(eviltarget) == 1)
	{
		if (get_user_team(eviltarget) == 2)   //  250, 250, 0 Yellow   250, 0 , 250 Pink
		{
			log_amx("[DoD EvilAdmin] User: %s Shell %d is glowing in team axis!", username, SPShell);

			set_user_rendering(eviltarget, kRenderFxGlowShell, 250, 0, 250, kRenderNormal , SPShell);
			// set_user_rendering(eviltarget, kRenderFxGlowShell, 255, 0, 0, kRenderNormal , SPShell);
			return PLUGIN_HANDLED;
		}
		if (get_user_team(eviltarget) == 1)
		{
			log_amx("[DoD EvilAdmin] User: %s Shell %d is glowing in team Allies!", username, SPShell);
			set_user_rendering(eviltarget, kRenderFxGlowShell, 250, 250, 0, kRenderNormal , SPShell);
			// set_user_rendering(eviltarget, kRenderFxGlowShell, 0, 255, 0, kRenderNormal , SPShell);
			return PLUGIN_HANDLED;
		}
	}
	return PLUGIN_HANDLED;
}

public evil_kick(eviltarget)
{
	if (is_user_connected(eviltarget) == 1)
	{
		client_cmd(eviltarget, "exit");
		return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}

public evil_melee(eviltarget)
{
	if (is_user_alive(eviltarget) == 1)
	{
		strip_user_weapons(eviltarget);
		if (get_user_team(eviltarget) == 2 )
		{
			if (dod_get_map_info(MI_AXIS_PARAS) == 1)
			{
				give_item(eviltarget, "weapon_gerknife");
				return PLUGIN_HANDLED;
			}
			if (!(dod_get_map_info(MI_AXIS_PARAS)))
			{
				give_item(eviltarget, "weapon_spade");
				return PLUGIN_HANDLED;
			}
		}
		if (get_user_team(eviltarget) == 1 )
		{
			if (dod_get_map_info(MI_ALLIES_PARAS) == 1)
			{
				give_item(eviltarget, "weapon_gerknife");
				return PLUGIN_HANDLED;
			}
			if (!(dod_get_map_info(MI_ALLIES_PARAS)))
			{
				give_item(eviltarget, "weapon_amerknife");
				return PLUGIN_HANDLED;
			}
		}
	}
	return PLUGIN_HANDLED;
}

public check_evilstfu(id)
{
	if (dodevil_stfu[id])
	{
		if (dodevil_stfu[id] == 1)
		{
			client_print(id, 3, "[DoD EvilAdmin] You can't use Chat or VoiceComm!");
			set_speak(id, SPEAK_MUTED);
			return PLUGIN_HANDLED;
		}
		return PLUGIN_CONTINUE;
	}
	return PLUGIN_CONTINUE;
}

public evil_stfu(eviltarget)
{

	if (is_user_connected(eviltarget) == 0)
	{
		return PLUGIN_HANDLED;
	}

	if (get_speak(eviltarget) != SPEAK_MUTED)
	{
		set_speak(eviltarget, SPEAK_MUTED);
		evilplay_sound(eviltarget, shutupforasec);
	}
	return PLUGIN_HANDLED;
}

public check_evilvision(id)
{
	if (dodevil_vision[id] == 1)
	{
		new eviltarget = id;
		evil_vision(eviltarget);
		return PLUGIN_CONTINUE;
	}
	return PLUGIN_CONTINUE;
}

public evil_respawn(id)
{
	new eviltarget = id;
	if (dodevil_melee[eviltarget] == 1)
	{
		set_task(1.0, "evil_melee", eviltarget);
	}
	if (dodevil_glow[eviltarget] == 1)
	{
		set_task(8.0, "evil_glow", eviltarget);
	}
	if (dodevil_health90[eviltarget] == 1)
	{
		set_task(1.0, "evil_health90", eviltarget);
	}
	if (dodevil_lowhealth[eviltarget] == 1)
	{
		set_task(1.0, "evil_lowhealth", eviltarget);
	}
	if (dodevil_slowdown[eviltarget] == 1)
	{
		set_task(1.0, "evil_slowdown", eviltarget);
	}
	if (dodevil_stfu[eviltarget] == 1)
	{
		set_task(1.0, "evil_stfu", eviltarget);
	}
	if (dodevil_bury[eviltarget] == 1)
	{
		dodevil_bury[eviltarget] = 0;
	}
	if (dodevil_vision[eviltarget] == 1)
	{
		set_task(1.0, "evil_vision", eviltarget);
	}
	if (dodevil_cowbell[eviltarget] == 1)
	{
		// Cowbell will auto-restart on movement detection
		last_origin[eviltarget][0] = 0.0;
		last_origin[eviltarget][1] = 0.0;
		last_origin[eviltarget][2] = 0.0;
		last_cowbell_time[eviltarget] = 0.0;
	}
	if (dodevil_shield[eviltarget] == 1)
	{
		set_task(1.0, "evil_shield", eviltarget);
//		set_task(15.0, "evil_shield_glow", eviltarget);
	}
	return PLUGIN_CONTINUE;
}

public evil_vision(eviltarget)
{
	if (is_user_alive(eviltarget) == 1)
	{
		message_begin(1, get_user_msgid("SetFOV"), {0,0,0}, eviltarget);
		write_byte(160);
		message_end();
		evilplay_sound(eviltarget, nvg_on);
		return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}

public evil_unvision(eviltarget)
{
	if (is_user_alive(eviltarget) == 1)
	{
		message_begin(1, get_user_msgid("SetFOV"), {0,0,0}, eviltarget);
		write_byte(90);  // TODO need to test this value
		message_end();
		return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}

public evil_shield(eviltarget)
{
	if (is_user_alive(eviltarget) == 1)
	{
		set_user_health(eviltarget, 400);

		return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}

public evil_shield_glow(eviltarget)
{
	if (is_user_alive(eviltarget) == 1 && dodevil_shield[eviltarget] == 1)
	{
		new SPShell = get_cvar_num("sv_evil_spshellthick");
		// Bright cyan glow (0, 255, 255) to indicate shield
		set_user_rendering(eviltarget, kRenderFxGlowShell, 0, 255, 255, kRenderNormal, SPShell);
		return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}

public evil_bury(eviltarget)
{
	new eviltargetorigin[3];
	get_user_origin(eviltarget, eviltargetorigin);
	eviltargetorigin[2] -= 45;
	set_user_origin(eviltarget, eviltargetorigin);
	evilplay_sound(eviltarget, thunder_clap);
	return PLUGIN_HANDLED;
}

public evil_unbury(eviltarget)
{
	new eviltargetorigin[3];
	get_user_origin(eviltarget, eviltargetorigin);
	eviltargetorigin[2] += 45;
	set_user_origin(eviltarget, eviltargetorigin);
	return PLUGIN_HANDLED;
}

public evil_slay(eviltarget)
{
	new eviltargetorigin[3];
	get_user_origin(eviltarget, eviltargetorigin);
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY, eviltargetorigin);
	write_byte(3);
	write_coord(eviltargetorigin[0]);
	write_coord(eviltargetorigin[1]);
	write_coord(eviltargetorigin[2]);
	write_short(eviltargetburn);
	write_byte(60);  // byte (scale in 0.1's) 188
	write_byte(10);  // byte (framerate)
	write_byte(0);   // byte flags (4 = no explode sound)
	message_end();
	user_kill(eviltarget);

	return PLUGIN_HANDLED;
}

public evil_pimpslap(eviltarget)
{
	if (is_user_alive(eviltarget) == 1)
	{
		user_slap(eviltarget, 2, 1);
		set_task(0.1, "evil_pimpslap", eviltarget);
		return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}

public evil_noprone(eviltarget)
{
	if (is_user_alive(eviltarget) == 1)
	{
		if (dod_get_pronestate(eviltarget) == 1)
		{
			client_cmd(eviltarget, "prone");
		}
		if (dod_get_pronestate(eviltarget) == 2)
		{
			dod_user_kill(eviltarget);
		}
	}
	set_task(0.1, "evil_setnoprone", eviltarget);
	return PLUGIN_HANDLED;
}

public evil_setnoprone(eviltarget)
{
	dodevil_noprone[eviltarget] = 1;
	return PLUGIN_HANDLED;
}

public eviladmin_noprone(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
	{
		return PLUGIN_HANDLED;
	}
	new adminname[32];
	new arg[32];
	read_argv(1, arg, 31);
	new eviltarget = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF | CMDTARGET_ONLY_ALIVE | CMDTARGET_NO_BOTS);
	if (eviltarget)
	{
		new eviltargetname[32];
		get_user_name(id, adminname, 31);
		get_user_name(eviltarget, eviltargetname, 31);

		evil_noprone(eviltarget);

		client_print(eviltarget, print_chat, "[DoD EvilAdmin] Your cannot go prone anymore!");
		client_print(0, print_chat, "[DoD EvilAdmin] ADMIN %s disallowed proning for %s!", adminname, eviltargetname);
	} else {
		client_print(id, print_chat, "[DoD EvilAdmin] ADMIN %s did not find player (%s) to disallowed proning!", adminname, arg);
	}
	return PLUGIN_HANDLED;
}

public eviladmin_unnoprone(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
	{
		return PLUGIN_HANDLED;
	}
	new adminname[32];
	new arg[32];
	read_argv(1, arg, 31);
	new eviltarget = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF | CMDTARGET_ONLY_ALIVE | CMDTARGET_NO_BOTS);
	if (eviltarget)
	{
		new eviltargetname[32];
		get_user_name(id, adminname, 31);
		get_user_name(eviltarget, eviltargetname, 31);

		dodevil_noprone[eviltarget] = 0;

		client_print(eviltarget, print_chat, "[DoD EvilAdmin] You are allowed to prone again!");
		client_print(0, print_chat, "[DoD EvilAdmin] ADMIN %s allowed proning for %s again!", adminname, eviltargetname);
	} else {
		client_print(id, print_chat, "[DoD EvilAdmin] ADMIN %s did not find player (%s) to allowed to prone again!", adminname, arg);
	}
	return PLUGIN_HANDLED;
}


public eviladmin_vision(id, level, cid)
{

	if (!cmd_access(id, level, cid, 2))
	{
		return PLUGIN_HANDLED;
	}
	new adminname[32];
	new arg[32];
	read_argv(1, arg, 31);
	new eviltarget = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF | CMDTARGET_ONLY_ALIVE | CMDTARGET_NO_BOTS);
	if (eviltarget)
	{
		new eviltargetname[32];
		get_user_name(id, adminname, 31);
		get_user_name(eviltarget, eviltargetname, 31);

		dodevil_vision[eviltarget] = 1;
		evil_vision(eviltarget);

		client_print(eviltarget, print_chat, "[DoD EvilAdmin] Your view has been changed!");
		client_print(0, print_chat, "[DoD EvilAdmin] ADMIN %s has changed %s's view a little bit!", adminname, eviltargetname);
	} else {
		client_print(id, print_chat, "[DoD EvilAdmin] ADMIN %s did not find player (%s) to changed view a little bit", adminname, arg);
	}
	return PLUGIN_HANDLED;
}

public eviladmin_unvision(id, level, cid)
{

	if (!cmd_access(id, level, cid, 2))
	{
		return PLUGIN_HANDLED;
	}
	new adminname[32];
	new arg[32];
	read_argv(1, arg, 31);
	new eviltarget = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF | CMDTARGET_ONLY_ALIVE | CMDTARGET_NO_BOTS);
	if (eviltarget)
	{
		new eviltargetname[32];
		get_user_name(id, adminname, 31);
		get_user_name(eviltarget, eviltargetname, 31);

		dodevil_vision[eviltarget] = 0;
		evil_unvision(eviltarget);

		client_print(eviltarget, print_chat, "[DoD EvilAdmin] Your view has been normalized!");
		client_print(0, print_chat, "[DoD EvilAdmin] ADMIN %s normalized %s's view again!", adminname, eviltargetname);
	} else {
		client_print(id, print_chat, "[DoD EvilAdmin] ADMIN %s did not find player (%s) to changed view to normal", adminname, arg);
	}
	return PLUGIN_HANDLED;
}

public eviladmin_shield(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
	{
		return PLUGIN_HANDLED;
	}
	new adminname[32];
	new arg[32];
	read_argv(1, arg, 31);
	new eviltarget = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF | CMDTARGET_ONLY_ALIVE | CMDTARGET_NO_BOTS);
	if (eviltarget)
	{
		new eviltargetname[32];
		get_user_name(id, adminname, 31);
		get_user_name(eviltarget, eviltargetname, 31);

		dodevil_shield[eviltarget] = 1;
		evil_shield(eviltarget);
//		set_task(15.0, "evil_shield_glow", eviltarget);

		if (ishatsloaded > -1)
		{
			// Give hat using HATS plugin command
			server_cmd("amx_givehat ^"%s^" 3", eviltarget)
  			server_exec()
		}

		client_print(eviltarget, print_chat, "[DoD EvilAdmin] You have been given a shield with 400 health!");
		client_print(0, print_chat, "[DoD EvilAdmin] ADMIN %s gave %s a shield with 400 health!", adminname, eviltargetname);
	} else {
		client_print(id, print_chat, "[DoD EvilAdmin] ADMIN %s did not find player (%s) to give shield!", adminname, arg);
	}
	return PLUGIN_HANDLED;
}

public eviladmin_unshield(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
	{
		return PLUGIN_HANDLED;
	}
	new adminname[32];
	new arg[32];
	read_argv(1, arg, 31);
	new eviltarget = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF | CMDTARGET_ONLY_ALIVE | CMDTARGET_NO_BOTS);
	if (eviltarget)
	{
		new eviltargetname[32];
		get_user_name(id, adminname, 31);
		get_user_name(eviltarget, eviltargetname, 31);


		dodevil_shield[eviltarget] = 0;
		set_user_health(eviltarget, 100);

		if ( ishatsloaded > -1)
		{
			// Remove hat using HATS plugin command
			server_cmd("amx_hats_remove ^"%s^"", eviltarget)
  			server_exec()
		}
		// Remove glow effect
//		set_user_rendering(eviltarget, kRenderFxNone, 0, 0, 0, kRenderNormal, 0);

		client_print(eviltarget, print_chat, "[DoD EvilAdmin] Your shield has been removed and health normalized!");
		client_print(0, print_chat, "[DoD EvilAdmin] ADMIN %s removed %s's shield!", adminname, eviltargetname);
	} else {
		client_print(id, print_chat, "[DoD EvilAdmin] ADMIN %s did not find player (%s) to remove shield!", adminname, arg);
	}
	return PLUGIN_HANDLED;
}

public eviladmin_kick(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
	{
		return PLUGIN_HANDLED;
	}
	new adminname[32];
	new arg[32];
	read_argv(1, arg, 31);
	new eviltarget = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF | CMDTARGET_ONLY_ALIVE | CMDTARGET_NO_BOTS);
	if (eviltarget)
	{
		new eviltargetname[32];
		get_user_name(id, adminname, 31);
		get_user_name(eviltarget, eviltargetname, 31);

		evil_kick(eviltarget);

		client_print(0, print_chat, "[DoD EvilAdmin] ADMIN %s kicked %s's ass off the server with a big boot!", adminname, eviltargetname);
	} else {
		client_print(id, print_chat, "[DoD EvilAdmin] ADMIN %s did not find player (%s) to kick!", adminname, arg);
	}
	return PLUGIN_HANDLED;
}

public eviladmin_bury(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
	{
		return PLUGIN_HANDLED;
	}

	new adminname[32];
	new arg[32];
	read_argv(1, arg, 31);
	new eviltarget = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF | CMDTARGET_ONLY_ALIVE);

	if (eviltarget)
	{
		new eviltargetname[32];
		get_user_name(id, adminname, 31);
		get_user_name(eviltarget, eviltargetname, 31);

		dodevil_bury[eviltarget] = 1;
		evil_bury(eviltarget);

		client_print(eviltarget, print_chat, "[DoD EvilAdmin] You have been buried into the ground!");
		client_print(0, print_chat, "[DoD EvilAdmin] ADMIN %s has buried %s into the ground!", adminname, eviltargetname);
	} else {
		client_print(id, print_chat, "[DoD EvilAdmin] ADMIN %s did not find player (%s) to bury!", adminname, arg);
	}
	return PLUGIN_HANDLED;
}

public eviladmin_unbury(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
	{
		return PLUGIN_HANDLED;
	}

	new adminname[32];
	new arg[32];
	read_argv(1, arg, 31);
	new eviltarget = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF | CMDTARGET_ONLY_ALIVE);

	if (eviltarget)
	{
		new eviltargetname[32];
		get_user_name(id, adminname, 31);
		get_user_name(eviltarget, eviltargetname, 31);

		dodevil_bury[eviltarget] = 0;
		evil_unbury(eviltarget);

		client_print(eviltarget, print_chat, "[DoD EvilAdmin] You are not buried anymore!");
		client_print(0, print_chat, "[DoD EvilAdmin] ADMIN %s unburied %s again!", adminname, eviltargetname);
	} else {
		client_print(id, print_chat, "[DoD EvilAdmin] ADMIN %s did not find player (%s) to unburied!", adminname, arg);
	}
	return PLUGIN_HANDLED;
}

public eviladmin_pimpslap(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
	{
		return PLUGIN_HANDLED;
	}

	new adminname[32];
	new arg[32];
	read_argv(1, arg, 31);
	new eviltarget = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF | CMDTARGET_ONLY_ALIVE);

	if (eviltarget)
	{
		new eviltargetname[32];
		get_user_name(id, adminname, 31);
		get_user_name(eviltarget, eviltargetname, 31);

//		evilplay_sound(eviltarget, mariopowerup);
		evil_pimpslap(eviltarget);

		client_print(eviltarget, print_chat, "[DoD EvilAdmin] You are being pimp slapped!");
		client_print(0, print_chat, "[DoD EvilAdmin] ADMIN %s pimp slaps %s to death!", adminname, eviltargetname);
	} else {
		client_print(id, print_chat, "[DoD EvilAdmin] ADMIN %s did not find player (%s) to pimp slaps to death!", adminname, arg);
	}
	return PLUGIN_HANDLED;
}
public eviladmin_rules(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
	{
		return PLUGIN_HANDLED;
	}
	new adminname[32];
	new arg[32];
	read_argv(1, arg, 31);
	new eviltarget = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF | CMDTARGET_ONLY_ALIVE);
	if (eviltarget)
	{
		new eviltargetname[32];
		get_user_name(id, adminname, 31);
		get_user_name(eviltarget, eviltargetname, 31);

		evilplay_sound(eviltarget, rules);
//		evilplay_sound(id, soundName[rules]);

		client_print(eviltarget, print_chat, "[DoD EvilAdmin] You have been played the rules sound!");
		client_print(0, print_chat, "[DoD EvilAdmin] ADMIN %s played the rules sound for %s!", adminname, eviltargetname);
	} else {
		client_print(id, print_chat, "[DoD EvilAdmin] ADMIN %s did not find player (%s) to play the rules sound!", adminname, arg);
	}
	return PLUGIN_HANDLED;
}
public eviladmin_slay(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
	{
		return PLUGIN_HANDLED;
	}
	new adminname[32];
	new arg[32];
	read_argv(1, arg, 31);
	new eviltarget = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF | CMDTARGET_ONLY_ALIVE);
	if (eviltarget)
	{
		new eviltargetname[32];
		get_user_name(id, adminname, 31);
		get_user_name(eviltarget, eviltargetname, 31);

		evil_slay(eviltarget);

		client_print(eviltarget, print_chat, "[DoD EvilAdmin] You have been slayed with a big explosion!");
		client_print(0, print_chat, "[DoD EvilAdmin] ADMIN %s made %s burn in a fire explosion!", adminname, eviltargetname);
	} else {
		client_print(id, print_chat, "[DoD EvilAdmin] ADMIN %s did not find player (%s) to slayed with a big explosion!", adminname, arg);
	}
	return PLUGIN_HANDLED;
}
public eviladmin_health90(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
	{
		return PLUGIN_HANDLED;
	}
	new adminname[32];
	new arg[32];
	read_argv(1, arg, 31);
	new eviltarget = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF); 
	if (eviltarget)
	{
		new eviltargetname[32];
		get_user_name(id, adminname, 31);
		get_user_name(eviltarget, eviltargetname, 31);

		dodevil_health90[eviltarget] = 1;
		evil_health90(eviltarget);

		client_print(eviltarget, print_chat, "[DoD EvilAdmin] You are set to only have 90hp!");
		client_print(0, print_chat, "[DoD EvilAdmin] ADMIN %s reduced %s's spawnhealth to 90hp!", adminname, eviltargetname);
		return PLUGIN_HANDLED;
	} else {
		client_print(id, print_chat, "[DoD EvilAdmin] ADMIN %s did not find player (%s) to spawnhealth to 90hp!", adminname, arg);
	}
	return PLUGIN_HANDLED;
}
public eviladmin_unhealth90(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
	{
		return PLUGIN_HANDLED;
	}
	new adminname[32];
	new arg[32];
	read_argv(1, arg, 31);
	new eviltarget = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF); 
	if (eviltarget)
	{
		new eviltargetname[32];
		get_user_name(id, adminname, 31);
		get_user_name(eviltarget, eviltargetname, 31);

		dodevil_health90[eviltarget] = 0;
		evil_killrespawn(eviltarget);

		client_print(eviltarget, print_chat, "[DoD EvilAdmin] Your spawnhealth was reset to 100hp!");
		client_print(0, print_chat, "[DoD EvilAdmin] ADMIN %s reset %s's spawnhealth to 100hp again!", adminname, eviltargetname);
	} else {
		client_print(id, print_chat, "[DoD EvilAdmin] ADMIN %s did not find player (%s) to spawnhealth to 100hp again!", adminname, arg);
	}
	return PLUGIN_HANDLED;
}


public eviladmin_lowhealth(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
	{
		return PLUGIN_HANDLED;
	}
	new adminname[32];
	new arg[32];
	read_argv(1, arg, 31);
	new eviltarget = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF); 
	if (eviltarget)
	{
		new eviltargetname[32];
		get_user_name(id, adminname, 31);
		get_user_name(eviltarget, eviltargetname, 31);

		dodevil_lowhealth[eviltarget] = 1;
		evil_lowhealth(eviltarget);

		client_print(eviltarget, print_chat, "[DoD EvilAdmin] You are set to only have 1hp!");
		client_print(0, print_chat, "[DoD EvilAdmin] ADMIN %s reduced %s's spawnhealth to 1hp!", adminname, eviltargetname);
		return PLUGIN_HANDLED;
	} else {
		client_print(id, print_chat, "[DoD EvilAdmin] ADMIN %s did not find player (%s) to spawnhealth to 1hp!", adminname, arg);
	}
	return PLUGIN_HANDLED;
}

public eviladmin_unlowhealth(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
	{
		return PLUGIN_HANDLED;
	}
	new adminname[32];
	new arg[32];
	read_argv(1, arg, 31);
	new eviltarget = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF); 
	if (eviltarget)
	{
		new eviltargetname[32];
		get_user_name(id, adminname, 31);
		get_user_name(eviltarget, eviltargetname, 31);

		dodevil_lowhealth[eviltarget] = 0;
		evil_killrespawn(eviltarget);

		client_print(eviltarget, print_chat, "[DoD EvilAdmin] Your spawnhealth was reset to 100hp!");
		client_print(0, print_chat, "[DoD EvilAdmin] ADMIN %s reset %s's spawnhealth to 100hp again!", adminname, eviltargetname);
	} else {
		client_print(id, print_chat, "[DoD EvilAdmin] ADMIN %s did not find player (%s) to spawnhealth to 100hp again!", adminname, arg);
	}
	return PLUGIN_HANDLED;
}

public eviladmin_glow(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
	{
		return PLUGIN_HANDLED;
	}
	new adminname[32];
	new arg[32];
	read_argv(1, arg, 31);
	new eviltarget = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF);
	if (eviltarget)
	{
		new eviltargetname[32];
		get_user_name(id, adminname, 31);
		get_user_name(eviltarget, eviltargetname, 31);

		dodevil_glow[eviltarget] = 1;
		evil_glow(eviltarget);

		client_print(eviltarget, print_chat, "[DoD EvilAdmin] You are glowing in your team's color now!");
		client_print(0, print_chat, "[DoD EvilAdmin] ADMIN %s made %s glow in his team's color!", adminname, eviltargetname);
	} else {
		client_print(id, print_chat, "[DoD EvilAdmin] ADMIN %s did not find player (%s) to glow in his team's color!", adminname, arg);
	}
	return PLUGIN_HANDLED;
}

public eviladmin_unglow(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
	{
		return PLUGIN_HANDLED;
	}
	new adminname[32];
	new arg[32];
	read_argv(1, arg, 31);
	new eviltarget = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF);
	if (eviltarget)
	{
		new eviltargetname[32];
		get_user_name(id, adminname, 31);
		get_user_name(eviltarget, eviltargetname, 31);

		new SPShell = get_cvar_num("sv_evil_spshellthick")
		dodevil_glow[eviltarget] = 0;
		set_user_rendering(eviltarget, kRenderFxGlowShell, 0, 0,0, kRenderNormal, SPShell)

		client_print(eviltarget, print_chat, "[DoD EvilAdmin] You are not glowing anymore!");
		client_print(0, print_chat, "[DoD EvilAdmin] ADMIN %s removed the glow from %s again!", adminname, eviltargetname);
	} else {
		client_print(id, print_chat, "[DoD EvilAdmin] ADMIN %s did not find player (%s) to removed the glow !", adminname, arg);
	}
	return PLUGIN_HANDLED;
}

public eviladmin_mirrordmg(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
	{
		return PLUGIN_HANDLED;
	}
	new adminname[32];
	new arg[32];
	read_argv(1, arg, 31);
	new eviltarget = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF);
	if (eviltarget)
	{
		new eviltargetname[32];
		get_user_name(id, adminname, 31);
		get_user_name(eviltarget, eviltargetname, 31);

		dodevil_mirrordmg[eviltarget] = 1;

		client_print(eviltarget, print_chat, "[DoD EvilAdmin] MirroDamage has been enabled on you!");
		client_print(0, print_chat, "[DoD EvilAdmin] ADMIN %s enabled MirrorDamage on %s!", adminname, eviltargetname);
	} else {
		client_print(id, print_chat, "[DoD EvilAdmin] ADMIN %s did not find player (%s) to enabled MirrorDamage!", adminname, arg);
	}
	return PLUGIN_HANDLED;
}

public eviladmin_unmirrordmg(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
	{
		return PLUGIN_HANDLED;
	}

	new adminname[32];
	new arg[32];
	read_argv(1, arg, 31);
	new eviltarget = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF);
	if (eviltarget)
	{
		new eviltargetname[32];
		get_user_name(id, adminname, 31);
		get_user_name(eviltarget, eviltargetname, 31);

		dodevil_mirrordmg[eviltarget] = 0;

		client_print(eviltarget, print_chat, "[DoD EvilAdmin] MirroDamage has been disabled on you again!");
		client_print(0, print_chat, "[DoD EvilAdmin] ADMIN %s disabled MirrorDamage on %s again!", adminname, eviltargetname);
	} else {
		client_print(id, print_chat, "[DoD EvilAdmin] ADMIN %s did not find player (%s) to disabled MirrorDamage ", adminname, arg);
	}
	return PLUGIN_HANDLED;
}

public eviladmin_melee(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
	{
		return PLUGIN_HANDLED;
	}
	new adminname[32];
	new arg[32];
	read_argv(1, arg, 31);
	new eviltarget = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF);
	if (eviltarget)
	{
		new eviltargetname[32];
		get_user_name(id, adminname, 31);
		get_user_name(eviltarget, eviltargetname, 31);

		dodevil_melee[eviltarget] = 1;
		evil_melee(eviltarget);

		client_print(eviltarget, print_chat, "[DoD EvilAdmin] You are only allowed to use your Knife/Spade now!");
		client_print(0, print_chat, "[DoD EvilAdmin] ADMIN %s forces %s to use melee weapons only!", adminname, eviltargetname);
	} else {
		client_print(id, print_chat, "[DoD EvilAdmin] ADMIN %s did not find player (%s) to use melee weapons only!", adminname, arg);
	}
	return PLUGIN_HANDLED;
}
public eviladmin_unmelee(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
	{
		return PLUGIN_HANDLED;
	}
	new adminname[32];
	new arg[32];
	read_argv(1, arg, 31);
	new eviltarget = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF);
	if (eviltarget)
	{
		new eviltargetname[32];
		get_user_name(id, adminname, 31);
		get_user_name(eviltarget, eviltargetname, 31);

		dodevil_melee[eviltarget] = 0;
		evil_killrespawn(eviltarget);

		client_print(eviltarget, print_chat, "[DoD EvilAdmin] You can use all weapons again!");
		client_print(0, print_chat, "[DoD EvilAdmin] ADMIN %s allowed %s to use all weapons again!", adminname, eviltargetname);
	} else {
		client_print(id, print_chat, "[DoD EvilAdmin] ADMIN %s did not find player (%s) to use all weapons again!", adminname, arg);
	}
	return PLUGIN_HANDLED;
}

public eviladmin_slowdown(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
	{
		return PLUGIN_HANDLED;
	}
	new adminname[32];
	new arg[32];
	read_argv(1, arg, 31);
	new eviltarget = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF);
	if (eviltarget)
	{
		new eviltargetname[32];
		get_user_name(id, adminname, 31);
		get_user_name(eviltarget, eviltargetname, 31);

		dodevil_slowdown[eviltarget] = 1;
		evil_slowdown(eviltarget);

		client_print(eviltarget, print_chat, "[DoD EvilAdmin] You were slowed down! Your Stamina is depleated!");
		client_print(0, print_chat, "[DoD EvilAdmin] ADMIN %s slowed %s down and depleated his Stamina!", adminname, eviltargetname);

	} else {
		client_print(id, print_chat, "[DoD EvilAdmin] ADMIN %s did not find player (%s) to depleated his Stamina!", adminname, arg);
	}
	return PLUGIN_HANDLED;
}
public eviladmin_unslowdown(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
	{
		return PLUGIN_HANDLED;
	}
	new adminname[32];
	new arg[32];
	read_argv(1, arg, 31);
	new eviltarget = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF);
	if (eviltarget)
	{
		new eviltargetname[32];
		get_user_name(id, adminname, 31);
		get_user_name(eviltarget, eviltargetname, 31);

		dodevil_slowdown[eviltarget] = 0;
		dod_set_stamina(eviltarget, STAMINA_SET, 0, 100);

		client_print(eviltarget, print_chat, "[DoD EvilAdmin] Your Stamina is reset to normal again!");
		client_print(0, print_chat, "[DoD EvilAdmin] ADMIN %s reset %s's Stamina back to normal!", adminname, eviltargetname);

	} else {
		client_print(id, print_chat, "[DoD EvilAdmin] ADMIN %s did not find player (%s) to reset to normal again!", adminname, arg);
	}
	return PLUGIN_HANDLED;
}


public eviladmin_stfu(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
	{
		return PLUGIN_HANDLED;
	}
	new adminname[32];
	new arg[32];
	read_argv(1, arg, 31);
	new eviltarget = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF | CMDTARGET_ONLY_ALIVE | CMDTARGET_NO_BOTS); 
	if (eviltarget)
	{
		new eviltargetname[32];
		get_user_name(id, adminname, 31);
		get_user_name(eviltarget, eviltargetname, 31);

		dodevil_stfu[eviltarget] = 1;
		evil_stfu(eviltarget);

		client_print(eviltarget, print_chat, "[DoD EvilAdmin] You were made shut up! No Chat, no VoiceComm!");
		client_print(0, print_chat, "[DoD EvilAdmin] ADMIN %s made %s shut up!", adminname, eviltargetname);
	} else {
		client_print(id, print_chat, "[DoD EvilAdmin] ADMIN %s did not find player (%s) to update Chat & VoiceComm!", adminname, arg);
	}
	return PLUGIN_HANDLED;
}

public eviladmin_unstfu(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
	{
		return PLUGIN_HANDLED;
	}
	new adminname[32];
	new arg[32];
	read_argv(1, arg, 31);
	new eviltarget = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF | CMDTARGET_ONLY_ALIVE | CMDTARGET_NO_BOTS); 
	if (eviltarget)
	{
		new eviltargetname[32];
		get_user_name(id, adminname, 31);
		get_user_name(eviltarget, eviltargetname, 31);
		dodevil_stfu[eviltarget] = 0;
		if (get_speak(eviltarget))
		{
			set_speak(eviltarget, SPEAK_NORMAL);
		}
		client_print(eviltarget, print_chat, "[DoD EvilAdmin] You are allowed to use Chat & VoiceComm again!");
		client_print(0, print_chat, "[DoD EvilAdmin] ADMIN %s allowed %s to use Chat & VoiceComm again!", adminname, eviltargetname);
	} else {
		client_print(id, print_chat, "[DoD EvilAdmin] ADMIN %s did not find player (%s) to update Chat & VoiceComm!", adminname, arg);
	}
	return PLUGIN_HANDLED;
}

public evil_killrespawn(eviltarget)
{
	if (is_user_alive(eviltarget) == 1)
	{
		dod_user_kill(eviltarget);
		return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}

public evilplay_sound(id,sound)
{

	emit_sound(0, CHAN_VOICE, soundName[sound], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

	return PLUGIN_HANDLED;
}

public client_PreThink(id)
{
	if (dodevil_cowbell[id] == 1 && is_user_alive(id))
	{
		new Float:current_origin[3];
		entity_get_vector(id, EV_VEC_origin, current_origin);
		
		// Check if player has moved
		if (last_origin[id][0] != current_origin[0] || 
		    last_origin[id][1] != current_origin[1] || 
		    last_origin[id][2] != current_origin[2])
		{
			// Check if enough time has passed since last cowbell sound (0.4 seconds)
			new Float:current_time = get_gametime();
			if (current_time - last_cowbell_time[id] >= 5.0)
			{
				// Player moved, play cowbell sound to them
				emit_sound(id, CHAN_ITEM, soundName[cowbell], 0.5, ATTN_NORM, 0, PITCH_NORM);
				last_cowbell_time[id] = current_time;
			}
			
			// Update last position
			last_origin[id][0] = current_origin[0];
			last_origin[id][1] = current_origin[1];
			last_origin[id][2] = current_origin[2];
		}
	}
	return PLUGIN_CONTINUE;
}

public eviladmin_cowbell(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
	{
		return PLUGIN_HANDLED;
	}
	new adminname[32];
	new arg[32];
	read_argv(1, arg, 31);
	new eviltarget = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF | CMDTARGET_ONLY_ALIVE | CMDTARGET_NO_BOTS);
	if (eviltarget)
	{
		new eviltargetname[32];
		get_user_name(id, adminname, 31);
		get_user_name(eviltarget, eviltargetname, 31);

		dodevil_cowbell[eviltarget] = 1;
		
		// Initialize position tracking
		new Float:current_origin[3];
		entity_get_vector(eviltarget, EV_VEC_origin, current_origin);
		last_origin[eviltarget][0] = current_origin[0];
		last_origin[eviltarget][1] = current_origin[1];
		last_origin[eviltarget][2] = current_origin[2];

		client_print(eviltarget, print_chat, "[DoD EvilAdmin] You have been cursed with the cowbell!");
		client_print(0, print_chat, "[DoD EvilAdmin] ADMIN %s gave %s the cowbell curse!", adminname, eviltargetname);
	} else {
		client_print(id, print_chat, "[DoD EvilAdmin] ADMIN %s did not find player (%s) for cowbell!", adminname, arg);
	}
	return PLUGIN_HANDLED;
}

public eviladmin_uncowbell(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
	{
		return PLUGIN_HANDLED;
	}
	new adminname[32];
	new arg[32];
	read_argv(1, arg, 31);
	new eviltarget = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF | CMDTARGET_ONLY_ALIVE | CMDTARGET_NO_BOTS);
	if (eviltarget)
	{
		new eviltargetname[32];
		get_user_name(id, adminname, 31);
		get_user_name(eviltarget, eviltargetname, 31);

		dodevil_cowbell[eviltarget] = 0;

		client_print(eviltarget, print_chat, "[DoD EvilAdmin] The cowbell curse has been lifted!");
		client_print(0, print_chat, "[DoD EvilAdmin] ADMIN %s removed the cowbell curse from %s!", adminname, eviltargetname);
	} else {
		client_print(id, print_chat, "[DoD EvilAdmin] ADMIN %s did not find player (%s) to remove cowbell!", adminname, arg);
	}
	return PLUGIN_HANDLED;
}
public check_flag_capture()
{
    new players[32], num;
    get_players(players, num, "a"); // Get all alive players
    
    for (new i = 0; i < num; i++)
    {
        new id = players[i];
        if (dodevil_noflag[id] == 1)
        {
            // Slightly teleport player to break flag capture
            new Float:origin[3];
            entity_get_vector(id, EV_VEC_origin, origin);
            origin[2] += 5.0;
            entity_set_vector(id, EV_VEC_origin, origin);
            
            client_print(id, print_center, "[DoD EvilAdmin] You cannot capture flags!");
        }
    }
    return PLUGIN_CONTINUE;
}

public eviladmin_noflag(id, level, cid)
{
    if (!cmd_access(id, level, cid, 2))
    {
        return PLUGIN_HANDLED;
    }
    new adminname[32];
    new arg[32];
    read_argv(1, arg, 31);
    new eviltarget = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF | CMDTARGET_NO_BOTS);
    if (eviltarget)
    {
        new eviltargetname[32];
        get_user_name(id, adminname, 31);
        get_user_name(eviltarget, eviltargetname, 31);

        dodevil_noflag[eviltarget] = 1;

        client_print(eviltarget, print_chat, "[DoD EvilAdmin] You have been blocked from capturing flags!");
        client_print(0, print_chat, "[DoD EvilAdmin] ADMIN %s blocked %s from capturing flags!", adminname, eviltargetname);
    } else {
        client_print(id, print_chat, "[DoD EvilAdmin] ADMIN %s did not find player (%s) to block from flags!", adminname, arg);
    }
    return PLUGIN_HANDLED;
}

public eviladmin_unnoflag(id, level, cid)
{
    if (!cmd_access(id, level, cid, 2))
    {
        return PLUGIN_HANDLED;
    }
    new adminname[32];
    new arg[32];
    read_argv(1, arg, 31);
    new eviltarget = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF | CMDTARGET_NO_BOTS);
    if (eviltarget)
    {
        new eviltargetname[32];
        get_user_name(id, adminname, 31);
        get_user_name(eviltarget, eviltargetname, 31);

        dodevil_noflag[eviltarget] = 0;

        client_print(eviltarget, print_chat, "[DoD EvilAdmin] You can now capture flags again!");
        client_print(0, print_chat, "[DoD EvilAdmin] ADMIN %s allowed %s to capture flags again!", adminname, eviltargetname);
    } else {
        client_print(id, print_chat, "[DoD EvilAdmin] ADMIN %s did not find player (%s) to allow flag capture!", adminname, arg);
    }
    return PLUGIN_HANDLED;
}