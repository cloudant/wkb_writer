%% Copyright 2012 Cloudant
-module(wkb_writer).

-include("wkb.hrl").

-export([geojson_to_wkb/1]).


geojson_to_wkb(Data) when is_list(Data) ->
	geojson_to_wkb(list_to_binary(Data));

geojson_to_wkb(Json) ->    
	JsonData = jiffy:decode(Json),
	parse_geom(JsonData).

% private api 
%
% The default signedness is unsigned.
% The default endianness is big.
%
parse_geom({JsonData}) ->
	% geometry collection is a special case
	case lists:keyfind(<<"coordinates">>, 1, JsonData) of 
		{_, Coords} ->
			{_, Type} = lists:keyfind(<<"type">>, 1, JsonData),
			parse_geom(Type, Coords);
		_ ->
			case lists:keyfind(<<"geometries">>, 1, JsonData) of 
				{_, Geometries} ->
					{_, Type} = lists:keyfind(<<"type">>, 1, JsonData),
					parse_geom(Type, Geometries);
				_ ->
					throw({error, "error parsing geometries"})
			end
	end.

parse_geom(?POINT, Coords) ->
	{ok, _Cnt, NewAcc} = make_pts([Coords], 0, <<>>),
	{ok, <<0:8, ?wkbPoint:32, NewAcc/binary>>};

parse_geom(?LINESTRING, Coords) ->
	{ok, Num, NewAcc} = make_pts(Coords, 0, <<>>),
	{ok, <<0:8, ?wkbLineString:32, Num:32, NewAcc/binary>>};

parse_geom(?POLYGON, Coords) ->
	{ok, Num, NewAcc} = make_linear_ring(Coords, 0, <<>>),
	{ok, <<0:8, ?wkbPolygon:32, Num:32, NewAcc/binary>>};

parse_geom(?MULTIPOINT, Coords) ->
	{ok, Num, NewAcc} = parse_nested_geoms(Coords, ?POINT, 0, <<>>),
	{ok, <<0:8, ?wkbMultiPoint:32, Num:32, NewAcc/binary>>};

parse_geom(?MULTILINESTRING, Coords) ->
	{ok, Num, NewAcc} = parse_nested_geoms(Coords, ?LINESTRING, 0, <<>>),
	{ok, <<0:8, ?wkbMultiLineString:32, Num:32, NewAcc/binary>>};

parse_geom(?MULTIPOLYGON, Coords) ->
	{ok, Num, NewAcc} = parse_nested_geoms(Coords, ?POLYGON, 0, <<>>),
	{ok, <<0:8, ?wkbMultiPolygon:32, Num:32, NewAcc/binary>>};

parse_geom(?GEOMETRYCOLLECTION, Geometries) ->
	{Num, NewAcc} = lists:foldl(fun(C, {Cntr, Acc1}) ->
			{ok, Acc2} = parse_geom(C),
			{Cntr + 1, <<Acc1/binary, Acc2/binary>>}
		end, {0, <<>>}, Geometries),
	{ok, <<0:8, ?wkbGeometryCollection:32, Num:32, NewAcc/binary>>};

parse_geom(false, _Data) ->
	throw({error, "error parsing geojson, geometry type not defined."}).

parse_nested_geoms([], _Type, Cntr, Acc) ->
	{ok, Cntr, Acc};

parse_nested_geoms([Coord | Rem], Type, Cntr, Acc) ->
	{ok, Acc1} = parse_geom(Type, Coord),
	parse_nested_geoms(Rem, Type, Cntr + 1, <<Acc/binary, Acc1/binary>>).

make_linear_ring([], Cntr, Acc) ->
	{ok, Cntr, Acc};

make_linear_ring([Coords | Rem], Cntr, Acc) ->
	{ok, Num, NewAcc} = make_pts(Coords, 0, <<>>),
	make_linear_ring(Rem, Cntr + 1, <<Acc/binary, Num:32, NewAcc/binary>>).

make_pts([], Cntr, Acc) ->
	{ok, Cntr, Acc};

make_pts([Coords | Rem], Cntr, Acc) ->
	NewAcc = lists:foldl(fun(P, Acc2) ->
		<<Acc2/binary, P:64/float>>
	end, Acc, Coords),
	make_pts(Rem, Cntr + 1, NewAcc).