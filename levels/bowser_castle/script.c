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
#include "levels/bowser_castle/header.h"

/* Fast64 begin persistent block [scripts] */
/* Fast64 end persistent block [scripts] */

const LevelScript level_bowser_castle_entry[] = {
	INIT_LEVEL(),
	LOAD_MIO0(0x7, _bowser_castle_segment_7SegmentRomStart, _bowser_castle_segment_7SegmentRomEnd), 
	ALLOC_LEVEL_POOL(),
	MARIO(MODEL_MARIO, 0x00000001, bhvMario), 
	/* Fast64 begin persistent block [level commands] */
	/* Fast64 end persistent block [level commands] */

	AREA(1, bowser_castle_area_1),
		WARP_NODE(0x0A, LEVEL_BOB, 0x01, 0x0A, WARP_NO_CHECKPOINT),
		WARP_NODE(0xF0, LEVEL_CASTLE_GROUNDS, 0x01, 0x0A, WARP_NO_CHECKPOINT),
		WARP_NODE(0xF1, LEVEL_CASTLE_GROUNDS, 0x01, 0x0A, WARP_NO_CHECKPOINT),
		MARIO_POS(0x01, 0, 1647, -719, -2088),
		OBJECT(MODEL_NONE, -1376, -3158, -1689, 0, 0, 0, (120), id_bhvArenaSpring),
		OBJECT(MODEL_NONE, 2723, -3158, -3634, 0, 0, 0, (120), id_bhvArenaSpring),
		OBJECT(MODEL_NONE, 2647, -3158, 100, 0, 0, 0, (120), id_bhvArenaSpring),
		OBJECT(MODEL_NONE, -55, -1707, 666, 0, 0, 0, (120), id_bhvArenaSpring),
		OBJECT(MODEL_STAR, 1210, -1037, -2088, 0, 0, 0, 0x00000000, bhvStealStar),
		OBJECT(MODEL_NONE, 1647, -719, -2088, 0, 0, 0, (10 << 16), bhvSpinAirborneWarp),
		TERRAIN(bowser_castle_area_1_collision),
		MACRO_OBJECTS(bowser_castle_area_1_macro_objs),
		SET_BACKGROUND_MUSIC(0x00, SEQ_LEVEL_HOT),
		TERRAIN_TYPE(TERRAIN_GRASS),
		/* Fast64 begin persistent block [area commands] */
		/* Fast64 end persistent block [area commands] */
	END_AREA(),
	FREE_LEVEL_POOL(),
	MARIO_POS(0x01, 0, 1647, -719, -2088),
	CALL(0, lvl_init_or_update),
	CALL_LOOP(1, lvl_init_or_update),
	CLEAR_LEVEL(),
	SLEEP_BEFORE_EXIT(1),
	EXIT(),
};