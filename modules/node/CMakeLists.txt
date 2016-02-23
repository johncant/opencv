# ----------------------------------------------------------------------------
#  CMake file for v8 support
# ----------------------------------------------------------------------------

if((WIN32 AND CMAKE_BUILD_TYPE STREQUAL "Debug")
    OR BUILD_opencv_world
    )
  ocv_module_disable(node)
endif()

if(ANDROID OR APPLE_FRAMEWORK OR WINRT)
  ocv_module_disable(node)
endif()



set(OPENCV_NODE_MODULES "node")


add_subdirectory(node)

#set(cv2_generated_hdrs
#    "${CMAKE_CURRENT_BINARY_DIR}/node_opencv_generated_include.h"
#    "${CMAKE_CURRENT_BINARY_DIR}/node_opencv_generated_funcs.h"
#    "${CMAKE_CURRENT_BINARY_DIR}/node_opencv_generated_types.h"
#    "${CMAKE_CURRENT_BINARY_DIR}/node_opencv_generated_type_reg.h"
#    "${CMAKE_CURRENT_BINARY_DIR}/node_opencv_generated_ns_reg.h")
#
#file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/headers.txt" "${opencv_hdrs}")
#add_custom_command(
#   OUTPUT ${cv2_generated_hdrs}
#   COMMAND ${NODE_EXECUTABLE} "${NODE_SOURCE_DIR}/src2/gen2.py" ${CMAKE_CURRENT_BINARY_DIR} "${CMAKE_CURRENT_BINARY_DIR}/headers.txt"
#   DEPENDS ${NODE_SOURCE_DIR}/src2/gen2.py
#   DEPENDS ${NODE_SOURCE_DIR}/src2/hdr_parser.py
#   DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/headers.txt
#   DEPENDS ${opencv_hdrs})
#
