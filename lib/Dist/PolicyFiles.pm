package Dist::PolicyFiles;

use 5.014;
use strict;
use warnings;

our $VERSION = '0.01';


use Carp;
use File::Basename;
use File::Spec::Functions;

use Software::Security::Policy::Individual;


use Text::Template;

use GitHub::Config::SSH::UserData qw(get_user_data_from_ssh_cfg);


#
# CONTRIBUTING.md, SECURITY.md
#


###########################################

sub new {
  my $class = shift;
  my %args = (dir => '.', prefix => q{}, @_);
  $args{uncapitalize} = !!$args{uncapitalize};
  # login module : mandatory
  # email full_name dir prefix uncapitalize
  delete @args{ grep { !defined $args{$_} } keys %args };
  do {croak("$_: missing mandatory argument") if !exists($args{$_})} for (qw(login module));
  do {croak("$_: value is not a scalar") if ref($args{$_})} for keys(%args);
  my $self = bless(\%args, $class);
  if (!(exists($self->{email}) && exists($self->{full_name}))) {
    my $udata = get_user_data_from_ssh_cfg($self->{login});
    $self->{email} //= $udata->{email2} // $udata->{email}
      // die("Could not determine email address");      # Should never happen.
    $self->{full_name} //= $udata->{full_name}
      // die("Could not determine user's full name");   # Should never happen.
  }
  return $self;
}


sub module       {$_[0]->{module}}
sub login        {$_[0]->{login}}
sub email        {$_[0]->{email}}
sub full_name    {$_[0]->{full_name}}
sub dir          {$_[0]->{dir}}
sub prefix       {$_[0]->{prefix}}
sub uncapitalize {$_[0]->{uncapitalize}}


# -----------------------------------


sub create_security_md {
  my $self = shift;
  my %args = (maintainer => sprintf("%s <%s>", @{$self}{qw(full_name email)}),
              program    => $self->{module},
              @_);
  if (!exists($args{url})) {
    (my $m = $self->{module}) =~ s/::/-/g;
    $m = lc($m) if $self->{uncapitalize};
    $args{url} = "https://github.com/$self->{login}/$self->{prefix}${m}/blob/main/SECURITY.md";
  }
  delete @args{ grep { !defined $args{$_} || $args{$_} eq q{}} keys %args };
  open(my $fh, '>', catfile($self->{dir}, 'SECURITY.md'));
  print $fh (Software::Security::Policy::Individual->new(\%args)->fulltext);
  close($fh);
}


sub create_contrib_md {
  my $self = shift;
  my $contrib_md_src = shift;
  croak('Unexpected argument(s)') if @_;
  croak('Missing --module: no module specified') unless exists($self->{module});
  my $contrib_md_tmpl_str = defined($contrib_md_src) ?
    do { local ( *ARGV, $/ ); @ARGV = ($contrib_md_src); <> }
    :
    <<'EOT';
# Contributing to This Perl Module

Thank you for your interest in contributing!

## Reporting Issues

Please open a
[CPAN request]({$cpan_rt})
or a
[GitHub Issue]({$github_i})
if you encounter a bug or have a suggestion.
Include the following if possible:

- A clear description of the issue
- A minimal code example that reproduces it
- Expected and actual behavior
- Perl version and operating system

## Submitting Code

Pull requests are welcome! To contribute code:

1. Fork the repository and create a descriptive branch name.
2. Write tests for any new feature or bug fix.
3. Ensure all tests pass using `prove -l t/` or `make test`.
4. Follow the existing code style, especially:
   - No tabs please
   - No trailing whitespace please
   - 2 spaces indentation
5. In your pull request, briefly explain your changes and their motivation.


## Creating a Distribution (Release)

This module uses MakeMaker for creating releases (`make dist`).


## Licensing

By submitting code, you agree that your contributions may be distributed under the same license as the project.

Thank you for helping improve this module!

EOT
#Don't append a semicolon to the line above!

  (my $mod_name = (split(/,/, $self->{module}))[0]) =~ s/::/-/g;
  my $cpan_rt  = "https://rt.cpan.org/NoAuth/ReportBug.html?Queue=$mod_name";
  my $repo = $self->{prefix} . ($self->{uncapitalize} ? lc($mod_name) : $mod_name);
  my $github_i = "https://github.com/$self->{login}/$repo/issues";
  my $tmpl_obj = Text::Template->new(SOURCE => $contrib_md_tmpl_str, TYPE => 'STRING')
    or croak("Couldn't construct template: $Text::Template::ERROR");

  my $contrib = $tmpl_obj->fill_in(HASH => {cpan_rt  => $cpan_rt, github_i => $github_i})
    // croak("Couldn't fill in template: $Text::Template::ERROR");
    open(my $fh, '>', catfile($self->{dir}, 'CONTRIBUTING.md'));
    print $fh ($contrib, "\n");
    close($fh);
}



1; # End of Dist::PolicyFiles


__END__

=pod

=head1 NAME

Dist::PolicyFiles - Generate F<CONTRIBUTING.md> and F<SECURITY.md>

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Dist::PolicyFiles;

    my $obj = Dist::PolicyFiles->new(login => $login_name, module => $module);
    $obj->create_security_md();
    $obj->create_contrib_md();

=head1 DESCRIPTION

=head2 METHODS

=over

=item C<>

=item C<>

=item C<>

=item C<>

=item C<>

=item C<>

=item C<>

=item C<>

=item C<>

=item C<>

=item C<>

=item C<>

=back


=head1 AUTHOR

Klaus Rindfrey, C<< <klausrin at cpan.org.eu> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-dist-policyfiles at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Dist-PolicyFiles>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Dist::PolicyFiles


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=Dist-PolicyFiles>

=item * Search CPAN

L<https://metacpan.org/release/Dist-PolicyFiles>

=item * GitHub Repository

L<https://github.com/klaus-rindfrey/perl-dist-policyfiles>

=back




=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2025 by Klaus Rindfrey.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.


=cut
