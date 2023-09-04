#include "iree/runtime/api.h"

typedef struct output_spec_t {
  iree_device_size_t data_length;
} output_spec_t;

typedef struct input_spec_t {
  iree_host_size_t rank;
  iree_hal_dim_t *shape;
  iree_hal_element_type_t element_type;
  iree_hal_encoding_type_t encoding_type;
} input_spec_t;

typedef struct function_spec_t {
  iree_string_view_t name;
  int num_inputs;
  input_spec_t *inputs;
  int num_outputs;
  output_spec_t *outputs;
} function_spec_t;

typedef struct model_t {
  iree_string_view_t name;
  int num_functions;
  function_spec_t *functions;
} model_t;
