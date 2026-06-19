// Copyright 2024 Altera Corporation.
//
// This software and the related documents are Altera copyrighted materials,
// and your use of them is governed by the express license under which they
// were provided to you ("License"). Unless the License provides otherwise,
// you may not use, modify, copy, publish, distribute, disclose or transmit
// this software or the related documents without Altera's prior written
// permission.
//
// This software and the related documents are provided as is, with no express
// or implied warranties, other than those that are expressly stated in the
// License.

/*
  This is a virtual class of the aux depthwise config struct
  This struct is identical to the struct in the interface but since the interface struct cannot be
  used, this virtual class contains it
*/

import dla_common_pkg::bits_for_2;

virtual class aux_depthwise_config_vc #(
  dla_aux_depthwise_pkg::aux_special_params_t special_params,
  dla_interface_pkg::aux_data_pack_params_t data_pack_params
);
// ------------------------------ START EDITING ------------------------------
localparam TILE_COUNT                 = data_pack_params.GROUP_SIZE * data_pack_params.GROUP_NUM;
localparam CONFIG_ID_BITS             = special_params.CONFIG_ID_WIDTH                  ;
localparam WINDOW_BITS_VERTICAL       = $clog2(special_params.MAX_WINDOW_HEIGHT     + 1);
localparam WINDOW_BITS_HORIZONTAL     = $clog2(special_params.MAX_WINDOW_WIDTH      + 1);
localparam STRIDE_BITS_VERTICAL       = $clog2(special_params.MAX_STRIDE_VERTICAL   + 1);
localparam STRIDE_BITS_HORIZONTAL     = $clog2(special_params.MAX_STRIDE_HORIZONTAL + 1);
localparam TILE_BITS_VERTICAL         = $clog2(special_params.MAX_TILE_HEIGHT       + 1);
localparam TILE_BITS_HORIZONTAL       = $clog2(special_params.MAX_TILE_WIDTH        + 1);
localparam TILE_BITS_DEPTHWISE        = $clog2(special_params.MAX_TILE_CHANNELS     + 1);
localparam VERTICAL_DILATION_BITS_DEPTHWISE    = $clog2(special_params.MAX_DILATION_VERTICAL     + 1);
localparam HORIZONTAL_DILATION_BITS_DEPTHWISE    = $clog2(special_params.MAX_DILATION_HORIZONTAL     + 1);
localparam ELEMENT_BITS               = data_pack_params.ELEMENT_BITS                   ;
localparam MAX_WINDOW_WIDTH = special_params.MAX_WINDOW_WIDTH;
localparam MAX_WINDOW_HEIGHT = special_params.MAX_WINDOW_HEIGHT;
localparam MAX_VERTICAL_PAD = (special_params.MAX_WINDOW_HEIGHT-1) * (special_params.MAX_DILATION_VERTICAL);
localparam MAX_HORIZONTAL_PAD = (special_params.MAX_WINDOW_WIDTH-1) * (special_params.MAX_DILATION_HORIZONTAL);
// ------------------------------  END EDITING  ------------------------------

typedef struct packed {
// ------------------------------ START EDITING ------------------------------
    logic                  [ bits_for_2(-1,special_params.MAX_TILE_CHANNELS-2)     -1:0] out_channels_minus_2;
    logic                  [ bits_for_2(-1,special_params.MAX_TILE_HEIGHT-2)       -1:0] out_height_minus_2;
    logic                  [ bits_for_2(-1,special_params.MAX_TILE_WIDTH-2)        -1:0] out_width_minus_2;
    logic                  [ bits_for_2(-2,MAX_HORIZONTAL_PAD-2)                   -1:0] pad_zone_horizontal_upper_bound_counter_minus_2;
    logic                  [ bits_for_2(-2,MAX_VERTICAL_PAD-2)                     -1:0] pad_zone_vertical_upper_bound_counter_minus_2;
    logic [TILE_COUNT-1:0][MAX_WINDOW_WIDTH-1:0] [
                    bits_for_2(-2, MAX_WINDOW_WIDTH+special_params.MAX_TILE_WIDTH-2) -1:0] horiz_pad_zero_upper_bound_counter_minus_2;
    logic [TILE_COUNT-1:0][MAX_WINDOW_WIDTH-1:0] [
                    bits_for_2(-2, MAX_WINDOW_WIDTH+special_params.MAX_TILE_WIDTH-2) -1:0] horiz_pad_zero_lower_bound_counter_minus_2;
    logic [TILE_COUNT-1:0][MAX_WINDOW_HEIGHT-1:0] [
                      bits_for_2(-2, (MAX_WINDOW_HEIGHT*special_params.MAX_DILATION_VERTICAL)+special_params.MAX_TILE_HEIGHT-2) -1:0] vert_pad_zero_upper_bound_counter_minus_2;
    logic [TILE_COUNT-1:0][MAX_WINDOW_HEIGHT-1:0] [
                      bits_for_2(-2, (MAX_WINDOW_HEIGHT*special_params.MAX_DILATION_VERTICAL)+special_params.MAX_TILE_HEIGHT-2) -1:0] vert_pad_zero_lower_bound_counter_minus_2;
    logic                  [ bits_for_2(-2,special_params.MAX_TILE_WIDTH*special_params.MAX_TILE_HEIGHT-2)
                                                                                    -1:0] line_buff_flush_minus_2;
    logic                  [ bits_for_2(-2,special_params.MAX_TILE_WIDTH*special_params.MAX_DILATION_VERTICAL-2)        -1:0] line_buff_wait_fill_minus_2;
    logic                  [
                              bits_for_2(-2,special_params.MAX_WINDOW_WIDTH * special_params.MAX_WINDOW_HEIGHT * special_params.MAX_TILE_WIDTH - 2)
                                                                                    -1:0] feature_almost_ready_minus_2;
    logic                  [ bits_for_2(-1,special_params.MAX_TILE_CHANNELS-2)     -1:0] tile_channels_over_native_vector_size_minus_2;
    logic                  [ bits_for_2(-1,special_params.MAX_STRIDE_VERTICAL-2)   -1:0] stride_vertical_minus_2;
    logic                  [ bits_for_2(-1,MAX_VERTICAL_PAD + 1-2)                 -1:0] eff_window_height_minus_2;
    logic                  [ bits_for_2(-1,special_params.MAX_WINDOW_HEIGHT-2)     -1:0] window_height_minus_2;
    logic                  [ bits_for_2(-1,special_params.MAX_TILE_HEIGHT-2)       -1:0] tile_height_minus_2;
    logic                  [ bits_for_2(-1,special_params.MAX_STRIDE_HORIZONTAL-2) -1:0] stride_horizontal_minus_2;
    logic                  [ bits_for_2(-1,MAX_HORIZONTAL_PAD + 1-2)               -1:0] eff_window_width_minus_2;
    logic                  [ bits_for_2(-1,special_params.MAX_WINDOW_WIDTH-2)      -1:0] window_width_minus_2;
    logic                  [ bits_for_2(-1,special_params.MAX_TILE_WIDTH-2)        -1:0] tile_width_minus_2;
    logic                                                   padding_ignore       ;
    logic                  [                       1:0]     padding_mode         ;
    logic                  [          ELEMENT_BITS-1:0]     padding_constant     ;
    logic                  [  HORIZONTAL_DILATION_BITS_DEPTHWISE-1:0]  dilation_horizontal  ;
    logic                  [  VERTICAL_DILATION_BITS_DEPTHWISE-1:0]  dilation_vertical    ;
    logic [TILE_COUNT-1:0] [  TILE_BITS_HORIZONTAL-1:0]     tile_horizontal_end  ;
    logic [TILE_COUNT-1:0] [  TILE_BITS_HORIZONTAL-1:0]     tile_horizontal_start;
    logic [TILE_COUNT-1:0] [    TILE_BITS_VERTICAL-1:0]     tile_vertical_end    ;
    logic [TILE_COUNT-1:0] [    TILE_BITS_VERTICAL-1:0]     tile_vertical_start  ;
    logic                  [   TILE_BITS_DEPTHWISE-1:0]     tile_channels        ;
    logic                  [  TILE_BITS_HORIZONTAL-1:0]     tile_width           ;
    logic                  [    TILE_BITS_VERTICAL-1:0]     tile_height          ;
    logic                  [STRIDE_BITS_HORIZONTAL-1:0]     stride_horizontal    ;
    logic                  [  STRIDE_BITS_VERTICAL-1:0]     stride_vertical      ;
    logic                  [WINDOW_BITS_HORIZONTAL-1:0]     window_width         ;
    logic                  [  WINDOW_BITS_VERTICAL-1:0]     window_height        ;
    logic                  [        CONFIG_ID_BITS-1:0]     config_id            ;
// ------------------------------  END EDITING  ------------------------------
  } config_t;

static function automatic string to_string(input config_t c);
  string s = "";
  string t;
  t = {"  out_channels_minus_2                  = ", $sformatf("%d",c.out_channels_minus_2                  ), "\n"}; s = {s, t};
  t = {"  out_height_minus_2              = ", $sformatf("%d",c.out_height_minus_2              ), "\n"}; s = {s, t};
  t = {"  out_width_minus_2              = ", $sformatf("%d",c.out_width_minus_2              ), "\n"}; s = {s, t};
  t = {"  pad_zone_horizontal_upper_bound_counter_minus_2                = ", $sformatf("%d",c.pad_zone_horizontal_upper_bound_counter_minus_2                ), "\n"}; s = {s, t};
  t = {"  pad_zone_vertical_upper_bound_counter_minus_2      = ", $sformatf("%d",c.pad_zone_vertical_upper_bound_counter_minus_2      ), "\n"}; s = {s, t};
  t = {"  line_buff_flush_minus_2                = ", $sformatf("%d",c.line_buff_flush_minus_2                ), "\n"}; s = {s, t};
  t = {"  line_buff_wait_fill_minus_2           = ", $sformatf("%d",c.line_buff_wait_fill_minus_2           ), "\n"}; s = {s, t};
  t = {"  feature_almost_ready_minus_2         = ", $sformatf("%d",c.feature_almost_ready_minus_2         ), "\n"}; s = {s, t};
  t = {"  tile_channels_over_native_vector_size_minus_2        = ", $sformatf("%d",c.tile_channels_over_native_vector_size_minus_2        ), "\n"}; s = {s, t};
  t = {"  stride_vertical_minus_2       = ", $sformatf("%d",c.stride_vertical_minus_2       ), "\n"}; s = {s, t};
  t = {"  window_height_minus_2        = ", $sformatf("%d",c.window_height_minus_2        ), "\n"}; s = {s, t};
  t = {"  eff_window_height_minus_2        = ", $sformatf("%d",c.eff_window_height_minus_2        ), "\n"}; s = {s, t};
  t = {"  tile_height_minus_2       = ", $sformatf("%d",c.tile_height_minus_2       ), "\n"}; s = {s, t};
  t = {"  stride_horizontal_minus_2      = ", $sformatf("%d",c.stride_horizontal_minus_2      ), "\n"}; s = {s, t};
  t = {"  window_width_minus_2       = ", $sformatf("%d",c.window_width_minus_2       ), "\n"}; s = {s, t};
  t = {"  eff_window_width_minus_2       = ", $sformatf("%d",c.eff_window_width_minus_2       ), "\n"}; s = {s, t};
  t = {"  tile_width_minus_2        = ", $sformatf("%d",c.tile_width_minus_2        ), "\n"}; s = {s, t};
  t = {"  padding_ignore       = ", $sformatf("%d",c.padding_ignore       ), "\n"}; s = {s, t};
  t = {"  padding_mode        = ", $sformatf("%d",c.padding_mode        ), "\n"}; s = {s, t};
  t = {"  padding_constant      = ", $sformatf("%d",c.padding_constant      ), "\n"}; s = {s, t};
  t = {"  dilation_horizontal                = ", $sformatf("%d",c.dilation_horizontal                ), "\n"}; s = {s, t};
  t = {"  dilation_vertical                = ", $sformatf("%d",c.dilation_vertical                ), "\n"}; s = {s, t};
  t = {"  tile_channels            = ", $sformatf("%d",c.tile_channels            ), "\n"}; s = {s, t};
  t = {"  tile_width                = ", $sformatf("%d",c.tile_width                ), "\n"}; s = {s, t};
  t = {"  tile_height       = ", $sformatf("%d",c.tile_height       ), "\n"}; s = {s, t};
  t = {"  stride_horizontal                = ", $sformatf("%d",c.stride_horizontal                ), "\n"}; s = {s, t};
  t = {"  stride_vertical       = ", $sformatf("%d",c.stride_vertical       ), "\n"}; s = {s, t};
  t = {"  window_width       = ", $sformatf("%d",c.window_width       ), "\n"}; s = {s, t};
  t = {"  window_height      = ", $sformatf("%d",c.window_height      ), "\n"}; s = {s, t};
  t = {"  config_id      = ", $sformatf("%d",c.config_id      ), "\n"}; s = {s, t};

  for (int i = 0; i < TILE_COUNT; i++) begin
    for (int j = 0; j < MAX_WINDOW_WIDTH; j++) begin
      t = {"  horiz_pad_zero_upper_bound_counter_minus_2[", $sformatf("%d",i), "]", $sformatf("%d",j), "]= ", $sformatf("%d",c.horiz_pad_zero_upper_bound_counter_minus_2[i][j]), "\n"}; s = {s, t};
    end
  end

  for (int i = 0; i < TILE_COUNT; i++) begin
    for (int j = 0; j < MAX_WINDOW_WIDTH; j++) begin
      t = {"  horiz_pad_zero_lower_bound_counter_minus_2[", $sformatf("%d",i), "]", $sformatf("%d",j), "]= ", $sformatf("%d",c.horiz_pad_zero_lower_bound_counter_minus_2[i][j]), "\n"}; s = {s, t};
    end
  end

  for (int i = 0; i < TILE_COUNT; i++) begin
    for (int j = 0; j < MAX_WINDOW_HEIGHT; j++) begin
      t = {"  vert_pad_zero_upper_bound_counter_minus_2[",$sformatf("%d",i), "]", $sformatf("%d",j), "]= ", $sformatf("%d",c.vert_pad_zero_upper_bound_counter_minus_2[i][j]), "\n"}; s = {s, t};
    end
  end

  for (int i = 0; i < TILE_COUNT; i++) begin
    for (int j = 0; j < MAX_WINDOW_HEIGHT; j++) begin
      t = {"  vert_pad_zero_lower_bound_counter_minus_2[", $sformatf("%d",i), "]", $sformatf("%d",j), "]= ", $sformatf("%d",c.vert_pad_zero_lower_bound_counter_minus_2[i][j]), "\n"}; s = {s, t};
    end
  end

  for (int j = 0; j < TILE_COUNT; j++) begin
    t = {"  tile_horizontal_end[", $sformatf("%d",j), "] = ", $sformatf("%d",c.tile_horizontal_end[j]), "\n"}; s = {s, t};
  end

  for (int j = 0; j < TILE_COUNT; j++) begin
    t = {"  tile_horizontal_start[", $sformatf("%d",j), "] = ", $sformatf("%d",c.tile_horizontal_start[j]), "\n"}; s = {s, t};
  end

  for (int j = 0; j < TILE_COUNT; j++) begin
    t = {"  tile_vertical_end[", $sformatf("%d",j), "] = ", $sformatf("%d",c.tile_vertical_end[j]), "\n"}; s = {s, t};
  end

  for (int j = 0; j < TILE_COUNT; j++) begin
    t = {"  tile_vertical_start[", $sformatf("%d",j), "] = ", $sformatf("%d",c.tile_vertical_start[j]), "\n"}; s = {s, t};
  end

  return s;
endfunction


typedef struct {
  int unsigned window_width;
  int unsigned window_height;
  int unsigned stride_horizontal;
  int unsigned stride_vertical;
  int unsigned tile_width;
  int unsigned tile_height;
  int unsigned tile_channels;
  int unsigned dilation_horizontal;
  int unsigned dilation_vertical;
  int unsigned padding_ignore;
  int unsigned padding_mode;
  int unsigned padding_constant;
  int unsigned tile_horizontal_end[TILE_COUNT];
  int unsigned tile_horizontal_start[TILE_COUNT];
  int unsigned tile_vertical_end[TILE_COUNT];
  int unsigned tile_vertical_start[TILE_COUNT];
} high_level_config_t;

// synthesis synthesis_off
static function automatic bit randomize_high_level_config(
  ref high_level_config_t hl
  );

  int unsigned dilation_horizontal;
  int unsigned dilation_vertical;
  int unsigned tile_channels;
  int unsigned tile_width;
  int unsigned tile_height;
  int unsigned stride_horizontal;
  int unsigned stride_vertical;
  int unsigned window_width;
  int unsigned window_height;
  int unsigned tile_horizontal_end[TILE_COUNT];
  int unsigned tile_horizontal_start[TILE_COUNT];
  int unsigned tile_vertical_end[TILE_COUNT];
  int unsigned tile_vertical_start[TILE_COUNT];

  bit success;

  /*
  Summary of randomization goals:
  1. Ensure all dimensions are positive and below the maximum allowed values
  */

  success = std::randomize (
    dilation_horizontal,
    dilation_vertical,
    tile_channels,
    tile_width,
    tile_height,
    stride_horizontal,
    stride_vertical,
    window_width,
    window_height,
    tile_horizontal_end,
    tile_horizontal_start,
    tile_vertical_end,
    tile_vertical_start
  ) with {
    window_width        >= 1;
    window_height       >= 1;
    tile_width          >= 1;
    tile_height         >= 1;
    tile_channels       >= 1;
    stride_horizontal   >= 1;
    stride_vertical     >= 1;
    dilation_horizontal >= 1;
    dilation_vertical   >= 1;
    window_width        <= special_params.MAX_WINDOW_WIDTH;
    window_height       <= special_params.MAX_WINDOW_HEIGHT;
    tile_width          <= special_params.MAX_TILE_WIDTH;
    tile_height         <= special_params.MAX_TILE_HEIGHT;
    tile_channels       <= special_params.MAX_TILE_CHANNELS;
    stride_horizontal   <= special_params.MAX_STRIDE_HORIZONTAL;
    stride_vertical     <= special_params.MAX_STRIDE_VERTICAL;
    dilation_horizontal <= special_params.MAX_DILATION_HORIZONTAL;
    dilation_vertical   <= special_params.MAX_DILATION_VERTICAL;

    // Odd and Equal window sizes are required for the depthwise hardware
    window_width  % 2 == 1;
    window_height % 2 == 1;
    window_height == window_width;

    if (window_width == 1) {
      dilation_horizontal == 1;
      dilation_vertical == 1;
    }

    // window size can not be larger than tile size
    tile_width  >= ((dilation_horizontal * (window_width  - 1)) + 1);
    tile_height >= ((dilation_vertical   * (window_height - 1)) + 1);
    // make sure there are no redundant lines/columns in the tensor when stride > 1
    if (stride_horizontal > 1) {
      (tile_width  - ((dilation_horizontal * (window_width  - 1)) + 1)  + 1) % stride_horizontal == 1;
    }
    if (stride_vertical > 1) {
      (tile_height - ((dilation_vertical   * (window_height - 1)) + 1) + 1) % stride_vertical   == 1;
    }
    // make sure tile channels is an integer multiple of the native vector size
    (tile_channels / data_pack_params.NATIVE_VECTOR_SIZE) * data_pack_params.NATIVE_VECTOR_SIZE == tile_channels;

    // make sure start and end points marking padding locations are within range and end
    // coordinates are bigger than the start coordinates
    foreach (tile_vertical_start[i]) {
      tile_vertical_start  [i] <= tile_vertical_end[i];
      tile_vertical_end    [i] <= tile_height;
      tile_horizontal_start[i] <= tile_horizontal_end[i];
      tile_horizontal_end  [i] <= tile_width;
      // Limitation: Tile start/end configs are generated the same for all lanes. This part might
      //             be expanded in the future if needed.
      tile_vertical_start  [i] == ((dilation_vertical   * (window_height - 1)) + 1) / 2;
      tile_vertical_end    [i] == tile_height - 1 - tile_vertical_start[i];
      tile_horizontal_start[i] == ((dilation_horizontal * (window_width  - 1)) + 1) / 2;
      tile_horizontal_end  [i] == tile_width - 1 - tile_horizontal_start[i];
    }
  };

  hl.window_width             = window_width;
  hl.window_height            = window_height;
  hl.stride_horizontal        = stride_horizontal;
  hl.stride_vertical          = stride_vertical;
  hl.tile_width               = tile_width;
  hl.tile_height              = tile_height;
  hl.tile_channels            = tile_channels;
  hl.dilation_horizontal      = dilation_horizontal;
  hl.dilation_vertical        = dilation_vertical;
  hl.padding_mode             = 0;
  hl.padding_ignore           = 0;
  hl.padding_constant         = 0;
  for (int i=0; i < TILE_COUNT; i++) begin
      hl.tile_vertical_start[i] = tile_vertical_start[i];
      hl.tile_horizontal_start[i] = tile_horizontal_start[i];
      hl.tile_vertical_end[i] = tile_vertical_end[i];
      hl.tile_horizontal_end[i] = tile_horizontal_end[i];
  end

  return success;

endfunction
// synthesis synthesis_on

static function automatic void derive_from_high_level_config(
  ref config_t c,
  input uint32_t k_vector,
  input uint32_t depthwise_k_vector,
  input high_level_config_t hl
  );

  uint32_t VECTOR_RATIO = k_vector/ depthwise_k_vector;
  // Param checks
  // Assertions for stride dimensions
  assert(hl.stride_horizontal > 0) else $fatal("Write/Move horizontal stride expected to be > 0");
  assert(hl.stride_vertical > 0) else $fatal("Write/Move vertical stride expected to be > 0");

  // Assertions for dilation dimensions
  assert(hl.dilation_horizontal > 0) else $fatal("Dilation horizontal expected to be > 0");
  assert(hl.dilation_vertical > 0) else $fatal("Dilation vertical expected to be > 0");

  // Assertions for tile dimensions
  assert(hl.tile_width > 0) else $fatal("Tile width expected to be > 0");
  assert(hl.tile_height > 0) else $fatal("Tile height expected to be > 0");
  assert(hl.tile_channels > 0) else $fatal("Tile channels expected to be > 0");

  // Assertions for window dimensions
  assert(hl.window_width > 0) else $fatal("Window width expected to be > 0");
  assert(hl.window_height > 0) else $fatal("Window height expected to be > 0");

  c.tile_channels  = hl.tile_channels;
  c.tile_width  = hl.tile_width;
  c.tile_height  = hl.tile_height;
  c.stride_horizontal  = hl.stride_horizontal;
  c.stride_vertical  = hl.stride_vertical;
  c.window_width  = hl.window_width;
  c.window_height  = hl.window_height;
  c.padding_ignore = hl.padding_ignore;
  c.padding_mode = hl.padding_mode;
  c.padding_constant = hl.padding_constant;
  c.dilation_horizontal = hl.dilation_horizontal;
  c.dilation_vertical = hl.dilation_vertical;

  for(uint32_t j=0; j < TILE_COUNT; j++) begin
    c.tile_horizontal_end[j]   = hl.tile_horizontal_end[j];
    c.tile_horizontal_start[j] = hl.tile_horizontal_start[j];
    c.tile_vertical_end[j]     = hl.tile_vertical_end[j];
    c.tile_vertical_start[j]   = hl.tile_vertical_start[j];
  end

  c.line_buff_flush_minus_2 = ((hl.window_height == 1) ? 0 :
                               VECTOR_RATIO * hl.tile_width * (hl.tile_height - hl.dilation_vertical)) - 2;
  c.line_buff_wait_fill_minus_2 = ((hl.window_height == 1) ? 0 :
                                   VECTOR_RATIO * hl.tile_width * hl.dilation_vertical) - 2;
  c.feature_almost_ready_minus_2 = ((hl.window_width == 1) ? 0 :
                                   (VECTOR_RATIO * hl.tile_width * ((hl.dilation_vertical * (hl.window_height-1) + 1) - 1)) +
                                   (VECTOR_RATIO * ((hl.dilation_horizontal * (hl.window_width-1) + 1) - 2)) +
                                   (VECTOR_RATIO - 1)) - 2;
  c.tile_channels_over_native_vector_size_minus_2 = hl.tile_channels / k_vector - 2;
  c.stride_vertical_minus_2 = hl.stride_vertical - 2;
  c.stride_horizontal_minus_2 = hl.stride_horizontal - 2;
  c.window_height_minus_2 = hl.window_height - 2;
  c.eff_window_height_minus_2 = (hl.dilation_vertical * (hl.window_height-1) + 1) - 2;
  c.window_width_minus_2 = hl.window_width - 2;
  c.eff_window_width_minus_2 = (hl.dilation_horizontal * (hl.window_width-1) + 1) - 2;
  c.tile_height_minus_2 = hl.tile_height - 2;
  c.tile_width_minus_2 = hl.tile_width - 2;
  c.out_channels_minus_2 = hl.tile_channels / k_vector - 2;
  c.out_height_minus_2 = divCeil((hl.tile_height - (hl.dilation_vertical * (hl.window_height - 1))),hl.stride_vertical) - 2;
  c.out_width_minus_2 = divCeil((hl.tile_width - (hl.dilation_horizontal * (hl.window_width - 1))),hl.stride_horizontal) - 2;
  c.pad_zone_horizontal_upper_bound_counter_minus_2 = ((hl.window_width > 1) ? (hl.dilation_horizontal *
                                                       (hl.window_width-1) + 1 - 1) : 0) - 2;
  c.pad_zone_vertical_upper_bound_counter_minus_2 = ((hl.window_height > 1) ? (hl.dilation_vertical *
                                                     (hl.window_height-1) + 1 - 1) : 0) - 2;
  for (uint32_t i = 0; i < TILE_COUNT; i++) begin
    for (uint32_t j = 0; j < MAX_WINDOW_HEIGHT; j++) begin
      c.vert_pad_zero_lower_bound_counter_minus_2[i][j] =
        (j < (hl.dilation_vertical * (hl.window_height - 1) + 1)) ?
          ((j * hl.dilation_vertical) + hl.tile_vertical_start[i]) - 2 :
          0 - 2;
    end
  end

  for (uint32_t i = 0; i < TILE_COUNT; i++) begin
    for (uint32_t j = 0; j < MAX_WINDOW_HEIGHT; j++) begin
      c.vert_pad_zero_upper_bound_counter_minus_2[i][j] =
        (j < (hl.dilation_vertical * (hl.window_height - 1) + 1)) ?
          ((j * hl.dilation_vertical) + hl.tile_vertical_end[i] + 1) - 2 :
          0 - 2;
    end
  end

  for (uint32_t i = 0; i < TILE_COUNT; i++) begin
    for (uint32_t j = 0; j < MAX_WINDOW_WIDTH; j++) begin
      c.horiz_pad_zero_lower_bound_counter_minus_2[i][j] =
        (j < (hl.dilation_horizontal * (hl.window_width - 1) + 1)) ?
          (j + hl.tile_horizontal_start[i]) - 2 :
          0 - 2;
    end
  end

  for (uint32_t i = 0; i < TILE_COUNT; i++) begin
    for (uint32_t j = 0; j < MAX_WINDOW_WIDTH; j++) begin
      c.horiz_pad_zero_upper_bound_counter_minus_2[i][j] =
        (j < (hl.dilation_horizontal * (hl.window_width - 1) + 1)) ?
          (j + hl.tile_horizontal_end[i] + 1) - 2 :
          0 - 2;
    end
  end



endfunction

static function automatic string hl_to_string(input high_level_config_t hl);
  string s = "";
  string t;

  t = {"window_width            = ", $sformatf("%d", hl.window_width            ), "\n"}; s = {s, t};
  t = {"window_height           = ", $sformatf("%d", hl.window_height           ), "\n"}; s = {s, t};
  t = {"stride_horizontal       = ", $sformatf("%d", hl.stride_horizontal       ), "\n"}; s = {s, t};
  t = {"stride_vertical         = ", $sformatf("%d", hl.stride_vertical         ), "\n"}; s = {s, t};
  t = {"tile_width              = ", $sformatf("%d", hl.tile_width              ), "\n"}; s = {s, t};
  t = {"tile_height             = ", $sformatf("%d", hl.tile_height             ), "\n"}; s = {s, t};
  t = {"tile_channels           = ", $sformatf("%d", hl.tile_channels           ), "\n"}; s = {s, t};
  t = {"dilation_horizontal     = ", $sformatf("%d", hl.dilation_horizontal     ), "\n"}; s = {s, t};
  t = {"dilation_vertical       = ", $sformatf("%d", hl.dilation_vertical       ), "\n"}; s = {s, t};
  t = {"padding_ignore          = ", $sformatf("%d", hl.padding_ignore          ), "\n"}; s = {s, t};
  t = {"padding_mode            = ", $sformatf("%d", hl.padding_mode            ), "\n"}; s = {s, t};
  t = {"padding_constant        = ", $sformatf("%d", hl.padding_constant        ), "\n"}; s = {s, t};

  for (int i = 0; i < TILE_COUNT; i++) begin
    t = {"tile_horizontal_end[", $sformatf("%d", i), "] = ", $sformatf("%d", hl.tile_horizontal_end[i]), "\n"}; s = {s, t};
    t = {"tile_horizontal_start[", $sformatf("%d", i), "] = ", $sformatf("%d", hl.tile_horizontal_start[i]), "\n"}; s = {s, t};
    t = {"tile_vertical_end[", $sformatf("%d", i), "] = ", $sformatf("%d", hl.tile_vertical_end[i]), "\n"}; s = {s, t};
    t = {"tile_vertical_start[", $sformatf("%d", i), "] = ", $sformatf("%d", hl.tile_vertical_start[i]), "\n"}; s = {s, t};
  end

  return s;
endfunction

endclass
