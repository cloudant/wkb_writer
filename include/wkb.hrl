% Licensed under the Apache License, Version 2.0 (the "License"); you may not
% use this file except in compliance with the License. You may obtain a copy of
% the License at
%
%   http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
% WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
% License for the specific language governing permissions and limitations under
% the License.
-define(POINT, <<"Point">>).
-define(LINESTRING, <<"LineString">>).
-define(POLYGON, <<"Polygon">>).
-define(MULTIPOINT, <<"MultiPoint">>).
-define(MULTILINESTRING, <<"MultiLineString">>).
-define(MULTIPOLYGON, <<"MultiPolygon">>).
-define(GEOMETRYCOLLECTION, <<"GeometryCollection">>).

-define(wkbPoint, 1).
-define(wkbLineString, 2).
-define(wkbPolygon, 3).
-define(wkbMultiPoint, 4).
-define(wkbMultiLineString, 5).
-define(wkbMultiPolygon, 6).
-define(wkbGeometryCollection, 7).

% postgis support ewkb and this module will as well, xyz, srid;geom
% TODO pointm does not transfer to geojson but does to odata
% POINT(0 0 0) -- XYZ
% SRID=32632;POINT(0 0) -- XY with SRID
% POINTM(0 0 0) -- XYM
% POINT(0 0 0 0) -- XYZM
% SRID=4326;MULTIPOINTM(0 0 0,1 2 1) -- XYM with SRID
% MULTILINESTRING((0 0 0,1 1 0,1 2 1),(2 3 1,3 2 1,5 4 1))
% POLYGON((0 0 0,4 0 0,4 4 0,0 4 0,0 0 0),(1 1 0,2 1 0,2 2 0,1 2 0,1 1 0))
% MULTIPOLYGON(((0 0 0,4 0 0,4 4 0,0 4 0,0 0 0),
%	(1 1 0,2 1 0,2 2 0,1 2 0,1 1 0)),((-1 -1 0,-1 -2 0,-2 -2 0,-2 -1 0,-1 -1 0)))
% GEOMETRYCOLLECTIONM(POINTM(2 3 9), LINESTRINGM(2 3 4, 3 4 5))


% spec - http://edndoc.esri.com/arcsde/9.0/general_topics/wkb_representation.htm

% // Basic Type definitions
% // byte : 1 byte
% // uint32 : 32 bit unsigned integer  (4 bytes)
% // double : double precision number (8 bytes)

% // Building Blocks : Point, LinearRing

% Point {
% double x;
% double y;
% };

% LinearRing   {
% uint32 numPoints;
% Point  points[numPoints];
% }

% enum wkbGeometryType {     
% wkbPoint = 1,
% wkbLineString = 2,
% wkbPolygon = 3,
% wkbMultiPoint = 4,
% wkbMultiLineString = 5,
% wkbMultiPolygon = 6,
% wkbGeometryCollection = 7
% };

% enum wkbByteOrder {

%    wkbXDR = 0,             // Big Endian

%    wkbNDR = 1           // Little Endian

% };

% WKBPoint {
% byte             byteOrder;
% uint32        wkbType;                // 1
% Point            point;
% }

% WKBLineString {
% byte             byteOrder;
% uint32        wkbType;                       // 2
% uint32        numPoints;
% Point            points[numPoints];
% }

% WKBPolygon {
% byte             byteOrder;
% uint32        wkbType;                       // 3
% uint32        numRings;
% LinearRing    rings[numRings];
% }

% WKBMultiPoint {
% byte             byteOrder;
% uint32        wkbType;                       // 4
% uint32        num_wkbPoints;
% WKBPoint         WKBPoints[num_wkbPoints];
% }

% WKBMultiLineString   {
% byte             byteOrder;
% uint32        wkbType;                       // 5
% uint32        num_wkbLineStrings;
% WKBLineString WKBLineStrings[num_wkbLineStrings];
% }

% wkbMultiPolygon {             
% byte             byteOrder;                                            
% uint32        wkbType;                       // 6
% uint32        num_wkbPolygons;
% WKBPolygon    wkbPolygons[num_wkbPolygons];
% }

% WKBGeometry  {
% union {
% WKBPoint                   point;
% WKBLineString           linestring;
% WKBPolygon              polygon;
% WKBGeometryCollection   collection;
% WKBMultiPoint           mpoint;
% WKBMultiLineString      mlinestring;
% WKBMultiPolygon         mpolygon;
% }
% };

% WKBGeometryCollection {
% byte             byte_order;
% uint32        wkbType;                       // 7
% uint32        num_wkbGeometries;
% WKBGeometry      wkbGeometries[num_wkbGeometries]
% }