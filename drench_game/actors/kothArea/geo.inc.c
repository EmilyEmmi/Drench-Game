#include "src/game/envfx_snow.h"

const GeoLayout kothArea_001_switch_opt1[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_DISPLAY_LIST(LAYER_ALPHA, kothArea_000_displaylist_001_mesh_layer_4_mat_override_green_0),
	GEO_CLOSE_NODE(),
	GEO_RETURN(),
};
const GeoLayout kothArea_geo[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_CULLING_RADIUS(600),
		GEO_OPEN_NODE(),
			GEO_SWITCH_CASE(2, geo_switch_anim_state),
			GEO_OPEN_NODE(),
				GEO_NODE_START(),
				GEO_OPEN_NODE(),
					GEO_DISPLAY_LIST(LAYER_ALPHA, kothArea_000_displaylist_001_mesh_layer_4),
				GEO_CLOSE_NODE(),
				GEO_BRANCH(1, kothArea_001_switch_opt1),
			GEO_CLOSE_NODE(),
		GEO_CLOSE_NODE(),
		GEO_DISPLAY_LIST(LAYER_ALPHA, kothArea_material_revert_render_settings),
	GEO_CLOSE_NODE(),
	GEO_END(),
};
