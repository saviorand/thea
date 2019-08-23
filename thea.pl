:- prolog_load_context(directory, Dir),
   file_directory_name(Dir, Lib),
   (   user:file_search_path(library, Lib)
   ->  true
   ;   asserta(user:file_search_path(library, Lib))
   ).

thea_jar_file(Jar) :-
    working_directory(CWD, CWD),
    absolute_file_name(library('thea2/jars'), Dir,
                       [ file_type(directory),
                         access(read),
                         file_errors(fail),
                         solutions(all)
                       ]),
    atom_concat(Dir, '/*.jar', Pattern),
    expand_file_name(Pattern, Files),
    member(Jar0, Files),
    relative_file_name(Jar0, CWD, Jar).

thea_setup_classpath :-
    findall(Jar, thea_jar_file(Jar), Jars),
    atomic_list_concat(Jars, :, ClassPath0),
    (   getenv('CLASSPATH', Existing)
    ->  atomic_list_concat([ClassPath0,Existing], :, ClassPath)
    ;   ClassPath = ClassPath0
    ),
    setenv('CLASSPATH', ClassPath).

:- initialization
    thea_setup_classpath.

:- use_module(owl2_model).
:- use_module(owl2_from_rdf).
:- use_module(owl2_export_rdf).
:- use_module(owl2_xml).
:- use_module(owl2_util).
:- use_module(owl2_io).
:- use_module(owl2_reasoner).

