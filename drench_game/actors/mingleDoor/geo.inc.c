#include "src/game/envfx_snow.h"

const GeoLayout mingleDoor_001_switch_opt1[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_DISPLAY_LIST(LAYER_ALPHA, mingleDoor_000_displaylist_001_mesh_layer_4_mat_override_porte1_0),
	GEO_CLOSE_NODE(),
	GEO_RETURN(),
};
const GeoLayout mingleDoor_001_switch_opt2[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_DISPLAY_LIST(LAYER_ALPHA, mingleDoor_000_displaylist_001_mesh_layer_4_mat_override_porte2_1),
	GEO_CLOSE_NODE(),
	GEO_RETURN(),
};
const GeoLayout mingleDoor_001_switch_opt3[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_DISPLAY_LIST(LAYER_ALPHA, mingleDoor_000_displaylist_001_mesh_layer_4_mat_override_porte3_2),
	GEO_CLOSE_NODE(),
	GEO_RETURN(),
};
const GeoLayout mingleDoor_001_switch_opt4[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_DISPLAY_LIST(LAYER_ALPHA, mingleDoor_000_displaylist_001_mesh_layer_4_mat_override_porte4_3),
	GEO_CLOSE_NODE(),
	GEO_RETURN(),
};
const GeoLayout mingleDoor_001_switch_opt5[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_DISPLAY_LIST(LAYER_ALPHA, mingleDoor_000_displaylist_001_mesh_layer_4_mat_override_porte5_4),
	GEO_CLOSE_NODE(),
	GEO_RETURN(),
};
const GeoLayout mingleDoor_001_switch_opt6[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_DISPLAY_LIST(LAYER_ALPHA, mingleDoor_000_displaylist_001_mesh_layer_4_mat_override_porte6_5),
	GEO_CLOSE_NODE(),
	GEO_RETURN(),
};
const GeoLayout mingleDoor_001_switch_opt7[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_DISPLAY_LIST(LAYER_ALPHA, mingleDoor_000_displaylist_001_mesh_layer_4_mat_override_porte7_6),
	GEO_CLOSE_NODE(),
	GEO_RETURN(),
};
const GeoLayout mingleDoor_geo[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_CULLING_RADIUS(600),
		GEO_OPEN_NODE(),
			GEO_SWITCH_CASE(8, geo_switch_anim_state),
			GEO_OPEN_NODE(),
				GEO_NODE_START(),
				GEO_OPEN_NODE(),
					GEO_DISPLAY_LIST(LAYER_ALPHA, mingleDoor_000_displaylist_001_mesh_layer_4),
				GEO_CLOSE_NODE(),
				GEO_BRANCH(1, mingleDoor_001_switch_opt1),
				GEO_BRANCH(1, mingleDoor_001_switch_opt2),
				GEO_BRANCH(1, mingleDoor_001_switch_opt3),
				GEO_BRANCH(1, mingleDoor_001_switch_opt4),
				GEO_BRANCH(1, mingleDoor_001_switch_opt5),
				GEO_BRANCH(1, mingleDoor_001_switch_opt6),
				GEO_BRANCH(1, mingleDoor_001_switch_opt7),
			GEO_CLOSE_NODE(),
		GEO_CLOSE_NODE(),
	GEO_CLOSE_NODE(),
	GEO_END(),
};
