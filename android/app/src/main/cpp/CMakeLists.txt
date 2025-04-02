
# # cmake_minimum_required(VERSION 3.4.1)

# # add_library( native-lib SHARED native-lib.cpp )

# # find_library( log-lib log )

# # target_link_libraries( native-lib ${log-lib} )




# cmake_minimum_required(VERSION 3.4.1)

# # Configuración básica
# project(native-lib)

# # Habilita C++17
# set(CMAKE_CXX_STANDARD 17)
# set(CMAKE_CXX_STANDARD_REQUIRED ON)

# # Crea la biblioteca
# add_library(
#     native-lib
#     SHARED
#     native-lib.cpp
# )

# # Bibliotecas necesarias
# find_library(log-lib log)
# find_library(m-lib m)  # Para funciones matemáticas

# target_link_libraries(
#     native-lib
#     ${log-lib}
#     ${m-lib}
# )

# # Configuración para FFI/Flutter
# set_target_properties(native-lib PROPERTIES
#     CXX_VISIBILITY_PRESET hidden
#     VISIBILITY_INLINES_HIDDEN ON
# )

                       
cmake_minimum_required(VERSION 3.4.1)

# Configuración básica del proyecto
project(native-lib LANGUAGES CXX)

# Configuración estándar de compilación
set(CMAKE_VERBOSE_MAKEFILE ON)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -Werror")

# Configuración para Android
if(ANDROID)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fexceptions -frtti")
    add_definitions(-DANDROID)
endif()

# Habilita C++17 con extensiones GNU (necesario para algunas características)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS ON)

# Configuración de la biblioteca nativa
add_library(
    native-lib
    SHARED
    native-lib.cpp
)

# Incluir directorios (si tienes headers adicionales)
include_directories(${CMAKE_CURRENT_SOURCE_DIR})

# Configuración de propiedades para FFI/Flutter
set_target_properties(native-lib PROPERTIES
    CXX_VISIBILITY_PRESET hidden
    VISIBILITY_INLINES_HIDDEN ON
    # Fuerza la exportación de símbolos necesarios
    CXX_VISIBILITY_PRESET default
)

# Encontrar y enlazar bibliotecas del sistema
find_library(log-lib log)
find_library(m-lib m)  # Biblioteca matemática

# Bibliotecas adicionales recomendadas para procesamiento de audio
find_library(android-lib android)
find_library(OpenSLES-lib OpenSLES)

target_link_libraries(
    native-lib
    ${log-lib}
    ${m-lib}
    ${android-lib}
    ${OpenSLES-lib}
)

# Configuración específica para Windows (si es necesario)
if(WIN32)
    target_compile_definitions(native-lib PRIVATE -D_USE_MATH_DEFINES)
endif()

# Configuración de instalación (opcional)
install(TARGETS native-lib LIBRARY DESTINATION lib)