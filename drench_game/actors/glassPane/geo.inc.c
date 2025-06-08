#include "src/game/envfx_snow.h"

const GeoLayout glassPane_001_switch_opt1[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_DISPLAY_LIST(LAYER_OPAQUE, glassPane_000_displaylist_001_mesh_layer_5_mat_override_Fast3D_Material_0),
	GEO_CLOSE_NODE(),
	GEO_RETURN(),
};
const GeoLayout glassPane_geo[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_CULLING_RADIUS(600),
		GEO_OPEN_NODE(),
			GEO_SWITCH_CASE(2, geo_switch_anim_state),
			GEO_OPEN_NODE(),
				GEO_NODE_START(),
				GEO_OPEN_NODE(),
					GEO_DISPLAY_LIST(LAYER_TRANSPARENT, glassPane_000_displaylist_001_mesh_layer_5),
				GEO_CLOSE_NODE(),
				GEO_BRANCH(1, glassPane_001_switch_opt1),
			GEO_CLOSE_NODE(),
		GEO_CLOSE_NODE(),
	GEO_CLOSE_NODE(),
	GEO_END(),
};
