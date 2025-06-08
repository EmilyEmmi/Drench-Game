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
#include "levels/bridge/header.h"

/* Fast64 begin persistent block [scripts] */
/* Fast64 end persistent block [scripts] */

const LevelScript level_bridge_entry[] = {
	INIT_LEVEL(),
	LOAD_MIO0(0x7, _bridge_segment_7SegmentRomStart, _bridge_segment_7SegmentRomEnd), 
	LOAD_MIO0(0xa, _water_skybox_mio0SegmentRomStart, _water_skybox_mio0SegmentRomEnd), 
	ALLOC_LEVEL_POOL(),
	MARIO(MODEL_MARIO, 0x00000001, bhvMario), 
	/* Fast64 begin persistent block [level commands] */
	/* Fast64 end persistent block [level commands] */

	AREA(1, bridge_area_1),
		WARP_NODE(0x0A, LEVEL_BOB, 0x01, 0x0A, WARP_NO_CHECKPOINT),
		WARP_NODE(0xF0, LEVEL_CASTLE, 0x01, 0x32, WARP_NO_CHECKPOINT),
		WARP_NODE(0xF1, LEVEL_CASTLE, 0x01, 0x64, WARP_NO_CHECKPOINT),
		MARIO_POS(0x01, 0, 0, 421, -8230),
		OBJECT(MODEL_NONE, 0, 421, -8230, 0, 0, 0, (0x0A << 16), bhvSpinAirborneWarp),
		OBJECT(MODEL_NONE, 568, -101, -5816, 0, 0, 0, 0x00000000, bhvGlass),
		OBJECT(MODEL_NONE, -568, -101, -5816, 0, 0, 0, 0x00000000, bhvGlass),
		OBJECT(MODEL_NONE, 568, -101, -4523, 0, 0, 0, (1 << 16), bhvGlass),
		OBJECT(MODEL_NONE, -568, -101, -4523, 0, 0, 0, (1 << 16), bhvGlass),
		OBJECT(MODEL_NONE, 568, -101, -3231, 0, 0, 0, (2 << 16), bhvGlass),
		OBJECT(MODEL_NONE, -568, -101, -3231, 0, 0, 0, (2 << 16), bhvGlass),
		OBJECT(MODEL_NONE, 568, -101, -1939, 0, 0, 0, (3 << 16), bhvGlass),
		OBJECT(MODEL_NONE, -568, -101, -1939, 0, 0, 0, (3 << 16), bhvGlass),
		OBJECT(MODEL_NONE, 568, -101, -646, 0, 0, 0, (4 << 16), bhvGlass),
		OBJECT(MODEL_NONE, -568, -101, -646, 0, 0, 0, (4 << 16), bhvGlass),
		OBJECT(MODEL_NONE, 568, -101, 646, 0, 0, 0, (5 << 16), bhvGlass),
		OBJECT(MODEL_NONE, -568, -101, 646, 0, 0, 0, (5 << 16), bhvGlass),
		OBJECT(MODEL_NONE, 568, -101, 1939, 0, 0, 0, (6 << 16), bhvGlass),
		OBJECT(MODEL_NONE, -568, -101, 1939, 0, 0, 0, (6 << 16), bhvGlass),
		OBJECT(MODEL_NONE, 568, -101, 3231, 0, 0, 0, (7 << 16), bhvGlass),
		OBJECT(MODEL_NONE, -568, -101, 3231, 0, 0, 0, (7 << 16), bhvGlass),
		OBJECT(MODEL_NONE, 568, -101, 4523, 0, 0, 0, (8 << 16), bhvGlass),
		OBJECT(MODEL_NONE, -568, -101, 4523, 0, 0, 0, (8 << 16), bhvGlass),
		OBJECT(MODEL_NONE, 568, -101, 5816, 0, 0, 0, (9 << 16), bhvGlass),
		OBJECT(MODEL_NONE, -568, -101, 5816, 0, 0, 0, (9 << 16), bhvGlass),
		TERRAIN(bridge_area_1_collision),
		MACRO_OBJECTS(bridge_area_1_macro_objs),
		STOP_MUSIC(0),
		TERRAIN_TYPE(TERRAIN_STONE),
		/* Fast64 begin persistent block [area commands] */
		/* Fast64 end persistent block [area commands] */
	END_AREA(),
	FREE_LEVEL_POOL(),
	MARIO_POS(0x01, 0, 0, 421, -8230),
	CALL(0, lvl_init_or_update),
	CALL_LOOP(1, lvl_init_or_update),
	CLEAR_LEVEL(),
	SLEEP_BEFORE_EXIT(1),
	EXIT(),
};