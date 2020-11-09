%% Copyright © 2013 Pierre Fenoll ‹pierrefenoll@gmail.com›
%% See LICENSE for licensing information.
%% -*- coding: utf-8 -*-
-module(dot_digraph).

%% dot_digraph: DOT <-> Erlang directed graph.

-export([load/1,
         export/1]).

-include("include/dot.hrl").

-type out(Ty) :: {ok, Ty} | {error, term()}.

%% API

-spec load(dot()) -> out(digraph:digraph()).
load(AST) ->
    {dot,digraph,_Direct,_Name,Assocs} = AST,
    G = digraph:new([]),
    lists:foreach(
      fun
          ({node,{nodeid,N,_,_},Opts}) ->
              Label = [{Key,Value} || {'=',Key,Value} <- Opts],
              digraph:add_vertex(G, N, Label);
          ({'->',{nodeid,A,_,_},{nodeid,B,_,_},_}) ->
              [ case digraph:vertex(G, N) of
                    false -> digraph:add_vertex(G, N, []);
                    {N, _} -> do_nothing
                end || N <- [A,B] ],
              ['$e'|_] = digraph:add_edge(G, A, B)
      end,
      lists:sort(fun erlang:'<'/2, Assocs)),
    {ok, G}.

-spec export(digraph:digraph()) -> out(dot()).
export(G) ->
    {ok,
     {dot,digraph,false,<<>>,
      lists:filtermap(
        fun (V) ->
                case digraph:vertex(G, V) of
                    {V, []} ->
                        false;
                    {V, Labels} ->
                        {true, {node,{nodeid,v_str(V),<<>>,<<>>},
                                [label_dot(Label) || Label <- Labels]}
                        }
                end
        end, digraph:vertices(G))
      ++
      [ begin
            {E, A, B, Labels} = digraph:edge(G, E),
            {'->'
            ,{nodeid,v_str(A),<<>>,<<>>}
            ,{nodeid,v_str(B),<<>>,<<>>}
            ,[label_dot(Label) || Label <- Labels]}
        end || E <- digraph:edges(G) ]}}.

%% Internals

v_str(['$v'|Id]) ->
    "v" ++ integer_to_list(Id).

label_dot({Key, Value}) ->
    {'=',
     case Key of
	 K when is_atom(K) ->
	     atom_to_list(K);
	 _ ->
	     Key
     end,
     Value}.
		   
%% End of Module.
