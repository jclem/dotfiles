; Direct children of the root (program)
(program (function_declaration)        @top_level)
(program (class_declaration)           @top_level)
(program (interface_declaration)       @top_level)
(program (type_alias_declaration)      @top_level)
(program (enum_declaration)            @top_level)
(program (lexical_declaration)         @top_level) ; const/let/var

; Exported forms
(program (export_statement (function_declaration)   @top_level))
(program (export_statement (class_declaration)      @top_level))
(program (export_statement (interface_declaration)  @top_level))
(program (export_statement (type_alias_declaration) @top_level))
(program (export_statement (enum_declaration)       @top_level))
(program (export_statement (lexical_declaration)    @top_level))
