set(MODULE_NAME node)

status("NODE_FOUND: " ${NODE_FOUND})
status("MODULE_NAME: " ${MODULE_NAME})
status("the_module: " ${the_module})

if(NOT NODE_FOUND)
  ocv_module_disable(node)
endif()

set(the_description "The nodejs bindings")

include(../common.cmake)

