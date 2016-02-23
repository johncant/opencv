# This file is included from a subdirectory
set(NODE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../")

ocv_add_module(${MODULE_NAME} BINDINGS)

status("NODE_SOURCE_DIR" ${NODE_SOURCE_DIR})


ocv_module_include_directories(
  "${NODE_INCLUDE_DIR}"
  "${NODE_SOURCE_DIR}/src2"
    )

# get list of modules to wrap
message(STATUS "Wrapped in ${MODULE_NAME}:")
set(OPENCV_NODE_MODULES)
foreach(m ${OPENCV_MODULES_BUILD})
  status("WEIRD_MODULE_LOOP_WRAPPERS " "${m}" - "${OPENCV_MODULE_${m}_WRAPPERS}" " - " "${MODULE_NAME}" - "${HAVE_${m}}")
  if (";${OPENCV_MODULE_${m}_WRAPPERS};" MATCHES ";${MODULE_NAME};" AND HAVE_${m})
    list(APPEND OPENCV_NODE_MODULES ${m})
  endif()
endforeach()

set(opencv_hdrs "")
foreach(m ${OPENCV_NODE_MODULES})
  list(APPEND opencv_hdrs ${OPENCV_MODULE_${m}_HEADERS})
endforeach(m)

# header blacklist
# TODO - really?
ocv_list_filterout(opencv_hdrs ".h$")
ocv_list_filterout(opencv_hdrs "cuda")
ocv_list_filterout(opencv_hdrs "cudev")
ocv_list_filterout(opencv_hdrs "/hal/")
ocv_list_filterout(opencv_hdrs "detection_based_tracker.hpp") # Conditional compilation

status("Node binding generation:")
status("opencv_hdrs: " "${opencv_hdrs}")
status("PYTHON_EXECUTABLE: " "${PYTHON_EXECUTABLE}")
status("NODE_SOURCE_DIR: " "${NODE_SOURCE_DIR}")
status("CMAKE_CURRENT_BINARY_DIR: " "${CMAKE_CURRENT_BINARY_DIR}")

# TODO - wait for this to break in order to figure out what it does
set(cv2_generated_hdrs
    "${CMAKE_CURRENT_BINARY_DIR}/node_opencv_generated_include.h"
    "${CMAKE_CURRENT_BINARY_DIR}/node_opencv_generated_funcs.h"
    "${CMAKE_CURRENT_BINARY_DIR}/node_opencv_generated_types.h"
    "${CMAKE_CURRENT_BINARY_DIR}/node_opencv_generated_type_reg.h"
    "${CMAKE_CURRENT_BINARY_DIR}/node_opencv_generated_ns_reg.h")

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/headers.txt" "${opencv_hdrs}")
add_custom_command(
   OUTPUT ${cv2_generated_hdrs}
   COMMAND ${PYTHON_EXECUTABLE} "${NODE_SOURCE_DIR}/src2/gen2.py" ${CMAKE_CURRENT_BINARY_DIR} "${CMAKE_CURRENT_BINARY_DIR}/headers.txt"
   DEPENDS ${NODE_SOURCE_DIR}/src2/gen2.py
   DEPENDS ${NODE_SOURCE_DIR}/src2/hdr_parser.py
   DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/headers.txt
   DEPENDS ${opencv_hdrs})

 ocv_add_library(${the_module} MODULE ${NODE_SOURCE_DIR}/src2/cv2.cpp ${cv2_generated_hdrs})

if(NODE_DEBUG_LIBRARIES AND NOT NODE_LIBRARIES MATCHES "optimized.*debug")
  ocv_target_link_libraries(${the_module} debug ${NODE_DEBUG_LIBRARIES} optimized ${NODE_LIBRARIES})
else()
  if(APPLE)
    set_target_properties(${the_module} PROPERTIES LINK_FLAGS "-undefined dynamic_lookup")
  else()
    ocv_target_link_libraries(${the_module} ${NODE_LIBRARIES})
  endif()
endif()
ocv_target_link_libraries(${the_module} ${OPENCV_MODULE_${the_module}_DEPS})

# TODO - What is this
execute_process(COMMAND ${NODE_EXECUTABLE} -c "import distutils.sysconfig; print(distutils.sysconfig.get_config_var('SO'))"
                RESULT_VARIABLE PYTHON_CVPY_PROCESS
                OUTPUT_VARIABLE CVPY_SUFFIX
                OUTPUT_STRIP_TRAILING_WHITESPACE)

              status("DEBUGGING FAILING NODE set_target_properties")
status("the_module" "${the_module}")
status("LIBRARY_OUTPUT_PATH" "${LIBRARY_OUTPUT_PATH}")
status("MODULE_INSTALL_SUBDIR" "${MODULE_INSTALL_SUBDIR}")
status("CVPY_SUFFIX" "${CVPY_SUFFIX}")

#set_target_properties(${the_module} PROPERTIES
#                      LIBRARY_OUTPUT_DIRECTORY  "${LIBRARY_OUTPUT_PATH}/${MODULE_INSTALL_SUBDIR}"
#                      PREFIX ""
#                      OUTPUT_NAME cv2
#                      SUFFIX ${CVPY_SUFFIX})

if(CMAKE_COMPILER_IS_GNUCXX AND NOT ENABLE_NOISY_WARNINGS)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-unused-function")
endif()


#if(NOT INSTALL_CREATE_DISTRIB)
#  install(TARGETS ${the_module} OPTIONAL
#          ${NODE_INSTALL_CONFIGURATIONS}
#          RUNTIME DESTINATION ${NODE_PACKAGES_PATH} COMPONENT python
#          LIBRARY DESTINATION ${NODE_PACKAGES_PATH} COMPONENT python
#          ${NODE_INSTALL_ARCHIVE}
#          )
#else()
#  if(DEFINED NODE_VERSION_MAJOR)
#    set(__ver "${NODE_VERSION_MAJOR}.${NODE_VERSION_MINOR}")
#  else()
#    set(__ver "unknown")
#  endif()
#  install(TARGETS ${the_module}
#          CONFIGURATIONS Release
#          RUNTIME DESTINATION python/${__ver}/${OpenCV_ARCH} COMPONENT python
#          LIBRARY DESTINATION python/${__ver}/${OpenCV_ARCH} COMPONENT python
#          )
#endif()

unset(NODE_SOURCE_DIR)
unset(NODE_CVJS_PROCESS)
unset(CVPY_SUFFIX)
unset(NODE_INSTALL_CONFIGURATIONS)
unset(NODE_INSTALL_ARCHIVE)
