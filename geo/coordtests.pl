#!/usr/bin/perl

use strict;
use warnings;

# Geo::Proj4 by markov

use Geo::Proj4;
use Geo::Point;
my $wgs84   = Geo::Proj4->new("+proj=longlat +ellps=WGS84  +datum=WGS84");
my $towgs84 = Geo::Proj4->new("+proj=longlat +ellps=bessel +towgs84=-146.336,506.832,680.254");

sub markov_tokyo_to_wgs84 {
	my ($long, $lat) = @_;
	my $point = $towgs84->transform($wgs84, [$long, $lat]);
	($point->[0], $point->[1]);
}

sub markov_wgs84_to_tokyo {
	my ($long, $lat) = @_;
	my $point = $wgs84->transform($towgs84, [$long, $lat]);
	($point->[0], $point->[1]);
}

# Geo::Coordinates::Converter by yappo

use Geo::Coordinates::Converter;

sub yappo_wgs84_to_tokyo {
	my ($long, $lat) = @_;
	my $geo = Geo::Coordinates::Converter->new(lat => $lat, lng => $long, datum => 'wgs84');
	my $point = $geo->convert(degree => 'tokyo');
	($point->lng, $point->lat);
}

sub yappo_tokyo_to_wgs84 {
	my ($long, $lat) = @_;
	my $geo = Geo::Coordinates::Converter->new(lat => $lat, lng => $long, datum => 'tokyo');
	my $point = $geo->convert(degree => 'wgs84');
	($point->lng, $point->lat);
}

# Location::GeoTool by kokogiko

use Location::GeoTool;

sub kokogiko_tokyo_to_wgs84 {
	my ($long, $lat) = @_;
	my $geo = Location::GeoTool->create_coord($lat, $long, 'tokyo', 'degree')->datum_wgs84;
	($geo->long, $geo->lat);
}

sub kokogiko_wgs84_to_tokyo {
	my ($long, $lat) = @_;
	my $geo = Location::GeoTool->create_coord($lat, $long, 'wgs84', 'degree')->datum_tokyo;
	($geo->long, $geo->lat);
}

# tokyo -> wgs84 -> tokyo tests

my @sapporo = (141.354209, 43.056587);
my @tokyo   = (139.738293, 35.628538);
my @naha    = (127.699931, 26.221828);

roundtrip('sapporo', @sapporo);
roundtrip('tokyo',   @tokyo);
roundtrip('naha',    @naha);

sub roundtrip {
	my $title  = shift;
	my @source = @_;

	my @kokogikoW = kokogiko_tokyo_to_wgs84(@source);
	my @yappoW    = yappo_tokyo_to_wgs84(@source);
	my @markovW   = markov_tokyo_to_wgs84(@source);

	my @kokogikoT = kokogiko_wgs84_to_tokyo(@kokogikoW);
	my @yappoT    = yappo_wgs84_to_tokyo(@yappoW);
	my @markovT   = markov_wgs84_to_tokyo(@markovW);

	printf("source:    place: %-10s            tokyo: %10.6f %9.6f\n", $title,     @source);
	printf("kokogiko:  wgs84: %10.6f %9.6f  tokyo: %10.6f %9.6f\n",    @kokogikoW, @kokogikoT);
	printf("yappo:     wgs84: %10.6f %9.6f  tokyo: %10.6f %9.6f\n",    @yappoW,    @yappoT);
	printf("markov:    wgs84: %10.6f %9.6f  tokyo: %10.6f %9.6f\n",    @markovW,   @markovT);
	printf("\n");
}
