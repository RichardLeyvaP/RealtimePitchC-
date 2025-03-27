cmake_minimum_required(VERSION 3.4.1)

add_library(native_lib SHARED cpp/native_lib.cpp)
set_target_properties(native_lib PROPERTIES
    FRAMEWORK TRUE
    PUBLIC_HEADER cpp/native_lib.h)
