
# cmake_minimum_required(VERSION 3.4.1)

# add_library( native-lib SHARED native-lib.cpp )

# find_library( log-lib log )

# target_link_libraries( native-lib ${log-lib} )




cmake_minimum_required(VERSION 3.4.1)

# Configuración básica
project(native-lib)

# Habilita C++17
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Crea la biblioteca
add_library(
    native-lib
    SHARED
    native-lib.cpp
)

# Bibliotecas necesarias
find_library(log-lib log)
find_library(m-lib m)  # Para funciones matemáticas

target_link_libraries(
    native-lib
    ${log-lib}
    ${m-lib}
)

# Configuración para FFI/Flutter
set_target_properties(native-lib PROPERTIES
    CXX_VISIBILITY_PRESET hidden
    VISIBILITY_INLINES_HIDDEN ON
)

                       
