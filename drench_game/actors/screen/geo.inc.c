#include "src/game/envfx_snow.h"

const GeoLayout screen_geo[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_DISPLAY_LIST(LAYER_OPAQUE, screen_Level_Mesh_002_mesh_layer_1),
	GEO_CLOSE_NODE(),
	GEO_END(),
};
