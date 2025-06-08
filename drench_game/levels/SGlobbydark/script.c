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
#include "levels/SGlobbydark/header.h"

/* Fast64 begin persistent block [scripts] */
/* Fast64 end persistent block [scripts] */

const LevelScript level_SGlobbydark_entry[] = {
	INIT_LEVEL(),
	LOAD_MIO0(0x7, _SGlobbydark_segment_7SegmentRomStart, _SGlobbydark_segment_7SegmentRomEnd), 
	ALLOC_LEVEL_POOL(),
	MARIO(MODEL_MARIO, 0x00000001, bhvMario), 
	/* Fast64 begin persistent block [level commands] */
	/* Fast64 end persistent block [level commands] */

	AREA(1, SGlobbydark_area_1),
		WARP_NODE(0x0A, LEVEL_BOB, 0x01, 0x0A, WARP_NO_CHECKPOINT),
		WARP_NODE(0xF0, LEVEL_CASTLE, 0x01, 0x32, WARP_NO_CHECKPOINT),
		WARP_NODE(0xF1, LEVEL_CASTLE, 0x01, 0x64, WARP_NO_CHECKPOINT),
		MARIO_POS(0x01, 0, 0, 80, 0),
		OBJECT(MODEL_NONE, 262, -985, -209, 0, 0, 0, (300 << 16), bhvPoleGrabbing),
		OBJECT(MODEL_NONE, 902, -247, -1109, 0, 0, 0, (250 << 16), bhvPoleGrabbing),
		OBJECT(MODEL_NONE, 1883, 25, -448, 0, 0, 0, (250 << 16), bhvPoleGrabbing),
		OBJECT(MODEL_NONE, 1576, -390, 1699, 0, 0, 0, (250 << 16), bhvPoleGrabbing),
		OBJECT(MODEL_NONE, 2146, -13, 2725, 0, 0, 0, (250 << 16), bhvPoleGrabbing),
		OBJECT(MODEL_NONE, 622, -369, 1985, 0, 0, 0, (250 << 16), bhvPoleGrabbing),
		OBJECT(MODEL_NONE, 313, 85, 3367, 0, 0, 0, (250 << 16), bhvPoleGrabbing),
		OBJECT(MODEL_NONE, -902, -13, 2474, 0, 0, 0, (250 << 16), bhvPoleGrabbing),
		OBJECT(MODEL_NONE, -1668, 27, 1460, 0, 0, 0, (250 << 16), bhvPoleGrabbing),
		OBJECT(MODEL_NONE, -2146, -310, 309, 0, 0, 0, (250 << 16), bhvPoleGrabbing),
		OBJECT(MODEL_NONE, -1230, -267, -209, 0, 0, 0, (250 << 16), bhvPoleGrabbing),
		OBJECT(MODEL_NONE, -622, -74, 344, 0, 0, 0, (250 << 16), bhvPoleGrabbing),
		OBJECT(MODEL_NONE, -2427, -247, 1891, 0, 0, 0, (250 << 16), bhvPoleGrabbing),
		OBJECT(MODEL_NONE, -2146, -247, 2940, 0, 0, 0, (250 << 16), bhvPoleGrabbing),
		OBJECT(MODEL_NONE, 380, 27, 1460, 0, 0, 0, (250 << 16), bhvPoleGrabbing),
		OBJECT(MODEL_NONE, 863, 1426, -3765, 0, 0, 0, 0x00000000, bhvScreen),
		OBJECT(MODEL_NONE, 0, 80, 0, 0, 0, 0, (0x0A << 16), bhvSpinAirborneWarp),
		TERRAIN(SGlobbydark_area_1_collision),
		MACRO_OBJECTS(SGlobbydark_area_1_macro_objs),
		STOP_MUSIC(0),
		TERRAIN_TYPE(TERRAIN_STONE),
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