# Try to find the GNU Multiple Precision Arithmetic Library (GMP)
# See http://gmplib.org/

find_path(GMP_INCLUDE_DIRS
  NAMES
  gmp.h
  PATHS
  $ENV{GMPDIR}
  ${INCLUDE_INSTALL_DIR}
)

find_library(GMP_LIBRARIES
  NAMES
  gmp
  PATHS
  $ENV{GMPDIR}
  ${LIB_INSTALL_DIR}
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(GMP DEFAULT_MSG
                                  GMP_INCLUDE_DIRS GMP_LIBRARIES)

if(GMP_FOUND)
  add_library(GMP::GMP INTERFACE IMPORTED)
  set_target_properties(GMP::GMP PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${GMP_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES "${GMP_LIBRARIES}"
  )
endif()

mark_as_advanced(GMP_INCLUDE_DIRS GMP_LIBRARIES)
