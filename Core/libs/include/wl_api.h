#ifndef WL_API_H
#define WL_API_H

#if defined(__APPLE__) && defined(__MACH__)
#include <TargetConditionals.h>
#endif

#ifdef __cplusplus
extern "C" {
#else
typedef short bool;
#endif

#define PASS	0
#define FAIL	1

#define WL_LOG_CURVE_NUM			4
#define WL_MAX_DISPLAY_MSG_CHAR		60
#define WL_MAX_DISPLAY_NODES		10
#define WL_NUMBER_DBG_MSG			12			
#define WL_MAX_NODE_SETTING			2000
#define WL_MAX_ERROR_CNT			10
#define WL_MAX_ERR_MSG_SIZE			200
#define WL_MAX_NODES_FOR_AI			10		// alg output info to AI once per sec. for the top 10 strongest nodes 
#define WL_MIN_POINTS_IN_BLOCKED_AREA	3
#define WL_MAX_POINTS_IN_BLOCKED_AREA	10
#define WL_MAX_NUM_BLOBKED_AREA			50
#define WL_MAX_AI_RSSI_NUM				20
#define WL_MAX_SKIP_POWERUP_SEC			5
#define WL_MAX_MISSED_TIME_THR_MS	3000	// in ms of time. If xyz of api_out is continuesly missed for this value, pips_lib will reset aoa tracking alg
#define WL_MAX_NUM_REGION_PER_NODE	3	
#define WL_MAX_REGION_OVERLAP_NODE	25		// 5 meter node distance, 10 meter node rigion, open space: 5 nodes on x * 5 nodes on y => max 25 nodes region overlap
#define WL_WFD_NUM_PREDICT_POINTS	20

#define WL_ZYX		321
#define WL_XYZ		123

#define STANDING			1
#define WALKING				2
#define RECORDED_WALKING	3

#if defined(__GNUC__) || defined(__clang__)
#define DEPRECATED __attribute__((deprecated))
#elif defined(_MSC_VER)
#define DEPRECATED __declspec(deprecated)
#else
#pragma message("WARNING: You need to implement DEPRECATED for this compiler")
#define DEPRECATED
#endif

enum  pips_position
{
	// general
    NO_NODES_ARE_FOUND,
    NOT_ENOUGH_NODES,
    FINDING_POSITION,
	// 4-node car
    DRIVER_SEAT,
    FRONT_PASSENGER,
    BACK_LEFT_PASSENGER,
    BACK_MIDDLE_PASSENGER,
    BACK_RIGHT_PASSENGER,
    OUT_OF_CAR,
	// 2-node car
	BACK_PASSENGER,
	// 1-node car
	PASSENGER,
	// indoor positioning
	INDOOR_1D_MODE,
	INDOOR_2D_MODE,
	INDOOR_3D_MODE,
	INDOOR_4D_MODE,
	// TV positioning
	NO_TV_FOUND,
	AT_TV,
	OUT_OF_TV,
	MAX_POS_NUMBER
};

enum  PhoneMovingSpeed
{
	PHONE_SPEED_UNAVAILABLE = -1,	// use PHONE_SPEED_DEFAULT
	PHONE_SPEED_NOT_MOVING = 0,		// target 0.00m/s
	PHONE_SPEED_VERY_SLOW,			// target 0.25m/s
	PHONE_SPEED_SLOW,				// target 0.50m/s
	PHONE_SPEED_MEDIUM,				// target 0.75m/s, DEFAULT
	PHONE_SPEED_FAST,				// target 1.00m/s
	PHONE_SPEED_VERY_FAST			// target 2.00m/s
};

enum  PhoneAmbientLight
{
	PHONE_LIGHT_UNAVAILABLE = -1,
	PHONE_LIGHT_DARK = 0,	
	PHONE_LIGHT_LOW,
	PHONE_LIGHT_MEDIUM,
	PHONE_LIGHT_HIGH
};

enum  PhoneUsageMode
{
	PHONE_USED_IN_HAND = 0,
	PHONE_USED_IN_POCKET = 1	
};

enum EngineTuningMode {
	// ENGINE_TUNE_ALL = -1,
	ENGINE_TUNE_DEFAULT = 0,
	ENGINE_TUNE_LOW_LATENCY = 1,
	ENGINE_TUNE_HIGH_ACCURACY = 2,
	ENGINE_TUNE_HIGHEST_ACCURACY = 3,
	ENGINE_TUNE_size
};

enum WFD_LAG_CNTL_SPEED_T {		// settings to control leg converging speed that how fast the RX blue dot catch up app wfd points moving
								// quicker on speed, faster converge, but may be bigger on drifting
	
	// note: api function requires the continually increased number
	WFD_LAG_CNTL_NORMAL,		// The same speed as no wayfinding
	WFD_LAG_CNTL_FAST,			// RX blue dot catch up wfd points faster than no wayfinding
	WFD_LAG_CNTL_FASTER,		// RX blue dot and wfd point moving in about same speed if RX blue dot not moving to reverse direction
	WFD_LAG_CNTL_FASTEST		// RX blue dot could moving a head of wfd points
};

typedef struct
{
	int left_node_id;		// room_node_id for left board 
	double left_rssi;		// rssi value in dBm, 0 = not valid 
	int right_node_id;		// room_node_id for right board 
	double right_rssi;		// rssi value in dBm, 0 = not valid 
} single_node_heatmap;

typedef struct
{
	double x, y;
} vector_2d;

typedef struct
{
	int distance_ready;		// app measures phone moving distance per sec: 1=new data ready; 0=old data  
	double x_distance;		// app measures phone moving distance on x direction, in last T second period, T=1sec
	double y_distance;		// app measures phone moving distance on y direction, in last T second period, T=1sec
	double z_distance;		// app measures phone moving distance on z direction, in last T second period, T=1sec
	double T_distance;		// the time period (in ms) that app measures xyz distance
} sensor;

typedef struct
{
    int cmd1;
    int cmd2;
    int cmd3;
    int cmd4;			// 1=UE_SPEED_STANDING, 2=UE_SPEED_WALKING,
    double para1;
    double para2;
    double para3;
    double para4;
} pips_api_cmd;

typedef struct
{
	unsigned int cust_id;			// customer id, range 0x0000-0xFFFF (16-bit, 0-65535). 
	unsigned int app_id;			// app id, range 0x00-0xFF (8-bit, 0-255). for indoor node, shopping cart node, car node etc
	unsigned int loc_id;			// loc id, range 0x00-0xFF (8-bit, 0-255). for country, state, city, campus etc
	unsigned int bld_id;			// bld id, range 0x00-0xFF (8-bit, 0-255). for different building in the same city or campus
	unsigned int room_id;			// room id, range 0x00-0xFF (8-bit, 0-255). for rooms in a building, or aisle/section in a store
	unsigned int node_id;			// node id, range 0x00-0xFF (8-bit, 0-255). for node in above defined id

	int num_region;
	double x, x_min[WL_MAX_NUM_REGION_PER_NODE], x_max[WL_MAX_NUM_REGION_PER_NODE];	// measured node location and it's walkable range on x-aixs, in meter
	double y, y_min[WL_MAX_NUM_REGION_PER_NODE], y_max[WL_MAX_NUM_REGION_PER_NODE];	// measured node location and it's walkable range on y-aixs, in meter
	double z, z_min, z_max;			// measured node location and it's walkable range on z-aixs, in meter
	double pathloss;				// path loss, in dB

	double xa, ya, za;				// node placement orientation, in degree
	int rotation_order;				// must be either WL_ZYX, or WL_XYZ, 0 for default (N/A)
	int gen;						// 1=gen1; 2=gen2

} pips_node_setting;

typedef struct
{
	unsigned int mac_addr[3];	// MAC addr 6 bytes (3 words): upper word - mac_addr[0], middle word - mac_addr[1];
	unsigned int node_id;		// nodeid = xxxyy, where xx=0-255 for aisle/area of a store; yy=0-99 for node of the aisle
	double nd_x, nd_y, nd_z;
	double xa, ya, za;			// SIRL board orienatation
	int rotation_order;

	int data_ready;				// 1=the data is used for pos calculation, 0=the data is not be used for generating pos estimation
	double ha[2], va[2];		// for ant0 and ant1
	double rssi0;				// dB for ant0
	double rssi1;				// dB for ant1
	double rssi_final;			// dB
	double r;
	double w;					// confident level;
} pips_ai_node_info;

typedef struct
{
	unsigned int room_id;
	unsigned int node_id;
	int rssi_cnt[2];						// current output size of arra rssi[2][rssi_cnt] 
	double rssi[2][WL_MAX_AI_RSSI_NUM];		// received rssi arry in current report, rssi[ant][rssi_cnt]
	double target_rssi;						
	double est_rssi;
	double ha[2], va[2];					// horizontal_angle[ant], vertical_angle[ant]
	double x_speed;							// in m/s
	double y_speed;							// in m/s
} pips_ai_rssi;

typedef struct
{
	vector_2d points[WL_MAX_POINTS_IN_BLOCKED_AREA];		
	int numOfPoints;
	int room_id_left;			// now blocked area includes shelf between 2 aisles (2 roome_id)
	int room_id_right;			// if a blocked area only impact 1 aisles, set the room_id_left and room_id_right to be same.
} pips_blocked_area_info;		// max 20 blocked area per store. alg only takes first 20 blocked areas from PIPS_addBlockedArea()

typedef struct
{
	int room_node_id;			// room_node_id = room_id * 100 + node_id
	double est_tx_power;		// real-time estimated node TX power at 1m, in dBm
	double est_pow_offset;		// the node power offset to average tx power of all nodes in the store. avr_tx_power = est_tx_power + est_powe_offset
	int used_cnt;				// the number of times the node is used for calulating succesful positions.

} pips_node_status_report;

typedef struct
{
	char ver[30];			// version number
    int new_pos_ready;		// 1 = current output data is new measured data; 0 = old data
    double x;				// %3.1f in meter
    double y;				// %3.1f in meter
    double z;				// %3.1f in meter
    double r;               // for out of car, and indoor 1 node: distance in meter,
	double w;				// confident level of the xyz: 0-100
	double x_speed_dx;		// x_spped by measured x movement,  in meter per second
	double x_speed_dn;		// x_spped by detected node change, in meter per second
	double x_speed_cmb;		// x_spped by combined estimation,  in meter per second
	double y_speed_dy;		// y_spped by measured x movement,  in meter per second
	double y_speed_dn;		// y_spped by detected node change, in meter per second
	double y_speed_cmb;		// y_spped by combined estimation,  in meter per second
    enum pips_position pos_id;
	char pos_name[WL_MAX_DISPLAY_MSG_CHAR];
    
    int node[WL_MAX_DISPLAY_NODES];
    double rssi[WL_MAX_DISPLAY_NODES];	// %3.1f in dBm
    
    int new_curve_ready;
    int curve_id[WL_LOG_CURVE_NUM];		//reang: 0 - (WL_LOG_CURVE_NUM-1); -1=NA
    int curve_x[WL_LOG_CURVE_NUM];
    int curve_y[WL_LOG_CURVE_NUM];
    
    int new_msg_ready;
    char dbg_msg[WL_NUMBER_DBG_MSG][WL_MAX_DISPLAY_MSG_CHAR];
    char dbg_msg_out[WL_NUMBER_DBG_MSG * WL_MAX_DISPLAY_MSG_CHAR];

	int err_cnt;
	int eror_code[WL_MAX_ERROR_CNT];
	char err_msg[WL_MAX_ERR_MSG_SIZE];
    
    int new_comments_ready;
    char cmt_msg[WL_MAX_DISPLAY_MSG_CHAR];

	// new output for AI
	int used_num_of_nodes;		// <=WL_MAX_NODES_FOR_AI
	pips_ai_node_info ai_node[WL_MAX_NODES_FOR_AI];		// current ai_node[] output array size = used_num_of_nodes
	pips_ai_rssi ai_rssi[WL_MAX_NODES_FOR_AI];			// current ai_rssi[] output array size = used_num_of_nodes

	unsigned int frame_id;			// current frame id; each measurement (WL_MEASURE_WIN_MS) is a frame; 
	int pos_credit;					// number of continues xy postions that pass confident metric threshold.

	enum PhoneMovingSpeed ue_speed_by_ble;		// phone moving spped detected by BLE based alg
	double ue_speed_final;			// final phone speed combined by BLE and app 2 alg, in meter per second

	pips_node_setting node_max_rssi;	// report detected max rssi node to app. App can reconfigure map and node_setting table based on the customer CRN id
    
	single_node_heatmap node_heatmap;	// report current x location for a single node heatmap application
} pips_api_out;


// interface for app passing cmd to api:
const char * PIPS_getVersion();

int PIPS_setLoopNumber(int loop);		// loop=0: api default, loop = 1-4  
int PIPS_setDelayCtrl(int delay);		// delay = 0: api default, delay = 1-5

DEPRECATED int PIPS_set_loop_number(int loop);		// loop=0: api default, loop = 1-4  
DEPRECATED int PIPS_set_delay_ctrl(int delay);		// delay = 0: api default, delay = 1-5

#if TARGET_OS_IPHONE != 1
int PIPS_addNodeSetting(pips_node_setting& node);
int PIPS_addBlockedArea(pips_blocked_area_info& area);
#else
int PIPS_addNodeSettingPtr(pips_node_setting *node_ptr);
#endif
    
const pips_node_setting PIPS_getNodeSetting(int node_id);
int PIPS_addNodeRegion(int node_id, int x_min, int x_max, int y_min, int y_max);
void PIPS_clearNodeSetting();
void PIPS_clearBlockedAreas();

int PIPS_rx_init(pips_api_out *api_out);
int PIPS_rx_adv_data(const char *adv_data, int len, int rssi, long int time_ms, const char *msg, pips_api_out *api_out);

DEPRECATED int PIPS_api_cmd(pips_api_cmd *api_cmd);
int PIPS_getApiCommand(pips_api_cmd *api_cmd);

#if TARGET_OS_IPHONE != 1
int PIPS_configCasing(const char* json);
int PIPS_configPlacement(const char* json);


int PIPS_setPhoneSpeed(PhoneMovingSpeed speed_level, double change_direction = 0); // change_direction= -180 to 180 deg
int PIPS_setAmbientLight(PhoneAmbientLight light_level);
int PIPS_setPhoneUsageMode(PhoneUsageMode mode);

#endif

int PIPS_setZBoundary(double z_bondary_low, double z_boundary_high);	// the default Z boundary for store is (0.6, 1.6) meter
int PIPS_get_single_node_status(int room_node_id, pips_node_status_report *node_status);
int PIPS_get_all_node_status(pips_node_status_report *node_status[], int *num_nodes);  // returned number_node = app configured num of nodes

int PIPS_1d_heatmap_post_proc(double* rssi_left, double* rssi_right, double* x_out, int len);
int PIPS_setDefaultZ(double z);
int PIPS_setPhoneID(int phone_id);
void PIPS_setUeTxIntervalMSec(double ue_tx_ms);
void PIPS_setTimingScaleUePktPerMeasureWinTag(double pkts);
void PIPS_setNoOutputWhileSearching(bool cmd);
void PIPS_setEnableDriftFilter(bool cmd);

#if TARGET_OS_IPHONE != 1
int PIPS_setEngineMode(EngineTuningMode mode);

int PIPS_setSkipPowerUpSec(int skip_power_up_sec, EngineTuningMode mode = ENGINE_TUNE_DEFAULT);
int PIPS_setSpeedScale(double speed_scale, EngineTuningMode mode = ENGINE_TUNE_DEFAULT);
int PIPS_setMAXMissedTimeMs(unsigned int timeout_thr, EngineTuningMode mode = ENGINE_TUNE_DEFAULT);
int PIPS_setboundaryMargin(double margin, EngineTuningMode mode = ENGINE_TUNE_DEFAULT);
int PIPS_setNodeTrackingLockStartWin(int lock_start_win, EngineTuningMode mode = ENGINE_TUNE_DEFAULT);
int PIPS_setNodeTrackingLockResetWin(int lock_reset_win, EngineTuningMode mode = ENGINE_TUNE_DEFAULT);

int PIPS_setTopRssiNodeRangeSearch(int top_rssi_node_range_search, EngineTuningMode mode = ENGINE_TUNE_DEFAULT);
int PIPS_setTopRssiNodeRangeTracking(int top_rssi_node_range_tracking, EngineTuningMode mode = ENGINE_TUNE_DEFAULT);
int PIPS_setMaxTrackingNodes(int max_tracking_nodes, EngineTuningMode mode = ENGINE_TUNE_DEFAULT);
int PIPS_setMaxXyToCrtndDist(double max_xy_to_crtnd_dist, EngineTuningMode mode = ENGINE_TUNE_DEFAULT);
int PIPS_setMaxXyToTrkndDist(double max_xy_to_trknd_dist, EngineTuningMode mode = ENGINE_TUNE_DEFAULT);
int PIPS_setMaxXyToCrtndDistLockSwitchRegion(double max_xy_to_crtnd_dist_lock_switch_region, EngineTuningMode mode = ENGINE_TUNE_DEFAULT);
int PIPS_setMaxXyToTrkndDistLockSwitchRegion(double max_xy_to_trknd_dist_lock_switch_region, EngineTuningMode mode = ENGINE_TUNE_DEFAULT);
int PIPS_setMaxXyToCrtndDistSameAisle(double max_xy_to_crtnd_dist_same_aisle, EngineTuningMode mode = ENGINE_TUNE_DEFAULT);
int PIPS_setMaxXyToTrkndDistSameAisle(double max_xy_to_trknd_dist_same_aisle, EngineTuningMode mode = ENGINE_TUNE_DEFAULT);
int PIPS_setNewAisleDetThr(int new_aisle_det_thr, EngineTuningMode mode = ENGINE_TUNE_DEFAULT);
int PIPS_setNewRegionDistWeight(double new_region_dist_weight, EngineTuningMode mode = ENGINE_TUNE_DEFAULT);
int PIPS_setNewRegionBrdMargin(double new_region_brd_margin, EngineTuningMode mode = ENGINE_TUNE_DEFAULT);
int PIPS_setMaxMrcDistWeight(double max_mrc_dist_weight, EngineTuningMode mode = ENGINE_TUNE_DEFAULT);
int PIPS_setMaxMrcDistFor0Wt(double max_mrc_dist_for_0_wt, EngineTuningMode mode = ENGINE_TUNE_DEFAULT);
int PIPS_setMaxDistToKeepTrackingNode(double max_dist_to_keep_tracking_node, EngineTuningMode mode = ENGINE_TUNE_DEFAULT);
#endif

int PIPS_setWayFindingPredictPoints(int num_points, double *point_array_x, double *point_array_y);
void PIPS_stopWayFiding();
int PIPS_setWayFindingLagCntlSpeed(enum WFD_LAG_CNTL_SPEED_T lag_control_speed);



#ifdef __cplusplus
}
#endif

#endif
