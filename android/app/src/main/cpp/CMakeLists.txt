# cmake_minimum_required(VERSION 3.10)

# # Nombre de tu proyecto (puedes poner "singing_app" o cualquier otro nombre)
# project(singing_app)

# # Agregar el archivo fuente nativo
# add_library(
#     native1_lib
#     SHARED
#     src/main/cpp/native_lib2.cpp  # Ruta del archivo cpp que ya tienes
# )

# # Incluir directorios
# target_include_directories(
#     native_lib PRIVATE
#     ${CMAKE_SOURCE_DIR}/src/main/cpp
# )

# # Enlazar bibliotecas necesarias
# find_library(
#     log-lib
#     log
# )

# target_link_libraries(
#     native_lib
#     ${log-lib}
# )

cmake_minimum_required(VERSION 3.4.1)

add_library( native-lib SHARED native-lib.cpp )

find_library( log-lib log )

target_link_libraries( native-lib ${log-lib} )



                       
