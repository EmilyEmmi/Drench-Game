#include <ultra64.h>
#include "sm64.h"
#include "behavior_data.h"
#include "model_ids.h"
#include "seq_ids.h"
#include "dialog_ids.h"
#include "segment_symbols.h"
#include "level_commands.h"

#include "game/level_update.h"

#include "levels/scripts.h"

#include "make_const_nonconst.h"
#include "levels/rglight/header.h"

/* Fast64 begin persistent block [scripts] */
/* Fast64 end persistent block [scripts] */

const LevelScript level_rglight_entry[] = {
	INIT_LEVEL(),
	LOAD_MIO0(0x7, _rglight_segment_7SegmentRomStart, _rglight_segment_7SegmentRomEnd), 
	LOAD_MIO0(0xa, _water_skybox_mio0SegmentRomStart, _water_skybox_mio0SegmentRomEnd), 
	ALLOC_LEVEL_POOL(),
	MARIO(MODEL_MARIO, 0x00000001, bhvMario), 
	/* Fast64 begin persistent block [level commands] */
	/* Fast64 end persistent block [level commands] */

	AREA(1, rglight_area_1),
		WARP_NODE(0x0A, LEVEL_BOB, 0x01, 0x0A, WARP_NO_CHECKPOINT),
		WARP_NODE(0xF0, LEVEL_CASTLE, 0x01, 0x32, WARP_NO_CHECKPOINT),
		WARP_NODE(0xF1, LEVEL_CASTLE, 0x01, 0x64, WARP_NO_CHECKPOINT),
		OBJECT(E_MODEL_NONE, 0, 0, -11809, 0, -180, 0, 0x00000000, bhvRGDoll),
		MARIO_POS(0x01, 0, 0, 80, 0),
		OBJECT(MODEL_NONE, 0, 80, 0, 0, 0, 0, (0x0A << 16), bhvSpinAirborneWarp),
		OBJECT(E_MODEL_BUBBLY_TREE, 2715, 0, -11749, 0, 0, 0, 0x00000000, id_bhvTree),
		OBJECT(E_MODEL_BUBBLY_TREE, 1609, 0, -11482, 0, 0, 0, 0x00000000, id_bhvTree),
		OBJECT(E_MODEL_BUBBLY_TREE, 1383, 0, -12336, 0, 0, 0, 0x00000000, id_bhvTree),
		OBJECT(E_MODEL_BUBBLY_TREE, -1858, 0, -11916, 0, 0, 0, 0x00000000, id_bhvTree),
		OBJECT(E_MODEL_BUBBLY_TREE, -1232, 0, -11462, 0, 0, 0, 0x00000000, id_bhvTree),
		OBJECT(E_MODEL_BUBBLY_TREE, -2367, 0, -11457, 0, 0, 0, 0x00000000, id_bhvTree),
		OBJECT(E_MODEL_BUBBLY_TREE, 2048, 0, -12002, 0, 0, 0, 0x00000000, id_bhvTree),
		OBJECT(E_MODEL_BUBBLY_TREE, 2495, 0, -12548, 0, 0, 0, 0x00000000, id_bhvTree),
		OBJECT(E_MODEL_BUBBLY_TREE, -2652, 0, -12289, 0, 0, 0, 0x00000000, id_bhvTree),
		OBJECT(E_MODEL_BUBBLY_TREE, -1271, 0, -12421, 0, 0, 0, 0x00000000, id_bhvTree),
		TERRAIN(rglight_area_1_collision),
		MACRO_OBJECTS(rglight_area_1_macro_objs),
		SET_BACKGROUND_MUSIC(0x00, SEQ_LEVEL_GRASS),
		TERRAIN_TYPE(TERRAIN_GRASS),
		/* Fast64 begin persistent block [area commands] */
		/* Fast64 end persistent block [area commands] */
	END_AREA(),
	FREE_LEVEL_POOL(),
	MARIO_POS(0x01, 0, 0, 80, 0),
	CALL(0, lvl_init_or_update),
	CALL_LOOP(1, lvl_init_or_update),
	CLEAR_LEVEL(),
	SLEEP_BEFORE_EXIT(1),
	EXIT(),
};