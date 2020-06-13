add_custom_target(uart_prove
    COMMAND ${CMAKE_COMMAND} -E chdir ./ sby -f uart_formal.sby prf
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Doing SHA1 Prove"
    )
add_custom_target(uart_cover
    COMMAND ${CMAKE_COMMAND} -E chdir ./ sby -f uart_formal.sby cvr
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Doing SHA1 Cover"
    )


