package Games::Lacuna::Client::Buildings;
use 5.0080000;
use strict;
use warnings;
use Carp 'croak';

use Games::Lacuna::Client;
use Games::Lacuna::Client::Module;

require Games::Lacuna::Client::Buildings::Simple;

our @BuildingTypes = (qw(
    Archaeology
    ArtMuseum
    Capitol
    CulinaryInstitute
    Development
    DistributionCenter
    Embassy
    EnergyReserve
    Entertainment
    FoodReserve
    GeneticsLab
    HallsOfVrbansk
    IBS
    Intelligence
    LibraryOfJith
    MercenariesGuild
    MiningMinistry
    MissionCommand
    Network19
    Observatory
    OperaHouse
    OracleOfAnid
    OreStorage
    Park
    Parliament
    PlanetaryCommand
    PoliceStation
    Security
    Shipyard
    SpacePort
    SSLA
    StationCommand
    SubspaceSupplyDepot
    TempleOfTheDrajilites
    ThemePark
    Trade
    Transporter
    Warehouse
    WasteRecycling
    WaterStorage
  ),
);
for my $building_type ( @BuildingTypes ){
    eval "require Games::Lacuna::Client::Buildings::$building_type;";
    die "Unable to load building type module $building_type: $@" if $@;
}

sub new {
  my $class = shift;
  my %opt = @_;
  my $btype = delete $opt{type};
  
  # redispatch in factory mode
  if (defined $btype) {
    my $realclass = $class->subclass_for($btype);
    return $realclass->new(%opt);
  }else{
    croak('Requires building type');
  }
}

sub build {
  my $self = shift;
  # assign id for this object after building
  my $rv = $self->_build(@_);
  $self->{building_id} = $rv->{building}{id};
  return $rv;
}

{
  my %type_for;

  sub type_for {
    my ($class, $hint) = @_;

    if (! keys %type_for) { # initialise mapping if needed
      %type_for = map { lc($_) => $_ }
        @Games::Lacuna::Client::Buildings::BuildingTypes,
        @Games::Lacuna::Client::Buildings::Simple::BuildingTypes;
    }

    $hint =~ s{.*/}{}mxs;
    $hint = lc($hint);
    return $type_for{$hint} || undef;
  }
}

sub type_from_url {
  my $url = shift;
  croak "URL is undefined" if not $url;
  $url =~ m{/([^/]+)$} or croak("Bad URL: '$url'");
  my $url_elem = $1;
  my $type = type_for(__PACKAGE__, $url) or croak("Bad URL: '$url'");
  return $type;
}

sub subclass_for {
  my ($class, $type) = @_;
  $type = $class->type_for($type);
  return "Games::Lacuna::Client::Buildings::$type";
}

1;
__END__

=head1 NAME

Games::Lacuna::Client::Buildings - The buildings module

=head1 SYNOPSIS

  use Games::Lacuna::Client;

=head1 DESCRIPTION

=head1 AUTHOR

Steffen Mueller, E<lt>smueller@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Steffen Mueller

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
