package Module::FeaturesUtil::Get;

# AUTHORITY
# DATE
# DIST
# VERSION

use strict 'subs', 'vars';
use warnings;

use Exporter 'import';
our @EXPORT_OK = qw();

sub _get_features_decl {
    my $mod = shift;

    # first, try to get features declaration from MODNAME::_ModuleFeatures's %FEATURES
    my $proxymod = "$mod\::_ModuleFeatures";
    (my $proxymodpm = "$proxymod.pm") =~ s!::!/!g;
    eval { require $proxymodpm; 1 };
    unless ($@) {
        my $features = \%{"$proxymod\::FEATURES"};
        return $features if scalar keys %$features;
    }

    # second, try to get features declaration from MODNAME %FEATURES
    (my $modpm = "$mod.pm") =~ s!::!/!g;
    require $modpm;

    # XXX compare the two if both declarations exist

    \%{"$mod\::FEATURES"};
}

sub get_feature_val {
    my ($module_name, $feature_set_name, $feature_name) = @_;

    my $features_decl = _get_features_decl($module_name);
    return undef unless $features_decl->{features}{$feature_set_name};

    my $val0 = $features_decl->{features}{$feature_set_name}{$feature};
    return ref $val0 eq 'HASH' ? $val0->{value} : $val0;
}

sub module_declares_feature {
    my ($module_name, $feature_set_name, $feature_name) = @_;

    my $features_decl = _get_features_decl($module_name);
    return undef unless $features_decl->{features}{$feature_set_name};

    exists $features_decl->{features}{$feature_set_name}{$feature};
}

1;
# ABSTRACT: Get a feature

=head1 SYNOPSIS

 use Module::FeaturesUtil::Get qw(
     get_features_decl
     get_feature_val
     module_declares_feature
 );

 # Get features declaration:
 my $features_decl = get_features_decl('Text::Table::Tiny');

 # Get value of a feature:
 if (!get_feature_val('Text::Table::Tiny', 'TextTable', 'align_cell_containing_color_codes')) {
     # strip color codes first
     for ($str1, $str2) { s/\e\[[0-9;]+m/sg }
 }
 push @rows, [$str1, $str2];

 # Check whether a module declares a feature:
 if (module_declares_feature('Text::Table::Tiny', 'TextTable', 'speed')) {
    ...
 }


=head1 DESCRIPTION


=head1 FUNCTIONS

=head2 get_features_decl

Usage:

 my $features_decl = get_features_decl($module_name);

Features declaration is first looked up from proxy module's C<%FEATURES> package
variable, then from the module's C<%FEATURES>. Proxy module is
C<$module_name>I<::_ModuleFeatures>. You have to load the modules yourself; this
routine will not load the modules for you.

This module will also NOT check the validity of features declaration.

=head2 get_feature_val

Usage:

 my $val = get_feature_val($module_name, $feature_set_name, $feature_name);

Example:

 if (!get_feature_val('Text::Table::Tiny', 'TextTable', 'align_cell_containing_color_codes')) {
     # strip color codes first
     for ($str1, $str2) { s/\e\[[0-9;]+m/sg }
 }
 push @rows, [$str1, $str2];

Get the value of a feature from a module's features declaration.

Features declaration is retrieved using L</get_features_decl>.

This routine will also NOT check the feature set specification.

=head2 module_declares_feature

Usage:

 my $bool = module_declares_feature($module_name, $feature_set_name, $feature_name);

Check whether module declares a feature.

Features declaration is retrieved using L</get_features_decl>.

This routine will also NOT check the feature set specification.


=head1 SEE ALSO

L<Module::Features>

This module does not check whether a feature declaration is valid or whether a
feature set specification is valid. To do that, use
L<Module::FeaturesUtil::Check>'s C<check_features_decl> and
C<check_feature_set_spec>.
