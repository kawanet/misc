#!/usr/bin/perl

use strict;
use warnings;

# Geo::Proj4 by markov

use Geo::Proj4;
my $wgs84 = Geo::Proj4->new("+proj=longlat +ellps=WGS84  +datum=WGS84");
my $tokyo = Geo::Proj4->new("+proj=longlat +ellps=bessel +towgs84=-146.336,506.832,680.254");

sub markov_tokyo_to_wgs84 {
	my ($lat, $long) = @_;
	my $point = $tokyo->transform($wgs84, [$long, $lat]);
	($point->[1], $point->[0]);
}

sub markov_wgs84_to_tokyo {
	my ($lat, $long) = @_;
	my $point = $wgs84->transform($tokyo, [$long, $lat]);
	($point->[1], $point->[0]);
}

# Geo::Coordinates::Converter by yappo

use Geo::Coordinates::Converter;

sub yappo_wgs84_to_tokyo {
	my ($lat, $long) = @_;
	my $geo = Geo::Coordinates::Converter->new(lat => $lat, lng => $long, datum => 'wgs84');
	my $point = $geo->convert(degree => 'tokyo');
	($point->lat, $point->lng);
}

sub yappo_tokyo_to_wgs84 {
	my ($lat, $long) = @_;
	my $geo = Geo::Coordinates::Converter->new(lat => $lat, lng => $long, datum => 'tokyo');
	my $point = $geo->convert(degree => 'wgs84');
	($point->lat, $point->lng);
}

# Location::GeoTool by kokogiko

use Location::GeoTool;

sub kokogiko_tokyo_to_wgs84 {
	my ($lat, $long) = @_;
	my $geo = Location::GeoTool->create_coord($lat, $long, 'tokyo', 'degree')->datum_wgs84;
	($geo->lat, $geo->long);
}

sub kokogiko_wgs84_to_tokyo {
	my ($lat, $long) = @_;
	my $geo = Location::GeoTool->create_coord($lat, $long, 'wgs84', 'degree')->datum_tokyo;
	($geo->lat, $geo->long);
}

# tokyo -> wgs84 -> tokyo tests

my @hokkaido = (155023450/3600000, 508861960/3600000);
my @tokyo    = (128470740/3600000, 502902170/3600000);
my @okinawa  = ( 94350640/3600000, 459658600/3600000);

roundtrip('hokkaido', @hokkaido);
roundtrip('tokyo',    @tokyo);
roundtrip('okinawa',  @okinawa);

sub roundtrip {
	my $title  = shift;
	my @source = @_;

	my @kokogikoW = kokogiko_tokyo_to_wgs84(@source);
	my @yappoW    = yappo_tokyo_to_wgs84(@source);
	my @markovW   = markov_tokyo_to_wgs84(@source);

	my @kokogikoT = kokogiko_wgs84_to_tokyo(@kokogikoW);
	my @yappoT    = yappo_wgs84_to_tokyo(@yappoW);
	my @markovT   = markov_wgs84_to_tokyo(@markovW);

	printf("source:    place: %-10s             tokyo: %10.6f %9.6f\n", $title,     @source);
	printf("kokogiko:  wgs84: %10.6f %9.6f  tokyo: %10.6f %9.6f\n",     @kokogikoW, @kokogikoT);
	printf("yappo:     wgs84: %10.6f %9.6f  tokyo: %10.6f %9.6f\n",     @yappoW,    @yappoT);
	printf("markov:    wgs84: %10.6f %9.6f  tokyo: %10.6f %9.6f\n",     @markovW,   @markovT);
	printf("\n");
}
