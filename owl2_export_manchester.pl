/* -*- Mode: Prolog -*- */

:- module(owl2_export_manchester,
          [ owl_generate_manchester/1,          % +FileName
            owl_generate_manchester/2           % +FileName, +Options
          ]).
:- use_module(owl2_model).
:- use_module(library(option)).

/** <module> Generate Manchester syntax

@tbd Almost everything ...
*/

%!  owl_generate_manchester(+FileName) is det.
%!  owl_generate_manchester(+FileName, +Options) is det.
%
%   Emit the current axioms as Manchester syntax.

owl_generate_manchester(FileName) :-
    setof(Ontology,ontology(Ontology),[Ontology]),
    !,
    owl_generate_manchester(FileName, [ontology(Ontology)]).
owl_generate_manchester(FileName) :-
    owl_generate_manchester(FileName, []).

owl_generate_manchester(FileName, Options) :-
    setup_call_cleanup(
        open(FileName, write, Out, [encoding(utf8)]),
        owl_generate_manchester_to_stream(Out, Options),
        close(Out)).

owl_generate_manchester_to_stream(Out, Options) :-
    save_prefixes(Out, Options),
    ontology(Ontology, Options),
    format(Out, '~nOntology: <~w>~n', [Ontology]),
    save_classes(Out).

save_prefixes(Out, Options) :-
    save_default_prefix(Out, Options).

save_default_prefix(Out, Options) :-
    option(prefix(Prefix), Options),
    !,
    format(Out, 'Prefix: : <~w>~n', [Prefix]).
save_default_prefix(_, _).

ontology(Ontology, Options) :-
    option(ontology(Ontology), Options),
    !.
ontology('http://example.org/ontology#', _).

save_classes(Out) :-
    forall(axiom(class(Class)),
           save_class(Out, Class)).

save_class(Out, Class) :-
    format(Out, '~nClass: ~w~n', [Class]),
    save_subclasses(Out, Class).

save_subclasses(Out, Class) :-
    setof(Sub, axiom(subClassOf(Class, Sub)), Subs),
    !,
    format(Out, '  SubClassOf:~n', []),
    save_list(Out, Subs).
save_subclasses(_, _).

save_list(_Out, []) :- !.
save_list(Out, [H|T]) :-
    (   T == []
    ->  format(Out, '    ~w~n', [H])
    ;   format(Out, '    ~w,~n', [H]),
        save_list(Out, T)
    ).
