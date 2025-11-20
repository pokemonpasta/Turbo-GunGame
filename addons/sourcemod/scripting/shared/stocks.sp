#pragma semicolon 1


#define MIN_FADE_DISTANCE	9999.9
#define MAX_FADE_DISTANCE	9999.9
#define FAR_FUTURE	100000000.0
#define PARTICLE_DISPATCH_FROM_ENTITY		(1<<0)
#define PARTICLE_DISPATCH_RESET_PARTICLES	(1<<1)

#define EF_BONEMERGE			0x001 	// Performs bone merge on client side
#define	EF_BRIGHTLIGHT 			0x002	// DLIGHT centered at entity origin
#define	EF_DIMLIGHT 			0x004	// player flashlight
#define	EF_NOINTERP				0x008	// don't interpolate the next frame
#define	EF_NOSHADOW				0x010	// Don't cast no shadow
#define	EF_NODRAW				0x020	// don't draw entity
#define	EF_NORECEIVESHADOW		0x040	// Don't receive no shadow
#define	EF_BONEMERGE_FASTCULL	0x080	// For use with EF_BONEMERGE. If this is set, then it places this ent's origin at its
										// parent and uses the parent's bbox + the max extents of the aiment.
										// Otherwise, it sets up the parent's bones every frame to figure out where to place
										// the aiment, which is inefficient because it'll setup the parent's bones even if
										// the parent is not in the PVS.
#define	EF_ITEM_BLINK			0x100	// blink an item so that the user notices it.
#define	EF_PARENT_ANIMATES		0x200	// always assume that the parent entity is animating
#define	EF_MAX_BITS = 10

#define	SHAKE_START					0			// Starts the screen shake for all players within the radius.
#define	SHAKE_STOP					1			// Stops the screen shake for all players within the radius.
#define	SHAKE_AMPLITUDE				2			// Modifies the amplitude of an active screen shake for all players within the radius.
#define	SHAKE_FREQUENCY				3			// Modifies the frequency of an active screen shake for all players within the radius.
#define	SHAKE_START_RUMBLEONLY		4			// Starts a shake effect that only rumbles the controller, no screen effect.
#define	SHAKE_START_NORUMBLE		5			// Starts a shake that does NOT rumble the controller.
enum //hitgroup_t
{
	HITGROUP_GENERIC,
	HITGROUP_HEAD,
	HITGROUP_CHEST,
	HITGROUP_STOMACH,
	HITGROUP_LEFTARM,
	HITGROUP_RIGHTARM,
	HITGROUP_LEFTLEG,
	HITGROUP_RIGHTLEG,
	
	NUM_HITGROUPS
};
enum ParticleAttachment_t {
	PATTACH_ABSORIGIN = 0,
	PATTACH_ABSORIGIN_FOLLOW,
	PATTACH_CUSTOMORIGIN,
	PATTACH_POINT,
	PATTACH_POINT_FOLLOW,
	PATTACH_WORLDORIGIN,
	PATTACH_ROOTBONE_FOLLOW
};

enum SolidFlags_t
{
	FSOLID_CUSTOMRAYTEST		= 0x0001,	// Ignore solid type + always call into the entity for ray tests
	FSOLID_CUSTOMBOXTEST		= 0x0002,	// Ignore solid type + always call into the entity for swept box tests
	FSOLID_NOT_SOLID			= 0x0004,	// Are we currently not solid?
	FSOLID_TRIGGER				= 0x0008,	// This is something may be collideable but fires touch functions
											// even when it's not collideable (when the FSOLID_NOT_SOLID flag is set)
	FSOLID_NOT_STANDABLE		= 0x0010,	// You can't stand on this
	FSOLID_VOLUME_CONTENTS		= 0x0020,	// Contains volumetric contents (like water)
	FSOLID_FORCE_WORLD_ALIGNED	= 0x0040,	// Forces the collision rep to be world-aligned even if it's SOLID_BSP or SOLID_VPHYSICS
	FSOLID_USE_TRIGGER_BOUNDS	= 0x0080,	// Uses a special trigger bounds separate from the normal OBB
	FSOLID_ROOT_PARENT_ALIGNED	= 0x0100,	// Collisions are defined in root parent's local coordinate space
	FSOLID_TRIGGER_TOUCH_DEBRIS	= 0x0200,	// This trigger will touch debris objects

	FSOLID_MAX_BITS	= 10
};

enum g_Collision_Group
{
    COLLISION_GROUP_NONE  = 0,
    COLLISION_GROUP_DEBRIS,            // Collides with nothing but world and static stuff
    COLLISION_GROUP_DEBRIS_TRIGGER,        // Same as debris, but hits triggers
    COLLISION_GROUP_INTERACTIVE_DEBRIS,    // Collides with everything except other interactive debris or debris
    COLLISION_GROUP_INTERACTIVE,        // Collides with everything except interactive debris or debris    Can be hit by bullets, explosions, players, projectiles, melee
    COLLISION_GROUP_PLAYER,            // Can be hit by bullets, explosions, players, projectiles, melee
    COLLISION_GROUP_BREAKABLE_GLASS,
    COLLISION_GROUP_VEHICLE,
    COLLISION_GROUP_PLAYER_MOVEMENT,    // For HL2, same as Collision_Group_Player, for TF2, this filters out other players and CBaseObjects

    COLLISION_GROUP_NPC,        // Generic NPC group
    COLLISION_GROUP_IN_VEHICLE,    // for any entity inside a vehicle    Can be hit by explosions. Melee unknown.
    COLLISION_GROUP_WEAPON,        // for any weapons that need collision detection
    COLLISION_GROUP_VEHICLE_CLIP,    // vehicle clip brush to restrict vehicle movement
    COLLISION_GROUP_PROJECTILE,    // Projectiles!
    COLLISION_GROUP_DOOR_BLOCKER,    // Blocks entities not permitted to get near moving doors
    COLLISION_GROUP_PASSABLE_DOOR,    // ** sarysa TF2 note: Must be scripted, not passable on physics prop (Doors that the player shouldn't collide with)
    COLLISION_GROUP_DISSOLVING,    // Things that are dissolving are in this group
    COLLISION_GROUP_PUSHAWAY,    // ** sarysa TF2 note: I could swear the collision detection is better for this than NONE. (Nonsolid on client and server, pushaway in player code) // Can be hit by bullets, explosions, projectiles, melee
    COLLISION_GROUP_NPC_ACTOR,        // Used so NPCs in scripts ignore the player.
    COLLISION_GROUP_NPC_SCRIPTED = 19,    // Used for NPCs in scripts that should not collide with each other.

    LAST_SHARED_COLLISION_GROUP,

    TF_COLLISIONGROUP_GRENADE = 20,
    TFCOLLISION_GROUP_OBJECT,
    TFCOLLISION_GROUP_OBJECT_SOLIDTOPLAYERMOVEMENT,
    TFCOLLISION_GROUP_COMBATOBJECT,
    TFCOLLISION_GROUP_ROCKETS,        // Solid to players, but not player movement. ensures touch calls are originating from rocket
    TFCOLLISION_GROUP_RESPAWNROOMS,
    TFCOLLISION_GROUP_TANK,
    TFCOLLISION_GROUP_ROCKET_BUT_NOT_WITH_OTHER_ROCKETS
	
};




stock int TF2_GetClassnameSlot(const char[] classname, int entity = -1)
{
	//if we already got the slot, dont bother.
	if(entity != -1 && i_SavedActualWeaponSlot[entity] != -1)
	{
		return i_SavedActualWeaponSlot[entity];
	}
	//This is a bandaid fix.
	int Index = TF2_GetClassnameSlotInternal(classname, false);
	if(entity != -1)
	{
		i_SavedActualWeaponSlot[entity] = Index;
	}
	return Index;
}

stock int TF2_GetClassnameSlotInternal(const char[] classname, bool econ=false)
{
	if(StrEqual(classname, "tf_weapon_scattergun") ||
	   StrEqual(classname, "tf_weapon_handgun_scout_primary") ||
	   StrEqual(classname, "tf_weapon_soda_popper") ||
	   StrEqual(classname, "tf_weapon_pep_brawler_blaster") ||
	  !StrContains(classname, "tf_weapon_rocketlauncher") ||
	   StrEqual(classname, "tf_weapon_particle_cannon") ||
	   StrEqual(classname, "tf_weapon_flamethrower") ||
	   StrEqual(classname, "tf_weapon_grenadelauncher") ||
	   StrEqual(classname, "tf_weapon_cannon") ||
	   StrEqual(classname, "tf_weapon_minigun") ||
	   StrEqual(classname, "tf_weapon_shotgun_primary") ||
	   StrEqual(classname, "tf_weapon_sentry_revenge") ||
	   StrEqual(classname, "tf_weapon_drg_pomson") ||
	   StrEqual(classname, "tf_weapon_shotgun_building_rescue") ||
	   StrEqual(classname, "tf_weapon_syringegun_medic") ||
	   StrEqual(classname, "tf_weapon_crossbow") ||
	  !StrContains(classname, "tf_weapon_sniperrifle") ||
	   StrEqual(classname, "tf_weapon_compound_bow"))
	{
		return TFWeaponSlot_Primary;
	}
	else if(!StrContains(classname, "tf_weapon_pistol") ||
	  !StrContains(classname, "tf_weapon_lunchbox") ||
	  !StrContains(classname, "tf_weapon_jar") ||
	   StrEqual(classname, "tf_weapon_handgun_scout_secondary") ||
	   StrEqual(classname, "tf_weapon_cleaver") ||
	  !StrContains(classname, "tf_weapon_shotgun") ||
	   StrEqual(classname, "tf_weapon_buff_item") ||
	   StrEqual(classname, "tf_weapon_raygun") ||
	  !StrContains(classname, "tf_weapon_flaregun") ||
	  !StrContains(classname, "tf_weapon_rocketpack") ||
	  !StrContains(classname, "tf_weapon_pipebomblauncher") ||
	   StrEqual(classname, "tf_weapon_laser_pointer") ||
	   StrEqual(classname, "tf_weapon_mechanical_arm") ||
	   StrEqual(classname, "tf_weapon_medigun") ||
	   StrEqual(classname, "tf_weapon_smg") ||
	   StrEqual(classname, "tf_weapon_charged_smg"))
	{
		return TFWeaponSlot_Secondary;
	}
	else if(!StrContains(classname, "tf_weapon_re"))	// Revolver
	{
		return econ ? TFWeaponSlot_Secondary : TFWeaponSlot_Primary;
	}
	else if(StrEqual(classname, "tf_weapon_sa"))	// Sapper
	{
		return econ ? TFWeaponSlot_Building : TFWeaponSlot_Secondary;
	}
	else if(!StrContains(classname, "tf_weapon_i") || !StrContains(classname, "tf_weapon_pda_engineer_d"))	// Invis & Destory PDA
	{
		return econ ? TFWeaponSlot_Item1 : TFWeaponSlot_Building;
	}
	else if(!StrContains(classname, "tf_weapon_p"))	// Disguise Kit & Build PDA
	{
		return econ ? TFWeaponSlot_PDA : TFWeaponSlot_Grenade;
	}
	else if(!StrContains(classname, "tf_weapon_bu"))	// Builder Box
	{
		return econ ? TFWeaponSlot_Building : TFWeaponSlot_PDA;
	}
	else if(!StrContains(classname, "tf_weapon_sp"))	 // Spellbook
	{
		return TFWeaponSlot_Item1;
	}
	return TFWeaponSlot_Melee;
}



stock int GetMaxWeapons(int client)
{
	static int maxweps;
	if(!maxweps)
		maxweps = GetEntPropArraySize(client, Prop_Send, "m_hMyWeapons");

	return maxweps;
}


stock void SetPlayerActiveWeapon(int client, int weapon)
{
	TF2Util_SetPlayerActiveWeapon(client, weapon);
	/*
	char buffer[64];
	GetEntityClassname(weapon, buffer, sizeof(buffer));
	FakeClientCommand(client, "use %s", buffer); 					//allow client to change
	SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);	//Force client to change.
	OnWeaponSwitchPost(client, weapon);
	*/
}


stock int Spawn_Buildable(int client, int AllowBuilding = -1)
{
	int entity = SpawnWeapon(client, "tf_weapon_builder", 28, 1, 0, view_as<int>({148}), view_as<float>({1.0}), 1); 
	if(entity > MaxClients)
	{
		SetEntProp(entity, Prop_Send, "m_bValidatedAttachedEntity", true);
		SetEntProp(entity, Prop_Send, "m_iAccountID", GetSteamAccountID(client, false));
		Attributes_Set(entity, 148, 0.0);
		
		if(AllowBuilding == -1)
		{
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", false, _, 0); //Dispenser
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", false, _, 1); //Teleporter
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", false, _, 2); //Sentry
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", false, _, 3);
		}
		else if(AllowBuilding == 0)
		{
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", true, _, 0); //Dispenser
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", false, _, 1); //Teleporter
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", false, _, 2); //Sentry
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", false, _, 3);
		}
		else if(AllowBuilding == 2)
		{
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", false, _, 0); //Dispenser
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", false, _, 1); //Teleporter
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", true, _, 2); //Sentry
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", false, _, 3);
		}
		else
		{
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", false, _, 0); //Dispenser
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", false, _, 1); //Teleporter
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", false, _, 2); //Sentry
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", false, _, 3);
		}
		
	//	PrintToChatAll("%i",GetEntPropEnt(entity, Prop_Send, "m_hOwner"));
		
		Attributes_Set(client, 353, 1.0);
		
		Attributes_Set(entity, 292, 3.0);
		Attributes_Set(entity, 293, 59.0);
		Attributes_Set(entity, 495, 60.0); //Kill eater score shit, i dont know.
	//	TF2_SetPlayerClass_ZR(client, TFClass_Engineer);
		return entity;
	}	
	return -1;
}


stock int SpawnWeapon(int client, char[] name, int index, int level, int qual, const int[] attrib, const float[] value, int count, int custom_classSetting = 0)
{
	if(custom_classSetting == 11)
	{
		custom_classSetting = 0;
	}
	int weapon = SpawnWeaponBase(client, name, index, level, qual, custom_classSetting);
	if(weapon != -1)
	{
		HandleAttributes(weapon, attrib, value, count); //Thanks suza! i love my min models
	}
	return weapon;
}

static int SpawnWeaponBase(int client, char[] name, int index, int level, int qual, int custom_classSetting = 0)
{
	Handle weapon = TF2Items_CreateItem(OVERRIDE_ALL|FORCE_GENERATION|PRESERVE_ATTRIBUTES);
	if(weapon == INVALID_HANDLE)
		return -1;
	
	TF2Items_SetClassname(weapon, name);
	TF2Items_SetItemIndex(weapon, index);
	TF2Items_SetLevel(weapon, level);
	TF2Items_SetQuality(weapon, qual);
	TF2Items_SetNumAttributes(weapon, 0);


	TFClassType class = TF2_GetWeaponClass(index, CurrentClass[client], TF2_GetClassnameSlot(name, true));
	if(custom_classSetting != 0)
	{
		class = view_as<TFClassType>(custom_classSetting);
	}
	TF2_SetPlayerClass_ZR(client, class, _, false);

	
	int entity = TF2Items_GiveNamedItem(client, weapon);
	delete weapon;
	if(entity > MaxClients)
	{


		Attributes_EntityDestroyed(entity);

		//for(int i; i < count; i++)
		//{
		//	Attributes_Set(entity, attrib[i], value[i]);
		//}
		
		if(StrEqual(name, "tf_weapon_sapper"))
		{
			SetEntProp(entity, Prop_Send, "m_iObjectType", 3);
			SetEntProp(entity, Prop_Data, "m_iSubType", 3);
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", false, _, 0);
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", false, _, 1);
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", false, _, 2);
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", true, _, 3);
		}
		else if(StrEqual(name, "tf_weapon_builder"))
		{
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", true, _, 0);
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", true, _, 1);
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", true, _, 2);
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", false, _, 3);
		}

		SetEntProp(entity, Prop_Send, "m_bValidatedAttachedEntity", true);
		SetEntProp(entity, Prop_Send, "m_iAccountID", GetSteamAccountID(client, false));

		EquipPlayerWeapon(client, entity);
	}

	TF2_SetPlayerClass_ZR(client, CurrentClass[client], _, false);

	return entity;
}

//										 info.Attribs, info.Value, info.Attribs);
public void HandleAttributes(int weapon, const int[] attributes, const float[] values, int count)
{
	RemoveAllDefaultAttribsExceptStrings(weapon);
	
	for(int i = 0; i < count; i++) 
	{
		Attributes_Set(weapon, attributes[i], values[i]);
	}
}

void RemoveAllDefaultAttribsExceptStrings(int entity)
{
	Attributes_RemoveAll(entity);
	
	char valueType[2];
	char valueFormat[64];
	
	int currentAttrib;
	
	ArrayList staticAttribs = TF2Econ_GetItemStaticAttributes(GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex"));
	char Weaponname[64];
	GetEntityClassname(entity, Weaponname, sizeof(Weaponname));
	DHook_HookStripWeapon(entity);
	
	for(int i = 0; i < staticAttribs.Length; i++)
	{
		currentAttrib = staticAttribs.Get(i, .block = 0);
	
		// Probably overkill
		if(currentAttrib == 796 || currentAttrib == 724 || currentAttrib == 817 || currentAttrib == 834 
			|| currentAttrib == 745 || currentAttrib == 731 || currentAttrib == 746)
			continue;
	
		// "stored_as_integer" is absent from the attribute schema if its type is "string".
		// TF2ED_GetAttributeDefinitionString returns false if it can't find the given string.
		if(!TF2Econ_GetAttributeDefinitionString(currentAttrib, "stored_as_integer", valueType, sizeof(valueType)))
			continue;
	
		TF2Econ_GetAttributeDefinitionString(currentAttrib, "description_format", valueFormat, sizeof(valueFormat));
	
		// Since we already know what we're working with and what we're looking for, we can manually handpick
		// the most significative chars to check if they match. Eons faster than doing StrEqual or StrContains.
	
		
		if(valueFormat[9] == 'a' && valueFormat[10] == 'd') // value_is_additive & value_is_additive_percentage
		{
			Attributes_Set(entity, currentAttrib, 0.0, true);
		}
		else if((valueFormat[9] == 'i' && valueFormat[18] == 'p')
			|| (valueFormat[9] == 'p' && valueFormat[10] == 'e')) // value_is_percentage & value_is_inverted_percentage
		{
			Attributes_Set(entity, currentAttrib, 1.0, true);
		}
		else if(valueFormat[9] == 'o' && valueFormat[10] == 'r') // value_is_or
		{
			Attributes_Set(entity, currentAttrib, 0.0, true);
		}
		
		NullifySpecificAttributes(entity,currentAttrib);
	}
	
	delete staticAttribs;	
}

stock void NullifySpecificAttributes(int entity, int attribute)
{
	switch(attribute)
	{
		case 781: //Is sword
		{
			Attributes_Set(entity, attribute, 0.0);	
		}
		case 128: //Provide on active
		{
			Attributes_Set(entity, attribute, 0.0);	
		}
	}
}


stock bool TF2_GetItem(int client, int &weapon, int &pos)
{
	//Could be looped through client slots, but would cause issues with >1 weapons in same slot
	int maxWeapons = GetMaxWeapons(client);

	//Loop though all weapons (non-wearables)
	while(pos < maxWeapons)
	{
		weapon = GetEntPropEnt(client, Prop_Send, "m_hMyWeapons", pos);
		pos++;

		if(weapon > MaxClients)
			return true;
	}
	return false;
}


stock void TF2_SetPlayerClass_ZR(int client, TFClassType classType, bool weapons=true, bool persistent=true)
{
	if(classType < TFClass_Scout || classType > TFClass_Engineer)
	{
		LogStackTrace("Invalid class %d", classType);
		classType = TFClass_Scout;
	}
	
	TF2_SetPlayerClass(client, classType, weapons, persistent);
}



stock void SetTeam(int entity, int teamSet)
{
	if(entity > 0 && entity <= MAXENTITIES)
	{
		if(entity <= MaxClients)
		{
			ChangeClientTeam(entity, teamSet);
		}
		else
		{
			SetEntProp(entity, Prop_Data, "m_iTeamNum", teamSet);
		}
	}
	else
	{
		SetEntProp(entity, Prop_Data, "m_iTeamNum", teamSet);
	}
}


stock bool TF2_GetWearable(int client, int &entity)
{
	while((entity=FindEntityByClassname(entity, "tf_wear*")) != -1)
	{
		if(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == client)
			return true;
	}
	return false;
}


stock bool IsValidClient( int client)
{	
	if ( client <= 0 || client > MaxClients )
		return false; 
	if ( !IsClientInGame( client ) ) 
		return false; 
		
	return true; 
}

void UpdatePlayerFakeModel(int client)
{
	int PlayerModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
	if(PlayerModel <= 0)
		return;

	SDKCall_RecalculatePlayerBodygroups(client);
	int i_nm_body_client = GetEntProp(client, Prop_Data, "m_nBody");
	SetEntProp(PlayerModel, Prop_Send, "m_nBody", i_nm_body_client);
}




stock float ClassHealth(TFClassType class)
{
	switch(class)
	{
		case TFClass_Soldier:
			return 200.0;

		case TFClass_Pyro, TFClass_DemoMan:
			return 175.0;

		case TFClass_Heavy:
			return 300.0;

		case TFClass_Medic:
			return 150.0;
	}
	
	return 125.0;
}
stock float RemoveExtraHealth(TFClassType class, float value)
{
	return value - ClassHealth(class);
}

stock float RemoveExtraSpeed(TFClassType class, float value)
{
	switch(class)
	{
		case TFClass_Scout:
			return value / 400.0;

		case TFClass_Soldier:
			return value / 240.0;

		case TFClass_DemoMan:
			return value / 280.0;

		case TFClass_Heavy:
			return value / 230.0;

		case TFClass_Medic, TFClass_Spy:
			return value / 320.0;

		default:
			return value / 300.0;
	}
}



stock TFClassType TF2_GetWeaponClass(int index, TFClassType defaul=TFClass_Unknown, int checkSlot=-1)
{
	switch(index)
	{
		case 25, 26:
			return TFClass_Engineer;
		
		case 735, 736, 810, 831, 933, 1080, 1102:
			return TFClass_Spy;
	}
	
	if(defaul != TFClass_Unknown)
	{
		int slot = TF2Econ_GetItemLoadoutSlot(index, defaul);
		if(checkSlot != -1)
		{
			if(slot == checkSlot)
				return defaul;
		}
		else if(slot>=0 && slot<6)
		{
			return defaul;
		}
	}

	TFClassType backup;
	for(TFClassType class=TFClass_Engineer; class>TFClass_Unknown; class--)
	{
		if(defaul == class)
			continue;

		int slot = TF2Econ_GetItemLoadoutSlot(index, class);
		if(checkSlot != -1)
		{
			if(slot == checkSlot)
				return class;
			
			if(!backup && slot >= 0 && slot < 6)
				backup = class;
		}
		else if(slot >= 0 && slot < 6)
		{
			return class;
		}
	}

	if(checkSlot != -1 && backup)
		return backup;
	
	return defaul;
}


stock void DHook_CreateDetour(GameData gamedata, const char[] name, DHookCallback preCallback = INVALID_FUNCTION, DHookCallback postCallback = INVALID_FUNCTION)
{
	DynamicDetour detour = DynamicDetour.FromConf(gamedata, name);
	if(detour)
	{
		if(preCallback!=INVALID_FUNCTION && !DHookEnableDetour(detour, false, preCallback))
			LogError("[Gamedata] Failed to enable pre detour: %s", name);

		if(postCallback!=INVALID_FUNCTION && !DHookEnableDetour(detour, true, postCallback))
			LogError("[Gamedata] Failed to enable post detour: %s", name);

		delete detour;
	}
	else
	{
		LogError("[Gamedata] Could not find %s", name);
	}
}




stock int GetAmmo(int client, int type)
{

	int ammo = GetEntProp(client, Prop_Data, "m_iAmmo", _, type);
	if(ammo < 0)
		ammo = 0;

	return ammo;
}

stock void SetAmmo(int client, int type, int ammo)
{
	SetEntProp(client, Prop_Data, "m_iAmmo", ammo, _, type);
}


stock void DisplayCritAboveNpc(int victim = -1, int client, bool sound, float position[3] = {0.0,0.0,0.0}, int ParticleIndex = -1, bool minicrit = false)
{
	float chargerPos[3];
	if(victim != -1)
	{
		GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", chargerPos);
		chargerPos[2] += 82.0;
	}
	else
	{
		chargerPos = position;
	}

	if(sound)
	{
		if(minicrit)
		{
			switch(GetRandomInt(1,5))
			{
				case 1:
				{
					EmitSoundToClient(client, "player/crit_hit_mini.wav", _, _, 80, _, 0.8, 100);
				}
				case 2:
				{
					EmitSoundToClient(client, "player/crit_hit_mini2.wav", _, _, 80, _, 0.8, 100);
				}
				case 3:
				{
					EmitSoundToClient(client, "player/crit_hit_mini3.wav", _, _, 80, _, 0.8, 100);
				}
				case 4:
				{
					EmitSoundToClient(client, "player/crit_hit_mini4.wav", _, _, 80, _, 0.8, 100);
				}
				
			}			
		}
		else
		{
			switch(GetRandomInt(1,5))
			{
				case 1:
				{
					EmitSoundToClient(client, "player/crit_hit.wav", _, _, 80, _, 0.8, 100);
				}
				case 2:
				{
					EmitSoundToClient(client, "player/crit_hit2.wav", _, _, 80, _, 0.8, 100);
				}
				case 3:
				{
					EmitSoundToClient(client, "player/crit_hit3.wav", _, _, 80, _, 0.8, 100);
				}
				case 4:
				{
					EmitSoundToClient(client, "player/crit_hit4.wav", _, _, 80, _, 0.8, 100);
				}
				case 5:
				{
					EmitSoundToClient(client, "player/crit_hit5.wav", _, _, 80, _, 0.8, 100);
				}
				
			}		
		}

	}
	if(ParticleIndex != -1)
	{
		TE_ParticleInt(ParticleIndex, chargerPos);
		TE_SendToClient(client);	
	}
	else
	{
		if(minicrit)
		{
			TE_ParticleInt(g_particleMiniCritText, chargerPos);
			TE_SendToClient(client);
		}
		else
		{
			TE_ParticleInt(g_particleCritText, chargerPos);
			TE_SendToClient(client);	
		}	
	}
}



void TE_ParticleInt(int iParticleIndex, const float origin[3] = NULL_VECTOR, const float start[3] = NULL_VECTOR, const float angles[3] = NULL_VECTOR, int entindex = -1, int attachtype = -1, int attachpoint = -1, bool resetParticles = true)
{
	TE_Start("TFParticleEffect");
	TE_WriteFloat("m_vecOrigin[0]", origin[0]);
	TE_WriteFloat("m_vecOrigin[1]", origin[1]);
	TE_WriteFloat("m_vecOrigin[2]", origin[2]);
	TE_WriteFloat("m_vecStart[0]", start[0]);
	TE_WriteFloat("m_vecStart[1]", start[1]);
	TE_WriteFloat("m_vecStart[2]", start[2]);
	TE_WriteVector("m_vecAngles", angles);
	TE_WriteNum("m_iParticleSystemIndex", iParticleIndex);
	TE_WriteNum("entindex", entindex);
	
	if (attachtype != -1)
	{
		TE_WriteNum("m_iAttachType", attachtype);
	}
	
	if (attachpoint != -1)
	{
		TE_WriteNum("m_iAttachmentPointIndex", attachpoint);
	}
	TE_WriteNum("m_bResetParticles", resetParticles ? 1 : 0);
}



stock int PrecacheParticleSystem(const char[] particleSystem)
{
	static int particleEffectNames = INVALID_STRING_TABLE;
	if (particleEffectNames == INVALID_STRING_TABLE)
	{
		if ((particleEffectNames = FindStringTable("ParticleEffectNames")) == INVALID_STRING_TABLE)
		{
			return INVALID_STRING_INDEX;
		}
	}
	
	int index = FindStringIndex2(particleEffectNames, particleSystem);
	if (index == INVALID_STRING_INDEX)
	{
		int numStrings = GetStringTableNumStrings(particleEffectNames);
		if (numStrings >= GetStringTableMaxStrings(particleEffectNames))
		{
			return INVALID_STRING_INDEX;
		}
		
		AddToStringTable(particleEffectNames, particleSystem);
		index = numStrings;
	}
	
	return index;
}

stock int FindStringIndex2(int tableidx, const char[] str)
{
	char buf[1024];
	int numStrings = GetStringTableNumStrings(tableidx);
	for (int idx = 0; idx < numStrings; idx++)
	{
		ReadStringTable(tableidx, idx, buf, sizeof(buf));
		if (strcmp(buf, str) == 0)
		{
			return idx;
		}
	}
	
	return INVALID_STRING_INDEX;
}



stock float fmax(float n1, float n2)
{
	return n1 > n2 ? n1 : n2;
}

stock bool Client_Shake(int client, int command=SHAKE_START, float amplitude=50.0, float frequency=150.0, float duration=3.0)
{
	//allow settings for the sick who cant handle screenshake.
	//can cause headaches.
	if (command == SHAKE_STOP) {
		amplitude = 0.0;
	}
	else if (amplitude <= 0.0) {
		return false;
	}

	Handle userMessage = StartMessageOne("Shake", client);

	if (userMessage == INVALID_HANDLE) {
		return false;
	}

	if (GetFeatureStatus(FeatureType_Native, "GetUserMessageType") == FeatureStatus_Available
		&& GetUserMessageType() == UM_Protobuf) {

		PbSetInt(userMessage,   "command",		 command);
		PbSetFloat(userMessage, "local_amplitude", amplitude);
		PbSetFloat(userMessage, "frequency",	   frequency);
		PbSetFloat(userMessage, "duration",		duration);
	}
	else {
		BfWriteByte(userMessage,	command);	// Shake Command
		BfWriteFloat(userMessage,	amplitude);	// shake magnitude/amplitude
		BfWriteFloat(userMessage,	frequency);	// shake noise frequency
		BfWriteFloat(userMessage,	duration);	// shake lasts this long
	}

	EndMessage();

	return true;
}


void RequestFrames(RequestFrameCallback func, int frames, any data=0)
{
	frames = RoundToNearest(TickrateModify * float(frames));
	DataPack pack = new DataPack();
	pack.WriteCell(frames);
	pack.WriteFunction(func);
	pack.WriteCell(data);
	RequestFrame(RequestFramesCallback, pack);
}

public void RequestFramesCallback(DataPack pack)
{
	pack.Reset();

	int frames = pack.ReadCell();
	if(frames < 1)
	{
		Function func = pack.ReadFunction();
		any data = pack.ReadCell();
		delete pack;
		
		Call_StartFunction(null, func);
		Call_PushCell(data);
		Call_Finish();
	}
	else
	{
		pack.Position--;
		pack.WriteCell(frames-1, false);
		RequestFrame(RequestFramesCallback, pack);
	}
}



stock int ParticleEffectAt(float position[3], const char[] effectName, float duration = 0.1)
{
	int particle = CreateEntityByName("info_particle_system");
	if (particle != -1)
	{
		TeleportEntity(particle, position, NULL_VECTOR, NULL_VECTOR);
		SetEntPropFloat(particle, Prop_Data, "m_flSimulationTime", GetGameTime());
		DispatchKeyValue(particle, "targetname", "rpg_fortress");
		if(effectName[0])
			DispatchKeyValue(particle, "effect_name", effectName);
		else
			DispatchKeyValue(particle, "effect_name", "3rd_trail");

		DispatchSpawn(particle);
		if(effectName[0])
		{
			ActivateEntity(particle);
			AcceptEntityInput(particle, "start");
		}
		SetEdictFlags(particle, (GetEdictFlags(particle) & ~FL_EDICT_ALWAYS));	
		//if it has no effect name, then it should always display, as its for other reasons.
		if (duration > 0.0)
			CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);
	}
	return particle;
}


stock void SetParent(int iParent, int iChild, const char[] szAttachment = "", const float vOffsets[3] = {0.0,0.0,0.0}, bool maintain_anyways = false)
{
	SetVariantString("!activator");
	AcceptEntityInput(iChild, "SetParent", iParent, iChild);
	
	if (szAttachment[0] != '\0') // Use at least a 0.01 second delay between SetParent and SetParentAttachment inputs.
	{
		if (szAttachment[0]) // do i even have anything?
		{
			SetVariantString(szAttachment); // "head"

			if (maintain_anyways || !AreVectorsEqual(vOffsets, view_as<float>({0.0,0.0,0.0}))) // NULL_VECTOR
			{
				if(!maintain_anyways)
				{
					float Vecpos[3];

					Vecpos = vOffsets;
					SDKCall_SetLocalOrigin(iChild,Vecpos);
				}
				AcceptEntityInput(iChild, "SetParentAttachmentMaintainOffset", iParent, iChild);
			}
			else
			{
				AcceptEntityInput(iChild, "SetParentAttachment", iParent, iChild);
			}
		}
	}
}


public Action Timer_RemoveEntity(Handle timer, any entid)
{
	int entity = EntRefToEntIndex(entid);
	if(IsValidEntity(entity))
	{
		RemoveEntity(entity);
	}
	return Plugin_Stop;
}


stock bool AreVectorsEqual(const float vVec1[3], const float vVec2[3])
{
	return (vVec1[0] == vVec2[0] && vVec1[1] == vVec2[1] && vVec1[2] == vVec2[2]);
} 

void ForceTeamWin(TFTeam team)
{
	int entity = FindEntityByClassname(-1, "game_round_win");
	bool shouldDelete;
	
	if (entity == -1)
	{
		entity = CreateEntityByName("game_round_win");
		DispatchSpawn(entity);
		shouldDelete = true;
	}
	
	SetVariantInt(view_as<int>(team));
	AcceptEntityInput(entity, "SetTeam");
	AcceptEntityInput(entity, "RoundWin");
	
	if (shouldDelete)
		RemoveEntity(entity);
}