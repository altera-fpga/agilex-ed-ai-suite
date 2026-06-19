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
  This is the shared datatype between C++ compiler config generation and input feeder writer addr gen module
  Config layout for stream buffer write address and write enable generation
  Ensure that all changes are mirrored between dla_input_feeder_writer_config.h, .sv, _vc.svh

  For documentation, see file://./../README.md
*/

virtual class input_feeder_writer_config_vc #(
  parameter int NUM_LANES=1
);

typedef struct packed {
  int32_t  count_words_minus_one;
  int8_t   count_channel_lo_minus_two;          // if read_from_xbar, KVEC_OVER_CVEC otherwise 1
  int32_t  [NUM_LANES-1:0][NUM_LANES-1:0] base_address;                         // base write address in stream buffer for this layer
  int32_t  [NUM_LANES-1:0][NUM_LANES-1:0] height_skip_minus_one;
  uint32_t bounds_channel_minus_one;            // how many channel CVECs in output tensor
  int32_t  [NUM_LANES-1:0][NUM_LANES-1:0] height_size_minus_one; // height of output tensor
  int32_t  count_depth_minus_two;               // depth of input tensor
  int32_t  count_channel_hi_minus_two;          // how many channel chunks in input tensor, chunk = CVEC for DDR, KVEC for XBAR
  int32_t  count_height_minus_two;              // width of input tensor
  int32_t  count_width_minus_two;               // height of input tensor
  uint8_t  is_feature_2x_precision;             // is this convolution using a 2x precision "bootstrap" for features?
  uint8_t  read_from_xbar;                      // whether input data comes from XBAR
  uint8_t  stream_id;
  int32_t  address_channel_lo_inc;
  int32_t  address_width_inc_channel_lo_reset;
  int32_t  address_height_inc_width_reset;
  int32_t  address_depth_inc_height_reset;
  int32_t  address_channel_hi_inc_depth_reset;
} config_t;

static function automatic string to_string(input config_t c);
  string s = "";
  string t;
  t = {"count_words_minus_one               = ", $sformatf("%d",c.count_words_minus_one               ), "\n"}; s = {s, t};
  t = {"count_channel_lo_minus_two          = ", $sformatf("%d",c.count_channel_lo_minus_two          ), "\n"}; s = {s, t};
  t = {"count_width_minus_two               = ", $sformatf("%d",c.count_width_minus_two               ), "\n"}; s = {s, t};
  t = {"count_height_minus_two              = ", $sformatf("%d",c.count_height_minus_two              ), "\n"}; s = {s, t};
  t = {"count_depth_minus_two               = ", $sformatf("%d",c.count_depth_minus_two               ), "\n"}; s = {s, t};
  t = {"count_channel_hi_minus_two          = ", $sformatf("%d",c.count_channel_hi_minus_two          ), "\n"}; s = {s, t};
  t = {"bounds_channel_minus_one            = ", $sformatf("%d",c.bounds_channel_minus_one            ), "\n"}; s = {s, t};
  for (int i=0; i < NUM_LANES; i++) begin
    for (int j=0; j < NUM_LANES; j++) begin
      t = {"height_skip_minus_one[", $sformatf("%d",i), "][", $sformatf("%d",j), "] = ", $sformatf("%d",c.height_skip_minus_one[i][j]), "\n"}; s = {s, t};
    end
  end
  for (int i=0; i < NUM_LANES; i++) begin
    for (int j=0; j < NUM_LANES; j++) begin
      t = {"height_size_minus_one[", $sformatf("%d",i), "][", $sformatf("%d",j), "] = ", $sformatf("%d",c.height_size_minus_one[i][j]), "\n"}; s = {s, t};
    end
  end
  for (int i=0; i < NUM_LANES; i++) begin
    for (int j=0; j < NUM_LANES; j++) begin
      t = {"base_address[", $sformatf("%d",i), "][", $sformatf("%d",j), "] = ", $sformatf("%d",c.base_address[i][j]), "\n"}; s = {s, t};
    end
  end
  t = {"address_channel_lo_inc              = ", $sformatf("%d",c.address_channel_lo_inc              ), "\n"}; s = {s, t};
  t = {"address_width_inc_channel_lo_reset  = ", $sformatf("%d",c.address_width_inc_channel_lo_reset  ), "\n"}; s = {s, t};
  t = {"address_height_inc_width_reset      = ", $sformatf("%d",c.address_height_inc_width_reset      ), "\n"}; s = {s, t};
  t = {"address_depth_inc_height_reset      = ", $sformatf("%d",c.address_depth_inc_height_reset      ), "\n"}; s = {s, t};
  t = {"address_channel_hi_inc_depth_reset  = ", $sformatf("%d",c.address_channel_hi_inc_depth_reset  ), "\n"}; s = {s, t};
  t = {"is_feature_2x_precision             = ", $sformatf("%d",c.is_feature_2x_precision             ), "\n"}; s = {s, t};
  t = {"read_from_xbar                      = ", $sformatf("%d",c.read_from_xbar                      ), "\n"}; s = {s, t};
  t = {"stream_id                           = ", $sformatf("%d",c.stream_id                           ), "\n"}; s = {s, t};
  return s;
endfunction

typedef struct {
  int unsigned skip;
  int unsigned size;
  int unsigned output_offset;
} dim_in_sample_out_offset_t;

typedef struct {
  int unsigned width;
  int unsigned height;
  int unsigned depth;
  int unsigned buffer_width;
  int unsigned buffer_height;
  int unsigned buffer_depth;
  int unsigned channel;
  int unsigned stride_w;
  int unsigned stride_h;
  int unsigned stride_d;
  dim_in_sample_out_offset_t height_sample_offset[NUM_LANES][NUM_LANES];
  int unsigned base_address;
  bit read_from_xbar;
  bit is_feature_2x_precision;
} high_level_config_t;

// synthesis synthesis_off
static function automatic bit randomize_high_level_config(
  ref high_level_config_t hl,
  input int unsigned max_width,
  input int unsigned max_height,
  input int unsigned max_depth,
  input int unsigned max_channel,
  input int unsigned max_writes,
  input int unsigned feature_high_precision,
  input int unsigned stream_buffer_depth
  );
  //std::randomize performance is awful if you use the struct.
  int unsigned width;
  int unsigned height;
  int unsigned depth;
  int unsigned channel;
  int unsigned skip[NUM_LANES][NUM_LANES];
  int unsigned size[NUM_LANES][NUM_LANES];
  int unsigned output_offset[NUM_LANES][NUM_LANES];
  int unsigned base_address;
  int unsigned min_output_offset;
  int unsigned max_output_height;
  // When mixed precision is enabled, a layer requires 2x the stream buffer for high precision,
  // essentially, each pixel takes up two locations in the stream buffer, so we need to guarantee
  // the input dimensions x2 fit in the stream buffer, and thus we use a multiplier of 2
  // to make sure diemensions fit in the stream buffer when high precision is enabled
  int unsigned high_precision_multiplier = feature_high_precision ? 2 : 1;
  bit read_from_xbar;
  bit success;

  /*
  Summary of randomization goals:
  1. Ensure writes cannot overflow stream buffer, internal counters, or a reasonable maximum
  2. Create monotonic, non overlapping write regions from different height slices of the input
  3. Calculate a base address that also does not overflow the stream buffer
  */
  success = std::randomize (
    width,
    height,
    depth,
    channel,
    skip,
    size,
    output_offset,
    min_output_offset,
    max_output_height,
    base_address,
    read_from_xbar
  ) with {
    width           >= 1;
    height          >= 1;
    depth           >= 1;
    channel         >= 1;
    width           <= max_width;
    height          <= max_height;
    depth           <= max_depth;
    channel         <= max_channel;

    max_writes / width / height / depth / channel >= 1;

    // This prevents overflow of certain 'input' counters
    (stream_buffer_depth * NUM_LANES) / high_precision_multiplier / width / height / depth / channel >= 1;

    foreach (skip[i,j])
      if (read_from_xbar == 0 && j > 0)
        skip[i][j] == height;
      else
        skip[i][j] >= 0;

    // Reference model does not support height skip when not multilane
    foreach (skip[i,j]) skip[i][j] <= ((NUM_LANES == 1) ? 0 : height);

    // Reference model does not support height limit when not multilane
    foreach (size[i,j]) size[i][j] >= ((NUM_LANES == 1) ? (height - skip[i][j]) : 0);

    foreach (size[i,j]) size[i][j] <= (height - skip[i][j]);

    // Force each output region to be monotonic and continuous
    // (Full freedom really stresses the solver, and is less representative on how this will be used anyways)
    foreach (output_offset[i,j])
      if (j < 1)
        output_offset[i][j] >= 0;
      else
        output_offset[i][j] == (output_offset[i][j-1] + size[i][j-1]);

    foreach (output_offset[i,j])
      output_offset[i][j] < height;

    // must write at least one word
    foreach (size[i])
      size[i].sum() >= 1;

    foreach (output_offset[i,j])
      if (size[i][j] > 0)
        min_output_offset <= output_offset[i][j];

    foreach (output_offset[i,j])
      if (size[i][j] > 0)
        max_output_height >= output_offset[i][j] + size[i][j];

    (max_output_height - min_output_offset) <= height;

    foreach (output_offset[i,j])
      stream_buffer_depth >= (high_precision_multiplier * width * depth * channel * (max_output_height - min_output_offset) + high_precision_multiplier * width * output_offset[i][j]);

    base_address >= 0;
    base_address < stream_buffer_depth - high_precision_multiplier + 1;

    foreach (output_offset[i,j])
      base_address <= (stream_buffer_depth -
        (high_precision_multiplier * width * (max_output_height - min_output_offset) * depth * channel +
        high_precision_multiplier * width * output_offset[i][j]) );
  };

  hl.width                   = width;
  hl.height                  = height;
  hl.depth                   = depth;
  hl.channel                 = channel;
  hl.buffer_width            = width;
  hl.buffer_height           = max_output_height - min_output_offset;
  hl.buffer_depth            = depth;
  hl.stride_w                = 1;
  hl.stride_h                = 1;
  hl.stride_d                = 1;
  for (int i=0; i < NUM_LANES; i++) begin
    for (int j=0; j < NUM_LANES; j++) begin
      hl.height_sample_offset[i][j].skip = skip[i][j];
      hl.height_sample_offset[i][j].size = size[i][j];
      hl.height_sample_offset[i][j].output_offset = output_offset[i][j];
    end
  end
  hl.base_address            = base_address;
  hl.read_from_xbar          = read_from_xbar;
  hl.is_feature_2x_precision = feature_high_precision;
  return success;
endfunction
// synthesis synthesis_on

static function automatic void derive_from_high_level_config(
  ref config_t c,
  input uint32_t arch_kvec_over_cvec,
  input uint32_t arch_num_lanes,
  input high_level_config_t hl
  );
  uint8_t count_channel_lo = (hl.read_from_xbar ? arch_kvec_over_cvec : 1);
  uint32_t count_channel_hi = ((hl.channel + count_channel_lo - 1) / count_channel_lo);
  uint32_t min_output_offset = hl.height;
  uint32_t max_output_height = 0;
  // Param checks
  assert(hl.stride_w > 0) else $fatal("Write/Move horizontal stride expected to be > 0");
  assert(hl.stride_h > 0) else $fatal("Write/Move vertical stride expected to be > 0");
  assert(hl.stride_d > 0) else $fatal("Write/Move depth stride expected to be > 0");
  // The write inst can either write the full tensor/buffer or part of it. Check this is true.
  assert(hl.buffer_width >= hl.width) else $fatal("The allocated width of a buffer must be larger or equal to the write width of this write.");
  assert(hl.buffer_depth >= hl.depth) else $fatal("The allocated depth of a buffer must be larger or equal to the write depth of this write.");

  for(uint32_t i=0; i < arch_num_lanes; i++) begin
    for(uint32_t j=0; j < arch_num_lanes; j++) begin
      c.height_skip_minus_one[i][j]     = hl.height_sample_offset[i][j].skip - 1;
      if (hl.height_sample_offset[i][j].size > 0) begin
        min_output_offset = min(min_output_offset, hl.height_sample_offset[i][j].output_offset);
        max_output_height = max(max_output_height, hl.height_sample_offset[i][j].output_offset + hl.height_sample_offset[i][j].size);
      end
    end
  end

  c.count_words_minus_one = (count_channel_lo * hl.width * hl.height * hl.depth * count_channel_hi) - 1;
  for(uint32_t i=0; i < arch_num_lanes; i++) begin
    for(uint32_t j=0; j < arch_num_lanes; j++) begin
      c.base_address[i][j]              = hl.base_address + (hl.height_sample_offset[i][j].output_offset - hl.height_sample_offset[i][j].skip)  * hl.width;
    end
  end
  c.read_from_xbar                      = hl.read_from_xbar;
  c.count_channel_lo_minus_two          = count_channel_lo - 2;
  c.count_width_minus_two               = hl.width - 2;
  c.count_height_minus_two              = hl.height - 2;
  c.count_channel_hi_minus_two          = count_channel_hi - 2;
  c.count_depth_minus_two               = hl.depth - 2;
  c.bounds_channel_minus_one            = hl.channel - 1;
  for(uint32_t i=0; i < arch_num_lanes; i++) begin
    for(uint32_t j=0; j < arch_num_lanes; j++) begin
        c.height_size_minus_one[i][j]= hl.height_sample_offset[i][j].size - 1;
    end
  end

  c.address_channel_lo_inc              = (count_channel_lo == 1) ? 0 : (hl.buffer_width * hl.buffer_height * hl.buffer_depth);
  c.address_width_inc_channel_lo_reset  = hl.stride_w - c.address_channel_lo_inc * count_channel_lo;
  c.address_height_inc_width_reset      = hl.stride_h * hl.buffer_width - (hl.width * hl.stride_w);
  c.address_depth_inc_height_reset      = hl.stride_d * hl.buffer_height * hl.buffer_width - (hl.height * hl.stride_h) * hl.buffer_width;
  c.address_channel_hi_inc_depth_reset  = count_channel_lo * (hl.buffer_width * hl.buffer_height * hl.buffer_depth) - ((hl.depth * hl.stride_d) * hl.buffer_height * hl.buffer_width);

  c.is_feature_2x_precision = hl.is_feature_2x_precision;
  if (hl.is_feature_2x_precision) begin
    // Double all address increments + resets to make space for the (sb_addr+1) word in 2x precision mode.
    c.address_channel_lo_inc             *= 2;
    c.address_width_inc_channel_lo_reset *= 2;
    c.address_height_inc_width_reset     *= 2;
    c.address_depth_inc_height_reset     *= 2;
    c.address_channel_hi_inc_depth_reset *= 2;
    // The count configs are not modified by is_2x_feature_precision.
    // These configs are all used to control the counters; their behavior is unchanged by 2x mode.
  end
endfunction

static function automatic string hl_to_string(input high_level_config_t c);
  string s = "";
  string t;
  t = {"width               = ", $sformatf("%d",c.width               ), "\n"}; s = {s, t};
  t = {"height              = ", $sformatf("%d",c.height              ), "\n"}; s = {s, t};
  t = {"depth               = ", $sformatf("%d",c.depth               ), "\n"}; s = {s, t};
  t = {"channel             = ", $sformatf("%d",c.channel             ), "\n"}; s = {s, t};
  for (int i=0; i < NUM_LANES; i++) begin
    for (int j=0; j < NUM_LANES; j++) begin
      t = {"height_sample_offset[", $sformatf("%d",i), "][", $sformatf("%d",j), "].skip          = ", $sformatf("%d",c.height_sample_offset[i][j].skip         ), "\n"}; s = {s, t};
      t = {"height_sample_offset[", $sformatf("%d",i), "][", $sformatf("%d",j), "].size          = ", $sformatf("%d",c.height_sample_offset[i][j].size         ), "\n"}; s = {s, t};
      t = {"height_sample_offset[", $sformatf("%d",i), "][", $sformatf("%d",j), "].output_offset = ", $sformatf("%d",c.height_sample_offset[i][j].output_offset), "\n"}; s = {s, t};
    end
  end
  t = {"base_address            = ", $sformatf("%d",c.base_address             ), "\n"}; s = {s, t};
  t = {"read_from_xbar          = ", $sformatf("%d",c.read_from_xbar           ), "\n"}; s = {s, t};
  t = {"is_feature_2x_precision = ", $sformatf("%d",c.is_feature_2x_precision  ), "\n"}; s = {s, t};
  return s;
endfunction

endclass
