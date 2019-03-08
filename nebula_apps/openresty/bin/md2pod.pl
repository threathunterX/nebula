#!/usr/bin/env perl

use v5.10.1;
use strict;
use warnings;

use Getopt::Std;

my %opts;
getopts('ho:', \%opts)
    or usage(1);

if ($opts{h}) {
    usage(0);
}

my %html_entities = (
    'amp' => '&',
    'lt' => 'E<lt>',
    'gt' => 'E<gt>',
    'quot' => '"',
);

my $infile = shift or die "No input file specified.\n";
my $pod = process_file($infile);

my $outfile = $opts{o};
if (defined $outfile) {
    open my $out, ">:encoding(UTF-8)", $outfile
        or die "cannot open $outfile for writing: $!\n";
    print $out $pod;
    close $out;

} else {
    binmode STDOUT, ':encoding(UTF-8)';
    print $pod;
}

sub process_file {
    my $infile = shift;

    open my $in, "<:encoding(UTF-8)", $infile
        or die "cannot open $infile for reading: $!\n";
    local $_ = do { local $/; <$in> };
    close $in;

    my $out = "=encoding utf-8\n\n";
    my ($in_code, %ind2level, %level2ind, $list_level, $cur_list_indent, %list_idx);
    my $just_seen_newline;
    my $add_indent;
    my $total_len = length;

    while (1) {
        #warn pos_str($_), $in_code ? ', in-code' : (),
        #$list_level ? ", list level $list_level" : ();

        if ($in_code) {
            if ($add_indent && m/ \G ^ ``` \s* \n? $ /gcxm) {
                undef $in_code;
                undef $add_indent;
                $just_seen_newline = 1;
                next;
            }

            if (!$add_indent) {
                if (m/ \G ^ \s* \n /gcxm) {
                    $just_seen_newline = 1;
                    $out .= "\n";
                    undef $in_code;
                    next;
                }

                undef $just_seen_newline;

                if (m/ \G ^ (\s+) /gcxm) {
                    my $leading_spaces = $1;
                    if (length $leading_spaces < 4) {
                        # new paragraph
                        pos $_ -= length $leading_spaces;
                        undef $in_code;
                        next;
                    }

                    pos $_ -= length $leading_spaces;

                } else {
                    undef $in_code;
                    next;
                }
            }

            if (/ \G ( [^\n]+ \n? ) /gcxms) {
                if ($add_indent) {
                    $out .= "    " . $1;

                } else {
                    $out .= $1;
                }

                undef $just_seen_newline;
                next;
            }

            if (/ \G (.) /gcxs) {
                if ($add_indent) {
                    $out .= "    " . $1;

                } else {
                    $out .= $1;
                }

                undef $just_seen_newline;
                next;
            }

            if ($add_indent) {
                warn "missing terminating ```\n";
            }

            last;

        } else {
            # !$in_code

            if (/ \G ^ ( \S .* ) \n \s* ([-=]+) \s* \n? $ /gcxm) {
                my ($title, $type) = ($1, $2);

                #die "Hit!";

                if ($list_level) {
                    for (my $level = $list_level; $level > 0; $level--) {
                        $out .= "\n=back\n\n";
                        my $ind = $level2ind{$level};
                        delete $level2ind{$level};
                        delete $ind2level{$ind};
                        delete $list_idx{$level};
                    }

                    undef $list_level;
                    undef $cur_list_indent;
                }

                my $level = ($type =~ /=/) ? 1 : 2;

                $out .= "\n=head$level ";
                $out .= process_remaining_line($title);
                $out .= "\n";
                next;
            }

            if (/ \G ^ \s* \<!--.*?--> \s* /gcxms) {
                $out .= "\n";
                $just_seen_newline = 1;
                next;
            }

            if (/ \G ^ \s* (?: \n | $ ) /gcxm) {
                $just_seen_newline = 1;
                $out .= "\n";

                if ($list_level && m/ \G (?! ^ \  ) /gcxm) {
                    for (my $level = $list_level; $level > 0; $level--) {
                        $out .= "\n=back\n\n";
                        my $ind = $level2ind{$level};
                        delete $level2ind{$level};
                        delete $ind2level{$ind};
                        delete $list_idx{$level};
                    }

                    undef $list_level;
                    undef $cur_list_indent;
                }

                next;
            }

            if (/ \G ^ ``` \s* (?: \w+ \s* )? (?: \n | $ ) /gcxm) {
                $in_code = 1;
                $add_indent = 1;
                $out .= "\n";
                next;
            }

            if (/ \G ^ (\s*) ( [-+*] | \d+ \. ) \s+ /gcxm) {
                my ($leading_space, $prefix) = ($1, $2);

                if (!defined $list_level) {
                    # first element
                    if (length $leading_space < 4) {
                        $out .= "\n=over\n\n";

                        # treat it as a new list
                        if ($prefix =~ /^[-+*]$/) {
                            $out .= "\n=item *\n\n";
                        } else {
                            $list_idx{1} = 1;
                            $out .= "\n=item 1.\n\n";
                        }

                        $list_level = 1;
                        $cur_list_indent = length $leading_space;
                        $ind2level{$cur_list_indent} = $list_level;
                        $level2ind{$list_level} = $cur_list_indent;

                        $out .= process_remaining_line($_);

                    } else {
                        if ($just_seen_newline) {
                            undef $just_seen_newline;
                            # FIXME must with a leading empty line
                            $in_code = 1;
                            m/ \G (.* \n? ) /;
                            $out .= $leading_space . $1;
                            next;
                        }

                        # append to the previous paraprah
                        $out .= process_remaining_line($_);
                        next;
                    }

                } else {
                    if ($just_seen_newline) {
                        for (my $level = $list_level; $level > 0; $level--) {
                            $out .= "\n=back\n\n";
                            my $ind = $level2ind{$level};
                            delete $level2ind{$level};
                            delete $ind2level{$ind};
                            delete $list_idx{$level};
                        }

                        undef $list_level;
                        undef $cur_list_indent;

                        # first element
                        if (length $leading_space < 4) {
                            $out .= "\n=over\n\n";

                            # treat it as a new list
                            if ($prefix =~ /^[-+*]$/) {
                                $out .= "\n=item *\n\n";
                            } else {
                                $list_idx{1} = 1;
                                $out .= "\n=item 1.\n\n";
                            }

                            $list_level = 1;
                            $cur_list_indent = length $leading_space;
                            $ind2level{$cur_list_indent} = $list_level;
                            $level2ind{$list_level} = $cur_list_indent;

                            $out .= process_remaining_line($_);

                        } else {
                            if ($just_seen_newline) {
                                undef $just_seen_newline;
                                # FIXME must with a leading empty line
                                $in_code = 1;
                                $out .= "$_";
                                next;
                            }

                            # append to the previous paraprah
                            $out .= process_remaining_line($_);
                            next;
                        }

                        next;
                    }

                    # a new element in an existing list or new list
                    if (length $leading_space != $cur_list_indent) {
                        my $new_level = $ind2level{length $leading_space};
                        if (defined $new_level) {
                            if ($new_level < $list_level) {
                                # closing current nested levels
                                for (my $level = $list_level; $level > $new_level; $level--) {
                                    $out .= "\n=back\n\n";
                                    my $ind = $level2ind{$level};
                                    delete $level2ind{$level};
                                    delete $ind2level{$ind};
                                    delete $list_idx{$level};
                                }
                                $list_level = $new_level;
                                $cur_list_indent = $level2ind{$list_level};

                                my $idx = $list_idx{$list_level};
                                if (defined $idx) {
                                    # being a numbered list
                                    $list_idx{$list_level}++;
                                    $idx++;
                                    $out .= "\n=item $idx.\n\n";

                                } else {
                                    $out .= "\n=item *\n\n";
                                }

                                $out .= process_remaining_line($_);

                            } else {
                                die "cannot happen!";
                            }

                        } else {
                            # a new nested list
                            $list_level++;

                            $out .= "\n=over\n\n";

                            if ($prefix =~ /^[-+*]$/) {
                                $out .= "\n=item *\n\n";
                            } else {
                                $list_idx{$list_level} = 1;
                                $out .= "\n=item 1.\n\n";
                            }

                            $cur_list_indent = length $leading_space;
                            $ind2level{$cur_list_indent} = $list_level;
                            $level2ind{$list_level} = $cur_list_indent;

                            $out .= process_remaining_line($_);
                        }

                    } else {
                        # in the current list

                        my $idx = $list_idx{$list_level};
                        if (defined $idx) {
                            # being a numbered list
                            $list_idx{$list_level}++;
                            $idx++;
                            $out .= "\n=item $idx.\n\n";

                        } else {
                            $out .= "\n=item *\n\n";
                        }

                        $out .= process_remaining_line($_);
                    }
                }

                undef $just_seen_newline;
                next;
            }

            if (/ \G ^ (\#+) \s+ /gcxm) {
                undef $just_seen_newline;

                if ($list_level) {
                    for (my $level = $list_level; $level > 0; $level--) {
                        $out .= "\n=back\n\n";
                        my $ind = $level2ind{$level};
                        delete $level2ind{$level};
                        delete $ind2level{$ind};
                        delete $list_idx{$level};
                    }

                    undef $list_level;
                    undef $cur_list_indent;
                }

                my $level = length $1;
                if ($level > 4) {
                    $level = 4;  # POD only supports 4 levels.
                }
                $out .= "\n=head$level ";
                $out .= process_remaining_line($_);
                $out =~ s/ \s* \#+ \s* $//xg;
                $out .= "\n";

                next;
            }

            if (/ \G ^ (\s*) /gcxm) {  # not an empty line though
                my $leading_space = $1;
                if ($list_level) {
                    # append to the previous paragraph
                    $out .= process_remaining_line($_);
                    undef $just_seen_newline;

                } else {
                    if ($just_seen_newline) {
                        undef $just_seen_newline;

                        if (length $leading_space >= 4) {
                            #warn "found new code";
                            # new code
                            m/ \G (.* \n?) /gcxm;
                            $out .= $leading_space . $1;
                            $in_code = 1;
                            undef $add_indent;

                        } else {
                            # new paragraph
                            #s/^\s*//;
                            $out .= process_remaining_line($_);
                        }

                    } else {
                        # append to the previous paragraph
                        $out .= process_remaining_line($_);
                    }
                }

                next;
            }

            $out .= process_remaining_line($_);

            if (pos $_ && pos $_ >= $total_len) {
                last;
            }
        }
    }

    close $in;

    if ($list_level) {
        for (my $level = $list_level; $level > 0; $level--) {
            $out .= "\n=back\n\n";
            my $ind = $level2ind{$level};
            delete $level2ind{$level};
            delete $ind2level{$ind};
            delete $list_idx{$level};
        }

        undef $list_level;
        undef $cur_list_indent;
    }

    return $out;
}

sub process_remaining_line {
    #warn pos $_[0] // 0;
    my %seen_quotes;
    my $out = '';
    for ($_[0]) {
        while (1) {

            if (!$seen_quotes{'**'} && m/ \G (\*\*) (?= .*? \*\* ) /gcxm
                || !$seen_quotes{'**'} && !$seen_quotes{'*'} && m/ \G ( \* ) (?= .*? \* ) /gcxm
                || $seen_quotes{'**'} && !$seen_quotes{'*'} && m/ \G ( \* ) (?! \* ) (?= .+? \* ) /gcxm)
            {
                my $quote = $1;
                # an opening quote
                if (length $quote == 1) {
                    $out .= "I<";
                } else {
                    $out .= "B<";
                }
                $seen_quotes{$quote} = 1;
                next;
            }

            if ($seen_quotes{'**'} && m/ \G (\*\*) /gcxm
                || !$seen_quotes{'**'} && $seen_quotes{'*'} && m/ \G ( \* ) /gcxm
                || $seen_quotes{'**'} && $seen_quotes{'*'} && m/ \G ( \* ) (?! \* ) /gcxm)
            {
                # found a closing quote
                my $quote = $1;
                $out .= ">";
                delete $seen_quotes{$quote};
                next;
            }

            if (!$seen_quotes{'__'} && m/ \G \b (__) (?= .*? __ \b ) /gcxm
                || !$seen_quotes{'__'} && !$seen_quotes{'_'} && m/ \G \b ( _ ) (?= .*? _ \b ) /gcxm
                || $seen_quotes{'__'} && !$seen_quotes{'_'} && m/ \G \b ( _ ) (?! _ \b ) (?= .+? _ \b ) /gcxm)
            {
                my $quote = $1;
                # an opening quote
                if (length $quote == 1) {
                    $out .= "I<";
                } else {
                    $out .= "B<";
                }
                $seen_quotes{$quote} = 1;
                next;
            }

            if ($seen_quotes{'__'} && m/ \G (__) /gcxm
                || !$seen_quotes{'__'} && $seen_quotes{'_'} && m/ \G ( _ ) /gcxm
                || $seen_quotes{'__'} && $seen_quotes{'_'} && m/ \G ( _ ) (?! _ ) /gcxm)
            {
                # found a closing quote
                my $quote = $1;
                $out .= ">";
                delete $seen_quotes{$quote};
                next;
            }

            if (/ \G ([<>]) /gcx) {
                my $c = $1;
                if ($c eq '<') {
                    $out .= "E<lt>";

                } elsif ($c eq '>') {
                    $out .= "E<gt>";
                }
            }

            if (/ \G \&(\w+); /gcx) {
                my $entity = $1;
                my $pod = $html_entities{$entity};
                if ($pod) {
                    $out .= $pod;

                } else {
                    $out .= "E<$entity>";
                }

                next;
            }

            if (/ \G \& \# (\d+) ; /gcx) {
                my $dec = $1;
                $out .= "E<$dec>";
                next;
            }

            if (/ \G ` (.*?) ` /gcx) {
                my $code = $1;
                my $level;

                if ($code =~ /(>+)/) {
                    $level = length($1) + 1;

                } elsif ($code =~ /^</) {
                    $level = 2;

                } else {
                    $level = 1;
                }

                if ($level == 1) {
                    $out .= "C<$code>";
                } else {
                    $out .= 'C' . ('<' x $level) . " $code " . ('>' x $level);
                }
            }

            if (/ \G \\ ([\[\]]) /gcx) {
                $out .= $1;
                next;
            }

            if (/ \G \[ ( [^\n\[\]]* ) \] \( ( [^()\n]* ) \) /gcxm) {
                my ($label, $link) = ($1, $2);

                if ($label eq 'Back to TOC') {
                    next;
                }

                $label =~ s/\|/E<verbar>/g;
                $label =~ s{/}{E<sol>}g;
                if ($link =~ m/^\#/) {
                    $out .= "L<$label>";
                } else {
                    $out .= "L<$label|$link>";
                }
                next;
            }

            if (/ \G ( [^`<>\[\n*_\&\\]+ ) /gcxm) {
                $out .= $1;
                next;
            }

            if (/ \G (.) /gcxm) {
                $out .= $1;
                next;
            }

            last;
        }
    }

    if ($_[0] =~ / \G \n /gcx) {
        $out .= "\n";
    }

    #warn pos $_[0] // 0;

    return $out;
}

sub pos_str {
    my $pos = pos $_[0];
    my ($ln, $col);
    if (!defined $pos) {
        $pos = 0;
        $ln = 1;
        $col = 1;

    } else {
        my $s = substr $_[0], 0, $pos;
        $ln = 1;
        while ($s =~ /\n/gc) {
            $ln++;
        }
        $s =~ /\G (.*) /gcx;
        $col = 1 + length $1;
    }

    return "pos $pos line $ln, col $col";
}

sub usage {
    my $code = shift;
    my $msg = <<_EOC_;
Usage:
    $0 [options] <input-file>

Options:

    -h           Print out this usage.
    -o file      Specify the output POD file.

Copyright (C) Yichun Zhang (agentzh). All rights reserved.
_EOC_

    if ($code == 0) {
        print $msg;
        exit(0);
    }

    print STDERR $msg;
    exit($code);
}
